package PMLBackend;
use Fslib;
use IOBackend qw(close_backend);
use strict;

use XML::Simple; # for PML schema
use XML::LibXML;
use XML::LibXML::Common qw(:w3c :encoding);
use XML::Writer;

  use Data::Dumper;


use vars qw(@pmlformat @pmlpatterns $pmlhint $encoding $DEBUG);

$DEBUG=0;

use constant {
  LM => 'LM',
  AM => 'AM',
  PML_NS => "http://ufal.mff.cuni.cz/pdt/pml/"
};



$encoding='utf8';
@pmlformat = (
);

@pmlpatterns = (
'<?$${form} unless $${form} eq \'???\' ?>${trace}${label}',
'style:#{Line-coords:n,n,n,p&n,p,p,p}'
);

$pmlhint="";

sub _debug {
  print "PMLBackend: ",@_,"\n" if $DEBUG;
}


=item open_backend (filename,mode)

Only reading is supported now!

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  return IOBackend::open_backend($filename,$mode); # discard encoding
}

=pod

=pod

=item read (handle_ref,fsfile)

=cut

sub index_by_id {
  my ($dom) = @_;
  my %index;
  my $node=$dom->getDocumentElement();
  while ($node) {
    my $next;
    if ($node->nodeType == ELEMENT_NODE) {
      my $id = $node->getAttribute('id');
      $index{$id}=$node if defined($id);
      $next = $node->firstChild || $node->nextSibling;
    } else {
      $next = $node->nextSibling;
    }
    if ($next) {
      $node = $next;
      next;
    } else {
      $node = $node->parentNode;
      $node = $node->parentNode while ($node and !$node->nextSibling);
      $node = $node->nextSibling if $node;
    }
  }
  return \%index;
}

sub index_fs_by_id {
  my ($fsfile) = @_;
  my %index;
  foreach my $node ($fsfile->trees) {
    while ($node) {
      $index{$node->{id}}=$node if $node->{id} ne "";
    } continue {
      $node=$node->following;
    }
  }
  return \%index;
}

sub read ($$) {
  my ($input, $fsfile)=@_;
  return unless ref($fsfile);

  $fsfile->changeEncoding($encoding);
  $fsfile->changeTail("(1)\n");
  $fsfile->changePatterns(@pmlformat);
  $fsfile->changeHint($pmlhint);

  my $parser = XML::LibXML->new();
  $parser->line_numbers(1);
  $parser->load_ext_dtd(0);
  $parser->validation(0);

  my $dom = $parser->parse_fh($input);
  $parser->process_xincludes($dom);

  my $dom_root = $dom->getDocumentElement();
  my $return;
#  $fsfile->FS->defs->{id}=' K';
  read_references($fsfile,$dom_root);

  unless (ref($fsfile->metaData('schema'))) {
    die "Unknown XML data: ",$dom_root->localname()," ",$dom_root->namespaceURI(),"\n";
  }
  $return = read_trees($parser, $fsfile,$dom_root);
#  @{$fsfile->FS->list} = grep {$_ ne $Fslib::special } sort keys %{$fsfile->FS->defs};
  return $return;
}


sub read_references {
  my ($fsfile,$dom_root)=@_;
  my %references;
  my %named_references;
  my ($head) = $dom_root->getElementsByTagNameNS(PML_NS,'head');
  if ($head) {
    my ($references) = $head->getElementsByTagNameNS(PML_NS,'references');
    if ($references) {
      foreach my $reffile ($references->getElementsByTagNameNS(PML_NS,'reffile')) {
	my $id = $reffile->getAttribute('id');
	my $name = $reffile->getAttribute('name');
	$named_references{ $name } = $id if $name;
	$references{ $id } = Fslib::ResolvePath($fsfile->filename,$reffile->getAttribute('href'),0);
      }
    }
    my ($schema) = $head->getElementsByTagNameNS(PML_NS,'schema');
    if ($schema) {
      my $schema_file = Fslib::ResolvePath($fsfile->filename,$schema->getAttribute('href'),1);
      $fsfile->changeMetaData('schema-url',$schema_file);
      $fsfile->changeMetaData('schema',Fslib::Schema->readFrom($schema_file));
    }
  }
  $fsfile->changeMetaData('references',\%references);
  $fsfile->changeMetaData('refnames',\%named_references);
}

