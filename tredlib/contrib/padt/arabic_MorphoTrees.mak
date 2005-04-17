# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    SwitchContext('MorphoTrees');
}

#include "arabic_common.mak"

#include "MorphoTrees.mak"
