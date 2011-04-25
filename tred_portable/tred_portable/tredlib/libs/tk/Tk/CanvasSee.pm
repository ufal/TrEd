package Tk::CanvasSee;
# pajas@ufal.mff.cuni.cz          22 èen 2007

# this package adds $canvas->see(tag-or-item) method for scrolled canvases

use Tk::Canvas;
use strict;
use Carp;
{
no integer;
sub Tk::Canvas::see {
  my ($c, $item,$x_aura,$y_aura) = @_;
  my @s = $c->cget('-scrollregion');
  return unless defined $s[0];
  my @bbox = $c->bbox( $item );
  my @xview = $c->xview;
  my @yview = $c->yview;
  my ($w,$h) = ($s[2]-$s[0], $s[3]-$s[1]);
  my @view = ($s[0]+$w*$xview[0],
	      $s[1]+$h*$yview[0],
	      $s[0]+$w*$xview[1],
	      $s[1]+$h*$yview[1]);
  if ($x_aura<=1) {
    $x_aura*=$w*($xview[1]-$xview[0]);
  }
  if ($y_aura<=1) {
    $y_aura*=$h*($yview[1]-$yview[0]);
  }
  if ($bbox[0]<$view[0] or $bbox[2]-$bbox[0]>$view[2]-$view[0]) {
    # west-most corner off view or bbox too wide
    $c->xviewMoveto(($bbox[0]-$x_aura-$s[0])/$w) if $w;
  } elsif ($bbox[2]>$view[2]) {
    $c->xviewMoveto( ($bbox[2]+$x_aura-$s[0]-($view[2]-$view[0]))/$w) if $w;
  }
  if ($bbox[1]<$view[1] or $bbox[3]-$bbox[1]>$view[3]-$view[1]) {
    # north-most corner off view or bbox too high
    $c->yviewMoveto(($bbox[1]-$y_aura-$s[1])/$h) if $h;
  } elsif ($bbox[3]>$view[3]) {
    $c->yviewMoveto( ($bbox[3]+$y_aura-$s[1]-($view[3]-$view[1]))/$h) if $h;
  }
  return 1;
}
sub Tk::Canvas::scrollWidth {
  my ($c)=@_;
  my @s = $c->cget('-scrollregion');
  return unless defined $s[0];
  return $s[2]-$s[0];

}
sub Tk::Canvas::scrollHeight {
  my ($c)=@_;
  my @s = $c->cget('-scrollregion');
  return unless defined $s[0];
  return $s[3]-$s[1];

}
sub Tk::Canvas::xviewCoord {
  my ($c,$x,$new)=@_;
  my @s = $c->cget('-scrollregion');
  my $w = $s[2]-$s[0];
  return $x unless $w;
  my @xview = $c->xview;
  if (@_==2) {
    my $vx = $x-$s[0]-$xview[0]*$w;
    return $vx;
  } elsif (@_==3) {
    return $c->xviewMoveto(($x-$s[0]-$new)/$w);
  } else {
    croak("Tk::Canvas::xviewCoord: wrong number of arguments: expected 1 or 2");
  }
}
sub Tk::Canvas::yviewCoord {
  my ($c,$y,$new)=@_;
  my @s = $c->cget('-scrollregion');
  my $h = $s[3]-$s[1];
  return $y unless $h;
  my @yview = $c->yview;
  my $vy = $y-$s[1]-$yview[0]*$h;
  if (@_==2) {
    return $vy;
  } elsif (@_==3) {
    return $c->yviewMoveto(($y-$s[1]-$new)/$h);
  } else {
    croak("Tk::Canvas::yviewCoord: wrong number of arguments: expected 1 or 2");
  }
}

sub Tk::Canvas::xviewCenter {
  my $c = shift;
  my $w = $c->scrollWidth;
  return unless $w;
  my ($item, $x);
  if (@_==1) {
    $item = shift;
  } elsif (@_>1) {
    my $what = shift;
    if ($what eq 'coord') {
      $x = shift;
    } elsif ($what eq 'item' or $what eq 'withtag') {
      $item = shift;
    } elsif ($what eq 'fraction') {
      $x = $what*$w;
    } else {
      croak("Tk::Canvas::xviewCenter: wrong arguments: expected either 0 arguments (get xview center), or 1 argument (tag_or_ID), or 2 arguments ".
	      "(item => tag_or_ID or x => x-coord or xview => float)");
    }
  }
  my @xview = $c->xview;
  return $w*($xview[1]+$xview[0])/2 unless defined($x) or defined($item);
  if (defined $item) {
    my @bbox = $c->bbox( $item );
    $x=($bbox[2]+$bbox[0])/2;
  }
  return unless $w;
  my $move_to = $x/$w-($xview[1]-$xview[0])/2;
  $move_to=0 if $move_to < 0;
  return $c->xviewMoveto($move_to);
}
sub Tk::Canvas::yviewCenter {
  my $c = shift;
  my $h = $c->scrollHeight;
  return unless $h;
  my ($item, $y);
  if (@_==1) {
    $item = shift;
  } elsif (@_>1) {
    my $what = shift;
    if ($what eq 'coord') {
      $y = shift;
    } elsif ($what eq 'item' or $what eq 'withtag') {
      $item = shift;
    } elsif ($what eq 'fraction') {
      $y = $what*$h;
    } else {
      croak("Tk::Canvas::yviewCenter: wrong arguments: expected either 0 arguments (get yview center), or 1 argument (tag_or_ID), or 2 arguments ".
	      "(item => tag_or_ID or y => y-coord or yview => float)");
    }
  }
  my @yview = $c->yview;
  return $h*($yview[1]+$yview[0])/2 unless defined($y) or defined($item);
  if (defined $item) {
    my @bbox = $c->bbox( $item );
    $y=($bbox[3]+$bbox[1])/2;
  }
  return unless $h;
  my $move_to = $y/$h-($yview[1]-$yview[0])/2;
  $move_to = 0 if $move_to < 0;
  return $c->yviewMoveto($move_to);

}

}
1;
__END__

