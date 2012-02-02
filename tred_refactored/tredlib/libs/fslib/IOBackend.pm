package IOBackend;
BEGIN {
  require Treex::PML::IO;
  my $o = 'Treex::PML::IO';
  foreach my $name (keys %{$o.'::'}) {
      if ($name eq 'ISA') {
      	@{__PACKAGE__.'::ISA'}=@{$o.'::ISA'};
      } else {
      	${__PACKAGE__.'::'}{$name} = ${$o.'::'}{$name}; # namespace copy
      }
  }
}

require Carp;
Carp::carp("Module IOBackend is deprecated, use Treex::PML::IO instead")
  unless (caller())[0] eq 'Fslib';

1;
__END__

=head1 NAME

IOBackend - compatibility module, use Treex::PML::IO instead!

=head1 DESCRIPTION

DEPRECATED!

This module is provided for backward compatibility only. Please use
Treex::PML::IO instead!

=head1 SEE ALSO

C<Treex::PML::IO>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

