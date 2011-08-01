package TrEd::Dialog::SelectValues;

use strict;
use warnings;

use TrEd::Config qw{$maxDisplayedValues $font $tredDebug};
use Tk;

require TrEd::Query::String;

# was main::selectValuesDialog
sub show_dialog {
    my ( $grp, $attr, $vals, $selected, $may_add, $lastFocus, $force ) = @_;
    print "select values...\n\n";
    my $a;
    my $multi = 0;
    my @prevSelectionSet;

    my $top = $grp->{top};
    $top->Busy( -recurse => 1 );
    my $enabled = (
        $force
            or doEvalHook( $grp->{focusedWindow}, 'enable_attr_hook', $attr,
            "ambiguous" ) ne 'stop'
    );

    my $d = $top->DialogBox(
        -title => ( $enabled ? "$attr: select values" : "$attr: values" ),
        -width => '8c',
        -buttons => ( $enabled ? [ "OK", "Cancel" ] : ["Cancel"] )
    );
    $d->BindReturn( $d, 1 );
    $d->BindEscape();
    $d->resizable( 0, 0 );
    my $l = $d->Scrolled(
        qw/Listbox -relief sunken -takefocus 1 -scrollbars oe/,
        -height => min( $maxDisplayedValues, scalar(@$vals) ),
        -font   => $font
    )->pack(qw/-expand yes -fill both/);
    disable_scrollbar_focus($l);
    $l->insert( 'end', @$vals );
    $l->BindMouseWheelVert();

    if ($enabled) {
        $l->bind(
            '<Double-ButtonPress-1>' => [
                sub {
                    my $w = shift;
                    my $d = shift;
                    my $e = $w->XEvent;
                    $w->BeginSelect( $w->index( $e->xy ) );
                    $d->{selected_button} = 'OK';
                },
                $d
            ]
        );
    }
    my $act = 0;
    for ( $a = 0; $a < @$vals; $a++ ) {
        if ( grep { $$vals[$a] eq $_ } @$selected ) {
            $l->selectionSet($a);
            if ( not $act ) {
                print "Activating $a\n" if $tredDebug;
                $act = 1;
                $l->activate($a);
                $l->see($a);
            }
        }
    }
    if ($enabled) {
        $d->Checkbutton(
            -text     => 'multiple select',
            -variable => \$multi,
            -command  => [
                sub {
                    shift->configure(
                        -selectmode => $multi ? 'multiple' : 'browse' );
                },
                $l
            ],
            -relief => 'flat'
        )->pack();
        if ($may_add) {
            $d->Button(
                -text    => 'Add',
                -command => [
                    sub {
                        my ( $grp, $l, $vals, $attr ) = @_;
                        $grp->{"histValue:$attr"} = []
                            unless $grp->{"histValue:$attr"};
                        my $val
                            = TrEd::Query::String::new_query( $grp,
                            "Add new value",
                            "Value", undef, 0, $grp->{"histValue:$attr"} );
                        return unless defined $val;
                        push @$vals, $val;
                        $l->insert( 'end', $val );
                        $l->selectionClear( 0, $l->size - 1 ) unless $multi;
                        $l->selectionSet( $l->size - 1 );
                    },
                    $grp,
                    $l,
                    $vals,
                    $attr
                ]
            )->pack();
        }
    }
    $top->Unbusy();
    $l->focus;
    $d->BindButtons;
    my $result = TrEd::Dialog::FocusFix::show_dialog( $d, $l, $lastFocus );
    if ( $result =~ /OK/ ) {

        # Hajic wanted this (I wash my hands):
        # first we store the values, which were selected originaly and
        # stayed selected
        foreach my $s (@$selected) {
            push @prevSelectionSet,
                ( grep { $$vals[$_] eq $s } ( 0 .. $l->size - 1 ) );
        }
        @$selected = ();
        foreach (@prevSelectionSet) {
            if ( $l->selectionIncludes($_) ) {
                $l->selectionClear($_);
                push @$selected, $$vals[$_];
            }
        }
        foreach ( 0 .. $l->size - 1 ) {
            push @$selected, $$vals[$_] if $l->selectionIncludes($_);
        }
        $d->destroy;
        undef $d;
        return 1;
    }
    $d->destroy;
    undef $d;
    return 0;
}

1;
