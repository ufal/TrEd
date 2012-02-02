#!/usr/bin/env perl
=head1 Automated installation of TrEd dependencies using PPM script


Changelog:
	0.0.1 -- First version as a subclass of TRED::Dependencies::Install

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Install::PPM;

use strict;
use warnings;

use TRED::Dependencies::Install
our @ISA = qw(TRED::Dependencies::Install);

use File::Spec;
use Data::Dumper;
use version;
use ActivePerl::PPM::Client;
use vars qw($VERSION);

our $VERSION = qv('0.0.1');

#TODO: use named args
sub new {
	my ($class, $install_base, $logfile_name) = @_;
	my $self = $class->SUPER::new($install_base, $logfile_name);
	
	$self->{'ppm'} = ActivePerl::PPM::Client->new();
	
	return bless($self, $class);
}


sub DESTROY {
	my ($self) = @_;
	$self->remove_ppm_repos();
	# Destroy parent
	$self->SUPER::DESTROY if $self->can("SUPER::DESTROY");
}


sub install_tred_deps {
	my ($self) = @_;
	$self->install_tred_deps_ppm();
}

# ActivePerl ppm installation

sub install_ppm_pkgs {
	my ($self, $pkgs_to_install_ref) = @_;
	
	my @features = map { my $pkg_name = $_; $pkg_name =~ s/::/-/g; $pkg_name } @{$pkgs_to_install_ref};
	# print Dumper(\@features);
	#TODO: here we can define specific version for each package (instead of undef)
	# but it does not mean that it will be available on the servers, of course
	my @want_array = map { [$_ => undef] } @features;
	my @packages = $self->{'ppm'}->packages_missing( want => \@want_array, force => 1);
	
	print STDOUT "Installing PPM packages, this may take a while...\n";
	eval {
		$self->{'ppm'}->install(packages => \@packages);
	};
	if($@) {
		warn $@;
		if($@ =~ /No packages to install/){
			print STDOUT "Installation successful\n";
		} else {
			print STDOUT "Installation failed!\n";
		}
	} else {
		print STDOUT "Installation successful\n";
	}
}

sub add_ppm_repos {
	my ($self) = @_;
	
	my $version_code = "univ";
	if($] =~ /5\.012/){
		$version_code = "512";
	} elsif($] =~ /5\.010/) {
		$version_code = "510";
	} elsif(($] =~ /5\.008/)) {
		$version_code = "58";
	} else {
		$version_code = "univ";
	}
	
	print "Repositories: \n";
	my @repo_ids = $self->{'ppm'}->repos();
	my %existing_repo_names = ();
	# remember names of repositories (because we do not want to add repos that are already there)
	foreach my $repo_id (@repo_ids){
		# print Dumper($ppm->repo($repo_id));
		$existing_repo_names{$self->{'ppm'}->repo($repo_id)->{'name'}} = 1;
	}
	my $additional_ppm_repos = $self->{'install_config'}->ppm_repos_for_vers($version_code);
	foreach my $repo_name (keys(%$additional_ppm_repos)){
		if(!exists($existing_repo_names{$repo_name})) {
			print STDOUT "Adding $repo_name repository\n";
			eval {
				$self->{'ppm'}->repo_add(
					 name => $repo_name,
					 packlist_uri => $additional_ppm_repos->{$repo_name},
					);
			};
			if($@) {
				warn $@;
			}
		}
	}
}

sub remove_ppm_repos {
	my ($self) = @_;
	
	my $version_code = "univ";
	if($] =~ /5\.012/){
		$version_code = "512";
	} elsif($] =~ /5\.010/) {
		$version_code = "510";
	} elsif(($] =~ /5\.008/)) {
		$version_code = "58";
	} else {
		$version_code = "univ";
	}
	
	my @repo_ids = $self->{'ppm'}->repos();
	my $additional_ppm_repos = $self->{'install_config'}->ppm_repos_for_vers($version_code);
	foreach my $repo_id (@repo_ids){
		# print Dumper($ppm->repo($repo_id));
		my $repo_name = $self->{'ppm'}->repo($repo_id)->{'name'};
		# if we added the repo, remove it
		if(exists($additional_ppm_repos->{$repo_name})){
			print STDOUT "Removing $repo_name repository\n";
			$self->{'ppm'}->repo_delete($repo_id)
		}
	}
}

sub install_tred_deps_ppm {
	my ($self) = @_;
	
	$self->_print_basic_info();
	
	# Add additional repositories
	$self->add_ppm_repos();
	
	# Sync new repositories
	$self->{'ppm'}->repo_sync( {force => 1} );
	
	# If we die, we still have to do the clean up
	# eval {
		# Install dependencies
		$self->install_ppm_pkgs($self->{'install_config'}->ppm_pkgs());
	# };

}

sub _print_basic_info {
	my ($self) = @_;
	print "Installation info:\n\tPerl version: $]\n";
	print "\tOS: " . $self->{'platform'} . "\n";
	# PPM version is not defined
	# print "\tPPM version:  $ActivePerl::PPM::Client::VERSION\n";
}

1;

__END__