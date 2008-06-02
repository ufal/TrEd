# -*- cperl -*-

#include <contrib/pml/PML.mak>

#TODO
#
# - _transitive=exclusive (in NG by default, a query node can lay on
# the transitive edge of other query node; if =exclusive, than no query
# node can lay on the transitive edge and also, the transitive edge
# cannot share nodes with any other exclusive transitive edge (but can
# share nodes with some non-exclusive transitive edge)). Thus,
# exclusivity in NG seems equivalent to creating an optional node
# between the transitive query node and its query parent.

# allow the user to mark the nodes with colours and recognize the
# colored nodes in the result tree

# check if we can search for non-projective edges

# relations/attributes from external tables:
# tables:
# - T            (tree structure)
# - T_FILEINFO   (currently T_POS)
# - T_ATTRS      (attribute structure, not yet used)

# warn if optional=1 for a relation that implies a different type
#
# some helpful atomic predicates:
#  - is_leaf
# relations of tgrep2
#
#
# - turn current EVALUATOR to a wrapper 
#   called e.g. ResultBrowser. Then Evaluator does not need
# ResultBrowser classes will implement a common interface 
#
#   - Configure
#   - SearchFirst
#   - ShowNextResult
#   - ShowPrevResult
#   - ShowCurrentNode
#   - HighlightCurrentNode
#
#  one class for SQLEavaluator, one for BtredEvaluator. In the future,
#  one for NtredEvaluator. I might also atttempt some day to write a
#  pure DOM/XPath-based PMLEvaluator using the same algorithm as
#  in BtredEvaluator, only reimplementing iterators, relations and attr().
#
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

our $VALUE_LINE_MODE = 0;
our @SEARCHES;
our $SEARCH;


# Edit node:
Bind sub {
  my $string = as_text($this);
  my $result;
  my $opts={};
  my $parser;
  {
    my $t0 = new Benchmark;
    $parser = query_parser();
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "creating parser took: $time\n";
  }
  while ( defined ($string = EditBoxQuery('Edit query node', $string, '',$opts)) ) {
    my $t0 = new Benchmark;
    eval {
      if (!$this->parent) {
	$result=$parser->parse_query($string);
      } elsif ($this->{'#name'} eq 'node') {
	$result=$parser->parse_node($string);
      } else {
	$result=$parser->parse_test($string);
      }
    };
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "parsing query took: $time\n";
    last unless $@;
    if (ref($@) eq 'Tree_Query::ParserError' ) {
      $opts->{-cursor} = $@->line.'.end';
    }
    ErrorMessage("$@");
  }
  return unless $string;
  {
    my $t0 = new Benchmark;
    if ($this->parent) {
      $result->paste_after($this);
      DeleteSubtree($this);
      $this=$result;
      DetermineNodeType($this);
    } else {
      DeleteSubtree($_) for $root->children;
      CutPaste($_,$root) for reverse $result->children;
    }
    DetermineNodeType($_) for ($this->descendants);
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "postprocessing took: $time\n";
  }
} => {
  key => 'e',
  menu => 'Edit node'
};

Bind sub {
  for (reverse sort_children_by_node_type($this)) {
    CutPaste($_,$this);
  }
} => {
  key => 'o',
  menu => "Sort node's children by type"
};

Bind 'Search' => {
  key => 'space',
  menu => 'Query SQL server',
  changing_file => 0,
};

Bind sub {  $SEARCH && $SEARCH->show_current_result } => {
  key => 'm',
  menu => 'Show Match',
  changing_file => 0,
};

Bind sub { $SEARCH && $SEARCH->show_next_result } => {
  key => 'n',
  menu => 'Show Next Match',
  changing_file => 0,
};

Bind sub { $SEARCH && $SEARCH->show_prev_result } => {
  key => 'p',
  menu => 'Show Previous Match',
  changing_file => 0,
};

Bind sub { RenewStylesheets(); $Redraw='stylesheet'; } => {
  key => 'y',
  menu => 'Renew Tree_query Stylesheet',
  changing_file => 0,
};

Bind 'fix_netgraph_query' => {
  key => 'f',
  menu => 'Attempt to fix a NetGraph query',
};

Bind sub { $VALUE_LINE_MODE=!$VALUE_LINE_MODE } => {
  key => 'v',
  menu => 'Toggle value line mode (TreeQuery/SQL)',
  changing_file => 0,
};

Bind sub {
  my $node=$this;
  ChangingFile(0);
  return unless $node->parent and
    $node->{'#name'} ne 'node';
  if ($node->parent->{'#name'} eq 'not' and
	!$node->lbrother and !$node->rbrother) {
    delete_node_keep_children($node->parent);
  } else {
    my $not = NewParent();
    $not->{'#name'}='not';
    DetermineNodeType($not);
    $this=$node;
    ChangingFile(1);
  }
} => {
  key => '!',
  menu => 'Negate a condition',
};

Bind sub {
  my $node=$this;
  ChangingFile(0);
  return if !$node->parent or
    $node->parent->{'#name'} !~ /^(?:not|or)$/;
  my $and = NewParent();
  $and->{'#name'}='and';
  DetermineNodeType($and);
  $this=$node;
  ChangingFile(1);
} => {
  key => '&',
  menu => 'Create And',
};

Bind sub {
  my $node=$this;
  ChangingFile(0);
  return unless $node->parent and
    $node->{'#name'}!~/^(?:node|or)$/
    and $node->parent->{'#name'} ne 'or';
  my $or = NewParent();
  $or->{'#name'}='or';
  DetermineNodeType($or);
  $this=$node;
  ChangingFile(1);
} => {
  key => '|',
  menu => 'Create Or',
};

Bind sub {
  ChangingFile(0);
  return unless $this->{'#name'}=~/^(?:node|subquery)$/;
  EditAttribute($this,'name') && ChangingFile(1);

} => {
  key => '$',
  menu => 'Edit node name',
};

Bind sub {
  ChangingFile(0);
  return unless $this->{'#name'}=~/^(?:node|subquery)$/;
  EditAttribute($this,'node-type') && ChangingFile(1);

 } => {
  key => 't',
  menu => 'Edit node type',
};

Bind sub {
  ChangingFile(0);
  return unless $this->{'#name'} eq 'node';
  $this->{optional}=!$this->{optional};
  ChangingFile(1);
} => {
  key => '?',
  menu => 'Toggle optional',
};

Bind sub {
  my $new;
  my $node=$this;
  ChangingFile(0);
  if ($node->{'#name'}=~/^(?:node|subquery|and|or|not)$/) {
    $new=NewSon();
  } elsif ($node->{'#name'}=~/^(?:test|ref)$/) {
    $new=NewRBrother();
  } else {
    return;
  }
  $new->{'#name'}='test';
  $new->{operator}='=';
  DetermineNodeType($new);
  unless (EditAttribute($new,undef,undef,'a')) {
    DeleteLeafNode($new);
    $this=$node;
    return;
  }
  ChangingFile(1);
} => {
  key => '=',
  menu => 'Add a constraint test',
};

Bind sub {
  ChangingFile(0);
  return unless $this->{'#name'} =~ /^(node|subquery|ref)$/;
  unless (SeqV($this->{relation})) {
    my @sel='child';
    ListQuery('Select relation of the current node to its parent',
	      'browse',
	      GetRelationTypes($this),
	      \@sel) || return;
    SetRelation($this,$sel[0]) if @sel;
  } elsif (EditAttribute($this,'relation')) {
    ChangingFile(1);
  }
} => {
  key => 'r',
  menu => 'Edit relation of the current node to its parent',
};

Bind sub {
  ChangingFile(0);
  return unless $this->{'#name'} eq 'subquery';
  if (not (AltV($this->{'occurrences'}))) {
    $this->{occurrences}=Fslib::Struct->new({min=>1});
  }
  if (EditAttribute($this,'occurrences')) {
    ChangingFile(1);
  }
} => {
  key => 'x',
  menu => 'Edit occurrences on a subquery-node',
};

