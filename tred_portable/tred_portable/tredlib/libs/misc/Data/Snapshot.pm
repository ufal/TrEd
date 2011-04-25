package Data::Snapshot;
# pajas@ufal.ms.mff.cuni.cz          02 srp 2007

use 5.006;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed readonly);

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
  make_data_snapshot
  restore_data_from_snapshot
);

our $VERSION = '0.01';

sub make_data_snapshot {
  my ($data,$dump) = @_;
  $dump ||= {};
  unless (ref($data)) {
    die "non-reference: $data\n";
  }
  return [ $data, $dump ] if exists $dump->{$data};
  if (UNIVERSAL::isa($data,'SCALAR')) {
    $dump->{$data} = [$data, readonly($$data) ? 'READONLY' : 'SCALAR', blessed($data), $$data ]
  } elsif (UNIVERSAL::isa($data,'HASH')) {
    $dump->{$data} = [$data, 'HASH', blessed($data), [ %$data ] ];
    foreach my $val (values %$data) {
      if (ref($val) and !exists($dump->{$val})) {
	make_data_snapshot( $val, $dump );
      }
    }
  } elsif (UNIVERSAL::isa($data,'ARRAY')) {
    $dump->{$data} = [$data, 'ARRAY', blessed($data), [ @$data ] ];
    foreach my $val (@$data) {
      if (ref($val) and !exists($dump->{$val})) {
	make_data_snapshot( $val, $dump );
      }
    }
  } else {
    $dump->{$data} = [ $data, 'OTHER', blessed($data) ];
  }
  return [ $data, $dump ];
}

sub restore_data_from_snapshot {
  my $snapshot = shift;
  my $dump = $snapshot->[1];
  foreach my $s (values %$dump) {
    my ($data,$type,$class,$content) = @$s;
    if ($type eq 'SCALAR') {
      $$data = $content
    } elsif ($type eq 'READONLY') {
      warn "Readonly-value changed" if $$data ne $content;
    } elsif ($type eq 'HASH') {
      %$data = @$content;
    } elsif ($type eq 'ARRAY') {
      @$data = @$content;
    }
    if ((blessed($data)||"") ne ($class||"")) {
      bless $data, $class;
    }
  }
  return $snapshot->[0];
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Data::Snapshot - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Data::Snapshot;

   $snapshot = make_data_snapshot($any_ref);
   restore_data_from_snapshot($snapshot);

=head1 DESCRIPTION

Create a snapshot of the data structures and restore
the data from the snapshot.

=over 5

=item make_data_snapshot ($any_ref)

Returns an object containing information for restoring a given data
structure (possibly nested and/or with circular references) to the
exact state as at the time of creating the snapshot.

=item restore_data_from_snapshot ($snapshot)

Restores a data structure from a snapshot created previously by
make_data_snapshot.

=back

=head2 EXPORT

Functions make_data_snapshot, restore_data_from_snapshot are exported
by default.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

