package TrEd::Config;

#
# $Id: Config.pm 4498 2010-10-14 15:34:37Z fabip4am $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use Data::Dumper;

use strict;
use File::Spec;
use Cwd;
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
  $sortAttrValues
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
  $enableTearOff
  %defaultPrintConfig
  %c_fonts
  $sidePanelWrap
);
  @EXPORT_OK=qw(&tilde_expand &read_config &set_config &parse_config_line &apply_config &set_default_config_file_search_list);
  @config_file_search_list=();

  *find_exe = eval {
      require File::Which;
      \&File::Which::which
  } || sub {};
}
use vars (@EXPORT);

# same as @TrEd::TreeView::Options, which we do not see yet
my @treeViewOpts = qw(

  backgroundColor backgroundImage backgroundImageX backgroundImageY
  balanceTree baseXPos baseYPos boxColor clearTextBackground columnSep
  currentBoxColor currentEdgeBoxColor currentNodeColor
  currentNodeHeight currentNodeWidth customColors dashHiddenLines
  displayMode drawBoxes drawEdgeBoxes drawFileInfo drawSentenceInfo
  edgeBoxColor edgeLabelSkipAbove edgeLabelSkipBelow font
  hiddenBoxColor hiddenEdgeBoxColor hiddenLineColor hiddenNodeColor
  highlightAttributes horizStripe labelSep lineArrow lineArrowShape
  lineColor lineDash lineSpacing lineWidth nearestNodeColor noColor
  nodeColor nodeHeight nodeOutlineColor nodeWidth nodeXSkip nodeYSkip
  reverseNodeOrder showHidden skipHiddenLevels skipHiddenParents
  stripeColor textColor textColorHilite textColorShadow
  textColorXHilite useAdditionalEdgeLabelSkip useFSColors vertStripe
  verticalTree xmargin ymargin

);

$treeViewOpts={
  customColors => {
    # we override the hash in TrEd::TreeView::DefaultOptions
    # because we don't see it yet
    0 => 'darkgreen',
    1 => 'darkblue',
    2 => 'darkmagenta',
    3 => 'orange',
    4 => 'black',
    5 => 'DodgerBlue4',
    6 => 'red',
    7 => 'gold',
    8 => 'cyan',
    9 => 'midnightblue'
  },

  # we want to create scalar references to these options:
  clearTextBackground => 1,
  drawEdgeBoxes => 0,
  drawBoxes => 0,
  showHidden => 0,
  displayMode => 0,
};

%defaultPrintConfig = (
  printOnePerFile => ['-oneTreePerFile',0],
  printTo => [undef,'printer'],
  printFormat => ['-format','PS'],
  printFileExtension => [undef,'ps'],
  printSentenceInfo => ['-sentenceInfo', 0],
  printFileInfo => ['-fileInfo', 0],
  printImageMagickResolution => ['-imageMagickResolution', 80],
  printNoRotate=> ['-noRotate',0],
  printColors => ['-colors', 1],
  ttFont=> ['-ttFontName',"Arial"],
  ttFontPath => ['-ttFontPath', undef],
  psFontFile => ['-psFontFile', undef],
  psFontAFMFile => ['-psFontAFMFile', undef],
  psFontSize => ['-fontSize', (($^O=~/^MS/) ? 14 : 12)],
  prtFmtWidth => ['-fmtWidth', 595],
  prtFmtHeight => ['-fmtHeight', 842],
  prtVMargin => ['-vMargin', '3c'],
  prtHMargin => ['-hMargin', '2c'],
  psMedia => ['-psMedia', 'A4'],
  psFile => [undef, undef],
  maximizePrintSize => ['-maximize', 0],
  defaultPrintCommand => ['-command', (($^O eq 'MSWin32') ? 'prfile32.exe /-' : 'lpr')],
);

$printOptions={};

my $resourcePathSplit = ($^O eq "MSWin32") ? ',' : ':';

######################################################################################
# Usage         : set_default_config_file_search_list()
# Purpose       : Set @config_file_search_list values to common places where 
#                 tredrc cofiguration file is usually found
# Returns       : nothing
# Parameters    : no
# Throws        : nothing
# Comments      : Requires FindBin
# See Also      : 
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

