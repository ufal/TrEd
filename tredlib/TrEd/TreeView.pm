package TrEd::TreeView;

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
  currentBoxColor currentNodeHeight currentNodeWidth customColors
  drawBoxes drawSentenceInfo font hiddenBoxColor highlightAttributes
  lineArrow lineColor lineWidth noColor nodeHeight nodeWidth nodeXSkip
  nodeYSkip pinfo textColor xmargin nodeOutlineColor nodeColor
  hiddenNodeColor nearestNodeColor ymargin currentNodeColor
  textColorShadow textColorHilite textColorXHilite);

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { pinfo => {}, canvas => shift, @_ };
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
# prepare value line and node list with deleted/saved hidden
# and ordered by real Ord

  my ($self,$fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  my $nodes=[];
  return $nodes unless ref($fsfile);

  my @unsorted=();
  $tree_no=0 if ($tree_no<0);
  $tree_no=$fsfile->lastTreeNo if ($tree_no>$fsfile->lastTreeNo);

  my $root=$fsfile->treeList->[$tree_no];
  my $node=$root;
  my $current=$root;

  while($node)
  {
    push @unsorted, $node;
    $current=$node if ($prevcurrent eq $node);
    $node=$show_hidden ? $node->following() : $node->following_visible($fsfile->FS);
  }

  my $ord=$fsfile->FS->order;
  @{$nodes}=
    sort { $a->{$ord} <=> $b->{$ord} }
      @unsorted;

  # just for sure
  undef @unsorted;
  # this is actually a workaround for TR, where two different nodes
  # may have the same Ord
  return $nodes,$current;
}



