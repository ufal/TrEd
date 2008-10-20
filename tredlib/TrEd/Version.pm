gpackage TrEd::Version;
# pajas@ufal.mff.cuni.cz          17 øíj 2008

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;
import Exporter qw( import );
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
  TRED_VERSION
  CMP_TRED_VERSION_AND
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw( TRED_VERSION );

our $SVN_REVISION='$Revision: 3645 $ ';

our $VERSION =  $SVN_REVISION;
$VERSION =~ s{^\$Revision:\s*|\$ $}{}g;
$VERSION = '1.'.$VERSION unless $VERSION=~/\./;

# Preloaded methods go here.

sub TRED_VERSION {
  return $VERSION
}

sub CMP_TRED_VERSION_AND {
  my ($version)=@_;
  return ($VERSION <=> $version);
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

