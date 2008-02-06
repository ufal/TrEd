# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.

#encoding iso-8859-2

BEGIN { import PML_A; }
sub first (&@);

=pod

=head1 PML_A_Edit

PML_A_Edit.mak - Miscellaneous macros for editing the analytic layer of
Prague Dependency Treebank (PDT) 2.0.

=over 4

=cut

sub get_status_line_hook {
  my $statusline=&PML_A::get_status_line_hook;
  push @{$statusline->[0]},
    ($PML::arf ?
           ('   Changing a.lex of: ' => [qw(label)],
            $PML::arf->{t_lemma} || $PML::arf->{id}=> [qw(status)]
           ):()
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


=item AddThisToALexRf()

If called from analytical tree entered through
C<PML_T_Edit::MarkForARf>, adds this node's C<id> to C<a/lex.rf> list
of the marked tectogrammatical node.

=cut

sub AddThisToALexRf {
  ChangingFile(0);
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  ANodeToALexRf($this,$PML::arf,$tr_fs);
  $tr_fs->notSaved(1);
}#AddThisToALexRf

=item AddThisToAAuxRf()

If called from analytical tree entered through
C<PML_T_Edit::MarkForARf>, adds this node's C<id> to C<a/aux.rf> list
of the marked tectogrammatical node.

=cut

sub AddThisToAAuxRf {
  ChangingFile(0);
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  ANodeToAAuxRf($this,$PML::arf,$tr_fs);
  $tr_fs->notSaved(1);
}#AddThisToAAuxRf

=item RemoveThisFromARf()

If called from analytical tree entered through
C<PML_T_Edit::MarkForARf>, remove this node's C<id> from C<a/lex.rf>
and C<a/aux.rf> of the marked tectogrammatical node.

=cut

sub RemoveThisFromARf {
  ChangingFile(0);
  return unless $PML::arf;
  my $tr_fs = $grp->{FSFile}->appData('tdata');
  return 0 unless ref($tr_fs);
  my $refid = $tr_fs->metaData('refnames')->{adata};
  if($PML::arf->attr('a/lex.rf')eq$refid.'#'.$this->{id}){
    delete $PML::arf->{a}{'lex.rf'};
  }
  @{$PML::arf->{a}{'aux.rf'}}
    =uniq(ListSubtract
          ($PML::arf->{a}{'aux.rf'},
           List($refid.'#'.$this->{id})
          )) if ListV($PML::arf->attr('a/aux.rf'));
  $tr_fs->notSaved(1);
}#RemoveThisFromARf

sub EditMLemma{
  ChangingFile(EditAttribute($this,'m/lemma'));
}#EditMlemma

sub EditMTag{
  ChangingFile(EditAttribute($this,'m/tag'));
}#EditMtag

sub EditAfun{
  ChangingFile(EditAttribute($this,'afun'));
}#EditAfun

sub RotateMember{
  $this->{is_member}=!$this->{is_member};
}#RotateMember

sub RotateParenthesisRoot{
  $this->{is_parenthesis_root}=!$this->{is_parenthesis_root};
}#RotateParenthesisRoot

=back

=cut

