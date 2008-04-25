# -*- cperl -*-

#include <contrib/pml/PML.mak>

#TODO
#
# - new netgraph _optional semantics?

# - _transitive=exclusive (in NG by default, a query node can lay on
# the transitive edge of other query node; if =exclusive, than no query
# node can lay on the transitive edge and also, the transitive edge
# cannot share nodes with any other exclusive transitive edge (but can
# share nodes with some non-exclusive transitive edge)). Thus,
# exclusivity in NG seems equivalent to creating an optional node
# between the transitive query node and its query parent.

# allow the user to mark the nodes with colours and recognize the
# colored nodes in the result tree

# - _#lbrothers   - works
# - _#rbrothers   - does not yet work if relation is not 'parent'
# - _#sons        - works
# - _#descendants - works
# - modify type of the default relation: parent/ancestor/effective_parent/...)
#   (parent and ancestor implemented, TODO: effective_parent)
# - additional relations to existing nodes (of any type except parent and possibly descendant)
#   with possibility to negate them or maybe even using them in propositional formulae
# non-projective edge search

# relations/attributes from external tables:
# tables:
# - T            (tree structure)
# - T_FILEINFO   (currently T_POS)
# - T_ATTRS      (attribute structure, not yet used)
# - T_QUOT       (quot (list))
# - T_GRAM       (grammatemes)
# - T_COREF_GRAM (attribute structure (list))
# - T_COMPL      (attribute structure (list))
# - T_A_AUX      (relation to A_ (list))
# - T_EPARENTS   (relation to T_ (list))

# warn if optional=1 for a relation that implies a different type

# some helpful predicates:
#  - is_leaf
#

#
# relations and their representation by colors:
# - parent-child: grey
# - ancestor-descendant: light-blue
# - e_parent-e_child: green
# - preceding-following: yellow

package Tree_Query;
{
use strict;

BEGIN {
  use vars qw($this $root);
  import TredMacro;
  import PML qw(&SchemaName);
  use File::Spec;
  use Benchmark ':hireswallclock';
}

our ($DEFAULT_LIMIT,$DEFAULT_TIMEOUT)=(100, 30);

Bind 'query_sql' => {
  key => 'space',
  menu => 'Query SQL server',
  changing_file => 0,
};
Bind sub { next_match('this') } => {
  key => 'm',
  menu => 'Show Match',
  changing_file => 0,
};
Bind sub { next_match('forward') } => {
  key => 'n',
  menu => 'Show Next Match',
  changing_file => 0,
};
Bind sub { next_match('backward') } => {
  key => 'p',
  menu => 'Show Previous Match',
  changing_file => 0,
};


Bind 'fix_netgraph_query' => {
  key => 'f',
  menu => 'Attempt to fix a NetGraph query',
};

my $default_dbi_config; # see below
my $dbi_config;
my $dbi_configuration;
my $dbi;

Bind sub {
  undef $dbi;
  connect_dbi()
} => {
  key => 'c',
  menu => 'Connect to SQL server',
  changing_file => 0,
};
Bind sub {
  edit_config();
} => {
  key => 'e',
  menu => 'Edit Connection Configuration',
  changing_file => 0,
};


#include <contrib/support/extra_edit.inc>
#include <contrib/support/arrows.inc>

# Setup context
unshift @TredMacro::AUTO_CONTEXT_GUESSING,
sub {
  SchemaName() eq 'tree_query' ? __PACKAGE__ : undef ;
};
sub allow_switch_context_hook {
  return 'stop' if SchemaName() ne 'tree_query';
}

# Setup stylesheet
sub switch_context_hook {
  CreateStylesheets();
  SetCurrentStylesheet('Tree_Query'),Redraw()
    if GetCurrentStylesheet() ne 'Tree_Query'; #eq STYLESHEET_FROM_FILE();
  FileAppData('noautosave',1);
}
sub file_reloaded_hook {
  FileAppData('noautosave',1);
}

sub CreateStylesheets{
  unless(StylesheetExists('Tree_Query')){
    SetStylesheetPatterns(<<'EOF','Tree_Query',1);
context:   Tree_Query
hint: 
rootstyleforbalanced:#{balance:1}#{Node-textalign:center}#{NodeLabel-halign:center}
rootstyle: #{vertical:0}#{nodeXSkip:15}
rootstyle: #{Node-addwidth:3}#{Node-addheight:3}#{CurrentOval-width:3}#{CurrentOval-outline:red}
node: <?length($${node-type}) ? $${node-type}.': ' : '' ?><? length $${occurrences} ? ($${occurrences}."x")  : "" 
?><? $${optional} ? '?'  : q()
?><? Tree_Query::serialize_conditions_as_stylesheet($this) ?>
node: #{darkblue}${name}#{brown}<? my$d=$${description}; $d=~s{^User .*?:}{}; $d ?>
style: #{Line-tag:relation}<? 
  my ($rel) = map {
    my $name = $_->name;
    $name eq 'user-defined' ? $_->value->{label} : $name
  } SeqV($this->{relation});
  my $color = Tree_Query::arrow_color($rel);
  defined($color) ? "#{Line-fill:$color}" : ()
?>
style:<?
   $this->parent 
   ? (($${node-type}||$root->{'node-type'}) eq 't'
      ? '#{Node-shape:rectangle}#{Oval-fill:pink}' 
      : '#{Oval-fill:yellow}' )
   : '#{Oval-fill:gray}' ?>
style:<?
   length $${occurrences}
     ? '#{Node-addwidth:0}#{Node-addheight:0}' 
     : q() ?>
EOF
  }
}

my %id;
my %name2node_hash;
sub init_id_map {
  my ($tree)=@_;
  my @nodes = $tree->descendants;
  %id = map {
    my $n=lc($_->{name});
    (defined($n) and length($n)) ? ($_=>$n) : ()
  } @nodes;
  %name2node_hash = map {
    my $n=lc($_->{name});
    (defined($n) and length($n)) ? ($n=>$_) : ()
  } @nodes;
  my $id = 'n0';
  my %occup; @occup{values %id}=();
  for my $n (@nodes) {
    unless (defined $id{$n} and length $id{$n}) {
      $id++ while exists $occup{$id}; # just for sure
      $id{$n}=$id; # generate id;
      $occup{$id}=1;
    }
  };
}


sub root_style_hook {
  DrawArrows_init();
  init_id_map($root);
}
sub after_redraw_hook {
  DrawArrows_cleanup();
}
my %color = (
  'depth-first-precedes' => 'green',
  'order-precedes' => 'yellow',
  'a/lex.rf' => 'violet',
  'a/aux.rf' => 'thistle',
  'a/lex.rf|a/aux.rf' => 'tan',
  coref_text => '#4C509F',
  coref_gram => '#C05633',
  ancestor => 'blue',
  'ancestor-of' => 'blue',
  'descendant-of' => 'lightblue',
  'parent-of' => 'black',
  'parent' => 'black',
  'child-of' => 'lightgray',
  effective_parent => 'green',
);
sub arrow_color {
  my $rel = shift;
  return $color{$rel};
}
sub node_style_hook {
  my ($node,$styles) = @_;
  my $i=0;
  DrawArrows($node,$styles,
	     [
	       map {
		 my $name = $_->name;
		 $name = $_->value->{label} if $name eq 'user-defined';
		 my $target = $_->value->{target};
		 my $negate = $_->value->{negate};
		 scalar {
		   -target => $name2node_hash{lc($target)},
		   -fill   => arrow_color($name),
		   (-dash   => $negate ? '-' : ''),
		   -raise => 8+8*(++$i),
		   -tag => 'extra_relation',
		 }
	       } SeqV($node->attr('extra-relations'))
	     ],
	     {
	       -arrow => 'last',
	       -arrowshape => '14,18,4',
	       -width => 1,
	       -smooth => 1,
	     });
}

sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target and $mod;
  return 'stop' unless $target->parent and $node->parent;
  if ($mod eq 'Control') {
    my @sel = map {
      my $name = $_->name;
      if ($name eq 'user-defined') {
	qq{$name: }.$_->value->{label}
      } else {
	$name
      }
    } SeqV($node->attr('extra-relations'));
    ListQuery('Select treebase connections to add or preserve',
	      'multiple',
	      [
		map {
		  my $name = $_->get_name;
		  if ($name eq 'user-defined') {
		    (map { qq{$name: $_} } $_->get_content_decl->get_attribute_by_name('label')->get_content_decl->get_values())
		  } else {
		    $name;
		  }
		} $node->type->schema->get_type_by_name('q-extra-relation.type')->get_content_decl->get_elements(),
	      ],
	      \@sel) || return;
    init_id_map($node->root);
    AddOrRemoveRelations($node,$target,\@sel,{-add_only=>0});
    TredMacro::Redraw_FSFile_Tree();
    ChangingFile(1);
  }
  return;
}

