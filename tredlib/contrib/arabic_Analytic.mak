# ########################################################################## Otakar Smrz, 2004/03/05
#
# Arabic Analytic Context for TrEd by Petr Pajas ###################################################

# $Id$

#include <tred.mac>

package TredMacro;

#binding-context TredMacro;

sub file_opened_hook {

    SwitchContext('Analytic');
}

#include <contrib/arabic_common.mak>

package Analytic;

use 5.008;

our $VERSION = do { my @r = q$Revision$ =~ /\d+/g; sprintf "%d." . "%02d" x $#r, @r };

# ##################################################################################################
#
# ##################################################################################################

#binding-context Analytic

our ($hooks_request_mode);

# ##################################################################################################
#
# ##################################################################################################

#unbind-key j
#remove-menu Assign afun AtvV
#unbind-key J
#remove-menu Assign afun AtvV_Ap
#unbind-key Ctrl+j
#remove-menu Assign afun AtvV_Co
#unbind-key Ctrl+J
#remove-menu Assign afun AtvV_Pa

#unbind-key j
#remove-menu Assign afun AtvV
#unbind-key J
#remove-menu Assign afun AtvV_Ap
#unbind-key Ctrl+j
#remove-menu Assign afun AtvV_Co
#unbind-key Ctrl+J
#remove-menu Assign afun AtvV_Pa

#unbind-key o
#remove-menu Assign afun AuxO
#unbind-key O
#remove-menu Assign afun AuxO_Ap
#unbind-key Ctrl+o
#remove-menu Assign afun AuxO_Co
#unbind-key Ctrl+O
#remove-menu Assign afun AuxO_Pa

#unbind-key r
#remove-menu Assign afun AuxR
#unbind-key R
#remove-menu Assign afun AuxR_Ap
#unbind-key Ctrl+r
#remove-menu Assign afun AuxR_Co
#unbind-key Ctrl+R
#remove-menu Assign afun AuxR_Pa

#unbind-key t
#remove-menu Assign afun AuxT
#unbind-key T
#remove-menu Assign afun AuxT_Ap
#unbind-key Ctrl+t
#remove-menu Assign afun AuxT_Co
#unbind-key Ctrl+T
#remove-menu Assign afun AuxT_Pa

#unbind-key v
#remove-menu Assign afun AuxV
#unbind-key V
#remove-menu Assign afun AuxV_Ap
#unbind-key Ctrl+v
#remove-menu Assign afun AuxV_Co
#unbind-key Ctrl+V
#remove-menu Assign afun AuxV_Pa

#unbind-key x
#remove-menu Assign afun AuxX
#unbind-key X
#remove-menu Assign afun AuxX_Ap
#unbind-key Ctrl+x
#remove-menu Assign afun AuxX_Co
#unbind-key Ctrl+X
#remove-menu Assign afun AuxX_Pa

#unbind-key z
#remove-menu Assign afun AuxZ
#unbind-key Z
#remove-menu Assign afun AuxZ_Ap
#unbind-key Ctrl+z
#remove-menu Assign afun AuxZ_Co
#unbind-key Ctrl+Z
#remove-menu Assign afun AuxZ_Pa

sub AfunAssign {

    my $fullafun = $_[0] || $sPar1;
    my ($afun, $parallel, $paren) = ($fullafun =~ /^([^_]*)(?:_(Ap|Co|no-parallel))?(?:_(Pa|no-paren))?/);

    if ($this->{'afun'} eq 'AuxS') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'afunaux'} = $this->{'afun'} unless $this->{'afun'} eq '???';

        $this->{'afun'} = $afun;
        $this->{'parallel'} = $parallel;
        $this->{'paren'} = $paren;

        $this->{'afunaux'} = '' if $this->{'afun'} eq '???';

        $iPrevAfunAssigned = $this->{'ord'};
        $this = $this->following();

        $Redraw = 'tree';
    }
}

#bind afun_auxM to m menu Arabic: Assign afun AuxM
sub afun_auxM { AfunAssign('AuxM') }
#bind afun_auxM_Co to Ctrl+m
sub afun_auxM_Co { AfunAssign('AuxM_Co') }
#bind afun_auxM_Ap to M
sub afun_auxM_Ap { AfunAssign('AuxM_Ap') }
#bind afun_auxM_Pa to Ctrl+M
sub afun_auxM_Pa { AfunAssign('AuxM_Pa') }

