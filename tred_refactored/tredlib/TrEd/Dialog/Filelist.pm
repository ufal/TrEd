package TrEd::Dialog::Filelist;

use strict;
use warnings;

use TrEd::Basics qw{$EMPTY_STR};
use TrEd::ManageFilelists;
use TrEd::Filelist::View;
use Treex::PML;

my $filelist_widget;

sub filelist_widget {
    return $filelist_widget;
}

sub _show_hidden_files {
    my ( $grp, $fsel, $show_hidden ) = @_;
    $fsel->configure( -showhidden => $show_hidden );
    $fsel->ReadDir( $fsel->getCWD );
}

sub _filter {
    my ( $fsel, $filter ) = @_;
    $fsel->SetFilter( '', $filter );
}

sub _add_files {
    my ( $grp, $t, $l ) = @_;
    my $anchor           = $t->info('anchor');
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    my $pos
        = defined($anchor)
        ? getFilelistLinePosition( $current_filelist, $anchor )
        : 0;
    TrEd::ManageFilelists::insertToFilelist( $grp, $current_filelist, $pos,
        $l->getSelectedFiles );
    TrEd::Bookmarks::updateBookmarks($grp)
        if ( ref($current_filelist)
        and $current_filelist->name eq 'Bookmarks' );
}

sub _remove_files {
    my ( $grp, $t ) = @_;
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    TrEd::ManageFilelists::removeFromFilelist( $grp, $current_filelist,
        getFilelistLinePosition( $current_filelist, $t->info('anchor') ),
        $t->info('selection') );
    TrEd::Bookmarks::updateBookmarks($grp)
        if ( ref($current_filelist)
        and $current_filelist->name eq 'Bookmarks' );
}

sub _show_in_tred {
    my ($grp) = @_;
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    $current_filelist->set_current(
        $filelist_widget->info( 'data', $filelist_widget->info('anchor') ) );
    TrEd::ManageFilelists::selectFilelist( $grp, $current_filelist );
}

sub _double_click {
    my ( $w, $grp ) = @_;
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    my $anchor           = $filelist_widget->info('anchor');
    my $nextentry        = $filelist_widget->info( 'next', $anchor );
    my $data             = $filelist_widget->info( 'data', $anchor );
    my $nextentry_parent;
    if (defined $nextentry) {
        $nextentry_parent = $filelist_widget->info( 'parent', $nextentry );
    } 
    if (    $nextentry && $nextentry_parent 
        && $nextentry_parent eq $anchor )
    {

        # pattern -> edit
        my $position = $current_filelist->find_pattern($data);
        $grp->{'hist-fileListPattern'} = []
            unless $grp->{'hist-fileListPattern'};
        $data = Query(
            $filelist_widget->toplevel,
            "Selection Pattern",
            "Edit directory pattern for $data",
            $data, 1, $grp->{'hist-fileListPattern'}
        );
        if ( defined($data) ) {
            print "Removing ", $filelist_widget->info( 'data', $anchor ), "\n"
                if $main::tredDebug;
            $current_filelist->remove(
                $filelist_widget->info( 'data', $anchor ) );
            print "Adding $data\n" if $main::tredDebug;
            $current_filelist->add( $position, $data );
            feedHListWithFilelist( $grp, $filelist_widget,
                $current_filelist );
        }
    }
    else {

        # file -> go to
        $current_filelist->set_current($data);
        TrEd::ManageFilelists::selectFilelist( $grp, $current_filelist );
    }
}

sub _destroy {
    shift;
    my $grp = shift;
    $filelist_widget = undef;
    TrEd::ManageFilelists::set_current_filelist(undef);
}

sub _escape {
    my ($forget, $dialog, $modal) = @_;
    $modal ? $dialog->{selected_button} = "Cancel" : $dialog->destroy();
}

sub _close {
    my ($dialog, $modal) = @_;
    $modal ? $dialog->{selected_button} = "Cancel" : $dialog->destroy();
}

