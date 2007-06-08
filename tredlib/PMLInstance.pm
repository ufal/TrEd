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

use Scalar::Util qw(weaken);
use PMLSchema;

$DEBUG = 0;

=begin comment

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

=end comment

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

our $VALIDATE_CDATA = 1;

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

# SAVE FLAGS
use constant {
  SAVE_DEFAULT          => 0,
  SAVE_KEEP_KNIT        => 1,
  SAVE_DECORATE         => 2, # decorate with type information
  SAVE_SINGLETON_LM     => 4,
};


# FIELDS:
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
    _no_read_trees
    _no_references
    _trees
    _pml_prolog
    _pml_epilog
    _id-hash
    _log
    _id_prefix
    _trees_written
    _refs_save
    _save_flags
    _pi
   );

# PML Instance File
sub get_filename	    {  $_[0]->{'_filename'}; }
sub set_filename	    {  $_[0]->{'_filename'} = $_[1]; }
sub get_transform_id	    {  $_[0]->{'_transform_id'}; }
sub set_transform_id	    {  $_[0]->{'_transform_id'} = $_[1]; }

# Schema
sub schema		    {  $_[0]->{'_schema'} }
*get_schema = \&schema;
sub set_schema		    {  $_[0]->{'_schema'} = $_[1] }
sub get_schema_url	    {  $_[0]->{'_schema-url'} }
sub set_schema_url	    {  $_[0]->{'_schema-url'} = $_[1]; }

# Data
sub get_root		    {  $_[0]->{'_root'}; }
sub set_root		    {  $_[0]->{'_root'} = $_[1]; }
sub get_trees		    {  $_[0]->{'_trees'}; }
#sub set_trees		    {  $_[0]->{'_trees'} = $_[1]; }
sub get_trees_prolog	    {  $_[0]->{'_pml_prolog'}; }
#sub set_trees_prolog	    {  $_[0]->{'_pml_prolog'} = $_[1]; }
sub get_trees_epilog	    {  $_[0]->{'_pml_epilog'}; }
#sub set_trees_epilog	    {  $_[0]->{'_pml_epilog'} = $_[1]; }
sub get_trees_type	    {  $_[0]->{'_pml_trees_type'}; }
#sub set_trees_type	    {  $_[0]->{'_pml_trees_type'} = $_[1]; }

# References
sub get_references_hash	    {  
  my $refs = $_[0]->{'_references'};
  $refs = $_[0]->{'_references'} = {} unless ( $refs );
  return $refs;
}
sub set_references_hash	    {  $_[0]->{'_references'} = $_[1]; }
sub get_refname_hash	    {  
  my $refs = $_[0]->{'_refnames'};
  $refs = $_[0]->{'_refnames'} = {} unless ( $refs );
  return $refs;
}
sub set_refname_hash	    {  $_[0]->{'_refnames'} = $_[1]; }
sub get_ref {
  my ($self,$id)=@_;
  my $refs = $self->{'_ref'};
  return $refs ? $refs->{$id} : undef;
}
sub set_ref {
  my ($self,$id,$obj)=@_;
  my $refs = $self->{'_ref'};
  $self->{'_ref'} = $refs = {} unless ($refs);
  return $refs->{$id}=$obj;
}

# Status=1 (if parsed fine)
sub get_status		    {  $_[0]->{'_status'}; }
#sub set_status		    {  $_[0]->{'_status'} = $_[1]; }


use Encode;
use XML::LibXML;
use XML::Writer;
use XML::LibXML::Common qw(:w3c :encoding);
use Data::Dumper;
use File::Spec;

