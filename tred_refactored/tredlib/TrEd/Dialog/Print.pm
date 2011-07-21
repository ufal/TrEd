package TrEd::Dialog::Print;

use strict;
use warnings;

use TrEd::Config qw{$printOptions $font $imageMagickConvert};
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::File qw{filename dirname};
use TrEd::View::Sentence;
use TrEd::Print;

require TrEd::RuntimeConfig;

require TrEd::Dialog::FocusFix;

# print, UI, dialog
#TODO: rename to create_dialog?
sub printDialog {
    my ($grp) = @_;
    my $win = $grp->{focusedWindow};
    return unless $win->{FSFile};
    my ( $Entry, @Entry ) = main::get_entry_type();
    my $e_hist = [];

    my ( %w, %s );    # widgets, state
    $s{command} = $TrEd::Config::printOptions->{defaultPrintCommand};

    $s{psFile} = $TrEd::Config::printOptions->{psFile};
    $s{psFile} = main::doEvalHook( $win, "print_tree_filename_hook",
        $win->{FSFile}->appData('tred.print.filename') );
    $s{psFile} = $win->{FSFile}->appData('tred.print.filename')
        if $s{psFile} eq $EMPTY_STR;
    $s{psFile} = $win->{FSFile}->filename if $s{psFile} eq $EMPTY_STR;
    $s{psFile}
        =~ s/\.[^.]*$/.$TrEd::Config::printOptions->{printFileExtension}/;

    $s{printRange} = $win->{treeNo} + 1;    # unless $printRange ne EMPTY;
    $s{defaultPrtFmtWidth}  = $TrEd::Config::printOptions->{prtFmtWidth};
    $s{defaultPrtFmtHeight} = $TrEd::Config::printOptions->{prtFmtHeight};

    $s{printImageMagickResolution}
        = $TrEd::Config::printOptions->{printImageMagickResolution};

    for my $opt (
        qw(printTo printFormat printSentenceInfo printFileInfo printNoRotate printOnePerFile
        printColors prtFmtWidth prtFmtHeight prtHMargin prtVMargin psMedia)
        )
    {
        $s{$opt} = $TrEd::Config::printOptions->{$opt};
    }
    $s{initTTFont} = $TrEd::Config::printOptions->{ttFont};
    if ( $s{printFormat} eq 'PDF' and defined $s{initTTFont} ) {
        initTTFonts( $grp, $grp->{top} ) unless $grp->{ttfonts};
        if ( $grp->{ttfonts}
            and exists( $grp->{ttfonts}->{ $s{initTTFont} } ) )
        {
            $s{ttFont} = $s{initTTFont};
        }
    }
    else {
        $s{ttFont} = $EMPTY_STR;
    }

    # Dialog
    my $d = $grp->{top}->DialogBox(
        -title   => "Print",
        -buttons => [ "OK", "Help", "Save configuration", "Cancel" ]
    );
    $d->resizable( 0, 0 );
    main::addBindTags( $d, 'dialog' );
    $d->BindEscape();
    $d->Subwidget('B_Save configuration')
        ->configure( -command => [ \&savePrintConfig, $win, \%s, \%w, 1 ] );

    $d->BindReturn( $d, 1 );
    $d->bind( '<Tab>',                [ sub { shift->focusNext; } ] );
    $d->bind( '<Shift-ISO_Left_Tab>', [ sub { shift->focusPrev; } ] );
    $d->bind( '<Shift-Tab>',          [ sub { shift->focusPrev; } ] );

    # Command Entry
    my $cf = $d->Frame()
        ->pack(qw/-pady 10 -padx 10 -side top -expand yes -fill x/);
    $w{command_label} = $cf->Label(
        -text    => 'Print command:',
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    $w{command} = $cf->$Entry(
        @Entry,
        -relief       => 'sunken',
        -width        => 20,
        -font         => $TrEd::Config::font,
        -textvariable => \$s{command}
    )->pack(qw/-padx 10 -side left -expand yes -fill x/);
    main::set_grp_history( $grp, $w{command}, 'defaultPrintCommand',
        $e_hist );
    $s{defaultBg}  = $w{command}->cget('-background');
    $s{disabledBg} = $d->cget('-background');

    # Page format selection
    my $mf = $d->Frame()
        ->pack(qw/-pady 10 -padx 10 -side top -expand yes -fill x/);
    $mf->Label(
        -text      => 'Media:',
        -underline => 0,
        -anchor    => 'w',
        -justify   => 'right'
    )->pack( -side => 'left' );

    $w{prtFmtWidth} = $mf->$Entry(
        @Entry,
        -textvariable    => \$s{prtFmtWidth},
        -width           => 5,
        -validate        => 'key',
        -validatecommand => sub { shift =~ /^\s*\d*\s*$/ }
    );
    main::set_grp_history( $grp, $w{prtFmtWidth}, 'printFmtWidth', $e_hist );
    $w{prtFmtHeight} = $mf->$Entry(
        @Entry,
        -textvariable    => \$s{prtFmtHeight},
        -width           => 5,
        -validate        => 'key',
        -validatecommand => sub { shift =~ /^\s*\d*\s*$/ }
    );
    main::set_grp_history( $grp, $w{prtFmtWidth}, 'printFmtHeight', $e_hist );

    my @jcombo_opts = (
        -relief              => 'flat',
        -takefocus           => 1,
        -borderwidth         => 0,
        -highlightcolor      => 'black',
        -highlightbackground => 'gray',
        -highlightthickness  => 1,
        -background          => 'gray',
        -popupbackground     => 'black',
        -borderwidth         => 1,
        -buttonrelief        => 'ridge'
    );

    # TrueType font
    my $of = $d->Frame();
    my $bf = $of->Frame();

    my %fmtbut;
    my $pbf = $bf->Frame();
    $w{font_label} = $pbf->Label(
        -text    => 'Font (TTF):',
        -anchor  => 'sw',
        -justify => 'right'
    );

    $w{font} = $pbf->JComboBox_0_02(
        -width        => 30,
        -mode         => 'editable',
        -validate     => 'match',
        -textvariable => \$s{ttFont},
        -choices      => [
            $grp->{ttfonts}
            ? ( sort { $a cmp $b } keys %{ $grp->{ttfonts} } )
            : ()
        ],
        @jcombo_opts
    );
    _fix_combo_box( $w{font} );

    # Page media
    $w{psMedia} = $mf->JComboBox_0_02(
        -mode          => 'editable',
        -validate      => 'match',
        -listhighlight => 1,
        -textvariable  => \$s{psMedia},    # global variable in TrEd::Config
        -choices       => [
            'BBox', 'User',
            sort { $a cmp $b } grep !/\d+x\d+|^ISO/,
            keys %TrEd::Print::media
        ],
        -selectcommand => [
            sub {
                updatePrintDialogState( @_[ 0 .. 4 ] );
                1;
            },
            $grp,
            \%w,
            \%s,
            undef,
            $d
        ],
        @jcombo_opts,
    )->pack( -side => 'left' );
    _fix_combo_box( $w{psMedia} );
    $d->bind( '<Alt-m>', [ sub { shift; shift->{psMedia}->focus }, \%w ] );

    $w{prtFmtWidth}->raise( $w{psMedia} );
    $w{prtFmtHeight}->raise( $w{psMedia} );
    $mf->Label(
        -text    => 'Width:',
        -padx    => 10,
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    $w{prtFmtHeight}->pack( -side => 'left' );
    $mf->Label(
        -text    => 'Height:',
        -padx    => 10,
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    $w{prtFmtWidth}->pack( -side => 'left' );

    # Page Margins
    $mf->Label(
        -text      => 'X margin:',
        -underline => 0,
        -padx      => 10,
        -anchor    => 'w',
        -justify   => 'right'
    )->pack( -side => 'left' );
    $w{prtHMargin} = $mf->$Entry(
        @Entry,
        -textvariable    => \$s{prtHMargin},
        -width           => 5,
        -validate        => 'key',
        -validatecommand => sub { shift =~ /^\s*\d*[cimp]?\s*$/ }
    )->pack( -side => 'left' );
    $d->bind( '<Alt-x>', [ sub { shift; shift->{prtHMargin}->focus }, \%w ] );

    main::set_grp_history( $grp, $w{prtHMargin}, 'printHMargin', $e_hist );
    $mf->Label(
        -text      => 'Y margin:',
        -underline => 0,
        -padx      => 10,
        -anchor    => 'w',
        -justify   => 'right'
    )->pack( -side => 'left' );
    $w{prtVMargin} = $mf->$Entry(
        @Entry,
        -textvariable    => \$s{prtVMargin},
        -width           => 5,
        -validate        => 'key',
        -validatecommand => sub { shift =~ /^\s*\d*[cimp]?\s*$/ }
    )->pack( -side => 'left' );
    $d->bind( '<Alt-y>', [ sub { shift; shift->{prtVMargin}->focus }, \%w ] );
    main::set_grp_history( $grp, $w{prtVMargin}, 'printVMargin', $e_hist );

    # Output filename
    my $ff = $d->Frame();
    $w{file_label} = $ff->Label(
        -text    => 'File name:',
        -anchor  => 'w',
        -justify => 'right'
    )->pack( -side => 'left' );
    $w{psFile} = $ff->$Entry(
        @Entry,
        -relief       => 'sunken',
        -width        => 50,
        -font         => $TrEd::Config::font,
        -textvariable => \$s{psFile}
    )->pack(qw/-padx 10 -side left -expand yes -fill x/);
    $d->bind( '<Alt-r>', [ sub { shift; shift->{psFile}->focus }, \%w ] );
    main::set_grp_history( $grp, $w{psFile}, 'printFile', $e_hist );
    if ( $s{psFile} ne $EMPTY_STR ) {
        my $start = rindex( $s{psFile}, "/" ) + 1;
        my $end   = rindex( $s{psFile}, "." );
        if ( $start < $end ) {
            $w{psFile}->selectionClear();
            $w{psFile}->selectionRange( $start, $end );
            $w{psFile}->icursor($start);
        }
    }

    # Print range
    my $sf = $d->Frame();
    $w{printRange} = $sf->$Entry(
        @Entry,
        -relief       => 'sunken',
        -width        => 20,
        -font         => $TrEd::Config::font,
        -textvariable => \$s{printRange}
    );
    main::set_grp_history( $grp, $w{printRange}, 'printRange', $e_hist );
    $w{findFile} = $ff->Button(
        -text      => '...',
        -underline => 0,
        -command   => [
            sub {
                my ( $d, $s ) = @_;
                my $initdir = TrEd::File::dirname( $s->{psFile} );
                $initdir = cwd() if ( $initdir eq './' );
                $initdir =~ s!${TrEd::File::dir_separator}$!!m;
                my $file = main::get_save_filename(
                    $d,
                    -title => "Print To File ...",
                    $^O eq 'MSWin32' ? ()
                    : ( -initialfile =>
                            TrEd::File::filename( $s->{psFile} ) ),
                    -d $initdir ? ( -initialdir => $initdir ) : (),
                    -filetypes => [
                        (   $s->{printFormat} eq 'PDF'
                            ? [ "PDF files", [qw/.pdf .PDF/] ]
                            : ( $s->{printFormat} eq 'SVG'
                                ? [ "SVG files", [qw/.svg .SVG/] ]
                                : [ "PostScript files",
                                    [qw/.ps .eps .PS .EPS/]
                                ]
                            )
                        ),
                        [ "All files", '*' ]
                    ]
                );
                $s->{psFile} = $file
                    if ( defined $file and $file ne $EMPTY_STR );
            },
            $d,
            \%s
        ]
    )->pack(qw/-padx 10 -side left/);

    # Bitmap Resolutions
    my $imf = $bf->Frame();
    $w{printImageMagickResolution} = $imf->JComboBox_0_02(
        -mode            => 'editable',
        -validate        => 'key',
        -validatecommand => sub { $_[0] =~ /^\d*$/ },
        -choices         => [
            '50',  '60',  '75',  '80',  '90',  '100', '120', '135',
            '150', '160', '180', '200', '225', '240', '260', '300',
            '360', '600', '720'
        ],
        -textvariable => \$s{printImageMagickResolution},
    );
    _fix_combo_box_return( $w{printImageMagickResolution} );
    my %printbuttons = (
        printer => [ $bf, 'Send to printer', undef, 8 ],
        file    => [ $bf, 'Print to file',   '?',   9 ],
        convert => [
            $imf, 'Convert to a bitmap format by extension (ImageMagick)',
            'png', 13
        ]
    );

    # print To buttons
    foreach (qw(printer file convert)) {
        $w{"printTo_$_"} = $printbuttons{$_}[0]->Radiobutton(
            -text      => $printbuttons{$_}[1],
            -value     => $_,
            -underline => $printbuttons{$_}[3],
            -variable  => \$s{printTo},
            -relief    => 'flat',
            -command   => [
                \&updatePrintDialogState, $grp,                 \%w,
                \%s,                      $printbuttons{$_}[2], $d
            ]
        );
    }
    $w{printTo_convert}->pack(qw/-anchor w -side left -fill y -expand 1/);

    $imf->Label( -text => "Resolution", -underline => 7 )
        ->pack(qw/-padx 10 -side left/);
    $imf->pack(qw/-fill x -expand yes -anchor nw/);
    $w{printImageMagickResolution}->pack(qw/-padx 10 -side left/);

    $d->bind( '<Alt-i>',
        [ sub { shift; shift->{printImageMagickResolution}->focus }, \%w ] );

    $w{printTo_convert}->lower( $w{printImageMagickResolution} );

    foreach (qw(printer file)) {
        $w{"printTo_$_"}->pack(qw/-fill y -anchor nw/);
    }

    $bf->Frame()->pack(qw/-pady 5/);

    # output format buttons
    my %fmtbuttons = (
        PS  => [ $bf,  'Create PostScript', 'ps',  11 ],
        EPS => [ $bf,  'Create EPS',        'eps', 7 ],
        SVG => [ $bf,  'Create SVG',        'svg', 7 ],
        PDF => [ $pbf, 'Create PDF',        'pdf', 8 ],
    );
    foreach (qw(PS EPS SVG PDF)) {
        $w{"format_$_"} = $fmtbuttons{$_}[0]->Radiobutton(
            -text      => $fmtbuttons{$_}[1],
            -value     => $_,
            -underline => $fmtbuttons{$_}[3],
            -variable  => \$s{printFormat},
            -relief    => 'flat',
            -command   => [
                \&updatePrintDialogState, $grp,               \%w,
                \%s,                      $fmtbuttons{$_}[2], $d
            ]
        );
    }
    foreach (qw(PS EPS SVG)) {
        $w{"format_$_"}->pack(qw/-fill y -anchor nw/);
    }
    $w{format_PDF}->pack(qw/-anchor w -side left -fill y -expand 1/);
    $w{font_label}->pack(qw/-padx 10 -side left/);
    $w{font}->pack(qw/-padx 10 -side left/);
    $pbf->raise( $w{format_EPS} );
    $pbf->pack(qw/-fill x -expand yes -anchor nw/);

    $bf->Frame()->pack(qw/-pady 5/);

    # print options
    $w{printColors} = $bf->Checkbutton(
        -text      => 'Use colors',
        -underline => 0,
        -variable  => \$s{printColors},
        -relief    => 'flat'
    )->pack( -fill => 'y', -anchor => 'nw' );
    $w{printFileInfo} = $bf->Checkbutton(
        -text      => 'Print filename and tree number',
        -underline => 8,
        -variable  => \$s{printFileInfo},
        -relief    => 'flat'
    )->pack( -fill => 'y', -anchor => 'nw' );
    $w{printSentenceInfo} = $bf->Checkbutton(
        -text      => 'Print sentence',
        -underline => 8,
        -variable  => \$s{printSentenceInfo},
        -relief    => 'flat'
    )->pack( -fill => 'y', -anchor => 'nw' );

    $w{printOnePerFile} = $bf->Checkbutton(
        -text =>
            'one tree per file (use %n in the filename to place the tree number)',
        -underline => 4,
        -variable  => \$s{printOnePerFile},
        -command   => [ \&updatePrintDialogState, $grp, \%w, \%s, undef, $d ],
        -relief    => 'flat'
    )->pack( -fill => 'y', -anchor => 'nw' );

    $w{printNoRotate} = $bf->Checkbutton(
        -text      => 'Disable landscape rotation of wide trees',
        -underline => 30,
        -variable  => \$s{printNoRotate},
        -relief    => 'flat'
    )->pack( -fill => 'y', -anchor => 'nw' );
    $bf->pack( -side => 'left' );

    $of->pack(qw/-padx 10 -pady 10 -side top -expand yes -fill x/);
    $sf->Label(
        -text      => 'Page range:',
        -underline => 5,
        -anchor    => 'w',
        -justify   => 'right'
    )->pack( -side => 'left' );
    $d->bind( '<Alt-r>', [ sub { shift; shift->{printRange}->focus }, \%w ] );
    $w{printRange}->pack(qw/-side left -padx 10 -fill x -expand yes/);

    for ( $sf, $ff ) {
        $_->raise($of);
    }

    # fill range buttons
    $sf->Button(
        -image   => main::icon( $grp, '1leftarrow' ),
        -command => [
            sub {
                my ( $grp, $w ) = @_;
                my $rng = TrEd::View::Sentence::get_selection($grp);
                $w->{printRange}->delete( 0, 'end' );
                $w->{printRange}->insert( 0, $rng );
            },
            $grp,
            \%w
        ]
    )->pack(qw/-padx 10 -side left/);
    $sf->Button(
        -image   => main::icon( $grp, 'contents' ),
        -command => [
            sub {
                my ( $grp, $win, $d, $w ) = @_;
                my $list = [];
                foreach (
                    TrEd::Print::parse_print_list(
                        $win->{FSFile}, $w->{printRange}
                    )
                    )
                {
                    $list->[ $_ - 1 ] = 1;
                }
                my $rng = TrEd::View::Sentence::get_selection(
                    $grp,
                    TrEd::View::Sentence::show_sentences_dialog(
                        $grp, $d, $win->{FSFile}, $list
                    )
                );
                $w->{printRange}->delete( 0, 'end' );
                $w->{printRange}->insert( 0, $rng );
            },
            $grp,
            $win,
            $d,
            \%w
        ]
    )->pack(qw/-padx 10 -side left/);

    $sf->pack(qw/-pady 10 -padx 10 -side bottom -expand yes -fill x/);
    $ff->pack(qw/-pady 10 -padx 10 -side bottom -expand yes -fill x/);

    updatePrintDialogState( $grp, \%w, \%s,
        $TrEd::Config::printOptions->{printFileExtension}, $d );

    #  $toFile ? $fe->focus : $ce->focus;

    $d->BindButtons;
    my $result
        = TrEd::Dialog::FocusFix::show_dialog( $d, $s{printTo} eq "command" ? $w{command} : $w{psFile},
        $grp->{top} );
    savePrintConfig( $win, \%s, \%w, 0 );

    my $one_per_file = 1 if $s{printOnePerFile};
    main::get_grp_histories( $grp, $e_hist ) if ( $result =~ /OK/ );
    $d->destroy;
    undef $d;

    if ( $result =~ /OK/ ) {
        return ()
            if $s{printTo} eq 'convert'
                and main::warnWin32PrintConvert($win) eq 'Cancel';
        return ()
            if $s{printTo} eq 'convert'
                and main::warn55PrintConvert($win) eq 'Cancel';
        return {
            -onePerFile => $one_per_file,
            -range      => $s{printRange},
            -to         => (
                  ( $s{printTo} eq 'file' )    ? 'file'
                : ( $s{printTo} eq 'convert' ) ? 'convert'
                : 'pipe'
            ),
            -format       => $s{printFormat},
            -filename     => TrEd::Config::tilde_expand( $s{psFile} ),
            -sentenceInfo => $s{printSentenceInfo} ? sub {
                $win->{framegroup}->{valueLine}
                    ->get_value_line( $win, $_[0], $_[1], 1, 0, 'print' );
                }
            : undef,
            -fileInfo              => $s{printFileInfo},
            -imageMagickResolution => $s{printImageMagickResolution},
            -convert               => $TrEd::Config::imageMagickConvert,
            -command               => $s{command},
            -colors                => $s{printColors},
            -noRotate              => $s{printNoRotate},
        };

    }
    else {
        return ();
    }
}

sub updatePrintDialogState {
    my ( $grp, $w, $s, $extension, $toplevel ) = @_;    # widgets, state

    my %t = map { $_ => 1 } keys %$w;                   # toggle
    my @disable;
    if ( $s->{printTo} eq 'printer' ) {
        @disable
            = qw(printOnePerFile printImageMagickResolution psFile format_PDF format_SVG);
    }
    elsif ( $s->{printTo} eq 'file' ) {
        @disable = qw(printImageMagickResolution command);
    }
    elsif ( $s->{printTo} eq 'convert' ) {
        @disable = qw(command psMedia prtFmtWidth prtFmtHeight);
    }
    if ( $s->{psMedia} ne 'User' ) {
        push @disable, qw(prtFmtWidth prtFmtHeight);
    }

    if ( $s->{printFormat} eq 'EPS' ) {
        push @disable, qw(font psMedia prtFmtWidth prtFmtHeight);
        push @disable, qw(printRange) unless $s->{printOnePerFile};
    }
    elsif ( $s->{printFormat} eq 'PS' ) {
        push @disable, qw(font);
    }
    elsif ( $s->{printFormat} eq 'SVG' ) {
        push @disable, qw(printTo_printer font);

        # push @disable,qw(printRange) unless $s->{printOnePerFile};
    }
    elsif ( $s->{printFormat} eq 'PDF' ) {
        push @disable, qw(printTo_printer);
        unless ( $grp->{ttfonts} ) {
            $w->{font}->toplevel->Busy( -recurse => 1 );
            initTTFonts( $grp, $toplevel );
            foreach ( sort { $a cmp $b } keys %{ $grp->{ttfonts} } ) {

                #	$w->{font}->insert('end',$_);
                $w->{font}->addItem($_);
            }
            $w->{font}->toplevel->afterIdle(
                sub {
                    if ( exists( $grp->{ttfonts}->{ $s->{initTTFont} } ) ) {
                        $s->{ttFont} = $s->{initTTFont};
                    }
                    else {
                        $s->{ttFont} = $EMPTY_STR;
                    }
                }
            );
            $w->{font}->toplevel->Unbusy();
            $w->{font}->focus;
            eval { $w->{font}->see(0) };
        }
    }
    $t{$_} = 0 for (@disable);
    if ( $extension eq '?' ) {
        $extension = lc( $s->{printFormat} );
    }
    $s->{psFile} =~ s/\.[^.]*$/.$extension/
        if defined($extension)
            and not($s->{printTo} eq 'convert'
                and $extension =~ /^(?:svg|pdf|e?ps)$/ );

    if ( $s->{printOnePerFile} ) {
        $s->{psFile} =~ s/\.([^.]*)$/_\%n.$1/ if $s->{psFile} !~ /[%]\d*n/;
    }

    if ( $s->{psMedia} eq 'BBox' ) {
        $s->{prtFmtWidth}  = $EMPTY_STR;
        $s->{prtFmtHeight} = $EMPTY_STR;
    }
    elsif ( $s->{psMedia} eq 'User' ) {
        $s->{prtFmtWidth}  = $s->{defaultPrtFmtWidth};
        $s->{prtFmtHeight} = $s->{defaultPrtFmtHeight};
    }
    else {
        $s->{prtFmtWidth}  = $TrEd::Print::media{ $s->{psMedia} }[0];
        $s->{prtFmtHeight} = $TrEd::Print::media{ $s->{psMedia} }[1];
    }
    foreach my $widget ( keys %t ) {
        if ( $t{$widget} ) {

            #print "On: $widget: $w->{$widget}\n";
            eval { $w->{$widget}->configure( -state => 'normal' ) };
            eval {
                $w->{$widget}->configure(
                    (          $w->{$widget}->isa('Tk::Entry')
                            or $w->{$widget}->isa('Tk::BrowseEntry')
                            or $w->{$widget}->isa('JComboBox_0_02')
                    ) ? ( -background => $s->{defaultBg} ) : ()
                );
            };
        }
        else {

            #print "Off: $widget: $w->{$widget}\n";
            eval { $w->{$widget}->configure( -state => 'disabled' ) };
            eval {
                $w->{$widget}->configure(
                    (          $w->{$widget}->isa('Tk::Entry')
                            or $w->{$widget}->isa('Tk::BrowseEntry')
                            or $w->{$widget}->isa('JComboBox_0_02')
                    ) ? ( -background => $s->{disabledBg} ) : ()
                );
            };
        }

        #print "---\n";
    }
}

# make sure that editable JComboBox only contains valid values
# Note: always get the values with GetSelected
sub _fix_combo_box_return {
    my $cw = shift;
    for my $w (
        $cw,
        $cw->Subwidget('ED_Entry'),
        $cw->Subwidget('RO_Entry'),
        $cw->Subwidget('Popup')
        )
    {
        $w->bind(
            $w,
            '<Return>',
            [   sub {
                    shift;
                    my $cw = shift;
                    if ( $cw->popupIsVisible() ) {
                        $cw->hidePopup();
                    }
                    else {
                        $cw->showPopup();
                    }
                    Tk->break();
                },
                $cw
            ]
        );
    }
}

sub _fix_combo_box {
    my $cw = shift;
    $cw->setSelected( $cw->GetSelected() );
    for my $w (
        $cw,
        $cw->Subwidget('ED_Entry'),
        $cw->Subwidget('RO_Entry'),
        $cw->Subwidget('Popup')
        )
    {
        $w->bind(
            '<FocusIn>',
            [   sub {
                    shift;
                    my $cw = shift;
                    my $lb = $cw->Subwidget('Listbox');
                    if ( not defined( $cw->{index_on_focus} ) ) {
                        $cw->{index_on_focus} = $cw->CurSelection();
                        $cw->see( $cw->{index_on_focus} )
                            if $cw->{index_on_focus} ne q{};
                    }
                },
                $cw
            ]
        );
        $w->bind(
            '<FocusOut>',
            [   sub {
                    shift;
                    my $cw = shift;
                    $cw->EntryEnter();
                    $cw->{index_on_focus} = undef;
                },
                $cw
            ]
        );

        $w->bind(
            $w,
            '<Return>',
            [   sub {
                    shift;
                    my $cw = shift;
                    if ( $cw->popupIsVisible() ) {
                        $cw->hidePopup();
                        $cw->EntryEnter();
                    }
                    else {
                        $cw->EntryEnter();
                        $cw->showPopup();
                    }
                    Tk->break();
                },
                $cw
            ]
        );
    }
}

# print
sub savePrintConfig {
    my ( $win, $s, $widgets, $save_to_tredrc ) = @_;
    my $grp = $win->{framegroup};
    for my $opt (
        qw( printRange printOnePerFile printTo printFormat psFile
        printSentenceInfo printFileInfo printImageMagickResolution
        printNoRotate printColors ttFont prtHMargin prtVMargin )
        )
    {
        $printOptions->{$opt} = $s->{$opt};
    }
    $printOptions->{defaultPrintCommand} = $s->{command};
    $printOptions->{psMedia}             = $widgets->{psMedia}->GetSelected;
    ( $printOptions->{printFileExtension} )
        = $s->{psFile} =~ m!\.([^.\\/]+)$!;

    $win->{FSFile}->changeAppData( 'tred.print.filename', $s->{psFile} );
    if ($save_to_tredrc) {
        TrEd::RuntimeConfig::save_runtime_config(
            $grp,
            {   ';' => 'Options saved from the Print dialog',
                %{$printOptions}
            }
        );
    }
}

# font
sub initTTFonts {
    my ( $grp, $toplevel ) = @_;
    print STDERR "Collecting TTF fonts..." if $TrEd::Config::tredDebug;
    my $opts = {};
    $grp->{ttfonts} = [];
    if ( $toplevel and eval { require Tk::ProgressBar; } ) {
        my $d = $toplevel->DialogBox(
            -title   => 'Looking for TrueType fonts...',
            -buttons => ['Cancel']
        );
        my $percent_done = 0;
        my $format       = '%3d/%3d  %3d%%';
        my $f1           = $d->Frame()
            ->pack( -side => 'top', -padx => 5, -fill => 'x', -expand => 1 );
        $f1->Label( -text =>
                "Looking for TrueType fonts. This may take a moment...\n" )
            ->pack( -side => 'left' );
        my $f = $d->Frame()
            ->pack( -side => 'top', -padx => 5, -fill => 'x', -expand => 1 );
        $f->ProgressBar(
            -width       => 20,
            -length      => 300,
            -blocks      => 1,
            -colors      => [ 0, 'darkblue' ],
            -troughcolor => 'white',
            -variable    => \$percent_done
        )->pack( -side => 'left' );
        my $cancel = 0;
        $d->bind( '<Escape>', sub { $cancel = 1 } );
        $d->Subwidget('B_Cancel')
            ->configure( -command => sub { $cancel = 1 } );
        my $label = sprintf( $format, 0, 0, 0 );
        $f->Label( -textvariable => \$label, -width => 12 )
            ->pack( -side => 'right' );

        #$grp->{top}->Unbusy();
        $d->BindButtons;
        $d->Popup;
        $d->update();
        $opts = {
            callback => sub {
                my ( $font, $i, $max ) = @_;
                die "Interrupted\n" if $cancel;
                return unless $i % 10 == 0 or $i == $max;
                $d->update;
                $percent_done = int( 100 * $i / $max );
                $label = sprintf( $format, $i, $max, $percent_done );
            },
            _dlg           => $d,
            try_fontconfig => ( $Tk::platform eq 'unix' ? 1 : 0 ),
        };
    }
    eval {
        $grp->{ttfonts} = TrEd::Print::get_ttf_fonts(
            $opts,     map TrEd::Config::tilde_expand($_),
            split /,/, $printOptions->{ttFontPath}
        );
    };
    if ($opts) {
        $opts->{_dlg}->destroy();
    }
    return $grp->{ttfonts};
}

1;
