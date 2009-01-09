#!/usr/bin/env perl
# -*- cperl -*-

use strict;
use warnings;

use ActivePerl::PPM::Client;
use ActivePerl::PPM::Package;
use ActivePerl::PPM::Logger qw(ppm_status);

use Tk;
use Tk::ProgressBar;
use Tk::ROText;
use Tk::NoteBook;
use Tk::LabFrame;

use File::Spec;
use File::Basename;
use File::Find;
use File::Copy;

use Win32 qw(CSIDL_DESKTOP CSIDL_PROGRAMS CSIDL_COMMON_PROGRAMS);
use Win32::Shortcut;
use Win32::TieRegistry (Delimiter=>'/');

our %win32_dir = (
  "Desktop" => CSIDL_DESKTOP,
  "User's Start Menu" => CSIDL_PROGRAMS,
  "System Start Menu" => CSIDL_COMMON_PROGRAMS,
);
our %create_shortcut = (
  "Desktop" => 1,
  "User's Start Menu" => 1,
  "System Start Menu" => 0,
);

use FindBin;

my $upgrade = 0;
my $install_base=File::Spec->rel2abs($FindBin::RealBin);
my $install_packages = 1;
my $install_tred_path= File::Spec->catfile($install_base,'tred');
my $install_target = 'c:\tred';
my $data_folder = 'c:\tred_data';
my $mk_data_folder = 1;
my ($status,$status2,$progress); # watched text variables
my $Log; # text widget

my $mw=Tk::MainWindow->new(-title=>'TrEd Installer');
$mw->optionAdd("*font","{Sans} 9");
my $lf = $mw->Frame()->pack(-expand => 'yes', -fill => 'x');
$lf->Label(
  -font => '{Sans} 16',
  -text => 'Tree Editor TrEd - Installation',
)->pack(-side=>'left',-padx=>10,-pady=>10);
$lf->Label(
	   -image => $mw->Photo(-file => 'tred/tredlib/tred.xpm')
	  )->pack(-side=>'right',-padx=>10,-pady=>10);
$mw->Label(
	   -anchor=>'nw',
	   -font => '{Sans} 10',
	   -text=>'Copyright (c) 2000-2008 by Petr Pajas',
	  )->pack(qw(-expand yes -fill x -padx 5));

$mw->Frame(qw(-height 2 -relief sunken))->pack(qw(-expand yes -fill x -padx 5 -pady 10));
my $nb = $mw->NoteBook(-takefocus=>0);
$nb->pack(qw(-expand yes -fill both -padx 10 -pady 10));
#$mw->Frame(qw(-height 2 -relief sunken))->pack(qw(-expand yes -fill x -padx 5 -pady 10));
sub next_page {
  my $current=pop || $nb->info('active');
  $nb->raise($current);
  my $next=$nb->info("focusnext");
  $nb->pageconfigure($next,-state=>'normal');
  $nb->pageconfigure($current,-state=>'disabled');
  $nb->raise($next);
}
sub prev_page {
  my $current=pop || $nb->info('active');
  $nb->raise($current);
  my $next=$nb->info("focusprev");
  $nb->pageconfigure($next,-state=>'normal');
  $nb->pageconfigure($current,-state=>'disabled');
  $nb->raise($next);
}

