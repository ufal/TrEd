# -*- cperl -*-

package PDT;
use base qw(TredMacro);
import TredMacro;

=pod

=head1 PDT

pdt.mak - Miscelaneous macros of general use in Prague Dependency Treebank

=head2 REFERENCE

=over 4

=item PDT::is_noun(node)

Check if the given node is a noun according to its morphological tag
(attribute C<tag>)

=cut
sub is_noun {
  return $_[0]->{tag}=~/^N../;
}

=item PDT::is_verb(node)

Check if the given node is a verb according to its morphological tag
(attribute C<tag>)

=cut
sub is_verb {
  return $_[0]->{tag}=~/^V../;
}

=item PDT::is_coord(node)

Check if the given node is a coordination according to its 
analytical function (attribute C<afun>)

=cut
sub is_coord {
  my ($node)=@_;
  return $node->{afun} =~ /^Coord/;
}

=item PDT::is_coord_TR(node)

Check if the given node is a coordination according to its TGTS
functor (attribute C<func>)

=cut
sub is_coord_TR {
  my ($node)=@_;
  return $node->{func} =~ /^(?:CONJ|DISJ|GRAD|ADVS|CSQ|REAS)$/;
}

=item PDT::is_apos(node)

Check if the given node is an aposition according to its analytical
function (attribute C<afun>)

=cut
sub is_apos {
  my ($node)=@_;
  return $node->{afun} eq '^Apos';
}

=item PDT::is_apos_TR(node)

Check if the given node is an apposition according to its TGTS functor
(attribute C<func>)

=cut
sub is_apos_TR {
  my ($node)=@_;
  return $node->{func} eq 'APPS';
}

=item PDT::is_pronoun_possessive(node)

Check if the given node is a possessive pronoun according to its
morphological tag (attribute C<tag>)

=cut
sub is_pronoun_possessive {
  my ($node)=@_;
  return $node->{tag}=~/^PS../;
}


=item PDT::expand_coord_apos(node,keep?)

If the given node is coordination or aposition (according to its
analytical function - attribute C<afun>) expand it to a list of
coordinated nodes. If the argument C<keep> is true, include the
coordination/aposition node in the list as well.

=cut
sub expand_coord_apos {
  my ($node,$keep)=@_;
  if (is_coord($node)) {
    return (($keep ? $node : ()),map { expand_coord_apos($_,$keep) }
      grep { $_->{afun} =~ '_Co' }
	$node->children());
  } elsif (is_apos($node)) {
    return (($keep ? $node : ()), map { expand_coord_apos($_,$keep) }
      grep { $_->{afun} =~ '_Co' }
	$node->children());
  } else {
    return $node;
  }
}


=item real_parent (node)

Find the nearest autosemantic governor of the given node. By
autosemantic we mean having the first letter of its morpholigical tag
in [NVADPC].

=cut
sub real_parent {
  my ($node)=@_;
  do  {
    $node=$node->parent();
  } while ($node and $node->{tag}!~/^[NVADPC]/);
  return $node;
}


=item get_subsentence_string_TR

Return string representation of current node and the first level of
tree-structure under it (coordinated substructures are expanded and
prepositions and other words stored in fw attributes are included in
the resulting string).

=cut
sub get_subsentence_string_TR {
  my ($node)=@_;
  return
    join(" ",map { ($_->{fw},$_->{form}.".".$_->{func}) }
	 sort {$a->{ord} <=> $b->{ord}}
	 $node,
	 map { expand_coord_apos($_,1) } $node->children());
}


=item expand_coord_apos_TR(node,keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<func>) expand it to a list of coordinated
nodes. If the argument C<keep> is true, include the
coordination/aposition node in the list as well.

=cut
sub expand_coord_apos_TR {
  my ($node,$keep)=@_;
  if (is_coord_TR($node)) {
    return (($keep ? $node : ()),map { expand_coord_apos_TR($_,$keep) }
      grep { $_->{memberof} eq 'CO' or $_->{reltype} eq 'CO' }
	$node->children());
  } elsif (is_apos_TR($node)) {
    return (($keep ? $node : ()), map { expand_coord_apos_TR($_,$keep) }
      grep { $_->{memberof} eq 'CO' or $_->{reltype} eq 'CO' }
	$node->children());
  } else {
    return $node;
  }
}


