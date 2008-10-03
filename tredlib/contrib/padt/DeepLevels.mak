# ########################################################################## Otakar Smrz, 2006/03/29
#
# DeepLevels Context for the TrEd Environment ######################################################

# $Id$

package DeepLevels;

use 5.008;

use strict;

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

# ##################################################################################################
#
# ##################################################################################################

#binding-context DeepLevels

BEGIN { import TredMacro; }

our ($this, $root, $grp);

our ($Redraw);

our ($hooks_request_mode, $fill) = (0, ' ' x 4);

# ##################################################################################################
#
# ##################################################################################################

sub FuncAssign {

    my $fullfunc = $_[0];
    my ($func, $parallel, $paren) = ($fullfunc =~ /^([^_]*)(?:_(Ap|Co))?(?:_(Pa))?/);

    if ($this->{'func'} eq 'SENT' or $this->{'func'} eq $func) {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'func'} = $func;

        $this = $this->following();

        $Redraw = 'tree';
    }
}

#bind func_CM to Ctrl+e menu Functor: CM
#bind func_CNCS to Ctrl+c menu Functor: CNCS

#bind func_COND to Ctrl+d menu Functor: COND Condition, podmínka reálná (-li, jestlize, kdyz, az)
#bind func_CONFR to O menu Functor: CONFR
#bind func_CONTRD to Ctrl+O menu Functor: CONTRD
#bind func_CPR to P menu Functor: CPR Porovnání (nez, jako, stejně jako)
#bind func_CRIT to Ctrl+k menu Functor: CRIT Criterion, měřítko (podle něj, podle jeho slov)
#bind func_CSQ to q menu Functor: CSQ Consequence, důsledek koord. (a proto, a tak, a tedy, pročez)
#bind func_CTREF to Ctrl+f menu Functor: CTERF Counterfactual, ireálná podmínka (kdyby)
#bind func_DENOM to n menu Functor: DENOM Pojmenování
#bind func_DIFF to F menu Functor: DIFF Difference, rozdíl (oč)
#bind func_DISJ to J menu Functor: DISJ Disjunction, rozlučovací koord. (nebo, anebo)
#bind func_DPHR to X menu Functor: DPHR zavisla cast frazemu
#bind func_ETHD to E menu Functor: ETHD Ethical Dative (já ti mám knih, děti nám nechodí včas)
#bind func_FPHR to 6 menu Functor: FPHR fraze v cizim jazyce
#bind func_GRAD to Ctrl+g menu Functor: GRAD Gradation, stupňovací koord (i, a také)
#bind func_HER to H menu Functor: HER heritage, dědictví (po otci)
#bind func_INTF to I menu Functor: INTF falesný podmět (To Karel jestě nepřisel?)
#bind func_MANN to 9 menu Functor: MANN Manner, způsob (ústně, psát česky)
#bind func_MAT to 4 menu Functor: MAT Partitiv (hrnek čaje)
#bind func_MEANS to Ctrl+m menu Functor: MEANS Prostředek (psát rukou, tuzkou)
#bind func_MOD to M menu Functor: MOD Adv. of modality (asi, mozná, to je myslím zlé)
#bind func_NORM to N menu Functor: NORM Norma (ve shodě s, podle)
#bind func_PAR to Ctrl+z menu Functor: PAR Parenthesis, vsuvka (myslím, věřím)
#bind func_PARTL to A menu Functor: PARTL
#bind func_PREC to Ctrl+p menu Functor: PREC Ref. to prec. text(na zač. věty:tedy, tudíz, totiz,protoze, ..)
#bind func_REAS to Ctrl+r menu Functor: REAS Reason, důvod (nebot)
#bind func_RESL to S menu Functor: RESL Účinek (takze)
#bind func_RESTR to R menu Functor: RESTR Omezení (kromě, mimo)
#bind func_RHEM to 7 menu Functor: RHEM Rhematizer (i, také, jenom,vůbec, NEG, nikoli)
#bind func_SUBS to Ctrl+u menu Functor: SUBS Zastoupení (místo koho-čeho)
#bind func_TFHL to Ctrl+h menu Functor: TFHL For how long, na jak dlouho (na věky)
#bind func_TFRWH to W menu Functor: TFRWH From when, zekdy (zbylo od vánoc cukroví)
#bind func_THL to Ctrl+l menu Functor: THL How long, jak dlouho (četl půl hodiny)
#bind func_THO to Ctrl+o menu Functor: THO How often (často, mnohokrát...)
#bind func_TOWH to Ctrl+w menu Functor: TOWH To when, nakdy (přelozí výuku na pátek)
#bind func_TPAR to Ctrl+a menu Functor: TPAR Parallel (během, zatímco, za celý zápas, mezitím co)
#bind func_TSIN to Ctrl+i menu Functor: TSIN Since, odkdy (od té doby co, ode dne podpisu)
#bind func_TILL to Ctrl+t menu Functor: TTILL Till, dokdy (az do, dokud ne, nez)
#bind func_TWHEN to w menu Functor: TWHEN When, kdy (loni, vstupuje v platnost dnem podpisu)
#bind func_VOC to V menu Functor: VOC Vokativní věta (Jirko!)
#bind func_VOCAT to K menu Functor: VOCAT Vokativ aponovaný (Pojď sem, Jirko!)


#bind func_PRED to  q menu Functor:  PRED    Predicate
sub func_PRED { FuncAssign('PRED') }