{
  my $name = "license";
  my $page = $nb->add($name,-label => "License", -state => 'normal');
  my $body = $page->Frame->pack(qw(-expand yes -fill both -side top));

  $body->Label(-text=>"Before you install this program, you should read the LICENSE below.\n".
	       "By pressing the button 'I Agree' you indicate your agreement with the terms of the LICENSE.",
	       -anchor=>'nw',
	       -justify=>'left',
	      )
    ->pack(-pady=>20,-padx=>15,-fill => 'x');
  my $license=$body->Scrolled('ROText',
			      -scrollbars => 'osoe',
			      -background => 'white',
			      -height => 15,
			     )->pack(qw(-expand yes -fill both -padx 15));
  $license->Insert( Slurp('tred/LICENSE') || Fail("Couldnot open LICENSE file\n") );
  $license->see('0.0');

  my $bf = $page->Frame->pack(qw(-expand yes -fill x -padx 10 -pady 10 -side bottom));
  $bf->Button(-text=>'Decline',
		-command =>
		sub {
		  if ($mw->messageBox(-title => 'Question',
				      -message => 'Abort the installation?',
				      -type=>'yesno',
				     )) {
		    $mw->destroy;
		    exit;
		  }
		}
	       )->pack(-side => 'left',-padx=>15,-pady=>15);
  $bf->Button(-text=>' I Agree', -command => [\&next_page,$name])->pack(-side => 'right',-padx=>15,-pady=>15)->focus;
}
{
  my $name = "configure";
  my $page = $nb->add($name,-label => "Configure", -state => 'disabled');
  my $body = $page->Frame()->pack(qw(-expand yes -fill both));
  my $bf = $page->Frame()->pack(qw(-fill x -padx 10 -pady 10 -side bottom));
  $bf->Button(-text=>' < Back ', -command => [\&prev_page,$name])->pack(-side => 'left',-padx=>15,-pady=>15);
  $bf->Button(-text=>' Abort ', -command => sub { $mw->destroy; exit; } )->pack(-side => 'left',-padx=>15,-pady=>15);

  $bf->Button(-text=>' Install > ', -command => [\&next_page,$name])->pack(-side => 'right',-padx=>15,-pady=>15)->focus;

  my $target_dir = $body->LabFrame(-label =>'Destination folder for TrEd')->pack(-fill => 'x',-padx=>15,-pady =>15);
  #$target_dir->Label(-text=>,-anchor=>'nw')->pack(-pady=>5,-fill=>'x');
  my $target_f = $target_dir->Frame->pack(-fill=>'x');
  $target_f->Entry(-textvariable=>\$install_target)->pack(-side=>'left',-expand => '1',-fill=>'x',-pady => 10, -padx => 10);
  $target_f->Frame(-width=>20)->pack(-side=>'left');
  $target_f->Button(-text=>'Browse',
		    -command => sub {
		      my $dir = $nb->chooseDirectory(-title=>'Target directory');
		      return unless $dir;
		      $install_target=File::Spec->rel2abs($dir);
		    }
		   )->pack(-side=>'right',-pady => 10,-padx => 10);

  my $data_dir = $body->LabFrame(-label =>'Folder for TrEd data files');
  my $data_f = $data_dir->Frame->pack(-fill=>'x');
  my $data_e = $data_f->Entry(-textvariable=>\$data_folder)->pack(-side=>'left',-expand => '1',-fill=>'x',-pady => 10, -padx => 10);
  $data_f->Frame(-width=>20)->pack(-side=>'left');
  my $data_b = $data_f->Button(-text=>'Browse',
		    -command => sub {
		      my $dir = $nb->chooseDirectory(-title=>'Data directory');
		      return unless $dir;
		      $data_folder=File::Spec->rel2abs($dir);
		    }
		   )->pack(-side=>'right',-pady => 10,-padx => 10);
  $body->Frame(-height=>10)->pack;
  my $sub = sub {
    for my $w ($data_e,$data_b) {
      $w->configure(-state=> $mk_data_folder ? 'normal' : 'disabled');
    }
  };
  $data_dir->Checkbutton(-text=>'Create',
		     -anchor => 'nw',
		     -variable => \$mk_data_folder,
		     -command => $sub,
		    )->pack(-fill => 'x',-padx=>15,-pady =>5 );
  $data_dir->pack(-fill => 'x',-padx=>15,-pady =>5);
  $sub->();
  $body->Frame(-height=>10)->pack;

  my $shortcuts = $body->LabFrame(-label =>'Create icon shortcuts:')->pack(-fill => 'x',-padx=>15,-pady =>15 );
  for my $loc ("Desktop","User's Start Menu", "System Start Menu") {
    $shortcuts->Checkbutton(-text   => $loc,
			    -anchor => 'nw',
			    -variable => \$create_shortcut{$loc}
			   )->pack(-fill => 'x',-padx=>10,-pady =>5 );
  }
}

