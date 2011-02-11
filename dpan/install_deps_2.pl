#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use TRED::Dependencies::Config;
use TRED::Dependencies::Install;

my $cpan_online_install = 0;
# CPAN install base
my $install_base;
my $log = "install-log.txt";

my $result = GetOptions (	"install-base=s" 	=> \$install_base,
				"log=s"			=> \$log,
				"online-install"  	=> \$cpan_online_install);


my $tred_dep_installer = TRED::Dependencies::Install->new($install_base, $log, $cpan_online_install);
$tred_dep_installer->install_tred_deps();