#bind func_ACT to   a menu Functor:  ACT     Actor
sub func_ACT { FuncAssign('ACT') }

#bind func_PAT to   p menu Functor:  PAT     Patient
sub func_PAT { FuncAssign('PAT') }

#bind func_ADDR to  d menu Functor:  ADDR    Addressee
sub func_ADDR { FuncAssign('ADDR') }

#bind func_EFF to   e menu Functor:  EFF     Effect
sub func_EFF { FuncAssign('EFF') }

#bind func_ORIG to  o menu Functor:  ORIG    Origin
sub func_ORIG { FuncAssign('ORIG') }


#bind func_TWHEN to  menu Functor: TWHEN   When (generic)
sub func_TWHEN { FuncAssign('TWHEN') }

#bind func_TFHL to  menu Functor: TFHL    For how long
sub func_TFHL { FuncAssign('TFHL') }

#bind func_THL to  menu Functor: THL     How long
sub func_THL { FuncAssign('THL') }

#bind func_THO to  menu Functor: THO     How often
sub func_THO { FuncAssign('THO') }

#bind func_TPAR to  menu Functor: TPAR    During
sub func_TPAR { FuncAssign('TPAR') }

#bind func_TSIN to  menu Functor: TSIN    Since when
sub func_TSIN { FuncAssign('TSIN') }

#bind func_TTILL to  menu Functor: TTILL   Till when
sub func_TTILL { FuncAssign('TTILL') }


#bind func_LOC to   l menu Functor:  LOC     Where (generic)
sub func_LOC { FuncAssign('LOC') }

#bind func_DIR1 to  1 menu Functor:  DIR1    From where
sub func_DIR1 { FuncAssign('DIR1') }

#bind func_DIR2 to  2 menu Functor:  DIR2    Through where
sub func_DIR2 { FuncAssign('DIR2') }

#bind func_DIR3 to  3 menu Functor:  DIR3    To where
sub func_DIR3 { FuncAssign('DIR3') }


#bind func_MANN to  menu Functor: MANN    Manner (generic)
sub func_MANN { FuncAssign('MANN') }

#bind func_EXT to   x menu Functor:  EXT     Extent
sub func_EXT { FuncAssign('EXT') }

#bind func_REG to   g menu Functor:  REG     Regard
sub func_REG { FuncAssign('REG') }

#bind func_ACMP to  C menu Functor:  ACMP    Accompaniment
sub func_ACMP { FuncAssign('ACMP') }

#bind func_ATT to   t menu Functor:  ATT     Attitude
sub func_ATT { FuncAssign('ATT') }

#bind func_MEANS to  menu Functor: MEANS   Means
sub func_MEANS { FuncAssign('MEANS') }

#bind func_CRIT to  menu Functor: CRIT    Criterion
sub func_CRIT { FuncAssign('CRIT') }

#bind func_BEN to   b menu Functor: BEN     Benefactive
sub func_BEN { FuncAssign('BEN') }

#bind func_RESTR to  menu Functor: RESTR   Except
sub func_RESTR { FuncAssign('RESTR') }


#bind func_CAUS to  c  menu Functor: CAUS    Causative
sub func_CAUS { FuncAssign('CAUS') }

#bind func_COND to  menu Functor: COND    Condition
sub func_COND { FuncAssign('COND') }

#bind func_AIM to   I menu Functor:  AIM     Aim
sub func_AIM { FuncAssign('AIM') }

#bind func_CONFR to  menu Functor: CONFR   Confrontation
sub func_CONFR { FuncAssign('CONFR') }

#bind func_RESL to  r menu Functor:  RESL    Result
sub func_RESL { FuncAssign('RESL') }

#bind func_CPR to  menu Functor: CPR     Comparison
sub func_CPR { FuncAssign('CPR') }

#bind func_NORM to  n menu Functor: NORM    Normative
sub func_NORM { FuncAssign('NORM') }


#bind func_SUBS to  menu Functor: SUBS    Substitution
sub func_SUBS { FuncAssign('SUBS') }

#bind func_DPHR to  menu Functor: DPHR    Phraseme
sub func_DPHR { FuncAssign('DPHR') }

#bind func_CPHR to  menu Functor: CPHR    Phraseme class
sub func_CPHR { FuncAssign('CPHR') }

#bind func_INTT to  T menu Functor:  INTT    Intention
sub func_INTT { FuncAssign('INTT') }

#bind func_COMPL to L menu Functor:  COMPL   Complement
sub func_COMPL { FuncAssign('COMPL') }


#bind func_APP to   P menu Functor:  APP     Appurtenance
sub func_APP { FuncAssign('APP') }

#bind func_RSTR to  S menu Functor:  RSTR    Restrictive
sub func_RSTR { FuncAssign('RSTR') }

#bind func_DES to   D menu Functor:  DES     Descriptive
sub func_DES { FuncAssign('DES') }


#bind func_ID to    0 menu Functor:  ID      Identity
sub func_ID { FuncAssign('ID') }

#bind func_MAT to  menu Functor: MAT     Partitive
sub func_MAT { FuncAssign('MAT') }

#bind func_VOC to  menu Functor: VOC     Vocative
sub func_VOC { FuncAssign('VOC') }


#bind func_DISJ to  J menu Functor:  DISJ    Disjunction
sub func_DISJ { FuncAssign('DISJ') }

