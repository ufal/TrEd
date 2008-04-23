# -*- cperl -*-

#include "arabic_common.mak"

#include "MorphoTrees.mak"
#include "Analytic.mak"
#include "DeepLevels.mak"
#include "PhraseTrees.mak"

push @TredMacro::AUTO_CONTEXT_GUESSING, sub {
  
    return 'MorphoTrees' if $grp->{FSFile}->FS()->isList('type') and
                            grep { /[EP]|paragraph|entity/ } $grp->{FSFile}->FS()->listValues('type');
    
    return 'DeepLevels'  if $grp->{FSFile}->FS()->isList('func') and
                            grep { /ACT|PAT|ADDR|EFF|ORIG/ } $grp->{FSFile}->FS()->listValues('func');

    return 'Analytic'    if $grp->{FSFile}->FS()->exists('afun') and 
                            $grp->{FSFile}->FS()->exists('arabclause');

    return;
}
