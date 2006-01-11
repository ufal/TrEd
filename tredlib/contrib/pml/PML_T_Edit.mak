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

PML_T_Edit.mak - Miscellaneous macros for editing the tectogrammatic layer
of Prague Dependency Treebank (PDT) 2.0.

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
  my $refid = FileMetaData('refnames')->{vallex};
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
  delete $PML_T::show{$PML_T_Edit::remember->{id}};
  undef $PML_T_Edit::remember;
  ChangingFile(0);
}#ForgetRemembered

=item MarkForARf()

Enter analytical layer with current node remembered. By calling
C<PML_A_Edit::AddThisToA...> you can make links between the layers.

=cut

#bind MarkForARf to + menu Mark for reference changes and enter A-layer
sub MarkForARf {
  $PML::arf=$this;
  ChangingFile(0);
  AnalyticalTree();
}#MarkForARf

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

sub AddNode {
  my $type=questionQuery('New node',
                         'Type of the new node:',
                         ('Analytic','#-entity','Cancel'));
  return if$type eq'Cancel';
  if($type eq'Analytic'){
    $this=NewNode($this);
    $this->{t_lemma}='#NewNode';
    $this->{functor}='PAR';
    $this->{nodetype}='complex';
    EditFunctor();
    EditNodetype();
    ChangingFile(EditAttribute($this,'is_generated'));
    MarkForARf();
  }else{
    my$dialog=[];
    my%lemmas=qw/AsMuch qcomplex
                 Benef qcomplex
                 Colon coap
                 Comma coap
                 Cor qcomplex
                 Dash coap
                 EmpNoun complex
                 EmpVerb qcomplex
                 Equal qcomplex
                 Forn list
                 Gen qcomplex
                 Idph list
                 Neg atom
                 Oblfm qcomplex
                 Percnt qcomplex
                 PersPron complex
                 QCor qcomplex
                 Rcp qcomplex
                 Separ coap
                 Some qcomplex
                 Total qcomplex
                 Unsp qcomplex
                /;
    ListQuery('T-lemma',
              'browse',
              [sort keys%lemmas],
              $dialog) or return;
    $this=NewNode($this);
    $this->{functor}='PAR';
    $this->{t_lemma}='#'.$dialog->[0];
    $this->{nodetype}=$lemmas{$dialog->[0]};
    $this->{is_generated}=1;
    EditFunctor();
    EditNodetype();
  }
} #AddNode

#bind MoveNodeLeft to Ctrl+Left menu Move node to the left
sub MoveNodeLeft {
  return unless (GetOrd($this)>1);
  ShiftNodeLeft($this);
}

#bind MoveNodeRight to Ctrl+Right menu Move node to the right
sub MoveNodeRight {
  return unless ($this->parent);
  ShiftNodeRight($this);
}

#bind MoveSTLeft to Alt+Left menu Move subtree to the left
sub MoveSTLeft {
# moves the subtree of a given node one node left (with respect to all other nodes)
# (if the subtree is not contiguous, the user is asked how to proceed)
  my $top=$this;
  my @subtree=GetNodes($top);
  SortByOrd(\@subtree);
  if ( (GetOrd($subtree[-1])-GetOrd($subtree[0])) != $#subtree ) {
    return if ("No" eq questionQuery('Non-contiguous subtree',
				     'The subtree you want to move is non-contiguous. Proceed anyway?',
				     ('Yes','No')));

  };
  my $all=GetNodesExceptSubtree([$top]);
  SortByOrd($all);
  my $i=Index($all,$top);  # locate the given node in the array @all
  if ($i>1) {  # check if there is place where to move (the root is always number zero)
    splice @$all,$i,1;  # cut out the given node
    splice @$all,$i-1,0, @subtree;  # splice the projectivized subtree at the right (ie left ;-) place
  }
  else {
    splice @$all,$i,1, @subtree;  # if there is no room where to move, just splice the proj. subtree
                                 # instead of the given node - thus the subtree gets projectivized
  }
  NormalizeOrds($all);  # the ordering attributes are modified accordingly
}

#bind MoveSTRight to Alt+Right menu Move subtree to the right
sub MoveSTRight {
# moves the subtree of a given node one node right (with respect to all other nodes)
# (if the subtree is not contiguous, the user is asked how to proceed)
  my $top=$this;
  my @subtree=GetNodes($top);
  SortByOrd(\@subtree);
  if ( (GetOrd($subtree[-1])-GetOrd($subtree[0])) != $#subtree ) {
    return if ("No" eq questionQuery('Non-contiguous subtree',
				     'The subtree you want to move is non-contiguous. Proceed anyway?',
				     ('Yes','No')));

  };
  my $all=GetNodesExceptSubtree([$top]);
  SortByOrd($all);
  my $i=Index($all,$top);  # locate the given node in the array @all
  if ($i<$#$all) {  # check if there is place where to move
    splice @$all,$i,1;  # cut out the given node
    splice @$all,$i+1,0, @subtree;  # splice the projectivized subtree at the right (ie left ;-) place
  }
  else {
    splice @$all,$i,1, @subtree;  # if there is no room where to move, just splice the proj. subtree
                                 # instead of the given node - thus the subtree gets projectivized
  }
  NormalizeOrds($all);  # the ordering attributes are modified accordingly
}


#bind DeleteNode to Delete menu Delete Node
#bind DeleteSubtree to Ctrl+Delete menu Delete Subtree
#bind AddNode to Insert menu Insert New Node

1;

=back

=cut

#endif PML_T_Edit
