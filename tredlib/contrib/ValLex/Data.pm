##############################################
# TrEd::ValLex::Data
##############################################

package TrEd::ValLex::Data;
use strict;

sub new {
  my ($self, $file, $cpconvert,$novalidation)=@_;
  my $class = ref($self) || $self;
  my $new = bless [$class->parser_start($file,$novalidation),
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
  return undef unless ref($self);
  return $self->doc()->documentElement->getAttribute("owner");
}

sub set_file {
  return undef unless ref($_[0]);
  return $_[0]->[2]=$_[1];
}

sub set_user {
  my ($self,$user)=@_;
  return undef unless ref($self);
  return $self->doc()->documentElement->setAttribute("owner",$user);
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
  my ($head)=$doc->documentElement()->getChildElementsByTagName("head");
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

sub getWordNodes {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my ($body)=$doc->documentElement()->getChildElementsByTagName ("body");
  return unless $body;
  return $body->getChildElementsByTagName("word");
}

sub getFrameNodes {
  my ($self,$word)=@_;
  return unless ref($word);
  my ($vf)=$word->getChildElementsByTagName ("valency_frames");
  return unless $vf;
  return $vf->getChildElementsByTagName ("frame");
}

sub getFrameElementNodes {
  my ($self,$frame)=@_;
  return unless ref($frame);
  my ($fe)=$frame->getChildElementsByTagName ("frame_elements");
  return unless $fe;
  return $fe->getChildElementsByTagName ("element");
}

=item getWordNodes
  return $slen words before and after given word
  suppose the lexicon is sorted alphabetically
=cut

sub getWordSubList {
  my ($self,$item,$slen,$posfilter)=@_;
  use locale;
  my $doc=$self->doc();
  return unless $doc;
  my @words=();
  my $docel=$doc->documentElement();
  my ($milestone,$after,$before,$i);
  if (ref($item)) {
    $milestone = $item;
    $before = $slen;
    $after = $slen;
  } elsif ($item eq "") {
    $milestone = $self->getFirstWordNode();
    $after = 2*$slen;
    $before = 0;
  } else {
    # search by lemma
    my $word = $self->getFirstWordNode();
    my $i=0;
    WORD: while ($word) {
      last if ($i++ % $slen == 0 &&
	       $item le $self->conv()->decode($word->getAttribute ("lemma")));
      $word = $word->nextSibling() || last;
      while ($word) {
	last if ($word->nodeName() eq 'word');
	$word = $word->nextSibling() || last;
      }
    }
    $milestone = $word;
    $before = $slen + $slen/2;
    $after = $slen/2;
  }

  # get before list
  $i=0;
  my $word = $milestone;
  ($posfilter) = $posfilter=~/^\s*([a-z])/i;
  while ($word and $i<$before) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if ($posfilter eq '' or $pos eq uc($posfilter)) {
      my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
      my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
      unshift @words, [$word,$id,$lemma,$pos];
      $i++;
    }
    $word=$word->previousSibling();
    while ($word) {
      last if ($word->nodeName() eq 'word');
      $word=$word->previousSibling();
    }
  }

  # get after list
  $i=0;
  $word=$milestone->nextSibling();
  while ($word and $word->nodeName eq 'word' and $i<$after) {
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    if ($posfilter eq '' or $pos eq uc($posfilter)) {
      my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
      my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
      push @words, [$word,$id,$lemma,$pos];
      $i++;
    }
    $word=$word->nextSibling();
    while ($word) {
      last if ($word->nodeName() eq 'word');
      $word=$word->nextSibling();
    }
  }
  return			# sort { $a->[2] cmp $b->[2] }
    @words;
}


sub getWordList {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my @words=();
  my $docel=$doc->documentElement();
  my $word = $self->getFirstWordNode();
  while ($word) {
    my $id = $self->conv()->decode($word->getAttribute ("word_ID"));
    my $lemma = $self->conv()->decode($word->getAttribute ("lemma"));
    my $pos = $self->conv()->decode($word->getAttribute ("POS"));
    push @words, [$word,$id,$lemma,$pos];
    $word=$word->nextSibling();
    while ($word) {
      last if ($word->nodeName() eq 'word');
      $word=$word->nextSibling();
    }
  }
  return # sort { $a->[2] cmp $b->[2] }
    @words;
}

sub getFrame {
  my ($self,$frame)=@_;

  my $id = $self->conv->decode($frame->getAttribute("frame_ID"));
  my $status = $self->conv->decode($frame->getAttribute("status"));
  my $elements = $self->getFrameElementString($frame);
  my $example=$self->getFrameExample($frame);
  my $note=$self->getSubElementNote($frame);
  $note=~s/\n/;/g;
  my ($local_event)=$frame->getDescendantElementsByTagName("local_event");
  my $auth="NA";
  $auth=$self->conv->decode($local_event->getAttribute("author")) if ($local_event);
  
  return [$frame,$id,$elements,$status,$example,$auth,$note];
}

sub getSuperFrameList {
  my ($self,$word)=@_;
  use Tie::IxHash;
  tie my %super, 'Tie::IxHash';
  return unless $word;
  my $base;
  my $nosuper=0;
  my $pos=$self->getPOS($word);
  my @frames=$self->getFrameNodes($word);
  my (@active,@obsolete);
  foreach (@frames) {
    if ($self->getFrameStatus($_) =~ /substituted|obsolete|deleted/) {
      push @obsolete,$_;
    } else {
      push @active,$_;
    }
  }
  if ($pos eq 'N') {
    foreach (@active,@obsolete) {
      $super{$nosuper++}=[$self->getFrame($_)];
    }
    return \%super;
  }
  foreach my $frame (@active) {
    $base="";
    my @element_nodes=$self->getFrameElementNodes($frame);
    foreach my $element (
			 (
			  grep { 
			    $_->getAttribute('type') eq 'oblig'
			  }
			  @element_nodes),
			 (grep {
			   $_->getAttribute('type') ne 'oblig' and # but
			     $_->getAttribute('functor') =~
			       /^(?:ACT|PAT|EFF|ORIG|ADDR)$/
			     } @element_nodes)
			 # this is in two greps so that we
			 # do not have to sort it
			) {
      $base.=$self->getOneFrameElementString($element)." ";
    }
    $base="$frame" if $base eq '';
    if (exists $super{$base}) {
      push @{$super{$base}},$self->getFrame($frame);
    } else {
      $super{$base}=[$self->getFrame($frame)];
    }
  }
  foreach (@obsolete) {
    $super{$nosuper++}=[$self->getFrame($_)];
  }
  return \%super;
}

sub getFrameList {
  my ($self,$word)=@_;
  return unless $word;
  return map { $self->getFrame($_) } $self->getFrameNodes($word);
}

sub getOneFrameElementString {
  my ($self,$element)=@_;

  my $functor = $self->conv->decode($element->getAttribute ("functor"));
  my $type = $self->conv->decode($element->getAttribute("type"));
  my $forms = $self->getFrameElementFormsString($element);
  return $functor.($type eq "oblig" ? "($forms)" : "[$forms]");
}

sub getFrameElementString {
  my ($self,$frame)=@_;
  return unless $frame;
  my @elements;
  my @element_nodes=$self->getFrameElementNodes($frame);

  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'oblig' }
			@element_nodes)
		      ) {
    push @elements,$self->getOneFrameElementString($element);
  }
  push @elements, "  " if @elements;
  foreach my $element (
		       (grep { $_->getAttribute('type') eq 'non-oblig' }
			@element_nodes
		       )
		      ) {
    push @elements,$self->getOneFrameElementString($element);
  }
  if (@elements) {
    return join("  ", @elements);
  } else {
    return "EMPTY";
  }
}

