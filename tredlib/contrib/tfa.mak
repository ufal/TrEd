# -*- cperl -*-
package TFA; # package for the annotation of topic-focus articulation
use base qw(Tectogrammatic);
import Tectogrammatic;


#bind ShiftLeft to Ctrl+Left menu posun uzel doleva
#bind ShiftRight to Ctrl+Right menu posun uzel doprava
#bind tfa_focus to F menu tfa = focus
#bind tfa_topic to T menu tfa = topic
#bind tfa_C to C menu tfa = contrast
#bind tfa_NA to A menu tfa = NA
#bind ProjectivizeSubTree to P menu Projectivize subtree
#bind ShiftSTLeft to Alt+Left menu Shift subtree to the left
#bind ShiftSTRight to Alt+Right menu Shift subtree to the right

sub switch_context_hook {

  SetDisplayAttrs('${trlemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?>',
		  '<? Parent($node) ? "#{custom4}\${tfa}#{default}_" : "" ?>'.
		  '${func}<? "_#{custom2}\${reltype}" if $${reltype} =~ /CO|PA/ ?>'.
		  '<? ".#{custom3}\${gram}" if $${gram} ne "???" and $${gram} ne ""?>'
		 );
  SetBalloonPattern('<?"fw:\t\${fw}\n" if $${fw} ne "" ?>form:'."\t".'${form}'."\n".
		    "afun:\t\${afun}\ntag:\t\${tag}");
  $FileNotSaved=0;
  return "1";
}

sub enable_attr_hook {
  my ($atr,$type)=@_;
  if ($atr!~/^(?:tfa|err1)$/) {
    return "stop";
  }
}

sub tfa_C {
  $sPar1 = 'C';
  TFAAssign();
}

sub tfa_NA {
  $sPar1 = 'NA';
  TFAAssign();
}

