#!/usr/bin/env perl
# tests for TrEd::Convert

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;

use Encode ();
# TrEd::Convert uses information about Tk version to determine 
# whether it should support unicode or not, so it needs to be 
# used... but is it really a good solution?
#TODO: think about it
use Tk ();

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

TrEd::Convert->import(qw{&encode &decode &filename &dirname $inputenc $outputenc});

our @subs;
can_ok(__PACKAGE__, @subs);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


# testing
  
# this needs more testing with arabic strings etc, 
# unfortunately, I do not understand these languages at all... yet

sub test_decode_support_unicode {
  my $sup_unicode_backup = $TrEd::Convert::support_unicode;
  $TrEd::Convert::support_unicode = 1;
  
  my $str = "¾lu»ouèký kùò úpìl ïábelské ódy ì¹èø¾";
  my $str_reversed_nonascii = "¾lu»ouèký kòù úpìl áïbelské ódy ¾øè¹ì";
  
  ## Branches for decode
  ## left to right is false -> reversing non-ascii characters
  $TrEd::Convert::lefttoright = 0;
  my $internal_string = TrEd::Convert::decode($str);

  is($internal_string, $str_reversed_nonascii, 
    "decode(): decode string with right-to-left direction, support_unicode on");
  
  ## left to right is true
  $TrEd::Convert::lefttoright = 1;
  $internal_string = TrEd::Convert::decode($str);
  is($internal_string, $str, 
    "decode(): decode string with left-to-right direction, support_unicode on");
    
  $TrEd::Convert::support_unicode = $sup_unicode_backup;  
}

sub test_decode_dont_support_unicode {
  my $sup_unicode_backup = $TrEd::Convert::support_unicode;
  $TrEd::Convert::support_unicode = 0;
  
  my $str = "¾lu»ouèký kùò úpìl ïábelské ódy ì¹èø¾";
  my $str_reversed_nonascii = "¾lu»ouèký kòù úpìl áïbelské ódy ¾øè¹ì";
  
  ## Branches for decode
  ## left to right is false -> reversing non-ascii characters
  $TrEd::Convert::lefttoright = 0;
  my $internal_string = TrEd::Convert::decode($str);
  
  my $outputenc = "iso-8859-2";
  my $expected_str = Encode::decode($outputenc, $str_reversed_nonascii);
  is($internal_string, $expected_str, 
    "decode(): decode string with right-to-left direction, support_unicode off");
  
  ## left to right is true -> do not reverse, just decode
  $TrEd::Convert::lefttoright = 1;
  $internal_string = TrEd::Convert::decode($str);
  $expected_str = Encode::decode($outputenc, $str);
  is($internal_string, $expected_str, 
    "decode(): decode string with left-to-right direction, support_unicode off");  
  
  $TrEd::Convert::support_unicode = $sup_unicode_backup;
}

