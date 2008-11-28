# -*- cperl -*-

#include <contrib/pml/PML.mak>

package Tree_Query::Common; # so that it gets reloaded
package Tree_Query::NG2PMLTQ; # so that it gets reloaded
package Tree_Query::SQLEvaluator; # so that it gets reloaded
package Tree_Query;
{
use strict;

use vars qw($this $root);
BEGIN {
  import TredMacro;
  import PML qw(&SchemaName);
}

use PMLSchema qw(:constants);
use File::Spec;
use Benchmark ':hireswallclock';

use lib CallerDir();

use Tree_Query::Common qw(:all);
use Tree_Query::NG2PMLTQ qw(ng2pmltq);

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
our $ng_string;

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
  {
    command => sub {
      my $res = EditBoxQuery('NetGraph Import', $ng_string,
			     'Insert or paste a query in the syntax of NetGraph:');
      return unless defined $res and length $res;
      $ng_string = $res;
      my $string = ng2pmltq($ng_string);
      new_tree_after();
      $root->{id}=new_tree_id();
      $root->{description} = 'Imported from NetGraph';
      unless (EditQuery($root,{string=>$string})) {
	DeleteNode();
	ChangingFile(0);
      }
    },
    menu => 'Import query from NetGraph',
    toolbar => ['Import', 'netgraph_client' ],
  },
  '---',
  {
    command => 'SelectSearch',
    key => 'c',
    menu => , 'Select file(s) to search or connect to a search server',
    changing_file => 0,
    toolbar => ['Connect' , 'connect_creating' ],
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
  {
    command => sub { $this=$root;
		     ChangingFile(0);
		     init_id_map($root,1);
		     Redraw() if $TredMacro::FileChanged==1;
		     EditSubtree();
		   },
    key => 'f',
    menu => 'Edit output filters',
    toolbar => ['Filters','filter' ],
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
    menu => 'Expand/hide auxiliary and logical nodes for current node',
    toolbar => ['(Un)Expand','toggle_hide_subtree' ],
  },
  {
    command =>  sub {
      ToggleHiding();
      unless (HiddenVisible()) {
	delete $_->{'.unhide'} for $root->descendants;
      }
    },
    key => 'H',
    menu => 'Expand/hide auxiliary and logical nodes for all nodes',
    changing_file => 0,
    toolbar => ['(Un)Expand all','toggle_hide_all' ],
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
    command => 'AddNOT',
    key => '!',
    toolbar => ['NOT','not' ],
    menu => 'Negate a condition',
  },
  {
    command => 'AddAND',
    key => 'a',
    menu => 'Add AND condition (under an OR or NOT)',
    toolbar => ['AND','and' ],
  },
  {
    command => 'AddOR',
    key => 'o',
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
      ChangingFile(0);
      return unless $this and $this->parent and $this->{'#name'} =~ /^(node|subquery)$/;
      $this->{'node-type'} ? EditAttribute($this,'node-type') : AssignType($this)
    },
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
      my $orig_name = $this->{'#name'};
      if ($orig_name eq 'node' and
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
      local $main::sortAttrs=0;
      if (EditAttribute($this,'occurrences')) {
	if (! defined first { defined && length } map { ($_->{min},$_->{max}) } AltV($this->{occurrences})) {
	  $this->set_type(undef);
	  $this->{'#name'}='node';
	  delete $this->{occurrences};
	  DetermineNodeType($this);
	}
	ChangingFile(1);
      } elsif ($orig_name ne $this->{'#name'}) {
	$this->{'#name'}=$orig_name;
	DetermineNodeType($this);
	if ($orig_name eq 'node') {
	  delete $this->{occurrences};
	}
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
    toolbar => ['Brother', 'new_rbrother' ],
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

DeclareMinorMode 'Tree_Query_Results' => {
  abbrev => 'reslt',
  bindings => {
    'n' => sub { $SEARCH && $SEARCH->show_next_result },
    'p' => sub { $SEARCH && $SEARCH->show_prev_result },
  },
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
    },
    get_value_line_hook => sub {
      my ($fsfile,$no)=@_;
      map_results($fsfile->tree($no),$fsfile->filename,$no);
      if (!defined $_[-1]) {
	# value line not supplied by hook, we provide the standard one
	$_[-1] = $grp->treeView->value_line($fsfile,$no,1,1,$grp);
      }
      my $vl =  $_[-1];
      if (ref $vl) {
	my $m;
	for my $item (@$vl) {
	  for (@$item[1..$#$item]) {
	    if (defined($m=$Tree_Query::is_match{$_})) {
	      # print "match: $m $_\n";
	      @$item = $item->[0],grep !/^-foreground => /, @$item[1..$#$item];
	      push @$item,'-foreground => #'.$Tree_Query::colors[$m];
	      last;
	    }
	  }
	}
      }
      # return $vl;
    },
  }
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
Bind({
    command =>  sub { my $new = new_lbrother();
		      if ($new and $new->{'#name'} =~ /^(node|subquery)$/) {
			( $new->parent ? AssignRelation($new) : AssignType($new) ) || DeleteLeafNode($new);
		      }
		    },
    key => 'Alt+Left',
    menu => 'New left brother node',
    # toolbar => ['Left brother','new_lbrother' ],
  });

for (grep ref, @TOOLBAR_BINDINGS) {
  Bind($_);
}

Bind AutoNameAllNodes => {
  key => 'A',
  menu => 'Automatically assign a name to all nodes',
};

Bind AddAND => {
  key => 'a',
  menu => 'Add AND condition (under an OR or NOT)',
};

Bind AddOR => {
  key => 'o',
  menu => 'Add OR condition',
};

Bind paste_as_new_tree => {
  key => 'Ctrl+Shift+Insert',
  menu => 'Paste as new tree',
};

Bind sub {
  for (reverse sort_children_by_node_type($this)) {
    CutPaste($_,$this);
  }
} => {
  key => 's',
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

#define no_extra_edit_menu_bindings
#include <contrib/support/extra_edit.inc>
#undefine no_extra_edit_menu_bindings

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

sub get_status_line_hook {
  return 'To create an additional edge (relation), drag a start node over the target node using mouse and hold CTRL before releasing.';
}

sub pre_switch_context_hook {
  my ($prev,$new,$win)=@_;
  return if $prev eq $new;
  return if $grp==$win and $grp!=CurrentWindow();
  if (first { $win!=$_ and CurrentContextForWindow($_) eq 'Tree_Query' } TrEdWindows()) {
    DisableUserToolbar('Tree_Query');
  } else {
    HideUserToolbar('Tree_Query');
  }
}
# Setup stylesheet
sub switch_context_hook {
 my ($prev,$new)=@_;
 CreateStylesheets();
 SetCurrentStylesheet('Tree_Query'),Redraw()
   if GetCurrentStylesheet() ne 'Tree_Query'; #eq STYLESHEET_FROM_FILE();
 #  FileAppData('noautosave',1);
# if ($prev ne $new) {
   if (GetUserToolbar('Tree_Query')) {
     unless (UserToolbarVisible('Tree_Query')) {
       ShowUserToolbar('Tree_Query');
     }
     EnableUserToolbar('Tree_Query');
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
node: <? !$this->parent ? "Tree Query" : () ?>
node: <?length($${id}) ? ' #{blue(}${id}#{)} ' : '' 
?><? 
  $this->{'#name'} =~ /^(node|subquery)$/ ?
   ( length($${node-type}) 
        ? $${node-type}.' ' : $root->{'node-type'} ? '#{brown(}${node-type='.$root->{'node-type'}.'}#{)}' : '#{red(}${node-type=AMBIGUOUS TYPE}#{)}' ) : () 
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
    join("\n",map { Tree_Query::as_text($_,{indent=>'  ',wrap =>1}) } 
       grep {
	my $f;
	not(
	  $_->{'#name'} eq 'ref' or
	  ($_->{'#name'} eq 'not' and $f=$_->firstson and $f->{'#name'} eq 'ref' and !$f->rbrother)) }
       grep { $_->{'#name'} !~ /^(?:node|subquery|ref)$/ } $this->children)
  } elsif ($this->{'#name'} eq 'test') {
    '${operator}'
  } elsif ($this->{'#name'} eq '' and !$this->parent) {
     my $filters = Tree_Query::as_text($this,{no_childnodes=>1, indent=>'  ',wrap =>1});
     $filters=~s/([ \t]*>>)/Output filters:\n$1/; $filters
  }
?>
node:${b}
style: <? 
  my $name = $this->{'#name'};
  if ($this->parent->parent) {
    if ($name =~ /^(?:node|subquery|ref)$/) {
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
  } else {
    '#{Line-coords:n,n,n,n}'
  }
?>
style: <? if ($this->parent) {
    if ($this->parent->{'#name'} eq 'or') {
      '#{Line-dash:8,2}'
     }
  } else {
     '#{Node-shape:rectangle}#{Node-surroundtext:1}#{Oval-fill:white}#{NodeLabel-valign:center}'
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
     '#{Node-addheight:7}#{Line-arrowshape:14,20,4}'
   } elsif ($name eq 'node') {
    ( $this->{'.unhide'} ? '#{Node-shape:polygon}#{Node-polygon:-8,8,8,8,0,-8}' : '' ).
     '#{Node-fill:brown}#{Line-arrowshape:14,20,4}'
   } elsif ($name eq 'test') {
    '#{NodeLabel-dodrawbox:yes}#{Line-fill:lightgray}#{Node-shape:rectangle}#{Oval-fill:gray}'
   } elsif ($name eq 'subquery') {
    ( $this->{'.unhide'} ? '#{Node-shape:polygon}#{Node-polygon:-4,4,4,4,0,-4}' : 
                                     '#{Node-shape:oval}' ).'#{Line-arrowshape:14,20,4}'
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
  my $id = new_tree_id();
  my $filename = DefaultQueryFile();
  my $fl = first { $_->name eq 'Tree Queries' } TrEdFileLists();
  unless ($fl) {
    $fl = Filelist->new('Tree Queries');
    $fl->add(0,$filename);
    AddNewFileList($fl);
  }
  if (CurrentFile() and $root and GetCurrentFileList() && GetCurrentFileList()->name ne 'Tree Queries'
	and PML::SchemaName() ne 'tree_query') {
    my $win = SplitWindowVertically({no_init => 1, no_redraw=>1,no_focus=>0,ratio=>-0.5});
    # SetCurrentWindow($win);
    $grp=$win;
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
  SelectSearch() || return;
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
      my $type = $SEARCH && $SEARCH->get_type_decl_for_query_node($node);
      if ($type) {
	my @res = sort $type->get_paths_to_atoms({ no_childnodes => 1 });
	return @res ? \@res : ();
      }
    } elsif ($attr_path eq 'b') {
      if (UNIVERSAL::isa($SEARCH,'Tree_Query::SQLSearch')) {
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
	  my @res= sort map qq('$_->[0]'),@$results;
	  return @res ? \@res : ();
	}
      } elsif (UNIVERSAL::can($SEARCH,'get_type_decl_for_query_node')) {
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
	      return [sort map { $_=~/\D/ ? qq{"$_"} : $_ } $decl->get_values];
	    }
	  }
	}
      }
    }
  }
  return;
}

my %id;
my %name2node_hash;
sub init_id_map {
  my ($tree,$assign_names)=@_;
  # assign_names == 1 means actually set name for the nodes in the current subquery
  # assign_names == 2 means actually set name for all nodes
  my @nodes = grep { $_->{'#name'} =~ /^(?:node|subquery)$/ } $tree->descendants;
  my %main_query_nodes;
  if (defined($assign_names) and $assign_names==1) {
    %main_query_nodes;
    @main_query_nodes{ Tree_Query::Common::FilterQueryNodes($tree) } = ();
  }
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
      if (defined($assign_names) and ($assign_names==2 or exists $main_query_nodes{$n})) {
	$n->{name}=$id;
	ChangingFile(1);
      }
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
    $i++ while (exists $name2node_hash{"n$i"});
    my $name = "n$i";
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
    local $main::sortAttrs=0;
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
  'same-tree-as' => 'gray',
  'depth-first-precedes' => 'red3',
  'depth-first-follows' => 'red4',
  'order-precedes' => 'orange',
  'order-follows' => 'orange3',
  'a/lex.rf' => 'violet',
  'a/aux.rf' => 'thistle',
  'a/lex.rf|a/aux.rf' => 'tan',
  'p/terminal.rf' => 'navy',
  'p/nonterminals.rf' => 'darkgreen',

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
  'same-tree-as' => 'first',
  'depth-first-precedes' => 'first',
  'depth-first-follows' => 'first',
  'order-precedes' => 'first',
  'order-follows' => 'first',
  'a/lex.rf' => 'first',
  'a/aux.rf' => 'first',
  'a/lex.rf|a/aux.rf' => 'first',
  'p/terminal.rf' => 'first',
  'p/nonterminals.rf' => 'first',
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
  my $current = $tree;
  while ($node) {
    $current=$node if $node==$prevcurrent;
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
  return [\@nodes,$current];
}

my (%legend,%main_query);

sub root_style_hook {
  my ($root,$styles,$Opts)=@_;
  DrawArrows_init();
  init_id_map($root);
  %legend=();
  my @nodes = GetDisplayedNodes();
  my $hv = HiddenVisible();
  %main_query = map { $_=>1 } Tree_Query::Common::FilterQueryNodes($root);
  for my $node (@nodes) {
    my @refs;
    my $qn = first { $_->{'#name'} =~ /^(?:node|subquery)$/ } ($node,$node->ancestors);
    my $showHidden = $qn->{'.unhide'} || $hv;
    @refs = ($node) if $node->{'#name'} =~ /^(?:node|subquery|ref)$/ and
      $node->parent and $node->parent->parent;
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
      $rel||='child' if $n==$node;
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
					    +
					  ($root && $root->firstson ? 0 : 3)
					 ) );
}
sub after_redraw_hook {
  return unless $root;
  DrawArrows_cleanup();

  return if $SEARCH and !keys(%legend) and ($root and $root->firstson);
  my $tv = $grp->treeView;
  my $scale=$tv->scale_factor();
  my $c=$tv->realcanvas;
  my $fh = $grp->treeView->getFontHeight;
  my $y=$scale * 10;
  my $hint='';
  if (!$SEARCH) {
    $hint .= qq{NO SEARCH ENGINE SELECTED!\nEditing features will be limited. Press 'c' to select a search engine.\n}
  }
  unless ($root and $root->firstson) {
    $hint .= qq{\n} if $hint;
    $hint .= qq{QUERY IS EMPTY!\nPressing 'Insert' to create the first query node, or 'e' to open the query editor!\n}
  }
  if (length $hint) {
    chomp $hint;
    $c->createText($scale * 15, $y,
		   -font => ($tv->get_scaled_font || $tv->get_font),
		   -text=> $hint,
		   -anchor=>'nw',
		   -tags=>['legend','text_item'] );
    $y+=$scale * (2+($hint=~y/\n/\n/)) * $fh;
  }
  for my $r ( sort keys %legend ) {
    my ($negate,$name) = ($r=~/^(!?\s*)(\S+)/);
    $c->createLine($scale * 75, $y, $scale * 15, $y,
		   -fill => $color{$name},
		   -width => 3*$scale,
		   (-dash => $negate ? '-' : ''),
		   -arrow => $arrow{$name},
		   -arrowshape => [14,20,4],
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
  my $lw = $grp->treeView->get_lineWidth;
  if ($main_query{$node}) {
    AddStyle($styles,'Node',
	     -addheight=>7,
	     -addwidth=>7,
	    );
    AddStyle($styles,'Line',
	     -width=>2+$lw,
	    );
  } elsif ($node->{'#name'} =~ /^(?:node|subquery)$/) {
    AddStyle($styles,'Node',
	     -addheight=>1,
	     -addwidth=>1);
    AddStyle($styles,'Line',
	     -width=>2+$lw,
	    );
  }
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
	  -raise => 8+16*(++$i),
	  -tag => 'relation',
	}
      } SeqV($ref->attr('relation'))
     ], {
       -arrow => 'last',
       -arrowshape => '14,20,4',
       -width => $showHidden ? $lw : $lw+1,
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
      local $main::sortAttrs=0;
      EditAttribute($node,'relation');
      Redraw();
    }
  }
}
sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target;
  print "NODE_RELEASE_HOOK: $mod, $node->{'#name'}, $target->{'#name'}, $node->{optional}\n";
  if (defined($mod) and $mod =~ /^(Control|Control-3|-2)$/) {
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
  } elsif (!$mod and $node->{'#name'} eq 'node' and $target->{'#name'} =~ /^(and|or|not)$/ and !$node->{optional}) {
    $this->set_type(undef);
    $node->{'#name'}='subquery';
    CutPaste($node,$target);
    DetermineNodeType($node);
    ChangingFile(1);
    Redraw();
    return 'stop';
  } elsif (!$mod and $target->{'#name'} =~ /^(ref|test)$/) {
    return 'stop';
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
  my ($root,$filename,$tree_number)=@_;
  $filename = FileName() unless defined $filename;
  $tree_number = CurrentTreeNumber() unless defined $tree_number;
  my $map = $SEARCH->map_nodes_to_query_pos($filename,$tree_number,$root);
  %is_match = defined($map) ? %$map : ();
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
  $d->add('Label', -text=>'What are you going to search?')->pack(-pady => 10);
  my $f = $d->add('Frame')->pack(qw(-expand 1 -fill both));
  $d->BindEscape;
  my ($vol,$dir)=File::Spec->splitpath(__this_module_path());
  my @b;
  for my $b (['File (local)' => 'file', 0, 0, 0], # grid row, grid column, underline
#	     ['List of files (local)' => 'filelist',0,1,5],
	     ['Treebank (server)' => 'remote-db',0,1,0],
#	     ['Database (server)' => 'local-db',1,1,0],
	    ) {
    my $but = $f->Button(
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
#    $b[$_]->bind('<Down>',[$b[ [2,3,1,0]->[$_] ],'focus']);
#    $b[$_]->bind('<Up>',[$b[ [3,2,0,1]->[$_] ],'focus']);
  }

  $d->configure(-focus=>$b[0]);
  my $preserve=0;
  if ($SEARCH) {
    $d->add('Checkbutton',-variable => \$preserve,-underline=>0,-text=>'Preserve current search')
      ->pack();
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
		(map "File: ".$_, uniq(map $_->filename, grep ref, map(CurrentFile($_), TrEdWindows()), GetOpenFiles())),
		(map "List: ".$_->name." (".$_->file_count." files)",
		 grep $_->file_count, TrEdFileLists())
	       ],
	      \@sel
	     ) || return;
    return unless @sel;
    $file = $sel[0];
  }
  my $S;
  # my $S = GetSearch($sel);
  #  unless ($S) {
  if ($choice =~ /^Database/) {
    $S=Tree_Query::SQLSearch->new();
  } elsif ($choice =~ /^Treebank/) {
    $S=Tree_Query::HTTPSearch->new();
  } elsif ($choice =~ /^File/) {
    if ($file=~s/^File: //) {
      $S=Tree_Query::TrEdSearch->new({file => $file});
    } elsif ($file=~s/^List: //) {
      $file =~ s/ \([^\)]* files\)$//g;
      $S=Tree_Query::TrEdSearch->new({filelist => $file});
    }
    #    } elsif ($choice =~ /^List/) {
    #      $S=Tree_Query::TrEdSearch->new({filelist => $file});
  }
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
  for my $but (['Query' =>
		    sub{
		      my $s = GetSearch($ident);
		      if ($s) {
			SetSearch($s);
			$s->search_first;
		      }
		      ChangingFile(0);
		    },
		'search_filter',
		'Perform the query: show first match/output (space)',
	       ],
	       ['Search' =>
		  sub{
		    my $s = GetSearch($ident);
		    if ($s) {
		      SetSearch($s);
		      $s->search_first({no_filters=>1});
		    }
		    ChangingFile(0);
		  },
		'search',
		'Find first match, ignore output filters (Shift+space)',
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
		'search_previous',
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
		'search_next',
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
		-image => main::icon($grp->{framegroup},$but->[2]),
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
	      -command => MacroCallback([sub {
					   my $ident=shift;
					   DestroyUserToolbar($ident);
					   my ($s) = grep { $_->identify eq $ident } @SEARCHES;
					   @SEARCHES = grep { $_ != $s } @SEARCHES;
					   $SEARCH = undef if $SEARCH and $SEARCH == $s;
					   ChangingFile(0);
					 },$ident])
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

our ($match_node_re,$variable_re,$relation_re);
$match_node_re  = qr/\[((?:(?> [^][]+ )|(??{ $match_node_re }))*)\]/x;
$variable_re = qr/\$[[:alpha:]_][[:alnum:]_]*/;
$relation_re = qr/descendant|ancestor|child|parent|descendant|ancestor|${Tree_Query::user_defined}|depth-first-precedes|depth-first-follows|order-precedes|order-follows|same-tree-as/;

sub _find_type_in_query_string {
  my ($context,$rest)=@_;
  my ($type,$var);
  if ($context =~ /(${variable_re})\.$/) {
    $var = $1;
    if (($context.$rest)=~/(?:(${relation_re})(?:\s+|$))?(${PMLSchema::CDATA::Name})\s+\Q$var\E\s*:=\s*\[/) {
      $type = $2;
    }
  } else {
    $context = reverse $context;
    my $depth = 0;
    while (length $context) {
      $context =~ s/^[^]["']+|"(?:[^"\\]+|\\.)*"|'(?:[^'\\]+|\\.)*'//;
      if ($context=~s/^\[\s*//) {
	last if $depth==0;
	$depth--;
      }
      $depth++ if $context=~s/^\]\s*//;
    }
    return unless length $context;
    $context=reverse $context;
    if ($context =~ /(?:(${relation_re})(?:\s+|$))?(?:(${PMLSchema::CDATA::Name})(?:\s+|$))(?:(${variable_re})\s*:=)?$/) {
      $type = $2;
    }
  }
  return ($type,$var);
}

sub _editor_offer_values {
  my ($ed,$operator) = @_;
  my @sel;
  if ($SEARCH) {
    my $context = $ed->get('0.0','insert');
    if ($context=~s{(${variable_re}\.)?(${PMLSchema::CDATA::Name}(?:/${PMLSchema::CDATA::Name})*)\s*$}{$1}) {
      my ($var,$attr) = ($1,$2);
      my ($type) = _find_type_in_query_string($context,
						   $ed->get('insert','end'));
      my $decl = $SEARCH->get_decl_for($type);
      if ($decl and ($decl = $decl->find($attr))) {
	my $decl_is = $decl->get_decl_type;
	while ($decl_is == PML_ALT_DECL or
		 $decl_is == PML_LIST_DECL) {
	  $decl = $decl->get_content_decl;
	  $decl_is = $decl->get_decl_type;
	}
	if ($decl_is == PML_CHOICE_DECL or
	      $decl_is == PML_CONSTANT_DECL) {
	  unless (ListQuery(
	    'Select value',
	    $operator eq 'in' ? 'multiple' : 'browse',
	    [map { $_=~/\D/ ? qq{"$_"} : $_ } $decl->get_values],
	    \@sel,
	    {
	      top => $ed->toplevel }
	   )) {
	    $ed->focus;
	    $ed->Insert(' '.$operator.' ');
	    return;
	  }
	}
      }
    }
  }
  $ed->focus;
  if ($operator eq 'in') {
    $ed->Insert(q( in { ).join(', ',@sel).q( } ));
  } else {
    $ed->Insert(' '.$operator.' '.(@sel ? $sel[0] : ''))
  }
}

sub EditQuery {
  my ($node,$opts)=@_;

  $opts||={};

  my $no_childnodes = ($node->{'#name'} =~ /^(node|subquery)$/ and $opts->{no_childnodes}) ? 1 : 0;
  my $string = $opts->{string} || as_text($node,{no_childnodes=>$no_childnodes});
  my $result;
  my $parser;
  {
    my $t0 = new Benchmark;
    $parser = query_parser();
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "creating parser took: $time\n";
  }
  my $qopts={$node->parent ? (-cursor => 'end - 3 chars') : (),
	     -height => 16,
	     -init => sub {
	       my ($d,$ed)=@_;
	       my $f = $d->add('Frame')->pack(-side=>'top');
	       for (
		 qw(? 3x),
		 [Relation => undef, #[ map { /^(\S+)/ } @{GetRelationTypes($this)} ],
		  {
		    -command => [
		      sub {
			my ($ed)=@_;
			my ($node_type) = _find_type_in_query_string($ed->get('0.0','insert'),
								     $ed->get('insert','end'));
			my $relations;
			if ($SEARCH and defined $node_type and length $node_type) {
			  $relations =
			    [ grep {
			      @{[GetRelativeQueryNodeType($node_type,
							  $SEARCH,
							  CreateRelation($_))]}>0
							} @{GetRelationTypes($this)}
						       ];
			} else {
			  $relations = GetRelationTypes($this);
			}
			return unless @$relations;
			my @sel=['child'];
			if (ListQuery('Select relation',
				  'browse',
				  $relations,
				      \@sel)) {
			  my $sel = $sel[0];
			  $sel=~s/\s.*//;
			  $ed->Insert($sel.' ');
			}
			$ed->focus;
		      },$ed
		     ],
		  }
		 ],
		 [Type => undef,
		  {
		    -state => $SEARCH ? 'normal' : 'disabled',
		    -command => [
		      sub {
			my ($ed)=@_;
			my $prev=$ed->get('0.0','insert');
			my ($node_type) = _find_type_in_query_string($prev,
								     $ed->get('insert','end'));
			my $relation = 'child';
			if ($prev=~/(${Tree_Query::user_defined})\s*$/) {
			  $relation = $1.' (user-defined)';
			} elsif ($prev=~/(${relation_re})\s*$/) {
			  $relation = $1;
			}
			my @types=
			  $node_type ? 
			  GetRelativeQueryNodeType($node_type,$SEARCH,CreateRelation($relation)) :
			    @{$SEARCH->get_node_types};
			if (@types==1) {
			  $ed->Insert($types[0].' ');
			} else {
			  my @sel=[$types[0]];
			  if (ListQuery('Select node type', 'browse', \@types, \@sel)) {
			    $ed->Insert($sel[0].' ');
			  }
			}
			$ed->focus;
		      },$ed
		     ],
                  }
		 ],
		 q|$n :=|,
		 '[ ]',
		 "\n",
		 ['Attribute',undef,
		  {
		    -state => $SEARCH ? 'normal' : 'disabled',
		    -underline => 5,
		    -command =>
		      [sub {
			 my ($ed)=@_;
			 my ($type,$var) = _find_type_in_query_string($ed->get('0.0','insert'),
								      $ed->get('insert','end'));
			 if (defined $type and length $type) {
			   my $decl = $SEARCH->get_decl_for($type);
			   if ($decl) {
			     my @res = $decl->get_paths_to_atoms({ no_childnodes => 1 });
			     if (@res) {
			       my @sel=$res[0];
			       if (ListQuery('Select attribute'.
					       ($var ? ' for '.$var : ()),'browse',
					     \@res,
					     \@sel,
					     {
					       top=>$ed->toplevel,
					       list=>{ -exportselection => 0 }
					     }
					    )) {
				 $ed->Insert(($var ? '' :' ').$sel[0].' ');
			       }
			     }
			   }
			 }
			 $ed->focus;
		       },$ed]
		     }
		 ],
		 ['=',undef,{-command => [\&_editor_offer_values,$ed,'=']}],
		 ['in { ... }',undef,{-command => [\&_editor_offer_values,$ed,'in']}],
		 ['~ (regexp)' => '~'],
		 qw|< >|,
		 [Function => [map { $_.'()' }
				 sort
				   qw( descendants
				       lbrothers
				       rbrothers sons depth_first_order
				       depth lower upper length substr tr replace ciel floor
				       round trunc percnt name file tree_no address substitute match
				    )
			       ]],
		 "\n",
		 qw|, ! and or ()|,
		 [q|"..."| => q|""|],
		 [q|'...'|=> q|''|],
		 qw|+ - * / ^ $|,
		 ['& (concat)' => '&'],
		 "\n",
		 ($node->parent
		    ? ()
		    : (qw| >> |,
		       ['Analytic function' => [map { $_.'()' }
						  sort
						    qw( min max sum avg count ratio concat )
						   ]]),
		 ),
		) {
		 if ($_ eq "\n") {
		   $f = $d->add('Frame')->pack(-side=>'top');
		   next;
		 }
		 my ($label,$value,$opts)=ref($_) ? @$_ : ($_,$_);
		 $opts||={};
		 if (ref($value) eq 'ARRAY') {
		   my $menubutton = $f->Menubutton(
		     -text => $label,
		     -underline => 0,
		     -relief => 'raised',
		     -direction => 'right',
		     %$opts,
		    )->pack(-side=>'left');
		   my $menu = $menubutton->menu(-tearoff => 0,-font=>'C_small');
		   $menubutton->configure(-menu => $menu);
		   for (@$value) {
		     $menubutton->command(-label => $_,
					  -command => [$ed,'Insert',' '.$_.' ']
					 );
		   }
		 } else {
		   $f->Button(-text => $label,
			      ($label=~/([[:alpha:]])/ ? (-underline => $-[0]) : ()),
			      defined($value) ? ( -command => [ sub { $_[0]->Insert($_[1]=~/\$|\^/ ? $_[1] : ' '.$_[1].' ');
						      $_[0]->SetCursor('insert -2 chars') if $_[1]=~/["'[({]/;
						    }, $ed, $value] ) : (),
			      %$opts,
			       )->pack(-side=>'left');
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
	eval {
	  Tree_Query::Common::CompleteMissingNodeTypes($SEARCH,$_) for @$result
	} if $SEARCH;
  	$result=$result->[0];
      } else {
	$result->paste_after($node);
	DetermineNodeType($_) for ($result,$result->descendants);
	eval { Tree_Query::Common::CompleteMissingNodeTypes($SEARCH,$result) }
	  if $SEARCH;
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
      eval { Tree_Query::Common::CompleteMissingNodeTypes($SEARCH,$node) } if $SEARCH;
    }
    my $t1 = new Benchmark;
    my $time = timestr(timediff($t1,$t0));
    print "postprocessing took: $time\n";
  }
  return 1;
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
  local $main::sortAttrs=0;
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
  } elsif ($node->{'#name'}=~/^(?:test|ref)/) {
    $new = NewRBrother();
    $new->{'#name'}=$node->{'#name'};
    DetermineNodeType($new);
  } else {
    $new = NewSon();
    DetermineNodeType($new);
  }
  if ($new and $new->{'#name'} =~ /^(?:node|subquery)/) {
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

sub AddNOT {
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
}

sub AddAND {
  my $node=$this;
  ChangingFile(0);
  return unless $node->parent;
  my $and;
  if ($node->{'#name'} eq 'or') {
    $and = NewSon();
    $this=$and;
  } elsif ($node->parent->{'#name'} eq 'or') {
    $and = NewParent();
    $this=$node;
  } else {
    return;
  }
  $and->{'#name'}='and';
  DetermineNodeType($and);
  ChangingFile(1);
}

sub AddOR {
  my $node=$this;
  ChangingFile(0);
  return unless $node->parent and $node->{'#name'} ne 'or';
  my $or;
  if ($node->{'#name'} =~ /^(?:node|and|not|subquery)/) {
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
}

sub AutoNameAllNodes {
  ChangingFile(0);
  init_id_map($root,2);
}

} # use strict
1;
