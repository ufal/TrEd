# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.

#encoding iso-8859-2

BEGIN {
  import TredMacro;
  use Carp;
}


=pod

=head1 PML

PML.mak - Miscelaneous macros of general use in Prague Dependency
Treebank (PDT) 2.0

=over 4

=item SchemaName()

Return name of the root element of a PML instance as specified in the
PML schema associated with the current file. PDT uses root element
named C<adata> for analytical layer annotation and C<tdata> for
tectogrammatical layer annotation.

=cut

sub SchemaName {
  my $schema = &Schema;
  return undef unless $schema;
  return $schema->{root}->{name};
} #SchemaName

=item SchemaDescription()

Return the content of the element C<description> of the PML schema
associated with the current file.

=cut

sub SchemaDescription {
  my $schema = &Schema;
  return undef unless $schema;
  return $schema->{description};
} #SchemaName


=item Schema($object?)

For a FSNode object returns PML schema associated with that object.
If the object is a FSFile, return PML schema associated with the given
file. If no object is given, the current FSFile is used.

The PML schema is returned in form of a Fslib::Schema object.

=cut

sub Schema {
  my $obj = $_[0] || $grp->{FSFile};
  if (UNIVERSAL::isa($obj,'FSNode')) {
    return $obj->type ? $obj->type->schema : undef;
  } elsif (UNIVERSAL::isa($obj,'FSFile')) {
    return $obj->metaData('schema');
  } elsif (!defined($obj) and defined($grp->{FSFile})) {
    return $grp->{FSFile}->metaData('schema');
  } else {
    croak("PML::Schema: Can't derive schema from $obj\n");
  }
} #Schema

=item GetNodeByID($id_or_ref,$fsfile?)

Looks up a node from the current file (or given fsfile) by its ID (or
PMLREF - i.e. the ID preceded by a file prefix of the form C<xy#>).

=cut

sub GetNodeByID {
  my ($rf,$fsfile)=@_;
  $fsfile = $grp->{FSFile} unless defined $fsfile;
  $rf =~ s/^.*#//;
  return GetNodeHash($fsfile)->{$rf};
}

=item SearchForNodeById()

Searches for node with given id. Returns the node and the number of
the tree.

=cut

sub SearchForNodeById ($){
  my ($id)=@_;
  my ($found,$tree,$treeNo);

  my $node_hash = GetNodeHash();
  $found = $node_hash->{$id};
  my $tree = $this->root;
  if (ref($found) and (my $r = $found->root)!=$tree) {
    my @trees=GetTrees();
    $treeNo=Index(\@trees,$r);
  } else {
    $treeNo=CurrentTreeNumber();
  }
  unless ($found ||= first{ $_->{id} eq $id } ($tree,$tree->descendants)){
    #we have to look into another trees
    my @trees=GetTrees();
    my $maxnum=$#trees;
    my($step_l,$step_r)=($treeNo>0 ? 1 : 0, $treeNo<$maxnum ? 1 : 0);
    while($step_l!=0 or $step_r!=0){
      if($step_l){
        if ($found=first { $_->{id} eq $id } $trees[$treeNo-$step_l],$trees[$treeNo-$step_l]->descendants){
          $treeNo=$treeNo-$step_l;
	  last;
        }
        $step_l=0 if ($treeNo-(++$step_l))<0;
      }
      if($step_r){
        if ($found=first { $_->{id} eq $id } $trees[$treeNo+$step_r],$trees[$treeNo+$step_r]->descendants){
          $treeNo=$treeNo+$step_r;
          last;
        }
        $step_r=0 if ($treeNo+(++$step_r))>$maxnum;
      }
    }
  }
  return($found,$treeNo+1);
}#SearchForNodeById

=item GetNodeHash($fsfile?)

Return a reference to a hash indexing nodes in a given file (or the
current file if no argument is given). If such a hash was not yet
created, it is built upon the first call to this function (or other
functions calling it, such as C<GetNodeByID>. Use C<clearNodeHash> to
clear the hash.

=cut

sub GetNodeHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  return {} unless ref($fsfile);
  unless (ref($fsfile->appData('id-hash'))) {
    my %ids;
    my $trees = $fsfile->treeList;
    for (my $i=0;$i<=$#$trees;$i++) {
      my $node = $trees->[$i];
      while ($node) {
	$ids{ $node->{id} } = $node;
      } continue {
	$node = $node->following;
      }
    }
    $fsfile->changeAppData('id-hash',\%ids);
  }
  return $fsfile->appData('id-hash');
}

=item ClearNodesHash($fsfile?)

Clear the internal hash indexing nodes of a given file (or the current
file if called without an argument).

=cut

sub ClearNodesHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  $fsfile->changeAppData('id-hash',undef);
}


=item GotoTree()

Ask user for sentence identificator (number or id) and go to the
sentence.

