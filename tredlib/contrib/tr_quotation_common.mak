## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-05-27 15:57:41 pajas>

package Quotation;

use base qw(TredMacro);
import TredMacro;

sub do_edit_attr_hook {
  Tectogrammatic::do_edit_attr_hook(@_);
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  return 'stop' if ($atr!~/^(?:quot_start|quot_member|quot_color)$/);
}

#bind edit_commentA to exclam menu Edit annotator's comment
#bind edit_commentA to exclam
sub edit_commentA {
  if (not FS()->exists('commentA')) {
    ToplevelFrame()->messageBox
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
  $value=main::QueryString($grp->{framegroup},"Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}


#include "quotation.mak"
