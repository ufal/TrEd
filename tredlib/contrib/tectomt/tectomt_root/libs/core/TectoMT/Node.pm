#!/usr/bin/perl

package TectoMT::Node;

use vars qw($root $this $grp $SelectedTree);

use 5.008;
use strict;
use warnings;
use Class::Std;
use Report;

use Fslib;

use Scalar::Util qw( weaken );

use Cwd;


{

    our $VERSION = '0.01';
    my %fsnode : ATTR;
    my %bundle : ATTR;

    our %fsnode2tmt_node;

    sub ordering_attribute { 'ord' } # default name of the (horizontal) ordering attribute

    sub BUILD {
        my ($self, $ident, $arg_ref) = @_;
        if ($arg_ref->{fsnode}) {
            tie_with_fsnode($self,$arg_ref->{fsnode});
        } else {
            my $fsnode = FSNode->new();
            tie_with_fsnode($self,$fsnode);
        }
    }


    sub disconnect {
        my ($self) = @_;

        # 1. disconnection in the background fs representation:
        my $fsnode = $self->get_tied_fsnode;
        $fsnode->cut;

        # COMMENTED OUT to be consistent with set_parent, which does not add nodes to the indexing table
        # 2. removing the node from the document's node indexing table
        #    my $document = $self->get_document;
        #    my $id = $self->get_attr('id');
        #    if ($id) {
        #      $document->index_node_by_id($id,undef);
        #    }

        #    print STDERR "$self disconnected now!\n";

    }


    sub tie_with_fsnode {
        my ($self, $fsnode) = @_;
        Report::fatal("Incorrect number of arguments!") if @_ != 2;
        Report::fatal("Argument (fsnode to be tied) must be a FSNode object!") if not UNIVERSAL::isa($fsnode, "FSNode");

        #    $fsnode->{_tmt_node} = $self;
        $fsnode2tmt_node{$fsnode} = $self;
        $fsnode{ident $self} = $fsnode;

        #    if ($fsnode->{id}) {
        #      $self->get_document->index_node_by_id($fsnode->{id},$self);
        #    }

        return;
    }


    sub untie_from_fsnode {
        my ($self) = @_;

        #    print STDERR "XXX Node untie\n";

        delete $fsnode2tmt_node{$fsnode{ident $self}};
        delete $fsnode{ident $self};
        delete $bundle{ident $self};
    }


    sub get_tied_fsnode {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments!") if @_ != 1;
        return $fsnode{ident $self};
    }


    sub get_attr {
        my ($self, $attr_name) = @_;
        Report::fatal("Incorrect number of arguments!") if @_ != 2;
        return $fsnode{ident $self}->attr($attr_name);
    }


    sub set_attr($$) {
        my ($self, $attr_name, $attr_value) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 3;
        if ($attr_name eq "id") {
            if (not defined $attr_value or $attr_value eq "") {
                Report::fatal "Setting undefined or empty ID is not allowed";
            }
            $self->get_document->index_node_by_id($attr_value,$self);
        } elsif (ref($attr_value) eq "ARRAY") {
            $attr_value = Fslib::List->new(@$attr_value);
        }
        return $fsnode{ident $self}->set_attr($attr_name,$attr_value);
    }

    sub generate_new_id {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $id = $self->get_attr('id');
        if (not defined $id) {
            Report::fatal "Node without id cannot be used for generating new id.";
        }
        my $document = $self->get_document;
        my $counter;
        my $new_id;

        do {
            $counter++;
            $new_id = "${id}x$counter";
        }
            while ($document->id_is_indexed($new_id));

        return $new_id;
    }

    sub get_id {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return $self->get_attr('id');
    }


    # navigace po stromu

    sub get_document($) {
        my  ($self) = @_;
        my $bundle = $self->get_bundle;
        Report::fatal("Can't call get_document on a node which is in no bundle") if not defined $bundle;
        return $self->get_bundle->get_document;
    }

    sub get_bundle($) {
        my  ($self) = @_;
        my $bundle = $bundle{ident $self};
        #    print "get bundle uzlu $self je $bundle\n";
        return $bundle;
    }

    sub _set_bundle($) {
        #    print " Node::_set_bundle ";
        my  ($self,$bundle) = @_;
        #   print "w";
        if (not $bundle) {
            Report::fatal("_set_bundle: Emtpy bundle $bundle");
        }
        $bundle{ident $self} = $bundle;
        weaken $bundle{ident $self};
    }


    sub get_parent($) {
        my ($self) = @_;
        my $fsparent = $fsnode{ident $self}->parent();
        if ($fsparent) {
            #      return $fsparent->{_tmt_node}
            return $fsnode2tmt_node{$fsparent};
        } else {
            return
        }
    }

    sub get_root($) {
        my ($self) = @_;
        my $fsroot = $fsnode{ident $self}->root();
        if ($fsroot) {
            return $fsnode2tmt_node{$fsroot};
        } else {
            return
        }
    }

    sub is_root($) {
        my ($self) = @_;
        return (not $self->get_parent);
    }

    sub set_parent($$) {
        my ($self,$parent) = @_;
        Report::fatal("Node's parent must be a TectoMT::Node (it is $parent)") if not UNIVERSAL::isa($parent,"TectoMT::Node");
        #    croak "paste_below: cannot paste tree root" if not $self->get_is_root;
        $self->_set_bundle($parent->get_bundle);
        my $fsself = $self->get_tied_fsnode;
        my $fsparent = $parent->get_tied_fsnode;
        if ($fsself->parent) {
            Fslib::Cut($fsself)
          }
        #    $fsself->{'_tree_name'} = $fsparent->{'_tree_name'};
        my $fsfile = $self->get_document()->get_tied_fsfile();
        my @fschildren = $fsparent->children;
        if (@fschildren) {
            Fslib::PasteAfter($fsself,$fschildren[-1]);
        } else {
            Fslib::Paste($fsself,$fsparent,$fsfile->FS());
        }
    }


    sub get_children {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        #    return (map {$_->{_tmt_node}} $fsnode{ident $self}->children);
        return (map {$fsnode2tmt_node{$_}} $fsnode{ident $self}->children);
    }

    sub get_descendants{
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        #    return (map {$_->{_tmt_node}} $fsnode{ident $self}->descendants);
        return (map {$fsnode2tmt_node{$_}} $fsnode{ident $self}->descendants);
    }

    sub get_self_and_descendants {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
  	return ($self, $self->get_descendants);
    }

    sub get_depth {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $depth = 0;
        $depth++ while $self = $self->get_parent;
        return $depth;
    }

    sub get_siblings {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $parent = $self->get_parent;
        if ($parent) {
            return (grep {$_ ne $self} $parent->get_children);
        } else {
            return ();
        }
    }


    sub get_fposition($) {
        my ($self) = @_;
        my $id = $self->get_attr('id');

        my $fsfile = $self->get_document->get_tied_fsfile;
        my $fs_root = $self->get_bundle->get_tied_fsroot;

        my $bundle_number = 1;
      trees: foreach my $t ($fsfile->trees) {
            if ($t == $fs_root) {
                last trees;
            }
            $bundle_number++;
        }

        my $filename = Cwd::abs_path($self->get_document->get_fsfile_name);
        return "$filename##$bundle_number.$id";
    }


    # ----------- things related with node ordering

    sub get_ordering_value {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return $self->get_attr($self->ordering_attribute);
    }

    sub set_ordering_value {
        my ($self, $val) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        $self->set_attr($self->ordering_attribute, $val);
    }

    sub get_ordered_children {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return (sort {$a->get_ordering_value<=>$b->get_ordering_value} $self->get_children);
    }
  
    sub get_first_child {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my ($son) = $self->get_ordered_children;
        return $son;
    }

    sub get_ordered_descendants {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return (sort {$a->get_ordering_value<=>$b->get_ordering_value} $self->get_descendants);
    }

    sub normalize_node_ordering {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        Report::fatal("Ordering normalization can be applied only on root nodes!") if $self->get_parent;
        my $new_ord = 0;
        foreach my $node ($self, $self->get_ordered_descendants) {
            $node->set_attr($self->ordering_attribute, $new_ord);
            $new_ord++
        }
    }

    sub get_left_children {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $my_ordering_value = $self->get_ordering_value;
        return (grep {$_->get_ordering_value < $my_ordering_value} $self->get_ordered_children);
    }

    sub get_right_children {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $my_ordering_value = $self->get_ordering_value;
        return (grep {$_->get_ordering_value > $my_ordering_value} $self->get_ordered_children);
    }

    sub get_leftmost_child {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my @children = $self->get_ordered_children;
        return $children[0];
    }

    sub get_rightmost_child {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my @children = $self->get_ordered_children;
        return $children[-1];
    }

    sub get_ordered_siblings {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return (sort {$a->get_ordering_value<=>$b->get_ordering_value} $self->get_siblings);
    }

    sub get_left_siblings {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $my_ordering_value = $self->get_ordering_value;
        return (grep {$_->get_ordering_value < $my_ordering_value} $self->get_ordered_siblings)
    }

    sub get_right_siblings {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $my_ordering_value = $self->get_ordering_value;
        return (grep {$_->get_ordering_value > $my_ordering_value} $self->get_ordered_siblings)
    }

    sub get_left_neighbor {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my @left_siblings = $self->get_left_siblings;
        return $left_siblings[-1];
    }

    sub get_right_neighbor {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my @right_siblings = $self->get_right_siblings;
        return $right_siblings[-0];
    }
  
    # ----------- things related to node reordering
  
    # shifting among one parent's children, node and its subtree is moved
    # projective tree assumed
    sub shift_left {
        my ($self) = @_;
        my $parent = $self->get_parent;
        Report::fatal("Cannot shift node without a parent") unless $parent;
        my $my_ord = $self->get_ordering_value;
        my $left_neighbor = $self->get_left_neighbor();
        my @my_treelet = $self->get_treelet_nodes();
        my @left_treelet;
    
        # parent can stand in the way
        if ( (!defined $left_neighbor || $left_neighbor->get_ordering_value() < $parent->get_ordering_value())
                 && $parent->get_ordering_value() < $my_ord) {
            @left_treelet = ($parent);  
        } else {
            Report::fatal("Cannot shift left without a left neighbor") unless $left_neighbor;
            @left_treelet = ($left_neighbor, $left_neighbor->get_descendants);
            @left_treelet = sort {$a->get_ordering_value<=>$b->get_ordering_value} @left_treelet;
        }
    
        my $my_mass   = scalar @my_treelet;
        my $left_mass = scalar @left_treelet;
    
        # ords in my treelet
        foreach (@my_treelet) {
            $_->set_ordering_value($_->get_ordering_value() - $left_mass);
        }
        
        # ords after me
        foreach (@left_treelet) {
            $_->set_ordering_value($_->get_ordering_value() + $my_mass);
        }
    }
    
    # shifting among one parent's children, node and its subtree is moved
    # projective tree assumed
    sub shift_right {
        my ($self) = @_;
        my $parent = $self->get_parent;
        Report::fatal("Cannot shift node without a parent") unless $parent;
        my $my_ord = $self->get_ordering_value;
        my $right_neighbor = $self->get_right_neighbor();
        my @my_treelet = $self->get_treelet_nodes();
        my @right_treelet;
    
        # parent can stand in the way
        if ( (!defined $right_neighbor || $parent->get_ordering_value() < $right_neighbor->get_ordering_value())
                 && $my_ord < $parent->get_ordering_value() ) {
            @right_treelet = ($parent);
        } else {
            Report::fatal("Cannot shift left without a left neighbor") unless $right_neighbor;
            @right_treelet = ($right_neighbor, $right_neighbor->get_descendants);
            @right_treelet = sort {$a->get_ordering_value<=>$b->get_ordering_value} @right_treelet;    
        }
        
        my $my_mass   = scalar @my_treelet;
        my $right_mass = scalar @right_treelet;
    
        # ords in my treelet
        foreach (@my_treelet) {
            $_->set_ordering_value($_->get_ordering_value() + $right_mass);
        }
    
        # ords before me
        foreach (@right_treelet) {
            $_->set_ordering_value($_->get_ordering_value() - $my_mass);
        }
    }
    
    sub AUTOMETHOD { # umozni misto $node->get_attr('functor') psat jen $node->geta_functor; #  opsano z Conway str. 396
        my ($self,$obj_id,@other_args) = @_;
        my $subroutine_name = $_; # predavani nazvu volane procedury - specialita AUTOMETHOD

        my ($mode,$name) = $subroutine_name =~ m/\A ([gs]eta)_(.*) \z/xms
            or return;

        $name =~ s/__/\//g;

        if ($mode eq "geta") {
            return sub { return $self->get_attr($name,@other_args); }
        } else {                # mode eq seta
            return sub { return $self->set_attr($name,@other_args); }
        }
    }



}

