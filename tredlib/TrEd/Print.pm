package TrEd::PSTreeView;
use TrEd::TreeView;
use base qw(TrEd::TreeView);
use PostScript::FontMetrics;

sub setFontMetrics {
  my ($self,$filename,$fontsize,$fontscale)=@_;
  $self->{psFontSize} = $fontsize;
  $self->{psFontScale} = $fontscale ? $fontscale : 1000;
  $self->{textWidthHash}={};
  $self->{psFontMetrics} = new PostScript::FontMetrics($filename);
  print STDERR "FONT SIZE: $self->{psFontSize}, $self->{psFontMetrics}\n";
  return $self->{psFontMetrics};
}

sub getFontHeight {
  my ($self)=@_;
  return 0 unless $self->{psFontMetrics};
  my $ascent=($self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[3])/1000;
  my $descent=-($self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[1])/1000;
  print STDERR "FONT HEIGHT: ".($ascent+$descent)."\n";
  return sprintf("%.0f",$ascent+$descent);
}

sub getTextWidth {
  my ($self,$text)=@_;
  return 0 unless $self->{psFontMetrics};
  my $width=$self->{textWidthHash}->{$text};
  if (!defined($width)) {
    $width=$self->{psFontMetrics}->stringwidth($text,$self->{psFontSize});
    print STDERR "WIDTH: $width\n";
    $self->{textWidthHash}->{$text}=$width;
    $self->{textWidthHashMiss}++;
  } else {
    print STDERR "HIT-WIDTH: $width\n";
    $self->{textWidthHashHit}++;
  }
  return $width;
}

sub getFontName {
  my ($self)=@_;
  return "" unless $self->{psFontMetrics};
  $self->{psFontMetrics}->FontName;
}

package TrEd::PDFTreeView;

use TrEd::TreeView;
use base qw(TrEd::TreeView);

sub initPDF {
  my ($self,$P)=@_;
  $self->{psFontSize} = abs($self->canvas->fontActual($self->get_font(),'-size'));
  $self->{TTF} = $P->{DefaultFont};
  return $self->{TTF};
}

sub getFontHeight {
  my ($self)=@_;
  return 0 unless $self->{TTF};
  my $ascent=($self->{TTF}->data->{ascender}*$self->{psFontSize})/1000;
  my $descent=-($self->{TTF}->data->{descender}*$self->{psFontSize})/1000;
  my $height=sprintf("%.0f",$ascent+$descent);
  return $height;
}

sub getTextWidth {
  my ($self,$text)=@_;
  return 0 unless $self->{TTF};
  my $width=$self->{textWidthHash}->{$text};
  if (!defined($width)) {
    if ($TrEd::Convert::support_unicode) {
      $width= $self->{TTF}->width_utf8($text)*$self->{psFontSize};
    } else {
      $width= $self->{TTF}->width($text)*$self->{psFontSize};
    }
    $self->{textWidthHash}->{$text}=$width;
    $self->{textWidthHashMiss}++;
  } else {
    $self->{textWidthHashHit}++;
  }
#  print STDERR "Width: $text = $width ($self->{psFontSize})\n";
  return $width;
}

sub getFontName {
  my ($self,$text)=@_;
  return 0 unless $self->{TTF};
  my $name= $self->{TTF}->name;
  print STDERR "NAME: $name\n";
  return $name;
}

package TrEd::Print;
use strict;
BEGIN{
  use vars qw($bwModeNodeColor %media);
  use Exporter;
  use Tk;
  use Tk::Wm;
  use Tk::Canvas::PDF;
  *media = *Tk::Canvas::PDF::media;
  use Fslib;

  use TrEd::Convert;
  import TrEd::Convert;

  use TrEd::MinMax;
  import TrEd::MinMax;
};
#$bwModeNodeColor = 'white';


sub _dirs {
  my ($dir) = @_;
  my @dirs;
  if (opendir(my $dd, $dir)) {
    @dirs = map { ("$dir/$_",_dirs("$dir/$_")) } grep { -d "$dir/$_" }
      grep { !/^\.*$/ }	readdir($dd);
    closedir $dd;
  } else {
    warn "Warning: can't read $dir\n";
  }
  return @dirs;
}