Bind ToggleHiding => {
  key => 'H',
  menu => 'Toggle hiding of logical nodes',
};

Bind sub {
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($this,$this->ancestors);
  if ($qn) {
    $qn->{'.unhide'}=!$qn->{'.unhide'};
    $this=$qn;
  }
} => {
  key => 'h',
  menu => 'Toggle hiding of logical nodes',
};


Bind sub {
  my $node=$this;
  return unless $node;
  my $p=$node->parent && $node->parent->parent;
  if ($node->{'#name'} =~ /^(?:node|subquery)/) {
    DeleteSubtree($_) for grep { !($_->{'#name'} eq 'node'
				     or ($p && $_->{'#name'} eq 'subquery')) }
      $node->children;
  }
  delete_node_keep_children($node);
} => {
  key => 'Delete',
  menu => 'Delete current node (pasting its children on its parent)'
};

Bind sub {
  my $node=$this;
  return unless $node;
  if (!$node->parent or $node->{'#name'} =~ /^(?:node|subquery)/) {
    my $new = NewSon();
    $new->{'#name'}='node';
    DetermineNodeType($new);
  } elsif ($node->{'$name'}=~/^(?:test|ref)/) {
    my $new = NewRBrother();
    $new->{'#name'}=$node->{'#name'};
    DetermineNodeType($new);
  }
} => {
  key => 'Insert',
  menu => 'Create a new query node'
};

my %schema_map = (
  t => PMLSchema->new({filename => 'tdata_schema.xml',use_resources=>1}),
  a => PMLSchema->new({filename => 'adata_schema.xml',use_resources=>1}),
);

Bind sub {
  SelectSearch()
} => {
  key => 'c',
  menu => 'Select search engine',
  changing_file => 0,
};

Bind sub {
  unless ($SEARCH) {
    SelectSearch()||return;
  }
  $SEARCH->configure;
} => {
  key => 'C',
  menu => 'Configure search engine',
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

sub RenewStylesheets {
  DeleteStylesheet('Tree_Query');
  CreateStylesheets();
  SetCurrentStylesheet('Tree_Query');
  SaveStylesheets();
}

sub CreateStylesheets{
  unless(StylesheetExists('Tree_Query')){
    SetStylesheetPatterns(<<'EOF','Tree_Query',1);
context:   Tree_Query
hint: 
rootstyle:#{balance:1}#{Node-textalign:center}#{NodeLabel-halign:center}
xrootstyle: #{vertical:0}#{nodeXSkip:15}
rootstyle: #{NodeLabel-skipempty:1}#{CurrentOval-width:3}#{CurrentOval-outline:red}
node: <?length($${node-type}) ? $${node-type}.': ' : '' ?>#{darkgreen}<?
  my $occ = Tree_Query::occ_as_text($this);
  length $occ ? '${occurrences='.$occ.'x}' : ""
?><? $${optional} ? '${optional=?}'  : q()
?>
node: #{darkblue}${name}#{brown}<? my$d=$${description}; $d=~s{^User .*?:}{}; $d ?>
node:<?
  ($this->{'#name'} =~ /^(?:and|or|not)$/) ? uc($this->{'#name'}) : '' 
?>${a}${target}
node:<?
  if (($this->{'#name'}=~/^(?:node|subquery)$/) and !$this->{'.unhide'} and !TredMacro::HiddenVisible() ) {
    join("\n",map { Tree_Query::as_text($_,'  ',1) } grep { $_->{'#name'} !~ /^(?:node|subquery|ref)$/ } $this->children)
  } elsif ($this->{'#name'} eq 'test') {
    '${operator}'
  }
?>
node:${b}
style: <? 
  my $name = $this->{'#name'};
  if ($name =~ /^(?:node|subquery|ref)$/ and $this->parent->parent ) {
    my ($rel) = map {
      my $name = $_->name;
      $name eq 'user-defined' ? $_->value->{label} : $name
    } SeqV($this->{relation});
    $rel||='child';
    my $color = Tree_Query::arrow_color($rel);
    my $arrow = Tree_Query::arrow($rel);
    (defined($arrow) ? "#{Line-arrow:$arrow}" : '').
    (defined($color) ? "#{Line-fill:$color}" : '').
    ($name eq 'ref' and defined($color) ? "#{Oval-outline:$color}#{Oval-fill:$color}" : '').
    '#{Line-tag:relation}'
  }
?>
style: <? if ($this->parent and $this->parent->{'#name'} eq 'or') {
    '#{Line-dash:-}'
  }
?>
style:<?
   my $name = $this->{'#name'};
   $name eq 'node' ?
   (($${node-type}||$root->{'node-type'}) eq 't'
      ? '#{Oval-fill:pink}' 
      : '#{Oval-fill:yellow}' ).'#{Node-addwidth:7}#{Node-addheight:7}#{Line-width:3}#{Line-arrowshape:14,18,4}'
   : $name eq 'test' ? '#{NodeLabel-dodrawbox:yes}#{Line-fill:lightgray}#{Node-shape:rectangle}#{Oval-fill:gray}' 
   : $name eq 'subquery' ? '#{Oval-fill:green}'
   : $name eq 'ref' ? '#{Node-shape:oval}'
   : $name =~ /^(?:or|and|not)$/ ? '#{Node-shape:rectangle}#{Node-surroundtext:1}#{NodeLabel-valign:center}#{Oval-fill:cyan}'
   : '${Oval-fill:black}'
?>
EOF
  }
}

sub get_query_node_type {
  my ($node)=@_;
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
  my $table = ($qn && $qn->{'node-type'})||$node->root->{'node-type'};
  return $table;
}

sub get_query_node_schema {
  my ($node)=@_;
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
  my $table = ($qn && $qn->{'node-type'})||$node->root->{'node-type'};
  return unless $table;
  return $schema_map{$table};
}

sub attr_choices_hook {
  my ($attr_path,$node,undef,$editor)=@_;
  if ($node->{'#name'} eq 'ref' and $attr_path eq 'target') {
    return [
      grep { defined && length }
      map $_->{name},
      grep $_->{'#name'} =~ /^(?:node|subquery)$/, $node->root->descendants
    ];
  } elsif (!$node->parent or $node->{'#name'} =~ /^(?:node|subquery)$/) {
    if ($attr_path eq 'node-type') {
      return [sort keys %schema_map];
    }
  } elsif ($node->{'#name'} eq 'test') {
    if ($attr_path eq 'a') {
      my $schema = get_query_node_schema($node);
      if ($schema) {
	return [
	  $schema->get_paths_to_atoms(undef, { no_childnodes => 1 })
	];
      }
    } elsif ($attr_path eq 'b') {
      if (UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch')) {
	my $name = $editor->get_current_value('a');
	if ($name and $name=~m{^(?:\$[[:alpha:]_][[:alnum:]_/\-]*\.)?"?([[:alpha:]_][[:alnum:]_/\-]*)"?$}) {
	  my $attr = $1;
	  my $table = get_query_node_type($node);
	  return unless $table=~m{^[[:alpha:]_][[:alnum:]_/\-]*$};
	  if ($attr=~s{^(.*)/}{}) {
	    my $t=$1;
	    $t=~s{/}{_}g;
	    $table=$table.'_'.$t;
	  }
	  my $sql = <<SQL;
SELECT * FROM (
  SELECT "$attr" FROM ${table} 
  WHERE "$attr" IS NOT NULL
  GROUP BY "$attr"
  ORDER BY count(1) DESC
) WHERE ROWNUM<100
ORDER BY "$attr"
SQL
	  #my $sql = qq(SELECT DISTINCT "$attr" FROM ${table} ORDER BY "$attr");
	  print "$sql\n";
	  my $results = eval { $SEARCH->{evaluator}->run_sql_query($sql,{ MaxRows=>100, RaiseError=>1, Timeout => 10 }) };
	  print $@;
	  return if $@;
	  my @res= map qq('$_->[0]'),@$results;
	  return @res ? \@res : ();
	}
      }
    }
  }
  return;
}

my %id;
my %name2node_hash;
sub init_id_map {
  my ($tree)=@_;
  my @nodes = grep { $_->{'#name'} =~ /^(?:node|subquery)$/ } $tree->descendants;
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
      $name2node_hash{$id}=$n;
    }
  };
}

