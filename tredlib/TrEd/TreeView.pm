package TrEd::TreeView;		# -*- cperl -*-

use Tk;
use Tk::Balloon;
use Fslib;
use TrEd::MinMax;
import TrEd::MinMax;

use TrEd::Convert;
import TrEd::Convert;

use vars qw($AUTOLOAD @Options);

use strict;

@Options = qw(CanvasBalloon backgroundColor baseXPos baseYPos boxColor
  currentBoxColor currentEdgeBoxColor currentNodeHeight
  currentNodeWidth customColors hiddenEdgeBoxColor edgeBoxColor
  clearTextBackground drawBoxes drawEdgeBoxes
  drawSentenceInfo font hiddenBoxColor edgeLabelYSkip
  highlightAttributes showHidden lineArrow lineColor lineWidth noColor
  nodeHeight nodeWidth nodeXSkip nodeYSkip edgeLabelSkipAbove
  edgeLabelSkipBelow pinfo textColor xmargin
  nodeOutlineColor nodeColor hiddenNodeColor nearestNodeColor ymargin
  currentNodeColor textColorShadow textColorHilite textColorXHilite
  useAdditionalEdgeLabelSkip);

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { pinfo     => {},	# maps canvas objects to nodes
	      canvas     => shift, @_ };

  bless $new, $class;
  return $new;
}

sub AUTOLOAD {
  my $self=shift;
  return undef unless ref($self);
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;
  if ($sub=~/^get_(.*)$/) {
    return $self->{$1};
  } elsif ($sub=~/^set_(.*)$/) {
    return $self->{$1}=shift;;
  } else {
    warn "Warning: $sub is not a method of TreeView\n";
    warn join "\n",(caller(0))[0..4];
  }
}

sub DESTROY {
}

sub canvas {
  my $self = shift;
  return undef unless ref($self);
  return $self->{canvas};
}

sub realcanvas {
  my $self = shift;
  return undef unless ref($self);
  return $self->{canvas}->isa("Tk::Canvas") ? $self->{canvas} : $self->{canvas}->Subwidget("scrolled");
}


sub pinfo {
  my $self = shift;
  return undef unless ref($self);
  return $self->{pinfo};
}

sub set_pinfo {
  my $self = shift;
  return undef unless ref($self);
  $self->{pinfo}=shift;
}

sub clear_pinfo {
  my $self = shift;
  return undef unless ref($self);
  %{$self->{pinfo}}=();
}

sub store_gen_pinfo {
  my ($self,$key,$value) = @_;
  return undef unless ref($self);
  $self->{pinfo}->{"gen:$key"}=$value;
}

sub store_node_pinfo {
  my ($self,$node,$key,$value) = @_;
  return undef unless ref($self);
  $self->{pinfo}->{"node:${node};${key}"}=$value;
}

sub store_obj_pinfo {
  my ($self,$obj,$value) = @_;
  return undef unless ref($self);
  $self->{pinfo}->{"obj:${obj}"}=$value;
}

sub get_gen_pinfo {
  my ($self,$key) = @_;
  return undef unless ref($self);
  return $self->{pinfo}->{"gen:$key"};
}

sub get_node_pinfo {
  my ($self,$node,$key) = @_;
  return undef unless ref($self);
  return $self->{pinfo}->{"node:${node};${key}"};
}

sub get_obj_pinfo {
  my ($self,$obj) = @_;
  return undef unless ref($self);
  return $self->{pinfo}->{"obj:${obj}"};
}


sub apply_options {
  my ($self,$opts) = @_;
  return undef unless ref($self);
  foreach (@Options) {
    $self->{$_}=$opts->{$_} if (exists($opts->{$_}));
  }
  print "FONT ======: ",$self->get_font,"\n";
  return;
}

sub options {
  my ($self) = @_;
  return undef unless ref($self);
  return { map {$_ => $self->{$_} } @Options };
}


sub value_line {
  my ($self,$fsfile,$tree_no)=@_;
  return unless $fsfile;

  my $node=$fsfile->treeList->[$tree_no];
  my @sent=();

  my $attr=$fsfile->FS->sentord;
  $attr=$fsfile->FS->order unless (defined($attr));
  while ($node) {
    push @sent,$node unless $node->{$attr}>=999; # this is TR specific
    $node=Next($node);
  }
  @sent = sort { $a->{$attr} <=> $b->{$attr} } @sent;

  $attr=$fsfile->FS->value;
  my $line =
    ($tree_no+1)."/".($fsfile->lastTreeNo+1).": ".
    encode(join(" ", map { $_->{$attr} } @sent));
  undef @sent;
  return $line;
}


