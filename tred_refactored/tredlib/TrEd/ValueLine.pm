package TrEd::ValueLine;

# value line je tak trocha nesikovne nazvany ten riadok, kde sa zobrazuje veta hore nad zobrazenim stromov...

use strict;
use warnings;

use TrEd::Convert qw{encode};
use TrEd::Basics qw{set_current $EMPTY_STR};
use TrEd::Config qw{$valueLineReverseLines
    $valueLineWrap
    $vLineFont
    $valueLineAlign
    $valueLineHeight
    $valueLineFocusBackground
    $valueLineFocusForeground
};

use Carp;

sub new {
    my ( $class, $val_line_frame, $grp ) = @_;
    my $value_line;

    if ( !ref $val_line_frame || !ref $grp ) {
        croak(
            "Value line constructor needs reference to value line frame and TrEd hash"
        );
    }

    $value_line = $val_line_frame->Scrolled(
        qw/ROText
            -takefocus 0
            -state disabled
            -relief sunken
            -borderwidth 1
            -scrollbars ose/,
        -font   => $TrEd::Config::vLineFont,
        -height => $TrEd::Config::valueLineHeight,
    );

    main::_deleteMenu( $value_line->Subwidget('scrolled')->menu(), 'File' );

    $value_line->tagConfigure(
        'current',
        -background => $TrEd::Config::valueLineFocusBackground,
        -foreground => $TrEd::Config::valueLineFocusForeground,
    );

    for my $modif ( q{}, qw(Shift Control Alt Meta) ) {
        my $m = $modif ? $modif . '-' : '';
        for my $but ( ( map 'Double-' . $_, 1 .. 3 ), 1 .. 3 ) {
            $value_line->bind( qq{<${m}${but}>},
                [ \&_click, $grp, $modif, $but ] );
        }
    }

    eval {    # supported only on some platforms/version of Tk
        $value_line->configure(
            -foreground => $TrEd::Config::valueLineForeground,
            -background => $TrEd::Config::valueLineBackground
        );
    };
    $value_line->BindMouseWheelHoriz();

    my $obj = { value_line => $value_line, };
    return bless $obj, $class;
}

sub value_line_widget {
    my ($self) = @_;
    return $self->{value_line};
}

