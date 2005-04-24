# -*- cperl -*-

#ifndef PML_A_View
#define PML_A_View

#include "PML_A.mak"

package PML_A_View;

#binding-context PML_A_View

#encoding iso-8859-2


import PML_A;
sub first (&@);

=pod

=head1 PML_A_View

PML_A_View.mak - Miscelaneous macros for viewing analytic layer of
Prague Dependency Treebank (PDT) 2.0.

=over 4

=cut

#bind TectogrammaticalTree to Ctrl+R menu Display tectogrammatical tree
#bind GotoTree to Alt+g menu Goto Tree

sub node_release_hook{
  return 'stop';
}#node_release_hook

sub enable_attr_hook{
  return'stop';
}#enable_attr_hook

sub switch_context_hook {
  &PML_A::switch_context_hook;
  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
}

sub pre_switch_context_hook {
  my ($prev,$current)=@_;
  return if $prev eq $current;
  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'normal');
  }

}


1;

=back

=cut

#endif PML_A_View
