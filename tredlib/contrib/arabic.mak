# -*- cperl -*-

#include <contrib/arabic_Analytic.mak>

#include <contrib/MorphoTrees.mak>

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    my $mode = GetSpecialPattern('mode');

    SwitchContext((defined $mode) ? $mode :
		  ($grp->{FSFile}->FS()->isList('type') and 
		   grep { /token_node|word_node/ } $grp->{FSFile}->FS()->listValues('type'))
		  ? 'MorphoTrees' : 'Analytic');
}
