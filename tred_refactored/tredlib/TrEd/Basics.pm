package TrEd::Basics;
#TODO:  - enhancement: absolutize -- really necessary? just a wrapper
#       - better name, what basics? tree operations, tree manager?
#       - uniq, absolutize, absolutize_path -- put them in other module, no real connection to other functions
use strict;
use warnings;

BEGIN {
    use Treex::PML;
    require TrEd::MinMax;
    import TrEd::MinMax qw(first min max);
    use UNIVERSAL::DOES;

    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK
        $on_tree_change
        $on_node_change
        $on_current_change
    );
    use base qw(Exporter);
    $VERSION = "0.2";
    @EXPORT  = qw(
        $EMPTY_STR
    );
    @EXPORT_OK = qw{
        $on_tree_change
        $on_node_change
        $on_current_change
        
        go_to_tree
        next_tree
        prev_tree
        new_tree
        new_tree_after
        prune_tree
        move_tree
        make_root
        new_node
        prune_node
        set_current
        absolutize
        absolutize_path
        uniq
        file_schema
        get_secondary_files
        get_secondary_files_recursively
        get_primary_files
        get_primary_files_recursively
    };
    use Treex::PML::Schema;
}

use Readonly;

Readonly our $EMPTY_STR => q{};

use Carp;

# different namespace only to load local rather than system files
# (rel2abs is not supported in all instalations)
use File::Spec;
if ( not File::Spec->can('rel2abs') ) {
    croak
        "The currently installed version of the File::Spec module doesn't provide rel2abs() method. Please upgrade it!\n";
}
else {
    require File::Spec::Functions;
    import File::Spec::Functions qw(rel2abs);
}

#TODO: this is a wrapper for pmltq extension 
sub error_message {
    require TrEd::Error::Message;
    TrEd::Error::Message::error_message(@_);
}

#######################################################################################
# Usage         : uniq(@array)
# Purpose       : Remove duplicit elements from array
# Returns       : Array without repeating elements
# Parameters    : array @arr  -- array to be uniqued
# Throws        : no exception
# Comments      : Preserves type and order of elements, as suggested by Perl best practices
sub uniq {
    # seen -- track keys already seen elements
    my %seen;
    # return only those not yet seen
    return grep { !( $seen{$_}++ ) } @_;
}

#######################################################################################
# Usage         : go_to_tree($win_ref, $tree_no)
# Purpose       : Change the position in $win_ref to specified tree in current file
# Returns       : The ordinal number of the 'destination' tree (counted from 0),
#                 undef/empty list if $win_ref->{FSFile} is not defined
# Parameters    : TrEd::Window ref $win_ref -- see comment below
#                 scalar $tree_no   -- the ordinal number of the desired tree (counted from 0)
# Comments      : modifies $win_ref, calls on_tree_chage() callback
# See Also      : on_tree_change(), Treex::PML::Document::lastTreeNo(), Treex::PML::Document::treeList()
#
# The $win_ref parameter to the following two routines should be
# a hash reference, having at least the following keys:
#
# FSFile       => reference of the current Treex::PML::Document
# treeNo       => number of the current tree in the file
# macroContext => current context under which macros are run
# currentNode  => pointer to the current node
# root         => pointer to the root node of current tree
sub go_to_tree {
    my ( $win_ref, $tree_no ) = @_;
    my $fsfile = $win_ref->{FSFile};
    return if ( !defined $fsfile );
    my $no = max( 0, min( $tree_no, $fsfile->lastTreeNo() ) );
    return $no if ( $no == $win_ref->{treeNo} );
    $win_ref->{treeNo} = $no;
    $win_ref->{root} = $fsfile->treeList()->[ $win_ref->{treeNo} ];

    # on_tree_change in tred needs only one parameter, why 3?
    if ( defined $on_tree_change ) {
        &$on_tree_change( $win_ref, 'go_to_tree', $no );
    }
    return $no;
}

