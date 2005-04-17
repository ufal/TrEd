# -*- cperl -*-

#include "arabic_Analytic.mak"

#include "MorphoTrees.mak"

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    my ($mode) = GetPatternsByPrefix('mode',STYLESHEET_FROM_FILE());

    SwitchContext((defined $mode) ? $mode :
		  ($grp->{FSFile}->FS()->isList('type') and 
		   grep { /token_node|word_node/ } $grp->{FSFile}->FS()->listValues('type'))
		  ? 'MorphoTrees' : 'Analytic');
}
