#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use File::Path;
use Config;
use Carp;
use English;
use Getopt::Long;
use FindBin;

$| = 1; # aotoflush STDOUT, so the user can see the progress of installation in real time

# We have to set proper PERL5LIB before running the actual installation, so this is a small wrapper script
my $perl = $^X; 

my $install_base = "";
my $cpan_online_install = 0;
my $log = "";

my $result = GetOptions (	"install-base=s" 	=> \$install_base,
				"log=s"				=> \$log,
				"online-install"  	=> \$cpan_online_install);


if ($install_base eq ""){
	print("Please specify directory for installation tred-dependencies (--install-base)");
	exit(0);
} else {
	# Don't ask on windows, we use an automatic installer...
	if($^O ne "MSWin32") {
		print("Do you really want to install perl modules to $install_base?\n [yes/no]\n");
		my $user_confirm = <STDIN>;
		chomp($user_confirm);
		if($user_confirm =~ /^yes$/i){
			print("Ok, installing...\n");
		} else {
			print("Cancelling.\n");
			exit(0);
		}
	} else {
		print("Installing perl modules to $install_base...\n");
	}
}

# if we call this script on Win32 with sth like recall.pl --install_base "c:\path\somewhere\"
# then the last quote is escaped, so the user should not do it, warn and die...
if ($install_base =~ /"/){
	croak 'Please, don\'t use backslash at the end of install_base, eg use --install_base "c:\dir" instead of --install_base "c:\dir\" or don\'t quote the argument.';
};

# Construct paths to be added to PERL5LIB in platform-independent way 
my ($volume_1_2,$directories,$file) = File::Spec->splitpath($install_base);
my @install_base_dirs = File::Spec->splitdir($directories);

my $inc_dirs_1 = File::Spec->catdir(@install_base_dirs, $file, "lib", "perl5");
my $inc_dirs_2 = File::Spec->catdir(@install_base_dirs, $file, "lib", "perl5", $Config{'archname'});

my ($volume_3,$directories_3,$file_3) = File::Spec->splitpath($FindBin::Bin);
my @find_bin_dirs = File::Spec->splitdir($directories_3);
my $inc_dirs_3 = File::Spec->catdir(@find_bin_dirs, $file_3, "lib");

my $inc_extension_1 = File::Spec->catpath($volume_1_2, $inc_dirs_1);
my $inc_extension_2 = File::Spec->catpath($volume_1_2, $inc_dirs_2);
my $inc_extension_3 = File::Spec->catpath($volume_3, $inc_dirs_3);

my $script = File::Spec->catfile($FindBin::Bin, "install_deps_2.pl");

my $platform = $^O;
my $PERL5LIB_SEPARATOR = $platform eq "MSWin32" ? ";" : ":";

my @inc_extensions = ($inc_extension_1, $inc_extension_2, $inc_extension_3);

# use quotes if appropriate
if ($platform eq "MSWin32") {
	foreach my $inc_str (@inc_extensions){
		#if string contains whitespace, quote it
		if($inc_str =~ m/ /){
			$inc_str = '"' . $inc_str . '"';
		}
	}
}

my $previous_perl5lib = defined($ENV{'PERL5LIB'}) ? $ENV{'PERL5LIB'} : "" ;
$ENV{'PERL5LIB'} = join($PERL5LIB_SEPARATOR, (@inc_extensions, $previous_perl5lib));
print "PERL5LIB = " . $ENV{'PERL5LIB'} . "\n"; 

my @cmd;
if ($cpan_online_install == 0) {
	@cmd = ("$perl", "$script", "--install-base", "$install_base");
} else {
	@cmd = ("$perl", "$script", "--install-base", "$install_base", "--online-install");
}
if ($log ne ""){
	($volume_1_2,$directories,$file) = File::Spec->splitpath($log);
	mkpath($volume_1_2 . $directories);
	push(@cmd, ("--log", "$log"));
}

# print "Run " . join(' ', @cmd) . "\n\n";
# 'system' return value is false on success, therefore we have to use and instead of or...
system(@cmd)
	and croak "Couldn't run: " . join(' ', @cmd) . " ($OS_ERROR)\n";