#######################################################################################
# Usage         : next_tree($win_ref)
# Purpose       : Activate the next tree from the current file
# Returns       : Zero if we are on the last tree, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
# Throws        : no exception
# See Also      : go_to_tree()
sub next_tree {
    my ($win_ref) = @_;
    return 0 if ( $win_ref->{treeNo} >= $win_ref->{FSFile}->lastTreeNo() );
    go_to_tree( $win_ref, $win_ref->{treeNo} + 1 );
    return 1;
}

#######################################################################################
# Usage         : prev_tree($win_ref)
# Purpose       : Activate the previous tree from the current file
# Returns       : Zero if we are on the first tree, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
# Throws        : no exception
# See Also      : go_to_tree()
sub prev_tree {
    my ($win_ref) = @_;
    return 0 if ( $win_ref->{treeNo} <= 0 );
    go_to_tree( $win_ref, $win_ref->{treeNo} - 1 );
    return 1;
}

#######################################################################################
# Usage         : new_tree($win_ref)
# Purpose       : Create new tree at the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} is not defined, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The tree on the current position and all the trees with position
#                 greater than the current position move to position + 1
#                 If $win_ref->{treeNo} is negative, new tree is created at the position counted from
#                 the end of file, if the position is after the end of file, new tree is created after
#                 the last tree
# See Also      : Treex::PML::Document::new_tree(), go_to_tree(), on_tree_change(), Treex::PML::Document::notSaved()
sub new_tree {
    my ($win_ref) = @_;
    my $fsfile = $win_ref->{FSFile};
    return if ( !defined $fsfile );
    if ( $fsfile->lastTreeNo() < 0 ) {
        $win_ref->{treeNo} = 0;
    }
    $win_ref->{root} = $fsfile->new_tree( $win_ref->{treeNo} );
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_tree_change( $win_ref, 'new_tree', $win_ref->{root} );
    }
    return 1;
}

#######################################################################################
# Usage         : new_tree_after($win_ref)
# Purpose       : Create new tree at the position after the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} is not defined, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The tree after the current position and all the trees with position
#                 greater than the one after the current position move to position + 1
#                 Unlike new_tree and prune_tree, this function does not support negative indices
# See Also      : Treex::PML::Document::new_tree(), go_to_tree(), on_tree_change(), Treex::PML::Document::notSaved()
sub new_tree_after {
    my ($win_ref) = @_;
    my $fsfile = $win_ref->{FSFile};
    return if ( !defined $fsfile );
    my $no = $win_ref->{treeNo}
        = max( 0, min( $win_ref->{treeNo}, $fsfile->lastTreeNo() ) + 1 );
    $win_ref->{root} = $fsfile->new_tree($no);
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_tree_change( $win_ref, 'new_tree_after', $win_ref->{root} );
    }
    return 1;
}

#######################################################################################
# Usage         : prune_tree($win_ref)
# Purpose       : Delete tree at the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} or the current tree is not defined, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The trees with position greater than the current position are moved to position - 1
#                 This implementation allows deleting from the end of file using negative indices, 
#                 e.g. $win_ref->treeNo = -1
# See Also      : go_to_tree(), on_tree_change(), Treex::PML::Document::notSaved(), Treex::PML::Document::destroy_tree()
#TODO:            shouldn't it be coherent and we should not allow negative indices?
#                 and if we give it negative index, returned root always points to tree no 1
sub prune_tree {
    my ($win_ref) = @_;
    my $fsfile = $win_ref->{FSFile};

    # why could use $fsfile->tree($win_ref->{treeNo}) instead?
    return
        if ( !( $fsfile and $fsfile->treeList()->[ $win_ref->{treeNo} ] ) );
    $win_ref->{root} = undef;
    my $no = $win_ref->{treeNo};
    $fsfile->destroy_tree( $win_ref->{treeNo} );
    $win_ref->{treeNo}
        = max( 0, min( $win_ref->{treeNo}, $fsfile->lastTreeNo() ) );
    $win_ref->{root} = $fsfile->treeList()->[ $win_ref->{treeNo} ];
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_tree_change( $win_ref, 'prune_tree', $win_ref->{treeNo} );
    }
    return 1;
}

