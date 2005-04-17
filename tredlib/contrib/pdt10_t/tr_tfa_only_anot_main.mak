## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2005-04-17 19:48:10 pajas>

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

#  Tectogrammatic->upgrade_file();

  if ($grp->{FSFile} and !patterns_forced() and !$grp->{FSFile}->hint()) {
    TFA->default_tfa_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
#	   "Copy Trees ...") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['TFA']);
  SwitchContext('TFA');
  $FileNotSaved=0;
}
#endif

#ifdef TRED
sub file_resumed_hook {
  SwitchContext('TFA');
}
#endif

#include "tred_mac_common.mak"
sub CutToClipboard {}
sub PasteFromClipboard {}


sub node_release_hook {
  my ($node)=@_;
  return 'stop' unless $node->{func} eq 'RHEM';
}

#binding-context TFA
#include <contrib/tfa/tfa.mak>

sub node_release_hook {
  my ($node)=@_;
  return 'stop' unless $node->{func} eq 'RHEM';
}
