package TrEd::PrintTreeView;

use TrEd::TreeView;
use base qw(TrEd::TreeView);
use PostScript::FontMetrics;

sub setFontMetrics {
  my ($self,$filename,$fontsize,$fontscale)=@_;
  $self->{psFontSize} = $fontsize;
  $self->{psFontScale} = $fontscale ? $fontscale : 1000;
  $self->{psFontMetrics} = new PostScript::FontMetrics($filename);
  return $self->{psFontMetrics};
}

sub getFontHeight {
  my ($self)=@_;
  return 0 unless $self->{psFontMetrics};
  $ascent=$self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[3]/1000;
  $descent=-$self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[1]/1000;
  return sprintf("%.0f",$ascent+$descent);
}

sub getTextWidth {
  my ($self,$text)=@_;
  return 0 unless $self->{psFontMetrics};
  return $self->{psFontMetrics}->stringwidth($text,$self->{psFontSize});
}

sub getFontName {
  my ($self)=@_;
  return "" unless $self->{psFontMetrics};
  $self->{psFontMetrics}->FontName;
}

package TrEd::Print;

use Tk;
use Fslib;

use TrEd::Convert;
import TrEd::Convert;

use TrEd::MinMax;
import TrEd::MinMax;

use strict;

sub parse_print_list {
  my ($fsfile,$printRange)=@_;
  my $pbeg;
  my $pend;
  my @printList;
  return unless ref($fsfile);
  foreach (split /,/,$printRange) {
    print "Parsing $_\n";
    if (/^\s*([0-9]+)\s*$/ and $1-1<=$fsfile->lastTreeNo) {
      print "Preparing $1\n";
      push @printList,$1;
      next;
    }
    if (/^\s*([0-9]*)\s*-\s*([0-9]*)\s*$/) {
      print "Preparing $1-$2\n";
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
      $fil,			# output file-name
      $snt,			# boolean: print sentence
      $cmd,			# lpr command
#      $useType1Font,		# boolean: use Type1 font
      $printColors,		# boolean: produce color output
      $noRotate,                # boolean: disable tree rotation
      $show_hidden,		# boolean: print hidden nodes too
      $psFontFile,		# postscript font
      $psFontAFMFile,		# postscript font
#      $type1font,		# Type1 font
      $prtFmtWidth,		# paper width
      $prtHMargin,
      $prtFmtHeight,
      $prtVMargin,
      $psFontName,
      $psFontSize,
      $maximizePrintSize,
      $psMedia,
      $canvas_opts		# color hash reference
     )=@_;


  return if (not defined($printRange));

  my $treeView = new TrEd::PrintTreeView($c);
  my $i;
  my $pagewidth;
  my $pageheight;
  my $printMultiple;
  my %pso;

  $treeView->setFontMetrics($psFontAFMFile,$psFontSize);
  $psFontName=$treeView->getFontName();
  $treeView->apply_options($canvas_opts);
  print "AFM: ",$psFontAFMFile,"\n";
  print "Name: ",$psFontName,"\n";
  unless ($printColors) {
    $treeView->apply_options({
			    lineColor	       => 'black',
			    nodeColor	       => 'white',
			    currentBoxColor    => 'white',
			    boxColor	       => 'white',
			    currentNodeColor   => 'white',
			    nearestNodeColor   => 'white',
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

  local $TrEd::Convert::outputenc='iso-88859-2';

  my @printList=parse_print_list($fsfile,$printRange);

#### this must be done by TrEd somewhere ###############
#  push @printList,$grp->{treeNo}+1 unless (@printList);

  unless (open(F,"<$psFontFile")) {
    print STDERR "Aborting: failed to open font file $psFontFile\n";
    return 0;
  }
  if ($toFile) {
    unless (open(O,">".$fil)) {
      print STDERR "Aborting: failed to open font file $fil\n";
      return 0;
    }
  } else {
    $SIG{'PIPE'} = sub {};
    unless (open(O, "| ".$cmd)) {
      print STDERR "Aborting: failed to open font file $cmd\n";
      return 0;
    }
  }

  $toplevel->Busy(-recurse => 1) if ($toplevel);
  for (my $t=0;$t<=$#printList;$t++) {
    print STDERR "Printing $printList[$t]\n";
#    $treeView->set_font($type1font) if ($useType1Font);
    do {
      $treeView->set_showHidden($show_hidden);
      my ($nodes) = $treeView->nodes($fsfile,$printList[$t]-1,undef);
      my ($valtext) = encode($fsfile->value_line($printList[$t]-1));
      $treeView->redraw($fsfile,undef,$nodes,$valtext);
    };

    my $rotate = !$toEPS && !$noRotate
      && $treeView->get_canvasHeight<$treeView->get_canvasWidth;
    print STDERR "Landscape : $rotate\n";
    print STDERR "Canvas    : ",int($treeView->get_canvasWidth),"x",
      int($treeView->get_canvasHeight),"\n";
    print STDERR "Page      : ",int($c->fpixels($prtFmtWidth)),"x",
      int($c->fpixels($prtFmtHeight)),"\n";
    if (not $rotate) {
      $pagewidth=$c->fpixels($prtFmtWidth)-2*$c->fpixels($prtHMargin);
      $pageheight=$c->fpixels($prtFmtHeight)-2*$c->fpixels($prtVMargin);
    } else {
      $pagewidth=$c->fpixels($prtFmtHeight)-2*$c->fpixels($prtVMargin);
      $pageheight=$c->fpixels($prtFmtWidth)-2*$c->fpixels($prtHMargin);
    }
    print STDERR "Real Page : ",int($pagewidth),"x",int($pageheight),"\n";

    %pso = (  -colormode => $printColors ? 'color' : 'gray',
	      '-x'	 => 0,
	      '-y'	 => 0,
	      -fontmap	 => { $treeView->get_font() => [$psFontName, $psFontSize] },
	      -width	 => $treeView->get_canvasWidth,
	      -height	 => $treeView->get_canvasHeight,
	      -rotate	 => $rotate);

    unless ($toEPS) {
      if ($maximizePrintSize or $c->fpixels($treeView->get_canvasWidth)>$pagewidth or
	  $c->fpixels($treeView->get_canvasHeight)>$pageheight) {
	print "Adjusting print size\n";
	if ($c->fpixels($treeView->get_canvasWidth)/$pagewidth*$pageheight>$c->fpixels($treeView->get_canvasHeight)) {
	  $pso{-pagewidth} =
	    $pagewidth;
	  print "Scaling by tree width,\n";
	  print "forcing box width to $pagewidth\n";
	} else {
	  $pso{-pageheight} =
	    $pageheight;
	  print "Scaling by tree height,\n";
	  print "forcing box height to $pageheight\n";
	}
      }
    }

    my @ps = split /\n/,$c->postscript(%pso);
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
	print O $psMedia,"\n";
	print O '%%Pages: ',$#printList+1,"\n";
	$i++;
      }
      print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i] !~ /^%\%DocumentNeededResources: font $psFontName/);
      print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i]!~/^%\%BeginProlog/);
      print O $ps[$i++],"\n";
      print O '%%BeginFont tredfont',"\n";
      print O <F>;
      print O '%%EndFont',"\n\n";
      $i++ while ($i<=$#ps and $ps[$i]!~/% StrokeClip/);
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
  print O '%%EOF',"\n";
  close (F);
  close (O);

  $toplevel->Unbusy() if ($toplevel);
  return 1;
}

1;
