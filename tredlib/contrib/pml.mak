# -*- cperl -*-
package PMLTectogrammatic;

#encoding iso-8859-2

#binding-context PMLTectogrammatic
import TredMacro;
sub first (&@);

my %arrow_colors;

undef *sort_attrs_hook;

=pod

=head1 PMLTectogrammatic

pml.mak - Miscelaneous macros of general use in Prague Dependency Treebank (PDT)

=head2 REFERENCE

=over 4

=item schema_name()

Return name of the PML schema for the current file. PDT typically uses
PML schema named C<adata> for analytical annotation and C<tdata> for
tectogrammatical annotation.

=cut

sub schema_name {
  my $schema;
  return undef unless $grp->{FSFile} and $schema=$grp->{FSFile}->metaData('schema');
  return $schema->{root}->{name};
}

sub file_resumed_hook {
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",schema_name(),"\n";
  default_pml_patterns();
  Redraw_FSFile();
  return;
}

sub switch_context_hook {
  my ($precontext,$context)=@_;
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",schema_name(),"\n";
  default_pml_patterns();
  %arrow_colors = (
                 textual => CustomColor('arrow_text'),
                 grammatical => CustomColor('arrow_gram'),
                 segment => CustomColor('arrow_segment'),
                 compl => CustomColor('arrow_compl'));
  Redraw_FSFile();
  return;
}

=item set_default_tdata_patterns()

Installs default display patterns for vieweing tectogrammatical trees in TrEd.

=cut

sub set_default_tdata_patterns {
  SetDisplayAttrs(split /\n\s*-------*\s*\n/,<<'EOF');
node:<? '#{customparenthesis}' if $${is_parenthesis} ?><?$${nodetype}eq'root' ? '${id}' : '${t_lemma}'?><? '#{customcoref}.'.$coreflemmas{$${id}} if $coreflemmas{$${id}}ne'' ?>

-------------------

node:<?
  ($${nodetype} eq 'root' ? '#{customnodetype}${nodetype}' :
  '#{customfunc}${functor}').
  "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?>

-------------------

node:<? $${nodetype} ne 'complex' and $${nodetype} ne 'root'
        ? '#{customnodetype}${nodetype}'
        : ''
     ?>#{customcomplex}<?
        local $_=$${gram/sempos};
        s/^sem([^.]+)(\..)?[^.]*(.*)$/$1$2$3/;
        '${gram/sempos='.$_.'}'
?>

-------------------

style:<? '#{Node-shape:Rectangle}'if$${is_generated} ?>

-------------------

style:<?
  if(($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/) or
     ($this->parent and $this->parent->{nodetype}eq'root')) {
     '#{Line-width:1}#{Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal').'}'
  } elsif ($${is_member}) {
    if (is_coord_T($this)) {
      '#{Line-width:1}#{Line-fill:'.CustomColor('line_normal').'}'
    } elsif ($this->parent and is_coord_T($this->parent)) {
      '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:3&1}#{Line-fill:'.
       CustomColor('line_normal').'&'.CustomColor('line_member').'}'
    } else {
      '#{Line-fill:'.CustomColor('error').'}'
    }
  } elsif ($this->parent and is_coord_T($this->parent)) {
    '#{Line-width:1}#{Line-fill:'.CustomColor('line_comm').'}'
  } elsif (is_coord_T($this)) {
    '#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:1&3}#{Line-fill:'.
    CustomColor('line_member').'&'.CustomColor('line_normal').'}'
  } else {
    '#{Line-width:2}#{Line-fill:'.CustomColor('line_normal').'}'
  }
?>

-------------------

style:<?
  if ($${tfa}=~/^[TFC]$/) {
    '#{Oval-fill:'.CustomColor('tfa_'.$${tfa}).'}${tfa}.'
  } else {
    '#{Oval-fill:'.CustomColor('tfa_no').'}'
  }
?>#{CurrentOval-width:3}#{CurrentOval-outline:<? CustomColor('current') ?>}
EOF

  SetBalloonPattern(<<'EOF');
