package TrEd::TreeView;		# -*- cperl -*-

use Tk;
use Tk::Canvas;
use Tk::Balloon;
use Fslib;
use TrEd::MinMax;
import TrEd::MinMax;

use TrEd::Convert;
import TrEd::Convert;

use vars qw($AUTOLOAD @Options %DefaultNodeStyle $Debug $on_get_root_style $on_get_node_style);

our $objectno;
our ($block, $bblock);
$block=qr/\{((?:(?> [^{}]* )|(??{ $block }))*)\}/x;
$bblock=qr/\{(?:(?> [^{}]* )|(??{ $bblock }))*\}/x;


use strict;

@Options = qw(CanvasBalloon backgroundColor baseXPos baseYPos boxColor
  currentBoxColor currentEdgeBoxColor currentNodeHeight
  currentNodeWidth customColors hiddenEdgeBoxColor edgeBoxColor
  clearTextBackground drawBoxes drawEdgeBoxes backgroundImage
  backgroundImageX backgroundImageY drawSentenceInfo font
  hiddenBoxColor edgeLabelYSkip highlightAttributes showHidden
  lineArrow lineColor hiddenLineColor dashHiddenLines lineWidth
  noColor nodeHeight nodeWidth nodeXSkip nodeYSkip edgeLabelSkipAbove
  edgeLabelSkipBelow pinfo textColor xmargin nodeOutlineColor
  nodeColor hiddenNodeColor nearestNodeColor ymargin currentNodeColor
  textColorShadow textColorHilite textColorXHilite skipHiddenLevels skipHiddenParents
  useAdditionalEdgeLabelSkip reverseNodeOrder balanceTree);

%DefaultNodeStyle = (
	      Oval            =>  [],
	      TextBox         =>  [],
	      EdgeTextBox     =>  [],
	      Line            =>  [ -coords => "n,n,p,p" ],
	      SentenceText    =>  [],
	      SentenceLine    =>  [],
	      SentenceFileInfo=>  [],
	      Text            =>  [],
	      TextBg          =>  [],
	      Node            =>  [-shape => 'oval'],
	      NodeLabel       =>  [-valign => 'top', -halign => 'left'],
	      EdgeLabel       =>  [-halign => 'center', -valign => 'top']
	     );

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { pinfo     => {},	# maps canvas objects to nodes
	      canvas    => shift,
	      patterns  => undef,
	      hint      => undef,
	      @_ };

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

sub set_patterns {
  my ($self,$patterns) = @_;
  die "Patterns are not array-ref" if (defined($patterns) and !ref($patterns) eq 'ARRAY');
  $self->{patterns}=$patterns;
}

sub patterns {
  my $self = shift;
  return undef unless ref($self);
  return $self->{patterns};
}

sub set_hint {
  my ($self,$hint) = @_;
  die "Hint is not scalar-ref" if (defined($hint) and !ref($hint) eq 'SCALAR');
  $self->{hint}=$hint;
}