sub nodes {
  my ($self,$fsfile,$tree_no,$prevcurrent)=@_;
  return ($fsfile->nodes($tree_no,$prevcurrent,$self->get_showHidden()));
}

sub getFontHeight {
  my ($self)=@_;
  return $self->canvas->fontMetrics($self->get_font, -linespace);
}

sub getTextWidth {
  my ($self,$text)=@_;
  return $self->canvas->fontMeasure($self->get_font,$text);
}

sub recalculate_positions {
  my ($self,$fsfile,$nodes,$Opts)=@_;
  return unless ref($self);

  my $baseXPos=$self->get_baseXPos;
  my $xpos=$baseXPos;
  my $level;

  my $minxpos;			# used temporarily to place a node far
                                # enough from its left neighbour

  my $maxlevel;			# has different meaning from $minxpos;
                                # this one's used for canvasHeight
  my $canvasWidth=0;
  my $node;
  my $xSkipBefore=0;
  my $xSkipAfter=0;
  my $nodeLabelXShift=0;
  my $nodeLabelWidth=0;
  my $edgeLabelWidth=0;
  my ($nodeWidth,$nodeHeight)=($self->get_nodeWidth,$self->get_nodeHeight);
  my ($nodeXSkip,$nodeYSkip)=($self->get_nodeXSkip,$self->get_nodeYSkip);
  my $m;

  my ($pattern_count,$node_pattern_count,$edge_pattern_count)=(0,0,0);
				# May change with line attached labels
  if (ref($fsfile)) {
    $pattern_count=$fsfile->pattern_count;
    $node_pattern_count=scalar($self->get_label_patterns($fsfile,"node"));
    $edge_pattern_count=scalar($self->get_label_patterns($fsfile,"edge"));
  }

  my $fontHeight=$self->getFontHeight();
  my $node_label_height=2*$self->get_ymargin + $node_pattern_count*$fontHeight;
  my $edge_label_height=2*$self->get_ymargin + $edge_pattern_count*$fontHeight;
  my $levelHeight=$nodeHeight;

  if ($edge_pattern_count) {
    $levelHeight +=
	     $self->get_edgeLabelSkipAbove
	  +  $self->get_edgeLabelSkipBelow
	  +  $edge_label_height;
  }
  if ($node_pattern_count) {
     $levelHeight += $nodeYSkip + $node_label_height;
     $levelHeight += $nodeYSkip unless ($edge_pattern_count);
  }

  my @prevnode=();
  my $parent;
  my $ypos;
  $maxlevel=0;
  my $valign_shift=0;
  my $valign;
  my $halign_node;
  my $halign_edge;
  my $valign_edge;
  my $edge_ypos;
  my ($pat_style,$pat);
  foreach $node (@{$nodes}) {
    $level=0;
    $parent=$node->parent;
    while ($parent) {
      $level++;
      $parent=$parent->parent;
    }
    $self->store_node_pinfo($node,"EdgeLabelHeight", $edge_label_height);

    $maxlevel=max($maxlevel,$level);
    $ypos = $self->get_baseYPos + $level*$levelHeight;

    $valign=$self->get_style_opt($node,"NodeLabel","-valign",$Opts);
    if ($valign eq 'bottom') {
      $valign_shift=-$nodeYSkip-$node_label_height;
      $ypos+=$node_label_height;
    } elsif ($valign eq 'center') {
      $valign_shift=-$node_label_height/2;
      $ypos+=$node_label_height/2;
    } else {
      $valign_shift=$nodeYSkip+$nodeHeight;
    }



    $self->store_node_pinfo($node,"YPOS", $ypos);

    $self->store_node_pinfo($node,"NodeLabel_YPOS",
			    $ypos
			    +$self->get_style_opt($node,"NodeLabel","-yadj",$Opts)
			    +$valign_shift);
    if ($valign eq 'bottom') {
      $edge_ypos=$ypos
	+ $valign_shift
	- $self->get_edgeLabelSkipBelow
	- $edge_label_height;
    } else {
      $edge_ypos=$ypos
	     + $valign_shift
	     + $node_label_height
	     + $self->get_edgeLabelSkipAbove
	     - $levelHeight;
    }
    $edge_ypos+=$self->get_style_opt($node,"EdgeLabel","-yadj",$Opts);
    $self->store_node_pinfo($node,"EdgeLabel_YPOS",$edge_ypos);

    $halign_edge=$self->get_style_opt($node,"EdgeLabel","-halign",$Opts);

    ($nodeLabelWidth,$edgeLabelWidth)=(0,0);
    $halign_node=$self->get_style_opt($node,"NodeLabel","-halign",$Opts);

    for (my $i=0;$i<$pattern_count;$i++) {
      ($pat_style,$pat)=$self->parse_pattern($fsfile->pattern($i));
      if ($pat_style eq "edge") {
	# this does not actually make
	# the edge label not to overwrap, but helps a little
	$m=$self->getTextWidth($self->prepare_text($node,$pat));
	$self->store_node_pinfo($node,"X[$i]",$m);
	$edgeLabelWidth=$m if $m>$edgeLabelWidth;
      } elsif ($pat_style eq "node") {
	$m=$self->getTextWidth($self->prepare_text($node,$pat));
	$self->store_node_pinfo($node,"X[$i]",$m);
	$nodeLabelWidth=$m if $m>$nodeLabelWidth;
      }
    }

    $xSkipBefore=$nodeWidth/2;
    $xSkipAfter=$nodeWidth/2;
    if ($halign_node eq 'right') {
      $xSkipBefore=max($xSkipBefore,$nodeLabelWidth-$nodeWidth/2);
      $nodeLabelXShift=-$nodeLabelWidth+$nodeWidth/2;
    } elsif ($halign_node eq 'center') {
      $xSkipBefore=max($xSkipBefore,$nodeLabelWidth/2);
      $xSkipAfter=max($xSkipBefore,$nodeLabelWidth/2);
      $nodeLabelXShift=-$nodeLabelWidth/2;
    } else {
      $xSkipAfter=max($xSkipAfter,$nodeLabelWidth-$nodeWidth/2);
      $nodeLabelXShift=-$nodeWidth/2;
    }

    # Try to add reasonable skip so that the edge labels do
    # not overlap. (this code however cannot ensure that!!)
    if ($self->get_useAdditionalEdgeLabelSkip() and
	$self->get_style_opt($node,"Node","-disableedgelabelspace",$Opts) ne "yes"
       ) {
      if ($halign_edge eq 'right') {
	$xSkipBefore=max($xSkipBefore,2*$edgeLabelWidth);
      } elsif ($halign_edge eq 'center') {
	$xSkipBefore=max($xSkipBefore,$edgeLabelWidth);
	$xSkipAfter=max($xSkipAfter,$edgeLabelWidth);
      } else {
	$xSkipAfter=max($xSkipAfter,2*$edgeLabelWidth);
      }
    }
    $xSkipBefore+=$self->get_style_opt($node,"Node","-addbeforeskip",$Opts);
    $xSkipAfter+=$self->get_style_opt($node,"Node","-addafterskip",$Opts);

    $self->store_node_pinfo($node,"NodeLabelWidth",$nodeLabelWidth);
    $self->store_node_pinfo($node,"EdgeLabelWidth",$edgeLabelWidth);
    $self->store_node_pinfo($node,"After",$xSkipAfter);
    $minxpos=0;
    if ($prevnode[$level]) {
      $minxpos=
	$self->get_node_pinfo($prevnode[$level],"XPOS")+
	$self->get_node_pinfo($prevnode[$level],"After")+$xSkipBefore;
    } else {
      $minxpos=$baseXPos+$xSkipBefore;
    }
    $xpos=max($xpos,$minxpos)+$nodeXSkip;
    $self->store_node_pinfo($node,"XPOS",$xpos);
    $self->store_node_pinfo($node,"NodeLabel_XPOS",$xpos+$nodeLabelXShift);

    $canvasWidth = max($canvasWidth,$xpos+$xSkipAfter+$nodeWidth+2*$self->get_xmargin+$baseXPos);

    $prevnode[$level]=$node;
  }

  $self->{canvasWidth}=$canvasWidth;
  $self->{canvasHeight}=$self->get_baseYPos
		     + ($maxlevel+1)*(2*($nodeYSkip +
					 $self->get_ymargin)
		     + $pattern_count*$fontHeight
		     + $nodeHeight);
}

