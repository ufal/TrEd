# -*- cperl -*-
################
### SQL compiler and evaluator
################

#### TrEd interface to Tree_Query::Evaluator
{

package Tree_Query::SQLSearch;
use Benchmark;
use Carp;
use strict;
use warnings;
use Scalar::Util qw(weaken);
use Tree_Query::SQLEvaluator;

BEGIN { import TredMacro  }

our %DEFAULTS = (
  row_limit => 5000,
  limit => 100,
  timeout => 30,
);

$Tree_Query::SQLSearchPreserve::object_id=0; # different NS so that TrEd's reload-macros doesn't clear it

sub new {
  my ($class,$opts)=@_;
  $opts||={};
  my $self = bless {
    object_id =>  $Tree_Query::SQLSearchPreserve::object_id++,
    evaluator => undef,
    config => {
      pml => $opts->{config_pml},
    },
    query => undef,
    query_nodes => undef,
    results => undef,
  }, $class;
  $self->init($opts->{config_file},$opts->{config_id}) || return;
  $self->{callback} = [\&open_pmltq,$self];
  weaken($self->{callback}[1]);
  register_open_file_hook($self->{callback});
  my $ident = $self->identify;
  (undef, $self->{label}) = Tree_Query::CreateSearchToolbar($ident);
  my $fn = $self->filelist_name;
  $self->{on_destroy} = MacroCallback(
    sub {
      DestroyUserToolbar($ident);
      for my $win (map { $_->[0] } grep { $_->[1]->name eq $fn } grep ref($_->[1]), map [$_,GetCurrentFileList($_)], TrEdWindows()) {
	CloseFileInWindow($win);
	CloseWindow($win);
      }
      RemoveFileList($fn) if GetFileList($fn);
      ChangingFile(0);
    });
  return $self;
}

sub DESTROY {
  my ($self)=@_;
  warn "DESTROING $self\n";
  RunCallback($self->{on_destroy}) if $self->{on_destroy};
  unregister_open_file_hook($self->{callback});
}

sub identify {
  my ($self)=@_;
  my $ident= "SQLSearch-".$self->{object_id};
  if ($self->{config}{data}) {
    my $cfg = $self->{config}{data};
    $ident.=
      $cfg->{id} ? " $cfg->{id}" : " $cfg->{driver}:$cfg->{username}\@$cfg->{host}:$cfg->{port}/$cfg->{database}";
  }
  return $ident;
}

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  my $query = $opts->{query} || $root;
  $self->{query}=$query;
  $self->init_evaluator;
  my ($limit, $row_limit, $timeout) = map { int($opts->{$_}||$self->{config}{pml}->get_root->get_member($_)||0)||$DEFAULTS{$_} }
    qw(limit row_limit timeout);
  eval {
    $self->{evaluator}->prepare_query($query,{
      node_limit => $limit,
      row_limit => $row_limit,
      no_filters => $opts->{no_filters},
    });
  };
  if ($@) {
    ErrorMessage($@);
    return unless GUI() and $opts->{edit_sql};
  }
  if (GUI() and $opts->{edit_sql}) {
    my $sql = EditBoxQuery(
      "SQL Query",
      $self->{evaluator}->get_sql,
      qq{Confirm or Edit the generated SQL Query},
     );
    return unless defined($sql) and length($sql);
    $self->{evaluator}->prepare_sql($sql);
  }
  $self->{last_query_nodes} = $self->{evaluator}->get_query_nodes;
  my $results = $self->{evaluator}->run({
    node_limit => $limit,
    row_limit => $row_limit,
    timeout => $timeout,
    timeout_callback => sub {
      (!GUI() or
	 QuestionQuery('Query Timeout',
			 'The evaluation of the query seems to take too long',
		       'Wait another '.$timeout.' seconds','Abort') eq 'Abort') ? 0 : 1
		     },
  });
  my $returns_nodes = $self->{evaluator}{returns_nodes};
  $self->{results} = $results if $returns_nodes;
  my $matches = @$results;
  if ($matches) {
    print "Returns nodes: $returns_nodes\n";
    $limit=$row_limit unless $returns_nodes;
    my $how_many = ((defined($limit) and $matches==$limit) ? '>=' : '').
      $matches.($returns_nodes ? ' match'.($matches>1?'es':'') : ' row'.($matches>1?'s':''));
    return $results unless
      (!$returns_nodes and $matches<200) or
	QuestionQuery('Results',
		      $how_many,
		      'Display','Cancel') eq 'Display';
    unless ($returns_nodes) {
      EditBoxQuery(
	"Results ($how_many)",
	join("\n",map { join("\t",@$_) } @$results),
	qq{},
	{-buttons=>['Close']}
       );
      return;
    }
    my @wins = TrEdWindows();
    my $res_win;
    my $fn = $self->filelist_name;
    if (@wins>1) {
      ($res_win) = grep { 
	my $f = GetCurrentFileList($_);
	($f and $f->name eq $fn)
      } @wins;
      unless ($res_win) {
	($res_win) = grep { $_ ne $grp } @wins;
      }
    } else {
      $res_win = SplitWindowVertically();
    }
    {
      my $fl = Filelist->new($fn);
      my @files = map {
	'pmltq://'.join('/',$self->{object_id},@$_)
      } @$results;
      $fl->add_arrayref(0, \@files);
      my @context=($this,$root,$grp);
      CloseFileInWindow($res_win);
      EnableMinorMode('Tree_Query_Results',$res_win);
      $grp=$res_win;
      SetCurrentWindow($grp);
      SetCurrentStylesheet(STYLESHEET_FROM_FILE);
      AddNewFileList($fl);
      SetCurrentFileList($fl->name,{no_open=>1});
      #GotoFileNo(0);
      $self->{current_result}=[$self->{evaluator}->idx_to_pos($results->[0])];
      ($this,$root,$grp)=@context;
      ${$self->{label}} = (CurrentFileNo($res_win)+1).' of '.(LastFileNo($res_win)+1).
	($limit == $matches ? '+' : '');
      $self->show_result('current');
      SetCurrentWindow($grp);
#      $grp->{famegroup}{focusedWindow}=$res_win;
#      local $main::insideEval=0;
#      main::focusCanvas($grp->canvas, $grp->{framegroup});
    }
  } else {
    QuestionQuery('Results','No results','OK');
  }
  return $results;
}

