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
  drawSentenceInfo font hiddenBoxColor
  highlightAttributes showHidden lineArrow lineColor lineWidth noColor
  nodeHeight nodeWidth nodeXSkip nodeYSkip pinfo textColor xmargin
  nodeOutlineColor nodeColor hiddenNodeColor nearestNodeColor ymargin
  currentNodeColor textColorShadow textColorHilite textColorXHilite);

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
  }
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
  my ($self,$fsfile,$nodes)=@_;
  return unless ref($self);

  my $xpos=$self->get_baseXPos;
  my $level;

  my $minxpos;			# used temporarily to place a node far
                                # enough from its left neighbour

  my $maxlevel;			# has different meaning from $minxpos;
                                # this one's used for canvasHeight
  my $canvasWidth=0;
  my $node;
  my $textWidth=0;
  my $nodeLabelWidth=0;
  my $edgeLabelWidth=0;
  my $m;

  my ($pattern_count,$node_pattern_count,$edge_pattern_count)=(0,0,0);
				# May change with line attached labels
  if (ref($fsfile)) {
    $pattern_count=$fsfile->pattern_count;
    $node_pattern_count=scalar($self->get_node_label_patterns($fsfile));
    $edge_pattern_count=$pattern_count-$node_pattern_count;
  }

  my $fontHeight=$self->getFontHeight();
  my %prevnode=();
  my $parent;
  my $ypos;
  $maxlevel=0;
  foreach $node (@{$nodes}) {
    $level=0;
    $parent=$node->parent;
    while ($parent) {
      $level++;
      $parent=$parent->parent;
    }
    $maxlevel=max($maxlevel,$level);
    
    if ($edge_pattern_count) {
      $ypos = $self->get_baseYPos
	+ $level*(2*$self->get_nodeYSkip
		  + $self->get_nodeHeight)
	  + 2*$level*(2*$self->get_ymargin
		      + $node_pattern_count*$fontHeight)
	    + $level*(2*$self->get_ymargin
		      + $edge_pattern_count*$fontHeight);
    } else {
      $ypos = $self->get_baseYPos
	+ $level*(2*($self->get_nodeYSkip
		     + $self->get_ymargin)
		  + $node_pattern_count*$fontHeight
		  + $self->get_nodeHeight);

    }
    $self->store_node_pinfo($node,"YPOS", $ypos);

    ($nodeLabelWidth,$edgeLabelWidth,$textWidth)=(0,0,0);
    for (my $i=0;$i<$pattern_count;$i++) {
      $m=$self->getTextWidth($self->prepare_text($fsfile,$node,$i));
      $self->store_node_pinfo($node,"X[$i]",$m);
      if ($self->is_edge_pattern($fsfile->pattern($i))) {
	$edgeLabelWidth=$m if $m>$edgeLabelWidth;
	$m*=2;
      } else {
	$nodeLabelWidth=$m if $m>$nodeLabelWidth;
      }
      $textWidth=$m if $m>$textWidth;
    }
    $self->store_node_pinfo($node,"NodeLabelWidth",$nodeLabelWidth);
    $self->store_node_pinfo($node,"EdgeLabelWidth",$edgeLabelWidth);
    $self->store_node_pinfo($node,"Width",$textWidth);

    $minxpos=0;
    if ($prevnode{$level}) {
      $minxpos=
	$self->get_node_pinfo($prevnode{$level},"XPOS")+
	$self->get_node_pinfo($prevnode{$level},"Width")+
	$self->get_nodeXSkip+$self->get_nodeWidth+2*$self->get_xmargin;
      $minxpos+=2*$self->get_xmargin if ($edge_pattern_count);
    }
    $xpos=max($xpos,$minxpos);
    $self->store_node_pinfo($node,"XPOS",$xpos);
    $xpos+=$self->get_nodeXSkip+$self->get_nodeWidth;
    $canvasWidth = max($canvasWidth,
		       $self->get_node_pinfo($node,"XPOS")
		       + $self->get_node_pinfo($node,"Width")
		       + $self->get_baseXPos
		       + $self->get_nodeWidth
		       + 2*$self->get_xmargin
		       + $self->get_nodeXSkip);

    $prevnode{$level}=$node;
  }

  $self->{canvasWidth}=$canvasWidth;
  $self->{canvasHeight}=$self->get_baseYPos
		     + ($maxlevel+1)*(2*($self->get_nodeYSkip +
					 $self->get_ymargin)
		     + $pattern_count*$fontHeight
		     + $self->get_nodeHeight);
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
  my ($nw,$nh)=
    (($currentNode eq $node) ? $self->get_currentNodeWidth : $self->get_nodeWidth,
     ($currentNode eq $node) ? $self->get_currentNodeHeight : $self->get_nodeHeight);
  my $x=$self->get_node_pinfo($node,"XPOS");
  my $y=$self->get_node_pinfo($node,"YPOS");

  return ($x+($self->get_nodeWidth-$nw)/2,
	  $y+($self->get_nodeHeight-$nh)/2,
	  $x+$nh,
	  $y+$nw);
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


