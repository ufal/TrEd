package PML2FS;
use Fslib;
use IOBackend qw(close_backend);
use strict;

use XML::Simple; # for PML schema
use XML::LibXML;
use XML::LibXML::Common qw(:w3c :encoding);
use vars qw(@pmlformat @pmlpatterns $pmlhint $encoding $pml_ns);

$pml_ns = "http://ufal.mff.cuni.cz/pdt/pml/";

$encoding='utf8';
@pmlformat = (
);

@pmlpatterns = (
'<?$${form} unless $${form} eq \'???\' ?>${trace}${label}',
'style:#{Line-coords:n,n,n,p&n,p,p,p}'
);

$pmlhint="";

sub _debug {
  print "PML2FS: ",@_,"\n";
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


sub get_pml_schema {
  my ($file)=@_;
  print STDERR "$file\n";
  my $fh = IOBackend::open_backend($file,'r');
  die "Couldn't open PML schema file '$file'\n" unless $fh;
  local $/;
  my $slurp = <$fh>;
  my $simple = XMLin($slurp,
 		     ForceArray=>[ 'member', 'attribute', 'value' ],
 		     KeyAttr => { "member" => "name",
				  "attribute" =>"name",
				  "type" => "name"
 				 },
 		     GroupTags => { "choice" => "value" }
 		    );
  close $fh;
  return $simple;
}


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
  $fsfile->FS->defs->{id}=' K';
  read_references($fsfile,$dom_root);

  if (ref($fsfile->metaData('schema'))) {
    $return = read_with_schema($fsfile,$dom_root);
  } elsif ($dom_root->localname() eq "mdata" and
      $dom_root->namespaceURI() eq $pml_ns) {
    $return = read_mdata($fsfile,$dom_root);
  } elsif ($dom_root->localname() eq "adata" and
	   $dom_root->namespaceURI() eq $pml_ns) {
    $fsfile->FS->defs->{ord}=' N';
    $fsfile->FS->defs->{'m/w/origf'}=' K V';
    my $m_file = $fsfile->metaData('references')->{'m'};
    # read morphological file if available
    _debug("MFile: $m_file");
    if ($m_file and $m_file ne $fsfile->filename()) {
      my $m_fh = open_backend($m_file,'r');
      _debug("M_FH: $m_fh");
      if ($m_fh) {
	my $m_dom = $parser->parse_fh($m_fh);
	_debug("M_DOM: $m_dom");
	$parser->process_xincludes($m_dom);
	$fsfile->changeMetaData('m',$m_dom);
	$fsfile->changeMetaData('m-lookup', index_by_id($m_dom));
      }
      close_backend($m_fh);
    }

    # knit with morphological data
    $return = read_trees($fsfile,$dom_root,{ 'm.rf' => $fsfile->metaData('m-lookup') });

  } elsif ($dom_root->localname() eq "tdata" and
	   $dom_root->namespaceURI() eq $pml_ns) {
    _debug("tdata\n");
    $fsfile->FS->defs->{dord}=' N';
    $return = read_trees($fsfile,$dom_root);
    my $a_file = $fsfile->metaData('references')->{a};

    if ($a_file and $a_file ne $fsfile->filename()) {
      # read analytical tree too
      my $afh = open_backend($a_file,'r');
      if ($afh) {
 	my $a_fsfile = FSFile->new();
 	$a_fsfile->changeFilename($a_file);
 	&read($afh,$a_fsfile);
	$fsfile->changeMetaData('a-ids',index_fs_by_id($a_fsfile));
	$fsfile->changeMetaData('a-fs',$a_fsfile);
      }
    }

#     if ($a_file and $a_file ne $fsfile->filename()) {
#       # read analytical tree too
#       my $afh = open_backend($a_file);
#       if ($afh) {
# 	my $a_fsfile = FSFile->new();
# 	$a_fsfile->changeFilename($a_file);
# 	__PACKAGE__::read($afh,$a_fsfile);
#       }
#     }
  } else {
    die "Unknown XML data: ",$dom_root->localname()," ",$dom_root->namespaceURI(),"\n";
  }
  @{$fsfile->FS->list} = grep {$_ ne $Fslib::special } sort keys %{$fsfile->FS->defs};
  return $return;
}