# note: you have to call init_id_map($root); first!
sub AddOrRemoveRelations {
  my ($node,$target,$types,$opts)=@_;
  if (defined($target) and !defined($target->{name})) {
    my $i=0;
    $i++ while (exists $name2node_hash{"ref$i"});
    $target->set_attr('name',"ref$i");
    $name2node_hash{"ref$i"}=$target;
  }
  my %types = map { $_=> 1 } @$types;
  my $attr = $opts->{-attribute} || 'extra-relations';
  my $relations = $node->attr($attr);
  my %have;
  my @keep = grep {
    my $rel_name = $_->name;
    my $val = $_->value;
    my $t = defined($val) && defined($target) && $val->{target};
    if ($rel_name eq 'user-defined') {
      $rel_name = $val->{label};
    }
    if (defined($target) and lc($target->{name}) eq $t) {
      $have{$rel_name}=1;
      $opts->{-add_only} || $types{$rel_name}
    } else {
      1
    }
  } SeqV($relations);
  my @new;
  for my $type (grep { !$have{$_} } @$types) {
    my ($name,$value);
    if ($type=~s/^(user-defined): //) {
      $name=$1;
      $value = Fslib::Container->new(undef,{
	(defined($target) ? (target => lc($target->{name})) : ()),
	label => $type
       },1)
    } else {
      $name = $type;
      $value = Fslib::Container->new(undef,{
	(defined($target) ? (target => lc($target->{name})) : ()),
      },1);
    }
    push @new,Fslib::Seq::Element->new($name=>$value);
  }
  if (!$relations) {
    AddToSeq($node,$attr, @keep,@new);
  } else {
    @{$node->{$attr}->elements_list}=(@keep,@new);
  }
  return @new;
}


sub limit {
  my ($limit)=@_;
  unless ($dbi_config) {
    connect_dbi()||return;
  }
  my $driver = $dbi_configuration->{driver};
  if ($driver eq 'Oracle') {
    return 'AND ROWNUM<='.$limit;
  } elsif ($driver eq 'Pg') {
    return 'LIMIT '.$limit.';';
  }
}
sub load_config {
  unless ($dbi_config) {
    if (-f (my $filename=FindInResources('treebase.conf'))) {
      $dbi_config =
	PMLInstance->load({ filename=>$filename });
    } else {
      my $tred_d = File::Spec->catfile($ENV{HOME},'.tred.d');
      mkdir $tred_d unless -d $tred_d;
      $dbi_config =
	PMLInstance->load({ string => $default_dbi_config, 
			    filename=> File::Spec->catfile($tred_d,'treebase.conf')});
      $dbi_config->save();
    }
  }
  return $dbi_config;
}

sub edit_config {
  load_config();
  GUI() && EditAttribute($dbi_config->get_root,'',
			 $dbi_config->get_schema->get_root_decl->get_content_decl) || return;
  $dbi_config->save();
}

