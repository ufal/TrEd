package TrEd::Basics;

BEGIN {
  use Fslib;
  require TrEd::MinMax;
  import TrEd::MinMax;
  import TrEd::MinMax qw(first);

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
  );
  use strict;
  use PMLSchema;
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
  $t=Fslib::DeleteLeaf($node);
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

sub chooseNodeType {
  my ($fsfile,$node,$opts)=@_;
  my $type = $node->type;
  return $type if $type;
  my $ntype;
  my @ntypes;
  if ($node->parent) {
    # is parent's type known?
    my $parent_decl = $node->parent->type;
    if (ref($parent_decl)) {
      # ok, find #CHILDNODES
      my $parent_decl_type = $parent_decl->get_decl_type;
      my $member_decl;
      if ($parent_decl_type == PML_STRUCTURE_DECL()) {
	($member_decl) = map { $_->get_content_decl } 
	  $parent_decl->find_members_by_role('#CHILDNODES');
      } elsif ($parent_decl_type == PML_CONTAINER_DECL()) {
	$member_decl = $parent_decl->get_content_decl;
	undef $member_decl unless $member_decl and $member_decl->get_role eq '#CHILDNODES';
      }
      if ($member_decl) {
	my $member_decl_type = $member_decl->get_decl_type;
	if ($member_decl_type == PML_LIST_DECL()) {
	  $ntype = $member_decl->get_content_decl;
	  undef $ntype unless $ntype and $ntype->get_role eq '#NODE';
	} elsif ($member_decl_type == PML_SEQUENCE_DECL()) {
	  my $elements = 
	  @ntypes = grep { $_->[1]->get_role eq '#NODE' }
	    map { [ $_->get_name, $_->get_content_decl ] }
	      $member_decl->get_elements;
	  if (defined $node->{'#name'}) {
	    $ntype = first { $_->[0] eq $node->{'#name'} } @ntypes;
	    $ntype=$ntype->[1] if $ntype;
	  }
	} else {
	  die "I'm confused - found role #CHILDNODES on a ".$member_decl->get_decl_type_str().", which is neither a list nor a sequence...\n".
	    Dumper($member_decl);
	}
      }
    } else {
      # ask the user to set the type of the parent first
      die("Parent node type is unknown.\nYou must assign node-type to the parent node first!");
      return;
    }
  } else {
    # find #TREES sequence representing the tree list
    my @tree_types;
    my $pml_trees_type = $fsfile->metaData('pml_trees_type');
    if (ref $pml_trees_type) {
      @tree_types = ($pml_trees_type);
    } else {
      my $schema = fileSchema($fsfile);
      @tree_types = $schema->find_types_by_role('#TREES');
    }
    foreach my $tt (map { $_->get_content_decl } @tree_types) {
      if (!ref($tt)) {
	die("I'm confused - found role #TREES on something which is neither a list nor a sequence...\n".
	  Dumper($tt));
      } elsif ($tt->get_decl_type == PML_LIST_DECL()) {
	$ntype = $tt->get_content_decl;
	undef $ntype unless $ntype and $ntype->get_role eq '#NODE';
      } elsif ($tt->get_decl_type == PML_SEQUENCE_DECL()) {
	my $elements = 
	  @ntypes = grep { $_->[1]->get_role eq '#NODE' }
	    map { [ $_->get_name, $_->get_content_decl ] }
	    $tt->get_elements;
	  if (defined $node->{'#name'}) {
	    $ntype = first { $_->[0] eq $node->{'#name'} } @ntypes;
	    $ntype=$ntype->[1] if $ntype;
	  }
      } else {
	die ("I'm confused - found role #CHILDNODES on something which is neither a list nor a sequence...\n".
	  Dumper($tt));
      }
    }
  }
  my $base_type;
  if ($ntype) {
    $base_type = $ntype;
    $node->set_type($base_type);
  } elsif (@ntypes == 1) {
    $node->{'#name'} = $ntypes[0][0];
    $base_type = $ntypes[0][1];
    $node->set_type($base_type);
  } elsif (@ntypes > 1) {
    my $i = 1;
    if (ref($opts) and $opts->{choose_command}) {
      my $type = $opts->{choose_command}->($fsfile,$node,[@ntypes]);
      if ($type and first { $_==$type } @ntypes) {
	$node->set_type($type->[1]);
	$node->{'#name'} = $type->[0];
	$base_type=$node->type;
      } else {
	return;
      }
    }
  } else {
    die("Cannot determine node type: schema does not allow nodes on this level...\n");
    return;
  }
  return $node->type;
}



1;