sub read_references {
  my ($fs_file,$dom_root)=@_;
  my %references;
  my ($head) = $dom_root->getElementsByTagNameNS($pml_ns,'head');
  if ($head) {
    my ($references) = $head->getElementsByTagNameNS($pml_ns,'references');
    if ($references) {
      foreach my $reffile ($references->getElementsByTagNameNS($pml_ns,'reffile')) {
	$references{ $reffile->getAttribute('id') } =
	  $reffile->getAttribute('href');
      }
    }
    my ($schema) = $head->getElementsByTagNameNS($pml_ns,'schema');
    if ($schema) {
      my $schema_file = $schema->getAttribute('href');
      if ($schema_file !~ m{^[[:alnum:]]+:|/}) {
	my ($dir) = $fs_file->filename =~ m{^(.*\/)};
	$schema_file=$dir.$schema_file;
      }
      $fs_file->changeMetaData('schema',get_pml_schema($schema_file));
    }
  }
  $fs_file->changeMetaData('references',\%references);
}

=item read_Seq($node)

If given DOM node contains a pml:Seq, return a list of its members,
otherwise return the node itself.

=cut

sub read_Seq ($) {
  my ($node)=@_;
  return unless $node;
  my ($Seq) = $node->getChildrenByTagNameNS($pml_ns,'Seq');
  return $Seq ? $Seq->getChildrenByTagNameNS($pml_ns,'M') : $node;
}

=item read_Alt($node)

If given DOM node contains a pml:Alt, return a list of its members,
otherwise return the node itself.

=cut

sub read_Alt ($) {
  my ($node)=@_;
  return unless $node;
  my ($Alt) = $node->getChildrenByTagNameNS($pml_ns,'Alt');
  return $Alt ? $Alt->getChildrenByTagNameNS($pml_ns,'M') : $node;
}


sub read_attr ($$$$;$) {
  my ($node,$fs_node,$defs,$attr,$knit)=@_;
  $attr = ($attr ne "") ? ($attr."/".$node->localname) : $node->localname;
  my @c = grep { $_->nodeType == ELEMENT_NODE } $node->childNodes;
  if (@c) {
    if ($c[0]->localname eq 'Seq' and $c[0]->namespaceURI eq $pml_ns) {
      $defs->{$attr} = ' K' unless (exists $defs->{$attr});
      $fs_node->{$attr}=join '|',map { $_->textContent } read_Seq($node);
    } elsif ($c[0]->localname eq 'Alt' and $c[0]->namespaceURI eq $pml_ns) {
      $defs->{$attr} = ' K' unless (exists $defs->{$attr});
      $fs_node->{$attr}=join '|',map { $_->textContent } read_Alt($node);
    } else {
      foreach (@c) {
	read_attr($_,$fs_node,$defs,$attr);
      }
    }
  } else {
    my $value = $node->textContent;
    $defs->{$attr} = ' K' unless (exists $defs->{$attr});
    $fs_node->{$attr}=$value;
    my $knit_hash = $knit->{$attr} if $knit;
    if ($knit_hash) {
      my $ref = $value;
      $ref =~ s/.*#//;
      $attr =~ s/\.rf$//;
      my $knit_with = $knit_hash->{$ref} if $knit_hash;
      if ($knit_with) {
	#_debug("Knitting $ref");
	foreach (grep { $_->nodeType == ELEMENT_NODE } $knit_with->childNodes) {
	  read_attr($_,$fs_node,$defs,$attr);
	}
      } else {
	_debug("Can't knit  $value") if $knit_hash;
      }
    }
  }
}

sub read_node ($$;$) {
  my ($node,$fsfile,$knit)=@_;

  my $fs_node=FSNode->new();
  $fs_node->{'id'} = $node->getAttribute('id');
  foreach my $child (grep {$node->nodeType == ELEMENT_NODE } $node->childNodes) {
    if ($child->namespaceURI eq $pml_ns) {
      if ($child->localname eq 'children') {
	foreach my $c (read_Seq($child)) {
	  Paste(read_node($c, $fsfile,$knit),$fs_node,$fsfile->FS->defs());
	}
      } else {
	read_attr($child,$fs_node,$fsfile->FS->defs(),"",$knit);
      }
    } else {
      $fs_node->{$node->namespaceURI.'#'.$node->localname}=$node->toString;
    }
  }
  return $fs_node;
}