#####################################################################################
# Usage         : parse_config_line()
# Purpose       : Parse each line of the config file to extract key and value pair and 
#                 save it into hash $confs
# Returns       : nothing
# Parameters    : string $line, hash_ref $confs_ref
# Throws        : nothing
# Comments      : Longer because of comments of quite sophisticated regexp
# See Also      : read_config() -- a caller of this ftion
sub parse_config_line {
  my ($line, $confs_ref) = @_;
  my $key;
  my $spaces_re = qr{\s*};
  my $optional_subkey_re = qr{
    ::[a-zA-Z_]+[a-zA-Z_0-9:]*
  }x;
  my $key_standard_re = qr{
    [a-zA-Z_]+[a-zA-Z_0-9]*
  }x;
  my $single_quot_value_re = qr{
    '(?:[^\\']|\\.)*' # we want the regexp to be able to match escaped single quotes and backslashes in string and use it, 
                      # so |'" \'sth_else| or |'abc\'\'| does not match
                      # but |'" \'sth_else'| or |'abcd\''| matches and it extracts |" \'sth_else| and |abcd\'|, respectively
                      # be careful, though: |'abcd\\''| matches, but the last quote is not extracted: |abcd\\|
  }x;
  my $double_quot_value_re = qr {
    "(?:[^\\"]|\\.)*" # the same situation as with single quotes, just change ' => " and vice versa
  }x;
  my $unquot_value_re = qr {
    (?:\s*(?:[^;\\\s]|\\.)+)* # we want to allow strings like C:\\Documents and Settings\\John\\Application Data\\
                              # so we basically accept everything except for ';', which is a start for a commentary (but it can be escaped)
                              # everything after the ';' until the end of the line is thrown away
                              # backslash, ';' and whitespace at the end of the string is chopped, but only if they are not escaped
  }x;
  my $parse_config_re = qr{
    ^
    $spaces_re # any number of spaces
    #key capturing
    (	
    $key_standard_re
    ($optional_subkey_re)?
    )
    $spaces_re # any number of spaces
    =	       # equal sign as the key-value delimiter
    $spaces_re # any number of spaces
    #capture value
    (
    #single quoted value
    $single_quot_value_re
    | # or
    $double_quot_value_re
    | # or
    $unquot_value_re
    )
  }x;
  
  # if line starts with ; or # or contains only spaces, don't do anything
  unless ($line =~ /^\s*[;#]/ or $line =~ /^\s*$/) {
    chomp($line);
    if ($line =~ $parse_config_re) {
      # if there is no "::" in key, lowercase it 
      $key = $2 ? $1 : lc($1);
      $confs_ref->{$key} = $3;
      $confs_ref->{$key} =~ s/\\(.)/$1/g;
      # remove quotes
      if ($confs_ref->{$key}=~/^'(.*)'$/ or $confs_ref->{$key}=~/^"(.*)"$/){
        $confs_ref->{$key}=$1;
      }
    }
  }
}

