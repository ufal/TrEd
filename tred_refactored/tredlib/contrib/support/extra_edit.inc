# -*- cperl -*-
# Additional macros and bindings for creating trees from scratch

#ifndef no_extra_edit_key_bindings

#bind new_tree_after Alt+N
#bind new_rbrother to Alt+Right
#bind new_lbrother to Alt+Left
#bind new_son to Alt+Down
#bind new_parent to Alt+Up

#bind trim_subtree Alt+T
#bind delete_node_keep_children to Delete
#bind DeleteSubtree to Ctrl+Delete

#bind cut_to_clipboard to Shift+Delete
#bind copy_to_clipboard to Ctrl+Insert
#bind paste_from_clipboard to Shift+Insert
#bind paste_as_new_tree to Ctrl+Shift+Insert

#bind cut_to_parents_parent to Ctrl+Up
#bind cut_to_parents_rbrother to Ctrl+Right
#bind cut_to_parents_lbrother to Ctrl+Left
#bind cut_to_sibling to Ctrl+Down

#bind ShiftLeft to Ctrl+Shift+Left
#bind ShiftRight to Ctrl+Shift+Right
#bind ShiftSToverSTLeft to Alt+Shift+Left
#bind ShiftSToverSTRight to Alt+Shift+Right

#endif no_extra_edit_key_bindings

#ifndef no_extra_edit_menu_bindings

#insert ShiftSTLeft as menu Move subtree to the left
#insert ShiftSTRight as menu Move subtree to the right
#insert ProjectivizeCurrentSubTree as menu Projectivize subtree
#insert ProjectivizeTree as menu Projectivize tree

#insert new_tree_after as menu New tree
#insert new_rbrother as menu New right brother node
#insert new_lbrother as menu New left brother node
#insert new_son as menu New son node
#insert new_parent as menu New parent node

#insert trim_subtree as menu Trim (remove all but current subtree)
#insert delete_node_keep_children as menu Delete current node (pasting its children on its parent)
#insert DeleteSubtree as menu Delete current subtree

#insert cut_to_clipboard as menu Cut subtree to clipboard
#insert copy_to_clipboard as menu Copy subtree to clipboard
#insert paste_from_clipboard as menu Paste subtree from clipboard
#insert paste_as_new_tree as menu Paste as new tree

#insert cut_to_parents_parent as menu Place node on parent's parent
#insert cut_to_parents_rbrother as menu Place node on parent's right brother
#insert cut_to_parents_lbrother as menu Place node on parent's left brother
#insert cut_to_sibling as menu Place node on its left- or right-sibling (whichever exists)

#insert ShiftLeft as menu Move node to the left
#insert ShiftRight as menu Move node to the right
#insert ShiftSToverSTLeft as menu Swap subtree with subtree to the left
#insert ShiftSToverSTRight as menu Swap subtree with subtree to the right

#endif no_extra_edit_menu_bindings


#include "reordering.inc"


sub new_tree_after {
  DetermineNodeType(NewTreeAfter());
}
sub new_rbrother {
  my $save = $this;
  my $new = NewRBrother();
  unless (DetermineNodeType($new)) {
    DeleteLeafNode($new);
    $this=$save;
    return;
  }
  return $new;
}
sub new_lbrother {
  my $save = $this;
  my $new = NewLBrother();
  unless (DetermineNodeType($new)) {
    DeleteLeafNode($new);
    $this=$save;
    return;
  }
  return $new;
}
sub new_son {
  my $save = $this;
  my $new = NewSon();
  unless (DetermineNodeType($new)) {
    DeleteLeafNode($new);
    $this=$save;
    return;
  }
  return $new;
}
sub new_parent {
  return unless $this->parent;
  my $save = $this;
  my $new = NewParent();
  unless (DetermineNodeType($new)) {
    delete_node_keep_children($new);
    $this=$save;
    return;
  }
  return $new;
}