sub _delete {
    my ( $grp, $d, $filelistref ) = @_;
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    my $fl               = $current_filelist;
    if (    $fl
        and $fl->name ne 'Default'
        and main::userQuery(
            $d,
            "Realy delete filelist '" . $fl->name . "'?\n",
            -bitmap  => 'question',
            -title   => "Delete filelist?",
            -buttons => [ 'Delete', 'Cancel' ]
        ) eq 'Delete'
        )
    {
        TrEd::ManageFilelists::deleteFilelist( $grp, $current_filelist );
        $fl = $current_filelist;
        $$filelistref = ( $fl && $fl->name || '' );
    }
}

sub _save_fl_to_file {
    my ( $grp, $d ) = @_;
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    my $file             = $current_filelist->filename;
    unless ( defined($file) and $file ne $EMPTY_STR ) {
        my $initdir = TrEd::Convert::dirname($file);
        $initdir = cwd() if ( $initdir eq './' );
        $initdir =~ s!${TrEd::Convert::Ds}$!!m;
        $file = main::get_save_filename(
            $d,
            -filetypes =>
                [ [ "Filelists", ['.fl'] ], [ "All files", [ '*', '*.*' ] ] ],
            -title       => "Save filelist as ...",
            -initialdir  => $initdir,
            -initialfile => TrEd::Convert::filename($file)
        );
        $d->deiconify();
        $d->focus();
        $d->raise();
        $file .= ".fl" unless $file =~ /\.fl$/;
        return unless ( defined $file and $file ne $EMPTY_STR );
        $current_filelist->filename($file);
    }
    $current_filelist->save();
}

sub _create_fl {
    my ( $grp, $d, $filelistref ) = @_;
    my $fl = TrEd::ManageFilelists::createNewFilelist( $grp, $d );
    $$filelistref = $fl->name if defined $fl;
}

