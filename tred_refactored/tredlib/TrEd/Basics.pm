package TrEd::Basics;

BEGIN {
  use Treex::PML;
  require TrEd::MinMax;
  import TrEd::MinMax;
  import TrEd::MinMax qw(first);
  use UNIVERSAL::DOES;

  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK
	      $on_tree_change
	      $on_node_change
	      $on_current_change
	      $on_error
	    );
  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    $on_tree_change
    $on_node_change
    $on_current_change
    $on_error
    &gotoTree
    &nextTree
    &prevTree
    &newTree
    &newTreeAfter
    &pruneTree
    &moveTree
    &makeRoot
    &newNode
    &pruneNode
    &setCurrent
    &errorMessage
    &absolutize
    &absolutize_path
    &uniq
    &chooseNodeType
    &fileSchema
    &getSecondaryFiles
    &getSecondaryFilesRecursively
    &getPrimaryFiles
    &getPrimaryFilesRecursively
  );
  use Treex::PML::Schema;
}
use Data::Dumper;
use strict;
use warnings;

# different namespace only to load local rather than system files
# (rel2abs is not supported in all instalations)
use File::Spec;
if (not File::Spec->can('rel2abs')) {
  die "The currently installed version of the File::Spec module doesn't provide rel2abs() method. Please upgrade it!\n";
} else {
  require File::Spec::Functions;
  import File::Spec::Functions qw(rel2abs);
}


#######################################################################################
# Usage         : uniq(@array)
# Purpose       : Remove duplicit elements from array
# Returns       : Array without repeating elements
# Parameters    : array @arr  -- array to be uniqued 
# Throws        : no exception
# Comments      : Preserves type and order of elements
sub uniq { 
  # a -- track keys already seen elements
  my %a; 
  # return only those not yet seen 
  return grep { !($a{$_}++) } @_;
}

#######################################################################################
# Usage         : gotoTree($win_ref, $tree_no)
# Purpose       : Change the position in $win_ref to specified tree in current file
# Returns       : The ordinal number of the 'destination' tree (counted from 0), 
#                 undef if $win_ref->{FSFile} is not defined (empty list in list context)
# Parameters    : hash_ref $win_ref -- see comment below
#                 scalar $tree_no   -- the ordinal number of the desired tree (counted from 0) 
# Comments      : modifies $win_ref, calls on_tree_chage() callback
# See Also      : on_tree_change(), Treex::PML::Document::lastTreeNo(), Treex::PML::Document::treeList() 
#
# The $win parameter to the following two routines should be
# a hash reference, having at least the following keys:
#
# FSFile       => reference of the current Treex::PML::Document
# treeNo       => number of the current tree in the file
# macroContext => current context under which macros are run 
# currentNode  => pointer to the current node 
# root         => pointer to the root node of current tree
sub gotoTree {
  my ($win_ref, $tree_no) = @_;
  return if(!$win_ref->{FSFile});
  my $no = max(0, min($tree_no, $win_ref->{FSFile}->lastTreeNo()));
  return $no if ($no == $win_ref->{treeNo});
  $win_ref->{treeNo} = $no;
  $win_ref->{root} = $win_ref->{FSFile}->treeList()->[$win_ref->{treeNo}];
  # on_tree_change in tred needs only one parameter, why 3? 
  &$on_tree_change($win_ref, 'gotoTree', $no) if $on_tree_change;
  return $no;
}

#######################################################################################
# Usage         : nextTree($win_ref)
# Purpose       : Activate the next tree from the current file
# Returns       : Zero if we are on the last tree, 1 otherwise
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function 
# Throws        : no exception
# See Also      : gotoTree()
sub nextTree {
  my ($win_ref) = @_;
  return 0 if ($win_ref->{treeNo} >= $win_ref->{FSFile}->lastTreeNo());
  gotoTree($win_ref, $win_ref->{treeNo}+1);
  return 1;
}

#######################################################################################
# Usage         : prevTree($win_ref)
# Purpose       : Activate the previous tree from the current file
# Returns       : Zero if we are on the first tree, 1 otherwise
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function 
# Throws        : no exception
# See Also      : gotoTree()
sub prevTree {
  my ($win_ref) = @_;
  return 0 if ($win_ref->{treeNo} <= 0);
  gotoTree($win_ref, $win_ref->{treeNo}-1);
  return 1;
}

