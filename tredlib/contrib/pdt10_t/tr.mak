## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2005-04-01 18:21:48 pajas>

package Tectogrammatic;

use base qw(TredMacro);
import TredMacro;


sub patterns_forced {
  return (grep { $_ eq 'force' } GetPatternsByPrefix('patterns',STYLESHEET_FROM_FILE()) ? 1 : 0)
}

sub switch_context_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  if ($grp->{FSFile} and !patterns_forced() and !$grp->{FSFile}->hint()
     ) {
    default_tr_attrs();
  }
  $FileNotSaved=0;
}

#include "tr_common.mak"

#include "tr_vallex_transform.mak"

