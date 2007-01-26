# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro

package TredMacro;

sub file_opened_hook {

    SwitchContext('DeepLevels');
}

#include "arabic_common.mak"

#include "DeepLevels.mak"
