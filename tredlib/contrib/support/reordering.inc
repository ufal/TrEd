#include "projectivize.inc"

############################### macros for moving nodes and subtrees #####################

sub Move {
# move the node specified by the first parameter right after the node specified in the second parameter

  my $top=$_[0];
  return unless $top;

  my $after= ref($_[1]) ? $_[1] : $root;  # if no node to place after is specified, it is taken to be the root node

  my $all = [GetNodes($top)];
  SortByOrd($all);

  splice @$all,Index($all,$top),1;   # the top node is cut off from the array
  splice @$all,Index($all,$after)+1,0,$top;   # the top node is spliced after the appropriate node

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


#************************** shifting subtrees ****************************************************
sub MoveST {
# move the subtree specified by the first parameter right after the node specified in the second parameter

  my $top=$_[0];
  return unless $top;

  return unless my $subtree=ContinueProjectivizing($top);

  my $after= ref($_[1]) ? $_[1] : $root;  # if no node to place after is specified, it is taken to be the root node

  my $all=GetNodesExceptST([$top]);

  splice @$all,Index($all,$top),1;   # the top node is cut off from the array
  splice @$all,Index($all,$after)+1,0,@$subtree;   # the subtree is spliced after the appropriate node

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSTLeft {
# moves the (projectivized) subtree of a given node one node left,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeLeft($this);
  } else {
    ShiftSubTreeLeftSkipHidden($this);
  }
}


sub ShiftSTRight {
# moves the (projectivized) subtree of a given node one node right,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeRight($this);
  } else {
    ShiftSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeLeft {
# moves the (projectivized) subtree of a given node one node left (with respect to all nodes)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $i=Index($all,$top);  # locate the given node in the array @all
  if ($i>1) {  # check if there is place where to move (the root is always number zero)
    splice @$all,$i,1;  # cut out the given node
    splice @$all,$i-1,0, @$subtree;  # splice the projectivized subtree at the right (ie left ;-) place
  }
  else {
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtree
                                 # instead of the given node - thus the subtree gets projectivized
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeRight {
# moves the (projectivized) subtree of a given node one node right (with respect to all nodes)
# see ShiftSubTreeLeft

  my $top=ref($_[0]) ? $_[0] : $this;

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $i=Index($all,$top);
  if ($i<$#$all) {
    splice @$all,$i,1;
    splice @$all,$i+1,0, @$subtree;
  }
  else {
    splice @$all,$i,1, @$subtree;
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeLeftSkipHidden {
# moves the (projectivized) subtree of a given node one node left (with respect to non-hidden nodes only)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return unless my $subtree=ContinueProjectivizing($top);  # the projectivized subtree

  my $all=GetNodesExceptST([$top]);  # all nodes except the nodes depending on the given node

  my $allvis=GetNodesExceptST([$top],1); # all visible (ie non-hidden) nodes except the nodes depending on the given node

  my $i=Index($allvis,$top);  # locate the given node within the array @allvis
  if ($i>1) {  # if there is room where to move
    splice @$all,Index($all,$top),1;  # cut the given node
    splice @$all,Index($all,$$allvis[$i-1]),0, @$subtree;  # locate the first visible node to the left
                                                    # and splice the projectivized subtree accordingly
  }
  else {  # nowhere to move, the subtree of the given node gets projectivized
    splice @$all,Index($all,$top),1, @$subtree;
  }

  NormalizeOrds($all);

}


sub ShiftSubTreeRightSkipHidden {
# moves the (projectivized) subtree of a given node one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeLeftSkipHidden

  my $top=ref($_[0]) ? $_[0] : $this;

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $allvis=GetNodesExceptST([$top],1);

  my $i=Index($allvis,$top);
  if ($i<$#$allvis) {
    splice @$all,Index($all,$top),1;
    splice @$all,Index($all,$$allvis[$i+1])+1,0, @$subtree;
  }
  else {
    splice @$all,Index($all,$top),1, @$subtree;
  }

  NormalizeOrds($all);

}

#************************** switching subtrees ****************************************************
sub brothernodes {
# return an array of all the brothers of the given node (including itself)
# according to the visibility status
  my $node = ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed
  my @brothers;
  while ($node->lbrother) {$node=$node->lbrother};  # get to the leftmost brother
  if ($_[1]) {               # @brothers is filled only with the visible brothers
    while ($node) {push @brothers,$node unless IsHidden($node); $node=$node->rbrother};
  }
  else {                     # @brothers is filled with all brothers
    while ($node) {push @brothers,$node; $node=$node->rbrother};
  };
  SortByOrd(\@brothers);
  return @brothers;
}

sub ShiftSToverSTLeft {
# switches the (projectivized) subtree of the current node with the (projectivized) subtree to the left,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeOverSubTreeLeft($this);
  } else {
    ShiftSubTreeOverSubTreeLeftSkipHidden($this);
  }
}


sub ShiftSToverSTRight {
# switches the (projectivized) subtree of the current node with the (projectivized) subtree to the right,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeOverSubTreeRight($this);
  } else {
    ShiftSubTreeOverSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeOverSubTreeLeft {
  # moves the (projectivized) subtree of a given node one subtree left (with respect to all nodes)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  my @brothers = brothernodes($top);

  my $switch = $brothers[max(Index(\@brothers,$top)-1,0)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

      splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
      splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place

  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}

sub ShiftSubTreeOverSubTreeRight {
# moves the (projectivized) subtree of a given node one node right (with respect to all nodes)
# see ShiftSubTreeOverSubTreeLeft

  my $top=ref($_[0]) ? $_[0] : $this;

  my @brothers = brothernodes($top);

  my $switch = $brothers[min(Index(\@brothers,$top)+1,$#brothers)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

    splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place
    splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeOverSubTreeLeftSkipHidden {
# moves the (projectivized) subtree of a given node one subtree left (with respect to non-hidden nodes only)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  my @brothers = brothernodes($top,1);

  my $switch = $brothers[max(Index(\@brothers,$top)-1,0)];

  my $all=GetNodesExceptST([$top,$switch]);  # all nodes except the nodes depending on the given node

#  my $allvis=GetNodesExceptST([$top,$switch],1); # all visible (ie non-hidden) nodes except the nodes depending on the given nodes
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtree back
    #  - thus the subtree gets projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

      splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
      splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place

  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeOverSubTreeRightSkipHidden {
# moves the (projectivized) subtree of a given node one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeOverSubTreeLeftSkipHidden
  my $top=ref($_[0]) ? $_[0] : $this;

  my @brothers = brothernodes($top,1);

  my $switch = $brothers[min(Index(\@brothers,$top)+1,$#brothers)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

    splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place
    splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place

    }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}

