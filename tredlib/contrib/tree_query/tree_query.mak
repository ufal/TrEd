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
#
# aggregating functions:
# max(count($x)) $y := [ eparent $x := [ ] ];
#  --> automatically group by $y

=comment

  (a) vypi¹te korpusové pozice t-uzlù reprezentujících osobní zájmena, jejich¾ antecedent ("pøedchùdce" ve smyslu textové koreference) je v jiné vìtì ne¾ dané zájmeno
 (b) spoèítejte, v kolika pøípadech je antecedent v té¾e vìtì, v kolika pøípadech je v pøedcházející, v kolika pøípadech pøedpøedcházející atd.

   t-node [ t_lemma='#PersPron', $r1:=ancestor t-root [],
     coref_text t-node [ $r2:=ancestor t-root [] ] ]
   >> tree_no($r1)-tree_no($r2) >> $1, count() per $1 >> sort by $1

or

   >> distribution(tree_no($r1)-tree_no($r2))


 (a) vypi¹te korpusové pozice t-uzlù, kde je pøísloveèné urèení místa nebo smìru (funktory LOC a DIR1-3) vyjádøeno pøedlo¾kovou skupinou,
 (b) spoèítejte, které pøedlo¾ky jsou pro tyto jednotlivé typy urèení místa nejèastìj¹í

  t-node [ functor~'^LOC|^DIR[1-3]', a/aux.rf a-node $a := [ afun='AuxP' ] ]
  >> $a/afun >> $1, count() per $1 sort decending by $2 >> top 5

 (a) vypi¹te korpusové pozice t-uzlù, které vyjadøují pøísloveèné urèení èasu, 
 (b) spoèítejte, kolik z nich je na morfologické rovinì vyjádøeno pøíslovcem

  t-node $x := [ functor='TWHEN' ]
  >> count($x)

  t-node $x := [ functor='TWHEN', a/lex.rf a-node [ m/tag~'^D' ] ]
  >> count($x)

 (a) vypi¹te korpusovou pozici/pozice t-stromu (stromù), které jsou v daném vzorku nejhlub¹í,
 (b) spoèítejte distribuci hloubky stromù (poèet stromù o hloubce 1, 2, atd.)

  (a)
     t-node $n := [ ] >> max(level($n)) >> $max;
     t-root [ 1+x descendant t-node [ level()=$max ] ];
  (b)
     t-root $r := [ descendant t-node $n := [ ] ]
     >> max(depth($n)) per $r
     >> $1, count() per $1 sort by $1

   select max,count(1) from (select max(n."#lvl") as max from "t-root" r, "t-node" n where r."#idx"=n."#root_idx" group by r."#idx") group by max order by max;

(a) vypi¹te korpusovou pozici/pozice t-stromu (stromù), které mají (z daného vzorku) nejvìt¹í poèet t-uzlù, 
(b) spoèítejte distribuci velikosti stromù vyjádøené poètem uzlù (tj. poèet stromù o velikosti 2 uzly, 3 uzly atd.)

  t-root $r := 
[ descendant t-node $n := [ ] ];
  >> count($n) per $r
  >> $1,count() per $1 sort by $1
 
 (a) vypi¹te korpusové pozice t-uzlù odpovídajících souøadicí spojce, která koordinuje sémantická substantiva (g/sempos=~/^n/),
 (b) spoèítejte, který funktor se vyskytuje jako èlen koordinace nejèastìji

  [ child $c := 
     [ is_member = 1, gram/sempos ~ '^n' ], nodetype = 'coap' ];
  >> $c.functor
  >> $1,count() per $1 sort by $1
 
 (a) vypi¹te korpusové pozice t-uzlù, které odpovídají koøenùm spojkových vedlej¹ích vìt, 
 (b) spoèítejte distribuci podøadicích spojek (tj. kolikrát se ve vzorku vyskytla spojka ¾e, spojka aby atd.)

  [ a/lex.rf a-node 
     [ m/tag ~ '^V' ], 
     a/aux.rf a-node $c := 
     [ afun = 'AuxC' ] ];
  >> $c.m/lemma
  >> $1,count() per $1 sort by $2
 
 (a) vypi¹te korpusové pozice t-uzlù, které odpovídají koøenùm vzta¾ných vedlej¹ích vìt, 
