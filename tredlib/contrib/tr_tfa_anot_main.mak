## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-01-14 17:54:34 pajas>

#include <contrib/tred_mac_common.mak>

#ifdef TRED
sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings (unless patterns:force is used as a pattern)!

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
  $o->options(['Tectogrammatic','TFA','TR_Diff']);
  SwitchContext('TFA');
  $FileChanged=0;
}
#endif

#binding-context Tectogrammatic
#include <contrib/tr.mak>

#ifdef TRED
sub switch_context_hook {
  default_tr_attrs();
  $FileChanged=0;
  return "1";
}
#endif

#binding-context TFA
#include <contrib/tfa.mak>


#bind tfa_focus to u menu tfa = focus
#bind tfa_topic to k menu tfa = topic
#bind tfa_C to Alt+k menu tfa = contrast
#bind tfa_NA to Alt+a menu tfa = NA
#bind ProjectivizeSubTree to Alt+p menu Projectivize subtree
#bind OrderSTByTFA to Alt+u menu Order subtree by TFA
