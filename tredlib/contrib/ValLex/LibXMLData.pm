##############################################
# TrEd::ValLex::LibXMLData
##############################################

package TrEd::ValLex::LibXMLData;
use strict;
use base qw(TrEd::ValLex::Data);
use IO;
use XML::LibXML;

sub parser_start {
  my ($self, $file)=@_;
  my $parser=XML::LibXML->new();
  XML::LibXML->load_ext_dtd(1);
  XML::LibXML->validation(1);
  my $doc;
  $doc=$parser->parse_file($file);
  return ($parser,$doc);
}

sub doc_reload {
  my ($self)=@_;
  XML::LibXML->load_ext_dtd(1);
  XML::LibXML->validation(1);
  $self->set_doc($self->parser()->parse_file($self->file));
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
  $output->print($self->doc()->toString($indent));
  $output->close();
  $self->set_change_status(0);
  return 1;
}

sub findWord {
  my ($self,$find,$nearest)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  my $lemma = $self->conv->encode($find);
  if ($nearest) {
    my ($word) = $docel->findnodes(".//word[starts-with(\@lemma,'$lemma')]");
    return $word;
  } else {
    my ($word) = $docel->findnodes(".//word[\@lemma='$lemma']");
    return $word;
  }
  return undef;
}

sub findWordAndPOS {
  my ($self,$find,$pos)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  my $lemma = $self->conv->encode($find);
  print ".//word[\@lemma='$lemma' and \@POS='$pos']\n";
  my ($word) = $docel->findnodes(".//word[\@lemma='$lemma' and \@POS='$pos']");
  return $word;
}

sub isEqual {
  my ($self,$a,$b)=@_;
  return unless ref($a);
  return $a->isEqual($b);
}

#############################################
## adding some features to XML::LibXML::Node
#############################################
package XML::LibXML::Node;

sub getChildElementsByTagName {
  my ($self,$name)=@_;
  return $self->getElementsByTagName($name);
}

sub getDescendantElementsByTagName {
  my ($self,$name)=@_;
  return $self->findnodes(".//$name");
}

sub isTextNode {
  return $_[0]->getType == XML::LibXML::XML_TEXT_NODE;
}

package XML::LibXML::Element;

sub addText {
  $_[0]->appendText($_[1])
}

1;