#######################################################################################
# Usage         : newTree($win_ref)
# Purpose       : Create new tree at the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} is not defined, 1 otherwise 
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The tree on the current position and all the trees with position 
#                 greater than the current position move to position + 1
#                 If $win_ref->{treeNo} is negative, new tree is created at the position counted from 
#                 the end of file, if the position is after the end of file, new tree is created after 
#                 the last tree
# See Also      : Treex::PML::Document::new_tree(), gotoTree(), on_tree_change(), Treex::PML::Document::notSaved()
sub newTree {
  my ($win_ref) = @_;
  my $fsfile = $win_ref->{FSFile};
  return if (!$fsfile);
  if ($fsfile->lastTreeNo() < 0) {
    $win_ref->{treeNo} = 0;
  }
  $win_ref->{root} = $fsfile->new_tree($win_ref->{treeNo});
  $fsfile->notSaved(1);
  &$on_tree_change($win_ref, 'newTree', $win_ref->{root}) if $on_tree_change;
  return 1;
}

#######################################################################################
# Usage         : newTreeAfter($win_ref)
# Purpose       : Create new tree at the position after the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} is not defined, 1 otherwise
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The tree after the current position and all the trees with position 
#                 greater than the one after the current position move to position + 1
#                 Unlike newTree and pruneTree, this function does not support negative indices
# See Also      : Treex::PML::Document::new_tree(), gotoTree(), on_tree_change(), Treex::PML::Document::notSaved()
sub newTreeAfter {
  my ($win_ref) = @_;
  my $fsfile = $win_ref->{FSFile};
  return if (!$fsfile);
  my $no = $win_ref->{treeNo} = max(0, min($win_ref->{treeNo}, $fsfile->lastTreeNo()) + 1);
  $win_ref->{root} = $fsfile->new_tree($no);
  $fsfile->notSaved(1);
  &$on_tree_change($win_ref, 'newTreeAfter', $win_ref->{root}) if $on_tree_change;
  return 1;
}

#######################################################################################
# Usage         : pruneTree($win_ref)
# Purpose       : Delete tree at the current position in the current file
# Returns       : Undef if $win_ref->{FSFile} or the current tree is not defined, 1 otherwise 
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 The trees with position greater than the current position are moved to position - 1 
#                 This implementation allows deleting from the end of file using negative indices, e.g. $win_ref->treeNo = -1
#TODO:            shouldn't it be coherent and we should not allow negative indices?
#                 and if we give it negative index, returned root always points to tree no 1
# See Also      : gotoTree(), on_tree_change(), Treex::PML::Document::notSaved(), Treex::PML::Document::destroy_tree()
sub pruneTree {
  my ($win_ref) = @_;
  my $fsfile = $win_ref->{FSFile};
  # why we don't use $fsfile->tree($win_ref->{treeNo}) instead?
  return if (!($fsfile and $fsfile->treeList()->[$win_ref->{treeNo}]));
  $win_ref->{root} = undef;
  my $no = $win_ref->{treeNo};
  $fsfile->destroy_tree($win_ref->{treeNo});
  $win_ref->{treeNo} = max(0, min($win_ref->{treeNo}, $fsfile->lastTreeNo));
  $win_ref->{root} = $fsfile->treeList()->[$win_ref->{treeNo}];
  $fsfile->notSaved(1);
  &$on_tree_change($win_ref,'pruneTree',$win_ref->{treeNo}) if $on_tree_change;
  return 1;
}

