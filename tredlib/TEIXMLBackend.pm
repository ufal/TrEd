## This is a simple XML backend for TEI files     -*-cperl-*-
## author: Petr Pajas
# $Id$ '
#############################################################

package TEIXMLBackend;
use Fslib;
use XML::LibXML;
use XML::LibXML::SAX;
use strict;

sub test {
  # should be replaced with some better magic-test for TEI XML
  my ($f,$encoding)=@_;

  if (ref($f)) {
    my $line1=$f->getline();
    my $line2=$f->getline();
    return ($line1 =~ /^\s*<\?xml / and ($line2 =~ /^\s*<p[\s>]/
	   or $line2 =~ /^\s*<text>/ or $line2 =~/^<!DOCTYPE text /));
  } else {
    my $fh = ZBackend::open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

sub open_backend {
  my ($filename, $mode,$encoding)=@_;
  if ($mode eq 'r') {
    return $_[0];
  } else {
    return ZBackend::open_backend($filename, $mode, $encoding);
  }
}

sub close_backend {
  my ($fh)=@_;
  if (ref($fh)) {
    return $fh->close();
  } else {
    return 1;
  }
}

=item read ($input,$fsfile)

Read TEI XML file used in SDT for morphological and analytical annotation.

=cut

sub read {
  my ($input,$fsfile) = @_;
  #my $handler = XML::SAX::Writer->new();
  my $handler = XML::Handler::TEIXML2FS->new(FSFile => $fsfile);
  my $p = XML::LibXML::SAX->new(Handler => $handler);
  if (ref($input)) {
    $p->parse_fh($input);
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

Write TEI XML file used in SDT for morphological and analytical annotation.

=cut

sub write {
  my ($output, $fsfile) = @_;

  die "Require GLOB reference\n" unless ref($output);

  my $rootdep='';
  if ($fsfile->FS->exists('dep') &&
      $fsfile->FS->isList('dep')) {
    ($rootdep)=$fsfile->FS->listValues('dep');
  }
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

  if ($fsfile->metaData('xml_doctype')) {
    my $properties=$fsfile->metaData('xml_doctype');
    unless ($properties->{'Name'}) {
      my $output = "DOCTYPE ".$properties->{'Name'};
      $output .= ' SYSTEM "'.$properties->{'SystemId'}.'"' if $properties->{'SystemId'};
      $output .= ' PUBLIC "'.$properties->{'PublicId'}.'"' if $properties->{'PublicId'};
      $output .= ' '.$properties->{'Internal'} if $properties->{'Internal'};
      print $output "<!",$output,">";
    }
  }

  print $output "<text>\n";
  # declare all list attributes as fLib. If fLib info exists, use it
  # to get value identifiers
  foreach my $attr (grep { $fsfile->FS->isList($_) } $fsfile->FS->attributes) {
    my %valids;
    if (ref($fsfile->metaData('fLib'))) {
      my $flib=$fsfile->metaData('fLib');
      if (exists($flib->{$attr})) {
	foreach (@{$flib->{$attr}}) {
	  $valids{$_->[1]} = $_->[0];
	}
      }
    }
    print $output "<fLib>\n";
    foreach ($fsfile->FS->listValues($attr)) {
      print $output "<f";
      print $output " id=\"$valids{$_}\"" if (exists($valids{$_}) and $valids{$_} ne "");
      print $output " name=\"$attr\">",
	"<sym value=\"$_\"/></f>\n";
    }
    print $output "</fLib>\n";
  }
  print $output "<body>\n";
  print $output "<p";
  if ($fsfile->tree(0)) {
    my $tree0=$fsfile->tree(0);
    foreach ($fsfile->FS->attributes()) {
      print $output " $1=\"".xml_quote($tree0->{$_})."\""
	if (/^p_(.*)$/ and $tree0->{$_} ne "");
    }
  }
  print $output ">\n";

  foreach my $tree ($fsfile->trees) {
    print $output "<s";
    foreach ($fsfile->FS->attributes()) {
      print $output " $1=\"".xml_quote($tree->{$_})."\""
	if (/^s_(.*)/ and $tree->{$_} ne "");
    }
    print $output ">\n";

    foreach my $node (sort { $a->{ord} <=> $b->{ord} } $tree->descendants) {
      my $type=$node->{type} || "w";
      print $output "<$type";
      foreach (grep { exists($node->{$_}) and
		      defined($node->{$_}) and 
		      !/^[sp]_|^(?:form|type|ord|dep)$/ }
	       $fsfile->FS->attributes()) {
	print $output " $_=\"".xml_quote($node->{$_})."\"";
      }
      print $output " dep=\"".
	xml_quote($node->parent->parent ? $rootdep : $node->parent->{id})."\"";
      print $output ">";
      print $output xml_quote_pcdata($node->{form});
      print $output "</$type>\n";
    }

    print $output "</s>\n";
  }

  print $output "</p>\n";
  print $output "</body>\n";
  print $output "</text>\n";
}


# SAX TEI-XML to FSFile transducer
package XML::Handler::TEIXML2FS;
use strict;
use Fslib;

sub new {
  my ($class, %args) = @_;
  bless \%args, $class;
}

sub start_document {
  my ($self,$hash) = @_;
  $self->{FSFile} ||= FSFile->new();
}

sub end_document {
  my ($self) = @_;
  my @header = ('@V form','@V form','@N ord');
  foreach my $attr (keys(%{$self->{FSAttrs}})) {
    push @header, '@P '.$attr;
    if (exists($self->{FSAttrSyms}->{$attr})
	and ref($self->{FSAttrSyms}->{$attr})) {
      my ($list);
      foreach (@{$self->{FSAttrSyms}->{$attr}}) {
	$list.="|$_->[1]";
      }
      push @header, '@L '.$attr.$list;
    }
  }
  $self->{FSFile}->changeFS(FSFormat->create(@header));
  $self->{FSFile}->changeMetaData('fLib' => $self->{FSAttrSyms});
  $self->{FSFile};
}

sub xml_decl {
  my ($self,$data) = @_;
  $self->{FSFile}->changeEncoding($data->{Encoding} || 'iso-8859-2');
  $self->{FSFile}->changeMetaData('xmldecl_version' => $data->{Version});
  $self->{FSFile}->changeMetaData('xmldecl_standalone' => $data->{Standalone});
}

sub characters {
  my ($self,$hash) = @_;
  return unless $self->{Node};
  if (($self->{Node}{type} eq 'w') or
      ($self->{Node}{type} eq 'c')) {
    my $str = $hash->{Data};
    if ($]>=5.008) {
      # leave data in the UTF-8 encoding
      $self->{Node}->{form}.=$str;
    } else {
      $self->{Node}->{form}=$self->{Node}->{form}.
	XML::LibXML::decodeFromUTF8($self->{FSFile}->encoding(),$str);
    }
  }
}

sub start_element {
  my ($self, $hash) = @_;
  my $elem = $hash->{Name};
  my $attr = $hash->{Attributes};
  my $fsfile = $self->{FSFile};

  if ($elem eq 'p') {
    $self->{DocAttributes}=$attr;
  } elsif ($elem eq 'f') {
    $self->{CurrentFSAttr}=$attr->{"{}name"}->{Value};
    $self->{CurrentFSAttrID}=$attr->{"{}id"}->{Value};
    $self->{FSAttrs}->{$attr->{"{}name"}->{Value}}=1;
  } elsif ($elem eq 'sym') {
    push @{$self->{FSAttrSyms}->{$self->{CurrentFSAttr}}},
      [$self->{CurrentFSAttrID},$attr->{"{}value"}->{Value}];
  } elsif ($elem eq 's') {
    $self->{Tree} = $self->{FSFile}->new_tree($self->{FSFile}->lastTreeNo+1);
    $self->{Node} = $self->{Tree};
    $self->{Node}->{ord} = 0;
    $self->{LastOrd} = 0;
    $self->{Node}->{type}=$elem;
    $self->{Node}->{form}='#'.($self->{FSFile}->lastTreeNo+1);
    if (ref($attr)) {
      foreach (values %$attr) {
	$self->{Node}->{'s_'.$_->{Name}} = ($]>=5.008) ? $_->{Value} :
	  XML::LibXML::decodeFromUTF8($self->{FSFile}->encoding(),$_->{Value});
	$self->{FSAttrs}->{'s_'.$_->{Name}}=1;
      }
      $self->{IDs}->{$self->{Node}->{id}}=$self->{Node}
	if ($self->{Node}->{id} ne '');
    }
    if ($self->{FSFile}->lastTreeNo == 0 and ref($self->{DocAttributes})) {
      foreach (values %{$self->{DocAttributes}}) {
	# leave data in the UTF-8 encoding in Perl 5.8
	$self->{Node}->{'p_'.$_->{Name}} = ($]>=5.008) ? $_->{Value} :
	  XML::LibXML::decodeFromUTF8($self->{FSFile}->encoding(),$_->{Value});
	$self->{FSAttrs}->{"p_".$_->{Name}}=1;
      }
    }
  } elsif ($elem eq 'w' or $elem eq 'c') {
    $self->{Node} = FSNode->new();
    $self->{Node}->{type}=$elem;
    $self->{Node}->{ord} = ++($self->{LastOrd});
    Fslib::Paste($self->{Node},$self->{Tree},{ ord => ' N'});
    if (ref($attr)) {
      foreach (values %$attr) {
	$self->{Node}->{$_->{Name}} = ($]>=5.008) ? $_->{Value} :
	  XML::LibXML::decodeFromUTF8($self->{FSFile}->encoding(),$_->{Value});
	$self->{FSAttrs}->{$_->{Name}}=1;
      }
      $self->{IDs}->{$self->{Node}->{id}}=$self->{Node}
	if ($self->{Node}->{id} ne '');
    }
  }
}

sub end_element {
  my ($self) = @_;
  if ($self->{Node} and $self->{Node}->{type} eq 's') {
    # build the tree (no consistency checks at all)
    my @nodes=$self->{Tree}->descendants;
    foreach my $node (@nodes) {
      my $dep=$node->{dep};
      if ($dep ne '' and
	  ref($self->{IDs}{$dep})) {
	Fslib::Paste(Cut($node),$self->{IDs}{$dep}, { ord => ' N' });
      }
    }
  }
  $self->{Node} = $self->{Node}->parent if ($self->{Node});
}

sub entity_reference {
  my $self = $_[0];
  my $name = $_[1]->{Name};
  if ($self->{Node}->{type} eq 'w' or
      $self->{Node}->{type} eq 'c') {
    $self->{Node}->{form}.='&'.$name.';';
  }
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

sub doctype_decl { # unfortunatelly, not called by the parser, so far
  my ($self,$hash) = @_;
  $self->{FSFile}->changeMetaData("xml_doctype" => $hash);
}

1;

