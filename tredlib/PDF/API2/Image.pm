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
#	PDF::API2::Image
#
#=======================================================================
package PDF::API2::Image;
use strict;
use PDF::API2::Util;
use PDF::API2::PDF::Utils;
use vars qw( $VERSION );
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Image;
use PDF::API2::PDF::ImageGD;
use PDF::API2::PDF::ImageJPEG;
use PDF::API2::PDF::ImagePPM;
use Compress::Zlib;

=head2 PDF::API2::Image

=item $img = PDF::API2::Image->new $pdf, $imgfile

Returns a new image object (called from $pdf->image).

=cut

sub new {
	my ($class,$pdf,$file,$tt,%opts)=@_;
	my ($obj,$buf);
	if(ref $file) {
		if(UNIVERSAL::isa($file,'GD::Image')) {
			$obj=PDF::API2::PDF::ImageGD->new($pdf,'IMGxGDx'.pdfkey($file),$file);
			$obj->{' apiname'}='IMGxGDx'.pdfkey($file);
	#	} elsif(UNIVERSAL::isa($file,'Image::Base')) {
	#		$obj=PDF::API2::PDF::ImageIMAGE->new($pdf,'IMGxIMAGEx'.pdfkey($file),$file);
	#		$obj->{' apiname'}='IMGxIMAGEx'.pdfkey($file);
		} elsif( (ref($file) eq 'PDF::API2::IOString') && $opts{-jpeg} ) {
			$obj=PDF::API2::PDF::ImageJPEG->new_fh($pdf,'IMGxJPEGx'.pdfkey($tt),$file);
			$obj->{' apiname'}='IMGxJPEGx'.pdfkey($tt);
		} elsif((ref($file) eq 'SCALAR') && $opts{-jpeg}) {
			$obj=PDF::API2::PDF::ImageJPEG->new_stream($pdf,'IMGxJPEGx'.pdfkey($tt),$file);
			$obj->{' apiname'}='IMGxJPEGx'.pdfkey($tt);
		} else {
			die "Unknown Object '$file'";
		}
	} else {
		open(INF,$file);
		binmode(INF);
		read(INF,$buf,10,0);
		close(INF);
		if ($buf=~/^\xFF\xD8/) {
			$obj=PDF::API2::PDF::ImageJPEG->new($pdf,'IMGxJPEGx'.pdfkey($file),$file);
			$obj->{' apiname'}='IMGxJPEGx'.pdfkey($file);
		} elsif ($buf=~/^\x89PNG/) {
			eval ' use PDF::API2::PDF::ImagePNG; ';
			die "unable to load PDF::API2::PDF::ImagePNG (did you install correctly?) " if($@);
			$obj=PDF::API2::PDF::ImagePNG->new($pdf,'IMGxPNGx'.pdfkey($file),$file);
			$obj->{' apiname'}='IMGxPNGx'.pdfkey($file);
		} elsif ($buf=~/^P[456][\s\n]/) {
			$obj=PDF::API2::PDF::ImagePPM->new($pdf,'IMGxPPMx'.pdfkey($file),$file);
			$obj->{' apiname'}='IMGxPPMx'.pdfkey($file);
		} else {
			die sprintf("image '$file' has unknown format with signature '%02x%02x%02x%02x%02x%02x'",
				ord(substr($buf,0,1)),
				ord(substr($buf,1,1)),
				ord(substr($buf,2,1)),
				ord(substr($buf,3,1)),
				ord(substr($buf,4,1)),
				ord(substr($buf,5,1))
			);
		}
	}
	return($obj);
}

sub newMask {
	my ($class,$pdf,$img,$file,$tt)=@_;
	my ($obj,$buf);
	open(INF,$file);
	binmode(INF);
	read(INF,$buf,10,0);
	close(INF);
	if ($buf=~/^\xFF\xD8/) {
		$obj=PDF::API2::JPEG->newMask($img,$file,$tt);
	} elsif ($buf=~/^\x89PNG/) {
		$obj=PDF::API2::PNG->newMask($img,$file,$tt);
	} elsif ($buf=~/^P[456][\s\n]/) {
		$obj=PDF::API2::PPM->newMask($img,$file,$tt);
	} else {
		die sprintf("image '$file' has unknown format with signature '%02x%02x%02x%02x%02x%02x'",
			ord(substr($buf,0,1)),
			ord(substr($buf,1,1)),
			ord(substr($buf,2,1)),
			ord(substr($buf,3,1)),
			ord(substr($buf,4,1)),
			ord(substr($buf,5,1))
		);
	}
	$pdf->new_obj($obj);
	$obj->{' apipdf'}.=$pdf;
	return($obj);
}