{
  my $name = "installation";
  my $finish_b;
  my $page = $nb->add($name,
		      -label => "Install",
		      -state => 'disabled',
		      -raisecmd => sub {
			Install();
			$finish_b->configure(-state => 'normal');
			$finish_b->focusForce;
			$status="Installation complete!";
			$status2="";
			$progress=1;
		      }
		     );
  my $body = $page->Frame()->pack(qw(-expand yes -fill both));
  my $bf = $page->Frame()->pack(qw(-fill x -padx 10 -pady 10 -side bottom));
  #$bf->Button(-text=>' Abort ', -command => [\&prev_page,$name])->pack(-side => 'left',-padx=>15,-pady=>15);
  $finish_b = $bf->Button(-text=>' Finish ', -state=>'disabled',
			  -command => sub { $mw->destroy; exit },
			 )->pack(-side => 'right',-padx=>15,-pady=>15);

  $body->Label( -textvariable => \$status,
	      -font=>'system',
	      -width => 60,
	      -anchor => 'w',
	    )->pack(-expand => 1, -fill => 'x', -padx => 10);
  $body->Label( -textvariable => \$status2,
	      -anchor => 'w',
	      -width => 70,
	    )->pack(-expand => 1, -fill => 'x', -padx => 10 );
  $body->ProgressBar(
		   -width => 20,
		   -length => 500,
		   -anchor => 'w',
		   -from => 0,
		   -to => 1,
		   -resolution => 0.001,
		   -blocks=>0,
		   -relief=>'sunken',
		   -troughcolor=>'white',
		   -variable => \$progress,
		   -colors=>[
			     map {
			       $_/100,
				 sprintf('#%02x%02x%02x',200-2*$_,200-2*$_,255-$_);
			     } 0..100,
			    ],
		  )->pack(-expand => 1, -fill => 'x',-padx => 10, -pady => 10);
  $Log = $body->Scrolled('ROText',
			 -scrollbars=>'osoe',
			 -foreground=>'black',
			 -background=>'white',
			 -relief=>'sunken',
 			 -height=>15,
			 )->pack(-fill=>'x',-expand=>'yes',-padx=>10,-pady=>10);
  #$Log->focus;
}
# {
# my $p_install_tred =$nb->add("install_tred",-label => "Install TrEd", state => 'disabled');
# $p_install_tred->Button(-text=>' < Back ', -command =>[\&prev_page,'install_tred'])->pack(-side => 'left',-padx=>15,-pady=>15);
# $p_install_tred->Button(-text=>' Next > ', -command =>[\&next_page,'install_tred'])->pack(-side => 'right',-padx=>15,-pady=>15)->focus;
# }
# {
#   my $name = "finish";
#   my $page = $nb->add($name,-label => "End", -state => 'disabled');
#   my $body = $page->Frame->pack(qw(-expand yes -fill both));
#   my $bf = $page->Frame->pack(qw(-fill x -padx 10 -pady 10 -side bottom));
#   $bf->Button(-text=>'Finish', -command => sub { $mw->destroy; exit; } )->pack(-side => 'right',-padx=>15,-pady=>15)->focus;
# }

MainLoop;
exit;

sub Slurp {
  my $fn = shift;
  local $/;
  open my $fh, '<:utf8', $fn || return;
  my $ret = <$fh>;
  close $fh;
  return $ret;
}
sub Log {
  my $log=join "\n", @_;
  $Log->Insert($log);
  print STDERR $log;
  $mw->update;
}

sub status_message {
  my ($s,$depth)=@_;
  Log($s);
  $s=~s/^\s+|\s+$//g;
  $s=~s/\n/ /g;
  if ($s =~ /^(done|failed)$/) {
    $s = $depth==0 ? $status.$s : $status2.$s;
  }
  if ($depth==0) {
    $status = $s;
    $status2 = '';
  } else {
    $status2 = $s;
  }
  $mw->update;
}

sub Fail {
  $mw->messageBox(
		  -title => 'Error',
		  -icon => 'error',
		  -message => join("\n", "Installation failed",@_)
		 );
  $mw->destroy;
  exit;
}


sub Install_PPM_Modules {
  my $ppm = ActivePerl::PPM::Client->new;
  return unless $install_packages;
  my $package_dir = File::Spec->catfile($install_base,'packages58_win32');
  Log("Installing required Perl modules\n");
  # current status of all repositories
  my %repo_state = map { $_ => $ppm->repo($_)->{enabled} } $ppm->repos;
  my $tmp_repo = 'tred_install';
  my $i;
  while (exists $repo_state{$tmp_repo}) {
    $tmp_repo.='tred_install_'.($i++);
  }
  # disable all repositories
  {
    my @repos=$ppm->repos;
    my $activity=ppm_status('begin',"Configuring PPM repositories");
    for my $i (0..$#repos) {
      $activity->tick(($i+1)/@repos);
      $ppm->repo_enable($repos[$i],0);
    }
    $activity->end;
  }
  # add our local repository
  my $my_repo;
  {
    my $activity=ppm_status('begin',"Adding installation repository '$tmp_repo'");
    require URI::file;
    $my_repo = eval {
      $ppm->repo_add(
		     name => $tmp_repo,
		     packlist_uri => URI::file->new_abs($package_dir),
		    );
    };
    if ($@) {
      Log("\nERROR: ",$@,"\n");
      $activity->end('failed');
      Fail();
    } else {
      $activity->end();
    }
  }
  my $fail;
  eval {
    Log("Reading package list...");
    my @features = do {{
      open my $list,'<', File::Spec->catfile($package_dir,'packages_list');
      <$list>
    }};
    Log("done.\n");
    chomp @features;
    my @packages = $ppm->packages_missing( want => [map { [$_ => undef] } @features] );
    if (@packages) {
      my $what = @packages > 1 ? (@packages . " packages") : "package";
      my $activity = ppm_status("begin", "Installing PPM $what");
      eval {
	$ppm->install(packages => \@packages ); # force => 1 
      };
      if ($@) {
	Log("\nERROR:",$@,"\n");
	$activity->end('fail');
	$fail=1;
      } else {
	$activity->end;
      }
    } else {
      Log("No packages to install.\n");
    }
  };
  if ($@) {
    Log("\nERROR:",$@,"\n");
    $fail=1;
  }
  {
    my $activity = ppm_status('begin',"Removing temporary repository '$tmp_repo'");
    eval {
      $ppm->repo_delete($my_repo);
    };
    if ($@) {
      Log("\nERROR:",$@,"\n");
      $activity->end('fail');
    } else {
      $activity->end();
    }
  }
  #Log("Syncin repositories");
  #$ppm->repo_sync;
  {
    my @repos = grep {$repo_state{$_}} keys %repo_state;
    my $activity = ppm_status('begin',"Restoring saved PPM configuration");
    for my $i (0..$#repos) {
      my $repo = $repos[$i];
      $activity->tick(($i+1)/@repos);
      $ppm->repo_enable($repo,$repo_state{$repo});
    }
    $activity->end;
  }
  Fail() if $fail;
}