sub get_ttf_fonts {
  my %result;
  eval {
    require PDF::API2::TTF::Font;
    foreach my $dir (map { _dirs($_) } @_) {
      foreach my $font (grep { -f $_ } glob("$dir/*.*")) {
	my $f = PDF::API2::TTF::Font->open($font);
	next unless $f;
	$PDF::API2::TTF::Name::utf8 = 1;
	$PDF::API2::TTF::GDEF::new_gdef = 1;
	$f->{'name'}->read;
	my $fn=$f->{name}->find_name(1);
	my $fs=$f->{name}->find_name(2);
	$fn.=" ".$fs if $fs ne 'Regular';
	$result{$fn} = $font unless exists $result{$fn};
      }
    }
  };
  print STDERR $@ if $@;
  return \%result;
}

sub parse_print_list {
  my ($fsfile,$printRange)=@_;
  my $pbeg;
  my $pend;
  my @printList;
  return unless ref($fsfile);
  foreach (split /,/,$printRange) {
    if (/^\s*(\d+)\s*$/ and $1-1<=$fsfile->lastTreeNo) {
      push @printList,$1;
      next;
    }
    if (/^\s*(\d*)\s*-\s*(\d*)\s*$/) {
      ($pbeg,$pend)=($1,$2);
      $pend=$fsfile->lastTreeNo+1 if ($pend eq '');
      $pbeg=1 if ($pbeg eq '');
      $pend=min($fsfile->lastTreeNo+1,$pend);
      next unless ($pbeg<=$pend);
      push @printList,$pbeg..$pend;
    }
  }
  return @printList;
}

