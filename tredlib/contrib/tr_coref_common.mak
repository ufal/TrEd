## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2003-01-24 11:09:01 pajas>

package Coref;

use base qw(TredMacro);
import TredMacro;

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  if ($grp->{FSFile}) {
    SetDisplayAttrs('mode:Coref',
		    '<? "#{red}" if $${commentA} ne "" ?>${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '${func}<? "_#{custom2}\${reltype}\${memberof}" if "$${memberof}$${reltype}" =~ /CO|AP|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>',
		    'style:<? "#{Line-fill:green}" if $${NG_matching_edge} eq "true" ?>',
		    'style:<? "#{Oval-fill:green}" if $${NG_matching_node} eq "true" ?>'
		   );

    SetBalloonPattern(<<'__BALLOON__');
ID:	  ${AID}${TID}
<?
  "fw:\t${fw}\n" if $${fw} ne ""
?>form:	  ${form}
gender:	  ${gender}
number:	  ${number}<?
  "\ncoref:\t  \${coref}" if $${coref} ne ""
?><?
  "\ncortype:\t  \${cortype}" if $${cortype} ne ""
?><?
  "\ncorlemma:  \${corlemma}" if $${corlemma} ne ""
?><?
  "\ncommentA:\t   \${commentA}" if $${commentA} ne ""
?>
__BALLOON__

  }
}

sub sort_attrs_hook {
  my ($ar)=@_;
  @$ar = (grep($grp->{FSFile}->FS->exists($_),
	       'trlemma','func','form','coref','cortype','corlemma','gender','number',
	       'memberof','aspect','commentA'),
	  sort {uc($a) cmp uc($b)}
	  grep(!/^(?:trlemma|func|form|coref|cortype|corlemma|gender|number|commentA|memberof|aspect)$/,@$ar));
  return 1;
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:corlemma|gender|number)$/) {
    return "stop";
  }
}

sub about_file_hook {
  my $msgref=shift;
  if ($root->{TR} and $root->{TR} ne 'hide') {
    $$msgref="Signed by $root->{TR}\n";
  }
}

#bind edit_commentA to exclam menu Edit annotator's comment
#bind edit_commentA to exclam
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
  $value=main::QueryString($grp->{framegroup},"Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}

#bind fill_empty_attrs to Space
sub fill_empty_attrs {
  foreach (qw/coref gender number corsnt/) {
    $this->{$_} = '???' if ($this->{$_} eq "");
  }
}

#include "coref.mak"