=item read_List($node)

If a given DOM node contains a pml:List, return a list of its members,
otherwise return the node itself.

=cut

sub read_List ($) {
  my ($node)=@_;
  return unless $node;
  my $List = $node->getChildrenByTagNameNS(PML_NS,LM);
  return @$List ? @$List : $node;
}

=item read_Sequence($node)

Child-elements of a given DOM nodes are mapped to
{ type => 'element', name => $name, value => $value } hashes. 
Text child-nodes are converted to { type => 'text', value => $cdata }.

=cut

sub read_Sequence ($$$$) {
  my ($child,$fsfile,$types,$type)=@_;
  my $list=[];
  bless($list, 'Fslib::List');
  return $list unless $child;
  while ($child) {
    if ($child->nodeType == ELEMENT_NODE) {
      my $name = $child->localName;
      my $ns = $child->namespaceURI;
      my $is_pml = ($ns eq PML_NS);
      if ($type->{element}{$name} and 
	    ($ns eq "" or $is_pml or $type->{element}{$name}{ns} eq $ns)) {
	my $element = read_element($child,$fsfile,$types,resolve_type($types,$type->{element}{$name}));
	push @$list, $element;
      } else {
	die "Undeclared ".
	  ($is_pml 
	     ? "pml-element "
	       : ($ns ne "" ? "element {$ns} " : "element"))." ".
		 _element_address($child);
      }
    } elsif (($child->nodeType == TEXT_NODE or $child->nodeType == CDATA_SECTION_NODE)
	       and $child->getData =~ /\S/) {
      if ($type->{role} eq '#CHILDNODES') {
	warn "Ignoring text node '".$child->getData."' in #CHILDNODES sequence in "._element_address($child->parentNode);
      } elsif ($type->{text}) {
	push @$list, {
	  '#type' => 'text',
	  '#content' => read_node($child,$fsfile,$types,resolve_type($types,$type->{text}))
	 }
      }
    }
  } continue {
    $child = $child->nextSibling;
  };
  return $list;
}

=item read_Alt($node)

If given DOM node contains a pml:Alt, return a list of its members,
otherwise return the node itself.

=cut

sub read_Alt ($) {
  my ($node)=@_;
  return unless $node;
  my $Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
  return @$Alt ? @$Alt : $node;
}


sub resolve_type ($$) {
  my ($types,$type)=@_;
  return $type unless ref($type);
  if ($type->{type}) {
    my $rtype = $types->{$type->{type}};
    return $rtype || $type->{type};
  } else {
    return $type;
  }
}

sub _element_address {
  my ($node)=@_;
  return "'".$node->localname."' at line ".$node->line_number."\n";
}

sub node_children {
  my ($node,$list)=@_;
  my $prev=0;
  foreach my $son (@{$list}) {
    unless (ref($son) eq 'FSNode') {
      use Data::Dumper;
      die "non-#NODE child '".Dumper($son)."'\n";
      return;
    }
    $son->{$Fslib::parent} = $node;
      $son->{$Fslib::lbrother} = $prev;
    $prev->{$Fslib::rbrother} = $son if $prev;
    $prev = $son;
  }
  $node->{$Fslib::firstson} = $list->[0];
}

sub read_element ($$$;$) {
  my ($node,$fsfile,$types,$type) = @_;
  my $hash;
  if (ref($type) and $type->{role} eq '#NODE') {
    $hash =  FSNode->new();
    $hash->set_type($fsfile->metaData('schema')->type($type));
  } else {
    $hash={};
  }
  my $name = $node->localName;
  my $ns = $node->namespaceURI;
  my $is_pml = ($ns eq PML_NS);
  $hash->{'#type'} = ($ns eq PML_NS ? 'pml-element' : 'element');
  $hash->{'#ns'} = $ns unless ($ns eq "" or $is_pml);
  $hash->{'#name'} = $name;
  foreach my $attr ($node->attributes) {
    my $name  = $attr->nodeName;
    my $value = $attr->value;
    if (ref($type) and $type->{attribute}{$name}) {
      $hash->{$name} = $value;
    } else {
      warn "Undeclared attribute '$name' of "._element_address($node);
    }
  }
  my $value = read_node($node,$fsfile,$types,$type);
  if (ref($type) and $type->{role} eq '#NODE' and
      ($type->{sequence} and $type->{sequence}{role} eq '#CHILDNODES' or
	 $type->{list} and $type->{list}{role} eq '#CHILDNODES') and
	   UNIVERSAL::isa($value,'Fslib::List')) {
    node_children($hash,$value);
  } else {
    $hash->{'#content'}=$value;
  }
  return $hash;
}

