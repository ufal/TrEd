## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-05-28 12:37:29 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#include "tred_mac_common.mak"

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

#bind GotoFileAsk to Alt+G menu Go to file...
sub GotoFileAsk {
  my $to=main::QueryString($grp->{framegroup},"Give a File Number","Number");
  return unless $to=~/^\s*\d+\s*$/;
  if (GotoFileNo($to-1)) {
    $FileNotSaved = GetFileSaveStatus();
  } else {
    ChangingFile(0);
  }
}


sub file_resumed_hook {
  SwitchContext('Quotation');
}
#endif

## add few custom bindings to predefined subroutines
sub CutToClipboard {}
sub PasteFromClipboard {}


#binding-context Quotation
#include "tr_quotation_common.mak"


