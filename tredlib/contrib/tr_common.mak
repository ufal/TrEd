## -*- cperl -*-
#
# $Id$ '
#
# Copyright (c) 2001-2003 by Petr Pajas <pajas@matfyz.cz>
#
## This file contains and imports most macros
## needed for Tectogrammatical annotation
##
## It is a base for other macro packages like tr.mak
## or tr_anot_main.mak which are used for various purposes


#encoding iso-8859-2

#include <contrib/AFA.mak>

#include <contrib/ValLex/chooser.mak>
#include <contrib/ValLex/adverb.mak>

#bind OpenEditor to Ctrl+Shift+Return menu Zobraz valenèní slovník

#bind choose_frame_or_advfunc to Ctrl+Return menu Vyber ramec pro sloveso, funktor pro adverbium
#bind choose_frame_or_advfunc to F1 menu Vyber ramec pro sloveso, funktor pro adverbium

#bind prev_file_choose_frame to Ctrl+KP_Subtract
#bind prev_file_choose_frame to Ctrl+minus Prejdi na predchozi soubor a obnov vyber ramce
#bind next_file_choose_frame to Ctrl+KP_Add
#bind next_file_choose_frame to Ctrl+plus Prejdi na dalsi soubor a obnov vyber ramce

@special_trlemmas=
    #disp  trlemma gender number
    #
    # Predelat na entity: &Comma; &Colon; atd.
    #
    #  display         trlemma      gender  number  func
    ([ 'Comma',        '&Comma;',   '???',  '???', 'CONJ'   ],
     [ 'Colon',        '&Colon;',   '???',  '???', 'CONJ'   ],
     [ 'Hyphen',       '&Hyphen;',    '???',  '???', 'CONJ'   ],
     [ 'Lpar',         '&Lpar;',    '???',  '???', '???'    ],
     [ 'Forn',         '&Forn;',    '???',  '???', '???'    ],
     [ 'Rcp',          '&Rcp;',     '???',  '???', 'PAT'    ],
     [ 'Neg',          '&Neg;',     '???',  '???', 'RHEM'    ],
     [ 'Cor',          '&Cor;',     '???',  '???', '???'    ],
     [ 'Emp',          '&Emp;',     '???',  '???', '???'    ],
     [ 'EmpNoun',      '&EmpNoun;', '???',  '???', '???'    ],
     [ 'Gen',          '&Gen;',     '???',  '???', '???'    ],
     [ 'Idph',         '&Idph;',    '???',  '???', '???'    ],
     [ 'Unsp',         '&Unsp;',    '???',  '???', '???'    ],
     [ 'QCor',         '&QCor;',    '???',  '???', 'ACT'    ],
     [ 'v¹echen',       'v¹echen',    '???',  '???', 'ACT'   ],
     [ 'stejnì',       'stejnì',    '???',  '???', 'MANN'   ],
     [ 'stejný',       'stejný',    '???',  '???', 'RSTR'   ],
     [ '???',          '???',       '???',  '???', '???'    ],
     [ 'já',           'já',        '???',  'SG',  '???'    ],
     [ 'ty',           'ty',        '???',  'SG',  '???'    ],
     [ 'on-¾iv.',      'on',        'ANIM', 'SG',  '???'    ],
     [ 'on-ne¾iv.',    'on',        'INAN', 'SG',  '???'    ],
     [ 'ona',          'on',        'FEM',  'SG',  '???'    ],
     [ 'ono',          'on',        'NEUT', 'SG',  '???'    ],
     [ 'my',           'my',        '???',  'PL',  '???'    ],
     [ 'vy',           'vy',        '???',  'PL',  '???'    ],
     [ 'oni-¾iv.',     'on',        'ANIM', 'PL',  '???'    ],
     [ 'ony-ne¾iv',    'on',        'INAN', 'PL',  '???'    ],
     [ 'ony-¾en.',     'on',        'FEM',  'PL',  '???'    ],
     [ 'ona-pl-neut.', 'on',        'NEUT', 'PL',  '???'    ],
     [ 'ten',          'ten',       '???',  '???', '???'    ],
     [ 'tak',          'tak',       '???',  '???', 'EXT'    ],
     [ 'takový',       'takový',    '???',  '???', 'PAT'    ],
    );