sub read_node ($$$;$) {
  my ($node,$fsfile,$types,$type) = @_;
  my $defs = $fsfile->FS->defs;
  if ($type eq 'PMLREF' or $type eq 'CDATA' or $type eq 'nonNegativeInteger') {
    # pre-defined atomic types
    return $node->textContent;
  }
  unless (ref($type)) {
    die "Unknown node type: $type\n";
  }

  if (exists $type->{list}) {
    return bless [
      map {
	read_node($_,$fsfile,
		  $types,resolve_type($types,$type->{list}))
      } read_List($node)
    ], 'Fslib::List';
  } elsif (exists $type->{sequence}) {
    return read_Sequence($node->firstChild,$fsfile,$types,$type->{sequence});
  } elsif (exists $type->{structure}) {
    # structure
    my $struct = $type->{structure};
    my $members = $struct->{member};
    my $hash;
    if ($type->{role} eq '#NODE' or $struct->{role} eq '#NODE') {
      $hash=FSNode->new();
      $hash->set_type($fsfile->metaData('schema')->type($type->{structure}));
    } else {
      $hash={}
    }
    foreach my $attr ($node->attributes) {
      my $name  = $attr->nodeName;
      my $value = $attr->value;
      if ($members->{$name} and 
	  $members->{$name}{as_attribute}) {
	$hash->{$name} = $value;
      } elsif ($members->{$name}) {
	warn "Member '$name' not declared as attribute of "._element_address($node);
      } else {
	warn "Undeclared attribute '$name' of "._element_address($node);
      }
    }

#    foreach my $child ($node->findnodes('*')) {
#    foreach my $child ($node->getChildrenByTagNameNS(PML_NS,'*')) {
#    foreach my $child ($node->findnodes('*[namespace-uri()="'.PML_NS.'"]')) {
    foreach my $child ($node->childNodes) {
#    my $child = $node->firstChild;
#    while ($child) {
      my $child_nodeType = $child->nodeType;
      if($child_nodeType == ELEMENT_NODE
	 and
	 $child->namespaceURI eq PML_NS) {
	my $name = $child->localname;
	my $member = $members->{$name};
	if ($member) {
	  my $role;
	  $role = $member->{role} if ref($member);
	  $member = resolve_type($types,$member);
	  $role ||= $member->{role} if ref($member);
	  if (ref($member) and $role eq '#CHILDNODES') {
	    if ($member->{list} or $member->{sequence}) {
	      if (ref($hash) eq 'FSNode') {
		my $list = read_node($child,$fsfile, $types,$member);
		node_children($hash, $list);
	      } else {
		use Data::Dumper;
		die "#CHILDNODES member '$name' encountered in non-#NODE element '".$node->localname.
		  "' at line ".$child->line_number."\n";
	      }
	    } else {
		die "#CHILDNODES member '$name' is neither a list nor a sequence in '".$node->localname.
		  "' at line ".$child->line_number."\n";
	    }
	  } elsif (ref($member) and $role eq '#KNIT') {
	    my $ref = $child->textContent();
	    _debug("KNIT: name=$name, '$ref'");
	    if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
	      my ($reffile,$idref)=($1,$2);
	      $fsfile->changeAppData('ref',{}) unless ref($fsfile->appData('ref'));
	      my $refdom = ($reffile ne "") ? $fsfile->appData('ref')->{$reffile} : $child->ownerDocument;
	      if (ref($refdom)) {
		$fsfile->changeAppData('ref-index',{}) unless ref($fsfile->appData('ref-index'));
		my $refnode =
		  $fsfile->appData('ref-index')->{$reffile}{$idref} ||
		    $refdom->getElementsById($idref);
		if (ref($refnode)) {
		  my $ret = read_node($refnode,$fsfile,$types,$member);
		  $name =~ s/\.rf$//;
		  $hash->{$name} = $ret;
		  if (ref($ret) and $ret->{id}) {
		    $ret->{id} = $reffile.'#'.$ret->{id};
		  }
		} else {
		  warn "warning: ID $idref not found in '$reffile'\n";
		  $hash->{$name} = $ref;
		}
	      } else {
		warn "Reference to $ref cannot be resolved - document '$reffile' not loaded\n";
		$hash->{$name} = $ref;
	      }
	    } else {
	      $hash->{$name} = $ref;
	    }
	  } else {
	    if ($role eq "#ORDER") {
	      $defs->{$name} = ' N' unless exists($defs->{$name});
	    } elsif ($role eq "#HIDE") {
	      $defs->{$name} = ' H' unless exists($defs->{$name});
#	    } else {
#	      $defs->{$name} = ' K' unless exists($defs->{$name});
	    }
	    $hash->{$name} = read_node($child,$fsfile,
						   $types,
						   $member);
	  }
	} else {
	  die "Undeclared member '$name' in '".$node->localname."' encountered".
		  " at line ".$child->line_number."\n";
	}
     } elsif (($child_nodeType == TEXT_NODE
		or $child_nodeType == CDATA_SECTION_NODE)
		and $child->data=~/\S/) {
	warn "Ignoring text content '".$child->data."'.\n";
     } elsif ($child_nodeType == ELEMENT_NODE
	       and $child->namespaceURI eq PML_NS) {
	warn "Ignoring non-PML element '".$child->nodeName."'.\n";
     }
#    } continue {
#      $child = $child->nextSibling;
    }
    foreach (keys %{$members}) {
      if (!exists($hash->{$_})) {
	my $member = $members->{$_};
	if ($member->{required}) {
	  die "Missing required member '$_' of '".
	    $node->localname."' at line ".$node->line_number."\n";
	} else {
	  my $mtype = resolve_type($types,$member);
	  if (ref($mtype) and exists($mtype->{constant})) {
	    $hash->{$_}=$mtype->{constant};
	  }
	}
      }
    }
    return $hash;
  } elsif (exists $type->{choice}) {
    my $data = $node->textContent();
    my $ok;
    warn "$type->{choice} at ".$node->nodeName."\n" unless ref($type->{choice}) eq 'ARRAY';
    foreach (@{$type->{choice}}) {
      if ($_ eq $data) {
	$ok = 1;
	last;
      }
    }
    unless ($ok) {
      die "Invalid value '$data' for '".$node->localname."' (expected one of: ".join(',',@{$type->{choice}}).")\n";
    }
    return $data;
  } elsif (exists $type->{constant}) {
    my $data = $node->textContent();
    if ($data ne "" and $data ne $type->{constant}) {
      die "Invalid value '$data' for constant '".$node->localname."' (expected $type->{constant})\n";
    }
    return $data;
  } elsif (exists $type->{alt}) {
    # alt
    my $Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
    if (@$Alt) {
      return bless [
	map {
	  read_node($_,$fsfile,
				$types,resolve_type($types,$type->{alt}))
	} @$Alt,
       ], 'Fslib::Alt';
    } else {
      return read_node($node,$fsfile,
				   $types,
				   resolve_type($types,$type->{alt}));
    }


  }
}

