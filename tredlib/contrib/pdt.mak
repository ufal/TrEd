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
  my $node=$_[0] || $this;
  return 0 unless $node;
  return $node->{func} =~ qr/CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/;
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


=item PDT::real_parent (node)

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

=item PDT::get_sentence_string

Return string representation of the given subtree
(suitable for Analytical trees).

=cut

 sub get_sentence_string {
   shift @_ unless ref($_[0]);
   my $top= $_[0]||$root;
   return undef unless $top;
   return join("",
		 map { $_->{origf}.($_->{nospace} ? "" : " ") }
		 sort { $a->{ord} <=> $b->{ord} }
		 $top->descendants);
}

=item PDT::get_subsentence_string_TR

Return string representation of the given node and the first level of
tree-structure under it (coordinated substructures are expanded and
prepositions and other words stored in fw attributes are included in
the resulting string).

=cut

sub get_subsentence_string_TR {
  shift @_ unless ref($_[0]);
  my $node=$_[0] || $this;
  return
    join(" ",map { ($_->{fw},$_->{form}.".".$_->{func}) }
	 sort {$a->{ord} <=> $b->{ord}}
	 $node,
	 map { expand_coord_apos($_,1) } $node->children());
}

=item PDT::get_sentence_string_TR

Return string representation of the given subtree
(suitable for Tectogrammatical trees).

=cut

 sub get_sentence_string_TR {
   shift @_ unless ref($_[0]);
   my $top= $_[0]||$root;
   return undef unless $top;
   my $sent=join("",
		 map { $_->{origf}.($_->{nospace} ? "" : " ") }
		 sort { $a->{sentord} <=> $b->{sentord} }
		 grep { $_->{origf} ne '???' and $_->{sentord}<999 } GetNodes($top));
   $sent=~s/^ //;
   return $sent;
}

=item PDT::expand_coord_apos_TR(node,keep?)

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


=item PDT->appendFSHeader(declarations)

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

=item PDT->undeclareAttributes(@attributes)

Remove declarations of given attributes from the FS header

=cut

