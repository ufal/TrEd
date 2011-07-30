package TrEd::Query::List;

use strict;
use warnings;

require TrEd::MinMax;
use TrEd::Config qw{$font $maxDisplayedValues};

require TrEd::Dialog::FocusFix;

use Tk;

# was main::listQuery
sub new_query {
    my ( $w, $title, $select_mode, $vals, $selected, %opts ) = @_;
    my $top = $w->toplevel();
    my $d   = $w->DialogBox(
        -title   => $title,
        -width   => '8c',
        -buttons => [ "OK", "Cancel" ],
        ref( $opts{dialog} ) ? %{ $opts{dialog} } : (),
    );
    $d->BindReturn( $d, 1 );
    $d->BindEscape();
    if ( ref( $opts{label} ) ) {
        $d->Label( %{ $opts{label} } )->pack(qw/-side top/);
    }
    my $l = $d->Scrolled(
        qw/Listbox -relief sunken
            -takefocus 1
            -width 0
            -scrollbars e/,
        -font       => $font,
        -selectmode => $select_mode,
        -height =>
            TrEd::MinMax::min( $maxDisplayedValues, scalar( @{$vals} ) ),
        ref( $opts{list} ) ? %{ $opts{list} } : ()
    )->pack(qw/-expand yes -fill both/);
    $l->insert( 'end', @$vals );
    if ( @$vals > 0 ) {
        $l->activate(0);
    }
    $l->BindMouseWheelVert();
    my $f = $d->Frame()->pack(qw/-fill x/);
    if ( $select_mode eq 'multiple' ) {
        $f->Button(
            -text      => 'All',
            -underline => 0,
            -command   => [
                sub {
                    my ($list) = @_;
                    $list->selectionSet( 0, 'end' );
                },
                $l
            ]
        )->pack( -side => 'left' );
        $f->Button(
            -text      => 'None',
            -underline => 0,
            -command   => [
                sub {
                    my ($list) = @_;
                    $list->selectionClear( 0, 'end' );
                },
                $l
            ]
        )->pack( -side => 'left' );
    }
    else {
        $l->bind( '<Double-1>', sub { $d->{selected_button} = 'OK' } );
    }
    if ( ref( $opts{buttons} ) ) {
        foreach my $b ( @{ $opts{buttons} } ) {
            if ( ref( $b->{-command} ) eq 'ARRAY' ) {
                push @{ $b->{-command} }, $l;
            }
            $f->Button(%$b)->pack( -side => 'left' );
        }
    }
    Tk::Callback->new( $opts{init} )->Call( $d, $l, $f ) if $opts{init};
    $d->BindButtons;
    my $act = 0;
    my %selected = map { $_ => 1 } @$selected;
    for ( $a = 0; $a < @$vals; $a++ ) {
        if ( $selected{ $$vals[$a] } ) {
            $l->selectionSet($a);
            if ( not $act ) {
                $act = 1;
                $l->activate($a);
                $l->see($a);
            }
        }
    }
    $l->focus;
    my $result = TrEd::Dialog::FocusFix::show_dialog( $d, $l, $top );

    if ( $result !~ /Cancel/ ) {
        @$selected = ();
        my @ret;
        foreach ( 0 .. $l->size - 1 ) {
            if ( $l->selectionIncludes($_) ) {
                push @$selected, $l->get($_);
                push @ret,       $_;
            }
        }
        $d->destroy;
        return \@ret;
    }
    $d->destroy;
    return;
}

1;
