package TrEd::Window;

use Tk;
use TrEd::TreeView;
use Tk::Separator;
use strict;
use Carp;

use TrEd::Stylesheet;
use TrEd::Config qw{$tredDebug $stippleInactiveWindows};

# options
# Nodes, root, treeView, FSFile, treeNo, currentNode
sub new {
    my $self  = shift;
    my $class = ref($self) || $self;
    my $new   = { treeView => shift, redrawn => 0, @_ };
    bless $new, $class;
    return $new;
}

sub treeView    { return $_[0]->{treeView} }
sub FSFile      { return $_[0]->{FSFile} }
sub treeNo      { return $_[0]->{treeNo} }
sub currentNode { return $_[0]->{currentNode} }

sub DESTROY {
    my ($self) = @_;
    undef $self->{treeView};
}

#TODO: addition from Utils/Stylesheet
# was Utils::applyWindowStylesheet
sub apply_stylesheet {
    my ( $self, $stylesheet ) = @_;
    return unless $self;
    my $s = $self->{framegroup}->{stylesheets}->{$stylesheet};
    if ( $stylesheet eq TrEd::Stylesheet::STYLESHEET_FROM_FILE() ) {
        $self->{treeView}->set_patterns(undef);
        $self->{treeView}->set_hint(undef);
    }
    else {
        if ($s) {
            $self->{treeView}->set_patterns( $s->{patterns} );
            $self->{treeView}->set_hint( \$s->{hint} );
        }
    }
    $self->{stylesheet} = $stylesheet;
}

#######################################################################################
# Usage         : $win->set_current_file($fsfile)
# Purpose       : Set tree number, current node and FSFile for Window $win to values
#                 obtained from $fsfile
# Returns       : Undef/empty list
# Parameters    : TrEd::Window ref $win -- ref to TrEd::Window object which is to be altered
#                 Treex::PML::Document ref $fsfile -- ref to Document which is set as current for the Window
# Throws        : No exception
# Comments      : If $fsfile is not defined, all the beforementioned values are set to undef.
#                 If Windows is focused, session status is updated.
# See Also      : is_focused(), fsfileDisplayingWindows()
# was main::setWindowFile
sub set_current_file {
    my ( $self, $fsfile ) = @_;
    $self->{FSFile} = $fsfile;
    if ( defined $fsfile ) {
        $self->{treeNo} = $fsfile->currentTreeNo() || 0;
        $self->{currentNode} = $fsfile->currentNode();
    }
    else {
        $self->{treeNo}      = undef;
        $self->{currentNode} = undef;
    }
    if ( $self->is_focused() ) {
        main::update_session_status( $self->{framegroup} );
    }
    return;
}

#######################################################################################
# Usage         : $win->is_focused()
# Purpose       : Find out whether $win Window is currently focused
# Returns       : 1 if the Window $win is focused, 0 otherwise
# Parameters    : TrEd::Window ref $win -- ref to TrEd::Window object which is tested for focus
# Throws        : No exception
# Comments      :
# See Also      :
sub is_focused {
    my ($self) = @_;
    return $self eq $self->{framegroup}->{focusedWindow} ? 1 : 0;
}

sub toplevel {
    my ($self) = @_;
    return $self->canvas()->toplevel();
}

# for user's comfort
sub canvas {
    my ($self) = @_;
    return if ( !ref $self || !ref $self->{treeView} );
    return $self->{treeView}->canvas();
}

sub canvas_frame {
    my ( $self, $canvas ) = @_;
    $canvas ||= $self->canvas();
    my $frame = undef;
    if ( ref($canvas) ) {
        my %pi = $canvas->packInfo();
        $frame = $pi{-in};
    }
    return $frame;
}

sub contains {
    my ( $self, $w ) = @_;
    return
           $w eq $self->treeView
        || $w eq $self->canvas()
        || $w eq $self->canvas()->Subwidget('scrolled')
        || $w eq $self->canvas_frame();
}

