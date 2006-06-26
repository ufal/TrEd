package PMLBackend;
use Fslib;
use IOBackend qw(close_backend);
use strict;

use XML::Simple; # for PML schema
use Encode;
use XML::LibXML;
use XML::LibXML::Common qw(:w3c :encoding);
use XML::Writer;
use File::Spec;

use Data::Dumper;

use Carp;

use vars qw(@pmlformat @pmlpatterns $pmlhint $encoding $DEBUG);

$DEBUG=0;

use constant {
  LM => 'LM',
  AM => 'AM',
  PML_NS => "http://ufal.mff.cuni.cz/pdt/pml/",
  SUPPORTED_VERSIONS => " 1.1 ",
};



$encoding='utf8';
@pmlformat = ();
@pmlpatterns = ();
$pmlhint="";

sub _die {
  my $msg = join '',@_;
  chomp $msg;
  if ($DEBUG) {
    local $Carp::CarpLevel=1;
    confess($msg);
  } else {
    die $msg."\n";
  }
}

sub _debug {
  return unless $DEBUG;
  my $level = 1;
  if (ref($_[0])) {
    $level=$_[0]->{level};
    shift;
  }
  my $msg=join '',@_;
  chomp $msg;
  print STDERR "PMLBackend: $msg\n" if $DEBUG>=$level;
}

sub _warn {
  my $msg = join '',@_;
  chomp $msg;
  warn "PMLBackend: WARNING: $msg\n";
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
  my $schema = $fsfile->metaData('schema');
  unless (ref($schema)) {
    _die("Unknown XML data: ".$dom_root->localname()." ".$dom_root->namespaceURI());
  }
  if ($schema->{version} eq "") {
    _die("PML Schema file ".$fsfile->metaData('schema-url')." does not specify version!");
  }
  if (index(SUPPORTED_VERSIONS," ".$schema->{version}." ")<0) {
    _die("Unsupported PML Schema version ".$schema->{version}." in ".$fsfile->metaData('schema-url'));
  }
  $return = read_data($parser, $fsfile,$dom_root);
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
	# Encode: all filenames must(!) be bytes
	$references{ $id } = Fslib::ResolvePath($fsfile->filename,
						Encode::encode_utf8($reffile->getAttribute('href')),0);
      _debug("read_references: $id => $references{$id}");

      }
    }
    my ($schema) = $head->getElementsByTagNameNS(PML_NS,'schema');
    if ($schema) {
      # Encode: all filenames must(!) be bytes
      my $schema_file = Encode::encode_utf8($schema->getAttribute('href'));
      my %revision_opts;
      for my $attr (qw(revision maximal_revision minimal_revision)) {
	$revision_opts{$attr}=$schema->getAttribute($attr) if $schema->hasAttribute($attr);
      }
      # store the original URL, not the resolved one!
      $fsfile->changeMetaData('schema-url',$schema_file);
      $fsfile->changeMetaData('schema',
			      Fslib::Schema->readFrom($schema_file,
						      { base_url => $fsfile->filename,
							use_resources => 1,
							revision_error => 
							  "Error: ".$fsfile->filename." requires different revision of PML schema %f: %e\n",
							%revision_opts,
						      }
						     ));
    }
  }
  $fsfile->changeMetaData('references',\%references);
  $fsfile->changeMetaData('refnames',\%named_references );
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

=cut

