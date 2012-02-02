#-*- cperl -*-
#encoding iso-8859-2

# returns the reference to an array ordered according to the ordering attribute
# containing the whole tree except the nodes depending on the given nodes
# the array contains all nodes or only visible nodes depending on the second parameter
sub GetNodesExceptST {
# $tops contains the reference to a list containing reference to the nodes whose subtrees are to be skipped
    my $tops = ref( $_[0]->[0] ) ? $_[0] : [$this];

    my @all;

    my $node = $root;

    if ( $_[1] ) {    # @all is filled the the visible nodes of the whole tree
        while ($node) {    # except for the nodes depending on the given node
            push @all, $node;
            if ( defined( Index( $tops, $node ) ) ) {
                $node = $node->following_right_or_up;
                if (IsHidden($node)) {
                    $node = $node->following_visible( $grp->{FSFile}->FS );
                }
            }
            else {
                $node = $node->following_visible( $grp->{FSFile}->FS );
            }
        }
    }
    else {
        while ($node) {    # @all is filled with the nodes of the whole tree
            push @all,
                $node;     # except for the nodes depending on the given node
            if ( defined( Index( $tops, $node ) ) ) {
                $node = $node->following_right_or_up;
            }
            else {
                $node = $node->following;
            }
        }
    }

    SortByOrd( \@all );
    return \@all;
}

# projectivizes the subtree of a given node (within the whole tree)
# if it succeeds, it returns 1, undef otherwise
sub ProjectivizeSubTree {
    my $top = ref( $_[0] ) ? $_[0] : $this; 
    # $top contains the reference to the node 
    # whose subtree is to be projectivized

    my $subtree = ContinueProjectivizing($top)
        ;    # the ordered array of the projectivized subtree, or undef
    return if !@{$subtree};

    my $all = GetNodesExceptST( [$top] );

    splice @{$all}, Index( $all, $top ), 1,
        @{$subtree};   # the projectivized subtree is spliced at the right place

    NormalizeOrds($all);    # the ordering attributes are modified accordingly

    return 1;
}

# interactively projectivizes current subtree
sub ProjectivizeCurrentSubTree {
    return ProjectivizeSubTree($this);
}

# interactively projectivizes the whole tree
sub ProjectivizeTree {
    return ProjectivizeSubTree($root);
}

