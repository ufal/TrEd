# -*- cperl -*-

#ifndef PML_A
#define PML_A

#include "PML.mak"

package PML_A;

#encoding iso-8859-2

import PML;
sub first (&@);

=pod

=head1 PML_A

PML_A.mak - Miscelaneous macros for analytic layer of Prague
Dependency Treebank (PDT) 2.0.

=head2 REFERENCE

=over 4

=cut


#ifdef TRED

=item tectogrammatical_tree()

This function is only available in TrEd (i.e. in GUI). After a
previous call to C<analytical_tree>, it switches current view back to
a tectogrammatical tree which refers to the current analytical tree.

=cut

sub tectogrammatical_tree {
  return unless schema_name() eq 'adata';
  return unless switch_to_tfile();
  if (CurrentContext() eq 'PML_A_Edit') {
    SwitchContext('PML_T_Edit');
  } else {
    SwitchContext('PML_T_View');
  }
  SetCurrentStylesheet($PML_T::laststylesheet || 'PML_T_Compact');
  undef$PML_T::laststylesheet;
  my $fsfile = $grp->{FSFile};
  my $id = $root->{id};
  my $this_id = $this->{id};
  #find current tree and new $this
  my $trees = $fsfile->treeList;
 TREE: for ($i=0;$i<=$#$trees;$i++) {
    foreach my $a_rf (ListV($trees->[$i]->{'a.rf'})) {
      $a_rf =~ s/^.*\#//;
      if ($a_rf eq $id) {
	$grp->{treeNo} = $i;
	$fsfile->currentTreeNo($i);
	print "Found $a_rf at tree position $i\n";
	last TREE;
      }
    }
  }
  $root = $fsfile->tree($grp->{treeNo});
  my $node=$root;
  while ($node) {
    if (first { $_ eq $this_id }
	  map { local $_=$_; s/^.*\#//; $_ }
	    ListV($node->{'a.rf'})) {
      $this = $node;
      last;
    }
  } continue {
    $node = $node->following;
  };
  ChangingFile(0);
}
sub switch_to_tfile {
  my $fsfile = $grp->{FSFile};
  return 0 unless $fsfile or schema_name() ne 'adata';
  my $tr_fs = $fsfile->appData('tdata');
  return 0 unless ref($tr_fs);
  $grp->{FSFile} = $tr_fs;
  return 1;
}

#endif TRED


=item expand_coord($node,$keep?)

If the given node is coordination or aposition (according to its
Analytical function - attribute C<afun>) expand it to a list of
coordinated nodes. Otherwise return the node itself. If the argument
C<keep> is true, include the coordination/aposition node in the list
as well.

=cut

sub expand_coord {
  my ($node,$keep)=@_;
  return unless $node;
  if ($node->{afun}=~/Coord|Apos/) {
    return (($keep ? $node : ()),
	    map { expand_coord($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #expand_coord

=item get_sentence_string($tree?)

Return string representation of the given tree (suitable for
Analytical trees).

=cut

sub get_sentence_string {
  my $node = $_[0]||$this;
  $node=$node->root->following;
  my @sent=();
  while ($node) {
    push @sent,$node;
    $node=$node->following();
  }
  return join('',map{
    $_->{'m'}{form}.($_->{'m'}{'w'}{no_space_after}?'':' ')
  } sort { $a->{ord} <=> $b->{ord} } @sent);
}#get_sentence_string

=item dive_AuxCP($node)

You can use this function as a C<through> argument to GetFathers and
GetChildren. It skips all the prepositions and conjunctions when
looking for nodes which is what you usually want.

=cut

sub dive_AuxCP ($){
  $_[0]->{afun}=~/x[CP]/
}#dive_AuxCP

=item GetFathers($node,$through)

Return linguistic parent of a given node as appears in an analytic
tree. The argument C<$through> should supply a function accepting one
node as an argument and returning true if the node should be skipped
on the way to parent or 0 otherwise. The most common C<dive_AuxCP> is
provided in this package.

=cut

sub _expand_coord_GetFathers { # node through
  my ($node,$through)=@_;
  my @toCheck = $node->children;
  my @checked;
  while (@toCheck) {
    @toCheck=map {
      if (&$through($_)) { $_->children() }
      elsif($_->{afun}=~/Coord|Apos/&&$_->{is_member}){ _expand_coord_GetFathers($_,$through) }
      elsif($_->{is_member}){ push @checked,$_;() }
      else{()}
    }@toCheck;
  }
  return @checked;
}# _expand_coord_GetFathers

sub GetFathers { # node through
  my ($node,$through)=@_;
  my $init_node = $node; # only used for reporting errors
  if ($node->{is_member}) { # go to coordination head
    while ($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}) {
      $node=$node->parent;
      if (!$node) {
	print STDERR
	  "GetFathers: Error - no coordination head $init_node->{AID}: ".ThisAddress($init_node)."\n";
        return();
      } elsif($node->{afun}eq'AuxS') {
	print STDERR
	  "GetFathers: Error - no coordination head $node->{AID}: ".ThisAddress($node)."\n";
        return();
      }
    }
  }
  if (&$through($node->parent)) { # skip 'through' nodes
    while (&$through($node->parent)) {
      $node=$node->parent;
    }
  }
  $node=$node->parent;
  return $node if $node->{afun}!~/Coord|Apos/;
  _expand_coord_GetFathers($node,$through);
} # GetFathers

=item GetChildren($node,$dive)

Return a list of nodes linguistically dependant on a given
node. C<$dive> is a function which is called to test whether a given
node should be used as a terminal node (in which case it should return
false) or whether it should be skipped and its children processed
instead (in which case it should return true). Most usual treatment is
provided in C<dive_AuxCP>. If C<$dive> is skipped, a function returning 0
for all arguments is used.

=cut

sub FilterSons{ # node dive suff from
  my ($node,$dive,$suff,$from)=@_;
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; # comment this line to get all members
    unless ($node==$from){ # on the way up do not go back down again
      if (!$suff&&$node->{afun}=~/Coord|Apos/&&!$node->{is_member}
	  or$suff&&$node->{afun}=~/Coord|Apos/&&$node->{is_member}) {
	push @sons,FilterSons($node,$dive,1,0)
      } elsif (&$dive($node) and $node->firstson){
	push @sons,FilterSons($node,$dive,$suff,0);
      } elsif(($suff&&$node->{is_member})
	      ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node;
      }
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons

sub GetChildren{ # node dive
  my ($node,$dive)=@_;
  my @sons;
  my $from;
  $dive = sub { 0 } unless defined($dive);
  push @sons,FilterSons($node,$dive,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}){
      $from=$node;$node=$node->parent;
      push @sons,FilterSons($node,$dive,0,$from);
    }
    if ($node->{afun}eq'AuxS'){
      print STDERR "Error: Missing Coord/Apos: $node->{id} ".ThisAddress($node)."\n";
      @sons=@oldsons;
    }
  }
  return@sons;
} # GetChildren

=item create_stylesheets()

Creates default stylesheet for PML analytical files unless already
defined. Most of the colors it uses can be redefined in the tred
config file C<.tredrc> by adding a line of the form

  CustomColorsomething = ...

The stylesheet is named C<PML_A> and it has the following display
features:

=over 4

1. sentence is displayed in C<CustomColorsentence>. If the form was
changed (e.g. because of a typo), the original form is displayed in
C<CustomColorspell> with overstrike.

2. analytical function is displayed in C<CustomColorafun>. If the
node's C<is_member> is set to 1, the type of the structure is
indicated by C<Co> (coordination) or C<Ap> (apposition) in
C<CustomColorcoappa>. For C<is_parenthesis_root>, C<Pa> is displayed
in the same color.

=back

=cut

sub create_stylesheets {
  unless(StylesheetExists('PML_A')){
    SetStylesheetPatterns(<<'EOF','PML_A',1);
text:<? $${m/w/token}eq$${m/form} ? '#{'.CustomColor('sentence').'}${m/w/token}' : '#{-over:1}#{'.CustomColor('spell').'}[${m/w/token}]#{-over:0}#{'.CustomColor('sentence').'}${m/form}' ?>

node:<? $${afun} eq "AuxS" ? '${id}' : '${m/form}' ?>

node:#{customafun}${afun}<?
  if ($${is_member}) {
    my $p=$this->parent;
    $p=$p->parent while $p and $p->{afun}=~/^Aux[CP]$/;
    ($p and $p->{afun}=~/^(Ap)os|(Co)ord/ ? "_#{customcoappa}\${is_member=$1$2}" : "_#{customerror}\${is_member=ERR}")
  } else { "" }
?><? '#{customcoappa}_${is_parenthesis_root=Pa}'if$${is_parenthesis_root}?>
EOF
  }
}

sub get_status_line_hook {
  # get_status_line_hook may either return a string
  # or a pair [ field-definitions, field-styles ]
  return unless $this;
  return [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "     id: " => [qw(label)],
	   $this->{id} => [qw({id} value)],
           ($this->parent
            ?
            ("     m/lemma: " => [qw(label)],
             $this->{'m'}{lemma} => [qw({m/lemma} value)],
             "     m/tag: " => [qw(label)],
             $this->{'m'}{tag} => [qw({m/tag} value)])
            :''),
	  ],

	  # field styles
	  [
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	  ]
	 ];
}

sub allow_switch_context_hook {
  return 'stop' if schema_name() ne 'adata';
}
sub switch_context_hook {
  create_stylesheets();
  SetCurrentStylesheet('PML_A') if GetCurrentStylesheet() eq STYLESHEET_FROM_FILE();
}



1;

=back

=cut

#endif PML_A
