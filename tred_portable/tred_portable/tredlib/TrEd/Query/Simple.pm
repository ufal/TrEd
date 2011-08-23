package TrEd::Query::Simple;

use strict;
use warnings;

use TrEd::Config qw{$font};
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::Convert;

use Tk;

# was main::Query
sub new_query {
    my ( $w, $title, $label, $default_text, $select, $hist ) = @_;
    my $newvalue = TrEd::Convert::encode($default_text);
    my $d        = $w->DialogBox(
        -title   => $title,
        -buttons => [ "OK", "Cancel" ]
    );
    $d->BindReturn( $d, 1 );
    $d->BindEscape;
    main::addBindTags( $d, 'dialog' );
    my ( $Entry, @Eopts ) = main::get_entry_type();
    my $e = $d->add(
        $Entry,
        -relief       => 'sunken',
        -width        => 40,
        -takefocus    => 1,
        -font         => $font,
        -textvariable => \$newvalue
    );

    if ( $e->can('history') and ref($hist) ) {
        $e->history($hist);
    }
    $e->selectionRange(qw(0 end)) if ($select);
    my $l = $d->Label(
        -text    => encode($label),
        -anchor  => 'e',
        -justify => 'right'
    );
    $l->pack( -side => 'top' );
    $e->pack( -side => 'left' );
    $d->resizable( 0, 0 );

    #  $e->focus;
    $d->BindButtons;
    my $result = TrEd::Dialog::FocusFix::show_dialog( $d, $e, $w );
    if ( $result =~ /OK/ ) {
        if ( ref($hist) and $e->can('historyAdd') ) {
            $e->historyAdd($newvalue) if $newvalue ne $EMPTY_STR;
            @$hist = $e->history();
        }
    }
    $d->destroy;
    undef $d;
    if ( $result =~ /OK/ ) {
        return TrEd::Convert::decode($newvalue);
    }
    else {
        return;
    }
}

1;