sub read_trees {
  my ($parser, $fsfile, $dom_root) = @_;
  my $references = $fsfile->metaData('schema')->{reference};
  if ($references) {
    foreach my $reference (@$references) {
      my $refid = $fsfile->metaData('refnames')->{$reference->{name}};
      if ($refid) {
	my $href = $fsfile->metaData('references')->{$refid};
	if ($href and $reference->{readas} =~ /^(?:dom|trees)$/) {
	  _debug("Found '$reference->{name}' as $refid# = '$href'");
	  if ($reference->{readas} eq 'trees') {
	    my $requires = ($fsfile->metaData('fs-require') || []);
	    push @$requires,[$refid,$href];
	    $fsfile->changeMetaData('fs-require',$requires);
	  } elsif ($reference->{readas} eq 'dom') {
	    my $ref_data;
	    my $ref_fh = open_backend($href,'r');
	    _debug("$href $ref_fh");
	    if ($ref_fh){
	      $ref_data = $parser->parse_fh($ref_fh);
	      $parser->process_xincludes($ref_data);
	      close_backend($ref_fh);
	      $fsfile->changeAppData('ref',{}) unless ref($fsfile->appData('ref'));
	      $fsfile->appData('ref')->{$refid}=$ref_data;
	      $fsfile->changeAppData('ref-index',{}) unless ref($fsfile->appData('ref-index'));
	      $fsfile->appData('ref-index')->{$refid}=index_by_id($ref_data);
	      _debug("Stored meta 'ref' -> '$reference->{name}' = $ref_data");
	    } else {
	      die "Couldn't open '".$href."': $!\n";
	    }
	  }
	} elsif ($href) {
	  die "Unknown readas method '$reference->{readas}'\n"
	} else {
	  die "No href for $refid# ($reference->{name})\n"
	}
      } else {
	warn "Didn't find any reference to '".$reference->{name}."'\n";
      }
    }
  }

  my $root_type = $fsfile->metaData('schema')->{root};
  my $types = $fsfile->metaData('schema')->{type};

  unless ($dom_root->namespaceURI eq PML_NS and
	  $dom_root->localname eq $root_type->{name}) {
    die "Expected root element '$root_type->{name}'\n";
  }

  # schema type 1: #TREES form a PML list
  if (UNIVERSAL::isa($root_type->{element},'HASH') and
      grep {
	UNIVERSAL::isa($_,'HASH') and
	$_->{role} eq '#TREES'
      } values %{$root_type->{element}}) {
    _debug("Found member with role \#TREES\n");

    for my $child ($dom_root->childNodes) {
      if ($child->nodeType == ELEMENT_NODE and
	    $child->namespaceURI eq PML_NS and
	      $root_type->{element}->{$child->localname}->{role} eq '#TREES') {
	_debug("found trees ",$child->localname);
	my $type = resolve_type($types,$root_type->{element}->{$child->localname});
	if ($type->{list}) {
	  my $trees = read_node($child,$fsfile,$types,$type);
	  if (ref($trees) eq 'Fslib::List') {
	    @{$fsfile->treeList} = @$trees
	  } else {
	    die "Expected 'Fslib::List', got $trees\n";
	    @{$fsfile->treeList} = ($trees);
	  }
	} else {
	  die "Expected 'list' in role #TREES\n";
	}
      } else {
	# TODO: store all non-#TREES members as meta-data
      }
    }
  } elsif (
    $root_type->{sequence} and
    UNIVERSAL::isa($root_type->{sequence},'HASH') and
    $root_type->{sequence}{role} eq '#TREES'
   ) {
    _debug("Found sequence with role \#TREES\n");
    # schema type 2: #TREES form a PML list
    for my $child ($dom_root->childNodes) {
      if ($child->nodeType == ELEMENT_NODE and $child->namespaceURI eq PML_NS and
	  $root_type->{sequence}{element}->{$child->localname}) {
	_debug("found tree ",$child->localname);
	my $list  = read_Sequence($child,$fsfile,$types,$root_type->{sequence});
	@{$fsfile->treeList} = @$list;
	last;
      } elsif ($child->nodeType == ELEMENT_NODE and $child->namespaceURI eq PML_NS and
	       $child->localname eq 'head') {
	# already read this one
      } else {
	warn("Ignoring element "._element_address($child),"\n");
	# TODO: store all other elements here + all attributes
      }
    }


  } else {
    die "No #TREES found in PML schema\n";
  }

}

