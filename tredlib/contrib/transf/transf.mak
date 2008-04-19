# -*- cperl -*-
#binding-context Transfer
#key-binding-adopt Tectogrammatic

package Transfer;

BEGIN { import TredMacro; }

push @TredMacro::AUTO_CONTEXT_GUESSING, sub {
  if ($grp->{FSFile}->FS->exists->{x_TNT} and $grp->{FSFile}->FS->hide eq 'X_hide') {
    return 'Transfer';
  }
  return;
};


#bind default_tr_attrs to F8 menu Display default attributes
sub default_tr_attrs {
  return unless $grp->{FSFile};
  print "Using standard patterns\n";
    SetDisplayAttrs('${x_TNl}','#{blue}${trlemma}','${x_TNfunc}');
    SetBalloonPattern("TNT: \${x_TNT}\n".
                      "TNfunc: \${x_TNfunc}\n".
                      "TNmg: \${x_TNmg}\n".
		      '<? $node->parent->{x_TNT} eq "OR_node" ?
                          "czlemma: ".$node->parent->{trlemma}."\n".
                          "czafun: ".$node->parent->{afun}."\n".
                          "cztagMD: ".$node->parent->{tagMD_a} :
		      "czafun: ".$${afun}."\ncztagMD: ".$${tagMD_a} ?>');
  return 1;
}

my @colors=qw(blue darkgreen darkred turquoise violet gray purple
           lightblue plum green pink orange2 maroon khaki gold
           firebrick2 cyan3 chartreuse burltywood);

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


# invoked by TrEd to allow custom styling of the tree ($node is the
# root)
sub root_style_hook {
  my ($node,$styles)=@_;

  my $color=-1;
  while ($node) {
    if ($node->{x_TNT} eq 'ID_node') {
      $color=($color+1) % scalar(@colors);
      $node->{x_TNcolor}=$colors[$color];
    }
    $node=$node->following;
  }
  AddStyle($styles,'Line',
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
    AddStyle($styles,'Line',
	      -coords => join('&',"n,n,p,p", map { "n,n,x[ord=$_],y[ord=$_]" } @glo),
	      -fill => $node->{x_TNcolor}.("&$node->{x_TNcolor}"x@glo),
	      -arrow => 'last'.('&last'x@glo),
	      -width => '1'.('&1'x@glo)
	     );
    AddStyle($styles,'Oval',
	      -fill => $node->{x_TNcolor},
	     );
    AddStyle($styles,'Node',
	      -addwidth => 2,
	      -addheight => 2,
	      -shape => 'rectangle',
	      -rellevel => '-0.1', # lower them down a little
	     );
  }
  # styling ID_node children
  if ($node->parent and $node->parent->{x_TNT} eq 'ID_node') {
    AddStyle($styles,'Node',
	      -rellevel => '-0.1', # lower them down a little
	     );
    AddStyle($styles,'Line',
	      -fill => $node->parent->{x_TNcolor},
	      -dash => '_',
	     );
  }
  # styling OR_nodes
  if ($node->{x_TNT} eq 'OR_node') {
    AddStyle($styles,'Oval',
	      -fill => 'orange',
	      -smooth => 0
	     );
    AddStyle($styles,'Node',
	      -addwidth => 2,
	      -addheight => 2,
	      -shape => 'polygon',
	      -polygon => '-6,0,-2,2,0,6,2,2,6,0,2,-2,0,-6,-2,-2',
	      -rellevel => '-0.2', # lower them down a little
	     );
  }
  # styling OR_node children
  if ($node->parent and $node->parent->{x_TNT} eq 'OR_node') {
    AddStyle($styles,'Node',
	      -rellevel => '0', # lower them down a little
	     );
    AddStyle($styles,'Line',
	      -fill => 'orange',
	      -dash => ',',
	     );
  }
  # styling all other nodes
  if (($node->parent and $node->parent->parent and
       $node->parent->{x_TNT} !~ /(OR|ID)_node/) and
      $node->{x_TNT} !~ /(OR|ID)_node/) {
    AddStyle($styles,'Node',
	      -rellevel => '0.8',
	     );
  }

}
