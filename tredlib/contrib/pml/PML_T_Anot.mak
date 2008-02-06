# -*- cperl -*-

#ifndef PML_T_Anot
#define PML_T_Anot

#include "PML_T_Edit.mak"

package PML_T_Anot;

#binding-context PML_T_Anot

#encoding iso-8859-2

BEGIN { import PML_T; }
sub first (&@);

#include <contrib/support/unbind_edit.inc>

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
  "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?><? '#{customcoappa}_${is_member=M}'if$${is_member} ?><? '#{customparenthesis}_${is_parenthesis=P}' if$${is_parenthesis} ?>

node:<? my $line;
        if($PML_T_Anot::showANodes){
          $line=(($this->attr('a/lex.rf')
            ? ('#{darkgreen}'
              .(PML_T::GetANodeByID($this->attr('a/lex.rf'))->attr('m/form')))
            : ''
          ).($this->attr('a/aux.rf')
            ? ('#{darkorange}'
              .join(',','',map{
                  PML_T::GetANodeByID($_)->attr('m/form')
                }ListV($this->attr('a/aux.rf'))
              ))
            : ''
          ));
        }else{
          $line=(($${nodetype} ne 'complex' and $${nodetype} ne 'root')
            ? '#{customnodetype}${nodetype}'
            : '');
          $line.='#{customcomplex}';
          local $_=$${gram/sempos};
          s/^sem([^.]+)(\..)?[^.]*(.*)$/$1$2$3/;
          $line.='${gram/sempos='.$_.'}';
        }
        return $line;
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
    my $form = $node->attr('m/form');
    if ($form ne $token){
      push@out,(['['.$token.']',@{$refers_to{$node->{id}}},'-over=>1','-foreground=>'.CustomColor('spell')]);
    }
    push@out,([$form,@{$refers_to{$node->{id}}}]);
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
  my ($node,$target,$mod)=@_;
  return if $mod || ! $target;
  if ($target->{t_lemma} eq "#Forn") {
    $node->{functor}='FPHR';
    $node->{nodetype}='fphr';
    TredMacro::Redraw_FSFile_Tree();
    $FileChanged=1;
  }
}#node_release_hook

