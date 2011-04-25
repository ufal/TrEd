#!/usr/bin/perl
# -*- cperl -*-

use warnings;
use strict;
use File::HomeDir;
use LWP::Simple;
use LWP::UserAgent;
use HTML::TreeBuilder;
use HTML::LinkExtor;
use Data::Dumper;
use Tk;
use Tk::ProgressBar;
use File::Spec;

my $url = q(http://downloads.activestate.com/ActivePerl/Windows/5.8/);

use Tk;
my $mw=Tk::MainWindow->new;

my $pf=$mw->Frame->pack(-pady => 10, -padx => 15, -fill => 'both' );
$pf->Label(-text => 'Downloading ActivePerl MSI Installator',
	   -font => 'system',
	   -anchor => 'nw')->pack(-expand => 1, -fill => 'x');
my $bf=$mw->Frame->pack(-pady => 10, -padx => 15, -fill => 'x' );
$bf->Button(-text=>'Abort',
	    -command =>sub{ 
		if (
		    $mw->messageBox(
			-title => 'Abort download',
			-message => 'Do you really want to abort downloading ActivePerl?',
			-type => 'yesno',
		    ) eq 'Yes') {
		    $mw->destroy; 
		}
	    },
    )->pack;

$mw->update;

my $last = shift;
my @links;
if (!$last) {
    my $html = get($url);
    if (defined($html)) {
	my $p = HTML::LinkExtor->new(\&extract,$url);
	$p->parse($html);
	if (@links) {
	    $last = $links[-1];
	    print $last,"\n";
	}
    }
}
if ($last) {
	my $file=$last; $file=~s{.*/}{};
	my $target_dir=File::HomeDir->my_desktop;
	my $target=File::Spec->catfile($target_dir,$file);
	if (-f $target) {
	    my $i=1;
	    my $test;
	    while (-f ($test=File::Spec->catfile($target_dir,$i.'_'.$file))) {
		$i++;
		if ($i>1000) {
		    err("files up to $test exist, bailing out");
		    exit 1;
		}
	    }
	    $target=$test;
	}
	my ($percnt_done,$bytes_done);
	for (['Source' => $last],
	     ['Target' => $target]) {
	    my $f = $pf->Frame->pack(-pady => 10, -expand => 'yes', -fill => 'both' );
	    $f->Label(-text => $_->[0],
		      -font => 'system',
		      -anchor => 'nw')->pack(-expand => 1, -fill => 'x');
	    $f->Label(-text => $_->[1],
		      -relief=>'sunken',
		      -anchor => 'nw')->pack(-expand => 1, -fill => 'x');
	}
	my $progress = $pf->ProgressBar(
	    -width => 20,
	    -length => 500,
	    -anchor => 'w',
	    -from => 0,
	    -to => 100,
	    -blocks=>0,
	    -relief=>'sunken',
	    -troughcolor=>'white',
	    -variable => \$percnt_done,
	    -colors=>[
		 map {
		     $_,
		     sprintf('#%02x%02x%02x',200-2*$_,200-2*$_,255-$_);
		 } 0..100,
	    ],
	    )->pack(-side => 'left', -expand => 1, -fill => 'x');
	$pf->Label(
	    -anchor=>'e',
	    -textvariable => \$bytes_done,
	    )->pack(-side=>'left', -padx => 10);
	$mw->update;
	my $start_time = time;
	my $res = download_file($last,$target,sub {
	    my ($done,$total)=@_;
	    $percnt_done = (100 * $done) / $total;
	    my $now = time;
	    my $str = format_bytes($done).' of '.format_bytes($total);
	    if ($now>$start_time) {
		$str.=' ('.format_bytes($done/($now-$start_time)).'/s)'
	    }
	    $bytes_done = $str;
	    $pf->update;
	    $pf->after(1000,[$pf,'update']);
			  });
	if ($res->[0]) {
	    system("msiexec.exe","/i",$target);
	} else {
	    err("Fetching $last failed:\n$res->[1]");
	}
}

sub extract {
    my ($tag,%links)=@_;
    return unless $tag =~ /a/i;
    push @links, grep { m{^\Q$url\E.*\.msi$} } values %links;
}

sub format_bytes {
    my $bytes = shift;
    my $unit;
    no integer;
    return $bytes.' bytes' if $bytes<1024;
    $bytes/=1024;
    my $fmt = "%.2f %s";
    return sprintf($fmt,$bytes,'KiB') if $bytes<1024;
    $bytes/=1024;
    return sprintf($fmt,$bytes,'MiB') if $bytes<1024;
    $bytes/=1024;
    return sprintf($fmt,$bytes,'GiB') if $bytes<1024;
}
sub err {
  $mw->messageBox(
      -title => 'Aborting',
      -message=>"Fatal error occurred:\n@_",
      -type=>'ok'
  );
  die "@_";
}

sub download_file {
  my ($URL, $out_filename, $callback)=@_;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(30);
  $ua->env_proxy;
  my $expected_length;
  my $bytes_received = 0;
  open(my $out_fh, ">", $out_filename) || err("cannot open $out_filename for writing");
  binmode $out_fh;
  my $request = HTTP::Request->new(GET => $URL);
  my $sub = sub {
      my($chunk, $res) = @_;
      use bytes;
      $bytes_received += length($chunk);
      unless (defined $expected_length) {
	  $expected_length = $res->content_length || 0;
      }
      print $out_fh $chunk;
      flush $out_fh;
      print "$bytes_received of $expected_length\t";
      print $res->status_line, " "x20,"\r";
      $callback->($bytes_received,$expected_length);
  };
  my $res = $ua->request($request,$sub);
  print STDERR $res->status_line, "\n" if !$res->is_success;

  my $retry = 1;
  if (!$res->is_success and $retry<10 and $res->status_line=~/^500 .*timeout/) {
    print STDERR "Resuming (retry $retry)\n";
    my $new_request = $request->clone;
    $new_request->header(Range=>'bytes='.($bytes_received+1).'-');
    $res = $ua->request($new_request,$sub);
    print STDERR $res->status_line, "\n" if !$res->is_success;
    $retry++;
  }
  close $out_fh;
#  exit;
  return [$res->is_success,$res->status_line];
}
