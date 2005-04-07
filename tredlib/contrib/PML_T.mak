# -*- cperl -*-

#ifndef PML_T
#define PML_T

#include "PML.mak"

package PML_T;

#encoding iso-8859-2


import PML;
sub first (&@);

=pod

=head1 PML_T

PML_T.mak - Miscelaneous macros for tectogrammatic layer of Prague
Dependency Treebank (PDT) 2.0.

=head2 REFERENCE

=over 4

=cut


=item AFile($fsfile?)

Return analytical file associated with a given (tectogrammatical)
file. If no file is given, the current file is assumed.

=cut

sub AFile {
  my $fsfile = $_[0] || $grp->{FSFile};
  return undef unless ref($fsfile->metaData('refnames')) and ref($fsfile->appData('ref'));
  my $refid = $fsfile->metaData('refnames')->{adata};
  $fsfile->appData('ref')->{$refid};
}

=item GetANodes($node?)

Returns a list of analytical nodes referenced from a given
tectogrammatical node. If no node is given, the function applies to
C<$this>.

=cut

sub GetANodes {
  my $node = $_[0] || $this;
  return grep defined, map { s/^.*#//; GetANodesHash()->{$_} } ListV($node->{'a.rf'});
}

=item GetANodeByID($id_or_ref)

Looks up an analytical node by its ID (or PMLREF - i.e. the ID
preceded by a file prefix of the form C<a#>). This function only works
if the current file is a tectogrammatical file and the requested node
belongs to an analytical file associated with it.

=cut

sub GetANodeByID {
  my ($arf)=@_;
  $arf =~ s/^.*#//;
  return GetANodesHash()->{$arf};
}

=item GetANodesHash()

Return a reference to a hash indexing analytical nodes of the
analytical file associated with the current tectogrammatical file. If
such a hash was not yet created, it is created upon the first call to
this function (or other functions calling it, such as C<GetANodes> or
C<GetANodeByID>.

=cut

sub GetANodesHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  return {} unless ref($fsfile);
  my $a_fs;
  if ($fsfile->appData('struct') eq 'adata') {
    $a_fs = $fsfile;
  } else {
    $a_fs = AFile($fsfile);
    return {} unless ref($a_fs);
  }
  return GetNodeHash($a_fs);
}

=item ClearANodesHash()

Clear the internal hash indexing analytical nodes of the analytical
file associated with the current tectogrammatical file.

=cut

sub ClearANodesHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  my $a_fs = AFile($fsfile);
  $a_fs->changeAppData('id-hash',undef) if ref($a_fs);
}


#ifdef TRED

=item AnalyticalTree()

This function is only available in TrEd (i.e. in GUI). It switches
current view to an analytical tree associated with a currently
displayed tectogrammatical tree.

=cut

sub AnalyticalTree {
  return unless SchemaName() eq 'tdata';
  return unless SwitchToAFile();
  $PML_T::laststylesheet=GetCurrentStylesheet();
  if (CurrentContext() eq 'PML_T_Edit') {
    SwitchContext('PML_A_Edit');
  } else {
    SwitchContext('PML_A_View');
  }
  SetCurrentStylesheet('PML_A');
  my $fsfile = $grp->{FSFile};
  #find current tree and new $this
  my $trees = $fsfile->treeList;
 TREE: for ($i=0;$i<=$#$trees;$i++) {
    foreach my $a_rf (ListV($root->{'a.rf'})) {
      $a_rf =~ s/^.*\#//;
      if ($trees->[$i]->{id} eq $a_rf) {
	$grp->{treeNo} = $i;
	$fsfile->currentTreeNo($i);
	# print "Found $a_rf at tree position $i\n";
	last TREE;
      }
    }
  }
  $root = $fsfile->tree($grp->{treeNo});
  my $a_ids = GetNodeHash($fsfile);
  my $first =
    first {
      ref($a_ids->{$_}) and ($a_ids->{$_}->root == $root) ? 1 : 0
    } map { my $s = $_; $s=~s/^.*\#//; $s; } ListV($this->{'a.rf'});
  $this = $a_ids->{$first};
  # print "New this: $this->{id}\n" if ref($this);
  ChangingFile(0);
}

sub SwitchToAFile {
  my $fsfile = $grp->{FSFile};
  return 0 unless SchemaName() eq 'tdata';
  my $ar_fs = AFile($fsfile);
  return 0 unless $ar_fs;
  # remember the file we came from:
  $ar_fs->changeAppData('tdata',$fsfile);
  $grp->{FSFile} = $ar_fs;
  return 1;
}

#endif TRED

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  my ($a_tree) = GetANodes($tree);
  return unless ($a_tree);
  my $node = $tree->following;
  my %refers_to;
  while ($node) {
    foreach (ListV($node->{'a.rf'})) {
      s/^.*\#//;
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
    push@out,([" ","space"])unless$first;
    $first=0;
    if ($node->{'m'}{form}ne$node->{'m'}{w}{token}){
      push@out,(['['.$node->{'m'}{w}{token}.']',@{$refers_to{$node->{id}}},'-over=>1','-foreground=>'.CustomColor('spell')]);
    }
    push@out,([$node->{'m'}{form},@{$refers_to{$node->{id}}}]);
  }
  return \@out;
}

sub node_style_hook {
  my ($node,$styles)=@_;
  my %line = ref($styles->{Line}) ? @{$styles->{Line}} : ();
  my %my_line;

  # make sure we only alter the very first line
  my $lines = scalar(split /&/,$line{coords});
  if ($lines>1) {
    for (keys %my_line) {
      my @l = split /&/,$line{$_};
      shift @l;
      $line{$_}=join '&',$my_line{$_},@l;
    }
  } else {
    $line{$_}=$my_line{$_} for keys %my_line;
  }

  if  ($node->{'coref_text.rf'} or $node->{'coref_gram.rf'} or $node->{'compl.rf'} or $node->{coref_special}) {
    my @gram = grep {$_ ne "" } ListV($node->{'coref_gram.rf'});
    my @text = grep {$_ ne "" } ListV($node->{'coref_text.rf'});
    my @compl = grep {$_ ne "" } ListV($node->{'compl.rf'});
    DrawCorefArrows($node,$styles,\%line,
		      [@gram,@text,@compl],
		      [(map 'grammatical',@gram),
		       (map 'textual',@text),
		       (map 'compl',@compl)
		      ]
                     );
  }
  1;
}

=item DrawCorefArrows

Called from C<node_style_hook>. Draws coreference arrows using
following properties: textual arrows in CustomColor C<arrow_textual>,
grammatical in <arrow_grammatical> (and dashed in Full stylesheet),
complement arrow in C<arrow_compl> (and dot-dashed in Full
stylesheet), segment arrow in C<arrow_segm> and exophora arrow in
C<arrow_exoph>.

=cut

sub DrawCorefArrows {
  my ($node,$styles,$line,$corefs,$cortypes)=@_;
  delete $coreflemmas{$node->{id}};
  my (@coords,@colors,@dash);
  my ($rotate_prv_snt,$rotate_nxt_snt,$rotate_dfr_doc)=(0,0,0);
  my $ids={};
  my $nd = $root; while ($nd) { $ids->{$nd->{id}}=1 } continue { $nd=$nd->following };
  foreach my $coref (@$corefs) {
    my $cortype=shift @$cortypes;
    if ($ids->{$coref}) { #index($coref,$id1)==0) {
      print STDERR "ref-arrows: Same sentence\n" if $main::macroDebug;
      # same sentence
      my $T="[?\$node->{id} eq '$coref'?]";
      my $X="(x$T-xn)";
      my $Y="(y$T-yn)";
      my $D="sqrt($X**2+$Y**2)";
      push @colors,CustomColor('arrow_'.$cortype);
      push @dash,GetPatternsByPrefix('full')?($cortype eq'compl'?'2,3,5,3':$cortype eq'grammatical'?'5,3':1):1;
      my $c = <<COORDS;

&n,n,
(x$T+xn)/2 - $Y*(25/$D+0.12),
(y$T+yn)/2 + $X*(25/$D+0.12),
x$T,y$T


COORDS
      push @coords,$c;

    } else { # should be always the same document, if it exists at all
      my($refed,$treeNo)=SearchForNodeById($coref);
      my $orientation=$treeNo-CurrentTreeNumber()-1;
      $orientation=$orientation>0 ? 'right' : ($orientation<0 ? 'left':0);
      $coreflemmas{$node->{id}}.=' '.$refed->{t_lemma};
      if($orientation){
          if($orientation eq'left'){
	    print STDERR "ref-arrows: Preceding sentence\n"if $main::macroDebug;
	    push @colors,CustomColor('arrow_'.$cortype);
            push @dash,1;
	    push @coords,"\&n,n,n-30,n+$rotate_prv_snt";
	    $rotate_prv_snt+=10;
          }else{ #right
	    print STDERR "ref-arrows: Following sentence\n" if $main::macroDebug;
	    push @colors,CustomColor('arrow_'.$cortype);
            push @dash,1;
	    push @coords,"\&n,n,n+30,n+$rotate_nxt_snt";
	    $rotate_nxt_snt+=10;
          }
        }else{
          print STDERR "ref-arrows: Not found!\n" if $main::macroDebug;
          push @colors,CustomColor('error');
            push @dash,1;
	  push @coords,"&n,n,n+$rotate_dfr_doc,n-25";
	  $rotate_dfr_doc+=10;
        }
    }
  }
  if($node->{coref_special}eq'segm') { # pointer to an unspecified segment of preceeding sentences
    print STDERR "ref-arrows: Segment - unaimed arrow\n" if $main::macroDebug;
    push @colors,CustomColor('arrow_segment');
    push @dash,1;
    push @coords,"&n,n,n-25,n+$rotate_prv_snt";
    $rotate_prv_snt+=10;
  }
  if($node->{coref_special}eq'exoph') {
    print STDERR "ref-arrows: Exophora\n" if $main::macroDebug;
    push @colors,CustomColor('arrow_exoph');
    push @dash,1;
    push @coords,"&n,n,n+$rotate_dfr_doc,n-25";
    $rotate_dfr_doc+=10;
  }
  $line->{-coords} ||= 'n,n,p,p';

  # make sure we don't alter any previous line
  my $lines = scalar($line->{-coords}=~/&/g)+1;
  for (qw(-arrow -dash -width -fill -smooth -arrowshape)) {
    $line->{$_}.='&'x($lines-scalar($line->{$_}=~/&/g)-1);
  }
  if (@coords) {
    AddStyle($styles,'Line',
	     -coords => $line->{-coords}.join("",@coords),
	     -arrow => $line->{-arrow}.('&last' x @coords),
             -arrowshape => $line->{-arrowshape}.('&16,18,3' x @coords),
	     -dash => $line->{-dash}.join('&','',@dash),
	     -width => $line->{-width}.('&1' x @coords),
	     -fill => $line->{-fill}.join("&","",@colors),
	     -smooth => $line->{-smooth}.('&1' x @coords));
  }
}

sub _FollowArrows{
  my$selected;
  if(@_>1){
    my$dialog=[];
    listQuery('Arrow to follow:'
              ,'browse'
              ,[map{
                my($type,$id,$node)=@$_;
                join ' ',$node->{t_lemma}.'   ',$type,$id;
              }@_],
              $dialog) or return;
    $selected=$dialog->[0];
    $selected=~s/^.* (.*)$/$1/;
  }else{
    $selected=$_[0][1];
    return 0 unless $selected;
  }
  my($found,$treeNo)=SearchForNodeById($selected);
  return unless $found;
  TredMacro::GotoTree($treeNo);
  $this=$found;
}#_FollowArrows

sub JumpToAntecedent {
  ChangingFile(0);
  return unless GUI();
  my@arrows;
  foreach my$type(@_){
    foreach my$arrow(ListV($this->{$type})){
      push@arrows,[$type,$arrow,SearchForNodeById($arrow)];
    }
  }
  _FollowArrows(@arrows)if@arrows;
}#JumpToAntecedent

sub JumpToAntecedentAll {
  ChangingFile(0);
  JumpToAntecedent('compl.rf','coref_text.rf','coref_gram.rf');
}#JumpToAntecedentAll

sub JumpToAntecedentCompl {
  ChangingFile(0);
  JumpToAntecedent('compl.rf');
}#JumpToAntecedentCompl

sub JumpToAntecedentText {
  ChangingFile(0);
  JumpToAntecedent('coref_text.rf');
}#JumpToAntecedentText

sub JumpToAntecedentGram {
  ChangingFile(0);
  JumpToAntecedent('coref_gram.rf');
}#JumpToAntecedentGram

sub get_status_line_hook {
  # get_status_line_hook may either return a string
  # or a pair [ field-definitions, field-styles ]
  return unless $this;
  return [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "     id: " => [qw(label)],
	   $this->{id} => [qw({id} value)],
	   "     a.rf: " => [qw(label)],
	   (join ", ",ListV($this->{'a.rf'})) => [qw({a.rf} value)],
           ,
	   ($this->{'val_frame.rf'} ?
	    ("     frame: " => [qw(label)],
	     join(",",AltV($this->{'val_frame.rf'})) => [qw({FRAME} value)]
	    ) : ()),
	  ],

	  # field styles
	  [
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	   "{commentA}" => [ -foreground => 'red' ],
	   "bg_white" => [ -background => 'white' ],
	  ]
	 ];
}


=item IsCoord($node?)

Check if the given node is a coordination according to its TGTS
functor (attribute C<functor>)

=cut

sub IsCoord {
  my $node=$_[0] || $this;
  return 0 unless $node;
  return $node->{functor} =~ /CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/;
}

=item ExpandCoord($node,$keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<functor>) expand it to a list of coordinated
nodes. Otherwise return the node itself. If the argument C<keep> is
true, include the coordination/aposition node in the list as well.

=cut

sub ExpandCoord {
  my ($node,$keep)=@_;
  return unless $node;
  if (IsCoord($node)) {
    return (($keep ? $node : ()),
	    map { ExpandCoord($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #ExpandCoord

=item GetSentenceString($tree?)

Return string representation of the given tree (suitable for
Tectogrammatical trees).

=cut

sub GetSentenceString {
  my $node=$_[0]||$this;
  my ($a_tree) = GetANodes($node->root);
  return unless ($a_tree);
  return get_sentence_string_A($a_tree);
}#GetSentenceString

=item GetEParents($node)

Return linguistic parents of a given node as appear in a TG tree.

=cut

sub GetEParents {
  my $node = $_[0] || $this;
  if ($node and $node->{is_member}) {
    while ($node and (!IsCoord($node) or $node->{is_member})) {
      $node=$node->parent;
    }
  }
  return () unless $node;
  $node=$node->parent;
  return () unless $node;
  return ($node) if !IsCoord($node);
  return (ExpandCoord($node));
} # GetEParents

=item GetEChildren($node?)

Return a list of nodes linguistically dependant on a given node.

=cut

sub FilterChildren { # node suff from
  my ($node,$suff,$from)=(shift,shift,shift);
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; #uncomment this line to get only first occurence
    unless ($node==$from){ # on the way up do not go back down again
      if(($suff&&$node->{is_member})
	 ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node unless IsCoord($node);
      }
      push @sons,FilterChildren($node,1,0)
	if (!$suff
	    &&IsCoord($node)
	    &&!$node->{is_member})
	  or($suff
	     &&IsCoord($node)
	     &&$node->{is_member});
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterChildren

sub GetEChildren { # node
  my $node=$_[0]||$this;
  return () if IsCoord($node);
  my @sons;
  my $init_node=$node;# for error message
  my $from;
  push @sons,FilterChildren($node,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node and $node->{nodetype}ne'root'
	  and ($node->{is_member} || !IsCoord($node))){
      $from=$node;$node=$node->parent;
      push @sons,FilterChildren($node,0,$from) if $node;
    }
    if ($node->{nodetype}eq'root'){
      stderr("Error: Missing coordination head: $init_node->{id} $node->{id} ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  @sons;
} # GetEChildren

=item GetEDescendants($node?)

Return a list of all nodes linguistically subordinated to a given node
(not including the node itself).

=cut

sub GetEDescendants {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { $_, GetEDescendants($_) } GetEChildren($node));
}

=item GetEAncestors($node?)

Return a list of all nodes linguistically superordinated to (ie
governing) a given node (not including the node itself).

=cut

sub GetEAncestors {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { ($_, GetEAncestors($_)) } GetEParents($node));
}


=item GetESiblings($node?)

Return linguistic siblings of a given node as appears in a
tectogrammatic tree. This doesn't include the node itself, neither
those children of the node's linguistic parent that are in
coordination with the node.

=cut

sub GetESiblings {
  my $node = $_[0] || $this;
  my $coord = GetNearestNonMember($node);
  return
    grep { GetNearestNonMember($_) != $coord }
    map { GetEChildren($_) }
    GetEParents($node)
} # GetESiblings

=item GetNearestNonMember($node?)

If the node is not a member of a coordination, return the node.  If it
is a member of a coordination, return the node representing the
highest coordination $node is a member of.

=cut

sub GetNearestNonMember {
 my $node = $_[0] || $this;
 while ($node->{is_member}) {
   $node=$node->parent;
 }
 return $node;
}

=item IsFiniteVerb($node?)

If the node is the head of a finite complex verb form (based on
C<a.rf> information and m/tag of the corresponding analytical nodes),
return 1, else return 0.

=cut

sub IsFiniteVerb {
  my $node = $_[0] || $this;
  return (first { $_->{'m'}{tag}=~/^V[^sf]/ } GetANodes($node)) ? 1 : 0;
}#IsFiniteVerb

=item IsPassive($node?)

If the node is the head of a passive-only verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub IsPassive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } GetANodes($node);
  return( @anodes == 1 and $anodes[0]->{'m'}{tag} =~ /^Vs/)
}#IsPassive

=item IsInfinitive($node?)

If the node is the head of an infinitive complex verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub IsInfinitive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } GetANodes($node);
  @anodes and not(&IsFiniteVerb or &IsPassive);
}#IsInfinitive


=item ModalVerbLemma($lemma)

Return 1 if trlemma is a member of the list of all possible modal verb
lemmas (morfological lemma suffixes (/[-`_].*/) are ignored).

=cut

sub ModalVerbLemma ($) {
  $_[0]=~/^(?:dát|dovést|hodlat|chtít|mít|moci|mus[ei]t|smìt|umìt)($|[-`_].*)/;
}#ModalVerbLemma

=item CreateStylesheets

Creates default stylesheets for PML tectogrammatic files unless
already defined. Most of the colors they use can be redefined in the
tred config file C<.tredrc> by adding a line of the form

  CustomColorsomething = ...

The stylesheets are named C<PML_T_Compact> and C<PML_T_Full>. Compact
stylesheet is suitable to be used on screen because it pictures many
features by means of colours whilst the Full stylesheet is better for
printing because it lists the values of almost all the attributes.

The stylesheets have the following features (if the stylesheet is not
mentioned, the description talks about the Compact one):

=over 4

1. C<t_lemma> is displayed on the first line. If the node's
C<is_parenthesis> is set to 1, the C<t_lemma> is displayed in
CustomColor C<parenthesis>. If there is a coreference leading to a
different sentence, the C<t_lemma> of the refered node is displayed in
CustomColor C<coref>.

2. Node's functor is displayed in CustomColor C<func>. If the node's
C<subfunctor> or C<is_state> are defined, they are indicated in
CustomColor C<subfunc>. In the Full stylesheet, C<is_member> is also
displayed as "M" in CustomColor C<coappa> and C<is_parenthesis> as
"P"in CustomColor C<parenthesis>.

3. For nodes of all types other than complex, C<nodetype> is displayed
in CustomColor C<nodetype>. For complex nodes, their C<gram/sempos> is
displayed in CustomColor C<complex>. In the Full stylesheet, all the
non-empty values of grammatemes are listed in CustomColor C<complex>,
and for ambiguous values the names of the attributes are displayed in
CustomColor C<detail>.

4. Generated nodes are displayed as squares, non-generated ones as
ovals.

5. Current node is displayed as bigger and with outline in CustomColor
C<current>.

6. Edges from nodes to roots or from nodes with C<functor> C<PAR,
PARTL, VOCAT, RHEM, CM, FPHR,> and C<PREC> to their parents are thin,
dashed and have the CustomColor C<line_normal>. Edges from
coordination heads with C<is_member> are thin and displayed in
CustomColor C<line_member>. Edges from other nodes with C<is_member>
to their coordination parents are displayed with the lower half thick
in CustomColor C<line_normal> and upper half thin in CustomColor
C<line_member>. Edges from nodes without C<is_member> to their
coordination parents are displayed thin in CustomColor C<line_comm>.
Edges from coordination nodes without C<is_member> to their parents
are displayed with the lower half thin in CustomColor C<line_member>
and upper half thick in CustomColor C<line_normal>. All other edges
are displayed half-thick in CustomColor C<line_normal>.

7. The attribute C<tfa> is reflected by the colour of the node.
CustomColors C<tfa_c, tfa_f, tfa_c>, and C<tfa_no> are used. In the
Full stylesheet, the value is also displayed before the functor in
C<tfa_text>.

8. Attributes C<gram, is_dsp_root, is_name_of_person,> and C<quot> are
listed in the hint box when the mouse cursor is over the node. In the
Full stylesheet, they are diplayed at the last line in CustomColor
C<detail>.

=back

=cut

sub CreateStylesheets{
  unless(StylesheetExists('PML_T_Compact')){
    SetStylesheetPatterns(<<'EOF','PML_T_Compact',1);
node:<? '#{customparenthesis}' if $${is_parenthesis} 
  ?><?$${nodetype}eq'root' ? '${id}' : '${t_lemma}'
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
   foreach my $gram (sort keys %{$this->{gram}}) {
     push @hintlines, "gram/".$gram." : ".$this->{gram}->{$gram} if $this->{gram}->{$gram}
   }
   push@hintlines, "is_dsp_root : 1" if $${is_dsp_root};
   push@hintlines, "is_name_of_person : 1" if $${is_name_of_person};
   push@hintlines, "quot : ". join(",",map{$_->{type}}ListV($this->{quot})) if $${quot};
   join"\n", @hintlines
?>
EOF
  }
  unless(StylesheetExists('PML_T_Full')){
    SetStylesheetPatterns(<<'EOF','PML_T_Full',1);
full:1

node:<?$${nodetype}eq'root' ? '${id}' : '${t_lemma}'
  ?><? '#{customcoref}.'.$PML_T::coreflemmas{$${id}}
    if $PML_T::coreflemmas{$${id}}ne'' ?>

node:<?
  ($${nodetype} eq 'root' ? '#{customnodetype}${nodetype}' :
  ($${tfa}=~/[tfc]/ ? '#{customtfa_text}${tfa}_' : '').
  '#{customfunc}${functor}').
  "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?><? '#{customcoappa}_${is_member=M}'if$${is_member} ?><? '#{customparenthesis}_${is_parenthesis=P}' if$${is_parenthesis} ?>

node:<? $${nodetype} !~/^(?:complex|root)$/
        ? '#{customnodetype}${nodetype}'
        : '#{customcomplex}${gram/sempos}'.join'',map{'.'.($this->{gram}{$_}eq'nr'?"#{customdetail}$_:#{customcomplex}":'')."\${gram/$_}" } sort grep{/mod/}keys%{$this->{gram}}
  ?>

node: <? $${nodetype} eq 'complex' ?
  join'.',map{(($this->{gram}{$_}=~/^(?:nr|inher)$/)?"#{customdetail}$_:":'')."#{customcomplex}\${gram/$_}" } sort grep{$this->{gram}->{$_}&&$_ !~/sempos|mod/}keys%{$this->{gram}}
  :''?>

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

node: #{customdetail}<? join'.',grep{$_}(
    ($${is_dsp_root}?'${is_dsp_root=dsp_root}':''),
    ($${is_name_of_person}?'${is_name_of_person=person_name}':''),
    ($${quot}?'${quot=quot/type:'.join(",",map{$_->{type}}ListV($this->{quot})).'}':'')
  )
  ?>

hint:<?
   my @hintlines;
   foreach my $gram (sort keys %{$this->{gram}}) {
     push @hintlines, "gram/".$gram." : ".$this->{gram}->{$gram} if $this->{gram}->{$gram}
   }
   push@hintlines, "is_dsp_root : 1" if $${is_dsp_root};
   push@hintlines, "is_name_of_person : 1" if $${is_name_of_person};
   push@hintlines, "quot : ". join(",",map{$_->{type}.'('.$_->{set_id}.')'}ListV($this->{quot})) if $${quot};
   join"\n", @hintlines
?>
EOF
  }
}#CreateStylesheets

sub allow_switch_context_hook {
  return 'stop' if SchemaName() ne 'tdata';
}
sub switch_context_hook {
  CreateStylesheets();
  SetCurrentStylesheet('PML_T_Compact'),Redraw() if GetCurrentStylesheet() eq STYLESHEET_FROM_FILE();
  undef$PML::arf;
}

## Show suite ##

sub NoShow {
  undef%PML_T::show;
  ChangingFile(0);
}#NoShow

sub ShowEParents {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEParents($node);
  ChangingFile(0);
}#ShowEParents

sub ShowEChildren {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEChildren($node);
  ChangingFile(0);
}#ShowEParents

sub ShowExpand {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}ExpandCoord($node);
  ChangingFile(0);
}#ShowExpand

sub ShowEDescendants {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEDescendants($node);
  ChangingFile(0);
}#ShowEDescendants

sub ShowEAncestors {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEAncestors($node);
  ChangingFile(0);
}#ShowEAncestors

sub ShowESiblings {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetESiblings($node);
  ChangingFile(0);
}#ShowESiblings

sub ShowNearestNonMember {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetNearestNonMember($node);
  ChangingFile(0);
}#ShowNearestNonMember

=item DeleteNode (node?)

Deletes $node or $this, attaches all its children to its parent and
recounts deepord. Cannot be used for the root.

=cut

sub DeleteNode{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  ChangingFile(0),return unless $node->parent;
  my$parent=$node->parent;
  foreach my$child($node->children){
    CutPaste($child,$parent);
  }
  DeleteLeafNode($node);
  $this=$parent unless@_;
  ChangingFile(1);
}#DeleteNode

=item DeleteSubtree (node?)

Deletes $node or $this and its whole subtree and recounts
deepord. Cannot be used for the root.

=cut

sub DeleteSubtree{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  ChangingFile(0),return unless $node->parent;
  my$parent=$node->parent;
  TredMacro::DeleteSubtree($node);
  $this=$parent unless@_;
  ChangingFile(1);
}#DeleteSubtree

=item NewNode (node?)

Add new node as a son of the given node or current node.

=cut

sub NewNode{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  my$new=NewSon($node);
  $new->{id}=$new->root->{id}.'a'.
    ((sort {$b<=>$a} map{$_->{id}=~/a([0-9]+)$/;$1}$root->descendants)[0]+1);
  my $type = first {$_->{name} eq 't-node' } Schema()->node_types;
  $new->set_type(Schema()->type($type))
}#NewNode

=item OpenValFrameList (node?, options...)

Open a window with a list of possible valency frames for a given node,
highlighting frames currently assigned to the node. All given options
are passed to the approporiate VallexGUI method. Most commonly used are
C<-no_assign =E<gt> 1> to suppress the Assign button,
C<-assign_func =E<gt> sub { my ($node,$frame_ids,$frame_text)=@_; ... }>
to specify a custom code for assigning the selected frame_ids to a node,
C<-lemma> and C<-pos> to override t_lemma and sempos of the node,
C<-frameid> to frames currently assigned to the node, C<-noadd => 1> to
forbid adding new words to the lexicon (also implied by C<-no-assign>.

=cut

sub OpenValFrameList {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;

  $VallexGUI::frameid_attr="val_frame.rf";
  $VallexGUI::lemma_attr="t_lemma";
  $VallexGUI::framere_attr=undef;
  $VallexGUI::sempos_attr="gram/sempos";
  my $refid = FileMetaData('refnames')->{vallex};
  my $rf = $node ? join('|',map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($node->{'val_frame.rf'})) : undef;
  VallexGUI::ChooseFrame(
    -lemma => $node ? $node->{t_lemma} : undef,
    -sempos => $node ? $node->{gram}{sempos} : undef,
    -frameid => $rf,
    -assignfunc => sub{},
    %opts
   );
}

sub ShowAssignedValFrames {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;
  my $refid = FileMetaData('refnames')->{vallex};
  my $rf = $node ? join('|',map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($node->{'val_frame.rf'})) : undef;
  VallexGUI::ShowFrames(-frameid => $rf);
  ChangingFile(0);
}

1;

=back

=cut

#endif PML_T