# projectivizes (asks for no confirmation) subtree
sub ProjectivizeSubTreeWithoutAsking {
    # $top contains the reference to the node whose subtree is to be projectivized
    my $top = ref( $_[0] ) ? $_[0] : $this;
    my $subtree = Projectivize($top);
    my $all = GetNodesExceptST( [$top] );

    # the projectivized subtree is spliced at the right place
    splice @{$all}, Index( $all, $top ), 1, @{$subtree};

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# returns a reference to the ordered array of the nodes of the projectivized subtree of a given node
# the reference to the node whose subtree is to be projectivized
# whether only non-hidden nodes are to be put in the array
sub Projectivize {
    my ( $top, $onlyvisible ) = ( shift, shift );

    return if !ref $top;

    my @subtree;
    my @sons_left;
    my @sons_right;
    my $node;
    my $i   = 0;
    my $ord = $grp->{FSFile}->FS->order;

    if ( !$onlyvisible || !IsHidden($top) ) {
        push @subtree, [ $top, 1 ];
    }

    # an ordered array of the projectivized subtree is being created
    # it contains pairs consisting of a reference to a node
    # and an indicator saying whether its sons have already been processed

    while ( $i <= $#subtree ){
        # the subtree is being traversed and projectivized at the same time
        # the array @subtree grows only to the right of the current index
        if ( $subtree[$i]->[1] == 1 ) {
            # this node's sons have not been processed yet
            undef @sons_left;
            undef @sons_right;
            $node = $subtree[$i]->[0]->firstson;
            while ($node) {    # the sons are being traversed and
                 # divided into those on the left and those on the right from the given node
                next if ( $onlyvisible and IsHidden($node) );
                if ( $node->{$ord} < $subtree[$i]->[0]->{$ord} ) {
                    push @sons_left, [ $node, 1 ];
                }
                else {
                    push @sons_right, [ $node, 1 ];
                }
            }
            continue {
                $node = $node->rbrother;
            }
            $subtree[$i]->[1] = 0;    # the processed noded is marked as such
              # the left and right sons are spliced at appropriate places in the array
            splice @subtree, $i + 1, 0,
                ( sort { $a->[0]->{$ord} <=> $b->[0]->{$ord} } @sons_right );
            splice @subtree, $i, 0,
                ( sort { $a->[0]->{$ord} <=> $b->[0]->{$ord} } @sons_left );
        }
        else {
            $i++;
            # increase the current index by one if the sons of the current 
            # node have already been processed 
        }
    }

    # a reference to an ordered array containing only the references
    # to the nodes of the projectivized subtree is returned
    return [ map { $_->[0] } @subtree ];
}

# asks a question in Czech or English, returns 1 if the answer is positive, 0 otherwise
# if the locale language setting is Czech, it asks in Czech, otherwise English is used
sub AskCzEn ($$$$) {
    my ( $title_cz, $message_cz, $title_en, $message_en ) = @_;
    my ( $title, $message, $yes, $no );

    if (eval
        "use POSIX qw(locale_h); setlocale(LC_MESSAGES) =~ /^cs_CZ$|^czech/i"
        )
    {
        ( $yes, $no, $title, $message )
            = ( 'Ano', 'Ne', $title_cz, $message_cz );
    }
    else {
        ( $yes, $no, $title, $message )
            = ( 'Yes', 'No', $title_en, $message_en );
    }

    my $d = ToplevelFrame()->DialogBox(
        -title   => $title,
        -buttons => [ $yes, $no ]
    );
    $d->add(
        'Label',
        -text       => $message,
        -font       => StandardTredFont(),
        -wraplength => 200
    )->pack;
    $d->bind(
        '<Return>',
        sub {
            my $w = shift;
            my $f = $w->focusCurrent;
            if ( $f && $f->isa('Tk::Button') ) {
                $f->Invoke();
            }
        }
    );
    $d->bind( 'all', '<Tab>',   [ sub { shift->focusNext; } ] );
    $d->bind( 'all', '<Right>', [ sub { shift->focusNext; } ] );
    $d->bind( 'all', '<Left>',  [ sub { shift->focusPrev; } ] );
    if ( $d->Show() eq $yes ) {
        return 1;
    }
    else {
        return 0;
    }
}

# displays a message in Czech or in English
sub MessageCzEn ($$) {
    my ( $message_cz, $message_en ) = @_;

    my ( $title, $message );

    if (eval
        "use POSIX qw(locale_h); setlocale(LC_MESSAGES) =~ /^cs_CZ$|^czech/i"
        )
    {
        ( $title, $message ) = ( 'Zpráva', $message_cz );
    }
    else {
        ( $title, $message ) = ( 'Message', $message_en );
    }
    my $d = ToplevelFrame()->DialogBox(
        -title   => $title,
        -buttons => ['OK']
    );
    $d->add(
        'Label',
        -text       => $message,
        -font       => StandardTredFont(),
        -wraplength => 200
    )->pack;
    $d->bind(
        '<Return>',
        sub {
            my $w = shift;
            my $f = $w->focusCurrent;
            if ( $f and $f->isa('Tk::Button') ) {
                $f->Invoke();
            }
        }
    );
    $d->Show();
    return 1;
}

# ask appropriate question (about the whole tree or some subtree)
sub AskProjectivityQuestion {
    my $top = ref( $_[0] ) ? $_[0] : $root;

    if ( $top == $root ) {
        AskCzEn(
            'Varování', 'Strom není projektivní. Chcete pokraèovat?',
            'Warning',  'The tree is not projective. Continue anyway?'
        );
    }
    else {
        AskCzEn(
            'Varování', 'Podstrom není projektivní. Chcete pokraèovat?',
            'Warning',  'The subtree is not projective. Continue anyway?'
        );
    }
    return;
}

# checks whether the current visible subtree or the whole tree
# (if no parameter is passed) is projective
# returns 1 if the subtree is projective (according to the visibility status of hidden nodes)
# 0 otherwise
sub CheckProjectivity {
    my $top = ref( $_[0] ) ? $_[0] : $root;
    # $top contains the reference to the node 
    # whose subtree is to be checked for projectivity (or roo)

    # projectivized subtree
    my $ProjectivizedSubTree = Projectivize( $top, not( IsHidden($top) ) );
    my $SubTree
        = IsHidden($top) ? [ GetNodes($top) ] : [ GetVisibleNodes($top) ];
    SortByOrd($SubTree);

    # subtree ordered according to the ordering attribute
    my ( $proj, $sub ) = ( $#{$ProjectivizedSubTree}, $#{$SubTree} );
    my $differ = 0;    # suppose they do not differ

    # compares the actual subtree with the projectivized one
    if ( $proj != $sub ){
        return 0;    # they differ
    }
    else {
        foreach my $i (0..$proj) {
            if ( $$ProjectivizedSubTree[$i] != $$SubTree[$i] ) {
                return 0;    # they differ
            }
        }
        return 1;
    }
}

# checks whether the current visible subtree or the whole tree
# (if no parameter is passed) is projective
# if it is not, is asks whether it should be projectivized
# if the user answers yes, it returns the whole projectivized subtree (including the hidden nodes)
# undef otherwise
sub ContinueProjectivizing {
    my $top = ref( $_[0] ) ? $_[0] : $root;
    # $top contains the reference to the node 
    # whose subtree is to be checked for projectivity (or roo)

    if ( not( CheckProjectivity($top) ) ) {    # they are not the same !!!
        if ( AskProjectivityQuestion($top) ) {
            return Projectivize($top);
            # continue, return the whole projectivized subtree
        }
        else {
            return;
            # do not continue
        }
    }
    else {
        return Projectivize($top);
        # continue by default if the subtree has already been projective
        # return the whole projectivized subtree
    }
}

