package TrEd::TreeView;    # -*- cperl -*-

use strict;

#use warnings;
BEGIN {
    use Carp;
    use Tk;
    use Tk::Canvas;
    use Tk::CanvasSee;
    use Tk::Balloon;
    use Tk::Font;
    use Treex::PML;
    use TrEd::MinMax;
    import TrEd::MinMax;
    import TrEd::MinMax 'sum';

    use TrEd::Convert;
    import TrEd::Convert;
    use TrEd::File qw{filename}; 

    use constant NoHash => {};

    use vars
        qw($AUTOLOAD @Options %DefaultNodeStyle $Debug $on_get_root_style $on_get_node_style $on_get_nodes $on_redraw_done %PATTERN_CODE_CACHE %COORD_CODE_CACHE %COORD_SPEC_CACHE %DefaultOptions);

    %DefaultOptions = (
        CanvasBalloon    => undef,
        drawSentenceInfo => 0,
        displayMode      => 0,
        verticalTree     => 0,
        customColors     => {

# note: this very hash is usually shared by all TreeView objects
# modifying it in one TreeView modifies it in all others
# unless you e.g.
#   apply_config({customColors=>{%TrEd::TreeView::DefaultOptions->{customColors}})

            0 => 'darkgreen',
            1 => 'darkblue',
            2 => 'darkmagenta',
            3 => 'orange',
            4 => 'black',
            5 => 'DodgerBlue4',
            6 => 'red',
            7 => 'gold',
            8 => 'cyan',
            9 => 'midnightblue'
        },
        lineSpacing                => 1,
        baseXPos                   => 15,
        baseYPos                   => 15,
        nodeWidth                  => 7,
        nodeHeight                 => 7,
        useAdditionalEdgeLabelSkip => 0,
        currentNodeWidth           => 9,
        currentNodeHeight          => 9,
        nodeXSkip                  => 10,
        nodeYSkip                  => 10,
        edgeLabelSkipAbove         => 10,
        edgeLabelSkipBelow         => 10,
        xmargin                    => 2,
        ymargin                    => 2,
        lineWidth                  => 2,
        lineColor                  => 'gray',
        hiddenLineColor            => 'lightgray',
        dashHiddenLines            => 0,
        lineArrow                  => 'none',
        nodeColor                  => 'yellow',
        nodeOutlineColor           => 'black',
        hiddenNodeColor            => 'black',
        currentNodeColor           => 'red',
        nearestNodeColor           => 'green',
        balanceTree                => 0,
        textColor                  => 'black',
        textColorShadow            => 'darkgrey',
        textColorHilite            => 'darkgreen',
        textColorXHilite           => 'darkred',
        stripeColor                => '#eeeeff',
        labelSep                   => 5,
        columnSep                  => 15,
        vertStripe                 => 0,
        horizStripe                => 1,
        boxColor                   => 'LightYellow',
        currentBoxColor            => 'yellow',
        hiddenBoxColor             => 'gray',
        edgeBoxColor               => '#fff0e0',
        currentEdgeBoxColor        => '#ffe68c',
        hiddenEdgeBoxColor         => "DarkGrey",
        clearTextBackground        => 1,
        backgroundColor            => 'white',
        backgroundImageX           => 0,
        backgroundImageY           => 0,
        noColor                    => 0,
        drawBoxes                  => 0,
        drawEdgeBoxes              => 0,
        highlightAttributes        => 1,
        showHidden                 => 0,
        skipHiddenLevels           => 0,
        skipHiddenParents          => 0,
        drawFileInfo               => 0,
        useFSColors                => 0,
        font                       => '{Arial Unicode Ms} 10',
        reverseNodeOrder           => 0,
        backgroundImage            => undef,
        lineArrowShape             => undef,
        lineDash                   => undef,
    );

    @Options = keys %DefaultOptions;

    %DefaultNodeStyle = (
        CurrentOval        => [],
        Oval               => [],
        TextBox            => [],
        CurrentTextBox     => [],
        CurrentEdgeTextBox => [],
        EdgeTextBox        => [],
        Line               => [ -coords => "n,n,p,p" ],
        SentenceText       => [],
        SentenceLine       => [],
        SentenceFileInfo   => [],
        Text               => [],
        TextBg             => [],
        Node               => [ -shape => 'oval' ],
        Label              => [],
        NodeLabel          => [ -valign => 'top', -halign => 'left' ],
        EdgeLabel          => [ -halign => 'center', -valign => 'top' ]
    );
}

# # #this is a stub
#  our $TEST;
#   use Benchmark qw(:all);
#   *old_redraw = \&redraw;
#   *redraw = sub {
#     my @args = @_;
# #     print timethese(10, {
# #       'c7t1' => sub { old_redraw(@args); },
# #     });
#       cmpthese(10, {	#
#        'c0t0' => sub { old_redraw(@args); },
# #       'c7t1' => sub { $TEST=1; old_redraw(@args); } ,
#       });
#  };

#our $objectno;
our ( $block, $bblock );
$block  = qr/\{((?:(?> [^{}]* )|(??{ $block }))*)\}/x;
$bblock = qr/\{(?:(?>  [^{}]* )|(??{ $bblock }))*\}/x;

{
    no strict 'refs';

    # generate methods
    for my $opt ( @Options, qw(canvasHeight canvasWidth scale scaled_font) ) {
        ( *{"get_$opt"}, *{"set_$opt"} ) = do {
            {
                my $o = $opt;
                ( sub { $_[0]->{$o} }, sub { $_[0]->{$o} = $_[1]; } )
            }
        };
    }
}

sub clear_code_caches {
    %PATTERN_CODE_CACHE = ();
    %COORD_CODE_CACHE   = ();
}

sub new {
    my $self  = shift;
    my $class = ref($self) || $self;
    my $new   = {
        canvas          => shift,
        patterns        => undef,
        hint            => undef,
        node_info       => {},      # contains per-node information
        style_info      => {},      # contains information about styles
        style_hash_info => {},      # -"- cached as hashes
        gen_info   => {},    # contains general information about the canvas
        oinfo_info => {},    # maps canvas objects to nodes
        iinfo_info => {},    # maps canvas object numbers to ID tags
        %DefaultOptions,
        @_
    };
    bless $new, $class;
    return $new;
}

sub AUTOLOAD {
    my $self = shift;
    croak "Unknown function $AUTOLOAD" unless ref($self);
    my $sub = $AUTOLOAD;
    $sub =~ s/.*:://;
    warn "Warning: $sub is not a method of TreeView\n\t";
    warn( join( "\n\t", ( caller(0) )[ 0 .. 4 ] ) . "\n" );
    if ( $sub =~ /^get_(.*)$/ ) {
        return $self->{$1};
    }
    elsif ( $sub =~ /^set_(.*)$/ ) {
        return $self->{$1} = shift;
    }
}

sub DESTROY {
}

sub set_patterns {
    my ( $self, $patterns ) = @_;
    die "Patterns are not array-ref"
        if ( defined($patterns) and !ref($patterns) eq 'ARRAY' );
    $self->{patterns}      = $patterns;
    $self->{pattern_lists} = undef
        ; # clear cached value so that the following call knows it should regenerate it
    $self->{pattern_lists} = $self->get_pattern_lists();
}
# patterns can be either set by stylesheet, or they can be read from fsfile->patterns(), they are parsed afterwards by parse_pattern(), so we got an array of tuples (pattern_type, pattern); 
sub get_pattern_lists {
    my ( $self, $fsfile ) = @_;
    my $patterns = $self->patterns();
    if ( $patterns && $self->{pattern_lists} ) { # if pattern_lists is already filled, return it
        return $self->{pattern_lists};
    }
    my (@node_patterns, @edge_patterns, @style_patterns,
        @patterns,      @label_patterns
    );
    @patterns
        = map { [ $self->parse_pattern($_) ] } $patterns ? @{$patterns}
        : $fsfile ? $fsfile->patterns() 
        :           ();
    @label_patterns = map { $_->[1] } grep { $_->[0] eq 'label' } @patterns; #filter label patterns
    @style_patterns = map { $_->[1] } grep { $_->[0] eq 'style' } @patterns; # filter style patterns
    @patterns = grep { $_->[0] eq 'node' or $_->[0] eq 'edge' } @patterns; # filter only edge and node patterns, others are discarded
    @node_patterns = map { $_->[1] } grep { $_->[0] eq 'node' } @patterns; # filter node patterns
    @edge_patterns = map { $_->[1] } grep { $_->[0] eq 'edge' } @patterns; # filter edge patterns
    my $pl = [
        \@node_patterns, \@edge_patterns, \@style_patterns,
        \@patterns,      \@label_patterns
    ];

    if ($patterns) {
        $self->{pattern_lists} = $pl; # save result in pattern_lists
    }
    return $pl; #reference to array which contains references to arrays of patterns
}
# return our patterns (affected by stylesheet, can be changed via window->apply_stylesheeet)
sub patterns {
    my $self = shift;
    return if !ref $self;
    return $self->{patterns};
}

sub set_hint {
    my ( $self, $hint ) = @_;
    die "Hint is not scalar-ref"
        if ( defined $hint && !ref $hint eq 'SCALAR' );
    $self->{hint} = $hint;
}

sub hint {
    my $self = shift;
    return $self->{hint};
}

sub canvas {
    my $self = shift;
    return unless ref($self);
    return $self->{canvas};
}
# return the real canvas to draw on... and cache it under our realcanvas hash key, creates Subwidget scrolled if our canvas is not isa(Tk::Canvas)
sub realcanvas {
    my $self = shift;
    return if not ref $self;
    return (
        $self->{realcanvas} ||= (
              $self->{canvas}->isa("Tk::Canvas")
            ? $self->{canvas}
            : $self->{canvas}->Subwidget("scrolled")
        )
    );
}

sub scale_factor {
    my ($self) = @_;
    my $s = $self->{scale};
    if ( $s < 0 ) {
        return 1 / ( -$s + 1 );
    }
    else {
        return ( $s + 1 );
    }
}

sub scale {
    my ( $self, $new_scale, $current_node ) = @_;
    my $c      = $self->realcanvas;
    my $factor = 1;
    for my $s ( -$self->{scale}, $new_scale ) {
        if ( $s < 0 ) {
            $factor /= ( -$s + 1 );
        }
        else {
            $factor *= ( $s + 1 );
        }
    }
    my ( $x, $y );
    if ( defined $current_node ) {
        if ( ref($current_node) ) {
            ( $x, $y ) = map $self->get_node_pinfo( $current_node, $_ ),
                "XPOS", "YPOS";
        }
        else {
            ( $x, $y ) = (
                $c->canvasx( $c->pointerx - $c->rootx ),
                $c->canvasy( $c->pointery - $c->rooty )
            );
        }
    }
    else {
        ( $x, $y ) = ( 0, 0 );
    }
    my $nx      = $x * $factor;
    my $ny      = $y * $factor;
    my @corners = (
        $c->canvasx(0), $c->canvasy(0),
        $c->canvasx( $c->width ),
        $c->canvasy( $c->height ),
    );
    my @scrollregion = @{ $c->cget('-scrollregion') };
    $c->configure(
        -scrollregion => [
            min( $corners[0] - $x + $nx, $scrollregion[0], $corners[0] ) || 0,
            min( $corners[1] - $y + $ny, $scrollregion[1], $corners[1] ) || 0,
            max( $corners[2] - $x + $nx, $scrollregion[2], $corners[2] ) || 0,
            max( $corners[3] - $y + $ny, $scrollregion[3], $corners[3] ) || 0,
        ]
    );
    my $xview = $c->xviewCoord($x);
    my $yview = $c->yviewCoord($y);

    $self->{scale} = $new_scale;
    $c->scale( 'all', 0, 0, $factor, $factor );

    # scale font
    if ( $factor != 1 ) {
        $self->scale_font($factor);
        $c->itemconfigure( 'text_item', -font => $self->{scaled_font} );
    }
    $self->{$_} *= $factor for qw(canvasWidth canvasHeight);
    for my $item ( $c->find( withtag => 'scale_width' ) ) {
        $c->itemconfigure( $item,
            -width => $factor * $c->itemcget( $item, '-width' ) );
    }
    for my $item ( $c->find( withtag => 'scale_arrow' ) ) {
        my $shape = $c->itemcget( $item, '-arrowshape' );
        next unless $shape;
        $c->itemconfigure( $item,
            -arrowshape => [ map { $_ * $factor } @$shape ] );
    }

    $c->xviewCoord( $x * $factor, $xview );
    $c->yviewCoord( $y * $factor, $yview );
    $c->configure(
        -scrollregion => [
            min2( 0, $c->canvasx(0) ) || 0,
            min2( 0, $c->canvasy(0) ) || 0,
            max2( $c->canvasx( $c->width ), $self->{canvasWidth} ) || 0,
            max2( $c->canvasx( $c->height ), $self->{canvasHeight} )
        ]
    ) || 0;
}

sub scale_font {
    my ( $self, $factor ) = @_;
    my $font = $self->{scaled_font} || $self->get_font;
    my $c = $self->realcanvas;
    if ( !ref $font ) {
        $font = $c->fontCreate( $c->fontActual($font) );
    }
    if ( !defined $self->{font_size} ) {
        $self->{font_size} = $font->actual('-size');
    }
    $self->{font_size} *= $factor;
    my $new_size = int( $self->{font_size} ) || 1;
    $font = $font->Clone( -size => $new_size );
    $self->{scaled_font} = $font;
}

sub reset_scale {
    my $self = shift;
    $self->{scale}       = 0;
    $self->{font_size}   = undef;
    $self->{scaled_font} = undef;
}
# clears information about node, style, style hash, gen_info, oinfo?
sub clear_pinfo {
    my $self = shift;
    return if !ref $self;
    %{ $self->{node_info} }       = ();
    %{ $self->{style_info} }      = ();
    %{ $self->{style_hash_info} } = ();
    %{ $self->{gen_info} }        = ();
    %{ $self->{oinfo} }           = ();
    return;
    #  %{$self->{iinfo}}=();
}

sub store_gen_pinfo {
    my ( $self, $key, $value ) = @_;
    return if !ref $self;
    $self->{gen_info}->{$key} = $value;
}

sub get_gen_pinfo {
    my ( $self, $key ) = @_;
    return if !ref $self;
    return $self->{gen_info}->{$key};
}

sub store_node_pinfo {
    my ( $self, $node, $key, $value ) = @_;
    return if !ref $self;
    $self->{node_info}{$node}{$key} = $value;
}

sub store_obj_pinfo {
    my ( $self, $obj, $value ) = @_;
    return if !ref $self;
    $self->{oinfo}->{$obj} = $value;
}

# sub get_id_pinfo {
#   my ($self,$obj) = @_;
#   return if !ref $self;
#   return $self->{iinfo}->{$obj};
# }

# sub store_id_pinfo {
#   my ($self,$obj,$value) = @_;
#   return if !ref $self;
#   $self->{iinfo}->{$obj}=$value;
# }

sub get_node_pinfo {
    my ( $self, $node, $key ) = @_;
    return if !ref $self;
    my $val;
    $val = $self->{node_info}{$node}{$key};
    if ( $key =~ /[XY]/ ) {
        return $self->scale_factor * $val;
    }
    else {
        return $val;
    }
}

sub get_obj_pinfo {
    my ( $self, $obj ) = @_;
    return if !ref $self;
    return $self->{oinfo}->{$obj};
}

sub node_is_displayed {
    my ( $self, $node ) = @_;
    return $self->{node_info}{$node}{E} ? 1 : 0;
}

sub find_item {
    my $self = shift;

    #return map { $self->get_id_pinfo($_) }
    return $self->canvas()->find(@_);
}

sub apply_options {
    my ( $self, $opts ) = @_;
    return if !ref $self;
    foreach ( keys %$opts ) {
        $self->{$_} = $opts->{$_} if ( exists( $DefaultOptions{$_} ) );
    }
    return;
}

sub options {
    my ($self) = @_;
    return if !ref $self;
    return { map { $_ => $self->{$_} } @Options };
}

sub value_line_list {
    my ( $self, $fsfile, $tree_no, $no_numbers, $tags, $grp ) = @_;
    return () unless $fsfile;

    my @patterns = $self->get_label_patterns( $fsfile, "text" );
    if (@patterns) {
        my $node = $fsfile->treeList->[$tree_no];
        my @sent = ();
        my $attr = $fsfile->FS->sentord();
        $attr = $fsfile->FS->order() unless ( defined($attr) );

        # schwartzian transform
        if ( defined($attr) ) {
            while ($node) {
                my $ord = $node->get_member($attr);
                push @sent, [ $node, $ord ]
                    unless ( $ord >= 999 )
                    ;    # this unless is a PDT1.0 specific thing
                $node = $node->following();
            }
        }
        else {

            # try to get the per-node ordering
            my %ord_attr_hash;    # hash ordering attributes by type
            while ($node) {
                my $ord;

                # find ordering attribute
                my $type = $node ? $node->type : undef;
                if ($type) {
                    my $ord_attr = $ord_attr_hash{$type};
                    unless ( defined($ord_attr) ) {
                        ($ord_attr) = $node->get_ordering_member_name;
                        $ord_attr_hash{$type} = $ord_attr;
                    }
                    $ord = $node->get_member($ord_attr);
                    push @sent, [ $node, $ord ];
                }
                else {
                    push @sent, [ $node, 0 ];
                }
                $node = $node->following();
            }
        }
        @sent = map { $_->[0] } sort { $a->[1] <=> $b->[1] } @sent;
        my @vl = ();

        foreach $node (@sent) {
            my %styles;
            my $add_space = 0;
            my $no_space;
            foreach my $style (@patterns) {
                my $msg
                    = $self->interpolate_text_field( $node, $style, $grp );
                foreach ( split( m/([\#\$]${bblock})/, $msg ) ) {
                    if (/^\$${block}$/) {

                        #attr
                        my $val = _present_attribute( $node, $1 );
                        if ( $val ne "" ) {
                            push @vl,
                                [
                                $val, $node,
                                map { encode("$_ => $styles{$_}") }
                                    keys %styles
                                ];
                            $add_space = 1;
                        }
                    }
                    elsif (/^\#${block}$/) {

                        #attr
                        my $style = $1;
                        if ( $style eq '-nospaceafter' ) {
                            $no_space = 1;
                        }
                        elsif ( $style eq '-nospacebefore' ) {
                            pop @vl if @vl and $vl[-1][0] eq ' ';
                        }
                        elsif ( $style =~ /-tag:\s*(.*\S)\s*$/ ) {
                            if ( $styles{tag} ne "" ) {
                                $styles{tag} .= ",$1";
                            }
                            else {
                                $styles{tag} = "$1";
                            }
                        }
                        elsif ( $style =~ /(-[a-z0-9]+):\s*(.*\S)\s*$/ ) {
                            $styles{$1} = $2;
                        }
                        else {
                            $styles{-foreground} = $style;
                        }
                    }
                    elsif ( $_ ne '' ) {
                        push @vl, [
                            $_, $node, 'text',
                            map {
                                $_ eq 'tag'
                                    ? split( /,/, encode( $styles{$_} ) )
                                    : encode("$_ => $styles{$_}")
                                } keys %styles
                        ];
                        $add_space = 1;
                    }
                }
            }
            push @vl, [ " ", 'space' ] if !$no_space and $add_space;
        }
        return @vl;
    }
    else {
        if ($tags) {
            return
                map { ( $_, $_->[0] ne "\n" ? ( [ ' ', 'space' ] ) : () ) }
                $fsfile->value_line_list( $tree_no, $no_numbers, $tags,
                $grp );
        }
        else {
            return $fsfile->value_line_list( $tree_no, $no_numbers, $tags,
                $grp );
        }
    }
}

sub rightToLeft {
    my ( $self, $fsfile ) = @_;
    my ($reverse) = $self->get_label_patterns( $fsfile, "rtl" );
    if ( defined($reverse) ) {
        return int($reverse) ? 1 : 0;
    }
    return;
}

sub value_line {
    my ( $self, $fsfile, $tree_no, $no_numbers, $tags, $grp ) = @_;
    return unless $fsfile;
    my $right_to_left = $self->{disableRTL} ? 0 : $self->rightToLeft($fsfile);
    $right_to_left = $self->{reverseNodeOrder} unless defined $right_to_left;

    my $prfx
        = ( $no_numbers
        ? ""
        : ( $tree_no + 1 ) . "/" . ( $fsfile->lastTreeNo + 1 ) . ": " );
    if ( $tags or $self->get_label_patterns( $fsfile, "text" ) ) {
        if ($right_to_left) {
            return [
                [ $prfx, 'prefix' ],
                map { $_->[0] = encode( $_->[0] ); $_ } grep { $_->[0] ne "" }
                    reverse $self->value_line_list(
                    $fsfile, $tree_no, $no_numbers, 1, $grp
                    )
            ];
        }
        else {
            return [
                [ $prfx, 'prefix' ],
                map { $_->[0] = encode( $_->[0] ); $_ }
                    grep { $_->[0] ne "" } $self->value_line_list(
                    $fsfile, $tree_no, $no_numbers, 1, $grp
                    )
            ];
        }
    }
    else {
        if ($right_to_left) {
            return $prfx . join " ", map { encode($_) } grep { $_ ne "" }
                reverse $self->value_line_list( $fsfile, $tree_no,
                $no_numbers, 0, $grp );
        }
        else {
            return $prfx . join " ",
                map { encode($_) }
                grep { $_ ne "" }
                $self->value_line_list( $fsfile, $tree_no, $no_numbers, 0,
                $grp );
        }
    }
}

sub nodes {
    my ( $self, $fsfile, $tree_no, $prevcurrent ) = @_;
    my $right_to_left = $self->rightToLeft($fsfile);
    $right_to_left = $self->{reverseNodeOrder} unless defined $right_to_left;
    my $l = callback( $on_get_nodes, $self, $fsfile, $tree_no, $prevcurrent );
    if ( ref($l) eq 'ARRAY' and @$l == 2 ) {
        return @$l;
    }
    else {
        my ( $nodes, $current )
            = $fsfile->nodes( $tree_no, $prevcurrent,
            $self->get_showHidden() );
        if ($right_to_left) {
            return ( [ reverse @$nodes ], $current );
        }
        return ( $nodes, $current );
    }
}

sub getFontHeight {
    my ($self) = @_;
    my $font = $self->get_font;
    if ( $self->{cached_font} eq $font ) {
        return $self->{cached_size};
    }
    else {
        $self->{cached_font} = $font;
        return ( $self->{cached_size}
                = $self->canvas->fontMetrics( $font, '-linespace' ) );
    }
}

sub getTextWidth {
    my ( $self, $text, $wrap ) = @_;
    return $wrap
        ? max(
        map { $self->canvas->fontMeasure( $self->get_font, $_ ) } split /\n/,
        $text
        )
        : $self->canvas->fontMeasure( $self->get_font, $text );
}

sub getTextWidthAndHeight {
    my ( $self, $text ) = @_;
    my @l = split /\n/, $text;
    return @l > 1
        ? (
        max( map { $self->canvas->fontMeasure( $self->get_font, $_ ) } @l ),
        $#l + 1
        )
        : ( $self->canvas->fontMeasure( $self->get_font, $l[0] ), 1 );
}

# this is a 2nd pass for balancing nodes
sub balance_xfix_node {
    my ( $self, $xfix, $node ) = @_;
    my $node_info = $self->{node_info};
    $xfix += $node_info->{$node}{"XFIX"};
    foreach my $c ( @{ $node_info->{$node}{"CH"} } ) {
        $node_info->{$c}{"XPOS"} = $node_info->{$c}{"XPOS"} + $xfix;
        $node_info->{$c}{"NodeLabel_XPOS"}
            = $node_info->{$c}{"NodeLabel_XPOS"} + $xfix;
        balance_xfix_node( $self, $xfix, $c );
    }
}

# this routine computes node XPos in balanced mode
sub balance_node {
    my ( $self, $level, $baseX, $node, $balanceOpts ) = @_;
    my $xskip     = $balanceOpts->[3];
    my $spread    = $balanceOpts->[2];
    my $node_info = $self->{node_info};
    my $i         = 0;
    my $before    = $node_info->{$node}{"Before"};

    #  $last_baseX+=$node_info->{$node}{"Before"};
    my $CH         = $node_info->{$node}{"CH"};
    my @c          = $CH ? @$CH : ();
    my $prev_baseX = $baseX->[$level];
    my $next_level = $spread ? 0 : $level + 1;
    my $max_level  = $spread ? 0 : $#$baseX;
    foreach my $c (@c) {
        $baseX->[$next_level]
            = $self->balance_node( $next_level, $baseX, $c, $balanceOpts );
        $baseX->[$next_level] += $xskip;
    }
    $baseX->[$next_level] -= $xskip if $spread and @c;
    my $xpos;
    if ( !@c ) {
        $xpos = $baseX->[$level] + $node_info->{$node}{"XPOS"};
    }
    else {
        if ( scalar(@c) % 2 == 1 ) {    # odd number of nodes
            if ( $balanceOpts->[0] ) {    # balance on middle node
                $xpos = $node_info->{ $c[ $#c / 2 ] }{"XPOS"};
            }
            else {
                $xpos = ( $node_info->{ $c[$#c] }{"XPOS"}
                        + $node_info->{ $c[0] }{"XPOS"} ) / 2;
            }
        }
        else {                            # even number of nodes
            if ( $balanceOpts->[1] ) {
                $xpos = ( $node_info->{ $c[ 1 + $#c / 2 ] }{"XPOS"}
                        + $node_info->{ $c[ $#c / 2 ] }{"XPOS"} ) / 2;
            }
            else {
                $xpos = ( $node_info->{ $c[$#c] }{"XPOS"}
                        + $node_info->{ $c[0] }{"XPOS"} ) / 2;
            }
        }
    }
    my $xfix = $prev_baseX + $before - $xpos;
    if ( $xfix > 0 ) {
        if (@c) {
            $baseX->[$_] += $xfix for $next_level .. $max_level;
        }
        $xpos += $xfix;
    }
    else {
        $xfix = 0;
    }
    $node_info->{$node}{"XFIX"} = $xfix;
    my $add = $xpos - $node_info->{$node}{"XPOS"};
    $node_info->{$node}{"XPOS"} = $xpos;

    $node_info->{$node}{"NodeLabel_XPOS"}
        = $node_info->{$node}{"NodeLabel_XPOS"} + $add;
    return max2( $baseX->[$level], $xpos + $node_info->{$node}{"After"} );
}

sub _bno {
    my ( $nodes, $i, $last, $node_info ) = @_;
    my @res;
    for ( ; $i <= $last; $i++ ) {
        my $node = $nodes->[$i];
        my $kids = $node_info->{$node}{"CH"};
        if ($kids) {
            my $mid = int @$kids / 2 - 1;
            push @res,
                @{ _bno( $kids, 0, $mid, $node_info ) },
                $node,
                @{ _bno( $kids, $mid + 1, $#$kids, $node_info ) };
        }
        else {
            push @res, $node;
        }
    }
    return \@res;
}

sub balance_node_order {
    my ( $self, $nodes ) = @_;
    my @level0;
    my $i         = 0;
    my $node_info = $self->{node_info};
    foreach my $node (@$nodes) {
        my $parent = $node_info->{$node}{"P"};
        push @{ $node_info->{$parent}{"CH"} }, $node;
        push @level0, $node if $node_info->{$node}{"Level"} == 0;
    }
    return _bno( \@level0, 0, $#level0, $node_info );
}
# for node $node compute level on which it is in the tree, return it and write it into $node_info->{$node}{"Level"}; if a parent exists, ref to it is stored in $node_info->{$parent}{'E'}
sub compute_level {
    my ( $self, $node, $Opts, $skipHiddenLevels ) = @_;
    my $node_info = $self->{node_info};
    my $level     = $node_info->{$node}{'Level'};
    if ( defined $level ) {
        return $level;
    }
    $level = 0;
    my $style  = $self->{style_info}{$node};
    my $parent = $style->{'Node'}{'-parent'};
    if ($parent) {
        $parent = $node_info->{$parent}{'E'};
    }
    $parent ||= $node->parent;
    if ($parent) {
        my $plevel
            = $self->compute_level( $parent, $Opts, $skipHiddenLevels );
        if ($skipHiddenLevels) {
            $level = $plevel;
            if ( $node_info->{$parent}{'E'} ) {
                $node_info->{$node}{'P'} = $parent;
                $level++;
            }
            else {
                $node_info->{$node}{'P'} = $node_info->{$parent}{'P'};
            }
            $level += $style->{'Node'}{'-rellevel'}
                if $node_info->{$node}{'E'};
        }
        else {
            $node_info->{$node}{'P'} = $parent;
            $level = $plevel + 1 + $style->{'Node'}{'-rellevel'};
        }
    }
    else {
        $level += $style->{'Node'}{'-rellevel'};
    }
    $node_info->{$node}{'Level'} = $level;
    return $level;
}

sub recalculate_positions_vert {
    my ( $self, $fsfile, $nodes, $Opts, $grp ) = @_;
    return unless ref($self);
    my $node_info   = $self->{node_info};
    my $gen_info    = $self->{gen_info};
    my $lineSpacing = $Opts->{lineSpacing} || $self->get_lineSpacing;
    my $baseXPos    = $Opts->{baseXPos} || $self->get_baseXPos;
    my $baseYPos    = $Opts->{baseYPos} || $self->get_baseYPos;
    my $level;

    my $canvasWidth = 0;
    $self->{canvasHeight} = 0;
    my $node;
    my $labelsep = $Opts->{'labelsep'};
    $labelsep = $self->get_labelSep unless defined $labelsep;
    my $columnsep = $Opts->{'columnsep'};
    $columnsep = $self->get_columnSep unless defined $columnsep;
    my ( $nodeWidth, $nodeHeight )
        = ( $self->get_nodeWidth, $self->get_nodeHeight );
    my $nodeXSkip
        = exists( $Opts->{nodeXSkip} )
        ? $Opts->{nodeXSkip}
        : $self->get_nodeXSkip;
    my $nodeYSkip
        = exists( $Opts->{nodeYSkip} )
        ? $Opts->{nodeYSkip}
        : $self->get_nodeYSkip;
    my ( $m, $h );
    my ( $patterns, $pattern_count, $node_pattern_count,
        $edge_pattern_count );
    {
        my $pl = $self->get_pattern_lists($fsfile);
        $patterns           = $pl->[3];
        $pattern_count      = scalar( @{$patterns} );
        $node_pattern_count = scalar( @{ $pl->[0] } );
        $edge_pattern_count = scalar( @{ $pl->[1] } );
    }

    # May change with line attached labels

    my $fontHeight = $self->getFontHeight() * $lineSpacing;

    my $xpos;
    my ( $pat_style, $pat );

    if ( exists( $Opts->{ballance} ) ) {
        print STDERR "Use 'balance' instead of misspelled 'ballance'!\n";
        $Opts->{balance} = $Opts->{ballance}
            unless ( exists( $Opts->{balance} ) );
    }
    my $balance
        = exists( $Opts->{balance} )
        ? $Opts->{balance}
        : $self->get_balanceTree;

    my $skipHiddenLevels
        = exists( $Opts->{skipHiddenLevels} )
        ? $Opts->{skipHiddenLevels}
        : $self->get_skipHiddenLevels;

    foreach $node ( @{$nodes} ) {
        $node_info->{$node}{"E"} = $node;
    }
    foreach $node ( @{$nodes} ) {
        $self->compute_level( $node, $Opts, $skipHiddenLevels );
    }
    if ($balance) {
        @{$nodes} = @{ $self->balance_node_order($nodes) };
    }

    # we reverse back to normal order in vertical mode
    my $right_to_left = $self->rightToLeft($fsfile);
    $right_to_left = $self->{reverseNodeOrder} unless defined $right_to_left;
    my $style_info = $self->{style_info};
    foreach $node ( $right_to_left ? reverse @{$nodes} : @{$nodes} ) {
        my $NI    = $node_info->{$node};
        my $style = $style_info->{$node};
        $level = $NI->{'Level'} + $style->{'Node'}{'-level'};

        $xpos = $baseXPos + $level * ( 15 + $nodeXSkip );
        $NI->{"XPOS"} = $xpos;
        my $label_xpos = $xpos + $nodeWidth + $labelsep;
        my $lines      = 0;
        if ($pattern_count) {
            ( $pat_style, $pat ) = @{ $patterns->[0] };
            ( $m, $h )
                = $self->getTextWidthAndHeight(
                $self->prepare_text( $node, $pat, $grp ) );
            $lines = $h if $lines < $h;
            if ( $pat_style eq 'node' ) {
                $NI->{"NodeLabelWidth"} = $m;

                #$gen_info->{"NodeLabelWidth[0]"}=0;
                $gen_info->{"NodeLabel_XPOS[0]"} = $label_xpos;
                $NI->{"NodeLabel_XPOS"}          = $label_xpos;    # compat
            }
            else {
                $NI->{"EdgeLabelWidth"} = $m;

                #$gen_info->{"NodeLabelWidth[0]"}=0;
                $gen_info->{"EdgeLabel_XPOS[0]"} = $label_xpos;
                $NI->{"EdgeLabel_XPOS"}          = $label_xpos;    #compat
            }
            $NI->{"NodeLabelLines"} = $lines;
            $NI->{"X[0]"}           = $m;
            $canvasWidth = max2( $canvasWidth, $label_xpos + $m );
            $NI->{"After"}  = 0;
            $NI->{"Before"} = 0;
        }
    }
    $gen_info->{"NodeLabel_XMIN"} = $canvasWidth;
    my ( $n_i, $e_i ) = ( -1, -1 );
    for ( my $i = 0; $i < $pattern_count; $i++ ) {
        my $max = 0;
        ( $pat_style, $pat ) = @{ $patterns->[$i] };
        if    ( $pat_style eq 'node' ) { $n_i++ }
        elsif ( $pat_style eq 'edge' ) { $e_i++ }
        next if $i == 0;
        my $sep = $Opts->{ 'columnsep[' . $i . ']' };
        $sep = $columnsep unless defined $sep;
        $canvasWidth += $sep;

        foreach $node ( @{$nodes} ) {
            my $NI = $node_info->{$node};
            ( $m, $h )
                = $self->getTextWidthAndHeight(
                $self->prepare_text( $node, $pat, $grp ) );
            $NI->{"NodeLabelLines"} = $h if $NI->{"NodeLabelLines"} < $h;
            $NI->{"X[$i]"} = $m;
            $max = max2( $max, $m );
        }
        if ( $pat_style eq 'node' ) {
            $gen_info->{"NodeLabel_XPOS[$n_i]"} = $canvasWidth;
            $gen_info->{"NodeLabelWidth[$n_i]"} = $max;
        }
        else {
            $gen_info->{"EdgeLabel_XPOS[$e_i]"} = $canvasWidth;
            $gen_info->{"EdgeLabelWidth[$e_i]"} = $max;
        }
        $canvasWidth += $max;
    }
    my $ypos          = $baseYPos;
    my $ymargin       = $self->get_ymargin;
    my $right_to_left = $self->rightToLeft($fsfile);
    $right_to_left = $self->{reverseNodeOrder} unless defined $right_to_left;
    foreach $node ( $right_to_left ? reverse @{$nodes} : @{$nodes} ) {
        my $NI = $node_info->{$node};
        $NI->{"YPOS"}           = $ypos;
        $NI->{"NodeLabel_YPOS"} = $ypos - $nodeHeight;
        $NI->{"EdgeLabel_YPOS"} = $ypos - $nodeHeight;
        my $levelHeight
            = max2( $nodeHeight,
            2 * $ymargin + $fontHeight * $NI->{"NodeLabelLines"} )
            + $nodeYSkip;
        $ypos += $levelHeight;
        $self->{canvasHeight} += $levelHeight;
    }
    $gen_info->{"NodeLabel_XMAX"} = $canvasWidth;
    $self->{canvasWidth} = $canvasWidth + $self->get_xmargin;
    $self->{canvasHeight} += $self->get_ymargin;
}

sub recalculate_positions {
    my ( $self, $fsfile, $nodes, $Opts, $grp ) = @_;
    return if !ref $self;
    my $node_info   = $self->{node_info};
    my $gen_info    = $self->{gen_info};
    my $baseXPos    = $Opts->{baseXPos} || $self->get_baseXPos;
    my $baseYPos    = $Opts->{baseYPos} || $self->get_baseYPos;
    my $lineSpacing = $Opts->{lineSpacing} || $self->get_lineSpacing;
    my $xpos        = $baseXPos;
    my $level;

    my $minxpos;    # used temporarily to place a node far
                    # enough from its left neighbour

    my $maxlevel;   # has different meaning from $minxpos;
                    # this one's used for canvasHeight
    my $canvasWidth = 0;
    my $node;
    my $xSkipBefore     = 0;
    my $xSkipAfter      = 0;
    my $nodeLabelXShift = 0;
    my $nodeLabelWidth  = 0;
    my $edgeLabelWidth  = 0;
    my ( $nodeWidth, $nodeHeight )
        = ( $self->get_nodeWidth, $self->get_nodeHeight );
    my $nodeXSkip
        = exists( $Opts->{nodeXSkip} )
        ? $Opts->{nodeXSkip}
        : $self->get_nodeXSkip;
    my $nodeYSkip
        = exists( $Opts->{nodeYSkip} )
        ? $Opts->{nodeYSkip}
        : $self->get_nodeYSkip;
    my ( $m, $h );

    my ( $patterns, $pattern_count, $node_pattern_count,
        $edge_pattern_count );
    {
        my $pl = $self->get_pattern_lists($fsfile);
        $patterns           = $pl->[3];
        $pattern_count      = scalar( @{$patterns} );
        $node_pattern_count = scalar( @{ $pl->[0] } );
        $edge_pattern_count = scalar( @{ $pl->[1] } );
    }

    my $fontHeight = $self->getFontHeight() * $lineSpacing;
    my $edge_label_height
        = 2 * $self->get_ymargin + $edge_pattern_count * $fontHeight;
    my $levelHeight = 0;

    if ($edge_pattern_count) {
        $levelHeight
            += $self->get_edgeLabelSkipAbove 
            + $self->get_edgeLabelSkipBelow
            + $edge_label_height;
    }

    my @prevnode   = ();
    my @zero_level = ();
    my $parent;
    my $ypos;
    $maxlevel = 0;
    my $valign_shift = 0;
    my $valign;
    my $halign_node;
    my $halign_edge;
    my $valign_edge;
    my $edge_ypos;
    my ( $pat_style, $pat );

    #   my %sameasparent;
    #   my %sameaschild;
    #   my $attr=$fsfile->FS->order;
    #   foreach my $node (@$nodes) {
    #     if ($node->parent and $node->{$attr} == $node->parent->{$attr}) {
    #       unless (exists($sameaschild{$node->parent})) {
    # 	$sameasparent{$node}=1;
    # 	$sameaschild{$node->parent}=$node;
    #       }
    #     }
    #   }
    if ( exists( $Opts->{ballance} ) ) {
        print STDERR "Use 'balance' instead of misspelled 'ballance'!\n";
        if ( !exists( $Opts->{balance} ) ) {
            $Opts->{balance} = $Opts->{ballance};
        }
    }
    my $balance
        = exists( $Opts->{balance} )
        ? $Opts->{balance}
        : $self->get_balanceTree;

    my $skipHiddenLevels
        = exists( $Opts->{skipHiddenLevels} )
        ? $Opts->{skipHiddenLevels}
        : $self->get_skipHiddenLevels;

    my $balanceOpts = [
        $balance =~ /aboveMiddleChild(Odd$|$)/i   ? 1 : 0,
        $balance =~ /aboveMiddleChild(Even$|$)?/i ? 1 : 0,
        $balance =~ /spread/i                     ? 1 : 0,
        $nodeXSkip
    ];

    foreach $node ( @{$nodes} ) {
        $node_info->{$node}{'E'} = $node;
    }
    my $style_info = $self->{style_info};
    #!!!ended here
    foreach my $node ( @{$nodes} ) {
        my $level = $self->compute_level( $node, $Opts, $skipHiddenLevels );
        if ( $maxlevel < int $level ) {
            $maxlevel = int($level);
        }

        my ( $n_nonempty, $e_nonempty );
        my $style              = $style_info->{$node};
        my $skip_empty_nlabels = $style->{'NodeLabel'}{'-skipempty'};
        my $skip_empty_elabels = $style->{'EdgeLabel'}{'-skipempty'};
        my $NI                 = ( $node_info->{$node} ||= {} );
        my ( $nodeLabelWidth, $edgeLabelWidth ) = ( 0, 0 );
        for ( my $i = 0; $i < $pattern_count; $i++ ) {
            ( $pat_style, $pat ) = @{ $patterns->[$i] };
            if ( $pat_style eq "edge" ) {

                # this does not actually make
                # the edge label not to overwrap, but helps a little
                ( $m, $h )
                    = $self->getTextWidthAndHeight(
                    $self->prepare_text( $node, $pat, $grp ) );
                $NI->{"X[$i]"} = $m;
                if ( $m > $edgeLabelWidth ) {
                    $edgeLabelWidth = $m;
                }
                if ( !$skip_empty_elabels || $m > 0 ) {
                    $e_nonempty += $h;
                }
            }
            elsif ( $pat_style eq "node" ) {
                ( $m, $h )
                    = $self->getTextWidthAndHeight(
                    $self->prepare_text( $node, $pat, $grp ) );
                $NI->{"X[$i]"} = $m;
                if ($m > $nodeLabelWidth) {
                    $nodeLabelWidth = $m;
                }
                if ( !$skip_empty_nlabels || $m > 0 ) {
                    $n_nonempty += $h;
                }
            }
        }
        $NI->{"NodeLabelWidth"}     = $nodeLabelWidth;
        $NI->{"EdgeLabelWidth"}     = $edgeLabelWidth;
        $NI->{"NodeLabel_nonempty"} = $n_nonempty;
        $NI->{"EdgeLabel_nonempty"} = $e_nonempty;

        my $h1
            = 2 * $nodeHeight 
            + $style->{Node}{'-addheight'}
            + $style->{Oval}{'-width'};
        my $h2
            = 2 * $nodeHeight 
            + $style->{CurrentNode}{'-addheight'}
            + $style->{CurrentOval}{'-width'};
        my $h = $h1 < $h2 ? $h2 : $h1;
        $gen_info->{"MaxNodeHeightOnLevel[$level]"} = $h
            if $gen_info->{"MaxNodeLabelsOnLevel[$level]"} < $h;
        $gen_info->{"MaxNodeLabelsOnLevel[$level]"} = $n_nonempty
            if $gen_info->{"MaxNodeLabelsOnLevel[$level]"} < $n_nonempty;

    }
    if ($balance) {
        @{$nodes} = @{ $self->balance_node_order($nodes) };
    }

    # now we compute he level heights

    my $ymargin = $self->get_ymargin;
    my $xmargin = $self->get_xmargin;
    {
        my $ypos = $baseYPos;
        for my $level ( 0 .. $maxlevel ) {
            my $thisLevelHeight
                = $levelHeight + $gen_info->{"MaxNodeHeightOnLevel[$level]"};
            my $node_pattern_count_on_level
                = $gen_info->{"MaxNodeLabelsOnLevel[$level]"};
            if ($node_pattern_count_on_level) {
                $thisLevelHeight
                    += $nodeYSkip 
                    + 2 * $ymargin
                    + $node_pattern_count_on_level * $fontHeight;
                $thisLevelHeight += $nodeYSkip unless ($edge_pattern_count);
            }
            else {
                $thisLevelHeight += 2 * $nodeYSkip + 2 * $ymargin;
            }
            $gen_info->{"LevelYPos[$level]"} = $ypos;
            $ypos += $thisLevelHeight;
        }
        $gen_info->{ "LevelYPos[" . ( $maxlevel + 1 ) . "]" } = $ypos;
    }
    foreach $node ( @{$nodes} ) {
        my $NI          = $node_info->{$node};
        my $style       = $style_info->{$node};
        my $node_style  = $style->{'Node'};
        my $label_style = $style->{'NodeLabel'};

        $level = $NI->{'Level'} + $node_style->{'-level'};
        $NI->{"EdgeLabelHeight"} = $edge_label_height;

        my $node_label_height
            = 2 * $ymargin + $NI->{"NodeLabel_nonempty"} * $fontHeight;

        #   my $node_label_height= $node_pattern_count*$fontHeight;
        #   if ($node_pattern_count) {
        #      $levelHeight += $nodeYSkip + $node_label_height;
        #      $levelHeight += $nodeYSkip unless ($edge_pattern_count);
        #   }
        my $thisLevelHeight = $gen_info->{"LevelHeight[$level]"};
        my $frac_level      = $level - int($level);
        $ypos
            = $frac_level == 0
            ? $gen_info->{"LevelYPos[$level]"}
            : $frac_level
            * $gen_info->{ "LevelYPos[" . int( $level + 1 ) . "]" }
            + ( 1 - $frac_level )
            * $gen_info->{ "LevelYPos[" . int($level) . "]" };
        $valign = $label_style->{'-valign'};
        if ( $valign eq 'bottom' ) {
            $valign_shift = -$nodeYSkip / 2 - $node_label_height;
            $ypos += $node_label_height;
        }
        elsif ( $valign eq 'center' ) {
            $valign_shift = -$node_label_height / 2;
            $ypos += $node_label_height / 2;
        }
        else {
            $valign_shift = $nodeYSkip / 2 + $nodeHeight;
        }
        $ypos += $node_style->{'-yadj'};
        $NI->{"YPOS"} = $ypos;
        $NI->{"NodeLabel_YPOS"}
            = $ypos + $label_style->{'-yadj'} + $valign_shift;
        if ( $valign eq 'bottom' ) {
            $edge_ypos
                = $ypos 
                + $valign_shift 
                - $self->get_edgeLabelSkipBelow
                - $edge_label_height;
        }
        else {
            $edge_ypos
                = $ypos 
                + $valign_shift 
                + $node_label_height
                + $self->get_edgeLabelSkipAbove 
                - $thisLevelHeight;
        }
        $edge_ypos += $style->{'EdgeLabel'}{'-yadj'};
        $NI->{"EdgeLabel_YPOS"} = $edge_ypos;

        $halign_edge = $style->{'EdgeLabel'}{'-halign'};

        ( $nodeLabelWidth, $edgeLabelWidth )
            = ( $NI->{"NodeLabelWidth"}, $NI->{"EdgeLabelWidth"} );

        $halign_node = $label_style->{'-halign'};

        if ( $node_style->{'-surroundtext'} ) {
            my $nw = $xmargin + $nodeLabelWidth / 2;
            my $addw = ( $node_style->{'-addwidth'} || 0 );
            if ( $node_style->{'-shape'} eq 'oval' ) {
                my $nh = $node_label_height / 2;
                my $addh = ( $node_style->{'-addheight'} || 0 );

                # here we compute the ellipse axes $A,$B from its semi-latus
                # rectum $L and the distance of its foci $C corresponding
                # to text-box width/height or or vice-versa, whichever is less
                my ( $A, $B, $L, $C );
                if ( $nw <= $nh ) {
                    ( $L, $C ) = ( $nw, $nh );
                }
                else {
                    ( $C, $L ) = ( $nw, $nh );
                }
                $A = ( $L + sqrt( $L * $L + 4 * $C * $C ) ) / 2;
                $B = sqrt( $L * $A );
                ( $B, $A ) = ( $A, $B ) if ( $nw <= $nh );
                $addw += ( $NI->{"NodeSurroundWidth"} = ( $A - $nw ) );
                $NI->{"NodeSurroundHeight"} = $B - $nh;
            }
            if ( $halign_node eq 'right' ) {
                $xSkipAfter      = $addw;
                $xSkipBefore     = 2 * $nw + $addw;
                $nodeLabelXShift = -$nodeLabelWidth;
            }
            elsif ( $halign_node eq 'center' ) {
                $xSkipAfter = ( $xSkipBefore = $nw + $addw );
                $nodeLabelXShift = -$nodeLabelWidth / 2;
            }
            else {
                $xSkipAfter      = 2 * $nw + $addw;
                $xSkipBefore     = $addw;
                $nodeLabelXShift = 0;
            }
        }
        else {
            my $nw = $nodeWidth / 2 + ( $node_style->{'-addwidth'} || 0 );
            $xSkipBefore = $nw;
            $xSkipAfter  = $nw;
            if ( $halign_node eq 'right' ) {
                $xSkipBefore = max2( $xSkipBefore, $nodeLabelWidth - $nw );
                $nodeLabelXShift = -$nodeLabelWidth + $nw;
            }
            elsif ( $halign_node eq 'center' ) {
                $xSkipBefore = max2( $xSkipBefore, $nodeLabelWidth / 2 );
                $xSkipAfter  = max2( $xSkipAfter,  $nodeLabelWidth / 2 );
                $nodeLabelXShift = -$nodeLabelWidth / 2;
            }
            else {
                $xSkipAfter = max2( $xSkipAfter, $nodeLabelWidth - $nw );
                $nodeLabelXShift = -$nw;
            }
        }
        $nodeLabelXShift += $label_style->{'-xadj'};

        # Try to add reasonable skip so that the edge labels do
        # not overlap. (this code however cannot ensure that!!)
        if (    $self->get_useAdditionalEdgeLabelSkip()
            and $node_style->{'-disableedgelabelspace'} ne "yes" )
        {
            if ( $halign_edge eq 'right' ) {
                $xSkipBefore = max2( $xSkipBefore, 2 * $edgeLabelWidth );
            }
            elsif ( $halign_edge eq 'center' ) {
                $xSkipBefore = max2( $xSkipBefore, $edgeLabelWidth );
                $xSkipAfter  = max2( $xSkipAfter,  $edgeLabelWidth );
            }
            else {
                $xSkipAfter = max2( $xSkipAfter, 2 * $edgeLabelWidth );
            }
        }
        else {
            if ( $halign_edge eq 'right' ) {
                $xSkipBefore = max2( $xSkipBefore, $edgeLabelWidth );
            }
            elsif ( $halign_edge eq 'center' ) {
                $xSkipBefore = max2( $xSkipBefore, $edgeLabelWidth / 2 );
                $xSkipAfter  = max2( $xSkipAfter,  $edgeLabelWidth / 2 );
            }
            else {
                $xSkipAfter = max2( $xSkipAfter, $edgeLabelWidth );
            }
        }
        $xSkipBefore += $node_style->{'-addbeforeskip'};
        $xSkipAfter  += $node_style->{'-addafterskip'};

        $NI->{"After"}  = $xSkipAfter;
        $NI->{"Before"} = $xSkipBefore;
        if ( $node_style->{'-xbreak'} ) {
            $xpos = $baseXPos;
        }
        if ($balance) {

            #$xSkipBefore+
            $xpos = $node_style->{'-extrabeforeskip'};
        }
        else {
            $minxpos = 0;
            if ( $prevnode[$level] ) {
                $minxpos
                    = $node_info->{ $prevnode[$level] }{"XPOS_noadj"}
                    + $node_info->{ $prevnode[$level] }{"After"}
                    + $xSkipBefore;
            }
            else {
                $minxpos = $baseXPos + $xSkipBefore;
            }
            $xpos = $minxpos if $minxpos > $xpos;
            $xpos += $nodeXSkip + $node_style->{'-extrabeforeskip'};
            $prevnode[$level] = $node;
        }
        my $xadj = $node_style->{'-xadj'};
        $NI->{"XPOS_noadj"}     = $xpos;
        $NI->{"XPOS"}           = $xpos + $xadj;
        $NI->{"NodeLabel_XPOS"} = $xpos + $xadj + $nodeLabelXShift;

        $canvasWidth = max2( $canvasWidth,
                  $xpos 
                + $xadj 
                + $xSkipAfter 
                + $nodeWidth 
                + 2 * $xmargin
                + $baseXPos );
        push @zero_level, $node if ( $level == 0 );
    }

    if ($balance) {
        my $baseX = $baseXPos;
        foreach my $c (@zero_level) {
            $baseX = $self->balance_node( 0, [ map $baseX, 0 .. $maxlevel ],
                $c, $balanceOpts );
        }
        foreach my $c (@zero_level) {
            $self->balance_xfix_node( 0, $c );
        }
        $canvasWidth = $baseX;
    }
    $self->{canvasWidth} = $canvasWidth;
    $self->{canvasHeight}
        = $baseYPos 
        + $gen_info->{ "LevelYPos[" . ( $maxlevel + 1 ) . "]" }
        + $ymargin;
}

sub which_text_color {
    my ( $self, $fsfile, $arg ) = @_;
    return if !$fsfile;
    return $self->get_textColor unless ( $self->get_highlightAttributes );

    my $color = $fsfile->FS->color($arg);
    return ( $color =~ /^(?:Shadow|Hilite|XHilite)$/ )
        ? $self->{ "textColor" . $color }
        : $self->get_textColor;
}

sub node_box_options {
    my ( $self, $node, $fs, $currentNode, $edge ) = @_;
    my $fill;
    if ($edge) {
        $fill
            = ( $currentNode == $node ) ? $self->get_currentEdgeBoxColor
            : (
              $fs->isHidden($node) ? $self->get_hiddenEdgeBoxColor
            : $self->get_edgeBoxColor
            );
    }
    else {
        $fill
            = ( $currentNode == $node ) ? $self->get_currentBoxColor
            : (
              $fs->isHidden($node) ? $self->get_hiddenBoxColor
            : $self->get_boxColor
            );
    }
    return (
        -width         => 1,
        -activewidth   => 1,
        -outline       => 'black',
        -activeoutline => 'black',
        -fill          => $fill,
        -activefill    => $fill,
    );
}

sub node_coords {
    my ( $self, $node, $currentNode ) = @_;
    my $factor = $self->scale_factor;
    my $NI     = $self->{node_info}{$node};
    my $x      = $NI->{'XPOS'};
    my $y      = $NI->{'YPOS'};

    my $Opts = $self->get_gen_pinfo('Opts');
    my @ret;
    my $node_style = $self->{style_info}{$node}{Node};
    my $shape      = $node_style->{'-shape'};
    if ( $shape ne 'polygon' ) {
        my ( $nw, $nh );
        if ( $node_style->{'-surroundtext'} and $NI->{"TextBoxCoords"} ) {
            @ret = @{ $NI->{"TextBoxCoords"} };
            my $addw = $NI->{"NodeSurroundWidth"};
            my $addh = $NI->{"NodeSurroundHeight"};
            @ret = (
                $ret[0] - $addw,
                $ret[1] - $addh,
                $ret[2] + $addw,
                $ret[3] + $addh
            );
        }
        else {
            if ( $currentNode eq $node ) {
                $nw = $node_style->{'-currentwidth'};
                $nh = $node_style->{'-currentheight'};
                $nw = $node_style->{'-width'} unless defined $nw;
                $nh = $node_style->{'-height'} unless defined $nh;
                $nw = $self->get_currentNodeWidth unless defined $nw;
                $nh = $self->get_currentNodeHeight unless defined $nh;
            }
            else {
                $nw = $node_style->{'-width'};
                $nh = $node_style->{'-height'};
                $nw = $self->get_nodeWidth unless defined $nw;
                $nh = $self->get_nodeHeight unless defined $nh;
            }
            $nw += $node_style->{'-addwidth'};
            $nh += $node_style->{'-addheight'};
            @ret = ( $x - $nw / 2, $y - $nh / 2, $x + $nw / 2, $y + $nh / 2 );
        }
    }
    else {
        my $horiz = 0;
        @ret = map { $horiz = !$horiz; $_ + ( $horiz ? $x : $y ) }
            split( ',', $node_style->{'-polygon'} );
    }
    return $factor != 1 ? ( map { $factor * $_ } @ret ) : @ret;
}

sub node_options {
    my ( $self, $node, $fs, $current_node ) = @_;
    return (
        -outline => $self->get_nodeOutlineColor,
        -width   => 1,
        -fill    => ( $current_node == $node ) ? $self->get_currentNodeColor
        : (   $fs->isHidden($node) ? $self->get_hiddenNodeColor
            : $self->get_nodeColor
        ),
    );
}

sub line_options {
    my ( $self, $node, $fs, $can_dash ) = @_;
    my $dash = $self->get_lineDash;
    if ( $fs->isHidden($node) ) {
        return (
            -fill => $self->get_hiddenLineColor,
            (   $can_dash
                ? ( $self->get_dashHiddenLines
                    ? ( '-dash' => '-' )
                    : ( defined $dash ? ( -dash => $dash ) : () )
                    )
                : ()
            )
        );
    }
    else {
        return (
            -fill => $self->get_lineColor,
            defined($dash) ? ( -dash => $self->get_lineDash ) : ()
        );
    }
}

sub wrappedLines {
    my ( $self, $text, $width ) = @_;
    use integer;
    my $spacew = $self->getTextWidth(" ");
    my @toks   = map { $self->getTextWidth($_) } split /\s+/, $text;
    my $wd     = shift @toks;
    my $lines  = 1;
    foreach (@toks) {
        if ( $wd + $spacew + $_ < $width ) { $wd += $spacew + $_; }
        else                               { $wd = $_; $lines++; }
    }
    return $lines;
}

sub wrapLines {
    my ( $self, $text, $width, $reverse ) = @_;
    use integer;

    # split on whitespace but preserve newlines as individual tokens
    my @toks = grep defined, split /[ \t]*(\n)[ \t]*|[ \t]+/, $text;
    if ($reverse) {
        my @result;
        my $wd = 0;
        my $w;
        my $t     = pop(@toks);
        my @lines = ();
        while ($t) {
            if ( $t eq "\n" ) {
                push @lines, join( ' ', @result );
                @result = ();
                $wd     = 0;
            }
            else {
                $w = $self->getTextWidth( ' ' . $t );
                if ( ( $wd + $w >= $width ) && ( @result > 0 ) ) {
                    push @lines, join( ' ', @result );
                    @result = ($t);
                    $wd     = $self->getTextWidth($t);
                }
                else {
                    $wd += $w;
                    unshift @result, $t;
                }
            }
            $t = pop(@toks);
        }
        push @lines, join( ' ', @result );
        return \@lines;
    }
    else {
        my $line  = shift @toks;
        my @lines = ();
        my $wd;
        if ( $line eq "\n" ) {
            push @lines, '';
            $wd = 0;
        }
        else {
            $wd = $self->getTextWidth($line);
        }
        my $w;
        foreach (@toks) {
            if ( $_ eq "\n" ) {
                push @lines, $line;
                $wd   = 0;
                $line = '';
            }
            else {
                my $s = length($line) ? " $_" : "$_";
                $w = $self->getTextWidth($s);
                if ( $wd + $w < $width ) {
                    $wd += $w;
                    $line .= $s;
                }
                else {
                    $wd = $self->getTextWidth("$_");
                    push @lines, $line;
                    $line = $_;
                }
            }
        }
        return [ @lines, $line ];
    }
}

sub get_style_opt {
    my ( $self, $node, $style, $opt, $opts ) = @_;
    my $styles = $self->{style_info}->{$node}{$style};
    if ( ref($styles) and exists $styles->{$opt} ) {
        return $styles->{$opt};
    }
    else {
        return;
    }
}

sub apply_style_opts {
    my ( $self, $item ) = ( shift, shift );
    eval { $self->realcanvas->itemconfigure( $item, @_ ); };
    print STDERR $@ if $@;
    return $@;
}

sub apply_stored_style_opts {
    my ( $self, $item, $node ) = @_;
    my $what = $item;
    $what =~ s/^Current//;
    eval {
        $self->realcanvas->itemconfigure( $self->{node_info}{$node}{$what},
            %{ $self->{style_info}{$node}{$item} || {} } );
    };
    print STDERR $@ if $@ ne "";
    return $@;
}

sub get_node_style {
    my ( $self, $node, $style ) = @_;
    my $s = $self->{style_info}{$node}{$style};
    return $s ? %{$s} : ();
}

sub parse_coords_spec {
    my ( $self, $node, $coords, $nodes, $nodehash, $grp_ctxt ) = @_;

    # perl inline search
    no strict 'refs';
    my $node_info = $self->{node_info};
    my @save = ( ${'TredMacro::this'}, ${'TredMacro::grp'} );

    $coords =~ s{([xy])\[\?((?:.|\n)*?)\?\]}{
      my $i=0;
      my $key="[?${2}?]";
      my $xy=$1;
      my $code=$2;
      if (exists($nodehash->{"$xy$key"})) {
	int($nodehash->{"$xy$key"})
      } else {
	my $cached = $COORD_CODE_CACHE{$key};
	unless (defined $cached) {
	  $code =~s[\$\{([-_A-Za-z0-9/]+)\}][ \$node->attr('$1') ]g;
	  $cached = $COORD_CODE_CACHE{$key}=
	    eval "package TredMacro; sub{ my \$node=\$_[0]; eval { $code } }";
	}
	(${'TredMacro::this'},${'TredMacro::grp'})=($node,$grp_ctxt);
	while ($i<@$nodes) {
	  last if ($cached->($nodes->[$i]));
	  print STDERR $@ if $@ ne "";
	  $i++;
	}
	if ($i<@$nodes) {
	  $nodehash->{"x$key"} = $node_info->{$nodes->[$i]}{"XPOS"};
	  $nodehash->{"y$key"} = $node_info->{$nodes->[$i]}{"YPOS"};
	  int($nodehash->{"$xy$key"})
	} else {
	  #	    print STDERR "NOT-FOUND $code\n";
	  "ERR";
	}
      }
    }ge;
    $coords =~ s{([xy])\[!((?:.|\n)*?)!\]}{
      my $i=0;
      my $key="[!${2}!]";
      my $xy=$1;
      my $code=$2;
      if (exists($nodehash->{"$xy$key"})) {
    int($nodehash->{"$xy$key"})
      } else {
    my $c=$code;
    my $that;
    my $cached = $COORD_CODE_CACHE{$key};
    unless (defined $cached) {
        $code =~s[\$\{([-_A-Za-z0-9/]+)\}][ \$node->attr('$1') ]g;
	  $cached = $COORD_CODE_CACHE{$key}=
	    eval "package TredMacro; sub{ my \$node=\$_[0]; eval { $code } }";
	}
	(${'TredMacro::this'},${'TredMacro::grp'})=($node,$grp_ctxt);
	$that = $cached->($node);
	print STDERR "Error in coords: $code\n".$@ if $@ ne "";
	if (ref($that)) {
	  $nodehash->{"x$key"}=
	    $node_info->{$that}{ "XPOS"};
	  $nodehash->{"y$key"}=
	    $node_info->{$that}{ "YPOS"};
	  int($nodehash->{"$xy$key"})
	} else {
	  #	    print STDERR "NOT-FOUND $code\n";
	  "ERR"
	}
      }
    }ge;
    ( ${'TredMacro::this'}, ${'TredMacro::grp'} ) = @save;    #

    # simple comparison inline
    $coords =~ s{(([xy])\[([-_A-Za-z0-9]+)\s*=\s*((?:[^\]\\]|\\.)+)\])}{
      my $i=0;
      if (exists($nodehash->{$1})) {
	$i=$nodehash->{$1};
      } else {
	$i++ while ($i<@$nodes and
		    !(exists($nodes->[$i]{$3}) and $nodes->[$i]{$3} eq $4));
	$nodehash->{$1}=$i;
      }
      if ($i<@$nodes) {
	int($node_info->{$nodes->[$i]}{($2 eq 'x' ? "XPOS" : "YPOS")})
      } else {
	"ERR"
      }
    }ge;
    return $coords;
}

sub sgn { $_[0] < 0 ? -1 : $_[0] == 0 ? 0 : 1 }

{
    my ( $HAVE_PARENT, $XP, $YP, $XN, $YN )
        ;    # persistent variables for precompiled subs

    sub eval_coords_spec {
        my ( $self, $node, $parent, $c ) = @_;
        my $node_info = $self->{node_info};
        $HAVE_PARENT = $parent ? 1 : 0;
        $XP = $HAVE_PARENT ? int( $node_info->{$parent}{"XPOS"} ) : undef;
        $YP = $HAVE_PARENT ? int( $node_info->{$parent}{"YPOS"} ) : undef;
        $XN = int( $node_info->{$node}{"XPOS"} );
        $YN = int( $node_info->{$node}{"YPOS"} );
        my $key    = $c;
        my $cached = $COORD_SPEC_CACHE{$key};

        if ( defined $cached ) {
            return ( $cached->() );
        }
        else {
            $c =~ s{([xy][np])}{ \U\$$1 }g;
            if ( $c =~ /(?<![a-z])[np]/ ) {
                my $x = 0;
                my $cc;
                $c = join ',', map {
                    $x  = !$x;
                    $cc = $_;
                    if ($x) {
                        $cc =~ s{(?<![a-z])([np])}{ \$X\U$1 }g;
                    }
                    else {
                        $cc =~ s{(?<![a-z])([np])}{ \$Y\U$1 }g;
                    }
                    $cc
                } split /,/, $c;
            }
            if ( $c
                =~ /^(?:,|sqrt\(|abs\(|sgn\(| \$[XY]N | \$[XY](P) |[-\s+\?:.\/*%\(\)0-9]|&&|\|\||!|\>|\<(?!>)|==|\>=|\<=)*$/
                )
            {
                if ($1) {
                    $cached = $COORD_SPEC_CACHE{$key}
                        = eval "sub{ \$HAVE_PARENT ? ( $c ) : () }";
                }
                else {
                    $cached = $COORD_SPEC_CACHE{$key} = eval "sub{ ( $c ) }";
                }
                if ( length($@) ) {
                    print STDERR $@;
                    return;
                }
                return ( $cached->() );
            }
            else {    # catches ERR too
                print STDERR (
                    "TreeView: ERROR IN COORD SPEC: $c for node $node\n");
                return;
            }
        }
    }
}

sub callback {
    my $func = shift;
    if ( ref $func eq 'ARRAY' ) {
        &{ $func->[0] }( @_, @{$func}[ 1 .. $#$func ] );
    }
    elsif ( ref $func eq 'CODE' ) {
        &$func(@_);
    }
    else {
        return ();
    }
}

sub convert_dash {
    my ( $self, $dash, $width ) = @_;

    if ( $dash =~ /\d\s*,/ ) {
        return [ split /,/, $dash ];
    }
    elsif ( $dash !~ /\d/ ) {
        my $w = $width || $self->get_lineWidth || 1;

# manually transform the dash (we do this because itemcget -dash returns garbage and we need a correct value for printing
        my @out = ();
        for ( split '', $dash ) {
            if ( $_ eq '.' ) {
                push @out, $w, 2 * $w;
            }
            elsif ( $_ eq ',' ) {
                push @out, 2 * $w, 2 * $w;
            }
            elsif ( $_ eq '-' ) {
                push @out, 3 * $w, 2 * $w;
            }
            elsif ( $_ eq '_' ) {
                push @out, 4 * $w, 2 * $w;
            }
            elsif ( $_ eq ' ' and @out ) {
                $out[-1] += $w;
            }
        }
        return \@out;
    }
    else {
        return '';
    }
}

sub _tk_can_dash {
    my $tk_version = $Tk::VERSION;
    $tk_version =~ s/^v//;
    my ($major, $minor) = split /[^0-9]/, $tk_version;
    $minor //= 0;
    $minor =~ s/^(0.)$/$1\Q0/;
    return ($major > 800
            or $major == 800 && $minor >= 22);
}

sub redraw {
    my ( $self, $fsfile, $currentNode, $nodes, $valtext, $stipple, $grp )
        = @_;

    #  local $SIG{__DIE__} = sub { Carp::confess(@_) };
    my $node;
    my $style;
    my $parent;
    my $node_has_box;
    my $edge_has_box;
    my $bg;
    my ($x_edge_delta,   $x_edge_length,   $y_edge_length,
        $edgeLabelWidth, $edgeLabelHeight, $halign_edge,
        $valign_edge
    );

    my $scale = $self->{scale};
    $self->reset_scale; #these are refs to arrays of patterns
    my ($node_patterns, $edge_patterns, $style_patterns,
        $patterns,      $label_patterns
    ) = @{ $self->get_pattern_lists($fsfile) };

    my %Opts      = ();
    my %RootStyle = ();
    while ( my ( $k, $v ) = each %DefaultNodeStyle ) {
        $RootStyle{$k} = {@$v};
    }
    my %arrow_hints;
    my $canvas = $self->realcanvas;

    $self->clear_pinfo();
    my $node_info = $self->{node_info};
    my $gen_info  = $self->{gen_info};
    $gen_info->{"Opts"} = \%RootStyle;

    #------------------------------------------------------------
    #{
    #use Benchmark;
    #my $t0= new Benchmark;
    #for (my $i=0;$i<=50;$i++) {
    #------------------------------------------------------------
    my $pstyle;
    $node = $nodes->[0];
    if ($node) {
        $node = $node->root;
        # add option from stylesheet to rootstyle or opts
        # only for root node if any
        foreach my $style ( $self->get_label_patterns( $fsfile, "rootstyle" ) ) {
            foreach ( $self->interpolate_text_field( $node, $style, $grp )
                =~ /\#${block}/g )
            {
                if (/^(Oval|CurrentOval|TextBox|EdgeTextBox|CurrentTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node|Label)((?:\[[^\]]+\])*)(-.+?):'?(.+)'?$/
                    )
                {
                    $RootStyle{"$1$2"}{$3} = $4;
                }
                elsif (/^(.*?):(.*)$/) {
                    $Opts{$1} = $2;
                }
                else {
                    $Opts{$_} = 1;
                }
            }
        }

        # root styling hook
        callback( $on_get_root_style, $self, $node, \%RootStyle, \%Opts )
            if $on_get_root_style;
    }

    # styling patterns should be interpolated here for each node and
    # the results stored within node_pinfo
    my $filter_nodes  = 0;
    my $segment_nodes = 0;
    my %skip_nodes;
    my %segment;

    my $style_info = ( $self->{style_info} ||= {} );
    my $k = 0;
    foreach $node ( @{$nodes} ) {
        my ( $k, $val );
        my %NodeStyle;
        while ( my ( $k, $val ) = each %RootStyle ) {
            $NodeStyle{$k} = {%{$val}};
        }
        foreach $style (@{$style_patterns}) {
            foreach ( $self->interpolate_text_field( $node, $style, $grp )
                =~ /\#${block}/g )
            {
                if (/^((CurrentOval|Oval|CurrentTextBox|TextBox|EdgeTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node|Label)((?:\[[^\]]+\])*)(-[^:]+?)):(.+)$/
                    )
                {
                    $NodeStyle{"$2$3"}{$4} = $5;
                    if ( $1 eq 'Node-hide' ) {
                        $skip_nodes{$node} = $5;
                        $filter_nodes = 1;
                    }
                }
            }
        }

        # external styling hook
        callback( $on_get_node_style, $self, $node, \%NodeStyle );
        $style_info->{$node} = \%NodeStyle;
    }
    if ( $filter_nodes and !$self->get_showHidden() ) {

        # $nodes = [ grep { !$skip_nodes{$_} } @$nodes ];

        # CAUTION: this change propagates up to the caller
        @{$nodes} = grep { !$skip_nodes{$_} } @{$nodes};
    }
    my (@segments);
    for my $node (@{$nodes}) {
        my $segment = $style_info->{$node}{Node}{'-segment'};
        if ( !defined $segment || !length $segment ) {
            $segment = '0/0';
        }
        my ( $i, $j ) = split( q{/}, $segment, 2 );
        push @{ $segments[$i][$j] }, $node;
    }

    if ( defined $self->get_backgroundColor ) {
        $canvas->configure( -background => $self->get_backgroundColor );
    }
    # delete all items on canvas except for bgimage
    $canvas->addtag( 'delete', 'all' );
    if ( $canvas->find( 'withtag', 'bgimage' ) ) {
        $canvas->dtag( 'bgimage', 'delete' ); # delete tag delete from bgimage
    }
    $canvas->delete('delete'); # delete all the items with tag delete

    my $vertical_tree = $self->set_verticalTree(
          $self->get_displayMode ? ( ( $self->get_displayMode + 1 ) / 2 )
        : exists( $Opts{vertical} ) ? $Opts{vertical}
        : 0
    );

    my $lineSpacing = $Opts{lineSpacing} || $self->get_lineSpacing;

    my $lineHeight = $self->getFontHeight() * $lineSpacing;
    my $edge_label_yskip
        = ( scalar(@{$node_patterns}) ? $self->get_edgeLabelSkipAbove : 0 );

    my $can_dash = _tk_can_dash();

    my $skipHiddenLevels = $Opts{skipHiddenLevels}
        || $self->get_skipHiddenLevels;
    my $skipHiddenParents 
        = $skipHiddenLevels
        || $Opts{skipHiddenParents}
        || $self->get_skipHiddenParents;
    my $ymargin       = $self->get_ymargin;
    my $xmargin       = $self->get_xmargin;
    my $drawBoxes     = $self->get_drawBoxes;
    my $drawEdgeBoxes = $self->get_drawEdgeBoxes;
    my $right_to_left = $self->rightToLeft($fsfile);
    if ( !defined $right_to_left ) {
        $right_to_left = $self->{reverseNodeOrder};
    }

    my ( $baseXPos, $baseYPos ) = (
        $Opts{baseXPos} || $self->get_baseXPos,
        $Opts{baseYPos} || $self->get_baseYPos
    );
    for my $seg_i ( 0 .. $#segments ) {
        for my $seg_j ( 0 .. $#{ $segments[$seg_i] } ) {
            $canvas->addtag( 'seg:prev', 'all' );
            $nodes = $segments[$seg_i][$seg_j];
            next if (!ref $nodes || !@{$nodes});

            #------------------------------------------------------------
            #}
            #my $t1= new Benchmark;
            #my $td= timediff($t1, $t0);
            #print "Applying styles the code took:",timestr($td),"\n";
            #}
            #------------------------------------------------------------

            if ($vertical_tree) {
                recalculate_positions_vert( $self, $fsfile, $nodes, \%Opts,
                    $grp );
            }
            else {
                recalculate_positions( $self, $fsfile, $nodes, \%Opts, $grp );
            }

            #------------------------------------------------------------
            #{
            #use Benchmark;
            #my $t0= new Benchmark;
            #for (my $i=0;$i<=50;$i++) {
            #------------------------------------------------------------

            #------------------------------------------------------------
            #}
            #my $t1= new Benchmark;
            #my $td= timediff($t1, $t0);
            #print "recalculate_positions: the code took:",timestr($td),"\n";
            #}
            #------------------------------------------------------------

            $gen_info->{'lastX'} = 0;
            $gen_info->{'lastY'} = 0;

            foreach $node ( @{$nodes} ) {
                my $NI = $node_info->{$node};
                $parent = $NI->{"P"};

#     if ($skipHiddenParents) {
#       $parent = $node->parent;
#       $parent=$parent->parent while ($parent and !$node_info->{$parent}{"E"});
#     } else {
#       $parent=$node->parent;
#     }
                use integer;

                my $style = $style_info->{$node};
                ## Lines ##
                my $line_style = $style->{'Line'};
                my @tag        = split '&', $line_style->{'-tag'};
                my @arrow      = split '&', $line_style->{'-arrow'};
                my @arrowshape = map {
                    $_ =~ /^(\d+),(\d+),(\d+)$/
                        ? [ split /,/ ]
                        : undef
                    }
                    split '&', $line_style->{'-arrowshape'};
                my @fill  = split '&', $line_style->{'-fill'};
                my @width = split '&', $line_style->{'-width'};
                my @hints = split '&', $line_style->{'-hint'};
                my @dash;

                for my $d ( split '&', $line_style->{'-dash'} ) {
                    push @dash,
                        $self->convert_dash( $d, $width[ 1 + $#dash ] );
                }

                my @smooth = split '&', $line_style->{'-smooth'};
                my @obj    = split '&', $line_style->{'-decoration'};
                my %nodehash;
                my $coords = $line_style->{'-coords'};
                $coords = $self->parse_coords_spec( $node, $coords, $nodes,
                    \%nodehash, $grp );
                my @coords = split '&', $coords;
                my $lin = -1;
            COORD: foreach my $c (@coords) {

                    #my @c=split ',',$c;
                    my @c = $self->eval_coords_spec( $node, $parent, $c );
                    $lin++;
                    next unless @c;

                    #      $objectno++;
                    #      my $line="line_$objectno";
                    my $l;
                    my $arrow_shape = $arrowshape[$lin]
                        || $self->get_lineArrowShape;
                    my @opts = (
                        $self->line_options( $node, $fsfile->FS, $can_dash ),
                        -tags => [
                            'line', 'scale_width',
                            'scale_arrow', split( /,/, $tag[$lin] )
                        ],
                        -arrow => $arrow[$lin] || $self->get_lineArrow,
                        (   defined($arrow_shape)
                            ? ( -arrowshape => $arrow_shape )
                            : ()
                        ),
                        -width => $width[$lin] || $self->get_lineWidth,
                        ( $fill[$lin] ? ( '-fill' => $fill[$lin] ) : () ),
                        (     ( $dash[$lin] && $can_dash )
                            ? ( '-dash' => $dash[$lin] )
                            : ()
                        ),
                    );
                    eval {
                        if ( $obj[$lin] )
                        {

         #
         # Line-decoration:...&step=4%;shape=rectangle;coords=<coords>;tag=...
         #                |..another decoration
         #
                            my $spline
                                = $smooth[$lin]
                                ? TkMakeBezierCurve( \@c, 12,
                                ( $arrow[$lin] && $arrow[$lin] ne 'none' ) )
                                : \@c;
                            my @L = (0);    # length to n'th point of $spline
                            my ( $dx, $dy );
                            for my $i ( 1 .. ( @$spline / 2 - 1 ) ) {
                                no integer;
                                $dx = $spline->[ 2 * $i ]
                                    - $spline->[ 2 * ( $i - 1 ) ];
                                $dy = $spline->[ 2 * $i + 1 ]
                                    - $spline->[ 2 * ( $i - 1 ) + 1 ];
                                $L[$i] = $L[ $i - 1 ]
                                    + sqrt( $dx * $dx + $dy * $dy );
                            }
                            for my $obj ( split /\|/, $obj[$lin] ) {
                                my %obj_spec = split /[=;]/, $obj;
                                my @obj_coords = split /,/,
                                    delete $obj_spec{coords};

                                # my $seg = delete $obj_spec{line_segment};
                                my $step  = delete $obj_spec{step};
                                my $force = delete $obj_spec{force};
                                my $start = delete( $obj_spec{start} ) || 0;
                                my $stop  = delete( $obj_spec{stop} )
                                    || '100%';
                                my $repeat = delete( $obj_spec{repeat} ) || 1;
                                my $rotate = delete( $obj_spec{rotate} );
                                my $shape = delete $obj_spec{shape} || 'oval';
                                {
                                    no integer;
                                    for ( $start, $step, $stop, $force ) {
                                        if (defined) {
                                            if (s/%\s*$//) {
                                                $_ = $L[-1] * ( $_ / 100 );
                                            }
                                            $_ += $L[-1] if $_ < 0;
                                        }
                                    }
                                }

                                my $d   = $start;
                                my $tag = delete( $obj_spec{tag} );
                                $tag = [ split /,/, $tag ] if $tag;
                                my $j = 0;
                                if ( $d > $stop and $force ) {
                                    $d      = $force;
                                    $repeat = 1;
                                    $stop   = $L[-1];
                                }

                                while ( $repeat > 0 and $d <= $stop ) {

                                    $j++ while ( $j < $#L and $L[$j] < $d );

                                    my ( $x, $y, $rx, $ry );
                                    if ( $j == 0 ) {
                                        ( $x, $y )
                                            = @$spline[ 2 * $j, 2 * $j + 1 ];
                                        if ($rotate) {
                                            no integer;
                                            my $rl = $L[ $j + 1 ] - $L[$j];
                                            my $r  = $d - $L[$j];
                                            ( $rx, $ry ) = (
                                                (   $spline->[ 2 * $j + 2 ]
                                                        - $spline->[ 2 * $j ]
                                                ) / $rl,
                                                (   $spline->[ 2 * $j + 3 ]
                                                        - $spline->[ 2 * $j
                                                        + 1 ]
                                                    ) / $rl
                                            );
                                        }
                                    }
                                    else {
                                        no integer;
                                        my $rl = ( $L[$j] - $L[ $j - 1 ] )
                                            || 1;
                                        my $r = $d - $L[ $j - 1 ];
                                        ( $rx, $ry ) = (
                                            (         $spline->[ 2 * $j ]
                                                    - $spline->[ 2 * $j - 2 ]
                                            ) / $rl,
                                            (         $spline->[ 2 * $j + 1 ]
                                                    - $spline->[ 2 * $j - 1 ]
                                                ) / $rl
                                        );
                                        ( $x, $y ) = (
                                            $spline->[ 2 * $j - 2 ]
                                                + $r * $rx,
                                            $spline->[ 2 * $j - 1 ] + $r * $ry
                                        );
                                    }

                                    {
                                        no integer;
                                        my $i = 0;
                                        my @canvas_obj = (
                                            $shape,
                                            (   (           $rotate
                                                        and @obj_coords >= 4
                                                )
                                                ? ( map {
                                                        (   int($x + (
                                                                          $rx
                                                                        * $obj_coords
                                                                        [
                                                                        2 * $_
                                                                        ] -
                                                                        $ry
                                                                        * $obj_coords
                                                                        [
                                                                        2 * $_
                                                                        + 1
                                                                        ]
                                                                )
                                                            ),
                                                            int($y + (
                                                                          $rx
                                                                        * $obj_coords
                                                                        [
                                                                        2 * $_
                                                                        + 1
                                                                        ] +
                                                                        $ry
                                                                        * $obj_coords
                                                                        [
                                                                        2 * $_
                                                                        ]
                                                                )
                                                            )
                                                            )
                                                        } (
                                                        0 .. int(
                                                            @obj_coords / 2
                                                                - 1
                                                        )
                                                        )
                                                    )
                                                : ( map( int(
                                                            (   $i = (
                                                                    $i + 1
                                                                    ) % 2
                                                            ) ? $_ + $x
                                                            : $_ + $y
                                                        ),
                                                        @obj_coords )
                                                )
                                            ),
                                            -tags => $tag,
                                            exists $obj_spec{dash}
                                                ? ( -dash => $self->convert_dash(
                                                    delete $obj_spec{dash},
                                                    $obj_spec{width} ))
                                                : (),
                                            map(( '-' . $_ => $obj_spec{$_} ),
                                                keys %obj_spec )
                                        );
                                        $canvas->create(@canvas_obj);
                                    }
                                    last unless $repeat;
                                    $d += $step;
                                    last if $d > $stop;
                                    $repeat--;
                                }
                            }
                            $l = $canvas->createLine( @$spline, @opts,
                                -smooth => 0 );
                        }
                        else {
                            $l = $canvas->createLine( @c, @opts,
                                '-smooth' => ( $smooth[$lin] || 0 ) );
                        }
                    };
                    if ($@) {
                        use Data::Dumper;
                        print STDERR "createLine: ",
                            Data::Dumper->new( [ \@c, \@opts ],
                            [ 'coords', 'opts' ] )->Dump;
                        print STDERR $@ . "\n";
                    }
                    else {

                        # $self->store_id_pinfo($l,$line);
                        $NI->{"Line$lin"} = $l;
                        $self->store_obj_pinfo( $l, $node );
                        $gen_info->{tag}{$l} = $tag[$lin];
                        $canvas->lower( $l, 'all' );
                        $canvas->raise( $l, 'line' );
                        if ( exists( $hints[$lin] )
                            and length( $hints[$lin] ) )
                        {
                            $arrow_hints{$l} = $hints[$lin];
                        }
                    }
                }

                undef %nodehash;

                ## Node Shape ##
                my $node_style  = $style->{'Node'};
                my $label_style = $style->{'NodeLabel'};
                my $shape       = lc( $node_style->{'-shape'} );

                $shape = 'oval'
                    unless ( $shape eq 'rectangle' or $shape eq 'polygon' );

                my $skip_empty_nlabels = $label_style->{'-skipempty'};
                my $skip_empty_elabels = $style->{'EdgeLabel'}{'-skipempty'};
                $node_has_box
                    = $drawBoxes
                    && ( $valign_edge
                    = $label_style->{'-nodrawbox'} ne "yes" )
                    || !$drawBoxes
                    && ( $valign_edge
                    = $label_style->{'-dodrawbox'} eq "yes" );
                $NI->{"NodeHasBox"} = $node_has_box;
                my $surround = $node_style->{'-surroundtext'};

                if ( $node_has_box or $surround ) {
                    my $count = $NI->{
                        "NodeLabel_nonempty"};    # : scalar(@$node_patterns);
                    $NI->{"TextBoxCoords"}
                        = $vertical_tree
                        ? [
                        0 + $gen_info->{"NodeLabel_XMIN"} - $xmargin,
                        0 + $NI->{"NodeLabel_YPOS"} - $ymargin,
                        0 + $gen_info->{"NodeLabel_XMAX"} + $xmargin,
                        0 
                            + $NI->{"NodeLabel_YPOS"} 
                            + $ymargin
                            + $NI->{"NodeLabelLines"} * $lineHeight
                        ]
                        : [
                        0 + $NI->{"NodeLabel_XPOS"} - $xmargin,
                        0 + $NI->{"NodeLabel_YPOS"} - $ymargin,
                        0 
                            + $NI->{"NodeLabel_XPOS"} 
                            + $NI->{"NodeLabelWidth"}
                            + $xmargin,
                        0 
                            + $NI->{"NodeLabel_YPOS"} 
                            + $ymargin
                            + $count * $lineHeight
                        ];
                }
                my @node_coords = $self->node_coords( $node, $currentNode );
                my @tags = split /,/, ( $node_style->{'-tag'} || '' );

                #    $objectno++;
                # my $oval="oval_$objectno";
                my $o = $canvas->create(
                    $shape,
                    @node_coords,
                    -tags    => [ 'point', 'node', @tags ],
                    -outline => $self->get_nodeOutlineColor,
                    $self->node_options( $node, $fsfile->FS, $currentNode )
                );

                # $self->store_id_pinfo($o,$oval);
                eval {    #apply_style_opts
                    $canvas->itemconfigure(
                        $o,
                        ( %{ $style->{'Oval'} } ),
                        (   $node eq $currentNode
                            ? ( %{ $style->{'CurrentOval'} } )
                            : ()
                        )
                    );
                };
                print STDERR $@ if $@;
                $NI->{"Oval"} = $o;
                $self->store_obj_pinfo( $o, $node );

                # EdgeLabel
                if (    not $vertical_tree
                    and scalar(@$edge_patterns)
                    and $parent )
                {
                    my $coords = $style->{'EdgeLabel'}{'-coords'};
                    $halign_edge     = $style->{'EdgeLabel'}{'-halign'};
                    $valign_edge     = $style->{'EdgeLabel'}{'-valign'};
                    $edgeLabelWidth  = $NI->{"EdgeLabelWidth"};
                    $edgeLabelHeight = $NI->{"EdgeLabelHeight"};

                    if ($coords) {

                        # edge label with explicit coords
                        $coords = $self->parse_coords_spec( $node, $coords,
                            $nodes, \%nodehash, $grp );

                        #my @c=split ',',$coords;
                        if (my @c = $self->eval_coords_spec(
                                $node, $parent, $coords
                            )
                            )
                        {
                            if ( $halign_edge eq "left" ) {
                                $c[0] -= $edgeLabelWidth;
                            }
                            elsif ( $halign_edge eq "center" ) {
                                $c[0] -= $edgeLabelWidth / 2;
                            }
                            if ( $valign_edge eq "bottom" ) {
                                $c[1] -= $edgeLabelHeight;
                            }
                            elsif ( $valign_edge eq "center" ) {
                                $c[1] -= $edgeLabelHeight / 2;
                            }
                            $NI->{"EdgeLabel_XPOS"} = $c[0];
                            $NI->{"EdgeLabel_YPOS"} = $c[1];
                        }
                    }
                    else {
                        $y_edge_length = (
                            $node_info->{$parent}{"YPOS"} - $NI->{"YPOS"} );
                        $x_edge_length = (
                            $node_info->{$parent}{"XPOS"} - $NI->{"XPOS"} );
                        $x_edge_delta
                            = ( ( $NI->{"EdgeLabel_YPOS"} - $NI->{"YPOS"} )
                            * $x_edge_length ) / $y_edge_length;

                        # the reference point for edge label is now
                        # X: $NI->{"XPOS"}+$x_edge_delta
                        #	Y: $NI->{"EdgeLabel_YPOS"}

                        if ( $halign_edge eq "left" ) {
                            $x_edge_delta -= $edgeLabelWidth;
                        }
                        elsif ( $halign_edge eq "center" ) {
                            $x_edge_delta -= $edgeLabelWidth / 2;
                        }
                        if ( $valign_edge eq "bottom" ) {
                            $x_edge_delta
                                += ( $edgeLabelHeight * $x_edge_length )
                                / $y_edge_length;
                        }
                        elsif ( $valign_edge eq "center" ) {
                            $x_edge_delta
                                += ( ( $edgeLabelHeight * $x_edge_length )
                                / $y_edge_length )
                                / 2;
                        }
                        $x_edge_delta += $style->{'EdgeLabel'}{'-xadj'};
                        $NI->{"EdgeLabel_XPOS"}
                            = $NI->{"XPOS"} + $x_edge_delta;
                    }
                }

                # stripe
                if ( $vertical_tree && $self->get_horizStripe
                    || !$vertical_tree && $self->get_vertStripe )
                {

                    #      $objectno++;
                    #      my $stripe = "stripe_$objectno";
                    my $stripe_id = $canvas->createRectangle(
                        $vertical_tree
                        ? ( -200,
                            0 + $NI->{"NodeLabel_YPOS"} - $ymargin,
                            0 + $self->{canvasWidth} + 200,
                            $NI->{"NodeLabel_YPOS"} + $ymargin + $lineHeight,
                            )
                        : ( 0 + $NI->{"XPOS"} - $self->get_nodeWidth,
                            -200,
                            0 + $NI->{"XPOS"} + $self->get_nodeWidth,
                            0 + $self->{canvasHeight} + 200,
                        ),
                        -fill => $currentNode == $node
                        ? $self->get_stripeColor
                        : $self->realcanvas->cget('-background'),
                        -outline => undef,
                        -tags    => ['stripe']
                    );

                    # $self->store_id_pinfo($stripe_id,$stripe);
                    $self->store_obj_pinfo( $stripe_id, $node );
                    $NI->{"Stripe"} = $stripe_id;
                }
                ## Boxes around attributes
                if ($node_has_box) {
                    ## get maximum width stored here by recalculate_positions
                    #      $objectno++;
                    #      my $box="textbox_$objectno";
                    my @coords = @{ $NI->{"TextBoxCoords"} };
                    my $bid    = $canvas->createRectangle( @coords,
                        -tags => ['textbox'] );

                    # $self->store_id_pinfo($bid,$box);
                    eval {    #apply_style_opts
                        $canvas->itemconfigure(
                            $bid,
                            $self->node_box_options(
                                $node, $fsfile->FS, $currentNode, 0
                            ),
                            %{  $style->{
                                    (   $node == $currentNode
                                        ? "CurrentTextBox"
                                        : "TextBox"
                                    )
                                    }
                                }
                        );
                    };
                    print STDERR $@ if $@;
                    $NI->{"TextBox"} = $bid;
                    $self->store_obj_pinfo( $bid, $node );
                }
                $edge_has_box 
                    = !$vertical_tree
                    && scalar(@$edge_patterns)
                    && $parent
                    && (
                    $drawEdgeBoxes
                    && ( $valign_edge
                        = $style->{'EdgeLabel'}{'-nodrawbox'} ne "yes" )
                    || !$drawEdgeBoxes
                    && ( $valign_edge
                        = $style->{'EdgeLabel'}{'-dodrawbox'} eq "yes" )
                    );
                $NI->{"EdgeHasBox"} = $edge_has_box;
                if ($edge_has_box) {

                    #      $objectno++;
                    #      my $box="edgebox_$objectno";
                    my $bid = $canvas->createRectangle(
                        $NI->{"EdgeLabel_XPOS"} - $xmargin,
                        $NI->{"EdgeLabel_YPOS"} - $ymargin,
                        $NI->{"EdgeLabel_XPOS"} + $xmargin + $edgeLabelWidth,
                        $NI->{"EdgeLabel_YPOS"} 
                            + $ymargin
                            + scalar(@$edge_patterns) * $lineHeight,
                        -tags => ['edgebox']
                    );

                    # $self->store_id_pinfo($bid,$box);
                    eval {    #apply_style_opts
                        $canvas->itemconfigure(
                            $bid,
                            $self->node_box_options(
                                $node, $fsfile->FS, $currentNode, 1
                            ),
                            %{  $style->{
                                    $node == $currentNode
                                    ? "CurrentEdgeTextBox"
                                    : "EdgeTextBox"
                                    }
                                }
                        );
                    };
                    print STDERR $@ if $@;
                    $NI->{"EdgeTextBox"} = $bid;
                    $self->store_obj_pinfo( $bid, $node );
                }

                undef %nodehash;

                ## Texts of attributes
                my ( $msg, $e_x, $n_x, $e_y, $n_y, $empty );
                my ( $i, $e_i, $n_i, $non_empty_n, $non_empty_e )
                    = ( 0, 0, 0, 0, 0 );
                my ( $pat_class, $pat );
                $e_y = 0 + $NI->{"EdgeLabel_YPOS"};
                $n_y = 0 + $NI->{"NodeLabel_YPOS"};
                $e_x = 0 + $NI->{"EdgeLabel_XPOS"};
                $n_x = 0 + $NI->{"NodeLabel_XPOS"};
                for ( ; $i <= $#$patterns; $i++ ) {
                    ( $pat_class, $pat ) = @{ $patterns->[$i] };
                    $msg = $self->interpolate_text_field( $node, $pat, $grp );
                    if ( $pat_class eq "edge" ) {
                        if ( $parent || $vertical_tree ) {
                            $msg =~ s{/}{}g
                                ; # should be done in interpolate_text_field; PP: what is it good for?
                            $empty = 0;
                            if ($vertical_tree) {
                                $e_x = 0 + $gen_info->{"EdgeLabel_XPOS[$e_i]"}
                                    if $i;
                            }
                            else {
                                if (    $skip_empty_elabels
                                    and $NI->{"X[$i]"} == 0 )
                                {
                                    $empty = 1;
                                }
                                if ( !$empty ) {
                                    $e_y += $lineHeight if $non_empty_e;
                                    $non_empty_e++;
                                }
                            }
                            $e_i++;
                            $e_y = $self->draw_text_line(
                                $fsfile, $node,          $i,
                                $msg,    $lineHeight,    $e_x,
                                $e_y,    !$edge_has_box, \%Opts,
                                $grp,    'Edge'
                            ) unless $empty;
                        }
                    }
                    elsif ( $pat_class eq "node" ) {    # node
                        $empty = 0;
                        if ($vertical_tree) {
                            $n_x = $gen_info->{"NodeLabel_XPOS[$n_i]"} if $i;
                        }
                        else {
                            if ( $skip_empty_nlabels and $NI->{"X[$i]"} == 0 )
                            {
                                $empty = 1;
                            }
                            if ( !$empty ) {
                                $n_y += $lineHeight if $non_empty_n;
                                $non_empty_n++;
                            }
                        }
                        $n_i++;
                        unless ($empty) {
                            my $ret = $self->draw_text_line(
                                $fsfile,     $node,
                                $i,          $msg,
                                $lineHeight, $n_x,
                                $n_y,        !$node_has_box && !$surround,
                                \%Opts,      $grp,
                                'Node'
                            );
                            $n_y = $ret unless $vertical_tree;
                        }
                    }
                }
                my $clear;
                for my $pat (@$label_patterns) {
                    my $coords;
                    $i++;
                    $msg = $self->interpolate_text_field( $node, $pat, $grp );
                    if ( $msg =~ s/\#{-coords:([^}]*)}//g ) {
                        $coords = $1;
                    }
                    $clear = 1;
                    if ( $msg =~ s/\#{-clear:([01])}//g ) {
                        $clear = $1;
                    }
                    $coords = 'n,n'
                        unless ( defined($coords) and length($coords) );
                    $coords
                        = $self->parse_coords_spec( $node, $coords, $nodes,
                        \%nodehash, $grp );
                    if ( my @c
                        = $self->eval_coords_spec( $node, $parent, $coords ) )
                    {
                        $self->draw_text_line(
                            $fsfile,     $node, $i,    $msg,
                            $lineHeight, $c[0], $c[1], $clear,
                            \%Opts,      $grp,  'Label'
                        );
                    }
                }
            }

            my @bbox = $canvas->bbox('!stripe&&!seg:prev');
            %$gen_info
                = ( attr => $gen_info->{attr}, tag => $gen_info->{tag} );
            $Opts{baseXPos} = $bbox[2] + $baseXPos;
            eval { $canvas->addtag( qq(seg:$seg_i/$seg_j), '!seg:prev' ); 1 }
                || $canvas->addtag( qq(seg:$seg_i/$seg_j), 'all' );
        }    #for $seg_j
        my @bbox = $canvas->bbox('!stripe');
        $Opts{baseXPos} = $baseXPos;
        $Opts{baseYPos} = $bbox[3] + $baseYPos;
    }    # for $seg_i

    {

        my @bbox = $canvas->bbox('!stripe');
        $self->{canvasWidth}  = $bbox[2] + $self->get_xmargin;
        $self->{canvasHeight} = $bbox[3] + $self->get_ymargin;

        # draw sentence info
        if ( $fsfile
            and ( $self->get_drawFileInfo or $self->get_drawSentenceInfo ) )
        {
            my $fontHeight = $self->getFontHeight() * $lineSpacing;
            $self->{canvasHeight} += $fontHeight;    # add some skip
            if ( $self->get_drawFileInfo ) {
                my $currentfile = TrEd::File::filename( $fsfile->filename );
                my ($ftext);
                $ftext = "File: $currentfile";
                if (@$nodes) {
                    my $r_node = $nodes->[0]->root;
                    my $which_tree
                        = Treex::PML::Index( $fsfile->treeList, $r_node ) + 1;
                    $ftext
                        .= ", tree "
                        . $which_tree . " of "
                        . ( $fsfile->lastTreeNo + 1 );
                }
                else {
                    $ftext = '';
                }
                eval {    #apply_style_opts
                    $canvas->itemconfigure(
                        $canvas->createText(
                            0,
                            $self->{canvasHeight},
                            -tags    => [ 'vline', 'text_item' ],
                            -font    => $self->get_font,
                            -text    => $ftext,
                            -justify => 'left',
                            -anchor  => 'nw'
                        ),
                        %{ $RootStyle{SentenceText} }
                    );
                };
                print STDERR $@ if $@;
                $self->{canvasHeight} += $fontHeight;
                my $ftw = $self->getTextWidth( $ftext, 1 );
                $self->{canvasWidth} = max2( $self->{canvasWidth}, $ftw );
                $self->apply_style_opts(
                    $canvas->createLine(
                        0, $self->{canvasHeight},
                        ( $ftw || 0 ), $self->{canvasHeight}
                    ),
                    %{ $RootStyle{SentenceFileInfo} }
                );
                $self->{canvasHeight} += $fontHeight;
            }
            if ( $self->get_drawSentenceInfo ) {
                if ( ref($valtext) eq 'ARRAY' ) {
                    $valtext = join '', map { $_->[0] } @$valtext;
                }
                else {
                    $valtext =~ s{^(.*)/([^:]*):}{};
                }
                $valtext =~ s/ +([.,!:;])|(\() |(\)) /$1/g;
                my $i     = 1;
                my $lines = $self->wrapLines( $valtext, $self->{canvasWidth},
                    $right_to_left );
                foreach (@$lines) {
                    if ($right_to_left) {
                        eval {    #apply_style_opts
                            $canvas->itemconfigure(
                                $canvas->createText(
                                    $self->{canvasWidth},
                                    $self->{canvasHeight},
                                    -font    => $self->get_font,
                                    -tags    => [ 'vline', 'text_item' ],
                                    -text    => $_,
                                    -justify => 'right',
                                    -anchor  => 'ne'
                                ),
                                %{ $RootStyle{SentenceLine} }
                            );
                        };
                        print STDERR $@ if $@;
                    }
                    else {
                        eval {    #apply_style_opts
                            $canvas->itemconfigure(
                                $canvas->createText(
                                    0, $self->{canvasHeight},
                                    -font    => $self->get_font,
                                    -tags    => [ 'vline', 'text_item' ],
                                    -text    => $_,
                                    -justify => 'left',
                                    -anchor  => 'nw'
                                ),
                                %{ $RootStyle{SentenceLine} }
                            );
                        };
                        print STDERR $@ if $@;
                    }
                    $self->{canvasHeight} += $fontHeight;
                }
            }
        }

        ## Canvas Custom Balloons ##
        if ($fsfile) {
            my $hint
                = defined( $self->hint ) ? ${ $self->hint } : $fsfile->hint;
            if ( $self->get_CanvasBalloon ) {

                #DEBUG

                #=pod
                $self->get_CanvasBalloon()->attach(
                    $canvas,
                    -balloonposition => 'mouse',
                    -msg             => {
                        %arrow_hints,
                        map {
                            if ( defined($_) )
                            {
                                my $node = $self->get_obj_pinfo($_);
                                my $msg
                                    = $self->interpolate_text_field( $node,
                                    $hint, $grp );
                                if ( defined $msg ) {
                                    $msg
                                        =~ s/\${([^}]+)}/_present_attribute($node,$1)/eg;
                                    ( $_ => encode($msg) );
                                }
                                else {
                                    ();
                                }
                            }
                            } $self->find_item( 'withtag', 'point' )
                    }
                );

                #=cut

            }
        }
        eval {
            if ( $vertical_tree
                && defined $node_info->{$currentNode}{'Stripe'} )
            {
                $canvas->itemconfigure( "textbg_$currentNode",
                    -fill => undef );
            }
        };
        eval { $canvas->lower( 'stripe', 'all' ) };
        $self->raise_order(
            qw(line
                point
                textbox
                edgetextbox
                textbg
                text
                plaintext
                )
        );
        if ( length $Opts{stackOrder} ) {
            $self->raise_order( split /\s*,\s*/, $Opts{stackOrder} );
        }
        if ( defined $self->get_backgroundImage ) {
            unless ( $canvas->find( 'withtag', 'bgimage' ) ) {
                my $img = $self->get_backgroundImage;
                print STDERR "Loading background image from $img...";
                eval {
                    $canvas->Photo( "photo", -file => $img );
                    $canvas->createImage(
                        $self->get_backgroundImageX,
                        $self->get_backgroundImageY,
                        -image  => "photo",
                        -anchor => 'nw',
                        -tags   => 'bgimage'
                    );
                };
                print STDERR $@ ? "failed.\n" : "ok.\n";
            }
            $canvas->lower( 'bgimage', 'all' )
                if ( $canvas->find( 'withtag', 'bgimage' ) );
        }

        undef $@;

        @bbox = $canvas->bbox('!stripe')
            ;    # now including the file and sentence info
        $self->{canvasWidth}  = $bbox[2] + $self->get_xmargin;
        $self->{canvasHeight} = $bbox[3] + $self->get_ymargin;
    }
    if ( $stipple ne "" ) {
        $canvas->createRectangle(
            -1000, -1000,
            max2( 5000, $self->{canvasWidth} ),
            max2( 5000, $self->{canvasHeight} ),
            -outline => undef,
            -fill    => 'lightgray',
            -stipple => 'gray25',

            #			     -activestipple => 'gray25',
            -tags  => 'stipple',
            -state => $stipple
        );
    }
    if ( defined $scale ) {
        $self->scale($scale);
    }
    else {
        $self->reset_scroll_region;
    }
    if ($on_redraw_done) {
        callback( $on_redraw_done, $self );
    }
}

sub raise_order {
    my ( $self, @tags ) = @_;
    my $last_ok;
    my $canvas = $self->realcanvas;
    while (@tags) {
        my ( $above, $raise ) = @tags;
        eval { $canvas->raise( $raise, $above ) };
        if ($@) {
            if ( defined $last_ok ) {
                eval { $canvas->raise( $raise, $last_ok ) };
                print STDERR $@ if $@;
            }
        }
        else {
            $last_ok = $above;
        }
        shift @tags;
    }
}

sub reset_scroll_region {
    my ($self) = @_;
    my $canvas = $self->canvas;
    $canvas->configure( -scrollregion =>
            [ 0, 0, $self->{canvasWidth} || 0, $self->{canvasHeight} || 0 ] );
    $canvas->xviewMoveto(0);
    $canvas->yviewMoveto(0);
}

sub draw_text_line {
    my ($self, $fsfile, $node,  $i,    $msg, $lineHeight,
        $x,    $y,      $clear, $Opts, $grp, $what
    ) = @_;
    my $node_info  = $self->{node_info};
    my $gen_info   = $self->{gen_info};
    my $style_info = $self->{style_info};

    #  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
    my $style = $style_info->{$node};
    my $align = $style->{ $what . "[$i]" }{'-textalign'}
        || $style->{$what}{'-textalign'};
    my $textdelta = 0;
    my $X
        = ( $what eq 'Label' )
        ? $self->getTextWidth( $self->prepare_text( $node, $msg, $grp ) )
        : $node_info->{$node}{"X[$i]"};
    if ( !defined($align) or $align eq 'left' ) {
        $textdelta = 0;
    }
    elsif ( $align eq 'right' ) {
        my $lw = $gen_info->{ $what . "LabelWidth[$i]" };
        $lw = $node_info->{$node}{ $what . "LabelWidth" } unless defined $lw;
        if ( defined $lw ) {
            $textdelta = ( $lw - $X );
        }
        else {
            $textdelta = -$X;
        }
    }
    elsif ( $align eq 'center' ) {
        my $lw = $gen_info->{ $what . "LabelWidth[$i]" };
        $lw = $node_info->{$node}{ $what . "LabelWidth" } unless defined $lw;
        if ( defined $lw ) {
            $textdelta = ( $lw - $X ) / 2;
        }
        else {
            $textdelta = -$X / 2;
        }
    }
    ## Clear background
    my $canvas = $self->realcanvas;

    ## Draw attribute
    ## Custom version (the tredish)
    ##
    ## in this case we use the following syntax:
    ## #{color} changes color of all the following text
    ## ${attribute} is expanded to the value of attribute (and the
    ##              text is made active, so that modification is possible)
    ## <?code?>     expands to the return value of the imbedded perl-code
    ##              ($${attribute} may be used inside the code and is expanded
    ##              to 'value'. \${attribute} is not interpolated before <?code?>,
    ##              but may be used in return value and is interpolated later).
    ##              Usage of ${attribute} would be in collision with perl syntax,
    ##              and would refer only to $attribute variable, if any such
    ##              exists.

    $x += $textdelta;

    my $xskip = 0;
    my $txt;
    my $at_text;
    my $j     = 0;
    my $color = undef;
    my @color_stack;
    my %inline_opts;
    my $use_fs_colors = $self->get_useFSColors;
    my $line;
    my $font = $self->get_font;

    foreach ( grep {length} split( m/([#\$]${bblock})/, $msg ) ) {
        if (/^\$${block}$/) {
            my $c = $1;
            $j++;
            if ( $c =~ /^(.*?)=(.*)$/s ) {
                $c       = $1;
                $at_text = encode($2);
            }
            else {
                $at_text = $self->prepare_text_field( $node, $c, $grp );
            }
            next unless length($at_text);
            my @opts = (
                -anchor => 'nw',
                (   $use_fs_colors
                    ? ( -fill => $self->which_text_color( $fsfile, $c ) )
                    : ()
                ),
                -font => $font,
                -tags => [
                    'text',        'text_item',
                    "text[$node]", "text[$node][$i]",
                    "text[$node][$i][$j]"
                ]
            );
            my @opts2 = (
                %{ $style->{"Text"}             || NoHash },
                %{ $style->{"Text[$c]"}         || NoHash },
                %{ $style->{"Text[$c][$i]"}     || NoHash },
                %{ $style->{"Text[$c][$i][$j]"} || NoHash },
                %inline_opts,
                ( defined($color) ? ( -fill => $color ) : () )
            );
            my $last;
            my $lines = 0;
            for $line ( split /\n/, $at_text, -1 ) {
                if ( $lines++ ) {
                    $xskip = 0;
                    $y += $lineHeight;
                }
                $last = $line;
                next unless length $line;
                my $bid = $canvas->createText(
                    $x + $xskip, $y,
                    -text => $line,
                    @opts
                );

                # $self->store_id_pinfo($bid,$txt);
                eval {    #apply_style_opts
                    $canvas->itemconfigure( $bid, @opts2 );
                };
                print STDERR $@ if $@;
                $self->store_obj_pinfo( $bid, $node );
                $gen_info->{attr}{$bid} = $c;
            }
            $xskip += $self->getTextWidth($last);
            $node_info->{$node}{"Text[$c][$i][$j]"} = "text[$c][$i][$j]";
        }
        elsif (/^\#${block}$/) {
            unless ( $self->get_noColor ) {
                my $c = $1;
                if ( $c =~ m/^(.*)(-.+):(.+)$/ ) {
                    if ( defined($1) and length($1) ) {

                        # Depreciated ! Use style pattern!
                        eval {
                            $canvas->itemconfigure( $node_info->{$node}{$1},
                                $2 => $3 );
                        };
                        print STDERR $@ if $@ ne "";
                    }
                    else {
                        $inline_opts{$2} = $3;
                    }
                }
                else {

# one can use also interval syntax, like:  #{red(} .... #{)red}, or #{red(} ... #{)}
                    if ( $c =~ s/\($// ) {
                        push @color_stack, [ $c, $color ];
                    }
                    elsif ( $c =~ s/^\)// ) {
                        if ( $c eq ''
                            or ( @color_stack and $c eq $color_stack[-1][0] )
                            )
                        {
                            $c = pop(@color_stack)->[1];
                        }
                        else {
                            warn
                                "Stylesheet error: cannot end #{$color_stack[-1][0](} with #{$c)}\n";
                            undef $c;
                        }
                    }
                    $color = $c;
                    $color = undef if ( $color eq 'default' );
                    $color = $self->get_custom_color($1)
                        if ( $color =~ /^custom(.*)$/ );
                }
            }
        }
        else {
            if ( $_ ne "" ) {
                my @opts = (
                    %{ $style->{Text} },
                    %inline_opts,
                    ( defined($color) ? ( -fill => $color ) : () )
                );
                my $lines = 0;
                my $last;
                my $tags = [
                    'plaintext',   'text_item',
                    "text[$node]", "text[$node][$i]"
                ];
                for $line ( split /\n/, $_, -1 ) {
                    if ( $lines++ ) {
                        $xskip = 0;
                        $y += $lineHeight;
                    }
                    $last = $line;
                    next unless length $line;
                    my $bid = $canvas->createText(
                        $x + $xskip,
                        $y,
                        -text   => encode($line),
                        -anchor => 'nw',
                        -font   => $font,
                        -tags   => $tags,
                    );
                    eval {    #apply_style_opts
                        $canvas->itemconfigure( $bid, @opts );
                    };
                    print STDERR $@ if $@;
                    $self->store_obj_pinfo( $bid, $node );
                }
                $xskip += $self->getTextWidth($last);
            }
        }
    }
    if (    $self->get_clearTextBackground
        and $clear )
    {                         #  and $X>0
        my @bbox = $canvas->bbox("text[$node][$i]");
        if (@bbox) {
            my $bid = $canvas->createRectangle(
                @bbox,

                #	$x+$textdelta,$y,
                #		      $x+$textdelta+$X+1,
                #		      $y+$lineHeight,
                -fill    => $canvas->cget('-background'),
                -outline => undef,
                -width   => 0,
                -tags    => [ 'textbg', "textbg_$node" ]
            );
            eval {    #apply_style_opts
                $canvas->itemconfigure(
                    $bid,
                    %{ $style->{TextBg} },
                    %{ $style->{"TextBg[$i]"} },
                );
            };
            print STDERR $@ if $@;
            $node_info->{$node}{"TextBg[$i]"} = $bid;
            $self->store_obj_pinfo( $bid, $node );
        }
    }
    return $y;
}

sub get_custom_color {
    my ( $self, $color ) = @_;
    if ( ref $self->{customColors} ) {
        return $self->{customColors}{$color};
    }
    else {
        return;
    }
}
# if pattern starts with 'sth:', 'sth' is considered to be the type of pattern, it is removed from the pattern and a tuple (type, pattern) is returned, trailing spaces are removed. otherwise, tuple ('node', pattern) is returned and no trailing spaces are removed
sub parse_pattern {
    my ( $self, $pattern ) = @_;
    if ( $pattern =~ s/^([a-z]+):\s*// ) {
        my $t = lc($1);
        $pattern =~ s/\s+$//;
        return ( $t, $pattern );
    }
    else {
        return "node", $pattern;
    }
}

sub is_pattern_of {
    my ( $self, $style, $pattern ) = @_;
    return ( $self->parse_pattern($pattern) )[0] eq lc($style);
}
# take our patterns or fsfile patterns and filter only those with label $style, return list of patterns for this label
sub get_label_patterns {
    my ( $self, $fsfile, $style ) = @_;
    $style = lc($style);
    return map {
        my ( $pattern_type, $pattern ) = $self->parse_pattern($_);
        $pattern_type eq $style ? $pattern : ()
        } $self->patterns() ? @{ $self->patterns }
        : $fsfile           ? $fsfile->patterns()
        :                     ();
}

=pod

=item prepare_text (fsfile,node,pattern)

Interpolate given pattern for the given node,
by evaluating all code (`<? code ?>') and
attribute (`${attribute}') fields, removing all
formatting references of the form #{format}.

=cut

sub prepare_text {
    my ( $self, $node, $pattern, $grp ) = @_;
    return q{} if !ref $node;
    my $msg = $self->interpolate_text_field( $node, $pattern, $grp );
    return q{} if !length $msg;
    $msg =~ s/\#${block}//g;
    $msg =~ s/\$${block}/$self->prepare_raw_text_field($node,$1)/eg;
    return encode($msg);
}

=pod

=item interpolate_text_field (node,text,grp)

Interpolate, evaluate and substitute the results for
all code references of the form `<? code ?>' in the given
text.

=cut

# matches sth like <? '#{customparenthesis}' if $${is_parenthesis} ?>
my $code_match    = qr/(\<\?(?:[^?]|\?[^>])+\?\>)/; 
# matches the same, it just has to be all there is in the string
my $code_match_in = qr/^\<\?((?:[^?]|\?[^>])+)\?\>$/; 

#######################################################################################
# Usage         : _compile_code($text)
# Purpose       : Compiled code contained in $text string
# Returns       : Reference to compiled code
# Parameters    : scalar $text -- text to compile
# Throws        : no exceptions
# Comments      : The code is executed in TredMacro package. Nodes attributes can be 
#                 accessed using $${attribute} syntax
# See Also      : interpolate_text_field(), 
sub _compile_code {
    my ($text) = @_;
    $text
        =~ s/\$\${([^}]+)}/ TrEd::TreeView::_present_attribute(\$this,'$1')/g; #subst $${var}
    return eval "package TredMacro; sub{ eval { $text } }";
}
# we got node object, text (e.g. pattern from stylesheet) and $grp (here we have window), we interpolate text field, ie run the code in <? ?> or just use the text directly
sub interpolate_text_field {
    my ( $self, $node, $text, $grp_ctxt ) = @_;
    return if (!defined $text || !length $text);
    # make $this, $root, and $grp available for the evaluated expression
    # as in TrEd::Macros
    no strict 'refs';
    my @save
        = ( ${'TredMacro::this'}, ${'TredMacro::root'}, ${'TredMacro::grp'} );
    my $root = ( $node && $node->root() );
#    $root = ( $node && $node->root );
    ( ${'TredMacro::this'}, ${'TredMacro::root'}, ${'TredMacro::grp'} )
        = ( $node, $root, $grp_ctxt );

    my $cached = $PATTERN_CODE_CACHE{$text};
    if ( !defined $cached ) {
        $cached = $PATTERN_CODE_CACHE{$text} = [
            map { $_ =~ $code_match_in ? _compile_code($1) : $_ }
                split $code_match, $text
        ];
    }
    # call compiled code if it is a code ref, otherwise just use the saved text
    # maybe we should reset this,root,grp, etc. every time!
    $text = join '', map { ref $_ ? $_->() : $_ }
                         @{$cached};
    ( ${'TredMacro::this'}, ${'TredMacro::root'}, ${'TredMacro::grp'} )
        = @save;     #
    return $text;
}

=pod

=item interpolate_refs (node, text)

Interpolate any attribute references of the form $${attribute}
in the text with the single-quotted value.

=cut

sub _quote_quote { my ($q) = @_; $q =~ s/\\/\\\\/g; $q =~ s/'/\\'/g; $q }

sub _present_attribute {
  my ($node,$path) = @_;
  my $val = $node;
  my $append = "";
  for my $step (split /\//, $path) {
    if (UNIVERSAL::DOES::does($val, 'Treex::PML::List') or UNIVERSAL::DOES::does($val, 'Treex::PML::Alt')) {
      if ($step =~ /^\[(\d+)\]/) {
	$val = ($val->values)[$1-1];
      } else {
	$append="*" if $val->count > 1;
	$val = ($val->values)[0];
	redo;
      }
    } elsif (UNIVERSAL::DOES::does($val, 'Treex::PML::Seq')) {
      if ($step =~ /^\[([-+]?\d+)\](.*)/) {
	$val =
	  $1>0 ? ($val->elements_list->values)[$1-1] :
	  $1<0 ? ($val->elements_list->values)[$1]   : undef; # element
	if (defined $2 and length $2) { # optional name test
	  return if $val->[0] ne $2; # ERROR
	}
	$val = $val->[1]; # value
      } elsif ($step =~ /^([^\[]+)(?:\[([-+]?\d+)\])?/) {
	my $i = $2;
	$val = $val->values($1);
	if (length $i) {
	  $val = $i>0 ? ($val->values)[$i-1] :
	         $i<0 ? ($val->values)[$i]   : undef;
	} else {
	  $append = '*' if $val->count > 1;
	  $val = ($val->values)[0];
	}
      } else {
	return; # ERROR
      }
    } elsif (UNIVERSAL::isa($val,'HASH')) {
      $val = $val->{$step};
    } elsif (defined($val)) {
      #warn "Can't follow attribute path '$path' (step '$step')\n";
      return undef; # ERROR
    } else {
      return '';
    }
  }
  if (UNIVERSAL::DOES::does($val, 'Treex::PML::List') or UNIVERSAL::DOES::does($val, 'Treex::PML::Alt')) {
    $append="*" if $val->count > 1;
    $val = ($val->values)[0];
  }
  return defined $val ? $val.$append : $append;
}


# find the value of attribute specified by $path on node $node
sub _present_attribute__2 {
    my ( $node, $path ) = @_;
    my $val    = $node;
    my $append = "";
    for my $step ( split /\//, $path ) {
        return q{} if (!defined $val);
        # changed order of conditions, premature optimization is our hobby ;)
        if ( UNIVERSAL::isa( $val, 'HASH' ) ) {
            $val = $val->{$step};
        }
        elsif (   UNIVERSAL::DOES::does( $val, 'Treex::PML::List' )
               or UNIVERSAL::DOES::does( $val, 'Treex::PML::Alt' ) )
        {
            if ( $step =~ /^\[(\d+)\]/ ) {
                $val = ($val->values)[ $1 - 1 ];
            }
            else {
                if ($val->values > 1) {
                    $append = "*";
                }
                $val = ($val->values)[0];
                redo;
            }
        }
        elsif ( UNIVERSAL::DOES::does( $val, 'Treex::PML::Seq' ) ) {
            if ( $step =~ /^\[([-+]?\d+)\](.*)/ ) {
                $val = $1 > 0 ? ($val->elements_list->values)[ $1 - 1 ]
                     : $1 < 0 ? ($val->elements_list->values)[$1]
                     :          undef;               # element
                if ( defined $2 and length $2 ) {    # optional name test
                    return if $val->[0] ne $2;       # ERROR
                }
                $val = $val->[1];                    # value
            }
            elsif ( $step =~ /^([^\[]+)(?:\[([-+]?\d+)\])?/ ) {
                my $i = $2;
                $val = $val->values($1);
                if ( length $i ) {
                    $val
                        = $i > 0 ? ($val->values)[ $i - 1 ]
                        : $i < 0 ? ($val->values)[$i]
                        :          undef;
                }
                else {
                    $append = '*' if $val->count > 1;
                    $val = ($val->values)[0];
                }
            }
            else {
                return;    # ERROR
            }
        }
        elsif ( defined $val ) {
            #warn "Can't follow attribute path '$path' (step '$step')\n";
            return;    # ERROR
        }
    }
    if (   UNIVERSAL::DOES::does( $val, 'Treex::PML::List' )
        or UNIVERSAL::DOES::does( $val, 'Treex::PML::Alt' ) )
    {
        $append = "*" if $val->count > 1;
        $val = ($val->values)[0];
    }
    return $val . $append;
}

sub interpolate_refs {
    my ( $self, $node, $text ) = @_;
    $text
        =~ s/\$\${([^}]+)}/"'"._quote_quote(_present_attribute($node,$1))."'"/eg;
    return $text;
}

=pod

=item prepare_text_field (node,attribute)

Return the first (of possibly multiple) value of the given node's
attribute. If more values exist, only the first is
presented followed by the character "*".

=cut

#'

sub prepare_text_field {
    my ( $self, $node, $atr ) = @_;
    my $text = _present_attribute( $node, $atr );

    #  $text=$1."*" if ($text =~/^([^\|]*)\|/);
    return encode($text);
}

=pod

=item prepare_raw_text_field (node,attribute)

As prepare_text_field but not recoding text to output encoding.

=cut

sub prepare_raw_text_field {
    my ( $self, $node, $atr ) = @_;
    if ( $atr =~ /^.*?=(.*)$/s ) {
        return $1;
    }
    else {
        return _present_attribute( $node, $atr );

        #    my $text=
        #    $text=$1."*" if ($text =~/^([^\|]*)\|/);
        #    return $text;
    }
}

#--------------------------------------------------------------
#
# TkBezierPoints --
#
#	Given four control points, create a larger set of points
#	for a Bezier spline based on the points.
#
# Results:
#	The array at *coordPtr gets filled in with 2*numSteps
#	coordinates, which correspond to the Bezier spline defined
#	by the four control points.  Note:  no output point is
#	generated for the first input point, but an output point
#	*is* generated for the last input point.
#
# Side effects:
#	None.
#
#--------------------------------------------------------------

sub TkBezierPoints {
    my ( $control, $numSteps, $coordPtr ) = @_;

    # double control[];			# Array of coordinates for four
    # control points:  x0, y0, x1, y1,
    # ... x3 y3.
    # int numSteps;			# Number of curve points to
    # generate.
    # register double *coordPtr;		# Where to put new points.
    my $i;
    my ( $u, $u2, $u3, $t, $t2, $t3 );
    no integer;
    for ( $i = 1; $i <= $numSteps; $i++ ) {
        $t  = $i / $numSteps;
        $t2 = $t * $t;
        $t3 = $t2 * $t;
        $u  = 1.0 - $t;
        $u2 = $u * $u;
        $u3 = $u2 * $u;
        push @$coordPtr,
              $control->[0] * $u3
            + 3.0 * ( $control->[2] * $t * $u2 + $control->[4] * $t2 * $u )
            + $control->[6] * $t3;
        push @$coordPtr,
              $control->[1] * $u3
            + 3.0 * ( $control->[3] * $t * $u2 + $control->[5] * $t2 * $u )
            + $control->[7] * $t3;
    }
}

#--------------------------------------------------------------
#
# TkMakeBezierCurve --
#
#	Given a set of points, create a new set of points that fit
#	parabolic splines to the line segments connecting the original
#	points.  Produces output points in either of two forms.
#
#	Note: in spite of this procedure's name, it does *not* generate
#	Bezier curves.  Since only three control points are used for
#	each curve segment, not four, the curves are actually just
#	parabolic.
#
# Results:
#	Either or both of the xPoints or dblPoints arrays are filled
#	in.  The return value is the number of points placed in the
#	arrays.  Note:  if the first and last points are the same, then
#	a closed curve is generated.
#
# Side effects:
#	None.
#
#--------------------------------------------------------------

sub TkMakeBezierCurve {
    my ( $coords, $numSteps, $has_arrow ) = @_;

    # Tk_Canvas canvas;			# Canvas in which curve is to be
    # drawn.
    # double *coords;			# Array of input coordinates:  x0,
    # y0, x1, y1, etc..
    # int numPoints;			# Number of points at coords.
    # int numSteps;			# Number of steps to use for each
    # spline segments (determines
    # smoothness of curve).
    # double retPoints[];			# Array of points to fill in as
    # doubles, in the form x0, y0,
    # x1, y1, ....  NULL means don't
    # fill in anything in this form.
    # Caller must make sure that this
    # array has enough space.
    my ( $closed, $i );
    no integer;
    my $numPoints = int( @$coords / 2 );
    my @control;
    my @retPoints;

    # If the curve is a closed one then generate a special spline
    # that spans the last points and the first ones.  Otherwise
    # just put the first point into the output.

    if (    !$has_arrow
        and ( $coords->[0] == $coords->[-2] )
        and ( $coords->[1] == $coords->[-1] ) )
    {
        $closed     = 1;
        $control[0] = 0.5 * $coords->[-4] + 0.5 * $coords->[0];
        $control[1] = 0.5 * $coords->[-3] + 0.5 * $coords->[1];
        $control[2] = 0.167 * $coords->[-4] + 0.833 * $coords->[0];
        $control[3] = 0.167 * $coords->[-3] + 0.833 * $coords->[1];
        $control[4] = 0.833 * $coords->[0] + 0.167 * $coords->[2];
        $control[5] = 0.833 * $coords->[1] + 0.167 * $coords->[3];
        $control[6] = 0.5 * $coords->[0] + 0.5 * $coords->[2];
        $control[7] = 0.5 * $coords->[1] + 0.5 * $coords->[3];
        push @retPoints, $control[0];
        push @retPoints, $control[1];
        TkBezierPoints( \@control, $numSteps, \@retPoints );
    }
    else {
        $closed = 0;
        push @retPoints, $coords->[0];
        push @retPoints, $coords->[1];
    }
    my ( $x1, $y1, $x2, $y2, $x3, $y3 );
    for ( $i = 2; $i < $numPoints; $i++ ) {
        ( $x1, $y1, $x2, $y2, $x3, $y3 )
            = @$coords[ 2 * $i - 4 .. 2 * $i + 1 ];

        # Set up the first two control points.  This is done
        # differently for the first spline of an open curve
        # than for other cases.

        if ( ( $i == 2 ) and !$closed ) {
            $control[0] = $x1;
            $control[1] = $y1;
            $control[2] = 0.333 * $x1 + 0.667 * $x2;
            $control[3] = 0.333 * $y1 + 0.667 * $y2;
        }
        else {
            $control[0] = 0.5 * $x1 + 0.5 * $x2;
            $control[1] = 0.5 * $y1 + 0.5 * $y2;
            $control[2] = 0.167 * $x1 + 0.833 * $x2;
            $control[3] = 0.167 * $y1 + 0.833 * $y2;
        }

        # Set up the last two control points.  This is done
        # differently for the last spline of an open curve
        # than for other cases.

        if ( ( $i == ( $numPoints - 1 ) ) and !$closed ) {
            $control[4] = 0.667 * $x2 + 0.333 * $x3;
            $control[5] = 0.667 * $y2 + 0.333 * $y3;
            $control[6] = $x3;
            $control[7] = $y3;
        }
        else {
            $control[4] = 0.833 * $x2 + 0.167 * $x3;
            $control[5] = 0.833 * $y2 + 0.167 * $y3;
            $control[6] = 0.5 * $x2 + 0.5 * $x3;
            $control[7] = 0.5 * $y2 + 0.5 * $y3;
        }

        # If the first two points coincide, or if the last
        # two points coincide, then generate a single
        # straight-line segment by outputting the last control
        # point.

        if (   ( abs( $x1 - $x2 ) < 0.0001 and abs( $y1 - $y2 ) < 0.0001 )
            or ( abs( $x2 - $x3 ) < 0.0001 and abs( $y2 - $y3 ) < 0.0001 ) )
        {
            push @retPoints, $control[6];
            push @retPoints, $control[7];
            next;
        }

        #
        # Generate a Bezier spline using the control points.
        TkBezierPoints( \@control, $numSteps, \@retPoints );
    }
    return \@retPoints;
}

1;

# package Tk::Canvas;
# BEGIN {
# *old_create = *create;
# *create = *new_create;
# };
# sub new_create {
#   my $self=shift;
#   print "\$canvas->create(",join(",",map { "'$_'" } @_),");\n";
#   $self->old_create(@_);
# }
# 1;