#######################################################################################
# Usage         : moveTree($win_ref, $delta)
# Purpose       : Move current tree to new position: current position + $delta
# Returns       : Undef if $win_ref->{FSFile} is undefined or if delta is 0, 1 otherwise
# Parameters    : hash_ref $win_ref -- see comment of gotoTree function
#                 scalar $delta     -- the number of positions to move the tree
# Throws        : Croaks if the current tree is out of bounds
# Comments      : Marks the modified file as notSaved(1), calls on_tree_chage() callback
#                 All the trees with position greater than current position + $delta 
#                 move to their current position + 1
# See Also      : Treex::PML::Document::move_tree_to(), on_tree_change(), Treex::PML::Document::notSaved()
sub moveTree {
  my ($win_ref, $delta) = @_;
  my $fsfile = $win_ref->{FSFile};
  return if (!$fsfile);
  my $no = $win_ref->{treeNo};
  $fsfile->move_tree_to($no, $no + $delta) || return;
  $win_ref->{treeNo} = $no + $delta;
  $win_ref->{root} = $win_ref->{FSFile}->treeList()->[$win_ref->{treeNo}];
  $win_ref->{FSFile}->notSaved(1);
  &$on_tree_change($win_ref,'moveTree',$win_ref->{treeNo}) if $on_tree_change;
  return 1;
}

#######################################################################################
# Usage         : makeRoot($win_ref, $node, $discard)
# Purpose       : Make the specified $node new root of the current tree, 
#                 optionally throwing out the former root if $discard is true
# Returns       : Undef if $win_ref->{FSFile} or $node is not defined, or 
#                 if the current's tree root is different from $node's root, 1 otherwise
# Parameters    : hash_ref $win_ref           -- see comment of gotoTree function
#                 Treex::PML::Node ref $node  -- reference to Treex::PML::Node object
#                 scalar $discard             -- switch telling if the root of the tree is discarded
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
#                 Node types are not changed, i.e. attr('nodetype') of the new root will be preserved
# See Also      : Treex::PML::Node::cut(), Treex::PML::Node::paste_on(), on_node_change(), Treex::PML::Document::notSaved()
sub makeRoot {
  my ($win_ref, $node, $discard) = @_;
  my $fsfile = $win_ref->{FSFile};
  return if(!($fsfile and $node));
  my $no = $win_ref->{treeNo};
  my $root = $fsfile->treeList()->[$no];
  # If the current's tree root is different from $node's root, return undef
  if ($root != $node->root()) {
    return;
  }
  # Disconnect the node from its parent and siblings
  $node->cut();
  # Make the node new root node
  $fsfile->treeList()->[$no] = $node;
  # If old root is not to be discarded, put it under the new root
  if (!$discard) {
    $root->paste_on($node, $fsfile->FS()->order());
  }
  $win_ref->{FSFile}->notSaved(1);
  &$on_node_change($win_ref, 'makeRoot', $node) if $on_tree_change;
  return 1;
}

#######################################################################################
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
sub newNode {
  ## Adds new son to current node
  my ($win_ref) = @_;
  my $parent = $win_ref->{currentNode};
  return if !($win_ref->{FSFile} and $parent);

  my $new_node = $parent->new(); # Treex::PML::Node warns users against using Treex::PML::Node->new(), hm?
  $new_node->paste_on($parent, $win_ref->{FSFile}->FS());
  my $order = $win_ref->{FSFile}->FS()->order();  
  if ($order) {
    # set_member and get_member are inherited from Treex::PML::Struct
    # and they have Treex::PML::Node equivalents setAttribute and getAttribute
    # Implementation of setAttribute is problematic and neither setAttribute, nor set_member 
    # can not be used without calling set_member with fully-qualified name 
    Treex::PML::Struct::set_member($new_node, $order, $parent->getAttribute($order));
  }
  setCurrent($win_ref, $new_node);
  $win_ref->{FSFile}->notSaved(1);
  &$on_node_change($win_ref, 'newNode', $new_node) if $on_node_change;

  return $new_node;
}

#######################################################################################
# Usage         : pruneNode($win_ref, $node)
# Purpose       : Delete specified node from current file
# Returns       : Undef if $win_ref->{FSFile} or $node or $node's parent are not defined, 
#                 return value of Treex::PML::Node::destroy_leaf() is returned otherwise 
#                 (which currently means that 1 is returned)
# Parameters    : hash_ref $win_ref     -- see comment of gotoTree function
#               : Treex::PML::Node ref  -- reference to the node to delete
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::destroy_leaf(), setCurrent()
#TODO: tests
sub pruneNode {
  ## Deletes given node
  my ($win_ref, $node)=@_;
  return undef if !($win_ref->{FSFile} and $node and $node->parent());
  
  # make all the sons of the current node its parent's sons
  my $son;
  while ($son = $node->firstson()) {
    $son->cut()->paste_on($node->parent(), $win_ref->{FSFile}->FS);
  }
  # if the deleted node is current node, make its parent the new current node
  if ($node == $win_ref->{currentNode}) {
    setCurrent($win_ref, $node->parent());
  }
  
  # Hm, destroy_leaf returns 1 (a scalar value), why is the son == 1?
  $son = $node->destroy_leaf();
  $win_ref->{FSFile}->notSaved(1);
  &$on_node_change($win_ref, 'newTree', $son) if $on_node_change;
  return $son;
}

