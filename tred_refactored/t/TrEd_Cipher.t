#!/usr/bin/env perl
# tests for TrEd::Cipher

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;

BEGIN {
  my $module_name = 'TrEd::Cipher';
  our @subs = qw{
    generate_random_block 
    block_to_hex 
    hex_to_block 
    block_xor 
    block_md5
    Negotiate 
    Authentify 
    save_block
  };
  use_ok($module_name, @subs);
}

#binmode(STDOUT, ':utf8');
#binmode(STDERR, ':utf8');

our @subs;
can_ok(__PACKAGE__, @subs);

TrEd::Cipher::generate_random_block(8);

print "hm: |" . TrEd::Cipher::block_to_hex("LOL") . "|\n";

print "hm2: |" . TrEd::Cipher::hex_to_block("4c4f4c") . "|\n";

my $file_name = "my_file";
TrEd::Cipher::save_block("LOL", $file_name);
unlink($file_name);
