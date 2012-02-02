#!/usr/bin/env perl
# tests for TrEd::ArabicRemix

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

use utf8;

use Test::More;
use Test::Exception;
#use Data::Dumper;

BEGIN {
  our $module_name = 'TrEd::ArabicRemix';
  our @subs = qw(
    direction
    remix
    remixdir
  );
  use_ok($module_name, @subs);
}

our @subs;
our $module_name;
can_ok($module_name, @subs);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


sub test_direction {
  my $also_latin_str = "\x{064B}\x{062E}123456\x{0631}";
  is(TrEd::ArabicRemix::direction($also_latin_str), 1, 
    "direction(): direction = 1 for latin characters");
    
  my $only_arabic = "\x{064B}\x{062E}\x{0631}";
  is(TrEd::ArabicRemix::direction($only_arabic), -1, 
    "direction(): direction = -1 for arabic characters");
    
  my $other = "Γρεεκ λεΘΘερσ";
  is(TrEd::ArabicRemix::direction($other), 0, 
    "direction(): direction = 0 for other characters");
}

sub test_remix {
  my $test_str = "\x{064B}\x{062E}\x{0631}0\x{0632}12\x{064B}\x{062E}";
  
  my $expected_result = "\x{062E}\x{064B}12\x{0632}0\x{0631}\x{062E}\x{064B}";
  is(TrEd::ArabicRemix::remix($test_str), $expected_result, 
    "remix(): reverse substrings");
}

sub test_remixdir {
  my $test_str = "\x{064B}\x{062E}\x{0631}0\x{0632}12\x{064B}\x{062E}";
  my $dont_reverse = 0;
  my $expected_result = "\x{062E}\x{064B}12\x{0632}0\x{0631}\x{062E}\x{064B}";
  is(TrEd::ArabicRemix::remixdir($test_str, $dont_reverse), $expected_result, 
    "remixdir(): reverse substrings");
    
  $dont_reverse = 1;
  $expected_result = "\x{064B}\x{062E}12\x{0632}0\x{064B}\x{062E}\x{0631}";
  is(TrEd::ArabicRemix::remixdir($test_str, $dont_reverse), $expected_result, 
    "remixdir(): don't reverse substrings");
}

#################
### Run Tests ###
#################

test_direction();
test_remix();
test_remixdir();

done_testing();