#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/lib";

use TRED::Dependencies::Download;


my $tred_dep_updater = TRED::Dependencies::Download->new();
$tred_dep_updater->download_from_cpan();
