# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro

package TredMacro;

sub file_opened_hook {

    SwitchContext('PhraseTrees');
}

#include "arabic_common.mak"

#include "PhraseTrees.mak"
