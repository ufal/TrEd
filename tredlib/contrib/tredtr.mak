# Automatically converted from Graph macros by graph2tred to Perl.         -*-cperl-*-.
## author: Alena Bohmova
## ----------------------------------------

my $iPrevAfunAssigned;		# used as type "string"
my $pPar1;			# used as type "pointer"
my $pPar2;			# used as type "pointer"
my $pPar3;			# used as type "pointer"
my $pReturn;			# used as type "pointer"
my $pDummy;			# used as type "pointer"
my $sPar1;			# used as type "string"
my $sPar2;			# used as type "string"
my $sPar3;			# used as type "string"
my $sReturn;			# used as type "string"
my $iPar1;			# used as type "string"
my $iPar2;			# used as type "string"
my $iPar3;			# used as type "string"
my $iReturn;			# used as type "string"
my $lPar1;			# used as type "list"
my $lPar2;			# used as type "list"
my $lPar3;			# used as type "list"
my $lReturn;			# used as type "list"
my $_pDummy;			# used as type "pointer"


sub ThisRoot {
  my $pT;			# used as type "pointer"
  my $pPrev;			# used as type "pointer"

  $pPrev = undef;

  $pT = $this;
 Cont1:
  if ($pT) {

    $pPrev = $pT;

    $pT = Parent($pT);

    goto Cont1;
  }

  $pReturn = $pPrev;

}


sub GoNext {
  my $pAct;			# used as type "pointer"

  $pAct = $pPar1;

  if (FirstSon($pAct)) {

    $pReturn = FirstSon($pAct);

    return;
  }
 loopGoNext:
  if ($pAct eq $pPar2 ||
      !(Parent($pAct))) {

    $pReturn = undef;

    return;
  }

  if (RBrother($pAct)) {

    $pReturn = RBrother($pAct);

    return;
  }

  $pAct = Parent($pAct);

  goto loopGoNext;

}


sub GoNextVisible {
  my $pAct;			# used as type "pointer"
  my $n;			# used as type "pointer"

  $pAct = $pPar1;

  if (FirstSon($pAct)) {

    $n = FirstSon($pAct);
  whileHidden:
    if ($n) {

      if (Interjection($n->{'TR'},'hide') ne 'hide') {

	$pReturn = $n;

	return;
      }

      $n = RBrother($n);

      goto whileHidden;
    }
  }
 lpGoNext:
  if ($pAct eq $pPar2 ||
      !(Parent($pAct))) {

    $pReturn = undef;

    return;
  }

  $n = RBrother($pAct);
 whileHiddenRBrother:
  if ($n) {

    if (Interjection($n->{'TR'},'hide') ne 'hide') {

      $pReturn = $n;

      return;
    }

    $n = RBrother($n);

    goto whileHiddenRBrother;
  }

  $pAct = Parent($pAct);

  goto lpGoNext;

}


sub GoPrev {
  my $pAct;			# used as type "pointer"

  $pAct = $pPar1;

  if (LBrother($pAct)) {

    $pAct = LBrother($pAct);

    if (FirstSon($pAct)) {
    loopDigDown:
      $pAct = FirstSon($pAct);
    loopLastBrother:
      if (RBrother($pAct)) {

	$pAct = RBrother($pAct);

	goto loopLastBrother;
      }

      if (FirstSon($pAct)) {

	goto loopDigDown;
      }

      $pReturn = $pAct;

      return;
    }

    $pReturn = $pAct;

    return;
  }

  if ($pAct eq $pPar2 ||
      !(Parent($pAct))) {

    $pReturn = undef;

    return;
  }

  $pReturn = Parent($pAct);

  return;

}


#bind _key_Shift_Tab to Shift+Tab menu previous word (linear order)
sub _key_Shift_Tab {

  $pPar1 = $this;

  $pPar2 = undef;

  GoPrev();

  $this = $pReturn;

}


#bind _key_Tab to Tab menu next word (linear order)
sub _key_Tab {

  $pPar1 = $this;

  $pPar2 = undef;

  GoNext();

  $this = $pReturn;

}


sub ToLine {
  my $pKing;			# used as type "pointer"
  my $pPrince;			# used as type "pointer"
  my $pInLaw;			# used as type "pointer"

  if (Parent($pPar1)) {

    $pKing = Parent($pPar1);

    $pPrince = $pPar1;
  } else {

    $pKing = $pPar1;

    $pPrince = FirstSon($pKing);

    goto whileHasBrothers;
  }

 start:
  $pReturn = $pPrince;

  $pInLaw = $pPrince;
 minOrd:
  $pPar1 = $pReturn;

  $pPar2 = $pPrince;

  GoNext();

  if (!($pReturn)) {

    goto changeOrder;
  }

  if (ValNo(0,$pReturn->{'ord'})<ValNo(0,$pInLaw->{'ord'})) {

    $pInLaw = $pReturn;
  }

  goto minOrd;
 changeOrder:
  if ($pInLaw ne $pPrince) {

    $pInLaw->{'warning'} = 'InLaw';

    $NodeClipboard=CutNode($pInLaw);

    $pDummy = PasteNode($NodeClipboard,$pKing);

    $pInLaw = FirstSon($pKing);
  whileNotInLaw:
    if (Interjection($pInLaw->{'warning'},'InLaw') ne 'InLaw') {

      $pInLaw = RBrother($pInLaw);

      goto whileNotInLaw;
    }

    $pInLaw->{'warning'} = '';

    $NodeClipboard=CutNode($pPrince);

    $pDummy = PasteNode($NodeClipboard,$pInLaw);

    $pPrince = $pInLaw;
  }

  $pKing = $pPrince;

  if (!(FirstSon($pKing))) {

    return;
  }

  $pPrince = FirstSon($pKing);
 whileHasBrothers:
  if (RBrother($pPrince)) {

    $NodeClipboard=CutNode(RBrother($pPrince));

    $pDummy = PasteNode($NodeClipboard,$pPrince);

    goto whileHasBrothers;
  }

  goto start;

}


sub Auxk {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sT;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pParent = $pRoot;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  if (!(FirstSon($pAct))) {

    goto AuxkStart;
  }

  $pParent = $pAct;

  $pAct = FirstSon($pAct);

  goto ContLoop1;
 AuxkStart:
  if (Interjection($pAct->{'form'},'.') eq '.' ||
      Interjection($pAct->{'form'},';') eq ';' ||
      Interjection($pAct->{'form'},':') eq ':' ||
      Interjection($pAct->{'form'},',') eq ',' ||
      Interjection($pAct->{'form'},'!') eq '!' ||
      Interjection($pAct->{'form'},'?') eq '?' ||
      Interjection($pAct->{'form'},')') eq ')' ||
      Interjection($pAct->{'form'},']') eq ']' ||
      Interjection($pAct->{'form'},'}') eq '}' ||
      Interjection($pAct->{'form'},'-') eq '-' ||
      Interjection($pAct->{'form'},';') eq ';') {

    $NodeClipboard=CutNode($pAct);

    $pDummy = PasteNode($NodeClipboard,$pRoot);

    $pAct = $pParent;

    $pParent = Parent($pParent);

    if (!($pAct)) {

      return;
    }

    goto AuxkStart;
  }

  return;

}


sub LeftMost {
  my $pAct;			# used as type "pointer"
  my $iMin;			# used as type "string"

  $pAct = $pPar1;

  $iMin = "29999";
 ContLoop1:
  if (!($pAct)) {

    goto ExitLoop1;
  }

  if ($iMin>ValNo(0,$pAct->{'ord'})) {

    $iMin = ValNo(0,$pAct->{'ord'});
  }

  $pAct = FirstSon($pAct);

  goto ContLoop1;
 ExitLoop1:
  $iReturn = $iMin;

}


sub ToChainNode {
  my $pRoot;			# used as type "pointer"
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pEndChain;		# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pPasted;			# used as type "pointer"
  my $pFinalActive;		# used as type "pointer"
  my $sT;			# used as type "string"
  my $iAct;			# used as type "string"
  my $iOrdParent;		# used as type "string"
  my $iOrdRoot;			# used as type "string"
  my $iEnd;			# used as type "string"
  my $fJustPasted;		# used as type "string"

  $pFinalActive = undef;

  $pRoot = $this;

  $iOrdRoot = ValNo(0,$pRoot->{'ord'});

  $pPar1 = $this;

  LeftMost();

  $iAct = $iReturn;

  if ($iAct==$iOrdRoot) {

    $pFinalActive = $pRoot;
  }

  $pRoot->{'err2'} = 'reinited';

  $pParent = Parent($pRoot);

  if (!($pParent)) {

    $iOrdParent = "-1";

    $pEndChain = $pRoot;

    $pAct = FirstSon($pRoot);

    $iAct = "1";
  } else {

    $iOrdParent = ValNo(0,$pParent->{'ord'});

    $pEndChain = $pParent;

    $pAct = $pRoot;
  }


  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $fJustPasted = 'n';

  if (ValNo(0,$pAct->{'ord'})==$iAct) {

    if ($pFinalActive eq $pAct) {

      $pFinalActive = undef;
    }

    $NodeClipboard=CutNode($pAct);

    $pPasted = PasteNode($NodeClipboard,$pEndChain);

    if (!($pFinalActive)) {

      $pFinalActive = $pPasted;
    }

    $pEndChain = $pPasted;

    $pAct = $pEndChain;

    $iAct = $iAct+"1";

    $fJustPasted = 'y';
  }
 ContLoop3:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    if (ValNo(0,$pAct->{'ord'})==$iOrdRoot) {

      goto ExitLoop1;
    }

    $pNext = RBrother($pAct);
  } else {

    if ($fJustPasted eq 'y') {

      if (ValNo(0,$pNext->{'ord'})==$iAct) {

	$pAct = $pNext;

	$pEndChain = $pAct;

	$iAct = $iAct+"1";

	goto ContLoop3;
      }
    }
  }

 ContLoop2:
  if ($pNext) {

    goto ExitLoop2;
  }

  $pAct = Parent($pAct);

  if (!($pAct)) {

    goto ExitLoop1;
  }

  if (ValNo(0,$pAct->{'ord'})==$iOrdRoot) {

    goto ExitLoop1;
  }

  $pNext = RBrother($pAct);

  goto ContLoop2;
 ExitLoop2:
  $pAct = $pNext;

  goto ContLoop1;
 ExitLoop1:
  if ($iOrdParent=="-1") {

    Auxk();
  }

  $this = $pFinalActive;

  return;

}


sub ToChain {
  my $pRoot;			# used as type "pointer"
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pEndChain;		# used as type "pointer"
  my $sT;			# used as type "string"
  my $iAct;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $this = $pRoot;

  $pRoot->{'err2'} = 'reinited';

  $iAct = "1";

  $pEndChain = $pRoot;

  $pParent = $pRoot;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  if (ValNo(0,$pAct->{'ord'})==$iAct) {

    $NodeClipboard=CutNode($pAct);

    $pDummy = PasteNode($NodeClipboard,$pEndChain);

    $pEndChain = FirstSon($pEndChain);

    $iAct = $iAct+"1";

    $pAct = $pEndChain;
  }

  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 ContLoop2:
  if ($pNext) {

    goto ExitLoop2;
  }

  $pAct = Parent($pAct);

  if (ValNo(0,$pAct->{'ord'})==ValNo(0,$pParent->{'ord'})) {

    goto ExitLoop1;
  }

  $pNext = RBrother($pAct);

  goto ContLoop2;
 ExitLoop2:
  $pAct = $pNext;

  goto ContLoop1;
 ExitLoop1:
  if (RBrother($pAct)) {

    $pAct = RBrother($pAct);

    goto ContLoop1;
  }

  Auxk();

  return;

}


