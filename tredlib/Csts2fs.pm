package Csts2fs;

use SGMLS;
use Fslib;

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

$normal_gap='gappost';
$no_node_gap='gappre';

%composed_attrs=();

sub assign_TRt {
  my ($s,$data,$machine)=@_;
  $machine = $machine ? "M" : "";
  if ($data=~/([MIFN-X])([SP-X])([123-X])([SPA-X])([PCR-X])([10-X])([IMC-X])([DBHVSPF-X])([.!DM?])/) {
    my $result;
    if ($1 eq 'M') { $result = 'ANIM' }
    elsif ($1 eq 'I') { $result = 'INAN' }
    elsif ($1 eq 'F') { $result = 'FEM' }
    elsif ($1 eq 'N') {  $result = 'NEUT' }
    elsif ($1 eq '-') {  $result = 'NA' }
    elsif ($1 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','gender'.$machine);

    if ($2 eq 'S') { $result = 'SG' }
    elsif ($2 eq 'P') { $result = 'PL' }
    elsif ($2 eq '-') {  $result = 'NA' }
    elsif ($2 eq 'X') {  $result = '???' }
    to_node_attr($s,$result,'|','number'.$machine);

    if ($3 eq '1') { $result = 'POS' }
    elsif ($3 eq '2') { $result = 'COMP' }
    elsif ($3 eq '3') {  $result = 'SUP' }
    elsif ($3 eq '-') {  $result = 'NA' }
    elsif ($3 eq 'X') {  $result = '???' }
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
			   $s->{root}->{tag}="Z#-------------";
			   $s->{root}->{trlemma}=$s->{root}->{form};
			   $s->{root}->{func}=$s->{root}->{sent};
			 }],
		 'salt' => [sub {
			      &make_new_tree(@_);
			      $s->{root}->{form}="#$s->{treeNo}.alt";
			      $s->{root}->{origf}=$s->{root}->{form};
			      $s->{root}->{ord}=0;
			      $s->{root}->{afun}="AuxS";
			      $s->{root}->{tag}="Z#-------------";
			      $s->{root}->{trlemma}=$s->{root}->{form};
			      $s->{root}->{func}=$s->{root}->{sent};
			    }],
		 'f' => [\&make_new_node],
		 'd' => [\&make_new_node],
		 'fadd' => [\&make_new_node],
		 'D' => [\&copy_tag_to,'','<','!GAP'],
#		 'h' => [\&copy_tag_to,'','<','!GAP'],
#		 'source' => [\&copy_tag_to,'','<','cstsprolog'],
#  		 'markup' => sub {
#  		   my ($s)=@_;
#  		   if ($s->{parser}->element->in('h')) {
#  		     copy_tag_to(@_,'','<','cstsprolog');
#  		   } else {
#  		     copy_tag_to(@_,'','<','docprolog');
#  		   }
#  		 },
		 'mauth' => sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to(@_,'','<','docmarkup');
		   }
		 },
		 'mdate' => sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to(@_,'','<','docmarkup');
		   }
		 },
		 'mdesc' => sub {
		   my ($s)=@_;
		   if ($s->{parser}->element->parent->in('h')) {
		     copy_tag_to(@_,'','<','cstsmarkup');
		   } else {
		     copy_tag_to(@_,'','<','docmarkup');
		   }
		 },
#		 'doc' => [\&copy_tag_to,'','<','cstsprolog'],
		 'doc' => [sub {
			   my ($s)=@_;
			   my $e=$s->{parser}->element;
			   $s->{following_root}->{doc}=$e->attribute('file')->value;
			   $s->{following_root}->{docid}=$e->attribute('id')->value;
			 }],