#######################################################################################
# Usage         : move_tree($win_ref, $delta)
# Purpose       : Move current tree to new position: current position + $delta
# Returns       : Undef if $win_ref->{FSFile} is undefined or if delta is 0, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
#                 scalar $delta             -- the number of positions to move the tree
# Throws        : Croaks if the current tree is out of bounds (because it uses move_tree_to() sub)
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 All the trees with position greater than current position + $delta
#                 move to their current position + 1
# See Also      : Treex::PML::Document::move_tree_to(), on_tree_change(), Treex::PML::Document::notSaved()
sub move_tree {
    my ( $win_ref, $delta ) = @_;
    my $fsfile = $win_ref->{FSFile};
    return if ( !$fsfile );
    my $no = $win_ref->{treeNo};
    $fsfile->move_tree_to( $no, $no + $delta ) || return;
    $win_ref->{treeNo} = $no + $delta;
    $win_ref->{root} = $fsfile->treeList()->[ $win_ref->{treeNo} ];
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_tree_change( $win_ref, 'move_tree', $win_ref->{treeNo} );
    }
    return 1;
}

#######################################################################################
# Usage         : make_root($win_ref, $node, $discard)
# Purpose       : Make the specified $node new root of the current tree,
#                 optionally throwing out the former root if $discard is true
# Returns       : Undef if $win_ref->{FSFile} or $node is not defined, or
#                 if the current's tree root is different from $node's root, 1 otherwise
# Parameters    : TrEd::Window ref $win_ref   -- ref to TrEd::Window object
#                 Treex::PML::Node ref $node  -- reference to Treex::PML::Node object
#                 scalar $discard             -- switch telling if the root of the tree is discarded
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
#                 Node types are not changed, i.e. attr('nodetype') of the new root will be preserved
# See Also      : Treex::PML::Node::cut(), Treex::PML::Node::paste_on(), on_node_change(), Treex::PML::Document::notSaved()
sub make_root {
    my ( $win_ref, $node, $discard ) = @_;
    my $fsfile = $win_ref->{FSFile};
    return if ( !( $fsfile and $node ) );
    my $no   = $win_ref->{treeNo};
    my $root = $fsfile->treeList()->[$no];

    # If the current's tree root is different from $node's root, return undef
    if ( $root != $node->root() ) {
        return;
    }

    # Disconnect the node from its parent and siblings
    $node->cut();

    # Make the node new root node
    $fsfile->treeList()->[$no] = $node;

    # If old root is not to be discarded, put it under the new root
    if ( !$discard ) {
        $root->paste_on( $node, $fsfile->FS()->order() );
    }
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_node_change( $win_ref, 'make_root', $node );
    }
    return 1;
}

#######################################################################################
# Usage         : new_node($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined,
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : TrEd::Window ref $win_ref  -- ref to TrEd::Window object
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
sub new_node {
    ## Adds new son to current node
    my ($win_ref) = @_;
    my $parent = $win_ref->{currentNode};
    my $fsfile = $win_ref->{FSFile};
    return if !( defined $fsfile and defined $parent );

    # Treex::PML::Node warns users against using Treex::PML::Node->new(), hm?
    my $new_node = $parent->new(); 
    $new_node->paste_on( $parent, $fsfile->FS() );
    my $order = $fsfile->FS()->order();
    if (defined $order && $order) {

# set_member and get_member are inherited from Treex::PML::Struct
# and they have Treex::PML::Node equivalents setAttribute and getAttribute
# Implementation of setAttribute is problematic and neither setAttribute, nor set_member
# can not be used without calling set_member with fully-qualified name
        Treex::PML::Struct::set_member( $new_node, $order,
            $parent->getAttribute($order) );
    }
    set_current( $win_ref, $new_node );
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_node_change( $win_ref, 'new_node', $new_node );
    }

    return $new_node;
}

