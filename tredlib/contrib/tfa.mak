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

#bind default_tfa_attrs to F8 menu Display default attributes
sub default_tfa_attrs {
  return unless $grp->{FSFile};
  SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		  '<? $this->parent ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		  '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		  '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		 );
  SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		    "afun:\t\${afun}\ntag:\t\${tag}");

}

#bind edit_commentA to exclam menu Edit annotator's comment
sub edit_commentA {
    if (not $grp->{FSFile}->FS->exists('commentA')) {
    $ToplevelFrame->messageBox
      (
       -icon => 'warning',
       -message => 'Sorry, no attribute for annotator\'s comment in this file',
       -title => 'Sorry',
       -type => 'OK'
      );
    $FileNotSaved=0;
    return;
  }
  my $value=$this->{commentA};
  $value=QueryString("Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}


sub switch_context_hook {
  default_tfa_attrs();
  $FileNotSaved=0;
  return "1";
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:tfa|err1)$/) {
    return "stop";
  }
}

#include <contrib/tfa_common.mak>








