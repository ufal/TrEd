# ########################################################################## Otakar Smrz, 2004/03/05
#
# MorphoTrees Context for the TrEd Environment #####################################################

# $Id$

package MorphoTrees;

use 5.008;

use strict;

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

# ##################################################################################################
#
# ##################################################################################################

#binding-context MorphoTrees

BEGIN { import TredMacro; }

our ($this, $root, $grp);

our ($Redraw);

our ($paragraph_hide_mode, $entity_hide_mode, $level_guide_mode) = ('', '', 0);

our ($dims, $fill) = (10, ' ' x 4);

# ##################################################################################################
#
# ##################################################################################################

sub node_release_hook {

    return 'stop' if defined $_[0]->{'type'};
}

sub get_nodelist_hook {

    my ($fsfile, $index, $recent, $show_hidden) = @_;
    my ($nodes, $current);

    my $tree = $fsfile->tree($index);

    if ($tree->{'type'} eq 'paragraph') {

        $tree->{'hide'} = '' unless defined $tree->{'hide'};

        if ($tree->{'hide'} ne $paragraph_hide_mode) {

            $tree->{'hide'} = $paragraph_hide_mode;
            $current = $tree;

            if ($paragraph_hide_mode eq 'hidden') {

                while ($current = $current->following()) {

                    $current->{'hide'} = $current->{'apply_m'} > 0 ? 'hide' : '';
                }
            }
            else {

                while ($current = $current->following()) {

                    $current->{'hide'} = '';
                }
            }
        }
    }
    else {

        $tree->{'hide'} = '' unless defined $tree->{'hide'};

        if ($tree->{'hide'} ne $entity_hide_mode) {

            $tree->{'hide'} = $entity_hide_mode;
            $current = $tree;

            if ($entity_hide_mode eq 'hidden') {

                while ($current = $current->following()) {

                    $current->{'hide'} = 'hide' if defined $current->{'tips'} and $current->{'tips'} == 0;
                }
            }
            else {

                while ($current = $current->following()) {

                    $current->{'hide'} = '' if defined $current->{'tips'} and $current->{'tips'} == 0;
                }
            }
        }
    }

    ($nodes, $current) = $fsfile->nodes($index, $recent, $show_hidden);

    @{$nodes} = reverse @{$nodes} if $main::treeViewOpts->{reverseNodeOrder};

    return [[@{$nodes}], $current];
}

sub get_value_line_hook {

    my ($fsfile, $index) = @_;
    my ($nodes, $words);

    my $tree = $fsfile->tree($index);

    if ($tree->{'type'} eq 'paragraph') {

        ($nodes, undef) = $fsfile->nodes($index, $this, 1);

        $words = [ [ $tree->{'id'} . " " . $tree->{'input'}, $tree, '-foreground => darkmagenta' ],
                   map {
                            [ " " ],
                            [ $_->{'input'}, (

                                $paragraph_hide_mode eq 'hidden'

                                      ? ( $_->{'apply_m'} > 0
                                            ? ( $fsfile->tree($_->{'ref'} - 1), '-foreground => gray' )
                                            : ( $_, '-foreground => black' ) )
                                      : ( $_->{'apply_m'} > 0
                                            ? ( $_, '-foreground => red' )
                                            : ( $_, '-foreground => black' ) )
                                ) ]

                        } grep { $_->{'type'} eq 'word_node' } @{$nodes} ];
    }
    else {

        my $para = $fsfile->tree($tree->{'ref'} - 1);

        my $last = (split /[^0-9]+/, $para->{'par'})[1];
        my $next = 1;

        $nodes = [ map { $fsfile->tree($_) } $tree->{'ref'} .. ( $tree->{'ref'} == $last ? $grp->{FSFile}->lastTreeNo : $last - 2 ) ];

        $words = [ [ $para->{'id'} . " " . $para->{'input'}, '#' . $tree->{'ref'}, '-foreground => purple' ],
                   map {
                            [ " " ],
                            [ $_->{'input'}, '#' . ( $tree->{'ref'} + $next++ ), $_ == $tree ? ( $_, '-underline => 1' ) : () ],

                        } grep { $_->{'type'} eq 'entity' } @{$nodes} ];
    }

    @{$words} = reverse @{$words} if $main::treeViewOpts->{reverseNodeOrder};

    return $words;
}

