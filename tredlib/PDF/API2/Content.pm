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
#	PDF::API2::Content
#
#=======================================================================
package PDF::API2::Content;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::PDF::Dict);

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use Math::Trig;
use PDF::API2::Util;

=head2 PDF::API2::Content

Subclassed from PDF::API2::PDF::Dict.

=item $co = PDF::API2::Content->new @parameters

Returns a new content object (called from $page->text/gfx).

=cut

sub new {
	my ($class)=@_;
	my $self = $class->SUPER::new(@_);
	$self->save;
	return($self);
}

=item $co->add @content

Adds @content to the object.

=cut

sub add {
	my $self=shift @_;
	if(scalar @_>0) {
  	$self->{' stream'}.=" ".join(' ',@_)."\n";
	}
	$self;
}

=item $co->save

Saves the state of the object.

=cut

sub save {
	my $self=shift @_;
	$self->add('q');
}

=item $co->restore

Restores the state of the object.

=cut

sub restore {
	my $self=shift @_;
	$self->add('Q');
}

=item $co->compress

Marks content for compression on output.

=cut

sub compress {
	my $self=shift @_;
	$self->{'Filter'}=PDFArray(PDFName('FlateDecode'));
	return($self);
}

sub outobjdeep {
	my ($self, @opts) = @_;
	$self->restore unless( $self->{' nofilt'});
#  $self->{Length}=PDFNum(length($self->{' stream'})) unless( $self->{' nofilt'});
	foreach my $k (qw/ api apipdf apipage /) {
		$self->{" $k"}=undef;
		delete($self->{" $k"});
	}
	$self->SUPER::outobjdeep(@opts);
}

=item $co->fillcolor $grey

=item $co->fillcolor $api2colorobject

=item $co->fillcolor $red, $green, $blue

=item $co->fillcolor $cyan, $magenta, $yellow, $black

=item $co->fillcolorbyname $colorname, $ascmyk

=item $co->fillcolorbyspace $colorspace, @colordef

Sets fillcolor.

=cut

