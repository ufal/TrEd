package TrEd::Basics;

BEGIN {
  use Fslib;
  require TrEd::MinMax;
  import TrEd::MinMax;

  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    $on_tree_change
    $on_node_change
    $on_current_change
    $on_error
    &gotoTree
    &nextTree
    &prevTree
    &newTree
    &newTreeAfter
    &pruneTree
    &newNode
    &pruneNode
    &setCurrent
    &errorMessage
  );
  use strict;
}


#
# The $win parameter to the following two routines should be
# a hash reference, having at least the following keys:
#
# FSFile       => FSFile blessed reference of the current FSFile
# treeNo       => number of the current tree in the file
# macroContext => current context under which macros are run 
# currentNode  => pointer to the current node 
# root         => pointer to the root node of current tree
#

sub gotoTree {
  my $win=shift;
  return unless $win->{FSFile};
  my $no = max(0,min(shift,$win->{FSFile}->lastTreeNo));
  return $no if ($no == $win->{treeNo});
  $win->{treeNo}=$no;
  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  &$on_tree_change($win,'gotoTree') if $on_tree_change;
  return $no;
}

sub nextTree {
  my ($win)=@_;
  return 0 if ($win->{treeNo} >= $win->{FSFile}->lastTreeNo);
  gotoTree($win,$win->{treeNo}+1);
  return 1;
}

sub prevTree {
  my ($win)=@_;
  return 0 if ($win->{treeNo} <= 0);
  gotoTree($win,$win->{treeNo}-1);
  return 1;
}

sub newTree {
  my ($win)=@_;

#  my $nr=FSNode->new(); # blessing new root
#  splice(@{$win->{FSFile}->treeList}, $win->{treeNo}, 0, $nr);
#  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{root}=$win->{FSFile}->new_tree($win->{treeNo});
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'newTree') if $on_tree_change;
  return 1;
}

sub newTreeAfter {
  my ($win)=@_;

#  my $nr=FSNode->new(); # blessing new root
#  splice(@{$win->{FSFile}->treeList}, ++$win->{treeNo}, 0, $nr);
#  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{root}=$win->{FSFile}->new_tree(++$win->{treeNo});
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'newTreeAfter') if $on_tree_change;
  return 1;
}

sub pruneTree {
  my ($win)=@_;

  return unless ($win->{FSFile} and $win->{FSFile}->treeList->[$win->{treeNo}]);
  $win->{root}=undef;
#  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
#  splice(@{$win->{FSFile}->treeList}, $win->{treeNo}, 1);
#  DeleteTree($win->{root});
  $win->{FSFile}->destroy_tree($win->{treeNo});
  $win->{treeNo}=max(0,min($win->{treeNo},$win->{FSFile}->lastTreeNo));
  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'pruneTree') if $on_tree_change;
  return 1;
}


sub newNode {
  ## Adds new son to current node
  my ($win)=@_;
  my $parent=$win->{currentNode};
  return unless ($win->{FSFile} and $parent);

  my $nd=$parent->new();
  my $ord=$win->{FSFile}->FS->order;
  Fslib::Paste($nd,$parent,$win->{FSFile}->FS);
  $nd->setAttribute($order,$parent->getAttribute($order));

  setCurrent($win,$nd);
  $win->{FSFile}->notSaved(1);
  &$on_node_change($win,'newNode') if $on_node_change;

  return $nd;
}

sub pruneNode {
  ## Deletes given node
  my ($win,$node)=@_;
  my $t;
  return undef unless ($win->{FSFile} and $node and $node->parent);

  Fslib::Paste(Cut($t),$node->parent,$win->{FSFile}->FS)
    while ($t=$node->firstson);

  setCurrent($win,$node->parent) if ($node == $win->{currentNode});
  $t=DeleteLeaf($node);
  $win->{FSFile}->notSaved(1);
  &$on_node_change($win,'newTree') if $on_node_change;
  return $t;
}

sub setCurrent {
  my ($win,$node)=@_;
  my $prev=$win->{currentNode};
  $win->{currentNode}=$node;
  &$on_current_change($win,$node,$prev,'setCurrent') if $on_current_change;
}

sub _messageBox {
  my ($top,$title,$msg)=@_;
  my $d= $top->DialogBox(-title=> $title,
		      -buttons=> ['OK']);
  $d->Label(-text => "ERROR",
	    -justify => 'left',
	    -foreground => 'red'
	   )
    ->pack(-pady => 5,-side => 'top', -fill => 'x');
  $d->Label(-text => 
	      "An error occured during a protected transaction.\n".
	      "You may wish to copy the error message displayed below and report it to the author.",
	    -justify => 'left'
	   )->pack(-pady => 10,-side => 'top', -fill => 'x');
  my $t= $d->
    Scrolled(qw/Text -relief sunken -borderwidth 2
		-scrollbars oe/);
  $t->Subwidget('scrolled')->menu->delete('File');
  $t->pack(qw/-side top -expand yes -fill both/);
#  disable_scrollbar_focus($t);
  $t->BindMouseWheelVert();
  $t->insert('0.0',$msg);
  $d->Show;
}

sub errorMessage {
  my ($win,$msg)=@_;
  if ($on_error) {
    &$on_error(@_);
  } else {
    my $top;
    if (ref($win)=~/^Tk::/) {
      $top = $win->toplevel;
    } elsif (exists($win->{framegroup}) and
	ref($win->{framegroup}) and
      exists($win->{framegroup}{top}) and
	ref($win->{framegroup}{top})) {
      $top = $win->{framegroup}->{top}->toplevel;
    }
    if ($top) {
      _messageBox($top,'Error',$msg);
      #       $top->messageBox(-icon=> 'error',
      # 		       -message=> $msg,
      # 		       -title=> 'Error', -type=> 'ok');
    } else {
      print STDERR "$msg\n";
    }
  }
}
1;