sub connect_dbi {
  require DBI;
  my ($id,$force_edit)=@_;
  return if $dbi;
  load_config() || return;
  my $cfgs = $dbi_config->get_root->{configurations};
  my $cfg_type = $dbi_config->get_schema->get_type_by_name('dbi-config.type')->get_content_decl;
  if (!defined($id) or GUI()) {
    my @opts = ((map { $_->{id} } ListV($cfgs)),' NEW ');
    my @sel= $dbi_configuration ? $dbi_configuration->{id} : @opts ? $opts[0] : ();
    ListQuery('Select treebase connection',
	      'browse',
	      \@opts,
	      \@sel) || return;
    ($id) = @sel;
  }
  return unless defined $id;
  my $cfg;
  if ($id eq ' NEW ') {
    $cfg = Fslib::Struct->new();
    GUI() && EditAttribute($cfg,'',$cfg_type) || return;
    $cfgs->append($cfg);
    $dbi_config->save();
    $id = $cfg->{id};
  } else {
    $cfg = first { $_->{id} eq $id } ListV($cfgs);
    die "Didn't find configuration '$id'" unless $cfg;
  }
  unless (defined($cfg->{username}) and defined($cfg->{password})) {
    if (GUI()) {
       EditAttribute($cfg,'',$cfg_type,'password') || return;
    } else {
      die "The configuration $id does not specify username or password\n";
    }
    $dbi_config->save();
  }
  $dbi_configuration = $cfg;
  require Sys::SigAction;
  import Sys::SigAction qw( set_sig_handler );
  # this is taken from http://search.cpan.org/~lbaxter/Sys-SigAction/dbd-oracle-timeout.POD
  eval {
    #note that if you ask for safe, it will not work...
    my $h = set_sig_handler( 'ALRM',
			     sub {
			       die "timed out connecting to database on $cfg->{host}\n";
			     },
			     { flags=>0 ,safe=>0 } );
    alarm(10);
    if ($cfg->{driver} eq 'Pg') {
      require DBD::Pg;
      import DBD::Pg qw(:async);
    }
    $dbi = DBI->connect('dbi:'.$cfg->{driver}.':'.
			  ($cfg->{driver} eq 'Oracle' ? "sid=" : "database=").$cfg->{database}.';'.
			    "host=".$cfg->{host}.';'.
			      "port=".$cfg->{port},
			$cfg->{username},
			$cfg->{password},
			{ RaiseError => 1,
			  (($cfg->{driver} eq 'Pg') ? (AutoCommit=>0) : ())
			}
		       );
    alarm(0);
    die "Connection failed" if not $dbi;
  };
  alarm(0);
  if ($@) {
    ErrorMessage($@);
    if ($@ =~ /timed out/) {
      return;
    }
    GUI() && EditAttribute($cfg,'',$cfg_type,'password') || return;
    $dbi_config->save();
    return connect_dbi($id);
  }
  return $dbi;
}


our @last_query_nodes;
sub query_sql {
  shift unless ref($_[0]); # shift-away package name
  my $opts = shift;
  $opts||={};
  my $xml = $opts->{xml};

  unless ($dbi) {
    connect_dbi()||die "Connection to DBI failed\n";
  }
  my ($limit,$timeout) = map { int($opts->{$_}||$dbi_config->get_root->get_member($_)) } qw(limit timeout);
  $limit||=$DEFAULT_LIMIT;
  $timeout||=$DEFAULT_TIMEOUT;
  my $driver_name = $dbi->{Driver}->{Name};
  my $tree = $opts->{root}||$root;
  my $sql = serialize_conditions($tree,{%$opts,syntax=>$driver_name,limit=>$limit});

  #  my @text_opt = eval { require Tk::CodeText; } ? (qw(CodeText -syntax SQL)) : qw(Text);
  if (GUI()) {
    $sql = EditBoxQuery(
      "SQL Query",
      $sql,
      qq{Confirm or Edit the generated SQL Query (results limit: $limit, timeout $timeout)},
      #    { -widget => \@text_opt },
     );
  }
  if (defined $sql and length $sql) {
    print qq(\n<query-result query.rf="$root->{id}" nodes=").$root->descendants.qq(" driver="$driver_name">\n<sql>\n<![CDATA[$sql]]></sql>\n) if $xml;
    STDOUT->flush;
    my $t0 = new Benchmark;
    my $results = eval { run_query($sql,{ MaxRows=>$limit, RaiseError=>1, Timeout => $timeout }) };
    if ($@) {
      if (GUI()) {
	ErrorMessage($@);
	return;
      } elsif ($xml) {
	print qq(  <error><![CDATA[\n);
	print $@;
	print qq(]]></error>\n);
	print qq(</query>\n);
      } else {
	my $err = $@;
	$err=~s/\n/ /g;
	if ($err =~ /^Query evaluation takes too long:/) {
	  print "$root->{id}\tTIMEOUT\t".($timeout)."s\n";
	} else {
	  print "$root->{id}\tFAIL\t$err\n";
	}
      }
      return;
    }
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    my $no_results = $opts->{count} ? $results->[0][0]  : scalar(@$results);
    if ($xml) {
      print qq(  <ok query.rf="$root->{id}" returned_rows="$no_results" time=").$time.qq("/>\n) if $xml;
      print qq(</query-result>\n) if $xml;
    } else {
      my $driver_name = $dbi->{Driver}->{Name};
      print "$root->{id}\tOK\t$driver_name\t$no_results\t$time\n";
    }
    if (GUI()) {
#      my $sel = [];
#       if (ListQuery("Results",
# 		    'browse',
# 		    [map { join '/',@$_ } @$results],
# 		    $sel,
# 		    {buttons=>[qw(Ok)]})) {
      my $matches = @$results;
      if ($matches) {
	return $results unless QuestionQuery('Results',
					     ((defined($limit) and $matches==$limit) ? '>=' : '').
					       $matches.' match'.($matches>1?'(es)':''),
					     'Display','Cancel') eq 'Display';
	my $treebase_sources = $dbi_configuration->{sources};
	unless (defined($treebase_sources) and
		  length($treebase_sources)) {
	  EditAttribute($dbi_configuration,'sources',
			$dbi_config->schema->
			  find_type_by_path('/configurations/[1]'),
		       ) || return;
	  $dbi_config->save();
	  $treebase_sources = $dbi_configuration->{sources};
	}
	if ($treebase_sources) {
	  #IOBackend::register_input_protocol_handler(pmltq=>\&pmltq_protocol_handler);
	  @last_query_nodes = get_query_nodes($tree);
	  my @wins = TrEdWindows();
	  my $res_win;
	  if (@wins>1) {
	    ($res_win) = grep { 
	      my $f = GetCurrentFileList($_);
	      ($f and $f->name eq __PACKAGE__)
	    } @wins;
	    unless ($res_win) {
	      ($res_win) = grep { $_ ne $grp } @wins;
	    }
	  } else {
	    $res_win = SplitWindowVertically();
	  }
	  {
	    my $fl = Filelist->new(__PACKAGE__);
	    my @files = map {
	      'pmltq://'.join('/',@$_)
		#		my @pos=@$_;
		#		my ($first) = idx_to_pos([$pos[0],$pos[1]]);
		#		(defined $first and length $first) ?
		# ('pmltq://'.$treebase_sources.'/'.$first) : ()
	    } @$results;
	    $fl->add(0, @files);

	    my @context=($this,$root,$grp);
	    #SetCurrentWindow($res_win);
	    CloseFileInWindow($res_win);
	    $grp=$res_win;
	    SetCurrentStylesheet(STYLESHEET_FROM_FILE);
	    AddNewFileList($fl);
	    SetCurrentFileList($fl->name);
	    GotoFileNo(0);
	    ($this,$root,$grp)=@context;
	    # SetCurrentWindow($grp);
	    current_node_change_hook($this,undef);
	  }
	}
      } else {
	QuestionQuery('Results','No results','OK');
      }
    }
    return $results;
  }
}


