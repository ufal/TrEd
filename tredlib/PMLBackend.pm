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
@pmlformat = ();
@pmlpatterns = ();
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
      $index{$id}=$node if defined $id;
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

sub xml_parser {
  my $parser = XML::LibXML->new();
  $parser->line_numbers(1);
  $parser->load_ext_dtd(0);
  $parser->validation(0);
  return $parser;
}

sub read ($$) {
  my ($input, $fsfile)=@_;
  return unless ref($fsfile);

  $fsfile->changeEncoding($encoding);
  $fsfile->changeTail("(1)\n");
  $fsfile->changePatterns(@pmlformat);
  $fsfile->changeHint($pmlhint);

  my $parser = xml_parser();

  my $dom = $parser->parse_fh($input);
  $dom->setBaseURI($fsfile->filename) if $dom and $dom->can('setBaseURI');
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
  1;
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
	my $element = read_element($child,$fsfile,$types,$type->{element}{$name});
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
  use Data::Dumper;
  return $type unless ref($type);
  if ($type->{type}) {
    my $rtype = $types->{$type->{type}};
    return $rtype; # || $type->{type};
  } else {
    return $type;
  }
}

sub _element_address {
  my ($node,$line_node)=@_;
  $line_node ||= $node;
  return "'".$node->localname."' at ".$line_node->ownerDocument->URI.":".$line_node->line_number."\n";
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
  1;
}

sub read_element ($$$;$) {
  my ($node,$fsfile,$types,$type) = @_;
  my $role = ref($type) ? $type->{role} : undef;
  $type = resolve_type($types,$type);
  $role = $type->{role} unless $role;
  my $hash;
  if (ref($type) and $role eq '#NODE' ) {
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
#    } else {
#      warn "Undeclared attribute '$name' of "._element_address($node);
    }
  }
  my $value = read_node($node,$fsfile,$types,$type);
  if (ref($type) and $role eq '#NODE' and
      ($type->{sequence} and $type->{sequence}{role} eq '#CHILDNODES' or
	 $type->{list} and $type->{list}{role} eq '#CHILDNODES') and
	   UNIVERSAL::isa($value,'Fslib::List')) {
    node_children($hash,$value);
  } else {
    $hash->{'#content'}=$value;
  }
  return $hash;
}

sub read_node_knit {
  my ($node,$fsfile,$types,$type)=@_;

  my $ref = $node->textContent();
#  _debug("KNIT: '$ref'");
  if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
    my ($reffile,$idref)=($1,$2);
    $fsfile->changeAppData('ref',{}) unless ref($fsfile->appData('ref'));
    my $refdom = ($reffile ne "") ? $fsfile->appData('ref')->{$reffile} : $node->ownerDocument;
    if (ref($refdom)) {
      $fsfile->changeAppData('ref-index',{}) unless ref($fsfile->appData('ref-index'));
      my $refnode =
	$fsfile->appData('ref-index')->{$reffile}{$idref} ||
	  $refdom->getElementsById($idref);
      if (ref($refnode)) {
	my $ret = read_node($refnode,$fsfile,$types,$type);
	if (ref($ret) and $ret->{id}) {
	  $ret->{id} = $reffile.'#'.$ret->{id};
	}
	return [1,$ret];
      } else {
	warn "warning: ID $idref not found in '$reffile'\n";
	return [0,$ref];
      }
    } else {
      warn "Reference to $ref cannot be resolved - document '$reffile' not loaded\n";
      return [0,$ref];
    }
  } else {
    return [0,$ref];
  }
}

