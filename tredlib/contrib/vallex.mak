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
  return $self->doc->findnodes("id('$id')")->[0];
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
  return $frame->getAttribute('id');
}

sub valid_frame_for {
  my ($self,$frame)=@_;
  my $with;
  while ($frame and ($with=$frame->getAttribute('substituted_with')) ne "") {
    $frame=$self->by_id($with);
  }
  if ($frame and $self->is_valid_frame($frame)) {
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
  return $element->findnodes('form');
}

sub frame_word {
  my ($self,$frame) = @_;
  return $frame->findnodes(qw{(ancestor::word)[1]})->[0];
}

sub word_lemma {
  my ($self,$word) = @_;
  return $word->getAttribute("lemma");
}


sub serialize_element {
  my ($self,$element)=@_;

  my $functor = $element->getAttribute ("functor");
  my $type = $element->getAttribute("type");
  my $forms = $self->serialize_forms($element);
  return ($type eq "oblig" ? "" : "?")."$functor($forms)";
}

sub serialize_frame {
  my ($self,$frame)=@_;
  return unless $frame;
  my @elements;
  my @element_nodes=$self->elements($frame);

  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'oblig' }
			@element_nodes)
		      ) {
    push @elements,$self->serialize_element($element);
  }
  push @elements, "  " if @elements;
  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'non-oblig' }
			@element_nodes
		       )
		      ) {
    push @elements,$self->serialize_element($element);
  }
  if (@elements) {
    return join("  ", @elements);
  } else {
    return "EMPTY";
  }
}

sub serialize_forms {
  my ($self,$element)=@_;
  return unless $element;
  my @forms;
  foreach my $form ($element->findnodes("form")) {
    push @forms,$self->serialize_form($form);
  }
  return join ";",@forms;
}

sub serialize_form {
  my ($self,$node)=@_;
  if ($node->nodeName() eq 'form') {
    if ($node->findnodes('elided')) {
      return "!";
    } elsif ($node->findnodes('typical')) {
      return "*";
    } elsif ($node->findnodes('state')) {
      return "=";
    } elsif ($node->findnodes('recip')) {
      return "%";
    } else {
      return join(",",map { $self->serialize_form($_) } grep { defined }
		  $node->findnodes('parent'),$node->findnodes('node'));
    }
  } elsif ($node->nodeName() eq 'parent') {
    return "^".join(",",map { $self->serialize_form($_) }
		    $node->findnodes('node'));
  } else {
    my $ret = $node->getAttribute('lemma');
    my $morph = join "",map { $node->getAttribute($_) } qw(pos gen num case);
    $morph.='@'.$node->getAttribute('deg') if $node->getAttribute('deg') ne "";
    $morph.='#' if $node->getAttribute('agreement') == 1;
    my $inherits = $node->getAttribute('inherits');
    $ret.=($inherits==1 ? '.' : ':').$morph if ($inherits==1 or $morph ne "");
    if ($node->findnodes('node')) {
      $ret.="[".join(",",map { $self->serialize_form($_) } $node->findnodes('node'))."]";
    }
    return $ret;
  }
}
