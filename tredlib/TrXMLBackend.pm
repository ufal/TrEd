## This is a XML backend for FSLib                           -*-cperl-*-
## author: Petr Pajas
# Time-stamp: <2001-08-27 16:20:46 pajas>

#############################################################

package TrXMLParser;

use Unicode::MapUTF8 qw(from_utf8);
use XML::LibXML;
use vars qw($state %defs @attlist @trees $node $attr $parent);

$state=0;
%defs=();
@attlist=();
@trees=();
$node=undef;
$attr=undef;
$parent=undef;

sub StartDocument {
}

sub EndDocument {
}

sub Attlist {
  my ($parser,$el,$at,$type,$def,$fixed)=@_;
  if ($el eq 'nd') {
    push @attlist,$at;
  }
}

sub StartTag {
  my ($parser,$elem)=(shift,shift);
  if ($TrXMLParser::state==0 and $elem eq 'trees') {
    $TrXMLParser::state=1;	# in trees
    return;
  }
  if ($TrXMLParser::state==1 and $elem eq 'meta') {
    $TrXMLParser::state=2;	# in meta
    return;
  }
  if ($TrXMLParser::state==1 and $elem eq 'types') {
    $TrXMLParser::state=3;	# in types
    return;
  }
  if ($TrXMLParser::state==3) {
    push @TrXMLParser::attlist,$_{n};
    if ($elem eq 't') {
#        if ($_{pos}) {
#  	$TrXMLParser::defs{$_{n}}.=' P';
#        }
#        if ($_{obl}) {
#  	$TrXMLParser::defs{$_{n}}.=' O';
#        }
#        if ($_{val}) {
#  	$TrXMLParser::defs{$_{n}}.=' V';
#        }
#        if ($_{ordw}) {
#  	$TrXMLParser::defs{$_{n}}.=' W';
#        }
#      $TrXMLParser::defs{$_{n}}=' K' unless $TrXMLParser::defs{$_{n}};
#    } elsif ($elem eq 'l') {
#      if ($_{pos}) {
#  	$TrXMLParser::defs{$_{n}}.=' P';
#        }
#        if ($_{obl}) {
#  	$TrXMLParser::defs{$_{n}}.=' O';
#        }
#        if ($_{v}) {
#  	$TrXMLParser::defs{$_{n}}.=' L='.from_utf8({-string => $_{v}, -charset => 'ISO-8859-2'});
#        }
#        $TrXMLParser::defs{$_{n}}=' K' unless $TrXMLParser::defs{$_{n}};
      $TrXMLParser::defs{$_{n}}.=' P';
      if ($_{v} ne "") {
	$TrXMLParser::defs{$_{n}}.=' L='.from_utf8({-string => $_{v}, -charset => 'ISO-8859-2'});
      }
    }
  }
  if ($TrXMLParser::state==1 || $TrXMLParser::state==4 and $elem eq 'nd') {
    my $new = FSNode->new();
    if ($TrXMLParser::node) {
      #add new as a last son of node
      my $n=$TrXMLParser::node->firstson;
      Fslib::SetParent($new,$TrXMLParser::node);
      if ($n) {
	$n=$n->rbrother while ($n->rbrother);
	Fslib::SetRBrother($n,$new);
	Fslib::SetLBrother($new,$n);
      } else {
	Fslib::SetFirstSon($TrXMLParser::node,$new);
      }
    } else {
      push @TrXMLParser::trees, $new;
    }
    $TrXMLParser::node=$new;
    $TrXMLParser::node->{ORD}=$_{n};
    $TrXMLParser::node->{HIDE}='hide'x$_{h};
    $TrXMLParser::node->{ID}=$_{id};
    foreach (keys(%_)) {
      $node->{$_}=from_utf8({-string => $_{$_}, -charset => 'ISO-8859-2'})
	unless ($_ eq "h" or $_ eq "id" or $_ eq "n");
    }
    $TrXMLParser::state=4;	# in nd
    return;
  }
}

sub EndTag {
  my ($parser,$elem)=@_;
  if ($TrXMLParser::state==1  and $elem eq 'trees') {
    $TrXMLParser::state=0;	# end of trees
    return;
  }
  if ($TrXMLParser::state==2 and $elem eq 'meta') {
    $TrXMLParser::state=1;	# end of meta
    return;
  }
  if ($TrXMLParser::state==3 and $elem eq 'types') {
    $TrXMLParser::state=1;	# end of types
    push @TrXMLParser::attlist, 'ORD','HIDE';
    $TrXMLParser::defs{HIDE}.=' H';
    $TrXMLParser::defs{ORD}.=' N';
    return;
  }
  if ($TrXMLParser::state==4 and $elem eq 'nd') {
    $TrXMLParser::node=$TrXMLParser::node->parent
      if ($TrXMLParser::node);
    $TrXMLParser::state=1 unless ($TrXMLParser::node);
  }
}

sub Text {
}

sub pi {
  # process tred's specific instructions, like attribute patterns,
  # which attributes are used as @W and @V etc.
}


#############################################################

package TrXMLBackend;

use Fslib;
use XML::Writer;
use XML::Parser;
use Carp;

@ISA=qw(ZBackend);
import ZBackend;


=item write (glob_ref,$fsfile)

Write FSFile in a tree-XML format (file handle open for reading must be passed
as a GLOB reference).

=cut