#######################################################################################
# Usage         : prune_node($win_ref, $node)
# Purpose       : Delete specified node from current file
# Returns       : Undef if $win_ref->{FSFile} or $node or $node's parent are not defined,
#                 return value of Treex::PML::Node::destroy_leaf() is returned otherwise
#                 (which currently means that 1 is returned)
# Parameters    : TrEd::Window ref $win_ref  -- ref to TrEd::Window object
#               : Treex::PML::Node ref $node -- reference to the node to delete
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::destroy_leaf(), set_current()
sub prune_node {
    ## Deletes given node
    my ( $win_ref, $node ) = @_;
    my $fsfile = $win_ref->{FSFile};
    return undef if !( $fsfile and $node and $node->parent() );

    # make all the sons of the current node its parent's sons
    my $son;
    while ( $son = $node->firstson() ) {
        $son->cut()->paste_on( $node->parent(), $fsfile->FS );
    }

   # if the deleted node is current node, make its parent the new current node
    if ( $node == $win_ref->{currentNode} ) {
        set_current( $win_ref, $node->parent() );
    }

    #TODO:
    # Hm, destroy_leaf returns 1 (a scalar value), therefore the $son == 1,
    # maybe Treex::PML::Node->destroy_leaf() should return destroyed leaf?
    $son = $node->destroy_leaf();
    $fsfile->notSaved(1);
    if ( defined $on_tree_change ) {
        &$on_node_change( $win_ref, 'prune_node', $son );
    }
    return $son;
}

#######################################################################################
# Usage         : set_current($win_ref, $node)
# Purpose       : Set $node as the current node (in $win_ref)
# Returns       : Nothing
# Parameters    : TrEd::Window ref $win_ref   -- ref to TrEd::Window object
#                 Treex::PML::Node ref $node  -- reference to Treex::PML::Node object that becomes the current node
# Throws        : no exception
# Comments      : calls on_current_chage() callback
sub set_current {
    my ( $win_ref, $node ) = @_;
    my $prev = $win_ref->{currentNode};
    $win_ref->{currentNode} = $node;
    if ( defined $on_tree_change ) {
        &$on_current_change( $win_ref, $node, $prev, 'set_current' );
    }
    return;
}


#######################################################################################
# Usage         : absolutize_path($ref_filename, $filename, [$search_resource_path])
# Purpose       : Return absolute path unchanged, resolve relative path
# Returns       : Resolved path, return value from Treex::PML::ResolvePath
# Parameters    : scalar $ref_path              -- a reference filename
#                 scalar $filename              -- a relative path to a file
#                 scalar $search_resource_paths -- 0 or 1
# Throws        : no exception
# Comments      : just calls Treex::PML::ResolvePath(@_)
# See Also      : Treex::PML::ResolvePath()
sub absolutize_path {
    return &Treex::PML::ResolvePath;
}

#######################################################################################
# Usage         : absolutize(@array)
# Purpose       : Make all paths in the @array absolute
# Returns       : Array of absolute paths
# Parameters    : list @array -- list of paths to be changed into absolute paths
# Throws        : no exception
# See Also      : File::Spec->rel2abs()
sub absolutize {

    # filter out elements containing only whitespaces
    # if the path starts with X:/, | or /, it is absolute, just return it;
    # otherwise change relative to absolute path
    return
        map { m(^[[:alnum:]]+:/|^\s*\||^\s*/) ? $_ : File::Spec->rel2abs($_) }
        grep { !/^\s*$/ } @_;
}

#######################################################################################
# Usage         : file_schema($fsfile)
# Purpose       : Return schema from file's metadata
# Returns       : Schema for $fsfile
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose schema we are searching for
# Throws        : no exception
# Comments      : Should return the same value as calling $fsfile->schema() (according to Treex::PML doc)
# See Also      : Treex::PML::Document::metaData(), Treex::PML::Document::schema()
sub file_schema {
    my ($fsfile) = @_;
    return $fsfile->metaData('schema');
}

