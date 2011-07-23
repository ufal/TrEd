package TrEd::RuntimeConfig;

use strict;
use warnings;

use TrEd::Config;
# initialized in BEGIN block, initialization here would delete
# the value set in BEGIN block => don't do it here
my $configFile; 

BEGIN {
    # we need to run this early to set up all the config options for other 
    # modules (not only lib, but also fonts, etc...)
    # this may setup a new $libDir
    $configFile = TrEd::Config::read_config();
}

require TrEd::Error::Message;

require TrEd::RecentFiles;
require File::Spec;
require Treex::PML;
require TrEd::Bookmarks;
require TrEd::ManageFilelists;


our $cmdline_config_file;


# config
sub get_config_from_file {
  my @conf;
  if (open(my $fh,"<",$configFile)) {
    @conf=<$fh>;
    close($fh);
    return \@conf;
  } else {
    return;
  }
}

# was main::saveRuntimeConfig
sub save_runtime_config {
  my ($grp,$update) = @_;
  # Save configuration
  print STDERR "Saving some configuration options.\n" if $TrEd::Config::tredDebug;
  my $config = get_config_from_file() || [];
  update_runtime_config($grp,$config,$update);
  save_config($grp,$config, $main::opt_q);
}

# was main::updateRuntimeConfig
sub update_runtime_config {
  my ($grp,$conf,$update)=@_;
  $update||={};
  my $comment = ';; Options changed by TrEd on every close (DO NOT EDIT)';
  my $ommit="canvasheight|canvaswidth|recentfile[0-9]+|geometry|showsidepanel|lastaction|filelist[0-9]+";
  my $update_comment = delete $update->{';'};
  for (keys %$update) {
    $ommit.=qq(|$_);
  }
  @$conf = grep { !/^\s*(?:\Q$comment\E|(?:$ommit)\s*=)/i } @$conf;
  @$conf = grep { !/^\s*;*\s*\Q$update_comment\E/i } @$conf if defined $update_comment;
  pop @$conf while @$conf and $conf->[-1] =~ /^\s*$/;

  push @$conf, "\n",";; ".$update_comment."\n" if $update_comment;
  push @$conf, (map { qq($_\t=\t).$update->{$_}."\n" } keys %$update);

  push @$conf, "\n",$comment."\n";
  #  $geometry=~s/^[0-9]+x[0-9]+//;
  if (TrEd::Bookmarks::get_last_action()) {
    my $s = TrEd::Bookmarks::get_last_action();
    $s=~s/\\/\\\\/g;
    push @$conf,"LastAction\t=\t".$s."\n";
  }
  if ($grp->{top}) {
    eval {
      $TrEd::Config::geometry=$grp->{top}->geometry();
      print "geometry is $TrEd::Config::geometry\n" if $TrEd::Config::tredDebug;
      if ($^O eq "MSWin32" and $grp->{top}->state() eq 'zoomed') {
	$TrEd::Config::geometry=~s/\+[-0-9]+\+[-0-9]+/+-3+-3/;
      }
    };
  }
  do {
    my $s;
    my @recentFiles = TrEd::RecentFiles::recent_files();
    push @$conf,
      "Geometry\t=\t".$TrEd::Config::geometry."\n",
      "ShowSidePanel\t=\t".$TrEd::Config::showSidePanel."\n",
      "CanvasHeight\t=\t".$TrEd::Config::defCHeight."\n",
      "CanvasWidth\t=\t".$TrEd::Config::defCWidth."\n",
	map { 
	  $s=$recentFiles[$_];
	  $s=~s/\\/\\\\/g;
	  "RecentFile$_\t=\t$s\n"
	} 0..$#recentFiles;

    TrEd::ManageFilelists::update_filelists($s, $conf);
    
  };
  chomp $conf->[-1];
}

# config
#!!! treti parameter -- quiet
sub save_config {
 my ($win,$config, $quiet)=@_;
 my $top;
 if (ref($win)=~/^Tk::/) {
   $top = $win->toplevel;
 } else {
   $top = $win->{top};
 }
 my ($default_trc)=File::Spec->catfile($TrEd::Config::libDir,'tredrc');
 if (Treex::PML::IO::is_same_file($configFile,$default_trc)) {
   $configFile = File::Spec->catfile($ENV{HOME},'.tredrc');
 }
 my $exists = -e $configFile ? 1 : 0;
 if (!$exists or (-f $configFile and -w $configFile)) {
    my $renamed = rename $configFile, "${configFile}~" if $exists;
    if (open(my $fh,">$configFile")) {
      print STDERR "Saving tred configuration to: $configFile\n" unless $quiet;
      print $fh (@$config);
      close($fh);
      return;
    } elsif ($renamed) {
      rename "${configFile}~", $configFile;
    }
  }
 # otherwise something went wrong
 { 
   my $lasterr=main::conv_from_locale($!);
   my ($trc)=File::Spec->catfile($ENV{HOME},'.tredrc');
   if (!Treex::PML::IO::is_same_file($configFile,$trc)  and
       ((defined($top) and
	   $top->
	     messageBox(-icon=> 'warning',
			-message=> "Cannot write configuration to $configFile: $lasterr\n\n".
			  "Shell I try to save it to ~/.tredrc?\n",
			-title=> 'Configuration cannot be saved',
			-type=> 'YesNo',
			# -default=> 'Yes' # problem: Windows 'yes', UNIX 'Yes'
		       )=~ m(yes)i) or 
	 (!defined($top) and ! -f $trc and !defined($cmdline_config_file)))) {
     my $renamed = rename $trc, "${trc}~";
     if (open(my $fh,">".$trc)) {
       print STDERR "SAVING CONFIG TO: $trc\n";
       print $fh (@$config);
       print STDERR "done\n";
       close($fh);
       $configFile=$trc;
     } else {
       rename("${trc}~", $trc) if $renamed;
       TrEd::Error::Message::error_message($top,"Cannot write to \"$trc\": $lasterr!\n".
		    "\nConfiguration could not be saved!\nCheck file and directory permissions.",1);
     }
   } else {
     TrEd::Error::Message::error_message($top,"Cannot write to \"$configFile\": $lasterr!\n".
		  "\nConfiguration could not be saved!\nCheck file and directory permissions.",1);
   }
 }
}



1;