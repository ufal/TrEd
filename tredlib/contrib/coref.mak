# -*- cperl -*-

$referent="";
%cortype_colors = (
		   textual => '&#6a85cd',
		   grammatical => '&#f6c27b'
		  );

sub get_ID_for_coref {
  my $node=$_[0] || $this;
  return ($node->{TID} ne "") ? $node->{TID} : $node->{AID};
}

sub assign_coref {
  my ($node,$ref,$type)=@_;
  if ($ref eq get_ID_for_coref($node)) {
    $node->{coref}='';
    $node->{cortype}='';
  } elsif ($node->{coref} =~ /(^|\|)$ref(\||$)/) {
    # remove $ref from coref, plus remove the corresponding cortype
    my (%coref,@coref);
    @coref = split /\|/,$node->{coref};
    @coref{ @coref }=split /\|/,$node->{cortype};
    @coref = grep { $_ ne $ref } @coref;
    $node->{coref} = join '|',  @coref;
    $node->{cortype} = join '|', @coref{ @coref };
  } elsif ($node->{coref} eq '' or
	   $node->{coref} eq '???') {
    $node->{coref}=$ref;
    $node->{cortype}=$type;
  } else {
    $node->{coref}.='|'.$ref;
    $node->{cortype}.='|'.$type;
  }
}

sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target;
  my $type;
  print "MODE: $mod\n";
  if ($mod eq 'Shift') {
    $type='grammatical';
  } elsif ($mod eq 'Control') {
    $type='textual';
  } elsif ($mod eq 'Alt') {
    my $selection=['textual'];
    listQuery('single',[qw(textual grammatical)],$selection) || return;
    $type=$selection->[0];
  } else {
    print "Ignoring this mode\n";
    return;
  }
  assign_coref($node,get_ID_for_coref($target),$type);
  TredMacro::Redraw_FSFile_Tree();
  $FileNotSaved=1;
}

#bind remember_this_node to Ctrl+q menu Remeber current node for coreference
sub remember_this_node {
  $referent = get_ID_for_coref($this);
  print STDERR "Remember:$referent $this->{AID}\n";
}

#bind set_referent_to_coref to Ctrl+s menu Set coreference to previously marked node
sub set_referent_to_coref {
  my $selection=['textual'];
  listQuery('single',[qw(textual grammatical)],$selection) || return;
  assign_coref($this,$referent,$selection->[0]);
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
  my (@coords,@colors);
  my @cortypes=split /\|/,$node->{cortype};
  foreach my $coref (split /\|/,$node->{coref}) {
    my $cortype=shift @cortypes;
    if (index($coref,$id1)==0) {
      print STDERR "Same sentence\n";
      # same sentence
      my $T="[?\${AID} eq '$coref' or \${TID} eq '$coref'?]";
      push @colors,$cortype_colors{$cortype};
      push @coords,<<COORDS;
&n,n,
n + ($T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
n + ($T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
$T,$T
COORDS
      } else {
	my ($d,$p,$s)=($id1=~/^(.*?)-p(\d+)s(\d+)$/);
	my ($cd,$cp,$cs)=($coref=~/^(.*?)-p(\d+)s(\d+).\d+/);
	if ($d eq $cd) {
	  print STDERR "Same document\n";
	  # same document
	  if ($cp<$p || $cp==$p && $cs<$s) {
	    # preceding sentence
	    print STDERR "Preceding sentence\n";
	    push @colors,$cortype_colors{$cortype}; #'&#c53c00'
	    push @coords,'&n,n,n-30,n';
	  } else {
	    # following sentence
	    print STDERR "Following sentence\n";
	    push @colors,$cortype_colors{$cortype}; #'&#c53c00'
	    push @coords,'&n,n,n+30,n';
	  }
	} else {
	  # different document
	  print STDERR "Following sentence\n";
	  push @colors,$cortype_colors{$cortype}; #'&#c53c00'
	  push @coords,'&n,n,n,n+30';
	  print STDERR "Different document sentence\n";
	}
      }
  }
  if (@coords) {
    add_style($styles,'Line',
	      -coords => 'n,n,p,p'.join("",@coords),
	      -arrow => '&last' x @coords,
	      -dash => '&9,3' x @coords,
	      -width => '&2' x @coords,
	      -fill => join("",@colors),
	      -smooth => '&1' x @coords);
  }
  1;
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
	  $coref=get_ID_for_coref($s);
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
	  $coref=get_ID_for_coref($cor);
	}
      }
    }
  }
}