#		 'a' => [\&copy_tag_to,'','<','docprolog'],
		 'mod' => [\&copy_tag_to,'','<','docprolog'],
		 'txtype' => [\&copy_tag_to,'','<','docprolog'],
		 'genre' => [\&copy_tag_to,'','<','docprolog'],
		 'c' => [sub {
			   shift->{following_root}->{chap}='1';
			 }],
		 'verse' => [\&copy_tag_to,'','<','docprolog'],
		 'med' => [\&copy_tag_to,'','<','docprolog'],
		 'authsex' => [\&copy_tag_to,'','<','docprolog'],
		 'lang' => [\&copy_tag_to,'','<','docprolog'],
		 'transsex' => [\&copy_tag_to,'','<','docprolog'],
		 'srclang' => [\&copy_tag_to,'','<','docprolog'],
		 'temp' => [\&copy_tag_to,'','<','docprolog'],
		 'firsted' => [\&copy_tag_to,'','<','docprolog'],
		 'authname' => [\&copy_tag_to,'','<','docprolog'],
		 'transname' => [\&copy_tag_to,'','<','docprolog'],
		 'opus' => [\&copy_tag_to,'','<','docprolog'],
		 'id' => [\&copy_tag_to,'','<','docprolog'],
		 'i' => [\&copy_tag_to,'','<','!GAP'],
		 'idioms' => [\&copy_tag_to,'','<','!GAP'],
		 'idiom' => [\&copy_tag_to,'','<','!GAP'],
		 'iref' => [\&copy_tag_to,'','<','!GAP']
		 );

my %end_tag = (
	       'csts' => [ \&make_last_tree ],
#	       'source' => [\&copy_tag_to,'','>','cstsprolog'],
#	       'h' => [\&copy_tag_to,'','>','cstsprolog'],
#  	       'markup' => sub {
#  		 my ($s)=@_;
#  		 if ($s->{parser}->element->in('h')) {
#  		   copy_tag_to(@_,'','>','cstsprolog');
#  		 } else {
#  		   copy_tag_to(@_,'','>','docprolog');
#  		 }
#  	       },
#	       'a' => [\&copy_tag_to,'','>','docprolog'],
	      );

my %att = (
	   'p n' => [sub { my($s,$data)=@_;
			   $s->{following_root}->{para}=$data;
			 }],
	   'MDt w' => [\&to_composed_node_attr,'_','|','src','wMDt'],
	   'MDl w' => [\&to_composed_node_attr,'_','|','src','wMDl'],
	   'MDA w' => [\&to_composed_node_attr,'_','|','src','wMDA'],
	   'MDg w' => [\&to_composed_node_attr,'_','|','src','wMDg'],
	   's id' => [\&to_attr,'root','|','ID1'],
	   'salt id' => [\&to_attr,'root','|','ID1'],
	   'csts lang' => [\&to_node_attr,'|','cstslang'],
	   'f case' => [\&to_node_attr,'|','formtype'],
	   'w kind' => [\&to_next_node_attr,'|','origfkind'],
	   't w'=> [\&to_node_attr,'|','wt'],
	   'fadd del' => [\&to_node_attr,'|','del'],
	   'TRl quot' => [\&assign_quot_dsp],
	   'cors rel' => [\&to_node_attr,'|','corsrel']
	  );