#######################################################################################
# Usage         : setCurrent($win_ref, $node)
# Purpose       : Set $node as the current node (in $win_ref)
# Returns       : Nothing
# Parameters    : hash_ref $win_ref           -- see comment of gotoTree function
#                 Treex::PML::Node ref $node  -- reference to Treex::PML::Node object that becomes the current node
# Throws        : no exception
# Comments      : calls on_current_chage() callback
sub setCurrent {
  my ($win_ref, $node) = @_;
  my $prev = $win_ref->{currentNode};
  $win_ref->{currentNode} = $node;
  &$on_current_change($win_ref, $node, $prev, 'setCurrent') if $on_current_change;
  return;
}

#######################################################################################
# Usage         : _messageBox($top, $title, $msg, $nobug)
# Purpose       : Displays an error message in GUI
# Returns       : Nothing
# Parameters    : hash_ref $top   -- reference to top GUI window (probably a Tk object)
#                 scalar $title   -- title of the message window
#                 scalar $msg     -- message to be displayed in the message window
#                 scalar $nobug   -- severity of message -- 'warn' means warning, everything else means error
# Throws        : no exception
# Comments      : requires Tk::ErrorReport
# See Also      : Tk::ErrorReport()
#TODO: tests
sub _messageBox {
  my ($top, $title, $msg, $nobug) = @_;
  require Tk::ErrorReport;
  $nobug ||= '';
  $top->ErrorReport(
    -title   => $title,
    -msgtype => ($nobug eq 'warn' ? "WARNING" : "ERROR"),
    -message => ($nobug eq 'warn' ? "Operation produced warnings - full message follows.\n" 
      : $nobug ? "Operation failed - full error message follows.\n"
      : "An error occured during a protected transaction.\n".
	"If you believe that it was caused by a bug in TrEd, you may wish to\n".
	"copy the error message displayed below and report it to the author."),
    -body => $msg,
  );
  return;
}

#######################################################################################
# Usage         : errorMessage($win_ref, $msg, $nobug)
# Purpose       : Displays an error message in GUI or calls on_error() callback, if it is set
# Returns       : Nothing
# Parameters    : hash_ref $win_ref -- see documentation for gotoTree function
#                 scalar $title     -- title of the message window
#                 scalar $msg       -- message to be displayed in the message window
#                 scalar $nobug     -- severity of message -- 'warn' means warning, everything else means error
# Throws        : no exception
# Comments      : requires Tk::ErrorReport
# See Also      : _messageBox(), Tk::ErrorReport()
#TODO tests
sub errorMessage {
  my ($win_ref, $msg, $nobug)=@_;
  if ($on_error) {
    &$on_error(@_);
  } else {
    my $top;
    if (ref($win_ref) =~ /^Tk::/) {
      $top = $win_ref->toplevel;
    } elsif (ref($win_ref) eq 'Mainwin_refdow') {
      $top = $win_ref;
    } elsif (exists($win_ref->{framegroup}) and
              ref($win_ref->{framegroup}) and
              exists($win_ref->{framegroup}{top}) and
              ref($win_ref->{framegroup}{top})) {
      $top = $win_ref->{framegroup}->{top}->toplevel;
    }
    
    if ($top) {
      # report the error from the highest displayed toplevel window in stacking order
      my ($highest) = reverse $top->stackorder();
      $top = $top->Widget($highest);
      _messageBox($top, 'Error', $msg, $nobug);
    } else {
      print STDERR "$msg\n";
    }
  }
}

