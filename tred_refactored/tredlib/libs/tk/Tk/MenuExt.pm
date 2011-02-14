package Tk::MenuExt;
# pajas@ufal.mff.cuni.cz          25 èen 2007

use 5.008;
use strict; 
use warnings;
use Carp;

use Tk::widgets qw/ Menu /;
use base qw/ Tk::Derived Tk::Menu /;

Construct Tk::Widget 'MenuExt';

sub InitObject {
  my( $self, $args ) = @_;
  $self->ConfigSpecs(
    '-unpostcommand'    => [ 'CALLBACK', 'unpostcommand', 'unpostCommand',   undef ],
   );
  $self->Tk::Menu::InitObject( $args );
}

sub unpost {
  my( $self ) = @_;

  # the following nasty line tries to determine whether the unpost() call
  # was caused by invoking a menu entry or by cancelling the menu
  my $from_invoke = (grep { (caller($_))[3] eq 'Tk::Menu::Invoke' } 1..5) ? 1 : 0;

  $self->Callback('-unpostcommand',$from_invoke);
  $self->SUPER::unpost();
  return; # current value
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Tk::MenuExt - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Tk::MenuExt;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Tk::MenuExt, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