# sub filelistDialog {
sub create_dialog {
    use Tk::LabFrame;
    my ( $grp, $modal ) = @_;
    my $win = $grp->{focusedWindow};
    if ( defined( $filelist_widget ) ) {
        if ($modal) {
            main::ShowDialog( $filelist_widget->toplevel );
        }
        else {
            $filelist_widget->toplevel->deiconify();
            $filelist_widget->toplevel->focus();
            $filelist_widget->toplevel->raise();
        }
        return;
    }
    return if ( $filelist_widget );

    $grp->{top}->Busy( -recurse => 1 );
    my $filelist;
    if ( !ref( $win->{currentFilelist} ) ) {
        if ( $win->{FSFile} ) {
            TrEd::Basics::errorMessage(
                $win,
                "Cannot manage file-lists while visiting a file not belonging to any file-list! "
                    . "Please, switch to a file-list (e.g. using Session->Default) and try again.",
                1
            );
            $grp->{top}->Unbusy();
            return;
        }
        else {
            TrEd::ManageFilelists::selectFilelist( $grp, 'Default' );
        }
    }

    TrEd::ManageFilelists::set_current_filelist( $win->{currentFilelist} );
    my $current_filelist = TrEd::ManageFilelists::get_current_filelist();
    $filelist = $current_filelist->name();
    my $d = $grp->{top}->Toplevel( -title => "Filelist" );
    $d->withdraw();
    $grp->{filelistDialog} = $d;

    my $botframe = $d->Frame()->pack(qw/-fill both -side bottom/);
    my $topframe = $d->Frame()->pack(qw/-fill both -side top -expand 1/);

    my $labframe = $topframe->LabFrame(
        -label     => 'Files to add',
        -labelside => 'acrosstop'
    )->pack(qw/-expand no -fill both -side left/);
    $labframe->Subwidget('label')->configure( -underline => 0 );
    my $fsel = $labframe->MyFileSelect(
        -selectmode => 'extended',
        -takefocus  => 1,
        -textentry  => 1,
    )->pack(qw/-expand yes -fill both -side left -padx 5 -pady 5/);
    $fsel->Subwidget('filelist')
        ->configure( -background => 'white', -setgrid => 1 );
    my $show_hidden = 0;
    my $menu        = $fsel->Menu(
        -tearoff   => 0,
        -menuitems => [
            [   'Checkbutton' => '~Show hidden files',
                -variable     => \$show_hidden,
                -command =>
                    [ \&_show_hidden_files, $grp, $fsel, $show_hidden ]
            ],
            [   'Cascade'  => '~Filter',
                -tearoff   => 0,
                -menuitems => [
                    map {
                        [   Button   => $_->[0],
                            -command => [
                                \&_filter,
                                $fsel,
                                (   ref( $_->[1] )
                                    ? join( ' ', @{ $_->[1] } )
                                    : $_->[1]
                                )
                            ],
                        ]
                        } @TrEd::Config::open_types
                ]
            ],
        ]
    );
    $fsel->Subwidget('filelist')
        ->bind( '<3>',
        sub { my ($w) = @_; $menu->Post( $w->pointerxy ); Tk->break; } );

    $d->bind( "<Alt-f>",
        [ $fsel->Subwidget('filelist')->Subwidget('scrolled'), 'focus' ] );

    my $leftframe  = $topframe->Frame();
    my $midframe   = $topframe->Frame();
    my $rightframe = $topframe->Frame();

    my $ll = createFilelistBrowseEntry( $grp, $rightframe, \$filelist );
    $ll->pack(qw/-expand no -fill x -side top/);

    # Bloody hell, how do I underline BrowseEntry labels?
    foreach ( grep { ref($_) and $_->isa('Tk::Label') }
        main::get_widget_descendants($ll) )
    {
        $_->configure( -underline => 1 );
    }
    $d->bind( "<Alt-i>", [ $ll->Subwidget('entry'), 'focus' ] );
    $grp->{Balloon}->attach( $ll,
        -balloonmsg =>
            "Select a file-list to display.\nTo rename the selected file-list, type in a new name and press Enter."
    );

    my $t = $rightframe->Scrolled(
        qw/HList -relief sunken
            -selectmode extended
            -font C_small
            -scrollbars oe/,
        -separator => "\t"
    )->pack(qw/-expand yes -fill both -side top/);
    main::disable_scrollbar_focus($t);
    $t->BindMouseWheelVert();
    $filelist_widget = $t;
    feedHListWithFilelist( $grp, $t,
        $grp->{focusedWindow}->{currentFilelist} );

    my @pad    = qw(-padleft 7 -padright 7 -padmiddle 5 );
    my @b_pack = qw(-padx 0.1c -pady 0.2c -side right);
    $midframe->ImgButton(
        -text  => 'Add',
        -image => main::icon( $grp, "1rightarrow" ),
        @pad,
        -underline => 0,
        -balloon   => $grp->{Balloon},
        -balloonmsg =>
            "Add files selected on the left\nto the file-list on the right.",
        -command => [ \&_add_files, $grp, $t, $fsel ]
    )->pack(qw/-fill x -expand yes -pady 0.2c -side top/);

    $midframe->ImgButton(
        -text  => 'Remove',
        -image => main::icon( $grp, "1leftarrow" ),
        @pad,
        -underline => 0,
        -balloon   => $grp->{Balloon},
        -balloonmsg =>
            "Remove selected files on the right from the file-list.",
        -underline => 4,
        -command   => [ \&_remove_files, $grp, $t ]
    )->pack(qw/-fill x -expand yes -pady 0.2c -side top/);

    unless ($modal) {
        $midframe->ImgButton(
            -text       => 'Show in TrEd',
            -image      => main::icon( $grp, "button_ok" ),
            -balloon    => $grp->{Balloon},
            -balloonmsg => "Open the file-list on the selected position.",
            @pad,
            -underline => 0,
            -command   => [ \&_show_in_tred, $grp ]
        )->pack(qw/-fill x -expand yes -pady 0.2c -side top/);
        $t->bind(
            '<Return>' => [
                sub {
                    my ( $w, $grp ) = @_;
                    my $current_filelist
                        = TrEd::ManageFilelists::get_current_filelist();
                    my $anchor = $filelist_widget->info('anchor');
                    my $nextentry = $filelist_widget->info( 'next', $anchor );
                    unless ($nextentry
                        and $filelist_widget->info( 'parent', $nextentry ) eq
                        $anchor )
                    {
                        $current_filelist->set_current(
                            $filelist_widget->info(
                                'data', $filelist_widget->info('anchor')
                            )
                        );
                        TrEd::ManageFilelists::selectFilelist( $grp,
                            $current_filelist );
                    }
                },
                $grp
            ]
        );
        $t->bind( '<Double-1>' => [ \&_double_click, $grp ] );
    }
    $d->bind( '<Destroy>' => [ \&_destroy, $grp ] );
    $d->bind( $d, '<Escape>' => [ \&_escape, $d, $modal ] );

    $botframe->ImgButton(
        -text       => 'Close',
        -image      => main::icon( $grp, "button_cancel" ),
        -balloon    => $grp->{Balloon},
        -balloonmsg => "Close this window.",
        -underline  => 0,
        @pad,
        -command => [ \&_close, $d, $modal ]
    )->pack(@b_pack);

    $botframe->ImgButton(
        -text       => 'Delete',
        -image      => main::icon( $grp, "editdelete" ),
        -balloon    => $grp->{Balloon},
        -balloonmsg => "Delete current file-list.",
        @pad,
        -underline => 0,
        -command   => [ \&_delete, $grp, $d, \$filelist ]
    )->pack(@b_pack);

    $botframe->ImgButton(
        -text       => 'Save',
        -image      => main::icon( $grp, "filesave" ),
        -balloon    => $grp->{Balloon},
        -balloonmsg => "Save current file-list to a file.",
        @pad,
        -underline => 0,
        -command   => [ \&_save_fl_to_file, $grp, $d ]
    )->pack(@b_pack);

    $botframe->ImgButton(
        -text       => 'New',
        -image      => main::icon( $grp, "filenew" ),
        -balloon    => $grp->{Balloon},
        -balloonmsg => "Create a new (empty) file-list.",
        -underline  => 0,
        @pad,
        -command => [ \&_create_fl, $grp, $d, \$filelist ]
    )->pack(@b_pack);

    $botframe->ImgButton(
        -text       => 'Load',
        -image      => main::icon( $grp, "fileopen" ),
        -balloon    => $grp->{Balloon},
        -balloonmsg => "Load a file-list from a file.",
        @pad,
        -underline => 0,
        -command   => [
            sub { $filelist = TrEd::ManageFilelists::loadFilelist(@_) },
            $grp, $d
        ]
    )->pack(@b_pack);

    $botframe->Button(
        -text      => 'Help',
        -underline => 0,
        -command   => [
            sub {
                main::help_topic( shift, 'filelists' );
                Tk->break;
            },
            $d
        ]
    )->pack(qw(-padx 0.1c -pady 0.2c -side left));

    $leftframe->pack(qw/-padx 5 -side left -fill y/);
    $midframe->pack(qw/-padx 5 -side left/);
    $rightframe->pack(qw/-padx 5 -side left -expand yes -fill both/);
    $topframe->pack(qw/-padx 3 -pady 3 -side top -expand yes -fill both/);

    if ( $grp->{focusedWindow}->{currentFileNo} ) {
        my $path
            = TrEd::ManageFilelists::filelistEntryPath( $current_filelist,
            $grp->{focusedWindow}->{currentFileNo} );
        $t->selectionClear();
        if ( $path ne $EMPTY_STR ) {
            eval {
                $t->anchorSet($path);
                $t->selectionSet($path);
                $t->see($path);
            };
        }
    }
    $t->focus;
    $d->BindButtons;
    $grp->{top}->Unbusy();
    if ($modal) {
        main::ShowDialog($d);
        $d->destroy();
        return $filelist;
    }
    else {
        $d->Popup;
        return $filelist;
    }

}

