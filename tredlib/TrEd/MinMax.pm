package TrEd::MinMax;

#
# $Revision$ '
# Time-stamp: <2003-10-08 19:29:46 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
require Exporter;

@ISA=qw(Exporter);
$VERSION = "0.1";
@EXPORT = qw(min max min2 max2);
@EXPORT_OK=qw(min max minstr maxstr sum reduce first suffle);

# This code is similar to List::Util but uses @_ instead of $a and $b,
# as it's very hard or impossible to locate those two correctly under
# the Safe mode (because of the namespace mangling)

sub reduce (&@) {
  my $code = shift;

  return shift unless @_ > 1;
  my ($a,$b);
  $a = shift;
  foreach (@_) {
    $b = $_;
    $a = &{$code}($a,$b);
  }
  $a;
}

sub min2 ($$) { $_[0] < $_[1] ? $_[0] : $_[1] }
sub max2 ($$) { $_[0] > $_[1] ? $_[0] : $_[1] }

sub sum (@) { reduce { $_[0] + $_[1] } @_ }
sub min (@) { reduce \&min2, @_; }
sub max (@) { reduce \&max2, @_; }
sub minstr (@) { reduce { $_[0] lt $_[1] ? $_[0] : $_[1] } @_ }
sub maxstr (@) { reduce { $_[0] gt $_[1] ? $_[0] : $_[1] } @_ }

sub first (&@) {
  my $code = shift;

  foreach (@_) {
    return $_ if &{$code}();
  }

  undef;
}

sub shuffle (@) {
  my @a=\(@_);
  my $n;
  my $i=@_;
  map {
    $n = rand($i--);
    (${$a[$n]}, $a[$n] = $a[$i])[0];
  } @_;
}

1;
