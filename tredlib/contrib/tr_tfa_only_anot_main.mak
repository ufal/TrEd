## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-10-09 16:04:10 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Tectogrammatic->upgrade_file();

  if ($grp->{FSFile} and
      GetSpecialPattern('patterns') ne 'force' and
      !$grp->{FSFile}->hint()) {
    TFA->default_tfa_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
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


