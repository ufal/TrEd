## -*- cperl -*-
## author: Petr Pajas
## $Id$
## Time-stamp: <2005-04-17 20:20:54 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.

package TredMacro;

sub register_exit_hook ($) {
  my ($hook)=@_;
  push @global_exit_hooks,$hook;
}

sub unregister_exit_hook ($) {
  my ($hook)=@_;
  @global_exit_hooks=grep { $_ ne $hook } @global_exit_hooks;
}

sub exit_hook {
  foreach my $sub (@global_exit_hooks) {
    if (ref($sub) eq 'ARRAY') {
      my $realsub=shift @$sub;
      eval{ &{$realsub}(@$sub); };
    } else {
      eval{ &$sub(); };
    }
    stderr($@) if $@;
  }
}

#ifdef TRED
sub patterns_forced {
  return (grep { $_ eq 'force' } GetPatternsByPrefix('patterns',STYLESHEET_FROM_FILE()) ? 1 : 0)
}

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  EN_Tectogrammatic->upgrade_file();
  if ($grp->{FSFile} and ! patterns_forced() and !$grp->{FSFile}->hint()) {
    EN_Tectogrammatic->default_tr_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree",
	   "Copy Trees ...") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['EN_Tectogrammatic','TR_Diff']);
  SwitchContext('EN_Tectogrammatic');
  $FileNotSaved=0;
}
#endif

#ifdef TRED
sub file_resumed_hook {
  SwitchContext('EN_Tectogrammatic');
}
#endif

#include <contrib/pdt10_t/tred_mac_common.mak>

#binding-context Tectogrammatic
#include <contrib/pdt10_t/tr.mak>

#binding-context Coref
#include <contrib/pdt10_t/tr_coref_common.mak>

#binding-context EN_Tectogrammatic
#key-binding-adopt Coref
#key-binding-adopt Tectogrammatic
#include "tr_en.mak"
#unbind-key Space

#binding-context TR_Diff
#include <contrib/pdt10_t/trdiff.mak>

#include <contrib/pdt10_t/pdt.mak>

