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

=item getANodes($node?)

Returns a list of analytical nodes referenced from a given
tectogrammatical node. If no node is given, the function applies to
C<$this>.

=cut

sub getANodes {
  my $node = $_[0] || $this;
  return grep defined, map { s/^.*#//; getANodesHash()->{$_} } ListV($node->{'a.rf'});
}

=item getANodeByID($id_or_ref)

Looks up an analytical node by its ID (or PMLREF - i.e. the ID
preceded by a file prefix of the form C<a#>). This function only works
if the current file is a tectogrammatical file and the requested node
belongs to an analytical file associated with it.

=cut

sub getANodeByID {
  my ($arf)=@_;
  $arf =~ s/^.*#//;
  return getANodesHash()->{$arf};
}

=item getANodesHash()

Return a reference to a hash indexing analytical nodes of the
analytical file associated with the current tectogrammatical file. If
such a hash was not yet created, it is created upon the first call to
this function (or other functions calling it, such as C<getANodes> or
C<getANodeByID>.

=cut

sub getANodesHash {
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
  return getNodeHash($a_fs);
}

=item clearANodesHash()

Clear the internal hash indexing analytical nodes of the analytical
file associated with the current tectogrammatical file.

=cut

sub clearANodesHash {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  my $a_fs = AFile($fsfile);
  $a_fs->changeAppData('id-hash',undef) if ref($a_fs);
}


#ifdef TRED

=item analytical_tree()

This function is only available in TrEd (i.e. in GUI). It switches
current view to an analytical tree associated with a currently
displayed tectogrammatical tree.

=cut

sub analytical_tree {
  return unless schema_name() eq 'tdata';
  return unless switch_to_afile();
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
	print "Found $a_rf at tree position $i\n";
	last TREE;
      }
    }
  }
  $root = $fsfile->tree($grp->{treeNo});
  my $a_ids = getANodesHash($fsfile);
  my $first =
    first {
      ref($a_ids->{$_}) and ($a_ids->{$_}->root == $root) ? 1 : 0
    } map { my $s = $_; $s=~s/^.*\#//; $s; } ListV($this->{'a.rf'});
  $this = $a_ids->{$first};
  print "New this: $this->{id}\n" if ref($this);
  ChangingFile(0);
}

sub switch_to_afile {
  my $fsfile = $grp->{FSFile};
  return 0 unless schema_name() eq 'tdata';
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
  my ($a_tree) = getANodes($tree);
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
    draw_coref_arrows($node,$styles,\%line,
		      [@gram,@text,@compl],
		      [(map 'grammatical',@gram),
		       (map 'textual',@text),
		       (map 'compl',@compl)
		      ]
                     );
  }
  1;
}

