## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-09-18 16:49:37 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  if ($grp->{FSFile} and
      GetSpecialPattern('patterns') ne 'force' and
      !$grp->{FSFile}->hint()) {
    Tectogrammatic->default_tr_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Tectogrammatic','TR_Diff']);
  SwitchContext('Tectogrammatic');
  $FileNotSaved=0;
}

sub file_resumed_hook {
  SwitchContext('Tectogrammatic');
}

#include <contrib/tred_mac_common.mak>

#binding-context Tectogrammatic
#include <contrib/tr.mak>

#binding-context TR_Diff
#include <contrib/trdiff.mak>

#include <contrib/pdt.mak>
