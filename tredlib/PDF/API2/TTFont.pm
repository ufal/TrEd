#=======================================================================
#	 ____  ____  _____              _    ____ ___   ____
#	|  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#	| |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#	|  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#	|_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#	Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
#	This library is free software; you can redistribute it 
#	and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
#	PDF::API2::TTFont
#
#=======================================================================
package PDF::API2::TTFont;
use strict;
use PDF::API2::UniMap qw( utf8_to_ucs2 );
use PDF::API2::Util;
use PDF::API2::Font;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::TTFont0;
use POSIX;

use vars qw(@ISA $VERSION);
@ISA = qw( PDF::API2::PDF::TTFont0 PDF::API2::Font );
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


=head2 PDF::API2::TTFont

Subclassed from PDF::API2::PDF::TTFont0 and PDF::API2::Font.

=item $font = PDF::API2::TTFont->new $pdf,$ttffile,$pdfname

Returns a truetype font object (called from $pdf->ttfont).

=cut

sub new {
	my ($class, $pdf,$file,$name) = @_;

	$class = ref $class if ref $class;
	my $self = $class->SUPER::new($pdf,$file,$name, -subset => 1);

	my $font=$self->{' font'};
	$font->{'cmap'}->read;
	$font->{'hmtx'}->read;
	$font->{'post'}->read;
	$font->{'loca'}->read;
	my $upem = $font->{'head'}->read->{'unitsPerEm'};

	$self->{' unicid'}=();
	$self->{' uniwidth'}=();
	$self->{' unibbx'}=();
	my @map=$font->{'cmap'}->reverse;
	foreach my $x (0..scalar(@map)) {
		$self->{' unicid'}{$map[$x]||0}=$x;
		$self->{' uniwidth'}{$map[$x]||0}=$font->{'hmtx'}{'advance'}[$x]*1000/$upem;
		$self->{' unibbx'}{$map[$x]||0}=[
			ceil($font->{'loca'}->{'glyphs'}[$x]->read->{'xMin'} * 1000 / $upem),
			ceil($font->{'loca'}->{'glyphs'}[$x]->{'yMin'} * 1000 / $upem),
			ceil($font->{'loca'}->{'glyphs'}[$x]->{'xMax'} * 1000 / $upem),
			ceil($font->{'loca'}->{'glyphs'}[$x]->{'yMax'} * 1000 / $upem)
		] if($font->{'loca'}->{'glyphs'}[$x]);
	}
	$self->{' encoding'}='latin1';
	$self->{' chrcid'}={};
	$self->{' chrcid'}->{'latin1'}=();
	$self->{' chrwidth'}={};
	$self->{' chrwidth'}->{'latin1'}=();
	$self->{' chrbbx'}={};
	$self->{' chrbbx'}->{'latin1'}=();
	foreach my $x (0..255) {
		$self->{' chrcid'}->{'latin1'}{$x}=$self->{' unicid'}{$x}||$self->{' unicid'}{32};
		$self->{' chrwidth'}->{'latin1'}{$x}=$self->{' uniwidth'}{$x}||$self->{' uniwidth'}{32};
		$self->{' chrbbx'}->{'latin1'}{$x}=$self->{' unibbx'}{$x}||$self->{' unibbx'}{32};
	}
    
    $self->{' ascent'}=int($font->{'hhea'}->read->{'Ascender'} * 1000 / $upem);
    $self->{' descent'}=int($font->{'hhea'}{'Descender'} * 1000 / $upem);

	eval {
		$self->{' capheight'}=int(
			$font->{'loca'}->read->{'glyphs'}[
				$font->{'post'}{'STRINGS'}{"H"}||0
			]->read->{'yMax'}
			* 1000 / $upem
		);
	};
	$self->{' capheight'}||=0;
	
	eval {
		$self->{' xheight'}=int(
			$font->{'loca'}->read->{'glyphs'}[
				$font->{'post'}{'STRINGS'}{"x"}||0
			]->read->{'yMax'}
			* 1000 / $upem
		);
	};
	$self->{' xheight'}||=0;

	$self->{' italicangle'}=$font->{'post'}->read->{'italicAngle'};

	$self->{' fontbbox'}=[
		int($font->{'head'}{'xMin'} * 1000 / $upem),
	        int($font->{'head'}{'yMin'} * 1000 / $upem),
	        int($font->{'head'}{'xMax'} * 1000 / $upem),
		int($font->{'head'}{'yMax'} * 1000 / $upem)
	];

	$self->{' apiname'}=$name;
	$self->{' apipdf'}=$pdf;

	return($self);
}