our @last_results;
our %is_match;
our $btred_results;
sub map_results {
  my ($tree)=@_;
  return if $btred_results;
  $tree||=$root;
  %is_match=();
  return unless @last_results;
  my $treebase_sources = $dbi_configuration->{sources};
  my $fn = FileName();
  return unless $fn=~s{^$treebase_sources/}{};
  $fn.='##'.(CurrentTreeNumber()+1);
  eval {
    my @nodes = ($tree,$tree->descendants);
    my @matches = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () } @last_results;
    for my $node (@nodes[@matches]) {
      $is_match{$node}=1;
    }
  };
  warn $@ if $@;
}

sub next_match {
  my $dir=shift;
  my $prev_grp = $grp;
  my @save = ($this,$root,$grp);
  for my $win (TrEdWindows()) {
    my $fl = GetCurrentFileList($win);
    if ($fl and $fl->name eq __PACKAGE__) {
      eval {
	if ($dir eq 'backward') {
	  $grp=$win;
	  PrevFile();
	} elsif ($dir eq 'forward') {
	  $grp=$win;
	  NextFile()
	} elsif ($dir eq 'this') {
	  my $idx = Index(\@last_query_nodes,$this);
	  print "idx:$idx\n";
	  if (defined($idx)) {
	    $grp=$win;
	    my $treebase_sources = $dbi_configuration->{sources};
	    print $treebase_sources.'/'.$last_results[$idx],"\n";
	    Open($treebase_sources.'/'.$last_results[$idx]);
	    Redraw($win);
	  }
	}
      };
      ($this,$root,$grp)=@save;
      current_node_change_hook($this,undef);
      die $@ if $@;
      return;
    }
  }
  return;
}

