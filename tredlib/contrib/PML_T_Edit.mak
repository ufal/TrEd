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

=item add_coref (node, target, coref)

If the node does not refer to target by the coref of type C<$coref>,
make the reference, else delete the reference.

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

sub get_status_line_hook {
  my $statusline=&PML_T::get_status_line_hook;
  push @{$statusline->[0]},
    ($PML_T_Edit::remember ?
     ('   Remembered: ' => [qw(label)],
      $PML_T_Edit::remember->{t_lemma} || $PML_T_Edit::remember->{id}=> [qw(status)]
     ):'');
  push @{$statusline->[1]},("status" => [ -foreground => CustomColor('status')]);
  return $statusline;
}#get_status_line_hook

sub status_line_doubleclick_hook {
  # status-line field double clicked

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
        ChooseFrame(); #TODO
        last;
      } else {
        if (main::doEditAttr($grp,$this,$1)) {
          ChangingFile(1);
          Redraw_FSFile();
        }
        last;
      }
    }
  }
}

=item remember_node

Remembers current node to be used later, e.g. with
C<text_arrow_to_remembered>.

=cut

#bind remember_node to space menu Remember Node
sub remember_node{
  $PML_T_Edit::remember=$this;
  undef %PML_T::show;
  $PML_T::show{$this->{id}}=1;
  ChangingFile(0);
}#remember_node

#bind text_arow_to_remembered to Ctrl+space menu Make Textual Coreference Aroow to Remembered Node
sub text_arow_to_remembered{
  ChangingFile(0);
  if($PML_T_Edit::remember and $PML_T_Edit::remember->parent and $this->parent){
    add_coref($this,$PML_T_Edit::remember,'coref_text.rf');
    ChangingFile(1);
  }
}#text_arow_to_remembered

#bind forget_remembered to Shift+space menu Forget Remembered Node
sub forget_remembered {
  undef $PML_T_Edit::remember;
  delete $PML_T::show{$this->{id}};
  ChangingFile(0);
}#forget_remembered

=item mark_for_arf

Enter analytical layer with current node remembered. By calling
C<add_this_to_arf> you can make links between the layers.

=cut

#bind mark_for_arf to + menu Mark Node for a.rf Changes
sub mark_for_arf {
  $PML::arf=$this;
  ChangingFile(0);
  analytical_tree();
}#mark_for_arf

#bind rotate_generated to g menu Change is_generated
sub rotate_generated{
  $this->{is_generated}=!$this->{is_generated};
}#rotate_generated

#bind rotate_member to m menu Change is_member
sub rotate_member{
  $this->{is_member}=!$this->{is_member};
}#rotate_member

#bind rotate_parenthesis to p menu Change is_parenthesis
sub rotate_parenthesis{
  $this->{is_parenthesis}=!$this->{is_parenthesis};
}#rotate_parenthesis

#bind edit_functor to f menu Edit Functor
sub edit_functor{
  ChangingFile(EditAttribute($this,'functor'));
}#edit_functor

#bind edit_tfa to t menu Edit TFA
sub edit_tfa{
  ChangingFile(EditAttribute($this,'tfa'));
}#edit_tfa

#bind edit_t_lemma to l menu Edit t_lemma
sub edit_t_lemma{
  ChangingFile(EditAttribute($this,'t_lemma'));
}#edit_t_lemma

#bind edit_nodetype to N menu Edit Node Type
sub edit_nodetype{
  ChangingFile(EditAttribute($this,'nodetype'));
}#edit_nodetype

#bind edit_gram to G menu Edit Grammatemes
sub edit_gram{
  ChangingFile(EditAttribute($this,'gram'));
}#edit_nodetype

#bind annotate_segm to s menu Annotate Special Coreference - Segment
sub annotate_segm{
  if($this->{coref_special}eq'segm'){
    $this->{coref_special}='';
  }else{
    $this->{coref_special}='segm';
  }
}#annotate_segm

#bind annotate_exoph to e menu Annotate Special Coreference - Exophora
sub annotate_exoph{
  if($this->{coref_special}eq'exoph'){
    $this->{coref_special}='';
  }else{
    $this->{coref_special}='exoph';
  }
}#annotate_exoph

#bind delete_node to Delete menu Delete Node
#bind delete_subtree to Ctrl+Delete menu Delete Subtree
#bind new_node to Insert menu Insert New Node

1;

=back

=cut

#endif PML_T_Edit
