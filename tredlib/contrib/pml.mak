# -*- cperl -*-
package PMLTectogrammatic;

#binding-context PMLTectogrammatic
#-#key-binding-adopt Tectogrammatic
#-#menu-binding-adopt Tectogrammatic
#use base qw(Tectogrammatic);
#import Tectogrammatic;
import TredMacro;
sub first (&@);

my %arrow_colors;

undef *sort_attrs_hook;

sub schema_name {
  my $schema;
  return undef unless $grp->{FSFile} and $schema=$grp->{FSFile}->metaData('schema');
  return $schema->{root}->{name};
}

sub file_resumed_hook {
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",schema_name(),"\n";
  default_pml_attrs();
  Redraw_FSFile();
  return;
}

sub switch_context_hook {
  my ($precontext,$context)=@_;
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",schema_name(),"\n";
  default_pml_attrs();
  my@CustomColors=qw/error red
                     current red
                     tfa_T white
                     tfa_F yellow
                     tfa_C green
                     tfa_no #c0c0c0
                     func #601808
                     subfunc #a02818
                     parenthesis #809080
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
    CustomColor($key,$val)unless CustomColor($key);
  }
  %arrow_colors = (
                 #should be converted to CustomColors
                 textual => CustomColor('arrow_text'),
                 grammatical => CustomColor('arrow_gram'),
                 segment => CustomColor('arrow_segment'),
                 compl => CustomColor('arrow_compl'));
  Redraw_FSFile();
  return;
}

sub set_default_tdata_attrs {
  SetDisplayAttrs(split /\n/,<<'EOF');
node:<? '#{customparenthesis}' if $${is_parenthesis} ?><?$${nodetype}eq'root' ? '${id}' : '${t_lemma}'?><? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?><? '#{customcoref}.'.$PMLTectogrammatic::coreflemmas{$${id}} if $PMLTectogrammatic::coreflemmas{$${id}}ne'' ?>
node:#{customfunc}${functor}<? "#{#4C9CCD}-\${parenthesis}" if $${parenthesis} eq "PA" ?><? "#{customsubfunc}".($${subfunctor}?".\${subfunctor}":'').($${is_state}?".\${is_state=state}":'') ?>
node:<? $${nodetype} ne 'complex' ? '#{darkblue}${nodetype}'  : ''?>#{darkmagenta}<? local $_=$${gram/wordclass}; s/^sem([^.]+)(\..)?[^.]*(.*)$/$1$2$3/; '${gram/wordclass='.$_.'}'?>
style:<? '#{Node-shape:Rectangle}'if$${is_generated} ?>
style:<? if(($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/)or($this->parent and $this->parent->{nodetype}eq'root')){'#{Line-width:1}#{Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal').'}'}elsif($${is_member}){if(PMLTectogrammatic::is_coord_TR($this)){'#{Line-width:1}#{Line-fill:'.CustomColor('line_normal').'}'}elsif($this->parent and PMLTectogrammatic::is_coord_TR($this->parent)){'#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:3&1}#{Line-fill:'.CustomColor('line_normal').'&'.CustomColor('line_member').'}'}else{'#{Line-fill:'.CustomColor('error').'}'}}elsif($this->parent and PMLTectogrammatic::is_coord_TR($this->parent)){'#{Line-width:1}#{Line-fill:'.CustomColor('line_comm').'}'}elsif(PMLTectogrammatic::is_coord_TR($this)){'#{Line-coords:n,n,(n+p)/2,(n+p)/2&(n+p)/2,(n+p)/2,p,p}#{Line-width:1&3}#{Line-fill:'.CustomColor('line_member').'&'.CustomColor('line_normal').'}'}else{'#{Line-width:2}#{Line-fill:'.CustomColor('line_normal').'}'} ?>
style:<? if($${tfa}=~/^[TFC]$/){'#{Oval-fill:'.CustomColor('tfa_'.$${tfa}).'}${tfa}.'}else{'#{Oval-fill:'.CustomColor('tfa_no').'}'} ?>#{CurrentOval-width:3}#{CurrentOval-outline:<? CustomColor('current') ?>}
EOF

  SetBalloonPattern('<? my@hintlines;foreach my$gram(keys %{$this->{gram}}){push@hintlines,"gram/".$gram." : ".$this->{gram}->{$gram} if$this->{gram}->{$gram}};push@hintlines,"is_dsp_root : 1" if $${is_dsp_root};push@hintlines,"is_name_of_person : 1"if$${is_name_of_person};push@hintlines,"quot_set : ".join("|",ListV($this->{quot_set}))if$${quot_set};join"\n",@hintlines?>');
}

