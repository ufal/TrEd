package AG2FS;

use Fslib;
use strict;
use XML::LibXML;
use XML::LibXML::Common qw(:encoding);
use Text::Iconv;
use vars qw(@agformat @agpatterns $aghint $encoding);

$encoding='windows-1256';

@agformat = (
'@P translit',
'@P form',
'@P lemma',
'@P tag',
'@P label',
'@V origf',
'@P origf',
'@P trace',
'@P mstag',
'@P start',
'@P end',
'@N ord',
'@N sortord',
'@P lookup',
'@P lookup',
'@P comment',
'@P id',
'@P gloss',
'@P solutionno',
'@P agID',
'@P tbcomment',
'@P para',
);

@agpatterns = (
'<?$${form} unless $${form} eq \'???\' ?>${trace}${label}',
'style:#{Line-coords:n,n,n,p&n,p,p,p}'
);

$aghint="lemma:\t\${lemma}\ntag:\t\${tag}\ngloss:\t\${gloss}\ncomment:\t\${comment}\n".
  "tbcomment:\t\${tbcomment}\nsentord:\t\${sordord}";


=item open_backend (filename,mode)

Only reading is supported now!

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  return $filename;
#   my $fh = undef;

#   if ($mode =~/[w\>]/) {
#     print STDERR "Error: Writing not supported by this backend!\n";
#   } else {
#     eval {
#       my $ok=open($fh,$filename) && $fh;
#       binmode($fh,":utf8") if ($ok && $]>=5.008);
#       $ok
#     } || do {
#       print STDERR "AG2FS error while openning $filename\n" if $!;
#       print STDERR "error: $!\n" if $!;
#       return undef;
#     };
#   }
#   return $fh;
}

=pod

=item close_backend (filehandle)

Close given filehandle opened by previous call to C<open_backend>

=cut

sub close_backend {
  my ($fh)=@_;
  return $fh->close() if ref($fh);
}

=pod

=item read (handle_ref,fsfile)

=cut

sub compute_ord {
  my ($node)=@_;
  if ($node->firstson()) {
    my $sum=0;
    my $count=0;
    foreach my $son ($node->children()) {
      compute_ord($son);
      $sum+=$son->{ord};
      $count++;
    }
    $node->{ord}=($sum/$count+0.00001);
  }
}

