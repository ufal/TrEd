# -*- cperl -*-

#ifndef Show_Neighboring_Trees
#define Show_Neighboring_Trees
{
package Show_Neighboring_Trees;
use strict;
BEGIN {
  import TredMacro;
}

my $cfg = QuickPML(
  cfg=> [
    'structure',
    context_before => 'nonNegativeInteger',
    context_after => 'nonNegativeInteger',
    follow_current_node => ['choice' => 'yes', 'no'],
    alignment => ['choice' => 'horizontal', 'vertical'],
   ],
  Fslib::Struct->new({
    context_before=>5,
    context_after=>5,
    follow_current_node => 'yes',
    alignment=>'horizontal',
  }));

sub edit_configuration {
  ToplevelFrame()->TrEdNodeEditDlg({
    title => 'Edit Parameters',
    type => $cfg->schema->get_root_type,
    object => $cfg->get_root,
    search_field => 0,
    focus => 'context_before',
    no_sort=>1,
  });
  ChangingFile(0);
}
sub configure {
  my ($before,$after,$alignment)=@_;
  for my $c (get_config()) {
    $c->{context_before}=int($before);
    $c->{context_after}=int($after);
    $c->{alignment}=$alignment if $alignment;
  }
}
sub get_config {
  return $cfg->get_root;
}


my %segment;
my $vertical;
DeclareMinorMode 'Show_Neighboring_Trees' => {
  abbrev => 'neigh_trees',
  configure => \&edit_configuration,
  post_hooks => {
    current_node_change_hook => sub {
      my ($node)=@_;
      my $config = get_config();
      return unless $config->{follow_current_node} eq 'yes';
      my $r=$node->root;
      return if $r==$root;	# same tree
      my @trees = GetTrees();
      for my $i (0..$#trees) {
	if ($trees[$i]==$r) {

	  # store the node's current position in the window
	  my $c = $grp->treeView->canvas;
	  my ($x,$y )=
	    map $grp->treeView->get_node_pinfo($node, $_),
	      qw(XPOS YPOS);	# coordinates of the selected node
	  my ($xv,$yv)=( 
	    $c->xviewCoord($x),	# translate to window position
	    $c->yviewCoord($y)
	   );

	  GotoTree($i+1);
	  $this = $node;
	  Redraw();

	  # adjust view so that the node appears
	  # on the exact same place
	  ($x,$y)= 
	    map $grp->treeView->get_node_pinfo($node, $_),
	      qw(XPOS YPOS);
	  $c->xviewCoord($x,$xv); # restore window position
	  $c->yviewCoord($y,$yv);
	  return;
	}
      }
    },
    node_style_hook => sub {
      my ($node,$styles)=@_;
      AddStyle($styles,'Node',-segment => $segment{$node}.'/0') if $vertical;
    },
    get_nodelist_hook => sub {
      my ($fsfile,$no,$prevcurrent,$show_hidden)=@_;
      %segment=();
      my $config = get_config();
      my ($context_before,$context_after) =
	map { $_->{context_before}, $_->{context_after} } $config;
      $vertical = ($config->{alignment}||'horizontal') eq 'vertical' ? 1 : 0;
      my $from=max(0,$no-$context_before);
      my $to=min($no+$context_after,$fsfile->lastTreeNo);
      my $sub = UNIVERSAL::can(CurrentContext(),'get_nodelist_hook')
	|| UNIVERSAL::can('TredMacro','get_value_line_hook');
      my $attr=FS->order();
      my ($nodes,$current);
      my $l = $_[-1];
      if (ref($l) eq 'ARRAY' and @$l==2) {
	($nodes,$current)=@$l;
      } else {
	$nodes=[];
	undef $l;
      }
      for my $i (reverse ($from..$no-1),
		 ($l ? () : $no),
		 $no+1..$to) {
	my @unsorted;
	my ($res,$cur);
	if ($sub) {
	  ($res,$cur)=@{$sub->($fsfile,$i,$prevcurrent,$show_hidden) || []};
	}
	if (!defined $res) {
	  ($res,$cur)=$fsfile->nodes($i,$prevcurrent,$show_hidden);
	}
	$current=$cur if ($i==$no);
	if ($i<$no) {
	  unshift @$nodes, @$res;
	} else {
	  push @$nodes,@$res;
	}
	$segment{$_}=$i-$from for @$res;
      }
      $current ||= $fsfile->tree($no);
      $_[-1] = [$nodes,$current];
    }
  },
};

}
1;

#endif Show_Neighboring_Trees
