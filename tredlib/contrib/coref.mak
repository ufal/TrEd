# -*- cperl -*-

# -------------------------------------------------------------------
#
# CONFIGURATION:
#

$cortypes='textual|grammatical';              # types of coreference

%cortype_colors = (                           # colors of coreference arrows
		   textual => '#6a85cd',
		   grammatical => '#f6c27b'
		  );

$referent_color = '#6a85cd';                  # color of the marked node

# verbs with antecedent PAT (for automatic coreference assingment)
$inf_lemmas_pat=
  'cítit|dát|dávat|lákat|nechat|nechávat|nutit|ponechat|ponechávat|poslat|'.
  'posílat|sly¹et|slýchávat|spatøit|uvidìt|vidìt|vídávat|vyslat|vysílat';

# verbs with antecedent ADDR (for automatic coreference assingment)
$inf_lemmas_addr=
  'bránit|donutit|donucovat|doporuèit|doporuèovat|dovolit|dovolovat|zaøídit|'.
  'za¾izovat|nauèit|pomoci|pomáhat|povolit|povolovat|pøimìt|uèit|umo¾nit|'.
  'umo¾òovat|zabránít|zabraòovat|zakázat|zakazovat';

# -------------------------------------------------------------------
#
# IMPLEMENTATION:
#

$referent=""; # stores ID of the marked node (Cut-and-Paste style)

#bind update_coref_file to F7 menu Update coref attributes
sub update_coref_file {
  Tectogrammatic->upgrade_file_to_tid_aidrefs();
  # no need for upgrade if cortype is declared with the $cortypes values
  return if (exists(FS()->defs->{cortype})
	     and join('|',FS()->listValue('cortype')) eq $cortypes);

  # otherwise, let the use decide
  if (!GUI() || questionQuery('Automatic file update',
			      "This file's declaration of coreference attributes is not up to date.\n\n".
			      "Should this declaration be added and the obsolete coreference attributes\n".
			      "'cornum', 'corsnt' and 'antec' removed (recommended)?\n\n",
			      qw{Yes No}) eq 'Yes') {
    AppendFSHeader('@P cortype',
			'@L cortype|'.$cortypes.'|---',
			'@P corlemma'
		       );
    UndeclareAttributes(qw(cornum corsnt antec));
  }
}

# return AID or TID of a node (whichever is available)
sub get_ID_for_coref {
  my $node=$_[0] || $this;
  return ($node->{TID} ne "") ? $node->{TID} : $node->{AID};
}


#bind jump_to_referent to ? menu Jump to node in coreference with current
sub jump_to_referent {
  my $id1=$this->{ID1};
  $id1=~s/:/-/g;
  my $coref=$this->{coref};
  my $treeno=0;
  if ($coref ne '') {
    my ($d)=($coref=~/^(.*?-p\d+s[0-9A-Z]+).\d+/);
    my $tree;
    if ($d eq $id1) {
      $tree=$root;
    } else {
      foreach my $t (GetTrees()) {
	$id1=$t->{ID1};
	$id1=~s/:/-/g;
	if ($d eq $id1) {
	  $tree=$t;
	  last;
	}
	$treeno++;
      }
    }
    while ($tree) {
      if ($tree->{AID} eq $coref or
	  $tree->{TID} eq $coref) {
	GotoTree($treeno+1) if ($treeno != CurrentTreeNumber());
	$this=$tree;
	last;
      }
      $tree=$tree->following();
    }
    if (!$tree) {
      GUI() && questionQuery('Error',
			   "The node in creference relation with the current node " .
			   "was not found in this file!",
			   'Ok');
    }
  }
  $FileChanged=0 if $FileChanged eq '?';
}

#bind edit_corlemma to \ menu Edit textual coreference (corlemma)
sub edit_corlemma {
  my $value=$this->{corlemma};
  $value=QueryString("Edit textual coreference","corlemma:",$value);
  if (defined($value)) {
    $this->{corlemma}=$value;
    $FileChanged=1;
  } else {
    $FileChanged=0 if $FileChanged eq '?';
  }
}


# add/remove a coref to/from a node. if the coref is already present,
# remove it otherwise add it.
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

