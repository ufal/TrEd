#==================================================================
#	PDF::API2::PDF::ImageJPEG
# http://www.funducode.com/freec/Fileformats/format3/format3b.htm
#==================================================================
package PDF::API2::PDF::ImageJPEG;

use strict;
use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Image;
use IO::File;
use PDF::API2::IOString;

use vars qw(@ISA $VERSION );

@ISA = qw(PDF::API2::PDF::Image);

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

=head2 PDF::API2::PDF::ImageJPEG

=item $img = PDF::API2::PDF::ImageJPEG->new $pdf,$name, $filename

Returns a new image object.

=cut

sub new {
	my ($class,$pdf,$name,$file)=@_;
	my $self = $class->SUPER::new($pdf,$name);
	my $fh = IO::File->new;
	open($fh,$file);
	binmode($fh);

	$self->readjpeg($pdf,$fh);
	$fh->close;
	$self->{' streamfile'}=$file;
	$self->{Length}=PDFNum(-s $file);
	return($self);
}

sub new_stream {
	my ($class,$pdf,$name,$file)=@_;
	my $self = $class->SUPER::new($pdf,$name);
	my $fh = PDF::API2::IOString->new($file);
	$self->readjpeg($pdf,$fh);
	$self->{' stream'}=$fh->{buf};
	$self->{Length}=PDFNum(length $self->{' stream'});
	return($self);
}

sub new_fh {
	my ($class,$pdf,$name,$fh)=@_;
	my $self = $class->SUPER::new($pdf,$name);
	$self->readjpeg($pdf,$fh);
	if(ref($fh) eq 'PDF::API2::IOString') {
		$self->{' stream'}=$fh->{buf};
		$self->{Length}=PDFNum(length $self->{' stream'});
	} else {
	}
	return($self);
}

sub readjpeg {
	my $self = shift @_;
	my $pdf = shift @_;
	my $fh = shift @_;

	my ($buf, $p, $h, $w, $c, $ff, $mark, $len);

	$fh->seek(0,0);
	$fh->read($buf,2);
	while (1) {
		$fh->read($buf,4);
		my($ff, $mark, $len) = unpack("CCn", $buf);
		last if( $ff != 0xFF);
		last if( $mark == 0xDA || $mark == 0xD9);  # SOS/EOI
		last if( $len < 2);
		last if( $fh->eof);
		$fh->read($buf,$len-2);
		next if ($mark == 0xFE);
		next if ($mark >= 0xE0 && $mark <= 0xEF);
		if (($mark >= 0xC0) && ($mark <= 0xC1)) {
			($p, $h, $w, $c) = unpack("CnnC", substr($buf, 0, 6));
			last;
		}
	}

	$self->width($w);
	$self->height($h);

	$self->bpc($p);

	$self->filters('DCTDecode');
	$self->{' nofilt'}=1;

	if($c==3) {
	        $self->colorspace('DeviceRGB');
	} elsif($c==4) {
	        $self->colorspace('DeviceCMYK');
	} elsif($c==1) {
	        $self->colorspace('DeviceGray');
	}

	return($self);
}

1;