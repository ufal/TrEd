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
use strict;
use Data::Dumper;

use vars qw(@EXPORT @EXPORT_OK @ISA $VERSION $field_re $attr_name_re
            $parent $firstson $lbrother $rbrother $type
            $SpecialTypes $FSError $Debug );

use Exporter;
@ISA=qw(Exporter);
$VERSION = "1.5";

@EXPORT = qw/&Next &Prev &DeleteTree &DeleteLeaf &Cut &ImportBackends/;
@EXPORT_OK = qw/$FSError &Index &SetParent &SetLBrother &SetRBrother &SetFirstSon &Paste &Parent &LBrother &RBrother &FirstSon/;

use Carp;
#use vars qw/$VERSION @EXPORT @EXPORT_OK $field_re $parent $firstson $lbrother/;

$Debug=0;
$field_re='(?:\\\\[\\]\\,]|[^\\,\\]])*';

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

sub SetParent ($$) {
  my ($node,$p) = @_;
  $node->{$parent}=$p if ($node);
}

sub LBrother ($) {
  my $node = shift;
  return $node->{$lbrother};
}

sub SetLBrother ($$) {
  my ($node,$p) = @_;
  $node->{$lbrother}=$p if ($node);
}


sub RBrother ($) {
  my $node = shift;
  return $node->{$rbrother};
}

sub SetRBrother ($$) {
  my ($node,$p) = @_;
  $node->{$rbrother}=$p if ($node);
}

sub FirstSon ($) {
  my $node = shift;
  return $node->{$firstson};
}

sub SetFirstSon ($$) {
  my ($node,$p) = @_;
  $node->{$firstson}=$p if ($node);
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
  my ($node,$top) = (shift, shift);
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
  my $node=shift;
  return $node if (! $node);

  if ($node->{$parent} and $node==$node->{$parent}->{$firstson}) {
    $node->{$parent}->{$firstson}=$node->{$rbrother};
  }
  $node->{$lbrother}->{$rbrother}=$node->{$rbrother} if ($node->{$lbrother});
  $node->{$rbrother}->{$lbrother}=$node->{$lbrother} if ($node->{$rbrother});

  $node->{$parent}=$node->{$lbrother}=$node->{$rbrother}=0;
  return $node;
}

sub Paste ($$$) {
  my ($node,$p,$fsformat)=(shift,shift,shift);
  my $aord=$fsformat->order;
  my $ordnum = $node->getAttribute($aord);

  my $b=$p->{$firstson};
  if ($b and $ordnum>$b->getAttribute($aord)) {
    $b=$b->{$rbrother} while ($b->{$rbrother} and $ordnum>$b->{$rbrother}->getAttribute($aord));
    $node->{$rbrother}=$b->{$rbrother};
    $b->{$rbrother}->{$lbrother}=$node if ($b->{$rbrother});
    $b->{$rbrother}=$node;
    $node->{$lbrother}=$b;
  } else {
    $node->{$rbrother}=$b;
    $p->{$firstson}=$node;
    $node->{$lbrother}=0;
    $b->{$lbrother}=$node if ($b);
  }
  $node->{$parent}=$p;
}

sub DeleteTree ($) {
  my ($top,$node,$next);
  $top=$node=shift;
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
  my $node = shift;
  if (!$node->{$firstson}) {
    $node->{$rbrother}->{$lbrother}=$node->{$lbrother} if ($node->{$rbrother});

    if ($node->{$lbrother}) {
      $node->{$lbrother}->{$rbrother}=$node->{$rbrother};
    } else {
      $node->{$parent}->{$firstson}=$node->{$rbrother} if $node->{$parent};
    }
    undef %$node;
    undef $node;
    return 1;
  }
  return 0;
}


sub Index ($$) {
  my ($ar,$i) = @_;
  for (my $n=0;$n<=$#$ar;$n++) {
    return $n if ($ar->[$n] eq $i);
  }
  return undef;
}

sub ReadLine {
  my $handle=shift;
  local $_;
  if (ref($handle) eq 'ARRAY') {
    $_=shift @$handle;
  } else { $_=<$handle>;
	   return $_; }
  return $_;
}