my %pcdata = (
	      'source' => [\&to_node_attr,'','cstssource'],
	      'mauth' => sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_node_attr(@_,'','cstsprolog');
		} else {
		  to_node_attr(@_,'','docprolog');
		}
	      },
	      'mdate' => sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_node_attr(@_,'','cstsprolog');
		} else {
		  to_node_attr(@_,'','docprolog');
		}
	      },
	      'mdesc' => sub {
		my ($s)=@_;
		if ($s->{parser}->element->parent->in('h')) {
		  to_node_attr(@_,'','cstsprolog');
		} else {
		  to_node_attr(@_,'','docprolog');
		}
	      },
	      'mod' => [\&to_node_attr,'','docprolog'],
	      'txtype' => [\&to_node_attr,'','docprolog'],
	      'genre' => [\&to_node_attr,'','docprolog'],
	      'verse' => [\&to_node_attr,'','docprolog'],
	      'med' => [\&to_node_attr,'','docprolog'],
	      'authsex' => [\&to_node_attr,'','docprolog'],
	      'lang' => [\&to_node_attr,'','docprolog'],
	      'transsex' => [\&to_node_attr,'','docprolog'],
	      'srclang' => [\&to_node_attr,'','docprolog'],
	      'temp' => [\&to_node_attr,'','docprolog'],
	      'firsted' => [\&to_node_attr,'','docprolog'],
	      'authname' => [\&to_node_attr,'','docprolog'],
	      'transname' => [\&to_node_attr,'','docprolog'],
	      'opus' => [\&to_node_attr,'','docprolog'],
	      'id' => [\&to_node_attr,'','docprolog'],
	      'i' => [\&to_node_attr,'','!GAP'],
	      'iref' => [\&to_node_attr,'','!GAP'],

	      MDt => [\&to_composed_node_attr,'_','|','src','tagMD'],
	      MDl => [\&to_composed_node_attr,'_','|','src','lemmaMD'],
	      MMt => [\&to_composed_node_attr,'_','|','src','tagMM'],
	      MMl => [\&to_composed_node_attr,'_','|','src','lemmaMM'],
	      MTRl => [\&to_composed_node_attr,'_','|','src','trlemmaM'],
	      MDg => [\&to_composed_node_attr,'_','|','src','govMD'],
	      MDA => [\&to_composed_node_attr,'_','|','src','afunMD'],
	      f => [sub {
		      my ($s,$data)=@_;
		      &to_node_attr(@_,'|','form');
		      $s->{node}->{origf}=$data
			unless (exists($s->{node}->{origf}));
		    }],
	      w => [\&to_next_node_attr,'|','origf'],
	      d => [\&to_node_attr,'|','form'],
	      P => [\&to_node_attr,'|','punct'],
	      Ct => [\&to_node_attr,'|','alltags'],
	      l => [\&to_node_attr,'|','lemma'],
	      R => [\&to_node_attr,'|','root'],   # should be src-ed by n parent
	      E => [\&to_node_attr,'|','ending'], # should be src-ed by n parent
	      t => [\&to_node_attr,'|','tag'],
	      A => [\&to_node_attr,'|','afun'],
	      TRl => [\&to_node_attr,'|','trlemmaM'],
	      TRg => [\&to_node_attr,'|','govTR'],
	      T => [\&to_node_attr,'|','func'],
	      grm => [\&to_node_attr,'|','gram'],
	      TRt => [\&assign_TRt,0],
	      tfa => [\&to_node_attr,'|','tfa'],
	      tfr => [\&to_node_attr,'|','dord'],
	      fw => [\&to_node_attr,'|','fw'],
	      phr => [\&to_node_attr,'|','phraseme'],
	      corl => [\&to_node_attr,'|','corl'],	# which attr?
	      corT => [\&to_node_attr,'|','corT'],	# which attr?
	      corr => [\&to_node_attr,'|','corr'],	# which attr?
	      cors => [\&to_node_attr,'|','cors'],	# which attr?
	      g => [\&to_node_attr,'|','ordorig'],
	      r => [\&to_node_attr,'|','ord']
	     );