=cut

  sub GotoTree {
    my$to=QueryString("Give a Tree Number or ID","Tree Identificator");
    my @trees = GetTrees();
    if($to =~ /^[0-9]+$/){ # number
      TredMacro::GotoTree($to) if $to <= @trees and $to != 0;
    } else{ # id
      for(my$i=0;$i<@trees;$i++){
	if($trees[$i]->{id} =~ /\Q$to\E$/){
	  TredMacro::GotoTree($i+1);
	  last;
	}
      }
    }
    ChangingFile(0);
  }#GotoTree

=item NonProjEdges($node,$ord?,$filterNode?,$returnParents?,$subord?,$filterGap?)

Returns hash-ref containing all non-projective edges in the subtree
rooted in $node. Values of the hash are references to arrays
containing the non-projective edges (the arrays contain the lower and
upper nodes representing the edge, and then the nodes causing the
non-projectivity of the edge), keys are concatenations of stringified
references to lower and upper nodes of non-projective edges. (The
function just wraps PDT::non_proj_edges.) Description of the arguments
is as follows: $node specifies the root of a subtree to be checked for
non-projective edges; $ord specifies the ordering attribute to be
used; a subroutine accepting one argument passed as sub-ref in
$filterNode can be used to filter the edges taken into account (by
specifying the lower nodes of the edges); sub-ref $returnParents
accepting one argument returns an array of upper nodes of the edges to
be taken into account; sub-ref $subord accepting two arguments returns
1 iff the first one is subordinated to the second one; sub-ref
$filterGap accepting one argument can be used to filter nodes causing
non-projectivity.  Defaults are: the default ordering attribute, all
nodes, parent (in the technical representation), subordination in the
technical sense, all nodes.

=cut

sub NonProjEdges {
# arguments are: root of the subtree to be projectivized
# the ordering attribute
# sub-ref to a filter accepting a node parameter (which nodes of the subtree should be skipped)
# sub-ref to a function accepting a node parameter returning a list of possible upper nodes
# on the edge from the node
# sub-ref to a function accepting two node parameters returning one iff the first one is
# subordinated to the second
# sub-ref to a filter accepting a node parameter for nodes in a potential gap

# returns a reference to a hash in which all non-projective edges are returned
# (keys being the lower nodes concatenated with the upper nodes of non-projective edges,
# values references to arrays containing the node, the parent and nodes in the respective gaps)

  my $top=shift;

  return undef unless ref($top);

  return PDT::non_proj_edges($top,0,@_);

} # sub NonProjEdges

#ifdef TRED

{ my@CustomColors=qw/error red
                     mlemma blue
                     form black
                     tag darkgreen
                     lemma black
                     current red
                     sentence black
                     spell gray
                     status darkblue
                     tfa_text darkcyan
                     tfa_t white
                     tfa_f yellow
                     tfa_c green
                     tfa_no #c0c0c0
                     func #601808
                     subfunc #a02818
                     afun darkblue
                     coappa blue
                     parenthesis #809080
                     nodetype darkblue
                     complex darkmagenta
                     detail darkgreen
                     detailheader #002416
                     coref darkblue
                     arrow_textual #4C509F
                     arrow_grammatical #C05633
                     arrow_segment darkred
                     arrow_compl #629F52
                     arrow_exoph blue
                     line_normal #7f7f7f
                     line_member #a0a0a0
                     line_comm #6F11EA/;
  while(@CustomColors){
    my$key=shift(@CustomColors);
    my$val=shift(@CustomColors);
    unless (CustomColor($key)) {
      CustomColor($key,$val);
    }
  }
}

# context guessing

push @TredMacro::AUTO_CONTEXT_GUESSING, sub {
  my ($hook)=@_;
  my $resuming = ($hook eq 'file_resumed_hook');
  my $current = CurrentContext();
  if (PML::SchemaName() eq 'tdata') {
    SetCurrentStylesheet(STYLESHEET_FROM_FILE()) if $resuming;
    if ($current eq 'PML_A_Edit') {
      return 'PML_T_Edit';
    } elsif ($current =~ /^PML.*_T_/) {
      return $current;
    } else {
      return 'PML_T_View';
    }
  } elsif (PML::SchemaName() eq 'adata') {
    SetCurrentStylesheet(STYLESHEET_FROM_FILE()) if $resuming;
    if ($current eq 'PML_T_Edit') {
      return 'PML_A_Edit';
    } elsif ($current =~ /^PML.*_A_/) {
      return $current;
    } else {
      return 'PML_A_View';
    }
    return 1;
  } elsif (PML::SchemaName() eq 'aeditdata') {
    SetCurrentStylesheet(STYLESHEET_FROM_FILE()) if $resuming;
    return 'PML_A_Edit';
  } elsif (PML::SchemaName() eq 'mdata') {
    SetCurrentStylesheet(STYLESHEET_FROM_FILE()) if $resuming;
    if ($current =~ /^PML.*_M_/) {
      return $current;
    } else {
      return 'PML_M';
    }
  }
  return;
};

#endif TRED

=back

=cut
