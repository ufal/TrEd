#==================================================================
#	PDF::API2::PDF::ImagePNG
#==================================================================
package PDF::API2::PDF::ImagePNG;

use strict;
use PDF::API2::PDF::Dict;
use POSIX;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Image;
use Compress::Zlib;
use vars qw(@ISA $VERSION);

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

@ISA = qw(PDF::API2::PDF::Image);

=head2 PDF::API2::PDF::ImagePNG

=item $img = PDF::API2::PDF::ImagePNG->new $pdf, $name, $filename

Returns a new image object.

=cut

sub new {
	my ($class,$pdf,$name,$file)=@_;
	my $self = $class->SUPER::new($pdf,$name);
	$self->readpng($pdf,$file);
	return($self);
}

sub readpng {
	my $self=shift @_;
	my $pdf=shift @_;
	my $file=shift @_;
	
	my ($buf,$l,$crc,$w,$h,$bpc,$cs,$cm,$fm,$im,$image,$palete,$transparency);
	open(INF,$file);
	binmode(INF);
	seek(INF,8,0);
	while(!eof(INF)) {
		read(INF,$buf,4);
		$l=unpack('N',$buf);
		read(INF,$buf,4);
		if($buf eq 'IHDR') {
			read(INF,$buf,$l);
			($w,$h,$bpc,$cs,$cm,$fm,$im)=unpack('NNCCCCC',$buf);
			warn "Unsupported Compression($cm)/Filter($fm)/Interlace($im) Method" if($im||$fm||$cm);
		} elsif($buf eq 'PLTE') {
			read(INF,$buf,$l);
			$palete=$buf;
		} elsif($buf eq 'IDAT') {
			read(INF,$buf,$l);
			$image.=$buf;
		} elsif($buf eq 'tRNS') {
			read(INF,$buf,$l);
			$transparency=$buf;
		} elsif($buf eq 'IEND') {
			last;
		} else {
			# skip ahead
			seek(INF,$l,1);
		}
		read(INF,$buf,4);
		$crc=$buf;
	}
	close(INF);

	if($cs==0){		# greyscale 
		$image=uncompress($image);
		$self->filters('FlateDecode');
		$self->colorspace('DeviceGray');	
		if($bpc>8) {
			$self->bpc(8);
			my $linebytes=1+2*$w;
			foreach my $y (0..$h-1){
				my $linemode=vec(substr($image,0,1),0,8);
				my $imageline=substr($image,($linebytes*$y)+1,$linebytes);
				foreach my $x (0..$w-1){
					my $g=vec($imageline,$x,$bpc)/8;
					$self->{' stream'}.=pack('C',$g);
				}
			}
			$self->mask(vec($transparency,0,16)/8,vec($transparency,0,16)/8) if($transparency);
		} else {
			$self->bpc($bpc);

			my $linebits=$bpc*$w;
			my $linebytes=$linebits%8 >0 ? 1+(($linebits+(8-$linebits%8))/8) : 1+($linebits/8) ;
			my $mask=(1<<$bpc)-1;
			foreach my $y (0..$h-1){
				my $linemode=vec(substr($image,0,1),0,8);
				my $imageline=substr($image,($linebytes*$y)+1,$linebytes-1);
				$self->{' stream'}.=$imageline;
			}
			$self->mask(vec($transparency,0,16),vec($transparency,0,16)) if($transparency);
		}
	} elsif($cs==2){	# rgb 8/16 bits
		my $linebytes=1+(3*$bpc*$w/8);
		$self->filters('ASCIIHexDecode');
		## $self->filters('FlateDecode');
		$self->colorspace('DeviceRGB');	
		$self->bpc(8);
		$image=uncompress($image);
		foreach my $y (0..$h-1){
			my $linemode=vec(substr($image,($linebytes*$y),1),0,8);
			my $imageline=substr($image,($linebytes*$y)+1,$linebytes-1);
			if($bpc>8) {
				$self->{' stream'}.='   ';
			} else {
				$self->{' stream'}.=$imageline;
			}
		}
	} elsif($cs==3){	# palette
	#	$self->filters('ASCIIHexDecode');
	#	$self->{' nofilt'}=1;
		$self->filters('FlateDecode');
		$self->colorspace('DeviceRGB');	
		$self->bpc(8);
		$image=uncompress($image);
		my $linebits=$bpc*$w;
		my $linebytes=$linebits%8 >0 ? 1+(($linebits+(8-$linebits%8))/8) : 1+($linebits/8) ;
		my $mask=(1<<$bpc)-1;
		my $smask='';
		foreach my $y (0..$h-1){
			my $linemode=vec(substr($image,0,1),0,8);
			my $imageline=substr($image,($linebytes*$y)+1,$linebytes);
			foreach my $x (0..$w-1){
				my $byte=floor($x*$bpc/8);
				my $by=(8/$bpc)-1-($x%(8/$bpc));
				my $c=vec(substr($imageline,$byte,1),0,8);
				$c=($c>>($by*$bpc))&$mask;
				$self->{' stream'}.=pack('C',vec($palete,  (3*$c),8));
				$self->{' stream'}.=pack('C',vec($palete,1+(3*$c),8));
				$self->{' stream'}.=pack('C',vec($palete,2+(3*$c),8));
				$smask.=(defined substr($transparency,$c,1) ? substr($transparency,$c,1) : pack('C',255)) if($transparency);
			}
		}
		if($transparency){
			my $mo=PDF::API2::PDF::Image->new($pdf);
			$mo->width($w);
			$mo->height($h);
			$mo->filters('ASCIIHexDecode');
			$mo->colorspace('DeviceGray');	
			$mo->bpc(8);
			$mo->{' stream'}=$smask;
			$self->smask($mo);
		}
	}

	$self->width($w);
	$self->height($h);

	return $self;
}

1;