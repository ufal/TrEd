#!/usr/bin/env perl
# tests for TrEd::Convert

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';

BEGIN {
  my $module_name = 'TrEd::Convert';
  our @subs = qw(
    encode 
    decode 
    filename 
    dirname
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);

# testing
  
my $str = "¾lu»ouèký kùò úpìl ïábelské ódy";

## Branches for decode
$TrEd::Convert::lefttoright = 0;
my $internal_string = TrEd::Convert::decode($str);


$TrEd::Convert::lefttoright = undef;
$internal_string = TrEd::Convert::decode($str);

## Testing branches for encode
#$TrEd::Convert::lefttoright = 0;
#
#$TrEd::Convert::lefttoright = undef;
#
#$TrEd::Convert::FORCE_NO_REMIX = 0;
#
#$TrEd::Convert::FORCE_NO_REMIX = 1;
#
#$TrEd::Convert::FORCE_REMIX = 0;
#
#$TrEd::Convert::FORCE_REMIX = 1;


my $iso_8859_2_str = TrEd::Convert::encode($internal_string);  

is($str, $iso_8859_2_str, 
  "decode and encode back correctly");
  
  


my $path = "/etc/X11/xorg.conf";

my $dir = TrEd::Convert::dirname($path);
is($dir, "/etc/X11/", 
  "dirname(): extract directory from path");

my $file = TrEd::Convert::filename($path);
is($file, "xorg.conf", 
  "filename(): extract filename from path");


#print "$path => $dir, $file\n";