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
#	PDF::API2::Font
#
#=======================================================================
package PDF::API2::Font;
use strict;
use PDF::API2::UniMap;
use PDF::API2::Util;
use PDF::API2::PDF::Utils;
use vars qw( $VERSION );
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


=head2 PDF::API2::Font

=item $font2 = $font->clone $subkey

Returns a clone of a font object.

=cut

sub copy { die "COPY NOT IMPLEMENTED !!!";}

sub clone {
	my $self=shift @_;
	my $key=shift @_ || localtime();
	my $res=$self->copy($self->{' apipdf'});
	$self->{' apipdf'}->new_obj($res);
	$res->{' apiname'}.='_CLONEx'.pdfkey($key);
	$res->{'Name'}=PDFName($res->{' apiname'});

	$res->{' api'}->resource('Font',$res->{' apiname'},$res);

	return($res);
}


=item @glyphs = $font->glyphs $encoding

Returns an array with glyphnames of the specified encoding.

=cut

sub glyphs {
	my ($self,$enc) = @_;
	$self->{' apipdf'}->{' encoding'}=$self->{' apipdf'}->{' encoding'} || {};
	$self->{' apipdf'}->{' encoding'}->{$enc}=$self->{' apipdf'}->{' encoding'}->{$enc} || PDF::API2::UniMap->new($enc);
	return($self->{' apipdf'}->{' encoding'}->{$enc}->glyphs);
}

=item $font->encode $encoding

Changes the encoding of the font object. If you want more than one encoding
for one font use 'clone' and then 'encode'.

B<Note:> The following encodings are supported (as of version 0.1.16_beta):

	adobe-standard adobe-symbol adobe-zapf-dingbats
	cp1250 cp1251 cp1252
	cp437 cp850
	es es2 pt pt2
	iso-8859-1 iso-8859-2 latin1 latin2
	koi8-r koi8-u
	macintosh
	microsoft-dingbats

B<Note:> Other encodings must be seperately installed via the pdf-api2-unimaps archive.

=cut

sub encode {
	my $self=shift @_;
	my ($encoding,@glyphs)=@_;
	if(scalar @glyphs < 1) {
		eval {
			@glyphs=$self->glyphs($encoding);
		};
		$encoding='custom';
	}

	if($self->{' apifontlight'}) {
		$self->encodeProperLight($encoding,32,255,@glyphs);
	} else {
		$self->encodeProper($encoding,32,255,@glyphs);
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
	} else {
		foreach my $g (0..length($text)-1) {
			$newtext.=
				(substr($text,$g,1)=~/[\x00-\x1f\\\{\}\[\]\(\)]/)
				? sprintf('\%03lo',vec($text,$g,8))
				: substr($text,$g,1) ;
		}
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

sub ascent      { return $_[0]->{' ascent'}; }
sub descent     { return $_[0]->{' descent'}; }
sub italicangle { return $_[0]->{' italicangle'}; }
sub fontbbx     { return @{$_[0]->{' fontbbox'}}; }
sub capheight   { return $_[0]->{' capheight'}; }
sub xheight     { return $_[0]->{' xheight'}; }

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