sub current_query {
  my ($self)=@_;
  return $self->{query};
}

sub show_next_result {
  my ($self)=@_;
  return $self->show_result('next');
}

sub show_prev_result {
  my ($self)=@_;
  return $self->show_result('prev');
}

sub show_current_result {
  my ($self)=@_;
  return $self->show_result('current');
}

sub resolve_path {
  my ($self,$path)=@_;
  return $path if $path=~m{^/};
  return $self->get_source_dir.'/'.$path;
}

sub get_source_dir {
  my ($self)=@_;
  my $conf = $self->{config}{data};
  my $source_dir = $conf->{sources};
  unless ($source_dir) {
    if (GUI()) {
      EditAttribute($conf,'sources',
		    $self->{config}{type},
		   ) || return;
      $self->{config}{pml}->save();
      $source_dir = $conf->{sources};
    }
  }
  return $source_dir;
}

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () }
    map { $self->resolve_path($_) } @{$self->{current_result}};
  return @nodes[@positions];
}

sub map_nodes_to_query_pos {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my @nodes = ($tree,$tree->descendants);
  my $r = $self->{current_result};
  return {
    map { $_->[1]=~/^\Q$fn\E\.(\d+)$/ ? ($nodes[$1] => $_->[0]) : () } 
      reverse # upper nodes first (optional nodes do not overwrite their parents)
      map { [$_,$self->resolve_path($r->[$_])] } 0..$#$r 
  };
}

sub node_index_in_last_query {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  return Index($self->{last_query_nodes},$query_node);
}

sub select_matching_node {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  my $idx = Index($self->{last_query_nodes},$query_node);
  return if !defined($idx);
  my $result = $self->{current_result}->[$idx];
  $result = $self->resolve_path($result);
  foreach my $win (TrEdWindows()) {
    my $fsfile = $win->{FSFile};
    next unless $fsfile;
    my $fn = $fsfile->filename.'##'.($win->{treeNo}+1);
    next unless $result =~ /\Q$fn\E\.(\d+)$/;
    my $pos = $1;
    my $r=$fsfile->tree($win->{treeNo});
    for (1..$pos) {
      $r=$r->following();
    }
    if ($r) {
      EnableMinorMode('Tree_Query_Results',$win);
      SetCurrentNodeInOtherWin($win,$r);
      CenterOtherWinTo($win,$r);
    }
  }
  return;
}

sub get_node_types {
  my ($self)=@_;
  $self->init_evaluator;
  return $self->{evaluator}->get_node_types;
}

sub configure {
  my ($self)=@_;
  my $config = $self->{config}{pml};
  GUI() && EditAttribute($config->get_root,'',
			 $config->get_schema->get_root_decl->get_content_decl) || return;
  $config->save();
  return 1;
}

