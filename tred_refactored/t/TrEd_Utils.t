#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';#tests => 19;
use IO qw(File Handle);
use utf8;
use Encode;

my @subs = qw(
  fetch_from_win32_reg
  find_win_home
  loadStyleSheets
  initStylesheetPaths
  readStyleSheets
  saveStyleSheets
  removeStylesheetFile
  readStyleSheetFile
  saveStyleSheetFile
  getStylesheetPatterns
  setStylesheetPatterns
  updateStylesheetMenu
  getStylesheetMenuList
  applyFileSuffix
  parseFileSuffix
  getNodeByNo
  applyWindowStylesheet
  setFHEncoding
);

my $module_name = 'TrEd::Utils';

use_ok($module_name, @subs)
  or die('Could not load module $module_name');

can_ok(__PACKAGE__, @subs);

# Test two windows functions
SKIP: {
#  eval { require Win32::TieRegistry };
#  skip "Win32::TieRegistry not installed", 3 if $@;
  skip "Not on Windows", 3 if $^O ne "MSWin32";
  
  like( fetch_from_win32_reg(q(HKEY_CURRENT_USER), q(Control Panel\Colors), q(Background)), 
        qr/^[\d]{1,3} [\d]{1,3} [\d]{1,3}$/, 
        "fetch_from_win32_reg(): successfully read value from registry");
  is( fetch_from_win32_reg('HKEY_CURRENT_USER', q(Software\NotExist), 'Nothing'), 
      undef, 
      "fetch_from_win32_reg(): return undef on failure");

  # Test if the environment variable is set properly
  find_win_home();
  ok(exists($ENV{'HOME'}) == 1, "find_win_home(): HOME Environment variable set successfully");
  
}

###################################
####### Test setFHEncoding()
###################################
my $utf8_test_string = "Příliš žluťoučký kůň úpěl ďábelské ódy\n";
my $cp1250_test_string = encode("cp1250", $utf8_test_string);
my $utf8_file_name = "utf8_file.txt";
my $cp1250_file_name = "cp1250_file.txt";

# Write cp 1250 string to the file
my $fh;
open($fh, ">", $cp1250_file_name)
  or die "Could not open file $cp1250_file_name";
setFHEncoding($fh, "cp1250");
print $fh $utf8_test_string
  or die "Could not write to file $cp1250_file_name";;
# writing in cp1250
close($fh);

# Write utf8 string to the file
my $fh_2;
open($fh_2, ">", $utf8_file_name)
  or die "Could not open file $utf8_file_name";
setFHEncoding($fh_2, ":utf8");
print $fh_2 $utf8_test_string
  or die "Could not write to $utf8_file_name";
# writing in utf8
close($fh_2);

# Read the string from cp1250 file
open($fh, "<", $cp1250_file_name)
  or die "Could not open file $cp1250_file_name";
binmode($fh);
my $cp1250_bytes=<$fh>;
close($fh);

# Read the string from utf8 file
open($fh_2, "<", $utf8_file_name)
  or die "Could not open file $utf8_file_name";
binmode($fh_2, ":encoding(utf8)");
my $utf8_bytes=<$fh_2>;
close($fh_2);

is($utf8_test_string,   $utf8_bytes,    "setFHEncoding(): utf8 strings are equal");
is($cp1250_test_string, $cp1250_bytes,  "setFHEncoding(): cp1250 strings are equal");

# Remove temporary files
unlink $fh;
unlink $fh_2;

