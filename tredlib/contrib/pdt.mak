# -*- cperl -*-
# Miscelaneous macros of general use in Prague Dependency Treebank

#
# Save structure to given attribute
#
package PDT;
use base qw(TredMacro);
import TredMacro;


sub is_noun {
  return $_[0]->{tag}=~/^N../;
}

sub is_verb {
  return $_[0]->{tag}=~/^V../;
}

sub is_coord {
  my ($node)=@_;
  return $node->{afun} =~ /^Coord/;
}

sub is_coord_TR {
  my ($node)=@_;
  return $node->{func} =~ /^(?:CONJ|DISJ|GRAD|ADVS|CSQ|REAS)$/;
}

sub is_apos {
  my ($node)=@_;
  return $node->{afun} eq '^Apos';
}

sub is_apos_TR {
  my ($node)=@_;
  return $node->{func} eq 'APPS';
}

sub is_pronoun_possessive {
  my ($node)=@_;
  return $node->{tag}=~/^PS../;
}


#
# if the given node is coordination or aposition expand it to a list
# of coordinated nodes. if the second argument is true, preserves the
# coordination/aposition node in the list too.
#

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


#
# Save governing node's ord to given attribute
#

sub saveTreeStructureToAttr {
  my ($class,$atr,$top)=@_;
  $top||=$root;

  my $node=$top->following;
  while ($node) {
    $node->{$atr}=$node->parent->{ord};
    $node=$node->following($top);
  }
}

#
# Save (annalytical) structure to ordorig
#

sub saveTreeAStructure {
  my $class=$_[0];
  saveTreeStructureToAttr($class,"ordorig");
}

#
# Save (tectogrammatical) structure to govTR
#

sub saveTreeTStructure {
  my $class=$_[0];
  saveTreeStructureToAttr($class,"govTR");
}

#
# Substitute a new header for current document
#

sub substituteFSHeader {
  my $class=shift;
  $grp->{FSFile}->changeFS(FSFormat->create(@_));
}

#
# Assign default TR header to current document
#

sub assignTRHeader {
  my $class=$_[0];
  substituteFSHeader($class,@Csts2fs::TRheader);
}

#
# Assign default AR header to current document
#

sub assignARHeader {
  my $class=$_[0];
  substituteFSHeader($class,@Csts2fs::ARheader);
}

#
# Append FS declarations to current file's FS format
# (little bit a hack)

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

#
# Convert current FS header to Tectogrammatical header
#

sub convertToTRHeader {
  my $class=$_[0];
  appendFSHeader($class,@Csts2fs::TRheader);
}

#
# Convert current FS header to Analytical header
#

sub convertToARHeader {
  my $class=$_[0];
  appendFSHeader($class,@Csts2fs::ARheader);
}

#
# Prepare current FS file to be saved as TR file
#

sub file2TR {
  my $class=$_[0];
  convertToTRHeader($class);
  GotoTree(1);
  do {
    saveTreeAStructure($class);
  } while NextTree();
  GotoTree(1);
}

#
# Copy {tag,lemma}MD_<src> to tag,lemma for given tree
#

sub MD2TagLemma {
  my ($class,$src,$top)=@_;
  $top||=$root;
  $src='a' unless defined $src;
  return if $src eq "";
  my $node=$root;
  while ($node) {
    $node->{lemma}=$node->{"lemmaMD_$src"};
    $node->{tag}=$node->{"tagMD_$src"};
    $node=$node->following($top);
  }
  $root->{tag}||='Z#-------------';
  $root->{lemma}||='#';
}

#
# Delete values of lemma and tag attributes in ghe given tree
#

sub delTagLemma {
  my ($class,$top)=@_;
  $top||=$root;
  my $node=$root;
  while ($node) {
    $node->{lemma}=$node->{tag}='';
    $node=$node->following($top);
  }
}

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