sub read_trees ($$;$) {
  my ($fsfile, $dom_root, $knit) = @_;
  my ($trees) = $dom_root->getChildrenByTagNameNS($pml_ns,'trees');
  unless ($trees) {
    die "no trees\n";
  }
  _debug("Knit: $knit\n");
  foreach my $tree (read_Seq($trees)) {
    push @{$fsfile->treeList}, read_node($tree,$fsfile,$knit);
  }
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

sub read_node_with_schema ($$$;$) {
  my ($node,$fsfile,$types,$type) = @_;
  my $defs = $fsfile->FS->defs;
  if ($type eq 'REF' or $type eq 'CDATA') {
    return $node->textContent;
  }
  unless (ref($type)) {
    die "Unknown node type: $type\n";
  }
  if ($type->{seq}) {
    return bless [
      map {
	read_node_with_schema($_,$fsfile,
			      $types,resolve_type($types,$type->{seq}))
      } read_Seq($node)
    ], 'Fslib::Seq';
  }

  # on-Seq
  if ($type->{member}) {
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
	 $child->namespaceURI eq $pml_ns) {
	my $name = $child->localname;
	my $member = $type->{member}->{$name};
	if ($member) {
	  my $role;
	  $role = $member->{role} if ref($member);
	  $member = resolve_type($types,$member);
	  $role ||= $member->{role} if ref($member);
	  if (ref($member) and $member->{role} eq '#CHILDNODES') {
	    if (ref($hash) eq 'FSNode') {
	      my $seq =
		read_node_with_schema($child,$fsfile,
				      $types,
				      $member);
	      $hash->{$Fslib::firstson} = $seq->[0];
	      my $prev=0;
	      foreach my $son (@{$seq}) {
		unless (ref($son) eq 'FSNode') {
		  die "non-#NODE child of '".$node->localname."'\n";
		}
		$son->{$Fslib::parent} = $hash;
		$son->{$Fslib::lbrother} = $prev;
		$prev->{$Fslib::rbrother} = $son if $prev;
		$prev = $son;
	      }
	    } else {
	      die "#CHILDNODES member '$name' encountered in non-#NODE element '".$node->localname."'\n";
	    }
	  } else {
	    if ($role eq "#ORDER") {
	      $defs->{$name} = ' N' unless exists($defs->{$name});
	    } else {
	      $defs->{$name} = ' K' unless exists($defs->{$name});
	    }
	    $hash->{$name} = read_node_with_schema($child,$fsfile,
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
	       and $child->namespaceURI eq $pml_ns) {
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
    my ($Alt) = $node->getChildrenByTagNameNS($pml_ns,'Alt');
    if ($Alt) {
      return bless [
	map {
	  read_node_with_schema($_,$fsfile,
				$types,resolve_type($types,$type->{alt}))
	} $Alt->getChildrenByTagNameNS($pml_ns,'M'),
       ], 'Fslib::Alt';
    } else {
      return read_node_with_schema($node,$fsfile,
				   $types,
				   resolve_type($types,$type->{alt}));
    }


  }
}

sub read_with_schema {
  my ($fsfile, $dom_root) = @_;
  my $types = $fsfile->metaData('schema')->{type};
  my %roles;
  foreach my $t (keys %$types) {
    print $t,"\n";
    $roles{$types->{$t}->{role}}{$t}=1 if ($types->{$t}->{role});
  }
  use Data::Dumper;

  for my $child ($dom_root->childNodes) {
    if ($child->nodeType == ELEMENT_NODE and
	$child->namespaceURI eq $pml_ns and
	$roles{'#TREES'}{$child->localname}) {
      my $type = $types->{$child->localname};
      if ($type->{seq}) {
	if ($type->{seq} and
	    $roles{'#NODE'}{$type->{seq}{type}}) {
# rework as: read Seq incl. the blessed object
# and turn it into a simple list

	  my $trees;
	  $trees = read_node_with_schema($child,$fsfile,$types,$type);
	  if (ref($trees) eq 'Fslib::Seq') {
	    @{$fsfile->treeList} = @$trees
	  } else {
	    @{$fsfile->treeList} = ($trees);
	  }
	  print "ORDER: ",Fslib::ASpecial($fsfile->FS->defs,"N"),"\n";
#
#	  foreach my $tree (read_Seq($child, $types)) {
#	    push @{$fsfile->treeList}, read_node_with_schema($tree,$fsfile,$types,$types->{});
#	  }

	} else {
	  die "Expected 'seq' of #NODE types in role #TREES\n";
	}
	  
      } else {
	die "Expected 'seq' in role #TREES\n";
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
  print STDERR "Error: Writing not supported by this module!"
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
    return 1 if /<[amt]data/;
    1 while ($_=$f->getline() and !/\S/);
    return (/<[amt]data/) ? 1 : 0;
  } else {
    my $fh = IOBackend::open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

1;