<?
   my @hintlines;
   foreach my $gram (sort keys %{$this->{gram}}) {
     push @hintlines, "gram/".$gram." : ".$this->{gram}->{$gram} if $this->{gram}->{$gram}
   }
   push@hintlines, "is_dsp_root : 1" if $${is_dsp_root};
   push@hintlines, "is_name_of_person : 1" if $${is_name_of_person};
   push@hintlines, "quot_set : ". join("|",ListV($this->{quot_set})) if $${quot_set};
   join"\n", @hintlines
?>
EOF

}

#JA: style:<?'#{'.((($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/)or($this->parent and $this->parent->{nodetype}eq'root'))?'Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal'):($this->{is_member}?((is_coord_T( $this->parent))?'Line-width:1}#{Line-fill:'.CustomColor('line_member'):'Line-fill:'.CustomColor('error')):(is_coord_T($this->parent)?'Line-width:1}#{Line-fill:'.CustomColor('line_comm'):'Line-width:2}#{Line-fill:'.CustomColor('line_normal')))).'}'?>

=item set_default_adata_patterns()

Installs default display patterns for vieweing analytical trees in TrEd.

=cut

sub set_default_adata_patterns {
    SetDisplayAttrs(split /\n\s*-----*\s*\n/, <<'EOF');
text:${m/w/token}

--------------------

<? $${afun} eq "AuxS" ? '${id}' : '${m/form}' ?>

--------------------

node:#{blue}${afun}<?
  if ($${is_member}) {
    my $p=$this->parent;
    $p=$p->parent while $p and $p->{afun}=~/^Aux[CP]$/;
    ($p and $p->{afun}=~/^(Ap)os|(Co)ord/ ? "_#{#4C9CCD}\${is_member=$1$2}" : "_#{red}\${is_member=ERR}")
  } else { "" }
?>
EOF
}


=item default_pml_patterns()

Determines current PML schema and calls set_default_tdata_patterns()
or set_default_adata_patterns() accordingly.

=cut

#bind default_pml_patterns to F8 menu Display default attributes
sub default_pml_patterns { # cperl-mode _ _
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  if (schema_name() eq 'tdata') {
    set_default_tdata_patterns()
  } elsif (schema_name() eq 'adata') {
    set_default_adata_patterns();
  }
  return 1;
}


=item AFile($fsfile?)

Return analytical file associated with a given (tectogrammatical)
file. If no file is given, the current file is assumed.

=cut

sub AFile {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  return undef unless ref($fsfile->metaData('refnames')) and ref($fsfile->metaData('ref'));
  my $refid = $fsfile->metaData('refnames')->{adata};
  $fsfile->metaData('ref')->{$refid};
}

=item getANodes($node?)

Returns a list of analytical nodes referenced from a given
tectogrammatical node. If no node is given, the function applies to
C<$this>.

=cut

sub getANodes {
  shift unless ref($_[0]);
  my $node = $_[0] || $this;
  return map { s/^.*#//; getANodesHash()->{$_} } ListV($node->{'a.rf'});
}

=item getANodeByID($id_or_ref)

Looks up an analytical node by it's ID (or PMLREF - i.e. the ID
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

  if ($fsfile and
      $fsfile->metaData('struct') eq 'adata') {
    $fsfile = $fsfile->metaData('tdata')
  }
  return {} unless $fsfile;
  unless (ref($fsfile->metaData('a-ids'))) {
    # hash a-ids
    my %a_ids;
    my $a_fs = AFile($fsfile);
    unless ($a_fs) {
      #print(join(",",caller($_))."\n") for (0..10);
      return {};
    }
    my $trees = $a_fs->treeList;
    for ($i=0;$i<=$#$trees;$i++) {
      my $node = $trees->[$i];
      while ($node) {
	$a_ids{ $node->{id} } = $node;
      } continue {
	$node = $node->following;
      }
    }
    $grp->{FSFile}->changeMetaData('a-ids',\%a_ids);
  }
  $fsfile->metaData('a-ids');
}


=item clearANodesHash()

Clear the internal hash indexing analytical nodes of the analytical
file associated with the current tectogrammatical file.

=cut

