## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2008-02-06 14:00:46 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#include "tred_mac_common.mak"

#ifdef TRED
sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Coref->default_tr_attrs() unless $grp->{FSFile};

  disable_node_menu_items() if GUI();
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Coref','Tectogrammatic','TR_Diff']);
  SwitchContext('Coref');
  Coref->update_coref_file();
  $FileNotSaved=0;
}
#endif

#ifdef TRED
sub file_resumed_hook {
  SwitchContext('Coref');
}
#endif

## add few custom bindings to predefined subroutines
sub CutToClipboard {}
sub PasteFromClipboard {}


#binding-context Coref
#include "tr_coref_common.mak"

#binding-context Tectogrammatic
#include "tr.mak"

package Tectogrammatic;

BEGIN { import TredMacro; }

#include "tr_common.mak"

#binding-context TR_Diff
#include "trdiff.mak"
