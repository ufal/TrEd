#$Id$
#   Tk::Canvas to PDF convertor.
#   Copyright (c) 2003 by Petr Pajas
#
#   This library is free software; you can use, modify, and
#   redistribute it under the terms of GPL - The General Public
#   Licence. Full text of the GPL can be found at
#   http://www.gnu.org/copyleft/gpl.html
#

package Tk::Canvas::PDF;

BEGIN {
  use Exporter;
  use strict;
  use base qw(Tk::Canvas Exporter);
  use vars qw(%media %join %capstyle @EXPORT_OK);
  @EXPORT_OK=(qw(%media));

  eval "use Encode";

  %join = (
	   bevel => 2,
	   miter => 0,
	   round => 1
	  );
  %capstyle = (
	   butt => 0,
	   round => 1,
	   projecting => 2
	  );
  %media = (
	  Letter => [612, 792],
	  LetterSmall => [612, 792],
	  Legal => [612, 1008],
	  Statement => [396, 612],
	  Tabloid => [792, 1224],
	  Ledger => [1224, 792],
	  Folio => [612, 936],
	  Quarto => [610, 780],
	  '7x9' => [504, 648],
	  '9x11' => [648, 792],
	  '9x12' => [648, 864],
	  '10x13' => [720, 936],
	  '10x14' => [720, 1008],
	  Executive => [540, 720],
	  A0 => [2384, 3370],
	  A1 => [1684, 2384],
	  A2 => [1191, 1684],
	  A3 => [842, 1191],
	  A4 => [595, 842],
	  A4Small => [595, 842],
	  A5 => [420, 595],
	  A6 => [297, 420],
	  A7 => [210, 297],
	  A8 => [148, 210],
	  A9 => [105, 148],
	  A10 => [73, 105],
	  B0 => [2920, 4127],
	  B1 => [2064, 2920],
	  B2 => [1460, 2064],
	  B3 => [1032, 1460],
	  B4 => [729, 1032],
	  B5 => [516, 729],
	  B6 => [363, 516],
	  B7 => [258, 363],
	  B8 => [181, 258],
	  B9 => [127, 181],
	  B10 => [91, 127],
	  ISOB0 => [2835, 4008],
	  ISOB1 => [2004, 2835],
	  ISOB2 => [1417, 2004],
	  ISOB3 => [1001, 1417],
	  ISOB4 => [709, 1001],
	  ISOB5 => [499, 709],
	  ISOB6 => [354, 499],
	  ISOB7 => [249, 354],
	  ISOB8 => [176, 249],
	  ISOB9 => [125, 176],
	  ISOB10 => [88, 125],
	  C0 => [2599, 3676],
	  C1 => [1837, 2599],
	  C2 => [1298, 1837],
	  C3 => [918, 1296],
	  C4 => [649, 918],
	  C5 => [459, 649],
	  C6 => [323, 459],
	  C7 => [230, 323]
	 );
}

=item $canvas->pdf(options)

Export cavnas content to PDF. Options:

=over 4

=item -media => media-name

A4,A5,B4,etc. or a bbox array of the form [x1,y1,x2,y2].
Defaults to A4.

=item -ttfont => filename

filename of a TrueType font

=item -psfont => [font-filename, afm-filename]

PostScript font as a pair of filenames of a PostScript font (pfb) and
a PostScript font metrics file (afm)

=item -font => name

PDF corefont filename

=item -file => filename

output filename

=back

=cut


sub __debug {
#  print join "",@_; print "\n";
}