#bind afun_auxE to f menu Arabic: Assign afun AuxE
sub afun_auxE { AfunAssign('AuxE') }
#bind afun_auxE_Co to Ctrl+f
sub afun_auxE_Co { AfunAssign('AuxE_Co') }
#bind afun_auxE_Ap to F
sub afun_auxE_Ap { AfunAssign('AuxE_Ap') }
#bind afun_auxE_Pa to Ctrl+F
sub afun_auxE_Pa { AfunAssign('AuxE_Pa') }

#bind afun_Ref to r menu Arabic: Assign afun Ref
sub afun_Ref { AfunAssign('Ref') }
#bind afun_Ref_Co to Ctrl+r
sub afun_Ref_Co { AfunAssign('Ref_Co') }
#bind afun_Ref_Ap to R
sub afun_Ref_Ap { AfunAssign('Ref_Ap') }
#bind afun_Ref_Pa to Ctrl+R
sub afun_Ref_Pa { AfunAssign('Ref_Pa') }

#bind afun_Ante to t menu Arabic: Assign afun Ante
sub afun_Ante { AfunAssign('Ante') }
#bind afun_Ante_Co to Ctrl+t
sub afun_Ante_Co { AfunAssign('Ante_Co') }
#bind afun_Ante_Ap to T
sub afun_Ante_Ap { AfunAssign('Ante_Ap') }
#bind afun_Ante_Pa to Ctrl+T
sub afun_Ante_Pa { AfunAssign('Ante_Pa') }

#bind assign_parallel to key 1 menu Arabic: Suffix Parallel
sub assign_parallel {
  $this->{parallel}||='no-parallel';
  EditAttribute($this,'parallel');
}

#bind assign_paren to key 2 menu Arabic: Suffix Paren
sub assign_paren {
  $this->{paren}||='no-paren';
  EditAttribute($this,'paren');
}

#bind assign_arabfa to key 3 menu Arabic: Suffix ArabFa
sub assign_arabfa {
  $this->{arabfa}||='no-fa';
  EditAttribute($this,'arabfa');
}

#bind assign_arabspec to key 4 menu Arabic: Suffix ArabSpec
sub assign_arabspec {
  $this->{arabspec}||='no-spec';
  EditAttribute($this,'arabspec');
}

#bind assign_arabclause to key 5 menu Arabic: Suffix ArabClause
sub assign_arabclause {
  $this->{arabclause}||='no-clause';
  EditAttribute($this,'arabclause');
}

#bind thisToParent to Alt+Up menu Annotate: Current node up one level to grandparent
sub thisToParent {
  return unless $this->parent and $this->parent->parent;
  my $act=$this;
  my $p=$act->parent->parent;
  CutPaste($act,$p);
  $this=$act;
}

#bind thisToRBrother to Alt+Left menu Annotate: Current node to brother on the left
sub thisToRBrother {
  return unless $this->rbrother;
  my $act=$this;
  my $p=$this->rbrother;
  CutPaste($act,$p);
  $this=$act;
}

#bind thisToLBrother to Alt+Right menu Annotate: Current node to brother on the right
sub thisToLBrother {
  return unless $this->lbrother;
  my $act=$this;
  my $p=$this->lbrother;
  CutPaste($act,$p);
  $this=$act;
}

#bind thisToParentRBrother to Alt+Shift+Left menu Annotate: Current node to uncle on the left
sub thisToParentRBrother {
  return unless $this->parent and $this->parent->rbrother;
  my $act=$this;
  my $p=$this->parent->rbrother;
  CutPaste($act,$p);
  $this=$act;
}

#bind thisToParentLBrother to Alt+Shift+Right menu Annotate: Current node to uncle on the right
sub thisToParentLBrother {
  return unless $this->parent and $this->parent->lbrother;
  my $act=$this;
  my $p=$this->parent->lbrother;
  CutPaste($act,$p);
  $this=$act;
}

#bind thisToEitherBrother to Alt+Down menu Annotate: Current node to either side brother if unique
sub thisToEitherBrother {
  my $lb = $this->lbrother;
  my $rb = $this->rbrother;
  return unless $lb xor $rb;
  my $act=$this;
  my $p = $lb || $rb;
  CutPaste($act,$p);
  $this=$act;
}

#bind SwapNodesUp to Alt+Shift+Up menu Annotate: Current node exchanged with parent
sub SwapNodesUp {
  return unless $this;
  my $parent=$this->parent;
  return unless $parent;
  my $grandParent=$parent->parent;
  return unless $grandParent;
  CutPaste($this,$grandParent);
  CutPaste($parent,$this);
  $this=$parent;
}