sub createFilelistBrowseEntry {
    my ( $grp, $w, $filelistref ) = @_;

    # dump_filelists("createFilelistBrowseEntry", \@filelists);
    my $ll = $w->BrowseEntry(
        -label     => 'File lists:',
        -variable  => $filelistref,
        -browsecmd => [ \&_browsecmd_1, $grp, $filelistref ],
        -listcmd   => [ \&_listcmd_1 ]
    );
    $ll->Subwidget('entry')
        ->bind( '<Return>', [ \&_return_binding, $grp, $filelistref ] );
    $ll->Subwidget('entry')->Subwidget('entry')
        ->configure(qw/-background white -foreground black/);
    $ll->Subwidget('slistbox')
        ->configure(qw/-background white -foreground black/);
    return $ll;
}

#TODO: toto sa mi nezda, overit!!!
# rozlicne predavanie parametrov, raz cakame list ze bude predany, druhy raz ze nie???!!!
sub _listcmd_1 {
    my $l = shift;
    $l->delete( 0, 'end' );
    my @filelists = TrEd::ManageFilelists::get_filelists();
    foreach ( sort { lc( $a->name() ) cmp lc( $b->name() ) } @filelists ) {
        $l->insert( 0, $_->name );
    }
}

sub _browsecmd_1 {
    my ( $grp, $list, $l ) = @_;
    TrEd::ManageFilelists::switchFilelist( $grp, $$list );
}

