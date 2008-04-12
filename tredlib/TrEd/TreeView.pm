package TrEd::TreeView;		# -*- cperl -*-

use strict;
#use warnings;
BEGIN {
use Carp;
use Tk;
use Tk::Canvas;
use Tk::CanvasSee;
use Tk::Balloon;
use Tk::Font;
use Fslib;
use TrEd::MinMax;
import TrEd::MinMax;
import TrEd::MinMax 'sum';

use TrEd::Convert;
import TrEd::Convert;

use vars qw($AUTOLOAD @Options %DefaultNodeStyle $Debug $on_get_root_style $on_get_node_style $on_get_nodes %PATTERN_CODE_CACHE %COORD_CODE_CACHE %COORD_SPEC_CACHE);

@Options = qw(CanvasBalloon backgroundColor
  stripeColor vertStripe horizStripe baseXPos baseYPos boxColor
  currentBoxColor currentEdgeBoxColor currentNodeHeight
  currentNodeWidth customColors hiddenEdgeBoxColor edgeBoxColor
  clearTextBackground drawBoxes drawEdgeBoxes backgroundImage
  backgroundImageX backgroundImageY drawFileInfo drawSentenceInfo font
  hiddenBoxColor edgeLabelYSkip highlightAttributes showHidden
  lineArrow lineArrowShape lineColor lineDash hiddenLineColor dashHiddenLines lineWidth
  noColor nodeHeight nodeWidth nodeXSkip nodeYSkip edgeLabelSkipAbove
  edgeLabelSkipBelow textColor xmargin nodeOutlineColor
  nodeColor hiddenNodeColor nearestNodeColor ymargin currentNodeColor
  useFSColors textColorShadow textColorHilite textColorXHilite skipHiddenLevels skipHiddenParents
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
	      Label           =>  [],
	      NodeLabel       =>  [-valign => 'top', -halign => 'left'],
	      EdgeLabel       =>  [-halign => 'center', -valign => 'top']
	     );
}

# # #this is a stub
# our $TEST;
#   use Benchmark qw(:all);
#   *old_redraw = \&redraw;
#   *redraw = sub {
#     my @args = @_;
# #     print timethese(10, {
# #       'c7t1' => sub { old_redraw(@args); },
# #     });
#      print cmpthese(10, {	# 
#        'c0t0' => sub { $TEST=0; old_redraw(@args); },
#        'c7t1' => sub { $TEST=1; old_redraw(@args); } ,
#       });
#   };

#our $objectno;
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

sub clear_code_caches {
  %PATTERN_CODE_CACHE=();
  %COORD_CODE_CACHE=();
}

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { canvas    => shift,
	      patterns  => undef,
	      hint      => undef,
	      node_info => {},  # contains per-node information
	      style_info => {}, # contains information about styles
	      style_hash_info => {}, # -"- cached as hashes
	      gen_info => {},   # contains general information about the canvas
	      oinfo_info => {}, # maps canvas objects to nodes
	      iinfo_info => {}, # maps canvas object numbers to ID tags
	      @_ };

  bless $new, $class;
  return $new;
}

sub AUTOLOAD {
  my $self=shift;
  croak "Unknown function $AUTOLOAD" unless ref($self);
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
  $self->{pattern_lists}=undef; # clear cached value so that the following call knows it should regenerate it
  $self->{pattern_lists} = $self->get_pattern_lists();
}

sub get_pattern_lists {
  my ($self,$fsfile)=@_;
  my $patterns = $self->patterns;
  if ($patterns && $self->{pattern_lists}) {
    return $self->{pattern_lists};
  }
  my (@node_patterns,@edge_patterns,@style_patterns,@patterns,@label_patterns);
  my @patterns = map { [ $self->parse_pattern($_) ] } 
    $patterns ? @{$patterns} :
    $fsfile         ? $fsfile->patterns() : ();
  @label_patterns = map { $_->[1] } grep { $_->[0] eq 'label' } @patterns;
  @style_patterns = map { $_->[1] } grep { $_->[0] eq 'style' } @patterns;
  @patterns = grep { $_->[0] eq 'node' or $_->[0] eq 'edge' } @patterns;
  @node_patterns = map { $_->[1] } grep { $_->[0] eq 'node' } @patterns;
  @edge_patterns = map { $_->[1] } grep { $_->[0] eq 'edge' } @patterns;
  my $pl = [\@node_patterns,\@edge_patterns,\@style_patterns,\@patterns,\@label_patterns];
  if ($patterns) {
    $self->{pattern_lists}=$pl;
  }
  return $pl;
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
  return unless ref($self);
  return $self->{canvas};
}

sub realcanvas {
  my $self = shift;
  return unless ref($self);
  return ($self->{realcanvas}||= ($self->{canvas}->isa("Tk::Canvas")
				    ? $self->{canvas} : $self->{canvas}->Subwidget("scrolled")));
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
		    min($corners[0]-$x+$nx,$scrollregion[0],$corners[0])||0,
		    min($corners[1]-$y+$ny,$scrollregion[1],$corners[1])||0,
		    max($corners[2]-$x+$nx,$scrollregion[2],$corners[2])||0,
		    max($corners[3]-$y+$ny,$scrollregion[3],$corners[3])||0,
		   ]);
  my $xview= $c->xviewCoord($x);
  my $yview= $c->yviewCoord($y);

  $self->{scale} = $new_scale;
  $c->scale('all', 0,0, $factor, $factor);
  # scale font
  if ($factor!=1) {
    $self->scale_font($factor);
    $c->itemconfigure('text_item', -font => $self->{scaled_font});
  }
  $self->{$_}*=$factor for qw(canvasWidth canvasHeight);
  for my $item ($c->find(withtag=>'scale_width')) {
    $c->itemconfigure($item, -width => $factor*$c->itemcget($item,'-width'));
  }


  $c->xviewCoord($x*$factor,$xview);
  $c->yviewCoord($y*$factor,$yview);
  $c->configure(-scrollregion => [min2(0,$c->canvasx(0))||0,
				  min2(0,$c->canvasy(0))||0,
				  max2($c->canvasx($c->width),$self->{canvasWidth})||0,
				  max2($c->canvasx($c->height),$self->{canvasHeight})])||0;
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


sub clear_pinfo {
  my $self = shift;
  return undef unless ref($self);
  %{$self->{node_info}}=();
  %{$self->{style_info}}=();
  %{$self->{style_hash_info}}=();
  %{$self->{gen_info}}=();
  %{$self->{oinfo}}=();
#  %{$self->{iinfo}}=();
}

sub store_gen_pinfo {
  my ($self,$key,$value) = @_;
  return undef unless ref($self);
  $self->{gen_info}->{$key}=$value;
}
sub get_gen_pinfo {
  my ($self,$key) = @_;
  return undef unless ref($self);
  return $self->{gen_info}->{$key};
}


sub store_node_pinfo {
  my ($self,$node,$key,$value) = @_;
  return undef unless ref($self);
  $self->{node_info}{$node}{$key}=$value;
}

