#!/usr/bin/perl

use XML::LibXML;
use strict;

sub add_forbidden_id {
  my ($doc,$id)=@_;
  my $doc_el=$doc->getDocumentElement();
  my ($tail)=$doc_el->getElementsByTagName("tail");
  unless ($tail) {
    $tail=$doc->createElement("tail");
    my ($body)=$doc_el->getElementsByTagName("body");
    $doc_el->insertAfter($tail,$body);
  }
  my $forbid=$doc->createElement("forbid");
  $forbid->setAttribute("forbidden_ID",$id);
  $tail->appendChild($forbid);
  return;
}

sub join_substitutions {
  my ($x,$y)=@_;
  my @x=split /\s+/,$x;
  my @y=split /\s+/,$y;
  my %uniq;
  foreach (@x,@y) {
    $uniq{$_}=1;
  }
  return join " ",keys(%uniq);
}

my ($base_file, @new_files)=@ARGV;

print STDERR "Base document: $base_file\n";
my $parser=XML::LibXML->new();
$parser->load_ext_dtd(1);
$parser->validation(1);

my $base_doc=$parser->parse_file($base_file);
my $base_doc_el=$base_doc->getDocumentElement();
my ($base_doc_body)=$base_doc_el->getElementsByTagName("body");
my $new_doc;
my $new_doc_el;

foreach my $new_file (@new_files) {
  print STDERR "Merging $new_file...\n";
  $new_doc=$parser->parse_file($new_file);
  $new_doc_el=$new_doc->getDocumentElement();
  my $new_doc_owner=$new_doc_el->getAttribute("owner");
  # Add new global history record
  do {
    my ($global_history)=$base_doc_el->findnodes("/valency_lexicon/head/global_history");
    my  $global_event=$base_doc->createElement("global_event");
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    $global_event->setAttribute("time_stamp",sprintf('%d.%d.%d %02d:%02d:%02d',
						   $mday,$mon,1900+$year,$hour,$min,$sec));
    $global_event->setAttribute("author","PP");
    $global_event->appendText("slevani s novymi ramci z dat $new_doc_owner");
    $global_history->appendChild($global_event);
  };				# forget these elements

  foreach my $word ($new_doc_el->findnodes("/valency_lexicon/body/word")) {
    my $id=$word->getAttribute("word_ID");

    my ($base_word)=$base_doc_el->findnodes("id('$id')");
    if (!ref($base_word)) {
      my $lemma=$word->getAttribute("lemma");
      my $pos=$word->getAttribute("POS");
#      print STDERR "Trying /valency_lexicon/body/word[\@lemma='$lemma' and \@POS='$pos']\n";
      ($base_word)=$base_doc_el->findnodes("/valency_lexicon/body/word[\@lemma='$lemma' and \@POS='$pos']");
      if (ref($base_word)) {
	print STDERR "found $base_word\n";
	# the same word was added by different annotators
	add_forbidden_id($base_doc,$id);
      }
    }
    if (ref($base_word)) {
      die("Error: non-word identifier $id of base element ".
	  $base_word->getName().
	  " used in the file owned by $new_doc_owner\n")
	unless ($base_word->getName() eq 'word');
      foreach my $frame ($word->findnodes("./valency_frames/frame")) {
	my $frame_id=$frame->getAttribute("frame_ID");
	my ($base_frame)=$base_doc_el->findnodes("id('$frame_id')");
	if (ref($base_frame)) {

	  die("Error: non-frame identifier $frame_id of base element ".
	      $base_frame->getName().
	      " used in the file owned by $new_doc_owner\n")
	    unless ($base_frame->getName() eq 'frame');
	  die("Error: frame $frame_id belongs to different words ".
	      "in base and the file owned by $new_doc_owner\n")
	    unless ($base_word->isEqual($base_frame->getParentNode()->getParentNode()));

	  my $status=$frame->getAttribute("status");
	  my $base_status=$base_frame->getAttribute("status");
	  my $subst_with=$frame->getAttribute("substituted_with");
	  my $base_subst_with=$base_frame->getAttribute("substituted_with");

	  # vetsi status vyhrava pri (castecnem) usporadani:
	  # deleted, substituted > obsolete > reviewed > active

	  if (($status =~ m!^substituted$|^obsolete$|^deleted$! and
	      $base_status =~ m!^active|reviewed$!) or
	      ($status eq 'reviewed' and $base_status eq 'active') or
	      ($status eq 'substituted' and $base_status eq 'obsolete')
	     ) {

	    $base_frame->setAttribute("status",$status);
	    $base_frame->setAttribute("substituted_with",
				      join_substitutions($subst_with,$base_subst_with));

	    #
	    # lokalni historie se musi prenest taky, ale
	    # neni jasne jak. Parsovat time_stamp
	    # a zjistovat, co je noveho se mi moc nechce.
	    # Tak proste pridam vsechno, co se stejnym time-stampem
	    # a autorem jeste v historii neni.
	    #

	    my ($local_history)=$base_frame->getElementsByTagName('local_history');
	    my %events = map { $_->getAttribute('author').
       			 '@'.$_->getAttribute('time_stamp') => 1
			     } $local_history->getElementsByTagName('local_event');
	    foreach my $event ($frame->findnodes('./local_history/local_event')) {
	      unless ($events{$event->getAttribute('author').
			  '@'.$event->getAttribute('time_stamp')}) {
		my $copy=$event->cloneNode(1);
		$copy->setOwnerDocument($base_doc);
		$local_history->appendChild($copy);
	      }
	    }

	  }
	} else {
	  my $copy=$frame->cloneNode(1);
	  $copy->setOwnerDocument($base_doc);
	  my ($valframes)=$base_word->getElementsByTagName('valency_frames');
	  $valframes->appendChild($copy);
	}
      }
    } else {
      # ok, the word really does not exist in the base document
      my $copy=$word->cloneNode(1);
      $copy->setOwnerDocument($base_doc);
      $base_doc_body->appendChild($copy);
    }
  }
  undef $new_doc_el;
  undef $new_doc; 		# forget it
}

print $base_doc->toString(1);
print "\n";
