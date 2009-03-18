#-*- cperl -*-

=head1 arrows.inc

This file provides generic support for drawing custom arrows that can be used in any macro context.

=head2 USAGE

Add these lines to your macro context:

  #include <contrib/support/arrows.inc>

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
           -target => GetNodeById($node->{ref}),
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

=cut

#ifdef TRED

{ # arrows.inc
use strict;
my %displayed_nodes_hash;

sub DrawArrows_init {
  return unless CurrentFile();
  for my $node (GetDisplayedNodes()) {
    $displayed_nodes_hash{$node}=1
  }
  FileUserData('DrawArrows',{});
  return;
}

# clear caches
sub DrawArrows_cleanup {
  %displayed_nodes_hash=();
  return unless CurrentFile();
  FileUserData('DrawArrows',undef);
  return;
}

#         -originx => 'xn',
#         -originy => 'yn',
# 	  -deltax => $rotate_dfr_doc,
# 	  -deltay => 30,
# 	  -target => PML::SearchForNodeById($coref)[0],
# 	  -tag => $cortype,
# 	  -arrow =>'last',
# 	  -arrowshape => '16,18,3',
#         -dash => '',
# 	  -width => 1,
# 	  -smooth => 1,
# 	  -fill => CustomColor('arrow_'.$_) },

my @opts = qw(-tag -arrow -arrowshape -width -smooth -fill -dash -hint);
sub DrawArrows {
  my ($node,$styles,$edges,$opts)=@_;
  my $i;
  my %props;
  my $arrows = FileUserData('DrawArrows');
  foreach my $edge (@$edges) {
    my $raise = $edge->{-raise}||$opts->{-raise}||25;
    my $frac  = $edge->{-frac}||$opts->{-frac}||0.12;
    my $target = $edge->{-target};
    my $originx = $edge->{-originx} || 'xn';
    my $originy = $edge->{-originy} || 'yn';
    my ($dx,$dy)=@$edge{qw(-deltax -deltay)};
    $dx||=0; $dy||=0;
    if ($node == $target) {
      # same node
      push @{$props{-coords}},qq($originx,$originy,$originx+$dx,$originy+$dy,$originx+$raise+$dx,$originy+$dy,$originx+$raise+$dx,$originy+$raise+$dy,$originx+$dx,$originy+$raise+$dy,$originx-$raise+$dx,$originy+$raise+$dy,$originx-$raise+$dx,$originy+$dy,$originx,$originy);
    } elsif (defined($target) and $displayed_nodes_hash{$target}) {
      # same sentence
      my $arr = $arrows->{$node}||=[];
      $i=@{$arr};
      my $T="[! FileUserData('DrawArrows')->{\$this}[$i] !]";
      push @$arr,$target;
      $i++;
      my $X="(x$T-$originx)";
      my $Y="(y$T-$originy)";
      my $D="sqrt($X**2+$Y**2)";
      my $c = <<COORDS;

$originx,$originy,
(x$T+$originx)/2 - $Y*($raise/$D+$frac) + $dx,
(y$T+$originy)/2 + $X*($raise/$D+$frac) + $dy,
x$T,y$T

COORDS
      push @{$props{-coords}},$c;
    } elsif ($dx||$dy) { # should be always the same document, if it exists at all
      if ($edge->{-smooth}) {
      my $xT="$originx+$dx";
      my $yT="$originy+$dy";
      my $X="($xT-$originx)";
      my $Y="($yT-$originy)";
      my $D="sqrt($X**2+$Y**2)";
      my $c = <<COORDS;

$originx,$originy,
($xT+$originx)/2 - $Y*($raise/$D+$frac),
($yT+$originy)/2 + $X*($raise/$D+$frac),
$xT,$yT

COORDS

	push @{$props{-coords}},$c;
      } else {
	push @{$props{-coords}},"$originx,$originy,$originx+$dx,$originy+$dy";
      }
    } else {
      next;
    }
    for my $p (@opts) {
      push @{$props{$p}}, ($edge->{$p}||$opts->{$p}||'');
    }
  }
  if (defined($props{-coords}) and @{$props{-coords}}) {
    my %line = GetStyles($styles,'Line');
    $line{-coords} ||= 'n,n,p,p';
    # make sure we don't alter any previous line
    my $lines = scalar($line{-coords}=~/&/g)+1;
    for (@opts) {
      $line{$_}.='&'x($lines-scalar($line{$_}=~/&/g)-1);
    }
    AddStyle($styles,'Line', map {
      $_ => $line{$_}.join('&','',@{$props{$_}})
    } ('-coords',@opts));
  }
  return;
}

} # arrows.inc

#endif