sub NP {
  my $pRoot;			# used as type "pointer"
  my $pAct;			# used as type "pointer"
  my $pActL3;			# used as type "pointer"
  my $pActL2;			# used as type "pointer"
  my $pActL1;			# used as type "pointer"
  my $pActR1;			# used as type "pointer"
  my $pActR2;			# used as type "pointer"
  my $pActR3;			# used as type "pointer"
  my $sPOSAct;			# used as type "string"
  my $sCASEAct;			# used as type "string"
  my $i;			# used as type "string"

  return;

  ThisRoot();

  $pRoot = $pReturn;

  $this = $pRoot;

  ToChain();

  $pAct = $pRoot;

  if (!($pAct)) {

    return;
  }

  $pAct = FirstSon($pAct);

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $sPOSAct = substr(ValNo(0,$pAct->{'tag'}),0,1);

  if ($sPOSAct eq 'N') {
  } else {

    if ($sPOSAct eq 'A') {

      $pActR1 = FirstSon($pAct);

      if (!($pActR1)) {

	goto GoDown;
      }

      $sPOSAct = substr(ValNo(0,$pActR1->{'tag'}),0,1);

      if ($sPOSAct eq 'N') {

	$pActR2 = FirstSon($pActR1);

	if ($pActR2) {

	  $pActR3 = FirstSon($pActR2);

	  $NodeClipboard=CutNode($pActR2);

	  $pDummy = PasteNode($NodeClipboard,Parent($pAct));

	  if ($pActR3) {

	    $pActR2 = Parent($pActR3);
	  } else {

	    $pActR2 = undef;

	    $pAct = undef;
	  }

	}

	$NodeClipboard=CutNode($pActR1);

	$pDummy = PasteNode($NodeClipboard,Parent($pAct));

	$NodeClipboard=CutNode($pAct);

	$pDummy = PasteNode($NodeClipboard,$pActR1);

	$pAct = $pActR2;

	goto GoNext;
      }
    } else {

      if ($sPOSAct eq 'R') {
      }
    }

  }

 GoDown:
  $pAct = FirstSon($pAct);
 GoNext:
  if (!($pAct)) {

    goto ExitLoop1;
  }
 Rightmost:
  if (RBrother($pAct)) {

    $pAct = RBrother($pAct);

    goto Rightmost;
  }

  goto ContLoop1;
 ExitLoop1:
  return;

}


#bind _key_Backspace to Backspace menu Jump to previous node (do *not* change afun)
sub _key_Backspace {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"
  my $pRoot;			# used as type "pointer"

  if ($iPrevAfunAssigned ne '') {

    ThisRoot();

    $pRoot = $pReturn;

    $pParent = $pRoot;

    $pAct = $pParent;

    if (!($pAct)) {

      return;
    }
  ContLoop1:
    if (ValNo(0,$pAct->{'ord'})==$iPrevAfunAssigned) {

      goto ExitLoop1;
    }

    $pNext = FirstSon($pAct);

    if (!($pNext)) {

      $pNext = RBrother($pAct);
    }
  ContLoop2:
    if ($pNext) {

      goto ExitLoop2;
    }

    $pAct = Parent($pAct);

    if (ValNo(0,$pAct->{'ord'})==ValNo(0,$pParent->{'ord'})) {

      goto ExitLoop1;
    }

    $pNext = RBrother($pAct);

    goto ContLoop2;
  ExitLoop2:
    $pAct = $pNext;

    goto ContLoop1;
  ExitLoop1:
    $this = $pAct;
  }

}


sub DepSuffix {
  my $pThis;			# used as type "pointer"
  my $pDep;			# used as type "pointer"
  my $sDepAfun;			# used as type "string"
  my $sDepSuff;			# used as type "string"
  my $sAfun;			# used as type "string"

  $sAfun = $sPar1;

  $pThis = $this;

  $pDep = FirstSon($this);

  AfunAssign();
 DSLoopCont1:
  if (!($pDep)) {

    goto DSLoopEnd1;
  }

  $sPar1 = ValNo(0,$pDep->{'afun'});

  GetAfunSuffix();

  $sDepAfun = $sPar2;

  $sDepSuff = $sPar3;

  if ($sDepSuff ne '' &&
      $sDepSuff ne '_Pa') {

    $sDepSuff = (ValNo(0,'_').ValNo(0,substr($sAfun,0,2)));

    $pDep->{'afun'} = (ValNo(0,$sDepAfun).ValNo(0,$sDepSuff));
  }

  $pDep = RBrother($pDep);

  goto DSLoopCont1;
 DSLoopEnd1:
  $this = $pThis;

  return;

}


sub AfunAssign {
  my $t, $n;			# used as type "pointer"

  $t = $this;

  if (Interjection($t->{'afun'},'AuxS') ne 'AuxS') {

    if (Interjection($t->{'afun'},'???') ne '???') {

      $t->{'afunprev'} = $t->{'afun'};
    }

    $t->{'afun'} = $sPar1;

    $iPrevAfunAssigned = ValNo(0,$t->{'ord'});

    if (FirstSon($t)) {

      $n = FirstSon($t);
    } else {

      $n = $t;
    SearchForBrotherCont:
      if (Interjection($n->{'afun'},'AuxS') ne 'AuxS') {

	if (RBrother($n)) {

	  $n = RBrother($n);

	  goto FoundBrother;
	}

	$n = Parent($n);

	goto SearchForBrotherCont;
      }

      $n = $t;
    FoundBrother:
      $n = $n;
    }


    $this = $n;
  }

}


sub TFAAssign {
  my $t;			# used as type "pointer"

  $t = $this;

  if (Interjection($t->{'afun'},'AuxS') ne 'AuxS') {

    $t->{'tfa'} = $sPar1;

    $pPar1 = $t;

    $pPar2 = undef;

    GoNextVisible();

    $this = $pReturn;
  }

}


sub FuncAssign {
  my $t, $n;			# used as type "pointer"

  $t = $this;

  if (Interjection($t->{'afun'},'AuxS') ne 'AuxS') {

    $t->{'func'} = $sPar1;

    if (FirstSon($t)) {

      $n = FirstSon($t);
    } else {

      $n = $t;
    SearchForBrotherCont:
      if (Interjection($n->{'afun'},'AuxS') ne 'AuxS') {

	if (RBrother($n)) {

	  $n = RBrother($n);

	  goto FoundBrother;
	}

	$n = Parent($n);

	goto SearchForBrotherCont;
      }

      $n = $t;
    FoundBrother:
      if (Interjection($n->{'TR'},'hide') eq 'hide') {

	$n = Parent($n);
      }

      $n = $n;
    }


    $this = $n;
  }

}


sub AllUndefAssign {
  my $pRoot;			# used as type "pointer"
  my $iStart;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $iStart = substr(ValNo(0,$pRoot->{'form'}),1,10);
 AUALoopCont1:
  $pPar1 = $pRoot;

  SubtreeUndefAfun();

  NextTree();

  if ($_NoSuchTree=="1") {

    goto AUALoopExit1;
  }

  $pRoot = $this;

  goto AUALoopCont1;
 AUALoopExit1:
  GotoTree($iStart);

  return;

}


sub FileUndefAssign {
  my $sSaveCatchError;		# used as type "string"

  $sSaveCatchError = $_CatchError;

  $_CatchError = "1";

  GotoTree(1);

  AllUndefAssign();

  $_CatchError = $sSaveCatchError;

}


sub AllAfunAssign {
  my $pRoot;			# used as type "pointer"
  my $iStart;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $iStart = substr(ValNo(0,$pRoot->{'form'}),1,10);
 AAALoopCont1:
  $pPar1 = $pRoot;

  SubtreeAfunAssign();

  NextTree();

  if ($_NoSuchTree=="1") {

    goto AAALoopExit1;
  }

  $pRoot = $this;

  goto AAALoopCont1;
 AAALoopExit1:
  GotoTree($iStart);

  return;

}


sub FileAfunAssign {
  my $sSaveCatchError;		# used as type "string"

  $sSaveCatchError = $_CatchError;

  $_CatchError = "1";

  GotoTree(1);

  AllUndefAssign();

  GotoTree(1);

  if ($_NoSuchTree=="1") {

    return;
  }

  AllAfunAssign();

  $_CatchError = $sSaveCatchError;

}


#bind _key_Ctrl_Shift_F9 to Ctrl+Shift+F9
sub _key_Ctrl_Shift_F9 {

  AllFuncAssign();

}


sub AllFuncAssign {
  my $pRoot;			# used as type "pointer"
  my $iStart;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $iStart = substr(ValNo(0,$pRoot->{'form'}),1,10);
 AAALoopCont1:
  $pPar1 = $pRoot;

  TreeToTR();

  NextTree();

  if ($_NoSuchTree=="1") {

    goto AAALoopExit1;
  }

  $pRoot = $this;

  goto AAALoopCont1;
 AAALoopExit1:
  return;

}


#bind _key_H to H menu Hide/Show current subtree
sub _key_H {

  HideSubtree();

}


#bind _key_Ctrl_Shift_U to Ctrl+Shift+U menu Pripojit akt. vrchol k matce (spojit lemmata, vhodne pro predlozky)
sub _key_Ctrl_Shift_U {

  $sPar1 = "1";

  JoinSubtree();

}


#bind _key_Ctrl_Shift_N to Ctrl+Shift+N menu Pripojit akt. vrchol k matce (nespojit lemmata, vhodne pro modal. sloveso)
sub _key_Ctrl_Shift_N {

  $sPar1 = "0";

  JoinSubtree();

}


#bind _key_Ctrl_Shift_S to Ctrl+Shift+S menu Doplnit Gen.ACT pod akt. vrchol
sub _key_Ctrl_Shift_S {

  $sPar1 = 'Gen';

  NewSubject();

}


#bind _key_Ctrl_Shift_K to Ctrl+Shift+K menu Doplnit Cor.ACT pod akt. vrchol
sub _key_Ctrl_Shift_K {

  $sPar1 = 'Cor';

  NewSubject();

}


#bind _key_Ctrl_Shift_O to Ctrl+Shift+O menu Doplnit on.ACT pod akt. vrchol
sub _key_Ctrl_Shift_O {

  $sPar1 = 'on';

  NewSubject();

}


#bind _key_Ctrl_Shift_X to Ctrl+Shift+X menu Doplnit novy uzel (???) pod akt. vrchol
sub _key_Ctrl_Shift_X {

  $pPar1 = $this;

  NewSon();

}


#bind _key_Ctrl_Shift_V to Ctrl+Shift+V menu Doplnit prazdne sloveso EV pod akt. vrchol
sub _key_Ctrl_Shift_V {

  NewVerb();

}


#bind _key_Ctrl_Shift_W to Ctrl+Shift+W menu Zmenit trlemma na lemma
sub _key_Ctrl_Shift_W {

  trtolemma();

}


#bind _key_Ctrl_Shift_P to Ctrl+Shift+P menu Pripojit akt. vrchol k matce jako fw
sub _key_Ctrl_Shift_P {

  joinfw();

}


#bind _key_Shift_X to Shift+X menu Pridat k funktoru ???
sub _key_Shift_X {

  $pPar1 = $this;

  $sPar1 = ValNo(0,Union($pPar1->{'func'},'???'));

  FuncAssign();

}


#bind _key_Ctrl_Shift_Q to Ctrl+Shift+Q menu Odpojit pripojene fw od akt. vrcholu
sub _key_Ctrl_Shift_Q {

  splitfw();

}


#bind _key_A to A menu ACT Actor, agens
sub _key_A {

  $sPar1 = 'ACT';

  FuncAssign();

}


#bind _key_D to D menu ADDR Addressee
sub _key_D {

  $sPar1 = 'ADDR';

  FuncAssign();

}


#bind _key_P to P menu PAT Patient (prosli celý les.PAT)
sub _key_P {

  $sPar1 = 'PAT';

  FuncAssign();

}


#bind _key_F to F menu EFF Effect, výsledek (zvolit kým)
sub _key_F {

  $sPar1 = 'EFF';

  FuncAssign();

}


#bind _key_O to O menu ORIG Origin, pùvod (z èeho, NE odkud)
sub _key_O {

  $sPar1 = 'ORIG';

  FuncAssign();

}


#bind _key_C to C menu ACMP  Accompaniment, doprovod (s, bez)
sub _key_C {

  $sPar1 = 'ACMP';

  FuncAssign();

}


#bind _key_V to V menu ADVS Adversative, odporovací koord. (ale, vsak)
sub _key_V {

  $sPar1 = 'ADVS';

  FuncAssign();

}


#bind _key_M to M menu AIM Úèel (aby, pro nìco)
sub _key_M {

  $sPar1 = 'AIM';

  FuncAssign();

}


#bind _key_Shift_P to Shift+P menu APP Appurtenance, pøinálezitost (èí, èeho)
sub _key_Shift_P {

  $sPar1 = 'APP';

  FuncAssign();

}


#bind _key_Shift_A to Shift+A menu APPS Apposition (totiz, a to)
sub _key_Shift_A {

  $sPar1 = 'APPS';

  FuncAssign();

}


#bind _key_T to T menu ATT Attitude, postoj
sub _key_T {

  $sPar1 = 'ATT';

  FuncAssign();

}


#bind _key_N to N menu BEN Benefactive (pro koho, proti komu)
sub _key_N {

  $sPar1 = 'BEN';

  FuncAssign();

}


#bind _key_Shift_C to Shift+C menu CAUS Cause, pøíèina
sub _key_Shift_C {

  $sPar1 = 'CAUS';

  FuncAssign();

}


#bind _key_Ctrl_C to Ctrl+C menu CNCS
sub _key_Ctrl_C {

  $sPar1 = 'CNCS';

  FuncAssign();

}


#bind _key_Ctrl_P to Ctrl+P menu COMPL Complement, závisí na slovese
sub _key_Ctrl_P {

  $sPar1 = 'COMPL';

  FuncAssign();

}