sub test_encode_support_unicode {
  my $sup_unicode_backup = $TrEd::Convert::support_unicode;
  $TrEd::Convert::support_unicode = 1;
  
  my $str = "¾lu»ouèký kùò úpìl ïábelské ódy ì¹èø¾";
  my $str_reversed_nonascii = "¾lu»ouèký kòù úpìl áïbelské ódy ¾øè¹ì";
  
  ## Branches for encode
  ## left to right is false -> reversing non-ascii characters
  $TrEd::Convert::lefttoright = 0;
  my $outputenc = "iso-8859-2";
  my $internal_string = Encode::decode($outputenc, $str);
  my $iso_8859_2_str = TrEd::Convert::encode($internal_string);
  
  is($iso_8859_2_str, Encode::decode($outputenc, $str_reversed_nonascii), 
    "encode(): encode string to iso-8859-2 correctly with right-to-left direction, support_unicode on");

  ## left to right is true -> no reversing
  $TrEd::Convert::lefttoright = 1;
  $iso_8859_2_str = TrEd::Convert::encode($internal_string);
  
  is($iso_8859_2_str, Encode::decode($outputenc, $str), 
    "encode(): encode string to iso-8859-2 correctly with left-to-right direction, support_unicode on");
  
  ## FORCE_REMIX --> use arabjoin & remix, this is a basic test only
  my $arabic_str = "\x{0623}\x{0647}\x{0644}\x{0627}\x{064B}";
  # my $arabic_str_reversed = "\x{064B}\x{0627}\x{0644}\x{0647}\x{0623}";
  # my $hm = "\x{064B}\x{FEFC}\x{FEEB}\x{FE83}";
  # this is an example from arabjoin, I do not personally know, if it is really correct
  my $expected = "\x{FE83}\x{FEEB}\x{FEFC}\x{064B}";
  $TrEd::Convert::outputenc = "utf8";
  $TrEd::Convert::lefttoright = 0;
    
  $TrEd::Convert::FORCE_NO_REMIX = 0;
  $TrEd::Convert::FORCE_REMIX = 1;
  $internal_string = TrEd::Convert::encode($arabic_str);
  
  is($internal_string, $expected, 
    "encode(): encode string with arabic string and right-to-left direction, FORCE_NO_REMIX = 0 & FORCE_REMIX = 1, support_unicode on");
  
  ## FORCE_NO_REMIX --> just reverse
  $TrEd::Convert::FORCE_NO_REMIX = 1;
  
  $internal_string = TrEd::Convert::encode($arabic_str);
  
  is($internal_string, reverse($arabic_str), 
    "decode(): decode string with arabic right-to-left direction, FORCE_NO_REMIX = 1, support_unicode on");
  
  $TrEd::Convert::support_unicode = $sup_unicode_backup;
}

sub test_encode_dont_support_unicode {
  my $sup_unicode_backup = $TrEd::Convert::support_unicode;
  $TrEd::Convert::support_unicode = 0;
  
  my $str = "¾lu»ouèký kùò úpìl ïábelské ódy ì¹èø¾";
  my $str_reversed_nonascii = "¾lu»ouèký kòù úpìl áïbelské ódy ¾øè¹ì";
  
  ## Branches for encode
  ## left to right is false -> reversing non-ascii characters
  $TrEd::Convert::lefttoright = 0;
  my $outputenc = "iso-8859-2";
  my $internal_string = Encode::decode($outputenc, $str);
  my $iso_8859_2_str = TrEd::Convert::encode($internal_string);
  
  is($str_reversed_nonascii, $iso_8859_2_str, 
    "encode(): encode string to iso-8859-2 correctly with right-to-left direction, support_unicode off");

  ## left to right is true -> no reversing
  $TrEd::Convert::lefttoright = 1;
  $iso_8859_2_str = TrEd::Convert::encode($internal_string);
  
  is($str, $iso_8859_2_str, 
    "encode(): encode string to iso-8859-2 correctly with left-to-right direction, support_unicode off");
    
  ## arabic string without unicode support are reversed & encoded by Encode::encode
  my $arabic_str = "\x{0623}\x{0647}\x{0644}\x{0627}\x{064B}";
  my $expected_str = reverse(Encode::encode('utf8', $arabic_str));
  
  $TrEd::Convert::outputenc = "utf8";
  $TrEd::Convert::lefttoright = 0;
  $internal_string = TrEd::Convert::encode($arabic_str);
  
  is($internal_string, $expected_str, 
    "encode(): encode string with arabic string and right-to-left direction, support_unicode off");
  
  $TrEd::Convert::support_unicode = $sup_unicode_backup;
}


my $path = "/etc/X11/xorg.conf";

my $dir = TrEd::Convert::dirname($path);
is($dir, "/etc/X11/", 
  "dirname(): extract directory from path");

my $file = TrEd::Convert::filename($path);
is($file, "xorg.conf", 
  "filename(): extract filename from path");

  
$path = 'hatlatitla';
$dir = TrEd::Convert::dirname($path);
is($dir, "./", 
  "dirname(): return current directory if there is no slash in path");

$file = TrEd::Convert::filename($path);
is($file, $path, 
  "filename(): return whole string if there is no slash in path");



#print "$path => $dir, $file\n";

test_decode_dont_support_unicode();
test_decode_support_unicode();

test_encode_dont_support_unicode();
test_encode_support_unicode();

done_testing();