package Csts2fs;
use SGMLS;
use Fslib;

#
# TODO:
# -buid TR/AR-tree according to mdesc?
#

#
# TR vs AR (vs M)
#
# $ord = ord (also in TR case)
# $gov = ordorig vs govTR (vs govMD)
#
# "ordorig" :=<g> on TR
# "govTR" := <TRg> on AR
#
# "TR" is @H on TR
# @N: ord on AR, dord on TR
# sentord is @W on TR
# govTR is stored on AR
# ordorig is stored on TR

$gov="ordorig";
$ord="ord";
$sentord="sentord";

$normal_gap='gappost';
$no_node_gap='gappre';

$fill_empty_ord=0;

$fs_tail='(2,3)';
@fs_patterns=('${form}', '${afun}');
$fs_hint="tag:\t".'${tag}';

$next_sentord=0;

%composed_attrs=();

sub assign_TRt {
  my ($s,$data,$machine)=@_;
  $machine = $machine ? "M" : "";
# hajic 2002/04/02
#  - moved - to front of [] expressions
#  - added X to last [] ($9)
#  - swapped $2 and $3
# (based on observations of data only!)

  if ($data=~/([-MIFNX])([-123X])([-SPX])([-SPAX])([-PCRX])([-10X])([-IMCX])([-DBHVSPFX])([.!DM?X])/) {
    my $result;
    if ($1 eq 'M') { $result = 'ANIM' }
    elsif ($1 eq 'I') { $result = 'INAN' }
    elsif ($1 eq 'F') { $result = 'FEM' }
    elsif ($1 eq 'N') {  $result = 'NEUT' }
    elsif ($1 eq '-') {  $result = 'NA' }
    elsif ($1 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','gender'.$machine);

# hajic 2002/04/02
#  - swapped $2 <-> $3 in teh following two switch sections:
    if ($3 eq 'S') { $result = 'SG' }
    elsif ($3 eq 'P') { $result = 'PL' }
    elsif ($3 eq '-') {  $result = 'NA' }
    elsif ($3 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','number'.$machine);

    if ($2 eq '1') { $result = 'POS' }
    elsif ($2 eq '2') { $result = 'COMP' }
    elsif ($2 eq '3') {  $result = 'SUP' }
    elsif ($2 eq '-') {  $result = 'NA' }
    elsif ($2 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','degcmp'.$machine);

    if ($4 eq 'S') { $result = 'SIM' }
    elsif ($4 eq 'P') { $result = 'POST' }
    elsif ($4 eq 'A') {  $result = 'ANT' }
    elsif ($4 eq '-') {  $result = 'NA' }
    elsif ($4 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','tense'.$machine);

    if ($5 eq 'P') { $result = 'PROC' }
    elsif ($5 eq 'C') { $result = 'CPL' }
    elsif ($5 eq 'R') {  $result = 'RES' }
    elsif ($5 eq '-') {  $result = 'NA' }
    elsif ($5 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','aspect'.$machine);

    if ($6 eq '1') { $result = 'IT1' }
    elsif ($6 eq '0') { $result = 'IT0' }
    elsif ($6 eq '-') {  $result = 'NA' }
    elsif ($6 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','iterativeness'.$machine);

    if ($7 eq 'I') { $result = 'IND' }
    elsif ($7 eq 'M') { $result = 'IMP' }
    elsif ($7 eq 'C') {  $result = 'CDN' }
    elsif ($7 eq '-') {  $result = 'NA' }
    elsif ($7 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','verbmod'.$machine);

    if ($8 eq 'D') { $result = 'DECL' }
    elsif ($8 eq 'B') { $result = 'DEB' }
    elsif ($8 eq 'H') {  $result = 'HRT' }
    elsif ($8 eq 'V') {  $result = 'VOL' }
    elsif ($8 eq 'S') {  $result = 'POSS' }
    elsif ($8 eq 'P') {  $result = 'PERM' }
    elsif ($8 eq 'F') {  $result = 'FAC' }
    elsif ($8 eq '-') {  $result = 'NA' }
    elsif ($8 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','deontmod'.$machine);

    if ($9 eq '.') { $result = 'ENUNC' }
    elsif ($9 eq '!') { $result = 'EXCL' }
    elsif ($9 eq 'D') {  $result = 'DESID' }
    elsif ($9 eq 'M') {  $result = 'IMPER' }
    elsif ($9 eq '?') {  $result = 'INTER' }
    elsif ($9 eq '-') {  $result = 'NA' }
    elsif ($9 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','sentmod'.$machine);
  }
}

sub assign_quot_dsp {
  my ($s,$data)=@_;
  if ($data=~/quot/) {
    to_node_attr($s,'QUOT','|','quoted');
  } else {
    to_node_attr($s,'NIL','|','quoted');
  }
  if ($data=~/(dspp|dspi|dsp)/) {
    to_node_attr($s,uc($1),'|','dsp');
  }
}

my %start_tag = (
		 's' => [sub {
			   my ($s)=@_;
			   &make_new_tree(@_);
			   $s->{treeNo}++;
			   $s->{ID2}=$s->{parser}->file;
			   $s->{root}->{form}="#$s->{treeNo}";
			   $s->{root}->{origf}=$s->{root}->{form};
			   $s->{root}->{afun}="AuxS";
			   $s->{root}->{ord}=0;
			   $s->{root}->{sentord}=0;
			   $s->{root}->{dord}=0;
			   $s->{root}->{tag}="Z#-------------";
			   $s->{root}->{lemma}="#";
			   $s->{root}->{trlemma}=$s->{root}->{form};
			   $s->{root}->{TR}="";
			   $s->{root}->{ARhide}='';
			   $s->{root}->{X_hide}='';
			   $s->{root}->{func}="SENT";
			 }],
		 'salt' => [sub {
			      &make_new_tree(@_);
			      $s->{root}->{form}="#$s->{treeNo}.alt";
			      $s->{root}->{origf}=$s->{root}->{form};
			      $s->{root}->{ord}=0;
			      $s->{root}->{dord}=0;
			      $s->{root}->{sentord}=0;
			      $s->{root}->{afun}="AuxS";
			      $s->{root}->{tag}="Z#-------------";
			      $s->{root}->{lemma}="#";
			      $s->{root}->{trlemma}=$s->{root}->{form};
			      $s->{root}->{TR}="";
			      $s->{root}->{ARhide}='';
			      $s->{root}->{X_hide}='';
			      $s->{root}->{func}="SENT";
			    }],
		 'f' => [\&make_new_node,0],
		 'd' => [\&make_new_node,0],
		 'fadd' => [\&make_new_node,1],
		 'TRl' => [sub {
			     my ($s)=@_;
			     # inicialization may be altered to fill
			     # 'hide' here otherwise
			     $s->{node}->{TR}="";
			   }],
		 'MTRl' => [sub {
			      my ($s)=@_;
			      # inicialization may be altered to fill
			      # 'hide' here otherwise (maybe not easy as
			      # these attributes are generated)
			      to_composed_node_attr($s,"","_","","src","MTR");
			    }],
#		 'D' => [\&copy_tag_to,'','<','!GAP'],
		 'D' => [sub {
			   my ($s)=@_;
			   if ($s->{node}) {
			     $s->{node}->{nospace}=1;
			   } else {
			     copy_tag_to(@_,'','<','!GAP');
#			     $s->{following}->{$no_node_gap}.="<D>";
			   }
			 }],

		 'mauth' => [sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to_following_root(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to_following_root(@_,'','<','docmarkup');
		   }
		 }],
		 'mdate' => [sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to_following_root(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to_following_root(@_,'','<','docmarkup');
		   }
		 }],
		 'mdesc' => [sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to_following_root(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to_following_root(@_,'','<','docmarkup');
		   }
		 }],
		 'doc' => [sub {
			   my ($s)=@_;
			   my $e=$s->{parser}->element;
			   $s->{following_root}->{doc}=$e->attribute('file')->value;
			   $s->{following_root}->{docid}=$e->attribute('id')->value;
			 }],
		 'mod' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'txtype' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'genre' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'c' => [sub {
			   shift->{following_root}->{chap}='1';
			 }],
		 'verse' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'med' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'authsex' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'lang' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'transsex' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'srclang' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'temp' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'firsted' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'authname' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'transname' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'opus' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'id' => [\&copy_tag_to_following_root,'','<','docprolog'],
		 'i' => [\&copy_tag_to,'','<','!GAP'],
		 'idioms' => [\&copy_tag_to,'','<','!GAP'],
		 'idiom' => [\&copy_tag_to,'','<','!GAP'],
		 'iref' => [\&copy_tag_to,'','<','!GAP'],
		 );

my %end_tag = (
	       'csts' => [ \&make_last_tree ],
	      );

my %att = (
	   'p n' => [sub { my($s,$data)=@_;
			   $s->{following_root}->{para}=$data;
			 }],
	   'A parallel' => [\&to_node_attr,'|','parallel'],
	   'A paren' => [\&to_node_attr,'|','paren'],
	   'A arabfa' => [\&to_node_attr,'|','arabfa'],
	   'A arabspec' => [\&to_node_attr,'|','arabspec'],
	   'A arabclause' => [\&to_node_attr,'|','arabclause'],
	   'MDt w' => [\&to_composed_node_attr,'_','|','src','wMDt'],
	   'MDl w' => [\&to_composed_node_attr,'_','|','src','wMDl'],
	   'MDA w' => [\&to_composed_node_attr,'_','|','src','wMDA'],
	   'MDA parallel' => [\&to_composed_node_attr,'_','|','src','parallelMD'],
	   'MDA paren' => [\&to_composed_node_attr,'_','|','src','parenMD'],
	   'MDA arabfa' => [\&to_composed_node_attr,'_','|','src','arabfaMD'],
	   'MDA arabspec' => [\&to_composed_node_attr,'_','|','src','arabspecMD'],
	   'MDA arabclause' => [\&to_composed_node_attr,'_','|','src','arabclauseMD'],
	   'MDg w' => [\&to_composed_node_attr,'_','|','src','wMDg'],
	   'wsd s' => [\&to_node_attr,'|','wsds'],
	   'wsd ewn' => [\&to_node_attr,'|','wsdewn'],
	   'wsd ili' => [\&to_node_attr,'|','wsdili'],
	   'wsd iliOffset' => [\&to_node_attr,'|','wsdiliOffset'],
	   's id' => [\&to_attr,'root','|','ID1'],
	   'salt id' => [\&to_attr,'root','|','ID1'],
	   'csts lang' => [\&to_node_attr,'|','cstslang'],
	   'f case' => [\&to_node_attr,'|','formtype'],
	   'f id' => [\&to_node_attr,'','AID'],
	   'd type' => [\&to_node_attr,'|','formtype'],
	   'd id' => [\&to_node_attr,'|','AID'],
	   'w kind' => [\&to_next_node_attr,'|','origfkind'],
	   't w'=> [\&to_node_attr,'|','wt'],
	   'fadd id' => [\&to_node_attr,'','TID'],
	   'fadd del' => [sub {
			    my ($s,$data)=@_;
			    &to_node_attr($s,uc($data),'|','del');
			    &to_node_attr($s,'hide','','ARhide');
			  }],
	   'MTRl quot' => [\&to_composed_node_attr,'_','|','src','quotMTRl'],
	   'TRl quot' => [\&assign_quot_dsp],
	   'coref ref' => [\&to_node_attr,'|','coref'],
	   'coref type' => [\&to_node_attr,'|','cortype'],
	   'TRl status' => [sub {
			    my ($s,$data)=@_;
			    &to_node_attr($s,'hide','','TR')
			      if ($data eq 'hidden');
			  }],
	   'MTRl status' => [sub {
			       my ($s,$data)=@_;
			       &to_composed_node_attr($s,'hide','_','|','src','MTR')
				 if ($data eq 'hidden');
			     }],
	   'TRl origin' => [sub {
			      my ($s,$data)=@_;
			      $data=~s/\s+/|/g;
			      &to_node_attr($s,$data,'','AIDREFS');
			    }],
	   'MTRl origin' => [sub {
			       my ($s,$data)=@_;
			       $data=~s/\s+/|/g;
			       &to_composed_node_attr($s,$data,'_','','src','MAIDREFS');
			     }],
	   'x name' => [sub {
			  my ($s,$data)=@_;
			  $s->{node}->{X_hide}='' if ($data eq 'TNT');
			}]
	  );

my %pcdata = (
	      'source' => [\&to_node_attr,'','cstssource'],
	      'mauth' => [sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_attr(@_,'following_root','','cstsmarkup');
		} else {
		  to_attr(@_,'following_root','','docmarkup');
		}
	      }],
	      'mdate' => [sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_attr(@_,'following_root','','cstsmarkup');
		} else {
		  to_attr(@_,'following_root','','docmarkup');
		}
	      }],
	      'mdesc' => [sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_attr(@_,'following_root','','cstsmarkup');
		} else {
		  to_attr(@_,'following_root','','docmarkup');
		}
	      }],
	      'mod' => [\&to_attr,'following_root','','docprolog'],
	      'txtype' => [\&to_attr,'following_root','','docprolog'],
	      'genre' => [\&to_attr,'following_root','','docprolog'],
	      'verse' => [\&to_attr,'following_root','','docprolog'],
	      'med' => [\&to_attr,'following_root','','docprolog'],
	      'authsex' => [\&to_attr,'following_root','','docprolog'],
	      'lang' => [\&to_attr,'following_root','','docprolog'],
	      'transsex' => [\&to_attr,'following_root','','docprolog'],
	      'srclang' => [\&to_attr,'following_root','','docprolog'],
	      'temp' => [\&to_attr,'following_root','','docprolog'],
	      'firsted' => [\&to_attr,'following_root','','docprolog'],
	      'authname' => [\&to_attr,'following_root','','docprolog'],
	      'transname' => [\&to_attr,'following_root','','docprolog'],
	      'opus' => [\&to_attr,'following_root','','docprolog'],
	      'id' => [\&to_attr,'following_root','','docprolog'],
	      'i' => [\&to_node_attr,'','!GAP'],
	      'iref' => [\&to_node_attr,'','!GAP'],
	      MDt => [\&to_composed_node_attr,'_','|','src','tagMD'],
	      MDl => [\&to_composed_node_attr,'_','|','src','lemmaMD'],
	      MMt => [\&to_composed_node_attr,'_','|','src','tagMM'],
	      MMl => [\&to_composed_node_attr,'_','|','src','lemmaMM'],
	      MTRl => [\&to_composed_node_attr,'_','|','src','trlemmaM'],
	      MDg => [\&to_composed_node_attr,'_','|','src','govMD'],
	      MDA => [\&to_composed_node_attr,'_','|','src','afunMD'],
	      coref => [\&to_node_attr,'|','corlemma'],
	      f => [sub {
		      my ($s,$data)=@_;
		      &to_node_attr(@_,'|','form');
		      unless (exists($s->{node}->{origf})
			      or
			      $s->{node}->{formtype} =~ /^gen$/
			     ) {
			$s->{node}->{origf}=$data;
		      }
		    }],
	      w => [\&to_next_node_attr,'|','origf'],
	      d => [sub {
		      my ($s,$data)=@_;
		      &to_node_attr(@_,'|','form');
		      unless (exists($s->{node}->{origf})
			      or
			      $s->{node}->{formtype} =~ /^gen$/
			     ) {
			$s->{node}->{origf}=$data;
		      }
		    }],
	      P => [\&to_node_attr,'|','punct'],
	      Ct => [\&to_node_attr,'|','alltags'],
	      l => [\&to_node_attr,'|','lemma'],
	      R => [\&to_node_attr,'|','root'],   # should be src-ed by n parent
	      E => [\&to_node_attr,'|','ending'], # should be src-ed by n parent
	      t => [\&to_node_attr,'|','tag'],
	      A => [\&to_node_attr,'|','afun'],
	      TRl => [\&to_node_attr,'|','trlemma'],
	      TRg => [\&to_node_attr,'|','govTR'],
	      T => [\&to_node_attr,'|','func'],
	      Tmo => [\&to_node_attr,'|','memberof'],
              Tpa => [\&to_node_attr,'|','parenthesis'],
              Top => [\&to_node_attr,'|','operand'],
	      grm => [\&to_node_attr,'|','gram'],
	      TRt => [\&assign_TRt,0],
	      tfa => [\&to_node_attr,'|','tfa'],
	      tfr => [\&to_node_attr,'|','dord'],
	      fw => [\&to_node_attr,'|','fw'],
	      phr => [\&to_node_attr,'|','phraseme'],
	      Tframeid => [\&to_node_attr,'|','frameid'],
	      Tframere => [\&to_node_attr,'|','framere'],
	      g => [sub{
		      my ($s,$data)=@_;
		      to_node_attr(@_);
		      $s->{node}->{govTR}=$data if $s->{node}->{govTR} eq "";
		    },'|','ordorig'],
	      r => [\&to_node_attr,'|','ord'],
	      x => [sub {
		      my ($s,$data)=@_;
		      to_composed_node_attr($s,$data,"x_","","name","");
		    }],
	     );

