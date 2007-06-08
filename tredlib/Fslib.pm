#
# Revision: $Id$

# See the bottom of this file for the POD documentation. Search for the
# string '=head'.

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# Several Perl Routines to handle files in treebank FS format
# See complete help in POD format at the end of this file

package Fslib;
use Data::Dumper;
use Scalar::Util qw(weaken);

use strict;

use vars qw(@EXPORT @EXPORT_OK @ISA $VERSION $API_VERSION %COMPATIBLE_API_VERSION
            $field_re $attr_name_re
            $parent $firstson $lbrother $rbrother $type
            $SpecialTypes $FSError $Debug $resourcePath $resourcePathSplit);

use Exporter;
use File::Spec;

@ISA=qw(Exporter);
$VERSION = "1.6";        # change when new functions are added etc

$API_VERSION = "1.2";    # change when internal data structures change,
                         # in a way that may prevent old binary dumps to work properly

%COMPATIBLE_API_VERSION = map { $_ => 1 } 
  qw( 1.1 ), 
  $API_VERSION;

@EXPORT = qw/&Next &Prev &DeleteTree &DeleteLeaf &Cut &ImportBackends/;
@EXPORT_OK = qw/$FSError &Index &SetParent &SetLBrother &SetRBrother &SetFirstSon &Paste &Parent &LBrother &RBrother &FirstSon ResourcePaths FindInResources FindDirInResources FindDirInResourcePaths ResolvePath &CloneValue AddResourcePath AddResourcePathAsFirst SetResourcePaths RemoveResourcePath /;

use Carp;
#use vars qw/$VERSION @EXPORT @EXPORT_OK $field_re $parent $firstson $lbrother/;

$Debug=0;
*DEBUG = \$Debug;
$field_re='(?:\\\\[\\]\\,]|[^\\,\\]])*';

$resourcePathSplit = ($^O eq "MSWin32") ? ',' : ':';

$attr_name_re='[^\\\\ \\n\\r\\t{}(),=|]+';
$parent="_P_";
$firstson="_S_";
$lbrother="_L_";
$rbrother="_R_";
$type="_T_";
$SpecialTypes='WNVH';
$FSError=0;


sub Parent {
  my ($node) = @_;
  return $node->{$parent};
}

sub LBrother ($) {
  my ($node) = @_;
  return $node->{$lbrother};
}

sub RBrother ($) {
  my ($node) = @_;
  return $node->{$rbrother};
}

sub FirstSon ($) {
  my ($node) = @_;
  return $node->{$firstson};
}

sub SetParent ($$) {
  my ($node,$p) = @_;
  return unless $node;
  if (ref( $p )) {
    weaken( $node->{$parent} = $p );
  } else {
    $node->{$parent} = 0;
  }
  return $p;
}

sub SetLBrother ($$) {
  my ($node,$p) = @_;
  return unless $node;
  if (ref( $p )) {
    weaken( $node->{$lbrother} = $p );
  } else {
    $node->{$lbrother} = 0;
  }
  return $p;
}

sub SetRBrother ($$) {
  my ($node,$p) = @_;
  return unless $node;
  $node->{$rbrother}= ref($p) ? $p : 0;
}

sub SetFirstSon ($$) {
  my ($node,$p) = @_;
  return unless $node;
  $node->{$firstson}=ref($p) ? $p : 0;
}

sub Next {
  my ($node,$top) = @_;
  $top=0 if !$top;

  if ($node->{$firstson}) {
    return $node->{$firstson};
  }
  while ($node) {
    return 0 if ($node==$top or !$node->{$parent});
    return $node->{$rbrother} if $node->{$rbrother};
    $node = $node->{$parent};
  }
  return 0;
}

sub Prev {
  my ($node,$top) = @_;
  $top=0 if !$top;

  if ($node->{$lbrother}) {
    $node = $node->{$lbrother};
  DIGDOWN: while ($node->{$firstson}) {
      $node = $node->{$firstson};
    LASTBROTHER: while ($node->{$rbrother}) {
    	$node = $node->{$rbrother};
        next LASTBROTHER;
      }
      next DIGDOWN;
    }
    return $node;
  }
  return 0 if ($node == $top or !$node->{$parent});
  return $node->{$parent};
}

sub Cut ($) {
  my ($node)=@_;
  return $node unless $node;
  my $p = $node->{$parent};
  if ($p and $node==$p->{$firstson}) {
    $p->{$firstson}=$node->{$rbrother};
  }
  $node->{$lbrother}->set_rbrother($node->{$rbrother}) if ($node->{$lbrother});
  $node->{$rbrother}->set_lbrother($node->{$lbrother}) if ($node->{$rbrother});
  $node->{$parent}=$node->{$lbrother}=$node->{$rbrother}=0;
  return $node;
}

sub Paste ($$$) {
  my ($node,$p,$fsformat)=@_;
  my $aord = ref($fsformat) ? $fsformat->order : $fsformat;
  my $ordnum = defined($aord) ? $node->getAttribute($aord) : undef;
  my $b=$p->{$firstson};
  if ($b and defined($ordnum) and $ordnum>$b->getAttribute($aord)) {
    $b=$b->{$rbrother} while ($b->{$rbrother} and $ordnum>$b->{$rbrother}->getAttribute($aord));
    my $rb = $b->{$rbrother};
    $node->{$rbrother}=$rb;
    $rb->set_lbrother( $node ) if $rb;
    $b->{$rbrother}=$node;
    $node->set_lbrother( $b );
    $node->set_parent( $p );
  } else {
    $node->{$rbrother}=$b;
    $p->{$firstson}=$node;
    $node->{$lbrother}=0;
    $b->set_lbrother( $node ) if ($b);
    $node->set_parent( $p );
  }
  return $node;
}

sub PasteAfter ($$) {
  my ($node,$ref_node)=@_;

  croak("Fslib::PasteAfter: ref_node undefined") unless $ref_node;
  my $p = $ref_node->parent;
  croak("Fslib::PasteAfter: ref_node has no parent") unless $p;

  my $rb = $ref_node->{$rbrother};
  $node->{$rbrother}=$rb;
  $rb->set_lbrother( $node ) if $rb;
  $ref_node->{$rbrother}=$node;
  $node->set_lbrother( $ref_node );
  $node->set_parent( $p );
  return $node;
}

sub PasteBefore ($$) {
  my ($node,$ref_node)=@_;

  croak("Fslib::PasteBefore: ref_node undefined") unless $ref_node;
  my $p = $ref_node->parent;
  croak("Fslib::PasteBefore: ref_node has no parent") unless $p;

  my $lb = $ref_node->{$lbrother};
  $node->set_lbrother( $lb );
  if ($lb) {
    $lb->{$rbrother}=$node;
  } else {
    $p->{$firstson}=$node;
  }
  $ref_node->set_lbrother( $node );
  $node->{$rbrother}=$ref_node;
  $node->set_parent( $p );
  return $node;
}

sub DeleteTree ($) {
  my ($top,$node,$next);
  $top=$node=$_[0];
  while ($node) {
    if ($node!=$top
	and !$node->{$firstson}
	and !$node->{$lbrother}
	and !$node->{$rbrother}) {
      $next=$node->{$parent};
    } else {
      $next=Next($node,$top);
    }
    DeleteLeaf($node);
    $node=$next;
  }
}

sub DeleteLeaf ($) {
  my ($node) = @_;
  if (!$node->{$firstson}) {
    my $lb = $node->{$lbrother};
    $node->{$rbrother}->set_lbrother($lb) if ($node->{$rbrother});

    if ($lb) {
      $lb->{$rbrother}=$node->{$rbrother};
    } else {
      $node->{$parent}->{$firstson}=$node->{$rbrother} if $node->{$parent};
    }
    undef %$node;
    undef $node;
    return 1;
  }
  return 0;
}

sub CloneValue {
  if (ref $_[0]) {
    my $val;
    return eval Data::Dumper->new([$_[0]],['val'])->Purity(1)->Dump;
  } else {
    return $_[0]
  }
}

sub Index ($$) {
  my ($ar,$i) = @_;
  for (my $n=0;$n<=$#$ar;$n++) {
    return $n if ($ar->[$n] eq $i);
  }
  return;
}

sub ReadLine {
  my ($handle)=@_;
  local $_;
  if (ref($handle) eq 'ARRAY') {
    $_=shift @$handle;
  } else { $_=<$handle>;
	   return $_; }
  return $_;
}

sub ReadEscapedLine {
  my ($handle)=@_;                # file handle or array reference
  my $l="";
  local $_;
  while ($_=ReadLine($handle)) {
    if (s/\\\r*\n?$//og) {
      $l.=$_; next;
    } # if backslashed eol, concatenate
    $l.=$_;
#    use Devel::Peek;
#    Dump($l);
    last;                               # else we have the whole tree
  }
  return $l;
}