sub reconfigure {
  my ($self)=@_;
  my $cfg = $self->{config}{pml};
  undef $self->{config}{pml};
  return $self->init($cfg->get_filename,$self->{config}{id}) if $cfg;
  return;
}

sub get_schema_for_query_node {
  my ($self,$node)=@_;
  my $ev = $self->init_evaluator;
  return $ev->get_schema($ev->get_schema_name_for(Tree_Query::Common::GetQueryNodeType($node)));
}

sub get_schema_for_type {
  my ($self,$type)=@_;
  my $ev = $self->init_evaluator;
  return $ev->get_schema_for_type($type);
}

sub get_type_decl_for_query_node {
  my ($self,$node)=@_;
  my $ev = $self->init_evaluator;
  return $ev->get_decl_for(Tree_Query::Common::GetQueryNodeType($node));
}

sub get_decl_for {
  my ($self,$type)=@_;
  return unless $type;
  my $ev = $self->init_evaluator;
  return $ev->get_decl_for($type);
}

#########################################
#### Private API

sub init {
  my ($self,$config_file,$id)=@_;
  $self->load_config_file($config_file) || return;
  my $configuration = $self->{config}{data};
  my $cfgs = $self->{config}{pml}->get_root->{configurations};
  my $cfg_type = $self->{config}{type};
  if (!$id) {
    my @opts = ((map { $_->value->{id} } grep { $_->name eq 'dbi' } SeqV($cfgs)),' CREATE NEW CONNECTION ');
    my @sel= $configuration ? $configuration->{id} : @opts ? $opts[0] : ();
    ListQuery('Select treebase connection',
			 'browse',
			 \@opts,
			 \@sel) || return;
    ($id) = @sel;
  }
  return unless $id;
  my $cfg;
  if ($id eq ' CREATE NEW CONNECTION ') {
    $cfg = Fslib::Struct->new();
    GUI() && EditAttribute($cfg,'',$cfg_type) || return;
    $cfgs->push_element('dbi',$cfg);
    $self->{config}{pml}->save();
    $id = $cfg->{id};
  } else {
    $cfg = first { $_->{id} eq $id } map $_->value, grep { $_->name eq 'dbi' } SeqV($cfgs);
    die "Didn't find configuration '$id'" unless $cfg;
  }
  $self->{config}{id} = $id;
  unless (defined($cfg->{username}) and defined($cfg->{password})) {
    if (GUI()) {
       EditAttribute($cfg,'',$cfg_type,'password') || return;
    } else {
      die "The configuration $id does not specify username or password\n";
    }
    $self->{config}{pml}->save();
  }
  $self->{config}{data} = $cfg;
}

sub init_evaluator {
  my ($self)=@_;
  unless ($self->{evaluator}) {
    $self->{evaluator} = Tree_Query::SQLEvaluator->new(undef,{connect => $self->{config}{data}});
  CONNECT: {
      eval {
	$self->{evaluator}->connect;
      };
      if ($@) {
	ErrorMessage($@);
	if ($@ =~ /timed out/) {
	  return;
	}
	GUI() && EditAttribute($self->{config}{data},'',$self->{config}{type},'password') || return;
	$self->{config}{pml}->save();
	redo CONNECT;
      }
    }
  }
  return $self->{evaluator};
}


sub filelist_name {
  my $self=shift;
  return ref($self).":".$self->{object_id};
}

sub show_result {
  my ($self,$dir)=@_;
  return unless $self->{evaluator};
  my @save = ($this,$root,$grp);
  return unless ($self->{current_result} and $self->{last_query_nodes}
	and @{$self->{current_result}} and @{$self->{last_query_nodes}});
  my $win=$self->claim_search_win();
  eval {
    if ($dir eq 'prev') {
      $grp=$win;
      PrevFile();
      my $idx = Index($self->{last_query_nodes},$save[0]);
      if (defined($idx)) {
	my $fn = FileName();
	my $result_fn = $self->resolve_path($self->{current_result}[$idx]);
	if ($result_fn !~ /^\Q$fn\E\.(\d+)$/) {
	  Open($result_fn,{-keep_related=>1});
	  Redraw($win);
	} else {
	  $self->select_matching_node($save[0]);
	}
      }
    } elsif ($dir eq 'next') {
      $grp=$win;
      NextFile();
#       my $idx = Index($self->{last_query_nodes},$save[0]);
#       if (defined($idx)) {
# 	my $fn = FileName();
# 	my $result_fn = $self->resolve_path($self->{current_result}[$idx]);
# 	print "$fn, $result_fn\n";
# 	if ($result_fn !~ /^\Q$fn\E\.(\d+)$/) {
# 	  Open($result_fn,{-keep_related=>1});
# 	  Redraw($win);
# 	} else {
# 	  $self->select_matching_node($save[0]);
# 	}
#       }
    } elsif ($dir eq 'current') {
      return unless $self->{current_result};
      my $idx = Index($self->{last_query_nodes},$save[0]);
      print "IDX: $idx\n";
      if (defined($idx)) {
	$grp=$win;
	Open($self->resolve_path($self->{current_result}[$idx]),{-keep_related=>1});
	Redraw($win);
      }
    }
  };
  my $err=$@;
  my $plus = ${$self->{label}}=~/\+/;
  ${$self->{label}} = (CurrentFileNo($win)+1).' of '.(LastFileNo($win)+1).
    ($plus ? '+' : '');
  ($this,$root,$grp)=@save;
  die $err if $err;
  return;
}