sub getNextWordNode {
  my ($self,$n)=@_;

  $n=$n->nextSibling();
  while ($n) {
    last if ($n and $n->nodeName() eq 'word');
    $n=$n->nextSibling();
  }
  return $n;
}

sub getFirstWordNode {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  my $body=$docel->firstChild();
  while ($body) {
    last if ($body->nodeName() eq 'body');
    $body=$body->nextSibling();
  }
  die "didn't find vallency_lexicon body?" unless $body;
  my @w;
  my $n=$body->firstChild();
  while ($n) {
    last if ($n->nodeName() eq 'word');
    $n=$n->nextSibling();
  }
  return $n;
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
    my $text=$example->firstChild;
    if ($text and $text->isTextNode) {
      my $data=$text->getData();
      $data=~s/^\s+//;
      $data=~s/\s*;\s*/\n/g;
      $data=~s/[\s\n]+$//g;
      $data=$self->conv->decode($data);
      return $data;
    }
  }
  return "";
}

sub getElementText {
  my ($self,$element)=@_;
  return unless $element;
  $self->normalize_ws($element);
  my $text=$element->firstChild;
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
  my $text=$note->firstChild;
  if ($text and $text->isTextNode) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/\s*;\s*/\n/g;
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
    my $solved = $self->conv->decode($problem->getAttribute ("solved"));
    my $text = $self->getElementText($problem);
    push @problems, [$problem,$text,$author,$solved];
  }
  return @problems;
}