sub undeclareAttributes {
  my $class=shift;
  my $fs=$grp->{FSFile}->FS;
  my $defs=$grp->{FSFile}->FS->defs();
  my $list=$grp->{FSFile}->FS->list();
  delete @{$defs}{@_};

  @$list=grep { exists($defs->{$_}) } @$list;
  @{$fs->unparsed}=grep { !/^\@\S+\s+([^\s|]+)/ || exists($defs->{$1})  }
    @{$fs->unparsed} if $fs->unparsed;

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


=item PDT->SaveAttributes(save_prefix,\@attributes,top?)

For the whole tree (or the subtree of optional top-node), copy values
of given attributes into new set of attributes with the original names
prefixed with the given save_prefix.

Thus, e.g., C<PDT-E<gt>SaveAttributes('x_save_',[qw(afun lemma tag)])>
stores afun to x_save_afun, lemma to x_save_lemma and tag to x_save_tag
for every node in the current tree.

=cut
sub SaveAttributes {
  my ($class,$prefix,$attrs,$top)=@_;
  $top||=$root;
  return if $prefix eq "";
  my $node=$top;
  while ($node) {
    foreach (@$attrs) {
      $node->{$prefix.$_}=$node->{$_};
    }
    $node=$node->following($top);
  }
}

=item PDT->RestoreSavedAttributes(save_prefix,\@attributes,top?)

Same as SaveAttributes but other way round.
Thus, e.g., C<PDT-E<gt>RestoreSavedAttributes('x_save_',[qw(afun lemma tag)])>
copies value of afun from x_save_afun, lemma from x_save_lemma and
tag from x_save_tag for every node in the current tree.

=cut
sub RestoreSavedAttributes {
  my ($class,$prefix,$attrs,$top)=@_;
  $top||=$root;
  return if $prefix eq "";
  my $node=$top;
  while ($node) {
    foreach (@$attrs) {
      $node->{$_}=$node->{$prefix.$_};
    }
    $node=$node->following($top);
  }
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
  $src='a' unless defined $src;
  return if $src eq "";
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
source (see C<PDT-E<gt>MD2TagLemma()>).

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
source (see C<PDT-E<gt>MD2TagLemma()>).

=cut
sub tree2AR {
  my ($class,$src)=@_;
  $src='a' unless defined $src;
  GotoTree(1);
  do {
    print "$root->{form}\n";
    MD2TagLemma($class,$src);
    Analytic->assign_all_afun_auto();
    delTagLemma($class) unless $src eq "";
  } while NextTree();
  GotoTree(1);
}

=item PDT->AR2TRtree(source?)

Run Alena Bohmova's ATS to TGTS transformation procedure. The source
argument may be used to specify C<lemma> and C<tag> source
(see C<PDT-E<gt>MD2TagLemma()>).

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
source (see C<PDT-E<gt>MD2TagLemma()>).

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
source argument may be used to specify C<lemma> and C<tag> source 
(see C<PDT-E<gt>MD2TagLemma()>).

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

#####include /home/stepanek/objsearch/tgsearch.btred

=item PDT::FilterSons_TR

=cut

sub FilterSons_TR { # node filter suff from
  my ($node,$filter,$suff,$from)=(shift,shift,shift,shift);
  my @sons;
  $node=$node->firstson;
  while ($node) {
    return @sons if $suff && @sons;
    unless ($node==$from){ # on the way up do not go back down again
      if(($suff&&is_valid_member_TR($node))
	 ||(!$suff&&!is_valid_member_TR($node))){ # this we are looking for
	push @sons,$node if !$suff or $suff && &$filter($node);
      }
      push @sons,FilterSons_TR($node,$filter,1,0)
	if (!$suff
	    &&is_coord_TR($node)
	    &&!is_valid_member_TR($node))
	  or($suff
	     &&is_coord_TR($node)
	     &&is_valid_member_TR($node));
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons_TR

=item PDT::GetChildren_TR ($node, $filter)

=cut

sub GetChildren_TR { # node filter
  my ($node,$filter)=(shift,shift);
  my @sons;
  my $a=$node;
  my $from;
  push @sons,FilterSons_TR($node,$filter,0,0);
  if(is_valid_member_TR($node)){
    my @oldsons=@sons;
    while($a and $a->{func}ne'SENT'
	  and (is_valid_member_TR($a) || !is_coord_TR($a))){
      $from=$a;$a=$a->parent;
      push @sons,FilterSons_TR($a,$filter,0,$from) if $a;
    }
    if ($a->{func}eq'SENT'){
      stderr("Error: Missing coordination head: ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  grep &$filter($_),@sons;
} # GetChildren_TR


=item PDT::is_member_TR ($node?)

Returns true if the given node is a member of a coordination,
aposition or operation according to its memberof and/or operand
attribute and its parent's functor.

=cut

# the given node is a member of coordination
sub is_member_TR {
  my $node=$_[0] || $this;
  return 0 if !$node->parent or !is_coord_TR($node->parent);
  return 1 if $node->parent->{func}=~/APPS/ and $node->{memberof} =~ /AP/;
  return 1 if $node->parent->{func}=~/OPER/ and $node->{operand} =~ /OP/;
  return 1 if $node->{memberof} =~ /CO/;
}

=item PDT::is_valid_member_TR ($node?)

Similar to is_member_TR but also check for validity with
valid_member_TR.

=cut

sub is_valid_member_TR {
  my $node=$_[0] || $this;
  is_member_TR($node) && valid_member_TR($node)
}

=item PDT::valid_member_TR ($node?)

Check, that the possible memberof and operand attributes of the given
node are in accord with its parent's functor. Return 0 if error is
found, 1 if the settings seem correct. Note: returns 1 even if the
given node has no memberof and operand at all.

=cut

sub valid_member_TR {
  my $node=$_[0] || $this;
  return 0 if (!$node->parent or !is_coord_TR($node->parent)) and
    $node->{memberof} =~ /CO|AP/ and $node->{operand} =~ /OP/;
  if ($node->parent) {
    return 0 if $node->parent->{func}=~/APPS/ and
      ($node->{memberof} =~ 'CO' or $node->{operand}=~ /OP/);
    return 0 if $node->parent->{func}=~/OPER/ and
      ($node->{memberof} =~ /CO|AP/);
    return 0 if is_coord_TR($node->parent) and
      $node->parent->{func}!~/APPS|OPER/ and
      ($node->{operand} =~ /OP/ or $node->{memberof} =~ /AP/);
  }
  return 1;
}





1;

=back

=cut
