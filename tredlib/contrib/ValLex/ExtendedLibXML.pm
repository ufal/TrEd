# -*- cperl -*-

package TrEd::ValLex::ExtendedLibXML;
use ValLex::Extended;
use ValLex::LibXMLData;
use base qw(TrEd::ValLex::Extended TrEd::ValLex::LibXMLData);

sub by_id {
  my ($self,$id)=@_;
  return wantarray ? $self->doc->findnodes("id('$id')") : $self->doc->findnodes("id('$id')")->[0];
}

sub word {
  my ($self,$lemma,$pos)=@_;
  return $self->doc->findnodes(qq(/valency_lexicon/body/word[\@lemma="$lemma" and \@POS="$pos"]))->[0];
}

sub remove_node {
  my ($self, $node) = @_;
  $node->unbindNode();
}

sub clone_frame {
  my ($self,$frame)=@_;
  return $frame->cloneNode(1);
}

1;