my $headers = <<'EOF';

@csts = (
'@P nospace',
'@P root',
'@P ending',
'@P punct',
'@P alltags',
'@P wt',
'@P origfkind',
'@P formtype',
"\@P $normal_gap",
"\@P $no_node_gap",
'@P para',
'@P cstslang',
'@P cstssource',
'@P cstsmarkup',
'@P chap',
'@P doc',
'@P docid',
'@P docmarkup',
'@P docprolog'
);

@misc = (
 '@P1 warning',
 '@P3 err1',
 '@P3 err2',
'@P reserve1',
'@P reserve2',
'@P reserve3',
'@P reserve4',
'@P reserve5'
);


@minARheader = (
'@P lemma',
'@O lemma',
'@P tag',
'@O tag',
'@P form',
'@O form',
'@P afun',
'@O afun',
'@L1 afun|---|Pred|Pnom|AuxV|Sb|Obj|Atr|Adv|AtrAdv|AdvAtr|Coord|AtrObj|ObjAtr|AtrAtr|AuxT|AuxR|AuxP|Apos|ExD|AuxC|Atv|AtvV|AuxO|AuxZ|AuxY|AuxG|AuxK|AuxX|AuxS|Pred_Co|Pnom_Co|AuxV_Co|Sb_Co|Obj_Co|Atr_Co|Adv_Co|AtrAdv_Co|AdvAtr_Co|Coord_Co|AtrObj_Co|ObjAtr_Co|AtrAtr_Co|AuxT_Co|AuxR_Co|AuxP_Co|Apos_Co|ExD_Co|AuxC_Co|Atv_Co|AtvV_Co|AuxO_Co|AuxZ_Co|AuxY_Co|AuxG_Co|AuxK_Co|AuxX_Co|Pred_Ap|Pnom_Ap|AuxV_Ap|Sb_Ap|Obj_Ap|Atr_Ap|Adv_Ap|AtrAdv_Ap|AdvAtr_Ap|Coord_Ap|AtrObj_Ap|ObjAtr_Ap|AtrAtr_Ap|AuxT_Ap|AuxR_Ap|AuxP_Ap|Apos_Ap|ExD_Ap|AuxC_Ap|Atv_Ap|AtvV_Ap|AuxO_Ap|AuxZ_Ap|AuxY_Ap|AuxG_Ap|AuxK_Ap|AuxX_Ap|Pred_Pa|Pnom_Pa|AuxV_Pa|Sb_Pa|Obj_Pa|Atr_Pa|Adv_Pa|AtrAdv_Pa|AdvAtr_Pa|Coord_Pa|AtrObj_Pa|ObjAtr_Pa|AtrAtr_Pa|AuxT_Pa|AuxR_Pa|AuxP_Pa|Apos_Pa|ExD_Pa|AuxC_Pa|Atv_Pa|AtvV_Pa|AuxO_Pa|AuxZ_Pa|AuxY_Pa|AuxG_Pa|AuxK_Pa|AuxX_Pa|Generated|NA|???',
'@P ID1',
'@P ID2',
'@VA origf',
'@P origf',
'@P afunprev',
'@P semPOS',
'@P tagauto',
'@P lemauto',
'@P AID',
'@P AIDREFS',
);

