## This is a simple XML backend for TEI files     -*-cperl-*-
## author: Petr Pajas
# $Id$ '
#############################################################

package TrXMLBackend;
use Fslib;
use XML::LibXML;
use XML::LibXML::SAX;
use IOBackend qw(close_backend);
use strict;

sub test {
  my ($f)=@_;
  if (ref($f)) {
    return ($f->getline()=~/\s*\<\?xml / &&
	    $f->getline()=~/\<!DOCTYPE trees[ >]|\<trees[ >]/i);
  } else {
    my $fh = IOBackend::open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}

sub open_backend {
  my ($uri,$rw,$encoding)=@_;
  # discard encoding and pass the rest to the IOBackend
  IOBackend::open_backend($uri,$rw,($rw eq 'w' ? $encoding : undef));
}

=item read ($input,$fsfile)

Read TEI XML file used in SDT for morphological and analytical annotation.

=cut

sub read {
  my ($input,$fsfile) = @_;
  #my $handler = XML::SAX::Writer->new();
  print "read\n";
  
  my $handler = XML::Handler::TrXML2FS->new(FSFile => $fsfile);
  my $p = XML::LibXML::SAX->new(Handler => $handler);
  if (ref($input)) {
    $p->parse(Source => { ByteStream => $input });
  } else {
    $p->parse_uri($input);
  }

  return 1;
}

sub xml_quote {
  local $_=$_[0];
  s/&/&amp;/g;
  s/'/&apos;/g;
  s/"/&quot;/g;
  s/>/&gt;/g;
  s/</&lt;/g;
  return $_;
}

sub xml_quote_pcdata {
  local $_=$_[0];
  s/&/&amp;/g;
  s/>/&gt;/g;
  s/</&lt;/g;
  return $_;
}


=item write ($output,$fsfile)

Write TrXML file

=cut

sub write {
  my ($output, $fsfile) = @_;

  die "Require GLOB reference\n" unless ref($output);

  # xml_decl
  print $output "<?xml";
  if ($fsfile->metaData('xmldecl_version') ne "") {
    print $output " version=\"".$fsfile->metaData('xmldecl_version')."\"";
  } else {
    print $output " version=\"1.0\"";
  }
  if ($fsfile->encoding() ne "") {
    print $output " encoding=\"".$fsfile->encoding()."\"";
  }
  if ($fsfile->metaData('xmldecl_standalone') ne "") {
    print $output " standalone=\"".$fsfile->metaData('xmldecl_standalone')."\"";
  }
  print $output "?>\n";

  print $output ("<!DOCTYPE trees PUBLIC \"-//CKL.MFF.UK//DTD TrXML V1.0//EN\"".
		 " \"http://ufal.mff.cuni.cz/~pajas/tred.dtd\" [\n".
		 "<!ENTITY % trxml.attributes \"".
		 join("\n",map { "  $_ CDATA #IMPLIED" }
		      grep { !/^(?:ORD|HIDE|ID)$/ } $fsfile->FS->attributes).
		 "\">\n]>\n");
  print $output "<!-- Time-stamp: <".localtime()." TrXMLBackend> -->\n";
  print $output "<trees>\n";

  my @meta=grep { !/^xmldecl_/ } $fsfile->listMetaData();
  if (@meta) {
    print $output "<info>\n";
    foreach (@meta) {
      print $output "  <meta name=\"$_\" content=\"".xml_quote($fsfile->metaData($_))."\"/>\n";
    }
    print $output "</info>\n";
  }

  print $output "<types full=\"1\">\n";
  foreach my $atr (grep { !/^(?:ORD|HIDE|ID)$/ } $fsfile->FS->attributes) {
    print $output "  <t n=\"$atr\"";
    if ($fsfile->FS->isList($atr)) {
      print $output " v=\"",xml_quote(join("|",$fsfile->FS->listValues($atr))),"\"";
    }
    print $output "/>\n";
  }
  print $output "</types>\n";

  foreach my $tree ($fsfile->trees) {
    my $node=$tree;
    NODE: while ($node) {
      print $output "<nd";
      print $output
	map { " $_=\"".xml_quote($node->{$_})."\"" }
	  grep { $node->{$_} ne "" }
	    grep { !/^(?:ORD|HIDE|ID)$/ } $fsfile->FS->attributes;
      print $output ">\n";
      if ($node->firstson) {
	$node=$node->firstson;
	next;
      }
      while ($node) {
	print $output "</nd>\n";
	if ($node->rbrother) {
	  $node=$node->rbrother;
	  next NODE;
	}
	$node=$node->parent;
      }
    }
  }
  print $output "</trees>\n";
}


# SAX TrXML to FSFile transducer
package XML::Handler::TrXML2FS;
use strict;
use Fslib;

sub decode {
  my ($self, $str)=@_;
  my $enc=$self->{FSFile}->encoding();
  if ($]>=5.008 or $enc eq "") {
    return $str;
  } else {
    print "encoding: $enc, $str\n";
    eval {
      $str = XML::LibXML::decodeFromUTF8($enc,$str);
    };
    print STDERR $@ if $@;
    return $str;
  }
}

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub start_document {
  my ($self,$hash) = @_;
  print "$hash, ",keys(%$hash),"\n";
  print map {"$_ => $hash->{$_}\n"} keys %$hash;
  $self->{FSFile} ||= FSFile->new();
  $self->{FSAttrs} ||= [];
}

