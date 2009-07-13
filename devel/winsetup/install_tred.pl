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
require Tk::Photo;
require Tk::JPEG;
require Tk::PNG;

use File::Spec;
use File::Basename;
use File::Find;
use File::Copy;

use FindBin;

use Win32 qw(CSIDL_DESKTOP CSIDL_PROGRAMS CSIDL_COMMON_PROGRAMS);
use Win32::Shortcut;
use Win32::TieRegistry (Delimiter=>'/');

our @obsolete_files = qw(
  resources/tree_query_schema.xml
);

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

my $upgrade = 0;
my $install_base=File::Spec->rel2abs($FindBin::RealBin.'../../../..');
chdir $install_base;

my $package_dir_58 = File::Spec->catdir($install_base,'packages58_win32');
my $package_dir_510 = File::Spec->catdir($install_base,'packages510_win32');
my $package_dir = $] >= 5.010 ? $package_dir_510 : $package_dir_58;
my $package_xml = File::Spec->catfile($package_dir,'package.xml');
my $install_packages = 1;
my $install_tred_path= File::Spec->catfile($install_base,'tred');
my $install_target = 'c:\tred';
my $data_folder = 'c:\tred_data';
my $icon = File::Spec->rel2abs('tred/tredlib/tred.xpm',$install_base);
my $license_file = File::Spec->rel2abs('tred/LICENSE',$install_base);
my $extensions_repo = File::Spec->rel2abs('extensions',$install_base);

my $mk_data_folder = 1;
my ($status,$status2,$progress); # watched text variables
my $Log; # text widget

{
  no warnings;
  require Tk::DialogBox;
  {
    my $old=\&Tk::Widget::DialogBox;
    *Tk::Widget::DialogBox = sub {
      my $d = &$old;
      if ($d) {
	for my $w ( grep $_->isa('Tk::Button'), $d->Subwidget ) {
	  $w->configure(-padx=>7, -pady=>2, -width=>0);
	}
      }
      return $d;
    };
  }
  require Tk::Dialog;
  {
    my $old=\&Tk::Widget::Dialog;
    *Tk::Widget::Dialog = sub {
      my $d = &$old;
      if ($d) {
	for my $w ( grep $_->isa('Tk::Button'), $d->Subwidget ) {
	  $w->configure(-padx=>7, -pady=>2, -width=>0);
	}
      }
      return $d;
    };
  }
}

sub InstallExtensions {
  my ($d,$pane,$progress,$progressbar)=@_;

  push @INC,
  map File::Spec->rel2abs($_,$install_target),
  qw(tredlib tredlib/libs/tk tredlib/libs/pml-base tredlib/libs/fslib);

  require Fslib;
  require TrEd::Extensions;

  require TrEd::Utils;
  TrEd::Utils::find_win_home();

  require TrEd::Config;
  TrEd::Config::set_default_config_file_search_list();
  TrEd::Config::read_config();
#  print $TrEd::Config::extensionsDir,"\n";
  Fslib::AddResourcePath(File::Spec->rel2abs('resources',$install_target));

  my $list = TrEd::Extensions::getExtensionList() || [];
  if ($progressbar) {
    $progressbar->configure(
      -to => scalar(@$list),
      -blocks => scalar(@$list),
     );
  }
  my %versions;
  for my $name (@$list) {
    $name=~s/^!//;
    my $data = TrEd::Extensions::getExtensionMetaData($name);
    $$progress++ if $progress;
    $progressbar->update if $progressbar;
    $versions{$name}=$data->{version} if $data;
  }
  my $enable = TrEd::Extensions::_populate_extension_pane({top=>$d},
							  $d,
							  {
							    pane => $pane,
							    install=>1,
							    progress=>$progress,
							    progressbar=>$progressbar,
							    installed => \%versions,
							    repositories => [$extensions_repo],
							  });
}

sub icon {
  my ($t,$name)=@_;
  my $file = File::Spec->rel2abs('tred/tredlib/icons/crystal/'.$name.'.png',$install_base);
  $t->{top}->Photo(-file => $file,-format=>'png');
}

my $mw=Tk::MainWindow->new(-title=>'TrEd Setup Wizard');
$mw->optionAdd("*font","{Sans} 9");
$mw->fontCreate(qw/C_small -family sans -size 7/);
$mw->fontCreate(qw/C_small_bold -family sans -weight bold -size 7/);
$mw->fontCreate(qw/C_heading -family sans -weight bold -size 11/);
$mw->fontCreate(qw/C_fixed   -family courier   -size 9/);
$mw->fontCreate(qw/C_default -family sans -size 9/);
$mw->fontCreate(qw/C_bold    -family sans -size 9 -weight bold/);
$mw->fontCreate(qw/C_italic  -family sans -size 9 -slant italic/);

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
	   -text=>'Copyright (c) 2000-2009 by Petr Pajas',
	  )->pack(qw(-expand yes -fill x -padx 10));
