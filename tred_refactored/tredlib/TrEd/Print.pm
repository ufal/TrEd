package TrEd::PSTreeView;
use File::Spec;
use TrEd::TreeView;
use base qw(TrEd::TreeView);
use Encode;
use Carp;

sub setFontMetrics {
    my ( $self, $filename, $fontsize, $fontscale ) = @_;
    $self->{psFontSize} = $fontsize || 10;
    $self->{psFontScale} = $fontscale ? $fontscale : 1000;
    $self->{textWidthHash} = {};
    my $err = "PostScript Font Metrics file not found: '$filename'\n"
        . "If printing from TrEd, check the settings of the psFontAFMFile configuration option.\n";
    if ($TrEd::Convert::support_unicode) {
        require PostScript::AGLFN;
        unless ( defined($filename) and length($filename) and -f $filename ) {
            die $err;
        }
        $self->{psFontMetrics} = new PostScript::AGLFN($filename);
    }
    else {
        require PostScript::FontMetrics;
        unless ( defined($filename) and length($filename) and -f $filename ) {
            die $err;
        }
        $self->{psFontMetrics} = new PostScript::FontMetrics($filename);
    }
    return $self->{psFontMetrics};
}

sub getFontHeight {
    my ($self) = @_;
    return 0 unless $self->{psFontMetrics};
    my $ascent
        = ( $self->{psFontSize} * $self->{psFontMetrics}->FontBBox->[3] )
        / 1000;
    my $descent
        = -( $self->{psFontSize} * $self->{psFontMetrics}->FontBBox->[1] )
        / 1000;
    return sprintf( "%.0f", $ascent + $descent );
}

sub getTextWidth {
    my ( $self, $text ) = @_;
    return 0 unless $self->{psFontMetrics};
    my $width = $self->{textWidthHash}->{$text};
    if ( !defined($width) ) {
        $width = $self->{psFontMetrics}
            ->stringwidth( $text, $self->{psFontSize} );
        $self->{textWidthHash}->{$text} = $width;
        $self->{textWidthHashMiss}++;
    }
    else {
        $self->{textWidthHashHit}++;
    }
    return $width;
}

sub getFontName {
    my ($self) = @_;
    return "" unless $self->{psFontMetrics};
    $self->{psFontMetrics}->FontName;
}

package TrEd::PDFTreeView;

use TrEd::TreeView;
use base qw(TrEd::TreeView);

sub initPDF {
    my ( $self, $P ) = @_;
    $self->{psFontSize}
        = abs( $self->canvas->fontActual( $self->get_font(), '-size' ) );
    $self->{TTF} = $P->{DefaultFont};
    return $self->{TTF};
}

sub getFontHeight {
    my ($self) = @_;
    return 0 unless $self->{TTF};
    my $ascent
        = ( $self->{TTF}->data->{ascender} * $self->{psFontSize} ) / 1000;
    my $descent
        = -( $self->{TTF}->data->{descender} * $self->{psFontSize} ) / 1000;
    my $height = sprintf( "%.0f", $ascent + $descent );
    return $height;
}

sub getTextWidth {
    my ( $self, $text ) = @_;
    return 0 unless $self->{TTF};
    my $width = $self->{textWidthHash}->{$text};
    if ( !defined($width) ) {

        #!! old PDF::API
        #!! if ($TrEd::Convert::support_unicode) {
        #!!  $width= $self->{TTF}->width_utf8($text)*$self->{psFontSize};
        #!! } else {
        $width = $self->{TTF}->width($text) * $self->{psFontSize};

        #!! }
        $self->{textWidthHash}->{$text} = $width;
        $self->{textWidthHashMiss}++;
    }
    else {
        $self->{textWidthHashHit}++;
    }
    return $width;
}

sub getFontName {
    my ( $self, $text ) = @_;
    return 0 unless $self->{TTF};
    my $name = $self->{TTF}->name;
    return $name;
}

package TrEd::Print;
use strict;
use Carp;
use UNIVERSAL::DOES;
use TrEd::Utils qw{uniq};

BEGIN {
    use vars qw($bwModeNodeColor %media);
    use Exporter;
    use Tk;
    use Tk::Wm;
    use Tk::Canvas::PDF;
    use Tk::Canvas::SVG;
    *media = *Tk::Canvas::PDF::media;
    use Treex::PML;

    use TrEd::Convert;
    import TrEd::Convert;

    use TrEd::MinMax;
    import TrEd::MinMax;

    use vars qw($QUIET);

    sub _msg {
        print STDERR @_ unless $QUIET;
    }
}

#$bwModeNodeColor = 'white';