1;

__END__


=head1 NAME

TectoMT::Node




=head1 DESCRIPTION


TectoMT trees (contained in bundles) are formed by nodes and edges.
Attributes can be attached only to nodes. Edge's attributes must
be equivalently stored as the lower node's attributes.
Tree's attributes must be stored as attributes of the root node.


=head1 METHODS

=head2 Constructor

=over 4

=item  my $new_node = TectoMT::Node->new();

Creates a new node as well as its underlying FSNode representation.

=item my $new_node = TectoMT::Node->new( { 'fsnode' => $fsnode } );

Creates a new node and associates it with an already existing FSNode object.



=back



=head2 Access to the underlying Fslib representation

=over 4

=item $node->tie_with_fsnode($fsnode);

Associates the given node with a FSNode object which
will be used as its underlying represenatation.

=item my $fsnode = $node->get_tied_fsnode();

Returns the associated FSNode object used as the
node's underlying represenatation.


=back




=head2 Access to attributes

=over 4

=item my $value = $node->get_attr($name);

Returns the value of the node attribute of the given name.

=item  $node->set_attr($name,$value);

Sets the given attribute of the node with the given value.
If the attribute name is 'id', then the document's indexing table
is updated. If value of the type List is to be filled,
then $value must be a reference to the array of values.

