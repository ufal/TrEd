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
# PDF::API2::SynFont
#
#=======================================================================
package PDF::API2::SynFont;

use PDF::API2::Util;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Dict;
use Math::Trig;
use POSIX;
use vars qw(@ISA $VERSION $fkey %fkeyset);
@ISA = qw( PDF::API2::PDF::Dict );

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

my $fkey='0';
my %fkeyset=(
	'B' => { -bold => 4 },
	'BI' => { -bold => 4, -oblique => 12 },
	'I' => { -oblique => 12 },
	'S' => { -slant => 0.65 },
	'SB' => { -bold => 4, -slant => 0.65 },
	'SBI' => { -bold => 4, -oblique => 12, -slant => 0.65 },
	'SI' => { -oblique => 12, -slant => 0.65 },
);

sub name_to_key {
  my $s=join('-',@_);
  $s=~s|[\001-\040\177-\377%()\[\]{}<>#/_\-]+|-|og;
  $s=~s|\-+$||og;
  $s=~s|^\-+||og;
  return($s);
}

=item $font = PDF::API2::SynFont->new $pdf, $font, %options

Returns a font object.

=cut

sub new {
  my ($class,$pdf,$font,@opts) = @_;
  my $self;
  my %opts=();
  my $first=1;
  my $last=255;

  %opts=@opts if((scalar @opts)%2 == 0);
  # check if the short key is given
  %opts=%{$fkeyset{uc($opts[0])}} if(scalar @opts == 1 && $fkeyset{uc($opts[0])});
  $class = ref $class if ref $class;
  $self=$class->SUPER::new();
  $pdf->new_obj($self);
  my $slant=$opts{-slant}||1;
  my $oblique=$opts{-oblique}||0;
  my $bold=($opts{-bold}||0)*10; # convert to em

  $self->{' slant'}=$slant;
  $self->{' oblique'}=$oblique;
  $self->{' bold'}=$bold;
  $self->{' boldmove'}=0.001;

  $self->{' fontbbox'}=ref($font->fontbbox) ? $font->fontbbox : [$font->fontbbox];
  $self->{' fontbbox'}->[0]*=$slant;
  $self->{' fontbbox'}->[2]*=$slant;
  $self->{' font'}=$font;
  $self->{' apiname'} = $font->{' apiname'}.'+S'.pdfkey("S $slant O $oblique B $bold");
  $self->{'Type'} = PDFName('Font');
  $self->{'Subtype'} = PDFName('Type3');
  $self->{'BaseFontName'} = PDFStr(name_to_key($font->{BaseFont}->val."+S $slant O $oblique B $bold"));
  $self->{'Name'} = PDFName($self->{' apiname'});
  $self->{'FirstChar'} = PDFNum($first);
  $self->{'LastChar'} = PDFNum($last);
  $self->{'FontBBox'} = PDFArray(map { PDFNum($_) } (@{$self->fontbbox}) );
  $self->{'FontMatrix'} = PDFArray(map { PDFNum($_) } ( 0.001, 0, 0, 0.001, 0, 0 ) );

  my @w=();

  $self->{'Encoding'}=$font->{Encoding};
  @w = map { PDFNum(int($self->width(chr($_))*1000)) } ($first..$last);
  $self->{'Widths'}=PDFArray(@w);

  my $procs=PDFDict();
  $pdf->new_obj($procs);
  $self->{'CharProcs'} = $procs;

  $self->{Resources}=PDFDict();
  $self->{Resources}->{ProcSet}=PDFArray(map { PDFName($_) } qw(PDF Text ImageB ImageC ImageI));
  my $xo=PDFDict();
  $self->{Resources}->{Font}=$xo;
  $self->{Resources}->{Font}->{$font->name}=$font;

  foreach my $w ($first..$last) {
    $procs->{$font->data->{char}->[$w]}=PDFDict();
    $procs->{$font->data->{char}->[$w]}->{Filter}=PDFArray(PDFName('FlateDecode'));
    $procs->{$font->data->{char}->[$w]}->{' stream'}=int($self->width(chr($w))*1000)." 0 ".join(' ',@{$self->fontbbox})." d1 ";
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" BT ";
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" ".join(' ',1,0,tan(deg2rad($oblique)),1,0,0)." Tm " if($oblique);
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" /".($font->name)." 1000 Tf ";
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" ".($slant*100)." Tz " if($slant!=1);
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" 2 Tr ".($bold)." w " if($bold);
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" ".$self->text(chr($w))." Tj ";
    $procs->{$font->data->{char}->[$w]}->{' stream'}.=" ET ";
    $pdf->new_obj($procs->{$font->data->{char}->[$w]});
  }
  $procs->{'.notdef'}=$procs->{$font->data->{char}->[32]};

  return($self);
}

=item $font = PDF::API2::SynFont->new_api $api, $name, %options

Returns a synfont object. This method is different from 'new' that
it needs an PDF::API2-object rather than a Text::PDF::File-object.

=cut

sub new_api {
  my ($class,$api,@opts)=@_;

  my $obj=$class->new($api->{pdf},@opts);
  my $key=$obj->{' apiname'};

  $api->resource('Font',$key,$obj);
  $api->resource('Font',$obj->{' apiname'},$obj);

  $api->{pdf}->out_obj($api->{pages});
  return($obj);
}

=item $pdfstring = $font->text $text

Returns a properly formated string-representation of $text
for use in the PDF.

=cut

sub text {
  my ($self,$text)=@_;
  return( $self->{' font'}->text($text) );
}

=item $pdfstring = $font->text_ucs2 $text

Returns a properly formated string-representation of $text
for use in the PDF but requires $text to be in UCS2.

=cut

sub text_ucs2 {
  my ($self,$text)=@_;
  return( $self->{' font'}->text_ucs2($text) );
}

=item $pdfstring = $font->text_utf8 $text

Returns a properly formated string-representation of $text
for use in the PDF but requires $text to be in UTF8.

=cut

sub text_utf8 {
  my ($self,$text)=@_;
  return( $self->{' font'}->text_utf8($text) );
}

=item $wd = $font->width $text

Returns the width of $text as if it were at size 1.

=cut

sub width {
  my ($self,$text,%opts)=@_;
  my $width=$self->{' font'}->width($text,%opts);
  return( $self->{' bold'}*$self->{' boldmove'}+$width*$self->{' slant'} );
}

=item $wd = $font->width_ucs2 $text

Returns the width of $text as if it were at size 1,
but requires $text to be in UCS2.

=cut

sub width_ucs2 {
  my ($self,$text,%opts)=@_;
  my $width=$self->{' font'}->width_ucs2($text,%opts);
  return( $self->{' bold'}*$self->{' boldmove'}+$width*$self->{' slant'} );
}

=item $wd = $font->width_utf8 $text

Returns the width of $text as if it were at size 1,
but requires $text to be in UTF8.

=cut

sub width_utf8 {
  my ($self,$text,%opts)=@_;
  my $width=$self->{' font'}->width_utf8($text,%opts);
  return( $self->{' bold'}*$self->{' boldmove'}+$width*$self->{' slant'} );
}

=item @widths = $font->width_array $text

Returns the widths of the words in $text as if they were at size 1.

=cut

sub width_array {
  my ($self,$text,%opts)=@_;
  my @w = $self->{' font'}->width_array($text,%opts);
  @w=map { ( $self->{' bold'}*$self->{' boldmove'}+$_*$self->{' slant'} ) } @w;
  return(@w);
}


sub name { return (shift @_)->{' apiname'}; }

sub fontbbox { return (shift @_)->{' fontbbox'}; }

sub capheight { return((shift @_)->{' font'}->capheight); }
sub xheight { return((shift @_)->{' font'}->xheight); }
sub underlineposition { return((shift @_)->{' font'}->underlineposition); }
sub underlinethickness { return((shift @_)->{' font'}->underlinethickness); }
sub ascender { return((shift @_)->{' font'}->ascender); }
sub descender { return((shift @_)->{' font'}->descender); }

sub issymbol { return((shift @_)->{' font'}->issymbol); }
sub unicode { return( undef ); }


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut

