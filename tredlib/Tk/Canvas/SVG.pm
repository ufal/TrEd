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

=item $canvas->svg(options)

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


sub svg {
  my ($canvas,%opts)=@_;
  my $P = __PACKAGE__->new(%opts);
  $P->new_page(%opts);
  $P->draw_canvas($canvas,%opts);
  return $P->finish(%opts);
}

sub new_page {
  my ($P,%opts)=@_;
  use IO::String;
  my $svg_page;
  if ($P->{current_page}) {
    $P->{current_page}->end;
  }
  my $fh = IO::String->new($svg_page);
  $P->{current_page} = XML::Writer->new(OUTPUT=>$fh,DATA_INDENT=>1,DATA_MODE=>1,ENCODING=>'utf-8');
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

sub item_desc {
  my ($self,$writer,$title)=@_;
  if (defined($title) and $title=~/\S/) {
    $writer->startTag('desc');
    $writer->characters($title);
    $writer->endTag('desc');
  }
}
sub draw_canvas {
  my ($self,$canvas,%opts)=@_;

  my @media = @{$canvas->cget('-scrollregion')};
#    @{$self->{Media}};
  my $width = $media[2]-$media[0];
  my $height = $media[3]-$media[1];
  my $writer = $self->{current_page};

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


  $writer->xmlDecl("UTF-8");
  $writer->startTag('svg',
		    xmlns=>"http://www.w3.org/2000/svg",
		    version=>"1.1",
		    onload=>'init(evt)',
		    onmousemove=>"mouse_move(evt)",
		    onmouseout=>"mouse_out(evt)",
		    height=>"$height",
		    width=>"$width",
		    #preserveAspectRatio=>"xMinYMax",
		    #viewBox=>"@media",
		   );
  if ($opts{-title}) {
    $writer->startTag('title');
    $writer->characters($opts{-title});
    $writer->endTag('title');
  }
  if ($opts{-desc}) {
    $writer->startTag('desc');
    my $value = $opts{-desc};
    if (ref($value) eq 'ARRAY') {
      $value = join '',map {$_->[0]} @$value;
    }
    $writer->characters($value);
    $writer->endTag('desc');
  }
  my $balloon = $opts{-balloon};
  my $hint;
  if ($balloon) {
    $hint = $balloon->GetOption('-balloonmsg',$canvas);
    if ($hint) {
      $writer->startTag('script', type=>"text/ecmascript");
      $writer->characters(<<'SCRIPT'); # cdata not supported by older XML::Writer versions

      var doc = null;
      var root = null;
      var last_target = null;
      var svgNs = "http://www.w3.org/2000/svg";

      function init(event) {
         doc = event.target.ownerDocument;
         root = doc.documentElement;
	 top.zoomSVG = zoom;
         if (top.setSVGTitle) top.setSVGTitle(get_title());
         if (top.setSVGDesc) top.setSVGDesc(get_desc());
      }
      function mouse_out (event) {
        hide_tooltip(event);
      }
      function mouse_move (event) {
         show_tooltip(event);
      }
      function get_title () {
        var title = root.getElementsByTagName('title').item(0);
        if (title && title.parentNode == root) {
           return title.firstChild.nodeValue;
        } else {
           return '';
        }
      }
      function get_desc () {
        var desc = root.getElementsByTagName('desc').item(0);
        if (desc && desc.parentNode == root) {
           return desc.firstChild.nodeValue;
        } else {
           return '';
        }
      }
      function zoom (amount) {
        var old_scale = root.currentScale;
        var new_scale = old_scale + amount;
        var rescale = new_scale/old_scale;
        root.currentScale = new_scale;
	root.setAttribute('width',Number(root.getAttribute('width'))*rescale);
	root.setAttribute('height',Number(root.getAttribute('height'))*rescale);
      }
      function hide_tooltip(event) {
	 if (event.target == last_target && top.changeToolTip) {
	    top.changeToolTip("");
	 }
      }
      function show_tooltip(event) {
         var target = event.target;
	 if (!top.placeTip) return;
	 var x = event.clientX;
	 var y = event.clientY;
  	 top.placeTip(x,y);
         if ( last_target != target ) {
	    last_target = target;
            var desc = target.getElementsByTagName('desc').item(0);
            if ( desc && desc.parentNode == target && desc.parentNode != root) {
               tooltip_text = desc.firstChild.nodeValue;
	       if (tooltip_text == null) {
	         top.changeToolTip('');
	       } else {
	         top.changeToolTip(tooltip_text.split(/\n/).join("<br />"));
               }
            }
         }
      }

SCRIPT
      $writer->endTag('script');
    }
  }
  $hint ||= {};


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

      my @lines = split /\n/,$text;
      if ($anchor =~ /s/) { $posy-=$height/2 }
      elsif ($anchor =~ /n/) { $posy+=$height/2 }

      if ($anchor =~ /e/) { $text_anchor='end' }
      elsif ($anchor =~ /w/) { $text_anchor='start' }

      $posy-=$descent;

      $writer->startTag(((@lines>1) ?
			   ('g') :
			   ('text',
			    x=>$posx,
			    y=>$posy)
			),
			'id' => 'i'.$item,
			"text-anchor" => $text_anchor,
			"font-family" => $canvasfont{-family},
			"font-weight" => $canvasfont{-weight},
			"font-size" => ($canvasfont{-size}<0 ? abs($canvasfont{-size}).'px' : $canvasfont{-size}.'pt'),
			"font-slant" => $canvasfont{-slant},
			"fill" => $color,
			width => $textwidth,

			((@lines>1) ? (  ) : ()),

			%item_opts,
		       );
      $self->item_desc($writer,$hint->{$item});
      if (@lines>1) {
	for my $line (@lines) {
	  $writer->startTag('text',
			    x=>$posx,
			    y=>$posy,
			   );
	  $writer->setDataMode(0);
	  $writer->characters($line);
	  $writer->setDataMode(1);
	  $writer->endTag('text');
	  $posy+=$height;
	}
	$writer->endTag('g');
      } else {
	$writer->setDataMode(0);
	$writer->characters($text);
	$writer->setDataMode(1);
	$writer->endTag('text');
      }
    } elsif ($type eq 'line') {
      my $color=$canvas->itemcget($item,"-${state}fill");
      next unless defined $color; # transparent line = no line
      $color = color2svg($color, $opts{-grayscale});
      my $join=$canvas->itemcget($item,'-joinstyle');
      my $capstyle=$canvas->itemcget($item,'-capstyle');
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_svg_dash($width,$canvas->itemcget($item,"-${state}dash"));
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
      $self->item_desc($writer,$hint->{$item});
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
	  $self->item_desc($writer,$hint->{$item});
	  $writer->endTag('polygon');
	  $writer->endTag('g');
	  $writer->endTag('g');
	}
      }
    } elsif ($type eq 'oval') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_svg_dash($width,$canvas->itemcget($item,"-${state}dash"));
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
      $self->item_desc($writer,$hint->{$item});
      $writer->endTag('ellipse');
    } elsif ($type eq 'polygon') {
      my $width=$canvas->itemcget($item,'-width');
      my $join=$canvas->itemcget($item,'-joinstyle');
      my @dash=_canvas_to_svg_dash($width,$canvas->itemcget($item,"-${state}dash"));
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
	$self->item_desc($writer,$hint->{$item});
	$writer->endTag('path');
      } else {
	$writer->startTag('polygon',
			  'id' => 'i'.$item,
			  'points'=> join(' ',map { $coords[2*$_].','.$coords[2*$_+1] } 0..(int(@coords/2)-1)),
			  %attrs,
			  %item_opts,
			 );
	$self->item_desc($writer,$hint->{$item});
	$writer->endTag('polygon');
      }
    } elsif ($type eq 'rectangle') {
      my $width=$canvas->itemcget($item,'-width');
      my @dash=_canvas_to_svg_dash($width,$canvas->itemcget($item,"-${state}dash"));
      @dash=() if @dash<2;
      my $color=$canvas->itemcget($item,"-${state}fill");
      my $outlinecolor=$canvas->itemcget($item,"-${state}outline");
      $outlinecolor=$color if !defined($outlinecolor);

      $color = color2svg($color, $opts{-grayscale})
	if defined $color;
      $outlinecolor = color2svg($outlinecolor, $opts{-grayscale})
	if defined $outlinecolor;
      my $is_text_bg = grep { $_ eq 'textbg' } @$tags;
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
			($is_text_bg ? ('fill-opacity' => '0.6') : ()),
			%item_opts,
		       );
	$self->item_desc($writer,$hint->{$item});
	$writer->endTag('rect');
    }
    # TODO image, ...
  }
  $writer->endTag('svg');
}