sub new_jpeg {
	my ($class,$pdf,$name,$file)=@_;
	my $self = PDF::API2::PDF::Image->new($pdf,$name);
	my $fh = IO::File->new;
	open($fh,$file);
	binmode($fh);
	PDF::API2::Image::read_jpeg($self,$pdf,$fh);
	$fh->close;
	$self->{' streamfile'}=$file;
	$self->{Length}=PDFNum(-s $file);
	return($self);
}

sub new_jpeg_stream {
	my ($class,$pdf,$name,$file)=@_;
	my $self = PDF::API2::PDF::Image->new($pdf,$name);
	my $fh = PDF::API2::IOString->new($file);
	PDF::API2::Image::read_jpeg($self,$pdf,$fh);
	$self->{' stream'}=$fh->{buf};
	$self->{Length}=PDFNum(length $self->{' stream'});
	return($self);
}

sub new_jpeg_fh {
	my ($class,$pdf,$name,$fh)=@_;
	my $self = PDF::API2::PDF::Image->new($pdf,$name);
	PDF::API2::Image::read_jpeg($self,$pdf,$fh);
	if(ref($fh) eq 'PDF::API2::IOString') {
		$self->{' stream'}=$fh->{buf};
		$self->{Length}=PDFNum(length $self->{' stream'});
	} else {
#		$self->{' stream'}=$fh->{buf};
#		$self->{Length}=PDFNum(length $self->{' stream'});
	}
	return($self);
}

