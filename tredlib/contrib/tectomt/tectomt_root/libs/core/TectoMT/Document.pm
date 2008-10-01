package TectoMT::Document;

use 5.008;
use strict;
use warnings;
use Report;
use Class::Std;
#use Fslib;
use Fslib qw(ImportBackends);
use TectoMT::Bundle;
use TectoMT::Node;
use Report;

use Scalar::Util qw( weaken );

$Fslib::resourcePath = $ENV{"TRED_DIR"}
    .":".$ENV{"TRED_DIR"}."/resources/"
    .":".$ENV{"TMT_ROOT"}."/pml_schemas/";
Fslib::ImportBackends("PMLBackend");

{
    our $VERSION = '0.01';

    my %id2node : ATTR;
    my %fsfile : ATTR;

    # substitution of the former solution with $fsfile->{_tmt_document}, $fsnode->{_tmt_bundle}, $fsnode->{_tmt_node}
    our %fsfile2tmt_document; # mapping from FSFile instances to TectoMT::Document instances

    sub BUILD {
        my ($self, $ident, $arg_ref) = @_;

        if ($arg_ref->{fsfile}) {
            tie_with_fsfile($self,$arg_ref->{fsfile});
        } elsif ($arg_ref->{filename}) {
            my @IObackends = Fslib::ImportBackends(qw(PMLBackend StorableBackend)); # ??? loadovat jen pri prvnim pouziti!!!
            my $fsfile = FSFile->newFSFile($arg_ref->{filename},\@IObackends);
            tie_with_fsfile($self,$fsfile);
        } else {
            # create a new tmt $fsfile object, if non was specified
            my $fsfile = FSFile->create
                (
                    name => "x", #$filename,  ???
                    FS => FSFormat->new({
                        'deepord' => ' N' # ???
                    }),
                    trees => [],
                    backend => 'PMLBackend',
                    encoding => "utf-8",
                );
            my $schema_file = Fslib::ResolvePath($fsfile->filename, 'tmt_schema.xml',1);
            $fsfile->changeMetaData('schema-url','tmt_schema.xml');
            $fsfile->changeMetaData('schema',Fslib::Schema->new({filename=>$schema_file}));
            $fsfile->changeMetaData('pml_root',    {  meta => { }, bundles => undef, });

            tie_with_fsfile($self,$fsfile);
        }
    }

    sub get_fsfile_name() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $fsfile = $fsfile{ident $self};
        return $fsfile->filename();
    }


    sub tie_with_fsfile() {
        my ($self, $fsfile) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        Report::fatal("Argument must be a FSFile object") if not UNIVERSAL::isa($fsfile,"FSFile");
        $fsfile{ident $self} = $fsfile;

        $fsfile2tmt_document{$fsfile} = $self;
        #    $fsfile->metaData('pml_root')->{_tmt_document} = $self;

        foreach my $fsroot ($fsfile->trees) {
            my $new_bundle = TectoMT::Bundle->new();
            $new_bundle->_set_document($self);
            $new_bundle->tie_with_fsroot($fsroot);

            $TectoMT::Bundle::fsroot2tmt_bundle{$fsroot} = $new_bundle;
            #      $fsroot->{_tmt_bundle} = $new_bundle;

            $TectoMT::Bundle::fsroot2tmt_document{$fsroot} = $self;
            #      $fsroot->{_tmt_document} = $self;
        }
        return $self;
    }


    sub untie_from_fsfile {
        my ($self) = @_;

        #    print STDERR "XXX Document untie\n";

        my $fsfile = $self->get_tied_fsfile;

        foreach my $bundle ($self->get_bundles) {
            $bundle->untie_from_fsroot();
        }
        delete $fsfile{ident $self};
        delete $id2node{ident $self};
        delete $fsfile2tmt_document{$fsfile};

    }


    # deleting all TectoMT representations
    sub Clean_all {

        print STDERR "XXX Clean all \n";

        # cleaning hashes in TectoMT::Document
        %id2node = ();
        %fsfile = ();
        %fsfile2tmt_document = ();

        # cleaning all hashes in TectoMT::Bundle
        %TectoMT::Bundle::fsroot = ();
        %TectoMT::Bundle::document = ();
        %TectoMT::Bundle::fsroot2tmt_bundle = ();
        %TectoMT::Bundle::fsroot2tmt_document = ();
        %TectoMT::Bundle::loadable_node_class = ();
        %TectoMT::Bundle::unloadable_node_class = ();
        %TectoMT::Bundle::missing_class_already_warned = ();

        # !!! zbyva udelat cisteni hashu v TectoMT::Node, ale i jeho potomku - jak to udelat???
    }


    sub get_tied_fsfile() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $fsfile = $fsfile{ident $self};
        Report::fatal("get_tied_fsfile: there is no FSFile instance tied with $self") if not defined $fsfile;
        return $fsfile;
    }



    sub save() {
        Report::fatal("2:Not implemented");
    }


    sub save_as() {
        my ($self,$filename) = @_;
        my $fsfile = $self->get_tied_fsfile();

        if ($filename eq "") {
            Report::fatal("Name of the file must be specified!")
          }

        $fsfile->writeFile($filename);
    }
  
    # serialize document into a filehandle 
    # ie $document->print_to(\*STDOUT);
    sub serialize_to {
        my ($self,$fh) = @_;
        my $fsfile = $self->get_tied_fsfile();

        $fsfile->writeTo($fh);
    }

    sub set_attr($$$) {
        my ($self, $attr_name, $attr_value) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 3;
        return FSNode::set_attr($self->get_tied_fsfile->metaData('pml_root')->{meta},$attr_name,$attr_value);
        #    return $self->get_tied_fsfile->metaData('pml_root')->{meta}{$attr_name}=$attr_value;
    }


    sub get_attr() {
        my ($self, $attr_name) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        return FSNode::attr($self->get_tied_fsfile->metaData('pml_root')->{meta},$attr_name);
        #    return $self->get_tied_fsfile->metaData('pml_root')->{meta}{$attr_name};
    }


    sub new_bundle() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;

        # new tree root on the fs-side
        #    print "Step A\n";
        #    my $new_fsroot = FSNode->new();
        my $fsfile = $self->get_tied_fsfile();
        #    print "fsfile: $fsfile\n";
        #    $fsfile->new_tree($new_fsroot);
        # Minimal position is 0, maximal position is number of bundles minus 1.
        # Next free position is equal to the current number of bundles.
        my $position = scalar($self->get_bundles());
        my $new_fsroot = $fsfile->new_tree($position);

        # new bundle on the tmt-side
        #    print "Step B\n";
        my $new_bundle = TectoMT::Bundle->new();
        $new_bundle->tie_with_fsroot($new_fsroot);
        $new_bundle->_set_document($self);
        $new_bundle->_set_position($position);

        return $new_bundle;
    }


    sub new_bundle_before() {
        my ($self, $existing_bundle) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        my $fsfile = $self->get_tied_fsfile();
        # Minimal position is 0, maximal position is number of bundles minus 1.
        my $position = $existing_bundle->get_position();
        # Shift positions of the $existing_bundle and all bundles after.
        foreach my $bundle ($self->get_bundles())
        {
            my $old_position = $bundle->get_position();
            if($old_position>=$position)
            {
                $bundle->_set_position($old_position+1);
            }
        }
        my $new_fsroot = $fsfile->new_tree($position);
        my $new_bundle = TectoMT::Bundle->new();
        $new_bundle->tie_with_fsroot($new_fsroot);
        $new_bundle->_set_document($self);
        $new_bundle->_set_position($position);
        return $new_bundle;
    }


    sub new_bundle_after() {
        my ($self, $existing_bundle) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        my $fsfile = $self->get_tied_fsfile();
        # Minimal position is 0, maximal position is number of bundles minus 1.
        my $position = $existing_bundle->get_position()+1;
        # Shift positions of all bundles after the new one.
        foreach my $bundle ($self->get_bundles())
        {
            my $old_position = $bundle->get_position();
            if($old_position>=$position)
            {
                $bundle->_set_position($old_position+1);
            }
        }
        my $new_fsroot = $fsfile->new_tree($position);
        my $new_bundle = TectoMT::Bundle->new();
        $new_bundle->tie_with_fsroot($new_fsroot);
        $new_bundle->_set_document($self);
        $new_bundle->_set_position($position);
        return $new_bundle;
    }


    sub get_bundles() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return map {$TectoMT::Bundle::fsroot2tmt_bundle{$_}} $self->get_tied_fsfile->trees;
        #    return map {$_->{_tmt_bundle}} $self->get_tied_fsfile->trees;
    }


    sub delete_bundle() {
        Report::fatal("5:Not implemented");
    }

    sub delete_all_bundles() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        my $fsfile = $self->get_tied_fsfile;
        while ($fsfile->trees) {
            $fsfile->delete_tree(0);
            # dodelat umazavani z indexniho hashe !!!!!!!!!!!
        }
    }


    sub index_node_by_id() {
        my ($self,$id,$node) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 3;
        if (defined $node) {
            $id2node{ident $self}{$id} = $node;
            weaken $id2node{ident $self}{$id};
        } else {
            delete $id2node{ident $self}{$id};
        }
    }

    sub id_is_indexed {
        my ($self,$id) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        return (defined $id2node{ident $self}{$id});
    }


    sub get_node_by_id() {
        my ($self,$id) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 2;
        if (defined $id2node{ident $self}{$id}) {
            return $id2node{ident $self}{$id};
        } else {
            Report::fatal "ID not indexed: id=\"$id\"";
        }
    }

    sub get_all_node_ids() {
        my ($self) = @_;
        Report::fatal("Incorrect number of arguments") if @_ != 1;
        return (keys %{$id2node{ident $self}});
    }


}

