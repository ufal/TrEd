package Tk::ErrorReport;

# pajas@ufal.mff.cuni.cz          14 èen 2007

use strict;
use warnings;

# this package actually adds a method to Tk::Widget

use Tk::widgets qw(ROText);

sub Tk::Widget::ErrorReport {
    my ( $w, %opts ) = @_;

    require Tk::BindMouseWheel;
    require Tk::BindButtons;
    require Tk::ROText;

    my $mw      = $w->toplevel;
    my $msgtype = delete $opts{-msgtype} || 'ERROR';
    my $msg     = delete $opts{-message};
    my $body    = delete $opts{-body};
    my $d = $mw->DialogBox( ( $opts{-buttons} ? ( -buttons => ['OK'] ) : () ),
        %opts );
    $d->Label(
        -text       => $msgtype,
        -justify    => 'left',
        -foreground => 'red'
    )->pack( -pady => 5, -side => 'top', -fill => 'x' );
    $d->Label(
        -text    => $msg,
        -justify => 'left'
    )->pack( -pady => 10, -side => 'top', -fill => 'x' );
    my $t = $d->Scrolled(
        qw/ROText -relief sunken -borderwidth 2
            -scrollbars oe/
    );
    $t->Subwidget('scrolled')->menu->delete('File');
    $t->pack(qw/-side top -expand yes -fill both/);
    $t->insert( '0.0', $body );
    $t->BindMouseWheelVert();
    $d->BindButtons;
    return $d->Show;
}

1;

__END__

=head1 NAME

Tk::ErrorReport - dialog box for reporting long error messages

=head1 SYNOPSIS

 $answer = 
   $widget->ErrorReport(
     -msgtype => "ERROR", # this is default
     -title   => "window title",
     -message => "short information message",
     -body    => "long message",
     -buttons => [qw(Abort Ignore)],
     # ... other Tk::DialogBox options
  );

=head1 DESCRIPTION

Displays a dialog box with a short message label and a Tk::ROText
window containing the main message text (body).

The function returns the label of the invoked button (like
Tk::Dialog::Show()).

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

