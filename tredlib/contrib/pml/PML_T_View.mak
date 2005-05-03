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

PML_T_View.mak - Miscellaneous macros for the viewing tectogrammatic layer
of Prague Dependency Treebank (PDT) 2.0.

=over 4

=cut

#bind AnalyticalTree to Ctrl+A menu Display corresponding analytical tree
#bind GotoTree to Alt+g menu Goto Tree

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

#bind ShowValFrames to Ctrl+Return menu Show valency frames and highlight assigned
sub ShowValFrames {
  PML_T::OpenValFrameList($this,-noadd => 1,-no_assign => 1);
}

#bind OpenValLexicon to Ctrl+Shift+Return menu Browse valency frame lexicon

#bind ShowEParents to Ctrl+p menu Show effective parents
#bind ShowEChildren to Ctrl+c menu Show effective children
#bind ShowExpand to Ctrl+e menu Show expansion
#bind ShowEDescendants to Ctrl+d menu Show effective descendants
#bind ShowEAncestors to Ctrl+a menu Show effective ancestors
#bind ShowESiblings to Ctrl+s menu Show effective siblings
#bind ShowNearestNonMember to Ctrl+n menu Show nearest non-member
#bind NoShow to Ctrl+N menu No Show
#bind ShowAssignedValFrames to Ctrl+v menu Show assigned valency frame(s)
#bind JumpToAntecedentAll to j menu Jump to coreference antecedent
#bind JumpToAntecedentCompl to Alt+j menu Jump to coreference antecedent
#bind JumpToAntecedentText to Ctrl+j menu Jump to coreference antecedent
#bind JumpToAntecedentGram to J menu Jump to coreference antecedent

1;

=back

=cut

#endif PML_T_View
