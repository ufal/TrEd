#==================================================================
#	PDF::API2::PDF::Image
#==================================================================
package PDF::API2::PDF::Image;

use strict;
use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use vars qw(@ISA $VERSION );

@ISA = qw(PDF::API2::PDF::Dict);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

=head2 PDF::API2::PDF::Image

=item $img = PDF::API2::PDF::Image->new $pdf, $name

Returns a new image object.

=cut

sub new {
	my ($class,$pdf,$name)=@_;
	my $self = $class->SUPER::new();

	$self->{Type}=PDFName('XObject');
	$self->{Subtype}=PDFName('Image');
	$self->{Name}=PDFName($name) if(defined $name);
	
	$pdf->new_obj($self);
	
	return($self);
}

=item $wd = $img->width

=cut

sub width {
	my $self = shift @_;
	my $x=shift @_;
	$self->{Width}=PDFNum($x) if(defined $x);
	return($self->{Width}->val);
}

=item $ht = $img->height

=cut

sub height {
	my $self = shift @_;
	my $x=shift @_;
	$self->{Height}=PDFNum($x) if(defined $x);
	return($self->{Height}->val);
}

=item $img->smask $smaskobj

=cut

sub smask {
	my $self = shift @_;
	my $maskobj = shift @_;
	$self->{SMask}=$maskobj;
	return $self;
}

=item $img->mask @maskcolorange

=cut

sub mask {
	my $self = shift @_;
	$self->{Mask}=PDFArray(map { PDFNum($_) } @_);
	return $self;
}

=item $img->imask $maskobj

=cut

sub imask {
	my $self = shift @_;
	$self->{Mask}=shift @_;
	return $self;
}

=item $img->colorspace $csobj

=cut

sub colorspace {
	my $self = shift @_;
	my $obj = shift @_;
	$self->{'ColorSpace'}=ref $obj ? $obj : PDFName($obj) ;
	return $self;
}

=item $img->filters @filternames

=cut

sub filters {
	my $self = shift @_;
	$self->{Filter}=PDFArray(map { PDFName($_) } @_);
	return $self;
}

=item $img->bpc $num

=cut

sub bpc {
	my $self = shift @_;
	$self->{BitsPerComponent}=PDFNum(shift @_);
	return $self;
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