sub Install_TrEd {
  copy_tree($mw, $install_tred_path => $install_target,
	    "Copying TrEd files");
  if (-f 'tred.mac') {
    copy_tree($mw, File::Spec->rel2abs('tred.mac',$install_base) => File::Spec->catfile($install_target,'tredlib'),
	      "Copying custom TrEd macros");
  }
  if (-d 'resources') {
    copy_tree($mw, File::Spec->rel2abs('resources',$install_base) => File::Spec->catfile($install_target,'resources'),
	      "Copying TrEd resources");
  }
  if (-d 'sample_data') {
    copy_tree($mw, File::Spec->rel2abs('sample_data',$install_base) => File::Spec->catfile($install_target,'sample_data'),
	      "Copying TrEd sample data");
  }
  if (-d "${install_target}/bin" || mkdir("${install_target}/bin")) {
    copy_tree($mw, File::Spec->rel2abs('nsgmls',$install_base) => File::Spec->catfile($install_target,'bin'),
	      "Copying utilities");
    copy_tree($mw, File::Spec->rel2abs('bin/prfile32.exe',$install_base) => File::Spec->catfile($install_target,'bin'),
	      "Copying utilities");
  }
  my @pl2bat = qw(tred btred trprint any2any);
  {
    my $activity = ppm_status('begin',"Creating BAT files");
    for my $i (0..$#pl2bat) {
      Pl2Bat(File::Spec->catfile($install_target,$pl2bat[$i]));
      $activity->tick(($i+1)/@pl2bat);
    }
  }
  {
    my $activity = ppm_status('begin','Creating registry entries');
    for my $loc (qw(LMachine CUser)) {
      eval {
	$Registry->{"$loc/Software/"}->{"TrEd/"}= {
			    "/Dir" => $install_target,
			   };
      };
      if ($@) {
	$activity->end("failed");
	Log("$@\n$^E\n");
      }
    }
  }
  if ($mk_data_folder) {
    my $activity = ppm_status('begin','Creating data folder');
    unless( mkdir($data_folder) ) {
      $activity->end("failed");
      Log("Failed to create $data_folder: $!!\n");
    }
  }
}

sub Install {
  Install_PPM_Modules();
  Install_TrEd();
  MakeShortcuts();
}

sub MakeShortcuts {
  my $activity = ppm_status('begin','Create shortcuts');
  my @types=grep{ $create_shortcut{$_} } keys %create_shortcut;
  for my $i (0..$#types) {
    my $type=$types[$i];
    my $dir = Win32::GetFolderPath($win32_dir{$type});
    my $activity_step = ppm_status('begin',"$type");
    eval{
      if (defined($dir) and length($dir) and ! -f "$dir\\Tred.lnk") {
	my $link=Win32::Shortcut->new();
	$link->{File}="$dir\\Tred.lnk";
	$link->{Path}="$install_target\\tred.bat";
	$link->{WorkingDirectory}=($data_folder || $install_target);
	$link->{Description}="Tree Editor";
	$link->{IconLocation}="$install_target\\tredlib\\tred.ico";
	$link->{IconNumber}="0";
	$link->{ShowCmd}=SW_SHOWMINNOACTIVE;
	$link->Save();
      }
    };
    if ($@) {
      $activity_step->end('failed');
      Log("Failed to create $type shortcut:\n",$@);
    }
    $activity->tick(($i+1)/@types);
  }
  $activity->end;
}

sub Pl2Bat {
  my $file=shift;
  my $bat=$file;
  my ($base,$path,$suffix)=fileparse($file);
  die "file $file is .bat already?" if $suffix eq '.bat';
  $bat=File::Spec->catfile($path,$base.'.bat');

  my $text = <<'BAT';
@echo off
set PATH=%PATH%;_INSTALL_TARGET_\bin

if "%OS%" == "Windows_NT" goto WinNT
_PERLBIN_ _CMD_ %1 %2 %3 %4 %5 %6 %7 %8 %9
goto end
:WinNT
"_PERLBIN_" "_CMD_" %*
:end
BAT

  $text=~s/_INSTALL_TARGET_/$install_target/g;
  $text=~s/_PERLBIN_/$^X/g;
  $text=~s/_CMD_/$file/g;
  my $activity=ppm_status('begin','Creating '.$bat);
  open(my $fh, '>:crlf', $bat) || Fail("Cannot write '$bat': $!");
  print $fh $text;
  close $fh;
  $activity->end;
}

