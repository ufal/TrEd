#$Id: SVG.pm 3945 2009-03-29 22:11:13Z pajas $
#   Tk::Canvas to SVG convertor.
#   Copyright (c) 2009 by Petr Pajas
#
#   This library is free software; you can use, modify, and
#   redistribute it under the terms of GPL - The General Public
#   Licence. Full text of the GPL can be found at
#   http://www.gnu.org/copyleft/gpl.html
#

package Tk::Canvas::SVG;
use strict;
use warnings;

BEGIN {
  use Exporter;
  use Tk::rgb;
  use base qw(Tk::Canvas Exporter);
  use vars qw(%media %join %capstyle @EXPORT_OK);
  @EXPORT_OK=(qw(%media));

  eval "use Encode";

  %join = (
	   bevel => 'bevel',
	   miter => 'miter',
	   round => 'round',
	  );
  %capstyle = (
	   butt => 'butt',
	   round => 'round',
	   projecting => 'square',
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

Export cavnas content to SVG. Options:

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

SVG corefont filename

=item -file => filename

output filename

=back

=cut


sub __debug {
#  print join "",@_; print "\n";
}

sub color2svg {
  my ($color,$grayscale)=@_;
  if ($grayscale) {
    $color = color2gray($color)
  } elsif ($color=~/^#([0-9a-fA-F]{2})[0-9a-fA-F]{2}([0-9a-fA-F]{2})[0-9a-fA-F]{2}([0-9a-fA-F]{2})[0-9a-fA-F]{2}$/) {
    $color=qq{#$1$2$3};
  } else {
    $color = lc($color);
  }

}

sub color2gray {
  my ($color)=@_;
  unless (ref($color)) {
    if (!defined($color)) {
      return undef;
    } elsif ($color =~ /^#(..)(..)(..)/) {
      $color = [map hex,$1,$2,$3];
    } elsif (exists($Tk::rgb::rgb{$color})) {
      $color = $Tk::rgb::rgb{$color};
    } elsif (exists($Tk::rgb::rgb{lc($color)})) {
      $color = $Tk::rgb::rgb{lc($color)};
    } else {
      warn "unknown color $color\n";
      return 0;
    }
  }
  no integer;
  foreach (@$color) {
    $_=$_ / 255;
    $_=1-(1 - $_ ** 1.5);
    $_=$_ * 255;
  }
  my $gray = int(sqrt($color->[0]**2+$color->[1]**2+$color->[2]**2)/sqrt(3));
  return ("#".(sprintf("%02x",$gray) x 3));
}

sub new {
  my ($class,%opts)=@_;

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
  __debug("Media: @media\n");

  return bless {
	  Debug => $opts{-debug},
	  Pages => [],
	  FontMap => $opts{-fontmap},
	  Media => \@media,
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

  my $svg_page='';
  if ($P->{current_page}) {
    $P->{current_page}->end;
  }
  $P->{current_page} = XML::Writer->new(OUTPUT=>\$svg_page,DATA_INDENT=>1,DATA_MODE=>1,ENCODING=>'utf-8');
  push @{$P->{pages}}, \$svg_page;
}

sub finish {
  my ($P,%opts)=@_;
  if ($P->{current_page}) {
    $P->{current_page}->end;
  }
  if ($opts{-file}) {
    if(@{$P->{pages}}==1) {
      print "Print to $opts{-file}\n";
      open(my $fh, '>:utf8', $opts{-file}) or die "Cannot open file '$opts{-file}' for writing: $!";
      print $fh ${$P->{pages}->[0]};
      close $fh;
    } elsif (@{$P->{pages}}>1) {
      require File::Spec;
      my $dir = $opts{-file};
      unless (-d $dir) {
	mkdir($dir) or die "Cannot create directory '$dir' for multi-page SVG: $!";
      }
      my $fn = File::Spec->catfile($dir,'index.html');
      open(my $fh, '>:utf8', $fn) or die "Cannot open file '$fn' for writing: $!";
      my $format = "page_%03d.svg";
      print_html_template($fh,$opts{-file},scalar(@{$P->{pages}}),$format);
      close $fh;
      for my $i (0..$#{$P->{pages}}) {
	$fn = File::Spec->catfile($dir,sprintf($format,$i));
	open(my $fh, '>:utf8', $fn) or die "Cannot open file '$fn' for writing: $!";
	print $fh ${$P->{pages}->[$i]};
	close $fh;
      }
    }
  } else {
    return join("\n\n<!-- new_page -->\n\n",@{$P->{pages}});
  }
}

sub item_title {
  my ($self,$writer,$title)=@_;
  if (defined($title) and $title=~/\S/) {
    $writer->startTag('title');
    $writer->characters($title);
    $writer->endTag('title');
  }
}
sub draw_canvas {
  my ($self,$canvas,%opts)=@_;

  my @media = @{$canvas->cget('-scrollregion')};
#    @{$self->{Media}};
  my $width = $media[2]-$media[0];
  my $height = $media[3]-$media[1];
  my $writer = $self->{current_page};
  $writer->xmlDecl("UTF-8");
  $writer->startTag('svg',
		 xmlns=>"http://www.w3.org/2000/svg",
		 version=>"1.2",
		 baseProfile=>"tiny",
		 #width=>"${width}",
		 #height=>"${height}",
		 #viewBox=>"@media"
		);
  my $balloon = $opts{-balloon};
  my $hint;
  if ($balloon) {
    $hint = $balloon->GetOption('-balloonmsg',$canvas);
    if ($hint) {
      $writer->startTag('script', type=>"text/ecmascript");
      $writer->characters(<<'SCRIPT');
function set_visibility (id,show) {
  obj = document.getElementById(id);
  if (obj) {
    if (show) {
      obj.setAttribute("visibility","visible");
    } else {
      obj.setAttribute("visibility","hidden");
    }
  }
}
SCRIPT
      $writer->endTag('script');
    }
  }
  $hint ||= {};
  # if ($opts{-transform}) {
  #   $draw->transform(%{$opts{-transform}});
  # }
  # if ($opts{-translate}) {
  #   $draw->translate(@{$opts{-translate}});
  # }
  # if ($opts{-rotate}) {
  #   $self->{current_page}->rotate($opts{-rotate});
  #   $draw->rotate($opts{-rotate});
  # }
  # if ($opts{-scale}) {
  #   $draw->scale(@{$opts{-scale}});
  # }
  # if ($opts{-skew}) {
  #   $draw->skew(@{$opts{-skew}});
  # }
  # if ($opts{-matrix}) {
  #   $draw->matrix(@{$opts{-matrix}});
  # }


  my $x = 0;
  my $y = 0;
  my $w = $opts{-width} || $self->{Media}[2];
  my $h = $opts{-height} || $self->{Media}[3];
  my $i;
  foreach my $item ($canvas->find('all')) {
    my $type=$canvas->type($item);
    my $tags=$canvas->itemcget($item,'-tags');
    my @coords=$canvas->coords($item);
    my %item_opts;
    if (defined $hint->{$item}) {
      my $id = 'hint_i'.$item;
      $item_opts{onmouseover}=qq{set_visibility('$id',1)};
      $item_opts{onmouseout}=qq{set_visibility('$id',0)};
    }
    $writer->comment( join(', ',@$tags) );
    my $state = $canvas->itemcget($item, '-state');
    next if $state eq 'hidden';
    $state = $state eq 'disabled' ? $state : '';
#    __debug("$type: orig @coords");
    # recalculate coords for bottom/up
    my $even=0;
    # foreach (@coords) {
    #   $_=$h-$_ if $even;
    #   $even=!$even;
    # }
#    __debug "$type: new @coords";
    if ($type eq 'text') {
      my $anchor=$canvas->itemcget($item,'-anchor') || 'center';
      my $color=$canvas->itemcget($item,"-${state}fill");
      next unless defined($color); # transparent text = no text
      $color = color2svg($color, $opts{-grayscale});
      my $fn = $canvas->itemcget($item,"-font");
      my %canvasfont = $canvas->fontActual($fn);
      __debug "FONT:", (map {" $_ => $canvasfont{$_}, "} keys %canvasfont),"\n";
      # my $font_lookup_string = lc($canvasfont{-family}." ".$canvasfont{-weight}." ".$canvasfont{-slant});
      # if ($self->{FontMap}{$font_lookup_string}) {
      # 	$fn=$self->{FontMap}{$font_lookup_string};
      # }
      my $text=$canvas->itemcget($item,"-text");
      my $textwidth=$canvas->itemcget($item,"-width");

      my ($posx,$posy)=@coords;
      my $ascent=$canvas->fontMetrics($fn,'-ascent');
      my $descent=$canvas->fontMetrics($fn,'-descent');
      my $height=$ascent+$descent;
      # my $width=$c->fontMeasure($fn,$text);
      # $posx-=$width/2;
      $posy+=$height/2;
      $anchor = '' if $anchor eq 'center';
      my $text_anchor = 'middle';


      if ($anchor =~ /s/) { $posy-=$height/2 }
      elsif ($anchor =~ /n/) { $posy+=$height/2 }

      if ($anchor =~ /e/) { $text_anchor='end' }
      elsif ($anchor =~ /w/) { $text_anchor='start' }

      $writer->startTag('text',
			'id' => 'i'.$item,
			"text-anchor" => $text_anchor,
			"font-family" => $canvasfont{-family},
			"font-weight" => $canvasfont{-weight},
			"font-size" => ($canvasfont{-size}<0 ? abs($canvasfont{-size}).'px' : $canvasfont{-size}.'pt'),
			"font-slant" => $canvasfont{-slant},
			"fill" => $color,
			width => $textwidth,
			x => $posx,
			y => $posy-$descent,
			%item_opts,
		       );
      $self->item_title($writer,$hint->{$item});
      $writer->setDataMode(0);
      for my $chunk (split /(\n)/,$text) {
	if ($chunk eq "\n") {
	  $writer->emptyTag('tbreak');
	} else {
	  $writer->characters($chunk);
	}
      }
      $writer->setDataMode(1);
      $writer->endTag('text');
    } elsif ($type eq 'line') {
      my $color=$canvas->itemcget($item,"-${state}fill");
      next unless defined $color; # transparent line = no line
      $color = color2svg($color, $opts{-grayscale});
      my $join=$canvas->itemcget($item,'-joinstyle');
      my $capstyle=$canvas->itemcget($item,'-capstyle');
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($width,$canvas->itemcget($item,"-${state}dash"));
      @dash=() if @dash<2;
      my $smooth = $canvas->itemcget($item,"-smooth");
      my $arrow = $canvas->itemcget($item,"-arrow");
      my $ars = $canvas->itemcget($item,"-arrowshape") || [8,10,3];

      # TODO: dashoffset
      my %attrs = (
	'stroke-width' => $width,
	'stroke-dasharray' => (join(',',@dash)||'none'),
	'stroke-linejoin' => $join{$join},
	'stroke-linecap' => $capstyle{$capstyle},
	'stroke'=>$color,
       );

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
      my $path='';
      if ($smooth and @c>5) {
	no integer;
	$path = qq{M$c[0],$c[1]};
	my @p;
	if ($c[0]==$c[-2] and $c[1]==$c[-1]) {
	  @p=(($c[-4]+$c[0])/2,($c[-3]+$c[1])/2);
	  unshift @c, @p;
	  @c[-2,-1]=@p;
	} else {
	  @p = @c[0,1];
	}
	my @m = @c[2,3];
	shift @c for 0..3;
	do {{
	  my @d = @c>=4 ? (($m[0]+$c[0])/2,($m[1]+$c[1])/2)  : @c[0,1];
	  $path .= qq{ C$p[0],$p[1],$m[0],$m[1],$d[0],$d[1]};
	  @m=@c[0,1];
	  @p=@d;
	  shift @c for 0,1;
	}} while (@c>=2);
      } else {
	my @p = @c;
	$path='M'.shift(@p).','.shift(@p);
	while (@p) {
	  $path.=' L'.shift(@p).','.shift(@p);
	}
      }
      $writer->startTag('path',
			'id' => 'i'.$item,
			'd' => $path,
			'fill' =>'none',
			%attrs,
			%item_opts,
		       );
      $self->item_title($writer,$hint->{$item});
      $writer->endTag('path');
      # draw arrows
      for (qw(first last)) {
	if ($arrow eq $_ or $arrow eq 'both') {
	  @c=$_ eq 'first' ? @coords[0..3] : @coords[-2,-1,-4,-3];
	  my $angle = 180*atan2($c[2]-$c[0],$c[1]-$c[3])/3.14159265-90;
	  $angle+=360 if ($angle<0);
	  $writer->startTag('g',transform=>'translate('.join(',',@c[0,1]).')');
	  $writer->startTag('g',transform=>'rotate('.(($angle+180) % 360).')');
	  $writer->startTag('polygon',
			    'id' => 'i'.$item,
			    'stroke-width' => 0,
			    'fill'=>$color,
			    'points' => (join ' ',map "$_->[0],$_->[1]",
					 ([0,0],[-$ars->[1],-$ars->[2]-$width],[-$ars->[0],0],[-$ars->[1],+$ars->[2]+$width])),
			    %item_opts,
			   );
	  $self->item_title($writer,$hint->{$item});
	  $writer->endTag('polygon');
	  $writer->endTag('g');
	  $writer->endTag('g');
	}
      }
    } elsif ($type eq 'oval') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($width,$canvas->itemcget($item,"-${state}dash"));
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);
      $color = color2svg($color, $opts{-grayscale});
      $outlinecolor = color2svg($outlinecolor, $opts{-grayscale});

      # TODO: dashoffset
      $writer->startTag('ellipse',
			'id' => 'i'.$item,
			cx=>($coords[2]+$coords[0])/2,
			cy=>($coords[3]+$coords[1])/2,
			rx=>abs($coords[2]-$coords[0])/2,
			ry=>abs($coords[3]-$coords[1])/2,
			'stroke-width'=>$width,
			'stroke-dasharray' => (join(',',@dash)||'none'),
			stroke => defined($outlinecolor) ? $outlinecolor : 'none',
			fill => defined($color) ? $color : 'none',
			%item_opts,
		       );
      $self->item_title($writer,$hint->{$item});
      $writer->endTag('ellipse');
    } elsif ($type eq 'polygon') {
      my $width=$canvas->itemcget($item,'-width');
      my $join=$canvas->itemcget($item,'-joinstyle');
      my @dash=_canvas_to_pdf_dash($width,$canvas->itemcget($item,"-${state}dash"));
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);

      $color = color2svg($color, $opts{-grayscale})
	if defined $color;
      $outlinecolor = color2svg($outlinecolor, $opts{-grayscale})
	if defined $outlinecolor;

      my $smooth = $canvas->itemcget($item,"-smooth");
      # TODO: dashoffset

      my %attrs = (
	'stroke-width' => $width,
	'stroke-dasharray' => (join(',',@dash)||'none'),
	'stroke-linejoin' => $join{$join},
	'stroke' => defined($outlinecolor) ? $outlinecolor : 'none',
	'fill' => defined($color) ? $color : 'none',
      );
      __debug "Polygon: @coords\n";

      if ($smooth) {
	no integer;
	my @c=(@coords,@coords[0..3]);
	my $first=1;
	my $path='';
 	while (@c>5) {
	  my @d = (($c[2]+$c[0])/2,($c[3]+$c[1])/2,
		   $c[2],$c[3],($c[4]+$c[2])/2,($c[5]+$c[3])/2);
	  $path.=qq{M$d[0],$d[1]} if $first;
	  $path.=qq{ C$d[2],$d[3] $d[2],$d[3] $d[4],$d[5]};
 	  splice @c,0,2;
	  $first = 0;
 	}
	$writer->startTag('path',
			  'id' => 'i'.$item,
			  d=>$path.' z',
			  %attrs,
			  %item_opts,
			 );
	$self->item_title($writer,$hint->{$item});
	$writer->endTag('path');
      } else {
	$writer->startTag('polygon',
			  'id' => 'i'.$item,
			  'points'=> join(' ',map { $coords[2*$_].','.$coords[2*$_+1] } 0..(int(@coords/2)-1)),
			  %attrs,
			  %item_opts,
			 );
	$self->item_title($writer,$hint->{$item});
	$writer->endTag('polygon');
      }
    } elsif ($type eq 'rectangle') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_pdf_dash($width,$canvas->itemcget($item,"-${state}dash"));
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);

      $color = color2svg($color, $opts{-grayscale})
	if defined $color;
      $outlinecolor = color2svg($outlinecolor, $opts{-grayscale})
	if defined $outlinecolor;

      $writer->startTag('rect',
			'id' => 'i'.$item,
			'x' => $coords[0],
			'y' => $coords[1],
			'width' => $coords[2]-$coords[0],
			'height' => $coords[3]-$coords[1],
			'stroke-width' => $width,
			'stroke-dasharray' => (join(',',@dash)||'none'),
			'stroke' => defined($outlinecolor) ? $outlinecolor : 'none',
			'fill' => defined($color) ? $color : 'none',
			%item_opts,
		       );
	$self->item_title($writer,$hint->{$item});
	$writer->endTag('rect');
    }
    # TODO image, ...
  }
  foreach my $item ($canvas->find('all')) {
    # HINT
    if (defined $hint->{$item}) {
      my @coords=$canvas->coords($item);

      my $fn = $balloon->cget('-font');
      my %canvasfont = $canvas->fontActual($fn);
      my %svg_font = (
	"font-family" => $canvasfont{-family},
	"font-weight" => $canvasfont{-weight},
	"font-size" => ($canvasfont{-size}<0 ? abs($canvasfont{-size}).'px' : $canvasfont{-size}.'pt'),
	"font-slant" => $canvasfont{-slant},
       );
      my $id = 'hint_i'.$item;
      $writer->startTag(
	'g',
	'visibility'=>'hidden',
	'id' => $id,
	%svg_font,
      );
      my $line_height = $balloon->fontMetrics($fn,'-linespace');
      my ($x,$y)=@coords[0,1];
      my $ascent=$canvas->fontMetrics($fn,'-ascent');
      my @lines = split /\n/, $hint->{$item};
      my $width = 0;
      for my $line (@lines) {
	my $lw = $balloon->fontMeasure($fn,$line);
	$width=$lw if $lw>$width;
      };
      $x+=10;$y+=10;
      $writer->emptyTag('rect',
			'x' => $x,
			'y' => $y,
			'width' => $width+20,
			'height' => scalar(@lines) * $line_height + 20,
			'stroke-width' => 1,
			'stroke' => 'black',
			'fill' => 'lightyellow');
      $y+=$ascent;
      for my $line (@lines) {
	$writer->startTag('text',
			  x=>$x,
			  y=>$y,
			 );
	$y+=$line_height;
	$writer->characters($line);
	$writer->endTag('text');
      }
      $writer->endTag('g');
    }
  }
  $writer->endTag('svg');
}

