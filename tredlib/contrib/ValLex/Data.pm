package TrEd::ValLex::Data;

use XML::DOM;
use Unicode::MapUTF8 qw(from_utf8);

sub toil2 {
  return from_utf8({-string => $_[0], -charset => 'ISO-8859-2'});
}

sub new {
  my ($self, $file)=@_;
  my $class = ref($self) || $self;
  my $parser = new XML::DOM::Parser(ParseParamEnt => 1);
  my $doc = $parser->parsefile ($file);
  my $new = bless [$parser,$doc,$file], $class;
}

sub parser {
  return undef unless ref($_[0]);
  return $_[0]->[0];
}

sub doc {
  return undef unless ref($_[0]);
  return $_[0]->[1];
}

sub file {
  return undef unless ref($_[0]);
  return $_[0]->[2];
}

# print all HREF attributes of all CODEBASE elements

sub getWordList {
  my ($self)=@_;
  my $doc=$self->doc();
  my @words=();
  my $words = $doc->getElementsByTagName ("word");
  my $n = $words->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $word = $words->item($i);
    my $id = $word->getAttribute ("word_ID");
    my $lemma = toil2($word->getAttribute ("lemma"));
    my $pos = $word->getAttribute ("POS");
    push @words, [$word,$id,$lemma,$pos];
  }
  return @words;
}

sub getFrameList {
  my ($self,$word)=@_;
  my @frames=();
  my $frames = $word->getElementsByTagName("frame");
  my $n = $frames->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $frame = $frames->item($i);
    my $id = $frame->getAttribute ("frame_ID");
    my $status = $frame->getAttribute ("status");
    my $elements = $self->getFrameElementString($frame);
    my $example=$self->getFrameExample($frame);
    push @frames, [$frame,$id,$elements,$status,$example];
  }
  return @frames;
}

sub getFrameElementString {
  my ($self,$frame)=@_;
  my @elements;
  my $elements = $frame->getElementsByTagName("element");
  my $n = $elements->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $element = $elements->item($i);
    my $functor = $element->getAttribute ("functor");
    my $type = $element->getAttribute("type");
    my $forms = $self->getFrameElementFormsString($element);
    push @elements,$functor.($type eq "oblig" ? "[$forms]" : "($forms)");
  }
  return join "  ",@elements;
}

sub getFrameElementFormsString {
  my ($self,$element)=@_;
  my @forms;
  my $forms = $element->getElementsByTagName("form",0);
  my $n = $forms->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $form = $forms->item($i);
    my $tag = $form->getAttribute ("tag");
    my $preposition = toil2($form->getAttribute("preposition"));
    my $clause = toil2($form->getAttribute("clause"));
    $tag=~s/\.//g;
    if ($clause ne "") {
      push @forms,"$clause";
    } else {
      push @forms,"$preposition".($tag ne "" ? "+$tag" : "");
    }
  }
  return join ",",@forms;
}

sub getFrameExample {
  my ($self,$frame)=@_;
  $frame->normalize();
  my $text=$frame->getElementsByTagName("example",0)->item(0)->getFirstChild;
  if ($text->getNodeType == TEXT_NODE) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/;\s+/\n/g;
    return toil2($data);
  }
  return "";
}

sub getElementText {
  my ($self,$element)=@_;
  $element->normalize();
  my $text=$element->getFirstChild;
  if ($text->getNodeType == TEXT_NODE) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    return toil2($data);
  }
}

sub getSubElementNote {
  my ($self,$elem)=@_;
  $elem->normalize();
  my $note=$elem->getElementsByTagName("note",0)->item(0);
  return "" unless $note;
  my $text=$note->getFirstChild;
  if ($text->getNodeType == TEXT_NODE) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/;\s+/\n/g;
    return toil2($data);
  }
}

sub getSubElementProblemsList {
  my ($self,$elem)=@_;
  my @problems=();
  my $problems_e=$elem->getElementsByTagName("problems",0)->item(0);
  return "" unless $problems_e;
  my $problems = $problems_e->getElementsByTagName ("problem",0);
  my $n = $problems->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $problem = $problems->item($i);
    my $author = toil2($problem->getAttribute ("author"));
    my $solved = $problem->getAttribute ("solved");
    my $text = $self->getElementText($problem);
    push @problems, [$problem,$text,$author,$solved];
  }
  return @problems;
}

sub findWord {
  my ($self,$find)=@_;
  my $doc=$self->doc();
  my $words = $doc->getElementsByTagName ("word");
  my $n = $words->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $word = $words->item($i);
    my $lemma = toil2($word->getAttribute ("lemma"));
    return $word if $lemma eq $find;
  }
  return undef;
}

sub generateNewWordId {
  my ($self)=@_;
  my $i=0;
  foreach ($self->getWordList) {
    if ($_->[1]=~/^w-([0-9]+)$/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  return "w-$i";
}

sub addWord {
  my ($self,$word,$pos)=@_;
  return unless
  my $new_id = $g
}

1;
