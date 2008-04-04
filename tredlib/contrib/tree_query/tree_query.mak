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
BEGIN {
  use vars qw($this $root);
  import TredMacro;
  import PML qw(&SchemaName);
  use File::Spec;
  use Benchmark ':hireswallclock';
}

Bind sub { query_sql({limit=>100}) } => {
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

{
use strict;

# Setup context
unshift @TredMacro::AUTO_CONTEXT_GUESSING,
sub { 
SchemaName() eq 'tree_query' ? __PACKAGE__ : undef };
sub allow_switch_context_hook {
  return 'stop' if SchemaName() ne 'tree_query';
}

# Setup stylesheet
sub switch_context_hook {
  CreateStylesheets();
  SetCurrentStylesheet('Tree_Query'),Redraw()
    if GetCurrentStylesheet() ne 'Tree_Query'; #eq STYLESHEET_FROM_FILE();
}
sub CreateStylesheets{
  unless(StylesheetExists('Tree_Query')){
    SetStylesheetPatterns(<<'EOF','Tree_Query',1);
context:   Tree_Query
rootstyle: #{vertical:0}
node: #{darkblue}${name}
node: <? Tree_Query::serialize_conditions_as_stylesheet($this) ?>
node: #{brown}${description}
EOF
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
    my @sel=@opts ? $opts[0] : ();
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
  eval {
    $dbi = DBI->connect('dbi:'.$cfg->{driver}.':'.
			  ($cfg->{driver} eq 'Oracle' ? "sid=" : "database=").$cfg->{database}.';'.
			    "host=".$cfg->{host}.';'.
			      "port=".$cfg->{port},
			$cfg->{username},
			$cfg->{password},
			{ RaiseError => 1 }
		       );
  };
  if ($@) {
    ErrorMessage($@);
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
    print qq(\n<query-result query.rf="$root->{id}" nodes=").$root->descendants.qq(">\n<sql>\n<![CDATA[$sql]]></sql>\n) if $xml;
    STDOUT->flush;
    my $t0 = new Benchmark;
    my $results = eval { $dbi->selectall_arrayref($sql,
						  {
						    MaxRows=>$opts->{limit}, RaiseError=>1
						   }
						 ) };
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
	$err=~y/\n/ /;
	print "$root->{id}\tFAIL\t$err\n";
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
      print "$root->{id}\tOK\t$no_results\t$time\n";
    }
    if (GUI()) {
#      my $sel = [];
#       if (ListQuery("Results",
# 		    'browse',
# 		    [map { join '/',@$_ } @$results],
# 		    $sel,
# 		    {buttons=>[qw(Ok)]})) {
      my $matches = @$results;
      if ($matches and QuestionQuery('Results',
				     ((defined($opts->{limit}) and $matches==$opts->{limit}) ? '>=' : '').
				       $matches.' match'.($matches>1?'(es)':''),
				     'Display','Cancel') eq 'Display') {
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
	      print map { $_."\n" } @files;
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
#      }
    }
    return $results;
  }
}

sub open_pmltq {
  my ($filename,$opts)=@_;
  print "open_pmltq: $filename,$opts\n";
  return unless $filename=~s{pmltq://}{};
  my @paths = idx_to_pos([split m{/}, $filename]);
  my $first = $paths[0];
  if (defined $first and length $first) {
    my $treebase_sources = $dbi_configuration->{sources};
    $opts->{-norecent}=1;
    Open($treebase_sources.'/'.$first,$opts);
    $first=~s/\.\d+$//;
    my @nodes = ($root,$root->descendants);
    for my $node (@nodes[map { /^\Q$first\E\.(\d+)$/ ? $1 : () } @paths]) {
      print "$node\n";
      $node->{__select}=1;
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
    print "idx: $idx, $type\n";
    print qq[SELECT "file", "sent_num", "pos" FROM ${type}_pos WHERE "idx" = $idx,\n];
    my $result = $dbi->selectall_arrayref(
      qq(SELECT "file", "sent_num", "pos" FROM ${type}_pos WHERE "idx" = $idx ).limit(1),
      { MaxRows=>1, RaiseError=>1 }
     );
    $result = $result->[0];
    push @res, $result->[0].'##'.$result->[1].'.'.$result->[2];
  }
  return @res;
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
    my $sql =  serialize_element({
      %$opts,
      name => 'and',
      condition => $node->{conditions},
    });
    if ($occurrences_strategy == SUB_QUERY) {
      my @occ_child = grep { length($_->{occurrences}) } $node->children;
      for my $child (@occ_child) {
	my $occ = $child->{occurrences};
	$sql .= " AND " if $sql=~/\S/;
	$sql .= " $occ=(".make_sql($child,{
	  count=>1,
	  parent_id=>$opts->{id},
	}).")";
      }
    }
    return $sql;
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

my %id;
sub init_id_map {
  my ($tree)=@_;
  my @nodes = $tree->descendants;
  %id = map { ($_ => lc($_->{name})) } @nodes;
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

sub relation {
  my ($n,$opts)=@_;
  my ($id,$parent_id)=map { $opts->{$_} } qw(id parent_id);
  my $condition;
  if ($n->parent) {
    if ($n->{'relation'} eq 'ancestor') {
      if ($n->parent->parent) {
	$condition = qq{$id."root_idx"=$parent_id."root_idx" AND }.
	  qq{$id."idx" BETWEEN $parent_id."idx" AND $parent_id."r"};
      }
    } elsif ($n->{'relation'} eq 'effective_parent') {
      $condition = qq{$id."root_idx"=n0."root_idx"};
    } elsif ($n->{'relation'} eq 'parent' or
	       $n->{'relation'} eq '') {
      $condition = qq{$id."parent_idx"=$id{$n->parent}."idx"};
    } elsif ($n->{'relation'} eq 'a/lex.rf') {
      $condition = qq{$id."idx"=$id{$n->parent}."a_lex_idx"};
    }
    if ($n->{optional}) {
      # identify with parent
      $condition = qq{(($condition) OR $id."idx"=$parent_id."idx")};
    }
  }
  return $condition;
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
  my @join;
  my @where;
  my %conditions;
  my %extra_joins;
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
    if ($i==0) {
      push @join," FROM $table $id ";
    } else {
      my $join;
      push @join,'';
      if ($parent->parent) {
	$join.=relation($n,{%$opts, id=>$id,parent_id=>$parent_id});
      } else {
	# what do we with _optional here?
	if ($n->parent->parent) {
	  $join .= qq{$id."root_idx"=n0."root_idx"};
	}
      }
      $join.=
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
      $join='1=1' unless $join=~/\S/;
      $join[-1].= " JOIN $table $id ".(length($join) ? ' ON '.$join : q{});
      if ($parent->parent and $n->{'relation'} eq 'effective_parent') {
	$join[-1].=qq{ JOIN ${table}_eparents ${id}_e ON ${id}_e."idx"=${id}."idx"}.
                   qq{ AND ${id}_e."eparent_idx"=$parent_id."idx"};
      }
    }
    my $where = Tree_Query::serialize_conditions($n,{
      type=>$table,
      id=>$id,
      parent_id=>$parent_id,
      join => \%extra_joins,
    });
    # where could also be obtained by replacing ___SELF___ with $id
    if ($n->{optional}) {
      if (length $where) {
	$where = qq{(($where) OR $id."idx"=$parent_id."idx")};
      }
    }
    if ($n->{'relation'} eq 'a/aux.rf' or
	$n->{'relation'} eq 'a/lex.rf|a/aux.rf') {
      if ($where=~/\S/) {
	$where.=' AND ';
      }
      $where.='('.serialize_expression({
	  type=>$n->parent->{type}||$tree->{type}||'t',
	  expression => qq{$parent_id."a_aux/a_idx"},
	  join => \%extra_joins,
	  id=>$id,
	}).qq(=$id."idx");
      if ($n->{'relation'} eq 'a/lex.rf|a/aux.rf') {
	  $where.=qq{ OR $id."idx"=$id{$n->parent}."a_lex_idx"};
      }
      $where.=')';
    }
    push @where, $where;
  }
  my $i=0;
  my @sql = (['SELECT ']);
  if ($count) {
    push @sql,['count(1)','space'];
  } else {
    push @sql, (map {
      (($_==0 ? () : [', ','space']),
       [$select[$_].'."idx"',$nodes[$_]],
       [' AS "'.$select[$_].'.idx"','space'],
       [q(, ').($nodes[$_]->{type}||$tree->{type}||'a').q('),$nodes[$_]],
       [' AS "'.$select[$_].'.type"','space']
      )
    } 0..$#nodes)
  }
  # joins
  push @sql, (map {
    (($_==0 ? () : ["\n ",'space']),
     [$join[$_],$nodes[$_]])
  } 0..$#nodes);
  # extra joins
  push @sql,
    (map {
      my $name=$_;
      my $tab=$extra_joins{$_}[0];
      my $on=$extra_joins{$_}[1];
      my $type=$extra_joins{$_}[2] || '';
      ([' ','space'],[
	qq(\n $type JOIN $tab $name ON $on)
       ])
    } sort { length($a)<=>length($b) } keys %extra_joins);
  my @WHERE;
  if (defined($tree_parent_id) and defined($id{$tree})) {
    my $rel = relation($tree, {%$opts,id=>$id{$tree},parent_id=>$tree_parent_id});
    push @WHERE,[$rel, $tree] if $rel=~/\S/;
  }
  push @WHERE, (map {
    [$where[$_],$nodes[$_]]
  } grep {
    my $w = $where[$_];
    defined($w) and length($w)
  } 0..$#nodes);
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

sub serialize_expression {
  my ($opts)=@_;
  my $exp = $opts->{expression};
  $exp=~s{(?:(\w+)\.)?"([^"]+)"}{
    print "$1 => $2\n";
    my $id = defined($1) ? $1 : $opts->{id};
    my @ref = split m{/}, $2;
    my $column = pop @ref;
    my $table = $opts->{type};
    for my $tab (@ref) {
      my $prev = $id;
      $id.="_$tab";
      $table.="_$tab";
      $opts->{join}{$id} = [$table => qq($id."idx" = $prev."idx"), 'LEFT'];# should be qq($prev."$tab")
    }
    qq($id."$column");
  }e;
  print "exp: $exp\n";
  return $exp;
}

sub serialize_element {
  my ($opts)=@_;
  my ($name,$value,$as_id,$parent_as_id)=map {$opts->{$_}} qw(name condition id parent_id);
  if ($name eq 'test') {
    my $left = serialize_expression({%$opts,expression=>$value->{a}});
    my $right = serialize_expression({%$opts,expression=>$value->{b}});
    for ($left,$right) {
      s/"_[#]descendants"/"r"-"idx"/g;
      s/"_[#]lbrothers"/"chord"/g;
      s/"_[#]rbrothers"/$parent_as_id."chld"-"chord"-1/g;
      s/"_[#]sons"/"chld"/g;
      s/"_depth"/"lvl"/g;
    #  s/(^|.)(\"[^"]*\")/$1 eq '.' ? $1.$2 : "$1$as_id.$2"/eg;
    }
    print "$left => $right\n";
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
