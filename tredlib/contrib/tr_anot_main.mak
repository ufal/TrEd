## -*- cperl -*-
## author: Petr Pajas
## $Id$
## Time-stamp: <2003-08-28 10:30:17 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

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
 

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  Tectogrammatic->upgrade_file();

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
