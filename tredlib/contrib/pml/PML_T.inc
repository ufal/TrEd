# -*- cperl -*-

## Contains all code of PML package, suitable to be included.
## Should be included at the very beginning of a macro file.
## Do not forget to include <contrib/vallex/contrib.mac> before setting the package.

#encoding iso-8859-2

{ # PML_T.inc

use Carp;
BEGIN { import PML; }
use Scalar::Util qw(weaken);
sub first (&@);

=pod

=head1 PML_T

PML_T.mak - Miscellaneous macros for the tectogrammatic layer of Prague
Dependency Treebank (PDT) 2.0.

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
  return $fsfile->appData('ref')->{$refid};
}

=item GetANodeIDs($node?)

Returns a list of IDs of analytical nodes referenced from a given
tectogrammatical node. If no node is given, the function applies to
C<$this>.

=cut

sub GetANodeIDs {
  return map { my $id=$_; $id=~s/^.*?#//; $id } &GetANodeREFs;
}

=item GetANodeREFs($node?)

Returns a list of PMLREFs of analytical nodes referenced from a given
tectogrammatical node. If no node is given, the function applies to
C<$this>. This function is similar to C<GetANodeIDs()> but it doesn't
strip the file-ref part of the reference.

=cut

sub GetANodeREFs {
  my $node = $_[0] || $this;
  return $node->{'atree.rf'} if $node->{'atree.rf'} ne "";
  my $lex = $node->attr('a/lex.rf');
  return (($lex ne "" ? $lex : ()), ListV($node->attr('a/aux.rf')));
}

=item GetANodes($node?,$fsfile?)

Returns a list of analytical nodes referenced from a given
tectogrammatical node. This combines references from a/tree.rf
(root-node), a/aux.rf and a/lex.rf (non-root nodes). If no node is
given, the function applies to C<$this>. If the node belongs to other
file than the current file, the optional second argument must
specify the corresponding FSFile object.

=cut

sub GetANodes {
  my ($node,$fsfile)=@_;
  return grep defined, map { GetANodesHash($fsfile)->{$_} } GetANodeIDs($node);
}

=item GetALexNode($node?)

Returns an analytical node referenced from a/lex.rf attribute of a
given tectogrammatical node. If no node is given, the function applies
to C<$this>.

=cut

sub GetALexNode {
  my $node = @_ ? $_[0] : $this;
  return GetANodeByID($node->attr('a/lex.rf'));
}

=item GetAAuxNodes($node?)

Returns a list of analytical nodes referenced from a/aux.rf attribute
of a given tectogrammatical node. If no node is given, the function
applies to C<$this>.

=cut

sub GetAAuxNodes {
  my $node = @_ ? $_[0] : $this;
  return grep defined, map { GetANodeByID($_) } ListV($node->attr('a/aux.rf'));
}

=item GetANodeByID($id_or_ref,$fsfile?)

Looks up an analytical node by its ID (or PMLREF - i.e. the ID
preceded by a file prefix of the form C<a#>). This function only works
if the current file is a tectogrammatical file and the requested node
belongs to an analytical file associated with it.

=cut

sub GetANodeByID {
  my ($arf,$fsfile)=@_;
  $arf =~ s/^.*?#//;
  return GetANodesHash($fsfile)->{$arf};
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
  return;
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
  my $t_root = $root;
  my $t_node = $this;
  $PML_T::laststylesheet=GetCurrentStylesheet();
  my $desiredcontext=CurrentContext();
  if($PML::desiredcontext=~/^PML_(?:.*_)?A_/){
    SwitchContext($PML::desiredcontext);
  }elsif (CurrentContext() eq 'PML_T_Edit') {
    SwitchContext('PML_A_Edit');
  } else {
    SwitchContext('PML_A_View');
  }
  $PML::desiredcontext=$desiredcontext;
  SetCurrentStylesheet('PML_A');
  my $fsfile = $grp->{FSFile};
  #find current tree and new $this
  my $trees = $fsfile->treeList;
  my $treeNo = $fsfile->currentTreeNo+0;
 TREE: for (my $i=0;$i<=$#$trees;$i++) {
    foreach my $a_rf (GetANodeIDs($t_root)) {
      $a_rf =~ s/^.*?#//;
      if ($trees->[$i]->{id} eq $a_rf) {
	$treeNo = $i;
	last TREE;
      }
    }
  }
  TredMacro::GotoTree($treeNo+1); # changes $root and $this
  my $a_ids = GetNodeHash($fsfile);
  my $first =
    first {
      ref($a_ids->{$_}) and ($a_ids->{$_}->root == $root) ? 1 : 0
    } GetANodeIDs($t_node);
  $this = $a_ids->{$first};
  ChangingFile(0);
  return 1;
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


# sub file_resumed_hook {
#   if (SchemaName() =~ /^a(?:edit)?data$/) {
#     SetCurrentStylesheet(STYLESHEET_FROM_FILE());
#     if (CurrentContext() eq 'PML_T_Edit') {
#       SwitchContext('PML_A_Edit');
#     } else {
#       SwitchContext('PML_A_View');
#     }
#   } else {
#     &TredMacro::file_resumed_hook;
#   }
#   return;
# }

#endif TRED

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
    push@out,([" ","space"])unless$first;
    $first=0;
    my $token = join(" ",map { $_->{token} } ListV($node->attr('m/w')));
    my $form = $node->attr('m/form');
    if ($form ne $token){
      push@out,(['['.$token.']',@{$refers_to{$node->{id}}},'-over=>1','-foreground=>'.CustomColor('spell')]);
    }
    push@out,([$form,@{$refers_to{$node->{id}}}]);
  }
  return \@out;
}

#include <contrib/support/arrows.inc>


# init caches
sub root_style_hook {
  my ($node,$styles)=@_;
  %PML_T::coreflemmas_hash=();
  %PML_T::displayed_nodes;
  @PML_T::displayed_nodes{ GetDisplayedNodes() } = ();
  DrawArrows_init();
  return;
}
# clear caches
sub after_redraw_hook {
  %PML_T::coreflemmas_hash=();
  %PML_T::displayed_nodes=();
  DrawArrows_cleanup();
  return;
}

sub node_style_hook {
  my ($node,$styles)=@_;
  if  ($node->{'coref_text.rf'} or $node->{'coref_gram.rf'} or $node->{'compl.rf'} or $node->{coref_special}) {
    my @gram = grep {$_ ne "" } ListV($node->{'coref_gram.rf'});
    my @text = grep {$_ ne "" } ListV($node->{'coref_text.rf'});
    my @compl = grep {$_ ne "" } ListV($node->{'compl.rf'});
    DrawCorefArrows($node,$styles,undef,
		      [@gram,@text,@compl],
		      [(map 'grammatical',@gram),
		       (map 'textual',@text),
		       (map 'compl',@compl)
		      ],
                     );
  }
  return 1;
}

=item DrawCorefArrows()

Called from C<node_style_hook>. Draws coreference arrows using
following properties: textual arrows in CustomColor C<arrow_textual>,
grammatical in <arrow_grammatical> (and dashed in Full stylesheet),
complement arrow in C<arrow_compl> (and dot-dashed in Full
stylesheet), segment arrow in C<arrow_segm> and exophora arrow in
C<arrow_exoph>.

=cut

sub DrawCorefArrows {
  my ($node,$styles,$line,$corefs,$cortypes,$displayed_nodes_hash)=@_;
  my ($rotate_prv_snt,$rotate_nxt_snt,$rotate_dfr_doc)=(0,0,0);
  my @edges;
  my %common = (
    -arrow => 'last',
    -smooth => 1,
    -arrowshape => '16,18,3',
    -width => 1,
    -dash => '',
  );
  foreach my $coref (@$corefs) {
    my $cortype=shift @$cortypes;
    my($refed,$treeNo)=SearchForNodeById($coref);
    my %edge = (-tag => $cortype);
    if ($refed) {
      my $orientation=
	exists($PML_T::displayed_nodes{$refed}) ? 0 : $treeNo-CurrentTreeNumber()-1;
      $PML_T::coreflemmas_hash{$node->{id}}.=' '.$refed->{t_lemma} if $orientation;
      if ($orientation == 0) {
	$edge{-target} = $refed;
	$edge{-fill}=CustomColor('arrow_'.$cortype);
	$edge{-dash}=GetPatternsByPrefix('full')?($cortype eq'compl'?'2,3,5,3':$cortype eq'grammatical'?'5,3':''):'';
      } elsif ($orientation<0) {
	print STDERR "ref-arrows: Preceding sentence\n"if $main::macroDebug;
	$edge{-fill}=CustomColor('arrow_'.$cortype);
	$edge{-deltax}=-30;
	$edge{-deltay}=10*($rotate_prv_snt++);
      }else{ #right
	print STDERR "ref-arrows: Following sentence\n" if $main::macroDebug;
	$edge{-fill}=CustomColor('arrow_'.$cortype);
	$edge{-deltax}=+30;
	$edge{-deltay}=10*($rotate_nxt_snt++);
      }
    } else {
      print STDERR "ref-arrows: Not found!\n" if $main::macroDebug;
      $edge{-fill}=CustomColor('error');
      $edge{-deltax}=10*($rotate_dfr_doc++);
      $edge{-deltay}=-25;
    }
    push @edges,\%edge;
  }
  if ($node->{coref_special} eq 'segm') { # pointer to an unspecified segment of preceeding sentences
    print STDERR "ref-arrows: Segment - unaimed arrow\n" if $main::macroDebug; 
   push @edges, {
      -fill   => CustomColor('arrow_segment'),
      -deltax => -25,
      -deltay => 10*($rotate_prv_snt++),
      -tag => 'segm',
    };
  }
  if ($node->{coref_special} eq 'exoph') {
    print STDERR "ref-arrows: Exophora\n" if $main::macroDebug;
    push @edges, {
      -fill   => CustomColor('arrow_exoph'),
      -deltax => 10*($rotate_dfr_snt++),
      -deltay => -25,
      -tag => 'exoph',
    };
  }
  DrawArrows($node,$styles,\@edges,\%common);
}

sub _FollowArrows{
  my$selected;
  if(@_>1){
    my$dialog=[];
    ListQuery('Arrow to follow:'
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
  return;
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
  return;
}#JumpToAntecedent

sub JumpToAntecedentAll {
  ChangingFile(0);
  JumpToAntecedent('compl.rf','coref_text.rf','coref_gram.rf');
  return;
}#JumpToAntecedentAll

sub JumpToAntecedentCompl {
  ChangingFile(0);
  JumpToAntecedent('compl.rf');
  return;
}#JumpToAntecedentCompl

sub JumpToAntecedentText {
  ChangingFile(0);
  JumpToAntecedent('coref_text.rf');
  return;
}#JumpToAntecedentText

sub JumpToAntecedentGram {
  ChangingFile(0);
  JumpToAntecedent('coref_gram.rf');
  return;
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
	   "     a: " => [qw(label)],
	   (join ", ",GetANodeREFs($this)) => [($this->{nodetype} eq 'root' ? '{atree.rf}' : '{a}'), 'value'],
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
  return $node->{functor} =~ /ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS/;
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
  return PML_A::GetSentenceString($a_tree);
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

sub _FilterEChildren { # node suff from
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
      push @sons,_FilterEChildren($node,1,0)
	if (!$suff
	    &&IsCoord($node)
	    &&!$node->{is_member})
	  or($suff
	     &&IsCoord($node)
	     &&$node->{is_member});
    } # unless node == from
    $node=$node->rbrother;
  }
  return @sons;
} # _FilterEChildren

sub GetEChildren { # node
  my $node=$_[0]||$this;
  return () if IsCoord($node);
  my @sons;
  my $init_node=$node;# for error message
  my $from;
  push @sons,_FilterEChildren($node,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node and $node->{nodetype}ne'root'
	  and ($node->{is_member} || !IsCoord($node))){
      $from=$node;$node=$node->parent;
      push @sons,_FilterEChildren($node,0,$from) if $node;
    }
    if ($node->{nodetype}eq'root'){
      stderr("Error: Missing coordination head: $init_node->{id} $node->{id} ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  return @sons;
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
C<m/tag> of the referenced analytical nodes), return 1, else return 0.

=cut

sub IsFiniteVerb {
  my $node = $_[0] || $this;
  return (first { $_->attr('m/tag')=~/^V[^sf]/ } GetANodes($node)) ? 1 : 0;
}#IsFiniteVerb

=item IsPassive($node?)

If the node is the head of a passive-only verb form, (based on
C<m/tag> of the referenced analytical nodes), return 1, else return 0.

=cut

sub IsPassive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->attr('m/tag') =~ /^V/ } GetANodes($node);
  return( @anodes == 1 and $anodes[0]->attr('m/tag') =~ /^Vs/)
}#IsPassive

=item IsInfinitive($node?)

If the node is the head of an infinitive complex verb form, (based on
C<m/tag> of the referenced analytical nodes), return 1, else return 0.

=cut

sub IsInfinitive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->attr('m/tag') =~ /^V/ } GetANodes($node);
  return (@anodes and not(&IsFiniteVerb or &IsPassive)) ? 1 : 0;
}#IsInfinitive


