# -*- cperl -*-

=head1 fold_subtree.inc

This file can add support for folding (collapsing) subtrees to any macro context.

=head2 USAGE

1. Add these lines to your macro context:

  #include <contrib/support/fold_subtree.inc>
  #bind fold_subtree_toggle to SOME_KEY as menu Fold/unfold current subtree (toggle)

and possibly

  #bind fold_subtree_unfold_all to OTHER_KEY as menu Unfold all in the current subtree

replacing I<SOME_KEY> and I<OTHER_KEY> with suitable key bindings.

2. Add the following lines to your stylesheet:

  style:<? "#{Node-hide:1}" if FileUserData('hide')->{$this}; ?>
  style:<? "#{Oval-fill:blue}#{Node-shape:rectangle}"
              if FileUserData('fold')->{$this} ?>

The fist line does the folding, the second defines the visual style
for the root of a folded subtree (blue rectangle in this case). Adjust it
as you need.

=cut

sub fold_subtree_toggle {
  my $hide = FileUserData("hide") || {};   # hash nodes not to show
  my $fold = FileUserData("fold") || {};   # fold-state of a subtree
  my $folded = $fold->{$this}; # currently folded

  $fold->{$this}=!$folded; # toggle
  my $node=$this->firstson;
  while ($node) {
     $hide->{$node}=!$folded; # toggle visibility

     if ($fold->{$node}) {
        # this is a folded subtree within our folded subtree
        # we skip it, keeping it folded and the nodes hidden
        $node=$node->following_right_or_up($this);
     } else {
        # next node
        $node=$node->following($this);
     }
  }
  # store the data
  FileUserData("hide",$hide);
  FileUserData("fold",$fold);
  ChangingFile(0);
}

sub fold_subtree_unfold_all {
  my $hide = FileUserData("hide") || {};
  my $fold = FileUserData("fold") || {};
  my $folded = $fold->{$this}; # currently folded

  delete $fold->{$this};
  my $node=$this->firstson;
  while ($node) {
     delete $fold->{$node};
     delete $hide->{$node};
     $node=$node->following($this);
  }
  # store the data
  FileUserData("hide",$hide);
  FileUserData("fold",$fold);
  ChangingFile(0);
}
