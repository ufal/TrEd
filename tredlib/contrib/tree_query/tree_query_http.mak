# -*- cperl -*-
################
### SQL compiler and evaluator
################

#### TrEd interface to Tree_Query::Evaluator
{

package Tree_Query::HTTPSearch;
use Benchmark;
use Carp;
use strict;
use warnings;
use Scalar::Util qw(weaken);
use HTTP::Request::Common;
use LWP::UserAgent;
use Encode;

BEGIN { import TredMacro  }

our %DEFAULTS = (
  row_limit => 5000,
  limit => 100,
  timeout => 30,
);

$Tree_Query::HTTPSearchPreserve::object_id=0; # different NS so that TrEd's reload-macros doesn't clear it
my $ua = LWP::UserAgent->new;
$ua->agent("TrEd/1.0 ");

sub new {
  my ($class,$opts)=@_;
  $opts||={};
  my $self = bless {
    object_id =>  $Tree_Query::HTTPSearchPreserve::object_id++,
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
}

sub identify {
  my ($self)=@_;
  my $ident= "HTTPSearch-".$self->{object_id};
  if ($self->{config}{data}) {
    my $cfg = $self->{config}{data};
    $ident.=" $cfg->{username}\@$cfg->{url}";
  }
  return $ident;
}

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  my $query = $self->{query} = $opts->{query} || $root;
  $self->{last_query_nodes} = [Tree_Query::Common::FilterQueryNodes($query)];
  $query = Tree_Query::Common::as_text($query,{resolve_types=>1}) if ref($query);
  my ($limit, $row_limit, $timeout) = map { int($opts->{$_}||$self->{config}{pml}->get_root->get_member($_)||0)||$DEFAULTS{$_} }
    qw(limit row_limit timeout);
  my $t0 = new Benchmark;
  my $res = $self->request(query => [
    query => $query,
    format => 'text',
    limit => $limit,
    row_limit => $row_limit,
    timeout => $timeout,
   ]);
  my $t1 = new Benchmark;
  my $time = timestr(timediff($t1,$t0));
  unless ($opts->{quiet}) {
    my $id = root->{id} || '*';
    print STDERR "$id\t".$self->identify."\t$time\n";
  }
  unless ($res->is_success) {
    ErrorMessage($res->status_line, "\n");
    return;
  }
  my $results = [ map { [ split /\t/, $_ ] } split /\r?\n/, Encode::decode_utf8($res->content,1) ];
  my $matches = @$results;
  if ($matches) {
    my $returns_nodes=$res->header('Pmltq-returns-nodes');
    $limit=$row_limit unless $returns_nodes;
    return $results unless
      (!$returns_nodes and $matches<200) or
	QuestionQuery('Results',
		      ((defined($limit) and $matches==$limit) ? '>=' : '').
			$matches.($returns_nodes ? ' match'.($matches>1?'(es)':'') : ' row'.($matches>1?'(s)':'')),
		      'Display','Cancel') eq 'Display';
    unless ($returns_nodes) {
      EditBoxQuery(
	"Results",
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
      $fl->add(0, @files);
      my @context=($this,$root,$grp);
      CloseFileInWindow($res_win);
      $grp=$res_win;
      SetCurrentStylesheet(STYLESHEET_FROM_FILE);
      AddNewFileList($fl);
      SetCurrentFileList($fl->name,{no_open=>1});
      #GotoFileNo(0);
      $self->{current_result}=[$self->idx_to_pos($results->[0])];
      ($this,$root,$grp)=@context;
      ${$self->{label}} = (CurrentFileNo($res_win)+1).' of '.(LastFileNo($res_win)+1).
	($limit == $matches ? '+' : '');
      $self->show_result('current');
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

sub __cat_path {
  my ($source_dir,$path)=@_;
  return $path if $path=~m{^/};
  return $source_dir.'/'.$path;
}

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my $source_dir = $self->get_source_dir;
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () }
    map { __cat_path($source_dir,$_) } @{$self->{current_result}};
  return @nodes[@positions];
}

sub map_nodes_to_query_pos {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my $source_dir = $self->get_source_dir;
  my @nodes = ($tree,$tree->descendants);
  my $r = $self->{current_result};
  return {
    map { $_->[1]=~/^\Q$fn\E\.(\d+)$/ ? ($nodes[$1] => $_->[0]) : () } map { [$_,__cat_path($source_dir,$r->[$_])] } 0..$#$r 
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
  my $source_dir = $self->get_source_dir;
  $result = __cat_path($source_dir,$result);
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
      SetCurrentNodeInOtherWin($win,$r);
      CenterOtherWinTo($win,$r);
    }
  }
  return;
}

sub get_node_types {
  my ($self)=@_;
  my $res = $self->request('nodetypes',[format=>'text']);
  unless ($res->is_success) {
    ErrorMessage($res->status_line, "\n");
    return;
  }
  return [ split /\r?\n/, Encode::decode_utf8($res->content,1) ];
}

sub configure {
  my ($self)=@_;
  my $config = $self->{config}{pml};
  GUI() && EditAttribute($config->get_root,'',
			 $config->get_schema->get_root_decl->get_content_decl) || return;
  $config->save();
}

sub get_schema_for_query_node {
  my ($self,$node)=@_;
  my $type = Tree_Query::Common::GetQueryNodeType($node);
  return $self->get_schema($self->get_schema_name_for($type));
}

sub get_schema_for_type {
  my ($self,$type)=@_;
  return $self->get_schema($self->get_schema_name_for($type));
}

sub get_type_decl_for_query_node {
  my ($self,$node)=@_;
  return $self->get_decl_for(Tree_Query::Common::GetQueryNodeType($node));
}

#########################################
#### Private API

sub get_schema_name_for {
  my ($self,$type)=@_;
  if ($self->{schema_types}{$type}) {
    return $self->{schema_types}{$type};
  }
  my $res = $self->request('type',[
    type => $type,
    format=>'text'
  ]);
  unless ($res->is_success) {
    die "Couldn't resolve schema name for type $type: ".$res->status_line."\n";
  }
  my $name = Encode::decode_utf8($res->content,1);
  $name=~s/\r?\n$//;
  return $self->{schema_types}{$type} = $name || die "Did not find schema name for type $type\n";
}

sub get_schema {
  my ($self,$name)=@_;
  return unless $name;
  if ($self->{schemas}{$name}) {
    return $self->{schemas}{$name};
  }
  my $res = $self->request('schema',[
    name => $name,
   ]);
  unless ($res->is_success) {
    die "Failed to obtain PML schema $name ".$res->status_line."\n";;
  }
  return $self->{schemas}{$name} = PMLSchema->new({string => Encode::decode_utf8($res->content,1)})
    || die "Failed to obtain PML schema $name\n";
}

sub get_decl_for {
  my ($self,$type)=@_;
  return unless $type;
  return $self->{type_decls}{$type} ||= Tree_Query::Common::QueryTypeToDecl($type,$self->get_schema($self->get_schema_name_for($type)));
}

sub request {
  my ($self,$type,$data)=@_;
  my $cfg = $self->{config}{data};
  my $url = $cfg->{url};
  $url.='/' unless $url=~m{/};
  if (ref $data) {
    $data = [ map { Encode::_utf8_off($_); $_ } @$data ];
  } elsif (defined $data) {
    Encode::_utf8_off($data);
  }
  return $ua->request(POST(qq{${url}${type}}, $data));
}

sub init {
  my ($self,$config_file,$id)=@_;
  $self->load_config_file($config_file) || return;
  my $configuration = $self->{config}{data};
  my $cfgs = $self->{config}{pml}->get_root->{configurations};
  my $cfg_type = $self->{config}{type};
  if (!$id) {
    my @opts = ((map { $_->{id} } map $_->value, grep $_->name eq 'http', SeqV($cfgs)),' CREATE NEW ');
    my @sel= $configuration ? $configuration->{id} : @opts ? $opts[0] : ();
    ListQuery('Select treebase connection',
			 'browse',
			 \@opts,
			 \@sel) || return;
    ($id) = @sel;
  }
  return unless $id;
  my $cfg;
  if ($id eq ' CREATE NEW ') {
    $cfg = Fslib::Struct->new();
    GUI() && EditAttribute($cfg,'',$cfg_type) || return;
    $cfgs->append($cfg);
    $self->{config}{pml}->save();
    $id = $cfg->{id};
  } else {
    $cfg = first { $_->{id} eq $id } map $_->value, grep $_->name eq 'http', SeqV($cfgs);
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


sub filelist_name {
  my $self=shift;
  return ref($self).":".$self->{object_id};
}

sub show_result {
  my ($self,$dir)=@_;
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
	my $source_dir = $self->get_source_dir;
	my $fn = FileName();
	my $result_fn = __cat_path($source_dir,$self->{current_result}[$idx]);
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
# 	my $source_dir = $self->get_source_dir;
# 	my $fn = FileName();
# 	my $result_fn = __cat_path($source_dir,$self->{current_result}[$idx]);
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
      if (defined($idx)) {
	$grp=$win;
	my $source_dir = $self->get_source_dir;
	Open(__cat_path($source_dir,$self->{current_result}[$idx]),{-keep_related=>1});
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
    eval {
      if ($self->{file}) {
	Open($self->{file});
      } elsif ($self->{filelist}) {
	SetCurrentFileList($self->{filelist});
      }
    };
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

sub idx_to_pos {
  my ($self,$idx_list)=@_;
  my @res;
  my @list=@$idx_list;
  while (@list) {
    my ($idx,$type)=(shift @list, shift @list);
    my $res = $self->request('node',
		   [ idx=>$idx,
		     type=>$type,
		     format=>'text',
		   ]);
    unless ($res->is_success) {
      die "Failed to resolve $type $idx ".$res->status_line."\n";;
    }
    my $f = $res->content;
    $f=~s/\r?\n$//;
    print "$f\n";
    push @res, $f;
  }
  return @res;
}

# registered open_file_hook
# called by Open to translate URLs of the
# form pmltq//table/idx/table/idx ....  to a list of file positions
# and opens the first of the them
sub open_pmltq {
  my ($self,$filename,$opts)=@_;
  my $object_id=$self->{object_id};
  return unless $filename=~s{pmltq://$object_id/}{};
  my @positions = $self->idx_to_pos([split m{/}, $filename]);
  print "$filename: @positions\n";
  $self->{current_result}=\@positions;
  my ($node) = map { CurrentNodeInOtherWindow($_) }
              grep { CurrentContextForWindow($_) eq __PACKAGE__ } TrEdWindows();
  my $idx = Index($self->{last_query_nodes},$node);
  my $first = $positions[$idx||0];
  if (defined $first and length $first) {
    my $source_dir = $self->get_source_dir;
    $opts->{-norecent}=1;
    $opts->{-keep_related}=1;
    my $fsfile = Open(__cat_path($source_dir,$first),$opts);
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

sub get_source_dir {
  my ($self)=@_;
  my $cfg = $self->{config}{data};
  my $url = $cfg->{url};
  $url.='/' unless $url=~m{/};
  return qq{${url}file?f=};
}

sub load_config_file {
  my ($self,$config_file)=@_;
  if (!$self->{config}{pml} or ($config_file and
				$config_file ne $self->{config}{pml}->filename)) {
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
$DEFAULTS{pmltq_config} = <<"EOF";
<pmltq_config xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema href="treebase_conf_schema.xml"/>
  </head>
  <limit>$DEFAULTS{limit}</limit>
  <row_limit>$DEFAULTS{row_limit}</row_limit>
  <timeout>$DEFAULTS{timeout}</timeout>
  <configurations>
    <dbi id="postgress">
      <driver>Pg</driver>
      <host>localhost</host>
      <port>5432</port>
      <database>treebase</database>
      <username>$userlogin</username>
      <password></password>
    </dbi>
    <dbi id="oracle">
      <driver>Oracle</driver>
      <host>localhost</host>
      <port>1521</port>
      <database>XE</database>
      <username></username>
      <password></password>
    </dbi>
    <http id="localhost">
      <url>http://localhost:8121/</host>
      <username>$userlogin</username>
      <password></password>
    </http>
  </configurations>
</pmltq_config>
EOF

} # HTTP
