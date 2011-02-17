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
sub _write_text_to_file {
  my ($fname, $encoding, $text) = @_;
  my $fh;
  open($fh, ">", $fname)
    or die "Could not open file $fname";
  setFHEncoding($fh, $encoding);
  print $fh $text
    or die "Could not write to file $fname";;
  close($fh);
}

sub _read_text_from_file {
  my ($fname, $encoding) = @_;
  my $fh;
  open($fh, "<", $fname)
    or die "Could not open file $fname";
  if(defined($encoding)){
    binmode($fh, $encoding);
  } else {
    binmode($fh);
  }
  my $file_bytes=<$fh>;
  close($fh);
  return $file_bytes;
}

my $utf8_test_string = "Příliš žluťoučký kůň úpěl ďábelské ódy\n";
my $cp1250_test_string = encode("cp1250", $utf8_test_string);
my $utf8_file_name = "utf8_file.txt";
my $cp1250_file_name = "cp1250_file.txt";

# Write strings to files using different encoding
_write_text_to_file($cp1250_file_name,  "cp1250", $utf8_test_string);
_write_text_to_file($utf8_file_name,    ":utf8",  $utf8_test_string);

# Read the strings from files
my $cp1250_bytes = _read_text_from_file($cp1250_file_name, undef);
my $utf8_bytes = _read_text_from_file($utf8_file_name, ":encoding(utf8)");

is($utf8_test_string,   $utf8_bytes,    "setFHEncoding(): utf8 strings are equal");
is($cp1250_test_string, $cp1250_bytes,  "setFHEncoding(): cp1250 strings are equal");

# Remove temporary files
unlink $utf8_file_name;
unlink $cp1250_file_name;