sub read_node ($$$;$) {
  my ($node,$fsfile,$types,$type) = @_;
  my $defs = $fsfile->FS->defs;
  unless (ref($type)) {
    die "Schema implies unknown node type: '$type' for node "._element_address($node)."\n";
  }

  if ($type->{cdata}) {
    # pre-defined atomic types
    return $node->textContent;
  } elsif (exists $type->{list}) {
    my $list_type = resolve_type($types,$type->{list});
    return bless [
      map {
	read_node($_,$fsfile,
		  $types,$list_type)
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
      my $member = $members->{$name};
      if ($member ne "" and 
	  $member->{as_attribute}) {
	$hash->{$name} = $value;
	if ($member->{role} eq "#ORDER") {
	  $defs->{$name} = ' N' unless exists($defs->{$name});
	} elsif ($member->{role} eq "#HIDE") {
	  $defs->{$name} = ' H' unless exists($defs->{$name});
	}
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
		die "#CHILDNODES member '$name' encountered in non-#NODE element ".
		  _element_address($node,$child);
	      }
	    } else {
		die "#CHILDNODES member '$name' is neither a list nor a sequence in ".
		  _element_address($node,$child);
	    }
	  } elsif (ref($member) and $role eq '#KNIT') {
	    my $ret = read_node_knit($child,$fsfile,$types,$member);
	    if ($ret->[0]) {
	      $name =~ s/\.rf$//;
	    }
	    $hash->{$name} = $ret->[1];
	  } else {
	    if ($role eq "#ORDER") {
	      $defs->{$name} = ' N' unless exists($defs->{$name});
	    } elsif ($role eq "#HIDE") {
	      $defs->{$name} = ' H' unless exists($defs->{$name});
#	    } else {
#	      $defs->{$name} = ' K' unless exists($defs->{$name});
	    }
	    if (ref($member) and ($member->{list} and $member->{list}{role} eq '#KNIT')) {
	      my $list_type = resolve_type($types,$member->{list});
	      my @knit = map {
		read_node_knit($_,$fsfile,$types,$list_type)
	      } read_List($child);
	      if (grep { !$_->[0] } @knit) {
		# one of the elements didn't knit correctly
		warn "Knit failed on list "._element_address($child)."\n";
		# read the whole node again as data references
		$hash->{$name} = read_node($child,$fsfile,$types,{cdata=>{format=>'PMLREF'}});
	      } else {
		$name =~ s/\.rf$//;
		$hash->{$name} = bless [ map { $_->[1] } @knit ],'Fslib::List';
	      }
	    } else {
	      $hash->{$name} = read_node($child,$fsfile,$types,$member);
	    }
	  }
	} else {
	  die "Undeclared member '$name' encountered in ".
	    _element_address($node,$child);
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
	  die "Missing required member '$_' of ".
	    _element_address($node);
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

sub readas_trees {
  my ($parser,$fsfile,$refid,$href)=@_;
  my $requires = ($fsfile->metaData('fs-require') || []);
  push @$requires,[$refid,$href];
  $fsfile->changeMetaData('fs-require',$requires);
  1;
}
sub readas_dom {
  my ($parser,$fsfile,$refid,$href)=@_;
  # embed DOM documents
  my $ref_data;
  my $ref_fh = open_backend($href,'r');
  _debug("readas_dom: $href $ref_fh");
  if ($ref_fh){
    $ref_data = $parser->parse_fh($ref_fh);
    $ref_data->setBaseURI($href) if $ref_data and $ref_data->can('setBaseURI');;
    $parser->process_xincludes($ref_data);
    close_backend($ref_fh);
    $fsfile->changeAppData('ref',{}) unless ref($fsfile->appData('ref'));
    $fsfile->appData('ref')->{$refid}=$ref_data;
    $fsfile->changeAppData('ref-index',{}) unless ref($fsfile->appData('ref-index'));
    $fsfile->appData('ref-index')->{$refid}=index_by_id($ref_data);
  } else {
    die "Couldn't open '".$href."': $!\n";
  }
  1;
}

sub get_references {
  my ($fsfile)=@_;
  my $references = $fsfile->metaData('schema')->{reference};
  my @refs;
  if ($references) {
    foreach my $reference (@$references) {
      my $refid = $fsfile->metaData('refnames')->{$reference->{name}};
      if ($refid) {
	my $href = $fsfile->metaData('references')->{$refid};
	if ($href) {
	  _debug("Found '$reference->{name}' as $refid# = '$href'");
	  push @refs,{
	    readas => $reference->{readas},
	    name => $reference->{name},
	    id => $refid,
	    href => $href
	   };
	} else {
	  die "No href for $refid# ($reference->{name})\n"
	}
      } else {
	warn "Didn't find any reference to '".$reference->{name}."'\n";
      }
    }
  }
  return @refs;
}

sub read_trees {
  my ($parser, $fsfile, $dom_root) = @_;

  foreach my $ref (get_references($fsfile)) {
    if ($ref->{readas} eq 'dom') {
      readas_dom($parser,$fsfile,$ref->{id},$ref->{href});
    } elsif($ref->{readas} eq 'trees') {
      readas_trees($parser,$fsfile,$ref->{id},$ref->{href});
    } else {
      warn "Ignoring references with unknown readas method: '$ref->{readas}'";
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

    my $found_trees = 0;
    for my $child ($dom_root->childNodes) {
      if ($child->nodeType == ELEMENT_NODE and
	    $child->namespaceURI eq PML_NS and
	      $root_type->{element}->{$child->localname}->{role} eq '#TREES') {
	$found_trees=1;
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
      } elsif ($child->nodeType == ELEMENT_NODE and $child->namespaceURI eq PML_NS and
	       $child->localname eq 'head') {
	# already read this one
      } elsif ($child->nodeType == ELEMENT_NODE and $child->namespaceURI eq PML_NS and
	       $root_type->{element}{$child->localname}) {
	my $name = $child->localname;
	my $element = read_element($child,$fsfile,$types,$root_type->{element}{$name});
	my $what = $found_trees ? 'pml_epilog' : 'pml_prolog';
	if (ref($fsfile->metaData($what)) eq 'ARRAY') {
	  push @{$fsfile->metaData($what)},$element;
	} else {
	  $fsfile->changeMetaData($what,[$element])
	}
      } elsif ($child->nodeType != TEXT_NODE or $child->textContent =~ /\S/) {
	warn("Ignoring node "._element_address($child),"\n");
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
      } elsif ($child->nodeType == ELEMENT_NODE and $child->namespaceURI eq PML_NS and
	       $root_type->{element}{$child->localname}) {
	my $name = $child->localname;
	my $element = read_element($child,$fsfile,$types,$root_type->{element}{$name});
	if (ref($fsfile->metaData('pml_prolog')) eq 'ARRAY') {
	  push @{$fsfile->metaData('pml_prolog')},$element;
	} else {
	  $fsfile->changeMetaData('pml_prolog',[$element])
	}
      } elsif ($child->nodeType != TEXT_NODE or $child->textContent =~ /\S/) {
	warn("Ignoring node "._element_address($child),"\n");
      }
    }
  } else {
    die "No #TREES found in PML schema\n";
  }
  1;
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
    } elsif (UNIVERSAL::isa($root_type->{sequence},'HASH') and $root_type->{sequence}{role} eq '#TREES') {
      $trees = $root_type;
    }
  } elsif (UNIVERSAL::isa($root_type->{sequence},'HASH') and $root_type->{sequence}{role} eq '#TREES') {
    $trees = $root_type;
  }
  unless ($trees) {
    die "Can't write: didn't find any element or sequence with role #TREES\n";
  }

  # dump embedded DOM documents
  my $refs_to_save = $fsfile->appData('refs_save');
  my @refs_to_save = grep { $_->{readas} eq 'dom' } get_references($fsfile);
  if (ref($refs_to_save)) {
    @refs_to_save = grep { $refs_to_save->{$_->{id}} } @refs_to_save;
  } else {
    $refs_to_save = {};
  }

  # update all DOM trees to be saved
  my $parser = xml_parser();
  foreach my $ref (@refs_to_save) {
    _debug("$ref->{id} => $ref->{href}\n");
    readas_dom($parser,$fsfile,$ref->{id},$ref->{href});
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
		       href => (exists($refs_to_save->{$_}) ? $refs_to_save->{$_} : $references->{$_}),
		       (exists($names{$_}) ? (name => $names{$_}) : ()));
      }
    }
  }
  $xml->endTag('references');
  $xml->endTag('head');

  my $prolog = $fsfile->metaData('pml_prolog');
  if (ref($prolog) eq 'ARRAY') {
    foreach my $element (@$prolog) {
      write_extra_element($xml,$fsfile,$types,$root_type,$element);
    }
  }

  my $tree_list = bless [$fsfile->trees],'Fslib::List';
  write_object($xml, $fsfile, $types,resolve_type($types,$trees),$trees_tag,$tree_list);

  my $epilog = $fsfile->metaData('pml_epilog');
  if (ref($epilog) eq 'ARRAY') {
    foreach my $element (@$epilog) {
      write_extra_element($xml,$fsfile,$types,$root_type,$element);
    }
  }

  $xml->endTag($root_type->{name});
  $xml->end;

  # dump DOM trees to save
  if (ref($fsfile->appData('ref'))) {
    foreach my $ref (@refs_to_save) {
      my $dom = $fsfile->appData('ref')->{$ref->{id}};
      my $href;
      if (exists($refs_to_save->{$ref->{id}})) {
	# effectively rename the file reference
	$fsfile->metaData('references')->{$ref->{id}} = $refs_to_save->{$ref->{id}};
	$href = $refs_to_save->{$ref->{id}};
      } else {
	$href = $ref->{href}
      }
      if (ref($dom)) {
	eval {
	  IOBackend::rename_uri($href,$href."~") unless $href=~/^ntred:/;
	};
	my $ref_fh = IOBackend::open_backend($href,"w");
	my $ok = 0;
	if ($ref_fh) {
	  eval {
	    binmode $ref_fh;
	    $dom->toFH($ref_fh,1);
	    close $ref_fh;
	    $ok = 1;
	  }
	}
	unless ($ok) {
	  my $err = $@;
	  eval {
	    IOBackend::rename_uri($href."~",$href) unless $href=~/^ntred:/;
	  };
	  die $err."$@\n" if $err;
	}
      }
    }
  }
  1;
}