sub clearANodesHash {
  $grp->{FSFile}->changeMetaData('a-ids',undef);
}



#ifdef TRED
#bind analytical_tree to Ctrl+A menu Display analytical tree

=item analytical_tree()

This function is only available in TrEd (i.e. in GUI). It switches
current view to an analytical tree associated with a currently
displayed tectogrammatical tree.

=cut

sub analytical_tree {
  if (which_struct() eq 'TR' and ARstruct()) {
    default_pml_patterns();
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
  }
  ChangingFile(0);
}
sub ARstruct {
  my $fsfile = $grp->{FSFile};
  return 0 unless ($fsfile or $fsfile->metaData('struct') eq 'adata');
  my $ar_fs = AFile($fsfile);
  return 0 unless $ar_fs;
  $ar_fs->changeMetaData('tdata',$fsfile);
  $ar_fs->changeMetaData('struct','adata');
  $grp->{FSFile} = $ar_fs;
  return 1;
}

#endif TRED

#ifdef TRED
#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree

=item tectogrammatical_tree()

This function is only available in TrEd (i.e. in GUI). After a
previous call to C<analytical_tree>, it switches current view back to
a tectogrammatical tree which refers to the current analytical tree.

=cut

sub tectogrammatical_tree {
  if (which_struct() eq 'AR' and TRstruct()) {
    default_pml_patterns();
    my $fsfile = $grp->{FSFile};
    my $id = $root->{id};
    my $this_id = $this->{id};
    #find current tree and new $this
    my $trees = $fsfile->treeList;
    TREE: for ($i=0;$i<=$#$trees;$i++) {
      foreach my $a_rf (ListV($trees->[$i]->{'a.rf'})) {
	$a_rf =~ s/^.*\#//;
	if ($a_rf eq $id) {
	  $grp->{treeNo} = $i;
	  $fsfile->currentTreeNo($i);
	  print "Found $a_rf at tree position $i\n";
	  last TREE;
	}
      }
    }
    $root = $fsfile->tree($grp->{treeNo});
    my $node=$root;
    while ($node) {
      if (first { $_ eq $this_id }
	  map { local $_=$_; s/^.*\#//; $_ }
	  ListV($node->{'a.rf'})) {
	$this = $node;
	last;
      }
    } continue {
      $node = $node->following;
    }
  }
  ChangingFile(0);
}
sub TRstruct {
  my $fsfile = $grp->{FSFile};
  return 0 unless $fsfile or $fsfile->metaData('struct') ne 'adata';
  my $tr_fs = $fsfile->metaData('tdata');
  return 0 unless $tr_fs;
  $grp->{FSFile} = $tr_fs;
  return 1;
}

#endif TRED


sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  return unless which_struct() eq 'TR';
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
    # this is TR specific stuff
    push @sent,$node unless ($node->{'m'}{w}{token} eq '');
    $node=$node->following();
  }
  @sent = map { [" ","space"],[$_->{'m'}{w}{token},
		@{$refers_to{$_->{id}}}] }
    sort { $a->{ord} <=> $b->{ord} } @sent;
  return \@sent;
}

sub which_struct {
  return unless ref($grp->{FSFile});
  if ($grp->{FSFile}->metaData('struct') eq "adata") {
    return 'AR';
  }
  return 'TR';
}

sub node_style_hook {
  my ($node,$styles)=@_;
  my $ARstruct = (which_struct() =~ /AR/) ? 1 : 0;
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

  if  (!$ARstruct and ($node->{'coref_text.rf'} or $node->{'coref_gram.rf'} or $node->{'compl.rf'} or $node->{coref_special})) {
    my @gram = grep {$_ ne "" } ListV($node->{'coref_gram.rf'});
    my @text = grep {$_ ne "" } ListV($node->{'coref_text.rf'});
    my @compl = grep {$_ ne "" } ListV($node->{'compl.rf'});
    draw_coref_arrows($node,$styles,\%line,
		      [@gram,@text,@compl],
		      [(map 'grammatical',@gram),
		       (map 'textual',@text),
		       (map 'compl',@compl)
		      ],
		      \%arrow_colors
		     );
  }
  1;
}

