# ########################################################################## Otakar Smrz, 2004/03/05
#
# MorphoTrees Context for TrEd by Petr Pajas #######################################################

# $Id$

package MorphoTrees;

use 5.008;

our $VERSION = do { my @r = q$Revision$ =~ /\d+/g; sprintf "%d." . "%02d" x $#r, @r };

# ##################################################################################################
#
# ##################################################################################################

#binding-context MorphoTrees

import TredMacro;

our ($paragraph_hide_mode, $entity_hide_mode);

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

                            ) ] } grep { $_->{'type'} eq 'word_node' } @{$nodes} ];
    }
    else {

        my $para = $fsfile->tree($tree->{'ref'} - 1);

        my $last = (split /[^0-9]+/, $para->{'par'})[1];
        my $next = 1;

        $nodes = [ map { $fsfile->tree($_) } $tree->{'ref'} .. ( $tree->{'ref'} == $last ? $grp->{FSFile}->lastTreeNo : $last - 2 ) ];

        $words = [ [ $para->{'id'} . " " . $para->{'input'}, '#' . $tree->{'ref'}, '-foreground => purple' ],
                   map {
                            [ " " ],
                            [ $_->{'input'}, '#' . ( $tree->{'ref'} + $next++ ), $_ == $tree ? ( $_, '-underline => 1' ): () ],

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

    my $quick = shift;
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

#bind move_to_next_paragraph Shift+Next menu Move to Next Paragraph
sub move_to_next_paragraph {

    unless ($root->{'type'} eq 'paragraph') {

        GotoTree($root->{'ref'});
    }

    GotoTree((split /[^0-9]+/, $root->{'par'})[1]);

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

#bind tree_hide_mode Ctrl+h menu Toggle Tree Hide Mode
sub tree_hide_mode {

    if ($root->{'type'} eq 'paragraph') {

        $paragraph_hide_mode = $paragraph_hide_mode eq 'hidden' ? '' : 'hidden';
    }
    else {

        $entity_hide_mode = $entity_hide_mode eq 'hidden' ? '' : 'hidden';
    }

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

        $node = main::HNext($grp, $node) until not $node or $node->level() == $level;
        $done = main::HPrev($grp, $done) until not $done or $done->level() == $level;

        if ($node) {

            if ($node->{'apply_m'} > 0) {

                $this = $node;
                last;
            }

            $node = main::HNext($grp, $node);
        }

        if ($done) {

            if ($done->{'apply_m'} > 0) {

                $this = $done;
                last;
            }

            $done = main::HPrev($grp, $done);
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

    $main::treeViewOpts->{reverseNodeOrder} ?
        ctrl_currentLeftWholeLevel($grp) :
        ctrl_currentRightWholeLevel($grp);

    $Redraw = 'none';
    ChangingFile(0);
}

#bind follow_apply_m_left Ctrl+Left menu Follow Annotation Left
sub follow_apply_m_left {

    $main::treeViewOpts->{reverseNodeOrder} ?
        ctrl_currentRightWholeLevel($grp) :
        ctrl_currentLeftWholeLevel($grp);

    $Redraw = 'none';
    ChangingFile(0);
}

sub ctrl_currentRightWholeLevel {    # modified copy of main::currentRightWholeLevel

    my $node = $this;
    my $level = $node->level();

    do {

        $node = main::HNext($grp, $node);
    }
    until not $node or $level == $node->level() and $node->{'apply_m'} > 0;

    $this = $node if $node;

    ChangingFile(0);
}

sub ctrl_currentLeftWholeLevel {     # modified copy of main::currentLeftWholeLevel

    my $node = $this;
    my $level = $node->level();

    do {

        $node = main::HPrev($grp, $node);
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
            -message => "No 'comment' attribute in this file",
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

            $node->{$_} = $twig->{$_} for qw 'form id type';
            $node->{'ref'} = $twig->{'ord'};
            $node->{'apply_m'} = 1;
        }

        $node = get_the_node($node, $leaf->{'ord'});

        unless ($node->{'ref'} eq $leaf->{'ord'}) {

            $node->{$_} = $leaf->{$_} for qw 'form id type tag gloss apply_t';
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

    my @restrict = split //, length $_[0] == $dim ? $_[0] : '-' x $dim;
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

                $node->{'inherit'} = restrict($node->parent()->{'restrict'}, $node->parent()->{'inherit'});     # might have been Shift+Escaped
                $node->{'inherit'} = '' if $node->{'inherit'} eq '-' x $dim;
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
            $node->{'inherit'} = '' if $node->{'inherit'} eq '-' x $dim;
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

    restrict_hide('-' x $dim, 'remove inherited');
}


# ##################################################################################################
#
# ##################################################################################################

our $dim = 10;      # dimension of Arabic morphology ^^


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

#bind restrict_definiteness_i i menu Restrict to Indefinite
sub restrict_definiteness_i {
    restrict_hide('---------I');
}

#bind restrict_definiteness_d d menu Restrict to Definite
sub restrict_definiteness_d {
    restrict_hide('---------D');
}

#bind restrict_definiteness_r r menu Restrict to Reduced
sub restrict_definiteness_r {
    restrict_hide('---------R');
}

#bind restrict_definiteness_c C menu Restrict to Complex
sub restrict_definiteness_c {
    restrict_hide('---------C');
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

1;


=head1 NAME

MorphoTrees - Context for Morphological Annotations in TrEd by Petr Pajas

=head1 REVISION

    $Revision$       $Date$


=head1 DESCRIPTION

In the next release ;)

Anyway, see the list of MorphoTrees macros and key-bindings in the User-defined menu item in TrEd.


=head1 SEE ALSO

TrEd L<http://ckl.mff.cuni.cz/pajas/>


=head1 AUTHOR

Otakar Smrz, L<http://ckl.mff.cuni.cz/smrz/>

    eval { 'E<lt>' . 'smrz' . "\x40" . ( join '.', qw 'ckl mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