=item my $value = $node->geta_ATTRNAME();

Generic set of faster-to-write attribute-getter methods, such as $node->geta_functor()
equivalent to $node->get_attr('functor'), or $node->geta_gram__number() equivalent to
$node->get_attr('gram/number'). In the case of structured attributes, '/' in the attribute name
is to be substituted with '__' (double underscore).

=item  $node->seta_ATTRNAME($name,$value);

Generic set of faster-to-write attribute-setter methods, such as $node->seta_functor('ACT')
equivalent to $node->set_attr('functor','ACT'), or $node->seta_gram__number('pl') equivalent to
$node->get_attr('gram/number','pl'). In the case of structured attributes, '/' in the attribute name
is to be substituted with '__' (double underscore).



=back




=head2 Access to tree topology

=over 4

=item my @child_nodes = $node->get_children();

Returns the array of child nodes.

=item my @descendant_nodes = $node->get_descendants();

Returns the array of descendant nodes ('transitive children').

=item my $parent_node = $node->get_parent();

Returns the parent node, or undef if there is none (if $node itself is the root)

=item $node->set_parent($parent_node);

Makes $node the child of $parent_node.

=item my $root_node = $node->get_root();

Returns the root of the node's tree.

=item my $root_node = $node->is_root();

Returns true if the node has no parent.

