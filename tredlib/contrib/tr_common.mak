## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-11-26 20:35:55 pajas>

## This file contains and imports most macros
## needed for Tectogrammatical annotation
##
## It is a base for other macro packages like tr.mak
## or tr_anot_main.mak which are used for various purposes

#include contrib/AFA.mak
#include contrib/ValLex/chooser.mak

#bind default_tr_attrs to key F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  print "Using standard patterns\n";
    SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '<?$${funcaux} if $${funcaux}=~/\#/?>${func}<? "_#{custom2}\${reltype}\${memberof}" if "$${memberof}$${reltype}" =~ /CO|AP|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>');
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      "afun:\t\${afun}\ntag:\t\${tag}".
		      '<?"\ncommentA:\t\${commentA}" if $${commentA} ne "" ?>'.
		      '<?"\nframe:\t\${framere}" if $${framere} ne "" ?>'.
		      '<?"\nframe_id:\t\${frameid}" if $${frameid} ne "" ?>');
  return 1;
}

sub sort_attrs_hook {
  my ($ar)=@_;
  @$ar = (grep($grp->{FSFile}->FS->exists($_),
	       'func','trlemma','form','afun','coref','reltype','memberof','aspect','commentA'),
	  sort {uc($a) cmp uc($b)}
	  grep(!/^(?:trlemma|func|form|afun|commentA|coref|reltype|memberof|aspect)$/,@$ar));
  return 1;
}

sub QuerySemtam {
  my $node=shift;
  my @trs=
    (
     ['tady', 'tady', 'LOC'],
     ['odsud', 'tady', 'DIR1'],
     ['tudy', 'tady', 'DIR2'],
     ['sem', 'tady', 'DIR3'],
     ['tam (kde?)', 'tam','LOC'],
     ['odtamtud', 'tam', 'DIR1'],
     ['tamtudy', 'tam', 'DIR2'],
     ['tam (kam?)', 'tam', 'DIR3']
    );
  my @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      $node->{func} eq $_->[2]
    }  @trs;
  @selected=grep { 
    $node->{trlemma} eq $_->[1]
  }  @trs unless (@selected>0);
  if (@selected>0) {
    @selected=($selected[0]->[0]);
  }
  else {
    @selected=($node->{trlemma});
  }
  if (main::selectValuesDialog($grp->{framegroup},$atr,
			   [ map { $_->[0] } @trs ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep { $_->[0] eq $selected[0] } @trs);

    $node->{trlemma}=$vals->[1];
    $node->{func}=$vals->[2];
    return 1;
  }
  return 0;
}

sub QueryTrlemma {
  my ($node,$assign_func)=@_;
  my @trs=
    #disp  trlemma gender number
    #
    # Predelat na entity: &Comma; &Colon; atd.
    #
    (['Comma','&Comma;','???','???','CONJ'],
     ['Colon','&Colon;','???','???','CONJ'],
     ['Dash','&Dash;','???','???','CONJ'],
     ['Lpar','&Lpar;','???','???'],
     ['Forn','&Forn;','???','???'],
     ['Rcp','&Rcp;','???','???','PAT'],
     ['Neg','&Neg;','???','???'],
     ['Cor','&Cor;','???','???'],
     ['Emp','&Emp;','???','???'],
     ['Gen','&Gen;','???','???'],
     ['stejnì','stejnì','???','???'],
     ['???','???','???','???'],
     ['já','já','???','SG'],
     ['ty','ty','???','SG'],
     ['on-¾iv.','on','ANIM','SG'],
     ['on-ne¾iv.','on','INAN','SG'],
     ['ona','on','FEM','SG'],
     ['ono','on','NEUT','SG'],
     ['my','my','???','PL'],
     ['vy','vy','???','PL'],
     ['oni-¾iv.','on','ANIM','PL'],
     ['ony-ne¾iv','on','INAN','PL'],
     ['ony-¾en.','on','FEM','PL'],
     ['ona-pl-neut.','on','NEUT','PL'],
     ['ten','ten','???','???'],
     ['tak','tak','???','???','EXT'],
    );
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
  }
  else {
    @selected=($node->{trlemma});
  }
  if (main::selectValuesDialog($grp->{framegroup},$atr,
			   [ map { &main::encode($_->[0]) } @trs ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep {$_->[0] eq &main::decode($selected[0])} @trs);

    $node->{trlemma}=$vals->[1];
    $node->{gender}=$vals->[2];
    $node->{number}=$vals->[3];
    if ($assign_func) {
      $node->{func}=$vals->[4] || '???';
    }
    return 1;
  }
  return 0;
}

