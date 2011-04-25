package Tk::ChoicePopup;
# pajas@ufal.mff.cuni.cz          14 èen 2007

# this package actually adds a method to Tk::Toplevel

# cached popup and super-paranoia regarding nodes and edges in a callback

use Carp;
use Scalar::Util qw(weaken);
my %menu; # here we cache one popup menu per top-level window

my $invoke_callback;
my $cancel_callback;

sub Cancel {
  my ($menu,$from_invoke) = @_;
  local $SIG{__DIE__} = \&Carp::confess; # we want to know what happend in case of error
  unless ($from_invoke and $menu->index('active') ne 'none') {
    Tk::Callback->new($cancel_callback)->Call() if defined $cancel_callback;
    undef $cancel_callback;
    undef $invoke_callback;
  }
}

sub Invoke {
  local $SIG{__DIE__} = \&Carp::confess; # we want to know what happend in case of error
  Tk::Callback->new($invoke_callback)->Call(@_) if defined $invoke_callback;
  undef $cancel_callback;
  undef $invoke_callback;
}

sub Tk::Toplevel::ChoicePopup {
  my ($mw, %opts)=@_;
  my $choices = $opts{-choices};
  croak "Tk::ChoicePopup: -choices must be an ARRAYREF\n" unless ref($choices) eq 'ARRAY';
  ($invoke_callback,$cancel_callback) = @opts{qw(-command -cancelcommand)};
  my $menu = $menu{$mw};
  use Tk::MenuExt;
  if (defined $menu) {
    $menu->delete(0,'end');
    $_->destroy for $menu->children;
  } else {
    $menu{$mw} = $menu = $mw->MenuExt(
      -tearoff => 0,
      -relief => 'groove',
      -borderwidth => 2,
      -menuitems => []);
    $menu->configure(-unpostcommand => [ \&Cancel, $menu ]);
  }
  for my $choice (@$choices) {
    $menu->add( 'command',
		-label => $choice,
		-command => [ \&Invoke, $choice ]
	       );
  }
  $opts{-popover}   ||= 'cursor';
  $opts{-popanchor} ||= 'nw';
  $menu->Popup( 
    map { exists $opts{$_} ? ($_ => $opts{$_}) : () } qw(-popover -overanchor -popanchor)
  );
}


1;
__END__

=head1 NAME

Tk::ChoicePopup - a simple cached popup-menu that does not keep any callback data

=head1 SYNOPSIS

   $mw->ChoicePoupup(
     -choices => ['a'..'z' ],
     -command => sub { print $_[0] },
     -cancelcommand => sub { print 'none' },
     [... optional Tk::Popup options ... ],
   );

=head1 DESCRIPTION

This method displays a popup menu with simple button menu items whose
labels are given in the -choices option and associates them with the
command callback.  The callback gets the selected item's label as its
last argument. An optional -cancelcommand is called if the menu was
unposted without any item being selected. Optionally, Tk::Poupup
options may be passed.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