sub store_obj_pinfo {
  my ($self,$obj,$value) = @_;
  return undef unless ref($self);
  $self->{oinfo}->{$obj}=$value;
}

# sub get_id_pinfo {
#   my ($self,$obj) = @_;
#   return undef unless ref($self);
#   return $self->{iinfo}->{$obj};
# }

# sub store_id_pinfo {
#   my ($self,$obj,$value) = @_;
#   return undef unless ref($self);
#   $self->{iinfo}->{$obj}=$value;
# }

sub get_node_pinfo {
  my ($self,$node,$key) = @_;
  return undef unless ref($self);
  my $val;
  $val = $self->{node_info}{$node}{$key};
  if ($key=~/[XY]/) {
    return $self->scale_factor * $val;
  } else {
    return $val;
  }
}

sub get_obj_pinfo {
  my ($self,$obj) = @_;
  return undef unless ref($self);
  return $self->{oinfo}->{$obj};
}

sub node_is_displayed {
  my ($self,$node)=@_;
  return $self->{node_info}{$node}{E} ? 1 : 0;
}

sub find_item {
  my $self = shift;
  #return map { $self->get_id_pinfo($_) } 
  return $self->canvas()->find(@_);
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
  my $font = $self->get_font;
  if ($self->{cached_font} eq $font) {
    return $self->{cached_size};
  } else {
    $self->{cached_font}=$font;
    return ($self->{cached_size} = $self->canvas->fontMetrics($font, -linespace));
  }
}

sub getTextWidth {
  my ($self,$text,$wrap)=@_;
  return $wrap ? max(map { $self->canvas->fontMeasure($self->get_font,$_) } split /\n/,$text) :
    $self->canvas->fontMeasure($self->get_font,$text);
}

sub balance_xfix_node {
  my ($self, $xfix, $node) = @_;
  my $node_info = $self->{node_info};
  $xfix += $node_info->{$node}{"XFIX"};
  foreach my $c (@{$node_info->{$node}{"CH"}}) {
    $node_info->{$c}{"XPOS"}=$node_info->{$c}{"XPOS"}+$xfix;
    $node_info->{$c}{"NodeLabel_XPOS"}=
			    $node_info->{$c}{"NodeLabel_XPOS"}+
			    $xfix;
    balance_xfix_node($self,$xfix,$c);
  }
}

