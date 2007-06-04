# -*- cperl -*-
package PMLSchema;

require Fslib;
use Carp;
use strict;

=head1 PMLSchema

PMLSchema - Perl implements a PML schema.

=head2 DESCRIPTION

This class implements PML schemas. PML schema consists of a set of
type declarations of several kinds, represented by objects inheriting
from a common base class C<PMLSchema::Decl>.

=head3 Attribute Paths

Some methods use so called 'attribute paths' to navigate through
nested and referenced type declarations. An attribute path is a
'/'-separated sequence of steps, where step can be one of the
following:

=over 3

=item C<!>I<type-name>

'!' followed by name of a named type (this step can only occur
as the very first step

=item I<name>

name (of a member of a structure, element of a sequence or attribute
of a container), specifying the type declaration of the specified
named component

=item C<#content>

the string '#content', specifying the content type declaration
of a container

=item C<[]> 

specifying the type declaration of a list or alt member

=item C<[>I<NNN>C<]>

where I<NNN> is a decimal number (ignored), which is an equivalent of []

=back

Steps of the form [] (except when occuring at the end of an attribute
path) may be omitted.

=head2 EXPORT

This module exports constants for declaration types.

=head2 EXPORT TAGS

=over 3

=item :constants

Export constant symbols (exported by default, too).

=back

=head2 CONSTANTS

The following integer constants are provided and exported by default:

  PML_TYPE_DECL
  PML_ROOT_DECL
  PML_STRUCTURE_DECL
  PML_CONTAINER_DECL
  PML_SEQUENCE_DECL
  PML_LIST_DECL    
  PML_ALT_DECL     
  PML_CDATA_DECL   
  PML_CHOICE_DECL  
  PML_CONSTANT_DECL
  PML_ATTRIBUTE_DECL
  PML_MEMBER_DECL   
  PML_ELEMENT_DECL  

=cut

BEGIN {
  our $VERSION = '1.1';
  require Exporter;
  import Exporter qw(import);
  our @EXPORT = qw(
	       PML_TYPE_DECL
	       PML_ROOT_DECL
	       PML_STRUCTURE_DECL
	       PML_CONTAINER_DECL
	       PML_SEQUENCE_DECL
	       PML_LIST_DECL    
	       PML_ALT_DECL     
	       PML_CDATA_DECL   
	       PML_CHOICE_DECL  
	       PML_CONSTANT_DECL
	       PML_ATTRIBUTE_DECL
	       PML_MEMBER_DECL   
	       PML_ELEMENT_DECL
  );

  our %EXPORT_TAGS = ( 
    'constants' => [ @EXPORT ],
  );
}

use constant   PML_TYPE_DECL        =>  1;
use constant   PML_ROOT_DECL        =>  2;
use constant   PML_STRUCTURE_DECL   =>  3;
use constant   PML_CONTAINER_DECL   =>  4;
use constant   PML_SEQUENCE_DECL    =>  5;
use constant   PML_LIST_DECL        =>  6;
use constant   PML_ALT_DECL         =>  7;
use constant   PML_CDATA_DECL       =>  8;
use constant   PML_CHOICE_DECL      =>  9;
use constant   PML_CONSTANT_DECL    => 10;
use constant   PML_ATTRIBUTE_DECL   => 11;
use constant   PML_MEMBER_DECL      => 12;
use constant   PML_ELEMENT_DECL     => 13;


=head1 METHODS

=over 3

=item PMLSchema->new (string)

Parses a given XML representation of the schema and returns a new
C<PMLSchema> instance.

=cut

sub new {
  my ($self,$string,$opts)=@_;
  my $class = ref($self) || $self;
  if ($opts) {
    croak "Usage: ".__PACKAGE__."->new(string,{ param => value,...})" unless UNIVERSAL::isa($opts,'HASH');
  } else {
    $opts={}
  }
  my @xml_simple_opts = (
    ForceArray=>[ 'delete', 'member', 'element', 'attribute', 'value', 'reference', 'type', 'derive', 'import', 'import_type' ],
    KeyAttr => { "member"    => "-#name",
		 "attribute" => "-#name",
		 "element"   => "-#name",
		 "type"      => "-#name",
	       },
# 		 "alt" => '>',
# 		 "list" => '>',
# 		 "sequence" => '>',
# 		 "choice" => '>',
# 		 "structure" => '>',
# 		 "container" => '>',
# 		},
    GroupTags => { "choice" => "value" },
    NSExpand=>1, 
    DefaultNS => "http://ufal.mff.cuni.cz/pdt/pml/schema/",
   );
  my $new;
  eval {
    require XML::IxSimple;
    $XML::IxSimple::PREFERRED_PARSER = 'XML::LibXML::SAX';
    $new = bless XML::IxSimple::XMLin($string,@xml_simple_opts), $class;
  };

  if ($@) {
    croak "Error occured when parsing PML schema ".$opts->{filename}.": $@";
  }
  $new->{URL} = $opts->{filename} || '<string>';
  $new->check_revision($opts);

  
  $opts->{schemas} = {} unless (ref($opts->{schemas}));
  my $schemas = $opts->{schemas};

  # apply imports
  my $imports = delete $new->{import};
  if (ref($imports)) {
    foreach my $import (@$imports) {
      if (exists($import->{type})) {
	my $schema = $class->readFrom($import->{schema},
				      { %$opts,
					imported => 1,
					base_url => $new->{URL},
					(map {
					  if (exists($import->{$_})) {
					    $_ => $import->{$_} 
					  }
					} qw(revision minimal_revision maximal_revision)),
					revision_error => "Error importing type '$import->{type}' from schema %f to $new->{URL} - revision mismatch: %e"
					      });
	$schemas->{ $schema->{URL} } = $schema;
	my $name = $import->{type};
	if (ref($schema->{type})) {
	  $new->_import_type($schema,$name);
	}
      } else {
	my $schema = $class->readFrom($import->{schema} ,{ %$opts, 
							   imported => 1,
							   base_url => $new->{URL},
							   (map {
							     if (exists($import->{$_})) {
								      $_ => $import->{$_} 
								    }
								  } qw(revision minimal_revision maximal_revision)),
								  revision_error => "Error importing schema %f to $new->{URL} - revision mismatch: %e",
								});
	$schemas->{ $schema->{URL} } = $schema;
	if (!exists($new->{root}) and $schema->{root}) {
	  $new->{root} = Fslib::CloneValue($schema->{root});
	}
	if (ref $schema->{type}) {
	  $new->{type}={} unless $new->{type};
	  foreach my $name (keys(%{$schema->{type}})) {
	    unless (exists $new->{type}{$name}) {
	      $new->{type}{$name}=Fslib::CloneValue($schema->{type}{$name});
	    }
	  }
	}
      } 
    }
  }
  $new->_derive();
  $new->convert_from_hash() if !$opts->{imported};
  return $new;
}


=item PMLSchema->readFrom (filename,opts)

Reads schema from a given XML file and returns a new C<PMLSchema>
object.

The 2nd argument, C<opts>, is an optional hash reference with parsing
options.  The following options are recognized:

C<base_url> - base URL for referred schemas.

C<use_resources> - if true, reffered schemas are also looked for in L<Fslib> resource paths.

C<revision>, C<minimal_revision>, C<maximal_revision> - constraint the revision
number of the schema.

=cut

sub readFrom {
  my ($self,$file,$opts)=@_;
  if ($opts) {
    croak "Usage: ".__PACKAGE__."->new(string,{ param => value,...})" unless UNIVERSAL::isa($opts,'HASH');
  } else {
    $opts={}
  }
  if ($opts->{base_url} ne "") {
    $file = Fslib::ResolvePath($opts->{base_url},$file,$opts->{use_resources});
  } elsif ($opts->{use_resources}) {
    $file = Fslib::FindInResources($file);
  }
  my $schema;
  if (ref $opts->{schemas}{$file}) {
    print STDERR "schema $file already hashed\n" if $Fslib::Debug;
    $schema = $opts->{schemas}{$file};
    $schema->check_revision($opts);
  } else {
    print STDERR "parsing schema $file\n" if $Fslib::Debug;
    my $fh = eval { IOBackend::open_uri($file) };
    croak "Couldn't open PML schema file '$file'\n".$@ if (!$fh || $@);
    local $/;
    my $slurp = <$fh>;
    IOBackend::close_uri($fh);
    $schema = $self->new($slurp,{ %$opts, filename => $file });
    print STDERR "schema ok\n"  if $Fslib::Debug;
  }
  return $schema;
}

=item $schema->get_url ()

Return location of the PML schema file.

=cut

sub get_url                  { return $_[0]->{URL};           }

=item $schema->get_version ()

Return PML version the schema conforms to.

=cut

sub get_pml_version          { return $_[0]->{version};       }


=item $schema->get_revision ()

Return PML schema revision.

=cut

sub get_revision             { return $_[0]->{revision};      }

=item $schema->get_description ()

Return PML schema description.

=cut

sub get_description          { return $_[0]->{description};   }

=item $schema->get_root_decl ()

Return the root type declaration (see C<PMLSchema::Root>).

=cut

sub get_root_decl            { return $_[0]->{root};          }

=item $schema->get_root_type ()

Like $schema->get_root_decl->get_content_decl.

=cut

sub get_root_type {
  my ($self,$name) = @_;
  return $self->{root}->get_content_decl;
}
*get_root_type_obj = \&get_root_type;


sub _internal_api_version    { return $_[0]->{'-api_version'} }

=item $schema->get_root_name ()

Return name of the root element for PML instance.

=cut

sub get_root_name { 
  my $root = $_[0]->{root}; 
  return $root ? $root->{name} : undef; 
}

=item $schema->get_type_names ()

Return names of all named type declarations.

=cut

sub get_type_names { 
  my $types = $_[0]->{type};
  return $types ? keys(%$types) : ();
}

=item $schema->get_named_reference_info (name)

This method retrieves information about a specific named instance
reference as a hash (currently with keys 'name' and 'readas').

=cut

sub get_named_reference_info {
  my ($self, $name) = @_;
  if ($self->{reference}) {
    return { map { %$_ } grep { $_->{name} eq $name } @{$self->{reference}} };
  }
}

sub find_named_type_uses { die "NOT YET IMPLEMENTED" }

# compare schema revision number with a given revision number
sub _match_revision {
  my ($self,$revision)=@_;
  my $my_revision=$self->{revision} || 0;

  my @my_revision = split(/\./,$my_revision);
  my @revision = split(/\./,$revision);
  my $cmp;
  while ($cmp==0 and (@my_revision or @revision)) {
    $cmp = (shift(@my_revision) <=> shift(@revision));
  }
  return $cmp;
}

# for internal use only
sub _resolve_type {
  my ($self,$type)=@_;
  return $type unless ref($type);
  my $ref = $type->{type};
  if ($ref) {
    my $rtype = $self->{type}{$ref};
    if (ref($rtype)) {
      return $rtype;
    } else {
      # couldn't resolve
      warn "No declaration for type '$type->{type}' in schema '".$self->get_url."'\n";
      return $type->{type};
    }
  } else {
    return $type;
  }
}


# traverse type data structure and collect types referred via
# type="type-name" declarations in the refferred hash
sub _get_referred_types {
  my ($self,$type,$referred) = @_;
  if (ref($type)) {
    if (UNIVERSAL::isa($type,'HASH')) {
      if ($type->{type} ne "" and !exists($referred->{$type->{type}})) {
	# this type declaration reffers to another type - get it
	my $resolved = $self->_resolve_type($type);
	$referred->{$type->{type}} = $resolved;
	$self->_get_referred_types($resolved,$referred);
      } else {
	# traverse descendant type declarations
	if (ref $type->{member}) {
	  foreach (values %{$type->{member}}) {
	    $self->_get_referred_types($_,$referred);
	  }
	} elsif (ref $type->{attribute}) {
	  foreach (values %{$type->{attribute}}) {
	    $self->_get_referred_types($_,$referred);
	  }
	} elsif (ref $type->{element}) {
	  foreach (values %{$type->{element}}) {
	    $self->_get_referred_types($_,$referred);
	  }
	} elsif (exists $type->{list}) {
	  $self->_get_referred_types($type->{list},$referred);
	} elsif (exists $type->{alt}) {
	  $self->_get_referred_types($type->{alt},$referred);
	} elsif (exists $type->{structure}) {
	  $self->_get_referred_types($type->{structure},$referred);
	} elsif (exists $type->{container}) {
	  $self->_get_referred_types($type->{container},$referred);
	} elsif (exists $type->{sequence}) {
	  $self->_get_referred_types($type->{sequence},$referred);
	} elsif (exists $type->{element}) {
	  $self->_get_referred_types($type->{element},$referred);
	}
      }
    } elsif (UNIVERSAL::isa($type,'ARRAY')) {
      foreach (@$type) {
	$self->_get_referred_types($_,$referred);
      }
    }
  }
}

# import given named type and all named types it requires
# from src_schema into the current schema (self)
sub _import_type {
  my ($self,$src_schema, $name) = @_;
  unless (exists $src_schema->{type}{$name}) {
    croak "Cannot import type '$name' from '$src_schema->{URL}' to '$self->{URL}': type not declared in the source schema\n";
  }
  my $type = $src_schema->{type}{$name};
  my %referred = ($name => $type);
  $src_schema->_get_referred_types($type,\%referred);
  foreach my $n (keys %referred) {
    unless (exists $self->{type}{$n}) {
      $self->{type}{$n}=Fslib::CloneValue($referred{$n});
    }
  }
}

sub _derive {
  my ($self)=@_;
  my $derives = delete $self->{derive};
  if (ref $derives) {
    foreach my $derive (@$derives) {
      my $name = $derive->{name};
      my $type;
      my $source = $derive->{type};
      if ($source eq "") {
	croak "Derive must specify source type in the attribute 'type' in $self->{URL}\n";
      }
      if ($name ne "") {
	if (exists ($self->{type}{$name})) {
	  croak "Refusing to derive already existing type '$name' from '$source' in $self->{URL}\n";
	}
	$type = $self->{type}{$name} = Fslib::CloneValue($self->{type}{$source});
      } else {
	$name = $source;
	$type = $self->{type}{$name};
      }
      # deriving possible for structures, sequences and choices
      if ($derive->{structure}) {
	if ($type->{structure}) {
	  my $new_structure = $derive->{structure};
	  my $orig_structure = $type->{structure};
	  foreach my $attr (qw(role name)) {
	    $orig_structure->{$attr} = $new_structure->{$attr} if exists $new_structure->{$attr};
	  }
	  $orig_structure->{member} ||= {};
	  my $members = $orig_structure->{member};
	  while (my ($member,$value) = each %{$new_structure->{member}}) {
	    $members->{$member} = Fslib::CloneValue($value); # FIXME: no need if we remove derives in the end
	  }
	  if (ref $new_structure->{delete}) {
	    for my $member (@{$new_structure->{delete}}) {
	      delete $members->{$member};
	    }
	  }
	} else {
	  croak "Cannot derive structure type '$name' from a non-structure '$source'\n";
	}
      } elsif ($derive->{sequence}) {
	if ($type->{sequence}) {
	  my $new_sequence = $derive->{sequence};
	  my $orig_sequence = $type->{sequence};
	  $orig_sequence->{role} = $new_sequence->{role} if exists $new_sequence->{role};
	  $new_sequence->{element} ||= {};
	  my $elements = $orig_sequence->{element};
	  while (my ($element,$value) = each %{$new_sequence->{element}}) {
	    $elements->{$element} = Fslib::CloneValue($value); # FIXME: no need if we remove derives in the end
	  }
	  if (ref $new_sequence->{delete}) {
	    for my $element (@{$new_sequence->{delete}}) {
	      delete $elements->{$element};
	    }
	  }
	} else {
	  croak "Cannot derive structure type '$name' from a non-structure '$source'\n";
	}
      } elsif ($derive->{container}) {
	if ($type->{container}) {
	  my $new_sequence = $derive->{container};
	  my $orig_sequence = $type->{container};
	  $orig_sequence->{role} = $new_sequence->{role} if exists $new_sequence->{role};
	  $new_sequence->{attribute} ||= {};
	  my $attributes = $orig_sequence->{attribute};
	  while (my ($attribute,$value) = each %{$new_sequence->{attribute}}) {
	    $attributes->{$attribute} = Fslib::CloneValue($value); # FIXME: no need if we remove derives in the end
	  }
	  if (ref $new_sequence->{delete}) {
	    for my $attribute (@{$new_sequence->{delete}}) {
	      delete $attributes->{$attribute};
	    }
	  }
	} else {
	  croak "Cannot derive a container '$name' from a different type '$source'\n";
	}
      } elsif ($derive->{choice}) {
	my $choice = $derive->{choice};
	if ($type->{choice}) {
	  my (@add,%delete);
	  if (UNIVERSAL::isa($choice,'HASH')) {
	    @add = @{$choice->{value}} if ref $choice->{value};
	    @delete{ @{$choice->{delete}} }=() if ref $choice->{delete};
	  } else {
	    @add = @$choice;
	  }
	  my %seen;
	  @{$type->{choice}} =
	    grep { !($seen{$_}++) and ! exists $delete{$_} } (@{$type->{choice}},@add);
	} else {
	  croak "Cannot derive a choice type '$name' from a non-choice type '$source'\n";
	}
      } else {
	unless ($name ne $source) {
	  croak "<derive type='$source'> has no effect in $self->{URL}\n";
	}
      }
    }
  }
}

sub __fmt {
  my ($string,$fmt) =@_;
  $string =~ s{%(.)}{ $1 eq "%" ? "%" : 
			exists($fmt->{$1}) ? $fmt->{$1} : "%$1" }eg;
  return $string;
}

sub check_revision {
  my ($self,$opts)=@_;

  my $error = $opts->{revision_error} || 'Error: wrong schema revision of %f: %e';
  if ($opts->{revision} and
	$self->_match_revision($opts->{revision})!=0) {
    croak(__fmt($error, { 'e' => "required $opts->{revision}, got $self->{revision}",
			  'f' => $self->{URL}}));
  } else {
    if ($opts->{minimal_revision} and
	  $self->_match_revision($opts->{minimal_revision})<0) {
      croak(__fmt($error, { 'e' => "required at least $opts->{minimal_revision}, got $self->{revision}",
			    'f' => $self->{URL}}));
    }
    if ($opts->{maximal_revision} and
	  $self->_match_revision($opts->{maximal_revision})>0) {
      croak(__fmt($error, { 'e' => "required at most $opts->{maximal_revision}, got $self->{revision}",
			    'f' => $self->{URL}}));
    }
  }
}

sub convert_from_hash {
  my $class = shift;
  my $schema_hash;
  if (ref($class)) {
    $schema_hash = $class;
    $class = ref( $schema_hash );
  } else {
    $schema_hash = shift;
    bless $schema_hash,$class;
  }
  $schema_hash->{-api_version} = '1.0';
  my $root = $schema_hash->{root};
  if (defined($root)) {
    bless $root, 'PMLSchema::Root';
    PMLSchema::Decl->convert_from_hash($root, 
				  $schema_hash,
				  undef  # path = '' for root
				 );
  }
  my $types = $schema_hash->{type};
  if ($types) {
    my ($name, $decl);
    while (($name, $decl) = each %$types) {
      bless $decl, 'PMLSchema::Type';
      PMLSchema::Decl->convert_from_hash($decl, 
				    $schema_hash,
				    '!'.$name
				   );
    }
  }
  return $schema_hash;
}


=item $schema->find_type_by_path (attribute-path,noresolve,decl)

Locate a declaration specified by C<attribute-path> starting from
declaration C<decl>. If C<decl> is undefined the root type declaration
is used. (Note that attribute paths starting with '/' are always
evaluated startng from the root declaration and paths starting with
'!' followed by a name of a named type are evaluated starting from
that type.) All references to named types are transparently resolved
in each step.

The caller should pass a true value in C<noresolve> to enforce Member,
Attribute, Element, Type, or Root declaration objects to be returned
rather than declarations of their content.

Attribute path is a '/'-separated sequence of steps (member,
attribute, element names or strings matching [\d*]) which identifying
a certain nested type declaration. A step of the aforementioned form
[\d*] is match the content declaration of a List or Alt. Note however, that
named stepsdive into List or Alt declarations automatically, too.

=cut

sub find_type_by_path {
  my ($schema, $path, $noresolve, $decl) = @_;
  if ($path ne '') {
    if ($path=~s{^!([^/]+)/?}{}) {
      $decl = $schema->get_type_by_name($1);
      if ($decl) {
	$decl = $decl->get_content_decl;
      } else {
	return;
      }
    } elsif ($path=~s{^/}{} or !$decl) {
      $decl = $schema->get_root_decl->get_content_decl;
    }
    for my $step (split /\//, $path,-1) {
      if (ref($decl)) {
	my $decl_is = $decl->get_decl_type;
	if ($decl_is == PML_ATTRIBUTE_DECL ||
	    $decl_is == PML_MEMBER_DECL ||
            $decl_is == PML_ELEMENT_DECL ||
            $decl_is == PML_TYPE_DECL ) {
	  $decl = $decl->get_knit_content_decl;
	  next if ($step eq q{});
	  redo;
	}
	if ($decl_is == PML_LIST_DECL ||
	    $decl_is == PML_ALT_DECL ) {
	  $decl = $decl->get_knit_content_decl;
	  next if ($step =~ /^\[\d*\]/);
	  redo;
	}
	if ($decl_is == PML_STRUCTURE_DECL) {
	  my $member = $decl->get_member_by_name($step);
	  if ($member) {
	    $decl = $member;
	  } else {
	    $member = $decl->get_member_by_name($step.'.rf');
	    return unless $member;
	    if ($member->get_knit_name eq $step) {
	      $decl = $member;
	    } else {
	      return;
	    }
	  }
	} elsif ($decl_is == PML_CONTAINER_DECL) {
	  if ($step eq '#content') {
	    $decl = $decl->get_content_decl;
	    next;
	  }
	  my $attr = $decl->get_attribute_by_name($step);
	  $decl =  $attr;
	} elsif ($decl_is == PML_SEQUENCE_DECL) {
	  $decl = $decl->get_element_by_name($step);
	} elsif ($decl_is == PML_ROOT_DECL) {
	  if ($step eq $decl->get_name or $step eq q{}) {
	    $decl = $decl->get_content_decl;
	  } else {
	    return;
	  }
	} else {
	  return;
	}
      } else {
#	warn "Can't follow type path '$path' (step '$step')\n";
	return(undef); # ERROR
      }
    }
  }
  my $decl_is = $decl->get_decl_type;
  return $noresolve ? $decl :
    $decl && (
	      $decl_is == PML_ATTRIBUTE_DECL ||
	      $decl_is == PML_MEMBER_DECL ||
	      $decl_is == PML_ELEMENT_DECL ||
	      $decl_is == PML_TYPE_DECL ||
              $decl_is == PML_ROOT_DECL
	     )
      ? ($decl->get_knit_content_decl) : $decl;
}


=item $schema->find_role (role,decl,opts)

Return a list of attribute paths leading to nested type declarations
of C<decl> with role equal to C<role>. If C<decl> is not specified,
the root type declaration is assumed.

In array context return all matching nested declarations are
returned. In scalar context only the first one is returned (with early
stopping).

The last argument C<opts> can be used to pass some flags to the
algorithm. Currently only the flag C<no_childnodes> is available. If
true, then the function never recurses into content declaration of
declarations with the role #CHILDNODES.

=cut

sub find_role {
  my ($self, $role, $decl, $opts)=@_;
  $decl ||= $self->{root};
  my $first = not(wantarray);
  my @res = grep { defined } $self->_find_role($decl,$role,$first,{},$opts);
  return $first ? $res[0] : @res;
}

sub _find_role {
  my ($self, $decl, $role, $first, $cache, $opts)=@_;

  my @result = ();  

  return () unless ref $decl;

  if ($cache->{'#RECURSE'}{ $decl }) {
    return ()
  }
  local $cache->{'#RECURSE'}{ $decl } = 1;

  if ( ref $opts and $opts->{no_childnodes} and $decl->{role} eq '#CHILDNODES') {
    return ();
  }

  if ( $decl->{role} eq $role ) {
    if ($first) {
      return '';
    } else {
      push @result, '';
    }
  }
  my $type_ref = $decl->get_type_ref;
  my $decl_is = $decl->get_decl_type;
  if ($type_ref) {
    my $cached = $cache->{ $type_ref };
    unless ($cached) {
      $cached = $cache->{ $type_ref } = [ $self->_find_role( $self->get_type_by_name($type_ref),
							     $role, $first, $cache, $opts ) ];
    }
    if ($decl_is == PML_CONTAINER_DECL) {
      push @result,  map { $_ ne '' ? '#content/'.$_ : '#content' } @$cached;
    } elsif ($decl_is == PML_LIST_DECL ||
	     $decl_is == PML_ALT_DECL) {
      push @result, map { $_ ne '' ? '[]/'.$_ : '[]' } @$cached;
    } else {
      push @result, @$cached;
    }
    return $result[0] if ($first and @result);
  }
  if ($decl_is == PML_STRUCTURE_DECL) {
    foreach my $member ($decl->get_members) {
      my @res = map { $_ ne '' ? $member->get_name.'/'.$_ : $member->get_name }
	$self->_find_role($member, $role, $first, $cache, $opts);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
  } elsif ($decl_is == PML_CONTAINER_DECL) {
    my $cdecl = $decl->get_content_decl;
    foreach my $attr ($decl->get_attributes) {
      my @res = map { $_ ne '' ? $attr->get_name.'/'.$_ : $attr->get_name }
	$self->_find_role($attr, $role, $first, $cache, $opts);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
    if ($cdecl) {
      push @result,  map { $_ ne '' ? '#content/'.$_ : '#content' } 
	$self->_find_role($cdecl, $role, $first, $cache, $opts);
      return $result[0] if ($first and @result);
    }
  } elsif ($decl_is == PML_SEQUENCE_DECL) {
    foreach my $element ($decl->get_elements) {
      my @res = map { $_ ne '' ? $element->get_name.'/'.$_ : $element->get_name }
	$self->_find_role($element, $role, $first, $cache, $opts);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
  } elsif ($decl_is == PML_LIST_DECL ||
	   $decl_is == PML_ALT_DECL ) {
    push @result, map { $_ ne '' ? '[]/'.$_ : '[]' } 
      $self->_find_role($decl->get_content_decl, $role, $first, $cache, $opts);
  } elsif ($decl_is == PML_TYPE_DECL ||
	   $decl_is == PML_ROOT_DECL ||
           $decl_is == PML_ATTRIBUTE_DECL ||
           $decl_is == PML_MEMBER_DECL ||
	   $decl_is == PML_ELEMENT_DECL ) {
    push @result, $self->_find_role($decl->get_content_decl, $role, $first, $cache, $opts);
  }
  my %uniq;
  return $first ? (@result ? $result[0] : ()) 
    : grep { !$uniq{$_} && ($uniq{$_}=1) } @result;
}

=item $schema->node_types ()

Return a list of all type declarations with the role C<#NODE>.

=cut

sub node_types {
  my ($self) = @_;
  my @result;
  return map { $self->find_type_by_path($_) } $self->find_role('#NODE');
}



=item $schema->get_type_by_name (name)

Return the declaration of the named type with a given name (see
C<PMLSchema::Type>).

=cut

sub get_type_by_name {
  my ($self,$name) = @_;
  return $self->{type}{$name};
}
*get_type_by_name_obj = \&get_type_by_name;


# OBSOLETE: for backward compatibility only
sub type {
  my ($self,$decl)=@_;
  if (UNIVERSAL::isa($decl,'PMLSchema::Decl')) {
    return $decl
  } else {
    return Fslib::Type->new($self,$decl);
  }
}

=item $schema->validate_object (object, type_decl, log)

Validates the data content of the given object against a specified
type declaration. The type_decl argument must either be an object
derived from the C<PMLSchema::Decl> class or the name of a named
type.

An array reference may be passed as the optional 3rd argument C<log>
to obtain a detailed report of all validation errors.

Returns: 1 if the content conforms, 0 otherwise.

=cut

sub validate_object { # (path, base_type)
  my ($schema, $object, $type,$log)=@_;
  if (defined $log and UNIVERSAL::isa('ARRAY',$log)) {
    croak "PMLSchema::validate_object: log must be an ARRAY reference";
  }
  $type ||= $schema->get_type_by_name($type);
  if (!ref($type)) {
    croak "PMLSchema::validate_object: Cannot determine data type";
  }
  return $type->validate_object($object,{log=>$log});
}


=item $schema->validate_field (object, attr-path, type, log)

This method is similar to C<validate_object>, but in this case the
validation is restricted to the data substructure of C<object>
specified by the C<attr-path> argument.

C<type> is the type of C<object> specified either by the name of a
named type, or as a Fslib::Type, or a type declaration.

An array reference may be passed as the optional 3rd argument C<log>
to obtain a detailed report of all validation errors.

Returns: 1 if the content conforms, 0 otherwise.

=cut

sub validate_field {
  my ($schema, $object, $path, $type, $log) = @_;
  if (defined $log and UNIVERSAL::isa('ARRAY',$log)) {
    croak "PMLSchema::validate_field: log must be an ARRAY reference";
  }
  if (!ref($type)) {
    my $named_type = $schema->get_type_by_name($type);
    croak "PMLSchema::validate_field: Cannot find type '$type'" 
      unless $named_type;
    $type = $named_type;
  }
  if ($path eq '') {
    return $type->validate_object($object, { log => $log });
  }
  $type = $type->find($path);
  croak "PMLSchema::validate_field: Cannot determine data type for attribute-path '$path'" unless $type;
  return 
    $type->validate_object(FSNode::attr($object,$path),{ path => $path, 
							 log=>$log 
							});
}

=back

=head1 CLASSES FOR TYPE DECLARATIONS

=cut

########################################################################
# PML Schema type declaration
########################################################################

package PMLSchema::Decl;

=head2 PMLSchema::Decl

PMLSchema::Decl - implements PML schema type declaration

=head3 DESCRIPTION

This is an abstract class from which all specific type declaration
classes inherit.

=cut

use Scalar::Util qw( weaken );
use Carp;
use PMLSchema;

=head3 METHODS

=over 3

=cut

sub new { croak("Can't create ".__PACKAGE__) }

# compatibility with old Fslib::Type

sub type_decl { return $_[0] };

=item $decl->get_schema () 

=item $decl->schema ()

Return C<PMLSchema> the declaration belongs to.

=cut

sub schema    { return $_[0]->{-schema} }
*get_schema = \&schema;

=item $decl->get_decl_type ()

Return the type of declaration as an integer constant (see
L</"CONSTANTS">).

=item $decl->get_decl_type_str ()

Return the type of declaration as string; one of: type, root,
structure, container, sequence, list, alt, cdata, choice, constant,
attribute, member, element.

=cut

sub get_decl_type     { return(undef); } # VIRTUAL
sub get_decl_type_str { return(undef); } # VIRTUAL

=item $decl->is_atomic ()

Return 1 if the declaration is of atomic type (cdata, choice,
constant), 0 if it is a structured type (structure, container,
sequence, list, alt), or undef, if it is an auxiliary declaration
(root, type, attribute, member, element).

=cut

sub is_atomic { croak "is_atomic(): UNKNOWN TYPE"; } # VIRTUAL

=item $decl->get_content_decl ()

For declarations with content (type, root, container, list, alt,
attribute, member, element), return the content declaration; return
undef for other declarations. This method transparently resolves
references to named types.

=cut

sub get_content_decl { 
  my $self = shift;
  my $no_resolve = shift;
  if ($self->{-decl}) {
    return $self->{ $self->{-decl} };
  } elsif (my $resolved = $self->{-resolved}) {
    return $resolved;
  } elsif (my $type_ref = $self->{type}) {
    my $schema = $self->{-schema};
    if ($schema) {
      my $type = $schema->{type}{ $type_ref };
      return $no_resolve ? $type 
	: $type ? 
	  ($self->{-resolved} = $type->get_content_decl)
	  : undef ;
    } else {
      croak "Declaration not associated with a schema";
    }
  }
  return(undef);
}

=item $decl->get_knit_content_decl ()

If the data type has a role '#KNIT', return a type declaration for the
knitted content (Note: PML 1.1.2 allows role '#KNIT' role on list,
element, and member declarations, but element knitting is not
currenlty implemented).

=cut


sub get_knit_content_decl {
  my $self = shift;
  return ($self->{role} eq '#KNIT') ?
    $self->get_type_ref_decl 
      : $self->get_content_decl;
}

=item $decl->get_type_ref ()

If the declaration has content and the content is specified via a
reference to a named type, return the name of the referred type.
Otherwise return undef.

=cut

sub get_type_ref {
  return $_[0]->{type};
}

=item $decl->get_type_ref_decl ()

Retrun content declaration object (if any), but only if it is
specified via a reference to a named type. In all other cases, return
undef.

=cut

sub get_type_ref_decl { 
  my $self = shift;
  my $no_resolve = shift;
  if (my $resolved = $self->{-resolved}) {
    return $resolved;
  } elsif (my $type_ref = $self->{type}) {
    my $schema = $self->{-schema};
    if ($schema) {
      my $type = $schema->{type}{ $type_ref };
      return $no_resolve ? $type 
	: $type ? 
	  ($self->{-resolved} = $type->get_content_decl)
	  : undef ;
    }
  }
  return(undef);
}

=item $decl->get_base_type_name ()

If the declaration is a nested (even deeply) part of a named type
declaration, return the name of that named type.

=cut

sub get_base_type_name {
  my $path = $_[0]->{-path};
  if ($path=~m{^!([^/]+)}) {
    return $1;
  } else {
    return(undef);
  }
}

=item $decl->get_parent_decl ()

If this declaration is nested, return its parent declaration.

=cut

sub get_parent_decl { return $_[0]->{-parent} }

=item $decl->get_decl_path ()

Return a cannonical attribute path leading to the declaration
(starting either at a named type or the root type declaration).

=cut

sub get_decl_path { return $_[0]->{-path};  }

=item $decl->get_role

If the declaration is associated with a role, return it.

=cut

sub get_role      { return $_[0]->{role}    }


sub traverse_decls    { die "NOT YET IMPLEMENTED" }

=item $decl->find (attribute-path,noresolve)

Locate a nested declaration specified by C<attribute-path> starting
from the current type. See C<$schema-E<gt>find_type_by_path> for details
about locating declarations.

=cut

sub find {
  my ($self, $path,$noresolve) = @_;
  # find node type
  my $type = $self->type_decl;
  return $self->schema->find_type_by_path($path,$noresolve,$type);
}

=item $decl->find_role (role, opts)

Search declarations with a given role nested within this declaration.
In scalar context, return the first declaration that matches, in array
context return all such declarations.

The last argument C<opts> can be used to pass some flags to the
algorithm. Currently only the flag C<no_children> is available. If
true, then the function never recurses into content declaration of
declarations with the role #CHILDNODES.

=cut

sub find_role {
  my ($self, $role, $opts) = @_;
  return $self->schema->find_role($role,$self->type_decl,$opts);
}

sub convert_from_hash {
  my ($class, $decl, $schema, $path) = @_;
  my $sub;
  my $decl_type;
  if ($sub = $decl->{structure}) {
    $decl_type = 'structure';
    bless $sub, 'PMLSchema::Struct';
    if (my $members = $sub->{member}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'PMLSchema::Member';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
  } elsif ($sub = $decl->{container}) {
    $decl_type = 'container';
    bless $sub, 'PMLSchema::Container';
    if (my $members = $sub->{attribute}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'PMLSchema::Attribute';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
    $class->convert_from_hash($sub, $schema, $path.'/#content');
  } elsif ($sub = $decl->{sequence}) {
    $decl_type = 'sequence';
    bless $sub, 'PMLSchema::Seq';
    if (my $members = $sub->{element}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'PMLSchema::Element';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
  } elsif ($sub = $decl->{list}) {
    $decl_type = 'list';
    bless $sub, 'PMLSchema::List';
    $class->convert_from_hash($sub, $schema, $path.'/[LIST]');
  } elsif ($sub = $decl->{alt}) {
    $decl_type = 'alt';
    bless $sub, 'PMLSchema::Alt';
    $class->convert_from_hash($sub, $schema, $path.'/[ALT]');
  } elsif ($sub = $decl->{choice}) {
    $decl_type = 'choice';
    # convert from an ARRAY to a hash
    if (ref($sub) eq 'ARRAY') {
      $sub = $decl->{choice} = bless { values => [
	                                 map { 
					   ref($_) eq 'HASH' ? $_->{content} : $_
                                         } @$sub
				       ],
				       data => {
	                                 map { 
					   ref($_) eq 'HASH' ? ($_->{content} => $_) : ($_ => {content=>$_})
                                         } @$sub
				       },
				     }, 'PMLSchema::Choice';
    } else {
      bless $sub, 'PMLSchema::Choice';
    }
  } elsif ($sub = $decl->{cdata}) {
    $decl_type = 'cdata';
    bless $sub, 'PMLSchema::CDATA';
  } elsif (exists $decl->{constant}) { # can be 0
    $sub = $decl->{constant};
    $decl_type = 'constant';
    unless (ref($sub)) {
      $sub = $decl->{constant} = bless { value => $sub }, 'PMLSchema::Constant';
    }
    ## this is just a scalar value
    # bless $sub, 'PMLSchema::Constant';
  }
  weaken( $decl->{-schema} = $schema );
  $decl->{-decl} = $decl_type;
  if (UNIVERSAL::isa($sub,'HASH')) {
    weaken( $sub->{-schema} = $schema ) unless $sub->{-schema};
    weaken( $sub->{-parent} = $decl );
    $sub->{-path} = $path;
  }
  return $decl;
}


=item $decl->get_normal_fields ()

This method is provided for convenience.

For a structure type, return names of its members, for a container
return names of its attributes plus the name '#content' referring to
the container's content value. In both cases, eliminate fields of
values with role C<#CHILDNODES> and strip a possible C<.rf> suffix of
fields with role C<#KNIT>.

=cut

sub get_normal_fields {
  my ($self,$path)=@_;
  my $type = defined($path) ? $self->find($path) : $self;
  my $struct;
  my $members;
  return unless ref $type;
  my $decl_is = $type->get_decl_type;
  if ($decl_is == PML_TYPE_DECL ||
      $decl_is == PML_ROOT_DECL ||
      $decl_is == PML_ATTRIBUTE_DECL ||
      $decl_is == PML_MEMBER_DECL ||
      $decl_is == PML_ELEMENT_DECL ) {
    if ($type = $type->get_content_decl) {
      $decl_is = $type->get_decl_type; 
    } else {
      return ();
    }
  }
  my @members = ();
  if ($decl_is == PML_STRUCTURE_DECL) {
    @members = 
      map { $_->get_knit_name }
	grep { $_->get_role ne '#CHILDNODES' }
	  $type->get_members;
  } elsif ($decl_is == PML_CONTAINER_DECL) {
    my $cdecl = $type->get_content_decl;
    @members = ($type->get_attribute_names, 
		($cdecl && $type->get_role ne '#CHILDNODES') ? '#content' : ());
  }
}

=item $decl->get_attribute_paths ()

Return attribute paths leading from this declaration to all (possibly
deeply) nested declarations of atomic type.

=cut

sub get_attribute_paths {
  my ($self)=@_;
  return $self->schema->attributes($self);
}

sub validate_object {
  croak "Not implemented for the class ".__PACKAGE__;
}

=back

=cut

#########################

=head2 PMLSchema::Root

PMLSchema::Root - implements root PML-schema declaration

=cut

package PMLSchema::Root;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_name ()

Returns the declared PML root-element name.

=item $decl->get_decl_type ()

Returns the constant PML_ROOT_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'root'.

=item $decl->get_content_decl ()

Returns declaration of the content type.

=cut

sub is_root { 1 }
sub is_atomic { undef }
sub get_decl_type { return PML_ROOT_DECL; }
sub get_decl_type_str { return 'root'; }
sub get_name { return $_[0]->{name}; }
sub validate_object {
  my $self = shift;
  $self->get_content_decl->validate_object(@_);
}

=back

=cut

#########################

package PMLSchema::Type;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Type

PMLSchema::Type - implements named type declaration in a PML schema

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_name ()

Returns type name.

=item $decl->get_decl_type ()

Returns the constant PML_TYPE_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'type'.

=item $decl->get_content_decl ()

Returns the associated data-type declaration.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return PML_TYPE_DECL; }
sub get_decl_type_str { return 'type'; }
sub get_name { return $_[0]->{-name}; }
sub validate_object {
  my $self = shift;
  $self->get_content_decl->validate_object(@_);
}

##############################

package PMLSchema::Struct;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Struct

PMLSchema::Struct - implements declaration of a structure.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_STRUCTURE_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'structure'.

=item $decl->get_structure_name ()

Return declared structure name (if any).

=cut

sub is_atomic { 0 }
sub get_decl_type { return PML_STRUCTURE_DECL; }
sub get_decl_type_str { return 'structure'; }
sub get_content_decl { return(undef); }
sub get_structure_name { return $_[0]->{name}; }

=item $decl->get_members ()

Return a list of the associated member declarations
(C<PMLSchema::Member>).

=cut

sub get_members { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_member_names ()

Return a list of names of all members of the structure.

=cut

sub get_member_names { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_member_by_name (name)

Return the declaration of the member with a given name.

=cut

sub get_member_by_name {
  my ($self, $name) = @_;
  my $members = $_[0]->{member};
  return $members ? $members->{$name} : undef;
}

=item $decl->get_attributes ()

Return a list of member declarations (C<PMLSchema::Member>) declared
as attributes.

=cut

sub get_attributes { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } 
    grep { $_->{as_attribute} } values %$members : (); 
}

=item $decl->get_attribute_names ()

Return a list of names of all members of the structure declared as
attributes.

=cut

sub get_attribute_names { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } 
    grep { $_->{as_attribute} } keys %$members : (); 
}



=item $decl->find_members_by_content_decl (decl)

Lookup and return those member declarations whose content declaration
is decl.

=cut

sub find_members_by_content_decl {
  my ($self, $decl) = @_;
  return grep { $decl == $_->get_content_decl } $self->get_members;
}

=item $decl->find_members_by_type_name (name)

Lookup and return those member declarations whose content is specified
via a reference to the named type with a given name.

=cut

sub find_members_by_type_name {
  my ($self, $type_name) = @_;
  # using directly $member->{type}
  return grep { $type_name eq $_->{type} } $self->get_members;  
}

=item $decl->find_members_by_role (role)

Lookup and return declarations of all members with a given role.

=cut

sub find_members_by_role {
  my ($self, $role) = @_;
  # using directly $member->{role}
  return grep { $role eq $_->{role} } $self->get_members;  
}

sub validate_object {
  my ($self,$object,$opts) = @_;

  my ($path,$tag);
  my $log = [];
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
  }

  my $members = $self->get_members;
  if (!UNIVERSAL::isa($object,'HASH')) {
    push @$log, "$path: Unexpected content of the structure '$self->{name}': '$object'";
  } else {
    my @members = $self->get_members;
    foreach my $member (grep { $_->is_attribute } @members) {
      my $name = $member->get_name;
      if (ref $object->{$name}) {
	push @$log,"$path/$name: invalid content for member declared as attribute: ".ref($object->{$name});
      }
    }
    foreach my $member (@members) {
      my $name = $member->get_name;
      my $role = $member->get_role;
      my $mtype = $member->get_content_decl;
      my $val = $object->{$name};
      my $knit_name = $member->get_knit_name;
      if ($role eq '#CHILDNODES') {
	if (!UNIVERSAL::isa($object,'FSNode')) {
	  push @$log, "$path/$name: #CHILDNODES member on a non-node object:\n".Dumper($object);
	}
	unless ($opts->{no_childnodes}) {
	  my $content;
	  my $mtype_is = $mtype->get_decl_type;
	  if ($mtype_is == PML_SEQUENCE_DECL) {
	    $content = Fslib::Seq->new([map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
	  } elsif ($mtype_is == PML_LIST_DECL) {
	    $content = Fslib::List->new_from_ref([$object->children],1);
	  } else {
	    push @$log, "$path: #CHILDNODES should be either a list or sequence type";
	  }
	  $mtype->validate_object($content,
				  { path => $path, 
				    tag => $name,
				    log => $log,
				  } );
	}
      } elsif ($name ne $knit_name) {
	my $knit_val = $object->{$knit_name};
	if ($knit_val ne q{} and $val ne q{}) {
	  push @$log, "$path/$knit_name: both '$name' and '$knit_name' are present for a #KNIT member";
	} elsif ($val ne q{}) {
	  $knit_name = $name;
	  $knit_val = $val;
	}
	if (my $knit_mtype = $member->get_knit_content_decl) {
	  if ($knit_val ne q{} or $member->is_required) {
	    $knit_mtype->validate_object($knit_val,
				       { path => $path,
					 tag => $knit_name,
					 log => $log
					});
	  }
	} else {
	  push @$log, "$path/$knit_name: can't determine data type of the #KNIT member";
	}
      } elsif ($val ne q{} or $member->is_required) {
	$mtype->validate_object($val,
				{ path => $path, 
				  tag => $name,
				  log => $log,
				} );
      }
    }
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

=back

=cut

##############################

package PMLSchema::Container;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Container

PMLSchema::Container - implements declaration of a container.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>, but provides
several methods which make its interface largely compatible with
the C<PMLSchema::Struct> class.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_CONTAINER_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'container'.

=item $decl->get_content_decl ()

Return declaration of the content type.

=cut

sub get_decl_type { return PML_CONTAINER_DECL; }
sub get_decl_type_str { return 'container'; }
sub is_atomic { 0 }

=item $decl->get_attributes ()

Return a list of the associated attribute declarations
(C<PMLSchema::Attribute>).

=cut

sub get_attributes { 
  my $members = $_[0]->{attribute};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_attribute_names ()

Return a list of names of attributes associated with the container.

=cut

sub get_attribute_names { 
  my $members = $_[0]->{attribute};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_attribute_by_name (name)

Return the declaration of the attribute with a given name.

=cut

sub get_attribute_by_name {
  my ($self, $name) = @_;
  my $members = $_[0]->{attribute};
  return $members ? $members->{$name} : undef;
}

=item $decl->find_attributes_by_content_decl (decl)

Lookup and return those attribute declarations whose content
declaration is decl.

=cut

sub find_attributes_by_content_decl {
  my ($self, $decl) = @_;
  return grep { $decl == $_->get_content_decl } $self->get_attributes;
}

=item $decl->find_attributes_by_type_name (name)

Lookup and return those attribute declarations whose content is
specified via a reference to the named type with a given name.

=cut

sub find_attributes_by_type_name {
  my ($self, $type_name) = @_;
  # using directly $member->{type}
  return grep { $type_name eq $_->{type} } $self->get_attributes;  
}

=item $decl->find_attributes_by_role (role)

Lookup and return declarations of all members with a given role.

=cut

sub find_attributes_by_role {
  my ($self, $role) = @_;
  # using directly $member->{role}
  return grep { $role eq $_->{role} } $self->get_attributes;  
}

sub validate_object {
  my ($self, $object, $opts) = @_;

  my ($path,$tag);
  my $log = [];
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
  }

  if (not UNIVERSAL::isa($object,'HASH')) {
    push @$log, "$path: Unexpected container object (should be a HASH): $object";
  } else {
    my @attributes = $self->get_attributes;
    foreach my $attr (@attributes) {
      my $name = $attr->get_name;
      my $val = $object->{$name};
      my $adecl = $attr->get_content_decl;
      if ($attr->is_required or $val ne q{}) {
	if (ref($val)) {
	  push @$log, "$path/$name: invalid content for attribute: ".ref($val);
	} elsif ($adecl) {
	  $adecl->validate_object($val, { path => $path, 
					  tag=>$name, 
					  log=>$log });
	}
      }
    }
    my $cdecl = $self->get_content_decl;
    if ($cdecl) {
      my $content = $object->{'#content'};
      my $skip_content = 0;
      if ($self->get_role eq '#NODE') {
	if (!UNIVERSAL::isa($object,'FSNode')) {
	  push @$log,"$path: container declared as #NODE should be a FSNode object: $object";
	} else {
	  my $cdecl_is = $cdecl->get_decl_type;
	  if ($cdecl->get_role eq '#CHILDNODES') {
	    if ($content ne q{}) {
	      push @$log, "$path: #NODE container containing a #CHILDNODES should have empty #content: $content";
	    }
	    if ($opts->{no_childnodes}) {
	      $skip_content = 1;
	    } elsif ($cdecl_is == PML_SEQUENCE_DECL) {
	      $content = Fslib::Seq->new([map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
	    } elsif ($cdecl_is == PML_LIST_DECL) {
	      $content = Fslib::List->new_from_ref([$object->children],1);
	    } else {
	      push @$log, "$path: #CHILDNODES should be either a list or sequence";
	    }
	  }
	}
      }
      unless ($skip_content) {
	$cdecl->validate_object($content,{ path => $path,
					   tag => '#content', 
					   log=>$log 
					  });
      }
    }
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

=back

=head3 COMPATIBILITY METHODS

=over 3

=item $decl->get_members ()

Return declarations of all associated attributes and of the content
type.

=cut

sub get_members {
  my $self = shift;
  return ($self->get_attributes, $self->get_content_decl);
}

=item $decl->get_member_by_name (name)

If name is equal to '#content', return the content type declaration,
otherwise acts like C<get_attribute_by_name>.

=cut

sub get_member_by_name {
  my ($self, $name) = @_;
  if ($name eq '#content') {
    return $self->get_content_decl
  } else {
    return $self->get_attribute_by_name($name);
  }
}

=item $decl->get_member_names ()

Return a list of all attribute names plus the string '#content'.

=cut

sub get_member_names {
  my $self = shift;
  return ($self->get_attribute_names, ($self->get_content_decl ? ('#content') : ()))
}


=item $decl->find_members_by_content_decl (decl)

Lookup and return those member (attribute or content) declarations
whose content declaration is decl.

=item $decl->find_members_by_type_name (name)

Lookup and return those member (attribute or content) declarations
whose content is specified via a reference to the named type with a
given name.

=item $decl->find_members_by_role (role)

Lookup and return declarations of all members (attribute or content)
with a given role.

=cut

*find_members_by_content_decl = \&PMLSchema::Struct::find_members_by_content_decl;
*find_members_by_type_name = \&PMLSchema::Struct::find_members_by_type_name;
*find_members_by_role = \&PMLSchema::Struct::find_members_by_role;

=back

=cut

##############################

package PMLSchema::Seq;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Seq

PMLSchema::Seq - implements declaration of a sequence.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_SEQUENCE_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'sequence'.

=item $decl->is_mixed ()

Return 1 if the sequence allows text content, otherwise
return 0.

=item $decl->get_content_pattern ()

Return content pattern associated with the declaration (if
any). Content pattern specifies possible ordering and occurences of
elements in DTD-like content-model grammar.

=cut

sub is_atomic { 0 }
sub get_decl_type { return PML_SEQUENCE_DECL; }
sub get_decl_type_str { return 'sequence'; }
sub get_content_decl { return(undef); }
sub is_mixed { return $_[0]->{text} ? 1 : 0 }
sub get_content_pattern {
  return $_[0]->{content_pattern};
}

=item $decl->get_elements ()

Return a list of element declarations (C<PMLSchema::Element>).

=cut

sub get_elements { 
  my $members = $_[0]->{element};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_elements ()

Return a list of names of elements declared for the sequence.

=cut

sub get_element_names { 
  my $members = $_[0]->{element};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_element_by_name (name)

Return the declaration of the element with a given name.

=cut

sub get_element_by_name {
  my ($self, $name) = @_;
  my $members = $_[0]->{element};
  return $members ? $members->{$name} : undef;
}

=item $decl->find_elements_by_content_decl

Lookup and return those element declarations whose content declaration
is decl.

=cut

sub find_elements_by_content_decl {
  my ($self, $decl) = @_;
  return grep { $decl == $_->get_content_decl } $self->get_elements;
}

=item $decl->find_elements_by_type_name

Lookup and return those element declarations whose content is
specified via a reference to the named type with a given name.

=cut


sub find_elements_by_type_name {
  my ($self, $type_name) = @_;
  # using directly $member->{type}
  return grep { $type_name eq $_->{type} } $self->get_elements;  
}

=item $decl->find_elements_by_role

Lookup and return declarations of all elements with a given role.

=cut

sub find_elements_by_role {
  my ($self, $role) = @_;
  # using directly $member->{role}
  return grep { $role eq $_->{role} } $self->get_elements;  
}

sub validate_content_pattern {
  die "NOT YET IMPLEMENTED";
}

sub validate_object {
  my ($self, $object, $opts) = @_;

  my ($path,$tag);
  my $log = [];
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
  }

  if (UNIVERSAL::isa($object,'Fslib::Seq')) {
    my $i = 0;
    foreach my $element ($object->elements) {
      $i++;
      if (!UNIVERSAL::isa($element,'ARRAY')) {
	push @$log, "$path: invalid sequence content: ",ref($element);
      } elsif ($element->[0] eq '#TEXT') {
	if ($self->is_mixed) {
	  if (ref($element->[1])) {
	    push @$log, "$path: expected CDATA, got: ",ref($element->[1]);
	  }
	} else {
	  push @$log, "$path: text node not allowed here\n";
	}
      } else {
	my $ename = $element->[0];
	my $edecl = $self->get_element_by_name($ename);
	# KNIT on elements not supported yet
	if ($edecl) {
	  $edecl->validate_object($element->[1],{ path => $path,
						  tag => "[$i]",
						  log => $log,
						});
	} else {
	  push @$log, "$path: undefined element '$ename'";
	}
      }
      my $content_pattern = $self->get_content_pattern;
      if ($content_pattern and !$object->validate($content_pattern)) {
	push @$log, "$path: sequence content (".join(",",$object->names).") does not follow the pattern ".$content_pattern;
      }
    }
  } else {
    push @$log, "$path: unexpected content of a sequence: $object";
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

=back

=cut 

##############################

package PMLSchema::List;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::List

PMLSchema::List - implements declaration of a list.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_LIST_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'list'.

=item $decl->get_content_decl ()

Return type declaration of the list members.

=item $decl->is_ordered ()

Return 1 if the list is declared as ordered.

=back

=cut

sub is_atomic { 0 }
sub get_decl_type { return PML_LIST_DECL; }
sub get_decl_type_str { return 'list'; }
sub is_ordered { return $_[0]->{ordered} }


sub validate_object {
  my ($self, $object, $opts) = @_;

  my ($path,$tag);
  my $log = [];
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
  }
  if (ref($object) eq 'Fslib::List') {
    my $lm_decl = $self->get_knit_content_decl;
    for (my $i=0; $i<@$object; $i++) {
      $lm_decl->validate_object($object->[$i],
				{ path=> $path,
				  tag => "[".($i+1)."]",
				  log => $log,
				});
    }
  } else {
    push @$log, "$path: unexpected content of a list: $object";
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

##############################

package PMLSchema::Alt;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Alt

PMLSchema::Alt - implements declaration of an alternative (alt).

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_ALT_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'alt'.

=item $decl->get_content_decl ()

Return type declaration of the list members.

=item $decl->is_flat ()

Return 1 for ``flat'' alternatives, otherwise return 0. (Flat
alternatives are not part of PML specification, but are used for
translating attribute values from C<FSFormat>.)

=back

=cut

sub is_atomic { 0 }
sub get_decl_type { return PML_ALT_DECL; }
sub get_decl_type_str { return 'alt'; }
sub is_flat { return $_[0]->{-flat} }

sub validate_object {
  my ($self, $object, $opts) = @_;

  my ($path,$tag);
  my $log = [];
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
  }
  my $am_decl = $self->get_content_decl;
  if ($self->is_flat) {
    # flat alternative:
    if (ref($object)) {
      push @$log, "$path: flat alternative is supposed to be a string: $object";      
    } else {
      my $i = 1;
      foreach my $val (split /\|/,$object) {
	$am_decl->validate_object($val,
				  { path=> $path,
				    tag => "[".($i++)."]",
				    log => $log,
				  });
      }
    }
  } elsif ($object ne q{} and ref($object) eq 'Fslib::Alt') {
    for (my $i=0; $i<@$object; $i++) {
      $am_decl->validate_object($object->[$i],
				{ path=> $path,
				  tag => "[".($i+1)."]",
				  log => $log,
				});
    }
  } else {
    $am_decl->validate_object($object,{path=>$path,
				       # tag => "[1]", # TrEdNodeEdit would very much like [1] here
				       log=>$log});
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

##############################

package PMLSchema::Choice;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Choice

PMLSchema::Choice - implements declaration of an enumerated
type (choice).

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_CHOICE_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'choice'.

=item $decl->get_values ()

Return list of possible values.

=back

=cut

sub is_atomic { 1 }
sub get_decl_type { return PML_CHOICE_DECL; }
sub get_decl_type_str { return 'choice'; }
sub get_content_decl { return(undef); }
sub get_values { return @{ $_[0]->{values} }; }


sub validate_object {
  my ($self, $object, $opts) = @_;
  my $ok = 0;
  my $values = $self->{values};
  if ($values) {
    foreach (@{$values}) {
      if ($_ eq $object) {
	$ok = 1;
	last;
      }
    }
  }
  if (!$ok and ref($opts) and ref($opts->{log})) {
    my $path = $opts->{path};
    my $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
    push @{$opts->{log}}, "$path: Invalid value: '$object'";
  }
  return $ok;
}

##############################

package PMLSchema::CDATA;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::CDATA

PMLSchema::CDATA - implements cdata declaration.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_CDATA_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'cdata'.

=item $decl->get_format ()

Return identifier of the data format.

=item $decl->check_string_format (string, format-id?)

If the C<format-id> argument is specified, return 1 if the string
confirms to the given format.  If the C<format-id> argument is
omitted, return 1 if the string conforms to the format specified in
the type declaration in the PML schema. Otherwise return 0.

=item $decl->supported_formats

Returns a list of formats for which the current implementation
of C<validate_object> provides a reasonable validator. 

Currently all formats defined in the PML Schema specification revision
1.1.2 are supported, namely:

any, anyURI, base64Binary, boolean, byte, date, dateTime, decimal,
double, duration, float, gDay, gMonth, gMonthDay, gYear, gYearMonth,
hexBinary, ID, IDREF, IDREFS, int, integer, language, long, Name,
NCName, negativeInteger, NMTOKEN, NMTOKENS, nonNegativeInteger,
nonPositiveInteger, normalizedString, PMLREF, positiveInteger, short,
string, time, token, unsignedByte, unsignedInt, unsignedLong,
unsignedShort

=back

=cut

sub is_atomic { 1 }
sub get_decl_type { return PML_CDATA_DECL; }
sub get_decl_type_str { return 'cdata'; }
sub get_content_decl { return(undef); }
sub get_format { return $_[0]->{format} }

{
  my %format_re = (
    any => sub { 1 }, # to make it appear in the list of supported formats
    nonNegativeInteger => qr(^\s*(?:[+]?\d+|-0+)\s*$),
    positiveInteger => qr(^\s*[+]?\d*[1-9]\d*\s*$), # ? is zero allowed lexically
    negativeInteger => qr(^\s*-\d*[1-9]\d*\s*$), # ? is zero allowed lexically
    nonPositiveInteger => qr(^\s*(?:-\d+|[+]?0+)\s*$),
    decimal => qr(^\s*[+-]?\d+(?:\.\d*)?\s*$),
    boolean => qr(^(?:[01]|true|false)$),
  );

  my $BaseChar = '[\x{0041}-\x{005A}\x{0061}-\x{007A}\x{00C0}-\x{00D6}\x{00D8}-\x{00F6}'.
      '\x{00F8}-\x{00FF}\x{0100}-\x{0131}\x{0134}-\x{013E}\x{0141}-\x{0148}\x{014A}-\x{017E}'.
      '\x{0180}-\x{01C3}\x{01CD}-\x{01F0}\x{01F4}-\x{01F5}\x{01FA}-\x{0217}\x{0250}-\x{02A8}'.
      '\x{02BB}-\x{02C1}\x{0386}\x{0388}-\x{038A}\x{038C}\x{038E}-\x{03A1}\x{03A3}-\x{03CE}'.
      '\x{03D0}-\x{03D6}\x{03DA}\x{03DC}\x{03DE}\x{03E0}\x{03E2}-\x{03F3}\x{0401}-\x{040C}'.
      '\x{040E}-\x{044F}\x{0451}-\x{045C}\x{045E}-\x{0481}\x{0490}-\x{04C4}\x{04C7}-\x{04C8}'.
      '\x{04CB}-\x{04CC}\x{04D0}-\x{04EB}\x{04EE}-\x{04F5}\x{04F8}-\x{04F9}\x{0531}-\x{0556}'.
      '\x{0559}\x{0561}-\x{0586}\x{05D0}-\x{05EA}\x{05F0}-\x{05F2}\x{0621}-\x{063A}\x{0641}-'.
      '\x{064A}\x{0671}-\x{06B7}\x{06BA}-\x{06BE}\x{06C0}-\x{06CE}\x{06D0}-\x{06D3}\x{06D5}\x{06E5}-'.
      '\x{06E6}\x{0905}-\x{0939}\x{093D}\x{0958}-\x{0961}\x{0985}-\x{098C}\x{098F}-\x{0990}\x{0993}-'.
      '\x{09A8}\x{09AA}-\x{09B0}\x{09B2}\x{09B6}-\x{09B9}\x{09DC}-\x{09DD}\x{09DF}-\x{09E1}\x{09F0}-'.
      '\x{09F1}\x{0A05}-\x{0A0A}\x{0A0F}-\x{0A10}\x{0A13}-\x{0A28}\x{0A2A}-\x{0A30}\x{0A32}-'.
      '\x{0A33}\x{0A35}-\x{0A36}\x{0A38}-\x{0A39}\x{0A59}-\x{0A5C}\x{0A5E}\x{0A72}-\x{0A74}\x{0A85}-'.
      '\x{0A8B}\x{0A8D}\x{0A8F}-\x{0A91}\x{0A93}-\x{0AA8}\x{0AAA}-\x{0AB0}\x{0AB2}-\x{0AB3}\x{0AB5}-'.
      '\x{0AB9}\x{0ABD}\x{0AE0}\x{0B05}-\x{0B0C}\x{0B0F}-\x{0B10}\x{0B13}-\x{0B28}\x{0B2A}-\x{0B30}'.
      '\x{0B32}-\x{0B33}\x{0B36}-\x{0B39}\x{0B3D}\x{0B5C}-\x{0B5D}\x{0B5F}-\x{0B61}\x{0B85}-'.
      '\x{0B8A}\x{0B8E}-\x{0B90}\x{0B92}-\x{0B95}\x{0B99}-\x{0B9A}\x{0B9C}\x{0B9E}-\x{0B9F}\x{0BA3}-'.
      '\x{0BA4}\x{0BA8}-\x{0BAA}\x{0BAE}-\x{0BB5}\x{0BB7}-\x{0BB9}\x{0C05}-\x{0C0C}\x{0C0E}-'.
      '\x{0C10}\x{0C12}-\x{0C28}\x{0C2A}-\x{0C33}\x{0C35}-\x{0C39}\x{0C60}-\x{0C61}\x{0C85}-'.
      '\x{0C8C}\x{0C8E}-\x{0C90}\x{0C92}-\x{0CA8}\x{0CAA}-\x{0CB3}\x{0CB5}-\x{0CB9}\x{0CDE}\x{0CE0}-'.
      '\x{0CE1}\x{0D05}-\x{0D0C}\x{0D0E}-\x{0D10}\x{0D12}-\x{0D28}\x{0D2A}-\x{0D39}\x{0D60}-'.
      '\x{0D61}\x{0E01}-\x{0E2E}\x{0E30}\x{0E32}-\x{0E33}\x{0E40}-\x{0E45}\x{0E81}-\x{0E82}\x{0E84}'.
      '\x{0E87}-\x{0E88}\x{0E8A}\x{0E8D}\x{0E94}-\x{0E97}\x{0E99}-\x{0E9F}\x{0EA1}-\x{0EA3}\x{0EA5}'.
      '\x{0EA7}\x{0EAA}-\x{0EAB}\x{0EAD}-\x{0EAE}\x{0EB0}\x{0EB2}-\x{0EB3}\x{0EBD}\x{0EC0}-\x{0EC4}'.
      '\x{0F40}-\x{0F47}\x{0F49}-\x{0F69}\x{10A0}-\x{10C5}\x{10D0}-\x{10F6}\x{1100}\x{1102}-'.
      '\x{1103}\x{1105}-\x{1107}\x{1109}\x{110B}-\x{110C}\x{110E}-\x{1112}\x{113C}\x{113E}\x{1140}'.
      '\x{114C}\x{114E}\x{1150}\x{1154}-\x{1155}\x{1159}\x{115F}-\x{1161}\x{1163}\x{1165}\x{1167}'.
      '\x{1169}\x{116D}-\x{116E}\x{1172}-\x{1173}\x{1175}\x{119E}\x{11A8}\x{11AB}\x{11AE}-\x{11AF}'.
      '\x{11B7}-\x{11B8}\x{11BA}\x{11BC}-\x{11C2}\x{11EB}\x{11F0}\x{11F9}\x{1E00}-\x{1E9B}\x{1EA0}-'.
      '\x{1EF9}\x{1F00}-\x{1F15}\x{1F18}-\x{1F1D}\x{1F20}-\x{1F45}\x{1F48}-\x{1F4D}\x{1F50}-'.
      '\x{1F57}\x{1F59}\x{1F5B}\x{1F5D}\x{1F5F}-\x{1F7D}\x{1F80}-\x{1FB4}\x{1FB6}-\x{1FBC}\x{1FBE}'.
      '\x{1FC2}-\x{1FC4}\x{1FC6}-\x{1FCC}\x{1FD0}-\x{1FD3}\x{1FD6}-\x{1FDB}\x{1FE0}-\x{1FEC}'.
      '\x{1FF2}-\x{1FF4}\x{1FF6}-\x{1FFC}\x{2126}\x{212A}-\x{212B}\x{212E}\x{2180}-\x{2182}\x{3041}-'.
      '\x{3094}\x{30A1}-\x{30FA}\x{3105}-\x{312C}\x{AC00}-\x{D7A3}]';
  my $Ideographic = '[\x{4E00}-\x{9FA5}\x{3007}\x{3021}-\x{3029}]';
  my $Letter = "(?:$BaseChar|$Ideographic)";
  my $Digit = 
       '[\x{0030}-\x{0039}\x{0660}-\x{0669}\x{06F0}-\x{06F9}\x{0966}-\x{096F}\x{09E6}-\x{09EF}'.
       '\x{0A66}-\x{0A6F}\x{0AE6}-\x{0AEF}\x{0B66}-\x{0B6F}\x{0BE7}-\x{0BEF}\x{0C66}-\x{0C6F}'.
       '\x{0CE6}-\x{0CEF}\x{0D66}-\x{0D6F}\x{0E50}-\x{0E59}\x{0ED0}-\x{0ED9}\x{0F20}-\x{0F29}]';
  my $CombiningChar = 
      '[\x{0300}-\x{0345}\x{0360}-\x{0361}\x{0483}-\x{0486}\x{0591}-\x{05A1}\x{05A3}-\x{05B9}'.
      '\x{05BB}-\x{05BD}\x{05BF}\x{05C1}-\x{05C2}\x{05C4}\x{064B}-\x{0652}\x{0670}\x{06D6}-\x{06DC}'.
      '\x{06DD}-\x{06DF}\x{06E0}-\x{06E4}\x{06E7}-\x{06E8}\x{06EA}-\x{06ED}\x{0901}-\x{0903}'.
      '\x{093C}\x{093E}-\x{094C}\x{094D}\x{0951}-\x{0954}\x{0962}-\x{0963}\x{0981}-\x{0983}\x{09BC}'.
      '\x{09BE}\x{09BF}\x{09C0}-\x{09C4}\x{09C7}-\x{09C8}\x{09CB}-\x{09CD}\x{09D7}\x{09E2}-\x{09E3}'.
      '\x{0A02}\x{0A3C}\x{0A3E}\x{0A3F}\x{0A40}-\x{0A42}\x{0A47}-\x{0A48}\x{0A4B}-\x{0A4D}\x{0A70}-'.
      '\x{0A71}\x{0A81}-\x{0A83}\x{0ABC}\x{0ABE}-\x{0AC5}\x{0AC7}-\x{0AC9}\x{0ACB}-\x{0ACD}\x{0B01}-'.
      '\x{0B03}\x{0B3C}\x{0B3E}-\x{0B43}\x{0B47}-\x{0B48}\x{0B4B}-\x{0B4D}\x{0B56}-\x{0B57}\x{0B82}-'.
      '\x{0B83}\x{0BBE}-\x{0BC2}\x{0BC6}-\x{0BC8}\x{0BCA}-\x{0BCD}\x{0BD7}\x{0C01}-\x{0C03}\x{0C3E}-'.
      '\x{0C44}\x{0C46}-\x{0C48}\x{0C4A}-\x{0C4D}\x{0C55}-\x{0C56}\x{0C82}-\x{0C83}\x{0CBE}-'.
      '\x{0CC4}\x{0CC6}-\x{0CC8}\x{0CCA}-\x{0CCD}\x{0CD5}-\x{0CD6}\x{0D02}-\x{0D03}\x{0D3E}-'.
      '\x{0D43}\x{0D46}-\x{0D48}\x{0D4A}-\x{0D4D}\x{0D57}\x{0E31}\x{0E34}-\x{0E3A}\x{0E47}-\x{0E4E}'.
      '\x{0EB1}\x{0EB4}-\x{0EB9}\x{0EBB}-\x{0EBC}\x{0EC8}-\x{0ECD}\x{0F18}-\x{0F19}\x{0F35}\x{0F37}'.
      '\x{0F39}\x{0F3E}\x{0F3F}\x{0F71}-\x{0F84}\x{0F86}-\x{0F8B}\x{0F90}-\x{0F95}\x{0F97}\x{0F99}-'.
      '\x{0FAD}\x{0FB1}-\x{0FB7}\x{0FB9}\x{20D0}-\x{20DC}\x{20E1}\x{302A}-\x{302F}\x{3099}\x{309A}]';

  my $Extender = 
      '[\x{00B7}\x{02D0}\x{02D1}\x{0387}\x{0640}\x{0E46}\x{0EC6}\x{3005}\x{3031}-\x{3035}\x{309D}-'.
      '\x{309E}\x{30FC}-\x{30FE}]';
    
  my $NameChar   = "(?:$Letter|$Digit|[-._:]|$CombiningChar|$Extender)";
  my $NCNameChar = "(?:$Letter|$Digit|[-._]|$CombiningChar|$Extender)";
  my $Name       = "(?:(?:$Letter|[_:])$NameChar*)";
  my $NCName     = "(?:(?:$Letter|[_])$NCNameChar*)";
  my $NmToken    = "(?:(?:$NameChar)+)"; 

  $format_re{ID} = $format_re{IDREF} = $format_re{NCName} = qr(^$NCName$)o;
  $format_re{PMLREF} = qr(^$NCName(?:\#$NCName)?$)o;
  $format_re{Name} = qr(^$Name$)o;
  $format_re{NMTOKEN} = qr(^$NameChar+$)o;
  $format_re{NMTOKENS} = qr(^$NmToken(?:\x20$NmToken)*$)o;
  $format_re{IDREFS} = qr(^\s*$NCName(?:\s+$NCName)*\s*$)o;

  my $Space = '[\x20]';
  my $TokChar = '(?:[\x21-\x{D7FF}]|[\x{E000}-\x{FFFD}]|[\x{10000}-\x{10FFFF}])'; # [\x10000-\x10FFFF]
  my $NoNorm = '\x09|\x0a|\x0d';

  my $NormChar = "(?:$Space|$TokChar)";
  my $Char = "(?:$NoNorm|$NormChar)";

  $format_re{string} = qr(^$Char*$)o;
  $format_re{normalizedString} = qr(^$NormChar*$)o;
  # Token :no \x9,\xA,\xD, no leading/trailing space,
  # no internal sequence of two or more spaces
  $format_re{token} = qr(^$TokChar(?:$TokChar*(?:$Space$TokChar)?)*$)o;

  my $B64          = '[A-Za-z0-9+/]';
  my $B16          = '[AEIMQUYcgkosw048]';
  my $B04          = '[AQgw]';
  my $B04S         = "$B04\x20?";
  my $B16S         = "$B16\x20?";
  my $B64S         = "$B64\x20?";
  my $Base64Binary =  "(?:(?:$B64S$B64S$B64S$B64S)*(?:(?:$B64S$B64S$B64S$B64)|(?:$B64S$B64S$B16S=)|(?:$B64S$B04S=\x20?=)))?";
  $format_re{base64Binary} = qr(^$Base64Binary$)o;
  my $hex          = '[0-9a-fA-F]';
  $format_re{hexBinary} = qr(^(?:$hex$hex)*$)o;
  $format_re{language} = qr(^(?:[a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*)$)o; 

  # URI (RFC 2396, RFC 2732)
  my $digit    = '[0-9]';
  my $upalpha  = '[A-Z]';
  my $lowalpha = '[a-z]';
  my $alpha        = "(?:$lowalpha | $upalpha)";
  my $alphanum     = "(?:$alpha | $digit)";
  my $hex          = "(?:$digit | [A-Fa-f])";
  my $escaped      = "(?:[%] $hex $hex)";
  my $mark         = "[-_.!~*'()]";
  my $unreserved   = "(?:$alphanum | $mark)";
  my $reserved     = '(?:[][;/?:@&=+] | [\$,])';
  my $uric         = "(?:$reserved | $unreserved | $escaped)";
  my $fragment     = "(?:$uric*)";
  my $query        = "(?:$uric*)";
  my $pchar        = "(?:$unreserved | $escaped | [:@&=+\$,])";
  my $param        = "(?:$pchar*)";
  my $segment      = "(?:$pchar* (?: [;] $param )*)";
  my $path_segments= "(?:$segment (?: [/] $segment )*)";
  my $port         = "(?:$digit*)";
  my $IPv4_address = "(?:${digit}{1,3} [.] ${digit}{1,3} [.] ${digit}{1,3} [.] ${digit}{1,3})";
  my $hex4    = "(?:${hex}{1,4})";
  my $hexseq  = "(?:$hex4 (?: : hex4)*)";
  my $hexpart = "(?:$hexseq | $hexseq :: $hexseq ? | ::  $hexseq ?)";
  my $IPv6prefix   = "(?:$hexpart / ${digit}{1,2})";
  my $IPv6_address = "(?:$hexpart (?: : IPv4address )?)";
  my $ipv6reference ="(?:[[](?:$IPv6_address)[]])";
  my $toplabel     = "(?:$alpha | $alpha (?: $alphanum | [-] )* $alphanum)";
  my $domainlabel  = "(?:$alphanum | $alphanum (?: $alphanum | [-] )* $alphanum)";
  my $hostname     = "(?:(?: ${domainlabel} [.] )* $toplabel (?: [.] )?)";
  my $host         = "(?:$hostname | $IPv4_address | $ipv6reference)";
  my $hostport     = "(?:$host (?: [:] $port )?)";
  my $userinfo     = "(?:(?: $unreserved | $escaped | [;:&=+\$,] )*)";
  my $server       = "(?:(?: (?: ${userinfo} [@] )? $hostport )?)";
  my $reg_name     = "(?:(?: $unreserved | $escaped | [\$,] | [;:@&=+] )+)";
  my $authority    = "(?:$server | $reg_name)";
  my $scheme       = "(?:$alpha (?: $alpha | $digit | [-+.] )*)";
  my $rel_segment  = "(?:(?: $unreserved | $escaped | [;@&=+\$,] )+)";
  my $abs_path     = "(?: /  $path_segments)";
  my $rel_path     = "(?:$rel_segment (?: $abs_path )?)";
  my $net_path     = "(?: // $authority (?: $abs_path )?)";
  my $uric_no_slash= "(?:$unreserved | $escaped | [;?:@] | [&=+\$,])";
  my $opaque_part  = "(?:$uric_no_slash $uric*)";
  my $path         = "(?:(?: $abs_path | $opaque_part )?)";
  my $hier_part    = "(?:(?: $net_path | $abs_path ) (?: [?] $query )?)";
  my $relativeURI  = "(?:(?: $net_path | $abs_path | $rel_path ) (?: [?] $query )?)";
  my $absoluteURI  = "(?:${scheme} [:] (?: $hier_part | $opaque_part ))";
  my $URI_reference = "(?:$absoluteURI|$relativeURI)?(?:[#]$fragment)?";

  $format_re{anyURI} = qr(^ $URI_reference $)x;

  sub _parse_real {
    my ($value,$exp) = @_;
    return 0 unless
      ($value ne q{} and 
       $value =~ /
	    ^
	    (?:[+-])?		    # sign
            (?:
	      (?:INF)		    # infinity
	    | (?:NaN)		    # not a number
	    | (?:\d+(?:\.\d+)?)	    # mantissa
	      (?:[eE]		    # exponent
		([+-])?		    # sign	   ($1)
		(\d+)		    # value        ($2)
	      )?
	    )
	    $
	/x);
    # TODO: need to test bounds of mantissa ( < 2^24 )
    $$exp = ($1 || '') . ($2 || '') if ref($exp);
    return 1;
  }

  $format_re{double} = sub {
    my $exp;
    return 0 unless _parse_real(shift,\$exp);
    return 0 if $exp && ($exp < -1075 || $exp > 970);
    return 1;
  };
  $format_re{float} = sub {
    my $exp;
    return 0 unless _parse_real(shift,\$exp);
    return 0 if $exp && ($exp < -149 || $exp > 104);
    return 1;
  };

  $format_re{duration} = sub {
    my $value = shift;
    return 0 
      unless length $value and $value =~ /
	    ^
	    -?                  # sign
	    P                   # date
	     (?:\d+Y)?            # years
	     (?:\d+M)?            # months
	     (?:\d+D)?            # days
	    (?:T                # time
             (?:\d+H)?	          # hours
	     (?:\d+M)?	          # minutes
	     (?:\d(?:\.\d+)?S)?   # seconds
            )?
	    $ 
	/x;
  };
  
  my $integer = $format_re{integer} = qr(^\s*[+-]?\d+\s*$);
  $format_re{long} = sub {
    my $val = shift;
    return ($val =~ $integer and
	    $val >= -9223372036854775808 and
            $val <=  9223372036854775807) ? 1 : 0;
  };
  $format_re{int} = sub {
    my $val = shift;
    return ($val =~ $integer and
	    $val >= -2147483648 and
            $val <=  2147483647) ? 1 : 0;
  };
  $format_re{short} = sub {
    my $val = shift;
    return ($val =~ $integer and
	    $val >= -32768 and
            $val <=  32767) ? 1 : 0;
  };
  $format_re{byte} = sub {
    my $val = shift;
    return ($val =~ $integer and
	    $val >= -128 and
            $val <=  127) ? 1 : 0;
  };
  my $nonNegativeInteger=$format_re{nonNegativeInteger};
  $format_re{unsignedLong} = sub {
    my $val = shift;
    return ($val =~ $nonNegativeInteger and
	    $val <= 18446744073709551615)
  };
  $format_re{unsignedInt} = sub {
    my $val = shift;
    return ($val =~ $nonNegativeInteger and
	    $val <= 4294967295)
  };
  $format_re{unsignedShort} = sub {
    my $val = shift;
    return ($val =~ $nonNegativeInteger and
	    $val <= 65535)
  };
  $format_re{unsignedByte} = sub {
    my $val = shift;
    return ($val =~ $nonNegativeInteger and
	    $val <= 255)
  };

  sub _check_time {
    my $value = shift;
    my $no_hour24 = shift;
    return 
      ((length($value) and 
      $value =~ m(^
	 (\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?  # hour:min:sec
	 (?:Z|[-+]\d{2}:\d{2})?      # zone
      $)x and
       ((!$no_hour24 and $1 == 24 and $2 == 0 and $3 == 0 and $4 == 0) or
	0 <= $1 and $1 <= 23 and
        0 <= $2 and $2 <= 59 and 
        0 <= $3 and $3 <= 59)
      ) ? 1 : 0);
  }
  sub _check_date {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /
	 ^
	   [-+]?	          # sign
	   (?:[1-9]\d{4,}|\d{4}) # year
	   -(\d{2})               # month ($1)
           -(\d{2})               # day ($2)
	 $
       /x
      and $1>=1 and $1<=12
      and $2>= 1 and $2<=31
      ) ? 1 : 0;
  }

  $format_re{time} = \&_check_time;
  $format_re{date} = \&_check_date;
  $format_re{dateTime} = sub {
    my $value = shift;
    return 0 unless length $value;
    return 0 unless $value =~ /^(.*)T(.*)$/;
    my ($date,$time)=($1,$2);
    return _check_date($date) && _check_time($time,1) ? 1 : 0;
  };
  $format_re{gYearMonth} = sub {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /
	 ^
	   [-+]?	           # sign
	   (?:[1-9]\d{4,}|\d{4})  # year
	   -(\d{2})                # month ($1)
	 $
       /x
      and $1>=1 and $1<=12
      ) ? 1 : 0;
  };
  $format_re{gYear} = sub {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /
	 ^
	   [-+]?	           # sign
	   (?:[1-9]\d{4,}|\d{4})  # year
	 $
       /x) ? 1 : 0;
  };
  $format_re{gMonthDay} = sub {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /^--(\d{2})-(\d{2})$/ # --MM-DD
       and $1>=1 and $1<=12
       and $2>= 1 and $2<=31	 
      ) ? 1 : 0;
  };
  $format_re{gDay} = sub {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /^---(\d{2})$/ # ---DD
       and $1>= 1 and $1<=31	 
      ) ? 1 : 0;
  };
  $format_re{gMonth} = sub {
    my $value = shift;
    return 
      (length($value) and 
       $value =~ /^--(\d{2})$/ # --MM
       and $1>=1 and $1<=12
      ) ? 1 : 0;
  };
  sub _get_format_checker { return $format_re{ $_[1] || $_[0]->{format} } }
  sub supported_formats {
    return sort keys %format_re;
  }
}


sub check_string_format {
  my ($self, $string, $format) = @_;
  my $format ||= $self->get_format;
  return 1 if $format eq 'any';
  my $re = $self->_get_format_checker($format);
  if (defined $re) {
    if ((ref($re) eq 'CODE' and !$re->($string))
	 or (ref($re) ne 'CODE' and $string !~ $re)) {
      return 0
    }
  } else {
    # warn "format $format not supported ??";
  }
  return 1;
}

sub validate_object {
  my ($self, $object, $opts) = @_;
  my $err = undef;
  my $format = $self->get_format;
  if (ref($object)) {
    $err = "expected CDATA, got: ".ref($object);
  } elsif (!$self->check_string_format($object,$format)) {
    $err = "CDATA value not formatted as $format: '$object'";
  }
  if ($err and ref($opts) and ref($opts->{log})) {
    my $path = $opts->{path};
    my $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
    push @{$opts->{log}}, "$path: ".$err;
  }
  return $err ? 0 : 1;
}

##############################

package PMLSchema::Constant;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Constant

PMLSchema::Constant - implements constant declaration.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_CONSTANT_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'constant'.

=item $decl->get_value ()

Return the constant value.

=item $decl->get_values ()

Returns a singleton list consisting of the constant value (for
compatibility with choice declarations).

=back

=cut


sub is_atomic { 1 }
sub get_decl_type { return PML_CONSTANT_DECL; }
sub get_decl_type_str { return 'constant'; }
sub get_content_decl { return(undef); }
sub get_value { return $_[0]->{value}; }
sub get_values { my @val=($_[0]->{value}); return @val; }

sub validate_object {
  my ($self, $object, $opts) = @_;
  my $const = $self->{value};
  my $ok = ($object eq $const) ? 1 : 0;
  if (!$ok and ref($opts) and ref($opts->{log})) {
    my $path = $opts->{path};
    my $tag = $opts->{tag};
    $path.="/".$tag if $tag ne q{};
    push @{$opts->{log}}, "$path: invalid constant, should be '$const', got: '$object'";
  }
  return $ok;
}

##############################

package PMLSchema::Member;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Member

PMLSchema::Member - implements declaration of a member of a structure.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_MEMBER_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'member'.

=item $decl->get_name ()

Return name of the member.

=item $decl->is_required ()

Return 1 if the member is declared as required, 0 otherwise.

=item $decl->is_attribute ()

Return 1 if the member is declared as attribute, 0 otherwise.

=item $decl->get_parent_struct ()

Return the structure declaration the member belongs to.

=item $decl->get_knit_name ()

Return the member's name with a possible suffix '.rf' chopped-off, if
either the member itself has a role '#KNIT' or its content is a list
and has a role '#KNIT'. Otherwise return just the member's name.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return PML_MEMBER_DECL; }
sub get_decl_type_str { return 'member'; }
sub get_name { return $_[0]->{-name}; }
sub is_required { return $_[0]->{required}; }
sub is_attribute { return $_[0]->{as_attribute}; }
*get_parent_struct = \&get_parent_decl;

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}

sub get_knit_name {
  my $self = shift;
  my $name = $self->{-name};
  my $knit_name = $name;
  if ($knit_name=~s/\.rf$//) {
    my $cont;
    if ( $self->{role} eq '#KNIT' or 
	   (($cont = $self->get_content_decl) and
	      $cont->get_decl_type == PML_LIST_DECL and
		$cont->get_role eq '#KNIT')) {
      return $knit_name
    }
  }
  return $name;
}

package PMLSchema::Element;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Element

PMLSchema::Element - implements declaration of an element of a
sequence.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_ELEMENT_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'element'.

=item $decl->get_name ()

Return name of the element.

=item $decl->get_parent_sequence ()

Return the sequence declaration the member belongs to.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return PML_ELEMENT_DECL; }
sub get_decl_type_str { return 'element'; }
sub get_name { return $_[0]->{-name}; }
*get_parent_sequence = \&get_parent_decl;

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}

##############################

package PMLSchema::Attribute;
use base qw( PMLSchema::Decl );
use PMLSchema;

=head2 PMLSchema::Attribute

PMLSchema::Attribute - implements declaration of an attribute
of a container.

=head3 INHERITANCE

This class inherits from C<PMLSchema::Decl>.

=head3 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type ()

Returns the constant PML_ATTRIBUTE_DECL.

=item $decl->get_decl_type_str ()

Returns the string 'attribute'.

=item $decl->get_name ()

Return name of the attribute.

=item $decl->is_required ()

Return 1 if the attribute is required, 0 otherwise.

=item $decl->is_attribute ()

Return 1 (for compatibility with C<PMLSchema::Member>).

=item $decl->get_parent_container ()

Return the container declaration the attribute belongs to.

=item $decl->get_parent_struct ()

Alias for C<get_parent_container()> for compatibility with
C<PMLSchema::Member>.

=back

=cut


sub is_atomic { undef }
sub get_decl_type { return PML_ATTRIBUTE_DECL; }
sub get_decl_type_str { return 'attribute'; }
sub get_name { return $_[0]->{-name}; }
sub is_required { return $_[0]->{required}; }
sub is_attribute { return 1; }
*get_parent_container = \&get_parent_decl;
*get_parent_struct = \&get_parent_decl; # compatibility with members

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!


=head1 SEE ALSO

L<PMLInstance>, L<Fslib>, L<http://ufal.mff.cuni.cz/jazz/PML/doc>,
L<http://ufal.mff.cuni.cz/~pajas/tred>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