# this can work as a class method as well
sub remove_split {
    my ( $self, $canvas ) = @_;
    $canvas ||= $self->canvas();
    return if !$canvas;
    my $frame = $self->canvas_frame($canvas);
    my $brother_canvas;
    my $pframe;
    {
        my %pi = $frame->packInfo();
        $pframe = $pi{-in};
    }
    return unless $pframe;
    my $wd = $pframe->width;
    my $ht = $pframe->height;
    my $separator
        = ( grep { ref($_) eq 'Tk::Separator' } $pframe->packSlaves() )[0];
    if ($separator) {
        $pframe->GeometryRequest( $wd, $ht );
        $pframe->configure( -width => $wd, -height => $ht );
        $frame->packForget();
        $canvas->packForget();
        $separator->packForget();
        $separator->destroy();
        undef $separator;
        $frame->destroy();
        undef $frame;
        my $brother = ( $pframe->packSlaves() )[0];

        if ($brother) {

            # repack all widgets from $brother to pframe
            $brother->packForget();
            my %pi;
            foreach my $bc ( $brother->packSlaves() ) {
                %pi = $bc->packInfo();
                $pi{-in} = $pframe;
                $bc->packForget();
                $bc->pack(%pi);
            }
            $brother->destroy();
            undef $brother;
            my @pc = $pframe->packSlaves();
            my $f;
            while ( $_ = shift @pc ) {
                next if ( $_->isa('Tk::Separator') );
                if ( $_->isa('Tk::Canvas') ) {
                    $brother_canvas = $_;
                    last;
                }
                else {
                    unshift @pc, $_->packSlaves();
                }
            }
            unless ($brother_canvas) {
                warn "No canvas found in the other frame!!\n";
            }
        }
        else { warn "No other canvas found in the frame!!\n"; }
    }
    return ( $canvas, $brother_canvas );
}

BEGIN {
    *remove_canvas = \&remove_split;
}

sub canvas_destroy {
    my ($self) = @_;
    my ( $canvas, $brother_canvas ) = $self->remove_canvas();
    $canvas->destroy() if ($canvas);
    return $brother_canvas;
}

sub frame_widget {
    my ( $self, $w, $frame_options, $pack_options ) = @_;

    return if !ref $w;
    my @fo = @$frame_options if ref($frame_options);
    my @po = @$pack_options  if ref($pack_options);
    my $top   = $w->toplevel;
    my $frame = $top->Frame(@fo);
    $w->pack(
        -in     => $frame,
        -expand => 'yes',
        -fill   => 'both',
        @po
    );
    $w->Tk::Widget::raise();
    return $frame;
}

sub split_frame {
    my $self = shift;
    $self->splitPack( $self->canvas(), @_ );
}

sub splitPack {
    my ( $self, $c, $newc, $ori, $ratio ) = @_;
    my $frame = $self->canvas_frame($c);
    my $top   = $c->toplevel;
    my $owd   = $frame->width;
    my $oht   = $frame->height;
    my ( $side, $fill, $wd, $ht );
    $ratio ||= 0.5;
    $ratio = -$ratio if $ori eq 'horiz';

    if ( $ori eq 'horiz' ) {
        $ht = $oht * abs($ratio) - 16;
        $oht -= $ht + 16;
        $wd   = $owd;
        $side = 'bottom';
        $fill = 'x';
    }
    else {
        $wd = $owd * abs($ratio) - 16;
        $owd -= $wd + 16;
        $ht   = $oht;
        $side = 'left';
        $fill = 'y';
    }
    my ( $cf, $newcf, $sep );

    $c->packForget();
    $c->configure( -width => $owd, -height => $oht );
    $newc->configure( -width => $wd, -height => $ht );

    $c->GeometryRequest( $owd, $oht );
    $cf = $self->frame_widget( $c, [], [qw(-side left)] );

    $newc->GeometryRequest( $wd, $ht );
    $newcf = $self->frame_widget( $newc, [], [qw(-side left)] );
    if ( $ratio < 0 ) {

        # SWAPPING the pack order
        my $swap = $cf;
        $cf    = $newcf;
        $newcf = $swap;
    }

    $sep = $top->Separator(
        -widget1     => $cf,
        -widget2     => $newcf,
        -orientation => $ori,
    );
    $sep->configure( -side => 'bottom' );

    $cf->pack( -in => $frame, -side => $side, qw(-expand yes -fill both) );
    $sep->pack(
        -in   => $frame,
        -side => $side,
        -fill => $fill,
        qw(-expand no)
    );
    $newcf->pack( -in => $frame, -side => $side, qw(-expand yes -fill both) );
    $frame->idletasks;    # pack first
    if ( $ori eq 'horiz' ) {
        $sep->delta_height( $ht - $newc->height );
    }
    else {
        $sep->delta_width( $wd - $newc->width );
    }
    $frame->idletasks;
    return $sep;
}