#####################################################################################
# Usage         : read_config()
# Purpose       : Set @config_file_search_list values to common places where 
#                 tredrc cofiguration file is usually found
# Returns       : Path to the config file from which the configuration was read
# Parameters    : [List of tredrc possible locations]
# Throws        : nothing
# Comments      : Simple configuration file handling
# See Also      : parse_config_line(), set_config()
sub read_config {
  my %confs;
  my ($key, $f);
  local *F;
  my $config_found = 0;
  my $config_file;

  foreach $f (@_,@config_file_search_list) {
    my $fh;
    if (defined($f) and open($fh,'<',$f)) {
      print STDERR "Config file: $f\n" unless $quiet;
      while (<$fh>) {
        parse_config_line($_,\%confs);
      }
      close($fh);
      $config_found = 1;
      $config_file = $f;
      last;
    }
  }
  unless ($config_found) {
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

  for my $opt (@treeViewOpts) {
    $treeViewOpts->{$opt} = $confs->{lc($opt)} if exists $confs->{lc($opt)};
  }
  for my $opt (qw(Height Width)) {
    $treeViewOpts->{'currentNode'.$opt} =
      $treeViewOpts->{'node'.$opt}+2
	if (!exists($treeViewOpts->{'currentNode'.$opt}) and
	      exists($treeViewOpts->{'node'.$opt}));
  }
  foreach (keys %$confs) {
    if (/^customcolor(.*)$/) {
      $treeViewOpts->{customColors}->{$1} = $confs->{$_};
    } elsif (/^user(.*)$/) {
      $userConf->{$1}=$confs->{$_};
    }
  }

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
  $extensionsDir=File::Spec->rel2abs(tilde_expand(length($confs->{extensionsdir})
						  ? $confs->{extensionsdir} : '~/.tred.d/extensions'),
				     Cwd::cwd());
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
    my @r = split $resourcePathSplit, $Treex::PML::resourcePath;
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
    $Treex::PML::resourcePath = join $resourcePathSplit, grep { defined and length } map { exists($r{$_}) ? () : ($r{$_}=$_) } @r
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
  $sortAttrValues   =	val_or_def($confs,"sortattributevalues",1);
  for my $opt (keys %defaultPrintConfig) {
    $printOptions->{$opt} = val_or_def($confs,lc($opt),$defaultPrintConfig{$opt}[1]);
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

  $Treex::PML::IO::reject_proto = val_or_def($confs,'rejectprotocols','^(pop3?s?|imaps?)\$');
  $Treex::PML::IO::gzip = val_or_def($confs,"gzip",find_exe("gzip"));
  if (!$Treex::PML::IO::gzip and -x "$libDir/../gzip") {
    $Treex::PML::IO::gzip = "$libDir/../bin/gzip";
  }
  $Treex::PML::IO::gzip_opts = val_or_def($confs,"gzipopts", "-c");
  $Treex::PML::IO::zcat = val_or_def($confs,"zcat", find_exe("zcat"));
  $Treex::PML::IO::zcat_opts = val_or_def($confs,"zcatopts", undef);
  $Treex::PML::IO::ssh = val_or_def($confs,"ssh", undef);
  $Treex::PML::IO::ssh_opts = val_or_def($confs,"sshopts", undef);
  $Treex::PML::IO::kioclient = val_or_def($confs,"kioclient", undef);
  $Treex::PML::IO::kioclient_opts = val_or_def($confs,"kioclientopts", undef);
  $Treex::PML::IO::curl = val_or_def($confs,"curl", undef);
  $Treex::PML::IO::curl_opts = val_or_def($confs,"curlopts", undef);
  if (!$Treex::PML::IO::zcat) {
    if ($Treex::PML::IO::gzip) {
      $Treex::PML::IO::zcat=$Treex::PML::IO::gzip;
      $Treex::PML::IO::zcat_opts='-d';
    } elsif (-x "$libDir/../zcat") {
      $Treex::PML::IO::zcat = "$libDir/../bin/zcat";
    }
  }
  $cstsToFs = val_or_def($confs,"cststofs",undef);
  $fsToCsts = val_or_def($confs,"fstocsts",undef);

  #  $Treex::PML::Backends::CSTS::gzip = $Treex::PML::IO::gzip;
  #  $Treex::PML::Backends::CSTS::zcat = $Treex::PML::IO::zcat;
  #  $Treex::PML::Backends::CSTS::csts2fs=$cstsToFs;
  #  $Treex::PML::Backends::CSTS::fs2csts=$fsToCsts;

  $sgmls       = val_or_def($confs,"sgmls","nsgmls");
  $sgmlsopts   = val_or_def($confs,"sgmlsopts","-i preserve.gen.entities");
  $cstsdoctype = val_or_def($confs,"cstsdoctype",undef);
  $cstsparsecommand = val_or_def($confs,"cstsparsercommand","\%s \%o \%d \%f");

  $Treex::PML::Backends::CSTS::sgmls=$sgmls;
  $Treex::PML::Backends::CSTS::sgmlsopts=$sgmlsopts;
  $Treex::PML::Backends::CSTS::doctype=$cstsdoctype;
  $Treex::PML::Backends::CSTS::sgmls_command=$cstsparsecommand;

  $keyboardDebug	      =	val_or_def($confs,"keyboarddebug",0);
  $hookDebug		      =	val_or_def($confs,"hookdebug",0);
  $macroDebug		      =	val_or_def($confs,"macrodebug",0);
  $tredDebug		      =	val_or_def($confs,"treddebug",$tredDebug);
  $Treex::PML::Debug               = val_or_def($confs,"backenddebug",$Treex::PML::Debug);
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
  $enableTearOff              =	val_or_def($confs,"enabletearoff",0);

  $sidePanelWrap              = val_or_def($confs,"sidepanelwrap",0);
  # ADD NEW OPTIONS HERE

  &$set_user_config($confs) if (ref($set_user_config)); # let this be the very last line
  {
    no strict qw(vars refs);
    foreach (keys %$confs) {
      if (/::/) {
	${"$_"}=$confs->{$_};
      }
    }
  }

}

1;
