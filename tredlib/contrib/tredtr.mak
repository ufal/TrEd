# Automatically converted from Graph macros by graph2tred to Perl.         -*-cperl-*-.

#encoding iso-8859-2

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
my $sPasteNow;			# used as type "string"
my $lPar1;			# used as type "list"
my $lPar2;			# used as type "list"
my $lPar3;			# used as type "list"
my $lReturn;			# used as type "list"


sub comments {

}
my $_pDummy;			# used as type "pointer"


sub ThisRoot {
  my ($pT, $pPrev);		# used as type "pointer"

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


sub TagPrune {
  my $lT;			# used as type "list"
  my $lTRet;			# used as type "list"
  my $sT;			# used as type "string"
  my $sT1;			# used as type "string"
  my $i;			# used as type "string"
  my $iLast;			# used as type "string"

  $lT = $lPar1;

  $sT1 = ValNo(0,$lT);

  $i = "0";

  $lTRet = Interjection('q','a');

  $iLast = scalar(split /\|/,$lT);
 TagPruneCont:
  if ($i>=$iLast) {

    goto TagPruneEnd;
  }

  $sT =  ValNo($i,$lT) ;

  if (substr($sT,0,1) ne '-') {

    $sT1 = $sT;

    if (substr($sT,0,2) ne 'VM') {

      $lTRet = Union($lTRet,$sT);
    }
  }

  $i = $i+"1";

  goto TagPruneCont;
 TagPruneEnd:
  if (ListEq($lTRet,Interjection('q','a'))) {

    $lTRet = $sT1;
  }

  $lReturn = $lTRet;

}


sub GetAfunSuffix {
  my $sChar;			# used as type "string"
  my $i;			# used as type "string"

  $i = "0";
 GASLoopCont1:
  $sChar = substr($sPar1,$i,1);

  if ($sChar eq '') {

    $sPar2 = $sPar1;

    $sPar3 = '';

    goto GASLoopEnd1;
  }

  if ($sChar eq '_' ||
      $sChar eq '-' ||
      $sChar eq '`' ||
      $sChar eq '&') {

    $sPar2 = substr($sPar1,0,$i);

    $sPar3 = substr($sPar1,$i,40);

    goto GASLoopEnd1;
  }

  $i = $i+"1";

  goto GASLoopCont1;
 GASLoopEnd1:
  return;

}


sub SubtreeAfunAssign {
  my $pAct;			# used as type "pointer"
  my $pParAct;			# used as type "pointer"
  my $pParParAct;		# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pThis;			# used as type "pointer"
  my $fSubject;			# used as type "string"
  my $fObject;			# used as type "string"
  my $sT;			# used as type "string"
  my $sT1;			# used as type "string"
  my $sLemmaFull;		# used as type "string"
  my $sLemma;			# used as type "string"
  my $sParTag;			# used as type "string"
  my $sParParTag;		# used as type "string"
  my $sParLemma;		# used as type "string"
  my $sParParLemma;		# used as type "string"
  my $sPOS;			# used as type "string"
  my $sParPOS;			# used as type "string"
  my $sParParPOS;		# used as type "string"
  my $lT;			# used as type "list"
  my $lafun;			# used as type "list"
  my $lTag;			# used as type "list"
  my $lLemma;			# used as type "list"
  my $lForm;			# used as type "list"
  my $lParTag;			# used as type "list"
  my $sTag;			# used as type "string"
  my $fObj;			# used as type "string"
  my $i;			# used as type "string"
  my $iLast;			# used as type "string"
  my $sCo;			# used as type "string"
  my $sAp;			# used as type "string"
  my $sSuffAct;			# used as type "string"
  my $sParAfun;			# used as type "string"
  my $sParParAfun;		# used as type "string"
  my $sAfun;			# used as type "string"
  my $pTmp;			# used as type "pointer"
  my $cList;			# used as type "string"
  my $lPar;			# used as type "list"
  my $sPar;			# used as type "string"
  my $Return;			# used as type "string"
  my $fReturn;			# used as type "string"

  $pThis = $pPar1;

  $sCo = '_Co';

  $sAp = '_Ap';

  $pParent = $pThis;

  if (!(Parent($pThis))) {

    $pAct = FirstSon($pThis);
  } else {

    $pAct = $pThis;
  }


  if (!($pAct)) {

    return;
  }
 ContLoop1:
  if (Interjection($pAct->{'afun'},'???') ne '???') {

    if (Interjection($pAct->{'form'},'se') ne 'se') {

      goto ex;
    }
  }

  $sSuffAct = '';

  $lafun = $pAct->{'afun'};

  $lLemma = $pAct->{'lemma'};

  $sLemmaFull = ValNo(0,$lLemma);

  $i = "0";

  $sT = substr($sLemmaFull,$i,1);
 ContLoop4:
  if ($sT eq '' ||
      $sT eq '_') {

    goto ExitLoop4;
  }

  $i = $i+"1";

  $sT = substr($sLemmaFull,$i,1);

  goto ContLoop4;
 ExitLoop4:
  $sLemma = substr($sLemmaFull,0,$i);

  $lPar1 = $pAct->{'tag'};

  TagPrune();

  $lTag = $lReturn;

  $lForm = $pAct->{'form'};

  $sTag = ValNo(0,$lTag);

  if ($sTag eq 'NOMORPH') {

    $lTag = 'NFXXA';

    $sTag = 'NFXXA';
  }

  $sPOS = substr($sTag,0,1);

  $pParAct = Parent($pAct);
 GoUp:
  $lPar1 = $pParAct->{'tag'};

  TagPrune();

  $lParTag = $lReturn;

  $sParTag = ValNo(0,$lParTag);

  $sParPOS = substr($sParTag,0,1);

  $sLemmaFull = ValNo(0,$pParAct->{'lemma'});

  $sParAfun = ValNo(0,$pParAct->{'afun'});

  $i = "0";

  $sT = substr($sParAfun,$i,1);
 ContLoop5s:
  if ($sT eq '' ||
      $sT eq '_') {

    goto ExitLoop5s;
  }

  $i = $i+"1";

  $sT = substr($sParAfun,$i,1);

  goto ContLoop5s;
 ExitLoop5s:
  $sParAfun = substr($sParAfun,0,$i);

  if ($sParAfun eq 'Coord' ||
      $sParAfun eq 'Apos') {

    $pParAct = Parent($pParAct);

    if (!($pParAct)) {

      goto ex;
    }

    if ($sSuffAct eq '') {

      $sSuffAct = (ValNo(0,'_').ValNo(0,substr($sParAfun,0,2)));
    }

    goto GoUp;
  }

  if ($sLemmaFull eq '&percnt;') {

    $sParPOS = 'N';

    $lParTag = 'NNXXA';

    $sParTag = ValNo(0,$lParTag);
  }

  $i = "0";

  $sT = substr($sLemmaFull,$i,1);
 ContLoop5:
  if ($sT eq '' ||
      $sT eq '_') {

    goto ExitLoop5;
  }

  $i = $i+"1";

  $sT = substr($sLemmaFull,$i,1);

  goto ContLoop5;
 ExitLoop5:
  $sParLemma = substr($sLemmaFull,0,$i);

  $pParParAct = Parent($pParAct);
 GoUpPar2:
  if ($pParParAct) {

    $lPar1 = $pParParAct->{'tag'};

    TagPrune();

    $sParParTag = ValNo(0,$lReturn);

    $sParParPOS = substr($sParParTag,0,1);

    $sLemmaFull = ValNo(0,$pParParAct->{'lemma'});

    $sParParAfun = ValNo(0,$pParParAct->{'afun'});

    if ($sLemmaFull eq '&percnt;') {

      $sParParPOS = 'N';

      $sParParTag = 'NNXXA';
    }

    $i = "0";

    $sT = substr($sParParAfun,$i,1);
  ContLoop5ps:
    if ($sT eq '' ||
	$sT eq '_') {

      goto ExitLoop5ps;
    }

    $i = $i+"1";

    $sT = substr($sParParAfun,$i,1);

    goto ContLoop5ps;
  ExitLoop5ps:
    $sParParAfun = substr($sParParAfun,0,$i);

    if ($sParParAfun eq 'Coord' ||
	$sParParAfun eq 'Apos') {

      $pParParAct = Parent($pParParAct);

      if (!($pParParAct)) {

	$sParParTag = '';

	$sParParPOS = '';

	$sParParLemma = '';

	goto MakeSuff;
      }

      if (substr(ValNo(0,$pParAct->{'afun'}),0,3) eq 'Aux') {

	if ($sSuffAct eq '') {

	  $sSuffAct = (ValNo(0,'_').ValNo(0,substr($sParParAfun,0,2)));
	}
      }

      goto GoUpPar2;
    }

    $i = "0";

    $sT = substr($sLemmaFull,$i,1);
  ContLoop6:
    if ($sT eq '' ||
	$sT eq '_') {

      goto ExitLoop6;
    }

    $i = $i+"1";

    $sT = substr($sLemmaFull,$i,1);

    goto ContLoop6;
  ExitLoop6:
    $sParParLemma = substr($sLemmaFull,0,$i);
  } else {

    $sParParTag = '';

    $sParParPOS = '';

    $sParParLemma = '';
  }

 MakeSuff:
  $i = $i;
 StartWork:
  $pAct->{'afunprev'} = $pAct->{'afun'};

  if (Interjection($lForm,'mo¾ná') eq 'mo¾ná' ||
      Interjection($lForm,'prý') eq 'prý' ||
      Interjection($lForm,'zøejmì') eq 'zøejmì' ||
      Interjection($lForm,'patrnì') eq 'patrnì' ||
      Interjection($lForm,'ostatnì') eq 'ostatnì' ||
      Interjection($lForm,'toti¾') eq 'toti¾' ||
      Interjection($lForm,'vlastnì') eq 'vlastnì' ||
      Interjection($lForm,'pravdìpodobnì') eq 'pravdìpodobnì') {

    $pAct->{'afun'} = 'AuxY';

    goto ex;
  }

  if (Interjection($lForm,'jen') eq 'jen' ||
      Interjection($lForm,'dokonce') eq 'dokonce' ||
      Interjection($lForm,'pouze') eq 'pouze') {

    $pAct->{'afun'} = 'AuxZ';

    goto ex;
  }

  if (Interjection($lForm,'snad') eq 'snad') {

    $pAct->{'afun'} = Union('AuxY','AuxZ');

    goto ex;
  }

  if (Interjection($lForm,'vèetnì') eq 'vèetnì') {

    if (FirstSon($pAct)) {

      $sAfun = 'AuxP';

      goto aa;
    } else {

      $pAct->{'afun'} = 'Adv';

      goto ex;
    }

  }

  if (substr($sLemma,0,6) eq 'podle-') {

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'mezi') eq 'mezi' ||
      Interjection($lForm,'Mezi') eq 'Mezi' ||
      Interjection($lForm,'MEZI') eq 'MEZI') {

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'V') eq 'V' &&
      Interjection($pAct->{'ord'},"1") eq "1") {

    if (scalar(split /\|/,$lTag) ne "1") {

      $pAct->{'tag'} = Union('R4','R6');
    }

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'Od') eq 'Od') {

    if (scalar(split /\|/,$lTag) ne "1") {

      $pAct->{'tag'} = 'R2';
    }

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'kolem') eq 'kolem' ||
      Interjection($lForm,'Kolem') eq 'Kolem' ||
      Interjection($lForm,'KOLEM') eq 'KOLEM') {

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'pøi') eq 'pøi' ||
      Interjection($lForm,'Pøi') eq 'Pøi' ||
      Interjection($lForm,'PøI') eq 'PøI') {

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if (Interjection($lForm,'&percnt;') eq '&percnt;') {

    $sPOS = 'N';

    $lTag = 'NNXXA';

    $sTag = ValNo(0,$lTag);

    $sAfun = 'Atr';

    goto aa;
  }

  if (Interjection($lForm,'.') eq '.' ||
      Interjection($lForm,';') eq ';' ||
      Interjection($lForm,'!') eq '!' ||
      Interjection($lForm,'?') eq '?' ||
      Interjection($lForm,'-') eq '-' ||
      Interjection($lForm,':') eq ':' ||
      Interjection($lForm,')') eq ')' ||
      Interjection($lForm,'}') eq '}' ||
      Interjection($lForm,']') eq ']') {

    if (!(RBrother($pAct))) {

      if (Interjection($pParAct->{'afun'},'AuxS') eq 'AuxS') {

	$pAct->{'afun'} = 'AuxK';
      }
    }

    goto ex;
  }

  if ($sPOS eq 'R') {

    $pAct->{'afun'} = 'AuxP';
  }

  if ($sTag eq 'ABBRX') {

    $sPOS = 'N';

    $lTag = 'NNXXA';

    $sTag = ValNo(0,$lTag);
  }

  if (Interjection($pParAct->{'afun'},'AuxS') eq 'AuxS') {

    if ($sPOS eq 'V' ||
	Interjection($lLemma,'být') eq 'být' ||
	Interjection('mít',$lLemma) eq 'mít') {

      $sAfun = 'Pred';

      goto aa;
    }

    if ($sPOS eq 'N' ||
	$sPOS eq 'X') {

      $sAfun = 'ExD';

      goto aa;
    }
  }

  if (Interjection($lTag,'JE') eq 'JE') {

    if (FirstSon($pAct)) {

      $sAfun = 'Coord';

      goto aa;
    } else {

      $pAct->{'afun'} = 'AuxY';

      goto ex;
    }

  }

  if ($sPOS eq 'D') {

    if ($sParPOS ne 'N') {

      $sAfun = 'Adv';

      goto aa;
    } else {

      $pAct->{'afun'} = 'AuxZ';

      goto ex;
    }

  }

  if (Interjection($pAct->{'form'},'se') eq 'se') {

    if (!(FirstSon($pAct))) {

      $pAct->{'afun'} = 'AuxT';

      goto ex;
    } else {

      $pAct->{'afun'} = 'AuxP';

      goto ex;
    }

  }

  if ($sPOS eq 'R') {

    $pAct->{'afun'} = 'AuxP';

    goto ex;
  }

  if ($sLemma eq ',') {

    if (!(FirstSon($pAct))) {

      $pAct->{'afun'} = 'AuxX';

      goto ex;
    } else {

      $sAfun = 'Apos';

      goto aa;
    }

  }

  if (substr(ValNo(0,$pAct->{'gap1'}),0,3) eq '<d>' ||
      substr(ValNo(0,$pAct->{'gap1'}),0,10) eq '<D>&nl;<d>') {

    if (Interjection($pParAct->{'afun'},'AuxS') eq 'AuxS') {

      if (Interjection($pAct->{'form'},':') eq ':') {

	$pAct->{'afun'} = 'Pred';

	goto ex;
      } else {

	$pAct->{'afun'} = 'AuxK';

	goto ex;
      }

    } else {

      $pAct->{'afun'} = 'AuxG';

      goto ex;
    }

  }

  if (Interjection($lTag,'JS') eq 'JS') {

    if (FirstSon($pAct)) {

      $sAfun = 'AuxC';

      goto aa;
    } else {

      $pAct->{'afun'} = 'AuxY';

      goto ex;
    }

  }

  if ($sPOS eq 'A' ||
      $sPOS eq 'P') {

    if ($sParPOS eq 'N' &&
	Interjection($pParAct->{'afun'},'AuxP') ne 'AuxP') {

      $sAfun = 'Atr';

      goto aa;
    }

    if ($sPOS eq 'A' &&
	( $sParLemma eq 'být' ||
	  Interjection($pParAct->{'form'},'je') eq 'je' ||
	  Interjection($pParAct->{'form'},'Je') eq 'Je' ||
	  Interjection($pParAct->{'form'},'JE') eq 'JE' )) {

      $sAfun = 'Pnom';

      goto aa;
    }
  }

  if ($sPOS eq 'P' &&
      substr($sParTag,0,3) eq 'DG3') {

    $sAfun = 'Adv';

    goto aa;
  }

  $fSubject = "0";

  $fObject = "0";

  $pT = LBrother($pAct);
 ContLoop3:
  if (!($pT)) {

    goto ExitLoop3;
  }

  if (Interjection($pT->{'afun'},'Sb') eq 'Sb') {

    $fSubject = "1";
  }

  if (Interjection($pT->{'afun'},'Obj') eq 'Obj') {

    $fObject = "1";
  }

  $pT = LBrother($pT);

  goto ContLoop3;
 ExitLoop3:
  if ($sPOS eq 'N' ||
      $sPOS eq 'P' ||
      $sPOS eq 'C' ||
      Interjection($lTag,'ZNUM') eq 'ZNUM') {

    if (Interjection($pParAct->{'afun'},'AuxP') eq 'AuxP') {

      goto ParentPossiblyAux;
    }

    if ($sParPOS eq 'C' ||
	Interjection($lParTag,'ZNUM') eq 'ZNUM') {

      $sAfun = 'Atr';

      goto aa;
    }

    if ($sParPOS eq 'N') {

      $sAfun = 'Atr';

      goto aa;
    }

    if ($pParParAct) {

      if (Interjection($pParAct->{'afun'},'AuxP') eq 'AuxP' &&
	  $sParParPOS eq 'N') {

	$sAfun = 'Atr';

	goto aa;
      }
    }

    if (Interjection($pParAct->{'afun'},'Pred') eq 'Pred' ||
	$sParPOS eq 'V' ||
	$sParPOS eq 'A') {

      if (Interjection($lTag,'NFS1A') eq 'NFS1A' ||
	  Interjection($lTag,'NFP1A') eq 'NFP1A' ||
	  Interjection($lTag,'NIS1A') eq 'NIS1A' ||
	  Interjection($lTag,'NIP1A') eq 'NIP1A' ||
	  Interjection($lTag,'NMS1A') eq 'NMS1A' ||
	  Interjection($lTag,'NMP1A') eq 'NMP1A' ||
	  Interjection($lTag,'NNS1A') eq 'NNS1A' ||
	  Interjection($lTag,'NNP1A') eq 'NNP1A' ||
	  Interjection($lTag,'NFS1N') eq 'NFS1N' ||
	  Interjection($lTag,'NFP1N') eq 'NFP1N' ||
	  Interjection($lTag,'NIS1N') eq 'NIS1N' ||
	  Interjection($lTag,'NIP1N') eq 'NIP1N' ||
	  Interjection($lTag,'NMS1N') eq 'NMS1N' ||
	  Interjection($lTag,'NMP1N') eq 'NMP1N' ||
	  Interjection($lTag,'NNS1N') eq 'NNS1N' ||
	  Interjection($lTag,'NNP1N') eq 'NNP1N' ||
	  Interjection($lTag,'PDNS1') eq 'PDNS1' ||
	  Interjection($lTag,'PDNP1') eq 'PDNP1' ||
	  Interjection($lTag,'PDFS1') eq 'PDFS1' ||
	  Interjection($lTag,'PDFP1') eq 'PDFP1' ||
	  Interjection($lTag,'PDMS1') eq 'PDMS1' ||
	  Interjection($lTag,'PDMP1') eq 'PDMP1' ||
	  Interjection($lTag,'PDIS1') eq 'PDIS1' ||
	  Interjection($lTag,'PDIP1') eq 'PDIP1' ||
	  Interjection($lTag,'NFXXA') eq 'NFXXA' ||
	  Interjection($lTag,'NMXXA') eq 'NMXXA' ||
	  Interjection($lTag,'NIXXA') eq 'NIXXA' ||
	  Interjection($lTag,'NNXXA') eq 'NNXXA' ||
	  Interjection($lTag,'ZNUM') eq 'ZNUM') {

	if ($fSubject eq "0" &&
	    Interjection($pParAct->{'tag'},'VFA') ne 'VFA' &&
	    Interjection($pParAct->{'tag'},'VFN') ne 'VFN' &&
	    Interjection($pParAct->{'tag'},'VPP1A') ne 'VPP1A' &&
	    Interjection($pParAct->{'tag'},'VPP1N') ne 'VPP1N' &&
	    Interjection($pParAct->{'tag'},'VPS1A') ne 'VPS1A' &&
	    Interjection($pParAct->{'tag'},'VPS2N') ne 'VPS2N') {

	  $sAfun = 'Sb';

	  goto aa;
	} else {

	  goto TryObj;
	}

      }
    TryObj:
      $fObj = "0";

      if (substr($sParLemma,0,10) eq 'financovat') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,9) eq 'dosahovat') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'vybrat') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'èerpat') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'mít') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'chtít') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'muset') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'smìt') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'zaèít') {

	$fObj = "1";

	goto TDO;
      }

      if (substr($sParLemma,0,6) eq 'skonèit') {

	$fObj = "1";

	goto TDO;
      }
    TDO:
      if ($fObj eq "1") {

	$sAfun = 'Obj';

	goto aa;
      } else {

	if (Interjection($lTag,'NFS4A') eq 'NFS4A' ||
	    Interjection($lTag,'NFP4A') eq 'NFP4A' ||
	    Interjection($lTag,'NIS4A') eq 'NIS4A' ||
	    Interjection($lTag,'NIP4A') eq 'NIP4A' ||
	    Interjection($lTag,'NMS4A') eq 'NMS4A' ||
	    Interjection($lTag,'NMP4A') eq 'NMP4A' ||
	    Interjection($lTag,'NNS4A') eq 'NNS4A' ||
	    Interjection($lTag,'NNP4A') eq 'NNP4A' ||
	    Interjection($lTag,'NFS4N') eq 'NFS4N' ||
	    Interjection($lTag,'NFP4N') eq 'NFP4N' ||
	    Interjection($lTag,'NIS4N') eq 'NIS4N' ||
	    Interjection($lTag,'NIP4N') eq 'NIP4N' ||
	    Interjection($lTag,'NMS4N') eq 'NMS4N' ||
	    Interjection($lTag,'NMP4N') eq 'NMP4N' ||
	    Interjection($lTag,'NNS4N') eq 'NNS4N' ||
	    Interjection($lTag,'NNP4N') eq 'NNP4N' ||
	    Interjection($lTag,'PDNS4') eq 'PDNS4' ||
	    Interjection($lTag,'PDNP4') eq 'PDNP4' ||
	    Interjection($lTag,'PDFS4') eq 'PDFS4' ||
	    Interjection($lTag,'PDFP4') eq 'PDFP4' ||
	    Interjection($lTag,'PDMS4') eq 'PDMS4' ||
	    Interjection($lTag,'PDMP4') eq 'PDMP4' ||
	    Interjection($lTag,'PDIS4') eq 'PDIS4' ||
	    Interjection($lTag,'PDIP4') eq 'PDIP4' ||
	    Interjection($lTag,'NFXXA') eq 'NFXXA' ||
	    Interjection($lTag,'NMXXA') eq 'NMXXA' ||
	    Interjection($lTag,'NIXXA') eq 'NIXXA' ||
	    Interjection($lTag,'NNXXA') eq 'NNXXA' ||
	    Interjection($lTag,'ZNUM') eq 'ZNUM') {

	  $sAfun = 'Obj';

	  goto aa;
	}

	if (substr($sTag,0,2) eq 'PQ' ||
	    substr($sTag,0,2) eq 'PI' ||
	    substr($sTag,0,2) eq 'PD' ||
	    substr($sTag,0,2) eq 'PP' ||
	    substr($sTag,0,2) eq 'PN') {

	  $sAfun = 'Sb';

	  goto aa;
	}

	if (Interjection($pParAct->{'form'},'je') eq 'je' ||
	    Interjection($pParAct->{'form'},'Je') eq 'Je' ||
	    Interjection($pParAct->{'form'},'JE') eq 'JE' ||
	    Interjection($pParAct->{'form'},'jsou') eq 'jsou' ||
	    Interjection($pParAct->{'form'},'Jsou') eq 'Jsou' ||
	    Interjection($pParAct->{'form'},'JSOU') eq 'JSOU') {

	  $pAct->{'afunprev'} = $pAct->{'afun'};

	  $pAct->{'afun'} = 'Pnom';

	  goto ex;
	} else {

	  $sAfun = 'Adv';

	  goto aa;
	}

      }

    }
  ParentPossiblyAux:
    if ($pParParAct) {

      if (Interjection($pParAct->{'afun'},'AuxP') eq 'AuxP') {

	if (Interjection($pParParAct->{'afun'},'Pred') eq 'Pred' ||
	    $sParParPOS eq 'V' ||
	    $sParParPOS eq 'A') {

	  $fObj = "0";

	  if (substr($sParLemma,0,3) eq 'bez') {

	    if (substr($sParParLemma,0,6) eq 'obejít') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,2) eq 'na') {

	    if (substr($sParParLemma,0,3) eq 'jít') {

	      $fObj = "1";

	      goto TObj;
	    }

	    if (substr($sParParLemma,0,5) eq 'chtít') {

	      $fObj = "1";

	      goto TObj;
	    }

	    if (substr($sParParLemma,0,5) eq 'dìlit') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,2) eq 'od') {

	    if (substr($sParParLemma,0,5) eq 'chtít') {

	      $fObj = "1";

	      goto TObj;
	    }

	    if (substr($sParParLemma,0,7) eq 'odli¹it') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,2) eq 'za') {

	    if (substr($sParParLemma,0,4) eq 'moci') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,1) eq 's') {

	    if (substr($sParParLemma,0,6) eq 'jednat') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,1) eq 'o') {

	    if (substr($sParParLemma,0,10) eq 'informovat') {

	      $fObj = "1";

	      goto TObj;
	    }

	    if (substr($sParParLemma,0,3) eq 'jít') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,1) eq 'z') {

	    if (substr($sParParLemma,0,10) eq 'financovat') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,1) eq 'k') {

	    if (substr($sParParLemma,0,5) eq 'dojít') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }

	  if (substr($sParLemma,0,1) eq 'v') {

	    if (substr($sParParLemma,0,10) eq 'pokraèovat') {

	      $fObj = "1";

	      goto TObj;
	    }
	  }
	TObj:
	  if ($fObj eq "1") {

	    $sAfun = 'Obj';

	    goto aa;
	  } else {

	    $sAfun = 'Adv';

	    goto aa;
	  }

	}

	if ($sParParPOS eq 'N' ||
	    $sParParPOS eq 'P' ||
	    $sParParPOS eq 'C') {

	  $sAfun = 'Atr';

	  goto aa;
	}
      }
    }
  }

  if ($sPOS eq 'V' ||
      Interjection('být',$lLemma) eq 'být' ||
      Interjection('mít',$lLemma) eq 'mít') {

    if (Interjection($lLemma,'být') eq 'být') {

      if (!(FirstSon($pAct))) {

	$pAct->{'afunprev'} = $pAct->{'afun'};

	$pAct->{'afun'} = 'AuxV';

	goto ex;
      }
    }

    if ($sParPOS eq 'N' ||
	$sParPOS eq 'P') {

      $sAfun = 'Atr';

      goto aa;
    }

    if (Interjection($pParAct->{'afun'},'AuxC') eq 'AuxC') {

      $fObj = "0";

      if ($sParLemma eq '¾e') {

	$fObj = "1";
      }

      if ($fObj eq "1") {

	$sAfun = 'Obj';

	goto aa;
      } else {

	$sAfun = 'Adv';

	goto aa;
      }

    }

    if ($sParLemma eq 'øíkat' ||
	$sParLemma eq 'utrousit' ||
	$sParLemma eq 'myslet' ||
	$sParLemma eq 'myslit' ||
	$sParLemma eq 'øíci' ||
	$sParLemma eq 'pronést' ||
	$sParLemma eq 'sdìlit' ||
	$sParLemma eq 'øíct' ||
	$sParLemma eq 'povìdìt') {

      $sAfun = 'Obj';

      goto aa;
    }

    if (Interjection($lTag,'VFA') eq 'VFA' ||
	Interjection($lTag,'VFN') eq 'VFN') {

      if ($fSubject eq "1" ||
	  $sParLemma eq 'mít' ||
	  $sParLemma eq 'chtít' ||
	  $sParLemma eq 'zaèít' ||
	  $sParLemma eq 'pøestat' ||
	  $sParLemma eq 'smìt' ||
	  $sParLemma eq 'moci' ||
	  $sParLemma eq 'moct') {

	$sAfun = 'Obj';

	goto aa;
      } else {

	$sAfun = 'Sb';

	goto aa;
      }

    }
  }

  if ($sParPOS eq 'N') {

    $sAfun = 'Atr';

    goto aa;
  }

  goto ex;
 aa:
  $pAct->{'afun'} = (ValNo(0,$sAfun).ValNo(0,$sSuffAct));
 ex:
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
  return;

}


