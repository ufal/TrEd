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


=item add_this_to_arf_original

If called from analytical tree entered through C<PML_T_Edit::mark_for_arf>, adds
this node's C<id> to C<a.rf> list of the marked tectogrammatical node.

=cut

#bind add_this_to_arf_original to Ctrl++ Add This to a.rf of Marked Node
sub add_this_to_arf_original {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  AddToList($PML::arf,'a.rf',$this->{id});
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
}#add_this_to_arf

=item add_this_to_arf

If called from analytical tree entered through C<PML_T_Edit::mark_for_arf>, adds
this node's C<id> to C<a.rf> list of the marked tectogrammatical node.

=cut

#bind add_this_to_arf to + menu Add This to a.rf of Marked Node
sub add_this_to_arf {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  AddToList($PML::arf,'a.rf','a#'.$this->{id});
  @{$PML::arf->{'a.rf'}}=uniq(ListV($PML::arf->{'a.rf'}));
  $tr_fs->notSaved(1);
}#add_this_to_arf

#bind remove_this_from_arf to minus menu Remove This from a.rf of Marked Node
#bind remove_this_from_arf to KP_Subtract
sub remove_this_from_arf {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  @{$PML::arf->{'a.rf'}}=uniq(ListSubtract($PML::arf->{'a.rf'},List('a#'.$this->{id})));
  $tr_fs->notSaved(1);
}#add_this_from_arf

#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree
#bind goto_tree to Alt+g menu Goto Tree


1;

=back

=cut

#endif PML_A_Edit