=item my @sibling_nodes = $node->get_siblings();

Returns an array of nodes sharing the parent with the current node.


=back



=head2 Access to tree topology regarding the ordering of nodes

=over 4

=item my $attrname = $node->get_ordering_attribute();

Returns the name of the ordering attribute ('ord' by default).

=item my $ord = $node->get_ordering_value();

Returns the ordering value of the given node, i.e., the value of
its 'ord' attribute. This method is supposed to be redefined in derived classes
(to return e.g. 'deepord'). All methods following in this section make use
of this method.

=item $rootnode->normalize_node_ordering();

The values of the ordering attribute of all nodes in the tree (possibly containing
negative or fractional numbers) are normalized. The node ordering is preserved,
but only integer values are used now (starting from 0 for the root, with increment 1).
This method can be called only on tree roots (nodes without parent),
otherwise fatal error is invoked.

=item my @child_nodes = $node->get_ordered_children();

Returns array of descendants sorted using the get_ordering_value method.

=item my @left_child_nodes = $node->get_left_children();

Returns array of sorted descendants with the ordering value
smaller than that of the given node.

=item my @right_child_nodes = $node->get_right_children();

Returns array of sorted descendants with the ordering value
bigger than that of the given node.

=item my $leftmost_child_node = $node->get_leftmost_child();

Returns the child node with the smallest ordering value.

=item my $rightmost_child_node = $node->get_rightmost_child();

Returns the child node with the biggest ordering value.

=item my @sibling_nodes = $node->get_ordered_siblings();

Returns an array of sibling nodes (nodes sharing their parent with
the current node), ordered according to get_ordering_value.

=item my @left_sibling_nodes = $node->get_left_siblings();

Returns an array (ordered according to get_ordering_value) of sibling nodes with
ordering values smaller than that of the current node.

=item my @right_sibling_nodes = $node->get_right_siblings();

Returns an array (ordered according to get_ordering_value) of sibling nodes with
ordering values bigger than that of the current node.

=item my $left_neighbor_node = $node->get_left_neighbor();

Returns the rightmost node from the set of left siblings (the nearest left sibling).

=item my $right_neighbor_node = $node->get_right_neighbor();

Returns the leftmost node from the set of right siblings (the nearest right sibling).

=item $node->shift_left();

Node and its subtree is moved among its siblings. Projective tree is assumed.

=item $node->shift_right();

Node and its subtree is moved among its siblings. Projective tree is assumed.

=back




=head2 Access to the containers

=over 4

=item $bundle = $node->get_bundle();

Returns the TectoMT::Bundle object in which the node's tree is contained.

=item $document = $node->get_document();

Returns the TectoMT::Document object in which the node's tree is contained.

=back

=head2 Other

=over 4

=item $node->generate_new_id();

Generate new (=so far unindexed) identifier (to be used when creating new nodes).
The new identifier is derived from the identifier of the root ($node->root), by adding
suffix x1 (or x2, if ...x1 has already been indexed, etc.) to the root's id.

=item my $position = $node->get_fposition();

Return the node address, i.e. file name and node's position within the file, similarly
to TrEd's FPosition() (but the value is only returned, not printed).

=back


=head1 COPYRIGHT

Copyright 2006 by Zdenek Zabokrtsky. This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
