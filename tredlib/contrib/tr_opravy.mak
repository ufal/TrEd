## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2004-03-15 23:09:27 pajas>

package TR_Correction;
@ISA=qw(Tectogrammatic);
import Tectogrammatic;

# permitting all attributes modification
sub enable_attr_hook {
  return;
}

sub node_release_hook {
  my ($node,$p, $mod) = @_;
  if ($mod eq 'Shift') {
    ConnectAID($p,$node);
    light_aidrefs_reverse();
    Redraw_FSFile_Tree();
    ChangingFile(1);
  }
}

sub node_click_hook {
  my ($node, $mod) = @_;
  if ($mod eq 'Shift') {
    if ($node->{_light} eq '_LIGHT_') {
      delete $node->{_light};
    } else {
      $node->{_light} = '_LIGHT_'
    }
    Redraw_FSFile_Tree();
  } elsif ($mod eq 'Control') {
    foreach ($node->root->descendants) {
      delete $_->{_light};
    }
    $node->{_light} = '_LIGHT_';
    Redraw_FSFile_Tree();
  }
}

sub which_struct {
  if ($Fslib::parent eq "_AP_") {
    return "AR";
  } elsif ($Fslib::parent eq "_P_") {
    return "TR";
  } else {
    return "unknown";
  }
}

sub with_AR (&) {
  my ($code) = @_;
  if (which_struct() eq 'AR') {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  } else {
    PDT::ARstruct();
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    PDT::TRstruct();
    return wantarray ? @$ret : $ret;
  }
}

sub with_TR (&) {
  my ($code) = @_;
  if (which_struct() eq 'AR') {
    PDT::TRstruct();
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    PDT::ARstruct();
    return wantarray ? @$ret : $ret;
  } else {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  }
}

#bind add_ord_patterns to key Shift+F8 menu Show ord, dord, sentord, and del, AID/TID
sub add_ord_patterns {
  return unless $grp->{FSFile};
  my @pat=GetDisplayAttrs();
  my $hint=GetBalloonPattern();

  SetDisplayAttrs(@pat,'<? #corr ?>${ord}/${sentord}/${dord}/${del}',
		  '<? #corr ?>${AID}','<? #corr ?>${TID}');
}

#bind add_AID_to_AIDREFS to key Alt+s menu add AID to AIDREFS
sub add_AID_to_AIDREFS {
  if ($this->{AIDREFS} ne "" and
      $this->{AID} ne "" and
      index("|$this->{AIDREFS}|","|$this->{AID}|")<0) {
    $this->{AIDREFS}.='|'.$this->{AID};
    ChangingFile(1);
  } else {
    print STDERR "nothing to fix\n";
    ChangingFile(0);
  }
}

sub auto_fix_AID_if_marked_in_err1 {
  if ($this->{err1} =~ 
      s/missing AID for ord (\d+)\|redundant TID for ord (\d+)\|?//g) {
    do {{
      local $this=$this->parent;
      try_fix_AID() if $this;
    }};
    try_fix_AID();
    print "$this->{AID}\n";
    $this->{err1} =~ s/\|$//;
  }
}

#bind try_fix_AID to key Alt+i menu addremove TID, generate AID from ord
sub try_fix_AID {
  return unless $grp->{FSFile};
  unless ($this->{ord}=~/\./) {
    if ($this->{TID} ne "") {
      $this->{AID}=$this->{TID};
      $this->{AID}=~s/a\d+$/w$this->{ord}/;
      $this->{TID}="";
    } elsif ($this->{AIDREFS} ne "") {
      ($this->{AID})=grep { /w$this->{ord}$/ } split /\|/,$this->{AIDREFS};
      if ($this->{AID} eq '') {
	($this->{AID})=split /\|/,$this->{AIDREFS};
	$this->{AID}=~s/w\d+$/w$this->{ord}/;
      }
    }
  }
}

#bind reorder_sentord to key Alt+j menu Reorder sentord
sub reorder_sentord {
  my @nodes=grep {$_->{ord} !~ /\./} GetNodes();
  @nodes = sort {$a->{sentord} <=> $b->{sentord}} @nodes;
  my $sentord=0;
  foreach (@nodes) {
    $_->{sentord}=$sentord++;
  }
}

#bind reorder_ord to key Alt+k menu Reorder ord
sub reorder_ord {
  my @nodes=grep {$_->{ord} !~ /\./} GetNodes();
  @nodes = sort {$a->{sentord} <=> $b->{sentord}} @nodes;
  my $sentord=0;
  foreach (@nodes) {
    $_->{ord}=$sentord++;
  }
}


