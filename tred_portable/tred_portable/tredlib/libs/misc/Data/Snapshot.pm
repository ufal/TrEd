package Data::Snapshot;

# pajas@ufal.ms.mff.cuni.cz          02 srp 2007

use 5.008;
use strict;
use warnings;

use Carp;
use Scalar::Util qw(blessed readonly reftype);

require Exporter;
use base qw(Exporter);

our @EXPORT = qw(
    make_data_snapshot
    restore_data_from_snapshot
);

our $VERSION = '0.02';

#######################################################################################
# Usage         : make_data_snapshot($data, $dump)
# Purpose       : Recursively create data snapshot of $data inside $dump hash
# Returns       : Returns an object containing information for restoring a given data
#                 structure (possibly nested and/or with circular references) to the
#                 exact state as at the time of creating the snapshot.
# Parameters    : ref $data -- reference to data whose snapshot is to be taken
#                 hash_ref $dump -- ref to hash where the data will be stored
# Throws        : Croaks if $data is not a reference.
# Comments      : 
# See Also      : restore_data_from_snapshot()
sub make_data_snapshot {
    my ( $data, $dump ) = @_;
    $dump ||= {};
    if ( !ref $data ) {
        croak "non-reference: $data\n";
    }
    return [ $data, $dump ] if exists $dump->{$data};
    my $data_reftype = reftype( $data );
    if ( $data_reftype eq 'SCALAR' ) {
        $dump->{$data} = [
            $data, readonly(${$data}) ? 'READONLY' : 'SCALAR',
            blessed($data), ${$data}
        ];
    }
    elsif ( $data_reftype eq 'HASH' ) {
        # store hash recursively (references inside hash are
        # followed and stored in snapshot, too)
        $dump->{$data} = [ $data, 'HASH', blessed($data), [%{$data}] ];
        foreach my $val ( values %{$data} ) {
            if ( ref $val && !exists $dump->{$val} ) {
                make_data_snapshot( $val, $dump );
            }
        }
    }
    elsif ( $data_reftype eq 'ARRAY' ) {
        # store array recursively (references inside array are
        # followed and stored in snapshot, too)
        $dump->{$data} = [ $data, 'ARRAY', blessed($data), [@{$data}] ];
        foreach my $val (@{$data}) {
            if ( ref $val && !exists $dump->{$val} ) {
                make_data_snapshot( $val, $dump );
            }
        }
    }
    else {
        $dump->{$data} = [ $data, 'OTHER', blessed($data) ];
    }
    return [ $data, $dump ];
}

#######################################################################################
# Usage         : restore_data_from_snapshot($snapshot)
# Purpose       : Restores a data structure from a snapshot created previously by
#                 make_data_snapshot 
# Returns       : Restored data structure
# Parameters    : array_ref $snapshot -- ref to array which contains data snapshot
# Throws        : Carps if readonly value has been changed since the snapshot has been created
# See Also      : make_data_snapshot()
sub restore_data_from_snapshot {
    my $snapshot = shift;
    my $dump     = $snapshot->[1];
    foreach my $s ( values %{$dump} ) {
        my ( $data, $type, $class, $content ) = @{$s};
        if ( $type eq 'SCALAR' ) {
            ${$data} = $content;
        }
        elsif ( $type eq 'READONLY' ) {
            if (${$data} ne $content) {
                carp 'Readonly-value changed';
            }
        }
        elsif ( $type eq 'HASH' ) {
            %{$data} = @{$content};
        }
        elsif ( $type eq 'ARRAY' ) {
            @{$data} = @{$content};
        }
        if ( ( blessed($data) || q{} ) ne ( $class || q{} ) ) {
            bless $data, $class;
        }
    }
    return $snapshot->[0];
}

1;

__END__



=head1 NAME


Data::Snapshot - Perl module for saving and restoring data snapshot


=head1 VERSION

This documentation refers to 
Data::Snapshot version 0.02.


=head1 SYNOPSIS

  use Data::Snapshot;

  $snapshot = make_data_snapshot($any_ref);
  restore_data_from_snapshot($snapshot);

=head1 DESCRIPTION


Create a snapshot of the data structures and restore
the data from the snapshot.



=head1 SUBROUTINES/METHODS

=over 4 


=item * C<Data::Snapshot::make_data_snapshot($data, $dump)>

=over 6

=item Purpose

Recursively create data snapshot of $data inside $dump hash

=item Parameters

  C<$data> -- ref $data -- reference to data whose snapshot is to be taken
  C<$dump> -- hash_ref $dump -- ref to hash where the data will be stored


=item See Also

L<restore_data_from_snapshot>,

=item Returns

Returns an object containing information for restoring a given data
structure (possibly nested and/or with circular references) to the
exact state as at the time of creating the snapshot.

=back


=item * C<Data::Snapshot::restore_data_from_snapshot($snapshot)>

=over 6

=item Purpose

Restores a data structure from a snapshot created previously by
make_data_snapshot 

=item Parameters

  C<$snapshot> -- array_ref $snapshot -- ref to array which contains data snapshot


=item See Also

L<make_data_snapshot>,

=item Returns

Restored data structure

=back



=back


=head1 DIAGNOSTICS

Croaks "non-reference: data\n" if the data passed to make_data_snapshot subroutine is not a reference.
Carps 'Readonly-value changed' if a readonly value has been changed by restore_data_from_snapshot subroutine.


=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.


=head1 DEPENDENCIES

CPAN modules:
Tk,
Readonly

TrEd modules:
TrEd::Window::TreeBasics

Standard Perl modules:
Carp,
Scalar::Util,
Exporter;


=head1 INCOMPATIBILITIES

No known incompatibilities.


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 
2007 Petr Pajas (code & part of documentation) <pajas@matfyz.cz>
2011 Peter Fabian (documentation). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
