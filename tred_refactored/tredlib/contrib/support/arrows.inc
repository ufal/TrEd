#-*- cperl -*-

=head1 arrows.inc

This file provides generic support for drawing custom arrows that can be used in any macro context.

=head2 USAGE

Add these lines to your macro context:

  #include <contrib/support/arrows.inc>
  #include <contrib/pml/PML.mak>

  sub root_style_hook {
    DrawArrows_init();
    # ...
  }
  sub after_redraw_hook {
    DrawArrows_cleanup();
    # ...
  }
  sub node_style_hook {
     my ($node,$styles) = @_;
     DrawArrows($node,$styles,
       [ {
           # an arrow with a target
           -target => PML::GetNodeByID($node->{ref}),
           # other options: -tag -arrow -arrowshape -width -smooth -fill -dash
         },
         {
           # an arrow without a target
           -deltax => 10,
           -deltay => '(yn-yp)/2',
           # ...
         },
         {
           # an arrow with modified origin
           -originx => 'xn+10',
           -originy => 'yn+10',
           # ...
         },
      ],
      {
        # options common to all edges
      });
    #...
  }

=head2 DESCRIPTION

This file provides a function DrawArrows which can be called from the node_style_hook to extra
arrows from the current node to some other nodes (or relative coordinates).
The USAGE section above shows a full example.

In the macros for your annotation context, you have to:

=over 5

=item 1.

include <contrib/support/arrows.inc>

=item 2.

define the root_style_hook which calls DrawArrow_init() to initialize caches.

=item 3.

define an after_redraw_hook which calls DrawArrow_cleanup() to clean-up caches.

=item 4.

define a node_style_hook which calls DrawArrows with the following arguments

  DrawArrows($node,$styles,\@arrow_definitions,\%common_arrow_options)

The first two arguments ($node and $styles) are the first two arguments passed to the node_style_hook by TrEd.
The third argument,
\@arrow_definitions, is an ARRAY reference containing definitions of
the arrows to draw. Each arrow definition is a HASH reference defining the target node or target coordinates for the other end
of the arrow and style options. Style options common to all arrows can be also passed in the optional HASH reference passed as the last argument
\%common_arrow_options.

=back

=head3 Arrow definitions and styles

Eeach arrow definition (passed in the \@rrow_definitions list to the
DrawArrows) is a HASH reference consisting of some arrow options.
With the exception of -target, -originx, -originy, -deltax, -deltay,
these options can also be passed as \%common_arrow_options to
DrawArrows.

=over 8

=item -target

the target node.

If no target is specified, the target coordinates default to the
coordinates of the current node and the flags -deltax and -deltay must
be used to specify the target coordinates.

=item -originx

the x-coordinate of the origin (defaults to 'xn' - the x-coordinate of the current node)

=item -originy

the y-coordinate of the origin (defaults to 'yn' - the y-coordinate of the current node)

=item -deltax

value to add to the x-coordinate of the target

=item -deltay

value to add to the y-coordinate of the target

=item -smooth

1 to make the arrow a smoothed curve (see also -raise and -frac)

=item -frac

Defaults to 0.12. When a curved arrow is drawn (i.e. -smooth => 1 was
given), this value defines the 'lift' of the arrow as a fraction of
the length of the straight line connecting the start and end of the
arrow. 0 means no lift (straight line). The signum of the value
decides the orientation of the lift.

=item -raise

Defaults to 25. An absolute value added to the 'lift' of an arrow.

=item -arrow

one of 'first', 'last', 'both', 'none' (where to put the the arrow head)

=item -arrowshape

a comma-separated list of three integers defining the shape of the arrow head (see Tk::Canvas manual)

=item -dash

a comma-separated list of integers (even number) specifying the lengths of dashes and spaces between them

=item -width

width of the line

=item -fill

color of the line (either the color name or a '#rrggbb' hex code)

=item -hint

a tooltip that is displayed when the user hovers mouse over the arrow

=item -tag