1;

__END__


=head1 NAME

TectoMT::Document



=head1 DESCRIPTION


A document consists of a sequence of bundles, mirroring a sequence
of natural language sentences (typically, but not necessarily,
originating from the same text). Attributes (attribute-value pairs)
 can to attached to a document as a whole.

=head1 METHODS

=head2 Constructor

=over 4

=item  my $new_document = TectoMT::Document->new();

Creates a new emtpy document object.

=item  my $new_document = TectoMT::Document->new( { 'fsfile' => $fsfile } );

Creates a TectoMT document corresponding to the specified Fsfile object.

=item  my $new_document = TectoMT::Document->new( { 'filename' => $filename } );

Loads the tmt file and creates a TectoMT document corresponding to its content.

=back


=head2 Access to the underlying Fslib representation

=over 4

=item $document->tie_with_fsfile($fsfile);

Associates the given document with a FSFile object which
will be used as its underlying represenatation. Which means
that for each FSFile sentence a new TectoMT::Bundle object is created
and for each tree in the FSFile sentence representation
a new tree of TectoMT::Node objects is built. Both representations
are interlinked in both directions.

=item $document->untie_from_fsfile();

Deletes the mutual references between the tied fsfile and
its TectoMT mirror.

=item $document->get_fsfile_name();