sub findWord {
  my ($self,$find,$nearest)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  foreach my $word ($self->getWordNodes()) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    return $word if (($nearest and index($lemma,$find)==0) or $lemma eq $find);
  }
  return undef;
}

sub findWordAndPOS {
  my ($self,$find,$pos)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  foreach my $word ($self->getWordNodes()) {
    my $lemma = $self->conv->decode($word->getAttribute("lemma"));
    my $POS = $self->conv->decode($word->getAttribute ("POS"));
    return $word if ($lemma eq $find and $POS eq $pos);
  }
  return undef;
}

sub getForbiddenIds {
  my ($self)=@_;
  my $doc=$self->doc();
  return {} unless $doc;
  my $docel=$doc->documentElement();
  my ($tail)=$docel->getChildElementsByTagName("tail");
  return {} unless $tail;
  my %ids;
  foreach my $ignore ($tail->getChildElementsByTagName("forbid")) {
    $ids{$self->conv->decode($ignore->getAttribute("forbidden_ID"))}=1;
  }
  return \%ids;
}

sub generateNewWordId {
  my ($self,$lemma,$pos)=@_;
  my $i=0;
  my $forbidden=$self->getForbiddenIds();
  foreach ($self->getWordList) {
    return undef if ($_->[2] eq $lemma and $_->[3] eq $pos);
    if ($_->[1]=~/^w-([0-9]+)/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  my $user=$self->user;
  $i++ while ($forbidden->{"w-$i-$user"});
  return "w-$i-$user";
}

sub addWord {
  my ($self,$lemma,$pos)=@_;
  return unless $lemma ne "";
  my $new_id = $self->generateNewWordId($lemma,$pos);
  return unless defined($new_id);

  my $doc=$self->doc();
  my $root=$doc->documentElement();
  my ($body)=$root->getChildElementsByTagName("body");
  return unless $body;
  # find alphabetic position
  my $n=$self->getFirstWordNode();
  use locale;

  while ($n) {
    last if $lemma le $self->conv->decode($n->getAttribute("lemma"));
    # don't allow more then 1 lemma/pos pair
    $n=$n->nextSibling();
    while ($n && $n->nodeName ne 'word') {
      $n=$n->nextSibling();
    }
  }
  my $word=$doc->createElement("word");
  if ($n) {
    print "insert before\n";
    $body->insertBefore($word,$n);
  } else {
    print "append\n";
    $body->appendChild($word);
  }
  $word->setAttribute("lemma",$self->conv->encode($lemma));
  $word->setAttribute("POS",$pos);
  $word->setAttribute("word_ID",$new_id);

  my $valency_frames=$doc->createElement("valency_frames");
  $word->appendChild($valency_frames);
  $self->set_change_status(1);
  print "Added $word\n";
  return $word;
}

sub getPOS {
  my ($self,$word)=@_;
  return unless ref($word);
  return $self->conv->decode($word->getAttribute("POS"));
}

sub getLemma {
  my ($self,$word)=@_;
  return unless ref($word);
  return $self->conv->decode($word->getAttribute("lemma"));
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
  $local_history->appendChild($local_event);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  $local_event->setAttribute("time_stamp",sprintf('%d.%d.%d %02d:%02d:%02d',
						 $mday,$mon+1,1900+$year,$hour,$min,$sec));
  $local_event->setAttribute("type_of_event",$type);
  $local_event->setAttribute("author",$self->user());
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
  return unless ($frame);
  my $new=$self->addFrame($frame,$word,$elements,$note,$example,$problem,$self->user());
  return unless $new;
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
#  my $w=0;
  my $wid=$word->getAttribute("word_ID");
  my $forbidden=$self->getForbiddenIds();
#  $w=$1 if ($wid=~/^.-(.+)/);
  foreach ($self->getFrameList($word)) {
    if ($_->[1]=~/-(\d+)\D*$/ and $i<$1) {
      $i=$1;
    }
  }
  $i++;
  my $user=$self->user;
  $i++ while ($forbidden->{"f-$wid-$i-$user"});
  return "f-$wid-$i-$user";
}

sub addForms {
  my ($self, $elem,$string)=@_;
  my $doc=$self->doc();
  foreach my $f (split /\s*,\s*/, $string) {
    $f=~s/^\s+//;
    if ($f ne "") {
      my $form=$doc->createElement("form");
      $elem->appendChild($form);
      $form->setAttribute("abbrev",$f);
    }
  }
  $self->set_change_status(1);
}

sub addFrameElements {
  my ($self,$elems,$elements)=@_;
  if ($elements=~/\S/ and $elements!~/EMPTY/) {
    my $doc=$self->doc();
    my @elements=$elements=~/(?:^\s*|\s+)[A-Z0-9]+(?:[[(][^])]*[])])?/g;
    foreach (@elements) {
      if (/^\s*([A-Z0-9]+)([[(])?([^])]*)[])]?$/) {
	my $elem=$doc->createElement("element");
	$elems->appendChild($elem);
	$elem->setAttribute("functor",$self->conv->encode($1));
	$elem->setAttribute("type", ($2 eq '(') ? "oblig" : "non-oblig");
	$self->addForms($elem,$self->conv->encode($3));
      }
    }
  }
  $self->set_change_status(1);
}