BEGIN {
  my $file_count=0;
  my $file_no=0;
  my $target_dir;
  my $source_dir;
  my $activity;
  sub count_files{ $file_count++ };
  sub do_copy_tree{
    my $source=$_;
    $source=~s{/}{\\}g;
    my $source_base = $source; $source_base=~s/^\Q$source_dir\E//;
    my $target=File::Spec->catfile($target_dir,$source_base);
    $status2=$source;
    #$target_info=$target;
    if (-f $source) {
      if (-f $target && !-w $target) {
	if ($mw->messageBox(
			    -title => "Error occurred while copying files",
			    -message=>join("\n",
					   "The target file",
					   "",
					   $target,
					   "",
					   "exists and is not writable!",
					   "",
					   "Shell I attempt to overwrite the file anyway?"),
			    -type=>'yesno') eq 'Yes') {
	  my $perm = (stat $target)[2] & 07777;
	  chmod($perm|0600, $target) || die "chmod failed on $target: $!";
	  copy($source,$target) || die "Copy $source to $target failed: $!";
	  chmod($perm,$target);
	}
      } else {
	copy($source,$target) || die "Copy $source to $target failed: $!";
      }
    } elsif (-d $source) {
      -d $target || mkdir($target) || die "mkdir failed: $! ($target)";
    }
  }
  sub copy_tree {
    my $mw=shift;
    my $desc;
    ($source_dir, $target_dir,$desc)=@_;
    {
      my $activity = ppm_status('begin','Determining files to copy');
      $file_count=0;
      find ({ wanted => \&count_files, no_chdir=>1 },$source_dir);
      $activity->tick(1);
      $activity->end;
    }
    {
      my $activity = ppm_status('begin',$desc);
      $file_no=0;
      find ({ wanted => sub {
		do_copy_tree(@_);
		$activity->tick((++$file_no)/$file_count);
		$mw->update;
	      }, no_chdir=>1 },$source_dir);
      $activity->end;
      $progress=1;
    }
    print "Copied $file_no files".($file_no<$file_count ? "of $file_count" : "\n");
  }
}


BEGIN {
    package ActivePerl::PPM::GUI::Status;

    require ActivePerl::PPM::Status;
    our @ISA = qw(ActivePerl::PPM::Status);

    my $prefixed;

    sub begin {
	my $self = shift;
	my $what = shift;
	my $depth = $self->depth;
	my $indent = ($prefixed ? "\n" : q()).("  " x $depth);
	::status_message("$indent$what ... ", $depth);
	$prefixed = 1;
	$self->SUPER::begin($what, @_);
    }

    sub tick {
	my $self = shift;
        if (@_) {
	  # update the progressbar
	  $progress = shift;
        }
	$mw->update;
    }

    sub end {
	my $self = shift;
	my $outcome = shift || "done";
	my $what = $self->SUPER::end;
	my $depth = $self->depth;
	unless ($prefixed) {
	  my $indent = "  " x $depth;
	  $outcome = "$indent$what $outcome";
	}
	::status_message("$outcome\n", $depth);
	$prefixed = 0;
	$progress = -1;
    }
}

__END__

=comment

#
# This is a TrEd and ActivePerl installer for Windows
# (intended for use with cygwin bash)
#

# usage: winsetup.sh [-l en|cz] [-p 6|8] [-t] [-r tredrc] [-f filelists-dir] [-n] [-d datadir]
# or
# winsetup.sh -h

PATH=.:`pwd`/bin:${PATH}

function debug {
  echo $@
}

INSTLANG=en
INSTPERLVER=8
TREDRC=""
DATADIR=""

while getopts "l:p:tr:hd:f:n" o; do
  case "$o" in
     l) INSTLANG="$OPTARG" ;;
     p) INSTPERLVER="$OPTARG" ;;
     t) PACKAGES58="Tk $PACKAGES58" ;;
     r) TREDRC="$OPTARG" ;;
     d) DATADIR="$OPTARG" ;;
     f) FILELISTS="$OPTARG" ;;
     n) SKIPPKGUPGRADE="1" ;;
     h) cat <<EOF ;;
