#!/usr/bin/perl

unless (@ARGV) {
  print "Usage: rename_macros.pl map-file < input > output ";
  exit;
}

while (<>) {
  $tr{$2}=$1
    if (/^([_\w][_\w\d]+)\s+([_\w][_\w\d]+)/);
}

my ($k,$v);

while (<STDIN>) {
  while (($k,$v)=each %tr) {
    s/^$k(?![_\w\d])/$v/g;
    s/([^_\w\d])$k(?![_\w\d])/$1$v/g;
  }
  print;
}