sub read_Sequence {
  my ($child,$fsfile,$types,$type,$seq)=@_;
  $seq ||= Fslib::Seq->new();
  $seq->set_content_pattern($type->{content_pattern});
  return undef unless $child;
  my $node = $child->parentNode;
  while ($child) {
    my $child_nodeType = $child->nodeType;
    if ($child_nodeType == ELEMENT_NODE) {
      my $name = $child->localName;
      my $ns = $child->namespaceURI;
      my $is_pml = ($ns eq PML_NS);
      if ($type->{element}{$name} and 
	    ($ns eq "" or $is_pml or $type->{element}{$name}{ns} eq $ns)) {
	my $value = read_node($child,$fsfile,$types,resolve_type($types,$type->{element}{$name}));
	$seq->push_element($name,$value);
      } else {
	_die("Undeclared element of a sequence "._element_address($child));
      }
    } elsif (($child_nodeType == TEXT_NODE or $child_nodeType == CDATA_SECTION_NODE)) {
      if ($type->{text}) {
	if ($type->{role} eq '#CHILDNODES') {
	  _warn("Ignoring text node '".$child->getData."' in #CHILDNODES sequence in "._element_address($node));
	} else {
	  $seq->push_element('#TEXT',$child->getData);
	}
      } elsif ($child->getData =~ /\S/) {
	_die("Text content '".$child->getData."'not allowed in sequence of "._element_address($node));
      }
    }
  } continue {
    $child = $child->nextSibling;
  };
  if (defined($type->{content_pattern}) and !$seq->validate()) {
    _warn("Sequence content (".join(",",$seq->names).") does not follow the pattern ".$type->{content_pattern}." in "._element_address($node));
  }
  return $seq;
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


sub resolve_type {
  my ($types,$type)=@_;
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

sub set_trees {
  my ($fsfile,$data,$type,$node)=@_;
  _debug("Found #TREES in "._element_address($node));
  unless (defined $fsfile->metaData('pml_trees_type')) {
    $fsfile->changeMetaData('pml_trees_type',$type);
    if (UNIVERSAL::isa($data,'Fslib::List')) {
      $fsfile->changeTrees($data->values);
      _warn("Object with role #TREES contains non-#NODE list members in "._element_address($node))
	if (grep {!UNIVERSAL::isa($_,'FSNode')} @{$fsfile->treeList});
      return undef; #$fsfile->treeList;
    } elsif (UNIVERSAL::isa($data,'Fslib::Seq')) {
      # in a #TREES sequence, we accept non-node elements, processing
      # the sequence in the following way:
      # - an initial contiguous block of non-node elements is stored
      #   as a pml_prolog
      # - the first contiguous block of node elements is used as the tree list
      #   (and its elements are delegated)
      # - the rest of the sequence is stored as pml_epilog
      my $prolog = $fsfile->metaData('pml_prolog') || Fslib::Seq->new;
      $fsfile->changeMetaData('pml_prolog',$prolog);
      my $epilog = $fsfile->metaData('pml_epilog') || Fslib::Seq->new;
      $fsfile->changeMetaData('pml_epilog',$epilog);
      my $trees=$fsfile->treeList;
      my $phase = 0; # prolog
      foreach my $element ($data->elements) {
	if (UNIVERSAL::isa($element->[1],'FSNode')) {
	  if ($phase == 0) {
	    $phase = 1;
	  }
	  if ($phase == 1) {
	    $element->[1]{'#name'} = $element->[0]; # manually delegate_name on this element
	    push @$trees, $element->[1];
	  } else {
	    $prolog->push_element(@$element);
	  }
	} else {
	  if ($phase == 1) {
	    $phase = 2; # start epilog
	  }
	  if ($phase == 0) {
	    $prolog->push_element(@$element);
	  } else {
	    $epilog->push_element(@$element);
	  }
	}
      }
      return undef;
    } else {
      # should be undef - empty tree list
      return $data;
    }
  }
  return $data;
}

sub set_node_children {
  my ($node,$list)=@_;
  my $prev=0;
  
  if (UNIVERSAL::isa($list,'Fslib::Seq')) {
    $list->delegate_names('#name');
    $list = $list->values;
  }
  foreach my $son (@{$list}) {
    unless (UNIVERSAL::isa($son,'FSNode')) {
      _die("non-#NODE child '".Dumper($son)."'");
      return;
    }
    $son->{$Fslib::parent} = $node;
      $son->{$Fslib::lbrother} = $prev;
    $prev->{$Fslib::rbrother} = $son if $prev;
    $prev = $son;
  }
  $node->{$Fslib::firstson} = $list->[0];
  return 1;
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
	_warn("warning: ID $idref not found in '$reffile'\n");
	return [0,$ref];
      }
    } else {
      _warn("Reference to $ref cannot be resolved - document '$reffile' not loaded\n");
      return [0,$ref];
    }
  } else {
    return [0,$ref];
  }
}

