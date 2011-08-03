# -*- cperl -*-

#ifndef NonProjectivity

package NonProjectivity;

use strict;

BEGIN { import TredMacro; }

=pod

=head1 non_projectivity.mak

An efficient algorighm for finding non-projectivity edges in ordered
trees.

=head2 USAGE

  #include <contrib/support/non_projectivity.mak>

  non_proj_edges($root);

=head2 MACROS

The following macros (functions) are provided by this package:

=over 5

=item non_proj_edges($node,$only_visible?,$ord?,$filterNode?,$returnParents?,$subord?,$filterGap?)

Returns hash-ref containing all non-projective edges in the subtree
rooted in $node. Values of the hash are references to arrays
containing the non-projective edges (the arrays contain the lower and
upper nodes representing the edge, and then the nodes causing the
non-projectivity of the edge), keys are concatenations of stringified
references to lower and upper nodes of non-projective
edges. Description of the arguments is as follows: $node specifies the
root of a subtree to be checked for non-projective edges;
$only_visible set to true confines the subtree to visible nodes; $ord
specifies the ordering attribute to be used; a subroutine accepting
one argument passed as sub-ref in $filterNode can be used to filter
the edges taken into account (by specifying the lower nodes of the
edges); sub-ref $returnParents accepting one argument returns an array
of upper nodes of the edges to be taken into account; sub-ref $subord
accepting two arguments returns 1 iff the first one is subordinated to
the second one; sub-ref $filterGap accepting one argument can be used
to filter nodes causing non-projectivity.  Defaults are: all nodes,
the default ordering attribute, all nodes, parent (in the technical
representation), subordination in the technical sense, all nodes.

=cut

sub non_proj_edges {

# arguments are: root of the subtree to be projectivized
# switch whether projectivize only visible or all nodes
# the ordering attribute
# sub-ref to a filter accepting a node parameter (which nodes of the subtree should be skipped)
# sub-ref to a function accepting a node parameter returning a list of possible upper nodes
# on the edge from the node
# sub-ref to a function accepting two node parameters returning 1 iff the first one is
# subordinated to the second
# sub-ref to a filter accepting a node parameter for nodes in a potential gap

# returns a reference to a hash in which all non-projective edges are returned
# (keys being the lower nodes concatenated with the upper nodes of non-projective edges,
# values references to arrays containing the node, the parent, and nodes in the respective gaps)

    my ( $top, $onlyvisible, $ord, $filterNode, $returnParents, $subord,
        $filterGap )
        = @_;

    return if !ref $top;

    if ( !defined $ord ) {
        $ord = $TredMacro::grp->{FSFile}->FS->order();
    }
    if ( !defined $filterNode ) {
        $filterNode = sub {1};
    }
    if ( !defined $returnParents ) {
        $returnParents
            = sub { return $_[0]->parent ? ( $_[0]->parent ) : () };
    }
    if ( !defined $subord ) {
        $subord = sub {
            my ( $n, $top ) = @_;
            while ( $n->parent and $n != $top ) { $n = $n->parent }
            return ( $n == $top ) ? 1 : 0;    # returns 1 if true, 0 otherwise
        };
    }
    if ( !defined $filterGap ) {
        $filterGap = sub {1};
    }

    my %npedges;

    # get the nodes of the subtree
    my @subtree = sort { $a->{$ord} <=> $b->{$ord} } (
        $onlyvisible ? $top->visible_descendants( FS() ) : $top->descendants,
        $top
    );

    # just store the index in the subtree in a special attribute of each node
    foreach my $i ( 0 .. $#subtree ) { $subtree[$i]->{'_proj_index'} = $i }

# now check all the edges of the subtree (but only those accepted by filterNode
    foreach my $node ( grep { $filterNode->($_) } @subtree ) {

        next if ( $node == $top );    # skip the top of the subtree

        foreach my $parent ( $returnParents->($node) ) {

            # span of the current edge
            my ( $l, $r )
                = ( $node->{'_proj_index'}, $parent->{'_proj_index'} );

            # set the boundaries of the interval covered by the current edge
            if ( $l > $r ) { ( $l, $r ) = ( $r, $l ) }

            # check all nodes covered by the edge
            for ( my $j = $l + 1; $j < $r; $j++ ) {

                my $gap = $subtree[$j];    # potential node in gap
                  # mark a non-projective edge and save the node causing the non-projectivity (ie in the gap)
                if ( !( $subord->( $gap, $parent ) ) && $filterGap->($gap) ) {
                    my $key = scalar $node . scalar $parent;
                    if ( exists $npedges{$key} ) {
                        push @{ $npedges{$key} }, $gap;
                    }
                    else { $npedges{$key} = [ $node, $parent, $gap ] }
                }    # unless

            }    # for $j

        }    # foreach $parent

    }    # foreach $node

    my $node = $TredMacro::root;  # delete auxiliary indeces in the whole tree
    while ($node) {
        delete $node->{'_proj_index'};
        $node = $node->following();
    }

    return \%npedges;

}    # sub non_proj_edges

=back

=head2 AUTHOR

Jiri Havelka

=cut

#endif NonProjectivity

1;
