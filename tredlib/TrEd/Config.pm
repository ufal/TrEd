package TrEd::Config;

#
# $Id$ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use strict;
use File::Spec;
BEGIN {
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK @config_file_search_list $quiet);
  use Exporter  ();
  @ISA=qw(Exporter);
  #  use Tk; # Tk::strictMotif
  $VERSION = "0.1";
  @EXPORT = qw(@config_file_search_list $set_user_config $override_options
  $appName
  $buttonsRelief
  $menubarRelief
  $buttonBorderWidth
  $canvasBalloonInitWait
  $canvasBalloonForeground
  $canvasBalloonBackground
  $toolbarBalloonInitWait
  $toolbarBalloonForeground
  $toolbarBalloonBackground
  $activeTextColor
  $treeViewOpts
  $font
  $guiFont
  $vLineFont
  $libDir
  $extensionsDir
  $preinstalledExtensionsDir
  $extensionRepos
  $iconPath
  $appIcon
  $sortAttrs
  $macroFile
  $defaultMacroFile
  $defaultMacroEncoding
  $printOptions
  $showHidden
  $createMacroMenu
  $maxMenuLines
  $useCzechLocales
  $useLocales
  $imageMagickConvert
  $cstsToFs
  $fsToCsts
  $sgmls
  $sgmlsopts
  $cstsdoctype
  $cstsparsecommand
  $cstsparsezcommand
  $keyboardDebug
  $hookDebug
  $macroDebug
  $tredDebug
  $defaultTemplateMatchMethod
  $defaultMacroListOrder
  $defCWidth
  $defCHeight
  $geometry
  $maxDisplayedValues
  $maxDisplayedAttributes
  $highlightWindowColor
  $highlightWindowWidth
  $lastAction
  $reverseNodeOrder
  $valueLineHeight
  $valueLineAlign
  $valueLineWrap
  $valueLineReverseLines
  $valueLineFocusBackground
  $valueLineFocusForeground
  $valueLineBackground
  $valueLineForeground
  $maxUndo
  $reloadKeepsPatterns
  $autoSave
  $displayStatusLine
  $openFilenameCommand
  $saveFilenameCommand
  $NoConvertWarning
  $lockFiles
  $noLockProto
  $stippleInactiveWindows
  $userConf
  $ioBackends
  $htmlBrowser
  $showSidePanel
  $skipStartupVersionCheck
  %c_fonts
);
  @EXPORT_OK=qw(&tilde_expand &read_config &set_config &parse_config_line &apply_config &set_default_config_file_search_list);
  @config_file_search_list=();

  *find_exe = eval {
      require File::Which;
      \&File::Which::which
  } || sub {};
}
use vars (@EXPORT);

$treeViewOpts={
  drawSentenceInfo => 0,
  showHidden => 0,
  displayMode => 0,
  customColors	 =>
    {0 => 'darkgreen',
     1 => 'darkblue',
     2 => 'darkmagenta',
     3 => 'orange',
     4 => 'black',
     5 => 'DodgerBlue4',
     6 => 'red',
     7 => 'gold',
     8 => 'cyan',
     9 => 'midnightblue'}
   };
$printOptions={
  printOnePerFile => 0,
  printTo => 'printer', # was printToFile!!
  printFormat => 'PS',
  # printPsFile, # removed
  printFileExtension => 'ps',
  printSentenceInfo => 0,
  printFileInfo => 0,
  # printCommand, # removed
  printImageMagickResolution => 80,
  printNoRotate=>0,
  printColors => 1,
  ttFont=>"Arial",
  ttFontPath => undef,
  psFontFile => undef,
  psFontAFMFile => undef,
  psFontSize => (($^O=~/^MS/) ? 14 : 12),
  prtFmtWidth => 595,
  prtFmtHeight => 842,
  prtVMargin => '3c',
  prtHMargin => '2c',
  psMedia => 'A4',
  psFile => undef,
  maximizePrintSize => 0,
  defaultPrintCommand => (($^O eq 'MSWin32') ? 'prfile32.exe /-' : 'lpr'),
};

