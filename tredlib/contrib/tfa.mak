# -*- cperl -*-
package TFA; # package for the annotation of topic-focus articulation
use base qw(TredMacro);
import TredMacro;
#use base qw(Tectogrammatic);
#import Tectogrammatic;


#bind ShiftLeft to Ctrl+Left menu Move node to the left
#bind ShiftRight to Ctrl+Right menu Move node to the right
#bind tfa_focus to f menu tfa = focus
#bind tfa_topic to t menu tfa = topic
#bind tfa_C to c menu tfa = contrast
#bind tfa_NA to a menu tfa = NA
#bind tfa_qm to n menu tfa = ???
#bind ProjectivizeCurrentSubTree to p menu Projectivize subtree
#bind ProjectivizeTree to Ctrl+p menu Projectivize tree
#bind ShiftSTLeft to Alt+Left menu Move subtree to the left
#bind ShiftSTRight to Alt+Right menu Move subtree to the right
#bind ShiftSToverSTLeft to Ctrl+Alt+Left menu Switch subtree with subtree to the left
#bind ShiftSToverSTRight to Ctrl+Alt+Right menu Switch subtree with subtree to the right
#bind OrderSTByTFA to o menu Order subtree by TFA

#bind default_tfa_attrs to F8 menu Display default attributes
sub default_tfa_attrs {
  return unless $grp->{FSFile};
!   SetDisplayAttrs('<? "#{red}" if $${commentA} ne "" ?>${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		  '<? $this->parent ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		  '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		  '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		 );
  SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		    "afun:\t\${afun}\ntag:\t\${tag}");

}

#bind edit_commentA to exclam menu Edit annotator's comment
sub edit_commentA {
    if (not FS()->exists('commentA')) {
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
  if ($atr!~/^(?:tfa|commentA)$/) {
    return "stop";
  }
}

sub ShiftLeft {
  return unless (GetOrd($this)>1);
  if (HiddenVisible()) {
    ShiftNodeLeft($this);
  } else {
    ShiftNodeLeftSkipHidden($this,1);
  }
}

sub ShiftRight {
  return unless (Parent($this));
  if (HiddenVisible()) {
    ShiftNodeRight($this);
  } else {
    ShiftNodeRightSkipHidden($this);
  }
}

#include <contrib/tfa_common.mak>








