# Automatically converted from Graph macros by graph2tred to Perl.         -*-cperl-*-.
## author: Alena Bohmova
## Time-stamp: <2001-03-06 11:28:45 pajas>

package Tectogrammatic;
@ISA=qw(TredMacro main);
import TredMacro;
import main;

sub switch_context_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!
  print "Tecto\n";
  unless ($grp->{BalloonPattern}) {
    SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>');
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      "afun:\t\${afun}\ntag:\t\${tag}");
  }
  $FileNotSaved=0;
}

sub QueryTrlemma {
  my $node=shift;
  my @trs=
    #disp  trlemma gender number
    (['Gen','Gen','???','???'],
     ['Neg','Neg','???','???'],
     ['Emp','Emp','???','???'],
     ['Cor','Cor','???','???'],
     ['???','???','???','???'],
     ['Forn','Forn','???','???'],
     ['já','já','???','SG'],
     ['ty','ty','???','SG'],
     ['on-¾iv.','on','ANIM','SG'],
     ['on-ne¾iv.','on','INAN','SG'],
     ['ona','on','FEM','SG'],
     ['ono','on','NEUT','SG'],
     ['my','já','???','PL'],
     ['vy','ty','???','PL'],
     ['oni-¾iv.','on','ANIM','PL'],
     ['ony-ne¾iv','on','INAN','PL'],
     ['ony-¾en.','on','FEM','PL'],
     ['ona-pl-neut.','on','NEUT','PL']);
  my @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      $node->{gender} eq $_->[2] and
	$node->{number} eq $_->[3]
      }  @trs;
  @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      ($node->{gender} eq $_->[2] or
       $node->{number} eq $_->[3])
    }  @trs unless (@selected>0);
  if (@selected>0) {
    @selected=($selected[0]->[0]);
    print "Found @selected\n";
  }
  else {
    @selected=($node->{trlemma});
    print "Not found, using @selected\n";
  }
  if (main::selectValuesDialog($grp,$atr,
			   [ map { &main::encode($_->[0]) } @trs ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep {$_->[0] eq &main::decode($selected[0])} @trs);

    $node->{trlemma}=$vals->[1];
    $node->{gender}=$vals->[2];
    $node->{number}=$vals->[3];
    return 1;
  }
  return 0;
}

sub do_edit_attr_hook {
  my ($atr,$node)=@_;
  print STDERR "edit? $atr",$node->{ord},"\n";
  if ($atr eq 'trlemma' and $node->{ord}=~/\./) {
    QueryTrlemma($node);
    Redraw();                      # This is because tred does not
                                   # redraw automatically after hooks.
    $FileNotSaved=1;
    return 'stop';
  }
  return 1;
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:func|coref|reltype|aspect|err1)$/) {
    return "stop";
  }
}

sub about_file_hook {
  my $msgref=shift;
  if ($root->{TR} and $root->{TR} ne 'hide') {
    $$msgref="Signed by $root->{TR}\n";
  }
}

sub rotate_attrib {
  my ($val)=@_;
  my @vals=split(/\|/,$val);
  return $val unless (@vals>1);
  @vals=(@vals[1..$#vals],$vals[0]);
  return join('|',@vals);
}

# bind rotate_func to Ctrl+space menu Rotate Functor Values
sub rotate_func {
  $this->{func}=rotate_attrib($this->{func});
}

## add few custom bindings to predefined subroutines

#x bind Save to F2 menu Save File
#x bind SaveAndPrevFile to F11 menu Save and Go to Next File
#x bind SaveAndNextFile to F12 menu Save and Go to Next File
# bind Find to F3 menu Find
# bind FindNext to F4 menu Find Next

#x bind NewRBrother to F7 menu New Node (r-brother)
#x bind NewSon to Shift+F7 menu New Node (son)
#x bind DeleteThisNode to F8 menu Delete Node
#x bind CopyValues to F5 menu Copy Values
#x bind PasteValues to F6 menu Paste Values
#x bind PrevTree to key comma
#x bind NextTree to key period

#include contrib/tredtr.mak

################################################
## Overriding definitions of contrib/tredtr.mak

sub _key_Ctrl_Shift_X {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  unless (QueryTrlemma($this)) {
   DeleteCurrentNode();
  }
}


## (overriding definitions of contrib/tredtr.mak)
sub GetNewOrd {

  my $base=0;
  my $suff=0;
  my $node;

  print STDERR "looking for a new value\n";



  if ($pPar2) {
    $base=$1 if $pPar2->{ord}=~/^([0-9]+)/;
  }

  foreach $node (@nodes) {
    $suff=$1 if ($node->{ord}=~/^$base\.([0-9]+)$/ and $1>$suff);
  }

  $sPar2="$base.".($suff+1);
  print STDERR "found $sPar2\n";
  return $sPar2;            # for future compatibility
}


sub AfunAssign {
  my $t, $n;

  $t = $this;
  if ($t->{'afun'} ne 'AuxS') {
    if ($t->{'afun'} ne '???') {
      $t->{'afunprev'} = $t->{'afun'};
    }
    $t->{'afun'} = $sPar1;
    $iPrevAfunAssigned = $t->{'ord'};
    $this=NextNode($this);
  }

}

sub GoNextVisible {
  $pReturn = NextVisibleNode($pPar1,$pPar2);
}

sub TFAAssign {
  if (Parent($this)) {
    $this->{'tfa'} = $sPar1;
    $this=NextVisibleNode($this);
  }
}

sub FuncAssign {
  if (Parent($this)) {
    $this->{'func'} = $sPar1;
    $this=NextVisibleNode($this);
  }
}


