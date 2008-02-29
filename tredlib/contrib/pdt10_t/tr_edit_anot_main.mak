## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2008-02-26 12:28:15 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#ifdef TRED
sub patterns_forced {
  return (grep { $_ eq 'force' } GetPatternsByPrefix('patterns',STYLESHEET_FROM_FILE()) ? 1 : 0)
}

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Tectogrammatic->upgrade_file();

  if ($grp->{FSFile} and !patterns_forced() and !$grp->{FSFile}->hint()) {
    Tectogrammatic->default_tr_attrs();
  }

  disable_node_menu_items() if GUI();
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Tectogrammatic','TR_Diff','TREdit']);
  SwitchContext('Tectogrammatic');
  $FileNotSaved=0;
}
#endif

#ifdef TRED
sub file_resumed_hook {
#  SwitchContext('Tectogrammatic');
}
#endif

#include "tred_mac_common.mak"

#binding-context Tectogrammatic
#include "tr.mak"

#binding-context TR_Diff
#include "trdiff.mak"

#binding-context TREdit
#include "edit.mak"

#include "pdt.mak"