sub which_text_color {
  my ($self,$fsfile,$arg)=@_;
  return undef unless $fsfile;
  return $self->get_textColor unless ($self->get_highlightAttributes);

  my $color = $fsfile->FS->color($arg);
  return ($color=~/^(?:Shadow|Hilite|XHilite)$/) ? $self->{"textColor".$color} : $self->get_textColor;
}

sub node_box_options {
  my ($self,$node,$fs,$currentNode,$edge)=@_;
  if ($edge) {
    return (-fill =>
	    ($currentNode eq $node) ?
	    $self->get_currentEdgeBoxColor :
	    ($fs->isHidden($node) ?
	     $self->get_hiddenEdgeBoxColor :
	     $self->get_edgeBoxColor)
	   );
  } else {
    return (-fill =>
	    ($currentNode eq $node) ?
	    $self->get_currentBoxColor :
	    ($fs->isHidden($node) ?
	     $self->get_hiddenBoxColor :
	     $self->get_boxColor)
	   );
  }
}


sub node_coords {
  my ($self,$node,$currentNode)=@_;
  my $Opts=$self->get_gen_pinfo("Opts");
  my ($nw,$nh)=
    (($currentNode eq $node) ? $self->get_currentNodeWidth : $self->get_nodeWidth,
     ($currentNode eq $node) ? $self->get_currentNodeHeight : $self->get_nodeHeight);
  $nw+=$self->get_style_opt($node,"Node","-addwidth",$Opts);
  $nh+=$self->get_style_opt($node,"Node","-addheight",$Opts);
  my $x=$self->get_node_pinfo($node,"XPOS");
  my $y=$self->get_node_pinfo($node,"YPOS");

  return ($x-$nw/2,
	  $y-$nh/2,
	  $x+$nh/2,
	  $y+$nw/2);

}

