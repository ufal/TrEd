## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-05-27 16:21:00 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#include <contrib/tred_mac_common.mak>

#ifdef TRED
sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Quotation::initquot() if $grp->{FSFile};

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Quotation']);
  SwitchContext('Quotation');
  $FileNotSaved=0;
}
#endif

#ifdef TRED
sub file_resumed_hook {
  SwitchContext('Quotation');
}
#endif

## add few custom bindings to predefined subroutines
sub CutToClipboard {}
sub PasteFromClipboard {}


#binding-context Quotation
#include <contrib/tr_quotation_common.mak>