=item IsModalVerbLemma($lemma)

Return 1 if trlemma is a member of the list of all possible modal verb
lemmas (morfological lemma suffixes (/[-`_].*/) are ignored).

=cut

sub IsModalVerbLemma ($) {
  return ($_[0]=~/^(?:dát|dovést|hodlat|chtít|mít|moci|mus[ei]t|smìt|umìt)($|[-`_].*)/) ? 1 : 0;
}#IsModalVerbLemma

=item ModalVerbLemma($lemma)

Deprecated alias for  IsModalVerbLemma

=cut

BEGIN {
  *ModalVerbLemma = \&IsModalVerbLemma;
}

=item CreateStylesheets()

Creates default stylesheets for PML tectogrammatic files unless
already defined. Most of the colors they use can be redefined in the
tred config file C<.tredrc> by adding a line of the form

  CustomColorsomething = ...

Default values can be found in C<PML.mak>. The stylesheets are named
C<PML_T_Compact> and C<PML_T_Full>. Compact stylesheet is suitable to
be used on screen because it pictures many features by means of
colours whilst the Full stylesheet is better for printing because it
lists the values of almost all the attributes.

The stylesheets have the following features (if the stylesheet is not
mentioned, the description talks about the Compact one):

=over 4

=item 1.

C<t_lemma> is displayed on the first line. If the node's
C<is_parenthesis> is set to 1, the C<t_lemma> is displayed in
CustomColor C<parenthesis> in the Compact stylesheet. If the node's
C<sentmod> is non-empty, its value is displayed in CustomColor
C<detail> after a dot. If there is a coreference leading to a
different sentence, the C<t_lemma> of the refered node is displayed in
CustomColor C<coref>, too.