sub read_node {
  my ($node,$fsfile,$types,$type,$childnodes_taker,$attrs,$first_child) = @_;
  $first_child ||= $node->firstChild;
  _debug({level => 6},"Reading node "._element_address($node)."\n");
  my $defs = $fsfile->FS->defs;
  unless (ref($type)) {
    _die("Schema implies unknown node type: '$type' for node "._element_address($node));
  }

  # CDATA ------------------------------------------------------------
  if ($type->{cdata}) {
    _debug({level => 6},"CDATA type\n");
    # pre-defined atomic types
    return $node->textContent;
  # LIST ------------------------------------------------------------
  } elsif (exists $type->{list}) {
    _debug({level => 6},"list type\n");
    my $list_type = resolve_type($types,$type->{list});

    my $nodelist = $node->getChildrenByTagNameNS(PML_NS,LM);
    my $list = bless
      [
	@$nodelist
	  ? (map {
	      read_node($_,$fsfile, $types,$list_type)
	     } read_List($node)) 
	  : read_node($node,$fsfile, $types, $list_type,undef,$attrs) 
      ], 'Fslib::List';
    my $role = $type->{list}{role};
    if ($role eq '#CHILDNODES' and $childnodes_taker) {
      set_node_children($childnodes_taker, $list) if $list;
      return undef;
    } elsif ($role eq '#TREES' and $childnodes_taker) {
      return set_trees($fsfile, $list, $type,$node);
    } else {
      return $list;
    }
  # ALT ------------------------------------------------------------
  } elsif (exists $type->{alt}) {
    _debug({level => 6},"alt type\n");
    my $alt_type = resolve_type($types,$type->{alt});
    # alt
    my $Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
    if (@$Alt) {
      return bless [
	map {
	  read_node($_,$fsfile,$types,$alt_type)
	} @$Alt,
       ], 'Fslib::Alt';
    } else {
      return read_node($node,$fsfile,$types,$alt_type,undef,$attrs);
    }
  # SEQUENCE ------------------------------------------------------------
  } elsif (exists $type->{sequence}) {
    _debug({level => 6},"sequence type\n");
    my $seq = read_Sequence($first_child,$fsfile,$types,$type->{sequence});
    my $role = $type->{sequence}{role};
    if ($role eq '#CHILDNODES' and $childnodes_taker) {
      if ($seq) {
	set_node_children($childnodes_taker, $seq);    
      }
      return undef;
    } elsif ($role eq '#TREES') {
      return set_trees($fsfile,$seq,$type,$node);
    } else {
      return $seq;
    }
  # STRUCTURE ------------------------------------------------------------
  } elsif (exists $type->{structure}) {
    _debug({level => 6},"structure type\n");
    # structure
    my $struct = $type->{structure};
    my $members = $struct->{member};
    my $hash;
    if ($type->{role} eq '#NODE' or $struct->{role} eq '#NODE') {
      $hash=FSNode->new();
      $childnodes_taker = $hash;
      $hash->set_type($fsfile->metaData('schema')->type($type->{structure}));
    } else {
      $hash={}
    }
    foreach my $attr ($node->attributes) {
      my $name  = $attr->nodeName;
      my $value;
      if ($attrs) {
	$value = delete $attrs->{$name};
	next unless defined $value;
      } else {
	$value = $attr->value;
      }
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
	_warn("Member '$name' not declared as attribute of "._element_address($node));
      } else {
	unless ($name =~ /^xml(?:ns)?(?:$|:)/) {
	  _warn("Undeclared attribute '$name' of "._element_address($node));
	}
      }
    }

#    foreach my $child ($node->findnodes('*')) {
#    foreach my $child ($node->getChildrenByTagNameNS(PML_NS,'*')) {
#    foreach my $child ($node->findnodes('*[namespace-uri()="'.PML_NS.'"]')) {
#    foreach my $child ($node->childNodes) {
    my $child = $first_child;
    while ($child) {
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
	      if (ref $childnodes_taker) {
		my $list = read_node($child,$fsfile, $types,$member);
		set_node_children($childnodes_taker, $list);
	      } else {
		_die("#CHILDNODES member '$name' encountered in non-#NODE element ".
		  _element_address($node,$child));
	      }
	    } else {
		_die("#CHILDNODES member '$name' is neither a list nor a sequence in ".
		  _element_address($node,$child));
	    }
	  } elsif (ref($member) and $role eq '#TREES') {
	    if ($member->{list} or $member->{sequence}) {
	      $hash->{$name} = set_trees($fsfile,read_node($child,$fsfile, $types,$member),$member,$child);
	    } else {
	      _die("#TREES member '$name' is neither a list nor a sequence in "._element_address($node,$child));
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
		_warn("Knit failed on list "._element_address($child)."\n");
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
	  _die("Undeclared member '$name' encountered in ".
	    _element_address($node,$child));
	}
     } elsif ((($child_nodeType == TEXT_NODE
		or $child_nodeType == CDATA_SECTION_NODE)
		and $child->data=~/\S/)) {
	_warn("Ignoring text content '".$child->data."'.\n");
      } elsif ($child_nodeType == ELEMENT_NODE
	       and $child->namespaceURI eq PML_NS) {
	_warn("Ignoring non-PML element '".$child->nodeName."'.\n");
      }
    } continue {
      $child = $child->nextSibling;
    }
    foreach (keys %{$members}) {
      if (!exists($hash->{$_})) {
	my $member = $members->{$_};
	if ($member->{required}) {
	  _die("Missing required member '$_' of ".
	    _element_address($node));
	} else {
	  my $mtype = resolve_type($types,$member);
	  if (ref($mtype) and exists($mtype->{constant})) {
	    $hash->{$_}=$mtype->{constant};
	  }
	}
      }
    }
    return $hash;
  # CONTAINER ------------------------------------------------------------
  } elsif (exists $type->{container}) {
    _debug({level => 6},"container type\n");
    # container
    my $container = $type->{container};
    my $attributes = $container->{attribute};
    my $hash;
    if ($type->{role} eq '#NODE' or $container->{role} eq '#NODE') {
      $hash=FSNode->new();
      $childnodes_taker = $hash;
      $hash->set_type($fsfile->metaData('schema')->type($container));
    } else {
      $hash={}
    }

    unless ($attrs) {
      $attrs = {};
      foreach my $attr ($node->attributes) {
	$attrs->{$attr->nodeName} = $attr->value;
      }
    }
    foreach my $atr_name (keys %$attributes) {
      if (exists($attrs->{$atr_name})) {
	$hash->{$atr_name} = delete $attrs->{$atr_name};
      } elsif ($attributes->{$atr_name}{required}) {
	_die("Required attribute '$atr_name' missing in container ".
	       _element_address($node));
      }
    }
    $hash->{'#content'} = read_node($node,$fsfile,$types,$container,$childnodes_taker,$attrs, $first_child);
    foreach my $atr_name (keys %$attrs) {
      unless ($atr_name =~ /^xml(?:ns)?(?:$|:)/) {
	_warn("Undeclared attribute '$atr_name' of "._element_address($node));
      }
    }
    return $hash;
  # CHOICE ------------------------------------------------------------
  } elsif (exists $type->{choice}) {
    _debug({level => 6},"choice type\n");
    if (grep { $_->nodeName !~ m{^xml(?:ns)?:} } $node->attributes) {
      _warn("Ignoring attributes on element "._element_address($node));
    }
    if (grep { $_->nodeType == ELEMENT_NODE } $node->childNodes) {
      _die("Invalid non-cdata content of "._element_address($node))
    }
    my $data = $node->textContent();
    my $ok;
    _warn("$type->{choice} at ".$node->nodeName."\n")
      unless ref($type->{choice}) eq 'ARRAY';
    foreach (@{$type->{choice}}) {
      if ($_ eq $data) {
	$ok = 1;
	last;
      }
    }
    unless ($ok) {
      _die("Invalid value '$data' for '".$node->localname."' (expected one of: ".join(',',@{$type->{choice}}).")");
    }
    return $data;
  # CONSTANT ------------------------------------------------------------
  } elsif (exists $type->{constant}) {
    _debug({level => 6},"constant type\n");
    my $data = $node->textContent();
    if ($data ne "" and $data ne $type->{constant}) {
      _die("Invalid value '$data' for constant '".$node->localname."' (expected $type->{constant})");
    }
    return $data;
  # OTHER ------------------------------------------------------------
  } elsif ($type->{element}) {
    _die("Type declaration error: element type not allowed for data construction in ".
	   _element_address($node));
  } elsif ($type->{member}) {
    _die("Type declaration error: AVS member type not applicable for data construction in ".
	   _element_address($node));
  # UNRESOLVED ------------------------------------------------------------
  } elsif  ($type->{type}) {
    return read_node($node,$fsfile,$types,resolve_type($types,$type),$childnodes_taker,$attrs,$first_child);
  } else {
    _die("Type declaration error: cannot determine data type of ".
	   _element_address($node)."Parsed type declaration:\n".Dumper($type));
  }
  return undef;
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

  my ($local_file,$remove_file) = IOBackend::fetch_file($href);
  my $ref_fh = IOBackend::open_backend($local_file,'r');
  _die("Can't open $href for reading") unless $ref_fh;
  _debug("readas_dom: $href $ref_fh");
  if ($ref_fh){
    eval {
      $ref_data = $parser->parse_fh($ref_fh);
    };
    _die("Error parsing $href $ref_fh $local_file ($@)") if $@;
    $ref_data->setBaseURI($href) if $ref_data and $ref_data->can('setBaseURI');;
    $parser->process_xincludes($ref_data);
    IOBackend::close_backend($ref_fh);
    $fsfile->changeAppData('ref',{}) unless ref($fsfile->appData('ref'));
    $fsfile->appData('ref')->{$refid}=$ref_data;
    $fsfile->changeAppData('ref-index',{}) unless ref($fsfile->appData('ref-index'));
    $fsfile->appData('ref-index')->{$refid}=index_by_id($ref_data);
    if ($href ne $local_file and $remove_file) {
      local $!;
      unlink $local_file || _warn("couldn't unlink tmp file $local_file: $!\n");
    }
  } else {
    if ($href ne $local_file and $remove_file) {
      local $!;
      unlink $local_file || _warn("couldn't unlink tmp file $local_file: $!\n");
    }
    _die("Couldn't open '".$href."': $!");
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
	  _die("No href for $refid# ($reference->{name})")
	}
      } else {
	_warn("Didn't find any reference to '".$reference->{name}."'\n");
      }
    }
  }
  return @refs;
}

