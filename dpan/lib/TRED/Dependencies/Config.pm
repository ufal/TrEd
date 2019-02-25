#!/usr/bin/env perl
=head1 Configuration script for automated installation of TrEd dependencies 

This file contains configuration for the install_deps_2__.pl script.
It lists modules to install. Each module is specified by
its filename without version number and extension.

Changelog:
	0.0.7 -- added alpha ppm packages support
	0.0.6 -- LWP::Simple -- new dependency: Encode::Locale
	0.0.5 -- Added support for installation of packages without running test
	0.0.4 -- Added more complex and powerful way of passing custom build & install parameters to cpan
	0.0.3 -- Added dpan_mirror location
	0.0.2 -- using quotes in anonymous hash keys

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Config;
use warnings;
use strict;
use version;
use Carp;
use FindBin;
# use Data::Dumper;

use vars qw($VERSION);

our $VERSION = qv('0.0.7');

sub new {
	my $package = shift;
	
	my %Tk_makepl_arg = ("add" => {"makepl_arg" => "XFT=1"});
	my %XML_LibXSLT_makepl_arg = ("add" => {"makepl_arg" => "SKIP_SAX_INSTALL=1"});
	
	# Custom build parameters for some packages
	my %custom_build_params = (
		"Tk" 			=> \%Tk_makepl_arg,
		"XML::LibXSLT" 		=> \%XML_LibXSLT_makepl_arg,
	);
	if($^O ne "MSWin32"){	
		require CPAN::Shell;
		require CPAN::HandleConfig;
		CPAN::Shell->import(qw{setup_output});
		CPAN::HandleConfig->import();
		# init cpan
		CPAN::HandleConfig->load();
		CPAN::HandleConfig->require_myconfig_or_config();
		CPAN::Shell::setup_output();
		
		my $make_command = $CPAN::Config->{'make'};
		if (!defined($make_command) || $make_command eq ""){
			$make_command = "make";
		}
		
		# If XML::SAX is installed by root user or in location not writable by us, the installation on XML::LibXML will fail
		# because it needs to write to XML/SAX/ParserDetails.ini, which in situated in 
		# /usr/local/share/perl/version (on linux)
		# /System/Library/Perl/Extras/version (on Mac OS X)
		# so we need to run installation as super-user
		my %XML_LibXML_make_install_make_command = ("replace" => {"make_install_make_command" => "sudo $make_command"});
		
		$custom_build_params{"XML::LibXML"} = \%XML_LibXML_make_install_make_command;
	}
	
	my %notest_pkgs = (
		"Tk"		=> 1,
	);
	
	# Some messages for better communication with the
	my %special_module_msg = (
		"Tk"		=> "; please be patient,\n\t this can take up to several minutes\n\t depending on your computer speed.\n",
		"PDF::API2"	=> "; please be patient...",
	);

	# create full path to local CPAN subset
	## TODO think about it, this is not really robust... relative to some other script that called us...maybe a parameter...
	my $perlscript_dir = $FindBin::Bin;
	my $dpan_dir = File::Spec->catdir($perlscript_dir, "dpan");
	my $authors_file = File::Spec->catfile($dpan_dir, "authors", "01mailrc.txt.gz");
	if(! -d $dpan_dir){
		croak "$dpan_dir is not a directory, DPAN could not be there!\n";
	}
	if(! -e $authors_file){
		croak "$dpan_dir is probably not a DPAN directory, exiting...\n";
	}
	my $dpan_mirror;
	if($dpan_dir =~ /^\//){
		$dpan_mirror = "file://" . $dpan_dir;
	} else {
		$dpan_mirror = "file:///" . $dpan_dir;
	}
	
	### Win32::API and Win32::Codepage::Simple are used only in old windows installer and can not be built under x64
	my @win_pkgs = qw{
		Win32
		!Win32::API
		!Win32::Codepage::Simple
		Win32API::File
		Win32::Job
		!Win32::Registry
		Win32::Shortcut
		Win32::TieRegistry
	};
	
	my @patched_pkgs = qw{
		Tk
		Syntax::Highlight::Perl
		Graph::Kruskal
	};
	
	my @mac_pkgs = qw{
		Mac::SystemDirectory
	};
	
	my @universal_pkgs = qw{
		!these_are_needed_for_building
		IPC::Run3
		Probe::Perl
		Test::Exception
		!CPAN_Build_system_does_not_work_without_Test__Harness
		Test::Harness
		Test::Script
		XML::NodeFilter
		Sub::Uplevel
		***********
		Archive::Zip
		*Benchmark
		*Carp
		*Class::Struct
		Class::Std
		*CPAN
		*Cwd
		*Data::Dumper
		*Devel::Peek
		*Digest::MD5
		*Encode
		Encode::Locale
		*Exporter
		*ExtUtils::MM
		*Fcntl
		*File::Basename
		*File::Copy
		*File::Find
		*File::Glob
		File::HomeDir
		*File::Path
		File::ShareDir
		*File::Spec
		*File::Spec::Functions
		*File::Temp
		File::Which
		*FindBin
		*Getopt::Long
		*Getopt::Std
		*I18N::Langinfo
		*IO
		*IO::File
		*IO::Pipe
		*IO::Select
		*IO::Socket
		*IO::Socket::INET
		IO::String
		IO::Zlib
		*List::Util
		LWP::Simple
		LWP::UserAgent
		*MIME::Base64
		PDF::API2
		PDF::API2::Basic::TTF::Font
		*Pod::Usage
		*POSIX
		PostScript::ISOLatin1Encoding
		PostScript::StandardEncoding
		Readonly
		*Safe
		*Scalar::Util
		*Storable
		*Sys::Hostname
		Tie::IxHash
		Tk::Bitmap
		Tk::Button
		Tk::CodeText
		!Tk::Config
		Tk::Derived
		Tk::Dialog
		Tk::DialogBox
		!Tk::DialogReturn__in_tred
		Tk::Entry
		Tk::Font
		Tk::Frame
		Tk::HistEntry
		Tk::ItemStyle
		!Tk::JComboBox_0_02__in_tred
		Tk::JPEG
		Tk::LabFrame
		Tk::Listbox
		Tk::MatchEntry
		Tk::Menu
		Tk::Menubutton
		Tk::Menu::Item
		Tk::NoteBook
		Tk::Photo
		Tk::PNG
		Tk::ProgressBar
		Tk::ROText
		Tk::Text
		Tk::TextUndo
		Tk::Toplevel
		Tk::Tree
		Tk::Widget
		Tk::widgets
		Treex::PML
		*UNIVERSAL
		UNIVERSAL::DOES
		URI
		URI::Escape
		URI::file
		XML::CompactTree
		XML::CompactTree::XS
		XML::LibXML
		XML::LibXML::Reader
		XML::LibXML::SAX
		XML::LibXML::SAX::Parser
		XML::LibXSLT
		XML::Writer
		XML::XPath
		!tieto_su_v_pkg_liste_no_neboli_najdene_ako_potrebne_automatickym_nastrojom
		Class::Inspector
		Compress::Raw::Zlib
		Compress::Raw::Bzip2
		Graph
		Graph::ChuLiuEdmonds
		!Graph::Reader
		IO::Compress::Gzip
		Parse::RecDescent
		Text::Iconv
		version
		!XML::JHXML
		XML::NamespaceSupport
		XML::SAX
		XML::SAX::Base
		XML::LibXML::Iterator
                !needed for extensions
                File::pushd
	};
	
	my @ppm_deps = qw{
		UNIVERSAL-DOES
		Tk
		Tk-MatchEntry
		Win32-API
		File-Which
		Tie-IxHash
		XML-JHXML
		XML-NamespaceSupport
		XML-SAX
		XML-LibXML
		XML-LibXML-Iterator
		XML-LibXSLT
		XML-CompactTree
		XML-CompactTree-XS
		XML-Writer
		Syntax-Highlight-Perl
		Tk-CodeText
		Parse-RecDescent
		Graph
		Graph-ChuLiuEdmonds
		Graph-Kruskal
		Class-Std
		!Graph-ReadWrite
		version
		Class-Inspector
		File-ShareDir
		Treex-PML
	};

	# * = core packages, ! = don't install these
	# Graph::Reader (Graph-ReadWrite) -- it seems that it is not used in TrEd (neither in Treex::PML), try to exclude it, it has some tests that don't pass on windows,
	# because of wrong line endings
	# PDF::API2::Basic::TTF::Font (quite old)
	# Tk::MatchEntry (quite old)
	# IO::Compress -- for PDF::API2
	# Class::Std -- listed in win32 dependencies, but never actually used in code (neither in extensions), try to ignore...
	#            -- Actually, it is needed for TectoMT base extension, so we should better keep it.
	# HTML::LinkExtor   -- used only in old setup script
	# HTML::TreeBuilder -- -- || --
	# Win32::Registry -- obsolete, removed from TrEd::Config, now only for maintenance, developing & testing purposes...
	
	my %ppm_repos = (
		"univ" => {
			"BRIBES-TRED"		=> "http://www.bribes.org/perl/ppm",
		},
		"58" => {
			"WINNIPEG-TRED"		=> "http://theoryx5.uwinnipeg.ca/ppms",
			"TCOOL-TRED" 		=> "http://ppm.tcool.org/archives",
			"TROUCHELLE-TRED"	=> "http://trouchelle.com/ppm/",
			"UFAL-TRED"			=> "http://ufal.mff.cuni.cz/~pajas/ppms/",
		#	"MY-UFAL-MIRROR-TRED"			=> "http://www.ms.mff.cuni.cz/~fabip4am/big/tred/ppms/",
		},
		"510" => {
			"WINNIPEG-TRED"		=> "http://cpan.uwinnipeg.ca/PPMPackages/10xx/",
			"TROUCHELLE-TRED"	=> "http://trouchelle.com/ppm10/",
			"UFAL-TRED"			=> "http://ufal.mff.cuni.cz/~pajas/ppms510/",
		#	"MY-UFAL-MIRROR-TRED"			=> "http://www.ms.mff.cuni.cz/~fabip4am/big/tred/ppms510/",
		},
		"512" => {
			"WINNIPEG-TRED"		=> "http://cpan.uwinnipeg.ca/PPMPackages/12xx/",
			"TROUCHELLE-TRED"	=> "http://trouchelle.com/ppm12/",
			"UFAL-TRED"			=> "http://ufal.mff.cuni.cz/~pajas/ppms512/",
		}
	);
	
	my $self = {
		'custom_build_params_ref' 	=> \%custom_build_params,
		'special_module_msg_ref'	=> \%special_module_msg,
		'should_not_be_tested_ref'	=> \%notest_pkgs,
		'win_pkgs_ref'				=> \@win_pkgs,
		'mac_pkgs_ref'				=> \@mac_pkgs,
		'patched_pkgs_ref'			=> \@patched_pkgs,
		'universal_pkgs_ref'		=> \@universal_pkgs,
		'ppm_pkgs_ref'				=> \@ppm_deps,
		'ppm_repos_ref'					=> \%ppm_repos,
		'dpan_mirror'				=> $dpan_mirror,
		'dpan_dir'					=> $dpan_dir,
	};
	return bless($self, $package);
}

