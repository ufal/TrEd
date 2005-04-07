# -*- cperl -*-

#ifndef PML_T_View
#define PML_T_View

#include "PML_T.mak"

package PML_T_View;

#binding-context PML_T_View

#encoding iso-8859-2


import PML_T;
sub first (&@);

=pod

=head1 PML_T_View

PML_T_View.mak - Miscelaneous macros for viewing tectogrammatic layer
of Prague Dependency Treebank (PDT) 2.0.

=head2 REFERENCE

=over 4

=cut

#bind analytical_tree to Ctrl+A menu Display corresponding analytical tree
#bind goto_tree to Alt+g menu Goto Tree

sub node_release_hook     { 'stop' }
sub enable_attr_hook      { 'stop' }
sub enable_edit_node_hook { 'stop' }

sub switch_context_hook {
  &PML_T::switch_context_hook;
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

#bind ShowFathers to Ctrl+f menu Show Fathers
#bind ShowChildren to Ctrl+c menu Show Children
#bind ShowExpand to Ctrl+e menu Show Expansion
#bind ShowDescendants to Ctrl+d menu Show Descendants
#bind ShowAncestors to Ctrl+a menu Show Ancestors
#bind ShowTrueSiblings to Ctrl+s menu Show Siblings
#bind ShowNearestNonMember to Ctrl+n menu Show Nearest Non-member
#bind NoShow to Ctrl+N menu No Show

#bind show_val_frames to Ctrl+Return menu Show valency frames and highlight assigned
sub show_val_frame {
  PML_T::open_val_frame_list(-noadd => 1,-no_assign => 1);
}

1;

=back

=cut

#endif PML_T_View