sub cut_to_firstson {
  return unless ($this and $this->firstson and $this->parent);
  my $p=$this->parent;
  my $b=$this->firstson;

  if (!$b->test_child_type($this) or
      !$p->test_child_type($b) or
      first {!$b->test_child_type($_) } $this->children
     ) {
    QuestionQuery("Cannot move node",
		  "Incompatible node types!\n",
		  'Ok');
    return;
  }

  CutNode($b);
  $this=CutPaste($this,$b);
  $b=PasteNode($b,$p);
  foreach ($this->children) {
    CutPaste($_,$b);
  }
}
sub cut_to_parents_parent {
  my $p = $this && $this->parent && $this->parent->parent;
  return unless $p;
  if (!$p->test_child_type($this)) {
    QuestionQuery("Cannot move node",
		  "Incompatible node types!\n",
		  'Ok');
    return;
  }

  my $ordering=TredMacro::_node_ord($this->parent);
  if (defined($ordering) and length($ordering)) {
    CutPaste($this,$p);
  } else {
    CutPasteAfter($this,$this->parent);
  }
}
sub cut_to_parents_rbrother {
  return unless $this and $this->parent and $this->parent->rbrother;
  my $b=$this->parent->rbrother;
  if (!$b->test_child_type($this)) {
    QuestionQuery("Cannot move node",
		  "Incompatible node types!\n",
		  'Ok');
    return;
  }
  CutPaste($this,$b);
}
sub cut_to_parents_lbrother {
  return unless $this and $this->parent and $this->parent->lbrother;
  my $b=$this->parent->lbrother;
  if (!$b->test_child_type($this)) {
    QuestionQuery("Cannot move node",
		  "Incompatible node types!\n",
		  'Ok');
    return;
  }
  CutPaste($this,$b);
}
sub cut_to_sibling {
  return unless $this;
  my $b = $this->lbrother;
  if ($b) {
    if ($b->firstson) {
      my $ordering=TredMacro::_node_ord($b->firstson);
      if (defined($ordering) and length($ordering)) {
	if (!$b->test_child_type($this)) {
	  QuestionQuery("Cannot move node",
			"Incompatible node types!\n",
			'Ok');
	  return;
	}
	CutPaste($this,$b);
      } else {
	if (!$b->test_child_type($this)) {
	  QuestionQuery("Cannot move node",
			"Incompatible node types!\n",
			'Ok');
	  return;
	}
	$b=$b->firstson;
	$b=$b->rbrother while $b->rbrother;
	CutPasteAfter($this,$b);
      }
    } else {
      if (!$b->test_child_type($this)) {
	QuestionQuery("Cannot move node",
		      "Incompatible node types!\n",
		      'Ok');
	return;
      }
      CutPaste($this,$b);
    }
  } elsif ($b=$this->rbrother) {
    if ($b->firstson) {
      my $ordering=TredMacro::_node_ord($b->firstson);
      if (defined($ordering) and length($ordering)) {
	if (!$b->test_child_type($this)) {
	  QuestionQuery("Cannot move node",
			"Incompatible node types!\n",
			'Ok');
	  return;
	}
	CutPaste($this,$b);
      } else {
	if (!$b->test_child_type($this)) {
	  QuestionQuery("Cannot move node",
			"Incompatible node types!\n",
			'Ok');
	  return;
	}
	$b=$b->firstson;
	$b=$b->lbrother while $b->lbrother;
	CutPasteBefore($this,$b);
      }
    } else {
      if (!$b->test_child_type($this)) {
	QuestionQuery("Cannot move node",
		      "Incompatible node types!\n",
		      'Ok');
	return;
      }
      CutPaste($this,$b);
    }
  }
}

sub trim_subtree {
  return unless ($this and $root and $this!=$root);
  my $node=$this;
  CutNode($node);
  $grp->{FSFile}->set_tree($node,$grp->{treeNo});
  $root->destroy;
  $this=$node;
  $root=$node;
}

sub copy_to_clipboard {
  return unless ($this);
  $TredMacro::nodeClipboard=CloneSubtree($this);
}

sub cut_to_clipboard {
  return unless ($this and $this->parent);
  $TredMacro::nodeClipboard=$this;
  $this=$this->rbrother ? $this->rbrother : $this->parent;
  CutNode($TredMacro::nodeClipboard);
  if (_node_ord( $TredMacro::nodeClipboard)) {
    my $nodesref=GetNodes();
    SortByOrd($nodesref);
    NormalizeOrds($nodesref);
  }
}

sub paste_from_clipboard {
  return unless ($this and $TredMacro::nodeClipboard);
  if (!$this->test_child_type($TredMacro::nodeClipboard)) {
    QuestionQuery("Cannot paste node",
		  "The type of the clipboard node is not compatible\n"
		  ."with the current node!",
		  'Ok');
    return;
  }
  if (_node_ord($this)) {
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
  }
  PasteNode($TredMacro::nodeClipboard,$this);
  $this=$TredMacro::nodeClipboard;
  $TredMacro::nodeClipboard=undef;
}

sub paste_as_new_tree {
  return unless ($grp->{FSFile} and $TredMacro::nodeClipboard);

  if ($this) {
    my $clipnodes=GetNodes($TredMacro::nodeClipboard);
    SortByOrd($clipnodes);
    NormalizeOrds($clipnodes);
  }
  my $pos=$grp->{FSFile}->lastTreeNo()+1;
  $grp->{FSFile}->insert_tree($TredMacro::nodeClipboard,$pos);
  GotoTree($pos+1);
  $TredMacro::nodeClipboard=undef;
}

sub delete_node_keep_children {
  shift unless ref $_[0];
  my $node=shift()||$this;
  my $parent = $node->parent;
  return unless $parent;
  if (first {!$parent->test_child_type($_)}
	$node->children) {
    QuestionQuery("Cannot delete node",
		  "The node cannot be deleted: some of its child nodes\n".
		  "has incompatible type with the parent node!",
		 'Ok');
    return;
  }

  my $ordering=TredMacro::_node_ord($node);
  if (defined($ordering) and length($ordering)) {
    for my $child ($node->children) {
      CutPaste($child,$parent);
    }
  } else {
    for my $child ($node->children) {
      CutPasteBefore($child,$node);
    }
  }
  DeleteLeafNode($node);
  if ($this==$node) {
    $this=$parent;
  }
}
