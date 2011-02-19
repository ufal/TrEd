#!/usr/bin/env perl
# tests for TrEd::MinMax

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use File::Spec;
use Cwd;

use Test::More 'no_plan';

BEGIN {
  my $module_name = 'TrEd::MinMax';
  our @subs = qw(
    min max min2 max2 minstr maxstr sum reduce first shuffle
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);


my $num_a = -3;
my $num_b = 500;

my $num_str_a = "5 sheep";
my $num_str_b = "5 contradictions";

my @list = (1, 2, $num_a, 3, 4, $num_b, 5, 210);

my $str_a = "Actually";
my $str_b = "zz top";
my @list_str = (qw(one two three aaron), $str_a, $str_b);

is(min2($num_a, $num_b), $num_a,
   "min2(): find smaller number");
    
is(min2($num_str_a, $num_str_b), $num_str_b,
   "min2(): comparing strings containing numbers");

is(max2($num_a, $num_b), $num_b,
   "max2(): find bigger number");
    
is(max2($num_str_a, $num_str_b), $num_str_b,
   "max2(): comparing strings containing numbers");
    
is(min(@list), $num_a,
    "min(): find minimal value in the list");
    
is(max(@list), $num_b,
    "min(): find maximal value in the list");
    
is(sum(@list), 1 + 2 + $num_a + 3 + 4 + $num_b + 5 + 210,
    "sum(): summing all the items in the list");

is(minstr(@list_str), $str_a,
    "minstr(): find the first string in the lexicographical ordering from the list");
    
is(maxstr(@list_str), $str_b,
    "maxstr(): find the last string in the lexicographical ordering from the list");

my $first_satisfying = first { $_ eq $str_a} @list_str;
is($first_satisfying, $str_a,
    "first(): find the first item in the list for which the subroutine returns true");
    
my $subtract_all = reduce { $_[0] - $_[1] } @list;
my $correct_subtraction = 1 - 2 - $num_a - 3 - 4 - $num_b - 5 - 210;
is($subtract_all, $correct_subtraction,
    "reduce(): apply subroutine incrementally on the list");
    
##############################
####### Test shuffle()
##############################
my @array_1 = (1, 2, 3, 4, 5);
my @array_2 = shuffle(@array_1);
my @array_2_sorted = sort {$a <=> $b} @array_1;

is_deeply(\@array_2_sorted, \@array_1, "shuffle(): All the elements are present in the result");
