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

PML_A.mak - Miscellaneous macros for the analytic layer of Prague
Dependency Treebank (PDT) 2.0.

=over 4

=cut


#ifdef TRED

=item TectogrammaticalTree()

This function is only available in TrEd (i.e. in GUI). After a
previous call to C<AnalyticalTree>, it switches current view back to
a tectogrammatical tree which refers to the current analytical tree.

=cut

sub TectogrammaticalTree {
  return unless SchemaName() eq 'adata';
  return unless SwitchToTFile();
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
    foreach my $a_rf (PML_T::GetANodeIDs($node)) {
      $a_rf =~ s/^.*\#//;
      if ($a_rf eq $id) {
	$grp->{treeNo} = $i;
	$fsfile->currentTreeNo($i);
#	print "Found $a_rf at tree position $i\n";
	last TREE;
      }
    }
  }
  $root = $fsfile->tree($grp->{treeNo});
  my $node=$root;
  while ($node) {
    if (first { $_ eq $this_id } PML_T::GetANodeIDs($node)) {
      $this = $node;
      last;
    }
  } continue {
    $node = $node->following;
  };
  ChangingFile(0);
}
sub SwitchToTFile {
  my $fsfile = $grp->{FSFile};
  return 0 unless $fsfile or SchemaName() ne 'adata';
  my $tr_fs = $fsfile->appData('tdata');
  return 0 unless ref($tr_fs);
  $grp->{FSFile} = $tr_fs;
  return 1;
}
sub file_resumed_hook {
  if (SchemaName() eq 'tdata') {
    SetCurrentStylesheet(STYLESHEET_FROM_FILE());
    if (CurrentContext() eq 'PML_A_Edit') {
      SwitchContext('PML_T_Edit');
    } else {
      SwitchContext('PML_T_View');
    }
  }
}


#endif TRED


=item ExpandCoord($node,$keep?)

If the given node is coordination or aposition (according to its
Analytical function - attribute C<afun>) expand it to a list of
coordinated nodes. Otherwise return the node itself. If the argument
C<keep> is true, include the coordination/aposition node in the list
as well.

=cut