sub _dirs {
    my ($dir) = @_;
    my $ds = $TrEd::File::dir_separator;
    my @dirs;
    if ( opendir( my $dd, $dir ) ) {
        @dirs = map { ( "${dir}${ds}$_", _dirs("${dir}${ds}$_") ) }
            grep { -d "${dir}${ds}$_" }
            grep { !/^\.*$/ } readdir($dd);
        closedir $dd;
    }
    else {
        warn "Warning: can't read ${dir}\n";
    }
    return $dir, @dirs;
}

sub get_ttf_fonts {
    my $opts = ref( $_[0] ) ? shift : {};
    my %result;

    if ( $opts->{try_fontconfig} and eval { require File::Which; 1 } ) {
        my $fc_list = File::Which::which('fc-list');
        my $fc;
        if ($fc_list
            and open(
                my $fc,
                '-|',
                $fc_list,
                ':fontformat=TrueType:scalable=True:style=Normal:decorative=False',
                'file',
                'family'
            )
            )
        {
            while (<$fc>) {
                s/\s+$//;
                my ( $font, $fn ) = split /:\s+/, $_, 2;
                $result{$fn} = $font
                    if -f $font
                        and defined($fn)
                        and length($fn)
                        and !exists $result{$fn};
            }
            close($fc);
            return \%result if keys %result;
        }
    }

    my $ds = $TrEd::File::dir_separator;
    eval {
        require PDF::API2::Basic::TTF::Font;
        my @files;
        my @dirs = TrEd::Utils::uniq( map { _dirs($_) } @_ );
        my $i = 0;
        foreach my $path (@dirs) {
            opendir my $dh, $path || next;
            if ( ref $opts->{search_callback} ) {
                $opts->{search_callback}->( $path, $i++, scalar(@dirs) );
            }
            push @files, grep { -f $_ }
                grep {/\.[to]tf$/i}
                map { File::Spec->catfile( $path, $_ ) } readdir($dh);
            closedir $dh;
        }
        $i = 0;
        foreach my $font (@files) {
            if ( ref $opts->{callback} ) {
                $opts->{callback}->( $font, $i++, scalar(@files) );
            }
            my $f = PDF::API2::Basic::TTF::Font->open($font);
            next unless $f;
            $PDF::API2::Basic::TTF::Name::utf8     = 0;    # 1 does not work
            $PDF::API2::Basic::TTF::GDEF::new_gdef = 1;
            $f->{'name'}->read;
            my $fn = $f->{name}->find_name(1);
            my $fs = $f->{name}->find_name(2);

            for ( $fn, $fs ) {

                # the encoding can be UTF-16 or 8bit (hopefully no other)
                use bytes;
                $_ = Encode::decode(
                    ( index( $_, "\x{0}" ) >= 0 )
                    ? 'iso-10646-1'
                    : 'iso-8859-1',
                    $_
                );
            }
            $fn .= " " . $fs if $fs ne 'Regular';
            $result{$fn} = $font unless exists $result{$fn};
            $f->release;
        }
    };
    _msg($@) if $@;
    return \%result;
}

sub parse_print_list {
    my ( $fsfile, $printRange ) = @_;
    my $pbeg;
    my $pend;
    my @printList;
    return unless ref($fsfile);
    foreach ( split /,/, $printRange ) {
        if ( /^\s*(\d+)\s*$/ and $1 - 1 <= $fsfile->lastTreeNo ) {
            push @printList, $1;
            next;
        }
        if (/^\s*(\d*)\s*-\s*(\d*)\s*$/) {
            ( $pbeg, $pend ) = ( $1, $2 );
            $pend = $fsfile->lastTreeNo + 1 if ( $pend eq '' );
            $pbeg = 1 if ( $pbeg eq '' );
            $pend = min( $fsfile->lastTreeNo + 1, $pend );
            next unless ( $pbeg <= $pend );
            push @printList, $pbeg .. $pend;
        }
    }
    return @printList;
}

sub get_nodes_callback {
    my $callback = shift;
    my $nodes;
    if ( !defined($callback) ) {
        my $treeView = shift;
        ($nodes) = $treeView->nodes(@_);
    }
    else {
        my ( $cb, @args );
        if ( ref($callback) eq 'ARRAY' ) {
            ( $cb, @args ) = @$callback;
        }
        elsif ( ref($callback) eq 'CODE' ) {
            $cb = $callback;
        }
        else {
            croak(
                "the get_nodes_callback argument to TrEd::Print::print_trees must be a code-ref or an array\n"
            );
        }
        ($nodes) = $cb->( @args, @_ );
    }
    return $nodes;
}