sub draw_coref_arrows {
  my ($node,$styles,$line,$corefs,$cortypes,$cortype_colors)=@_;
  my (@coords,@colors);
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
      push @colors,$cortype_colors->{$cortype};
      my $c = <<COORDS;

&n,n,
(x$T+xn)/2 - $Y*(25/$D+0.12),
(y$T+yn)/2 + $X*(25/$D+0.12),
x$T,y$T


COORDS
      push @coords,$c;

    } else { # should be always the same document, if it exists at all
      delete $coreflemmas{$node->{id}};
      my($step_l,$step_r)=(1,1);
      my $current=CurrentTreeNumber();
      my $maxnum=scalar(GetTrees())-1;
      my $orientation;

      while($step_l!=0 or $step_r!=0){
        if($step_l){
          if (my$refed=first { $_->{id} eq $coref } (GetTrees())[$current-$step_l] -> descendants){
            $orientation='left';
            $coreflemmas{$node->{id}}.=$refed->{t_lemma};
            last;
          }
          $step_l=0 if ($current-(++$step_l))<0;
        }
        if($step_r){
          if (my$refed=first { $_->{id} eq $coref } (GetTrees())[$current+$step_r] -> descendants){
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
	    push @colors,$cortype_colors->{$cortype};
	    push @coords,"\&n,n,n-30,n+$rotate_prv_snt";
	    $rotate_prv_snt+=10;
          }else{ #right
	    print STDERR "ref-arrows: Following sentence\n" if $main::macroDebug;
	    push @colors,$cortype_colors->{$cortype};
	    push @coords,"\&n,n,n+30,n+$rotate_nxt_snt";
	    $rotate_nxt_snt+=10;
          }
        }else{
          print STDERR "ref-arrows: Not found!\n" if $main::macroDebug;
          push @colors,CustomColor('error');
	  push @coords,"&n,n,n+$rotate_dfr_doc,n-20";
	  $rotate_dfr_doc+=10;
        }
    }
  }
  if(join ('|',ListV($node->{coref_special}))=~ /sg/) { # pointer to an unspecified segment of preceeding sentences
    print STDERR "ref-arrows: Segment - unaimed arrow\n" if $main::macroDebug;
    push @colors,CustomColor('arrow_segment');
    push @coords,"&n,n,n-25,n";
  }
  if(join ('|',ListV($node->{coref_special}))=~ /exoph/) {
    print STDERR "ref-arrows: Exophora\n" if $main::macroDebug;
    push @colors,CustomColor('arrow_exoph');
    push @coords,"&n,n,n+$rotate_dfr_doc,n-20";
    $rotate_dfr_doc+=10;
  }
  $line->{-coords} ||= 'n,n,p,p';

  # make sure we don't alter any previous line
  my $lines = scalar($line->{-coords}=~/&/g)+1;
  for (qw(-arrow -dash -width -fill -smooth)) {
    $line->{$_}.='&'x($lines-scalar($line->{$_}=~/&/g)-1);
  }
  if (@coords) {
    AddStyle($styles,'Line',
	     -coords => $line->{-coords}.join("",@coords),
	     -arrow => $line->{-arrow}.('&last' x @coords),
	     -dash => $line->{-dash},#.('&_' x @coords),
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
	   $this->{id} => [qw({AID} value)],
	   "     a.rf: " => [qw(label)],
	   (join ", ",ListV($this->{'a.rf'})) => [qw({'a.rf'} value)],
	   ($this->attr('valency/rf') ne "" ?
	    ("     frame: " => [qw(label)],
	     $this->attr('valency/comment') => [qw({FRAME} value)],
	     "     {".$this->attr('valency/rf')."}" => [qw({FRAME} value)],
	   ) : ()),
	   ($this->{commentA} ne "" ?
	    ("     [" => [qw()],
	     $this->{commentA} => [qw({commentA})],
	     "]" => [qw()]
	    ) : ())
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

=item goto_tree()

Ask user for sentence identificator (number or id) and go to the
sentence.

=cut

#bind goto_tree to Alt+g menu Goto Tree
sub goto_tree {
  my$to=QueryString("Give a Tree Number or ID","Tree Identificator");
  if($to =~ /^[0-9]+$/){ # number
    GotoTree($to) if $to <= scalar GetTrees() and $to != 0;
  }else{ # id
    for(my$i=0;$i<GetTrees();$i++){
      if((GetTrees())[$i]->{id} =~ /\Q$to\E$/){
        GotoTree($i+1);
        last;
      }
    }
  }
  ChangingFile(0);
}#goto_tree

=item is_coord_T($node?)

Check if the given node is a coordination according to its TGTS
functor (attribute C<functor>)

=cut

sub is_coord_T {
  my $node=$_[0] || $this;
  return 0 unless $node;
  return $node->{functor} =~ /CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/;
}

=item expand_coord_A($node,$keep?)

If the given node is coordination or aposition (according to its
Analytical function - attribute C<afun>) expand it to a list of
coordinated nodes. Otherwise return the node itself. If the argument
C<keep> is true, include the coordination/aposition node in the list
as well.

=cut

sub expand_coord_A {
  my ($node,$keep)=@_;
  return unless $node;
  if ($node->{afun}=~/Coord|Apos/) {
    return (($keep ? $node : ()),
	    map { expand_coord_A($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #expand_coord_T

=item expand_coord_T($node,$keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<functor>) expand it to a list of coordinated
nodes. Otherwise return the node itself. If the argument C<keep> is
true, include the coordination/aposition node in the list as well.

=cut

sub expand_coord_T {
  my ($node,$keep)=@_;
  return unless $node;
  if (is_coord_T($node)) {
    return (($keep ? $node : ()),
	    map { expand_coord_T($_,$keep) }
	    grep { $_->{is_member} } $node->children);
  } else {
    return ($node);
  }
} #expand_coord_T

=item get_sentence_string_A($tree?)

Return string representation of the given tree (suitable for
Analytical trees).

=cut

sub get_sentence_string_A {
  my $node = $_[0]||$this;
  $node=$node->root->following;
  my @sent=();
  while ($node) {
    push @sent,$node;
    $node=$node->following();
  }
  return join('',map{
    $_->{'m'}{form}.($_->{'m'}{'w'}{no_space_after}?'':' ')
  } sort { $a->{ord} <=> $b->{ord} } @sent);
}#get_sentence_string_A

=item get_sentence_string_T($tree?)

Return string representation of the given tree (suitable for
Tectogrammatical trees).

=cut

sub get_sentence_string_T {
  my $node=$_[0]||$this;
  my ($a_tree) = getANodes($node->root);
  return unless ($a_tree);
  return get_sentence_string_A($a_tree);
}#get_sentence_string_T

=item dive_AuxCP ($node)

You can use this function as a C<through> argument to GetFathers_A and
GetChildren_A. It skips all the prepositions and conjunctions when
looking for nodes which is what you usually want.

=cut

sub dive_AuxCP ($){
  $_[0]->{afun}=~/x[CP]/
}#dive_AuxCP

=item GetFathers_A($node,$through)

Return linguistic parent of a given node as appears in an analytic
tree. The argument C<$through> should supply a function accepting one
node as an argument and returning true if the node should be skipped
on the way to parent or 0 otherwise. The most common C<dive_AuxCP> is
provided in this package.

=cut

sub _expand_coord_GetFathers_A { # node through
  my ($node,$through)=@_;
  my @toCheck = $node->children;
  my @checked;
  while (@toCheck) {
    @toCheck=map {
      if (&$through($_)) { $_->children() }
      elsif($_->{afun}=~/Coord|Apos/&&$_->{is_member}){ _expand_coord_GetFathers_A($_,$through) }
      elsif($_->{is_member}){ push @checked,$_;() }
      else{()}
    }@toCheck;
  }
  return @checked;
}# _expand_coord_GetFathers_A

sub GetFathers_A { # node through
  my ($node,$through)=@_;
  my $init_node = $node; # only used for reporting errors
  if ($node->{is_member}) { # go to coordination head
    while ($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}) {
      $node=$node->parent;
      if (!$node) {
	print STDERR
	  "GetFathers: Error - no coordination head $init_node->{AID}: ".ThisAddress($init_node)."\n";
        return();
      } elsif($node->{afun}eq'AuxS') {
	print STDERR
	  "GetFathers: Error - no coordination head $node->{AID}: ".ThisAddress($node)."\n";
        return();
      }
    }
  }
  if (&$through($node->parent)) { # skip 'through' nodes
    while (&$through($node->parent)) {
      $node=$node->parent;
    }
  }
  $node=$node->parent;
  return $node if $node->{afun}!~/Coord|Apos/;
  _expand_coord_GetFathers_A($node,$through);
} # GetFathers_A

=item GetFathers_T($node)

Return linguistic parents of a given node as appear in a TG tree.

=cut

sub GetFathers_T {
  my $node = $_[0] || $;
  if ($node and $node->{is_member}) {
    while ($node and (!is_coord_T($node) or $node->{is_member})) {
      $node=$node->parent;
    }
  }
  return () unless $node;
  $node=$node->parent;
  return () unless $node;
  return ($node) if !is_coord_T($node);
  return (expand_coord_T($node));
} # GetFathers_T

=item GetChildren_A($node, $dive)

Return a list of nodes linguistically dependant on a given
node. C<$dive> is a function which is called to test whether a given
node should be used as a terminal node (in which case it should return
false) or whether it should be skipped and its children processed
instead (in which case it should return true). Most usual treatment is
provided in C<dive_AuxCP>. If C<$dive> is skipped, a function returning 0
for all arguments is used.

=cut

sub FilterSons_A{ # node dive suff from
  my ($node,$dive,$suff,$from)=@_;
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; # comment this line to get all members
    unless ($node==$from){ # on the way up do not go back down again
      if (!$suff&&$node->{afun}=~/Coord|Apos/&&!$node->{is_member}
	  or$suff&&$node->{afun}=~/Coord|Apos/&&$node->{is_member}) {
	push @sons,FilterSons_A($node,$dive,1,0)
      } elsif (&$dive($node) and $node->firstson){
	push @sons,FilterSons_A($node,$dive,$suff,0);
      } elsif(($suff&&$node->{is_member})
	      ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node;
      }
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons_A

sub GetChildren_A{ # node dive
  my ($node,$dive)=@_;
  my @sons;
  my $from;
  $dive = sub { 0 } unless defined($dive);
  push @sons,FilterSons_A($node,$dive,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}){
      $from=$node;$node=$node->parent;
      push @sons,FilterSons_A($node,$dive,0,$from);
    }
    if ($node->{afun}eq'AuxS'){
      print STDERR "Error: Missing Coord/Apos: $node->{id} ".ThisAddress($node)."\n";
      @sons=@oldsons;
    }
  }
  return@sons;
} # GetChildren_A


=item GetChildren_T($node?)

Return a list of nodes linguistically dependant on a given node.

=cut

sub FilterSons_T { # node suff from
  my ($node,$suff,$from)=(shift,shift,shift);
  my @sons;
  $node=$node->firstson;
  while ($node) {
#    return @sons if $suff && @sons; #uncomment this line to get only first occurence
    unless ($node==$from){ # on the way up do not go back down again
      if(($suff&&$node->{is_member})
	 ||(!$suff&&!$node->{is_member})){ # this we are looking for
	push @sons,$node unless is_coord_T($node);
      }
      push @sons,FilterSons_T($node,1,0)
	if (!$suff
	    &&is_coord_T($node)
	    &&!$node->{is_member})
	  or($suff
	     &&is_coord_T($node)
	     &&$node->{is_member});
    } # unless node == from
    $node=$node->rbrother;
  }
  @sons;
} # FilterSons_T

sub GetChildren_T { # node
  my $node=$_[0]||$this;
  return () if is_coord_T($node);
  my @sons;
  my $init_node=$node;# for error message
  my $from;
  push @sons,FilterSons_T($node,0,0);
  if($node->{is_member}){
    my @oldsons=@sons;
    while($node and $node->{nodetype}ne'root'
	  and ($node->{is_member} || !is_coord_T($node))){
      $from=$node;$node=$node->parent;
      push @sons,FilterSons_T($node,0,$from) if $node;
    }
    if ($node->{nodetype}eq'root'){
      stderr("Error: Missing coordination head: $init_node->{id} $node->{id} ",ThisAddressNTRED($node),"\n");
      @sons=@oldsons;
    }
  }
  @sons;
} # GetChildren_T

=item GetDescendants_T($node?)

Return a list of all nodes linguistically subordinated to a given node
(not including the node itself).

=cut

sub GetDescendants_T {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { $_, GetDescendants_T($_) } GetChildren_T($node));
}

=item GetAncestors_T($node?)

Return a list of all nodes linguistically superordinated to (ie governing)a given node
(not including the node itself).

=cut

sub GetAncestors_T {
  my $node = $_[0] || $this;
  return () unless ($node and $node->{nodetype} ne 'coap');
  return uniq(map { ($_, GetAncestors_T($_)) } GetFathers_T($node));
}


=item GetTrueSiblings_T($node?)

Return linguistic siblings of a given node as appears in a
tectogrammatic tree. This doesn't include the node itself, neither
those children of the node's linguistic parent that are in
coordination with the node.

=cut

sub GetTrueSiblings_T {
  my $node = $_[0] || $this;
  my $coord = GetNearestNonMember_T($node);
  return
    grep { GetNearestNonMember_T($_) != $coord }
    map { GetChildren_T($_) }
    GetFathers_T($node)
} # GetTrueSiblings_T

=item GetNearestNonMember_T($node?)

If the node is not a member of a coordination, return the node.  If it
is a member of a coordination, return the node representing the
highest coordination $node is a member of.

=cut

sub GetNearestNonMember_T {
 my $node = $_[0] || $this;
 while ($node->{is_member}) {
   $node=$node->parent;
 }
 return $node;
}

=item isFiniteVerb_T($node?)

If the node is the head of a finite complex verb form (based on
C<a.rf> information and m/tag of the corresponding analytical nodes),
return 1, else return 0.

=cut

sub isFiniteVerb_T {
  my $node = $_[0] || $this;
  return (first { $_->{'m'}{tag}=~/^V[^sf]/ } getANodes($node)) ? 1 : 0;
}#isFiniteVerb_T

=item isPassive_T($node?)

If the node is the head of a passive-only verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub isPassive_T {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } getANodes($node);
  return( @anodes == 1 and $anodes[0]->{'m'}{tag} =~ /^Vs/)
}#isPassive_T

=item isInfinitive_T($node?)

If the node is the head of an infinitive complex verb form, (based on
C<a.rf> information), return 1, else return 0.

=cut

sub isInfinitive_T {
  my $node = $_[0] || $this;
  my @anodes = grep { $_->{'m'}{tag} =~ /^V/ } getANodes($node);
  @anodes and not(&isFiniteVerb_T or &isPassive_T);
}#isInfinitive_T


=item modal_verb_lemma($lemma)

Return 1 if trlemma is a member of the list of all possible modal verb
lemmas (morfological lemma suffixes (/[-`_].*/) are ignored).

=cut

sub modal_verb_lemma ($) {
  $_[0]=~/^(?:dát|dovést|hodlat|chtít|mít|moci|mus[ei]t|smìt|umìt)($|[-`_].*)/;
}#modal_verb_trlemmas

=item non_proj_edges($node?,$ord?,$filterNode?,$returnParents?,$subord?,$filterGap?)

Returns hash-ref containing all non-projective edges. Values of the
hash are references to arrays containing the non-projective edges (the
arrays contain the lower and upper nodes representing the edge, and
then the nodes causing the non-projectivity of the edge), keys are
concatenations of stringified references to lower and upper nodes of
non-projective edges. Description of the arguments is as follows:
$node specifies the root of a subtree to be checked for non-projective
edges; $ord specifies the ordering attribute to be used; a subroutine
accepting one argument passed as sub-ref in $filterNode can be used to
filter the edges taken into account (by specifying the lower nodes of
the edges); sub-ref $returnParents accepting one argument returns an
array of upper nodes of the edges to be taken into account; sub-ref
$subord accepting two arguments returns 1 iff the first one is
subordinated to the second one; sub-ref $filterGap accepting one
argument can be used to filter nodes causing non-projectivity.
Defaults are: the root of the current tree, the default
ordering attribute, all nodes, parent (in the technical
representation), subordination in the technical sense, all nodes.

=cut

sub non_proj_edges {
# arguments are: root of the subtree to be projectivized
# the ordering attribute
# sub-ref to a filter accepting a node parameter (which nodes of the subtree should be skipped)
# sub-ref to a function accepting a node parameter returning a list of possible upper nodes
# on the edge from the node
# sub-ref to a function accepting two node parameters returning one iff the first one is
# subordinated to the second
# sub-ref to a filter accepting a node parameter for nodes in a potential gap

# returns a reference to a hash in which all non-projective edges are returned
# (keys being the lower nodes concatenated with the upper nodes of non-projective edges,
# values references to arrays containing the node, the parent and nodes in the respective gaps)


  my ($top,$ord,$filterNode,$returnParents,$subord,$filterGap) = @_;
  $top = $root unless ref($top);

  $ord = $grp->{FSFile}->FS->order() unless defined($ord);
  $filterNode = sub { 1 } unless defined($filterNode);
  $returnParents = sub { return $_[0]->parent ? ($_[0]->parent) : () } unless defined $returnParents;
  $subord = sub { my ($n,$top) = @_;
		  while ($n->parent and $n!=$top) {$n=$n->parent};
		  return ($n==$top) ? 1 : 0; # returns 1 if true, 0 otherwise
		} unless defined($subord);
  $filterGap = sub { 1 } unless defined($filterGap);

  my %npedges;

  # get the nodes of the subtree
  my @subtree = sort {$a->{$ord} <=> $b->{$ord}} ($top->descendants, $top);

  # just store the index in the subtree in a special attribute of each node
  for (my $i=0; $i<=$#subtree; $i++) {$subtree[$i]->{'_proj_index'} = $i}

  # now check all the edges of the subtree (but only those accepted by filterNode
  foreach my $node (grep {&$filterNode($_)} @subtree) {

    next if ($node==$top); # skip the top of the subtree

    foreach my $parent (&$returnParents($node)) {

      # span of the current edge
      my ($l,$r)=($node->{'_proj_index'}, $parent->{'_proj_index'});

      # set the boundaries of the interval covered by the current edge
      if ($l > $r) { ($l,$r) = ($r,$l) };

      # check all nodes covered by the edge
      for (my $j=$l+1; $j<$r; $j++) {

	my $gap=$subtree[$j]; # potential node in gap
	# mark a non-projective edge and save the node causing the non-projectivity (ie in the gap)
	if (not(&$subord($gap,$parent)) and &$filterGap($gap)) {
	  my $key=scalar($node).scalar($parent);
	  if (exists($npedges{$key})) { push @{$npedges{$key}}, $gap }
	  else { $npedges{$key} = [$node, $parent, $gap] };
	} # unless

      } # for $j

    } # foreach $parent

  } # foreach $node

  return \%npedges;

} # sub non_proj_edges


#bind test to t
sub test {
  print "\n";
  ChangingFile(0);
}

{ my@CustomColors=qw/error red
                     current red
                     tfa_T white
                     tfa_F yellow
                     tfa_C green
                     tfa_no #c0c0c0
                     func #601808
                     subfunc #a02818
                     parenthesis #809080
                     nodetype darkblue
                     complex darkmagenta
                     coref darkblue
                     arrow_text #4C509F
                     arrow_gram #C05633
                     arrow_segment darkred
                     arrow_compl #629F52
                     arrow_exoph blue
                     line_normal #707070
                     line_member #a0a0a0
                     line_comm #6F11EA/;
  while(@CustomColors){
    my$key=shift(@CustomColors);
    my$val=shift(@CustomColors);
    unless (TredMacro::CustomColor($key)) {
      CustomColor($key,$val);
    }
  }
}

1;

=back

=cut

