package Tk::BindReturn;

# pajas@ufal.mff.cuni.cz          14 èen 2007

sub Tk::Widget::_DialogReturn {
    my ( $w, $no_default ) = @_;
    my $f = $w->focusCurrent;
    my $button;
    if ( $f and $f->isa('Tk::Button') ) {
        $button = $f;
    }
    elsif ( !$no_default ) {
        $button = $w->toplevel->{default_button};
    }
    if ($button) {
        $button->flash;
        $button->invoke;
    }
    Tk->break;
}

sub Tk::Widget::BindReturn {
    my ( $d, $widget, $also_normal_return ) = @_;
    $widget = $d unless defined $widget;
    $d->bind( $widget, '<Control-Return>', '_DialogReturn' );
    $d->bind( $widget, '<Return>', '_DialogReturn' ) if $also_normal_return;
}

sub Tk::Widget::BindEscape {
    my ( $d, $widget, $button ) = @_;
    $widget = $d       unless defined $widget;
    $button = 'Cancel' unless defined $button;

    # Make Escape and WM_DELETE_WINDOW act as pressing $button
    my $sub = sub {
        my ( $w, $d ) = @_;
        $d = $d->toplevel;
        $d->afterIdle( sub { $d->{selected_button} = $button } );
    };
    $d->bind( $widget, '<Escape>' => [ $sub, $d ] );
    $d->protocol( 'WM_DELETE_WINDOW' => [ $sub, $d, $d ] );
}

1;

__END__


=head1 NAME

Tk::DialogReturn - binds Control-Return to the default dialog button

=head1 SYNOPSIS

   use Tk::DialogReturn;
   $d = $mw->DialogBox();
   ...
   $d->BindReturn();

=head1 DESCRIPTION

Binds Control-Return on all dialog subwidgets to invoke the currently
focused button or the default dialog button if no button is focused.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Tk::DialogBox Tk::bind

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

