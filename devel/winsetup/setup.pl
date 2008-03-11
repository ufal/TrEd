#!/usr/bin/perl
# -*- cperl -*-

use warnings;
use strict;
use LWP::Simple;
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::LinkExtor;
use Data::Dumper;
use Tk;
use Tk::ProgressBar;
use Tk::Photo;
use Tk::ROText;
use Tk::NoteBook;
use Tk::LabFrame;

use File::Spec;
use File::Basename;
use File::Find;
use File::Copy;

use FindBin;

use Win32 qw(CSIDL_DESKTOP CSIDL_PROGRAMS CSIDL_COMMON_PROGRAMS);
use Win32::Shortcut;
use Win32::TieRegistry (Delimiter=>'/');
use Win32::API;
use Getopt::Long;

print "ARGV: ",@ARGV,"\n";
if (@ARGV and $ARGV[0] eq '--log-file') {
  shift;
  my $log = shift;
  open STDERR, '>', $log || warn "Cannot create $log: $!\n";
  open STDOUT, '>&STDERR' || warn "Cannot dup STDERR: $!\n";
}
Win32::SetChildShowWindow(0) if defined &Win32::SetChildShowWindow;

$SIG{__DIE__} = sub {
  print STDERR @_,"\n";
  die $@;
};

my $inc = File::Spec->rel2abs('tred/devel/winsetup/setup.inc',
			      File::Spec->rel2abs($FindBin::RealBin));
do $inc;
die $@ if $@;

