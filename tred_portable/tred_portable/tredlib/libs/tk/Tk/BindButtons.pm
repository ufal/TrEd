package Tk::BindButtons;

# pajas@ufal.mff.cuni.cz          14 èen 2007

use strict;
use warnings;

use Tk;

# this package actually adds a method to Tk::Widget

our $VERSION = '0.1';

# a private helper routine
my $_descendant_widgets;
$_descendant_widgets = sub {
    return ( $_[0], map { $_descendant_widgets->($_) } $_[0]->children );
};

sub Tk::Widget::BindButtons {
    my ( $w, @subwidgets ) = @_;
    my $top = $w->toplevel;
    my %bind;
    foreach my $button (
        grep { ref $_ && ( $_->isa('Tk::Button') || $_->isa('Tk::Label') ) }
        $_descendant_widgets->($w)
        )
    {
        my $ul = $button->cget('-underline');
        if ( defined $ul && $ul >= 0 ) {
            my $text = $button->cget('-text');
            my $key = lc substr $text, $ul, 1;
            $bind{$key} = $button;
        }
    }
    if ( $w->isa('Tk::Dialog') or $w->isa('Tk::DialogBox') ) {
        unshift @subwidgets, $w->Subwidget('bottom');
    }
    my %seen;
    foreach my $button (
        grep { ref $_ && $_->isa('Tk::Button') }
        map { $_descendant_widgets->($_) }
        grep { defined }
        @subwidgets
        )
    {
        next if $seen{$button};
        $seen{$button} = 1;
        my $text = $button->cget('-text');
        next if $button->cget('-underline') >= 0;
        for my $i ( 0 .. length $text ) {
            my $key = lc substr $text, $i, 1;
            if ( $key =~ /[a-zA-Z.]/ && !exists $bind{$key} ) {
                $button->configure( -underline => $i );
                $bind{$key} = $button;
                last;
            }
        }
    }
    for my $key ( keys %bind ) {
        my $button = $bind{$key};
        next if !$button->isa('Tk::Button');
        next if $key !~ /^[a-zA-Z.]$/i;
        $key =~ s/^\.$/period/;
        $top->bind( "<Alt-$key>",
            [ sub { $_[1]->flash; $_[1]->invoke; }, $button ] );
    }
    return;
}

1;


__END__



=head1 NAME


Tk::BindButtons - automatically create keyboard shortcuts for Tk buttons


=head1 VERSION

This documentation refers to 
Tk::BindButtons version 0.01.


=head1 SYNOPSIS


    $dialog->BindButtons();

=head1 DESCRIPTION


This function finds all buttons with -underline option set and creates
a corresponding Alt+key keyboard binding. For Dialog or DialogBox
widgets this function also automatically underlines the dialog buttons
and creates the corresponding bindings (using the first letter that is
not occupied by buttons or labels inside the dialog).



=head1 SUBROUTINES/METHODS

=over 4 







=back


=head1 DIAGNOSTICS

No diagnostic messages.


=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.


=head1 DEPENDENCIES

CPAN modules:
Tk

TrEd modules:


Standard Perl modules:


=head1 INCOMPATIBILITIES

No known incompatibilities.


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 
2007 Petr Pajas (code & part of documentation) <pajas@matfyz.cz>
2011 Peter Fabian (documentation). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