#######################################################################################
# Usage         : get_secondary_files($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list)
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_secondary_files_recursively()
sub get_secondary_files {
    my ($fsfile) = @_;

    # is probably the same as Treex::PML::Document->relatedDocuments()
    # a reference to a list of pairs (id, URL)
    my $requires = $fsfile->metaData('fs-require');
    my @secondary;
    if ($requires) {
        foreach my $req (@$requires) {
            my $id = $req->[0];
            my $req_fs
                = ref( $fsfile->appData('ref') )
                ? $fsfile->appData('ref')->{$id}
                : undef;
            if ( UNIVERSAL::DOES::does( $req_fs, 'Treex::PML::Document' ) ) {
                push( @secondary, $req_fs );
            }
        }
    }
    return uniq(@secondary);
}

#######################################################################################
# Usage         : get_secondary_files_recursively($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema,
#                 and also all secondary files of these secondary files, etc recursively
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list)
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_secondary_files()
sub get_secondary_files_recursively {
    my ($fsfile) = @_;
    my @secondary = get_secondary_files($fsfile);
    my %seen;
    my $i = 0;
    while ( $i < @secondary ) {
        my $sec = $secondary[$i];
        if ( !exists( $seen{$sec} ) ) {
            $seen{$sec} = 1;
            push( @secondary, get_secondary_files($sec) );
        }
        $i++;
    }
    return uniq(@secondary);
}

#######################################################################################
# Usage         : get_primary_files($fsfile)
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_primary_files_recursively()
sub get_primary_files {
    my ($fsfile) = @_;

    # probably the same as Treex::PML::Document->relatedSuperDocuments()
    return @{ $fsfile->appData('fs-part-of') || [] };
}

#######################################################################################
# Usage         : get_primary_files_recursively($fsfile)
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents,
#                 and then list of all their superior documents, etc recursively
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for
# Throws        : no exception
# See Also      : get_primary_files()
sub get_primary_files_recursively {
    my ($fsfile) = @_;
    my @primary = get_primary_files($fsfile);
    my %seen;
    my $i = 0;
    while ( $i < @primary ) {
        my $prim = $primary[$i];
        if ( !exists( $seen{$prim} ) ) {
            $seen{$prim} = 1;
            push( @primary, get_primary_files($prim) );
        }
        $i++;
    }
    return uniq(@primary);
}

1;

__END__

=head1 NAME


TrEd::Basics - Basic functions for manipulating trees in L<Treex::PML::Document|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>


=head1 VERSION

This documentation refers to 
TrEd::Basics version 0.2.


=head1 SYNOPSIS

  use TrEd::Basics;
  
  # backends to use by Treex::PML
  my @backends=(
    'FS',
    ImportBackends(
      qw{NTRED
         Storable
         PML
         CSTS
         TrXML
         TEIXML
         PMLTransform
        })
    );
  
  # create Treex::PML::Document
  my $file_name = "my_file";
  my $fsfile = Treex::PML::Factory->createDocumentFromFile(
    $file_name,
    {
      encoding => 'utf8',
      backends => \@backends,
      recover => 1,
    });
  
  my $win_ref = { 
    treeNo => 0,
    FSFile => $fsfile,
    macroContext =>  'TredMacro',
    currentNode => $fsfile->tree(0),
    root => $fsfile->tree(0),
  }
  
  # Changing position in file
  my $new_position = TrEd::Basics::go_to_tree($win_ref, 42);
  
  my $success = TrEd::Basics::next_tree($win_ref);
  $success = TrEd::Basics::prev_tree($win_ref);
  
  # Tree manipulation -- creating, deleting and moving trees
  $success = TrEd::Basics::new_tree($win_ref);
  $success = TrEd::Basics::new_tree_after($win_ref);
  
  $success = TrEd::Basics::prune_tree($win_ref);
  
  my $delta = "3";
  $success = TrEd::Basics::move_tree($win_ref, $delta);
  
  # Node manipulation -- creating, deleting, creating new root from existing node
  my $root = $fsfile->tree(0);
  my $node = $root->firstson();
  my $discard_old_root = 1;
  
  $win_ref->{treeNo} = 0;
  $win_ref->{root} = $fsfile->tree(0);
  
  $success = TrEd::Basics::make_root($win_ref, $node, $discard_old_root);
  my $new_node = TrEd::Basics::new_node($win_ref);
  $success = TrEd::Basics::prune_node($win_ref, $new_node);
  
  # FSFile metainfo retrieval
  
  my $schema_ref = TrEd::Basics::file_schema($fsfile);
  
  my @secondary_files         = TrEd::Basics::get_secondary_files($fsfile);
  my @secondary_files_recurs  = TrEd::Basics::get_secondary_files_recursively($fsfile);
  
  # Find ref to related Treex::PML::Documents loaded by Treex::PML::Document->loadRelatedDocuments()
  my $id = $secondary_files[0]->[0];
  my $fsfile_2 = $fsfile->referenceObjectHash()->{$id};
  
  my @primary_files         = TrEd::Basics::get_primary_files($fsfile_2);
  my @primary_files_recurs  = TrEd::Basics::get_primary_files_recursively($fsfile_2);
  
  
  # Utility functions 
  TrEd::Basics::set_current($win_ref, $node);
  
  my @array = qw{1 1 2 3 4 4 5 8 8 9};
  my @uniqed_array = uniq(@array);      # without duplicities
  
  my $filename = "passwd";
  my $ref_path = "/etc";
  my $search_res_path = 1;
  my $absolute_path = TrEd::Basics::absolutize_path($ref_path, $filename, $search_res_path);
  
  my @input_paths = (
    "     ",
    "/home/something/unusual",
    "x:/Documents and Settings/John",
    "t/test_macros/include/../simple-macro.mac",
  );
  my @absolute_paths = TrEd::Basics::absolutize(@input_paths);
  
  

