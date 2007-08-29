# -*- cperl -*-
# Additional macros and bindings for creating trees from scratch

#bind NewTreeAfter Alt+N menu New tree
#bind trim_subtree Alt+T menu Trim (remove all but current subtree)
#bind copy_to_clipboad to Ctrl+Insert menu Copy subtree
#bind cut_to_clipboad to Shift+Delete menu Cut subtree
#bind paste_from_clipboad to Shift+Insert menu Paste subtree
#bind paste_as_new_tree to Ctrl+Shift+Insert menu Paste as new tree
#bind NewRBrother to Ctrl+Shift+Right menu New right brother node
#bind NewLBrother to Ctrl+Shift+Left menu New left brother node
#bind NewSon to Ctrl+Shift+Down menu New son node
#bind NewParent to Ctrl+Shift+Up menu New son parent
#bind DeleteThisNode to Delete menu Delete current node

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
  $nodeClipboard=CloneSubtree($this);
}

sub cut_to_clipboad {
  return unless ($this and $this->parent);
  $nodeClipboard=$this;
  $this=$this->rbrother ? $this->rbrother : $this->parent;
  CutNode($nodeClipboard);

  my $nodesref=GetNodes();
  SortByOrd($nodesref);
  NormalizeOrds($nodesref);
}

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