sub do_edit_attr_hook {
  my ($atr,$node)=@_;
  if ($atr eq 'trlemma' and $node->{ord}=~/\./) {
    if ($node->{trlemma} =~ /tady|tam/ or
	$node->{func} =~ /DIR[1-3]|LOC/) {
      QuerySemtam($node);
    } else {
      QueryTrlemma($node);
    }
    Redraw();                      # This is because tred does not
                                   # redraw automatically after hooks.
    $FileNotSaved=1;
    return 'stop';
  }
  return 1;
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:func|coref|commentA|reltype|memberof|aspect|tfa|err1)$/) {
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


## add few custom bindings to predefined subroutines
#include contrib/tredtr.mak

################################################
## Overriding definitions of contrib/tredtr.mak

sub add_new_node {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  unless (QueryTrlemma($this,1)) {
    DeleteCurrentNode();
  }
}

# this is new (not overriden)
#bind AddNewLoc to key Ctrl+Shift+L menu Doplnit mistní doplnìní pod akt. vrchol
sub AddNewLoc {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  $this->{trlemma}='tady';
  unless (QuerySemtam($this)) {
   DeleteCurrentNode();
  }
}


## (overriding definitions of contrib/tredtr.mak)
sub GetNewOrd {

  my $base=0;
  my $suff=0;
  my $node;

  if ($pPar2) {
    $base=$1 if $pPar2->{ord}=~/^([0-9]+)/;
  }

  $node=$root;
  while ($node) {
    if ($node->{ord}=~/^$base\.([0-9]+)$/ and $1>$suff) {
      $suff=$1;
    }
    $node=$node->following;
  }

  $sPar2="$base.".($suff+1);
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
    clear_funcaux($this);
    $this=NextVisibleNode($this);
  }
}

#bind add_questionmarks_func to Ctrl+Shift+X menu Pridat k funktoru ???
sub add_questionmarks_func {
  $pPar1 = $this;
  $sPar1 = Union($pPar1->{'func'},'???');
  FuncAssign();
}

#######################################################
# Node shifting

#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftLeft to Shift+Q menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind ShiftRight to Shift+U menu posun uzel doprava

sub ShiftLeft {
  return unless ($this->{dord}>1);
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

sub NewVerb {
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pTatka;			# used as type "pointer"
  my $pNew;			# used as type "pointer"

  my $sNum;			# used as type "string"

  print STDERR "Running NewVerb\n";
  return unless ($root->{'reserve1'}=~'TR_TREE');

  $pT = $this;

  my @all=GetNodes();
  SortByOrd(\@all);
  NormalizeOrds(\@all);

  my $son=$pT->firstson;
  my $rb;

  $son=$son->rbrother() while ($son and $son->rbrother() and $son->{afun} !~ /ExD/);

  if ($son) {
    $this=$son;
    NewLBrother();
    $pNew=$this;
    $pNew->{sentord}=$son->{sentord}-1;

    $son=$pT->firstson();
    while ($son) {
      $rb=$son->rbrother();
      PasteNode(CutNode($son),$pNew) if ($son->{afun}=~/ExD/ and $son ne $pNew);
      $son=$rb;
    }
  } else {
    NewSon();
    $pNew=$this;
    $pNew->{sentord}=$pT->{sentord};
  }

  GetNewOrd();
  $sNum = $sPar2;

  $pNew->{'lemma'} = '-';
  $pNew->{'tag'} = '-';
  $pNew->{'form'} = '-';
  $pNew->{'afun'} = '---';
  $pNew->{'ord'} = $sNum;
  $pNew->{'trlemma'} = '&Emp;';
  $pNew->{'gender'} = '???';
  $pNew->{'number'} = '???';
  $pNew->{'degcmp'} = '???';
  $pNew->{'tense'} = '???';
  $pNew->{'aspect'} = '???';
  $pNew->{'iterativeness'} = '???';
  $pNew->{'verbmod'} = '???';
  $pNew->{'deontmod'} = '???';
  $pNew->{'sentmod'} = '???';
  $pNew->{'tfa'} = '???';
  $pNew->{'func'} = 'PRED';
  $pNew->{'gram'} = '???';
  $pNew->{'memberof'} = '???';
  $pNew->{'gender'} = '???';
  $pNew->{'number'} = '???';
  $pNew->{'degcmp'} = '???';
  $pNew->{'tense'} = '???';
  $pNew->{'aspect'} = '???';
  $pNew->{'iterativeness'} = '???';
  $pNew->{'verbmod'} = '???';
  $pNew->{'deontmod'} = '???';
  $pNew->{'sentmod'} = '???';
  $pNew->{'tfa'} = '???';
  $pNew->{'func'} = '???';
  $pNew->{'gram'} = '???';
  $pNew->{'memberof'} = '???';
  $pNew->{'del'} = 'ELID';
  $pNew->{'quoted'} = '???';
  $pNew->{'dsp'} = '???';
  $pNew->{'corsnt'} = '???';
  $pNew->{'antec'} = '???';
  $pNew->{'parenthesis'} = '???';
  $pNew->{'recip'} = '???';
  $pNew->{'dispmod'} = '???';
  $pNew->{'trneg'} = 'NA';

  $this=$pNew;
}

sub ConnectID {
  $sReturn =  $sPar1.'|'.$sPar2;
}

sub DisconnectID {
  $sReturn  = $sPar1;
  $sReturn =~ s/(?:^|\|)$sPar2(?:\||$)//;
}
