# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.

#encoding iso-8859-2

BEGIN {
  import TredMacro;
  use Carp;
}

use Scalar::Util qw(weaken);

=pod

=head1 PML

PML.mak - Miscelaneous macros of general use in Prague Dependency
Treebank (PDT) 2.0

=head2 USAGE

  #include <contrib/pml/PML.mak>

=head2 MACROS

The following macros (functions) are provided by this package:

=over 4

=item PML::SchemaName()

Return name of the root element of a PML instance as specified in the
PML schema associated with the current file. PDT uses root element
named C<adata> for analytical layer annotation and C<tdata> for
tectogrammatical layer annotation.

=cut

sub SchemaName {
  my $schema = &Schema;
  return undef unless $schema;
  return $schema->get_root_name;
} #SchemaName

=item PML::SchemaDescription()

Return the content of the element C<description> of the PML schema
associated with the current file.

=cut

sub SchemaDescription {
  my $schema = &Schema;
  return undef unless $schema;
  return $schema->{description};
} #SchemaName


=item PML::Schema($object?)

For a FSNode object returns PML schema associated with that object.
If the object is a FSFile, return PML schema associated with the given
file. If no object is given, the current FSFile is used.

The PML schema is returned in form of a Fslib::Schema object.

=cut

sub Schema {
  my $obj = $_[0] || $grp->{FSFile};
  return unless defined $obj;
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

=item PML::GetNodeByID($id_or_ref,$fsfile?)

Looks up a node from the current file (or given fsfile) by its ID (or
PMLREF - i.e. the ID preceded by a file prefix of the form C<xy#>).

=cut

sub GetNodeByID {
  my ($rf,$fsfile)=@_;
  $fsfile = $grp->{FSFile} unless defined $fsfile;
  $rf =~ s/^.*#//;
  return GetNodeHash($fsfile)->{$rf};
}

=item PML::SearchForNodeById($id)

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

=item PML::GetNodeHash($fsfile?)

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
	weaken($ids{ $node->{id} } = $node);
      } continue {
	$node = $node->following;
      }
    }
    $fsfile->changeAppData('id-hash',\%ids);
  }
  return $fsfile->appData('id-hash');
}

=item PML::ClearNodesHash($fsfile?)

Clear the internal hash indexing nodes of a given file (or the current
file if called without an argument).

=cut

sub ClearNodesHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  $fsfile->changeAppData('id-hash',undef);
}


=item PML::GotoTree()

Ask user for sentence or node identificator (tree number or id) and go to the
sentence.

=cut

  sub GotoTree {
    my$to=QueryString("Give a Tree Number or ID","Tree or Node Identificator");
    my @trees = GetTrees();
    ChangingFile(0);
    if($to =~ /^(\d+)(?:\.(\d+))?$/){ # number
      my ($tree_no,$node_no) = ($1,$2);
      if ($tree_no <= @trees and $tree_no > 0) {
	my $ret = TredMacro::GotoTree($tree_no);
	$this = [$root, $root->descendants]->[$node_no] if defined $node_no and length $node_no;
	return $ret;
      }
    }elsif(length $to){ # id
      my ($node,$tree_no) = SearchForNodeById($to);
      if ($node) {
	my $ret = TredMacro::GotoTree($tree_no);
	$this=$node;
	return $ret;
      }
      # fallback: go to the first node with matching ID ending
      for my $i (0..@trees){
	if($trees[$i]->{id} =~ /\Q$to\E$/){
	  return TredMacro::GotoTree($i+1);
	}
      }
    }
  }#GotoTree

=item PML::NonProjEdges($node,$ord?,$filterNode?,$returnParents?,$subord?,$filterGap?)

DEPRECATED, use non_proj_edges from <contrib/support/non_projectivity.mak> instead.

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
  if (exists &non_proj_edges) {
    return NonProjectivity::non_proj_edges($top,0,@_);
  } else {
    confess("Module NonProjectivity (support/non_projectivity.mak) not loaded!");
  }

} # sub NonProjEdges

=back

=cut