usage: winsetup.sh [-l en|cz] [-p 6|8] [-t] [-r tredrc]
       -l language
       -p perl5 sub-version
       -t force Tk804 for perl 5.8
       -r use given file as the default tredrc
       -d data-dir
       -f dir - add all <dir>/*.fl as filelists
       -n skip perl package upgrade
or
       winsetup.sh -h for this help
EOF
  esac
done

shift $(( $OPTIND - 1 ))

if [ -n "$1" ]; then
  echo "Warning: unknown non-option arguments remain on the command-line:"
  echo "$@"
fi

. "winsetup_${INSTLANG}.msg" || exit 1

if [ "$INSTPERLVER" = 6 ]; then
  REQPERLVER="[68]"
  REQPERLINSTDIR=win32_perl56
  packages_ap56=packages56_win32
  PACKAGES56="$PACKAGES56 $(cat $packages_ap56/packages_list | sed s/-/::/)"
else
  packages_ap58=packages58_win32
  PACKAGES58="$PACKAGES58 $(cat $packages_ap58/packages_list | sed s/-/::/)"
  REQPERLVER="8\.[3-9]|9|1[0-9]"
  REQPERLINSTDIR=win32_perl58
fi

if [ "$OSTYPE" != "cygwin" ]; then 
  echo $MSG000
  echo $MSG001
fi

function ask {
  answer=""
  until [ "$answer" = $MSGYES -o "$answer" = $MSGNO ]; do       
    read -e -n1 -r -p "$1 [$MSGYES/$MSGNO]?" answer 
  done
  if [ "$answer" = $MSGYES ]; then
    return 0
  else
    return 1  
  fi
}

function mkplbat {
  PERLBIN=`echo "$PERLBIN" | sed 's,^/cygdrive/\(.\),\1:,' | sed -e 's,/,\\\\\\\\,g'`
  DOSTREDDIR=`echo "$TREDDIR" | sed 's,^/cygdrive/\(.\),\1:,' | sed -e 's,/,\\\\\\\\,g'`
  sed "s,_PERLBIN_,$PERLBIN,g" < bat | sed "s,_CMD_,${TREDDIR}/$1,g" | sed "s,_TREDDIR_,${DOSTREDDIR},g" > "${TREDDIR}/$1.bat"
  return $?
}

function findperlbin {
  PERLBIN=`which perl 2>/dev/null`
  if [ ! -z "$PERLBIN" ]; then
      "$PERLBIN" -v | grep -q 'MSWin32';
      if [ $? != 0 ]; then
	  PERLBIN=""
      fi
  fi
  if [ -z "$PERLBIN" ]; then
    PERLBIN=`regtool get '\machine\Software\Perl\BinDir' 2>/dev/null`"/perl.exe"
    if [ ! -x "$PERLBIN" ]; then
      for d in c d e f g; do 
        if [ -x "${d}:/perl/bin/perl.exe" ]; then
          PERLBIN="${d}:/perl/bin/perl.exe"
	  return 0
        fi
      done
    fi
  fi
}

function dosdirname {
  dirname="$1"
  dosdirname="${dirname#/cygdrive/}"
  if [ "$dirname" != "$dosdirname" ]; then
    dosdirname="${dosdirname/\//:/}"
  fi
  echo "$dosdirname"
}

function cygdirname {
  dirname="${1//\\\\//}"
  if ! echo "$dirname" | grep -q '^/cygdrive/'; then
    cygdirname="/cygdrive/${dirname}";
    cygdirname="${cygdirname/://}"
  else
    cygdirname="$dirname";
  fi
  echo "$cygdirname"
}



function findtreddir {
    TREDDIR=`regtool get '\machine\Software\TrEd\Dir' 2>/dev/null`
    INSTTRED=`dosdirname ${PWD}/tred`
    if [ ! -f "${TREDDIR}/tred" ]; then
      for d in c d e f g; do 
        if [ -f "${d}:/tred/tred" -a ! "${d}:/tred" -ef "$INSTTRED" ]; then
          TREDDIR="${d}:/tred"
          return 0
        fi
      done
    fi
}

function perl_version_current {
  INSTVER=`"$PERLBIN" --version | grep "This is perl,"`
  if "$PERLBIN" --version | grep -E 'This is perl, v5\.'"(${REQPERLVER})"; then
    return 0
  else 
    return 1
  fi
}

function test_version {
  return `$PERLBIN -e "print ($1 > $2) ? 1 : 0"`
}

function get_version {
  echo `"$PPM" $* | grep "\[[0-9.]*\]" | sed 's/^.*\[\([0-9.]*\).*$\]/\1/g'`
}

function upgrade_packages {
  if "$PERLBIN" --version | grep -q 'This is perl.* v5\.6'; then
      for s in $PACKAGES56; do 
	echo
	echo $MSG002 $s
	QUERY=`"$PPM" query "^$s\$"`
	if [ -n "$QUERY" ]; then
	  "$PPM" verify --location="$packages_ap56" --upgrade "$s"
	else
	  install_packages "$s"
	  echo
	fi
      done
  else
      echo $MSG003
      "$PPM" rep del tredsetup 2>/dev/null >/dev/null
      "$PPM" rep
      REPS="$("$PPM" rep | grep -E '^\[[0-9]+\]')"
      REPS=`echo "$REPS" | sed 's/^\[[0-9]*\] *//'`
      OLDIFS="$IFS";
      IFS=$'\n\t\n';
      for rep in $REPS; do
	  IFS="$OLDIFS";
	  "$PPM" rep off $rep 2>/dev/null >/dev/null
      done
      IFS="$OLDIFS";
      "$PPM" rep add tredsetup "$packages_ap58" 2>/dev/null >/dev/null
      "$PPM" rep
      echo $MSGDONE
      for s in $PACKAGES58; do 
	echo
        echo "$MSG004 $s"
	ppd="${s//::/-}";
	if ! "$PPM" install "$ppd" 2>/dev/null >/dev/null; then
          "$PPM" upgrade -install -precious "$ppd"
        fi
      done
      echo $MSG005
      "$PPM" rep del tredsetup 2>/dev/null >/dev/null
      OLDIFS="$IFS";
      IFS=$'\n\t\n';
      for rep in $REPS; do
           IFS="$OLDIFS";
           "$PPM" rep on "$rep" 2>/dev/null >/dev/null
      done
      "$PPM" rep
      IFS="$OLDIFS";
      echo $MSGDONE
  fi
}