=head1 DESCRIPTION

Most of these functions are wrappers around some of the L<Treex::PML::Document|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm> and 
L<Treex::PML::Node|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Node.pm> functions that set up win_ref/grp_ref according to needs of tred
and call callbacks. 


=head1 SUBROUTINES/METHODS

=over 4 

=item * C<TrEd::Basics::uniq (@array)>

=over 6

=item Purpose

Remove duplicit elements from array

=item Parameters

C<@array> -- array to be uniqued

=item Description

Preserves type and order of elements.

=item Returns

Array without repeating elements

=back


=item * C<TrEd::Basics::go_to_tree ($win_ref, $tree_no)>

=over 6

=item Purpose

Change the position in $win_ref to specified tree in current file

=item Parameters

C<$win_ref> -- hash reference, see description below
C<$tree_no> -- the ordinal number of the desired tree (counted from 0)

=item Description

The $win_ref parameter to the following two routines should be
a hash reference, having at least the following keys:

  FSFile       => reference to the current L<Treex::PML::Document|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>
  treeNo       => number of the current tree in the file
  macroContext => current context under which macros are run
  currentNode  => pointer to the current node
  root         => pointer to the root node of current tree

Function modifies $win_ref and calls on_tree_chage() callback.

=item See also

L<Treex::PML::Document::lastTreeNo|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>, 
L<Treex::PML::Document::treeList|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

The ordinal number of the 'destination' tree (counted from 0), 
undef if $win_ref->{FSFile} is not defined (empty list in list context)

=back


=item * C<TrEd::Basics::next_tree($win_ref)>

=over 6

=item Purpose

Activate the next tree from the current file (if there is any such tree).

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item See also

L<go_to_tree>

=item Returns

Zero if we are on the last tree, 1 otherwise

=back


=item * C<TrEd::Basics::prev_tree($win_ref)>

=over 6

=item Purpose

Activate the previous tree from the current file (if there is any such tree)

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item See also

L<go_to_tree>

=item Returns

Zero if we are on the first tree, 1 otherwise

=back


=item * C<TrEd::Basics::new_tree($win_ref)>

=over 6

=item Purpose

Create new tree at the current position in the current file

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item Description

Marks the modified file as notSaved(1), calls on_tree_chage() callback
The tree on the current position and all the trees with position 
greater than the current position move to position + 1.

If $win_ref->{treeNo} is negative, new tree is created at the position counted from 
the end of file, if the position is after the end of file, new tree is created after 
the last tree

=item See also

L<Treex::PML::Document::new_tree|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>, 
L<go_to_tree>, L<Treex::PML::Document::notSaved|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if $win_ref->{FSFile} is not defined, 1 otherwise.

