package TrEd::TreeView;		# -*- cperl -*-

use strict;

BEGIN {
use Tk;
use Tk::Canvas;
use Tk::CanvasSee;
use Tk::Balloon;
use Tk::Font;
use Fslib;
use TrEd::MinMax;
import TrEd::MinMax;

use TrEd::Convert;
import TrEd::Convert;

use vars qw($AUTOLOAD @Options %DefaultNodeStyle $Debug $on_get_root_style $on_get_node_style $on_get_nodes);

@Options = qw(CanvasBalloon backgroundColor
  stripeColor vertStripe horizStripe baseXPos baseYPos boxColor
  currentBoxColor currentEdgeBoxColor currentNodeHeight
  currentNodeWidth customColors hiddenEdgeBoxColor edgeBoxColor
  clearTextBackground drawBoxes drawEdgeBoxes backgroundImage
  backgroundImageX backgroundImageY drawFileInfo drawSentenceInfo font
  hiddenBoxColor edgeLabelYSkip highlightAttributes showHidden
  lineArrow lineArrowShape lineColor lineDash hiddenLineColor dashHiddenLines lineWidth
  noColor nodeHeight nodeWidth nodeXSkip nodeYSkip edgeLabelSkipAbove
  edgeLabelSkipBelow pinfo textColor xmargin nodeOutlineColor
  nodeColor hiddenNodeColor nearestNodeColor ymargin currentNodeColor
  textColorShadow textColorHilite textColorXHilite skipHiddenLevels skipHiddenParents
  useAdditionalEdgeLabelSkip reverseNodeOrder balanceTree verticalTree displayMode labelSep
  columnSep lineSpacing);

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
}


our $objectno;
our ($block, $bblock);
$block  = qr/\{((?:(?> [^{}]* )|(??{ $block }))*)\}/x;
$bblock = qr/\{(?:(?>  [^{}]* )|(??{ $bblock }))*\}/x;

{
  no strict 'refs';
  # generate methods
  for my $opt (@Options, qw(canvasHeight canvasWidth scale)) {
    (*{"get_$opt"},*{"set_$opt"}) = do {{
      my $o = $opt;
      (sub { $_[0]->{$o} },
       sub { $_[0]->{$o} = $_[1]; })
     }};
  }
}

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
  warn "Warning: $sub is not a method of TreeView\n\t";
  warn(join("\n\t",(caller(0))[0..4])."\n");
  if ($sub=~/^get_(.*)$/) {
    return $self->{$1};
  } elsif ($sub=~/^set_(.*)$/) {
    return $self->{$1}=shift;;
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
  return $self->{canvas}->isa("Tk::Canvas")
    ? $self->{canvas} : $self->{canvas}->Subwidget("scrolled");
}

sub scale_factor {
  my ($self)=@_;
  my $s = $self->{scale};
  if ($s < 0) {
    return 1/(-$s+1);
  } else {
    return ($s+1);
  }
}

sub scale {
  my ($self,$new_scale,$current_node)=@_;
  my $c=$self->realcanvas;
  my $factor = 1;
  for my $s (-$self->{scale},$new_scale) {
    if ($s < 0) {
      $factor /= (-$s+1);
    } else {
      $factor *= ($s+1);
    }
  }
  my ($x,$y);
  if (defined $current_node) {
    if (ref($current_node)) {
      ($x,$y)= map $self->get_node_pinfo($current_node,$_), "XPOS","YPOS";
    } else {
      ($x,$y) = ($c->canvasx($c->pointerx-$c->rootx),$c->canvasy($c->pointery-$c->rooty));
    }
  } else {
    ($x,$y)=(0,0);
  }
  my $nx = $x*$factor;
  my $ny = $y*$factor;
  my @corners = (
    $c->canvasx(0),
    $c->canvasy(0),
    $c->canvasx($c->width),
    $c->canvasy($c->height),
   );
  my @scrollregion=@{$c->cget('-scrollregion')};
  $c->configure(-scrollregion =>
		  [
		    min($corners[0]-$x+$nx,$scrollregion[0],$corners[0]),
		    min($corners[1]-$y+$ny,$scrollregion[1],$corners[1]),
		    max($corners[2]-$x+$nx,$scrollregion[2],$corners[2]),
		    max($corners[3]-$y+$ny,$scrollregion[3],$corners[3])
		   ]);
  my $xview= $c->xviewCoord($x);
  my $yview= $c->yviewCoord($y);

  $self->{scale} = $new_scale;
  $c->scale('all', 0,0, $factor, $factor);
  # scale font
  $self->scale_font($factor);
  $c->itemconfigure('text_item', -font => $self->{scaled_font});
  $self->{$_}*=$factor for qw(canvasWidth canvasHeight);

  $c->xviewCoord($x*$factor,$xview);
  $c->yviewCoord($y*$factor,$yview);
  $c->configure(-scrollregion => [min2(0,$c->canvasx(0)),
				  min2(0,$c->canvasy(0)),
				  max2($c->canvasx($c->width),$self->{canvasWidth}),
				  max2($c->canvasx($c->height),$self->{canvasHeight})]);
}

