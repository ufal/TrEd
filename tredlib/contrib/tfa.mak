# -*- cperl -*-
package TFA; # package for the annotation of topic-focus articulation
use base qw(Tectogrammatic);
import Tectogrammatic;


#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind tfa_focus to F menu tfa = focus
#bind tfa_topic to T menu tfa = topic
#bind tfa_C to C menu tfa = contrast
#bind tfa_NA to A menu tfa = NA
#bind ProjectivizeSubTree to P menu Projectivize subtree
#bind ShiftSTLeft to Alt+Left menu Shift subtree to the left
#bind ShiftSTRight to Alt+Right menu Shift subtree to the right

sub switch_context_hook {

  SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		  '<? Parent($node) ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		  '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		  '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		 );
  SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		    "afun:\t\${afun}\ntag:\t\${tag}");
  $FileNotSaved=0;
  return "1";
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:tfa|err1)$/) {
    return "stop";
  }
}

#import tfa_common.mak