#bind func_CONJ to  j menu Functor:  CONJ    Conjunction
sub func_CONJ { FuncAssign('CONJ') }

#bind func_ADVS to  v menu Functor:  ADVS    Adversative
sub func_ADVS { FuncAssign('ADVS') }

#bind func_APPS to  s menu Functor:  APPS    Apposition
sub func_APPS { FuncAssign('APPS') }

# ##################################################################################################
#
# ##################################################################################################

sub ContextAssign {

    if ($this->{'func'} eq 'SENT' or $this->{'context'} eq $_[0]) {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'context'} = $_[0];

        $this = $this->following();

        $Redraw = 'tree';
    }
}

#bind context_B to  Ctrl+b menu Context: B bound
sub context_B { ContextAssign('B') }

#bind context_N to  Ctrl+n menu Context: N non-bound
sub context_N { ContextAssign('N') }

#bind context_C to  Ctrl+c menu Context: C contrastive
sub context_C { ContextAssign('C') }

# ##################################################################################################
#
# ##################################################################################################

##bind assign_parallel to key 1 menu Arabic: Suffix Parallel
sub assign_parallel {
  $this->{parallel}||='';
  EditAttribute($this,'parallel');
}

##bind assign_paren to key 2 menu Arabic: Suffix Paren
sub assign_paren {
  $this->{paren}||='';
  EditAttribute($this,'paren');
}

##bind assign_arabfa to key 3 menu Arabic: Suffix ArabFa
sub assign_arabfa {
  $this->{arabfa}||='';
  EditAttribute($this,'arabfa');
}

##bind assign_arabspec to key 4 menu Arabic: Suffix ArabSpec
sub assign_arabspec {
  $this->{arabspec}||='';
  EditAttribute($this,'arabspec');
}

##bind assign_arabclause to key 5 menu Arabic: Suffix ArabClause
sub assign_arabclause {
  $this->{arabclause}||='';
  EditAttribute($this,'arabclause');
}

# ##################################################################################################
#
# ##################################################################################################