#######################################################################################
# Usage         : absolutize_path($ref_filename, $filename, [$search_resource_path])
# Purpose       : Return absolute path unchanged, resolve relative path
# Returns       : Resolved path, return value from Treex::PML::ResolvePath
# Parameters    : scalar $ref_path              -- a reference filename
#                 scalar $filename              -- a relative path to a file
#                 scalar $search_resource_paths -- 0 or 1
# Throws        : no exception
# Comments      : just calls Treex::PML::ResolvePath()
# See Also      : Treex::PML::ResolvePath()
#TODO tests
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
  return map { m(^[[:alnum:]]+:/|^\s*\||^\s*/) ? $_ : File::Spec->rel2abs($_) } grep { !/^\s*$/ } @_;
}

#######################################################################################
# Usage         : fileSchema($fsfile)
# Purpose       : Return schema from file's metadata
# Returns       : Schema for $fsfile
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose schema we are searching for
# Throws        : no exception
# Comments      : Should return the same value as calling $fsfile->schema() (according to Treex::PML doc)
# See Also      : Treex::PML::Document::metaData(), Treex::PML::Document::schema()
#TODO: tests
sub fileSchema {
  my ($fsfile) = @_;
  return $fsfile->metaData('schema');
}

#######################################################################################
# Usage         : getSecondaryFiles($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list)
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for 
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), getSecondaryFilesRecursively()
#TODO tests
sub getSecondaryFiles {
  my ($fsfile)=@_;
  # is probably the same as Treex::PML::Document->relatedDocuments()
  # a reference to a list of pairs (id, URL)
  my $requires = $fsfile->metaData('fs-require');
  my @secondary;
  if ($requires) {
    foreach my $req (@$requires) {
      my $id = $req->[0];
      my $req_fs = ref($fsfile->appData('ref')) ? $fsfile->appData('ref')->{$id} : undef;
      if (UNIVERSAL::DOES::does($req_fs, 'Treex::PML::Document')) {
        push(@secondary,$req_fs);
      }
    }
  }
  return uniq(@secondary);
}

#######################################################################################
# Usage         : getSecondaryFilesRecursively($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema, 
#                 and also all secondary files of these secondary files, etc recursively
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list) 
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for 
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), getSecondaryFiles()
#TODO tests
sub getSecondaryFilesRecursively {
  my ($fsfile) = @_;
  my @secondary = getSecondaryFiles($fsfile);
  my %seen;
  my $i=0;
  while ($i < @secondary) {
    my $sec = $secondary[$i];
    if (!exists($seen{$sec})) {
      $seen{$sec}=1;
      push(@secondary, getSecondaryFiles($sec));
    }
    $i++;
  }
  return uniq(@secondary);
}

#######################################################################################
# Usage         : getPrimaryFiles($fsfile)
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for 
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), getPrimaryFilesRecursively()
#TODO tests
sub getPrimaryFiles {
  my ($fsfile) = @_;
  # probably the same as Treex::PML::Document->relatedSuperDocuments()
  return @{ $fsfile->appData('fs-part-of') || [] };
}

#######################################################################################
# Usage         : getPrimaryFilesRecursively()
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents, 
#                 and then list of all their superior documents, etc recursively
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for 
# Throws        : no exception
# See Also      : getPrimaryFiles()
#TODO tests
sub getPrimaryFilesRecursively {
  my ($fsfile)=@_;
  my @primary = getPrimaryFiles($fsfile);
  my %seen;
  my $i=0;
  while ($i<@primary) {
    my $prim = $primary[$i];
    if (!exists($seen{$prim})) {
      $seen{$prim}=1;
      push(@primary, getPrimaryFiles($prim));
    }
    $i++;
  }
  return uniq(@primary);
}


1;

__END__

=head1 NAME


TrEd::Basics - ...


=head1 VERSION

This documentation refers to 
TrEd::Basics version 0.1.


=head1 SYNOPSIS

  use TrEd::Basics;
  
  

=head1 DESCRIPTION

...

=head1 SUBROUTINES/METHODS

=over 4 

=item * C<TrEd::Basics::uniq ()>

=over 6

=item Purpose

...

=item Parameters

C<@array> -- some array

=item Description


=item Returns

Uniqued array

=back


=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES


=head1 INCOMPATIBILITIES

...


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <email@address.cz>

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
