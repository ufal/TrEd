# -*- cperl -*-
#binding-context Transf
#key-binding-adopt Tectogrammatic

package Transf;
use base qw(Tectogrammatic);
import Tectogrammatic;

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  print "Using standard patterns\n";
    SetDisplayAttrs('${x_TNl}');
    SetBalloonPattern("\${trlemma}\n\${x_TNT}\n\${x_TNr}");
  return 1;
}

$colors=qw(blue darkgreen darkred turquoise violet purple plum pink
           orange2 maroon khaki gold firebrick2 cyan3 chartreuse
           burltywood);
$color=-1;

sub add_style {
  my $styles=shift;
  my $style=shift;
  if (exists($styles->{$style})) {
    push @{$styles->{$style}},@_
  } else {
    $styles->{$style}=[];
  }
}

sub node_style_hook {
  my ($node,$styles)=@_;

  if ($node->{x_TNT} eq 'ID_node') {
    $color=($color+1)%@colors;
    $node->{x_TNcolor}=@colors[$color];
    my @glo=split(',',$node->{x_TNglo});
    add_style($styles,'Line',
	      -coords => join('&',"n,n,p,p", map { "n,n,[ord=$_],[ord=$_]" } @glo),
	      -fill => $node->{x_TNcolor}.("&$node->{x_TNcolor}"x@glo),
	      -width => '1'.('&1'x@glo)
	     );
    add_style($styles,'Oval',
	      -fill => $node->{x_TNcolor}
	     );
    add_style($styles,'Node',
	      -addwidth => 4,
	      -addheight => 4
	     );
  }
  if ($node->parent and $node->parent->{x_TNT} eq 'OR_node') {
    add_style($styles,'Line',
	      -fill => 'orange',
	      -dash => '.'
	     );
    add_style($styles,'Oval',
	      -fill => 'orange'
	     );
    add_style($styles,'Node',
	      -addwidth => 4,
	      -addheight => 4
	     );
  }
  if ($node->parent and $node->parent->{x_TNT} eq 'ID_node') {
    add_style($styles,'Line',
	      -fill => $node->parent->{x_TNTcolor}
	     );
  }
  if ($node->parent and $node->parent->{x_TNT} !~ /^(OR|ID)_node$/) {
    add_style($styles,'Node',
	      -rellevel => '1',
	     );
  }

}