sub end_document {
  my ($self) = @_;
  $self->{FSFile}->changeFS(
    FSFormat->create(
		     @{$self->{FSAttrs}},
		     '@N ORD', '@H HIDE', '@K ID'
		    ));
  $self->{FSFile};
}

sub xml_decl {
  my ($self,$data) = @_;
  $self->{FSFile}->changeEncoding($data->{Encoding});# || 'iso-8859-2');
  $self->{FSFile}->changeMetaData('xmldecl_version' => $data->{Version});
  $self->{FSFile}->changeMetaData('xmldecl_standalone' => $data->{Standalone});
}

sub characters {
  # nothing to do so far
}

sub start_element {
  my ($self, $hash) = @_;
  my $elem = $hash->{Name};
  my $attr = $hash->{Attributes};
  my $fsfile = $self->{FSFile};
#  my %attr = map { $_->{Name} => $_->{Value} } values %$attr;

  # $elem eq 'tree' && do { } # nothing to do
  # $elem eq 'info' && do { } # nothing to do
  if ($elem eq 'meta') {

    $fsfile->changeMetaData($self->decode($attr->{'{}name'}->{Value}) =>
			    $self->decode($attr->{'{}content'}->{Value}));

  } elsif ($elem eq 'types') {

#    $fsfile->changeMetaData('TrXML types/@full' => $self->decode($attr->{'{}full'}->{Value}))
#      if (exists($attr->{'{}full'}));

  } elsif ($elem eq 't') {

    my $atrname = $attr->{'{}n'}->{Value};
    my $v = exists($attr->{'{}v'}) ? $self->decode($attr->{'{}v'}->{Value}) : "";

    push @{$self->{FSAttrs}}, '@P '.$atrname;
    push @{$self->{FSAttrs}}, '@L '.$atrname.'|'.$v if ($v ne "");
    # d and m not implemented
  } elsif ($elem eq 'nd') {

    my $parent = $self->{Node};
    my $new;
    if ($parent) {
      $self->{Node} = $new = FSNode->new();
    } else {
      undef $parent;
      $self->{Tree} = $self->{FSFile}->new_tree($self->{FSFile}->lastTreeNo+1);
      $self->{Node} = $new = $self->{Tree};
    }
    $new->{ORD}=$attr->{'{}n'}->{Value};
    $new->{HIDE}='hide'x$attr->{'{}h'}->{Value};
    $new->{ID}=$self->decode($attr->{'{}id'}->{Value});
    foreach (grep { !/^{}(?:n|h|id)$/ } keys %$attr) {
      $new->{$self->decode($attr->{$_}->{Name})} = $self->decode($attr->{$_}->{Value});
    }
    Fslib::Paste($new,$parent,FSFormat->new({ ORD => ' N'},['ORD'])) if ($parent);
  }
  $self->{attributes}=$attr;
}

sub end_element {
  my ($self,$hash) = @_;

  if ($hash->{Name} eq 'nd') {
    $self->{Node}=$self->{Node}->parent;
  } elsif ($hash->{Name} eq 'trees') {
    $self->{Node}=undef;
  }
}

sub entity_reference {
}

sub start_cdata { # not much use for this
  my $self = shift;
  $self->{InCDATA} = 1;
}

sub end_cdata { # not much use for this
  my $self = shift;
  $self->{InCDATA} = 0;
}

sub comment {
  my $self = $_[0];
  my $data = $_[1];
  if ($self->{Node}) {
    $self->{Node}->{xml_comment}.='<!--'.$data.'-->';
  }
}

sub doctype_decl { # not use for this, so far
  my ($self,$hash) = @_;
  foreach (qw(Name SystemId PublicId Internal)) {
    $self->{"DocType_$_"} = $hash->{$_};
  }
}

1;