sub print_trees {
  my ($fsfile,			# FSFile object
      $toplevel,		# Tk window to make busy when printing output
      $c,			# Tk::Canvas object
      $printRange,		# print range
      $toFile,			# boolean: print to file
      $toEPS,			# boolean: create EPS
      $toPDF,			# boolean: create EPS
      $fil,			# output file-name
      $snt,			# boolean: print sentence
      $cmd,			# lpr command
      $printColors,		# boolean: produce color output
      $noRotate,                # boolean: disable tree rotation
      $show_hidden,		# boolean: print hidden nodes too
      $fontSpec,                # hash
      $prtFmtWidth,		# paper width
      $prtHMargin,
      $prtFmtHeight,
      $prtVMargin,
      $maximizePrintSize,
      $Media,
      $canvas_opts		# color hash reference
     )=@_;


  return if (not defined($printRange));

  local $TrEd::Convert::support_unicode = $TrEd::Convert::support_unicode;
  local $TrEd::Convert::lefttoright = $TrEd::Convert::lefttoright;
  # A hack to support correct Arabic rendering under Tk800
  if (1000*$] >= 5008 and
      !$TrEd::Convert::support_unicode and
      $TrEd::Convert::inputenc eq 'iso-8859-6' or
      $TrEd::Convert::inputenc eq 'windows-1256') {
    $TrEd::Convert::lefttoright=1; # arabjoin does this
    $TrEd::Convert::support_unicode=1;
  }


  print STDERR "Printing (TO-FILE=$toFile, PDF=$toPDF, EPS=$toEPS, FIL=$fil, CMD=$cmd, MEDIA=$Media=$prtFmtWidth x $prtFmtHeight)\n";
  my $pagewidth;
  my $pageheight;
  my $P;
  my $treeView;

  my $hMargin = $c->fpixels($prtHMargin);
  my $vMargin = $c->fpixels($prtVMargin);

  if ($Media eq 'User') {
    $prtFmtWidth = $c->fpixels($prtFmtWidth);
    $prtFmtHeight = $c->fpixels($prtFmtHeight);
  } elsif ($Media ne 'BBox') {
    die "Unknown media $Media\n" unless exists $media{$Media};
      $prtFmtWidth  = $media{$Media}[0];
      $prtFmtHeight = $media{$Media}[1];
  }

  if ($toPDF) {
    die "Sending PDF command not yet supported!" unless $toFile;
    $pagewidth=$prtFmtWidth-2*$hMargin;
    $pageheight=$prtFmtHeight-2*$vMargin;
    $P = Tk::Canvas::PDF->new(
			      -unicode => $]>=5.008 ? 1 : 0,
			      -encoding => $TrEd::Convert::support_unicode ? 
			      'utf8' : $TrEd::Convert::outputenc,
			      -ttfont => $fontSpec->{TTF},
			      ($Media ne 'BBox') ?
			      (-media => [0,0,$prtFmtWidth,$prtFmtHeight]) 
			      : ()
			     );

    $treeView = new TrEd::PDFTreeView($c);
    $treeView->apply_options($canvas_opts);
    $treeView->initPDF($P);
  } else {
    $treeView = new TrEd::PSTreeView($c);
    $treeView->apply_options($canvas_opts);
    $treeView->setFontMetrics($fontSpec->{AFM},$fontSpec->{Size});
  }

  unless ($printColors) {
    $treeView->apply_options({
			      lineColor	       => 'black',
			      currentNodeColor   => $bwModeNodeColor,
			      nearestNodeColor   => $bwModeNodeColor,
			      nodeColor	       => $bwModeNodeColor,
			      currentBoxColor    => 'white',
			      boxColor	       => 'white',
			      textColor	       => 'black',
			      textColorShadow    => 'black',
			      textColorHilite    => 'black',
			      textColorXHilite   => 'black',
			      activeTextColor    => 'black',
			      noColor	       => 1,
			      backgroundColor    => 'white',
			     });
  }
  $treeView->apply_options({
			    lineWidth => 1,
			    drawSentenceInfo => $snt
			   });
  my @printList=parse_print_list($fsfile,$printRange);
  return unless @printList;

  my ($infot,$infotext);
  if ($toplevel) {
    $infotext="Printing";
    $infot=$toplevel->Toplevel();
    my $f=$infot->Frame(qw/-relief raised -borderwidth 3/)->pack();
    $f->Label(-textvariable => \$infotext,
	      -wraplength => 200
	     )->pack();
    $infot->overrideredirect(1);
    $infot->Popup();
    $toplevel->Busy(-recurse => 1);
  }
  eval {
    if ($toPDF) {
      my $scale;
      for (my $t=0;$t<=$#printList;$t++) {
	$infotext="Printing $printList[$t]";
	$infot->idletasks() if ($infot);
	print STDERR "$infotext\n";
	$P->new_page();
	do {
	  $treeView->set_showHidden($show_hidden);
	  my ($nodes) = $treeView->nodes($fsfile,$printList[$t]-1,undef);
	  my $valtext=$treeView->value_line($fsfile,$printList[$t]-1,1,0);
	  $treeView->redraw($fsfile,undef,$nodes,$valtext);
	};
	my $width=$c->fpixels($treeView->get_canvasWidth);
	my $height=$c->fpixels($treeView->get_canvasHeight)+10;
	my $rotate = !$toEPS && !$noRotate && $Media ne 'BBox'
	  && $height<$width;
	if ($Media eq 'BBox') {
	  $pagewidth=$width;
	  $pageheight=$height;
	  if (@printList == 1) {
	    $P->{PDF}->mediabox(0,0,$pagewidth+2*$vMargin,$pageheight+2*$vMargin)
	  } else {
	    $P->{current_page}->mediabox(0,0,$pagewidth+2*$vMargin,$pageheight+2*$vMargin);
	  }
	}
	if ($rotate) {
	  $scale = min($pagewidth/$height,
		       $pageheight/$width);
	} else {
	  $scale = min($pageheight/$height,
		       $pagewidth/$width);
	}
	$scale = 1 if ($scale>1 and !$maximizePrintSize);
	if ($rotate) {
	  $P->draw_canvas($c,
			  -width => $width,
			  -height => $height,
			  -scale => [$scale,$scale],
			  -rotate => -90,
			  -translate => [$hMargin+
					 ($pagewidth-$height*$scale)/2,
					 $vMargin+
					 ($pageheight+$width*$scale)/2]
			 );
	} else {
	  $P->draw_canvas($c,
			  -width => $width,
			  -height => $height,
			  #			-rotate => -90,
			  -scale => [$scale,$scale],
			  -translate => [$hMargin+
					 ($pagewidth-$width*$scale)/2,
					 $vMargin+
					 ($pageheight-$height*$scale)/2]
			 );
	}
###	last; # only one page for now
      }
      print STDERR "saving PDF to $fil\n";
      $P->finish(-file => $fil);
      print STDERR "PDF done\n";
    } else {
      my $i;
      my $printMultiple;
      my %pso;
      my $psFontName=$treeView->getFontName();
      print STDERR "Font: ",$fontSpec->{PS},"\n";
      print STDERR "AFM: ",$fontSpec->{AFM},"\n";
      print STDERR "Size: ",$fontSpec->{Size},"\n";
      print STDERR "Name: ",$psFontName,"\n";
      local $TrEd::Convert::outputenc='iso-8859-2';

      unless (open(F,"<$fontSpec->{PS}")) {
	print STDERR "Aborting: failed to open file '$fontSpec->{PS}': $!\n";
	return 0;
      }
      if ($toFile) {
	unless (open(O,">".$fil)) {
	  print STDERR "Aborting: failed to open file '$fil': $!\n";
	  return 0;
	}
      } else {
	$SIG{'PIPE'} = sub {};
	unless (open(O, "| ".$cmd)) {
	  print STDERR "Aborting: failed to open pipe to '$cmd': $!\n";
	  return 0;
	}
      }
      for (my $t=0;$t<=$#printList;$t++) {
	$infotext="Printing $printList[$t]";
	$infot->idletasks() if ($infot);
	print STDERR "$infotext\n";
	do {
	  $treeView->set_showHidden($show_hidden);
	  my ($nodes) = $treeView->nodes($fsfile,$printList[$t]-1,undef);
	  my $valtext=$treeView->value_line($fsfile,$printList[$t]-1,1,0);
	  $treeView->redraw($fsfile,undef,$nodes,$valtext);
	};

	my $rotate = !$toEPS && !$noRotate
	  && $treeView->get_canvasHeight<$treeView->get_canvasWidth;
	if (not $rotate) {
	  $pagewidth=$prtFmtWidth-2*$hMargin;
	  $pageheight=$prtFmtHeight-2*$vMargin;
	} else {
	  $pagewidth=$prtFmtHeight-2*$vMargin;
	  $pageheight=$prtFmtWidth-2*$hMargin;
	}
	print STDERR "Real Page : ",int($pagewidth),"x",int($pageheight),"\n";

	%pso = (  -colormode => $printColors ? 'color' : 'gray',
		  '-x'	 => 0,
		  '-y'	 => 0,
		  -fontmap	 => { $treeView->get_font() => [$psFontName,$fontSpec->{Size}] },
		  -width	 => $treeView->get_canvasWidth,
		  -height	 => $treeView->get_canvasHeight,
		  -rotate	 => $rotate);
	my $width=$c->fpixels($treeView->get_canvasWidth);
	my $height=$c->fpixels($treeView->get_canvasHeight);

	unless ($toEPS) {
	  if ($maximizePrintSize or $width>$pagewidth or
	      $height>$pageheight) {
	    print STDERR "Adjusting print size\n";
	    if ($width/$pagewidth*$pageheight>$height) {
	      $pso{-pagewidth} =
		$pagewidth;
	      print STDERR "Scaling by tree width,\n";
	      print STDERR "forcing box width to $pagewidth\n";
	    } else {
	      $pso{-pageheight} =
		$pageheight;
	      print STDERR "Scaling by tree height,\n";
	      print STDERR "forcing box height to $pageheight\n";
	    }
	  }
	}

	my @ps = split /\n/,$c->postscript(%pso);
	# if ($toFile) {
	#      local *U;
	#      open(U,">"."$fil.orig.ps");
	#      print U $c->postscript(%pso);
	#      close U;
	#    }

	$i=0;
	if ($t>0) {
	  $i++  while ($i<=$#ps and $ps[$i]!~/^%%Page:/);
	  print O '%%Page: ',$t+1," ",$t+1,"\n";
	  #       my $now=localtime;
	  #        unless ($toEPS) {
	  #  	print O	       "gsave\n",
	  #  		       "/Arial-Medium findfont 8 scalefont setfont\n",
	  #  		       "0.000 0.000 0.000 setrgbcolor AdjustColor\n",
	  #  		       "40 40 [\n",
	  #  		       "(".
	  #  		       "Printed by TrEd on $now.)\n",
	  #  		       "] 13 -0 0 0 false DrawText\ngrestore\n";
	  #        }
	  $i++;
	} else {
	  $i=0;
	  unless ($toEPS) {
	    $ps[0]=~s/ EPSF-3.0//;
	    print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i]!~/^%\%BoundingBox:/);
	    print O $ps[$i++],"\n";
	    print O "\%\%DocumentMedia: $Media $prtFmtWidth $prtFmtHeight white()\n";
	    print O '%%Pages: ',$#printList+1,"\n";
	    $i++;
	  }
	  print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i] !~ /^%\%DocumentNeededResources: font $psFontName/);
	  print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i]!~/^%\%BeginProlog|^%\%BeginSetup/);
	  if ($ps[$i]=~/^%\%BeginSetup/) {
	    # this hack is to partially fix Tk804.025 bug
	    print O '%%BeginProlog',"\n";
	    print O '%%BeginFont tredfont',"\n";
	    print O <F>;
	    print O '%%EndFont',"\n\n";
	    print O <<'__END_OF_TK804_WORKAROUD__';
% StrokeClip
%
% This procedure converts the current path into a clip area under
% the assumption of stroking.  It's a bit tricky because some Postscript
% interpreters get errors during strokepath for dashed lines. If
% this happens then turn off dashes and try again.

/StrokeClip {
    {strokepath} stopped {
	(This Postscript printer gets limitcheck overflows when) =
	(stippling dashed lines;  lines will be printed solid instead.) =
	[] 0 setdash strokepath} if
    clip
} bind def

% desiredSize EvenPixels closestSize
%
% The procedure below is used for stippling.  Given the optimal size
% of a dot in a stipple pattern in the current user coordinate system,
% compute the closest size that is an exact multiple of the device's
% pixel size.  This allows stipple patterns to be displayed without
% aliasing effects.

/EvenPixels {
    % Compute exact number of device pixels per stipple dot.
    dup 0 matrix currentmatrix dtransform
    dup mul exch dup mul add sqrt

    % Round to an integer, make sure the number is at least 1, and compute
    % user coord distance corresponding to this.
    dup round dup 1 lt {pop 1} if
    exch div mul
} bind def

% width height string StippleFill --
%
% Given a path already set up and a clipping region generated from
% it, this procedure will fill the clipping region with a stipple
% pattern.  "String" contains a proper image description of the
% stipple pattern and "width" and "height" give its dimensions.  Each
% stipple dot is assumed to be about one unit across in the current
% user coordinate system.  This procedure trashes the graphics state.

/StippleFill {
    % The following code is needed to work around a NeWSprint bug.

    /tmpstip 1 index def

    % Change the scaling so that one user unit in user coordinates
    % corresponds to the size of one stipple dot.
    1 EvenPixels dup scale

    % Compute the bounding box occupied by the path (which is now
    % the clipping region), and round the lower coordinates down
    % to the nearest starting point for the stipple pattern.  Be
    % careful about negative numbers, since the rounding works
    % differently on them.

    pathbbox
    4 2 roll
    5 index div dup 0 lt {1 sub} if cvi 5 index mul 4 1 roll
    6 index div dup 0 lt {1 sub} if cvi 6 index mul 3 2 roll

    % Stack now: width height string y1 y2 x1 x2
    % Below is a doubly-nested for loop to iterate across this area
    % in units of the stipple pattern size, going up columns then
    % across rows, blasting out a stipple-pattern-sized rectangle at
    % each position

    6 index exch {
	2 index 5 index 3 index {
	    % Stack now: width height string y1 y2 x y

	    gsave
	    1 index exch translate
	    5 index 5 index true matrix tmpstip imagemask
	    grestore
	} for
	pop
    } for
    pop pop pop pop pop
} bind def

% -- AdjustColor --
% Given a color value already set for output by the caller, adjusts
% that value to a grayscale or mono value if requested by the CL
% variable.

/AdjustColor {
    CL 2 lt {
	currentgray
	CL 0 eq {
	    .5 lt {0} {1} ifelse
	} if
	setgray
    } if
} bind def

% x y strings spacing xoffset yoffset justify stipple DrawText --
% This procedure does all of the real work of drawing text.  The
% color and font must already have been set by the caller, and the
% following arguments must be on the stack:
%
% x, y -	Coordinates at which to draw text.
% strings -	An array of strings, one for each line of the text item,
%		in order from top to bottom.
% spacing -	Spacing between lines.
% xoffset -	Horizontal offset for text bbox relative to x and y: 0 for
%		nw/w/sw anchor, -0.5 for n/center/s, and -1.0 for ne/e/se.
% yoffset -	Vertical offset for text bbox relative to x and y: 0 for
%		nw/n/ne anchor, +0.5 for w/center/e, and +1.0 for sw/s/se.
% justify -	0 for left justification, 0.5 for center, 1 for right justify.
% stipple -	Boolean value indicating whether or not text is to be
%		drawn in stippled fashion. If text is stippled,
%		procedure StippleText must have been defined to call
%		StippleFill in the right way.
%
% Also, when this procedure is invoked, the color and font must already
% have been set for the text.

/DrawText {
    /stipple exch def
    /justify exch def
    /yoffset exch def
    /xoffset exch def
    /spacing exch def
    /strings exch def

    % First scan through all of the text to find the widest line.

    /lineLength 0 def
    strings {
	stringwidth pop
	dup lineLength gt {/lineLength exch def} {pop} ifelse
	newpath
    } forall

    % Compute the baseline offset and the actual font height.

    0 0 moveto (TXygqPZ) false charpath
    pathbbox dup /baseline exch def
    exch pop exch sub /height exch def pop
    newpath

    % Translate coordinates first so that the origin is at the upper-left
    % corner of the text's bounding box. Remember that x and y for
    % positioning are still on the stack.

    translate
    lineLength xoffset mul
    strings length 1 sub spacing mul height add yoffset mul translate

    % Now use the baseline and justification information to translate so
    % that the origin is at the baseline and positioning point for the
    % first line of text.

    justify lineLength mul baseline neg translate

    % Iterate over each of the lines to output it.  For each line,
    % compute its width again so it can be properly justified, then
    % display it.

    strings {
	dup stringwidth pop
	justify neg mul 0 moveto
	stipple {

	    % The text is stippled, so turn it into a path and print
	    % by calling StippledText, which in turn calls StippleFill.
	    % Unfortunately, many Postscript interpreters will get
	    % overflow errors if we try to do the whole string at
	    % once, so do it a character at a time.

	    gsave
	    /char (X) def
	    {
		char 0 3 -1 roll put
		currentpoint
		gsave
		char true charpath clip StippleText
		grestore
		char stringwidth translate
		moveto
	    } forall
	    grestore
	} {show} ifelse
	0 spacing neg translate
    } forall
} bind def

%%EndProlog
__END_OF_TK804_WORKAROUD__
	    print O $ps[$i++],"\n";
	    for (my $j=$i; $j<=$#ps; $j++) {
	      if ($ps[$j]=~/^\[(\(.*\))\]$/) {
		$ps[$j]=$1;
		$ps[$j] =~ s/\\370/\\354/g;
		$ps[$j] =~ s/\)\/\(/\\370/g;
	      }
	    }
	  } else {
	    print O $ps[$i++],"\n";
	    print O '%%BeginFont tredfont',"\n";
	    print O <F>;
	    print O '%%EndFont',"\n\n";
	    $i++ while ($i<=$#ps and $ps[$i]!~/% StrokeClip/);
	  }
	  print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i]!~/^%\%IncludeResource: font $psFontName/);
	  $i++;
	}
	while ($i<=$#ps && $ps[$i]!~/^%\%Trailer\w*$/) {
	  $ps[$i]=~s/ISOEncode //g;
	  print O $ps[$i]."\n" unless ($toEPS and
				       $ps[$i] =~/^restore showpage/);
	  $i++
	}
      }
      print O "restore\n" if $toEPS;
      print O '%%EOF',"\n";
      close (F);
      close (O);
    }
  };
  my $err=$@;
  if ($toplevel) {
    $infot->destroy() if ($infot);
    $toplevel->Unbusy();
  }
  die $err if $err;
  return 1;
}

1;
