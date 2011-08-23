#
# Revision: $Id: Fslib.pm 3044 2007-06-08 17:47:08Z pajas $

# See the bottom of this file for the POD documentation. Search for the
# string '=head'.

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# Several Perl Routines to handle files in treebank FS format
# See complete help in POD format at the end of this file

package Fslib;
use Carp;
use strict;
use warnings;

use Treex::PML;
use Treex::PML::IO;
use Treex::PML::Node;
use Treex::PML::FSFormat;
use Treex::PML::Document;
use Treex::PML::Backend::FS;
use Treex::PML::Schema;
use Treex::PML::Instance;
use Treex::PML::Backend::PML;
use PMLSchema;
use IOBackend;

# import everything from PML here:
BEGIN {
  no strict qw(refs);
  # Treex::PML namespace will be extended here, so we alias individual entries instead
  for my $k (grep { !/^(?:EXPORT|EXPORT_OK|ISA|.*::)/ } keys %{"Treex::PML::"}) {
    if ($k =~ /^(resourcePathSplit|resourcePath|Debug)$/ and defined ${__PACKAGE__."::$k"}) {
      my $value = ${__PACKAGE__."::$k"};
      *{__PACKAGE__."::$k"} = *{"Treex::PML::$k"};
      ${"Treex::PML::$k"} = $value;
    } else {
      *{__PACKAGE__."::$k"} = *{"Treex::PML::$k"};
    }
    for my $var (qw(parent firstson lbrother rbrother TYPE)) {
      my $name =qq{Treex::PML::Node::$var};
      *{lc($var)} = \$$name ;
    }
  }
  # Package aliasing
  my %alias = (
    "FSBackend" => "Treex::PML::Backend::FS",
    "PMLBackend" => "Treex::PML::Backend::PML",
   );
  while (my ($k,$v) = each %alias) {
    my $path = $v; $path =~ s{::}{/}g;
    *{$k.'::'} = \*{$v.'::'}; # namespace alias
    $INC{$k.'.pm'} ||= $INC{$path.'.pm'}; # pretend the aliased module to be loaded
  }

  my %derive = (
    "FSNode"    => "Treex::PML::Node",
    "FSFormat"  => "Treex::PML::FSFormat",
    "PMLInstance" => "Treex::PML::Instance",
    "Fslib::Struct" => "Treex::PML::Struct",
    "Fslib::List" => "Treex::PML::List",
    "Fslib::Alt" => "Treex::PML::Alt",
    "Fslib::Seq" => "Treex::PML::Seq",
    "Fslib::Schema" => "Treex::PML::Schema",
    "Fslib::Container" => "Treex::PML::Container",
    "Fslib::Attribute" => "Treex::PML::Attribute",
  );
  while (my ($k,$v) = each %derive) {
  	foreach my $name (keys %{$v.'::'}) {
      if ($name eq 'ISA') {
      	@{$k.'::ISA'}=@{$v.'::ISA'};
      } else {
      	${$k.'::'}{$name} = ${$v.'::'}{$name}; # namespace copy
      }
  	}
    *{$k.'::DOES'}=sub {
      my ($self,$role)=@_;
      return 1 if ($role||'') eq $v or ($role||'') eq $k;
      return $self->SUPER::DOES($role);
    };
    my $path = $v; $path =~ s{::}{/}g;
    $INC{$k.'.pm'} ||= $INC{$path.'.pm'}; # pretend the aliased module to be loaded
  }
}

use strict;
use vars qw(@EXPORT @EXPORT_OK @ISA);
use Exporter;
use File::Spec;
use Carp;
use URI;
use URI::file;

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT = qw/&Next &Prev &DeleteLeaf &Cut &ImportBackends/;
  @EXPORT_OK = qw/$FSError &Index &SetParent &SetLBrother &SetRBrother &SetFirstSon &Paste &Parent &LBrother &RBrother &FirstSon ResourcePaths FindInResources FindInResourcePaths FindDirInResources FindDirInResourcePaths ResolvePath &CloneValue AddResourcePath AddResourcePathAsFirst SetResourcePaths RemoveResourcePath /;

  *ReadLine = \&Treex::PML::FSFormat::_ReadLine;
  *ReadEscapedLine = \&Treex::PML::FSFormat::_ReadEscapedLine;
}

package FSFile;
use strict;
use warnings;
use base qw(Treex::PML::Document);
sub readFrom {
  my ($self,$fileref) = @_;
  return unless ref($self);

  my $ret=Treex::PML::Backend::FS::read($fileref,$self);
  $self->notSaved(0);
  return $ret;
}

package Fslib::Factory;

