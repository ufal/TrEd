##############################################
# TrEd::ValLex::Data
##############################################

package TrEd::ValLex::Data;
use strict;

sub new {
  my ($self, $file, $cpconvert)=@_;
  my $class = ref($self) || $self;
  my $new = bless [$class->parser_start($file),
		   $file, undef, undef, 0, $cpconvert, []], $class;
  $new->loadListOfUsers();
  return $new;
}

sub conv {
  return $_[0]->[6];
}

sub clients {
  return $_[0]->[7];
}

sub changed {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[5];
}

sub set_change_status {
  my ($self,$status)=@_;
  return undef unless ref($self);
  $self->[5]=$status;
}

sub dispose_node {
}

sub save {
}

sub doc_reload {
}

sub doc_free {
  my ($self)=@_;
  $self->make_clients_forget_data_pointers();
  $self->dispose_node($self->doc());
  $self->set_doc(undef);
}

sub reload {
  my ($self)=@_;
  return unless $self->parser();
  $self->doc_free();
  $self->doc_reload();
  $self->loadListOfUsers();
  $self->set_change_status(0);
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

sub user {
  my ($self)=@_;
  return undef unless ref($_[0]);
  return $self->doc()->getDocumentElement->getAttribute("owner");
}

sub set_file {
  return undef unless ref($_[0]);
  return $_[0]->[2]=$_[1];
}

sub set_user {
  return undef unless ref($_[0]);
  return $_[0]->[3]=$_[1];
}

sub set_doc {
  return undef unless ref($_[0]);
  return $_[0]->[1]=$_[1];
}

sub set_parser {
  return undef unless ref($_[0]);
  return $_[0]->[0]=$_[1];
}

sub get_user_info {
  my ($self,$user)=@_;
  return exists($self->[4]->{$user}) ? $self->[4]->{$user} : ["unknown user",0,0];
}

sub user_is_reviewer {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[2];
}

sub user_is_annotator {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[1];
}

sub getUserName {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->conv->decode($self->get_user_info($self->user())->[0]);
}

sub loadListOfUsers {
  my ($self)=@_;
  my $users = {};
  return undef unless ref($self);
  my $doc=$self->doc();
  my ($head)=$doc->getDocumentElement()->getChildElementsByTagName("head");
  if ($head) {
    my ($list)=$head->getChildElementsByTagName("list_of_users");
    if ($list) {
      foreach my $user ($list->getChildElementsByTagName("user")) {
	$users->{$user->getAttribute("user_ID")} =
	  [
	   $user->getAttribute("name"),
	   $user->getAttribute("annotator") eq "YES",
	   $user->getAttribute("reviewer") eq "YES"
	  ]
      }
    }
  }
  $self->[4]=$users;
}

sub getWordList {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my @words=();
  my $docel=$doc->getDocumentElement();
  foreach my $word ($docel->getDescendantElementsByTagName ("word")) {
    my $id = $word->getAttribute ("word_ID");
    my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
    my $pos = $word->getAttribute ("POS");
    push @words, [$word,$id,$lemma,$pos];
  }
  return @words;
}

sub getFrameList {
  my ($self,$word)=@_;
  return unless $word;
  my @frames=();
  foreach my $frame ($word->getDescendantElementsByTagName("frame")) {
    my $id = $frame->getAttribute ("frame_ID");
    my $status = $frame->getAttribute ("status");
    my $elements = $self->getFrameElementString($frame);
    my $example=$self->getFrameExample($frame);
    my ($local_event)=$frame->getDescendantElementsByTagName("local_event");
    my $auth="NA";
    $auth=$self->conv->decode($local_event->getAttribute("author")) if ($local_event);
    push @frames, [$frame,$id,$elements,$status,$example,$auth];
  }
  return @frames;
}

sub getFrameElementString {
  my ($self,$frame)=@_;
  return unless $frame;
  my @elements;
  foreach my $element ($frame->getDescendantElementsByTagName("element")) {
    my $functor = $element->getAttribute ("functor");
    my $type = $element->getAttribute("type");
    my $forms = $self->getFrameElementFormsString($element);
    push @elements,$functor.($type eq "oblig" ? "($forms)" : "[$forms]");
  }
  return join "  ",@elements;
}

sub getFrameElementFormsString {
  my ($self,$element)=@_;
  return unless $element;
  my @forms;
  foreach my $form ($element->getChildElementsByTagName("form")) {
    my $abbrev = $self->conv->decode($form->getAttribute ("abbrev"));
    push @forms,"$abbrev";
  }
  return join ",",@forms;
}

sub getFrameExample {
  my ($self,$frame)=@_;
  return unless $frame;
  $self->normalize_ws($frame);
  my ($example)=$frame->getChildElementsByTagName("example");
  if ($example) {
    my $text=$example->getFirstChild;
    if ($text and $text->isTextNode) {
      my $data=$text->getData();
      $data=~s/^\s+//;
      $data=~s/;\s+/\n/g;
      $data=~s/[\s\n]+$//g;
      return $self->conv->decode($data);
    }
  }
  return "";
}

sub getElementText {
  my ($self,$element)=@_;
  return unless $element;
  $self->normalize_ws($element);
  my $text=$element->getFirstChild;
  if ($text and $text->isTextNode) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/[\s\n]+$//g;
    return $self->conv->decode($data);
  }
  return "";
}

