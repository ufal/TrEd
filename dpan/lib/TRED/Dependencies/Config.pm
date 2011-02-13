#!/usr/bin/env perl
=head1 Configuration script for automated installation of TrEd dependencies 

This file contains configuration for the install_deps_2__.pl script.
It lists modules to install. Each module is specified by
its filename without version number and extension.

Changelog:
	0.0.3 -- Added dpan_mirror location
	0.0.2 -- using quotes in anonymous hash keys

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Config;
use warnings;
use strict;
use Exporter;
use version;
use Carp;
# use Data::Dumper;

use vars qw($VERSION @ISA @EXPORT);

our $VERSION = qv('0.0.3');

our @ISA = qw(Exporter);
our @EXPORT = qw(custom_build_params special_module_msg win_pkgs patched_pkgs universal_pkgs dpan_mirror);

sub new {
	my $package = shift;
	# Custom build parameters for some packages
	my %custom_build_params = (
		"Tk" 			=> "XFT=1",
		"XML::LibXSLT" 		=> "SKIP_SAX_INSTALL=1",
	);
	
	# Some messages for better communication with the
	my %special_module_msg = (
		"Tk"		=> "; please be patient,\n\t this can take up to several minutes\n\t depending on your computer speed.\n\t Many windows will appear during testing of Tk,\n\t don't close them, just wait until the test finishes...\n",
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
	my @win_pkgs = qw(
		Win32
		!Win32::API
		!Win32::Codepage::Simple
		Win32API::File
		Win32::Job
		Win32::Registry
		Win32::Shortcut
		Win32::TieRegistry
	);
	
	my @patched_pkgs = qw(
		Syntax::Highlight::Perl
		Graph::Kruskal
		Tk
	);
	
	my @universal_pkgs = qw(
		*these_are_needed_for_building
		IPC::Run3
		Probe::Perl
		Test::Exception
		*CPAN_Build_system_does_not_work_without_Test::Harness
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
		HTML::LinkExtor
		HTML::TreeBuilder
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
		!Tk::DialogReturn
		Tk::Entry
		Tk::Font
		Tk::Frame
		Tk::HistEntry
		Tk::ItemStyle
		!Tk::JComboBox_0_02
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
		*tieto_su_v_pkg_liste_no_neboli_najdene_ako_potrebne_automatickym_nastrojom
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
		XML::LibXML::Iterator
	);

	# * = core packages, ! = don't install these
	# it seems that Graph::Reader is not used in TrEd, try to exclude it, it has some tests that don't pass on windows,
	# because of wrong line endings
	# PDF::API2::Basic::TTF::Font (quite old)
	# Tk::MatchEntry (quite old)
	# IO-Compress -- for PDF::API2
	
	my $self = {
		'custom_build_params_ref' 	=> \%custom_build_params,
		'special_module_msg_ref'	=> \%special_module_msg,
		'win_pkgs_ref'			=> \@win_pkgs,
		'patched_pkgs_ref'		=> \@patched_pkgs,
		'universal_pkgs_ref'		=> \@universal_pkgs,
		'dpan_mirror'			=> $dpan_mirror,
		'dpan_dir'			=> $dpan_dir,
	};
	return bless($self, $package);
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
		return "";
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
	return $self->{'win_pkgs_ref'};
}


# patched or modified packages
sub patched_pkgs {
	my $self = shift;
	return $self->{'patched_pkgs_ref'};
}

# universal packages

sub universal_pkgs {
	my $self = shift;
	return $self->{'universal_pkgs_ref'};
}

1;

__END__