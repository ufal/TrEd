package TrEd::Config;

#
# $Id$ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

BEGIN {
  use Exporter  ();
#  use Tk;			# Tk::strictMotif
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK @config_file_search_list $quiet);
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
  $psFontAFMFile
  $ttFont
  $ttFontPath
  $appIcon
  $sortAttrs
  $psFontSize
  $macroFile
  $defaultMacroFile
  $defaultMacroEncoding
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
  $useLocales
  $printColors
  $defaultPrintCommand
  $imageMagickConvert
  $cstsToFs
  $fsToCsts
  $gzip
  $zcat
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
);
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
  my ($a)=@_;
  $a=~s/^\~/$ENV{HOME}/;
  $a=~s/([^\\])\~/$1$ENV{HOME}/g;
  return $a;
}

sub parse_config_line {
  local $_=shift;
  my $confs=shift;
  my $key;
  unless (/^[;\#]/ or /^$/) {
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
      print STDERR "Using resource file $f\n" unless $quiet;
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

  $appName=val_or_def($confs,"appname","TrEd ver. ".$main::VERSION);
  $buttonsRelief=val_or_def($confs,"buttonsrelief",'flat');
  $menubarRelief=val_or_def($confs,"menubarrelief",'flat');
  $buttonBorderWidth=val_or_def($confs,"buttonsborder",2);
  $canvasBalloonInitWait=val_or_def($confs,"hintwait",1000);
  $activeTextColor=val_or_def($confs,"activetextcolor",'blue');

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

  $treeViewOpts->{baseXPos}	      =	 val_or_def($confs,"basexpos",15);
  $treeViewOpts->{baseYPos}	      =	 val_or_def($confs,"baseypos",15);
  $treeViewOpts->{nodeWidth}	      =	 val_or_def($confs,"nodewidth",7);
  $treeViewOpts->{nodeHeight}	      =	 val_or_def($confs,"nodeheight",7);
  $treeViewOpts->{useAdditionalEdgeLabelSkip}
                                      =
					 val_or_def($confs,"useadditionaledgelabelskip",1);
  $treeViewOpts->{currentNodeWidth}   =	 val_or_def($confs,"currentnodewidth",$treeViewOpts->{nodeWidth});
  $treeViewOpts->{currentNodeHeight}  =	 val_or_def($confs,"currentnodeheight",$treeViewOpts->{nodeHeight});
  $treeViewOpts->{nodeXSkip}	      =	 val_or_def($confs,"nodexskip",10);
  $treeViewOpts->{nodeYSkip}	      =	 val_or_def($confs,"nodeyskip",10);
  $treeViewOpts->{edgeLabelSkipAbove} =	 val_or_def($confs,"edgelabelskipabove",10);
  $treeViewOpts->{edgeLabelSkipBelow} =	 val_or_def($confs,"edgelabelskipbelow",10);
  $treeViewOpts->{xmargin}	      =	 val_or_def($confs,"xmargin",2);
  $treeViewOpts->{ymargin}	      =	 val_or_def($confs,"ymargin",2);
  $treeViewOpts->{lineWidth}	      =	 val_or_def($confs,"linewidth",1);
  $treeViewOpts->{lineColor}	      =	 val_or_def($confs,"linecolor",'black');
  $treeViewOpts->{hiddenLineColor}    =	 val_or_def($confs,"hiddenlinecolor",'gray');
  $treeViewOpts->{dashHiddenLines}    =	 val_or_def($confs,"dashhiddenlines",0);
  $treeViewOpts->{lineArrow}	      =	 val_or_def($confs,"linearrow",'none');
  $treeViewOpts->{nodeColor}	      =	 val_or_def($confs,"nodecolor",'yellow');
  $TrEd::Print::bwModeNodeColor	      =	 val_or_def($confs,"bwprintnodecolor",'white');
  $treeViewOpts->{nodeOutlineColor}   =	 val_or_def($confs,"nodeoutlinecolor",'black');
  $treeViewOpts->{hiddenNodeColor}    =	 val_or_def($confs,"hiddennodecolor",'black');
  # $activeNodeColor		      =	 val_or_def($confs,"activenodecolor",'blue');
  $treeViewOpts->{currentNodeColor}   =	 val_or_def($confs,"currentnodecolor",'red');
  $treeViewOpts->{nearestNodeColor}   =	 val_or_def($confs,"nearestnodecolor",'green');
  $treeViewOpts->{textColor}	      =	 val_or_def($confs,"textcolor",'black');
  $treeViewOpts->{textColorShadow}    =	 val_or_def($confs,"textcolorshadow",'darkgrey');
  $treeViewOpts->{textColorHilite}    =	 val_or_def($confs,"textcolorhilite",'darkgreen');
  $treeViewOpts->{textColorXHilite}   =	 val_or_def($confs,"textcolorxhilite",'darkred');

  foreach (0..9) {
    $treeViewOpts->{customColors}->[$_]=$confs->{"customcolor$_"} if $confs->{"customcolor$_"};
  }

  $treeViewOpts->{boxColor}	       = val_or_def($confs,"boxcolor",'LightYellow');
  $treeViewOpts->{currentBoxColor}     = val_or_def($confs,"currentboxcolor",'yellow');
  $treeViewOpts->{hiddenBoxColor}      = val_or_def($confs,"hiddenboxcolor",'gray');

  $treeViewOpts->{edgeBoxColor}	       = val_or_def($confs,"edgeboxcolor",'#fff0e0');
  $treeViewOpts->{currentEdgeBoxColor} = val_or_def($confs,"edgecurrentboxcolor",'#ffe68c');
  $treeViewOpts->{hiddenEdgeBoxColor}  = val_or_def($confs,"edgehiddenboxcolor","DarkGrey");

  $treeViewOpts->{clearTextBackground} = val_or_def($confs,"cleartextbackground",1);

  $treeViewOpts->{backgroundColor}     = val_or_def($confs,"backgroundcolor",undef);


  $treeViewOpts->{backgroundImageX}     = val_or_def($confs,"backgroundimagex",0);
  $treeViewOpts->{backgroundImageY}     = val_or_def($confs,"backgroundimagey",0);
  $treeViewOpts->{noColor}	       = val_or_def($confs,"allowcustomcolors",0);
  $treeViewOpts->{drawBoxes}	       = val_or_def($confs,"drawboxes",0);
  $treeViewOpts->{drawEdgeBoxes}       = val_or_def($confs,"drawedgeboxes",0);
  $treeViewOpts->{highlightAttributes} = val_or_def($confs,"highlightattributes",1);
  $treeViewOpts->{showHidden} = val_or_def($confs,"showhiddne",0);;

  $TrEd::Convert::inputenc = val_or_def($confs,"defaultfileencoding",$TrEd::Convert::inputenc);
  $TrEd::Convert::outputenc = val_or_def($confs,"defaultdisplayencoding",$TrEd::Convert::outputenc);
  $TrEd::Convert::lefttoright = val_or_def($confs,"displaynonasciilefttoright",$TrEd::Convert::lefttoright);

  my $fontenc=$TrEd::Convert::outputenc
    || ($Tk::VERSION >= 804 and "iso-10646-1")  || "iso-8859-2";
  $fontenc=~s/^iso-/iso/;

  if (exists $confs->{font}) {
    $font=$confs->{font};
    $font=~s/-\*-\*$/-$fontenc/;
  } else {
    if ($^O=~/^MS/) { $font='family:Arial,size:10' }
    elsif ($fontenc eq 'iso10646-1') {
      $font='-*-arial unicode ms-medium-r-normal-*-12-*-*-*-*-*-iso10646-1'
    } else {
      $font='-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-'.$fontenc;
    }
  }
  # print "USING FONT $font\n";
  $treeViewOpts->{font}=$font;
  $vLineFont=val_or_def($confs,"vlinefont",$font);
  $type1font=(exists $confs->{type1font}) ? $confs->{type1font} :
    (($^O=~/^MS/) ? $font : '-*-helvetica-medium-r-*-*-*-*-*-*-*-*-'.$fontenc);

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
#  if (exists $confs->{ttfontfile}) {
#    $ttFontFile=tilde_expand($confs->{ttfontfile});
#    $ttFontFile="$libDir/".$ttFontFile if (not -f $ttFontFile and -f "$libDir/".$ttFontFile);
#  }
  $ttFont=val_or_def($confs,"ttfont","Arial");
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
	push @fontpath,$1 if m{<dir>([^<]*)</dir>} and -d $1;
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
  if (exists $confs->{ttfontpath}) {
    $ttFontPath=tilde_expand($confs->{ttfontpath});
  } else {
    $ttFontPath = join ",",map tilde_expand($_),@fontpath;
  }

#  while (not(defined($ttFontFile) or -f $ttFontFile) and @fontpath) {
#    $ttFontFile = $fontpath[0]."arial.ttf" if -f $fontpath[0]."arial.ttf";
#    shift @fontpath;
#  }

  if (exists $confs->{psfontafmfile}) {
    $psFontAFMFile=$confs->{psfontafmfile};
  } else {
    $psFontAFMFile=$psFontFile;
    $psFontAFMFile=~s/\.[^.]+$/.afm/;
    unless (-f $psFontAFMFile) {
      $psFontAFMFile=~s!/([^/]+)$!/afm/$1!;
    }
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
  $macroFile=tilde_expand($confs->{macrofile}) if (exists $confs->{macrofile});
  $defaultMacroFile=(exists $confs->{defaultmacrofile}) ? tilde_expand($confs->{defaultmacrofile}) : "$libDir/tred.def";
  $defaultMacroEncoding=val_or_def($confs,"defaultmacroencoding",'utf8');
  $sortAttrs	     =	val_or_def($confs,"sortattributes",1);
  $psFontSize	     =	val_or_def($confs,"psfontsize",($^O=~/^MS/) ? "14" : "12");

  $prtFmtWidth	     =	val_or_def($confs,"prtfmtwidth",'595');
  $prtFmtHeight	     =	val_or_def($confs,"prtfmtheight",'842');
  $prtVMargin	     =	val_or_def($confs,"prtvmargin",'3c');
  $prtHMargin	     =	val_or_def($confs,"prthmargin",'2c');

  $psMedia	     =	val_or_def($confs,"psmedia",'A4');
  $psFile=(exists $confs->{psfile}) ? tilde_expand($confs->{psfile}) : 'tred.ps';

  $maximizePrintSize  =	 val_or_def($confs,"maximizeprintsize",0);
  $createMacroMenu    =	 val_or_def($confs,"createmacromenu",0);
  $maxMenuLines	      =	 val_or_def($confs,"maxmenulines",20);
  $useCzechLocales    =	 val_or_def($confs,"useczechlocales",($^O !~ /^MS/));
  $useLocales         =	 val_or_def($confs,"uselocales",0);
  $Tk::strictMotif    =	 val_or_def($confs,"strictmotif",0);
  $printColors	      =	 val_or_def($confs,"printcolors",0);
  $defaultPrintCommand = val_or_def($confs,"defaultprintcommand",
				    ($^O eq 'MSWin32') ? 'prfile32.exe /-' : 'lpr'
				   );
  $imageMagickConvert = val_or_def($confs,"imagemagickconvert",'convert');

  $gzip=val_or_def($confs,"gzip",(-x "/bin/gzip" ? "/bin/gzip -c" :
				  (-x "$libDir/../gzip" ? 
				   "$libDir/../bin/gzip -c" : undef)));
  $zcat=val_or_def($confs,"zcat",(-x "/bin/zcat" ? "/bin/zcat" :
				  (-x "$libDir/../gzip" ?
				   "$libDir/../bin/gzip -c" : "$gzip -d")));

  $ZBackend::gzip = $gzip;
  $ZBackend::zcat = $zcat;

  $cstsToFs = val_or_def($confs,"cststofs",undef);
  $fsToCsts = val_or_def($confs,"fstocsts",undef);

  $CSTSBackend::gzip = $gzip;
  $CSTSBackend::zcat = $zcat;
  $CSTSBackend::csts2fs=$cstsToFs;
  $CSTSBackend::fs2csts=$fsToCsts;

  $sgmls       = val_or_def($confs,"sgmls","nsgmls");
  $sgmlsopts   = val_or_def($confs,"sgmlsopts","-i preserve.gen.entities");
  $cstsdoctype = val_or_def($confs,"cstsdoctype","$libDir/csts.doctype");
  $cstsparsecommand = val_or_def($confs,"cstsparsercommand","\%s \%o \%d \%f");
  $cstsparsezcommand = val_or_def($confs,"cstsparserzcommand","\%z < \%f | \%s \%o \%d -");

  $CSTS_SGML_SP_Backend::gzip=$gzip;
  $CSTS_SGML_SP_Backend::zcat=$zcat;
  $CSTS_SGML_SP_Backend::sgmls=$sgmls;
  $CSTS_SGML_SP_Backend::sgmlsopts=$sgmlsopts;
  $CSTS_SGML_SP_Backend::doctype=$cstsdoctype;
  $CSTS_SGML_SP_Backend::sgmls_command=$cstsparsecommand;
  $CSTS_SGML_SP_Backend::z_sgmls_command=$cstsparsezcommand;

  $keyboardDebug	      =	val_or_def($confs,"keyboarddebug",0);
  $hookDebug		      =	val_or_def($confs,"hookdebug",0);
  $macroDebug		      =	val_or_def($confs,"macrodebug",0);
  $tredDebug		      =	val_or_def($confs,"treddebug",0);
  $Fslib::Debug               = val_or_def($confs,"backenddebug",0);
  $defaultTemplateMatchMethod =	val_or_def($confs,"searchmethod",'Exhaustive regular expression');
  $defaultMacroListOrder      =	val_or_def($confs,"macrolistorder",'M');
  $defCWidth		      =	val_or_def($confs,"canvaswidth",'18c');
  $defCHeight		      =	val_or_def($confs,"canvasheight",'12c');
  $geometry		      =	val_or_def($confs,"geometry",undef);
  $maxDisplayedValues	      =	val_or_def($confs,"maxdisplayedvalues",25);
  $maxDisplayedAttributes     =	val_or_def($confs,"maxdisplayedattributes",20);
  $lastAction		      =	val_or_def($confs,"lastaction",undef);

  &$set_user_config($confs) if (ref($set_user_config));
  $maxUndo		      =	val_or_def($confs,"maxundo",30);
  $reloadKeepsPatterns	      =	val_or_def($confs,"reloadpreservespatterns",1);
  $autoSave	              =	val_or_def($confs,"autosave",5);
  $displayStatusLine          =	val_or_def($confs,"displaystatusline",0);
}

1;