=item PDT->saveTreeStructureToAttr(atr,top?)

Save governing node's ord to given attribute in the whole tree (or, if
a C<top> node is given, in the subtree of C<top>).

=cut
sub saveTreeStructureToAttr {
  my ($class,$atr,$top)=@_;
  $top||=$root;

  my $node=$top->following;
  while ($node) {
    $node->{$atr}=$node->parent->{ord};
    $node=$node->following($top);
  }
}


=item PDT->saveTreeAStructure(atr,top?)

For each node in the tree save governing node's ord to attribute
C<ordorig>.

=cut
sub saveTreeAStructure {
  my $class=$_[0];
  saveTreeStructureToAttr($class,"ordorig");
}

=item PDT->saveTreeTStructure(atr,top?)

For each node in the tree save governing node's ord to attribute
C<govTR>.

=cut
sub saveTreeTStructure {
  my $class=$_[0];
  saveTreeStructureToAttr($class,"govTR");
}


=item PDT->substituteFSHeader(declarations)

Substitute a new FS header for current document. A list of valid FS
declarations must be passed to this function.

=cut
sub substituteFSHeader {
  my $class=shift;
  $grp->{FSFile}->changeFS(FSFormat->create(@_));
}

=item PDT->assignTRHeader

Assign standard TGTS header to current document.

=cut
sub assignTRHeader {
  my $class=$_[0];
  substituteFSHeader($class,@Csts2fs::TRheader);
}

=item PDT->assignARHeader

Assign standard analytical header to current document.

=cut
sub assignARHeader {
  my $class=$_[0];
  substituteFSHeader($class,@Csts2fs::ARheader);
}


=item PDT->assignTRHeader(declarations)

Merge given FS header declarations with the present header
of the current document.

=cut
sub appendFSHeader {
  my $class=shift;
  my $new=FSFormat->create(@_);
  my $newdefs=$new->defs();
  my $fs=$grp->{FSFile}->FS;
  my $defs=$grp->{FSFile}->FS->defs();
  my $list=$grp->{FSFile}->FS->list();
  foreach ($new->attributes()) {
    push @$list, $_ unless ($fs->exists($_));
    $defs->{$_}=$newdefs->{$_};
  }
  @{$fs->unparsed}=$fs->toArray() if $fs->unparsed;
}

=item PDT->convertToTRHeader

Merge current document's FS header with the standard TGTS header.

=cut
sub convertToTRHeader {
  my $class=$_[0];
  appendFSHeader($class,@Csts2fs::TRheader);
}

=item PDT->convertToARHeader

Merge current document's FS header with the standard analytical
header.

=cut
sub convertToARHeader {
  my $class=$_[0];
  appendFSHeader($class,@Csts2fs::ARheader);
}

=item PDT->file2TR

Prepare current FS file to be saved as TR file by merging its header
with standard TGTS header and saving the current tree (analytical)
structure to C<ordorig> attribute.n

=cut
sub file2TR {
  my $class=$_[0];
  convertToTRHeader($class);
  GotoTree(1);
  do {
    saveTreeAStructure($class);
  } while NextTree();
  GotoTree(1);
}

=item PDT->MD2TagLemma(source,top?)

Copy values of C<lemmaMD_src> and C<tagMD_src> attributes (that is,
the attributes resulting from C<E<lt>MDl src="src"E<gt>> and
C<E<lt>MDt src="src"E<gt>> CSTS elements) to C<lemma> and C<tag> where
C<src> is the value of the source argument. If no source is given,
suppose C<source="a">. If source is an empty string, do nothing.  If
the optional top node is given, work on a subtree of top instead the
whole tree.

