# -*- cperl -*-

#encoding iso-8859-2

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
  return $node->{afun} =~ /^Apos/;
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
  return unless $node;
  if (is_coord($node)) {
    return (($keep ? $node : ()),map { expand_coord_apos($_,$keep) }
      grep { $_->{afun} =~ '_Co' }
	$node->children());
  } elsif (is_apos($node)) {
    return (($keep ? $node : ()), map { expand_coord_apos($_,$keep) }
      grep { $_->{afun} =~ '_Ap' }
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
  return unless $node;
  if (is_coord_TR($node)) {
    return (($keep ? $node : ()),
	    map { expand_coord_apos_TR($_,$keep) }
	    grep { is_valid_member_TR($_) } $node->visible_children(FS()));
  } else {
    return ($node);
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


=item PDT->saveTreeAStructure(top?)

For each node in the tree save governing node's ord to attribute
C<ordorig>.

=cut
sub saveTreeAStructure {
  my ($class,$top)=@_;
  saveTreeStructureToAttr($class,"ordorig",$top);
}

=item PDT->saveTreeTStructure(top?)

For each node in the tree save governing node's ord to attribute
C<govTR>.

=cut
sub saveTreeTStructure {
  my ($class,$top)=@_;
  saveTreeStructureToAttr($class,"govTR",$top);
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
  require Csts2fs;
  my $class=$_[0];
  substituteFSHeader($class,@Csts2fs::TRheader);
}

=item PDT->assignARHeader

Assign standard analytical header to current document.

=cut
sub assignARHeader {
  require Csts2fs;
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
  $grp->{FSFile}->FS->renew_specials();
#  @{$fs->unparsed}=$fs->toArray() if $fs->unparsed;
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
#  @{$fs->unparsed}=grep { !/^\@\S+\s+([^\s|]+)/ || exists($defs->{$1})  }
#    @{$fs->unparsed} if $fs->unparsed;

}


=item PDT->convertToTRHeader

Merge current document's FS header with the standard TGTS header.

=cut
sub convertToTRHeader {
  require Csts2fs;
  my $class=$_[0];
  appendFSHeader($class,@Csts2fs::TRheader);
}

=item PDT->convertToARHeader

Merge current document's FS header with the standard analytical
header.

=cut
sub convertToARHeader {
  require Csts2fs;
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

sub _expand_coord_apos_GetFather_AR { # node through
  my ($node,$through)=@_;
  my @toCheck = $node->children;
  my @checked;
  while (@toCheck) {
    @toCheck=map {
      if (&$through($_)) { $_->children() }
      elsif($_->{afun}=~/(?:Coord|Apos)_[CA]/){ _expand_coord_apos_GetFather_AR($_,$through) }
      elsif($_->{afun}=~/_[CA]/){ push @checked,$_;() }
      else{()}
    }@toCheck;
  }
  return @checked;
}

=item PDT::GetFather_AR($node,$through)

Return linguistic parent of a given node as appears in an analytic
tree. The argument C<$through> should supply a function accepting one
node as an argument and returning true if the node should be skipped
on the way to parent (usually nodes with afun AuxC or AuxP) or 0
otherwise.

=cut

sub GetFather_AR { # node through
  my ($node,$through)=@_;
  my $init_node = $node; # only used for reporting errors
  if ($node->{afun}=~/_[CA]/) { # go to coordination head
    while ($node->{afun}!~/(?:Coord|Apos)(?:$|_P)|AuxS/) {
      $node=$node->parent;
      if (!$node) {
	print STDERR
	  "GetFather: Error - no coordination head $init_node->{AID}: ".ThisAddress($init_node)."\n";
      } elsif($node->{afun}eq'AuxS') {
	print STDERR
	  "GetFather: Error - no coordination head $node->{AID}: ".ThisAddress($node)."\n";
      }
    }
  }
  if (&$through($node->parent)) { # skip 'through' nodes
    while (&$through($node->parent)) {
      $node=$node->parent;
    }
  }
  $node=$node->parent;
  return $node if $node->{afun}!~/Coord|Apos/;
  _expand_coord_apos_GetFather_AR($node,$through);
} # GetFather_AR

sub FilterSons_AR{ # node filter dive suff from
  my ($node,$filter,$dive,$suff,$from)=@_;
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; # comment this line to get all members
    unless ($node==$from){ # on the way up do not go back down again

      if (!$suff&&$node->{afun}=~/Coord$|Apos$|Coord_P|Apos_P/
	  or$suff&&$node->{afun}=~/(Coord|Apos)_[CA]/) {
	push @sons,FilterSons_AR($node,$filter,$dive,1,0)
      } elsif (&$dive($node) and $node->firstson){
	push @sons,FilterSons_AR($node,$filter,$dive,$suff,0);
      } elsif(($suff&&$node->{afun}=~/_[CA]/)
	      ||(!$suff&&$node->{afun}!~/_[CA]/)){ # this we are looking for
	push @sons,$node if !$suff or $suff && &$filter($node);
      }
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons_AR

=item PDT::GetChildren_AR ($node, $filter, $dive)

Return a list of nodes linguistically dependant on a given node. The
list may be filtered by a given subroutine specified in C<$filter>.  A
fitler obtains one argument - the child node to be filtered - and
should return either true (the child node is permitted to the result
list) or false (the child node is filtered out). C<$dive> is a
function which is called to test whether a given node should be used
as a terminal node (in which case it should return false) or whether it
should be skipped and its children processed instead (in which case it
should return true). Most usual case is to provide function returning 1
for nodes with afun AuxC and AuxP. If C<$dive> is skipped, a function
returning 0 for all arguments is used.

=cut

sub GetChildren_AR{ # node filter dive
  my ($node,$filter,$dive)=@_;
  my @sons;
  my $from;
  $filter = sub { 1 } unless defined($filter);
  $dive = sub { 0 } unless defined($dive);
  push @sons,FilterSons_AR($node,$filter,$dive,0,0);
  if($node->{afun}=~/_Co|_Ap/){
    my @oldsons=@sons;
    while($node->{afun}!~/Coord$|Coord_P|Apos$|Apos_P|AuxS/){
      $from=$node;$node=$node->parent;
      push @sons,FilterSons_AR($node,$filter,$dive,0,$from);
    }
    if ($node->{afun}eq'AuxS'){
      print STDERR "Error: Missing Coord/Apos: $node->{AID}$node->{ID1} ".ThisAddress($node)."\n";
      @sons=@oldsons;
    }
  }
  grep &$filter($_),@sons;
} # GetChildren_AR



#####include /home/stepanek/objsearch/tgsearch.btred

sub FilterSons_TR { # node filter suff from
  my ($node,$filter,$suff,$from)=(shift,shift,shift,shift);
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons;
    unless ($node==$from){ # on the way up do not go back down again
      if(($suff&&is_valid_member_TR($node))
	 ||(!$suff&&!is_valid_member_TR($node))){ # this we are looking for
	push @sons,$node if (!is_coord_TR($node) and (!$suff or $suff && &$filter($node)));
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

Return a list of nodes linguistically dependant
on a given node. The list may be filtered by
a given subroutine specified in C<$filter>.
A filter obtains one argument - the child node to be filtered - 
and should return either true (the child node is permitted
to the result list) or false (the child node
is filtered out).

=cut

sub GetChildren_TR { # node filter
  my ($node,$filter)=(shift,shift);
  return () if is_coord_TR($node);
  $filter = sub { 1 } unless $filter;
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
      stderr("Error: Missing coordination head: $node->{ID1} $a->{AID}$a->{TID} ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  grep &$filter($_), grep { !IsHidden($_) } @sons;
} # GetChildren_TR


=item PDT::GetDescendants_TR

Return a list of all nodes linguistically subordinated to a given node
(not including the node itself).

=cut

sub GetDescendants_TR {
  my ($node)=@_;
  return () unless ($node and !is_coord_TR($node));
  return uniq(map { $_, GetDescendants_TR($_) } GetChildren_TR($node));
}


=item PDT::GetFather_TR ($node)

Return linguistic parent of a given node as
appears in a TR tree.

=cut

sub GetFather_TR {
  my ($node)=@_;
  if ($node and is_valid_member_TR($node)) {
    while ($node and (!is_coord_TR($node) or is_valid_member_TR($node))) {
      $node=$node->parent;
    }
  }
  return () unless $node;
  $node=$node->parent;
  return () unless $node;
  return ($node) if !is_coord_TR($node);
  return (expand_coord_apos_TR($node));
} # GetFather


=item PDT::GetAncestors_TR

Return a list of all nodes linguistically superordinated to (ie governing)a given node
(not including the node itself).

=cut

sub GetAncestors_TR {
  my ($node)=@_;
  return () unless ($node and !is_coord_TR($node));
  return uniq(map { ($_, GetAncestors_TR($_)) } GetFather_TR($node));
}


=item PDT::GetTrueSiblings_TR ($node)

Return linguistic siblings of a given node as appears in a TR
tree. This doesn't include the node itself, neither those children of
the node's linguistic parent that are in coordination with the node.

=cut

sub GetTrueSiblings_TR {
  my ($node)=@_;
  my $coord = highest_coord_TR($node);
  return
    grep { highest_coord_TR($_) != $coord }
    map { PDT::GetChildren_TR($_) }
    PDT::GetFather_TR($node)
} # GetTrueSiblings_TR

=item PDT::highest_coord_TR($node)

If the node is not a member of a coordination, return the node.  If it
is a member of a coordination, return the node representing the
highest coordination $node is a member of.

=cut

sub highest_coord_TR {
 my ($node) = @_;
 while (PDT::is_valid_member_TR($node)) {
   $node=$node->parent;
 }
 return $node;
}


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
    ($node->{memberof} =~ /CO|AP/ or $node->{operand} =~ /OP/);
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


=item PDT::transform_to_tectogrammatic ()

Saves TR strucutre to govTR attribute, changes header to default AR
header and restores the original AR tree structure from ordorig.
Nodes added on TR are placed on root and hidden (with ARhide='hide').

=cut

sub transform_to_tectogrammatic {
  my $fsformat = FSFormat->new({'dord' => ' N'},['dord']);
  foreach my $root ($grp->{FSFile}->trees) {
    my @nodes = ($root,$root->descendants);
    my %nodes = map {$_->{ord} => $_} @nodes;
    if ($root->{reserve1} eq 'TR_TREE') {
      ErrorMessage("Tree already looks like TR_TREE");
      return;
    }
    $root->{reserve1}='TR_TREE';
    PDT->convertToTRHeader();
    PDT->saveTreeAStructure($root);

    # disconnect all nodes
    foreach my $node (@nodes) {
      Fslib::SetParent($node,0);
      Fslib::SetFirstSon($node,0);
      Fslib::SetLBrother($node,0);
      Fslib::SetRBrother($node,0);
    }

    # connect nodes
    foreach my $node (@nodes) {
      next if $node == $root;
      if (ref($nodes{ $node->{govTR} })) {
	Fslib::Paste($node,$nodes{ $node->{govTR} },$fsformat);
      } else {
	Fslib::Paste($node,$root,$fsformat);
      }
    }

    # make sure we have a tree
    foreach my $node (@nodes) {
      next if $node == $root;
      my $r = $node;
      while ($r->parent) {
	$r = $r->parent();
	last if $r == $node;
      }
      if ($r == $node) {
	Cut($r);
      }
      unless ($r == $root) {
	print STDERR "fixing structure of [$node->{ord}]\n";
	Fslib::Paste($r,$root,$fsformat);
      }
    }
  }
}

=item PDT::transform_to_analytic ()

Saves AR strucutre to ordorig attribute, changes header to default TR
header and restores the original TR tree structure from govTR.

=cut

sub transform_to_analytic {
  my $fsformat = FSFormat->new({'ord' => ' N'},['ord']);
  foreach my $root ($grp->{FSFile}->trees) {
    my @nodes = ($root,$root->descendants);
    unless ($root->{reserve1} eq 'TR_TREE') {
      ErrorMessage("Tree doesn't look like TR_TREE");
      return;
    }
    $root->{reserve1}='AR_TREE';
    PDT->convertToARHeader();
    PDT->saveTreeTStructure($root);

    my (@analytic,@added);
    # disconnect all nodes
    foreach my $node (@nodes) {
      Fslib::SetParent($node,0);
      Fslib::SetFirstSon($node,0);
      Fslib::SetLBrother($node,0);
      Fslib::SetRBrother($node,0);
    }

    # create an array of analytic nodes
    foreach my $node (@nodes) {
      if ($node->{ord} !~ /\./) {
	$analytic[ $node->{ord} ] = $node;
      } else {
	push @added,$node;
      }
    }

    # connect analytic nodes
    foreach my $node (@analytic) {
      next if $node == $root;
      if ($node->{ordorig} =~ /^\d+$/ and
	  defined $analytic[ $node->{ordorig} ]) {
	Fslib::Paste($node,$analytic[ $node->{ordorig} ],$fsformat);
      } else {
	Fslib::Paste($node,$root,$fsformat);
      }
      $node->{ARhide}=''; # don't hide them
    }

    # connect TR-added nodes
    foreach my $node (@added) {
      next if $node == $root;
      Fslib::Paste($node,$root,$fsformat);
      $node->{ARhide}='hide'; # hide them
    }

    # make sure we have a tree
    foreach my $node (@nodes) {
      next if $node == $root;
      my $r = $node->root();
      unless ($r == $root) {
	Fslib::Paste($r,$root,$fsformat);
      }
    }
  }
}

=item PDT::ARstruct ()

Builds parallel analytical structure on all tectogrammatical trees in
current file, using the ordorig attribute. This structure is stored in
attributes _AP_,_AS_,_AL_,_AR_. Fslib is re-configured to use these
structure attributes instead of the default ones, so that all common
FSNode methods like parent, children, following, descendants, etc work
on the new structure. Use L<PDT::TRstruct> to switch back to the
tectogrammatical structure.

=cut

sub ARstruct {
  my ($single)=@_;
  foreach my $r ($single ? $root : $grp->{FSFile}->trees) {
    # build the parallel structure,
    # unless already built
    next if exists($r->{_AP_});
    my @nodes = $r->descendants;
    # hash parents
    my %p = map { $_->{ord} => $_ } ($r,@nodes);
    my %c;
    # create children lists
    for my $node (@nodes) {
      if ($node->{ord}!~/\./ and $p{$node->{ordorig}}) {
	push @{$c{ $p{ $node->{ordorig} }->{ord} }},$node;
      }
    }
    # build the structure
    foreach my $node ($r,@nodes) {
      if ($node->{ord}!~/\./) {
	$node->{_AP_} = $p{$node->{ordorig}};
	my @ch = sort { $a->{ord} <=> $b->{ord} } @{ $c{ $node->{ord} } };
	$node->{_AS_} = (ref($ch[0]) ? $ch[0] : 0);
	my $i = 0;
	my $prev = 0;
	while (ref($ch[$i])) {
	  $ch[$i]->{_AL_} = $prev;
	  $prev->{_AR_} = $ch[$i] if ref($prev);
	  $prev=$ch[$i];
	  $i++;
	}
      } else {
	for (qw(_AP_ _AS_ _AL_ _AR_)) {
	  $node->{$_} = 0;
	}
      }
    }
  }
  # mend file header
  my $format = $grp->{FSFile}->FS;
  my $defs = $format->defs;
  $defs->{ord}  = ' N';
  $defs->{dord} = ' P';
  $defs->{TR}   = ' P';
  $format->renew_specials();
  #  PDT->appendFSHeader('@N ord','@P dord','@P TR');
  # configure Fslib
  $Fslib::parent="_AP_";
  $Fslib::firstson="_AS_";
  $Fslib::lbrother="_AL_";
  $Fslib::rbrother="_AR_";
}

=item PDT::TRstruct ()

Setup Fslib to use default (tectogrammatical) tree structure
(after ARstruct was called).

=cut

sub TRstruct {
  # fix file header
#  PDT->appendFSHeader('@P ord','@N dord','@H TR');
  my $format = $grp->{FSFile}->FS;
  my $defs = $format->defs;
  $defs->{ord}  = ' P';
  $defs->{dord} = ' N';
  $defs->{TR}   = ' H';
  $format->renew_specials();
  # configure Fslib
  $Fslib::parent="_P_";
  $Fslib::firstson="_S_";
  $Fslib::lbrother="_L_";
  $Fslib::rbrother="_R_";
}

=item PDT::ClearARstruct ()

Probably useless if in TRstruct().  Clear parallel analytical
structure. This should be done at the end of processing in order to
break cyclic node references and thus prevent memory leaks in Perl
garbage collector.

=cut

sub ClearARstruct {
  TRstruct();
  foreach my $root ($grp->{FSFile}->trees) {
    my $node=$root;
    while ($node) {
      delete $node->{$_} for qw(_AP_ _AS_ _AL_ _AR_);
      $node = $node->following();
    }
  }
}

=item PDT::SetHidden ($node?)

If current node is hidden, set the hide flag on it.  Calling this on
all trees may speedup the identification of hidden nodes.

=cut

sub SetHidden {
  my $node=$_[0] || $this;
  my $hid=FS()->hide;
  $node->{$hid} = 'hide' if IsHidden($node);
}

sub trueFiniteVerb_TR {
  my ($node)=@_;
  $node->{tag}=~/^V[^sf]/;
}#trueFiniteVerb_TR

=item isFiniteVerb_TR (node,aid_hash)

If the node is the head of a finite complex verb form (based on
C<AIDREFS> information), return 1, else return 0.

=cut

sub isFiniteVerb_TR {
  my ($node,$hash)=@_;
  return (trueFiniteVerb_TR($node)
	  or $node->{tag}=~/^V/
          &&(
             grep {trueFiniteVerb_TR($_)}grep{IsHidden($_)}
             map {my$n=$hash->{$_};$n!=$node?$n:0} split /\|/,$node->{AIDREFS}) >0
         )
  ? 1 : 0;
}#isFiniteVerb_TR

=item isPassive_TR (node,aid_hash)

If the node is the head of a passive complex verb form, (based on
C<AIDREFS> information), return 1, else return 0.

=cut

sub isPassive_TR {
  my($node,$hash)=@_;
  return($node->{tag}=~/^Vs/
         and not first(sub{
                         $_->{tag}=~/^V/
                       },map{my$n=$hash->{$_};$n!=$node?$n:0}split /\|/,$node->{AIDREFS}
                      )
        )
}#isPassive_TR

=item isInfinitive_TR (node,aid_hash)

If the node is the head of an infinitive complex verb form, (based on
C<AIDREFS> information), return 1, else return 0.

=cut

sub isInfinitive_TR {
  $_[0]->{tag}=~/^V/ and not(&isFiniteVerb_TR or &isPassive_TR);
}#isInfinitive_TR

=item GetNewTrlemma (node?)

This function tries to guess the right trlemma of the node.

=cut

sub GetNewTrlemma {
  my$node=$_[0]||$this;
  return$node->{trlemma}if($node->{TID}and$node->{tag}eq'-')or($node==$root);
  my%specialEntity;
  %specialEntity=qw!. Period , Comma &amp; Amp - Hyphen / Slash ( Lpar ) Rpar
              ; Semicolon : Colon &ast; Ast &verbar; Verbar &percnt; Percnt
              !;
  my%specialLemma;
  my$lemma=$node->{lemma};
  if($lemma=~/^.*`([^0-9_-]+)/){
    $lemma=$1;
  }else{
    $lemma=~s/(.+?)[-_`].*$/$1/;
    if($lemma eq'svùj'){$lemma='se'}
    elsif($lemma=~/^(m|tv)ùj$/){
      if($1 eq'm'){
        $lemma=substr($node->{tag},6,1)eq'S'?'já':'my';
      }else{# $1 eq 'tv'
        $lemma=substr($node->{tag},6,1)eq'S'?'ty':'vy';
      }
    }elsif($lemma eq'já'){
      $lemma=substr($node->{tag},3,1)eq'S'?'já':'my';
    }elsif($lemma eq'ty'){
      $lemma=substr($node->{tag},3,1)eq'S'?'ty':'vy';
    }elsif($lemma eq'jeho'){$lemma='on'}
    $lemma="&$specialEntity{$lemma};"if exists$specialEntity{$lemma};
  }
  return$lemma;
}#GetNewTrlemma

=item modal_verb_trlemma (trlemma)

Return 1 if trlemma is a member of the list of all possible modal verb
trlemmas.

=cut

sub modal_verb_trlemma ($) {
  $_[0]=~/^(?:dát|dovést|hodlat|chtít|mít|moci|mus[ei]t|smìt|umìt)$/;
}#modal_verb_trlemmas

=item PDT::non_proj_edges($node,$only_visible?,$ord?,$filterNode?,$returnParents?,$subord?,$filterGap?)

Returns hash-ref containing all non-projective edges. Values of the
hash are references to arrays containing the non-projective edges (the
arrays contain the lower and upper nodes representing the edge, and
then the nodes causing the non-projectivity of the edge), keys are
concatenations of stringified references to lower and upper nodes of
non-projective edges. Description of the arguments is as follows:
$node specifies the root of a subtree to be checked for non-projective
edges; $only_visible set to true confines the subtree to visible
nodes; $ord specifies the ordering attribute to be used; a subroutine
accepting one argument passed as sub-ref in $filterNode can be used to
filter the edges taken into account (by specifying the lower nodes of
the edges); sub-ref $returnParents accepting one argument returns an
array of upper nodes of the edges to be taken into account; sub-ref
$subord accepting two arguments returns 1 iff the first one is
subordinated to the second one; sub-ref $filterGap accepting one
argument can be used to filter nodes causing non-projectivity.
Defaults are: all nodes, the default ordering attribute, all nodes,
parent (in the technical representation), subordination in the
technical sense, all nodes.

=cut

sub non_proj_edges {
# arguments are: root of the subtree to be projectivized
# switch whether projectivize only visible or all nodes
# the ordering attribute
# sub-ref to a filter accepting a node parameter (which nodes of the subtree should be skipped)
# sub-ref to a function accepting a node parameter returning a list of possible upper nodes
# on the edge from the node
# sub-ref to a function accepting two node parameters returning one iff the first one is
# subordinated to the second
# sub-ref to a filter accepting a node parameter for nodes in a potential gap

# returns a reference to a hash in which all non-projective edges are returned
# (keys being the lower nodes concatenated with the upper nodes of non-projective edges,
# values references to arrays containing the node, the parent and nodes in the respective gaps)


  my ($top,$onlyvisible,$ord,$filterNode,$returnParents,$subord,$filterGap) = @_;

  return undef unless ref($top);

  $ord = $grp->{FSFile}->FS->order() unless defined($ord);
  $filterNode = sub { 1 } unless defined($filterNode);
  $returnParents = sub { return $_[0]->parent ? ($_[0]->parent) : () } unless defined $returnParents;
  $subord = sub { my ($n,$top) = @_;
		  while ($n->parent and $n!=$top) {$n=$n->parent};
		  return ($n==$top) ? 1 : 0; # returns 1 if true, 0 otherwise
		} unless defined($subord);
  $filterGap = sub { 1 } unless defined($filterGap);

  my %npedges;

  # get the nodes of the subtree
  my @subtree = sort {$a->{$ord} <=> $b->{$ord}}
    ($onlyvisible ? $top->visible_descendants(FS()) : $top->descendants, $top);

  # just store the index in the subtree in a special attribute of each node
  for (my $i=0; $i<=$#subtree; $i++) {$subtree[$i]->{'_proj_index'} = $i}

  # now check all the edges of the subtree (but only those accepted by filterNode
  foreach my $node (grep {&$filterNode($_)} @subtree) {

    next if ($node==$top); # skip the top of the subtree

    foreach my $parent (&$returnParents($node)) {

      # span of the current edge
      my ($l,$r)=($node->{'_proj_index'}, $parent->{'_proj_index'});

      # set the boundaries of the interval covered by the current edge
      if ($l > $r) { ($l,$r) = ($r,$l) };

      # check all nodes covered by the edge
      for (my $j=$l+1; $j<$r; $j++) {

	my $gap=$subtree[$j]; # potential node in gap
	# mark a non-projective edge and save the node causing the non-projectivity (ie in the gap)
	if (not(&$subord($gap,$parent)) and &$filterGap($gap)) {
	  my $key=scalar($node).scalar($parent);
	  if (exists($npedges{$key})) { push @{$npedges{$key}}, $gap }
	  else { $npedges{$key} = [$node, $parent, $gap] };
	} # unless

      } # for $j

    } # foreach $parent

  } # foreach $node

  return \%npedges;

} # sub non_proj_edges


1;

=back

=cut
