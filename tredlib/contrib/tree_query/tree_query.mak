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

Bind sub { query_sql({limit=>100, timeout=>150}) } => {
  key => 'space',
  menu => 'Query SQL server',
  changing_file => 0,
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
  menu => 'Connect to SQL server',
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
rootstyle: #{vertical:0}
node: <? length $${occurrences} ? ($${occurrences}."x")  : "" 
?><? $${optional} ? '?'  : q()
?><? Tree_Query::serialize_conditions_as_stylesheet($this) ?>
node: <?length($${type}) ? $${type}.': ' : '' ?>#{darkblue}${name}#{brown}${description}
style: <? 
  my $rel = $${relation};
  $rel eq 'ancestor' ? "#{Line-dash:_}#{Line-fill:blue}" :
  $rel eq 'effective_parent' ? "#{Line-dash:_}#{Line-fill:green}" :
  $rel eq 'a/lex.rf' ? "#{Line-fill:violet}" :
  $rel eq 'a/aux.rf' ? "#{Line-dash:_}#{Line-fill:violet}" :
  $rel eq 'a/lex.rf|a/aux.rf' ? "#{Line-dash:.}#{Line-fill:violet}" :
  q()
?>
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
  'deepord-less-than' => '',
  'a/lex.rf' => 'violet',
  'a/lex.rf|a/aux.rf' => 'violet',
  'a/aux.rf' => 'violet',
  coref_text => '#4C509F',
  coref_gram => '#C05633',
);
my %dash = (
  'depth-first-precedes' => '',
  'deepord-less-than' => '',
  'a/lex.rf' => '',
  'a/lex.rf|a/aux.rf' => '.',
  'a/aux.rf' => '_',
  coref_text => '',
  coref_gram => '',
);
sub node_style_hook {
  my ($node,$styles) = @_;
  my $i=0;
  DrawArrows($node,$styles,
	     [
	       map {
		 scalar {
		   -target => $name2node_hash{lc($_->{target})},
		   -fill   => $color{$_->{relation}},
		   -dash   => $dash{$_->{relation}},
		   -raise => 8+8*(++$i),
		 }
	       } ListV($node->attr('extra-relations'))
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
    my @sel = map { $_->{relation} } ListV($node->attr('extra-relations'));
    ListQuery('Select treebase connection',
	      'browse',
	      [$node->type->schema->get_type_by_name('q-extra-relation.type')->get_content_decl->get_values()],
	      \@sel) || return;
    init_id_map($node->root);
    for my $s (@sel) {
      AddOrRemoveRelation($node,$target,$s);
    }
    TredMacro::Redraw_FSFile_Tree();
    ChangingFile(1);
  }
  return;
}

# note: you have to call init_id_map($root); first!
sub AddOrRemoveRelation {
  my ($node,$target,$type)=@_;
  if (!defined($target->{name})) {
    my $i=0;
    $i++ while (exists $name2node_hash{"ref$i"});
    $target->set_attr('name',"ref$i");
  }
  my $relations = $node->attr('extra-relations');
  if (first { lc($target->{name}) eq $_->{target} and $type eq $_->{relation} } ListV($relations)) {
    @{$relations} = grep { lc($target->{name}) ne $_->{target} and $type eq $_->{relation} } ListV($relations);
  }else{
    AddToList($node,'extra-relations',
	      Fslib::Struct->new({
		target => lc($target->{name}),
		relation => $type,
	       },1)
	     );
  }
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
sub query_sql {
  my $opts = shift;
  $opts||={};
  my $xml = $opts->{xml};
  my $sql = serialize_conditions($opts->{root}||$root,$opts);
  #  my @text_opt = eval { require Tk::CodeText; } ? (qw(CodeText -syntax SQL)) : qw(Text);
  if (GUI()) {
    $sql = EditBoxQuery(
      "SQL Query",
      $sql,
      'Confirm or Edit the generated SQL Query',
      #    { -widget => \@text_opt },
     );
  }
  if (defined $sql and length $sql) {
    unless ($dbi) {
      connect_dbi()||die "Connection to DBI failed\n";
    }
    my $driver_name = $dbi->{Driver}->{Name};
    print qq(\n<query-result query.rf="$root->{id}" nodes=").$root->descendants.qq(" driver="$driver_name">\n<sql>\n<![CDATA[$sql]]></sql>\n) if $xml;
    STDOUT->flush;
    my $t0 = new Benchmark;
    my $results = eval { run_query($sql,{ MaxRows=>$opts->{limit}, RaiseError=>1, Timeout => $opts->{timeout}||30 }) };
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
	  print "$root->{id}\tTIMEOUT\t".($opts->{timeout}||30)."s\n";
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
					     ((defined($opts->{limit}) and $matches==$opts->{limit}) ? '>=' : '').
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
	  my @wins = TrEdWindows();
	  my $res_win;
	  if (@wins>1) {
	    ($res_win) = grep { $_ ne $grp } @wins;
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
	    SetCurrentWindow($res_win);
	    CloseFileInWindow($res_win);
	    SetCurrentStylesheet(STYLESHEET_FROM_FILE);
	    AddNewFileList($fl);
	    SetCurrentFileList($fl->name);
	    GotoFileNo(0);
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
sub map_results {
  my ($tree)=@_;
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
sub open_pmltq {
  my ($filename,$opts)=@_;
  return unless $filename=~s{pmltq://}{};
  @last_results = idx_to_pos([split m{/}, $filename]);
  my $first = $last_results[0];
  if (defined $first and length $first) {
    my $treebase_sources = $dbi_configuration->{sources};
    $opts->{-norecent}=1;
    Open($treebase_sources.'/'.$first,$opts);
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
  local $dbi->{RaiseError} = $opts->{RaiseError};
  my $canceled = 0;
  my $driver_name = $dbi->{Driver}->{Name};
  my $sth;
  if ($driver_name eq 'Pg') {
    $sth = $dbi->prepare( $sql, { pg_async => 1 } );
    my $step=2;
    my $time=0;
    eval {
      $sth->execute();
      if (defined $opts->{Timeout}) {
	do {{
	  $time+=$step;
	  sleep $step;
	  if ($time>=$opts->{Timeout}) {
	    $sth->pg_cancel();
	    die "Query evaluation takes too long: cancelled after $opts->{Timeout} seconds.\n"
	  }
	}} while (!$sth->pg_ready);
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
				   $canceled = 1; 
				   my $res = $sth->cancel();
				   warn "Canceled: ".(defined($res) ? $res : 'undef');
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
	die "Query evaluation takes too long: cancelled after $opts->{Timeout} seconds."
      } else {
	die $@;
      }
    }
  }
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
	});
	push @sql,[qq{ $occ=($subquery)},$child];
      }
    }
    return wantarray ? @sql : join(' AND ',map { $_->[0] } @sql);
  } else {
    init_id_map($root);
    return make_sql($root,{
      count=>$opts->{count},
      limit => $opts->{limit}
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


sub relation {
  my ($n,$opts)=@_;
  my ($id,$parent_id)=@$opts{qw(id parent_id)};
  my $condition;
  if ($n->parent) {
    if ($n->{'relation'} eq 'ancestor') {
      if ($n->parent->parent) {
	$condition = qq{$id."root_idx"=$parent_id."root_idx" AND $id."idx"!=$parent_id."idx" AND }.
	  qq{$id."idx" BETWEEN $parent_id."idx" AND $parent_id."r"};
      }
    } elsif ($n->{'relation'} eq 'effective_parent') {
      $condition = extra_relation($id,'effective_parent',{%$opts,target=>$parent_id});
    } elsif ($n->{'relation'} eq 'parent' or
	       $n->{'relation'} eq '') {
      $condition = qq{$id."parent_idx"=$parent_id."idx"};
    } elsif ($n->{'relation'} eq 'a/lex.rf') {
      $condition = qq{$id."idx"=$parent_id."a_lex_idx"};
    }
    if ($n->{optional}) {
      # identify with parent
      if (length($condition)) {
	$condition = qq{(($condition) OR $id."idx"=$parent_id."idx")};
      }
    }
  }
  return $condition;
}
sub extra_relation {
  my ($id,$rel,$opts)=@_;
  my $target = $rel->{target};
  my $relation = $rel->{relation};
  if ($rel eq 'effective_parent') {
    return qq{$id."root_idx"=n0."root_idx" AND }.
      serialize_expression({
	id=>$id,
	type=>$opts->{type},
	join=>$opts->{join},
	expression => qq{"eparents/idx"}
       }).qq{=$target."idx" };
  } elsif ($relation eq 'depth-first-precedes') {
    return qq{$id."idx"<$target."idx"};
  } elsif ($relation eq 'deepord-less-than') {
    my $order;
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
  } elsif ($relation eq 'a/lex.rf') {
    return qq{$id."a_lex_idx"=$target."idx"}
  } elsif ($relation eq 'a/aux.rf') {
    return serialize_expression({
      id=>$id,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => qq{"a_aux/a_idx"},
    }).qq(=$target."idx");
  } elsif ($relation eq 'a/lex.rf|a/aux.rf') {
    return
      qq{$id."a_lex_idx"=$target."idx" OR }.
      serialize_expression({
      id=>$id,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => qq{"a_aux/a_idx"},
    }).qq(=$target."idx");
  } elsif ($relation eq 'coref_gram') {
    return
      serialize_expression({
      id=>$id,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => qq{"coref_gram/corg_idx"}
     }).qq(=$target."idx");
  } elsif ($relation eq 'coref_text') {
    return
      serialize_expression({
      id=>$id,
      type=>$opts->{type},
      join=>$opts->{join},
      expression => qq{"coref_text/cort_idx"}
     }).qq(=$target."idx");
  } elsif ($relation eq 'ancestor') {
    return qq{$id."root_idx"=$target."root_idx" AND $id."idx"!=$target."idx" AND }.
      qq{$target."idx" BETWEEN $id."idx" AND $id."r"};
  } elsif ($relation eq 'parent') {
    return qq{$id."parent_idx"=$target."idx"};
  }

}
sub make_sql {
  my ($tree,$opts)=@_;
  $opts||={};
  my ($format,$count,$tree_parent_id) = 
    map {$opts->{$_}} qw(format count parent_id limit);
  # we rely on depth first order!
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
  my @select;
  my @table;
  my @where;
  my %conditions;
  my $extra_joins = $opts->{join} || {};
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $table = $n->{type}||$tree->{type}||'a';
    if ($n->{relation} =~ m{^a/}) {
      $table = $n->{type}||'a';
    }
    my $id = $id{$n};
    push @select, $id;
    my $parent = $n->parent;
    my $parent_id = $id{$parent};
    $conditions{$id} = Tree_Query::serialize_conditions($n,{
      type=>$table,
      id=>'___SELF___',
      parent_id=>$parent_id
     });
    if ($n->parent->parent) {
      my $condition=q();
      if ($parent->parent) {
	$condition.=relation($n,{%$opts, id=>$id,parent_id=>$parent_id});
      } else {
	# what do we with _optional here?
	if ($n->parent->parent) {
	  $condition .= qq{$id."root_idx"=n0."root_idx"};
	}
      }
      $condition.=
	join('', (map { qq{ AND $id{$_}."idx"}.
			  ($conditions{$id} eq $conditions{$id{$_}} ? '<' : '!=' ).
			qq{${id}."idx"} }
		    grep { #$_->parent == $n->parent
		      #  or
		      my $type=$_->{type}||$tree->{type}||'a';
		      $type eq $table and
			(first { !$_->{optional} } $_->ancestors)==(first { !$_->{optional} } $n->ancestors)
		      }
		      map { $nodes[$_] } 0..($i-1)));
      push @table,[$table,$id,$n,$condition];
    } else {
      push @table,[$table,$id,$n];
    }
    my @conditions = serialize_conditions($n,{
      type=>$table,
      id=>$id,
      parent_id=>$parent_id,
      join => $extra_joins,
    });
    # where could also be obtained by replacing ___SELF___ with $id
    if ($n->{optional}) {
      # identify with parent
      if (@conditions) {
	@conditions = (['((',$n],@conditions,[qq{) OR $id."idx"=$parent_id."idx")},$n]);
      }
    }
    if ($n->{'relation'} eq 'a/aux.rf' or
	$n->{'relation'} eq 'a/lex.rf|a/aux.rf') {
      push @conditions,
	['('.serialize_expression({
	  type=>$n->parent->{type}||$tree->{type}||'t',
	  expression => qq{$parent_id."a_aux/a_idx"},
	  join => $extra_joins,
	  id=>$id,
	}).qq(=$id."idx").
	  (($n->{'relation'} eq 'a/lex.rf|a/aux.rf') 
	     ? qq{ OR $id."idx"=$id{$n->parent}."a_lex_idx"}
	     : qq{}).')',$n];
    }
    for my $rel (ListV($n->attr('extra-relations'))) {
      push @conditions,['('.extra_relation($id,$rel,{type=>$table,join => $extra_joins}).')',$n];
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
       [q(, ').($nodes[$_]->{type}||$tree->{type}||'a').q('),$n],
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

#   if (defined($tree_parent_id) and defined($id{$tree})) {
#     my $rel = relation($tree, {%$opts,id=>$id{$tree},parent_id=>$tree_parent_id});
#     push @WHERE,[$rel, $tree] if $rel=~/\S/;
#   }
  push @WHERE, @where;
  push @sql, [ "\nWHERE\n     ",'space'];
  push @sql, (map { ($_, ["\n AND ",'space']) } @WHERE);
  pop @sql; # pop the last AND or a solitary WHERE
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

sub map_attr {
  my ($attr)=@_;

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
    return ($value->{negate}==1 ? 'NOT ' : '').
           ($left.' '.uc($value->{operator}).' '.$right);
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

my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
$default_dbi_config = <<"EOF";
<dbi xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema>
      <pml_schema 
	  xmlns="http://ufal.mff.cuni.cz/pdt/pml/schema/" version="1.1">
        <revision>1.0</revision>
	<root name="dbi">
	  <structure>
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