#bind thisToParent to Alt+Up menu Annotate: Current node up one level to grandparent
sub thisToParent {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this->parent() and $this->parent()->parent();

    my $act = $this;
    my $p = $act->parent()->parent();

    CutPaste($act, $p);
    $this = $act;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToRBrother to Alt+Left menu Annotate: Current node to brother on the left
sub thisToRBrother {

    $Redraw = 'none';
    ChangingFile(0);

    my $p = $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()
            ? $this->rbrother() : $this->lbrother();

    return unless $p;

    my $c = $this;

    CutPaste($c, $p);
    $this = $c;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToLBrother to Alt+Right menu Annotate: Current node to brother on the right
sub thisToLBrother {

    $Redraw = 'none';
    ChangingFile(0);

    my $p = $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()
            ? $this->lbrother() : $this->rbrother();

    return unless $p;

    my $c = $this;

    CutPaste($c, $p);
    $this = $c;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToParentRBrother to Alt+Shift+Left menu Annotate: Current node to uncle on the left
sub thisToParentRBrother {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this->parent();

    my $p = $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()
            ? $this->parent()->rbrother() : $this->parent()->lbrother();

    return unless $p;

    my $c = $this;

    CutPaste($c, $p);
    $this = $c;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToParentLBrother to Alt+Shift+Right menu Annotate: Current node to uncle on the right
sub thisToParentLBrother {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this->parent();

    my $p = $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()
            ? $this->parent()->lbrother() : $this->parent()->rbrother();

    return unless $p;

    my $c = $this;

    CutPaste($c, $p);
    $this = $c;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToEitherBrother to Alt+Down menu Annotate: Current node to either side brother if unique
sub thisToEitherBrother {

    $Redraw = 'none';
    ChangingFile(0);

    my $lb = $this->lbrother();
    my $rb = $this->rbrother();

    return unless $lb xor $rb;

    my $c = $this;
    my $p = $lb || $rb;

    CutPaste($c, $p);
    $this = $c;

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind SwapNodesUp to Alt+Shift+Down menu Annotate: Current node exchanged with parent
sub SwapNodesUp {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this;

    my $parent = $this->parent();

    return unless $parent;

    my $grandParent = $parent->parent();

    return unless $grandParent;

    CutPaste($this, $grandParent);
    CutPaste($parent, $this);
    $this = $parent;

    $Redraw = 'tree';
    ChangingFile(1);
}

##bind SwapNodesDown to Alt+Shift+Down menu Annotate: Current node exchanged with son if unique
sub SwapNodesDown {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this;

    my @childs = $this->children();
    my $parent = $this->parent();

    return unless @childs == 1 and $parent;

    CutPaste($childs[0], $parent);
    CutPaste($this, $childs[0]);
    $this = $childs[0];

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToRoot to Alt+Shift+Up menu Annotate: Current node to the root
sub thisToRoot {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this and $this->parent();

    return unless $root;

    CutPaste($this, $root);

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToLeftClauseHead to Ctrl+Alt+Right menu Annotate: Current node to preceeding clause head
sub thisToLeftClauseHead {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this and $this->parent();

    $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode() ?
        thisToPrevClauseHead() :
        thisToNextClauseHead();
}

#bind thisToRightClauseHead to Ctrl+Alt+Left menu Annotate: Current node to following clause head
sub thisToRightClauseHead {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this and $this->parent();

    $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode() ?
        thisToNextClauseHead() :
        thisToPrevClauseHead();
}

sub thisToPrevClauseHead {

    my $node = $this->parent();

    do { $node = $node->previous() } while $node and not isClauseHead($node);

    return unless $node;

    CutPaste($this, $node);

    $Redraw = 'tree';
    ChangingFile(1);
}

sub thisToNextClauseHead {

    my $node = $this->parent();

    do { $node = $node->following() } until $node == $this or isClauseHead($node);

    unless ($node == $this) {

        CutPaste($this, $node);
    }
    else {

        $node = $this->rightmost_descendant();

        do { $node = $node->following() } while $node and not isClauseHead($node);

        return unless $node;

        CutPaste($this, $node);
    }

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToSuperClauseHead to Ctrl+Alt+Up menu Annotate: Current node to superior clause head
sub thisToSuperClauseHead {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this and $this->parent();

    my $node = $this->parent();

    do { $node = $node->parent() } while $node and not isClauseHead($node);

    return unless $node;

    CutPaste($this, $node);

    $Redraw = 'tree';
    ChangingFile(1);
}

#bind thisToInferClauseHead to Ctrl+Alt+Down menu Annotate: Current node to inferior clause head
sub thisToInferClauseHead {

    $Redraw = 'none';
    ChangingFile(0);

    return unless $this and $this->parent();

    my $node = $this;

    do { $node = $node->following($this) } while $node and not isClauseHead($node);

    return unless $node;

    CutPaste($node, $this->parent());
    CutPaste($this, $node);

    $Redraw = 'tree';
    ChangingFile(1);
}

# ##################################################################################################
#
# ##################################################################################################

#bind hide_node to Ctrl+h menu Display: Hide / unhide the node
sub hide_node {

    $this->{'hide'} = $this->{'hide'} eq 'hide' ? '' : 'hide';
}

sub get_auto_afun {

    require Assign_arab_afun;

    my ($ra, $rb, $rc) = Assign_arab_afun::afun($_[0]);

    print STDERR "$this->{lemma} ($ra,$rb,$rc)\n";

    return $ra =~ /^\s*$/ ? '' : $ra;
}

##bind request_auto_afun_node Ctrl+Shift+F9 menu Arabic: Request auto afun for current node
sub request_auto_afun_node {

    my $node = $_[0] eq __PACKAGE__ ? $this : $_[0];

    unless ($node and $node->parent() and ($node->{'afun'} eq '???' or $node->{'afun'} eq '')) {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $node->{'afun'} = '???';    # it might have been empty
        $node->{'afunaux'} = get_auto_afun($node);

        $Redraw = 'tree';
    }
}

##bind request_auto_afun_subtree to Ctrl+Shift+F10 menu Arabic: Request auto afun for current subtree
sub request_auto_afun_subtree {

    my $node = $this;

    request_auto_afun_node($node);      # more strict checks

    while ($node = $node->following($this)) {

        if ($node->{'afun'} eq '???' or $node->{'afun'} eq '') {

            $node->{'afun'} = '???';    # it might have been empty
            $node->{'afunaux'} = get_auto_afun($node);
        }
    }

    $Redraw = 'tree';
}

##bind hooks_request_mode Ctrl+Shift+F8 menu Arabic: Toggle request mode for auto afuns
sub hooks_request_mode {

    $hooks_request_mode = not $hooks_request_mode;

    $Redraw = 'none';
    ChangingFile(0);
}

sub get_value_line_hook {

    my ($fsfile, $index) = @_;
    my ($nodes, $words);

    ($nodes, undef) = $fsfile->nodes($index, $this, 1);

    $nodes = [ sort { $a->{'y_ord'} <=> $b->{'y_ord'} } @{$nodes} ];

    $words = [ [ $nodes->[0]->{'origf'}, $nodes->[0], '-foreground => darkmagenta' ],
               map {
                        [ " " ],
                        [ $_->{'origf'}, $_, $_->{'tag'} ? () : '-foreground => red' ],
               }
               grep { defined $_->{'origf'} and $_->{'origf'} ne '' } @{$nodes}[1 .. $#{$nodes}] ];

    @{$words} = reverse @{$words} if $main::treeViewOpts->{reverseNodeOrder};

    return $words;
}

sub highlight_value_line_tag_hook {

    my $node = $grp->{currentNode};

    $node = PrevNodeLinear($node, 'y_ord') until !$node or defined $node->{'origf'} and $node->{'origf'} ne '';

    return $node;
}

sub node_release_hook {

    my ($node, $done, $mode) = @_;
    my (@line);

    return unless $done;

    return 'stop' unless $node->parent();

    if ($mode eq 'Control') {

        shuffle_tree($node, $done);

        Redraw_FSFile_Tree();
        main::centerTo($grp, $grp->{currentNode});
        ChangingFile(1);

        return 'stop';
    }
    elsif ($mode eq 'Shift') {

        shuffle_node($node, $done);

        Redraw_FSFile_Tree();
        main::centerTo($grp, $grp->{currentNode});
        ChangingFile(1);

        return 'stop';
    }
    else {

        return unless $hooks_request_mode;

        while ($done->{'afun'} eq '???' and $done->{'afunaux'} eq '') {

            unshift @line, $done;

            $done = $done->parent();
        }

        request_auto_afun_node($_) foreach @line, $node;
    }
}

sub shuffle_tree ($$) {

    my ($node, $done) = @_;
    my ($curr, $diff, $dirr, $etip, $itip);
    my (@nodes, @extra, @intra, $inter);

    $dirr = $node->{'ord'} <=> $done->{'ord'};
    $diff = $dirr * ($node->{'ord'} - $done->{'ord'});

    $etip = $node->root();
    $itip = $node;

    @nodes = ($etip);

    while (@nodes) {

        $curr = shift @nodes;

        next if $curr == $node;

        push @nodes, $curr->children();
        push @extra, $curr;

        $etip = $curr if ($etip->{'ord'} <=> $curr->{'ord'}) == $dirr;
    }

    @nodes = ($itip);

    while (@nodes) {

        $curr = shift @nodes;

        $diff-- if ($node->{'ord'} - $curr->{'ord'}) * ($done->{'ord'} - $curr->{'ord'}) < 0;

        push @nodes, $curr->children();
        push @intra, $curr;

        $itip = $curr if ($itip->{'ord'} <=> $curr->{'ord'}) == $dirr;
    }

    return if $dirr * ($itip->{'ord'} - $etip->{'ord'}) < $diff;

    @extra = sort { $a->{'ord'} <=> $b->{'ord'} } @extra;
    @intra = sort { $a->{'ord'} <=> $b->{'ord'} } @intra;

    @nodes = ();

    $inter = $intra[0]->{'ord'} - $extra[0]->{'ord'} > 0 ? $intra[0]->{'ord'} - $extra[0]->{'ord'} : 0;

    push @nodes, splice @extra, 0, $inter - $diff * $dirr;

    while (@intra > 1) {

        $inter = $intra[1]->{'ord'} - $intra[0]->{'ord'} - 1;

        push @nodes, shift @intra, splice @extra, 0, $inter;
    }

    push @nodes, @intra, @extra;

    for ($inter = 0; $inter < @nodes; $inter++) {

        $nodes[$inter]->{'ord'} = $inter;
    }

    RepasteNode($node);
}

sub shuffle_node ($$) {

    my ($node, $done) = @_;
    my ($curr, $dirr);

    $curr = $node->root();

    $dirr = $node->{'ord'} <=> $done->{'ord'};

    while ($curr = $curr->following()) {

        $curr->{'ord'} += $dirr if ($node->{'ord'} - $curr->{'ord'}) * ($done->{'ord'} - $curr->{'ord'}) < 0;
    }

    $node->{'ord'} = $done->{'ord'};
    $done->{'ord'} += $dirr;

    RepasteNode($node);
}

sub node_moved_hook {

    return unless $hooks_request_mode;

    my (undef, $done) = @_;

    my @line;

    while ($done->{'afun'} eq '???' and $done->{'afunaux'} eq '') {

        unshift @line, $done;

        $done = $done->parent();
    }

    request_auto_afun_node($_) foreach @line;
}

# bind padt_auto_parse_tree to Ctrl+Shift+F2 menu Arabic: Parse the current sentence and build a tree
sub padt_auto_parse_tree {
  require Arab_parser;
  Arab_parser::parse_sentence($grp,$root);
}

sub root_style_hook {

}

sub node_style_hook {

    my ($node, $styles) = @_;

    if ($node->{'arabspec'} eq 'Ref') {

        my $T = << 'TARGET';
[!
    return DeepLevels::referring_Ref($this);
!]
TARGET

        my $C = << "COORDS";
n,n,
(n + x$T) / 2 + (abs(xn - x$T) > abs(yn - y$T) ? 0 : -40),
(n + y$T) / 2 + (abs(yn - y$T) > abs(xn - x$T) ? 0 :  40),
x$T,y$T
COORDS

    AddStyle($styles,   'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $C,         # coords for our line
             -arrow =>  '&last',
             -dash =>   '&_',
             -width =>  '&1',
             -fill =>   '&#C000D0', # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );
    }


    if ($node->{arabspec} eq 'Msd') {

        my $T = << 'TARGET';
[!
    return DeepLevels::referring_Msd($this);
!]
TARGET

        my $C = << "COORDS";
n,n,
(n + x$T) / 2 + (abs(xn - x$T) > abs(yn - y$T) ? 0 : -40),
(n + y$T) / 2 + (abs(yn - y$T) > abs(xn - x$T) ? 0 :  40),
x$T,y$T
COORDS

    AddStyle($styles,   'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $C,         # coords for our line
             -arrow =>  '&last',
             -dash =>   '&_',
             -width =>  '&1',
             -fill =>   '&#FFA000', # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );
    }
}

# ##################################################################################################
#
# ##################################################################################################

sub isPredicate {

    my $this = defined $_[0] ? $_[0] : $this;

    return $this->{arabclause} ne "" || $this->{tag} =~ /^V/ && $this->{afun} !~ /^Aux/
                                     || $this->{afun} =~ /^Pred[ECMP]?$/;
}

sub theClauseHead ($;&) {

    my $this = defined $_[0] ? $_[0] : $this;

    my $code = defined $_[1] ? $_[1] : sub { return undef };

    my ($return, $effect, @children, $main);

    my $head = $this;

    while ($head) {

        $effect = $head->{afun};

        if ($head->{afun} =~ /^(?:Coord|Apos)$/) {

            @children = grep { $_->{parallel} =~ /^(?:Co|Ap)$/ } $head->children();

            if (grep { $_->{afun} eq 'Atv' } @children) {

                $effect = 'Atv';
            }
            elsif (grep { isPredicate($_) } @children) {

                $effect = 'Pred';
            }
            elsif (grep { $_->{afun} eq 'Pnom'} @children) {

                $effect = 'Pnom';
            }
        }

        if ($head->{afun} =~ /^(?:Pnom|Atv)$/ or $effect =~ /^(?:Pnom|Atv)$/) {

            $main = $head;                      # {Pred} <- [Pnom] = [Pnom] and there exist [Verb] <- [Verb]

            if ($main->{parallel} =~ /^(?:Co|Ap)$/) {

                do {

                    $main = $main->parent();
                }
                while $main and $main->{parallel} =~ /^(?:Co|Ap)$/ and $main->{afun} =~ /^(?:Coord|Apos)$/;

                $main = $head unless $main and $main->{afun} =~ /^(?:Coord|Apos)$/;
            }

            if ($main->parent() and isPredicate($main->parent())) {

                return $main->parent();
            }
            elsif ($head->{afun} eq 'Pnom') {

                return $head;
            }
        }

        last if isPredicate($head) or $effect =~ /^(?:Pred|Pnom)$/;

        if ($return = $code->($head)) {

            return $return;
        }

        $head = $head->parent();
    }

    return $head;
}

sub isClauseHead {

    my $this = defined $_[0] ? $_[0] : $this;

    my $head = theClauseHead($this, sub { return 'stop' } );

    return $this == $head;
}

sub referring_Ref {

    my $this = defined $_[0] ? $_[0] : $this;

    my $head = $this->parent();

    $head = theClauseHead($head, sub {                  # attributive pseudo-clause .. approximation only

            return $_[0] if $_[0]->{afun} eq 'Atr' and $_[0]->{tag} =~ /^A/
                            and $this->level() > $_[0]->level() + 1;
            return undef;

        } );

    if ($head) {

        my $ante = $head;

        $ante = $ante->following($head) while $ante and $ante->{afun} ne 'Ante' and $ante != $this;

        unless ($ante) {

            $head = $head->parent() while $head->{parallel} =~ /^(?:Co|Ap)$/;

            $ante = $head;

            $ante = $ante->following($head) while $ante and $ante->{afun} ne 'Ante' and $ante != $this;
        }

        $ante = $ante->parent() while $ante and $ante->{parallel} =~ /^(?:Co|Ap)$/;

        if ($ante) {

            $this = $this->parent() while $this and $this != $ante;

            return $ante if $this != $ante;
        }

        $head = $head->parent() while $head->{parallel} =~ /^(?:Co|Ap)$/;

        $head = $head->parent();

        return $head;
    }
    else {

        return undef;
    }
}

sub referring_Msd {

    my $this = defined $_[0] ? $_[0] : $this;

    my $head = $this->parent();                                     # the token itself might feature the critical tags

    $head = $head->parent() if $this->{afun} eq 'Atr';                      # constructs like <_hAfa 'a^sadda _hawfiN>

    $head = $head->parent() until not $head or $head->{tag} =~ /^[VNA]/;    # the verb, governing masdar or participle

    return $head;
}

# ##################################################################################################
#
# ##################################################################################################

sub enable_attr_hook {

    return 'stop' unless $_[0] =~ /^(?:func|context|comment)$/;
}

#bind edit_comment to exclam menu Annotate: Edit annotator's comment
sub edit_comment {

    $Redraw = 'none';
    ChangingFile(0);

    my $comment = $grp->{FSFile}->FS->exists('comment') ? 'comment' : undef;

    unless (defined $comment) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "No attribute for annotator's comment in this file",
            -title => 'Sorry',
            -type => 'OK',
        );

        return;
    }

    my $value = $this->{$comment};

    $value = main::QueryString($grp->{framegroup}, "Enter comment", $comment, $value);

    if (defined $value) {

        $this->{$comment} = $value;

        $Redraw = 'tree';
        ChangingFile(1);
    }
}

#bind default_ar_attrs to F8 menu Display: Show / hide morphological tags
sub default_ar_attrs {

    return unless $grp->{FSFile};

    my ($type, $pattern) = ('node:', '#{custom2}${tag}');

    my $code = q {<? '#{custom6}${x_comment} << ' if $this->{afun} ne 'AuxS' and $this->{x_comment} ne '' ?>};

    my ($hint, $cntxt, $style) = GetStylesheetPatterns();

    my @filter = grep { $_ !~ /^(?:\Q${type}\E\s*)?(?:\Q${code}\E)?\Q${pattern}\E$/ } @{$style};

    SetStylesheetPatterns([ $hint, $cntxt, [ @filter, @{$style} == @filter ? $type . ' ' . $code . $pattern : () ] ]);

    ChangingFile(0);

    return 1;
}

#bind invoke_undo BackSpace menu Annotate: Undo recent annotation action
sub invoke_undo {

    warn 'Undoooooing ;)';

    main::undo($grp);
    $this = $grp->{currentNode};

    ChangingFile(0);
}

#bind annotate_following space menu Annotate: Move to following ???
sub annotate_following {

    my $node = $this;

    do { $this = $this->following() } while $this and $this->{'func'} ne '???';

    $this = $node unless $this and $this->{'func'} eq '???';

    $Redraw = 'none';
    ChangingFile(0);
}

#bind annotate_previous Shift+space menu Annotate: Move to previous ???
sub annotate_previous {

    my $node = $this;

    do { $this = $this->previous() } while $this and $this->{'func'} ne '???';

    $this = $node unless $this and $this->{'func'} eq '???';

    $Redraw = 'none';
    ChangingFile(0);
}

##bind accept_auto_afun Ctrl+space menu Arabic: Accept auto-assigned annotation
sub accept_auto_afun {

    my $node = $this;

    unless ($this->{'afun'} eq '???' and $this->{'afunaux'} ne '') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'afun'} = $this->{'afunaux'};
        $this->{'afunaux'} = '';

        $Redraw = 'tree';
    }
}

#bind unset_func to question menu Functor: unset to ???
sub unset_func {

    if ($this->{'func'} eq 'SENT' or $this->{'func'} eq '???') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'func'} = '???';

        $Redraw = 'tree';
    }
}

#bind unset_context to Ctrl+v menu Context: revert to unset
sub unset_context {

    if ($this->{'func'} eq 'SENT' or $this->{'context'} eq '') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'context'} = '';

        $Redraw = 'tree';
    }
}

# ##################################################################################################
#
# ##################################################################################################

use List::Util 'reduce';

#bind move_word_home Home menu Move to First Word
sub move_word_home {

    $this = reduce { $a->{'ord'} < $b->{'ord'} ? $a : $b } GetVisibleNodes($root);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_word_end End menu Move to Last Word
sub move_word_end {

    $this = reduce { $a->{'ord'} > $b->{'ord'} ? $a : $b } GetVisibleNodes($root);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_deep_home Ctrl+Home menu Move to Rightmost Descendant
sub move_deep_home {

    $this = $this->leftmost_descendant();

    $this = PrevVisibleNode($this) if IsHidden($this);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_deep_end Ctrl+End menu Move to Leftmost Descendant
sub move_deep_end {

    $this = $this->rightmost_descendant();

    $this = NextVisibleNode($this) || PrevVisibleNode($this) if IsHidden($this);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_par_home Shift+Home menu Move to First Paragraph
sub move_par_home {

    GotoTree(1);

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_par_end Shift+End menu Move to Last Paragraph
sub move_par_end {

    GotoTree($grp->{FSFile}->lastTreeNo + 1);

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_to_next_paragraph Shift+Next menu Move to Next Paragraph
sub move_to_next_paragraph {

    NextTree();

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_to_prev_paragraph Shift+Prior menu Move to Prev Paragraph
sub move_to_prev_paragraph {

    PrevTree();

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_to_root Ctrl+Shift+Up menu Move Up to Root
sub move_to_root {

    $this = $root unless $root == $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_to_fork Ctrl+Shift+Down menu Move Down to Fork
sub move_to_fork {

    my $node = $this;
    my (@children);

    while (@children = $node->children()) {

        @children = grep { $_->{'hide'} ne 'hide' } @children;

        last unless @children == 1;

        $node = $children[0];
    }

    $this = $node unless $node == $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind prev_clause_head Ctrl+Right menu Move to the Preceeding Clause Head
sub prev_clause_head {

    my $node = $this;

    if ($main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()) {

        do { $this = $this->previous() } while $this and not isClauseHead($this);
    }
    else {

        do { $this = $this->following() } while $this and not isClauseHead($this);
    }

    $this = $node unless $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind next_clause_head Ctrl+Left menu Move to the Following Clause Head
sub next_clause_head {

    my $node = $this;

    if ($main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode()) {

        do { $this = $this->following() } while $this and not isClauseHead($this);
    }
    else {

        do { $this = $this->previous() } while $this and not isClauseHead($this);
    }

    $this = $node unless $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind super_clause_head Ctrl+Up menu Move to the Superior Clause Head
sub super_clause_head {

    my $node = $this;

    do { $this = $this->parent() } while $this and not isClauseHead($this);

    $this = $node unless $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind infer_clause_head Ctrl+Down menu Move to the Inferior Clause Head
sub infer_clause_head {

    my $node = $this;

    do { $this = $this->following($node) } while $this and not isClauseHead($this);

    $this = $node unless $this;

    $Redraw = 'none';
    ChangingFile(0);
}

# ##################################################################################################
#
# ##################################################################################################

use File::Spec;
use File::Copy;

sub path (@) {

    return File::Spec->join(@_);
}

sub escape ($) {

    return $^O eq 'MSWin32' ? '"' . $_[0] . '"' : "'" . $_[0] . "'";
}

sub espace ($) {

    my $name = $_[0];

    $name =~ s/\\/\//g if $^O eq 'MSWin32' and $name =~ / /;

    return escape $name;
}

sub expace ($) {

    return '"' . "'" . $_[0] . "'" . '"'  if $^O eq 'MSWin32' and $_[0] =~ / /;

    return escape $_[0];
}

sub inter_with_level ($) {

    require File::Basename;

    my $level = $_[0];

    my (@file, $path, $name);

    my $thisfile = File::Spec->canonpath(FileName());

    ($name, $path, undef) = File::Basename::fileparse($thisfile, '.deeper.fs');
    (undef, $path, undef) = File::Basename::fileparse((substr $path, 0, -1), '');

    $file[0] = path $path . 'deeper', $name . '.deeper.fs';
    $file[1] = path $path . "$level", $name . ".$level.fs";

    $file[2] = $level ne 'others' ? ( path $path . "$level", $name . '.deeper.fs')
                                  : ( path $path . 'deeper', $name . ".$level.fs");

    $file[3] = path $path . 'deeper', $name . '.deeper.fs.anno.fs';

    unless ($file[0] eq $thisfile) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "This file's name does not fit the directory structure!$fill\n" .
                        "Relocate it to " . ( path '..', 'deeper', $name . '.deeper.fs' ) . ".$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    return $level, $name, $path, @file;
}

#bind synchronize_file to Ctrl+Alt+equal menu Action: Synchronize Annotations
sub synchronize_file {

    ChangingFile(0);

    my $reply = main::userQuery($grp, "\nDo you wish to synchronize this file's annotations?$fill",
            -bitmap=> 'question',
            -title => "Synchronizing",
            -buttons => ['Yes', 'No']);

    return unless $reply eq 'Yes';

    print "Synchronizing ...\n";

    my ($level, $name, $path, @file) = inter_with_level 'syntax';

    return unless defined $level;

    unless (-f $file[1]) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "There is no " . ( path '..', "$level", $name . ".$level.fs" ) . " file.$fill\n" .
                        "Make sure you are working with complete data!$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    if (-f $file[2]) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "Cannot create " . ( path '..', 'deeper', $name . '.deeper.fs' ) . "!$fill\n" .
                        "Please remove " . ( path '..', "$level", $name . '.deeper.fs' ) . ".$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    if (GetFileSaveStatus()) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "The current file has been modified. Either save it, or reload it discarding the changes.$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    ToplevelFrame()->messageBox (
        -icon => 'warning',
        -message => "This function is not implemented yet.$fill",
        -title => 'Error',
        -type => 'OK',
    );

    return;

    my ($tree, $node);

    $tree = CurrentTreeNumber() + 1;
    $node = $this->{'ord'};

    move $file[0], $file[3];

    system 'perl -X ' . ( escape CallerDir('exec').'/DeeperFS.pl' ) .
                  ' ' . ( expace $file[1] );

    move $file[2], $file[0];

    system 'btred -QI ' . ( escape CallerDir('exec').'/migrate_annotation_deeper.btred' ) .
                    ' ' . ( espace $file[0] );

    print "... succeeded.\n";

    main::reloadFile($grp);

    GotoTree($tree);

    $this = $this->following() until $this->{'ord'} == $node;
}

#bind open_level_first to Ctrl+Alt+1 menu Action: Edit MorphoTrees File
sub open_level_first {

    ChangingFile(0);

    my ($level, $name, $path, @file) = inter_with_level 'morpho';

    return unless defined $level;

    unless (-f $file[1]) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "There is no " . ( path '..', "$level", $name . ".$level.fs" ) . " file!$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    my ($tree, $node);

    ($tree) = $root->{'x_id_ord'} =~ /^\#[0-9]+\_([0-9]+)$/;

    unless ($this == $root) {

        ($node) = $this->{'x_id_ord'} =~ /^\#[0-9]+\/([0-9]+)(:?\_[0-9]+)?$/;
    }
    else {

        $node = 0;
    }

    if (Open($file[1])) {

        GotoTree($tree);

        $this = ($this->children())[$node - 1] unless $node == 0;
    }
    else {

        SwitchContext('DeepLevels');
    }
}

#bind open_level_second to Ctrl+Alt+2 menu Action: Edit Analytic File
sub open_level_second {

    ChangingFile(0);

    my ($level, $name, $path, @file) = inter_with_level 'syntax';

    return unless defined $level;

    unless (-f $file[1]) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "There is no " . ( path '..', "$level", $name . ".$level.fs" ) . " file!$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    my ($tree, $node) = $this->{'x_id_ord'} =~ /^\#([0-9]+)\/([0-9]+)(:?\_[0-9]+)?$/;

    if (Open($file[1])) {

        GotoTree($tree);

        $this = $this->following() until $this->{'ord'} eq $node;
    }
    else {

        SwitchContext('DeepLevels');
    }
}

#bind open_level_third to Ctrl+Alt+3 menu Action: Edit DeepLevels File
sub open_level_third {

    ChangingFile(0);
}

#bind ThisAddressClipBoard Ctrl+Return menu ThisAddress() to Clipboard
sub ThisAddressClipBoard {

    my $reply = main::userQuery($grp,
                        "\nCopy this node's address to clipboard?$fill",
                        -bitmap=> 'question',
                        -title => "Clipboard",
                        -buttons => ['Yes', 'No']);

    return unless $reply eq 'Yes';

    my $widget = ToplevelFrame();

    $widget->clipboardClear();
    $widget->clipboardAppend(ThisAddress());

    $Redraw = 'none';
    ChangingFile(0);
}

# ##################################################################################################
#
# ##################################################################################################

no strict;

1;


=head1 NAME

DeepLevels - Context for Annotation of Tectogrammatics and Deeper Levels in the TrEd Environment


=head1 REVISION

    $Revision$       $Date$


=head1 DESCRIPTION

For reference, see the list of DeepLevels macros and key-bindings in the User-defined menu item in TrEd.


=head1 SEE ALSO

TrEd Tree Editor L<http://ufal.mff.cuni.cz/~pajas/tred/>

Prague Arabic Dependency Treebank L<http://ufal.mff.cuni.cz/padt/online/>


=head1 AUTHOR

Otakar Smrz, L<http://ufal.mff.cuni.cz/~smrz/>

    eval { 'E<lt>' . ( join '.', qw 'otakar smrz' ) . "\x40" . ( join '.', qw 'mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright 2006-2007 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
