# -*- cperl -*-

#ifndef PML_T_Edit
#define PML_T_Edit

#include "PML_T.mak"

package PML_T_Edit;

#binding-context PML_T_Edit

#encoding iso-8859-2


import PML_T;
sub first (&@);

=pod

=head1 PML_T_Edit

PML_T_Edit.mak - Miscelaneous macros for editing tectogrammatic layer
of Prague Dependency Treebank (PDT) 2.0.

=head2 REFERENCE

=over 4

=cut

#key-binding-adopt PML_T_View
#menu-binding-adopt PML_T_View

=item add_coref

TODO

=cut

sub add_coref{
  print@_,"\n";
  my($node,$target,$coref)=@_;
  if (first{$target->{id}eq$_}ListV($node->{$coref})){
    @{$node->{$coref}}
      =grep{$_ ne$target->{id}}ListV($node->{$coref});
  }else{
    AddToList($node,$coref,$target->{id});
  }
}#add_coref

sub node_release_hook {
  my ($node,$target,$mod)=@_;
  return unless $target and $mod;
  return 'stop' unless $target->parent and $node->parent;
  my%cortypes=(grammatical=>'coref_gram',
              textual=>'coref_text',
              compl=>'compl',
              );
  my $type;
  if ($mod eq 'Shift') {
    $type='grammatical';
  } elsif ($mod eq 'Control') {
    $type='textual';
  } elsif ($mod eq 'Alt') {
    $type='compl';
  }else{
    return;
  }
  add_coref($node,$target,$cortypes{$type}.'.rf');
  TredMacro::Redraw_FSFile_Tree();
  $FileChanged=1;
}#node_release_hook

#bind edit_functor to f menu Edit Functor
sub edit_functor{
  my$f=$this->{functor};
  EditAttribute($this,'functor');
  ChangingFile($f ne$this->{functor});
}#edit_functor

#bind edit_tfa to t menu Edit TFA
sub edit_tfa{
  my$t=$this->{tfa};
  EditAttribute($this,'tfa');
  ChangingFile($t ne$this->{tfa});
}#edit_functor

#bind remember_node to space menu Remember Node
sub remember_node{
  $PML_T_Edit::remember=$this;
}#remember_node

#bind text_arow_to_remembered to Ctrl+space menu Make Textual Coreference Aroow to Remembered Node
sub text_arow_to_remembered{
  if($PML_T_Edit::remember and $PML_T_Edit::remember->parent and $this->parent){
    add_coref($this,$PML_T_Edit::remember,'coref_text.rf');
  } # TODO: mazat $PML_T::coreflemmas !!!!!!!!!!!!!!!!1
}#text_arow_to_remembered


#bind delete_node to Delete menu Delete Node
#bind delete_subtree to Ctrl+Delete menu Delete Subtree

1;

=back

=cut

#endif PML_T_Edit
