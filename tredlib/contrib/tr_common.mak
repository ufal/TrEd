## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-12-13 14:59:38 pajas>

## This file contains and imports most macros
## needed for Tectogrammatical annotation
##
## It is a base for other macro packages like tr.mak
## or tr_anot_main.mak which are used for various purposes

#include <contrib/AFA.mak>

#include <contrib/ValLex/chooser.mak>
#include <contrib/ValLex/adverb.mak>

#bind OpenEditor to Ctrl+Shift+Return menu Zobraz valenèní slovník

#bind choose_frame_or_advfunc to Ctrl+Return menu Vyber ramec pro sloveso, funktor pro adverbium
#bind choose_frame_or_advfunc to F1 menu Vyber ramec pro sloveso, funktor pro adverbium

sub choose_frame_or_advfunc {
  my $tag;
  foreach (qw(tag tagMD_a tagMD_b)) {
    if ($this->{$_} ne "" and
	$this->{$_} ne "-") {
      $tag=$_;
      last;
    }
  }
  if ($this->{$tag}=~/^[VAN]/) {	# co neni sloveso, subst ni adj, je adv :))))
    ChooseFrame();
  } else {
    ChooseAdverbFunc();
  }
}

sub upgrade_file {
  # Add new functor OPER if not present in header
  my $defs=$grp->{FSFile}->FS->defs;
  if (exists($defs->{func}) and $defs->{func} !~ /OPER/) {
    $fsfunc=$defs->{func}=~s/(NORM)/NORM|OPER/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /CONTRA/) {
    $fsfunc=$defs->{func}=~s/(CONFR)/CONFR|CONTRA/;
  }
  if (exists($defs->{antec}) and $defs->{func} !~ /OPER/) {
    $fsfunc=$defs->{antec}=~s/(NORM)/NORM|OPER/;
  }
  if (exists($defs->{memberof}) and $defs->{memberof} =~ /CO\|AP\|PA/) {
    $defs->{memberof}=~s/CO\|AP\|PA/CO|AP/;
  }
  if (exists($defs->{gram}) and $defs->{gram} !~ /MULT\|RATIO/) {
    $defs->{gram}=~s/LESS/LESS|MULT|RATIO/;
  }
  unless (exists($defs->{operand})) {
    AppendFSHeader('@P operand',
		   '@L operand|---|OP|NIL|???');
  }
  upgrade_file_to_tid_aidrefs();
}

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  print "Using standard patterns\n";
    SetDisplayAttrs('<? "#{red}" if $${commentA} ne "" ?>${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '<?$${funcaux} if $${funcaux}=~/\#/?>${func}<? "_#{custom2}\${memberof}" if $${memberof} =~ /CO|AP|PA/ ?><? "_#{custom2}\${operand}" if $${operand} eq "OP" ?><? "#{custom2}-\${parenthesis}" if $${parenthesis} eq "PA" ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>');
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      "afun:\t\${afun}\ntag:\t\${tag}".
		      '<?"\ncommentA:\t\${commentA}" if $${commentA} ne "" ?>'.
		      '<?"\nframe:\t\${framere}" if $${framere} ne "" ?>'.
		      '<?"\nframe_id:\t\${frameid}" if $${frameid} ne "" ?>');
  upgrade_file();
  return 1;
}