sub checkcolor {
	my ($t,$c,$m,$y,$k)=@_;

	if (!defined($k)) {
		if (!defined($m)) {
			if($c=~/^[a-z\!\$\%\&\#]+/) {
				my @col=namecolor($c);
				return(checkcolor($t,@col));
			} else {
				return('g',$c) unless(ref $t);
        if($t->isIndexed) {
					return('sc',$c);
				} elsif($t->isCMYK) {
					return('sc',0,0,0,1-$c);
				} elsif($t->isGray) {
					return('sc',$c);
				} elsif($t->isRGB) {
					return('sc',$c,$c,$c);
				} else {
					die "undefined color=(".join(',',$c,$m,$y,$k).") in colorspace $t of type=($t->{' type'})";
				}
			}
		} else {
			return('rg',$c,$m,$y) unless(ref $t);
      if($t->isIndexed) {
				# return('sc',$t->resolveIndexFromRGB($c,$m,$y));
		  } elsif($t->isRGB) {
				return('sc',$c,$m,$y);
			} elsif($t->isCMYK) {
				return('sc',1-$c,1-$m,1-$y,0);
			} elsif($t->isGray) {
				return('sc',($c+$m+$y)/3);
			} else {
				return('sc',$c,$m,$y);
			}
		}
	} else {
		return('k',$c,$m,$y,$k) unless(ref $t);
    if($t->isIndexed) {
			# return('sc',$t->resolveIndexFromCMYK($c,$m,$y,$k));
		} elsif($t->isRGB) {
			return('sc',1-$c-$k,1-$m-$k,1-$y-$k);
		} elsif($t->isCMYK) {
			return('sc',$c,$m,$y,$k);
		} elsif($t->isGray) {
			return('sc',(3-$c-$k-$m-$k-$y-$k)/3);
		} else {
			return('sc',$c,$m,$y,$k);
		}
	}
}

sub fillcolor {
	my $self=shift @_;
	my ($obj,$c,$m,$y,$k,$type,@clrs);
	$obj=shift @_;
	if(ref($obj) eq 'PDF::API2::Color') {
		$self->add(floats($obj->asCMYK),'k');
	} elsif(ref($obj) eq 'PDF::API2::ColorSpace') {
		if($obj->isRGB || $obj->isCMYK||$obj->isGray) {
			($type,@clrs)=checkcolor($obj,@_);
			$self->add("/$obj->{' apiname'}",'cs',floats(@clrs),$type);
		} else {
			$self->add("/$obj->{' apiname'}",'cs',floats(@_),'sc');
		}
		$self->resource('ColorSpace',$obj->{' apiname'},$obj);
	} elsif(ref($obj) eq 'PDF::API2::Pattern') {
		$self->add("/Pattern",'cs',"/$obj->{' apiname'}",'scn');
		$self->resource('Pattern',$obj->{' apiname'},$obj);
	} else {
		($m,$y,$k)=@_;
		$c=$obj;
		($type,@clrs)=checkcolor(undef,$c,$m,$y,$k);
		$self->add(floats(@clrs),$type);
	}

	return($self);
}

sub fillcolorbyname {
	my ($self,$name,$ascmyk)=@_;
	my @col=namecolor($name);
	@col=RGBasCMYK(@col) if($ascmyk);
	$self->fillcolor(@col);
	return($self);
}

sub fillcolorbyspace {
	my ($self,$cs,@para)=@_;
	$self->fillcolor($cs,@para);
	return($self);
}

=item $co->strokecolor $grey

=item $co->strokecolor $api2colorobject

=item $co->strokecolor $red, $green, $blue

=item $co->strokecolor $cyan, $magenta, $yellow, $black

=item $co->strokecolorbyname $colorname, $ascmyk

=item $co->strokecolorbyspace $colorspace, @colordef

Sets strokecolor.

B<Defined color-names are:>

	aliceblue, antiquewhite, aqua, aquamarine, azure, beige, bisque, black, blanchedalmond, 
	blue, blueviolet, brown, burlywood, cadetblue, chartreuse, chocolate, coral, cornflowerblue, 
	cornsilk, crimson, cyan, darkblue, darkcyan, darkgoldenrod, darkgray, darkgreen, darkgrey, 
	darkkhaki, darkmagenta, darkolivegreen, darkorange, darkorchid, darkred, darksalmon, 
	darkseagreen, darkslateblue, darkslategray, darkslategrey, darkturquoise, darkviolet, 
	deeppink, deepskyblue, dimgray, dimgrey, dodgerblue, firebrick, floralwhite, forestgreen, 
	fuchsia, gainsboro, ghostwhite, gold, goldenrod, gray, grey, green, greenyellow, honeydew, 
	hotpink, indianred, indigo, ivory, khaki, lavender, lavenderblush, lawngreen, lemonchiffon,
	lightblue, lightcoral, lightcyan, lightgoldenrodyellow, lightgray, lightgreen, lightgrey, 
	lightpink, lightsalmon, lightseagreen, lightskyblue, lightslategray, lightslategrey, 
	lightsteelblue, lightyellow, lime, limegreen, linen, magenta, maroon, mediumaquamarine,
	mediumblue, mediumorchid, mediumpurple, mediumseagreen, mediumslateblue, mediumspringgreen, 
	mediumturquoise, mediumvioletred, midnightblue, mintcream, mistyrose, moccasin, navajowhite, 
	navy, oldlace, olive, olivedrab, orange, orangered, orchid, palegoldenrod, palegreen,
	paleturquoise, palevioletred, papayawhip, peachpuff, peru, pink, plum, powderblue, purple, 
	red, rosybrown, royalblue, saddlebrown, salmon, sandybrown, seagreen, seashell, sienna, 
	silver, skyblue, slateblue, slategray, slategrey, snow, springgreen, steelblue, tan, teal,
	thistle, tomato, turquoise, violet, wheat, white, whitesmoke, yellow, yellowgreen

or the rgb-hex-notation:

	#rgb, #rrggbb, #rrrgggbbb and #rrrrggggbbbb

or the cmyk-hex-notation:

	%cmyk, %ccmmyykk, %cccmmmyyykkk and %ccccmmmmyyyykkkk

or the hsl-hex-notation:

	&hsl, &hhssll, &hhhssslll and &hhhhssssllll

and additionally the hsv-hex-notation:

	!hsv, !hhssvv, !hhhsssvvv and !hhhhssssvvvv

=cut

sub strokecolor {
	my $self=shift @_;
	my ($obj,$c,$m,$y,$k,$type,@clrs);
	$obj=shift @_;
	if(ref($obj) eq 'PDF::API2::Color') {
		$self->add(floats($obj->asCMYK),'K');
	} elsif(ref($obj) eq 'PDF::API2::ColorSpace') {
		if($obj->isRGB || $obj->isCMYK||$obj->isGray) {
			($type,@clrs)=checkcolor($obj,@_);
			$self->add("/$obj->{' apiname'}",'CS',floats(@clrs),uc $type);
		} else {
			$self->add("/$obj->{' apiname'}",'CS',floats(@_),'SC');
		}
		$self->resource('ColorSpace',$obj->{' apiname'},$obj);
	} elsif(ref($obj) eq 'PDF::API2::Pattern') {
		$self->add("/Pattern",'CS',"/$obj->{' apiname'}",'SCN');
		$self->resource('Pattern',$obj->{' apiname'},$obj);
	} else {
		($m,$y,$k)=@_;
		$c=$obj;
		($type,@clrs)=checkcolor(undef,$c,$m,$y,$k);
		$self->add(floats(@clrs),uc $type);
	}

	return($self);
}

sub strokecolorbyname {
	my ($self,$name,$ascmyk)=@_;
	my @col=namecolor($name);
	@col=RGBasCMYK(@col) if($ascmyk);
	$self->strokecolor(@col);
	return($self);
}

sub strokecolorbyspace {
	my ($self,$cs,@para)=@_;
	$self->strokecolor($cs,@para);
	return($self);
}

=item $co->flatness $flat

Sets flatness.

=cut

sub flatness {
	my ($self,$flatness)=@_;
	$self->add($flatness,'i');
}

=item $co->linecap $cap

Sets linecap.

=cut

sub linecap {
	my ($this,$linecap)=@_;
	$this->add($linecap,'J');
}

=item $co->linedash @dash

Sets linedash.

=cut

sub linedash {
	my ($self,@a)=@_;
	if(scalar @a < 1) {
			$self->add('[ ] 0 d');
	} else {
  	if($a[0]=~/^\-/){
  		my %a=@a;
  		$a{-pattern}=[$a{-full}||0,$a{-clear}||0] unless($a{-pattern});
  		$self->add('[',floats(@{$a{-pattern}}),']',intg($a{-shift}||0),'d');
  	} else {
			$self->add('[',floats(@a),'] 0 d');
		}
	}
}

=item $co->linejoin $join

Sets linejoin.

=cut

sub linejoin {
	my ($this,$linejoin)=@_;
	$this->add($linejoin,'j');
}

=item $co->linewidth $width

Sets linewidth.

=cut

sub linewidth {
	my ($this,$linewidth)=@_;
	$this->add($linewidth,'w');
}

=item $co->meterlimit $limit

Sets meterlimit.

=cut

sub meterlimit {
	my ($this, $limit)=@_;
	$this->add($limit,'M');
}

=item $co->matrix $a,$b,$c,$d,$e,$f

Sets matrix transformation.

=cut

sub matrix {
	my $self=shift @_;
	my ($a,$b,$c,$d,$e,$f)=@_;
	$self->add(floats($a,$b,$c,$d,$e,$f),'cm');
}

=item $co->translate $x,$y

Sets translation transformation.

=cut

sub translate {
	my ($self,$x,$y)=@_;
	$self->matrix(1,0,0,1,$x,$y);
}

=item $co->scale $sx,$sy

Sets scaleing transformation.

=cut

sub scale {
	my ($self,$x,$y)=@_;
	$self->matrix($x,0,0,$y,0,0);
}

=item $co->skew $sa,$sb

Sets skew transformation.

=cut

sub skew {
	my ($self,$a,$b)=@_;
	$self->matrix(1, tan(deg2rad($a)),tan(deg2rad($b)),1,0,0);
}

=item $co->rotate $rot

Sets rotation transformation.

=cut

sub rotate {
	my ($self,$a)=@_;
	$self->matrix(cos(deg2rad($a)), sin(deg2rad($a)),-sin(deg2rad($a)), cos(deg2rad($a)),0,0);
}

=item $co->transform %opts

Sets transformations (eg. translate, rotate, scale, skew) in pdf-canonical order.

B<Example:>

	$co->transform(
		-translate => [$x,$y],
		-rotate    => $rot,
		-scale     => [$sx,$sy],
		-skew      => [$sa,$sb],
	)

=cut

sub transform {
	use PDF::API2::Matrix;
	my ($self,%opt)=@_;
	my $mtx=PDF::API2::Matrix->new([1,0,0],[0,1,0],[0,0,1]);
	foreach my $o (qw( -skew -scale -rotate -translate )) {
		next unless(defined($opt{$o}));
		if($o eq '-translate') {
			my ($tx,$ty)=@{$opt{$o}};
			$mtx=$mtx->multiply(PDF::API2::Matrix->new([1,0,0],[0,1,0],[$tx,$ty,1]));
		} elsif($o eq '-rotate') {
			my $rot=$opt{$o};
			$mtx=$mtx->multiply(PDF::API2::Matrix->new(
				[ cos(deg2rad($rot)),sin(deg2rad($rot)),0],
				[-sin(deg2rad($rot)),cos(deg2rad($rot)),0],
				[0,0,1]
			));
		} elsif($o eq '-scale') {
			my ($sx,$sy)=@{$opt{$o}};
			$mtx=$mtx->multiply(PDF::API2::Matrix->new([$sx,0,0],[0,$sy,0],[0,0,1]));
		} elsif($o eq '-skew') {
			my ($sa,$sb)=@{$opt{$o}};
			$mtx=$mtx->multiply(PDF::API2::Matrix->new(
				[1,tan(deg2rad($sa)),0],
				[tan(deg2rad($sb)),1,0],
				[0,0,1]
			));
		}
	}
	$self->matrix(
		$mtx->[0][0],$mtx->[0][1],
		$mtx->[1][0],$mtx->[1][1],
		$mtx->[2][0],$mtx->[2][1]
	);
	return($self);
}

=item $co->resource $type, $key, $obj

Adds a resource to the page-inheritance tree.

B<Example:>

	$co->resource('Font',$fontkey,$fontobj);
	$co->resource('XObject',$imagekey,$imageobj);
	$co->resource('Shading',$shadekey,$shadeobj);
	$co->resource('ColorSpace',$spacekey,$speceobj);

B<Note:> You only have to add the required resources, if
they are NOT handled by the *font*, *image*, *shade* or *space*
methods.

=cut

sub resource {
	my ($self, $type, $key, $obj, $force) = @_;
	if($self->{' apipage'}) { 
	  # we are a content stream on a page.
  	return( $self->{' apipage'}->resource($type, $key, $obj, $force) );
	} else {
	  # we are a self-contained content stream.
  	$self->{Resources}||=PDFDict();
  
  	my $dict=$self->{Resources};
  	$dict->realise if(ref($dict)=~/Objind$/);
  
  	$dict->{$type}||= PDFDict();
  	$dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);
    unless (defined $obj) {
      return($dict->{$type}->{$key} || undef);
    } else {
    	if($force) {
    		$dict->{$type}->{$key}=$obj;
    	} else {
    		$dict->{$type}->{$key}||= $obj;
    	}
      return($dict);
    }
	}
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
