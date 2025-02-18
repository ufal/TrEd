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
  use Math::Trig;
  use base qw(Tk::Canvas Exporter);
  use vars qw(%media %join %capstyle %stipple_def @EXPORT_OK $round_format);
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
  %stipple_def = (
    dash1 => [1, 5, 120],
    dash2 => [1, 5, 60],
    dash3 => [1, 5, 30],
    dash4 => [1, 5, 150],
    dash5 => [1, 5, 90],
    dash6 => [1, 5, 0],
    dense1 => [1, 2, 120],
    dense2 => [1, 2, 60],
    dense3 => [1, 2, 150],
    dense4 => [1, 2, 30],
    dense5 => [1, 2, 90],
    dense6 => [1, 2, 0],
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
  $round_format = "%.6g"; # no rounding: "%s"
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
  return unless defined $color;

  if ($grayscale) {
    $color = color2gray($color)
  } elsif ($color=~/^#([0-9a-fA-F]{2})[0-9a-fA-F]{2}([0-9a-fA-F]{2})[0-9a-fA-F]{2}([0-9a-fA-F]{2})[0-9a-fA-F]{2}$/) {
    $color=qq{#$1$2$3};
  } elsif (exists($Tk::rgb::rgb{$color})) {
    $color = sprintf("#%02x%02x%02x",@{$Tk::rgb::rgb{$color}});
  } else {
    warn "unknown color $color\n" unless $color=~/^#[0-9a-fA-F]{6}$/;
    $color = lc($color);
  }
  return $color;
}

sub color2gray {
  my ($color)=@_;
  unless (ref($color)) {
    if (!defined($color)) {
      return;
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
  my $svg_page;
  if ($P->{current_page}) {
    $P->{current_page}->end;
  }
  my $fh;
  if (eval('use XML::Writer 0.6; 1')) {
    $fh = \$svg_page;
  } else {
    require IO::String;
    $fh = IO::String->new($svg_page);
  }
  $P->{current_page} = XML::Writer->new(OUTPUT=>$fh,
                                        DATA_INDENT=>1,
                                        DATA_MODE=>1,
                                        ENCODING=>'utf-8');
  push @{$P->{pages}}, \$svg_page;
}

sub finish {
  my ($P,%opts)=@_;
  if ($P->{current_page}) {
    $P->{current_page}->end;
  }
  if ($opts{-file}) {
    if(@{$P->{pages}}==1 && ! $opts{-alwayscreatedir}) {
      # print STDERR "Print to $opts{-file}\n";
      open(my $fh, '>:utf8', $opts{-file}) or die "Cannot open file '$opts{-file}' for writing: $!";
      print $fh ${$P->{pages}->[0]};
      close $fh;
    } elsif (@{$P->{pages}}>1 || (@{$P->{pages}}>0 && $opts{-alwayscreatedir})) {
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
  } elsif ($opts{-object}) {
    return [ map $$_, @{$P->{pages}} ];
  } else {
    return join("\n\n<!-- new_page -->\n\n",map $$_, @{$P->{pages}});
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

sub write_stipple_clip_pattern {
  my ($writer, $w, $h, $lw, $dw, $angle,$name) = @_;
  my ($mx1, $my1, $mx2, $my2) = (0,0,0,0);
  if($angle == 0){
    $mx1 = $my1 = $mx2 = 0;
    $my2 = $lw + $dw;
  }
  elsif($angle == 90){
    $mx1 = $my1 = $my2 = 0;
    $mx2 = $lw + $dw;
  }
  elsif($angle < 90){
    my $a = pi*$angle/180;
    $mx1 = $my1 = 0;
    $mx2 = ($lw + $dw)*sin($a);
    $my2 = ($lw + $dw)*cos($a);
  }
  elsif($angle > 90){
    my $a = pi*(180 - $angle)/180;
    $mx1 = $my2 = 0;
    $mx2 = ($lw + $dw)*sin($a);
    $my1 = ($lw + $dw)*cos($a);
  }
  my $p = int(10000* $lw / ($lw + $dw))/100;
  $writer->startTag(
    'mask', 'id' => "mask_$name",
    'x' => 0, 'y' => 0, 'width' => $w, 'height'=> $h,
    'maskUnits' => "userSpaceOnUse"
  );
  $writer->startTag(
    'linearGradient', 'id' => "gradient_$name",
    'gradientUnits' => "userSpaceOnUse", 'spreadMethod' => "repeat",
    'x1' => $mx1, 'y1' => $my1, 'x2' => $mx2, 'y2' => $my2,
  );
  $writer->emptyTag('stop', 'offset' =>   '0%', 'stop-color' => '#FFF', 'stop-opacity' => '0');
  $writer->emptyTag('stop', 'offset' =>   '0%', 'stop-color' => '#FFF', 'stop-opacity' => '0.5');
  $writer->emptyTag('stop', 'offset' =>  "$p%", 'stop-color' => '#FFF', 'stop-opacity' => '0.5');
  $writer->emptyTag('stop', 'offset' =>  "$p%", 'stop-color' => '#FFF', 'stop-opacity' => '0');
  $writer->emptyTag('stop', 'offset' => '100%', 'stop-color' => '#FFF', 'stop-opacity' => '0');
  $writer->endTag('linearGradient');
  $writer->emptyTag('rect', 'x' => '0', 'y' => '0', 'width' => "$w", 'height' => "$h", 'fill' => "url(#gradient_$name)");
  $writer->endTag('mask');
}

sub write_stipple_clip_path {
  my ($writer, $w, $h, $lw, $dw, $angle,$name) = @_;
    my $path='';
  my $format = ' M%.1f,%.1f L%.1f,%.1f L%.1f,%.1f L%.1f,%.1f Z';
  if($angle == 0){
    my($x1,$y1,$lh,$dh) = (0,0,$lw,$dw);
    while($y1 < $h){
      $path .= sprintf $format,
        $x1,$y1,
        $x1+$w,$y1,
        $x1+$w,$y1+$lh,
        $x1,$y1+$lh,
#        $x1, $y1
      ;
      $y1+=$lh+$dh;
    }
  }
  elsif($angle == 90){
    my($x1,$y1,$lw,$dw) = (0,0,$lw,$dw);
    while($x1 < $w){
      $path .= sprintf $format,
        $x1,$y1,
        $x1,$y1+$h,
        $x1+$lw,$y1+$h,
        $x1+$lw,$y1,
#        $x1, $y1
      ;
      $x1+=$lw+$dw;
    }
  }
  elsif($angle < 90){
    my $a = pi*$angle/180;
    my($x1,$y1,$x2,$y2,$lh,$dh) = (0,0,$w,
      int(-10*$w*tan($a))/10,
      int(10*$lw/cos($a))/10,
      int(10*$dw/cos($a))/10
    );
    while($y2 < $h){
      $path .= sprintf $format,
        $x1,$y1,
        $x2,$y2,
        $x2,$y2+$lh,
        $x1,$y1+$lh,
#        $x1, $y1
      ;
      $y1+=$lh+$dh;
      $y2+=$lh+$dh;
    }
  }
  elsif($angle > 90){
    my $a = pi*(180-$angle)/180;
    my($x1,$y1,$x2,$y2,$lh,$dh) = (
      0,int(-10*$w*tan($a))/10,
      $w,0,
      int(10*$lw/cos($a))/10,
      int(10*$dw/cos($a))/10
    );
    while($y1 < $h){
      $path .= sprintf $format,
        $x1,$y1,
        $x2,$y2,
        $x2,$y2+$lh,
        $x1,$y1+$lh,
 #       $x1, $y1
      ;
      $y1+=$lh+$dh;
      $y2+=$lh+$dh;
    }
  }
  $writer->startTag(
    'clipPath',
    'id' => 'mask_'.$name,
#    'x' => 0,
#    'y' => 0,
#    'width' => $w,
#    'height' => $h,
#    'maskUnits'=> "userSpaceOnUse",
  );
  $path =~ s/^ //;
  $writer->startTag(
    'path',
    'd' => $path,
    'fill' =>'#FFF',
    'opacity' => '0.5',
  );
  $writer->endTag('path');
  $writer->endTag('clipPath');
}
sub draw_canvas {
  my ($self,$canvas,%opts)=@_;

  my @media = @{$canvas->cget('-scrollregion')};
#    @{$self->{Media}};
  my $width = $media[2]-$media[0] + 10;
  my $height = $media[3]-$media[1] + 10;
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
                    # preserveAspectRatio=>'xMinYMin meet',
                    # viewBox=>"@media",
                   );
  if ($opts{-title}) {
    $writer->startTag('title');
    if (ref($opts{-title}) eq 'CODE') {
      $opts{-title}->($writer);
    } else {
      $writer->characters($opts{-title});
    }
    $writer->endTag('title');
  }
  if ($opts{-desc}) {
    $writer->startTag('desc');
    $writer->setDataMode(0);
    my $value = $opts{-desc};
    if (ref($value) eq 'ARRAY') {
      $writer->startTag('span', "xmlns"=>"http://www.w3.org/1999/xhtml/");
      for my $v (@$value) {
        my ($text,@tags)=@$v;
        if (@tags) {
          $writer->startTag('span', class=>join(' ',grep !ref($_), @tags));
        }
        for my $t (split(/(\n)/,$text)) {
          if ($t eq "\n") {
            $writer->emptyTag("br");
          } else {
            $writer->characters($t);
          }
        }
        $writer->endTag('span') if @tags;
      }
      $writer->endTag('span');
    } else {
      $writer->characters($value);
    }
    $writer->setDataMode(1);
    $writer->endTag('desc');
  }
  my $balloon = $opts{-balloon};
  my $hint;
  if ($balloon) {
    $hint = $balloon->GetOption('-balloonmsg',$canvas);
    if ($hint && ! $opts{-compress}) {
      $writer->startTag('script', type=>"text/ecmascript");
      $writer->setDataMode(0);
      $writer->characters(<<'SCRIPT'); # cdata not supported by older XML::Writer versions

      var doc = null;
      var root = null;
      var css = null;
      var last_target = null;
      var svgNs = "http://www.w3.org/2000/svg";

      function init(event) {
         doc = event.target.ownerDocument;
         root = doc.documentElement;
         if (root.styleSheets != null && root.styleSheets[0] != null) css = root.styleSheets[0]
         else if (doc.styleSheets != null && doc.styleSheets[0] != null) css = doc.styleSheets[0];
         top.zoomSVG = zoom;
         if (top.svg_loaded) top.svg_loaded(doc);
         if (top.setSVGTitle) top.setSVGTitle(get_title());
         if (top.setSVGDesc) top.setSVGDesc(get_desc());
         if (top.highlightSVGNodes) top.highlightSVGNodes(css);
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
           var n = desc.firstChild;
           while (n && n.nodeType != 1) n=n.nextSibling;
           if (!n) n=desc.firstChild;
           return n; // desc.firstChild.nodeValue;
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
        top.placeTip(x,y,root,event);
        if ( last_target != target ) {
          last_target = target;
          if (top.onSVGMouseOver) top.onSVGMouseOver(target);
          if (target==root) return;
          var desc;
          for (var i=0; i<target.childNodes.length; i++) {
            var n = target.childNodes[i];
            if (n.nodeName == 'desc') {
              desc = n;
              break;
            }
          }
          if ( desc ) {
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
      $writer->setDataMode(1);
      $writer->endTag('script');
      $writer->startTag('defs');
      # style element is used also for dynamic styling
      $writer->startTag('style', type=>'text/css');
      if ($opts{-inline_css}) {
        $writer->characters($opts{-inline_css});
      }
      $writer->endTag('style');
      $writer->endTag('defs');
    }
  }
  $hint ||= {};
  $writer->startTag('g',
                    transform=>"translate(".(-$media[0]+5).' '.(-$media[1]+5).")");

#  my $x = 0;
#  my $y = 0;
#  my $w = $opts{-width} || $self->{Media}[2];
#  my $h = $opts{-height} || $self->{Media}[3];
#  my $i;

  #find group visualisation lines and stipple patterns used
  my (%group_tags, %stipples);
  foreach my $item ($canvas->find('withtag','group_line')) {
    my @tags = $canvas->itemcget($item, '-tags');
    map { $group_tags{$_} = 1 if $_ =~ "^group_no_"; } @tags;
    my $stipple = $canvas->itemcget($item, '-stipple');
    if($stipple and not $stipples{$stipple} and $stipple_def{$stipple}){
        #prepare clipPath elements
        write_stipple_clip_path($writer,$width,$height,@{$stipple_def{$stipple}}, $stipple);
        $stipples{$stipple} = 1;
    }
  }

  foreach my $item ($canvas->find('all')) {
    my $type=$canvas->type($item);
    my $tags=$canvas->itemcget($item,'-tags');
    my @coords=$canvas->coords($item);
    my %item_opts;
    $item_opts{class} = join(' ',grep !/(?:SCALAR|ARRAY|HASH|CODE)\(0x/, @$tags);
    $item_opts{class} =~ s/\//\./g;
    # $writer->comment( join(', ',@$tags) );
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
      # Leading spaces are not displayed in SVG, but we want them.
      $text =~ s/^( +)/"\N{NO-BREAK SPACE}" x length $1/e;
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
                        "font-size" => ($canvasfont{-size}<0 ? abs($canvasfont{-size})#.'px'
                                          : $canvasfont{-size}.'pt'),
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
      next if grep {$_ =~ 'group_no_' } @{$canvas->itemcget($item,'-tags')}; #skip group visualisation lines;
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
                        cx=>sprintf($round_format,($coords[2]+$coords[0])/2),
                        cy=>sprintf($round_format,($coords[3]+$coords[1])/2),
                        rx=>sprintf($round_format,abs($coords[2]-$coords[0])/2),
                        ry=>sprintf($round_format,abs($coords[3]-$coords[1])/2),
                        'stroke-width'=>sprintf($round_format,$width),
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
                        'x' => sprintf($round_format,$coords[0]),
                        'y' => sprintf($round_format,$coords[1]),
                        'width' => sprintf($round_format,$coords[2]-$coords[0]),
                        'height' => sprintf($round_format,$coords[3]-$coords[1]),
                        'stroke-width' => $width,
                        'stroke-dasharray' => (join(',',@dash)||'none'),
                        'stroke' => defined($outlinecolor) ? $outlinecolor : 'none',
                        'fill' => defined($color) ? $color : 'none',
                        ($is_text_bg ? ('fill-opacity' => '0.9') : ()),
                        ($is_text_bg ? ('stroke-opacity' => '0.9') : ()),
                        %item_opts,
                       );
        $self->item_desc($writer,$hint->{$item});
        $writer->endTag('rect');
    }
    # TODO image, ...
  }

  #render groups separately
  foreach my $is_group_no (keys %group_tags){
    my @group_lines = $canvas->find('withtag',$is_group_no);
    my $item = $group_lines[0];

    my %item_opts;
    my $tags=$canvas->itemcget($item,'-tags');
    $item_opts{class} = join(' ',grep !/(?:SCALAR|ARRAY|HASH|CODE)\(0x/, @$tags);
    $item_opts{class} =~ s/\//\./g;
    my $state = $canvas->itemcget($item, '-state');
    next if $state eq 'hidden';
    $state = $state eq 'disabled' ? $state : '';

    my $color=$canvas->itemcget($item,"-${state}fill");
    next unless defined $color; # transparent line = no line
    $color = color2svg($color, $opts{-grayscale});
    my $join=$canvas->itemcget($item,'-joinstyle');
    my $capstyle=$canvas->itemcget($item,'-capstyle');
    my $width=$canvas->itemcget($item,'-width');
    my %attrs = (
      'stroke-width' => $width,
      'stroke-dasharray' => 'none',
      'style'=>'stroke-linejoin:round;stroke-linecap:round',
      'stroke'=>$color,
    );
    my $path='';
    foreach my $item (@group_lines) {
      my $smooth = $canvas->itemcget($item,"-smooth");
      if($smooth){
        print {*STDERR} "SMOOTH = $smooth\n";
      }
      my @p=$canvas->coords($item);
      $path.=' M'.shift(@p).','.shift(@p);
      while (@p) {
        $path.=' L'.shift(@p).','.shift(@p);
      }
    }
    my $stipple = $canvas->itemcget($item,"-stipple");
    $writer->startTag(
      'path',
      'id' => 'i'.$item,
      'd' => $path,
      'fill' =>'none',
      'clip-path' => "url(#mask_$stipple)",
      'opacity' => '0.5',
      %attrs,
      %item_opts,
    );
    $self->item_desc($writer,$hint->{$item});
    $writer->endTag('path');
  }

  $writer->endTag('g');
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
      function f_windowHeight() {
        var h = window.innerHeight;
        if (h) return h;
        if (document.documentElement) h = document.documentElement.clientHeight;
        if (h) return h;
        if (document.body) h=document.body.clientHeight;
        return h ? h : 0;
      }
      function fit_window() {
        var height = f_windowHeight();
        var tree_obj = document.getElementById("svg-tree");
        if (height && tree_obj) {
          var y = findPosY(tree_obj);
          var tree = document.getElementById('tree');
          tree.style.height = "" + (height - y - 20) + "px";
        }
      }
      function getSVG (container) {
        var svg_document =
            container.contentDocument
            ? container.contentDocument
            : container.contentWindow
            ? container.contentWindow.document
            : null;
        return svg_document ? svg_document.documentElement : null;
      }
      function zoom_inc (amount) {
        var container = document.getElementById('svg-tree');
        var svg = getSVG(container);
        var w = parseFloat(container.getAttribute('width'));
        var h = parseFloat(container.getAttribute('height'));
        var rescale = amount>=0 ? (1+amount) : 1/(1-amount);
        w=w*rescale;
        h=h*rescale;
        container.setAttribute('width', w);
        container.setAttribute('height', h);
        if (svg) {
          svg.currentScale = svg.currentScale * rescale;
          svg.setAttribute('viewBox', '0 0 ' + w + ' ' + h);
        }
      }
      function next_tree ( delta ) {
        var next = current_tree+delta;
        if (next >= 0 && files.length > next) {

          // in FF, we would just set 'data', but Opera
          // and other require replacing the object
          current_tree = next;
          var container = document.getElementById('svg-tree');
          if (container) container.width=0; // to prevent visible zooming
          update_object_data(container);
          update_title();
        }
      }
      function update_object_data (oobject) {
        if (oobject == null) return;
        var nobject = oobject.ownerDocument.createElement(oobject.nodeName);
        var a = ['class','style','type','width','height'];
        for (var i=0; i<a.length; i++) {
          var v = oobject.getAttribute(a[i]);
          if (v!=null && v!='') nobject.setAttribute(a[i],v);
        }
        var id = oobject.getAttribute("id");
        nobject.setAttribute("data", files[current_tree]);
        oobject.parentNode.replaceChild(nobject,oobject);
        nobject.setAttribute("id", id);
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
        window.svg_loaded = svg_tree_loaded;
        fit_window();
        next_tree(0);
      }
      function set_title (title) {
        document.getElementById("title").firstChild.nodeValue = title;
      }

      var ltrChars      = 'A-Za-z\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u02B8\\u0300-\\u0590\\u0800-\\u1FFF'+'\\u2C00-\\uFB1C\\uFDFE-\\uFE6F\\uFEFD-\\uFFFF',
          rtlChars      = '\\u0591-\\u07FF\\uFB1D-\\uFDFD\\uFE70-\\uFEFC',
          ltrDirCheckRe = new RegExp('^[^'+rtlChars+']*['+ltrChars+']'),
          rtlDirCheckRe = new RegExp('^[^'+ltrChars+']*['+rtlChars+']');
      var user_agent=navigator.userAgent.toLowerCase();
      var bidi_support_in_svg = ((user_agent.indexOf("firefox") != -1) ? 0 : 1);

      function textDirection (text) {
         return rtlDirCheckRe.test(text) ? 'rtl'
                : (ltrDirCheckRe.test(text) ? 'ltr' : '');
      }
      function svg_tree_loaded (svg_document) {
        var container = document.getElementById('svg-tree');
        var svg = svg_document ? svg_document.documentElement : null;
        if (svg==null) return;
        container.setAttribute('width',parseFloat(svg.getAttribute('width')));
        container.setAttribute('height',parseFloat(svg.getAttribute('height')));
      }
      function set_desc (desc) {
        var el = document.getElementById("desc");
        var text;
        try { if(desc.innerText) { text=desc.innerText } else { text = desc.textContent } } catch(e) {}
        var dir = textDirection(text);
        el.style.direction = dir;
        var childNodes =  desc.childNodes;
        if (typeof(childNodes)=="undefined") return;
        try {
          var s = new XMLSerializer();
          var str='';
          for (var i=0; i<childNodes.length;i++) {
            str += s.serializeToString(childNodes[i]);
          }
          el.innerHTML = str;
        } catch (e) {
          el.innerHTML = '';
          for (var i=0; i<childNodes.length;i++) {
            el.appendChild(document.importNode(childNodes[i],true));
          }
        }
        if ( dir!='ltr' && ! bidi_support_in_svg) {
          el.innerHTML += '<div style="color: gray; direction: ltr; font-size: 6pt;">WARNING: Firefox may obscure right-to-left text in SVG on some platforms!</div>';
        }
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

      function placeTip (x,y,svg) {
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
  <div id="tree" class="tree" style="width:100%; height:60%; overflow:auto;">
    <object width="100%" type="image/svg+xml" id="svg-tree" alt="tree"></object>
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
