# -*- cperl -*-

#ifndef PML_A_View
#define PML_A_View

#include "PML_A.mak"

package PML_A_View;

#binding-context PML_A_View

#include <contrib/support/unbind_edit.inc>

#include "PML_A_View.inc"

#bind TectogrammaticalTree to Ctrl+R menu Display tectogrammatical tree
#bind GotoTree to Alt+g menu Goto Tree
#bind OpenValFrameList to Ctrl+Return menu Show valency lexicon entry for the current word

1;

#endif PML_A_View
