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
#
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
# - allow placeholders literals in tests:
#   m/lemma = ??
#   Before evaluating the query, the user is asked
#   to fill ?? for m/lemma, if empty, the test is ignored
#   The placeholder remains in the query, but the value
#   filled in by the user is kept somewhere, so that it is
#   the value pre-filled next time
#
#
# FIXME:
# - Escape after Insert
# - release with button <2>



package Tree_Query::Common; # so that it gets reloaded
package Tree_Query::SQLEvaluator; # so that it gets reloaded
package Tree_Query;
{
use strict;

BEGIN {
  use vars qw($this $root);
  import TredMacro;
  use PMLSchema qw(:constants);
  import PML qw(&SchemaName);
  use File::Spec;
  use Benchmark ':hireswallclock';
  use lib $main::libDir.'/contrib/tree_query';
  use Tree_Query::Common;
  import Tree_Query::Common qw(:all);
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

my @TOOLBAR_BINDINGS = (
  {
    command => sub {
      new_tree_after();
      $root->{id}=new_tree_id();
    },
    key => 'Ctrl+n',
    menu => 'Create a new query tree',
    toolbar => ['New query', 'filenew' ],
  },
  '---',
  {
    command => 'SelectSearch',
    key => 'c',
    menu => , 'Connect to search server or select file(s) to search',
    changing_file => 0,
    toolbar => ['Select search engine' , 'connect_creating' ],
  },
  {
    command => sub {
      unless ($SEARCH) {
	SelectSearch()||return;
      }
      if ($SEARCH->configure) {
	for (@SEARCHES) {
	  eval { $_->reconfigure } ; # various searches may share the same config file
	  ErrorMessage("$@") if $@;
	}
      }
    },
    key => 'C',
    menu => 'Configure search engine',
    changing_file => 0,
    toolbar => ['Configure' , 'configure' ],
  },
  '---',
#  "\n",
  {
    command => sub { $this=$root; EditSubtree() },
    key => 'Ctrl+e',
    menu => 'Edit complete query',
    toolbar => ['Edit query',  'edit_file'],
  },
  {
    command => 'EditNodeConditions',
    key => 'e',
    menu => 'Edit part of the query corresponding to the current node',
    toolbar => ['Edit node','edit_node' ],
  },
  {
    command => 'EditSubtree',
    key => 'E',
    menu => 'Edit part of the query corresponding to the current subtree',
    toolbar => ['Edit subtree', 'edit_subtree' ],
   },

  '---',

  {
    command => 'cut_to_clipboad',
    key => 'Ctrl+Delete',
    menu => 'Cut subtree to clipboard',
    toolbar => ['Cut',  'editcut'],
   },
  {
    command => 'copy_to_clipboad',
    key => 'Ctrl+Insert',
    menu => 'Copy subtree to clipboard',
    toolbar => ['Copy', 'editcopy'],
  },
  {
    command => sub { paste_from_clipboad(); copy_to_clipboad() },
    key => 'Shift+Insert',
    menu => 'Paste subtree from clipboard',
    toolbar => ['Paste', 'editpaste'],
  },
  '---',
  {
    command =>  sub {
      ChangingFile(0);
      my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($this,$this->ancestors);
      if ($qn) {
	$qn->{'.unhide'}=!$qn->{'.unhide'};
	$this=$qn;
      }
    },
    key => 'h',
    menu => 'Toggle hiding of logical nodes for current node',
    toolbar => ['(Un)hide','toggle_hide_subtree' ],
  },
  {
    command =>  'ToggleHiding',
    key => 'H',
    menu => 'Toggle hiding of logical nodes for all nodes',
    changing_file => 0,
    toolbar => ['(Un)hide all','toggle_hide_all' ],
  },

  "\n",

  {
   command => 'AddNode',
   key => 'Insert',
   menu => 'Create a new query node',
   toolbar => ['Add node', 'add_node'],
  },
  '---',
  {
    command => sub {
      my $node=$this;
      ChangingFile(0);
      return unless $node->parent;
      if ($node->{'#name'} =~ /^(node|subquery|and|or)$/) {
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
    },
    key => '!',
    toolbar => ['NOT','not' ],
    menu => 'Negate a condition',
  },
  {
    command => sub {
      my $node=$this;
      ChangingFile(0);
      return unless $node->parent and $node->{'#name'} =~ /^(?:not|or)$/;
      my $and = NewSon();
      $and->{'#name'}='and';
      DetermineNodeType($and);
      $this=$and;
      ChangingFile(1);
    },
    key => '&',
    menu => 'Add AND condition (under OR or NOT)',
    toolbar => ['AND','and' ],
  },
  {
    command => sub {
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
    },
    key => '|',
    menu => 'Add OR condition',
    toolbar => ['OR','or' ],
  },
  {
    command =>  'NewTest',
    key => '=',
    menu => 'Add a equality test',
    toolbar => ['Equality','test_equality' ],
  },
  {
    command =>  sub { NewTest('~')   },
    key => '~',
    menu => 'Add a regexp test',
    toolbar => ['Regexp','test_regexp' ],
  },
  '---',
  {
    command => sub {
      ChangingFile(0);
      return unless $this->{'#name'}=~/^(?:node|subquery)$/;
      EditAttribute($this,'name') && ChangingFile(1);
    },
    key => '$',
    menu => 'Edit node name',
    toolbar => ['Name','name_node' ],
  },
  {
    command => sub {
      return unless $this and $this->parent and $this->{'#name'} =~ /^(node|subquery)$/;
      $this->{'node-type'} ? EditAttribute($this,'node-type') : AssignType($this)
    },
    changing_file => 0,
    key => 'T',
    menu => 'Try automatically set the node type based on parent-node type',
    toolbar => ['Type','node_type' ],
  },
  {
    command => 'AssignRelation',
    key => 'r',
    changing_file => 0,
    menu => 'Edit relation of the current node to its parent',
    toolbar => ['Relation','relation' ],
  },
  '---',
  {
    command =>  sub {
      ChangingFile(0);
      unless ($this->parent and $this->parent->parent and $this->{'#name'} eq 'node') {
	QuestionQuery('Sorry',"Cannot make this node optional!",'Ok');
	return;
      }
      $this->{optional}=!$this->{optional};
      ChangingFile(1);
    },
    key => '?',
    menu => 'Toggle optional',
    toolbar => ['Optional','optional_node' ],
  },
  {
    command =>  sub {
      ChangingFile(0);
      if ($this->{'#name'} eq 'node' and
	    $this->parent and $this->parent->parent and $this->parent->{'#name'} =~ /^(?:node|subquery)$/) {
	if ($this->{optional}) {
	  QuestionQuery('Sorry',"Cannot set occurrences for an optional node!",'Ok');
	  return;
	}
	$this->set_type(undef);
	$this->{'#name'}='subquery';
	DetermineNodeType($this);
      }
      unless ($this->{'#name'} eq 'subquery') {
	QuestionQuery('Sorry',"Cannot set occurrences for this node!",'Ok');
	return;
      }
      if (not (AltV($this->{'occurrences'}))) {
	$this->{occurrences}=Fslib::Struct->new({min=>1});
      }
      if (EditAttribute($this,'occurrences')) {
	if (! first { defined && length } map { ($_->{min},$_->{max}) } AltV($this->{occurrences})) {
	  $this->set_type(undef);
	  $this->{'#name'}='node';
	  DetermineNodeType($this);
	}
	ChangingFile(1);
      }
    },
    key => 'x',
    menu => 'Edit occurrences on a subquery-node',
    toolbar => ['Occurrences','subquery' ],
  },
  '---',
  {
    command => 'DeleteNode',
    key => 'Delete',
    menu => 'Delete current node (pasting its children on its parent)',
    toolbar => ['Delete node', 'delete_node' ],
  },
  {
    command =>  'DeleteSubtree',
    key => 'Shift+Delete',
    menu => 'Delete current subtree',
    toolbar => ['Delete subtree', 'delete_subtree'],
  },
  '---',
  {
    command =>  sub { my $new = new_rbrother();
		      if ($new and $new->{'#name'} =~ /^(node|subquery)$/) {
			( $new->parent ? AssignRelation($new) : AssignType($new) ) || DeleteLeafNode($new);
		      }
		    },
    key => 'Alt+Right',
    menu => 'New right brother node',
    toolbar => ['Right brother', 'new_rbrother' ],
  },
  {
    command =>  sub { my $new = new_lbrother();
		      if ($new and $new->{'#name'} =~ /^(node|subquery)$/) {
			( $new->parent ? AssignRelation($new) : AssignType($new) ) || DeleteLeafNode($new);
		      }
		    },
    key => 'Alt+Left',
    menu => 'New left brother node',
    toolbar => ['Left brother','new_lbrother' ],
  },

  {
    command =>  sub { my $new = new_son();
		      if ($new and $new->{'#name'} =~ /^(node|subquery)$/) {
			( $new->parent ? AssignRelation($new) : AssignType($new) ) || DeleteLeafNode($new);
		      }
		    },
    key => 'Alt+Down',
    menu => 'New son node',
    toolbar => ['Son', 'new_son' ],
  },

  {
    command =>  sub { my $new = new_parent();
		      if ($new and $new->{'#name'} =~ /^(node|subquery)$/) {
			( $new->parent ? AssignRelation($new) : AssignType($new) ) || DeleteLeafNode($new);
		      }
		    },
    key => 'Alt+Up',
    menu => 'Insert a new node between the current node and its parent',
    toolbar => ['Parent', 'new_parent' ],
  },

 );

DeclareMinorContext 'Tree_Query_Results' => {
  pre_hooks => {
    root_style_hook => sub {
      map_results($root);
    },
  },
  post_hooks => {
    node_style_hook => sub {
      my ($node,$styles)=@_;
      my $m=$Tree_Query::is_match{$node};
      if (defined $m) {
	AddStyle($styles,'Oval',-fill => '#'.$Tree_Query::colors[$m]);
	AddStyle($styles,'Node',-addwidth=>3);
	AddStyle($styles,'Node',-addheight=>3);
      }
    }
   }
#text:<?    my $m=$Tree_Query::is_match{$this};    my $color =  defined($m) ? '#'.$Tree_Query::colors[$m] : CustomColor('sentence');   ($${m/w/token}eq$${m/form} ?     "#{$color}".'${m/w/token}' :   '#{-over:1}#{'.CustomColor('spell').'}['.     join(" ",map { $_->{token} } ListV($this->attr('m/w'))).  ']#{-over:0}'."#{$color}".'${m/form}') ?>
};

Bind({
  command => sub {
    ChangingFile(0);
    return unless !$this->parent || $this->{'#name'}=~/^(?:node|subquery)$/;
    EditAttribute($this,'node-type') && ChangingFile(1);
  },
  key => 't',
  menu => 'Edit node type',
});


for (grep ref, @TOOLBAR_BINDINGS) {
  Bind($_);
}

Bind paste_as_new_tree => {
  key => 'Ctrl+Shift+Insert',
  menu => 'Paste as new tree',
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
  menu => 'Run query',
  changing_file => 0,
};

Bind sub { Search({no_filters=>1}) } => {
  key => 'Shift+space',
  menu => 'Run query without output filters',
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


 my %schema_map = (
#   't-node' => PMLSchema->new({filename => 'tdata_schema.xml',use_resources=>1}),
#   'a-node' => PMLSchema->new({filename => 'adata_schema.xml',use_resources=>1}),
);


#include <contrib/support/extra_edit.inc>
#include <contrib/support/arrows.inc>

#unbind-key Alt+N
#unbind-key Alt+Up
#unbind-key Alt+Down
#unbind-key Alt+Left
#unbind-key Alt+Right
#remove-menu New tree
#unbind-key Alt+T
#remove-menu Trim (remove all but current subtree)

# Setup context
unshift @TredMacro::AUTO_CONTEXT_GUESSING,
sub {
  SchemaName() eq 'tree_query' ? __PACKAGE__ : undef ;
};

sub allow_switch_context_hook {
  return 'stop' if SchemaName() ne 'tree_query';
}

sub pre_switch_context_hook {
  my ($prev,$new)=@_;
  return if $prev eq $new;
  HideUserToolbar('Tree_Query');
}
# Setup stylesheet
sub switch_context_hook {
 my ($prev,$new)=@_;
 CreateStylesheets();
 SetCurrentStylesheet('Tree_Query'),Redraw()
   if GetCurrentStylesheet() ne 'Tree_Query'; #eq STYLESHEET_FROM_FILE();
 #  FileAppData('noautosave',1);
 print "switch_context_hook from $prev to $new\n";
# if ($prev ne $new) {
   if (GetUserToolbar('Tree_Query')) {
     unless (UserToolbarVisible('Tree_Query')) {
       ShowUserToolbar('Tree_Query');
     }
   } else {
     my $tb = NewUserToolbar('Tree_Query');
     my $frame = $tb->Frame()->pack(qw(-fill x));#qw(-side top -expand 1 -fill both));
     $frame->packPropagate;
     for my $binding (@TOOLBAR_BINDINGS) {
       if (ref($binding)) {
	 my $but = $binding->{toolbar};
	 return unless $but;
	 my $button = $frame->Button(
	   -command => MacroCallback($binding),
	   -padx => 2,
	   -font    =>'C_small',
	   -borderwidth => 0,
	   -takefocus=>0,
	   -relief => $main::buttonsRelief,
	   $but->[1] ? (-compound => 'top',
			-image => main::icon($grp->{framegroup},$but->[1]),
			-text  => $but->[0],
		       ) :
		       (
			 -text  => $but->[0]
		       )
		       )->pack(-side=>'left',-padx=>5);
	 my $tooltip = $binding->{menu} || '';
	 $tooltip .= qq{ ($binding->{key})} if $binding->{key};
	 AttachTooltip($button,$tooltip) if $tooltip;
       } elsif ($binding eq '---') {
	 $frame->Frame(-bd => 2, -width => 2, -relief => 'groove')
	   ->pack(-side=> 'left', -padx => '3', -fill => 'y', -pady => 3);
       } elsif ($binding eq "\n") {
	 $frame = $tb->Frame()->pack(qw(-fill x));#qw(-side top -expand 1 -fill both));
	 $frame->packPropagate;
       }
     }
   }
 # }
}
# sub file_reloaded_hook {
#   FileAppData('noautosave',1);
# }

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
context:  Tree_Query
hint: 
rootstyle:#{balance:1}#{Node-textalign:center}#{NodeLabel-halign:center}
rootstyle: #{vertical:0}#{nodeXSkip:40}#{skipHiddenLevels:1}
rootstyle: #{NodeLabel-skipempty:1}#{CurrentOval-width:3}#{CurrentOval-outline:red}
rootstyle: <? $Tree_Query::__color_idx=0;$Tree_Query::__color_idx2=1 ?>
node: <?length($${id}) ? '#{blue(}${id}#{)} ' : '' 
?><? 
  $this->{'#name'} =~ /^(node|subquery)$/ ?
   ( length($${node-type}) 
        ? $${node-type}.' ' : '#{red(}${node-type=NO_TYPE}#{)}' ) : () 
?>#{darkblue}<?length($${name}) ? '$'.$${name}.' ' : '' ?>
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
style: <? if ($this->parent) {
    if ($this->parent->{'#name'} eq 'or') {
      '#{Line-dash:-}'
     }
  } else {
     '#{Node-hide:1}'
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
    ( $this->{'.unhide'} ? '#{Node-shape:polygon}#{Node-polygon:-8,8,8,8,0,-8}' : '' ).
     (defined($color) ? '#{Oval-fill:#'.$Tree_Query::colors[$color].'}' : '').
     '#{Node-addwidth:7}#{Node-addheight:7}#{Line-width:3}#{Line-arrowshape:14,18,4}'
   } elsif ($name eq 'node') {
    ( $this->{'.unhide'} ? '#{Node-shape:polygon}#{Node-polygon:-8,8,8,8,0,-8}' : '' ).
     '#{Node-fill:brown}#{Node-addwidth:7}#{Node-addheight:7}#{Line-width:3}#{Line-arrowshape:14,18,4}'
   } elsif ($name eq 'test') {
    '#{NodeLabel-dodrawbox:yes}#{Line-fill:lightgray}#{Node-shape:rectangle}#{Oval-fill:gray}'
   } elsif ($name eq 'subquery') {
    ( $this->{'.unhide'} ? '#{Node-shape:polygon}#{Node-polygon:-4,4,4,4,0,-4}' : 
                                     '#{Node-shape:oval}' )
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

sub new_tree_id {
  use POSIX;
  POSIX::strftime('q-%y-%m-%d_%H%M%S', localtime());
}

sub NewQuery {
  SelectSearch() || return;

  my $id = new_tree_id();
  my $filename = DefaultQueryFile();
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
  GotoTree(scalar(GetTrees()));
  DetermineNodeType(NewTreeAfter()) if ($root->children);
  $root->{id}=$id;
  ChangingFile(0);
}


sub get_query_node_schema {
  my ($node)=@_;
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
  my $table = ($qn && $qn->{'node-type'})||$node->root->{'node-type'};
  return unless $table;
  return $schema_map{$table};
}

sub attr_validate_hook {
  my ($txt,$attr_path,$node)=@_;
  if ($node->{'#name'} eq 'test' and $attr_path eq 'a' or $attr_path eq 'b') {
    eval { query_parser()->parse_flat_expression($txt) };
    return $@ ? 0 : 1
  }
  return 1;
}

sub attr_choices_hook {
  my ($attr_path,$node,undef,$editor)=@_;
  return unless UNIVERSAL::isa($node,'FSNode');
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
      my $type = $SEARCH->get_type_decl_for_query_node($node);
      if ($type) {
	my @res = $type->get_paths_to_atoms({ no_childnodes => 1 });
	return @res ? \@res : ();
      }
    } elsif ($attr_path eq 'b') {
      if (UNIVERSAL::isa($SEARCH,'Tree_Query::HTTPSearch')) {
	my $name = $editor->get_current_value('a');
	if ($name and $name=~m{^(?:\$([[:alpha:]_][[:alnum:]_\-]*)\.)?([[:alpha:]_][[:alnum:]_/\-]*)$}) {
	  my $var = $1;
	  my $attr = $2;
	  if ($var) {
	    $node=first {
	      $_->{'name'} eq $var and
	      $_->{'#name'}=~/^(?:node|subquery)$/
	    } $node->root->descendants;
	  }
	  return unless $node;
	  my $decl = $SEARCH->get_type_decl_for_query_node($node);
	  if ($decl) {
	    $decl = $decl->find($attr);
	    my $decl_is = $decl->get_decl_type;
	    while ($decl_is == PML_ALT_DECL or
		   $decl_is == PML_LIST_DECL) {
	      $decl = $decl->get_content_decl;
	      $decl_is = $decl->get_decl_type;
	    }
	    if ($decl_is == PML_CHOICE_DECL or
		$decl_is == PML_CONSTANT_DECL) {
	      return [map { $_=~/\D/ ? qq{'$_'} : $_ } $decl->get_values];
	    }
	  }
	}
      } elsif (UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch')) {
	my $name = $editor->get_current_value('a');
	if ($name and $name=~m{^(?:\$[[:alpha:]_][[:alnum:]_/\-]*\.)?([[:alpha:]_][[:alnum:]_/\-]*)$}) {
	  my $attr = $1;
	  my $table = Tree_Query::Common::GetQueryNodeType($node,$SEARCH);
	  return unless $table=~m{^[[:alpha:]_][[:alnum:]_/\-]*$};
	  if ($attr=~s{^(.*)/}{}) {
	    my $t=$1;
	    $t=~s{/}{_}g;
	    $table=$table.'_'.$t;
	  }
	  my $sql = <<SQL;
SELECT * FROM (
  SELECT "$attr" FROM "${table}"
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

sub AssignRelation {
  shift unless ref $_[0];
  my $node = $_[0] || $this;
  return unless
    $node and
    $node->parent and ($node->{'#name'} =~ /^(node|subquery)$/ or ($node->{'#name'} eq 'ref' and $node->{target}));
  my ($rel) = map {
    $_->name eq 'user-defined' ?
      $_->value->{label}.' (user-defined)' : $_->name }
    SeqV($node->{relation});
  my @sel=($rel||'child');
  my $node_type = $node->parent->{'node-type'};
  my $relations =
    $SEARCH && $node_type ?
      [ grep {
	@{[GetRelativeQueryNodeType($node_type,
				 $SEARCH,
				 CreateRelation($_))]}>0
      } @{GetRelationTypes($node)}
     ] : GetRelationTypes($node);
  return unless @$relations;
  ListQuery('Select relation of the current node to its parent',
	    'browse',
	    $relations,
	    \@sel) || return;
  SetRelation($node,$sel[0]) if @sel;
  if (@sel and $sel[0] eq 'descendant' or $sel[0] eq 'ancestor') {
    EditAttribute($node,'relation/[1]'.$sel[0]) || return;
  }
  AssignType($node) || return;
#  } elsif (EditAttribute($node,'relation')) {
#    AssignType($node);
    ChangingFile(1);
#  }
  return 1;
}

sub AssignType {
  shift unless ref $_[0];
  my $node = $_[0] || $this;
  return 1 unless $SEARCH;
  return 1 if ( $node->parent && $node->{'#name'}!~/^(?:node|subquery)$/ );
  my @types = Tree_Query::Common::GetQueryNodeType($node,$SEARCH);
  if (@types <= 1) {
    $node->{'node-type'} = $types[0];
  } else {
    my @sel=$types[0];
    ListQuery('Select node type',
	      'browse',
	      \@types,
	      \@sel) || return;
    $node->{'node-type'}=$sel[0];
  }
  return 1;
}

#include "ng.inc"

# given to nodes or their IDs ($id and $ref)
# returns 0 if both belong to the same subquery
# returns 1 if $id is in a subquery nested in a subtree of $ref
# (and hence $ref can be referred to from $id)
# returns -1 otherwise


my %color = (
  'depth-first-precedes' => 'red3',
  'depth-first-follows' => 'red4',
  'order-precedes' => 'orange',
  'order-follows' => 'orange3',
  'a/lex.rf' => 'violet',
  'a/aux.rf' => 'thistle',
  'a/lex.rf|a/aux.rf' => 'tan',
  'val_frame.rf' => 'cyan',
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
  'depth-first-precedes' => 'first',
  'depth-first-follows' => 'first',
  'order-precedes' => 'first',
  'order-follows' => 'first',
  'a/lex.rf' => 'first',
  'a/aux.rf' => 'first',
  'a/lex.rf|a/aux.rf' => 'first',
  'val_frame.rf' => 'first',
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
  return unless $fsfile;
  my $tree = $fsfile->tree($tree_no);
  return unless $tree;

  my @nodes=($tree);
  my $node = $tree->firstson;
  my $next;
  while ($node) {
    if ($node->{'#name'} =~ /^(?:node|subquery)$/) {
      push @nodes,$node;
      $next=$node->following;
    } else {
      if ($show_hidden or
	    do {
	      my $p = $node->parent;
	      while ($p) { last if $p->{'#name'} =~ /^(?:node|subquery)$/; $p = $p->parent; }
	      $p && $p->{'.unhide'} ? 1 : 0
	    }) {
	push @nodes,$node;
	$next=$node->following;
      } else {
	$next=$node->following_right_or_up;
      }
    }
    $node=$next;
  }
  return [\@nodes,$prevcurrent];
}

my %legend;

sub root_style_hook {
  my ($root,$styles,$Opts)=@_;
  DrawArrows_init();
  init_id_map($root);
  %legend=();
  my @nodes = GetDisplayedNodes();
  my $hv = HiddenVisible();
  for my $node (@nodes) {
    my @refs;
    my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
    my $showHidden = $qn->{'.unhide'} || $hv;
    @refs = ($node) if $node->{'#name'} =~ /^(?:node|subquery|ref)$/;
    unless ($showHidden) {
      push @refs, grep { $_->{'#name'} eq 'ref' }
	map { $_->{'#name'} eq 'not' ? $_->children : $_ }
	  $node->children;
    }
    for my $n (@refs) {
      my ($rel) = map {
	my $name = $_->name;
	$name eq 'user-defined' ? $_->value->{label} : $name
      } SeqV($n->{relation});
      next unless $rel;
      if ($n!=$node and $n->parent->{'#name'} eq 'not') {
	$legend{'! '.$rel}=1
      } else {
	$legend{$rel}=1
      }
    }
  }
#  use Data::Dumper;
#  print Dumper(\%legend);
  my $tv = $grp->treeView;
  my $fh=$tv->getFontHeight;
  $tv->realcanvas->delete('legend');
  my $scale=$tv->scale_factor();
  $Opts->{baseYPos}+= $scale*(20 + $fh * (keys(%legend)
					    +
					  ($SEARCH ? 0 : 3)
					 ) );
}
sub after_redraw_hook {
  DrawArrows_cleanup();

  return if $SEARCH and !keys(%legend);
  my $tv = $grp->treeView;
  my $scale=$tv->scale_factor();
  my $c=$tv->realcanvas;
  my $fh = $grp->treeView->getFontHeight;
  my $y=$scale * 10;
  unless ($SEARCH) {
    $c->createText($scale * 15, $y,
		   -font => ($tv->get_scaled_font || $tv->get_font),
		   -text=> qq{NO SEARCH ENGINE SELECTED!\nEditing features will be limited. Press 'c' to select a search engine.},
		   -anchor=>'nw',
		   -tags=>['legend','text_item'] );
    $y+=$scale * 3* $fh;
  }
  for my $r ( sort keys %legend ) {
    my ($negate,$name) = ($r=~/^(!?\s*)(\S+)/);
    $c->createLine($scale * 75, $y, $scale * 15, $y,
		   -fill => $color{$name},
		   -width => 3*$scale,
		   (-dash => $negate ? '-' : ''),
		   -arrow => $arrow{$name},
		   -tags => ['scale_width','legend']
		  );
    $c->createText($scale * 85, $y, -font => ($tv->get_scaled_font || $tv->get_font),
		   # -fill => $color{$name},
		   -text=> $r, -anchor=>'w', -tags=>['legend','text_item'] );
    $y+=$scale * $fh;
  }
  my @b = $c->bbox('legend');
  $c->lower(
    $c->createRectangle(
      $b[0]-$scale * 5,$b[1],$b[2]+ $scale * 5,$b[3],
      -fill => 'lightyellow',
      -tags=>['legend'],
  ),'legend');

  %legend=();
}

sub node_style_hook {
  my ($node,$styles) = @_;
  my $i=0;
  my @refs;
  my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
  my $showHidden = $qn->{'.unhide'} || HiddenVisible();
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
    make_string_with_tags(tq_serialize($tree,{arrow_colors=>\%color}),[]) :
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
  if ($mod =~ /^(Control|Control-3|-2)$/) {
    my $type = $node->{'#name'};
    my $target_is = $target->{'#name'};
    return 'stop' unless $target_is =~/^(?:node|subquery)$/
      and $type =~/^(?:node|subquery|ref)$/;
    return 'stop' if cmp_subquery_scope($node,$target)<0;
    my @sel = map {
      my $name = $_->name;
      if ($name eq 'user-defined') {
	$_->value->{label}.qq( ($name))
      } else {
	$name
      }
    } map { SeqV($_->{relation}) }
      grep { $_->{target} eq $target->{name} }
      ($type eq 'ref' ? $node : (grep $_->{'#name'} eq 'ref', $node->children));
    my $node_type = $node->{'node-type'};
    my $target_type = $target->{'node-type'};
    my $relations =
      $SEARCH && $node_type && $target_type ?
      [ grep {
	first { $_ eq $target_type }
	  GetRelativeQueryNodeType($node_type,
				   $SEARCH,
				   CreateRelation($_))
	} @{GetRelationTypes($node)}
       ] : GetRelationTypes($node);
    return unless @$relations;
    ListQuery('Select query-node relations to add/preserve',
	      ($type eq 'ref' ? 'browse' : 'multiple'),
	      $relations,
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
      TredMacro::Redraw_FSFile_Tree();
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
	$rel_name = $val->{label}." ($rel_name)";
      }
      if ($opts->{-add_only}) {
	delete $types{$rel_name}; # already have it
      } elsif (!$types{$rel_name}) {
	DeleteLeafNode($ref);
      } else {
	delete $types{$rel_name}; # already have it
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
  shift unless ref($_[0]);
  my $opts=$_[0] || {};
  unless ($SEARCH) {
    SelectSearch() || return;
  }

  unless ($this->parent) {
    $this=first { $_->{'#name'} eq 'node' } $this->children;
  } else {
    my $non_node = first { $_->parent and $_->{'#name'} ne 'node' } reverse ($this, $this->ancestors);
    $this=$non_node->parent if $non_node;
  }

  if (UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch')) {
    $SEARCH->search_first({%$opts});
  } else {
    $SEARCH->search_first($opts);
  }
}

sub __this_module_path {
  return [caller(0)]->[1]
}

sub SelectSearch {
  my @sel;
  require Tk::DialogReturn;
  my $d = ToplevelFrame()->DialogBox(
    -title => 'Select search target',
    -cancel_button=>'Cancel',
    -buttons => ['Cancel'],
  );
  $d->BindEscape;
  my ($vol,$dir)=File::Spec->splitpath(__this_module_path());
  my @b;
  for my $b (['File' => 'file', 0, 0, 0],
	     ['File List' => 'filelist',0,1,5],
	     ['TreeQuery Server' => 'remote-db',1,0,0],
	     ['SQL Database' => 'local-db',1,1,0],
	    ) {
    my $but = $d->add('Button',
	    -compound=>'top',
	    -text => $b->[0],
	    -underline => $b->[4],
	    -image => $d->Photo(
	      -format=>'png',
	      -file => File::Spec->catfile(File::Spec->catpath($vol,$dir),'icons',$b->[1].'.png'),
	     ),
	    -highlightthickness => 3,
	    -command => [sub { $_[0]->{selected_button}=$_[1] },$d,$b->[0]],
	   );
    $but->grid(-column => $b->[3], -row => $b->[2]);
    $but->bind($d,'<Return>'=>'Invoke');
    push @b,$but;
  }
  for (0..$#b) {
    $b[$_]->bind('<Right>',[$b[ ($_+1) % (0+@b) ],'focus']);
    $b[$_]->bind('<Left>',[$b[ $_-1 ],'focus']);
    $b[$_]->bind('<Down>',[$b[ [2,3,1,0]->[$_] ],'focus']);
    $b[$_]->bind('<Up>',[$b[ [3,2,0,1]->[$_] ],'focus']);

  }

  $d->configure(-focus=>$b[0]);
  my $preserve=0;
  if ($SEARCH) {
    $d->add('Checkbutton',-variable => \$preserve,-underline=>0,-text=>'Preserve current search')
      ->grid(-column=>0,-columnspan=>2,-row=>3);
  }
  $d->BindButtons;
  my $choice = $d->Show;
  return if $choice eq 'Cancel';
  my $file;
  if ($choice=~/^File/) {
    my @sel;
    ListQuery('Search',
	      'browse',
	      [
		#  (map { $_->identify } @SEARCHES),
		$choice eq 'File' ? (map $_->filename, grep ref, map CurrentFile($_), TrEdWindows())
		: $choice eq 'File List' ? (map $_->name, TrEdFileLists())
		: return
		# 		(map { 'Search File list: '.$_->name } TrEdFileLists()),
		# 		(map { 'Search File: '.$_->filename } grep ref, map CurrentFile($_), TrEdWindows()),
		# 		'Search Using PMLTQ Server',
		# 		'Search Remote Treebank Database',
	       ],
	      \@sel
	     ) || return;
    return unless @sel;
    $file = $sel[0];
  }
  my $S;
  # my $S = GetSearch($sel);
  #  unless ($S) {
    if ($choice eq 'SQL Database') {
      $S=Tree_Query::SQLSearch->new();
    } elsif ($choice eq 'TreeQuery Server') {
      $S=Tree_Query::HTTPSearch->new();
    } elsif ($choice eq 'File') {
      $S=Tree_Query::TrEdSearch->new({file => $file});
    } elsif ($choice eq 'File List') {
      $S=Tree_Query::TrEdSearch->new({filelist => $file});
    }
  #  }
  if ($S) {
    if (!$preserve and $SEARCH) {
      DestroyUserToolbar($SEARCH->identify);
      @SEARCHES = grep { $_!=$SEARCH } @SEARCHES;
      $SEARCH=undef;
    }
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
  if (!defined($prev) or $ident ne $prev) {
    for my $name (grep defined, $ident,$prev) {
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
  for my $but (['Search' =>
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->search_first;
		      }
		      ChangingFile(0);
		    },
		'find',
		'Find first match (space)',
	       ],
	       ['Previous match' =>
		      sub{
			my $s = GetSearch($ident);
			if ($s) {
			  SetSearch($s);
			  $s->show_prev_result;
			}
			ChangingFile(0);
		      },
		'up',
		'Show previous match (p)',
	       ],
	       ['This match' =>
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->show_current_result;
		      }
		      ChangingFile(0);
		    },
		'apply',
		'Show corresponding node in the current match (m)',
	       ],
	       ['Next match' =>
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->show_next_result;
		      }
		      ChangingFile(0);
		    },
		'down',
		'Show next match (n)',
	       ],
	      ) {
    $tb->Button(-text  => $but->[0],
		-command => MacroCallback($but->[1]),
		-padx => 2,
		-font    =>'C_small',
		-borderwidth => 0,
		-takefocus=>0,
		-relief => $main::buttonsRelief,
		-image => main::icon($grp->{framegroup},'16x16/'.$but->[2]),
		-compound => 'top',
	       )->pack(-side=>'left',-padx => 5);
  }
  my $l = $tb->Label(-text=>$ident,-font=>'C_small')->pack(-side=>'left');
  $l->bind('<1>',
	   MacroCallback(
	     sub{
	       my $s = GetSearch($ident);
	       if ($s) {
		 SetSearch($s);
		 $s->show_current_result;
	       }
	       ChangingFile(0);
	     }),
	  );
  $tb->Button(-text=>'x',
	      -font => 'C_small',
		-takefocus=>0,
	      -relief => $main::buttonsRelief,
	      -borderwidth=> $main::buttonBorderWidth,
	      -image => main::icon($grp->{framegroup},'16x16/remove'),
	      -command => MacroCallback(sub {
					  DestroyUserToolbar($ident);
					  my ($s) = grep { $_->identify eq $ident } @SEARCHES;
					  @SEARCHES = grep { $_ != $s } @SEARCHES;
					  $SEARCH = undef if $SEARCH and $SEARCH == $s;
					  ChangingFile(0);
					})
	     )->pack(-side=>'right');
  my $label;
  $tb->Label(-textvariable=>\$label,-font=>'C_small')->pack(-side=>'right',-padx => 5);
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
  my $qopts={-cursor => 'end - 3 chars',
	     -init => sub {
	       my ($d,$ed)=@_;
	       my $f = $d->add('Frame')->pack(-side=>'top');
	       for (qw|! and or|,
		    [q|"..."|=>q|""|],
		    [q|'...'|=>q|''|],
		    qw| [] () |,
		    'in { }',
		    qw|? >> |,
		    "\n",
		    qw|= ~ ^ $ |,
		    q|$n :=|,
		    qw|< > + - * / |,
		    ['& (concat)' => '&']
		   ) {
		 if ($_ eq "\n") {
		   $f = $d->add('Frame')->pack(-side=>'top');
		   next;
		 }
		 my ($label,$value)=ref($_) ? @$_ : ($_,$_);
		 $f->Button(-text => $label,
			    ($label=~/([[:alpha:]])/ ? (-underline => $-[0]) : ()),
			    -command => [ sub { $_[0]->Insert($_[1]=~/\$|\^/ ? $_[1] : ' '.$_[1].' ');
						$_[0]->SetCursor('insert -2 chars') if $_[1]=~/["'[({]/;
						}, $ed, $value
					 ]
			   )->pack(-side=>'left');
	       }
	       $f = $d->add('Frame')->pack(-side=>'top');
	       for my $mb (
		 [Relation => GetRelationTypes($this)],
		 [Type => $SEARCH ? $SEARCH->get_node_types : []],
		 [Function => [map { $_.'()' }
				 qw( descendants lbrothers rbrothers sons depth_first_order
				     depth lower upper length substr tr replace ciel floor
				     round trunc percnt name file tree_no position
				     min max sum avg count ratio concat)]]
		) {
		 my $menubutton = $f->Menubutton(
		   -text => $mb->[0],
		   -underline => 0,
		   -relief => 'raised',
		   -direction => 'below',
		  )->pack(-side=>'left');
		 my $menu = $menubutton->menu(-tearoff => 0);
		 $menubutton->configure(-menu => $menu);
		 for (@{$mb->[1]}) {
		   $menubutton->command(-label => $_,
					-command => [$ed,'Insert',' '.$_.' ']
				       );
		 }
	       }
	       $d->BindButtons;
	     },
	   };
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
	@c=map CutNode($_), grep { $_->{'#name'} eq 'node' } reverse $node->children;
      }
      if (ref($result) eq 'ARRAY') {
	$_->paste_after($node) for @$result;
	DetermineNodeType($_) for map { ($_,$_->descendants) } @$result;
	$result=$result->[0];
      } else {
	$result->paste_after($node);
	DetermineNodeType($_) for ($result,$result->descendants);
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

sub NewTest {
  my ($op)=@_;
  $op='=' if $op !~ /^[=~]$/;
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
  $new->{operator}=$op;
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
}

sub AddNode {
  my $node=$this;
  return unless $node;
  my $new;
  if (!$node->parent or $node->{'#name'} =~ /^(?:node|subquery)/) {
    $new = NewSon();
    $new->{'#name'}='node';
    DetermineNodeType($new);
  } elsif ($node->{'$name'}=~/^(?:test|ref)/) {
    $new = NewRBrother();
    $new->{'#name'}=$node->{'#name'};
    DetermineNodeType($new);
  } else {
    $new = NewSon();
    DetermineNodeType($new);
  }
  if ($new) {
    unless ($node->parent ? AssignRelation($new) : AssignType($new)) {
      DeleteLeafNode($new);
      $this=$node;
    }
  }
}

sub DeleteNode {
  my $node=$this;
  return unless $node;
  unless ($node->parent) {
    return if $node->firstson
      and (QuestionQuery("Really delete tree?",
			 "Do you want to delete the whole query tree?",
			 "Delete","Cancel") ne 'Delete');
    DestroyTree();
  }
  my $p = $node->parent && $node->parent->parent;
  if ($node->{'#name'} =~ /^(?:node|subquery)/) {
    DeleteSubtree($_) for grep { !($_->{'#name'} eq 'node'
				     or ($p && $_->{'#name'} eq 'subquery')) }
      $node->children;
  }
  delete_node_keep_children($node);
}


} # use strict
1;
