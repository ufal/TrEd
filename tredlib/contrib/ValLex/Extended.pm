# -*- cperl -*-

package TrEd::ValLex::Extended;
use ValLex::LibXMLData;
use base qw(TrEd::ValLex::LibXMLData);

sub by_id {
  my ($self,$id)=@_;
  return $self->doc->findnodes("id('$id')")->[0];
}

sub word {
  my ($self,$lemma,$pos)=@_;
  return $self->doc->findnodes(qq(/valency_lexicon/body/word[\@lemma="$lemma" and \@POS="$pos"]))->[0];
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
  return $frame->findnodes(q{frame_elements/element[@type='oblig' and @functor!='---']})
}

sub nonoblig {
  my ($self,$frame)=@_;
  return $frame->findnodes(q{frame_elements/element[@type='non-oblig' and @functor!='---']})
}

sub word_form {
  my ($self,$frame)=@_;
  my @wf = $frame->findnodes(q{frame_elements/element[@functor='---']});
  return wantarray ? @wf : $wf[0];
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

sub remove_node {
  my ($self, $node) = @_;
  $node->unbindNode();
}

sub split_serialized_forms {
  my ($self,$forms)=@_;
  return $forms =~ m/\G((?:\\.|[^\\;]+)+)(?:;|$)/g;
}

sub new_frame_element {
  my ($self, $frame, $functor,$type) = @_;
  my ($elems)=$frame->getChildElementsByTagName("frame_elements");
  my $el = $self->doc()->createElement('element');
  $elems->appendChild($el);
  $el->setAttribute('functor',$functor);
  $el->setAttribute('type',($type eq "?" or $type eq "non-oblig") ? 'non-oblig' : 'oblig');
  return $el;
}

sub new_element_form {
  my ($self, $eldom, $form)=@_;

  my $formdom = $self->doc()->createElement('form');
  $eldom->appendChild($formdom);
  do {{
    $form = $self->parseFormPart($form,0,$formdom);
  }} while ($form =~ s/^,//);
  if ($form ne "") { die "Unexpected tokens near '$form'\n" }
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
  return TrEd::ValLex::Data::serializeForm($node);
}

1;