sub hint {
  my $self = shift;
  return $self->{hint};
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

sub store_id_pinfo {
  my ($self,$obj,$value) = @_;
  return undef unless ref($self);
  $self->{pinfo}->{"id:${obj}"}=$value;
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

sub get_id_pinfo {
  my ($self,$obj) = @_;
  return undef unless ref($self);
  return $self->{pinfo}->{"id:${obj}"};
}

sub node_is_displayed {
  my ($self,$node)=@_;
  my $pinfo = $self->{pinfo};
  return $pinfo->{"node:${node};E"} ? 1 : 0;
}

sub find_item {
  my ($self,$which,$tag)=@_;
  return map { $self->get_id_pinfo($_) } $self->canvas()->find($which,$tag);
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

sub value_line_list {
  my ($self,$fsfile,$tree_no,$no_numbers,$tags,$grp)=@_;
  return () unless $fsfile;

  my @patterns = $self->get_label_patterns($fsfile,"text");
  if (@patterns and $tags) {
    my $node=$fsfile->treeList->[$tree_no];
    my @sent=();
    my $attr=$fsfile->FS->sentord();
    $attr=$fsfile->FS->order() unless (defined($attr));
    while ($node) {
      push @sent,$node unless ($node->getAttribute($attr)>=999); # this is TR specific stuff
      $node=$node->following();
    }
    @sent = sort { $a->getAttribute($attr) <=> $b->getAttribute($attr) } @sent;
    my @vl=();

    foreach $node (@sent) {
      my %styles;
      foreach my $style (@patterns) {
	my $msg=$self->interpolate_text_field($node,$style,$grp);
	foreach (split(m/([\#\$]${bblock})/,$msg)) {
	  if (/^\$${block}$/) {
	    #attr
	    my $val = _present_attribute($node,$1);
	    if ($val ne "") {
	      push @vl,[$val,$node, map { encode("$_ => $styles{$_}") }
			keys %styles];
	    }
	  } elsif (/^\#${block}$/) {
	    #attr
	    my $style=$1;
	    if ($style =~ /-tag:\s*(.*\S)\s*$/) {
	      if ($styles{tag} ne "") {
		$styles{tag}.=",$1";
	      } else {
		$styles{tag}="$1";
	      }
	    } elsif ($style =~ /(-[a-z0-9]+):\s*(.*\S)\s*$/) {
	      $styles{$1} = $2;
	    } else {
	      $styles{-foreground} = $style
	    }
	  } else {
	    push @vl,[$_,$node,'text',map { encode("$_ => $styles{$_}") } keys %styles];
	  }
	}
      }
      push @vl,[" ",'space',];
    }
    return @vl;
  } else {
    if ($tags) {
      return map { ($_,
		    $_->[0] ne "\n" ? ([' ','space']) : ())
		 } $fsfile->value_line_list($tree_no,$no_numbers,$tags,$grp);
    } else {
      return $fsfile->value_line_list($tree_no,$no_numbers,$tags,$grp);
    }
  }
}

sub value_line {
  my ($self,$fsfile,$tree_no,$no_numbers,$tags,$grp)=@_;

  return unless $fsfile;

  my $prfx=($no_numbers ? "" : ($tree_no+1)."/".($fsfile->lastTreeNo+1).": ");

  if ($tags) {
    if ($self->{reverseNodeOrder}) {
      return [[$prfx,'prefix'],
	      map { $_->[0]=encode($_->[0]); $_ } grep { $_->[0] ne "" }
	      reverse $self->value_line_list($fsfile,$tree_no,$no_numbers,1,$grp)];
    } else {
      return [[$prfx,'prefix'],
	      map { $_->[0]=encode($_->[0]); $_ } grep { $_->[0] ne "" }
	      $self->value_line_list($fsfile,$tree_no,$no_numbers,1,$grp)];
    }
  } else {
    if ($self->{reverseNodeOrder}) {
      return $prfx.join " ",
	map { encode($_) } grep { $_ ne "" }
	  reverse $self->value_line_list($fsfile,$tree_no,$no_numbers,0,$grp);
    } else {
      return $prfx.join " ",
	map { encode($_) } grep { $_ ne "" }
	  $self->value_line_list($fsfile,$tree_no,$no_numbers,0,$grp);
    }
  }
}


sub nodes {
  my ($self,$fsfile,$tree_no,$prevcurrent)=@_;
  my ($nodes,$current)=$fsfile->nodes($tree_no,$prevcurrent,$self->get_showHidden());
  if ($self->{reverseNodeOrder}) {
    return ([reverse @$nodes],$current);
  }
  return ($nodes,$current);
}

sub getFontHeight {
  my ($self)=@_;
  return $self->canvas->fontMetrics($self->get_font, -linespace);
}

sub getTextWidth {
  my ($self,$text)=@_;
  return max(map { $self->canvas->fontMeasure($self->get_font,$_) } split /\n/,$text);
}

sub balance_xfix_node {
  my ($self, $xfix, $node) = @_;
  my @c = grep { $self->get_node_pinfo($_,"E") } $node->children;
  $xfix += $self->get_node_pinfo($node,"XFIX");
  foreach my $c (@c) {
    $self->store_node_pinfo($c,"XPOS",
			    $self->get_node_pinfo($c,"XPOS")+
			    $xfix);
    $self->store_node_pinfo($c,"NodeLabel_XPOS",
			    $self->get_node_pinfo($c,"NodeLabel_XPOS")+
			    $xfix);
    balance_xfix_node($self,$xfix,$c);
  }
}

# this routine computes node XPos in balanced mode
sub balance_node {
  my ($self, $baseX, $node, $balanceOpts) = @_;
  my $last_baseX = $baseX;
  my $xskip = $self->get_nodeXSkip;
  my $i=0;
  my $before = $self->get_node_pinfo($node,"Before");
#  $last_baseX+=$self->get_node_pinfo($node,"Before");
  my @c = grep { $self->get_node_pinfo($_,"E") } $node->children;
  foreach my $c (@c) {
    $last_baseX = $self->balance_node($last_baseX,$c,$balanceOpts);
    $last_baseX += $xskip;
  }
  $last_baseX -= $xskip if @c;
  my $xpos;
  if (!@c) {
    $xpos = $last_baseX+$self->get_node_pinfo($node,"XPOS");
  } else {
    if (scalar(@c) % 2 == 1) { # odd number of nodes
      if ($balanceOpts->[0]) { # balance on middle node
	$xpos =$self->get_node_pinfo($c[$#c/2],"XPOS");
      } else {
	$xpos =($self->get_node_pinfo($c[$#c],"XPOS")
		+ $self->get_node_pinfo($c[0],"XPOS"))/2;
      }
    } else { # even number of nodes
      if ($balanceOpts->[1]) {
	$xpos =
	  ($self->get_node_pinfo($c[1+$#c/2],"XPOS") +
	   $self->get_node_pinfo($c[$#c/2],"XPOS"))/2;
      } else {
	$xpos =($self->get_node_pinfo($c[$#c],"XPOS")
		+ $self->get_node_pinfo($c[0],"XPOS"))/2;
      }
    }
  }
  my $xfix = $before-$xpos+$baseX;
  if ($xfix > 0) {
    $last_baseX += $xfix;
    $xpos += $xfix;
  } else {
    $xfix = 0;
  }
  $self->store_node_pinfo($node,"XFIX", $xfix);
  my $add = $xpos-$self->get_node_pinfo($node,"XPOS");
  $self->store_node_pinfo($node,"XPOS", $xpos);

  $self->store_node_pinfo($node,"NodeLabel_XPOS",
			  $self->get_node_pinfo($node,"NodeLabel_XPOS") +
			  $add);
  return max($last_baseX,$xpos+
	     $self->get_node_pinfo($node,"After"));
}

sub recalculate_positions {
  my ($self,$fsfile,$nodes,$Opts,$grp)=@_;
  return unless ref($self);

  my $baseXPos=$Opts->{baseXPos} || $self->get_baseXPos;
  my $baseYPos=$Opts->{baseYPos} || $self->get_baseYPos;
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
  my $nodeXSkip = exists($Opts->{nodeXSkip}) ? $Opts->{nodeXSkip} : $self->get_nodeXSkip;
  my $nodeYSkip = exists($Opts->{nodeYSkip}) ? $Opts->{nodeYSkip} : $self->get_nodeYSkip;
  my $m;

  my ($pattern_count,$node_pattern_count,$edge_pattern_count)=(0,0,0);
				# May change with line attached labels
  my @patterns;
  if ($self->patterns) {
    @patterns=@{$self->patterns};
  } elsif (ref($fsfile)) {
    @patterns=$fsfile->patterns();
  }
  if (ref($fsfile)) {
    $pattern_count=@patterns;
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
  my @zero_level=();
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

#   my %sameasparent;
#   my %sameaschild;
#   my $attr=$fsfile->FS->order;
#   foreach my $node (@$nodes) {
#     if ($node->parent and $node->{$attr} == $node->parent->{$attr}) {
#       unless (exists($sameaschild{$node->parent})) {
# 	$sameasparent{$node}=1;
# 	$sameaschild{$node->parent}=$node;
#       }
#     }
#   }
  if (exists($Opts->{ballance})) {
    print STDERR "Use 'balance' instead of misspelled 'ballance'!\n";
    $Opts->{balance}=$Opts->{ballance} unless (exists($Opts->{balance}));
  }
  my $balance= exists($Opts->{balance}) ? 
    $Opts->{balance} : $self->get_balanceTree;

  my $skipHiddenLevels= exists($Opts->{skipHiddenLevels}) ? $Opts->{skipHiddenLevels} : $self->get_skipHiddenLevels;

  my $balanceOpts = [$balance =~ /^aboveMiddleChild(Odd$|$)/ ? 1 : 0,
		      $balance =~ /^aboveMiddleChild(Even$|$)?/ ? 1 : 0];

  foreach $node (@{$nodes}) {
    $self->store_node_pinfo($node,"E",1);
  }
  foreach $node (@{$nodes}) {
    $level=0;
    if ($skipHiddenLevels) {
      $parent=$node->parent;
      while ($parent) {
	if ($self->get_node_pinfo($parent,"E")) {
	  $level++;
	  $level+=$self->get_style_opt($parent,"Node","-rellevel",$Opts);
	}
	$parent=$parent->parent;
      }
#      print "SKIPHIDDEN: $node->{trlemma} => level: $level\n";
    } else {
      $parent=$node->parent;
      while ($parent) {
	$level++;
	$level+=$self->get_style_opt($parent,"Node","-rellevel",$Opts);
	$parent=$parent->parent;
      }
    }
    $level+=$self->get_style_opt($node,"Node","-rellevel",$Opts);
    $level+=$self->get_style_opt($node,"Node","-level",$Opts);
    $self->store_node_pinfo($node,"EdgeLabelHeight", $edge_label_height);

    $maxlevel=max($maxlevel,$level);
    $ypos = $baseYPos + $level*$levelHeight;

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
      ($pat_style,$pat)=$self->parse_pattern($patterns[$i]);
      if ($pat_style eq "edge") {
	# this does not actually make
	# the edge label not to overwrap, but helps a little
	$m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
	$self->store_node_pinfo($node,"X[$i]",$m);
	$edgeLabelWidth=$m if $m>$edgeLabelWidth;
      } elsif ($pat_style eq "node") {
	$m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
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
      $xSkipAfter=max($xSkipAfter,$nodeLabelWidth/2);
      $nodeLabelXShift=-$nodeLabelWidth/2;
    } else {
      $xSkipAfter=max($xSkipAfter,$nodeLabelWidth-$nodeWidth/2);
      $nodeLabelXShift=-$nodeWidth/2;
    }
    $nodeLabelXShift+=$self->get_style_opt($node,"NodeLabel","-xadj",$Opts);
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
    $self->store_node_pinfo($node,"Before",$xSkipBefore);
    if ($balance) {
      #$xSkipBefore+
      $xpos = $self->get_style_opt($node,"Node","-extrabeforeskip",$Opts);
    } else {
      $minxpos=0;
      if ($prevnode[$level]) {
	$minxpos=
	  $self->get_node_pinfo($prevnode[$level],"XPOS")+
	    $self->get_node_pinfo($prevnode[$level],"After")+$xSkipBefore;
      } else {
	$minxpos=$baseXPos+$xSkipBefore;
      }
      $xpos=max($xpos,$minxpos)+$nodeXSkip+$self->get_style_opt($node,"Node","-extrabeforeskip",$Opts);
      $prevnode[$level]=$node
    }
    $self->store_node_pinfo($node,"XPOS",$xpos);
    $self->store_node_pinfo($node,"NodeLabel_XPOS",$xpos+$nodeLabelXShift);

    $canvasWidth = max($canvasWidth,
		       $xpos+$xSkipAfter+$nodeWidth+2*$self->get_xmargin+$baseXPos);
    $self->store_node_pinfo($node,"Level", $level);
    push @zero_level, $node if ($level == 0);
  }

  if ($balance) {
    my $baseX = $baseXPos;
    foreach my $c (@zero_level) {
      $baseX = $self->balance_node($baseX,$c,$balanceOpts);
    }
    foreach my $c (@zero_level) {
      $self->balance_xfix_node(0,$c);
    }
    $canvasWidth = $baseX;
  }

  $self->{canvasWidth}=$canvasWidth;
  $self->{canvasHeight}=$baseYPos+
		     + ($maxlevel+1)*$levelHeight+$self->get_ymargin;
#		     + $nodeHeight + $self->get_ymargin
#		     + $node_pattern_count*$fontHeight;
#		       (2*($nodeYSkip +
#					 $self->get_ymargin)
#		     + ($node_pattern_count+$edge_pattern_count)*$fontHeight
#		     + $nodeHeight);
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

  my $x=$self->get_node_pinfo($node,'XPOS');
  my $y=$self->get_node_pinfo($node,'YPOS');
  my $Opts=$self->get_gen_pinfo('Opts');
  if ($self->get_style_opt($node,'Node','-shape',$Opts) ne 'polygon') {

    my ($nw,$nh);
    if ($currentNode eq $node) {
      $nw=$self->get_style_opt($node,'Node','-currentwidth',$Opts);
      $nh=$self->get_style_opt($node,'Node','-currentheight',$Opts);
      $nw=$self->get_style_opt($node,'Node','-width',$Opts) unless defined $nw;
      $nh=$self->get_style_opt($node,'Node','-height',$Opts) unless defined $nh;
      $nw=$self->get_currentNodeWidth unless defined $nw;
      $nh=$self->get_currentNodeHeight unless defined $nh;
    } else {
      $nw=$self->get_style_opt($node,'Node','-width',$Opts);
      $nh=$self->get_style_opt($node,'Node','-height',$Opts);
      $nw=$self->get_nodeWidth unless defined $nw;
      $nh=$self->get_nodeHeight unless defined $nh;
    }
    $nw+=$self->get_style_opt($node,'Node','-addwidth',$Opts);
    $nh+=$self->get_style_opt($node,'Node','-addheight',$Opts);
    return ($x-$nw/2,
	    $y-$nh/2,
	    $x+$nw/2,
	    $y+$nh/2);
  } else {
    my $horiz=0;
    return map { $horiz=!$horiz; $_+($horiz ? $x : $y) } 
      split(',',$self->get_style_opt($node,'Node','-polygon',$Opts))
  }
}

sub node_options {
  my ($self,$node,$fs,$current_node)=@_;
  return (-outline => $self->get_nodeOutlineColor,
	  -width => 1,
	  -fill =>
	  ($current_node eq $node) ?
	  $self->get_currentNodeColor :
	  ($fs->isHidden($node) ?
	   $self->get_hiddenNodeColor :
	   $self->get_nodeColor),
	 );
}

sub line_options {
  my ($self,$node,$fs,$can_dash)=@_;
  if ($fs->isHidden($node)) {
    return (-fill => $self->get_hiddenLineColor,
	    ($can_dash ? 
	    ($self->get_dashHiddenLines ? ('-dash' => '-') : (-dash => $self->get_lineDash)) : ())
	   );
  } else {
    return (-fill => $self->get_lineColor, -dash => $self->get_lineDash);
  }
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
  my %h=(
	 (ref($opts->{$style}) ? @{$opts->{$style}} : ()),
	 (ref($s) ? @$s : ())
	);
  return $h{$opt};
}

sub apply_style_opts {
  my ($self, $item)=(shift,shift);
  eval { $self->canvas->itemconfigure($item,@_); };
  print STDERR $@ if $@ ne "";
  return $@;
}

sub apply_stored_style_opts {
  my ($self, $item, $node)=@_;
  my $Opts=$self->get_gen_pinfo("Opts");
  
  eval { $self->canvas->
	   itemconfigure($self->get_node_pinfo($node,"Oval"),
			 @{$Opts->{$item}},
			 $self->get_node_style($node,$item)); };
  print STDERR $@ if $@ ne "";
  return $@;
}

sub get_node_style {
  my ($self,$node,$style)=@_;
  my $s=$self->get_node_pinfo($node,"style-$style");
  return $s ? @{$s} : ();
}

sub parse_coords_spec {
  my ($self,$node,$coords,$nodes,$nodehash)=@_;
  # perl inline search
  $coords =~
    s{([xy])\[\?((?:.|\n)*?)\?\]}{
      my $i=0;
      my $key="[?${2}?]";
      my $xy=$1;
      my $code=$2;
      if (exists($nodehash->{"$xy$key"})) {
	int($nodehash->{"$xy$key"})
      } else {
	while ($i<@$nodes) {
	  my $c=$code;
	  my $this=$node;	 # $this is the context node
	  my $node=$nodes->[$i]; # $node is the search node
	  $c=~s[\$\{([-_A-Za-z0-9]+)\}]["'$nodes->[$i]->{$1}'"]ge;
	  last if eval $c;	 # NOT SECURE, NOT SAFE!
	  print STDERR $@ if $@ ne "";
	  $i++;
	}
	if ($i<@$nodes) {
	  $nodehash->{"x$key"} = $self->get_node_pinfo($nodes->[$i], "XPOS");
	  $nodehash->{"y$key"} = $self->get_node_pinfo($nodes->[$i], "YPOS");
	  int($nodehash->{"$xy$key"})
	} else {
	  #	    print STDERR "NOT-FOUND $code\n";
	  "ERR";
	}
      }
    }ge;
  $coords=~
    s{([xy])\[!((?:.|\n)*?)!\]}{
      my $i=0;
      my $key="[!${2}!]";
      my $xy=$1;
      my $code=$2;
      if (exists($nodehash->{"$xy$key"})) {
	int($nodehash->{"$xy$key"})
      } else {
	my $c=$code;
	my $this=$node;		# $this is the context node

	$c=~s[\$\{([-_A-Za-z0-9]+)\}]["'$this->{$1}'"]ge;
	my $that=eval $c;	# NOT SECURE, NOT SAFE!
	print STDERR $@ if $@ ne "";
	if (ref($that)) {
	  $nodehash->{"x$key"}=
	    $self->get_node_pinfo($that, "XPOS");
	  $nodehash->{"y$key"}=
	    $self->get_node_pinfo($that, "YPOS");
	  int($nodehash->{"$xy$key"})
	} else {
	  #	    print STDERR "NOT-FOUND $code\n";
	  "ERR"
	}
      }
    }ge;

  # simple comparison inline
  $coords =~
    s{([xy])\[([-_A-Za-z0-9]+)\s*=\s*((?:[^\]\\]|\\.)+)\]}{
      my $i=0;
      if (exists($nodehash->{$&})) {
	$i=$nodehash->{$&};
      } else {
	$i++ while ($i<@$nodes and
		    !(exists($nodes->[$i]{$2}) and $nodes->[$i]{$2} eq $3));
	$nodehash->{$&}=$i;
      }
      if ($i<@$nodes) { 
	int($self->get_node_pinfo($nodes->[$i],($1 eq 'x') ? "XPOS" : "YPOS"))
      } else {
	"ERR"
      }
    }ge;
  return $coords;
}

sub eval_coords_spec {
  my ($self,$node,$parent,$C,$coords) = @_;
  my $x=1;
  foreach (@$C) {
    s{([xy]?)p}{
      if ($parent) {
	int($self->get_node_pinfo($parent,(($x and ($1 ne 'y')) or $1 eq 'x') ?
				    "XPOS" : "YPOS"))
      } else {
	"NE"
      }
    }ge;
    s{([xy]?)n}{
      int($self->get_node_pinfo($node,
				(($x and ($1 ne 'y')) or $1 eq 'x') ?
				  "XPOS" : "YPOS"))
    }ge;
    if (/^([-\s+\?:.\/*%\(\)0-9]|&&|\|\||!|\>|\<(?!>)|==|\>=|\<=|sqrt\(|abs\()*$/) {
      $_=eval $_;
      print STDERR $@ if $@ ne "";
    } else { # catches ERR too
      if ($Debug and (/ERR/ or !/NE/)) {
	print STDERR "COORD: $coords\n";
	print STDERR "BAD: $_\n";
	  }
      return undef;
    }
    $x=!$x;
  }
  return $C;
}

sub redraw {
  my ($self,$fsfile,$currentNode,$nodes,$valtext,$stipple,$grp)=@_;
  my $node;
  my $style;
  my $parent;
  my $node_has_box;
  my $edge_has_box;
  my $bg;
  my ($x_edge_delta,
      $x_edge_length,
      $y_edge_length,
      $edgeLabelWidth,
      $edgeLabelHeight,
      $halign_edge,
      $valign_edge
     );


  my (@node_patterns,@edge_patterns,@style_patterns,@patterns);

  my %Opts=();
  foreach (keys %DefaultNodeStyle) {
    $Opts{$_}=[@{$DefaultNodeStyle{$_}}];
  }
  
  if (ref($fsfile)) {
    @node_patterns=$self->get_label_patterns($fsfile,"node");
    @edge_patterns=$self->get_label_patterns($fsfile,"edge");
    @style_patterns=$self->get_label_patterns($fsfile,"style");
    @patterns=($self->patterns) ? @{$self->patterns} : $fsfile->patterns();
  }

  my $canvas = $self->canvas;

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
    $node=$node->parent() while ($node->parent());
    # only for root node if any
    foreach $style ($self->get_label_patterns($fsfile,"rootstyle")) {
      foreach ($self->interpolate_text_field($node,$style,$grp)=~/\#${block}/g) {
  	if (/^(Oval|TextBox|EdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-.+):'?(.+)'?$/) {
	  if (exists $Opts{"$1$2"}) {
	    push @{$Opts{"$1$2"}},$3=>$4;
	  } else {
	    $Opts{"$1$2"}=[$3=>$4];
	  }
	} elsif (/^(.*?):(.*)$/) {
	  $Opts{$1}=$2;
	} else {
	  $Opts{$_}=1;
	}
      }
    }
    # root styling hook
    if (ref($on_get_root_style) eq 'ARRAY') {
      &{$on_get_root_style->[0]}($self,$node,\%Opts,@{$on_get_root_style}[1..$#$on_get_root_style]);
    } elsif (ref($on_get_root_style) eq 'CODE') {
      &$on_get_root_style($self,$node,\%Opts);
    }
  }

  # styling patterns should be interpolated here for each node and
  # the results stored within node_pinfo
  foreach $node (@{$nodes}) {
    my %nopts=();
    foreach $style (@style_patterns) {
      foreach ($self->interpolate_text_field($node,$style,$grp)=~/\#${block}/g) {
	if (/^(CurrentOval|Oval|TextBox|EdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-[^:]+):(.+)$/) {
	  if (exists $nopts{"$1$2"}) {
	    push @{$nopts{"$1$2"}},$3=>$4;
	  } else {
	    $nopts{"$1$2"}=[$3=>$4];
	  }
	}
      }
    }
    # external styling hook
    if (ref($on_get_node_style) eq 'ARRAY') {
      &{$on_get_node_style->[0]}($self,$node,\%nopts,@{$on_get_node_style}[1..$#$on_get_node_style]);
    } elsif (ref($on_get_node_style) eq 'CODE') {
      &$on_get_node_style($self,$node,\%nopts);
    }
    foreach (keys %nopts) {
      $self->store_node_pinfo($node,"style-$_",$nopts{$_});
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
  recalculate_positions($self,$fsfile,$nodes,\%Opts,$grp);

  #------------------------------------------------------------
  #}
  #my $t1= new Benchmark;
  #my $td= timediff($t1, $t0);
  #print "recalculate_positions: the code took:",timestr($td),"\n";
  #}
  #------------------------------------------------------------

  $canvas->configure(-background => $self->get_backgroundColor) if (defined $self->get_backgroundColor);
  $canvas->addtag('delete','all');
  if ($canvas->find('withtag','bgimage')) {
    $canvas->dtag('bgimage','delete');
  }
  $canvas->delete('delete');

  $self->store_gen_pinfo('lastX' => 0);
  $self->store_gen_pinfo('lastY' => 0);

  # draw sentence info
  if ($self->get_drawSentenceInfo) {
    return unless $fsfile;
    my $currentfile=filename($fsfile->filename);
    my $fontHeight=$self->getFontHeight();
    $valtext=~s/ +([.,!:;])|(\() |(\)) /$1/g;

    my ($ftext,$vtext);
    if ($valtext=~/^(.*)\/([^:]*):\s*(.*)/) {
      $ftext="File: $currentfile, tree $1 of $2";
      $vtext=$3;
    } else {
      $ftext="";
      $vtext=$valtext;
    }
    $self->apply_style_opts(
			    $canvas->
			    createText(0,
				       $self->{canvasHeight},
				       -font => $self->get_font,
				       -text => $ftext,
				       -justify => 'left', -anchor => 'nw'),
			    @{$Opts{SentenceText}});
    $self->{canvasHeight}+=$fontHeight;
    $self->{canvasWidth}=max($self->{canvasWidth},$self->getTextWidth($ftext));
    $self->apply_style_opts(
			    $canvas->
			    createLine(0,$self->{canvasHeight},
				       $self->getTextWidth($ftext),
				       $self->{canvasHeight}),
			    @{$Opts{SentenceLine}});
    $self->{canvasHeight}+=$fontHeight;
    my $i=1;
    my @lines=$self->wrapLines($vtext,$self->{canvasWidth});
    @lines=reverse @lines if ($self->{reverseNodeOrder});
    foreach (@lines) {
      if ($self->{reverseNodeOrder}) {
	$self->apply_style_opts(
				$canvas->
				createText($self->{canvasWidth},
					   $self->{canvasHeight},
					   -font => $self->get_font,
					   -tags => 'vline',
					   -text => $_,
					   -justify => 'right',
					   -anchor => 'ne'),
				@{$Opts{SentenceFileInfo}});
      } else {
	$self->apply_style_opts(
				$canvas->
				createText(0,$self->{canvasHeight},
					   -font => $self->get_font,
					   -tags => 'vline',
					   -text => $_,
					   -justify => 'left',
					   -anchor => 'nw'),
			@{$Opts{SentenceFileInfo}});
      }
      $self->{canvasHeight}+=$fontHeight;
    }

#    $canvas->createRectangle(0,0, $self->{canvasWidth},$self->{canvasHeight},
#			      -outline => 'black',
#			      -fill => undef,
#				   -tags => 'vline'
#			     );
  }
  $canvas->configure(-scrollregion =>['0c', '0c', $self->{canvasWidth}, $self->{canvasHeight}]);

  my $lineHeight=$self->getFontHeight();
  my $edge_label_yskip= (scalar(@node_patterns) ? $self->get_edgeLabelSkipAbove : 0);
  my $can_dash=($Tk::VERSION=~/\.([0-9]+)$/ and $1>=22);
  $objectno=0;

  my $skipHiddenLevels = $Opts{skipHiddenLevels} || $self->get_skipHiddenLevels;
  my $skipHiddenParents = $skipHiddenLevels || $Opts{skipHiddenParents} || $self->get_skipHiddenParents;

  foreach $node (@{$nodes}) {
    if ($skipHiddenParents) {
      $parent = $node->parent;
      $parent=$parent->parent while ($parent and !$self->get_node_pinfo($parent,"E"));
    } else {
      $parent=$node->parent;
    }
    use integer;

    ## Lines ##
    my @arrow=split '&',$self->get_style_opt($node,"Line","-arrow",\%Opts);
    my @fill=split '&',$self->get_style_opt($node,"Line","-fill",\%Opts);
    my @width=split '&',$self->get_style_opt($node,"Line","-width",\%Opts);
    my @dash=map { /\d/ ? [split /,/,$_] : $_ } 
      split '&',$self->get_style_opt($node,"Line","-dash",\%Opts);
    my @smooth=split '&',$self->get_style_opt($node,"Line","-smooth",\%Opts);
    my $lin=0;
    my %nodehash;

    my $coords=$self->get_style_opt($node,"Line","-coords",\%Opts);
    $coords = $self->parse_coords_spec($node,$coords,$nodes,\%nodehash);

    my @coords=split '&',$coords;
    COORD: foreach my $c (@coords) {
      my @c=split ',',$c;
      next unless $self->eval_coords_spec($node,$parent,\@c,$coords);
      $objectno++;
      my $line="line_$objectno";
      my $l;
      eval {
	$l=$canvas->
	  createLine(@c,
		     $self->line_options($node,$fsfile->FS,$can_dash),
		     -tags => [$line,'line'],
		     -arrow =>  $arrow[$lin] || $self->get_lineArrow,
		     -width =>  $width[$lin] || $self->get_lineWidth,
		     ($fill[$lin] ? ('-fill'  => $fill[$lin]) : ()),
		     (($dash[$lin] && $can_dash) ? ('-dash'  => $dash[$lin]) : ()),
		     '-smooth'  =>  $smooth[$lin] || 0
		    );
      };
      print STDERR $@ if $@ ne "";
      $self->store_id_pinfo($l,$line);
      $self->store_node_pinfo($node,"Line$lin",$line);
      $self->store_obj_pinfo($line,$node);
      $self->realcanvas->lower($line,'all');
      $self->realcanvas->raise($line,'line');

      $lin++;
   }

    undef %nodehash;

#    $self->apply_style_opts($line,@{$Opts{Line}},
#			    $self->get_node_style($node,"Line"));

    ## Node Shape ##
    my $shape=lc($self->get_style_opt($node,'Node','-shape',\%Opts));

    $shape='oval' unless ($shape eq 'rectangle' or $shape eq 'polygon');
    my @node_coords=$self->node_coords($node,$currentNode);
    $objectno++;
    my $oval="oval_$objectno";
    my $o=$canvas->create($shape,
			  @node_coords,
			  -tags => ['point',$oval],
			  -outline => $self->get_nodeOutlineColor,
			  $self->node_options($node,
					      $fsfile->FS,
					      $currentNode)
			 );
    $self->store_id_pinfo($o,$oval);
    $self->apply_style_opts($oval,@{$Opts{Oval}},
			    $self->get_node_style($node,"Oval"),
			    ($node eq $currentNode ? $self->get_node_style($node,"CurrentOval") : ())
			   );
    $self->store_node_pinfo($node,"Oval",$oval);
    $self->store_obj_pinfo($oval,$node);

    # EdgeLabel
    if (scalar(@edge_patterns) and $parent) {
      my $coords = $self->get_style_opt($node,"EdgeLabel","-coords",\%Opts);
      $halign_edge=$self->get_style_opt($node,"EdgeLabel","-halign",\%Opts);
      $valign_edge=$self->get_style_opt($node,"EdgeLabel","-valign",\%Opts);
      $edgeLabelWidth=$self->get_node_pinfo($node,"EdgeLabelWidth");
      $edgeLabelHeight=$self->get_node_pinfo($node,"EdgeLabelHeight");

      if ($coords) {
	# edge label with explicit coords
	$coords = $self->parse_coords_spec($node,$coords,$nodes,\%nodehash);
	my @c=split ',',$coords;
	if ($self->eval_coords_spec($node,$parent,\@c,$coords)) {
	  if ($halign_edge eq "left") {
	    $c[0]-=$edgeLabelWidth;
	  } elsif ($halign_edge eq "center") {
	    $c[0]-=$edgeLabelWidth/2;
	  }
	  if ($valign_edge eq "bottom") {
	    $c[1]-=$edgeLabelHeight;
	  } elsif ($valign_edge eq "center") {
	    $c[1]-=$edgeLabelHeight/2;
	  }
	  $self->store_node_pinfo($node,"EdgeLabel_XPOS", $c[0]);
	  $self->store_node_pinfo($node,"EdgeLabel_YPOS", $c[1]);
	}
      } else {
	$y_edge_length=
	  ($self->get_node_pinfo($parent, "YPOS")-
	     $self->get_node_pinfo($node,"YPOS"));
	$x_edge_length=
	  ($self->get_node_pinfo($parent, "XPOS")-
	     $self->get_node_pinfo($node,"XPOS"));
	$x_edge_delta=(($self->get_node_pinfo($node, "EdgeLabel_YPOS")
			  -$self->get_node_pinfo($node, "YPOS"))*$x_edge_length)/$y_edge_length;
	
	# the reference point for edge label is now
	# X: $self->get_node_pinfo($node,"XPOS")+$x_edge_delta
	#	Y: $self->get_node_pinfo($node,"EdgeLabel_YPOS")
	
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
	$x_edge_delta+=$self->get_style_opt($node,"EdgeLabel","-xadj",\%Opts);
	$self->store_node_pinfo($node,"EdgeLabel_XPOS",
				$self->get_node_pinfo($node,"XPOS")+$x_edge_delta);
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
      $objectno++;
      my $box="textbox_$objectno";
      my $bid=$canvas->
	createRectangle($self->get_node_pinfo($node,"NodeLabel_XPOS")-
			$self->get_xmargin,
			$self->get_node_pinfo($node,"NodeLabel_YPOS")-
			$self->get_ymargin,
			$self->get_node_pinfo($node,"NodeLabel_XPOS")+
			$textWidth+$self->get_xmargin,
			$self->get_node_pinfo($node,"NodeLabel_YPOS")+
			$self->get_ymargin+
			scalar(@node_patterns)*$lineHeight,
			-tags => ['TextBox',$box]
		       );
      $self->store_id_pinfo($bid,$box);
      $self->apply_style_opts($box,
			      $self->node_box_options($node,$fsfile->FS,
						      $currentNode,0),
			      @{$Opts{TextBox}},
			      $self->get_node_style($node,"TextBox"));
      $self->store_node_pinfo($node,"TextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }
    $edge_has_box=
      scalar(@edge_patterns) && $parent &&
	($self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-nodrawbox",\%Opts) ne "yes") ||
	 !$self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-drawbox",\%Opts) eq "yes"));
    $self->store_node_pinfo($node,"EdgeHasBox",$edge_has_box);
    if ($edge_has_box) {
      ## get maximum width stored here by recalculate_positions
      $objectno++;
      my $box="edgebox_$objectno";
      my $bid=$canvas->
	createRectangle($self->get_node_pinfo($node,"EdgeLabel_XPOS")-
			$self->get_xmargin,
			$self->get_node_pinfo($node,"EdgeLabel_YPOS")
			-$self->get_ymargin,
			$self->get_node_pinfo($node,"EdgeLabel_XPOS")+
			$self->get_xmargin+$edgeLabelWidth,
			$self->get_node_pinfo($node,"EdgeLabel_YPOS")
			+$self->get_ymargin
			+scalar(@edge_patterns)*$lineHeight,
			-tags => ['EdgeBox',$box]
		       );
      $self->store_id_pinfo($bid,$box);
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
      $msg=$self->interpolate_text_field($node,$pat,$grp);
      if ($pat_class eq "edge") {
	if ($parent) {
	  $msg =~ s!/!!g;		# should be done in interpolate_text_field
	  $x=$self->get_node_pinfo($node,"EdgeLabel_XPOS");
	  $y=$self->get_node_pinfo($node,"EdgeLabel_YPOS")+$e_i*$lineHeight;
	  $self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
				!$edge_has_box, \%Opts,$grp);
	  $e_i++;
	}
      } elsif ($pat_class eq "node") {
	$x=$self->get_node_pinfo($node,"NodeLabel_XPOS");
	$y=$self->get_node_pinfo($node,"NodeLabel_YPOS")+$n_i*$lineHeight;
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
			      !$node_has_box, \%Opts,$grp);
	$n_i++;
      }
    }
  }
  ## Canvas Custom Balloons ##
  if ($fsfile) {
    my $hint=defined($self->hint) ? ${$self->hint} : $fsfile->hint;
    if ($self->get_CanvasBalloon) {
#DEBUG

#=pod

      $self->get_CanvasBalloon()->
	attach($canvas->Subwidget('scrolled'),
	       -balloonposition => 'mouse',
	       -msg =>
	       {
		map { 
		  if (defined($_)) {
		    my $node=$self->get_obj_pinfo($_);
		    my $msg=
		      $self->interpolate_text_field($node,
						    $hint,$grp);
		    $msg=~s/\${([^}]+)}/_present_attribute($node,$1)/eg;
		    $_ => encode($msg);
		  }
		} $self->find_item('withtag','point')
	       });

#=cut

    }
  }
  if (defined $self->get_backgroundImage) {
    unless ($canvas->find('withtag','bgimage')) {
      my $img=$self->get_backgroundImage;
      print STDERR "Loading background image from $img...";
      eval {
	$canvas->Photo("photo", -file => $img);
	$canvas->createImage($self->get_backgroundImageX,
				   $self->get_backgroundImageY,
				   -image =>"photo",
				   -anchor => 'nw', -tags=>'bgimage');
      };
      print STDERR $@ ? "failed.\n" : "ok.\n";
    }
    $self->realcanvas->lower('bgimage','all')  if ($canvas->find('withtag','bgimage'));
  }
  eval {
    $self->realcanvas->raise('text','TextBg');
    $self->realcanvas->raise('plaintext','TextBg');
  };
  undef $@;
  ## Canvas grid - for inactive TreeView ##
  ##  $canvas->createLine(0,0,$canvas->width, $canvas->height,-fill => 'green');
  if ($stipple ne "") {
    $canvas->createRectangle(-1000,-1000,
			     max(5000,$self->{canvasWidth}),max(5000,$self->{canvasHeight}),
			     -outline => undef,
			     -fill=>'lightgray',
			     -stipple => 'gray25',
#			     -activestipple => 'gray25',
			     -tags => 'stipple',
			     -state => $stipple);
  }
}




sub draw_text_line {
  my ($self,$fsfile,$node,$i,$msg,
      $lineHeight,$x,$y,$clear,$Opts,$grp)=@_;

#  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
  my $align=$self->get_style_opt($node,"Node","-textalign",$Opts);
  my $textdelta;
  if ($align eq 'left') {
    $textdelta=0;
  } elsif ($align eq 'right') {
    $textdelta=
      $self->get_node_pinfo($node,"NodeLabelWidth")-
	$self->get_node_pinfo($node,"X[$i]");
  } elsif ($align eq 'center') {
    $textdelta=
      ($self->get_node_pinfo($node,"NodeLabelWidth")-
       $self->get_node_pinfo($node,"X[$i]"))/2;
  }
  
  ## Clear background
  if ($self->get_clearTextBackground and
      $clear and $self->get_node_pinfo($node,"X[$i]")>0) {
    $objectno++;
    my $bg="textbg_$objectno";
    my $bid=$self->canvas->
      createRectangle($x+$textdelta,$y,
		      $x+$textdelta+$self->get_node_pinfo($node,"X[$i]")+1,
		      $y+$lineHeight,
		      -fill => $self->canvas->cget('-background'),
		      -outline => undef,
		      -tags => [$bg,'TextBg']
		     );
    $self->store_id_pinfo($bid,$bg);
    $self->apply_style_opts($bg,
			    @{$Opts->{TextBg}},
			    @{$Opts->{"TextBg[$i]"}},
			    $self->get_node_style($node,"TextBg"),
			    $self->get_node_style($node,"TextBg[$i]")
			   );
    $self->store_node_pinfo($node,"TextBg[$i]",$bg);
    $self->store_obj_pinfo($bg,$node);
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
  foreach (grep {$_ ne ""} split(m/([#\$]${bblock})/,$msg)) {
    if (/^\$${block}$/) {
      my $c=$1;
      $j++;
      if ($c=~/^(.*?)=(.*)$/s) {
	$c=$1;
	$at_text=$2;
      } else {
	$at_text=$self->prepare_text_field($node,$c,$grp);
      }
      next if ($at_text) eq "";
      $objectno++;
      $txt="text_$objectno";
      my $bid=$self->canvas->
	createText($x+$xskip+$textdelta, $y,
		   -anchor => 'nw',
		   -text => $at_text,
		   -fill =>
		   defined($color) ? $color :
		   $self->which_text_color($fsfile,$c),
		   -font => $self->get_font,
		   -tags => [$txt,'text']
		  );
      $self->store_id_pinfo($bid,$txt);
      $self->apply_style_opts($txt,
		   @{$Opts->{Text}},
		   @{$Opts->{"Text[$c]"}},
		   @{$Opts->{"Text[$c][$i]"}},
		   @{$Opts->{"Text[$c][$i][$j]"}},
		   $self->get_node_style($node,"Text"),
		   $self->get_node_style($node,"Text[$c]"),
		   $self->get_node_style($node,"Text[$c][$i]"),
		   $self->get_node_style($node,"Text[$c][$i][$j]"));
      $xskip+=$self->getTextWidth($at_text);
      $self->store_obj_pinfo($txt,$node);
      $self->store_node_pinfo($node,"Text[$c][$i][$j]",$txt);
      $self->store_gen_pinfo("attr:$txt",$c);
    } elsif (/^\#${block}$/) {
      unless ($self->get_noColor) {
	my $c=$1;
	if ($c=~m/^(.+)(-.+):(.+)$/) {
	  # Depreciated ! Use style pattern!
	  eval {
	    $self->canvas->
	      itemconfigure($self->get_node_pinfo($node,$1),$2 => $3);
	  };
	  print STDERR $@ if $@ ne "";
	} else {
	  $color=$c;
	  $color=undef if ($color eq 'default');
	  $color=$self->get_customColors->{$1} if ($color=~/^custom(.*)$/);
	}
      }
    } else {
      if ($_ ne "") {
	$objectno++;
	$txt="text_$objectno";
	my $bid=$self->canvas->
	  createText($x+$xskip+$textdelta,
		     $y,
		     -text => encode($_),
		     -font => $self->get_font,
		     -tags => [$txt,'plaintext']
		    );
	$self->store_id_pinfo($bid,$txt);
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
  } $self->patterns ? @{$self->patterns} : $fsfile->patterns();
}


=pod

=item prepare_text (fsfile,node,pattern)

Interpolate given pattern for the given node,
by evaluating all code (`<? code ?>') and 
attribute (`${attribute}') fields, removing all
formatting references of the form #{format}.

=cut

sub prepare_text {
  my ($self,$node,$pattern,$grp)=@_;
  return "" unless ref($node);
  my $msg=$self->interpolate_text_field($node,$pattern,$grp);
  $msg=~s/\#${block}//g;
  $msg=~s/\$${block}/$self->prepare_raw_text_field($node,$1)/eg;
  return encode($msg);
}

=pod

=item interpolate_text_field (node,text,grp)

Interpolate, evaluate and substitute the results for
all code references of the form `<? code ?>' in the given
text.

=cut

sub interpolate_text_field {
  my ($self,$this,$text,$grp)=@_;
  # make root visible for the evaluated expression
  local $TredMacro::this = $this;
  local $TredMacro::root = my $root = ($this ? $this->root : undef);
  local $TredMacro::grp = $grp;
  $text=~s/\<\?((?:[^?]|\?[^>])+)\?\>/eval "package TredMacro;\n".$self->interpolate_refs($this,$1)/eg;
  return $text;
}

=pod

=item interpolate_refs (node, text)

Interpolate any attribute references of the form $${attribute}
in the text with the single-quotted value.

=cut

sub _quote_quote { my ($q) = @_; $q=~s/\\/\\\\/g; $q =~ s/'/\\'/g; $q }

sub _present_attribute {
  my ($node,$path) = @_;
  my $val = $node;
  my $append = "";
  for my $step (split /\//, $path) {
    if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
      if ($step =~ /^\[(\d+)\]/) {
	$val = $val->[$1-1];
      } else {
	$append="*" if @$val > 1;
	$val = $val->[0]{$step};
      }
    } elsif (ref($val)) {
      $val = $val->{$step};
    } elsif (defined($val)) {
#      warn "Can't follow attribute path '$path' (step '$step')\n";
      return undef; # ERROR
    } else {
      return '';
    }
  }
  return $val.$append;
}

sub interpolate_refs {
  my ($self,$node,$text)=@_;
  $text=~s/\$\${([^}]+)}/"'"._quote_quote(_present_attribute($node,$1))."'"/eg;
  return $text;
}

=pod

=item prepare_text_field (node,attribute)

Return the first (of possibly multiple) value of the given node's
attribute. If more values exist, only the first is
presented followed by the character "*".

=cut

#'

sub prepare_text_field {
  my ($self,$node,$atr)=@_;
  my $text=_present_attribute($node,$atr);
#  $text=$1."*" if ($text =~/^([^\|]*)\|/);
  return encode($text);
}

=pod

=item prepare_raw_text_field (node,attribute)

As prepare_text_field but not recoding text to output encoding.

=cut

sub prepare_raw_text_field {
  my ($self,$node,$atr)=@_;
  if ($atr=~/^.*?=(.*)$/s) {
    return $1;
  } else {
    my $text=_present_attribute($node,$atr);
    $text=$1."*" if ($text =~/^([^\|]*)\|/);
    return $text;
  }
}

1;

# package Tk::Canvas;
# BEGIN {
# *old_create = *create;
# *create = *new_create;
# };
# sub new_create {
#   my $self=shift;
#   print "\$canvas->create(",join(",",map { "'$_'" } @_),");\n";
#   $self->old_create(@_);
# }
# 1;

