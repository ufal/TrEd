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
#	PDF::API2::ExtGState
#
#=======================================================================
package PDF::API2::ExtGState;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::PDF::Dict);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use Math::Trig;
use PDF::API2::Util;

=head2 PDF::API2::ExtGState

Subclassed from PDF::API2::PDF::Dict.

=item $egs = PDF::API2::ExtGState->new @parameters

Returns a new extgstate object (called from $pdf->extgstate).

=cut

sub new {
	my ($class,$pdf,$key)=@_;
	my $self = $class->SUPER::new;
	$self->{' apiname'}=$key;
	$self->{Type}=PDFName('ExtGState');
	return($self);
}

=item $egs->strokeadjust $boolean

=cut

sub strokeadjust {
	my ($self,$var)=@_;
	$self->{SA}=PDFBool($var);
	return($self);
}

=item $egs->strokeoverprint $boolean

=cut

sub strokeoverprint {
	my ($self,$var)=@_;
	$self->{OP}=PDFBool($var);
	return($self);
}

=item $egs->filloverprint $boolean

=cut

sub filloverprint {
	my ($self,$var)=@_;
	$self->{op}=PDFBool($var);
	return($self);
}

=item $egs->overprintmode $num

=cut

sub overprintmode {
	my ($self,$var)=@_;
	$self->{OPM}=PDFNum($var);
	return($self);
}

=item $egs->blackgeneration $obj

=cut

sub blackgeneration {
	my ($self,$obj)=@_;
	$self->{BG}=$obj;
	return($self);
}

=item $egs->blackgeneration2 $obj

=cut

sub blackgeneration2 {
	my ($self,$obj)=@_;
	$self->{BG2}=$obj;
	return($self);
}

=item $egs->undercolorremoval $obj

=cut

sub undercolorremoval {
	my ($self,$obj)=@_;
	$self->{UCR}=$obj;
	return($self);
}

=item $egs->undercolorremoval2 $obj

=cut

sub undercolorremoval2 {
	my ($self,$obj)=@_;
	$self->{UCR2}=$obj;
	return($self);
}

=item $egs->transfer $obj

=cut

sub transfer {
	my ($self,$obj)=@_;
	$self->{TR}=$obj;
	return($self);
}

=item $egs->transfer2 $obj

=cut

sub transfer2 {
	my ($self,$obj)=@_;
	$self->{TR2}=$obj;
	return($self);
}

=item $egs->halftone $obj

=cut

sub halftone {
	my ($self,$obj)=@_;
	$self->{HT}=$obj;
	return($self);
}

=item $egs->halftonephase $obj

=cut

sub halftonephase {
	my ($self,$obj)=@_;
	$self->{HTP}=$obj;
	return($self);
}

=item $egs->smoothness $num

=cut

sub smoothness {
	my ($self,$var)=@_;
	$self->{SM}=PDFNum($var);
	return($self);
}

=item $egs->font $font, $size

=cut

sub font {
	my ($self,$font,$size)=@_;
	$self->{Font}=PDFArray(PDFName($font->{' apiname'}),PDFNum($size));
	return($self);
}

=item $egs->linewidth $size

=cut

sub linewidth {
	my ($self,$var)=@_;
	$self->{LW}=PDFNum($var);
	return($self);
}

=item $egs->linecap $cap

=cut

sub linecap {
	my ($self,$var)=@_;
	$self->{LC}=PDFNum($var);
	return($self);
}

=item $egs->linejoin $join

=cut

sub linejoin {
	my ($self,$var)=@_;
	$self->{LJ}=PDFNum($var);
	return($self);
}

=item $egs->meterlimit $limit

=cut

sub meterlimit {
	my ($self,$var)=@_;
	$self->{ML}=PDFNum($var);
	return($self);
}

=item $egs->dash @dash

=cut

sub dash {
	my ($self,@dash)=@_;
	$self->{ML}=PDFArray( map { PDFNum($_); } @dash );
	return($self);
}

=item $egs->flatness $flat

=cut

sub flatness {
	my ($self,$var)=@_;
	$self->{FL}=PDFNum($var);
	return($self);
}

=item $egs->renderingintent $intentName

=cut

sub renderingintent {
	my ($self,$var)=@_;
	$self->{FL}=PDFName($var);
	return($self);
}

=item $egs->strokealpha $alpha

The current stroking alpha constant, specifying the
constant shape or constant opacity value to be used
for stroking operations in the transparent imaging model.

=cut

sub strokealpha {
	my ($self,$var)=@_;
	$self->{CA}=PDFNum($var);
	return($self);
}

=item $egs->fillalpha $alpha

Same as strokealpha, but for nonstroking operations.

=cut

sub fillalpha {
	my ($self,$var)=@_;
	$self->{ca}=PDFNum($var);
	return($self);
}

=item $egs->blendmode $blendname

=item $egs->blendmode $blendfunctionobj

The current blend mode to be used in the transparent
imaging model.

=cut

sub blendmode {
	my ($self,$var)=@_;
	if(ref($var)) {
		$self->{BM}=$var;
	} else {
		$self->{BM}=PDFName($var);
	}
	return($self);
}

=item $egs->alphaisshape $boolean

The alpha source flag (alpha is shape), specifying
whether the current soft mask and alpha constant
are to be interpreted as shape values (true) or
opacity values (false).

=cut

sub alphaisshape {
	my ($self,$var)=@_;
	$self->{AIS}=PDFBool($var);
	return($self);
}

=item $egs->textknockout $boolean

The text knockout flag, which determines the behavior
of overlapping glyphs within a text object in the
transparent imaging model.

=cut

sub textknockout {
	my ($self,$var)=@_;
	$self->{TK}=PDFBool($var);
	return($self);
}

=item $egs->transparency $t

The graphics tranparency , with 0 being fully opaque and 1 being fully transparent.
This is a convenience method setting proper values for strokeaplha and fillalpha.

=cut

sub transparency {
	my ($self,$var)=@_;
	$self->strokealpha(1-$var);
	$self->fillalpha(1-$var);
	return($self);
}

=item $egs->opacity $op

The graphics opacity , with 1 being fully opaque and 0 being fully transparent.
This is a convenience method setting proper values for strokeaplha and fillalpha.

=cut

sub opacity {
	my ($self,$var)=@_;
	$self->strokealpha($var);
	$self->fillalpha($var);
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
