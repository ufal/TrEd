#!/usr/bin/env perl
# update_version.pl     pajas@ufal.mff.cuni.cz     2008/10/21 08:18:10

use warnings;
use strict;
$|=1;

use Getopt::Long;
use Pod::Usage;
Getopt::Long::Configure ("bundling");
my %opts;
GetOptions(\%opts,
	'debug|D',
	'quiet|q',
	'no-update|n',
	'help|h',
	'usage|u',
	'man',
       ) or $opts{usage}=1;

if ($opts{usage}) {
  pod2usage(-msg => 'update_version.pl');
}
if ($opts{help}) {
  pod2usage(-exitstatus => 0, -verbose => 1);
}
if ($opts{man}) {
  pod2usage(-exitstatus => 0, -verbose => 2);
}

use FindBin;
my $rb = $FindBin::RealBin;
$rb=~s{/$}{};
my $version_file = File::Spec->rel2abs('../tredlib/TrEd/Version.pm',$rb);

die "Did not find $version_file!" if !-f $version_file;

my $git_date = `git log -1 --date=format:"\%Y\%m\%d" --format="%ad"`;
my $VER = '3.' . $git_date;

print $VER,"\n" unless $opts{'quiet'};
print STDERR "TrEd::Version: $version_file\n" if $opts{debug};
open my $fh, '<',$version_file || die "Cannot open $version_file: $!";
my @doc=<$fh>;
close $fh;
my $update=0;
for (@doc) {
  if (s/(our\s*\$VERSION\s*=\s*)"([^"]*)"/$1"${VER}"/g) {
    $update = 1 unless $opts{'no-update'};
    print STDERR "Old-version: $2\n" if $opts{debug};
  }
}
if ($update) {
  print STDERR "Updating: $version_file\n" if $opts{debug};
  open $fh, '>',$version_file  || die "Cannot open $version_file: $!";
  print $fh @doc;
  close $fh;
}

__END__

=head1 NAME

update_version.pl - update TrEd version number in TrEd::Version

=head1 SYNOPSIS

update_version.pl [--debug|-D] [--quiet|-q] [--no-update|-n] [REPOSITORY_URL]
or
  update_version.pl -u          for usage
  update_version.pl -h          for help
  update_version.pl --man       for the manual page

=head1 DESCRIPTION

This script updates the version number in the module TrEd::Version based on
the current SVN revision number of TrEd.

=over 5

=item B<--quiet|-q>

Do not print the revision number on STDOUT.

=item B<--debug|-D>

Print the path to TrEd::Version and old version number on STDERR.

=item B<--no-update|-n>

Do not update TrEd::Version, only just print the new version number.

=item B<--usage|-u>

Print a brief help message on usage and exits.

=item B<--help|-h>

Prints the help page and exits.

=item B<--man>

Displays the help as manual page.

=item B<--version>

Print program version.

=back

=head1 AUTHOR

Petr Pajas, E<lt>pajas@sup.ms.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
