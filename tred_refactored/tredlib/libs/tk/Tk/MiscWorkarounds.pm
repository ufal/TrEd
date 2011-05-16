package Tk::MiscWorkarounds;
# pajas@ufal.mff.cuni.cz          04 bøe 2010

use 5.008;
use strict;
use warnings;
use Carp;

use Tk;
use Tk::Wm;
use Tk::Menu;

sub apply_workarounds {
  my ($mw)=@_;
  if ($^O eq 'MSWin32') {
    # a workaround for focus being lost after popup menu usage on Win32
    $mw->bind('Tk::Menu', '<<MenuSelect>>', sub { if ($Tk::popup) { $Tk::popup->Unpost; } });
  }
  return $mw;
}

# work around a bug in Tk
if (defined $Tk::encodeFallback and $Tk::encodeFallback == Encode::FB_PERLQQ() and
    Encode::FB_PERLQQ() != Encode::PERLQQ()) {
  $Tk::encodeFallback    = Encode::PERLQQ();
}

{
  package Tk::Wm;

  # overwriting the original Tk::Wm::Post:
  sub Post {
    my ($w,$X,$Y)= @_;
    $X= int($X);
    $Y= int($Y);
    $w->positionfrom('user');
    # $w->geometry("+$X+$Y");
    $w->MoveToplevelWindow($X,$Y);
    $w->deiconify;
    ## This causes the "slowness":
    # $w->raise;
  }
}



1;
__END__

=head1 NAME

Tk::MiscWorkarounds - work-around several bugs in Tk (or particular versions of it)

=head1 SYNOPSIS

   use Tk::MiscWorkarounds;
   my $mw = Tk::MiscWorkarounds::apply_workarounds( Tk::MainWindow->new );

=head1 DESCRIPTION

This module applies the following fixes to the Tk (some are applied
globally when the module is loaded, other are applied to a particular
main window using Tk::MiscWorkarounds::apply_workarounds().

=item 'selection conversion left too many bytes unconverted' bug

See http://cpansearch.perl.org/src/SREZIC/Tk-804.027_501/Changes

Applied on load.

=item reimplementation of Tk::Wm::Post()

Replacing a call to geometry() with MoveToplevelWindow and disabling a
call to raise(), which caused slowness with some window managers.

Applied on load.

=item focus being lost after popup menu usage on Win32

Applied to a specified main window using apply_workarounds();

=head2 EXPORT

None by default.

=head1 SEE ALSO

  Tk

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