#bind SwapNodesDown to Alt+Shift+Down menu Annotate: Current node exchanged with son if unique
sub SwapNodesDown {
  return unless $this;
  my @childs = $this->children();
  my $parent = $this->parent;
  return unless @childs == 1 and $parent;
  CutPaste($childs[0],$parent);
  CutPaste($this,$childs[0]);
  $this=$childs[0];
}

# ##################################################################################################
#
# ##################################################################################################

#unbind-key Ctrl+Shift+F1
#remove-menu Automatically assign afun to subtree
#unbind-key Ctrl+F9
#remove-menu Parse Slovene sentence
#unbind-key Ctrl+Shift+F9
#remove-menu Auto-assign analytical function to node
#unbind-key Ctrl+Shift+F10
#remove-menu Assign Slovene afun
#remove-menu Auto-assign analytical functions to tree

sub get_auto_afun {

    require Assign_arab_afun;

    my ($ra, $rb, $rc) = Assign_arab_afun::afun($_[0]);

    print STDERR "$node->{lemma} ($ra,$rb,$rc)\n";

    return $ra =~ /^\s*$/ ? '' : $ra;
}

### rebind PDT bindings used for Czech with Arabic ones
#bind request_auto_afun_node Ctrl+Shift+F9 menu Arabic: Request auto afun for current node
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

#bind request_auto_afun_subtree to Ctrl+Shift+F10 menu Arabic: Request auto afun for current subtree
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

#bind hooks_request_mode Ctrl+Shift+F8 menu Arabic: Toggle request mode for auto afuns
sub hooks_request_mode {

    $hooks_request_mode = not $hooks_request_mode;

    $Redraw = 'none';
    ChangingFile(0);
}

