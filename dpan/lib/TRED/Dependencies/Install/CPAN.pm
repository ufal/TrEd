#!/usr/bin/env perl
=head1 Automated installation of TrEd dependencies using CPAN script


Changelog:
	0.0.1 -- First version as a subclass of TRED::Dependencies::Install

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Install::CPAN;

use strict;
use warnings;

use TRED::Dependencies::Install
our @ISA = qw(TRED::Dependencies::Install);

use CPAN;
use CPAN::HandleConfig;
use Config;
use FindBin;
use IO::CaptureOutput qw(capture);
use File::Spec;
use Data::Dumper;
use TRED::Dependencies::Config;
use version;


use vars qw($VERSION);
our $VERSION = qv('0.0.1');


#TODO: use named args
sub new {
	my ($class, $install_base, $logfile_name, $cpan_online_install) = @_;
	my $self = $class->SUPER::new($install_base, $logfile_name);
	
	my %cpan_conf_backup = ();
	
	$self->{'cpan_online_install'} = $cpan_online_install;
	$self->{'cpan_conf_backup_ref'} = \%cpan_conf_backup;

	return bless($self, $class);
}



sub _init_cpan {
	my ($self) = @_;
	my $log_output = "";
	# Init CPAN
	CPAN::HandleConfig->load();
	CPAN::HandleConfig->require_myconfig_or_config();
	CPAN::Shell::setup_output();

	capture {
		# Don't colorize output to log
		CPAN::Shell->o("conf", "colorize_output", 0);
	} \$log_output, \$log_output;
	print({$self->{'logfh'}} $log_output);

	$self->_backup_cpan_conf();

}


# but be careful, dependencies must be already present in the local mirror... or we need internet connection
sub _install_local_modules {
	my ($self, $module_list_ref) = @_;
	# use local mirror 
	my $log_output = "";
	capture { 
		print "***adding " .$self->{'install_config'}->dpan_mirror(). " as first mirror\n";
		CPAN::Shell->o("conf", "urllist", $self->{'install_config'}->dpan_mirror());
	} \$log_output, \$log_output;
	print({$self->{'logfh'}} $log_output);
	
	$self->_install_modules($module_list_ref);
	
}

sub _install_online_modules {
	my ($self, $module_list_ref) = @_;
	my $log_output = "";
	capture { 
		# use internet mirror 
		$CPAN::Config->{'urllist'} = $self->{'cpan_conf_backup_ref'}->{'urllist'};
	} \$log_output, \$log_output;
	print({$self->{logfh}} $log_output);
	
	$self->_install_modules($module_list_ref);
}

sub _common_cpan_conf {
	my ($self) = @_;
	my $log_output = "";
	capture { 
		CPAN::Shell->o("conf", "index_expire", 0);
		CPAN::Shell->o("conf", "prerequisites_policy", "follow");
		CPAN::Shell->o("conf", "build_requires_install_policy", "yes");
		CPAN::Shell->o("conf", "build_cache", "1");
		
		# we don't support SQLite CPAN (yet)
		CPAN::Shell->o("conf", "use_sqlite", 0);
		# if UNINST=1 is set, we could mess up the standard installation make  => unset UNINST=1
		CPAN::Shell->o("conf", "make_install_arg", "");
		CPAN::Shell->o("conf", "mbuild_install_arg", "");
		# reload cpan
		CPAN::HandleConfig->load();
		CPAN::Shell::setup_output();
		CPAN::Index->force_reload();
		# set installation directory, but be careful, because on Windows direcotries contain spaces
		# the only choice to handle spaces in MakeMaker is to use 8.3 names, so we have to rely on the installer to pass us
		# proper filename 
		#TODO: (at least a check and a warning would be nice)
		CPAN::Shell->o("conf", "makepl_arg", 'INSTALL_BASE=' . $self->{'install_base'} . '');
		CPAN::Shell->o("conf", "mbuildpl_arg", '--install_base ' . $self->{'install_base'} . '');
	} \$log_output, \$log_output;
	print({$self->{'logfh'}} $log_output);
}

sub _set_custom_parameters {
	my ($self, $custom_build_params_ref, $backup_ref) = @_;
	
	# replace
	my $params_to_replace_ref = $custom_build_params_ref->{"replace"};
	foreach my $param_key (keys(%{$params_to_replace_ref})){
		#create backup
		$backup_ref->{$param_key} = $CPAN::Config->{$param_key};
		#replace the parameter
		CPAN::Shell->o("conf", $param_key, $params_to_replace_ref->{$param_key});
		print "custom param: $param_key=|".$CPAN::Config->{$param_key}."|\n";
	}
	
	#add
	my $params_to_add_ref = $custom_build_params_ref->{"add"};
	foreach my $param_key (keys(%{$params_to_add_ref})){
		#create backup
		$backup_ref->{$param_key} = $CPAN::Config->{$param_key};
		
		#add the parameter
		if(defined($CPAN::Config->{$param_key})){
			CPAN::Shell->o("conf", $param_key, $CPAN::Config->{$param_key} . ' ' . $params_to_add_ref->{$param_key});
		} else {
			CPAN::Shell->o("conf", $param_key, $params_to_add_ref->{$param_key});
		}
		print "custom param: $param_key=|".$CPAN::Config->{$param_key}."|\n";
	}

}