#bind _key_Ctrl_D to Ctrl+D menu COND Condition, podmínka reálná (-li, jestlize, kdyz, az)
sub _key_Ctrl_D {

  $sPar1 = 'COND';

  FuncAssign();

}


#bind _key_J to J menu CONJ Conjunction, sluèovací koord. (a)
sub _key_J {

  $sPar1 = 'CONJ';

  FuncAssign();

}


#bind _key_Ctrl_Shift_R to Ctrl+Shift+R menu CPR Porovnání (nez, jako, stejnì jako)
sub _key_Ctrl_Shift_R {

  $sPar1 = 'CPR';

  FuncAssign();

}


#bind _key_I to I menu CRIT Criterion, mìøítko (podle nìj, podle jeho slov)
sub _key_I {

  $sPar1 = 'CRIT';

  FuncAssign();

}


#bind _key_Q to Q menu CSQ Consequence, dùsledek koord. (a proto, a tak, a tedy, proèez)
sub _key_Q {

  $sPar1 = 'CSQ';

  FuncAssign();

}


#bind _key_Ctrl_Shift_C to Ctrl+Shift+C menu CTERF Counterfactual, ireálná podmínka (kdyby)
sub _key_Ctrl_Shift_C {

  $sPar1 = 'CTERF';

  FuncAssign();

}


#bind _key_Ctrl_O to Ctrl+O menu DENOM Pojmenování
sub _key_Ctrl_O {

  $sPar1 = 'DENOM';

  FuncAssign();

}


#bind _key_S to S menu DES Deskr. pøívl., nerestr. (zlatá Praha, lidé mající ...)
sub _key_S {

  $sPar1 = 'DES';

  FuncAssign();

}


#bind _key_Shift_F to Shift+F menu DIFF Difference, rozdíl (oè)
sub _key_Shift_F {

  $sPar1 = 'DIFF';

  FuncAssign();

}


#bind _key_Shift_F1 to Shift+F1 menu DIR1 Odkud
sub _key_Shift_F1 {

  $sPar1 = 'DIR1';

  FuncAssign();

}


#bind _key_Shift_F2 to Shift+F2 menu DIR2 Kudy (prosli lesem)
sub _key_Shift_F2 {

  $sPar1 = 'DIR2';

  FuncAssign();

}


#bind _key_Shift_F3 to Shift+F3 menu DIR3 Kam
sub _key_Shift_F3 {

  $sPar1 = 'DIR3';

  FuncAssign();

}


#bind _key_Shift_J to Shift+J menu DISJ Disjunction, rozluèovací koord. (nebo, anebo)
sub _key_Shift_J {

  $sPar1 = 'DISJ';

  FuncAssign();

}


#bind _key_Ctrl_X to Ctrl+X menu DPHR zavisla cast frazemu
sub _key_Ctrl_X {

  $sPar1 = 'DPHR';

  FuncAssign();

}


#bind _key_Shift_E to Shift+E menu ETHD Ethical Dative (já ti mám knih, dìti nám nechodí vèas)
sub _key_Shift_E {

  $sPar1 = 'ETHD';

  FuncAssign();

}


#bind _key_E to E menu EV Empty verb, elidovane sloveso
sub _key_E {

  $sPar1 = 'EV';

  FuncAssign();

}


#bind _key_X to X menu EXT Extent, míra (velmi, trochu)
sub _key_X {

  $sPar1 = 'EXT';

  FuncAssign();

}


#bind _key_Ctrl_U to Ctrl+U menu FPHR fraze v cizim jazyce
sub _key_Ctrl_U {

  $sPar1 = 'FPHR';

  FuncAssign();

}


#bind _key_Ctrl_G to Ctrl+G menu GRAD Gradation, stupòovací koord (i, a také)
sub _key_Ctrl_G {

  $sPar1 = 'GRAD';

  FuncAssign();

}


#bind _key_Ctrl_Shift_H to Ctrl+Shift+H menu HER heritage, dìdictví (po otci)
sub _key_Ctrl_Shift_H {

  $sPar1 = 'HER';

  FuncAssign();

}


#bind _key_Shift_D to Shift+D menu ID Identity (pojem èasu, øeka Vltava)
sub _key_Shift_D {

  $sPar1 = 'ID';

  FuncAssign();

}


#bind _key_Ctrl_F to Ctrl+F menu INTF falesný podmìt (To Karel jestì nepøisel?)
sub _key_Ctrl_F {

  $sPar1 = 'INTF';

  FuncAssign();

}


#bind _key_Ctrl_Shift_T to Ctrl+Shift+T menu INTT zámìr (šel se koupat)
sub _key_Ctrl_Shift_T {

  $sPar1 = 'INTT';

  FuncAssign();

}


#bind _key_L to L menu LOC Location, místo kde (jednání uvnitø koalice)
sub _key_L {

  $sPar1 = 'LOC';

  FuncAssign();

}


#bind _key_Shift_N to Shift+N menu MANN Manner, zpùsob (ústnì, psát èesky)
sub _key_Shift_N {

  $sPar1 = 'MANN';

  FuncAssign();

}


#bind _key_Ctrl_T to Ctrl+T menu MAT Partitiv (hrnek èaje)
sub _key_Ctrl_T {

  $sPar1 = 'MAT';

  FuncAssign();

}


#bind _key_Ctrl_E to Ctrl+E menu MEANS Prostøedek (psát rukou, tuzkou)
sub _key_Ctrl_E {

  $sPar1 = 'MEANS';

  FuncAssign();

}


#bind _key_Ctrl_M to Ctrl+M menu MOD Adv. of modality (asi, mozná, to je myslím zlé)
sub _key_Ctrl_M {

  $sPar1 = 'MOD';

  FuncAssign();

}


#bind _key_Shift_M to Shift+M menu NORM Norma (ve shodì s, podle)
sub _key_Shift_M {

  $sPar1 = 'NORM';

  FuncAssign();

}


#bind _key_Shift_R to Shift+R menu PAR Parenthesis, vsuvka (myslím, vìøím)
sub _key_Shift_R {

  $sPar1 = 'PAR';

  FuncAssign();

}


#bind _key_Ctrl_V to Ctrl+V menu PREC Ref. to prec. text(na zaè. vìty:tedy, tudíz, totiz,protoze, ..)
sub _key_Ctrl_V {

  $sPar1 = 'PREC';

  FuncAssign();

}


#bind _key_R to R menu PRED Predikat
sub _key_R {

  $sPar1 = 'PRED';

  FuncAssign();

}


#bind _key_Ctrl_R to Ctrl+R menu REAS Reason, dùvod (nebo)
sub _key_Ctrl_R {

  $sPar1 = 'REAS';

  FuncAssign();

}


#bind _key_G to G menu REG Regard (se zøetelem, s ohledem)
sub _key_G {

  $sPar1 = 'REG';

  FuncAssign();

}


#bind _key_Shift_S to Shift+S menu RESL Úèinek (takze)
sub _key_Shift_S {

  $sPar1 = 'RESL';

  FuncAssign();

}


#bind _key_Ctrl_S to Ctrl+S menu RESTR Omezení (kromì, mimo)
sub _key_Ctrl_S {

  $sPar1 = 'RESTR';

  FuncAssign();

}


#bind _key_Shift_H to Shift+H menu RHEM Rhematizer (i, také, jenom,vùbec, NEG, nikoli)
sub _key_Shift_H {

  $sPar1 = 'RHEM';

  FuncAssign();

}


#bind _key_Shift_T to Shift+T menu RSTR restriktivní pøívlastek
sub _key_Shift_T {

  $sPar1 = 'RSTR';

  FuncAssign();

}


#bind _key_B to B menu SUBS Zastoupení (místo koho-èeho)
sub _key_B {

  $sPar1 = 'SUBS';

  FuncAssign();

}


#bind _key_Ctrl_H to Ctrl+H menu TFHL For how long, na jak dlouho (na vìky)
sub _key_Ctrl_H {

  $sPar1 = 'TFHL';

  FuncAssign();

}


#bind _key_W to W menu TFRWH From when, zekdy (zbylo od vánoc cukroví)
sub _key_W {

  $sPar1 = 'TFRWH';

  FuncAssign();

}


#bind _key_Shift_L to Shift+L menu THL How long, jak dlouho (èetl pùl hodiny)
sub _key_Shift_L {

  $sPar1 = 'THL';

  FuncAssign();

}


#bind _key_Shift_O to Shift+O menu THO How often, jak dlouho (èetl dennì)
sub _key_Shift_O {

  $sPar1 = 'THO';

  FuncAssign();

}


#bind _key_Ctrl_W to Ctrl+W menu TOWH To when, nakdy (pøelozí výuku na pátek)
sub _key_Ctrl_W {

  $sPar1 = 'TOWH';

  FuncAssign();

}


#bind _key_Ctrl_A to Ctrl+A menu TPAR Parallel (bìhem, zatímco, za celý zápas, mezitím co)
sub _key_Ctrl_A {

  $sPar1 = 'TPAR';

  FuncAssign();

}


#bind _key_Ctrl_I to Ctrl+I menu TSIN Since, odkdy (od té doby co, ode dne podpisu)
sub _key_Ctrl_I {

  $sPar1 = 'TSIN';

  FuncAssign();

}


#bind _key_Shift_I to Shift+I menu TTILL Till, dokdy (az do, dokud ne, nez)
sub _key_Shift_I {

  $sPar1 = 'TTILL';

  FuncAssign();

}


#bind _key_Shift_W to Shift+W menu TWHEN When, kdy (loni, vstupuje v platnost dnem podpisu)
sub _key_Shift_W {

  $sPar1 = 'TWHEN';

  FuncAssign();

}


#bind _key_Shift_V to Shift+V menu VOC Vokativní vìta (Jirko!)
sub _key_Shift_V {

  $sPar1 = 'VOC';

  FuncAssign();

}


#bind _key_Shift_K to Shift+K menu VOCAT Vokativ aponovaný (Pojï sem, Jirko!)
sub _key_Shift_K {

  $sPar1 = 'VOCAT';

  FuncAssign();

}


#bind _key_Ctrl_N to Ctrl+N menu NA Not Applicable, toto slovo nemá funktor
sub _key_Ctrl_N {

  $sPar1 = 'NA';

  FuncAssign();

}


#bind _key_Ctrl_Y to Ctrl+Y menu ???
sub _key_Ctrl_Y {

  $sPar1 = '???';

  FuncAssign();

}


#bind _key_K to K menu tfa = topic
sub _key_K {

  $sPar1 = 'T';

  TFAAssign();

}


#bind _key_U to U menu tfa = focus
sub _key_U {

  $sPar1 = 'F';

  TFAAssign();

}


#bind _key_Shift_Q to Shift+Q menu posun uzel doleva
sub _key_Shift_Q {

  $sPar1 = 'L';

  MoveNode();

}


#bind _key_Shift_U to Shift+U menu posun uzel doprava
sub _key_Shift_U {

  $sPar1 = 'R';

  MoveNode();

}


#bind _key_Ctrl_Shift_Z to Ctrl+Shift+Z menu Podpis Zdena Uresova
sub _key_Ctrl_Shift_Z {

  $sPar1 = 'ZU/func_EB/tfa';

  SignatureAssign();

}


#bind _key_Ctrl_Shift_A to Ctrl+Shift+A menu Podpis Alla Bemova
sub _key_Ctrl_Shift_A {

  $sPar1 = 'AB/func_EB/tfa';

  SignatureAssign();

}


#bind _key_Ctrl_Shift_E to Ctrl+Shift+E menu Podpis Eva Buranova
sub _key_Ctrl_Shift_E {

  $sPar1 = 'EB/func_EB/tfa';

  SignatureAssign();

}


#bind _key_Ctrl_Shift_F2 to Ctrl+Shift+F2
sub _key_Ctrl_Shift_F2 {

  TreeToTR();

}


#bind _key_Ctrl_Shift_F8 to Ctrl+Shift+F8
sub _key_Ctrl_Shift_F8 {

  InitFileTR();

}


sub TreeToTR {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pThis;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') eq 'TR_TREE') {

    return;
  }

  $pRoot->{'reserve1'} = 'TR_TREE';

  $pAct = $this;

  RelTyp();

  MorphGram();

  AuxPY();

  Numeratives();

  PassiveVerb();

  NumAndNoun();

  ActiveVerb();

  DegofComp();

  TRAuxO();

  Quot();

  Prepositions();

  Sentmod();

  TRVerbs();

  ModalVerbs();

  FillEmpty();

}


sub InitFileTR {
  my $pRoot;			# used as type "pointer"
  my $iStart;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $iStart = substr(ValNo(0,$pRoot->{'form'}),1,10);
 AAALoopCont1:
  $pPar1 = $pRoot;

  InitTR();

  NextTree();

  if ($_NoSuchTree=="1") {

    goto AAALoopExit1;
  }

  $pRoot = $this;

  goto AAALoopCont1;
 AAALoopExit1:
  return;

}


