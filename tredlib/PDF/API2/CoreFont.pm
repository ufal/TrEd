#=======================================================================
#  ____  ____  _____              _    ____ ___   ____
# |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
# | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
# |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
# |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
# Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
# This library is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
# PDF::API2::CoreFont
#
#=======================================================================
package PDF::API2::CoreFont;

BEGIN {
  use vars qw( @ISA $fonts $alias $subs $encodings $VERSION );
  ( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;
}

use strict;

use PDF::API2::UniMap;
use PDF::API2::Util;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Dict;

@ISA = qw( PDF::API2::PDF::Dict );

=head1 PDF::API2::CoreFont

PDF::API2::CoreFont - a perl-module providing core-font objects for both
Text::PDF and PDF::API2.

=head2 SYNOPSIS

  use PDF::API2;
  use PDF::API2::CoreFont;

  $api = PDF::API2->new;
  ...
  $font = PDF::API2::CoreFont->new_api($api,'Helvetica', -encode => 'latin1');

OR

  use PDF::API2::PDF::File;
  use PDF::API2::CoreFont;

  $pdf = PDF::API2::PDF::File->new('some.pdf');
  ...
  $font = PDF::API2::CoreFont->new($pdf,'Helvetica', -encode => 'latin1', -pdfname => 'F0');

=head2 METHODS

=item $font = PDF::API2::CoreFont->new $pdf, $fontname, %options

Returns a corefont object.

Valid %options are:

  '-encode' ... changes the encoding of the font from its default.

  '-pdfname' ... changes the reference-name of the font from its default.

B<On '-encode':> The natively supported encodings are 'latin1','winansi' and 'macroman'.
Other Encodings are supported via PDF::API2::UniMap.

B<On '-pdfname':> The reference-name is normally generated automatically and can be
retrived via $pdfname=$font->name.

=cut

sub _look_for_font ($) {
  my $fname=shift;
  return(%{$fonts->{$fname}}) if(defined $fonts->{$fname});
  eval "require PDF::API2::CoreFont::$fname; ";
  unless($@){
    return(%{$fonts->{$fname}});
  } else {
    die "requested font '$fname' not installed ";
  }
}

sub _look_for_fontfile ($) {
  my $fname=shift;
  my $fpath;
  foreach my $dir (@INC) {
    $fpath="$dir/PDF/API2/CoreFont/$fname";
    last if(-f $fpath);
    $fpath=undef;
  }
  return($fpath);
}

sub new {
  my ($class,$pdf,$name,@opts) = @_;
  my $self;
  my %opts=();
  my $lookname=lc($name);
  $lookname=~s/[^a-z0-9]+//gi;
  %opts=@opts if((scalar @opts)%2 == 0);
  $class = ref $class if ref $class;
  $self = $class->SUPER::new();
  $opts{-encode}||='asis';

  $lookname = defined($alias->{$lookname}) ? $alias->{$lookname} : $lookname ;

  if(defined $subs->{$lookname}) {
    $self->{' data'}={_look_for_font($subs->{$lookname}->{-alias})};
    foreach my $k (keys %{$subs->{$lookname}}) {
      next if($k=~/^\-/);
      $self->{' data'}->{$k}=$subs->{$lookname}->{$k};
    }
  } else {
    unless(defined $opts{-metrics}) {
      $self->{' data'}={_look_for_font($lookname)};
    } else {
      $self->{' data'}={%{$opts{-metrics}}};
    }
  }

  die "Undefined Font '$name($lookname)'" unless($self->{' data'}->{fontname});

  $self->{'Type'} = PDFName("Font");
  $self->{'Subtype'} = PDFName($self->{' data'}->{type});
  $self->{'BaseFont'} = PDFName($self->{' data'}->{fontname});
  if($self->{' data'}->{apiname}) {
      $self->{' apiname'} = $self->{' data'}->{apiname}.(((scalar @opts >0) && (!$self->{' data'}->{issymbol})) ? '+'.pdfkey(@opts) : '+0');
  } else {
      $self->{' apiname'} = 'cFx'.pdfkey($self->{' data'}->{fontname}).(((scalar @opts >0) && (!$self->{' data'}->{issymbol})) ? '+'.pdfkey(@opts) : '0');
  }
  $self->{'Name'} = PDFName($self->{' apiname'});

  $self->{'PDFAPIOptions'} = PDFStr(join(' ',@opts));

  unless($self->{' data'}->{iscore}) {
    $self->{'FontDescriptor'}=PDFDict();
    $self->{'FontDescriptor'}->{'Type'}=PDFName('FontDescriptor');
    $self->{'FontDescriptor'}->{'FontName'}=PDFName($self->{' data'}->{fontname});
    $self->{'FontDescriptor'}->{'FontBBox'}=PDFArray(map { PDFNum($_ || 0) } @{$self->{' data'}->{fontbbox}});
    unless($self->{' data'}->{issymbol} && !$self->{' data'}->{-ttfile}) {
      $self->{'FontDescriptor'}->{'Ascent'}=PDFNum($self->{' data'}->{ascender});
      $self->{'FontDescriptor'}->{'Descent'}=PDFNum($self->{' data'}->{descender});
      $self->{'FontDescriptor'}->{'ItalicAngle'}=PDFNum($self->{' data'}->{italicangle});
      $self->{'FontDescriptor'}->{'CapHeight'}=PDFNum($self->{' data'}->{capheight});
    # $self->{'FontDescriptor'}->{'StemV'}=PDFNum($self->{' data'}->{stemv});
    # $self->{'FontDescriptor'}->{'StemH'}=PDFNum($self->{' data'}->{stemh});
      $self->{'FontDescriptor'}->{'XHeight'}=PDFNum($self->{' data'}->{xheight});
    }

    $self->{'FontDescriptor'}->{'Flags'}=PDFNum($self->{' data'}->{flags}) if(defined $self->{' data'}->{flags});

    if(defined $self->{' data'}->{-ttfile}) {
        my $ttf = _look_for_fontfile($self->{' data'}->{-ttfile});
        if(defined $ttf) {
            my $ff=PDFDict();
            $pdf->new_obj($ff);
            $self->{'FontDescriptor'}->{FontFile2}=$ff;
            $ff->{Filter}=PDFArray(PDFName('FlateDecode'));
            $ff->{' streamfile'}=$ttf;
            $ff->{Length1}=PDFNum(-s $ttf);
        }
    }

  }

  $self->encode($opts{-encode});

  if(defined($pdf) && !$self->is_obj($pdf)) {
    $pdf->new_obj($self);
  }

  return($self);
}

=item $font = PDF::API2::CoreFont->new_api $api, $fontname, %options

Returns a corefont object. This method is different from 'new' that
it needs an PDF::API2-object rather than a PDF::API2::PDF::File-object.

=cut

sub new_api {
  my ($class,$api,@opts)=@_;

  my $obj=$class->new($api->{pdf},@opts);
  my $key=$obj->{' apiname'};

  $api->{pdf}->new_obj($obj) unless($obj->is_obj($api->{pdf}));

  $api->resource('Font',$key,$obj);

  $api->{pdf}->out_obj($api->{pages});
  return($obj);
}

=item PDF::API2::CoreFont->loadallfonts()

"Requires in" all fonts available as corefonts.

=cut

sub loadallfonts {
  foreach my $f (qw(
    andalemono
    arialrounded
    bankgothic
    courier
    courierbold
    courierboldoblique
    courieroblique
    georgia
    georgiabold
    georgiabolditalic
    georgiaitalic
    helveticaboldoblique
    helveticaoblique
    helveticabold
    helvetica
    impact
    ozhandicraft
    symbol
    timesbolditalic
    timesitalic
    timesroman
    timesbold
    trebuchet
    trebuchetbold
    trebuchetbolditalic
    trebuchetitalic
    verdana
    verdanabold
    verdanabolditalic
    verdanaitalic
    webdings
    wingdings
    zapfdingbats
  )){
    _look_for_font($f);
  }
}

=item $pdfstring = $font->text $text

Returns a properly formated string-representation of $text
for use in the PDF.

=cut

sub text {
  my ($self,$text,%opts)=@_;
  my $newtext='';
  if($opts{-utf8}) {
    $text=utf8_to_ucs2($text);
    foreach my $x (0..(length($text)>>1)-1) {
      $newtext.=pack("C",vec($text,$x,16) & 0xff);
    }
  } elsif($opts{-ucs2}) {
    foreach my $x (0..(length($text)>>1)-1) {
      $newtext.=pack("C",vec($text,$x,16) & 0xff);
    }
  } else {
  # foreach my $g (0..length($text)-1) {
  #   $newtext.=
  #     (substr($text,$g,1)=~/[\x00-\x1f\\\{\}\[\]\(\)]/)
  #     ? sprintf('\%03lo',vec($text,$g,8))
  #     : substr($text,$g,1) ;
  # }
    $newtext=$text;
    $newtext=~s/\\/\\\\/go;
    $newtext=~s/([\x00-\x1f])/sprintf('\%03lo',ord($1))/ge;
    $newtext=~s/([\{\}\[\]\(\)])/\\$1/g
  }
  return("($newtext)");
}

sub text_utf8 {
  my ($self,$text,%opts)=@_;
  return($self->text($text,-utf8=>1));
}

=item $pdfstring = $font->text_hex $text

Returns a properly formated hex-representation of $text
for use in the PDF.

=cut

sub text_hex {
  my ($font,$text,%opts)=@_;
  my $newtext='';
  if($opts{-utf8}) {
    $text=utf8_to_ucs2($text);
    foreach my $x (0..(length($text)>>1)-1) {
      $newtext.=sprintf('%02X',vec($text,$x,16) & 0xff);
    }
  } elsif($opts{-ucs2}) {
    foreach my $x (0..(length($text)>>1)-1) {
      $newtext.=sprintf('%02X',vec($text,$x,16) & 0xff);
    }
  } else {
    foreach (unpack("C*", $text)) {
      $newtext.= sprintf('%02X',$_);
    }
  }
  return('<'.$newtext.'>');
}

=item $wd = $font->width $text

Returns the width of $text as if it were at size 1.

=cut

sub width {
  my ($self,$text,%opts)=@_;
  my $width=0;
  if($opts{-utf8}) {
    $text=utf8_to_ucs2($text);
    foreach my $x (0..(length($text)>>1)-1) {
      my $ch=vec($text,$x,16) & 0xff;
      $width += $self->{' data'}{'wx'}{$self->{' data'}{'char'}[$ch] || 'space'} || $self->{' data'}{'wx'}{space};
    }
  } elsif($opts{-ucs2}) {
    foreach my $x (0..(length($text)>>1)-1) {
      my $ch=vec($text,$x,16) & 0xff;
      $width += $self->{' data'}{'wx'}{$self->{' data'}{'char'}[$ch] || 'space'} || $self->{' data'}{'wx'}{space};
    }
  } else {
    foreach (unpack("C*", $text)) {
      $width += $self->{' data'}{'wx'}{$self->{' data'}{'char'}[$_] || 'space'} || $self->{' data'}{'wx'}{space};
    }
  }
  $width/=1000;
  return($width);
}

=item @widths = $font->width_array $text

Returns the widths of the words in $text as if they were at size 1.

=cut

sub width_array {
  my ($self,$text,%opts)=@_;
  my @text=split(/\s+/,$text);
  my @widths=map {$self->width($_,%opts)} @text;
  return(@widths);
}

#=item ($llx,$lly,$urx,$ury) = $font->bbox $text
#
#Returns the texts bounding-box as if it were at size 1.
#
#=cut
#
#sub bbox {
# my ($self,$text,%opts)=@_;
# my $width=$self->width(substr($text,0,length($text)-1));
# my @f=@{$self->{' data'}{'bbox'}{$self->{' data'}{'char'}[unpack("C",substr($text,0,1))] || 'space'}};
# my @l=@{$self->{' data'}{'bbox'}{$self->{' data'}{'char'}[unpack("C",substr($text,-1,1))] || 'space'}};
# my ($high,$low);
# foreach (unpack("C*", $text)) {
#   $high = $self->{' data'}{'bbox'}{$self->{' data'}{'char'}[$_] || 'space'}->[3]>$high ? $self->{' data'}{'bbox'}{$self->{' data'}{'char'}[$_] || 'space'}->[3] : $high;
#   $low  = $self->{' data'}{'bbox'}{$self->{' data'}{'char'}[$_] || 'space'}->[1]<$low  ? $self->{' data'}{'bbox'}{$self->{' data'}{'char'}[$_] || 'space'}->[1] : $low;
# }
# return map {$_/1000} ($f[0],$low,(($width*1000)+$l[2]),$high);
#}
#
#=item $font->encode $encoding
#
#=cut

sub encode {
  my ($self,$encoding)=@_;

  my ($firstChar,$lastChar);

  my $pdfencode='WinAnsiEncoding';

  unless($self->{' data'}->{issymbol}) {
    if($encoding) {
      if($encoding eq 'asis') {
        $pdfencode='WinAnsiEncoding';
      } elsif($encoding eq 'winansi') {
        $pdfencode='WinAnsiEncoding';
        $self->{' data'}->{char}=[ @{$encodings->{winansi}} ];
      } elsif($encoding eq 'macroman') {
        $pdfencode='MacRomanEncoding';
        $self->{' data'}->{char}=[ @{$encodings->{macroman}} ];
      } elsif($encoding eq 'latin1') {
        $pdfencode='WinAnsiEncoding';
        $self->{' data'}->{char}=[ @{$encodings->{latin1}} ];
      } else {
        $pdfencode='WinAnsiEncoding';
        my $uniMap = PDF::API2::UniMap->new($encoding);
        $self->{' data'}->{char}=[ $uniMap->glyphs() ];
      }
      $encoding=1;
    } else {
      $pdfencode='WinAnsiEncoding';
      $encoding=0;
    }
  }

  $firstChar=1;
  $lastChar=255;

  $self->{'FirstChar'} = PDFNum($firstChar);
  $self->{'LastChar'} = PDFNum($lastChar);
  if($encoding || $self->{' data'}->{issymbol}) {
    $self->{'Encoding'}=PDFDict();
    $self->{'Encoding'}->{'Type'}=PDFName('Encoding');
    $self->{'Encoding'}->{'BaseEncoding'}=PDFName($pdfencode || 'WinAnsiEncoding');
    my $notdefbefore=1;
    my @w=();

    foreach my $w ($firstChar..$lastChar) {
      if(!defined($self->{' data'}->{char}->[$w]) ||($self->{' data'}->{char}->[$w] eq '.notdef')) {
        $notdefbefore=1;
        next;
      } else {
        if($notdefbefore) {
          push(@w,PDFNum($w))
        }
        $notdefbefore=0;
        push(@w,PDFName($self->{' data'}->{char}->[$w]));
      }
    }
    $self->{'Encoding'}->{'Differences'}=PDFArray(@w);
  } else {
    $self->{'Encoding'}=PDFName($pdfencode) if($pdfencode);
  }

  my @w = map {
    PDFNum($self->{' data'}->{'wx'}{$_ || '.notdef'} || $self->{' data'}->{missingwidth} || 300)
  } map {
    $self->{' data'}->{'char'}[$_]
  } ($firstChar..$lastChar);
  $self->{'Widths'}=PDFArray(@w);

  return($self);
}

=item $pdfname = $font->name

Returns the fonts pdfname.

=cut

sub name      { return $_[0]->{' apiname'}; }

=item $a = $font->ascender

Returns the fonts ascender value.

=cut

sub data      { return $_[0]->{' data'}; }
sub ascender      { return $_[0]->{' data'}->{ascender}; }

=item $d = $font->descender

Returns the fonts descender value.

=cut

sub descender     { return $_[0]->{' data'}->{descender}; }

=item $ia = $font->italicangle

Returns the fonts italicangle value.

=cut

sub italicangle { return $_[0]->{' data'}->{italicangle}; }

=item ($llx,$lly,$urx,$ury) = $font->fontbbox

Returns the fonts bounding-box.

=cut

sub fontbbox     { return @{$_[0]->{' data'}->{fontbbox}}; }

=item $ch = $font->capheight

Returns the fonts capheight value.

=cut

sub capheight   { return $_[0]->{' data'}->{capheight}; }

=item $xh = $font->xheight

Returns the fonts xheight.

=cut

sub xheight     { return $_[0]->{' data'}->{xheight}; }

=item $ul = $font->underlineposition

Returns the fonts underlineposition.

=cut

sub underlineposition { return $_[0]->{' data'}->{underlineposition}; }


BEGIN {

  $alias = {
    ## Windows Fonts with Type1 equivalence

#    'arialbolditalic'   => 'helveticaboldoblique',
#    'arialbold'     => 'helveticabold',
#    'arialitalic'     => 'helveticaoblique',
#    'arial'       => 'helvetica',

    'times'       => 'timesroman',
    'timesnewromanbolditalic' => 'timesbolditalic',
    'timesnewromanbold'   => 'timesbold',
    'timesnewromanitalic'   => 'timesitalic',
    'timesnewroman'     => 'timesroman',

    'couriernewbolditalic'    => 'courierboldoblique',
    'couriernewbold'    => 'courierbold',
    'couriernewitalic'    => 'courieroblique',
    'couriernew'      => 'courier',


    ## unix/TeX-ish aliases

    'typewriterbolditalic'    => 'courierboldoblique',
    'typewriterbold'    => 'courierbold',
    'typewriteritalic'    => 'courieroblique',
    'typewriter'      => 'courier',

    'sansbolditalic'    => 'helveticaboldoblique',
    'sansbold'      => 'helveticabold',
    'sansitalic'      => 'helveticaoblique',
    'sans'        => 'helvetica',

    'serifbolditalic'   => 'timesbolditalic',
    'serifbold'     => 'timesbold',
    'serifitalic'     => 'timesitalic',
    'serif'       => 'timesroman',

    'greek'       => 'symbol',
    'bats'        => 'zapfdingbats',
  };

  $subs = {
    'impactitalic'      => {
              'apiname' => 'Imp2',
              '-alias'  => 'impact',
              'fontname'  => 'Impact,Italic',
              'italicangle' => -12,
            },
    'ozhandicraftbold'    => {
              'apiname' => 'Oz2',
              '-alias'  => 'ozhandicraft',
              'fontname'  => 'OzHandicraftBT,Bold',
              'italicangle' => 0,
              'flags' => 32+262144,
            },
    'ozhandicraftitalic'    => {
              'apiname' => 'Oz3',
              '-alias'  => 'ozhandicraft',
              'fontname'  => 'OzHandicraftBT,Italic',
              'italicangle' => -15,
              'flags' => 96,
            },
    'ozhandicraftbolditalic'  => {
              'apiname' => 'Oz4',
              '-alias'  => 'ozhandicraft',
              'fontname'  => 'OzHandicraftBT,BoldItalic',
              'italicangle' => -15,
              'flags' => 96+262144,
            },
    'arialroundeditalic'  => {
              'apiname' => 'ArRo2',
              '-alias'  => 'arialrounded',
              'fontname'  => 'ArialRoundedMTBold,Italic',
              'italicangle' => -15,
              'flags' => 96+262144,
            },
    'arialitalic'  => {
              'apiname' => 'Ar2',
              '-alias'  => 'arial',
              'fontname'  => 'ArialUnicodeMS,Italic',
              'italicangle' => -15,
              'flags' => 96,
            },
    'arialbolditalic'  => {
              'apiname' => 'Ar3',
              '-alias'  => 'arial',
              'fontname'  => 'ArialUnicodeMS,BoldItalic',
              'italicangle' => -15,
              'flags' => 96+262144,
            },
    'arialbold'  => {
              'apiname' => 'Ar4',
              '-alias'  => 'arial',
              'fontname'  => 'ArialUnicodeMS,Bold',
              'flags' => 32+262144,
            },
    'bankgothicbold'  => {
              'apiname' => 'Bg2',
              '-alias'  => 'bankgothic',
              'fontname'  => 'BankGothicMediumBT,Bold',
              'flags' => 32+262144,
            },
    'bankgothicbolditalic'  => {
              'apiname' => 'Bg3',
              '-alias'  => 'bankgothic',
              'fontname'  => 'BankGothicMediumBT,BoldItalic',
              'italicangle' => -15,
              'flags' => 96+262144,
            },
    'bankgothicitalic'  => {
              'apiname' => 'Bg4',
              '-alias'  => 'bankgothic',
              'fontname'  => 'BankGothicMediumBT,Italic',
              'italicangle' => -15,
              'flags' => 96,
            },
  };

  $fonts = { };

  $encodings = { };

  eval "require PDF::API2::CoreFont::defaultencodings; ";

}

1;

__END__

=head1 SUPPORTED FONTS

=item PDF::API::CoreFont supports the following 'Adobe Core Fonts':

  Courier
  Courier-Bold
  Courier-BoldOblique
  Courier-Oblique
  Helvetica
  Helvetica-Bold
  Helvetica-BoldOblique
  Helvetica-Oblique
  Symbol
  Times-Bold
  Times-BoldItalic
  Times-Italic
  Times-Roman
  ZapfDingbats

=item PDF::API::CoreFont supports the following 'Windows Fonts':

  Andale,Mono
  Arial
  Arial,Bold
  Arial,BoldItalic
  Arial,Italic
  BankGothic
  BankGothic,Bold
  BankGothic,BoldItalic
  BankGothic,Italic
  CourierNew
  CourierNew,Bold
  CourierNew,BoldItalic
  CourierNew,Italic
  Georgia
  Georgia,Bold
  Georgia,BoldItalic
  Georgia,Italic
  Impact
  Impact,Italic
  OzHandicraft
  OzHandicraft,Bold
  OzHandicraft,BoldItalic
  OzHandicraft,Italic
  TimesNewRoman
  TimesNewRoman,Bold
  TimesNewRoman,BoldItalic
  TimesNewRoman,Italic
  Trebuchet
  Trebuchet,Bold
  Trebuchet,BoldItalic
  Trebuchet,Italic
  Verdana
  Verdana,Bold
  Verdana,BoldItalic
  Verdana,Italic
  Webdings
  Wingdings

=item PDF::API::CoreFont supports the following 'Unix-ish Fonts' as aliases:

  sans
  sans,bold
  sans,bolditalic
  sans,italic
  serif
  serif,bold
  serif,bolditalic
  serif,italic
  typewriter
  typewriter,bold
  typewriter,bolditalic
  typewriter,italic
  greek
  bats

=head1 AUTHOR

alfred reibenschuh

=cut


