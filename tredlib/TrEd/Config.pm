package TrEd::Config;

#
# $Revision$ '
# Time-stamp: <2001-07-23 12:45:23 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

BEGIN {
  use Exporter  ();
  use Tk;			# Tk::strictMotif
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK @config_file_search_list);
  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(@config_file_search_list $set_user_config
  $appName
  $buttonsRelief
  $menubarRelief
  $buttonBorderWidth
  $canvasBalloonInitWait
  $activeTextColor
  $treeViewOpts
  $font
  $vLineFont
  $type1font
  $libDir
  $psFontFile
  $appIcon
  $sortAttrs
  $psFontName
  $psFontSize
  $macroFile
  $defaultMacroFile
  $prtFmtWidth
  $prtFmtHeight
  $prtVMargin
  $prtHMargin
  $psMedia
  $psFile
  $maximizePrintSize
  $showHidden
  $createMacroMenu
  $maxMenuLines
  $useCzechLocales
  $printColors
  $cstsToFs
  $fsToCsts
  $gzip
  $zcat
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
  $lastAction);
  @EXPORT_OK=qw(&tilde_expand &read_config &set_config &parse_config_line &apply_config &set_default_config_file_search_list);

  use strict;

  @config_file_search_list=();
}

sub set_default_config_file_search_list {
  require FindBin;
  @config_file_search_list=
    ($ENV{HOME}.'/.tredrc',
     (exists $ENV{TREDHOME}) ? $ENV{TREDHOME}.'/tredrc' : (),
     "$FindBin::RealBin/tredrc",
     "$FindBin::RealBin/../lib/tredlib/tredrc",
     "$FindBin::RealBin/tredlib/tredrc",
     "$FindBin::RealBin/../lib/tred/tredrc",
     '/usr/usr/share/config/tredrc');
}

sub tilde_expand {
  my $a=shift;
  $a=~s/$\~/$ENV{HOME}/;
  $a=~s/([^\\])\~/$1$ENV{HOME}/g;
  return $a;
}