sub InitTR {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sForm;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;

  $pNext = $pAct;
 PruchodStromemDoHloubky:
  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sForm = ValNo(0,$pAct->{'lemma'});

  $sPar1 = $sForm;

  GetAfunSuffix();

  $pAct->{'trlemma'} = $sPar2;

  $pAct->{'dord'} = $pAct->{'ord'};

  $pAct->{'sentord'} = $pAct->{'ord'};

  if (Interjection($pAct->{'afun'},'AuxS') eq 'AuxS') {

    $pAct->{'trlemma'} = $pAct->{'form'};
  }

  if (Interjection($pAct->{'afun'},'Pred') eq 'Pred' ||
      Interjection($pAct->{'afun'},'Pred_Co') eq 'Pred_Co' ||
      Interjection($pAct->{'afun'},'Pred_Pa') eq 'Pred_Pa' ||
      Interjection($pAct->{'afun'},'Pred_Ap') eq 'Pred_Ap') {

    $pAct->{'func'} = 'PRED';
  }

  $pNext = FirstSon($pAct);

  goto PruchodStromemDoHloubky;

}


sub Init {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sForm = ValNo(0,$pAct->{'lemma'});

  $sPar1 = $sForm;

  GetAfunSuffix();

  $pAct->{'trlemma'} = $sPar2;

  if (Interjection($pAct->{'afun'},'Pred') eq 'Pred' ||
      Interjection($pAct->{'afun'},'Pred_Co') eq 'Pred_Co' ||
      Interjection($pAct->{'afun'},'Pred_Pa') eq 'Pred_Pa' ||
      Interjection($pAct->{'afun'},'Pred_Ap') eq 'Pred_Ap') {

    $pAct->{'func'} = 'PRED';
  }

  goto PruchodStromemDoHloubky;

}


sub MorphGram {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTag1;			# used as type "string"
  my $sVTag2;			# used as type "string"
  my $sVTag3;			# used as type "string"
  my $sVTag4;			# used as type "string"
  my $sVTag5;			# used as type "string"
  my $sVTag6;			# used as type "string"
  my $sVTag7;			# used as type "string"
  my $sVTag8;			# used as type "string"
  my $i;			# used as type "string"
  my $sGender;			# used as type "string"
  my $sNumber;			# used as type "string"
  my $sN;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $sTag = '';

  $sVTag1 = '';

  $sVTag2 = '';

  $sVTag3 = '';

  $sVTag4 = '';

  $sVTag5 = '';

  $sVTag6 = '';

  $sVTag7 = '';

  $sVTag8 = '';

  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTag1 = substr($sTag,0,1);

  if ($sVTag1 eq '') {

    goto PruchodStromemDoHloubky;
  }

  $sVTag2 = substr($sTag,1,1);

  if ($sVTag2 eq '') {

    $i = "0";

    goto MGContinue;
  }

  $sVTag3 = substr($sTag,2,1);

  if ($sVTag3 eq '') {

    $i = "1";

    goto MGContinue;
  }

  $sVTag4 = substr($sTag,3,1);

  if ($sVTag4 eq '') {

    $i = "2";

    goto MGContinue;
  }

  $sVTag5 = substr($sTag,4,1);

  if ($sVTag5 eq '') {

    $i = "3";

    goto MGContinue;
  }

  $sVTag6 = substr($sTag,5,1);

  if ($sVTag6 eq '') {

    $i = "4";

    goto MGContinue;
  }

  $sVTag7 = substr($sTag,6,1);

  if ($sVTag7 eq '') {

    $i = "5";

    goto MGContinue;
  }

  $sVTag8 = substr($sTag,7,1);

  if ($sVTag8 eq '') {

    $i = "6";

    goto MGContinue;
  } else {

    $i = "7";
  }

 MGContinue:
  if ($sVTag1 eq 'V') {

    goto Verb;
  }

  if ($sVTag1 eq 'N') {

    goto Noun;
  }

  if ($sVTag1 eq 'A') {

    goto Adject;
  }

  if ($sVTag1 eq 'P') {

    goto Pronoun;
  }

  goto PruchodStromemDoHloubky;
 Verb:
  if (substr($sTag,11,1) eq 'N') {

    $pPar1 = $pAct;

    NewSon();

    $pT = $pReturn;

    $pT->{'func'} = 'RHEM';

    $pT->{'trlemma'} = 'Neg';

    $pT->{'del'} = 'ELID';

    $pT->{'reserve2'} = 'Neg';
  }

  goto PruchodStromemDoHloubky;
 Adject:
  goto Noun;
 Noun:
  if ($i eq "2" &&
      $sVTag2 eq 'A') {

    goto PruchodStromemDoHloubky;
  }

  if ($sVTag2 eq 'M') {

    $sGender = 'ANIM';
  }

  if ($sVTag2 eq 'I') {

    $sGender = 'INAN';
  }

  if ($sVTag2 eq 'F') {

    $sGender = 'FEM';
  }

  if ($sVTag2 eq 'N') {

    $sGender = 'NEUT';
  }

  if ($sVTag2 eq 'X') {

    $sGender = '???';
  }

  if ($sVTag2 eq 'Y') {

    $sGender = ValNo(0,Union('ANIM','INAN'));
  }

  if ($sVTag2 eq 'H') {

    $sGender = ValNo(0,Union('FEM','NEUT'));
  }

  if ($sVTag2 eq 'Q') {

    $sGender = ValNo(0,Union('FEM','NEUT'));
  }

  if ($sVTag2 eq 'T') {

    $sGender = ValNo(0,Union('INAN','FEM'));
  }

  if ($sVTag2 eq 'Z') {

    $sGender = ValNo(0,Union('ANIM','INAN'));
  }

  if ($sVTag2 eq 'W') {

    $sGender = ValNo(0,Union('INAN','NEUT'));
  }

  $pAct->{'gender'} = $sGender;

  if ($sVTag3 eq 'S') {

    $sNumber = 'SG';
  }

  if ($sVTag3 eq 'P') {

    $sNumber = 'PL';
  }

  if ($sVTag3 eq 'D') {

    $sNumber = '???';
  }

  if ($sVTag3 eq 'X') {

    $sNumber = '???';
  }

  $pAct->{'number'} = $sNumber;

  goto PruchodStromemDoHloubky;
 Pronoun:
  if ($i eq "2" &&
      $sVTag2 eq 'A') {

    goto PruchodStromemDoHloubky;
  }

  $i = $i-"1";

  $sN = substr($sTag,$i,1);

  if ($sN eq 'S') {

    $sNumber = 'SG';
  }

  if ($sN eq 'P') {

    $sNumber = 'PL';
  }

  $pAct->{'number'} = $sNumber;

  $i = $i-"1";

  $sN = substr($sTag,$i,1);

  if ($sN eq 'M') {

    $sGender = 'ANIM';
  }

  if ($sN eq 'I') {

    $sGender = 'INAN';
  }

  if ($sN eq 'F') {

    $sGender = 'FEM';
  }

  if ($sN eq 'N') {

    $sGender = 'NEUT';
  }

  if ($sN eq 'X') {

    $sGender = '???';
  }

  if ($sN eq 'Y') {

    $sGender = ValNo(0,Union('ANIM','INAN'));
  }

  if ($sN eq 'H') {

    $sGender = ValNo(0,Union('FEM','NEUT'));
  }

  if ($sN eq 'Q') {

    $sGender = ValNo(0,Union('FEM','NEUT'));
  }

  if ($sN eq 'T') {

    $sGender = ValNo(0,Union('INAN','FEM'));
  }

  if ($sN eq 'Z') {

    $sGender = ValNo(0,Union('ANIM','INAN'));
  }

  if ($sN eq 'W') {

    $sGender = ValNo(0,Union('INAN','NEUT'));
  }

  $pAct->{'gender'} = $sGender;

  goto PruchodStromemDoHloubky;

}


sub Numeratives {
  my $pAct;			# used as type "pointer"
  my $pParAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pTisice;			# used as type "pointer"
  my $pStovky;			# used as type "pointer"
  my $pDesitky;			# used as type "pointer"
  my $pJednotky;		# used as type "pointer"
  my $sTisice;			# used as type "string"
  my $sStovky;			# used as type "string"
  my $sDesitky;			# used as type "string"
  my $sJednotky;		# used as type "string"
  my $sTag;			# used as type "string"
  my $sTag1;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }

  if (!($pNext)) {

    return;
  }

  $pAct = $pNext;

  $pParAct = Parent($pAct);

  if (Interjection($pAct->{'form'},'tisíc') eq 'tisíc') {

    $sTag = ValNo(0,$pParAct->{'tag'});

    $sTag1 = substr($sTag,0,1);

    if ($sTag1 eq 'C') {

      $pT = FirstSon($pAct);

      if ($pT) {

	if (Interjection($pT->{'ordorig'},'') eq '') {

	  $pT->{'ordorig'} = Parent($pT)->{'ord'};
	}

	$NodeClipboard=CutNode($pT);

	$pDummy = PasteNode($NodeClipboard,$pParAct);
      }
    }
  }

  goto PruchodStromemDoHloubky;

}


sub PassiveVerb {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTagBeg = substr($sTag,0,2);

  if ($sVTagBeg eq 'Vs') {

    $pVerb = $pAct;

    $pT = FirstSon($pVerb);
  PodstromVS:
    if (!($pT)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pT->{'afun'},'Obj') eq 'Obj') {

      $pT->{'func'} = 'ACT';
    }

    $pT = RBrother($pT);

    goto PodstromVS;
  }

  goto PruchodStromemDoHloubky;

}


sub NumAndNoun {
  my $pAct;			# used as type "pointer"
  my $pNum;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pD1;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTagBeg = substr($sTag,0,1);

  if ($sVTagBeg eq 'C' ||
      $sTag eq 'ZNUM') {

    $pNum = $pAct;

    $pSon = FirstSon($pNum);
  CheckSons:
    if ($pSon) {

      $pParent = Parent($pNum);

      $sTag = ValNo(0,$pSon->{'tag'});

      $sVTagBeg = substr($sTag,0,1);

      if ($sVTagBeg eq 'N') {

	if (Interjection($pSon->{'ordorig'},'') eq '') {

	  $pSon->{'ordorig'} = Parent($pSon)->{'ord'};
	}

	$NodeClipboard=CutNode($pSon);

	$pD = PasteNode($NodeClipboard,$pParent);

	if (Interjection($pNum->{'ordorig'},'') eq '') {

	  $pNum->{'ordorig'} = Parent($pNum)->{'ord'};
	}

	$NodeClipboard=CutNode($pNum);

	$pD1 = PasteNode($NodeClipboard,$pD);

	$pAct = $pD;
      } else {

	if (RBrother($pSon)) {

	  $pSon = RBrother($pSon);

	  goto CheckSons;
	}
      }

    }
  }

  goto PruchodStromemDoHloubky;

}


sub RelTyp {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sSuffix;			# used as type "string"
  my $sForm;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'lemma'},',') eq ',') {

    $pAct->{'trlemma'} = 'Comma';

    $pAct->{'reserve1'} = 'Comma';
  }

  $sForm = ValNo(0,$pAct->{'lemma'});

  $sPar1 = $sForm;

  GetAfunSuffix();

  $pAct->{'trlemma'} = $sPar2;

  $sPar1 = ValNo(0,$pAct->{'afun'});

  GetAfunSuffix();

  $sSuffix = substr($sPar3,0,3);

  $sAfun = $sPar2;

  $pAct->{'reserve2'} = $sAfun;

  if ($sSuffix eq '_Co') {

    $pAct->{'reltype'} = 'CO';
  } else {

    if ($sSuffix eq '_Ap') {

      $pAct->{'reltype'} = 'NIL';

      Parent($pAct)->{'func'} = 'APPS';
    } else {

      if ($sSuffix eq '_Pa') {

	$pAct->{'reltype'} = 'PA';

	if (Interjection($pAct->{'afun'},'AuxY_Pa') eq 'AuxY_Pa') {

	  $pAct->{'func'} = 'PAR';
	} else {

	  $pAct->{'func'} = 'PAR';
	}

      } else {

	$pAct->{'reltype'} = 'NIL';
      }

    }

  }


  goto PruchodStromemDoHloubky;

}


sub TRAuxO {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sCase;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'afun'},'AuxO') eq 'AuxO') {

    $sTag = ValNo(0,$pAct->{'tag'});

    $sCase = substr($sTag,4,1);

    if ($sCase eq "3") {

      $pAct->{'gram'} = 'ETHD';
    } else {

      $pAct->{'func'} = 'INTF';
    }

  }

  goto PruchodStromemDoHloubky;

}


