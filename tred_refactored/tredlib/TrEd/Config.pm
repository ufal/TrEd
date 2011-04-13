package TrEd::Config;

#
# $Id: Config.pm 4498 2010-10-14 15:34:37Z fabip4am $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

#use Data::Dumper;

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
  $default_macro_file
  $default_macro_encoding
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



######################################################################################
# Usage         : set_default_config_file_search_list()
# Purpose       : Set @config_file_search_list values to common places where 
#                 tredrc cofiguration file (tredrc) is usually found
# Returns       : nothing
# Parameters    : no
# Throws        : nothing
# Comments      : Requires FindBin. Tredrc paths are set to HOME environment variable, 
#                 TREDHOME environment variable and relative to the original perl script's 
#                 directory: under subdirectory tredlib, ../lib/tredlib, ../lib/tred
# See Also      : $FindBin::RealBin
sub set_default_config_file_search_list {
  require FindBin;
  @config_file_search_list=
    (File::Spec->catfile($ENV{'HOME'},'.tredrc'),
     map {
       File::Spec->catfile($_,'tredrc')
     } (
       (exists($ENV{'TREDHOME'}) ? $ENV{'TREDHOME'} : ()),
       $FindBin::RealBin,
       File::Spec->catfile($FindBin::RealBin,'tredlib'),
       File::Spec->catfile($FindBin::RealBin,'..','lib','tredlib'),
       File::Spec->catfile($FindBin::RealBin,'..','lib','tred'),
    ));
}

######################################################################################
# Usage         : tilde_expand($path_str)
# Purpose       : If string contains tilde, substitute tilde with home directory of current user
# Returns       : String after the substitution
# Parameters    : scalar $path_str -- string containing path
# Throws        : nothing
# Comments      : 
# See Also      : 
sub tilde_expand {
  my ($a) = @_;
  # substitute tilde with HOME env variable at the beginning of the string
  $a =~ s/^\~/$ENV{HOME}/;
  # substitute tilde with HOME env variable anywhere in the string
  $a =~ s/([^\\])\~/$1$ENV{HOME}/g;
  return $a;
}

