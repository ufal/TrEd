#==================================================================
#	PDF::API2::PDF::ImagePPM
#==================================================================
package PDF::API2::PDF::ImagePPM;

use strict;
use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Image;
use vars qw(@ISA $VERSION );

@ISA = qw(PDF::API2::PDF::Image);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

=head2 PDF::API2::PDF::ImagePPM

=item $img = PDF::API2::PDF::ImagePPM->new $pdf, $name, $filename

Returns a new image object.

=cut

sub new {
	my ($class,$pdf,$name,$file)=@_;
	my $self = $class->SUPER::new($pdf,$name);
	$self->readppm($pdf,$file);
	return($self);
}

sub readppm {
	my $self = shift @_;
	my $pdf = shift @_;
	my $file = shift @_;

	my ($buf,$t,$s,$line);
	my ($w,$h,$bpc,$cs,$img,@img)=(0,0,'','','');
	open(INF,$file);
	binmode(INF);
	$buf=<INF>;
	$buf.=<INF>;
	($t)=($buf=~/^(P\d+)\s+/);
	if($t eq 'P4') {
		($t,$w,$h)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+/);
		$bpc=1;
		$s=0;
		for($line=($w*$h/8);$line>0;$line--) {
			read(INF,$buf,1);
			push(@img,$buf);
		}
		$cs='DeviceGray';
	} elsif($t eq 'P5') {
		$buf.=<INF>;
		($t,$w,$h,$bpc)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/);
		if($bpc==255){
			$s=0;
		} else {
			$s=255/$bpc;
		}
		$bpc=8;
		for($line=($w*$h);$line>0;$line--) {
			read(INF,$buf,1);
			if($s>0) {
				$buf=pack('C',(unpack('C',$buf)*$s));
			}
			push(@img,$buf);
		}
		$cs='DeviceGray';
	} elsif($t eq 'P6') {
		$buf.=<INF>;
		($t,$w,$h,$bpc)=($buf=~/^(P\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/);
		if($bpc==255){
			$s=0;
		} else {
			$s=255/$bpc;
		}
		$bpc=8;
		if($s>0) {
			for($line=($w*$h);$line>0;$line--) {
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
				read(INF,$buf,1);
				push(@img,pack('C',(unpack('C',$buf)*$s)));
			}
		} else {
			@img=<INF>;
		}
		$cs='DeviceRGB';
	}
	close(INF);

	$self->width($w);
	$self->height($h);

	$self->bpc($bpc);

	$self->filters('FlateDecode');

        $self->colorspace($cs);

	$self->{' stream'}=join('',@img);

	return($self);
}

1;