##############################################
# TrEd::ValLex::GDOMEData
##############################################

package TrEd::ValLex::GDOMEData;
use strict;
use base qw(TrEd::ValLex::Data);
use IO;
use XML::GDOME;

sub parser_start {
  my ($self, $file, $novalidation)=@_;

  my $mode|=GDOME_LOAD_VALIDATING unless $novalidation;
  $mode= GDOME_LOAD_PARSING | GDOME_LOAD_SUBSTITUTE_ENTITIES | GDOME_LOAD_COMPLETE_ATTRS;
  my $doc=XML::GDOME->createDocFromURI($file,$mode);
  return (1,$doc);
}

sub doc_reload {
  my ($self,$novalidation)=@_;
  my $mode|=GDOME_LOAD_VALIDATING unless $novalidation;
  $mode= GDOME_LOAD_PARSING | GDOME_LOAD_SUBSTITUTE_ENTITIES | GDOME_LOAD_COMPLETE_ATTRS;
  $self->set_doc(XML::GDOME->createDocFromURI($self->file,$mode));
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

# sub findWord {
#   my ($self,$find,$nearest)=@_;
#   my $doc=$self->doc();
#   return unless $doc;
#   my $docel=$doc->getDocumentElement();
#   my $lemma = $self->conv->encode($find);
#   if ($nearest) {
#     my ($word) = $docel->findnodes(".//word[starts-with(\@lemma,'$lemma')]");
#     return $word;
#   } else {
#     my ($word) = $docel->findnodes(".//word[\@lemma='$lemma']");
#     return $word;
#   }
#   return undef;
# }

# sub findWordAndPOS {
#   my ($self,$find,$pos)=@_;
#   my $doc=$self->doc();
#   return unless $doc;
#   my $docel=$doc->getDocumentElement();
#   my $lemma = $self->conv->encode($find);
#   my ($word) = $docel->findnodes(".//word[\@lemma='$lemma' and \@POS='$pos']");
#   return $word;
# }

sub isEqual {
  my ($self,$a,$b)=@_;
  return unless(ref($a) and ref($b));
  return $a->gdome_ref == $b->gdome_ref
}

#############################################
## adding some features to XML::GDOME::Node
#############################################
package XML::GDOME::Node;

sub getChildElementsByTagName {
  my ($self,$name)=@_;
  return $self->findnodes("./$name");
}

sub getDescendantElementsByTagName {
  my ($self,$name)=@_;
  return $self->findnodes(".//$name");
}

sub isTextNode {
  return $_[0]->getNodeType == XML::GDOME::TEXT_NODE;
}

package XML::GDOME::Element;

sub addText {
  $_[0]->appendText($_[1])
}

1;
