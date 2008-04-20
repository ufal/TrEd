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
           -deltay => '(n-p)/2',
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

my @opts = qw(-tag -arrow -arrowshape -width -smooth -fill -dash);
sub DrawArrows {
  my ($node,$styles,$edges,$opts)=@_;
  my $i = 0;
  my %props;
  foreach my $edge (@$edges) {
    my $raise = $edge->{-raise}||$opts->{-raise}||25;
    my $frac  = $edge->{-frac}||$opts->{-frac}||0.12;
    for my $p (@opts) {
      push @{$props{$p}}, $edge->{$p}||$opts->{$p}||'';
    }
    my $target = $edge->{-target};
    my ($dx,$dy)=@$edge{qw(-deltax -deltay)};
    $dx||=0; $dy||=0;
    if ($displayed_nodes_hash{$target}) {
      # same sentence
      my $T="[! FileUserData('DrawArrows')->{\$this}[$i] !]";
      FileUserData('DrawArrows')->{$node}[$i]=$target;
      $i++;
      my $X="(x$T-xn)";
      my $Y="(y$T-yn)";
      my $D="sqrt($X**2+$Y**2)";
      my $c = <<COORDS;

n,n,
(x$T+xn)/2 - $Y*($raise/$D+$frac) + $dx,
(y$T+yn)/2 + $X*($raise/$D+$frac) + $dy,
x$T,y$T

COORDS
      push @{$props{-coords}},$c;
    } elsif ($dx||$dy) { # should be always the same document, if it exists at all
      push @{$props{-coords}},"n,n,n+$dx,n+$dy";
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