sub new {
  my ($class,%opts)=@_;

  require PDF::API2;
  my $pdf=PDF::API2->new;
  my %fontmap;


  my $encoding=$opts{-encoding} || 'utf8';
  $encoding = 'utf8' if $encoding =~ /^\s*unicode\s*$|^\s*utf-?8\s*$/i;
  $encoding =~ s/^\s*windows/cp/i;
  $encoding =~ s/^\s*iso-?8859(\d+)/iso-8859-$1/i;

  my @media;
  if ($opts{-media}) {
    if (ref($opts{-media})) {
      @media=@{$opts{-media}};
    } elsif (exists $media{$opts{-media}}) {
      @media=(0,0,@{$media{$opts{-media}}});
    } else {
      die "Unknown media type $opts{-media}";
    }
  } else {
    @media=(0,0,@{$media{A4}});
  }
  $pdf->mediabox(@media);
  __debug("Media: @media, Encoding: $encoding\n");
  if ($opts{-fontmap}) {
    foreach my $fn (keys %{$opts{-fontmap}}) {
      if ($opts{-fontmap}->{$fn}->[0] =~ /tt|truetype/i) {
	if ($encoding eq 'utf8') {
	  $fontmap{$fn}=$pdf->ttfont($opts{-fontmap}->{$fn}->[1])->unicode();
	} else {
	  $fontmap{$fn}=$pdf->ttfont($opts{-fontmap}->{$fn}->[1],
				     -encode => $encoding);
	}
      } elsif ($opts{-fontmap}->{$fn}->[0] =~ /ps|postscript/i) {
	$fontmap{$fn}=$pdf->psfont($opts{-fontmap}->{$fn}->[1],$opts{-fontmap}->{$fn}->[2],
				   $encoding ne 'utf8' ?
				   (-encode => $encoding) : ()
				  );
      } elsif ($opts{-fontmap}->{$fn}->[0] =~ /core|builtin/i) {
	$fontmap{$fn}=$pdf->corefont($opts{-fontmap}->{$fn}->[1],
				     $encoding ne 'utf8' ?
				   (-encode => $encoding) : ()
				    );
      } else {
	die "Canvas::PDF->pdf: unknown font type: $opts{-fontmap}->{$fn}";
      }
    }
  }

  my $font;
  my $fontType;
  if ($opts{-ttfont}) {
    $fontType='TT';
    if ($encoding eq 'utf8') {
      $font=$pdf->ttfont($opts{-ttfont})->unicode();
    } else {
      $font=$pdf->ttfont($opts{-ttfont},-encode => $encoding);
    }
  } elsif ($opts{-psfont}) {
    $fontType='PS';
    $font=$pdf->psfont($opts{-psfont}->[0],$opts{-psfont}->[1],
		       $encoding ne 'utf8' ?
		       (-encode => $encoding) : ()
		      );
  } else {
    $fontType='Core';
    $font=$pdf->corefont('Helvetica',
			 $encoding ne 'utf8' ?
			 (-encode => $encoding) : ()
			);
  }

  return bless {
	  Debug => $opts{-debug},
	  Encoding => $encoding,
	  PDF => $pdf,
	  FontMap => \%fontmap,
	  Media => \@media,
	  DefaultFont => $font,
	  DefaultFontType => $fontType
	 },$class;
}


sub pdf {
  my ($canvas,%opts)=@_;
  my $P = __PACKAGE__->new(%opts);
  $P->new_page(%opts);
  $P->draw_canvas($canvas,%opts);
  return $P->finish(%opts);
}

sub new_page {
  my ($P,%opts)=@_;
  $P->{current_page} = $P->{PDF}->page;
}

sub finish {
  my ($P,%opts)=@_;
  if ($opts{-file}) {
    $P->{PDF}->saveas($opts{-file});
    $P->{PDF}->end;
  } else {
    my $string = $P->{PDF}->stringify;
    $P->{PDF}->end;
    return $string;
  }
}

