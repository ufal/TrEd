package TectoMT::Bundle;

use vars qw($root $this $grp $SelectedTree);

use 5.008;
use strict;
use warnings;
use Report;
use Class::Std;
use Fslib;
use TectoMT::Node;

use Scalar::Util qw( weaken );


{

    our $VERSION = '0.01';
    my %fsroot : ATTR;
    my %document : ATTR;

    our %fsroot2tmt_bundle;
    our %fsroot2tmt_document;

    my %loadable_node_class;
    my %unloadable_node_class;

    my %missing_class_already_warned;

    sub tie_with_fsroot {
        my ($self, $fsroot) = @_;
        Report::fatal "Incorrect number of arguments" if @_ != 2;
        Report::fatal "Argument must be a FSNode object" if not UNIVERSAL::isa($fsroot, "FSNode");

        #    $fsroot->{_tmt_bundle} = $self;
        $fsroot2tmt_bundle{$fsroot} = $self;
        $fsroot{ident $self} = $fsroot;

        #    foreach my $fstree (map {$fsroot->{trees}->{$_}} keys %{$fsroot->{trees}}) {
        foreach my $treename ( keys %{$fsroot->{trees}}) {

            my $fstree = $fsroot->{trees}->{$treename};

            foreach my $fsnode ($fstree, $fstree->descendants) {

                my $class = 'TectoMT::Node::'.$treename;
                my $new_node;

                if (not $loadable_node_class{$class} and not $unloadable_node_class{$class}) {
                    eval "use $class";
                    if ($@) {
                        $unloadable_node_class{$class} = 1;
                    } else {
                        $loadable_node_class{$class} = 1;
                    }
                }

                if ($loadable_node_class{$class}) {
                    eval '$new_node='.$class.'->new({"fsnode"=>$fsnode})';
                    if ($@) {
                        Report::fatal "Can't initiate node of class $class: $@";
                    }
                } else {
                    if (not defined $missing_class_already_warned{$class}) {
                        Report::warn "Could not load class $class or construct its instance! TectoMT::Node is used instead.\n";
                        $missing_class_already_warned{$class} = 1;
                    }
                    $new_node = TectoMT::Node->new({'fsnode'=>$fsnode});
                }


                $new_node->_set_bundle($self);
                my $id;
                if ($id = $new_node->get_attr('id')) {
                    $self->get_document->index_node_by_id($id,$new_node);
                }
            }
        }
        return;
    }

    sub untie_from_fsroot {
        my ($self) = @_;
        #    print STDERR "XXX Bundle untie\n";

        my $fsroot = $self->get_tied_fsroot;

        foreach my $treename ( keys %{$fsroot->{trees}}) {
            my $treeroot = $self->get_tree($treename);
            foreach my $node ($treeroot, $treeroot->get_descendants) {
                $node->untie_from_fsnode;
            }
        }

        delete $fsroot2tmt_bundle{$fsroot};
        delete $fsroot2tmt_document{$fsroot};
        delete $fsroot{ident $self};
        delete $document{ident $self};

    }


    sub get_tied_fsroot {
        my ($self) = @_;
        Report::fatal "get_tied_fsroot: incorrect number of arguments" if @_ != 1;
        return $fsroot{ident $self};
    }


    sub get_document($) {
        my ($self) = @_;
        my $document =  $document{ident $self};
        return $document;
    }

    sub _set_document($) {
        my ($self,$document) = @_;
        $document{ident $self} = $document;
        weaken $document{ident $self};
    }

    # The following two functions are needed to keep track about the underlying
    # ordering of the bundles in FS file and to be able to insert new bundles
    # at given positions.

    # They are currently mapped to get_attr() resp. set_attr() calls so it seems
    # that we could have the user call [sg]et_attr() directly. However, this is
    # only a workaround because I do not know how to access the Bundle object's
    # internal data. I expect the implementation to change in future.

    sub get_position($) {
        my ($self) = @_;
        my $position = $self->get_attr('_fs_position_');
        return $position;
    }

    sub _set_position($) {
        my ($self, $position) = @_;
        my $old_position = $self->get_attr('_fs_position_');
        $self->set_attr('_fs_position_', $position);
        return $old_position;
    }


    sub get_attr {
        my ($self, $attr_name) = @_;
        Report::fatal "get_attr: incorrect number of arguments" if @_ != 2;
        return $fsroot{ident $self}->{$attr_name}
    }


    sub set_attr {
        my ($self, $attr_name, $attr_value) = @_;
        Report::fatal "set_attr: incorrect number of arguments" if @_ != 3;
        return $fsroot{ident $self}->{$attr_name}=$attr_value
    }


    sub tree_exists {
        my ($self, $tree_name) = @_;
        Report::warning ("all usages of the method tree_exists should be substituted by contains_tree");
        Report::fatal "tree_exists: incorrect number of arguments" if @_ != 2;
        return defined($fsroot{ident $self}->{trees}->{$tree_name});
        # and defined($TectoMT::Node::fsnode2tmt_node{ $fsroot{ident $self}->{trees}->{$tree_name} });
    }

    sub contains_tree {
        my ($self, $tree_name) = @_;
        Report::fatal "tree_exists: incorrect number of arguments" if @_ != 2;
        return defined($fsroot{ident $self}->{trees}->{$tree_name});
        # and defined($TectoMT::Node::fsnode2tmt_node{ $fsroot{ident $self}->{trees}->{$tree_name} });
    }

    sub get_tree_names {
        my ($self) = @_;
        Report::fatal "get_trees: incorrect number of arguments" if @_ != 1;
        return sort(keys(%{$fsroot{ident $self}->{trees}}));
    }

    sub get_tree {
        my ($self, $tree_name) = @_;
        Report::fatal "get_tree: incorrect number of arguments" if @_ != 2;
        #    my $tree = $fsroot{ident $self}->{trees}->{$tree_name}->{_tmt_node};
        my $tree = $TectoMT::Node::fsnode2tmt_node{ $fsroot{ident $self}->{trees}->{$tree_name} };
        Report::fatal "No tree named $tree_name available in the bundle, bundle id=".$self->get_attr('id') unless $tree;
        return $tree;
    }

    sub set_tree {
        my ($self, $tree_name, $tree_root) = @_;
        Report::fatal "set_tree: incorrect number of arguments" if @_ != 3;
        Report::fatal "set_tree: argument must be a TectoMT::Node object" if not UNIVERSAL::isa($tree_root, "TectoMT::Node");
        foreach my $node ($tree_root, $tree_root->get_descendants) {
            $node->_set_bundle($self);
        }
        return $fsroot{ident $self}->{trees}->{$tree_name} = $tree_root->get_tied_fsnode;
    }

}

