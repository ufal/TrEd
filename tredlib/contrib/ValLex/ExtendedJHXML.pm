# -*- cperl -*-

package TrEd::ValLex::ExtendedJHXML;
use ValLex::Extended;
use ValLex::JHXMLData;
use base qw(TrEd::ValLex::Extended TrEd::ValLex::JHXMLData);

sub remove_node {
  my ($self, $node) = @_;
  if ($node->parentNode) {
    $node->parentNode->removeChild($node);
  }
  $node->destroy();
}

sub clone_frame {
  my ($self,$frame)=@_;
  my $str = $frame->toString();
  $str = '<?xml version="1.0" encoding="utf-8"?>'."\n".$str;
  my $p = XML::JHXML->new();
  $p->keep_blanks(-1);
  return $p->parse_string($str)->documentElement;
}

sub addWord {
  print "Called extended addWord\n";
  my $self = shift;
  my $word = $self->SUPER::addWord(@_);
  if ($word) {
    $self->[8]->{ $word->getAttribute('word_ID') } = $word if ref($self->[8]);
    $self->[9]->{ $word->getAttribute('lemma') } = $word if ref($self->[9]);
  }
  return $word;
}

sub addFrame {
  print "Called extended addFrame\n";
  my $self = shift;
  my $frame = $self->SUPER::addFrame(@_);
  $self->[8]->{ $frame->getAttribute('frame_ID') } = $frame if $frame and ref($self->[8]);
  return $frame;
}


1;
