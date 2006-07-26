package PMLInstance;
# pajas@ufal.mff.cuni.cz          17 Jul 2006

use 5.008;
use strict; 
#use warnings;
use Carp;

require Exporter;
import Exporter qw(import);

use strict;
use vars qw( $DEBUG );

use Scalar::Util qw(weaken isweak);

$DEBUG = 1;

=for comment

 TODO 

  Note: correct writing with XSLT requires XML::LibXML >= 1.59 (!!!)

 (GENERAL):

  - improve reading/writing trees (use the live object)
    Postponing because:
       1/ sequences of tree/no-tree objects are problematic
       2/ changing this would break binary compatibility

  - Fslib:
       find_role_in_data,
       traverse_data($node, $decl, sub($data,$decl,$decl_resolved))

  - readas DOM => readas PML, where #KNITting means pointing to the same data (if possible).
    test implementation: breaks old Undo/Redo, but ok with the new "object-preserving" one

  (XSLT):

  - support for external xslt processors (maybe a common wrapper)
  - with LibXSLT, cache the parsed stylesheets

  DONE:

  - hash by #ID into appData('id-hash')/{'id-hash'} (knitted instances could be hashed with prefix#, 
    knitted-knitted instances with prefix1#prefix2#...)
    (this is temporary)

=cut

our %EXPORT_TAGS = ( 
  'constants' => [ qw( LM AM PML_NS PML_SCHEMA_NS SUPPORTED_PML_VERSIONS ) ],
  'diagnostics' => [ qw( _die _warn _debug ) ],
);
$EXPORT_TAGS{'all'} = [ @{ $EXPORT_TAGS{'constants'} }, @{ $EXPORT_TAGS{'diagnostics'} }, 
			qw( $DEBUG )
		      ];

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.01';

use constant EMPTY => qw();
use constant   LM => 'LM';
use constant   AM => 'AM';
use constant   PML_NS => "http://ufal.mff.cuni.cz/pdt/pml/";
use constant   PML_SCHEMA_NS => "http://ufal.mff.cuni.cz/pdt/pml/schema/";
use constant   SUPPORTED_PML_VERSIONS => " 1.1 ";

use constant {
  KNIT_FAIL   => 0,
  KNIT_OK     => 1,
  KNIT_WEAKEN => 2,
};

#FIELDS:
use fields qw(
    _schema 
    _schema-url
    _schema-inline
    _types
    _dom
    _root
    _parser
    _writer
    _filename
    _transform_id
    _status
    _readas-trees
    _references
    _refnames
    _ref
    _ref-index
    _pml_trees_type
    _trees
    _pml_prolog
    _pml_epilog
    _id-hash
    _log
    _id_prefix
    _trees_written
    _write_single_LM
    _refs_save
   );

# PML Instance File
sub get_filename	    {  $_[0]->{'_filename'}; }
sub set_filename	    {  $_[0]->{'_filename'} = $_[1]; }
sub get_transform_id	    {  $_[0]->{'_transform_id'}; }
sub set_transform_id	    {  $_[0]->{'_transform_id'} = $_[1]; }

# Schema
sub get_schema		    {  $_[0]->{'_schema'} }
sub set_schema		    {  $_[0]->{'_schema'} = $_[1] }
sub get_schema_url	    {  $_[0]->{'_schema-url'} }
sub set_schema_url	    {  $_[0]->{'_schema-url'} = $_[1]; }

# Data
sub get_root		    {  $_[0]->{'_root'}; }
sub set_root		    {  $_[0]->{'_root'} = $_[1]; }
sub get_trees		    {  $_[0]->{'_trees'}; }
sub set_trees		    {  $_[0]->{'_trees'} = $_[1]; }
sub get_trees_prolog	    {  $_[0]->{'_pml_prolog'}; }
sub set_trees_prolog	    {  $_[0]->{'_pml_prolog'} = $_[1]; }
sub get_trees_epilog	    {  $_[0]->{'_pml_epilog'}; }
sub set_trees_epilog	    {  $_[0]->{'_pml_epilog'} = $_[1]; }
sub get_trees_type	    {  $_[0]->{'_pml_trees_type'}; }
sub set_trees_type	    {  $_[0]->{'_pml_trees_type'} = $_[1]; }

# References
sub get_readas_trees	    {  $_[0]->{'_readas-trees'}; }
sub set_readas_trees	    {  $_[0]->{'_readas-trees'} = $_[1]; }
sub get_references	    {  $_[0]->{'_references'}; }
sub set_references	    {  $_[0]->{'_references'} = $_[1]; }
sub get_refnames	    {  $_[0]->{'_refnames'}; }
sub set_refnames	    {  $_[0]->{'_refnames'} = $_[1]; }
sub get_ref                 {  $_[0]->{'_ref'}; }
sub set_ref                 {  $_[0]->{'_ref'} = $_[1]; }

# Validation log
sub get_log {  
  my $log = $_[0]->{'_log'};
  if ($log) {
    return @$log;
  } else {
    return ();
  }
}
sub clear_log		    {  $_[0]->{'_log'} = []; }
# Status=1 (if parsed fine)
sub get_status		    {  $_[0]->{'_status'}; }
sub set_status		    {  $_[0]->{'_status'} = $_[1]; }


use Encode;
use XML::LibXML;
use XML::Writer;
use XML::LibXML::Common qw(:w3c :encoding);
use Data::Dumper;
use File::Spec;

require Fslib;
require PMLBackend;
import PMLBackend;
import PMLBackend qw(&_die &_warn &_debug);

###################################
# CONSTRUCTOR
####################################

sub new {
  my $class = shift;
  _die('Usage: ' . __PACKAGE__ . '->new()') if ref($class);
  return fields::new($class);
}

###################################
# DIAGNOSTICS
###################################

sub _die {
  my $msg = join EMPTY,@_;
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
  my $msg=join EMPTY,@_;
  chomp $msg;
  print STDERR "PMLBackend: $msg\n" if abs($DEBUG)>=$level;
}

sub _warn {
  my $msg = join EMPTY,@_;
  chomp $msg;
  if ($DEBUG>0) {
    Carp::cluck("PMLBackend: WARNING: $msg\n");
  } else {
    warn "PMLBackend: WARNING: $msg\n";
  }
}

sub _log {
  my $ctxt = shift;
  my $log = $ctxt->{'_log'} ||= [];
  push @$log, join EMPTY,@_;
}

###################################
# LOAD
###################################

sub load {
  my $ctxt = shift;
  my $opts = shift;
  
  if (!ref($ctxt)) {
    $ctxt = PMLInstance->new;
  }

  my $parser = $ctxt->{'_parser'} ||= $opts->{parser} || PMLBackend::xml_parser();
  $ctxt->{'_filename'} ||= $opts->{filename};
  if ($opts->{dom}) {
    $ctxt->{'_dom'} = delete $opts->{dom};
  } elsif ($opts->{fh}) {
    $ctxt->{'_dom'} = $parser->parse_fh($opts->{fh},
				     $ctxt->{'_filename'});
  } elsif ($opts->{string}) {
    $ctxt->{'_dom'} = $parser->parse_string($opts->{string},
					 $ctxt->{'_filename'});
  } elsif ($opts->{filename}) {
    my $fh = PMLBackend::open_backend($opts->{filename},'r');
    $ctxt->{'_dom'} = $parser->parse_fh($fh,
				     $opts->{filename});
    PMLBackend::close_backend($fh);
  }
  unless ($ctxt->{'_dom'}) {
    _die("Reading PML instance '".$ctxt->{'_filename'}."' to DOM failed!");
  }

  my $dom = $ctxt->{'_dom'};
  my $dom_root = $dom->getDocumentElement();
  $parser->process_xincludes($dom);
  $dom->setBaseURI($ctxt->{'_filename'}) if $dom->can('setBaseURI');
  
  # check NS
  if ($dom_root->namespaceURI ne PML_NS) {
    # TRANSFORM
    my $config = $opts->{config};
    if ($config and $config->{'_root'}) {
      foreach my $transform ($config->{'_root'}{transform_map}->values) {
	my $id = $transform->{'id'};
	if ($id eq EMPTY) {
	  _warn("PMLBackend: Skipping PML transform in ".$config->{'_filename'}." (required attribute id missing):".Dumper($transform));
	  next;
	}
	my ($in_xsl) = $transform->{in};
	next unless ($in_xsl and $in_xsl->{'type'} eq 'xslt');
	my $in_xsl_href = $in_xsl->getAttribute('href');
	my $test = $transform->{'test'};
	_debug("Testing XPath '$test' for XSLT transform '$in_xsl_href'");
	if ($in_xsl_href ne EMPTY and 
	      $test ne EMPTY and 
	  eval { $dom->find($test) }) {
	  if ( $in_xsl->{'type'} eq 'identity' ) {
	    _debug("Identity transformation to PML");
	    last;
	  }
	  _debug("Transforming to PML with XSLT '$in_xsl_href'");
	  $ctxt->{'_transform_id'} = $id;
	  my $params = $in_xsl->content;
	  my %params;
	  %params = map { $_->{'name'} => $_->value } $params->values if $params;
	  $in_xsl_href = Fslib::ResolvePath($config->{'_filename'}, $in_xsl_href, 1);
	  my $xslt = XML::LibXSLT->new;
	  my $in_xsl_parsed = $xslt->parse_stylesheet_file($in_xsl_href)
	    || _die("Can't locate XSL stylesheet '$in_xsl_href' declared as "._element_address($in_xsl));
	  $ctxt->{'_dom'} = $dom = $in_xsl_parsed->transform($dom,%params);
	  $dom_root = $dom->getDocumentElement;
	  $dom->setBaseURI($ctxt->{'_filename'}) if $dom and $dom->can('setBaseURI');
	  last;
	}
      }
    } else {
      _die("Root element isn't in PML namespace: ".$dom_root->localname()." ".$dom_root->namespaceURI());
    }
  }

  $ctxt->read_header();
  my $schema = $ctxt->{'_schema'};
  unless (ref($schema)) {
    _die("Instance doesn't provide PML schema: ".$dom_root->localname()." ".$dom_root->namespaceURI());
  }
  if ($schema->{version} eq EMPTY) {
    _die("PML Schema file ".$ctxt->{'_schema-url'}." does not specify version!");
  }
  if (index(SUPPORTED_PML_VERSIONS," ".$schema->{version}." ")<0) {
    _die("Unsupported PML Schema version ".$schema->{version}." in ".$ctxt->{'_schema-url'});
  }
  $ctxt->read_data();

  return $ctxt;
}


