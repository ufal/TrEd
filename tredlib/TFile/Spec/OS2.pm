package TFile::Spec::OS2;

use strict;
use vars qw(@ISA $VERSION);
require TFile::Spec::Unix;

$VERSION = '1.1';

@ISA = qw(TFile::Spec::Unix);

sub devnull {
    return "/dev/nul";
}

sub case_tolerant {
    return 1;
}

sub file_name_is_absolute {
    my ($self,$file) = @_;
    return scalar($file =~ m{^([a-z]:)?[\\/]}is);
}

sub path {
    my $path = $ENV{PATH};
    $path =~ s:\\:/:g;
    my @path = split(';',$path);
    foreach (@path) { $_ = '.' if $_ eq '' }
    return @path;
}

my $tmpdir;
sub tmpdir {
    return $tmpdir if defined $tmpdir;
    my $self = shift;
    foreach (@ENV{qw(TMPDIR TEMP TMP)}, qw(/tmp /)) {
	next unless defined && -d;
	$tmpdir = $_;
	last;
    }
    $tmpdir = '' unless defined $tmpdir;
    $tmpdir =~ s:\\:/:g;
    $tmpdir = $self->canonpath($tmpdir);
    return $tmpdir;
}

1;
__END__

=head1 NAME

TFile::Spec::OS2 - methods for OS/2 file specs

=head1 SYNOPSIS

 require TFile::Spec::OS2; # Done internally by TFile::Spec if needed

=head1 DESCRIPTION

See TFile::Spec::Unix for a documentation of the methods provided
there. This package overrides the implementation of these methods, not
the semantics.