=item 2.

Node's functor is displayed in CustomColor C<func>. If the node's
C<subfunctor> or C<is_state> are defined, they are indicated in
CustomColor C<subfunc>. In the Full stylesheet, C<is_member> is also
displayed as "M" in CustomColor C<coappa> and C<is_parenthesis> as "P"
in CustomColor C<parenthesis>.

=item 3.

For nodes of all types other than complex, C<nodetype> is displayed
in CustomColor C<nodetype>. For complex nodes, their C<gram/sempos> is
displayed in CustomColor C<complex>. In the Full stylesheet, all the
non-empty values of grammatemes are listed in CustomColor C<detail>,
and for ambiguous values the names of the attributes are displayed in
CustomColor C<detailheader>.

=item 4.

Generated nodes are displayed as squares, non-generated ones as
ovals.

=item 5. 

Current node is displayed as bigger and with outline in CustomColor
C<current>.

=item 6.

Edges from nodes to roots or from nodes with C<functor> C<PAR,
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

=item 7.

The attribute C<tfa> is reflected by the colour of the node.
CustomColors C<tfa_c, tfa_f, tfa_c>, and C<tfa_no> are used. In the
Full stylesheet, the value is also displayed before the functor in
C<tfa_text>.

=item 8.

Attributes C<gram, is_dsp_root, is_name_of_person,> and C<quot> are
listed in the hint box when the mouse cursor is over the node. In the
Full stylesheet, they are diplayed at the last line in CustomColor
C<detail> (see 3).