sub recalculate_positions {
  my ($self,$fsfile,$nodes)=@_;
  return unless ref($self);

  my $xpos=$self->get_baseXPos;
  my $ypos;

  my $minxpos;			# used temporarily to place a node far
                                # enough from its left neighbour

  my $maxypos;			# has different meaning from $minxpos;
                                # this one's used for canvasHeight
  my $canvasWidth=0;
  my $node;
  my $pattern_count=0;
  $pattern_count=$fsfile->pattern_count if (ref($fsfile));

  my $fontHeight=$self->canvas->fontMetrics($self->get_font, -linespace);
  my %prevnode=();
  my $parent;

  $maxypos=0;
  foreach $node (@{$nodes}) {
    $ypos=0;
    $parent=$node->parent;
    while ($parent) {
      $ypos++;
      $parent=$parent->parent;
    }
    $maxypos=max($maxypos,$ypos);
    $node->{"_tkYPOS_"}=$self->get_baseYPos
		+ $ypos*(2*($self->get_nodeYSkip+$self->get_ymargin)
		+ $pattern_count*$fontHeight
		+ $self->get_nodeHeight);

    my $textWidth=0;
    my $m;
    for (my $i=0;$i<$pattern_count;$i++) {
      $m=$self->canvas->fontMeasure($self->get_font,$self->prepare_text($fsfile,$node,$i));
      $node->{"_tkX_$i"}=$m;
      $textWidth=$m if $m>$textWidth;
    }
    $node->{"_tkXWidth_"}=$textWidth;
    $minxpos=0;
    if ($prevnode{$ypos}) {
      $minxpos=$prevnode{$ypos}{"_tkXPOS_"}+$prevnode{$ypos}{"_tkXWidth_"}+
	$self->get_nodeXSkip+$self->get_nodeWidth+2*$self->get_xmargin;
    }
    $xpos=max($xpos,$minxpos);
    $node->{"_tkXPOS_"}=$xpos;
    $xpos+=$self->get_nodeXSkip+$self->get_nodeWidth;
    $canvasWidth = max($canvasWidth, $node->{"_tkXPOS_"}
		       + $node->{"_tkXWidth_"}
		       + $self->get_baseXPos
		       + $self->get_nodeWidth
		       + 2*$self->get_xmargin
		       + $self->get_nodeXSkip);

    $prevnode{$ypos}=$node;
  }
  $self->{'canvasWidth'}=$canvasWidth;
  $self->{'canvasHeight'}=$self->get_baseYPos
		     + ($maxypos+1)*(2*($self->get_nodeYSkip + $self->get_ymargin)
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
  my ($self,$node,$fs,$currentNode)=@_;
  return (-fill =>
	  ($currentNode eq $node) ?
	  $self->get_currentBoxColor :
	  ($fs->isHidden($node) ?
	   $self->get_hiddenBoxColor :
	   $self->get_boxColor)
	 );
}


sub node_coords {
  my ($self,$node,$currentNode)=@_;
  my ($nw,$nh)=
    (($currentNode eq $node) ? $self->get_currentNodeWidth : $self->get_nodeWidth,
     ($currentNode eq $node) ? $self->get_currentNodeHeight : $self->get_nodeHeight);

  return ($node->{"_tkXPOS_"}+($self->get_nodeWidth-$nw)/2,
	  $node->{"_tkYPOS_"}+($self->get_nodeHeight-$nh)/2,
	  $node->{"_tkXPOS_"}+$nh,
	  $node->{"_tkYPOS_"}+$nw);
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
  return $self->fontMeasure($self->get_font,$text)/$width + 1;
}


sub redraw {
  my ($self,$fsfile,$currentNode,$nodes,$valtext)=@_;
  my $node;
  my $parent;

  my @displayAttrs;
  @displayAttrs=$fsfile->patterns() if (ref($fsfile));

  foreach $node (@{$nodes}) {
    foreach (keys(%$node)) {
      delete $node->{$_} if (/^_tk(?:X|Text)/);
    }
  }
  recalculate_positions($self,$fsfile,$nodes);

  $self->canvas->configure(-scrollregion =>['0c', '0c', $self->{canvasWidth}, $self->{canvasHeight}]);
  $self->canvas->configure(-background => $self->get_backgroundColor) if (defined $self->get_backgroundColor);
  $self->canvas->addtag('delete','all');
  $self->canvas->delete('delete');

  $self->set_pinfo({lastX => 0, lastY => 0});

  if ($self->get_drawSentenceInfo) {
    return unless $fsfile;
    my $currentfile=filename($fsfile->filename);
    my $fontHeight=$self->canvas->fontMetrics($self->get_font, -linespace);
    $valtext=~s/ +([.,!:;])|(\() |(\)) /$1/g;

    if ($valtext=~/^(.*)\/([^:]*):\s*(.*)/) {
      my $ftext="File: $currentfile, tree $1 of $2";
      my $vtext=$3;
      $self->canvas->createText(0,$self->{canvasHeight},-font => $self->get_font,-text => $ftext,
				   -justify => 'left', -anchor => 'nw');
      $self->{canvasHeight}+=$fontHeight;
      $self->{canvasWidth}=max($self->{canvasWidth},$self->canvas->fontMeasure($self->get_font,$ftext));
      $self->canvas->createLine(0,$self->{canvasHeight},
				   $self->canvas->fontMeasure($self->get_font,$ftext),
				   $self->{canvasHeight});
      $self->{canvasHeight}+=$fontHeight;
      $self->canvas->createText(0,$self->{canvasHeight},-font => $self->get_font,-text => $vtext,
				   -justify => 'left', -anchor => 'nw',
				   -width => $self->{canvasWidth});
      $self->{canvasHeight}+=$fontHeight*($self->wrappedLines($vtext,$self->{canvasWidth})+2);
#      $self->canvas->createLine(0,$self->{canvasHeight},$self->{canvasWidth},$self->{canvasHeight});

    }
  }

  foreach $node (@{$nodes}) {
    $parent=$node->parent;
    use integer;
    if ($parent) {
      $node->{"_tkLine_"}=$self->canvas->createLine($node->{"_tkXPOS_"}+$self->get_nodeWidth/2,
					     $node->{"_tkYPOS_"}+$self->get_nodeHeight/2,
					     $parent->{"_tkXPOS_"}+$self->get_nodeWidth/2,
					     $parent->{"_tkYPOS_"}+$self->get_nodeHeight/2,
						      '-arrow' =>$self->get_lineArrow,
						     '-width' => $self->get_lineWidth,
						     '-fill' => $self->get_lineColor);
      $self->pinfo->{$node->{"_tkLine_"}}=$node;
    }
  }

  my $lineHeight=$self->canvas->fontMetrics($self->get_font, -linespace);
  ## The Nodes ##
  foreach $node (@{$nodes}) {
    $node->{"_tkOval_"}=$self->canvas->createOval($self->node_coords($node,$currentNode),
						 $self->node_options($node,$fsfile->FS,$currentNode));
    $self->canvas->addtag('point', 'withtag', $node->{"_tkOval_"});


    ## Boxes around attributes
    if ($self->get_drawBoxes) {
      ## get maximum width stored here by recalculate_positions
      my $textWidth=$node->{'_tkXWidth_'};
      $node->{"_tkTextBox_"}=
	$self->canvas->
	  createRectangle($node->{"_tkXPOS_"}-$self->get_xmargin,
			  $node->{"_tkYPOS_"}+$self->get_nodeHeight+$self->get_nodeYSkip-$self->get_ymargin,
			  $node->{"_tkXPOS_"}+$textWidth+$self->get_xmargin,
			  $node->{"_tkYPOS_"}+
			  ($#displayAttrs+1)*$lineHeight+
			  $self->get_nodeHeight+$self->get_nodeYSkip+$self->get_ymargin,
			  $self->node_box_options($node,$fsfile->FS,$currentNode));
    }

    ## Texts of attributes
    for (my $i=0;$i<=$#displayAttrs;$i++) {

      ## Clear background
      $node->{"_tkTextBg".$i."_"}=
	$self->canvas->
	  createRectangle($node->{"_tkXPOS_"},
			  $node->{"_tkYPOS_"}+$self->get_nodeHeight+$self->get_nodeYSkip+
			  $i*$lineHeight-2,
			  $node->{"_tkXPOS_"}+$node->{"_tkX_$i"}+1,
			  #$self->canvas->fontMeasure($self->get_font,$self->prepare_text($node,$i))+1,
			  $node->{"_tkYPOS_"}+$self->get_nodeHeight+$self->get_nodeYSkip+($i+1)*$lineHeight,
			  -fill => $self->canvas->cget('-background'), -outline => undef)
	  unless ($self->get_drawBoxes);
      $self->canvas->addtag('textbg', 'withtag', $node->{"_tkTextBg".$i."_"});
      $self->pinfo->{$node->{"_tkTextBg".$i."_"}}=$node;

      ## Draw attribute
      ## Custom version (the tredish)
      ##
      ## in this case we use the following syntax:
      ## #{color} changes color of all the following text
      ## ${attribute} is expanded to the value of attribute (and the
      ##              text is made active, so that modification is possible)
      ## <?code?>     expands to the return value of the imbedded perl-code
      ##              ($${attribute} may be used inside the code and is expanded
      ##               to 'value'. \${attribute} is not interpolated before <?code?>,
      ##               but may be used in retur value and is interpolated later)
      my $msg=encode($self->interpolate_text_field($node,$displayAttrs[$i]));
      $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
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
	    createText($node->{"_tkXPOS_"}+$xskip,
		       $node->{"_tkYPOS_"}+
		       $self->get_nodeHeight+$self->get_nodeYSkip+$i*$lineHeight,
		       -anchor => 'nw',
		       -text => $at_text,
		       -fill => defined($color) ? $color : $self->which_text_color($fsfile,$1),
		       -font => $self->get_font);
	  $xskip+=$self->canvas->fontMeasure($self->get_font,$at_text);
	  $self->canvas->addtag('text', 'withtag', $txt);
	  $self->pinfo->{$txt}=$node;
	  $node->{"_tkText[$1][$i][$j]_"}=$txt;
	} elsif (/^\#{([^}]+)}$/) {
	  unless ($self->get_noColor) {
	    $color=$1;
	    $color=undef if ($color eq 'default');
	    $color=$self->get_customColors->[$1] if ($color=~/^custom([0-9])$/);
	  }
	} else {
	  if ($_ ne "") {
	    $txt=$self->canvas->
	      createText($node->{"_tkXPOS_"}+$xskip,
			 $node->{"_tkYPOS_"}+
			 $self->get_nodeHeight+$self->get_nodeYSkip+$i*$lineHeight,
			 -anchor => 'nw',
			 -text => $_,
			 -fill => defined($color) ? $color : $self->get_textColor,
			 -font => $self->get_font);
	    $xskip+=$self->canvas->fontMeasure($self->get_font,$_);
	  }
	}
      }
    }

    $self->pinfo->{$node->{"_tkOval_"}}=$node;
    $self->pinfo->{$node->{"_tkTextBox_"}}=$node if exists $node->{"_tkTextBox_"};
  }

  ## Canvas Custom Balloons ##
  if ($fsfile) {
    my $hint=$fsfile->hint;
    if ($self->get_CanvasBalloon) {
      $self->get_CanvasBalloon()->
	attach($self->canvas->Subwidget('scrolled'),
	       -balloonposition => 'mouse',
	       -msg => { map 
			 {
			   if (defined($_)) {
			     my $msg=$self->interpolate_text_field($self->pinfo->{$_},$hint);
			     $msg=~s/\${([^}]+)}/$self->pinfo->{$_}->{$1}/eg;
			     $_ => encode($msg);
			 }
			 } $self->canvas->find('withtag','point')
		       });
    }
  }
}



sub prepare_text {
  my ($self,$fsfile,$node,$index)=@_;
  return unless ref($fsfile);
  my $msg=$self->interpolate_text_field($node,$fsfile->pattern($index));
  $msg=~s/\#{[^}]+}//g;
  $msg=~s/\${([^}]+)}/$self->prepare_text_field($node,$1)/eg;
  return encode($msg);
}

sub interpolate_text_field {
  my ($self,$node,$text)=@_;
  $text=~s/\<\?((?:[^?]|\?[^>])+)\?\>/eval $self->interpolate_refs($node,$1)/eg;
  return $text;
}

sub interpolate_refs {
  my ($self,$node,$text)=@_;
  $text=~s/\$\${([^}]+)}/"'".$node->{$1}."'"/eg;
  return $text;
}

sub prepare_text_field {
  my ($self,$node,$atr)=@_;
  my $text=$node->{$atr};
  $text=$1."*" if ($text =~/^([^\|]*)\|/);
  return encode($text);
}

1;