#include "ng.inc"

# given to nodes or their IDs ($id and $ref)
# returns 0 if both belong to the same subquery
# returns 1 if $id is in a subquery nested in a subtree of $ref
# (and hence $ref can be referred to from $id)
# returns -1 otherwise

sub cmp_subquery_scope {
  my ($id,$ref) = @_;
  return 0 if $id eq $ref;
  my $node = ref($id) ? $id : $name2node_hash{$id};
  my $ref_node = ref($ref) ? $ref : $name2node_hash{$ref};
  $ref_node || croak "didn't find node $ref";
  $node || croak "didn't find node $id";

  while ($node->parent and $node->{'#name'} ne 'subquery') {
    $node=$node->parent;
  }
  while ($ref_node->parent and $ref_node->{'#name'} ne 'subquery') {
    $ref_node=$ref_node->parent;
  }
  return 0 if $node==$ref_node;
  return 1 if first { $_==$ref_node } $node->ancestors;
  return -1;
}

sub occ_as_text {
  my ($node)=@_;
  return '' unless $node->{'#name'} eq 'subquery';
  return join('|', grep { /\d/ } map {
    my ($min,$max)=($_->{min},$_->{max});
    if (length($min) and length($max)) {
      if (int($min)==int($max)) {
	int($min)
      } else {
	int($min).'..'.int($max)
      }
    } elsif (length($min)) {
      int($min).'+'
    } elsif (length($max)) {
      int($max).'-'
    } else {
      '1+'
    }
  } AltV($node->{occurrences}));
}


my %child_order = (
  test=>1,
  not=>2,
  or=>3,
  and=>4,
  ref=>5,
  subquery=>6,
  node=>7,
);

sub sort_children_by_node_type {
  my ($node)=@_;
  return map { $_->[0] }
         sort { $a->[1]<=>$b->[1] }
         map { [$_,int($child_order{$_->{'#name'}})] } $node->children;
}

sub rel_as_text {
  my ($node)=@_;
  my ($rel) = SeqV($node->{relation});
  if ($rel) {
    my ($rn,$rv)=($rel->name,$rel->value);
    if ($rn eq 'user-defined') {
      return $rv->{label};
    } elsif ($rn =~ /^(?:ancestor|descendant)/
	       and length($rv->{min_length})||length($rv->{max_length})) {
      return $rn.'{'.$rv->{min_length}.','.$rv->{max_length}.'}'
    } else {
      return $rn;
    }
  } else {
    return 'child';
  }
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
  'order-precedes' => 'orange',
  'a/lex.rf' => 'violet',
  'a/aux.rf' => 'thistle',
  'a/lex.rf|a/aux.rf' => 'tan',
  'coref_text' => '#4C509F',
  'coref_gram' => '#C05633',
  'compl' => '#629F52',
  'descendant' => 'blue',
  'ancestor' => 'lightblue',
  'child' => 'black',
  'parent' => 'lightgray',
  'echild' => 'darkgreen',
  'eparent' => 'green',
);
my %arrow = (
  'a/lex.rf' => 'first',
  'a/aux.rf' => 'first',
  'a/lex.rf|a/aux.rf' => 'first',
  'coref_text' => 'first',
  'coref_gram' => 'first',
  'compl' => 'first',
  'descendant' => 'first',
  'ancestor' => 'first',
  'child' => 'first',
  'parent' => 'first',
  'echild' => 'first',
  'eparent' => 'first',
);
sub arrow_color {
  my $rel = shift;
  return $color{$rel};
}
sub arrow {
  my $rel = shift;
  return $arrow{$rel};
}

