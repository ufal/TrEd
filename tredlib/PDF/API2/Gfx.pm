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
#	PDF::API2::Gfx
#
#=======================================================================
package PDF::API2::Gfx;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Content);
use PDF::API2::Content;
use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use Math::Trig;
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


=head2 PDF::API2::Gfx

Subclassed from PDF::API2::Content.

=item $gfx = PDF::API2::Gfx->new @parameters

Returns a new graphics content object (called from $page->gfx).

=item $gfx->matrix $a, $b, $c, $d, $e, $f

Sets the matrix.

=cut

sub matrix {
	my $self=shift @_;
	my ($a,$b,$c,$d,$e,$f)=@_;
	$self->add(floats($a,$b,$c,$d,$e,$f),'cm');
	return($self);
}

=item $gfx->move $x, $y

=cut

sub move { # x,y ...
	my $self=shift @_;
	my($x,$y);
	while(defined($x=shift @_)) {
		$y=shift @_;
		$self->{' x'}=$x;
		$self->{' y'}=$y;
		$self->{' mx'}=$x;
		$self->{' my'}=$y;
		$self->add(floats($x,$y),'m');
	}
	return($self);
}

=item $gfx->line $x, $y

=cut

sub line { # x,y ...
	my $self=shift @_;
	my($x,$y);
	while(defined($x=shift @_)) {
		$y=shift @_;
		$self->{' x'}=$x;
		$self->{' y'}=$y;
		$self->add(floats($x,$y),'l');
	}
	return($self);
}

=item $gfx->hline $x

=cut

sub hline {
	my($self,$x)=@_;
	$self->add(floats($x,$self->{' y'}),'l');
	$self->{' x'}=$x;
	return($self);
}

=item $gfx->vline $y

=cut

sub vline {
	my($self,$y)=@_;
	$self->add(floats($self->{' x'},$y),'l');
	$self->{' y'}=$y;
	return($self);
}

=item $gfx->curve $x1, $y1, $x2, $y2, $x3, $y3

=cut

sub curve { # x1,y1,x2,y2,x3,y3 ...
	my $self=shift @_;
	my($x1,$y1,$x2,$y2,$x3,$y3);
	while(defined($x1=shift @_)) {
		$y1=shift @_;
		$x2=shift @_;
		$y2=shift @_;
		$x3=shift @_;
		$y3=shift @_;
		$self->add(floats($x1,$y1,$x2,$y2,$x3,$y3),'c');
		$self->{' x'}=$x3;
		$self->{' y'}=$y3;
	}
	return($self);
}

