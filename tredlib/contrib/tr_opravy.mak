## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2005-02-06 14:04:57 pajas>

package TR_Correction;
@ISA=qw(Tectogrammatic);
import Tectogrammatic;

#bind FCopy to Ctrl+c menu copy node
#bind FPaste to Ctrl+C menu paste node


######################### Hooks ######################

%arrow_colors = (                           # colors of coreference arrows
  %Coref::cortype_colors,
  AID => 'cyan'
 );

#bind remember_this_node_AID to space menu AIDREFS: Remeber current node's AID
sub remember_this_node_AID {
  if ($this->{AID} ne '') {
    $aid_referent = $this->{AID};
    print STDERR "Remember:$aid_referent\n" if $main::macroDebug;
  }
}

#bind add_remembered_AID_to_AIDREFS to Shift+space menu AIDREFS: Add remembered AID to AIDREFs of current node
sub add_remembered_AID_to_AIDREFS {
  if ($aid_referent ne '') {
    unless ($this->{AID} eq $aid_referent or
	    getAIDREFsHash($this)->{$aid_referent}) {
      if ($this->{AIDREFS} eq "" and $this->{AID} ne "") {
	$this->{AIDREFS}=$this->{AID};
      }
      $this->{AIDREFS}.='|'.$aid_referent;
    }
    undef $aid_referent;
  }
}

sub switch_context_hook {
  Coref->switch_context_hook();
}

