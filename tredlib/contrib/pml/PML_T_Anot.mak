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

#remove-menu Show valency frames and highlight assigned

sub CreateStylesheets{
  unless(StylesheetExists('PML_T_Anot')){
    SetStylesheetPatterns(<<'EOF','PML_T_Anot',1);
node:<? '#{customparenthesis}' if $${is_parenthesis}
  ?><? $${nodetype}eq'root' ? '${id}' : '${t_lemma}' ?><? '#{customerror}'.('!'x scalar(ListV($this->{annot_comment}))) if $${annot_comment} ?><? '#{customdetail}"' if $${is_dsp_root}
  ?><? '#{customdetail}.${sentmod}'if$${sentmod}
  ?><? '#{customcoref}'.$PML_T::coreflemmas{$${id}}
    if $PML_T::coreflemmas{$${id}}ne'' ?>

node:<?
  ($${nodetype} eq 'root' ? '#{customnodetype}${nodetype}' :
  '#{customfunc}${functor}').
  "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?>

node:<? $${nodetype} ne 'complex' and $${nodetype} ne 'root'
        ? '#{customnodetype}${nodetype}'
        : ''
     ?>#{customcomplex}<?
        local $_=$${gram/sempos};
        s/^sem([^.]+)(\..)?[^.]*(.*)$/$1$2$3/;
        '${gram/sempos='.$_.'}'
?>

style:#{Node-width:7}#{Node-height:7}#{Node-currentwidth:9}#{Node-currentheight:9}

style:<? '#{Node-shape:'.($this->{is_generated}?'rectangle':'oval').'}'?>

style:<? exists $PML_T::show{$${id}} ?'#{Node-addwidth:10}#{Node-addheight:10}':''?>

style:<?
  if(($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/) or
     ($this->parent and $this->parent->{nodetype}eq'root')) {
     '#{Line-width:1}#{Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal').'}'
  } elsif ($${is_member}) {
    if (PML_T::IsCoord($this)and PML_T::IsCoord($this->parent)) {
      '#{Line-width:1}#{Line-fill:'.CustomColor('line_member').'}'
    } elsif ($this->parent and PML_T::IsCoord($this->parent)) {
      '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:3&1}#{Line-fill:'.
       CustomColor('line_normal').'&'.CustomColor('line_member').'}'
    } else {
      '#{Line-fill:'.CustomColor('error').'}'
    }
  } elsif ($this->parent and PML_T::IsCoord($this->parent)) {
    '#{Line-width:1}#{Line-fill:'.CustomColor('line_comm').'}'
  } elsif (PML_T::IsCoord($this)) {
    '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:1&3}#{Line-fill:'.
    CustomColor('line_member').'&'.CustomColor('line_normal').'}'
  } else {
    '#{Line-width:2}#{Line-fill:'.CustomColor('line_normal').'}'
  }
?>

style:<?
  if ($${tfa}=~/^[tfc]$/) {
    '#{Oval-fill:'.CustomColor('tfa_'.$${tfa}).'}${tfa}.'
  } else {
    '#{Oval-fill:'.CustomColor('tfa_no').'}'
  }
?>#{CurrentOval-width:3}#{CurrentOval-outline:<? CustomColor('current') ?>}

hint:<?
   my @hintlines;
   if (ref($this->{gram})) {
     foreach my $gram (sort keys %{$this->{gram}}) {
       push @hintlines, "gram/".$gram." : ".$this->{gram}->{$gram} if $this->{gram}->{$gram}
     }
   }
   push@hintlines, "is_dsp_root : 1" if $${is_dsp_root};
   push@hintlines, "is_name_of_person : 1" if $${is_name_of_person};
   push@hintlines, "quot : ". join(",",map{$_->{type}}ListV($this->{quot})) if $${quot};
   push @hintlines,map{'! '.$_->{type}.':'.$_->{text}}ListV($this->{annot_comment});
   join"\n", @hintlines
?>
EOF
  }
}#CreateStylesheets

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  my ($a_tree) = GetANodes($tree);
  return unless ($a_tree);
  my $node = $tree->following;
  my %refers_to;
  while ($node) {
    foreach (GetANodeIDs($node)) {
      push @{$refers_to{$_}}, $node;
    }
    $node = $node->following;
  }
  $node = $a_tree->following;
  my @sent=();
  while ($node) {
    push @sent,$node;
    $node=$node->following();
  }
  my@out;
  my$first=1;
  foreach $node (sort { $a->{ord} <=> $b->{ord} } @sent){
    unless($first){
      push@out,([" ","space"])
    }
    $first=0;
    my $token = join(" ",map { $_->{token} } ListV($node->attr('m/w')));
    if ($node->{'m'}{form} ne $token){
      push@out,(['['.$token.']',@{$refers_to{$node->{id}}},'-over=>1','-foreground=>'.CustomColor('spell')]);
    }
    push@out,([$node->{'m'}{form},@{$refers_to{$node->{id}}}]);
  }
  push@out,(["\n".$tree->{eng_sentence},'-foreground=>lightblue']);
  return \@out;
}