sub draw_coref_arrows {
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
      my($step_l,$step_r)=(1,1);
      my $current=CurrentTreeNumber();
      my @trees=GetTrees();
      my $maxnum=$#trees;
      my $orientation;

      while($step_l!=0 or $step_r!=0){
        if($step_l){
          if (my$refed=first { $_->{id} eq $coref } $trees[$current-$step_l] -> descendants){
            $orientation='left';
            $coreflemmas{$node->{id}}.=$refed->{t_lemma};
            last;
          }
          $step_l=0 if ($current-(++$step_l))<0;
        }
        if($step_r){
          if (my$refed=first { $_->{id} eq $coref } $trees[$current+$step_r] -> descendants){
            $coreflemmas{$node->{id}}.=$refed->{t_lemma};
            $orientation='right';
            last;
          }
          $step_r=0 if ($current+(++$step_r))>$maxnum;
        }
      }
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


=item is_coord($node?)

Check if the given node is a coordination according to its TGTS
functor (attribute C<functor>)

=cut

sub is_coord {
  my $node=$_[0] || $this;
  return 0 unless $node;
  return $node->{functor} =~ /CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/;
}

=item expand_coord($node,$keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<functor>) expand it to a list of coordinated
nodes. Otherwise return the node itself. If the argument C<keep> is
true, include the coordination/aposition node in the list as well.

=cut

sub expand_coord {
  my ($node,$keep)=@_;
  return unless $node;
  if (is_coord($node)) {
    return (($keep ? $node : ()),
	    map { expand_coord($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #expand_coord

=item get_sentence_string($tree?)

Return string representation of the given tree (suitable for
Tectogrammatical trees).

=cut

sub get_sentence_string {
  my $node=$_[0]||$this;
  my ($a_tree) = getANodes($node->root);
  return unless ($a_tree);
  return get_sentence_string_A($a_tree);
}#get_sentence_string

=item GetFathers($node)

Return linguistic parents of a given node as appear in a TG tree.

=cut

sub GetFathers {
  my $node = $_[0] || $this;
  if ($node and $node->{is_member}) {
    while ($node and (!is_coord($node) or $node->{is_member})) {
      $node=$node->parent;
    }
  }
  return () unless $node;
  $node=$node->parent;
  return () unless $node;
  return ($node) if !is_coord($node);
  return (expand_coord($node));
} # GetFathers

=item GetChildren($node?)

Return a list of nodes linguistically dependant on a given node.

=cut

sub FilterSons { # node suff from
  my ($node,$suff,$from)=(shift,shift,shift);
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; #uncomment this line to get only first occurence
    unless ($node==$from){ # on the way up do not go back down again
      if(($suff&&$node->{is_member})
	 ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node unless is_coord($node);
      }
      push @sons,FilterSons($node,1,0)
	if (!$suff
	    &&is_coord($node)
	    &&!$node->{is_member})
	  or($suff
	     &&is_coord($node)
	     &&$node->{is_member});
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons

sub GetChildren { # node
  my $node=$_[0]||$this;
  return () if is_coord($node);
  my @sons;
  my $init_node=$node;# for error message
  my $from;
  push @sons,FilterSons($node,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node and $node->{nodetype}ne'root'
	  and ($node->{is_member} || !is_coord($node))){
      $from=$node;$node=$node->parent;
      push @sons,FilterSons($node,0,$from) if $node;
    }
    if ($node->{nodetype}eq'root'){
      stderr("Error: Missing coordination head: $init_node->{id} $node->{id} ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  @sons;
} # GetChildren

=item GetDescendants($node?)

Return a list of all nodes linguistically subordinated to a given node
(not including the node itself).

=cut

sub GetDescendants {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { $_, GetDescendants($_) } GetChildren($node));
}

=item GetAncestors($node?)

Return a list of all nodes linguistically superordinated to (ie
governing) a given node (not including the node itself).

=cut

sub GetAncestors {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { ($_, GetAncestors($_)) } GetFathers($node));
}


=item GetTrueSiblings($node?)

Return linguistic siblings of a given node as appears in a
tectogrammatic tree. This doesn't include the node itself, neither
those children of the node's linguistic parent that are in
coordination with the node.

=cut

sub GetTrueSiblings {
  my $node = $_[0] || $this;
  my $coord = GetNearestNonMember($node);
  return
    grep { GetNearestNonMember($_) != $coord }
    map { GetChildren($_) }
    GetFathers($node)
} # GetTrueSiblings

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

=item isFiniteVerb($node?)

If the node is the head of a finite complex verb form (based on
C<a.rf> information and m/tag of the corresponding analytical nodes),
return 1, else return 0.

=cut

sub isFiniteVerb {
  my $node = $_[0] || $this;
  return (first { $_->{'m'}{tag}=~/^V[^sf]/ } getANodes($node)) ? 1 : 0;
}#isFiniteVerb

=item isPassive($node?)

If the node is the head of a passive-only verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub isPassive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } getANodes($node);
  return( @anodes == 1 and $anodes[0]->{'m'}{tag} =~ /^Vs/)
}#isPassive

=item isInfinitive($node?)

If the node is the head of an infinitive complex verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub isInfinitive {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } getANodes($node);
  @anodes and not(&isFiniteVerb or &isPassive);
}#isInfinitive


=item modal_verb_lemma($lemma)

Return 1 if trlemma is a member of the list of all possible modal verb
lemmas (morfological lemma suffixes (/[-`_].*/) are ignored).

=cut

sub modal_verb_lemma ($) {
  $_[0]=~/^(?:dát|dovést|hodlat|chtít|mít|moci|mus[ei]t|smìt|umìt)($|[-`_].*)/;
}#modal_verb_lemma

=item create_stylesheets

Creates default stylesheets for PML tectogrammatic files unless
already defined.

=cut

sub create_stylesheets{
  unless(StylesheetExists('PML_T_Compact')){
    SetStylesheetPatterns(<<'EOF','PML_T_Compact',1);
node:<? '#{customparenthesis}' if $${is_parenthesis} 
  ?><?$${nodetype}eq'root' ? '${id}' : '${t_lemma}'
  ?><? '#{customcoref}.'.$PML_T::coreflemmas{$${id}}
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
    if (PML_T::is_coord($this)and PML_T::is_coord($this->parent)) {
      '#{Line-width:1}#{Line-fill:'.CustomColor('line_normal').'}'
    } elsif ($this->parent and PML_T::is_coord($this->parent)) {
      '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:3&1}#{Line-fill:'.
       CustomColor('line_normal').'&'.CustomColor('line_member').'}'
    } else {
      '#{Line-fill:'.CustomColor('error').'}'
    }
  } elsif ($this->parent and PML_T::is_coord($this->parent)) {
    '#{Line-width:1}#{Line-fill:'.CustomColor('line_comm').'}'
  } elsif (PML_T::is_coord($this)) {
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
  '#{customcomplex}'.join'.',map{(($this->{gram}{$_}=~/^(?:nr|inher)$/)?"#{customdetail}$_:#{customcomplex}":'')."\${gram/$_}" } sort grep{$this->{gram}->{$_}&&$_ !~/sempos|mod/}keys%{$this->{gram}}
  :''?>

style:#{Node-width:7}#{Node-height:7}#{Node-currentwidth:9}#{Node-currentheight:9}

style:<? '#{Node-shape:'.($this->{is_generated}?'rectangle':'oval').'}'?>

style:<? exists $PML_T::show{$${id}} ?'#{Node-addwidth:10}#{Node-addheight:10}':''?>

style:<?
  if(($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/) or
     ($this->parent and $this->parent->{nodetype}eq'root')) {
     '#{Line-width:1}#{Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal').'}'
  } elsif ($${is_member}) {
    if (PML_T::is_coord($this)and PML_T::is_coord($this->parent)) {
      '#{Line-width:1}#{Line-fill:'.CustomColor('line_normal').'}'
    } elsif ($this->parent and PML_T::is_coord($this->parent)) {
      '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:3&1}#{Line-fill:'.
       CustomColor('line_normal').'&'.CustomColor('line_member').'}'
    } else {
      '#{Line-fill:'.CustomColor('error').'}'
    }
  } elsif ($this->parent and PML_T::is_coord($this->parent)) {
    '#{Line-width:1}#{Line-fill:'.CustomColor('line_comm').'}'
  } elsif (PML_T::is_coord($this)) {
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
}#create_stylesheets

sub allow_switch_context_hook {
  return 'stop' if schema_name() ne 'tdata';
}
sub switch_context_hook {
  create_stylesheets();
  SetCurrentStylesheet('PML_T_Compact') if GetCurrentStylesheet() eq STYLESHEET_FROM_FILE();
  undef$PML::arf;
}

## Show suite ##

sub NoShow {
  undef%PML_T::show;
  ChangingFile(0);
}#NoShow

sub ShowFathers {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetFathers($node);
  ChangingFile(0);
}#ShowFathers

sub ShowChildren {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetChildren($node);
  ChangingFile(0);
}#ShowFathers

sub ShowExpand {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}expand_coord($node);
  ChangingFile(0);
}#ShowExpand

sub ShowDescendants {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetDescendants($node);
  ChangingFile(0);
}#ShowDescendants

sub ShowAncestors {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetAncestors($node);
  ChangingFile(0);
}#ShowAncestors

sub ShowTrueSiblings {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetTrueSiblings($node);
  ChangingFile(0);
}#ShowTrueSiblings

sub ShowNearestNonMember {
  my $node=$this;
  undef%PML_T::show;
  $PML_T::show{$_}=1 foreach map{$_->{id}}GetNearestNonMember($node);
  ChangingFile(0);
}#ShowNearestNonMember

=item delete_node (node?)

Deletes $node or $this, attaches all its children to its parent and
recounts deepord. Cannot be used for the root.

=cut

sub delete_node{
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
}#delete_node

=item delete_subtree (node?)

Deletes $node or $this and its whole subtree and recounts
deepord. Cannot be used for the root.

=cut

sub delete_subtree{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  ChangingFile(0),return unless $node->parent;
  my$parent=$node->parent;
  DeleteSubtree($node);
  $this=$parent unless@_;
  ChangingFile(1);
}#delete_subtree

=item new_node (node?)

Add new node as a son of the given node or current node.

=cut

sub new_node{
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  my$new=NewSon($node);
  $new->{id}=$new->root->{id}.'a'.
    ((sort {$b<=>$a} map{$_->{id}=~/a([0-9]+)$/;$1}$root->descendants)[0]+1);
  my $type = first {$_->{name} eq 't-node' } schema()->node_types;
  $new->set_type(schema()->type($type))
}#new_node

1;

=back

=cut

#endif PML_T
