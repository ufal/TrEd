package TrEd::Basics;

BEGIN {
  use Fslib;
  require TrEd::MinMax;
  import TrEd::MinMax;

  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    $on_tree_change
    $on_node_change
    $on_current_change
    &gotoTree
    &nextTree
    &prevTree
    &newTree
    &newTreeAfter
    &pruneTree
    &newNode
    &pruneNode
    &setCurrent
  );
  use strict;
}


#
# The $grp parameter to the following two routines should be
# a hash reference, having at least the following keys:
#
# FSFile       => FSFile blessed reference of the current FSFile
# treeNo       => number of the current tree in the file
# macroContext => current context under which macros are run 
# currentNode  => pointer to the current node 
# root         => pointer to the root node of current tree
#

sub gotoTree {
  my $grp=shift;
  return unless $grp->{'FSFile'};
  my $no = max(0,min(shift,$grp->{FSFile}->lastTreeNo));
  return $no if ($no == $grp->{treeNo});
  $grp->{treeNo}=$no;
  $grp->{root}=$grp->{FSFile}->treeList->[$grp->{treeNo}];
  &$on_tree_change($grp,'gotoTree') if $on_tree_change;
  return $no;
}

sub nextTree {
  my ($grp)=@_;

  return 0 if ($grp->{treeNo} >= $grp->{FSFile}->lastTreeNo);
  gotoTree($grp,$grp->{treeNo}+1);
  return 1;
}

sub prevTree {
  my ($grp)=@_;
  return 0 if ($grp->{treeNo} <= 0);
  gotoTree($grp,$grp->{treeNo}-1);
  return 1;
}

sub newTree {
  my ($grp)=@_;

  my $nr=FSNode->new(); # blessing new root
  splice(@{$grp->{FSFile}->treeList}, $grp->{treeNo}, 0, $nr);
  $grp->{root}=$grp->{FSFile}->treeList->[$grp->{treeNo}];
  &$on_tree_change($grp,'newTree') if $on_tree_change;
  return 1;
}

sub newTreeAfter {
  my ($grp)=@_;

  my $nr=FSNode->new(); # blessing new root

  splice(@{$grp->{FSFile}->treeList}, ++$grp->{treeNo}, 0, $nr);
  $grp->{root}=$grp->{FSFile}->treeList->[$grp->{treeNo}];
  &$on_tree_change($grp,'newTreeAfter') if $on_tree_change;
  return 1;
}

sub pruneTree {
  my ($grp)=@_;

  return unless ($grp->{'FSFile'} and $grp->{FSFile}->treeList->[$grp->{treeNo}]);
  $grp->{root}=$grp->{FSFile}->treeList->[$grp->{treeNo}];
  splice(@{$grp->{FSFile}->treeList}, $grp->{treeNo}, 1);
  DeleteTree($grp->{root});

  $grp->{treeNo}=max(0,min($grp->{treeNo},$grp->{FSFile}->lastTreeNo));
#  $grp->{root} = undef;
  $grp->{root}=$grp->{FSFile}->treeList->[$grp->{treeNo}];
  &$on_tree_change($grp,'pruneTree') if $on_tree_change;
  return 1;
}


sub newNode {
  ## Adds new son to current node
  my ($grp)=@_;
  my $parent=$grp->{currentNode};
  return unless ($grp->{'FSFile'} and $parent);

  my $nd=FSNode->new();

  Paste($nd,$parent,$grp->{FSFile}->FS->defs);
  $nd->{$grp->{FSFile}->FS->order}=$parent->{$grp->{FSFile}->FS->order};

  setCurrent($grp,$nd);

  &$on_node_change($grp,'newNode') if $on_node_change;

  return $nd;
}

sub pruneNode {
  ## Deletes given node
  my ($grp,$node)=@_;
  my $t;
  return undef unless ($grp->{'FSFile'} and $node and $node->parent);

  Paste(Cut($t),$node->parent,$grp->{FSFile}->FS->defs)
    while ($t=$node->firstson);

  setCurrent($grp,$node->parent) if ($node == $grp->{currentNode});
  $t=DeleteLeaf($node);

  &$on_node_change($grp,'newTree') if $on_node_change;
  return $t;
}

sub setCurrent {
  my ($grp,$node)=@_;
  my $prev=$grp->{currentNode};
  $grp->{'currentNode'}=$node;
  &$on_current_change($grp,$node,$prev,'setCurrent') if $on_current_change;
}

1;