(b) spoèítejte distribuci vzta¾ných t-lemmat v tìchto vzta¾ných vìtách (kolikrát se vyskytlo které vzta¾né t-lemma kdo, který atd.)

 
 (a) vypi¹te korpusové pozice t-uzlù, které jsou na morfologické rovinì vyjádøeny pøíslovcem, 
 (b) spoèítejte distribuci funktorù na této mno¾inì (tj. kolikrát se který funktor vyskytl) 

=cut

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

register_reload_macros_hook(sub{
  undef @SEARCHES;
  undef $SEARCH;
});

Bind 'Tree_Query->NewQuery' => {
  context => 'TredMacro',
  key => 'Shift+F3',
  menu => 'New Tree Query',
};

# Edit node:
Bind 'EditNodeConditions' => {
  key => 'e',
  menu => 'Edit node conditions'
};
# Edit node:
Bind 'EditSubtree' => {
  key => 'E',
  menu => 'Edit subtree'
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

our @colors = qw(
66B032 ffff93740000 4a6d0133c830 b9f30175f2f0 0392CE ffffe1c90000
9655c9b94496 fef866282da3 007FFF C154C1 CC7722 FBFB00
00A86B fef8b3ca5b88 CCCCFF 8844AA 987654 F0E68C
BFFF00 E68FAC 00FFFF FFAAFF 996515 f3f6bdcb15f4
ADDFAD FFCBA4 007BA7 CC99CC B1A171 dddd00
6B8E23 FF8855 9BDDFF FF00FF 654321 FFFACD
00FF00 FF2400 1560BD 997A8D cd0da2373d4f FFFF77
D0EA2B b7ce1c6b0d0c E2F9FF  c1881d075743  0247FE 
);

Bind sub {
  my $node=$this;
  ChangingFile(0);
  return unless $node->parent;
  if ($node->{'#name'} eq 'node') {
    my $not = NewSon();
    $not->{'#name'}='not';
    DetermineNodeType($not);
    $this=$not;
    $node->{'.unhide'}=1;
  } elsif ($node->parent->{'#name'} eq 'not' and
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
  return unless $node->parent and $node->{'#name'} ne 'or';
  my $or;
  if ($node->{'#name'} eq 'node') {
    $or=NewSon();
    $this=$or;
    $node->{'.unhide'}=1;
  } else {
    $or = NewParent();
    $this=$node;
  }
  $or->{'#name'}='or';
  DetermineNodeType($or);
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
  return unless !$this->parent || $this->{'#name'}=~/^(?:node|subquery)$/;
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
  if (EditAttribute($new,undef,undef,'a')) {
#     $node->{'.unhide'}=1;
    $this=$new;
  } else {
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
  if ($this->{'#name'} eq 'node' and 
      $this->parent and $this->parent->{'#name'} =~ /^(?:node|subquery)$/) {
    $this->set_type(undef);
    $this->{'#name'}='subquery';
    DetermineNodeType($this);
  } elsif (!$this->{'#name'} eq 'subquery') {
    return;
  }
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
  menu => 'Toggle hiding of logical nodes for all nodes',
  changing_file => 0,
};

Bind sub {
  ChangingFile(0);
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($this,$this->ancestors);
  if ($qn) {
    $qn->{'.unhide'}=!$qn->{'.unhide'};
    $this=$qn;
  }
} => {
  key => 'h',
  menu => 'Toggle hiding of logical nodes for current node',
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

my $query_schema = PMLSchema->new({filename => 'tree_query_schema.xml',use_resources=>1});
 my %schema_map = (
#   't-node' => PMLSchema->new({filename => 'tdata_schema.xml',use_resources=>1}),
#   'a-node' => PMLSchema->new({filename => 'adata_schema.xml',use_resources=>1}),
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

our $__color_idx;
sub CreateStylesheets{
  unless(StylesheetExists('Tree_Query')){
    SetStylesheetPatterns(<<'EOF','Tree_Query',1);
context:   Tree_Query
hint: 
rootstyle:#{balance:1}#{Node-textalign:center}#{NodeLabel-halign:center}
rootstyle: #{vertical:0}#{nodeXSkip:40}
rootstyle: #{NodeLabel-skipempty:1}#{CurrentOval-width:3}#{CurrentOval-outline:red}
rootstyle: <? $Tree_Query::__color_idx=0;$Tree_Query::__color_idx2=1 ?>
node: #{blue(}<?length($${id}) ? $${id}.' ' : '' ?>#{)}<?length($${node-type}) ? $${node-type}.' ' : '' ?>#{darkblue}<?length($${name}) ? '$'.$${name}.' ' : '' ?>
label:#{darkgreen}<?
  my $occ = Tree_Query::occ_as_text($this);
  length $occ ? '#{-coords:n-10,n}#{-anchor:e}${occurrences='.$occ.'x}' : ""
?><? $${optional} ? '#{-coords:n-10,n}#{-anchor:e}${optional=?}'  : q()
?>
xxxnode: #{brown}<? my$d=$${description}; $d=~s{^User .*?:}{}; $d ?>
node:<?
  ($this->{'#name'} =~ /^(?:and|or|not)$/) ? uc($this->{'#name'}) : '' 
?>${a}${target}
node:<?
  if (($this->{'#name'}=~/^(?:node|subquery)$/) and !$this->{'.unhide'} and !TredMacro::HiddenVisible() ) {
    join("\n",map { Tree_Query::as_text($_,{indent=>'  ',wrap =>1}) } grep { $_->{'#name'} !~ /^(?:node|subquery|ref)$/ } $this->children)
  } elsif ($this->{'#name'} eq 'test') {
    '${operator}'
  } elsif ($this->{'#name'} eq '' and !$this->parent) {
     Tree_Query::as_text($this,{no_childnodes=>1,indent=>'  ',wrap =>1})
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
xlabel:<?
   if ($this->{'#name'} eq 'node'
      and !(grep { ($_->{'#name'}||'node') ne 'node' } $this->ancestors)) {
      '#{-clear:0}#{-coords:n,n}#{-anchor:center}'.$${color}
   }
?>
style:<?
   my $name = $this->{'#name'};
   if ($name eq 'node'
      and !(grep { ($_->{'#name'}||'node') ne 'node' } $this->ancestors)) {
     my $color = Tree_Query::NodeIndexInLastQuery($this);
     (defined($color) ? '#{Oval-fill:#'.$Tree_Query::colors[$color].'}' : '').
     '#{Node-addwidth:7}#{Node-addheight:7}#{Line-width:3}#{Line-arrowshape:14,18,4}'
   } elsif ($name eq 'node') {
     '#{Node-fill:brown}#{Node-addwidth:7}#{Node-addheight:7}#{Line-width:3}#{Line-arrowshape:14,18,4}'
   } elsif ($name eq 'test') {
    '#{NodeLabel-dodrawbox:yes}#{Line-fill:lightgray}#{Node-shape:rectangle}#{Oval-fill:gray}'
   } elsif ($name eq 'subquery') {
     '#{Node-shape:oval}'
   } elsif ($name eq 'ref') {
      '#{Node-shape:rectangle}'
   } elsif ($name =~ /^(?:or|and|not)$/) {
      '#{Node-shape:rectangle}#{Node-surroundtext:1}#{NodeLabel-valign:center}#{Oval-fill:cyan}'
   } else {
     '${Oval-fill:black}'
   }
?>
EOF
  }
}

sub DefaultQueryFile {
  return $ENV{HOME}.'/.tred.d/queries.pml';
}

sub NewQuery {
  use POSIX;
  my $id = POSIX::strftime('q-%y-%m-%d_%H%M%S', localtime());
  my $filename = DefaultQueryFile();
  ChangingFile(0);
  my $fl = first { $_->name eq 'Tree Queries' } TrEdFileLists();
  unless ($fl) {
    $fl = Filelist->new('Tree Queries');
    AddNewFileList($fl);
    $fl->add($filename);
  }
  if (CurrentFile()) {
    SplitWindowVertically();
    $Redraw='all';
  }
  unless (-f $filename) {
    unless (-d main::dirname($filename)) {
      mkdir main::dirname($filename);
    }
    my $fsfile = PMLInstance->load({
      filename => $filename,
      config   => $PMLBackend::config,
      string   => <<"END" })->convert_to_fsfile();
<?xml version="1.0" encoding="utf-8"?>
<tree_query xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
 <head>
  <schema href="tree_query_schema.xml" />
 </head>
 <q-trees>
  <LM id="$id"/>
 </q-trees>
</tree_query>
END
    push @main::openfiles, $fsfile;
    SetCurrentFileList($fl->name);
    ResumeFile($fsfile);
  } else {
    SetCurrentFileList($fl->name);
    Open($filename);
  }
  SelectSearch();
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
      if ($SEARCH and UNIVERSAL::can($SEARCH,'get_node_types')) {
	return $SEARCH->get_node_types;
      }
      return [sort keys %schema_map];
    }
  } elsif ($node->{'#name'} eq 'test') {
    if ($attr_path eq 'a') {
      my $schema;
      unless ($schema = get_query_node_schema($node)) {
	if (UNIVERSAL::isa($SEARCH,'Tree_Query::TrEdSearch')) {
	  my $file = $SEARCH->{file} || return;
	  my $fsfile = (first { $_->filename eq $file } GetOpenFiles()) || return;
	  $schema = PML::Schema($fsfile);
	}
      }
      return unless $schema;
      my @res = $schema->get_paths_to_atoms(undef,{ no_childnodes => 1 });
      return @res ? \@res : ();
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
  'echild' => '#22aa22',
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
      UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch') ? 
	  ($SEARCH->{evaluator} ? $SEARCH->{evaluator}->build_sql($tree,{format=>1})
	     : 'NO EVALUATOR')
	     : 'PLEASE SELECT SQL SEARCH';
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
    return 'stop' unless $target_type =~/^(?:node|subquery)$/
      and $type =~/^(?:node|subquery|ref)$/;
    return 'stop' if cmp_subquery_scope($node,$target)<0;
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
    if ($type eq 'node' or $type eq 'subquery') {
      init_id_map($node->root);
      AddOrRemoveRelations($node,$target,\@sel,{-add_only=>0});
      TredMacro::Redraw_FSFile_Tree();
      ChangingFile(1);
    } elsif ($type eq 'ref') {
      init_id_map($node->root);
      $node->{target}=GetNodeName($target);
      SetRelation($node,$sel[0]) if @sel;
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

# Helper routines

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
    } $node->type->schema->get_type_by_name('q-ref-relation.type')->get_content_decl->get_elements(),
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
  return unless $SEARCH;
  %is_match = %{$SEARCH->map_nodes_to_query_pos(FileName(),CurrentTreeNumber(),$root)};
}

sub NodeIndexInLastQuery {
  if ($SEARCH) {
    return $SEARCH->node_index_in_last_query(@_);
  }
  return;
}

sub GetSearch {
  my ($ident)=@_;
  return first { $_->identify eq $ident }  @SEARCHES;
}

sub Search {
  unless ($SEARCH) {
    SelectSearch() || return;
  }
  if (UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch')) {
    $SEARCH->search_first({edit_sql=>1});
  } else {
    $SEARCH->search_first();
  }
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
  my $S = GetSearch($sel);
  unless ($S) {
    if ($sel eq 'Search Remote Treebank Database') {
      $S=Tree_Query::SQLSearch->new();
    } elsif ($sel =~ /Search File: (.*)/) {
      $S=Tree_Query::TrEdSearch->new({file => $1});
    } elsif ($sel =~ /Search File list: (.*)/) {
      $S=Tree_Query::TrEdSearch->new({filelist => $1});
    }
  }
  if ($S) {
    my $ident = $S->identify;
    @SEARCHES = grep { $_->identify ne $ident } @SEARCHES;
    push @SEARCHES, $S;
    SetSearch($S);
  }
  # TODO
  #
  return $SEARCH;
}

sub SetSearch {
  my ($s) = @_;
  my $prev=$SEARCH && $SEARCH->identify;
  my $ident = $s && $s->identify;
  $SEARCH=$s;
  if ($ident ne $prev) {
    for my $name ($ident,$prev) {
      my $tb = GetUserToolbar($name);
      next unless $tb;
      my $lab = first { ref($_) eq 'Tk::Label' } $tb->children;
      $lab->configure(-font=> $name eq $ident ? 'C_small_bold' : 'C_small' ) if $lab;
    }
  }
}

sub CreateSearchToolbar {
  my ($ident)=@_;
  RemoveUserToolbar($ident);
  my $tb = NewUserToolbar($ident);
  for my $but (['(Re)start Search' =>
		  MacroCallback(
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->search_first;
		      }
		      ChangingFile(0);
		    }),
		'find',
	       ],
	       ['Next Match' =>
		  MacroCallback(
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->show_next_result;
		      }
		      ChangingFile(0);
		    }),
		'down',
	       ],
	       ['Previous Match' =>
		  MacroCallback(
		      sub{
			my $s = GetSearch($ident);
			if ($s) {
			  SetSearch($s);
			  $s->show_prev_result;
			}
			ChangingFile(0);
		      }),
		'up',
	       ],
	      ) {
    $tb->ImgButton(-text    => $but->[0],
		   -padleft => 15,
		   -padright => 15,
		   -padmiddle => 10,
		   -height => 32,
		   -command => $but->[1],
		   -font    =>'C_small',
		   -borderwidth => 0,
		   -takefocus=>0,
		   -relief => $main::buttonsRelief,
		   -image => main::icon($grp->{framegroup},'16x16/'.$but->[2]),
		   #		-compound => 'left',
		  )->pack(-side=>'left');
  }
  $tb->Label(-text=>$ident,-font=>'C_small')->pack(-side=>'left');
  $tb->Button(-text=>'x',
	      -font => 'C_small',
		-takefocus=>0,
	      -relief => $main::buttonsRelief,
	      -borderwidth=> $main::buttonBorderWidth,
	      -image => main::icon($grp->{framegroup},'16x16/remove'),
	      -command => MacroCallback(sub {
					  # DestroyUserToolbar($ident);
					  print "$ident\n";
					  my ($s) = grep { $_->identify eq $ident } @SEARCHES;
					  print "$s";
					  @SEARCHES = grep { $_ != $s } @SEARCHES;
					  $SEARCH = undef if $SEARCH and $SEARCH == $s;
					  ChangingFile(0);
					})
	     )->pack(-side=>'right');
  my $label;
  $tb->Label(-textvariable=>\$label,-font=>'C_small')->pack(-side=>'right');
  return ($tb,\$label);
}

sub EditNodeConditions {
  EditQuery($this,{no_childnodes=>1})
}
sub EditSubtree {
  EditQuery($this)
}

sub EditQuery {
  my ($node,$opts)=@_;

  $opts||={};

  my $no_childnodes = ($node->{'#name'} eq 'node' and $opts->{no_childnodes}) ? 1 : 0;
  my $string = as_text($node,{no_childnodes=>$no_childnodes});
  my $result;
  my $parser;
  {
    my $t0 = new Benchmark;
    $parser = query_parser();
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "creating parser took: $time\n";
  }
  my $qopts={};
  while ( defined ($string = EditBoxQuery('Edit query node', $string, '',$qopts)) ) {
    my $t0 = new Benchmark;
    eval {
      if (!$node->parent) {
	$result=$parser->parse_query($string);
      } elsif ($node->{'#name'} eq 'node') {
	$result=$parser->parse_node($string);
      } else {
	$result=$parser->parse_conditions($string); # returns ARRAY
      }
    };
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "parsing query took: $time\n";
    last unless $@;
    if (ref($@) eq 'Tree_Query::ParserError' ) {
      $qopts->{-cursor} = $@->line.'.end';
    }
    ErrorMessage("$@");
  }
  return unless $string;
  {
    my $t0 = new Benchmark;
    if ($node->parent) {
      my @c;
      if ($no_childnodes) {
	@c=map CutNode($_), grep { $_->{'#name'} eq 'node' } $node->children;
      }
      if (ref($result) eq 'ARRAY') {
	$_->paste_after($node) for @$result;
	DetermineNodeType($_) for @$result;
	$result=$result->[0];
      } else {
	$result->paste_after($node);
	DetermineNodeType($result);
	$result->{'.unhide'}=1 if $node->{'.unhide'};
      }
      $this=$result if $node==$this;
      DeleteSubtree($node);
      PasteNode($_,$result) for @c;
    } else {
      $node->{'output-filters'}=CloneValue($result->{'output-filters'});
      DeleteSubtree($_) for $node->children;
      CutPaste($_,$node) for reverse $result->children;
      DetermineNodeType($_) for ($node->descendants);
    }
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "postprocessing took: $time\n";
  }
}

### Query serialization

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
      ($opts->{no_childnodes} ? () : (map { (@{tq_serialize($_,$opts)},[";\n"]) } $node->children)),
      map {
	[join('',
	      '  >> ',
	      ($_->{distinct} ? ('distinct ')  : ()),
	      join(',',ListV($_->{return})),
	      (ListV($_->{'group-by'}) ? (' per ',join(',',ListV($_->{'group-by'})))  : ()),
	      (ListV($_->{'sort-by'}) ? (' sort by ',join(',',ListV($_->{'sort-by'})))  : ()),
	      "\n"
	     ), $node]
      } ListV($node->{'output-filters'})
     ]
  } else {
    my $copts = {%$opts,no_childnodes=>0,indent=>$indent."     "};
    if ($name eq 'subquery' or $name eq 'node') {
      $copts->{query_node}=$node;
    }
    my @r = map [tq_serialize($_,$copts)], 
      $opts->{no_childnodes} ? (grep { $_->{'#name'} ne 'node' } $node->children) : $node->children;
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
      my $type=$node->{'node-type'}; # get_query_node_type($node);
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
  my ($node,$opts)=@_;
  make_string(tq_serialize($node,$opts));
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

### Query parsing

my $parser;
sub query_parser {
  return $parser if defined $parser;
  my $Grammar = $libDir."/contrib/tree_query/Grammar.pm";
  delete $INC{$Grammar};
  require $Grammar;
  $Tree_Query::user_defined = 'echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_text|coref_gram|compl|val_frame';
  $parser = Tree_Query::Grammar->new() or die "Could not create parser for Tree_Query grammar\n";
  return $parser;
}
sub parse_query {
  shift if @_>1;
  my $ret = eval {query_parser()->parse_query($_[0])};
  confess($@) if $@;
  $ret->set_type($query_schema->find_type_by_path('!q-query.type'));
  DetermineNodeType($_) for ($ret->descendants);
  return $ret;
}
sub parse_expression {
  shift if @_>1;
  my $ret = eval { query_parser()->parse_expression($_[0]) };
  confess($@) if $@;
  return $ret;
}
sub parse_column_expression {
  shift if @_>1;
  my $ret = eval { query_parser()->parse_column_expression($_[0]) };
  confess($@) if $@;
  return $ret;
}



} # use strict
1;