sub tq_serialize {
  my ($node,$opts)=@_;
  my $indent = $opts->{indent};
  my $do_wrap = $opts->{wrap};
  my $query_node = $opts->{query_node};
  my $name = $node->{'#name'};
  $indent||='';
  my @ret;
  my $wrap=int($do_wrap) ? "\n$indent" : " ";
  if ($name eq '' and !$node->parent) {
    my $desc = $node->{description};
    return [
      [(length($desc) ? '#  '.$desc."\n" : ''),$node],
      map { (@{tq_serialize($_,$opts)},[";\n"]) } $node->children
     ]
  } else {
    my $copts = {%$opts,indent=>$indent."     "};
    if ($name eq 'subquery' or $name eq 'node') {
      $copts->{query_node}=$node;
    }
    my @r = map [tq_serialize($_,$copts)], $node->children;
    if ($name=~/^(?:not|or|and)$/) {
      if ($name eq 'not') {
	push @ret,['!',$node,$query_node,'-foreground=>darkcyan'];
	$name='and';
      }
      if (@r) {
	push @ret,( @r==1 ? $r[0] : (['(',$node,$query_node,'-foreground=>darkcyan'],
				     @{_group(\@r,["${wrap}$name ",$node,$query_node,'-foreground=>darkcyan'])},
				     [')',$node,$query_node,'-foreground=>darkcyan']) );
      }
    } elsif ($name eq 'ref') {
      my $rel=rel_as_text($node);
      my $arrow = $rel;
      $arrow=~s/{.*//;
      push @ret,
	[$rel.' ',$node,$query_node,'-foreground=>'.arrow_color($arrow)];
      my $ref = $node->{target} || '???';
      push @ret,["\$$ref",$node,$query_node,'-foreground=>darkblue'];
    } elsif ($name eq 'test') {
      my $test=  $node->{a}.' '.$node->{operator}.' '.$node->{b};
      #$test=~s/"//g;		# FIXME
      @ret = ( [$test,$node,$query_node] );
    } elsif ($name eq 'subquery' or $name eq 'node') {
      if ($name eq 'subquery') {
	push @ret, [occ_as_text($node).'x ',$node,'-foreground=>darkgreen'];
      } elsif ($node->{optional}) {
	push @ret, ['?',$node,'-foreground=>darkgreen'];
      }
      my $rel='';
      if ($node->parent and $node->parent->parent) {
	$rel=rel_as_text($node);
	my $arrow = $rel;
	$arrow=~s/{.*//;
	push @ret,[$rel.' ',$node,'-foreground=>'.arrow_color($arrow)];
      }
      my $type=get_query_node_type($node);
      push @ret,[$type.' ',$node] if $type; #FIXME: 
      if ($node->{name}) {
	push @ret,['$'.$node->{name},$node,'-foreground=>darkblue'],[' := ',$node];
      }
      if ($do_wrap) {
	if (@r) {
	  push @ret, (["[ ",$node],["${wrap}  "],
		      @{_group(\@r,[",${wrap}  "])},
		      ["${wrap}"],[" ]",$node]);
	} else {
	  push @ret, (["[ ]",$node]);
	}
      } else {
	unshift @ret,["\n${indent}"] if $node->lbrother;
	if (@r) {
	  push @ret,["\n${indent}"],["[ ",$node],
	    @{_group(\@r,[", ",$node])},
	      [" ]",$node];
	} else {
	  push @ret, (["[ ]",$node]);
	}
      }
    } else {
      @ret = (['## unknown: '.$name,$node]);
    }
  }
  return \@ret;
}

sub as_text {
  my ($node,$indent,$wrap)=@_;
  make_string(tq_serialize($node,{indent=>$indent,wrap=>$wrap}));
}

sub _group {
  my ($array,$and_or) = @_;
  return [ map {
    ($_==0) ? ($array->[$_]) : ($and_or,$array->[$_])
  } 0..$#$array ];
}

sub make_string {
  my ($array) = @_;
  Carp::cluck "not an array" unless ref($array) eq 'ARRAY';
  return join '', map {
    ref($_->[0]) ? make_string($_->[0]) : $_->[0]
  } @$array;
}

sub make_string_with_tags {
  my ($array,$tags) = @_;
  return [map {
    ref($_->[0]) ? @{make_string_with_tags($_->[0],[uniq(@$tags,@{$_}[1..$#$_])])} : [$_->[0], uniq(@$tags,@{$_}[1..$#$_])]
  } @$array];
}

my $parser;
sub query_parser {
  return $parser if defined $parser;
  my $Grammar = $libDir."/contrib/tree_query/Grammar.pm";
  delete $INC{$Grammar};
  require $Grammar;
  $Tree_Query::user_defined = 'echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_text|coref_gram|compl';
  $parser = Tree_Query::Grammar->new() or die "Could not create parser for Tree_Query grammar\n";
  return $parser;
}
sub parse_query {
  shift if @_>1;
  return query_parser()->parse_query($_[0]);
}
sub parse_expression {
  shift if @_>1;
  return query_parser()->parse_expression($_[0]);
}


sub get_nodelist_hook {
  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  my $tree = $fsfile->tree($tree_no);
  my @nodes = ($tree, grep {
    my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($_,$_->ancestors);
    ($qn->{'.unhide'} || $show_hidden) || ($_->{'#name'} =~ /^(?:node|subquery)$/)
  } $tree->descendants);
  return [\@nodes,$prevcurrent];
}

sub node_style_hook {
  my ($node,$styles) = @_;
  my $i=0;
  my @refs;
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
  my $showHidden = $qn->{'.unhide'} or HiddenVisible();
  if ($showHidden) {
    @refs=($node) if $node->{'#name'} eq 'ref';
  } else {
    @refs=grep { $_->{'#name'} eq 'ref' }
      map { $_->{'#name'} eq 'not' ? $_->children : $_ }
      $node->children;
  }
  for my $ref (@refs) {
    DrawArrows($node,$styles, [
      map {
	my $name = $_->name;
	$name = $_->value->{label} if $name eq 'user-defined';
	my $target = $ref->{target};
	my $negate = ($node!=$ref && $ref->parent->{'#name'} eq 'not') ? 1 : 0;
	scalar {
	  -target => $name2node_hash{lc($target)},
	  -fill   => $showHidden ? 'gray' : arrow_color($name),
	  (-dash   => $negate ? '-' : ''),
	  -raise => 8+8*(++$i),
	  -tag => 'relation',
	}
      } SeqV($ref->attr('relation'))
     ], {
       -arrow => 'last',
       -arrowshape => '14,18,4',
       -width => $showHidden ? 1 : 2,
       -smooth => 1,
     });
  }
}

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  init_id_map($tree);
  return $VALUE_LINE_MODE == 0 ?
    make_string_with_tags(tq_serialize($tree),[]) :
    build_sql($tree,{format=>1});
}

sub line_click_hook {
  my ($node,$tag,$button, $double,$modif, $ev)=@_;
  if ($node and $double and $button eq '1' and !$modif) {
    if ($tag eq 'relation') {
      EditAttribute($node,'relation');
      Redraw();
    }
  }
}
sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target and $mod;
  if ($mod eq 'Control') {
    my $type = $node->{'#name'};
    my $target_type = $target->{'#name'};
    return 'stop' unless $target_type =~/^(?:node|subquery)$/;
    return 'stop' if cmp_subquery_scope($node,$target)<0;

    if ($type eq 'node' or $type eq 'subquery') {
      my @sel = map {
	my $name = $_->name;
	if ($name eq 'user-defined') {
	  qq{$name: }.$_->value->{label}
	} else {
	  $name
	}
      } map { SeqV($_->{relation}) }
        grep { $_->{target} eq $target->{name} }
        grep { $_->{'#name'} eq 'ref' } $node->children;
      ListQuery('Select query-node relations to add/preserve',
		'multiple',
		GetRelationTypes($node),
		\@sel) || return;
      init_id_map($node->root);
      AddOrRemoveRelations($node,$target,\@sel,{-add_only=>0});
      TredMacro::Redraw_FSFile_Tree();
      ChangingFile(1);
    } elsif ($type eq 'ref') {
      init_id_map($node->root);
      return 'stop' if cmp_subquery_scope($node,$target)<0;
      $node->{target}=GetNodeName($target);
      ChangingFile(1);
    }
  }
  return;
}


sub current_node_change_hook {
  my ($node,$prev)=@_;
  return unless $SEARCH;
  return $SEARCH->select_matching_node($node);
}

sub GetNodeName {
  my ($node)=@_;
  die "#name!='node'" unless defined($node) and $node->{'#name'} eq 'node';
  if (defined($node->{name})) {
    return $node->{name}
  } else {
    my $i=0;
    $i++ while (exists $name2node_hash{"ref$i"});
    my $name = "ref$i";
    $node->set_attr('name',$name);
    $name2node_hash{$name}=$node;
    return $name;
  }
}

sub SetRelation {
  my ($node,$type,$opts)=@_;
  if ($type=~s/^(user-defined): // and !($opts and $opts->{label})) {
    $opts||={};
    $opts->{label}=$type;
    $type = 'user-defined';
  }
  my $rel = Fslib::Seq::Element->new( 
    $type => Fslib::Container->new(undef,$opts) 
  );
  $node->{relation}||=Fslib::Seq->new();
  @{$node->{relation}->elements_list}=( $rel );
  return $rel;
}

sub GetRelationTypes {
  my $node=@_ ? $_[0] : $this;
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
}

# note: you have to call init_id_map($root); first!
sub AddOrRemoveRelations {
  my ($node,$target,$types,$opts)=@_;
  my $target_name = GetNodeName($target);
  my %types = map { $_=> 1 } @$types;
  my @refs =
    grep { lc($_->{target}) eq lc($target_name) }
    grep { $_->{'#name'} eq 'ref' } $node->children;
  for my $ref (@refs) {
    my ($rel)=SeqV($ref->{relation});
    if ($rel) {
      my $rel_name = $rel->name;
      my $val = $rel->value;
      if ($rel_name eq 'user-defined') {
	$rel_name = "$rel_name: ".$val->{label};
      }
      if ($opts->{-add_only}) {
	delete $types{$rel_name}; # already have it
      } elsif (!$types{$rel_name}) {
	DeleteLeafNode($ref);
      }
    }
  }
  my @new;
  for my $type (grep { $types{$_} } @$types) {
    my $ref = NewSon($node);
    $ref->{'#name'}='ref';
    DetermineNodeType($ref);
    $ref->{target}=$target_name;
    my ($name,$value);
    SetRelation($ref,$type);
    push @new,$ref;
  }
  return @new;
}


sub FilterQueryNodes {
  my ($tree)=@_;
  my @nodes;
  my $n = $tree;
  while ($n) {
    if ($n->{'#name'} eq 'node' or
	  ($n==$tree and $n->{'#name'} eq 'subquery')) {
      push @nodes, $n;
    } elsif ($n->parent) {
      $n = $n->following_right_or_up($tree);
      next;
    }
    $n = $n->following($tree);
  }
  return @nodes;
}


our %is_match;
our $btred_results;
our @last_results;

# determine which nodes are part of the current result
sub map_results {
}

sub Search {
  unless ($SEARCH) {
    SelectSearch();
  }
  $SEARCH->search_first();
}

sub SelectSearch {
  my @sel;
  ListQuery('Search',
	    'browse',
	    [
	      (map { $_->identify } @SEARCHES),
	      (map { 'Search File list: '.$_->name } TrEdFileLists()),
	      (map { 'Search File: '.$_->filename } grep ref, map CurrentFile($_), TrEdWindows()),
	      'Search Remote Treebank Database',
	    ],
	    \@sel
	   ) || return;
  return unless @sel;
  my $sel = $sel[0];
  if ($sel eq 'Search Remote Treebank Database') {
    $SEARCH=Tree_Query::SQLSearch->new();
  } elsif ($sel =~ /Search File: (.*)/) {
    $SEARCH=Tree_Query::TrEdSearch->new({file => $1});
  } elsif ($sel =~ /Search File list: (.*)/) {
    $SEARCH=Tree_Query::TrEdSearch->new({filelist => $1});
  }

  push @SEARCHES, $SEARCH if $SEARCH;
  # TODO
  #
  return $SEARCH;
}

################
### SQL compiler and evaluator
################
{

package Tree_Query::SQLEvaluator;
use Benchmark;
use Carp;
use strict;
use warnings;
BEGIN { import TredMacro qw(first SeqV AltV ListV GUI ErrorMessage QuestionQuery) }

sub new {
  my ($class,$query_tree,$opts)=@_;
  my $self = bless {
    dbi => $opts->{dbi},
    connect => $opts->{connect},
    results => undef,
    query_nodes=>undef,
  }, $class;
  $self->prepare_query($query_tree,$opts) if $query_tree;
  return $self;
}

sub get_results {
  my $self = shift;
  return $self->{results} || [];
}

sub get_query_nodes {
  my $self = shift;
  return $self->{query_nodes};
}

sub get_sql {
  my $self = shift;
  return $self->{sql};
}

sub prepare_sql {
  my ($self,$sql)=@_;
  $self->{sth} = undef;
  $self->{sql} = $sql;
  my $dbi = $self->{dbi} || $self->connect();
  if ($self->sql_driver eq 'Pg') {
    $self->{sth} = $dbi->prepare( $sql, { pg_async => 1 } );
  } else {
    $self->{sth} = $dbi->prepare( $sql );
  }
}

sub prepare_query {
  my ($self,$query_tree,$opts)=@_;
  $opts||={};
  unless (ref($query_tree)) {
    $query_tree = Tree_Query::parse_query($query_tree);
  }
  $self->{id} = $query_tree->{id} || 'no_ID';
  $self->{query_nodes} = [Tree_Query::FilterQueryNodes($query_tree)];
  {
    my %id;
    my %name2node_hash;
    my @nodes = grep { $_->{'#name'} =~ /^(?:node|subquery)$/ } $query_tree->descendants;
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
	$id{$n}=$id;			# generate id;
	$occup{$id}=1;
	$name2node_hash{$id}=$n;
      }
    }
    ;
    $self->{id_map}=\%id;
    $self->{name2node}=\%name2node_hash;
  }
  $self->prepare_sql($self->sql_serialize_conditions($query_tree,
						     { %$opts,
						       syntax=>$self->sql_driver,
						       limit=>$self->{limit}
						      }));
}

sub sql_driver {
  my ($self)=@_;
  return $self->{connect}{driver};
}

sub connect {
  my ($self)=@_;
  return $self->{dbi} if $self->{dbi};
  my $cfg = $self->{connect};
  require DBI;
  require Sys::SigAction;
  # this is taken from http://search.cpan.org/~lbaxter/Sys-SigAction/dbd-oracle-timeout.POD
  eval {
    #note that if you ask for safe, it will not work...
    my $h = Sys::SigAction::set_sig_handler( 'ALRM',
					     sub {
					       die "timed out connecting to database on $cfg->{host}\n";
					     },
					     { flags=>0 ,safe=>0 } );
    alarm(10);
    if ($cfg->{driver} eq 'Pg') {
      require DBD::Pg;
      import DBD::Pg qw(:async);
    } elsif ($cfg->{driver} eq 'Oracle') {
      $::ENV{NLS_LANG}='CZECH_CZECH REPUBLIC.AL32UTF8';
      $::ENV{NLS_NCHAR}='AL32UTF8';
    }
    $self->{dbi} = DBI->connect('dbi:'.$cfg->{driver}.':'.
			  ($cfg->{driver} eq 'Oracle' ? "sid=" : "database=").$cfg->{database}.';'
			   ."host=".$cfg->{host}.';'
			   ."port=".$cfg->{port},
			$cfg->{username},
			$cfg->{password},
			{ RaiseError => 1,
			  (($cfg->{driver} eq 'Pg') ? (AutoCommit=>0) : ())
			}
		       );
    alarm(0);
    die "Connection failed" if not $self->{dbi};
  };
  alarm(0);
  die $@ if $@;
  return $self->{dbi};
}

sub run {
  my ($self,$opts)=@_;
  delete $self->{results};
  $opts||={};
  my $dbi  = $self->{dbi} || die "Not connected to DBI!\n";
  my $timeout = $opts->{timeout};
  my $driver_name = $self->sql_driver;
  my $t0 = new Benchmark;
  my $results = eval { $self->run_sql_query($self->{sth},{
    limit=>$opts->{limit},
    timeout => $timeout,
    raise_error =>1,
  }) };
  if ($@) {
    if (GUI()) {
      ErrorMessage($@);
      return;
    } else {
      my $err = $@;
      $err=~s/\n/ /g;
      if ($err =~ /^Query evaluation takes too long:/) {
	die "$self->{id}\tTIMEOUT\t".($timeout)."s\n";
      } else {
	die "$self->{id}\tFAIL\t$err\n";
      }
    }
    return;
  }
  my $t1 = new Benchmark;
  my $time = timestr(timediff($t1,$t0));
  my $no_results = $opts->{count} ? $results->[0][0]  : scalar(@$results);
  unless ($opts->{quiet}) {
    my $driver_name = $self->sql_driver;
    print "$self->{id}\tOK\t$driver_name\t$no_results\t$time\n";
  }
  return $self->{results}=$results;
}

sub idx_to_pos {
  my ($self,$idx_list)=@_;
  my @res;
  my @list=@$idx_list;
  while (@list) {
    my ($idx,$type)=(shift@list, shift@list);
    my $result = $self->run_sql_query(qq(SELECT "file", "sent_num", "pos" FROM ${type}_pos WHERE "idx" = $idx ).$self->serialize_limit(1),
			   { MaxRows=>1, RaiseError=>1 });
    $result = $result->[0];
    push @res, $result->[0].'##'.$result->[1].'.'.$result->[2];
  }
  return @res;
}

sub run_sql_query {
  my ($self, $sql_or_sth, $opts)=@_;
  my $dbi = $self->{dbi} || die "Not connected to DBI!\n";
  local $dbi->{RaiseError} = $opts->{RaiseError};
  require Time::HiRes;
  my $canceled = 0;
  my $driver_name = $self->sql_driver;
  my $sth = ref($sql_or_sth) ? $sql_or_sth : $dbi->prepare( $sql_or_sth,
							    $driver_name eq 'Pg' ? { pg_async => 1 } : ());
  if ($driver_name eq 'Pg') {
    my $step=0.05;
    my $time=0;
    eval {
      $sth->execute();
      if (defined $opts->{timeout}) {
	while (!$sth->pg_ready) {
	  $time+=$step;
	  Time::HiRes::sleep($step);
	  if ($time>=$opts->{timeout}) {
	    if (!GUI() or QuestionQuery('Query Timeout',
						   'The evaluation of the query seems to take too long',
						   'Wait another '.$opts->{timeout}.' seconds','Abort') eq 'Abort') {
	      $sth->pg_cancel();
	      die "Query evaluation takes too long: cancelled.\n"
	    } else {
	      $time=0;
	    }
	  }
	}
      }
      $sth->pg_result;
    };
    if ($@) {
      $dbi->rollback();
      die $@;
    }
  } else {
    eval {
      if (defined $opts->{timeout}) {
	require Sys::SigAction;
	my $h = Sys::SigAction::set_sig_handler( 'ALRM',
				 sub {
				   if (!GUI() or QuestionQuery('Query Timeout',
							       'The evaluation of the query seems to take too long',
							       'Wait another '.$opts->{timeout}.' seconds','Abort') !~ /Wait/) {
				     $canceled = 1;
				     my $res = $sth->cancel();
				     warn "Canceled: ".(defined($res) ? $res : 'undef');
				   } else {
				     alarm($opts->{timeout});
				   }
				 }, #dont die (oracle spills its guts)
				 { mask=>[ qw( INT ALRM ) ] ,safe => 0 }
				);
	alarm($opts->{timeout});
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
  return $sth->fetchall_arrayref(undef,$opts->{limit});
}

sub serialize_limit {
  my ($self, $limit)=@_;
  my $driver = $self->sql_driver;
  if ($driver eq 'Oracle') {
    return 'AND ROWNUM<='.$limit;
  } elsif ($driver eq 'Pg') {
    return 'LIMIT '.$limit.';';
  }
}


# serialize to SQL (or SQL fragment)
sub sql_serialize_conditions {
  my ($self,$node,$opts)=@_;
  $opts||={};
  if ($node->parent) {
    return [$self->sql_serialize_element({
      %$opts,
      name => 'and',
      condition => $node,
    })];
  } else {
    return $self->build_sql($node,{
      count=>$opts->{count},
      limit => $opts->{limit},
      syntax=>$opts->{syntax},
    });
  }
}

sub relation {
  my ($self,$id,$rel,$target,$opts)=@_;
  my $relation = $rel->name;
  my $params = $rel->value;
  if ($relation eq 'ancestor') {
    $relation = 'descendant';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'parent') {
    $relation = 'child';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'order-follows') {
    $relation = 'order-precedes';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'depth-first-follows') {
    $relation = 'depth-first-precedes';
    ($id,$target)=($target,$id);
  }
  my $cond;
  if ($relation eq 'user-defined') {
    return $self->user_defined_relation($id,$params,$target,$opts);
  } elsif ($relation eq 'descendant') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND $id."idx"!=$target."idx" AND }.
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
  } elsif ($relation eq 'child') {
    $cond = qq{$id."idx"=$target."parent_idx"};
  } elsif ($relation eq 'depth-first-precedes') {
    $cond = qq{$id."idx"<$target."idx"};
  } elsif ($relation eq 'order-precedes') {
    my $order; # FIXME: get the ordering attribute from the database
    if ($opts->{type} eq 'a') {
      $order = q(ord);
    } else {
      $order = q(tfa/deepord);
    }
    $cond =
      $self->sql_serialize_predicate(
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  expression => qq{\$$id.$order},
	},
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  expression => qq{\$$target.$order},
	},
	'<',$opts # there should be no ambiguity here, treat expressoins as positive
       );
  } else {
    die "Unsupported relation: $relation between nodes $id and $target\n";
  }
  return $cond;
}

sub user_defined_relation {
  my ($self,$id,$params,$target,$opts)=@_;
  my $relation=$params->{label};
  my $type = $opts->{type};
  my $cond;
  my $from_id = $opts->{id}; # view point
  if ($relation eq 'eparent') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND }.
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.eparents/eparent_idx},
	  negative=> $opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'echild') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND }.
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$target.eparents/eparent_idx},
	  negative=>$opts->{negative},
	},
	qq{$id."idx"},
	q(=),$opts,
       )
  } elsif ($relation eq 'a/lex.rf') {
    $cond =  qq{$id."a_lex_idx"=$target."idx"}
  } elsif ($relation eq 'a/aux.rf') {
    $cond = $self->sql_serialize_predicate(
      {
	id=>$from_id,
	type=>$type,
	join=>$opts->{join},
	expression => qq{\$$id.a_aux/a_idx},
	negative=>$opts->{negative},
      },
      qq{$target."idx"},
      qq(=),$opts,
     )
  } elsif ($relation eq 'a/lex.rf|a/aux.rf') {
    $cond =
      qq{($id."a_lex_idx"=$target."idx" OR }.
	$self->sql_serialize_predicate(
	  {
	    id=>$from_id,
	    type=>$type,
	    join=>$opts->{join},
	    expression => qq{\$$id.a_aux/a_idx},
	    negative=>$opts->{negative},
	  },
	  qq{$target."idx"},
	  qq(=),$opts,
	 ).')';
  } elsif ($relation eq 'coref_gram') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_gram/corg_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'coref_text') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_text/cort_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'compl') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.compl/compl_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  }
  return $cond;
}

