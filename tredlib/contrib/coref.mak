# -*- cperl -*-

$referent="";

sub get_ID_for_coref {
  my $node=$_[0] || $this;
  return ($node->{TID} ne "") ? $node->{TID} : $node->{AID};
}

sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target;
  if ($mod eq 'Shift') {
    $node->{coref}=get_ID_for_coref($target);
    TredMacro::Redraw_FSFile_Tree();
    $FileNotSaved=1;
  }
}

#bind remember_this_node to Ctrl+q menu Remeber current node for coreference
sub remember_this_node {
  $referent = get_ID_for_coref($this);
  print STDERR "Remember:$referent $this->{AID}\n";
}

#bind set_referent_to_coref to Ctrl+s menu Set coreference to previously marked node
sub set_referent_to_coref {
  if ($referent eq get_ID_for_coref()) {
    $this->{coref}='';
  } else {
    $this->{coref}=$referent;
  }
}


sub add_style {
  my $styles=shift;
  my $style=shift;
  if (exists($styles->{$style})) {
    push @{$styles->{$style}},@_
  } else {
    $styles->{$style}=[@_];
  }
}

sub node_style_hook {
  my ($node,$styles)=@_;
  if (($referent ne "") and
      (($node->{TID} eq $referent) or
       ($node->{AID} eq $referent))) {
    add_style($styles,'Oval',
	      -fill => '#6a85cd'
	     );
    add_style($styles,'Node',
	      -addheidht => '6',
	      -addwidth => '6'
	     );
  }

  my $id1=$root->{ID1};
  $id1=~s/:/-/g;
  if ($node->{coref} ne "") {
    my ($coords,$color);
    if (index($node->{coref},$id1)==0) {
      print STDERR "Same sentence\n";
      # same sentence
      my $T="[?\${AID} eq '$node->{coref}' or \${TID} eq '$node->{coref}'?]";
      $color='&#6a85cd';
      $coords=<<COORDS;
         n,n,p,p &
         n,n,
         n + ($T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
         n + ($T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
         $T,$T
COORDS
    } else {
      my ($d,$p,$s)=($id1=~/^(.*?)-p(\d+)s(\d+)$/);
      my ($cd,$cp,$cs)=($node->{coref}=~/^(.*?)-p(\d+)s(\d+).\d+/);
      if ($d eq $cd) {
	print STDERR "Same document\n";
	# same document
	if ($cp<$p || $cp==$p && $cs<$s) {
	  # preceding sentence
	  print STDERR "Preceding sentence\n";
	  $color='&#c53c00';
	  $coords='n,n,p,p&n,n,n-30,n';
	} else {
	  # following sentence
	  print STDERR "Following sentence\n";
	  $color='&#c53c00';
	  $coords='n,n,p,p&n,n,n+30,n';
	}
      } else {
	# different document
	$coords=undef;
	print STDERR "Different document sentence\n";
	add_style($styles,'Oval', -fill => '#c53c00');
	add_style($styles,'Node',
		  -shape => 'rectangle',
		  -addwidth => 2,
		  -addheight => 2);
      }
    }
    if ($coords) {
      add_style($styles,'Line',
		-coords => $coords,
		-arrow => '&last',
		-dash => '&9,3',
		-width => '&2',
		-fill => $color,
		-smooth => '&1');
    }
  }
}

#bind generate_tids_whole_file to F7 menu Repair TID and AIDREFS
sub generate_tids_whole_file {
  Tectogrammatic->generate_tids_whole_file();
  Tectogrammatic->move_aid_to_aidrefs();
}

#bind auto_coref to Ctrl+e menu Automaticky dopln coref u vztaznych zajmen a nevyjadreneho aktora infinitivu

sub auto_coref {
  auto_coref_subclause();
  auto_coref_infinitive();
}

sub auto_coref_subclause {

  my $node=$root;
  while ($node) {
    if ($node->{tag}=~/^P[149EJK]/) {
      my $p=$node->parent;
      $p=$p->parent while ($p and $p->{tag}!~/^V[^f]/);
      if ($p) {
	my $s=$p->parent;
	$s=$s->parent while ($s and $s->{tag}!~/^[NP]/);
	if ($s) {
	  $node->{coref}=get_ID_for_coref($s);
	}
      }
    }
    $node=$node->following();
  }

}

sub find_depending_func {
  my ($node,$func,$memberof)=@_;
  my $child=$node->firstson;
  while ($child) {
    if ($child->{func} eq $func and (!$memberof or $child->{memberof}=~/CO|AP/)) {
      return $child;
    } elsif ($child->{func} =~ /^(?:APOS|CONJ|DISJ)$/) {
      if (find_depending_func($child,$func,1)) {
	return $child;
      }
    }
    $child=$child->rbrother;
  }
  return undef;
}

sub auto_coref_infinitive {

  for ($node=$root;$node;$node=$node->following()) {
    if ($node->{trlemma} eq '&Cor;') {
      print "N: $node->{trlemma},$node->{func}\n";
      
      next unless ($node->parent->{tag}=~/^V[fs]/ or
		   ($node->parent->{func}=~/^(?:APOS|CONJ|DISJ)$/ and
		    grep { $_->{tag}=~/^V[fs]/ and
			     $_->{memberof}=~/CO|AP/ } $node->parent->children));

      my $p=$node->parent->parent;
      print "P1: $p->{trlemma},$p->{func}\n" if $p;
      $p=$p->parent while ($p and $p->{tag}!~/^(?:V|AG)/);
      if ($p) {
	print "P2: $p->{trlemma},$p->{func}\n";
	my $cor;
	if ($p->{tag}=~/^AG/) {
	  $cor=$p->parent;
	  $cor=$cor->parent while ($cor and $cor->{func}=~/^(?:APOS|CONJ|DISJ)$/);
	  $cor=undef unless ($cor->{tag}=~/^[ANCP]/);
	} elsif ($p->{trlemma}=~/^(cítit|dát|dávat|lákat|nechat|nechávat|nutit|ponechat|ponechávat|poslat|posílat|sly¹et|slýchávat|spatøit|uvidìt|vidìt|vídávat|vyslat|vysílat)$/) {
	  $cor=find_depending_func($p,'PAT');
	} elsif ($p->{trlemma}=~/^(bránit|donutit|donucovat|doporuèit|doporuèovat|dovolit|dovolovat|zaøídit|za¾izovat|nauèit|pomoci|pomáhat|povolit|povolovat|pøimìt|uèit|umo¾nit|umo¾òovat|zabránít|zabraòovat|zakázat|zakazovat)$/) {
	  $cor=find_depending_func($p,'ADDR');
	} else {
	  $cor=find_depending_func($p,'ACT');
	}
	if ($cor and $cor != $node->parent) {
	  print "C: $cor->{trlemma},$cor->{func}\n";
	  $node->{coref}=get_ID_for_coref($cor);
	}
      }
    }
  }
}
