# -*- cperl -*-
#binding-context Transfer
#key-binding-adopt Tectogrammatic

package Transfer;
use base qw(TredMacro);
import TredMacro;

#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  print "Using standard patterns\n";
    SetDisplayAttrs('${x_TNl}','#{blue}${trlemma}','${x_TNfunc}');
    SetBalloonPattern("TNT: \${x_TNT}\n".
                      "TNmg: \${x_TNmg}\n".
		      '<? $node->parent->{x_TNT} eq "OR_node" ?
                          "czlemma: ".$node->parent->{trlemma}."\n".
                          "TNfunc: ".$node->{x_TNfunc}."\n".
                          "TNmg: ".$node->{x_TNmg}."\n".
                          "afun: ".$node->parent->{afun}."\n".
                          "tagMD: ".$node->parent->{tagMD_a} :
		      $${afun}."\n".$${tagMD_a} ?>');
  return 1;
}

@colors=qw(blue darkgreen darkred turquoise violet gray purple lightblue plum green pink
           orange2 maroon khaki gold firebrick2 cyan3 chartreuse
           burltywood);

sub switch_context_hook {
  my ($prevcontext)=@_;
  print STDERR "switch_context_hook: $prevcontext\n";
  default_tr_attrs() if $prevcontext eq 'TredMacro';
  $FileNotSaved=0;
#  foreach ($grp->{FSFile}->trees()) {
#    TFA->ProjectivizeSubTree($_);
#  }
#  Redraw();
  return 1;
}

# append given styles to the object
sub add_style {
  my $styles=shift;
  my $obj=shift;
  if (exists($styles->{$obj})) {
    push @{$styles->{$obj}},@_
  } else {
    $styles->{$obj}=[@_];
  }
}

# invoked by TrEd to allow custom styling of the tree ($node is the
# root)
sub root_style_hook {
  my ($node)=@_;

  my $color=-1;
  while ($node) {
    if ($node->{x_TNT} eq 'ID_node') {
      $color=($color+1) % scalar(@colors);
      $node->{x_TNcolor}=$colors[$color];
    }
    $node=$node->following;
  }
  add_style($styles,'Line',
	    -fill => 'black',
	    -width => '1'
	   );
}

# invoked by TrEd to allow custom styling of a specific node
# $styles contains default styles and styles assigned by
# styling patterns in the attribute selection of current FSFile.
sub node_style_hook {
  my ($node,$styles)=@_;

  # styling ID_nodes
  if ($node->{x_TNT} eq 'ID_node') {
    my @glo=split(',',$node->{x_TNglo});
    add_style($styles,'Line',
	      -coords => join('&',"n,n,p,p", map { "n,n,[ord=$_],[ord=$_]" } @glo),
	      -fill => $node->{x_TNcolor}.("&$node->{x_TNcolor}"x@glo),
	      -arrow => 'last'.('&last'x@glo),
	      -width => '1'.('&1'x@glo)
	     );
    add_style($styles,'Oval',
	      -fill => $node->{x_TNcolor},
	     );
    add_style($styles,'Node',
	      -addwidth => 2,
	      -addheight => 2,
	      -shape => 'rectangle',
	      -rellevel => '-0.1', # lower them down a little
	     );
  }
  # styling ID_node children
  if ($node->parent and $node->parent->{x_TNT} eq 'ID_node') {
    add_style($styles,'Node',
	      -rellevel => '-0.1', # lower them down a little
	     );
    add_style($styles,'Line',
	      -fill => $node->parent->{x_TNcolor},
	      -dash => '-',
	     );
  }
  # styling OR_nodes
  if ($node->{x_TNT} eq 'OR_node') {
    add_style($styles,'Oval',
	      -fill => 'orange',
	      -smooth => 0
	     );
    add_style($styles,'Node',
	      -addwidth => 2,
	      -addheight => 2,
	      -shape => 'polygon',
	      -polygon => '-6,0,-2,2,0,6,2,2,6,0,2,-2,0,-6,-2,-2',
	      -rellevel => '-0.2', # lower them down a little
	     );
  }
  # styling OR_node children
  if ($node->parent and $node->parent->{x_TNT} eq 'OR_node') {
    add_style($styles,'Node',
	      -rellevel => '0', # lower them down a little
	     );
    add_style($styles,'Line',
	      -fill => 'orange',
	      -dash => '.',
	     );
  }
  # styling all other nodes
  if (($node->parent and $node->parent->parent and
       $node->parent->{x_TNT} !~ /(OR|ID)_node/) and
      $node->{x_TNT} !~ /(OR|ID)_node/) {
    add_style($styles,'Node',
	      -rellevel => '0.8',
	     );
  }

}