sub _canvas_to_pdf_dash {
  my ($linewidth,@dash)=@_;
  my $dash = join " ",@dash;
  my %d=('.' => 40, '-' => 120, ',' => 80, '_' => 160);
  $dash =~ s/(\d+)/$1*$linewidth/ge;
  $dash =~ s/[-.,_]( *)/$d{$1}." ".40*(1+length($2))." "/ge;
  $dash =~ s/[{}]//;
  return split /\s*/,$dash;
}

sub print_html_template {
  my ($fh, $title, $pages, $fn_format)=@_;
  my $files = join ",", map '"'.sprintf($fn_format, $_).'"', 0..($pages-1);
  print $fh <<"HTML";
<html>
  <head>
    <script language="javascript">
      var files = [
        $files
      ];
      var current_tree = 0;
      function height_inc ( amount ) {
        var object = document.getElementById("tree").getElementsByTagName("object").item(0);
        object.height=parseInt(object.height)+amount;
      }
      function next_tree ( delta ) {
        var next = current_tree+delta;
        if (next >= 0 && files.length > next) {

          // in FF, we would just set 'data', but Opera
          // and other require replacing the object

          var tree = document.getElementById("tree");
          var oobject = tree.getElementsByTagName("object").item(0);
          var nobject = tree.ownerDocument.createElement("object"); 
          nobject.width = oobject.width;
          nobject.height = oobject.height;
          nobject.class = oobject.class;
          nobject.type = oobject.type;
          nobject.data=files[next];
          tree.replaceChild(nobject,oobject);
          current_tree = next;
          update_title();
        }
      }
      function update_title () {
         document.getElementById("cur_tree").firstChild.nodeValue = current_tree + 1;
         document.getElementById("tree_count").firstChild.nodeValue = files.length;
      }
    </script>
  </head>
<body onLoad="next_tree(0)">
<h1>$title</h1>
<form>
  <input type="button" value="+" onClick="javascript:height_inc(30)"/>
  <input type="button" value="-" onClick="javascript:height_inc(-30)"/>

  <input type="button" value="<" onClick="javascript:next_tree(-1)"/>
  <span id="cur_tree">0</span> of <span id="tree_count">0</span>
  <input type="button" value=">" onClick="javascript:next_tree(1)"/>
</form>

<div id="tree" style="background:white;border: black solid 1px;">
  <object data="" width="100%" height="600"
         type="image/svg+xml"
         pluginspage="http://www.adobe.com/svg/viewer/install/" /> <!-- Adobe plugin for IE; Firefox supports SVG since 1.5 -->
</div>
</body>

</html>
HTML
}


package Tk::Canvas;

sub svg {
  my $self = shift;
  Tk::Canvas::SVG::svg($self,@_);
}

1;