sub read_jpeg {
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
		if (($mark >= 0xC0) && ($mark <= 0xCF)) {
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

sub new_png {
	my ($class,$pdf,$name,$file)=@_;
	my $self = PDF::API2::PDF::Image->new($pdf,$name);
	my $fh = IO::File->new;
	open($fh,$file);
	binmode($fh);

	my ($buf,$l,$crc,$w,$h,$bpc,$cs,$cm,$fm,$im,$palete,$transparency);
	open($fh,$file);
	binmode($fh);
	seek($fh,8,0);
	$self->{' stream'}='';
	$self->{' nofilt'}=1;
	while(!eof($fh)) {
		read($fh,$buf,4);
		$l=unpack('N',$buf);
		read($fh,$buf,4);
		if($buf eq 'IHDR') {
			read($fh,$buf,$l);
			($w,$h,$bpc,$cs,$cm,$fm,$im)=unpack('NNCCCCC',$buf);
			warn "Unsupported Compression($cm)/Interlace($im) Method" if($im||$cm);
		} elsif($buf eq 'PLTE') {
			read($fh,$buf,$l);
			$palete=$buf;
		} elsif($buf eq 'IDAT') {
			read($fh,$buf,$l);
			$self->{' stream'}.=$buf;
		} elsif($buf eq 'tRNS') {
			read($fh,$buf,$l);
			$transparency=$buf;
		} elsif($buf eq 'IEND') {
			last;
		} else {
			# skip ahead
			seek($fh,$l,1);
		}
		read($fh,$buf,4);
		$crc=$buf;
	}
	close($fh);

  $self->width($w);
  $self->height($h);

	if($cs==0){		# greyscale 
    if($bpc>8) {
      die "16-bits of greylevel in png not supported.";
    } else {
  		$self->filters('FlateDecode');
  		$self->colorspace('DeviceGray');	
  	  $self->bpc($bpc);	
      my $dict=PDFDict();
      $self->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum(15);
      $dict->{BitsPerComponent}=PDFNum($bpc);
      $dict->{Colors}=PDFNum(1);
      $dict->{Columns}=PDFNum($w);
    }
  } elsif($cs==2){	# rgb 8/16 bits
	  if($bpc>8) {
      die "16-bits of rgb in png not supported.";
    } else {
  		$self->filters('FlateDecode');
  		$self->colorspace('DeviceRGB');	
  		$self->bpc($bpc);
      my $dict=PDFDict();
      $self->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum(15);
      $dict->{BitsPerComponent}=PDFNum($bpc);
      $dict->{Colors}=PDFNum(3);
      $dict->{Columns}=PDFNum($w);
    }
  } elsif($cs==3){	# palette
	  if($bpc>8) {
      die "bits>8 of palette in png not supported.";
    } else {
      my $dict=PDFDict();
      $pdf->new_obj($dict);
      $dict->{Filter}=PDFArray(PDFName('FlateDecode'));
      $dict->{' stream'}=$palete;
      $palete="";
  		$self->filters('FlateDecode');
  		$self->colorspace(PDFArray(PDFName('Indexed'),PDFName('DeviceRGB'),PDFNum(int(length($dict->{' stream'})/3)-1),$dict));
  		$self->bpc($bpc);
      $dict=PDFDict();
      $self->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum(15);
      $dict->{BitsPerComponent}=PDFNum($bpc);
      $dict->{Colors}=PDFNum(1);
      $dict->{Columns}=PDFNum($w);
    }
	} elsif($cs==4){		# greyscale+alpha 
    die "greylevel+alpha in png not supported.";
    if($bpc>8) {
      die "16-bits of greylevel+alpha in png not supported.";
    } else {
  		$self->filters('FlateDecode');
  		$self->colorspace('DeviceGray');	
  	  $self->bpc($bpc);	
      my $dict=PDFDict();
      $self->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum(15);
      $dict->{BitsPerComponent}=PDFNum($bpc);
      $dict->{Colors}=PDFNum(2);
      $dict->{Columns}=PDFNum($w);
    }
  } elsif($cs==6){	# rgb+alpha
    die "rgb+alpha in png not supported.";
	  if($bpc>8) {
      die "16-bits of rgb+alpha in png not supported.";
    } else {
  		$self->filters('FlateDecode');
  		$self->colorspace('DeviceRGB');	
  		$self->bpc($bpc);
      my $dict=PDFDict();
      $self->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum(15);
      $dict->{BitsPerComponent}=PDFNum($bpc);
      $dict->{Colors}=PDFNum(4);
      $dict->{Columns}=PDFNum($w);
    }
	} else {
	  die "unsupported png-type ($cs).";  
	}

	$fh->close;
	return($self);
}

sub new_gif {
	my ($class,$pdf,$name,$file)=@_;
	my $obj = PDF::API2::PDF::Image->new($pdf,$name);
	my $fh = IO::File->new;
	open($fh,$file);
	binmode($fh);
  my $buf;
  $fh->read($buf,6); # signature
  die "unknown image signature '$buf' -- not a gif." unless($buf=~/^GIF[0-9][0-9][a-b]/);
  $fh->read($buf,7); # logical descr.
  my($wg,$hg,$flags)=unpack('vvC',$buf);
  die "non-global color-table not supported in gif." unless($flags&0x80);
  my $colSize=2**(($flags&0x7)+1);
  my $dict=PDFDict();
  $pdf->new_obj($dict);
  $obj->colorspace(PDFArray(PDFName('Indexed'),PDFName('DeviceRGB'),PDFNum($colSize-1),$dict));
  $fh->read($dict->{' stream'},3*$colSize); # color-table
  while(!$fh->eof) {
    $fh->read($buf,1); # tag.
    my $sep=unpack('C',$buf);
    if($sep==0x2C){
      $fh->read($buf,9); # image-descr.
      my ($left,$top,$w,$h,$flags)=unpack('vvvvC',$buf);
      die "local color-table not supported in gif." unless($flags&0x80);
      die "interlace not supported in gif." unless($flags&0x40);
      $obj->width($w||$wg);
      $obj->height($h||$hg);
      $obj->bpc(8);
      if($flags&0x80) { #read local colortable;
        $colSize=2**(($flags&0x7)+1);
        $obj->colorspace(PDFArray(PDFName('Indexed'),PDFName('DeviceRGB'),PDFNum($colSize-1),$dict));
        $fh->read($dict->{' stream'},3*$colSize); # color-table
      }
      $fh->read($buf,1); # image-lzw-start (should be 9).
      my ($sep)=unpack('C',$buf);
      die "unsupported initial lzw-codesize in gif." if($sep>9);
      $fh->read($buf,1); # first chunk.
      my ($len)=unpack('C',$buf);
      $obj->filters('LZWDecode');
      $obj->{' nofilt'}=1;
      $obj->{' stream'}='';
      while($len>0) {
        $fh->read($buf,$len);
        $obj->{' stream'}.=$buf;
        $fh->read($buf,1);
        $len=unpack('C',$buf);
      }
      last;
    } elsif($sep==0x3b) {
      last;
    } else {
      # extension
      $fh->read($buf,1); # tag.
      my $tag=unpack('C',$buf);
      $fh->read($buf,1); # tag.
      my $len=unpack('C',$buf);
      while($len>0) {
        $fh->read($buf,$len);
        $fh->read($buf,1);
        $len=unpack('C',$buf);
      }
    }
  }
  $fh->close;
	return($obj);
}

sub new_pnm {
	my ($class,$pdf,$name,$file)=@_;
	my $self = PDF::API2::PDF::Image->new($pdf,$name);
	PDF::API2::Image::read_pnm($self,$pdf,$file);
	return($self);
}

sub read_pnm {
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

sub new_tiff {
	my ($class,$pdf,$name,$file)=@_;
	my $obj = PDF::API2::PDF::Image->new($pdf,$name);
	my $tif=TiffFile->new($file);

  $obj->width($tif->{imageWidth});
  $obj->height($tif->{imageHeight});
  if($tif->{colorSpace} eq 'Indexed') {
    my $dict=PDFDict();
    $pdf->new_obj($dict);
    $obj->colorspace(PDFArray(PDFName($tif->{colorSpace}),PDFName('DeviceRGB'),PDFNum(255),$dict));
    $dict->{Filter}=PDFArray(PDFName('FlateDecode'));
    $tif->{fh}->seek($tif->{colorMapOffset},0);
    my $colormap;
    my $straight;
    $tif->{fh}->read($colormap,$tif->{colorMapLength});
    $dict->{' stream'}='';
    map { $straight.=pack('C',($_/256)) } unpack($tif->{short}.'*',$colormap);
    foreach my $c (0..(($tif->{colorMapSamples}/3)-1)) {
      $dict->{' stream'}.=substr($straight,$c,1);
      $dict->{' stream'}.=substr($straight,$c+($tif->{colorMapSamples}/3),1);
      $dict->{' stream'}.=substr($straight,$c+($tif->{colorMapSamples}/3)*2,1);
    }
  } else {
    $obj->colorspace($tif->{colorSpace});
  }
  $obj->{Interpolate}=PDFBool(1);

  if($tif->{whiteIsZero}==1 && $tif->{filter} ne 'CCITTFaxDecode') {
    $obj->{Decode}=PDFArray(PDFNum(1),PDFNum(0));
  }
  $obj->bpc($tif->{bitsPerSample});
  if($tif->{filter}) {
    $obj->filters($tif->{filter});
   $obj->{' nofilt'}=1;
   if($tif->{filter} eq 'CCITTFaxDecode') {
      $obj->{Filter}=PDFName('CCITTFaxDecode');
      $obj->{DecodeParms}=PDFDict();
      $obj->{DecodeParms}->{K}=(($tif->{ccitt}==4 || ($tif->{g3Options}&0x1)) ? PDFNum(-1) : PDFNum(0));
      $obj->{DecodeParms}->{Columns}=PDFNum($tif->{imageWidth});
      $obj->{DecodeParms}->{Rows}=PDFNum($tif->{imageHeight});
      $obj->{DecodeParms}->{Blackls1}=PDFBool($tif->{whiteIsZero}==1?1:0);
      if(defined($tif->{g3Options}) && ($tif->{g3Options}&0x4)) {
        $obj->{DecodeParms}->{EndOfLine}=PDFBool(1); 
        $obj->{DecodeParms}->{EncodedByteAlign}=PDFBool(1);
      }
      # $obj->{DecodeParms}=PDFArray($obj->{DecodeParms});
      $obj->{DecodeParms}->{DamagedRowsBeforeError}=PDFNum(100);
    } elsif($tif->{filter} eq 'LZWDecode') {
      my $dict=PDFDict();
      $obj->{DecodeParms}=PDFArray($dict);
      $dict->{Predictor}=PDFNum($tif->{lzwPredictor}||0);
      $dict->{BitsPerComponent}=PDFNum($tif->{bitsPerSample});
      $dict->{Colors}=PDFNum($tif->{samplesPerPixel});
      $dict->{Columns}=PDFNum($tif->{imageWidth});
    }
  } else {
    $obj->filters('FlateDecode');
  }
  
  if(ref($tif->{imageOffset})) {
    $obj->{' stream'}='';
    my $d=scalar @{$tif->{imageOffset}};
    foreach (1..$d) {
      my $buf;
      $tif->{fh}->seek(shift @{$tif->{imageOffset}},0);
      $tif->{fh}->read($buf,shift @{$tif->{imageLength}});
      $buf=uncompress($buf) if($tif->{filter} eq 'FlateDecode');
      $obj->{' stream'}.=$buf;
    }
    delete $obj->{' nofilt'} if($tif->{filter} eq 'FlateDecode');
	if($tif->{ccitt}==4) {
      $obj->{DecodeParms}->{EndOfLine}=PDFBool(1); 
      $obj->{DecodeParms}->{EncodedByteAlign}=PDFBool(1);
	}
  } else {
    $tif->{fh}->seek($tif->{imageOffset},0);
    $tif->{fh}->read($obj->{' stream'},$tif->{imageLength});
  }
  
  if($tif->{fillOrder}==2) {
    my @bl=();
    foreach my $n (0..255) {
      my $b=$n;
      my $f=0;
      foreach (0..7) {
        my $bit=0;
        if($b &0x1) {
          $bit=1;
        }
        $b>>=1;
        $f<<=1;
        $f|=$bit;
      }
      $bl[$n]=$f;
    }
    my $l=length($obj->{' stream'})-1;
    foreach my $n (0..$l) {
      vec($obj->{' stream'},$n,8)=$bl[vec($obj->{' stream'},$n,8)];  
    }
  }

  $tif->close;
	return($obj);
}

package TiffFile;

use IO::File;

sub new {
  my $class=shift @_;
  my $file=shift @_;
  my $self={};
  bless($self,$class);
  $self->{fh} = IO::File->new;
  open($self->{fh},"< $file");
  binmode($self->{fh});
  my $fh = $self->{fh};

  $self->{offset}=0;
  $fh->seek( $self->{offset}, 0 );

  # checking byte order of data
  $fh->read( $self->{byteOrder}, 2 );
  $self->{byte}='C';
  $self->{short}=(($self->{byteOrder} eq 'MM') ? 'n' : 'v' );
  $self->{long}=(($self->{byteOrder} eq 'MM') ? 'N' : 'V' );
  $self->{rational}='NN';

  # get/check version id
  $fh->read( $self->{version}, 2 );
  $self->{version}=unpack($self->{short},$self->{version});
  die "Wrong TIFF Id '$self->{version}' (should be 42)." if($self->{version} != 42);

  # get the offset to the first tag directory.
  $fh->read( $self->{ifdOffset}, 4 );
  $self->{ifdOffset}=unpack($self->{long},$self->{ifdOffset});

  $self->readTags;

  return($self);
}

sub readTag {
  my $self = shift @_;
  my $fh = $self->{fh};
  my $buf;
  $fh->read( $buf, 12 );
  my $tag = unpack($self->{short}, substr($buf, 0, 2 ) );
  my $type = unpack($self->{short}, substr($buf, 2, 2 ) );
  my $count = unpack($self->{long}, substr($buf, 4, 4 ) );
  my $len=0;

  if($type==1) {
    # byte
    $len=$count;
  } elsif($type==2) {
    # charZ
    $len=$count;
  } elsif($type==3) {
    # int16
    $len=$count*2;
  } elsif($type==4) {
    # int32
    $len=$count*4;
  } elsif($type==5) {
    # rational: 2 * int32
    $len=$count*8;
  } else {
    $len=$count;
  }

  my $off = substr($buf, 8, 4 );

  if($len>4) {
    $off=unpack($self->{long},$off);
  } else {
    if($type==1) {
      $off=unpack($self->{byte},$off);
    } elsif($type==2) {
      $off=unpack($self->{long},$off);
    } elsif($type==3) {
      $off=unpack($self->{short},$off);
    } elsif($type==4) {
      $off=unpack($self->{long},$off);
    } else {
      $off=unpack($self->{short},$off);
    }
  }

  return ($tag,$type,$count,$len,$off);
}

sub close {
  my $self = shift @_;
  my $fh = $self->{fh};
  $fh->close;
  %{$self}=();    
}

sub readTags {
  my $self = shift @_;
  my $fh = $self->{fh};

  $self->{ifd}=$self->{ifdOffset};

  while($self->{ifd} > 0) {
    $fh->seek( $self->{ifd}, 0 );
    $fh->read( $self->{ifdNum}, 2 );
    $self->{ifdNum}=unpack($self->{short},$self->{ifdNum});
    $self->{bitsPerSample}=1;
    foreach (1..$self->{ifdNum}) {
      my ($valTag,$valType,$valCount,$valLen,$valOffset)=$self->readTag;
  #    print "tag=$valTag type=$valType count=$valCount len=$valLen off=$valOffset\n";
      if($valTag==0) {
      } elsif($valTag==256) {
        # imagewidth
        $self->{imageWidth}=$valOffset;
      } elsif($valTag==257) {
        # imageheight
        $self->{imageHeight}=$valOffset;
      } elsif($valTag==258) {
        # bits per sample
        if($valCount>1) {
          my $here=$fh->tell;
          my $val;
          $fh->seek($valOffset,0);
          $fh->read($val,2);
          $self->{bitsPerSample}=unpack($self->{short},$val);
          $fh->seek($here,0);
        } else {
          $self->{bitsPerSample}=$valOffset;
        }
      } elsif($valTag==259) {
        # compression
        $self->{filter}=$valOffset;
        if($valOffset==1) {
          delete $self->{filter};
        } elsif($valOffset==3 || $valOffset==4) {
          $self->{filter}='CCITTFaxDecode';
          $self->{ccitt}=$valOffset;
        } elsif($valOffset==5) {
          $self->{filter}='LZWDecode';
        } elsif($valOffset==6 || $valOffset==7) {
          $self->{filter}='DCTDecode';
        } elsif($valOffset==8 || $valOffset==0x80b2) {
          $self->{filter}='FlateDecode';
        } elsif($valOffset==32773) {
          $self->{filter}='RunLengthDecode';
        } else {
          die "unknown/unsupported TIFF compression method with id '$self->{filter}'.";
        }
      } elsif($valTag==262) {
        # photometric interpretation
        $self->{colorSpace}=$valOffset;
        if($valOffset==0) {
          $self->{colorSpace}='DeviceGray';
          $self->{whiteIsZero}=1;
        } elsif($valOffset==1) {
          $self->{colorSpace}='DeviceGray';
          $self->{blackIsZero}=1;
        } elsif($valOffset==2) {
          $self->{colorSpace}='DeviceRGB';
        } elsif($valOffset==3) {
          $self->{colorSpace}='Indexed';
      #  } elsif($valOffset==4) {
      #    $self->{colorSpace}='TransMask';
        } elsif($valOffset==5) {
          $self->{colorSpace}='DeviceCMYK';
        } elsif($valOffset==6) {
          $self->{colorSpace}='DeviceRGB';
        } elsif($valOffset==8) {
          $self->{colorSpace}='Lab';
        } else {
          die "unknown/unsupported TIFF photometric interpretation with id '$self->{colorSpace}'.";
        }
      } elsif($valTag==266) {
        $self->{fillOrder}=$valOffset;
      } elsif($valTag==273) {
        # image data offset/strip offsets
        if($valCount==1) {
          $self->{imageOffset}=$valOffset;
        } else {
          my $here=$fh->tell;
          my $val;
          $fh->seek($valOffset,0);
          $fh->read($val,$valLen);
          $fh->seek($here,0);
          $self->{imageOffset}=[ unpack($self->{long}.'*',$val) ];
        }
      } elsif($valTag==277) {
        # samples per pixel
        $self->{samplesPerPixel}=$valOffset;
      } elsif($valTag==279) {
        # image data length/strip lengths
        if($valCount==1) {
          $self->{imageLength}=$valOffset;
        } else {
          my $here=$fh->tell;
          my $val;
          $fh->seek($valOffset,0);
          $fh->read($val,$valLen);
          $fh->seek($here,0);
          $self->{imageLength}=[ unpack($self->{long}.'*',$val) ];
        }
      } elsif($valTag==292) {
        $self->{g3Options}=$valOffset;
      } elsif($valTag==293) {
        $self->{g4Options}=$valOffset;
      } elsif($valTag==320) {
        # color map
        $self->{colorMapOffset}=$valOffset;
        $self->{colorMapSamples}=$valCount;
        $self->{colorMapLength}=$valCount*2; # shorts!
      } elsif($valTag==317) {
        # lzwPredictor
        $self->{lzwPredictor}=$valOffset;
#      } elsif($valTag==) {
#      } elsif($valTag==) {
#      } elsif($valTag==) {
#      } elsif($valTag==) {
#      } elsif($valTag==) {
      }
    }
    $fh->read( $self->{ifd}, 4 );
    $self->{ifd}=unpack($self->{long},$self->{ifd});
  }
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut