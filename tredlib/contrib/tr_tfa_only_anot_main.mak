## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-04-24 09:25:39 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  unless ($grp->{FSFile}->hint()) {
    default_tr_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['TFA','TR_Diff']);
  SwitchContext('TFA');
  $FileNotSaved=0;
}

sub file_resumed_hook {
  SwitchContext('TFA');
}


#include <contrib/tred_mac_common.mak>

#binding-context Tectogrammatic
#include <contrib/tr.mak>

#binding-context TR_Diff
#include <contrib/trdiff.mak>

#binding-context TFA
#include <contrib/tfa.mak>