=head1 NAME

Tk::CanvasSee - make sure a given canvas item is in the viewed part on a scrolled canvas

=head1 SYNOPSIS

   use Tk::CanvasSee;

   $canvas = $mw->Scrolled('Canvas',...)->pack();
   ...
   # adjust xview and yview so that this item is visible
   $canvas->see($item_or_tag);

   $w = $canvas->scrollWidth;  # width of the scrollregion
   $h = $canvas->scrollHeight; # height of the scrollregion

   # get x coord of the center of the visible part of the canvas
   $xview_center = $canvas->xviewCenter();

   # adjust xview so that the visible part of the canvas is
   # horizontally centered around the object 'foo' (i.e. the center of
   # its bbox)
   $canvas->xviewCenter(withtag => 'foo');

   # adjust xview so that the visible part of the canvas is
   # horizontally centered around the canvas X coord 140
   $canvas->xviewCenter(coord => 140);

   # adjust xview so that the part left from the center
   # of the visible  part of the canvas forms 30% of the
   # canvas scrollregion width (scrolledWidth)
   $canvas->xviewCenter(fraction => .3);

   # get the horizontal distance of the point on canvas X coord 100
   # from the left side of the visible part of the canvas
   $x = $canvas->xviewCoord(100);

   # adjust xview so that the distance of the point on canvas X coord 100
   # from the left side of the visible part of the canvas is $x+10
   $canvas->xviewCoord(100,$x+10);

   # Similarly:
   $yview_center = $canvas->yviewCenter();
   $canvas->yviewCenter(withtag => 'foo');
   $canvas->yviewCenter(coord => 140);
   $canvas->yviewCenter(fraction => .3);
   $y = $canvas->yviewCoord(100);
   $canvas->yviewCoord(100,$y+10);

=head1 DESCRIPTION

=over 4

=item $canvas->see($tag_or_ID)

This function adjusts the xview and yview of a scrolled canvas so that
the bounding box for given item(s) is contained in (or, if larger,
covering) the viewed part of a scrolled canvas.

=item $canvas->scrollWidth

Return width of the canvas' scrollregion.

=item $canvas->scrollHeight

Return height of the canvas' scrollregion.

=item $canvas->xviewCenter();

Return x coord of the center of the visible part of the canvas.

=item $canvas->xviewCenter(withtag => $tag_or_ID);

Adjust xview so that the visible part of the canvas is horizontally
centered around the center of the bbox of the item(s) $tag_or_ID.

=item $canvas->xviewCenter(coord => $x_coord);

Adjust xview so that the visible part of the canvas is horizontally
centered around a given canvas X coord.

=item $canvas->xviewCenter(fraction => $fraction);

Adjust xview so that the part left from the center of the visible part
of the canvas forms 30% of the canvas scrollregion width (scrolledWidth).
The fraction must be a float between 0 and 1.

=item $canvas->yviewCenter(...)

See xviewCenter(...) above.

=item $canvas->xviewCoord($x_coord)

Return the horizontal distance of the point on a given canvas X coord
from the left side of the visible part of the canvas.

=item $canvas->xviewCoord($x_coord, $xviewCoord)

Adjust xview so that the distance of the point on canvas X $x_coord
from the left side of the visible part of the canvas is $xviewCoord.

=item $canvas->yviewCoord(...)

See xviewCoord(...) above.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