function install_packages {
  "$PPM" install --location="$packages_ap58" $*
}

function upgrade_perl {
  PERLINSTALLDIR="${PERLDIR%/BIN}"
  PERLINSTALLDIR="${PERLINSTALLDIR%/bin}"
  if ask "$MSG007 $PERLINSTALLDIR?"; then
      "$PERLBIN" uninst_p500.pl "$DOSPERLDIR/p_uninst.dat" >/dev/null 2>/dev/null
      echo
      echo "$MSG006 $PERLINSTALLDIR"
      read -e -n1 -r -p "$MSG008"
      echo "$MSG009 $PERLINSTALLDIR..."
      rm -rf "$PERLINSTALLDIR"
      echo $MSGDONE
  else
      echo $MSG010
      read -e -n1 -r -p "$MSG011"
      exit 1;
  fi
  echo 
  echo $MSG012
  install_perl
}

function get_perl_install_dir {
  read -e -r -p "$MSG036 c:/perl]: " PERLINSTALLDIR
  if [ -z "$PERLINSTALLDIR" ]; then
    PERLINSTALLDIR="c:/perl"
  fi
}

function fail_install_perl {
  DIR="$PWD"
  if [ ! -f "$DIR/$REQPERLINSTDIR/"perl*.tgz ]; then
      echo "-------------------------------------------------------------------------------"
      echo
      echo "Due to licensing issues we cannot distribute ActivePerl 5.8 together with"
      echo "this setup. Please download and install ActivePerl 5.8 for Windows from:"
      echo
      echo "http://www.activestate.com/Products/Download/Download.plex?id=ActivePerl"
      echo "It is free of charge."
      echo
      echo "When finished, run setup.bat again."
      echo
      echo "Thank you!";
      exit 1;
  fi
}

function install_perl {
  DIR="$PWD"
  fail_install_perl
  test -d "$PERLINSTALLDIR" || mkdir "$PERLINSTALLDIR"
  echo "$MSG013" "$DIR/$REQPERLINSTDIR"/perl*.tgz
  (cd "$PERLINSTALLDIR" &&\
  tar -xzf "$DIR/$REQPERLINSTDIR/"perl*.tgz &&\
  sed "s,c:\\Perl,$PERLINSTALLDIR," < "$PERLINSTALLDIR/install.bat" > "$PERLINSTALLDIR/install2.bat" &&\
  echo "$MSG014"
  "$PERLINSTALLDIR/install2.bat") || \
  (echo; echo "$MSG015"; exit 1)
}

echo
echo "-------------------------------------------------------------------------------"
echo
echo "$MSG016"
ask "$MSG017" || exit 127

echo
findperlbin
until [ -n "$PERLBIN" -a  -f "$PERLBIN" -a -x "$PERLBIN" ] && ask "$MSG018 $(dosdirname "$PERLBIN") $MSG046"; do
  echo "$MSG019"
  echo "$MSG020"
  echo "$MSG021"
  echo
  if ask "$MSG022"; then
    fail_install_perl
    # ok, we do provide a perl installation here
    get_perl_install_dir
    install_perl
#    findperlbin
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else  
    read -e -r -p "$MSG023" PERLBIN
    PERLBIN="${PERLBIN//\\\\//}"
  fi
done


PERLDIR=`dirname "$PERLBIN" 2>/dev/null`
DOSPERLDIR=`dosdirname "$PERLDIR"`
CYGPERLDIR=`cygdirname "$PERLDIR"`
export PATH="$CYGPERLDIR:$PATH"
PPM="$CYGPERLDIR/ppm.bat" #$DOSPERLDIR/ppm.bat