sub getSubElementNote {
  my ($self,$elem)=@_;
  return unless $elem;
  $self->normalize_ws($elem);
  my ($note)=$elem->getChildElementsByTagName("note");
  return "" unless $note;
  my $text=$note->getFirstChild;
  if ($text and $text->isTextNode) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/;\s+/\n/g;
    $data=~s/[\s\n]+$//g;
    return $self->conv->decode($data);
  }
  return "";
}

sub getSubElementProblemsList {
  my ($self,$elem)=@_;
  return unless $elem;
  my @problems=();
  my ($problems_e)=$elem->getChildElementsByTagName("problems");
  return "" unless $problems_e;
  foreach my $problem ($problems_e->getChildElementsByTagName("problem")) {
    my $author = $self->conv->decode($problem->getAttribute ("author"));
    my $solved = $problem->getAttribute ("solved");
    my $text = $self->getElementText($problem);
    push @problems, [$problem,$text,$author,$solved];
  }
  return @problems;
}

sub findWord {
  my ($self,$find,$nearest)=@_;
  print "find $find $nearest\n";
  my $doc=$self->doc();
  print "find $find $nearest\n";
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  foreach my $word ($docel->getDescendantElementsByTagName("word")) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    print "found $lemma\n";
    return $word if (($nearest and index($lemma,$find)==0) or $lemma eq $find);
  }
  return undef;
}

sub findWordAndPOS {
  my ($self,$find,$pos)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  foreach my $word ($docel->getDescendantElementsByTagName("word")) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    my $POS = $self->conv->decode($word->getAttribute ("POS"));
    return $word if ($lemma eq $find and $POS eq $pos);
  }
  return undef;
}

