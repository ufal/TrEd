## This is macro file for Tred                                   -*-cperl-*-
## It should be used for analytical trees editing
## author: Petr Pajas
## Time-stamp: <2002-10-06 08:33:36 pajas>

package Analytic;
use base qw(TredMacro);
import TredMacro;


#include <contrib/AutoAfun.mak>

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
  $value=main::QueryString($grp->{framegroup},"Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}


#bind default_ar_attrs to F8 menu Display default attributes
sub default_ar_attrs {
  return unless $grp->{FSFile};
  SetDisplayAttrs('${form}', '${afun}');
  SetBalloonPattern("tag:\t\${tag}\nlemma:\t\${lemma}");
  return 1;
}


sub switch_context_hook {
  if ($grp->{FSFile} and 
      GetSpecialPattern('patterns') ne 'force' and
      !$grp->{FSFile}->hint()) {
#    SetDisplayAttrs('${form}', '${afun}');
    SetBalloonPattern("tag:\t\${tag}\nlemma:\t\${lemma}\ncommentA: \${commentA}");
  }
  $FileNotSaved=0;
}


sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:afun|commentA|err1|err2)$/) {
    return "stop";
  }
}

sub thisAfunNoNext {
  $this->{'afunprev'}=$this->{'afun'};
  $this->{'afun'}=shift;
}

sub thisAfun {
  thisAfunNoNext(@_);
  $this=Next($this) if Next($this);
}

sub thisRoot {
  $this=$root;
}

sub thisChildrensAfun {
  my $suff=shift;
  my $chid;
  my $t=$this;
  $child=FirstSon($t);
  while ($child) {
    $$child{'afun'}=~s/_Co|_Ap/$suff/;
    $child=RBrother($child);
  }
}

# Automatically converted from Graph macros by graph2tred to Perl.         -*-cperl-*-.

my $iPrevAfunAssigned;		# used as type "string"
my $pPar1;			# used as type "pointer"
my $pPar2;			# used as type "pointer"
my $pPar3;			# used as type "pointer"
my $pReturn;			# used as type "pointer"
my $sPar1;			# used as type "string"
my $sPar2;			# used as type "string"
my $sPar3;			# used as type "string"
my $sReturn;			# used as type "string"
my $lPar1;			# used as type "list"
my $lPar2;			# used as type "list"
my $lPar3;			# used as type "list"
my $lReturn;			# used as type "list"
my $_pDummy;			# used as type "pointer"


sub ReadMe {

}


sub comments {

}


