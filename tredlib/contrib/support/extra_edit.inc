# -*- cperl -*-
# Additional macros and bindings for creating trees from scratch

#bind NewTreeAfter Alt+N menu New tree
#bind trim_subtree Alt+T menu Trim (remove all but current subtree)
#bind DeleteThisNode to Delete menu Delete current node
#bind DeleteSubtree to Ctrl+Delete menu Delete current subtree

#bind cut_to_clipboad to Shift+Delete menu Cut subtree to clipboard
#bind copy_to_clipboad to Ctrl+Insert menu Copy subtree to clipboard
#bind paste_from_clipboad to Shift+Insert menu Paste subtree from clipboard
#bind paste_as_new_tree to Ctrl+Shift+Insert menu Paste as new tree

#bind cut_to_parents_parent to Ctrl+Up menu Place node on parent's parent
#bind cut_to_parents_rbrother to Ctrl+Right menu Place node on parent's right brother
#bind cut_to_parents_lbrother to Ctrl+Left menu Place node on parent's left brother
#bind cut_to_sibling to Ctrl+Down menu Place node on its left- or right-sibling (whichever exists)

#bind NewRBrother to Alt+Right menu New right brother node
#bind NewLBrother to Alt+Left menu New left brother node
#bind NewSon to Alt+Down menu New son node
#bind NewParent to Alt+Up menu New son parent

#include "reordering.inc"
#include "projectivize.inc"

#bind ShiftLeft to Ctrl+Shift+Left menu Move node to the left
#bind ShiftRight to Ctrl+Shift+Right menu Move node to the right
#bind ShiftSToverSTLeft to Alt+Shift+Left menu Swap subtree with subtree to the left
#bind ShiftSToverSTRight to Alt+Shift+Right menu Swap subtree with subtree to the right
#insert ShiftSTLeft as menu Move subtree to the left
#insert ShiftSTRight as menu Move subtree to the right
#insert ProjectivizeCurrentSubTree as menu Projectivize subtree
#insert ProjectivizeTree as menu Projectivize tree

sub cut_to_firstson {
  return unless ($this and $this->firstson and $this->parent);
  my $p=$this->parent;
  my $b=CutNode($this->firstson);
  $this=CutPaste($this,$b);
  $b=PasteNode($b,$p);
  foreach ($this->children) {
    CutPaste($_,$b);
  }
}
sub cut_to_parents_parent {
  my $p = $this && $this->parent && $this->parent->parent;
  return unless $p;
  my $ordering=TredMacro::_node_ord($this->parent);
  if (defined($ordering) and length($ordering)) {
    CutPaste($this,$p);
  } else {
    CutPasteAfter($this,$this->parent);
  }
}
sub cut_to_parents_rbrother {
  return unless $this and $this->parent and $this->parent->rbrother;
  CutPaste($this,$this->parent->rbrother);
}
sub cut_to_parents_lbrother {
  return unless $this and $this->parent and $this->parent->lbrother;
  CutPaste($this,$this->parent->lbrother);
}
sub cut_to_sibling {
  return unless $this;
  my $b = $this->lbrother;
  if ($b) {
    if ($b->firstson) {
      my $ordering=TredMacro::_node_ord($b->firstson);
      if (defined($ordering) and length($ordering)) {
	CutPaste($this,$b);
      } else {
	$b=$b->firstson;
	$b=$b->rbrother while $b->rbrother;
	CutPasteAfter($this,$b);
      }
    } else {
      CutPaste($this,$b);
    }
  } elsif ($b=$this->rbrother) {
    if ($b->firstson) {
      my $ordering=TredMacro::_node_ord($b->firstson);
      if (defined($ordering) and length($ordering)) {
	CutPaste($this,$b);
      } else {
	$b=$b->firstson;
	$b=$b->lbrother while $b->lbrother;
	CutPasteBefore($this,$b);
      }
    } else {
      CutPaste($this,$b);
    }
  }
}

sub trim_subtree {
  return unless ($this and $root and $this!=$root);
  my $node=$this;
  CutNode($node);
  $grp->{FSFile}->set_tree($node,$grp->{treeNo});
  Fslib::DeleteTree($root);
  $this=$node;
  $root=$node;
}

sub copy_to_clipboad {
  return unless ($this);
  $TredMacro::nodeClipboard=CloneSubtree($this);
}

sub cut_to_clipboad {
  return unless ($this and $this->parent);
  $TredMacro::nodeClipboard=$this;
  $this=$this->rbrother ? $this->rbrother : $this->parent;
  CutNode($TredMacro::nodeClipboard);

  my $nodesref=GetNodes();
  SortByOrd($nodesref);
  NormalizeOrds($nodesref);
}

sub paste_from_clipboad {
  return unless ($this and $TredMacro::nodeClipboard);

  my $clipnodes=GetNodes($TredMacro::nodeClipboard);
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

  PasteNode($TredMacro::nodeClipboard,$this);
  $this=$TredMacro::nodeClipboard;
  $TredMacro::nodeClipboard=undef;
}

sub paste_as_new_tree {
  return unless ($grp->{FSFile} and $TredMacro::nodeClipboard);

  my $clipnodes=GetNodes($TredMacro::nodeClipboard);
  SortByOrd($clipnodes);
  NormalizeOrds($clipnodes);
  my $pos=$grp->{FSFile}->lastTreeNo()+1;
  $grp->{FSFile}->insert_tree($TredMacro::nodeClipboard,$pos);
  GotoTree($pos+1);
  $TredMacro::nodeClipboard=undef;
}