# this routine computes node XPos in balanced mode
sub balance_node {
  my ($self, $baseX, $node, $balanceOpts) = @_;
  my $last_baseX = $baseX;
  my $xskip = $balanceOpts->[2];
  my $node_info = $self->{node_info};
  my $i=0;
  my $before = $node_info->{$node}{"Before"};
#  $last_baseX+=$node_info->{$node}{"Before"};
  my $CH = $node_info->{$node}{"CH"};
  my @c = $CH ? @$CH : ();
  foreach my $c (@c) {
    $last_baseX = $self->balance_node($last_baseX,$c,$balanceOpts);
    $last_baseX += $xskip;
  }
  $last_baseX -= $xskip if @c;
  my $xpos;
  if (!@c) {
    $xpos = $last_baseX+$node_info->{$node}{"XPOS"};
  } else {
    if (scalar(@c) % 2 == 1) { # odd number of nodes
      if ($balanceOpts->[0]) { # balance on middle node
	$xpos =$node_info->{$c[$#c/2]}{"XPOS"};
      } else {
	$xpos =($node_info->{$c[$#c]}{"XPOS"}
		+ $node_info->{$c[0]}{"XPOS"})/2;
      }
    } else { # even number of nodes
      if ($balanceOpts->[1]) {
	$xpos =
	  ($node_info->{$c[1+$#c/2]}{"XPOS"} +
	   $node_info->{$c[$#c/2]}{"XPOS"})/2;
      } else {
	$xpos =($node_info->{$c[$#c]}{"XPOS"}
		+ $node_info->{$c[0]}{"XPOS"})/2;
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
  $node_info->{$node}{"XFIX"}= $xfix;
  my $add = $xpos-$node_info->{$node}{"XPOS"};
  $node_info->{$node}{"XPOS"}= $xpos;

  $node_info->{$node}{"NodeLabel_XPOS"} =
			  $node_info->{$node}{"NodeLabel_XPOS"} +
			  $add;
  return max($last_baseX,$xpos+
	     $node_info->{$node}{"After"});
}


sub _bno {
  my ($nodes,$i,$last,$node_info)=@_;
  my @res;
  for (;$i<=$last;$i++) {
    my $node = $nodes->[$i];
    my $kids = $node_info->{ $node }{"CH"};
    if ($kids) {
      my $mid = int @$kids/2-1;
      push @res,
	@{ _bno($kids,0,$mid,$node_info) },
	$node,
	@{ _bno($kids,$mid+1,$#$kids,$node_info) };
    } else {
      push @res, $node;
    }
  }
  return \@res;
}

sub balance_node_order {
  my ($self, $nodes) = @_;
  my @level0;
  my $i=0;
  my $node_info = $self->{node_info};
  foreach my $node (@$nodes) {
    my $parent = $node_info->{$node}{"P"};
    push @{ $node_info->{$parent}{"CH"} }, $node;
    push @level0, $node if $node_info->{$node}{"Level"}==0;
  }
  return _bno(\@level0,0,$#level0,$node_info);
}

sub compute_level {
  my ($self, $node, $Opts, $skipHiddenLevels) = @_;
  my $node_info = $self->{node_info};
  my $level = $node_info->{$node}{"Level"};
  if (defined $level) {
    return $level;
  }
  $level=0;
  my $parent=$node->parent;
  if ($parent) {
    my $plevel = $self->compute_level($parent, $Opts, $skipHiddenLevels);
    if ($skipHiddenLevels) {
      $level = $plevel;
      if ($node_info->{$parent}{"E"}) {
	$node_info->{$node}{"P"}=$parent;
	$level++;
      } else {
	$node_info->{$node}{"P"} = $node_info->{$parent}{"P"};
      }
      $level += $self->get_style_opt($node,"Node","-rellevel",$Opts) if $node_info->{$node}{"E"};
    } else {
      $node_info->{$node}{"P"}=$parent;
      $level = $plevel + 1 + $self->get_style_opt($node,"Node","-rellevel",$Opts);
    }
  }
  $node_info->{$node}{"Level"}= $level;
  return $level;
}

sub recalculate_positions_vert {
  my ($self,$fsfile,$nodes,$Opts,$grp)=@_;
  return unless ref($self);
  my $node_info = $self->{node_info};
  my $gen_info = $self->{gen_info};
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
  my ($patterns,$pattern_count,$node_pattern_count,$edge_pattern_count);
  {
    my $pl = $self->get_pattern_lists($fsfile);
    $patterns = $pl->[3];
    $pattern_count = scalar(@{$patterns});
    $node_pattern_count = scalar(@{$pl->[0]});
    $edge_pattern_count = scalar(@{$pl->[1]});
  }
  # May change with line attached labels

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
    $node_info->{$node}{"E"}=1;
  }
  foreach $node (@{$nodes}) {
    $self->compute_level($node,$Opts,$skipHiddenLevels);
  }
  if ($balance) {
    @{$nodes} = @{ $self->balance_node_order($nodes) };
  }
  # we reverse back to normal order in vertical mode
  foreach $node ($self->get_reverseNodeOrder ? reverse @{$nodes} : @{$nodes}) {
    $level=$node_info->{$node}{'Level'}+$self->get_style_opt($node,"Node","-level",$Opts);

    $xpos = $baseXPos + $level * (15+$nodeXSkip);
    $node_info->{$node}{"XPOS"}= $xpos;
    $node_info->{$node}{"YPOS"}= $ypos;
    $node_info->{$node}{"NodeLabel_YPOS"}= $ypos-$nodeHeight;
    $node_info->{$node}{"EdgeLabel_YPOS"}= $ypos-$nodeHeight;
    my $label_xpos = $xpos + $nodeWidth + $labelsep;
    $ypos += $levelHeight;
    $self->{canvasHeight} += $levelHeight;
    if ($pattern_count) {
      ($pat_style,$pat)=@{$patterns->[0]};
      $m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
      if ($pat_style eq 'node') {
	$node_info->{$node}{"NodeLabelWidth"}=$m;
	#$gen_info->{"NodeLabelWidth[0]"}=0;
	$gen_info->{"NodeLabel_XPOS[0]"}= $label_xpos;
	$node_info->{$node}{"NodeLabel_XPOS"}= $label_xpos; # compat
      } else {
	$node_info->{$node}{"EdgeLabelWidth"}=$m;
	#$gen_info->{"NodeLabelWidth[0]"}=0;
	$gen_info->{"EdgeLabel_XPOS[0]"}= $label_xpos;
	$node_info->{$node}{"EdgeLabel_XPOS"}= $label_xpos; #compat
      }
      $node_info->{$node}{"X[0]"}=$m;
      $canvasWidth = max($canvasWidth, $label_xpos + $m);
      $node_info->{$node}{"After"}=0;
      $node_info->{$node}{"Before"}=0;
    }
  }
  $gen_info->{"NodeLabel_XMIN"}=$canvasWidth;
  my ($n_i, $e_i)=(-1,-1);
  for (my $i=0; $i<$pattern_count; $i++) {
    my $max = 0;
    ($pat_style,$pat)=@{$patterns->[$i]};
    if ($pat_style eq 'node') { $n_i++ } elsif ($pat_style eq 'edge') { $e_i++ }
    next if $i==0;
    my $sep = $Opts->{'columnsep['.$i.']'};
    $sep = $columnsep unless defined $sep;
    $canvasWidth+=$sep;
    
    foreach $node (@{$nodes}) {
      $m=$self->getTextWidth( $self->prepare_text($node,$pat,$grp) );
      $node_info->{$node}{"X[$i]"}=$m;
      $max = max($max,$m);
    }
    if ($pat_style eq 'node') {
      $gen_info->{"NodeLabel_XPOS[$n_i]"}=$canvasWidth;
      $gen_info->{"NodeLabelWidth[$n_i]"}=$max;
    } else {
      $gen_info->{"EdgeLabel_XPOS[$e_i]"}=$canvasWidth;
      $gen_info->{"EdgeLabelWidth[$e_i]"}=$max;
    }
    $canvasWidth+=$max;
  }
  $gen_info->{"NodeLabel_XMAX"}=$canvasWidth;
  $self->{canvasWidth} = $canvasWidth+$self->get_xmargin;
  $self->{canvasHeight} += $self->get_ymargin;
}

sub recalculate_positions {
  my ($self,$fsfile,$nodes,$Opts,$grp)=@_;
  return unless ref($self);
  my $node_info = $self->{node_info};
  my $gen_info = $self->{gen_info};
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

  my ($patterns,$pattern_count,$node_pattern_count,$edge_pattern_count);
  {
    my $pl = $self->get_pattern_lists($fsfile);
    $patterns = $pl->[3];
    $pattern_count = scalar(@{$patterns});
    $node_pattern_count = scalar(@{$pl->[0]});
    $edge_pattern_count = scalar(@{$pl->[1]});
  }

  my $fontHeight=$self->getFontHeight()*$lineSpacing;
  my $edge_label_height=2*$self->get_ymargin + $edge_pattern_count*$fontHeight;
  my $levelHeight=$nodeHeight;

  if ($edge_pattern_count) {
    $levelHeight +=
	     $self->get_edgeLabelSkipAbove
	  +  $self->get_edgeLabelSkipBelow
	  +  $edge_label_height;
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
    $node_info->{$node}{"E"}=1;
  }
  foreach $node (@{$nodes}) {
    my $level = $self->compute_level($node,$Opts,$skipHiddenLevels);
    my ($n_nonempty,$e_nonempty);
    my $skip_empty_nlabels = $self->get_style_opt($node,"NodeLabel","-skipempty",$Opts);
    my $skip_empty_elabels = $self->get_style_opt($node,"EdgeLabel","-skipempty",$Opts);
    my $NI=($node_info->{$node}||={});
    my ($nodeLabelWidth,$edgeLabelWidth)=(0,0);
    for (my $i=0;$i<$pattern_count;$i++) {
      ($pat_style,$pat)=@{$patterns->[$i]};
      if ($pat_style eq "edge") {
	# this does not actually make
	# the edge label not to overwrap, but helps a little
	$m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
	$NI->{"X[$i]"}=$m;
	$edgeLabelWidth=$m if $m>$edgeLabelWidth;
	$e_nonempty++ if (!$skip_empty_elabels or $m>0);
      } elsif ($pat_style eq "node") {
	$m=$self->getTextWidth($self->prepare_text($node,$pat,$grp));
	$NI->{"X[$i]"}=$m;
	$nodeLabelWidth=$m if $m>$nodeLabelWidth;
	$n_nonempty++ if (!$skip_empty_nlabels or $m>0);

      }
    }
    $NI->{"NodeLabelWidth"}=$nodeLabelWidth;
    $NI->{"EdgeLabelWidth"}=$edgeLabelWidth;
    $NI->{"NodeLabel_nonempty"}=$n_nonempty;
    $NI->{"EdgeLabel_nonempty"}=$e_nonempty;
    $gen_info->{"MaxNodeLabelsOnLevel[$level]"}=$n_nonempty if $gen_info->{"MaxNodeLabelsOnLevel[$level]"}<$n_nonempty;
    $maxlevel=$level if $maxlevel<$level;
  }
  if ($balance) {
    @{$nodes} = @{$self->balance_node_order($nodes)};
  }
  # now we compute he level heights

  my $ymargin=$self->get_ymargin;
  {
    my $ypos = $baseYPos;
    for my $level (0..$maxlevel) {
      my $thisLevelHeight = $levelHeight;
      my $node_pattern_count_on_level = $gen_info->{"MaxNodeLabelsOnLevel[$level]"};
      if ($node_pattern_count_on_level) {
	$thisLevelHeight += $nodeYSkip + 2*$ymargin +$node_pattern_count_on_level*$fontHeight;
	$thisLevelHeight += $nodeYSkip unless ($edge_pattern_count);
      }
      $gen_info->{"LevelYPos[$level]"}=$ypos;
      $ypos += $thisLevelHeight;
    }
    $gen_info->{"LevelYPos[".($maxlevel+1)."]"}=$ypos;
  }
  foreach $node (@{$nodes}) {
    my $NI=$node_info->{$node};
    $level=$NI->{'Level'}+$self->get_style_opt($node,"Node","-level",$Opts);


    $NI->{"EdgeLabelHeight"}= $edge_label_height;

    my $node_label_height=2*$ymargin + $NI->{"NodeLabel_nonempty"}*$fontHeight;
    #   my $node_label_height= $node_pattern_count*$fontHeight;
    #   if ($node_pattern_count) {
    #      $levelHeight += $nodeYSkip + $node_label_height;
    #      $levelHeight += $nodeYSkip unless ($edge_pattern_count);
    #   }
    my $thisLevelHeight = $gen_info->{"LevelHeight[$level]"};
    $ypos = $gen_info->{"LevelYPos[$level]"};

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
    $NI->{"YPOS"}= $ypos;
    $NI->{"NodeLabel_YPOS"}=
			    $ypos
			    +$self->get_style_opt($node,"NodeLabel","-yadj",$Opts)
			    +$valign_shift;
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
	     - $thisLevelHeight;
    }
    $edge_ypos+=$self->get_style_opt($node,"EdgeLabel","-yadj",$Opts);
    $NI->{"EdgeLabel_YPOS"}=$edge_ypos;

    $halign_edge=$self->get_style_opt($node,"EdgeLabel","-halign",$Opts);

    ($nodeLabelWidth,$edgeLabelWidth)=($NI->{"NodeLabelWidth"},$NI->{"EdgeLabelWidth"});

    $halign_node=$self->get_style_opt($node,"NodeLabel","-halign",$Opts);

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

    $NI->{"After"}=$xSkipAfter;
    $NI->{"Before"}=$xSkipBefore;
    if ($balance) {
      #$xSkipBefore+
      $xpos = $self->get_style_opt($node,"Node","-extrabeforeskip",$Opts);
    } else {
      $minxpos=0;
      if ($prevnode[$level]) {
	$minxpos=
	  $node_info->{$prevnode[$level]}{"XPOS"}+
	    $node_info->{$prevnode[$level]}{"After"}+$xSkipBefore;
      } else {
	$minxpos=$baseXPos+$xSkipBefore;
      }
      $xpos=max($xpos,$minxpos)+$nodeXSkip+$self->get_style_opt($node,"Node","-extrabeforeskip",$Opts);
      $prevnode[$level]=$node
    }
    $NI->{"XPOS"}=$xpos;
    $NI->{"NodeLabel_XPOS"}=$xpos+$nodeLabelXShift;

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
                     $gen_info->{"LevelYPos[".($maxlevel+1)."]"} + $ymargin;
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
  my $NI = $self->{node_info}{$node};
  my $x=$NI->{'XPOS'};
  my $y=$NI->{'YPOS'};

  my $Opts=$self->get_gen_pinfo('Opts');
  my @ret;
  my $shape = $self->get_style_opt($node,'Node','-shape',$Opts);
  if ($shape ne 'polygon') {
    my ($nw,$nh);
    if ($self->get_style_opt($node,'Node','-surroundtext',$Opts)) {
      @ret = @{$NI->{"TextBoxCoords"}};
      $nw=$ret[2]-$ret[0];
      $nh=$ret[3]-$ret[1];
      my $addw = ($self->get_style_opt($node,'Node','-addwidth',$Opts)||0);
      my $addh = ($self->get_style_opt($node,'Node','-addheight',$Opts)||0);
      if ($shape eq 'oval') {
	# here we compute the ellipse axes $A,$B from its semi-latus
	# rectum $L and the distance of its foci $C corresponding
	# to text-box width/height or or vice-versa, whichever is less 
	my ($A,$B,$L,$C);
	if ($nw<=$nh) {
	  ($L,$C) = ($nw,$nh)
	} else {
	  ($C,$L) = ($nw,$nh)
	}
	$A=($L+sqrt($L*$L+4*$C*$C))/2;
	$B=sqrt($L*$A);
	($B,$A)=($A,$B) if ($nw<=$nh);
	$addw+=($A-$nw);
	$addh+=($B-$nh);
      }
      @ret=($ret[0]-$addw/2,$ret[1]-$addh/2,$ret[2]+$addw/2,$ret[3]+$addh/2);
    } else {
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
    }
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
	  ($current_node == $node) ?
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
  my $hash_info = $self->{style_hash_info};
  my $S = ($hash_info->{$node}{$style}||={ @{ $self->{style_info}->{$node}{$style}|| [] } });
  return $S->{$opt} if exists $S->{$opt};
  $S = ($hash_info->{$style}||={ @{ $opts->{$style} || [] } });
  return $S->{$opt};
}

sub apply_style_opts {
  my ($self, $item)=(shift,shift);
  eval { $self->realcanvas->itemconfigure($item,@_); };
  print STDERR $@ if $@;
  return $@;
}

sub apply_stored_style_opts {
  my ($self, $item, $node)=@_;
  my $Opts=$self->get_gen_pinfo("Opts");
  my $what = $item; $what=~s/^Current//;
  eval { $self->realcanvas->
	   itemconfigure($self->{node_info}{$node}{$what},
			 @{$Opts->{$item}||[]},
			 $self->get_node_style($node,$item)); };
  print STDERR $@ if $@ ne "";
  return $@;
}

sub get_node_style {
  my ($self,$node,$style)=@_;
  my $s=$self->{style_info}{$node}{$style};
  return $s ? @{$s} : ();
}

sub parse_coords_spec {
  my ($self,$node,$coords,$nodes,$nodehash,$grp_ctxt)=@_;
  # perl inline search
  no strict 'refs';
  my $node_info = $self->{node_info};
  my @save = (${'TredMacro::this'},${'TredMacro::grp'});

  $coords =~
    s{([xy])\[\?((?:.|\n)*?)\?\]}{
      my $i=0;
      my $key="[?${2}?]";
      my $xy=$1;
      my $code=$2;
      if (exists($nodehash->{"$xy$key"})) {
	int($nodehash->{"$xy$key"})
      } else {
	my $cached = $COORD_CODE_CACHE{$key};
	unless (defined $cached) {
	  $code =~s[\$\{([-_A-Za-z0-9/]+)\}][ \$node->attr('$1') ]g;
	  $cached = $COORD_CODE_CACHE{$key}=
	    eval "package TredMacro; sub{ my \$node=\$_[0]; eval { $code } }";
	}
	(${'TredMacro::this'},${'TredMacro::grp'})=($node,$grp_ctxt);
	while ($i<@$nodes) {
	  last if ($cached->($nodes->[$i]));
	  print STDERR $@ if $@ ne "";
	  $i++;
	}
	if ($i<@$nodes) {
	  $nodehash->{"x$key"} = $node_info->{$nodes->[$i]}{"XPOS"};
	  $nodehash->{"y$key"} = $node_info->{$nodes->[$i]}{"YPOS"};
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
	my $that;
	my $cached = $COORD_CODE_CACHE{$key};
	unless (defined $cached) {
	  $code =~s[\$\{([-_A-Za-z0-9/]+)\}][ \$node->attr('$1') ]g;
	  $cached = $COORD_CODE_CACHE{$key}=
	    eval "package TredMacro; sub{ my \$node=\$_[0]; eval { $code } }";
	}
	(${'TredMacro::this'},${'TredMacro::grp'})=($node,$grp_ctxt);
	$that = $cached->($node);
	print STDERR $@ if $@ ne "";
	if (ref($that)) {
	  $nodehash->{"x$key"}=
	    $node_info->{$that}{ "XPOS"};
	  $nodehash->{"y$key"}=
	    $node_info->{$that}{ "YPOS"};
	  int($nodehash->{"$xy$key"})
	} else {
	  #	    print STDERR "NOT-FOUND $code\n";
	  "ERR"
	}
      }
    }ge;
  (${'TredMacro::this'},${'TredMacro::grp'})=@save; # 

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
	int($node_info->{$nodes->[$i]}{($2 eq 'x' ? "XPOS" : "YPOS")})
      } else {
	"ERR"
      }
    }ge;
  return $coords;
}

{
  my ($HAVE_PARENT,$XP,$YP,$XN,$YN); # persistent variables for precompiled subs
sub eval_coords_spec {
  my ($self,$node,$parent,$c,$coords) = @_;
  my $node_info=$self->{node_info};
  $HAVE_PARENT = $parent ? 1 : 0;
  $XP = $HAVE_PARENT ? int($node_info->{$parent}{"XPOS"}) : undef;
  $YP = $HAVE_PARENT ? int($node_info->{$parent}{"YPOS"}) : undef;
  $XN = int($node_info->{$node}{"XPOS"});
  $YN = int($node_info->{$node}{"YPOS"});
  my $key=$c;
  my $cached=$COORD_SPEC_CACHE{$key};
  if (defined $cached) {
    return($cached->());
  } else {
    $c=~s{([xy][np])}{ \U\$$1 }g;
    if ($c=~/[np]/) {
      my $x=0;
      my $cc;
      $c=join ',',
	map {
	  $x=!$x;
	  $cc = $_;
	  if ($x) {
	    $cc=~s{([np])}{ \$X\U$1 }g;
	  } else {
	      $cc=~s{([np])}{ \$Y\U$1 }g;
	    }
	  $cc
	} split/,/,$c;
    }
    if ($c=~/^(?:,| \$[XY]N | \$[XY](P) |[-\s+\?:.\/*%\(\)0-9]|&&|\|\||!|\>|\<(?!>)|==|\>=|\<=|sqrt\(|abs\()*$/) {
      if ($1) {
	$cached = $COORD_SPEC_CACHE{$key} = eval "sub{ \$HAVE_PARENT ? ( $c ) : () }";
      } else {
	$cached = $COORD_SPEC_CACHE{$key} = eval "sub{ ( $c ) }";
      }
      if (length($@)) {
	print STDERR $@;
	return;
	}
      return($cached->());
    } else { # catches ERR too
      print STDERR "TreeView: ERROR IN COORD SPEC: $coords\n";
      return;
    }
  }
}
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
  #  local $SIG{__DIE__} = sub { Carp::confess(@_) };
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
  my ($node_patterns,$edge_patterns,$style_patterns,$patterns,$label_patterns) = @{$self->get_pattern_lists($fsfile)};

  my %Opts=();
  while ( my($k,$v)= each %DefaultNodeStyle ) {
    $Opts{$k}=[@$v];
  }

  my $canvas = $self->realcanvas;

  $self->clear_pinfo();
  my $node_info = $self->{node_info};
  my $gen_info = $self->{gen_info};
  $gen_info->{"Opts"}=\%Opts;

  #------------------------------------------------------------
  #{
  #use Benchmark;
  #my $t0= new Benchmark;
  #for (my $i=0;$i<=50;$i++) {
  #------------------------------------------------------------
  my $pstyle;
  $node=$nodes->[0];
  if ($node) {
    $node=$node->root;
    # only for root node if any
    foreach $style ($self->get_label_patterns($fsfile,"rootstyle")) {
      foreach ($self->interpolate_text_field($node,$style,$grp)=~/\#${block}/g) {
  	if (/^(Oval|CurrentOval|TextBox|EdgeTextBox|CurrentTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node|Label)((?:\[[^\]]+\])*)(-.+?):'?(.+)'?$/) {
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
  my $style_info = $self->{style_info};
  foreach $node (@{$nodes}) {
    my %nopts=();
    foreach $style (@$style_patterns) {
      foreach ($self->interpolate_text_field($node,$style,$grp)=~/\#${block}/g) {
	if (/^((CurrentOval|Oval|CurrentTextBox|TextBox|EdgeTextBox|CurrentEdgeTextBox|Line|SentenceText|SentenceLine|SentenceFileInfo|Text|TextBg|NodeLabel|EdgeLabel|Node|Label)((?:\[[^\]]+\])*)(-[^:]+?)):(.+)$/) {
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
      $style_info->{$node}{$_}=$nopts{$_};
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

  $gen_info->{'lastX'}= 0;
  $gen_info->{'lastY'}= 0;

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
      eval { #apply_style_opts
	$canvas->itemconfigure(
	  $canvas->
	    createText(0,
		       $self->{canvasHeight},
		       -tags => ['vline','text_item'],
		       -font => $self->get_font,
		       -text => $ftext,
		       -justify => 'left', -anchor => 'nw'),
	  @{$Opts{SentenceText}});
      }; print STDERR $@ if $@;
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
	  eval { #apply_style_opts
	    $canvas->itemconfigure(
	    $canvas->
	      createText($self->{canvasWidth},
					   $self->{canvasHeight},
			 -font => $self->get_font,
			 -tags => ['vline','text_item'],
			 -text => $_,
			 -justify => 'right',
			 -anchor => 'ne'),
	    @{$Opts{SentenceLine}})
	  }; print STDERR $@ if $@;
	} else {
	  eval { #apply_style_opts
	    $canvas->itemconfigure(
	    $canvas->
	      createText(0,$self->{canvasHeight},
			 -font => $self->get_font,
			 -tags => ['vline','text_item'],
			 -text => $_,
					   -justify => 'left',
			 -anchor => 'nw'),
	    @{$Opts{SentenceLine}});
	  }; print STDERR $@ if $@;
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
  my $edge_label_yskip= (scalar(@$node_patterns) ? $self->get_edgeLabelSkipAbove : 0);
  my $can_dash=($Tk::VERSION=~/\.([0-9]+)$/ and $1>=22);
#  $objectno=0;

  my $skipHiddenLevels = $Opts{skipHiddenLevels} || $self->get_skipHiddenLevels;
  my $skipHiddenParents = $skipHiddenLevels || $Opts{skipHiddenParents} || $self->get_skipHiddenParents;

  foreach $node (@{$nodes}) {
    my $NI=$node_info->{$node};
    $parent = $NI->{"P"};
#     if ($skipHiddenParents) {
#       $parent = $node->parent;
#       $parent=$parent->parent while ($parent and !$node_info->{$parent}{"E"});
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
    my %nodehash;

    my $coords=$self->get_style_opt($node,"Line","-coords",\%Opts);
    $coords = $self->parse_coords_spec($node,$coords,$nodes,\%nodehash,$grp);

    my @coords=split '&',$coords;
    my $lin=-1;
    COORD: foreach my $c (@coords) {
      #my @c=split ',',$c;
      my @c = $self->eval_coords_spec($node,$parent,$c,$coords);
      $lin++;
      next unless @c;
#      $objectno++;
#      my $line="line_$objectno";
      my $l;
      my $arrow_shape = $arrowshape[$lin] || $self->get_lineArrowShape;
      my @opts = ($self->line_options($node,$fsfile->FS,$can_dash),
		     -tags => ['line','scale_width'],
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
      if ($@) {
	use Data::Dumper;
	print STDERR "createLine: ",
	  Data::Dumper->new([\@c,\@opts],['coords','opts'])->Dump;
	print STDERR $@."\n";
      } else {
	# $self->store_id_pinfo($l,$line);
	$NI->{"Line$lin"}=$l;
	$self->store_obj_pinfo($l,$node);
	$gen_info->{'tag:'.$l}=$tag[$lin];
	$canvas->lower($l,'all');
	$canvas->raise($l,'line');
      }
   }

    undef %nodehash;

#    $self->apply_style_opts($line,@{$Opts{Line}},
#			    $self->get_node_style($node,"Line"));

    ## Node Shape ##
    my $shape=lc($self->get_style_opt($node,'Node','-shape',\%Opts));

    $shape='oval' unless ($shape eq 'rectangle' or $shape eq 'polygon');

    my $skip_empty_nlabels = $self->get_style_opt($node,"NodeLabel","-skipempty",\%Opts);
    my $skip_empty_elabels = $self->get_style_opt($node,"EdgeLabel","-skipempty",\%Opts);
    $node_has_box=
      $self->get_drawBoxes 
	&& ($valign_edge=$self->get_style_opt($node,"NodeLabel","-nodrawbox",\%Opts) ne "yes")
	  || !$self->get_drawBoxes
	    && ($valign_edge=$self->get_style_opt($node,"NodeLabel","-dodrawbox",\%Opts) eq "yes");
    $NI->{"NodeHasBox"}=$node_has_box;
    if ($node_has_box or $self->get_style_opt($node,'Node','-surroundtext',\%Opts)) {
      my $count = $skip_empty_nlabels ? $NI->{"NodeLabel_nonempty"} : scalar(@$node_patterns);
      $NI->{"TextBoxCoords"} =
	$vertical_tree
	  ? [ 0+$gen_info->{"NodeLabel_XMIN"}-$self->get_xmargin,
	      0+$NI->{"NodeLabel_YPOS"}-$self->get_ymargin,
	      0+$gen_info->{"NodeLabel_XMAX"}+$self->get_xmargin,
	      0+$NI->{"NodeLabel_YPOS"}+$self->get_ymargin+$lineHeight ]
	  : [ 0+$NI->{"NodeLabel_XPOS"}-$self->get_xmargin,
	      0+$NI->{"NodeLabel_YPOS"}-$self->get_ymargin,
	      0+$NI->{"NodeLabel_XPOS"}+
		$NI->{"NodeLabelWidth"}+$self->get_xmargin,
	      0+$NI->{"NodeLabel_YPOS"}+ $self->get_ymargin+
		$count*$lineHeight];
    }
    my @node_coords=$self->node_coords($node,$currentNode);
#    $objectno++;
    # my $oval="oval_$objectno";
    my $o=$canvas->create($shape,
			  @node_coords,
			  -tags => ['point','node'],
			  -outline => $self->get_nodeOutlineColor,
			  $self->node_options($node,
					      $fsfile->FS,
					      $currentNode)
			 );
    # $self->store_id_pinfo($o,$oval);
    eval { #apply_style_opts
      $canvas->itemconfigure($o,@{$Opts{Oval}},
			    $self->get_node_style($node,"Oval"),
			    ($node eq $currentNode ? $self->get_node_style($node,"CurrentOval") : ())
			   );
    }; print STDERR $@ if $@;
    $NI->{"Oval"}=$o;
    $self->store_obj_pinfo($o,$node);

    # EdgeLabel
    if (not $vertical_tree and scalar(@$edge_patterns) and $parent) {
      my $coords = $self->get_style_opt($node,"EdgeLabel","-coords",\%Opts);
      $halign_edge=$self->get_style_opt($node,"EdgeLabel","-halign",\%Opts);
      $valign_edge=$self->get_style_opt($node,"EdgeLabel","-valign",\%Opts);
      $edgeLabelWidth=$NI->{"EdgeLabelWidth"};
      $edgeLabelHeight=$NI->{"EdgeLabelHeight"};

      if ($coords) {
	# edge label with explicit coords
	$coords = $self->parse_coords_spec($node,$coords,$nodes,\%nodehash,$grp);
	#my @c=split ',',$coords;
	if (my @c = $self->eval_coords_spec($node,$parent,$coords)) {
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
	  $NI->{"EdgeLabel_XPOS"}= $c[0];
	  $NI->{"EdgeLabel_YPOS"}= $c[1];
	}
      } else {
	$y_edge_length=
	  ($node_info->{$parent}{ "YPOS"}-
	     $NI->{"YPOS"});
	$x_edge_length=
	  ($node_info->{$parent}{ "XPOS"}-
	     $NI->{"XPOS"});
	$x_edge_delta=(($NI->{ "EdgeLabel_YPOS"}
			  -$NI->{ "YPOS"})*$x_edge_length)/$y_edge_length;
	
	# the reference point for edge label is now
	# X: $NI->{"XPOS"}+$x_edge_delta
	#	Y: $NI->{"EdgeLabel_YPOS"}
	
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
	$NI->{"EdgeLabel_XPOS"}=
				$NI->{"XPOS"}+$x_edge_delta;
      }
    }

    ## Boxes around attributes
    if ($vertical_tree && $self->get_horizStripe || !$vertical_tree && $self->get_vertStripe) {
#      $objectno++;
#      my $stripe = "stripe_$objectno";
      my $stripe_id = $canvas->
	createRectangle(
	  $vertical_tree ?
	    (-200,
	     0+$NI->{"NodeLabel_YPOS"}-$self->get_ymargin,
	     0+$self->{canvasWidth}+200,
	     $NI->{"NodeLabel_YPOS"}+$self->get_ymargin+$lineHeight,
	    ) :
	    (
	     0+$NI->{"XPOS"}-$self->get_nodeWidth,
	     -200,
	     0+$NI->{"XPOS"}+$self->get_nodeWidth,
	     0+$self->{canvasHeight}+200,
	    ),
	   -fill => $currentNode==$node ? $self->get_stripeColor  :
	     $self->realcanvas->cget('-background'),
	   -outline => undef,
	   -tags => ['stripe']
	);
      # $self->store_id_pinfo($stripe_id,$stripe);
      $self->store_obj_pinfo($stripe_id,$node);
      $NI->{"Stripe"}=$stripe_id;
    }
    if ($node_has_box) {
      ## get maximum width stored here by recalculate_positions
#      $objectno++;
#      my $box="textbox_$objectno";
      my @coords = @{$NI->{"TextBoxCoords"}};
      my $bid=$canvas->
	createRectangle(
	  @coords,
	  -tags => ['textbox']
	 );
      # $self->store_id_pinfo($bid,$box);
      eval { #apply_style_opts
	$canvas->itemconfigure(
	$bid,
	$self->node_box_options($node,$fsfile->FS,
				$currentNode,0),
	@{$Opts{TextBox}},
	$self->get_node_style($node,
			      ($node==$currentNode ?
				 "CurrentTextBox" : "TextBox")
			     ));
      }; print STDERR $@ if $@;
      $NI->{"TextBox"}=$bid;
      $self->store_obj_pinfo($bid,$node);
    }
    $edge_has_box=!$vertical_tree &&
      scalar(@$edge_patterns) && $parent &&
	($self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-nodrawbox",\%Opts) ne "yes") ||
	 !$self->get_drawEdgeBoxes &&
	 ($valign_edge=$self->get_style_opt($node,"EdgeLabel","-dodrawbox",\%Opts) eq "yes"));
    $NI->{"EdgeHasBox"}=$edge_has_box;
    if ($edge_has_box) {
#      $objectno++;
#      my $box="edgebox_$objectno";
      my $bid=$canvas->
	createRectangle($NI->{"EdgeLabel_XPOS"}-
			$self->get_xmargin,
			$NI->{"EdgeLabel_YPOS"}
			-$self->get_ymargin,
			$NI->{"EdgeLabel_XPOS"}+
			$self->get_xmargin+$edgeLabelWidth,
			$NI->{"EdgeLabel_YPOS"}
			+$self->get_ymargin
			+scalar(@$edge_patterns)*$lineHeight,
			-tags => ['edgebox']
		       );
      # $self->store_id_pinfo($bid,$box);
      eval { #apply_style_opts
	$canvas->itemconfigure(
	$bid,
	$self->node_box_options($node,
				$fsfile->FS,
				$currentNode,1),
	@{$Opts{EdgeTextBox}},
	$self->get_node_style($node,
			      $node==$currentNode ?
				"CurrentEdgeTextBox" :
				"EdgeTextBox"
			     ));
      }; print STDERR $@ if $@;
      $NI->{"EdgeTextBox"}=$bid;
      $self->store_obj_pinfo($bid,$node);
    }

    undef %nodehash;

    ## Texts of attributes
    my ($msg,$e_x,$n_x,$e_y,$n_y,$empty);
    my ($i,$e_i,$n_i)=(0,0,0);
    my ($pat_class,$pat);
    $e_y=0+$NI->{"EdgeLabel_YPOS"};
    $n_y=0+$NI->{"NodeLabel_YPOS"};
    $e_x=0+$NI->{"EdgeLabel_XPOS"};
    $n_x=0+$NI->{"NodeLabel_XPOS"};
    for (;$i<=$#$patterns;$i++) {
      ($pat_class,$pat)=@{$patterns->[$i]};
      $msg=$self->interpolate_text_field($node,$pat,$grp);
      if ($pat_class eq "edge") {
	if ($parent||$vertical_tree) {
	  $msg =~ s{/}{}g; # should be done in interpolate_text_field; PP: what is it good for?
	  $empty=0;
	  if ($vertical_tree) {
	    $e_x=0+$gen_info->{"EdgeLabel_XPOS[$e_i]"} if $i;
	  } else {
	    if ($skip_empty_nlabels and $NI->{"X[$i]"}==0) {
	      $empty=1;
	    }
	    if ($empty) {
	      $e_y-=$lineHeight;
	    } elsif ($e_i) {
	      $e_y+=$lineHeight;
	    }
	  }
	  $e_i++;
	  $self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$e_x,$e_y,
				!$edge_has_box,
				\%Opts,$grp,'Edge') unless $empty;
	}
      } elsif ($pat_class eq "node") { # node
	$empty=0;
	if ($vertical_tree) {
	  $n_x=$gen_info->{"NodeLabel_XPOS[$n_i]"} if $i;
	} else {
	  if ($skip_empty_nlabels and $NI->{"X[$i]"}==0) {
	    $empty=1;
	  }
	  if ($empty) {
	    $n_y-=$lineHeight;
	  } elsif ($n_i) {
	    $n_y+=$lineHeight;
	  }
	}
	$n_i++;
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$n_x,$n_y,
			      !$node_has_box,
			      \%Opts,$grp,'Node') unless $empty;
      }
    }
    for my $pat (@$label_patterns) {
      $i++;
      $msg=$self->interpolate_text_field($node,$pat,$grp);
      if ($msg=~s/\#{-coords:([^}]*)}//g) {
	$coords = $1;
      }
      $coords = 'n,n' unless defined($coords) and length($coords);
      $coords = $self->parse_coords_spec($node,$coords,$nodes,\%nodehash,$grp);
      if (my @c = $self->eval_coords_spec($node,$parent,$coords)) {
	$self->draw_text_line($fsfile,$node,$i,$msg,$lineHeight,$c[0],$c[1],1,\%Opts,$grp,'Label');
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
		    if (defined $msg) {
		      $msg=~s/\${([^}]+)}/_present_attribute($node,$1)/eg;
		      ($_ => encode($msg));
		    } else {
		      ()
		    }
		  }
		} $self->find_item('withtag','point')
	       });
#=cut

    }
  }
  eval {
    if ($vertical_tree && defined $node_info->{$currentNode}{'Stripe'}) {
      $canvas->itemconfigure("textbg_$currentNode", -fill => undef )
    }
  };
  eval { $canvas->lower('stripe','all') };
  $self->raise_order(qw(line
			point
			textbox
			edgetextbox
			textbg
			text
			plaintext
			));
  if (length $Opts{stackOrder}) {
    $self->raise_order(split /\s*,\s*/,$Opts{stackOrder});
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
  $canvas->configure(-scrollregion =>[0,0, $self->{canvasWidth}||0, $self->{canvasHeight}||0]);
  $canvas->xviewMoveto(0);
  $canvas->yviewMoveto(0);
}




sub draw_text_line {
  my ($self,$fsfile,$node,$i,$msg,
      $lineHeight,$x,$y,$clear,$Opts,$grp,$what)=@_;
  my $node_info = $self->{node_info};
  my $gen_info = $self->{gen_info};
  my $style_info = $self->{style_info};
#  $msg=~s/([\$\#]{[^}]+})/\#\#\#$1\#\#\#/g;
  my $align= $self->get_style_opt($node,$what."[$i]","-textalign",$Opts);
  $align = $self->get_style_opt($node,$what,"-textalign",$Opts) unless defined $align;
  my $textdelta=0;
  my $X =
    ($what eq 'Label') ?
      $self->getTextWidth($self->prepare_text($node,$msg,$grp)) :
      $node_info->{$node}{"X[$i]"};
  if (!defined($align) or $align eq 'left') {
    $textdelta=0;
  } elsif ($align eq 'right') {
    my $lw = $gen_info->{$what."LabelWidth[$i]"};
    $lw = $node_info->{$node}{$what."LabelWidth"} unless defined $lw;
    if (defined $lw) {
      $textdelta= ($lw - $X);
    } else {
      $textdelta= -$X;
    }
  } elsif ($align eq 'center') {
    my $lw = $gen_info->{$what."LabelWidth[$i]"};
    $lw = $node_info->{$node}{$what."LabelWidth"} unless defined $lw;
    if (defined $lw) {
      $textdelta= ($lw - $X)/2;
    } else {
      $textdelta= -$X/2;
    }
  }
  ## Clear background
  my $canvas = $self->realcanvas;

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
  my %inline_opts;
  my $use_fs_colors = $self->get_useFSColors;
  foreach (grep {length} split(m/([#\$]${bblock})/,$msg)) {
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
#      $objectno++;
#      $txt="text_$objectno";
      my $bid=$canvas->
	createText($x+$xskip+$textdelta, $y,
		   -anchor => 'nw',
		   -text => $at_text,
		   ($use_fs_colors ? (-fill => $self->which_text_color($fsfile,$c)) : ()),
		   -font => $self->get_font,
		   -tags => ['text','text_item', "text[$node][$i]" ]
		  );
      # $self->store_id_pinfo($bid,$txt);
      eval { #apply_style_opts
	$canvas->itemconfigure($bid,
		   @{$Opts->{Text}},
		   @{$Opts->{"Text[$c]"}},
		   @{$Opts->{"Text[$c][$i]"}},
		   @{$Opts->{"Text[$c][$i][$j]"}},
		   @{$style_info->{$node}{"Text"}},
		   @{$style_info->{$node}{"Text[$c]"}},
		   @{$style_info->{$node}{"Text[$c][$i]"}},
		   @{$style_info->{$node}{"Text[$c][$i][$j]"}},
		   %inline_opts,
		   (defined($color) ? (-fill => $color) : ())
		  );
      }; print STDERR $@ if $@;
      $xskip+=$self->getTextWidth($at_text);
      $self->store_obj_pinfo($bid,$node);
      $node_info->{$node}{"Text[$c][$i][$j]"}=$bid;
      $gen_info->{"attr:$bid"}=$c;
    } elsif (/^\#${block}$/) {
      unless ($self->get_noColor) {
	my $c=$1;
	if ($c=~m/^(.*)(-.+):(.+)$/) {
	  if (defined($1) and length($1)) {
	    # Depreciated ! Use style pattern!
	    eval {
	      $canvas->
		itemconfigure($node_info->{$node}{$1},$2 => $3);
	    };
	    print STDERR $@ if $@ ne "";
	  } else {
	    $inline_opts{$2}=$3;
	  }
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
#	$objectno++;
#	$txt="text_$objectno";
	my $bid=$canvas->
	  createText($x+$xskip+$textdelta,
		     $y,
		     -text => encode($_),
		     -anchor => 'nw',
		     -font => $self->get_font,
		     -tags => ['plaintext','text_item',"text[$node][$i]"]
		    );
	#$self->store_id_pinfo($bid,$txt);
	eval { #apply_style_opts
	  $canvas->itemconfigure($bid,
				@{$Opts->{Text}},
				@{$style_info->{$node}{Text}},
				%inline_opts,
				(defined($color) ? (-fill => $color) : ())
			       );
	}; print STDERR $@ if $@;
	$xskip+=$self->getTextWidth($_);
      }
    }
  }
  if ($self->get_clearTextBackground and
      $clear) { #  and $X>0
    my @bbox=$canvas->bbox("text[$node][$i]");
    if (@bbox) {
      my $bid=$canvas->
	createRectangle(@bbox,
			#	$x+$textdelta,$y,
			#		      $x+$textdelta+$X+1,
			#		      $y+$lineHeight,
			-fill => $canvas->cget('-background'),
			-outline => undef,
			-tags => ['textbg',"textbg_$node"]
		       );
      eval { #apply_style_opts
	$canvas->itemconfigure($bid,
			       @{$Opts->{TextBg}},
			       @{$Opts->{"TextBg[$i]"}},
			       @{$style_info->{$node}{TextBg}},
			       @{$style_info->{$node}{"TextBg[$i]"}},
			      );
      }; print STDERR $@ if $@;
      $node_info->{$node}{"TextBg[$i]"}=$bid;
      $self->store_obj_pinfo($bid,$node);
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
  return "" unless length $msg;
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

my $code_match = qr/(\<\?(?:[^?]|\?[^>])+\?\>)/;
my $code_match_in = qr/^\<\?((?:[^?]|\?[^>])+)\?\>$/;

sub _compile_code {
  my ($text)=@_;
  $text=~s/\$\${([^}]+)}/ TrEd::TreeView::_present_attribute(\$this,'$1')/g;
  return eval "package TredMacro; sub{ eval { $text } }";
}

sub interpolate_text_field {
  my ($self,$node,$text,$grp_ctxt)=@_;
  return unless defined $text and length $text;
  # make $this, $root, and $grp available for the evaluated expression
  # as in TrEd::Macros
  no strict 'refs';
  my @save = (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'});
  my $root; $root=$node && $node->root;
  (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'})=
    ($node,$root,$grp_ctxt);
  my $cached = $PATTERN_CODE_CACHE{$text};
  unless (defined $cached) {
    $cached = $PATTERN_CODE_CACHE{$text} = [map {
      $_=~$code_match_in ? _compile_code($1) : $_
    } split $code_match, $text]
  }
  $text = join '', map { ref($_) ? $_->() : $_ } @$cached; # maybe we should reset this,root,grp, etc. every time!
  (${'TredMacro::this'},${'TredMacro::root'},${'TredMacro::grp'})=@save; # 
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

