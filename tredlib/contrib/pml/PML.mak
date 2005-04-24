# -*- cperl -*-

#ifndef PML
#define PML

package PML;

#encoding iso-8859-2

import TredMacro;
sub first (&@);

=pod

=head1 PML

PML.mak - Miscelaneous macros of general use in Prague Dependency
Treebank (PDT) 2.0

=over 4

=item SchemaName()

Return name of the PML schema associated with the current file. PDT
typically uses PML Schema named C<adata> for analytical annotation and
C<tdata> for tectogrammatical annotation.

=cut

sub SchemaName {
  my $schema = &Schema;
  return undef unless $schema;
  return $schema->{root}->{name};
} #SchemaName

=item Schema($fsfile?)

Return PML schema associated with a given (or the current) file
(Fslib::Schema object).

=cut

sub Schema {
  my $fsfile = $_[0] || $grp->{FSFile};
  return undef unless $fsfile;
  return $grp->{FSFile}->metaData('schema');
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
  my$id=$_[0];
  my$found;
  my$treeNo=CurrentTreeNumber();
  my $tree = $this->root;
  unless($found = first{ $_->{id} eq $id } $tree->descendants,$tree){
    #we have to look into another trees
    my @trees=GetTrees();
    my $maxnum=$#trees;
    my($step_l,$step_r)=($treeNo>0 ? 1 : 0, $treeNo<$maxnum ? 1 : 0);
    while($step_l!=0 or $step_r!=0){
      if($step_l){
        if ($found=first { $_->{id} eq $id } $trees[$treeNo-$step_l]->descendants){
          $treeNo=$treeNo-$step_l;
	  last;
        }
        $step_l=0 if ($treeNo-(++$step_l))<0;
      }
      if($step_r){
        if ($found=first { $_->{id} eq $id } $trees[$treeNo+$step_r]->descendants){
          $treeNo=$treeNo+$step_r;
          last;
        }
        $step_r=0 if ($treeNo+(++$step_r))>$maxnum;
      }
    }
  }
  return($found,++$treeNo);
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
    for ($i=0;$i<=$#$trees;$i++) {
      my $node = $trees->[$i];
      while ($node) {
	$ids{ $node->{id} } = $node;
      } continue {
	$node = $node->following;
      }
    }
    $fsfile->changeAppData('id-hash',\%ids);
  }
  $fsfile->appData('id-hash');
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
  }else{ # id
    for(my$i=0;$i<@trees;$i++){
      if($trees[$i]->{id} =~ /\Q$to\E$/){
        TredMacro::GotoTree($i+1);
        last;
      }
    }
  }
  ChangingFile(0);
}#GotoTree

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


  my ($top,$ord,$filterNode,$returnParents,$subord,$filterGap) = @_;
  $top = $root unless ref($top);

  $ord = $grp->{FSFile}->FS->order() unless defined($ord);
  $filterNode = sub { 1 } unless defined($filterNode);
  $returnParents = sub { return $_[0]->parent ? ($_[0]->parent) : () } unless defined $returnParents;
  $subord = sub { my ($n,$top) = @_;
		  while ($n->parent and $n!=$top) {$n=$n->parent};
		  return ($n==$top) ? 1 : 0; # returns 1 if true, 0 otherwise
		} unless defined($subord);
  $filterGap = sub { 1 } unless defined($filterGap);

  my %npedges;

  # get the nodes of the subtree
  my @subtree = sort {$a->{$ord} <=> $b->{$ord}} ($top->descendants, $top);

  # just store the index in the subtree in a special attribute of each node
  for (my $i=0; $i<=$#subtree; $i++) {$subtree[$i]->{'_proj_index'} = $i}

  # now check all the edges of the subtree (but only those accepted by filterNode
  foreach my $node (grep {&$filterNode($_)} @subtree) {

    next if ($node==$top); # skip the top of the subtree

    foreach my $parent (&$returnParents($node)) {

      # span of the current edge
      my ($l,$r)=($node->{'_proj_index'}, $parent->{'_proj_index'});

      # set the boundaries of the interval covered by the current edge
      if ($l > $r) { ($l,$r) = ($r,$l) };

      # check all nodes covered by the edge
      for (my $j=$l+1; $j<$r; $j++) {

	my $gap=$subtree[$j]; # potential node in gap
	# mark a non-projective edge and save the node causing the non-projectivity (ie in the gap)
	if (not(&$subord($gap,$parent)) and &$filterGap($gap)) {
	  my $key=scalar($node).scalar($parent);
	  if (exists($npedges{$key})) { push @{$npedges{$key}}, $gap }
	  else { $npedges{$key} = [$node, $parent, $gap] };
	} # unless

      } # for $j

    } # foreach $parent

  } # foreach $node

  return \%npedges;

} # sub NonProjEdges

#ifdef TRED

{ my@CustomColors=qw/error red
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

#endif TRED

1;

=back

=cut

#endif PML