=item $pdfstring = $font->text_ucs2 $text

Returns a properly formated string-representation of $text
for use in the PDF but requires $text to be in UCS2.

=cut

sub text_ucs2 {
	my ($self,$text)=@_;
	my ($newtext);
	foreach my $x (0..(length($text)>>1)-1) {
		my $g=$self->{' unicid'}{vec($text,$x,16)}||0;
		$newtext.= sprintf('%04x',$g);
		vec($self->{' subvec'},$g,1)=1;
	}
	return("<$newtext>");
}

=item $pdfstring = $font->text_utf8 $text

Returns a properly formated string-representation of $text
for use in the PDF but requires $text to be in UTF8.

=cut

sub text_utf8 {
	my ($self,$text)=@_;
	$text=utf8_to_ucs2($text);
	return $self->text_ucs2($text);
}

=item $pdfstring = $font->text $text

Returns a properly formated string-representation of $text
for use in the PDF.

=cut

sub text {
	my ($self,$text,$enc)=@_;
	$enc=$enc||$self->{' encoding'};
	if(lc($enc) eq 'ucs2') {
		return $self->text_ucs2($text);
	} elsif(lc($enc) eq 'utf8') {
		return $self->text_utf8($text);
	}
	my $newtext='';
	$self->{' subvec'}='' unless($self->{' subvec'});
	foreach (unpack("C*", $text)) {
		my $g=$self->{' chrcid'}{$enc}{$_}||32;
		$newtext.= sprintf('%04x',$g);
		vec($self->{' subvec'},$g,1)=1;
	}
	return("<$newtext>");
}

=item $wd = $font->width $text

Returns the width of $text as if it were at size 1.

=cut