@minTRheader = (
'@P ordtf',
'@P trlemma',
'@P gender',
'@L gender|---|ANIM|INAN|FEM|NEUT|NA|???',
'@P number',
'@L number|---|SG|PL|NA|???',
'@P degcmp',
'@L degcmp|---|POS|COMP|SUP|NA|???',
'@P tense',
'@L tense|---|SIM|ANT|POST|NA|???',
'@P aspect',
'@L aspect|---|PROC|CPL|RES|NA|???',
'@P iterativeness',
'@L iterativeness|---|IT1|IT0|NA|???',
'@P verbmod',
'@L verbmod|---|IND|IMP|CDN|NA|???',
'@P deontmod',
'@L deontmod|---|DECL|DEB|HRT|VOL|POSS|PERM|FAC|NA|???',
'@P sentmod',
'@L sentmod|---|ENUNC|EXCL|DESID|IMPER|INTER|NA|???',
'@P tfa',
'@L tfa|---|T|F|C|NA|???',
'@P func',
'@L2 func|---|ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|ATT|BEN|CAUS|CNCS|COMPL|CONJ|CONFR|CONTRA|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|DPHR|ETHD|EXT|FPHR|GRAD|HER|ID|INTF|INTT|LOC|MANN|MAT|MEANS|MOD|NA|NORM|OPER|PAR|PARTL|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT|SENT|???',
'@P gram',
'@L gram|---|0|GNEG|DISTR|APPX|GPART|GMULT|VCT|PNREL|DFR|BEF|AFT|JBEF|INTV|WOUT|AGST|MORE|LESS|MULT|RATIO|NIL|blízko|kolem|mezi.1|mezi.2|mimo|na|nad|naproti|pod|pøed|u|uprostøed|v|vedle|za|pøes|uvnitø|NA|???',
'@P memberof',
'@L memberof|---|CO|AP|NIL|???',
'@P fw',
'@P phraseme',
'@P del',
'@L del|---|ELID|ELEX|EXPN|NIL|???',
'@P quoted',
'@L quoted|---|QUOT|NIL|???',
'@P dsp',
'@L dsp|---|DSP|DSPP|DSPI|NIL|???',
'@P coref',
'@P cortype',
'@P corlemma',
'@P commentA',
'@P parenthesis',
'@L parenthesis|---|PA|NIL|???',
'@P operand',
'@L operand|---|OP|NIL|???',
'@P funcauto',
'@P funcprec',
'@P funcaux',
'@P TID',
'@P frameid',
'@P framere'
);

@ARspecial = (
'@N ord',
'@P dord',
'@W sentord',
'@P TR',
'@P govTR',
'@H ARhide',
);

@ARheader = (
 @minARheader,
 @ARspecial,
 @minTRheader,
 @csts,
 @misc
);

@PADTattributes = (
  '@P parallel',
  '@L parallel|Co|Ap|no-parallel',
  '@P paren',
  '@L paren|Pa|no-paren',
  '@P arabfa',
  '@L arabfa|Ca|Exp|Fi|no-fa',
  '@P arabspec',
  '@L arabspec|Ref|Msd|no-spec',
  '@P arabclause',
  '@L arabclause|Pred|PredC|PredE|PredP|Pnom|no-claus'
);

@PADTARheader= (
		(map { my $x=$_; $x=~s/^(\@L[0-9]?\s*afun\|)(.*)$/$1---|Pred|Pnom|Sb|Obj|Atr|Adv|AtrAdv|AdvAtr|Coord|Ref|AtrObj|ObjAtr|AtrAtr|AuxP|Apos|ExD|Atv|Ante|AuxC|AuxO|AuxE|AuxY|AuxM|AuxG|AuxK|AuxX|AuxS|Generated|NA|???/; $x } @minARheader),
		@ARspecial,
		@PADTattributes,
		@minTRheader,
		@csts,
		@misc
	       );