1;



__END__


=head1 NAME

TectoMT::Bundle


=head1 DESCRIPTION

A bundle in TectoMT corresponds to one sentence in its various forms/representations
(esp. its representations on various levels of language description, but also
possibly including its counterpart sentence from a parallel corpus, or its
automatically created translation, and their linguistic representations,
be they created by analysis / transfer / synthesis). Attributes can be
attached to a bundle as a whole.


=head1 METHODS

=head2 Constructor

=over 4

=item  my $new_bundle = TectoMT::Bundle->new();

Creates a new empty tree bundle.

=back


=head2 Access to the underlying Fslib representation

=over 4

=item $bundle->tie_with_fsroot($fsroot)

Associates the given bundle with a FSNode object which
is the root of a tree in the Fslib representation and
will be used as the underlying represenatation of the bundle.

=item my $fsroot = $bundle->get_tied_fsroot();

Returns the associated FSNode object used as the
bundle's underlying Fslib represenatation.

=item $bundle->untie_from_fsroot();

Unties the TectoMT::Bundle object from its underlying
FSNode representation.

=back


=head2 Access to attributes

=over 4

=item my $value = $bundle->get_attr($name);

Returns the value of the bundle attribute of the given name.

=item  $bundle->set_attr($name,$value);

Sets the given attribute of the bundle with the given value.

=back



=head2 Access to the subsumed trees

=over 4

=item my $root_node = $bundle->get_tree($tree_name);

Returns the TectoMT::Node object which is the root of
the tree named $tree_name. Fatal error is caused if
no tree of the given name is present in the bundle.


=item $bundle->set_tree($tree_name,$root_node);

Includes the tree rooted by $root_node into the bundle
under the $tree_name name.

=item $bungle->contains_tree($tree_name);

Returns true if a tree of the given name is present
in the budnle.

=item $bundle->get_tree_names();

Returns alphabetically sorted array of names of trees
contained in the bundle.


=back


=head2 Access to the containers

=over 4

=item $document = $bundle->get_document();

Returns the TectoMT::Document object in which the bundle is contained.

=back



=head1 COPYRIGHT

Copyright 2006 by Zdenek Zabokrtsky. This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