sub build_sql {
  my ($self,$tree,$opts)=@_;
  $opts||={};
  my ($format,$count,$tree_parent_id) = map {$opts->{$_}} qw(format count parent_id limit);
  # we rely on depth first order!
  my @nodes = Tree_Query::FilterQueryNodes($tree);
  my @select;
  my @table;
  my @where;
  my %conditions;
  my $extra_joins = $opts->{join} || {};
  my $default_type = $opts->{type}||$tree->root->{'node-type'}||'a';
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $table = $n->{'node-type'}||$default_type;
    my $id = $self->{id_map}{$n};

    push @select, $id;
    my $parent = $n->parent;
    while ($parent and $parent->{'#name'} !~/^(?:node|subquery)$/) {
      $parent=$parent->parent
    }
    my $parent_id = $self->{id_map}{$parent};
    $conditions{$id} = Tree_Query::as_text($n);
    my @conditions;
    if ($parent && $parent->parent) {
      my ($rel) = SeqV($n->{relation});
      $rel ||= Tree_Query::SetRelation($n,'child');
      push @conditions,
	[$self->relation($parent_id,$rel,$id, {
	  %$opts,
	  id=>$id,
	  join => $extra_joins,
	  type=>($parent->{'node-type'}||$default_type)
	 }),$n];
      push @table,[$table,$id,$n];
    } else {
      push @table,[$table,$id,$n];
    }
    push @conditions,
      (map {
	[qq{$self->{id_map}{$_}."idx"}.
	   ($conditions{$id} eq $conditions{$self->{id_map}{$_}} ? '<' : '!=' ).
	     qq{${id}."idx"},$n] }
	 grep { #$_->parent == $n->parent
	   #  or
	   my $type=$_->{'node-type'}||$default_type;
	   $type eq $table and
	     (first { !$_->{optional} } $_->ancestors)==(first { !$_->{optional} } $n->ancestors)
	   }
	   map { $nodes[$_] } 0..($i-1));
    {
      my $conditions = $self->sql_serialize_conditions($n,{
	type=>$table,
	id=>$id,
	parent_id=>$parent_id,
	join => $extra_joins,
	syntax=>$opts->{syntax},
      });
      push @conditions, [$conditions,$n] if @$conditions;
    }
    # where could also be obtained by replacing ___SELF___ with $id
    if ($n->{optional}) {
      # identify with parent
      if (@conditions) {
	@conditions = ( [ [['(('], @{Tree_Query::_group(\@conditions,[' AND '])}, [qq{) OR $id."idx"=$parent_id."idx")}]], $n] );
      }
    }
    push @where, @conditions;
  }

  my @sql = (['SELECT ']);
  if ($count == 2) {
    push @sql,['count(DISTINCT '.$self->{id_map}{$tree}.'."idx")','space'];
  } elsif ($count) {
    push @sql,['count(1)','space'];
  } else {
    push @sql, (['DISTINCT '], map {
      my $n = $nodes[$_];
      (($_==0 ? () : [', ','space']),
       [$select[$_].'."idx"',$n],
       [' AS "'.$select[$_].'.idx"',$n],
       [q(, ').($nodes[$_]->{'node-type'}||$default_type).q('),$n],
       [' AS "'.$select[$_].'.type"',$n]
      )
    } 0..$#nodes);
  }
  # joins
  {
    my $i=0;
    for my $t (@table) {
      my ($tab, $name, $node)=@$t;
      push @sql, ($i++)==0 ? ["\nFROM\n  ",'space'] : [",\n  ",'space'];
      push @sql, ["$tab $name",$node];
      if ($extra_joins->{$name}) {
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  push @sql, [' ','space'], [qq($join_type JOIN $join_tab $join_as ON $join_on),$node]
	}
      }
    }
  }
  push @sql, [ "\nWHERE\n     ",'space'],@{Tree_Query::_group(\@where,[' AND '])};

  unless (defined($tree_parent_id) and defined($self->{id_map}{$tree}) 
	  or !defined($opts->{limit})) {
    push @sql, ["\n".$self->serialize_limit($opts->{limit})."\n",'space']
  }

  if ($format) {
    return Tree_Query::make_string_with_tags(\@sql,[$tree]);
  } else {
    return Tree_Query::make_string(\@sql);
  }
}

