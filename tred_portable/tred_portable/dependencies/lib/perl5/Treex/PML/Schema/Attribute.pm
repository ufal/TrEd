package Treex::PML::Schema::Attribute;

use strict;
use warnings;

use vars qw($VERSION);
BEGIN {
  $VERSION='2.06'; # version template
}
no warnings 'uninitialized';
use Carp;

use Treex::PML::Schema::Constants;
use base qw( Treex::PML::Schema::Decl );

=head1 NAME

Treex::PML::Schema::Attribute - implements declaration of an attribute
of a container.

=head1 INHERITANCE

This class inherits from L<Treex::PML::Schema::Decl>.

=head1 METHODS

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

Return 1 (for compatibility with C<Treex::PML::Schema::Member>).

=item $decl->get_parent_container ()

Return the container declaration the attribute belongs to.

=item $decl->get_parent_struct ()

Alias for C<get_parent_container()> for compatibility with
C<Treex::PML::Schema::Member>.

=back

=cut


sub is_atomic { undef }
sub get_decl_type { return PML_ATTRIBUTE_DECL; }
sub get_decl_type_str { return 'attribute'; }
sub get_name { return $_[0]->{-name}; }
sub is_required { return $_[0]->{required}; }
sub is_attribute { return 1; }
*get_parent_container = \&Treex::PML::Schema::Decl::get_parent_decl;
*get_parent_struct = \&Treex::PML::Schema::Decl::get_parent_decl; # compatibility with members

sub validate_object {
  shift->get_content_decl->validate_object(@_);
}



1;
__END__

=head1 SEE ALSO

L<Treex::PML::Schema::Decl>, L<Treex::PML::Schema>, L<Treex::PML::Container>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008-2010 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

