#!/usr/bin/env perl
=head1 Automated download of TrEd dependencies from CPAN script

Changelog:
	0.0.1 -- First version

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Download;

use strict;
use warnings;
use CPAN;
use CPAN::HandleConfig;
use Config;
use FindBin;
use Getopt::Long;
use File::Spec;
use Cwd;
use TRED::Dependencies::Config;
use version;

use vars qw($VERSION @ISA @EXPORT);

our $VERSION = qv('0.0.1');

our @ISA = qw(Exporter);
our @EXPORT = qw(download_from_cpan);

sub new {
	my ($package) = @_;
	
	my $tred_dpan_config = TRED::Dependencies::Config->new();
	
	CPAN::HandleConfig->load;
	CPAN::HandleConfig->require_myconfig_or_config();
	my $wget = $CPAN::Config->{wget};
	
	my $pkgs_to_patch_ref = $tred_dpan_config->patched_pkgs();
	my $universal_pkgs_ref = $tred_dpan_config->universal_pkgs();
	my $win32_pkgs_ref = $tred_dpan_config->win_pkgs();
	
	my @all_pkgs = (@{$pkgs_to_patch_ref}, @{$universal_pkgs_ref}, @{$win32_pkgs_ref});
	
	my %needed_files;
	my %files_to_download;
	
	my $self = {
		'dpan_config'		=> $tred_dpan_config,
		'wget'			=> $wget,
		'all_pkgs_ref'		=> \@all_pkgs,
		'needed_files'		=> \%needed_files,
		'files_to_download'	=> \%files_to_download,
	};
	return bless($self, $package);
}



sub download_from_cpan {
	my ($self) = @_;
	
	# Initialize some information needed for subsequent routines
	$self->_init_metainfo();
	# download new packages
	$self->_download_fresh_packages();
	# remove old and obsolete packages
	$self->_clean_up_dpan();
	
	# probably in bash...
	# apply patches
	$self->_apply_patches();
	# reindex
	$self->_reindex();
	
	$self->_nasty_hack();
}

# we use older pdf::api2, that has also other dependencies, that's why we have to get rid of this newer one...
sub _nasty_hack {
	my ($self) = @_;
	my $package_dir = File::Spec->catdir($self->{'dpan_config'}->dpan_dir(), "authors", "id", "D", "DP", "DPAN");
	my $orig_cwd = getcwd();
	chdir($package_dir);
	my ($pdf_api2) = glob("PDF-API2-2.*.tar.gz");
	unlink $pdf_api2;
	chdir($orig_cwd);
}

sub _reindex {
	print "Reindex...\n";
}

sub _apply_patches {
	#### TODO?
	# it will be probably easier as a bash script...
}


sub _clean_up_dpan {
	my ($self) = @_;
	my $package_dir = File::Spec->catdir($self->{'dpan_config'}->dpan_dir(), "authors", "id", "D", "DP", "DPAN");
	my $orig_cwd = getcwd();
	chdir($package_dir);
	
	print "Cleaning up DPAN repo.\n";
	
	my @packages = glob("*.tar.gz");
	
	foreach my $package ( @packages ) {
		if(exists($self->{'needed_files'}->{$package})){
			print "File $package is needed, leaving it.\n"
		} else {
			print "File $package is not needed any more, deleting it.\n";
			unlink $package or warn "Could not remove $package: $!";
			# also remove information that this release was patched (if it was)
			unlink "$package.patched";
		}
	}
	chdir($orig_cwd);
}

sub _init_metainfo {
	my ($self) = @_;
	print "Init DPAN metainfo.\n";
	my $package_dir = File::Spec->catdir($self->{'dpan_config'}->dpan_dir(), "authors", "id", "D", "DP", "DPAN");
	my $orig_cwd = getcwd();
	chdir($package_dir);
	CPAN::Index->force_reload;
	foreach my $module_name (@{$self->{'all_pkgs_ref'}}){
		if($module_name =~ /^!/ || $module_name =~ /^\*/){
			# skip core and commented modules
			next;
		}
		my $module = CPAN::Shell->expandany($module_name);
		my $file_name;
		if($module){
			$file_name = $module->cpan_file();
		}
		if (defined($file_name) and length($file_name)) {
			my $base_name = $file_name; 
			$base_name =~ s{.*/}{};
			if (-f $base_name) {
				# the file exists and we need it -> remember it so we don't delete it during clean-up
				print "File $base_name already exists, skipping.\n";
				$self->{'needed_files'}->{$base_name} = 1;
			} else {
				# this file does not exist, we need to download it 
				print "File $base_name does not exist, pushing into download queue.\n";
				$self->{'needed_files'}->{$base_name} = 1;
				$self->{'files_to_download'}->{$file_name} = 1;
			}
		} else {
			warn "WARNING: Didn't find module $module_name on CPAN!";
		}
	}
	
	chdir($orig_cwd);
}


sub _download_fresh_packages {
	my ($self) = @_;
	my $package_dir = File::Spec->catdir($self->{'dpan_config'}->dpan_dir(), "authors", "id", "D", "DP", "DPAN");
	my $orig_cwd = getcwd();
	chdir($package_dir);
	print "Downloading new packages.\n";
	my @mirror_list = (@{$CPAN::Config->{urllist}}, "http://www.perl.com/CPAN/");
	my @files_to_download = keys(%{$self->{'files_to_download'}});
	foreach my $cpan_file (@files_to_download){
		foreach my $url_prefix (@mirror_list) {
			my $url = $url_prefix . "authors/id/" . $cpan_file;
			print "Fetching URL '$url'\n";
			my @cmd = ($self->{'wget'}, "$url");
			print "Running " . join(" ", @cmd) . "\n";
			system(@cmd)==0 && last;
			print "failed: exit status $?\n";
		}
	}
	
	chdir($orig_cwd);
}

1;

__END__