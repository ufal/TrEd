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
#	PDF::API2::Chart::Pie
#
#=======================================================================
package PDF::API2::Chart::Pie;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Chart);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use PDF::API2::Chart;

=head1 PDF::API2::Chart::Pie;

Subclassed from PDF::API2::Chart.

=head1 SYNOPSIS

  $pie=$page->piechart(
    -x => 300, -y => 100, 
    -h => 350, -w => 400, 
    -labelfont => $font, -labelsize =>10
  );

  $pie->set_data(50,25,13,6,6);
  $pie->set_label('50%','25%','13%','6%','6%');
  $pie->set_description('data1','data2','data3','data4','data5');
  $pie->finish;

=head1 DESCRIPTION

=over 4

=item $piechart = PDF::API2::Chart::Pie->new @parameters

Returns a new pie-chart object.

=cut

sub new {
	my $class=shift @_;
	my $self = $class->SUPER::new(@_);
	$self->param('pie',1);
	$self->param('data',[]);
	$self->param('label',[]);
	$self->param('description',[]);
  my %opt=@_;
  foreach my $k (qw/ -labelfont -labelsize -startangle /) {
    next unless(exists $opt{$k});  
    $self->param($k,$opt{$k});
  }
	
	return($self);
}

=item $pie->add_data @data

Adds data to the pie-chart.

=cut

sub add_data {
	my $self=shift @_;
  push(@{$self->param('data')},@_);
  return($self);
}

=item $pie->set_data @data

Sets the data of the pie-chart.

=cut

sub set_data {
	my $self=shift @_;
  @{$self->param('data')}=@_;
  return($self);
}

=item $pie->add_label @lables

Adds labels of the data to the pie-chart.

=cut

sub add_label {
	my $self=shift @_;
  push(@{$self->param('label')},@_);
  return($self);
}

=item $pie->set_label @lables

Sets the labels of the data of the pie-chart.

=cut

sub set_label {
	my $self=shift @_;
  @{$self->param('label')}=@_;
  return($self);
}

=item $pie->add_description @text

Adds descriptions of the data to the pie-chart.

=cut

sub add_description {
	my $self=shift @_;
  push(@{$self->param('description')},@_);
  return($self);
}

=item $pie->set_description @lables

Sets the descriptions of the data of the pie-chart.

=cut

sub set_description {
	my $self=shift @_;
  @{$self->param('description')}=@_;
  return($self);
}

=item $pie->finish

Finishes the pie-chart for output.

=cut

sub finish {
	my $self=shift @_;
	my $cx=$self->param('-x')+($self->param('-w')/2);
	my $cy=$self->param('-y')+($self->param('-h')/2);
	my $ca=$self->param('-w')/3;
	my $cb=$self->param('-h')/3;
	my $sum=0;
	foreach (@{$self->param('data')}) { $sum+=$_; }
	my $a=($self->param('-startangle')||0)*$sum/360;
	my $b=$a;
	foreach my $i (0..(scalar @{$self->param('data')}-1)) {
	  $self->strokecolor('#000000');  
	  $self->linewidth(0.001);  
	  $self->linedash;  
	  $self->fillcolor(@{$self->param('-colors')}[$i]);  
	  $b+=@{$self->param('data')}[$i];
	  $self->pie($cx,$cy,$ca,$cb,$a*360/$sum,$b*360/$sum);  
	  $self->fillstroke;
	  $a=$b;
	}
  return($self);
}

1;

__END__


=back

=head1 NOTICE

WORK IN PROGRESS

=head1 AUTHOR

alfred reibenschuh (alfredreibenschuh@gmx.net)

=cut