my $resourcePathSplit = ($^O eq "MSWin32") ? ',' : ':';

sub set_default_config_file_search_list {
  require FindBin;
  @config_file_search_list=
    (File::Spec->catfile($ENV{HOME},'.tredrc'),
     map {
       File::Spec->catfile($_,'tredrc')
     } (
       (exists($ENV{TREDHOME}) ? $ENV{TREDHOME} : ()),
       $FindBin::RealBin,
       File::Spec->catfile($FindBin::RealBin,'tredlib'),
       File::Spec->catfile($FindBin::RealBin,'..','lib','tredlib'),
       File::Spec->catfile($FindBin::RealBin,'..','lib','tred'),
    ));
}

sub tilde_expand {
  my ($a)=@_;
  $a=~s/^\~/$ENV{HOME}/;
  $a=~s/([^\\])\~/$1$ENV{HOME}/g;
  return $a;
}

sub parse_config_line {
  local $_=shift;
  my $confs=shift;
  my $key;
  unless (/^\s*[;\#]/ or /^\s*$/) {
    chomp;
    if (/^\s*([a-zA-Z_]+[a-zA-Z_0-9]*(::[a-zA-Z_]+[a-zA-Z_0-9:]*)?)\s*=\s*('(?:[^\\']|\\.)*'|"(?:[^\\"]|\\.)*"|(?:\s*(?:[^;\\\s]|\\.)+)*)/) {
      $key = $2 ? $1 : lc($1);
      $confs->{$key}=$3;
      $confs->{$key}=~s/\\(.)/$1/g;
      $confs->{$key}=$1 if ($confs->{$key}=~/^'(.*)'$/ or $confs->{$key}=~/^"(.*)"$/);
    }
  }
}

sub read_config {
  #
  # Simple configuration file handling
  #
  my %confs;
  my ($key, $f);
  local *F;
  my $openOk=0;
  my $config_file;

  foreach $f (@_,@config_file_search_list) {
    if (defined($f) and open(F,"<$f")) {
      print STDERR "Config file: $f\n" unless $quiet;
      while (<F>) {
	parse_config_line($_,\%confs);
      }
      close F;
      $openOk=1;
      $config_file=$f;
      last;
    }
  }
  unless ($openOk) {
    print STDERR
      "Warning: Cannot open any file in:\n",
      join(":",@config_file_search_list),"\n" .
      "         Using configuration defaults!\n" unless $quiet;
  }
  set_config(\%confs);
  return $config_file;
}

sub apply_config {
  my %confs;
  foreach (@_) {
    parse_config_line($_,\%confs);
  }
  set_config(\%confs);
}

sub val_or_def {
  my ($confs,$key,$def)=@_;
  return ((exists $confs->{$key}) ? $confs->{$key} : $def);
}