# hook coref assignment to node-release event
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
  return if $referent eq "";
  my $selection=['textual'];
  listQuery('single',[qw(textual grammatical)],$selection) || return;
  assign_coref($this,$referent,$selection->[0]);
}

#bind remove_last_coref to Ctrl+j menu Remove last coreference from the current node
sub remove_last_coref {
  shift @_ unless ref($_[0]);
  my $node = ($_[0] || $this);
  $node->{coref}=~s/(^|\|)[^\|]*$//;
  $node->{cortype}=~s/(^|\|)[^\|]*$//;
}


# hook coref arrows drawing and custom coloring to node styling event
sub node_style_hook {
  my ($node,$styles)=@_;
  if (($referent ne "") and
      (($node->{TID} eq $referent) or
       ($node->{AID} eq $referent))) {
    AddStyle($styles,'Oval',
	      -fill => $referent_color
	     );
    AddStyle($styles,'Node',
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
      my $T="[?\$node->{AID} eq '$coref' or \$node->{TID} eq '$coref'?]";
      push @colors,$cortype_colors{$cortype};
      push @coords,<<COORDS;
&n,n,
n + (x$T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
n + (y$T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
x$T,y$T

COORDS
#&n,n,
#n + (x$T-n)/2, n,
#n + (x$T-n)/2, y$T,
#x$T,y$T
      } else {
	my ($d,$p,$s)=($id1=~/^(.*?)-p(\d+)s([0-9A-Z]+)$/);
	my ($cd,$cp,$cs)=($coref=~/^(.*?)-p(\d+)s([0-9A-Z]+).\d+/);
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
	  print STDERR "Different document?\n";
	  push @colors,$cortype_colors{$cortype}; #'&#c53c00'
	  push @coords,'&n,n,n,n-30';
	  print STDERR "Different document sentence\n";
	}
      }
  }
  if ($node->{corlemma} ne "") {
    AddStyle($styles,'Oval',
	      -fill => $cortype_colors{'textual'}
	     );
    AddStyle($styles,'Node',
	      -shape => 'rectangle',
	      -addheidht => '5',
	      -addwidth => '5'
	     );
  }
  if (@coords) {
    AddStyle($styles,'Line',
	      -coords => 'n,n,p,p'.join("",@coords),
	      -arrow => '&last' x @coords,
	      -dash => '&9,3' x @coords,
	      -width => '&2' x @coords,
	      -fill => join("&","",@colors),
	      -smooth => '&1' x @coords);
  }
  1;
}


#bind auto_coref to Ctrl+e menu Automaticky dopln coref u vztaznych zajmen a nevyjadreneho aktora infinitivu
sub auto_coref {
  auto_coref_subclause();
  auto_coref_infinitive();
}

# automatically assign subclause coreference
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
	  $node->{cortype}='grammatical';
	}
      }
    }
    $node=$node->following();
  }

}

# find nearest depending node with given FUNC (skip coordinations and apositions)
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

# automatically assign coreference to constructions with infinitive
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
	} elsif ($p->{trlemma}=~/^(?:$inf_lemmas_pat)$/) {
	  $cor=find_depending_func($p,'PAT');
	} elsif ($p->{trlemma}=~/^(?:$inf_lemmas_addr)$/) {
	  $cor=find_depending_func($p,'ADDR');
	} else {
	  $cor=find_depending_func($p,'ACT');
	}
	if ($cor and $cor != $node->parent) {
	  print "C: $cor->{trlemma},$cor->{func}\n";
	  $node->{coref}=get_ID_for_coref($cor);
	  $node->{cortype}='grammatical';
	}
      }
    }
  }
}

=pod

=head1 Coref

coref.mak - TrEd mode for coreference annotation

=head2 USAGE

=over 4

=item Adding a coreference relation using mouse

Coreference annotation by mouse works only if both nodes in the
coreference relation belong to the same tree.

1. Drag a node with the left mouse button to the node which is in the
coreference relation with the node being dragged and keep the mouse
button pressed.

2. To annotate textual coreference, press and hold Ctrl. To annotate
grammatical coreference , press and hold Shift. To select the type of
coreference from a list, press and hold Alt.

3. Release the mouse button.

4. Release the modifier key (Ctrl/Shift/Alt).

You will see a dashed arrow representing the coreference relation.

