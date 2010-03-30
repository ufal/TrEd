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
use AG2FS;

foreach my $file (@ARGV) {
  print "Processing $file\n";
  my $fs = Treex::PML::Factory->createDocumentFromFile($file,{backends=>['AG2FS']});
  print $fs->lastTreeNo,"\n";
  if ($fs->lastTreeNo<0) { die "File is empty or corrupted!\n"; }
  $fs->changeBackend('Treex::PML::Backend::FS');
  print "Writing to $file.fs\n";
  $fs->writeFile("$file.fs");
  print "done\n";
}