@TRheader = (
 @minARheader,
'@P ord',
'@N dord',
'@W sentord',
'@H TR',
'@P ordorig',
'@P ARhide',
 @minTRheader,
 @csts,
 @misc,
);

EOF

if ($]>=5.008) {
  require Encode;
  $headers=Encode::decode('iso-8859-2',$headers);
  eval('use utf8;'.$headers);
} else {
  eval($headers);
}

%initial_root_values = ();

%initial_node_values = (
#   'afun' => '???',
#   'gender' => '???',
#   'number' => '???',
#   'degcmp' => '???',
#   'tense' => '???',
#   'aspect' => '???',
#   'iterativeness' => '???',
#   'verbmod' => '???',
#   'deontmod' => '???',
#   'sentmod' => '???',
#   'tfa' => '???',
#   'func' => '???',
#   'gram' => '???',
#   'memberof' => '???',
#   'del' => 'NIL',
#   'quoted' => '???',
#   'dsp' => '???',
#   'corsnt' => '???',
#   'antec' => '???',
#   'parenthesis' => '???'
);

$header=\@ARheader;


sub paste_node ($$$) {
  my ($node,$p)=@_;
  my $ordnum = $node->{$ord};
  my $b=$p->{$Fslib::firstson};
  if ($b and $ordnum>$b->{$ord}) {
    $b=$b->{$Fslib::rbrother} while ($b->{$Fslib::rbrother} and $ordnum>$b->{$Fslib::rbrother}->{$ord});
    $node->{$Fslib::rbrother}=$b->{$Fslib::rbrother};
    $b->{$Fslib::rbrother}->{$Fslib::lbrother}=$node if ($b->{$Fslib::rbrother});
    $b->{$Fslib::rbrother}=$node;
    $node->{$Fslib::lbrother}=$b;
  } else {
    $node->{$Fslib::rbrother}=$b;
    $p->{$Fslib::firstson}=$node;
    $node->{$Fslib::lbrother}=0;
    $b->{$Fslib::lbrother}=$node if ($b);
  }
  $node->{$Fslib::parent}=$p;
}