=back

=cut

sub CreateStylesheets{
  unless(StylesheetExists('PML_T_Compact')){
    SetStylesheetPatterns(<<'EOF','PML_T_Compact',1);
node:<? '#{customparenthesis}' if $${is_parenthesis}
  ?><? $${nodetype}eq'root' ? '${id}' : '${t_lemma}'
  ?><? '#{customdetail}.${sentmod}'if$${sentmod}
  ?><? '#{customcoref}'.$PML_T::coreflemmas_hash{$${id}}
    if $PML_T::coreflemmas_hash{$${id}}ne'' ?>

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
   join"\n", @hintlines
?>
EOF
  }
  unless(StylesheetExists('PML_T_Full')){
    SetStylesheetPatterns(<<'EOF','PML_T_Full',1);
full:1

node:<? $${nodetype}eq'root' ? '${id}' : '${t_lemma}'
  ?><? '#{customdetail}.${sentmod}'if$${sentmod}
  ?><? ('#{customcoref}'.$PML_T::coreflemmas_hash{$${id}})
    if $PML_T::coreflemmas_hash{$${id}}ne'' ?>

node:<?
  ($${nodetype} eq 'root' ? '#{customnodetype}${nodetype}' :
  ($${tfa}=~/[tfc]/ ? '#{customtfa_text}${tfa}_' : '').
  '#{customfunc}${functor}').
  "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?><? '#{customcoappa}_${is_member=M}'if$${is_member} ?><? '#{customparenthesis}_${is_parenthesis=P}' if$${is_parenthesis} ?>


node:<? $${nodetype} !~/^(?:complex|root)$/
        ? '#{customnodetype}${nodetype}'
        : '#{customcomplex}${gram/sempos}'.(
        ref($this->{gram}) ?
          '#{customdetail} '.join'.', map{($this->{gram}{$_}=~/^(?:nr|nil)$/?"#{customdetailheader}$_:#{customdetail}":'')."\${gram/$_}" } sort grep{/mod/}keys%{$this->{gram}} : '') ?>

node: <? ($${nodetype} eq 'complex' and ref($this->{gram}))?
  join'.',map{(($this->{gram}{$_}=~/^(?:nil|nr|inher)$/)?"#{customdetailheader}$_:":'')."#{customdetail}\${gram/$_}" } sort grep{$this->{gram}->{$_}&&$_ !~/sempos|mod/}keys%{$this->{gram}}
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
   if (ref($this->{gram})) {
     foreach my $gram (sort keys %{$this->{gram}}) {
       push @hintlines, "gram/".$gram." : ".$this->{gram}->{$gram} if $this->{gram}->{$gram}
     }
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
  my $cur_stylesheet = GetCurrentStylesheet();
  if ($cur_stylesheet eq STYLESHEET_FROM_FILE() or
      $cur_stylesheet =~ /^PML_(?:\w+_)?[^T](?:_|\b)/){
    SetCurrentStylesheet('PML_T_Compact');
    Redraw() if GUI();
  }
  undef $PML::arf;
  return;
}

## Show suite ##

sub NoShow {
  undef %PML_T::show;
  ChangingFile(0);
}#NoShow

sub ShowEParents {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEParents($node);
  ChangingFile(0);
}#ShowEParents

sub ShowEChildren {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEChildren($node);
  ChangingFile(0);
}#ShowEParents

sub ShowExpand {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}ExpandCoord($node);
  ChangingFile(0);
}#ShowExpand

sub ShowEDescendants {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEDescendants($node);
  ChangingFile(0);
}#ShowEDescendants

sub ShowEAncestors {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetEAncestors($node);
  ChangingFile(0);
}#ShowEAncestors

sub ShowESiblings {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetESiblings($node);
  ChangingFile(0);
}#ShowESiblings

sub ShowNearestNonMember {
  my $node=$this;
  undef %PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetNearestNonMember($node);
  ChangingFile(0);
}#ShowNearestNonMember

=item DeleteNode(node?)

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
  delete GetNodeHash()->{$node->{id}};
  DeleteLeafNode($node);
  $this=$parent unless @_;
  ChangingFile(1);
  return 1;
}#DeleteNode