Returns the name of the file with the underlying
Fslib representation.


=item my $fsfile = $document->get_tied_fsfile();

Returns the associated FSFile object used as the
documents's underlying represenatation. Fatal error
is no such object is associated.

=back


=head2 Accessing directly the PML files

=over 4

=item open, save, save_as
Not implemented yet.

=item my $filename = $fsfile->get_fsfile_name();

=back

=head2 Access to attributes

=over 4

=item my $value = $document->get_attr($name);

Returns the value of the document attribute of the given name.

=item  $document->set_attr($name,$value);

Sets the given attribute of the document with the given value.
If the attribute name is 'id', then the document's indexing table
is updated.

=back


=head2 Access to the contained bundles

=over 4

=item my @bundles = $document->get_bundles();

Returns the array of bundles contained in the document.


=item my $new_bundle = $document->new_bundle();

Creates a new empty bundle and appends it
at the end of the document.

=item my $new_bundle = $document->new_bundle_before($existing_bundle);

Creates a new empty bundle and inserts it
in front of the existing bundle.

=item my $new_bundle = $document->new_bundle_after($existing_bundle);

Creates a new empty bundle and inserts it
after the existing bundle.

=back


=head2 Node indexing

=over 4

=item  $document->index_node_by_id($id,$node);

The node is added to the id2node hash table (as mentioned above, it
is done automatically in $node->set_attr() if the attribute name
is 'id'). When using undef in the place of the second argument, the entry
for the given id is deleted from the hash.


=item my $node = $document->get_node_by_id($id);

Return the node which has the value $id in its 'id' attribute,
no matter to which tree and to which bundle in the given document
the node belongs to.

=item $document->id_is_indexed($id);

Return true if the given id is already present in the indexing table.

=item $document->get_all_node_ids();

Return the array of all node identifiers indexed in the document.

=back



=head1 COPYRIGHT

Copyright 2006 by Zdenek Zabokrtsky. This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