sub write {
  my ($fileref,$fs) = @_;
  return 0 unless ref($fileref) and ref($fs);

  my $writer = new XML::Writer(OUTPUT => $fileref, DATA_MODE => 1, DATA_INDENT => 1);
  $writer->{DOCTYPE} = sub {
    my ($name, $publicId, $systemId, $localDTD) = (@_);
    $fileref->print("<!DOCTYPE $name");
    if ($publicId) {
      $fileref->print(" PUBLIC \"$publicId\" \"$systemId\"");
    } elsif ($systemId) {
      $fileref->print(" SYSTEM \"$systemId\"");
    }
    if ($localDTD) {
      $fileref->print(" [\n$localDTD\n]");
    }
    $fileref->print(">\n");
  };

  $writer->xmlDecl('iso-8859-2');
  $writer->doctype("trees",
		   "-//CKL.MFF.UK//DTD TrXML V1.0//EN",
		   "http://ufal.mff.cuni.cz/~pajas/tred.dtd",
                   "<!ENTITY % trxml.attributes \"".
		   join("\n",map { "  $_ CDATA #IMPLIED" }
			$fs->FS->attributes).
		   "\">");
  $writer->comment("Time-stamp: <".localtime()." TrXMLBackend>");
  $writer->startTag("trees");
  XMLPrintTypes($fs->FS->list, $fs->FS->defs,$writer);
  foreach my $tree ($fs->trees) {
    XMLPrintTree($tree,$fs->FS->list, $fs->FS->defs,$writer);
  }
  $writer->endTag("trees");
  $writer->end();
  return 1;
}

sub XMLPrintTypes {
  my ($ord,			# a reference to the ord-array
      $atr,			# a reference to the attribute-hash
      $output			# XML Writer object reference
     )=@_;

  my $list;
  my $atrs;
  $output->startTag('types','full'=>1);
  foreach (@$ord) {
    %atrs=();
    $list=Fslib::IsList($_,$atr);
    $atrs{n}=$_;
#    $atrs{obl}=1 if (index($atr->{$_}," O")>=0);
#    $atrs{pos}=1 if (index($atr->{$_}," P")>=0);
    if ($list) {
      $atrs{v}=join"|",Fslib::ListValues($_,$atr);
    } #else {
# implement as TrEd's processing instructions?
#      $atrs{val}=1 if (index($atr->{$_}," V")>=0);
#      $atrs{ordw}=1 if (index($atr->{$_}," W")>=0);
#    }
    $output->emptyTag('t',%atrs);
  }
  $output->endTag('types');
}

sub XMLPrintNode {
  my ($node,			# a reference to the root-node
      $ord,			# a reference to the ord-array
      $atr,			# a reference to the attribute-hash
      $output			# XML Writer object reference
     )=@_;
  my $v;
  my $natr=Fslib::ASpecial($atr,"N");
  my $hatr=Fslib::ASpecial($atr,"H");

  if ($node) {
    $output->startTag('att');
    for (my $n=0; $n<=$#$ord; $n++) {
      $v=$node->{$ord->[$n]};
      next if ($ord->[$n] eq $natr
	       or
	       $ord->[$n] eq $hatr and $v eq 'hide'
	       or $v eq '' or not defined($v));
      if (defined($v)) {
	$output->startTag('a',n => $ord->[$n]);
	$output->characters($v);
	$output->endTag('a');
      }
    }
    $output->endTag('att');
  }
}

sub XMLPrintTree {
  my ($curr,			# a reference to the root-node
      $rord,			# a reference to the ord-array
      $ratr,			# a reference to the attribute-hash
      $output			# XML Writer object reference
     )=@_;
  my $natr=Fslib::ASpecial($ratr,"N");
  my $hatr=Fslib::ASpecial($ratr,"H");
  return unless $output;
  my $root=$curr;
  while ($curr) {
    # id should be processed here
    $output->startTag('nd',
		      defined($curr->{$natr}) ?
		      ('n' => $curr->{$natr}) : (),
		      $curr->{$hatr} eq 'hide' ?
		      ('h' => 1) : (),
                      map { ($curr->{$_} eq "") ? () : ($_ => $curr->{$_}) } @$rord
		     );
#    XMLPrintNode($curr,$rord,$ratr,$output);
    if ($curr->firstson) {
      $curr = $curr->firstson;
      redo;
    }
    $output->endTag('nd');
    while ($curr && $curr != $root && !($curr->rbrother)) {
      $output->endTag('nd');
      $curr = $curr->parent;
    }
    croak "Error: NULL-node within the tree while printing\n" if !$curr;
    last if ($curr == $root || !$curr);
    $curr = $curr->rbrother;
    redo;
  }
}

=item read (glob_ref,$fsfile)

Read FSFile from tree-XML file (file handle open for reading must be
passed as a GLOB reference). Return 1 on success 0 on fail.

=cut

sub read {
  my ($fileref,$fsfile) = @_;
  return unless ref($fsfile);


  my $parser=new XML::Parser(Style=>'Stream', Pkg => 'TrXMLParser',ProtocolEncoding=>'iso-8859-2');
  $parser->parse(*$fileref);

  $fsformat = new FSFormat({%TrXMLParser::defs},
			   [@TrXMLParser::attlist], undef);
  $fsfile->changeFS($fsformat);
  $fsfile->changeTrees(@TrXMLParser::trees);

  # forget it
  $TrXMLParser::state=0;
  %TrXMLParser::defs=();
  @TrXMLParser::attlist=();
  @TrXMLParser::trees=();
  $TrXMLParser::node=undef;
  $TrXMLParser::attr=undef;
  $TrXMLParser::parent=undef;
  return 1;
}

=item test (filehandle | filename)

Test if given file is in Tree XML format. If the argument is a
file-handle the filehandle is supposed to be open by previous call to
C<open_backend>.  In this case, the calling application may need to
close the handle and reopen it in order to seek the beginning of the
file after the test has read few characters or lines from it.

=cut

sub test {
  my ($f)=@_;
  if (ref($f)) {
    return $f->getline()=~/\<\?xml /;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}


1;
