# -*- cperl -*-

our %win32_dir = (
  "Desktop" => CSIDL_DESKTOP,
);

my $install_base = File::Spec->rel2abs($FindBin::RealBin);
chdir $install_base;
my $package_dir_510 = File::Spec->catfile($install_base,'packages510_win32');
my $tk_ppd=File::Spec->catfile($package_dir_510,'Tk.ppd');

my $minimum_build = shift || 822;
my $minimum_perl_version = shift || 5.008008;
my $maximum_perl_version = 5.010999;
my $url = q(http://downloads.activestate.com/ActivePerl/Windows/5.8/);
my $ap_download_site = q(http://www.activestate.com/store/activeperl/download/);
my $tred_setup = File::Spec->rel2abs('tred/devel/winsetup/install_tred.pl',$install_base);
my $icon = File::Spec->rel2abs('tred/tredlib/tred.xpm',$install_base);
my $ap_installer_url = shift; #url of the latest .msi
my $ap_installer_local=glob("activeperl58_win32/ActivePerl-*.msi");
if (defined $ap_installer_local) {
  $ap_installer_local=File::Spec->rel2abs($ap_installer_local,$install_base);
}
my $perl_version;

my $mw=Tk::MainWindow->new(-title=>'Installing TrEd');
$mw->optionAdd("*font","{Sans} 9");
my $tf = $mw->Frame(-background=>'white')->pack(-expand => 'yes', -fill => 'x');
my $lf = $tf->Frame(-background=>'white')->pack(-expand => 'yes', -fill => 'x');
$lf->Label(
	   -background=>'white',
	   -font => '{Sans} 16',
	   -foreground => 'darkblue',
	   -text => 'Installing the tree editor TrEd',
)->pack(-side=>'left',-padx=>10,-pady=>10);
$lf->Label(
	   -background=>'white',
	   -image => $mw->Photo(-file => $icon)
	  )->pack(-side=>'right',-padx=>10,-pady=>10);
$tf->Label(
	   -background=>'white',
	   -anchor=>'nw',
	   -font => '{Sans} 10',
	   -text=>'Copyright (c) 2000-2008 by Petr Pajas',
	  )->pack(qw(-expand yes -fill x -padx 10));
$tf->Frame(-height => 10)->pack();
$mw->Frame(-relief=>'sunken',-border=>1,
	   -height => 2)->pack(-expand=>'yes',-fill => 'x');
$mw->Frame(-height => 10)->pack();
my $pf=$mw->Frame(-relief=>'sunken',-border=>2)->pack(-pady => 10, -padx => 15, -fill => 'both' );
my @pack = qw(-padx 10 -pady 10 -fill x -expand yes);

my ($status,$status2,$status3);
$pf->Label(-textvariable => \$status,
	   -justify => 'left',
	   -font => 'system',
	   -anchor => 'nw')->pack(@pack);
$pf->Label(-textvariable => \$status2,
	   -justify => 'left',
	   -height => 4,
	   -anchor => 'nw')->pack(@pack,-pady => 5);
$pf->Label(-textvariable => \$status3,
	   -justify => 'left',
	   -width=>100,
	   -anchor => 'nw')->pack(@pack,-pady => 0);
my $bf=$mw->Frame->pack(-pady => 10, -padx => 15, -fill => 'x' );
our $abort = sub {
  $mw->destroy;
  undef $mw;
  CORE::exit;
};
sub Quit {
  $mw->destroy;
  undef $mw;
  CORE::exit;
};

$bf->Button(-text=>'Abort',
	    -command =>
	    sub {
	      if ($mw->messageBox(-title => 'Question',
				  -message => 'Abort the installation?',
				  -type=>'yesno',
				 ) eq 'Yes') {
		$abort->();
	      }
	    }
	   )->pack(-side => 'left',-padx=>15,-pady=>15);
my $action='';

my $continue_b=$bf->Button(
		   -text => 'Continue',
		   -command => sub {
		     $action->();
		   }
		  )->pack(-side => 'right',-padx=>15,-pady=>15);
$continue_b->focus;

my $option_frame = $pf->Frame;
my @pl = qw(-side top -pady 2 -anchor w);
our @standard_options = (["Download and install ActivePerl automatically for me" => 'download_ap',{}],
		["Open ActivePerl website (I will download and install myself)",'open_ap_site',{}],
		["I have installed ActivePerl in the meantime (check version again)",'recheck_ap_version',{}
		],
		["My ActivePerl installation is here (browse to a disk folder, e.g. C:\\Perl)",'browse_ap',{}
		],
	       );
our @options;
sub display_options {
  @options= @_ ? @_ : @standard_options;
  unless ($option_frame->ismapped) {
    for my $o (@options) {
      $o->[3] = $option_frame->Radiobutton(
					   -text => $o->[0],
					   -variable => \$action,
					   -relief => 'flat',
					   -value => $o->[1],
					   %{$o->[2]},
					  )->pack(@pl);
    }
    $option_frame->pack(qw(-pady 10 -fill x -expand yes -padx 20));
  }
  $continue_b->configure(-state => 'normal');
}
sub hide_options {
  if ($option_frame->ismapped) {
    for my $o (@options) {
      $o->[3]->destroy if $o->[3];
      $o->[3]=undef;
    }
    $option_frame->packForget;
  }
  $continue_b->configure(-state => 'disabled');
}
my $perl;
my $perl_ok;
my $perl_old;
recheck_ap_version();
MainLoop;

exit;

sub browse_ap {
  my $dir = $mw->chooseDirectory(
				 -title=>'Browse to ActivePerl directory',
				 -mustexist => 1,
  );
  print "choosen directory: $dir\n";
  recheck_ap_version($dir);
}
sub recheck_ap_version {
  my ($dir) = @_;
  my $message=check_ap_version($dir);
  print STDERR $message,"\n";
  hide_options();
  if ($perl_ok) {
    install_tk();
    install_tred();
  } else {
    $status='Installation of ActivePerl';
    $status2=$message;
    if ($perl_old) {
      $status2.="\nNote: It is recommended that you uninstall the existing ActivePerl first.";
    }

    if ($ap_installer_local) {
      $status3="\n\Please, choose from the following options:";
      #$action='install_ap';
      {
	my @o = (
			  ["Install ActivePerl now" => 'install_ap',{}],
			  ["I already have ActivePerl installed here (browse to a disk folder, e.g. C:\\Perl)",'browse_ap',{}
			  ],
			 );
	$action=$o[0][1];
	display_options(@o);
      }

    } else {
      $status3="For licensing reasons, ActivePerl installer cannot be distributed with this software.\n".
	"You can choose from the following options:";
      display_options(@standard_options);
      if ($options[0][2]->{-state} ne 'disabled') {
	$action=$options[0][1];
      } else {
	$action=$options[1][1];
      }
    }
  }
}

sub download_ap {
  hide_options();
  $status='Locating ActivePerl installer';
  $status2='Connecting to ActiveState website...';
  $status3='Please wait.';
  $mw->update;
  $mw->idletasks;
  locate_latest_ap() unless defined $ap_installer_url;
  if ($ap_installer_url) {
    $status='Downloading ActivePerl';
    $status2="Downloading ActivePerl installer.\n".
      "The downloaded package will be saved on your Desktop in case you need it later again.";
    $status3='This will take a while.';
    $mw->update;
    $mw->idletasks;
    $ap_installer_local = download_latest_ap();
    if ($ap_installer_local) {
      $status2="Download sucessfully completed.";
      $status3='Press Continue to install ActivePerl.';
      $action='install_ap';
      $continue_b->configure(-state => 'normal');
    }
  } else {
    $status='Downloading ActivePerl - failed';
    $status2="Failed to find a suitable ActivePerl package on the web.\n".
      "Please, try to download and install ActivePerl yourself.\n";
    $status3="Please, choose next action:";
    my @o = @standard_options;
    local $o[0][2]->{-state} = 'disabled';
    display_options(@o);
    $action=$options[1][1];
  }
}

sub install_ap {
  $status='Installing ActivePerl';
  $status2="Please follow the instructions of the ActivePerl Setup Wizard (other window).";
  $status3="Waiting for the installer to finish\n";
  $mw->update;
  if (job("msiexec.exe",qq(/i "$ap_installer_local"))==0) {
    recheck_ap_version();
  } else {
    $status2="ActivePerl installer returned error.\n";
    $status3="Please, choose next action:";
    hide_options();
    display_options(@standard_options,
		    ['Try run the ActivePerl Installer again','install_ap',{}]
		   );
  }
}

sub open_ap_site {
  system("start $ap_download_site");
  $action = 'recheck_ap_version'
}
sub install_tk {
  if ($perl_version >= 5.010 and system($perl,'-MTk', '-e1')!=0) {
    print "Installing Tk for $perl $perl_version\n";
    $mw->update;
    $status  = "Installing Perl/Tk\n";
    $status2 = "Please wait for PPM installer to finish\n";
    $status3 = "This may take a while...";
    $mw->update;
    my $ppm = File::Spec->rel2abs('ppm',dirname($perl));
    print "Perl: $perl\n";
    print "PPM: $ppm\n";
    print "Tk.ppd: $tk_ppd\n";
    if (job($perl,qq("$ppm" install "$tk_ppd"))==0) {
      $status3="Success.";
    } else {
      $status3="There were errors.";
      if (system($perl,'-MTk', '-e1')!=0) {
	if ($mw->messageBox(-title => 'Question',
			    -message => "Installation of Tk module failed.\n".
			    "Do you want to use Perl Package Manager to install it from the internet?",
			    -type=>'yesno'
			   ) eq 'Yes') {
	  $status2="Starting the Perl Package Manager";
	  $status3="Use Ctrl+1 and select the package named 'Tk'\n".
	    "Apply the button 'Mark for install [+]' on the package and\n".
	    "then the button 'Run marked actions [Ctrl+Enter]' to install it";
	  $mw->update;
	  job($perl,qq("$ppm"));
	  $status2="PPM ended.";
	  $status3="";
	  $mw->update;
	  $continue_b->configure(-state => 'normal');
	  if (job($perl,'-MTk -e1')!=0) {
	    err("Failed to install PPM Tk package!");
	  } else {
	    $action = 'install_tred';
	  }
	}
      }
    }
    $mw->update;
  }
}
sub install_tred {
  if (-f $tred_setup) {
    $status  = "Installing TrEd\n";
    $status2 = "Please wait for TrEd Setup Wizard to finish\n";
    $status3 ="";
    if ($mw->ismapped) {
      $mw->update;
    }
    job($perl, qq("$tred_setup"));
    Quit();
  } else {
    err("Couldn't find TrEd installer $tred_setup");
  }
}
my @links;
sub locate_latest_ap {
    my $html = get($url);
    $status2='Obtained directory listing...';
    $mw->update;
    if (defined($html)) {
      my $p = HTML::LinkExtor->new(\&extract,$url);
      $p->parse($html);
      if (@links) {
	$ap_installer_url = $links[-1];
	if ($ap_installer_url) {
	  print STDERR $ap_installer_url,"\n";
	  $status2='Found ActivePerl MSI Installer.';
	  $status3=$ap_installer_url;
	  return;
	}
      }
    }
}

sub download_latest_ap {
  if ($ap_installer_url) {
    $mw->update;
    my $file=$ap_installer_url; $file=~s{.*/}{};
    my $target_dir=Win32::GetFolderPath($win32_dir{Desktop});
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
    my $ppf=$pf->Frame()->pack(-pady => 10, -padx => 15, -fill => 'both' );
    for (['Source' => $ap_installer_url],
	 ['Target' => $target]) {
      my $f = $ppf->Frame->pack(-pady => 10, -expand => 'yes', -fill => 'both' );
      $f->Label(-text => $_->[0],
		-font => 'system',
		-anchor => 'nw')->pack(-expand => 1, -fill => 'x');
      $f->Label(-text => $_->[1],
		-relief=>'sunken',
		-anchor => 'nw')->pack(-expand => 1, -fill => 'x');
    }
    my $progress = $ppf->ProgressBar(
				    -width => 20,
				    -length => 500,
				    -anchor => 'w',
				    -from => 0,
				    -to => 100,
				    -blocks=>0,
				    -relief=>'sunken',
				     -border=>1,
				    -troughcolor=>'white',
				    -variable => \$percnt_done,
				    -colors=>[
					      map {
						$_,
						  sprintf('#%02x%02x%02x',200-2*$_,200-2*$_,255-$_);
					      } 0..100,
					     ],
				   )->pack(-side => 'left', -expand => 1, -fill => 'x');
    $ppf->Label(
	       -anchor=>'e',
	       -textvariable => \$bytes_done,
	      )->pack(-side=>'left', -padx => 10);
    $mw->update;
    my $start_time = time;
    my $old_abort = $abort;
    my $do_abort=0;
    local $abort = sub {
      $do_abort=1;
      print STDERR "Aborting...\n";
      return;
    };
    my $res = eval { download_file($ap_installer_url,$target,sub {
			      my ($done,$total)=@_;
			      $percnt_done = (100 * $done) / $total;
			      my $now = time;
			      my $str = format_bytes($done).' of '.format_bytes($total);
			      if ($now>$start_time) {
				$str.=' ('.format_bytes($done/($now-$start_time)).'/s)'
			      }
			      $bytes_done = $str;
			      $ppf->update;
			      $ppf->idletasks;
			      if ($do_abort) {
				die "ABORTING\n";
			      }
			    });
		   };
    if ($do_abort or $@ =~ 'ABORTING') {
      if (-f $target) {
	print STDERR "Removing $target\n";
	unlink $target || warn $!;
      }
      $old_abort->();
      exit;
    }
    if ($mw and $res->[0] and -f $target) {
      $status='Download successfull!';
      $status2="The MSI installer successfully downloaded to\n".$target;
      $action=' Install ActivePerl ';
      return $target;
    } else {
      err("Fetching $ap_installer_url failed:\n$res->[1]");
    }
  } else {
    err('Failed to locate ActivePerl MSI installer on the web!');
  }
  return;
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
  if ($mw) {
    $mw->messageBox(
		    -title => 'Aborting',
		    -message=>"Fatal error occurred:\n@_",
		    -type=>'ok'
		   );
    $mw->destroy;
  }
  die "@_";
}

sub download_file {
  my ($URL, $out_filename, $callback)=@_;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(15);
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
      print STDERR "$bytes_received of $expected_length\t";
      print STDERR $res->status_line, " "x20,"\r";
      $callback->($bytes_received,$expected_length);
  };
  my $res = $ua->request($request,$sub);
  print STDERR $res->status_line, "\n" if !$res->is_success;

  my $retry = 1;
  if (!$res->is_success and $retry<30 and $res->status_line=~/^500 .*timeout/) {
    print STDERR "Resuming (retry $retry)\n";
    my $new_request = $request->clone;
    $new_request->header(Range=>'bytes='.($bytes_received+1).'-');
    $res = $ua->request($new_request,$sub);
    print STDERR $res->status_line, "\n" if !$res->is_success;
    $retry++;
  }
  close $out_fh;
  if ($res->is_success) {
  } else {
    print STDERR "download failed\n";
  }
#  exit;
  return [$res->is_success,$res->status_line];
}

sub check_ap_version {
  my ($dir)=@_;
  my $ver;
  my $message;
  if (defined $dir) {
    my $p = File::Spec->rel2abs('bin/perl.exe',$dir);
    if (-d $dir and -f $p) {
      $ver = `$p -MActivePerl -e "print ActivePerl->VERSION"`;
      print "Found version $ver in $dir\n";
      chomp $ver;
      if ($ver=~/^\d+$/) {
      } else {
	$message = ( 'ActivePerl not installed in "$dir" or is too old.' );
      }
    } else {
      $message = ( 'ActivePerl not installed in "$dir".' );
    }
  } else {
    $ver =
      $Registry->{"LMachine/Software/ActiveState/ActivePerl//CurrentVersion"} ||
	$Registry->{"CUser/Software/ActiveState/ActivePerl//CurrentVersion"};
  }
  return $message if defined $message;
  if (!defined $ver) {
    $message = ( 'ActivePerl not installed.' );
  } elsif ($ver<$minimum_build) {
    $message = ( "Currently installed build $ver of ActivePerl is too old.\nAt least build $minimum_build is required." );
    $perl_old=1;
  } else {
    if (!defined $dir) {
      $dir = $Registry->{"LMachine/Software/ActiveState/ActivePerl/$ver//"} ||
	$Registry->{"CUser/Software/ActiveState/ActivePerl/$ver//"};
    }
    if (defined $dir) {
      $perl = File::Spec->rel2abs('bin/perl.exe',$dir);
      if (-d $dir and -f $perl) {
	$perl_version = `$perl -e "print \$]"`;
	if (defined $perl_version) {
	  if ($perl_version < $minimum_perl_version) {
	    $message = ( "Currently installed version $perl_version of ActivePerl is too old.\nAt least version $minimum_perl_version is required." );
	    $perl_old=1;
	  } elsif ($perl_version > $maximum_perl_version) {
	    $message = ( "TrEd is not compatible with the installed version $perl_version of ActivePerl.\nVersions based on Perl $minimum_perl_version are recommended." );
	    $perl_old=1;
	  } else {
	    $message = ( "Found ActivePerl $perl_version (build $ver)." );
	    $perl_ok=1;
	  }
	} else {
	  $message = ( "Cannot start Perl executable: $!");
	}
      } else {
	$message = ( "ActivePerl (build $ver) installed in $dir, but executable $perl does not exist!");
      }
    } else {
      $message = ( "ActivePerl installation not found" );
    }
  }
  print STDERR $message,"\n";
  return $message;
}

sub system_noblock {
  my ($cmd,$args,$cb,$opts)=@_;
  my $job = Win32::Job->new;
  $opts ||= {no_window=>1};
  print "Starting job: $cmd $args\n";
  $job->spawn($cmd,"$cmd $args",$opts);
  $job->watch(sub {
		if (defined($cb) and $cb->()) {
		  return 1;
		} else {
		  Tk::Event::DoOneEvent(0);
		  return 0;
		}
	      },0.01);
  return $job->status()->{exitcode};
}

sub job {
  my ($cmd,$args,$opts)=@_;
  my $do_abort=0;
  local $abort = sub {
    $do_abort=1;
    print STDERR "Aborting...\n";
    return;
  };
  my $ret = system_noblock($cmd,$args, sub {  $do_abort; },$opts);
  if ($do_abort) {
    Quit();
    return -1000;
  }
  return $ret;
}
