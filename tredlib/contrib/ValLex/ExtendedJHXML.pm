# -*- cperl -*-

package TrEd::ValLex::ExtendedJHXML;
use ValLex::Extended;
use ValLex::JHXMLData;
use base qw(TrEd::ValLex::JHXMLData TrEd::ValLex::Extended);

sub remove_node {
  my ($self, $node) = @_;
  if ($node->parentNode) {
    $node->parentNode->removeChild($node);
  }
  $node->destroy();
}

sub clone_frame {
  my ($self,$frame)=@_;
  my $str = $frame->toString();
  $str = '<?xml version="1.0" encoding="utf-8"?>'."\n".$str;
  my $p = XML::JHXML->new();
  $p->keep_blanks(-1);
  return $p->parse_string($str)->documentElement;
}

1;
