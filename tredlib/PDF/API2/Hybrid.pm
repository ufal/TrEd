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
#	PDF::API2::Hybrid
#
#=======================================================================
package PDF::API2::Hybrid;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Gfx PDF::API2::Text PDF::API2::Content);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use PDF::API2::Content;
use PDF::API2::Text;
use PDF::API2::Gfx;

=head2 PDF::API2::Hybrid

Subclassed from PDF::API2::Gfx+Text+Content.

=item $hyb = PDF::API2::Hybrid->new @parameters

Returns a new hybrid content object (called from $page->hybrid).

=cut

sub new {
	my ($class)=@_;
	my $self = PDF::API2::Content::new(@_);
	$self->{' font'}=undef;
	$self->{' fontsize'}=0;
	$self->{' charspace'}=0;
	$self->{' hspace'}=100;
	$self->{' wordspace'}=0;
	$self->{' lead'}=0;
	$self->{' rise'}=0;
	$self->{' render'}=0;
	$self->{' matrix'}=[1,0,0,1,0,0];
	$self->{' fillcolor'}=[0];
	$self->{' strokecolor'}=[0];
	$self->{' translate'}=[0,0];
	$self->{' scale'}=[1,1];
	$self->{' skew'}=[0,0];
	$self->{' rotate'}=0;
	$self->{' apiistext'}=0;
	return($self);
}

=item $hyb->matrix $a, $b, $c, $d, $e, $f

Sets the matrix.

=cut

sub matrix {
	my ($self,$a,$b,$c,$d,$e,$f)= @_;
	if(defined($self->{' apiistext'}) && $self->{' apiistext'} == 1) {
		return PDF::API2::Text::matrix(@_);
	} else {
		$self->add(floats($a,$b,$c,$d,$e,$f),'cm');
	}
	return($self);
}


sub outobjdeep {
	my ($self) = @_;
	foreach my $k (qw/ api apipdf apipage font fontsize charspace hspace wordspace lead rise render matrix fillcolor strokecolor translate scale skew rotate /) {
		$self->{" $k"}=undef;
		delete($self->{" $k"});
	}
	PDF::API2::Content::outobjdeep(@_);
}

sub transform {
	my ($self)=@_;
	if($self->{' apiistext'} != 1) {
		PDF::API2::Content::transform(@_);
	} else {
		PDF::API2::Text::transform(@_);
	}
	return($self);
}

=item $hyb->textstart

=cut

sub textstart {
	my ($self)=@_;
	if(!defined($self->{' apiistext'}) || $self->{' apiistext'} != 1) {
		$self->add(' BT ');
		$self->{' apiistext'}=1;
		$self->{' font'}=undef;
		$self->{' fontsize'}=0;
		$self->{' charspace'}=0;
		$self->{' hspace'}=100;
		$self->{' wordspace'}=0;
		$self->{' lead'}=0;
		$self->{' rise'}=0;
		$self->{' render'}=0;
		@{$self->{' matrix'}}=(1,0,0,1,0,0);
		@{$self->{' fillcolor'}}=(0);
		@{$self->{' strokecolor'}}=(0);
		@{$self->{' translate'}}=(0,0);
		@{$self->{' scale'}}=(1,1);
		@{$self->{' skew'}}=(0,0);
		$self->{' rotate'}=0;
	}
	return($self);
}

=item $hyb->textend

=cut

sub textend {
	my ($self)=@_;
	if($self->{' apiistext'} == 1) {
		$self->add(' ET ');
		$self->{' apiistext'}=0;
	}
	return($self);
}


1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
