# -*- cperl -*-

#ifndef PML_A_Edit
#define PML_A_Edit

#include "PML_A.mak"

package PML_A_Edit;

#binding-context PML_A_Edit

#encoding iso-8859-2


import PML_A;
sub first (&@);

=pod

=head1 PML_A_Edit

PML_A_Edit.mak - Miscelaneous macros for editing analytic layer of
Prague Dependency Treebank (PDT) 2.0.

=head2 REFERENCE

=over 4

=cut

sub get_status_line_hook {
  my $statusline=&PML_A::get_status_line_hook;
  push @{$statusline->[0]},
    ($PML::arf ?
           ('   Changing a.rf of: ' => [qw(label)],
            $PML::arf->{t_lemma} || $PML::arf->{id}=> [qw(status)]
           ):''
    );
  push @{$statusline->[1]},("status" => [ -foreground => CustomColor('status')]);
  return $statusline;
}#get_status_line_hook

sub status_line_doubleclick_hook {
  # status-line field double clicked

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if (main::doEditAttr($grp,$this,$1)) {
        ChangingFile(1);
        Redraw_FSFile();
      }
      last;
    }
  }
}


=item AddThisToArfOriginal

If called from analytical tree entered through C<PML_T_Edit::MarkForArf>, adds
this node's C<id> to C<a.rf> list of the marked tectogrammatical node.

=cut

#bind AddThisToArfOriginal to Ctrl++ Add This to a.rf of Marked Node
sub AddThisToArfOriginal {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  my $refid = $tr_fs->metaData('refnames')->{adata};
  AddToList($PML::arf,'a.rf',$refid."#".$this->{id});
  @{$PML::arf->{'a.rf'}}=uniq(ListV($PML::arf->{'a.rf'}));
  my$lemma=$this->{'m'}{lemma};
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
  $PML::arf->{t_lemma}=$lemma;
  $tr_fs->notSaved(1);
}#AddThisToArf

=item AddThisToArf

If called from analytical tree entered through C<PML_T_Edit::MarkForArf>, adds
this node's C<id> to C<a.rf> list of the marked tectogrammatical node.

=cut

#bind AddThisToArf to + menu Add This to a.rf of Marked Node
sub AddThisToArf {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  my $refid = $tr_fs->metaData('refnames')->{adata};
  AddToList($PML::arf,'a.rf',$refid.'#'.$this->{id});
  @{$PML::arf->{'a.rf'}}=uniq(ListV($PML::arf->{'a.rf'}));
  $tr_fs->notSaved(1);
}#AddThisToArf

#bind RemoveThisFromArf to minus menu Remove This from a.rf of Marked Node
#bind RemoveThisFromArf to KP_Subtract
sub RemoveThisFromArf {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  my $refid = $tr_fs->metaData('refnames')->{adata};
  @{$PML::arf->{'a.rf'}}=uniq(ListSubtract($PML::arf->{'a.rf'},List($refid.'#'.$this->{id})));
  $tr_fs->notSaved(1);
}#add_this_from_arf

#bind EditMLemma to L menu Edit morphological lemma
sub EditMLemma{
  ChangingFile(EditAttribute($this,'m/lemma'));
}#EditMlemma

#bind EditMTag to T menu Edit morphological tag
sub EditMTag{
  ChangingFile(EditAttribute($this,'m/tag'));
}#EditMtag

#bind EditAfun to a menu Edit afun
sub EditAfun{
  ChangingFile(EditAttribute($this,'afun'));
}#EditAfun

#bind RotateMember to m menu Change is_member
sub RotateMember{
  $this->{is_member}=!$this->{is_member};
}#RotateMember

#bind RotateParenthesisRoot to p menu Change is_parenthesis_root
sub RotateParenthesisRoot{
  $this->{is_parenthesis_root}=!$this->{is_parenthesis_root};
}#RotateParenthesisRoot


#bind TectogrammaticalTree to Ctrl+R menu Display tectogrammatical tree
#bind GotoTree to Alt+g menu Goto Tree


1;

=back

=cut

#endif PML_A_Edit