=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  my ($fh,$fsfile)=@_;
  binmode $fh;
  binmode $fh,":utf8";
  my $xml =  new XML::Writer(OUTPUT => $fh,
			   DATA_MODE => 1,
			   DATA_INDENT => 1);
  unless (ref($fsfile->metaData('schema'))) {
    die "Can't write - document isn't associated with a schema\n";
  }

  my $root_type = $fsfile->metaData('schema')->{root};
  my $types = $fsfile->metaData('schema')->{type};
  my ($trees,$trees_tag);
  if (UNIVERSAL::isa($root_type->{element},'HASH')) {
    ($trees) = grep { UNIVERSAL::isa($_,'HASH') and $_->{role} eq '#TREES' } values %{$root_type->{element}};
    if ($trees) {
      $trees_tag = $trees->{-name};
    }
  } elsif (UNIVERSAL::isa($root_type->{sequence},'HASH') and $root_type->{sequence}{role} eq '#TREES') {
    $trees = $root_type->{sequence};
  }
  unless ($trees) {
    die "Can't write: didn't find any element or sequence with role #TREES\n";
  }

  $xml->xmlDecl("utf-8");
  $xml->startTag($root_type->{name},xmlns => PML_NS);
  $xml->startTag('head');
  $xml->emptyTag('schema', href => $fsfile->metaData('schema-url'));
  $xml->startTag('references');
  {
    my $references = $fsfile->metaData('references');
    my $named = $fsfile->metaData('refnames');
    my %names = $named ? (map { $named->{$_} => $_ } keys %$named) : ();
    if ($references) {
      foreach (keys %$references) {
	$xml->emptyTag('reffile', id => $_,
		       href => $references->{$_},
		       (exists($names{$_}) ? (name => $names{$_}) : ()));
      }
    }
  }
  $xml->endTag('references');
  $xml->endTag('head');

  my $tree_list = bless [$fsfile->trees],'Fslib::List';
  write_object($xml, $fsfile, $types,resolve_type($types,$trees),$trees_tag,$tree_list);
  $xml->endTag($root_type->{name});
  $xml->end;

  # write embedded DOM documents
  my $references = $fsfile->metaData('schema')->{reference};
  if ($references) {
    foreach my $reference (@$references) {
      my $refid = $fsfile->metaData('refnames')->{$reference->{name}};
      if ($refid) {
	my $href = $fsfile->metaData('references')->{$refid};
	if ($href and $reference->{readas} eq 'dom' and
	      ref($fsfile->appData('ref'))) {
	  my $dom = $fsfile->appData('ref')->{$refid};
	  if ($dom) {
	    my $ref_fh = IOBackend::open_backend($href,"w");
	    binmode $ref_fh;
	    $dom->toFH($ref_fh,1);
	    close $ref_fh;
	  }
	}
      }
    }
  }
  1;
}

