## -*- cperl -*-
## author: Petr Pajas
## $Id$

#key-binding-adopt Tectogrammatic

package TREdit;

use base qw(Tectogrammatic);
import Tectogrammatic;
import Coref qw(switch_context_hook node_style_hook node_release_hook);

my %menu_prevstate;

sub FuncAssign {
  $this->{'func'} = $sPar1;
  clear_funcaux($this);
  $this=NextVisibleNode($this);
}

sub switch_context_hook {
  my ($precontext,$context)=@_;
  return unless ($precontext ne $context);
  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
    $menu_prevstate{$_}=$grp->{framegroup}->{NodeMenu}->entrycget($_,'-state');
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'normal');
  }

}

sub pre_switch_context_hook {
  my ($precontext,$context)=@_;
  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => $menu_prevstate{$_})
      if defined $menu_prevstate{$_};
  }

}

sub enable_attr_hook {
}


sub edit_attr_value {
  my ($attr)=@_;
  if (not $grp->{FSFile}->FS->exists($attr)) {
    ToplevelFrame()->messageBox
      (
       -icon => 'warning',
       -message => "Attribute $attr not defined!",
       -title => 'Sorry',
       -type => 'OK'
      );
    $FileNotSaved=0;
    return;
  }
  my $value=$this->{$attr};
  $value=QueryString("Enter comment",$attr,$value);
  if (defined($value)) {
    $this->{$attr}=$value;
  }
}

#bind edit_origf Alt+O menu Edit root's origf
sub edit_origf {
  {
    local $this=$root;
    edit_attr_value('origf');
  }
}


#bind edit_trlemma Alt+L menu Edit trlemma
sub edit_trlemma {
  edit_attr_value('trlemma');
}

#bind edit_ID1 Alt+I menu Edit ID1 add assign identifiers to all nodes
sub edit_ID1 {
  {
    local $this=$root;
    edit_attr_value('ID1');
  }
  my $id1 = $root->{ID1};
  my $i = 0;
  foreach my $node ($root,$root->descendants) {
    $node->{TID}=$id1."-N".$i;
    $i++;
  }
}


#bind create_new_tree Alt+N menu New tree
sub create_new_tree {
  my $pos=$grp->{FSFile}->lastTreeNo()+1;
  $grp->{FSFile}->new_tree($pos);
  GotoTree($pos+1);
}

#bind trim_subtree Alt+T menu Trim (remove all but current subtree)
sub trim_subtree {
  return unless ($this and $root and $this!=$root);
  my $node=$this;
  CutNode($node);
  $grp->{FSFile}->set_tree($node,$grp->{treeNo});
  Fslib::DeleteTree($root);
  $this=$node;
  $root=$node;
}

#bind copy_to_clipboad to Ctrl+Insert menu Copy subtree
sub copy_to_clipboad {
  return unless ($this);
  $nodeClipboard=CloneSubtree($this);
}

#bind cut_to_clipboad to Shift+Delete menu Cut subtree
sub cut_to_clipboad {
  return unless ($this and $this->parent);
  $nodeClipboard=$this;
  $this=$this->rbrother ? $this->rbrother : $this->parent;
  CutNode($nodeClipboard);

  my $nodesref=GetNodes();
  SortByOrd($nodesref);
  NormalizeOrds($nodesref);

  # reorder tree
}

#bind paste_from_clipboad to Shift+Insert menu Paste subtree
sub paste_from_clipboad {
  return unless ($this and $nodeClipboard);

  my $clipnodes=GetNodes($nodeClipboard);
  SortByOrd($clipnodes);
  NormalizeOrds($clipnodes);
  my $nodes=GetNodes($root);
  SortByOrd($nodes);
  NormalizeOrds($nodes);
  my $ord=FS()->order;
  my $shift=$this->{$ord};
  foreach my $node (@$clipnodes) {
    $node->{$ord}+=$shift;
  }
  foreach my $node (@$nodes) {
    $node->{$ord}+=$#$clipnodes+1 if $node->{$ord}>$shift;
  }

  PasteNode($nodeClipboard,$this);
  $this=$nodeClipboard;
  $nodeClipboard=undef;
}

#bind paste_as_new_tree to Ctrl+Shift+Insert menu Paste as new tree
sub paste_as_new_tree {
  return unless ($grp->{FSFile} and $nodeClipboard);

  my $clipnodes=GetNodes($nodeClipboard);
  SortByOrd($clipnodes);
  NormalizeOrds($clipnodes);
  my $pos=$grp->{FSFile}->lastTreeNo()+1;
  $grp->{FSFile}->insert_tree($nodeClipboard,$pos);
  GotoTree($pos+1);
  $nodeClipboard=undef;
}


#bind create_new_rbrother to Ctrl+Shift+Right menu New right brother node
#bind create_new_lbrother to Ctrl+Shift+Left menu New left brother node
#bind create_new_son to Ctrl+Shift+Down menu New son node
#bind create_new_parent to Ctrl+Shift+Up menu New son parent

sub create_new_rbrother {
  TredMacro::NewRBrother();
}

sub create_new_lbrother {
  TredMacro::NewLBrother();
}

sub create_new_son {
  TredMacro::NewSon();
}

sub create_new_parent {
  TredMacro::NewParent();
}

# new node right, left, below (son)

#include <contrib/tfa_common.mak>

#bind ShiftSTLeft to Alt+Left menu Move subtree to the left
#bind ShiftSTRight to Alt+Right menu Move subtree to the right
#bind ShiftSToverSTLeft to Ctrl+Alt+Left menu Switch subtree with subtree to the left
#bind ShiftSToverSTRight to Ctrl+Alt+Right menu Switch subtree with subtree to the right