######################################################
# $ctxt
sub read_header {
  my $ctxt = shift;
  my $dom_root = $ctxt->{'_dom'}->getDocumentElement;

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
	$references{ $id } = Fslib::ResolvePath($ctxt->{'_filename'},
						Encode::encode_utf8($reffile->getAttribute('href')),0);
      _debug("read_head: $id => $references{$id}");

      }
    }
    my ($schema) = $head->getElementsByTagNameNS(PML_NS,'schema');
    if ($schema) {
      # Encode: all filenames must(!) be bytes
      if ($schema->hasAttribute('href')) {
	my $schema_file = Encode::encode_utf8($schema->getAttribute('href'));
	my %revision_opts;
	for my $attr (qw(revision maximal_revision minimal_revision)) {
	  $revision_opts{$attr}=$schema->getAttribute($attr) if $schema->hasAttribute($attr);
	}
	# store the original URL, not the resolved one!
	$ctxt->{'_schema-url'} = $schema_file;
	$ctxt->{'_schema'} = Fslib::Schema->readFrom($schema_file,
						  { base_url => $ctxt->{'_filename'},
						    use_resources => 1,
						    revision_error => 
						      "Error: ".$ctxt->{'_filename'}." requires different revision of PML schema %f: %e\n",
						    %revision_opts,
						  }
						 );
      } else {
	my ($inline) = $schema->getChildrenByTagNameNS(PML_SCHEMA_NS,'pml_schema');
	if ($inline) {
	  _debug("inline schema");
	  # we copy inline schema to a new document so that
	  # all namespace declarations are present in the string output
	  my $schema = XML::LibXML::Document->new;
	  # we cannot just adopt (move) it to the new document since
	  # the schema document might be a result of a XSLT transformation
          # and we would get a core-dump at de-allocation
	  # (maybe because XSLT uses dictionaries) 

	  $schema->setDocumentElement($schema->importNode($inline));

	  my $xml = $schema->toString();
	  $ctxt->{'_schema-url'} = undef;
	  $ctxt->{'_schema-inline'} = $xml;
	  $ctxt->{'_schema'} =
		  Fslib::Schema->new($xml,
				     { 
				       base_url => $ctxt->{'_filename'},
				       use_resources => 1,
				       filename => $ctxt->{'_filename'},
				     }
				    );	
	} else {
	  _die("PML instance must specify a PML schema in "._element_address($head));
	}
      }
    } else {
      _die("PML instance must specify a PML schema in "._element_address($head));
    }
  }
  $ctxt->{'_references'} = \%references;
  $ctxt->{'_refnames'} = \%named_references;
  $ctxt->{'_types'} = $ctxt->{'_schema'}->{type};
  return 1;
}

sub read_data {
  my $ctxt = shift;

  $ctxt->{'_status'} = 0;
  foreach my $ref ($ctxt->get_references()) {
    if ($ref->{readas} eq 'dom') {
      $ctxt->readas_dom($ref->{id},$ref->{href});
    } elsif($ref->{readas} eq 'trees') {
      $ctxt->readas_trees($ref->{id},$ref->{href});
    } elsif($ref->{readas} eq 'pml') {
      $ctxt->readas_pml($ref->{id},$ref->{href});
    } else {
      _warn("Ignoring references with unknown readas method: '$ref->{readas}'\n");
    }
  }
  my $schema = $ctxt->{'_schema'};
  my $root_type = $schema->{root};
  my $root_name = $schema->{root}{name};

  $root_type = $ctxt->resolve_type($root_type);

  my $dom_root = $ctxt->{'_dom'}->getDocumentElement;
  unless ($dom_root->namespaceURI eq PML_NS and
	  $dom_root->localname eq $root_name) {
    _die("Expected root element '$root_name', got '".$dom_root->localname."'\n".Dumper($schema));
  }
  unless (UNIVERSAL::isa($root_type,'HASH')) {
    _die("PML schema error - invalid root element declaration");
  }

  # In PML 1.1, root can either be a sequence or a structure
  if ($root_type->{structure} or $root_type->{sequence} or $root_type->{container}) {
    $ctxt->{'_root'} = read_node($ctxt, $dom_root, $root_type, { 
      # the child after <head>
      first_child => _skip_head($dom_root)
     });
  } else {
    _die("The root type must be a structure or a sequence: "._element_address($dom_root));
  }
  $ctxt->{'_status'} = 1;
  return 1;
}

sub resolve_type {
  my ($ctxt,$type)=@_;
  return $type unless ref($type);
  if ($type->{type}) {
    my $types = $ctxt->{'_types'} ||= $ctxt->{'_schema'}->{type};
    my $rtype = $types->{$type->{type}};
    return $rtype; # || $type->{type};
  } else {
    return $type;
  }
}

