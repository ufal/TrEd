## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-10-23 11:26:15 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#include <contrib/tred_mac_common.mak>

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Coref->default_tr_attrs() unless $grp->{FSFile};

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Coref','Tectogrammatic','TR_Diff']);
  SwitchContext('Coref');
  Coref->update_coref_file();
  $FileNotSaved=0;
}

sub file_resumed_hook {
  SwitchContext('Coref');
}

## add few custom bindings to predefined subroutines
sub CutToClipboard {}
sub PasteFromClipboard {}


#binding-context Coref
#include <contrib/tr_coref_common.mak>

#binding-context Tectogrammatic
#include <contrib/tr.mak>

package Tectogrammatic;

use base qw(TredMacro);
import TredMacro;

#include <contrib/tr_common.mak>

#binding-context TR_Diff
#include <contrib/trdiff.mak>