require IOBackend;
require Fslib;
require PMLBackend;
import PMLBackend;

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
  if ($DEBUG<0) {
    Carp::cluck("PMLBackend: WARNING: $msg\n");
  } else {
    warn "PMLBackend: WARNING: $msg\n";
  }
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
  $ctxt->{'_no_read_trees'} ||= $opts->{no_trees};
  $ctxt->{'_no_references'} ||= $opts->{no_references};
  local $VALIDATE_CDATA=$opts->{validate_cdata} if
    exists $opts->{validate_cdata};
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
    if ($opts->{filename} eq '-') {
      $ctxt->{'_dom'} = $parser->parse_fh(\*STDIN,
					  $ctxt->{'_filename'});      
    } else {
      my $fh = IOBackend::open_uri($opts->{filename});
      $ctxt->{'_dom'} = $parser->parse_fh($fh,
					  $opts->{filename});
      IOBackend::close_uri($fh);
    }
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
	my $in_xsl_href = $in_xsl->get_member('href');
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
	    || _die("Cannot locate XSL stylesheet '$in_xsl_href' declared as "._element_address($in_xsl));
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
  undef $ctxt->{_dom};

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
	$ctxt->{'_schema'} = PMLSchema->readFrom($schema_file,
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
		  PMLSchema->new($xml,
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
  foreach my $ref ($ctxt->get_reffiles()) {
    if ($ctxt->{'_no_references'}) {
      # do not read any reffiles
    } elsif ($ref->{readas} eq 'dom') {
      $ctxt->readas_dom($ref->{id},$ref->{href});
    } elsif($ref->{readas} eq 'trees') {
      #  when translating to FSFile, 
      #  push to fs-require [$ref->{id},$ref->{href}];
    } elsif($ref->{readas} eq 'pml') {
      $ctxt->readas_pml($ref->{id},$ref->{href});
    } else {
      _warn("Ignoring references with unknown readas method: '$ref->{readas}'\n");
    }
  }
  my $schema = $ctxt->{'_schema'};
  my $root_type = $schema->{root};
  unless (ref $root_type) {
      _die("PML schema error - schema contains no root element declaration");
  }
  my $root_name = $schema->{root}{name};

  $root_type = $ctxt->resolve_type($root_type);
  unless (UNIVERSAL::isa($root_type,'HASH')) {
      _die("PML schema error - invalid root element declaration");
  }

  my $dom_root = $ctxt->{'_dom'}->getDocumentElement;
  unless ($dom_root->namespaceURI eq PML_NS and
	  $dom_root->localname eq $root_name) {
    _die("Expected root element '$root_name', got '".$dom_root->localname."'\n");
  }

  # In PML 1.1, root can either be a sequence or a structure
  if ($root_type->{structure} or $root_type->{sequence} or $root_type->{container}) {
    $ctxt->{'_root'} = read_node($ctxt, $dom_root, $root_type, { 
      # the child after <head>
      first_child => _skip_head($dom_root)
     });
    for my $pi ($ctxt->{'_dom'}->childNodes) {
      if ($pi->nodeType == PI_NODE) {
	push @{$ctxt->{'_pi'}}, [$pi->nodeName, $pi->getData ];
      }
    }
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
    if (!defined($rtype)) {
      warn "PML schema error: No declaration for type '$type->{type}' in schema '".
	$ctxt->{'_schema'}->get_url."'\n";
    }
    return $rtype; # || $type->{type};
  } else {
    return $type;
  }
}

sub get_reffiles {
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
  my $ref_fh = IOBackend::open_uri($local_file);
  _die("Cannot open $href for reading") unless $ref_fh;
  _debug("readas_dom: $href $ref_fh");
  my $parser = $ctxt->{'_parser'} || PMLBackend::xml_parser();
  if ($ref_fh){
    eval {
      $ref_data = $parser->parse_fh($ref_fh, $href);
    };
    _die("Error parsing $href $ref_fh $local_file ($@)") if $@;
    $ref_data->setBaseURI($href) if $ref_data and $ref_data->can('setBaseURI');;
    $parser->process_xincludes($ref_data);
    IOBackend::close_uri($ref_fh);
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
  my ($ctxt,$id,$object,$check_uniq) = @_;
  return if $id eq EMPTY; 
  my $prefix = $ctxt->{'_id_prefix'};
  $id = $prefix . $id;
  my $hash = $ctxt->{'_id-hash'} ||= {};
  if ($check_uniq) { # and $prefix eq ''
    my $current = $hash->{$id};
    if (defined $current and $current != $object) {
      _warn("Duplicated ID '$id'");
    }
  }
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
    my $data =$node->textContent;
    if ($VALIDATE_CDATA) {
      my $log = [];
      unless ($type->{cdata}->validate_object($data,{log => $log, 
						     tag => $node->localname})) {
	_warn(@$log," in element "._element_address($node));
      }
    }
    return $data;
  # LIST ------------------------------------------------------------
  } elsif (exists $type->{list}) {
    _debug({level => 6},"list type\n");
    my $list_type = $ctxt->resolve_type($type->{list});

    my @nodelist = $node->getChildrenByTagNameNS(PML_NS,LM);
    my $list = bless
      [
	@nodelist
	  ? (map {
	      $ctxt->read_node($_,$list_type)
	     } _read_List($node,\@nodelist)) 
	  : ($node->hasChildNodes or 
	       ($opts->{attrs} ? keys(%{$opts->{attrs}})>0 : $node->hasAttributes)) 
	  ? $ctxt->read_node($node, $list_type,{ attrs => $opts->{attrs} }) 
	  : () 
      ], 'Fslib::List';
    my $role = $type->{list}{role};
    my $childnodes_taker = $opts->{childnodes_taker};
    if ($role eq '#CHILDNODES' and $childnodes_taker) {
      _set_node_children($childnodes_taker, $list) if $list;
      return;
    } elsif ($role eq '#TREES') {
      return $ctxt->_set_trees($list, $type,$node);
    } else {
      return $list;
    }
  # ALT ------------------------------------------------------------
  } elsif (exists $type->{alt}) {
    _debug({level => 6},"alt type\n");
    my $alt_type = $ctxt->resolve_type($type->{alt});
    # alt
    my @Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
    my $size = @Alt;
    if ($size>1) {
      return bless [
	map {
	  $ctxt->read_node($_,$alt_type)
	} @Alt,
       ], 'Fslib::Alt';
    } elsif ($size ==1) {
      return $ctxt->read_node($Alt[0],$alt_type)
    } else {
      return $ctxt->read_node($node,$alt_type,{ attrs => $opts->{attrs} });
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
      return;
    } elsif ($role eq '#TREES') {
      return $ctxt->_set_trees($seq,$type,$node);
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
    if (!$ctxt->{_no_read_trees} and ($type->{role} eq '#NODE' or $struct->{role} eq '#NODE')) {
      $hash=FSNode->new();
      $childnodes_taker = $hash;
      $hash->set_type($type->{structure});
      #$ctxt->{'_schema'}->type($type->{structure}));
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
	if ($VALIDATE_CDATA) {
	  my $log = [];
	  unless ($member->get_content_decl->validate_object($value,{log => $log, tag=>$name})) {
	    _warn(@$log," in element "._element_address($node));
	  }
	}
	$hash->{$name} = $value;
	if ($member->{role} eq '#ID') {
	  $ctxt->hash_id($value,$hash,1);
	}
      } else {
	unless ($name =~ /^xml(?:ns)?(?:$|:)/) {
	  _warn("Undeclared attribute '$name' of "._element_address($node));
	}
      }
    }

### guess which is fastest:-)
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
	      $hash->{$name} = $ctxt->_set_trees($ctxt->read_node($child,$member),$member,$child);
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
						  PMLSchema::Decl->convert_from_hash(
						    {
						      # Fake type
						      list => {cdata=>{format=>'PMLREF'}}, 
						      ordered => $member->{list}{ordered}
						     },
						    $ctxt->{'_schema'},
						    '!!fake'
						   ));
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
	      $ctxt->hash_id($hash->{$name},$hash,1);
	    }
	  }
	} else {
	  _die("Undeclared member '$name' encountered in ".
	    _element_address($node,$child));
	}
     } elsif ((($child_nodeType == TEXT_NODE
		or $child_nodeType == CDATA_SECTION_NODE)
		and $child->data=~/\S/)) {
	_warn("Ignoring text content '".$child->data."' in element "._element_address($child));
      } elsif ($child_nodeType == ELEMENT_NODE
		 and $child->namespaceURI ne PML_NS) {
	_warn("Ignoring non-PML element "._element_address($child));
      }
    } continue {
      $child = $child->nextSibling;
    }
    foreach (keys %{$members}) {
      if (!exists($hash->{$_})) {
	my $member = $members->{$_};
	if ($member->{required}) {
	  if ($member->{role} eq '#KNIT') {
	    my $name = $_; $name=~s/\.rf$//;
	    if (!exists($hash->{$name})) {
	      _warn("Missing required member '$_' or '$name' of ".
		      _element_address($node));
	    }
	  } else {
	    _warn("Missing required member '$_' of ".
		    _element_address($node));
	  }
	} else {
	  my $mtype = $ctxt->resolve_type($member);
	  if (ref($mtype) and exists($mtype->{constant})) {
	    $hash->{$_}=$mtype->{constant}{value};
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
    if (!$ctxt->{_no_read_trees} and ($type->{role} eq '#NODE' or $container->{role} eq '#NODE')) {
      $hash=FSNode->new();
      $opts->{childnodes_taker} = $hash;
      $hash->set_type($container); #$ctxt->{'_schema'}->type($container));
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
      my $attr_decl = $attributes->{$atr_name};
      if (exists($attrs->{$atr_name})) {
	my $value = delete $attrs->{$atr_name};
	if ($VALIDATE_CDATA) {
	  my $log = [];
	  unless ($attr_decl->get_content_decl->validate_object($value,{log => $log, tag=>$atr_name})) {
	    _warn(@$log," in element "._element_address($node));
	  }
	}
	$hash->{$atr_name} = $value;
	if ($attr_decl->{role} eq '#ID') {
	  $ctxt->hash_id($hash->{$atr_name},$hash,1);
	}
      } elsif ($attr_decl->{required}) {
	_die("Required attribute '$atr_name' missing in container ".
	       _element_address($node));
      }
    }
    # passing options as is (including live reference to $attrs)
    if ($container->{-decl} or $container->{type}) {
      $hash->{'#content'} = $ctxt->read_node($node,$container, $opts);
    }
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
    my $values = $type->{choice}{values};
    foreach (@{$values}) {
      if ($_ eq $data) {
	$ok = 1;
	last;
      }
    }
    unless ($ok) {
      _warn("Invalid value: '$data' (expected one of: ".join(',',@$values).") in "._element_address($node));
    }
    return $data;
  # CONSTANT ------------------------------------------------------------
  } elsif (exists $type->{constant}) {
    _debug({level => 6},"constant type\n");
    my $data = $node->textContent();
    if ($data ne EMPTY and $data ne $type->{constant}{value}) {
      _warn("Invalid value '$data' (expected constant: '$type->{constant}') in "._element_address($node));
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
  return;
}


# If a given DOM node contains a pml:List, return a list of its members,
# otherwise return the node itself.

sub _read_List {
  my ($node,$node_list)=@_;
  return unless $node;
  if ($node_list) {
    return @$node_list ? @$node_list : $node;
  } else {
    my @List = $node->getChildrenByTagNameNS(PML_NS,LM);
    return @List if @List;
    if ($node->hasChildNodes or 
	  $node->hasAttributes) {
      return $node; # singleton
    } else {
      return (); # emtpy list
    }
  }
}

sub read_Sequence {
  my ($ctxt,$child,$type,$seq)=@_;
  $seq ||= Fslib::Seq->new();
  $seq->set_content_pattern($type->{content_pattern});
  return $seq unless $child;
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


# If given DOM node contains a pml:Alt, return a list of its members,
# otherwise return the node itself.

sub _read_Alt {
  my ($node)=@_;
  return unless $node;
  my @Alt = $node->getChildrenByTagNameNS(PML_NS,AM);
  return @Alt ? @Alt : $node;
}


sub _element_address {
  my ($node,$line_node)=@_;
  $node = $node->getParentNode unless $node->nodeType == ELEMENT_NODE;
  $line_node ||= $node;
  return "'".$node->nodeName."' at ".$line_node->ownerDocument->URI.":".$line_node->line_number."\n";
}

# $ctxt, $data, $type, $node
sub _set_trees {
  my ($ctxt,$data,$type,$node)=@_;
  return $data if $ctxt->{'_no_read_trees'};
  _debug("Found #TREES in "._element_address($node));
  unless (defined $ctxt->{'_pml_trees_type'}) {
    $ctxt->{'_pml_trees_type'}= $type;
    if (UNIVERSAL::isa($data,'Fslib::List')) {
      $ctxt->{'_trees'} = $data;
      _warn("Object with role #TREES contains non-#NODE list members in "._element_address($node))
	if (grep {!UNIVERSAL::isa($_,'FSNode')} @{$ctxt->{'_trees'}});
      return; #$ctxt->{'_trees'}
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
      return;
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
    if ($prev) {
      Fslib::PasteAfter($son,$prev);
    } else {
      Fslib::Paste($son,$node,undef);
    }
    $prev = $son;
  }
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
      my $id_member;
      {
	# find what attribute is ID
	my $decl = $type->{structure}||$type->{container};
	if ($decl) {
	  $id_member = $decl->{'-#ID'}; # cached
	  unless (defined $id_member) {
	    my ($idM) = grep { $_->{role} eq '#ID' } $decl->get_attributes();
	    if ($idM) {
	      $id_member = $decl->{'-#ID'} = $idM->{-name};
	      # what follows is a hack fixing buggy PDT 2.0 schemas
	      if ($idM->{cdata} and $idM->{cdata}{format} eq 'ID') {
		$idM->{cdata}{format} = 'PMLREF';
	      } elsif ($idM->{type}) {
		if ($idM->{type}) {
		  my $idType = $ctxt->resolve_type($idM);
		  if ($idType->{cdata} and $idType->{cdata}{format} eq 'ID') {
		    my $what = $type->{name} || $type->{-name};
		    _warn "Trying to knit an object with type/name '$what' which has an #ID-attribute ".
		      "'$idM->{-name}' declared as <cdata format=\"ID\"/>. ".
		      "Note that the data-type for #ID-attributes in objects knitted as DOM should be ".
		      "<cdata format=\"PML\"/> (Hint: redeclare with <derive> for imported types).";
		  }
		}
	      }
	    }
	  }
	}
      } 

      $ctxt->{'_ref-index'}||={};
      my $refnode =
	$ctxt->{'_ref-index'}->{$reffile}{$idref} ||
	  $data->getElementsById($idref);
      if (ref($refnode)) {
	my ($ret);
	my $_id_prefix = $ctxt->{'_id_prefix'};

	if (defined $id_member) {
	  $ret = $ctxt->lookup_id( $_id_prefix.$reffile.'#'.$idref );
	  if (defined $ret) {
	    # we have already knitted this part, reuse it
	    return [ KNIT_OK, $ret];
	  }
	}

	$ctxt->{'_id_prefix'} .= $reffile.'#';
	$ret = $ctxt->read_node($refnode,$type);
	$ctxt->{'_id_prefix'} = $_id_prefix;

	if (defined $id_member and ref($ret) and $ret->{$id_member}) {
	  $ret->{$id_member} = $reffile.'#'.$ret->{$id_member};
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

  local $VALIDATE_CDATA=$opts->{validate_cdata} if
    exists $opts->{validate_cdata};

  $ctxt->{'_filename'} = $opts->{filename} if $opts->{filename};
  my $href = $ctxt->{'_filename'};

  $fh=\*STDOUT if ($href eq '-' and !$fh);

  $ctxt->{'_trees_written'} = 0;
  $ctxt->{'_save_flags'}  = SAVE_DEFAULT;
  $ctxt->{'_save_flags'} |= SAVE_KEEP_KNIT     if $opts->{keep_knit};
  $ctxt->{'_save_flags'} |= SAVE_DECORATE      if $opts->{decorate};
  $ctxt->{'_save_flags'} |= SAVE_SINGLETON_LM  if $opts->{'write_single_LM'};

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
      $out_xsl_href = Fslib::ResolvePath($PMLBackend::config->{_filename}, $out_xsl_href, 1);
      if ($out_xsl_href eq EMPTY) {
	_die("PMLBackend: no output transformation defined for $transform_id");
      }
      $ctxt->{'_writer'} = XML::MyDOMWriter->new(DOM => XML::LibXML::Document->new);
      $ctxt->write_data();
      my $dom = $ctxt->{'_writer'}->end;
      my $xslt = XML::LibXSLT->new;
      my $params = $out_xsl->content;
      my %params;
      %params = map { $_->{'name'} => $_->textContent } $params->values
	  if $params;
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
  my ($ctxt) = @_;

  my $schema = $ctxt->{'_schema'};
  unless (ref($schema)) {
    _die("Cannot write - document isn't associated with a schema");
  }

  $ctxt->{'_types'} ||= $schema->{type};
  my $root_name = $schema->{root}{name};
  my $root_type = $ctxt->resolve_type($schema->{root});

  # dump embedded DOM documents
  my $refs_to_save = $ctxt->{'_refs_save'};
  my @refs_to_save = grep { $_->{readas} eq 'dom' or $_->{readas} eq 'pml' } $ctxt->get_reffiles();
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

  $xml->startTag($root_name,'xmlns' => PML_NS, 
		 ($ctxt->{_save_flags} & SAVE_DECORATE ? ('xmlns:s' => PML_SCHEMA_NS) : () ),
		 %attribs);
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
	unless (Fslib::_is_url($href)) { 
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
  if ($ctxt->{'_pi'}) {
    for my $pi (@{$ctxt->{'_pi'}}) {
      $xml->pi(@$pi);
    }
  }
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

sub write_start_tag {
  my $ctxt = shift;
  my $type = shift;
  my @t=();
  if ($ctxt->{'_save_flags'} & SAVE_DECORATE) {
    my $path  = $type->get_decl_path;
    $path =~ s/^!//;
    @t = ('s:type', $path);
  }
  $ctxt->{'_writer'}->startTag(@_,@t);
}
sub write_empty_tag {
  my $ctxt = shift;
  my $type = shift;
  my @t=();
  if ($ctxt->{'_save_flags'} & SAVE_DECORATE) {
    my $path  = $type->get_decl_path;
    $path =~ s/^!//;
    @t = ('s:type', $path);
  }
  $ctxt->{'_writer'}->emptyTag(@_,@t);
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
    $ctxt->write_start_tag($type->{cdata},$tag,%$attribs) if defined($tag);
    if ($VALIDATE_CDATA) {
      my $log = [];
      unless ($type->{cdata}->validate_object($object,{log => $log, 
						       tag=>$tag})) {
	_warn(@$log);
      }
    }
    $xml->characters($object);
    $xml->endTag($tag) if defined($tag);
  } elsif (exists $type->{choice}) {
    my $ok;
    my $values = $type->{choice}{values};
    foreach (@{$values}) {
      if ($_ eq $object) {
	$ok = 1;
	last;
      }
    }
    unless ($ok) {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Invalid value for '$what': $object\n")
    }
    $ctxt->write_start_tag($type->{choice},$tag,%$attribs);
    $xml->characters($object);
    $xml->endTag($tag);
  } elsif (exists $type->{structure}) {
    my $struct = $type->{structure};
    my $members = $struct->{member};
    if (!ref($object)) {
      # what do we do now?
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Unexpected content of the structure '$what': $object\n");
    } elsif (keys(%$object)+keys(%$attribs)>0) {
      # ok, non-empty structure
      if ($opts->{no_attribs}) {
	$ctxt->write_start_tag($struct,$tag) if defined($tag);
      } else {
	foreach my $mdecl (grep {$_->{as_attribute}} values %$members) {
	  my $atr = $mdecl->{-name};
	  if ($mdecl->{required} or $object->{$atr} ne EMPTY) {
	    my $value = $object->{$atr};
	    if ($VALIDATE_CDATA) {
	      my $log = [];
	      unless ($mdecl->get_content_decl->validate_object($value,{log => $log, 
									path=>$tag,
									tag=>$atr})) {
		_warn(@$log);
	      }
	    }
	    $attribs->{$atr} = $value;
	  }
	}
	if (%$attribs and !defined($tag)) {
	  _die("Cannot write structure with attributes (".join("\,",keys %$attribs).") without a tag");
	}
	$ctxt->write_start_tag($type->{structure},$tag,%$attribs) if defined($tag);
      }
      foreach my $mdecl (
	grep {!$_->{as_attribute}} 
	  sort { $a->{'-#'} <=> $b->{'-#'} }
	  values %$members) {
	my $is_required = $mdecl->{required};
	my $member = $mdecl->{-name};
	my $mtype = $ctxt->resolve_type($mdecl);
	if ($mdecl->{role} eq '#CHILDNODES') {
	  if (ref($object) eq 'FSNode') {
	    if ($object->firstson or $is_required) {
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
	      $ctxt->write_object($children, $mdecl,{ tag => $member, no_empty => !$is_required });
	    }
	  } else {
	    _warn("Found #CHILDNODES member '$member' on a non-node value: $object\n");
	  }
	} elsif ($mdecl->{role} eq '#TREES') {
	  my $data = $ctxt->get_write_trees($mdecl,$mtype);
	  $ctxt->write_object($data,$mdecl,{ tag => $member, no_empty => !$is_required });
	} elsif ($mdecl->{role} eq '#KNIT') {
	  if ($object->{$member} ne EMPTY) {
	    # un-knit data
	    # _debug("#KNIT.rf $member");
	    my $value = $object->{$member};
	    $ctxt->write_start_tag($mdecl->get_content_decl,$member);
	    if ($VALIDATE_CDATA) {
	      my $log = [];
	      unless ($mdecl->get_content_decl->validate_object($value,{log => $log, 
									path=>$tag,
									tag=>$member})) {
		_warn(@$log);
	      }
	    }
	    $xml->characters($value);
	    $xml->endTag($member);
	  } else {
	    # knit data
	    my $knit_tag = $member;
	    $knit_tag =~ s/\.rf$//;
	    if ($ctxt->{'_save_flags'} & SAVE_KEEP_KNIT) {
	      $ctxt->write_object($object->{$knit_tag}, $mdecl,{ tag => $knit_tag,  no_empty => !$is_required });
	    } elsif (ref($object->{$knit_tag})) {
	      $ctxt->write_object_knit($object->{$knit_tag}, $mdecl,{ tag => $member });
	    }# else {
	    #	_warn("Didn't find $knit_tag on the object! ",join(" ",%$object),"\n");
	    #      }
	  }
	} elsif (ref($mtype) and $mtype->{list} and $mtype->{list}{role} eq '#KNIT') {
	  if ($object->{$member} ne EMPTY) {
	    # un-knit list
	    my $list = $object->{$member};
	    # _debug("#KNIT.rf $member @$list");

	    write_list($ctxt, $list, $mtype->{list}, { tag => $member, no_resolve => 1 } );
	  } else {
	    # KNIT list
	    my $knit_tag = $member;
	    $knit_tag =~ s/\.rf$//;
	    my $list = $object->{$knit_tag};
	    if ($list ne EMPTY) {
	      if ($ctxt->{'_save_flags'} & SAVE_KEEP_KNIT) {
		write_list($ctxt, $list, $mtype->{list}, { tag => $knit_tag, knit => 0 } )
	      } else {
		write_list($ctxt, $list, $mtype->{list}, { tag => $member, knit => 1, no_resolve => 1 } )
	      }
	    }
	  }
	} elsif ($object->{$member} ne EMPTY or $is_required) {
	  $ctxt->write_object($object->{$member},$mdecl,{tag => $member, no_empty => !$is_required });
	}
      }
      $xml->endTag($tag) if defined($tag);
    } else {
      # encode empty struct
      my $etag = $opts->{empty_tag} || $tag;
      $ctxt->write_empty_tag($struct,$etag) if defined($etag) and !$opts->{no_empty};
    }
  } elsif (exists $type->{list}) {
    my $list_type = $type->{list};
    if (ref($list_type) and $list_type->{role} eq '#TREES') {
      $object = $ctxt->get_write_trees($object,$type);
    }
    write_list($ctxt, $object, $list_type, $opts);
  } elsif (exists $type->{alt}) {
    my $alt = $type->{alt};
    if ($object ne EMPTY and ref($object) eq 'Fslib::Alt') {
      if (@$object == 0 and keys(%$attribs)==0) {
	# encode empty alt
	my $etag = $opts->{empty_tag} || $tag;
	$ctxt->write_empty_tag($alt,$etag) if defined($etag) and !$opts->{no_empty};
      } elsif (@$object == 1 and !$opts->{write_single_AM} and keys(%$attribs)==0) {
	$ctxt->write_object($object->[0],$alt,$opts);
      } else {
	$ctxt->write_start_tag($alt,$tag,%$attribs) if defined($tag);
	foreach my $value (@$object) {
	  $ctxt->write_object($value,$alt,{tag => AM});
	}
	$xml->endTag($tag) if defined($tag);
      }
    } else {
      if (!$opts->{write_single_AM} and keys(%$attribs)==0) {
	$ctxt->write_object($object,$alt, $opts);
      } else {
	$ctxt->write_start_tag($alt,$tag,%$attribs) if defined($tag);
	$ctxt->write_object($object,$alt,{tag => AM, no_empty => 1});
	$xml->endTag($tag) if defined($tag);
      }
    }
  } elsif (exists $type->{sequence}) {
    my $sequence = $type->{sequence};
    my $data_mode;
    if ($sequence->{text}) {
      $data_mode = $xml->getDataMode();
      $xml->setDataMode(0);
    }
    $ctxt->write_start_tag($sequence,$tag,%$attribs) if defined($tag);
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
	  unless ($sequence->{text}) {
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
    } elsif(defined($object)) {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _die("Unexpected content of the sequence '$what': $object\n");
    }
    $xml->endTag($tag) if defined($tag);
    $xml->setDataMode($data_mode) if defined $data_mode;
  } elsif (exists $type->{container}) {
    my $what = $tag || $type->{name} || $type->{'-name'};    
    unless (UNIVERSAL::isa($object,'HASH')) {
      _die("Unexpected type of the container '$what': $object\n");
    }
    my $container = $type->{container};
    my %attribs = %$attribs;
    unless ($opts->{no_attribs}) {
      if ($container->{attribute}) {
	foreach my $attrib (values(%{$container->{attribute}})) {
	  my $atr = $attrib->{-name};
	  if ($attrib->{required} or $object->{$atr} ne EMPTY) {
	    my $value = $object->{$atr};
	    if ($VALIDATE_CDATA) {
	      my $log = [];
	      unless ($attrib->get_content_decl->validate_object($value,{log => $log, 
									 path => $tag,
									 tag=>$atr})) {
		_warn(@$log);
	      }
	    }
	    $attribs{$atr} = $value;
	  }
	}
      }
      if (%attribs and !defined($tag)) {
	_warn("Internal error: too late to serialize attributes of a container in '$what'");
      }
    }
    if ($container->{-decl} or $container->{type}) {
      my $content = $object->{'#content'};
      if ($container->{role} eq '#NODE' and 
	    UNIVERSAL::isa($object,'FSNode')) {
	$content = $ctxt->get_childnodes($object,$container,$content,$what);
      }
      $ctxt->write_object($content,$container,{ %$opts, 
						write_single_LM => 1,
						write_single_AM => 1,
						no_attribs => 0,
						attribs => \%attribs
					       });
    } else {
      $ctxt->write_empty_tag($container,$tag, %attribs);
    }
  } elsif (exists $type->{constant}) {
    if ($object ne $type->{constant}{value}) {
      my $what = $tag || $type->{name} || $type->{'-name'};
      _warn("Invalid constant '$what', should be '$type->{constant}', got: ",$object);
    }
    $ctxt->write_start_tag($type->{constant},$tag,%$attribs) if defined($tag);
    $xml->characters($object);
    $xml->endTag($tag) if defined($tag);
  } else {
    my $what = $tag || $type->{name} || $type->{'-name'};
    _die("Type error: unrecognized data type for '$what'!\nObject cannot be serialized in this context.\nParsed type declaration follows:\n".Dumper($type));
  }
  1;
}

sub write_list {
  my ($ctxt, $object, $type, $opts) = @_;
  $opts ||= {};
  my $tag = $opts->{tag};
  my $knit = $opts->{knit};
  my $no_resolve = $opts->{no_resolve};
  my $attribs = $opts->{attribs} || {};
  my $xml = $ctxt->{'_writer'};
  if (ref($object) eq 'Fslib::List') {
    if (@$object == 0) {
      # encode empty list
      my $etag = $opts->{empty_tag} || $tag;
      $ctxt->write_empty_tag($type,$etag,%$attribs) if defined($etag) and not ($opts->{no_empty} and keys(%$attribs)==0);
    } elsif (@$object == 1 and !$opts->{'write_single_LM'} and
	       !($ctxt->{'_save_flags'} & SAVE_SINGLETON_LM) and 
		 keys(%$attribs)==0 and
	     !(UNIVERSAL::isa($object->[0],'HASH') and keys(%{$object->[0]})==0)) {
      if ($knit) {
	$ctxt->write_object_knit($object->[0],$type,{ tag => $tag });
      } else {
	$ctxt->write_object($object->[0],$type, { tag => $tag,
						  empty_tag => LM, 
						  no_resolve => $no_resolve });
      }
    } else {
      $ctxt->write_start_tag($type,$tag,%$attribs) if defined($tag);
      if (defined $knit) {
	foreach my $value (@$object) {
	  $ctxt->write_object_knit($value,$type,{ tag => LM });
	}
      } else {
	foreach my $value (@$object) {
	  $ctxt->write_object($value,$type,{ tag => LM, no_resolve => $no_resolve });
	}
      }
      $xml->endTag($tag) if defined($tag);
    }
  } else {
    my $what = $tag || $type->{name} || $type->{'-name'};
    _warn("Unexpected content of the list '$what': $object\n");
  }
}      




# $ctxt, $object, $type, { tag=> $tag, attribs => {}, $knit_tag => }
sub write_object_knit {
  my ($ctxt,$object,$type,$opts)=@_;
  my $tag = $opts->{tag};
  my $attribs = $opts->{attribs} || {};  
  my $xml = $ctxt->{'_writer'};

  my $prefix=EMPTY;


  my $rtype = $ctxt->resolve_type($type);

  my $id;
  # find what attribute is ID
  my $decl = $rtype->{structure}||$rtype->{container};
  if ($decl) {
    $id = $decl->{'-#ID'}; # cached
    unless (defined $id) {
      my ($idM) = grep { $_->{role} eq '#ID' } $decl->get_attributes();
      if ($idM) {
	$id = $decl->{'-#ID'} = $idM->{-name};
      }
    }
  }
  if (!defined $id) {
    _warn("Don't know which attribute is #ID - cannot knit back!\n");
    return;
  }
  my $ref = $object->{$id};
  if (ref($object) and $ref !~ /#/) {
    $prefix = $object->{'#knit_prefix'};
  } elsif ($ref =~ /^(?:(.*?)\#)?(.+)/) {
    $ref = $2;
    $prefix = $1;
  }

  {
    $ctxt->write_start_tag($type->get_content_decl,$tag,$attribs?%$attribs:());
    my $value = $prefix ne EMPTY ? $prefix.'#'.$ref : $ref;
    if ($VALIDATE_CDATA) {
      my $log = [];
      unless ($type->get_content_decl->validate_object($value,{log => $log, 
							       path=>'',
							       tag=>$tag})) {
	_warn(@$log);
      }
    }
    $xml->characters( $value );
    $xml->endTag($tag);
  }

  if ($prefix ne EMPTY) {
    return if (UNIVERSAL::isa($ctxt->{'_ref'}{$prefix},'PMLInstance'));
    my $refs_save = $ctxt->{'_refs_save'} || {};
    my $rf_href = $refs_save->{$prefix};
    if ( $rf_href ) {
      my $indeces = $ctxt->{'_ref-index'};
      if ($indeces and $indeces->{$prefix}) {
	my $knit = $indeces->{$prefix}{$ref};
	if ($knit) {
	  my $tag = $knit->nodeName;
	  my $dom_writer = XML::MyDOMWriter->new(REPLACE => $knit);
	  {
	    my $writer = $ctxt->{'_writer'};
	    $ctxt->{'_writer'} = $dom_writer;
	    eval {
	      $ctxt->write_object($object, $rtype, { tag => $tag });
	    };
	    $ctxt->{'_writer'} = $writer;
	    die $@."\n" if $@;
	  }
	  my $new = $dom_writer->end;
	  $new->setAttribute($id,$ref);
	} else {
	  _warn("Didn't find ID '$ref' in '$rf_href' ('$prefix') - cannot knit back!\n");
	}
      } else {
	_warn("Knit-file '$rf_href' ('$prefix') has no index - cannot knit back!\n");
      }
    }
  } else {
    _warn("Cannot parse '$tag' href '$ref' - cannot knit back!\n");
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
	_warn("#TREES are neither a list nor a sequence - cannot save trees.\n");
      }
    } else {
      _warn("Cannot determine #TREES type - cannot save trees.\n");
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
# Validation
#########################################

sub validate_object {
  my ($ctxt, $object, $type, $opts)=@_;
  $type->validate_object($object,$opts);
}

##########################################
# Data pulling
#########################################

sub get_data {
  my ($node,$path, $strict) = @_;
  if (UNIVERSAL::isa($node,__PACKAGE__)) {
    $node = $node->get_root;
  }
  my $val = $node;
  for my $step (split /\//, $path) {
    if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
      if ($step =~ /^\[(\d+)\]/) {
	$val = $val->[$1-1];
      } elsif ($strict) {
	return; # ERROR
      } else {
	$val = $val->[0]{$step};
      }
    } elsif (UNIVERSAL::isa($val, 'Fslib::Seq')) {
      if ($step =~ /^\[(\d+)\]/) {
	$val = $val->[$1-1][1]; # value
      } elsif ($step =~ /^([^\[]+)(?:\[(\d+)\])?/) {
	my $i = $2;
	$val = $val->values($1);
	if ($i ne q{}) {
	  $val = $val->[ $i ];
	}
      } else {
	return; # ERROR
      }
    } elsif (ref($val)) {
      $val = $val->{$step};
    } elsif (defined($val)) {
      return; # ERROR
    } else {
      return '';
    }
  }
  return $val;
}

sub set_data {
  my ($node,$path, $value, $strict) = @_;
  if (UNIVERSAL::isa($node,__PACKAGE__)) {
    $node = $node->get_root;
  }
  my $val = $node;
  my @steps = split /\//, $path;
  while (@steps) {
    my $step = shift @steps;
    if (ref($val) eq 'Fslib::List' or ref($val) eq 'Fslib::Alt') {
      if ($step =~ /^\[(\d+)\]/) {
	if (@steps) {
	  $val = $val->[$1-1];
	} else {
	  $val->[$1-1] = $value;
	  return $value;
	}
      } elsif ($strict) {
	my $msg = "Can't follow attribute path '$path' (step '$step')";
	croak $msg if ($strict==2);
	warn $msg."\n";
	return; # ERROR
      } else {
	if (@steps) {
	  $val = $val->[0]{$step};
	} else {
	  $val->[0]{$step} = $value;
	  return $value;
	}
      }
    } elsif (ref($val)) {
      if (@steps) {
	if (!defined($val->{$step}) and $steps[0]!~/^\[/) {
	  $val->{$step}=Fslib::Struct->new;
	}
	$val = $val->{$step};
      } else {
	$val->{$step} = $value;
	return $value;
      }
    } elsif (defined($val)) {
      my $msg = "Can't follow attribute path '$path' (step '$step')";
      croak $msg if ($strict==2);
      warn $msg."\n";
      return; # ERROR
    } else {
      return '';
    }
  }
  return;
}

##########################################
# Convert to FSFile
#########################################

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

  # rebless
  bless $schema, 'Fslib::Schema';
  $fsfile->changeMetaData( 'schema',         $schema                    );
  $fsfile->changeMetaData( 'schema-url',     $ctxt->{'_schema-url'}      );
  $fsfile->changeMetaData( 'schema-inline',  $ctxt->{'_schema-inline'}   );
  $fsfile->changeMetaData( 'pml_transform',  $ctxt->{'_transform_id'}    );
  $fsfile->changeMetaData( 'references',     $ctxt->{'_references'}      );
  $fsfile->changeMetaData( 'refnames',       $ctxt->{'_refnames'}        );
  $fsfile->changeMetaData( 'fs-require',
     [ map { [$_->{id},$_->{href}] } 
	 grep { $_->{readas} eq 'trees' } $ctxt->get_reffiles() ]
  );

  $fsfile->changeAppData(  'ref',            $ctxt->{'_ref'} || {}         );
#  $fsfile->changeAppData(  'ref-index',      $ctxt->{'_ref-index'} || {} );
  $fsfile->changeAppData(  'id-hash',        $ctxt->{'_id-hash'}         );

  $fsfile->changeMetaData( 'pml_root',       $ctxt->{'_root'}            );
  $fsfile->changeMetaData( 'pml_trees_type', $ctxt->{'_pml_trees_type'}  );
  $fsfile->changeMetaData( 'pml_prolog',     $ctxt->{'_pml_prolog'}        );
  $fsfile->changeMetaData( 'pml_epilog',     $ctxt->{'_pml_epilog'}        );
  
  if ($ctxt->{'_pi'})  {
    my @patterns = map { $_->[1] } grep { $_->[0] eq 'tred-pattern' } @{$ctxt->{'_pi'}};
    my ($hint) = map { $_->[1] } grep { $_->[0] eq 'tred-hint' } @{$ctxt->{'_pi'}} ;
    for (@patterns, $hint) {
      s/&lt;/</g;
      s/&gt;/>/g;
      s/&amp;/&/g;
    }
    $fsfile->changePatterns( @patterns  );
    $fsfile->changeHint( $hint );
  }

  $fsfile->changeTrees( @{$ctxt->{'_trees'}} ) if $ctxt->{'_trees'};

  my @nodes = $ctxt->{'_schema'}->find_role('#NODE');
  my (@order,@hide);
  for my $path (@nodes) {
    my $node_decl = $schema->find_type_by_path($path);
    #if ($node_decl->get_decl_type == PML_ELEMENT_DECL) {
    #  $node_decl = $node_decl->get_content_decl;
    #}
    push @order, map { $_->get_name } $node_decl->find_members_by_role('#ORDER');
    push @hide, map { $_->get_name } $node_decl->find_members_by_role('#HIDE' );
    #    push @order, $node_decl->find_role('#ORDER',{no_childnodes=>1});
    #    push @hide, $node_decl->find_role('#HIDE',{no_childnodes=>1});
    # last if $order ne EMPTY and $hide ne EMPTY;
  }
  my %uniq;
  @order = grep { !$uniq{$_} && ($uniq{$_}=1) } @order;
  %uniq=();
  @hide = grep { !$uniq{$_} && ($uniq{$_}=1) } @hide;
  if (@order>1) {
    _warn("FSFile only supports #ORDER members/attributes with a same name: found {",
	  join(',',@order),"}, using $order[0]!");
  }
  if (@hide>1) {
    _warn("FSFile only supports #HIDE members/attributes with a same name: found {",
	  join(',',@hide),"} $hide[0]!");
  }
  my $defs = $fsfile->FS->defs;
  $defs->{$order[0]} = ' N' if @order;
  $defs->{$hide[0]}  = ' H' if @hide;

  return $fsfile;
}

##########################################
# Convert from FSFile
##########################################

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

  my $PIs = $ctxt->{'_pi'} = [];
  for my $pattern ($fsfile->patterns) {
    $pattern =~ s/&/&amp;/g;
    $pattern =~ s/</&lt;/g;
    $pattern =~ s/>/&gt;/g;
    push @$PIs, ['tred-pattern', $pattern];
  }
  my $hint = $fsfile->hint;
  if (defined $hint and length $hint) {
    $hint =~ s/&/&amp;/g;
    $hint =~ s/</&lt;/g;
    $hint =~ s/>/&gt;/g;
    push @$PIs, [ 'tred-hint', $hint ];
  }
  
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
	_die ("Cannot end ".
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

This class provides a simple implementation of a PML instance.

=head1 EXPORT

None by default.

The following export tags are available:

=over 4

=item :constants

Imports the following constants:

=over 8

=item LM

name of the "<LM>" (list-member) tag

=item AM

name of the "<LM>" (alt-member) tag

=item PML_NS

XML namespace URI for PML instances

=item PML_SCHEMA_NS

XML namespace URI for PML schemas

=item SUPPORTED_PML_VERSIONS

space-separated list of supported PML-schema version numbers

=back

=item :diagnostics

Imports internal _die, _warn, and _debug diagnostics commands.

=back

=head1 METHODS

=over 3

=item PMLInstance->new ()

Create a new empty PML instance object.

=item PMLInstance->load (\%opts)

=item $pml->load (\%opts)

Read a PML instance from file, filehandle, string, or DOM.  This
method may be used both on an existing object (in which case it
operates on and returns this object) or as a constructor (in which
case it creates a new PMLInstance object and returns it). Possible
options are: 

  {
    filename => $filename,  # and/or
    fh => \*FH,             # or
    string => $xml_string,  # or
    dom => $document,       # (XML::LibXML::Document)
    parser => $xml_parser,  # (XML::LibXML)
    config => $cfg_pml,     # (PMLInstance)
    no_trees => $bool,
    no_references => $bool,
  }

where C<filename> may be used either by itself or in combination with
any of C<fh> , C<string>, or C<dom>, which are otherwise mutually
exclusive. The C<parser> option may be used to substitute a customized
XML::LibXML parser object. The C<config> option may be used to pass a
PMLInstance representing a PMLBackend configuration file. If
C<no_trees> is true, then the roles #TREES and #NODES are ignored.  If
C<no_references> is true, then the 'readas' attribute of a reffile
header is ignored, i.e. load does not attempt to load any reffered
file (or knit to it).

=item $pml->get_status ()

Returns 1 if the last load() was successful.

=item $pml->save (\%opts)

Save PML instance to a file or file-handle. Possible options are:
C<filename, fh, config, refs_save, write_single_LM>.  If both
C<filename> and C<fh> are specified, C<fh> is used, but the filename
associated with the PMLInstance object is changed to C<filename>.  If
neither is given, the filename currently associated with the
PMLInstance object is used. The C<config> option may be used to pass a
PMLInstance representing a PMLBackend configuration file.  The
C<refs_save> option may be used to specify which reference files
should be saved along with the PMLInstance and where to. The value of
C<refs_save>, if given, should be a HASH reference mapping reference
IDs to the target URLs (filenames). If C<refs_save> is given, only
those references listed in the HASH are saved along with the
PMLInstance. If C<refs_save> is undefined or not given, all references
are saved (to their original locations). In both cases, only files
declared as readas='dom' or readas='pml' can be saved.

=item $pml->convert_to_fsfile (fsfile)

Translates the current C<PMLInstance> object to a C<FSFile> object
(using FSFile MetaData and AppData fields for storage of non-tree
data). If fsfile argument is not provided, creates a new C<FSFile> object,
otherwise operates on a given fsfile. Returns the resulting C<FSFile> object.

=item $pml->convert_from_fsfile (fsfile)

=item PMLInstance->convert_from_fsfile (fsfile)

Translates a C<FSFile> object to a C<PMLInstance> object. Non-tree
data are fetched from FSFile MetaData and AppData fields. If called
on an instance, modifies and returns the instance, otherwise creates
and returns a new instance.

=item $pml->hash_id (id,object,warn)

Hash a given object under a given ID. If warn is true, then a warning
is issued if the ID already wash hashed with a different object.

=item $pml->lookup_id (id)

Lookup an object by ID.

=item $pml->get_filename ()

Return the filename of the PML instance.

=item $pml->set_filename (filename)

Change filename of the PML instance.

=item $pml->get_transform_id ()

Return ID of the XSL-based transformation specification which was used
to convert between an original non-PML format and PML (and back).

=item $pml->set_transform_id (transform)

Set ID of an XSL-transformation specification which is to be used for
conversion from PML to an external non-PML format (and back).

=item $pml->get_schema ()

Return C<PMLSchema> object associated with the PML instance.

=item $pml->set_schema (schema)

Associate a C<PMLSchema> with the PML instance (this method should
not be used for an instance containing data).

=item $pml->get_schema_url ()

Return URL of the PML schema file associated with the PML instance.

=item $pml->set_schema_url (url)

Change URL of the PML schema file associated with the PML instance.

=item $pml->get_root ()

Return the root data structure.

=item $pml->set_root (object)

Set the root data structure.

=item $pml->get_trees ()

Return a C<Fslib::List> object containing data structures with role
'#NODE' belonging in the first block (list or sequence) with role
'#TREES' occuring in the PML instance.

=item $pml->get_trees_prolog ()

If the PML instance consists of a sequence with role '#TREES', return a
C<Fslib::Seq> object containing the maximal (but possibly empty)
initial segment of this sequience consisting of elements with role
other than '#NODE'.

=item $pml->get_trees_epilog ()

If the PML instance consists of a sequence with role '#TREES', return
a C<Fslib::Seq> object containing all elements of the sequence
following the first maximal contiguous subsequence of elements with
role '#NODE'.

=item $pml->get_trees_type ()

Return the type declaration associated with the list of trees.

=item $pml->get_references_hash ()

Returns a HASHref mapping file reference IDs to URLs.

=item $pml->set_references_hash (\%map)

Set a given HASHref as a map between refrence IDs and URLs.

=item $pml->get_refname_hash ()

Returns a HASHref mapping file reference names to reference IDs.

=item $pml->set_refname_hash (\%map)

Set a given HASHref as a map between refrence IDs and URLs.

=item $pml->get_ref (id)

Return a DOM or PMLInstance object representing the referenced
resource with a given ID (applies only to resources declared as
readas='dom' or readas='pml').

=item $pml->set_ref (id,object)

Use a given DOM or PMLInstance object as a resource of the current
PMLInstance with a given ID (note that this may break knitting).

=back

=head1 SEE ALSO

L<Fslib>, L<PMLSchema>, 
PML spec - L<http://ufal.mff.cuni.cz/jazz/PML/doc>,
TrEd - L<http://ufal.mff.cuni.cz/~pajas/tred>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