# convert translitaration to windows-1256 arabic script
sub detransliterate {
  my ($s)=@_;
  $s=~s/\(null\)//g;
  $s=~s/[auio~FKN]//g;
  $s=~tr['|>&<}AbptvjHxd*rzs$SDTZEg_fqklmnhwYyFNKaui~o`{]
    [\xC1-\xD6\xD8-\xDF\xE1\xE3-\xE6\xEC\xED\xF0-\xF3\xF5\xF6\xF8\xFA\xF3\xC7];

  return $s;
}

sub xp {
  my ($node,$xp)=@_;
  return decodeFromUTF8($encoding,$node->findvalue($xp));
}

sub read {
  my ($input, $fsfile)=@_;
  die "Filename required, not a reference ($input)!" if ref($input);
  return unless ref($fsfile);

  $fsfile->changeFS(FSFormat->create(@agformat));
  $fsfile->changeTail("(1)\n");
  $fsfile->changePatterns(@agpatterns);
  $fsfile->changeHint($aghint);


  my $parser = XML::LibXML->new();
  $parser->load_ext_dtd(1);
  $parser->validation(0);
  my $agdom = eval { $parser->parse_file($input); };
  print STDERR "$@\n$agdom\n" if $Fslib::Debug;
  unless ($agdom) {
    print STDERR "Error parsing ",$fsfile->filename(),". Aborting!\n";
    return 0;
  }
  $agdom->validate();
  $agdom->getDocumentElement()->setAttribute('xmlns:ag','http://www.ldc.upenn.edu/atlas/ag/');
  my $sigfile = $agdom->findvalue( q{ string(//ag:Signal/@xlink:href) } );
  unless (-f $sigfile) {
    ( $sigfile ) = ( $sigfile=~m{([^/]+)$} ); # strip the filename
  }

  my $sigfh;
  if ($sigfile !~ m(/)) {
    my ($input_dir)=($input=~m(^(.*?/)[^/]+$));
    $sigfile=$input_dir.$sigfile;
  }
  unless (open($sigfh,$sigfile)) {
    print STDERR "Can't open $sigfile. Aborting!\n";
    return 0;
  }
  my $sigdom=eval { $parser->parse_string("<?xml version='1.0' encoding='utf-8'?>\n".
					  "<!DOCTYPE DOC [\n".
					  "<!ENTITY HT ''>\n".
					  "<!ENTITY QC ''>\n".
					  "]>".join("",<$sigfh>)
					 ) };
  close ($sigfh);
  print STDERR "$@\n";
  unless ($sigdom) {
    print STDERR "Error parsing $sigfile. Aborting!\n";
    return 0;
  }

  foreach my $ag ($agdom->findnodes( q{ //ag:AG } )) {
    my $agid=decodeFromUTF8($encoding,$ag->getAttributeNode('id')->getValue);
    my $tree=xp($ag,q{ string(descendant::ag:OtherMetadata[@name='treebanking']|
                              descendant::ag:MetadataElement[@name='treebanking']) });
    my $para=xp($ag,q{ string(descendant::ag:OtherMetadata[@name='paragraph']|
                              descendant::ag:MetadataElement[@name='paragrah']) });
    my $comment=xp($ag,q{ string(descendant::ag:OtherMetadata[@name='tbcomment']|
                                 descendant::ag:MetadataElement[@name='tbcomment']) });

    my $paratxt=xp($sigdom, qq{ string(//P[$para]) });
    $paratxt=~s/^\n//;
    my @nodes;

    foreach my $annotation ($ag->findnodes( q{ descendant::ag:Annotation[@type='word'] } )) {
      my $start=xp($annotation, q{ string(id(@start)/@offset) });
      my $end=xp($annotation, q{ string(id(@end)/@offset) });
      $start=~s/\.(\d+)$//;
      $end=~s/\.(\d+)$//;

      my $node=FSNode->new();	# novy uzel
      $node->{origf}=substr($paratxt,$start,$end-$start);
      $node->{start}=$start;
      $node->{end}=$end;
      $node->{origf}=~s/\s+$//;
      $node->{lookup}=xp($annotation,q{ string(ag:Feature[@name='lookup-word']) });
      $node->{comment}=xp($annotation,q{ string(ag:Feature[@name='comment']) });
      $node->{id}=decodeFromUTF8($encoding,$annotation->getAttributeNode('id')->getValue);

      my ($selection)=
	$annotation->findnodes(q{ id(string(ag:Feature[@name='selection'])) });
      if ($selection) {
	$node->{gloss}=xp($selection,q{ string(ag:Feature[@name='gloss']) });
	$node->{solutionno}=xp($selection,q{ string(ag:Feature[@name='number']) });
	my $solution=xp($selection,q{ string(ag:Feature[@name='solution']) });
	my $lemmatag;
	($node->{translit},$lemmatag)=($solution=~m{^\(([^)]+)\)\s+(.*)$});
	my @lemmatag=split /\+/,$lemmatag;
	$node->{lemma}=join '+', map { m{^(.*)/}; $1 } @lemmatag;
	$node->{tag}=join '+',map { m{^.*/(.*)}; $1 } @lemmatag;
      }
      if ($node->{translit} ne "") {
	$node->{form}=detransliterate($node->{translit});
      } else {
	$node->{form}=$node->{origf};
      }
      push @nodes,$node;
    }
    @nodes = sort { $a->{start} <=> $b->{start} } @nodes;

    my @nts;
    my $nt=0;

    my $lastord;
    $tree=~s{ (?:(\d+)|(\*\S*))(?= )}{
      if ($1 ne "") {
	$lastord=$1;
	" $1"
      } else {
	$lastord+=0.01;
	" $lastord$2"
      }
    }eg;

    print "parsing preprocessed tree $agid:\n$tree\n\n" if $Fslib::Debug;
    my $origtree=$tree;
    while ($tree =~ s{\( ([^()]+) \)}{nt$nt}) {
      my @children=split /\s+/,$1;
      my $node=FSNode->new();
      $node->{label}=shift @children;
#      $node->{origf}='???';
      foreach (@children) {
	my $child;
	if (/^nt(\d+)$/) { 
	  $child=$nts[$1];
	} elsif (/^(\d+)$/) {
	  die "no word has index $_ in $agid:\n$origtree\n" if $_ >$#nodes;
	  $child=$nodes[$_];
	  $child->{ord}=$_+1;
	} elsif (/^(\d+(?:\.\d+))(\*.*)$/) {
	  $child=FSNode->new();
	  $child->{label}='TRACE';
	  $child->{trace}=$2;
	  $child->{ord}=$1+1;
	} else {
	  die "unrecoginzed token $_! Aborting\n";
	}
	die "malformed tree?\n" unless ref($child);
	Paste($child,$node,$fsfile->FS->defs());
      }
      $nts[$nt]=$node;
      $nt++;
    }
    my $root=pop @nts;
    if ($root) {
      $root->{agID}=$agid;
      $root->{mstag}=$agdom->URI();
      $root->{tbcomment}=$comment;
      $root->{para}=$para;
      compute_ord($root);
      my $tmpord=0;
      foreach (sort { $a->{ord} <=> $b->{ord} } $root,$root->descendants) {
	$_->{sortord}=$_->{ord};
	$_->{ord}=$tmpord++;
      }
      $fsfile->insert_tree($root,$fsfile->lastTreeNo()+1);
      my $node=$root->following;
      while ($node) {
	my $parent=$node->parent;
	if ($parent) {
#	  Cut($node);
#	  Paste($node,$parent,$fsfile->FS->defs());
	}
	$node=$node->following;
      }
    } else {
      print STDERR "Failed to create a tree from $agid\n";
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
    my $line1=$f->getline();
    my $line2=$f->getline();
    return ($line1.$line2)=~/<!DOCTYPE AGSet/;
  } else {
    my $fh = ZBackend::open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}
