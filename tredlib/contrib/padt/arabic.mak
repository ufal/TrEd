# -*- cperl -*-

#include "arabic_common.mak"

#include "MorphoTrees.mak"
#include "Analytic.mak"
#include "DeepLevels.mak"
#include "PhraseTrees.mak"

#binding-context TredMacro

package TredMacro;

sub start_hook {
  UnbindBuiltin('Ctrl+Home');
  UnbindBuiltin('Ctrl+End');
  return;
}

push @TredMacro::AUTO_CONTEXT_GUESSING,  sub {
  my $res  =
    ($grp->{FSFile}->FS()->isList('type') and
       grep { /token_node|word_node/ } $grp->{FSFile}->FS()->listValues('type'))
  ? 'MorphoTrees' :
    ($grp->{FSFile}->FS()->isList('func') and
       grep { /ACT|PAT|ADDR|EFF|ORIG/ } $grp->{FSFile}->FS()->listValues('func'))
  ? 'DeepLevels' :
    ( $grp->{FSFile}->FS->exists('afun') and $grp->{FSFile}->FS->exists('x_morph') )
  ?    'Analytic' :
    ();
  return $res;
}
