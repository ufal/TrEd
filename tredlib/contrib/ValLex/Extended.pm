# -*- cperl -*-

package TrEd::ValLex::Extended;

sub user_cache {
  $self->[10] = {} unless defined($self->[10]);
  return $self->[10];
}

sub doc_free {
  my ($self)=@_;
  %{$self->user_cache}=();
  $self->TrEd::ValLex::Data::doc_free;
}

sub _index_by_id {
  my ($self)=@_;
  my $word = $self->getFirstWordNode();
  while ($word) {
    $self->[8]->{$word->getAttribute('word_ID')}=$word;
    foreach my $frame ($self->getFrameNodes($word)) {
      $self->[8]->{$frame->getAttribute('frame_ID')}=$frame;
    }
    $word = $word->findNextSibling('word');
  }
}

sub _index_by_lemma {
  my ($self)=@_;
  my $word = $self->getFirstWordNode();
  while ($word) {
    push @{$self->[9]->{$word->getAttribute('lemma')}},$word;
    $word = $word->findNextSibling('word');
  }
}

sub by_id {
  my ($self,$id)=@_;
  $self->_index_by_id() unless (ref($self->[8]));
  my @result = grep {defined($_)} map { $self->[8]->{$_} } split /\s+/,$id;
  return wantarray ? @result : $result[0];
}

sub word {
  my ($self,$lemma,$pos)=@_;
  $self->_index_by_lemma() unless ($self->[9]);
  my $words = $self->[9]->{$lemma};
  return unless ref($words);
  return (grep { $_->getAttribute('POS') eq $pos } @$words)[0];
}

sub is_valid_frame {
  my ($self,$frame)=@_;
  return ($frame->getAttribute('status')=~/^active$|^reviewed$/);
}

sub valid_frames {
  my ($self,$word)=@_;
  return
    grep { $_->getAttribute('status') eq 'active' or
    		$_->getAttribute('status') eq 'reviewed'
    	      }
    $self->getFrameNodes($word);
}

sub frame_status {
  my ($self,$frame)=@_;
  return $frame->getAttribute('status');
}

sub frame_id {
  my ($self,$frame)=@_;
  return $frame->getAttribute('frame_ID');
}

sub _uniq { my %a; @a{@_}=@_; values %a }
sub valid_frames_for {
  my ($self,$frame)=@_;
  my $with;
  my @frames = ($frame);
  my @resolve;
  my %resolved;

#  print "Start: ",$self->frame_id($frame),"\n";
  while (@resolve = grep { $_->getAttribute('substituted_with') ne "" } @frames) {
#    foreach (@resolve) {
#      print "resolving ",$self->frame_id($_)," to ",$_->getAttribute('substituted_with'),"\n";
#    }
    @resolved{map { $self->frame_id($_) } @resolve} = ();
    @frames = _uniq grep { !exists($resolved{$self->frame_id($_)}) } (@frames, map { $self->by_id($_->getAttribute('substituted_with')) } @resolve);
#    print "resolve: ",join(" ",map { $self->frame_id($_) } @resolve),"\n";
#    @frames = (@frames, map { $self->by_id($_->getAttribute('substituted_with')) } @resolve);
#    print "Step1: ",join(" ",map { $self->frame_id($_) } @frames),"\n";
#    @frames = grep { !exists($resolved{$self->frame_id($_)}) } @frames;
#    print "Step2: ",join(" ",map { $self->frame_id($_) } @frames),"\n";
#    @frames = _uniq @frames;
#    print "Step3: ",join(" ",map { $self->frame_id($_) } @frames),"\n";
  }
#  print "Result: ",join(" ",map { $self->frame_id($_) } grep { $self->is_valid_frame($_) } @frames),"\n";
  return grep { $self->is_valid_frame($_) } @frames;
}

sub elements {
  my ($self,$frame)=@_;
  my $fe = $frame->findFirstChild('frame_elements');
  return unless $fe;
  return $fe->getChildrenByTagName('element');
}

sub oblig {
  my ($self,$frame)=@_;
  my $fe = $frame->findFirstChild('frame_elements');
  return unless $fe;
  return grep { $_->getAttribute('type') eq 'oblig' and
		  $_->getAttribute('functor') ne '---'
	      } $fe->getChildrenByTagName('element');
}

sub nonoblig {
  my ($self,$frame)=@_;
  my $fe = $frame->findFirstChild('frame_elements');
  return unless $fe;
  return grep { $_->getAttribute('type') eq 'non-oblig' and
		  $_->getAttribute('functor') ne '---'
	      } $fe->getChildrenByTagName('element');
}

sub word_form {
  my ($self,$frame)=@_;
  my $fe = $frame->findFirstChild('frame_elements');
  return unless $fe;
  my @wf = grep { $_->getAttribute('functor') eq '---'
	      } $fe->getChildrenByTagName('element');
  return wantarray ? @wf : $wf[0];
}

sub func {
  my ($self,$e)=@_;
  return $e->getAttribute('functor');
}

sub forms {
  my ($self,$element)=@_;
  return $element->getChildrenByTagName('form');
}

sub frame_word {
  my ($self,$frame) = @_;
  return $frame->parentNode->parentNode;
}

sub word_lemma {
  my ($self,$word) = @_;
  return $word->getAttribute("lemma");
}

sub remove_node {
  my ($self, $node) = @_;
  if ($node->parentNode) {
    $node->parentNode->removeChild($node);
  }
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
  foreach my $form ($element->getChildElementsByTagName("form")) {
    push @forms,$self->serialize_form($form);
  }
  return join ";",@forms;
}

sub serialize_form {
  my ($self,$node)=@_;
  return TrEd::ValLex::Data::serializeForm($node);
}


sub clone_frame {}

1;

