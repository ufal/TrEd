# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.

#encoding iso-8859-2

BEGIN { import PML_T; }
sub first (&@);

=pod

=head1 PML_T_View

PML_T_View.mak - Miscellaneous macros for the viewing tectogrammatic layer
of Prague Dependency Treebank (PDT) 2.0.

=over 4

=cut

sub node_release_hook     { 'stop' }
sub enable_attr_hook      { 'stop' }
sub enable_edit_node_hook { 'stop' }

sub switch_context_hook {
  &PML_T::switch_context_hook;
  disable_node_menu_items() if GUI();
}

sub pre_switch_context_hook {
  my ($prev,$current)=@_;
  return if $prev eq $current;
  enable_node_menu_items() if GUI();
}

=item ShowValFrames

Displays valency frames for the lemma of the current node and
highlights those assigned to that node.

=cut

sub ShowValFrames {
  PML_T::OpenValFrameList($this,-noadd => 1,-no_assign => 1);
}

=back

=cut