sub get_status_line_hook {
  return unless $this;
  my$statusline= [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
#	   "     id: " => [qw(label)],
#	   $this->{id} => [qw({id} value)],
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
    if($ref){
      push @{$statusline->[0]},
#        ($sep => [qw(label)],"$ref" => [ '{REF}','ref',$ref ]);
        ($sep => [qw(label)],GetANodeByID($ref)->attr('m/form') => [ '{REF}','ref',$ref ]);
    $sep=", ";
    }
  }
  unshift @{$statusline->[0]},
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
        $this=$root;
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
  my @list=$this->type('annot_comment/type/')->get_values();
  my$dialog=[$list[0]];
  ListQuery('Comment type',
            'browse',
            \@list,
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

#bind AddANode to Shift+Insert menu Insert New Node from A-layer
sub AddANode {
  ChangingFile(0);
  PML_T_Edit::AddAnalyticNode(1);
}#AddANode

#bind AddENode to Insert menu Insert New #-Entity Node
sub AddENode {
  ChangingFile(0);
  PML_T_Edit::AddEntityNode(1);
}#AddENode

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
  AddToList($parent,
            'a/aux.rf',
            grep { defined $_ }
            $node->attr('a/lex.rf'),ListV($node->attr('a/aux.rf'))
           ) if $node->attr('a/lex.rf') or $node->attr('a/aux.rf');
  DeleteLeafNode($node);
  $this=$parent unless@_;
  ChangingFile(1);
}#DeleteNodeToAux

#remove-menu Change is_parenthesis
#bind PML_T_Edit->RotateParenthesis to ALT+p menu Change is_parenthesis
#bind RotateParenthesisSubtree to p menu Change is_parenthesis for Subtree
sub RotateParenthesisSubtree{
  my $par = ! $this->{is_parenthesis};
  foreach my $node ($this,$this->descendants) {
    $node->{is_parenthesis} = $par;
  }
}#RotateParenthesisSubtree

#bind AddForn to Ctrl+f menu Add #Forn.ID
sub AddForn {
  $this=NewNode($this);
  $this->{functor}='ID';
  $this->{t_lemma}='#Forn';
  $this->{nodetype}='list';
  $this->{is_generated}=1;
}#AddForn

#bind AddNewNode to w menu Add #NewNode.VOCAT
sub AddNewNode {
  $this=NewNode($this);
  $this->{functor}='VOCAT';
  $this->{t_lemma}='#NewNode';
  $this->{nodetype}='qcomplex';
  $this->{is_generated}=1;
}#AddNewNode

#bind ToggleANodes to Ctrl+a menu Toggle Display a-nodes 
sub ToggleANodes {
  $PML_T_Anot::showANodes=not $PML_T_Anot::showANodes;
  ChangingFile(0);
}#ToggleANodes

#ifndef SKIPFUNC
#define SKIPFUNC

sub AssignFunctor {
  $this->{functor}=$_[0];
  after_edit_attr_hook($this,'functor',$_[0]);
}#AssignFunctor

#bind FuncRSTR to r menu Assign RSTR
sub FuncRSTR {
  AssignFunctor('RSTR');
}#FuncRSTR

#bind FuncACT to a menu Assign ACT
sub FuncACT {
  AssignFunctor('ACT');
}#FuncACT

#bind FuncPAT to A menu Assign PAT
sub FuncPAT {
  AssignFunctor('PAT');
}#FuncPAT

#bind FuncPRED to R menu Assign PRED
sub FuncPRED {
  AssignFunctor('PRED');
}#FuncPRED

#bind FuncCONJ to c menu Assign CONJ
sub FuncCONJ {
  AssignFunctor('CONJ');
}#FuncCONJ

#bind FuncLOC to Ctrl+L menu Assign LOC
sub FuncLOC {
  AssignFunctor('LOC');
}#FuncLOC

#bind FuncTWHEN to T menu Assign TWHEN
sub FuncTWHEN {
  AssignFunctor('TWHEN');
}#FuncTWHEN

#bind FuncRHEM to Ctrl+R menu Assign RHEM
sub FuncRHEM {
  AssignFunctor('RHEM');
}#FuncRHEM

#bind FuncDENOM to D menu Assign DENOM
sub FuncDENOM {
  AssignFunctor('DENOM');
}#FuncDENOM

#bind FuncMANN to M menu Assign MANN
sub FuncMANN {
  AssignFunctor('MANN');
}#FuncMANN

#bind FuncEXT to E menu Assign EXT
sub FuncEXT {
  AssignFunctor('EXT');
}#FuncEXT

#bind FuncID to i menu Assign ID
sub FuncID {
  AssignFunctor('ID');
}#FuncID

#bind FuncMAT to Ctrl+M menu Assign MAT
sub FuncMAT {
  AssignFunctor('MAT');
}#FuncMAT

#bind FuncDIR3 to I menu Assign DIR3
sub FuncDIR3 {
  AssignFunctor('DIR3');
}#FuncDIR3

#bind FuncDIR1 to Ctrl+I menu Assign DIR1
sub FuncDIR1 {
  AssignFunctor('DIR1');
}#FuncDIR1

#bind FuncBEN to b menu Assign BEN
sub FuncBEN {
  AssignFunctor('BEN');
}#FuncBEN

#bind FuncFPHR to h menu Assign FPHR
sub FuncFPHR {
  AssignFunctor('FPHR');
}#FuncFPHR

#bind FuncPREC to C menu Assign PREC
sub FuncPREC {
  AssignFunctor('PREC');
}#FuncPREC

#bind FuncCRIT to Ctrl+T menu Assign CRIT
sub FuncCRIT {
  AssignFunctor('CRIT');
}#FuncCRIT

#bind FuncCAUS to u menu Assign CAUS
sub FuncCAUS {
  AssignFunctor('CAUS');
}#FuncCAUS

#bind FuncREG to Ctrl+G menu Assign REG
sub FuncREG {
  AssignFunctor('REG');
}#FuncREG

#bind FuncTHL to H menu Assign THL
sub FuncTHL {
  AssignFunctor('THL');
}#FuncTHL

#bind FuncADVS to v menu Assign ADVS
sub FuncADVS {
  AssignFunctor('ADVS');
}#FuncADVS

#bind FuncTHO to Ctrl+H menu Assign THO
sub FuncTHO {
  AssignFunctor('THO');
}#FuncTHO

#bind FuncCOMPL to o menu Assign COMPL
sub FuncCOMPL {
  AssignFunctor('COMPL');
}#FuncCOMPL

#bind FuncCOND to O menu Assign COND
sub FuncCOND {
  AssignFunctor('COND');
}#FuncCOND

#bind FuncOPER to Ctrl+O menu Assign OPER
sub FuncOPER {
  AssignFunctor('OPER');
}#FuncOPER

#bind FuncAUTH to U menu Assign AUTH
sub FuncAUTH {
  AssignFunctor('AUTH');
}#FuncAUTH

#bind FuncCSQ to q menu Assign CSQ
sub FuncCSQ {
  AssignFunctor('CSQ');
}#FuncCSQ

#bind FuncSUBS to Ctrl+U menu Assign SUBS
sub FuncSUBS {
  AssignFunctor('SUBS');
}#FuncSUBS

#bind FuncTFRWH to W menu Assign TFRWH
sub FuncTFRWH {
  AssignFunctor('TFRWH');
}#FuncTFRWH

#bind FuncTOWH to Ctrl+W menu Assign TOWH
sub FuncTOWH {
  AssignFunctor('TOWH');
}#FuncTOWH

#bind FuncDIR2 to 2 menu Assign DIR2
sub FuncDIR2 {
  AssignFunctor('DIR2');
}#FuncDIR2

#bind FuncVOCAT to V menu Assign VOCAT
sub FuncVOCAT {
  AssignFunctor('VOCAT');
}#FuncVOCAT

#bind FuncAPP to k menu Assign APP
sub FuncAPP {
  AssignFunctor('APP');
}#FuncAPP

#bind FuncADDR to x menu Assign ADDR
sub FuncADDR {
  AssignFunctor('ADDR');
}#FuncADDR

#bind FuncEFF to y menu Assign EFF
sub FuncEFF {
  AssignFunctor('EFF');
}#FuncEFF

#bind FuncPAR to z menu Assign PAR
sub FuncPAR {
  AssignFunctor('PAR');
}#FuncPAR

#bind FuncAPPS to B menu Assign APPS
sub FuncAPPS {
  AssignFunctor('APPS');
}#FuncAPPS

#bind FuncACMP to K menu Assign ACMP
sub FuncACMP {
  AssignFunctor('ACMP');
}#FuncACMP

#bind FuncAIM to Q menu Assign AIM
sub FuncAIM {
  AssignFunctor('AIM');
}#FuncAIM

#bind FuncMEANS to X menu Assign MEANS
sub FuncMEANS {
  AssignFunctor('MEANS');
}#FuncMEANS

#bind FuncCM to Y menu Assign CM
sub FuncCM {
  AssignFunctor('CM');
}#FuncCM

#bind FuncDIFF to Z menu Assign DIFF
sub FuncDIFF {
  AssignFunctor('DIFF');
}#FuncDIFF

#bind FuncCPHR to Ctrl+b menu Assign CPHR
sub FuncCPHR {
  AssignFunctor('CPHR');
}#FuncCPHR

#bind FuncCPR to Ctrl+k menu Assign CPR
sub FuncCPR {
  AssignFunctor('CPR');
}#FuncCPR

#bind FuncTSIN to Ctrl+q menu Assign TSIN
sub FuncTSIN {
  AssignFunctor('TSIN');
}#FuncTSIN

#bind FuncTPAR to Ctrl+x menu Assign TPAR
sub FuncTPAR {
  AssignFunctor('TPAR');
}#FuncTPAR

#bind FuncORIG to Ctrl+y menu Assign ORIG
sub FuncORIG {
  AssignFunctor('ORIG');
}#FuncORIG

#bind FuncMOD to Ctrl+z menu Assign MOD
sub FuncMOD {
  AssignFunctor('MOD');
}#FuncMOD

#endif

package PML_A_View;

#binding-context PML_A_View
#bind ShowTNodes to t menu Show t-nodes
#binding-context PML_A_Edit
#bind PML_A_View->ShowTNodes to t menu Show t-nodes
sub ShowTNodes{ # TODO : spoils Undo !!!
  my $aid = $this->{id};
  my $num = CurrentTreeNumber();
  my @nodes;
  ChangingFile(0);
  TectogrammaticalTree() or return;
  foreach my $node ( GetTrees() ){
    while ($node) {
      if ( grep { s/^.*?#//;/^$aid$/ }
           $node->attr('a/lex.rf'),ListV($node->attr('a/aux.rf')) ) {
        push @nodes,$node;
      }
      $node=$node->following
    }
  }
  if ( @nodes ) {
    my @lemmas = map { ($_->{t_lemma})
                         .'.'.($_->{functor}).' : '.($_->{id})} @nodes;
    my $d = [[]];
    my@toBeCleared;
    if(main::listQuery
       ($grp->toplevel,
        'Select Node',
        'multiple',
        \@lemmas,
        $d,
        buttons=>[{-text=>'Delete',
                   -underline=>0,
                   -command=>
                   [sub{
                      my($l)=@_;
                      foreach my $sel(reverse $l->curselection){
                        my$line=$l->get($sel);
                        $line =~ s/.* : //;
                        my($node)=SearchForNodeById($line);
                        push @toBeCleared,$node;
                        $l->delete($sel);
                      }
                    }
                   ]}]
       )){
      if(@toBeCleared){
        SetFileSaveStatus(1);
        SaveUndo('Delete a/*.rf reference');
        foreach my$node(@toBeCleared){
          my $refid = CurrentFile()->metaData('refnames')->{adata};
          if($node->attr('a/lex.rf') eq $refid.'#'.$aid){
            delete $node->{a}{'lex.rf'};
          }
          @{$node->{a}{'aux.rf'}}
            =uniq(ListSubtract
                  ($node->{a}{'aux.rf'},
                   List($refid.'#'.$aid)
                  ));
        }
      }
      my $id = $d->[0];
      if($id){
        $id =~ s/.* : //;
        my ($node,$tree)=SearchForNodeById($id);
        TredMacro::GotoTree($tree);
        $this=$node;
        return 1;
      }
    }
  }
  PML_T::AnalyticalTree();
  my ($node,$tree)=SearchForNodeById($aid);
  TredMacro::GotoTree($tree);
  $this=$node;
}#ShowTNodes

1;

=back

=cut

#endif PML_T_Anot
