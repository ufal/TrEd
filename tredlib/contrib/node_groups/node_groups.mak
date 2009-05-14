# -*- cperl -*-
package TrEd::NodeGroups;

=head1 NAME

TrEd::NodeGroups - macros for v visualizing groups of nodes

=head2 SYNOPSIS

  package MyMacros;
  use strict;
  BEGIN{ import TredMacro };

  sub after_redraw_hook {
    my @nodes = GetDisplayedNodes();
    my $group1 = [ $nodes[0..$#$nodes/2] ];
    my $group2 = [ $nodes[$#$nodes/2..$#$nodes] ];
    my $group3 = [ $nodes[$#$nodes/3..2*$#$nodes/3] ];
    TrEd::NodeGroups::draw_groups(
      $grp,
      [$group1,$group2,$group3],
      { colors => [qw(red orange pink)],
        # stipples => [qw(dense1 dense2 ... dense6)],
        # stipples => [qw(dash1 dash2 ... dash6)], # default
        # group_line_width => 30, # default
      }
    );
  }

=cut


sub draw_groups {
  my ($win,$groups,$opts)=@_;
  for (my $i=0; $i<@$groups; $i++) {
    draw_group($win, $i+1, $groups->[$i], $opts);
  }
}

my @colors = qw(lightblue yellow lightgreen orange cyan lightgray pink);
sub draw_group {
  my ($win,$group_no,$nodes,$opts)=@_;
#  $Redraw = 'none';
  $opts||={};
  my $tv=$win->treeView;
  my $c=$tv->realcanvas;
  $c->delete('group'.$group_no);

  my $color   = $opts->{color}   || ($opts->{colors}   ? $opts->{colors}[$group_no-1]   : $colors[$group_no-1]   );
  my $stipples = $opts->{stipples};
  my $stipple = $opts->{stipple} || ($stipples ? $stipples->[($group_no-1)%@$stipples] : stipple($c,$group_no-1));
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
  eval { $c->raise('point','group_line'); };
}

# define stipples
{
  my @bits = (
    [qw{
	1.......
	.1......
	..1.....
	...1....
	....1...
	.....1..
	......1.
	.......1
    }],
    [qw{
	 .......1
	 ......1.
	 .....1..
	 ....1...
	 ...1....
	 ..1.....
	 .1......
	 1.......
    }],
    [qw{
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
	...1...1
    }],
    [qw{
	........
	........
	........
	11111111
	........
	........
	........
	11111111
    }],
   );
  sub _bitmap {
    return pack("b8"x8,@{$_[0]});
  }
  sub _rot_bitmap {
    my ($bits,$amount) = @_;
    return _bitmap([ map { substr($_,$amount).substr($_,0,$amount) } @$bits ]);
  }
  sub _vrot_bitmap {
    my ($bits,$amount) = @_;
    return _bitmap([@$bits[$amount..$#$bits],@$bits[0..$amount-1]]);
  }
  sub _or_bitmap {
    my ($bitmap1,$bitmap2) = @_;
    return $bitmap1|$bitmap2;
  }

  my %normal_stipples = (
    dash1 => _bitmap($bits[0]),
    dash2 => _bitmap($bits[1]),
    dash3 => _rot_bitmap($bits[1],4),
    dash4 => _rot_bitmap($bits[0],4),
    dash5 => _bitmap($bits[2]),
    dash6 => _bitmap($bits[3]),
  );
  my %dense_stipples = (
    dense1 => _or_bitmap(_rot_bitmap($bits[0],1), _rot_bitmap($bits[0],5)),
    dense2 => _or_bitmap(_rot_bitmap($bits[1],1),_rot_bitmap($bits[1],5)),
    dense3 => _or_bitmap(_rot_bitmap($bits[0],3),_rot_bitmap($bits[0],7)),
    dense4 => _or_bitmap(_rot_bitmap($bits[1],3),_rot_bitmap($bits[1],7)),
    dense5 => _or_bitmap(_rot_bitmap($bits[2],1),_rot_bitmap($bits[2],3)),
    dense6 => _or_bitmap(_vrot_bitmap($bits[3],1),_vrot_bitmap($bits[3],3)),
  );
  my %stipples = (%normal_stipples,%dense_stipples);
  my @normal_stipples = sort(keys(%normal_stipples));
  my @dense_stipples = sort(keys(%dense_stipples));
  my @stipples = @normal_stipples,@dense_stipples;
  sub define_stipples {
    my $c = shift;
    for (keys %stipples) {
      unless (defined($c->toplevel->GetBitmap($_))) {
	$c->toplevel->DefineBitmap($_ => 8,8,$stipples{$_})
      }
    }
    return 1;
  }
  sub stipple {
    my $c = shift;
    my $no  =shift;
    return $stipples[$no % @stipples] if define_stipples();
  }
  sub dense_stipples {
    my $grp=shift;
    define_stipples($grp->treeView->realcanvas);
    return \@dense_stipples;
  }
  sub normal_stipples {
    my $grp=shift;
    define_stipples($grp->treeView->realcanvas);
    return \@normal_stipples;
  }
}

1;