sub ppm_repos_for_vers {
	my ($self, $perl_version) = @_;
	# add repositories for this version
	my %ppm_repositories = %{$self->{'ppm_repos_ref'}->{$perl_version}};
	# and also universal repositories
	foreach my $repo_name (keys(%{$self->{'ppm_repos_ref'}->{'univ'}})) {
		$ppm_repositories{$repo_name} = $self->{'ppm_repos_ref'}->{'univ'}->{$repo_name};
	}
	return \%ppm_repositories;
}

sub dpan_mirror {
	my ($self) = @_;
	return $self->{'dpan_mirror'};
}

sub dpan_dir {
	my ($self) = @_;
	return $self->{'dpan_dir'};
}

sub custom_build_params {
	my ($self, $module_name) = @_;
	if(defined($self->{'custom_build_params_ref'}->{$module_name})){
		return $self->{'custom_build_params_ref'}->{$module_name};
	} else {
		return undef;
	}
}

sub special_module_msg {
	my ($self, $module_name) = @_;
	if(defined($self->{'special_module_msg_ref'}->{$module_name})){
		return $self->{'special_module_msg_ref'}->{$module_name};
	} else {
		return "";
	}
}

# packages only for running TrEd on windows
sub win_pkgs {
	my $self = shift;
	my @pkgs = grep {!/^!/ and !/^\*/} @{$self->{'win_pkgs_ref'}};
	return \@pkgs;
}

# packages only for running TrEd on Mac OS
sub mac_pkgs {
	my $self = shift;
	my @pkgs = grep {!/^!/ and !/^\*/} @{$self->{'mac_pkgs_ref'}};
	return \@pkgs;
}

# patched or modified packages
sub patched_pkgs {
	my $self = shift;
	my @pkgs = grep {!/^!/ and !/^\*/} @{$self->{'patched_pkgs_ref'}};
	return \@pkgs;
}

# universal packages
sub universal_pkgs {
	my $self = shift;
	my @pkgs = grep {!/^!/ and !/^\*/} @{$self->{'universal_pkgs_ref'}};
	return \@pkgs;
}

sub ppm_pkgs {
	my $self = shift;
	my @pkgs = grep {!/^!/ and !/^\*/} @{$self->{'ppm_pkgs_ref'}};
	return \@pkgs;
}

# should the package be tested before installation?
sub should_be_tested {
	my ($self, $pkg_name) = @_;
	if(exists($self->{'should_not_be_tested_ref'}->{$pkg_name})){
		return 0;
	} else {
		return 1;
	}
}

1;

__END__