sub sql_serialize_expression_pt {# pt stands for parse tree
  my ($self,$pt,$opts,$extra_joins)=@_;
  my $this_node_id = $opts->{id};
  if (ref($pt)) {
    my $type = shift @$pt;
    if ($type eq 'ATTR' or $type eq 'REF_ATTR') {
      my ($id,$attr,$cmp);
      if ($type eq 'REF_ATTR') {
	$id = lc($pt->[0]);
	$pt=$pt->[1];
	die "Error in attribute reference of node $id in expression $opts->{expression} of node '$this_node_id'" 
	  unless shift(@$pt) eq 'ATTR'; # not likely
	$cmp = $self->cmp_subquery_scope($this_node_id,$id);
	if ($cmp<0) {
	  die "Node '$id' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
	}
      } else {
	$id=$this_node_id;
      }
      my $column = pop @$pt;
      my $table = $opts->{type};
      my $node_id = $id;
      for my $tab (@$pt) {
	next if $tab =~ /^[mw]$/;  # FIXME: hack
	my $prev = $id;
	my $j;
	if ($opts->{negative} or $cmp) {
	  $opts->{use_exists}=1;
	  $j=$extra_joins;
	} else {
	  $j=$opts->{join};
	}
	$j->{$node_id}||=[];
	my $i = @{$j->{$node_id}};
	$id.="_${tab}_$i";
	$table.="_$tab";
	push @{$j->{$node_id}},[$id,$table, qq($id."idx" = $prev."idx"), 'LEFT']; # should be qq($prev."$tab")
      }
      return qq( $id."$column" );
    } elsif ($type eq 'FUNC') {
      my $name = $pt->[0];
      my $args = $pt->[1];
      my $id;
      if ($name=~/^(?:descendants|lbrothers|rbrothers|sons|depth)$/) {
	if ($args and @$args==1 and !ref($args->[0]) and $args->[0]=~s/^\$//) {
	  $id = $args->[0];
	  if ($self->cmp_subquery_scope($this_node_id,$id)<0) {
	    die "Node '$id' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
	  }
	} elsif ($args and @$args) {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(\$node?)\n";
	} else {
	  $id=$this_node_id;
	}
	return ($name eq 'descendants') ? qq{$id."r"-$id."idx"}
	     : ($name eq 'lbrothers')   ? qq{$id."chord"}
	     : ($name eq 'rbrothers')   ? qq{$opts->{parent_id}."chld"-$id."chord"-1}
             : ($name eq 'sons')        ? qq{$id."chld"}
             : ($name eq 'depth')       ? qq{$id."lvl"}
             : die "Tree_Query internal error while compiling expression: should never get here!";
      } elsif ($name=~/^(?:lower|upper|length)$/) {
	if ($args and @$args==1) {
	  return uc($name).'('
	         .  $self->sql_serialize_expression_pt($args->[0],$opts,$extra_joins)
	         . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	}
      } elsif ($name eq 'substr') {
	if ($args and @$args>1 and @$args<4) {
	  my @args = map { $self->sql_serialize_expression_pt($_,$opts,$extra_joins) } @$args;
	  $args[1].='+1';
	  return 'SUBSTR('
	         .  join(',', @args)
	         . ')';
	} else {
	  die "Wrong arguments for function substr() in expression $opts->{expression} of node '$this_node_id'!\nUsage: substr(string,from,length?)\n";
	}
      }
    } elsif ($type eq 'EXP') {
      my $out.='(';
      while (@$pt) {
	$out.=$self->sql_serialize_expression_pt(shift @$pt,$opts,$extra_joins);
	if (@$pt) { # op
	  my $op = shift @$pt;
	  if ($op eq 'div') {
	    $op='/'
	  } elsif ($op eq 'mod') {
	    $op='%'
	  } elsif ($op eq '~') {
	    $op='||'
	  } elsif ($op !~ /[-+*]/) {
	    die "Urecognized operator '$op' in expression $opts->{expression} of node '$this_node_id'\n";
	  }
	  $out.=$op;
	}
      }
      $out.=')';
      return $out;
    }
  } else {
    if ($pt=~/^[-0-9']/) { # literal
      return qq( $pt );
    } elsif ($pt=~s/\$//) { # a plain variable
      if ($self->cmp_subquery_scope($this_node_id,$pt)<0) {
	die "Node '$pt' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
      }
      return qq( $pt."idx" );
    } else { # unrecognized token
      die "Token '$pt' not recognized in expression $opts->{expression} of node '$this_node_id'\n";
    }
  }
}

sub sql_serialize_expression {
  my ($self,$opts)=@_;

  my $pt = Tree_Query::parse_expression($opts->{expression}); # $pt stands for parse tree
  die "Invalid expression '$opts->{expression}' on node '$opts->{id}'" unless defined $pt;

  my $extra_joins={};
  my $out = $self->sql_serialize_expression_pt($pt,$opts,$extra_joins); # do not copy $opts here!

  my $wrap;
  if ($opts->{use_exists}) {
    my @from;
    my @where;
    for my $name (keys (%$extra_joins)) {
      if ($extra_joins->{$name}) {
	my $table;
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  if (defined $table) {
	    $table.=qq( $join_type JOIN $join_tab $join_as ON $join_on);
	  } else {
	    $table=qq($join_tab $join_as);
	    push @where, $join_on;
	  }
	}
	push @from,$table;
      }
    }
    if (@from) {
      $wrap='EXISTS (SELECT *'
	.' FROM '.join(', ',@from)
	.' WHERE '.join(' AND ',@where);
      $wrap=~s/%/%%/g;
      $wrap.=' AND ' if @where;
      $wrap.='%s )';
    }
  }
  return ($out,$wrap);
}

