## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2005-04-01 18:22:08 pajas>

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

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
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

#include <contrib/tred_mac_common.mak>

#binding-context Tectogrammatic
#include <contrib/tr.mak>

#binding-context TR_Diff
#include <contrib/trdiff.mak>

#binding-context TREdit
#include <contrib/edit.mak>

#include <contrib/pdt.mak>