=back


=item * C<TrEd::Basics::new_tree_after($win_ref)>

=over 6

=item Purpose

Create new tree at the position after the current position in the current file

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item Description

Marks the modified file as notSaved(1), calls on_tree_chage() callback.

The tree after the current position and all the trees with position 
greater than the one after the current position move to position + 1

Unlike new_tree and prune_tree, this function does not support negative indices

=item See also

L<Treex::PML::Document::new_tree|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>, 
L<go_to_tree>, 
L<Treex::PML::Document::notSaved()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if $win_ref->{FSFile} is not defined, 1 otherwise

=back


=item * C<TrEd::Basics::prune_tree($win_ref)>

=over 6

=item Purpose

Delete tree at the current position in the current file

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item Description

Marks the modified file as notSaved(1), calls on_tree_chage() callback

The trees with position greater than the current position are moved to position - 1
 
This implementation allows deleting from the end of file using negative indices, e.g. $win_ref->treeNo = -1

=item See also

L<Treex::PML::Document::destroy_tree|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>, 
L<go_to_tree>, 
L<Treex::PML::Document::notSaved()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if $win_ref->{FSFile} or the current tree is not defined, 1 otherwise

=back


=item * C<TrEd::Basics::move_tree($win_ref, $delta)>

=over 6

=item Purpose

Move current tree to new position: current position + $delta

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>
C<$delta> -- the number of positions to move the tree

=item Description

Marks the modified file as notSaved(1), calls on_tree_chage() callback

All the trees with position greater than current position + $delta move to their current position + 1

=item See also

L<Treex::PML::Document::move_tree_to|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>, 
L<go_to_tree>, 
L<Treex::PML::Document::notSaved()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if $win_ref->{FSFile} is undefined or if delta is 0, 1 otherwise

=back


=item * C<TrEd::Basics::make_root($win_ref, $node, $discard)>

=over 6

=item Purpose

Make the specified $node new root of the current tree, 
optionally throwing out the former root if $discard is true

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>
C<$node> -- reference to Treex::PML::Node object that becomes new tree
C<$discard> -- switch telling if the root of the tree is discarded

=item Description

Marks the modified file as notSaved(1), calls on_node_chage() callback

Node types are not changed, i.e. attr('nodetype') of the new root will be preserved

=item See also

L<Treex::PML::Node::cut|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Node.pm>, 
L<Treex::PML::Node::paste_on|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Node.pm>,
L<go_to_tree>, 
L<Treex::PML::Document::notSaved()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if win_ref->{FSFile} is not defined, 1 otherwise

=back


=item * C<TrEd::Basics::new_node($win_ref)>

=over 6

=item Purpose

Create new node as a new child of current node

=item Parameters

C<$win_ref> -- hash reference, see description for L<go_to_tree>

=item Description

Marks the modified file as notSaved(1), calls on_node_chage() callback

=item See also

L<Treex::PML::Node::new|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Node.pm>,
L<Treex::PML::Struct::set_member|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Struct.pm>,
L<Treex::PML::Struct::paste_on|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Struct.pm>,
L<go_to_tree>, 
L<Treex::PML::Document::notSaved()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>

=item Returns

Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
reference to new Treex::PML::Node object otherwise

=back



=item * C<TrEd::Basics::prune_node($win_ref, $node)>

=over 6

=item Purpose

Delete specified node from current file


=item Parameters

  C<$win_ref> -- TrEd::Window ref $win_ref     -- ref to TrEd::Window object
  C<$node> -- : Treex::PML::Node ref  -- reference to the node to delete

=item Description

Marks the modified file as notSaved(1), calls on_node_chage() callback


=item See Also

L<Treex::PML::Node::destroy_leaf()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Node.pm>,
L<set_current>,

=item Returns

Undef if $win_ref->{FSFile} or $node or $node's parent are not defined, 
return value of Treex::PML::Node::destroy_leaf() is returned otherwise 
(which currently means that 1 is returned)

=back


=item * C<TrEd::Basics::set_current($win_ref, $node)>