#####################################################################################
# Usage         : parse_config_line()
# Purpose       : Parse each line of the config file to extract key and value pair and 
#                 save it into hash $confs_ref
# Returns       : nothing
# Parameters    : string $line        -- line to be parsed
#                 hash_ref $confs_ref -- hash of configuration key-value pairs
# Throws        : nothing
# Comments      : Longer because of comments of quite sophisticated regexp
# See Also      : read_config() -- a caller of this function
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
  my $single_quot_value_re = qr {
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
  my $parse_config_re = qr {
    ^
    $spaces_re # any number of spaces
    #capturing key to $1
    (	
    $key_standard_re
    ($optional_subkey_re)?
    )
    $spaces_re # any number of spaces
    =	       # equal sign as the key-value delimiter
    $spaces_re # any number of spaces
    #capture value to $2
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
# Usage         : read_config(@paths_to_config_file)
# Purpose       : Read configuration values from file and save it to %confs hash
# Returns       : Name/path to config file that was used to read cofiguration values
# Parameters    : list @paths_to_config_file -- array containing file name of config file(s)
# Throws        : 
# Comments      : Tries to open config file, first from list supported by argument, if it does not succeed, 
#                 function tries to open files from @config_file_search_list. If any of these files is opened
#                 successfully, the configuration is then read to memory from this file. 
# See Also      : set_config(), parse_config_line()
sub read_config {
  my %confs;
  my ($key, $f);
  my $config_found = 0;
  my $config_file;

  foreach $f (@_, @config_file_search_list) {
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
  if (!$config_found) {
    print STDERR
      "Warning: Cannot open any file in:\n",
      join(":",@config_file_search_list),"\n" .
      "         Using configuration defaults!\n" unless $quiet;
  }
  set_config(\%confs);
  return $config_file;
}

#####################################################################################
# Usage         : apply_config(@options)
# Purpose       : Apply configuration @options
# Returns       : Nothing
# Parameters    : list @options -- list of option_name=option_value strings
# Throws        : 
# Comments      : Parses configuration @options, calls set_config() with new options
# See Also      : set_config(), parse_config_line() 
sub apply_config {
  my %confs;
  foreach (@_) {
    parse_config_line($_,\%confs);
  }
  set_config(\%confs);
  return;
}

#####################################################################################
# Usage         : val_or_def($configuration_hash, $key, $default_value)
# Purpose       : Choose value from $configuration_hash with $key if it exists or $default_value otherwise
# Returns       : Value set in $configuration_hash reference with key $key if it exists, $default_value otherwise
# Parameters    : hash_ref $configuration_hash  -- reference to hash with configuration options
#                 scalar $key                   -- string containing name of the option
#                 scalar $default_value         -- scalar containing the value of configuration option
# Throws        : 
# Comments      : 
# See Also      : 
sub val_or_def {
  my ($confs_ref, $key, $default) = @_;
  return (exists($confs_ref->{$key}) ? $confs_ref->{$key} : $default);
}

#####################################################################################
# Usage         : _parse_cmdline_options($confs_ref)
# Purpose       : Parse options from command line switch -O and save them in $confs_ref
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : Uses array reference $override_options, where the command line options are 
#                 stored. The syntax of -O argument is specified in tred manual, in short these options
#                 are supported: 
#                 * name=value    -- set option 'name' to 'value'
#                 * nameX=value   -- treat the option as a list delimited by the delimiter X and prepend the value to the list.
#                 * nameX+=value  -- treat the option as a list delimited by the delimiter X and append the value to the list.
#                 * nameX-=value  -- treat the option as a list delimited by the delimiter X and remove the value from the list (if exists).
#                 Only the following characters can be used as a delimiter:
#                 ; : , & | / + - \s \t SPACE
#                 Can be combined, i.e. -O "extensionRepos\\s"-=http://foo/bar -O "extensionRepos\\s"+=http://foo/bar
#                 first removes any occurrence of the URL http://foo/bar from the white-space separated list of extensionRepos and then appends the URL to the end of the list. 
# See Also      : set_config()
sub _parse_cmdline_options {
  my ($confs_ref) = @_;

  if (ref($override_options)) {
    foreach my $opt (@$override_options) {
      my ($name, $value) = split(/=/, $opt, 2);
      if (!($name =~ /::/)){
        $name = lc($name);
      }
      if ($name =~ s{([-+;:.,&|/ \t]|\\s|\\t)([-.+]?)$}{}) {
        my $delim = $1;
        my $operation = $2;
        my $wdelim = $delim;
        if ($delim eq '\s'){
          $wdelim = ' ' ;
        }
        if ($delim eq '\t'){
          $wdelim = "\t";
        }
        if (defined($confs_ref->{$name}) and length($confs_ref->{$name})) {
          if (!$operation) {
            $confs_ref->{$name} = $value . $wdelim . $confs_ref->{$name};
          } elsif ($operation eq '+') {
            $confs_ref->{$name} = $confs_ref->{$name} . $wdelim . $value;
          } elsif ($operation eq '-') {
            $confs_ref->{$name} = join($wdelim, grep { $_ ne $value } split(/[$delim]/, $confs_ref->{$name}));
          }
          next;
        } else {
          next if ($operation and $operation eq '-');
        }
      }
      $confs_ref->{$name}=$value;
    }
  }
  return;
}

#####################################################################################
# Usage         : _set_treeViewOpts($confs_ref)
# Purpose       : Set various options in treeViewOpts hash
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : Tries to set all options found in treeViewOpts from $confs_ref. 
#                 In addition, sets these options: currentNodeHeight, -Width, nodeHeight, -Width,
#                 customColor..., font and backgroundImage
#                 $TrEd::Config::font should be set before running this function e.g. by calling _set_fonts()
# See Also      : set_config()
sub _set_treeViewOpts {
  my ($confs_ref) = @_;
  ## set treeViewOpts
  for my $opt (@treeViewOpts) {
    if (exists($confs_ref->{lc($opt)})) {
      $treeViewOpts->{$opt} = $confs_ref->{lc($opt)};
    }
  }
  # treeViewOpts: set currentNodeWidht & -Height
  for my $opt (qw(Height Width)) {
    if (!exists($treeViewOpts->{'currentNode'.$opt}) and exists($treeViewOpts->{'node'.$opt})) {
      $treeViewOpts->{'currentNode'.$opt} = $treeViewOpts->{'node'.$opt} + 2; # Hm, why +2?
    }
  }
  # treeViewOpts: set customColors
  # and user- settings
  #TODO: find out whether userConf is somehow connected with the treeViewOpts, maybe put it back into set_config()
  foreach my $key (keys %$confs_ref) {
    if ($key =~ m/^customcolor(.*)$/) {
      $treeViewOpts->{customColors}->{$1} = $confs_ref->{$key};
    } elsif ($key =~ m/^user(.*)$/) {
      $userConf->{$1} = $confs_ref->{$key};
    }
  }
  
  # Font
  $treeViewOpts->{font} = $font;
  
  # Background image
  if ($confs_ref->{backgroundimage} ne "" 
      and ! -f $confs_ref->{backgroundimage}
      and  -f $libDir . "/" . $confs_ref->{backgroundimage}) {
    $treeViewOpts->{backgroundImage} = $libDir . "/" . $confs_ref->{backgroundimage};
  } else {
    $treeViewOpts->{backgroundImage} = val_or_def($confs_ref, "backgroundimage", undef);
  }
  return;
}

#####################################################################################
# Usage         : _set_fonts($confs_ref)
# Purpose       : Set font family, size and encoding
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : If font is set in $confs_ref, it is used. Otherwise Arial is picked as a default font 
#                 on Windows and Helvetica on other OSes.
#                 Function also sets vlinefont, guifont and 
#                 guifont_small/small_bold/heading/fixed/default/bold/italic fonts.
# See Also      : set_config(), _set_font_encoding()
sub _set_fonts {
  my ($confs_ref) = @_;
  my $fontenc = _set_font_encoding();
  if (exists($confs_ref->{'font'})) {
    $font = $confs_ref->{'font'};
    # substitute -*-* at the end of $confs_ref->{font} with -$fontenc
    $font =~ s/-\*-\*$/-$fontenc/;
  } else {
    if ($^O =~ /^MS/) {
      $font = 'family:Arial,size:10';
    } elsif ($fontenc eq 'iso10646-1') {
      $font = '{Arial Unicode Ms} 10';
      #$font = '-*-arial unicode ms-medium-r-normal-*-12-*-*-*-*-*-iso10646-1';
    } else {
      $font = '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-' . $fontenc;
    }
  }
  # print "USING FONT $font\n";
  
  $vLineFont        = val_or_def($confs_ref, "vlinefont", $font);
  $guiFont          = val_or_def($confs_ref, "guifont", undef);
  
  # set up various gui fonts
  for my $name (qw(small small_bold heading fixed default bold italic)) {
    $c_fonts{$name} = val_or_def($confs_ref, "guifont_" . $name, undef);
  }
  return;
}

#####################################################################################
# Usage         : _set_font_encoding()
# Purpose       : Choose font encoding according to Tk version and TrEd::Convert::outputenc
# Returns       : Font encoding
# Parameters    : 
# Throws        : nothing
# Comments      : If $TrEd::Convert::outputenc is set, it is used, otherwise iso8859-2 is used 
#                 with Tk versions older than 804, iso10646-1 for newer versions
# See Also      : set_config(), _set_font_encoding()
sub _set_font_encoding {
  my $fontenc = $TrEd::Convert::outputenc
    || ((defined($Tk::VERSION) and $Tk::VERSION < 804) ?  "iso-8859-2" : "iso-10646-1");
  $fontenc =~ s/^iso-/iso/;
  return $fontenc;
}

#####################################################################################
# Usage         : _set_resource_path($confs_ref, $default_share_path)
# Purpose       : ...
# Returns       : ...
# Parameters    : hash_ref $confs_ref         -- hash with configuration options
#                 scalar $default_share_path  -- share path
# Throws        : nothing
# Comments      : 
# See Also      : set_config(), _set_font_encoding()
sub _set_resource_path {
  my ($confs_ref, $def_share_path) = @_;
  
  my $resourcePathSplit = ($^O eq "MSWin32") ? ',' : ':';
  
  my $def_res_path  = $def_share_path =~ m{/share/tred$} ? $def_share_path : File::Spec->catdir($def_share_path,'resources');
  $def_res_path = tilde_expand(q(~/.tred.d)) . $resourcePathSplit . $def_res_path ;
  my @r = split $resourcePathSplit, $Treex::PML::resourcePath;
  my $r;
  if (exists($confs_ref->{resourcepath})) {
    my $path = 
      join($resourcePathSplit, map { tilde_expand($_) } split(/\Q$resourcePathSplit\E/, $confs_ref->{resourcepath}));
    if ($path =~ /^\Q$resourcePathSplit\E/) {
      $path = $def_res_path . $path;
    } elsif ($path =~ /\Q$resourcePathSplit\E$/) {
      $path .= $def_res_path;
    }
    $r = $path;
  } else {
    $r = $def_res_path;
  }
  #TODO: whats with the comma?
  unshift @r, split($resourcePathSplit, $r),
  my %r;
  $Treex::PML::resourcePath = join $resourcePathSplit, grep { defined and length } map { exists($r{$_}) ? () : ($r{$_}=$_) } @r;
}

sub _set_print_options {
  my ($confs_ref) = @_;
  for my $opt (keys %defaultPrintConfig) {
    $printOptions->{$opt} = val_or_def($confs_ref,lc($opt),$defaultPrintConfig{$opt}[1]);
  }
  {
    my $psFontFile = $printOptions->{psFontFile};
    my $psFontAFMFile = $printOptions->{psFontAFMFile};
    if (defined $psFontFile and length $psFontFile) {
      $psFontFile = tilde_expand($psFontFile);
      if (not -f $psFontFile and -f "$libDir/".$psFontFile) {
        $psFontFile = "$libDir/".$psFontFile;
      }
    } else {
      if (!defined($Tk::VERSION) or $Tk::VERSION >= 804) {
        $psFontFile="$libDir/fonts/n019003l.pfa";
      } else {
        $psFontFile="$libDir/fonts/ariam___.pfa";
      }
    }
    if (defined $psFontAFMFile and length $psFontAFMFile) {
      $psFontAFMFile=tilde_expand($psFontAFMFile);
      if (not -f $psFontAFMFile and -f "$libDir/".$psFontAFMFile) {
        $psFontAFMFile="$libDir/".$psFontAFMFile;
      }
    } else {
      $psFontAFMFile=$psFontFile;
      $psFontAFMFile=~s/\.[^.]+$/.afm/;
      if (!(-f $psFontAFMFile)) {
        $psFontAFMFile=~s!/([^/]+)$!/afm/$1!;
      }
    }
    $printOptions->{psFontFile}=$psFontFile;
    $printOptions->{psFontAFMFile}=$psFontAFMFile;
  }
  {
    my $ttFontPath = $printOptions->{ttFontPath};
    if (defined $ttFontPath and length $ttFontPath) {
      $ttFontPath = tilde_expand($confs_ref->{ttfontpath});
      $ttFontPath = "$libDir/".$ttFontPath if (not -d $ttFontPath and -d "$libDir/".$ttFontPath);
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
}

sub _set_extension_dirs {
  my ($confs_ref, $def_share_path) = @_;
  $extensionsDir  = File::Spec->rel2abs(tilde_expand(length($confs_ref->{extensionsdir})
                  ? $confs_ref->{extensionsdir} : '~/.tred.d/extensions'),
                    Cwd::cwd());
                    
  $extensionRepos = val_or_def($confs_ref,'extensionrepos','http://ufal.mff.cuni.cz/~pajas/tred/extensions');
  
  $preinstalledExtensionsDir =  length($confs_ref->{preinstalledextensionsdir})   ? tilde_expand($confs_ref->{preinstalledextensionsdir})
                             :  $def_share_path =~ m{/share/tred$}                ? $def_share_path.'-extensions'
                             :                                                      File::Spec->catdir($def_share_path,'tred-extensions')
                             ;
  
}

#####################################################################################
# Usage         : set_config($confs_ref)
# Purpose       : Set configuration values to values in $confs_ref hash (if defined) or to default values
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : 
# See Also      : apply_config(), read_config()
sub set_config {
  my ($confs_ref) = @_;

  # options specified on (b/n)tred's command line
  _parse_cmdline_options($confs_ref);

  $appName                    = val_or_def($confs_ref, "appname", "TrEd ver. ".$main::VERSION);
  if (!exists($ENV{PML_COMPILE})) {
    $ENV{PML_COMPILE}         = val_or_def($confs_ref, "pml_compile", 0);
  }

  $buttonsRelief              = val_or_def($confs_ref, "buttonsrelief", 'flat');
  $menubarRelief              = val_or_def($confs_ref, "menubarrelief", 'flat');
  $buttonBorderWidth          = val_or_def($confs_ref, "buttonsborder", 2);
  $canvasBalloonInitWait      = val_or_def($confs_ref, "hintwait", 1000);
  $canvasBalloonForeground    = val_or_def($confs_ref, "hintforeground", 'black');
  $canvasBalloonBackground    = val_or_def($confs_ref, "hintbackground", '#fff3b0');
  $toolbarBalloonInitWait     = val_or_def($confs_ref, "toolbarhintwait", 450);
  $toolbarBalloonForeground   = val_or_def($confs_ref, "toolbarhintforeground", 'black');
  $toolbarBalloonBackground   = val_or_def($confs_ref, "toolbarhintbackground", '#fff3b0');

  $activeTextColor            = val_or_def($confs_ref, "activetextcolor", 'blue');
  $stippleInactiveWindows     = val_or_def($confs_ref, "stippleinactivewindows", 1);

  $highlightWindowColor       = val_or_def($confs_ref, "highlightwindowcolor", 'black');
  $highlightWindowWidth       = val_or_def($confs_ref, "highlightwindowwidth", 3);

  $valueLineHeight            = val_or_def($confs_ref, "vlineheight",           
                                  defined($valueLineHeight)           ? $valueLineHeight          : 2);
  $valueLineAlign             = val_or_def($confs_ref, "vlinealign",            
                                  defined($valueLineAlign)            ? $valueLineAlign           : 'left');
  $valueLineWrap              = val_or_def($confs_ref, "vlinewrap",
                                  defined($valueLineWrap)             ? $valueLineWrap            : 'word');
  $valueLineReverseLines      = val_or_def($confs_ref, "vlinereverselines",
                                  defined($valueLineReverseLines)     ? $valueLineReverseLines    : 0);
  $valueLineFocusForeground   = val_or_def($confs_ref, "vlinefocusforeground",
                                  defined($valueLineFocusForeground)  ? $valueLineFocusForeground : 'black');
  $valueLineForeground        = val_or_def($confs_ref, "vlineforeground",
                                  defined($valueLineForeground)       ? $valueLineForeground      : 'black');
  $valueLineFocusBackground   = val_or_def($confs_ref, "vlinefocusbackground",
                                  defined($valueLineFocusBackground)  ? $valueLineFocusBackground : 'yellow');
  $valueLineBackground        = val_or_def($confs_ref, "vlinebackground",
                                  defined($valueLineBackground)       ? $valueLineBackground      : 'white');
  
  # Set encoding and text orientation
  $TrEd::Convert::inputenc    = val_or_def($confs_ref, "defaultfileencoding",         $TrEd::Convert::inputenc);
  $TrEd::Convert::outputenc   = val_or_def($confs_ref, "defaultdisplayencoding",      $TrEd::Convert::outputenc);
  $TrEd::Convert::lefttoright = val_or_def($confs_ref, "displaynonasciilefttoright",  $TrEd::Convert::lefttoright);
  
  # Set font and its encoding
  _set_fonts($confs_ref);
  
  # Set libdir and perllib
  if ($confs_ref->{perllib}) {
    foreach my $perllib (split/\:/, $confs_ref->{perllib}) {
      $perllib = tilde_expand($perllib);
      if (!(grep($_ eq $perllib, @INC))) {
        unshift(@INC, $perllib);
      }
    }
  }
  if (exists $confs_ref->{libdir}) {
    $libDir = tilde_expand($confs_ref->{libdir});
  }
  if ($libDir) {
    if (!(grep($_ eq $libDir, @INC))) {
      unshift(@INC, $libDir);
    }
  }
  
  my $def_share_path = $libDir;
  #TODO: $^O never equals Win32, it can be MSWin32, though
  if ($^O eq 'Win32') {
    $def_share_path =~ s/[\\\/](?:lib[\\\/]tred|tredlib)$//;
  } else {
    if (!($def_share_path =~ s{/lib/tred$}{/share/tred})) {
      $def_share_path =~ s/\/(?:tredlib)$//;
    }
  }
  
  _set_extension_dirs($confs_ref, $def_share_path);
  
  _set_resource_path($confs_ref, $def_share_path);
  
  _set_treeViewOpts($confs_ref);

  $appIcon                        = (exists $confs_ref->{appicon})          ? tilde_expand($confs_ref->{appicon})           : "$libDir/tred.xpm";
  $iconPath                       = (exists $confs_ref->{iconpath})         ? tilde_expand($confs_ref->{iconpath})          : "$libDir/icons/crystal";
  $macroFile                      = (exists $confs_ref->{macrofile})        ? tilde_expand($confs_ref->{macrofile})         : undef;
  $default_macro_file             = (exists $confs_ref->{defaultmacrofile}) ? tilde_expand($confs_ref->{defaultmacrofile})  : "$libDir/tred.def";
  $default_macro_encoding         = val_or_def($confs_ref,"defaultmacroencoding",'utf8');
  $sortAttrs                      = val_or_def($confs_ref,"sortattributes",1);
  $sortAttrValues                 = val_or_def($confs_ref,"sortattributevalues",1);
  
  _set_print_options();
  
  $createMacroMenu                = val_or_def($confs_ref,"createmacromenu",0);
  $maxMenuLines                   = val_or_def($confs_ref,"maxmenulines",20);
  $useCzechLocales                = val_or_def($confs_ref,"useczechlocales",0);
  $useLocales                     = val_or_def($confs_ref,"uselocales",0);
  $Tk::strictMotif                = val_or_def($confs_ref,"strictmotif",0);
  $imageMagickConvert             = val_or_def($confs_ref,"imagemagickconvert",'convert');
  $NoConvertWarning               = val_or_def($confs_ref,"noconvertwarning",0);

  $Treex::PML::IO::reject_proto   = val_or_def($confs_ref,'rejectprotocols','^(pop3?s?|imaps?)\$');
  $Treex::PML::IO::gzip           = val_or_def($confs_ref,"gzip",find_exe("gzip"));
  if (!$Treex::PML::IO::gzip and -x "$libDir/../gzip") {
    $Treex::PML::IO::gzip = "$libDir/../bin/gzip";
  }
  $Treex::PML::IO::gzip_opts      = val_or_def($confs_ref,"gzipopts", "-c");
  $Treex::PML::IO::zcat           = val_or_def($confs_ref,"zcat", find_exe("zcat"));
  $Treex::PML::IO::zcat_opts      = val_or_def($confs_ref,"zcatopts", undef);
  $Treex::PML::IO::ssh            = val_or_def($confs_ref,"ssh", undef);
  $Treex::PML::IO::ssh_opts       = val_or_def($confs_ref,"sshopts", undef);
  $Treex::PML::IO::kioclient      = val_or_def($confs_ref,"kioclient", undef);
  $Treex::PML::IO::kioclient_opts = val_or_def($confs_ref,"kioclientopts", undef);
  $Treex::PML::IO::curl           = val_or_def($confs_ref,"curl", undef);
  $Treex::PML::IO::curl_opts      = val_or_def($confs_ref,"curlopts", undef);
  if (!$Treex::PML::IO::zcat) {
    if ($Treex::PML::IO::gzip) {
      $Treex::PML::IO::zcat = $Treex::PML::IO::gzip;
      $Treex::PML::IO::zcat_opts = '-d';
    } elsif (-x "$libDir/../zcat") {
      $Treex::PML::IO::zcat = "$libDir/../bin/zcat";
    }
  }
  $cstsToFs                   = val_or_def($confs_ref,"cststofs",undef);
  $fsToCsts                   = val_or_def($confs_ref,"fstocsts",undef);

  $sgmls                      = val_or_def($confs_ref,"sgmls","nsgmls");
  $sgmlsopts                  = val_or_def($confs_ref,"sgmlsopts","-i preserve.gen.entities");
  $cstsdoctype                = val_or_def($confs_ref,"cstsdoctype",undef);
  $cstsparsecommand           = val_or_def($confs_ref,"cstsparsercommand","\%s \%o \%d \%f");

  $Treex::PML::Backends::CSTS::sgmls=$sgmls;
  $Treex::PML::Backends::CSTS::sgmlsopts=$sgmlsopts;
  $Treex::PML::Backends::CSTS::doctype=$cstsdoctype;
  $Treex::PML::Backends::CSTS::sgmls_command=$cstsparsecommand;

  $keyboardDebug              = val_or_def($confs_ref,"keyboarddebug",0);
  $hookDebug                  = val_or_def($confs_ref,"hookdebug",0);
  $macroDebug                 = val_or_def($confs_ref,"macrodebug",0);
  $tredDebug                  = val_or_def($confs_ref,"treddebug",$tredDebug);
  $Treex::PML::Debug          = val_or_def($confs_ref,"backenddebug",$Treex::PML::Debug);
  $defaultTemplateMatchMethod = val_or_def($confs_ref,"searchmethod",'R');
  $defaultMacroListOrder      = val_or_def($confs_ref,"macrolistorder",'M');
  $defCWidth                  = val_or_def($confs_ref,"canvaswidth",'18c');
  $defCHeight                 = val_or_def($confs_ref,"canvasheight",'12c');
  $geometry                   = val_or_def($confs_ref,"geometry",undef);
  $showSidePanel              = val_or_def($confs_ref,"showsidepanel",undef);
  $maxDisplayedValues         = val_or_def($confs_ref,"maxdisplayedvalues",25);
  $maxDisplayedAttributes     = val_or_def($confs_ref,"maxdisplayedattributes",20);
  $lastAction                 = val_or_def($confs_ref,"lastaction",undef);

  $maxUndo                    = val_or_def($confs_ref,"maxundo",30);
  $reloadKeepsPatterns        = val_or_def($confs_ref,"reloadpreservespatterns",1);
  $autoSave                   = val_or_def($confs_ref,"autosave",5);
  $displayStatusLine          = val_or_def($confs_ref,"displaystatusline",1);
  $openFilenameCommand        = val_or_def($confs_ref,"openfilenamecommand",undef);
  $saveFilenameCommand        = val_or_def($confs_ref,"savefilenamecommand",undef);
  $lockFiles                  = val_or_def($confs_ref,"lockfiles",1);
  $noLockProto                = val_or_def($confs_ref,"nolockprotocols",'^(https?|zip|tar)$');
  $ioBackends                 = val_or_def($confs_ref,"iobackends",undef);
  $htmlBrowser                = val_or_def($confs_ref,"htmlbrowser",undef);

  $skipStartupVersionCheck    = val_or_def($confs_ref,"skipstartupversioncheck",undef);
  $enableTearOff              = val_or_def($confs_ref,"enabletearoff",0);

  $sidePanelWrap              = val_or_def($confs_ref,"sidepanelwrap",0);
  # ADD NEW OPTIONS HERE

  &$set_user_config($confs_ref) if (ref($set_user_config)); # let this be the very last line
  {
    no strict qw(vars refs);
    foreach (keys %$confs_ref) {
      if (/::/) {
	${"$_"}=$confs_ref->{$_};
      }
    }
  }
  return;
}

1;

__END__

=head1 NAME


TrEd::Config - ...


=head1 VERSION

This documentation refers to 
TrEd::Config version 0.x.


=head1 SYNOPSIS

  use TrEd::Config;
    
  

=head1 DESCRIPTION



=head1 SUBROUTINES/METHODS

=over 4 




=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES



=head1 INCOMPATIBILITIES



=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .
