# we have to add some missing features to standard XML modules :(
package XML::Handler::Composer;

sub Comment
{
    my ($self, $event) = @_;
#    my $str = "<!-- " . $event->{Data} . " -->\n";
#    $self->print ($str);
}

sub comment
{
    my ($self, $event) = @_;
#    my $str = "<!-- " . $event->{Data} . " -->\n";
#    $self->print ($str);
}


package XML::Filter::Reindent;

sub Comment {
  my ($self,$event)=@_;
#  $self->push_event('comment',$event);
}

sub comment {
  my ($self,$event)=@_;
#  $self->push_event('comment',$event);
}


package TrEd::ValLex::Data;
use strict;
use XML::DOM;

use IO;
use IO::Zlib;

sub new {
  my ($self, $file, $cpconvert)=@_;
  my $class = ref($self) || $self;
  my $parser;
  if ($^O eq "MSWin32") {
    # why even simple things must this damned hacked
    # in that system, huh?
    my ($filename_base)= $file=~/^(.*[\/\\])[^\/\\]*$/;
    $parser = 
      new XML::DOM::Parser(ParseParamEnt => 1,
			   NoLWP =>1,
			   Handlers =>{ExternEnt =>
				       sub {
					 my ($exp, $base, $sys, $pub) = @_;
					 if ($base eq "" and
					     $sys!~/^(\/)/ and
					     $sys!~/^\w+:/) {
					   $base="file:$filename_base";
					 }
					 return XML::Parser::file_ext_ent_handler($exp,$base,$sys,$pub);
				       }
				      }
			  );
  } else {
    $parser = new XML::DOM::Parser(ParseParamEnt => 1, NoLWP =>1);
  }
  my $doc;
  if ($file=~/.gz$/) {
    my $fh;
    if (eval {
      $fh = new IO::Pipe();
      $fh && $fh->reader("$ZBackend::zcat < \"$file\"");
    }) {
      $doc = $parser->parse ($fh);
      $fh->close();
    }
  } else {
    $doc = $parser->parsefile ($file);
  }
  my $new = bless [$parser,$doc,$file, undef, undef, 0, $cpconvert], $class;
  $new->loadListOfUsers();
  return $new;
}

sub conv {
  return $_[0]->[6];
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

sub test_internal {
  my ($self,$doctype)=@_;
  if ($doctype->can('getInternal')) {
    return $doctype->getInternal();
  } else {
    return $doctype->{Internal};
  }
}

sub save {
  my ($self, $no_backup,$indent)=@_;
  my $file=$self->file();
  return unless ref($self);
  my $backup=$file;
  if ($^O eq "MSWin32") {
    $backup=~s/(\.xml)?$/.bak/i;
  } else {
    $backup.="~";
  }

  unless ($no_backup || rename $file, $backup) {
    warn "Couldn't create backup file, aborting save!\n";
    return 0;
  }
  my $output;
  if ($file=~/.gz$/) {
    eval {
      $output = new IO::Pipe();
      $output && $output->writer("$ZBackend::gzip > \"$file\"");
    };
  } else {
    $output = new IO::File(">$file");
  }
  unless ($output) {
    print STDERR "ERROR: cannot write to file $file\n";
    return 0;
  }
  if ($indent) {
    require XML::Handler::Composer;
    require XML::Filter::Reindent;


    $self->doc()->getXMLDecl()->setEncoding('utf-8');
    $self->doc()->getXMLDecl()->print($output);
    $output->print("\n");
    my $writer = new XML::Handler::Composer (Print => sub {
					       $output->print(@_);
					     });
    my $filter = new XML::Filter::Reindent (Handler => $writer);
    $self->doc()->to_sax(Handler => $filter);
  } else {
    my $doctype=$self->doc()->getDoctype;
    if ($doctype and !$self->test_internal($doctype)) {
      $self->doc()->getXMLDecl->print($output);
      $output->print("\n");
      my $doctype=$self->doc()->getDoctype;
      if ($doctype) {
	my $name  = $doctype->getName;
	my $sysId = $doctype->getSysId;
	my $pubId = $doctype->getPubId;
	$output->print ("<!DOCTYPE $name");
	if (defined $pubId)
	  {
	    $output->print (" PUBLIC \"$pubId\" \"$sysId\"");
	  }
	elsif (defined $sysId)
	  {
	    $output->print (" SYSTEM \"$sysId\"");
	  }
	# if no internal subset exists, do not print anything
	$output->print (">\x0A");
      }
      $self->doc()->getDocumentElement->print($output);
    } else {
      # If there is an internal subset, dump whole document including
      # doctype (which may result in the external subset included too :((
      # I don't know yet how to handle this using XML::Parser.
      $self->doc()->print($output);
    }
  }
  $output->close();
  $self->set_change_status(0);
  return 1;
}

sub reload {
  my ($self)=@_;
  return unless $self->parser();
  $self->doc()->dispose();
  $self->set_doc(undef);
  $self->set_doc($self->parser()->parsefile($self->file));
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
  my $heads=$doc->getDocumentElement()->getElementsByTagName("head",0);
  if ($heads and $heads->item(0)) {
    my $lists=$heads->item(0)->getElementsByTagName("list_of_users",0);
    if ($lists and $lists->item(0)) {
      foreach my $user ($lists->item(0)->getElementsByTagName("user",0)) {
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
  my $words = $doc->getElementsByTagName ("word");
  my $n = $words->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $word = $words->item($i);
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
  my $frames = $word->getElementsByTagName("frame");
  my $n = $frames->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $frame = $frames->item($i);
    my $id = $frame->getAttribute ("frame_ID");
    my $status = $frame->getAttribute ("status");
    my $elements = $self->getFrameElementString($frame);
    my $example=$self->getFrameExample($frame);
    my $auth=$self->conv->decode($frame->getElementsByTagName("local_event")->item(0)->getAttribute("author"));
    push @frames, [$frame,$id,$elements,$status,$example,$auth];
  }
  return @frames;
}

sub getFrameElementString {
  my ($self,$frame)=@_;
  return unless $frame;
  my @elements;
  my $elements = $frame->getElementsByTagName("element");
  my $n = $elements->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $element = $elements->item($i);
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
  my $forms = $element->getElementsByTagName("form",0);
  my $n = $forms->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $form = $forms->item($i);
    my $abbrev = $self->conv->decode($form->getAttribute ("abbrev"));
    push @forms,"$abbrev";
  }
  return join ",",@forms;
}

sub getFrameExample {
  my ($self,$frame)=@_;
  return unless $frame;
  $frame->normalize();
  my $text=$frame->getElementsByTagName("example",0)->item(0)->getFirstChild;
  if ($text and $text->getNodeType == TEXT_NODE) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/;\s+/\n/g;
    $data=~s/[\s\n]+$//g;
    return $self->conv->decode($data);
  }
  return "";
}

sub getElementText {
  my ($self,$element)=@_;
  return unless $element;
  $element->normalize();
  my $text=$element->getFirstChild;
  if ($text and $text->getNodeType == TEXT_NODE) {
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
  $elem->normalize();
  my $note=$elem->getElementsByTagName("note",0)->item(0);
  return "" unless $note;
  my $text=$note->getFirstChild;
  if ($text and $text->getNodeType == TEXT_NODE) {
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
  my $problems_e=$elem->getElementsByTagName("problems",0)->item(0);
  return "" unless $problems_e;
  my $problems = $problems_e->getElementsByTagName ("problem",0);
  my $n = $problems->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $problem = $problems->item($i);
    my $author = $self->conv->decode($problem->getAttribute ("author"));
    my $solved = $problem->getAttribute ("solved");
    my $text = $self->getElementText($problem);
    push @problems, [$problem,$text,$author,$solved];
  }
  return @problems;
}

sub findWord {
  my ($self,$find,$nearest)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $words = $doc->getElementsByTagName ("word");
  my $n = $words->getLength;
  for (my $i = 0; $i < $n; $i++) {
    my $word = $words->item($i);
    my $lemma = $self->conv->decode($word->getAttribute ("lemma"));
    return $word if ($nearest and index($lemma,$find)==0 or $lemma eq $find);
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
  my ($body)=$root->getElementsByTagName("body",0);
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

  my $local_history=$frame->getElementsByTagName("local_history",0)->item(0);
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
  my ($valency_frames)=$word->getElementsByTagName("valency_frames",0);
  return unless $valency_frames;
  my $frame=$doc->createElement("frame");
  $frame->setAttribute("frame_ID",$new_id);
  $frame->setAttribute("status","active");
  $valency_frames->insertBefore($frame,$before);

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
  my ($old_ex)=$frame->getElementsByTagName("example",0);
  my $ex=$doc->createElement("example");
  $ex->addText($self->conv->encode($example));
  $frame->replaceChild($ex,$old_ex);
  $old_ex->dispose();
  undef $old_ex;

  my ($old_note)=$frame->getElementsByTagName("note",0);
  if ($note ne "") {
    my $not=$doc->createElement("note");
    $not->addText($self->conv->encode($note));
    print "replacing\n";
    $frame->replaceChild($not,$old_note);
  } else {
    $frame->removeChild($old_note);
  }
  $old_note->dispose();
  undef $old_note;
  my ($old_elems)=$frame->getElementsByTagName("frame_elements",0);
  my ($problems)=$frame->getElementsByTagName("problems",0);
  if ($problem ne "") {
    unless ($problems) {
      $problems=$doc->createElement("problems");
      $frame->insertBefore($problems,$old_elems);
    }
    my $probl=$doc->createElement("problem");
    $probl->addText($self->conv->encode($problem));
    $probl->setAttribute("author",$author);
    $problems->appendChild($probl);
  }

  my $elems=$doc->createElement("frame_elements");
  $frame->replaceChild($elems,$old_elems);
  $old_elems->dispose();
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

1;
