## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-11-26 19:17:13 pajas>

package Tectogrammatic;

use base qw(TredMacro);
import TredMacro;


sub switch_context_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  if ($grp->{FSFile} and !$grp->{FSFile}->hint()) {
    default_tr_attrs();
  }
  $FileNotSaved=0;
}

#include tr_common.mak