sub current_node_change_hook {
  my ($node,$prev)=@_;
  my $idx = Index(\@last_query_nodes,$node);
  return if !defined($idx);
  my $result = $last_results[$idx];
  my $treebase_sources = $dbi_configuration->{sources};
  foreach my $win (TrEdWindows()) {
    my $fsfile = $win->{FSFile};
    next unless $fsfile;
    my $fn = $fsfile->filename.'##'.($win->{treeNo}+1);
    next unless ($treebase_sources.'/'.$result) =~ /\Q$fn\E\.(\d+)$/;
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


sub open_pmltq {
  my ($filename,$opts)=@_;
  return unless $filename=~s{pmltq://}{};
  $btred_results=0;
  @last_results = idx_to_pos([split m{/}, $filename]);
  my ($node) = map { CurrentNodeInOtherWindow($_) } grep { CurrentContextForWindow($_) eq __PACKAGE__ } TrEdWindows();
  my $idx = Index(\@last_query_nodes,$node);
  my $first = $last_results[$idx||0];
  if (defined $first and length $first) {
    my $treebase_sources = $dbi_configuration->{sources};
    $opts->{-norecent}=1;
    my $fsfile = Open($treebase_sources.'/'.$first,$opts);
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

BEGIN {
  register_open_file_hook(\&open_pmltq);
}

sub pmltq_protocol_handler {
  my ($url)=@_;
  return if $url =~ '\.lock$';
  $url=~s{^pmltq://}{} || die "not a pmltq:// URI";
  my ($first) = idx_to_pos([split m{/}, $url]);
  if (defined $first and length $first) {
    my $treebase_sources = $dbi_configuration->{sources};
    return ($treebase_sources.'/'.$first,0);
  }
  return;
}

sub idx_to_pos {
  my $idx_list=shift;
  my @res;
  my @list=@$idx_list;
  while (@list) {
    my ($idx,$type)=(shift@list, shift@list);
    my $result = run_query(qq(SELECT "file", "sent_num", "pos" FROM ${type}_pos WHERE "idx" = $idx ).limit(1),
			   { MaxRows=>1, RaiseError=>1 });
    $result = $result->[0];
    push @res, $result->[0].'##'.$result->[1].'.'.$result->[2];
  }
  return @res;
}

sub run_query {
  my ($sql, $opts)=@_;
#  my $do_profile = eval { require DBI::Profile };
#   if ($do_profile) {
#     $dbi->{Profile} = DBI::Profile->new();
#     $dbi->{Profile}->{Data} = undef;
#   }
  local $dbi->{RaiseError} = $opts->{RaiseError};
  require Time::HiRes;
  my $canceled = 0;
  my $driver_name = $dbi->{Driver}->{Name};
  my $sth;
  if ($driver_name eq 'Pg') {
    $sth = $dbi->prepare( $sql, { pg_async => 1 } );
    my $step=0.05;
    my $time=0;
    eval {
      $sth->execute();
      if (defined $opts->{Timeout}) {
	while (!$sth->pg_ready) {
#	do {{
	  $time+=$step;
	  Time::HiRes::sleep($step);
	  if ($time>=$opts->{Timeout}) {
	    if (!GUI() or QuestionQuery('Query Timeout',
					'The evaluation of the query seems to take too long',
					'Wait another '.$opts->{Timeout}.' seconds','Abort') eq 'Abort') {
	      $sth->pg_cancel();
	      die "Query evaluation takes too long: cancelled.\n"
	    } else {
	      $time=0;
	    }
	  }
#	}} while (!$sth->pg_ready);
	}
      }
      $sth->pg_result;
    };
    if ($@) {
      $dbi->rollback();
      die $@;
    }
  } else {
    $sth = $dbi->prepare( $sql );
    eval {
      if (defined $opts->{Timeout}) {
	my $h = set_sig_handler( 'ALRM',
				 sub {
				   if (!GUI() or QuestionQuery('Query Timeout',
						     'The evaluation of the query seems to take too long',
						     'Wait another '.$opts->{Timeout}.' seconds','Abort') eq 'Abort') {
				     $canceled = 1;
				     my $res = $sth->cancel();
				     warn "Canceled: ".(defined($res) ? $res : 'undef');
				   } else {
				     alarm($opts->{Timeout});
				   }
				 }, #dont die (oracle spills its guts)
				 { mask=>[ qw( INT ALRM ) ] ,safe => 0 }
				);
	alarm($opts->{Timeout});
	$sth->execute();
	alarm(0);
      } else {
	$sth->execute();
      }
    };
    alarm(0);
    if ( $@ ) {
      $dbi->rollback();
      if ($canceled) {
	die "Query evaluation takes too long: cancelled."
      } else {
	die $@;
      }
    }
  }
#   if ($do_profile) {
#     print STDERR $dbi->{Profile}->format;
#   }
  return $sth->fetchall_arrayref(undef,$opts->{MaxRows});
}

use constant {
  SUB_QUERY => 1,
  GROUP    => 2,
};

my $occurrences_strategy = SUB_QUERY;
# serialize to SQL (or SQL fragment)
sub serialize_conditions {
  my ($node,$opts)=@_;
  $opts||={};
  if ($node->parent) {
    my $el = serialize_element({
      %$opts,
      name => 'and',
      condition => $node->{conditions},
    });
    my @sql;
    push @sql,[$el,$node] if defined($el) and length($el);
    if ($occurrences_strategy == SUB_QUERY) {
      my @occ_child = grep { length($_->{occurrences}) } $node->children;
      for my $child (@occ_child) {
	my $occ = $child->{occurrences};
	my $subquery = make_sql($child,{
	  count=>1,
	  parent_id=>$opts->{id},
	  join => $opts->{join},
	  syntax=>$opts->{syntax},
	});
	push @sql,[qq{ $occ=($subquery)},$child];
      }
    }
    return wantarray ? @sql : join(' AND ',map { $_->[0] } @sql);
  } else {
    init_id_map($root);
    return make_sql($root,{
      count=>$opts->{count},
      limit => $opts->{limit},
      syntax=>$opts->{syntax},
    });
  }
}
sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  init_id_map($tree);
  return make_sql($tree,{format=>1});
}

sub line_click_hook {
  my ($node,$tag,$button, $double,$modif, $ev)=@_;
  if ($node and $double and $button eq '1' and !$modif) {
    if ($tag eq 'relation') {
      EditAttribute($node,'relation');
      Redraw();
    } elsif ($tag eq 'extra_relation') {
      EditAttribute($node,'extra-relations');
      Redraw();
    }
  }
}

sub relation {
  my ($n,$opts)=@_;
  my ($id,$parent_id)=@$opts{qw(id parent_id)};
  my ($rel) = SeqV($n->{relation});
  my $name = $rel ? $rel->name : 'parent';
  my $condition;
  if ($name eq 'parent') {
    $condition= qq{$id."parent_idx"=$parent_id."idx"};
  } elsif ($name eq 'ancestor') {
    $condition= extra_relation($parent_id,$rel,$id,$opts);
  } elsif ($name eq 'user-defined') {
    $condition= user_defined_relation($id,$rel->value,$parent_id,$opts);
  }
  if ($n->{optional}) {
    # identify with parent
    if (length($condition)) {
      $condition = qq{(($condition) OR $id."idx"=$parent_id."idx")};
    }
  }
  return $condition;
}

sub extra_relation {
  my ($id,$rel,$target,$opts)=@_;
  my $relation = $rel->name;
  my $params = $rel->value;
  if ($relation eq 'descendant-of') {
    $relation = 'ancestor-of';
    ($id,$target)=($target,$id);
  }
  if ($relation eq 'child-of') {
    $relation = 'parent-of';
    ($id,$target)=($target,$id);
  }

  if ($relation eq 'user-defined') {
    return user_defined_relation($id,$params,$target,{%$opts,extra_relation=>1});
  } elsif ($relation eq 'ancestor' or $relation eq 'ancestor-of' ) {
    my $cond = qq{$id."root_idx"=$target."root_idx" AND $id."idx"!=$target."idx" AND }.
      qq{$target."idx" BETWEEN $id."idx" AND $id."r"};
    my $min = int($params->{min_length});
    my $max = int($params->{max_length});
    if ($min>0 and $max>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl" BETWEEN $min AND $max};
    } elsif ($min>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl">=$min}
    } elsif ($max>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl"<=$max}
    }
    if ($params->{negate}) {
      $cond=qq{NOT($cond)};
    }
    return $cond;
  } elsif ($relation eq 'parent-of') {
    if ($params->{negate}) {
      return qq{$id."idx"!=$target."parent_idx"};
    } else {
      return qq{$id."idx"=$target."parent_idx"};
    }
  } elsif ($relation eq 'depth-first-precedes') {
    return qq{$id."idx"<$target."idx"};
  } elsif ($relation eq 'order-precedes') {
    my $order; # FIXME: get the ordering attribute from the database
    if ($opts->{type} eq 'a') {
      $order = q("ord");
    } else {
      $order = q("tfa/deepord");
    }
    return serialize_expression({
      id=>$id,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => $order
    }).qq(<).serialize_expression({
      id=>$target,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => qq{$target.$order},
    });
  }
}

sub user_defined_relation {
  my ($id,$rel,$target,$opts)=@_;
  my $relation=$rel->{label};
  my $type = $opts->{type};
  my $params = $rel->value;
  my $cond;
  if ($relation eq 'effective_parent') {
    $cond =  qq{$id."root_idx"=$target."root_idx" AND }.
      serialize_expression({
	id=>$id,
	type=>$type,
	join=>$opts->{join},
	expression => qq{"eparents/eparent_idx"}
       }).qq{=$target."idx" };
  } elsif ($relation eq 'a/lex.rf') {
    unless ($opts->{extra_relation}) {
      # reverse
      ($id,$target)=($target,$id);
    }
    $cond =  qq{$id."a_lex_idx"=$target."idx"}
  } elsif ($relation eq 'a/aux.rf') {
    unless ($opts->{extra_relation}) {
      # reverse
      ($id,$target,$type)=($target,$id,$opts->{parent_type});
    }
    $cond =  serialize_expression({
      id=>$id,
      type=>$type,
      join=>$opts->{join},
      expression => qq{"a_aux/a_idx"},
    }).qq(=$target."idx");
  } elsif ($relation eq 'a/lex.rf|a/aux.rf') {
    unless ($opts->{extra_relation}) {
      # reverse
      ($id,$target,$type)=($target,$id,$opts->{parent_type});
    }
    $cond = 
      qq{($id."a_lex_idx"=$target."idx" OR }.
      serialize_expression({
      id=>$id,
      type=>$type,
      join=>$opts->{join},
      expression => qq{"a_aux/a_idx"},
    }).qq{=$target."idx")};
  } elsif ($relation eq 'coref_gram') {
    $cond = 
      serialize_expression({
      id=>$id,
      type=>$type,
      join=>$opts->{join},
      expression => qq{"coref_gram/corg_idx"}
     }).qq{=$target."idx"};
  } elsif ($relation eq 'coref_text') {
    $cond = 
      serialize_expression({
      id=>$id,
      type=>$type,
      join=>$opts->{join},
      expression => qq{"coref_text/cort_idx"}
     }).qq{=$target."idx"};
  }
  if ($params->{negate}) {
    $cond=qq{NOT($cond)};
  }
  return $cond;
}

sub get_query_nodes {
  my ($tree)=@_;
  my @nodes;
  if ($occurrences_strategy == SUB_QUERY) {
    my $n = $tree;
    while ($n) {
      if ($n->parent) {
	if (length($n->{occurrences}) and $n!=$tree) {
	  $n = $n->following_right_or_up($tree);
	  next;
	} else {
	  push @nodes, $n;
	}
      }
      $n = $n->following($tree);
    }
  } else {
    @nodes =  grep { $_->parent }  ($tree, $tree->descendants);
  }
  return @nodes;
}

sub make_sql {
  my ($tree,$opts)=@_;
  $opts||={};
  my ($format,$count,$tree_parent_id) = 
    map {$opts->{$_}} qw(format count parent_id limit);
  # we rely on depth first order!
  my @nodes = get_query_nodes($tree);
  my @select;
  my @table;
  my @where;
  my %conditions;
  my $extra_joins = $opts->{join} || {};
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $table = $n->{'node-type'}||$tree->{'node-type'}||'a';
    my $id = $id{$n};
    push @select, $id;
    my $parent = $n->parent;
    my $parent_id = $id{$parent};
    $conditions{$id} =
      join(' AND ',
	   sort grep { defined and length }
	     (
	       scalar(serialize_conditions($n,{
		 type=>$table,
		 id=>'___SELF___',
		 parent_id=>$parent_id,
		})),
	       map { extra_relation('___SELF___',$_,$_->value->{target},{type=>$table}) } SeqV($n->attr('extra-relations'))
	      ));
    my @conditions;
    if ($parent->parent) {
      my $condition=q();
      $condition.=relation($n,{%$opts,
			       id=>$id,
			       type => $table,
			       parent_id=>$parent_id,
			       parent_type=>($n->parent->{'node-type'}||$tree->{'node-type'}),
			       join => $extra_joins,
			      });
      push @table,[$table,$id,$n,$condition];
      push @conditions,
	(map { [qq{$id{$_}."idx"}.
		  ($conditions{$id} eq $conditions{$id{$_}} ? '<' : '!=' ).
		    qq{${id}."idx"},$n] }
	   grep { #$_->parent == $n->parent
	     #  or
	     my $type=$_->{'node-type'}||$tree->{'node-type'}||'a';
	     $type eq $table and
	       (first { !$_->{optional} } $_->ancestors)==(first { !$_->{optional} } $n->ancestors)
	     }
	     map { $nodes[$_] } 0..($i-1));
    } else {
      push @table,[$table,$id,$n];
    }
    push @conditions,
    serialize_conditions($n,{
      type=>$table,
      id=>$id,
      parent_id=>$parent_id,
      join => $extra_joins,
      syntax=>$opts->{syntax},
    });
    # where could also be obtained by replacing ___SELF___ with $id
    if ($n->{optional}) {
      # identify with parent
      if (@conditions) {
	@conditions = ([ ['((',$n], AND_Group(@conditions), [qq{) OR $id."idx"=$parent_id."idx")},$n] ]);
      }
    }
    for my $rel (SeqV($n->attr('extra-relations'))) {
      push @conditions,['('.extra_relation($id,$rel,$rel->value->{target},{type=>$table,join => $extra_joins,syntax=>$opts->{syntax}}).')',$n];
    }
    push @where, @conditions;
  }
  my @sql = (['SELECT ']);
  if ($count) {
    push @sql,['count(1)','space'];
  } else {
    push @sql, (['DISTINCT '], map {
      my $n = $nodes[$_];
      (($_==0 ? () : [', ','space']),
       [$select[$_].'."idx"',$n],
       [' AS "'.$select[$_].'.idx"',$n],
       [q(, ').($nodes[$_]->{'node-type'}||$tree->{'node-type'}||'a').q('),$n],
       [' AS "'.$select[$_].'.type"',$n]
      )
    } 0..$#nodes);
  }
  # joins
  my @WHERE;
  {
    my $i=0;
    for my $t (@table) {
      my ($tab, $name, $node, $condition)=@$t;
      push @sql, ($i++)==0 ? ["\nFROM\n  ",'space'] : [",\n  ",'space'];
      push @sql, ["$tab $name",$node];
      if ($extra_joins->{$name}) {
	for my $join_as (sort { length($a)<=>length($b) } keys %{$extra_joins->{$name}}) {
	  my ($join_tab,$join_on,$join_type)=@{$extra_joins->{$name}{$join_as}};
	  $join_type||='';
	  push @sql, [' ','space'], [qq($join_type JOIN $join_tab $join_as ON $join_on),$node]
	}
      }
      push @WHERE, [$condition,$node] if defined($condition) and $condition=~/\S/;
    }
  }
  push @sql, [ "\nWHERE\n     ",'space'],AND_Group(@WHERE,@where);
  unless (defined($tree_parent_id) and defined($id{$tree}) 
	  or !defined($opts->{limit})) {
    push @sql, ["\n".limit($opts->{limit})."\n",'space']
  }
  if ($format) {
    return \@sql;
  } else {
    return join '',map { $_->[0] } @sql;
  }
}

sub AND_Group {
  my @res = (map {(ref($_) and ref($_->[0])) ? @$_ : $_ } 
	     map { ($_, ["\n AND ",'space']) } @_);
  pop @res; # pop the last AND
  return @res;
}

sub serialize_expression {
  my ($opts)=@_;
  my $parent_id = $opts->{parent_id};
  my $exp = $opts->{expression};
  for ($exp) {
    s/(?:(\w+)\.)?"_[#]descendants"/$1"r"-$1"idx"/g;
    s/"_[#]lbrothers"/"chord"/g;
    s/(?:(\w+)\.)?"_[#]rbrothers"/$1$parent_id."chld"-$1"chord"-1/g;
    s/"_[#]sons"/"chld"/g;
    s/"_depth"/"lvl"/g;
  }
  $exp=~s{(?:(\w+)\.)?"([^"]+)"}{
    my $id = defined($1) ? lc($1) : $opts->{id};
    my @ref = split m{/}, $2;
    my $column = pop @ref;
    my $table = $opts->{type};
    my $node_id = $id;
    for my $tab (@ref) {
      my $prev = $id;
      $id.="_$tab";
      $table.="_$tab";
      $opts->{join}{$node_id}{$id}=[$table => qq($id."idx" = $prev."idx"), 'LEFT'];# should be qq($prev."$tab")
    }
    qq($id."$column");
  }ge;
  return $exp;
}

sub serialize_element {
  my ($opts)=@_;
  my ($name,$value,$as_id,$parent_as_id)=map {$opts->{$_}} qw(name condition id parent_id);
  if ($name eq 'test') {
    my $left = serialize_expression({%$opts,expression=>$value->{a}});
    my $right = serialize_expression({%$opts,expression=>$value->{b}});
    my $operator = $value->{operator};
    if ($operator eq '~' and $opts->{syntax} eq 'Oracle') {
      return ($value->{negate}==1 ? 'NOT ' : '').qq{REGEXP_LIKE($left,$right)};
    } else {
      return ($value->{negate}==1 ? 'NOT ' : '').
	($left.' '.uc($operator).' '.$right);
    }
  } elsif ($name =~ /^(?:and|or)$/) {
   my $seq = $value->{'#content'};
   return () unless (
     UNIVERSAL::isa( $seq, 'Fslib::Seq') and
     @$seq
   );
   my $condition = join(' '.uc($name).' ',
			grep { defined and length }
			map {
			  my $n = $_->name;
			  serialize_element({
			    %$opts,
			    name => $n,
			    condition => $_->value,
			    id => $as_id,
			    parent_id => $parent_as_id,
			   }) } $seq->elements);
   return () unless length $condition;
   return ($value->{negate} ? "NOT ($condition)" :
	   @$seq > 1 ? "($condition)" : $condition);
  } else {
    warn "Unknown element $name ";
  }
}

# serialize to stylesheet
sub serialize_conditions_as_stylesheet {
  my ($node)=@_;
  if ($node->parent) {
    return serialize_element_as_stylesheet( $node, 'conditions', 'and', $node->{conditions} );
  } else {
    return;
  }
}

sub serialize_element_as_stylesheet {
  my ($node,$path,$name,$value)=@_;
  if ($name eq 'test') {
    return ($value->{negate} ? "#{darkred(}\${$path/negate=NOT}#{)} " : '').
           (
	     "\${$path/a=".$value->{a}."} ".
	     "#{darkblue(}\${$path/operator=".uc($value->{operator})."}#{)} ".
	     "\${$path/b=".$value->{b}."} "
	   );
  } elsif ($name =~ /^(?:and|or)$/) {
   my $seq = $value->{'#content'};
   return () unless (
     UNIVERSAL::isa( $seq, 'Fslib::Seq') and
     @$seq
   );
   my $i=1;
   return ($value->{negate} ? "#{darkred(}\${$path/negate=NOT}#{)} " : '').
         "#{darkviolet(}\${$path=(}#{)}".
       	  join(' #{darkviolet(}${'.$path.'/#content='.uc($name).'}#{)} ',map {
	    my $n = $_->name;
	    serialize_element_as_stylesheet($node,
			      $path.'/#content/['.($i++).']'.$n,
			      $n,
			      $_->value) } $seq->elements
	  ).
	  "#{darkviolet(}\${$path=)}#{)}";
  }
}

sub fix_netgraph_ord_to_precedes {
  my ($node,$group) = @_;
  if (ref($group)) {
    my $seq = $group->{'#content'};
    if (ref($seq)) {
      my $elements_list=$seq->elements_list;
      @$elements_list = map {
	my @res=($_);
	if ($_->name eq 'test') {
	  my $val = $_->value;
          if ($val->{operator}=~/[<>]/) {
	    my ($x,$y)=($val->{a},$val->{b});
	    if ($val->{operator} =~/>/) {
	      ($x,$y)=($y,$x);
	    }
	    # we now assume $x < $y (we ignore the = in $x <= $y)
	    my ($start,$end);
	    my $ord = (($node->{'node-type'}||$node->root->{'node-type'}) eq 't') ? 'tfa/deepord' : 'ord';
	    if ($x eq qq("$ord") and $y=~/^([[:alnum:]]+)\."\Q$ord\E"$/) {
	      $end = $name2node_hash{lc($1)};
	      $start=$node;
	    } elsif ($y eq qq("$ord") and $x=~/^([[:alnum:]]+)\."\Q$ord\E"$/) {
	      $start=$name2node_hash{lc($1)};
	      $end=$node;
	    }
	    if ($start && $end) {
	      AddOrRemoveRelations($start,$end,['order-precedes'],{-add_only=>1});
	      @res=(); # remove the element
	      ChangingFile(1);
	    }
	  }
	} elsif ($_->name =~ /^(?:and|or)$/) {
	  fix_netgraph_ord_to_precedes($node,$_->value);
	}
	@res;
      } @$elements_list;
    }
  }
  return $group;
}

sub fix_tecto_coap {
  my ($node,$group) = @_;
  if (ref($group)) {
    my $seq = $group->{'#content'};
    if (ref($seq)) {
      my $elements_list=$seq->elements_list;
      @$elements_list = map {
	my @res=($_);
	if ($_->name eq 'test') {
	  my $val = $_->value;
	  if ($val->{operator} eq 'in'
		and $val->{a} eq q("functor")) {
	    my $y = $val->{b};
	    $y=~s/\s//g;
	    $y=~s/^\(|\)$//g;
	    if (join(',',uniq sort split(/,/,$y)) eq q('ADVS','APPS','CONFR','CONJ','CONTRA','CSQ','DISJ','GRAD','OPER','REAS')) {
	      $val->{a} = q("nodetype");
	      $val->{b} = q('coap');
	      $val->{operator} = '=';
	      ChangingFile(1);
	    }
	  }
	} elsif ($_->name =~ /^(?:and|or)$/) {
	  fix_tecto_coap($node,$_->value);
	}
	@res;
      } @$elements_list;
    }
  }
  return $group;
}

sub fix_or2in {
  my ($node,$group) = @_;
  if (ref($group)) {
    my $seq = $group->{'#content'};
    if (ref($seq)) {
      my $elements_list=$seq->elements_list;
      @$elements_list = map {
	my $el = $_;
	my @res=($el);
	my $name = $el->name;
	if ($name eq 'or' or $name eq 'and') {
	  my $or = $el->value->{'#content'};
	  if (ref($or)) {
	    my $tests=$or->elements_list;
	    if (@$tests>3
		and !(first { !($_->name eq 'test' and $_->value ->{operator} eq '=') } @$tests) # all are tests with =
		and !($name eq 'and' and first { !($_->value->{negate}) } @$tests)            # all have the same a
		and !(first { !($_->value->{a} eq $tests->[0]->value->{a}) } @$tests)            # all have the same a
	       ) { 
	      ChangingFile(1);
	      @res = (
		Fslib::Seq::Element->new(
		  'test',
		  Fslib::Struct->new({
		    negate => $name eq 'or' ? $el->value->{negate} : !$el->value->{negate},
		    a => $tests->[0]->value->{a},
		    operator => 'in',
		    b => '('.join(',', sort map { $_->value->{b} } @$tests) .')',
		  },1)
		)
	      );
	    } else {
	      fix_or2in($node,$el->value);
	    }
	  }
	}
	@res;
      } @$elements_list;
    }
  }
  return $group;
}


sub __serialize_node {
  my ($n)=@_;
  my $type=$n->{'node-type'} || $n->root->{'node-type'};
  return join(' AND ',
       sort grep { defined and length }
	 (
	   scalar(serialize_conditions($n,{
	     type=>$type,
	     id=>'___SELF___',
	     parent_id=>'___PARENT___',
	   })),
	   map { extra_relation('___SELF___', $_,$_->value->{target},{type=>$type}) } SeqV($n->attr('extra-relations'))
	  ));
}

sub __test_optional_chain {
  my ($node)=@_;
  return unless $node;
  my $son = $node->firstson;
  return (
    $son
    and (!$son->rbrother)
    and ($son->children<=1)
    and (!$son->{relation} or $son->{relation}->name_at(0) eq 'parent')
    and !(defined($node->{occurrences}) and length($node->{occurrences}))
    and (!$node->{relation} or $node->{relation}->name_at(0) eq 'parent')
  )
  ? 1 : 0;
}

sub reduce_optional_node_chain {
  my ($node)=@_;
  my $parent = $node->parent;
  return unless $parent and $parent->parent;
  my $conditions = __serialize_node($node);
  my $last = $node;
  my $max_length=0;
  my $min_length=0;
  while (__test_optional_chain($last) and ($last==$node or $conditions eq __serialize_node($last))) {
    $max_length++;
    $min_length++ unless $last->{optional};
    $last=$last->firstson;
  }
  if ($max_length>1) {
    ChangingFile(1);
    # trim the chain between $node and $last
    my $son = $node->firstson;
    CutPasteAfter($last,$node);
    DeleteSubtree($son);
    AddOrRemoveRelations($node,$last,['ancestor'],{
      -add_only=>1
    });
    AddOrRemoveRelations($node,undef,['ancestor'],{
      -attribute=>'relation',
      -add_only=>0
    });
    $node->{occurrences}=0;
    $node->{optional}=0;
    $node->set_attr('conditions/negate',!$node->attr('conditions/negate'));
    my ($rel) = AddOrRemoveRelations($last,undef,['ancestor'],{
      -attribute=>'relation',
      -add_only=>0,
    });
    $rel->value->{min_length}=$min_length if $min_length;
    $rel->value->{max_length}=$max_length;
  }
}

sub fix_netgraph_query {
  init_id_map($root);
  ChangingFile(0);
  {
    my $node = $root;
    while ($node) {
      fix_or2in($node,$node->{conditions});
      $node=$node->following;
    }
  }
  {
    my $node = $root;
    while ($node) {
      fix_tecto_coap($node,$node->{conditions});
      $node=$node->following;
    }
  }
  {
    my $node = $root;
    while ($node) {
      reduce_optional_node_chain($node);
      $node=$node->following;
    }
  }
  {
    my $node = $root;
    while ($node) {
      fix_netgraph_ord_to_precedes($node,$node->{conditions});
      $node=$node->following;
    }
  }
}


my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
$default_dbi_config = <<"EOF";
<dbi xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema>
      <pml_schema 
	  xmlns="http://ufal.mff.cuni.cz/pdt/pml/schema/" version="1.1">
        <revision>1.1</revision>
	<root name="dbi">
	  <structure>
	    <member name="limit"><cdata format="nonNegativeInteger"/></member>
	    <member name="timeout"><cdata format="nonNegativeInteger"/></member>
	    <member name="configurations">
	      <list ordered="1" type="dbi-config.type"/>
	    </member>
	  </structure>
	</root>
	<type name="dbi-config.type">
	  <structure>
	    <member name="id" role="#ID" required="1" as_attribute="1"><cdata format="ID"/></member>
	    <member name="driver"><cdata format="NMTOKEN"/></member>
	    <member name="host"><cdata format="url"/></member>
	    <member name="port"><cdata format="integer"/></member>
	    <member name="database"><cdata format="NMTOKEN"/></member>
	    <member name="username"><cdata format="NMTOKEN"/></member>
	    <member name="password"><cdata format="any"/></member>
	    <member name="sources"><cdata format="anyURI"/></member>
	  </structure>
	</type>
      </pml_schema>
    </schema>
  </head>
  <limit>$DEFAULT_LIMIT</limit>
  <timeout>$DEFAULT_TIMEOUT</timeout>
  <configurations>
    <LM id="postgress">
      <driver>Pg</driver>
      <host>localhost</host>
      <port>5432</port>
      <database>treebase</database>
      <username>$userlogin</username>
      <password></password>
    </LM>
    <LM id="oracle">
      <driver>Oracle</driver>
      <host>localhost</host>
      <port>1521</port>
      <database>XE</database>
      <username></username>
      <password></password>
    </LM>
  </configurations>
</dbi>
EOF

} # use strict
1;
