# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.

#encoding iso-8859-2

BEGIN { import PML_A; }
sub first (&@);

=pod

=head1 PML_A_View

PML_A_View.mak - Miscellaneous macros for viewing the analytic layer of
Prague Dependency Treebank (PDT) 2.0.

=cut

sub node_release_hook     { 'stop' }
sub enable_attr_hook      { 'stop' }
sub enable_edit_node_hook { 'stop' }

sub switch_context_hook {
  &PML_A::switch_context_hook;
  disable_node_menu_items() if GUI();
}

sub pre_switch_context_hook {
  my ($prev,$current)=@_;
  return if $prev eq $current;
  enable_node_menu_items() if GUI();
}