sub node_style_hook {
  my ($node,$styles)=@_;
  my $ARstruct = (which_struct() =~ /AR/) ? 1 : 0;
  my @aids = grep { $_ ne "" and $_ ne $node->{AID} } getAIDREFs($node);
  my %line;
  #'style:<? #diff ?><? "#{Line-fill:red}#{Line-dash:- -}" if $${_diff_dep_} ?>',
  if ($node->{_diff_dep_}) {
    $line{-fill}='red';
    $line{-dash}='- -';
  }
  if (($aid_referent ne "") and
	($node->{AID} eq $aid_referent)) {
    AddStyle($styles,'Oval',
	      -fill => 'cyan'
	     );
    AddStyle($styles,'Node',
	      -shape => 'rectangle',
	      -addheight => '6',
	      -addwidth => '6'
	     );
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
      $line{-dash}='- -';
      $line{-fill}='black';
    }
  } elsif ($node->{_diff_in_}) {
    #'style:<? #diff ?><? "#{Oval-fill:cyan}#{Line-fill:cyan}#{Line-dash:- -}" if $${_diff_in_} ?>',
    $line{-fill}='cyan';
    AddStyle($styles,'Oval',
	     -fill => 'cyan');
    AddStyle($styles,'Node',
	     -addheight => 4,
	     -addwidth => 4);

  } elsif (!$ARstruct) {
    if ($Coref::drawAutoCoref and $node->{corefMark}==1 and
	  ($node->{coref} eq "" or $node->{cortype}=~/auto/)) {
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
  if  (!$ARstruct) {
    Coref::draw_coref_arrows(
      $node,$styles,\%line,
      [
	(IsSeq($node->{coref}) ?
	 map {$_->{rf}} $node->{coref}->values :
	   split(/\|/,$node->{coref})),
	@aids ],
      [ (IsSeq($node->{coref}) ?
	map {$_->{type}} $node->{coref}->values :
	split(/\|/,$node->{cortype})),
	map "AID",@aids ],
      \%arrow_colors
     );
  }
  1;
}

sub file_close_hook {
  if (which_struct() eq 'AR') {
    PDT::TRstruct();
    Redraw();
  }
}

sub file_save_hook {
  if (which_struct() eq 'AR') {
    my $answ = questionQuery("Save file", "TrEd is currently displaying AR structure.\nReally save?",qw(Yes No),'Switch to TR and save');
    if ( $answ eq 'Yes'
	and
	questionQuery("Save file", "You realy want to save with AR structure only?\nReally, really?",qw(Yes No)) eq 'Yes') {
      return;
    } elsif ($answ eq 'No') {
      return "stop";
    } else {
      PDT::TRstruct();
      Redraw();
      return;
    }
  }
}

# permitting all attributes modification
sub enable_attr_hook {
  return;
}

sub node_release_hook {
  my ($node,$p, $mod) = @_;
  if ($mod eq 'Alt') {
    my @choices = (["grammatical coreference" => 'Shift'],
		   ["textual coreference" => 'Control'],
		   ["add source AID to AIDREFS of target" => 'Super']);
    my $selection=[$choices[0][0]];
    listQuery("What do you want to do",'browse',
	      [map { $_->[0] } @choices],
	      $selection) || return;
    ($mod) = map { $_->[1] } grep { $selection->[0] eq $_->[0] } @choices;
  }
  if ($mod eq 'Super') {
    if ($node->{AID}) {
      if (getAIDREFsHash($p)->{$node->{AID}}) {
	DisconnectAID($p,$node);
      } else {
	ConnectAID($p,$node);
      }
      Redraw_FSFile_Tree();
      ChangingFile(1);
    }
  } else {
    Coref::node_release_hook($node,$p,$mod);
  }
  return 1; # allow all
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


################### with_AR etc. ##################

sub which_struct {
  if ($Fslib::parent eq "_AP_") {
    return "AR";
  } elsif ($Fslib::parent eq "_P_" and $grp->{FSFile}) {
    my $o = $grp->{FSFile}->FS->order;
    if ($o eq 'dord') {
      return "TR";
    } elsif ($o eq 'ord') {
      return "AR-ONLY";
    }
  }
  return "unknown";
}

sub with_AR (&) {
  my ($code) = @_;
  if (which_struct() =~ /AR/) {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  } else {
    PDT::ARstruct();
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    PDT::TRstruct();
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  }
}

sub with_ARtree (&) {
  my ($code) = @_;
  if (which_struct() =~ /AR/) {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  } else {
    PDT::ARstruct(1);
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    PDT::TRstruct();
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  }
}

sub with_TRtree (&) {
  my ($code) = @_;
  die "Can't call with_TR on analytical files!" if which_struct() eq 'AR-ONLY';
  if (which_struct() eq 'AR') {
    PDT::TRstruct();
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    PDT::ARstruct(1);
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  } else {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  }
}

sub with_TR (&) {
  my ($code) = @_;
  die "Can't call with_TR on analytical files!" if which_struct() eq 'AR-ONLY';
  if (which_struct() eq 'AR') {
    PDT::TRstruct();
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    PDT::ARstruct();
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  } else {
    my $ret = wantarray ? [ eval { &$code } ] : eval { &$code };
    die $@ if $@;
    return wantarray ? @$ret : $ret;
  }
}

########################## Macros #######################

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


=item hash_AIDs_file

Returns hash-ref of all nodes in the current file, nodes' AIDs or TIDs
being the keys and the nodes themselves being the values.

=cut

sub hash_AIDs_file {
  my %aids;
  foreach my $tree (GetTrees()) {
    my $node=$tree;
    $node=$node->following;
    while ($node) {
      $aids{$node->{AID}.$node->{TID}} = $node;
      $node=$node->following;
    }
  }
  return \%aids;
}

=item hash_AIDs

Returns hash-ref of all nodes in the current tree, nodes' AIDs or TIDs
being the keys and the nodes themselves being the values.

=cut

sub hash_AIDs {
  my %aids;
  my $node=ref($_[0]) ? $_[0] : $root->following;
  while ($node) {
    $aids{$node->{AID}.$node->{TID}} = $node;
    $node=$node->following;
  }
  return \%aids;
}

=item hash_copies

Returns hash-ref in which keys are the nodes themselves and values references to
arrays containing all nodes which are copies of the same tectogrammatical node
(ie nodes that are copies of a node (and the node itself) point to one array
containing all of them).

=cut

sub hash_copies {  # hash all copies of nodes for the whole file

  my $aidsHash = hash_AIDs_file();
  my %copies;

  my %exceptions; # nodes having in AIDREFs nodes in different files
  @exceptions{qw/cmpr9410-015-p11s9a0 cmpr9413-033-p30s2a1 cmpr9413-033-p30s2w1
		 cmpr9413-033-p31s2a3 cmpr9413-033-p31s2w1 cmpr9413-033-p31s2w5/}=();

  foreach my $tree (GetTrees()) {
    my $node = $tree;
    while ($node) {

      next if exists $exceptions{$node->{AID}.$node->{TID}}; # reference in another file

      foreach my $ref (grep {$_!=$node and !IsHidden($_) and defined($_)}
		       map {$aidsHash->{$_}} grep {$_ ne ""} (split /\|/, $node->{AIDREFS})) {

	if ($node->{trlemma} eq $ref->{trlemma}) { # we encountered a copy of $node
	  if (not exists($copies{$ref}) and not exists($copies{$node})) { # create new class
	    $copies{$node}=[$node,$ref];
	    $copies{$ref}=$copies{$node};
	    next;
	  }
	  if (not exists($copies{$ref}) and exists($copies{$node})) { # append to the class of $node
	    push @{$copies{$node}}, $ref;
	    $copies{$ref}=$copies{$node};
	    next;
	  }
	  if (exists($copies{$ref}) and not exists($copies{$node})) { # append to the class of $ref
	    push @{$copies{$ref}}, $node;
	    $copies{$node}=$copies{$ref};
	    next;
	  }
	}#if

      }#foreach ref

    }#while

    continue {
      $node=$node->following_visible(FS());
    }#continue while

  }#foreach tree
  return \%copies;
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

  if ($this->{TID} ne '' and $this->{lemma} eq '-') {
    if ($this->{trlemma} =~ /^(tady|tam)$/ or
	$this->{func} =~ /DIR[1-3]|LOC/) {
      QuerySemtam($this);
    } elsif ($this->{trlemma} eq 'kdy') {
      QueryKdy($this);
    } else {
      QueryTrlemma($this);
    }
  } else {
    $lemma = PDT::GetNewTrlemma();
    $this->{trlemma}=$lemma;
  }
}

#bind goto_father to Ctrl+F menu Go to real father
sub goto_father {
  print STDERR map {$_->{trlemma},"\n"} PDT::GetFather_TR($this);
  ($this) = @father;
  ChangingFile(0);
  $Redraw='none';
}

#bind lemma_tag_Xat to Alt+at menu Assign X@------------ to tag and form to lemma
sub lemma_tag_Xat {
  $this->{lemma}=$this->{form};
  $this->{tag}='X@-------------';
}

#bind edit_lemma_tag to Ctrl+T menu Edit lemma and tag (using morph)
sub edit_lemma_tag {
  Analytic_Correction::edit_lemma_tag();
}

#bind analytical_tree to Ctrl+A menu Display analytical tree
sub analytical_tree {
  PDT::ARstruct() if (which_struct() eq 'TR');
  ChangingFile(0);
}

#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree
sub tectogrammatical_tree {
  PDT::TRstruct() if (which_struct() eq 'AR');
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


#bind light_ar_children to Ctrl+h menu Mark true analytic children of current node with _light = _LIGHT_
sub light_ar_children {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  with_AR {
    foreach (
	grep { $_->{afun} !~ /Aux[CPYZXG]/ }
	     PDT::GetChildren_AR($this,
				 sub { 1 },
				 sub { $_[0]{afun}=~/Aux[PC]/ })
	    ) { $_->{_light}='_LIGHT_'; 
		print "SON: $_\n";
	      }
  };
  ChangingFile(0);
}

#bind light_ar_parent to Ctrl+i menu Mark true analytic parent(s) of current node with _light = _LIGHT_
sub light_ar_parent {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  with_AR {
    foreach (
	grep { $_->{afun} !~ /Aux[CPYZXG]/ }
	     PDT::GetFather_AR($this,
				 sub { $_[0]{afun}=~/Aux[PC]/ })
	    ) { $_->{_light}='_LIGHT_'; 
		print "PARENT: $_\n";
	      }
  };
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
  ChangingFile();
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
  @c = map { expand_coord_apos_auxcp($_) } @c;
  if (@c>1 and first { $_->{afun} !~ /ExD/ } @c) {
    print "ERROR:\tAux[CP] with too many childnodes ";
    print map {$_->{form}.".".$_->{afun}.".".$_->{AID}." "} @c;
    print "\t";
    PDT::TRstruct();
    print ThisAddressNTRED($node);
    PDT::ARstruct();
    my $af = ThisAddress($node);
    $af=~s{.*/}{};
    $af=~s{\.pls\.gz}{.fs};
    $af="/net/su/h/pdt2004/Corpora/PDT_1.0/Data/fs/$af";
    print "\t$af\n";
  }
  return @c;
}

#bind light_auxcp_children to Ctrl+f menu Mark nodes expected to refer to current node
sub light_auxcp_children {
  my $node = $root;
  while ($node) {
    delete $node->{_light};
    $node=$node->following;
  }
  $node=$this;
  if ($node->{afun} =~ /Aux[CP]/ and $node->{TR} eq 'hide') {
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

#bind make_lighten_be_children to Ctrl+s menu Make nodes marked with _light=_LIGHT_ children of active node and add them to ative node's AIDREFS
sub make_lighten_be_children {
  my $node = $root;
  my $target;
  foreach my $node ($root->descendants(FS())) {
    if ($node->{_light} eq '_LIGHT_') {

      my $p = $this;
      $p = $p->parent while ($p and $p!=$node);
      next if ($p == $node);

      $node->{TR} = 'hide';
      ConnectAID($this,$node);
      PasteNode(Cut($node),$this);
      delete $node->{_light};
      ChangingFile(1);
    }
  }
}

#bind add_lighten_to_aidrefs to Ctrl+q menu Reference only nodes marked with _light=_LIGHT_ from active node's AIDREFS
sub add_lighten_to_aidrefs {
  my $node = $root;
  my $target;
  $node->{AIDREFS}='';
  while ($node) {
    if ($node->{_light} eq '_LIGHT_') {
      ConnectAID($this,$node);
      ChangingFile(1);
    }
    $node = $node->following;
  }
}


#bind light_current to L menu Lighten current node
sub light_current {
  $this->{_light} = '_LIGHT_';
  ChangingFile(0);
}


sub MoveTreeToPrev {
  my @children = $root->children;
  foreach (@children) {
    Cut($_);
  }
  PrevTree();
  foreach (@children) {
    PasteNode($_,$root);
  }
}

# OBSOLETE use CutPasteSubTree instead

# #bind JoinNextTree to Ctrl+4 menu Join the following tree with the current tree (both TR and AR layer)
# sub JoinNextTree {
#   my @nodes = ($root->descendants());
#   PDT::ClearARstruct();
#   my %max;
#   $max{ord}     = max(map { $_->{ord} } $root, @nodes);
#   $max{dord}    = max(map { $_->{dord} } $root,@nodes);
#   $max{sentord} = max(map { $_->{sentord} } $root, grep { $_->{AID} ne "" } @nodes);
#   $max{ordorig} = $max{ord};
#   return unless NextTree();
#   foreach my $atr (qw(ord dord sentord ordorig)) {
#     foreach my $node ($root->descendants()) {
#       $node->{$atr} += $max{$atr};
#     }
#   }
#   MoveTreeToPrev();
# }

# sub __renumber_by {
#   my $atr = shift;
#   my $i=0;
#   my @list = sort { $a->{$atr} <=> $b->{$atr} } @_;
#   foreach (@list) { $_->{$atr}=$i++ }
# }

# #bind JoinSubtreeToPrev to Ctrl+2 menu Join current subtree with the previous tree
# sub JoinSubtreeToPrev {
#   unless ($this->parent) {
#     return unless PrevTree();
#     JoinNextTree();
#     return;
#   }

#   CutSubtreeBeforeMove();
#   if (PrevTree()) {
#     PasteMovedSubtree();
#   } else {
#     undef $SubtreeToMove;
#   }
# }

# #bind CutSubtreeBeforeMove to Ctrl+5 menu Cut subtree to be moved to another tree or file
# sub CutSubtreeBeforeMove {
#   my @nodes;
#   if ($this->parent) {
#     @nodes = ($this);
#   } else {
#     @nodes = $this->children();
#   }
#   my @subtree = grep ref,map { ($_,$_->descendants()) } @nodes;
#   my @anal  = grep $_->{AID}, @subtree;
#   my @added = grep $_->{TID}, @subtree;
#   my %astruct;
#   with_AR { $astruct{$_} = $_->parent for @anal };
#   PDT::ClearARstruct();

#   __renumber_by('dord',@subtree);
#   __renumber_by('sentord',@anal);
#   __renumber_by('ord',@anal);

#   Cut($_) for @nodes;

#   my @rest = $root->descendants();
#   my @rest_anal = grep $_->{AID}, @rest;
#   __renumber_by('dord',$root,@rest);
#   __renumber_by('sentord',$root,@rest_anal);
#   __renumber_by('ord',$root,@rest_anal);

#   $SubtreeToMove = [ \@nodes,\@subtree,\@anal,\@added, \%astruct ];
# }

# #bind PasteMovedSubtree to Ctrl+6 menu PasteMovedSubtree
# sub PasteMovedSubtree {
#   return unless ref($SubtreeToMove);
#   PDT::ClearARstruct();
#   my ($nodes, $subtree, $anal, $added, $astruct) = @$SubtreeToMove;
#   undef $SubtreeToMove;
#   my @nodes = ($root->descendants());
#   my %max;
#   $max{ord1}   = max(map { $_->{ord}=~/\.(\d+)/ ? $1 : 0 } $root, @nodes);
#   $max{ord}     = max(map { $_->{ord} } $root, @nodes);
#   $max{dord}    = max(map { $_->{dord} } $root,@nodes);
#   $max{sentord} = max(map { $_->{sentord} } $root, grep { $_->{AID} ne "" } @nodes);

#   PasteNode($_,$root) for @$nodes;

#   foreach my $atr (qw(ord dord sentord)) {
#     foreach my $node ($atr eq 'dord' ? @$subtree : @$anal) {
#       $node->{$atr} += $max{$atr}+1;
#     }
#   }
#   $_->{ordorig} = $astruct->{$_}->{ord} for @$anal;
#   $_->{ord} = int($_->parent->{ord}).".".(++$max{ord1}) for @$added;
# }

#bind insert_node to Insert menu Insert new node on both TR and AR layers
sub insert_node {
  PDT::ClearARstruct();
  my$aid=$this->{AID}.$this->{TID};
  $aid=~s/[wa]\d+$/w/;
  $aid.=max(map{$_->{AID}=~m/w(\d+)$/?$1:0}$root->descendants())+1;
  foreach my$node (grep{
    $_->{sentord}>$this->{sentord}
      and$_->{AID}
    }$root->descendants()){
    $node->{sentord}++;
  }
  foreach my$node (grep{
    $_->{ordorig}>$this->{ord}
      and$_->{AID}
    }$root->descendants()){
    $node->{ordorig}++;
  }
  foreach my$node(grep{
    $_->{ord}>$this->{ord}
      and$_->{AID}
    }$root->descendants()){
    $node->{ord}++;
  }
  my$new=TredMacro::NewSon($this); #calculates dord
  $new->{AID}=$aid;
  $new->{ord}=$this->{ord}+1;
  $new->{sentord}=$this->{sentord}+1;
  $new->{ordorig}=$this->{ord};
  $new->{afun}='???';
  $new->{func}='???';
  $new->{origfkind}='spell';
  $this=$new;
}#insert_node


#bind join_with_mother to asciicircum menu Join with mother
sub rehang_children_to_mother{
  print STDERR "rctmacf called from $this->{trlemma}\n";
  my$parent=$this->parent;
  print STDERR ('CHILDREN: ',(map{$_->{trlemma}}$this->children),"\n");
  foreach my$child($this->children){
    CutPaste($child,$parent);
    print STDERR "Rehanging $child->{trlemma} to $parent->{trlemma}\n";
  }
}#rehang_children_to_mother

sub join_with_mother {
  ChangingFile(0);
  return unless($this->{AID}
                and$this->parent
                and$this->parent->{AID}
                and with_AR{$this->parent}==$this->parent
                and$this->{ord}==$this->parent->{ord}+1);

  my$parent=$this->parent;
  $parent->{form}.=$this->{form};

  if($parent->{origfkind}!~/spell/){
    $parent->{origfkind}=($parent->{origfkind}?$parent->{origfkind}.'|':'').'spell';
  }
  delete_analytical_node_from_all_layers();
}#join_with_mother

#bind delete_analytical_node_from_all_layers to Ctrl+Delete
sub delete_analytical_node_from_all_layers {
  shift unless ref($_[0]);
  my $node = $_[0] || $this;
  ChangingFile(0);
  return unless($node->{AID} and $node->parent);

  my$parent=$node->parent;

  rehang_children_to_mother;
  PDT::ARstruct();
  rehang_children_to_mother;
  tectogrammatical_tree_store_AR();

  my($sentord,$ord,$dord)=map{$node->{$_}}qw/sentord ord dord/;
  Cut($node);
  with_AR{Cut($node)};

  foreach my$node (grep{
    $_->{sentord}>$sentord and$_->{AID}
  }$root->descendants()){
    $node->{sentord}--;
  }
  foreach my$node (grep{
    $_->{ordorig}>$ord and$_->{AID}
  }$root->descendants()){
    $node->{ordorig}--;
  }
  foreach my$node(grep{
    $_->{ord}>$ord and$_->{AID}
  }$root->descendants()){
    $node->{ord}--;
  }
  foreach my$node(grep{
    $_->{dord}>$dord
  }$root->descendants()){
    $node->{dord}--;
  }
  $this=$parent if $this==$node;
  ChangingFile(1);
}#delete_analytical_node_from_all_layers

=item recountAll (shift_ord, shift_dord, nodes)

Normalizes ords, dords and sentords of given nodes so that they start
at given value and the increment in ord at AR and dord at TR is
1. Ordorig must be set manually.

=cut

sub recountAll ($$@){
  my($shiftOrd,$shiftDord,@nodes)=@_;
  print"RECOUNT $shiftOrd,$shiftDord,$nodes[0]->{trlemma}\n";
  my$maxOrd;
  with_AR{
    NormalizeOrds(SortByOrd([grep{$_->{AID}}@nodes]));
    foreach my$node(grep{$_->{AID}}@nodes){
      $node->{ord}+=$shiftOrd;
      $maxOrd=$node->{ord}if$node->{ord}>$maxOrd;
    }
  };
  my$number;
  $_->{ord}=int($_->parent->{ord}).'.'.++$number foreach grep{$_->{TID}}@nodes;
  NormalizeOrds(SortByOrd(\@nodes));
  my$maxDord;
  foreach(@nodes){
    $_->{dord}+=$shiftDord;
    $maxDord=$_->{dord}if$_->{dord}>$maxDord;
  }
  $_->{sentord}=($_->{AID}?$_->{ord}:999)
    foreach@nodes;
  return($maxOrd,$maxDord);
}# recountAll

sub _testChainOfNoColor{
  my$node=$_[0];
  my@aidch=$node->children;
  my$magch=grep{$_->{_light}eq'_LIGHT_magenta'}@aidch;
  my$blch=grep{$_->{_light}eq'_LIGHT_blue'}@aidch;
  if($magch and not $blch){
    $node->{_light}='_LIGHT_magenta';
    return 1;
  }elsif(not $magch and $blch){
    $node->{_light}='_LIGHT_blue';
    return 2;
  }elsif($magch and$blch){
    $this=$node;
    print("Cannot decide $node->{trlemma}.\n"),return 0;
  }
  3;
}#_testChainOfNoColor

=item PrepareCutHere (node?)

Divides nodes into two sets so that the sentence can be split in two
by C<CutPasteSubTree>.

=cut

#bind PrepareCutHere to slash menu Prepare Cut Here
sub PrepareCutHere(;$){
  shift unless ref $_[0];
  my$Node=$_[0]||$this;
  print("Cannot split on this node.\n"),return unless$Node->{AID};
  foreach my$node($root->descendants){
    $node->{_light}='';
    $node->{_light}='_LIGHT_magenta'
      if$node->{AID}&&$node->{ord}>=$Node->{ord}
        or$node->{TID}&&$node->parent->{_light}eq'_LIGHT_magenta';
    $node->{_light}='_LIGHT_blue'
      if$node->{AID}and$node->{ord}<$Node->{ord}
        or$node->{TID}&&$node->parent->{_light}eq'_LIGHT_blue';
  }
  my@problematic=grep{$_->{TID}}$root->children;
  foreach my$prb(@problematic){
    return unless _testChainOfNoColor($prb);
  }
  my$nochange;
  until($nochange){
    $nochange=1;
    foreach(grep{$_->{TID}and!$_->{_light}}$root->descendants){
      my$test=_testChainOfNoColor($_);
      return unless $test;
      $nochange=0 if$test!=3;
    }
  }
  my$problem=first{$_->{TID}and not$_->{_light}}$root->descendants;
  $this=$problem if$problem;
}#PrepareCutHere

=item NewID (node?)

Assigns a new ID1 to node's root (uses C<$this> if no node is given).

=cut

#bind NewID to numbersign

sub NewID(;$){
  shift unless ref $_[0];
  my$node=$_[0]||$this;
  $node=$node->root if$node->parent;
  my($suf,$iprfx,$lprfx);
  my$sentnum=$node->{ID1};
  if($sentnum!~/[[:upper:]]$/){
    $suf='A';
    $iprfx=$sentnum;
    $lprfx=$node->{trlemma};
  }else{
    $sentnum=~s/.$//;
    $iprfx=$sentnum;
    $lprfx=$node->{trlemma};
    $lprfx=~s/[[:upper:]]$//;
    my@trees=map{s/^.*(.)$/$1/;$1}
      grep{$_=~/^\Q$sentnum\E\D/}
        map{$_->{ID1}}GetTrees();
    $suf=[sort@trees]->[@trees-1];
    $suf++;
    print"@trees;$suf\n";
  }
  $node->{trlemma}=$lprfx.$suf;
  $node->{form}=$lprfx.$suf;
  $node->{origf}=$lprfx.$suf;
  $node->{ID1}=$iprfx.$suf;
  ChangingFile(1);
}#NewID


=item NewSentenceAfter_TR

Inserts a new TR sentence after the current one.

=cut

#bind NewSentenceAfter_TR to bar menu Create New TR Sentence After Current
sub NewSentenceAfter_TR{
  NewID($root)if$root->{ID1}!~/[[:upper:]]$/;
  my$oldsent=$root;
  my$newsent=NewTreeAfter();
  foreach my$attr(qw/func trlemma afun dord ord sentord ID1 lemma tag para reserve1/){
    $newsent->{$attr}=$oldsent->{$attr};
  }
  NewID($newsent);
  $newsent->{form}=$newsent->{trlemma};
  $newsent->{origf}=$newsent->{trlemma};
}#NewSentenceAfter_TR

=item CutPasteSubTree

Must be run immediately after C<PrepareCutHere>. Cuts the subtree to
which the current nodes belongs and moves it the appropriate way.

=cut

#bind CutPasteSubTree to asterisk menu Cut Colored Subtrees and Paste Them
sub CutPasteSubTree{
  return if first{$_->{_light}!~/_LIGHT_(?:magenta|blue)$/}$root->descendants;
  return if$this==$root;
  my$left=$this->{_light}eq'_LIGHT_blue';
  return if$left&&CurrentTreeNumber()==0 or !$left&&CurrentTreeNumber()==GetTrees();
  my($new_ord,$new_dord); # amount to shift ords and dords
  my@right_a_nodes=grep{$_->{AID}and$_->{_light}eq'_LIGHT_magenta'}$root->descendants;
  my@right_t_nodes=grep{$_->{_light}eq'_LIGHT_magenta'}$root->descendants;
  my@left_a_nodes=grep{$_->{AID}and$_->{_light}eq'_LIGHT_blue'}$root->descendants;
  my@left_t_nodes=grep{$_->{_light}eq'_LIGHT_blue'}$root->descendants;
  my(@move_a,@move_t,@stay_a,@stay_t);
  if($left){
    @move_a=@left_a_nodes;
    @move_t=@left_t_nodes;
    @stay_a=@right_a_nodes;
    @stay_t=@right_t_nodes;
  }else{
    @move_a=@right_a_nodes;
    @move_t=@right_t_nodes;
    @stay_a=@left_a_nodes;
    @stay_t=@left_t_nodes;
  }
  NewID($root);
  my$newsent;
  if($left){
    PrevTree();
    $new_ord=max(map{$_->{ord}}grep{$_->{AID}}$root->descendants)+1;
    $new_dord=max(map{$_->{dord}}$root->descendants)+1;
    $newsent=$root;
    NextTree();
    recountAll(1,1,@stay_t);
  }else{#right
    $new_ord=1;
    $new_dord=1;
    NextTree();
    $newsent=$root;
    recountAll(1+scalar @move_a,1+scalar @move_t,$root->descendants);
    with_AR{
      $_->{ordorig}=$_->parent->{ord} foreach(grep{$_->{AID}}$root->descendants);
    };
    PrevTree();
  }
  recountAll($new_ord,$new_dord,@move_t);
  with_AR{
    foreach my$node(@move_a){
      CutPaste($node,$newsent)if$node->parent->{_light}ne$node->{_light};
      $node->{ordorig}=$node->parent->{ord};
    }
    foreach my$node(@stay_a){
      CutPaste($node,$root)if$node->parent->{_light}ne$node->{_light};
      $node->{ordorig}=$node->parent->{ord};
    }
  };
  foreach my$node(@move_t){
    CutPaste($node,$newsent)if$node->parent->{_light}ne$node->{_light};
  }
  foreach my$node(@stay_t){
    CutPaste($node,$root)if$node->parent->{_light}ne$node->{_light};
  }
}#CutPasteSubTree

#bind mark_blue to question

=item mark_blue

Makes the node blue, magenta or of no colour to be used by
C<CodePasteSubTree>.

=cut

sub mark_blue {
  if($this->{_light}eq'_LIGHT_blue'){
    $this->{_light}='_LIGHT_magenta';
  }elsif($this->{_light}eq'_LIGHT_magenta'){
    $this->{_light}='';
  }else{
    $this->{_light}='_LIGHT_blue';
  }
}#mark_blue



=item untouch()

Returns 1 if the current tree is untouchable.

=cut

#bind untouch to backslash
sub untouch {
  ChangingFile(0);
  if(system
     "grep '^".$root->{ID1}."\$' /net/projects/pdt/work/TR/kontrola/all/untouchables*"){
    print "TOUCHABLE\n";
    0;
  }else{
    print "NOT touchable\n";
    1;
  }
}#untouch

=item remove_func_questionmarks()

Removes ??? from func of a given node or $this

=cut

#bind remove_from_aidrefs to semicolon
sub remove_from_aidrefs {
  shift unless ref($_[0]);
  my $node=ref($_[0]) ? $_[0] : $this;
  $this->{func} = join '|', grep {$_ ne ''} grep {$_ ne '???'} split /\|/,$this->{func};
}


#### TFA

#bind edit_tfa to Alt+t menu Edit TFA attribute
sub edit_tfa {
  EditAttribute($this,'tfa');
}

#bind TFA->ProjectivizeCurrentSubTree to Alt+p menu Projectivize subtree


#ifinclude <contrib/pdt_tags.mak>
#bind show_tag to Alt+T menu Show detailed morphological tag description
sub show_tag {
  describe_tag($this->{tag});
}

############# TR_Diff #############

#bind DiffTRFiles              to equal      menu Compare trees
#bind DiffWholeTRFiles         to Alt+equal  menu Compare files
#bind DiffTRFiles_with_summary to Ctrl+plus  menu Compare trees with summary
#bind TR_Diff->DiffTRFiles_select_attrs to Ctrl+equal menu Choose attributes to compare
#bind find_next_difference_in_file to Alt+space menu Goto next difference in file
#bind TR_Diff->clear_diff_attrs to Alt+- menu Clear TRDiff attributes

sub find_next_difference_in_file {
  local $TR_Diff::compare_all = 1;
  TR_Diff->find_next_difference_in_file;
}


sub DiffTRFiles {
  local $TR_Diff::compare_all = 1;
  TR_Diff->DiffTRFiles;
}

sub DiffWholeTRFiles {
  local $TR_Diff::compare_all = 1;
  TR_Diff->DiffWholeTRFiles;
}

sub DiffTRFiles_with_summary {
  local $TR_Diff::compare_all = 1;
  TR_Diff->DiffTRFiles_with_summary;
}

############# XPath #############
sub TRXPath {
  return if $TRXPath;
  SetupXPath(name => sub { $_[0]->{func} },
	     value => sub { $_[0]->{trlemma} },
	     @_);
  $TRXPath = 1;
}

sub findnodes {
  my ($exp, $node, @defs)=@_;
  $node ||= $this;
  TRXPath(@defs);
  $node->findnodes($exp);
}

sub findvalue {
  my ($exp, $node, @defs)=@_;
  $node ||= $this;
  TRXPath(@defs);
  $node->findvalue($exp);
}

############################################