# return the first child after <head>
sub _skip_head {
  my ($node, $child)=@_;
  my $child = $node->firstChild;
  while ($child) {
    if ($child->nodeType == ELEMENT_NODE) {
      if ($child->namespaceURI eq PML_NS and $child->localname eq 'head') {
	$child = $child->nextSibling;
	last;
      } else {
	_warn("Expected <head> instead of "._element_address($child));
	last;
      }
    } elsif (($child->nodeType == TEXT_NODE or $child->nodeType == CDATA_SECTION_NODE) and $child->textContent =~ /\S/) {
      _die("Unexpected text content '".$child->textContent."' in "._element_address($node));
    }
  } continue {
    $child = $child->nextSibling;
  };
  return $child;
}

sub read_data {
  my ($parser, $fsfile, $dom_root) = @_;
  $fsfile->changeMetaData('pml_trees_type',undef);
  foreach my $ref (get_references($fsfile)) {
    if ($ref->{readas} eq 'dom') {
      readas_dom($parser,$fsfile,$ref->{id},$ref->{href});
    } elsif($ref->{readas} eq 'trees') {
      readas_trees($parser,$fsfile,$ref->{id},$ref->{href});
    } else {
      _warn("Ignoring references with unknown readas method: '$ref->{readas}'\n");
    }
  }
  my $schema = $fsfile->metaData('schema');
  my $types = $schema->{type};
  my $root_name = $schema->{root}{name};
  my $root_type = resolve_type($types,$schema->{root});

  unless ($dom_root->namespaceURI eq PML_NS and
	  $dom_root->localname eq $root_name) {
    _die("Expected root element '$root_name'");
  }
  unless (UNIVERSAL::isa($root_type,'HASH')) {
    _die("PML schema error - invalid root element declaration");
  }

  # In PML 1.1, root can either be a sequence or a structure

  if ($root_type->{structure} or $root_type->{sequence} or $root_type->{container}) {
    $fsfile->changeMetaData(
      'pml_root' =>
      read_node($dom_root,$fsfile,$types,$root_type,undef,undef,
		_skip_head($dom_root) # the child after <head>
	       )
     );
  } else {
    _die("The root type must be a structure or a sequence: "._element_address($dom_root));
  }
  return 1;
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
  my $schema = $fsfile->metaData('schema');
  unless (ref($schema)) {
    _die("Can't write - document isn't associated with a schema");
  }

  my $types = $schema->{type};
  my $root_name = $schema->{root}{name};
  my $root_type = resolve_type($types,$schema->{root});

  # dump embedded DOM documents
  my $refs_to_save = $fsfile->appData('refs_save');
  my @refs_to_save = grep { $_->{readas} eq 'dom' } get_references($fsfile);
  if (ref($refs_to_save)) {
    @refs_to_save = grep { $refs_to_save->{$_->{id}} } @refs_to_save;
  } else {
    $refs_to_save = {};
  }

  my $references = $fsfile->metaData('references');

  # update all DOM trees to be saved
  my $parser = xml_parser();
  foreach my $ref (@refs_to_save) {
    readas_dom($parser,$fsfile,$ref->{id},$ref->{href});
    # NOTE:
    # if ($refs_to_save->{$ref->{id}} ne $ref->{href}),
    # then the ref-file is going to be renamed.
    # Although we don't parse it as PML, it can be a PML file.
    # If it is, we might try to update it's references too,
    # but the snag here is, that we don't know if the
    # resources it references aren't moved along with it by
    # other means (e.g. by user making the copy).
  }

  $xml->xmlDecl("utf-8");

  # we need to collect structure/container attributes first
  my %attribs;
  if (exists $root_type->{structure}) {
    my $struct = $root_type->{structure};
    my $members = $struct->{member};
    my $object = $fsfile->metaData('pml_root');
    if (ref($object)) {
      foreach my $mdecl (grep {$_->{as_attribute}} values %$members) {
	my $atr = $mdecl->{-name};
	if ($mdecl->{required} or $object->{$atr} ne "") {
	  $attribs{$atr} = $object->{$atr};
	}
      }
    }
  } elsif (exists $root_type->{container}) {
    my $container = $root_type->{container};
    my $object = $fsfile->metaData('pml_root');
    if (ref($object)) {
      foreach my $attrib (values(%{$container->{attribute}})) {
	my $atr = $attrib->{-name};
	if ($attrib->{required} or  $object->{$atr} ne "") {
	  $attribs{$atr} = $object->{$atr}
	}
      }
    }
  }

  $xml->startTag($root_name,xmlns => PML_NS, %attribs);
  $xml->startTag('head');
  $xml->emptyTag('schema', href => $fsfile->metaData('schema-url'));
  $xml->startTag('references');
  {
    my $named = $fsfile->metaData('refnames');
    my %names = $named ? (map { $named->{$_} => $_ } keys %$named) : ();
    if ($references) {
      foreach my $id (sort keys %$references) {
	my $href;
	if (exists($refs_to_save->{$id})) {
	  # effectively rename the file reference
	  $href = $references->{$id} = $refs_to_save->{$id}
	} else {
	  $href = $references->{$id};
	}
	if ($href !~ m(^[[:alnum:]]+//)) { 
	  # not an URL
	  # local paths are always relative
	  # if you need absolute path, try file:// URL instead
	  my ($vol,$dir) = File::Spec->splitpath(File::Spec->rel2abs($fsfile->filename));
	  $href = File::Spec->abs2rel($href,File::Spec->catfile($vol,$dir));
	}
	$xml->emptyTag('reffile',
		       id => $id,
		       href => $href,
		       (exists($names{$id}) ? (name => $names{$id}) : ()));
      }
    }
  }
  $xml->endTag('references');
  $xml->endTag('head');

  write_object($xml, $fsfile, $types, $root_type, [undef,{},1], $fsfile->metaData('pml_root'));
  $xml->endTag($root_name);
  $xml->end;

  # dump DOM trees to save
  if (ref($fsfile->appData('ref'))) {
    foreach my $ref (@refs_to_save) {
      my $dom = $fsfile->appData('ref')->{$ref->{id}};
      my $href;
      if (exists($refs_to_save->{$ref->{id}})) {
	$href = $refs_to_save->{$ref->{id}};
      } else {
	$href = $ref->{href}
      }
      if (ref($dom)) {
	eval {
	  IOBackend::rename_uri($href,$href."~") unless $href=~/^ntred:/;
	};
	my $ok = 0;
	eval {
	  my $ref_fh = IOBackend::open_backend($href,"w");
	  if ($ref_fh) {
	    binmode $ref_fh;
	    $dom->toFH($ref_fh,1);
	    IOBackend::close_backend($ref_fh);
	    $ok = 1;
	  }
	};
	unless ($ok) {
	  my $err = $@;
	  eval {
	    IOBackend::rename_uri($href."~",$href) unless $href=~/^ntred:/;
	  };
	  _die($err."$@") if $err;
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
	_warn("Didn't find ID $idref in $reffile - can't knit back!\n");
      }
    } else {
      _warn("Knit-file $reffile has no index - can't knit back!\n");
    }
  } else {
    _warn("Can't parse '$tag' href '$ref' - can't knit back!\n");
  }
}

sub get_write_trees {
  my ($fsfile, $data, $type)=@_;
  if ($fsfile->metaData('trees_written')) {
    return $data
  } else {
    my $trees_type = $fsfile->metaData('pml_trees_type') || $type;
    if (ref($trees_type)) {
      if ($trees_type->{sequence}) {
	my $prolog = $fsfile->metaData('pml_prolog');
	my $epilog = $fsfile->metaData('pml_epilog');
	return Fslib::Seq->new(
	  [(UNIVERSAL::isa($prolog,'Fslib::Seq') ? $prolog->elements : ()),
	   (map { [$_->{'#name'},$_] } @{$fsfile->treeList}),
	   (UNIVERSAL::isa($epilog,'Fslib::Seq') ? $epilog->elements : ())]
	 );
      } elsif ($trees_type->{list}) {
	return $fsfile->treeList;
      } else {
	_warn("#TREES are neither a list nor a sequence - can't save trees.\n");
      }
    } else {
      _warn("Can't determine #TREES type - can't save trees.\n");
    }
    $fsfile->changeMetaData('trees_written',1);
  }
}

sub get_childnodes {
  my ($object,$types,$container,$content,$what)=@_;
  my $cont_type = resolve_type($types,$container);
  return $content unless ref($cont_type);
  if (ref($cont_type->{sequence}) and 
	$cont_type->{sequence}{role} eq '#CHILDNODES') {
    if ($content ne "") {
      _warn("Replacing non-empty value '$content' of '$what' with the #CHILDNODES sequence!");
    }
    return Fslib::Seq->new([map { [$_->{'#name'},$_] } $object->children]);
  } elsif (ref($cont_type->{list}) and 
	     $cont_type->{list}{role} eq '#CHILDNODES') {
    if ($content ne "") {
      _warn("Replacing non-empty value '$content' of '$what' with the #CHILDNODES list!");
    }
    return Fslib::List->new_from_ref([$object->children]);
  }
}

sub write_object {
  my ($xml,$fsfile, $types,$type,$tag_spec,$object,$no_resolve)=@_;
  my $pre=$type;
  my ($tag,$attribs,$no_attribs) = ref($tag_spec) ? @$tag_spec : ($tag_spec,undef,undef);
  $attribs = {} unless $attribs;
  unless ($no_resolve) {
    $type = resolve_type($types,$type)
  }
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
    unless ($ok) {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Invalid value for '$what': $object\n")
    }
    $xml->startTag($tag,%$attribs);
    $xml->characters($object);
    $xml->endTag($tag);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (!ref($object)) {
      # what do we do now?
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Unexpected content of structure '$what': $object\n");
    } elsif (keys(%$object)) {
      # ok, non-empty structure
      if ($no_attribs) {
	$xml->startTag($tag) if defined($tag);
      } else {
	foreach my $mdecl (grep {$_->{as_attribute}} values %$members) {
	  my $atr = $mdecl->{-name};
	  if ($mdecl->{required} or $object->{$atr} ne "") {
	    $attribs->{$atr} = $object->{$atr};
	  }
	}
	if (%$attribs and !defined($tag)) {
	  _die("Can't write structure with attribute members without a tag");
	}
	$xml->startTag($tag,%$attribs) if defined($tag);
      }
      foreach my $mdecl (
	grep {!$_->{as_attribute}} 
	  sort { $a->{'-#'} <=> $b->{'-#'} }
	  values %$members) {
	my $member = $mdecl->{-name};
	my $mtype = resolve_type($types,$mdecl);
	if ($mdecl->{role} eq '#CHILDNODES') {
	  if (ref($object) eq 'FSNode') {
	    if ($object->firstson or $mdecl->{required}) {
	      my $children;
	      if (ref($mtype->{sequence})) {
		if ($object->{$member} ne "") {
		  _warn("Replacing non-empty value of member '$member' with the #CHILDNODES sequence!");
		}
		$children = Fslib::Seq->new([map { [$_->{'#name'},$_] } $object->children]);
	      } elsif (ref($mtype->{list})) {
		if ($object->{$member} ne "") {
		  _warn("Replacing non-empty value of member '$member' with the #CHILDNODES list!");
		}
		$children = Fslib::List->new_from_ref([$object->children]);
	      } else {
		_warn("The member '$member' with the role #CHILDNODES is neither a list nor a sequence - ignoring it!");
	      }
	      write_object($xml, $fsfile, $types,$mdecl,$member,$children);
	    }
	  } else {
	    _warn("Found #CHILDNODES member '$member' on a non-node value: $object\n");
	  }
	} elsif ($mdecl->{role} eq '#TREES') {
	  my $data = get_write_trees($fsfile,$mdecl,$mtype);
	  write_object($xml, $fsfile, $types,$mdecl,$member, $data);
	} elsif ($mdecl->{role} eq '#KNIT') {
	  if ($object->{$member} ne "") {
	    # un-knit data
#	    _debug("#KNIT.rf $member");
	    $xml->startTag($member);
	    $xml->characters($object->{$member});
	    $xml->endTag($member);
	  } else {
	    # knit data
	    my $knit_tag = $member;
	    $knit_tag =~ s/\.rf$//;
	    if (ref($object->{$knit_tag})) {
	      write_object_knit($xml,$fsfile,$types,$mdecl,$member,$knit_tag,$object->{$knit_tag});
	    }# else {
	    #	_warn("Didn't find $knit_tag on the object! ",join(" ",%$object),"\n");
	    #      }
	  }
	} elsif (ref($mtype) and $mtype->{list} and $mtype->{list}{role} eq '#KNIT') {
	  if ($object->{$member} ne "") {
	    # un-knit list
	    my $list = $object->{$member};
	    # _debug("#KNIT.rf $member @$list");
	    if (ref($list) eq 'Fslib::List') {
	      if (@$list == 0) {
	      } elsif (@$list == 1) {
		write_object($xml,$fsfile,$types,$mtype->{list},$member,$list->[0],
			     1 # don't resolve type
			    );
	      } else {
		$xml->startTag($member);
		foreach my $value (@$list) {
		  write_object($xml,$fsfile,$types,$mtype->{list},LM,$value,
			       1 # don't resolve type
			      );
		}
		$xml->endTag($member);
	      }
	    } else {
	      _warn("Unexpected content of un-knit List '$member': $list\n");
	    }
	  } else {
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
	    } elsif ($list ne '') {
	      _warn("Unexpected content of knit List '$knit_tag': $list\n");
	    }
	  }
	} elsif ($object->{$member} ne "" or $mdecl->{required}) {
	  write_object($xml, $fsfile, $types,$mdecl,$member,$object->{$member});
	}
      }
      $xml->endTag($tag) if defined($tag);
    }
  } elsif (exists $type->{list}) {
    my $list_type = $type->{list};
    if (ref($list_type) and $list_type->{role} eq '#TREES') {
      $object = get_write_trees($fsfile,$object,$type);
    }
    if (ref($object) eq 'Fslib::List') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	write_object($xml, $fsfile,  $types,$list_type,$tag,$object->[0]);
      } else {
	$xml->startTag($tag,%$attribs) if defined($tag);
	foreach my $value (@$object) {
	  write_object($xml, $fsfile, $types,$list_type,LM,$value);
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Unexpected content of List '$what': $object\n");
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
    my $sequence = $type->{sequence};
    $xml->startTag($tag,%$attribs) if defined($tag);
    if ($sequence->{role} eq '#TREES') {
      $object = get_write_trees($fsfile,$object,$type);
    }
    if (UNIVERSAL::isa($object,'Fslib::Seq')) {
      if (exists $sequence->{content_pattern}) {
	unless ($object->validate($sequence->{content_pattern})) {
	  _warn("Sequence '$tag' (".join(",",$object->names).") does not follow the pattern ".$sequence->{content_pattern});
	}
      }
      foreach my $element (@{$object->elements_list}) {
	if ($element->[0] eq '#TEXT') {
	  unless ($type->{sequence}{text}) {
	    my $what = $tag || $type->{name} || $type->{'-name'};
	    _warn("Text not allowed in the sequence '$what', writing it anyway\n");
	  }
	  $xml->characters($element->[1]);
	} elsif ($element->[0] ne '') {
	  my $eltype = $sequence->{element}{$element->[0]};
	  if ($eltype) {
	    write_object($xml, $fsfile, $types,$eltype,$element->[0],$element->[1]);
	  } else {
	    my $what = $tag || $type->{name} || $type->{'-name'};
	    _warn("Element '".$element->[0]."' not allowed in the sequence '$what', skipping\n");
	  }
	} else {
	  my $what = $tag || $type->{name} || $type->{'-name'};
	  _warn("The sequence '$what' contains element with no name, skipping\n");
	}
      }
    } else {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _die("Unexpected content of the sequence '$what': $object\n");
    }
    $xml->endTag($tag) if defined($tag);
  } elsif (exists $type->{container}) {
    my $what = $tag || $type->{name} || $type->{'-name'};    
    unless (UNIVERSAL::isa($object,'HASH')) {
      _die("Unexpected type of the container '$what': $object\n");
    }
    my $container = $type->{container};
    my %attribs;
    unless ($no_attribs) {
      foreach my $attrib (values(%{$container->{attribute}})) {
	my $atr = $attrib->{-name};
	if ($attrib->{required} or  $object->{$atr} ne "") {
	  $attribs{$atr} = $object->{$atr}
	}
      }
      if (%attribs and !defined($tag)) {
	_warn("Internal error: too late to serialize attributes of a container in '$what'");
      }
    }
    my $content = $object->{'#content'};
    if ($container->{role} eq '#NODE' and 
	  UNIVERSAL::isa($object,'FSNode')) {
      $content = get_childnodes($object,$types,$container,$content,$what);
    }
    write_object($xml, $fsfile, $types,$container,[$tag,{%$attribs,%attribs}],$content);
  } elsif (exists $type->{constant}) {
    if ($object ne $type->{constant}) {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Invalid constant '$what', should be '$type->{constant}', got: ",$object);
    }
    $xml->startTag($tag,%$attribs) if defined($tag);
    $xml->characters($object);
    $xml->endTag($tag) if defined($tag);
  } else {
    _die("Type error: Unrecognized data type, object cannot be serialized in this context. Type declaration:\n".Dumper($type));
  }
  1;
}

sub validate_object_knit {
  my ($log,$path,$types,$type,$tag,$knit_tag,$object)=@_;
  my $ref = $object->{id};
  _debug("validate_knit_object: $path/$knit_tag, $object");
  if ($object->{id} eq "" or ref($object->{id})) {
    push @$log, "$path/$knit_tag/id: invalid ID: $object->{id}\n";
  }
  if ($ref =~ /^.+#.|^[^#]+$/) {
    validate_object($log, $path, $types, resolve_type($types,$type), $knit_tag, $object);
  } else {
    push @$log, "$path/$knit_tag/id: invalid PMLREF '$ref'";
  }
}

sub validate_object ($$$$$$) {
  my ($log, $path, $types, $type, $tag, $object)=@_;
  my $pre=$type;
  $path.="/".$tag if $tag ne "";
  _debug("validate_object: $path, $object");
  $type = resolve_type($types,$type);
  unless (ref($type)) {
    push @$log, "$path: Invalid type: $type";
  }
  if ($type->{cdata}) {
    if (ref($object)) {
      push @$log, "$path: expected CDATA, got: ",ref($object);
    } elsif ($type->{cdata}{format} eq 'nonNegativeInteger') {
      push @$log, "$path: CDATA value is not formatted as nonNegativeInteger: '$object'"
	unless $object=~/^\s*\d+\s*$/;
    } # TODO - check validity of other formats
  } elsif (exists $type->{constant}) {
    if ($object ne $type->{constant}) {
      push @$log, "$path: invalid constant, should be '$type->{constant}', got: ",$object;
    }
  } elsif (exists $type->{choice}) {
    my $ok;
    foreach (@{$type->{choice}}) {
      if ($_ eq $object) {
	$ok = 1;
	last;
      }
    }
    push @$log, "$path: Invalid value: '$object'" unless ($ok);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (!ref($object)) {
      push @$log, "$path: Unexpected content of a structure $struct->{name}: '$object'";
    } elsif (keys(%$object)) {
      foreach my $atr (grep {$members->{$_}{as_attribute}} keys %$members) {
	if ($members->{$atr}{required} or $object->{$atr} ne "") {
	  if (ref($object->{$atr})) {
	    push @$log, "$path/$atr: invalid content for member declared as attribute: ".ref($object->{$atr});
	  }
	}
      }
      foreach my $member (grep {!$members->{$_}{as_attribute}}
			  keys %$members) {
	my $mtype = resolve_type($types,$members->{$member});
	if ($members->{$member}{role} eq '#CHILDNODES') {
	  if (ref($object) ne 'FSNode') {
	    push @$log, "$path/$member: #CHILDNODES member with a non-node value:\n".Dumper($object);
	  }
	} elsif ($members->{$member}{role} eq '#KNIT') {
	  my $knit_tag = $member;
	  $knit_tag =~ s/\.rf$//;
	  if ($object->{$member} ne "") {
	    if (ref($object->{$member})) {
	      push @$log, "$path/$member: invalid content for member with role #KNIT: ",ref($object->{$member});
	    }
	    if (ref($object->{$knit_tag}) or $object->{$knit_tag} ne "") {
	      push @$log, "$path/$knit_tag: both '$member' and '$knit_tag' are present for a #KNIT member";
	    }
	  } else {
	    if (ref($object->{$knit_tag})) {
	      validate_object_knit($log,$path,$types,$members->{$member},$member,$knit_tag,$object->{$knit_tag});
	    } elsif ($object->{$knit_tag} ne '') {
	      push @$log, "$path/$knit_tag: invalid value for a #KNIT member: '$object->{$knit_tag}'";
	    }
	  }
	} elsif (ref($mtype) and $mtype->{list} and
		 $mtype->{list}{role} eq '#KNIT') {
	  # KNIT list
	  my $knit_tag = $member;
	  $knit_tag =~ s/\.rf$//;
	  if ($object->{$member} ne "" and
	      $object->{$knit_tag} ne "") {
	    push @$log, "$path/$knit_tag: both '$member' and '$knit_tag' are present for a #KNIT member";
	  } elsif ($object->{$member} ne "") {
	    _debug("validating as $member not $knit_tag");
	    validate_object($log, $path, $types,$members->{$member},$member,$object->{$member});
	  } else {
	    my $list = $object->{$knit_tag};
	    if (ref($list) eq 'Fslib::List') {
	      for (my $i=1; $i<=@$list;$i++) {
		validate_object_knit($log,$path."/$knit_tag",$types,$mtype->{list},$member,"[$i]",$list->[$i-1]);
	      }
	    } elsif ($list ne "") {
	      push @$log, "$path/$knit_tag: not a list: ",ref($object->{$knit_tag});
	    }
	  }
	} elsif ($object->{$member} ne "" or $members->{$member}{required}) {
	  validate_object($log, $path, $types,$members->{$member},$member,$object->{$member});
	}
      }
    } else {
      push @$log, "$path: structure is empty";
    }
  } elsif (exists $type->{list}) {
    if (ref($object) eq 'Fslib::List') {
      for (my $i=1; $i<=@$object; $i++) {
	validate_object($log, $path, $types,$type->{list},"[$i]",$object->[$i-1]);
      }
    } else {
      push @$log, "$path: unexpected content of a list: $object\n";
    }
  } elsif (exists $type->{alt}) {
    if ($object ne "" and ref($object) eq 'Fslib::Alt') {
      for (my $i=1; $i<=@$object; $i++) {
	validate_object($log, $path, $types,$type->{alt},"[$i]",$object->[$i-1]);
      }
    } else {
      validate_object($log, $path, $types,$type->{alt},undef,$object);
    }
  } elsif (exists $type->{container}) {
    if (not UNIVERSAL::isa($object,'HASH')) {
      push @$log, "$path: unexpected container (should be a HASH): $object";
    } else {
      my $container = $type->{container};
      my $attributes = $container->{attribute};
      foreach my $atr (keys %$attributes) {
	if ($attributes->{$atr}{required} or $object->{$atr} ne "") {
	  if (ref($object->{$atr})) {
	    push @$log, "$path/$atr: invalid content for attribute: ".ref($object->{$atr});
	  } else {
	    validate_object($log, $path, $types,$attributes->{$atr},$atr,$object->{$atr});
	  }
	}
      }
      my $content = $object->{'#content'};
      if ($container->{role} eq '#NODE') {
	if (!UNIVERSAL::isa($object,'FSNode')) {
	  push @$log, "$path: container declared as #NODE should be a FSNode object: $object";
	} else {
	  my $cont_type = resolve_type($types,$container);
	  if (ref($cont_type) and ref($cont_type->{sequence}) and $cont_type->{sequence}{role} eq '#CHILDNODES') {
	    if ($content ne "") {
	      push @$log, "$path: #NODE container containing a #CHILDNODES should have empty #content: $content";
	    }
	    $content = Fslib::Seq->new([map { [$_->{'#name'},$_] } $object->children]);
	  }
	}
      }
      validate_object($log, $path, $types,$container,'#content',$content);
    }
  } elsif (exists $type->{sequence}) {
    if (UNIVERSAL::isa($object,'Fslib::Seq')) {
      my $sequence=$type->{sequence};
      foreach my $element ($object->elements) {
	if (!(UNIVERSAL::isa($element,'ARRAY') and @$element==2)) {
	  push @$log, "$path: invalid sequence content: ",ref($element);
	} elsif ($element->[0] eq '#TEXT') {
	  if ($sequence->{text}) {
	    if (ref($element->[1])) {
	      push @$log, "$path: expected CDATA, got: ",ref($element->[1]);
	    }
	  } else {
	    push @$log, "$path: text node not allowed here\n";
	  }
	} else {
	  my $eltype = $sequence->{element}{$element->[0]};
	  if ($eltype) {
	    validate_object($log, $path, $types,$eltype,$element->[0],$element->[1]);
	  } else {
	    push @$log, "$path: undefined element '$element->[0]'",Dumper($type);
	  }
	}
      }
      if ($sequence->{content_pattern} and !$object->validate($sequence->{content_pattern})) {
	push @$log, "$path: sequence content (".join(",",$object->names).") does not follow the pattern ".$sequence->{content_pattern};
      }
    } else {
      push @$log, "$path: unexpected content of a sequence: $object\n";
      push @$log, Dumper($type);
    }
  } else {
    push @$log, "$path: unknown type: ".Dumper($type);
  }
  return (@$log == 0);
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
    IOBackend::close_backend($fh);
    return $test;
  }
}

  package MyDOMWriter;
  sub new {
    my ($class,%args)=@_;
    $class = ref($class) || $class;

    unless ($args{DOM} || $args{ELEMENT} || $args{REPLACE} ) {
      _die("Usage: $class->new(ELEMENT => XML::LibXML::Document)");
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
	_die ("Can't end ".
	  ($self->{ELEMENT} ? '<'.$self->{ELEMENT}->nodeName.'>' : 'none').
	    " with </$name>");
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
