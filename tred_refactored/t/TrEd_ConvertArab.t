#!/usr/bin/env perl
# tests for TrEd::ConvertArab

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

use Test::More 'no_plan';
use Test::Exception;

use utf8;

BEGIN {
  our $module_name = 'TrEd::ConvertArab';
  our @subs = qw(
    arabjoin
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
our $module_name;

can_ok($module_name, @subs);

my $hello_world = "\x{0623}\x{0647}\x{0644}\x{0627}\x{064B} \x{0628}\x{0627}\x{0644}\x{0639}\x{0627}\x{0644}\x{0645}!";
# this is actually reversed result of original arabjoin function, because the implementation is modified
my $expected_hw = reverse("!\x{FEE2}\x{FEDF}\x{FE8E}\x{FECC}\x{FEDF}\x{FE8E}\x{FE91} \x{064B}\x{FEFC}\x{FEEB}\x{FE83}");

is(TrEd::ConvertArab::arabjoin($hello_world), $expected_hw, 
  "arabjoin(): convert sample text correctly");