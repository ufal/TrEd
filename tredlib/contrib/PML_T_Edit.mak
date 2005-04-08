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

=item AddCoref(node,target,coref)

If the node does not refer to target by the coref of type C<$coref>,
make the reference, else delete the reference.

=cut

sub AddCoref{
  my($node,$target,$coref)=@_;
  if (first{$target->{id}eq$_}ListV($node->{$coref})){
    @{$node->{$coref}}
      =grep{$_ ne$target->{id}}ListV($node->{$coref});
  }else{
    AddToList($node,$coref,$target->{id});
  }
}#AddCoref

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
  AddCoref($node,$target,$cortypes{$type}.'.rf');
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

#bind ChooseValFrame to Ctrl+Return menu Select a and assign valency frame
sub ChooseValFrame {
  PML_T::OpenValFrameList(
    $this,
    -assign_func => sub {
      my ($n, $ids)=@_;
      $n->{'val_frame.rf'} = undef;
      AddToAlt($n,'val_frame.rf',map { $refid."#".$_} split /\|/,$ids);
    }
   )
}

sub status_line_doubleclick_hook {
  # status-line field double clicked

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	ChooseValFrame();
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

=item RememberNode()

Remembers current node to be used later, e.g. with
C<text_arrow_to_remembered>.

=cut

#bind RememberNode to space menu Remember Node
sub RememberNode{
  $PML_T_Edit::remember=$this;
  undef %PML_T::show;
  $PML_T::show{$this->{id}}=1;
  ChangingFile(0);
}#RememberNode

#bind TextArowToRemembered to Ctrl+space menu Make Textual Coreference Aroow to Remembered Node
sub TextArowToRemembered{
  ChangingFile(0);
  if($PML_T_Edit::remember and $PML_T_Edit::remember->parent and $this->parent){
    AddCoref($this,$PML_T_Edit::remember,'coref_text.rf');
    ChangingFile(1);
  }
}#TextArowToRemembered

#bind ForgetRemembered to Shift+space menu Forget Remembered Node
sub ForgetRemembered {
  undef $PML_T_Edit::remember;
  delete $PML_T::show{$this->{id}};
  ChangingFile(0);
}#ForgetRemembered

=item MarkForArf()

Enter analytical layer with current node remembered. By calling
C<AddThisToArf> you can make links between the layers.

=cut

#bind MarkForArf to + menu Mark Node for a.rf Changes
sub MarkForArf {
  $PML::arf=$this;
  ChangingFile(0);
  AnalyticalTree();
}#MarkForArf

#bind RotateGenerated to g menu Change is_generated
sub RotateGenerated{
  $this->{is_generated}=!$this->{is_generated};
}#RotateGenerated

#bind RotateMember to m menu Change is_member
sub RotateMember{
  $this->{is_member}=!$this->{is_member};
}#RotateMember

#bind RotateParenthesis to p menu Change is_parenthesis
sub RotateParenthesis{
  $this->{is_parenthesis}=!$this->{is_parenthesis};
}#RotateParenthesis

#bind EditFunctor to f menu Edit Functor
sub EditFunctor{
  ChangingFile(EditAttribute($this,'functor'));
}#EditFunctor

#bind EditTfa to t menu Edit TFA
sub EditTfa{
  ChangingFile(EditAttribute($this,'tfa'));
}#EditTfa

#bind EditTLemma to l menu Edit t_lemma
sub EditTLemma{
  ChangingFile(EditAttribute($this,'t_lemma'));
}#EditTLemma

#bind EditNodetype to N menu Edit Node Type
sub EditNodetype{
  ChangingFile(EditAttribute($this,'nodetype'));
}#EditNodetype

#bind EditGram to G menu Edit Grammatemes
sub EditGram{
  ChangingFile(EditAttribute($this,'gram'));
}#EditNodetype

#bind AnnotateSegm to s menu Annotate Special Coreference - Segment
sub AnnotateSegm{
  if($this->{coref_special}eq'segm'){
    $this->{coref_special}='';
  }else{
    $this->{coref_special}='segm';
  }
}#AnnotateSegm

#bind AnnotateExoph to e menu Annotate Special Coreference - Exophora
sub AnnotateExoph{
  if($this->{coref_special}eq'exoph'){
    $this->{coref_special}='';
  }else{
    $this->{coref_special}='exoph';
  }
}#AnnotateExoph

#bind DeleteNode to Delete menu Delete Node
#bind DeleteSubtree to Ctrl+Delete menu Delete Subtree
#bind NewNode to Insert menu Insert New Node

1;

=back

=cut

#endif PML_T_Edit