@header = (
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
'@P ordtf',
'@P afunprev',
'@P1 warning',
'@P3 err1',
'@P3 err2',
'@P semPOS',
'@P tagauto',
'@P lemauto',
'@P ordorig',
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
'@L2 func|---|ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|ATT|BEN|CAUS|CNCS|COMPL|CONJ|CONFR|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|DPHR|ETHD|EXT|EV|FPHR|GRAD|HER|ID|INTF|INTT|LOC|MANN|MAT|MEANS|MOD|NA|NORM|PAR|PARTL|PN|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT|SENT|???',
'@P gram',
'@L gram|---|0|GNEG|DISTR|APPX|GPART|GMULT|VCT|PNREL|DFR|BEF|AFT|JBEF|INTV|WOUT|AGST|MORE|LESS|NIL|blízko|kolem|mezi.1|mezi.2|mimo|na|nad|naproti|pod|pøed|u|uprostøed|v|vedle|za|pøes|uvnitø|NA|???',
'@P memberof',
'@L memberof|---|CO|AP|PA|NIL|???',
'@P fw',
'@P phraseme',
'@P del',
'@L del|---|ELID|ELEX|EXPN|NIL|???',
'@P quoted',
'@L quoted|---|QUOT|NIL|???',
'@P dsp',
'@L dsp|---|DSP|DSPP|DSPI|NIL|???',
'@P coref',
'@P cornum',
'@P corsnt',
'@L corsnt|---|PREV1|PREV2|PREV3|PREV4|PREV5|PREV6|PREV7|NIL|???',
'@P antec',
'@L antec|---|ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|ATT|BEN|CAUS|CNCS|COMPL|CONJ|CONFR|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|DPHR|ETHD|EXT|EV|FPHR|GRAD|HER|ID|INTF|INTT|LOC|MANN|MAT|MEANS|MOD|NA|NORM|PAR|PARTL|PN|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT|SENT|???',
'@P commentA',
'@P parenthesis',
'@L parenthesis|---|PA|NIL|???',
'@P funcauto',
'@P funcprec',
'@P funcaux',
'@P reserve1',
'@P reserve2',
'@P reserve3',
'@P reserve4',
'@P reserve5',
'@P dord',
'@N ord',
'@P sentord',
#'@H TR',
'@P origfkind',
'@P formtype',
"\@P $normal_gap",
"\@P $no_node_gap",
'@P cstslang',
'@P cstssource',
'@P cstsmarkup',
'@P chap',
'@P doc',
'@P docid',
'@P docmarkup',
'@P docprolog'
);


##
## root should be treated specially, (stored in state)
## as the first node created. It should be shifted out of @_ in build_tree,
## as it is the first node there. (It bears special information)
## superelements of s (such as c and p) should be kept here,
## i.e. if there is a p or c, then it should be stored in the root of
## the tree.
## End tags of c are required but may be deduced from context.
## This means that they should not be stored. But whenever new <c>
## is started, the preceding <c> should be closed. 
## End tags for p should be ignored and omitted in the backward conversion.
##
## c --> @P chap (bckw: newchap non-empty means yes)
## p --> @P para  (bckw: if newpar is non-empty, the value is taken as the attribute n for element p)


### here ordered should be made a hash table for <r> is a general id,
### not necessarily number

sub build_tree {
  my $root = shift;

  my %ordered=();
  my @unordered=();
  foreach (@_) {
    if (!exists($ordered{$_->{$ord}})) {
      $ordered{$_->{$ord}}=$_;
    } else {
      push @unordered,$_;
    }
  }
  foreach (@_) {
    next unless $_;
    if (exists($ordered{$_->{$gov}})) {
      my $parent=$ordered{$_->{$gov}};
      Paste($_,$parent,{ $ord => ' N'}); # paste using $ord as the numbering attribute
    }
  }

  foreach (@_) {
    if ($_ and !$_->parent) {
      Paste($_,$root,{ $ord => ' N'}); # paste using $ord as the numbering attribute
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
  to_attr($s,$data,ref($s->{node}) ? 'node' : 'following',$concat,$attr);
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
  my ($s)=@_;
  # starting a new node
  push @{$s->{nodes}},$s->{node} if ref($s->{node});
  $s->{node} = FSNode->new();
  foreach (keys %{$s->{following}}) {
    $s->{node}->{$_} = $s->{following}->{$_};
  }
  $s->{following}={};
}

sub make_new_tree {
  my ($s)=@_;
  # starting a new tree
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

  my (%defs,@attlist,$event,@trees);
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

  @attlist=();

  my @attlist=();
  foreach (keys %composed_attrs) {
    push @header,"\@P $_";
  }
  my %defs=ReadAttribs(\@header,\@attlist);
  $fsformat = new FSFormat({%defs},
			   [@attlist], undef);
  $fsfile->changeFS($fsformat);
  $fsfile->changeTrees(@{$state->{trees}});
  $fsfile->changePatterns('${form}', '${afun}');
  $fsfile->changeHint("tag:\t".'${tag}');

  return 1;
}

1;