sub sql_serialize_predicate {
  my ($self,$L,$R,$operator,$opts)=@_;
  my ($left,$wrap_left) = ref($L) ? $self->sql_serialize_expression($L) : ($L);
  my ($right,$wrap_right) = ref($R) ? $self->sql_serialize_expression($R) : ($R);
  my $res;
  if ($operator eq '~' and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right)};
  } elsif ($operator eq '~*' and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right,'i')};
  } else {
    $res = $left.' '.uc($operator).' '.$right;
  }
  if (defined $wrap_right) {
    $res=sprintf($wrap_right,$res);
  }
  if (defined $wrap_left) {
    $res=sprintf($wrap_left,$res);
  }
  return $res;
}

sub sql_serialize_element {
  my ($self,$opts)=@_;
  my ($name,$node,$as_id,$parent_as_id)=map {$opts->{$_}} qw(name condition id parent_id);
  my $negative = $opts->{negative};
  $negative=!$negative if $name eq 'not';
  if ($name eq 'test') {
    return
      [$self->sql_serialize_predicate({%$opts,expression=>$node->{a},negative=>$negative},
				      {%$opts,expression=>$node->{b},negative=>$negative},
				      $node->{operator},
				      $opts),$node];
  } elsif ($name =~ /^(?:and|or|not)$/) {
    my @c =
      grep { @$_ }
      map {
	my $n = $_->{'#name'};
	$self->sql_serialize_element({
	  %$opts,
	  name => $n,
	  condition => $_,
	  id => $as_id,
	  parent_id => $parent_as_id,
	  negative=>$negative
	 })
      } grep { $_->{'#name'} ne 'node' } $node->children;
   return unless @c;
   return
     $name eq 'not' ? [[['NOT('],@{Tree_Query::_group(\@c,[' AND '])},[')']],$node] :
     $name eq 'and' ? [[['('],@{Tree_Query::_group(\@c,[' AND '])},[')']],$node] :
     $name eq 'or' ? [[['('],@{Tree_Query::_group(\@c,[' OR '])},[')']],$node] : ();
  } elsif ($name eq 'subquery') {
    my $subquery = $self->build_sql($node,{
      format => 1,
      count=>2,
      parent_id=>$opts->{id},
      join => $opts->{join},
      syntax=>$opts->{syntax},
    });
    my @sql;
    my @occ;
    my @vals = grep ref, AltV($node->{occurrences});
    @vals=(Fslib::Struct->new({min=>1})) unless @vals;
    for my $occ (@vals) { # this is not optimal for @occ>1
      my ($min,$max)=($occ->{min},$occ->{max});
      if (length($min) and length($max)) {
	if ($min==$max) {
	  push @occ,[[['('],@$subquery,[qq')=$min']],$node];
	} else {
	  push @occ,[[['('],@$subquery,[qq') BETWEEN $min AND $max']],$node];
	}
      } elsif (length($min)) {
	push @occ,[[['('],@$subquery,[qq')>=$min']],$node];
      } elsif (length($max)) {
	push @occ,[[['('],@$subquery,[qq')<=$max']],$node];
      }
    }
    return (@occ ? [[ ['('],@{Tree_Query::_group(\@occ,[' OR '])},[')'] ],$node] : ());
  } elsif ($name eq 'ref') {
    my $target = $node->{target};
    if ($self->cmp_subquery_scope($node,$target)<0) {
      die "Node '$as_id' belongs to a sub-query and cannot be referred from the scope of node '$target'\n";
    }
    my ($rel) = SeqV($node->{relation});
    if ($rel) {
      return ['('.$self->relation($as_id,$rel,$target,$opts).')',$node];
    } else {
      return;
    }
  } else {
    Carp::cluck "Unknown element $name ";
    return;
  }
}

