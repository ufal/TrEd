## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-09-04 11:09:02 pajas>

package Corref;

use base qw(TredMacro);
import TredMacro;

#bind default_tr_attrs F1
#insert default_tr_attrs as menu Display default attributes
sub default_tr_attrs {
    SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '${func}<? "_#{custom2}\${reltype}\${memberof}" if "$${memberof}$${reltype}" =~ /CO|AP|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>',
		    '${gender}.${number}',
		    '${coref}',
		    '${corsnt}'
		   );
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      '<?"\ncommentA:\t\${commentA}\n" if $${commentA} ne "" ?>'.
		      "gender\t\${gender}\nnumber:\t\${number}");
}

sub sort_attrs_hook {
  my ($ar)=@_;
  @$ar = (grep($grp->{FSFile}->FS->exists($_),
	       'trlemma','func','form','coref','corsnt','gender','number','memberof','aspect','commentA'),
	  sort {uc($a) cmp uc($b)}
	  grep(!/^(?:trlemma|func|form|coref|corsnt|gender|number|commentA|memberof|aspect)$/,@$ar));
  return 1;
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:coref|corsnt|gender|number)$/) {
    return "stop";
  }
}

sub about_file_hook {
  my $msgref=shift;
  if ($root->{TR} and $root->{TR} ne 'hide') {
    $$msgref="Signed by $root->{TR}\n";
  }
}

# bind edit_commentA to key exclam menu Edit annotator's comment
# bind edit_commentA to key Shift+1
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

#bind fill_empty_attrs to key Space
sub fill_empty_attrs {
  foreach (qw/coref gender number corsnt/) {
    $this->{$_} = '???' if ($this->{$_} eq "");
  }
}