sub generateNewWordId {
  my ($self,$lemma,$pos)=@_;
  my $i=0;
  foreach ($self->getWordList) {
    return undef if ($_->[2] eq $lemma and $_->[3] eq $pos);
    if ($_->[1]=~/^w-([0-9]+)/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  return "w-$i-".$self->user;
}

sub addWord {
  my ($self,$lemma,$pos)=@_;
  return unless $lemma ne "";
  my $new_id = $self->generateNewWordId($lemma,$pos);
  return unless defined($new_id);

  my $doc=$self->doc();
  my $root=$doc->getDocumentElement();
  my ($body)=$root->getChildElementsByTagName("body");
  return unless $body;
  my $word=$doc->createElement("word");
  $word->setAttribute("lemma",$self->conv->encode($lemma));
  $word->setAttribute("POS",$pos);
  $word->setAttribute("word_ID",$new_id);
  $body->appendChild($word);

  my $valency_frames=$doc->createElement("valency_frames");
  $word->appendChild($valency_frames);
  $self->set_change_status(1);
  return $word;
}

sub addFrameLocalHistory {
  my ($self,$frame,$type)=@_;
  return unless $frame;
  my $doc=$self->doc();

  my ($local_history)=$frame->getChildElementsByTagName("local_history");
  unless ($local_history) {
    $local_history=$doc->createElement("local_history");
    $frame->appendChild($local_history);
  }

  my $local_event=$doc->createElement("local_event");
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  $local_event->setAttribute("timestamp",sprintf('%d.%d.%d %02d:%02d:%02d',
						 $mday,$mon,1900+$year,$hour,$min,$sec));
  $local_event->setAttribute("type_of_event",$type);
  $local_event->setAttribute("author",$self->user());
  $local_history->appendChild($local_event);
  $self->set_change_status(1);
  return $local_event;
}

sub changeFrameStatus {
  my ($self,$frame,$status,$action)=@_;
  $frame->setAttribute('status',$status);
  $self->addFrameLocalHistory($frame,$action);
  $self->set_change_status(1);
}

sub substituteFrame {
  my ($self,$word,$frame,$elements,$note,$example,$problem)=@_;
  return unless $frame;
  my $new=$self->addFrame($frame,$word,$elements,$note,$example,$problem,$self->user());
  $self->changeFrameStatus($frame,"substituted","obsolete");
  my $subst=$frame->getAttribute("substituted_with");
  my $new_id=$new->getAttribute("frame_ID");
  $subst= $subst eq "" ? $new_id : "$subst $new_id";
  $frame->setAttribute("substituted_with",$subst);
  $self->set_change_status(1);
  return $new;
}

sub generateNewFrameId {
  my ($self,$word)=@_;
  my $i=0;
  my $w=0;
  my $wid=$word->getAttribute("word_ID");
  $w=$1 if ($wid=~/^w-([0-9]+)/);
  foreach ($self->getFrameList($word)) {
    if ($_->[1]=~/^f-$w-([0-9]+)/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  return "f-$w-$i-".$self->user;
}

sub addForms {
  my ($self, $elem,$string)=@_;
  my $doc=$self->doc();
  foreach my $f (split /,/, $string) {
    my $form=$doc->createElement("form");
    $form->setAttribute("abbrev",$f);
    $elem->appendChild($form);
  }
  $self->set_change_status(1);
}

sub addFrameElements {
  my ($self,$elems,$elements)=@_;
  my $doc=$self->doc();
  foreach (split /\s+/,$elements) {
    if (/^([A-Z0-9]+)([[(])?([^])]*)[])]?/) {
      my $elem=$doc->createElement("element");
      $elem->setAttribute("functor",$1);
      if ($2 eq '(') {
	$elem->setAttribute("type","oblig");
      }
      $self->addForms($elem,$3);
      $elems->appendChild($elem);
    }
  }
  $self->set_change_status(1);
}

sub addFrame {
  my ($self,$before,$word,$elements,$note,$example,$problem,$author)=@_;
  return unless $word and $elements ne "";
  my $new_id = $self->generateNewFrameId($word);
  my $doc=$self->doc();
  my ($valency_frames)=$word->getChildElementsByTagName("valency_frames");
  return unless $valency_frames;
  my $frame=$doc->createElement("frame");
  $frame->setAttribute("frame_ID",$new_id);
  $frame->setAttribute("status","active");
  if (ref($before)) {
    $valency_frames->insertBefore($frame,$before);
  } else {
    $valency_frames->appendChild($frame);
  }
  my $ex=$doc->createElement("example");
  $ex->addText($self->conv->encode($example));
  $frame->appendChild($ex);

  if ($note ne "") {
    my $not=$doc->createElement("note");
    $not->addText($self->conv->encode($note));
    $frame->appendChild($not);
  }

  if ($problem ne "") {
    my $problems=$doc->createElement("problems");
    $frame->appendChild($problems);

    my $probl=$doc->createElement("problem");
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
    $problems->appendChild($probl);
  }

  my $elems=$doc->createElement("frame_elements");
  $self->addFrameElements($elems,$elements);

  $frame->appendChild($elems);
  $self->addFrameLocalHistory($frame,"create");
  $self->set_change_status(1);
  return $frame;
}

sub modifyFrame {
  my ($self,$frame,$elements,$note,$example,$problem,$author)=@_;
  return unless $frame and $elements ne "";

  my $doc=$self->doc();
  my ($old_ex)=$frame->getChildElementsByTagName("example");
  my $ex=$doc->createElement("example");
  $ex->addText($self->conv->encode($example));
  if ($old_ex) {
    $frame->replaceChild($ex,$old_ex);
    $self->dispose_node($old_ex);
  } else {
    $frame->insertBefore($ex,undef);
  }
  undef $old_ex;

  my ($old_note)=$frame->getChildElementsByTagName("note");
  if ($note ne "") {
    my $not=$doc->createElement("note");
    $not->addText($self->conv->encode($note));
    if ($old_note) {
      $frame->replaceChild($not,$old_note);
      $self->dispose_node($old_note);
    } else {
      $frame->insertAfter($not,$ex);
    }
  } elsif ($old_note) {
    $frame->removeChild($old_note);
    $self->dispose_node($old_note);
  }
  undef $old_note;
  my ($old_elems)=$frame->getChildElementsByTagName("frame_elements");
  my ($problems)=$frame->getChildElementsByTagName("problems");
  if ($problem ne "") {
    unless ($problems) {
      $problems=$doc->createElement("problems");
      if ($old_elems) {
	$frame->insertBefore($problems,$old_elems);
      } else {
	$frame->appendChild($problems);
      }
    }
    my $probl=$doc->createElement("problem");
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
    $problems->appendChild($probl);
  }

  my $elems=$doc->createElement("frame_elements");
  $frame->replaceChild($elems,$old_elems);
  $self->dispose_node($old_elems);
  undef $old_elems;

  $self->addFrameElements($elems,$elements);
  $self->addFrameLocalHistory($frame,"modify");
  $self->set_change_status(1);
  return $frame;
}

sub getWordForFrame {
  my ($self,$frame)=@_;
  return $frame->getParentNode()->getParentNode();
}

sub getFrameId {
  my ($self,$frame)=@_;
  return undef unless $frame;
  return $frame->getAttribute("frame_ID");
}

sub getWordId {
  my ($self,$word)=@_;
  return undef unless $word;
  return $word->getAttribute("word_ID");
}

sub getSubstitutingFrame {
  my ($self,$frame)=@_;
  return $frame->getAttribute("substituted_with");
}

sub getFrameStatus {
  my ($self,$frame)=@_;
  return $frame->getAttribute("status");
}

sub isEqual {
  my ($self,$a,$b)=@_;
  return $a == $b;
}

sub normalize_ws {
}

sub register_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  unless (grep {$_ == $client} @$clients) {
    push @$clients,$client;
  }
}

sub unregister_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  @$clients=grep {$_ != $client} @$clients;
}

sub make_clients_forget_data_pointers {
  my ($self)=@_;
  my $clients=$self->clients();
  foreach my $client (@$clients) {
    $client->forget_data_pointers();
  }
}

sub DESTROY {
  my ($self)=@_;
  $self->make_clients_forget_data_pointers();
}

##############################################
# TrEd::ValLex::Data
##############################################
#
# Any object storing pointers to data elements
# must implement this interface for proper
# deallocation
#
##############################################

package TrEd::ValLex::DataClient;

sub data {
}

sub register_as_data_client {
  if ($_[0]->data()) {
    $_[0]->data()->register_client($_[0]);
  }
}

sub unregister_data_client {
  if ($_[0]->data()) {
    $_[0]->data()->unregister_client($_[0]);
  }
}

sub forget_data_pointers {
}

sub destroy {
  my ($self)=@_;
  $_[0]->unregister_data_client();
}

1;