# this function serves as a preliminary version of a `public' API to this module
sub Print {
    my %opts;
    if ( @_ == 1 and ref( $_[0] ) ) {
        %opts = %{ $_[0] };
    }
    else {
        %opts = @_;
    }
    my $ctx = $opts{-context};
    my $canvas = $opts{-canvas} || Tk::MainWindow->new->Canvas();

    # setup some defaults
    $opts{-noRotate} = 1      unless exists $opts{-noRotate};
    $opts{-colors}   = 1      unless exists $opts{-colors};
    $opts{-psMedia}  = 'BBox' unless exists $opts{-psMedia};
    if ( $opts{-psMedia} eq 'BBox' ) {
        $opts{-hMargin} = 0 unless exists $opts{-hMargin};
        $opts{-vMargin} = 0 unless exists $opts{-vMargin};
    }
    $opts{-range} = 1
        unless defined( $opts{-range} )
            and length( $opts{-range} );

    if ( uc( $opts{-format} ) eq 'IMAGEMAGICK' ) {
        $opts{-to} = 'convert';
        delete $opts{-toFile};
        $opts{-format} = 'EPS';
    }
    else {
        $opts{-format} ||= 'PDF';
    }

    unless ( $opts{-format} ne 'PDF' or $opts{-ttFont} ) {
        if ( $opts{-ttFontName} ) {
            my $fonts = TrEd::Print::get_ttf_fonts(
                { try_fontconfig => 1 },
                (   $opts{-ttFontPath}
                    ? ( map TrEd::Config::tilde_expand($_),
                        split /,/,
                        $opts{-ttFontPath}
                        )
                    : ()
                )
            );
            $opts{-ttFont} = $fonts->{ $opts{-ttFontName} };
        }
    }
    $TrEd::TreeView::on_get_root_style
        = ( ref( $opts{-onGetRootStyle} ) eq 'CODE' and $ctx )
        ? [ $opts{-onGetRootStyle}, $ctx ]
        : $opts{-onGetRootStyle};

    $TrEd::TreeView::on_get_node_style
        = ( ref( $opts{-onGetNodeStyle} ) eq 'CODE' and $ctx )
        ? [ $opts{-onGetNodeStyle}, $ctx ]
        : $opts{-onGetNodeStyle};

    $TrEd::TreeView::on_redraw_done
        = ( ref( $opts{-onRedrawDone} ) eq 'CODE' and $ctx )
        ? [ $opts{-onRedrawDone}, $ctx ]
        : $opts{-onRedrawDone};

    my $on_get_nodes
        = ( ref( $opts{-onGetNodes} ) eq 'CODE' and $ctx )
        ? [ $opts{-onGetNodes}, $ctx ]
        : $opts{-onGetNodes};

    $opts{-imageMagickResolution} ||= 80;
    croak(
        "When using -format => 'ImageMagick', -convert => /path/to/convert must be specified.\n"
    ) if ( $opts{-to} eq 'convert' and !$opts{-convert} );
    local $QUIET = $opts{-quiet};
    my $command = $opts{-command};
    if ( $opts{-to} eq 'convert' or ( $opts{-format} =~ /ImageMagick/i ) ) {
        $command = "$opts{-convert} -density $opts{-imageMagickResolution} - "
            . Treex::PML::IO::quote_filename( $opts{-filename} );
    }
    if ( defined $opts{-to} ) {
        croak("Cannot use flags -to and -toFile at the same time!\n")
            if defined $opts{-toFile};
        if ( lc( $opts{-to} ) eq 'file' ) {
            $opts{-toFile} = 1;
        }
        elsif ( lc( $opts{-to} ) eq 'string' ) {
            $opts{-toFile} = 2;
        }
        elsif ( lc( $opts{-to} ) eq 'convert' ) {
            $opts{-toFile} = 0;
        }
        elsif ( lc( $opts{-to} ) eq 'object' ) {
            $opts{-toFile} = 3;
        }
        elsif ( lc( $opts{-to} ) eq 'pipe' ) {
            $opts{-toFile} = 0;
        }
        else {
            croak(
                "Unknown value '$opts{-to}' of the flag -to: use one of file,string,object,pipe!\n"
            );
        }
    }
    my $return = eval {
        print_trees(
            $opts{-fsfile},
            $opts{-toplevel},
            $canvas,
            $opts{-range},
            $opts{-toFile},
            ( ( uc( $opts{-format} ) eq 'EPS' ) ? 1 : 0 ),
            (   ( $opts{-format} =~ /^PDF$|^SVG$/i )
                ? uc( $opts{-format} )
                : 0
            ),
            $opts{-filename},
            $opts{-sentenceInfo},
            $opts{-fileInfo},
            $command,
            $opts{-colors},
            $opts{-noRotate},
            $opts{-hidden},
            {   'PS'   => $opts{-psFontFile},
                'AFM'  => $opts{-psFontAFMFile},
                'TTF'  => $opts{-ttFont},
                'Size' => $opts{-fontSize},
            },
            $opts{-fmtWidth},
            $opts{-hMargin},
            $opts{-fmtHeight},
            $opts{-vMargin},
            $opts{-maximize},
            ( $opts{-psMedia} || 'BBox' ),
            ( $opts{-treeViewOpts} || {} ),
            $opts{-styleSheetObject},
            $opts{-context},
            $on_get_nodes,
            $opts{-extraOptions},
        );
    };
    my $err = $@;
    $TrEd::TreeView::on_get_root_style = undef;
    $TrEd::TreeView::on_get_node_style = undef;
    $TrEd::TreeView::on_redraw_done    = undef;
    $canvas->destroy() unless $opts{-canvas};
    die $err if $err;
    return $return;
}

