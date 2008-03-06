# -*- cperl -*-
package TrEd::NodeGroups;

=head1 NAME

TrEd::NodeGroups - macros for v visualizing groups of nodes

=head2 SYNOPSIS

package MyMacros;
use strict;
BEGIN{ import TredMacro };

sub after_redraw_hook {
  my @nodes = GetVisibleNodes();
  my $group1 = [ $nodes[0..$#$nodes/2] ];
  my $group2 = [ $nodes[$#$nodes/2..$#$nodes] ];
  my $group3 = [ $nodes[$#$nodes/3..2*$#$nodes/3] ];
  TrEd::NodeGroups::draw_groups(
    $grp,
    [$group1,$group2,$group3],
    { colors => [qw(red orange pink)] }
  );
}

=cut


sub draw_groups {
  my ($win,$groups,$opts)=@_;
  for (my $i=0; $i<@$groups; $i++) {
    draw_group($win, $i+1, $groups->[$i], $opts);
  }
}


sub draw_group {
  my ($win,$group_no,$nodes,$opts)=@_;
#  $Redraw = 'none';
  $opts||={};
  my $tv=$win->treeView;
  my $c=$tv->realcanvas;
  $c->delete('group'.$group_no);

  my $color   = $opts->{color}   || ($opts->{colors}   ? $opts->{colors}[$group_no-1]   : $colors[$group_no-1]   );
  my $stipple = $opts->{stipple} || ($opts->{stipples} ? $opts->{stipples}[$group_no-1] : stipple($c,$group_no-1));
  my $xshift= defined $opts->{x_shift} ? $opts->{x_shift} : 2;
  my $raise= defined $opts->{y_shift} ? $opts->{y_shift} : 20;
  my $group_width= defined $opts->{group_line_width} ? $opts->{group_line_width} : 30;

  my @sel =
    map {
      my @c =  $c->coords($_);
      [$_,($c[0]+$c[2])/2,($c[1]+$c[3])/2,  @c] 
    } grep { defined }
    map { $tv->get_node_pinfo($_,'Oval') } @$nodes;

  my $scale_factor=$tv->scale_factor();
#   my $oval_width = 2*$scale_factor;
#   for my $sel (@sel) {
#     $c->create($c->type($sel->[0]),
# 	       $sel->[3]-$oval_width*$group_no,
# 	       $sel->[4]-$oval_width*$group_no,
# 	       $sel->[5]+$oval_width*$group_no,
# 	       $sel->[6]+$oval_width*$group_no,
# 	       -outline => $color,
# 	       -width => $oval_width,
# 	       -tags => ['group','scale_width'],
# 	      );
#   }
#  return unless @sel>1;
  my ($x,$y)=(0,0);
  for my $i (0..$#sel) {
    my (undef,$cx,$cy) = @{$sel[$i]};
    $x += $cx/@sel;
    $y += $cy/@sel;
  }
  @sel = sort { (int($b->[2]/10)<=>int($a->[2]/10)) } @sel;
  require Graph::Kruskal;
  Graph::Kruskal::define_vortices(1..@sel); # ehm, the author meant 'vertices'
  my @nodes = map { $tv->get_obj_pinfo($_->[0]) } @sel;
  my %idx = map { $nodes[$_]=>$_ } 0..$#sel;

  my @mst;
  if (@sel==1) {
    @mst={from=>1,to=>1};
  } else {
  my %component_root;
  my %components;
  for my $n (@nodes) {
    my $node = $n;
    my $top;
    while ($node) { # could be while(1), but this is safer
      if (exists($component_root{$node})) {
	$top = $component_root{$node};
	last;
      }
      if (!defined$idx{$node->parent}) {
	$top = $node;
	$component_root{$node}=$top;
	push @{$components{ $idx{$top} }},$idx{$node};
	last;
      }
      $node=$node->parent;
    }
    my $nn=$n;
    while ($nn!=$node) {
      $component_root{$nn} = $top;
      push @{$components{$idx{$top} }},$idx{$nn};
      $nn=$nn->parent;
    }
  }
  my @graph_edges;
  my @components = values %components;
  for my $i (0..$#components) {
    my $c1=$components[$i];
    # first add best connections between components
    for my $j (($i+1)..$#components) {
      my $c2=$components[$j];
      my $best;
      for my $ni (@$c1) {
	for my $nj (@$c2) {
	  my $dist = abs($sel[$ni]->[1]-$sel[$nj]->[1])+
	             abs($sel[$ni]->[2]-$sel[$nj]->[2]);
	  if (!defined($best) or $best->[2]>$dist) {
	    $best=[$ni+1,$nj+1,$dist];
	  }
	}
      }
      if (!defined $best) {
	warn "No best between components $i, $j\n";
      }
      push @graph_edges,$best;
    }
    # then add all child-to-parent edges in the component
    for my $ni (@$c1) {
      my $n = $nodes[$ni];
      my $p = $n->parent;
      my $pi = $idx{$p};
      if ($p and defined $pi) {
	push @graph_edges,[$ni+1,$pi+1,
			   sqrt(abs($sel[$ni]->[1]-$sel[$pi]->[1])**2+
				abs($sel[$ni]->[2]-$sel[$pi]->[2])**2)];
      }
    }
  }
  Graph::Kruskal::define_edges(
    map { @$_ } @graph_edges
  );
  @mst = Graph::Kruskal::kruskal();
}
  for my $mst_edge (@mst) {
    my $from = $sel[$mst_edge->{from}-1];
    my $to = $sel[$mst_edge->{to}-1];
    ($from,$to)=sort {
      ($a->[1]<=>$b->[1]) || ($a->[2]<=>$b->[2])
    } $from,$to;
    my $from_node = $tv->get_obj_pinfo($from->[0]);
    my $to_node = $tv->get_obj_pinfo($to->[0]);
    my @coords = 
      (($from_node->parent == $to_node) or 
	 ($to_node->parent == $from_node)) ?
      (
	$from->[1],
	$from->[2],
	$to->[1],
	$to->[2],
       ) :
      (
      $from->[1],
      $from->[2],
      $from->[1],
      $from->[2]-$raise*$scale_factor,
      (
	($from->[2]<$to->[2]) ? (
	  $to->[1],
	  $from->[2]-$raise*$scale_factor,
	 ): (
	   $from->[1],
	   $to->[2]-$raise*$scale_factor,
	  )
	),
       $to->[1],
       $to->[2]-$raise*$scale_factor,

      $to->[1],
      $to->[2],
     );
    $c->createLine(
      (map { $_-$xshift*$scale_factor*$group_no } @coords),
      -capstyle=>'round',
      -joinstyle=>'round',
      -width => $group_width*$scale_factor,
      -fill => $color,
      -stipple=> $stipple,
      -tags => ['scale_width','group_line','group_no_'.$group_no],
     );
  }
  eval { $c->raise('group_line','stripe'); };
  eval { $c->lower('group_line','line'); };
  eval { $c->raise('group_line','textbg'); };
}

# define stipples
{
  my %stipples = (
    dash1 => [8,8,pack("b8"x8,qw{
	1.......
	.1......
	..1.....
	...1....
	....1...
	.....1..
	......1.
	.......1
    })],
    dash2=> [8,8,pack("b8"x8,qw{
	 .......1
	 ......1.
	 .....1..
	 ....1...
	 ...1....
	 ..1.....
	 .1......
	 1.......
    })],
    dash3 => [8,8,pack("b8"x8,qw{
	....1...
	...1....
	..1.....
	.1......
	1.......
	.......1
	......1.
	.....1..
    })],
    dash4 => [8,8,pack("b8"x8,qw{
         ...1....
	 ....1...
	 .....1..
	 ......1.
	 .......1
	 1.......
	 .1......
	 ..1.....
    })],
    dash5 => [8,8,pack("b8"x8,qw{
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
    })],
    dash6 => [8,8,pack("b8"x8,qw{
	........
	........
	........
	11111111
	........
	........
	........
	11111111
    })],
   );
  my @stipples = sort keys %stipples;
  my $stipples_defined = 0;
  sub stipple {
    my $c = shift;
    my $no  =shift;
    unless ($TrEd::Groups::stipples_defined) {
      $TrEd::Groups::stipples_defined=1;
      for (keys %stipples) {
	unless (defined($c->toplevel->GetBitmap($_))) {
	  $c->toplevel->DefineBitmap($_ => @{$stipples{$_}})
	}
      }
    }
    return $stipples[$no % @stipples] if $TrEd::Groups::stipples_defined;
  }
}

1;