sub remove_ord_patterns {
  SetDisplayAttrs(grep { !/ \#corr / } GetDisplayAttrs());
}

sub add_commentA {
  my ($comment,$node)=@_;
  $node = $this unless ref($node);
  $node->{commentA}.='|' if $node->{commentA} ne "";
  $node->{commentA}.=$comment;
}

sub prepend_commentA {
  my ($comment,$node)=@_;
  $node = $this unless ref($node);
  $comment.='|' if $node->{commentA} ne "";
  $node->{commentA}=$comment.$node->{commentA};
}


sub hash_AIDs {
  my %aids;
  my $node=ref($_[0]) ? $_[0] : $root;
  while ($node) {
    $aids{$node->{AID}.$node->{TID}} = $node;
    $node=$node->following;
  }
  return \%aids;
}

sub uniq { my %a; @a{@_}=@_; values %a }


#bind clean_fw_join_to_parent to Ctrl+exclam menu Clean fw and AIDREFS of current node, repaste children to parent and joinfw with parent
sub clean_fw_join_to_parent {
  shift if @_ and not ref($_[0]);
  my $node = $_[0] || $this;
  return unless $node->parent;
  $node->parent->{fw}='';
  $node->parent->{AIDREFS}='';
  foreach ($node->children) {
    PasteNode(CutNode($_),$node->parent);
  }
  { local $this=$node; joinfw(); };
}

#bind clean_fw_AIDREFS to Ctrl+at menu Clear fw and AIDREFS of current node
sub clean_fw_AIDREFS {
  shift if @_ and not ref($_[0]);
  my $node = $_[0] || $this;
  $node->{fw}='';
  $node->{AIDREFS}='';
}

#bind join_AIDREFS to Ctrl+J menu Join current node's AID to parent's AIDREFS
sub join_AIDREFS {
  shift if @_ and not ref($_[0]);
  my $node = $_[0] || $this;
  my $parent = $_[1] || $this->parent;
  return unless $parent;
  ConnectAID($parent,$node);
}


#bind rehang_right to Ctrl+Shift+Right menu Rehang to right brother
sub rehang_right {
  return unless ($this and $this->rbrother);
  my $b=$this->rbrother;
  $this=PasteNode(CutNode($this),$b);
}
#bind rehang_left to Ctrl+Shift+Left menu Rehang to left brother
sub rehang_left {
  return unless ($this and $this->lbrother);
  my $b=$this->lbrother;
  $this=PasteNode(CutNode($this),$b);
}
#bind rehang_down to Ctrl+Shift+Down menu Rehang to first son
sub rehang_down {
  return unless ($this and $this->firstson and $this->parent);
  my $p=$this->parent;
  my $b=CutNode($this->firstson);
  $this=PasteNode(CutNode($this),$b);
  $b=PasteNode($b,$p);
  foreach ($this->children) {
    PasteNode(CutNode($_),$b);
  }
}
#bind rehang_up to Ctrl+Shift+Up menu Rehang to parent
sub rehang_up {
  return unless ($this and $this->parent and $this->parent->parent);
  my $p=$this->parent->parent;
  $this=PasteNode(CutNode($this),$p);
}

#bind SwapNodes to Ctrl+9 menu Swap nodes
sub SwapNodes {
  Analytic_Correction::SwapNodes;
}

#bind UnhideNode to Ctrl+H menu Unhide current node and all ancestors
sub UnhideNode {
  shift if $_[0] and !ref($_[0]);
  my $node = $_[0] || $this;
  while ($node) {
    $node->{TR}='' if $node->{TR} eq 'hide';
    $node=$node->parent;
  }
}

#bind AssignTrLemma to Ctrl+L menu Regenerate trlemma from lemma
sub AssignTrLemma {
  my $lemma = $this->{lemma};
  $lemma =~ s/[-_`&].*$//;
  $this->{trlemma}=$lemma;
}

#bind goto_father to Ctrl+F menu Go to real father
sub goto_father {
  print STDERR map {$_->{trlemma},"\n"} PDT::GetFather_TR($this);
  ($this) = @father;
  ChangingFile(0);
  $Redraw='none';
}

#bind edit_lemma_tag to Ctrl+T menu Edit lemma and tag (using morph)
sub edit_lemma_tag {
  Analytic_Correction::edit_lemma_tag();
}

#bind analytical_tree to Ctrl+A menu Display analytical tree
sub analytical_tree {
  PDT::ARstruct();
  ChangingFile(0);
}

#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree
sub tectogrammatical_tree {
  PDT::TRstruct();
  ChangingFile(0);
}

#bind tectogrammatical_tree_store_AR to Ctrl+B menu Save ordorig of AR tree and display tectogrammatical tree
sub tectogrammatical_tree_store_AR {
  my $node = $root;
  if ($Fslib::parent eq "_AP_") {
    while ($node) {
      $node->{ordorig} = $node->parent->{ord} if $node->parent;
      $node=$node->following();
    }
  }
  PDT::TRstruct();
  PDT::ClearARstruct();
  ChangingFile(0);
}

#bind light_aidrefs to Ctrl+a menu Mark AIDREFS nodes with _light = _LIGHT_
sub light_aidrefs {
  my$aids=hash_AIDs();
  foreach my$aid(keys %$aids){
    $aids->{$aid}->{_light}='';
  }
  foreach my$aid(getAIDREFs($this)){
    if(exists$aids->{$aid}){
      $aids->{$aid}->{_light}='_LIGHT_' if$aid ne$this->{AID};
    }else{
      $this->{_light}=join'|',(split/\|/,$this->{_light}),$aid;
    }
  }
  ChangingFile(0);
}

#bind light_aidrefs_reverse to Ctrl+b menu Mark nodes pointing to current via AIDREFS with _light = _LIGHT_
sub light_aidrefs_reverse {
  my $node = $root;
  while ($node) {
    if ($node != $this and
	getAIDREFsHash($node)->{$this->{AID}}) {
      $node->{_light}='_LIGHT_';
    } else {
      delete $node->{_light};
    }
    $node=$node->following;
  }
  ChangingFile(0);
}

#bind light_aidrefs_reverse_expand to Ctrl+r menu Mark nodes pointing to current via AIDREFS with _light = _LIGHT_ expanding coords
sub light_aidrefs_reverse_expand {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  $node = $root;
  while ($node) {
    if ($node != $this and
	getAIDREFsHash($node)->{$this->{AID}}) {
      $node->{_light}='_LIGHT_';
      foreach my $r (PDT::expand_coord_apos_TR($node)) {
	$r->{_light}='_LIGHT_'; 
      }
    }
    $node=$node->following;
  }
  ChangingFile(0);
}


#bind light_ar_children to Ctrl+c menu Mark true analytic children of current node with _light = _LIGHT_
sub light_ar_children {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  PDT::ARstruct();
  foreach (PDT::GetChildren_AR($this,
			       sub { 1 },
			       sub { $_[0]{afun}=~/Aux[PC]/ })) {
    $_->{_light}='_LIGHT_';
  }
  PDT::TRstruct();
  ChangingFile(0);
}


#bind light_tr_children to Ctrl+t menu Mark true tectogramatic children of current node with _light = _LIGHT_
sub light_tr_children {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  foreach (PDT::GetChildren_TR($this)) {
    $_->{_light}='_LIGHT_';
  }
  ChangingFile(0);
}


#bind remove_from_aidrefs to Ctrl+d menu Remove current node's AID from all nodes refering to it within the current tree
sub remove_from_aidrefs {
  my $node = $root;
  ChangingFile(0);
  while ($node) {
    if ($node != $this and
	getAIDREFsHash($node)->{$this->{AID}}) {
	$node->{AIDREFS} = join '|', grep { $_ ne $this->{AID} } split /\|/,$node->{AIDREFS};
	$node->{AIDREFS} = "" if ($node->{AIDREFS} eq $node->{AID});
	ChangingFile(1);
    }
    $node->{_light}='';
    $node=$node->following;
  }
}

#bind only_parent_aidrefs to Ctrl+p menu Make only parent have the current node among its AIDREFS
sub only_parent_aidrefs {
  remove_from_aidrefs();
  join_AIDREFS();
  light_aidrefs_reverse();
}

#################################################
sub first (&@);

sub expand_auxcp {
  my ($node)=@_;
  if ($node->{afun}=~/Aux[CP]/) {
    my @c = $node->children();
    if ($node->{afun}=~/_Co/ and $node->parent->{afun}=~/Coord/) {
      push @c, grep { $_->{afun} !~ /_Co/ } $node->parent->children()
    } elsif ($node->{afun}=~/_Ap/ and $node->parent->{afun}=~/Apos/) {
      push @c, grep { $_->{afun} !~ /_Ap/ } $node->parent->children()
    }
    if ($node->{afun}=~/AuxC/) {
      return
	map { expand_auxcp($_) }
	grep { $_->{afun} !~ /_Pa$/ and
	      ($_->{afun} !~ /Aux[KGYZX]/ or $_->firstson) } @c;
    } elsif ($node->{afun}=~/AuxP/) {
      return
	map { expand_auxcp($_) } # $_->{afun} !~ /_Pa$/ and
	grep { ($_->{afun} !~ /Aux[KPGZX]/ or $_->firstson) } @c;
    }
  } else {
    return $node;
  }
}

sub is_a_to {
  my ($node)=@_;
  return ($_->{afun} =~ /AuxY/ and $_->{lemma} eq 'ten' and
	  $_->firstson and !$_->firstson->rbrother and
	  $_->firstson->{lemma} eq 'a-1') ? 1 : 0;
}

sub expand_coord_apos_auxcp {
  my ($node,$keep)=@_;
  if (PDT::is_coord($node)) {
    return (($keep ? $node : ()),map { expand_coord_apos_auxcp($_,$keep) }
      grep { $_->{afun} =~ '_Co' }
	$node->children());
  } elsif (PDT::is_apos($node)) {
    return (($keep ? $node : ()), map { expand_coord_apos_auxcp($_,$keep) }
	    grep { $_->{afun} =~ '_Ap' }
	    $node->children());
  } elsif ($node->{afun} =~ /AuxC/) {
    return (($keep ? $node : ()), map { expand_coord_apos_auxcp($_,$keep) } 
	    grep { $_->{afun} !~ /_Pa$/ and ($_->{afun} !~ /Aux[KGYZX]/ or $_->firstson)}
	    $node->children());
  } elsif ($node->{afun} =~ /AuxP/) {
    return (($keep ? $node : ()), map { expand_coord_apos_auxcp($_,$keep) }
	    # $_->{afun} !~ /_Pa$/ and 
	    grep { ($_->{afun} !~ /Aux[KGPZX]/ or $_->firstson) }
	    $node->children());
  } else {
    return $node;
  }
}

sub children_of_auxcp {
  my ($node) = @_;
  my @c = expand_auxcp($node);
  if (@c>1 and first { $_->{afun} !~ /ExD/ } @c) {
    print "ERROR:\tAux[CP] with too many childnodes\t";
    PDT::TRstruct();
    print ThisAddressNTRED($node);
    PDT::ARstruct();
    my $af = ThisAddress($node);
    $af=~s{.*/}{};
    $af=~s{\.pls\.gz}{.fs};
    $af="/net/su/h/pdt2004/Corpora/PDT_1.0/Data/fs/$af";
    print "\t$af\n";
  }
  return map { expand_coord_apos_auxcp($_) } @c;
}

#bind light_auxcp_children to Ctrl+f menu Mark nodes expected to refer to current node
sub light_auxcp_children {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  $node=$this;
  if ($node->{afun} =~ /Aux[P]/ and $node->{TR} eq 'hide') {
    # get real analytic children of AuxP (skip coords, Aux[CPZYKG])
    with_AR {
      my @c = grep { $_->{afun}!~/AuxZ/ } children_of_auxcp($node);
      foreach my $c (@c) {
	$c->{_light}='_LIGHT_';
      }
    };
  }
  ChangingFile(0);
}

#bind make_lighten_be_aidrefs to Ctrl+l menu Make nodes marked with _light=_LIGHT_ be the nodes and only the nodes referencing current node in AIDREFS
sub make_lighten_be_aidrefs {
  my $node = $root;
  my $rehang = ($node->parent->{_light} eq '_LIGHT_' ? 0 : 1);
  my $target;
  foreach my $node ($root->visible_descendants(FS())) {
    next if $node == $this;
    if ($node->{_light} eq '_LIGHT_') {
      ConnectAID($node,$this);
      if ($rehang) {
	PasteNode(Cut($this),$node);
	$rehang = 0;
      }
    } else {
      $node->{AIDREFS} = join '|', grep { $_ ne $this->{AID} } split /\|/,$node->{AIDREFS};
      $node->{AIDREFS} = "" if ($node->{AIDREFS} eq $node->{AID});
    }
  }
  ChangingFile(1);
}

#bind light_current to L menu Lighten current node
sub light_current {
  $this->{_light} = '_LIGHT_';
  ChangingFile(0);
}


############################################