sub print_trees {
    my ($fsfile,          # Treex::PML::Document object
        $toplevel,        # Tk window to make busy when printing output
        $c,               # Tk::Canvas object
        $printRange,      # print range
        $toFile,          # 1: file, 2: string, 3: object, 0: pipe
        $toEPS,           # boolean: create EPS
        $outputFormat,    # SVG/PDF/false (1 also means PDF)
        $fil,             # output file-name
        $snt,             # sentence
        $fileinfo,        # boolean: fileinfo
        $cmd,             # lpr command
        $printColors,     # boolean: produce color output
        $noRotate,        # boolean: disable tree rotation
        $show_hidden,     # boolean: print hidden nodes too
        $fontSpec,        # hash
        $prtFmtWidth,     # paper width
        $prtHMargin,
        $prtFmtHeight,
        $prtVMargin,
        $maximizePrintSize,
        $Media,
        $canvas_opts,     # color hash reference
        $stylesheet,
        $grp_ctx,
        $get_nodes_callback,
        $extra_opts
    ) = @_;

    my $return;
    $extra_opts ||= {};
    my $toPDF = ( ( $outputFormat eq 'PDF' or $outputFormat == 1 ) ? 1 : 0 );
    my $toSVG = ( $outputFormat eq 'SVG' ? 1 : 0 );
    return if ( not defined($printRange) );

    local $TrEd::Convert::FORCE_REMIX    = $toSVG ? 0 : 1;
    local $TrEd::Convert::FORCE_NO_REMIX = $toSVG ? 1 : 0;
    local $TrEd::Convert::support_unicode = $TrEd::Convert::support_unicode;
    local $TrEd::Convert::lefttoright     = $TrEd::Convert::lefttoright;

    # A hack to support correct Arabic rendering under Tk800
    if (    1000 * $] >= 5008
        and !$TrEd::Convert::support_unicode
        and $TrEd::Convert::inputenc =~ /^utf-?8$/i
        or $TrEd::Convert::inputenc eq 'iso-8859-6'
        or $TrEd::Convert::inputenc eq 'windows-1256' )
    {
        $TrEd::Convert::lefttoright     = 1;    # arabjoin does this
        $TrEd::Convert::support_unicode = 1;
    }

    my $pagewidth;
    my $pageheight;
    my $P;
    my $treeView;

    my $hMargin = $c->fpixels( $prtHMargin || 0 );
    my $vMargin = $c->fpixels( $prtVMargin || 0 );

    $Media = 'BBox' if $toPDF and $toEPS;       # hack

    if ( $Media eq 'User' ) {
        $prtFmtWidth  = $c->fpixels( $prtFmtWidth  || 0 );
        $prtFmtHeight = $c->fpixels( $prtFmtHeight || 0 );
    }
    elsif ( $Media ne 'BBox' ) {
        die "Unknown media $Media\n" unless exists $media{$Media};
        $prtFmtWidth  = $media{$Media}[0];
        $prtFmtHeight = $media{$Media}[1];
    }

    _msg(
        "Printing (TO-FILE=$toFile, SVG=$toSVG, PDF=$toPDF, EPS=$toEPS, FIL=$fil, CMD=$cmd, MEDIA=$Media($prtFmtWidth x $prtFmtHeight), RANGE=$printRange)\n"
    );

    if ($toPDF) {
        $pagewidth  = $prtFmtWidth - 2 * $hMargin;
        $pageheight = $prtFmtHeight - 2 * $vMargin;
        local $TrEd::Convert::support_unicode = 1 if ( $] >= 5.008 );
        $P = Tk::Canvas::PDF->new(
            -unicode => ( $] >= 5.008 ) ? 1 : 0,
            -encoding => $TrEd::Convert::support_unicode ? 'utf8'
            : $TrEd::Convert::outputenc,
            -ttfont => $fontSpec->{TTF},
            ( $Media ne 'BBox' )
            ? ( -media => [ 0, 0, $prtFmtWidth, $prtFmtHeight ] )
            : ()
        );

        $treeView = new TrEd::PDFTreeView($c);
        $treeView->apply_options($canvas_opts);
        $treeView->initPDF($P);
    }
    elsif ($toSVG) {
        $pagewidth  = $prtFmtWidth - 2 * $hMargin;
        $pageheight = $prtFmtHeight - 2 * $vMargin;
        $P          = Tk::Canvas::SVG->new(
              ( $Media ne 'BBox' )
            ? ( -media => [ 0, 0, $prtFmtWidth, $prtFmtHeight ] )
            : ()
        );
        my $balloon = $c->toplevel->Balloon( -state => 'balloon' );
        $treeView = new TrEd::TreeView( $c, 'CanvasBalloon' => $balloon );
        $treeView->apply_options($canvas_opts);
    }
    else {
        $treeView = new TrEd::PSTreeView($c);
        $treeView->apply_options($canvas_opts);
        $treeView->setFontMetrics( $fontSpec->{AFM}, $fontSpec->{Size} );
    }

    unless ( $toPDF or $toSVG or $printColors ) {
        $treeView->apply_options(
            {   lineColor        => 'black',
                currentNodeColor => $bwModeNodeColor,
                nearestNodeColor => $bwModeNodeColor,
                nodeColor        => $bwModeNodeColor,
                currentBoxColor  => 'white',
                boxColor         => 'white',
                textColor        => 'black',
                textColorShadow  => 'black',
                textColorHilite  => 'black',
                textColorXHilite => 'black',
                activeTextColor  => 'black',
                noColor          => 1,
                backgroundColor  => 'white',
            }
        );
    }
    my $create_dir_for_one_tree = $printRange =~ m/[-,]/;
    my @printList = parse_print_list( $fsfile, $printRange );
    return unless @printList;

    if ( defined($stylesheet) ) {
        $treeView->set_patterns( $stylesheet->{patterns} );
        $treeView->set_hint( \$stylesheet->{hint} );
    }

    $treeView->apply_options(
        {   lineWidth => 1,
            (   (          !$toSVG
                        or !$extra_opts->{use_svg_desc_and_title}
                        and @printList < 2
                )
                ? ( drawSentenceInfo => $snt      ? 1 : 0,
                    drawFileInfo     => $fileinfo ? 1 : 0,
                    )
                : ()
            )
        }
    );

    my ( $infot, $infotext );
    if ($toplevel) {
        $infotext = "Printing";
        $infot    = $toplevel->Toplevel();
        $infot->UnmapWindow;
        my $f = $infot->Frame(qw/-relief raised -borderwidth 3/)->pack();
        $f->Label(
            -textvariable => \$infotext,
            -wraplength   => 200
        )->pack();
        $infot->overrideredirect(1);
        $infot->Popup();
        $toplevel->Busy( -recurse => 1 );
    }
    eval {
        if ( $toPDF or $toSVG )
        {
            my $scale;
            for ( my $t = 0; $t <= $#printList; $t++ ) {
                $infotext = "Printing $printList[$t]";
                $infot->idletasks() if ($infot);
                _msg("$infotext\n");
                $P->new_page();
                my $valtext;
                do {
                    $treeView->set_showHidden($show_hidden);
                    my $nodes
                        = get_nodes_callback( $get_nodes_callback, $treeView,
                        $fsfile, $printList[$t] - 1, undef );
                    {
                        my $rtl = $treeView->{disableRTL};
                        $treeView->{disableRTL} = $toSVG ? 1 : $rtl;
                        if ( ref($snt) eq 'ARRAY' ) {
                            $valtext = $snt->[ $printList[$t] - 1 ];
                        }
                        elsif ( ref($snt) eq 'CODE' ) {
                            $valtext = $snt->( $fsfile, $printList[$t] - 1 );
                        }
                        else {
                            $valtext
                                = $treeView->value_line( $fsfile,
                                $printList[$t] - 1,
                                1, 0, $grp_ctx );
                        }
                        $treeView->{disableRTL} = $rtl;
                    }
                    {
                        local $grp_ctx->{treeView} = $treeView if $grp_ctx;
                        $treeView->redraw(
                            $fsfile, undef, $nodes, $valtext,
                            undef,   $grp_ctx
                        );
                    }
                };
                my $width  = $c->fpixels( $treeView->get_canvasWidth ) + 10;
                my $height = $c->fpixels( $treeView->get_canvasHeight ) + 10;
                my $rotate
                    = !$toEPS
                    && !$noRotate
                    && $Media ne 'BBox'
                    && $height < $width;
                if ( $Media eq 'BBox' ) {
                    $pagewidth  = $width;
                    $pageheight = $height;
                    if ($toSVG) {
                        if ( @printList == 1 ) {
                            $P->{Media} = [
                                0, 0,
                                $pagewidth + 2 * $hMargin,
                                $pageheight + 2 * $vMargin
                            ];
                        }
                        else {
                            $P->{Media} = [
                                0, 0,
                                $pagewidth + 2 * $hMargin,
                                $pageheight + 2 * $vMargin
                            ];
                        }
                    }
                    else {
                        if ( @printList == 1 ) {
                            $P->{PDF}->mediabox(
                                0, 0,
                                $pagewidth + 2 * $hMargin,
                                $pageheight + 2 * $vMargin
                            );
                        }
                        else {
                            $P->{current_page}->mediabox(
                                0, 0,
                                $pagewidth + 2 * $hMargin,
                                $pageheight + 2 * $vMargin
                            );
                        }
                    }
                }
                if ($rotate) {
                    $scale
                        = min( $pagewidth / $height, $pageheight / $width );
                }
                else {
                    $scale
                        = min( $pageheight / $height, $pagewidth / $width );
                }
                $scale = 1 if ( $scale > 1 and !$maximizePrintSize );

                my @opts;
                if ($toSVG
                    and (  $extra_opts->{use_svg_desc_and_title}
                        or @printList > 1 )
                    )
                {
                    if ($snt) {
                        if ( ref($valtext) eq 'ARRAY' ) {

                            # map FSNodes to IDs
                            my @mapped;
                            my %types;
                            foreach my $v (@$valtext) {
                                my ( $value, @tags ) = @$v;
                                @tags = map {
                                    if (UNIVERSAL::DOES::does(
                                            $_, 'Treex::PML::Node'
                                        )
                                        )
                                    {
                                        my $node    = $_;
                                        my $type    = $node->type;
                                        my $id_attr = $types{$type};
                                        if ( !$id_attr and $type ) {
                                            ($id_attr)
                                                = $type->find_members_by_role(
                                                '#ID');
                                            $types{$type} = $id_attr
                                                = $id_attr->get_name
                                                if $id_attr;
                                        }
                                        ( $id_attr and $node->{$id_attr} )
                                            ? ( '#' . $node->{$id_attr} )
                                            : ();    #$node
                                    }
                                    elsif (/^[a-zA-Z:_]+=HASH\(/) {
                                        ();
                                    }
                                    else {
                                        ($_);
                                    }
                                } @tags;
                                push @mapped, [ $value, @tags ];
                            }
                            push @opts, ( -desc => \@mapped );
                        }
                        else {
                            push @opts, ( -desc => $valtext );
                        }
                    }
                    if ($fileinfo) {
                        push @opts,
                            ( -title => TrEd::File::filename( $fsfile->filename ) . ' ('
                                . $printList[$t] . '/'
                                . ( $fsfile->lastTreeNo + 1 )
                                . ')' );
                    }
                }

                my %final_opts = (
                    -width     => $width,
                    -height    => $height,
                    -grayscale => !$printColors,
                    -scale     => [ $scale, $scale ],
                    -translate => [
                        $hMargin + ( $pagewidth - $width * $scale ) / 2,
                        $vMargin + ( $pageheight - $height * $scale ) / 2
                    ],
                    -balloon => $treeView->get_CanvasBalloon,
                    -compress => $extra_opts->{compress} || 0
                );
                if ($rotate) {
                    $final_opts{-rotate}    = -90;
                    $final_opts{-translate} = [
                        $hMargin + ( $pagewidth - $height * $scale ) / 2,
                        $vMargin + ( $pageheight + $width * $scale ) / 2
                    ];
                }
                $P->draw_canvas( $c, %final_opts, @opts );
            }
            if ($toSVG) {
                _msg("saving SVG to $fil\n");
            }
            else {
                _msg("saving PDF to $fil\n");
            }
            if ( defined($toFile) and $toFile == 2 ) {
                $return = $P->finish();
            }
            elsif ( defined($toFile) and $toFile == 3 ) {
                $return = $P->finish( -object => 1 );
            }
            elsif ( $toFile and $fil ) {
                $return = $fil;
                $P->finish( -file => $fil, -alwayscreatedir => $create_dir_for_one_tree );
            }
            elsif ($cmd) {
                $return = 1;
                $SIG{'PIPE'} = sub { };
                eval {
                    require File::Temp;
                    my $fh = new File::Temp( UNLINK => 0 );
                    my $fn = $fh->filename;
                    $P->finish( -file => $fn );
                    open $fh, $fn;
                    binmode $fh;
                    my $out = new IO::Pipe;
                    $out->writer($cmd);
                    binmode $out;
                    $out->print(<$fh>);
                    unlink $fh;
                    close $fh;
                    close $out;
                } || do {

                    #_msg($@) if $@;
                    die $@
                        . "Print: aborting - failed to open pipe to '$cmd': $!\n";
                };
            }
            else {
                die "Print: No output file or command pipe specified!\n";
            }
            _msg( $toSVG ? "SVG done\n" : "PDF done\n" );
        }
        else {
            my $i;
            my %pso;
            my ( $O, $FNT );
            if ( defined($toFile) and $toFile == 2 or $toFile == 3 ) {
                $return = '';
                require IO::String;
                $O = IO::String->new($return);
            }
            elsif ( $toFile and $fil ) {
                $return = $fil;
                unless ( open( $O, '>' . $fil ) ) {
                    die "Print: aborting - failed to open file '$fil': $!\n";
                }
            }
            elsif ($cmd) {
                $return = 1;
                $SIG{'PIPE'} = sub { };
                unless ( open( $O, '| ' . $cmd ) ) {
                    die
                        "Print: aborting - failed to open pipe to '$cmd': $!\n";
                }
            }
            else {
                die "Print: No output file or command pipe specified!\n";
            }

            my $psFontName = $treeView->getFontName();
            _msg( "Font: ", $fontSpec->{PS},   "\n" );
            _msg( "AFM: ",  $fontSpec->{AFM},  "\n" );
            _msg( "Size: ", $fontSpec->{Size}, "\n" );
            _msg( "Name: ", $psFontName,       "\n" );
            local $TrEd::Convert::outputenc = 'iso-8859-2';
            unless ( open( $FNT, '<', $fontSpec->{PS} ) ) {
                die "Aborting: failed to open file '$fontSpec->{PS}': $!\n";
            }
            for ( my $t = 0; $t <= $#printList; $t++ ) {
                $infotext = "Printing $printList[$t]";
                $infot->idletasks() if ($infot);
                _msg("$infotext\n");
                do {
                    $treeView->set_showHidden($show_hidden);
                    my $nodes
                        = get_nodes_callback( $get_nodes_callback, $treeView,
                        $fsfile, $printList[$t] - 1, undef );
                    my $valtext;
                    if ( ref($snt) eq 'ARRAY' ) {
                        $valtext = $snt->[ $printList[$t] - 1 ];
                    }
                    elsif ( ref($snt) eq 'CODE' ) {
                        $valtext = $snt->( $fsfile, $printList[$t] - 1 );
                    }
                    else {
                        $valtext
                            = $treeView->value_line( $fsfile,
                            $printList[$t] - 1,
                            1, 0, $grp_ctx );
                    }
                    {
                        local $grp_ctx->{treeView} = $treeView if $grp_ctx;
                        $treeView->redraw(
                            $fsfile, undef, $nodes, $valtext,
                            undef,   $grp_ctx
                        );
                    }
                };

                my $rotate
                    = !$toEPS
                    && !$noRotate
                    && $treeView->get_canvasHeight
                    < $treeView->get_canvasWidth;
                if ( not $rotate ) {
                    $pagewidth  = $prtFmtWidth - 2 * $hMargin;
                    $pageheight = $prtFmtHeight - 2 * $vMargin;
                }
                else {
                    $pagewidth  = $prtFmtHeight - 2 * $vMargin;
                    $pageheight = $prtFmtWidth - 2 * $hMargin;
                }
                _msg( "Real Page : ", int($pagewidth), "x", int($pageheight),
                    "\n" );

                %pso = (
                    -colormode => $printColors ? 'color' : 'gray',
                    '-x'       => 0,
                    '-y'       => 0,
                    -fontmap   => {
                        $treeView->get_font() =>
                            [ $psFontName, $fontSpec->{Size} ]
                    },
                    -width  => $treeView->get_canvasWidth,
                    -height => $treeView->get_canvasHeight,
                    -rotate => $rotate
                );
                my $width  = $c->fpixels( $treeView->get_canvasWidth );
                my $height = $c->fpixels( $treeView->get_canvasHeight );

                unless ($toEPS) {
                    if (   $maximizePrintSize
                        or $width > $pagewidth
                        or $height > $pageheight )
                    {
                        _msg("Adjusting print size\n");
                        if ( $width / $pagewidth * $pageheight > $height ) {
                            $pso{-pagewidth} = $pagewidth;
                            _msg("Scaling by tree width,\n");
                            _msg("forcing box width to $pagewidth\n");
                        }
                        else {
                            $pso{-pageheight} = $pageheight;
                            _msg("Scaling by tree height,\n");
                            _msg("forcing box height to $pageheight\n");
                        }
                    }
                }
                my $ps_result = $c->postscript(%pso);
                my $curenc    = <<END_OF_ENC;
/CurrentEncoding [
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/exclam/quotedbl/numbersign/dollar/percent/ampersand/quotesingle
/parenleft/parenright/asterisk/plus/comma/hyphen/period/slash
/zero/one/two/three/four/five/six/seven
/eight/nine/colon/semicolon/less/equal/greater/question
/at/A/B/C/D/E/F/G
/H/I/J/K/L/M/N/O
/P/Q/R/S/T/U/V/W
/X/Y/Z/bracketleft/backslash/bracketright/asciicircum/underscore
/grave/a/b/c/d/e/f/g
/h/i/j/k/l/m/n/o
/p/q/r/s/t/u/v/w
/x/y/z/braceleft/bar/braceright/asciitilde/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/exclamdown/cent/sterling/currency/yen/brokenbar/section
/dieresis/copyright/ordfeminine/guillemotleft/logicalnot/hyphen/registered/macron
/degree/plusminus/twosuperior/threesuperior/acute/mu/paragraph/periodcentered
/cedilla/onesuperior/ordmasculine/guillemotright/onequarter/onehalf/threequarters/questiondown
/Agrave/Aacute/Acircumflex/Atilde/Adieresis/Aring/AE/Ccedilla
/Egrave/Eacute/Ecircumflex/Edieresis/Igrave/Iacute/Icircumflex/Idieresis
/Eth/Ntilde/Ograve/Oacute/Ocircumflex/Otilde/Odieresis/multiply
/Oslash/Ugrave/Uacute/Ucircumflex/Udieresis/Yacute/Thorn/germandbls
/agrave/aacute/acircumflex/atilde/adieresis/aring/ae/ccedilla
/egrave/eacute/ecircumflex/edieresis/igrave/iacute/icircumflex/idieresis
/eth/ntilde/ograve/oacute/ocircumflex/otilde/odieresis/divide
/oslash/ugrave/uacute/ucircumflex/udieresis/yacute/thorn/ydieresis
] def
END_OF_ENC
                $ps_result
                    =~ s{/CurrentEncoding\s*\[\s*(?:/space\s*)+\] def}{$curenc}g;
                my @ps = split /\n/, $ps_result;
                $i = 0;
                if ( $t > 0 ) {
                    $i++ while ( $i <= $#ps and $ps[$i] !~ /^%%Page:/ );
                    print $O '%%Page: ', $t + 1, " ", $t + 1, "\n";
                    $i++;
                }
                else {    # $t == 0
                    $i = 0;
                    unless ($toEPS) {
                        $ps[0] =~ s/ EPSF-3.0//;
                        print $O $ps[ $i++ ], "\n"
                            while ( $i <= $#ps
                            and $ps[$i] !~ /^%\%BoundingBox:/ );
                        print $O $ps[ $i++ ], "\n";
                        print $O
                            "\%\%DocumentMedia: $Media $prtFmtWidth $prtFmtHeight white()\n";
                        print $O '%%Pages: ', $#printList + 1, "\n";
                        $i++;
                    }
                    print $O $ps[ $i++ ], "\n"
                        while ( $i <= $#ps
                        and $ps[$i]
                        !~ /^%\%DocumentNeededResources: font $psFontName/ );
                    print $O $ps[ $i++ ], "\n"
                        while ( $i <= $#ps
                        and $ps[$i] !~ /^%\%BeginProlog|^%\%BeginSetup/ );
                    if ( $ps[$i] =~ /^%\%BeginSetup/ ) {

                        # this hack is to partially fix Tk804.025 bug
                        print $O '%%BeginProlog', "\n";

                        #           print $O '%%BeginFont tredfont',"\n";
                        print $O (<$FNT>);

                        #           print $O '%%EndFont',"\n\n";
                    }
                    else {
                        print $O $ps[ $i++ ], "\n";

                        #           print $O '%%BeginFont ',"$psFontName\n";
                        print $O (<$FNT>);

                    #       print $O '%%EndFont',"\n\n";
                    #         $i++ while ($i<=$#ps and $ps[$i]!~/% StrokeClip/);
                    }
                    print $O $ps[ $i++ ], "\n"
                        while ( $i <= $#ps
                        and $ps[$i]
                        !~ /^%\%IncludeResource: font $psFontName/ );
                    $i++;
                }
                while ( $i <= $#ps && $ps[$i] !~ /^%\%Trailer\w*$/ ) {
                    $ps[$i] =~ s/ISOEncode //g
                        unless $TrEd::Convert::support_unicode;
                    print $O $ps[$i] . "\n"
                        unless ( $toEPS
                        and $ps[$i] =~ /^restore showpage/ );
                    $i++;
                }
            }
            print $O "restore\n" if $toEPS;
            print $O '%%EOF', "\n";
            close($FNT);
            close($O);
        }
    };
    my $err = $@;
    if ($toplevel) {
        $infot->destroy() if ($infot);
        $toplevel->Unbusy();
    }
    die $err if $err;
    return $return;
}

1;