sub get_references {
  my ($ctxt)=@_;
  my $references = $ctxt->{'_schema'}->{reference};
  my @refs;
  if ($references) {
    foreach my $reference (@$references) {
      my $refid = $ctxt->{'_refnames'}->{$reference->{name}};
      if ($refid) {
	my $href = $ctxt->{'_references'}->{$refid};
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

sub readas_trees {
  my ($ctxt,$refid,$href)=@_;
  $ctxt->{'_readas-trees'} ||= [];
  push @{$ctxt->{'_readas-trees'}},[$refid,$href];
  1;
}

sub _index_by_id {
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

sub readas_pml {
  my ($ctxt,$refid,$href)=@_;
  # embed PML documents
  my $ref_data;

  my $pml = PMLInstance->load({ filename => $href });
  $ctxt->{'_ref'} ||= {};
  $ctxt->{'_ref'}->{$refid}=$pml;
  $ctxt->{'_ref-index'} ||= {};
  weaken( $ctxt->{'_ref-index'}->{$refid} = $pml->{'_id-hash'} );
  1;
}


# $ctxt, $refid, $href
sub readas_dom {
  my ($ctxt,$refid,$href)=@_;
  # embed DOM documents
  my $ref_data;

  my ($local_file,$remove_file) = IOBackend::fetch_file($href);
  my $ref_fh = IOBackend::open_backend($local_file,'r');
  _die("Can't open $href for reading") unless $ref_fh;
  _debug("readas_dom: $href $ref_fh");
  my $parser = $ctxt->{'_parser'} || PMLBackend::xml_parser();
  if ($ref_fh){
    eval {
      $ref_data = $parser->parse_fh($ref_fh, $href);
    };
    _die("Error parsing $href $ref_fh $local_file ($@)") if $@;
    $ref_data->setBaseURI($href) if $ref_data and $ref_data->can('setBaseURI');;
    $parser->process_xincludes($ref_data);
    IOBackend::close_backend($ref_fh);
    $ctxt->{'_ref'} ||= {};
    $ctxt->{'_ref'}->{$refid}=$ref_data;
    $ctxt->{'_ref-index'} ||= {};
    $ctxt->{'_ref-index'}->{$refid}=_index_by_id($ref_data);
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

sub lookup_id {
  my ($ctxt,$id)=@_;
  my $hash = $ctxt->{'_id-hash'} ||= {};
  return $hash->{ $id };
}

sub hash_id {
  my ($ctxt,$id,$object) = @_;
  return if $id eq EMPTY; 
  $id = $ctxt->{'_id_prefix'} . $id;
  my $hash = $ctxt->{'_id-hash'} ||= {};
  if (ref($object)) {
    weaken( $hash->{$id} = $object );
  } else {
    $hash->{$id} = $object;
  }
}

# $ctxt, $node, $type, $opts = { childnodes_taker=>..., attrs=>..., first_child=>...}
sub read_node {
  my ($ctxt,$node,$type,$opts) = @_;
  $opts ||= {};

  #$childnodes_taker,$attrs,$first_child

  my $first_child = $opts->{first_child} || $node->firstChild;
  _debug({level => 6},"Reading node "._element_address($node)."\n");
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
    my $list_type = $ctxt->resolve_type($type->{list});

    my $nodelist = $node->getChildrenByTagNameNS(PML_NS,LM);
    my $list = bless
      [
	@$nodelist
	  ? (map {
	      $ctxt->read_node($_,$list_type)
	     } _read_List($node)) 
	  : $ctxt->read_node($node, $list_type,{ attrs => $opts->{attrs} }) 
      ], 'Fslib::List';
    my $role = $type->{list}{role};
    my $childnodes_taker = $opts->{childnodes_taker};
    if ($role eq '#CHILDNODES' and $childnodes_taker) {
      _set_node_children($childnodes_taker, $list) if $list;
      return undef;
    } elsif ($role eq '#TREES' and $childnodes_taker) {
      return $ctxt->set_trees($list, $type,$node);
    } else {
      return $list;
    }
  # ALT ------------------------------------------------------------
  } elsif (exists $type->{alt}) {
    _debug({level => 6},"alt type\n");
    my $alt_type = $ctxt->resolve_type($type->{alt});
    # alt
    my $Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
    if (@$Alt) {
      return bless [
	map {
	  $ctxt->read_node($_,$alt_type)
	} @$Alt,
       ], 'Fslib::Alt';
    } else {
      my $data = $ctxt->read_node($node,$alt_type,{ attrs => $opts->{attrs} });
      return $data;
    }
  # SEQUENCE ------------------------------------------------------------
  } elsif (exists $type->{sequence}) {
    _debug({level => 6},"sequence type\n");
    my $seq = $ctxt->read_Sequence($first_child,$type->{sequence});
    my $role = $type->{sequence}{role};
    my $childnodes_taker = $opts->{childnodes_taker};
    if ($role eq '#CHILDNODES' and $childnodes_taker) {
      if ($seq) {
	_set_node_children($childnodes_taker, $seq);    
      }
      return undef;
    } elsif ($role eq '#TREES') {
      return $ctxt->set_trees($seq,$type,$node);
    } else {
      return $seq;
    }
  # STRUCTURE ------------------------------------------------------------
  } elsif (exists $type->{structure}) {
    _debug({level => 6},"structure type\n");
    # structure
    my $struct = $type->{structure};
    my $members = $struct->{member};
    my $attrs = $opts->{attrs};

    my $hash;
    my $childnodes_taker = $opts->{childnodes_taker};
    if ($type->{role} eq '#NODE' or $struct->{role} eq '#NODE') {
      $hash=FSNode->new();
      $childnodes_taker = $hash;
      $hash->set_type($ctxt->{'_schema'}->type($type->{structure}));
    } else {
      $hash=Fslib::Struct->new();
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
      if ($member ne EMPTY) {
	unless ($member->{as_attribute}) {
	  _warn("Member '$name' not declared as attribute of "._element_address($node));
	}
	$hash->{$name} = $value;
	if ($member->{role} eq '#ID') {
	  $ctxt->hash_id($value,$hash);
	}
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
	  $member = $ctxt->resolve_type($member);
	  $role ||= $member->{role} if ref($member);
	  if (ref($member) and $role eq '#CHILDNODES') {
	    if ($member->{list} or $member->{sequence}) {
	      if (ref $childnodes_taker) {
		my $list = $ctxt->read_node($child,$member);
		_set_node_children($childnodes_taker, $list);
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
	      $hash->{$name} = $ctxt->set_trees($ctxt->read_node($child,$member),$member,$child);
	    } else {
	      _die("#TREES member '$name' is neither a list nor a sequence in "._element_address($node,$child));
	    }
	  } elsif (ref($member) and $role eq '#KNIT') {
	    my $ret = $ctxt->read_node_knit($child,$member);
	    $name =~ s/\.rf$// if $ret->[0];
	    $hash->{$name} = $ret->[1];
	    weaken ( $hash->{$name} ) if ( ref($ret->[1]) and ($ret->[0] & KNIT_WEAKEN) );
		
	  } else {
	    if (ref($member) and ($member->{list} and $member->{list}{role} eq '#KNIT')) {
	      my $list_type = $ctxt->resolve_type($member->{list});
	      my @knit = map {
		$ctxt->read_node_knit($_,$list_type)
	      } _read_List($child);
	      if (grep { !$_->[0] } @knit) {
		# one of the elements didn't knit correctly
		_warn("Knit failed on list "._element_address($child)."\n");
		# read the whole node again as data references
		$hash->{$name} = $ctxt->read_node($child,
						  {
						    # Fake type
						    list => {cdata=>{format=>'PMLREF'}}, 
						    ordered => $member->{list}{ordered}
						  });
	      } else {
		$name =~ s/\.rf$//;
		my $list = $hash->{$name} = Fslib::List->new;
		my $i = 0;
		for my $ret (@knit) {
		  $list->[$i] = $ret->[1];
		  weaken ( $list->[$i] ) if ( ref($ret->[1]) and ($ret->[0] & KNIT_WEAKEN) ) ;
		  $i++;
		}
	      }
	    } else {
	      $hash->{$name} = $ctxt->read_node($child,$member);
	    }
	    if ($role eq '#ID') {
	      $ctxt->hash_id($hash->{$name},$hash);
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
	  my $mtype = $ctxt->resolve_type($member);
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
      $opts->{childnodes_taker} = $hash;
      $hash->set_type($ctxt->{'_schema'}->type($container));
    } else {
      $hash=Fslib::Container->new();
    }
    my $attrs;
    if ($opts->{attrs}) {
       $attrs = $opts->{attrs};
    } else {
      $attrs = $opts->{attrs} = {};
      foreach my $attr ($node->attributes) {
	$attrs->{$attr->nodeName} = $attr->value;
      }
    }
    foreach my $atr_name (keys %$attributes) {
      if (exists($attrs->{$atr_name})) {
	$hash->{$atr_name} = delete $attrs->{$atr_name};
	if ($attributes->{$atr_name}{role} eq '#ID') {
	  $ctxt->hash_id($hash->{$atr_name},$hash);
	}
      } elsif ($attributes->{$atr_name}{required}) {
	_die("Required attribute '$atr_name' missing in container ".
	       _element_address($node));
      }
    }
    # passing options as is (including live reference to $attrs)
    $hash->{'#content'} = $ctxt->read_node($node,$container, $opts);
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
    if ($data ne EMPTY and $data ne $type->{constant}) {
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
    return $ctxt->read_node($node,$ctxt->resolve_type($type),$opts);
  } else {
    _die("Type declaration error: cannot determine data type of ".
	   _element_address($node)."Parsed type declaration:\n".Dumper($type));
  }
  return undef;
}


=item _read_List($node)

If a given DOM node contains a pml:List, return a list of its members,
otherwise return the node itself.

=cut

sub _read_List ($) {
  my ($node)=@_;
  return unless $node;
  my $List = $node->getChildrenByTagNameNS(PML_NS,LM);
  return @$List ? @$List : $node;
}

=item read_Sequence($node)

=cut

# $ctxt, $child, $type, $seq
sub read_Sequence {
  my ($ctxt,$child,$type,$seq)=@_;
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
	    ($ns eq EMPTY or $is_pml or $type->{element}{$name}{ns} eq $ns)) {
	my $value = $ctxt->read_node($child,$ctxt->resolve_type($type->{element}{$name}));
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

=item _read_Alt($node)

If given DOM node contains a pml:Alt, return a list of its members,
otherwise return the node itself.

=cut

sub _read_Alt ($) {
  my ($node)=@_;
  return unless $node;
  my $Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
  return @$Alt ? @$Alt : $node;
}


sub _element_address {
  my ($node,$line_node)=@_;
  $line_node ||= $node;
  return "'".$node->localname."' at ".$line_node->ownerDocument->URI.":".$line_node->line_number."\n";
}

# $ctxt, $data, $type, $node
sub set_trees {
  my ($ctxt,$data,$type,$node)=@_;
  _debug("Found #TREES in "._element_address($node));
  unless (defined $ctxt->{'_pml_trees_type'}) {
    $ctxt->{'_pml_trees_type'}= $type;
    if (UNIVERSAL::isa($data,'Fslib::List')) {
      $ctxt->{'_trees'} = $data;
      _warn("Object with role #TREES contains non-#NODE list members in "._element_address($node))
	if (grep {!UNIVERSAL::isa($_,'FSNode')} @{$ctxt->{'_trees'}});
      return undef; #$ctxt->{'_trees'}
    } elsif (UNIVERSAL::isa($data,'Fslib::Seq')) {
      # in a #TREES sequence, we accept non-node elements, processing
      # the sequence in the following way:
      # - an initial contiguous block of non-node elements is stored
      #   as a pml_prolog
      # - the first contiguous block of node elements is used as the tree list
      #   (and its elements are delegated)
      # - the rest of the sequence is stored as pml_epilog
      my $prolog = $ctxt->{'_pml_prolog'} ||= Fslib::Seq->new;
      my $epilog = $ctxt->{'_pml_epilog'} ||= Fslib::Seq->new;
      my $trees  = $ctxt->{'_trees'} ||= Fslib::List->new;
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
	    $prolog->push_element_obj($element);
	  }
	} else {
	  if ($phase == 1) {
	    $phase = 2; # start epilog
	  }
	  if ($phase == 0) {
	    $prolog->push_element_obj($element);
	  } else {
	    $epilog->push_element_obj($element);
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

sub _set_node_children {
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
  my ($ctxt,$node,$type)=@_;

  my $ref = $node->textContent();
  if ($ref =~ /^(?:(.*?)\#)?(.+)/) {
    my ($reffile,$idref)=($1,$2);
    $ctxt->{'_ref'} ||= {};
    my $data = ($reffile ne EMPTY) ? $ctxt->{'_ref'}->{$reffile} : $node->ownerDocument;
    unless (ref($data)) {
      _warn("Reference to $ref cannot be resolved - document '$reffile' not loaded\n");
      return [0,$ref];
    }
    if ($data->isa('PMLInstance')) {
      # PML
      my $refnode = $data->{'_id-hash'}{$idref};
      if (ref($refnode)) {
	$refnode->{'#knit_prefix'} = $reffile;
	return [ KNIT_OK | KNIT_WEAKEN , $refnode];
      }	else {
	_warn("warning: ID $idref not found in '$reffile'\n");
	return [ KNIT_FAIL, $ref];
      }
    } else {
      # DOM
      $ctxt->{'_ref-index'}||={};
      my $refnode =
	$ctxt->{'_ref-index'}->{$reffile}{$idref} ||
	  $data->getElementsById($idref);
      if (ref($refnode)) {
	my $_id_prefix = $ctxt->{'_id_prefix'};
	$ctxt->{'_id_prefix'} .= $reffile.'#';
	my $ret = $ctxt->read_node($refnode,$type);
	$ctxt->{'_id_prefix'} = $_id_prefix;
	if (ref($ret) and $ret->{id}) {
	  $ret->{id} = $reffile.'#'.$ret->{id};
	}
	return [ KNIT_OK, $ret];
      } else {
	_warn("warning: ID $idref not found in '$reffile'\n");
	return [ KNIT_FAIL, $ref];
      }
    }
  } else {
    return [ KNIT_FAIL, $ref];
  }
}



# return the first child after <head>
sub _skip_head {
  my ($node, $child)=@_;
  $child ||= $node->firstChild;
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


###########################################
# SAVE
###########################################

sub save {
  my ($ctxt,$opts)=@_;

  my $fh = $opts->{fh};

  $ctxt->{'_filename'} = $opts->{filename} if $opts->{filename};
  my $href = $ctxt->{'_filename'};

  $ctxt->{'_trees_written'} = 0;
  unless ($fh) {
    if ($href ne EMPTY) {
      eval {
	IOBackend::rename_uri($href,$href."~") unless $href=~/^ntred:/;
      };
      my $ok = 0;
      my $res;
      eval {
	$fh = PMLBackend::open_backend($href,'w');
	if ($fh) {
	  binmode $fh;
	  $res = $ctxt->save({%$opts, fh=> $fh});
	  PMLBackend::close_backend($fh);
	  $ok = 1;
	}
      };
      unless ($ok) {
	my $err = $@;
	eval {
	  IOBackend::rename_uri($href."~",$href) unless $href=~/^ntred:/;
	};
	_die($err."$@\n") if $err;
      }
      return $res;
    } else {
      _die("Usage: $ctxt->save({filename=>...,[fh => ...]})");
    }
  }

  $ctxt->{'_write_single_LM'} = $opts->{'write_single_LM'};
  $ctxt->{'_refs_save'} ||= $opts->{'refs_save'};
  _debug("Saving PML instance '$href'\n");
  binmode $fh if $fh;
  my $transform_id = $ctxt->{'_transform_id'};
  my $config = $opts->{config};
  if ($config and $transform_id ne EMPTY) {
    my $transform = $config->lookup_id( $transform_id );
    if ($transform) {
      my ($out_xsl) = $transform->{'out'};
      if ($out_xsl->{type} eq 'identity') {
	_debug("Identity transformation from PML");
	binmode $fh,":utf8";
	$ctxt->{'_writer'} = new XML::Writer(OUTPUT => $fh,
					  DATA_MODE => 1,
					  DATA_INDENT => 1);
	$ctxt->write_data();
	return 1;
      } elsif ($out_xsl->{'type'} ne 'xslt') {
	_die("PMLBackend: unsupported output transformation $transform_id (only type='xslt') transformations are supported)"); 
      }
      my $out_xsl_href = $out_xsl ? $out_xsl->{'href'} : undef;
      $out_xsl_href = Fslib::ResolvePath($PMLBackend::config->{filename}, $out_xsl_href, 1);
      if ($out_xsl_href eq EMPTY) {
	_die("PMLBackend: no output transformation defined for $transform_id");
      }
      $ctxt->{'_writer'} = XML::MyDOMWriter->new(DOM => XML::LibXML::Document->new);
      $ctxt->write_data();
      my $dom = $ctxt->{'_writer'}->end;
      my $xslt = XML::LibXSLT->new;
      my $params = $out_xsl->content;
      my %params = map { $_->{'name'} => $_->textContent 
		       } $params->values if $params;
      _debug("Transforming from PML with XSLT '$out_xsl_href'");
      my $out_xsl_parsed = $xslt->parse_stylesheet_file($out_xsl_href);
      my $result = $out_xsl_parsed->transform($dom,%params);
      if (UNIVERSAL::can($result,'toFH')) {
	$result->toFH($fh,1);
      } else {
	$out_xsl_parsed->output_fh($result,$fh);
      }
      return 1;
    } else {
      _die("PMLBackend: Couldn't find PML transform with ID $transform_id");
    }
  } else {
    binmode $fh,":utf8";
    $ctxt->{'_writer'} = new XML::Writer(OUTPUT => $fh,
				      DATA_MODE => 1,
				      DATA_INDENT => 1);
    $ctxt->write_data();
  }
  return 1;
}


sub write_data {
  my $ctxt = shift;

  my $schema = $ctxt->{'_schema'};
  unless (ref($schema)) {
    _die("Can't write - document isn't associated with a schema");
  }

  $ctxt->{'_types'} ||= $schema->{type};
  my $root_name = $schema->{root}{name};
  my $root_type = $ctxt->resolve_type($schema->{root});

  # dump embedded DOM documents
  my $refs_to_save = $ctxt->{'_refs_save'};
  my @refs_to_save = grep { $_->{readas} eq 'dom' or $_->{readas} eq 'pml' } $ctxt->get_references();
  if (ref($refs_to_save)) {
    @refs_to_save = grep { $refs_to_save->{$_->{id}} } @refs_to_save;
  } else {
    $refs_to_save = {};
  }

  my $references = $ctxt->{'_references'};

  # update all DOM trees to be saved
  $ctxt->{'_parser'} ||= PMLBackend::xml_parser();
  foreach my $ref (@refs_to_save) {
    if ($ref->{readas} eq 'dom') {
      $ctxt->readas_dom($ref->{id},$ref->{href});
    }
    # NOTE:
    # if ($refs_to_save->{$ref->{id}} ne $ref->{href}),
    # then the ref-file is going to be renamed.
    # Although we don't parse it as PML, it can be a PML file.
    # If it is, we might try to update it's references too,
    # but the snag here is, that we don't know if the
    # resources it references aren't moved along with it by
    # other means (e.g. by user making the copy).
  }

  my $xml = $ctxt->{'_writer'};
  $xml->xmlDecl("utf-8");

  # we need to collect structure/container attributes first
  my %attribs;
  if (exists $root_type->{structure}) {
    my $struct = $root_type->{structure};
    my $members = $struct->{member};
    my $object = $ctxt->{'_root'};
    if (ref($object)) {
      foreach my $mdecl (grep {$_->{as_attribute}} values %$members) {
	my $atr = $mdecl->{-name};
	if ($mdecl->{required} or $object->{$atr} ne EMPTY) {
	  $attribs{$atr} = $object->{$atr};
	}
      }
    }
  } elsif (exists $root_type->{container}) {
    my $container = $root_type->{container};
    my $object = $ctxt->{'_root'};
    if (ref($object)) {
      foreach my $attrib (values(%{$container->{attribute}})) {
	my $atr = $attrib->{-name};
	if ($attrib->{required} or  $object->{$atr} ne EMPTY) {
	  $attribs{$atr} = $object->{$atr}
	}
      }
    }
  }

  $xml->startTag($root_name,'xmlns' => PML_NS, %attribs);
  $xml->startTag('head');
  my $inline = $ctxt->{'_schema-inline'};
  if ($inline ne "") {
    $xml->startTag('schema');
    _element2writer($xml,$ctxt->{'_parser'}->parse_string($inline,$ctxt->{'_filename'})->documentElement);
    $xml->endTag('schema');
  } else {
    $xml->emptyTag('schema', href => $ctxt->{'_schema-url'});
  }
  {
    if (ref($references) and keys(%$references)) {
      my $named = $ctxt->{'_refnames'};
      my %names = $named ? (map { $named->{$_} => $_ } keys %$named) : ();
      $xml->startTag('references');
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
	  if (File::Spec->file_name_is_absolute($href)) {
	    my ($vol,$dir) = File::Spec->splitpath(File::Spec->rel2abs($ctxt->{'_filename'}));
	    $href = File::Spec->abs2rel($href,File::Spec->catfile($vol,$dir));
	  }
	}
	$xml->emptyTag('reffile',
		       id => $id,
		       href => $href,
		       (exists($names{$id}) ? (name => $names{$id}) : ()));
      }
      $xml->endTag('references');
    }
  }
  $xml->endTag('head');

  $ctxt->write_object($ctxt->{'_root'},$root_type, {no_attribs => 1});
  $xml->endTag($root_name);
  $xml->end;

  # dump DOM trees to save
  if (ref($ctxt->{'_ref'})) {
    foreach my $ref (@refs_to_save) {
      if ($ref->{readas} eq 'dom') {
	my $dom = $ctxt->{'_ref'}->{$ref->{id}};
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
      } elsif ($ref->{readas} eq 'pml') {
	my $pml = $ctxt->{'_ref'}->{$ref->{id}};
	my $href;
	if (exists($refs_to_save->{$ref->{id}})) {
	  $href = $refs_to_save->{$ref->{id}};
	} else {
	  $href = $ref->{href}
	}
	$pml->save({ filename => $href });
      }
    }
  }
  1;
}

sub write_object {
  my ($ctxt,$object,$type,$opts)=@_;
  $opts ||= {};
  my $tag = $opts->{tag};
  my $attribs = $opts->{attribs} || {};
  
  my $xml = $ctxt->{'_writer'};
  my $pre=$type;

  unless ($opts->{no_resolve}) {
    $type = $ctxt->resolve_type($type)
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
      if ($opts->{no_attribs}) {
	$xml->startTag($tag) if defined($tag);
      } else {
	foreach my $mdecl (grep {$_->{as_attribute}} values %$members) {
	  my $atr = $mdecl->{-name};
	  if ($mdecl->{required} or $object->{$atr} ne EMPTY) {
	    $attribs->{$atr} = $object->{$atr};
	  }
	}
	if (%$attribs and !defined($tag)) {
	  _die("Can't write structure with attributes (".join("\,",keys %$attribs).") without a tag");
	}
	$xml->startTag($tag,%$attribs) if defined($tag);
      }
      foreach my $mdecl (
	grep {!$_->{as_attribute}} 
	  sort { $a->{'-#'} <=> $b->{'-#'} }
	  values %$members) {
	my $member = $mdecl->{-name};
	my $mtype = $ctxt->resolve_type($mdecl);
	if ($mdecl->{role} eq '#CHILDNODES') {
	  if (ref($object) eq 'FSNode') {
	    if ($object->firstson or $mdecl->{required}) {
	      my $children;
	      if (ref($mtype->{sequence})) {
		if ($object->{$member} ne EMPTY) {
		  _warn("Replacing non-empty value of member '$member' with the #CHILDNODES sequence!");
		}
		$children = Fslib::Seq->new( [map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
	      } elsif (ref($mtype->{list})) {
		if ($object->{$member} ne EMPTY) {
		  _warn("Replacing non-empty value of member '$member' with the #CHILDNODES list!");
		}
		$children = Fslib::List->new_from_ref([$object->children],1);
	      } else {
		_warn("The member '$member' with the role #CHILDNODES is neither a list nor a sequence - ignoring it!");
	      }
	      $ctxt->write_object($children, $mdecl,{ tag => $member });
	    }
	  } else {
	    _warn("Found #CHILDNODES member '$member' on a non-node value: $object\n");
	  }
	} elsif ($mdecl->{role} eq '#TREES') {
	  my $data = $ctxt->get_write_trees($mdecl,$mtype);
	  $ctxt->write_object($data,$mdecl,{ tag => $member });
	} elsif ($mdecl->{role} eq '#KNIT') {
	  if ($object->{$member} ne EMPTY) {
	    # un-knit data
	    # _debug("#KNIT.rf $member");
	    $xml->startTag($member);
	    $xml->characters($object->{$member});
	    $xml->endTag($member);
	  } else {
	    # knit data
	    my $knit_tag = $member;
	    $knit_tag =~ s/\.rf$//;
	    if (ref($object->{$knit_tag})) {
	      $ctxt->write_object_knit($object->{$knit_tag}, $mdecl,{ tag => $member, knit_tag => $knit_tag });
	    }# else {
	    #	_warn("Didn't find $knit_tag on the object! ",join(" ",%$object),"\n");
	    #      }
	  }
	} elsif (ref($mtype) and $mtype->{list} and $mtype->{list}{role} eq '#KNIT') {
	  if ($object->{$member} ne EMPTY) {
	    # un-knit list
	    my $list = $object->{$member};
	    # _debug("#KNIT.rf $member @$list");
	    if (ref($list) eq 'Fslib::List') {
	      if (@$list == 0) {
	      } elsif (!$ctxt->{'_write_single_LM'} and @$list == 1) {
		$ctxt->write_object($list->[0],$mtype->{list},{tag =>$member, no_resolve=>1});
	      } else {
		$xml->startTag($member);
		foreach my $value (@$list) {
		  $ctxt->write_object($value,$mtype->{list},{tag => LM, 'no_resolve' => 1});
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
	      } elsif (!$ctxt->{'_write_single_LM'} and @$list == 1) {
		$ctxt->write_object_knit($list->[0],$mtype->{list},{ tag=> $member, knit_tag => $knit_tag});
	      } else {
		$xml->startTag($member);
		foreach my $knit_value (@$list) {
		  $ctxt->write_object_knit($knit_value,$mtype->{list},{ tag=> LM, knit_tag => $knit_tag });
		}
		$xml->endTag($member);
	      }
	    } elsif ($list ne EMPTY) {
	      _warn("Unexpected content of knit List '$knit_tag': $list\n");
	    }
	  }
	} elsif ($object->{$member} ne EMPTY or $mdecl->{required}) {
	  $ctxt->write_object($object->{$member},$mdecl,{tag => $member});
	}
      }
      $xml->endTag($tag) if defined($tag);
    }
  } elsif (exists $type->{list}) {
    my $list_type = $type->{list};
    if (ref($list_type) and $list_type->{role} eq '#TREES') {
      $object = $ctxt->get_write_trees($object,$type);
    }
    if (ref($object) eq 'Fslib::List') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	$ctxt->write_object($object->[0],$list_type,{ tag => $tag });
      } else {
	$xml->startTag($tag,%$attribs) if defined($tag);
	foreach my $value (@$object) {
	  $ctxt->write_object($value,$list_type,{ tag => LM });
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Unexpected content of List '$what': $object\n");
    }
  } elsif (exists $type->{alt}) {
    if ($object ne EMPTY and ref($object) eq 'Fslib::Alt') {
      if (@$object == 0) {
	# what do we do now?
      } elsif (@$object == 1) {
	$ctxt->write_object($object->[0],$type->{alt},{tag => $tag});
      } else {
	$xml->startTag($tag,%$attribs) if defined($tag);
	foreach my $value (@$object) {
	  $ctxt->write_object($value,$type->{alt},{tag => AM});
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      $ctxt->write_object($object,$type->{alt},{tag => $tag});
    }
  } elsif (exists $type->{sequence}) {
    my $sequence = $type->{sequence};
    $xml->startTag($tag,%$attribs) if defined($tag);
    if ($sequence->{role} eq '#TREES') {
      $object = $ctxt->get_write_trees($object,$type);
    }
    if (UNIVERSAL::isa($object,'Fslib::Seq')) {
      if (exists $sequence->{content_pattern}) {
	unless ($object->validate($sequence->{content_pattern})) {
	  _warn("Sequence '$tag' (".join(",",$object->names).") does not follow the pattern ".$sequence->{content_pattern});
	}
      }
      foreach my $element (@{$object->elements_list}) {
	my $name = $element->[0];
	my $value = $element->[1];
	if ($name eq '#TEXT') {
	  unless ($type->{sequence}{text}) {
	    my $what = $tag || $type->{name} || $type->{'-name'};
	    _warn("Text not allowed in the sequence '$what', writing it anyway\n");
	  }
	  $xml->characters($value);
	} elsif ($name ne EMPTY) {
	  my $eltype = $sequence->{element}{$name};
	  
	  if ($eltype) {
	    $ctxt->write_object($value,$eltype,{tag => $name});
	  } else {
	    my $what = $tag || $type->{name} || $type->{'-name'};
	    _warn("Element '".$name."' not allowed in the sequence '$what', skipping\n");
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
    unless ($opts->{no_attribs}) {
      foreach my $attrib (values(%{$container->{attribute}})) {
	my $atr = $attrib->{-name};
	if ($attrib->{required} or  $object->{$atr} ne EMPTY) {
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
      $content = $ctxt->get_childnodes($object,$container,$content,$what);
    }
    $ctxt->write_object($content,$container,{ tag => $tag, attribs => {%$attribs,%attribs}});
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


# $ctxt, $object, $type, { tag=> $tag, attribs => {}, $knit_tag => }
sub write_object_knit {
  my ($ctxt,$object,$type,$opts)=@_;

  my $tag = $opts->{tag};
  my $attribs = $opts->{attribs} || {};  
  my $xml = $ctxt->{'_writer'};

  my $prefix=EMPTY;
  my $ref = $object->{id};
  if (ref($object) and $ref !~ /#/) {
    $prefix = $object->{'#knit_prefix'};
  } elsif ($ref =~ /^(?:(.*?)\#)?(.+)/) {
    $ref = $2;
    $prefix = $1;
  }

  $xml->startTag($tag,$attribs?%$attribs:());
  $xml->characters($prefix ne EMPTY ? $prefix.'#'.$ref : $ref);
  $xml->endTag($tag);

  if ($prefix ne EMPTY) {
    return if (UNIVERSAL::isa($ctxt->{'_ref'}{$prefix},'PMLInstance'));
    my $indeces = $ctxt->{'_ref-index'};
    if ($indeces and $indeces->{$prefix}) {
      my $knit = $indeces->{$prefix}{$ref};
      if ($knit) {
	my $dom_writer = XML::MyDOMWriter->new(REPLACE => $knit);
	{
	  my $writer = $ctxt->{'_writer'};
	  $ctxt->{'_writer'} = $dom_writer;
	  eval {
	    $ctxt->write_object($object, $ctxt->resolve_type($type), { tag => $opts->{knit_tag} });
	  };
	  $ctxt->{'_writer'} = $writer;
	  die $@."\n" if $@;
	}
	my $new = $dom_writer->end;
	$new->setAttribute('id',$ref);
      } else {
	_warn("Didn't find ID $ref in $prefix - can't knit back!\n");
      }
    } else {
      _warn("Knit-file $prefix has no index - can't knit back!\n");
    }
  } else {
    _warn("Can't parse '$tag' href '$ref' - can't knit back!\n");
  }
}

# $ctxt, $data, $type
sub get_write_trees {
  my ($ctxt, $data, $type)=@_;
  if ($ctxt->{'_trees_written'}) {
    return $data
  } else {
    my $trees_type = $ctxt->{'_pml_trees_type'} || $type;
    if (ref($trees_type)) {
      if ($trees_type->{sequence}) {
	my $prolog = $ctxt->{'_pml_prolog'};
	my $epilog = $ctxt->{'_pml_epilog'};
	return Fslib::Seq->new(
	  [(UNIVERSAL::isa($prolog,'Fslib::Seq') ? $prolog->elements : ()),
	   (map { Fslib::Seq::Element->new($_->{'#name'},$_) } @{$ctxt->{'_trees'}}),
	   (UNIVERSAL::isa($epilog,'Fslib::Seq') ? $epilog->elements : ())]
	 );
      } elsif ($trees_type->{list}) {
	return $ctxt->{'_trees'};
      } else {
	_warn("#TREES are neither a list nor a sequence - can't save trees.\n");
      }
    } else {
      _warn("Can't determine #TREES type - can't save trees.\n");
    }
    $ctxt->{'_trees_written'} = 1;
  }
}

sub get_childnodes {
  my ($ctxt,$object,$cont_type,$content,$what)=@_;
  $cont_type = $ctxt->resolve_type($cont_type);

  return $content unless ref($cont_type);
  
  if (ref($cont_type->{sequence}) and 
	$cont_type->{sequence}{role} eq '#CHILDNODES') {
    if ($content ne EMPTY) {
      _warn("Replacing non-empty value '$content' of '$what' with the #CHILDNODES sequence!");
    }
    return Fslib::Seq->new([map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
  } elsif (ref($cont_type->{list}) and 
	     $cont_type->{list}{role} eq '#CHILDNODES') {
    if ($content ne EMPTY) {
      _warn("Replacing non-empty value '$content' of '$what' with the #CHILDNODES list!");
    }
    return Fslib::List->new_from_ref([$object->children],1);
  }
  return $content;
}

sub _element2writer {
  my ($xml,$element,@attributes) = @_;
  push @attributes, map { $_->nodeName => $_->value } $element->attributes;
  if ($element->hasChildNodes) {
    $xml->startTag($element->nodeName, @attributes );
    my $child = $element->firstChild;
    while ($child) {
      my $type = $child->nodeType;
      if ($type == ELEMENT_NODE) {
	_element2writer($xml,$child);
      } elsif ($type == TEXT_NODE) {
	my $data = $child->data;
	$xml->characters($data) if $data=~/\S/;
      } elsif ($type == CDATA_SECTION_NODE) {
	$xml->cdata($child->data);
      } elsif ($type == PI_NODE) {
	$xml->pi($child->nodeName, $child->data);
      } elsif ($type == COMMENT_NODE) {
	$xml->comment($child->data);
	
      }
    } continue {
      $child = $child->nextSibling;
    };
    $xml->endTag($element->nodeName);
  } else {
    $xml->emptyTag($element->nodeName, @attributes );
  }
}

##########################################
# VALIDATE
#########################################

# Usage:
# $ctxt->validate_object($object, $type, { path => $path, tag => $tag })
# $ctxt only requires the field $ctxt->{'_schema'} (or $ctxt->{'_types'})
# log is in $ctxt->{'_log'}

sub validate_object ($$$;$) {
  my ($ctxt, $object, $type, $opts)=@_;
  my $pre=$type;

  my ($path,$tag);
  if (ref($opts)) {
    $path = $opts->{path};
    $tag = $opts->{tag};
    $path.="/".$tag if $tag ne EMPTY;
  }

  _debug("validate_object: $path, $object, $type");
  $type = $ctxt->resolve_type($type);
  unless (ref($type)) {
    $ctxt->_log("$path: Invalid type: $type");
  }
  if ($type->{cdata}) {
    if (ref($object)) {
      $ctxt->_log("$path: expected CDATA, got: ",ref($object));
    } elsif ($type->{cdata}{format} eq 'nonNegativeInteger') {
      $ctxt->_log("$path: CDATA value is not formatted as nonNegativeInteger: '$object'")
	unless $object=~/^\s*\d+\s*$/;
    } # TODO - check validity of other formats
  } elsif (exists $type->{constant}) {
    if ($object ne $type->{constant}) {
      $ctxt->_log("$path: invalid constant, should be '$type->{constant}', got: ",$object);
    }
  } elsif (exists $type->{choice}) {
    my $ok;
    foreach (@{$type->{choice}}) {
      if ($_ eq $object) {
	$ok = 1;
	last;
      }
    }
    $ctxt->_log("$path: Invalid value: '$object'") unless ($ok);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (!ref($object)) {
      $ctxt->_log("$path: Unexpected content of a structure $struct->{name}: '$object'");
    } elsif (keys(%$object)) {
      foreach my $atr (grep {$members->{$_}{as_attribute}} keys %$members) {
	if ($members->{$atr}{required} or $object->{$atr} ne EMPTY) {
	  if (ref($object->{$atr})) {
	    $ctxt->_log("$path/$atr: invalid content for member declared as attribute: ".ref($object->{$atr}));
	  }
	}
      }
      foreach my $member (grep {!$members->{$_}{as_attribute}}
			  keys %$members) {
	my $mtype = $ctxt->resolve_type($members->{$member});
	if ($members->{$member}{role} eq '#CHILDNODES') {
	  if (ref($object) ne 'FSNode') {
	    $ctxt->_log("$path/$member: #CHILDNODES member with a non-node value:\n".Dumper($object));
	  }
	} elsif ($members->{$member}{role} eq '#KNIT') {
	  my $knit_tag = $member;
	  $knit_tag =~ s/\.rf$//;
	  if ($object->{$member} ne EMPTY) {
	    if (ref($object->{$member})) {
	      $ctxt->_log("$path/$member: invalid content for member with role #KNIT: ",ref($object->{$member}));
	    }
	    if (ref($object->{$knit_tag}) or $object->{$knit_tag} ne EMPTY) {
	      $ctxt->_log("$path/$knit_tag: both '$member' and '$knit_tag' are present for a #KNIT member");
	    }
	  } else {
	    if (ref($object->{$knit_tag})) {
	      $ctxt->validate_object_knit($object->{$knit_tag},$members->{$member},
					  { path => $path , tag => $member, tag => $knit_tag });
	    } elsif ($object->{$knit_tag} ne EMPTY) {
	      $ctxt->_log("$path/$knit_tag: invalid value for a #KNIT member: '$object->{$knit_tag}'");
	    }
	  }
	} elsif (ref($mtype) and $mtype->{list} and
		 $mtype->{list}{role} eq '#KNIT') {
	  # KNIT list
	  my $knit_tag = $member;
	  $knit_tag =~ s/\.rf$//;
	  if ($object->{$member} ne EMPTY and
	      $object->{$knit_tag} ne EMPTY) {
	    $ctxt->_log("$path/$knit_tag: both '$member' and '$knit_tag' are present for a #KNIT member");
	  } elsif ($object->{$member} ne EMPTY) {
	    _debug("validating as $member not $knit_tag");
	    $ctxt->validate_object($object->{$member},$members->{$member},
				   { path => $path, type => $member } );
	  } else {
	    my $list = $object->{$knit_tag};
	    if (ref($list) eq 'Fslib::List') {
	      for (my $i=1; $i<=@$list;$i++) {
		$ctxt->validate_object_knit($list->[$i-1], $mtype->{list}, 
					    { path => $path."/$knit_tag", tag => "[$i]" });
	      }
	    } elsif ($list ne EMPTY) {
	      $ctxt->_log("$path/$knit_tag: not a list: ",ref($object->{$knit_tag}));
	    }
	  }
	} elsif ($object->{$member} ne EMPTY or $members->{$member}{required}) {
	  $ctxt->validate_object($object->{$member}, $members->{$member}, 
				 { path => $path, tag => $member } );
	}
      }
    } else {
      $ctxt->_log("$path: structure is empty");
    }
  } elsif (exists $type->{list}) {
    if (ref($object) eq 'Fslib::List') {
      for (my $i=1; $i<=@$object; $i++) {
	$ctxt->validate_object($object->[$i-1],$type->{list},{ path=> $path, tag => "[$i]"});
      }
    } else {
      $ctxt->_log("$path: unexpected content of a list: $object\n");
    }
  } elsif (exists $type->{alt}) {
    if ($object ne EMPTY and ref($object) eq 'Fslib::Alt') {
      for (my $i=1; $i<=@$object; $i++) {
	$ctxt->validate_object($object->[$i-1],$type->{alt},{ path => $path, $tag => "[$i]"});
      }
    } else {
      $ctxt->validate_object($object,$type->{alt},{path=>$path});
    }
  } elsif (exists $type->{container}) {
    if (not UNIVERSAL::isa($object,'HASH')) {
      $ctxt->_log("$path: unexpected container (should be a HASH): $object");
    } else {
      my $container = $type->{container};
      my $attributes = $container->{attribute};
      foreach my $atr (keys %$attributes) {
	if ($attributes->{$atr}{required} or $object->{$atr} ne EMPTY) {
	  if (ref($object->{$atr})) {
	    $ctxt->_log("$path/$atr: invalid content for attribute: ".ref($object->{$atr}));
	  } else {
	    $ctxt->validate_object($object->{$atr}, $attributes->{$atr}, { path => $path, tag=>$atr });
	  }
	}
      }
      my $content = $object->{'#content'};
      if ($container->{role} eq '#NODE') {
	if (!UNIVERSAL::isa($object,'FSNode')) {
	  $ctxt->_log("$path: container declared as #NODE should be a FSNode object: $object");
	} else {
	  my $cont_type = $ctxt->resolve_type($container);
	  if (ref($cont_type) and ref($cont_type->{sequence}) and $cont_type->{sequence}{role} eq '#CHILDNODES') {
	    if ($content ne EMPTY) {
	      $ctxt->_log("$path: #NODE container containing a #CHILDNODES should have empty #content: $content");
	    }
	    $content = Fslib::Seq->new([map { Fslib::Seq::Element->new($_->{'#name'},$_) } $object->children]);
	  }
	}
      }
      $ctxt->validate_object($content,$container,{ path => $path, tag => '#content' });
    }
  } elsif (exists $type->{sequence}) {
    if (UNIVERSAL::isa($object,'Fslib::Seq')) {
      my $sequence=$type->{sequence};
      foreach my $element ($object->elements) {
	if (!(UNIVERSAL::isa($element,'ARRAY') and @$element==2)) {
	  $ctxt->_log("$path: invalid sequence content: ",ref($element));
	} elsif ($element->[0] eq '#TEXT') {
	  if ($sequence->{text}) {
	    if (ref($element->[1])) {
	      $ctxt->_log("$path: expected CDATA, got: ",ref($element->[1]));
	    }
	  } else {
	    $ctxt->_log("$path: text node not allowed here\n");
	  }
	} else {
	  my $eltype = $sequence->{element}{$element->[0]};
	  if ($eltype) {
	    $ctxt->validate_object($element->[1],$eltype,{ path => $path, tag => $element->[0] });
	  } else {
	    $ctxt->_log("$path: undefined element '$element->[0]'",Dumper($type));
	  }
	}
      }
      if ($sequence->{content_pattern} and !$object->validate($sequence->{content_pattern})) {
	$ctxt->_log("$path: sequence content (".join(",",$object->names).") does not follow the pattern ".$sequence->{content_pattern});
      }
    } else {
      $ctxt->_log("$path: unexpected content of a sequence: $object\n");
      $ctxt->_log(Dumper($type));
    }
  } else {
    $ctxt->_log("$path: unknown type: ".Dumper($type));
  }
  return (ref($ctxt->{'_log'}) and @{ $ctxt->{'_log'} }>0) ? 0 : 1;
}

# $ctxt $path $object $type { $tag $knit_tag }
sub validate_object_knit {
  my ($ctxt, $object, $type, $opts) = @_;

  my $ref = $object->{id};
  _debug("validate_knit_object: $opts->{path}/$opts->{tag}, $object");
  if ($object->{id} eq EMPTY or ref($object->{id})) {
    $ctxt->_log("$opts->{path}/$opts->{tag}/id: invalid ID: $object->{id}\n");
  }
  if ($ref =~ /^.+#.|^[^#]+$/) {
    $ctxt->validate_object($object, $ctxt->resolve_type($type), $opts);
  } else {
    $ctxt->_log("$opts->{path}/$opts->{tag}/id: invalid PMLREF '$ref'");
  }
}

sub convert_to_fsfile {
  my ($ctxt,$fsfile)=@_;

  my $schema = $ctxt->{'_schema'};

  unless (ref($fsfile)) {
    $fsfile = FSFile->create({ backend => 'PMLBackend' } );
  }

  $fsfile->changeFilename( $ctxt->{'_filename'} );
  $fsfile->changeEncoding($PMLBackend::encoding);
  $fsfile->changeTail("(1)\n");
  $fsfile->changePatterns(@PMLBackend::pmlformat);
  $fsfile->changeHint($PMLBackend::pmlhint);


  $fsfile->changeMetaData( 'schema',         $schema                    );
  $fsfile->changeMetaData( 'schema-url',     $ctxt->{'_schema-url'}      );
  $fsfile->changeMetaData( 'schema-inline',  $ctxt->{'_schema-inline'}   );
  $fsfile->changeMetaData( 'pml_transform',  $ctxt->{'_transform_id'}    );
  $fsfile->changeMetaData( 'references',     $ctxt->{'_references'}      );
  $fsfile->changeMetaData( 'refnames',       $ctxt->{'_refnames'}        );
  $fsfile->changeMetaData( 'fs-require',     $ctxt->{'_readas-trees'}    );

  $fsfile->changeAppData(  'ref',            $ctxt->{'_ref'} || {}         );
#  $fsfile->changeAppData(  'ref-index',      $ctxt->{'_ref-index'} || {} );
  $fsfile->changeAppData(  'id-hash',        $ctxt->{'_id-hash'}         );

  $fsfile->changeMetaData( 'pml_root',       $ctxt->{'_root'}            );
  $fsfile->changeMetaData( 'pml_trees_type', $ctxt->{'_pml_trees_type'}  );
  $fsfile->changeMetaData( 'pml_prolog',     $ctxt->{'_pml_prolog'}        );
  $fsfile->changeMetaData( 'pml_epilog',     $ctxt->{'_pml_epilog'}        );

  $fsfile->changeTrees( @{$ctxt->{'_trees'}} ) if $ctxt->{'_trees'};

  my @nodes = $ctxt->{'_schema'}->find_role('#NODE');
  my ($order,$hide);
  for my $path (@nodes) {
    my $decl = $schema->find_type_by_path($path,1);
    $order ||= $schema->find_role('#ORDER', $decl );
    $hide  ||= $schema->find_role('#HIDE', $decl );
    last if $order ne EMPTY and $hide ne EMPTY;
  }
  
  my $defs = $fsfile->FS->defs;
  $defs->{$order} = ' N' if $order ne EMPTY; 
  $defs->{$hide}  = ' H' if $hide  ne EMPTY;

  return $fsfile;
}

sub convert_from_fsfile {
  my ($ctxt,$fsfile)=@_;

  unless (ref($ctxt)) {
    $ctxt = __PACKAGE__->new();
  }

  $ctxt->{'_transform_id'}   = $fsfile->metaData('pml_transform');
  $ctxt->{'_filename'}       = $fsfile->filename;
  $ctxt->{'_schema'}         = $fsfile->metaData('schema');
  $ctxt->{'_root'}           = $fsfile->metaData('pml_root');
  $ctxt->{'_schema-inline'}  = $fsfile->metaData('schema-inline');
  $ctxt->{'_schema-url'}     = $fsfile->metaData('schema-url');
  $ctxt->{'_references'}     = $fsfile->metaData('references');
  $ctxt->{'_refnames'}       = $fsfile->metaData('refnames');
  $ctxt->{'_pml_trees_type'} = $fsfile->metaData('pml_trees_type');
  $ctxt->{'_pml_prolog'}     = $fsfile->metaData('pml_prolog');
  $ctxt->{'_pml_epilog'}     = $fsfile->metaData('pml_epilog');
  $ctxt->{'_trees'}          = Fslib::List->new_from_ref( $fsfile->treeList );

  $ctxt->{'_refs_save'}      = $fsfile->appData('refs_save');

  $ctxt->{'_ref'}            = $fsfile->appData('ref');
#  $ctxt->{'_ref-index'}      = $fsfile->appData('ref-index');
  $ctxt->{'_id-hash'}        = $fsfile->appData('id-hash');

  return $ctxt;
}

########################################################################
# XML::MyDOMWriter
#
# Auxiliary package
#
# (same basic API as XML::Writer but builds a DOM instead of writing a
# XML file)
#
########################################################################

{

  package XML::MyDOMWriter;
  use constant {
    EMPTY => q(),
  };
  *_die = \&PMLBackend::_die;
  sub new {
    my ($class,%args)=@_;
    $class = ref($class) || $class;

    unless ($args{DOM} || $args{ELEMENT} || $args{REPLACE} ) {
      _die("Usage: ".__PACKAGE__."->new(ELEMENT => XML::LibXML::Document)");
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
  sub xmlDecl {
    my ($self,$enc,$standalone)=@_;
    $self->{DOM}->setEncoding($enc) if defined $enc;
    $self->{DOM}->setStandalone($standalone) if defined $standalone;
  }

  sub startTag {
    my ($self,$name,@attrs)=@_;
    if ($self->{ELEMENT}) {
      $self->{ELEMENT} = $self->{ELEMENT}->addNewChild(undef,$name);
    } elsif ($self->{REPLACE}) {
      $self->{ELEMENT} = $self->{DOM}->createElement($name);
      $self->{REPLACE}->replaceNode($self->{ELEMENT});
      $self->{REPLACEMENT} = $self->{ELEMENT};
      delete $self->{REPLACE};
    } else {
      $self->{ELEMENT} = $self->{DOM}->createElement($name);
      $self->{DOM}->setDocumentElement($self->{ELEMENT});
    }
    for (my $i=0; $i<@attrs; $i+=2) {
      my $atr = $attrs[$i];
      if ($atr=~/^xmlns(?:[:](.*))?/) {
	$self->{ELEMENT}->setNamespace($attrs[$i+1],$1,0);
      } else {
	$self->{ELEMENT}->setAttribute( $attrs[$i] => $attrs[$i+1] );
      }
    }
    my $prefix = ($name =~ m/^([^:]+):/) ? $1 : undef;
    my $uri = $self->{ELEMENT}->lookupNamespaceURI( $prefix );
    if ($uri ne EMPTY) {
      $self->{ELEMENT}->setNamespace($uri,$prefix,1);
    }
    1;
  }
  sub emptyTag {
    my $self = shift;
    my $name = shift;
    $self->startTag($name,@_);
    $self->endTag();
  }
  sub endTag {
    my ($self,$name)=@_;
    if ($name ne EMPTY) {
      if ($self->{ELEMENT} and $self->{ELEMENT}->nodeName eq $name) {
	$self->{ELEMENT} = $self->{ELEMENT}->parentNode;
      } else {
	_die ("Can't end ".
	  ($self->{ELEMENT} ? '<'.$self->{ELEMENT}->localName.'>' : 'none').
	    " with </$name>");
      }
    } else {
      $self->{ELEMENT} = $self->{ELEMENT}->parentNode if $self->{ELEMENT};
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
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

PMLInstance - Perl extension for loading/saving PML data

=head1 SYNOPSIS

   use PMLInstance;

   Fslib::AddToResourcePaths( "$ENV{HOME}/my_pml_schemas" );

   my $pml = PMLInstance->load({ filename => 'foo.xml' });

   my $schema = $pml->get_schema;
   my $data   = $pml->get_root;

   $pml->save();

=head1 DESCRIPTION

blah blah blah

TODO

blah blah blah

=head2 EXPORT

None by default.

The following export tags are available:

=over 4

=item import PMLInstance qw(:constants);

Imports the following constants:

=over 8

=item LM - name of the "<LM>" (list-member) tag

=item AM - name of the "<LM>" (alt-member) tag

=item PML_NS - XML namespace URI for PML instances

=item PML_SCHEMA_NS - XML namespace URI for PML schemas

=item SUPPORTED_PML_VERSIONS - space-separated list of supported PML-schema version numbers

=back

=item import PMLInstance qw(:diagnostics);

Imports internal _die, _warn, and _debug diagnostics commands.

=back

=item PMLInstance->new()

Create a new empty PML instance object.

=item PMLInstance->load( \%opts )

Load PML instance from file or filehandle. Possible options are:

filename, fh, string, dom, parser, config

=item $pml->save( \%opts )

Save PML instance to a file or file-handle. Possible options are:

fh, filename, config, save_refs, write_single_LM

=item convert_to_fsfile

=item convert from_fsfile

=item validate_object

=item hash_id

=item lookup_id

=item  get_filename

=item  set_filename

=item  get_transform_id

=item  set_transform_id

# Schema
=item  get_schema

=item  set_schema

=item  get_schema_url

=item  set_schema_url

# Data
=item  get_root

=item  set_root

=item  get_trees

=item  set_trees

=item  get_trees_prolog

=item  set_trees_prolog

=item  get_trees_epilog

=item  set_trees_epilog

=item  get_trees_type

=item  set_trees_type

# References
=item  get_readas_trees

=item  set_readas_trees

=item  get_references

=item  set_references

=item  get_refnames

=item  set_refnames

=item  get_ref

=item  set_ref

# Validation log
=item  get_log  (returns a list)

=item  clear_log
# Status=1 (if parsed fine)
=item  get_status

=item  set_status


=head1 SEE ALSO

Documentation to Fslib and TrEd documentation.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

