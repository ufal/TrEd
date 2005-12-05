#!/usr/bin/perl
# -*- cperl -*-

use encoding 'iso-8859-2';

$language = $ARGV[0] || 'cz';

$treddir = $ARGV[1] || "c:\\tred";
$treddir =~ s{/}{\\}g;
$treddir =~ s{\\$}{};
$defaultvalue =  "C:\\tred_data";


if ($ARGV[2]) {
  $datadir= $ARGV[2];
} else {
  $datadir=$defaultvalue;
  %lang = (
    cz => {
      'dir' => "Vyber adresáø pro data:",
      'cantopen' => "nelze otevøít",
      'ok' => 'Ok',
      'cancel' => 'Zru¹it',
      'direxists1' => "Adresáø ",
      'direxists2' => " neexistuje. Vytvoøit?",
      'enterdatadir' => "Zadejte adresáø pro datové sobory:",
      'dektopregfail' => "Nelze zjistit adresáø plochy!",
      'inst' => 'Instalace'
     },
    en => {
      'dir' => "Choose data folder:",
      'cantopen' => "Can't open",
      'ok' => 'Ok',
      'cancel' => 'Cancel',
      'direxists1' => "Directory ",
      'direxists2' => " doesn't exist. Create?",
      'enterdatadir' => "Enter data folder:",
      'dektopregfail' => "Can't determine Desktop folder!",
      'inst' => 'Installation'
     }
   );
  use Tk;
  use Tk::DirTree;

  my $top = MainWindow->new();
  sub getDir {
    my ($top,$curr_dir)=@_;
    my $t = $top->Toplevel;
    $t->title($lang{$language}{dir});
    $ok = 0;		    # flag: "1" means OK, "-1" means cancelled

    # Create Frame widget before the DirTree widget, so it's always visible
    # if the window gets resized.
    my $f = $t->Frame->pack(-fill => "x", -side => "bottom");

    my $d;
    my $inidir="/";
    my $inidir="$1\\" if $curr_dir=~/^([A-Z]:)/i;

    $d = $t->Scrolled('DirTree',
		      -scrollbars => 'osoe',
		      -width => 40,
		      -height => 40,
		      -selectmode => 'browse',
		      -exportselection => 1,
		      -directory => $inidir,
		      -dircmd => sub {
			my( $some_dir, $showhidden ) = @_;
			my $sdir=($some_dir=~/^[A-Z]:$/i) ? "$some_dir/" : $some_dir;
			@dots=();
			eval { 
			  opendir(DIR, $sdir) || die $lang{$language}{cantopen}." $some_dir: $!"; 
			  @dots=grep { -d "$some_dir/$_" } readdir(DIR);
			  closedir DIR;
			};
			return @dots;
		      },
		      -browsecmd => sub { $curr_dir = shift },

		      # With this version of -command a double-click will
		      # select the directory
		      -command   => sub { $ok = 1 },

		      # With this version of -command a double-click will
		      # open a directory. Selection is only possible with
		      # the Ok button.
		      #-command   => sub { $d->opencmd($_[0]) },
		     )->pack(-fill => "both", -expand => 1);
    # Set the initial directory
    $d->chdir($curr_dir) if (-d $curr_dir);
    $f->Button(-text => $lang{$language}{ok},
	       -command => sub { $ok =  1 })->pack(-side => 'left');
    $f->Button(-text => $lang{$language}{cancel},
	       -command => sub { $ok = -1 })->pack(-side => 'left');

    # You probably want to set a grab. See the Tk::FBox source code for
    # more information (search for grabCurrent, waitVariable and
    # grabRelease).
    # Set a grab and claim the focus too.
    my $oldFocus = $t->focusCurrent;
    my $oldGrab = $t->grabCurrent;
    my $grabStatus = $oldGrab->grabStatus if ($oldGrab);
    $t->grab;

    $t->waitVariable(\$ok);
    eval {
      $oldFocus->focus if $oldFocus;
    };
    if (Tk::Exists($t)) {	# widget still exists
      $t->grabRelease;
      $t->withdraw;
    }
    if ($oldGrab) {
      if ($grabStatus eq 'global') {
	$oldGrab->grabGlobal;
      } else {
	$oldGrab->grab;
      }
    }
    if ($ok == 1) {
      print "$curr_dir\n";
      return $curr_dir;
    } else {
      return undef;
    }
  }

  $f=$top->Frame();
  $e=$f->Entry(-relief => 'sunken',
	       -width => 40,
	       -takefocus => 1,
	       -background => "white",
	       -textvariable => \$datadir);

  $l = $f->Label(-text => $lang{$language}{enterdatadir},
		 -anchor => 'e',
		 -justify => 'right');
  $l->pack(-side=>'top');
  $e->pack(-side=>'left',-expand=>1,-fill=>'x');
  #$top->resizable(0,0);
  $dots=$f->Button(-text => '...',
		   -command => [ sub {
				   my $dir=getDir($top,$datadir);
				   $datadir=$dir if (-d $dir);
				 }])->pack(-padx=>'0.2c',-side=>'left');

  $f->pack(-side=>'top',
	   -expand=>1,
	   -fill=>'both',-anchor => n);


  $top->Button(-text => $lang{$language}{ok},
	       -command => [ sub {
			       return unless (defined($datadir) and $datadir ne "");
			       unless (-d $datadir) {
				 mkdir $datadir,775 if 
				   $top->messageBox(-message => 
						      $lang{$language}{direxists1}.$datadir.
							$lang{$language}{direxists2},
						    -title => $lang{$language}{inst}, -type => 'YesNo')
				     =~/^yes|ano$/i;
			       }
			       $top->destroy();
			     }])->pack(-padx=>'0.2c',-pady=>'0.2c',-side=>'left',-expand =>1);

  $top->Button(-text => $lang{$language}{cancel},
	       -command => [ sub {
			       $datadir=undef;
			       $top->destroy();
			     }])->pack(-padx=>'0.2c',-pady=>'0.2c',-side=>'left',-expand=>1);
  $e->focus();

  MainLoop;

}
if ($^O eq "MSWin32") {

  require Win32::Registry;
  require Win32::Shortcut;

  my @dirs;
  my $shell_folders = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
  eval {
    my $ShellFolders;
    my %shf;
    if ($::HKEY_CURRENT_USER->Open($shell_folders,$ShellFolders)) {
      $ShellFolders->GetValues(\%shf);
      push @dirs,$shf{Desktop}[2];
    } else {
      die $lang{$language}{dektopregfail}." $^E\n";
    }
  };
  print STDERR $@ if $@;
  eval {
    my $ShellFolders;
    my %shf;
    if ($::HKEY_LOCAL_MACHINE->Open($shell_folders,$ShellFolders)) {
      $ShellFolders->GetValues(\%shf);
      push @dirs,$shf{'Common Programs'}[2];
    } else {
      die $lang{$language}{dektopregfail}." $^E\n";
    }
  };
  print STDERR $@ if $@;
  if ($@) {
    # can't add to startup menu of all users, try adding for the current user only
    eval {
      my $ShellFolders;
      my %shf;
      if ($::HKEY_CURRENT_USER->Open($shell_folders,$ShellFolders)) {
	$ShellFolders->GetValues(\%shf);
	push @dirs,$shf{'Programs'}[2];
      } else {
	die $lang{$language}{dektopregfail}." $^E\n";
      }
    };
    print STDERR $@ if $@;
  }
  eval{
    for my $dir (@dirs) {
      unless ($dir eq "" or -f "$dir\\Tred.lnk") {
	$link=Win32::Shortcut->new();
	$link->{File}="$dir\\Tred.lnk";
	$link->{Path}="$treddir\\tred.bat";
	$link->{WorkingDirectory}=$datadir;
	$link->{Description}="Tree Editor";
	$link->{IconLocation}="$treddir\\tredlib\\tred.ico";
	$link->{IconNumber}="0";
	$link->{ShowCmd}=SW_SHOWMINNOACTIVE;
	$link->Save();
      }
    }
  };
}
