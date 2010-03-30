#!/usr/bin/perl
# -*- cperl -*-

use FindBin;
use lib ("$FindBin::RealBin",
	 "$FindBin::RealBin/../tredlib",
	 "$FindBin::RealBin/../tredlib/contrib",
	 "$FindBin::RealBin/tredlib",
	 "$FindBin::RealBin/tredlib/contrib"
	);

use Treex::PML;

foreach my $file (@ARGV) {
  print "Processing $file\n";
  my $fs = Treex::PML::Factory->createDocumentFromFile($file,{backends=>[ Treex::PML::ImportBackends('AG2PML') ]});
  print $fs->lastTreeNo,"\n";
  if ($fs->lastTreeNo<0) { die "File is empty or corrupted!\n"; }
  $fs->changeBackend('FS');
  print "Writing to $file.fs\n";
  $fs->writeFile("$file.fs");
  print "done\n";
}
