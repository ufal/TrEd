package TrEd::Version;

# pajas@ufal.mff.cuni.cz          17 ri­j 2008

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;
import Exporter qw( import );
our @ISA         = qw(Exporter);
our %EXPORT_TAGS = (
    'all' => [
        qw(
            TRED_VERSION
            CMP_TRED_VERSION_AND
            )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT    = qw( TRED_VERSION );

# next line is modified automatically during the release
our $VERSION = "DEV_VERSION";    # DO NOT MODIFY THIS LINE !!
$VERSION = 99999999 if $VERSION eq 'DEV_VERSION';

# Preloaded methods go here.

#######################################################################################
# Usage         : TRED_VERSION()
# Purpose       : Returns current tred's version
# Returns       : Current version of tred
# Parameters    : no
# Throws        : no exceptions
# Comments      : Is automatically changed to proper version durinng release to 1.commit#
sub TRED_VERSION {
    return $VERSION;
}

#######################################################################################
# Usage         : CMP_TRED_VERSION_AND($other_version)
# Purpose       : Compare version of tred with other version number (1.xyz)
# Returns       : 0 if the versions are equal, -1 if TRED_VERSION is less than $other_version and 1 otherwise.
# Parameters    : string $other_version
# Throws        : no exceptions
# Comments      : Version format: 3.git_commit_date, e.g. 3.20240529
# See Also      : TRED_VERSION()
sub CMP_TRED_VERSION_AND {
    my ($version) = @_;
    return 1 if $VERSION eq 'DEV_VERSION';
    return ( $VERSION <=> $version );
}

1;
__END__

=head1 NAME

TrEd::Version - TrEd version

=head1 SYNOPSIS

   use TrEd::Version;
   print "Current tred version is: ",TRED_VERSION,"\n";

=head1 DESCRIPTION

Get the current version number of TRED.

=head2 EXPORT

TRED_VERSION - a constant.

The tag :all also exports the function

  CMP_TRED_VERSION_AND($otherversion)

which returns 0 if the versions are equal, -1 if TRED_VERSION is less than $otherversion and
1 otherwise.

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