$tf->Frame(-height => 10)->pack();
$mw->Frame(-relief=>'sunken',-border=>1,
	   -height => 2)->pack(-expand=>'yes',-fill => 'x');
$mw->Frame(-height => 10)->pack();
#$mw->Frame(qw(-height 3 -relief sunken))->pack(qw(-expand yes -fill x -padx 5 -pady 10));
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
  $license->Insert( Slurp($license_file) || Fail("Couldnot open LICENSE file\n") );
  $license->see('0.0');

  my $bf = $page->Frame->pack(qw(-expand yes -fill x -padx 10 -pady 10 -side bottom));
  $bf->Button(-text=>'Decline',
		-command =>
		sub {
		  if ($mw->messageBox(-title => 'Question',
				      -message => 'Abort the installation?',
				      -type=>'yesno',
				     ) eq 'Yes') {
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
my $finish_b;
{
  my $name = "installation";
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
  if (-d $extensions_repo) {
    $finish_b=$bf->Button(-text=>' Continue > ',
			  -state=>'disabled',
			  -command => [\&next_page,$name])->pack(-side => 'right',-padx=>15,-pady=>15);
  } else {
    $finish_b = $bf->Button(-text=>' Finish ',
			    -state=>'disabled',
			    -command => sub { $mw->destroy; exit },
			   )->pack(-side => 'right',-padx=>15,-pady=>15);
  }

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
		     -troughcolor=>'white',
		     -relief => 'sunken',
		     -border=>1,
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
}
my $finish_b2;
if (-d $extensions_repo) {
  my $name = "extensions";
  my ($progress, $progressbar, $pane);
  my $enable;
  my $page = $nb->add($name,
		      -label => "Install Extensions",
		      -state => 'disabled',
		      -raisecmd => sub {
			$status="Creating extension list:";
			$status2="";
			$enable = InstallExtensions($nb,$pane,\$progress,$progressbar);
			$status="Install extensions";
			$status2="Please select extensions to install/upgrade";
			$finish_b2->configure(-state => 'normal');
			$pane->focusForce;
#			$status="Installation complete!";
#			$status2="";
			$progress=0;
		      }
		     );
  my $body = $page->Frame()->pack(qw(-expand yes -fill both));
  $body->Label( -textvariable => \$status,
	      -font=>'system',
	      -width => 60,
	      -anchor => 'w',
	    )->pack(-expand => 1, -fill => 'x', -padx => 10);
  $body->Label( -textvariable => \$status2,
	      -anchor => 'w',
	      -width => 70,
	    )->pack(-expand => 1, -fill => 'x', -padx => 10 );
  $progressbar = $body->ProgressBar(
		     -width => 20,
		     -length => 500,
		     -anchor => 'w',
		     -from => 0,
		     -to => 1,
		     -resolution => 0.001,
		     -blocks=>0,
		     -troughcolor=>'white',
		     -relief => 'sunken',
		     -border=>1,
		     -variable => \$progress,
 		     -colors=>[0,'darkblue'],
# 			       map {
# 				 $_/100,
# 				   sprintf('#%02x%02x%02x',200-2*$_,200-2*$_,255-$_);
# 			       } 0..100,
# 			      ],
		    )->pack(-expand => 1, -fill => 'x',-padx => 10, -pady => 10);

  $pane = $body->Scrolled('ROText',
			  -scrollbars=>'oe',
			  -takefocus=>0,
			  -relief=>'flat',
			  -wrap=>'word',
			  -width=>60,
			  -height=>20,
			  -background => 'white',
			 )->pack(-fill=>'x',-expand=>'yes',-padx=>10,-pady=>10);

  my $bf = $page->Frame()->pack(qw(-fill x -padx 10 -pady 10 -side bottom));
  #$bf->Button(-text=>' Abort ', -command => [\&prev_page,$name])->pack(-side => 'left',-padx=>15,-pady=>15);

  $bf->Button(-text=>' Skip Extensions and Finish ', -state=>'normal',
	      -command => sub { $mw->destroy; exit  }
	     )->pack(-side => 'right',-padx=>15,-pady=>15);

  $finish_b2 = $bf->Button(-text=>' Install Extensions and Finish ', -state=>'disabled',
			  -command => sub {
			    my @selected = grep $enable->{$_}, keys %$enable;
			    if (@selected) {
			      $progressbar->configure(
				-to => scalar(@selected),
				-blocks => scalar(@selected),
			       );
			      $mw->Busy(-recurse=>1);
			      eval {
				TrEd::Extensions::installExtensions(\@selected,{
				  tk => $body,
				  progress=>\$progress,
				  # quiet=>$opts->{only_upgrades},
				});
			      };
			    }
			    $mw->ErrorReport(
			      -title   => "Installation error",
			      -message => "The following error occurred during package installation:",
			      -body    => "$@",
			      -buttons => [qw(OK)],
			     ) if $@;
			    $mw->Unbusy;
			    $mw->destroy; exit 
			  },
			  )->pack(-side => 'right',-padx=>15,-pady=>15);

}

MainLoop;
exit;

sub Slurp {
  my $fn = shift;
  local $/;
  print $fn,"\n";
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
  if ($finish_b) {
    $finish_b->configure(-state => 'normal');
    die;
  } else {
    $mw->destroy;
    exit;
  }
}

sub _better_than {
  my ($pkg1,$pkg2)=@_;
  return 0 unless $pkg1 and $pkg2;
  my @v1=split /\./,$pkg1->version;
  my @v2=split /\./,$pkg2->version;
  while (@v1 or @v2) {
    my $v1 = shift(@v1)||0;
    my $v2 = shift(@v2)||0;
    for ($v1,$v2) { $_=0 unless /^\s*\d+\s*$/ }
    return 0 if ($v1<$v2);
    return 1 if ($v1>$v2);
  }
  return 0;
}

sub Install_PPM_Modules {
  my $ppm = ActivePerl::PPM::Client->new;
  return unless $install_packages;
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
		     packlist_uri => URI::file->new_abs($package_xml),
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
    s/^\s+|\s+$//g for @features;
    Log("done.\n");

    my @remove = grep /^!/, @features;
    @features = grep !/^!/, @features;
    for my $name (@remove) {
      $name=~s/^!//;
      for my $area_name ($ppm->areas) {
	my $area = $ppm->area($area_name);
	my $pkg = $area->package($name);
	if ($pkg) {
	  Log("Uninstalling $name\n");
	  $pkg->run_script("uninstall", $area, undef, {
		    old_version => $pkg->{version},
		    packlist => $area->package_packlist($pkg->{id}),
		});
	  $area->uninstall($name);
	}
      }
    }
    my @best= grep { defined } map { $ppm->package_best($_,0) } @features;
    for (@best) {
      Log("best ".$_->name_version."\n");
    }
    Log("Finding packages for upgrade...");
    my @packages;
    for my $best (@best) {
      for my $area_name ($ppm->areas) {
	my $area = $ppm->area($area_name);
	my $name=$best->name;
	my $pkg = $area->package($name);
	if ($pkg and
	    $pkg->name eq $name and
	    $pkg->version ne $best->version and
	    eval{ _better_than($best,$pkg) }) {
	  Log("upgrade $name\n");
	  push @packages,$best;
	} else {
	  Log("keep $name\t".$pkg->version."\n") if $pkg;
	}
      }
    }
    if (@packages) {
      my $what = @packages > 1 ? (@packages . " PPM packages") : " PPM package";
      my $activity = ppm_status("begin", "Upgrading $what");
      eval {
	$ppm->install(packages => \@packages );
      };
      if ($@) {
	Log("\nERROR:",$@,"\n");
	$activity->end('fail');
	$fail=1;
      } else {
	$activity->end;
      }
    } else {
      Log("No packages to upgrade.\n");
    }

    @packages = $ppm->packages_missing( want => [map { [$_,0] } @features] );
    for (@packages) {
      Log("pkg ".$_->name_version."\n");
    }
    if (@packages) {
      my $what = @packages > 1 ? (@packages . " PPM packages") : " PPM package";
      my $activity = ppm_status("begin", "Installing $what");
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
  my $tredrc= File::Spec->catfile($install_target,'tredlib','tredrc');
  {
    if (-f $tredrc) {
      my $activity = ppm_status('begin',"Dropping read-only permission from default tredrc");
      my $perm = ((stat $tredrc)[2] | 0600); # read-write
      chmod($perm,$tredrc);
    }
  }
  {
    my $activity = ppm_status('begin',"Removing obsolete files");
    remove_old_pm_files($mw,$install_target);
    remove_obsolete_files($mw,$install_target);
  }

  copy_tree($mw, $install_tred_path => $install_target,
	    "Copying TrEd files");
  {
    if (-f $tredrc) {
      my $activity = ppm_status('begin',"Setting read-only permission on default tredrc");
      my $perm = ((stat $tredrc)[2] & 0444); # read-only
      chmod($perm,$tredrc);
    }
  }
  if (-f 'tred.mac') {
    copy_tree($mw, File::Spec->rel2abs('tred.mac',$install_base) => File::Spec->catfile($install_target,'tredlib'),
	      "Copying custom TrEd macros");
  }
  if (-d 'resources') {
    copy_tree($mw, File::Spec->rel2abs('resources',$install_base) => File::Spec->catfile($install_target,'resources'),
	      "Copying TrEd resources");
  }
  if (-d "${install_target}/bin" || mkdir("${install_target}/bin")) {
    copy_tree($mw, File::Spec->rel2abs('tools\nsgmls',$install_base) => File::Spec->catfile($install_target,'bin'),
	      "Copying utilities");
    copy_tree($mw, File::Spec->rel2abs('tools\print\prfile32.exe',$install_base) => File::Spec->catfile($install_target,'bin'),
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
  if ($suffix eq '.bat') {
    Log("file $file is .bat already?");
    return;
  }
  $bat=File::Spec->catfile($path,$base.'.bat');

  my $text = <<'BAT';
@echo off
set PATH=%PATH%;"_INSTALL_TARGET_\bin"

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
  my $overwrite_all = undef;
  sub do_copy_tree{
    my $source=$_;
    $source=~s{/}{\\}g;
    my $source_base = $source;
    my $strip = $source_dir;
    if (-f $strip) {
      $strip=dirname($strip);
    }
    $source_base=~s/^\Q$strip\E//;
    my $target=File::Spec->catfile($target_dir,$source_base);
    $status2=$source;
    #$target_info=$target;
    if (-f $source) {
      if (-f $target && !-w $target) {
	if ((defined($overwrite_all) and $overwrite_all==1) or
	    $mw->messageBox
	    (
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
	  chmod($perm|0600, $target) || Log("chmod failed on $target: $!");
	  copy($source,$target) || Log("Copy $source to $target failed: $!");
	  chmod($perm|0600,$target);
	  Log("overwriting read-only $target\n");
	  if (!defined($overwrite_all) and $mw->messageBox(
			      -title => "Question",
			      -message=>"Overwrite all read-only files in the target folder?\n(Note: this question is asked only once.)",
			      -type=>'yesno') eq 'Yes') {
	    $overwrite_all=1;
	  } elsif(!defined($overwrite_all)) {
	    $overwrite_all=0;
	  }
	}
      } else {
	my $perm = (stat $source)[2] & 07777;
	copy($source,$target) || Log("Copy $source to $target failed: $!");
	chmod($perm|0600,$target);
      }
    } elsif (-d $source) {
      -d $target || mkdir($target) || Log("mkdir failed: $! ($target)");
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
    print STDERR "Copied $file_no files".($file_no<$file_count ? "of $file_count" : "\n");
  }
  sub remove_old_pm_files {
    my ($mw,$dir)=@_;
    my $count=0;
    $dir = File::Spec->catfile($dir,'tredlib');
    {
      my $activity = ppm_status('begin','Looking for old *.pm files');
      find({ wanted => sub {
		$count++ if m[\.pm$] and !m[/contrib/]
            }, no_chdir=>1 },$dir);
      $activity->tick(1);
      $activity->end;
    }
    {
      my $activity = ppm_status('begin',"Removing $count old *.pm files");
      my $no=0;
      find ({ wanted => sub {
		if (m[\.pm$] and !m[/contrib/]) {
		  Log("Removing $_\n");
		  unlink $_ || Log("Error: $!\n");
		  $activity->tick((++$no)/$count);
		  $mw->update;
		}
            }, no_chdir=>1 },$dir);
      $activity->end;
    }
  }
  sub remove_obsolete_files {
    my ($mw,$dir)=@_;
    my @files =
      grep { -f $_ }
      map File::Spec->catfile($dir,$_),
      @obsolete_files;
    my $count=@files;
    return unless $count;
    {
      my $activity = ppm_status('begin',"Removing $count obsolete resource file(s)");
      my $no=0;
      for my $f (@files) {
	if (-f $f) {
	  Log("Removing $f\n");
	  unlink $f || Log("Error: $!\n");
	  $activity->tick((++$no)/$count);
	  $mw->update;
	}
      }
      $activity->tick(1);
      $mw->update;
      $activity->end;
    }
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