# Return the index of the last file in the current filelist.
# was main::lastFileNo
sub last_file_no {
    my ($self) = @_;
    return $self->{currentFilelist}
        ? $self->{currentFilelist}->file_count() - 1
        : -1;
}

# Return the index of the current file in the current filelist.
# was main::currentFileNo
sub current_file_no {
    my ($self) = @_;
    return $self->{currentFileNo};
}

#######################################################################################
# Usage         : $win->get_nodes($no_redraw)
# Purpose       : Load the root, nodes and current node of tree number $win->{treeNo}
#                 from current file in the Window $win into $win->{root}, $win->{Nodes}
#                 and $win->{currentNode} hash values
# Returns       : Undef/empty list
# Parameters    : scalar $no_redraw     -- indicator that forbids redrawing during the function
# Throws        : No exception
# Comments      : Updates TrEd::ValueLine if $no_redraw is not set.
# See Also      :
# was main::get_nodes_win
sub get_nodes {
    my ( $self, $no_redraw ) = @_;
    if ( $self->{FSFile} ) {

        # set hook
        $TrEd::TreeView::on_get_nodes = [ \&main::onGetNodes, $self ];
        if ( $self->{treeNo} < 0 and $self->{FSFile}->lastTreeNo >= 0 ) {
            $self->{treeNo} = 0;
        }
        $self->{root} = $self->{FSFile}->treeList->[ $self->{treeNo} ];

        # here the assignment happens
        ( $self->{Nodes}, $self->{currentNode} )
            = $self->treeView->nodes( $self->{FSFile}, $self->{treeNo},
            $self->{currentNode} );
    }
    else {
        print "no nodes to get\n" if $tredDebug;
        $self->{root}        = undef;
        $self->{Nodes}       = [];
        $self->{currentNode} = undef;
    }
    if ( $self->is_focused() and !$no_redraw ) {
        my $grp = main::cast_to_grp($self);    #->{framegroup};
        $grp->{valueLine}->update($grp);

        #TrEd::ValueLine::update( $self->{framegroup} );
    }
    return;
}

# was main::getWindowPatterns
sub get_patterns {
    my ($self) = @_;
    if ( $self->treeView->patterns() ) {
        return @{ $self->treeView->patterns() };
    }
    elsif ( $self->{FSFile} ) {
        return $self->{FSFile}->patterns();
    }
    else {
        return ();
    }
}

# was main::getWindowHint
sub get_hint {
    my ($win) = @_;
    if ( defined( $win->treeView->hint ) ) {
        return ${ $win->treeView->hint() };
    }
    elsif ( $win->{FSFile} ) {
        return $win->{FSFile}->hint();
    }
    else {
        return;
    }
}

# was main::getWindowContextRE
sub get_contex_RE {
    my ($win)      = @_;
    my $grp        = cast_to_grp($win);
    my $stylesheet = $win->{stylesheet};
    if ( exists( $grp->{stylesheets}->{$stylesheet} ) ) {
        return $grp->{stylesheets}->{$stylesheet}->{context};
    }
    else {
        return;
    }
}

