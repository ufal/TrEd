# -*- cperl -*-

#ifndef PML_T_Anot
#define PML_T_Anot

#include "PML_T_Edit.mak"

package PML_T_Anot;

#binding-context PML_T_Anot

#encoding iso-8859-2

import PML_T;
sub first (&@);

=pod

=head1 PML_T_Anot

PML_T_Anot.mak - Miscellaneous macros for annotating the
tectogrammatic layer in the way of Prague Dependency Treebank (PDT)
2.0.

=over 4

=cut

#key-binding-adopt PML_T_Edit
#menu-binding-adopt PML_T_Edit

sub switch_context_hook {
  PML_T::switch_context_hook();
  my$pattern=GetStylesheetPatterns('PML_T_Compact');
  if($pattern=~
     s/(t_lemma}')\s*\n/$1?><?'#{customerror}'.('!'x scalar(ListV(\$this->{annot_comment}))) if \$\${annot_comment} ?><? '#{customdetail}"' if \$\${is_dsp_root}/){
    $pattern=~s/(hint:\s*my\s*\Q@\Ehintlines;)\s*\n/$1push \@hintlines,map{'! '.\$_->{type}.':'.\$_->{text}}ListV(\$this->{annot_comment});\n/;
    SetStylesheetPatterns($pattern,'PML_T_Compact');
  }
  $pattern=GetStylesheetPatterns('PML_T_Full');
  if($pattern=~
     s/(t_lemma}')\s*\n/$1?><?'#{customerror}'.('!'x scalar(ListV(\$this->{annot_comment}))).'#{default}' if \$\${annot_comment}/
    ){
    $pattern=~s/(hint:\s*my\s*\Q@\Ehintlines;)\s*\n/$1push \@hintlines,map{'! '.\$_->{type}.':'.\$_->{text}}ListV(\$this->{annot_comment});\n/;
    print$pattern,"\n";
    SetStylesheetPatterns($pattern,'PML_T_Full');
  }
} #switch_context_hook

sub enable_edit_node_hook { 'stop' }

sub enable_attr_hook { 
  if ($_[0]=~m!^(?:id|a|a/.*|compl\.rf.*|coref_gram\.rf.*|coref_text\.rf.*|deepord|quot|val_frame\.rf)$!)
    {'stop'} else {1}
}#enable_attr_hook

sub node_release_hook{
  &PML_T_Edit::node_release_hook;
}#node_release_hook

sub get_status_line_hook {
  return unless $this;
  my$statusline= [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "     id: " => [qw(label)],
	   $this->{id} => [qw({id} value)],
	   "     a:" => [qw(label)]
          ],
	  # field styles
	  [
           "ref" => [-underline => 1, -foreground => 'blue'],
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	   "bg_white" => [ -background => 'white' ],
           "status" => [ -foreground => CustomColor('status')]
	  ]
	 ];
  my$sep=" ";
  foreach my $ref (
                   $this->{nodetype}eq'root'
                   ?
                   $this->{'atree.rf'}
                   :
                   ($this->attr('a/lex.rf'),ListV($this->attr('a/aux.rf')))){
    push @{$statusline->[0]},
      ($sep => [qw(label)],"$ref" => [ '{REF}','ref',$ref ]);
    $sep=", ";
  }
  push @{$statusline->[0]},
    ($this->{'val_frame.rf'} ?
     ("     frame: " => [qw(label)],
      join(",",AltV($this->{'val_frame.rf'})) => [qw({FRAME} value)]
     ) : ());
  push @{$statusline->[0]},
    ($PML_T_Edit::remember ?
     ('   Remembered: ' => [qw(label)],
      $PML_T_Edit::remember->{t_lemma} || $PML_T_Edit::remember->{id}=> [qw(status)]
     ):'');
  return $statusline;
}#get_status_line_hook

sub status_line_doubleclick_hook {
  # status-line field double clicked

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	PML_T_Edit::ChooseValFrame();
        last;
      } elsif($1 eq 'REF'){
        my $aref=@_[-1];
        $aref=~s/.*?#//;
        AnalyticalTree();
        my($node,$tree)=SearchForNodeById($aref);
        TredMacro::GotoTree($tree);
        $this=$node;
        Redraw_FSFile();
      } else {
        if (main::doEditAttr($grp,$this,$1)) {
          ChangingFile(1);
          Redraw_FSFile();
        }
        last;
      }
    }
  }
}#status_line_doubleclick_hook

#bind AddComment to ! menu Add Annotator's comment
sub AddComment {
  my $list=$this->type->schema->resolve_type($this->type->find('annot_comment/type'))->{choice};
  my$dialog=[$list->[0]];
  ListQuery('Comment type',
            'browse',
            $list,
            $dialog) or return;
  (my$text=QueryString('Comment text','Text:'));
  return unless defined $text;
  my%comment=(type=>$dialog->[0],
              text=>$text);
  AddToList($this,'annot_comment',\%comment);
}#AddComment

#bind EditComment to ? menu Edit Annotator's Comment
sub EditComment{
  ChangingFile(EditAttribute($this,'annot_comment'));
}#EditComment

#bind AddNeg to n menu Add Negation
sub AddNeg {
  $this=NewNode($this);
  $this->{functor}='RHEM';
  $this->{t_lemma}='#Neg';
  $this->{nodetype}='atom';
  $this->{is_generated}=1;
}#AddNeg

#bind EditSemPOS to P menu Edit Semantical POS
sub EditSemPOS{
  ChangingFile(EditAttribute($this,'gram/sempos'));
}#EditSemPOS

#bind RotateState to S menu Rotate State
sub RotateState{
    $this->{is_state}=!$this->{is_state};
}#RotateState

#bind RotateDsp to d menu Rotate is_dsp_root
sub RotateDsp{
    $this->{is_dsp_root}=!$this->{is_dsp_root};
}#RotateDsp

#bind ChooseValFrame to Ctrl+Return menu Select a and assign valency frame
sub ChooseValFrame {
  my$sempos=[];
  ListQuery('Semantical POS','browse',[qw(v n)],$sempos);
  my $refid = FileMetaData('refnames')->{vallex};
  PML_T::OpenValFrameList(
    $this,
    -sempos=>$sempos->[0],
    -assign_func => sub {
      my ($n, $ids)=@_;
      $n->{'val_frame.rf'} = undef;
      AddToAlt($n,'val_frame.rf',map { $refid."#".$_} split /\|/,$ids);
    }
   )
}

#bind MarkForARf to + menu Mark for reference changes and enter A-layer
sub MarkForARf {
  $PML::arf=$this;
  ChangingFile(0);
  $PML::desiredcontext='PML_A_Edit';
  AnalyticalTree();
}#MarkForARf


1;

=back

=cut

#endif PML_T_Anot