sub node_options {
  my ($self,$node,$fs,$current_node)=@_;
  return (-outline => $self->get_nodeOutlineColor,
	  -fill =>
	  ($current_node eq $node) ?
	  $self->get_currentNodeColor :
	  ($fs->isHidden($node) ?
	   $self->get_hiddenNodeColor :
	   $self->get_nodeColor)
	 );
}

sub wrappedLines {
  my ($self,$text,$width)=@_;
  use integer;
  my $spacew=$self->getTextWidth(" ");
  my @toks = map {$self->getTextWidth($_)} split /\s+/, $text;
  my $wd=shift @toks;
  my $lines=1;
  foreach (@toks) {
    if ($wd+$spacew+$_<$width) { $wd+=$spacew+$_; } else { $wd=$_; $lines++; }
  }
  return $lines;
}

sub wrapLines {
  my ($self,$text,$width)=@_;
  use integer;
  my @toks = split /\s+/, $text;
  my $line=shift @toks;
  my $wd=$self->getTextWidth($line);
  my @lines=();
  my $w;
  foreach (@toks) {
    $w=$self->getTextWidth(" $_");
    if ($wd+$w<$width) {
      $wd+=$w;
      $line.=" $_";
    } else {
      $wd=$self->getTextWidth("$_");
      push @lines,$line;
      $line=$_;
    }
  }
  return @lines,$line;
}


sub get_style_opt {
  my ($self,$node,$style,$opt,$opts)=@_;
  my $s=$self->get_node_pinfo($node,"style-$style");
  my %h=(@{$opts->{$style}}, (ref($s) ? @$s : ()));
  return $h{$opt};
}

sub apply_style_opts {
  my ($self, $item)=(shift,shift);
  eval { $self->canvas->itemconfigure($item,@_); };
  return $@;
}

sub apply_stored_style_opts {
  my ($self, $item, $node)=@_;
  my $Opts=$self->get_gen_pinfo("Opts");
  
  eval { $self->canvas->
	   itemconfigure($self->get_node_pinfo($node,"Oval"),
			 @{$Opts->{$item}},
			 $self->get_node_style($node,$item)); };
  return $@;
}

sub get_node_style {
  my ($self,$node,$style)=@_;
  my $s=$self->get_node_pinfo($node,"style-$style");
  return $s ? @{$s} : ();
}