sub set_config {
  my ($confs)=@_;

  if (ref($override_options)) {
    my $opt;
    foreach my $opt (@$override_options) {
      my ($n,$v) = split /=/,$opt,2;
      $n=lc($n) unless $n=~/::/;
      if ($n=~s{([-+;:.,&|/ \t]|\\s|\\t)([-.+]?)$}{}) {
	my $delim=$1;
	my $operation=$2;
	my $wdelim = $delim;
	$wdelim=' ' if $delim eq '\s';
	$wdelim="\t" if $delim eq '\t';
	if (defined($confs->{$n}) and length($confs->{$n})) {
	  if (!$operation) {
	    $confs->{$n}=$v.$wdelim.$confs->{$n};
	  } elsif ($operation eq '+') {
  	    $confs->{$n}=$confs->{$n}.$wdelim.$v;
	  } elsif ($operation eq '-') {
	    $confs->{$n}=join $wdelim, grep { $_ ne $v } split /[$delim]/,$confs->{$n};
	  }
	  next;
	} else {
	  next if $operation and $operation eq '-';
	}
      }
      $confs->{$n}=$v;
    }
  }

  $appName=val_or_def($confs,"appname","TrEd ver. ".$main::VERSION);

  $ENV{PML_COMPILE}=val_or_def($confs,"pml_compile",0) unless exists $ENV{PML_COMPILE};

  $buttonsRelief=val_or_def($confs,"buttonsrelief",'flat');
  $menubarRelief=val_or_def($confs,"menubarrelief",'flat');
  $buttonBorderWidth=val_or_def($confs,"buttonsborder",2);
  $canvasBalloonInitWait=val_or_def($confs,"hintwait",1000);
  $canvasBalloonForeground=val_or_def($confs,"hintforeground",'black');
  $canvasBalloonBackground=val_or_def($confs,"hintbackground",'#fff3b0');
  $toolbarBalloonInitWait=val_or_def($confs,"toolbarhintwait",450);
  $toolbarBalloonForeground=val_or_def($confs,"toolbarhintforeground",'black');
  $toolbarBalloonBackground=val_or_def($confs,"toolbarhintbackground",'#fff3b0');

  $activeTextColor=val_or_def($confs,"activetextcolor",'blue');
  $stippleInactiveWindows=val_or_def($confs,"stippleinactivewindows",1);

  $highlightWindowColor=val_or_def($confs,"highlightwindowcolor",'black');
  $highlightWindowWidth=val_or_def($confs,"highlightwindowwidth",3);

  $valueLineHeight=val_or_def($confs,"vlineheight",
			      defined($valueLineHeight) ? $valueLineHeight : 2);
  $valueLineAlign=val_or_def($confs,"vlinealign",
			     defined($valueLineAlign) ? $valueLineAlign : 'left');
  $valueLineWrap=val_or_def($confs,"vlinewrap",
			    defined($valueLineWrap) ? $valueLineWrap : 'word');
  $valueLineReverseLines=val_or_def($confs,"vlinereverselines",
				    defined($valueLineReverseLines) ?
				    $valueLineReverseLines : 0
				   );
  $valueLineFocusForeground=val_or_def($confs,"vlinefocusforeground",
				    defined($valueLineFocusForeground) ?
				    $valueLineFocusForeground : 'black'
				   );
  $valueLineForeground=val_or_def($confs,"vlineforeground",
				    defined($valueLineForeground) ?
				    $valueLineForeground : 'black'
				   );
  $valueLineFocusBackground=val_or_def($confs,"vlinefocusbackground",
				    defined($valueLineFocusBackground) ?
				    $valueLineFocusBackground : 'yellow'
				   );
  $valueLineBackground=val_or_def($confs,"vlinebackground",
				    defined($valueLineBackground) ?
				    $valueLineBackground : 'white'
				   );


  $treeViewOpts->{reverseNodeOrder}   =	val_or_def($confs,"reversenodeorder",
						   $treeViewOpts->{reverseNodeOrder});
  $treeViewOpts->{displayMode}   =	val_or_def($confs,"displaymode",
						   $treeViewOpts->{displayMode});

  $treeViewOpts->{lineSpacing}	      =	 val_or_def($confs,"linespacing",1);
  $treeViewOpts->{baseXPos}	      =	 val_or_def($confs,"basexpos",15);
  $treeViewOpts->{baseYPos}	      =	 val_or_def($confs,"baseypos",15);
  $treeViewOpts->{nodeWidth}	      =	 val_or_def($confs,"nodewidth",7);
  $treeViewOpts->{nodeHeight}	      =	 val_or_def($confs,"nodeheight",7);
  $treeViewOpts->{useAdditionalEdgeLabelSkip}
                                      =
					 val_or_def($confs,"useadditionaledgelabelskip",1);
  $treeViewOpts->{currentNodeWidth}   =	 val_or_def($confs,"currentnodewidth",$treeViewOpts->{nodeWidth}+2);
  $treeViewOpts->{currentNodeHeight}  =	 val_or_def($confs,"currentnodeheight",$treeViewOpts->{nodeHeight}+2);
  $treeViewOpts->{nodeXSkip}	      =	 val_or_def($confs,"nodexskip",10);
  $treeViewOpts->{nodeYSkip}	      =	 val_or_def($confs,"nodeyskip",10);
  $treeViewOpts->{edgeLabelSkipAbove} =	 val_or_def($confs,"edgelabelskipabove",10);
  $treeViewOpts->{edgeLabelSkipBelow} =	 val_or_def($confs,"edgelabelskipbelow",10);
  $treeViewOpts->{xmargin}	      =	 val_or_def($confs,"xmargin",2);
  $treeViewOpts->{ymargin}	      =	 val_or_def($confs,"ymargin",2);
  $treeViewOpts->{lineWidth}	      =	 val_or_def($confs,"linewidth",2);
  $treeViewOpts->{lineColor}	      =	 val_or_def($confs,"linecolor",'gray');
  $treeViewOpts->{hiddenLineColor}    =	 val_or_def($confs,"hiddenlinecolor",'lightgray');
  $treeViewOpts->{dashHiddenLines}    =	 val_or_def($confs,"dashhiddenlines",0);
  $treeViewOpts->{lineArrow}	      =	 val_or_def($confs,"linearrow",'none');
  $treeViewOpts->{nodeColor}	      =	 val_or_def($confs,"nodecolor",'yellow');
  $TrEd::Print::bwModeNodeColor	      =	 val_or_def($confs,"bwprintnodecolor",'white');
  $treeViewOpts->{nodeOutlineColor}   =	 val_or_def($confs,"nodeoutlinecolor",'black');
  $treeViewOpts->{hiddenNodeColor}    =	 val_or_def($confs,"hiddennodecolor",'black');
  $treeViewOpts->{currentNodeColor}   =	 val_or_def($confs,"currentnodecolor",'red');
  $treeViewOpts->{nearestNodeColor}   =	 val_or_def($confs,"nearestnodecolor",'green');
  $treeViewOpts->{balanceTree}	      =	 val_or_def($confs,"balancetree",0) ||
                                         val_or_def($confs,"ballancetree",0);
  $treeViewOpts->{textColor}	      =	 val_or_def($confs,"textcolor",'black');
  $treeViewOpts->{textColorShadow}    =	 val_or_def($confs,"textcolorshadow",'darkgrey');
  $treeViewOpts->{textColorHilite}    =	 val_or_def($confs,"textcolorhilite",'darkgreen');
  $treeViewOpts->{textColorXHilite}   =	 val_or_def($confs,"textcolorxhilite",'darkred');
  $treeViewOpts->{stripeColor}        =  val_or_def($confs,"stripecolor",'#eeeeff');
  $treeViewOpts->{labelSep}        =  val_or_def($confs,"labelsep",5);
  $treeViewOpts->{columnSep}        =  val_or_def($confs,"columnsep",15);
  $treeViewOpts->{vertStripe}     =  val_or_def($confs,"vertstripe",0);
  $treeViewOpts->{horizStripe}     =  val_or_def($confs,"horizstripe",1);

  foreach (keys %$confs) {
    if (/^customcolor(.*)$/) {
      $treeViewOpts->{customColors}->{$1} = $confs->{$_};
    } elsif (/^user(.*)$/) {
      $userConf->{$1}=$confs->{$_};
    }
  }

  $treeViewOpts->{boxColor}	       = val_or_def($confs,"boxcolor",'LightYellow');
  $treeViewOpts->{currentBoxColor}     = val_or_def($confs,"currentboxcolor",'yellow');
  $treeViewOpts->{hiddenBoxColor}      = val_or_def($confs,"hiddenboxcolor",'gray');

  $treeViewOpts->{edgeBoxColor}	       = val_or_def($confs,"edgeboxcolor",'#fff0e0');
  $treeViewOpts->{currentEdgeBoxColor} = val_or_def($confs,"edgecurrentboxcolor",'#ffe68c');
  $treeViewOpts->{hiddenEdgeBoxColor}  = val_or_def($confs,"edgehiddenboxcolor","DarkGrey");

  $treeViewOpts->{clearTextBackground} = val_or_def($confs,"cleartextbackground",1);

  $treeViewOpts->{backgroundColor}     = val_or_def($confs,"backgroundcolor",'white');

  $treeViewOpts->{backgroundImageX}     = val_or_def($confs,"backgroundimagex",0);
  $treeViewOpts->{backgroundImageY}     = val_or_def($confs,"backgroundimagey",0);
  $treeViewOpts->{noColor}	       = val_or_def($confs,"allowcustomcolors",0);
  $treeViewOpts->{drawBoxes}	       = val_or_def($confs,"drawboxes",0);
  $treeViewOpts->{drawEdgeBoxes}       = val_or_def($confs,"drawedgeboxes",0);
  $treeViewOpts->{highlightAttributes} = val_or_def($confs,"highlightattributes",1);
  $treeViewOpts->{showHidden} = val_or_def($confs,"showhidden",0);;
  $treeViewOpts->{skipHiddenLevels} = val_or_def($confs,"skiphiddenlevels",0);
  $treeViewOpts->{skipHiddenParents} = val_or_def($confs,"skiphiddenparents",0);
  $treeViewOpts->{drawSentenceInfo} = val_or_def($confs,"drawsentenceinfo",0);
  $treeViewOpts->{drawFileInfo} = val_or_def($confs,"drawfileinfo",0);
  $treeViewOpts->{useFSColors} = val_or_def($confs,"usefscolors",0);

  $TrEd::Convert::inputenc = val_or_def($confs,"defaultfileencoding",$TrEd::Convert::inputenc);
  $TrEd::Convert::outputenc = val_or_def($confs,"defaultdisplayencoding",$TrEd::Convert::outputenc);
  $TrEd::Convert::lefttoright = val_or_def($confs,"displaynonasciilefttoright",$TrEd::Convert::lefttoright);

  my $fontenc=$TrEd::Convert::outputenc
    || ((defined($Tk::VERSION) and $Tk::VERSION < 804) ?  "iso-8859-2" : "iso-10646-1");
  $fontenc=~s/^iso-/iso/;

  if (exists $confs->{font}) {
    $font=$confs->{font};
    $font=~s/-\*-\*$/-$fontenc/;
  } else {
    if ($^O=~/^MS/) {
      $font='family:Arial,size:10';
    } elsif ($fontenc eq 'iso10646-1') {
      $font='{Arial Unicode Ms} 10';
      #$font='-*-arial unicode ms-medium-r-normal-*-12-*-*-*-*-*-iso10646-1';
    } else {
      $font='-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-'.$fontenc;
    }
  }
  # print "USING FONT $font\n";
  $treeViewOpts->{font}=$font;
  $vLineFont=val_or_def($confs,"vlinefont",$font);
  $guiFont=val_or_def($confs,"guifont",undef);
  for my $name (qw(small small_bold heading fixed default bold italic)) {
    $c_fonts{$name}=val_or_def($confs,"guifont_".$name,undef);
  }

  if ($confs->{perllib}) {
    foreach my $perllib (split/\:/,$confs->{perllib}) {
      $perllib = tilde_expand($perllib);
      unshift @INC,$perllib unless (grep($_ eq $perllib, @INC));
    }
  }
  $libDir=tilde_expand($confs->{libdir}) if (exists $confs->{libdir});
  if ($libDir) {
    unshift @INC,$libDir unless (grep($_ eq $libDir, @INC));
  }
  $extensionsDir=tilde_expand(length($confs->{extensionsdir})
				? $confs->{extensionsdir} : '~/.tred.d/extensions');
  $extensionRepos = val_or_def($confs,'extensionrepos','http://ufal.mff.cuni.cz/~pajas/tred/extensions');

  my $def_share_path=$libDir;
  if ($^O eq 'Win32') {
    $def_share_path=~s/[\\\/](?:lib[\\\/]tred|tredlib)$//;
  } else {
    unless ($def_share_path=~s{/lib/tred$}{/share/tred}) {
      $def_share_path=~s/\/(?:tredlib)$//;
    }
  }
  $preinstalledExtensionsDir =
    length($confs->{preinstalledextensionsdir})
				? tilde_expand($confs->{preinstalledextensionsdir}) :
     $def_share_path =~ m{/share/tred$} ? $def_share_path.'-extensions' :
      File::Spec->catdir($def_share_path,'tred-extensions');

  {
    my $def_res_path = 
      $def_share_path =~ m{/share/tred$} ? $def_share_path :
	File::Spec->catdir($def_share_path,'resources');
    $def_res_path = tilde_expand(q(~/.tred.d)) . $resourcePathSplit . $def_res_path ;
    my @r = split $resourcePathSplit, $Fslib::resourcePath;
    my $r;
    if (exists $confs->{resourcepath}) {
      my $path = 
	join $resourcePathSplit,
	  map { tilde_expand($_) } split /\Q$resourcePathSplit\E/, $confs->{resourcepath};
      if ($path=~/^\Q$resourcePathSplit\E/) {
	$path=$def_res_path.$path;
      } elsif ($path=~/\Q$resourcePathSplit\E$/) {
	$path.=$def_res_path;
      }
      $r = $path;
    } else {
      $r = $def_res_path;
    }
    unshift @r, split($resourcePathSplit,$r),
    my %r;
    $Fslib::resourcePath = join $resourcePathSplit, grep { defined and length } map { exists($r{$_}) ? () : ($r{$_}=$_) } @r
  }
  if ($confs->{backgroundimage} ne "" 
      and ! -f $confs->{backgroundimage}
      and  -f $libDir."/".$confs->{backgroundimage}) {
    $treeViewOpts->{backgroundImage}=
      $libDir."/".$confs->{backgroundimage};
  } else {
    $treeViewOpts->{backgroundImage}=
      val_or_def($confs,"backgroundimage",undef);
  }

  $appIcon=(exists $confs->{appicon}) ? tilde_expand($confs->{appicon}) : "$libDir/tred.xpm";
  $iconPath=(exists $confs->{iconpath}) ? tilde_expand($confs->{iconpath}) : "$libDir/icons/crystal";
  $macroFile=tilde_expand($confs->{macrofile}) if (exists $confs->{macrofile});
  $defaultMacroFile=(exists $confs->{defaultmacrofile}) ? tilde_expand($confs->{defaultmacrofile}) : "$libDir/tred.def";
  $defaultMacroEncoding=val_or_def($confs,"defaultmacroencoding",'utf8');
  $sortAttrs	     =	val_or_def($confs,"sortattributes",1);
  for my $opt (keys %$printOptions) {
    $printOptions->{$opt} = val_or_def($confs,lc($opt),$printOptions->{$opt});
  }
  {
    my $psFontFile = $printOptions->{psFontFile};
    my $psFontAFMFile = $printOptions->{psFontAFMFile};
    if (defined $psFontFile and length $psFontFile) {
      $psFontFile=tilde_expand($psFontFile);
      $psFontFile="$libDir/".$psFontFile if (not -f $psFontFile and -f 
					       "$libDir/".$psFontFile);
    } else {
      if (!defined($Tk::VERSION) or $Tk::VERSION >= 804) {
	$psFontFile="$libDir/fonts/n019003l.pfa";
      } else {
	$psFontFile="$libDir/fonts/ariam___.pfa";
      }
    }
    if (defined $psFontAFMFile and length $psFontAFMFile) {
      $psFontAFMFile=tilde_expand($psFontAFMFile);
      $psFontAFMFile="$libDir/".$psFontAFMFile if (not -f $psFontAFMFile and -f 
					       "$libDir/".$psFontAFMFile);
    } else {
      $psFontAFMFile=$psFontFile;
      $psFontAFMFile=~s/\.[^.]+$/.afm/;
      unless (-f $psFontAFMFile) {
	$psFontAFMFile=~s!/([^/]+)$!/afm/$1!;
      }
    }
    $printOptions->{psFontFile}=$psFontFile;
    $printOptions->{psFontAFMFile}=$psFontAFMFile;
  }
  {
    my $ttFontPath = $printOptions->{ttFontPath};
    if (defined $ttFontPath and length $ttFontPath) {
      $ttFontPath=tilde_expand($confs->{ttfontpath});
      $ttFontPath="$libDir/".$ttFontPath if (not -d $ttFontPath and -d "$libDir/".$ttFontPath);
    } else {
      my @fontpath;
      if ($^O eq "MSWin32") {
	require Win32::Registry;
	my %shf;
	my $ShellFolders;
	my $shfolders="Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
	$::HKEY_CURRENT_USER->Open($shfolders,$ShellFolders) or warn "Cannot read $shfolders $^E\n";
	$ShellFolders->GetValues(\%shf);
	@fontpath = ($shf{Fonts}[2]);
	#		 qw(c:/windows/fonts/ c:/winnt/fonts/);
      } else {
	# use fontconfig here?
	if (open my $fc,'/etc/fonts/fonts.conf') {
	  while (<$fc>) {
	    push @fontpath,tilde_expand($1) if m{<dir>([^<]*)</dir>} and -d tilde_expand($1);
	    # naive, should subst. entities, etc.
	  }
	}
	unless (@fontpath) {
	  @fontpath = ("$ENV{HOME}/.fonts/",
		       qw(
			   /usr/X11R6/lib/X11/fonts/TTF/
			   /usr/X11R6/lib/X11/fonts/TrueType/
			   /usr/share/fonts/default/TrueType/
			   /usr/share/fonts/default/TTF/
			)
		      );
	}
      }
      $ttFontPath = join ",",map tilde_expand($_),@fontpath;
    }
    $printOptions->{ttFontPath} = $ttFontPath;
  }
  $createMacroMenu    =	 val_or_def($confs,"createmacromenu",0);
  $maxMenuLines	      =	 val_or_def($confs,"maxmenulines",20);
  $useCzechLocales    =	 val_or_def($confs,"useczechlocales",0);
  $useLocales         =	 val_or_def($confs,"uselocales",0);
  $Tk::strictMotif    =	 val_or_def($confs,"strictmotif",0);
  $imageMagickConvert = val_or_def($confs,"imagemagickconvert",'convert');
  $NoConvertWarning = val_or_def($confs,"noconvertwarning",0);

  $IOBackend::reject_proto = val_or_def($confs,'rejectprotocols','^(pop3?s?|imaps?)\$');
  $IOBackend::gzip = val_or_def($confs,"gzip",find_exe("gzip"));
  if (!$IOBackend::gzip and -x "$libDir/../gzip") {
    $IOBackend::gzip = "$libDir/../bin/gzip";
  }
  $IOBackend::gzip_opts = val_or_def($confs,"gzipopts", "-c");
  $IOBackend::zcat = val_or_def($confs,"zcat", find_exe("zcat"));
  $IOBackend::zcat_opts = val_or_def($confs,"zcatopts", undef);
  $IOBackend::ssh = val_or_def($confs,"ssh", undef);
  $IOBackend::ssh_opts = val_or_def($confs,"sshopts", undef);
  $IOBackend::kioclient = val_or_def($confs,"kioclient", undef);
  $IOBackend::kioclient_opts = val_or_def($confs,"kioclientopts", undef);
  $IOBackend::curl = val_or_def($confs,"curl", undef);
  $IOBackend::curl_opts = val_or_def($confs,"curlopts", undef);
  if (!$IOBackend::zcat) {
    if ($IOBackend::gzip) {
      $IOBackend::zcat=$IOBackend::gzip;
      $IOBackend::zcat_opts='-d';
    } elsif (-x "$libDir/../zcat") {
      $IOBackend::zcat = "$libDir/../bin/zcat";
    }
  }
  $cstsToFs = val_or_def($confs,"cststofs",undef);
  $fsToCsts = val_or_def($confs,"fstocsts",undef);

  $CSTSBackend::gzip = $IOBackend::gzip;
  $CSTSBackend::zcat = $IOBackend::zcat;
  $CSTSBackend::csts2fs=$cstsToFs;
  $CSTSBackend::fs2csts=$fsToCsts;

  $sgmls       = val_or_def($confs,"sgmls","nsgmls");
  $sgmlsopts   = val_or_def($confs,"sgmlsopts","-i preserve.gen.entities");
  $cstsdoctype = val_or_def($confs,"cstsdoctype",undef);
  $cstsparsecommand = val_or_def($confs,"cstsparsercommand","\%s \%o \%d \%f");

  $CSTS_SGML_SP_Backend::sgmls=$sgmls;
  $CSTS_SGML_SP_Backend::sgmlsopts=$sgmlsopts;
  $CSTS_SGML_SP_Backend::doctype=$cstsdoctype;
  $CSTS_SGML_SP_Backend::sgmls_command=$cstsparsecommand;

  $keyboardDebug	      =	val_or_def($confs,"keyboarddebug",0);
  $hookDebug		      =	val_or_def($confs,"hookdebug",0);
  $macroDebug		      =	val_or_def($confs,"macrodebug",0);
  $tredDebug		      =	val_or_def($confs,"treddebug",$tredDebug);
  $Fslib::Debug               = val_or_def($confs,"backenddebug",$Fslib::Debug);
  $defaultTemplateMatchMethod =	val_or_def($confs,"searchmethod",'R');
  $defaultMacroListOrder      =	val_or_def($confs,"macrolistorder",'M');
  $defCWidth		      =	val_or_def($confs,"canvaswidth",'18c');
  $defCHeight		      =	val_or_def($confs,"canvasheight",'12c');
  $geometry		      =	val_or_def($confs,"geometry",undef);
  $showSidePanel              =	val_or_def($confs,"showsidepanel",undef);
  $maxDisplayedValues	      =	val_or_def($confs,"maxdisplayedvalues",25);
  $maxDisplayedAttributes     =	val_or_def($confs,"maxdisplayedattributes",20);
  $lastAction		      =	val_or_def($confs,"lastaction",undef);

  $maxUndo		      =	val_or_def($confs,"maxundo",30);
  $reloadKeepsPatterns	      =	val_or_def($confs,"reloadpreservespatterns",1);
  $autoSave	              =	val_or_def($confs,"autosave",5);
  $displayStatusLine          =	val_or_def($confs,"displaystatusline",1);
  $openFilenameCommand        =	val_or_def($confs,"openfilenamecommand",undef);
  $saveFilenameCommand        =	val_or_def($confs,"savefilenamecommand",undef);
  $lockFiles                  =	val_or_def($confs,"lockfiles",1);
  $noLockProto                =	val_or_def($confs,"nolockprotocols",'^(https?|zip|tar)$');
  $ioBackends                 =	val_or_def($confs,"iobackends",undef);
  $htmlBrowser                =	val_or_def($confs,"htmlbrowser",undef);

  $skipStartupVersionCheck    =	val_or_def($confs,"skipstartupversioncheck",undef);

  # ADD NEW OPTIONS HERE

  &$set_user_config($confs) if (ref($set_user_config)); # let this be the very last line
  {
    no strict qw(vars);
    foreach (keys %$confs) {
      if (/::/) {
	${"$_"}=$confs->{$_};
      }
    }
  }

}

1;
