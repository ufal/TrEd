package TrEd::PSTreeView;
use TrEd::TreeView;
use base qw(TrEd::TreeView);

sub setFontMetrics {
  my ($self,$filename,$fontsize,$fontscale)=@_;
  $self->{psFontSize} = $fontsize;
  $self->{psFontScale} = $fontscale ? $fontscale : 1000;
  $self->{textWidthHash}={};
  if ($TrEd::Convert::support_unicode) {
    require PostScript::AGLFN;
    $self->{psFontMetrics} = new PostScript::AGLFN($filename);
  } else {
    require PostScript::FontMetrics;
    $self->{psFontMetrics} = new PostScript::FontMetrics($filename);
  }
#  print STDERR "FONT SIZE: $self->{psFontSize}, $self->{psFontMetrics}\n";
  return $self->{psFontMetrics};
}

sub getFontHeight {
  my ($self)=@_;
  return 0 unless $self->{psFontMetrics};
  my $ascent=($self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[3])/1000;
  my $descent=-($self->{psFontSize}*$self->{psFontMetrics}->FontBBox->[1])/1000;
  return sprintf("%.0f",$ascent+$descent);
}

sub getTextWidth {
  my ($self,$text)=@_;
  return 0 unless $self->{psFontMetrics};
  my $width=$self->{textWidthHash}->{$text};
  if (!defined($width)) {
    $width=$self->{psFontMetrics}->stringwidth($text,$self->{psFontSize});
    $self->{textWidthHash}->{$text}=$width;
    $self->{textWidthHashMiss}++;
  } else {
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
  return $width;
}

sub getFontName {
  my ($self,$text)=@_;
  return 0 unless $self->{TTF};
  my $name= $self->{TTF}->name;
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
  my $ds=$TrEd::Convert::Ds;
  my @dirs;
  if (opendir(my $dd, $dir)) {
    @dirs = map { ("${dir}${ds}$_",_dirs("${dir}${ds}$_")) } grep { -d "${dir}${ds}$_" }
      grep { !/^\.*$/ }	readdir($dd);
    closedir $dd;
  } else {
    warn "Warning: can't read ${dir}\n";
  }
  return $dir,@dirs;
}

sub get_ttf_fonts {
  my %result;
  my $ds=$TrEd::Convert::Ds;
  eval {
    require PDF::API2::TTF::Font;
    foreach my $dir (map { _dirs($_) } @_) {
      foreach my $font (grep { -f $_ } glob("${dir}${ds}*.*")) {
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
      $canvas_opts,		# color hash reference
      $stylesheet
     )=@_;

  return if (not defined($printRange));

  local $TrEd::Convert::support_unicode = $TrEd::Convert::support_unicode;
  local $TrEd::Convert::lefttoright = $TrEd::Convert::lefttoright;
  # A hack to support correct Arabic rendering under Tk800
  if (1000*$] >= 5008 and
      !$TrEd::Convert::support_unicode and
      $TrEd::Convert::inputenc =~ /^utf-?8$/i or
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

  $Media='BBox' if $toPDF and $toEPS; # hack

  if ($Media eq 'User') {
    $prtFmtWidth = $c->fpixels($prtFmtWidth);
    $prtFmtHeight = $c->fpixels($prtFmtHeight);
  } elsif ($Media ne 'BBox') {
    die "Unknown media $Media\n" unless exists $media{$Media};
      $prtFmtWidth  = $media{$Media}[0];
      $prtFmtHeight = $media{$Media}[1];
  }

  if ($toPDF) {
    $pagewidth=$prtFmtWidth-2*$hMargin;
    $pageheight=$prtFmtHeight-2*$vMargin;
    local $TrEd::Convert::support_unicode = 1 if ($]>=5.008);
    $P = Tk::Canvas::PDF->new(
			      -unicode => ($]>=5.008) ? 1 : 0,
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

  unless ($toPDF or $printColors) {
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
  if (defined($stylesheet)) {
    $treeView->set_patterns($stylesheet->{patterns});
    $treeView->set_hint(\$stylesheet->{hint});
  }

  my @printList=parse_print_list($fsfile,$printRange);
  return unless @printList;

  my ($infot,$infotext);
  if ($toplevel) {
    $infotext="Printing";
    $infot=$toplevel->Toplevel();
    $infot->UnmapWindow;
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
	    $P->{PDF}->mediabox(0,0,$pagewidth+2*$hMargin,$pageheight+2*$vMargin)
	  } else {
	    $P->{current_page}->mediabox(0,0,$pagewidth+2*$hMargin,$pageheight+2*$vMargin);
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
			  -grayscale => !$printColors,
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
			  -grayscale => !$printColors,
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
      if ($toFile) {
	$P->finish(-file => $fil);
      } else {
	$SIG{'PIPE'} = sub {};
	eval {
	  require File::Temp;
	  my $fh = new File::Temp(UNLINK => 0);
	  my $fn = $fh->filename;
	  $P->finish(-file => $fn);
	  open $fh, $fn;
	  binmode $fh;
	  my $out = new IO::Pipe;
	  $out->writer($cmd);
	  binmode $out;
	  $out->print(<$fh>);
	  unlink $fh;
	  close $fh;
	  close $out;
	} || do {
	  print STDERR $@ if $@;
	  print STDERR "Aborting: failed to open pipe to '$cmd': $!\n";
	  return 0;
	};
      }
      print STDERR "PDF done\n";
    } else {
      my $i;
      my $printMultiple;
      my %pso;
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
	my $ps_result = $c->postscript(%pso);
	my $curenc = <<END_OF_ENC;
/CurrentEncoding [
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/exclam/quotedbl/numbersign/dollar/percent/ampersand/quotesingle
/parenleft/parenright/asterisk/plus/comma/hyphen/period/slash
/zero/one/two/three/four/five/six/seven
/eight/nine/colon/semicolon/less/equal/greater/question
/at/A/B/C/D/E/F/G
/H/I/J/K/L/M/N/O
/P/Q/R/S/T/U/V/W
/X/Y/Z/bracketleft/backslash/bracketright/asciicircum/underscore
/grave/a/b/c/d/e/f/g
/h/i/j/k/l/m/n/o
/p/q/r/s/t/u/v/w
/x/y/z/braceleft/bar/braceright/asciitilde/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/space/space/space/space/space/space/space
/space/exclamdown/cent/sterling/currency/yen/brokenbar/section
/dieresis/copyright/ordfeminine/guillemotleft/logicalnot/hyphen/registered/macron
/degree/plusminus/twosuperior/threesuperior/acute/mu/paragraph/periodcentered
/cedilla/onesuperior/ordmasculine/guillemotright/onequarter/onehalf/threequarters/questiondown
/Agrave/Aacute/Acircumflex/Atilde/Adieresis/Aring/AE/Ccedilla
/Egrave/Eacute/Ecircumflex/Edieresis/Igrave/Iacute/Icircumflex/Idieresis
/Eth/Ntilde/Ograve/Oacute/Ocircumflex/Otilde/Odieresis/multiply
/Oslash/Ugrave/Uacute/Ucircumflex/Udieresis/Yacute/Thorn/germandbls
/agrave/aacute/acircumflex/atilde/adieresis/aring/ae/ccedilla
/egrave/eacute/ecircumflex/edieresis/igrave/iacute/icircumflex/idieresis
/eth/ntilde/ograve/oacute/ocircumflex/otilde/odieresis/divide
/oslash/ugrave/uacute/ucircumflex/udieresis/yacute/thorn/ydieresis
] def
END_OF_ENC
	$ps_result =~ s{/CurrentEncoding\s*\[\s*(?:/space\s*)+\] def}{$curenc}g;
	my @ps = split /\n/,$ps_result;
	$i=0;
	if ($t>0) {
	  $i++  while ($i<=$#ps and $ps[$i]!~/^%%Page:/);
	    print O '%%Page: ',$t+1," ",$t+1,"\n";
	  $i++;
	} else { # $t == 0
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
#	    print O '%%BeginFont tredfont',"\n";
	    print O <F>;
#	    print O '%%EndFont',"\n\n";
	  } else {
	    print O $ps[$i++],"\n";
#	    print O '%%BeginFont ',"$psFontName\n";
	    print O <F>;
#	    print O '%%EndFont',"\n\n";
	    #	      $i++ while ($i<=$#ps and $ps[$i]!~/% StrokeClip/);
	  }
	  print O $ps[$i++],"\n" while ($i<=$#ps and $ps[$i]!~/^%\%IncludeResource: font $psFontName/);
	  $i++;
	}
	while ($i<=$#ps && $ps[$i]!~/^%\%Trailer\w*$/) {
	  $ps[$i]=~s/ISOEncode //g unless $TrEd::Convert::support_unicode;
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
