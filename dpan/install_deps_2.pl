#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use TRED::Dependencies::Config;


my $cpan_online_install = 0;
# CPAN install base
my $install_base;
my $log = "install-log.txt";

my $result = GetOptions (	"install-base=s" 	=> \$install_base,
				"log=s"			=> \$log,
				"online-install"  	=> \$cpan_online_install);

my $is_active_perl = 0;
my $perl_flavour = eval{
	require ActivePerl::PPM;
};

my $tred_dep_installer;
if($perl_flavour){
	print "ActivePerl detected, starting ppm installation\n";
	$is_active_perl = 1;
	require TRED::Dependencies::Install::PPM;
	$tred_dep_installer = TRED::Dependencies::Install::PPM->new($install_base, $log);
} else {
	print "Starting CPAN installation\n";
	require TRED::Dependencies::Install::CPAN;
	$tred_dep_installer = TRED::Dependencies::Install::CPAN->new($install_base, $log, $cpan_online_install);
}

$tred_dep_installer->install_tred_deps();