=cut
sub MD2TagLemma {
  my ($class,$src,$top)=@_;
  $top||=$root;
  return if $src eq "";
  $src='a' unless defined $src;
  $src="_$src";
  my $node=$top;
  while ($node) {
    $node->{lemma}=$node->{"lemmaMD$src"};
    $node->{tag}=$node->{"tagMD$src"};
    $node=$node->following($top);
  }
  $root->{tag}||='Z#-------------';
  $root->{lemma}||='#';
}

=item PDT->delTagLemma(top?)

Delete values of C<lemma> and C<tag> attributes in the whole tree (or,
if top is given, in the subtree of top).

=cut
sub delTagLemma {
  my ($class,$top)=@_;
  $top||=$root;
  my $node=$top;
  while ($node) {
    $node->{lemma}=$node->{tag}='';
    $node=$node->following($top);
  }
}

=item PDT->MR2TR(source?)

Run Zdenek Zabokrtsky's automatical C<afun> assignment on the current
tree.  Run Alena Bohmova's ATS to TGTS transformation procedure.  Run
Zdenek Zabokrtsky's automatical functor assignment on the current
tree. The source argument may be used to specify C<lemma> and C<tag>
source (see MD2TagLemma).

=cut
sub MR2TR {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  convertToTRHeader($class);
  GotoTree(1);
  do {
    print "$root->{form}\n";
    MD2TagLemma($class,$src);
    Analytic->assign_all_afun_auto();
    saveTreeAStructure($class);
    Tectogrammatic->InitTR();
    Tectogrammatic->TreeToTR();
    Tectogrammatic->assign_all_func_auto();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->tree2AR(source?)

Run Zdenek Zabokrtsky's automatical C<afun> assignment on the current
tree. The source argument may be used to specify C<lemma> and C<tag>
source (see MD2TagLemma).

=cut
sub tree2AR {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  GotoTree(1);
  do {
    print "$root->{form} 000\n";
    MD2TagLemma($class,$src);
    Analytic->assign_all_afun_auto();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->AR2TRtree(source?)

Run Alena Bohmova's ATS to TGTS transformation procedure. The source
argument may be used to specify C<lemma> and C<tag> source (see
MD2TagLemma).

=cut
sub AR2TRtree {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  convertToTRHeader($class);
  GotoTree(1);
  do {
    print "$root->{form}\n";
    MD2TagLemma($class,$src);
    saveTreeAStructure($class);
    Tectogrammatic->InitTR();
    Tectogrammatic->TreeToTR();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->TRAssignFunc(source?)

Run Zdenek Zabokrtsky's automatical functor assignment on the current
tree.  The source argument may be used to specify C<lemma> and C<tag>
source (see MD2TagLemma).

=cut
sub TRAssignFunc {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  GotoTree(1);
  do {
    print "$root->{form}\n";
    MD2TagLemma($class,$src);
    Tectogrammatic->assign_all_func_auto();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->AR2TR(source?)

Run Alena Bohmova's ATS to TGTS transformation procedure.  Run Zdenek
Zabokrtsky's automatical functor assignment on the current tree.  The
source argument may be used to specify C<lemma> and C<tag> source (see
MD2TagLemma).

=cut
sub AR2TR {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  convertToTRHeader($class);
  GotoTree(1);
  do {
    print "$root->{form}\n";
    MD2TagLemma($class,$src);
    saveTreeAStructure($class);
    Tectogrammatic->InitTR();
    Tectogrammatic->TreeToTR();
    Tectogrammatic->assign_all_func_auto();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->InitTROrderingAttributes(top?)

Initialize all empty values of TGTS ordering attributes C<dord> and
C<sentord> with the value of analytical ordering attribute
(C<ord>). If top node is given, work only on its subtree (instead of
the whole tree).

=cut
sub InitTROrderingAttributes {
  my ($class,$top)=@_;
  $top||=$root;
  for (my $node=$root; $node; $node=$node->following($top)) {
    $node->{dord}=$node->{ord} if $node->{dord} eq "";
    $node->{sentord}=$node->{ord} if $node->{sentord} eq "";
  }
}

1;

=back

=cut
