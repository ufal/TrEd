# -*- cperl -*-

#binding-context Draw
package Draw; # simple drawing package
BEGIN{ import TredMacro; }

#bind F11 to node_release_hook menu "Node Release"
sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target;
  if ($mod eq 'Shift') {
    print STDERR "Shift\n";
    if ($node->{Coords} eq "") {
      $node->{Coords}='n,n,p,p';
    }
    my $t=$target->{ord};
    $node->{Coords}.="\&n,n,n+([ord=$t]-n)/2+(abs(xn-x[ord=$t])>abs(yn-y[ord=$t])?0:((yn>y[ord=$t]?1:-1)*40)),n+([ord=$t]-n)/2+(abs(yn-y[ord=$t])>abs(xn-x[ord=$t]) ? 0 : ((xn>x[ord=$t]?1:-1)*40)),[ord=$t],[ord=$t]";
    $node->{Arrow}.="\&last";
    $node->{Smooth}.="\&1";
    TredMacro::Redraw_FSFile_Tree();
    $FileNotSaved=1;
  }
}

sub root_style_hook {
  my ($node,$styles)=@_;
  AddStyle($styles,'NodeLabel', -valign => $node->{NodeVAlign});
}

sub node_style_hook {
  my ($node,$styles)=@_;
  AddStyle($styles,'NodeLabel', 
	    -halign => $node->{NodeHAlign},
	    -yadj => $node->{NodeY},
	    -xadj => $node->{NodeX},
	    -drawbox => $node->{NodeFrame},
	    -nodrawbox => $node->{NoNodeFrame},
	    -addbeforeskip => $node->{NodeSkipBefore},
	    -addafterskip => $node->{NodeSkipAfter},
	    -extrabeforeskip => $node->{ExtraSkip}
	   );
  AddStyle($styles,'EdgeLabel',
	    -halign => $node->{EdgeHAlign},
	    -valign => $node->{EdgeVAlign},
	    -yadj => $node->{EdgeY},
	    -xadj => $node->{EdgeX},
	    -drawbox => $node->{EdgeFrame},
	    -nodrawbox => $node->{NoEdgeFrame}
	   );
  AddStyle($styles,'Line',
	    -dash => $node->{Dash},
	    -arrow => $node->{Arrow},
	    -width => $node->{Width},
	    -coords => $node->{Coords} || 'n,n,p,p',
	    -smooth => $node->{Smooth}
	   );
  AddStyle($styles,'Node',
	    -level => $node->{Level}
	   );
}