sub draw_canvas {
  my ($P,$canvas,%opts)=@_;
  my $draw = $P->{current_page}->hybrid;
  if ($opts{-transform}) {
    $draw->transform(%{$opts{-transform}});
  }
  if ($opts{-translate}) {
    $draw->translate(@{$opts{-translate}});
  }
  if ($opts{-rotate}) {
    $draw->rotate($opts{-rotate});
  }
  if ($opts{-scale}) {
    $draw->scale(@{$opts{-scale}});
  }
  if ($opts{-skew}) {
    $draw->skew(@{$opts{-skew}});
  }
  if ($opts{-matrix}) {
    $draw->matrix(@{$opts{-matrix}});
  }

  $draw->linedash();
  $draw->linecap(0);
  $draw->linejoin(0);

  my $x = 0;
  my $y = 0;
  my $w = $opts{-width} || $P->{Media}[2];
  my $h = $opts{-height} || $P->{Media}[3];
  my $i;
  foreach my $item ($canvas->find('all')) {
    $draw->save;
    my $type=$canvas->type($item);
    my $state = $canvas->itemcget($item, '-state');
    next if $state eq 'hidden';
    $state = $state eq 'disabled' ? $state : '';
    my @coords=$canvas->coords($item);
    __debug("$type: orig @coords");
    # recalculate coords for bottom/up
    my $even=0;
    foreach (@coords) {
      $_=$h-$_ if $even;
      $even=!$even;
    }
    __debug "$type: new @coords";
    if ($type eq 'text') {
      $draw->textstart;
      my $anchor=$canvas->itemcget($item,'-anchor') || 'center';
      my $color=$canvas->itemcget($item,"-${state}fill");
      next unless defined($color); # transparent text = no text
      my %canvasfont = $canvas->fontActual($canvas->itemcget($item,"-font"));
      __debug "FONT:", (map {" $_ => $canvasfont{$_}, "} keys %canvasfont),"\n";
      my $fn;
      my $font_lookup_string = lc($canvasfont{-family}." ".$canvasfont{-weight}." ".$canvasfont{-slant});
      if ($P->{FontMap}{$font_lookup_string}) {
	$fn=$P->{FontMap}{$font_lookup_string};
      } else {
	warn ("'$font_lookup_string' font isn't mapped\n") if $P->{Debug};
	$fn = $P->{DefaultFont};
      }
      my $fnsize=abs($canvasfont{-size});
      my $text=$canvas->itemcget($item,"-text");
      my $textwidth=$canvas->itemcget($item,"-width");

      # TODO: width
      __debug "$anchor\n";
      $draw->linewidth(1);
      $draw->linedash();
      $draw->font($fn,$fnsize);
      $draw->fillcolor($color);
      my ($posx,$posy)=@coords;
      my $ascent=$fn->ascender*$fnsize/1000;
      my $descent=-$fn->descender*$fnsize/1000;
      my $height=$ascent+$descent;
#      my $height = $fn->capheight*$fnsize/1000;
      my $width;

      if (eval "Encode::is_utf8(\$text)" and not $@) {
	$width = $fn->width_utf8($text)*$fnsize;
      } elsif ($P->{Encoding} eq 'utf8') {
	eval "\$text= Encode::decode('utf8',\$text);";
	$width = $fn->width_utf8($text)*$fnsize;
      } else {
	$width = $fn->width($text)*$fnsize;
      }
      __debug "Width: $width";
      $posx-=$width/2;
      $posy-=$height/2;
      $anchor = '' if $anchor eq 'center';
      if ($anchor =~ /s/) { $posy+=$height/2 }
      elsif ($anchor =~ /n/) { $posy-=$height/2 }
      if ($anchor =~ /e/) { $posx-=$width/2 }
      elsif ($anchor =~ /w/) { $posx+=$width/2 }

      $draw->translate($posx,$posy+$descent);
      __debug "Text: $posx $posy $anchor";
      if (eval "Encode::is_utf8(\$text)" and not $@ or $P->{Encoding} eq 'utf8') {
	$draw->text($text,-utf8 => 1);
      } else {
	$draw->text($text);
      }
      $draw->textend;
    } elsif ($type eq 'line') {
      my $color=$canvas->itemcget($item,"-${state}fill");
      next unless defined $color; # transparent line = no line
      my $join=$canvas->itemcget($item,'-joinstyle');
      my $capstyle=$canvas->itemcget($item,'-capstyle');
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($canvas->itemcget($item,"-${state}dash"),$width);
      @dash=() if @dash<2;
      my $smooth = $canvas->itemcget($item,"-smooth");
      my $arrow = $canvas->itemcget($item,"-arrow");
      my $ars = $canvas->itemcget($item,"-arrowshape") || [8,10,3];

      # TODO: dashoffset
      $draw->linewidth($width);
      $draw->linedash(@dash);
      $draw->linejoin($join{$join});
      $draw->linecap($capstyle{$capstyle});
      $draw->strokecolor($color);
      $draw->fillcolor($color);
      __debug "Line: @coords";
      my @c=@coords;
      # shorten line for arrows
      for (qw(first last)) {
	if ($arrow eq $_ or $arrow eq 'both') {
	  # we should adjust the enpoints to make space for the arrows
	  my ($x1,$y1,$x2,$y2) = $_ eq 'first' ? (0..3) : (-2,-1,-4,-3);
	  my $len = sqrt(($c[$x2]-$c[$x1])**2 + ($c[$y2]-$c[$y1])**2);
	  $c[$x1]+=($c[$x2]-$c[$x1])*0.9*$ars->[0]/$len;
	  $c[$y1]+=($c[$y2]-$c[$y1])*0.9*$ars->[0]/$len;
	}
      }
      # draw line
      if ($smooth and @c>=6) {
	$draw->move(@c[0,1]);
	$draw->curve(@c);
      } else {
	$draw->move(@c[0,1]);
	$draw->line(@c[2..$#c]);
      }
      $draw->stroke;
      # draw arrows
      for (qw(first last)) {
	if ($arrow eq $_ or $arrow eq 'both') {
	  @c=$_ eq 'first' ? @coords[0..3] : @coords[-2,-1,-4,-3];
	  my $angle = 180*atan2($c[2]-$c[0],$c[1]-$c[3])/3.14159265;
	  $draw->save;
	  $draw->translate(@c[0,1]);
	  $draw->linedash();
	  $draw->linecap(0);
	  $draw->linejoin(0);
	  $draw->rotate($_ eq 'first' ? -$angle : $angle-90);
	  $draw->move(0,0);
	  $draw->line($ars->[1],$ars->[2], $ars->[0],0, $ars->[1],-$ars->[2], 0,0);
	  $draw->close;
	  $draw->fillstroke;
	  $draw->restore;
	}
      }
    } elsif ($type eq 'oval') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($canvas->itemcget($item,"-${state}dash"),$width);
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);

      # TODO: dashoffset

      $draw->linewidth($width);
      $draw->linedash(@dash);
      $draw->strokecolor($outlinecolor) if defined $outlinecolor;
      $draw->fillcolor($color) if defined $color;
      my @c = (($coords[2]+$coords[0])/2,($coords[3]+$coords[1])/2,
	       ($coords[2]-$coords[0])/2,($coords[3]-$coords[1])/2);
      __debug "Ellipse: @c";
      $draw->ellipse(@c);
      if (defined($color)) {
	$draw->fillstroke;
      } else {
	$draw->stroke;
      }
    } elsif ($type eq 'polygon') {
      my $width=$canvas->itemcget($item,'-width');
      my $join=$canvas->itemcget($item,'-joinstyle');
      my @dash=_canvas_to_pdf_dash($canvas->itemcget($item,"-${state}dash"),$width);
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);
      my $smooth = $canvas->itemcget($item,"-smooth");
      # TODO: dashoffset
      $draw->linewidth($width);
      $draw->linedash(@dash);
      $draw->linejoin($join{$join});
      $draw->strokecolor($outlinecolor) if defined($color);
      $draw->fillcolor($color) if defined($color);
      __debug "Polygon: @coords";
      if ($smooth) {
	$draw->move(@coords[0,1]);
	$draw->curve(@coords);
	$draw->close();
      } else {
	$draw->rect(@coords);
      }
      if (defined $color) {
	$draw->fillstroke;
      } else {
	$draw->stroke;
      }
    } elsif ($type eq 'rectangle') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($canvas->itemcget($item,"-${state}dash"),$width);
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);
      # TODO: dashoffset
      $draw->linewidth($width);
      $draw->linedash(@dash);
      $draw->linejoin(0);
      $draw->linecap(0);
      $draw->strokecolor($outlinecolor) if defined($outlinecolor);
      $draw->fillcolor($color) if defined($color);
      __debug "Rectangle: @coords";
      $draw->rectxy(@coords);
      if (defined $color) {
	$draw->fillstroke;
      } else {
	$draw->stroke;
      }
    }
    # TODO image, ...
  } continue {
    $draw->restore;
  }
}

sub _canvas_to_pdf_dash {
  my ($dash,$linewidth)=@_;
  my %d=qw(. 40 - 120 , 80 _ 160);
  $dash =~ s/(\d+)/$1*$linewidth/ge;
  $dash =~ s/[-.,_]( *)/$d{$1}." ".40*(1+length($2))." "/ge;
  $dash =~ s/[{}]//;
  return split /\s*/,$dash;
}

package Tk::Canvas;

sub pdf {
  my $self = shift;
  Tk::Canvas::PDF::pdf($self,@_);
}

1;
