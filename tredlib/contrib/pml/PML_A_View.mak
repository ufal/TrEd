# -*- cperl -*-

#ifndef PML_A_View
#define PML_A_View

#include "PML_A.mak"

package PML_A_View;

#binding-context PML_A_View
#include <contrib/unbind_edit/unbind_edit.mak>

#encoding iso-8859-2


import PML_A;
sub first (&@);

=pod

=head1 PML_A_View

PML_A_View.mak - Miscellaneous macros for viewing the analytic layer of
Prague Dependency Treebank (PDT) 2.0.

=cut

#bind TectogrammaticalTree to Ctrl+R menu Display tectogrammatical tree
#bind GotoTree to Alt+g menu Goto Tree

sub node_release_hook     { 'stop' }
sub enable_attr_hook      { 'stop' }
sub enable_edit_node_hook { 'stop' }

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

#bind OpenValFrameList to Ctrl+Return menu Show valency lexicon entry for the current word


1;

#endif PML_A_View
