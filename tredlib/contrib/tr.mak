## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-09-18 16:49:55 pajas>

package Tectogrammatic;

use base qw(TredMacro);
import TredMacro;


sub switch_context_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  if ($grp->{FSFile} and
      GetSpecialPattern('patterns') ne 'force' and
      !$grp->{FSFile}->hint()
     ) {
    default_tr_attrs();
  }
  $FileNotSaved=0;
}

#include <contrib/tr_common.mak>