=item DeleteSubtree(node?)

Deletes $node or $this and its whole subtree and recounts
deepord. Cannot be used for the root.

=cut

sub DeleteSubtree{
  shift unless ref $_[0];
  my $node=$_[0]||$this;
  ChangingFile(0),return unless $node->parent;
  my $parent=$node->parent;
  my $id_hash = GetNodeHash();
  if ($id_hash) {
    for my $n ($node,$node->descendants) {
      delete $id_hash->{$n->{id}};
    }
  }
  TredMacro::DeleteSubtree($node);
  $this=$parent unless @_;
  ChangingFile(1);
  return 1;
}#DeleteSubtree

=item NewNode(node?,id?)

Add new node as a son of the given node or current node, initializes
the new node using InitNode. If id is specified, it is assigned to the
new node. Otherwise, a unique ID is computed and assigned to the node
using NewID. Not all the required attributes are being set!

=cut

sub NewNode{
  shift unless ref($_[0]);
  my ($node,$id)=@_;
  $node ||= $this;
  my $new = InitNode(NewSon($node),$node);
  $id||=NewID($new);
  $new->{id} = $id;
  weaken( GetNodeHash()->{$id} = $new );
  return $new;
}#NewNode

=item InitNode(node,obj?)

Initialize already existing FSNode object as a t-node by associating
it with t-node PML schema type. If the node belongs to a different
file than the current one, the FSFile or some already initialized node
of that file must be specified as the second argument. Returns the
initialized node.

