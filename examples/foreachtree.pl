#!/usr/bin/perl
#
# Usage: 
# foreachnode.pl files [- script-parameters]
#
# Rreads a perl script from stdin and evals it for every tree in files 
#
# You may use these variables in your SCRIPT:
#
#  @nodes        - ordered array of nodes of current tree 
#  $root         - root node of current tree
#  $f            - current file name
#  $save         - if set to 1, file is saved after each its node is processed
#  %attribs      - attribute definition hash 
#  @atord        - (positional) attribute array
#
# If you want to save the file after each tree is processed, set the $save var. to 1
#
#

use Fslib;
use locale;
use POSIX qw(locale_h);

setlocale(LC_ALL,"cs_CZ");
setlocale(LANG,"czech");

%attribs = ();
@atord = ();

$SCRIPT.=$_ while <STDIN>;

push(@files, shift(@ARGV)) while (defined($ARGV[0]) and $ARGV[0] ne '-');
shift if ($ARGV[0] eq '-');
%tree = ();

$filecount=$#files+1;

foreach $f (@files) {
  @trees = ();
  @header = ();
  @rest = ();
  @nodes=();

  $_found=0;
  die "cannot open $f!\n" unless open(F,"<$f");
  $fileno++;
  print STDERR "$f\t",int(100*$fileno / $filecount),"%\t$fileno of $filecount\n";

  %attribs=ReadAttribs(\*F,\@atord,2,\@header);
#########################
  while ($_=ReadTree(\*F)) {
    if (/^\[/) {
      $root=GetTree($_,\@atord,\%attribs);
      push(@trees, $root) if $root;
#------------------------
      $node=$root;
      while($node)
      {
	delete $$node{"err2"};
	$nodes[$$node{"ord"}]=$node;
	$node=Next($node);
      }
      $save=0;
      die unless eval($SCRIPT);	
      print "Save!\n" if ($save>0);
      $_found+=$save;

      @nodes=();

#-------------------------
    } else { push(@rest, $_); }
  }
########################

  close (F);
  if ($_found) {
    die "cannot open $f.out for writing!\n" unless open(FO,">$f.out");
    print FO @header;
    PrintFS(\*FO,\@header,\@trees,\@atord,\%attribs);
    print FO @rest;
    close(FO);
    print STDERR "$_found matches in $f, wrote to $f.out.\n";
  }
 
  foreach (@trees) { DeleteTree($_); }
  undef @header;
}