sub arctocurve {
        my ($a,$b,$alpha,$beta)=@_;
        if(abs($beta-$alpha) > 180) {
        	return (
        		arctocurve($a,$b,$alpha,($beta+$alpha)/2),
        		arctocurve($a,$b,($beta+$alpha)/2,$beta)
        	);
        } else {
                $alpha = ($alpha * 3.1415 / 180);
                $beta  = ($beta * 3.1415 / 180);

                my $bcp = (4.0/3 * (1 - cos(($beta - $alpha)/2)) / sin(($beta - $alpha)/2));
                my $sin_alpha = sin($alpha);
                my $sin_beta =  sin($beta);
                my $cos_alpha = cos($alpha);
                my $cos_beta =  cos($beta);

                my $p0_x = $a * $cos_alpha;
                my $p0_y = $b * $sin_alpha;
                my $p1_x = $a * ($cos_alpha - $bcp * $sin_alpha);
                my $p1_y = $b * ($sin_alpha + $bcp * $cos_alpha);
                my $p2_x = $a * ($cos_beta + $bcp * $sin_beta);
                my $p2_y = $b * ($sin_beta - $bcp * $cos_beta);
                my $p3_x = $a * $cos_beta;
                my $p3_y = $b * $sin_beta;
                return($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
	}
}

=item $gfx->arc $x, $y, $a, $b, $alfa, $beta, $move

=cut

sub arc { # x,y,a,b,alf,bet[,mov]
        my ($self,$x,$y,$a,$b,$alpha,$beta,$move)=@_;
        my @points=arctocurve($a,$b,$alpha,$beta);
        my ($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);

        $p0_x= $x + shift @points;
        $p0_y= $y + shift @points;

        $self->move($p0_x,$p0_y) if($move);

	while(scalar @points > 0) {
	        $p1_x= $x + shift @points;
	        $p1_y= $y + shift @points;
	        $p2_x= $x + shift @points;
	        $p2_y= $y + shift @points;
	        $p3_x= $x + shift @points;
	        $p3_y= $y + shift @points;
	        $self->curve($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
	        shift @points;
	        shift @points;
		$self->{' x'}=$p3_x;
		$self->{' y'}=$p3_y;
	}
	return($self);
}

=item $gfx->ellipse $x, $y, $a, $b

=cut

sub ellipse {
	my ($self,$x,$y,$a,$b) = @_;
	$self->arc($x,$y,$a,$b,0,360,1);
	$self->close;
	return($self);
}

=item $gfx->circle $x, $y, $r

=cut

sub circle {
	my ($self,$x,$y,$r) = @_;
	$self->arc($x,$y,$r,$r,0,360,1);
	$self->close;
	return($self);
}

=item $gfx->bogen $x1, $y1, $x2, $y2, $r, $move, $larc, $span

=cut

sub bogen { # x1,y1,x2,y2,r[,move[,large-arc[,span-factor]]]
	my ($self,$x1,$y1,$x2,$y2,$r,$move,$larc,$spf) = @_;
        my ($p0_x,$p0_y,$p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
	my $x=$x2-$x1;
	$x=$x1-$x2 if($spf>0);
	my $y=$y2-$y1;
	$y=$y1-$y2 if($spf>0);
	my $z=sqrt($x**2+$y**2);
	my $alfa_rad=asin($y/$z);

	if($spf>0) {
		$alfa_rad-=pi/2 if($x<0);
		$alfa_rad=-$alfa_rad if($y>0);
	} else {
		$alfa_rad+=pi/2 if($x<0);
		$alfa_rad=-$alfa_rad if($y<0);
	}

	my $alfa=rad2deg($alfa_rad);
	my $d=2*$r;
	my ($beta,$beta_rad,@points);

	$beta=rad2deg(2*asin($z/$d));
	$beta=360-$beta if($larc>0);

	$beta_rad=deg2rad($beta);

	@points=arctocurve($r,$r,90+$alfa+$beta/2,90+$alfa-$beta/2);

	if($spf>0) {
		my @pts=@points;
		@points=();
		while($y=pop @pts){
			$x=pop @pts;
			push(@points,$x,$y);
		}
	}

	$p0_x=shift @points;
	$p0_y=shift @points;
	$x=$x1-$p0_x;
	$y=$y1-$p0_y;

        $self->move($x,$y) if($move);

	while(scalar @points > 0) {
	        $p1_x= $x + shift @points;
	        $p1_y= $y + shift @points;
	        $p2_x= $x + shift @points;
	        $p2_y= $y + shift @points;
	        $p3_x= $x + shift @points;
	        $p3_y= $y + shift @points;
	        $self->curve($p1_x,$p1_y,$p2_x,$p2_y,$p3_x,$p3_y);
	        shift @points;
	        shift @points;
	}
	return($self);
}

=item $gfx->pie $x, $y, $a, $b, $alfa, $beta

=cut

sub pie {
	my $self=shift @_;
	my ($x,$y,$a,$b,$alfa,$beta)=@_;
        my ($p0_x,$p0_y)=arctocurve($a,$b,$alfa,$beta);
	$self->move($x,$y);
	$self->line($p0_x+$x,$p0_y+$y);
	$self->arc($x,$y,$a,$b,$alfa,$beta);
	$self->close;
}

=item $gfx->pie3d $x, $y, $a, $b, $alfa, $beta, $thickness [, $sides]

=cut

sub pie3d {
	my $self=shift @_;
	my ($x,$y,$a,$b,$alfa,$beta,$th,$sd)=@_;

	my ($sa,$sb);

	while($alfa<0) {$alfa+=360;$beta+=360;}

	while($alfa>360) {$alfa-=360;$beta-=360;}

	$sa=$alfa;

	$sb=$beta;
	while($sb<0) {$sb+=360;}
	while($sb>360) {$sb-=360;}

	my ($p0x,$p0y)=arctocurve($a,$b,$alfa,$beta);
	my ($p1x,$p1y)=arctocurve($a,$b,$beta,$alfa);
	if($sd) {
		if (($sa<90) || ($sa>270)) {
			$self->move($x,$y);
			$self->line($x,$y-$th);
			$self->line($x+$p0x,$y+$p0y-$th);
			$self->line($x+$p0x,$y+$p0y);
			$self->close;
		}
		if (($sb>90) && ($sb<270)) {
			$self->move($x,$y);
			$self->line($x,$y-$th);
			$self->line($x+$p1x,$y+$p1y-$th);
			$self->line($x+$p1x,$y+$p1y);
			$self->close;
		}
	}

	my($r_s,$r_m,$r_e);

	my $mid=($beta+$alfa)/2;

	if( ($alfa<180) && ($beta>180) && ($beta<360) ) {
		$r_s=180;
		$r_e=$beta;
	} elsif(($alfa>180) && ($beta<360)) {
		$r_s=$alfa;
		$r_e=$beta;
	} elsif( ($alfa<360) && ($alfa>180) && ($beta>360) ) {
		$r_s=$alfa;
		$r_e=360;
	} elsif ( ($alfa<180) && ($beta>360) ) {
		$r_s=180;
		$r_e=360;
	}

	if($r_s||$r_e||$r_m) {
		($p0x,$p0y)=arctocurve($a,$b,$r_s,$r_e);
		($p1x,$p1y)=arctocurve($a,$b,$r_e,$r_s);
		$self->move($x+$p0x,$y+$p0y);
		$self->line($x+$p0x,$y+$p0y-$th);
		$self->arc($x,$y-$th,$a,$b,$r_s,$r_e);
		$self->line($x+$p1x,$y+$p1y);
		$self->close;
		if(($sb>180) && ($sb<360) && (($beta-$alfa)>180) && ($sa>$sb)) {
			($p0x,$p0y)=arctocurve($a,$b,180,$beta);
			($p1x,$p1y)=arctocurve($a,$b,$beta,180);
			$self->move($x+$p1x,$y+$p1y);
			$self->line($x+$p1x,$y+$p1y-$th);
			$self->arc($x,$y-$th,$a,$b,$sb,180);
			$self->line($x+$p0x,$y+$p0y);
			$self->close;
		#	print " sa=$sa sb=$sb a=$alfa b=$beta \n";
		}
	}

	$self->fillstroke;

	$self->pie($x,$y,$a,$b,$alfa,$beta);

	return($self);
}

=item $gfx->rect $x1,$y1, $w1,$h1, ..., $xn,$yn, $wn,$hn

=cut

sub rect { # x,y,w,h ...
	my $self=shift @_;
	my($x,$y,$w,$h);
	while(defined($x=shift @_)) {
		$y=shift @_;
		$w=shift @_;
		$h=shift @_;
		$self->add(floats($x,$y,$w,$h),'re');
	}
	$self->{' x'}=$x;
	$self->{' y'}=$y;
	return($self);
}

=item $gfx->rectxy $x1,$y1, $x2,$y2

=cut

sub rectxy {
	my ($self,$x,$y,$x2,$y2)=@_;
	$self->rect($x,$y,($x2-$x),($y2-$y));
	return($self);
}

=item $gfx->poly $x1,$y1, ..., $xn,$yn

=cut

sub poly {
	my $self=shift @_;
	my($x,$y);
	$x=shift @_;
	$y=shift @_;
	$self->move($x,$y);
	$self->line(@_);
	return($self);
}

=item $gfx->close

=cut

sub close {
	my $self=shift @_;
	$self->add('h');
	$self->{' x'}=$self->{' mx'};
	$self->{' y'}=$self->{' my'};
	return($self);
}

=item $gfx->endpath

=cut

sub endpath {
	my $self=shift @_;
	$self->add('n');
	return($self);
}

=item $gfx->clip $nonzero

=cut

sub clip { # nonzero
	my $self=shift @_;
	$self->add(!(shift @_)?'W':'W*');
	return($self);
}

=item $gfx->stroke

=cut

sub stroke {
	my $self=shift @_;
	$self->add('S');
	return($self);
}

=item $gfx->fill $nonzero

=cut

sub fill { # nonzero
	my $self=shift @_;
	$self->add(!(shift @_)?'f':'f*');
	return($self);
}

=item $gfx->fillstroke $nonzero

=cut

sub fillstroke { # nonzero
	my $self=shift @_;
	$self->add(!(shift @_)?'B':'B*');
	return($self);
}

=item $gfx->image $imgobj, $x,$y, $w,$h

=item $gfx->image $imgobj, $x,$y, $scale

=item $gfx->image $imgobj, $x,$y

B<Please Note:> The width/height or scale given
is in user-space coordinates which is subject to
transformations which may have been specified beforehand.

Per default this has a 72dpi resolution, so if you want an
image to have a 150 or 300dpi resolution, you should specify
a scale of 72/150 (or 72/300) or adjust width/height accordingly.

=cut

sub image {
	my $self=shift @_;
	my $img=shift @_;
	my ($x,$y,$w,$h)=@_;
	$self->save;
	if(!defined $w) {
		$h=$img->height;
		$w=$img->width;
	} elsif(!defined $h) {
		$h=$img->height*$w;
		$w=$img->width*$w;
	}
	$self->matrix($w,0,0,$h,$x,$y);
	$self->add("/$img->{' apiname'}",'Do');
	$self->restore;
	$self->{' x'}=$x;
	$self->{' y'}=$y;
	$self->resource('XObject',$img->{' apiname'},$img);
	return($self);
}

=item $gfx->pdfimage $imgobj, $x, $y, $sx, $sy

=item $gfx->pdfimage $imgobj, $x, $y, $scale

=item $gfx->pdfimage $imgobj, $x, $y

B<Please Note:> *TODO*


=cut

sub pdfimage {
	my $self=shift @_;
	my $img=shift @_;
	my $x=shift @_||0;
	my $y=shift @_||0;
	my ($w,$h)=@_;
	my $sx=shift @_||1;
	my $sy=shift @_||$sx;
	$self->save;
	$self->matrix($sx,0,0,$sy,$x,$y);
	$self->add($img->{' pdfimage'});
	$self->restore;
	foreach my $type (keys %{$img->{Resources}}) {
		next if($type=~/^ /);
		foreach my $res (keys %{$img->{Resources}->{$type}}) {
			next if($res=~/^ /);
			$self->resource($type,$res,$img->{Resources}->{$type}->{$res});
		}
	}
	return($self);
}

=item $gfx->barcode $barcodeobj, $center_x, $center_y, $scale [,$frame]

=item $gfx->barcode_inline $barcodeobj, $center_x, $center_y, $scale [,$frame]

=cut

sub barcode {
	my $self=shift @_;
	my $obj=shift @_;
	my ($cx,$cy,$s,$f)=@_;
	$self->save;
	$self->matrix($s,0,0,$s,$cx-($obj->{' w'}*$s/2),$cy-($obj->{' h'}*$s/2));
	if($f>0) {
		$self->fillcolorbyname('white');
		$self->strokecolorbyname('black');
		$self->linewidth($f);
		$self->rect(0,0,$obj->{' w'},$obj->{' h'});
		$self->fillstroke;
	}
	$self->add("/$obj->{' apiname'}",'Do');
	$self->restore;
	$self->resource('XObject',$obj->{' apiname'},$obj);
	$self->resource('Font',$obj->{' font'}->{' apiname'},$obj->{' font'});
	return($self);
}

sub barcode_inline {
	my $self=shift @_;
	my $obj=shift @_;
	my ($cx,$cy,$s,$f)=@_;
	$self->save;
	$self->matrix($s,0,0,$s,$cx-($obj->{' w'}*$s/2),$cy-($obj->{' h'}*$s/2));
	if($f>0) {
		$self->fillcolorbyname('white');
		$self->strokecolorbyname('black');
		$self->linewidth($f);
		$self->rect(0,0,$obj->{' w'},$obj->{' h'});
		$self->fillstroke;
	}
	$self->add($obj->{' stream'});
	$self->restore;
	$self->resource('Font',$obj->{' font'}->{' apiname'},$obj->{' font'});
	return($self);
}

=item $gfx->shade $shadeobj, $x1,$y1, $x2,$y2

=cut

sub shade {
	my $self=shift @_;
	my $shade=shift @_;
	my @cord=@_;
	my @tm=(
		$cord[2]-$cord[0] , 0,
		0                 , $cord[3]-$cord[1],
		$cord[0]          , $cord[1]
	);
	$self->save;
	$self->matrix(@tm);
	$self->add("/$shade->{' apiname'}",'sh');

	$self->resource('Shading',$shade->{' apiname'},$shade);

	$self->restore;
	return($self);
}

=item $gfx->egstate $egsobj

=cut

sub egstate {
	my $self=shift @_;
	my $egs=shift @_;
	$self->add("/$egs->{' apiname'}",'gs');
	$self->resource('ExtGState',$egs->{' apiname'},$egs);
	return($self);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