=item Removing a coreference relation using mouse

To remove a coreference relation between two nodes within the same
tree, proceed exactly as when creating a relation. 

=item Adding a coreference relation using keyboard

Coreference annotation by keyboard is especially useful to annotate
coreference between nodes that are very distant to each other or don't
belong to the same tree.

1. Select the node where the coreference relation ends and press
   Ctrl+q. The node is now marked and visibly distinguished from other
   nodes in the tree.

2. Select the node where the coreference relation starts and press
   Ctrl+s.

3. Select type of relation from the list (if you are using keyboard,
   do not forget to press Space to mark the selected item before you
   press Enter or Ok).

An arrow representing the coreference relation appears between the
nodes in relation.

Node, that it is possible to repeat Step 2 without repeating Step 1 as
long as the end-node of the coreference relation remains the same.

=item Removing a coreference relation using keyboard

To remove a coreference relation that starts in the current node,
press Ctrl+j. If there are more than one relation starting at the
point, only the one that was last added will be removed.

=item Coreference to non-nodes

To annotate a coreference with an entity not represented by a node in
the treebank, press "backslash" (\) and fill the text field with lemma
or other description of the entity according to annotation guidelines.
Nodes that have been assigned a coreference in this way are displayed
as squares.

=item Jump to the node in coreference relation

To quickly move to the node that is in the coreference relation with
the current node, press '?'. Note, that this does not work for
coreference between nodes that belong to different files.

=item Automatic coreference assignment

Some simple cases of grammatical coreference in PDT tectogrammatical
trees can be recognized automatically. To apply the automatic
coreference recognition procedure on the current tree, press Ctrl+e.

=item Reseting default display style

Press F8 to apply the default display settings to the current file.

=item Applying new-style coreference declarations

Since there is a lot of files floating around which don't yet use
the most recent annotations scheme for coreference annotation,
there is a macro provided to upgrade those FS files.

Press F7 to upgrade current file by applying the new FS header to
it. Note that this macro may completely discard old-style
coreference-related annotation in the file, since it removes all
obsolete attributes for coreference markup.

=back

=head2 CUSTOMIZING

This section describes how to customize coreference macros coref.mak
in order to allow annotation of other relations between nodes.

For this purpose, there is a set of variable assignments at the
beginning of coref.mak, that can be altered.

=over 4

=item Adding other coreference types/classes

To add new types of coreference to the annotation scheme, simply add
new types to the $cortypes variable (separating items with the
pipeline '|' character) and associate them with colors of arrows
in the %cortype_colors variable by adding a

C< name =E<gt> '#rrggbb', >

construction, where C<name> is a name of the new type and C<#rrggbb>
is the color to be used in hexadecimal notation of RGB (red, green,
blue).

Press F7 (see above) to apply the changes in the annotation scheme on
the current file.

=back

=head2 ANNOTATION SCHEME

The coreference relation is represented using the following FS attributes:
C<coref>, C<cortype>, and C<corlemma>.

Each time a new coreference relation is created between two nodes A
and B (respectively), a unique identifier of B is taken from its AID
or TID attribute (whichever is available) and appended to the C<coref>
attribute of the node A. At the same time, the type label of the
coreference is added to the C<cortype> attribute of A. Individual
identifiers in the C<coref> attribute as well as types of the
relations in the C<cortype> attribute are separated with a pipeline
character '|'.  The correspondence between the identifiers in C<coref>
attribute and the types in C<cortype> is given by the order in which
they appear in the respective attributes.

The C<corlemma> attribute is used to mark coreference relation between
a node and other entity/entities not represented by a node.  If a node
is in relation with more than one entity, their individual
representations in C<corlemma> attribute are separated with pipeline
character '|'.  Coreference relations given by C<corlemma> attribute
are not assigned any explicit type. In PDT they are automatically
considered as textual coreference relations.

In CSTS SGML format (used in PDT), each coreference relation starting
at a given node is stored in a separate C<coref> element. The
identifier of the node of the coreference relation is stored in its
C<ref> attribute and type of the relation in its C<type> attribute.
If the relation target is other entity than a node (i.e. it is
represented by C<corlemma> attribute in FS), the C<coref> element has
no C<ref> attribute but contains the representation of the entity as
PCDATA.

=cut