sub build_tree {
  my $root = shift;

  my %ordered=();
  my @unordered=();
  # fill uninitialized node values
  foreach my $t (keys %initial_root_values) {
    $root->{$t} = $initial_root_values{$t} unless exists($root->{$t});
  }
  foreach (@_) {
    if ($_->{$ord} ne "" and !exists($ordered{$_->{$ord}})) {
      $ordered{$_->{$ord}}=$_;
    }
  }
  foreach (@_) {
    next unless $_;
    if ($_->{$gov} ne "" and exists($ordered{$_->{$gov}})) {
      my $parent=$ordered{$_->{$gov}};
      paste_node($_,$parent,{ $ord => ' N'}); # paste using $ord as the numbering attribute
    }
  }
  foreach (reverse @_) {
    if (ref($_) and ! $_->parent) {
      paste_node($_,$root,{ $ord => ' N'}); # paste using $ord as the numbering attribute
    }
  }
  if ($fill_empty_ord) {
    foreach (@_) {
      if ($_->{$ord} eq "") {
	$_->{$ord}=$_->{$sentord};
      }
    }
  }
  unless (ref($root)) {
    print STDERR "No root node\n";
  }
  return defined($root) ? $root : ();
}

sub convert_element_to_string {
  my ($e)=@_;
  my $string="<".$e->name;
  foreach ($e->attribute_names) {
    my $a=$e->attribute($_);
    next if $a->is_implied;
    $string.=' '.$a->name.'="'.$a->value.'"';
  }
  return $string.">";
}