use strict;
use warnings;
use base qw(Treex::PML::StandardFactory);

sub createPMLSchema {
  my $self = shift;
  return PMLSchema->new(@_);
}

sub createPMLInstance {
  my $self = shift;
  if (@_) {
    return $self->createPMLInstance()->load(@_);
  } else {
    return PMLInstance->new();
  }
}

sub createDocument {
  my $self = shift;
  return FSFile->new(@_);
}

sub createFSFormat {
  my $self = shift;
  return FSFormat->new(@_);
}

sub createNode {
  my $self=shift;
  return FSNode->new(@_);
}

sub createList {
  my $self=shift;
  return @_>0 ? Fslib::List->new_from_ref(@_) : Fslib::List->new();
}
sub createAlt {
  my $self=shift;
  return @_>0 ? Fslib::Alt->new_from_ref(@_) : Fslib::Alt->new();
}
sub createSeq {
  my $self=shift;
  return Fslib::Seq->new(@_);
}
sub createContainer {
  my $self=shift;
  return Fslib::Container->new(@_);
}
sub createStructure {
  my $self=shift;
  return Fslib::Struct->new(@_);
}

unless ($ENV{NO_FS_CLASSES}) {
  Carp::carp("Turning on Fslib.pm compatibility mode; deprecated Fslib classes will be created by default.\n".
       "Hint: Set env NO_FS_CLASSES=1 or avoid calling 'require Fslib'");
  __PACKAGE__->make_default();
}

package Fslib::Type;
use Carp;
use warnings;
use strict;
use vars qw($AUTOLOAD);
# This is an obsoleted wrapper class for a schema type declarations.
sub new {
  my ($class, $schema, $type)=@_;
  return bless [$schema,$type], $class;
}
sub schema {
  my ($self)=@_;
  return $self->[0];
}
sub type_decl {
  my ($self)=@_;
  return $self->[1];
}
# delegate every method to the type
sub AUTOLOAD {
  my $self = shift;
  croak "$self is not an object" unless ref($self);
  my $name = $AUTOLOAD;
  $name =~ s/.*://;   # strip fully-qualified portion
  return $self->[1]->$name(@_);
}

package FSNode;
no warnings qw(redefine);
sub type {
  my ($self,$attr) = @_;
  my $type = $self->{$FSNode::TYPE};
  if (defined $attr and length $attr) {
    return $type ? $type->find($attr,1) : undef;
  } elsif (ref($type) eq 'Fslib::Type') {
    # pushing backward compatibility forward
    my $decl = $type->type_decl;
      return UNIVERSAL::DOES::does($decl,'Treex::PML::Schema::Decl') ? $decl : $type;
  } else {
    return $type;
  }
}

package Fslib::Schema;

sub DOES {
  my ($self,$role)=@_;
  return 1 if ($role||'') eq 'Treex::PML::Schema' or ($role||'') eq __PACKAGE__;
  return $self->SUPER::DOES($role);
};


1;


1;

__END__

=head1 NAME

Fslib - compatibility module, use Treex::PML for new projects instead!

=head1 DESCRIPTION

DEPRECATED!

This module is provided for backward compatibility only. Please use
Treex::PML instead!

The module defines Fslib and FSFile (almost by importing/deriving from
Treex::PML and Treex::PML::Document) and provides the following
package aliasing:

    FSNode           => Treex::PML::Node
    FSFormat         => Treex::PML::FSFormat
    FSBackend        => Treex::PML::Backend::FS
    IOBackend        => Treex::PML::IO
    PMLBackend       => Treex::PML::Backend::PML
    PMLSchema        => Treex::PML::Schema
    PMLInstance      => Treex::PML::Instance

    Fslib::Struct    => Treex::PML::Struct
    Fslib::List      => Treex::PML::List
    Fslib::Alt       => Treex::PML::Alt
    Fslib::Seq       => Treex::PML::Seq
    Fslib::Container => Treex::PML::Container
    Fslib::Attribute => Treex::PML::Attribute

To force creation of objects from the old Fslib family of classes
(left) rather than from the new Treex::PML family (right) in factory
calls, set the environment variable FORCE_FS_CLASSES to 1 or call

	Fslib::Factory->make_default();

=head1 PORTING TO Treex::PML

In order to port code using the old Fslib interfaces to Treex::PML, one has to do the following steps:

=over 5

=item *

Replace 'use Fslib' with 'use Treex::PML'.

=item *

Replace 'use OldClass' with 'use NewClass' according to the package
aliasing map given above.

=item *