sub highlight_value_line_tag_hook {

    return $grp->{root} if $grp->{root}->{'type'} eq 'entity';

    my $node = $grp->{currentNode};

    $node = $node->parent() until !$node or $node->{'type'} eq 'word_node' or $node->{'type'} eq 'paragraph';

    return $node;
}

sub value_line_doubleclick_hook {

    return if $grp->{root}->{'type'} eq 'paragraph';

    my ($index) = map { $_ =~ /^#([0-9]+)/ ? $1 : () } @_;

    return 'stop' unless defined $index;

    GotoTree($index);
    Redraw();
    main::centerTo($grp, $grp->{currentNode});

    return 'stop';
}

sub node_doubleclick_hook {

    $grp->{currentNode} = $_[0];

    if ($_[1] eq 'Shift') {

        main::doEvalMacro($grp, __PACKAGE__ . '->switch_either_context');
    }
    else {

        main::doEvalMacro($grp, __PACKAGE__ . '->annotate_morphology');
    }

    return 'stop';
}

sub node_click_hook {

    $grp->{currentNode} = $_[0];

    if ($_[1] eq 'Shift') {

        main::doEvalMacro($grp, __PACKAGE__ . '->switch_either_context');
    }
    else {

        main::doEvalMacro($grp, __PACKAGE__ . '->annotate_morphology_click');
    }

    return 'stop';
}

#bind annotate_morphology_click to Ctrl+space menu Annotate as if by Clicking
sub annotate_morphology_click {

    annotate_morphology('click');
}

#bind switch_either_context Shift+space menu Switch Either Context
sub switch_either_context {

    $Redraw = 'win' if $_[0] eq __PACKAGE__;

    my $quick = $_[0];
    my @refs;

    if ($root->{'type'} eq 'paragraph') {

        if ($this->{'type'} eq 'paragraph') {

            GotoTree((split /[^0-9]+/, $root->{'par'})[0]);
        }
        elsif ($this->{'type'} eq 'word_node') {

            GotoTree($this->{'ref'});
        }
        else {

            $refs[0] = $this->{'ref'};

            if ($this->{'type'} eq 'lemma_id') {

                GotoTree($this->parent()->{'ref'});
            }
            else {

                GotoTree($this->parent()->parent()->{'ref'});
            }

            $this = ($root->descendants())[$refs[0] - 1];
        }
    }
    else {

        ($refs[0]) = $root->{'id'} =~ /([0-9]+)$/;

        $refs[1] = $this->{'ord'} unless $quick eq 'quick';

        GotoTree($root->{'ref'});

        $this = ($root->children())[$refs[0] - 1];

        unless ($quick eq 'quick') {

            ($refs[2]) = grep { $_->{'ref'} eq $refs[1] } $this->descendants();

            $this = $refs[2] if defined $refs[2];
        }
    }

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_to_prev_paragraph Shift+Prior menu Move to Prev Paragraph
sub move_to_prev_paragraph {

    unless ($root->{'type'} eq 'paragraph') {

        GotoTree($root->{'ref'});
    }

    GotoTree((split /[^0-9]+/, $root->{'par'})[0]);

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_to_next_paragraph Shift+Next menu Move to Next Paragraph
sub move_to_next_paragraph {

    unless ($root->{'type'} eq 'paragraph') {

        GotoTree($root->{'ref'});
    }

    GotoTree((split /[^0-9]+/, $root->{'par'})[1]);

    $Redraw = 'win';
    ChangingFile(0);
}

#bind move_word_home Home menu Move to First Word
sub move_word_home {

    if ($root->{'type'} eq 'paragraph') {

        $this = (grep { $_->{'hide'} ne 'hide' } $root->children())[0];

        $Redraw = 'none';
    }
    else {

        switch_either_context('quick');
        $this = ($root->children())[0];
        switch_either_context();

        $Redraw = 'win';
    }

    ChangingFile(0);
}

#bind move_word_end End menu Move to Last Word
sub move_word_end {

    if ($root->{'type'} eq 'paragraph') {

        $this = (grep { $_->{'hide'} ne 'hide' } $root->children())[-1];

        $Redraw = 'none';
    }
    else {

        switch_either_context('quick');
        $this = ($root->children())[-1];
        switch_either_context();

        $Redraw = 'win';
    }

    ChangingFile(0);
}

#bind move_next_home Ctrl+Home menu Move to First on Level
sub move_next_home {

    my $node = $this;
    my $level = $node->level();

    my ($done, @children);

    do {

        $done = $node if $level == $node->level();

        $node = PrevVisibleNode($node);
    }
    while $node;

    if ($done == $this and @children = grep { $_->{'hide'} ne 'hide' } $this->children()) {

        $this = $children[0];
    }
    else {

        $this = $done;
    }

    $Redraw = 'none';
    ChangingFile(0);
}

#bind move_next_end Ctrl+End menu Move to Last on Level
sub move_next_end {

    my $node = $this;
    my $level = $node->level();

    my ($done, @children);

    do {

        $done = $node if $level == $node->level();

        $node = NextVisibleNode($node);
    }
    while $node;

    if ($done == $this and @children = grep { $_->{'hide'} ne 'hide' } $this->children()) {

        $this = $children[-1];
    }
    else {

        $this = $done;
    }

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
    switch_either_context('quick');
    $this = $root;

    $Redraw = 'win';
    ChangingFile(0);
}

#bind tree_hide_mode Ctrl+equal menu Toggle Tree Hide Mode
sub tree_hide_mode {

    if ($root->{'type'} eq 'paragraph') {

        $paragraph_hide_mode = $paragraph_hide_mode eq 'hidden' ? '' : 'hidden';
    }
    else {

        $entity_hide_mode = $entity_hide_mode eq 'hidden' ? '' : 'hidden';
    }

    ChangingFile(0);
}

#bind level_guide_mode_none Ctrl+F1 menu Level Guide Mode Normal
sub level_guide_mode_none {

    $level_guide_mode = 0;

    ChangingFile(0);
}

#bind level_guide_mode_fine Ctrl+F2 menu Level Guide Mode Strict
sub level_guide_mode_fine {

    $level_guide_mode = 1;

    ChangingFile(0);
}

#bind level_guide_mode_high Ctrl+F3 menu Level Guide Mode Xtreme
sub level_guide_mode_high {

    $level_guide_mode = 2;

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

#bind follow_apply_m_up Ctrl+Up menu Follow Annotation Up
sub follow_apply_m_up {

    $Redraw = 'none';
    ChangingFile(0);

    my $node = $this->parent();

    return unless $node;

    if ($node->{'apply_m'} > 0) {

        $this = $node;

        return;
    }

    my $level = $node->level();

    my $done = $node;

    { do {

        $node = NextVisibleNode($node) until not $node or $node->level() == $level;
        $done = PrevVisibleNode($done) until not $done or $done->level() == $level;

        if ($node) {

            if ($node->{'apply_m'} > 0) {

                $this = $node;
                last;
            }

            $node = NextVisibleNode($node);
        }

        if ($done) {

            if ($done->{'apply_m'} > 0) {

                $this = $done;
                last;
            }

            $done = PrevVisibleNode($done);
        }
    }
    while $node or $done; }
}

#bind follow_apply_m_down Ctrl+Down menu Follow Annotation Down
sub follow_apply_m_down {

    my $node = $this;
    my (@children);

    while (@children = $node->children()) {

        @children = grep { $_->{'hide'} ne 'hide' and $_->{'apply_m'} > 0 } @children;

        last unless @children == 1;

        $node = $children[0];
    }

    $node = $children[0] if @children;

    $this = $node unless $node == $this;

    $Redraw = 'none';
    ChangingFile(0);
}

#bind follow_apply_m_right Ctrl+Right menu Follow Annotation Right
sub follow_apply_m_right {

    $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode() ?
        ctrl_currentLeftWholeLevel() :
        ctrl_currentRightWholeLevel();

    $Redraw = 'none';
    ChangingFile(0);
}

#bind follow_apply_m_left Ctrl+Left menu Follow Annotation Left
sub follow_apply_m_left {

    $main::treeViewOpts->{reverseNodeOrder} && ! InVerticalMode() ?
        ctrl_currentRightWholeLevel() :
        ctrl_currentLeftWholeLevel();

    $Redraw = 'none';
    ChangingFile(0);
}

sub ctrl_currentRightWholeLevel {    # modified copy of main::currentRightWholeLevel

    my $node = $this;
    my $level = $node->level();

    do {

        $node = NextVisibleNode($node);
    }
    until not $node or $level == $node->level() and $node->{'apply_m'} > 0;

    $this = $node if $node;

    ChangingFile(0);
}

sub ctrl_currentLeftWholeLevel {     # modified copy of main::currentLeftWholeLevel

    my $node = $this;
    my $level = $node->level();

    do {

        $node = PrevVisibleNode($node);
    }
    until not $node or $level == $node->level() and $node->{'apply_m'} > 0;

    $this = $node if $node;

    ChangingFile(0);
}

#bind invoke_undo BackSpace menu Undo Annotate / Restrict
sub invoke_undo {

    warn 'Undoooooing ;)';

    main::undo($grp);
    $this = $grp->{currentNode};

    ChangingFile(0);
}

#bind invoke_redo Shift+BackSpace menu Redo Annotate / Restrict
sub invoke_redo {

    warn 'Redoooooing ;)';

    main::re_do($grp);
    $this = $grp->{currentNode};

    ChangingFile(0);
}

#bind edit_comment to exclam menu Edit Annotation Comment
sub edit_comment {

    $Redraw = 'none';
    ChangingFile(0);

    my $comment = $grp->{FSFile}->FS->exists('comment') ? 'comment' : undef;

    unless (defined $comment) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "There is no 'comment' attribute in this file's format!$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    my $switch = $this->{'type'} eq 'token_node' || $this->{'type'} eq 'lemma_id';

    if ($switch and not $this->{'apply_m'} > 0) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "This node must be annotated in order to receive comments!$fill",
            -title => 'Error',
            -type => 'OK',
        );

        return;
    }

    switch_either_context() if $switch;

    my $value = $this->{$comment};

    $value = main::QueryString($grp->{framegroup}, "Enter the comment", $comment, $value);

    if (defined $value) {

        $this->{$comment} = $value;

        $Redraw = 'tree';
        ChangingFile(1);
    }

    switch_either_context() if $switch;

    $this->{$comment} = $value if defined $value;
}

# ##################################################################################################
#
# ##################################################################################################

#bind annotate_morphology to space menu Annotate Morphology
sub annotate_morphology {

    $Redraw = 'none' if $_[0] eq __PACKAGE__;
    ChangingFile(0);

    # indicated below when the file or the redraw mode actually change

    if ($root->{'type'} eq 'paragraph') {

        if ($this->{'type'} eq 'paragraph') {

            GotoTree((split /[^0-9]+/, $this->{'par'})[1]);
        }
        else {

            switch_either_context();
        }

        $Redraw = 'win';

        return;
    }

    my ($quick, @tips) = @_;
    my (@children, $diff, $reflect);

    my $node = $this;

    while (@children = $node->children()) {

        @children = grep { $_->{'hide'} ne 'hide' and ( not defined $_->{'tips'} or $_->{'tips'} > 0 ) } @children;

        last unless @children == 1;

        $node = $children[0];
    }

    unless (@children) {

        if ($node->{'type'} eq 'token_node') {

            $diff = $node->{'apply_m'} == 0 ? 1 : $node == $this ? -1 : 0;

            unless ($diff == 0) {

                $node->{'apply_m'} += $diff;

                $reflect = reflect_choice($node, $diff);

                $Redraw = 'file';
                ChangingFile(1);
            }

            if ($diff == -1) {

                while ($node = $node->parent()) {

                    if ($node->{'type'} eq 'partition') {

                        @children = grep { $_->{'apply_m'} < 1 } $node->children();

                        last unless @children and $node->{'apply_m'} > 0;
                    }

                    $node->{'apply_m'}--;
                }

                unless ($node) {    # ~~ # $root->parent(), $this->following() etc. are defined # ~~ #

                    $reflect->{'apply_m'} = $root->{'apply_m'};
                    $reflect->{'hide'} = $paragraph_hide_mode eq 'hidden' && $reflect->{'apply_m'} > 0 ? 'hide' : '';
                }
            }
            else {

                $node->{'apply_m'} = 1;

                while ($node = $node->parent()) {

                    if ($node->{'type'} eq 'partition') {

                        @children = grep { $_->{'apply_m'} < 1 } $node->children();

                        last if @children or $node->{'apply_m'} == 1 or $diff == 0;
                    }

                    $node->{'apply_m'} += $diff;
                }

                if (@children) {

                    $this = defined $tips[0] && ( grep { $tips[0] == $_ } @children ) ? $tips[0] : $children[0];

                    if (defined $this->{'tips'} and $this->{'tips'} == 0) {

                        my $myRedraw = $Redraw;

                        remove_inherited_restrict();

                        $Redraw = $myRedraw if $myRedraw eq 'file';
                    }

                    annotate_morphology($quick eq 'click' ? $quick : undef);
                }
                else {

                    unless ($node or $diff == 0) {  # ~~ # $root->parent(), $this->following() etc. are defined # ~~ #

                        $reflect->{'apply_m'} = $root->{'apply_m'};
                        $reflect->{'hide'} = $paragraph_hide_mode eq 'hidden' && $reflect->{'apply_m'} > 0 ? 'hide' : '';
                    }

                    unless (defined $quick and $quick eq 'click') {

                        NextTree();

                        $Redraw = 'win' if $Redraw eq 'none';
                    }
                }
            }
        }
    }
    elsif ($level_guide_mode > 0) {

        if ($level_guide_mode > 1) {

            $this = defined $tips[0] && ( grep { $tips[0] == $_ } @children )
                        ? $tips[0]
                        : $children[0]->{'type'} eq 'lemma_id' ||
                          $children[0]->{'type'} eq 'partition' && @children > 1
                            ? $node
                            : $children[0];
        }
        else {

            $this = defined $tips[0] && ( grep { $tips[0] == $_ } @children )
                        ? $tips[0]
                        : $children[0]->{'type'} eq 'lemma_id'
                            ? $node
                            : $children[0];
        }
    }
    else {

        $this = defined $tips[0] && ( grep { $tips[0] == $_ } @children ) ? $tips[0] : $children[0];
    }
}


sub reflect_choice {

    my ($leaf, $diff) = @_;
    my ($roox, $thix) = ($root, $this);

    switch_either_context('quick');

#ifdef TRED

    main::save_undo($grp, main::prepare_undo($grp));

#endif

    my $reflect = $this;
    my $twig = $leaf->parent();

    my $node = get_the_node($reflect, $twig->{'ord'});

    if ($diff == -1) {

        my $clip = get_the_node($node, $leaf->{'ord'});

        CutNode($clip);
        CutNode($node) and $diff-- unless $node->children();

        $node = $root;

        do {

            $node->{'ord'} += $diff if $node->{'ord'} > $clip->{'ord'};
        }
        while $node = $node->following();
    }
    else {

        unless ($node->{'ref'} eq $twig->{'ord'}) {

            $node->{$_} = $twig->{$_} for qw 'form id type comment';
            $node->{'ref'} = $twig->{'ord'};
            $node->{'apply_m'} = 1;
        }

        $node = get_the_node($node, $leaf->{'ord'});

        unless ($node->{'ref'} eq $leaf->{'ord'}) {

            $node->{$_} = $leaf->{$_} for qw 'form id type comment gloss apply_t tag';
            $node->{'ref'} = $leaf->{'ord'};
            $node->{'apply_m'} = 1;
        }
    }

    switch_either_context();

    ($root, $this) = ($roox, $thix);

    return $reflect;
}


sub get_the_node {

    my ($parent, $id) = @_;

    my (@children, $node, $find, $i);

    if (@children = $parent->children()) {

        for ($i = -1; $i >= -@children; $i--) {

            last if $children[$i]->{'ref'} <= $id;
        }

        if ($i < -@children) {

            $node = $find = $children[0];

            while ($node = $node->following($children[0])) {

                $find = $node if $node->{'ord'} < $find->{'ord'};
            }

            $node = CutNode(NewLBrother($find));
            PasteNode($node, $parent);
        }
        elsif ($children[$i]->{'ref'} == $id) {

            $node = $children[$i];
        }
        else {

            $node = $find = $children[$i];

            while ($node = $node->following($children[$i])) {

                $find = $node if $node->{'ord'} > $find->{'ord'};
            }

            $node = CutNode(NewRBrother($find));
            PasteNode($node, $parent);
        }
    }
    else {

        $node = NewSon($parent);
    }

    return $node;
}


sub restrict {

    my @restrict = split //, length $_[0] == $dims ? $_[0] : '-' x $dims;
    my @inherit = split //, $_[1];

    return join '', map { $restrict[$_] eq '-' && defined $inherit[$_] ? $inherit[$_] : $restrict[$_] } 0 .. $#restrict;
}


sub restrict_hide {

    ChangingFile(0);

    return unless $root->{'type'} eq 'entity';

    $Redraw = 'tree';   # be careful in annotate_morphology()
    ChangingFile(1);

    my ($restrict, $context) = @_;

    my $node = $this->{'type'} eq 'token_node' ? $this->parent() : $this;
    my $roof = $node;

    my (@tips, %tips, $orig, $diff);

    if (defined $context) {

        if ($context eq 'remove inherited') {

            $node->{'inherit'} = '';
        }
        elsif ($context eq 'remove induced') {

            if ($node->{'restrict'} eq '') {

                $context = 'remove induced clear';
            }
            else {

                $node->{'restrict'} = '';

                if ($node->parent()) {

                    $node->{'inherit'} = restrict($node->parent()->{'restrict'}, $node->parent()->{'inherit'});
                    $node->{'inherit'} = '' if $node->{'inherit'} eq '-' x $dims;
                }
                else {

                    $node->{'inherit'} = '';
                }
            }
        }
    }

    $node->{'restrict'} = restrict($restrict, $node->{'restrict'}) unless $restrict eq '';

    while ($node = $node->following($roof)) {

        if ($context eq 'remove induced clear') {

            $node->{'restrict'} = '';
            $node->{'inherit'} = $node->parent()->{'inherit'};
        }
        else {

            $node->{'inherit'} = restrict($node->parent()->{'restrict'}, $node->parent()->{'inherit'});
            $node->{'inherit'} = '' if $node->{'inherit'} eq '-' x $dims;
        }

        if ($node->{'type'} eq 'token_node') {

            if (restrict($node->{'inherit'}, $node->{'tag'}) ne $node->{'tag'}) {

                $node->{'hide'} = 'hide';
            }
            else {

                $node->{'hide'} = '';
                unshift @tips, $node;
            }
        }
        else {

            $node->{'hide'} = $entity_hide_mode eq 'hidden' ? 'hide' : '';
            $node->{'tips'} = 0;
        }
    }

    $orig = defined $roof->{'tips'} && $roof->{'tips'} == 0 ? 0 : 1;
    $roof->{'tips'} = 0;

    while ($node = shift @tips) {

        next if $node == $roof;

        $node->{'hide'} = '';

        $node->parent()->{'tips'}++ unless $node->{'hide'} eq 'hide' or defined $node->{'tips'} and $node->{'tips'} == 0;
        $tips{$node->parent()} = $node->parent();

        unless (@tips) {

            @tips = values %tips;
            %tips = ();
        }
    }

    $node = $roof;

    { do {

        last if $node == $root;     # ~~ # $root->parent(), $this->following() etc. are defined # ~~ # never hide the root

        $node->{'hide'} = $entity_hide_mode eq 'hidden' && $node->{'tips'} == 0 ? 'hide' : '';

        if (defined $node->parent()->{'tips'}) {    # optimizing, if this is necessary ^^

            $diff = ( $node->{'tips'} > 0 ? 1 : 0 ) - $orig;
            $orig = $node->parent()->{'tips'} > 0 ? 1 : 0;
            $node->parent()->{'tips'} += $diff;
        }
        else {

            $orig = 1;
            $node->parent()->{'tips'} = grep { not defined $_->{'tips'} or $_->{'tips'} > 0 } $node->parent()->children();
        }
    }
    while $node = $node->parent(); }

    ($this, @tips) = ($roof, $this);

    annotate_morphology(undef, @tips) if $this->{'tips'} > 0 and not defined $context;
}


#bind remove_induced_restrict Escape menu Remove Induced Restrict
sub remove_induced_restrict {

    restrict_hide('', 'remove induced');
}


#bind remove_inherited_restrict Shift+Escape menu Remove Inherited Restrict
sub remove_inherited_restrict {

    restrict_hide('-' x $dims, 'remove inherited');
}


# ##################################################################################################
#
# ##################################################################################################

#bind restrict_case_nom 1 menu Restrict Case Nominative
sub restrict_case_nom {
    restrict_hide('--------1-');
}

#bind restrict_case_gen 2 menu Restrict Case Genitive
sub restrict_case_gen {
    restrict_hide('--------2-');
}

#bind restrict_case_acc 4 menu Restrict Case Accusative
sub restrict_case_acc {
    restrict_hide('--------4-');
}

#bind restrict_state_i i menu Restrict State Indefinite
sub restrict_state_i {
    restrict_hide('---------I');
}

#bind restrict_state_d d menu Restrict State Definite
sub restrict_state_d {
    restrict_hide('---------D');
}

#bind restrict_state_a A menu Restrict State Absolute
sub restrict_state_a {
    restrict_hide('---------A');
}

#bind restrict_state_r r menu Restrict State Reduced
sub restrict_state_r {
    restrict_hide('---------R');
}

#bind restrict_state_c C menu Restrict State Complex
sub restrict_state_c {
    restrict_hide('---------C');
}

#bind restrict_state_l L menu Restrict State Lifted
sub restrict_state_l {
    restrict_hide('---------L');
}

#bind restrict_noun n menu Restrict Noun
sub restrict_noun {
    restrict_hide('N---------');
}

#bind restrict_adjective a menu Restrict Adjective
sub restrict_adjective {
    restrict_hide('A---------');
}

#bind restrict_verb v menu Restrict Verb
sub restrict_verb {
    restrict_hide('V---------');
}

#bind restrict_proper z menu Restrict Proper Name
sub restrict_proper {
    restrict_hide('Z---------');
}

#bind restrict_adverb D menu Restrict Adverb
sub restrict_adverb {
    restrict_hide('D---------');
}

#bind restrict_preposition p menu Restrict Preposition
sub restrict_preposition {
    restrict_hide('P---------');
}

#bind restrict_pronoun s menu Restrict Pronoun
sub restrict_pronoun {
    restrict_hide('S---------');
}

#bind restrict_particle f menu Restrict Particle
sub restrict_particle {
    restrict_hide('F---------');
}

#bind restrict_conjunction c menu Restrict Conjunction
sub restrict_conjunction {
    restrict_hide('C---------');
}

#bind restrict_third 3 menu Restrict Person Third ;)
#bind restrict_third Ctrl+3 menu Restrict Person Third
sub restrict_third {
    restrict_hide('-----3----');
}

#bind restrict_second Ctrl+2 menu Restrict Person Second
sub restrict_second {
    restrict_hide('-----2----');
}

#bind restrict_first Ctrl+1 menu Restrict Person First
sub restrict_first {
    restrict_hide('-----1----');
}

#bind restrict_perfect P menu Restrict Verb Perfect
sub restrict_perfect {
    restrict_hide('-P--------');
}

#bind restrict_indicative I menu Restrict Verb Indicative
sub restrict_indicative {
    restrict_hide('--I-------');
}

#bind restrict_subjunctive S menu Restrict Verb Subjunctive
sub restrict_subjunctive {
    restrict_hide('--S-------');
}

#bind restrict_jussive J menu Restrict Verb Jussive
sub restrict_jussive {
    restrict_hide('--J-------');
}

#bind restrict_active Ctrl+c menu Restrict Voice Active
sub restrict_active {
    restrict_hide('---A------');
}

#bind restrict_passive Ctrl+t menu Restrict Voice Passive
sub restrict_passive {
    restrict_hide('---P------');
}

#bind restrict_plural Ctrl+p menu Restrict Illusory Plural
sub restrict_plural {
    restrict_hide('-------P--');
}

#bind restrict_dual Ctrl+d menu Restrict Illusory Dual
sub restrict_dual {
    restrict_hide('-------D--');
}

#bind restrict_singular Ctrl+s menu Restrict Illusory Singular
sub restrict_singular {
    restrict_hide('-------S--');
}

#bind restrict_masculine Ctrl+m menu Restrict Illusory Masculine
sub restrict_masculine {
    restrict_hide('------M---');
}

#bind restrict_feminine Ctrl+f menu Restrict Illusory Feminine
sub restrict_feminine {
    restrict_hide('------F---');
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

    ($name, $path, undef) = File::Basename::fileparse($thisfile, '.morpho.fs');
    (undef, $path, undef) = File::Basename::fileparse((substr $path, 0, -1), '');

    $file[0] = path $path . 'morpho', $name . '.morpho.fs';
    $file[1] = path $path . "$level", $name . ".$level.fs";

    $file[2] = $level eq 'corpus' ? ( path $path . "$level", $name . '.morpho.fs')
                                  : ( path $path . 'morpho', $name . ".$level.fs");

    $file[3] = path $path . 'morpho', $name . '.morpho.fs.anno.fs';

    unless ($file[0] eq $thisfile) {

        ToplevelFrame()->messageBox (
            -icon => 'warning',
            -message => "This file's name does not fit the directory structure!$fill\n" .
                        "Relocate it to " . ( path '..', 'morpho', $name . '.morpho.fs' ) . ".$fill",
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

    open_level_second();
    
    Analytic::synchronize_file();
}

#bind open_level_first to Ctrl+Alt+1 menu Action: Edit MorphoTrees File
sub open_level_first {

    ChangingFile(0);
}

#bind open_level_second to Ctrl+Alt+2 menu Action: Edit Analytic File
sub open_level_second {

    ChangingFile(0);

    my ($level, $name, $path, @file) = inter_with_level 'syntax';

    return unless defined $level;

    unless (-f $file[1]) {

        my $reply = main::userQuery($grp,
                        "\nThere is no " . ( path '..', "$level", $name . ".$level.fs" ) . " file.$fill" .
                        "\nReally create a new one?$fill",
                        -bitmap=> 'question',
                        -title => "Creating",
                        -buttons => ['Yes', 'No']);

        return unless $reply eq 'Yes';

        if (-f $file[2]) {

            ToplevelFrame()->messageBox (
                -icon => 'warning',
                -message => "Cannot create " . ( path '..', "$level", $name . ".$level.fs" ) . "!$fill\n" .
                            "Please remove " . ( path '..', 'morpho', $name . ".$level.fs" ) . ".$fill",
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

        system 'perl -X ' . ( escape CallerDir('exec').'/SyntaxFS.pl' ) .
                      ' ' . ( expace $file[0] );

        mkdir path $path, "$level" unless -d path $path, "$level";

        move $file[2], $file[1];
    }

    switch_the_levels($file[1]);
}

#bind open_level_third to Ctrl+Alt+3 menu Action: Edit DeepLevels File
sub open_level_third {

    ChangingFile(0);

    my ($level, $name, $path, @file) = inter_with_level 'deeper';

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

    switch_the_levels($file[1]);
}

sub switch_the_levels {

    my $file = $_[0];

    my ($tree, $node, @child, $hits);

    switch_either_context() unless $root->{'type'} eq 'paragraph';

    $tree = substr $root->{'id'}, 1;
    $node = 0;

    unless ($this == $root) {

        $this = $this->parent() until $this->{'type'} eq 'word_node';

        @child = $root->children();

        foreach $hits (@child) {

            last if $hits == $this;
            $node++;
        }

        if ($node == @child) {

            $node = 0;
        }
        else {

            $node++;
        }
    }

    if (Open($file)) {

        GotoTree($tree);

        unless ($node == 0) {

            do {

                $this = $this->following();

                ($hits) = $this->{'x_id_ord'} =~ /^\#[0-9]+\/([0-9]+)(:?\_[0-9]+)?$/;
            }
            until $hits == $node;
        }
    }
    else {

        SwitchContext('MorphoTrees');
    }
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

MorphoTrees - Context for Annotation of Morphology in the TrEd Environment


=head1 REVISION

    $Revision$       $Date$


=head1 DESCRIPTION

MorphoTrees were first introduced in L<http://ufal.mff.cuni.cz/padt/docs/2004-nemlar-tred.pdf>.
They have re-appeared in various papers and talks, esp. in the video-recorded lecture on the Prague
Arabic Dependency Treebank, L<http://ufal.mff.cuni.cz/padt/online/2007/01/prague-treebanking-for-everyone-video.html>.

Examples of MorphoTrees include L<http://ufal.mff.cuni.cz/padt/docs/morpho_fhm.gif>,
L<http://ufal.mff.cuni.cz/padt/docs/morpho_AfrAd.gif>, or
L<http://ufal.mff.cuni.cz/padt/docs/morpho_AmA.gif>.

Paragraph annotation trees look like L<http://ufal.mff.cuni.cz/padt/docs/morpho_view.gif>.

For further reference, see the list of MorphoTrees macros and key-bindings in the User-defined menu item in TrEd.


=head1 SEE ALSO

TrEd Tree Editor L<http://ufal.mff.cuni.cz/~pajas/tred/>

Prague Arabic Dependency Treebank L<http://ufal.mff.cuni.cz/padt/online/>


=head1 AUTHOR

Otakar Smrz, L<http://ufal.mff.cuni.cz/~smrz/>

    eval { 'E<lt>' . ( join '.', qw 'otakar smrz' ) . "\x40" . ( join '.', qw 'mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright 2004-2007 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
