#==================================================================
#	PDF::API2::PDF::ImageGD
#==================================================================
package PDF::API2::PDF::ImageGD;

use strict;
use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Image;
use vars qw(@ISA $VERSION );

@ISA = qw(PDF::API2::PDF::Image);

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:44 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

=head2 PDF::API2::PDF::ImageGD

=item $img = PDF::API2::PDF::ImageGD->new $pdf,$name, $gdobj

Returns a new image object from a gd object.

=cut

sub new {
        my ($class,$pdf,$name,$gd)=@_;
        my $self = $class->SUPER::new($pdf,$name);
        my ($w,$h)=$gd->getBounds();

        $self->width($w);
        $self->height($h);
        $self->bpc(8);
        $self->colorspace('DeviceRGB');

        if(UNIVERSAL::can($gd,'jpeg') && ($gd->colorsTotal > 256)) {
                $self->filters('DCTDecode');
                $self->{' nofilt'}=1;
                $self->{' stream'}=$gd->jpeg(75);
        } elsif(UNIVERSAL::can($gd,'raw')) {
                $self->filters('FlateDecode');
                $self->{' stream'}=$gd->raw;
        } else {
                $self->filters('FlateDecode');
                my($x,$y);
                for($y=0;$y<$h;$y++) {
                        for($x=0;$x<$w;$x++) {
                                my $index=$gd->getPixel($x,$y);
                                my @rgb=$gd->rgb($index);
                                $self->{' stream'}.=pack('CCC',@rgb);
                        }
                }
        }

        return($self);
}

1;