sub DegofComp {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $pAdj;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sVTagCase;		# used as type "string"
  my $sVTagDeg;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTagBeg = substr($sTag,0,1);

  $sVTagCase = substr($sTag,4,1);

  $sVTagDeg = substr($sTag,9,1);

  if ($sVTagBeg eq 'A') {

    $pAdj = $pAct;

    if ($sVTagDeg eq "1") {

      $pAdj->{'degcmp'} = 'POS';
    }

    if ($sVTagDeg eq "2") {

      $pAdj->{'degcmp'} = 'COMP';
    }

    if ($sVTagDeg eq "3") {

      $pAdj->{'degcmp'} = 'SUP';
    }
  } else {

    $pAct->{'degcmp'} = 'NA';
  }


  goto PruchodStromemDoHloubky;

}


sub ActiveVerb {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg1;		# used as type "string"
  my $sVTagBeg2;		# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTagBeg1 = substr($sTag,0,1);

  $sVTagBeg2 = substr($sTag,1,2);

  if ($sVTagBeg1 eq 'V' &&
      $sVTagBeg2 ne 'S') {

    $pVerb = $pAct;

    $pT = FirstSon($pVerb);
  PodstromVS:
    if (!($pT)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pT->{'afun'},'Sb') eq 'Sb') {

      $pT->{'func'} = 'ACT';
    }

    $pT = RBrother($pT);

    goto PodstromVS;
  }

  goto PruchodStromemDoHloubky;

}


sub AuxPY {
  my $pAct;			# used as type "pointer"
  my $pPrepParent;		# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pBlind;			# used as type "pointer"
  my $pSubtree;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sPrep;			# used as type "string"
  my $sPrepBody;		# used as type "string"
  my $sPrepTail;		# used as type "string"
  my $BodyOrder;		# used as type "string"
  my $TailOrder;		# used as type "string"
  my $sPomocny;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'afun'},'AuxP') eq 'AuxP' ||
      Interjection($pAct->{'afun'},'AuxY') eq 'AuxY') {

    $pPrepParent = Parent($pAct);

    if (Interjection($pPrepParent->{'afun'},'AuxP') eq 'AuxP') {

      $sPrepBody = ValNo(0,$pPrepParent->{'trlemma'});

      $sPrepTail = ValNo(0,$pAct->{'trlemma'});

      $BodyOrder = ValNo(0,$pPrepParent->{'ord'});

      $TailOrder = ValNo(0,$pAct->{'ord'});

      if ($TailOrder>$BodyOrder) {

	$sPomocny = (ValNo(0,$sPrepBody).ValNo(0,'_'));

	$sPrep = (ValNo(0,$sPomocny).ValNo(0,$sPrepTail));
      } else {

	$sPomocny = (ValNo(0,'_').ValNo(0,$sPrepBody));

	$sPrep = (ValNo(0,$sPrepTail).ValNo(0,$sPomocny));
      }


      $pPrepParent->{'trlemma'} = $sPrep;

      $pAct->{'TR'} = 'hide';

      $pSubtree = FirstSon($pAct);

      if ($pSubtree) {

	if (Interjection($pSubtree->{'ordorig'},'') eq '') {

	  $pSubtree->{'ordorig'} = Parent($pSubtree)->{'ord'};
	}

	$NodeClipboard=CutNode($pSubtree);

	$pBlind = PasteNode($NodeClipboard,$pPrepParent);
      }
    }
  }

  if (Interjection($pAct->{'afun'},'AuxY') eq 'AuxY') {

    $pPrepParent = Parent($pAct);

    if (Interjection($pPrepParent->{'afun'},'AuxC') eq 'AuxC' ||
	Interjection($pPrepParent->{'afun'},'Coord') eq 'Coord') {

      $sPrepBody = ValNo(0,$pPrepParent->{'trlemma'});

      $sPrepTail = ValNo(0,$pAct->{'trlemma'});

      $BodyOrder = ValNo(0,$pPrepParent->{'ord'});

      $TailOrder = ValNo(0,$pAct->{'ord'});

      if ($TailOrder>$BodyOrder) {

	$sPomocny = (ValNo(0,$sPrepBody).ValNo(0,'_'));

	$sPrep = (ValNo(0,$sPomocny).ValNo(0,$sPrepTail));
      } else {

	$sPomocny = (ValNo(0,'_').ValNo(0,$sPrepBody));

	$sPrep = (ValNo(0,$sPrepTail).ValNo(0,$sPomocny));
      }


      $pPrepParent->{'trlemma'} = $sPrep;

      $pAct->{'TR'} = 'hide';
    }
  }

  goto PruchodStromemDoHloubky;

}


sub TRVerbs {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $pThisSon;			# used as type "pointer"
  my $pBYT;			# used as type "pointer"
  my $pBYT2;			# used as type "pointer"
  my $pBY;			# used as type "pointer"
  my $pPNOM;			# used as type "pointer"
  my $pSE;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sXTag;			# used as type "string"
  my $sXTagBeg;			# used as type "string"
  my $sTrlema;			# used as type "string"
  my $sAuxVlema;		# used as type "string"
  my $sSuffix;			# used as type "string"
  my $sVSuffix;			# used as type "string"
  my $sSEForm;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sVTagBeg = substr($sTag,0,1);

  if ($sVTagBeg eq 'V') {

    $pVerb = $pAct;

    if (Interjection($pVerb->{'afun'},'AuxV') ne 'AuxV') {

      $sPar1 = ValNo(0,$pVerb->{'lemma'});

      GetAfunSuffix();

      $sVSuffix = $sPar3;

      if ($sVSuffix eq '_:T') {

	$pVerb->{'aspect'} = 'PROC';
      }

      if ($sVSuffix eq '_:W') {

	$pVerb->{'aspect'} = 'CPL';
      }

      if (FirstSon($pVerb)) {

	$sVTagBeg = substr($sTag,0,2);

	$pThisSon = FirstSon($pVerb);

	$pBY = undef;

	$pBYT = undef;

	$pBYT2 = undef;

	$pPNOM = undef;

	$pSE = undef;
      AllSons:
	if (Interjection($pThisSon->{'afun'},'AuxV') eq 'AuxV') {

	  if (Interjection($pThisSon->{'lemma'},'být') eq 'být' &&
	      Interjection($pThisSon->{'form'},'by') ne 'by') {

	    if ($pBYT) {

	      $pBYT2 = $pThisSon;

	      $pThisSon->{'TR'} = 'hide';
	    }

	    if (!($pBYT)) {

	      $pBYT = $pThisSon;

	      $pThisSon->{'TR'} = 'hide';
	    }
	  }

	  if (Interjection($pThisSon->{'form'},'by') eq 'by' ||
	      Interjection($pThisSon->{'form'},'bych') eq 'bych' ||
	      Interjection($pThisSon->{'form'},'bys') eq 'bys' ||
	      Interjection($pThisSon->{'form'},'byste') eq 'byste' ||
	      Interjection($pThisSon->{'form'},'bysme') eq 'bysme' ||
	      Interjection($pThisSon->{'form'},'bychom') eq 'bychom') {

	    $pBY = $pThisSon;

	    $pThisSon->{'TR'} = 'hide';
	  }
	}

	if (Interjection($pThisSon->{'afun'},'AuxT') eq 'AuxT') {

	  $pSE = $pThisSon;

	  $sSEForm = ValNo(0,$pSE->{'form'});

	  $pSE->{'TR'} = 'hide';
	}

	if (Interjection($pThisSon->{'afun'},'Pnom') eq 'Pnom') {

	  $sVTagBeg = substr(ValNo(0,$pThisSon->{'tag'}),0,1);

	  if ($sVTagBeg eq 'V') {

	    $pPNOM = $pThisSon;

	    $pCut = FirstSon($pPNOM);
	  CutAllSubtrees:
	    if ($pCut) {

	      if (Interjection($pCut->{'ordorig'},'') eq '') {

		$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
	      }

	      $NodeClipboard=CutNode($pCut);

	      $pD = PasteNode($NodeClipboard,Parent($pPNOM));

	      $pCut = FirstSon($pPNOM);

	      goto CutAllSubtrees;
	    }

	    $pPNOM->{'TR'} = 'hide';
	  }
	}

	if (RBrother($pThisSon)) {

	  $pThisSon = RBrother($pThisSon);

	  goto AllSons;
	}

	if ($pSE) {

	  $sTrlema = ValNo(0,$pVerb->{'trlemma'});

	  $sSEForm = (ValNo(0,'_').ValNo(0,$sSEForm));

	  $pVerb->{'trlemma'} = (ValNo(0,$sTrlema).ValNo(0,$sSEForm));
	}

	if (!($pBY)) {

	  if (!($pBYT)) {

	    if ($sVTagBeg eq 'VR') {

	      $pVerb->{'tense'} = 'ANT';
	    }
	  }

	  if ($pBYT) {

	    $sXTag = ValNo(0,$pBYT->{'tag'});

	    $sXTagBeg = substr($sXTag,0,2);

	    if ($sXTagBeg eq 'VU') {

	      $pVerb->{'tense'} = 'POST';
	    }
	  }
	}

	if ($pBY &&
	    !($pBYT)) {

	  $pVerb->{'tense'} = 'SIM';

	  $pVerb->{'verbmod'} = 'CDN';
	}

	if ($pBY &&
	    $pBYT &&
	    !($pBYT2)) {

	  $pVerb->{'tense'} = 'ANT';

	  $pVerb->{'verbmod'} = 'CDN';
	}
      } else {

	if ($sVTagBeg eq 'VR') {

	  $pVerb->{'tense'} = 'ANT';
	} else {

	  if ($sVTagBeg eq 'VU') {

	    $pVerb->{'tense'} = 'POST';
	  } else {

	    $pVerb->{'tense'} = 'SIM';
	  }

	}

      }


      $pBY = undef;

      $pBYT = undef;

      $pBYT2 = undef;

      $pPNOM = undef;

      $pSE = undef;
    }
  }

  goto PruchodStromemDoHloubky;

}


sub ModalVerbs {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $pJoin;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pModal;			# used as type "pointer"
  my $sLemma;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sMod;			# used as type "string"
  my $sModLem;			# used as type "string"
  my $sVerbLem;			# used as type "string"
  my $pVerbTag;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sPar1 = ValNo(0,$pAct->{'lemma'});

  GetAfunSuffix();

  if ($sPar2 eq 'chtít') {

    $sMod = 'VOL';

    goto ActNodeWasModalObjReq;
  }

  if ($sPar2 eq 'muset') {

    $sMod = 'DEB';

    goto ActNodeWasModal;
  }

  if ($sPar2 eq 'moci' ||
      Interjection($pAct->{'trlemma'},'dát_se') eq 'dát_se' ||
      Interjection($pAct->{'trlemma'},'dát_by_se') eq 'dát_by_se' ||
      Interjection($pAct->{'trlemma'},'by_se_dát') eq 'by_se_dát') {

    $sMod = 'POSS';

    goto ActNodeWasModal;
  }

  if ($sPar2 eq 'smìt') {

    $sMod = 'PERM';

    goto ActNodeWasModal;
  }

  if ($sPar2 eq 'umìt' ||
      $sPar2 eq 'dovést') {

    $sMod = 'FAC';

    goto ActNodeWasModalObjReq;
  }

  if ($sPar2 eq 'mít') {

    $sMod = 'HRT';

    goto ActNodeWasModalObjReq;
  }

  goto PruchodStromemDoHloubky;
 ActNodeWasModal:
  $pJoin = undef;

  $pModal = $pAct;

  $pVerb = FirstSon($pModal);
 AllSons:
  if ($pVerb) {

    $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);

    if ($pVerbTag eq 'Vf') {

      $pJoin = $pVerb;

      $pModal->{'ID1'} = $pVerbTag;
    } else {

      $pVerb = RBrother($pVerb);

      goto AllSons;
    }

  }

  if ($pJoin) {

    $pCut = FirstSon($pJoin);
  CutAllSubtrees:
    if ($pCut) {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,$pModal);

      $pCut = FirstSon($pJoin);

      goto CutAllSubtrees;
    }

    $pJoin->{'TR'} = 'hide';

    $sVerbLem = ValNo(0,$pJoin->{'trlemma'});

    $pModal->{'trlemma'} = $sVerbLem;

    $pModal->{'deontmod'} = $sMod;
  }

  goto PruchodStromemDoHloubky;
 ActNodeWasModalObjReq:
  $pJoin = undef;

  $pModal = $pAct;

  $pVerb = FirstSon($pModal);
 AllSonsObj:
  if ($pVerb) {

    $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);

    if ($pVerbTag eq 'Vf' &&
	Interjection($pVerb->{'afun'},'Obj') eq 'Obj') {

      $pJoin = $pVerb;

      $pModal->{'ID1'} = $pVerbTag;
    } else {

      $pVerb = RBrother($pVerb);

      goto AllSonsObj;
    }

  }

  if ($pJoin) {

    $pCut = FirstSon($pJoin);
  CutAllSubtreesObj:
    if ($pCut) {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,$pModal);

      $pCut = FirstSon($pJoin);

      goto CutAllSubtreesObj;
    }

    $pJoin->{'TR'} = 'hide';

    $sVerbLem = ValNo(0,$pJoin->{'trlemma'});

    $pModal->{'trlemma'} = $sVerbLem;

    $pModal->{'deontmod'} = $sMod;
  }

  goto PruchodStromemDoHloubky;

}


