##############################################
# TrEd::ValLex::XML_DOM_Data
##############################################

package TrEd::ValLex::XML_DOM_Data;
use strict;
use base qw(TrEd::ValLex::Data);
use IO;
use XML::DOM;

sub parser_start {
  my ($self,$file)=@_;
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

  return ($parser,$doc);
}

sub doc_reload {
  my ($self)=@_;
  $self->set_doc($self->parser()->parsefile($self->file));
}

sub dispose_node {
  my ($self,$node)=@_;
  $node->dispose();
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

sub normalize_ws {
  my ($self,$node)=@_;
  $node->normalize();
}

#############################################
## adding some features to XML::DOM::Node
#############################################
package XML::DOM::Node;

*firstChild = *getFirstChild;
*nextSibling = *getNextSibling;
*nodeName = *getNodeName;
sub getChildElementsByTagName {
  my ($self,$name)=@_;
  return ($self->getElementsByTagName($name,0));
}

sub getDescendantElementsByTagName {
  my ($self,$name)=@_;
  return ($self->getElementsByTagName($name));
}

sub findNextSibling {
  my ($self, $name)=@_;
  my $n=$self->nextSibling();
  while ($n) {
    last if ($n and $n->nodeName() eq $name);
    $n=$n->nextSibling();
  }
  return $n;
}

sub findPreviousSibling {
  my ($self, $name)=@_;
  my $n=$self->previousSibling();
  while ($n) {
    last if ($n and $n->nodeName() eq $name);
    $n=$n->previousSibling();
  }
  return $n;
}

sub isTextNode {
  return $_[0]->getNodeType == TEXT_NODE;
}
package XML::DOM::Text;
*nodeName = *getNodeName;
package XML::DOM::Element;
*nodeName = *getNodeName;

package XML::DOM::Document;
*documentElement = *getDocumentElement;

##################################################
## adding some features to XML::Handler::Composer
##################################################

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


##################################################
## adding some features to XML::Filter::Reindent
##################################################

package XML::Filter::Reindent;

sub Comment {
  my ($self,$event)=@_;
#  $self->push_event('comment',$event);
}

sub comment {
  my ($self,$event)=@_;
#  $self->push_event('comment',$event);
}

1;