sub get_value_line_hook {

    my ($fsfile, $index) = @_;
    my ($nodes, $words);

    ($nodes, undef) = $fsfile->nodes($index, $this, 1);

    $words = [ [ $nodes->[0]->{'origf'}, $nodes->[0], '-foreground => darkmagenta' ],
               map {
                        [ " " ],
                        [ $_->{'origf'}, $_ ],
               }
               grep { defined $_->{'origf'} and $_->{'origf'} ne '' } @{$nodes}[1 .. $#{$nodes}] ];

    @{$words} = reverse @{$words} if $main::treeViewOpts->{reverseNodeOrder};

    return $words;
}

sub highlight_value_line_tag_hook {

    my $node = $grp->{currentNode};

    $node = PrevNodeLinear($node, 'ord') until !$node or defined $node->{'origf'} and $node->{'origf'} ne '';

    return $node;
}

sub node_release_hook {

    return unless $hooks_request_mode;

    my ($node, $done) = @_;

    my @line;

    while ($done->{'afun'} eq '???' and $done->{'afunaux'} eq '') {

        unshift @line, $done;

        $done = $done->parent();
    }

    request_auto_afun_node($_) foreach @line, $node;
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

# root style hook
# here used only to check if the sentence contains a node with afun=Ante
sub root_style_hook {

}

# node styles to draw extra arrows
sub node_style_hook {

    my ($node, $styles) = @_;

    if ($node->{'arabspec'} eq 'Ref') {

        my $T = << 'TARGET';
[!
    return Analytic::referring_Ref($this);
!]
TARGET

        my $coords = << "COORDS";
n,n,
(n + x$T) / 2 + (abs(xn - x$T) > abs(yn - y$T) ? 0 : -40),
(n + y$T) / 2 + (abs(yn - y$T) > abs(xn - x$T) ? 0 :  40),
x$T,y$T
COORDS

    AddStyle($styles, 'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $coords,    # coords for our line
             -arrow => '&last',
             -dash => '&_',
             -width => '&1',
             -fill => '&#C000D0',   # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );
  }


  if ($node->{arabspec} eq 'Msd') {

      my $T = << 'TARGET';
[!
    return Analytic::referring_Msd($this);
!]
TARGET

        my $coords = << "COORDS";
n,n,
(n + x$T) / 2 + (abs(xn - x$T) > abs(yn - y$T) ? 0 : -40),
(n + y$T) / 2 + (abs(yn - y$T) > abs(xn - x$T) ? 0 :  40),
x$T,y$T
COORDS

    AddStyle($styles, 'Line',
             -coords => 'n,n,p,p&'. # coords for the default edge to parent
                        $coords,    # coords for our line
             -arrow => '&last',
             -dash => '&_',
             -width => '&1',
             -fill => '&#FFA000',   # color
             -smooth => '&1'        # approximate our line with a smooth curve
            );
  }
}

# ##################################################################################################
#
# ##################################################################################################

sub referring_Ref {

    my $this = defined $_[0] ? $_[0] : $this;

    my $head = $this->parent;

    until ( (not $head) or (#$head->{afun} =~ /^(?:Atr|Atv)$/ and
                            ($head->{arabclause} !~ /^no-|^$/ or $head->{tag} =~ /^V/))
                        or ($head->{afun} =~ /^(?:Pred[CEP]?|Pnom)$/)
                        or ($head->{afun} =~ /^(?:Coord|Apos)$/ and grep {

                            $_->{parallel} =~ /^(?:Co|Ap)$/

                            and (  (#$_->{afun} =~ /^(?:Atr|Atv)$/ and
                                    ($_->{arabclause} !~ /^no-|^$/ or $_->{tag} =~ /^V/))
                                or ($_->{afun} =~ /^(?:Pred[CEP]?|Pnom)$/) )

                            } $head->children()) ) {

        $head = $head->parent();
        last if not defined $attr and $head->{afun} eq 'Atr';   # attributive pseudo-clause .. approximation only
    }

    if ($head) {

        if ($head->{afun} eq 'Pnom') {                          # needs attention since {Pred} <- [Pnom] = [Pnom]

            my $pnom = $head;

            if ($pnom->{parallel} =~ /^(?:Co|Ap)$/) {

                do {

                    $pnom = $pnom->parent();
                }
                while $pnom and $pnom->{parallel} =~ /^(?:Co|Ap)$/ and $pnom->{afun} =~ /^(?:Coord|Apos)$/;

                $pnom = $head unless $pnom and $pnom->{afun} =~ /^(?:Coord|Apos)$/;
            }

            $head = $pnom->parent() if $pnom->parent() and ( $pnom->parent()->{arabclause} =~ /^Pred[CEP]?$/
                                       or $_->{tag} =~ /^V/ or $pnom->parent()->{afun} =~ /^Pred[CEP]?$/ );
        }

        my $ante = $head;

        $ante = $ante->following($head) while $ante and $ante->{afun} ne 'Ante';

        unless ($ante) {

            $head = $head->parent() while $head->{parallel} =~ /^(?:Co|Ap)$/;

            $ante = $head;

            $ante = $ante->following($head) while $ante and $ante->{afun} ne 'Ante';
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

    return 'stop' unless $_[0] =~ /^(?:afun|parallel|paren|arabclause|arabfa|arabspec|comment|commentA|err1|err2)$/;
}

#remove-menu Edit annotator's comment
#bind edit_commentA to exclam menu Annotate: Edit annotator's comment
sub edit_commentA {

    $Redraw = 'none';
    ChangingFile(0);

    my $comment = $grp->{FSFile}->FS->exists('comment') ? 'comment' : $grp->{FSFile}->FS->exists('commentA') ? 'commentA' : undef;

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

#remove-menu Display default attributes
#bind default_ar_attrs to F8 menu Annotate: Show / hide morphological tags
sub default_ar_attrs {

    return unless $grp->{FSFile};

    my $pattern = '#{custom2}${tag}';

    my @original = GetDisplayAttrs();

    my @filtered = grep { $_ ne $pattern } @original;

    SetDisplayAttrs( @filtered, @original == @filtered ? $pattern : () );

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

    do { $this = $this->following() } while $this and $this->{afun} ne '???';

    $this = $node unless $this->{afun} eq '???';

    $Redraw = 'none';
    ChangingFile(0);
}

#bind annotate_previous Shift+space menu Annotate: Move to previous ???
sub annotate_previous {

    my $node = $this;

    do { $this = $this->previous() } while $this and $this->{afun} ne '???';

    $this = $node unless $this->{afun} eq '???';

    $Redraw = 'none';
    ChangingFile(0);
}

#bind accept_auto_afun Ctrl+space menu Arabic: Accept auto-assigned annotation
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

#bind unset_afun to question menu Arabic: Unset afun to ???
sub unset_afun {

    if ($this->{'afun'} eq 'AuxS') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'afun'} = '???';
        $this->{'afunaux'} = '';

        $Redraw = 'tree';
    }
}

#bind unset_request_afun to Ctrl+question menu Arabic: Unset and request auto afun
sub unset_request_afun {

    if ($this->{'afun'} eq 'AuxS') {

        $Redraw = 'none';
        ChangingFile(0);
    }
    else {

        $this->{'afun'} = '???';
        $this->{'afunaux'} = get_auto_afun($this);

        $Redraw = 'tree';
    }
}