sub Sentmod {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $pFirstWord;		# used as type "pointer"
  my $pLastWord;		# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sInterpunction;		# used as type "string"
  my $sLastMod;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;

  $pFirstWord = $pRoot;
 FindFirstWord:
  if (FirstSon($pFirstWord)) {

    $pFirstWord = FirstSon($pFirstWord);

    goto FindFirstWord;
  } else {

    return;
  }


  $pLastWord = FirstSon($pAct);
 FindInterpunction:
  if (RBrother($pLastWord)) {

    $pLastWord = RBrother($pLastWord);

    goto FindInterpunction;
  }

  $sInterpunction = ValNo(0,$pLastWord->{'form'});
 LookForVerbs:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    return;
  }

  $pAct = $pNext;

  if (Interjection($pAct->{'afun'},'Pred') eq 'Pred') {

    if ($sInterpunction eq '?') {

      $pAct->{'sentmod'} = 'INTER';
    }

    if ($sInterpunction eq '!') {

      $pAct->{'sentmod'} = 'IMPER';
    }

    if ($sInterpunction eq '.') {

      $pAct->{'sentmod'} = 'DECL';
    }

    return;
  }

  if (Interjection($pNext->{'afun'},'Coord') eq 'Coord') {

    $pAct = FirstSon($pAct);
  FindLast:
    if (RBrother($pAct)) {

      $pAct = RBrother($pAct);

      goto FindLast;
    }
  FindCoordinated:
    if (!($pAct)) {

      return;
    }

    if (Interjection($pAct->{'reltype'},'CO') eq 'CO') {

      $pVerb = $pAct;

      goto LastVerb;
    } else {

      goto FindCoordinated;
    }

  LastVerb:
    if (Interjection($pVerb->{'afun'},'Pred_Co') ne 'Pred_Co') {

      return;
    }

    if ($sInterpunction eq '?') {

      $pAct->{'sentmod'} = 'INTER';
    }

    if ($sInterpunction eq '!') {

      $pAct->{'sentmod'} = 'IMPER';
    }

    if ($sInterpunction eq '.') {

      $pAct->{'sentmod'} = 'DECL';
    }

    $sLastMod = ValNo(0,$pAct->{'sentmod'});
  AnyVerb:
    if (!($pAct)) {

      return;
    }

    $pAct = LBrother($pAct);

    if (Interjection($pAct->{'reltype'},'CO') ne 'CO') {

      $pAct = LBrother($pAct);

      goto AnyVerb;
    }

    if ($sLastMod eq 'INTER') {

      $pAct->{'sentmod'} = 'INTER';
    } else {

      if (Interjection($pAct->{'verbmod'},'IMP') eq 'IMP') {

	$pAct->{'sentmod'} = 'IMPER';
      }

      if (Interjection($pAct->{'verbmod'},'IND') eq 'IND') {

	$pAct->{'sentmod'} = 'ENUNC';
      }

      if (Interjection($pAct->{'verbmod'},'CDN') eq 'CDN') {

	if (Interjection($pFirstWord->{'form'},'kéž') eq 'kéž') {

	  $pAct->{'sentmod'} = 'DESID';
	} else {

	  $pAct->{'sentmod'} = 'ENUNC';
	}

      }
    }


    return;
  }

}


sub Prepositions {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pPrep;			# used as type "pointer"
  my $pConj;			# used as type "pointer"
  my $pOnlyChild;		# used as type "pointer"
  my $pCoordP;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pD1;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sTRLema;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'afun'},'AuxP') eq 'AuxP') {

    if (Interjection($pAct->{'TR'},'hide') eq 'hide') {

      goto PruchodStromemDoHloubky;
    }

    $pPrep = $pAct;

    $pParent = Parent($pPrep);

    if (Interjection($pParent->{'afun'},'AuxP') eq 'AuxP') {

      goto PruchodStromemDoHloubky;
    }

    $pOnlyChild = FirstSon($pPrep);
  FindNoun:
    if (!($pOnlyChild)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pOnlyChild->{'afun'},'AuxP') eq 'AuxP' ||
	Interjection($pOnlyChild->{'afun'},'AuxG') eq 'AuxG') {

      $pOnlyChild = RBrother($pOnlyChild);

      goto FindNoun;
    }

    if (!($pOnlyChild)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pOnlyChild->{'afun'},'Coord') eq 'Coord') {

      $pCoordP = FirstSon($pOnlyChild);
    CoordinationWPrep:
      if ($pCoordP) {

	if (Interjection($pCoordP->{'reltype'},'CO') eq 'CO') {

	  $pCoordP->{'fw'} = $pPrep->{'trlemma'};
	}

	$pCoordP = RBrother($pCoordP);

	goto CoordinationWPrep;
      }
    }

    $sTRLema = ValNo(0,$pPrep->{'trlemma'});

    $pOnlyChild->{'fw'} = $sTRLema;

    $pPrep->{'TR'} = 'hide';

    if (Interjection($pOnlyChild->{'ordorig'},'') eq '') {

      $pOnlyChild->{'ordorig'} = Parent($pOnlyChild)->{'ord'};
    }

    $NodeClipboard=CutNode($pOnlyChild);

    $pD = PasteNode($NodeClipboard,$pParent);

    if (Interjection($pPrep->{'ordorig'},'') eq '') {

      $pPrep->{'ordorig'} = Parent($pPrep)->{'ord'};
    }

    $NodeClipboard=CutNode($pPrep);

    $pD1 = PasteNode($NodeClipboard,$pD);

    $pAct = $pParent;
  }

  if (Interjection($pAct->{'afun'},'AuxC') eq 'AuxC') {

    if (Interjection($pAct->{'TR'},'hide') eq 'hide') {

      goto PruchodStromemDoHloubky;
    }

    $pConj = $pAct;

    $pParent = Parent($pConj);

    $pOnlyChild = FirstSon($pConj);
  FindNoun:
    if (!($pOnlyChild)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pOnlyChild->{'afun'},'AuxX') eq 'AuxX') {

      $pOnlyChild = RBrother($pOnlyChild);

      goto FindNoun;
    }

    $sTRLema = ValNo(0,$pConj->{'trlemma'});

    $pOnlyChild->{'fw'} = $sTRLema;

    if (Interjection($pConj->{'ord'},"1") ne "1") {

      $pConj->{'TR'} = 'hide';
    } else {

      $pConj->{'func'} = 'PREC';
    }


    if (Interjection($pOnlyChild->{'ordorig'},'') eq '') {

      $pOnlyChild->{'ordorig'} = Parent($pOnlyChild)->{'ord'};
    }

    $NodeClipboard=CutNode($pOnlyChild);

    $pD = PasteNode($NodeClipboard,$pParent);

    if (Interjection($pConj->{'ordorig'},'') eq '') {

      $pConj->{'ordorig'} = Parent($pConj)->{'ord'};
    }

    $NodeClipboard=CutNode($pConj);

    $pD1 = PasteNode($NodeClipboard,$pD);

    $pAct = $pParent;
  }

  goto PruchodStromemDoHloubky;

}


sub Parentheses {

}


sub Quot {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pLQuot;			# used as type "pointer"
  my $pRQuot;			# used as type "pointer"
  my $pLook;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $i;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'form'},'\"') eq '\"') {

    if (Interjection($pAct->{'reserve2'},'SOLVED') ne 'SOLVED') {

      $i = "0";

      $pLQuot = $pAct;

      $pLQuot->{'TR'} = 'hide';

      $pRQuot = undef;

      $pLook = $pLQuot;
    FindRight:
      if (RBrother($pLook)) {

	$pLook = RBrother($pLook);

	$i = $i+"1";

	if (Interjection($pLook->{'form'},'\"') eq '\"') {

	  $pRQuot = $pLook;

	  $pRQuot->{'reserve2'} = 'SOLVED';

	  $pRQuot->{'TR'} = 'hide';
	} else {

	  goto FindRight;
	}

      }

      if (!($pRQuot)) {

	Parent($pLQuot)->{'dsp'} = 'DSPP';
      } else {

	if ($i eq "2") {

	  RBrother($pLQuot)->{'quoted'} = 'QUOT';
	} else {

	  Parent($pLQuot)->{'dsp'} = 'DSP';
	}

      }

    }
  }

  goto PruchodStromemDoHloubky;

}


sub HideSubtree {
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;

  $pT = $this;

  if (Interjection($pT->{'TR'},'hide') eq 'hide') {

    $pT->{'TR'} = '';
  } else {

    $pT->{'TR'} = 'hide';
  }


}


sub JoinSubtree {
  my $pAct;			# used as type "pointer"
  my $pSubtree;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pTatka;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sJLema;			# used as type "string"
  my $sActLema;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  $pSubtree = $pAct;

  $sJLema = ValNo(0,Parent($pAct)->{'trlemma'});

  $sActLema = ValNo(0,$pAct->{'trlemma'});

  $sJLema = (ValNo(0,$sJLema).ValNo(0,'_'));

  $sJLema = (ValNo(0,$sJLema).ValNo(0,$sActLema));

  $pCut = FirstSon($pAct);

  $pTatka = Parent($pAct);
 CutAllSubtrees:
  if ($pCut) {

    if (Interjection($pCut->{'ordorig'},'') eq '') {

      $pCut->{'ordorig'} = Parent($pCut)->{'ord'};
    }

    $NodeClipboard=CutNode($pCut);

    $pD = PasteNode($NodeClipboard,$pTatka);

    $pCut = FirstSon($pAct);

    goto CutAllSubtrees;
  }

  $pAct->{'TR'} = 'hide';

  $pAct = Parent($pAct);

  if ($sPar1 eq "1") {

    $pAct->{'trlemma'} = $sJLema;

    $sPar1 = "0";
  }

  if ($sPar1 eq "0") {
  }

  $this = $pAct;

}


sub joinfw {
  my $pAct;			# used as type "pointer"
  my $pParentW;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  if (!(FirstSon($pAct))) {

    $pAct->{'TR'} = 'hide';

    $pParentW = Parent($pAct);

    $pParentW->{'fw'} = $pAct->{'trlemma'};
  }

}


sub splitfw {
  my $pAct;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $sWLemma;			# used as type "string"
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  $sWLemma = ValNo(0,$pAct->{'fw'});

  if ($sWLemma eq '') {

    return;
  }

  $pSon = FirstSon($pAct);
 AllSons:
  if (Interjection($pSon->{'trlemma'},$sWLemma) eq $sWLemma) {

    $pSon->{'TR'} = '';

    $pAct->{'fw'} = '';
  } else {

    $pSon = RBrother($pSon);

    if ($pSon) {

      goto AllSons;
    }
  }


}


sub FillEmpty {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $pCand1;			# used as type "pointer"
  my $pCand2;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sTRlemma;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sCandTag;			# used as type "string"
  my $sCandTagBeg;		# used as type "string"
  my $sEval;			# used as type "string"
  my $sOrd1;			# used as type "string"
  my $sOrd2;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;

  $pRoot->{'func'} = 'SENT';
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  if (Interjection($pAct->{'afun'},'AuxR') eq 'AuxR') {

    $pAct->{'trlemma'} = 'Gen';

    $pAct->{'func'} = 'ACT';
  }

  if (Interjection($pAct->{'afun'},'AuxK') eq 'AuxK') {

    $pAct->{'TR'} = 'hide';
  }

  if (Interjection($pAct->{'afun'},'AuxG') eq 'AuxG') {

    $pAct->{'TR'} = 'hide';
  }

  if (Interjection($pAct->{'form'},',') eq ',' &&
      Interjection($pAct->{'TR'},'hide') ne 'hide') {

    $pAct->{'trlemma'} = 'Comma';

    if (!(FirstSon($pAct))) {

      $sEval = ValNo(0,$pAct->{'ord'})-"1";

      $pCand1 = Parent($pAct);

      $sOrd1 = ValNo(0,$pCand1->{'ord'});

      $pCand2 = LBrother($pAct);

      if ($pCand2) {

	$sOrd2 = ValNo(0,$pCand2->{'ord'});
      }

      if ($sOrd1 eq $sEval) {

	$sCandTag = ValNo(0,$pCand1->{'tag'});
      }

      if ($sOrd2 eq $sEval) {

	$sCandTag = ValNo(0,$pCand2->{'tag'});
      }

      $sCandTagBeg = substr($sCandTag,0,1);

      if ($sCandTagBeg ne 'N') {

	$pAct->{'TR'} = 'hide';
      }
    }
  }

  $sTRlemma = ValNo(0,$pAct->{'trlemma'});

  if (Interjection($pAct->{'func'},'') eq '') {

    $pAct->{'func'} = '???';
  }

  if (Interjection($pAct->{'gender'},'') eq '') {

    $pAct->{'gender'} = '???';
  }

  $pAct->{'tfa'} = 'T';

  goto PruchodStromemDoHloubky;

}


