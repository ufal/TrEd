# -*- cperl -*-
package TFA; # package for the annotation of topic-focus articulation
use base qw(Tectogrammatic);
import Tectogrammatic;


#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind tfa_focus to f menu tfa = focus
#bind tfa_topic to t menu tfa = topic
#bind tfa_C to c menu tfa = contrast
#bind tfa_NA to a menu tfa = NA
#bind tfa_qm to n menu tfa = ???
#bind ProjectivizeSubTree to p menu Projectivize subtree
#bind ShiftSTLeft to Alt+Left menu Shift subtree to the left
#bind ShiftSTRight to Alt+Right menu Shift subtree to the right
#bind OrderSTByTFA to o menu Order subtree by TFA


sub switch_context_hook {
  if ($grp->{FSFile}) {
    SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		    '<? Parent($node) ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		    '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		    '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		   );
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      "afun:\t\${afun}\ntag:\t\${tag}");
  }
  $FileNotSaved=0;
  return "1";
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:tfa|err1)$/) {
    return "stop";
  }
}

#include tfa_common.mak








