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

$DEBUG=1;

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


sub absolutize_path ($$) {
  my ($orig, $href)=@_;
  if ($href !~ m{^[[:alnum:]]+:|^/}) {
    $orig =~ m{^(.*\/)};
    return $1.$href;
  } else {
    return $href;
  }
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
	$references{ $id } =
	  absolutize_path($fsfile->filename,$reffile->getAttribute('href'));
      }
    }
    my ($schema) = $head->getElementsByTagNameNS(PML_NS,'schema');
    if ($schema) {
      my $schema_file = absolutize_path($fsfile->filename,$schema->getAttribute('href'));
      $fsfile->changeMetaData('schema-url',$schema_file);
      $fsfile->changeMetaData('schema',Fslib::Schema->readFrom($schema_file));
    }
  }
  $fsfile->changeMetaData('references',\%references);
  $fsfile->changeMetaData('refnames',\%named_references);
}

=item read_List($node)

If given DOM node contains a pml:List, return a list of its members,
otherwise return the node itself.

=cut

sub read_List ($) {
  my ($node)=@_;
  return unless $node;
  my $List = $node->getChildrenByTagNameNS(PML_NS,LM);
  return @$List ? @$List : $node;
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

  if ($type->{list}) {
    return bless [
      map {
	read_node($_,$fsfile,
		  $types,resolve_type($types,$type->{list}))
      } read_List($node)
    ], 'Fslib::List';
  } elsif ($type->{member} or $type->{attribute}) {
    # structure
    my $hash = ($type->{role} eq '#NODE') ? FSNode->new() : {};

    if ($type->{attribute}) {
      foreach my $atr (keys %{$type->{attribute}}) {
	die "Missing required attribute '$atr' of "._element_address($node)
	  unless $type->{attribute}{$atr}{optional} or $node->hasAttribute($atr);
	$hash->{$atr} = $node->getAttribute($atr);
      }
    }
    # we silently ignore all other attributes :-/

    my $child = $node->firstChild;
    while ($child) {
      if($child->nodeType == ELEMENT_NODE
	 and
	 $child->namespaceURI eq PML_NS) {
	my $name = $child->localname;
	my $member = $type->{member}->{$name};
	if ($member) {
	  my $role;
	  $role = $member->{role} if ref($member);
	  $member = resolve_type($types,$member);
	  $role ||= $member->{role} if ref($member);
	  if (ref($member) and $role eq '#CHILDNODES') {
	    if (ref($hash) eq 'FSNode') {
	      my $list = read_node($child,$fsfile,$types,$member);
	      $hash->{$Fslib::firstson} = $list->[0];
	      my $prev=0;
	      foreach my $son (@{$list}) {
		unless (ref($son) eq 'FSNode') {
		  die "non-#NODE child '$name' of '".$node->localname.
		    "' at line ".$child->line_number."\n";
		}
		$son->{$Fslib::parent} = $hash;
		$son->{$Fslib::lbrother} = $prev;
		$prev->{$Fslib::rbrother} = $son if $prev;
		$prev = $son;
	      }
	    } else {
	      die "#CHILDNODES member '$name' encountered in non-#NODE element '".$node->localname.
		"' at line ".$child->line_number."\n";
	    }
	  } elsif (ref($member) and $role eq '#KNIT') {
	    my $ref = $child->textContent();
	    # _debug("KNIT: name=$name, '$ref');
	    if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
	      my ($reffile,$idref)=($1,$2);
	      my $refdom = ($reffile ne "") ? $fsfile->metaData('ref')->{$reffile} : $child->ownerDocument;
	      if (ref($refdom)) {
		my $refnode =
		  $fsfile->metaData('ref-index')->{$reffile}{$idref} ||
		    $refdom->getElementsById($idref);
		if (ref($refnode)) {
		  #	  _debug("KNIT: $idref");
		  #	  _debug("KNIT-TYPE: ",Dumper(resolve_type($types,$type->{knit})));
		  #	  _debug($refnode->toString(1));
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
	  die "Undefined member '$name' in '".$node->localname."' encountered\n";
	}
      } elsif (($child->nodeType == TEXT_NODE
		or $child->nodeType == CDATA_SECTION_NODE)
		and $child->data=~/\S/) {
	warn "Ignoring text content '".$child->data."'.\n";
      } elsif ($child->nodeType == ELEMENT_NODE
	       and $child->namespaceURI eq PML_NS) {
	warn "Ignoring non-PML element '".$child->nodeName."'.\n";
      }
    } continue {
      $child = $child->nextSibling;
    }
    foreach (keys %{$type->{member}}) {
      die "Missing required member '$_' of '".
	$node->localname."' at line ".$node->line_number."\n"
	  unless exists($hash->{$_}) or $type->{member}{$_}{optional};
    }
    return $hash;
  } elsif ($type->{choice}) {
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
      die "Invalid value '$data' for '".$node->localname."'\n";
    }
    return $data;
  } elsif ($type->{alt}) {
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
    _debug(Dumper($references));
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
	      for (qw(ref ref-index)) {
		$fsfile->changeMetaData($_,{}) unless $fsfile->metaData($_)
	      }
	      $fsfile->metaData('ref')->{$refid}=$ref_data;
	      $fsfile->metaData('ref-index')->{$refid}=index_by_id($ref_data);
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

  my $types = $fsfile->metaData('schema')->{type};
  my %roles;
  foreach my $t (keys %$types) {
    _debug($t);
    $roles{$types->{$t}->{role}}{$t}=1 if ($types->{$t}->{role});
  }

  _debug("reading trees ".join(",",%{$roles{'#TREES'}}),"\n");


  for my $child ($dom_root->childNodes) {
    if ($child->nodeType == ELEMENT_NODE and
	$child->namespaceURI eq PML_NS and
	$roles{'#TREES'}{$child->localname}) {
      _debug("found tree ",$child->localname);
      my $type = $types->{$child->localname};
      if ($type->{list}) {
	if ($type->{list} and
	    $roles{'#NODE'}{$type->{list}{type}}) {
# rework as: read List incl. the blessed object
# and turn it into a simple list

	  my $trees;
	  $trees = read_node($child,$fsfile,$types,$type);
	  if (ref($trees) eq 'Fslib::List') {
	    @{$fsfile->treeList} = @$trees
	  } else {
	    @{$fsfile->treeList} = ($trees);
	  }
#	  _debug("ORDER: ",Fslib::ASpecial($fsfile->FS->defs,"N"));;
#
#	  foreach my $tree (read_List($child, $types)) {
#	    push @{$fsfile->treeList}, read_node($tree,$fsfile,$types,$types->{});
#	  }

	} else {
	  die "Expected 'list' of #NODE types in role #TREES\n";
	}
      } else {
	die "Expected 'list' in role #TREES\n";
      }
    } else {
      # store ??
    }
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
  my $types = $fsfile->metaData('schema')->{type};
  my %roles;
  foreach my $t (keys %$types) {
    _debug($t);
    $roles{$types->{$t}->{role}}{$t}=1 if ($types->{$t}->{role});
  }
  my ($data) = keys (%{$roles{'#DATA'}});

  $xml->xmlDecl("utf-8");
  $xml->startTag($data,xmlns => PML_NS);
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
  my ($trees) = keys (%{$roles{'#TREES'}});
  my $tree_list = bless [$fsfile->trees],'Fslib::List';
  write_object($xml, $fsfile, $types,$types->{$trees},$trees,$tree_list);
  $xml->endTag($data);
  $xml->end;

  # write embedded DOM documents
  my $references = $fsfile->metaData('schema')->{reference};
  if ($references) {
    foreach my $reference (@$references) {
      my $refid = $fsfile->metaData('refnames')->{$reference->{name}};
      if ($refid) {
	my $href = $fsfile->metaData('references')->{$refid};
	if ($href and $reference->{readas} eq 'dom' and
	      ref($fsfile->metaData('ref'))) {
	  my $dom = $fsfile->metaData('ref')->{$refid};
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

sub write_object ($$$$) {
  my ($xml,$fsfile, $types,$type,$tag,$object)=@_;
  $type = resolve_type($types,$type);
  if (!ref($type)) {
    $xml->startTag($tag);
    $xml->characters($object);
    $xml->endTag($tag);
  } elsif ($type->{choice}) {
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
  } elsif ($type->{member} or $type->{attribute}) {
    if (ref($object)) {
      my %attribs;
      if ($type->{attribute}) {
	foreach my $atr (sort keys %{$type->{attribute}}) {
	  if ($type->{attribute}{$atr}{optional} or $object->{$atr} ne "") {
	    $attribs{$atr} = $object->{$atr};
	  }
	}
      }
      $xml->startTag($tag,%attribs);
      if ($type->{member}) {
	foreach my $member (sort keys %{$type->{member}}) {
#	  _debug("Writing children to $member");
	  if ($type->{member}{$member}{role} eq '#CHILDNODES') {
	    if (ref($object) eq 'FSNode') {
	      if ($object->firstson or !$type->{member}{$member}{optional}) {
		write_object($xml, $fsfile, $types,$type->{member}{$member},$member,
			     bless([ $object->children ],'Fslib::List'));
	      }
	    } else {
	      warn "Found #CHILDNODES member '$tag/$member' on a non-node value: $object\n";
	    }
	  } elsif ($type->{member}{$member}{role} eq '#KNIT') {
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
		  my $indeces = $fsfile->metaData('ref-index');
		  if ($indeces and $indeces->{$reffile}) {
		    my $knit = $indeces->{$reffile}{$idref};
		    if ($knit) {
		      #_debug($knit->toString(1));
		      my $knit_tag = $name;
#		      $knit_tag = LM if ($knit->nodeName =~ /^(Alt|List)$/ and
#				     $knit->parentNode->namespaceURI eq PML_NS);
		      my $dom_writer = MyDOMWriter->new(REPLACE => $knit);
		      write_object($dom_writer, $fsfile, $types,
				   resolve_type($types,$type->{member}{$member}),
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
	  } elsif ($object->{$member} ne "" or !$type->{member}{$member}{optional}) {
	    write_object($xml, $fsfile, $types,$type->{member}{$member},$member,$object->{$member});
	  }
	}
      }
      $xml->endTag($tag);
    } else {
      # what do we do now?
      warn "Unexpected content structure '$tag': $object\n";
    }
  } elsif ($type->{list}) {
    if ($object ne "" and ref($object) eq 'Fslib::List') {
      if (@$object == 0) {
	# what do we do now?
#      } elsif (@$object == 1) {
#	write_object($xml, $fsfile,  $types,$type->{list},$tag,$object->[0]);
      } else {
	$xml->startTag($tag);
#	$xml->startTag('List');
	foreach my $member (@$object) {
	  write_object($xml, $fsfile, $types,$type->{list},LM,$member);
	}
#	$xml->endTag('List');
	$xml->endTag($tag);
      }
    } else {
      warn "Unexpected content of List '$tag': $object\n";
    }
  } elsif ($type->{alt}) {
    if ($object ne "" and ref($object) eq 'Fslib::Alt') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	write_object($xml, $fsfile, $types,$type->{alt},$tag,$object->[0]);
      } else {
	$xml->startTag($tag);
#	$xml->startTag('Alt');
	foreach my $member (@$object) {
	  write_object($xml, $fsfile, $types,$type->{alt},AM,$member);
	}
#	$xml->endTag('Alt');
	$xml->endTag($tag);
      }
    } else {
      write_object($xml, $fsfile, $types,$type->{alt},$tag,$object);
    }
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
    return 1 if /<[atx]data/;
    1 while ($_=$f->getline() and !/\S/);
    return (/<[atx]data/) ? 1 : 0;
  } else {
    my $fh = IOBackend::open_backend($f,"r",$encoding);
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