sub _is_url {
  return ($_[0] =~ m(^\s*[[:alnum:]]+://)) ? 1 : 0;
}
sub _is_absolute {
  my ($path) = @_;
  return (_is_url($path) or File::Spec->file_name_is_absolute($path));
}

sub FindDirInResources {
  my ($filename)=@_;
  unless (_is_absolute($filename)) {
    for my $dir (split /\Q${Fslib::resourcePathSplit}\E/o,$resourcePath) {
      my $f = File::Spec->catfile($dir,$filename);
      return $f if -d $f;
    }
  }
  return $filename;
}
*FindDirInResourcePaths = \&FindDirInResources;

sub FindInResources {
  my ($filename)=@_;
  unless (_is_absolute($filename)) {
    for my $dir (split /\Q${Fslib::resourcePathSplit}\E/o,$resourcePath) {
      my $f = File::Spec->catfile($dir,$filename);
      return $f if -f $f;
    }
  }
  return $filename;
}


sub ResourcePath {
  return split /\Q${Fslib::resourcePathSplit}\E/, $Fslib::resourcePath;
}

sub AddResourcePath {
  if ($resourcePath ne q{}) {
    $resourcePath.=$resourcePathSplit;
  }
  $resourcePath .= join $resourcePathSplit,@_;
}

sub AddResourcePathAsFirst {
  $resourcePath = join($resourcePathSplit,@_) .
    ($resourcePath ne q{}) ? $resourcePathSplit.$resourcePath : q{};
}

sub RemoveResourcePath {
  my %remove;
  @remove{@_} = ();
  $resourcePath = join $resourcePathSplit, grep { !exists($remove{$_}) }
    split /\Q$resourcePathSplit\E/, $resourcePath;
}

sub SetResourcePaths {
  $resourcePath=join $resourcePathSplit,@_;
}

sub _strip_file_prefix {
  if ($_[0] =~ m{^file:/}) {
      $_[0] = IOBackend::strip_protocol($_[0]);
      return 1;
  } else {
      return 0;
  }
}

sub ResolvePath ($$;$) {
  my ($orig, $href,$use_resources)=@_;
  print STDERR "ResolvePath: '$href' base='$orig' use_resources=$use_resources\n" if $Fslib::Debug;
  my $href_was_file_url = _strip_file_prefix($href);
  unless (_is_absolute($href)) {
    my $orig_was_file_url = _strip_file_prefix($orig);
    if (_is_url($orig)) {
      print STDERR "ResolvePath: as URL:\n" if $Fslib::Debug;
      # for URLs, reverse the process a bit:
      # 1st, try a local relative path
      if (-f $href) {
	$href = File::Spec->rel2abs($href);
	print STDERR "ResolvePath: (URL-local) result='$href'\n" if $Fslib::Debug;
	return $href;
      }
      # 2nd, try resource path
      if ($use_resources) {
	my $res = FindInResources($href);
	if ($res ne $href) {
	  print STDERR "ResolvePath: (URL-resources) result='$res'\n" if $Fslib::Debug;
	  return $res;
	}
      }
      # 3rd
      # strip filename part from the $orig URL and append $href to it
      $orig =~ s{/[^/]*$}{};
      print STDERR "ResolvePath: (URL) result='$orig/$href'\n" if $Fslib::Debug;
      return $orig.'/'.$href;
    } else {
      my ($vol,$dir) = File::Spec->splitpath(File::Spec->rel2abs($orig));
      my $rel = File::Spec->rel2abs($href,File::Spec->catfile($vol,$dir));
      print STDERR "ResolvePath: trying rel: $rel, based on: ",File::Spec->catfile($vol,$dir),"\n" 
	if $Fslib::Debug;
      if (-f $rel) {
	$rel = 'file://'.$rel if $orig_was_file_url;
	print STDERR "ResolvePath: (1) result='$rel'\n" if $Fslib::Debug;
	return $rel;
      } elsif (-f $href) {
	print STDERR "ResolvePath: (2) result='$href'\n" if $Fslib::Debug;
	return $href;
      }
    }
    my $result = $use_resources ? FindInResources($href) : $href;
    print STDERR "ResolvePath: (3) result='$result'\n" if $Fslib::Debug;
    return $result;
  } else {
    $href = 'file://'.$href if $href_was_file_url;
    print STDERR "ResolvePath: (4) result='$href'\n" if $Fslib::Debug;
    return $href;
  }
}

sub ImportBackends {
  my @backends=();
  foreach my $backend (@_) {
    print STDERR "LOADING $backend\n" if $Fslib::Debug;
    if (eval { require $backend.".pm"; } ) {
      push @backends,$backend;
    } else {
      print STDERR "FAILED TO LOAD $backend\n";
    }
    print STDERR $@ if ($@);
  }
  return @backends;
}

############################################################
############################################################

=head1 Fslib

Fslib.pm - library for tree processing

=head1 SYNOPSIS

  use Fslib qw(ImportBackends);

  my @IObackends = ImportBackends(qw(PMLBackend StorableBackend));

  my $file="trees.fs";
  my $fs = FSFile->newFSFile($file,\@IObackends);

  if ($fs->lastTreeNo<0) { die "File is empty or corrupted!\n" }
  foreach my $tree ($fs->trees) {
     my $node = $tree;
     while ($node) {
       ...  # do something on node
       $node = $node->following; # depth-first traversal
     }
  }
  $fs->writeFile("$file.out");

=head1 DESCRIPTION

=head2 Introduction

This package provides API for manipulating treebank files; originally
only files in so-called FS format (designed by Michal Kren) were
supported, but the current implementation features pluggable I/O
backends for other data formats, such as generic XML-based format PML.

Fslib provides among other the following classes:

=over 4

=item L</"FSFile">

representing a FS file (consisting of a set of trees, type
declarations, meta-data etc.). FSFile object has containers for
additional (user or application defined) data structures (run-time
only).

=item L</"FSNode">

representing a node of a tree (including the root node, which also
represents the whole tree).

=back

=head2 Representation of trees

Fslib provides representation for oriented rooted trees (such as
dependency trees or constituency trees).

In Fslib, each tree is represented by its root-node. A node is a
L</"FSNode"> object, which is underlined by a usual Perl hash
reference whose hash keys represent node attributes (name-value
pairs).

The set of available attributes at each node is specified in the data
format (which, depending on I/O backend, is represented either by a
L</"FSFormat"> or L</"Fslib::Schema"> object; whereas L</"FSFormat">
uses a fixed set of attributes for all nodes, in the latter case the
set of attributes may be specific to a node, providing a wide range of
data-structures for attribute values). Other keys may be added to the
node hashes at run-time but such keys are not normally preserved via
I/O backends. FS format also allows to declare some attributes as
representants of extra features, such as total ordering on a tree,
text value of a node, indicator for "hidden" nodes, etc.


Attribute values may be plain scalars or Fslib data objects
(L</"Fslib::List">, L</"Fslib::Alt">, L</"Fslib::Struct">,
L</"Fslib::Container">, L</"Fslib::Seq">.

The tree structure can be modified and traversed by various
L</"FSNode"> object methods, such as C<parent>, C<firstson>,
C<rbrother>, C<lbrother>, C<following>, C<previous>, C<cut>,
C<paste_on>, C<paste_after>, and C<paste_before>.

Four special keys are reserved for representing the tree structure in
the L</"FSNode"> hash. These keys are defined in global variables:
C<$Fslib::parent>, C<$Fslib::firstson>, C<$Fslib::rbrother>, and
C<$Fslib::lbrother>. Another special key C<$Fslib::type> is reserved
for storing data type information. It is highly recommended to use
L</"FSNode"> object methods instead of accessing these hash keys
directly.

=head2 Resource paths

Since some I/O backends require additional resources (such as schemas,
DTDs, configuration files, XSLT stylesheets, dictionaries, etc.), For
this purpose, Fslib maintains a list of so called "resource paths"
which I/O backends may conveniently search for their resources.

See L</"PACKAGE FUNCTIONS"> for description of functions related to
pluggable I/O backends and the list resource paths..

=cut

=head1 OBJECT CLASSES

=cut

############################################################
#
# FS Node
# =========
#
#

package FSNode;
use Carp;
use strict;
use vars qw(@ISA);
use PMLSchema;

@ISA=qw(Fslib::Struct);

=pod

=head2 FSNode

FSNode - Fslib class representing a node.

=over 4

=cut

=pod

=item FSNode->new

Create a new FSNode object. FSNode is basically a hash reference, which
means that you may simply access node's attributes as C<$node->>C<{attribute}>

=cut


sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $size = shift;
  my $new = {@_};
  keys (%$new) = $size + 5 if defined($size);
  bless $new, $class;
  $new->initialize();
  return $new;
}

=pod

=item $node->initialize

This function initializes FSNode. It is called by the constructor new.

=cut

sub initialize {
  my ($self) = @_;
  return unless ref($self);
  $self->{$Fslib::firstson}=0;
  $self->{$Fslib::lbrother}=0;
  $self->{$Fslib::rbrother}=0;
  $self->{$Fslib::parent}=0;
}

=item $node->destroy

This function destroys a FSNode (and all its descendants). The node
should not be attached to a tree.

=cut

sub destroy {
  my ($self) = @_;
  Fslib::DeleteTree($self);
}

sub DESTROY {
    my ($self) = @_;
    return unless ref($self);
    %{$self}=();
    return 1;
}

=pod

=item $node->parent

Return node's parent node (C<undef> if none).

=cut


sub parent {
  my ($self) = @_;
  return ref($self) ? Fslib::Parent($self) : undef;
}

=pod

=item $node->type (attr-path?)

If called without an argument or if C<attr-path> is empty, return
node's data-type declaration (C<undef> if none). If C<attr-path> is
non-empty, return the data-type declaration of the value reachable
from C<$node> under the attribute-path C<attr-path>.

=cut


sub type {
  my ($self,$attr) = @_;
  return unless ref $self;
  my $type = $self->{$Fslib::type};
  if ($attr ne '') {
    return $type ? $type->find($attr,1) : undef;
  } elsif (ref($type) eq 'Fslib::Type') {
    # pushing backward compatibility forward 
    my $decl = $type->type_decl;
    return UNIVERSAL::isa($decl,'PMLSchema::Decl') ? $decl : $type;
  } else {
    return $type;
  }
}

=item $node->root

Find and return the root of the node's tree.

=cut


sub root {
  my ($self) = @_;
  my $root=$self; 
  my $p;
  while ($p=Fslib::Parent($root)) {
    $root=$p 
  }
  return $root;
}


=item $node->level

Calculate node's level (root-level is 0).

=cut

sub level {
  my ($node) = @_;
  my $level=-1;
  while ($node) {
    $node=$node->parent;
    $level++;
  }
  return $level;
}


=pod

=item $node->lbrother

Return node's left brother node (C<undef> if none).

=cut


sub lbrother {
  my ($self) = @_;
  return ref($self) ? Fslib::LBrother($self) : undef;
}

=pod

=item $node->rbrother

Return node's right brother node (C<undef> if none).

=cut


sub rbrother {
  my ($self) = @_;
  return ref($self) ? Fslib::RBrother($self) : undef;
}

=pod

=item $node->firstson

Return node's first dependent node (C<undef> if none).

=cut


sub firstson {
  my ($self) = @_;
  return ref($self) ? Fslib::FirstSon($self) : undef;
}

*set_parent   = \&Fslib::SetParent;
*set_lbrother = \&Fslib::SetLBrother;
*set_rbrother = \&Fslib::SetRBrother;
*set_firstson = \&Fslib::SetFirstSon;


=item $node->set_type (type)

Associate FSNode object with a type declaration-object (see
L<PMLSchema> class).

=cut

sub set_type ($$) {
  my ($node,$type) = @_;
  $node->{$Fslib::type}=$type;
}

=item $node->set_type_by_name (schema,type-name)

Lookup a structure or container declaration in the given Fslib::Schema
by its type name and associate the corresponding type-declaration
object with the FSNode.

=cut

sub set_type_by_name ($$$) {
  if (@_!=3) {
    croak('Usage: $node->set_type_by_name($schema, $type_name)');
  }
  my ($node,$schema,$name) = @_;
  my $type = $schema->get_type_by_name($name);
  if (ref($type)) {
    my $decl_type = $type->get_decl_type;
    if ($decl_type == PML_MEMBER_DECL() ||
        $decl_type == PML_ELEMENT_DECL() ||
        $decl_type == PML_TYPE_DECL() ||
	$decl_type == PML_ROOT_DECL() ) {
      $type = $type->get_content_decl;
    }
    $decl_type = $type->get_decl_type;
    if ($decl_type == PML_CONTAINER_DECL() ||
	$decl_type == PML_STRUCTURE_DECL()) {
      $node->set_type($type);
    } else {
      croak "FSNode::set_type_by_name: Incompatible type '$name' (neither a structure nor a container)";
    }
  } else {
    croak "FSNode::set_type_by_name: Type not found '$name'";
  }
}

=item $node->validate (attr-path?,log?)

This method requires C<$node> to be associated with a type declaration.

Validates the content of the node according to the associated type and
schema. If attr-path is non-empty, validate only attribute selected by
the attribute path. An array reference may be passed as the 2nd
argument C<log> to obtain a detailed report of all validation errors.

Note: this method does not validate descendants of the node. Use e.g.

  $node->validate_subtree($log);

to validate the complete subtree.

Returns: 1 if the content validates, 0 otherwise.

=cut

sub validate {
  my ($node, $path, $log) = @_;
  if (defined $log and UNIVERSAL::isa('ARRAY',$log)) {
    croak "FSNode::validate: log must be an ARRAY reference";
  }
  my $type = $node->type;
  if (!ref($type)) {
    croak "FSNode::validate: Cannot determine node data type!";
  }
  if ($path eq q{}) {
    $type->validate_object($node,{ log=>$log, no_childnodes => 1 });
  } else {
    my $mtype = $type->find($path);
    if ($mtype) {
      $mtype->validate_object($node->attr($path),
			      {
				path => $path,
				log=>$log
			       });
    } else {
      croak "FSNode::validate: can't determine data type from attribute-path '$path'!";
    }
  }
}

=item $node->validate_subtree (log?)

This method requires C<$node> to be associated with a type declaration.

Validates the content of the node and all its descendants according to
the associated type and schema. An array reference C<log> may be
passed as an argument to obtain a detailed report of all validation
errors.

Returns: 1 if the subtree validates, 0 otherwise.

=cut

sub validate_subtree {
  my ($node, $log) = @_;
  if (defined $log and UNIVERSAL::isa('ARRAY',$log)) {
    croak "FSNode::validate: log must be an ARRAY reference";
  }
  my $type = $node->type;
  if (!ref($type)) {
    croak "FSNode::validate: Cannot determine node data type!";
  }
  $type->validate_object($node,{ log=>$log });
}


=pod

=item $node->following (top?)

Return the next node of the subtree in the order given by structure
(C<undef> if none). If any descendant exists, the first one is
returned. Otherwise, right brother is returned, if any.  If the given
node has neither a descendant nor a right brother, the right brother
of the first (lowest) ancestor for which right brother exists, is
returned.

=cut

sub following {
  my ($self,$top) = @_;
  return ref($self) ? Fslib::Next($self,$top) : undef;
}

=pod

=item $node->following_visible (FSFormat_object,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub following_visible {
  my ($self,$fsformat,$top) = @_;
  return unless ref($self);
  my $node=Fslib::Next($self,$top);
  return $node unless ref($fsformat);
  my $hiding;
  while ($node) {
    return $node unless ($hiding=$fsformat->isHidden($node));
#    $node=Fslib::Next($node,$top);
    $node=$hiding->following_right_or_up($top);
  }
}

=pod

=item $node->following_right_or_up (top?)

Return the next node of the subtree in the order given by
structure (C<undef> if none), but not descending.

=cut

sub following_right_or_up {
  my ($self,$top) = @_;
  return unless ref($self);

  my $node=$self;
  while ($node) {
    return 0 if ($node==$top or !$node->parent);
    return $node->rbrother if $node->rbrother;
    $node = $node->parent;
  }
}


=pod

=item $node->previous (top?)

Return the previous node of the subtree in the order given by
structure (C<undef> if none). The way of searching described in
C<following> is used here in reversed order.

=cut

sub previous {
  my ($self,$top) = @_;
  return ref($self) ? Fslib::Prev($self,$top) : undef;
}

=pod

=item $node->previous_visible (FSFormat_object,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub previous_visible {
  my ($self,$fsformat,$top) = @_;
  return unless ref($self);
  my $node=Fslib::Prev($self,$top);
  my $hiding;
  return $node unless ref($fsformat);
  while ($node) {
    return $node unless ($hiding=$fsformat->isHidden($node));
    $node=Fslib::Prev($hiding,$top);
  }
}


=pod

=item $node->rightmost_descendant (node)

Return the rightmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub rightmost_descendant {
  my ($self) = @_;
  return unless ref($self);
  my $node=$self;
 DIGDOWN: while ($node->firstson) {
    $node = $node->firstson;
  LASTBROTHER: while ($node->rbrother) {
      $node = $node->rbrother;
      next LASTBROTHER;
    }
    next DIGDOWN;
  }
  return $node;
}


=pod

=item $node->leftmost_descendant (node)

Return the leftmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub leftmost_descendant {
  my ($self) = @_;
  return unless ref($self);
  my $node=$self;
  $node=$node->firstson while ($node->firstson);
  return $node;
}

=pod

=item $node->getAttribute (attr_name)

Return value of the given attribute.

=cut

# inherited from Fslib::Struct (compatibility)

=item $node->attr (path)

Return value of an attribute specified as a path of the form
attr/subattr/[n]/subsubattr/[m], where [n] can be used to pick n-th
element of a list or alternative.  If alternative or list is
encountered but no index is given, then 1st element of the list or
alternative is used (except for the case when list or alternative
is found in the last path step, in which case the corresponding object
- list or alternative - is returned as is).

=cut

sub attr {
  my ($node,$path, $strict) = @_;
  my $val = $node;
  for my $step (split /\//, $path) {
    if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
      if ($step =~ /^\[(\d+)\]/) {
	$val = $val->[$1-1];
      } elsif ($strict) {
#	warn "Can't follow attribute path '$path' (step '$step')\n";
	return; # ERROR
      } else {
	$val = $val->[0]{$step};
      }
    } elsif (ref($val) eq 'Fslib::Seq') {
      if ($step =~ /^\[(\d+)\]/) {
	$val = $val->[$1-1][1]; # value
      } elsif ($step =~ /^([^\[]+)(?:\[(\d+)\])?/) {
	my $i = $2;
	$val = $val->values($1);
	if ($i ne q{}) {
	  $val = $val->[ $i ];
	}
      } else {
	return; # ERROR
      }
    } elsif (ref($val)) {
      $val = $val->{$step};
    } elsif (defined($val)) {
#      warn "Can't follow attribute path '$path' (step '$step')\n";
      return; # ERROR
    } else {
      return '';
    }
  }
  return $val;
}

sub flat_attr {
  my ($node,$path) = @_;
  return "$node" unless ref($node);
  my ($step,$rest) = split /\//, $path,2;
  if (ref($node) eq 'Fslib::List' or
      ref($node) eq 'Fslib::Alt') {
    if ($step =~ /^\[(\d+)\]$/) {
      return flat_attr($node->[$1-1],$rest);
    } else {
      return join "|",map { flat_attr($_,$rest) } @$node;
    }
  } else {
    return flat_attr($node->{$step},$rest);
  }
}

=item $node->set_attr (path,value,strict?)

Set value of an attribute specified by a path of the form
attr/subattr/[n]/subsubattr/[m], where [n] can be used to pick n-th
element of a list or alternative.  If strict==0 and an alternative or
list is encountered but no index is given, then 1st element of the
list or alternative is used (except for the case when list or
alternative is found in the last path step, in which case the entire
list or alternative is overwritten by the given value). If strict==1
and a list or an alternative is encountered in the value tree but no
step of the form [n] is given, a warning is issued and undef is
returned. If strict==2, the same approach as with strict==1 is taken,
only errors are reported via a croak.

=cut

sub set_attr {
  my ($node,$path, $value, $strict) = @_;
  my $val = $node;
  my @steps = split /\//, $path;
  while (@steps) {
    my $step = shift @steps;
    if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
      if ($step =~ /^\[(\d+)\]/) {
	if (@steps) {
	  $val = $val->[$1-1];
	} else {
	  $val->[$1-1] = $value;
	  return $value;
	}
      } elsif ($strict) {
	my $msg = "Can't follow attribute path '$path' (step '$step')";
	croak $msg if ($strict==2);
	warn $msg."\n";
	return; # ERROR
      } else {
	if (@steps) {
	  $val = $val->[0]{$step};
	} else {
	  $val->[0]{$step} = $value;
	  return $value;
	}
      }
    } elsif (ref($val)) {
      if (@steps) {
	if (!defined($val->{$step}) and $steps[0]!~/^\[/) {
	  $val->{$step}=Fslib::Struct->new;
	}
	$val = $val->{$step};
      } else {
	$val->{$step} = $value;
	return $value;
      }
    } elsif (defined($val)) {
      my $msg = "Can't follow attribute path '$path' (step '$step')";
      croak $msg if ($strict==2);
      warn $msg."\n";
      return; # ERROR
    } else {
      return '';
    }
  }
  return;
}

=pod

=item $node->setAttribute (name,value)

Set value of the given attribute.

=cut

# inherited from Fslib::Struct (compatibility)

=pod

=item $node->children

Return a list of dependent nodes.

=cut

sub children {
  my $self = $_[0];
  my @children=();
  my $child=$self->firstson;
  while ($child) {
    push @children, $child;
    $child=$child->rbrother;
  }
  return @children;
}

=pod

=item $node->visible_children (fsformat)

Return a list of visible dependent nodes.

=cut

sub visible_children {
  my ($self,$fsformat) = @_;
  croak "required parameter missing for visible_children(fsformat)" unless $fsformat;
  my @children=();
  unless ($fsformat->isHidden($self)) {
    my $hid=$fsformat->hide;
    my $child=$self->firstson;
    while ($child) {
      push @children, $child if $child->getAttribute($hid) eq '';
      $child=$child->rbrother;
    }
  }
  return @children;
}


=item $node->descendants

Return a list recursively dependent nodes.

=cut

sub descendants {
  my $self = $_[0];
  my @kin=();
  my $desc=$self->following($self);
  while ($desc) {
    push @kin, $desc;
    $desc=$desc->following($self);
  }
  return @kin;
}

=item $node->visible_descendants (fsformat)

Return a list recursively dependent visible nodes.

=cut

sub visible_descendants($$) {
  my ($self,$fsformat) = @_;
  croak "required parameter missing for visible_descendants(fsfile)" unless $fsformat;
  my @kin=();
  my $desc=$self->following_visible($fsformat,$self);
  while ($desc) {
    push @kin, $desc;
    $desc=$desc->following_visible($fsformat,$self);
  }
  return @kin;
}

=item $node->cut ()

Disconnect the node from its parent and siblings. Returns the node
itself.

=cut

*cut = \&Fslib::Cut;

=item $node->paste_on (new-parent,ord-attr)

Attach a new or previously disconnected node to a new parent, placing
it to the position among the other child nodes corresponding to a
numerical value obtained from the ordering attribute specified in 
C<ord-attr>. 

This method does not check node types, but one can use
C<$parent-E<gt>test_child_type($node)> before using this method to verify
that the node is of a permitted child-type for the parent node.

Returns the node itself.

=cut

*paste_on = \&Fslib::Paste;

=item $node->paste_after (ref-node)

Attach a new or previously disconnected node to ref-node's parent node
as a closest right sibling of ref-node in the structural order of
sibling nodes.

This method does not check node types, but one can use
C<$ref_node-E<gt>parent->test_child_type($node)> before using this method
to verify that the node is of a permitted child-type for the parent
node.

Returns the node itself.

=cut

*paste_after = \&Fslib::PasteAfter;

=item $node->paste_before (ref-node)

Attach a new or previously disconnected node to ref-node's parent node
as a closest left sibling of ref-node in the structural order of
sibling nodes.

This method does not check node types, but one can use
C<$ref_node-E<gt>parent->test_child_type($node)> before using this method
to verify that the node is of a permitted child-type for the parent
node.

Returns the node itself.

=cut

*paste_before = \&Fslib::PasteBefore;

=item $node->test_child_type ( test_node )

This method can be used before a C<paste_on> or a similar operation to
test if the node provided as an argument is of a type that is valid
for children of the current node. More specifically, return 1 if the
current node is not associated with a type declaration or if it has
a #CHILDNODES member which is of a list or sequence type and the list
or sequence can contain members of the type of C<test_node>.
Otherwise return 0.

A type-declaration object can be passed directly instead of
C<test_node>.

=cut

sub test_child_type {
  my ($self, $obj) = @_;
  die 'Usage: $node->test_child_type($node_or_decl)' unless ref($obj);
  my $type =  $self->type;
  return 1 unless $type;
  if (UNIVERSAL::isa($obj,'PMLSchema::Decl')) {
    if ($obj->get_decl_type == PML_TYPE_DECL) {
      # a named type decl passed, no problem
      $obj = $obj->get_content_decl;
    }
  } else {
    # assume it's a node
    $obj = $obj->type;
    return 0 unless $obj;
  }
  if ($type->get_decl_type == PML_ELEMENT_DECL) {
    $type = $type->get_content_decl;
  }
  my ($ch) = $type->find_members_by_role('#CHILDNODES');
  if ($ch) {
    my $ch_is = $ch->get_decl_type;
    if ($ch_is == PML_MEMBER_DECL) {
      $ch = $ch->get_content_decl;
      $ch_is = $ch->get_decl_type;
    }
    if ($ch_is == PML_SEQUENCE_DECL) {
      return 1 if $ch->find_elements_by_content_decl($obj);
    } elsif ($ch_is == PML_LIST_DECL) { 
      return 1 if $ch->get_content_decl == $obj;
    }
  } else {
    return 0;
  }
}

=item $node->get_order

For a typed node return value of the ordering attribute on the node
(i.e. the one with role #ORDER). Returns undef for untyped nodes (for
untyped FS nodes the name of the ordering attribute can be obtained
from the FSFormat object).

=cut

sub get_order {
  my $self = $_[0];
  my $oattr = $self->get_ordering_member_name;
  return defined $oattr ? $self->{$oattr} : undef;
}

=item $node->get_ordering_member_name

For a typed node return name of the ordering attribute on the node
(i.e. the one with role #ORDER). Returns undef for untyped nodes (for
untyped FS nodes the name of the ordering attribute can be obtained
from the FSFormat object).

=cut

sub get_ordering_member_name {
  my $self = $_[0];
  my $type = $self->type;
  return undef unless $type;
  if ($type->get_decl_type == PML_ELEMENT_DECL) {
    $type = $type->get_content_decl;
  }
  my ($omember) = $type->find_members_by_role('#ORDER');
  if ($omember) {
    return ($omember->get_name);
  }
  return undef; # we want this undef
}

*getRootNode = *root;
*getParentNode = *parent;
*getNextSibling = *rbrother;
*getPreviousSibling = *lbrother;
*getChildNodes = sub { wantarray ? $_[0]->children : [ $_[0]->children ] };

sub getElementById { }
sub isElementNode { 1 }
sub get_global_pos { 0 }
sub getNamespaces { return wantarray ? () : []; }
sub isTextNode { 0 }
sub isPINode { 0 }
sub isCommentNode { 0 }
sub getNamespace { undef }
sub getValue { undef }
sub getName { "node" }
*getLocalName = *getName;
*string_value = *getValue;

sub getAttributes {
  my ($self) = @_;
  my @attribs = map { 
    FSAttribute->new($self,$_,$self->{$_})
  } keys %$self;
  return wantarray ? @attribs : \@attribs;
}

sub find {
    my ($node,$path) = @_;
    require XML::XPath;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new(); # new is v. lightweight
    return $xp->find($path, $node);
}

sub findvalue {
    my ($node,$path) = @_;
    require XML::XPath;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return $xp->findvalue($path, $node);
}

sub findnodes {
    my ($node,$path) = @_;
    require XML::XPath;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return $xp->findnodes($path, $node);
}

sub matches {
    my ($node,$path,$context) = @_;
    require XML::XPath;
    local $_; # XML::XPath isn't $_-safe
    my $xp = XML::XPath->new();
    return $xp->matches($node, $path, $context);
}

package FSAttribute;
use Carp;

sub new { # node, name, value
  my $class = shift;
  return bless [@_],$class;
}

sub getElementById { $_[0]->getElementById($_[1]) }
sub getLocalName { $_[0][1] }
*getName = *getLocalName;
sub string_value { $_[0][2] }
*getValue = *string_value;

sub getRootNode { $_[0][0]->getRootNode() }
sub getParentNode { $_[0][0] }
sub getNamespace { undef }


=pod

=back

=cut


############################################################
#
# FS File
# =========
#
#

package FSFile;
use Carp;
use strict;

=head2 FSFile

FSFile - Fslib class representing a document consisting of a set of trees.

=over 4

=cut


=item FSFile->newFSFile (filename,encoding?,\@backends)

This constructor creates a new FSFile object based on the content of a
given file. See C<readFile()> method for details on the use of the
C<@backends> argument.

In perl ver. >= 5.8, you may optionaly specify file character encoding
as the second argument (this information is used by some text-based
I/O backends).

=cut

sub newFSFile {
  my ($self,$filename) = (shift,shift);
  my $new=$self->new();
  # the second arg may/may not be encoding string
  $new->changeEncoding(shift) unless ref($_[0]);
  $Fslib::FSError=$new->readFile($filename,@_);
  return $new;
}

=pod

=item FSFile->new (name?, file_format?, FS?, hint_pattern?, attribs_patterns?, unparsed_tail?, trees?, save_status?, backend?, encoding?, user_data?, meta_data?, app_data?)

Creates and returns a new FS file object based on the given values
(optional). For use with arguments, it is more convenient to use the
method C<create()> instead.

=cut

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = [];
  bless $new, $class;
  $new->initialize(@_);
  return $new;
}

=pod

=item FSFile->create({ argument => value, ... })

Creates and returns a new FS file object based on the given values.
This method accepts argument => value pairs as arguments. The
following arguments are available:

name, format, FS, hint, patterns, tail, trees, save_status, backend

See C<initialize> for more detail.

=cut

sub create {
  my $self = shift;
  my $args = (@_==1 and ref($_[0])) ? $_[0] : { @_ };
  return $self->new(@{$args}{qw(name format FS hint patterns tail trees save_status backend encoding user_data meta_data app_data)});
}


=item $fsfile->clone ($clone_trees)

Create a new FSFile object with the same file name, file format,
FSFormat, backend, encoding, patterns, hint and tail as the current
FSFile. If $clone_trees is true, populate the new FSFile object with
clones of all trees from the current FSFile.

=cut

sub clone {
  my ($self, $deep)=@_;
  my $fs=$self->FS;
  my $new = FSFile->create(
			   name => $self->filename,
			   format => $self->fileFormat,
			   FS => $fs->clone,
			   trees => [],
			   backend => $self->backend,
			   encoding => $self->encoding,
			   hint => $self->hint,
			   patterns => [ $self->patterns() ],
			   tail => $self->tail
			  );
  # clone metadata
  if (ref($self->[13])) {
    $new->[13] = Fslib::CloneValue($self->[13]);
  }
  if ($deep) {
    @{$new->treeList} = map { $fs->clone_subtree($_) } $self->trees();
  }
  return $new;
}

sub DESTROY {
  my ($self) = @_;
  return unless ref($self);
  $self->[9]=undef;
  $self->[12]=undef;
  foreach ($self->trees) {
    Fslib::DeleteTree($_);
  }
  $self->[0]=undef;
  $self->[1]=undef;
  $self->[2]=undef;
  $self->[3]=undef;
  $self->[4]=undef;
  $self->[5]=undef;
  $self->[6]=undef;
  $self->[7]=undef;
  $self->[8]=undef;
  $self->[9]=undef;
  $self->[10]=undef;
  $self->[11]=undef;
}

=pod

=item $fsfile->initialize (name?, file_format?, FS?, hint_pattern?, attribs_patterns?, unparsed_tail?, trees?, save_status?, backend?, encoding?, user_data?, meta_data?, app_data?)

Initialize a FS file object. Argument description:

=over 4

=item name (scalar)

File name

=item file_format (scalar)

File format identifier (user-defined string). TrEd, for example, uses
C<FS format>, C<gzipped FS format> and C<any non-specific format> strings as identifiers.

=item FS (FSFormat)

FSFormat object associated with the file

=item hint_pattern (scalar)

hint pattern definition (used by TrEd)

=item attribs_patterns (list reference)

embedded stylesheet patterns (used by TrEd)

=item unparsed_tail (list reference)

The rest of the file, which is not parsed by Fslib, i.e. Graph's embedded macros

=item trees (list reference)

List of FSNode objects representing root nodes of all trees in the FSFile.

=item save_status (scalar)

File save status indicator, 0=file is saved, 1=file is not saved (TrEd
uses this field).

=item backend (scalar)

IO Backend used to open/save the file.

=item encoding (scalar)

IO character encoding for perl 5.8 I/O filters

=item user_data (arbitrary scalar type)

Reserved for the user. Content of this slot is not persistent.

=item meta_data (hashref)

Meta data (usually used by IO Backends to store additional information
about the file - i.e. other than encoding, trees, patterns, etc).

=item app_data (hashref)

Non-persistent application specific data associated with the file (by
default this is an empty hash reference). Applications may store
temporary data associated with the file into this hash.

=back


=cut

sub initialize {
  my $self = shift;
  # what will we do here ?
  $self->[0] = $_[0];  # file name   (scalar)
  $self->[1] = $_[1];  # file format (scalar)
  $self->[2] = ref($_[2]) ? $_[2] : FSFormat->new(); # FS format (FSFormat object)
  $self->[3] = $_[3];  # hint pattern
  $self->[4] = ref($_[4]) eq 'ARRAY' ? $_[4] : []; # list of attribute patterns
  $self->[5] = ref($_[5]) eq 'ARRAY' ? $_[5] : []; # unparsed rest of a file
  $self->[6] = UNIVERSAL::isa($_[6],'ARRAY') ? Fslib::List->new_from_ref($_[6],1) : Fslib::List->new; # trees
  $self->[7] = $_[7] ? $_[7] : 0; # notsaved
  $self->[8] = undef; # storage for current tree number
  $self->[9] = undef; # storage fro current node
  $self->[10] = $_[8] ? $_[8] : 'FSBackend'; # backend;
  $self->[11] = $_[9] ? $_[9] : undef; # encoding;
  $self->[12] = $_[10] ? $_[10] : {}; # user data
  $self->[13] = $_[11] ? $_[11] : {}; # meta data
  $self->[14] = $_[12] ? $_[12] : {}; # app data
  return ref($self) ? $self : undef;
}

=pod

=item $fsfile->readFile ($filename, \@backends)

Read FS declaration and trees from a given file.  The first argument
must be a file-name. The second argument may be a list reference
consisting of names of I/O backends. If no backends are given, only
the FSBackend is used. For each I/O backend, C<readFile> tries to
execute the C<test> function from the appropriate class in the order
in which the backends were specified, passing it the filename as an
argument. The first I/O backend whose C<test()> function returns 1 is
then used to read the file.

Note: this function sets noSaved to zero.

Return values:
   0 - succes
   1 - no suitable backend
  -1 - backend failed

=cut

sub readFile {
  my ($self,$url) = (shift,shift);
  my @backends = UNIVERSAL::isa($_[0],'ARRAY') ? 
    @{$_[0]} : scalar(@_) ? @_ : qw(FSBackend);
  my $ret = 1;
  croak("readFile is not a class method") unless ref($self);
  $url =~ s/^\s*|\s*$//g;
  my ($file,$remove_file) = eval { IOBackend::fetch_file($url) };
  print STDERR "Actual file: $file\n" if $Fslib::Debug;
  return -1 if $@;
  foreach my $backend (@backends) {
    print STDERR "Trying backend $backend: " if $Fslib::Debug;
    if (eval {
 	  no strict 'refs';
	  $backend->can('test')
	  && $backend->can('read')
	  && $backend->can('open_backend')
	  && &{"${backend}::test"}($file,$self->encoding);
	}) {
      $self->changeBackend($backend);
      $self->changeFilename($url);
      print STDERR "success\n" if $Fslib::Debug;
      eval {
	no strict 'refs';
	my $fh;
	print STDERR "calling ${backend}::open_backend\n" if $Fslib::Debug;
	$fh = &{"${backend}::open_backend"}($file,"r",$self->encoding);
	&{"${backend}::read"}($fh,$self);
	&{"${backend}::close_backend"}($fh) || warn "Close failed.\n";
      };
      if ($@) {
	print STDERR "Error occured while reading '$file' using backend ${backend}:\n";
	my $err = $@; chomp $err;
	print STDERR "$err\n";
	$ret = -1;
      } else {
	$ret = 0;
      }
      $self->notSaved(0);
      last;
    }
    print STDERR "fail\n" if $Fslib::Debug;
#     eval {
#       no strict 'refs';
#       print STDERR "TEST",$backend->can('test'),"\n";
#       print STDERR "READ",$backend->can('read'),"\n";
#       print STDERR "OPEN",$backend->can('open_backend'),"\n";
#       print STDERR "REAL_TEST($file): ",&{"${backend}::test"}($file,$self->encoding),"\n";
#     } if $Fslib::Debug;
    if ($@) {
      my $err = $@; chomp $err;
      print STDERR "$err\n";
    }
  }
  if ($ret == 1) {
    my $err = "Unknown file type (all IO backends failed): $file\n";
    $@.="\n".$err;
  }
  if ($url ne $file and $remove_file) {
    local $!;
    unlink $file || warn "couldn't unlink tmp file $file: $!\n";
  }
  return $ret;
}

=pod

=item $fsfile->readFrom (glob_ref, [backends...])

Read FS declaration and trees from a given file (file handle open for
reading must be passed as a GLOB reference).
This function is limited to use FSBackend only.
Sets noSaved to zero.

=cut

sub readFrom {
  my ($self,$fileref) = @_;
  return unless ref($self);

  my $ret=FSBackend::read($fileref,$self);
  $self->notSaved(0);
  return $ret;
}

=pod

=item $fsfile->writeFile (filename)

Write FS declaration, trees and unparsed tail to a given file. Sets
noSaved to zero.

=cut

sub writeFile {
  my ($self,$filename) = @_;
  return unless ref($self);

  $filename = $self->filename unless (defined($filename) and $filename ne "");
  my $backend=$self->backend || 'FSBackend';
  print STDERR "Writing to $filename using backend $backend\n" if $Fslib::Debug;
  my $ret;
  #eval {
  no strict 'refs';
  my $fh;
  $backend->can('write') || die "Backend $backend is not loaded or does not support writing\n";
  $backend->can('open_backend') || die "Backend $backend does not support open\n";
  ($fh=&{"${backend}::open_backend"}($filename,"w",$self->encoding)) || die "Open failed on '$filename' using backend $backend\n";
  $ret=&{"${backend}::write"}($fh,$self) || die "Write to '$filename' failed using backend $backend\n";
  &{"${backend}::close_backend"}($fh) || die "Closing file '$filename' failed using backend $backend\n";
  #};
  #if ($@) {
  #  print STDERR "Error: $@\n";
  #  return 0;
  #}
  $self->notSaved(0) if $ret;
  return $ret;
}


=item $fsfile->writeTo (glob_ref)

Write FS declaration, trees and unparsed tail to a given file (file handle open for
reading must be passed as a GLOB reference). Sets noSaved to zero.

=cut

sub writeTo {
  my ($self,$fileref) = @_;
  return unless ref($self);

  my $backend=$self->backend || 'FSBackend';
  print STDERR "Writing using backend $backend\n" if $Fslib::Debug;
  my $ret;
  eval {
    no strict 'refs';
#    require $backend;
    $ret=$backend->can('write')  && &{"${backend}::write"}($fileref,$self);
  };
  print STDERR "$@\n" if $@;
  return $ret;
}

=pod

=item $fsfile->filename

Return the FS file's file name.

=cut


sub filename {
  my ($self) = @_;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item $fsfile->changeFilename (new_filename)

Change the FS file's file name.

=cut


sub changeFilename {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[0]=$val;
}

=pod

=item $fsfile->fileFormat

Return file format identifier (user-defined string). TrEd, for
example, uses C<FS format>, C<gzipped FS format> and C<any
non-specific format> strings as identifiers.

=cut

sub fileFormat {
  my ($self) = @_;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item $fsfile->changeFileFormat (string)

Change file format identifier.

=cut

sub changeFileFormat {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[1]=$val;
}

=pod

=item $fsfile->backend

Return IO backend module name. The default backend is FSBackend, used
to save files in the FS format.

=cut

sub backend {
  my ($self) = @_;
  return ref($self) ? $self->[10] : undef;
}

=pod

=item $fsfile->changeBackend (string)

Change file backend.

=cut

sub changeBackend {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[10]=$val;
}

=pod

=item $fsfile->encoding

Return file character encoding (used by Perl 5.8 input/output filters).

=cut

sub encoding {
  my ($self) = @_;
  return ref($self) ? $self->[11] : undef;
}

=pod

=item $fsfile->changeEncoding (string)

Change file character encoding (used by Perl 5.8 input/output filters).

=cut

sub changeEncoding {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[11]=$val;
}


=pod

=item $fsfile->userData

Return user data associated with the file (by default this is an empty
hash reference). User data are not supposed to be persistent and IO
backends should ignore it.

=cut

sub userData {
  my ($self) = @_;
  return ref($self) ? $self->[12] : undef;
}

=pod

=item $fsfile->changeUserData (value)

Change user data associated with the file. User data are not supposed
to be persistent and IO backends should ignore it.

=cut

sub changeUserData {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[12]=$val;
}

=pod

=item $fsfile->metaData (name)

Return meta data stored into the object usually by IO backends. Meta
data are supposed to be persistent, i.e. they are saved together with
the file (at least by some IO backends).

=cut

sub metaData {
  my ($self,$name) = @_;
  return ref($self) ? $self->[13]->{$name} : undef;
}

=pod

=item $fsfile->changeMetaData (name,value)

Change meta information (usually used by IO backends). Meta data are
supposed to be persistent, i.e. they are saved together with the file
(at least by some IO backends).

=cut

sub changeMetaData {
  my ($self,$name,$val) = @_;
  return unless ref($self);
  return $self->[13]->{$name}=$val;
}

=item $fsfile->listMetaData (name)

In array context, return the list of metaData keys. In scalar context
return the hash reference where metaData are stored.

=cut

sub listMetaData {
  my ($self) = @_;
  return unless ref($self);
  return wantarray ? keys(%{$self->[13]}) : $self->[13];
}

=item $fsfile->appData (name)

Return application specific information associated with the
file. Application data are not persistent, i.e. they are not saved
together with the file by IO backends.

=cut

sub appData {
  my ($self,$name) = @_;
  return ref($self) ? $self->[14]->{$name} : undef;
}

=pod

=item $fsfile->changeAppData (name,value)

Change application specific information associated with the
file. Application data are not persistent, i.e. they are not saved
together with the file by IO backends.

=cut

sub changeAppData {
  my ($self,$name,$val) = @_;
  return unless ref($self);
  return $self->[14]->{$name}=$val;
}

=item $fsfile->listAppData (name)

In array context, return the list of appData keys. In scalar context
return the hash reference where appData are stored.

=cut

sub listAppData {
  my ($self) = @_;
  return unless ref($self);
  return wantarray ? keys(%{$self->[14]}) : $self->[13];
}

=pod

=item $fsfile->FS

Return a reference to the associated FSFormat object.

=cut

sub FS {
  my ($self) = @_;
  return ref($self) ? $self->[2] : undef;
}

=pod

=item $fsfile->changeFS (FSFormat_object)

Associate FS file with a new FSFormat object.

=cut

sub changeFS {
  my ($self,$val) = @_;
  return unless ref($self);
  $self->[2]=$val;
  
  my $enc = $val->special('E');
  if ($enc) {
    $self->changeEncoding($enc);
    delete $val->specials->{E};
  }
  return $self->[2];
}

=pod

=item $fsfile->hint

Return the Tred's hint pattern declared in the FSFile.

=cut


sub hint {
  my ($self) = @_;
  return ref($self) ? $self->[3] : undef;
}

=pod

=item $fsfile->changeHint (string)

Change the Tred's hint pattern associated with this FSFile.

=cut


sub changeHint {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[3]=$val;
}

=pod

=item $fsfile->pattern_count

Return the number of display attribute patterns associated with this FSFile.

=cut

sub pattern_count {
  my ($self) = @_;
  return ref($self) ? scalar(@{ $self->[4] }) : undef;
}

=item $fsfile->pattern (n)

Return n'th the display pattern associated with this FSFile.

=cut


sub pattern {
  my ($self,$index) = @_;
  return ref($self) ? $self->[4]->[$index] : undef;
}

=item $fsfile->patterns

Return a list of display attribute patterns associated with this FSFile.

=cut

sub patterns {
  my ($self) = @_;
  return ref($self) ? @{$self->[4]} : undef;
}

=pod

=item $fsfile->changePatterns (list)

Change the list of display attribute patterns associated with this FSFile.

=cut

sub changePatterns {
  my $self = shift;
  return unless ref($self);
  return @{$self->[4]}=@_;
}

=pod

=item $fsfile->tail

Return the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut


sub tail {
  my ($self) = @_;
  return ref($self) ? @{$self->[5]} : undef;
}

=pod

=item $fsfile->changeTail (list)

Modify the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut


sub changeTail {
  my $self = shift;
  return unless ref($self);
  return @{$self->[5]}=@_;
}

=pod

=item $fsfile->trees

Return a list of all trees (i.e. their roots represented by FSNode objects).

=cut

## Two methods to work with trees (for convenience)
sub trees {
  my ($self) = @_;
  return ref($self) ? @{$self->treeList} : undef;
}

=pod

=item $fsfile->changeTrees (list)

Assign a new list of trees.

=cut

sub changeTrees {
  my $self = shift;
  return unless ref($self);
  return @{$self->treeList}=@_;
}

=pod

=item $fsfile->treeList

Return a reference to the internal array of all trees (e.g. their
roots represented by FSNode objects).

=cut

# returns a reference!!!
sub treeList {
  my ($self) = @_;
  return ref($self) ? $self->[6] : undef;
}

=pod

=item $fsfile->tree (n)

Return a reference to the tree number n.

=cut

# returns a reference!!!
sub tree {
  my ($self,$n) = @_;
  return ref($self) ? $self->[6]->[$n] : undef;
}


=pod

=item $fsfile->lastTreeNo

Return number of associated trees minus one.

=cut

sub lastTreeNo {
  my ($self) = @_;
  return ref($self) ? $#{$self->treeList} : undef;
}

=pod

=item $fsfile->notSaved (value?)

Return/assign file saving status (this is completely user-driven).

=cut

sub notSaved {
  my ($self,$val) = @_;

  return unless ref($self);
  return $self->[7]=$val if (defined $val);
  return $self->[7];
}

=item $fsfile->currentTreeNo (value?)

Return/assign index of current tree (this is completely user-driven).

=cut

sub currentTreeNo {
  my ($self,$val) = @_;

  return unless ref($self);
  return $self->[8]=$val if (defined $val);
  return $self->[8];
}

=item $fsfile->currentNode (value?)

Return/assign current node (this is completely user-driven).

=cut

sub currentNode {
  my ($self,$val) = @_;

  return unless ref($self);
  return $self->[9]=$val if (defined $val);
  return $self->[9];
}

=pod

=item $fsfile->nodes (tree_no, prev_current, include_hidden)

Get list of nodes for given tree. Returns two value list
($nodes,$current), where $nodes is a reference to a list of nodes for
the tree and current is either root of the tree or the same node as
prev_current if prev_current belongs to the tree. The list is sorted
according to the ordering attribute (obtained from FS->order) and
inclusion of hidden nodes depends on the boolean value of
include_hidden.

=cut

sub nodes {
# prepare value line and node list with deleted/saved hidden
# and ordered by real Ord

  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  my $nodes=[];
  return $nodes unless ref($fsfile);

  my @unsorted=();
  $tree_no=0 if ($tree_no<0);
  $tree_no=$fsfile->lastTreeNo() if ($tree_no>$fsfile->lastTreeNo());

  my $root=$fsfile->treeList->[$tree_no];
  my $node=$root;
  my $current=$root;

  while($node)
  {
    push @unsorted, $node;
    $current=$node if ($prevcurrent eq $node);
    $node=$show_hidden ? $node->following() : $node->following_visible($fsfile->FS);
  }

  my $attr=$fsfile->FS->order();
  # schwartzian transform
  @{$nodes} = 
    map { $_->[0] }
    sort { $a->[1] <=> $b->[1] }
    map { [$_, $_->get_member($attr) ] } @unsorted;

  # just for sure
  undef @unsorted;
  # this is actually a workaround for TR, where two different nodes
  # may have the same Ord
  return ($nodes,$current);
}

=pod

=item $fsfile->value_line (tree_no, no_tree_numbers?)

Return a sentence string for the given tree. Sentence string is a
string of chained value attributes (FS->value) ordered according to
the FS->sentord or FS->order if FS->sentord attribute is not defined.

Unless no_tree_numbers is non-zero, prepend the resulting string with
a "tree number/tree count: " prefix.

=cut

sub value_line {
  my ($fsfile,$tree_no,$no_numbers)=@_;
  return unless $fsfile;

  return ($no_numbers ? "" : ($tree_no+1)."/".($fsfile->lastTreeNo+1).": ").
    join(" ",$fsfile->value_line_list($tree_no));
}

=item $fsfile->value_line_list (tree_no)

Return a list of value (FS->value) attributes for the given tree
ordered according to the FS->sentord or FS->order if FS->sentord
attribute is not defined.

=cut

sub value_line_list {
  my ($fsfile,$tree_no,$no_numbers,$wantnodes)=@_;
  return unless $fsfile;

  my $node=$fsfile->treeList->[$tree_no];
  my @sent=();

  my $sentord=$fsfile->FS->sentord();
  my $val=$fsfile->FS->value();
  $sentord=$fsfile->FS->order() unless (defined($sentord));

  # if PML schemas are in use and one of the attributes
  # is an attr-path, we have to use $node->attr(...) instead of $node->{...}
  # (otherwise we optimize and use hash keys).
  if (($val=~m{/} or $sentord=~m{/}) and ref($fsfile->metaData('schema'))) {
    while ($node) {
      my $value = $node->attr($val);
      push @sent,$node
	unless ($value eq '' or
		$value eq '???' or
		$node->attr($sentord)>=999); # this is a PDT-TR specific hack
      $node=$node->following();
    }
    @sent = sort { $a->attr($sentord) <=> $b->attr($sentord) } @sent;
    if ($wantnodes) {
      return (map { [$_->attr($val),$_] } @sent);
    } else {
      return (map { $_->attr($val) } @sent);
    }
  } else {
    while ($node) {
      push @sent,$node 
	unless ($node->{$val} eq '' or
		$node->{$val} eq '???' or
		$node->{$sentord}>=999); # this is a PDT-TR specific hack
      $node=$node->following();
    }
    @sent = sort { $a->{$sentord} <=> $b->{$sentord} } @sent;
    if ($wantnodes) {
      return (map { [$_->{$val},$_] } @sent);
    } else {
      return (map { $_->{$val} } @sent);
    }
  }
}


=pod

=item $fsfile->insert_tree (root,position)

Insert new tree at given position.

=cut

sub insert_tree {
  my ($self,$nr,$pos)=@_;
  splice(@{$self->treeList}, $pos, 0, $nr) if $nr;
  return $nr;
}

=pod

=item $fsfile->set_tree (root,pos)

Set tree at given position.

=cut

sub set_tree {
  my ($self,$nr,$pos)=@_;
  $self->treeList->[$pos]=$nr;
  return $nr;
}


=pod

=item $fsfile->new_tree (position)

Create a new tree at given position and return pointer to its root.

=cut

sub new_tree {
  my ($self,$pos)=@_;

  my $nr=FSNode->new(); # creating new root
  $self->insert_tree($nr,$pos);
  return $nr;

}

=item $fsfile->delete_tree (position)

Delete the tree at given position and return pointer to its root.

=cut

sub delete_tree {
  my ($self,$pos)=@_;
  my ($root)=splice(@{$self->treeList}, $pos, 1);
  return $root;
}

=item $fsfile->destroy_tree (position)

Delete the tree at given position and return pointer to its root.

=cut

sub destroy_tree {
  my ($self,$pos)=@_;
  my $root=$self->delete_tree($pos);
  return 0 unless $root;
  Fslib::DeleteTree($root);
  return 1;
}


=pod

=back

=cut

############################################################
#
# FS Format
# =========
#
#

package FSFormat;
use Carp;
use strict;
use vars qw(%Specials $AUTOLOAD $special);

=head2 FSFormat

FSFormat - Fslib class representing file header of a FSFile.

=over 4

=cut

%Specials = (sentord => 'W', order => 'N', value => 'V', hide => 'H');
$special=" _SPEC";

=pod

=item FSFormat->create (@header)

Create a new FS format instance object by parsing each of the parameters
passed as one FS header line.

=cut

sub create {
  my $self = shift;
  my @header=@_;
  my $new=$self->new();
  $new->readFrom(\@header);
  return $new;
}


=item FSFormat->new (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

Create a new FS format instance object and C<initialize> it with the
optional values.

=cut

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = [];
  bless $new, $class;
  $new->initialize(@_);
  return $new;
}

=pod

=item $format->clone

Duplicate FS format instance object.

=cut

sub clone {
  my ($self) = @_;
  return unless ref($self);
  return $self->new(
		    {%{$self->defs()}},
		    [$self->attributes()],
		    [@{$self->unparsed()}]
		   );
}


=pod

=item $format->initialize (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

Initialize a new FS format instance with given values. See L<"Fslib">
for more information about attribute hash, ordered names list and unparsed headers.

=cut

sub initialize {
  my $self = $_[0];
  return unless ref($self);

  $self->[0] = ref($_[1]) ? $_[1] : { }; # attribs  (hash)
  $self->[1] = ref($_[2]) ? $_[2] : [ ]; # atord    (sorted array)
  $self->[2] = ref($_[3]) ? $_[3] : [ ]; # unparsed (sorted array)
  return $self;
}

=pod

=item $format->addNewAttribute (type, colour, name, list)

Adds a new attribute definition to the FSFormat. Type must be one of
the letters [KPOVNWLH], colour one of characters [A-Z0-9]. If the type
is L, the fourth parameter is a string containing a list of possible
values separated by |.

=cut

sub addNewAttribute {
  my ($self,$type,$color,$name,$list)=@_;
  $self->list->[$self->count()]=$name if (!defined($self->defs->{$name}));
  if (index($Fslib::SpecialTypes, $type)+1) {
    $self->specials->{$type}=$name;
  }
  if ($list) {
    $self->defs->{$name}.=" $type=$list"; # so we create a list of defchars separated by spaces
  } else {                 # a value-list may follow the equation mark
    $self->defs->{$name}.=" $type";
  }
  if ($color) {
    $self->defs->{$name}.=" $color"; # we add a special defchar for color
  }
}

=pod

=item $format->readFrom (source,output?)

Reads FS format instance definition from given source, optionally
echoing the unparsed input on the given output. The obligatory
argument C<source> must be either a GLOB or list reference.
Argument C<output> is optional and if given, it must be a GLOB reference.

=cut

sub readFrom {
  my ($self,$handle,$out) = @_;
  return unless ref($self);

  my %result;
  my $count=0;
  local $_;
  while ($_=Fslib::ReadEscapedLine($handle)) {
    s/\r$//o;
    if (ref($out)) {
      print $out $_;
    } else {
      push @{$self->unparsed}, $_;
    }
    if (/^\@([KPOVNWLHE])([A-Z0-9])* (${Fslib::attr_name_re})(?:\|(.*))?/o) {
      if ($1 eq 'E') {
	$self->defs->{$special}->{E}=$3;
	if (ref($handle) ne 'ARRAY') {
	  binmode $handle;
	  binmode $handle, ':encoding('.$3.')';
	}
	next;
      }
      if (index($Fslib::SpecialTypes, $1)+1) {
	$self->defs->{$special}->{$1}=$3;
      }
      $self->list->[$count++]=$3 if (!defined($self->defs->{$3}));
      if ($4) {
	$self->defs->{$3}.=" $1=$4"; # so we create a list of defchars separated by spaces
      } else {                 # a value-list may follow the equation mark
	$self->defs->{$3}.=" $1";
      }
      if ($2) {
	$self->defs->{$3}.=" $2"; # we add a special defchar for color
      }
      next;
    } elsif (/^\r*$/o) {
      last;
    } else {
      return 0;
    }
  }
  return 1;
}

=item $format->toArray

Return FS declaration as an array of FS header declarations.

=cut

sub toArray {
  my ($self) = @_;
  return unless ref($self);
  my $defs = $self->defs;
  my @ad;
  my @result;
  my $l;
  my $vals;
  foreach (@{$self->list}) {
    @ad=split ' ',$defs->{$_};
    while (@ad) {
      $l='@';
      if ($ad[0]=~/^L=(.*)/) {
	$vals=$1;
	shift @ad;
	$l.="L";
	$l.=shift @ad if ($ad[0]=~/^[A0-3]/);
	$l.=" $_|$vals\n";
      } else {
	$l.=shift @ad;
	$l.=shift @ad if ($ad[0]=~/^[A0-3]/);
	$l.=" $_\n";
      }
      push @result, $l;
    }
  }
  push @result,"\n";
  return @result;
}

=item $format->writeTo (glob_ref)

Write FS declaration to a given file (file handle open for
reading must be passed as a GLOB reference).

=cut

sub writeTo {
  my ($self,$fileref) = @_;
  return unless ref($self);
  print $fileref $self->toArray;
  return 1;
}


=pod

=item $format->sentord (), order(), value(), hide()

Return names of special attributes declared in FS format as @W, @N,
@V, @H respectively.

=cut

{
  my ($sub, $key);
  while (($sub,$key)= each %FSFormat::Specials) {
    eval "sub $sub { \$_[0]->specials->{$key}; }";
  }
}

# sub AUTOLOAD {
#   my ($self)=@_;
#   return unless ref($self);
#   my $sub = $AUTOLOAD;
#   $sub =~ s/.*:://;
#   if (exists($FSFormat::Specials{$sub})) {
#     return $self->specials->{ $FSFormat::Specials{$sub} };
#   } else {
#     return;
#   }
# }

sub DESTROY {
  my ($self) = @_;
  return unless ref($self);
  $self->[0]=undef;
  $self->[1]=undef;
  $self->[2]=undef;
  $self=undef;
}

=pod

=item $format->isHidden (node)

Return the lowest ancestor-or-self of the given node whose value of
the FS attribute declared as @H is either C<'hide'> or 1. Return
undef, if no such node exists.

=cut

sub isHidden {
  # Tests if given FSNode node is hidden or not
  # Returns the ancesor that hides it or undef
  my ($self,$node)=@_;
  return unless ref($self) and ref($node);
  my $hid=$self->specials->{H};
  return unless defined $hid;
  while (ref($node) && ($node->{$hid} != 1 and
			$node->{$hid} ne 'hide')) {
    $node=$node->parent;
  }
  return ($node ? $node : undef);
}

=pod

=item $format->defs

Return a reference to the internally stored attribute hash.

=cut

sub defs {
  my ($self) = @_;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item $format->list

Return a reference to the internally stored attribute names list.

=cut

sub list {
  my ($self) = @_;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item $format->unparsed

Return a reference to the internally stored unparsed FS header. Note,
that this header must B<not> correspond to the defs and attributes if
any changes are made to the definitions or names at run-time by hand.

=cut

sub unparsed {
  my ($self) = @_;
  return ref($self) ? $self->[2] : undef;
}


=pod

=item $format->renew_specials

Refresh special attribute hash.

=cut

sub renew_specials {
  my ($self)=@_;
  my $defs = $self->defs;
  delete $defs->{$special};
  $defs->{$special} = { map { $_ => $self->findSpecialDef($_) } split '',$Fslib::SpecialTypes };
}

sub findSpecialDef {
  my ($self,$defchar)=@_;
  my $defs = $self->defs;
  foreach (keys %{$defs}) {
    return $_ if (index($defs->{$_}," $defchar")>=0);
  }
  return undef; # we want an explicit undef here!!
}

=item $format->specials

Return a reference to a hash of attributes of special types. Keys
of the hash are special attribute types and values are their names.

=cut

sub specials {
  my ($self) = @_;
  return unless ref($self);
  unless (ref($self->[0]->{$special})) {
    $self->renew_specials();
  }
  return $self->[0]->{$special};
}

=pod

=item $format->attributes

Return a list of all attribute names (in the order given by FS
instance declaration).

=cut

sub attributes {
  my ($self) = @_;
  return ref($self) ? @{$self->list} : ();
}

=pod

=item $format->atno (n)

Return the n'th attribute name (in the order given by FS
instance declaration).

=cut


sub atno {
  my ($self,$index) = @_;
  return ref($self) ? $self->list->[$index] : undef;
}

=pod

=item $format->atno (attribute_name)

Return the definition string for the given attribute.

=cut

sub atdef {
  my ($self,$name) = @_;
  return ref($self) ? $self->defs->{$name} : undef;
}

=pod

=item $format->count

Return the number of declared attributes.

=cut

sub count {
  my ($self) = @_;
  return ref($self) ? $#{$self->list}+1 : undef;
}

=pod

=item $format->isList (attribute_name)

Return true if given attribute is assigned a list of all possible
values.

=cut

sub isList {
  my ($self,$attrib)=@_;
  return (index($self->defs->{$attrib}," L")>=0) ? 1 : 0;
}

=pod

=item $format->listValues (attribute_name)

Return the list of all possible values for the given attribute.

=cut

sub listValues {
  my ($self,$attrib)=@_;
  return unless ref($self);

  my $defs = $self->defs;
  my ($I,$b,$e);
  $b=index($defs->{$attrib}," L=");
  if ($b>=0) {
    $e=index($defs->{$attrib}," ",$b+1);
    if ($e>=0) {
      return split /\|/,substr($defs->{$attrib},$b+3,$e-$b-3);
    } else {
      return split /\|/,substr($defs->{$attrib},$b+3);
    }
  } else { return (); }
}

=pod

=item $format->color (attribute_name)

Return one of C<Shadow>, C<Hilite> and C<XHilite> depending on the
color assigned to the given attribute in the FS format instance.

=cut

sub color {
  my ($self,$arg) = @_;
  return unless ref($self);

  if (index($self->defs->{$arg}," 1")>=0) {
    return "Shadow";
  } elsif (index($self->defs->{$arg}," 2")>=0) {
    return "Hilite";
  } elsif (index($self->defs->{$arg}," 3")>=0) {
    return "XHilite";
  } else {
    return "normal";
  }
}

=pod

=item $format->special (letter)

Return name of a special attribute declared in FS definition with a
given letter. See also sentord() and similar.

=cut

sub special {
  my ($self,$defchar)=@_;
  return
    ref($self) ? $self->specials->{$defchar} : undef;
}

=pod

=item $format->indexOf (attribute_name)

Return index of the given attribute (in the order given by FS
instance declaration).

=cut

sub indexOf {
  my ($self,$arg)=@_;
  return
    ref($self) ? Fslib::Index($self->list,$arg) : undef;
}

=item $format->exists (attribute_name)

Return true if an attribute of the given name exists.

=cut

sub exists {
  my ($self,$arg)=@_;
  return
    ref($self) ?
      (exists($self->defs->{$arg}) &&
       defined($self->defs->{$arg})) : undef;
}


=pod

=item $format->make_sentence (root_node,separator)

Return a string containing the content of value (special) attributes
of the nodes of the given tree, separated by separator string, sorted by
value of the (special) attribute sentord or (if sentord does not exist) by
(special) attribute order.

=cut

sub make_sentence {
  my ($self,$root,$separator)=@_;
  return unless ref($self);
  $separator=' ' unless defined($separator);
  my @nodes=();
  my $sentord = $self->sentord || $self->order;
  my $value = $self->value;
  my $node=$root;
  while ($node) {
    push @nodes,$node;
    $node=$node->following($root);
  }
  return join ($separator,
	       map { $_->getAttribute($value) }
	       sort { $a->getAttribute($sentord) <=> $b->getAttribute($sentord) } @nodes);
}


=pod

=item $format->clone_node

Create a copy of the given node.

=cut

sub clone_node {
  my ($self,$node)=@_;
  my $new = FSNode->new();
  if ($node->type) {
    foreach my $atr ($node->type->get_normal_fields) {
      if (ref($node->{$atr})) {
	$new->{$atr} = Fslib::CloneValue($node->{$atr});
      } else {
	$new->{$atr} = $node->{$atr};
      }
    }
    $new->set_type($node->type);
  } else {
    foreach (@{$self->list}) {
      $new->{$_}=$node->{$_};
    }
  }
  return $new;
}

=item $format->clone_subtree

Create a deep copy of the given subtree.

=cut

sub clone_subtree {
  my ($self,$node)=@_;
  my $nc;
  return 0 unless $node;
  my $prev_nc=0;
  my $nd=$self->clone_node($node);
  foreach ($node->children()) {
    $nc=$self->clone_subtree($_);
    $nc->set_parent($nd);
    if ($prev_nc) {
      $nc->set_lbrother($prev_nc);
      $prev_nc->set_rbrother($nc);
    } else {
      $nd->set_firstson($nc);
    }
    $prev_nc=$nc;
  }
  return $nd;
}


=pod

=back

=cut

############################################################
#
# FSBackend
# =========
#
#

package FSBackend;
use Carp;
use vars qw($CheckListValidity $emulatePML);
use strict;
use IOBackend qw(open_backend close_backend);
use Carp;

=pod

=head2 FSBackend

FSBackend - IO backend for reading/writing FS files using FSFile class.

Do not use this class directly.

=over 4

=item FSBackend::$emulatePML

This variable controls whether a simple PML schema should be created
for FS files (default is 1 - yes). Attribute whose name contains one
or more slashes is represented as a (possibly nested) structure where
each slash represents one level of nesting. Attributes sharing a
common name-part followed by a slash are represented as members of
the same structure. For example, attributes C<a>, C<b/u/x>, C<b/v/x> and
C<b/v/y> result in the following structure:

C<{a => value_of_a,
   b => { u => { x => value_of_a/u/x },
          v => { x => value_of_a/v/x,
                 y => value_of_a/v/y }
        }
  }>

In the PML schema emulation mode, it is forbidden to have both C<a>
and C<a/b> attributes. In such a case the parser reverts to
non-emulation mode.

=cut

$emulatePML=1;


=item FSBackend::test (filehandle | filename, encoding?)

Test if given filehandle or filename is in FSFormat. If the argument
is a file-handle the filehandle is supposed to be open by previous
call to C<open_backend>. In this case, the calling application may
need to close the handle and reopen it in order to seek the beginning
of the file after the test has read few characters or lines from it.

Optionally, in perl ver. >= 5.8, you may also specify file character
encoding.

=cut

sub test {
  my ($f,$encoding)=@_;
  if (ref($f) eq 'ARRAY') {
    return $f->[0]=~/^@/; 
  } elsif (ref($f)) {
    binmode $f unless UNIVERSAL::isa($f,'IO::Zlib');
    my $test = ($f->getline()=~/^@/);
    return $test;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}


sub _fs2members {
  my ($fs)=@_;
  my $mbr = {};
  my $defs = $fs->defs;
  # sort, so that possible short parts go first
  foreach my $attr (sort $fs->attributes) {
    my $m = $mbr;
    # check that no short attr exists
    my @parts = split /\//,$attr;
    my $short=$parts[0];
    for (my $i=1;$i<@parts;$i++) {
      if ($defs->{$short}) {
	warn "Can't emulate PML schema: attribute name conflict between $short and $attr: falling back to non-emulation mode\n";
      }
      $short .= '/'.$parts[$i];
    }
    for my $part (@parts) {
      $m->{structure}{member}{$part}{-name} = $part;
      $m=$m->{structure}{member}{$part};
    }
    # allow ``alt'' values concatenated with |
    if ($fs->isList($attr)) {
      $m->{alt} = {
	-flat => 1,
	choice => [ $fs->listValues($attr) ]
      };
    } else {
      $m->{alt} = {
	-flat => 1,
	cdata => { format =>'any' }
      };
    }
  }
  return $mbr->{structure}{member};
}

=item FSBackend::read (handle_ref,fsfile)

Read FS declaration and trees from a given file in FS format (file
handle open for reading must be passed as a GLOB reference).
Return 1 on success 0 on fail.

=cut

sub read {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);
  my $FS = FSFormat->new();
  $FS->readFrom($fileref) || return 0;
  $fsfile->changeFS( $FS );

  my $emu_schema_type;
  if ($emulatePML) {
    # fake a PML Schema:
    my $members = _fs2members($fsfile->FS);
    $members->{'#childnodes'}={
      role => '#CHILDNODES',
      list => {
	ordered => 1,
	type => 'fs-node.type',
      },
    };
    my $node_type = {
      name => 'fs-node',
      role => '#NODE',
      member => $members,
    };
    my $schema= Fslib::Schema->convert_from_hash({
      description => 'PML schema generated from FS header',
      root => { name => 'fs-data',
		structure => {
		  member => {
		    trees => {
		      -name => 'trees',
		      role => '#TREES',
		      required => 1,
		      list => {
			ordered => 1,
			type => 'fs-node.type'
		       }
		     }
		   }
		 }
	      },
      type => {
	'fs-node.type' => {
	  -name => 'fs-node.type',
	  structure => $node_type,
	}
      }
    });
    if (defined($node_type->{member})) {
      $emu_schema_type = $node_type;
      $fsfile->changeMetaData('schema',$schema);
    }
  }

  my ($root,$l,@rest);
  $fsfile->changeTrees();

  # this could give us some speedup.
  my $ordhash;
  {
    my $i = 0;
    $ordhash = { map { $_ => $i++ } $fsfile->FS->attributes };
  }

  while ($l=Fslib::ReadEscapedLine($fileref)) {
    if ($l=~/^\[/) {
      $root=ParseFSTree($fsfile->FS,$l,$ordhash,$emu_schema_type);
      push @{$fsfile->treeList}, $root if $root;
    } else { push @rest, $l; }
  }
  $fsfile->changeTail(@rest);

  #parse Rest
  my @patterns;
  foreach ($fsfile->tail) {
    if (/^\/\/Tred:Custom-Attribute:(.*\S)\s*$/) {
      push @patterns,$1;
    } elsif (/^\/\/Tred:Custom-AttributeCont:(.*\S)\s*$/) {
      $patterns[$#patterns].="\n".$1;
    } elsif (/^\/\/FS-REQUIRE:\s*(\S+)\s+(\S+)=\"([^\"]+)\"\s*$/) {
      my $requires = $fsfile->metaData('fs-require') || $fsfile->changeMetaData('fs-require',[]);
      push @$requires,[$2,$3];
      my $refnames = $fsfile->metaData('refnames') || $fsfile->changeMetaData('refnames',{});
      $refnames->{$1} = $2;
    }
  }
  $fsfile->changePatterns(@patterns);
  unless (@patterns) {
    my ($peep)=$fsfile->tail;
    $fsfile->changePatterns( map { "\$\{".$fsfile->FS->atno($_)."\}" } 
		    ($peep=~/[,\(]([0-9]+)/g));
  }
  $fsfile->changeHint(join "\n",
		    map { /^\/\/Tred:Balloon-Pattern:(.*\S)\s*$/ ? $1 : () } $fsfile->tail);
  return 1;
}

=pod

=item FSBackend::write (handle_ref,$fsfile)

Write FS declaration, trees and unparsed tail to a given file to a
given file in FS format (file handle open for reading must be passed
as a GLOB reference).

=cut

sub write {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

#  print $fileref @{$fsfile->FS->unparsed};
  print $fileref '@E '.$fsfile->encoding."\n";
  $fsfile->FS->writeTo($fileref);
  PrintFSFile($fileref,
	      $fsfile->FS,
	      $fsfile->treeList,
	      ref($fsfile->metaData('schema')) ? 1 : 0
	     );

  ## Tredish custom attributes:
  $fsfile->changeTail(
		    (grep { $_!~/\/\/Tred:(?:Custom-Attribute(?:Cont)?|Balloon-Pattern):/ } $fsfile->tail),
		    (map {"//Tred:Custom-Attribute:$_\n"}
		     map {
		       join "\n//Tred:Custom-AttributeCont:",
			 split /\n/,$_
		       } $fsfile->patterns),
		    (map {"//Tred:Balloon-Pattern:$_\n"}
		     split /\n/,$fsfile->hint),
		   );
  print $fileref $fsfile->tail;
  if (ref($fsfile->metaData('fs-require'))) {
    my $refnames = $fsfile->metaData('refnames') || {};
    foreach my $req ( @{ $fsfile->metaData('fs-require') } ) {
      my ($name) = grep { $refnames->{$_} eq $req->[0] } keys(%$refnames);
      print $fileref "//FS-REQUIRE:$name $req->[0]=\"$req->[1]\"\n";
    }
  }
  return 1;
}

sub Print ($$) {
  my (
      $output,			# filehandle or string
      $text			# text
     )=@_;
  if (ref($output) eq 'SCALAR') {
    $$output.=$text;
  } else {
    print $output $text;
  }
}

sub PrintFSFile {
  my ($fh,$fsformat,$trees,$emu_schema)=@_;
  foreach my $tree (@$trees) {
    PrintFSTree($tree,$fsformat,$fh,$emu_schema);
  }
}

sub PrintFSTree {
  my ($root,  # a reference to the root-node
      $fsformat, # FSFormat object
      $fh,
      $emu_schema
     )=@_;

  $fh=\*STDOUT unless $fh;
  my $node=$root;
  while ($node) {
    PrintFSNode($node,$fsformat,$fh,$emu_schema);
    if ($node->{$Fslib::firstson}) {
      Print($fh, "(");
      $node = $node->{$Fslib::firstson};
      redo;
    }
    while ($node && $node != $root && !($node->{$Fslib::rbrother})) {
      Print($fh, ")");
      $node = $node->{$Fslib::parent};
    }
    croak "Error: NULL-node within the node while printing\n" if !$node;
    last if ($node == $root || !$node);
    Print($fh, ",");
    $node = $node->{$Fslib::rbrother};
    redo;
  }
  Print($fh, "\n");
}

sub PrintFSNode {
  my ($node,			# a reference to the root-node
      $fsformat,
      $output,			# output stream
      $emu_schema
     )=@_;
  my $v;
  my $lastprinted=1;

  my $defs = $fsformat->defs;
  my $attrs = $fsformat->list;
  my $attr_count = $#$attrs+1;

  if ($node) {
    Print($output, "[");
    for (my $n=0; $n<$attr_count; $n++) {
      $v=$emu_schema ? $node->attr($attrs->[$n]) : $node->{$attrs->[$n]};
      $v=~s/([,\[\]=\\])/\\$1/go if (defined($v));
      if (index($defs->{$attrs->[$n]}, " O")>=0) {
	Print($output,",") if $n;
	unless ($lastprinted && index($defs->{$attrs->[$n]}," P")>=0) # N could match here too probably
	  { Print($output, $attrs->[$n]."="); }
	$v='-' if ($v eq '' or not defined($v));
	Print($output,$v);
	$lastprinted=1;
      } elsif ($v ne "") {
	Print($output,",") if $n;
	unless ($lastprinted && index($defs->{$attrs->[$n]}," P")>=0) # N could match here too probably
	  { Print($output,$attrs->[$n]."="); }
	Print($output,$v);
	$lastprinted=1;
      } else {
	$lastprinted=0;
      }
    }
    Print($output,"]");
  } else {
    Print($output,"<<NULL>>");
  }
}


=pod

=item FSBackend::ParseFSTree ($fsformat,$line,$ordhash)

Parse a given string (line) in FS format and return the root of the
resulting FS tree as an FSNode object.

=cut

sub ParseFSTree {
  my ($fsformat,$l,$ordhash,$emu_schema_type)=@_;
  return unless ref($fsformat);
  my $root;
  my $curr;
  my $c;

  unless ($ordhash) {
    my $i = 0;
    $ordhash = { map { $_ => $i++ } @{$fsformat->list} };
  }

  if ($l=~/^\[/o) {
    $l=~s/&/&amp;/g;
    $l=~s/\\\\/&backslash;/g;
    $l=~s/\\,/&comma;/g;
    $l=~s/\\\[/&lsqb;/g;
    $l=~s/\\]/&rsqb;/g;
    $l=~s/\\=/&eq;/g;
    $l=~s/\\//g;
    $l=~s/\r//g;
    $curr=$root=ParseFSNode($fsformat,\$l,$ordhash,$emu_schema_type);   # create Root

    while ($l) {
      $c = substr($l,0,1);
      $l = substr($l,1);
      if ( $c eq '(' ) { # Create son (go down)
	my $first_son = $curr->{$Fslib::firstson} = ParseFSNode($fsformat,\$l,$ordhash,$emu_schema_type);
	$first_son->{$Fslib::parent}=$curr;
	$curr=$first_son;
	next;
      }
      if ( $c eq ')' ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$curr->{$Fslib::parent};
	next;
      }
      if ( $c eq ',' ) { # Create right brother (go right);
	my $rb = $curr->{$Fslib::rbrother} = ParseFSNode($fsformat,\$l,$ordhash,$emu_schema_type);
	$rb->set_lbrother( $curr );
	$rb->set_parent( $curr->{$Fslib::parent} );
	$curr=$rb;
	next;
      }
      croak "Unexpected token... `$c'!\n$l\n";
    }
    croak "Error: Closing brackets do not lead to root of the tree.\n" if ($curr != $root);
  }
  return $root;
}


sub ParseFSNode {
  my ($fsformat,$lr,$ordhash,$emu_schema_type) = @_;
  my $n = 0;
  my $node;
  my @ats=();
  my $pos = 1;
  my $a=0;
  my $v=0;
  my $tmp;
  my @lv;
  my $nd;
  my $i;
  my $w;

  my $defs = $fsformat->defs;
  my $attrs = $fsformat->list;
  my $attr_count = $#$attrs+1;
  unless ($ordhash) {
    my $i = 0;
    $ordhash = { map { $_ => $i++ } @$attrs };
  }

  $node = FSNode->new();
  $node->set_type($emu_schema_type) if ($emu_schema_type);
  if ($$lr=~/^\[/) {
    chomp $$lr;
    $i=index($$lr,']');
    $nd=substr($$lr,1,$i-1);
    $$lr=substr($$lr,$i+1);
    @ats=split(',',$nd);
    while (@ats) {
      $w=shift @ats;
      $i=index($w,'=');
      if ($i>=0) {
	$a=substr($w,0,$i);
	$v=substr($w,$i+1);
	$tmp=$ordhash->{$a};
	$n = $tmp if (defined($tmp));
      } else {
	$v=$w;
        $n++ while ( $n<$attr_count and $defs->{$attrs->[$n]}!~/ [PNW]/);
	if ($n>$attr_count) {
	  croak "No more positional attribute $n for value $v at position in:\n".$n."\n";
	}
	$a=$attrs->[$n];
      }
      if ($CheckListValidity) {
	if ($fsformat->isList($a)) {
	  @lv=$fsformat->listValues($a);
	  foreach $tmp (split /\|/,$v) {
	    print("Invalid list value $v of atribute $a no in @lv:\n$nd\n" ) unless (defined(Index(\@lv,$tmp)));
	  }
	}
      }
      $n++;
      $v=~s/&comma;/,/g;
      $v=~s/&lsqb;/[/g;
      $v=~s/&rsqb;/]/g;
      $v=~s/&eq;/=/g;
      $v=~s/&backslash;/\\/g;
      $v=~s/&amp;/&/g;
      if ($emu_schema_type and $a=~/\//) {
	$node->set_attr($a,$v);
      } else {
	# speed optimized version
	#      $node->setAttribute($a,$v);
	$node->{$a}=$v;
      }
    }
  } else { croak $$lr," not node!\n"; }
  return $node;
}

=pod

=back

=cut

############################################################
#
# Fslib Schema
# =============
#
#

package Fslib::Schema;
use strict;
use PMLSchema;
@Fslib::Schema::EXPORT      =  @PMLSchema::EXPORT;
%Fslib::Schema::EXPORT_TAGS = %PMLSchema::EXPORT_TAGS;
use base qw(PMLSchema);

=head2 Fslib::Schema

Fslib::Schema - Fslib interface to PML schemas. This package aims to
become a successor of FSFormat in the future. Currently it derives
from C<PMLSchema> class.

Only methods added over L<PMLSchema> class are listed below.

=over 4

=cut

# emulate FSFormat->attributes to some extent

=item $schema->attributes (decl...)

This function tries to emulate the behavior of
C<$format-E<gt>attributes> to some extent.

Return attribute paths to all atomic subtypes of given type
declarations. If no type declaration objects are given, then types
with role C<#NODE> are assumed. This function never descends to
subtypes with role C<#CHILDNODES>.

=cut

sub attributes {
  my ($self,@types) = @_;
  # find node type

  unless (@types) {
    @types = $self->node_types;
  }
  my @result;
  foreach my $type (@types) {
    my $decl_is = $type->get_decl_type;
    next if $type->get_role eq '#CHILDNODES';
    if ($decl_is == PML_TYPE_DECL ||
	$decl_is == PML_ROOT_DECL ||
	$decl_is == PML_ATTRIBUTE_DECL ||
	$decl_is == PML_MEMBER_DECL ||
	$decl_is == PML_ELEMENT_DECL  ||
	$decl_is == PML_LIST_DECL ||
	$decl_is == PML_ALT_DECL ) {
      $type = $type->get_knit_content_decl;
      redo;
    }
    next unless ref($type);
    my @members;
    if ($decl_is == PML_STRUCTURE_DECL) {
      @members = map { [$_,$_->get_knit_name] } $type->get_members;
    } elsif ($decl_is == PML_CONTAINER_DECL) {
      my $cdecl = $type->get_knit_content_decl;
      @members = ((map { [ $_, $_->get_name ] } $type->get_attributes),
		    ($cdecl ? [$cdecl, '#content'] : ()));
    } elsif ($decl_is == PML_SEQUENCE_DECL) {
      @members = map { [ $_, $_->get_name ] } $type->get_elements;
    } else {
      push @result, qq{};
    }
    if (@members) {
      for my $m (@members) {
	my ($mdecl,$name) = @$m;
	push @result, map { $_ eq q{} ? $name : $name."/".$_ } $self->attributes($mdecl);
      }
    }
  }
  my %uniq;
  return grep { !$uniq{$_} && ($uniq{$_}=1) } @result;
}

=item Other methods

See the documentation of the super class (L<PMLSchema>) for a complete
API documentation.

=back

=cut

############################################################

=head1 DATA TYPE CLASSES

=head2 Fslib::List

This class implements the attribute value type 'list'.

=over 4

=cut

package Fslib::List;
use Carp;

=item Fslib::List->new (val1,val2,...)

Create a new list (optionally populated with given values).

=cut

sub new {
  my $class = shift;
  return bless [@_],$class;
}

=item Fslib::List->new_from_ref (array_ref, reuse)

Create a new list consisting of values in a given array reference.
Use this constructor instead of new() to pass large lists by reference. If
reuse is true, then the same array_ref scalar is reused within the
Fslib::List object (i.e. blessed). Otherwise, a copy is created within
the constructor.

=cut

sub new_from_ref {
  my ($class,$array,$reuse) = @_;
  if ($reuse) {
    if (UNIVERSAL::isa($array,'ARRAY')) {
      return bless $array,$class;
    } else {
      croak("Usage: new_from_ref(ARRAY_REF,1) - arg 1 is not an ARRAY reference!");
    }
  } else {
    return bless [@$array],$class;
  }
}

=item $list->values ()

Returns all its values (i.e. the list members).

=cut

sub values {
  return @{$_[0]};
}

=item $list->count ()

Return number of values in the list.

=cut

sub count {
  return scalar(@{$_[0]});
}

=item $list->append (@values)

Append given values to the list.

=cut

sub append {
  my $self = shift;
  push @$self,@_;
  return $self;
}

*push = \&append;

=item $list->append_list ($list2)

Append given values to the list.

=cut

sub append_list {
  my ($self, $list) = @_;
  push @$self,@$list;
  return $self;
}


=item $list->insert ($index, @values)

Insert values before the value at a given position in the list.  The
index of the first position in the list is 0.  It is an error if
$index is less then 0. If $index equals the index of the last
value + 1, then values are appended to the list, but it is an error if
$index is greater than that.

=cut

sub insert {
  my $self = shift;
  my $pos = shift;
  $self->insert_list($pos,\@_);
  return $self;
}

=item $list->insert_list ($index, $list)

Insert all values in $list before the value at a given position in the
current list. The index of the first position in the current list is
0.  It is an error if $index is less then 0. If $index equals
the index of the last value + 1, then values are appended to the list,
but it is an error if $index is greater than that.

=cut

sub insert_list {
  die 'Usage: Fslib::List->insert_list($index,$list) (wrong number of arguments!)'
    if @_!=3;
  my ($self,$pos,$list) = @_;
  die 'Fslib::List->insert: position out of bounds' if ($pos<0 or $pos>@$self);
  if ($pos==@$self) {
    push @$self,@$list;
  } else {
    splice @$self,$pos,0,@$list;
  }
  return $self;
}

=item $list->delete ($index, $count)

Delete $count values from the list starting at index $index.

=cut

sub delete {
  die 'Usage: Fslib::List->delete($index,$list) (wrong number of arguments!)'
    if @_!=3;
  my ($self,$pos,$count) = @_;
  die 'Fslib::List->insert: position out of bounds' if ($pos<0 or $pos>=@$self);
  splice @$self,$pos,$count;
  return $self;
}

=item $list->delete_value ($value)

Delete all occurences of value $value. Values are compared as strings.

=cut

sub delete_value {
  die 'Usage: Fslib::List->delete_value($value) (wrong number of arguments!)'
    if @_!=2;
  my ($self,$value) = @_;
  @$self = grep { $_ ne $value } @$self;
  return $self;
}

=item $list->delete_values ($value1,$value2,...)

Delete all occurences of values $value1, $value2,... Values are
compared as strings.

=cut

sub delete_values {
  my $self = shift;
  my %d; %d = @_;
  @$self = grep { !exists($d{$_}) } @$self;
  return $self;
}

=item $list->replace ($index, $count, @list)

Replacing $count values starting at index $index by values provided
in the @list (the count of values in @list may differ from $count).

=cut

sub replace {
  die 'Usage: Fslib::List->replace($index,$count,@list) (wrong number of arguments!)'
    unless @_>=3;
  my $self = shift;
  my $pos = shift;
  my $count = shift;
  $self->replace_list($pos,\@_);
  return $self;
}

=item $list->replace_list ($index, $count, $list)

Like replace, but replacement values are taken from a Fslib::List
object $list.

=cut

sub replace_list {
  my ($self,$pos,$count,$list)=@_;
  die 'Usage: Fslib::List->replace_list($index,$count,$list) (wrong number of arguments!)'
    if @_!=4;
  die 'Fslib::List->replace_list: position out of bounds' if ($pos<0 or $pos>=@$self);
  splice @$self,$pos,$count,@$list;
  return $self;
}

=item $list->value_at ($index)

Return value at index $index. This is in fact the same as
$list->[$index] only $index is checked to be non-negative and less
then the index of the last value.

=cut

sub value_at {
  my ($self,$pos)=@_;
  die 'Usage: Fslib::List->value_at($index) (wrong number of arguments!)'
    if @_!=2;
  die 'Fslib::List->value_at: position out of bounds' if ($pos<0 or $pos>=@$self);
  return $self->[$pos];
}

=item $list->set_value_at ($index,$value)

Set value at index $index to $value. This is in fact the same as
assigning directly to $list->[$index], except that $index is checked
to be non-negative and less then the index of the last value.  Returns
$value.

=cut

sub set_value_at {
  my ($self,$pos,$value)=@_;
  die 'Usage: Fslib::List->set_value_at($index,$value) (wrong number of arguments!)'
    if @_!=3;
  die 'Fslib::List->set_value_index: position out of bounds' if ($pos<0 or $pos>=@$self);
  return $self->[$pos] = $value;
}

=item $list->index_of ($value)

Search the list for the first occurence of value $value. Returns index
of the first occurence or undef if the value is not in the
list. (Values are compared as strings.)

=cut

sub index_of {
  my ($self,$value)=@_;
  die 'Usage: Fslib::List->index_of($value) (wrong number of arguments!)'
    if @_!=2;
  return \&Fslib::Index;
}

=item $list->unique_values ()

Return unique values in the list (ordered by the index of the first
occurence). Values are compared as strings.

=cut

sub unique_values {
  die 'Usage: Fslib::List->unique_values() (wrong number of arguments!)'
    if @_!=1;
  my $self = shift;
  my %a; 
  return grep { !($a{$_}++) } @$self;
}

=item $list->unique_list ()

Return a new Fslib::List object consisting of unique values in the
current list (ordered by the index of the first occurence).  Values
are compared as strings.

=cut

sub unique_list {
  die 'Usage: Fslib::List->unique_values() (wrong number of arguments!)'
    if @_!=1;
  my $self = shift;
  my %a; 
  my $class = ref $self;
  return $class->new_from_ref([grep { !($a{$_}++) } @$self],1);
}


=item $list->make_unique ()

Remove duplicated values from the list. Values are compared as
strings. Returns $list.

=cut

sub make_unique {
  die 'Usage: Fslib::List->make_unique() (wrong number of arguments!)'
    if @_!=1;
  my $self = shift;
  my %a; @$self = grep { !($a{$_}++) } @$self;
  return $self;
}

=back

=head2 Fslib::Alt

This class implements the attribute value type 'alternative'.

=over 4

=cut

package Fslib::Alt;
use Carp;

=item Fslib::Alt->new (value1,value2,...)

Create a new alternative (optionally populated with given values).

=cut

sub new {
  my $class = shift;
  return bless [@_],$class;
}

=item $alt->values ()

Retrurns a its values (i.e. the alternatives).

=cut

sub values {
  return @{$_[0]};
}

sub count {
  return scalar(@{$_[0]});
}

=item $alt->add (@values)

Add given values to the alternative. Only values which are not already
included in the alternative are added.

=cut

sub add {
  my $self = shift;
  $self->add_list(\@_);
  return $self;
}

=item $alt->add_list ($list)

Add values of the given list to the alternative. Only values which are
not already included in the alternative are added.

=cut

sub add_list {
  die 'Usage: Fslib::Alt->add_list() (wrong number of arguments!)'
    if @_!=2;
  my $self = shift;
  my $list = shift;
  my %a; @a{ @$self } = ();
  push @{$self}, grep { exists($a{$_}) ? 0 : ($a{$_}=1) } @$list;
  return $self;
}

=item $alt->delete_value ($value)

Delete all occurences of value $value. Values are compared as strings.

=cut

sub delete_value {
  die 'Usage: Fslib::List->delete_value($value) (wrong number of arguments!)'
    if @_!=2;
  my ($self,$value) = @_;
  @$self = grep { $_ ne $value } @$self;
  return $self;
}

=item $alt->delete_values ($value1,$value2,...)

Delete all occurences of values $value1, $value2,... Values are
compared as strings.

=cut

sub delete_values {
  my $self = shift;
  my %d; %d = @_;
  @$self = grep { !exists($d{$_}) } @$self;
  return $self;
}

=back

=cut

=head2 Fslib::Struct

This class implements the data type 'structure'.  Structure consists
of items called members. Each member is a name-value pair, where the
name uniquely determines the member within the structure
(i.e. distinct members of a structure have distinct names).

=over 4

=cut

package Fslib::Struct;
use Carp;

=item Fslib::Struct->new ({name=>value, ...},reuse?)

Create a new structure (optionally initializing its members).  If
reuse is true, the hash reference passed may be reused (re-blessed)
into the structure.

=cut

sub new {
  my ($class,$hash,$reuse) = @_;
  if (ref $hash) {
    return $reuse ? bless $hash, $class 
                  : bless {%$hash}, $class;
  } else {
    return bless {}, $class;
  }
}

=item $struct->get_member ($name)

Return value of the given member.

=cut

sub get_member {
  my ($self,$name) = @_;
  return $self->{$name};
}

# compatibility
*getAttribute = \&get_member;

=item $struct->set_member ($name,$value)

Set value of the given member.

=cut

sub set_member {
  my ($self,$name,$value) = @_;
  return $self->{$name}=$value;
}

# compatibility
*setAttribute = \&set_member;


=item $struct->delete_member ($name)

Delete the given member (returning its last value).

=cut

sub delete_member {
  my ($self,$name) = @_;
  return delete $self->{$name};
}

=item $struct->members ()

Return (assorted) list of names of all members.

=cut

sub members {
  return keys %{$_[0]};
}

=back

=cut

=head2 Fslib::Container

This class implements the data type 'container'. A container consists
of a central value called content annotated by a set of name-value
pairs called attributes whose values are atomic. Fslib represents the
container class as a subclass of Fslib::Struct, where attributes are
represented as members and the content as a member with a reserved
name '#content'.

=over 4

=cut

package Fslib::Container;
use Carp;
use strict;
use vars qw(@ISA);

@ISA=qw(Fslib::Struct);

=item Fslib::Container->new (value?, { name=>attr, ...}?,reuse?)

Create a new container (optionally initializing its value and
attributes). If reuse is true, the hash reference passed may be
reused (re-blessed) into the structure.

=cut

sub new {
  my ($class,$value,$hash,$reuse) = @_;
  if (ref $hash) {
    $hash = {%$hash} unless ($reuse);
    bless $hash, $class;
    $hash->{'#content'} = $value unless !defined($value) and exists($hash->{'#content'});
  } else {
    return bless {}, $class;
  }
}

=item $container->attributes ()

Return (assorted) list of names of all attributes.

=cut

sub attributes {
  return grep { $_ ne '#container' } keys %{$_[0]};
}

=item $container->value

Return the content value of the container.

=cut

sub value {
  return $_[0]->{'#content'};
}

=item $container->content

This is an alias for value().

=cut

*content = \&value;
*get_attribute = \&Fslib::Struct::get_member;
*set_attribute = \&Fslib::Struct::set_member;

=back

=cut

##############################

package Fslib::Seq;
use Carp;

=head2 Fslib::Seq

This class implements the data type 'sequence'. A sequence contains of
zero or more elements (L</"Fslib::Seq::Element">), each consisting of
a name and value. The ordering of elements in a sequence may be
constrained by a regular-expression-like pattern operating on element
names. Validation of a sequence against this constraint pattern is not
automatic but can be performed at any time on demand.

=over 4

=item Fslib::Seq->new (element_array_ref?, content_pattern?)

Create a new sequence (optionally populated with elements from a given
array_ref).  Each element should be a [ name, value ] pair. The second
optional argument is a regular expression constraint which can be
stored in the object and used later for validating content (see
validate() method below).

=cut

  sub new {
    my ($class,$array,$content_pattern) = @_;
    $array = [] unless defined($array);
    return bless [Fslib::List->new_from_ref($array), # a list consisting of [name,value] pairs
		  $content_pattern                  # a content_pattern constraint
		 ],$class;
  }

=item $seq->elements ($name?)

Return a list of [ name, value ] pairs representing the sequence
elements. If the optional $name argument is given, select
only elements whose name is $name.

=cut

  sub elements {
    my ($self,$name)=@_;
    if (defined $name and $name ne '*') {
      return grep { $_->[0] eq $name } @{$_[0]->[0]};
    } else {
      return @{$_[0]->[0]};
    }
  }

=item $seq->elements_list ()

Like C<elements>, only this method returns a Fslib::List object.

=cut

  sub elements_list {
    return $_[0]->[0];
  }


=item $seq->content_pattern ()

Return the regular expression constraint stored in the sequence object (if any).

=cut

  sub content_pattern {
    return $_[0]->[1];
  }

=item $seq->set_content_pattern ()

Store a regular expression constraint in the sequence object. This
expression can be used later to validate sequence content (see
validate() method).

=cut

  sub set_content_pattern {
    $_[0]->[1] = $_[1];
  }


=item $seq->values (name?)

If no name is given, return a list of values of all elements of the
sequence. If a name is given, return a list consisting of values of
elements with the given name.

In array context, the returned value is a list, in scalar
context the result is a Fslib::List object.

=cut

  sub values {
    my ($self,$name)=@_;
    my @values = map { $_->[1] } ($name ne q{}
				    ? grep { $_->[0] eq $name } $self->[0]->values
				    : $self->[0]->values);
    return wantarray ? @values : Fslib::List->new_from_ref(\@values,1);
  }

=item $seq->names ()

Return a list of names of all elements of the sequence. In array
context, the returned value is a list, in scalar context the result is
a Fslib::List object.

=cut

  sub names {
    my @names = map { $_->[0] } $_[0][0]->values;
    return wantarray ? @names : Fslib::List->new_from_ref(\@names,1);
  }

=item $seq->element_at (index)

Return the element of the sequence on the position specified by a
given index. Elements in the sequence are indexed as elements in Perl
arrays, i.e. starting from $[, which defaults to 0 and nobody sane
should ever want to change it.

=cut

  sub element_at {
    my ($self, $index)=@_;
    return $self->[0][$index];
  }


=item $seq->name_at (index)

Return the name of the element on a given position.

=cut

  sub name_at {
    my ($self, $index)=@_;
    return $self->[0][$index][0];
  }

=item $seq->value_at (index)

Return the value of the element on a given position.

=cut

  sub value_at {
    my ($self, $index)=@_;
    return $self->[0][$index][1];
  }

=item $seq->delegate_names (key?)

If all element values are HASH-references, then it is possible to
store each element's name in its value under a given key (that is, to
delegate the name to the HASH value). The default value for key is
C<#name>. It is a fatal error to try to delegate names if some of the
values is not a HASH reference.

=cut

  sub delegate_names {
    my ($self,$key) = @_;
    $key = '#name' unless defined $key;
    if (grep { !UNIVERSAL::isa($_->[1],'HASH') } @{$self->[0]}) {
      croak("Error: sequence contains a non-HASH element (Fslib::Seq can only delegate names to values if all values are HASH refs)!");
    }
    foreach my $element (@{$self->[0]}) {
      $element->[1]{$key} = $element->[0]; # store element's name in key $key of its value
    }
  }

=item $seq->validate (content_pattern?)

Check that content of the sequence satisfies a constraint specified
by means of a regular expression C<content_pattern>. If no content_pattern is
given, the one stored with the object is used (if any; otherwise undef
is returned).

Returns: 1 if the content satisfies the constraint, 0 otherwise.

=cut

  sub validate {
    my ($self,$re) = @_;
    $re = $self->content_pattern if !defined($re);
    return unless defined $re;
    my $content = join "",map { "<$_>"} $self->names;
    $re=~s/\#/\\\#/g;
    $re=~s/,/ /g;
    $re=~s/\s+/ /g;
    $re=~s/([^()?+*|,\s]+)/(?:<$1>)/g;
    # warn "'$content' VERSUS /$re/\n";
    return $content=~m/^$re$/x ? 1 : 0;
  }

=item $seq->push_element (name, value)

Append a given name-value pair to the sequence.

=cut

  sub push_element {
    my ($self,$name,$value)=@_;
    push @{$self->[0]},Fslib::Seq::Element->new($name,$value);
  }

=item $seq->push_element_obj (obj)

Append a given Fslib::Seq::Element object to the sequence.

=cut

  sub push_element_obj {
    my ($self,$obj)=@_;
    push @{$self->[0]},$obj;
  }


  sub splice {
    # TODO
  }
  sub delete_element_at {
    # TODO
  }
  sub store_element_at {
    # TODO
  }
  sub insert_at {
    # TODO
  }

=back

=cut

=head2 Fslib::Seq::Element

This class implements an element of a 'sequence', i.e. a name-value
pair.

=over 4

=cut

package Fslib::Seq::Element;
use Carp;

=item Fslib::Seq::Element->new (name, value)

Create a new sequence element.

=cut

  sub new {
    my ($class,$name, $value) = @_;
    return bless [$name,$value],$class;
  }

=item $el->name ()

Return the name of the element.

=cut

  sub name {
    $_[0]->[0];
  }


=item $el->value ()

Return the value of the element.

=cut

  sub value {
    $_[0]->[1];
  }

=item $el->setName (name)

Set name of the element

=cut

  sub setName {
    $_[0]->[0] = $_[1];
  }


=item $el->setValue (value)

Set value of the element

=cut

  sub setValue {
    $_[0]->[1] = $_[1];
  }

=back

=cut


###############################################################3

package Fslib::Type;
use Carp;

# =head2 Fslib::Type

# This is an obsoleted wrapper class for a schema type declarations.

# =over 4

# =cut

# =item Fslib::Type->new (schema,type)

# Return a new C<Fslib::Type> object containing a given type of a given
# C<Fslib::Schema>.

# =cut

sub new {
  my ($class, $schema, $type)=@_;
  return bless [$schema,$type], $class;
}

# =item $type->schema ()

# Retrieve the C<Fslib::Schema>.

# =cut

sub schema {
  my ($self)=@_;
  return $self->[0];
}

# =item $type->type_decl ()

# OBSOLETE

# =cut

sub type_decl {
  my ($self)=@_;
  return $self->[1];
}

{
  our $AUTOLOAD;
  sub AUTOLOAD {
    my $self = shift;
    croak "$self is not an object" unless ref($self);
    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    return $self->[1]->$name(@_);
  }
}

#=back

#=cut

# can be exported, but are discouraged
#C<$FSError>, C<Index>, C<SetParent>, C<SetLBrother>, C<SetRBrother>,
#C<SetFirstSon>, C<Paste>, C<Parent>, C<LBrother>, C<RBrother>,
#C<First>C<Son>



1;


############################################################
############################################################
############################################################

__END__

=pod

=head1 PACKAGE FUNCTIONS

=over 4

=item Fslib::ImportBackends (@backends)

=over 6

=item Parameters

C<@backends>  - a list of backend names

=item Description

Demand to load the given modules as I/O backends and return a list of
backend names successfully loaded. This list may then passed to FSFile
IO calls.

=item Returns

List of names of successfully loaded I/O backends.

=back

=item Fslib::CloneValue ($scalar)

=over 6

=item Parameters

C<$scalar> - arbitrary Perl scalar

=item Description

Returns a deep copy of the Perl structures containing
in a given scalar.

=item Returns

a deep copy of $scalar

=back

=item Fslib::ResourcePaths ()

Returns the current list of directories used by Fslib to search for
resources.

=item Fslib::SetResourcePaths (@paths)

=over 6

=item Parameters

C<@paths> - a list of a directory paths

=item Description

Specify the complete set of directories to be used by Fslib when
looking up resources.

=back

=item Fslib::AddResourcePath (@paths)

=over 6

=item Parameters

C<@paths> - a list of directory paths

=item Description

Add given paths to the end of the list of directories searched by
Fslib for resources.

=back

=item Fslib::AddResourcePathAsFirst (@paths)

=over 6

=item Parameters

C<@paths> - a list of directory paths

=item Description

Add given paths to beginning of the list of directories
searched for resources.

=back

=item Fslib::RemoveResourcePath (@paths)

=over 6

=item Parameters

C<@paths> - a list of directory paths

=item Description

Remove given paths from the list of directories searched for
resources.

=back

=item Fslib::FindInResourcePaths ($filename)

=over 6

=item Parameters

C<$filename> - a relative path to a file

=item Description

If a given filename is a relative path of a file found in the resource
paths, return an absolute path for the resource. Otherwise return
filename.

=back

=item Fslib::FindInResources ($filename)

Alias for C<FindInResourcePaths($filename)>.

=item Fslib::FindDirInResourcePaths ($dirname)

=over 6

=item Parameters

C<$dirname> - a relative path to a directory

=item Description

If a given directory name is a relative path of a sub-directory
located in one of resource directories, return an absolute path for
that subdirectory. Otherwise return dirname.

=back

=item Fslib::FindDirInResources ($filename)

Alias for C<FindDirInResourcePaths($filename)>.

=item Fslib::ResolvePath ($ref_filename,$filename,$search_resource_path?)

=over 6

=item Parameters

C<$ref_filename> - a reference filename

C<$filename>     - a relative path to a file

C<$search_resource_paths> - 0 or 1

=item Description

If a given filename is a relative path, try to find the file in the
same directory as ref-filename. In case of success, return a path
based on the directory part of ref-filename and filename.  If the file
can't be located in this way and the C<$search_resource_paths>
argument is true, return the value of
C<FindInResourcePaths($filename)>.

=back

=item Fslib::ReadEscapedLine (FH)

=over 6

=item Parameters

FH - a file handle, e.g. STDIN

=item Description

This auxiliary function reads lines form FH as long as one without a
trailing backslash is encountered. Returns concatenation of all lines
read with all trailing backslash characters removed.

=item Returns

The whole "line".

=back

=back

=head1 OBSOLETED FUNCTIONS

=over 4

=item OBSOLETE: Fslib::FirstSon($node), Fslib::Parent($node), Fslib::LBrother($node), Fslib::RBrother($node)

=over 6

=item Parameters

C<$node> - a FSNode object

=item Returns

Parent, first son, left brother or right brother resp. of the node
referenced by C<$node>.

There is no need to use these functions directly. You should use
FSNode methods instead.

=back

=item Next($node,[$top]), Prev ($node,[$top])

=over 6

=item Parameters

C<$node> - a reference to a tree hash-structure
C<$top>  - a reference to a tree hash-structure, containing
           the node referenced by $node

=item Returns

Reference to  the next or previous  node of $node  on the backtracking
way along the tree having its root in $top.  The $top parameter is NOT
obligatory and  may be omitted.  Return  zero, if $top of  root of the
tree reached.

There is no need to use this function directly. You should use
C<$node-E<gt>following()> method instead.

=back

=item Fslib::Cut ($node)

=over 6

=item Parameters

$node - a reference to a node

=item Description:

Cuts (disconnets) $node from its parent and siblings

Use C<$node-E<gt>cut()> instead.

=item Returns

$node

=back

=item Fslib::Paste ($node,$newparent,$fsformat_or_ord)

=over 6

=item Parameters

C<$node> - a reference to a (cutted or new) node

C<$newparent> - a reference to the new parent node

C<$fsformat_or_ord>  - FSFormat object or name of the ordering attribute

=item Description

attaches $node to $newparent as its new child, placing it to the
position among the other child nodes corresponding to a numerical
value obtained from the ordering attribute. If $fsformat_or_ord is a
FSFormat object, the $fsformat_or_ord->order method is used to
determine the ordering attribute. Otherwise, the string value of
$fsformat_or_ord is used as the name of the ordering attribute.

Use C<$node-E<gt>paste_on($newparent,$fsformat_or_ord)> instead.

=item Returns

$node

=back

=back

=head1 EXPORTED SYMBOLS

For B<backward compatibility reasons> only, Fslib exports by default the
following function symbols:

C<ImportBackends>, C<Next>, C<Prev>, C<DeleteTree>, C<DeleteLeaf>,
C<Cut>

For this reason, it is recommended to load Fslib as:

  use Fslib qw();

The following function symbols can be imported on demand:

C<ImportBackends>, C<CloneValue>, C<ResourcePaths>, C<FindInResources>, C<FindDirInResources>, C<FindDirInResourcePaths>, C<ResolvePath>, C<AddResourcePath>, C<AddResourcePathAsFirst>, C<SetResourcePaths>, C<RemoveResourcePath>

=head1 SEE ALSO

Tree editor TrEd: L<http://ufal.mff.cuni.cz/~pajas/tred>

Description of FS format:
L<http://ufal.mff.cuni.cz/pdt/Corpora/PDT_1.0/Doc/fs.html>

Description of PML format:
L<http://ufal.mff.cuni.cz/jazz/PML/doc/>

Related packages: L<PMLSchema>, L<PMLInstance>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

