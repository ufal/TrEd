# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    SwitchContext('MorphoTrees');
}

#include <contrib/arabic_common.mak>

#include <contrib/MorphoTrees.mak>
