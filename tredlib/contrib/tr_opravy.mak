## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2003-10-29 11:08:04 pajas>


package TR_Correction;
@ISA=qw(Tectogrammatic);
import Tectogrammatic;

# permitting all attributes modification
sub enable_attr_hook {
  return;
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

sub hash_AIDs {
  my %aids;
  my $node=ref($_[0]) ? $_[0] : $root;
  while ($node) {
    $aids{$node->{AID}} = $node;
    $node=$node->following;
  }
  return \%aids;
}

sub uniq { my %a; @a{@_}=@_; values %a }


#bind clean_fw_join_to_parent to Ctrl+exclam
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

#bind clean_fw_AIDREFS to Ctrl+at
sub clean_fw_AIDREFS {
  shift if @_ and not ref($_[0]);
  my $node = $_[0] || $this;
  $node->{fw}='';
  $node->{AIDREFS}='';
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

#bind SwapNodes to Ctrl+9
sub SwapNodes {
  Analytic_Correction::SwapNodes;
}

#bind UnhideNode to Ctrl+H
sub UnhideNode {
  shift if $_[0] and !ref($_[0]);
  my $node = $_[0] || $this;
  while ($node) {
    $node->{TR}='' if $node->{TR} eq 'hide';
    $node=$node->parent;
  }
}

#bind AssignTrLemma to Ctrl+L
sub AssignTrLemma {
  my $lemma = $this->{lemma};
  $lemma =~ s/[-_`&].*$//;
  $this->{trlemma}=$lemma;
}
