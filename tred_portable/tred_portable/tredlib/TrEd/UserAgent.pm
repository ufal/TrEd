# -*- cperl -*-
# pajas@ufal.mff.cuni.cz          24 zar 2008

package TrEd::UserAgent;

use strict;
use base qw(LWP::UserAgent);
use Tk::BindButtons;
use Tk::DialogReturn;

sub new {
    my $class = shift;
    my $mw    = shift;
    my $self  = $class->SUPER::new(@_);
    $self->{ToplevelWindow} = $mw;
    return $self;
}

sub get_basic_credentials {
    my $self = shift;
    my ( $realm, $uri ) = @_;
    my @ret = $self->LWP::UserAgent::get_basic_credentials(@_);
    unless ( grep { defined and length } @ret ) {
        my $mw = $self->{ToplevelWindow};
        if ($mw) {
            my $d;
            unless ( $d = $self->{CredentialsDialog} ) {
                $d = $self->{CredentialsDialog} = $mw->DialogBox(
                    -title   => 'Authorization required',
                    -buttons => [qw(OK Cancel)],
                );
                $d->add(
                    'Label',
                    -text    => "Authorization required for",
                    -justify => 'left',
                    -anchor  => 'nw',
                )->pack( -fill => 'x', -expand => 1 );
                $self->{AuthLabel} = $d->add(
                    'Label',,
                    -justify => 'left',
                    -anchor  => 'nw',
                    -text    => ''
                )->pack( -fill => 'x', -expand => 1 );
                $d->add(
                    'Label',
                    -text    => 'Username:',
                    -justify => 'left',
                    -anchor  => 'nw'
                )->pack( -fill => 'x', -expand => 1 );
                $self->{UsernameEntry}
                    = $d->add( 'Entry', -background => 'white' )
                    ->pack( -fill => 'x', -expand => 1 );
                $d->add(
                    'Label',
                    -text    => 'Passphrase:',
                    -justify => 'left',
                    -anchor  => 'nw'
                )->pack( -fill => 'x', -expand => 1 );
                $self->{PasswordEntry}
                    = $d->add( 'Entry', -background => 'white', -show => '*' )
                    ->pack( -fill => 'x', -expand => 1 );
                $d->configure( -focus => $self->{UsernameEntry} );
                $d->BindButtons;
                $d->BindReturn( $d, 1 );
                $d->BindEscape();
            }
            my ($busy) = grep { $_ eq 'Busy' } $mw->bindtags;
            my $cursor = $mw->cget('-cursor');
            $mw->Unbusy();
            my $host_port = lc( $uri->host_port );
            $self->{AuthLabel}
                ->configure( -text => "$realm on server $host_port" );
            if ( $d->Show eq 'OK' ) {
                my $user     = $self->{UsernameEntry}->get;
                my $password = $self->{PasswordEntry}->get;
                $self->LWP::UserAgent::credentials( $host_port, $realm, $user,
                    $password );
                @ret = $self->LWP::UserAgent::get_basic_credentials(@_);
            }
            $mw->Busy( -recurse => 1, -cursor => $cursor ) if $busy;
        }
    }
    return @ret;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::UserAgent - a basic LWP::UserAgent that uses Tk dialog to ask for credentials

=head1 SYNOPSIS

   use Tk;
   my $mw = MainWindow->new;

   use TrEd::UserAgent;
   my $ua=TrEd::UserAgent->new($mw);

=head1 DESCRIPTION

This class inherits from LWP::UserAgent and reimplements
get_basic_credentials() so that if the credentials are not stored in
the agent's cache, a Tk::DialogBox is shown asking the user for
the credentials.

=head2 EXPORT

None by default.

=head1 SEE ALSO

L<LWP::UserAgent>, L<Tk>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

