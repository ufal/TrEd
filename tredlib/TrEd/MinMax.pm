package TrEd::MinMax;

#
# $Revision$ '
# Time-stamp: <2001-06-01 15:54:19 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use strict;

BEGIN {
  use Exporter  ();
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK);
  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(&min &max);
  @EXPORT_OK=();
}

sub min {
  my ($a,$b)=@_;
  return ($a<$b)?$a:$b;
}

sub max {
  my ($a,$b)=@_;
  return ($a<$b)?$b:$a;
}

1;

