# -*- cperl -*-

#ifndef PML_T_Edit
#define PML_T_Edit

#include "PML_T.mak"

package PML_T_Edit;

#binding-context PML_T_Edit

#include "PML_T_Edit.inc"

#key-binding-adopt PML_T_View
#menu-binding-adopt PML_T_View

#bind ChooseValFrame to Ctrl+Return menu Select and assign valency frame
#bind RememberNode to space menu Remember Node
#bind TextArowToRemembered to Ctrl+space menu Make Textual Coreference Arrow to Remembered Node
#bind ForgetRemembered to Shift+space menu Forget Remembered Node
#bind MarkForARf to + menu Mark for reference changes and enter A-layer
#bind RotateGenerated to g menu Change is_generated
#bind RotateMember to m menu Change is_member
#bind RotateParenthesis to p menu Change is_parenthesis
#bind EditFunctor to f menu Edit Functor
#bind EditTfa to t menu Edit TFA
#bind EditTLemma to l menu Edit t_lemma
#bind EditNodetype to N menu Edit Node Type
#bind EditGram to G menu Edit Grammatemes
#bind AnnotateSegm to s menu Annotate Special Coreference - Segment
#bind AnnotateExoph to e menu Annotate Special Coreference - Exophora
#bind AddNode to Insert menu Insert New Node
#bind MoveNodeLeft to Ctrl+Left menu Move node to the left
#bind MoveNodeRight to Ctrl+Right menu Move node to the right
#bind MoveSTLeft to Alt+Left menu Move subtree to the left
#bind MoveSTRight to Alt+Right menu Move subtree to the right
#bind DeleteNode to Delete menu Delete Node
#bind DeleteSubtree to Ctrl+Delete menu Delete Subtree

1;

#endif PML_T_Edit
