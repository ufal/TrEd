# -*- cperl -*-
package PMLTectogrammatic;

#binding-context PMLTectogrammatic
#-#key-binding-adopt Tectogrammatic
#-#menu-binding-adopt Tectogrammatic
#use base qw(Tectogrammatic);
#import Tectogrammatic;
import TredMacro;
sub first (&@);

%arrow_colors = (
  textual => '#6a85cd',
  grammatical => '#f6c27b',
  segment => '#dd5555',
  compl =>'#609060');

undef *sort_attrs_hook;


sub file_resumed_hook {
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",$grp->{FSFile}->metaData('schema')->{name},"\n";
  default_pml_attrs();
  Redraw_FSFile();
  return;
}

sub switch_context_hook {
  my ($precontext,$context)=@_;
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  print "SCHEMA: ",$grp->{FSFile}->metaData('schema')->{name},"\n";
  default_pml_attrs();
  Redraw_FSFile();
  return;
}

sub set_default_tdata_attrs {
    SetDisplayAttrs(split /\n/,<<'EOF');
<? "#{red}" if $${commentA} ne "" ?>${t_lemma}<? ".#{custom1}\${aspect}" if $${aspect} =~/PROC|CPL|RES/ ?><? "$${_light}"if$${_light}and$${_light}ne"_LIGHT_" ?>${m/form}
node:#{darkgreen}${functor}<? $${is_member} ? "_#{#4C9CCD}".($this->parent->{functor}=~/^(AP)PS|^(OP)ER/ ? "\${is_member=$1$2}" : "\${is_member=CO}") : "" ?><? "#{#4C9CCD}-\${parenthesis}" if $${parenthesis} eq "PA" ?><? ".#{custom3}\${subfunctor}" if $${subfunctor} ne "???" and $${subfunctor} ne ""?>
text:<? "#{-background:cyan}" if $${_light}eq"_LIGHT_" ?><? "#{-foreground:green}#{-underline:1}" if $${NG_matching_node} eq "true" ?><? "#{-tag:NG_TOP}#{-tag:LEMMA_".$${trlemma}."}" if ($${NG_matching_node} eq "true" and $${NG_matching_edge} ne "true") ?>${m/w/origf}
style:<? "#{Line-fill:green}" if $${NG_matching_edge} eq "true" ?>
style:<? "#{Node-addwidth:7}#{Node-addheight:7}#{Oval-fill:cyan}" if $${_light}eq"_LIGHT_" ?>
style:<? "#{Oval-fill:green}" if $${NG_matching_node} eq "true" ?>
node:<? $${nodetype} ne 'complex' ? '#{darkblue}${nodetype}'  : ''?>#{darkred}<? local $_=$${gram/wordclass}; s/^sem([^.]+)(\..)?[^.]*(.*)$/$1$2$3/; '${gram/wordclass='.$_.'}' ?><? $${dsp_root} ? '#{black}.#{green}${dsp_root=DSP}' : '' ?><? $${quot_type} ne '' ? '.#{green}${quot_type}' : ''?>
style:<? $${operand}.$${is_member} ? '#{Line-coords:n,n,n,n+(p-n)/3&n,n+(p-n)/3,p,p}' : '#{Line-coords:n,n,n,n}') ?>
style:<? $${nodetype} eq 'coap' ? '#{Node-shape:rectangle}#{Node-currentwidth:7}#{Node-currentheight:7}#{CurrentOval-width:1}#{Node-width:0}#{Node-height:0}#{Oval-width:0}' : '' ?>
EOF
    SetBalloonPattern('');
}

sub set_default_adata_attrs {
    SetDisplayAttrs(split /\n/, <<'EOF');
${m/form}
node:#{blue}${afun}<? if ($${is_member}) { my $p=$this->parent; $p=$p->parent while $p and $p->{afun}=~/^Aux[CP]$/; ($p and $p->{afun}=~/^(Ap)os|(Co)ord/ ? "_#{#4C9CCD}\${is_member=$1$2}" : "_#{red}\${is_member=ERR}")} else {""} ?>
text:${m/w/origf}
EOF
}