@special_where=
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

@special_when=
    (
     ['kdy', 'kdy', 'TWHEN'],
     ['odkdy', 'kdy', 'TSIN'],
     ['dokdy', 'kdy', 'TTILL'],
     ['jak dlouho', 'kdy', 'THL'],
     ['na jak dlouho', 'kdy','TFHL'],
     ['jak èasto', 'kdy', 'THO'],
     ['bìhem', 'kdy', 'TPAR'],
     ['ze kdy', 'kdy', 'TFRWH'],
     ['na kdy', 'kdy', 'TOWH']
    );


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

sub prev_file_choose_frame {
  PrevFile();
  if ($this->{rframeid} ne "") {
    local $frameid_attr="rframeid";
    local $framere_attr="rframere";
    ChooseFrame() if ($this->{tag}=~/^[VAN]/);
  } else {
    ChooseFrame() if ($this->{tag}=~/^[VAN]/);
  }
}

sub next_file_choose_frame {
  NextFile();
  if ($this->{rframeid} ne "") {
    local $frameid_attr="rframeid";
    local $framere_attr="rframere";
    ChooseFrame() if ($this->{tag}=~/^[VAN]/);
  } else {
    ChooseFrame() if ($this->{tag}=~/^[VAN]/);
  }
}

sub upgrade_file {
  # Add new functor OPER if not present in header
  my $defs=$grp->{FSFile}->FS->defs;
  if (exists($defs->{func}) and $defs->{func} !~ /OPER/) {
    $defs->{func}=~s/(NORM)/NORM|OPER/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /CPHR/) {
    $defs->{func}=~s/(DPHR)/CPHR|DPHR/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /\|CM\|/) {
    $defs->{func}=~s/(CPHR)/CM|CPHR/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /AUTH/) {
    $defs->{func}=~s/(APPS)/APPS|AUTH/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /CONTRA/) {
    $defs->{func}=~s/(CONFR)/CONFR|CONTRA/;
  }
  if (exists($defs->{antec}) and $defs->{func} !~ /OPER/) {
    $defs->{antec}=~s/(NORM)/NORM|OPER/;
  }
  if (exists($defs->{func}) and $defs->{func} !~ /CONTRD/) {
    $defs->{func}=~s/(CONTRA)/CONTRA|CONTRD/;
  }
  if (exists($defs->{memberof}) and $defs->{memberof} =~ /CO\|AP\|PA/) {
    $defs->{memberof}=~s/CO\|AP\|PA/CO|AP/;
  }
  if (exists($defs->{gram}) and $defs->{gram} !~ /MULT\|RATIO/) {
    $defs->{gram}=~s/LESS/LESS|MULT|RATIO/;
  }
  if (exists($defs->{gram}) and $defs->{gram} !~ /\|ADD\|SUBTR\|ORDER\|/) {
    $defs->{func}=~s/(\|NIL\|)/\|ADD\|SUBTR\|ORDER\|NIL\|/;
  }
  unless (exists($defs->{parenthesis})) {
    AppendFSHeader('@P parenthesis',
		   '@L parenthesis|---|PA|NIL|???');
  }
  unless (exists($defs->{operand})) {
    AppendFSHeader('@P operand',
		   '@L operand|---|OP|NIL|???');
  }
  unless (exists($defs->{argnum})) {
    AppendFSHeader('@P argnum');
  }
  unless (exists($defs->{state})) {
    AppendFSHeader('@P state',
		   '@L state|---|NA|NIL|ST|???');
  }
  eval { Coref::update_coref_file(); 1; } || upgrade_file_to_tid_aidrefs();
}

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  stdout("Using standard patterns\n");
  SetDisplayAttrs('<? "#{red}" if $${commentA} ne "" ?>${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?><? "$${_light}"if$${_light}and$${_light}ne"_LIGHT_" ?>',
		  '<?$${funcaux} if $${funcaux}=~/\#/?>${func}<? "_#{custom2}\${memberof}" if $${memberof} =~ /CO|AP|PA/ ?><? "_#{custom2}\${operand}" if $${operand} eq "OP" ?><? "#{custom2}-\${parenthesis}" if $${parenthesis} eq "PA" ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>',
		  'text:<? "#{-background:cyan}" if $${_light}eq"_LIGHT_" ?><? "#{-foreground:green}#{-underline:1}" if $${NG_matching_node} eq "true" ?><? "#{-tag:NG_TOP}#{-tag:LEMMA_".$${trlemma}."}" if ($${NG_matching_node} eq "true" and $${NG_matching_edge} ne "true") ?>${origf}',
		  'style:<? "#{Line-fill:green}" if $${NG_matching_edge} eq "true" ?>',
                  'style:<? "#{Node-addwidth:7}#{Node-addheight:7}#{Oval-fill:cyan}" if $${_light}eq"_LIGHT_" ?>',
		  'style:<? "#{Oval-fill:green}" if $${NG_matching_node} eq "true" ?>'
		 );
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

  my @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      $node->{func} eq $_->[2]
    }  @special_where;
  @selected=grep { 
    $node->{trlemma} eq $_->[1]
  }  @special_where unless (@selected>0);
  if (@selected>0) {
    @selected=($selected[0]->[0]);
  }
  else {
    @selected=($node->{trlemma});
  }
  if (main::selectValuesDialog($grp->{framegroup},$atr,
			   [ map { $_->[0] } @special_where ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep { $_->[0] eq $selected[0] } @special_where);

    $node->{trlemma}=$vals->[1];
    $node->{func}=$vals->[2];
    return 1;
  }
  return 0;
}

