# -*- cperl -*-

package Vallex;
use base qw(TredMacro);
import TredMacro;

sub new {
  my ($class,$url,$validate)=@_;
  $class = ref($class) if ref($class);
  return bless [$class->load($url,$validate)], $class;
}

sub load {
  my ($self,$url,$validate)=@_;
  require XML::LibXML;
  my $parser = XML::LibXML->new;
  if ($validate) {
    $parser->validation(1);
    $parser->load_ext_dtd(1);
    $parser->expand_entities(1);
  } else {
    $parser->validation(0);
    $parser->load_ext_dtd(0);
    $parser->expand_entities(0);
  }
  my $doc = $parser->parse_file($url);
  $doc->indexElements() if ref($doc) and $doc->can('indexElements');
  return $doc;
}

sub doc { $_[0]->[0] }

sub by_id {
  my ($self,$id)=@_;
  return $self->doc->findnodes(qq(id('$id')))->[0];
}

sub word {
  my ($self,$lemma)=@_;
  return $self->doc->findnodes(qq(/valency_lexicon/body/word[\@lemma="$lemma"]))->[0];
}

sub frames {
  my ($self,$word,$cond)=@_;
  return $word->findnodes(qq(valency_frames/frame${cond}));
}

sub is_valid_frame {
  my ($self,$frame)=@_;
  return ($frame->getAttribute('status')=~/^active$|^reviewed$/);
}

sub valid_frames {
  my ($self,$word)=@_;
  return $word->findnodes(qq(valency_frames/frame[\@status='active' or \@status='reviewed']));
}

sub frame_status {
  my ($self,$frame)=@_;
  return $frame->getAttribute('status');
}

sub frame_id {
  my ($self,$frame)=@_;
  return $frame->getAttribute('frame_ID');
}

sub valid_frame_for {
  my ($self,$frame)=@_;
  my $with;
  while ($with=$frame->getAttribute('substituted_with')) {
    $frame=$self->by_id($with);
  }
  if ($self->is_valid_frame($frame)) {
    return $frame;
  } else {
    return undef;
  }
}

sub elements {
  my ($self,$frame)=@_;
  return $frame->findnodes(q{frame_elements/element})
}

sub oblig {
  my ($self,$frame)=@_;
  return $frame->findnodes(q{frame_elements/element[@type='oblig']})
}

sub nonoblig {
  my ($self,$frame)=@_;
  return $frame->findnodes(q{frame_elements/element[@type='non-oblig']})
}

sub func {
  my ($self,$e)=@_;
  return $e->getAttribute('functor');
}

sub forms {
  my ($self,$element)=@_;
  return map { $_->value } $element->findnodes(q{form/@abbrev});
}