sub GetNewOrd {
  my $pNext;			# used as type "pointer"
  my $sOrdnum;			# used as type "string"
  my $sOrdB;			# used as type "string"
  my $sBaseA;			# used as type "string"
  my $sSufA;			# used as type "string"
  my $sBaseB;			# used as type "string"
  my $sSufB;			# used as type "string"
  my $sChar;			# used as type "string"
  my $i;			# used as type "string"
  my $sBase;			# used as type "string"
  my $sSuf;			# used as type "string"

  $pPar1->{'reserve2'} = 'Par1';

  $sBaseA = '';

  $sBaseB = '';

  $sSufA = '';

  $sSufB = '';

  $sOrdnum = ValNo(0,$pPar1->{'ord'});

  if (!($pPar2)) {

    $sBaseB = "999";

    $sSufB = "9";
  } else {

    $sOrdB = ValNo(0,$pPar2->{'ord'});

    $sBase = "0";

    $sSuf = "0";

    $i = "0";
  GNBLoopCont1:
    $sChar = substr($sOrdB,$i,1);

    if ($sChar eq '') {

      $sBaseB = $sOrdB;

      $sSufB = '';

      goto GNBLoopEnd1;
    }

    if ($sChar eq '.') {

      $sBaseB = substr($sOrdB,0,$i);

      $i = $i+"1";

      $sSufB = substr($sOrdB,$i,10);

      goto GNBLoopEnd1;
    }

    $i = $i+"1";

    goto GNBLoopCont1;
  }

 GNBLoopEnd1:
  $i = "0";
 GNOLoopCont1:
  $sChar = substr($sOrdnum,$i,1);

  if ($sChar eq '') {

    $sBaseA = $sOrdnum;

    $sSufA = '';

    goto GNOLoopEnd1;
  }

  if ($sChar eq '.') {

    $sBaseA = substr($sOrdnum,0,$i);

    $i = $i+"1";

    $sSufA = substr($sOrdnum,$i,10);

    goto GNOLoopEnd1;
  }

  $i = $i+"1";

  goto GNOLoopCont1;
 GNOLoopEnd1:
  if ($sSufB eq '') {

    $sSufB = "9";
  }

  if ($sSufA eq '') {

    $sSufA = "0";
  }

  if ($sBaseA<$sBaseB) {

    $sBase = $sBaseA;

    if ($sSufA eq "9") {

      $sBase = $sBase+"1";

      $sSuf = "1";
    } else {

      $sSuf = $sSufA+"1";
    }

  }

  if ($sBaseA>$sBaseB) {

    $sBase = $sBaseB;

    $sSuf = $sSufB-"1";

    if ($sBase==$sBaseA &&
	$sSuf==$sSufA) {

      $sSuf = $sSuf-"1";
    }

    if ($sSuf<"1") {

      $sSuf = (ValNo(0,$sSufA).ValNo(0,"5"));
    }
  } else {

    $sBase = $sBaseA;

    $sSuf = $sSufB-"1";

    if ($sBase==$sBaseA &&
	$sSuf==$sSufA) {

      $sSuf = $sSuf-"1";
    }

    if ($sSuf<"1") {

      $sSufA = $sSufA+"1";

      $sSuf = (ValNo(0,$sSufA).ValNo(0,"5"));
    }
  }


  $sPar2 = (ValNo(0,$sBase).ValNo(0,'.'));

  $sPar2 = (ValNo(0,$sPar2).ValNo(0,$sSuf));

}


sub NewSubject {
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pNew;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pPredch;			# used as type "pointer"
  my $sPoradi;			# used as type "string"
  my $sDord;			# used as type "string"

  UnGap();

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pT = $this;

  $pPar1 = $pT;

  $pPar2 = FirstSon($pT);

  if (!($pPar2)) {

    if (RBrother($pT)) {

      $pPar2 = RBrother($pT);
    }
  }

  GetNewOrd();

  $sPoradi = $sPar2;

  if (FirstSon($pT)) {

    $sDord = ValNo(0,FirstSon($pT)->{'dord'});
  } else {

    $sDord = ValNo(0,$pT->{'dord'});
  }


  $pNew =   PlainNewSon($pT);

  $pNew->{'lemma'} = '---';

  $pNew->{'tag'} = 'NA';

  $pNew->{'form'} = '---';

  $pNew->{'afun'} = '---';

  $pNew->{'ID1'} = '???';

  $pNew->{'ID2'} = '???';

  $pNew->{'origf'} = '---';

  $pNew->{'origap'} = '???';

  $pNew->{'gap1'} = '';

  $pNew->{'gap2'} = '';

  $pNew->{'gap3'} = '';

  $pPredch = FirstSon($pT);

  $pNew->{'ord'} = $sPoradi;

  $pNew->{'ordtf'} = '???';

  $pNew->{'afunprev'} = '---';

  $pNew->{'TR'} = '???';

  $pNew->{'warning'} = '???';

  $pNew->{'err1'} = '???';

  $pNew->{'err2'} = '???';

  $pNew->{'semPOS'} = '???';

  $pNew->{'tagauto'} = '???';

  $pNew->{'lemauto'} = '???';

  $pNew->{'ordorig'} = '???';

  $pNew->{'trlemma'} = $sPar1;

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

  $pNew->{'func'} = 'ACT';

  $pNew->{'gram'} = '???';

  $pNew->{'reltype'} = '???';

  $pNew->{'fw'} = '???';

  $pNew->{'phraseme'} = '???';

  $pNew->{'del'} = 'ELID';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'coref'} = '???';

  $pNew->{'cornum'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'dord'} = "-1";

  $sPar1 = $sDord;

  $sPar2 = "1";

  ShiftDords();

  $pNew->{'dord'} = $sDord;

  $pNew->{'sentord'} = "999";

  $pNew->{'reserve1'} = '???';

  $pNew->{'reserve2'} = '???';

  $NodeClipboard=CutNode($pNew);

  $pD = PasteNode($NodeClipboard,$pT);

}


sub NewSon {
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pNew;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sNum;			# used as type "string"
  my $sDord;			# used as type "string"

  $pT = $pPar1;

  UnGap();

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pPar2 = FirstSon($pT);

  if (!($pPar2)) {

    if (RBrother($pT)) {

      $pPar2 = RBrother($pT);
    }
  }

  GetNewOrd();

  $sNum = $sPar2;

  if (FirstSon($pT)) {

    $sDord = ValNo(0,FirstSon($pT)->{'dord'});
  } else {

    $sDord = ValNo(0,$pT->{'dord'});
  }


  $sPar1 = $sDord;

  $sPar2 = "1";

  ShiftDords();

  $pNew =   PlainNewSon($pT);

  $pNew->{'lemma'} = '---';

  $pNew->{'tag'} = '???';

  $pNew->{'form'} = '---';

  $pNew->{'afun'} = '---';

  $pNew->{'ID1'} = '???';

  $pNew->{'ID2'} = '???';

  $pNew->{'origf'} = '---';

  $pNew->{'origap'} = '???';

  $pNew->{'gap1'} = '';

  $pNew->{'gap2'} = '';

  $pNew->{'gap3'} = '';

  $pNew->{'dord'} = $sDord;

  $pNew->{'sentord'} = "999";

  $pNew->{'ord'} = $sNum;

  $pNew->{'ordtf'} = '???';

  $pNew->{'afunprev'} = '---';

  $pNew->{'TR'} = '???';

  $pNew->{'warning'} = '???';

  $pNew->{'err1'} = '???';

  $pNew->{'err2'} = '???';

  $pNew->{'semPOS'} = '???';

  $pNew->{'tagauto'} = '???';

  $pNew->{'lemauto'} = '???';

  $pNew->{'ordorig'} = '???';

  $pNew->{'trlemma'} = '???';

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

  $pNew->{'reltype'} = '???';

  $pNew->{'fw'} = '???';

  $pNew->{'phraseme'} = '???';

  $pNew->{'del'} = 'ELID';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'coref'} = '???';

  $pNew->{'cornum'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'reserve1'} = '???';

  $pNew->{'reserve2'} = '???';

  $NodeClipboard=CutNode($pNew);

  $pD = PasteNode($NodeClipboard,$pT);

  $pReturn = $pD;

}


sub NewVerb {
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pTatka;			# used as type "pointer"
  my $pNew;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sNum;			# used as type "string"
  my $sDord;			# used as type "string"

  UnGap();

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pT = $this;

  $pPar1 = $pT;

  $pPar2 = FirstSon($pT);

  if (!($pPar2)) {

    if (RBrother($pT)) {

      $pPar2 = RBrother($pT);
    }
  }

  GetNewOrd();

  $sNum = $sPar2;

  if (FirstSon($pT)) {

    $sDord = ValNo(0,FirstSon($pT)->{'dord'});
  } else {

    $sDord = ValNo(0,$pT->{'dord'});
  }


  $pNew =   PlainNewSon($pT);

  $pNew->{'lemma'} = '---';

  $pNew->{'tag'} = '---';

  $pNew->{'form'} = '---';

  $pNew->{'afun'} = '---';

  $pNew->{'ID1'} = '???';

  $pNew->{'ID2'} = '???';

  $pNew->{'origf'} = '---';

  $pNew->{'origap'} = '???';

  $pNew->{'gap1'} = '';

  $pNew->{'gap2'} = '';

  $pNew->{'gap3'} = 's';

  $pNew->{'ord'} = $sNum;

  $pNew->{'ordtf'} = '???';

  $pNew->{'afunprev'} = '---';

  $pNew->{'TR'} = '???';

  $pNew->{'warning'} = '???';

  $pNew->{'err1'} = '???';

  $pNew->{'err2'} = '???';

  $pNew->{'semPOS'} = '???';

  $pNew->{'tagauto'} = '???';

  $pNew->{'lemauto'} = '???';

  $pNew->{'ordorig'} = '???';

  $pNew->{'trlemma'} = 'Emp';

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

  $pNew->{'func'} = 'EV';

  $pNew->{'gram'} = '???';

  $pNew->{'reltype'} = '???';

  $pNew->{'fw'} = '???';

  $pNew->{'phraseme'} = '???';

  $pNew->{'del'} = 'ELID';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'coref'} = '???';

  $pNew->{'cornum'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'dord'} = "-1";

  $sPar1 = $sDord;

  $sPar2 = "1";

  ShiftDords();

  $pNew->{'dord'} = $sDord;

  $pNew->{'sentord'} = FirstSon($pT)->{'dord'};

  $pNew->{'reserve1'} = '???';

  $pNew->{'reserve2'} = '???';

  $NodeClipboard=CutNode($pNew);

  $pTatka = PasteNode($NodeClipboard,$pT);

  $pCut = RBrother($pTatka);
 CutAllSubtrees:
  if ($pCut) {

    if (Interjection($pCut->{'afun'},'ExD') eq 'ExD') {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,$pTatka);
    }

    $pCut = RBrother($pTatka);

    goto CutAllSubtrees;
  }

}


#bind _key_Ctrl_Shift_F3 to Ctrl+Shift+F3
sub _key_Ctrl_Shift_F3 {

  TRLemaForm();

}


sub TRLemaForm {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pVerb;			# used as type "pointer"
  my $sAfun;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $pAct->{'sentord'} = $pAct->{'dord'};

  goto PruchodStromemDoHloubky;

}


sub trtolemma {
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') eq 'TR_TREE') {

    return;
  }

  $pAct->{'trlemma'} = $pAct->{'lemma'};

}


sub SignatureAssign {
  my $pT;			# used as type "pointer"
 SignatureNext:
  ThisRoot();

  $pT = $pReturn;

  if (Interjection($pT->{'TR'},'') eq '') {

    $pT->{'TR'} = $sPar1;
  }

  NextTree();

  if ($_NoSuchTree=="1") {

    goto SignatureExit;
  } else {

    goto SignatureNext;
  }

 SignatureExit:
  GotoTree(1);

  return;

}