sub width {
	my ($self,$text,%opts)=@_;
	my $enc=$opts{-encode}||$self->{' encoding'};
	my $width=0;
	if($opts{-utf8}) {
		$text=utf8_to_ucs2($text);
		foreach my $x (0..(length($text)>>1)-1) {
			$width += $self->{' uniwidth'}{vec($text,$x,16)};
		}
	} elsif($opts{-ucs2}) {
			foreach my $x (0..(length($text)>>1)-1) {
				$width += $self->{' uniwidth'}{vec($text,$x,16)};
			}
		} else {
			foreach (unpack("C*", $text)) {
				$width += $self->{' chrwidth'}{$enc}{$_||0};
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
	if($opts{-ucs2}) {
		my @text=split(/\0x00\0x20/,$text);
		my @widths=map {$self->width($_,%opts)} @text;
		return(@widths);
	} else {
		my @text=split(/\s+/,$text);
		my @widths=map {$self->width($_,%opts)} @text;
		return(@widths);
	}
}

=item $wd = $font->width_ucs2 $text

Returns the width of $text as if it were at size 1,
but requires $text to be in UCS2.

=cut

sub width_ucs2 {
	my ($self,$text,%opts)=@_;
	my ($width);
	foreach my $x (0..(length($text)>>1)-1) {
		$width += $self->{' uniwidth'}{vec($text,$x,16)};
	}
	$width/=1000;
	return($width);
}

=item $wd = $font->width_utf8 $text

Returns the width of $text as if it were at size 1,
but requires $text to be in UTF8.

=cut

sub width_utf8 {
	my ($self,$text,%opts)=@_;
	$text=utf8_to_ucs2($text);
	return $self->width_ucs2($text);
}

=item ($llx,$lly,$urx,$ury) = $font->bbox $text

Returns the texts bounding-box as if it were at size 1.

=cut

sub bbox {
	my ($self,$text,%opts)=@_;
	my $enc=$opts{-encode}||$self->{' encoding'};
	my $width=$self->width(substr($text,0,length($text)-1),$enc);
	my @f=@{$self->{' chrbbx'}{$enc}{unpack("C",substr($text,0,1))}};
	my @l=@{$self->{' chrbbx'}{$enc}{unpack("C",substr($text,-1,1))}};
	my ($high,$low);
	foreach (unpack("C*", $text)) {
		$high = $self->{' chrbbx'}{$enc}{$_}->[3]>$high ? $self->{' chrbbx'}{$enc}{$_}->[3] : $high;
		$low  = $self->{' chrbbx'}{$enc}{$_}->[1]<$low  ? $self->{' chrbbx'}{$enc}{$_}->[1] : $low;
	}
	return map {$_/1000} ($f[0],$low,(($width*1000)+$l[2]),$high);
}

=item ($llx,$lly,$urx,$ury) = $font->bbox_ucs2 $ucs2text

Returns the texts bounding-box as if it were at size 1.

=cut

sub bbox_ucs2 {
	my ($self,$text)=@_;
	my $width=$self->width_ucs2($text);
	my @f=@{$self->{' unibbx'}{vec($text,0,16)}};
	my @l=@{$self->{' unibbx'}{vec($text,(length($text)>>1)-1,16)}};
	my ($high,$low);
	foreach my $x (0..(length($text)>>1)-1) {
		$high = $self->{' unibbx'}{vec($text,$x,16)}->[3]>$high ? $self->{' unibbx'}{vec($text,$x,16)}->[3] : $high;
		$low  = $self->{' unibbx'}{vec($text,$x,16)}->[1]<$low  ? $self->{' unibbx'}{vec($text,$x,16)}->[1] : $low;
	}
	return map {$_/1000} ($f[0],$low,(($width*1000)+$l[2]),$high);
}

=item ($llx,$lly,$urx,$ury) = $font->bbox_utf8 $utf8text

Returns the texts bounding-box as if it were at size 1.

=cut

sub bbox_utf8 {
	my ($self,$text)=@_;
	$text=utf8_to_ucs2($text);
	return $self->bbox_ucs2($text);
}

=item $font->encode $encoding

Changes the encoding of the font object. Since encodings are one virtual
in ::API2 for truetype fonts you DONT have to use 'clone'.

=cut

sub encode {
	my ($self,$enc)=@_;

	my $map=PDF::API2::UniMap->new($enc);

	my $ttf=$self->{' font'};
	my $upem = $ttf->{'head'}->read->{'unitsPerEm'};

	$self->{' encoding'}=$enc;
	$self->{' chrcid'}->{$enc}=$self->{' chrcid'}->{$enc}||{};
	$self->{' chrwidth'}->{$enc}=$self->{' chrwidth'}->{$enc}||{};
	if(scalar keys(%{$self->{' chrcid'}->{$enc}}) < 1) {
		foreach my $x (0..255) {
			$self->{' chrcid'}->{$enc}{$x}=
				$self->{' unicid'}{$map->{'c2u'}->{$x}||32}||$self->{' unicid'}{32};
			$self->{' chrwidth'}->{$enc}{$x}=
				$ttf->{'hmtx'}{'advance'}[$self->{' unicid'}{$map->{'c2u'}->{$x}||32}||$self->{' unicid'}{32}]*1000/$upem;
		}
	}
	return($self);
}

sub outobjdeep {
	my ($self, @opts) = @_;
	foreach my $k (qw/ api apipdf /) {
		$self->{" $k"}=undef;
		delete($self->{" $k"});
	}
	$self->SUPER::outobjdeep(@opts);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
