package TrEd::Basics;

BEGIN {
  use Treex::PML;
  require TrEd::MinMax;
  import TrEd::MinMax;
  import TrEd::MinMax qw(first);
  use UNIVERSAL::DOES;

  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK
	      $on_tree_change
	      $on_node_change
	      $on_current_change
	      $on_error
	    );
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
    &moveTree
    &makeRoot
    &newNode
    &pruneNode
    &setCurrent
    &errorMessage
    &absolutize
    &absolutize_path
    &uniq
    &chooseNodeType
    &fileSchema
    &getSecondaryFiles
    &getSecondaryFilesRecursively
    &getPrimaryFiles
    &getPrimaryFilesRecursively
  );
  use Treex::PML::Schema;
}

use strict;
use warnings;
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
# FSFile       => reference of the current Treex::PML::Document
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
  my $fsfile = $win->{FSFile};
  $win->{treeNo}=0 if $fsfile->lastTreeNo<0;
  $win->{root}=$fsfile->new_tree($win->{treeNo});
  $fsfile->notSaved(1);
  &$on_tree_change($win,'newTree',$win->{root}) if $on_tree_change;
  return 1;
}

sub newTreeAfter {
  my ($win)=@_;
  my $fsfile = $win->{FSFile};
  my $no = $win->{treeNo} = max(0,min($win->{treeNo},$fsfile->lastTreeNo)+1);
  $win->{root}=$fsfile->new_tree($no);
  $fsfile->notSaved(1);
  &$on_tree_change($win,'newTreeAfter',$win->{root}) if $on_tree_change;
  return 1;
}

sub pruneTree {
  my ($win)=@_;
  my $fsfile = $win->{FSFile};
  return unless ($fsfile and $fsfile->treeList->[$win->{treeNo}]);
  $win->{root}=undef;
#  $win->{root}=$fsfile->treeList->[$win->{treeNo}];
#  splice(@{$fsfile->treeList}, $win->{treeNo}, 1);
#  DeleteTree($win->{root});
  my $no = $win->{treeNo};
  $fsfile->destroy_tree($win->{treeNo});
  $win->{treeNo}=max(0,min($win->{treeNo},$fsfile->lastTreeNo));
  $win->{root}=$fsfile->treeList->[$win->{treeNo}];
  $fsfile->notSaved(1);
  &$on_tree_change($win,'pruneTree',$win->{treeNo}) if $on_tree_change;
  return 1;
}

sub moveTree {
  my ($win,$delta)= @_;
  my $fsfile = $win->{FSFile};
  return unless $fsfile;
  my $no = $win->{treeNo};
  $fsfile->move_tree_to($no,$no+$delta) || return;
  $win->{treeNo}=$no+$delta;
  $win->{root}=$win->{FSFile}->treeList->[$win->{treeNo}];
  $win->{FSFile}->notSaved(1);
  &$on_tree_change($win,'moveTree',$win->{treeNo}) if $on_tree_change;
  return 1;
}

sub makeRoot {
  my ($win,$node,$discard)= @_;
  my $fsfile = $win->{FSFile};
  return unless $fsfile and $node;
  my $no = $win->{treeNo};
  my $root = $fsfile->treeList->[$no];
  if ($root!=$node->root) {
    return;
  }
  $node->cut;
  $fsfile->treeList->[$no]=$node;
  $root->paste_on($node,$fsfile->FS->order) unless $discard;
  $win->{FSFile}->notSaved(1);
  &$on_node_change($win,'makeRoot',$node) if $on_tree_change;
  return 1;
}

sub newNode {
  ## Adds new son to current node
  my ($win)=@_;
  my $parent=$win->{currentNode};
  return unless ($win->{FSFile} and $parent);

  my $nd=$parent->new();
  $nd->paste_on($parent,$win->{FSFile}->FS);
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

  $t->cut()->paste_on($node->parent,$win->{FSFile}->FS) while ($t=$node->firstson);

  setCurrent($win,$node->parent) if ($node == $win->{currentNode});
  $t=$node->destroy_leaf();
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
  $nobug||='';
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
    } elsif (ref($win) eq 'MainWindow') {
      $top = $win;
    } elsif (exists($win->{framegroup}) and
              ref($win->{framegroup}) and
              exists($win->{framegroup}{top}) and
              ref($win->{framegroup}{top})) {
      $top = $win->{framegroup}->{top}->toplevel;
    }
    
    if ($top) {
      # report the error from the highest displayed toplevel window in stacking order
      my ($highest) = reverse $top->stackorder();
      $top = $top->Widget($highest);
      _messageBox($top,'Error',$msg,$nobug);
    } else {
      print STDERR "$msg\n";
    }
  }
}

sub absolutize_path {
  &Treex::PML::ResolvePath;
}

sub absolutize {
  return map { m(^[[:alnum:]]+:/|^\s*\||^\s*/) ? $_ : rel2abs($_) } grep { !/^\s*$/ } @_;
}

sub fileSchema {
  my ($fsfile)=@_;
  return $fsfile->metaData('schema');
}

sub getSecondaryFiles {
  my ($fsfile)=@_;
  my $requires = $fsfile->metaData('fs-require');
  my @secondary;
  if ($requires) {
    foreach my $req (@$requires) {
      my $req_fs = ref($fsfile->appData('ref')) ? $fsfile->appData('ref')->{$req->[0]} : undef;
      if (UNIVERSAL::DOES::does($req_fs,'Treex::PML::Document')) {
	push @secondary,$req_fs;
      }
    }
  }
  return uniq @secondary;
}

sub getSecondaryFilesRecursively {
  my ($fsfile)=@_;
  my @secondary = getSecondaryFiles($fsfile);
  my %seen;
  my $i=0;
  while ($i<@secondary) {
    my $sec = $secondary[$i];
    if (!exists($seen{$sec})) {
      $seen{$sec}=1;
      push @secondary, getSecondaryFiles($sec);
    }
    $i++;
  }
  return uniq @secondary;
}

sub getPrimaryFiles {
  my ($fsfile)=@_;
  return @{ $fsfile->appData('fs-part-of') || [] };
}

sub getPrimaryFilesRecursively {
  my ($fsfile)=@_;
  my @primary = getPrimaryFiles($fsfile);
  my %seen;
  my $i=0;
  while ($i<@primary) {
    my $prim = $primary[$i];
    if (!exists($seen{$prim})) {
      $seen{$prim}=1;
      push @primary, getPrimaryFiles($prim);
    }
    $i++;
  }
  return uniq @primary;
}


1;

