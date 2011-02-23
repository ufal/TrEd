#!/usr/bin/env perl
# tests for TrEd::Convert

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';#tests => 19;
#use IO qw(File Handle);
#use Encode;
#use Data::Dumper;
#use File::Spec;
#use Cwd;
#use File::Copy; # need move

BEGIN {
  my $module_name = 'TrEd::Convert';
  our @subs = qw(
    &encode 
    &decode 
    &filename 
    &dirname
    $inputenc 
    $outputenc 
    $Ds 
    %encodings
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);

# write tests