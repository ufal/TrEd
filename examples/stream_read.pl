#!/usr/bin/perl

use Fslib;

open my $f, $ARGV[0];

my $fsformat = FSFormat->ReadFrom($f);

my @trees,@tail;
my $l;

while ($l=Fslib::ReadTree($f)) {
  if ($l=~/^\[/) { # je to strom
    my $root=$fsformat->FS->parseFSTree($l);
    # process the tree, e.g.
    push @trees, $root if $root;
  } else { push @tail, $l; }
}

open my $out, ">$ARGV[0]";

$fsformat->writeTo($out); # ulozi hlavicku
foreach my $root (@trees) {
  Fslib::PrintFS($out,undef,
		 \@trees,
		 $fsformat->list,
		 $fsformat->defs);
}
print $out @tail;

# destroy trees
foreach (@trees) {
  Fslib::DeleteTree($_);
}