sub QueryKdy {
  my $node=shift;
  my @selected=grep { 
    $node->{trlemma} eq $_->[1] and $node->{func} eq $_->[2]
    }  @special_when;
  @selected=grep { 
    $node->{trlemma} eq $_->[1]
  }  @special_when unless (@selected>0);
  if (@selected>0) {
    @selected=($selected[0]->[0]);
  }
  else {
    @selected=($node->{trlemma});
  }
  if (main::selectValuesDialog($grp->{framegroup},$atr,
			   [ map { $_->[0] } @special_when ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep { $_->[0] eq $selected[0] } @special_when);

    $node->{trlemma}=$vals->[1];
    $node->{func}=$vals->[2];
    return 1;
  }
  return 0;
}


sub QueryTrlemma {
  my ($node,$assign_func)=@_;
  my @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      $node->{gender} eq $_->[2] and
	$node->{number} eq $_->[3]
      }  @special_trlemmas;
  @selected=grep { 
    $node->{trlemma} eq $_->[1] and 
      ($node->{gender} eq $_->[2] or
       $node->{number} eq $_->[3])
    }  @special_trlemmas unless (@selected>0);
  if (@selected>0) {
    @selected=($selected[0]->[0]);
  }
  else {
    @selected=($node->{trlemma});
  }
  if (main::selectValuesDialog($grp->{framegroup},$atr,
			   [ map { &main::encode($_->[0]) } @special_trlemmas ],
			       \@selected,0,undef,1)) {

    my ($vals)=(grep {$_->[0] eq &main::decode($selected[0])} @special_trlemmas);

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
  if ($atr eq 'trlemma' and $node->{ord}=~/\./ and $node->{tag} !~ /......./) {
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
  if ($atr!~/^(?:func|commentA|reltype|memberof|operand|aspect|err1|parenthesis)$/) {
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
    ToplevelFrame()->messageBox
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
    ChangingFile(1);
  }
}


## add few custom bindings to predefined subroutines
#include <contrib/tredtr.mak>

################################################
## Overriding definitions of contrib/tredtr.mak

sub DeleteCurrentNode {
  my $node = $this;
  $sPasteNow = '';
  UnGap();
  return unless $node->{ord}=~/\./; # forbid deleting Analytic nodes
  return if $node->firstson;
  return unless $this->parent();
  my $dord = $node->{dord};
  $this=$this->parent();
  CutNode($node);

  $sPar1 = $dord;
  $sPar2 = "-1";
  ShiftDords();
}

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
  if ($this->parent or $this->{func} ne 'SENT') {
    $this->{'tfa'} = $sPar1;
    $this=NextVisibleNode($this);
  }
}

sub FuncAssign {
  if ($this->parent or $this->{func} ne 'SENT') {
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
  return unless (Parent($this) or $this->{func} ne 'SENT');
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

=item getAIDREFs(node?)

Returns a list of AIDs the node points to. This includes AID of the
node itself if it has any. If no node is specified, $this is used.

=cut

sub getAIDREFs {
  my $node = $_[0] || $this;
  my $aidref=($node->{AIDREFS} ne "") ? $node->{AIDREFS} : $node->{AID};
  return split /\|/,$aidref;
}

=item getAIDREFs(node?)

Returns a hash-ref whose keys are AIDs the node points to (all values
are 1) . AID of the node itself is included too (if the node has
any). If no node is specified, $this is used.

=cut

sub getAIDREFsHash {
  my $node = $_[0] || $this;
  return { map { $_ => 1 } getAIDREFs(@_) };
}

sub ConnectAID {
  my $node = shift || $pPar1;
  my $dnode = shift || $pPar2;

  if (getAIDREF($dnode) ne '') {
    my %a; @a{ getAIDREFs($node) }=();
    unless (exists $a{ $dnode->{AID} }) {
      my $aid = getAIDREF($node);
      if ($aid eq "") {
	$node->{AIDREFS}=$dnode->{AID};
      } else {
	$node->{AIDREFS}=$aid.'|'.$dnode->{AID};
      }
    }
  }
}

sub ConnectAIDREFS {
  my $node = shift || $pPar1;
  my $dnode = shift || $pPar2;

  if (getAIDREF($dnode) ne '') {
    my %a; @a{ getAIDREFs($node) }=();
    $node->{AIDREFS}=getAIDREF($node).'|'.getAIDREF($dnode)
      unless exists $a{getAIDREF($dnode)};
  }
}

sub DisconnectAIDREFS {
  my $node = shift || $pPar1;
  my $dnode = shift || $pPar2;
  my $aid=getAIDREF($dnode);
  $node->{AIDREFS} =~ s/\|$aid|$aid\||^$aid$//g;
  $node->{AIDREFS} = "" if ($node->{AIDREFS} eq $node->{AID});
}

sub DisconnectAID {
  my ($node,$dnode) = @_;
  $node->{AIDREFS} = join '|', grep { $_ ne $dnode->{AID} }
                               split /\|/,$node->{AIDREFS};
  $node->{AIDREFS} = "" if ($node->{AIDREFS} eq $node->{AID});
}

sub ConnectFW {
  $pPar1->{fw}= join '|',grep { $_ ne "" }
    $pPar1->{fw},$pPar2->{trlemma},$pPar2->{fw};
}

sub DisconnectFW {
  my $fw = $pPar2->{trlemma};
  $pPar1->{fw} =~ s/\|$fw|$fw\||^$fw$//g;
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

sub split_node_and_lemma {
  SplitJoinedByAID();
}

sub SplitJoinedByAID {
  my $node = ref($_[0]) ? $_[0] : $this;
  ($node->root->{'reserve1'} eq 'TR_TREE') || return;
  unless ($node->{AIDREFS}) {
    stderr("SplitJoinedByAID: nodes with empty AIDREFS can't be split!\n");
    return;
  }

  my %aidrefs;
  @aidrefs{ split /\|/,$node->{AIDREFS} }=();

  foreach my $child ($node->descendants()) {
    if (exists($aidrefs{ $child->{AID} })) {
      my $l=$child->{trlemma};
      if ($l eq 'se' and $node->{trlemma} !~ /^se_|_se_|_se$/) {
	$l='si';
      }
      if ($node->{trlemma} =~ s/^${l}_|_${l}_|_${l}$//i) {
	$child->{TR}='';
	DisconnectAIDREFS($node,$child);

	# ugh! 
	$pPar1 = $child;
	ifmodal();
	if ($sPar3 ne '') {
	  $pAct->{'deontmod'} = '';
	}

      }
    }
  }
}

sub JoinSubtree {
  my $node = ref($_[0]) ? $_[0] : $this;
  my $parent = $node->parent;

  ($node->root->{'reserve1'} eq 'TR_TREE') || return;
  $parent || return;

  my $modal = ($sPar1 eq '0'); # 0 means modal

  $plemma = $parent->{'trlemma'};
  $nlemma = $node->{'trlemma'};

  # allows appending 'se' even if there was no node for it on ATS
  if ($nlemma eq '&Gen;') {
    $nlemma = 'se';
  }

  if ($nlemma eq 'se' && $node->{'form'} eq 'si') {
    # se
    $plemma.='_si';
  } elsif ($nlemma eq 'se') {
    # si
    $plemma.='_se';
  } elsif ($node->{sentord} < $parent->{sentord}) {
    # prepend
    $plemma="${nlemma}_$plemma";
  } else {
    # append
    $plemma.="_$nlemma";
  }

  # move children to parent
  while ($node->firstson()) {
    PasteNode(CutNode($node->firstson),$parent)
  }

  # hide
  $node->{'TR'} = 'hide';

  # connect AIDREFS
  $pPar1 = $parent;
  $pPar2 = $node;
  ConnectAIDREFS();

  if ($modal) {
    # don't join trlemma but rather adjust deontmod
    $pPar1 = $node; $sPar3 = ''; ifmodal();
    $parent->{'deontmod'} = $sPar3;
  } else {
    # join trlemma
    $parent->{'trlemma'} = $plemma;
  }

  $this = $parent;
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
	  stdout(FileName()."##$treeno.".GetNodeIndex($node)." fixing ord $node->{ord} --> $neword for del $node->{del}\n") if $verbose;
	  $node->{ord}=$neword;
	}
	if ($node->{sentord} != 999) {
	  stdout(FileName()."##$treeno.".GetNodeIndex($node)." fixing sentord $node->{sentord} for del $node->{del}\n") if $verbose;
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
	  stdout(FileName()."##$treeno.".GetNodeIndex($node).
	    " fixing duplicated ord $node->{ord} --> $neword\n") if $verbose;
	  $node->{ord}=$neword;
	}
	$ords{$node->{ord}}=1;
      }
      $node=$node->following;
    }
  }
}