sub redraw {
  my ($self,$fsfile,$currentNode,$nodes,$valtext)=@_;
  my $node;
  my $style;
  my $parent;
  my $node_has_box;
  my $edge_has_box;
  my ($x_edge_delta,
      $x_edge_length,
      $y_edge_length,
      $edgeLabelWidth,
      $edgeLabelHeight,
      $halign_edge,
      $valign_edge
     );


  my (@node_patterns,@edge_patterns,@style_patterns,@patterns);

  my %Opts = (
	      Oval            =>  [],
	      TextBox         =>  [],
	      EdgeTextBox     =>  [],
	      Line            =>  [],
	      SentenceText    =>  [],
	      SentenceLine    =>  [],
	      SentenceFileInfo=>  [],
	      Text            =>  [],
	      TextBg          =>  [],
	      EdgeTextBg      =>  [],
	      Node            =>  [],
	      NodeLabel       =>  [-valign => 'top', -halign => 'left'],
	      EdgeLabel       =>  [-halign => 'center', -valign => 'top']
	     );

  if (ref($fsfile)) {
    @node_patterns=$self->get_label_patterns($fsfile,"node");
    @edge_patterns=$self->get_label_patterns($fsfile,"edge");
    @style_patterns=$self->get_label_patterns($fsfile,"style");
    @patterns=$fsfile->patterns();
  }

  $self->clear_pinfo();
  $self->store_gen_pinfo("Opts",\%Opts);

  #------------------------------------------------------------
  #{
  #use Benchmark;
  #my $t0= new Benchmark;
  #for (my $i=0;$i<=50;$i++) {
  #------------------------------------------------------------

  my $pstyle;
  $node=$nodes->[0];
  if ($node) {
    # only for root node if any
    foreach $style ($self->get_label_patterns($fsfile,"rootstyle")) {
      foreach ($self->interpolate_text_field($node,$style)=~/\#\{([^\}]+)\}/g) {
  	if (/^(Oval|TextBox|EdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|EdgeTextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-.+):'?(.+)'?$/) {
	  if (exists $Opts{"$1$2"}) {
	    push @{$Opts{"$1$2"}},$3=>$4;
	  } else {
	    $Opts{"$1$2"}=[$3=>$4];
	  }
	}
      }
    }
  }
  # styling patterns should be interpolated here for each node and
  # the results stored within node_pinfo

  foreach $style (@style_patterns) {
    foreach $node (@{$nodes}) {
      foreach ($self->interpolate_text_field($node,$style)=~/\#\{([^\}]+)\}/g) {
	if (/^(Oval|TextBox|EdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|EdgeTextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-.+):(.+)$/) {
	  $pstyle=$self->get_node_pinfo($node,"style-$1$2");
	  if ($pstyle) {
	    push @$pstyle,$3=>$4; # making it unique would certainly slow it down
	  } else {
	    $self->store_node_pinfo($node,"style-$1$2",[$3 => $4]);
	  }
	}
      }
    }
  }

  #------------------------------------------------------------
  #}
  #my $t1= new Benchmark;
  #my $td= timediff($t1, $t0);
  #print "Applying styles the code took:",timestr($td),"\n";
  #}
  #------------------------------------------------------------


  #------------------------------------------------------------
  #{
  #use Benchmark;
  #my $t0= new Benchmark;
  #for (my $i=0;$i<=50;$i++) {
  #------------------------------------------------------------

  recalculate_positions($self,$fsfile,$nodes,\%Opts);

  #------------------------------------------------------------
  #}
  #my $t1= new Benchmark;
  #my $td= timediff($t1, $t0);
  #print "recalculate_positions: the code took:",timestr($td),"\n";
  #}
  #------------------------------------------------------------

  $self->canvas->configure(-scrollregion =>['0c', '0c', $self->{canvasWidth}, $self->{canvasHeight}]);
  $self->canvas->configure(-background => $self->get_backgroundColor) if (defined $self->get_backgroundColor);
  $self->canvas->addtag('delete','all');
  $self->canvas->delete('delete');

  $self->store_gen_pinfo('lastX' => 0);
  $self->store_gen_pinfo('lastY' => 0);

  # Something like redraw_hook should be called here

  if ($self->get_drawSentenceInfo) {
    return unless $fsfile;
    my $currentfile=filename($fsfile->filename);
    my $fontHeight=$self->getFontHeight();
    $valtext=~s/ +([.,!:;])|(\() |(\)) /$1/g;

    if ($valtext=~/^(.*)\/([^:]*):\s*(.*)/) {
      my $ftext="File: $currentfile, tree $1 of $2";
      my $vtext=$3;
      $self->apply_style_opts(
			      $self->canvas->
			      createText(0,
					 $self->{canvasHeight},
					 -font => $self->get_font,
					 -text => $ftext,
					 -justify => 'left', -anchor => 'nw'),
			      @{$Opts{SentenceText}});
      $self->{canvasHeight}+=$fontHeight;
      $self->{canvasWidth}=max($self->{canvasWidth},$self->getTextWidth($ftext));
      $self->apply_style_opts(
			      $self->canvas->
			      createLine(0,$self->{canvasHeight},
					 $self->getTextWidth($ftext),
					 $self->{canvasHeight}),
			      @{$Opts{SentenceLine}});
      $self->{canvasHeight}+=$fontHeight;
      foreach ($self->wrapLines($vtext,$self->{canvasWidth})) {
	$self->apply_style_opts(
				$self->canvas->
				createText(0,$self->{canvasHeight},
					   -font => $self->get_font,
					   -text => $_,
					   -justify => 'left',
					   -anchor => 'nw'),
				@{$Opts{SentenceFileInfo}});
	$self->{canvasHeight}+=$fontHeight;
      }

    }
  }

  my $lineHeight=$self->getFontHeight();
  my $edge_label_yskip= (scalar(@node_patterns) ? $self->get_edgeLabelSkipAbove : 0);
  foreach $node (@{$nodes}) {
    # Something like draw_node_hook should be called here
    $parent=$node->parent;
    use integer;
    if ($parent) {
      my $line=
	$self->canvas->createLine($self->get_node_pinfo($node,"XPOS"),
				  $self->get_node_pinfo($node,"YPOS"),
				  $self->get_node_pinfo($parent,"XPOS"),
				  $self->get_node_pinfo($parent,"YPOS"),
				  '-arrow' =>  $self->get_lineArrow,
				  '-width' =>  $self->get_lineWidth,
				  '-fill' =>   $self->get_lineColor);
      $self->apply_style_opts($line,@{$Opts{Line}},
				  $self->get_node_style($node,"Line"));
      $self->store_node_pinfo($node,"Line",$line);
      $self->store_obj_pinfo($line,$node);
      $self->realcanvas->lower($line,'all');
    }

    ## The Nodes ##
    my $oval=$self->canvas->createOval($self->node_coords($node,$currentNode),
				       $self->node_options($node,
							   $fsfile->FS,
							   $currentNode));
    $self->apply_style_opts($oval,@{$Opts{Oval}},
				       $self->get_node_style($node,"Oval"));
    $self->canvas->addtag('point', 'withtag', $oval);
    $self->store_node_pinfo($node,"Oval",$oval);
    $self->store_obj_pinfo($oval,$node);


    if (scalar(@edge_patterns) and $node->parent) {
      $y_edge_length=
	($self->get_node_pinfo($node->parent, "YPOS")-
	 $self->get_node_pinfo($node,"YPOS"));
      $x_edge_length=
	($self->get_node_pinfo($node->parent, "XPOS")-
	 $self->get_node_pinfo($node,"XPOS"));
      $x_edge_delta=(($self->get_node_pinfo($node, "EdgeLabel_YPOS")
		      -$self->get_node_pinfo($node, "YPOS"))*$x_edge_length)/$y_edge_length;

      # the reference point for edge label is now
      # X: $self->get_node_pinfo($node,"XPOS")+$x_edge_delta
      #	Y: $self->get_node_pinfo($node,"EdgeLabel_YPOS")

      $halign_edge=$self->get_style_opt($node,"EdgeLabel","-halign",\%Opts);
      $valign_edge=$self->get_style_opt($node,"EdgeLabel","-valign",\%Opts);

      $edgeLabelWidth=$self->get_node_pinfo($node,"EdgeLabelWidth");
      $edgeLabelHeight=$self->get_node_pinfo($node,"EdgeLabelHeight");
      if ($halign_edge eq "left") {
	$x_edge_delta-=$edgeLabelWidth;
      } elsif ($halign_edge eq "center") {
	$x_edge_delta-=$edgeLabelWidth/2;
      }
      if ($valign_edge eq "bottom") {
	$x_edge_delta+=($edgeLabelHeight*$x_edge_length)/$y_edge_length;
      } elsif ($valign_edge eq "center") {
	$x_edge_delta+=(($edgeLabelHeight*$x_edge_length)/$y_edge_length)/2;
      }
    }
    $node_has_box=
      $self->get_drawBoxes 
      && ($valign_edge=$self->get_style_opt($node,"NodeLabel","-nodrawbox",\%Opts) ne "yes")
      || !$self->get_drawBoxes
      && ($valign_edge=$self->get_style_opt($node,"NodeLabel","-drawbox",\%Opts) eq "yes");
    $self->store_node_pinfo($node,"NodeHasBox",$node_has_box);
    ## Boxes around attributes
    if ($node_has_box) {
      ## get maximum width stored here by recalculate_positions
      my $textWidth=$self->get_node_pinfo($node,"NodeLabelWidth");
      my $box=
	$self->canvas->
	  createRectangle($self->get_node_pinfo($node,"NodeLabel_XPOS")-
			  $self->get_xmargin,
			  $self->get_node_pinfo($node,"NodeLabel_YPOS")-
			  $self->get_ymargin,
			  $self->get_node_pinfo($node,"NodeLabel_XPOS")+
			  $textWidth+$self->get_xmargin,
			  $self->get_node_pinfo($node,"NodeLabel_YPOS")+
			  $self->get_ymargin+
			  scalar(@node_patterns)*$lineHeight);
      $self->apply_style_opts($box,
			      $self->node_box_options($node,$fsfile->FS,
						      $currentNode,0),
			      @{$Opts{TextBox}},
			      $self->get_node_style($node,"TextBox"));
      $self->store_node_pinfo($node,"TextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }
    $edge_has_box=
      scalar(@edge_patterns) && $node->parent &&
	($self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-nodrawbox",\%Opts) ne "yes") ||
	 !$self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-drawbox",\%Opts) eq "yes"));
    $self->store_node_pinfo($node,"EdgeHasBox",$edge_has_box);
    if ($edge_has_box) {
      ## get maximum width stored here by recalculate_positions
      my $box=
	$self->canvas->
	  createRectangle($self->get_node_pinfo($node,"XPOS")-
			  $self->get_xmargin+$x_edge_delta,

			  $self->get_node_pinfo($node,"EdgeLabel_YPOS")
			  -$self->get_ymargin,

			  $self->get_node_pinfo($node,"XPOS")+
			  $self->get_xmargin+$x_edge_delta+$edgeLabelWidth,

			  $self->get_node_pinfo($node,"EdgeLabel_YPOS")
			  +$self->get_ymargin
			  +scalar(@edge_patterns)*$lineHeight);
      $self->apply_style_opts($box,
			      $self->node_box_options($node,
						      $fsfile->FS,
						      $currentNode,1),
			      @{$Opts{EdgeTextBox}},
			      $self->get_node_style($node,"EdgeTextBox"));

      $self->store_node_pinfo($node,"EdgeTextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }

    ## Texts of attributes
    my ($msg,$x,$y);
    my ($e_i,$n_i)=(0,0);
    my ($pat_class,$pat);
    for (my $i=0;$i<=$#patterns;$i++) {
      ($pat_class,$pat)=$self->parse_pattern($patterns[$i]);
      $msg=encode($self->interpolate_text_field($node,$pat));
      if ($pat_class eq "edge") {
	if ($node->parent) {
	  $msg =~ s!/!!g;		# should be done in interpolate_text_field
	  $x=$self->get_node_pinfo($node,"XPOS")+$x_edge_delta;
	  $y=$self->get_node_pinfo($node,"EdgeLabel_YPOS")+$e_i*$lineHeight;
	  $self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
				!$edge_has_box, \%Opts);
	  $e_i++;
	}
      } elsif ($pat_class eq "node") {
	$x=$self->get_node_pinfo($node,"NodeLabel_XPOS");
	$y=$self->get_node_pinfo($node,"NodeLabel_YPOS")+$n_i*$lineHeight;
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
			      !$node_has_box, \%Opts);
	$n_i++;
      }
    }
  }

  ## Canvas Custom Balloons ##
  if ($fsfile) {
    my $hint=$fsfile->hint;
    if ($self->get_CanvasBalloon) {
      $self->get_CanvasBalloon()->
	attach($self->canvas->Subwidget('scrolled'),
	       -balloonposition => 'mouse',
	       -msg =>
	       {
		map { 
		  if (defined($_)) {
		    my $node=$self->get_obj_pinfo($_);
		    my $msg=
		      $self->interpolate_text_field($node,
						    $hint);
		    $msg=~s/\${([^}]+)}/$node->{$1}/eg;
		    $_ => encode($msg);
		  }
		} $self->canvas->find('withtag','point')
	       });
    }
  }
}




sub draw_text_line {
  my ($self,$fsfile,$node,$i,$msg,
      $lineHeight,$x,$y,$clear,$Opts)=@_;

#  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
  
  ## Clear background
  if ($clear) {
    my $bg=
      $self->canvas->
	createRectangle($x,$y,
			$x+$self->get_node_pinfo($node,"X[$i]")+1,
			$y+$lineHeight,
			-fill => $self->canvas->cget('-background'),
			-outline => undef,
			$self->get_node_style($node,"TextBg"),
			$self->get_node_style($node,"TextBg[$i]")
		       );
    $self->store_node_pinfo($node,"TextBg[$i]",$bg);
    $self->store_obj_pinfo($bg,$node);
    $self->canvas->addtag('textbg', 'withtag', $bg);
  }

  ## Draw attribute
  ## Custom version (the tredish)
  ##
  ## in this case we use the following syntax:
  ## #{color} changes color of all the following text
  ## ${attribute} is expanded to the value of attribute (and the
  ##              text is made active, so that modification is possible)
  ## <?code?>     expands to the return value of the imbedded perl-code
  ##              ($${attribute} may be used inside the code and is expanded
  ##              to 'value'. \${attribute} is not interpolated before <?code?>,
  ##              but may be used in return value and is interpolated later).
  ##              Usage of ${attribute} would be in collision with perl syntax,
  ##              and would refer only to $attribute variable, if any such
  ##              exists.
  
  my $xskip=0;
  my $txt;
  my $at_text;
  my $j=0;
  my $color=undef;
  foreach (split(m'([#$]{[^}]+})',$msg)) {
    if (/^\${([^}]+)}$/) {
      $j++;
      $at_text=$self->prepare_text_field($node,$1);
      $txt=$self->canvas->
	createText($x+$xskip, $y,
		   -anchor => 'nw',
		   -text => $at_text,
		   -fill =>
		   defined($color) ? $color :
		   $self->which_text_color($fsfile,$1),
		   -font => $self->get_font);
      $self->apply_style_opts($txt,
		   @{$Opts->{Text}},
		   @{$Opts->{"Text[$1]"}},
		   @{$Opts->{"Text[$1][$i]"}},
		   @{$Opts->{"Text[$1][$i][$j]"}},
		   $self->get_node_style($node,"Text"),
		   $self->get_node_style($node,"Text[$1]"),
		   $self->get_node_style($node,"Text[$1][$i]"),
		   $self->get_node_style($node,"Text[$1][$i][$j]"));
      $xskip+=$self->getTextWidth($at_text);
      $self->canvas->addtag('text', 'withtag', $txt);
      $self->store_obj_pinfo($txt,$node);
      $self->store_node_pinfo($node,"Text[$1][$i][$j]",$txt);
#      print "Text[$1][$i][$j]\n";
      $self->store_gen_pinfo("attr:$txt",$1);
    } elsif (/^\#{([^}]+)}$/) {
      unless ($self->get_noColor) {
	my $c=$1;
	if ($c=~m/^(.+)(-.+):(.+)$/) {
	  # Depreciated ! Use style pattern!
	  eval {
	    $self->canvas->
	      itemconfigure($self->get_node_pinfo($node,$1),$2 => $3);
	  };
	  warn $@ if $@;
	} else {
	  $color=$c;
	  $color=undef if ($color eq 'default');
	  print "Setting color to $color\n";
	  $color=$self->get_customColors->[$1] if ($color=~/^custom([0-9])$/);
	  print "Setting color to $color\n";
	}
      }
    } else {
      if ($_ ne "") {
	$txt=$self->canvas->
	  createText($x+$xskip,
		     $y,
		     -text => $_,
		     -font => $self->get_font);
	$self->apply_style_opts($txt,
				-anchor => 'nw',
				-fill =>
				defined($color) ? $color : $self->get_textColor,
				@{$Opts->{Text}},
				$self->get_node_style($node,"Text"));
	$xskip+=$self->getTextWidth($_);
      }
    }
  }
}

sub parse_pattern {
  my ($self,$pattern)=@_;
  if ($pattern=~/^([a-z]+):/) {
    return lc($1),$';
  } else {
    return "node",$pattern;
  }
}

sub is_pattern_of {
  my ($self,$style,$pattern)=@_;
  return ($self->parse_pattern($pattern))[0] eq lc($style);
}

sub get_label_patterns {
  my ($self,$fsfile,$style)=@_;
  $style=lc($style);
  return map {
    my ($a,$b)=$self->parse_pattern($_);
    $a eq $style ? $b : ()
  } $fsfile->patterns();
}


=pod

=item prepare_text (fsfile,node,pattern)

Interpolate given pattern for the given node,
by evaluating all code (`<? code ?>') and 
attribute (`${attribute}') fields, removing all
formatting references of the form #{format}.

=cut

sub prepare_text {
  my ($self,$node,$pattern)=@_;
  return "" unless ref($node);
  my $msg=$self->interpolate_text_field($node,$pattern);
  $msg=~s/\#{[^}]+}//g;
  $msg=~s/\${([^}]+)}/$self->prepare_raw_text_field($node,$1)/eg;
  return encode($msg);
}

=pod

=item interpolate_text_field (node,text)

Interpolate, evaluate and substitute the results for
all code references of the form `<? code ?>' in the given
text.

=cut

sub interpolate_text_field {
  my ($self,$node,$text)=@_;
  # make root visible for the evaluated expression
  my $root=$node; $root=$root->parent while ($root->parent);
  $text=~s/\<\?((?:[^?]|\?[^>])+)\?\>/eval $self->interpolate_refs($node,$1)/eg;
  return $text;
}

=pod

=item interpolate_refs (node, text)

Interpolate any attribute references of the form `$${attribute}'
in the text with the single-quotted value. 

=cut

sub interpolate_refs {
  my ($self,$node,$text)=@_;
  $text=~s/\$\${([^}]+)}/"'".$node->{$1}."'"/eg;
  return $text;
}

=pod

=item prepare_text_field (node,attribute)

Return the first (of possibly multiple) value of the given node's
attribute. The value is appended by "*" character if more values
exist.

=cut

sub prepare_text_field {
  my ($self,$node,$atr)=@_;
  my $text=$node->{$atr};
  $text=$1."*" if ($text =~/^([^\|]*)\|/);
  return encode($text);
}

=pod

=item prepare_raw_text_field (node,attribute)

As prepare_text_field but not recoding text to output encoding.

=cut

sub prepare_raw_text_field {
  my ($self,$node,$atr)=@_;
  my $text=$node->{$atr};
  $text=$1."*" if ($text =~/^([^\|]*)\|/);
  return $text;
}

1;



