#!/usr/bin/perl
# -*- cperl -*-

use FindBin;
use lib ("$FindBin::RealBin",
	 "$FindBin::RealBin/../tredlib",
	 "$FindBin::RealBin/../tredlib/contrib",
	 "$FindBin::RealBin/tredlib",
	 "$FindBin::RealBin/tredlib/contrib"
	);

use Fslib;
use AG2FS;

foreach my $file (@ARGV) {
  print "Processing $file\n";
  my $fs = FSFile->newFSFile($file,undef,qw(AG2FS));
  print $fs->lastTreeNo,"\n";
  if ($fs->lastTreeNo<0) { die "File is empty or corrupted!\n"; }
  $fs->changeBackend('FSBackend');
  print "Writing to $file.fs\n";
  $fs->writeFile("$file.fs");
  print "done\n";
}
