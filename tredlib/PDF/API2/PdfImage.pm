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
#	PDF::API2::PdfImage
#
#=======================================================================
package PDF::API2::PdfImage;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Hybrid);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use PDF::API2::Hybrid;

=head2 PDF::API2::PdfImage

Subclassed from PDF::API2::Hybrid.

=cut

sub resource {
	my ($self, $type, $key, $obj) = @_;
	$self->{Resources}=$self->{Resources}||PDFDict();
	$self->{Resources}->{$type}=$self->{Resources}->{$type}||PDFDict();
	$self->{Resources}->{$type}->{$key}=$obj;
	return($self);
}

=item $wd = $img->width

=cut

sub width {
	my $self = shift @_;
	return($self->{' rx'}-$self->{' lx'});
}

=item $ht = $img->height

=cut

sub height {
	my $self = shift @_;
	return($self->{' ry'}-$self->{' ly'});
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
