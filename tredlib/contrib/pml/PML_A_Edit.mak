# -*- cperl -*-

#ifndef PML_A_Edit
#define PML_A_Edit

#include "PML_A.mak"

package PML_A_Edit;

#binding-context PML_A_Edit

#include "PML_A_Edit.inc"

#bind AddThisToALexRf to Ctrl+plus menu Add This to a/lex.rf of Marked Node
#bind AddThisToALexRf to Ctrl+KP_Add
#bind AddThisToAAuxRf to + menu Add This to a/aux.rf of Marked Node
#bind RemoveThisFromARf to minus menu Remove This from a/*.rf of Marked Node
#bind RemoveThisFromARf to KP_Subtract
#bind EditMLemma to L menu Edit morphological lemma
#bind EditMTag to T menu Edit morphological tag
#bind EditAfun to a menu Edit afun
#bind RotateMember to m menu Change is_member
#bind RotateParenthesisRoot to p menu Change is_parenthesis_root
#bind TectogrammaticalTree to Ctrl+R menu Display tectogrammatical tree
#bind GotoTree to Alt+g menu Goto Tree
#bind OpenValFrameList to Ctrl+Return menu Show valency lexicon entry for the current word

#include "PML_A_AutoAfun.mak"
#bind assign_afun_auto Ctrl+a menu Auto-assign afun to the current node
#bind assign_all_afun_auto to Ctrl+A menu Auto-assign afun to all nodes without afun in the tree


1;

#endif PML_A_Edit
