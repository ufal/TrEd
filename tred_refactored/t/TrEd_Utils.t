#!/usr/bin/env perl
# tests for TrEd::Utils

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;
use IO qw(File Handle);
use utf8;
use Encode;
use Data::Dumper;
use File::Spec;
use Cwd;
use File::Copy; # need move

BEGIN {
  my $module_name = 'TrEd::Utils';
  our @subs = qw(
    fetch_from_win32_reg
    find_win_home
    applyFileSuffix
    parse_file_suffix
    get_node_by_no
    set_fh_encoding

    uniq
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);

### test function uniq()
sub test_uniq {
  my @array = qw{ 1 2 3 4 5 1 2 3 4 1 7 7 2 3 9 8 5 6 };
  my @expected = qw{ 1 2 3 4 5 6 7 8 9 };
  my @uniqued_array = sort(TrEd::Utils::uniq(@array));
  my @sorted_expected = sort(@expected);
    is_deeply(\@uniqued_array, \@sorted_expected,
              "uniq(): return uniqued array");
}

sub test_fetch_from_win32_reg {
# Test two windows functions
  SKIP: {
  #  eval { require Win32::TieRegistry };
  #  skip "Win32::TieRegistry not installed", 3 if $@;
    skip "Not on Windows", 2 if $^O ne "MSWin32";

    like( fetch_from_win32_reg(q(HKEY_CURRENT_USER), q(Control Panel\Colors), q(Background)),
          qr/^[\d]{1,3} [\d]{1,3} [\d]{1,3}$/,
          "fetch_from_win32_reg(): successfully read value from registry");
    is( fetch_from_win32_reg('HKEY_CURRENT_USER', q(Software\NotExist), 'Nothing'),
        undef,
        "fetch_from_win32_reg(): return undef on failure");
  }
}

sub test_find_win_home {
  SKIP: {
  #  eval { require Win32::TieRegistry };
  #  skip "Win32::TieRegistry not installed", 3 if $@;
    skip "Not on Windows", 1 if $^O ne "MSWin32";

    # Test if the environment variable is set properly
    find_win_home();
    ok(exists($ENV{'HOME'}) == 1, "find_win_home(): HOME Environment variable set successfully");

  }
}

###################################
####### Test set_fh_encoding()
###################################
# Write $text to file $fname using $encoding
# (set encoding by using set_fh_encoding() function)
sub _write_text_to_file {
  my ($fname, $encoding, $text) = @_;
  my $fh;
  open($fh, ">", $fname)
    or die "Could not open file $fname";
  set_fh_encoding($fh, $encoding);
  print $fh $text
    or die "Could not write to file $fname";;
  close($fh);
}

# Read text from file $fname (optionally using $encoding)
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

sub test_set_fh_encoding {
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

  is($utf8_test_string,   $utf8_bytes,    "set_fh_encoding(): utf8 strings are equal");
  is($cp1250_test_string, $cp1250_bytes,  "set_fh_encoding(): cp1250 strings are equal");

  # Remove temporary files
  unlink $utf8_file_name;
  unlink $cp1250_file_name;
}

sub test_parse_file_suffix {
  my $file_name;
  my $suffix;
  # (##?[0-9A-Z]+(?:-?\.[0-9]+)?)$
  # ^(.*) (##[0-9]+\.) ([^0-9#][^#]*)$
  # ^(.*) # ([^#]+)$
  my %expected_parse = (
    'filename.tgz##ABC123-.123' => ['filename.tgz', '##ABC123-.123'],
    'filename.tgz##ABC123.123' => ['filename.tgz', '##ABC123.123'],
    'filename.tgz#ABC123.123' => ['filename.tgz', '#ABC123.123'],
    'filename.tgz#ABC123' => ['filename.tgz', '#ABC123'],

    'filename.tgz##123.a12' => ['filename.tgz', '##123.a12'],

    'filename.tgz#,./' => ['filename.tgz#,./', undef],

    'filename.tgz,./' => ['filename.tgz,./', undef],
  );

  foreach my $filename (keys(%expected_parse)){
    my ($got_filename, $got_suffix) = TrEd::Utils::parse_file_suffix($filename);
    is($got_filename, $expected_parse{$filename}->[0],
      "parse_file_suffix(): filename $filename parsed correctly");
    is($got_suffix, $expected_parse{$filename}->[1],
      "parse_file_suffix(): suffix $filename parsed correctly");
  }
}




####################################################
################## Run Tests #####################
####################################################

test_uniq();

test_fetch_from_win32_reg();
test_find_win_home();

test_set_fh_encoding();

test_parse_file_suffix();

done_testing();