##############################################
# TrEd::ValLex::JHXMLData
##############################################

package TrEd::ValLex::JHXMLData;
use strict;
use base qw(TrEd::ValLex::Data);
use IO;
use XML::JHXML;

sub parser_start {
  my ($self, $file, $novalidation)=@_;
  my $parser=XML::JHXML->new();
  my $doc;
  print STDERR "parsing file $file\n";
  eval {
    $doc = $parser->parse_file($file);
  };
  die "$@\n" if $@;
  print STDERR "done\n";
  return ($parser,$doc);
}

sub dispose_node {
  my ($self,$node)=@_;
  $node->destroy();
}

sub doc_reload {
  my ($self)=@_;
  my $parser=$self->parser();
  return unless $parser;
  print STDERR "parsing file ",$self->file,"\n";
  eval {
    my $doc=$parser->parse_file($self->file);
    $self->set_doc($doc);

  };
  print STDERR "$@\ndone\n";
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

  $self->doc()->toFile($file);
  $self->set_change_status(0);
  return 1;
}

sub getFirstWordNode {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  my $body=$docel->findFirstChild('body');
  die "didn't find vallency_lexicon body?" unless $body;
  return $body->findFirstChild('word');
}

sub getWordNodes {
  my ($self)=@_;
  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->documentElement();
  my $body=$docel->findFirstChild('body');
  die "didn't find vallency_lexicon body?" unless $body;
  my @w;
  my $n=$body->findFirstChild('word');
  while ($n) {
    push @w,$n;
    $n=$n->findNextSibling('word');
  }
  return @w;
}

sub isEqual {
  my ($self,$a,$b)=@_;
  return unless ref($a);
  return $a->isSameNode($b);
}

#############################################
## adding some features to XML::JHXML::Node
#############################################
package XML::JHXML::Node;

*getChildElementsByTagName=*getChildrenByTagName;
*getDescendantElementsByTagName=*getElementsByTagName;

package XML::JHXML::Node;

*addText = *appendText;

1;