a comma-separated list of tags associated with the arrow on the
canvas; tags can be used for varius purposes, e.g. to raise or lower
objects on the Tk::Canvas (see the stackOrder instruction in
L<http://ufal.ms.mff.cuni.cz/tred/ar01s10.html>).
they are also used as classes when exporting to SVG.

=item -decoration

decoration of the arrow (see description of the Line-decoration style
instruction in L<http://ufal.ms.mff.cuni.cz/tred/ar01s10.html>).

=back

=cut

#ifdef TRED

{    # arrows.inc
    use strict;
    my %displayed_nodes_hash;

    sub DrawArrows_init {
        return if !CurrentFile();
        for my $node ( GetDisplayedNodes() ) {
            $displayed_nodes_hash{$node} = 1;
        }
        FileUserData( 'DrawArrows', {} );
        return;
    }

    # clear caches
    sub DrawArrows_cleanup {
        %displayed_nodes_hash = ();
        return if !CurrentFile();
        FileUserData( 'DrawArrows', undef );
        return;
    }

    my @opts
        = qw(-tag -arrow -arrowshape -width -smooth -fill -dash -hint -decoration);

    sub DrawArrows {
        my ( $node, $styles, $edges, $opts ) = @_;
#        use Data::Dumper;
#        $Data::Dumper::Maxdepth = 1;
#        print 'grp in draw arrows: ' . Dumper($grp);
#        print 'this in draw arrows: ' . Dumper($this);
        my $i;
        my %props;
        my $arrows = FileUserData('DrawArrows');
        foreach my $edge (@{$edges}) {
            my $raise = $edge->{-raise} || $opts->{-raise} || 25;
            my $frac  = $edge->{-frac}  || $opts->{-frac}  || 0.12;
            my $target  = $edge->{-target};
            my $originx = $edge->{-originx} || 'xn';
            my $originy = $edge->{-originy} || 'yn';
            my ( $dx, $dy ) = @$edge{qw(-deltax -deltay)};
            $dx ||= 0;
            $dy ||= 0;

            if ( $node == ($target // -1) ) {

                # same node
                push @{ $props{-coords} }, <<"COORDS";
$originx,$originy,
$originx+$raise+$dx,$originy-$raise/2+$dy,
$originx+2*$raise+$dx,$originy+$dy,
$originx+$raise+$dx,$originy+$raise/2+$dy,
$originx,$originy
COORDS
            }
            elsif ( defined($target) and $displayed_nodes_hash{$target} ) {

                # same sentence
                my $arr = $arrows->{$node} ||= [];
                $i = @{$arr};
                my $T = "[! FileUserData('DrawArrows')->{\$this}[$i] !]";
                push @{$arr}, $target;
                $i++;
                my $X = "(x$T-$originx)";
                my $Y = "(y$T-$originy)";
                my $D = "sqrt($X**2+$Y**2)";
                my $c = <<"COORDS";
$originx,$originy,
(x$T+$originx)/2 - $Y*($raise/$D+$frac) + $dx,
(y$T+$originy)/2 + $X*($raise/$D+$frac) + $dy,
x$T,y$T
COORDS
                push @{ $props{-coords} }, $c;
            }
            elsif ( $dx || $dy )
            {    # should be always the same document, if it exists at all
                if ( $edge->{-smooth} ) {
                    my $xT = "$originx+$dx";
                    my $yT = "$originy+$dy";
                    my $X  = "($xT-$originx)";
                    my $Y  = "($yT-$originy)";
                    my $D  = "sqrt($X**2+$Y**2)";
                    my $c  = <<"COORDS";
$originx,$originy,
($xT+$originx)/2 - $Y*($raise/$D+$frac),
($yT+$originy)/2 + $X*($raise/$D+$frac),
$xT,$yT
COORDS

                    push @{ $props{-coords} }, $c;
                }
                else {
                    push @{ $props{-coords} },
                        "$originx,$originy,$originx+$dx,$originy+$dy";
                }
            }
            else {
                next;
            }
            for my $p (@opts) {
                push @{ $props{$p} }, ( $edge->{$p} || $opts->{$p} || q{} );
            }
        }
        if ( defined $props{-coords} && @{ $props{-coords} } ) {
            my %line = GetStyles( $styles, 'Line' );
            $line{-coords} ||= 'n,n,p,p';

            # make sure we don't alter any previous line
            my $lines = scalar( $line{-coords} =~ /&/g ) + 1;
            for (@opts) {
                my $ampersands = defined $line{$_} 
                               ? scalar( $line{$_} =~ /&/g )
                               : 0;
                $line{$_}
                    .= q{&} x ( $lines - $ampersands - 1 );
            }
            AddStyle( $styles, 'Line',
                map { $_ => $line{$_} . join(q{&}, q{}, @{ $props{$_} }) }
                    ( '-coords', @opts ) );
        }
        return;
    }

}    # arrows.inc

#endif