sub redraw {
  my ($self,$fsfile,$currentNode,$nodes,$valtext)=@_;
  my $node;
  my $parent;

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
	      EdgeTextBg      =>  []
	     );

  my (@node_patterns,@edge_patterns,@patterns);

  if (ref($fsfile)) {
    @node_patterns=$self->get_node_label_patterns($fsfile);
    @edge_patterns=$self->get_edge_label_patterns($fsfile);
    @patterns=$fsfile->patterns();
  }

  $self->clear_pinfo();

  # node patterns should be interpolated here and
  # stored within node_pinfo

  recalculate_positions($self,$fsfile,$nodes);

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
      $self->canvas->createText(0,$self->{canvasHeight},-font => $self->get_font,-text => $ftext,
				   -justify => 'left', -anchor => 'nw',
				@{$Opts{SentenceText}});
      $self->{canvasHeight}+=$fontHeight;
      $self->{canvasWidth}=max($self->{canvasWidth},$self->getTextWidth($ftext));
      $self->canvas->createLine(0,$self->{canvasHeight},
				   $self->getTextWidth($ftext),
				   $self->{canvasHeight},
				@{$Opts{SentenceLine}});
      $self->{canvasHeight}+=$fontHeight;
      foreach ($self->wrapLines($vtext,$self->{canvasWidth})) {
	$self->canvas->createText(0,$self->{canvasHeight},
				  -font => $self->get_font,
				  -text => $_,
				  -justify => 'left',
				  -anchor => 'nw',
				 @{$Opts{SentenceFileInfo}});
	$self->{canvasHeight}+=$fontHeight;
      }

    }
  }

  my $lineHeight=$self->getFontHeight();
  my $edge_label_yskip= (scalar(@node_patterns) ? $lineHeight : 0);

  foreach $node (@{$nodes}) {
    my %NodeOpts = {};
    # Something like draw_node_hook should be called here
    $parent=$node->parent;
    use integer;
    if ($parent) {
      my $line=
	$self->canvas->createLine($self->get_node_pinfo($node,"XPOS")+
				  $self->get_nodeWidth/2,
				  $self->get_node_pinfo($node,"YPOS")+
				  $self->get_nodeHeight/2,
				  $self->get_node_pinfo($parent,"XPOS")+
				  $self->get_nodeWidth/2,
				  $self->get_node_pinfo($parent,"YPOS")+
				  $self->get_nodeHeight/2,
				  '-arrow' =>  $self->get_lineArrow,
				  '-width' =>  $self->get_lineWidth,
				  '-fill' =>   $self->get_lineColor,
				  @{$Opts{Line}},
				  @{$NodeOpts{Line}}
				 );
      $self->store_node_pinfo($node,"Line",$line);
      $self->store_obj_pinfo($line,$node);
      $self->realcanvas->lower($line,'all');
    }

    ## The Nodes ##
    my $oval=$self->canvas->createOval($self->node_coords($node,$currentNode),
				       $self->node_options($node,
							   $fsfile->FS,
							   $currentNode),
				       @{$Opts{Oval}},
				       @{$NodeOpts{Oval}}
				      );
    $self->canvas->addtag('point', 'withtag', $oval);
    $self->store_node_pinfo($node,"Oval",$oval);
    $self->store_obj_pinfo($oval,$node);

    my ($x_edge_delta,$y_edge_delta)=(0,0);
    
    if (scalar(@edge_patterns) and $node->parent) {
      $x_edge_delta=
	($self->get_node_pinfo($node->parent, "XPOS")-
	 $self->get_node_pinfo($node,"XPOS"))/2;
      $y_edge_delta=
	($self->get_node_pinfo($node->parent, "YPOS")-
	 $self->get_node_pinfo($node,"YPOS"))/2;
    }

    ## Boxes around attributes
    if ($self->get_drawBoxes) {
      ## get maximum width stored here by recalculate_positions
      my $textWidth=$self->get_node_pinfo($node,"NodeLabelWidth");
      my $box=
	$self->canvas->
	  createRectangle($self->get_node_pinfo($node,"XPOS")-
			  $self->get_xmargin,
			  $self->get_node_pinfo($node,"YPOS")+
			  $self->get_nodeHeight+
			  $self->get_nodeYSkip-$self->get_ymargin,
			  $self->get_node_pinfo($node,"XPOS")+
			  $textWidth+$self->get_xmargin,
			  $self->get_node_pinfo($node,"YPOS")+
			  ($#node_patterns+1)*$lineHeight+
			  $self->get_nodeHeight+$self->get_nodeYSkip+
			  $self->get_ymargin,
			  $self->node_box_options($node,$fsfile->FS,
						  $currentNode,0),
			  @{$Opts{TextBox}},
			  @{$NodeOpts{TextBox}}
			 );
      $self->store_node_pinfo($node,"TextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }
    if ($self->get_drawEdgeBoxes and scalar(@edge_patterns) and $node->parent) {
      ## get maximum width stored here by recalculate_positions
      my $textWidth=$self->get_node_pinfo($node,"EdgeLabelWidth");
      my $box=
	$self->canvas->
	  createRectangle($self->get_node_pinfo($node,"XPOS")-
			  $self->get_xmargin+$x_edge_delta,
			  
			  $self->get_node_pinfo($node,"YPOS")+
			  $y_edge_delta+
			  -$self->get_ymargin-
			  (($#edge_patterns+1)*$lineHeight)/2+
			  $edge_label_yskip,
			  
			  $self->get_node_pinfo($node,"XPOS")+
			  $self->get_xmargin+$x_edge_delta+$textWidth,
			  
			  $self->get_node_pinfo($node,"YPOS")+
			  $y_edge_delta+
			  (($#edge_patterns+1)*$lineHeight)/2+
			  $edge_label_yskip+
			  $self->get_ymargin,
			  
			  $self->node_box_options($node,
						  $fsfile->FS,
						  $currentNode,1),
			  @{$Opts{EdgeTextBox}},
			  @{$NodeOpts{EdgeTextBox}}
			 );
      
      $self->store_node_pinfo($node,"EdgeTextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }

    ## Texts of attributes
    my ($msg,$x,$y);
    my ($e_i,$n_i)=(0,0);
    for (my $i=0;$i<=$#patterns;$i++) {
      $msg=encode($self->interpolate_text_field($node,$patterns[$i]));
      if ($self->is_edge_pattern($patterns[$i])) {
	if ($node->parent) {
	  $msg =~ s!/!!g;		# should be done in interpolate_text_field
	  $x=$self->get_node_pinfo($node,"XPOS")+$x_edge_delta;
	  $y=$self->get_node_pinfo($node,"YPOS")+$y_edge_delta+
	    -(($#edge_patterns+1)*$lineHeight)/2
	      +$edge_label_yskip+$e_i*$lineHeight;
	  $self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
				(!$self->get_drawEdgeBoxes &&
				$self->get_clearTextBackground),
				\%Opts,\%NodeOpts);
	  $e_i++;
	}
      } else {
	$x=$self->get_node_pinfo($node,"XPOS");
	$y=$self->get_node_pinfo($node,"YPOS")+
	  $self->get_nodeHeight+$self->get_nodeYSkip+
	    $n_i*$lineHeight;
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
			      (!$self->get_drawBoxes &&
			      $self->get_clearTextBackground),
			      \%Opts,\%NodeOpts);
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
      $lineHeight,$x,$y,$clear,$Opts,$NodeOpts)=@_;

  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
  
  ## Clear background
  if ($clear) {
    my $bg=
      $self->canvas->
	createRectangle($x,$y,
			$x+$self->get_node_pinfo($node,"X[$i]")+1,
			$y+$lineHeight,
			-fill => $self->canvas->cget('-background'),
			-outline => undef,
			@{$Opts->{TextBgBox}},
			@{$Opts->{"TextBgBox_$i"}}
		       );
    $self->store_node_pinfo($node,"TextBg_$i",$bg);
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
  foreach (split(/\#\#\#/,$msg)) {
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
		   -font => $self->get_font,
		   @{$Opts->{Text}},
		   @{$Opts->{"Text[$1]"}},
		   @{$Opts->{"Text[$1][$i]"}},
		   @{$Opts->{"Text[$1][$i][$j]"}},
		   @{$NodeOpts->{Text}},
		   @{$NodeOpts->{"Text[$1]"}},
		   @{$NodeOpts->{"Text[$1][$i]"}},
		   @{$NodeOpts->{"Text[$1][$i][$j]"}}
		  );
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
	  eval {
	    $self->canvas->
	      itemconfigure($self->get_node_pinfo($node,$1),$2 => $3);				       
	  };
	  warn $@ if $@;
	} else {
	  $color=$c;
	  $color=undef if ($color eq 'default');
	  $color=$self->get_customColors->[$color] if ($color=~/^custom([0-9])$/);
	}
      }
    } else {
      if ($_ ne "") {
	$txt=$self->canvas->
	  createText($self->get_node_pinfo($node,"XPOS")+$xskip,
		     $self->get_node_pinfo($node,"YPOS")+
		     $self->get_nodeHeight+$self->get_nodeYSkip+$i*$lineHeight,
		     -anchor => 'nw',
		     -text => $_,
		     -fill => defined($color) ? $color : $self->get_textColor,
		     -font => $self->get_font,
		     @{$Opts->{Text}},
		     @{$NodeOpts->{Text}}
		    );
	$xskip+=$self->getTextWidth($_);
      }
    }
  }
}

sub is_edge_pattern {
  my ($self,$pattern)=@_;
  return substr($pattern,0,1) eq "/";
}

sub get_node_label_patterns {
  my ($self,$fsfile)=@_;
  return grep { !$self->is_edge_pattern($_) } $fsfile->patterns();
}

sub get_edge_label_patterns {
  my ($self,$fsfile)=@_;
  return grep { $self->is_edge_pattern($_) } $fsfile->patterns();
}

=pod

=item prepare_text (fsfile,node,n)

Interpolate the n'th fsfile's pattern for the given node,
by evaluating all code (`<? code ?>') and 
attribute (`${attribute}') fields, removing all
formatting references of the form #{format}.

=cut

sub prepare_text {
  my ($self,$fsfile,$node,$index)=@_;
  return unless ref($fsfile);
  my $msg=$self->interpolate_text_field($node,$fsfile->pattern($index));
  $msg=~s/\#{[^}]+}//g;
  $msg=~s/\${([^}]+)}/$self->prepare_text_field($node,$1)/eg;
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

1;