sub to_attr {
  my ($s,$data,$node,$concat,$attr)=@_;
  if ($attr eq '!GAP') {
    $attr = $s->{node} ? $normal_gap : $no_node_gap;
  }
  $s->{$node}->{$attr} =
    exists($s->{$node}->{$attr}) && $s->{$node}->{$attr} ne "" ? 
      $s->{$node}->{$attr}.$concat.$data : $data;
}

sub to_node_attr {
  my ($s,$data,$concat,$attr)=@_;
  $node = ref($s->{node}) ? 'node' : 'following';
  to_attr($s,$data,$node,$concat,$attr);
}

sub to_next_node_attr {
  my ($s,$data,$concat,$attr)=@_;
  $s->{following}->{$attr} =
    exists($s->{following}->{$attr}) && $s->{following}->{$attr} ne "" ? 
      $s->{following}->{$attr}.$concat.$data : $data;
}

sub to_composed_node_attr {
  my ($s,$data,$prefix,$concat,$compose,$attr)=@_;
  $attr.=$prefix.$s->{parser}->element->attribute($compose)->value;
  to_node_attr($s,$data,$concat,$attr);
  $composed_attrs{$attr}=1;
}

sub make_new_node {
  my ($s,$data,$added)=@_;
  # starting a new node
  push @{$s->{nodes}},$s->{node} if ref($s->{node});
  #my $sentord=ref($s->{node}) ? $s->{node}->{sentord}+1 : 0;
  $s->{node} = FSNode->new();
  foreach (keys %initial_node_values) {
    $s->{node}->{$_} = $initial_node_values{$_};
  }
  if ($added) {
    $s->{node}->{sentord}=999;
  } else {
    $s->{node}->{sentord}=$next_sentord;
    $next_sentord++;
  }
  foreach (keys %{$s->{following}}) {
    $s->{node}->{$_} = $s->{following}->{$_};
  }
  $s->{following}={};
}

sub make_new_tree {
  my ($s)=@_;
  # starting a new tree
  $next_sentord=0;
  make_new_node(@_);
  push @{$s->{trees}}, build_tree(@{$s->{nodes}}) if (@{$s->{nodes}});
  $s->{root}=$s->{node};
  foreach (keys %{$s->{following_root}}) {
    $s->{root}->{$_} = $s->{following_root}->{$_};
  }
  $s->{following_root}={};
  @{$s->{nodes}}=();
}