sub parse_config_line {
  local $_=shift;
  my $confs=shift;
  my $key;
  unless (/^[;#]/ or /^$/) {
    chomp;
    if (/^\s*([a-zA-Z_]+[a-zA-Z_0-9]*)\s*=\s*('(?:[^\\']|\\.)*'|"(?:[^\\"]|\\.)*"|(?:\s*(?:[^;\\\s]|\\.)+)*)/) {
      $key=lc($1);
      $confs->{$key}=$2;
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
      print STDERR "Using resource file $f\n";
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
      "         Using configuration defaults!\n";
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

sub set_config {
  my ($confs)=@_;

  $appName=(exists $confs->{appname}) ? $confs->{appname} : "TrEd ver. 0.5";
  $buttonsRelief=(exists $confs->{buttonsrelief}) ? $confs->{buttonsrelief} : 'flat';
  $menubarRelief=(exists $confs->{menubarrelief}) ? $confs->{menubarrelief} : 'flat';
  $buttonBorderWidth=(exists $confs->{buttonsborder}) ? $confs->{buttonsborder} : 2;
  $canvasBalloonInitWait=(exists $confs->{hintwait}) ? $confs->{hintwait} : 1000;
  $activeTextColor=(exists $confs->{activetextcolor}) ? $confs->{activetextcolor} : 'blue';

  $treeViewOpts->{baseXPos}=(exists $confs->{basexpos}) ? $confs->{basexpos} : 15;
  $treeViewOpts->{baseYPos}=(exists $confs->{baseypos}) ? $confs->{baseypos} : 15;
  $treeViewOpts->{nodeWidth}=(exists $confs->{nodewidth}) ? $confs->{nodewidth} : 7;
  $treeViewOpts->{nodeHeight}=(exists $confs->{nodeheight}) ? $confs->{nodeheight} : 7;
  $treeViewOpts->{currentNodeWidth}=(exists $confs->{currentnodewidth}) ? $confs->{currentnodewidth} : $nodeWidth;
  $treeViewOpts->{currentNodeHeight}=(exists $confs->{currentnodeheight}) ? $confs->{currentnodeheight} : $nodeHeight;
  $treeViewOpts->{nodeXSkip}=(exists $confs->{nodexskip}) ? $confs->{nodexskip} : 5;
  $treeViewOpts->{nodeYSkip}=(exists $confs->{nodeyskip}) ? $confs->{nodeyskip} : 10;
  $treeViewOpts->{xmargin}=(exists $confs->{xmargin}) ? $confs->{xmargin} : 2;
  $treeViewOpts->{ymargin}=(exists $confs->{ymargin}) ? $confs->{ymargin} : 2;
  $treeViewOpts->{lineWidth}=(exists $confs->{linewidth}) ? $confs->{linewidth} : 1;
  $treeViewOpts->{lineColor}=(exists $confs->{linecolor}) ? $confs->{linecolor} : 'black';
  $treeViewOpts->{lineArrow}=(exists $confs->{linearrow}) ? $confs->{linearrow} : 'none';
  $treeViewOpts->{nodeColor}=(exists $confs->{nodecolor}) ? $confs->{nodecolor} : 'yellow';
  $treeViewOpts->{nodeOutlineColor}=(exists $confs->{nodeoutlinecolor}) ? $confs->{nodeoutlinecolor} : 'black';
  $treeViewOpts->{hiddenNodeColor}=(exists $confs->{hiddennodecolor}) ? $confs->{hiddennodecolor} : 'black';
  # $activeNodeColor=(exists $confs->{activenodecolor}) ? $confs->{activenodecolor} : 'blue';
  $treeViewOpts->{currentNodeColor}=(exists $confs->{currentnodecolor}) ? $confs->{currentnodecolor} : 'red';
  $treeViewOpts->{nearestNodeColor}=(exists $confs->{nearestnodecolor}) ? $confs->{nearestnodecolor} : 'green';
  $treeViewOpts->{textColor}=(exists $confs->{textcolor}) ? $confs->{textcolor} : 'black';
  $treeViewOpts->{textColorShadow}=(exists $confs->{textcolorshadow}) ? $confs->{textcolorshadow} : 'darkgrey';
  $treeViewOpts->{textColorHilite}=(exists $confs->{textcolorhilite}) ? $confs->{textcolorhilite} : 'darkgreen';
  $treeViewOpts->{textColorXHilite}=(exists $confs->{textcolorxhilite}) ? $confs->{textcolorxhilite} : 'darkred';

  foreach (0..9) {
    $treeViewOpts->{customColors}->[$_]=$confs->{"customcolor$_"} if $confs->{"customcolor$_"};
  }

  $treeViewOpts->{boxColor}=(exists $confs->{boxcolor}) ? $confs->{boxcolor} : 'wheat';
  $treeViewOpts->{currentBoxColor}=(exists $confs->{currentboxcolor}) ? $confs->{currentboxcolor} : 'white';
  $treeViewOpts->{hiddenBoxColor}=(exists $confs->{hiddenboxcolor}) ? $confs->{hiddenboxcolor} : 'gray';
  $treeViewOpts->{backgroundColor}=(exists $confs->{backgroundcolor}) ? $confs->{backgroundcolor} : undef;
  $treeViewOpts->{noColor}=(exists $confs->{allowcustomcolors}) ? $confs->{allowcustomcolors} : 0;
  $treeViewOpts->{drawBoxes}=(exists $confs->{drawboxes}) ? $confs->{drawboxes} : 0;
  $treeViewOpts->{highlightAttributes}=(exists $confs->{highlightattributes}) ? $confs->{highlightattributes} : 1;
  $font=(exists $confs->{font}) ? $confs->{font} :
    (($^O=~/^MS/) ? 'family:Helvetica,size:10' : '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-iso8859-2');
  $treeViewOpts->{font}=$font;
  $vLineFont=(exists $confs->{vlinefont}) ? $confs->{vlinefont} : $font;
  $type1font=(exists $confs->{type1font}) ? $confs->{type1font} :
    (($^O=~/^MS/) ? $font : '-ult1mo-arial-medium-r-*-*-*-*-*-*-*-*-iso8859-2');

  $libDir=tilde_expand($confs->{libdir})
    if (exists $confs->{libdir});
  unshift @INC,$libDir unless (grep($_ eq $libDir, @INC));
  if (exists $confs->{psfontfile}) {
    $psFontFile=tilde_expand($confs->{psfontfile});
    $psFontFile="$libDir/".$psFontFile if (not -f $psFontFile and -f 
					   "$libDir/".$psFontFile);
  } else {
    $psFontFile="$libDir/fonts/ariam___.pfa";
  }
  $appIcon=(exists $confs->{appicon}) ? tilde_expand($confs->{appicon}) : "$libDir/tred.xpm";
  $sortAttrs=(exists $confs->{sortattributes}) ? $confs->{sortattributes} : 1;
  $psFontName=(exists $confs->{psfontname}) ? $confs->{psfontname} : "Arial-Medium";
  $psFontSize=(exists $confs->{psfontsize}) ? $confs->{psfontsize} : ($^O=~/^MS/) ? "14" : "12";
  $macroFile=tilde_expand($confs->{macrofile}) if (exists $confs->{macrofile});
  $defaultMacroFile=(exists $confs->{defaultmacrofile}) ? tilde_expand($confs->{defaultmacrofile}) : "$libDir/tred.def";
  $prtFmtWidth=(exists $confs->{prtfmtwidth}) ? $confs->{prtfmtwidth} : '21c';
  $prtFmtHeight=(exists $confs->{prtfmtheight}) ? $confs->{prtfmtheight} : '297m';
  $prtVMargin=(exists $confs->{prtvmargin}) ? $confs->{prtvmargin} : '3c';
  $prtHMargin=(exists $confs->{prthmargin}) ? $confs->{prthmargin} : '1c';
  $psMedia=(exists $confs->{psmedia}) ? $confs->{psmedia} : '%%DocumentMedia: A4 595 842 white()';
  $psFile=(exists $confs->{psfile}) ? tilde_expand($confs->{psfile}) : 'tred.ps';
  $maximizePrintSize=(exists $confs->{maximizeprintsize}) ? $confs->{maximizeprintsize} : 0;
  $showHidden=exists ($confs->{showhidden}) ? $confs->{showhidden} : 0;
  $createMacroMenu=(exists $confs->{createmacromenu}) ? $confs->{createmacromenu} : 0;
  $maxMenuLines=(exists $confs->{maxmenulines}) ? $confs->{maxmenulines} : 20;
  $useCzechLocales=(exists $confs->{useczechlocales}) ? $confs->{useczechlocales} : ($^O !~ /^MS/);
  $Tk::strictMotif=(exists $confs->{strictmotif}) ? $confs->{strictmotif} : 0;
  $printColors=(exists $confs->{printcolors}) ? $confs->{printcolors} : 0;
  $cstsToFs=(exists $confs->{cststofs}) ? $confs->{cststofs} : undef;
  $fsToCsts=(exists $confs->{fstocsts}) ? $confs->{fstocsts} : undef;
  $gzip=(exists $confs->{gzip}) ? $confs->{gzip} : (-x "/bin/gzip" ? "/bin/gzip -c" : undef);
  $zcat=(exists $confs->{zcat}) ? $confs->{zcat} : (-x "/bin/zcat" ? "/bin/zcat" : $gzip);
  $keyboardDebug=(exists $confs->{keyboarddebug}) ? $confs->{keyboarddebug} : 0;
  $hookDebug=(exists $confs->{hookdebug}) ? $confs->{hookdebug} : 0;
  $macroDebug=(exists $confs->{macrodebug}) ? $confs->{macrodebug} : 0;
  $tredDebug=(exists $confs->{treddebug}) ? $confs->{treddebug} : 0;
  $defaultTemplateMatchMethod=(exists $confs->{searchmethod}) ? $confs->{searchmethod} : 'Exhaustive regular expression';
  $defaultMacroListOrder=(exists $confs->{macrolistorder}) ? $confs->{macrolistorder} : 'M';
  $defCWidth=(exists $confs->{canvaswidth}) ? $confs->{canvaswidth} : '18c';
  $defCHeight=(exists $confs->{canvasheight}) ? $confs->{canvasheight} : '12c';
  $geometry=(exists $confs->{geometry}) ? $confs->{geometry} : undef;
  $maxDisplayedValues=(exists $confs->{maxdisplayedvalues}) ? $confs->{maxdisplayedvalues} : 30;
  $maxDisplayedAttributes=(exists $confs->{maxdisplayedattributes}) ? $confs->{maxdisplayedattributes} : 20;
  $lastAction=(exists $confs->{lastaction}) ? $confs->{lastaction} : undef;

  &$set_user_config($confs) if (ref($set_user_config));
}

1;