#######################################################################################
# Usage         : $win->redraw()
# Purpose       : Redraw Window $win
# Returns       : Undef/empty list
# Parameters    : TrEd::Window ref $win -- reference to TrEd::Window object
# Throws        : No exception
# Comments      : Runs these hooks:
#                   $TrEd::TreeView::on_get_root_style
#                   $TrEd::TreeView::on_get_node_style
#                   $TrEd::TreeView::on_redraw_done
# See Also      : TrEd::TreeView::redraw()
#TODO:          Also look at the undo stuff after redraw
sub redraw {
    my ($self) = @_;
    return if ( $self->{noRedraw} or $main::insideEval );
    print STDERR "redraw $self\n" if $tredDebug;

    #------------------------------------------------------------
    #{
    #use Benchmark;
    #my $t0= new Benchmark;
    #for (my $i=0;$i<=50;$i++) {
    #------------------------------------------------------------
    $TrEd::TreeView::on_get_root_style = [ \&main::onGetRootStyle, $self ];
    $TrEd::TreeView::on_get_node_style = [ \&main::onGetNodeStyle, $self ];
    $TrEd::TreeView::on_redraw_done    = [ \&main::onRedrawDone,   $self ];
    my $vl;

    my $grp = main::cast_to_grp($self);

    if ( $self->{FSFile} and $self->treeView()->get_drawSentenceInfo() ) {
        $vl
            = $grp->{valueLine}
            ->get_value_line( $self, $self->{FSFile}, $self->{treeNo}, 1, 0,
            'html' );
    }

    # may be used to check that this function was called (e.g. during a hook),
    # do not forget to reset the value first
    $self->{redrawn}++;

    $self->treeView->redraw(
        $self->{FSFile},
        $self->{currentNode},
        $self->{Nodes},

        # CHANGE THIS (this is just for printing) :
        ( defined($vl) ? $vl : q{} ),
        (   $stippleInactiveWindows
            ? ( ( $self == $grp->{focusedWindow} )
                ? 'hidden'
                : 'normal'
                )
            : undef
        ),
        $self
    );
    if ( $self->{FSFile} ) {
        TrEd::Window::TreeBasics::set_current( $self, $self->{currentNode} );
        $self->ensure_current_is_displayed();
    }
    $TrEd::TreeView::on_get_root_style = undef; #forget the reference on $self
    $TrEd::TreeView::on_get_node_style = undef;
    $TrEd::TreeView::on_redraw_done    = undef;

    if ( $self == $grp->{focusedWindow} ) {
        main::saveFileStateUpdate($self);
        TrEd::Undo::reset_undo_status($self);
        main::resetTreePosStatus($grp);
        $self->{framegroup}->{statusLine}->update_status($self);
        main::updateNodeMenu($self);
    }

    #------------------------------------------------------------
    #}
    #my $t1= new Benchmark;
    #my $td= timediff($t1, $t0);
    #print "redraw: the code took:",timestr($td),"\n";
    #}
    #------------------------------------------------------------

    return;
}

# was main::ensureCurrentIsDisplayed
sub ensure_current_is_displayed {
    my ($self) = @_;
    return unless $self->{FSFile};
    my $node = $self->{currentNode};
    while ( $node and !$self->treeView->node_is_displayed($node) ) {
        $node = $node->parent;
    }
    if ( !$node ) {
        my $rtl = TrEd::Window::TreeBasics::tree_is_reversed($self);
        if ($rtl) {
            $node = $self->{Nodes}->[-1];
        }
        else {
            $node = $self->{Nodes}->[0];
        }
    }
    if ( $node and $node != $self->{currentNode} ) {
        TrEd::Window::TreeBasics::set_current( $self, $node );
    }
}

1;