sub ThisRoot {
  my $pT, $pPrev;		# used as type "pointer"

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

  if ($sChar eq '_') {

    $sPar2 = substr($sPar1,0,$i);

    $sPar3 = substr($sPar1,$i,20);

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

    goto ex;
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


#bind _key_Ctrl_Shift_F1 to Ctrl+Shift+F1 menu Automatically assign afun to subtree
sub _key_Ctrl_Shift_F1 {

  $pPar1 = $this;

  $_CatchError = "0";

  SubtreeAfunAssign();

  return;

}


#bind _key_F1 to F1
sub _key_F1 {
  my $par;			# used as type "pointer"
  my $parpar;			# used as type "pointer"
  my $parBrotherAct;		# used as type "pointer"
  my $thisLeft;			# used as type "pointer"
  my $thisRight;		# used as type "pointer"
  my $parLeft;			# used as type "pointer"
  my $parRight;			# used as type "pointer"
  my $fThisOK;			# used as type "string"
  my $a0;			# used as type "list"
  my $a1;			# used as type "list"
  my $a2;			# used as type "list"
  my $a3;			# used as type "list"
  my $a4;			# used as type "list"
  my $a5;			# used as type "list"
  my $a6;			# used as type "list"
  my $a7;			# used as type "list"
  my $a8;			# used as type "list"
  my $a9;			# used as type "list"
  my $a10;			# used as type "list"
  my $a11;			# used as type "list"

  $par = Parent($this);

  if (!($par)) {

    return;
  }

  $parpar = Parent($par);

  if (!($parpar)) {

    return;
  }

  $a0 = $this->{AtrNo(0)};

  $a1 = $this->{AtrNo(1)};

  $a2 = $this->{AtrNo(2)};

  $a3 = $this->{AtrNo(3)};

  $a4 = $this->{AtrNo(4)};

  $a5 = $this->{AtrNo(5)};

  $a6 = $this->{AtrNo(6)};

  $a7 = $this->{AtrNo(7)};

  $a8 = $this->{AtrNo(8)};

  $a9 = $this->{AtrNo(9)};

  $a10 = $this->{AtrNo(10)};

  $a11 = $this->{AtrNo(11)};

  if (FirstSon($this)) {

    return;
  }

  $thisLeft = LBrother($this);

  $thisRight = RBrother($this);

  $parLeft = LBrother($par);

  $parRight = RBrother($par);

  $fThisOK = "1";

  if ($thisLeft) {

    if (ValNo(0,$thisLeft->{'ord'})>ValNo(0,$par->{'ord'})) {

      $fThisOK = "0";
    }
  }

  if ($thisRight) {

    if (ValNo(0,$thisRight->{'ord'})<ValNo(0,$par->{'ord'})) {

      $fThisOK = "0";
    }
  }

  if ($parLeft) {

    if (ValNo(0,$parLeft->{'ord'})>ValNo(0,$this->{'ord'})) {

      $fThisOK = "0";
    }
  }

  if ($parRight) {

    if (ValNo(0,$parRight->{'ord'})<ValNo(0,$this->{'ord'})) {

      $fThisOK = "0";
    }
  }

  if ($fThisOK eq "1") {

    $this->{AtrNo(0)} = $par->{AtrNo(0)};

    $this->{AtrNo(1)} = $par->{AtrNo(1)};

    $this->{AtrNo(2)} = $par->{AtrNo(2)};

    $this->{AtrNo(3)} = $par->{AtrNo(3)};

    $this->{AtrNo(4)} = $par->{AtrNo(4)};

    $this->{AtrNo(5)} = $par->{AtrNo(5)};

    $this->{AtrNo(6)} = $par->{AtrNo(6)};

    $this->{AtrNo(7)} = $par->{AtrNo(7)};

    $this->{AtrNo(8)} = $par->{AtrNo(8)};

    $this->{AtrNo(9)} = $par->{AtrNo(9)};

    $this->{AtrNo(10)} = $par->{AtrNo(10)};

    $this->{AtrNo(11)} = $par->{AtrNo(11)};

    $par->{AtrNo(0)} = $a0;

    $par->{AtrNo(1)} = $a1;

    $par->{AtrNo(2)} = $a2;

    $par->{AtrNo(3)} = $a3;

    $par->{AtrNo(4)} = $a4;

    $par->{AtrNo(5)} = $a5;

    $par->{AtrNo(6)} = $a6;

    $par->{AtrNo(7)} = $a7;

    $par->{AtrNo(8)} = $a8;

    $par->{AtrNo(9)} = $a9;

    $par->{AtrNo(10)} = $a10;

    $par->{AtrNo(11)} = $a11;
  }

  return;

}


#bind _key_Shift_F7 to Shift+F7
sub _key_Shift_F7 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"

  $pParent = $this;

  $pAct = FirstSon($pParent);

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $pAct->{'afunprev'} = $pAct->{'afun'};

  if (( Interjection($pAct->{'afun'},'AuxP') ne 'AuxP' ) &&
      ( Interjection($pAct->{'afun'},'Coord') ne 'Coord' ) &&
      ( Interjection($pAct->{'afun'},'AuxX') ne 'AuxX' ) &&
      ( Interjection($pAct->{'afun'},'AuxZ') ne 'AuxZ' ) &&
      ( Interjection($pAct->{'afun'},'AuxG') ne 'AuxG' ) &&
      ( Interjection($pAct->{'afun'},'AuxY') ne 'AuxY' ) &&
      ( Interjection($pAct->{'afun'},'AuxC') ne 'AuxC' )) {

    $pAct->{'afun'} = 'Atr';
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


#bind _key_Shift_F12 to Shift+F12
sub _key_Shift_F12 {
  my $sT;			# used as type "string"

  $sT = ValNo(0,$this->{'afun'});

  $this->{'afun'} = $this->{'afunprev'};

  if (Interjection($this->{'afun'},'') eq '') {

    $this->{'afun'} = '???';
  }

  if ($sT ne '' &&
      $sT ne '???') {

    $this->{'afunprev'} = $sT;
  }

}


#bind _key_Ctrl_Shift_F12 to Ctrl+Shift+F12
sub _key_Ctrl_Shift_F12 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pParent = $this;

  $pAct = FirstSon($pParent);

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $sT = ValNo(0,$pAct->{'afun'});

  $pAct->{'afun'} = $pAct->{'afunprev'};

  if (Interjection($pAct->{'afun'},'') eq '') {

    $pAct->{'afun'} = '???';
  }

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


#bind _key_0 to 0
sub _key_0 {
  my $sT;			# used as type "string"

  $sT = ValNo(0,$this->{'afun'});

  if ($sT ne '' &&
      $sT ne '???') {

    $this->{'afunprev'} = $sT;
  }

  $this->{'afun'} = '???';

}


#bind _key_Shift_0 to parenright
sub _key_Shift_0 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pAct = FirstSon($this);

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

  $pNext = RBrother($pAct);

  $pAct = $pNext;

  if ($pAct) {

    goto ContLoop1;
  }
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


#bind _key_Ctrl_Shift_0 to Ctrl+parenright
sub _key_Ctrl_Shift_0 {

  $_CatchError = "0";

  $pPar1 = $this;

  SubtreeUndefAfun();

}


#bind _key_1 to 1
sub _key_1 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"
  my $cErrors;			# used as type "string"

  $cErrors = "0";

  $this->{'err1'} = $cErrors;

  $pParent = $this;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  if (ValNo(0,$pAct->{'afun'}) ne ValNo(0,$pAct->{'afunman'})) {

    $cErrors = $cErrors+"1";

    $pAct->{'err1'} = 'ERR';
  } else {

    $pAct->{'err1'} = '';
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
  $this->{'err1'} = $cErrors;

  return;

}


sub _key_Shift_1 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pParent = $this;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $pAct->{'afun'} = $pAct->{'afunman'};

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


#bind _key_Ctrl_1 to Ctrl+1
sub _key_Ctrl_1 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pParent = $this;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $pAct->{'afunman'} = $pAct->{'afun'};

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


#bind _key_Ctrl_Shift_1 to Ctrl+exclam
sub _key_Ctrl_Shift_1 {
  my $pAct;			# used as type "pointer"
  my $pNext;			# used as type "pointer"
  my $pParent;			# used as type "pointer"
  my $sT;			# used as type "string"

  $pParent = $this;

  $pAct = $pParent;

  if (!($pAct)) {

    return;
  }
 ContLoop1:
  $pAct->{'gap2'} = '';

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


#bind _key_Backspace to Backspace
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


#bind _key_Q to q menu Assing afun Pred
sub _key_Q {

  $sPar1 = 'Pred';

  AfunAssign();

}


#bind _key_N to n menu Assing afun Pnom
sub _key_N {

  $sPar1 = 'Pnom';

  AfunAssign();

}


#bind _key_V to v menu Assing afun AuxV
sub _key_V {

  $sPar1 = 'AuxV';

  AfunAssign();

}


#bind _key_S to s menu Assing afun Sb
sub _key_S {

  $sPar1 = 'Sb';

  AfunAssign();

}


#bind _key_B to b menu Assing afun Obj
sub _key_B {

  $sPar1 = 'Obj';

  AfunAssign();

}


#bind _key_A to a menu Assing afun Atr
sub _key_A {

  $sPar1 = 'Atr';

  AfunAssign();

}


#bind _key_D to d menu Assing afun Adv
sub _key_D {

  $sPar1 = 'Adv';

  AfunAssign();

}


#bind _key_I to i menu Assign afun Coord
sub _key_I {

  $sPar1 = 'Coord';

  DepSuffix();

}


#bind _key_T to t menu Assign afun AuxT
sub _key_T {

  $sPar1 = 'AuxT';

  AfunAssign();

}


#bind _key_R to r menu Assign afun AuxR
sub _key_R {

  $sPar1 = 'AuxR';

  AfunAssign();

}


#bind _key_P to p menu Assign afun AuxP
sub _key_P {

  $sPar1 = 'AuxP';

  AfunAssign();

}


#bind _key_U to u menu Assign afun Apos
sub _key_U {

  $sPar1 = 'Apos';

  DepSuffix();

}


#bind _key_C to c menu Assign afun AuxC
sub _key_C {

  $sPar1 = 'AuxC';

  AfunAssign();

}


#bind _key_O to o menu Assign afun AuxO
sub _key_O {

  $sPar1 = 'AuxO';

  AfunAssign();

}


#bind _key_H to h menu Assign afun Atv
sub _key_H {

  $sPar1 = 'Atv';

  AfunAssign();

}


#bind _key_J to j menu Assign afun AtvV
sub _key_J {

  $sPar1 = 'AtvV';

  AfunAssign();

}


#bind _key_Z to z menu Assign afun AuxZ
sub _key_Z {

  $sPar1 = 'AuxZ';

  AfunAssign();

}


#bind _key_Y to y menu Assign afun AuxY
sub _key_Y {

  $sPar1 = 'AuxY';

  AfunAssign();

}


#bind _key_G to g menu Assign afun AuxG
sub _key_G {

  $sPar1 = 'AuxG';

  AfunAssign();

}


#bind _key_K to k menu Assign afun AuxK
sub _key_K {

  $sPar1 = 'AuxK';

  AfunAssign();

}


#bind _key_X to x menu Assign afun AuxX
sub _key_X {

  $sPar1 = 'AuxX';

  AfunAssign();

}


#bind _key_E to e menu Assign afun ExD
sub _key_E {

  $sPar1 = 'ExD';

  AfunAssign();

}


#bind _key_Ctrl_Q to Ctrl+q menu Assign afun Pred_Co
sub _key_Ctrl_Q {

  $sPar1 = 'Pred_Co';

  AfunAssign();

}


#bind _key_Ctrl_N to Ctrl+n menu Assign afun Pnom_Co
sub _key_Ctrl_N {

  $sPar1 = 'Pnom_Co';

  AfunAssign();

}


#bind _key_Ctrl_V to Ctrl+v menu Assign afun AuxV_Co
sub _key_Ctrl_V {

  $sPar1 = 'AuxV_Co';

  AfunAssign();

}


#bind _key_Ctrl_S to Ctrl+s menu Assign afun Sb_Co
sub _key_Ctrl_S {

  $sPar1 = 'Sb_Co';

  AfunAssign();

}


#bind _key_Ctrl_B to Ctrl+b menu Assign afun Obj_Co
sub _key_Ctrl_B {

  $sPar1 = 'Obj_Co';

  AfunAssign();

}


#bind _key_Ctrl_A to Ctrl+a menu Assign afun Atr_Co
sub _key_Ctrl_A {

  $sPar1 = 'Atr_Co';

  AfunAssign();

}


#bind _key_Ctrl_D to Ctrl+d menu Assign afun Adv_Co
sub _key_Ctrl_D {

  $sPar1 = 'Adv_Co';

  AfunAssign();

}


#bind _key_Ctrl_I to Ctrl+i menu Assign afun Coord_Co
sub _key_Ctrl_I {

  $sPar1 = 'Coord_Co';

  DepSuffix();

}


#bind _key_Ctrl_T to Ctrl+t menu Assign afun AuxT_Co
sub _key_Ctrl_T {

  $sPar1 = 'AuxT_Co';

  AfunAssign();

}


#bind _key_Ctrl_R to Ctrl+r menu Assign afun AuxR_Co
sub _key_Ctrl_R {

  $sPar1 = 'AuxR_Co';

  AfunAssign();

}


#bind _key_Ctrl_P to Ctrl+p menu Assign afun AuxP_Co
sub _key_Ctrl_P {

  $sPar1 = 'AuxP_Co';

  AfunAssign();

}


#bind _key_Ctrl_U to Ctrl+u menu Assign afun Apos_Co
sub _key_Ctrl_U {

  $sPar1 = 'Apos_Co';

  DepSuffix();

}


#bind _key_Ctrl_C to Ctrl+c menu Assign afun AuxC_Co
sub _key_Ctrl_C {

  $sPar1 = 'AuxC_Co';

  AfunAssign();

}


#bind _key_Ctrl_O to Ctrl+o menu Assign afun AuxO_Co
sub _key_Ctrl_O {

  $sPar1 = 'AuxO_Co';

  AfunAssign();

}


#bind _key_Ctrl_H to Ctrl+h menu Assign afun Atv_Co
sub _key_Ctrl_H {

  $sPar1 = 'Atv_Co';

  AfunAssign();

}


#bind _key_Ctrl_J to Ctrl+j menu Assign afun AtvV_Co
sub _key_Ctrl_J {

  $sPar1 = 'AtvV_Co';

  AfunAssign();

}


#bind _key_Ctrl_Z to Ctrl+z menu Assign afun AuxZ_Co
sub _key_Ctrl_Z {

  $sPar1 = 'AuxZ_Co';

  AfunAssign();

}


#bind _key_Ctrl_Y to Ctrl+y menu Assign afun AuxY_Co
sub _key_Ctrl_Y {

  $sPar1 = 'AuxY_Co';

  AfunAssign();

}


#bind _key_Ctrl_G to Ctrl+g menu Assign afun AuxG_Co
sub _key_Ctrl_G {

  $sPar1 = 'AuxG_Co';

  AfunAssign();

}


#bind _key_Ctrl_K to Ctrl+k menu Assign afun AuxK_Co
sub _key_Ctrl_K {

  $sPar1 = 'AuxK_Co';

  AfunAssign();

}


#bind _key_Ctrl_X to Ctrl+x menu Assign afun AuxX_Co
sub _key_Ctrl_X {

  $sPar1 = 'AuxX_Co';

  AfunAssign();

}


#bind _key_Ctrl_E to Ctrl+e menu Assign afun ExD_Co
sub _key_Ctrl_E {

  $sPar1 = 'ExD_Co';

  AfunAssign();

}


#bind _key_Shift_Q to Q menu Assign afun Pred_Ap
sub _key_Shift_Q {

  $sPar1 = 'Pred_Ap';

  AfunAssign();

}


#bind _key_Shift_N to N menu Assign afun Pnom_Ap
sub _key_Shift_N {

  $sPar1 = 'Pnom_Ap';

  AfunAssign();

}


#bind _key_Shift_V to V menu Assign afun AuxV_Ap
sub _key_Shift_V {

  $sPar1 = 'AuxV_Ap';

  AfunAssign();

}


#bind _key_Shift_S to S menu Assign afun Sb_Ap
sub _key_Shift_S {

  $sPar1 = 'Sb_Ap';

  AfunAssign();

}


#bind _key_Shift_B to B menu Assign afun Obj_Ap
sub _key_Shift_B {

  $sPar1 = 'Obj_Ap';

  AfunAssign();

}


#bind _key_Shift_A to A menu Assign afun Atr_Ap
sub _key_Shift_A {

  $sPar1 = 'Atr_Ap';

  AfunAssign();

}


#bind _key_Shift_D to D menu Assign afun Adv_Ap
sub _key_Shift_D {

  $sPar1 = 'Adv_Ap';

  AfunAssign();

}


#bind _key_Shift_I to I menu Assign afun Coord_Ap
sub _key_Shift_I {

  $sPar1 = 'Coord_Ap';

  DepSuffix();

}


#bind _key_Shift_T to T menu Assign afun AuxT_Ap
sub _key_Shift_T {

  $sPar1 = 'AuxT_Ap';

  AfunAssign();

}


#bind _key_Shift_R to R menu Assign afun AuxR_Ap
sub _key_Shift_R {

  $sPar1 = 'AuxR_Ap';

  AfunAssign();

}


#bind _key_Shift_P to P menu Assign afun AuxP_Ap
sub _key_Shift_P {

  $sPar1 = 'AuxP_Ap';

  AfunAssign();

}


#bind _key_Shift_U to U menu Assign afun Apos_Ap
sub _key_Shift_U {

  $sPar1 = 'Apos_Ap';

  DepSuffix();

}


#bind _key_Shift_C to C menu Assign afun AuxC_Ap
sub _key_Shift_C {

  $sPar1 = 'AuxC_Ap';

  AfunAssign();

}


#bind _key_Shift_O to O menu Assign afun AuxO_Ap
sub _key_Shift_O {

  $sPar1 = 'AuxO_Ap';

  AfunAssign();

}


#bind _key_Shift_H to H menu Assign afun Atv_Ap
sub _key_Shift_H {

  $sPar1 = 'Atv_Ap';

  AfunAssign();

}


#bind _key_Shift_J to J menu Assign afun AtvV_Ap
sub _key_Shift_J {

  $sPar1 = 'AtvV_Ap';

  AfunAssign();

}


#bind _key_Shift_Z to Z menu Assign afun AuxZ_Ap
sub _key_Shift_Z {

  $sPar1 = 'AuxZ_Ap';

  AfunAssign();

}


#bind _key_Shift_Y to Y menu Assign afun AuxY_Ap
sub _key_Shift_Y {

  $sPar1 = 'AuxY_Ap';

  AfunAssign();

}


#bind _key_Shift_G to G menu Assign afun AuxG_Ap
sub _key_Shift_G {

  $sPar1 = 'AuxG_Ap';

  AfunAssign();

}


#bind _key_Shift_K to K menu Assign afun AuxK_Ap
sub _key_Shift_K {

  $sPar1 = 'AuxK_Ap';

  AfunAssign();

}


#bind _key_Shift_X to X menu Assign afun AuxX_Ap
sub _key_Shift_X {

  $sPar1 = 'AuxX_Ap';

  AfunAssign();

}


#bind _key_Shift_E to E menu Assign afun ExD_Ap
sub _key_Shift_E {

  $sPar1 = 'ExD_Ap';

  AfunAssign();

}


#bind _key_Ctrl_Shift_Q to Ctrl+Q menu Assign afun Pred_Pa
sub _key_Ctrl_Shift_Q {

  $sPar1 = 'Pred_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_N to Ctrl+N menu Assign afun Pnom_Pa
sub _key_Ctrl_Shift_N {

  $sPar1 = 'Pnom_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_V to Ctrl+V menu Assign afun AuxV_Pa
sub _key_Ctrl_Shift_V {

  $sPar1 = 'AuxV_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_S to Ctrl+S menu Assign afun Sb_Pa
sub _key_Ctrl_Shift_S {

  $sPar1 = 'Sb_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_B to Ctrl+B menu Assign afun Obj_Pa
sub _key_Ctrl_Shift_B {

  $sPar1 = 'Obj_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_A to Ctrl+A menu Assign afun Atr_Pa
sub _key_Ctrl_Shift_A {

  $sPar1 = 'Atr_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_D to Ctrl+D menu Assign afun Adv_Pa
sub _key_Ctrl_Shift_D {

  $sPar1 = 'Adv_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_I to Ctrl+I menu Assign afun Coord_Pa
sub _key_Ctrl_Shift_I {

  $sPar1 = 'Coord_Pa';

  DepSuffix();

}


#bind _key_Ctrl_Shift_T to Ctrl+T menu Assign afun AuxT_Pa
sub _key_Ctrl_Shift_T {

  $sPar1 = 'AuxT_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_R to Ctrl+R menu Assign afun AuxR_Pa
sub _key_Ctrl_Shift_R {

  $sPar1 = 'AuxR_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_P to Ctrl+P menu Assign afun AuxP_Pa
sub _key_Ctrl_Shift_P {

  $sPar1 = 'AuxP_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_U to Ctrl+U menu Assign afun Apos_Pa
sub _key_Ctrl_Shift_U {

  $sPar1 = 'Apos_Pa';

  DepSuffix();

}


#bind _key_Ctrl_Shift_C to Ctrl+C menu Assign afun AuxC_Pa
sub _key_Ctrl_Shift_C {

  $sPar1 = 'AuxC_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_O to Ctrl+O menu Assign afun AuxO_Pa
sub _key_Ctrl_Shift_O {

  $sPar1 = 'AuxO_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_H to Ctrl+H menu Assign afun Atv_Pa
sub _key_Ctrl_Shift_H {

  $sPar1 = 'Atv_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_J to Ctrl+J menu Assign afun AtvV_Pa
sub _key_Ctrl_Shift_J {

  $sPar1 = 'AtvV_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_Z to Ctrl+Z menu Assign afun AuxZ_Pa
sub _key_Ctrl_Shift_Z {

  $sPar1 = 'AuxZ_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_Y to Ctrl+Y menu Assign afun AuxY_Pa
sub _key_Ctrl_Shift_Y {

  $sPar1 = 'AuxY_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_G to Ctrl+G menu Assign afun AuxG_Pa
sub _key_Ctrl_Shift_G {

  $sPar1 = 'AuxG_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_K to Ctrl+K menu Assign afun AuxK_Pa
sub _key_Ctrl_Shift_K {

  $sPar1 = 'AuxK_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_X to Ctrl+X menu Assign afun AuxX_Pa
sub _key_Ctrl_Shift_X {

  $sPar1 = 'AuxX_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_E to Ctrl+E menu Assign afun ExD_Pa
sub _key_Ctrl_Shift_E {

  $sPar1 = 'ExD_Pa';

  AfunAssign();

}


#bind _key_F9 to F9 menu Assign afun ExD_Pa
sub _key_F9 {

  $sPar1 = 'ExD_Pa';

  AfunAssign();

}


#bind _key_Shift_F9 to Shift+F9 menu Assign afun ExD_Pa
sub _key_Shift_F9 {

  $sPar1 = 'ExD_Pa';

  AfunAssign();

}


#bind _key_Ctrl_F9 to Ctrl+F9 menu Assign afun ExD_Pa
sub _key_Ctrl_F9 {

  $sPar1 = 'ExD_Pa';

  AfunAssign();

}


#bind _key_Ctrl_Shift_F9 to Ctrl+Shift+F9 menu Assign afun ExD_Pa
sub _key_Ctrl_Shift_F9 {

  $sPar1 = 'ExD_Pa';

  AfunAssign();

}


#bind _key_Ctrl_F11 to Ctrl+F11 menu Assign afun Coord
sub _key_Ctrl_F11 {

  $sPar1 = 'Coord';

  AfunAssign();

}


#bind _key_Shift_F11 to Shift+F11 menu Assign afun Apos
sub _key_Shift_F11 {

  $sPar1 = 'Apos';

  AfunAssign();

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


#bind _key_Ctrl_Shift_F8 to Ctrl+Shift+F8
sub _key_Ctrl_Shift_F8 {

  $_CatchError = "0";

  AllUndefAssign();

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


#bind _key_Ctrl_Shift_F5 to Ctrl+Shift+F5
sub _key_Ctrl_Shift_F5 {

  $_CatchError = "0";

  AllAfunAssign();

}