sub _restore_after_custom_parameters {
	my ($self, $backup_ref) = @_;
	# set params back
	foreach my $key (keys(%{$backup_ref})){
		CPAN::Shell->o("conf", $key, $backup_ref->{$key});
	}
}

sub _install_module_cpan {
	my ($self, $module_name) = @_;
	# this mechanism is far from perfect, because if a package is installed as a dependency of another package, 
	# the test would run anyway...
	if(!$self->{'install_config'}->should_be_tested($module_name)){
		print ">>> Installing $module_name without testing\n";
		CPAN::Shell->notest('install', $module_name);
	} else {
		print ">>> Installing $module_name with testing\n";
		CPAN::Shell->install($module_name);
	}
}

sub _print_basic_info {
	my ($self) = @_;
	print "Installation info:\n\tPerl version: $]\n";
	print "\tOS: " . $self->{'platform'} . "\n";
	print "\tCPAN version:  $CPAN::VERSION\n";
}

sub _install_modules {
	my ($self, $module_list_ref) = @_;
	
	# Configure cpan properly
	$self->_common_cpan_conf();
	
	foreach my $module_name (@{$module_list_ref}){
		my $special_msg = $self->{'install_config'}->special_module_msg($module_name);
		print(STDOUT "*** Compiling & installing $module_name $special_msg\n");
		
		my $log_output = "";
		capture {
			my $custom_build_params_ref = $self->{'install_config'}->custom_build_params($module_name);
			
			$self->_print_basic_info();
			
			if(defined($custom_build_params_ref)){
				my %custom_params_backup = ();
				# set custom make parameters
				$self->_set_custom_parameters($custom_build_params_ref, \%custom_params_backup);
				# install module
				$self->_install_module_cpan($module_name);
				# restore usual config after using custom parameters
				$self->_restore_after_custom_parameters(\%custom_params_backup);
			} else {
				$self->_install_module_cpan($module_name);
			}
		} \$log_output, \$log_output;
		my @log_lines = split("\n", $log_output);
		my @make_reports = grep(/ -- (NOT )?OK$|up to date |Running install for module/, @log_lines);
		
		my $install_status = join("\n", @make_reports);
		print(STDOUT $install_status . "\n\n");
		print({$self->{'logfh'}} $log_output);
	}
}

sub _install_modules_smartly {
	my ($self, $module_list_ref) = @_;
	if($self->{'cpan_online_install'} == 1) {
		$self->_install_online_modules($module_list_ref);
	} else {
		$self->_install_local_modules($module_list_ref);
	}

}

sub _backup_cpan_conf {
	my ($self) = @_;
	my @cpan_opts = keys(%{$CPAN::Config});
	foreach my $cpan_option (@cpan_opts){
		$self->{'cpan_conf_backup_ref'}->{$cpan_option} = $CPAN::Config->{$cpan_option};
	}
}

sub _restore_cpan_conf {
	my ($self) = @_;
	my @cpan_opts = keys(%{$CPAN::Config});
	foreach my $cpan_option (@cpan_opts){
		$CPAN::Config->{$cpan_option} = $self->{'cpan_conf_backup_ref'}->{$cpan_option};
	};
	# if cpan does not auto commit, we didn't commit anything, so there is no need to make any changes
	# However, if the cpan uses auto_commit, we have to commit after restoring previous values
	my $cpan_uses_autocommit = $CPAN::Config->{'auto_commit'};
	my $log_output;
	if($cpan_uses_autocommit){
		capture {
			CPAN::Shell->o("conf", "commit");
		} \$log_output, \$log_output;
		print({$self->{'logfh'}} $log_output);
	};
	capture {
		CPAN::Index->force_reload();
	} \$log_output, \$log_output;
	print({$self->{'logfh'}} $log_output);
}

sub DESTROY {
	my ($self) = @_;
	print("Restoring CPAN config and index...");
	$self->_restore_cpan_conf();
	print("done\n");
	# Destroy parent
	$self->SUPER::DESTROY if $self->can("SUPER::DESTROY");
}


sub install_tred_deps {
	my ($self) = @_;
	$self->install_tred_deps_cpan();
}

sub install_tred_deps_cpan {
	my ($self) = @_;
	$self->_init_cpan();
	$self->_backup_cpan_conf();

	# Let's install modules
	# But be careful, if sth fails, we have to restore original CPAN configuration
	eval {

		# these modules must be installed from local CPAN mirror, because they are patched or modified
		$self->_install_local_modules($self->{'install_config'}->patched_pkgs());
		
		
		# these modules are installed according to user's choice, either from the internet, or from local CPAN mirror
		$self->_install_modules_smartly($self->{'install_config'}->universal_pkgs());

		# these are windows-specific packages, that can be installed according to user's choice, either from the internet, or from local CPAN mirror
		if ($self->{'platform'} eq "MSWin32"){
			print "Detected Windows platform, install Windows-only dependencies...\n";
			$self->_install_modules_smartly($self->{'install_config'}->win_pkgs());
		}
		
		if ($self->{'platform'} eq "darwin"){
			print "Detected MacOS platform, install Mac-only dependencies...\n";
			$self->_install_modules_smartly($self->{'install_config'}->mac_pkgs());
		}
	};

	# Report which packages failed to install
	print("Installing Perl modules done.\n");
	CPAN::Shell->failed();
	print("If some of the modules failed to install correctly, please, install them manually using CPAN command.\n");
}



1;

__END__