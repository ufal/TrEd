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
#	PDF::API2::Chart
#
#=======================================================================
package PDF::API2::Chart;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Hybrid);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use PDF::API2::Content;
use PDF::API2::Hybrid;
use PDF::API2::Text;
use PDF::API2::Gfx;

=head2 PDF::API2::Chart;

Subclassed from PDF::API2::Hybrid+Gfx+Text+Content.

=over 4

=item $hyb = PDF::API2::Chart->new 
-x => $xorigin,
-y => $yorigin,
-h => $height,
-w => $width,
-bgcolor => $color_of_background,
-border => $border_width,
-bordercolor => $color_of_border,
-texttop => $text_on_top,
-textbottom => $text_on_bottom,
-textleft => $text_to_the_left,
-textright => $text_to_the_right,
-textcolor => $color_of_text,
-textfont => $font_of_text,
-textsize => $size_of_text,
-colors => [ $color1, $color2, ... ]

Returns a new chart content object which acts as a super-class for PDF::API2::Chart::*.

=cut

sub new {
	my $class=shift @_;
	my $self = $class->SUPER::new(@_);
  my %opt=@_;
  $self->param('-colors',[ qw/
  !00FFFF  !40FFFF  !80FFFF  !C0FFFF
  !08FFFF  !48FFFF  !88FFFF  !C8FFFF
  !10FFFF  !50FFFF  !90FFFF  !D0FFFF
  !18FFFF  !58FFFF  !98FFFF  !D8FFFF
  !20FFFF  !60FFFF  !A0FFFF  !E0FFFF
  !28FFFF  !68FFFF  !A8FFFF  !E8FFFF
  !30FFFF  !70FFFF  !B0FFFF  !F0FFFF
  !38FFFF  !78FFFF  !B8FFFF  !F8FFFF
  / ]);
  foreach my $k (qw/ -x -y -h -w -bgcolor -border -bordercolor -texttop -textbottom -textleft -textright -textcolor -textfont -textsize -colors /) {
    next unless(exists $opt{$k});  
    $self->param($k,$opt{$k});
  }
	return($self);
}

=item $val = $chart->param $tag, $val

Sets/Gets chart parameter.

=cut

sub param {
	my $self = shift @_;
	my $tag = shift @_;
 	$self->{" chart"}||={};
	if(scalar @_>0) {
  	my $val = shift @_;
  	$self->{" chart"}->{$tag}=$val;
	}
  return($self->{" chart"}->{$tag});
}

=item $val = $chart->sub_param $tag, $subtag, $val

Sets/Gets chart sub-parameter.

=cut

sub sub_param {
	my $self = shift @_;
	my $tag1 = shift @_;
	my $tag2 = shift @_;
	$self->{" chart"}||={};
	$self->{" chart"}->{$tag1}||={};
	if(scalar @_>0) {
  	my $val = shift @_;
	  $self->{" chart"}->{$tag1}->{$tag2}=$val;
	}
  return($self->{" chart"}->{$tag1}->{$tag2});
}

=item $chart->add_color $color1, ..., $colorx

Adds colors to those available in the chart.

=cut

sub add_color {
	my $self=shift @_;
  push(@{$self->param('-colors')},@_);
  return($self);
}

=item $chart->set_color $color1, ..., $colorx

Sets the colors available in the chart.

=cut

sub set_color {
	my $self=shift @_;
  @{$self->param('-colors')}=@_;
  return($self);
}

sub outobjdeep {
	my $self = shift @_;
	$self->{" chart"}=undef;
	delete($self->{" chart"});
	$self->SUPER::outobjdeep(@_);
}

1;

__END__

=back

=head1 NOTICE

work in progress

=head1 AUTHOR

alfred reibenschuh (alfredreibenschuh@gmx.net)

=cut
