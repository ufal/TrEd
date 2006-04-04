# -*- cperl -*-

#include "arabic_common.mak"

#include "MorphoTrees.mak"
#include "Analytic.mak"
#include "DeepLevels.mak"

#binding-context TredMacro;
package TredMacro;

sub file_opened_hook {

    my ($mode) = GetPatternsByPrefix('mode',STYLESHEET_FROM_FILE());

    SwitchContext((defined $mode) ? $mode :
          ($grp->{FSFile}->FS()->isList('type') and
           grep { /token_node|word_node/ } $grp->{FSFile}->FS()->listValues('type'))
          ? 'MorphoTrees' :
          ($grp->{FSFile}->FS()->isList('func') and
           grep { /ACT|PAT|ADDR|EFF|ORIG/ } $grp->{FSFile}->FS()->listValues('func'))
          ? 'DeepLevels' : 'Analytic');
}