sub print_out_and_to_attr {
  my ($node,$treeno,$attr,$text) = @_;
  if ($node->{$attr} ne "") {
    $node->{$attr}.="|".$text;
  } else {
    $node->{$attr}=$text;
  }
  stdout(FileName()."##$treeno.".GetNodeIndex($node)." ".$text."\n");
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
	print_out_and_to_attr($node,$treeno,'err1',"negative ord $node->{ord}");
      }
      if ($node->{dord} < 0) {
	print_out_and_to_attr($node,$treeno,'err1',"negative dord $node->{dord}");
      }
      if ($node->{sentord} < 0) {
	print_out_and_to_attr($node,$treeno,'err1',"negative sentord $node->{sentord}");
      }
      if ($node->{AID} ne "" and exists($aids{$node->{AID}})) {
	print_out_and_to_attr($node,$treeno,'err1',"duplicate AID $node->{AID}");
      }
      if ($node->{TID} ne "" and exists($tids{$node->{TID}})) {
	print_out_and_to_attr($node,$treeno,'err1',"duplicate TID $node->{TID}");
      }
      if ($node->{ord} ne "" and exists($ords{$node->{ord}})) {
	print_out_and_to_attr($node,$treeno,'err1',"duplicate ord $node->{ord}");
      }
      if ($node->{ord} !~ /\./ and $node->{sentord} ne $node->{ord}) {
	print_out_and_to_attr($node,$treeno,'err1',"sentord $node->{sentord} =! ord $node->{ord}");
      }
      if ($node->{ord} =~ /\./ and $node->{sentord} != 999) {
	print_out_and_to_attr($node,$treeno,'err1',"inconsistent sentord $node->{sentord} for ord $node->{ord}");
      }
      if ($node->{ord} =~ /\./ and $node->{TID} eq "") {
	print_out_and_to_attr($node,$treeno,'err1',"missing TID for ord $node->{ord}");
      }
      if ($node->{ord} !~ /\./ and $node->{ord} != 0 and $node->{AID} eq "") {
	print_out_and_to_attr($node,$treeno,'err1',"missing AID for ord $node->{ord}");
      }
      if ($node->{ord} =~ /\./ and $node->{AID} ne "") {
	print_out_and_to_attr($node,$treeno,'err1',"redundant AID for ord $node->{ord}");
      }
      if ($node->{ord} !~ /\./ and $node->{TID} ne "") {
	print_out_and_to_attr($node,$treeno,'err1',"redundant TID for ord $node->{ord}");
      }
      if ($sentords[$node->{sentord}] == 1) {
	print_out_and_to_attr($node,$treeno,'err1',"duplicate sentord $node->{sentord}");
      }
      if ($dords[$node->{dord}] == 1) {
	print_out_and_to_attr($node,$treeno,'err1',"duplicate dord $node->{dord}");
      }
      if ($node->{AID}=~/\|/) {
	print_out_and_to_attr($node,$treeno,'err1',"forbidden character | in AID $node->{AID}");
      }
      if ($node->{AIDREFS} ne "" and $node->{AID} ne "" and index("|$node->{AIDREFS}|","|$node->{AID}|")<0) {
	print_out_and_to_attr($node,$treeno,'err1',"AID $node->{AID} missing in AIDREFS $node->{AIDREFS}");
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
	stdout(FileName()."##$treeno missing sentord $i/$#sentords\n");
      }
    }
    for (my $i=0; $i<=$#dords; $i++) {
      unless ($dords[$i]) {
	stdout(FileName()."##$treeno missing dord $i/$#dords\n");
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
	      stdout(FileName()."##$treeno.".GetNodeIndex($node).
		" no ID from $node->{AIDREFS} matches w$node->{ord}. Using the first one!\n");
	      $node->{AID}=$aid
	    } else {
	      stdout(FileName()."##$treeno.".GetNodeIndex($node).
		" no ID from $node->{AIDREFS} matches w$node->{ord}. Risking free $aid_risk!\n");
	      $node->{AID}=$aid_risk;
	      $node->{AIDREFS}=$aid_risk.'|'.$node->{AIDREFS};
	    }
	  }
	}
      }
      if ($node->{TID} ne "" or $node->{ord}=~/\./ or $node->{sentord}==999) {
	if ($node->{AID} ne "") {
	  stdout(FileName()."##$treeno.".GetNodeIndex($node).
	    " Removing AID $node->{AID} from $node->{TID} $node->{ord}\n")
	      if $verbose;
	  $node->{AID}='';
	}
	if ($node->{TID} eq "") {
	  $node->{TID}=generate_new_tid($tree);
	  stdout(FileName()."##$treeno.".GetNodeIndex($node).
	    " node with ord $node->{ord} has no TID yet: assigning $node->{TID}\n");
	}
	if ($node->{sentord}==999 and $node->{ord}!~/\./) {
	  do {
	    my $oldord=$node->{ord};
	    $node->{ord}=GetNewOrd($node);
	    stdout(FileName()."##$treeno.".GetNodeIndex($node).
	      " changing ord for node with sentord 999 from $oldord to $node->{ord}");
	  };
	}
      }
      if ($node->{AID} ne "" and exists($aids{$node->{AID}})) {
	$node->{TID}=generate_new_tid($tree);
	stdout(FileName()."##$treeno.".GetNodeIndex($node).
	  " replacing duplicate AID $node->{AID} ($node->{ord},$node->{sentord}) with $node->{TID}\n");
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
      stdout(FileName()."##".(CurrentTreeNumber()+1).".".GetNodeIndex($nodesref->[$i])." ",
	$nodesref->[$i]->{$ord}," --> $i\n");
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

#bind tr_vallex_transform to Alt+F10 menu Create missing nodes (based on ValLex)
sub tr_vallex_transform {
  unless ($simple_vallex_loaded) {
    stderr("Loading simple_vallex $libDir/contrib/ValLex/simple_vallex.txt\n");
    local $vallex;
    do "$libDir/contrib/ValLex/simple_vallex.txt";
    die "$@" if ($@);
    $TRValLexTransform::vallex=$vallex;
    stderr("Loaded ",scalar(keys %$vallex)," items\n");
    $simple_vallex_loaded=1;
  }
  TRValLexTransform::DoTransformTree();
}

sub status_line_doubleclick_hook { 
  # status-line field double clicked
  # there is also status_line_click_hook for single clicks

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	ChooseFrame();
	last;
      } else {
	if (main::doEditAttr($grp,$this,$1)) {
	  ChangingFile(1);
	  Redraw_FSFile();
	}
	last;
      }
    }
  }
}