# value line, UI
# sub set_value_line
sub set_value {
    my ( $self, $rtl, $v ) = @_;

    #  my ($grp,$v)=@_;
    my $vl = $self->{value_line};
    $vl->configure(qw(-state normal));
    $vl->delete( '0.0', 'end' );

#  my $rtl = $grp->{focusedWindow}->treeView->rightToLeft($grp->{focusedWindow}->{FSFile});
    if ( $TrEd::Config::valueLineWrap eq 'word'
        and
        ( $rtl or !defined($rtl) and $TrEd::Config::valueLineReverseLines ) )
    {
        Tk::catch {
            $vl->configure(qw(-wrap none));
        };
        $v = main::reverseWrapLines( $self->{value_line},
            $TrEd::Config::vLineFont, $v, $self->{value_line}->width() - 15 );
    }
    else {
        Tk::catch {
            $vl->configure(
                -wrap => ( $TrEd::Config::valueLineWrap || 'word' ) );
        };
    }
    my @oldtags = grep {/^[a-zA-Z:]+=(?:HASH|ARRAY)/} $vl->tagNames();
    if (@oldtags) {
        $vl->tagDelete(@oldtags);
    }
    if ( ref($v) ) {
        my %tags;
        @tags{ map { @$_[ 1 .. $#$_ ] } @$v } = ();
        foreach my $tag ( keys(%tags) ) {
            if ( $tag =~ /^\s*-/ ) {
                eval {
                    $vl->tagConfigure(
                        $tag => (
                            map { (/^\s*(-[[:alnum:]]+)\s*=>\s*(.*\S)\s*$/) }
                                split( /,/, $tag )
                        )
                    );
                };
                print $@ if $@;
            }
        }
        $vl->Subwidget('scrolled')
            ->insert( 'end', $EMPTY_STR, undef,
            map { ( $_->[0], [ reverse @$_[ 1 .. $#$_ ] ] ) } @$v );
    }
    else {
        $vl->Subwidget('scrolled')->insert( '0.0', $v );
    }
    $vl->tagAdd( 'all', '0.0', 'end' );
    $vl->tagConfigure(
        'all',
        -justify => (
            defined($rtl)
            ? ( $rtl ? 'right' : 'left' )
            : $TrEd::Config::valueLineAlign
        )
    );
    $vl->configure(qw(-state disabled));
    return $v;
}

# value line
sub update_current {
    my ( $self, $win, $node ) = @_;
    return if $win->{noRedraw};
    my $grp = $win->{framegroup};
    my $vl  = $self->{value_line};
    if ( $win == $grp->{focusedWindow} ) {
        eval {
            $vl->tagRemove( 'current', '0.0', 'end' );
            $vl->tagRemove( 'sel',     '0.0', 'end' );
            my $tag = main::doEvalHook( $win, "highlight_value_line_tag_hook",
                $node );
            if ( not defined $tag ) {
                $tag = defined $node ? $node : $EMPTY_STR;
            }
            my ( $first, $last ) = ( '0.0', '0.0' );
            while ( ( $first, $last ) = $vl->tagNextrange( "$tag", $last ) ) {
                $vl->tagAdd( 'current', $first, $last );

                # 		    $tag.".first",
                # 		    $tag.".last",
                #	   );
                $vl->see('current.first');
            }
        };
    }
}

# value line, UI
sub _click {
    my ( $w, $grp, $modif, $but ) = @_;
    my $Ev     = $w->XEvent();
    my $win    = $grp->{focusedWindow};
    my (@tags) = $w->tagNames( $w->index( $Ev->xy ) );
    my $ret;
    if ( $but eq 'Double-1' and $modif eq '' ) {
        main::doEvalHook( $win, "value_line_click_hook", $but, $modif,
            \@tags );
        $ret = main::doEvalHook( $win, "value_line_doubleclick_hook", @tags );
        $ret ||= $EMPTY_STR;
        if ( ref($ret) and UNIVERSAL::DOES::does( $ret, 'Treex::PML::Node' ) )
        {
            TrEd::Basics::set_current( $win, $ret );
            main::ensureCurrentIsDisplayed($win);
            main::centerTo( $win, $ret );
            Tk->break();
            return;
        }
        elsif ( $ret ne 'stop' ) {
            my %nodes = map { $_ => $_ } @{ $win->{Nodes} };
            for my $t ( reverse @tags ) {

                #	print STDERR "tag: $t\n";
                if ( exists $nodes{$t} ) {

                    #  print STDERR "found $t\n";
                    my $node = $nodes{$t};
                    TrEd::Basics::set_current( $win, $node );
                    main::ensureCurrentIsDisplayed($win);
                    main::centerTo( $win, $node );
                    Tk->break();
                    return;
                }
            }

            # fallback
            my $node = $win->{root};
            while ($node) {
                if ( index( join( $EMPTY_STR, @tags ), ${node} ) >= 0 ) {
                    TrEd::Basics::set_current( $win, $node );
                    main::ensureCurrentIsDisplayed($win);
                    main::centerTo( $win, $node );
                    Tk->break();
                    return;
                }
                $node = $node->following();
            }
        }
    }
    else {
        main::doEvalHook( $win, "value_line_click_hook", $but, $modif,
            \@tags );
    }
    Tk->break();
}

# sub get_value_line
#TODO: named args?
sub get_value_line {
    my ( $self, $win, $fsfile, $no, $no_numbers, $tags, $type ) = @_;
    my $vl;
    if ($fsfile) {
        $vl = main::doEvalHook( $win, "get_value_line_hook", $fsfile, $no,
            $type );
        if ( defined($vl) ) {
            if ( ref($vl) ) {
                unless ($tags) {

# important: encode inside - required by arabic, otherwise the text gets remixed
                    $vl = join $EMPTY_STR,
                        map { TrEd::Convert::encode( $_->[0] ) } @$vl;
                }
                else {
                    $vl = [
                        map { $_->[0] = TrEd::Convert::encode( $_->[0] ); $_ }
                        grep { $_->[0] ne $EMPTY_STR } @$vl
                    ];
                }
            }
            else {
                $vl = TrEd::Convert::encode($vl);
            }
        }
        else {
            $vl = $win->treeView->value_line( $fsfile, $no, $no_numbers,
                $tags, $win );
        }
    }
    else {
        $vl = $EMPTY_STR;
    }
    return $vl;
}

# value line
# sub update_value_line
sub update {
    my ( $self, $grp ) = @_;
    my $win = $grp->{focusedWindow}; # only focused window uses the value line
    return if $win->{noRedraw};
    main::update_tree_pos($grp);
    my $fsfile = $win->{FSFile};
    my $rtl    = $win->treeView()->rightToLeft($fsfile);
    my $vl     = $self->set_value(
        $rtl,
        $self->get_value_line(
            $win, $fsfile, $win->{treeNo}, 1, 1, 'value_line'
        )
    );
    $self->update_current( $win, $win->{currentNode} );
    return $vl;
}

1;
