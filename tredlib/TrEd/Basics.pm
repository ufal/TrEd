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
    &absolutize
    &absolutize_path
    &uniq
  );
  use strict;
}

sub uniq { my %a; grep { !($a{$_}++) } @_ }


# different namespace only to load local rather than system files
# (rel2abs is not supported in all instalations)
use File::Spec;
if (not File::Spec->can('rel2abs')) {
  die "The currently installed version of the File::Spec module doesn't provide rel2abs() method. Please upgrade it!\n";
} else {
  require File::Spec::Functions;
  import File::Spec::Functions qw(rel2abs);
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
  &$on_tree_change($win,'gotoTree',$no) if $on_tree_change;
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
  &$on_tree_change($win,'newTree',$win->{root}) if $on_tree_change;
  return 1;
}

sub newTreeAfter {
  my ($win)=@_;

#  my $nr=FSNode->new(); # blessing new root
#  splice(@{$win->{FSFile}->treeList}, ++$win->{treeNo}, 0, $nr);
#  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{root}=$win->{FSFile}->new_tree(++$win->{treeNo});
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'newTreeAfter',$win->{root}) if $on_tree_change;
  return 1;
}

sub pruneTree {
  my ($win)=@_;

  return unless ($win->{FSFile} and $win->{FSFile}->treeList->[$win->{treeNo}]);
  $win->{root}=undef;
#  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
#  splice(@{$win->{FSFile}->treeList}, $win->{treeNo}, 1);
#  DeleteTree($win->{root});
  my $no = $win->{treeNo};
  $win->{FSFile}->destroy_tree($win->{treeNo});
  $win->{treeNo}=max(0,min($win->{treeNo},$win->{FSFile}->lastTreeNo));
  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'pruneTree',$win->{treeNo}) if $on_tree_change;
  return 1;
}

sub newNode {
  ## Adds new son to current node
  my ($win)=@_;
  my $parent=$win->{currentNode};
  return unless ($win->{FSFile} and $parent);

  my $nd=$parent->new();
  Fslib::Paste($nd,$parent,$win->{FSFile}->FS);
  my $order = $win->{FSFile}->FS->order;
  if ($order) {
    $nd->set_member($order,$parent->get_member($order));
  }
  setCurrent($win,$nd);
  $win->{FSFile}->notSaved(1);
  &$on_node_change($win,'newNode',$nd) if $on_node_change;

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
  &$on_node_change($win,'newTree',$t) if $on_node_change;
  return $t;
}

sub setCurrent {
  my ($win,$node)=@_;
  my $prev=$win->{currentNode};
  $win->{currentNode}=$node;
  &$on_current_change($win,$node,$prev,'setCurrent') if $on_current_change;
}

sub _messageBox {
  my ($top,$title,$msg,$nobug)=@_;
  require Tk::ErrorReport;
  $top->ErrorReport(
    -title   => $title,
    -msgtype => ($nobug eq 'warn' ? "WARNING" : "ERROR"),
    -message => ($nobug eq 'warn' ? "Operation produced warnings - full message follows.\n" 
      : $nobug ? "Operation failed - full error message follows.\n"
      : "An error occured during a protected transaction.\n".
	"If you believe that it was caused by a bug in TrEd, you may wish to\n".
	"copy the error message displayed below and report it to the author."),
    -body => $msg,
  );
}

sub errorMessage {
  my ($win,$msg,$nobug)=@_;
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
      _messageBox($top,'Error',$msg,$nobug);
    } else {
      print STDERR "$msg\n";
    }
  }
}

sub absolutize_path {
  &Fslib::ResolvePath;
}

sub absolutize {
  return map { m(^[[:alnum:]]+:/|^\s*\||^\s*/) ? $_ : rel2abs($_) } grep { !/^\s*$/ } @_;
}


1;

