package Assign_slovene_afun;

use Fslib;

use strict;

sub adjective { return $_[0]->{tag}=~/^A/ }
sub adverb { return $_[0]->{tag}=~/^R/ }
sub adjectival { return $_[0]->{tag}=~/^(A|Ps|M[oc]|P.........a)/ }
sub noun { return $_[0]->{tag}=~/^N/ }
sub personal_pronoun { return $_[0]->{tag}=~/^Pp/ } #ZO
sub preposition { return ($_[0]->{tag}=~/^S/ or $_[0]->{lemma} eq "kot")}
sub subordinating_conjunction { return $_[0]->{tag}=~/^Css/ }
sub relative_pronoun { return $_[0]->{tag}=~/^Pr/ }


sub effective_parent {
  my ($node)=@_;
  my $parent=$node->parent();
  while ($parent->{lemma}=~/^(,|in)$/) {$parent=$parent->parent()};
  return $parent;
}


sub afuns_to_tree {
  print  "testik testik\n";
  my ($root)=@_;
  foreach my $node (grep {$_->{afun}} $root->descendants()) {
    my $tag=$node->{tag};
    my $eparent=effective_parent($node);
    my $eparent_tag=$eparent->{tag};
    my $afun;
    if (!$eparent->parent() and $tag=~/^V/) {$afun="Pred"}
    elsif ($node->{lemma} eq ".") {$afun="AuxK"}
    elsif (adjective($node) and $eparent->{lemma} eq "biti") {$afun="Pnom"}
    elsif (adjectival($node) or noun($eparent)) {$afun='Atr'}
    elsif (preposition($node)) {$afun='AuxP'}
    elsif ($tag=~/^(P....n....n|N...n)/ and $eparent_tag=~/^V/) {$afun='Sb'}
    elsif ($tag=~/^(P....[^n]....n|N...[^n])/ and $eparent_tag=~/^V/) {$afun='Obj'}
    elsif ($tag=~/^(P.........n|N)/ and preposition($eparent)) {$afun='Adv'}
    elsif ($tag=~/^R/) {$afun='Adv'}
    elsif ($node->{lemma} eq "in" or $tag=~/^Ccs/) {$afun="Coord"}
    elsif ($node->{lemma} eq ",") {
      if ($node->children()) {$afun='Coord'}
      else {$afun='AuxX'}
    }
    elsif ($tag=~/^Vc/ and $eparent_tag=~/V/) {$afun="AuxV"}
    elsif ($tag=~/^Css/) {$afun='AuxC'}
    elsif ($tag=~/^V.n/) {$afun='Obj'}
    $afun='???' unless $afun;
    $node->{afun}=$afun;
  }
}

1;