sub feedHListWithFilelist {
    my ( $grp, $hl, $fl ) = @_;
    return unless ref($hl) and ref($fl);
    if ( $hl->can('Subwidget') and $hl->Subwidget('scrolled') ) {
        $hl = $hl->Subwidget('scrolled');
    }
    $hl->delete('all');
    my $pat;
    my $f;
    for ( my $i = 0; $i < $fl->file_count; $i++ ) {
        $pat = $fl->file_pattern($i);
        $f   = $fl->file_at($i);
        next unless defined($pat) and defined($f);
        if ( $pat eq $f ) {
            $hl->add(
                $f,
                -itemtype => 'imagetext',
                -image    => $grp->{fileImage},
                -data     => $f,
                -text     => $f,
                -style    => $hl->{default_style_imagetext},
            );
            next;
        }
        unless ( $hl->info( 'exists', $pat ) ) {
            $hl->add(
                "$pat",
                -itemtype => 'imagetext',
                -image    => $grp->{folderImage},
                -data     => $pat,
                -text     => $pat,
                -style    => $hl->{default_style_imagetext},
            );
        }
        $hl->add(
            "$pat\t$f",
            -itemtype => 'imagetext',
            -image    => $grp->{fileImage},
            -data     => $f,
            -text     => $f,
            -style    => $hl->{default_style_imagetext},
        );
    }
    return;
}

sub getFilelistLinePosition {
    my ( $fl, $line ) = @_;
    return undef unless ref($fl);
    my ( $p, $f ) = split /\t/, $line;
    return Treex::PML::Index( $fl->list_ref, $p );
}

sub update_2 {
  my ($grp, $fl) = @_;
  if ($filelist_widget) {
    
    TrEd::Filelist::View::update_a_filelist_view($grp,$filelist_widget, $fl, 0, 1);
    if (defined($fl->current)) {
      my $max_pos = TrEd::MinMax::max2(0, $fl->position);
      TrEd::Filelist::View::update_a_filelist_view($grp,$filelist_widget, $fl, $max_pos, 0);
    }
    $filelist_widget->update();
  }
}

1;