sub get_status_line_hook {
  # get_status_line_hook may either return a string
  # or a pair [ field-definitions, field-styles ]
  return [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "form: " => [qw(label)],
	   $this->{form} => [qw({form} value)],
	   "     afun: " => [qw(label)],
	   $this->{afun} => [qw({afun} value)],
	   "     tag: " => [qw(label)],
	   $this->{tag} => [qw({tag} value)],
	   "     lemma: " => [qw(label)],
	   $this->{lemma} => [qw({lemma} value)],
	   ($this->{fw} ne "" ?
	    ("     fw: " => [qw(label)],
	     $this->{fw} => [qw({fw} value)]) : ()),
	   "     ID: " => [qw(label)],
	   $this->{AID} => [qw({AID} value)],
	   $this->{ID1} => [qw({ID1} value)],
	   $this->{TID} => [qw({TID} value)],
	   "     AIDREFS: " => [qw(label)],
	   (join ", ",split /\|/,$this->{AIDREFS}) => [qw({AIDREFS} value)],
	   ($this->{framere} ne "" ?
	    ("     frame: " => [qw(label)],
	     $this->{framere} => [qw({FRAME} value)],
	     "     {".$this->{frameid}."}" => [qw({FRAME} value)],
	   ) : ()),
	   ($this->{commentA} ne "" ?
	    ("     [" => [qw()],
	     $this->{commentA} => [qw({commentA})],
	     "]" => [qw()]
	    ) : ())
	  ],

	  # field styles
	  [
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	   "{commentA}" => [ -foreground => 'red' ],
	   "bg_white" => [ -background => 'white' ],
	  ]

	 ];
}


# just an experiment
sub __get_value_line_hook {
   my ($fsfile,$treeNo)=@_;
   my @vl = $fsfile->value_line_list($treeNo,1,1);
   %colors = ( ACT => 'red',
	       PAT => 'blue',
	       EFF => 'green',
	       PRED => 'gray' );
   foreach (@vl) {
     if (exists($colors{$_->[1]->{func}})) {
       push @$_, "-underline => 1, -foreground => ".$colors{$_->[1]->{func}};
     }
   }
   return \@vl;
}