sub ReadEscapedLine {
  my $handle=shift;                # file handle or array reference
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


## End of Fs-format specific functions

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


####################
# OO API to FS Lib #
####################

############################################################
#
# FS Node
# =========
#
#

package FSNode;
use strict;

=pod

=head1 FSNode


FSNode - Simple OO interface to tree structures of Fslib.pm

=head2 REFERENCE

=over 4

=cut

=pod

=item new

Create a new FSNode object. FSNode is basicly a hash reference, which
means that you may simply acces node's attributes as C<$node->>C<{attribute}>

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

=item initialize

This function inicializes FSNode. It is called by the constructor new.

=cut

sub initialize {
  my $self = shift;
  return undef unless ref($self);
  $self->{$Fslib::firstson}=0;
  $self->{$Fslib::lbrother}=0;
  $self->{$Fslib::rbrother}=0;
  $self->{$Fslib::parent}=0;
}

sub DESTROY {
    my $self = shift;
    return undef unless ref($self);
    %{$self}=();
    return 1;
}

=pod

=item parent

Return node's parent node (C<undef> if none).

=cut


sub parent {
  my ($self) = @_;
  return ref($self) ? Fslib::Parent($self) : undef;
}

=pod

=item type

Return node's type node (C<undef> if none).

=cut


sub type {
  my ($self) = @_;
  return ref($self) ? $self->{$Fslib::type} : undef;
}

=item root

Find and return the root of the node's tree.

=cut


sub root {
  my ($self) = @_;
  my $root=$self; $root=Fslib::Parent($root) while ($root->parent);
  return $root;
}


=item level

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

=item lbrother

Return node's left brother node (C<undef> if none).

=cut


sub lbrother {
  my $self = shift;
  return ref($self) ? Fslib::LBrother($self) : undef;
}

=pod

=item rbrother

Return node's right brother node (C<undef> if none).

=cut


sub rbrother {
  my $self = shift;
  return ref($self) ? Fslib::RBrother($self) : undef;
}

=pod

=item firstson

Return node's first dependent node (C<undef> if none).

=cut


sub firstson {
  my $self = shift;
  return ref($self) ? Fslib::FirstSon($self) : undef;
}


sub set_parent ($$) {
  my ($node,$p) = @_;
  $node->{$Fslib::parent}= ref($p) ? $p : 0;
}

sub set_lbrother ($$) {
  my ($node,$p) = @_;
  $node->{$Fslib::lbrother}= ref($p) ? $p : 0;
}

sub set_rbrother ($$) {
  my ($node,$p) = @_;
  $node->{$Fslib::rbrother}= ref($p) ? $p : 0;
}

sub set_firstson ($$) {
  my ($node,$p) = @_;
  $node->{$Fslib::firstson}=ref($p) ? $p : 0;
}

sub set_type ($$) {
  my ($node,$type) = @_;
  $node->{$Fslib::type}=$type;
}

=pod

=item following (top?)

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

=item following_visible (fsformat,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub following_visible {
  my ($self,$fsformat,$top) = @_;
  return undef unless ref($self);
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

=item following_right_or_up (top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none), but not descending.

=cut

sub following_right_or_up {
  my ($self,$top) = @_;
  return undef unless ref($self);

  my $node=$self;
  while ($node) {
    return 0 if ($node==$top or !$node->parent);
    return $node->rbrother if $node->rbrother;
    $node = $node->parent;
  }
}


=pod

=item previous (top?)

Return the previous node of the subtree in the order given by
structure (C<undef> if none). The way of searching described in
C<following> is used here in reversed order.

=cut

sub previous {
  my ($self,$top) = @_;
  return ref($self) ? Fslib::Prev($self,$top) : undef;
}

=pod

=item previous_visible (fsformat,top?)

Return the next visible node of the subtree in the order given by
structure (C<undef> if none). A node is considered visible if it has
no hidden ancestor. Requires FSFormat object as the first parameter.

=cut

sub previous_visible {
  my ($self,$fsformat,$top) = @_;
  return undef unless ref($self);
  my $node=Fslib::Prev($self,$top);
  my $hiding;
  return $node unless ref($fsformat);
  while ($node) {
    return $node unless ($hiding=$fsformat->isHidden($node));
    $node=Fslib::Prev($hiding,$top);
  }
}


=pod

=item rightmost_descendant (node)

Return the rightmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub rightmost_descendant {
  my ($self) = @_;
  return undef unless ref($self);
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

=item leftmost_descendant (node)

Return the leftmost lowest descendant of the node (or
the node itself if the node is a leaf).

=cut

sub leftmost_descendant {
  my ($self) = @_;
  return undef unless ref($self);
  my $node=$self;
  $node=$node->firstson while ($node->firstson);
  return $node;
}

=pod

=item getAttribute (name)

Return value of the given attribute.

=cut

sub getAttribute {
  my ($self,$name) = @_;
  return $self->{$name};
}

=item attr (path)

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
	return undef; # ERROR
      } else {
	$val = $val->[0]{$step};
      }
    } elsif (ref($val)) {
      $val = $val->{$step};
    } elsif (defined($val)) {
#      warn "Can't follow attribute path '$path' (step '$step')\n";
      return undef; # ERROR
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
	warn "Can't follow attribute path '$path' (step '$step')\n";
	return undef; # ERROR
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
	$val = $val->{$step};
      } else {
	$val->{$step} = $value;
      }
    } elsif (defined($val)) {
      warn "Can't follow attribute path '$path' (step '$step')\n";
      return undef; # ERROR
    } else {
      return '';
    }
  }
  return undef;
}


=pod

=item setAttribute (name,value)

Set value of the given attribute.

=cut

sub setAttribute {
  my ($self,$name,$value) = @_;
  return $self->{$name}=$value;
}


=pod

=item children

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

=item visible_children(fsformat)

Return a list of visible dependent nodea.

=cut