sub cmp_subquery_scope {
  my ($self,$src,$target)=@_;
  $_ = ref($_) ? $_ : $self->{name2node}{$_} || croak("didn't find node $_")
    for $src,$target;
  return Tree_Query::cmp_subquery_scope($src,$target);
}

}

{

package Tree_Query::SQLSearch;
use Benchmark;
use Carp;
use strict;
use warnings;
use Scalar::Util qw(weaken);
BEGIN { import TredMacro  }

our %DEFAULTS = (
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
    query_nodes => undef,
    results => undef,
  }, $class;
  $self->configure($opts->{config_file},$opts->{config_id}) || return;
  $self->{callback} = [\&open_pmltq,$self];
  weaken($self->{callback}[1]);
  register_open_file_hook($self->{callback});
  return $self;
}

sub DESTROY {
  my ($self)=@_;
  warn "DESTROING $self\n";
  unregister_open_file_hook($self->{callback});
}

sub identify {
  my ($self)=@_;
  return "SQLSearch" unless $self->{config}{data};
  my $cfg = $self->{config}{data};
  return "SQLSearch $cfg->{driver}:$cfg->{username}\@$cfg->{host}:$cfg->{port}/$cfg->{database}";
}

sub configure {
  my ($self,$config_file,$id)=@_;
  $self->load_config_file($config_file) || return;
  my $configuration = $self->{config}{data};
  my $cfgs = $self->{config}{pml}->get_root->{configurations};
  my $cfg_type = $self->{config}{type};
  if (!$id) {
    my @opts = ((map { $_->{id} } ListV($cfgs)),' CREATE NEW ');
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
    $cfg = first { $_->{id} eq $id } ListV($cfgs);
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

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  my $query = $opts->{query} || $root;
  unless ($self->{evaluator}) {
    $self->{evaluator} = Tree_Query::SQLEvaluator->new($query,{connect => $self->{config}{data}});
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
  } else {
    $self->{evaluator}->prepare_query($query);
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
  my ($limit, $timeout) = map { int($opts->{$_}||$self->{config}{pml}->get_root->get_member($_))||$DEFAULTS{$_} }
    qw(limit timeout);

  my $results = $self->{evaluator}->run({
    limit => $limit,
    timeout => $timeout,
  });
  $self->{results} = $results;
  my $matches = @$results;
  if ($matches) {
    return $results unless QuestionQuery('Results',
					 ((defined($limit) and $matches==$limit) ? '>=' : '').
					   $matches.' match'.($matches>1?'(es)':''),
					 'Display','Cancel') eq 'Display';
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
      SetCurrentFileList($fl->name);
      GotoFileNo(0);
      ($this,$root,$grp)=@context;
      select_matching_node($this);
    }
  } else {
    QuestionQuery('Results','No results','OK');
  }
  return $results;
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

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my @matching;
  my $fn = $filename.'##'.($tree_number+1);
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () } @{$self->{current_result}};
  return @nodes[@positions];
}

sub select_matching_node {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  my $idx = Index($self->{last_query_nodes},$query_node);
  return if !defined($idx);
  my $result = $self->{current_result}->[$idx];
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


#########################################
#### Private API

sub filelist_name {
  my $self=shift;
  return ref($self).":".$self->{object_id};
}

sub show_result {
  my ($self,$dir)=@_;
  return unless $self->{evaluator};
  my $prev_grp = $grp;
  my @save = ($this,$root,$grp);
  my $fn = $self->filelist_name;
  for my $win (TrEdWindows()) {
    my $fl = GetCurrentFileList($win);
    if ($fl and $fl->name eq $fn) {
      eval {
	if ($dir eq 'prev') {
	  $grp=$win;
	  PrevFile();
	} elsif ($dir eq 'next') {
	  $grp=$win;
	  NextFile()
	} elsif ($dir eq 'current') {
	  return unless $self->{current_result};
	  my $idx = Index($self->{current_result},$this);
	  if (defined($idx)) {
	    $grp=$win;
	    my $source_dir = $self->get_source_dir;
	    Open($source_dir.'/'.$self->{current_result}[$idx]);
	    Redraw($win);
	  }
	}
      };
      ($this,$root,$grp)=@save;
      $self->select_matching_node($this);
      die $@ if $@;
      return;
    }
  }
  return;
}

# registered open_file_hook
# called by Open to translate URLs of the
# form pmltq//table/idx/table/idx ....  to a list of file positions
# and opens the first of the them
sub open_pmltq {
  my ($self,$filename,$opts)=@_;
  my $object_id=$self->{object_id};
  return unless $filename=~s{pmltq://$object_id/}{};
  my @positions = $self->{evaluator}->idx_to_pos([split m{/}, $filename]);
  $self->{current_result}=\@positions;
  my $fn = $self->filelist_name;
  my ($node) = map { CurrentNodeInOtherWindow($_) }
              grep { CurrentContextForWindow($_) eq $fn } TrEdWindows();
  my $idx = Index($self->{last_query_nodes},$node);
  my $first = $positions[$idx||0];
  print "$first\n";
  if (defined $first and length $first) {
    my $source_dir = $self->get_source_dir;
    $opts->{-norecent}=1;
    my $fsfile = Open($source_dir.'/'.$first,$opts);
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

sub edit_configuration {
  my ($self)=@_;
  my $config = $self->{config}{pml};
  GUI() && EditAttribute($config->get_root,'',
			 $config->get_schema->get_root_decl->get_content_decl) || return;
  $config->save();
}


my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
$DEFAULTS{dbi_config} = <<"EOF";
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
  <limit>$DEFAULTS{limit}</limit>
  <timeout>$DEFAULTS{timeout}</timeout>
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

} # SQL

} # use strict
1;