sub write_object ($$$$$$) {
  my ($xml,$fsfile, $types,$type,$tag,$object)=@_;
  my $pre=$type;
  $type = resolve_type($types,$type);
  if (!ref($type)) {
    _debug("TYPE: $type (pre: $pre)\n");
    $xml->startTag($tag) if defined($tag);
    $xml->characters($object);
    $xml->endTag($tag) if defined($tag);
  } elsif (exists $type->{choice}) {
    my $ok;
    foreach (@{$type->{choice}}) {
      if ($_ eq $object) {
	$ok = 1;
	last;
      }
    }
    warn "Invalid value for '$tag': $object\n" unless ($ok);
    $xml->startTag($tag);
    $xml->characters($object);
    $xml->endTag($tag);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (ref($object)) {
      my %attribs;
      foreach my $atr (grep {$members->{$_}{as_attribute}}
			 sort keys %$members) {
	if ($members->{$atr}{required} or $object->{$atr} ne "") {
	  $attribs{$atr} = $object->{$atr};
	}
      }
      if (%attribs and !defined($tag)) {
	die "Can't write structure with attribute members without a tag";
      }
      $xml->startTag($tag,%attribs) if defined($tag);
      foreach my $member (
	grep {!$members->{$_}{as_attribute}} sort keys %$members) {
	if ($members->{$member}{role} eq '#CHILDNODES') {
	  if (ref($object) eq 'FSNode') {
	    if ($object->firstson or $members->{$member}{required}) {
	      write_object($xml, $fsfile, $types,$members->{$member},$member,
			   bless([ $object->children ],'Fslib::List'));
	    }
	  } else {
	    warn "Found #CHILDNODES member '$tag/$member' on a non-node value: $object\n";
	  }
	} elsif ($members->{$member}{role} eq '#KNIT') {
	  if ($object->{$member} ne "") {
	    _debug("#KNIT.rf $member");
	    $xml->startTag($member);
	    $xml->characters($object->{$member});
	    $xml->startTag($member);
	  } else {
	    my $name = $member;
	    $name =~ s/\.rf$//;
	    if (ref($object->{$name})) {
	      my $ref = $object->{$name}{id};
	      $xml->startTag($member);
	      $xml->characters($object->{$name}{id});
	      $xml->endTag($member);
	      if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
		my ($reffile,$idref)=($1,$2);
		my $indeces = $fsfile->appData('ref-index');
		if ($indeces and $indeces->{$reffile}) {
		  my $knit = $indeces->{$reffile}{$idref};
		  if ($knit) {
		    #_debug($knit->toString(1));
		    my $knit_tag = $name;
		    #		      $knit_tag = LM if ($knit->nodeName =~ /^(Alt|List)$/ and
		    #				     $knit->parentNode->namespaceURI eq PML_NS);
		    my $dom_writer = MyDOMWriter->new(REPLACE => $knit);
		    write_object($dom_writer, $fsfile, $types,
				 resolve_type($types,$members->{$member}),
				 $knit_tag, $object->{$name});
		    my $new = $dom_writer->end;
		    $new->setAttribute('id',$idref);
		    #_debug $dom_writer->end->toString(1));
		  } else {
		    warn "Didn't find ID $idref in $reffile - can't knit back!\n";
		  }
		} else {
		  warn "Knit-file $reffile has no index - can't knit back!\n";
		}
	      } else {
		_debug("$object = {\n",(map {"  $_ => $object->{$name}{$_}\n"} keys %{$object->{$name}}),"}");
		warn "Can't parse '$member' href '$ref' - can't knit back!\n";
	      }
	    }# else {
	    #	warn "Didn't find $name on the object! ",join(" ",%$object),"\n";
	    #      }
	  }
	} elsif ($object->{$member} ne "" or $members->{$member}{required}) {
	  write_object($xml, $fsfile, $types,$members->{$member},$member,$object->{$member});
	}
      }
      $xml->endTag($tag) if defined($tag);
    } else {
      # what do we do now?
      warn "Unexpected content structure '$tag': $object\n";
    }
  } elsif (exists $type->{list}) {
    if ($object ne "" and ref($object) eq 'Fslib::List') {
      if (@$object == 0) {
	# what do we do now?
#      } elsif (@$object == 1) {
#	write_object($xml, $fsfile,  $types,$type->{list},$tag,$object->[0]);
      } else {
	$xml->startTag($tag) if defined($tag);
	foreach my $member (@$object) {
	  _debug("Writing list-member $member $member->{t_lemma} as type ",%{$type->{list}},"\n") if (ref($member)eq'FSNode');
	  write_object($xml, $fsfile, $types,$type->{list},LM,$member);
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      warn "Unexpected content of List '$tag': $object\n";
    }
  } elsif (exists $type->{alt}) {
    if ($object ne "" and ref($object) eq 'Fslib::Alt') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	write_object($xml, $fsfile, $types,$type->{alt},$tag,$object->[0]);
      } else {
	$xml->startTag($tag) if defined($tag);
	foreach my $member (@$object) {
	  write_object($xml, $fsfile, $types,$type->{alt},AM,$member);
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      write_object($xml, $fsfile, $types,$type->{alt},$tag,$object);
    }
  } elsif (exists $type->{sequence}) {
    $xml->startTag($tag) if defined($tag);
    if (UNIVERSAL::isa($object,'Fslib::List')) {
      foreach my $element (@$object) {
	if ($element->{'#type'} eq 'text') {
	  if ($type->{sequence}{text}) {
	    $xml->characters($element->{'#content'});
	  } else {
	    warn "Text node is not allowed in sequence '$tag'\n";
	  }
	} elsif ($element->{'#type'} eq 'pml-element') {
	  my $eltype = $type->{sequence}{element}{$element->{'#name'}};
	  if ($eltype) {
	    my %attribs;
	    foreach my $atr (keys(%{$eltype->{attribute}})) {
	      $attribs{$atr} = $object->{$atr};
	    }
	    $xml->startTag($element->{'#name'},%attribs);
	    write_object($xml, $fsfile, $types,$eltype,undef,$object->{'#content'});
	    $xml->endTag($element->{'#name'});
	  } else {
	    warn "PML-element '".$element->{'#name'}."' node is not allowed in sequence '$tag'\n";
	  }
	} elsif ($element->{'#type'} eq 'element') {
	  # TODO:
	  # similar but with a namespace, etc...

	  warn "Writing non-pml elements not yet supported\n";
	}
      }
    } else {
      warn "Unexpected content of sequence '$tag': $object\n";
    }
    $xml->endTag($tag) if defined($tag);

  }
}


=pod

=item test (filehandle | filename, encoding?)

=cut

sub test {
  my ($f,$encoding)=@_;

  if (ref($f)) {
    local $_;
    1 while ($_=$f->getline() and !/\S/);
    return 0 unless (/^\s*<\?xml\s/);
    return 1 if /<[atxmw]data/;
    1 while ($_=$f->getline() and !/\S/);
    return (/<[atxmw]data/) ? 1 : 0;
  } else {
    my $fh = IOBackend::open_backend($f,"r");
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

  package MyDOMWriter;
  sub new {
    my ($class,%args)=@_;
    $class = ref($class) || $class;

    unless ($args{DOM} || $args{ELEMENT} || $args{REPLACE} ) {
      die "Usage: $class->new(ELEMENT => XML::LibXML::Document)\n";
    }
    if ($args{ELEMENT}) {
      $args{DOM} ||= $args{ELEMENT}->ownerDocument;
    } else {
      $args{DOM} ||= $args{REPLACE}->ownerDocument;
    }
    return bless \%args,$class;
  }
  sub end {
    my ($self)=@_;
    return $self->{REPLACEMENT} || $self->{ELEMENT};
  }
  sub startTag {
    my ($self,$name,@attrs)=@_;
    if ($self->{ELEMENT}) {
      $self->{ELEMENT} = $self->{ELEMENT}->addNewChild($self->{NS},$name);
    } elsif ($self->{REPLACE}) {
      $self->{ELEMENT} = $self->{DOM}->createElementNS($self->{NS},$name);
      $self->{REPLACE}->replaceNode($self->{ELEMENT});
      $self->{REPLACEMENT} = $self->{ELEMENT};
      delete $self->{REPLACE};
    } else {
      $self->{ELEMENT} = $self->{DOM}->createElementNS($self->{NS},$name);
      $self->{DOM}->setDocumentElement($self->{ELEMENT});
    }
    for (my $i=0; $i<@attrs; $i+=2) {
      $self->{ELEMENT}->setAttribute( $attrs[$i] => $attrs[$i+1] );
    }
  }
  sub endTag {
    my ($self,$name)=@_;
    if ($name ne "") {
      if ($self->{ELEMENT} and $self->{ELEMENT}->nodeName eq $name) {
	$self->{ELEMENT} = $self->{ELEMENT}->parentNode;
      } else {
	die "Can't end ".
	  ($self->{ELEMENT} ? '<'.$self->{ELEMENT}->nodeName.'>' : 'none').
	    " with </$name>\n";
      }
    }
  }
  sub characters {
    my ($self,$pcdata) = @_;
    if ($self->{REPLACE}) {
      $self->{REPLACEMENT} = $self->{DOM}->createTextNode($pcdata);
      $self->{REPLACE}->replaceNode($self->{REPLACEMENT});
      delete $self->{REPLACE};
    } else {
      $self->{ELEMENT}->appendTextNode($pcdata);
    }
  }
  sub cdata {
    my ($self,$pcdata) = @_;
    if ($self->{REPLACE}) {
      $self->{REPLACEMENT} = $self->{DOM}->createCDATASection($pcdata);
      $self->{REPLACE}->replaceNode($self->{REPLACEMENT});
      delete $self->{REPLACE};
    } else {
      $self->{ELEMENT}->appendChild($self->{DOM}->createCDATASection($pcdata));
    }
  }
1;
