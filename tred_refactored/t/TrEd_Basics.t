#!/usr/bin/env perl
# tests for TrEd::Basics

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

use Test::More;
use Test::Exception;
use Data::Dumper;
use Treex::PML qw{ImportBackends};
use File::Spec;
use Cwd;

#use TrEd::Config;
#use TrEd::Utils;

BEGIN {
  our $module_name = 'TrEd::Basics';
  our @subs = qw(
     error_message
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
our $module_name;
can_ok($module_name, @subs);


done_testing();