sub SubtreeUndefAfun {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pParent = $pPar1;

  $pAct = FirstSon($pParent);

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $sT = ValNo(0,$pAct->{'afun'});

  $pAct->{'afun'} = '???';

  if ($sT ne '' &&
      $sT ne '???') {

    $pAct->{'afunprev'} = $sT;
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
  return;

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


#bind previous_node to Shift+Tab menu previous word (linear order)
sub previous_node {

  $pPar1 = $this;

  $pPar2 = undef;

  GoPrev();

  $this = $pReturn;

}


#bind next_node to Tab menu next word (linear order)
sub next_node {

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
  my ($t, $n);			# used as type "pointer"

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

  $sPasteNow = '';

}


sub FuncAssign {
  my ($t, $n);			# used as type "pointer"

  $t = $this;

  if (Interjection($t->{'afun'},'AuxS') ne 'AuxS') {

    $t->{'func'} = $sPar1;

    if ($sPar1 eq 'PAR') {

      $t->{'memberof'} = 'PA';
    }

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

  $sPasteNow = '';

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


#bind all_func_assign to Ctrl+Shift+F9
sub all_func_assign {

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


#bind toggle_hide_subtree to h menu Hide/Show current subtree
sub toggle_hide_subtree {

  HideSubtree();

}


#bind join_with_mother_lemma to Ctrl+U menu Pripojit k matce (spojit, vhodne pro sloz. predlozky)
sub join_with_mother_lemma {

  $sPar1 = "1";

  JoinSubtree();

}


#bind join_with_mother to Ctrl+N menu Pripojit k matce (nespojit, vhodne pro modal. sloveso)
sub join_with_mother {

  $sPar1 = "0";

  JoinSubtree();

}


#bind split_node_and_lemma to Ctrl+B menu Rozpojit uzel i lemmata
sub split_node_and_lemma {

  $sPar1 = "1";

  SplitJoined();

}


#bind _key_Ctrl_Shift_Q to Ctrl+Q menu Odpojit pripojene fw od akt. vrcholu
sub _key_Ctrl_Shift_Q {

  splitfw();

}


#bind _key_Ctrl_Shift_M to Ctrl+M menu Zmenit uzel Neg na predponu ne-
sub _key_Ctrl_Shift_M {

  JoinNegation();

}


#bind add_Gen_ACT to 1 menu Doplnit Gen.ACT pod akt. vrchol
sub add_Gen_ACT {

  $sPar1 = '&Gen;';

  $sPar2 = '';

  NewSubject();

}


#bind add_Cor_ACT to 2 menu Doplnit Cor.ACT pod akt. vrchol
sub add_Cor_ACT {

  $sPar1 = '&Cor;';

  $sPar2 = '';

  NewSubject();

}


#bind add_on_ACT to 3 menu Doplnit on.ACT pod akt. vrchol
sub add_on_ACT {

  $sPar1 = 'on';

  $sPar2 = 'ANIM';

  NewSubject();

}


#bind add_Forn_ACT to 8 menu Doplnit Forn.ACT pod akt. vrchol
sub add_Forn_ACT {

  $sPar1 = '&Forn;';

  $sPar2 = '';

  NewSubject();

}


#bind add_new_node to Ctrl+x menu Doplnit novy uzel (???) pod akt. vrchol
sub add_new_node {

  $pPar1 = $this;

  NewSon();

}


#bind add_EV to Ctrl+v menu Doplnit prazdne sloveso Emp pod akt. vrchol
sub add_EV {

  NewVerb();

}


#bind change_trlemma_to_lemma to Ctrl+W menu Zmenit trlemma na lemma
sub change_trlemma_to_lemma {

  trtolemma();

}


#bind join_with_mother_as_fw to Ctrl+P menu Pripojit k matce jako fw
sub join_with_mother_as_fw {

  joinfw();

}


#bind add_questionmarks_func to Ctrl+X menu Pridat k funktoru ???
sub add_questionmarks_func {

  $sPar3 = ValNo(0,$this->{'func'});

  $sPar1 = ValNo(0,Union($sPar3,'???'));

  FuncAssign();

}


#bind memberof_co to y menu Pridat memberof=CO
sub memberof_co {

  $pPar1 = $this;

  $pPar1->{'memberof'} = 'CO';

}


#bind memberof_ap to Y menu Pridat memberof=AP
sub memberof_ap {

  $pPar1 = $this;

  $pPar1->{'memberof'} = 'AP';

}


#bind func_ACT to a menu ACT Actor, agens
sub func_ACT {

  $sPar1 = 'ACT';

  FuncAssign();

}


#bind func_ADDR to d menu ADDR Addressee
sub func_ADDR {

  $sPar1 = 'ADDR';

  FuncAssign();

}


#bind func_PAT to p menu PAT Patient (prosli celý les.PAT)
sub func_PAT {

  $sPar1 = 'PAT';

  FuncAssign();

}


#bind func_EFF to f menu EFF Effect, výsledek (zvolit kým)
sub func_EFF {

  $sPar1 = 'EFF';

  FuncAssign();

}


#bind func_ORIG to o menu ORIG Origin, pùvod (z èeho, NE odkud)
sub func_ORIG {

  $sPar1 = 'ORIG';

  FuncAssign();

}


#bind func_ACMP to c menu ACMP  Accompaniment, doprovod (s, bez)
sub func_ACMP {

  $sPar1 = 'ACMP';

  FuncAssign();

}


#bind func_ADVS to v menu ADVS Adversative, odporovací koord. (ale, vsak)
sub func_ADVS {

  $sPar1 = 'ADVS';

  FuncAssign();

}


#bind func_AIM to m menu AIM Úèel (aby, pro nìco)
sub func_AIM {

  $sPar1 = 'AIM';

  FuncAssign();

}


#bind func_APP to 5 menu APP Appurtenance, pøinálezitost (èí, èeho)
sub func_APP {

  $sPar1 = 'APP';

  FuncAssign();

}


#bind func_APPS to s menu APPS Apposition (totiz, a to)
sub func_APPS {

  $sPar1 = 'APPS';

  FuncAssign();

}


#bind func_ATT to t menu ATT Attitude, postoj
sub func_ATT {

  $sPar1 = 'ATT';

  FuncAssign();

}


#bind func_BEN to b menu BEN Benefactive (pro koho, proti komu)
sub func_BEN {

  $sPar1 = 'BEN';

  FuncAssign();

}


#bind func_CAUS to C menu CAUS Cause, pøíèina
sub func_CAUS {

  $sPar1 = 'CAUS';

  FuncAssign();

}


#bind func_CNCS to Ctrl+c menu CNCS
sub func_CNCS {

  $sPar1 = 'CNCS';

  FuncAssign();

}


#bind func_COMPL to L menu COMPL Complement, závisí na slovese
sub func_COMPL {

  $sPar1 = 'COMPL';

  FuncAssign();

}


#bind func_COND to Ctrl+d menu COND Condition, podmínka reálná (-li, jestlize, kdyz, az)
sub func_COND {

  $sPar1 = 'COND';

  FuncAssign();

}


#bind func_CONFR to O menu CONFR
sub func_CONFR {

  $sPar1 = 'CONFR';

  FuncAssign();

}


#bind func_CONJ to j menu CONJ Conjunction, sluèovací koord. (a)
sub func_CONJ {

  $sPar1 = 'CONJ';

  FuncAssign();

}


#bind func_CPR to P menu CPR Porovnání (nez, jako, stejnì jako)
sub func_CPR {

  $sPar1 = 'CPR';

  FuncAssign();

}


#bind func_CRIT to Ctrl+k menu CRIT Criterion, mìøítko (podle nìj, podle jeho slov)
sub func_CRIT {

  $sPar1 = 'CRIT';

  FuncAssign();

}


#bind func_CSQ to q menu CSQ Consequence, dùsledek koord. (a proto, a tak, a tedy, proèez)
sub func_CSQ {

  $sPar1 = 'CSQ';

  FuncAssign();

}


#bind func_CTREF to Ctrl+f menu CTERF Counterfactual, ireálná podmínka (kdyby)
sub func_CTREF {

  $sPar1 = 'CTERF';

  FuncAssign();

}


#bind func_DENOM to n menu DENOM Pojmenování
sub func_DENOM {

  $sPar1 = 'DENOM';

  FuncAssign();

}


#bind func_DES to D menu DES Deskr. pøívl., nerestr. (zlatá Praha, lidé mající ...)
sub func_DES {

  $sPar1 = 'DES';

  FuncAssign();

}


#bind func_DIFF to F menu DIFF Difference, rozdíl (oè)
sub func_DIFF {

  $sPar1 = 'DIFF';

  FuncAssign();

}


#bind func_DIR1 to Shift+F1 menu DIR1 Odkud
sub func_DIR1 {

  $sPar1 = 'DIR1';

  FuncAssign();

}


#bind func_DIR2 to Shift+F2 menu DIR2 Kudy (prosli lesem)
sub func_DIR2 {

  $sPar1 = 'DIR2';

  FuncAssign();

}


#bind func_DIR3 to Shift+F3 menu DIR3 Kam
sub func_DIR3 {

  $sPar1 = 'DIR3';

  FuncAssign();

}


#bind func_DISJ to J menu DISJ Disjunction, rozluèovací koord. (nebo, anebo)
sub func_DISJ {

  $sPar1 = 'DISJ';

  FuncAssign();

}


#bind func_DPHR to X menu DPHR zavisla cast frazemu
sub func_DPHR {

  $sPar1 = 'DPHR';

  FuncAssign();

}


#bind func_ETHD to E menu ETHD Ethical Dative (já ti mám knih, dìti nám nechodí vèas)
sub func_ETHD {

  $sPar1 = 'ETHD';

  FuncAssign();

}


#bind func_EXT to x menu EXT Extent, míra (velmi, trochu)
sub func_EXT {

  $sPar1 = 'EXT';

  FuncAssign();

}


#bind func_FPHR to 6 menu FPHR fraze v cizim jazyce
sub func_FPHR {

  $sPar1 = 'FPHR';

  FuncAssign();

}


#bind func_GRAD to Ctrl+g menu GRAD Gradation, stupòovací koord (i, a také)
sub func_GRAD {

  $sPar1 = 'GRAD';

  FuncAssign();

}


#bind func_HER to H menu HER heritage, dìdictví (po otci)
sub func_HER {

  $sPar1 = 'HER';

  FuncAssign();

}


#bind func_ID to i menu ID Identity (pojem èasu, øeka Vltava)
sub func_ID {

  $sPar1 = 'ID';

  FuncAssign();

}


#bind func_INTF to I menu INTF falesný podmìt (To Karel jestì nepøisel?)
sub func_INTF {

  $sPar1 = 'INTF';

  FuncAssign();

}


#bind func_INTT to T menu INTT zámìr (šel se koupat)
sub func_INTT {

  $sPar1 = 'INTT';

  FuncAssign();

}


#bind func_LOC to l menu LOC Location, místo kde (jednání uvnitø koalice)
sub func_LOC {

  $sPar1 = 'LOC';

  FuncAssign();

}


#bind func_MANN to 9 menu MANN Manner, zpùsob (ústnì, psát èesky)
sub func_MANN {

  $sPar1 = 'MANN';

  FuncAssign();

}


#bind func_MAT to 4 menu MAT Partitiv (hrnek èaje)
sub func_MAT {

  $sPar1 = 'MAT';

  FuncAssign();

}


#bind func_MEANS to Ctrl+m menu MEANS Prostøedek (psát rukou, tuzkou)
sub func_MEANS {

  $sPar1 = 'MEANS';

  FuncAssign();

}


#bind func_MOD to M menu MOD Adv. of modality (asi, mozná, to je myslím zlé)
sub func_MOD {

  $sPar1 = 'MOD';

  FuncAssign();

}


#bind func_NORM to N menu NORM Norma (ve shodì s, podle)
sub func_NORM {

  $sPar1 = 'NORM';

  FuncAssign();

}


#bind func_PAR to Ctrl+z menu PAR Parenthesis, vsuvka (myslím, vìøím)
sub func_PAR {

  $sPar1 = 'PAR';

  FuncAssign();

}


#bind func_PARTL to A menu PARTL
sub func_PARTL {

  $sPar1 = 'PARTL';

  FuncAssign();

}


#bind func_PREC to Ctrl+p menu PREC Ref. to prec. text(na zaè. vìty:tedy, tudíz, totiz,protoze, ..)
sub func_PREC {

  $sPar1 = 'PREC';

  FuncAssign();

}


#bind func_PRED to e menu PRED Predikat
sub func_PRED {

  $sPar1 = 'PRED';

  FuncAssign();

}


#bind func_REAS to Ctrl+r menu REAS Reason, dùvod (nebot)
sub func_REAS {

  $sPar1 = 'REAS';

  FuncAssign();

}


#bind func_REG to g menu REG Regard (se zøetelem, s ohledem)
sub func_REG {

  $sPar1 = 'REG';

  FuncAssign();

}


#bind func_RESL to S menu RESL Úèinek (takze)
sub func_RESL {

  $sPar1 = 'RESL';

  FuncAssign();

}


#bind func_RESTR to R menu RESTR Omezení (kromì, mimo)
sub func_RESTR {

  $sPar1 = 'RESTR';

  FuncAssign();

}


#bind func_RHEM to 7 menu RHEM Rhematizer (i, také, jenom,vùbec, NEG, nikoli)
sub func_RHEM {

  $sPar1 = 'RHEM';

  FuncAssign();

}


#bind func_RSTR to r menu RSTR restriktivní pøívlastek
sub func_RSTR {

  $sPar1 = 'RSTR';

  FuncAssign();

}


#bind func_SUBS to Ctrl+u menu SUBS Zastoupení (místo koho-èeho)
sub func_SUBS {

  $sPar1 = 'SUBS';

  FuncAssign();

}


#bind func_TFHL to Ctrl+h menu TFHL For how long, na jak dlouho (na vìky)
sub func_TFHL {

  $sPar1 = 'TFHL';

  FuncAssign();

}


#bind func_TFRWH to W menu TFRWH From when, zekdy (zbylo od vánoc cukroví)
sub func_TFRWH {

  $sPar1 = 'TFRWH';

  FuncAssign();

}


#bind func_THL to Ctrl+l menu THL How long, jak dlouho (èetl pùl hodiny)
sub func_THL {

  $sPar1 = 'THL';

  FuncAssign();

}


#bind func_THO to Ctrl+o menu THO How often (èasto, mnohokrát...)
sub func_THO {

  $sPar1 = 'THO';

  FuncAssign();

}


#bind func_TOWH to Ctrl+w menu TOWH To when, nakdy (pøelozí výuku na pátek)
sub func_TOWH {

  $sPar1 = 'TOWH';

  FuncAssign();

}


#bind func_TPAR to Ctrl+a menu TPAR Parallel (bìhem, zatímco, za celý zápas, mezitím co)
sub func_TPAR {

  $sPar1 = 'TPAR';

  FuncAssign();

}


#bind func_TSIN to Ctrl+i menu TSIN Since, odkdy (od té doby co, ode dne podpisu)
sub func_TSIN {

  $sPar1 = 'TSIN';

  FuncAssign();

}


#bind func_TILL to Ctrl+t menu TTILL Till, dokdy (az do, dokud ne, nez)
sub func_TILL {

  $sPar1 = 'TTILL';

  FuncAssign();

}


#bind func_TWHEN to w menu TWHEN When, kdy (loni, vstupuje v platnost dnem podpisu)
sub func_TWHEN {

  $sPar1 = 'TWHEN';

  FuncAssign();

}


#bind func_VOC to V menu VOC Vokativní vìta (Jirko!)
sub func_VOC {

  $sPar1 = 'VOC';

  FuncAssign();

}


#bind func_VOCAT to K menu VOCAT Vokativ aponovaný (Pojï sem, Jirko!)
sub func_VOCAT {

  $sPar1 = 'VOCAT';

  FuncAssign();

}


#bind func_NA to Ctrl+n menu NA Not Applicable, toto slovo nemá funktor
sub func_NA {

  $sPar1 = 'NA';

  FuncAssign();

}


#bind func_questionmarks to Ctrl+y menu ???
sub func_questionmarks {

  $sPar1 = '???';

  FuncAssign();

}


#bind tfa_topic to k menu tfa = topic
sub tfa_topic {

  $sPar1 = 'T';

  TFAAssign();

}


#bind tfa_focus to u menu tfa = focus
sub tfa_focus {

  $sPar1 = 'F';

  TFAAssign();

}


#bind shift_node_left to Q menu posun uzel doleva
sub shift_node_left {

  $sPar1 = 'L';

  MoveNode();

}


#bind shift_node_right to U menu posun uzel doprava
sub shift_node_right {

  $sPar1 = 'R';

  MoveNode();

}


#bind sign_ZU to Ctrl+Z menu Podpis Zdena Uresova
sub sign_ZU {

  $sPar1 = 'ZU/func_EB/tfa';

  SignatureAssign();

}


#bind sign_AB to Ctrl+A menu Podpis Alla Bemova
sub sign_AB {

  $sPar1 = 'AB/func_EB/tfa';

  SignatureAssign();

}


#bind sign_EB to Ctrl+E menu Podpis Eva Buranova
sub sign_EB {

  $sPar1 = 'EB/func_EB/tfa';

  SignatureAssign();

}


#bind sign_IK to Ctrl+K menu Podpis Ivona Kucerova
sub sign_IK {

  $sPar1 = 'IK/func_EB/tfa';

  SignatureAssign();

}


#bind _key_Ctrl_B to Ctrl+b menu copy node
sub _key_Ctrl_B {

  FCopy();

}


#bind _key_Ctrl_Shift_F1 to Ctrl+Shift+F1 menu paste node
sub _key_Ctrl_Shift_F1 {

  FPaste();

}

sub tree_to_tr {
  foreach ($root,$root->descendants) {
    $_->{TR}='';
  }
  $root->{reserve1}='';
  InitFileTR();
  TreeToTR();
}


##bind tree_to_tr to Ctrl+Shift+F2
#sub tree_to_tr {
#
#  TreeToTR();
#
#}


#bind init_file_tr to Ctrl+Shift+F8
sub init_file_tr {

  InitFileTR();

}


sub TreeToTR {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pThis;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"

  $sPasteNow = '';

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

  Conjunctions();

  Prec();

  Sentmod();

  TRVerbs();

  Pnoms();

  ModalVerbs();

  FillEmpty();

}


sub InitFileTR {
  my $pRoot;			# used as type "pointer"
  my $iStart;			# used as type "string"

  $sPasteNow = '';

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
  my $pT1;			# used as type "pointer"
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
  my $sVTag11;			# used as type "string"
  my $i;			# used as type "string"
  my $sGender;			# used as type "string"
  my $sNumber;			# used as type "string"
  my $sN;			# used as type "string"

  $sPasteNow = '';

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

  $sVTag2 = substr($sTag,2,1);

  if ($sVTag2 eq '') {

    $i = "0";

    goto MGContinue;
  }

  $sVTag3 = substr($sTag,3,1);

  if ($sVTag3 eq '') {

    $i = "1";

    goto MGContinue;
  }

  $sVTag4 = substr($sTag,4,1);

  if ($sVTag4 eq '') {

    $i = "2";

    goto MGContinue;
  }

  $sVTag5 = substr($sTag,5,1);

  if ($sVTag5 eq '') {

    $i = "3";

    goto MGContinue;
  }

  $sVTag6 = substr($sTag,6,1);

  if ($sVTag6 eq '') {

    $i = "4";

    goto MGContinue;
  }

  $sVTag7 = substr($sTag,7,1);

  if ($sVTag7 eq '') {

    $i = "5";

    goto MGContinue;
  }

  $sVTag8 = substr($sTag,8,1);

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
  my $sLema;			# used as type "string"
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

  $sLema = ValNo(0,$pAct->{'lemma'});

  $sPar1 = $sLema;

  GetAfunSuffix();

  $pAct->{'trlemma'} = $sPar2;

  $sForm = ValNo(0,$pAct->{'form'});

  $sPar1 = ValNo(0,$pAct->{'afun'});

  GetAfunSuffix();

  $sSuffix = substr($sPar3,0,3);

  $sAfun = $sPar2;

  $pAct->{'reserve2'} = $sAfun;

  if ($sSuffix eq '_Co') {

    $pAct->{'memberof'} = 'CO';
  } else {

    if ($sSuffix eq '_Ap') {

      Parent($pAct)->{'func'} = 'APPS';

      $pAct->{'memberof'} = 'AP';
    } else {

      if ($sSuffix eq '_Pa') {

	$pAct->{'parenthesis'} = 'PA';

	if (Interjection($pAct->{'afun'},'AuxY_Pa') eq 'AuxY_Pa') {

	  $pAct->{'func'} = 'PAR';
	} else {

	  $pAct->{'func'} = 'PAR';
	}

      } else {

	$pAct->{'memberof'} = 'NIL';
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

      $pAct->{'func'} = 'ETHD';
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

  if (Interjection($pAct->{'afun'},'AuxP') eq 'AuxP' &&
      Interjection($pAct->{'TR'},'hide') ne 'hide') {

    $pPrepParent = Parent($pAct);

    if (Interjection($pPrepParent->{'afun'},'AuxP') eq 'AuxP') {

      $sPrepBody = ValNo(0,$pPrepParent->{'form'});

      $sPrepTail = ValNo(0,$pAct->{'form'});

      $BodyOrder = ValNo(0,$pPrepParent->{'ord'});

      $TailOrder = ValNo(0,$pAct->{'ord'});

      if ($TailOrder>=$BodyOrder) {

	$sPomocny = (ValNo(0,$sPrepBody).ValNo(0,'_'));

	$sPrep = (ValNo(0,$sPomocny).ValNo(0,$sPrepTail));
      } else {

	$sPomocny = (ValNo(0,'_').ValNo(0,$sPrepBody));

	$sPrep = (ValNo(0,$sPrepTail).ValNo(0,$sPomocny));
      }


      $pPrepParent->{'trlemma'} = $sPrep;

      $pAct->{'TR'} = 'hide';

      $pAct->{'reserve1'} = 'AuxP';

      $pPar1 = $pPrepParent;

      $pPar2 = $pAct;

      ConnectAIDREFS();

      $pPrepParent->{'reserve1'} = 'complex';

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

      $sPrepBody = ValNo(0,$pPrepParent->{'form'});

      $sPrepTail = ValNo(0,$pAct->{'form'});

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

      $pPrepParent->{'reserve1'} = 'complex';

      $pAct->{'TR'} = 'hide';

      $pAct->{'reserve1'} = 'AuxC';

      $pPar1 = $pPrepParent;

      $pPar2 = $pAct;

      ConnectAIDREFS();
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
  my $pPnomPar;			# used as type "pointer"
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

	      $pPar1 = $pAct;

	      $pPar2 = $pThisSon;

	      ConnectAIDREFS();

	      $pPar1 = $pThisSon;

	      $pPar2 = $pAct;

	      CutAllSubtrees();
	    }

	    if (!($pBYT)) {

	      $pBYT = $pThisSon;

	      $pThisSon->{'TR'} = 'hide';

	      $pPar1 = $pVerb;

	      $pPar2 = $pThisSon;

	      ConnectAIDREFS();

	      $pPar1 = $pThisSon;

	      $pPar2 = $pVerb;

	      CutAllSubtrees();
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

	    $pPar1 = $pAct;

	    $pPar2 = $pThisSon;

	    ConnectAIDREFS();
	  }
	}

	if (Interjection($pThisSon->{'afun'},'AuxT') eq 'AuxT') {

	  $pSE = $pThisSon;

	  $sSEForm = ValNo(0,$pSE->{'form'});

	  $pSE->{'TR'} = 'hide';

	  $pPar1 = $pAct;

	  $pPar2 = $pThisSon;

	  ConnectAIDREFS();
	}

	if (Interjection($pThisSon->{'afun'},'Pnom') eq 'Pnom') {

	  $sVTagBeg = substr(ValNo(0,$pThisSon->{'tag'}),0,1);

	  if ($sVTagBeg eq 'V') {

	    $pThisSon->{'reserve5'} = 'PNOM';
	  }
	}

	if ($pThisSon) {

	  if (RBrother($pThisSon)) {

	    $pThisSon = RBrother($pThisSon);

	    goto AllSons;
	  }
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
  my $pCut1;			# used as type "pointer"
  my $pModal;			# used as type "pointer"
  my $pKoord;			# used as type "pointer"
  my $pPossVerb;		# used as type "pointer"
  my $pVerbRBrother;		# used as type "pointer"
  my $sLemma;			# used as type "string"
  my $sTag;			# used as type "string"
  my $sVTagBeg;			# used as type "string"
  my $sMod;			# used as type "string"
  my $sModLem;			# used as type "string"
  my $sVerbLem;			# used as type "string"
  my $pVerbTag;			# used as type "string"
  my $sVerbAfun;		# used as type "string"
  my $sKoord;			# used as type "string"
  my $sFw;			# used as type "string"

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

  $sKoord = "0";

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

  $sFw = ValNo(0,$pModal->{'fw'});
 AllSons:
  if ($pVerb) {

    $sVerbAfun = ValNo(0,$pVerb->{'afun'});

    $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);

    if ($sVerbAfun eq 'Coord') {

      $sKoord = $sKoord+"1";

      $pKoord = $pVerb;

      $pPossVerb = FirstSon($pVerb);

      if ($pPossVerb) {

	if (substr(ValNo(0,$pPossVerb->{'tag'}),0,1) eq 'V') {

	  $pVerb = $pPossVerb;

	  goto ModalKoordination;
	}
      }
    }

    if ($pVerbTag eq 'Vf' ||
	$pVerbTag eq 'Vs') {

      $pJoin = $pVerb;

      $pVerb->{'fw'} = $sFw;
    } else {

      $pVerb = RBrother($pVerb);

      goto AllSons;
    }


    if ($pJoin) {

      $pCut1 = $pJoin;

      $NodeClipboard=CutNode($pCut1);

      $pD = PasteNode($NodeClipboard,Parent($pModal));

      $pVerb = $pD;

      $pCut = FirstSon($pModal);
    CutAllSubtrees:
      if ($pCut) {

	if (Interjection($pCut->{'ordorig'},'') eq '') {

	  $pCut->{'ordorig'} = Parent($pCut)->{'ord'};
	}

	$NodeClipboard=CutNode($pCut);

	$pD = PasteNode($NodeClipboard,$pVerb);

	$pCut = FirstSon($pModal);

	goto CutAllSubtrees;
      }

      $pPar1 = $pVerb;

      $pPar2 = $pModal;

      ConnectAIDREFS();

      $NodeClipboard=CutNode($pModal);

      $pD = PasteNode($NodeClipboard,$pVerb);

      $pD->{'TR'} = 'hide';

      $pVerb->{'deontmod'} = $sMod;

      $pAct = $pVerb;

      if ($sKoord>"0") {

	$sKoord = $sKoord+"1";

	$pVerb = RBrother($pVerb);

	goto AllSons;
      }
    }
  }

  goto PruchodStromemDoHloubky;
 ActNodeWasModalObjReq:
  $pJoin = undef;

  $pModal = $pAct;

  $pVerb = FirstSon($pModal);

  $sFw = ValNo(0,$pModal->{'fw'});
 AllSonsObj:
  if ($pVerb) {

    $pVerbRBrother = RBrother($pVerb);

    $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);

    $sVerbAfun = ValNo(0,$pVerb->{'afun'});

    if ($sVerbAfun eq 'Coord') {

      $sKoord = $sKoord+"1";

      $pKoord = $pVerb;

      $pPossVerb = FirstSon($pVerb);

      if ($pPossVerb) {

	if (substr(ValNo(0,$pPossVerb->{'tag'}),0,1) eq 'V') {

	  $pVerb = $pPossVerb;

	  goto ModalKoordinationObj;
	}
      }
    }

    if ($pVerbTag eq 'Vf' ||
	$pVerbTag eq 'Vs') {

      if (Interjection($pVerb->{'afun'},'Obj') eq 'Obj') {

	$pJoin = $pVerb;

	$pVerb->{'fw'} = $sFw;
      } else {

	$pJoin = undef;
      }

    } else {

      $pVerb = $pVerbRBrother;

      goto AllSonsObj;
    }


    if ($pJoin) {

      $pCut = $pJoin;

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,Parent($pModal));

      $pVerb = $pD;

      $pCut = FirstSon($pModal);
    CutAllSubtrees:
      if ($pCut) {

	if (Interjection($pCut->{'ordorig'},'') eq '') {

	  $pCut->{'ordorig'} = Parent($pCut)->{'ord'};
	}

	$NodeClipboard=CutNode($pCut);

	$pD = PasteNode($NodeClipboard,$pVerb);

	$pCut = FirstSon($pModal);

	goto CutAllSubtrees;
      }

      $pPar1 = $pVerb;

      $pPar2 = $pModal;

      ConnectAIDREFS();

      $NodeClipboard=CutNode($pModal);

      $pD = PasteNode($NodeClipboard,$pVerb);

      $pD->{'TR'} = 'hide';

      $pVerb->{'deontmod'} = $sMod;

      $pAct = $pVerb;

      if ($sKoord>"0") {

	$sKoord = $sKoord+"1";

	$pVerb = $pVerbRBrother;

	goto AllSonsObj;
      }
    }
  }

  goto PruchodStromemDoHloubky;
 ModalKoordination:
  $pVerb->{'reserve1'} = 'MODAL KOORD';

  $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);
 AllSonsKoord:
  if ($pVerb) {

    if ($pVerbTag eq 'Vf' ||
	$pVerbTag eq 'Vs') {

      $pJoin = $pVerb;

      $pVerb->{'fw'} = $sFw;
    } else {

      $pVerb = RBrother($pVerb);

      goto AllSonsKoord;
    }


    if ($pJoin) {

      $pJoin->{'deontmod'} = $sMod;

      $pVerb = RBrother($pVerb);

      goto AllSonsKoord;
    }
  }

  $pPar1 = $pKoord;

  $pPar2 = $pModal;

  ConnectAIDREFS();

  $NodeClipboard=CutNode($pKoord);

  $pD = PasteNode($NodeClipboard,Parent($pModal));

  $pKoord = $pD;

  $pPar1 = $pModal;

  $pPar2 = $pKoord;

  CutAllSubtrees();

  $pModal->{'TR'} = 'hide';

  $NodeClipboard=CutNode($pModal);

  $pD = PasteNode($NodeClipboard,$pKoord);

  $pAct = $pKoord;

  goto PruchodStromemDoHloubky;
 ModalKoordinationObj:
  $pVerbTag = substr(ValNo(0,$pVerb->{'tag'}),0,2);
 AllSonsKoordObj:
  if ($pVerb) {

    if ($pVerbTag eq 'Vf' ||
	$pVerbTag eq 'Vs') {

      if (Interjection($pVerb->{'afun'},'Obj_Co') eq 'Obj_Co') {

	$pJoin = $pVerb;

	$pVerb->{'fw'} = $sFw;
      }
    } else {

      $pVerb = RBrother($pVerb);

      goto AllSonsKoordObj;
    }


    if ($pJoin) {

      $pJoin->{'deontmod'} = $sMod;

      $pVerb = RBrother($pVerb);

      goto AllSonsKoordObj;
    }
  }

  $pPar1 = $pKoord;

  $pPar2 = $pModal;

  ConnectAIDREFS();

  $NodeClipboard=CutNode($pKoord);

  $pD = PasteNode($NodeClipboard,Parent($pModal));

  $pKoord = $pD;

  $pPar1 = $pModal;

  $pPar2 = $pKoord;

  CutAllSubtrees();

  $pModal->{'TR'} = 'hide';

  $NodeClipboard=CutNode($pModal);

  $pD = PasteNode($NodeClipboard,$pKoord);

  $pAct = $pKoord;

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

    if (Interjection($pAct->{'memberof'},'CO') eq 'CO') {

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

    if (Interjection($pAct->{'memberof'},'CO') ne 'CO') {

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

    if (Interjection($pAct->{'TR'},'hide') eq 'hide' &&
	Interjection($pAct->{'reserve1'},'complex') ne 'complex') {

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

	if (Interjection($pCoordP->{'memberof'},'CO') eq 'CO') {

	  $pCoordP->{'fw'} = $pPrep->{'trlemma'};
	}

	$pCoordP = RBrother($pCoordP);

	goto CoordinationWPrep;
      }
    }

    $sTRLema = ValNo(0,$pPrep->{'trlemma'});

    $pOnlyChild->{'fw'} = $sTRLema;

    $pPrep->{'TR'} = 'hide';

    $pPar1 = $pOnlyChild;

    $pPar2 = $pPrep;

    ConnectAIDREFS();

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

  goto PruchodStromemDoHloubky;

}


sub Conjunctions {
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

  if (Interjection($pAct->{'afun'},'AuxC') eq 'AuxC') {

    if (Interjection($pAct->{'TR'},'hide') eq 'hide' &&
	Interjection($pAct->{'reserve1'},'complex') ne 'complex') {

      goto PruchodStromemDoHloubky;
    }

    $pConj = $pAct;

    $pParent = Parent($pConj);

    $pOnlyChild = FirstSon($pConj);
  FindNoun:
    if (!($pOnlyChild)) {

      goto PruchodStromemDoHloubky;
    }

    if (Interjection($pOnlyChild->{'afun'},'AuxX') eq 'AuxX' ||
	Interjection($pOnlyChild->{'afun'},'AuxY') eq 'AuxY' ||
	Interjection($pOnlyChild->{'afun'},'AuxZ') eq 'AuxZ' ||
	Interjection($pOnlyChild->{'afun'},'AuxP') eq 'AuxP') {

      $pOnlyChild = RBrother($pOnlyChild);

      goto FindNoun;
    }

    $sTRLema = ValNo(0,$pConj->{'trlemma'});

    $pOnlyChild->{'fw'} = $sTRLema;

    $pPar1 = $pOnlyChild;

    $pPar2 = $pConj;

    ConnectAIDREFS();

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

  $sPasteNow = '';

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
  my $sPriznak;			# used as type "string"

  $sPasteNow = '';

  $sPriznak = $sPar1;

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  $pSubtree = $pAct;

  $sJLema = ValNo(0,Parent($pAct)->{'trlemma'});

  $sActLema = ValNo(0,$pAct->{'trlemma'});

  if ($sActLema eq '&Gen;') {

    $sActLema = 'se';
  }

  if ($sActLema eq 'se' &&
      Interjection($pAct->{'form'},'si') eq 'si') {

    $sActLema = 'si';
  }

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

  $pPar1 = Parent($pAct);

  $pPar2 = $pAct;

  ConnectAIDREFS();

  $pPar1 = $pAct;

  $pAct = Parent($pAct);

  if ($sPriznak eq "1") {

    $pAct->{'trlemma'} = $sJLema;

    $sPar1 = "0";
  }

  if ($sPriznak eq "0") {

    $sPar3 = '';

    ifmodal();

    $pAct->{'deontmod'} = $sPar3;
  }

  $this = $pAct;

}


sub ifmodal {

  $sPasteNow = '';

  $sPar1 = ValNo(0,$pPar1->{'lemma'});

  GetAfunSuffix();

  $sPar3 = '';

  if ($sPar2 eq 'chtít') {

    $sPar3 = 'VOL';
  }

  if ($sPar2 eq 'muset') {

    $sPar3 = 'DEB';
  }

  if ($sPar2 eq 'moci' ||
      $sPar2 eq 'dát_se' ||
      $sPar2 eq 'dát' ||
      $sPar2 eq 'se_dát') {

    $sPar3 = 'POSS';
  }

  if ($sPar2 eq 'smìt') {

    $sPar3 = 'PERM';
  }

  if ($sPar2 eq 'umìt' ||
      $sPar2 eq 'dovést' ||
      $sPar2 eq 'dokázat') {

    $sPar3 = 'FAC';
  }

  if ($sPar2 eq 'mít') {

    $sPar3 = 'HRT';
  }

}


sub JoinNegation {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $pNeg;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sActLema;			# used as type "string"
  my $sSonLema;			# used as type "string"
  my $sParLema;			# used as type "string"
  my $sFinLema;			# used as type "string"

  $sPasteNow = '';

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  $sActLema = ValNo(0,$pAct->{'trlemma'});

  $pSon = FirstSon($pAct);
 CheckSons:
  if ($pSon) {

    $sSonLema = ValNo(0,$pSon->{'trlemma'});

    if ($sSonLema eq '&Neg;') {

      $pNeg = $pSon;

      goto DoIt;
    }

    $pSon = RBrother($pSon);

    goto CheckSons;
  } else {

    $sSonLema = '';
  }


  $pParent = Parent($pAct);

  if ($pParent) {

    $sParLema = ValNo(0,$pParent->{'trlemma'});
  } else {

    $sParLema = '';
  }


  if ($sActLema eq '&Neg;') {

    $pNeg = $pAct;

    goto DoIt;
  }

  if ($sParLema eq '&Neg;') {

    $pNeg = $pParent;

    goto DoIt;
  }

  return;
 DoIt:
  $pParent = Parent($pNeg);

  $sParLema = ValNo(0,$pParent->{'trlemma'});

  $pSon = FirstSon($pNeg);

  if ($pSon) {

    return;
  }

  $NodeClipboard=CutNode($pNeg);

  $sFinLema = (ValNo(0,'ne').ValNo(0,$sParLema));

  $pParent->{'trlemma'} = $sFinLema;

  $this = $pParent;

}


sub joinfw {
  my $pAct;			# used as type "pointer"
  my $pParentW;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"

  $sPasteNow = '';

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  if (!(FirstSon($pAct))) {

    $pAct->{'TR'} = 'hide';

    $pParentW = Parent($pAct);

    $pPar1 = $pParentW;

    $pPar2 = $pAct;

    ConnectAIDREFS();

    $pPar1 = $pParentW;

    $pPar2 = $pAct;

    ConnectFW();
  }

}


sub splitfw {
  my $pAct;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $sWLemma;			# used as type "string"
  my $pRoot;			# used as type "pointer"

  $sPasteNow = '';

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

    $pPar1 = $pAct;

    $pPar2 = $pSon;

    DisconnectFW();

    DisconnectAIDREFS();
  } else {

    $pSon = RBrother($pSon);

    if ($pSon) {

      goto AllSons;
    }
  }


}


sub SplitJoined {
  my $pAct;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $sWLemma;			# used as type "string"
  my $sRestOfTrLemma;		# used as type "string"
  my $pRoot;			# used as type "pointer"
  my $sCaseSi;			# used as type "string"

  $sCaseSi = "0";

  $sPasteNow = '';

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') ne 'TR_TREE') {

    return;
  }

  $pAct = $this;

  $pSon = FirstSon($pAct);

  $sRestOfTrLemma = ValNo(0,$pAct->{'trlemma'});
 AllParts:
  $sPar1 = $sRestOfTrLemma;

  GetAfunSuffix();

  $sRestOfTrLemma = $sPar2;

  $sWLemma = $sPar3;

  if ($sWLemma eq '') {

    $pAct->{'trlemma'} = $sRestOfTrLemma;

    return;
  }

  if ($sWLemma eq '_si') {

    $sCaseSi = "1";
  }
 AllSons:
  if ($sCaseSi eq "1") {

    if (Interjection($pSon->{'trlemma'},'se') eq 'se' &&
	Interjection($pSon->{'form'},'si') eq 'si') {
      $sWLemma = '_se';
    }

    $sCaseSi = "0";
  }
  if (substr(ValNo(0,$pSon->{'trlemma'}),0,3) eq substr($sWLemma,1,3)) {

    $pPar1 = $pAct;

    $pPar2 = $pSon;

    DisconnectAIDREFS();

    $pSon->{'TR'} = '';

    $pPar1 = $pSon;

    ifmodal();

    if ($sPar3 ne '') {

      $pAct->{'deontmod'} = '';
    }
  } else {

    $pSon = RBrother($pSon);

    if ($pSon) {

      goto AllSons;
    }
  }


  goto AllParts;

}


sub FillEmpty {
  my $pAct;			# used as type "pointer"
  my $pNew;			# used as type "pointer"
  my $pNewNode;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pT1;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
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
  my $sAfunc;			# used as type "string"
  my $sForma;			# used as type "string"
  my $sNegace;			# used as type "string"

  $sPasteNow = '';

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

  $sAfunc = ValNo(0,$pAct->{'afun'});

  $sForma = ValNo(0,$pAct->{'form'});

  $sTag = ValNo(0,$pAct->{'tag'});

  if (Interjection($pAct->{'TR'},'hide') ne 'hide') {

    if ($sForma eq ',') {

      $pAct->{'trlemma'} = '&Comma;';
    }

    if ($sForma eq ':') {

      $pAct->{'trlemma'} = '&Colon;';
    }

    if ($sForma eq ';') {

      $pAct->{'trlemma'} = '&Semicolon;';
    }

    if ($sForma eq '-') {

      $pAct->{'trlemma'} = '&Hyphen;';
    }

    if ($sForma eq '.') {

      $pAct->{'trlemma'} = '&Period;';
    }

    if ($sForma eq '/') {

      $pAct->{'trlemma'} = '&Slash;';
    }

    if ($sForma eq '(' ||
	$sForma eq ')') {

      $pAct->{'trlemma'} = '&Lpar;';
    }
  }

  if ($sAfunc eq 'AuxR') {

    $pAct->{'TR'} = 'hide';

    $pPar1 = Parent($pAct);

    NewSon();

    $pNewNode = $pReturn;

    $pNewNode->{'trlemma'} = '&Gen;';

    $pNewNode->{'func'} = 'ACT';
  }

  if ($sAfunc eq 'AuxK') {

    $pAct->{'TR'} = 'hide';
  }

  if ($sAfunc eq 'AuxG') {

    $pAct->{'TR'} = 'hide';
  }

  if ($sAfunc eq 'ExD' &&
      Interjection($pAct->{'trlemma'},'&Lpar;') eq '&Lpar;') {

    $pAct->{'TR'} = 'hide';
  }

  if ($sAfunc eq 'AuxX') {

    $pAct->{'TR'} = 'hide';

    $pPar1 = $pAct;

    $pPar2 = Parent($pAct);

    CutAllSubtrees();
  }

  $sTRlemma = ValNo(0,$pAct->{'trlemma'});

  if ($sTRlemma eq 'mùj') {

    $pAct->{'trlemma'} = 'my';

    $pAct->{'func'} = 'APP';
  }

  if ($sTRlemma eq 'tvùj') {

    $pAct->{'trlemma'} = 'ty';

    $pAct->{'func'} = 'APP';
  }

  if ($sTRlemma eq 'jeho') {

    $pAct->{'trlemma'} = 'on';

    $pAct->{'func'} = 'APP';
  }

  if ($sTRlemma eq 'její') {

    $pAct->{'trlemma'} = 'on';

    $pAct->{'func'} = 'APP';
  }

  if ($sTRlemma eq 'jejich') {

    $pAct->{'trlemma'} = 'on';

    $pAct->{'func'} = 'APP';
  }

  if ($sTRlemma eq 'svùj') {

    $pAct->{'trlemma'} = 'se';

    $pAct->{'func'} = 'APP';
  }

  $sNegace = substr($sTag,10,1);

  if ($sNegace eq 'N') {

    $pAct->{'trneg'} = 'N';

    $pPar1 = $pAct;

    NewSon();

    $pT1 = $pReturn;

    $pT1->{'func'} = 'RHEM';

    $pT1->{'trlemma'} = '&Neg;';

    $pT1->{'form'} = 'NIL';

    $pT1->{'del'} = 'ELID';
  }

  if ($sNegace eq 'A') {

    $pAct->{'trneg'} = 'A';
  }

  if ($sNegace eq '-') {

    $pAct->{'trneg'} = 'NA';
  }

  if (Interjection($pAct->{'func'},'') eq '') {

    $pAct->{'func'} = '???';
  }

  if (Interjection($pAct->{'gender'},'') eq '') {

    $pAct->{'gender'} = '???';
  }

  $pAct->{'tfa'} = 'T';

  goto PruchodStromemDoHloubky;

}


sub Prec {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pTest;			# used as type "pointer"
  my $pSon;			# used as type "pointer"
  my $pD;			# used as type "pointer"

  $sPasteNow = '';

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

  if (Interjection($pAct->{'afun'},'Coord') eq 'Coord') {

    $pTest = Parent($pAct);

    $pSon = FirstSon($pAct);

    if (Interjection($pTest->{'afun'},'AuxS') eq 'AuxS') {

      if (!(RBrother($pSon))) {

	if (Interjection($pSon->{'ordorig'},'') eq '') {

	  $pSon->{'ordorig'} = Parent($pSon)->{'ord'};
	}

	$NodeClipboard=CutNode($pSon);

	$pD = PasteNode($NodeClipboard,$pTest);

	$pSon = $pD;

	$pAct->{'func'} = 'PREC';

	if (Interjection($pAct->{'ordorig'},'') eq '') {

	  $pAct->{'ordorig'} = Parent($pAct)->{'ord'};
	}

	$NodeClipboard=CutNode($pAct);

	$pD = PasteNode($NodeClipboard,$pSon);

	if (Interjection($pSon->{'memberof'},'CO') eq 'CO') {

	  $pSon->{'memberof'} = '';
	}

	$pAct = $pSon;
      }
    }

    goto PruchodStromemDoHloubky;
  }

}


sub GetNewTID {

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
  my $sLemma;			# used as type "string"
  my $sTID;			# used as type "string"

  $sPasteNow = '';

  $sLemma = $sPar1;

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

  GetNewTID();

  $sTID = $sPar3;

  if (FirstSon($pT)) {

    $sDord = ValNo(0,FirstSon($pT)->{'dord'});
  } else {

    $sDord = ValNo(0,$pT->{'dord'});
  }


  $pNew =   PlainNewSon($pT);

  $pNew->{'lemma'} = '-';

  $pNew->{'tag'} = '-';

  $pNew->{'form'} = '-';

  $pNew->{'afun'} = '-';

  $pNew->{'TID'} = $sTID;

  $pPredch = FirstSon($pT);

  $pNew->{'ord'} = $sPoradi;

  $pNew->{'ID1'} = '';

  $pNew->{'ID2'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'afunprev'} = '';

  $pNew->{'semPOS'} = '';

  $pNew->{'tagauto'} = '';

  $pNew->{'lemauto'} = '';

  $pNew->{'AID'} = '';

  $pNew->{'govTR'} = '';

  $pNew->{'nospace'} = '';

  $pNew->{'root'} = '';

  $pNew->{'ending'} = '';

  $pNew->{'punct'} = '';

  $pNew->{'alltags'} = '';

  $pNew->{'wt'} = '';

  $pNew->{'origfkind'} = '';

  $pNew->{'formtype'} = '';

  $pNew->{'gappost'} = '';

  $pNew->{'gappre'} = '';

  $pNew->{'para'} = '';

  $pNew->{'cstslang'} = '';

  $pNew->{'cstssource'} = '';

  $pNew->{'cstsmarkup'} = '';

  $pNew->{'chap'} = '';

  $pNew->{'doc'} = '';

  $pNew->{'docid'} = '';

  $pNew->{'docmarkup'} = '';

  $pNew->{'docprolog'} = '';

  $pNew->{'TR'} = '';

  $pNew->{'warning'} = '';

  $pNew->{'err1'} = '';

  $pNew->{'err2'} = '';

  $pNew->{'wMDl_b'} = '';

  $pNew->{'wMDt_a'} = '';

  $pNew->{'tagMD_a'} = '';

  $pNew->{'wMDt_b'} = '';

  $pNew->{'tagMD_b'} = '';

  $pNew->{'lemmaMD_a'} = '';

  $pNew->{'lemmaMD_b'} = '';

  $pNew->{'wMDl_a'} = '';

  $pNew->{'ordorig'} = '';

  $pNew->{'trlemma'} = $sLemma;

  $pNew->{'func'} = 'ACT';

  $pNew->{'del'} = 'ELID';

  $pNew->{'dord'} = "-1";

  $sPar1 = $sDord;

  $sPar2 = "1";

  ShiftDords();

  $pNew->{'dord'} = $sDord;

  if ($sPar2 eq 'ANIM') {

    $pNew->{'gender'} = 'ANIM';

    $pNew->{'number'} = 'SG';
  } else {

    $pNew->{'gender'} = '???';

    $pNew->{'number'} = '???';
  }


  $pNew->{'degcmp'} = '???';

  $pNew->{'tense'} = '???';

  $pNew->{'aspect'} = '???';

  $pNew->{'iterativeness'} = '???';

  $pNew->{'verbmod'} = '???';

  $pNew->{'deontmod'} = '???';

  $pNew->{'sentmod'} = '???';

  $pNew->{'tfa'} = '???';

  $pNew->{'gram'} = '???';

  $pNew->{'memberof'} = '???';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'parenthesis'} = '???';

  $pNew->{'recip'} = '???';

  $pNew->{'fw'} = '';

  $pNew->{'phraseme'} = '';

  $pNew->{'coref'} = '';

  $pNew->{'cornum'} = '';

  $pNew->{'commentA'} = '';

  $pNew->{'funcauto'} = '';

  $pNew->{'funcprec'} = '';

  $pNew->{'funcaux'} = '';

  $pNew->{'dispmod'} = '???';

  $pNew->{'trneg'} = 'NA';

  $pNew->{'frameid'} = '';

  $pNew->{'framerel'} = '';

  $pNew->{'reserve1'} = '';

  $pNew->{'reserve2'} = '';

  $pNew->{'reserve3'} = '';

  $pNew->{'reserve4'} = '';

  $pNew->{'reserve5'} = '';

  $pNew->{'sentord'} = "999";

  $pNew->{'reserve1'} = '';

  $pNew->{'reserve2'} = '';

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
  my $sTID;			# used as type "string"

  $sPasteNow = '';

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

  GetNewTID();

  $sTID = $sPar3;

  $pNew =   PlainNewSon($pT);

  $pNew->{'lemma'} = '-';

  $pNew->{'tag'} = '-';

  $pNew->{'form'} = '-';

  $pNew->{'afun'} = '---';

  $pNew->{'TID'} = $sTID;

  $pNew->{'ID1'} = '';

  $pNew->{'ID2'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'afunprev'} = '';

  $pNew->{'semPOS'} = '';

  $pNew->{'tagauto'} = '';

  $pNew->{'lemauto'} = '';

  $pNew->{'AID'} = '';

  $pNew->{'govTR'} = '';

  $pNew->{'nospace'} = '';

  $pNew->{'root'} = '';

  $pNew->{'ending'} = '';

  $pNew->{'punct'} = '';

  $pNew->{'alltags'} = '';

  $pNew->{'wt'} = '';

  $pNew->{'origfkind'} = '';

  $pNew->{'formtype'} = '';

  $pNew->{'gappost'} = '';

  $pNew->{'gappre'} = '';

  $pNew->{'para'} = '';

  $pNew->{'cstslang'} = '';

  $pNew->{'cstssource'} = '';

  $pNew->{'cstsmarkup'} = '';

  $pNew->{'chap'} = '';

  $pNew->{'doc'} = '';

  $pNew->{'docid'} = '';

  $pNew->{'docmarkup'} = '';

  $pNew->{'docprolog'} = '';

  $pNew->{'TR'} = '';

  $pNew->{'warning'} = '';

  $pNew->{'err1'} = '';

  $pNew->{'err2'} = '';

  $pNew->{'wMDl_b'} = '';

  $pNew->{'wMDt_a'} = '';

  $pNew->{'tagMD_a'} = '';

  $pNew->{'wMDt_b'} = '';

  $pNew->{'tagMD_b'} = '';

  $pNew->{'lemmaMD_a'} = '';

  $pNew->{'lemmaMD_b'} = '';

  $pNew->{'wMDl_a'} = '';

  $pNew->{'ordorig'} = '';

  $pNew->{'dord'} = $sDord;

  $pNew->{'sentord'} = "999";

  $pNew->{'ord'} = $sNum;

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

  $pNew->{'memberof'} = '???';

  $pNew->{'del'} = 'ELID';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'parenthesis'} = '???';

  $pNew->{'recip'} = '???';

  $pNew->{'fw'} = '';

  $pNew->{'phraseme'} = '';

  $pNew->{'coref'} = '';

  $pNew->{'cornum'} = '';

  $pNew->{'commentA'} = '';

  $pNew->{'funcauto'} = '';

  $pNew->{'funcprec'} = '';

  $pNew->{'funcaux'} = '';

  $pNew->{'dispmod'} = '???';

  $pNew->{'trneg'} = 'NA';

  $pNew->{'frameid'} = '';

  $pNew->{'framerel'} = '';

  $pNew->{'reserve1'} = '';

  $pNew->{'reserve2'} = '';

  $pNew->{'reserve3'} = '';

  $pNew->{'reserve4'} = '';

  $pNew->{'reserve5'} = '';

  $NodeClipboard=CutNode($pNew);

  $pReturn = PasteNode($NodeClipboard,$pT);

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
  my $sTID;			# used as type "string"

  $sPasteNow = '';

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

  GetNewTID();

  $sTID = $sPar3;

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

  $pNew->{'TID'} = $sTID;

  $pNew->{'ID1'} = '';

  $pNew->{'ID2'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'origf'} = '';

  $pNew->{'afunprev'} = '';

  $pNew->{'semPOS'} = '';

  $pNew->{'tagauto'} = '';

  $pNew->{'lemauto'} = '';

  $pNew->{'AID'} = '';

  $pNew->{'ord'} = $sNum;

  $pNew->{'govTR'} = '';

  $pNew->{'nospace'} = '';

  $pNew->{'root'} = '';

  $pNew->{'ending'} = '';

  $pNew->{'punct'} = '';

  $pNew->{'alltags'} = '';

  $pNew->{'wt'} = '';

  $pNew->{'origfkind'} = '';

  $pNew->{'formtype'} = '';

  $pNew->{'gappost'} = '';

  $pNew->{'gappre'} = '';

  $pNew->{'para'} = '';

  $pNew->{'cstslang'} = '';

  $pNew->{'cstssource'} = '';

  $pNew->{'cstsmarkup'} = '';

  $pNew->{'chap'} = '';

  $pNew->{'doc'} = '';

  $pNew->{'docid'} = '';

  $pNew->{'docmarkup'} = '';

  $pNew->{'docprolog'} = '';

  $pNew->{'TR'} = '';

  $pNew->{'warning'} = '';

  $pNew->{'err1'} = '';

  $pNew->{'err2'} = '';

  $pNew->{'wMDl_b'} = '';

  $pNew->{'wMDt_a'} = '';

  $pNew->{'tagMD_a'} = '';

  $pNew->{'wMDt_b'} = '';

  $pNew->{'tagMD_b'} = '';

  $pNew->{'lemmaMD_a'} = '';

  $pNew->{'lemmaMD_b'} = '';

  $pNew->{'wMDl_a'} = '';

  $pNew->{'ordorig'} = '';

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

  $pNew->{'gram'} = '???';

  $pNew->{'memberof'} = '???';

  $pNew->{'del'} = 'ELID';

  $pNew->{'quoted'} = '???';

  $pNew->{'dsp'} = '???';

  $pNew->{'corsnt'} = '???';

  $pNew->{'antec'} = '???';

  $pNew->{'parenthesis'} = '???';

  $pNew->{'recip'} = '???';

  $pNew->{'fw'} = '';

  $pNew->{'phraseme'} = '';

  $pNew->{'coref'} = '';

  $pNew->{'cornum'} = '';

  $pNew->{'commentA'} = '';

  $pNew->{'funcauto'} = '';

  $pNew->{'funcprec'} = '';

  $pNew->{'funcaux'} = '';

  $pNew->{'dispmod'} = '???';

  $pNew->{'trneg'} = 'NA';

  $pNew->{'frameid'} = '';

  $pNew->{'framerel'} = '';

  $pNew->{'reserve1'} = '';

  $pNew->{'reserve2'} = '';

  $pNew->{'reserve3'} = '';

  $pNew->{'reserve4'} = '';

  $pNew->{'reserve5'} = '';

  $pNew->{'dord'} = "-1";

  $sPar1 = $sDord;

  $sPar2 = "1";

  ShiftDords();

  $pNew->{'dord'} = $sDord;

  $pNew->{'sentord'} = FirstSon($pT)->{'dord'};

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


#bind tr_lemma_form to Ctrl+Shift+F3
sub tr_lemma_form {

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

  $sPasteNow = '';

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

  $sPasteNow = '';

  ThisRoot();

  $pRoot = $pReturn;

  if (Interjection($pRoot->{'reserve1'},'TR_TREE') eq 'TR_TREE') {

    return;
  }

  $pAct->{'trlemma'} = $pAct->{'lemma'};

}


sub SignatureAssign {
  my $pT;			# used as type "pointer"

  $sPasteNow = '';
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


sub CutAllSubtrees {
  my $pCut;			# used as type "pointer"
  my $pD;			# used as type "pointer"

  $sPasteNow = '';

  if (!($pPar1)) {

    return;
  }

  if (!($pPar2)) {

    return;
  }

  $pCut = FirstSon($pPar1);

  if ($pCut) {
  CutAllSubtrees:
    if ($pCut) {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,$pPar2);

      $pCut = FirstSon($pPar1);

      goto CutAllSubtrees;
    }
  }

}


sub ConnectFW {

}


sub DisconnectFW {

}


sub ConnectAIDREFS {

}


sub DisconnectAIDREFS {

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
  $pPar2 = undef;
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
  $pPar2 = undef;
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

 loopShiftDord:
  if (ValNo(0,$pAct->{'dord'})>=$sPar1) {

    $pAct->{'dord'} = ValNo(0,$pAct->{'dord'})+$sPar2;
  }

  $pPar1 = $pAct;
  $pPar2 = undef;
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

 loopShiftDord:
  if (ValNo(0,$pAct->{'dord'})==$sPar1) {

    $pAct->{'dord'} = ValNo(0,$pAct->{'dord'})+$sPar2;

    return;
  }

  $pPar1 = $pAct;
  $pPar2 = undef;

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

  $sPasteNow = '';

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


#bind delete_node to Ctrl+D menu Smaze aktualni uzel, pokud nema deti.
sub delete_node {

  DeleteCurrentNode();

}


sub DeleteCurrentNode {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sDord;			# used as type "string"

  $sPasteNow = '';

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


#bind cut_paste_all to Ctrl+I menu Cut a paste na vsechny uzly podle struktury. (Treba spustit vicekrat).
sub cut_paste_all {

  CutPasteAll();

}


sub CutPasteAll {
  my $pAct;			# used as type "pointer"
  my $pParent;			# used as type "pointer"

  $sPasteNow = '';

  ThisRoot();

  $pAct = FirstSon($pReturn);

 forallnodes:
  if ($pAct) {

    $pParent = Parent($pAct);

    $NodeClipboard=CutNode($pAct);

    $pAct = PasteNode($NodeClipboard,$pParent);

    $pPar1 = $pAct;
    $pPar2 = undef;
    GoNext();

    $pAct = $pReturn;

    goto forallnodes;
  }

}


#bind ungap_dords to Ctrl+G menu Testuje poradi uzlu (dord) a rusi mezery v cislovani
sub ungap_dords {

  UnGap();

}


sub UnGap {
  my $pAct;			# used as type "pointer"
  my $lDords;			# used as type "list"
  my $lEmpty;			# used as type "list"
  my $sMaxDord;			# used as type "string"
  my $sShift;			# used as type "string"

  $sPasteNow = '';

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
    $pPar2 = undef;

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

  OpravaHlavy();

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


sub OpravaGenNum {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sAdj;			# used as type "string"
  my $sVTag1;			# used as type "string"
  my $sVTag2;			# used as type "string"
  my $sVTag3;			# used as type "string"
  my $sGender;			# used as type "string"
  my $sNumber;			# used as type "string"

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

  $sVTag1 = substr($sTag,0,1);

  $sVTag2 = substr($sTag,2,1);

  $sVTag3 = substr($sTag,3,1);

  if ($sVTag1 eq 'N') {

    goto Noun;
  }

  if ($sVTag1 eq 'A') {

    goto Noun;
  }

  if ($sVTag1 eq 'P') {

    goto Noun;
  }

  goto PruchodStromemDoHloubky;
 Noun:
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

  if (Interjection($pAct->{'gap1'},'???') eq '???') {

    $pAct->{'gap1'} = '';
  }

  if (Interjection($pAct->{'gap2'},'???') eq '???') {

    $pAct->{'gap2'} = '';
  }

  if (Interjection($pAct->{'gap3'},'???') eq '???') {

    $pAct->{'gap3'} = '';
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

  if (Interjection($pAct->{'memberof'},'') eq '' ||
      Interjection($pAct->{'memberof'},'???') eq '???') {

    $pAct->{'memberof'} = 'NIL';
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


sub OpravaHlavy {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sAdj;			# used as type "string"
  my $sSuffix;			# used as type "string"

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

  if (Interjection($pAct->{'memberof'},'PA') eq 'PA') {

    $pAct->{'memberof'} = 'NIL';

    $pAct->{'parenthesis'} = 'PA';
  }

  $sPar1 = ValNo(0,$pAct->{'afun'});

  GetAfunSuffix();

  $sSuffix = substr($sPar3,0,3);

  if ($sSuffix eq '_Ap') {

    $pAct->{'memberof'} = 'AP';
  }

  $pNext = FirstSon($pAct);

  goto PruchodStromemDoHloubky;

}


sub Pnoms {
  my $pPNOM;			# used as type "pointer"
  my $pPnomPar;			# used as type "pointer"
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pT;			# used as type "pointer"
  my $pRoot;			# used as type "pointer"
  my $pD;			# used as type "pointer"
  my $pCut;			# used as type "pointer"
  my $sTag;			# used as type "string"
  my $sAdj;			# used as type "string"
  my $sSuffix;			# used as type "string"

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

  $pCut = undef;

  $pPNOM = undef;

  $pPnomPar = undef;

  if (Interjection($pAct->{'reserve5'},'PNOM') eq 'PNOM') {

    $pAct->{'reserve5'} = '';

    $pPNOM = $pAct;

    $pPnomPar = Parent($pPNOM);

    $pCut = $pPNOM;

    if ($pCut) {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);
    }

    $pD = PasteNode($NodeClipboard,Parent($pPnomPar));

    $pPNOM = $pD;

    $pCut = $pPnomPar;

    if ($pCut) {

      if (Interjection($pCut->{'ordorig'},'') eq '') {

	$pCut->{'ordorig'} = Parent($pCut)->{'ord'};
      }

      $NodeClipboard=CutNode($pCut);

      $pD = PasteNode($NodeClipboard,$pPNOM);
    }

    $pPar1 = $pD;

    $pPar2 = $pPNOM;

    CutAllSubtrees();

    $pD->{'TR'} = 'hide';

    $pPnomPar = $pD;

    $pPar1 = $pPnomPar;

    $pPar2 = $pPNOM;

    ConnectAIDREFS();

    $pAct = $pPNOM;
  }

  goto PruchodStromemDoHloubky;

}


sub FCopy {
  my $pThis;			# used as type "pointer"
  my $pParent;			# used as type "pointer"

  $pThis = $this;

  $pParent = Parent($pThis);

  if (Interjection($pThis->{'del'},'ELID') ne 'ELID') {

    $NodeClipboard=CutNode($pThis);

    $pDummy = PasteNode($NodeClipboard,$pParent);

    $sPasteNow = 'yes';
  }

}


sub FPaste {
  my $pThis;			# used as type "pointer"
  my $pPasted;			# used as type "pointer"
  my $sDord;			# used as type "string"
  my $pCut;			# used as type "pointer"
  my $sTID;			# used as type "string"

  if ($sPasteNow eq 'yes') {

    $pThis = $this;

    $sDord = ValNo(0,$pThis->{'dord'});

    $pPasted = PasteNode($NodeClipboard,$pThis);

    $pCut = FirstSon($pPasted);

    if ($pCut) {
    CutAllSubtrees:
      if ($pCut) {

	$NodeClipboard=CutNode($pCut);

	$pCut = FirstSon($pPasted);

	goto CutAllSubtrees;
      }
    }

    $pPasted->{'dord'} = "-1";

    $pPasted->{'del'} = 'ELID';

    $sPar1 = $sDord;

    $sPar2 = "1";

    ShiftDords();

    $pPasted->{'dord'} = $sDord;

    GetNewTID();

    $sTID = $sPar3;

    $pPasted->{'TID'} = $sTID;

    if (Interjection($pPasted->{'AIDREFS'},'') eq '') {

      $pPasted->{'AIDREFS'} = $pPasted->{'AID'};
    }

    $pPasted->{'AID'} = '';
  }

  $sPasteNow = '';

}