sub make_last_tree {
  my ($s)=@_;
  push @{$s->{nodes}},$s->{node} if ref($s->{node});
  push @{$s->{trees}}, build_tree(@{$s->{nodes}}) if (@{$s->{nodes}});
  print STDERR "Unstored data for following node\n" if (keys(%{$s->{following}}));
  print STDERR "Unstored data for following root\n" if (keys(%{$s->{following_root}}));
  @{$s->{nodes}}=();
}

sub copy_tag_to_following_root {
  my ($s,$data,$concat,$tag,$attr)=@_;
  if ($tag =~/\</) {
    to_attr($s,convert_element_to_string($s->{parser}->element),"following_root",$concat,$attr);
  }
  if ($tag =~/\>/) {
    to_attr($s,"</$data>","following_root",$concat,$attr);
  }
}

sub copy_tag_to {
  my ($s,$data,$concat,$tag,$attr)=@_;
  if ($tag =~/\</) {
    to_node_attr($s,convert_element_to_string($s->{parser}->element),$concat,$attr);
  }
  if ($tag =~/\>/) {
    to_node_attr($s,"</$data>",$concat,$attr);
  }
}

sub read {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

  my $parser=new SGMLS(*$fileref);

  my (%defs,@attlist,$event,@trees,@header);
  my $state = {
	       parser => $parser,
	       event => undef,
	       root => undef,
	       following_root => {},
	       node => undef,
	       following => {},
	       trees => [],
	       nodes => []
	      };

  while ($event = $parser->next_event) {
     $state->{event} = $event;
    if ($event->type eq 'start_element') {
      my $e=$event->data;
      my $n=$e->name;
      if (exists($start_tag{$n})) {
	my ($cb,@args)=@{ $start_tag{$n} };
	&$cb($state,$n,@args);
      }
      foreach ($e->attribute_names) {
	if (exists $att{"$n $_"}) {
	  my ($cb,@args)=@{ $att{"$n $_"} };
	  &$cb($state,$e->attribute($_)->value,@args);
	}
      }
    } elsif ($event->type eq 'end_element') {
      my $e=$event->data;
      my $n=$e->name;

      if (exists($end_tag{$n})) {
	my ($cb,@args)=@{ $end_tag{$n} };
	&$cb($state,$n,@args);
      }
    } elsif ($event->type eq 'cdata') {
      my $data=$event->data;
      my $n=$parser->element->name;

      if (exists($pcdata{$n})) {
	my ($cb,@args)=@{ $pcdata{$n} };
	&$cb($state,$data,@args);
      }
    }
  }

  @header=@{$header};
  foreach (keys %composed_attrs) {
    push @header,"\@P $_";
  }
  $fsfile->changeFS(FSFormat->create(@header));
  $fsfile->changeTail("$fstail\n");
  $fsfile->changeTrees(@{$state->{trees}});
  $fsfile->changePatterns(@fs_patterns);
  $fsfile->changeHint($fs_hint);

  return 1;
}

sub setupTR {
  $gov = "govTR";
  $header = \@TRheader;
  $initial_node_values{TR}='hide';
  $initial_root_values{reserve1}='TR_TREE';
  $fs_tail='(2,3)';
  @fs_patterns=();		# proper patterns added by TrEd's hook
  $fs_hint=undef;

}

sub setupAR {
  $gov="ordorig";
  $header = \@ARheader;
  delete $initial_node_values{TR};
  delete $initial_root_values{reserve1};
  $fs_tail='(2,3)';
  @fs_patterns=('${form}', '${afun}');
  $fs_hint="tag:\t\${tag}\nlemma:\t\${lemma}";
}

sub setupPADTAR {
  setupAR();
  $header = \@PADTARheader;
  @fs_patterns=('${form}',
		'#{custom1}<? join "_", map { "\${$_}" }'.
                '   grep { $this->{$_}=~/./ && $this->{$_}!~/^no-/ }'.
	        '   qw(afun parallel paren arabfa arabspec arabclause) ?>');
  $fs_hint="tag:\t\${tag}\nlemma:\t\${lemma}\ngloss:\t\${x_gloss}\ncommentA:\t\${commentA}";
}


sub setupSpec {
  $gov = $_[0];
  $header = [ (grep !/\@[NH]/,@TRheader), '@N '.$_[1], '@H X_hide'];
  $initial_node_values{X_hide}='hide';
}

1;