sub claim_search_win {
  my ($self)=@_;
  my $fn = $self->filelist_name;
  my ($win) = map { $_->[0] } grep { $_->[1]->name eq $fn } grep ref($_->[1]), map [$_,GetCurrentFileList($_)], TrEdWindows();
  unless ($win) {
    $win = SplitWindowVertically();
    my $cur_win = $grp;
    $grp=$win;
    eval { SetCurrentFileList($fn) };
    $grp=$cur_win;
    die $@ if $@;
  }
  return $win;
}

sub update_label {
  my ($self)=@_;
  my $past = (($self->{past_results} ? int(@{$self->{past_results}}) : 0)
		+ ($self->{current_result} ? 1 : 0));
  ${$self->{label}} = $past.' of '.
	 ($self->{next_results} ? $past+int(@{$self->{next_results}}) : $past).'+';
}

# registered open_file_hook
# called by Open to translate URLs of the
# form pmltq//table/idx/table/idx ....  to a list of file positions
# and opens the first of the them
sub open_pmltq {
  my ($self,$filename,$opts)=@_;
  print "$filename\n";
  my $object_id=$self->{object_id};
  return unless $filename=~s{pmltq://$object_id/}{};
  my @positions = $self->{evaluator}->idx_to_pos([split m{/}, $filename]);
  $self->{current_result}=\@positions;
  my ($node) = map { CurrentNodeInOtherWindow($_) }
              grep { CurrentContextForWindow($_) eq 'Tree_Query' } TrEdWindows();
  my $idx = Index($self->{last_query_nodes},$node);
  my $first = $positions[$idx||0];
  if (defined $first and length $first) {
    $opts->{-norecent}=1;
    $opts->{-keep_related}=1;
    my $fsfile = Open($self->resolve_path($first),$opts);
    if (ref $fsfile) {
      $fsfile->changeAppData('tree_query_url',$filename);
      $fsfile->changeAppData('norecent',1);
      for my $req_fs (GetSecondaryFiles($fsfile)) {
	$req_fs->changeAppData('norecent',1);
      }
    }
    Redraw();
  }
  return 'stop';
}

sub load_config_file {
  my ($self,$config_file)=@_;
  if (!$self->{config}{pml} or ($config_file and
				$config_file ne $self->{config}{pml}->get_filename)) {
    if ($config_file) {
      die "Configuration file '$config_file' does not exist!" unless -f $config_file;
      $self->{config}{pml} = PMLInstance->load({ filename=>$config_file });
    } else {
      $config_file ||= FindInResources('treebase.conf');
      if (-f $config_file) {
	$self->{config}{pml} = PMLInstance->load({ filename=>$config_file });
      } else {
	my $tred_d = File::Spec->catfile($ENV{HOME},'.tred.d');
	mkdir $tred_d unless -d $tred_d;
	$config_file = File::Spec->catfile($tred_d,'treebase.conf');
	$self->{config}{pml} = PMLInstance->load({ string => $DEFAULTS{dbi_config},
					      filename=> $config_file});
	$self->{config}{pml}->save();
      }
    }
  }
  $self->{config}{type} = $self->{config}{pml}->get_schema->get_type_by_name('dbi-config.type')->get_content_decl;
  return $self->{config}{pml};
}

sub get_results {
  my $self = shift;
  return $self->{results} || [];
}

sub get_query_nodes {
  my $self = shift;
  return $self->{query_nodes};
}


my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
$DEFAULTS{dbi_config} = <<"EOF";
<pmltq_config xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema href="treebase_conf_schema.xml"/>
  </head>
  <limit>$DEFAULTS{limit}</limit>
  <row_limit>$DEFAULTS{row_limit}</row_limit>
  <timeout>$DEFAULTS{timeout}</timeout>
  <configurations>
  </configurations>
</pmltq_config>
EOF

} # SQL