sub visible_children {
  my ($self,$fsformat) = @_;
  die "required parameter missing for visible_children(fsformat)" unless $fsformat;
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


=item descendants

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

=item visible_descendants(fsformat)

Return a list recursively dependent visible nodes.

=cut

sub visible_descendants($$) {
  my ($self,$fsformat) = @_;
  die "required parameter missing for visible_descendants(fsfile)" unless $fsformat;
  my @kin=();
  my $desc=$self->following_visible($fsformat,$self);
  while ($desc) {
    push @kin, $desc;
    $desc=$desc->following_visible($fsformat,$self);
  }
  return @kin;
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
# FS Format
# =========
#
#

package FSFormat;
use strict;
use vars qw(%Specials $AUTOLOAD $special);

=head1 FSFormat

FSFormat - Simple OO interface for FS instance of Fslib.pm

=head2 REFERENCE

=over 4

=cut

%Specials = (sentord => 'W', order => 'N', value => 'V', hide => 'H');
$special=" _SPEC";

=pod

=item create (@header)

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


=item new (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

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

=item clone

Duplicate FS format instance object.

=cut

sub clone {
  my $self = shift;
  return unless ref($self);
  return $self->new(
		    {%{$self->defs()}},
		    [$self->attributes()],
		    [@{$self->unparsed()}]
		   );
}


=pod

=item initialize (attributes_hash_ref?, ordered_names_list_ref?, unparsed_header?)

Initialize a new FS format instance with given values. See L<"Fslib">
for more information about attribute hash, ordered names list and unparsed headers.

=cut

sub initialize {
  my $self = shift;
  return undef unless ref($self);

  $self->[0] = ref($_[0]) ? $_[0] : { }; # attribs  (hash)
  $self->[1] = ref($_[1]) ? $_[1] : [ ]; # atord    (sorted array)
  $self->[2] = ref($_[2]) ? $_[2] : [ ]; # unparsed (sorted array)
  return $self;
}

=pod

=item addNewAttribute (type, colour, name, list)

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

=item readFrom (source,output?)

Reads FS format instance definition from given source, optionally
echoing the unparsed input on the given output. The obligatory
argument C<source> must be either a GLOB or list reference.
Argument C<output> is optional and if given, it must be a GLOB reference.

=cut

sub readFrom {
  my ($self,$handle,$out) = @_;
  return undef unless ref($self);

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
    if (/^\@([KPOVNWLH])([A-Z0-9])* (${Fslib::attr_name_re})(?:\|(.*))?/o) {
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

=item toArray

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

=item writeTo (glob_ref)

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

=item sentord
=item order
=item value
=item hide

Return names of special attributes declared in FS format as @W, @N,
@V, @H respectively.

=cut

sub AUTOLOAD {
  my ($self)=@_;
  return undef unless ref($self);
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;
  if (exists($FSFormat::Specials{$sub})) {
    return $self->specials->{ $FSFormat::Specials{$sub} };
  } else {
    return undef;
  }
}

sub DESTROY {
  my $self = shift;
  return undef unless ref($self);
  $self->[0]=undef;
  $self->[1]=undef;
  $self->[2]=undef;
  $self=undef;
}

=pod

=item isHidden (node)

Return the lowest ancestor-or-self of the given node marked by
C<'hide'> in the FS attribute declared as @H. Return undef, if no such
node exists.

=cut

sub isHidden {
  # Tests if given FSNode node is hidden or not
  # Returns the ancesor that hides it or undef
  my ($self,$node)=@_;
  return unless ref($self) and ref($node);
  my $hid=$self->specials->{H};

  while (ref($node) && ($node->{$hid} eq '')) {
    $node=$node->parent;
  }
  return ($node ? $node : undef);
}

=pod

=item defs

Return a reference to the internally stored attribute hash.

=cut

sub defs {
  my $self = shift;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item list

Return a reference to the internally stored attribute names list.

=cut

sub list {
  my $self = shift;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item unparsed

Return a reference to the internally stored unparsed FS header. Note,
that this header must B<not> correspond to the defs and attributes if
any changes are made to the definitions or names at run-time by hand.

=cut

sub unparsed {
  my $self = shift;
  return ref($self) ? $self->[2] : undef;
}


=pod

=item renew_specials

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
  return undef;
}

=item specials

Return a reference to a hash of attributes of special types. Keys
of the hash are special attribute types and values are their names.

=cut

sub specials {
  my $self = shift;
  return undef unless ref($self);
  unless (ref($self->[0]->{$special})) {
    $self->renew_specials();
  }
  return $self->[0]->{$special};
}

=pod

=item attributes

Return a list of all attribute names (in the order given by FS
instance declaration).

=cut

sub attributes {
  my $self = shift;
  return ref($self) ? @{$self->list} : ();
}

=pod

=item atno (n)

Return the n'th attribute name (in the order given by FS
instance declaration).

=cut


sub atno {
  my ($self,$index) = @_;
  return ref($self) ? $self->list->[$index] : undef;
}

=pod

=item atno (attribute_name)

Return the definition string for the given attribute.

=cut

sub atdef {
  my ($self,$name) = @_;
  return ref($self) ? $self->defs->{$name} : undef;
}

=pod

=item count

Return the number of declared attributes.

=cut

sub count {
  my ($self) = @_;
  return ref($self) ? $#{$self->list}+1 : undef;
}

=pod

=item isList (attribute_name)

Return true if given attribute is assigned a list of all possible
values.

=cut

sub isList {
  my ($self,$attrib)=@_;
  return (index($self->defs->{$attrib}," L")>=0) ? 1 : 0;
}

=pod

=item listValues (attribute_name)

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

=item color (attribute_name)

Return one of C<Shadow>, C<Hilite> and C<XHilite> depending on the
color assigned to the given attribute in the FS format instance.

=cut

sub color {
  my ($self,$arg) = @_;
  return undef unless ref($self);

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

=item special (letter)

Return name of a special attribute declared in FS definition with a
given letter. See also L<"sentord"> and similar.

=cut

sub special {
  my ($self,$defchar)=@_;
  return
    ref($self) ? $self->specials->{$defchar} : undef;
}

=pod

=item indexOf (attribute_name)

Return index of the given attribute (in the order given by FS
instance declaration).

=cut

sub indexOf {
  my ($self,$arg)=@_;
  return
    ref($self) ? Fslib::Index($self->list,$arg) : undef;
}

=item exists (attribute_name)

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

=item make_sentence (root_node,separator)

Return a string containing the content of value (special) attributes
of the nodes of the given tree, separted by separator string, sorted by
value of the (special) attribute sentord or (if sentord does not exist) by
(special) attribute order.

=cut

sub make_sentence {
  my ($self,$root,$separator)=@_;
  return undef unless ref($self);
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

=item clone_node

Create a copy of the given node.

=cut

sub clone_node {
  my ($self,$node)=@_;
  my $new = FSNode->new();
  if ($node->type) {
    foreach my $atr ($node->type->members) {
      if (ref($node->{$atr})) {
	my $val;
	$new->{$atr} = eval Data::Dumper->new([$node->{$atr}],['val'])->Purity(1)->Dump;
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

=item clone_subtree

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
# FS File
# =========
#
#

package FSFile;
use strict;

=head1 FSFile

FSFile - Simple OO interface for FS files.

=head2 SYNOPSIS

  use Fslib;

  my $file="trees.fs";
  my $fs = FSFile->newFSFile($file);

  if ($fs->lastTreeNo<0) { die "File is empty or corrupted!\n" }

  foreach my $tree ($fs->trees) {

    ...    # do something on the trees

  }

  $fs->writeFile("$file.out");

=head2 REFERENCE

=over 4

=cut

=pod

=item new (name?,format?,FS?,hint_pattern?,attribs_pattern?,unparsed_tail?,trees?,save_status?,backend?,encoding?,user_data?,meta_data?)

Create a new FS file object and C<initialize> it with the optional values.

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

=item create

Same as C<new> but accepts name => value pairs as arguments. The
following argument names are available:

filename, format, FS, hint, patterns, tail, trees, save_status, backend

See C<initialize> for more detail.

=cut

sub create {
  my $self = shift;
  my %args=@_;
  return $self->new(@args{qw(name format FS hint patterns tail trees save_status backend encoding user_data meta_data)});
}


=item clone ($clone_trees)

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
  if ($deep) {
    @{$new->treeList} = map { $fs->clone_subtree($_) } $self->trees();
  }
  return $new;
}

sub DESTROY {
  my $self = shift;
  return undef unless ref($self);
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

=item initialize (name?,file_format?,FS?,hint_pattern?,attribs_patterns?,unparsed_tail?,trees?,save_status?,backend?,encoding?)

Initialize a FS file object. Argument description:

=over 4

=item name (scalar)

File name

=item file_format (scalar)

File format indentifier (user-defined string). TrEd, for example, uses
C<FS format>, C<gzipped FS format> and C<any non-specific format> strings as identifiers.

=item FS (FSFormat)

FSFormat object associated with the file

=item hint_pattern (scalar)

TrEd's hint pattern definition

=item attribs_patterns (list reference)

TrEd's display attributes pattern definition

=item unparsed_tail (list reference)

The rest of the file, which is not parsed by Fslib, i.e. Graph's embedded macros

=item trees (list reference)

List of FSNode objects representing root nodes of all trees in the FSFile.

=item save_status (scalar)

File save status indicator, 0=file is saved, 1=file is not saved (TrEd uses this field).

=item backend (scalar)

IO Backend used to open/save the file.

=item encoding (scalar)

IO character encoding for perl 5.8 I/O filters

=item user_data (arbitrary scalar type)

Applicatoin specific data

=item meta_data (hashref)

Meta data (usually used by IO Backends to store additional information
about the file).

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
  $self->[6] = ref($_[6]) eq 'ARRAY' ? $_[6] : []; # trees
  $self->[7] = $_[7] ? $_[7] : 0; # notsaved
  $self->[8] = undef; # storage for current tree number
  $self->[9] = undef; # storage fro current node
  $self->[10] = $_[8] ? $_[8] : 'FSBackend'; # backend;
  $self->[11] = $_[9] ? $_[9] : undef; # encoding;
  $self->[12] = $_[10] ? $_[10] : undef; # user data
  $self->[13] = $_[11] ? $_[11] : {}; # meta data
  return ref($self) ? $self : undef;
}

=pod

=item readFile (filename, [backends...])

Read FS declaration and trees from a given file.  The first argument
must be a file-name.  If a list of backend modules is specified,
C<test> methods of the modules are invoked as long as one of them
succeeds. That module is than used as a backend for opening and
parsing the file.

Note: this function sets noSaved to zero.

=cut

sub readFile {
  my ($self,$url) = (shift,shift);
  my $ret = 1;
  return unless ref($self);
  $url =~ s/^\s*|\s*$//g;
  my ($file,$remove_file) = IOBackend::fetch_file($url);

  @_=qw/FSBackend/ unless @_;
  foreach my $backend (@_) {
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
	&{"${backend}::close_backend"}($fh);
      };
      if ($@) {
	print STDERR "Error occured while reading '$file':\n";
	print STDERR "$@\n";
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
    print STDERR "$@\n" if $@;
  }
  if ($url ne $file and $remove_file) {
    local $!;
    unlink $file || warn "couldn't unlink tmp file $file: $!\n";
  }
  return $ret;
}

=pod

=item readFrom (glob_ref, [backends...])

Read FS declaration and trees from a given file (file handle open for
reading must be passed as a GLOB reference).
This function is limited to use FSBackend only.
Sets noSaved to zero.

=cut

sub readFrom {
  my ($self,$fileref) = (shift,shift);
  return unless ref($self);

  my $ret=FSBackend::read($fileref,$self);
  $self->notSaved(0);
  return $ret;
}

=pod

=item writeFile (filename)

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
  eval {
    no strict 'refs';
    my $fh;
    $ret=( $backend->can('write')
       and $backend->can('open_backend')
       and ($fh=&{"${backend}::open_backend"}($filename,"w",$self->encoding))
       and &{"${backend}::write"}($fh,$self)
       and &{"${backend}::close_backend"}($fh));
    print STDERR "Status: $ret\n" if $Fslib::Debug;
  };
  if ($@) {
    print STDERR "Error: $@\n";
    return 0;
  }
  $self->notSaved(0) if $ret;
  return $ret;
}


=item writeTo (glob_ref)

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

=item newFSFile (filename,encoding?,[backends...])

Create a new FSFile object based on the content of a given file.
If a list of backend
modules is specified, C<read> methods of the modules are invoked
as long as one of them succeeds to open and parse the file.

Optionally, in perl ver. >= 5.8, you may also specify file character
encoding.

=cut

sub newFSFile {
  my ($self,$filename,$encoding) = (shift,shift,shift);

  my $new=$self->new();
  $new->changeEncoding($encoding);
  $Fslib::FSError=$new->readFile($filename,@_);
  return $new;
}

=pod

=item filename

Return the FS file's file name.

=cut


sub filename {
  my $self = shift;
  return ref($self) ? $self->[0] : undef;
}

=pod

=item changeFilename (new_filename)

Change the FS file's file name.

=cut


sub changeFilename {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[0]=$val;
}

=pod

=item fileFormat

Return file format indentifier (user-defined string). TrEd, for
example, uses C<FS format>, C<gzipped FS format> and C<any
non-specific format> strings as identifiers.

=cut

sub fileFormat {
  my $self = shift;
  return ref($self) ? $self->[1] : undef;
}

=pod

=item changeFileFormat

Change file format indentifier.

=cut

sub changeFileFormat {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[1]=$val;
}

=pod

=item backend

Return IO backend module name. The default backend is FSBackend, used
to save files in the FS format.

=cut

sub backend {
  my $self = shift;
  return ref($self) ? $self->[10] : undef;
}

=pod

=item changeBackend

Change file backend.

=cut

sub changeBackend {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[10]=$val;
}

=pod

=item encoding

Return file character encoding (used by Perl 5.8 input/output filters).

=cut

sub encoding {
  my $self = shift;
  return ref($self) ? $self->[11] : undef;
}

=pod

=item changeEncoding

Change file character encoding (used by Perl 5.8 input/output filters).

=cut

sub changeEncoding {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[11]=$val;
}


=pod

=item userData

Return user data associated with the file

=cut

sub userData {
  my $self = shift;
  return ref($self) ? $self->[12] : undef;
}

=pod

=item changeUserData

Change user data associated with the file

=cut

sub changeUserData {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[12]=$val;
}

=pod

=item metaData(name)

Return meta data stored into the object usually by IO backends.

=cut

sub metaData {
  my ($self,$name) = @_;
  return ref($self) ? $self->[13]->{$name} : undef;
}

=pod

=item changeMetaData(name,value)

Change meta information (usually used by IO backends).

=cut

sub changeMetaData {
  my ($self,$name,$val) = @_;
  return unless ref($self);
  return $self->[13]->{$name}=$val;
}

=pod

=item listMetaData(name)

Return meta-data keys (in array context) or meta-data hash reference
(in scalar context).

=cut

sub listMetaData {
  my ($self) = @_;
  return unless ref($self);
  return wantarray ? keys(%{$self->[13]}) : $self->[13];
}

=pod

=item FS

Return a reference to the associated FSFormat object.

=cut

sub FS {
  my $self = shift;
  return ref($self) ? $self->[2] : undef;
}

=pod

=item changeFS

Associate FS file with a new FSFormat object.

=cut

sub changeFS {
  my ($self,$val) = @_;
  return undef unless ref($self);
  $self->[2]=$val;
  return $self->[2];
}

=pod

=item hint

Return the Tred's hint pattern declared in the FSFile.

=cut


sub hint {
  my $self = shift;
  return ref($self) ? $self->[3] : undef;
}

=pod

=item changeHint

Change the Tred's hint pattern associated with this FSFile.

=cut


sub changeHint {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[3]=$val;
}

=pod

=item pattern_count

Return the number of display attribute patterns associated with this FSFile.

=cut

sub pattern_count {
  my $self = shift;
  return ref($self) ? scalar(@{ $self->[4] }) : undef;
}

=item pattern (n)

Return n'th the display pattern associated with this FSFile.

=cut


sub pattern {
  my ($self,$index) = @_;
  return ref($self) ? $self->[4]->[$index] : undef;
}

=item patterns

Return a list of display attribute patterns associated with this FSFile.

=cut

sub patterns {
  my $self = shift;
  return ref($self) ? @{$self->[4]} : undef;
}

=pod

=item changePatterns

Change the list of display attribute patterns associated with this FSFile.

=cut

sub changePatterns {
  my $self = shift;
  return unless ref($self);
  return @{$self->[4]}=@_;
}

=pod

=item tail

Return the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut


sub tail {
  my $self = shift;
  return ref($self) ? @{$self->[5]} : undef;
}

=pod

=item tail

Modify the unparsed tail of the FS file (i.e. Graph's embedded macros).

=cut


sub changeTail {
  my $self = shift;
  return unless ref($self);
  return @{$self->[5]}=@_;
}

=pod

=item trees

Return a list of all trees (i.e. their roots represented by FSNode objects).

=cut

## Two methods to work with trees (for convenience)
sub trees {
  my $self = shift;
  return ref($self) ? @{$self->treeList} : undef;
}

=pod

=item trees

Assign a new list of trees.

=cut

sub changeTrees {
  my $self = shift;
  return unless ref($self);
  return @{$self->treeList}=@_;
}

=pod

=item treeList

Return a reference to the internal array of all trees (e.g. their
roots represented by FSNode objects).

=cut

# returns a reference!!!
sub treeList {
  my $self = shift;
  return ref($self) ? $self->[6] : undef;
}

=pod

=item tree (n)

Return a reference to the tree number n.

=cut

# returns a reference!!!
sub tree {
  my ($self,$n) = @_;
  return ref($self) ? $self->[6]->[$n] : undef;
}


=pod

=item changeTreeList (new_trees)

Associate a new reference to a list of trees with the this FSFile.
The referenced array must be a list of FSNode objects representing all
the new trees.

=cut

sub changeTreeList {
  my ($self,$val) = @_;
  return unless ref($self);
  return $self->[6]=$val;
}

=pod

=item lastTreeNo

Return number of associated trees minus one.

=cut

sub lastTreeNo {
  my $self = shift;
  return ref($self) ? $#{$self->treeList} : undef;
}

=pod

=item notSaved (value?)

Return/assign file saving status (this is completely user-driven).

=cut

sub notSaved {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[7]=$val if (defined $val);
  return $self->[7];
}

=item currentTreeNo (value?)

Return/assign index of current tree (this is completely user-driven).

=cut

sub currentTreeNo {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[8]=$val if (defined $val);
  return $self->[8];
}

=item currentNode (value?)

Return/assign current node (this is completely user-driven).

=cut

sub currentNode {
  my ($self,$val) = @_;

  return undef unless ref($self);
  return $self->[9]=$val if (defined $val);
  return $self->[9];
}

=pod

=item nodes (tree_no, prev_current, include_hidden)

Get list of nodes for given tree. Returns two value list ($nodes,$current),
where $nodes is a reference to a list of nodes for the tree and
current is either root of the tree or the same node as prev_current if
prev_current belongs to the tree. The list is sorted according to
the FS->order attribute and inclusion of hidden nodes depends on the
boolean value of include_hidden.

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

  my $ord=$fsfile->FS->order();
  @{$nodes}=
    sort { $a->getAttribute($ord) <=> $b->getAttribute($ord) }
      @unsorted;

  # just for sure
  undef @unsorted;
  # this is actually a workaround for TR, where two different nodes
  # may have the same Ord
  return ($nodes,$current);
}

=pod

=item value_line (tree_no, no_tree_numbers?)

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

=item value_line_list (tree_no)

Return a list of value (FS->value) attributes for the given tree
ordered according to the FS->sentord or FS->order if FS->sentord
attribute is not defined.

=cut

sub value_line_list {
  my ($fsfile,$tree_no,$no_numbers,$wantnodes)=@_;
  return unless $fsfile;

  my $node=$fsfile->treeList->[$tree_no];
  my @sent=();

  my $attr=$fsfile->FS->sentord();
  my $val=$fsfile->FS->value();
  $attr=$fsfile->FS->order() unless (defined($attr));
  while ($node) {
    push @sent,$node unless ($node->{$val} eq '' or
			     $node->{$val} eq '???' or
			     $node->{$attr}>=999); # this is TR specific stuff
    $node=$node->following();
  }
  @sent = sort { $a->{$attr} <=> $b->{$attr} } @sent;
  if ($wantnodes) {
    return (map { [$_->{$val},$_] } @sent);
  } else {
    return (map { $_->{$val} } @sent);
  }
}


=pod

=item insert_tree (root,position)

Insert new tree at given position.

=cut

sub insert_tree {
  my ($self,$nr,$pos)=@_;
  splice(@{$self->treeList}, $pos, 0, $nr) if $nr;
  return $nr;
}

=pod

=item set_tree (root,pos)

Set tree at given position.

=cut

sub set_tree {
  my ($self,$nr,$pos)=@_;
  $self->treeList->[$pos]=$nr;
  return $nr;
}


=pod

=item new_tree (position)

Create a new tree at given position and return pointer to its root.

=cut

sub new_tree {
  my ($self,$pos)=@_;

  my $nr=FSNode->new(); # creating new root
  $self->insert_tree($nr,$pos);
  return $nr;

}

=item delete_tree (position)

Delete the tree at given position and return pointer to its root.

=cut

sub delete_tree {
  my ($self,$pos)=@_;
  my ($root)=splice(@{$self->treeList}, $pos, 1);
  return $root;
}

=item destroy_tree (position)

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
# FSBackend
# =========
#
#

package FSBackend;
use vars qw($CheckListValidity);
use strict;
use IOBackend qw(open_backend close_backend);
use Carp;

=pod

=head1 FSBackend

FSBackend - IO backend for reading/writing FS files using FSFile class.

=head2 REFERENCE

=over 4

=cut

=pod

=item test (filehandle | filename, encoding?)

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
    binmode $f;
    my $test = ($f->getline()=~/^@/);
    return $test;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}

=pod

=item read (handle_ref,fsfile)

Read FS declaration and trees from a given file in FS format (file
handle open for reading must be passed as a GLOB reference).
Return 1 on success 0 on fail.

=cut

sub read {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

  $fsfile->changeFS( FSFormat->new() );
  $fsfile->FS->readFrom($fileref) || return 0;

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
      $root=ParseFSTree($fsfile->FS,$l,$ordhash);
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
    } elsif (/^\/\/FS-REQUIRE:\s*(\S+)\s+(\S+)="([^"]+)"\s*$/) {
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

=item write (handle_ref,$fsfile)

Write FS declaration, trees and unparsed tail to a given file to a
given file in FS format (file handle open for reading must be passed
as a GLOB reference).

=cut

sub write {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);

#  print $fileref @{$fsfile->FS->unparsed};
  $fsfile->FS->writeTo($fileref);
  PrintFSFile($fileref,
	      $fsfile->FS,
	      $fsfile->treeList);

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

sub PrintFSFile ($$$) {
  my ($fh,$fsformat,$trees)=@_;
  foreach my $tree (@$trees) {
    PrintFSTree($tree,$fsformat,$fh);
  }
}

sub PrintFSTree {
  my ($root,  # a reference to the root-node
      $fsformat, # FSFormat object
      $fh)=@_;

  $fh=\*STDOUT unless $fh;
  my $node=$root;
  while ($node) {
    PrintFSNode($node,$fsformat,$fh);
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

sub PrintFSNode($$$$) {
  my ($node,			# a reference to the root-node
      $fsformat,
      $output			# output stream
     )=@_;
  my $v;
  my $lastprinted=1;

  my $defs = $fsformat->defs;
  my $attrs = $fsformat->list;
  my $attr_count = $#$attrs+1;

  if ($node) {
    Print($output, "[");
    for (my $n=0; $n<$attr_count; $n++) {
      $v=$node->getAttribute($attrs->[$n]);
      $v=~s/([,\[\]=\\])/\\$&/go if (defined($v));
      if (index($defs->{$attrs->[$n]}, " O")>=0) {
	Print($output,",") if $n;
	unless ($lastprinted && index($defs->{$attrs->[$n]}," P")>=0) # N could match here too probably
	  { Print($output, $attrs->[$n]."="); }
	$v='-' if ($v eq '' or not defined($v));
	Print($output,$v);
	$lastprinted=1;
      } elsif (defined($node->getAttribute($attrs->[$n])) and $node->getAttribute($attrs->[$n]) ne '') {
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

=item ParseFSTree ($fsformat,$line,$ordhash)

Parse a given string (line) in FS format and return the root of the
resulting FS tree as an FSNode object.

=cut

sub ParseFSTree {
  my ($fsformat,$l,$ordhash)=@_;
  return undef unless ref($fsformat);
  my $root;
  my $curr;
  my $c;

  unless ($ordhash) {
    my $i = 0;
    $ordhash = { map { $_ => $i++ } @{$fsformat->list} };
  }

  if ($l=~/^\[/o) {
    $l=~s/\\,/&comma;/g;
    $l=~s/\\\[/&lsqb;/g;
    $l=~s/\\]/&rsqb;/g;
    $l=~s/\\\\/&backslash;/g;
    $l=~s/\\=/&eq;/g;
    $l=~s/\r//g;
    $curr=$root=ParseFSNode($fsformat,\$l,$ordhash);   # create Root

    while ($l) {
      $c = substr($l,0,1);
      $l = substr($l,1);
      if ( $c eq '(' ) { # Create son (go down)
	$curr->{$Fslib::firstson} = ParseFSNode($fsformat,\$l,$ordhash);
	$curr->{$Fslib::firstson}->{$Fslib::parent}=$curr;
	$curr=$curr->{$Fslib::firstson};
	next;
      }
      if ( $c eq ')' ) { # Return to parent (go up)
	croak "Error paring tree" if ($curr eq $root);
	$curr=$curr->{$Fslib::parent};
	next;
      }
      if ( $c eq ',' ) { # Create right brother (go right);
	$curr->{$Fslib::rbrother} = ParseFSNode($fsformat,\$l,$ordhash);
	$curr->{$Fslib::rbrother}->{$Fslib::lbrother}=$curr;
	$curr->{$Fslib::rbrother}->{$Fslib::parent}=$curr->{$Fslib::parent};
	$curr=$curr->{$Fslib::rbrother};
	next;
      }
      croak "Unexpected token... `$c'!\n$l\n";
    }
    croak "Error: Closing brackets do not lead to root of the tree.\n" if ($curr != $root);
  }
  return $root;
}


sub ParseFSNode {
  my ($fsformat,$lr,$ordhash) = @_;
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
      $v=~s/&backslash;/\\/g;
      $v=~s/&eq;/=/g;
      $node->setAttribute($a,$v);
    }
  } else { croak $$lr," not node!\n"; }
  return $node;
}

=pod

=back

=cut

############################################################

package Fslib::List;

sub new {
  my $class = shift;
  return bless [@_],$class;
}

sub values {
  return @{$_[0]};
}


package Fslib::Alt;

sub new {
  my $class = shift;
  return bless [@_],$class;
}

sub values {
  return @{$_[0]};
}


###########################################################

package Fslib::Schema;

sub new {
  my ($self,$string)=@_;
  my $class = ref($self) || $self;
  require XML::Simple;
  bless
    XML::Simple::XMLin($string,
	  ForceArray=>[ 'member', 'element', 'attribute', 'value', 'reference' ],
	  KeyAttr => { "member"    => "-name",
		       "element"   => "-name",
		       "attribute" => "-name",
		       "element"   => "-name",
		       "type"      => "-name"
		      },
	  GroupTags => { "choice" => "value" }
	 ), $class;
}

sub readFrom {
  my ($self,$file)=@_;
  print STDERR "parsing schema $file\n" if $Fslib::Debug;
  my $fh = IOBackend::open_backend($file,'r');
  die "Couldn't open PML schema file '$file'\n" unless $fh;
  local $/;
  my $slurp = <$fh>;
  close $fh;
  $self->new($slurp);
}

sub find_role {
  my ($self,$type,$role)=@_;
  return() unless UNIVERSAL::isa($type,'HASH');
  return (($type->{role} eq $role ? $self->resolve_type($type) : ()),  map { $self->find_role($_,$role) } grep { UNIVERSAL::isa($_,'HASH') } values %$type);
}

sub node_types {
  my ($self) = @_;
  my @result;
  return $self->find_role($self->{type},'#NODE');
}

sub resolve_type {
  my ($self,$type)=@_;
  return $type unless ref($type);
  if ($type->{type}) {
    my $rtype = $self->{type}{$type->{type}};
    return $rtype || $type->{type};
  } else {
    return $type;
  }
}

sub type {
  my ($self,$type)=@_;
  return Fslib::Type->new($self,$type);
}


# emulate FSFormat->attributes to some extent

sub attributes {
  my ($self,@types) = @_;
  # find node type

  unless (@types) {
    @types = $self->node_types;
  }
  my @result;
  foreach my $type (@types) {
    $type = $self->resolve_type($type);
    if (ref($type) and $type->{role} eq '#CHILDNODES') {
      return ();
    }
    while (ref($type) and ($type->{list} or $type->{alt})) {
      $type = $self->resolve_type($type->{list} || $type->{alt})
    }
    if (ref($type) and (exists($type->{member}) or exists($type->{structure}))) {
      my $members = exists($type->{member}) ? $type->{member} : $type->{structure}{member};
      for my $member (sort (keys %{$members})) {
	next if ($members->{$member} and
		   $members->{$member}{role} eq '#CHILDNODES');
	my @subattrs = $self->attributes($members->{$member});
	my $name = $member;
	if ($members->{$member} and $members->{$member}{role} eq '#KNIT') {
	  $name=~s/\.rf$//;
	}
	if (@subattrs) {
	  push @result, map { $name."/".$_ } @subattrs;
	} else {
	  push @result,$name;
	}
      }
    }
  }
  my %uniq;
  return grep { !$uniq{$_} && ($uniq{$_}=1) } @result;
}

package Fslib::Type;

sub new {
  my ($class, $schema, $type)=@_;
  return bless [$schema,$type], $class;
}

sub schema {
  my ($self)=@_;
  return $self->[0];
}

sub type_struct {
  my ($self)=@_;
  return $self->[1];
}

sub members {
  my ($self,$path)=@_;
  my $type = defined($path) ? $self->find($path) : $self->type_struct;
  if (ref($type) and $type->{structure}) {
    my $members = $type->{structure}{member};
    return grep { !(ref($members->{$_}) and $members->{$_}{role} eq '#CHILDNODES') } keys %$members;
  } else {
    return ();
  }
}

sub attributes {
  my ($self)=@_;
  return $self->schema->attributes($self->type_struct);
}

sub find {
  my ($self, $path) = @_;
  # find node type
  my $type = $self->type_struct;
  my $schema = $self->schema;
  if ($path eq '') {
    return $type;
  } else {
    for my $step (split /\//, $path) {
      $type = $schema->resolve_type($type);
      if (ref($type)) {
	if ($type->{knit}) {
	  $type = $type->{knit};
	  redo;
	} elsif ($type->{list} or $type->{alt}) {
	  $type = $type->{list} || $type->{alt};
	  if ($step =~ /^\[(\d+)\]/) {
	    next;
	  } else {
	    redo;
	  }
	} elsif ($type->{structure}) {
	  $type = $type->{structure}{member}{$step};
	} elsif ($type->{sequence}) {
	  $type = $type->{sequence}{element}{$step};
	} else {
	  return undef;
	}
      } else {
#	warn "Can't follow type path '$path' (step '$step')\n";
	return undef; # ERROR
      }
    }
    return $schema->resolve_type($type);
  }
}

1;


############################################################
############################################################
############################################################

__END__

=head1 Fslib

Fslib.pm - Simple low-level API for treebank files in .fs format.  See
L<"FSFile">, L<"FSFormat"> and L<"FSNode"> for an object-oriented
abstraction over this module.

=head2 SYNOPSIS

  use Fslib;


=head2 DESCRIPTION

This package has the ambition to be a simple and usable perl API for manipulating the
treebank files in the .fs format (which was designed by Michal Kren
and is the only format supported by his Windows application GRAPH.EXE
used to interractively edit treebank analytical or tectogramatical
trees). See also Dan Zeman's review of this format in Czech at

http://ufal.mff.cuni.cz/local/doc/trees/format_fs.html

The Fslib package defines functions for parsing .fs files, extracting
headers, reading trees and representing them in memory using simple
hash structures blessed to the B<FSNode> class, manipulate the values
of node attributes and modify the structure of the trees.

=head2 REFERENCE

=over 4

=item ReadEscapedLine (FH)

 Params:

   FH - a file handle, e.g. STDIN

 Returns:

   This auxiliary function reads lines form FH as long as
   one without a trailing backslash is encountered. Returns
   concatenation of all lines read with all trailing backslash
   characters removed.


=item Parent($node), FirstSon($node), LBrother($node), RBrother($node)

 Params:

   $node - a FSNode object

 Returns:

   Parent, first son, left brother or right brother resp. of the node
   referenced by $node

   There is no need to use these functions directly. You should
   use FSNode methods instead.


=item Next($node,[$top]), Prev($node,[$top])

 Params:

   $node - a reference to a tree hash-structure
   $top  - a reference to a tree hash-structure, containing
           the node referenced by $node

 Return:

   Reference to the next or previous node of $node on
   the backtracking way along the tree having its root in $top.
   The $top parameter is NOT obligatory and may be omitted.
   Return zero, if $top of root of the tree reached.

   There is no need to use this function directly. You should
   use B<FSNode->>B<following> method instead.

=item Cut($node)

 Params:

   $node - a reference to a node

  Description:

   Cuts (disconnets) $node from its parent and brothers

  Returns:

   $node


=item Paste($node,$newparent,$fsformat)

 Params:

   $node      - a reference to a (cutted or new) node
   $newparent - a reference to the new parent node
   $fsformat  - FSFormat object

 Description:

   connetcs $node to $newparent and links it
   with its new brothers, placing it to position
   corresponding to its numerical-argument value
   obtained via $fsformat->order.

 Returns $node

=item ImportBackends(@backends)

 Params:

   @backends  - a list of backend names

 Description:

   Demand to load the given backends and return a list of
   backends for which the demand was fulfilled. These
   backends may then be freely used in FSFile IO calls.

=item NODES AND TREES

 Description:

 A node a B<FSNode> object, which in turn is a usual Perl hash
 reference. It's keys are names of the node's attributes and it's
 values are their respective values. Four special keys (defined as
 global variables) are reserved for representing the tree structure.
 These are namely $parent, $firstson, $rbrother, and $lbrother.
 Thus $node->{$parent} is the parent-node of $node,
 $node->{$firstson} is the first of its child-nodes,
 $node->{$rbrother} and $node->{$lbrother} are
 it's right and left sibling-node, respectively.

=back

=cut
