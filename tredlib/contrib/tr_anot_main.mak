## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-05-03 11:13:23 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#

#include remote_control.mak

sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  unless ($grp->{FSFile}->hint()) {
    default_tr_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{NodeMenu}->entryconfigure($_,-state => 'disabled');
    $grp->{ContextsMenu}->configure(-state=>'disabled');
  }
  $FileNotSaved=0;
}

#insert default_tr_attrs as menu Display default attributes
sub default_tr_attrs {
    SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
                    '${func}<? "_#{custom2}\${reltype}\${memberof}" if "$${memberof}$${reltype}" =~ /CO|AP|PA/ ?><? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>');
    SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		      "afun:\t\${afun}\ntag:\t\${tag}".
		      '<?"\ncommentA:\t\${commentA}\n" if $${commentA} ne "" ?>');
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
  if (main::selectValuesDialog($grp,$atr,
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
     ['my','my','???','PL'],
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
  }
  else {
    @selected=($node->{trlemma});
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
    $grp->{top}->toplevel->messageBox
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
  $value=main::QueryString($grp,"Enter comment","commentA",$value);
  if (defined($value)) {
    $this->{commentA}=$value;
  }
}


## add few custom bindings to predefined subroutines

# bind Save to F2 menu Save File
# bind SaveAndPrevFile to F11 menu Save and Go to Next File
# bind SaveAndNextFile to F12 menu Save and Go to Next File
# bind Find to F3 menu Find
# bind FindNext to F4 menu Find Next
# bind FindPrev to Ctrl+F4 menu Find Prev

#x bind NewRBrother to F7 menu New Node (r-brother)
#x bind NewSon to Shift+F7 menu New Node (son)
#x bind DeleteThisNode to F8 menu Delete Node
#x bind CopyValues to F5 menu Copy Values
#x bind PasteValues to F6 menu Paste Values
#x bind PrevTree to key comma
#x bind NextTree to key period

# bind CutToClipboard to Ctrl+Insert menu Cut Subtree

sub CutToClipboard {
  return unless ($this and Parent($this));
  $nodeClipboard=$this;
  $this=RBrother($this) ? RBrother($this) : Parent($this);
  CutNode($nodeClipboard);
}

# bind PasteFromClipboard to Shift+Insert menu Paste Subtree
sub PasteFromClipboard {
  return unless ($this and $nodeClipboard);
  PasteNode($nodeClipboard,$this);
  $this=$nodeClipboard;
  $nodeClipboard=undef;
}


#bind GotoTreeAsk to key Alt+G menu Go to...
sub GotoTreeAsk {
  my $to=main::QueryString($grp,"Give a Tree Number","Number");

  $FileNotSaved=0;
  if ($to=~/#/) {
    for (my $i=$grp->{treeNo}+1; $i<=$grp->{FSFile}->lastTreeNo; $i++) {
      GotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
    for (my $i=0; $i<$grp->{treeNo}; $i++) {
      GotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
  } else {
    GotoTree($to) if defined $to;
  }
}

#bind LastTree to key Shift+greater menu Go to last tree
#bind LastTree to key Ctrl+Next
sub LastTree {
  GotoTree($grp->{FSFile}->lastTreeNo+1);
}

#bind FirstTree to key Shift+less menu Go to first tree
#bind FirstTree to key Ctrl+Prior
sub FirstTree {
  GotoTree(1);
}


#include contrib/tredtr.mak

################################################
## Overriding definitions of contrib/tredtr.mak

sub add_new_node {

  $pPar1 = $this;

  NewSon();
  $this=$pReturn;
  unless (QueryTrlemma($this)) {
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
    print "setting up $iPrevAfunAssigned\n";
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
  if ($main::showHidden) {
    ShiftNodeLeft($this);
  } else {
    ShiftNodeLeftSkipHidden($this,1);
  }
}

sub ShiftRight {
  return unless (Parent($this));
  if ($main::showHidden) {
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
  my $sDord;			# used as type "string"

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
  $pNew->{'func'} = 'PRED';
  $pNew->{'gram'} = '???';
  $pNew->{'reltype'} = '???';
  $pNew->{'memberof'} = '???';
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

  $this=$pNew;
}