sub switch_context_hook {
  CreateStylesheets();
  my $cur_stylesheet = GetCurrentStylesheet();
  SetCurrentStylesheet('PML_T_Anot'),Redraw();
  undef$PML::arf;
  my ($prefix,$file)=FindVallex();
  ValLex::GUI::Init({-vallex_file => $file});
}

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
      join(",",map{_get_frame($_)}AltV($this->{'val_frame.rf'})) => [qw({FRAME} value)]
     ) : ());
  push @{$statusline->[0]},
    ($PML_T_Edit::remember ?
     ('   Remembered: ' => [qw(label)],
      $PML_T_Edit::remember->{t_lemma} || $PML_T_Edit::remember->{id}=> [qw(status)]
     ):'');
  return $statusline;
}#get_status_line_hook

sub _get_frame {
  my$rf=shift;
  my ($prefix,$file)=FindVallex();
  $rf=~s/^\Q$prefix\E\#//;
  my $frame = $ValLex::GUI::ValencyLexicon->by_id($rf);
  return $ValLex::GUI::ValencyLexicon->serialize_frame($frame) if $frame;
  'NOT FOUND!';
}#_get_frame

sub status_line_doubleclick_hook {
  # status-line field double clicked

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	ChooseValFrame();
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

#bind Reflexive to 3 menu Reflexive se/si
sub Reflexive {
  ChangingFile(0);
  if($this->{t_lemma}=~/_s[ei](?:\b|_)/){
    $this->{t_lemma}=~s/_s[ei](\b|_)/$1/;
    ChangingFile(1);
    VallexWarning($this);
  }else{
    my@anodes=grep{$_->attr('m/form')=~/^s[ei]$/i}GetANodes($this);
    if(@anodes==0){
      my$q=questionQuery
        ('se/si',
         'No "se" nor "si" found among analytical nodes.',
         'Add se','Add si','Cancel');
      if($q=~/Add (s[ei])/){
        $this->{t_lemma}.='_'.$1;
        ChangingFile(1);
        VallexWarning($this);
      }
    }elsif(@anodes==1){
      $this->{t_lemma}.='_'.lc($anodes[0]->attr('m/form'));
      ChangingFile(1);
      VallexWarning($this);
    }else{ # more than 1 anodes
      if(grep{$_->attr('m/form')=~/se/i}@anodes
         and grep{$_->attr('m/form')=~/si/i}@anodes){
        my$q=questionQuery
          ('se/si',
           'Both "se" and "si" found among analytical nodes.',
           'Add se','Add si','Cancel');
        if($q=~/Add (s[ei])/){
          $this->{t_lemma}.='_'.$1;
          ChangingFile(1);
          VallexWarning($this);
        }
      }else{
        $this->{t_lemma}.='_'.lc($anodes[0]->attr('m/form'));
        ChangingFile(1);
        VallexWarning($this);
      }
    }
  }
}#Reflexive

sub _Perm{
  my$pos=shift;
  my$perm=shift;
  if($pos<@_){
    for(my$i=$pos;$i<@_;$i++){
      if($i!=$pos){
        my$j=$_[$i];
        $_[$i]=$_[$pos];
        $_[$pos]=$j;
      }
      _Perm($pos+1,$perm,@_);
      if($i!=$pos){
        my$j=$_[$i];
        $_[$i]=$_[$pos];
        $_[$pos]=$j;
      }
    }
  }else{
    push @{$perm},join"_",@_;
  };
}#_Perm

sub _GenerateLemmaList{
  my$perm=[];
  _Perm(0,$perm,@_);
  return$perm;
}#_GenerateLemmaList

#bind RegenerateTLemma to L menu Regenerate T-lemma
sub RegenerateTLemma{
  ChangingFile(0);
  @anodes=GetANodes($this);
  if(@anodes>1){
    my@words=map{
      my$l=$_->attr('m/lemma');$l=~s/(.+?)[-_`].*$/$1/;$l;
    }@anodes;
    my$d=[$words[0]];
    ListQuery('Participating lemmas',
              'multiple',
              \@words,
              $d);
    my$possible=_GenerateLemmaList(@{$d});
    my$d=[$possible->[0]];
    ListQuery('New t-lemma','browse',
              $possible,
              $d) or return;
    $this->{t_lemma}=$d->[0];
    ChangingFile(1);
    VallexWarning($this);
  }elsif(@anodes==1){
    my$l=$anodes[0]->attr('m/lemma');
    $l=~s/(.+?)[-_`].*$/$1/;
    $this->{t_lemma}=$l;
    ChangingFile(1);
    VallexWarning($this);
  }
}#RegenerateTLemma

#bind AddComment to ! menu Add Annotator's comment
sub AddComment {
  my $list=$this->type->schema->resolve_type($this->type->find('annot_comment/type'))->{choice};
  my$dialog=[$list->[0]];
  ListQuery('Comment type',
            'browse',
            $list,
            $dialog) or return;
  my$text=QueryString('Comment text','Text:');
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

#bind EditSubfunctor to F menu Edit Subfunctor
sub EditSubfunctor{
  ChangingFile(EditAttribute($this,'subfunctor'));
}#EditSubfunctor

#bind EditFunctor to f menu Edit Functor
sub EditFunctor{
  ChangingFile(EditAttribute($this,'functor'));
}#EditFunctor

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

## strip vallex PML-ref prefix from a given frame_rf
sub _stripped_frame_rf {
  my $frame_rf = shift;
  my $refid = FileMetaData('refnames')->{vallex};
  my @rf = map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($frame_rf);
  return wantarray ? @rf : join '|',$frame_rf;
}

## get POS of the frame assigned to a given node
sub _assigned_frame_pos_of {
  my $node = shift || $this;
  return unless $node;
  if ($node->{'val_frame.rf'} ne q()) {
    my ($refid,$vallex_file) = FindVallex();
    my $V = ValLex::GUI::Init({-vallex_file=>$vallex_file});
    if ($V) {
      for my $id (_stripped_frame_rf($node->{'val_frame.rf'})) {
	my $frame = $V->by_id( $id );
	if ($frame) {
	  return lc($V->getPOS($V->getWordForFrame($frame)));
	}
      }
    }
  }
  return;
}

#bind OpenValLexicon to Ctrl+Shift+Return menu Browse valency frame lexicon
sub OpenValLexicon {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;
  $opts{-sempos}  ||= $node->attr('gram/sempos') || _assigned_frame_pos_of($node);
  PML_T::OpenValLexicon($node, %opts);
  ChangingFile(0);
}

#bind ChooseValFrame to Ctrl+Return menu Select and assign valency frame
sub ChooseValFrame {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;

  my $sempos = [ $opts{-sempos} || $node->attr('gram/sempos') || _assigned_frame_pos_of($node) ];
  if (!$sempos->[0]) {
    $sempos=['v'];
    ListQuery('Semantical POS','browse',[qw(v n)],$sempos) or return;
  }
  $opts{-sempos} = $sempos->[0];
  PML_T_Edit::ChooseValFrame($node, %opts);
  ChangingFile(0);
}

#bind MarkForARf to + menu Mark for reference changes and enter A-layer
sub MarkForARf {
  $PML::arf=$this;
  ChangingFile(0);
  $PML::desiredcontext='PML_A_Edit';
  AnalyticalTree();
}#MarkForARf

sub VallexWarning {
  if($_[0]->{'val_frame.rf'}){
    questionQuery('T-lemma changed',
                  'T-lemma has changed. Verify that the vallex reference is correct.',
                  'OK');
  }
}#VallexWarning

sub after_edit_attr_hook {
  my($node,$attr,$result)=(shift,shift,shift);
  return unless $result;
  if($attr eq 't_lemma'){
    if($node->{t_lemma}=~m/^#(.*)/
       and not first{$1 eq $_}qw[Amp Ast AsMuch Benef Bracket Colon
                                 Comma Cor Dash EmpNoun EmpVerb Equal
                                 Forn Gen Idph Neg Oblfm Percnt
                                 PersPron Period Period3 QCor Rcp
                                 Slash Separ Some Total Unsp]){
      questionQuery('Invalid entity',
                    'Cannot change t-lemma to undefined #-entity. T-lemma not changed.',
                    'OK');
      Undo();
    }else{
      VallexWarning($node);
    }
    if($node->{t_lemma}=~m/^#(?:Idph|Forn)$/){
      $node->{nodetype}='list';
    }elsif(($node->{t_lemma}=~m/^#(?:Amp|Ast|AsMuch|Cor|EmpVerb|Equal|Gen|Oblfm|Percnt|Qcor|Rcp|Some|Total|Unsp)$/o)
           or($node->{nodetype}ne'coap'
              and $node->{t_lemma}=~m/^#(?:Bracket|Comma|Colon|Dash|Period|Period3|Slash)$/o)){
      $node->{nodetype}='qcomplex';
    }
  }elsif($attr eq 'functor'){
    if(IsCoord($node)){
      $node->{nodetype}='coap';
    }elsif($node->{functor}=~/^(?:ATT|CM|INTF|MOD|PARTL|PREC|RHEM)$/){
      $node->{nodetype}='atom';
    }elsif($node->{functor}=~m/^([FD]PHR)$/){
      $node->{nodetype}=lc $1;
    }
  }
}#after_edit_attr_hook

#bind EditTLemma to l menu Edit t_lemma
sub EditTLemma{
  ChangingFile(EditAttribute($this,'t_lemma'));
  # Because of Undo in hook:
  $this=undef;
}#EditTLemma

#bind AddNode to Insert menu Insert New Node
sub AddNode {
  ChangingFile(0);
  PML_T_Edit::_AddNode(1);
}#AddNode

=item DeleteNodeToAux(node?)

Deletes $node or $this, attaches all its children and references from
a/ to its parent and recounts deepord. Cannot be used for the root.

=cut

#bind DeleteNodeToAux to Shift+Delete menu Delete Node Moving to Aux
sub DeleteNodeToAux{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  ChangingFile(0),return unless $node->parent;
  my$parent=$node->parent;
  foreach my$child($node->children){
    CutPaste($child,$parent);
  }
  AddToList($parent,'a/aux.rf',$node->attr('a/lex.rf'),ListV($node->attr('a/aux.rf')));
  DeleteLeafNode($node);
  $this=$parent unless@_;
  ChangingFile(1);
}#DeleteNodeToAux




1;

=back

=cut

#endif PML_T_Anot
