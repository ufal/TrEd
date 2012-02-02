package TrEd::Dialog::CopyTrees;

use strict;
use warnings;

use Tk;
use TrEd::Config qw{$buttonsRelief $font};

require TrEd::Print;
require TrEd::File;
require TrEd::Dialog::FocusFix;
require TrEd::View::Sentence;

# was main::copyTreesDialog
sub show_dialog {
    my ($grp) = @_;
    return unless $grp->{focusedWindow}->{FSFile};
    my ( $Entry, @Entry ) = main::get_entry_type();
    my $range       = $grp->{focusedWindow}->{treeNo} + 1;
    my $source      = $grp->{focusedWindow}->{FSFile};
    my $destination = $grp->{focusedWindow}->{FSFile};
    my $d           = $grp->{top}->DialogBox(
        -title   => 'Copy Trees',
        -buttons => [ 'OK', 'Cancel' ]
    );
    $d->BindReturn( $d, 1 );
    $d->resizable( 0, 0 );
    main::addBindTags( $d, 'dialog' );
    $d->BindEscape();
    $d->bind( '<Tab>',                [ sub { shift->focusNext; } ] );
    $d->bind( '<Shift-Tab>',          [ sub { shift->focusPrev; } ] );
    $d->bind( '<Shift-ISO_Left_Tab>', [ sub { shift->focusPrev; } ] );
    my $ff = $d->Frame();
    $ff->Label(
        -text    => 'Destination file:',
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    my @items;
    my $i = 1;

    foreach my $of ( TrEd::File::get_openfiles() ) {
        push @items, $i++ . ". " . $of->filename();
    }
    my $om = $ff->Optionmenu(
        -relief   => $buttonsRelief,
        -options  => \@items,
        -variable => \$destination
    )->pack(qw/-side left -padx 10/);
    $om->menu->bind( "<KeyPress>",
        [ \&main::NavigateMenuByFirstKey, Ev('K') ] );
    $ff->pack(qw/-pady 10 -padx 10 -side top -expand yes -fill x/);
    my $sf = $d->Frame();
    my $re = $sf->$Entry(
        @Entry,
        -relief       => 'sunken',
        -width        => 20,
        -font         => $font,
        -textvariable => \$range
    );
    main::set_grp_history( $grp, $re, 'treeRange' );
    $sf->Label(
        -text    => 'Trees selection (range):',
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    $re->pack(qw/-side left -padx 10 -fill x -expand yes/);
    $sf->Button(
        -image   => main::icon( $grp, '1leftarrow' ),
        -command => [
            sub {
                my ( $grp, $range ) = @_;
                $$range = TrEd::View::Sentence::get_selection($grp);
            },
            $grp,
            \$range
        ]
    )->pack(qw/-padx 10 -side left/);
    $sf->Button(
        -image   => main::icon( $grp, 'contents' ),
        -command => [
            sub {
                my ( $grp, $d, $range, $source ) = @_;
                my $list = [];
                foreach ( TrEd::Print::parse_print_list( $source, $$range ) )
                {
                    $list->[ $_ - 1 ] = 1;
                }
                $$range = TrEd::View::Sentence::get_selection(
                    $grp,
                    TrEd::View::Sentence::show_sentences_dialog(
                        $grp, $d, $source, $list
                    )
                );
            },
            $grp,
            $d,
            \$range,
            $source
        ]
    )->pack(qw/-padx 10 -side left/);
    $sf->pack(qw/-pady 10 -padx 10 -side bottom -expand yes -fill x/);

    $d->BindButtons;
    my $result = TrEd::Dialog::FocusFix::show_dialog( $d, $re, $grp->{top} );
    main::get_grp_history( $grp, $re, 'treeRange' ) if ( $result =~ /OK/ );
    $d->destroy();
    undef $d;
    if ( $result =~ /OK/ ) {
        $destination =~ /^(\d+)/;
        my @open_files = TrEd::File::get_openfiles();
        my $fs         = $open_files[ $1 - 1 ];
        return unless ref($fs);
        my @list = TrEd::Print::parse_print_list( $source, $range );
        my $tree;
        my $any;
        foreach my $l (@list) {
            $tree = $source->tree( $l - 1 );
            if ($tree) {
                $fs->insert_tree( $fs->FS->clone_subtree($tree),
                    $fs->lastTreeNo + 1 );
                $any = 1;
            }
        }
        if ($any) {
            $fs->notSaved(1);
            main::get_nodes_fsfile( $grp, $fs );
            main::redraw_fsfile( $grp, $fs );
        }
    }
}

1;