#JA: style:<?'#{'.((($this->{functor}=~/^(?:PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/)or($this->parent and $this->parent->{nodetype}eq'root'))?'Line-dash:2,4}#{Line-fill:'.CustomColor('line_normal'):($this->{is_member}?((PMLTectogrammatic::is_coord_TR( $this->parent))?'Line-width:1}#{Line-fill:'.CustomColor('line_member'):'Line-fill:'.CustomColor('error')):(PMLTectogrammatic::is_coord_TR($this->parent)?'Line-width:1}#{Line-fill:'.CustomColor('line_comm'):'Line-width:2}#{Line-fill:'.CustomColor('line_normal')))).'}'?>

sub set_default_adata_attrs {
    SetDisplayAttrs(split /\n/, <<'EOF');
<? $${afun} eq "AuxS" ? '${id}' : '${m/form}' ?>
node:#{blue}${afun}<? if ($${is_member}) { my $p=$this->parent; $p=$p->parent while $p and $p->{afun}=~/^Aux[CP]$/; ($p and $p->{afun}=~/^(Ap)os|(Co)ord/ ? "_#{#4C9CCD}\${is_member=$1$2}" : "_#{red}\${is_member=ERR}")} else {""} ?>
text:${m/w/token}
EOF
}

#bind default_pml_attrs to F8 menu Display default attributes
sub default_pml_attrs { # cperl-mode _ _
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  if (schema_name() eq 'tdata') {
    set_default_tdata_attrs()
  } elsif (schema_name() eq 'adata') {
    set_default_adata_attrs();
  }
  return 1;
}

sub adata {
  shift unless ref($_[0]);
  my $fsfile = $_[0] || $grp->{FSFile};
  return undef unless ref($fsfile->metaData('refnames')) and ref($fsfile->metaData('ref'));
  my $refid = $fsfile->metaData('refnames')->{adata};
  $fsfile->metaData('ref')->{$refid};
}

sub getANodes {
  shift unless ref($_[0]);
  my $node = $_[0] || $this;
  return map { s/^.*#//; getANodesHash()->{$_} } ListV($node->{'a.rf'});
}

sub getANodeByID {
  my ($arf)=@_;
  $arf =~ s/^.*#//;
  return getANodesHash()->{$arf};
}

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
    my $a_fs = adata($fsfile);
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

#bind analytical_tree to Ctrl+A menu Display analytical tree
sub analytical_tree {
  if (which_struct() eq 'TR' and ARstruct()) {
    default_pml_attrs();
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

#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree
sub tectogrammatical_tree {
  if (which_struct() eq 'AR' and TRstruct()) {
    default_pml_attrs();
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

sub ARstruct {
  my $fsfile = $grp->{FSFile};
  return 0 unless ($fsfile or $fsfile->metaData('struct') eq 'adata');
  my $ar_fs = adata($fsfile);
  return 0 unless $ar_fs;
  $ar_fs->changeMetaData('tdata',$fsfile);
  $ar_fs->changeMetaData('struct','adata');
  $grp->{FSFile} = $ar_fs;
  return 1;
}

sub TRstruct {
  my $fsfile = $grp->{FSFile};
  return 0 unless $fsfile or $fsfile->metaData('struct') ne 'adata';
  my $tr_fs = $fsfile->metaData('tdata');
  return 0 unless $tr_fs;
  $grp->{FSFile} = $tr_fs;
  return 1;
}

sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  return unless which_struct() eq 'TR';
  my $tree = $fsfile->tree($treeNo);
  my ($a_tree) = getANodes($tree);
  return unless ($a_tree);
  my $node = $tree;
  my %refers_to;
  while ($node) {
    foreach (ListV($node->{'a.rf'})) {
      s/^.*\#//;
      push @{$refers_to{$_}}, $node;
    }
    $node = $node->following;
  }
  $node = $a_tree;
  my @sent=();
  while ($node) {
    # this is TR specific stuff
    push @sent,$node unless ($node->{m}{w}{token} eq '');
    $node=$node->following();
  }
  @sent = map { [" ","space"],[$_->{m}{w}{token},
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

=item PMLTectogrammatic::goto

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

=item PMLTectogrammatic::is_coord_TR(node)

Check if the given node is a coordination according to its TGTS
functor (attribute C<functor>)

=cut

sub is_coord_TR {
  my $node=$_[0] || $this;
  return 0 unless $node;
  return $node->{functor} =~ /CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/;
}

=item PMLTectogrammatic::expand_coord_apos_TR(node,keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<functor>) expand it to a list of coordinated
nodes. Otherwise return the node itself. If the argument C<keep> is
true, include the coordination/aposition node in the list as well.

=cut

sub expand_coord_TR {
  my ($node,$keep)=@_;
  return unless $node;
  if (is_coord_TR($node)) {
    return (($keep ? $node : ()),
	    map { expand_coord_TR($_,$keep) }
	    grep { $_->{is_member} } $node->children(FS()));
  } else {
    return ($node);
  }
} #expand_coord_TR

#TODO: zkusit pulene hrany, jmena