=cut

sub InitNode{
  shift unless ref($_[0]);
  my ($node,$obj)=@_;
  croak("InitNode: no node specified") unless ref($node);
  my $schema = Schema($obj);
  croak("InitNode: Couldn't derive PML schema") unless (ref($schema));
  $node->set_type_by_name($schema,'t-node.type');
  return $node;
}#InitNode

=item NewID(node?)

Tries to compute a new unique ID based on the ID's in the tree to
which the given node belongs. If no node is specified, the
global variable $root is used. Returns the computed ID.

=cut

sub NewID {
  shift unless ref($_[0]);
  my $top = ref($_[0]) ? $_[0]->root : $root;
  my $id = $top->{id}.'a'.
    ((sort {$b<=>$a} map{$_->{id}=~/a([0-9]+)$/;$1}$top->descendants)[0]+1);
  return $id;
}#NewNode

sub FindVallex {
  my $refid = FileMetaData('refnames')->{vallex};
  my $vallex_file = FileMetaData('references')->{$refid};
  $vallex_file = ResolvePath(FileName(),$vallex_file,1);
  return ($refid, $vallex_file);
}


=item OpenValFrameList(node?,options...)

Open a window with a list of possible valency frames for a given node,
highlighting frames currently assigned to the node. All given options
are passed to the approporiate ValLex::GUI method. Most commonly used are
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

  local $ValLex::GUI::frameid_attr="val_frame.rf";
  local $ValLex::GUI::lemma_attr="t_lemma";
  local $ValLex::GUI::framere_attr=undef;
  local $ValLex::GUI::sempos_attr="gram/sempos";
  my ($refid,$vallex_file) = FindVallex();
  my $rf = $node ? join('|',map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($node->{'val_frame.rf'})) : undef;
  ValLex::GUI::ChooseFrame({
    -vallex_file => $vallex_file,
    -lemma => $node ? $node->{t_lemma} : undef,
    -sempos => $node ? $node->attr('gram/sempos') : undef,
    -lemma_attr => 't_lemma',
    -sempos_attr => 'gram/sempos',
    -frameid => $rf,
    -assignfunc => sub{},
    %opts
   });
  ChangingFile(0);
}


=item OpenValLexicon(options...)

Open valency lexicon editor/browser GUI. All given options are passed
to the approporiate ValLex::GUI method. Most commonly used are C<-lemma>
and C<-pos> to override t_lemma and sempos of the node and C<-frameid>
to frames currently assigned to the node.

=cut

sub OpenValLexicon {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;

  local $ValLex::GUI::frameid_attr="val_frame.rf";
  local $ValLex::GUI::lemma_attr="t_lemma";
  local $ValLex::GUI::framere_attr=undef;
  local $ValLex::GUI::sempos_attr="gram/sempos";
  my ($refid,$vallex_file) = FindVallex();
  my $rf = $node ? join('|',map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($node->{'val_frame.rf'})) : undef;
  ValLex::GUI::OpenEditor(
    {
      -vallex_file => $vallex_file,
      -lemma => $node ? $node->{t_lemma} : undef,
      -sempos => $node ? $node->attr('gram/sempos') : undef,
      -frameid => $rf,
      %opts
    });
  ChangingFile(0);
  return;
}


sub ShowAssignedValFrames {
  shift unless @_ and ref($_[0]);
  my $node = shift || $this;
  my %opts = @_;
  my ($refid,$vallex_file) = FindVallex();
  my $rf = $node ? join('|',map { my $x=$_;$x=~s/^\Q$refid\E#//; $x } AltV($node->{'val_frame.rf'})) : undef;
  ValLex::GUI::ShowFrames(
    -vallex_file => $vallex_file,
    -frameid => $rf
   );
  ChangingFile(0);
  return;
}

} # PML_T.inc

=back

=cut