Replace all explicit calls to constructors with calls to the
Treex::PML::Factory creators. Here are the rules:

  FSFile->newFSFile($filename,$enc,\@backends)
    --> Treex::PML::Factory->createDocumentFromFile($filename,{
          encoding=>$enc,
          backends=>\@backends
        })

  FSFile->load($filename,{...}) --> Treex::PML::Factory->createDocumentFromFile($filename,{encoding=>$enc,{...})

  FSFile->new() --> Treex::PML::Factory->createDocument()

  FSFile->create({...}) --> Treex::PML::Factory->createDocument({...})

  FSNode->new(...); $node->set_type($type)
     --> Treex::PML::Factory->createTypedNode($type,...)

  FSNode->new(...); $node->set_type_by_name($schema,$type_name);
     --> Treex::PML::Factory->createTypedNode($type_name,$schema,...)

  FSNode->new(...)
     --> Treex::PML::Factory->createNode(...)

  Fslib::Struct->new(...)
     --> Treex::PML::Factory->createStructure(...)

  Fslib::Seq->new(...)
     --> Treex::PML::Factory->createSeq(...)

  Fslib::Container->new(...)
     --> Treex::PML::Factory->createContainer(...)

  Fslib::List->new(@array)
     --> Treex::PML::Factory->createList(\@array)
     or
     --> Treex::PML::Factory->createList([@array],1)

  Fslib::List->new_from_ref($array_ref,$reuse)
     --> Treex::PML::Factory->createList($array_ref,$reuse)

  Fslib::Alt->new(@array)
     --> Treex::PML::Factory->createAlt(\@array)
     or
     --> Treex::PML::Factory->createAlt([@array],1)

  Fslib::Alt->new_from_ref($array_ref,$reuse)
     --> Treex::PML::Factory->createAlt($array_ref,$reuse)


  PMLInstance->new()
     --> Treex::PML::Factory->createPMLInstance(...)

  PMLInstance->load(...)
     --> Treex::PML::Factory->createPMLInstance(...)


  PMLSchema->new()
     --> Treex::PML::Factory->createPMLSchema(...)

  PMLSchema->load(...)
     --> Treex::PML::Factory->createPMLSchema(...)

  FSFormat->create(@header)
     --> Treex::PML::Factory->createFSFormat(\@header)

  FSFormat->new($hashRef)
     --> Treex::PML::Factory->createFSFormat($hashRef)

  FSFormat->readFrom(\@header)
     --> Treex::PML::Factory->createFSFormat(\@header)

  FSFormat->readFrom(FILEHANDLE)
     --> Treex::PML::Factory->createFSFormat(FILEHANDLE)

=item *

Replace calls like:

  UNIVERSAL::isa($object,'OldClass')
  $object->isa($object,'OldClass')
  ref($object) eq 'OldClass'

with

  Treex::PML::does($object,'NewClass');

or

  use UNIVERSAL::DOES;

  UNIVERSAL::DOES::does($object,'NewClass');

=item *

Replace calls to obsolete Fslib functions (possibly imported!) with
the corresponding object method calls.

This is how to rewrite the functions Fslib exported by default (note
that they may appear unqualified in user code):

  Next($node)       --> $node->following
  Prev($node)       --> $node->previous
  DeleteLeaf($node) --> $node->destroy_leaf
  Cut($node)        --> $node->cut()

This is how to rewrite calls to other Fslib functions (note that they
may therefore appear unqualified in the user code if they were
explicitly imported):

  Fslib::Paste($node,$parent,$ord)  --> $node->paste_on($parent,$ord)
  Fslib::Parent($node)              --> $node->parent
  Fslib::LBrother($node)            --> $node->lbrother
  Fslib::RBrother($node)            --> $node->rbrother
  Fslib::FirstSon($node)            --> $node->firstson

The following functions should never be used in code ported to
Treex::PML (use node methods paste_on(), paste_after(), and
paste_before() instead):

  Fslib::SetParent($node,$parent)     --> DON'T USE, $node->set_parent($parent) if you must!
  Fslib::SetLBrother($node,$brother)  --> DON'T USE, $node->set_lbrother($brother) if you must!
  Fslib::SetRBrother($node,$brother)  --> DON'T USE, $node->set_rbrother($brother) if you must!
  Fslib::SetFirstSon($node,$son)      --> DON'T USE, $node->set_firstson($son) if you must!

Although all these functions are also available in Treex::PML
(implementing the rewritten version according to the above rules),
none of them is exported by the Treex::PML module by default and it is
recommended to avoid them.

=item *

Replace remaining package function calls with new package function calls, i.e. rewrite

  OldClass::function(...);

to

  NewClass::function(...);

according to the aliasing map given above.

=back

=head1 SEE ALSO

L<Treex::PML>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

