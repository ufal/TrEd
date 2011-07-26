# -*- cperl -*-

#include "projectivize.inc"

############################### macros for moving nodes and subtrees #####################

# move the node specified by the first parameter right after 
# the node specified in the second parameter
sub Move {
    my $top = $_[0];
    return if !$top;

    my $after = ref( $_[1] ) ? $_[1] : $root;
    # if no node to place after is specified, 
    # it is taken to be the root node

    my $all = [ GetNodes($top) ];
    SortByOrd($all);

    splice @{$all}, Index( $all, $top ),
        1;    # the top node is cut off from the array
    splice @{$all}, Index( $all, $after ) + 1, 0,
        $top;    # the top node is spliced after the appropriate node

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

sub ShiftLeft {
    return if ( !$this->parent );
    if ( HiddenVisible() ) {
        ShiftNodeLeft($this);
    }
    else {
        ShiftNodeLeftSkipHidden( $this, 1 );
    }
    return;
}

sub ShiftRight {
    return if ( !$this->parent );
    if ( HiddenVisible() ) {
        ShiftNodeRight($this);
    }
    else {
        ShiftNodeRightSkipHidden($this);
    }
    return;
}

#************************** shifting subtrees ****************************************************
# move the subtree specified by the first parameter right 
# after the node specified in the second parameter
sub MoveST {
    my $top = $_[0];
    return if !$top;

    my $subtree = ContinueProjectivizing($top);
    return if (!$subtree);
    # if no node to place after is specified,
    # it is taken to be the root node
    my $after = ref( $_[1] ) ? $_[1] : $root;

    my $all = GetNodesExceptST( [$top] );

    # the top node is cut off from the array
    splice @{$all}, Index( $all, $top ), 1;

    # the subtree is spliced after the appropriate node
    splice @{$all}, Index( $all, $after ) + 1, 0, @{$subtree};

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node one node left,
# according to the visibility-of-hidden-nodes status
sub ShiftSTLeft {
    return if ( GetOrd($this) <= 0 );
    if ( HiddenVisible() ) {
        ShiftSubTreeLeft($this);
    }
    else {
        ShiftSubTreeLeftSkipHidden($this);
    }
    return;
}

# moves the (projectivized) subtree of a given node one node right,
# according to the visibility-of-hidden-nodes status
sub ShiftSTRight {
    return if ( GetOrd($this) <= 0 );
    if ( HiddenVisible() ) {
        ShiftSubTreeRight($this);
    }
    else {
        ShiftSubTreeRightSkipHidden($this);
    }
    return;
}

# moves the (projectivized) subtree of a given node one node left 
# (with respect to all nodes)
sub ShiftSubTreeLeft {
    my $top = ref( $_[0] ) ? $_[0] : $this;    # if no parameter is passed,
    # take $this to be the reference to the node to be processed

    my $subtree = ContinueProjectivizing($top);
    return if !$subtree;

    my $all = GetNodesExceptST( [$top] );

    my $i = Index( $all, $top );    # locate the given node in the array @all
    if ( $i > 1 )
    { # check if there is place where to move (the root is always number zero)
        splice @{$all}, $i, 1;    # cut out the given node
        splice @{$all}, $i - 1, 0, @{$subtree};
        # splice the projectivized subtree at the right (ie left ;-) place
    }
    else {
        splice @{$all}, $i, 1, @{$subtree};
        # if there is no room where to move, just splice the proj. subtree
        # instead of the given node - thus the subtree gets projectivized
    }

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node one node right 
# (with respect to all nodes)
# see ShiftSubTreeLeft
sub ShiftSubTreeRight {
    my $top = ref( $_[0] ) ? $_[0] : $this;

    my $subtree = ContinueProjectivizing($top);
    return if !$subtree;

    my $all = GetNodesExceptST( [$top] );

    my $i = Index( $all, $top );
    if ( $i < $#{$all} ) {
        splice @{$all}, $i, 1;
        splice @{$all}, $i + 1, 0, @{$subtree};
    }
    else {
        splice @{$all}, $i, 1, @{$subtree};
    }

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node one node left 
# (with respect to non-hidden nodes only)
sub ShiftSubTreeLeftSkipHidden {
    my $top = ref( $_[0] ) ? $_[0] : $this;    # if no parameter is passed,
           # take $this to be the reference to the node to be processed

    # the projectivized subtree
    my $subtree = ContinueProjectivizing($top);
    return if !$subtree;

    my $all = GetNodesExceptST( [$top] );
    # all nodes except the nodes depending on the given node

    my $allvis = GetNodesExceptST( [$top], 1 );
    # all visible (ie non-hidden) nodes except the nodes depending on the given node

    my $i = Index( $allvis, $top );
    # locate the given node within the array @allvis
    if ( $i > 1 ) {    # if there is room where to move
        splice @{$all}, Index( $all, $top ), 1;    # cut the given node
        splice @{$all}, Index( $all, ${$allvis}[ $i - 1 ] ), 0,
            @{$subtree};    # locate the first visible node to the left
                          # and splice the projectivized subtree accordingly
    }
    else { # nowhere to move, the subtree of the given node gets projectivized
        splice @{$all}, Index( $all, $top ), 1, @{$subtree};
    }

    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node one node right 
# (with respect to non-hidden nodes only)
# see ShiftSubTreeLeftSkipHidden
sub ShiftSubTreeRightSkipHidden {
    my $top = ref( $_[0] ) ? $_[0] : $this;

    my $subtree = ContinueProjectivizing($top);
    return if !$subtree;

    my $all = GetNodesExceptST( [$top] );

    my $allvis = GetNodesExceptST( [$top], 1 );

    my $i = Index( $allvis, $top );
    if ( $i < $#{$allvis} ) {
        splice @{$all}, Index( $all, $top ), 1;
        splice @{$all}, Index( $all, ${$allvis}[ $i + 1 ] ) + 1, 0, @{$subtree};
    }
    else {
        splice @{$all}, Index( $all, $top ), 1, @{$subtree};
    }

    NormalizeOrds($all);
    return;
}

#************************** switching subtrees ****************************************************
# return an array of all the brothers of the given node (including itself)
# according to the visibility status
sub brothernodes {
    my $node = ref( $_[0] ) ? $_[0] : $this;    # if no parameter is passed,
           # take $this to be the reference to the node to be processed
    my @brothers;
    while ( $node->lbrother ) { $node = $node->lbrother }; # get to the leftmost brother
    if ( $_[1] ) {    # @brothers is filled only with the visible brothers
        while ($node) {
            if (!IsHidden($node)) {
                push @brothers, $node;
            }
            $node = $node->rbrother;
        }
    }
    else {            # @brothers is filled with all brothers
        while ($node) {
            push @brothers, $node;
            $node = $node->rbrother;
        }
    }
    SortByOrd( \@brothers );
    return @brothers;
}

# switches the (projectivized) subtree of the current node 
# with the (projectivized) subtree to the left,
# according to the visibility-of-hidden-nodes status
sub ShiftSToverSTLeft {
    if (!ref $_[0]) {
        shift;
    }
    my $node = shift() || $this;

    return if ( !$node->parent );
    if ( HiddenVisible() ) {
        ShiftSubTreeOverSubTreeLeft($node);
    }
    else {
        ShiftSubTreeOverSubTreeLeftSkipHidden($node);
    }
    return;
}

# switches the (projectivized) subtree of the current node 
# with the (projectivized) subtree to the right,
# according to the visibility-of-hidden-nodes status
sub ShiftSToverSTRight {
    if (!ref $_[0]) {
        shift;
    }
    my $node = shift() || $this;

    return if ( !$node->parent );
    if ( HiddenVisible() ) {
        ShiftSubTreeOverSubTreeRight($node);
    }
    else {
        ShiftSubTreeOverSubTreeRightSkipHidden($node);
    }
    return;
}

# moves the (projectivized) subtree of a given node 
# one subtree left (with respect to all nodes)
sub ShiftSubTreeOverSubTreeLeft {
    my $top = ref( $_[0] ) ? $_[0] : $this;    # if no parameter is passed,
    # take $this to be the reference to the node to be processed

    my @brothers = brothernodes($top);

    my $switch = $brothers[ max( Index( \@brothers, $top ) - 1, 0 ) ];

    my $all = GetNodesExceptST( [ $top, $switch ] );
    my $i = Index( $all, $top );    # locate the given node in the array @all

    if ( $top == $switch ) {
        my $subtree = ContinueProjectivizing($top);
        return if (!$subtree);
        splice @{$all}, $i, 1, @{$subtree};
        # if there is no room where to move, just splice the proj. subtrees
        # instead of the given nodes - thus the subtrees get projectivized
    }

    else {
        my $subtree = ContinueProjectivizing($top);
        my $switchsubtree = ContinueProjectivizing($switch);
        return if (!$subtree) || (!$switchsubtree);

        # locate the switching node in the array @all
        my $si = Index( $all, $switch );

        # splice the projectivized switching subtree at the right place
        splice @{$all}, $i, 1, @{$switchsubtree};

        # splice the projectivized moving subtree at the right place
        splice @{$all}, $si, 1, @{$subtree};
    }

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node 
# one node right (with respect to all nodes)
# see ShiftSubTreeOverSubTreeLeft
sub ShiftSubTreeOverSubTreeRight {
    my $top = ref( $_[0] ) ? $_[0] : $this;

    my @brothers = brothernodes($top);

    my $switch
        = $brothers[ min( Index( \@brothers, $top ) + 1, $#brothers ) ];

    my $all = GetNodesExceptST( [ $top, $switch ] );
    my $i = Index( $all, $top );    # locate the given node in the array @all

    if ( $top == $switch ) {
        my $subtree = ContinueProjectivizing($top);
        return if(!$subtree);
        splice @{$all}, $i, 1, @{$subtree};
        # if there is no room where to move, just splice the proj. subtrees
        # instead of the given nodes - thus the subtrees get projectivized
    }

    else {
        my $subtree = ContinueProjectivizing($top);
        my $switchsubtree = ContinueProjectivizing($switch);
        return if (!$subtree || !$switchsubtree );

        # locate the switching node in the array @all
        my $si = Index( $all, $switch );
        
        # splice the projectivized moving subtree at the right place
        splice @{$all}, $si, 1, @{$subtree};
        
        # splice the projectivized switching subtree at the right place
        splice @{$all}, $i, 1, @$switchsubtree;
    }

    # the ordering attributes are modified accordingly
    NormalizeOrds($all);
    return;
}

# moves the (projectivized) subtree of a given node 
# one subtree left (with respect to non-hidden nodes only)
sub ShiftSubTreeOverSubTreeLeftSkipHidden {
    my $top = ref( $_[0] ) ? $_[0] : $this;    # if no parameter is passed,
    # take $this to be the reference to the node to be processed

    my @brothers = brothernodes( $top, 1 );

    my $switch = $brothers[ max( Index( \@brothers, $top ) - 1, 0 ) ];

    my $all = GetNodesExceptST( [ $top, $switch ] );
    # all nodes except the nodes depending on the given node

#  my $allvis=GetNodesExceptST([$top,$switch],1); 
    # all visible (ie non-hidden) nodes except the nodes depending on the given nodes
    my $i = Index( $all, $top );    # locate the given node in the array @all

    if ( $top == $switch ) {
        my $subtree = ContinueProjectivizing($top);
        return if !$subtree;
        splice @{$all}, $i, 1, @{$subtree};
        # if there is no room where to move, just splice the proj. subtree back
        #  - thus the subtree gets projectivized
    }

    else {
        my $subtree = ContinueProjectivizing($top);
        my $switchsubtree = ContinueProjectivizing($switch);
        return if (!$subtree || !$switchsubtree);

        # locate the switching node in the array @all
        my $si = Index( $all, $switch );

        # splice the projectivized switching subtree at the right place
        splice @{$all}, $i, 1, @{$switchsubtree};

        # splice the projectivized moving subtree at the right place
        splice @{$all}, $si, 1, @{$subtree};
    }

    NormalizeOrds($all);    # the ordering attributes are modified accordingly
    return;
}

# moves the (projectivized) subtree of a given node 
# one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeOverSubTreeLeftSkipHidden
sub ShiftSubTreeOverSubTreeRightSkipHidden {
    my $top = ref( $_[0] ) ? $_[0] : $this;
    my @brothers = brothernodes( $top, 1 );

    my $switch
        = $brothers[ min( Index( \@brothers, $top ) + 1, $#brothers ) ];

    my $all = GetNodesExceptST( [ $top, $switch ] );
    my $i = Index( $all, $top );    # locate the given node in the array @all

    if ( $top == $switch ) {
        my $subtree = ContinueProjectivizing($top);
        return if !$subtree;
        splice @{$all}, $i, 1, @{$subtree};
        # if there is no room where to move, just splice the proj. subtrees
        # instead of the given nodes - thus the subtrees get projectivized
    }
    else {
        my $subtree = ContinueProjectivizing($top);
        my $switchsubtree = ContinueProjectivizing($switch);
        return if (!$subtree || !$switchsubtree);

        # locate the switching node in the array @all
        my $si = Index( $all, $switch );

        # splice the projectivized moving subtree at the right place
        splice @{$all}, $si, 1, @{$subtree};

        # splice the projectivized switching subtree at the right place
        splice @{$all}, $i, 1, @{$switchsubtree};
    }

    NormalizeOrds($all);    # the ordering attributes are modified accordingly
    return;
}