#bind default_pml_attrs to F8 menu Display default attributes
sub default_pml_attrs { # cperl-mode _ _
  return unless $grp->{FSFile} and $grp->{FSFile}->metaData('schema');
  if ($grp->{FSFile}->metaData('schema')->{name} eq 'tdata') {
    set_default_tdata_attrs()
  } elsif ($grp->{FSFile}->metaData('schema')->{name} eq 'adata') {
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

sub aids {
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
      # print(join(",",caller($_))."\n") for (0..10);
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
    my $a_ids = aids($fsfile);
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

#  my $ar_header = $ar_fs->FS;
#  my $header = $fsfile->FS;
#  my @ar_trees = $ar_fs->trees();
#  my @trees = $fsfile->trees();
#   $fsfile->changeMetaData('a-fs',undef);
#   $fsfile->changeMetaData('t-fs',$ar_fs);
#   $fsfile->changeTrees(@ar_trees);
#   $ar_fs->changeTrees(@trees);
#   $fsfile->changeFS($ar_header);
#   $ar_fs->changeFS($header);
  return 1;
}

sub TRstruct {
  my $fsfile = $grp->{FSFile};
  return 0 unless $fsfile or $fsfile->metaData('struct') ne 'adata';
  my $tr_fs = $fsfile->metaData('tdata');
  return 0 unless $tr_fs;
  $grp->{FSFile} = $tr_fs;
  
#   my $tr_header = $tr_fs->FS;
#   my $header = $fsfile->FS;
#   my @tr_trees = $tr_fs->trees();
#   my @trees = $fsfile->trees();
#   $fsfile->changeMetaData('struct','TR');
#   $fsfile->changeMetaData('t-fs',undef);
#   $fsfile->changeMetaData('a-fs',$tr_fs);
#   $fsfile->changeTrees(@tr_trees);
#   $tr_fs->changeTrees(@trees);
#   $fsfile->changeFS($tr_header);
#   $tr_fs->changeFS($header);
  return 1;
}


sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  return unless which_struct() eq 'TR';
  my $tree = $fsfile->tree($treeNo);
  my $a_fs = adata($fsfile);
  my $ref = $tree->{'a.rf'}[0];
  $ref =~ s/^.*\#//;
  my $a_tree = aids($fsfile)->{$ref};
  return unless ($a_fs and $a_tree);
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
    push @sent,$node unless ($node->{m}{w}{origf} eq '');
    $node=$node->following();
  }
  @sent = map { [" ","space"],[$_->{m}{w}{origf},
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
  #'style:<? #diff ?><? "#{Line-fill:red}#{Line-dash:- -}" if $${_diff_dep_} ?>',
  if ($node->{_diff_dep_}) {
    $my_line{-fill}='red';
    $my_line{-dash}='- -';
  }
  if ($node->{_diff_attrs_}) {
    #'style:<? #diff ?><? "#{Oval-fill:darkorange}#{Node-addwidth:4}#{Node-addheight:4}" if $${_diff_attrs_} ?>',
    AddStyle($styles,'Oval',
	     -fill => 'darkorange');
    AddStyle($styles,'Node',
	     -addheight => 4,
	     -addwidth => 4
	    );
    #'style:<? #diff ?><? join "",map{"#{Text[$_]-fill:orange}"} split  " ",$${_diff_attrs_} ?>',
    AddStyle($styles,"Text[$_]", -fill => 'orange') for split " ",$node->{_diff_attrs_};
    #'style:<? #diff ?><? "#{Line-fill:black}#{Line-dash:- -}" if $${_diff_attrs_}=~/ TR/ ?>',
    if ($node->{_diff_attrs_}=~/ TR/) {
      $my_line{-dash}='- -';
      $my_line{-fill}='black';
    }
  } elsif ($node->{_diff_in_}) {
    #'style:<? #diff ?><? "#{Oval-fill:cyan}#{Line-fill:cyan}#{Line-dash:- -}" if $${_diff_in_} ?>',
    AddStyle($styles,'Oval',
	     -fill => 'cyan');
    AddStyle($styles,'Node',
	     -addheight => 4,
	     -addwidth => 4);

  } elsif (!$ARstruct) {
    if ($Coref::drawAutoCoref and $node->{corefMark}==1 and
	  $node->{'coref_text.rf'} eq "" and $node->{'coref_gram.rf'} eq "") {
      AddStyle($styles,'Node',
	       -shape => 'rectangle',
	       -addheight => 10,
	       -addwidth => 10
	      );
      AddStyle($styles,'Oval',
	       -fill => '#FF7D20');
    }
    if (($Coref::referent ne "") and
	  (($node->{TID} eq $Coref::referent) or
	     ($node->{AID} eq $Coref::referent))) {
      AddStyle($styles,'Oval',
	       -fill => $Coref::referent_color
	      );
      AddStyle($styles,'Node',
	       -addheight => 6,
	       -addwidth => 6
	      );
    }
  }

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

  if  (!$ARstruct and ($node->{'coref_text.rf'} or $node->{'coref_gram.rf'} or $node->{'complref.rf'})) {
    my @gram = grep {$_ ne "" } ListV($node->{'coref_gram.rf'});
    my @text = grep {$_ ne "" } ListV($node->{'coref_text.rf'});
    my @compl = grep {$_ ne "" } ListV($node->{'complref.rf'});
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
  my $id1=$root->{id};
  $id1=~s/:/-/g;
#  $id1=~s/-/:/;
  my (@coords,@colors);
  my ($rotate_prv_snt,$rotate_nxt_snt,$rotate_dfr_doc)=(0,0,0);
  my $ids={};
  my $nd = $root; while ($nd) { $ids->{$nd->{id}}=1 } continue { $nd=$nd->following };
  foreach my $coref (@$corefs) {
    my $cortype=shift @$cortypes;
    next if (!$drawAutoCoref and $cortype =~ /auto/);
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

#&n,n,
#(x$T+xn)/2 + $D*$Y,
#(y$T+yn)/2 - $D*$X,
#x$T,y$T


#&n,n,
#n + (x$T-n)/2 + (abs(xn-x$T)>abs(yn-y$T)?0:-40),
#n + (y$T-n)/2 + (abs(yn-y$T)>abs(xn-x$T) ? 0 : 40),
#x$T,y$T


#&n,n,
#n + (x$T-n)/2, n,
#n + (x$T-n)/2, y$T,
#x$T,y$T
      } else {
	my ($d,$p,$s,$l)=($id1=~/^(.*?)-p(\d+)s([0-9]+)([A-Z]*)$/);
	my ($cd,$cp,$cs,$cl)=($coref=~/^(.*?)-p(\d+)s([0-9]+)([A-Z]*).\d+/);
	print STDERR "ref-arrows: $d,$p,$s,$l versus $cd,$cp,$cs,$cl\n" if $main::macroDebug;
	if ($d eq $cd) {
	  print STDERR "ref-arrows: Same document\n" if $main::macroDebug;
	  # same document
	  if ($cp<$p || $cp==$p && ($cs<$s or $cs == $s and $cl lt $l)) {
	    # preceding sentence
	    print STDERR "ref-arrows: Preceding sentence\n";
	    push @colors,$cortype_colors->{$cortype}; #'&#c53c00'
	    push @coords,"\&n,n,n-30,n+$rotate_prv_snt";
	    $rotate_prv_snt+=10;
	  } else {
	    # following sentence
	    print STDERR "ref-arrows: Following sentence\n" if $main::macroDebug;
	    push @colors,$cortype_colors->{$cortype}; #'&#c53c00'
	    push @coords,"\&n,n,n+30,n+$rotate_nxt_snt";
	    $rotate_nxt_snt+=10;
	  }
	} else {
	  # different document
	  print STDERR "ref-arrows: Different document?\n" if $main::macroDebug;
	  push @colors,$cortype_colors->{$cortype}; #'&#c53c00'
	  push @coords,"&n,n,n+$rotate_dfr_doc,n-30";
	  $rotate_dfr_doc+=10;
	  print STDERR "ref-arrows: Different document sentence\n" if $main::macroDebug;
	}
      }
  }
  if ($node->{corlemma} eq "sg") { # pointer to an unspecified segment of preceeding sentences
    print STDERR "ref-arrows: Segment - unaimed arrow\n" if $main::macroDebug;
    push @colors,$cortype_colors->{segment};
    push @coords,"&n,n,n-25,n";
  }
  elsif ($node->{corlemma} ne "") {
    AddStyle($styles,'Oval',
	      -fill => $cortype_colors->{textual}
	     );
    AddStyle($styles,'Node',
	      -shape => 'rectangle',
	      -addheight => '5',
	      -addwidth => '5'
	     );
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

# sub get_nodelist_hook {
#   my ($fs,$treeNo,$current)=@_;
#   $current = $current->firstson unless $current->parent;
#   return [[sort {$a->{deepord} <=> $b->{deepord}}
#     $fs->treeList->[$treeNo]->descendants],$current];
# }

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


