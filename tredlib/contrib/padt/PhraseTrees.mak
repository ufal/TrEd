# ########################################################################## Otakar Smrz, 2005/07/13
#
# PhraseTrees Context for the TrEd Environment #####################################################

# $Id$

package PhraseTrees;

use 5.008;

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

# ##################################################################################################
#
# ##################################################################################################

#binding-context PhraseTrees

import TredMacro;

our ($justify_mode);

# ##################################################################################################
#
# ##################################################################################################

#bind tree_justify_mode Ctrl+j menu Toggle Tree Justify Mode
sub tree_justify_mode {

    $justify_mode = $justify_mode eq 'justify' ? '' : 'justify';

    ChangingFile(0);
}

sub get_nodelist_hook {

    my ($fsfile, $index, $recent, $show_hidden) = @_;
    my ($nodes, $current);

    my $tree = $fsfile->tree($index);

    ($nodes, $current) = $fsfile->nodes($index, $recent, $show_hidden);

    @{$nodes} = sort { $a->{'ord_just'} <=> $b->{'ord_just'} } @{$nodes} if $justify_mode;

    @{$nodes} = reverse @{$nodes} if $main::treeViewOpts->{reverseNodeOrder};

    return [[@{$nodes}], $current];
}

sub get_value_line_hook {

    my ($fsfile, $index) = @_;
    my ($nodes, $words);

    ($nodes, undef) = $fsfile->nodes($index, $this, 1);

    $words = [ [ '#' . ($index + 1), $nodes->[0], '-foreground => darkmagenta'],
               map {
                        [ " " ],
                        [ $main::treeViewOpts->{reverseNodeOrder} ? $_->{'form'} : $_->{'token'}, $_ ],
               }
               grep { defined $_->{'form'} and $_->{'form'} ne '' } @{$nodes} ];

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

    my $head = $this->parent();

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

#bind edit_commentA to exclam menu Edit the 'other' Field
sub edit_commentA {

    $Redraw = 'none';
    ChangingFile(0);

    my $comment = $grp->{FSFile}->FS->exists('other') ? 'other' :
                  $grp->{FSFile}->FS->exists('commentA') ? 'commentA' : undef;

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

#bind toggle_tag_1 to F1 menu Show / Hide Morphological Tags 1
sub toggle_tag_1 {

    return unless $grp->{FSFile};

    my $pattern = '#{custom3}${tag_1}';

    my ($hint, $original) = GetStylesheetPatterns(GetCurrentStylesheet());

    my @filtered = grep { $_ ne $pattern } @{$original};

    SetStylesheetPatterns([ $hint, [ @filtered, @{$original} == @filtered ? $pattern : () ] ]);

    ChangingFile(0);

    return 1;
}

#bind toggle_tag_2 to F2 menu Show / Hide Morphological Tags 2
sub toggle_tag_2 {

    return unless $grp->{FSFile};

    my $pattern = '#{custom4}${tag_2}';

    my ($hint, $original) = GetStylesheetPatterns(GetCurrentStylesheet());

    my @filtered = grep { $_ ne $pattern } @{$original};

    SetStylesheetPatterns([ $hint, [ @filtered, @{$original} == @filtered ? $pattern : () ] ]);

    ChangingFile(0);

    return 1;
}

#bind toggle_tag_3 to F3 menu Show / Hide Morphological Tags 3
sub toggle_tag_3 {

    return unless $grp->{FSFile};

    my $pattern = '#{custom5}${tag_3}';

    my ($hint, $original) = GetStylesheetPatterns(GetCurrentStylesheet());

    my @filtered = grep { $_ ne $pattern } @{$original};

    SetStylesheetPatterns([ $hint, [ @filtered, @{$original} == @filtered ? $pattern : () ] ]);

    ChangingFile(0);

    return 1;
}

#bind direction_RTL to Ctrl+r menu Display Trees Right-to-Left
sub direction_RTL {

    $support_unicode=($Tk::VERSION gt 804.00);

    # does the OS or TrEd+Tk support propper arabic rendering
    $ArabicRendering=($^O eq 'MSWin32' or $support_unicode);

    # if not, at least reverse all non-asci strings
    unless ($ArabicRendering) {
      print STDERR "Arabic: Forcing right-to-left\n";
      $TrEd::Convert::lefttoright=0;
    }

    $TrEd::Config::valueLineReverseLines=1;
    $TrEd::Config::valueLineAlign='right';

    # display nodes in the reversed order
    print STDERR "Arabic: Forcing reverseNodeOrder\n";
    $main::treeViewOpts->{reverseNodeOrder}=1;
    foreach (@{$grp->{framegroup}->{treeWindows}}) {
      $_->treeView->apply_options($main::treeViewOpts);
    }

    # setup file encodings
    if ($^O eq 'MSWin32') {
      $TrEd::Convert::outputenc='windows-1256';
      print STDERR $TrEd::Convert::outputenc,"\n";
    } elsif ($support_unicode) {
      $TrEd::Convert::outputenc='iso10646-1';
      print STDERR $TrEd::Convert::outputenc,"\n";
    } else {
      $TrEd::Convert::outputenc='iso-8859-6';
      print STDERR $TrEd::Convert::outputenc,"\n";
    }
    $TrEd::Convert::inputenc='windows-1256';

    # setup CSTS header
    Csts2fs::setupPADTAR();

    # align node labels to right for more natural look
    $TrEd::TreeView::DefaultNodeStyle{NodeLabel}=
      [-valign => 'top', -halign => 'right'];
    $TrEd::TreeView::DefaultNodeStyle{Node}=
      [-textalign => 'right'];

    # reload config
    main::read_config();
    eval {
      main::reconfigure($grp->{framegroup});
    };

    Redraw_All();
}

#bind direction_LTR to Ctrl+l menu Display Trees Left-to-Right
sub direction_LTR {

    $support_unicode=($Tk::VERSION gt 804.00);

    # does the OS or TrEd+Tk support propper arabic rendering
    $ArabicRendering=($^O eq 'MSWin32' or $support_unicode);

    # if not, at least reverse all non-asci strings
    unless ($ArabicRendering) {
      print STDERR "Arabic: Forcing right-to-left\n";
      $TrEd::Convert::lefttoright=0;
    }

    $TrEd::Config::valueLineReverseLines=0;
    $TrEd::Config::valueLineAlign='left';

    # display nodes in the reversed order
    print STDERR "Arabic: Forcing reverseNodeOrder\n";
    $main::treeViewOpts->{reverseNodeOrder}=0;
    foreach (@{$grp->{framegroup}->{treeWindows}}) {
      $_->treeView->apply_options($main::treeViewOpts);
    }

    # setup file encodings
    if ($^O eq 'MSWin32') {
      $TrEd::Convert::outputenc='windows-1256';
      print STDERR $TrEd::Convert::outputenc,"\n";
    } elsif ($support_unicode) {
      $TrEd::Convert::outputenc='iso10646-1';
      print STDERR $TrEd::Convert::outputenc,"\n";
    } else {
      $TrEd::Convert::outputenc='iso-8859-6';
      print STDERR $TrEd::Convert::outputenc,"\n";
    }
    $TrEd::Convert::inputenc='windows-1256';

    # setup CSTS header
    Csts2fs::setupPADTAR();

    # align node labels to right for more natural look
    $TrEd::TreeView::DefaultNodeStyle{NodeLabel}=
      [-valign => 'top', -halign => 'left'];
    $TrEd::TreeView::DefaultNodeStyle{Node}=
      [-textalign => 'left'];

    # reload config
    main::read_config();
    eval {
      main::reconfigure($grp->{framegroup});
    };

    Redraw_All();
}

# ##################################################################################################
#
# ##################################################################################################

use List::Util 'reduce';

#bind move_word_home Home menu Move to First Word
sub move_word_home {

    my $fs = $grp->{FSFile}->FS();

    $this = reduce { $a->{'ord'} < $b->{'ord'} ? $a : $b } $root->visible_descendants($fs);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_word_end End menu Move to Last Word
sub move_word_end {

    my $fs = $grp->{FSFile}->FS();

    $this = reduce { $a->{'ord'} > $b->{'ord'} ? $a : $b } $root->visible_descendants($fs);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_deep_home Ctrl+Home menu Move to Rightmost Descendant
sub move_deep_home {

    my $fs = $grp->{FSFile}->FS();

    $this = $this->leftmost_descendant();

    $this = $this->previous_visible($fs) if $fs->isHidden($this);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_deep_end Ctrl+End menu Move to Leftmost Descendant
sub move_deep_end {

    my $fs = $grp->{FSFile}->FS();

    $this = $this->rightmost_descendant();

    $this = $this->following_visible($fs) ||
            $this->previous_visible($fs) if $fs->isHidden($this);

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

#bind move_to_root Shift+Up menu Move Up to Root
sub move_to_root {

    $this = $root unless $root == $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_to_fork Shift+Down menu Move Down to Fork
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

# ##################################################################################################
#
# ##################################################################################################

1;


=head1 NAME

PhraseTrees - Context for Annotation of Constituency Syntax in the TrEd Environment


=head1 REVISION

    $Revision$       $Date$


=head1 DESCRIPTION

For reference, see the list of PhraseTrees macros and key-bindings in the User-defined menu item in TrEd.


=head1 SEE ALSO

TrEd Tree Editor L<http://ufal.mff.cuni.cz/~pajas/tred/>

Prague Arabic Dependency Treebank L<http://ufal.mff.cuni.cz/padt/online/>


=head1 AUTHOR

Otakar Smrz, L<http://ufal.mff.cuni.cz/~smrz/>

    eval { 'E<lt>' . ( join '.', qw 'otakar smrz' ) . "\x40" . ( join '.', qw 'mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright 2005-2007 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