sub scale_font {
  my ($self,$factor)=@_;
  my $font = $self->{scaled_font} || $self->get_font;
  my $c = $self->realcanvas;
  if (!ref $font) {
    $font = $c->fontCreate($c->fontActual($font))
  }
  if (!defined $self->{font_size}) {
    $self->{font_size}=$font->actual('-size');
  }
  $self->{font_size} *= $factor;
  my $new_size = int($self->{font_size})||1;
  $font = $font->Clone(-size => $new_size);
  $self->{scaled_font}= $font;
}

sub reset_scale {
  my $self=shift;
  $self->{scale}=0;
  $self->{font_size}=undef;
  $self->{scaled_font}=undef;
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
  my $val = $self->{pinfo}->{"node:${node};${key}"};
  if ($key=~/[XY]/) {
    return $self->scale_factor * $val;
  } else {
    return $val;
  }
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
  if (@patterns) {
    my $node=$fsfile->treeList->[$tree_no];
    my @sent=();
    my $attr=$fsfile->FS->sentord();
    $attr=$fsfile->FS->order() unless (defined($attr));
    # schwartzian transform
    if (defined($attr)) {
      while ($node) {
	my $ord = $node->get_member($attr);
	push @sent,[$node,$ord]
	  unless ($ord>=999); # this unless is a PDT1.0 specific thing
	$node=$node->following();
      }
    } else {
      # try to get the per-node ordering
      my %ord_attr_hash; # hash ordering attributes by type
      while ($node) {
	my $ord;
	# find ordering attribute
	my $type = $node ? $node->type : undef;
	if ($type) {
	  my $ord_attr = $ord_attr_hash{ $type };
	  unless (defined($ord_attr)) {
	    ($ord_attr) = $node->get_ordering_member_name;
	    $ord_attr_hash{ $type } = $ord_attr;
	  }
	  $ord = $node->get_member($ord_attr);
	  push @sent, [$node,$ord];
	} else {
	  push @sent, [$node,0];
	}
	$node=$node->following();
      }
    }
    @sent = map { $_->[0] } sort { $a->[1] <=> $b->[1] } @sent;
    my @vl=();

    foreach $node (@sent) {
      my %styles;
      my $add_space=0;
      foreach my $style (@patterns) {
	my $msg=$self->interpolate_text_field($node,$style,$grp);
	foreach (split(m/([\#\$]${bblock})/,$msg)) {
	  if (/^\$${block}$/) {
	    #attr
	    my $val = _present_attribute($node,$1);
	    if ($val ne "") {
	      push @vl,[$val,$node, map { encode("$_ => $styles{$_}") }
			keys %styles];
	      $add_space=1;
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
	  } elsif ($_ ne '') {
	    push @vl,[$_,$node,'text',map { encode("$_ => $styles{$_}") } keys %styles];
	    $add_space=1;
	  }
	}
      }
      push @vl,[" ",'space'] if $add_space;
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
  if ($tags or $self->get_label_patterns($fsfile,"text")) {
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

  my $l = callback($on_get_nodes,$self,$fsfile,$tree_no,$prevcurrent);
  if (ref($l) eq 'ARRAY' and @$l==2) {
    return @$l;
  } else {
    my ($nodes,$current)=$fsfile->nodes($tree_no,$prevcurrent,$self->get_showHidden());
    if ($self->{reverseNodeOrder}) {
      return ([reverse @$nodes],$current);
    }
    return ($nodes,$current);
  }
}

sub getFontHeight {
  my ($self)=@_;
  return $self->canvas->fontMetrics($self->get_font, -linespace);
}

sub getTextWidth {
  my ($self,$text,$wrap)=@_;
  return $wrap ? max(map { $self->canvas->fontMeasure($self->get_font,$_) } split /\n/,$text) :
    $self->canvas->fontMeasure($self->get_font,$text);
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
  my $xskip = $balanceOpts->[2];

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


sub _bno {
  my ($nodes,$i,$last,$childs)=@_;
  my @res;
  for (;$i<=$last;$i++) {
    my $node = $nodes->[$i];
    my $kids = $childs->{ $node };
    if ($kids) {
      my $mid = int @$kids/2-1;
      push @res,
	@{ _bno($kids,0,$mid,$childs) },
	$node,
	@{ _bno($kids,$mid+1,$#$kids,$childs) };
    } else {
      push @res, $node;
    }
  }
  return \@res;
}

sub balance_node_order {
  my ($self, $nodes) = @_;
  my %childs;
  my @level0;
  my $i=0;
  foreach my $node (@$nodes) {
    my $parent = $self->get_node_pinfo($node,"P");
    push @{ $childs{ $parent } }, $node;
    push @level0, $node if $self->get_node_pinfo($node,"Level")==0;
  }
  return _bno(\@level0,0,$#level0,\%childs);
}

sub compute_level {
  my ($self, $node, $Opts, $skipHiddenLevels) = @_;
  my $level = $self->get_node_pinfo($node,"Level");
  if (defined $level) {
    return $level;
  }
  $level=0;
  my $parent=$node->parent;
  if ($parent) {
    my $plevel = $self->compute_level($parent, $Opts, $skipHiddenLevels);
    if ($skipHiddenLevels) {
      $level = $plevel;
      if ($self->get_node_pinfo($parent,"E")) {
	$self->store_node_pinfo($node,"P",$parent);
	$level++;
      } else {
	$self->store_node_pinfo($node,"P",$self->get_node_pinfo($parent,"P"));
      }
      $level += $self->get_style_opt($node,"Node","-rellevel",$Opts) if $self->get_node_pinfo($node,"E");
    } else {
      $self->store_node_pinfo($node,"P",$parent);
      $level = $plevel + 1 + $self->get_style_opt($node,"Node","-rellevel",$Opts);
    }
  }
  $self->store_node_pinfo($node,"Level", $level);
  return $level;
}

sub recalculate_positions_vert {
  my ($self,$fsfile,$nodes,$Opts,$grp)=@_;
  return unless ref($self);

  my $lineSpacing=$Opts->{lineSpacing} || $self->get_lineSpacing;
  my $baseXPos=$Opts->{baseXPos} || $self->get_baseXPos;
  my $baseYPos=$Opts->{baseYPos} || $self->get_baseYPos;
  my $level;

  my $canvasWidth=0;
  $self->{canvasHeight}=0;
  my $node;
  my $labelsep = $Opts->{'labelsep'};
  $labelsep = $self->get_labelSep unless defined $labelsep;
  my $columnsep = $Opts->{'columnsep'};
  $columnsep = $self->get_columnSep unless defined $columnsep;
  my ($nodeWidth,$nodeHeight)=($self->get_nodeWidth,$self->get_nodeHeight);
  my $nodeXSkip = exists($Opts->{nodeXSkip}) ? $Opts->{nodeXSkip} : $self->get_nodeXSkip;
  my $nodeYSkip = exists($Opts->{nodeYSkip}) ? $Opts->{nodeYSkip} : $self->get_nodeYSkip;
  my $m;
  my ($pattern_count,$node_pattern_count,$edge_pattern_count)=(0,0,0);
				# May change with line attached labels
  my @patterns;
  if ($self->patterns) {
    @patterns= @{$self->patterns};
  } elsif (ref($fsfile)) {
    @patterns=$fsfile->patterns();
  }
  @patterns = grep { $_->[0] eq 'node' or
		     $_->[0] eq 'edge' } map { [ $self->parse_pattern($_) ] } @patterns;
  if (ref($fsfile)) {
    $pattern_count=@patterns;
    $node_pattern_count=scalar($self->get_label_patterns($fsfile,"node"));
    $edge_pattern_count=scalar($self->get_label_patterns($fsfile,"edge"));
  }

  my $fontHeight=$self->getFontHeight() * $lineSpacing;
  my $node_label_height=2*$self->get_ymargin + $fontHeight;
  my $levelHeight=max($nodeHeight,$node_label_height) + $nodeYSkip;

  my $xpos;
  my $ypos = $baseYPos;
  my ($pat_style,$pat);

  if (exists($Opts->{ballance})) {
    print STDERR "Use 'balance' instead of misspelled 'ballance'!\n";
    $Opts->{balance}=$Opts->{ballance} unless (exists($Opts->{balance}));
  }
  my $balance= exists($Opts->{balance}) ? 
    $Opts->{balance} : $self->get_balanceTree;

  my $skipHiddenLevels= exists($Opts->{skipHiddenLevels}) ? $Opts->{skipHiddenLevels} : $self->get_skipHiddenLevels;

  my $balanceOpts = [$balance =~ /^aboveMiddleChild(Odd$|$)/ ? 1 : 0,
		     $balance =~ /^aboveMiddleChild(Even$|$)?/ ? 1 : 0,
		     $nodeXSkip
		    ];

  foreach $node (@{$nodes}) {
    $self->store_node_pinfo($node,"E",1);
  }
  foreach $node (@{$nodes}) {
    $self->compute_level($node,$Opts,$skipHiddenLevels);
  }
  if ($balance) {
    @{$nodes} = @{$self->balance_node_order($nodes)};
  }
  # we reverse back to normal order in vertical mode
  foreach $node ($self->get_reverseNodeOrder ? reverse @{$nodes} : @{$nodes}) {
    $level=$self->get_node_pinfo($node,'Level')+$self->get_style_opt($node,"Node","-level",$Opts);

    $xpos = $baseXPos + $level * (15+$nodeXSkip);
    $self->store_node_pinfo($node,"XPOS", $xpos);
    $self->store_node_pinfo($node,"YPOS", $ypos);
    $self->store_node_pinfo($node,"NodeLabel_YPOS", $ypos-$nodeHeight);
    $self->store_node_pinfo($node,"EdgeLabel_YPOS", $ypos-$nodeHeight);
    my $label_xpos = $xpos + $nodeWidth + $labelsep;
    $ypos += $levelHeight;
    $self->{canvasHeight} += $levelHeight;
    if (@patterns) {
      ($pat_style,$pat)=@{$patterns[0]};
      $m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
      if ($pat_style eq 'node') {
	$self->store_node_pinfo($node,"NodeLabelWidth",$m);
	#$self->store_gen_pinfo("NodeLabelWidth[0]",0);
	$self->store_gen_pinfo("NodeLabel_XPOS[0]", $label_xpos);
	$self->store_node_pinfo($node,"NodeLabel_XPOS", $label_xpos); # compat
      } else {
	$self->store_node_pinfo($node,"EdgeLabelWidth",$m);
	#$self->store_gen_pinfo("NodeLabelWidth[0]",0);
	$self->store_gen_pinfo("EdgeLabel_XPOS[0]", $label_xpos);
	$self->store_node_pinfo($node,"EdgeLabel_XPOS", $label_xpos); #compat
      }
      $self->store_node_pinfo($node,"X[0]",$m);
      $canvasWidth = max($canvasWidth, $label_xpos + $m);
      $self->store_node_pinfo($node,"After",0);
      $self->store_node_pinfo($node,"Before",0);
    }
  }
  $self->store_gen_pinfo("NodeLabel_XMIN",$canvasWidth);
  my ($n_i, $e_i)=(-1,-1);
  for (my $i=0; $i<@patterns; $i++) {
    my $max = 0;
    ($pat_style,$pat)=@{$patterns[$i]};
    if ($pat_style eq 'node') { $n_i++ } else { $e_i++ }
    next if $i==0;
    my $sep = $Opts->{'columnsep['.$i.']'};
    $sep = $columnsep unless defined $sep;
    $canvasWidth+=$sep;
    
    foreach $node (@{$nodes}) {
      $m=$self->getTextWidth( $self->prepare_text($node,$pat,$grp) );
      $self->store_node_pinfo($node,"X[$i]",$m);
      $max = max($max,$m);
    }
    if ($pat_style eq 'node') {
      $self->store_gen_pinfo("NodeLabel_XPOS[$n_i]",$canvasWidth);
      $self->store_gen_pinfo("NodeLabelWidth[$n_i]",$max);
    } else {
      $self->store_gen_pinfo("EdgeLabel_XPOS[$e_i]",$canvasWidth);
      $self->store_gen_pinfo("EdgeLabelWidth[$e_i]",$max);
    }
    $canvasWidth+=$max;
  }
  $self->store_gen_pinfo("NodeLabel_XMAX",$canvasWidth);
  $self->{canvasWidth} = $canvasWidth+$self->get_xmargin;
  $self->{canvasHeight} += $self->get_ymargin;
}

sub recalculate_positions {
  my ($self,$fsfile,$nodes,$Opts,$grp)=@_;
  return unless ref($self);

  my $baseXPos=$Opts->{baseXPos} || $self->get_baseXPos;
  my $baseYPos=$Opts->{baseYPos} || $self->get_baseYPos;
  my $lineSpacing=$Opts->{lineSpacing} || $self->get_lineSpacing;
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
  @patterns = grep { $_->[0] eq 'node' or
		     $_->[0] eq 'edge' } map { [ $self->parse_pattern($_) ] } @patterns;
  if (ref($fsfile)) {
    $pattern_count=@patterns;
    $node_pattern_count=scalar($self->get_label_patterns($fsfile,"node"));
    $edge_pattern_count=scalar($self->get_label_patterns($fsfile,"edge"));
  }

  my $fontHeight=$self->getFontHeight()*$lineSpacing;
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
		     $balance =~ /^aboveMiddleChild(Even$|$)?/ ? 1 : 0,
		     $nodeXSkip
		    ];

  foreach $node (@{$nodes}) {
    $self->store_node_pinfo($node,"E",1);
  }
  foreach $node (@{$nodes}) {
    $level=$self->compute_level($node,$Opts,$skipHiddenLevels);
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
      ($pat_style,$pat)=@{$patterns[$i]};
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
  my $fill;
  if ($edge) {
    $fill = ($currentNode == $node) ?
	    $self->get_currentEdgeBoxColor :
	    ($fs->isHidden($node) ?
	     $self->get_hiddenEdgeBoxColor :
	     $self->get_edgeBoxColor);
	   ;
  } else {
    $fill = ($currentNode == $node) ?
	    $self->get_currentBoxColor :
	    ($fs->isHidden($node) ?
	     $self->get_hiddenBoxColor :
	     $self->get_boxColor);
  }
  return (
      -width => 1,
      -activewidth => 1,
      -outline => 'black',
      -activeoutline => 'black',
      -fill => $fill,
      -activefill => $fill,
     );
}


sub node_coords {
  my ($self,$node,$currentNode)=@_;
  my $factor=$self->scale_factor;
  my $x=$self->get_node_pinfo($node,'XPOS')/$factor;
  my $y=$self->get_node_pinfo($node,'YPOS')/$factor;

  my $Opts=$self->get_gen_pinfo('Opts');
  my @ret;
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
    @ret = ($x-$nw/2,
	    $y-$nh/2,
	    $x+$nw/2,
	    $y+$nh/2);
  } else {
    my $horiz=0;
    @ret = map { $horiz=!$horiz; $_+($horiz ? $x : $y) } 
      split(',',$self->get_style_opt($node,'Node','-polygon',$Opts))
  }
  return $factor!=1 ? (map{ $factor * $_ } @ret) : @ret;
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
  my $dash = $self->get_lineDash;
  if ($fs->isHidden($node)) {
    return (-fill => $self->get_hiddenLineColor,
	    ($can_dash ? 
	    ($self->get_dashHiddenLines ? ('-dash' => '-') : 
	       (defined $dash ? (-dash => $dash) : ())) : ())
	   );
  } else {
    return (-fill => $self->get_lineColor,
	    defined($dash) ? (-dash => $self->get_lineDash) : ());
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
  my ($self,$text,$width,$reverse)=@_;
  use integer;
  my @toks = split /\s+/, $text;
  if ($reverse) {
      my @result;
      my $wd=0;
      my $w;
      my $t=pop(@toks);
      my @lines=();
      while ($t) {
	$w=$self->getTextWidth(' '.$t);
	if (($wd+$w>=$width) && (@result>0)) {
	  push @lines, join(' ',@result);
	  @result=($t);
	  $wd=$self->getTextWidth($t);
	} else {
	  $wd+=$w;
	  unshift @result, $t;
	}
	$t=pop(@toks);
      }
      push @lines, join(' ',@result);
      return \@lines;
  } else {
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
    return [@lines,$line];
  }
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
  my $what = $item; $what=~s/^Current//;
  eval { $self->canvas->
	   itemconfigure($self->get_node_pinfo($node,$what),
			 @{$Opts->{$item}||[]},
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
    s{(([xy])\[([-_A-Za-z0-9]+)\s*=\s*((?:[^\]\\]|\\.)+)\])}{
      my $i=0;
      if (exists($nodehash->{$1})) {
	$i=$nodehash->{$1};
      } else {
	$i++ while ($i<@$nodes and
		    !(exists($nodes->[$i]{$3}) and $nodes->[$i]{$3} eq $4));
	$nodehash->{$1}=$i;
      }
      if ($i<@$nodes) { 
	int($self->get_node_pinfo($nodes->[$i],($2 eq 'x') ? "XPOS" : "YPOS"))
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

sub callback {
  my $func = shift;
  if (ref($func) eq 'ARRAY') {
    &{$func->[0]}(@_,@{$func}[1..$#$func]);
  } elsif (ref($func) eq 'CODE') {
    &$func(@_);
  } else {
    return ();
  }
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

  my $scale = $self->{scale};
  $self->reset_scale;
  my (@node_patterns,@edge_patterns,@style_patterns,@patterns);

  my %Opts=();
  foreach (keys %DefaultNodeStyle) {
    $Opts{$_}=[@{$DefaultNodeStyle{$_}}];
  }
  if (ref($fsfile)) {
    @patterns = map { [ $self->parse_pattern($_) ] } ($self->patterns) ? @{$self->patterns} : $fsfile->patterns();
    @node_patterns = map { $_->[1] } grep { $_->[0] eq 'node' } @patterns;
    @edge_patterns = map { $_->[1] } grep { $_->[0] eq 'edge' } @patterns;
    @style_patterns = map { $_->[1] } grep { $_->[0] eq 'style' } @patterns;
    @patterns = grep { $_->[0] eq 'node' or $_->[0] eq 'edge' } @patterns;
  }

  my $canvas = $self->realcanvas;

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
  	if (/^(Oval|CurrentOval|TextBox|EdgeTextBox|CurrentTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-.+?):'?(.+)'?$/) {
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
    callback($on_get_root_style,$self,$node,\%Opts);
  }

  # styling patterns should be interpolated here for each node and
  # the results stored within node_pinfo
  my $filter_nodes = 0;
  my %skip_nodes;
  foreach $node (@{$nodes}) {
    my %nopts=();
    foreach $style (@style_patterns) {
      foreach ($self->interpolate_text_field($node,$style,$grp)=~/\#${block}/g) {
	if (/^((CurrentOval|Oval|CurrentTextBox|TextBox|EdgeTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node)((?:\[[^\]]+\])*)(-[^:]+?)):(.+)$/) {
	  if (exists $nopts{"$2$3"}) {
	    push @{$nopts{"$2$3"}},$4=>$5;
	  } else {
	    $nopts{"$2$3"}=[$4=>$5];
	  }
	  if ($1 eq 'Node-hide') {
	    $skip_nodes{$node}=$5;
	    $filter_nodes = 1;
	  }
	}
      }
    }
    # external styling hook
    callback($on_get_node_style,$self,$node,\%nopts);
    foreach (keys %nopts) {
      $self->store_node_pinfo($node,"style-$_",$nopts{$_});
    }
  }
  if ($filter_nodes and !$self->get_showHidden()) {
    # $nodes = [ grep { !$skip_nodes{$_} } @$nodes ];

    # CAUTION: this change propagates up to the caller
    @$nodes = grep { !$skip_nodes{$_} } @$nodes;
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
  my $vertical_tree = $self->set_verticalTree(
    $self->get_displayMode
      ? (($self->get_displayMode+1)/2)
      : exists($Opts{vertical}) ? $Opts{vertical} : 0 );
  if ($vertical_tree) {
    recalculate_positions_vert($self,$fsfile,$nodes,\%Opts,$grp);
  } else {
    recalculate_positions($self,$fsfile,$nodes,\%Opts,$grp);
  }

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

  my $lineSpacing=$Opts{lineSpacing} || $self->get_lineSpacing;

  # draw sentence info
  if ($fsfile and ($self->get_drawFileInfo or $self->get_drawSentenceInfo)) {
    my $fontHeight=$self->getFontHeight()*$lineSpacing;
    $self->{canvasHeight}+=$fontHeight; # add some skip
    if ($self->get_drawFileInfo) {
      my $currentfile=filename($fsfile->filename);
      my ($ftext);
      $ftext="File: $currentfile";
      if (@$nodes) {
	my $r_node = $nodes->[0]->root;
	my $which_tree = Fslib::Index($fsfile->treeList,$r_node)+1;
	$ftext.=", tree ".$which_tree." of ".($fsfile->lastTreeNo+1);
      } else {
	$ftext='';
      }
      $self->apply_style_opts(
	$canvas->
	  createText(0,
		     $self->{canvasHeight},
		     -tags => ['vline','text_item'],
		     -font => $self->get_font,
		     -text => $ftext,
		     -justify => 'left', -anchor => 'nw'),
	@{$Opts{SentenceText}});
      $self->{canvasHeight}+=$fontHeight;
      my $ftw = $self->getTextWidth($ftext,1);
      $self->{canvasWidth}=max($self->{canvasWidth},$ftw);
      $self->apply_style_opts(
	$canvas->
	  createLine(0,$self->{canvasHeight},
		     ($ftw || 0),
		     $self->{canvasHeight}),
	@{$Opts{SentenceFileInfo}});
      $self->{canvasHeight}+=$fontHeight;
    }
    if ($self->get_drawSentenceInfo) {
      if (ref($valtext) eq 'ARRAY') {
	$valtext = join '',map {$_->[0]} @$valtext;
      } else {
	$valtext=~s{^(.*)/([^:]*):}{};
      }
      $valtext=~s/ +([.,!:;])|(\() |(\)) /$1/g;
      my $i=1;
      my $lines=$self->wrapLines($valtext,$self->{canvasWidth},$self->{reverseNodeOrder});
      foreach (@$lines) {
	if ($self->{reverseNodeOrder}) {
	  $self->apply_style_opts(
	    $canvas->
	      createText($self->{canvasWidth},
					   $self->{canvasHeight},
			 -font => $self->get_font,
			 -tags => ['vline','text_item'],
			 -text => $_,
			 -justify => 'right',
			 -anchor => 'ne'),
	    @{$Opts{SentenceLine}});
	} else {
	  $self->apply_style_opts(
	    $canvas->
	      createText(0,$self->{canvasHeight},
			 -font => $self->get_font,
			 -tags => ['vline','text_item'],
			 -text => $_,
					   -justify => 'left',
			 -anchor => 'nw'),
	    @{$Opts{SentenceLine}});
	}
	$self->{canvasHeight}+=$fontHeight;
      }
    }

#    $canvas->createRectangle(0,0, $self->{canvasWidth},$self->{canvasHeight},
#			      -outline => 'black',
#			      -fill => undef,
#				   -tags => 'vline'
#			     );
  }
#   $canvas->configure(-scrollregion =>[0,0,
# 				      $self->{canvasWidth},
# 				      $self->{canvasHeight}]);
#   $canvas->xviewMoveto(0);
#   $canvas->yviewMoveto(0);

  my $lineHeight=$self->getFontHeight() * $lineSpacing;
  my $edge_label_yskip= (scalar(@node_patterns) ? $self->get_edgeLabelSkipAbove : 0);
  my $can_dash=($Tk::VERSION=~/\.([0-9]+)$/ and $1>=22);
  $objectno=0;

  my $skipHiddenLevels = $Opts{skipHiddenLevels} || $self->get_skipHiddenLevels;
  my $skipHiddenParents = $skipHiddenLevels || $Opts{skipHiddenParents} || $self->get_skipHiddenParents;

  foreach $node (@{$nodes}) {
    $parent = $self->get_node_pinfo($node,"P");
#     if ($skipHiddenParents) {
#       $parent = $node->parent;
#       $parent=$parent->parent while ($parent and !$self->get_node_pinfo($parent,"E"));
#     } else {
#       $parent=$node->parent;
#     }
    use integer;

    ## Lines ##
    my @tag=split '&',$self->get_style_opt($node,"Line","-tag",\%Opts);
    my @arrow=split '&',$self->get_style_opt($node,"Line","-arrow",\%Opts);
    my @arrowshape=map { $_=~/^(\d+),(\d+),(\d+)$/ ? [split /,/] : undef } 
      split '&',$self->get_style_opt($node,"Line","-arrowshape",\%Opts);
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
      my $arrow_shape = $arrowshape[$lin] || $self->get_lineArrowShape;
      my @opts = ($self->line_options($node,$fsfile->FS,$can_dash),
		     -tags => [$line,'line'],
		     -arrow =>  $arrow[$lin] || $self->get_lineArrow,
                     (defined($arrow_shape) ? (-arrowshape => $arrow_shape) : ()),
		     -width =>  $width[$lin] || $self->get_lineWidth,
		     ($fill[$lin] ? ('-fill'  => $fill[$lin]) : ()),
		     (($dash[$lin] && $can_dash) ? ('-dash'  => $dash[$lin]) : ()),
		     '-smooth'  =>  ($smooth[$lin] || 0));
      eval {
	$l=$canvas->
	  createLine(@c, @opts);
      };
      if (defined $@ and length $@) {
	use Data::Dumper;
	print STDERR "createLine: ",
	  Data::Dumper->new([\@opts],['opts'])->Dump;
	print STDERR $@;
      }
      $self->store_id_pinfo($l,$line);
      $self->store_node_pinfo($node,"Line$lin",$line);
      $self->store_obj_pinfo($line,$node);
      $self->store_gen_pinfo('tag:'.$line,$tag[$lin]);
      $canvas->lower($line,'all');
      $canvas->raise($line,'line');

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
    if (not $vertical_tree and scalar(@edge_patterns) and $parent) {
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
      && ($valign_edge=$self->get_style_opt($node,"NodeLabel","-dodrawbox",\%Opts) eq "yes");
    $self->store_node_pinfo($node,"NodeHasBox",$node_has_box);
    ## Boxes around attributes
    if ($vertical_tree && $self->get_horizStripe || !$vertical_tree && $self->get_vertStripe) {
      $objectno++;
      my $stripe = "stripe_$objectno";
      my $stripe_id = $canvas->
	createRectangle(
	  $vertical_tree ?
	    (-200,
	     0+$self->get_node_pinfo($node,"NodeLabel_YPOS")-$self->get_ymargin,
	     0+$self->{canvasWidth}+200,
	     $self->get_node_pinfo($node,"NodeLabel_YPOS")+$self->get_ymargin+$lineHeight,
	    ) :
	    (
	     0+$self->get_node_pinfo($node,"XPOS")-$self->get_nodeWidth,
	     -200,
	     0+$self->get_node_pinfo($node,"XPOS")+$self->get_nodeWidth,
	     0+$self->{canvasHeight}+200,
	    ),
	   -fill => $currentNode==$node ? $self->get_stripeColor  :
	     $self->realcanvas->cget('-background'),
	   -outline => undef,
	   -tags => [$stripe,'stripe']
	);
      $self->store_id_pinfo($stripe_id,$stripe);
      $self->store_obj_pinfo($stripe,$node);
      $self->store_node_pinfo($node,"Stripe",$stripe)
    }
    if ($node_has_box) {
      ## get maximum width stored here by recalculate_positions
      $objectno++;
      my $box="textbox_$objectno";
      my $bid=$canvas->
	createRectangle(
	  $vertical_tree ? (
	    0+$self->get_gen_pinfo("NodeLabel_XMIN")-$self->get_xmargin,
	    0+$self->get_node_pinfo($node,"NodeLabel_YPOS")-$self->get_ymargin,
	    0+$self->get_gen_pinfo("NodeLabel_XMAX")+$self->get_xmargin,
	    $self->get_node_pinfo($node,"NodeLabel_YPOS")+$self->get_ymargin+$lineHeight) : (
	      0+$self->get_node_pinfo($node,"NodeLabel_XPOS")-$self->get_xmargin,
              0+$self->get_node_pinfo($node,"NodeLabel_YPOS")-$self->get_ymargin,
	      0+$self->get_node_pinfo($node,"NodeLabel_XPOS")+
		$self->get_node_pinfo($node,"NodeLabelWidth")+$self->get_xmargin,
	      0+$self->get_node_pinfo($node,"NodeLabel_YPOS")+ $self->get_ymargin+
		scalar(@node_patterns)*$lineHeight
	    ),
	  -tags => ['textbox',$box]
		       );
      $self->store_id_pinfo($bid,$box);
      $self->apply_style_opts(
	$box,
	$self->node_box_options($node,$fsfile->FS,
				$currentNode,0),
	@{$Opts{TextBox}},
	$self->get_node_style($node,
			      ($node==$currentNode ?
				 "CurrentTextBox" : "TextBox")
			     ));
      $self->store_node_pinfo($node,"TextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }
    $edge_has_box=!$vertical_tree &&
      scalar(@edge_patterns) && $parent &&
	($self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-nodrawbox",\%Opts) ne "yes") ||
	 !$self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-dodrawbox",\%Opts) eq "yes"));
    $self->store_node_pinfo($node,"EdgeHasBox",$edge_has_box);
    if ($edge_has_box) {
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
			-tags => ['edgebox',$box]
		       );
      $self->store_id_pinfo($bid,$box);
      $self->apply_style_opts(
	$box,
	$self->node_box_options($node,
				$fsfile->FS,
				$currentNode,1),
	@{$Opts{EdgeTextBox}},
	$self->get_node_style($node,
			      $node==$currentNode ?
				"CurrentEdgeTextBox" :
				"EdgeTextBox"
			     ));

      $self->store_node_pinfo($node,"EdgeTextBox",$box);
      $self->store_obj_pinfo($box,$node);
    }

    ## Texts of attributes
    my ($msg,$x,$y);
    my ($e_i,$n_i)=(0,0);
    my ($pat_class,$pat);
    for (my $i=0;$i<=$#patterns;$i++) {
      ($pat_class,$pat)=@{$patterns[$i]};
      $msg=$self->interpolate_text_field($node,$pat,$grp);
      if ($pat_class eq "edge") {
	if ($parent||$vertical_tree) {
	  $msg =~ s!/!!g;		# should be done in interpolate_text_field
	  if ($vertical_tree) {
	    $x= $i==0
	      ? 0+$self->get_node_pinfo($node,"EdgeLabel_XPOS")
	      : 0+$self->get_gen_pinfo("EdgeLabel_XPOS[$e_i]");
	    $y=0+$self->get_node_pinfo($node,"EdgeLabel_YPOS");
	  } else {
	    $x=$self->get_node_pinfo($node,"EdgeLabel_XPOS");
	    $y=$self->get_node_pinfo($node,"EdgeLabel_YPOS")+$e_i*$lineHeight;
	  }
	  $e_i++;
	  $self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
				!$edge_has_box,
				\%Opts,$grp,1);
	}
      } else { # node
	if ($vertical_tree) {
	  $x= $i==0
	      ? 0+$self->get_node_pinfo($node,"NodeLabel_XPOS")
	      : 0+$self->get_gen_pinfo("NodeLabel_XPOS[$n_i]");
	  $y=0+$self->get_node_pinfo($node,"NodeLabel_YPOS");
	} else {
	  $x=$self->get_node_pinfo($node,"NodeLabel_XPOS");
	  $y=$self->get_node_pinfo($node,"NodeLabel_YPOS")+$n_i*$lineHeight;
	}
	$n_i++;
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$x,$y,
			      !$node_has_box,
			      \%Opts,$grp);
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
	attach($canvas,
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
  eval {
    if ($vertical_tree && defined $self->get_node_pinfo($currentNode,'Stripe')) {
      $canvas->itemconfigure("textbg_$currentNode", -fill => undef )
    }
  };
  eval { $canvas->lower('stripe','all') };
  $self->raise_order(qw(textbox
			edgetextbox
			textbg
			line
			text
			plaintext
			point));
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
    $canvas->lower('bgimage','all')  if ($canvas->find('withtag','bgimage'));
  }

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
  if (defined $scale) {
    $self->scale($scale);
  } else {
    $self->reset_scroll_region;
  }
}

sub raise_order {
  my ($self,@tags)=@_;
  my $last_ok;
  my $canvas=$self->realcanvas;
  while (@tags) {
    my ($above,$raise)=@tags;
    eval { $canvas->raise($raise,$above) };
    if ($@) {
      if (defined $last_ok) {
	eval { $canvas->raise($raise,$last_ok) };
	print STDERR $@ if $@;
      }
    } else {
      $last_ok = $above;
    }
    shift @tags;
  }
}


sub reset_scroll_region {
  my ($self)=@_;
  my $canvas = $self->canvas;
  $canvas->configure(-scrollregion =>[0,0, $self->{canvasWidth}, $self->{canvasHeight}]);
  $canvas->xviewMoveto(0);
  $canvas->yviewMoveto(0);
}




sub draw_text_line {
  my ($self,$fsfile,$node,$i,$msg,
      $lineHeight,$x,$y,$clear,$Opts,$grp,$edge)=@_;
  my $what = $edge ? "Edge" : "Node";
#  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
  my $align= $self->get_style_opt($node,$what,"-textalign[$i]",$Opts);
  $align = $self->get_style_opt($node,$what,"-textalign",$Opts) unless defined $align;
  my $textdelta;
  my $X=$self->get_node_pinfo($node,"X[$i]");
  if ($align eq 'left') {
    $textdelta=0;
  } elsif ($align eq 'right') {
    my $lw = $self->get_gen_pinfo($what."LabelWidth[$i]");
    $lw = $self->get_node_pinfo($node,$what."LabelWidth") unless defined $lw;
    $textdelta= ($lw - $X);
  } elsif ($align eq 'center') {
    my $lw = $self->get_gen_pinfo($what."LabelWidth[$i]");
    $lw = $self->get_node_pinfo($node,$what."LabelWidth") unless defined $lw;
    $textdelta= ($lw - $X)/2;
  }
  ## Clear background
  if ($self->get_clearTextBackground and
      $clear and $X>0) {
    $objectno++;
    my $bg="textbg_$objectno";
    my $bid=$self->canvas->
      createRectangle($x+$textdelta,$y,
		      $x+$textdelta+$X+1,
		      $y+$lineHeight,
		      -fill => $self->realcanvas->cget('-background'),
		      -outline => undef,
		      -tags => [$bg,'textbg',"textbg_$node"]
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
  my @color_stack;
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
		   -tags => [$txt,'text','text_item']
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
	  # one can use also interval syntax, like:  #{red(} .... #{)red}, or #{red(} ... #{)}
	  if ($c=~s/\($//) { 
	    push @color_stack, [$c,$color];
	  } elsif ($c=~s/^\)//) {
	    if ($c eq '' or (@color_stack and $c eq $color_stack[-1][0])) {
	      $c = pop(@color_stack)->[1];
	    } else {
	      warn "Stylesheet error: cannot end #{$color_stack[-1][0](} with #{$c)}\n";
	      undef $c;
	    }
	  }
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
		     -tags => [$txt,'plaintext','text_item']
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
  if ($pattern=~s/^([a-z]+):\s*//) {
    my $t=lc($1);
    $pattern=~s/\s+$//;
    return ($t,$pattern);
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
  my ($self,$node,$text,$grp_ctxt)=@_;
  # make $this, $root, and $grp available for the evaluated expression
  # as in TrEd::Macros
  no strict 'refs';
  my @save = (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'});
  (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'})=
    ($node,($node ? $node->root : undef),$grp_ctxt);
  eval {
    $text=~s{\<\?((?:[^?]|\?[^>])+)\?\>}
      {
	my $result = eval "package TredMacro;\n".
	  $self->interpolate_refs($node,$1);
	print STDERR $@ if $@ and $Debug;
	$result;
      }eg;
  };
  (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'})=@save;
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
	$val = $val->[0];
	redo;
      }
    } elsif (UNIVERSAL::isa($val,'HASH')) {
      $val = $val->{$step};
    } elsif (defined($val)) {
      #warn "Can't follow attribute path '$path' (step '$step')\n";
      return undef; # ERROR
    } else {
      return '';
    }
  }
  if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
    $append="*" if @$val > 1;
    $val = $val->[0];
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

