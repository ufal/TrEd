package TFile::Spec::Functions;

require TFile::Spec;
use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

$VERSION = '1.1';

require Exporter;

@ISA = qw(Exporter);

@EXPORT = qw(
	canonpath
	catdir
	catfile
	curdir
	rootdir
	updir
	no_upwards
	file_name_is_absolute
	path
);

@EXPORT_OK = qw(
	devnull
	tmpdir
	splitpath
	splitdir
	catpath
	abs2rel
	rel2abs
);

%EXPORT_TAGS = ( ALL => [ @EXPORT_OK, @EXPORT ] );

foreach my $meth (@EXPORT, @EXPORT_OK) {
    my $sub = TFile::Spec->can($meth);
    no strict 'refs';
    *{$meth} = sub {&$sub('TFile::Spec', @_)} if $sub;
}


1;
__END__

=head1 NAME

TFile::Spec::Functions - portably perform operations on file names

=head1 SYNOPSIS

	use TFile::Spec::Functions;
	$x = catfile('a','b');

=head1 DESCRIPTION

This module exports convenience functions for all of the class methods
provided by TFile::Spec.

For a reference of available functions, please consult L<TFile::Spec::Unix>,
which contains the entire set, and which is inherited by the modules for
other platforms. For further information, please see L<TFile::Spec::Mac>,
L<TFile::Spec::OS2>, L<TFile::Spec::Win32>, or L<TFile::Spec::VMS>.

=head2 Exports

The following functions are exported by default.

	canonpath
	catdir
	catfile
	curdir
	rootdir
	updir
	no_upwards
	file_name_is_absolute
	path


The following functions are exported only by request.

	devnull
	tmpdir
	splitpath
	splitdir
	catpath
	abs2rel
	rel2abs

All the functions may be imported using the C<:ALL> tag.

=head1 SEE ALSO

TFile::Spec, TFile::Spec::Unix, TFile::Spec::Mac, TFile::Spec::OS2,
TFile::Spec::Win32, TFile::Spec::VMS, ExtUtils::MakeMaker