sub write_object_knit {
  my ($xml,$fsfile,$types,$type,$tag,$knit_tag,$object)=@_;
  my $ref = $object->{id};
  my $attribs;
  ($tag,$attribs)=@$tag if ref($tag);
  $xml->startTag($tag,$attribs?%$attribs:());
  $xml->characters($object->{id});
  $xml->endTag($tag);
  if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
    my ($reffile,$idref)=($1,$2);
    my $indeces = $fsfile->appData('ref-index');
    if ($indeces and $indeces->{$reffile}) {
      my $knit = $indeces->{$reffile}{$idref};
      if ($knit) {
	my $dom_writer = MyDOMWriter->new(REPLACE => $knit);
	write_object($dom_writer, $fsfile, $types, resolve_type($types,$type), $knit_tag, $object);
	my $new = $dom_writer->end;
	$new->setAttribute('id',$idref);
      } else {
	warn "Didn't find ID $idref in $reffile - can't knit back!\n";
      }
    } else {
      warn "Knit-file $reffile has no index - can't knit back!\n";
    }
  } else {
    warn "Can't parse '$tag' href '$ref' - can't knit back!\n";
  }
}

sub write_object ($$$$$$) {
  my ($xml,$fsfile, $types,$type,$tag,$object)=@_;
  my $pre=$type;
  my $attribs;
  ($tag,$attribs)=@$tag if ref($tag);
  $attribs = {} unless $attribs;
  $type = resolve_type($types,$type);
  if ($type->{cdata}) {
    $xml->startTag($tag,%$attribs) if defined($tag);
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
    $xml->startTag($tag,%$attribs);
    $xml->characters($object);
    $xml->endTag($tag);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (!ref($object)) {
      # what do we do now?
      warn "Unexpected content structure '$tag': $object\n";
    } elsif (keys(%$object)) {
      # ok, non-empty structure
      foreach my $atr (grep {$members->{$_}{as_attribute}}
			 #sort 
			   keys %$members) {
	if ($members->{$atr}{required} or $object->{$atr} ne "") {
	  $attribs->{$atr} = $object->{$atr};
	}
      }
      if (%$attribs and !defined($tag)) {
	die "Can't write structure with attribute members without a tag";
      }
      $xml->startTag($tag,%$attribs) if defined($tag);
      foreach my $member (
	grep {!$members->{$_}{as_attribute}} 
	  #sort 
	  keys %$members) {
	my $mtype = resolve_type($types,$members->{$member});
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
#	    _debug("#KNIT.rf $member");
	    $xml->startTag($member);
	    $xml->characters($object->{$member});
	    $xml->startTag($member);
	  } else {
	    my $knit_tag = $member;
	    $knit_tag =~ s/\.rf$//;
	    if (ref($object->{$knit_tag})) {
	      write_object_knit($xml,$fsfile,$types,$members->{$member},$member,$knit_tag,$object->{$knit_tag});
	    }# else {
	    #	warn "Didn't find $knit_tag on the object! ",join(" ",%$object),"\n";
	    #      }
	  }
	} elsif ($object->{$member} eq "" and ref($mtype) and $mtype->{list} and $mtype->{list}{role} eq '#KNIT') {
	  # KNIT list
	  my $knit_tag = $member;
	  $knit_tag =~ s/\.rf$//;
	  my $list = $object->{$knit_tag};
	  if (ref($list) eq 'Fslib::List') {
	    if (@$list == 0) {
	    } elsif (@$list == 1) {
	      write_object_knit($xml,$fsfile,$types,$mtype->{list},$member,$knit_tag,$list->[0]);
	    } else {
	      $xml->startTag($member);
	      foreach my $knit_value (@$list) {
		write_object_knit($xml,$fsfile,$types,$mtype->{list},LM,$knit_tag,$knit_value);
	      }
	      $xml->endTag($member);
	    }
	  }
	} elsif ($object->{$member} ne "" or $members->{$member}{required}) {
	  write_object($xml, $fsfile, $types,$members->{$member},$member,$object->{$member});
	}
      }
      $xml->endTag($tag) if defined($tag);
    }
  } elsif (exists $type->{list}) {
    if (ref($object) eq 'Fslib::List') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	write_object($xml, $fsfile,  $types,$type->{list},$tag,$object->[0]);
      } else {
	$xml->startTag($tag,%$attribs) if defined($tag);
	foreach my $member (@$object) {
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
	$xml->startTag($tag,%$attribs) if defined($tag);
	foreach my $member (@$object) {
	  write_object($xml, $fsfile, $types,$type->{alt},AM,$member);
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      write_object($xml, $fsfile, $types,$type->{alt},$tag,$object);
    }
  } elsif (exists $type->{sequence}) {
    $xml->startTag($tag,%$attribs) if defined($tag);
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
	    my $role = $eltype->{role};
	    $eltype=resolve_type($types,$eltype);
	    $role = $eltype->{role} if $role eq '';
	    my %attribs;
	    foreach my $atr (keys(%{$eltype->{attribute}})) {
	      $attribs{$atr} = $element->{$atr};
	    }
	    if (UNIVERSAL::isa($element,'FSNode') and $element->firstson and
		($eltype->{sequence} and $eltype->{sequence}{role} eq '#CHILDNODES' or
		 $eltype->{list} and $eltype->{list}{role} eq '#CHILDNODES')) {
	      write_object($xml, $fsfile, $types,$eltype,[$element->{'#name'},\%attribs],
			   bless([ $element->children ],'Fslib::List'));
	    } else {
	      write_object($xml, $fsfile, $types,$eltype,[$element->{'#name'},\%attribs],$element->{'#content'});
	    }
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
  1;
}


sub write_extra_element {
  my ($xml,$fsfile,$types,$type,$element)=@_;
  my $eltype = $type->{element}{$element->{'#name'}};
  if ($eltype) {
    my %attribs;
    foreach my $atr (keys(%{$eltype->{attribute}})) {
      $attribs{$atr} = $element->{$atr};
    }
    $xml->startTag($element->{'#name'},%attribs);
    write_object($xml, $fsfile, $types,$eltype,undef,$element->{'#content'});
    $xml->endTag($element->{'#name'});
  } else {
    warn "PML-element '".$element->{'#name'}."' node is not allowed in prolog/epilog\n";
  }
  1;
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
    do {{
      return 1 if m{xmlns=(['"])http://ufal.mff.cuni.cz/pdt/pml/\1};
    }} while ($_=$f->getline() and (!/\S/ or /^\s*<?[^>]+?>\s*$/ or !/[>]/));
    return m{<[^>]+xmlns=(['"])http://ufal.mff.cuni.cz/pdt/pml/\1} ? 1 : 0;
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
    1;
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
    1;
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
    1;
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
    1;
  }
1;
