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

use Getopt::Long;


Win32::SetChildShowWindow(0) if defined &Win32::SetChildShowWindow;

$SIG{__DIE__} = sub {
  print STDERR @_,"\n";
  die $@;
};

my $inc = File::Spec->rel2abs('setup.inc', dirname($0));
print "$inc\n";
do $inc;
die $@ if $@;