sub addFrame {
  my ($self,$before,$word,$elements,$note,$example,$problem,$author)=@_;
  return unless $word and $elements;

  my $new_id = $self->generateNewFrameId($word);
  my $doc=$self->doc();
  my ($valency_frames)=$word->getChildElementsByTagName("valency_frames");
  return unless $valency_frames;
  my $frame=$doc->createElement("frame");

  if (ref($before)) {
    $valency_frames->insertBefore($frame,$before);
  } else {
    $valency_frames->appendChild($frame);
  }
  $frame->setAttribute("frame_ID",$new_id);
  $frame->setAttribute("status","active");

  my $ex=$doc->createElement("example");
  $frame->appendChild($ex);
  $ex->addText($self->conv->encode($example));

  if ($note ne "") {
    my $not=$doc->createElement("note");
    $frame->appendChild($not);
    $not->addText($self->conv->encode($note));
  }
  if ($problem ne "") {
    my $problems=$doc->createElement("problems");
    $frame->appendChild($problems);

    my $probl=$doc->createElement("problem");
    $problems->appendChild($probl);
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
  }
  my $elems=$doc->createElement("frame_elements");
  $frame->appendChild($elems);
  $self->addFrameElements($elems,$elements);
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
  if ($old_ex) {
    $frame->replaceChild($ex,$old_ex);
    $self->dispose_node($old_ex);
  } else {
    $frame->insertBefore($ex,undef);
  }
  $ex->addText($self->conv->encode($example));
  undef $old_ex;

  my ($old_note)=$frame->getChildElementsByTagName("note");
  if ($note ne "") {
    my $not=$doc->createElement("note");
    if ($old_note) {
      $frame->replaceChild($not,$old_note);
      $self->dispose_node($old_note);
    } else {
      $frame->insertAfter($not,$ex);
    }
    $not->addText($self->conv->encode($note));
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
    $problems->appendChild($probl);
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
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
  return $self->conv->decode($frame->getAttribute("frame_ID"));
}

sub getWordId {
  my ($self,$word)=@_;
  return undef unless $word;
  return $self->conv->decode($word->getAttribute("word_ID"));
}

sub getSubstitutingFrame {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("substituted_with"));
}

sub getFrameStatus {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("status"));
}

sub getFrameUsed {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("used"));
}

sub getFrameHereditaryUsed {
  my ($self,$frame)=@_;
  return $self->conv->decode($frame->getAttribute("hereditary_used"));
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
  $self->set_parser(undef);
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
