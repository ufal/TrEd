# -*- cperl -*-
require Fslib;
package Fslib::Schema;
use Carp;

=head1 Fslib::Schema

Fslib::PMLSchema - Perl implements a PML schema.

=head2 DESCRIPTION

This class implements PML schemas. PML schema consists of a set of
type declarations of several kinds, represented by objects inheriting
from a common base class C<Fslib::Schema::Decl>.

=head3 Attribute Paths

Some methods use so called 'attribute paths' to navigate through
nested and referenced type declarations. An attribute path is a
'/'-separated sequence of steps, where step can be one of the
following:

=over 3

=item '!' followed by name of a named type (this step can only occur
as the very first step

=item a name (of a member of a structure, element of a sequence or
attribute of a container), specifying the type declaration of the
specified named component

=item the string '#content', specifying the content type declaration
of a container

=item [] specifying the type declaration of a list or alt member

=item [NNN] where NNN is a decimal number (ignored), which is an
equivalent of []

=back

Steps of the form [] (except when occuring at the end of an attribute
path) may be omitted.

=head2 METHODS

=over 3

=item Fslib::Schema->new (string)

Parses a given XML representation of the schema and returns a new
C<Fslib::Schema> instance.

=cut

sub new {
  my ($self,$string,$opts)=@_;
  my $class = ref($self) || $self;
  if ($opts) {
    croak "Usage: Fslib::Schema->new(string,{ param => value,...})" unless UNIVERSAL::isa($opts,'HASH');
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
	my $schema = Fslib::Schema->readFrom($import->{schema},
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
	my $schema = Fslib::Schema->readFrom($import->{schema} ,{ %$opts, 
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


=item Fslib::Schema->readFrom (filename,opts)

Reads schema from a given XML file and returns a new C<Fslib::Schema>
object.

The 2nd argument, C<opts>, is an optional hash reference with parsing
options.  The following options are recognized:

C<base_url> - base URL for referred schemas

C<use_resources> - if true, reffered schemas are also looked for in the $ResourcePath

C<revision>, C<minimal_revision>, C<maximal_revision> - constraint the revision
number of the schema

=cut

sub readFrom {
  my ($self,$file,$opts)=@_;
  if ($opts) {
    croak "Usage: Fslib::Schema->new(string,{ param => value,...})" unless UNIVERSAL::isa($opts,'HASH');
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

=item $schema->get_url()

Return location of the PML schema file.

=cut

sub get_url                  { return $_[0]->{URL};           }

=item $schema->get_version()

Return PML version the schema conforms to.

=cut

sub get_pml_version          { return $_[0]->{version};       }

=item $schema->get_url()

Return PML version the schema conforms to.

=cut

=item $schema->get_revision()

Return PML schema revision.

=cut

sub get_revision             { return $_[0]->{revision};      }

=item $schema->get_description()

Return PML schema description.

=cut

sub get_description          { return $_[0]->{description};   }

=item $schema->get_root_decl()

Return the root type declaration.

=cut

sub get_root_decl            { return $_[0]->{root};          }
sub _internal_api_version    { return $_[0]->{'-api_version'} }

=item $schema->get_root_name()

Return name of the root element for PML instance.

=cut

sub get_root_name { 
  my $root = $_[0]->{root}; 
  return $root ? $root->{name} : undef; 
}

=item $schema->get_type_names()

Return names of all named type declarations.

=cut

sub get_type_names { 
  my $types = $_[0]->{type};
  return $types ? keys(%$types) : ();
}

=item $schema->get_named_reference_info(name)

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
      warn "Couldn't resolve type '$type->{type}' (no such type in schema '".
	$self->{URL}."')\n";
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
    bless $root, 'Fslib::Schema::Root';
    Fslib::Schema::Decl->convert_from_hash($root, 
				  $schema_hash,
				  undef  # path = '' for root
				 );
  }
  my $types = $schema_hash->{type};
  if ($types) {
    my ($name, $decl);
    while (($name, $decl) = each %$types) {
      bless $decl, 'Fslib::Schema::Type';
      Fslib::Schema::Decl->convert_from_hash($decl, 
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
	return undef;
      }
    } elsif ($path=~s{^/}{} or !$decl) {
      $decl = $schema->get_root_decl->get_content_decl;
    }
    for my $step (split /\//, $path,-1) {
      if (ref($decl)) {
	my $decl_is = $decl->get_decl_type;
	if ($decl_is =~ /^(attribute|member|element|type)$/) {
	  $decl = $decl->get_content_decl;
	  next if ($step eq q{});
	  redo;
	}
	if ($decl_is =~ /^(list|alt)$/) {
	  $decl = $decl->get_content_decl;
	  next if ($step =~ /^\[\d*\]/);
	  redo;
	}
	if ($decl_is eq 'structure') {
	  my $member = $decl->get_member_by_name($step);
	  if ($member) {
	    $decl = $member;
	  } else {
	    $member = $decl->get_member_by_name($step.'.rf');
	    return undef unless $member;
	    if ($member->get_knit_name eq $step) {
	      $decl = $member;
	    } else {
	      return undef;
	    }
	  }
	} elsif ($decl_is eq 'container') {
	  if ($step eq '#content') {
	    $decl = $decl->get_content_decl;
	    next;
	  }
	  my $attr = $decl->get_attribute_by_name($step);
	  $decl =  $attr;
	} elsif ($decl_is eq 'sequence') {
	  $decl = $decl->get_element_by_name($step);
	} elsif ($decl_is eq 'root') {
	  if ($step eq $decl->get_name or $step eq q{}) {
	    $decl = $decl->get_content_decl;
	  } else {
	    return undef;
	  }
	} else {
	  return undef;
	}
      } else {
#	warn "Can't follow type path '$path' (step '$step')\n";
	return undef; # ERROR
      }
    }
  }
  return $noresolve ? $decl :
    $decl ? ($decl->get_content_decl || $decl) : undef;
}


=item $schema->find_role (role,decl)

Return a list of attribute paths leading to nested type declarations
of C<decl> with role equal to C<role>. If C<decl> is not specified,
the root type declaration is assumed.

In array context return all matching nested declarations are
returned. In scalar context only the first one is returned (with early
stopping).

=cut

sub find_role {
  my ($self, $role, $decl)=@_;
  $decl ||= $self->{root};
  my $first = not(wantarray);
  my @res = grep { defined } $self->_find_role($decl,$role,$first,{});
  return $first ? $res[0] : @res;
}

sub _find_role {
  my ($self, $decl, $role, $first, $cache)=@_;

  my @result = ();  

  return @result unless ref $decl;

  if ($cache->{'#RECURSE'}{ $decl }) {
    return ()
  }
  local $cache->{'#RECURSE'}{ $decl } = 1;

  if ( $decl->{role} eq $role ) {
    if ($first) {
      return '';
    } else {
      push @result, '';
    }
  }
  my $type_ref = $decl->get_type_ref;
  if ($type_ref) {
    my $cached = $cache->{ $type_ref };
    unless ($cached) {
      $cached = $cache->{ $type_ref } = [ $self->_find_role( $self->get_type_by_name($type_ref),
							     $role, $first, $cache ) ];
    }
    push @result, @$cached;
    return $result[0] if ($first and @result);
  }
  my $decl_is = $decl->get_decl_type;
  if ($decl_is eq 'structure') {
    foreach my $member ($decl->get_members) {
      my @res = map { $_ ne '' ? $member->get_name.'/'.$_ : $member->get_name }
	$self->_find_role($member, $role, $first, $cache);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
  } elsif ($decl_is eq 'container') {
    push @result,  map { $_ ne '' ? '#content/'.$_ : '#content' } 
      $self->_find_role($decl->get_content_decl, $role, $first, $cache);
    return $result[0] if ($first and @result);
    foreach my $attr ($decl->get_attributes) {
      my @res = map { $_ ne '' ? $attr->get_name.'/'.$_ : $attr->get_name }
	$self->_find_role($attr, $role, $first, $cache);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
  } elsif ($decl_is eq 'sequence') {
    foreach my $element ($decl->get_elements) {
      my @res = map { $_ ne '' ? $element->get_name.'/'.$_ : $element->get_name }
	$self->_find_role($element, $role, $first, $cache);
      return $res[0] if ($first and @res);
      push @result,@res;
    }
  } elsif ($decl_is =~ /^(list|alt)$/ ) {
    push @result, map { $_ ne '' ? '[]/'.$_ : '[]' } 
      $self->_find_role($decl->get_content_decl, $role, $first, $cache);
  } elsif ($decl_is =~ /^(type|root|attribute|member|element)$/ ) {
    push @result, $self->_find_role($decl->get_content_decl, $role, $first, $cache);
  }
  return $first ? (@result ? $result[0] : ()) : @result;
}

=item $schema->node_types ()

Return a list of all type declarations with the role C<#NODE>.

=cut

sub node_types {
  my ($self) = @_;
  my @result;
  return map { $self->find_type_by_path($_) } $self->find_role('#NODE');
}


=item $schema->get_root_type ()

Return the declaration of the root type (see C<Fslib::Schema::Root>).

=cut

sub get_root_type {
  my ($self,$name) = @_;
  return $self->{root};
}

*get_root_type_obj = \&get_root_type;

=item $schema->get_type_by_name (name)

Return the declaration of the named type with a given name (see
C<Fslib::Schema::Type>).

=cut

sub get_type_by_name {
  my ($self,$name) = @_;
  return $self->{type}{$name};
}
*get_type_by_name_obj = \&get_type_by_name;


# OBSOLETE: for backward compatibility only
sub type {
  my ($self,$decl)=@_;
  if (UNIVERSAL::isa($decl,'Fslib::Schema::Decl')) {
    return $decl
  } else {
    return Fslib::Type->new($self,$decl);
  }
}

# emulate FSFormat->attributes to some extent

=item $schema->attributes (decl...)

This function tries to emulate the behavior of
C<FSFormat-E<gt>attributes> to some extent.

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
    my $type_is = $type->get_decl_type;
    next if $type->get_role eq '#CHILDNODES';
    if ($type_is =~ /^(root|type|attribute|member|element|list|alt)$/) {
      $type = $type->get_content_decl;
      redo;
    }
    next unless ref($type);
    my @members;
    if ($type_is eq 'structure') {
      @members = map { [$_,$_->get_knit_name] } $type->get_members;
    } elsif ($type_is eq 'container') {
      @members = (map { [ $_, $_->get_name ] } $type->get_attributes,
		    ['#content',$type->get_content_decl]);
    } elsif ($type_is eq 'sequence') {
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

=item $schema->validate_object (object, type_decl, log)

Validates the data content of the given object against a specified
type declaration. The type_decl argument must either be an object
derived from the C<Fslib::Schema::Decl> class or the name of a named
type.

An array reference may be passed as the optional 3rd argument C<log>
to obtain a detailed report of all validation errors.

Returns: 1 if the content conforms, 0 otherwise.

=cut

sub validate_object { # (path, base_type)
  my ($schema, $object, $type,$log)=@_;
  if (defined $log and UNIVERSAL::isa('ARRAY',$log)) {
    croak "Fslib::Schema::validate_object: log must be an ARRAY reference";
  }
  $type ||= $schema->get_type_by_name($type);
  if (!ref($type)) {
    croak "Fslib::Schema::validate_object: Cannot determine data type";
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
    croak "Fslib::Schema::validate_field: log must be an ARRAY reference";
  }
  if (!ref($type)) {
    my $named_type = $schema->get_type_by_name($type);
    croak "Fslib::Schema::validate_field: Cannot find type '$type'" 
      unless $named_type;
    $type = $named_type;
  }
  if ($path eq '') {
    return $type->validate_object($object, { log => $log });
  }
  $type = $type->find($path);
  croak "Fslib::Schema::validate_field: Cannot determine data type for attribute-path '$path'" unless $type;
  return 
    $type->validate_object(FSNode::attr($object,$path),{ path => $path, 
							 log=>$log 
							});
}

=back

=cut

########################################################################
# PML Schema type declaration
########################################################################

=head1 Fslib::Schema::Decl

Fslib::PMLSchema::Decl - implements PML schema type declaration

=head2 DESCRIPTION

This is an abstract class from which all specific type declaration
classes inherit.

=cut

package Fslib::Schema::Decl;

use Scalar::Util qw( weaken );
use Carp;

=head2 METHODS

=over 3

=cut

sub new { croak("Can't create ".__PACKAGE__) }

# compatibility with old Fslib::Type

sub type_decl { return $_[0] };

=item $decl->get_schema() 
=item $decl->schema()       / alias /

Return C<Fslib::PMLSchema> the declaration belongs to.

=cut

sub schema    { return $_[0]->{-schema} }
*get_schema = \&schema;

=item $decl->get_decl_type()

Return the type of declaration; one of: type, root, structure,
container, sequence, list, alt, cdata, choice, constant, attribute,
member, element.

=cut

sub get_decl_type { return undef; } # VIRTUAL

=item $decl->is_atomic()

Return 1 if the declaration is of atomic type (cdata, choice,
constant), 0 if it is a structured type (structure, container,
sequence, list, alt), or undef, if it is an auxiliary declaration
(root, type, attribute, member, element).

=cut

sub is_atomic { croak "is_atomic(): UNKNOWN TYPE"; } # VIRTUAL

=item $decl->get_content_decl()

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
    }
  }
  return undef;
}

=item $decl->get_type_ref()

If the declaration has content and the content is specified via a
reference to a named type, return the name of the referred type.
Otherwise return undef.

=cut

sub get_type_ref {
  return $_[0]->{type};
}

=item $decl->get_type_ref_decl()

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
  return undef;
}

=item $decl->get_base_type_name()

If the declaration is a nested (even deeply) part of a named type
declaration, return the name of that named type.

=cut

sub get_base_type_name {
  my $path = $_[0]->{-path};
  if ($path=~m{^!([^/]+)}) {
    return $1;
  } else {
    return undef;
  }
}

=item $decl->get_parent_decl()

If this declaration is nested, return its parent declaration.

=cut

sub get_parent_decl { return $_[0]->{-parent} }

=item $decl->get_decl_path()

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
from the current type. See C<$schema->find_type_by_path> for details
about locating declarations.

=cut

sub find {
  my ($self, $path,$noresolve) = @_;
  # find node type
  my $type = $self->type_decl;
  return $self->schema->find_type_by_path($path,$noresolve,$type);
}

=item $decl->find_role (role)

Search declarations with a given role nested within this declaration.
In scalar context, return the first declaration that matches, in array
context return all such declarations.

=cut

sub find_role {
  my ($self, $role) = @_;
  return $self->schema->find_role($role,$self->type_decl);
}

sub convert_from_hash {
  my ($class, $decl, $schema, $path) = @_;
  my $sub;
  my $decl_type;
  if ($sub = $decl->{structure}) {
    $decl_type = 'structure';
    bless $sub, 'Fslib::Schema::Struct';
    if (my $members = $sub->{member}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'Fslib::Schema::Member';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
  } elsif ($sub = $decl->{container}) {
    $decl_type = 'container';
    bless $sub, 'Fslib::Schema::Container';
    if (my $members = $sub->{attribute}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'Fslib::Schema::Attribute';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
    $class->convert_from_hash($sub, $schema, $path.'/#content');
  } elsif ($sub = $decl->{sequence}) {
    $decl_type = 'sequence';
    bless $sub, 'Fslib::Schema::Seq';
    if (my $members = $sub->{element}) {
      my ($name, $mdecl);
      while (($name, $mdecl) = each %$members) {
	bless $mdecl, 'Fslib::Schema::Element';
	$class->convert_from_hash($mdecl, 
			 $schema,
			 $path.'/'.$name
			);
      }
    }
  } elsif ($sub = $decl->{list}) {
    $decl_type = 'list';
    bless $sub, 'Fslib::Schema::List';
    $class->convert_from_hash($sub, $schema, $path.'/[LIST]');
  } elsif ($sub = $decl->{alt}) {
    $decl_type = 'alt';
    bless $sub, 'Fslib::Schema::Alt';
    $class->convert_from_hash($sub, $schema, $path.'/[ALT]');
  } elsif ($sub = $decl->{choice}) {
    $decl_type = 'choice';
    # convert from an ARRAY to a hash
    if (ref($sub) eq 'ARRAY') {
      $sub = $decl->{choice} = bless { values => $sub }, 'Fslib::Schema::Choice';
    } else {
      bless $sub, 'Fslib::Schema::Choice';
    }
  } elsif ($sub = $decl->{cdata}) {
    $decl_type = 'cdata';
    bless $sub, 'Fslib::Schema::CDATA';
  } elsif ($sub = $decl->{constant}) {
    $decl_type = 'constant';
    unless (ref($sub)) {
      $sub = $decl->{constant} = bless { value => $sub }, 'Fslib::Schema::Constant';
    }
    ## this is just a scalar value
    # bless $sub, 'Fslib::Schema::Constant';
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
  my $type_is = $type->get_decl_type;
  if ($type_is =~ /^(type|root|attribute|member|element)/) {
    if ($type = $type->get_content_decl) {
      $type_is = $type->get_decl_type; 
    } else {
      return ();
    }
  }
  my @members = ();
  if ($type_is eq 'structure') {
    @members = 
      map { $_->get_knit_name }
	grep { $_->get_role ne '#CHILDNODES' }
	  $type->get_members;
  } elsif ($type_is eq 'container') {
    @members = ($type->get_attributes, 
		$type->get_role ne '#CHILDNODES' ? '#content' : ());
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

=head1 Fslib::Schema::Root

Fslib::PMLSchema::Root - implements root PML-schema declaration

=cut

package Fslib::Schema::Root;
use base qw( Fslib::Schema::Decl );

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_name()

Returns the declared PML root-element name.

=item $decl->get_decl_type()

Returns the string 'root'.

=item $decl->get_content_decl()

Returns declaration of the content type.

=cut

sub is_root { 1 }
sub is_atomic { undef }
sub get_decl_type { return 'root'; }
sub get_name { return $_[0]->{name}; }
sub validate_object {
  my $self = shift;
  $self->get_content_decl->validate_object(@_);
}

=back

=cut

#########################

package Fslib::Schema::Type;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Type

Fslib::PMLSchema::Type - implements named type declaration in a PML schema

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_name()

Returns type name.

=item $decl->get_decl_type()

Returns the string 'type'.

=item $decl->get_content_decl()

Returns the associated data-type declaration.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return 'type'; }
sub get_name { return $_[0]->{-name}; }
sub validate_object {
  my $self = shift;
  $self->get_content_decl->validate_object(@_);
}

##############################

package Fslib::Schema::Struct;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Struct

Fslib::PMLSchema::Struct - implements declaration of a structure.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'structure'.

=item $decl->get_structure_name()

Return declared structure name (if any).

=cut

sub is_atomic { 0 }
sub get_decl_type { return 'structure'; }
sub get_content_decl { return undef; }
sub get_structure_name { return $_[0]->{name}; }

=item $decl->get_members()

Return a list of the associated member declarations
(C<Fslib::Schema::Member>).

=cut

sub get_members { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_member_names()

Return a list of names of all members of the structure.

=cut

sub get_member_names { 
  my $members = $_[0]->{member};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_member_by_name(name)

Return the declaration of the member with a given name.

=cut

sub get_member_by_name {
  my ($self, $name) = @_;
  my $members = $_[0]->{member};
  return $members ? $members->{$name} : undef;
}

=item $decl->find_members_by_content_decl(decl)

Lookup and return those member declarations whose content declaration
is decl.

=cut

sub find_members_by_content_decl {
  my ($self, $decl) = @_;
  return grep { $decl == $_->get_content_decl } $self->get_members;
}

=item $decl->find_members_by_type_name(name)

Lookup and return those member declarations whose content is specified
via a reference to the named type with a given name.

=cut

sub find_members_by_type_name {
  my ($self, $type_name) = @_;
  # using directly $member->{type}
  return grep { $type_name eq $_->{type} } $self->get_members;  
}

=item $decl->find_members_by_role(role)

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
    push @$log, "$path: Unexpected content of a structure $self->{name}: '$object'";
  } else {
    my @members = $self->get_members;
    foreach my $member (grep { $_->is_attribute } @members) {
      my $name = $member->get_name;
      if ($member->is_required or $object->{$name} ne q{}) {
	if (ref($object->{$name})) {
	  push @$log,"$path/$name: invalid content for member declared as attribute: ".ref($object->{$name});
	}
      }
    }
    foreach my $member (@members) {
      my $name = $member->get_name;
      my $role = $member->get_role;
      my $mtype = $member->get_content_decl;
      my $val = $object->{$name};
      if ($role eq '#CHILDNODES') {
	if (!UNIVERSAL::isa($object,'FSNode')) {
	  push @$log, "$path/$name: #CHILDNODES member on a non-node object:\n".Dumper($object);
	}
      } elsif ($name ne (my $knit_name = $member->get_knit_name)) {
	if ($val ne q{}) {
	  if (ref($val)) {
	    push @$log,"$path/$name: invalid content for a member with role #KNIT: ",ref($val);
	  }
	}
	my $knit_val = $object->{$knit_name};
	if ($knit_val ne q{} and $val ne q{}) {
	  push @$log, "$path/$knit_name: both '$name' and '$knit_name' are present for a #KNIT member";
	} elsif ($val eq q{}) {
	  if (my $knit_mtype = $member->get_knit_content_decl) {
	    $knit_mtype->validate_object($knit_val,
					 { path => $path,
					   tag => $knit_name,
					   log => $log
					 });
	  } else {
	    push @$log, "$path/$knit_name: can't determine data type of the #KNIT member";
	  }
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

package Fslib::Schema::Container;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Container

Fslib::PMLSchema::Container - implements declaration of a container.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>, but provides
several methods which make its interface largely compatible with
the C<Fslib::PMLSchema::Schema> class.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'container'.

=item $decl->get_content_decl()

Return declaration of the content type.

=cut

sub get_decl_type { return 'container'; }
sub is_atomic { 0 }

=item $decl->get_attributes()

Return a list of the associated attribute declarations
(C<Fslib::Schema::Attribute>).

=cut

sub get_attributes { 
  my $members = $_[0]->{attribute};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_attribute_names()

Return a list of names of attributes associated with the container.

=cut

sub get_attribute_names { 
  my $members = $_[0]->{attribute};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_attribute_by_name(name)

Return the declaration of the attribute with a given name.

=cut

sub get_attribute_by_name {
  my ($self, $name) = @_;
  my $members = $_[0]->{attribute};
  return $members ? $members->{$name} : undef;
}

=item $decl->find_attributes_by_content_decl(decl)

Lookup and return those attribute declarations whose content
declaration is decl.

=cut

sub find_attributes_by_content_decl {
  my ($self, $decl) = @_;
  return grep { $decl == $_->get_content_decl } $self->get_attributes;
}

=item $decl->find_attributes_by_type_name(name)

Lookup and return those attribute declarations whose content is
specified via a reference to the named type with a given name.

=cut

sub find_attributes_by_type_name {
  my ($self, $type_name) = @_;
  # using directly $member->{type}
  return grep { $type_name eq $_->{type} } $self->get_attributes;  
}

=item $decl->find_attributes_by_role(role)

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
      my $val = $object->{$attr};
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
    my $content = $object->{'#content'};
    my $cdecl = $self->get_content_decl;
    if ($self->get_role eq '#NODE') {
      if (!UNIVERSAL::isa($object,'FSNode')) {
	push @$log,"$path: container declared as #NODE should be a FSNode object: $object";
      } else {
	if ($cdecl and $cdecl->get_decl_type eq 'sequence'
	      and $cdecl->get_role eq '#CHILDNODES') {
	  if ($content ne q{}) {
	    push @$log, "$path: #NODE container containing a #CHILDNODES should have empty #content: $content";
	  }
	  $content = Fslib::Seq->new([map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
	}
      }
    }
    $cdecl->validate_object($content,{ path => $path,
				       tag => '#content', 
				       log=>$log 
				      });
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

=back

=head2 COMPATIBILITY METHODS

=over 3

=item $decl->get_members()

Return declarations of all associated attributes and of the content
type.

=cut

sub get_members {
  my $self = shift;
  return ($self->get_attributes, $self->get_content_decl);
}

=item $decl->get_member_by_name(name)

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

=item $decl->get_member_names()

Return a list of all attribute names plus the string '#content'.

=cut

sub get_member_names {
  return ($_[0]->get_attribute_names, '#content')
}

=back

=cut

##############################

package Fslib::Schema::Seq;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Seq

Fslib::PMLSchema::Seq - implements declaration of a sequence.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'sequence'.

=item $decl->is_mixed()

Return 1 if the sequence allows text content, otherwise
return 0.

=item $decl->get_content_pattern()

Return content pattern associated with the declaration (if
any). Content pattern specifies possible ordering and occurences of
elements in DTD-like content-model grammar.

=cut

sub is_atomic { 0 }
sub get_decl_type { return 'sequence'; }
sub get_content_decl { return undef; }
sub is_mixed { return $_[0]->{text} ? 1 : 0 }
sub get_content_pattern {
  return $_[0]->{content_pattern};
}

=item $decl->get_elements()

Return a list of element declarations (C<Fslib::Schema::Element>).

=cut

sub get_elements { 
  my $members = $_[0]->{element};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $_->{'-#'} ] } values %$members : (); 
}

=item $decl->get_elements()

Return a list of names of elements declared for the sequence.

=cut

sub get_element_names { 
  my $members = $_[0]->{element};
  return $members ? map { $_->[0] } sort { $a->[1]<=> $b->[1] } map { [ $_, $members->{$_}->{'-#'} ] } keys %$members : (); 
}

=item $decl->get_element_by_name(name)

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
    foreach my $element ($object->elements) {
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
	my $edecl = $self->get_element_by_name($element->[0]);
	if ($edecl) {
	  $edecl->validate_object($element->[1],{ path => $path,
						  tag => $element->[0],
						  log => $log,
						});
	} else {
	  push @$log, "$path: undefined element '$element->[0]'";
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

package Fslib::Schema::List;
use base qw( Fslib::Schema::Decl );


=head1 Fslib::Schema::List

Fslib::PMLSchema::List - implements declaration of a list.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'list'.

=item $decl->get_content_decl()

Return type declaration of the list members.

=item $decl->is_ordered()

Return 1 if the list is declared as ordered.

=back

=cut

sub is_atomic { 0 }
sub get_decl_type { return 'list'; }
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
    my $lm_decl = $self->get_content_decl;
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

package Fslib::Schema::Alt;
use base qw( Fslib::Schema::Decl );


=head1 Fslib::Schema::Alt

Fslib::PMLSchema::Alt - implements declaration of an alternative (alt).

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'alt'.

=item $decl->get_content_decl()

Return type declaration of the list members.

=item $decl->is_flat()

Return 1 for ``flat'' alternatives, otherwise return 0. (Flat
alternatives are not part of PML specification, but are used for
translating attribute values from C<FSFormat>.)

=back

=cut

sub is_atomic { 0 }
sub get_decl_type { return 'alt'; }
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
  if ($object ne q{} and ref($object) eq 'Fslib::Alt') {
    for (my $i=0; $i<@$object; $i++) {
      $am_decl->validate_object($object->[$i],
				{ path=> $path,
				  tag => "[".($i+1)."]",
				  log => $log,
				});
    }
  } else {
    $am_decl->validate_object($object,{path=>$path,log=>$log});
  }
  if ($opts and ref($opts->{log})) {
    push @{$opts->{log}}, @$log;
  }
  return @$log ? 0 : 1;
}

##############################

package Fslib::Schema::Choice;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Choice

Fslib::PMLSchema::Choice - implements declaration of an enumerated
type (choice).

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'choice'.

=item $decl->get_values()

Return list of possible values.

=back

=cut

sub is_atomic { 1 }
sub get_decl_type { return 'choice'; }
sub get_content_decl { return undef; }
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

package Fslib::Schema::CDATA;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::CDATA

Fslib::PMLSchema::CDATA - implements cdata declaration.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'cdata'.

=item $decl->get_format()

Return identifier of the data format.

=back

=cut

sub is_atomic { 1 }
sub get_decl_type { return 'cdata'; }
sub get_content_decl { return undef; }
sub get_format { return $_[0]->{format} }

{
  my %format_re = (
    nonNegativeInteger => qr(^\s*\d+\s*$),
  );
  sub get_format_re { return $format_re{ $_[1] || $_[0]->{format} } }
}

sub validate_object {
  my ($self, $object, $opts) = @_;
  my $err = undef;
  my $format = $self->get_format;
  my $re = $self->get_format_re;
  if (ref($object)) {
    $err = "expected CDATA, got: ".ref($object);
  } elsif (defined $re and $object !~ $re) {
    $err = "CDATA value is not formatted as $format: '$object'";
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

package Fslib::Schema::Constant;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Constant

Fslib::PMLSchema::Constant - implements constant declaration.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'constant'.

=item $decl->get_value()

Return the constant value.

=item $decl->get_values()

Returns a singleton list consisting of the constant value (for
compatibility with choice declarations).

=back

=cut


sub is_atomic { 1 }
sub get_decl_type { return 'constant'; }
sub get_content_decl { return undef; }
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

package Fslib::Schema::Member;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Member

Fslib::PMLSchema::Member - implements declaration of a member of a structure.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'member'.

=item $decl->get_name()

Return name of the member.

=item $decl->is_required()

Return 1 if the member is declared as required, 0 otherwise.

=item $decl->is_attribute()

Return 1 if the member is declared as attribute, 0 otherwise.

=item $decl->get_parent_struct()

Return the structure declaration the member belongs to.

=item $decl->get_knit_name()

Return the member's name with a possible suffix '.rf' chopped-off, if
either the member itself has a role '#KNIT' or its content is a list
and has a role '#KNIT'. Otherwise return just the member's name.

=item $decl->get_knit_content_decl()

If the member has a role '#KNIT', return a type declaration for the
knitted content.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return 'member'; }
sub get_name { return $_[0]->{-name}; }
sub is_required { return $_[0]->{required}; }
sub is_attribute { return $_[0]->{as_attribute}; }
*get_parent_struct = \&get_parent_decl;

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}

sub get_knit_content_decl {
  my $self = shift;
  return ($self->{role} eq '#KNIT') ?
    $self->get_type_ref_decl 
      : $self->get_content_decl;
}

sub get_knit_name {
  my $self = shift;
  my $name = $self->{-name};
  my $knit_name = $name;
  if ($knit_name=~s/\.rf$//) {
    my $cont;
    if ( $self->{role} eq '#KNIT' or 
	   (($cont = $self->get_content_decl) and
	      $cont->get_decl_type eq 'list' and
		$cont->get_role eq '#KNIT')) {
      return $knit_name
    }
  }
  return $name;
}

package Fslib::Schema::Element;
use base qw( Fslib::Schema::Decl );

=head1 Fslib::Schema::Element

Fslib::PMLSchema::Element - implements declaration of an element of a
sequence.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'element'.

=item $decl->get_name()

Return name of the element.

=item $decl->get_parent_sequence()

Return the sequence declaration the member belongs to.

=back

=cut

sub is_atomic { undef }
sub get_decl_type { return 'element'; }
sub get_name { return $_[0]->{-name}; }
*get_parent_sequence = \&get_parent_decl;

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}

##############################

package Fslib::Schema::Attribute;
use base qw( Fslib::Schema::Decl );


=head1 Fslib::Schema::Attribute

Fslib::PMLSchema::Attribute - implements declaration of an attribute
of a container.

=head2 INHERITANCE

This class inherits from C<Fslib::PMLSchema::Decl>.

=head2 METHODS

See the super-class for the complete list.

=over 3

=item $decl->get_decl_type()

Returns the string 'attribute'.

=item $decl->get_name()

Return name of the attribute.

=item $decl->is_required()

Return 1 if the attribute is required, 0 otherwise.

=item $decl->is_attribute()

Return 1 (for compatibility with C<Fslib::PMLSchema::Member>).

=item $decl->get_parent_container()

Return the container declaration the attribute belongs to.

=item $decl->get_parent_struct()

Alias for C<get_parent_container()> for compatibility with
C<Fslib::PMLSchema::Member>.

=back

=cut


sub is_atomic { undef }
sub get_decl_type { return 'attribute'; }
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


=head1 EXPORT

None by default.

=head1 SEE ALSO

L<Fslib>, L<PMLInstance>, L<http://ufal.mff.cuni.cz/jazz/PML/doc>,
L<http://ufal.mff.cuni.cz/~pajas/tred>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

