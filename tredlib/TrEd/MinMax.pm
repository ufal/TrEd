package TrEd::MinMax;

#
# $Revision$ '
# Time-stamp: <2003-10-06 17:17:03 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
require Exporter;

@ISA=qw(Exporter);
$VERSION = "0.1";
@EXPORT = qw(min max);
@EXPORT_OK=qw(first min max minstr maxstr reduce sum shuffle);
eval 'require List::Util; die if List::Util::min(0,-1)!=-1; import List::Util qw(first min max minstr maxstr reduce sum shuffle)';

eval <<'ESQ' if $@ or not defined &reduce;

# This code is only compiled if List::Util did not load

use vars qw($a $b);

sub reduce (&@) {
  my $code = shift;

  return shift unless @_ > 1;

  my $caller = caller;
  local(*{$caller."::a"}) = \my $a;
  local(*{$caller."::b"}) = \my $b;

  $a = shift;
  foreach (@_) {
    $b = $_;
    $a = &{$code}();
  }

  $a;
}

sub sum (@) { reduce { $a + $b } @_ }

sub min (@) { reduce { $a < $b ? $a : $b } @_ }

sub max (@) { reduce { $a > $b ? $a : $b } @_ }

sub minstr (@) { reduce { $a lt $b ? $a : $b } @_ }

sub maxstr (@) { reduce { $a gt $b ? $a : $b } @_ }

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

ESQ

1;