sub sort_attrs_hook {
  my ($ar)=@_;
  @$ar = (grep($grp->{FSFile}->FS->exists($_),
	       'func','trlemma','form','afun','coref','memberof','operand','parenthesis','aspect','commentA'),
	  sort {uc($a) cmp uc($b)}
	  grep(!/^(?:trlemma|func|form|afun|commentA|coref|memberof|operand|aspect|parenthesis)$/,@$ar));
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

sub QueryKdy {
  my $node=shift;
  my @trs=
    (
     ['kdy', 'kdy', 'TWHEN'],
     ['odkdy', 'kdy', 'TSIN'],
     ['dokdy', 'kdy', 'TTIL'],
     ['jak dlouho', 'kdy', 'THL'],
     ['na jak dlouho', 'kdy','TFHL'],
     ['jak èasto', 'kdy', 'THO'],
     ['bìhem', 'kdy', 'TPAR'],
     ['ze kdy', 'kdy', 'TFRWH'],
     ['na kdy', 'kdy', 'TOWH']
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
     ['EmpNoun','&EmpNoun;','???','???'],
     ['Gen','&Gen;','???','???'],
     ['Idph','&Idph;','???','???'],
     ['stejnì','stejnì','???','MANN'],
     ['stejný','stejný','???','RSTR'],
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
    } elsif ($node->{trlemma} eq 'kdy') {
      QueryKdy($node);
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
  if ($atr!~/^(?:func|coref|commentA|reltype|memberof|operand|aspect|tfa|err1|parenthesis)$/) {
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

#bind rotate_func to Ctrl+space menu Rotate Functor Values
sub rotate_func {
  $this->{func}=rotate_attrib($this->{func});
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

sub memberof_pa_to_parenthesis {
  if ($this->{memberof} eq 'PA') {
    $this->{memberof}='???';
    $this->{parenthesis}='PA';
  }
}


## add few custom bindings to predefined subroutines
#include <contrib/tredtr.mak>

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
#bind AddNewLoc to Ctrl+L menu Doplnit mistní doplnìní pod akt. vrchol
sub AddNewLoc {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  $this->{trlemma}='tady';
  unless (QuerySemtam($this)) {
   DeleteCurrentNode();
  }
}

# this is new (not overriden)
#bind AddNewTime to Ctrl+T menu Doplnit urèení èasu pod akt. vrchol
sub AddNewTime {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  $this->{trlemma}='kdy';
  unless (QueryKdy($this)) {
   DeleteCurrentNode();
  }
}


## (overriding definitions of contrib/tredtr.mak)
sub GetNewOrd {

  my $base=0;
  my $suff=0;
  my $node=$_[0] || $pPar2;

  if ($node) {
    $base=$1 if $node->{ord}=~/^([0-9]+)/;
    $node=$node->root;
  } else {
    $node=$root;
  }
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

sub func_PAR {
  subtree_add_pa($this);
  $sPar1 = 'PAR';
  FuncAssign();
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

#bind add_questionmarks_func to Ctrl+X menu Pridat k funktoru ???
sub add_questionmarks_func {
  $pPar1 = $this;
  $sPar1 = Union($pPar1->{'func'},'???');
  FuncAssign();
}

#######################################################
# Node shifting

#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftLeft to Q menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind ShiftRight to U menu posun uzel doprava

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

#bind add_EN to Ctrl+V menu Doplnit prazdne substantivum EmpNoun pod akt. vrchol
sub add_EN {
  NewVerb();
  $this->{'trlemma'} = '&EmpNoun;';
  $this->{'func'}='???';
}

sub GetNewTID { # fill GraphTR fake
  $sPar3 = generate_new_tid();
}

sub NewVerb {
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pTatka;			# used as type "pointer"
  my $pNew;			# used as type "pointer"

  my $sNum;			# used as type "string"

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
    TredMacro::NewLBrother();
    $pNew=$this;
    $pNew->{sentord}=$son->{sentord}-1;

    $son=$pT->firstson();
    while ($son) {
      $rb=$son->rbrother();
      PasteNode(CutNode($son),$pNew) if ($son->{afun}=~/ExD/ and $son ne $pNew);
      $son=$rb;
    }
  } else {
    TredMacro::NewSon();
    $pNew=$this;
    $pNew->{sentord}=$pT->{sentord};
  }

  $sNum = GetNewOrd($pT);
  $pNew->{TID} = generate_new_tid();
  $pNew->{'TR'}='';
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
  $pNew->{'operand'} = '???';
  $pNew->{'gender'} = '???';
  $pNew->{'number'} = '???';
  $pNew->{'degcmp'} = '???';
  $pNew->{'tense'} = '???';
  $pNew->{'aspect'} = '???';
  $pNew->{'iterativeness'} = '???';
  $pNew->{'verbmod'} = '???';
  $pNew->{'deontmod'} = '???';
  $pNew->{'sentmod'} = '???';
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

sub getAIDREF {
  my $node = $_[0] || $this;
  return ($node->{AIDREFS} ne "") ? $node->{AIDREFS} : $node->{AID};
}

sub ConnectAIDREFS {
  $pPar1->{AIDREFS}=getAIDREF($pPar1).'|'.getAIDREF($pPar2);
}

sub DisconnectAIDREFS {
  my $aid=getAIDREF($pPar2);
  $pPar1->{AIDREFS} =~ s/(?:^|\|)$aid(?:\||$)//g;
}

sub ConnectFW {
  $pPar1->{fw}= join '|',grep { $_ ne "" }
    $pPar1->{fw},$pPar2->{trlemma},$pPar2->{fw};
}

sub DisconnectFW {
  $pPar1->{fw} =~ s/(?:^|\|)$pPar2->{trlemma}(?:\||$)//g;
}


sub FCopy {
  if ($pThis->{'del'} ne 'ELID') {
    $NodeClipboard=CopyNode($this);
    $sPasteNow = 'yes';
  }
}

sub FPaste {
  my $sDord;			# used as type "string"
  my $pThis;

  $pThis=$this;
  if ($NodeClipboard and $sPasteNow eq 'yes') {
    $sDord = $pThis->{'dord'};
    $pPasted=PasteNode($NodeClipboard,$pThis);
    $pPasted->{'dord'} = "-1";
    $pPasted->{'del'} = 'ELID';
    $pPasted->{'origf'} = '???';
    $pPasted->{'sentord'}=999;
    $pPasted->{'ord'}=GetNewOrd($pThis);
    $sPar1 = $sDord;
    $sPar2 = "1";
    ShiftDords();
    $pPasted->{'dord'} = $sDord;
    $pPasted->{'TID'} = generate_new_tid();
    if ($pPasted->{'AIDREFS'} eq '') {
      $pPasted->{'AIDREFS'} = $pPasted->{'AID'};
    }
    $pPasted->{'AID'} = '';
    $this=PasteNode(CutNode($pPasted),$pThis); # repaste to get structure order right
  }
  $sPasteNow = '';
}

#bind operand_op to Ctrl+Y menu Pridat operand=OP
sub operand_op {

  $pPar1 = $this;
  $pPar1->{'operand'} = 'OP';

}

#bind subtree_add_pa to z menu Pridat _PA k podstromu
sub subtree_add_pa {
  shift unless ref($_[0]);
  my $node = $_[0] || $this;
  foreach ($node, $node->descendants(FS())) {
    $_->{'parenthesis'} = 'PA';
  }
}

#bind subtree_remove_pa to Z menu Odebrat _PA od podstromu
sub subtree_remove_pa {
  shift unless ref($_[0]);
  my $node = $_[0] || $this;
  foreach ($node, $node->descendants(FS())) {
    $_->{'parenthesis'} = 'NIL';
  }
}

sub generate_new_tid {
  my $tree = $_[0] || $root;
  my $id = $tree->{ID1};
  my $t = 0;
  my $node=$tree;
  $id=~s/:/-/g;
  while ($node) {
    if ($node->{TID}=~/a(\d+)$/ and $t<=$1) {
      $t=$1+1;
    }
    $node = $node->following();
  }
  return "${id}a${t}";
}

#insert generate_tids_whole_file as menu Doplnit TID v celem souboru
sub generate_tids_whole_file {
  my $defs=FS()->defs;
  unless (exists($defs->{TID})) {
    AppendFSHeader('@P TID');
  }
  foreach my $tree (GetTrees()) {
    my $node=$tree->following;
    while ($node) {
      if ($node->{ord}=~/\./ and $node->{TID} eq "") {
	$node->{TID}=generate_new_tid($tree);
      }
      $node=$node->following;
    }
  }
}

sub check_and_repair_ids {
  my ($verbose)=@_;
  repair_added_nodes($verbose);
  upgrade_file();
  move_aid_to_aidrefs($verbose);
  rigorously_check_ids();
}

sub repair_added_nodes {
  my ($verbose)=@_;
  my $treeno=0;
  foreach my $tree (GetTrees()) {
    $treeno++;
    $node=$tree;
    while ($node) {
      if ($node->{del} =~ /^E/) {
	if ($node->{ord} !~ /\./) {
	  my $neword=GetNewOrd($node);
	  print FileName()."##$treeno.".GetNodeIndex($node)." fixing ord $node->{ord} --> $neword for del $node->{del}\n" if $verbose;
	  $node->{ord}=$neword;
	}
	if ($node->{sentord} != 999) {
	  print FileName()."##$treeno.".GetNodeIndex($node)." fixing sentord $node->{sentord} for del $node->{del}\n" if $verbose;
	  $node->{sentord}=999;
	}
      }
      $node=$node->following;
    }
    my %ords;
    $node=$tree;
    while ($node) {
      if ($node->{ord} =~ /\./) {
	if (exists($ords{$node->{ord}})) {
	  my $neword=GetNewOrd($node);
	  print FileName()."##$treeno.".GetNodeIndex($node).
	    " fixing duplicated ord $node->{ord} --> $neword\n" if $verbose;
	  $node->{ord}=$neword;
	}
	$ords{$node->{ord}}=1;
      }
      $node=$node->following;
    }
  }
}

sub rigorously_check_ids {
  my %aids;
  my %tids;
  my $treeno=0;
  foreach my $tree (GetTrees()) {
    $treeno++;
    my $node=$tree;
    my @sentords=();
    my @dords=();
    my %ords;
    while ($node) {
      if ($node->{ord} < 0) {
	print FileName()."##$treeno.".GetNodeIndex($node)." negative ord $node->{ord}\n";
      }
      if ($node->{dord} < 0) {
	print FileName()."##$treeno.".GetNodeIndex($node)." negative dord $node->{dord}\n";
      }
      if ($node->{sentord} < 0) {
	print FileName()."##$treeno.".GetNodeIndex($node)." negative sentord $node->{sentord}\n";
      }
      if ($node->{AID} ne "" and exists($aids{$node->{AID}})) {
	print FileName()."##$treeno.".GetNodeIndex($node)." duplicate AID $node->{AID}\n";
      }
      if ($node->{TID} ne "" and exists($tids{$node->{TID}})) {
	print FileName()."##$treeno.".GetNodeIndex($node)." duplicate TID $node->{TID}\n";
      }
      if ($node->{ord} ne "" and exists($ords{$node->{ord}})) {
	print FileName()."##$treeno.".GetNodeIndex($node)." duplicate ord $node->{ord}\n";
      }
      if ($node->{ord} !~ /\./ and $node->{sentord} ne $node->{ord}) {
	print FileName()."##$treeno.".GetNodeIndex($node)." sentord $node->{sentord} =! ord $node->{ord}\n";
      }
      if ($node->{ord} =~ /\./ and $node->{sentord} != 999) {
	print FileName()."##$treeno.".GetNodeIndex($node)." inconsistent sentord $node->{sentord} for ord $node->{ord}\n";
      }
      if ($node->{ord} =~ /\./ and $node->{TID} eq "") {
	print FileName()."##$treeno.".GetNodeIndex($node)." missing TID for ord $node->{ord}\n";
      }
      if ($node->{ord} !~ /\./ and $node->{ord} != 0 and $node->{AID} eq "") {
	print FileName()."##$treeno.".GetNodeIndex($node)." missing AID for ord $node->{ord}\n";
      }
      if ($node->{ord} =~ /\./ and $node->{AID} ne "") {
	print FileName()."##$treeno.".GetNodeIndex($node)." redundant AID for ord $node->{ord}\n";
      }
      if ($node->{ord} !~ /\./ and $node->{TID} ne "") {
	print FileName()."##$treeno.".GetNodeIndex($node)." redundant TID for ord $node->{ord}\n";
      }
      if ($sentords[$node->{sentord}] == 1) {
	print FileName()."##$treeno.".GetNodeIndex($node)." duplicate sentord $node->{sentord}\n";
      }
      if ($dords[$node->{dord}] == 1) {
	print FileName()."##$treeno.".GetNodeIndex($node)." duplicate dord $node->{dord}\n";
      }
      if ($node->{AID}=~/\|/) {
	print FileName()."##$treeno.".GetNodeIndex($node)." forbidden character | in AID $node->{AID}\n";
      }
      if ($node->{AIDREFS} ne "" and $node->{AID} ne "" and index("|$node->{AIDREFS}|","|$node->{AID}|")<0) {
	print FileName()."##$treeno.".GetNodeIndex($node)." AID $node->{AID} missing in AIDREFS $node->{AIDREFS}\n";
      }
      $sentords[$node->{sentord}]=1 unless ($node->{sentord}<0 or $node->{sentord}>=999);
      $dords[$node->{dord}]=1 unless ($node->{dord}<0);
      $ords{$node->{ord}}=1 if $node->{ord} ne "";
      $aids{$node->{AID}}=1 if $node->{AID} ne "";
      $tids{$node->{TID}}=1 if $node->{TID} ne "";
      $node=$node->following();
    }
    for (my $i=0; $i<=$#sentords; $i++) {
      unless ($sentords[$i]) {
	print FileName()."##$treeno missing sentord $i/$#sentords\n";
      }
    }
    for (my $i=0; $i<=$#dords; $i++) {
      unless ($dords[$i]) {
	print FileName()."##$treeno missing dord $i/$#dords\n";
      }
    }
  }
}

#insert move_aid_to_aidrefs as menu Oprava: presune nasobne AID do AIDREFS
sub move_aid_to_aidrefs {
  my ($verbose)=@_;
  my $defs=FS()->defs;
  unless (exists($defs->{AIDREFS})) {
    AppendFSHeader('@P AIDREFS');
  }
  my %aids;
  my $treeno=0;
  foreach my $tree (GetTrees()) {
    $treeno++;
    my $node=$tree->following;
    while ($node) {
      # reverse!!!
#      $node->{AID}=$node->{AIDREFS} if ($node->{AIDREFS} ne "");
#      unless ($node->{ord}=~/\./ or $node->{sentord}==999) {
#	$node->{TID}=''
#      }
      if ($node->{AID}=~/\|/) {
	if ($node->{ord}=~/\./ or $node->{sentord}==999) {
	  $node->{AIDREFS}=join '|',split /\|/,$node->{AID};
	  $node->{AID}='';
	} else {
	  $node->{AIDREFS}=join '|',split /\|/,$node->{AID};
	  ($node->{AID})=grep { /w$node->{ord}$/ } split /\|/,$node->{AIDREFS};
	  if ($node->{AID} eq '') {
	    my ($aid)=split /\|/,$node->{AIDREFS};
	    my $aid_risk=$aid;
	    $aid_risk=~s/w\d+$/w$node->{ord}/;
	    if (exists($aids{$aid})) {
	      print FileName()."##$treeno.".GetNodeIndex($node).
		" no ID from $node->{AIDREFS} matches w$node->{ord}. Using the first one!\n";
	      $node->{AID}=$aid
	    } else {
	      print FileName()."##$treeno.".GetNodeIndex($node).
		" no ID from $node->{AIDREFS} matches w$node->{ord}. Risking free $aid_risk!\n";
	      $node->{AID}=$aid_risk;
	      $node->{AIDREFS}=$aid_risk.'|'.$node->{AIDREFS};
	    }
	  }
	}
      }
      if ($node->{TID} ne "" or $node->{ord}=~/\./ or $node->{sentord}==999) {
	if ($node->{AID} ne "") {
	  print FileName()."##$treeno.".GetNodeIndex($node).
	    " Removing AID $node->{AID} from $node->{TID} $node->{ord}\n"
	      if $verbose;
	  $node->{AID}='';
	}
	if ($node->{TID} eq "") {
	  $node->{TID}=generate_new_tid($tree);
	  print FileName()."##$treeno.".GetNodeIndex($node).
	    " node with ord $node->{ord} has no TID yet: assigning $node->{TID}\n";
	}
	if ($node->{sentord}==999 and $node->{ord}!~/\./) {
	  do {
	    my $oldord=$node->{ord};
	    $node->{ord}=GetNewOrd($node);
	    print FileName()."##$treeno.".GetNodeIndex($node).
	      " changing ord for node with sentord 999 from $oldord to $node->{ord}";
	  };
	}
      }
      if ($node->{AID} ne "" and exists($aids{$node->{AID}})) {
	$node->{TID}=generate_new_tid($tree);
	print FileName()."##$treeno.".GetNodeIndex($node).
	  " replacing duplicate AID $node->{AID} ($node->{ord},$node->{sentord}) with $node->{TID}\n";
	$node->{AID}='';
      }
      $aids{$node->{AID}}=1 if $node->{AID} ne "";
      $node=$node->following;
    }
  }
}

#bind upgrade_file_to_tid_aidrefs to F7 menu Aktualizace souboru na system AID/AIDREFS, TID
sub upgrade_file_to_tid_aidrefs {
  my $defs=FS()->defs;
  return if (exists($defs->{TID}) && exists($defs->{AIDREFS}));
#  print "TID and AIDREF don't exist!\n";
  if (!GUI() || questionQuery(TrEd::Convert::encode('Automatická oprava'),
			      TrEd::Convert::encode("Tento soubor neobsahuje deklarace atributu AIDREFS nebo TID,\n".
						    "do nich¾ se ukládají dùle¾ité identifikátory uzlù.\n\n".
						    "Pøejete si tyto atributy pøidat a aktualizovat soubor (doporuèeno)?\n\n"),
						    qw{Ano Ne}) eq 'Ano') {
    generate_tids_whole_file();
    move_aid_to_aidrefs();
  }
}

#bind reorder_dords Alt+r
sub reorder_dords {
  my $nodesref=[ GetNodes() ];
  SortByOrd($nodesref);
  $nodesref = [$root, grep {$_ != $root} @$nodesref];
  my $ord=$grp->{FSFile}->FS->order;
  for (my $i=0;$i<=$#$nodesref; $i++) {
    if ($nodesref->[$i]->{$ord}!=$i) {
      print FileName()."##".(CurrentTreeNumber()+1).".".GetNodeIndex($nodesref->[$i])." ",
	$nodesref->[$i]->{$ord}," --> $i\n";
      $nodesref->[$i]->{$ord}=$i;
      $FileChanged=1;
    }
  }
  for (my $i=0;$i<=$#$nodesref;$i++) {
    RepasteNode($nodesref->[$i]);
  }
}

#bind tr_diff_all_windows key equal menu Porovnej zobrazene stromy pomoci TR_Diff
sub tr_diff_all_windows {
  foreach my $win (@{$grp->{framegroup}->{treeWindows}}) {
    SwitchContextForWindow($win,'TR_Diff');
  }
  TR_Diff->DiffTRFiles(0);
}