=over 6

=item Purpose

Set $node as the current node (in $win_ref)


=item Parameters

  C<$win_ref> -- TrEd::Window ref $win_ref           -- ref to TrEd::Window object
  C<$node> -- Treex::PML::Node ref $node  -- reference to Treex::PML::Node object that becomes the current node

=item Description

calls on_current_chage() callback



=item Returns

Nothing


=back




=item * C<TrEd::Basics::absolutize_path($ref_filename, $filename, [$search_resource_path])>

=over 6

=item Purpose

Return absolute path unchanged, resolve relative path


=item Parameters

  C<$ref_filename> -- scalar $ref_path              -- a reference filename
  C<$filename> -- scalar $filename              -- a relative path to a file
  C<[$search_resource_path]> -- scalar $search_resource_paths -- 0 or 1

=item Description

just calls Treex::PML::ResolvePath(@_)


=item See Also

L<Treex::PML::ResolvePath()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/ResolvePath.pm>,

=item Returns

Resolved path, return value from Treex::PML::ResolvePath


=back


=item * C<TrEd::Basics::absolutize(@array)>

=over 6

=item Purpose

Make all paths in the @array absolute


=item Parameters

  C<@array> -- list @array -- list of paths to be changed into absolute paths


=item See Also

L<File::Spec->rel2abs>,

=item Returns

Array of absolute paths


=back


=item * C<TrEd::Basics::file_schema($fsfile)>

=over 6

=item Purpose

Return schema from file's metadata


=item Parameters

  C<$fsfile> -- Treex::PML::Document ref $fsfile -- the file whose schema we are searching for

=item Description

Should return the same value as calling $fsfile->schema() (according to Treex::PML doc)


=item See Also

L<Treex::PML::Document::metaData()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>,
L<Treex::PML::Document::schema()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>,

=item Returns

Schema for $fsfile


=back


=item * C<TrEd::Basics::get_secondary_files($fsfile)>

=over 6

=item Purpose

Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema


=item Parameters

  C<$fsfile> -- Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for 


=item See Also

L<Treex::PML::Document::appData()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document::appData.pm>,
L<get_secondary_files_recursively>,

=item Returns

List of Treex::PML::Document objects (every object appears just once in the list)


=back


=item * C<TrEd::Basics::get_secondary_files_recursively($fsfile)>

=over 6

=item Purpose

Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema, 
and also all secondary files of these secondary files, etc recursively

=item Parameters

  C<$fsfile> -- Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for 


=item See Also

L<Treex::PML::Document::appData()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>,
L<get_secondary_files>,

=item Returns

List of Treex::PML::Document objects (every object appears just once in the list) 


=back


=item * C<TrEd::Basics::get_primary_files($fsfile)>

=over 6

=item Purpose

Find a list of Treex::PML::Document objects representing related superior documents


=item Parameters

  C<$fsfile> -- Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for 


=item See Also

L<Treex::PML::Document::appData()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Document.pm>,
L<get_primary_files_recursively>,

=item Returns

List of Treex::PML::Document objects representing related superior documents


=back


=item * C<TrEd::Basics::get_primary_files_recursively($fsfile)>

=over 6

=item Purpose

Find a list of Treex::PML::Document objects representing related superior documents, 
and then list of all their superior documents, etc recursively

=item Parameters

  C<$fsfile> -- Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for 


=item See Also

L<get_primary_files>,

=item Returns

List of Treex::PML::Document objects representing related superior documents


=back



=back


=head1 DIAGNOSTICS


Croaks "The currently installed version of the File::Spec module 
doesn't provide rel2abs() method. Please upgrade it!" if the version
of File::Spec does not provide rel2abs subroutine.  


=head1 CONFIGURATION AND ENVIRONMENT



=head1 DEPENDENCIES

CPAN modules:
Treex::PML,
Readonly

TrEd modules:
TrEd::MinMax,


Standard Perl modules:
UNIVERSAL::DOES (for 5.10.1 and better),
File::Spec::Functions,
Exporter


=head1 INCOMPATIBILITIES

No known incompatibilities.


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