sub MaxDord {
  my $pAct;			# used as type "pointer"

  $sReturn = "0";

  $pAct = $pPar1;

  $pPar2 = $pPar1;
 loop:
  if ($sReturn<ValNo(0,$pAct->{'dord'})) {

    $sReturn = ValNo(0,$pAct->{'dord'});
  }

  $pPar1 = $pAct;

  GoNext();

  $pAct = $pReturn;

  if ($pAct) {

    goto loop;
  }

}


sub ShiftDordsButFirst {
  my $pAct;			# used as type "pointer"
  my $one;			# used as type "string"

  $one = "0";

  ThisRoot();

  $pAct = $pReturn;

  $pPar2 = undef;
 loopShiftDord:
  if (ValNo(0,$pAct->{'dord'})>$sPar1 ||
      ( ValNo(0,$pAct->{'dord'})==$sPar1 &&
	$one=="1" )) {

    $pAct->{'dord'} = ValNo(0,$pAct->{'dord'})+$sPar2;
  } else {

    if (ValNo(0,$pAct->{'dord'})==$sPar1) {

      $one = "1";
    }
  }


  $pPar1 = $pAct;

  GoNext();

  $pAct = $pReturn;

  if ($pAct) {

    goto loopShiftDord;
  }

}


sub ShiftDords {
  my $pAct;			# used as type "pointer"

  ThisRoot();

  $pAct = $pReturn;

  $pPar2 = undef;
 loopShiftDord:
  if (ValNo(0,$pAct->{'dord'})>=$sPar1) {

    $pAct->{'dord'} = ValNo(0,$pAct->{'dord'})+$sPar2;
  }

  $pPar1 = $pAct;

  GoNext();

  $pAct = $pReturn;

  if ($pAct) {

    goto loopShiftDord;
  }

}


sub ShiftFirst {
  my $pAct;			# used as type "pointer"

  ThisRoot();

  $pAct = $pReturn;

  $pPar2 = undef;
 loopShiftDord:
  if (ValNo(0,$pAct->{'dord'})==$sPar1) {

    $pAct->{'dord'} = ValNo(0,$pAct->{'dord'})+$sPar2;

    return;
  }

  $pPar1 = $pAct;

  GoNext();

  $pAct = $pReturn;

  if ($pAct) {

    goto loopShiftDord;
  }

}


sub MoveNode {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sOrdNum;			# used as type "string"
  my $sMaxDord;			# used as type "string"
  my $pRoot;			# used as type "pointer"
  my $sDir;			# used as type "string"

  $sDir = $sPar1;

  UnGap();

  ThisRoot();

  $pRoot = $pReturn;

  $pPar1 = $pRoot;

  $pPar2 = undef;

  MaxDord();

  $sMaxDord = $sReturn;

  $pAct = $this;

  $pParent = Parent($pAct);

  $sOrdNum = ValNo(0,$pAct->{'dord'});

  if ($sOrdNum=="0") {

    return;
  }

  if ($sDir eq 'L') {

    $sOrdNum = $sOrdNum-"1";

    if ($sOrdNum<"1") {

      return;
    }

    $sPar2 = "1";
  } else {

    if ($sDir eq 'R') {

      $sOrdNum = $sOrdNum+"1";

      if ($sOrdNum>$sMaxDord) {

	return;
      }

      $sPar2 = "-1";
    } else {

      return;
    }

  }


  $sPar1 = $sOrdNum;

  ShiftFirst();

  $pAct->{'dord'} = $sOrdNum;

  $NodeClipboard=CutNode($pAct);

  $this = PasteNode($NodeClipboard,$pParent);

}


#bind _key_Ctrl_Shift_D to Ctrl+Shift+D menu Smaze aktualni uzel, pokud nema deti.
sub _key_Ctrl_Shift_D {

  DeleteCurrentNode();

}


sub DeleteCurrentNode {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sDord;			# used as type "string"

  $pAct = $this;

  $pParent = Parent($pAct);

  UnGap();

  if (FirstSon($pAct)) {

    return;
  }

  $sDord = ValNo(0,$pAct->{'dord'});

  $NodeClipboard=CutNode($pAct);

  $sPar1 = $sDord;

  $sPar2 = "-1";

  ShiftDords();

  $this = $pParent;

}


#bind _key_Ctrl_Shift_I to Ctrl+Shift+I menu Cut a paste na vsechny uzly podle struktury. (Treba spustit vicekrat).
sub _key_Ctrl_Shift_I {

  CutPasteAll();

}


sub CutPasteAll {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"

  ThisRoot();

  $pAct = FirstSon($pReturn);

  $pPar2 = undef;
 forallnodes:
  if ($pAct) {

    $pParent = Parent($pAct);

    $NodeClipboard=CutNode($pAct);

    $pAct = PasteNode($NodeClipboard,$pParent);

    $pPar1 = $pAct;

    GoNext();

    $pAct = $pReturn;

    goto forallnodes;
  }

}


#bind _key_Ctrl_Shift_G to Ctrl+Shift+G menu Testuje poradi uzlu (dord) a rusi mezery v cislovani
sub _key_Ctrl_Shift_G {

  UnGap();

}


sub UnGap {
  my $pAct;			# used as type "pointer"
  my $lDords;			# used as type "list"
  my $lEmpty;			# used as type "list"
  my $sMaxDord;			# used as type "string"
  my $sShift;			# used as type "string"

  $sShift = "0";

  $sMaxDord = "0";

  ThisRoot();

  $pAct = $pReturn;

  $lDords = Interjection('q','a');

  $lEmpty = $lDords;
 forallnodes:
  if ($pAct) {

    if (ListEq(Union($lDords,$pAct->{'dord'}),$lDords)) {

      $sShift = 'Chyba v dord';

      return;
    } else {

      $lDords = Union($lDords,$pAct->{'dord'});

      if ($sMaxDord<ValNo(0,$pAct->{'dord'})) {

	$sMaxDord = ValNo(0,$pAct->{'dord'});
      }
    }


    $pPar1 = $pAct;

    GoNext();

    $pAct = $pReturn;

    goto forallnodes;
  }
 foralldords:
  if ($sMaxDord>"0") {

    $sMaxDord = $sMaxDord-"1";

    if (ListEq(Union($lDords,$sMaxDord),$lDords)) {

      if ($sShift!="0") {

	$sPar1 = $sMaxDord+"1";

	$sPar2 = $sShift;

	ShiftDords();

	$sShift = "0";
      }
    } else {

      $sShift = $sShift-"1";

      PrintToFile('c:\\log', map { ValNo(0,$_) } ($sMaxDord, '\n'));
    }


    goto foralldords;
  }

  if ($sShift ne "0") {

    $sPar1 = $sMaxDord+"1";

    $sPar2 = $sShift;

    ShiftDords();
  }

}


sub OpravBlb {
  my $pRoot;			# used as type "pointer"

  ThisRoot();

  $pRoot = $pReturn;
 AAALoopCont1:
  $pPar1 = $pRoot;

  Oprava1();

  NextTree();

  if ($_NoSuchTree=="1") {

    goto AAALoopExit1;
  }

  $pRoot = $this;

  goto AAALoopCont1;
 AAALoopExit1:
  GotoTree(1);

  return;

}


sub Oprava {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sAdj;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sAdj = substr($sTag,0,1);

  if (Interjection($pAct->{'lemma'},'') eq '') {

    $pAct->{'lemma'} = '???';
  }

  if (Interjection($pAct->{'tag'},'') eq '') {

    $pAct->{'tag'} = 'NA';
  }

  if (Interjection($pAct->{'form'},'') eq '') {

    $pAct->{'form'} = 'EV';
  }

  if (Interjection($pAct->{'afun'},'') eq '') {

    $pAct->{'afun'} = '???';
  }

  if (Interjection($pAct->{'ID1'},'') eq '') {

    $pAct->{'ID1'} = '???';
  }

  if (Interjection($pAct->{'ID2'},'') eq '') {

    $pAct->{'ID2'} = '???';
  }

  if (Interjection($pAct->{'origf'},'') eq '') {

    $pAct->{'origf'} = '???';
  }

  if (Interjection($pAct->{'origap'},'???') eq '???') {

    $pAct->{'origap'} = '';
  }

  if (Interjection($pAct->{'gap1'},'???') eq '???') {

    $pAct->{'gap1'} = '';
  }

  if (Interjection($pAct->{'gap2'},'???') eq '???') {

    $pAct->{'gap2'} = '';
  }

  if (Interjection($pAct->{'gap3'},'???') eq '???') {

    $pAct->{'gap3'} = '';
  }

  if (Interjection($pAct->{'ordtf'},'') eq '') {

    $pAct->{'ordtf'} = '???';
  }

  if (Interjection($pAct->{'afunprev'},'') eq '') {

    $pAct->{'afunprev'} = '???';
  }

  if (Interjection($pAct->{'ordorig'},'???') eq '???') {

    $pAct->{'ordorig'} = '';
  }

  if ($sAdj eq 'A') {

    if (Interjection($pAct->{'gender'},'???') eq '???') {

      $pAct->{'gender'} = 'NA';
    }

    if (Interjection($pAct->{'number'},'???') eq '???') {

      $pAct->{'number'} = 'NA';
    }

    if (Interjection($pAct->{'degcmp'},'???') eq '???') {

      $pAct->{'degcmp'} = 'POS';
    }
  }

  if ($sAdj eq 'D') {

    if (Interjection($pAct->{'degcmp'},'???') eq '???') {

      $pAct->{'degcmp'} = 'NA';
    }
  }

  if (Interjection($pAct->{'reltype'},'') eq '' ||
      Interjection($pAct->{'reltype'},'???') eq '???') {

    $pAct->{'reltype'} = 'NIL';
  }

  if (Interjection($pAct->{'del'},'') eq '' ||
      Interjection($pAct->{'del'},'???') eq '???') {

    $pAct->{'del'} = 'NIL';
  }

  if (Interjection($pAct->{'quoted'},'') eq '' ||
      Interjection($pAct->{'quoted'},'???') eq '???') {

    $pAct->{'quoted'} = 'NIL';
  }

  if (Interjection($pAct->{'dsp'},'') eq '' ||
      Interjection($pAct->{'dsp'},'???') eq '???') {

    $pAct->{'dsp'} = 'NIL';
  }

  if (Interjection($pAct->{'degcmp'},'') eq '' ||
      Interjection($pAct->{'degcmp'},'???') eq '???') {

    $pAct->{'degcmp'} = 'NA';
  }

  if (Interjection($pAct->{'tense'},'') eq '') {

    $pAct->{'tense'} = 'NA';
  }

  if (Interjection($pAct->{'aspect'},'') eq '') {

    $pAct->{'aspect'} = 'NA';
  }

  if (Interjection($pAct->{'iterativeness'},'') eq '') {

    $pAct->{'iterativeness'} = 'NA';
  }

  if (Interjection($pAct->{'verbmod'},'') eq '') {

    $pAct->{'verbmod'} = 'NA';
  }

  if (Interjection($pAct->{'deontmod'},'') eq '') {

    $pAct->{'deontmod'} = 'NA';
  }

  if (Interjection($pAct->{'sentmod'},'') eq '') {

    $pAct->{'sentmod'} = 'NA';
  }

  if (Interjection($pAct->{'func'},'ACT') eq 'ACT' ||
      Interjection($pAct->{'func'},'PAT') eq 'PAT') {

    if (Interjection($pAct->{'gram'},'???') eq '???') {

      $pAct->{'gram'} = 'NIL';
    }
  } else {

    if (Interjection($pAct->{'gram'},'???') eq '???') {

      $pAct->{'gram'} = 'NA';
    }
  }


  if (Interjection($pAct->{'gram'},'') eq '' ||
      Interjection($pAct->{'gram'},'???') eq '???') {

    $pAct->{'gram'} = 'NA';
  }

  $pNext = FirstSon($pAct);

  goto PruchodStromemDoHloubky;

}


sub Oprava1 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sAdj;			# used as type "string"

  ThisRoot();

  $pRoot = $pReturn;

  $pAct = $pRoot;
 PruchodStromemDoHloubky:
  $pNext = FirstSon($pAct);

  if (!($pNext)) {

    $pNext = RBrother($pAct);
  }
 LevelUp:
  if (!($pNext)) {

    $pNext = Parent($pAct);

    if (!($pNext)) {

      return;
    } else {

      $pAct = $pNext;

      $pNext = RBrother($pNext);

      goto LevelUp;
    }

  }

  $pAct = $pNext;

  $sTag = ValNo(0,$pAct->{'tag'});

  $sAdj = substr($sTag,0,1);

  $pAct->{'gram'} = '';

  $pAct->{'corsnt'} = '';

  $pAct->{'antec'} = '';

  $pAct->{'cornum'} = '';

  $pAct->{'phraseme'} = '';

  $pNext = FirstSon($pAct);

  goto PruchodStromemDoHloubky;

}