sub _canvas_to_svg_dash {
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
    <style type="text/css">

body {
  font-family: Arial, Sans Serif, sans;
  font-size: 10pt;
}

#tooltip {
  visibility: hidden;
  position: absolute;
  top: 10px;
  left: 10px;
  padding: 10px;
  background: #ffffbb;
  border: black solid 1pt;
}
#title {
  text-align: center;
}
#tree iframe,
#tree embed {
 background:white;
 border: black solid 1px;
}
    </style>
    <script type="text/javascript"><!--
      var files = [
        $files
      ];
      var current_tree = 0;
      var tree_obj = null;
      var tooltip = null;

      function f_filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
      }
      function f_clientHeight() {
	return f_filterResults (
		window.innerHeight ? window.innerHeight : 0,
		document.documentElement ? document.documentElement.clientHeight : 0,
		document.body ? document.body.clientHeight : 0	);
      }
      function fit_window() {
        height = f_clientHeight();
	var object = tree_obj.getElementsByTagName("iframe").item(0);
	if (object) {
          object.height = height - findPosY(tree_obj) - 20;
        }
	var object = tree_obj.getElementsByTagName("embed").item(0);
	if (object) {
          object.height = height - findPosY(tree_obj) - 20;
        }
      }
      function zoom_inc ( amount ) {
	 window.zoomSVG( amount );
      }
      function next_tree ( delta ) {
        var next = current_tree+delta;
        if (next >= 0 && files.length > next) {

          // in FF, we would just set 'data', but Opera
          // and other require replacing the object
          current_tree = next;
	  update_object("iframe");
	  update_object("embed");
          update_title();
        }
      }
      function update_object (tagName) {
          var oobject = tree_obj.getElementsByTagName(tagName).item(0);
	  if (oobject == null) return;
          var nobject = tree_obj.ownerDocument.createElement(tagName); 
          nobject.width = oobject.width;
          nobject.height = oobject.height;
          nobject.setAttribute('class',oobject.getAttribute('class'));
          nobject.type = oobject.type;
	  if (oobject.src != null) nobject.src=files[current_tree];
	  if (oobject.data != null) nobject.data=files[current_tree];
          tree_obj.replaceChild(nobject,oobject);
      }
      function update_title () {
         document.getElementById("cur_tree").firstChild.nodeValue = current_tree + 1;
         document.getElementById("tree_count").firstChild.nodeValue = files.length;
      }
      function init () {
	tooltip = document.getElementById('tooltip');
        tree_obj = document.getElementById("tree");
	document.changeToolTip = changeToolTip;
	document.placeTip = placeTip;
        window.setSVGTitle = set_title;
        window.setSVGDesc = set_desc;
	fit_window();
        next_tree(0);
      }
      function set_title (title) {
        document.getElementById("title").firstChild.nodeValue = title;
      }
      function set_desc (desc) {
        document.getElementById("desc").innerHTML = desc.replace(/</,'&lt;').replace(/&/,'&amp;').split(/\\n/).join('<br />');
        fit_window();
      }

      // findPosX and findPosY by Peter-Paul Koch & Alex Tingle. 
      function findPosX(obj) {
        var curleft = 0;
	if(obj.offsetParent)
        while(1) {
	  curleft += obj.offsetLeft;
	  if(!obj.offsetParent)
	    break;
	    obj = obj.offsetParent;
	  }
	else if(obj.x)
          curleft += obj.x;
	return curleft;
      }
      function findPosY(obj) {
        var curtop = 0;
        if(obj.offsetParent)
          while(1) {
            curtop += obj.offsetTop;
            if(!obj.offsetParent)
              break;
            obj = obj.offsetParent;
          }
        else if(obj.y)
          curtop += obj.y;
        return curtop;
      }

      function placeTip (x,y) {
        tooltip.style.left="" + (findPosX(tree_obj) + x + 20) + "px";
        tooltip.style.top="" + (findPosY(tree_obj) + y + 10) + "px";
      }
      function changeToolTip (html) {
        if ('' != html) {
          tooltip.innerHTML = html;
	  tooltip.style.visibility = 'visible';
        } else {
	  tooltip.style.visibility = 'hidden';
        }
      }
-->
    </script>
  </head>
<body onload="init()" onresize="fit_window()">
 <h1 id="title">$title</h1>
 <form action="">
  <table width="100%" class="toolbar">
    <tr>
      <td width="10%"></td>
      <td align="center">
        <p>
          <input type="button" value="&lt;" onclick="next_tree(-1)"/>
          <span id="cur_tree">0</span> of <span id="tree_count">0</span>
          <input type="button" value=">" onclick="next_tree(1)"/>
        </p>
      </td>
      <td width="10%">
        <p>
          <input type="button" value="+" onclick="zoom_inc(0.1)"/>
          <input type="button" value="-" onclick="zoom_inc(-0.1)"/>
        </p>
      </td>
    </tr>
  </table>
 </form>
 <div id="tooltip"></div>
 <div id="desc" style="padding: 0 2% 10 2%"></div>
 <div id="tree" style="text-align:center">
    <iframe src="" width="98%" height="80%" frameborder="0" marginwidth="0"  marginheight="0" scrolling="yes">
      <embed src="" width="98%" height="80%" type="image/svg+xml" pluginspage="http://www.adobe.com/svg/viewer/install/"/>
    </iframe>
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
