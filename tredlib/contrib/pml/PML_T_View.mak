# -*- cperl -*-

#ifndef PML_T_View
#define PML_T_View

#include "PML_T.mak"

package PML_T_View;

#binding-context PML_T_View

#include <contrib/support/unbind_edit.inc>

#include "PML_T_View.inc"

#bind AnalyticalTree to Ctrl+A menu Display corresponding analytical tree
#bind GotoTree to Alt+g menu Goto Tree
#bind ShowValFrames to Ctrl+Return menu Show valency frames and highlight assigned
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
#bind JumpToAntecedentCompl to Alt+j menu Jump to complement coreference antecedent
#bind JumpToAntecedentText to Ctrl+j menu Jump to textual coreference antecedent
#bind JumpToAntecedentGram to J menu Jump to grammatical coreference antecedent

1;

#endif PML_T_View
