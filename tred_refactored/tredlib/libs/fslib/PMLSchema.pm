package PMLSchema;

BEGIN {
  require Treex::PML::Schema;
  my $o = 'Treex::PML::Schema';
  foreach my $name (keys %{$o.'::'}) {
      if ($name eq 'ISA') {
      	@{__PACKAGE__.'::ISA'}=@{$o.'::ISA'};
      } else {
      	${__PACKAGE__.'::'}{$name} = ${$o.'::'}{$name}; # namespace copy
      }
  }
}

sub DOES {
  my ($self,$role)=@_;
  return 1 if ($role||'') eq 'Treex::PML::Schema' or ($role||'') eq __PACKAGE__;
  return $self->SUPER::DOES($role);
};

require Carp;
Carp::carp("Module PMLSchema is deprecated, use Treex::PML::Schema instead")
  unless (caller())[0] eq 'Fslib';


1;
__END__

=head1 NAME

PMLSchema - compatibility module, use Treex::PML::Schema instead!

=head1 DESCRIPTION

DEPRECATED!

This module is provided for backward compatibility only. Please use
Treex::PML::Schema instead!

=head1 SEE ALSO

C<Treex::PML::Schema>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