sub ProjectivizeSubTree {
# projectivizes the subtree of a given node (within the whole tree)

  my $top=ref($_[0]) ? $_[0] : $this; # $top contains the reference to the node whose subtree is to be projectivized

  my @subtree=ContinueProjectivizing($top); # the ordered array of the projectivized subtree, or undef
  return undef unless @subtree;

  my @all;

  my $node=$root;
  while ($node) {
    push @all, $node;      # @all is filled with the nodes of the whole tree
    if ($node eq $top) {   # except for the nodes depending on the given node
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);   # the array @all is ordered according to the appropriate ordering attribute
  splice @all,Index(\@all,$top),1, @subtree;   # the projectivized subtree is spliced at the right place
  NormalizeOrds(\@all);  # the ordering attributes are modified accordingly

}

sub Projectivize {
# returns an ordered array with the nodes of the projectivized subtree of a given node

  my ($top,$onlyvisible) = @_;  # the reference to the node whose subtree is to be projectivized
                                # whether only non-hidden nodes are to be put in the array
  return undef unless ref($top);

  my @subtree;
  my @sons_left;
  my @sons_right;
  my $i = 0;
  my $ord=$grp->{FSFile}->FS->order;

  push @subtree, [$top,1] unless ($onlyvisible and IsHidden($top));
                           # an ordered array of the projectivized subtree is being created
                           # it contains pairs consisting of a reference to a node
                           # and an indicator saying whether its sons have already been processed

  while ($i<=$#subtree) {  # the subtree is being traversed and projectivized at the same time
                           # the array @subtree grows only to the right of the current index
    if ($subtree[$i]->[1] == 1) { # this node's sons have not been processed yet
        undef(@sons_left);
    	undef(@sons_right);
	$node=$subtree[$i]->[0]->firstson;
	  while ($node) {  # the sons are being traversed and
                           # divided into those on the left and those on the right from the given node
	    next if ($onlyvisible and IsHidden($node));
	    if ($node->{$ord} < $subtree[$i]->[0]->{$ord}) {
	      push @sons_left, [$node,1];
	    }
	    else {
	      push @sons_right, [$node,1];
	    }
	  }
	continue {
	  $node=$node->rbrother;
	}
        $subtree[$i]->[1]=0;  # the processed noded is marked as such
	# the left and right sons are spliced at appropriate places in the array
        splice @subtree,$i+1,0,(sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_right);
        splice @subtree,$i,0,(sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_left);
      }
      else {
	$i++;  # increase the current index by one if the sons of the current node have already been processed
      }
  }

  return map {$_->[0]} @subtree;  # an ordered array containing only the references
                                  # to the nodes of the projectivized subtree is returned
}

sub Ask ($$) {
  my ($title, $message) = @_;

  my $d = ToplevelFrame()->DialogBox(-title => $title,
				       -buttons => ["Ano", "Ne"]
				      );
  $d->add(Label, -text => $message, -font => StandardTredFont(), -wraplength => 200)->pack;
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  return $d->Show;
}

sub ContinueProjectivizing {
# checks whether the current visible subtree or the whole tree
# (if no parameter is passed) is projective
# returns the whole projectivized subtree (including the hidden nodes)
# if the user wishes to continue, undef otherwise

  my $top=ref($_[0]) ? $_[0] : $root;
  # $top contains the reference to the node whose subtree is to be checked for projectivity

  my @ProjectivizedSubTree=Projectivize($top,not(IsHidden($top)));  # projectivized subtree
  my @SubTree = IsHidden($top) ? SortByOrd([GetNodes($top)]) : SortByOrd([GetVisibleNodes($top)]); # subtree ordered according to the ordering attribute
  my ($proj, $sub) = ($#ProjectivizedSubTree, $#SubTree);
  my $differ = 0;  # suppose they do not differ

  if ($proj != $sub) {  # compares the actual subtree with the projectivized one
    $differ=1  ; # they differ
  }
  else {
    for (my $i=0; $i<=$proj; $i++) {
      if ($ProjectivizedSubTree[$i] != $SubTree[$i]) {
	$differ=1;  # they differ
	last;
      }
    }
  }

  if ($differ) { # they are not the same !!!
    if (Ask("Varování", "Podstrom není projektivní. Chcete pokraèovat?") eq "Ano") {
      return Projectivize($top);  # continue, return the whole projectivized subtree
    } else {
      return;  # do not continue
    }

  } else {

    return Projectivize($top);  # continue by default if the subtree has already been projective
                                # return the whole projectivized subtree
  }
}


sub ShiftSTLeft {
# moves the (projectivized) subtree of a given node one node left,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeLeft($this);
  } else {
    ShiftSubTreeLeftSkipHidden($this);
  }
}


sub ShiftSTRight {
# moves the (projectivized) subtree of a given node one node right,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeRight($this);
  } else {
    ShiftSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeLeft {
# moves the (projectivized) subtree of a given node one node left (with respect to all nodes)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return undef unless my @subtree=ContinueProjectivizing($top);

  my @all;

  my $node=$root;  # put all nodes of the whole tree except the nodes depending on the given node into @all
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);  # sort them according to the ordering attribute

  my $i=Index(\@all,$top);  # locate the given node in the array @all
  if ($i>1) {  # check if there is place where to move (the root is always number zero)
    splice @all,$i,1;  # cut out the given node
    splice @all,$i-1,0, @subtree;  # splice the projectivized subtree at the right (ie left ;-) place
  }
  else {
    splice @all,$i,1, @subtree;  # if there is no room where to move, just splice the proj. subtree
                                 # instead of the given node - thus the subtree gets projectivized
  }

  NormalizeOrds(\@all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeRight {
# moves the (projectivized) subtree of a given node one node right (with respect to all nodes)
# see ShiftSubTreeLeft

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=ContinueProjectivizing($top);

  my @all;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $i=Index(\@all,$top);
  if ($i<$#all) {
    splice @all,$i,1;
    splice @all,$i+1,0, @subtree;
  }
  else {
    splice @all,$i,1, @subtree;
  }
  NormalizeOrds(\@all);

}


sub ShiftSubTreeLeftSkipHidden {
# moves the (projectivized) subtree of a given node one node left (with respect to non-hidden nodes only)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return undef unless my @subtree=ContinueProjectivizing($top);  # the projectivized subtree

  my @all;    # all nodes except the nodes depending on the given node
  my @allvis; # all visible (ie non-hidden) nodes except the nodes depending on the given node

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $node=$root;
  while ($node) {
    push @allvis, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
      $node=$node->following_visible($grp->{FSFile}->FS) if IsHidden($node);
    }
    else {
      $node=$node->following_visible($grp->{FSFile}->FS);
    }
  }
  SortByOrd(\@allvis);

  my $i=Index(\@allvis,$top);  # locate the given node within the array @allvis
  if ($i>1) {  # if there is room where to move
    splice @all,Index(\@all,$top),1;  # cut the given node
    splice @all,Index(\@all,$allvis[$i-1]),0, @subtree;  # locate the first visible node to the left
                                                    # and splice the projectivized subtree accordingly
  }
  else {  # nowhere to move, the subtree of the given node gets projectivized
    splice @all,Index(\@all,$top),1, @subtree;
  }

  NormalizeOrds(\@all);

}


sub ShiftSubTreeRightSkipHidden {
# moves the (projectivized) subtree of a given node one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeLeftSkipHidden

  my $top=ref($_[0]) ? $_[0] : $this;

  return undef unless my @subtree=ContinueProjectivizing($top);

  my @all;
  my @allvis;

  my $node=$root;
  while ($node) {
    push @all, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
    }
    else {
      $node=$node->following;
    }
  }
  SortByOrd(\@all);

  my $node=$root;
  while ($node) {
    push @allvis, $node;
    if ($node eq $top) {
      $node=$node->following_right_or_up;
      $node=$node->following_visible($grp->{FSFile}->FS) if IsHidden($node);
    }
    else {
      $node=$node->following_visible($grp->{FSFile}->FS);
    }
  }
  SortByOrd(\@allvis);

  my $i=Index(\@allvis,$top);
  if ($i<$#allvis) {
    splice @all,Index(\@all,$top),1;
    splice @all,Index(\@all,$allvis[$i+1])+1,0, @subtree;
  }
  else {
    splice @all,Index(\@all,$top),1, @subtree;
  }

  NormalizeOrds(\@all);

}



#  sub ShiftSubTreeLeft {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;
#    return 0 if ($node->{$ord} < $min);
#    Projectivize($node);
#    my @all=GetNodes();
#    SortByOrd(\@all);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)),0);
#    $all[$x--]->{$ord}=$y;
#    for (my $i=$x;$i<=$y;$i++) { $all[$i]->{$ord}--; }
#    RepasteNode($node);
#  }



#  sub ShiftSubTreeLeftSkipHidden {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;

#    Projectivize($node);

#    my @all=GetNodes();
#    SortByOrd(\@all);

#  #  print "$n\n";

#    my @vis=GetVisibleNodes();
#    SortByOrd(\@vis);
#    my $m=Index(\@vis,$node);
#    my $beforethis=$vis[$m-1];

#    my $n=$node->{$ord};
#    return 0 if ($n < $min);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)]),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)]),0);
#    for (my $i=$n-1;$i>=$x;$i--) { $all[$i]->{$ord}++; }
#    $node->{$ord}=$x;
#    RepasteNode($node);
#  }



