echo "$MSG024"

if perl_version_current; then
  echo "$MSGOK"
else 
  echo
  echo "$MSG025 5.${REQPERLVER}"
  if ask "$MSG026"; then
    upgrade_perl
    PERLBIN="$PERLINSTALLDIR/bin/perl.exe"
  else
    if ask "$MSG027"; then
     echo 
     echo "$MSG028"
     echo "$MSG029"
    else 
     exit 1
    fi
  fi
fi

if [ -z "$SKIPPKGUPGRADE" ]; then
  upgrade_packages
fi

findtreddir

if [ -n "$TREDDIR" -a  -x "$TREDDIR/tred" ]; then
  echo
  echo "$MSG030 $TREDDIR"
  if ask "$MSG031"; then
    UPGRADE=1
    if ask "$MSG032"; then
      test -f "$TREDDIR/tredlib/tredrc" && \
	( attrib -R "${TREDDIR}/tredlib/tredrc";
	  mv "$TREDDIR/tredlib/tredrc" "$TREDDIR/tredlib/tredrc.sav")
    else
      rm -f "$TREDDIR/tredlib/tredrc.sav"
    fi  
  else
    echo
    ask "$MSG033" || exit 127
    if [ "$OSTYPE" = "cygwin" ]; then
      TREDDIR="c:/tred"
    else 
      TREDDIR="$HOME/tred"
    fi    
    read -e -r -p "$MSG034 $TREDDIR]: " DIR
    test -z "$DIR" || TREDDIR="${DIR//\\\\//}"
  fi
else 
  echo
  ask "$MSG035" || exit 127
  if [ "$OSTYPE" = "cygwin" ]; then
    TREDDIR="c:/tred"
  else 
    TREDDIR="$HOME/tred"
  fi    
  read -e -r -p "$MSG036 $TREDDIR]: " DIR
  test -z "$DIR" || TREDDIR="${DIR//\\\\//}"
fi

attrib -R "${TREDDIR}/tredlib/tredrc" >/dev/null 2>/dev/null
if ((test -d "${TREDDIR}" || mkdir "${TREDDIR}") && \
    cp -R tred/* "${TREDDIR}"             && \
    ([ ! -f tred.mac ] || cp tred.mac "${TREDDIR}/tredlib")  && \
    ([ ! -d resources ] || \
       ([ -d "${TREDDIR}/resources" ] || mkdir "${TREDDIR}/resources";\
        cp -R resources/* "${TREDDIR}/resources"))  && \
    ([ "$SAVED_TREDRC" = 1  -o "$TREDRC" = "" -o ! -f "$TREDRC" ] || \
     (echo "$MSG044 $TREDRC $MSG045"; cp "$TREDRC" "${TREDDIR}/tredlib/tredrc"))  && \
    mkplbat tred                          && \
    mkplbat btred                         && \
    mkplbat trprint                       && \
    mkplbat any2any); then 
    
    if (test -d "${TREDDIR}/bin" || mkdir "${TREDDIR}/bin"); then
      cp -f bin/prfile32.exe nsgmls/* bin/prfile32.exe bin/*.dll bin/gunzip.exe bin/gzip.exe bin/zcat.exe "${TREDDIR}/bin"
    else 
      echo "$MSG039 ${TREDDIR}/bin !"
    fi
    [ "$SAVED_TREDRC" = 1 ] && \
      mv "${TREDDIR}/tredlib/tredrc.sav" "${TREDDIR}/tredlib/tredrc";

    if [ -n "${FILELISTS}" -a -d "${FILELISTS}" ]; then
      if ! grep '^\s*filelist[0-9]*\s*=' "${TREDDIR}/tredlib/tredrc"; then
        attrib -R "${TREDDIR}/tredlib/tredrc"
        # pridej filelisty
        i=0
        for s in "${FILELISTS}"/*.fl; do
	  echo >> "${TREDDIR}/tredlib/tredrc"
          echo "filelist${i}=\"${s//\\\\//}\"" >> "${TREDDIR}/tredlib/tredrc"
          i=$((i+1))
        done
      fi
    fi
    
    test "x$UPGRADE" != "x1" && "$PERLBIN" trinstall.pl "$INSTLANG" "${TREDDIR}" "${DATADIR}"

    # change tredrc to read-only so that users have to create
    # their own copy
    attrib +R "${TREDDIR}/tredlib/tredrc"

    echo "$MSG038"
    ((regtool add "\\machine\\Software\\TrEd" && regtool -s set "\\machine\\Software\\TrEd\\Dir" "$TREDDIR" ) ||
     (regtool add "\\user\\Software\\TrEd" && regtool -s set "\\user\\Software\\TrEd\\Dir" "$TREDDIR" )) >/dev/null 2>/dev/null;

=cut