sub ExpandCoord {
  my ($node,$keep)=@_;
  return unless $node;
  if ($node->{afun}=~/Coord|Apos/) {
    return (($keep ? $node : ()),
	    map { ExpandCoord($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #ExpandCoord

=item GetSentenceString($tree?)

Return string representation of the given tree (suitable for
Analytical trees).

=cut

sub GetSentenceString {
  my $node = $_[0]||$this;
  $node=$node->root->following;
  my @sent=();
  while ($node) {
    push @sent,$node;
    $node=$node->following();
  }
  return join('',map{
    $_->{'m'}{form}.($_->attr('m/w/no_space_after')?'':' ')
  } sort { $a->{ord} <=> $b->{ord} } @sent);
}#GetSentenceString

=item DiveAuxCP($node)

You can use this function as a C<through> argument to GetEParents and
GetEChildren. It skips all the prepositions and conjunctions when
looking for nodes which is what you usually want.

=cut

sub DiveAuxCP ($){
  $_[0]->{afun}=~/x[CP]/
}#DiveAuxCP

=item GetEParents($node,$through)

Return linguistic parent of a given node as appears in an analytic
tree. The argument C<$through> should supply a function accepting one
node as an argument and returning true if the node should be skipped
on the way to parent or 0 otherwise. The most common C<DiveAuxCP> is
provided in this package.

=cut

sub _ExpandCoordGetEParents { # node through
  my ($node,$through)=@_;
  my @toCheck = $node->children;
  my @checked;
  while (@toCheck) {
    @toCheck=map {
      if (&$through($_)) { $_->children() }
      elsif($_->{afun}=~/Coord|Apos/&&$_->{is_member}){ _ExpandCoordGetEParents($_,$through) }
      elsif($_->{is_member}){ push @checked,$_;() }
      else{()}
    }@toCheck;
  }
  return @checked;
}# _ExpandCoordGetEParents

sub GetEParents { # node through
  my ($node,$through)=@_;
  my $init_node = $node; # only used for reporting errors
  if ($node->{is_member}) { # go to coordination head
    while ($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}) {
      $node=$node->parent;
      if (!$node) {
	print STDERR
	  "GetEParents: Error - no coordination head $init_node->{AID}: ".ThisAddress($init_node)."\n";
        return();
      } elsif($node->{afun}eq'AuxS') {
	print STDERR
	  "GetEParents: Error - no coordination head $node->{AID}: ".ThisAddress($node)."\n";
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
  _ExpandCoordGetEParents($node,$through);
} # GetEParents

=item GetEChildren($node,$dive)

Return a list of nodes linguistically dependant on a given
node. C<$dive> is a function which is called to test whether a given
node should be used as a terminal node (in which case it should return
false) or whether it should be skipped and its children processed
instead (in which case it should return true). Most usual treatment is
provided in C<DiveAuxCP>. If C<$dive> is skipped, a function returning 0
for all arguments is used.

=cut

sub _FilterEChildren{ # node dive suff from
  my ($node,$dive,$suff,$from)=@_;
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; # comment this line to get all members
    unless ($node==$from){ # on the way up do not go back down again
      if (!$suff&&$node->{afun}=~/Coord|Apos/&&!$node->{is_member}
	  or$suff&&$node->{afun}=~/Coord|Apos/&&$node->{is_member}) {
	push @sons,_FilterEChildren($node,$dive,1,0)
      } elsif (&$dive($node) and $node->firstson){
	push @sons,_FilterEChildren($node,$dive,$suff,0);
      } elsif(($suff&&$node->{is_member})
	      ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node;
      }
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # _FilterEChildren

sub GetEChildren{ # node dive
  my ($node,$dive)=@_;
  my @sons;
  my $from;
  $dive = sub { 0 } unless defined($dive);
  push @sons,_FilterEChildren($node,$dive,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}){
      $from=$node;$node=$node->parent;
      push @sons,_FilterEChildren($node,$dive,0,$from);
    }
    if ($node->{afun}eq'AuxS'){
      print STDERR "Error: Missing Coord/Apos: $node->{id} ".ThisAddress($node)."\n";
      @sons=@oldsons;
    }
  }
  return@sons;
} # GetEChildren

=item ANodeToALexRf(a_node,t_node,t_file)

Adds given a-node's C<id> to C<a/lex.rf> of the given t-node and
adjusts C<t_lemma> of the t-node accordingly. The third argument
t_file specifies the C<FSFile> object to which the given t-node
belongs.

=cut

sub ANodeToALexRf {
  my ($a_node,$t_node,$t_file)=@_;
  return unless ref($t_node) && ref($a_node) && ref($t_file);
  my $refid = $t_file->metaData('refnames')->{adata};
  $t_node->set_attr('a/lex.rf',$refid."#".$a_node->{id});
  $t_node->set_attr('a/aux.rf',List(grep{ $_ ne $refid."#".$a_node->{id} }
    uniq(ListV($t_node->{a}{'aux.rf'}))));
  my$lemma=$this->attr('m/lemma');
  my%specialEntity;
  %specialEntity=qw!. Period
                    , Comma
                    &amp; Amp
                    - Dash
                    / Slash
                    ( Bracket
                    ) Bracket
                    ; Semicolon
                    : Colon
                    &ast; Ast
                    &verbar; Verbar
                    &percnt; Percnt
                    !;
  if($lemma=~/^.*`([^0-9_-]+)/){
    $lemma=$1;
  }else{
    $lemma=~s/(.+?)[-_`].*$/$1/;
    if($lemma =~/^(?:(?:[ts]v|m)ùj|já|ty|jeho|se)$/){
      $lemma='#PersPron';
    }
    $lemma="#$specialEntity{$lemma}"if exists$specialEntity{$lemma};
  }
  $t_node->{t_lemma}=$lemma;
} #ANodeToALexRf

=item ANodeToALexRf(a_node,t_node,t_file)

Appends given a-node's C<id> to C<a/aux.rf> of the given t-node. The
third argument t_file specifies the C<FSFile> object to which the
given t-node belongs.

=cut

sub ANodeToAAuxRf {
  my ($a_node,$t_node,$t_file)=@_;
  return unless $t_node && $a_node;
  return unless ref($t_file);
  my $refid = $t_file->metaData('refnames')->{adata};
  AddToList($t_node,'a/aux.rf',$refid.'#'.$a_node->{id});
  @{$t_node->{a}{'aux.rf'}}=uniq(ListV($t_node->{a}{'aux.rf'}));
  delete $t_node->{a}{'lex.rf'}
    if $t_node->attr('a/lex.rf')eq$refid.'#'.$a_node->{id};
}#ANodeToAAuxRf



=item CreateStylesheets()

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

sub CreateStylesheets {
  unless(StylesheetExists('PML_A')){
    SetStylesheetPatterns(<<'EOF','PML_A',1);
text:<? $${m/w/token}eq$${m/form} ? 
  '#{'.CustomColor('sentence').'}${m/w/token}' : 
  '#{-over:1}#{'.CustomColor('spell').'}['.
     join(" ",map { $_->{token} } ListV($this->attr('m/w'))).
  ']#{-over:0}#{'.CustomColor('sentence').'}${m/form}' ?>

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
  return 'stop' if SchemaName() ne 'adata';
}
sub switch_context_hook {
  CreateStylesheets();
  my $cur_stylesheet = GetCurrentStylesheet();
  SetCurrentStylesheet('PML_A')
    if $cur_stylesheet eq STYLESHEET_FROM_FILE() or
       $cur_stylesheet =~ /^PML_T(?:_|\b)/;
}



1;

=back

=cut

#endif PML_A
