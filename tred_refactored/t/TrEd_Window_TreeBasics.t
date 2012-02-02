#!/usr/bin/env perl
# tests for TrEd::Window::TreeBasics

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

use Test::More;
use Test::Exception;
use Data::Dumper;
use Treex::PML qw{ImportBackends};
use File::Spec;
use Cwd;

#use TrEd::Config;
#use TrEd::Utils;

BEGIN {
  our $module_name = 'TrEd::Window::TreeBasics';
  our @subs = qw(
    go_to_tree
    next_tree
    prev_tree
    new_tree
    new_tree_after
    prune_tree
    move_tree
    make_root
    new_node
    prune_node
    set_current
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
our $module_name;
can_ok($module_name, @subs);

my @backends=(
  'FS',
  ImportBackends(
    qw{NTRED
       Storable
       PML
       CSTS
       TrXML
       TEIXML
       PMLTransform
      })
);



### Initialize documents and load related documents recursively 
sub _init_fsfile {
  my ($file_name) = @_;
  my $bck = \@backends;
  my $fsfile = Treex::PML::Factory->createDocumentFromFile(
    $file_name,
    {
      encoding => 'utf8',
      backends => $bck,
      recover => 1,
    });
  $fsfile->loadRelatedDocuments(1,sub {});
    # warning: this can be a looong Dump!
#    print Dumper($fsfile);
  return $fsfile;
}

### test fn go_to_tree()
sub test_go_to_tree {
  my ($fsfile) = @_;
  my $win_ref = {
   treeNo => 0,
   FSFile => undef,
   macroContext =>  'TredMacro',
   currentNode => undef,
   root => undef
  };
  
  is(TrEd::Window::TreeBasics::go_to_tree($win_ref), undef, 
    "go_to_tree(): return undef if FSFile is not defined");
  
  $win_ref = {
   treeNo => 128,
   FSFile => $fsfile,
   macroContext =>  'TredMacro',
   currentNode => $fsfile->currentNode(),
   root => undef
  };
  
  ## Try negative tree number
  is(TrEd::Window::TreeBasics::go_to_tree($win_ref, -1), 0,
    "go_to_tree(): negative tree number -- return 0");
  is($win_ref->{treeNo}, 0,
    "go_to_tree(): set win_ref->{treeNo} if the position changes");
  is($win_ref->{root}->attr('nodetype'), 'root',
    "go_to_tree(): win_ref->{root} is really a root node of the tree");
  is($win_ref->{root}->attr('id'), 't-ln94210-2-p1s1',
    "go_to_tree(): win_ref->{root}'s id is correct -- first root");  
  
  ## No effect when not changing tree number
  $win_ref->{treeNo} = 0;
  $win_ref->{root} = undef;
  TrEd::Window::TreeBasics::go_to_tree($win_ref, -1);
  is($win_ref->{treeNo}, 0,
    "go_to_tree(): do not modify win_ref->{treeNo}, if the position does not change");
  is($win_ref->{root}, undef, 
    "go_to_tree(): do not modify win_ref->{root}, if the position does not change");
  
  ## Tree number bigger than number of trees in file
  is(TrEd::Window::TreeBasics::go_to_tree($win_ref, 55), 53,
    "go_to_tree(): tree number bigger than the number of trees -- return number of trees");
  is($win_ref->{treeNo}, 53,
    "go_to_tree(): set win_ref->{treeNo} to last tree if the position is larger than number of trees in file");
  is($win_ref->{root}->attr('nodetype'), 'root',
    "go_to_tree(): win_ref->{root} is really a root node of the tree");
  is($win_ref->{root}->attr('id'), 't-ln94208-140-p2s4',
    "go_to_tree(): win_ref->{root}'s id is correct -- last root");  
    
  ## Test that callback was called
  is($win_ref->{msg}, "Changed tree ".$win_ref->{treeNo}." by go_to_tree", 
    "go_to_tree(): callback called");
}


#sub _tree_id_is {
#  my ($tree, $expected_id, $perform_test, $message) = @_;
#  if($perform_test){
#    is($tree->root()->attr('id'), $expected_id, $message);
#  } 
#  else {
#    if($tree->root()->attr('id') eq $expected_id){
#      return 1;
#    } 
#    else {
#      return 0;
#    }
#  }
#}

#sub _test_win_ref {
#  my ($arg_ref) = @_;
#  my $win_ref           = $arg_ref->{win_ref};
#  my $fn_ref            = $arg_ref->{fn_ref};
#  my $expected_win_ref  = $arg_ref->{expected_win_ref};
#  my $expected_val      = $arg_ref->{expected_val};
#  my $msg1              = $arg_ref->{msg1};
#  my $msg2              = $arg_ref->{msg2};
#  
#  is($fn_ref->($win_ref), $expected_val,
#    $msg1);
#  is_deeply($win_ref, $expected_win_ref, 
#    $msg2);
#
## toto je asi este horsie zrozumitelne...
##  _test_win_ref({
##    fn_ref            => \&TrEd::Window::TreeBasics::next_tree,
##    win_ref           => $win_ref,
##    expected_val      => 0,
##    msg1              => "next_tree(): return 0 if there is no next tree",
##    expected_win_ref  => $expected_win_ref,
##    msg2              => "next_tree() does not modify win_ref if there is no next tree",
##  });
#  
#}

sub test_next_tree {
  my ($fsfile) = @_;
  my $win_ref = {
   treeNo         => 128,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  my $expected_win_ref = {
    treeNo        => $win_ref->{treeNo},
    FSFile        => $win_ref->{FSFile},
    macroContext  => $win_ref->{macroContext},
    currentNode   => $win_ref->{currentNode},
    root          => $win_ref->{root},
  };
  
  is(TrEd::Window::TreeBasics::next_tree($win_ref), 0,
    "next_tree(): return 0 if there is no next tree");
  is_deeply($win_ref, $expected_win_ref, 
    "next_tree() does not modify win_ref if there is no next tree");
  
  
  my $first_tree = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  $win_ref = {
   treeNo       => 0,
   FSFile       => $fsfile,
   macroContext => 'TredMacro',
   currentNode  => $first_tree,
   root         => $first_tree,
  };
  $expected_win_ref = {
    treeNo        => 1,
    FSFile        => $win_ref->{FSFile},
    macroContext  => $win_ref->{macroContext},
    currentNode   => $win_ref->{currentNode}, # should not change
    root          => $second_tree,
    msg           => "Changed tree 1 by go_to_tree",
  };
  is(TrEd::Window::TreeBasics::next_tree($win_ref), 1,
    "next_tree(): return 1 if there is some next tree");
  is_deeply($win_ref, $expected_win_ref, 
    "next_tree() set root and treeNo correctly");
}
 
sub test_prev_tree {
  my ($fsfile) = @_;
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  my $expected_win_ref = {
    treeNo        => $win_ref->{treeNo},
    FSFile        => $win_ref->{FSFile},
    macroContext  => $win_ref->{macroContext},
    currentNode   => $win_ref->{currentNode},
    root          => $win_ref->{root},
  };
  
  is(TrEd::Window::TreeBasics::prev_tree($win_ref), 0,
    "prev_tree(): return 0 if there is no previous tree");
  is_deeply($win_ref, $expected_win_ref, 
    "prev_tree() does not modify win_ref if there is no next tree");
  
  
  my $first_tree = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  $win_ref = {
   treeNo       => 1,
   FSFile       => $fsfile,
   macroContext => 'TredMacro',
   currentNode  => $second_tree,
   root         => $second_tree,
  };
  $expected_win_ref = {
    treeNo        => 0,
    FSFile        => $win_ref->{FSFile},
    macroContext  => $win_ref->{macroContext},
    currentNode   => $win_ref->{currentNode}, # should not change
    root          => $first_tree,
        msg           => "Changed tree 0 by go_to_tree",
  };
  is(TrEd::Window::TreeBasics::prev_tree($win_ref), 1,
    "prev_tree(): return 1 if there is some previous tree");
  is_deeply($win_ref, $expected_win_ref, 
    "prev_tree() set root and treeNo correctly");
}

sub test_new_tree {
  my ($fsfile) = @_;
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  
  my $first_tree = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
#  print Dumper($fsfile->treeList());
  is(TrEd::Window::TreeBasics::new_tree($win_ref), 1,
    "new_tree(): return value");
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  
  is($win_ref->{root}, $now_first_tree, 
    "new_tree(): win_ref->root contains new tree which becomes the first tree in file");
  
  is($first_tree, $now_second_tree, 
    "new_tree(): move first tree to the second position");
  
  is($second_tree, $now_third_tree, 
    "new_tree(): move second tree to the third position");
  
  is($fsfile->notSaved(), 1, 
    "new_tree(): Treex::PML::Document::notSaved set to 1");
    
  is($win_ref->{msg}, "Changed tree no-id-tree by new_tree", 
    "new_tree(): callback called");
    
  # notSaved to default position
  $fsfile->notSaved(0);
  
  ########################
  #### FSFile undef  #####
  ########################
  $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  
  is(TrEd::Window::TreeBasics::new_tree($win_ref), undef, 
    "new_tree(): return undef if fsfile is not defined");
  
  ## Try position out of bounds of the loaded file
  $win_ref = {
   treeNo         => 120,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::new_tree($win_ref), 1,
    "new_tree(): return value when out of bounds");
    
  is($win_ref->{root}, $fsfile->tree($fsfile->lastTreeNo()), 
    "new_tree(): if the position is after the end of file, add after last position");
  
}

sub _test_new_tree_after_undef {
  ########################
  #### FSFile undef  #####
  ########################
  my $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  
  is(TrEd::Window::TreeBasics::new_tree_after($win_ref), undef, 
    "new_tree_after(): return undef if fsfile is not defined");
}

sub _test_new_tree_after_in_bounds {
  my ($fsfile) = @_;
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $last_tree = $fsfile->tree($no_of_trees);
  
#  print Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => $no_of_trees,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef,
   root           => $last_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::new_tree_after($win_ref), 1,
    "new_tree_after(): return value");
  
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_no_of_trees = $fsfile->lastTreeNo();
  my $now_last_tree = $fsfile->tree($now_no_of_trees);
  my $now_bef_last_tree = $fsfile->tree($now_no_of_trees - 1);

  
  is($win_ref->{root}, $now_last_tree, 
    "new_tree_after(): win_ref->root contains new tree which becomes the last tree in file");
  
  is($last_tree, $now_bef_last_tree, 
    "new_tree_after(): last tree becomes the one before the last one");
  
  is($win_ref->{msg}, "Changed tree no-id-tree by new_tree_after", 
    "new_tree_after(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "new_tree_after(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_new_tree_after_after_eof {
  my ($fsfile) = @_;
  note("new_tree_after: adding after the end of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $last_tree = $fsfile->tree($no_of_trees);
  
#  print Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => $no_of_trees + 3,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef,
   root           => $last_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::new_tree_after($win_ref), 1,
    "new_tree_after(): return value");
  
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_no_of_trees = $fsfile->lastTreeNo();
  my $now_last_tree = $fsfile->tree($now_no_of_trees);
  my $now_bef_last_tree = $fsfile->tree($now_no_of_trees - 1);

  
  is($win_ref->{root}, $now_last_tree, 
    "new_tree_after(): win_ref->root contains new tree which becomes the last tree in file");
  
  is($last_tree, $now_bef_last_tree, 
    "new_tree_after(): last tree becomes the one before the last one");
  
  is($win_ref->{msg}, "Changed tree no-id-tree by new_tree_after", 
    "new_tree_after(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "new_tree_after(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_new_tree_after_before_bof {
  my ($fsfile) = @_;
  note("new_tree_after: adding before the beginning of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $first_tree = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  
  
  my $win_ref = {
   treeNo         => -5,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef,
   root           => $first_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::new_tree_after($win_ref), 1,
    "new_tree_after(): return value");
  
  ################
  #### After  ####
  ################
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  
  is($win_ref->{root}, $now_first_tree, 
    "new_tree_after(): win_ref->root contains new tree which becomes the first tree in file");
  
  is($first_tree, $now_second_tree, 
    "new_tree_after(): first tree becomes the second one");
  
  is($second_tree, $now_third_tree, 
    "new_tree_after(): 2nd tree becomes the 3rd one");
  
  is($win_ref->{msg}, "Changed tree no-id-tree by new_tree_after", 
    "new_tree_after(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "new_tree_after(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_new_tree_after {
  my ($fsfile) = @_;
  _test_new_tree_after_in_bounds($fsfile);
  _test_new_tree_after_after_eof($fsfile);
  _test_new_tree_after_before_bof($fsfile);
  _test_new_tree_after_undef();
}


sub _test_prune_tree_first {
  my ($fsfile) = @_;
  note("prune_tree: removing from the beginning of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $first_tree  = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  my $third_tree  = $fsfile->tree(2);
  my $fourth_tree = $fsfile->tree(3);
  
#  print "before prune_tree: " . Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::prune_tree($win_ref), 1,
    "prune_tree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after prune_tree" . Dumper($fsfile->treeList());
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  my $now_fourth_tree = $fsfile->tree(3);
  
  is($win_ref->{root}, $second_tree, 
    "prune_tree(): win_ref->root contains second tree");
  
  is($third_tree, $now_second_tree, 
    "prune_tree(): second tree moved to the first position");
  
  is($fourth_tree, $now_third_tree, 
    "prune_tree(): 4th tree moved to the 3rd position");
    
  is($win_ref->{msg}, "Changed tree 0 by prune_tree", 
    "prune_tree(): callback called");
    
  is($fsfile->notSaved(), 1, 
    "prune_tree(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_prune_tree_last {
  my ($fsfile) = @_;
  ########################
  #### Remove from end ###
  ########################
  note("prune_tree: removing from the end of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $last_tree  = $fsfile->tree($no_of_trees);
  my $before_last_tree = $fsfile->tree($no_of_trees - 1);
  
#  print "before last prune_tree: " . Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => $no_of_trees,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $last_tree->root(),
  };
  
  is(TrEd::Window::TreeBasics::prune_tree($win_ref), 1,
    "prune_tree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after prune_tree" . Dumper($fsfile->treeList());
  $no_of_trees = $fsfile->lastTreeNo();
  
  my $now_last_tree = $fsfile->tree($no_of_trees);
  
  is($win_ref->{root}, $now_last_tree, 
    "prune_tree(): win_ref->root contains the new last tree");
  
  is($before_last_tree, $now_last_tree, 
    "prune_tree(): last tree is removed, the one before the last one becomes the last one");
  
  is($win_ref->{msg}, "Changed tree $no_of_trees by prune_tree", 
    "prune_tree(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "prune_tree(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_prune_tree_negative {
  my ($fsfile) = @_;
  ############################
  #### Remove with - index ###
  ############################
  note("prune_tree: negative index");
  ################
  #### Before ####
  ################
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $last_tree  = $fsfile->tree($no_of_trees);
  my $before_last_tree = $fsfile->tree($no_of_trees - 1);
  my $win_ref = {
   treeNo         => -1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $last_tree->root(),
  };
  
#  print "b4 prune_tree" . Dumper($fsfile->treeList());
  is(TrEd::Window::TreeBasics::prune_tree($win_ref), 1, 
    "prune_tree(): return value, negative index");
  
  ################
  #### After  ####
  ################
#  print "after prune_tree" . Dumper($fsfile->treeList());
  $no_of_trees = $fsfile->lastTreeNo();

  my $now_last_tree = $fsfile->tree($no_of_trees);

  is($win_ref->{root}, $fsfile->tree(0), 
    "prune_tree(): negative index: win_ref->root contains the first tree");
  
  is($before_last_tree, $now_last_tree, 
    "prune_tree(): negative index: last tree is removed, the one before the last one becomes the last one");
  
  is($win_ref->{msg}, "Changed tree 0 by prune_tree", 
    "prune_tree(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "prune_tree(): negative index: Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_prune_tree_undef {
  my ($fsfile) = @_;
  ########################
  #### FSFile undef  #####
  ########################
  my $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  
  is(TrEd::Window::TreeBasics::prune_tree($win_ref), undef, 
    "prune_tree(): return undef if fsfile is not defined");
  
  ## prune_tree after the end of file
  $win_ref->{treeNo} = $fsfile->lastTreeNo() + 1;  
  is(TrEd::Window::TreeBasics::prune_tree($win_ref), undef, 
    "prune_tree(): tree out of bounds: position after the end of file");

}

sub test_prune_tree {
  my ($fsfile) = @_;
  _test_prune_tree_first($fsfile);
  _test_prune_tree_undef($fsfile);
  _test_prune_tree_last($fsfile);
  _test_prune_tree_negative($fsfile);
}

sub _test_move_tree_out_of_bounds {
  my ($fsfile) = @_;
  note("move_tree: corner cases");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $first_tree  = $fsfile->tree(0);
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
  dies_ok(sub { TrEd::Window::TreeBasics::move_tree($win_ref, $no_of_trees + 1) }, "move_tree(): move existing tree after the file ending");
  dies_ok(sub { TrEd::Window::TreeBasics::move_tree($win_ref, -1) }, "move_tree(): move existing tree before the file beginning");
  
  $win_ref = {
   treeNo         => $no_of_trees + 1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  dies_ok(sub { TrEd::Window::TreeBasics::move_tree($win_ref, 0) }, "move_tree(): try to move tree with ordinal number greater than total number of trees in file");
  
  $win_ref = {
   treeNo         => -1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  dies_ok(sub { TrEd::Window::TreeBasics::move_tree($win_ref, 0) }, "move_tree(): try to move tree with ordinal number -1");
  
  $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  is(TrEd::Window::TreeBasics::move_tree($win_ref, 0), undef, 
    "move_tree(): delta is 0");
  
  $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  is(TrEd::Window::TreeBasics::move_tree($win_ref, 0), undef, 
    "move_tree(): fsfile not defined");
}

sub _test_move_tree {
  my ($fsfile) = @_;
  ##################
  #### Move tree ###
  ##################
  ################
  #### Before ####
  ################
  $fsfile->notSaved(0);
  
  my $first_tree  = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  my $third_tree  = $fsfile->tree(2);
  my $fourth_tree = $fsfile->tree(3);
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
#  print "b4 move_tree" . Dumper($fsfile->treeList());
  is(TrEd::Window::TreeBasics::move_tree($win_ref, 2), 1, 
    "move_tree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after move_tree" . Dumper($fsfile->treeList());
  my $now_first_tree  = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree  = $fsfile->tree(2);
  my $now_fourth_tree = $fsfile->tree(3);

  is($win_ref->{root}, $now_third_tree, 
    "move_tree(): win_ref->root contains moved tree");
  
  is($now_first_tree, $second_tree, 
    "move_tree(): second tree becomes the first one");
  
  is($now_second_tree, $third_tree, 
    "move_tree(): 3rd tree becomes the 2nd one");
  
  is($now_third_tree, $first_tree, 
    "move_tree(): 1st tree becomes the 3rd one");
  
  is($now_fourth_tree, $fourth_tree, 
    "move_tree(): 4th tree is still the 4th one");
  
  is($win_ref->{msg}, "Changed tree 2 by move_tree", 
    "move_tree(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "move_tree(): negative index: Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_move_tree {
  my ($fsfile) = @_;
  _test_move_tree($fsfile);
  _test_move_tree_out_of_bounds($fsfile);
}

sub _test_make_root_undef {
  my ($fsfile) = @_;
  ################
  #### Before ####
  ################
  my $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  
  # notSaved to default position
  $fsfile->notSaved(0);
  
  my $first_tree = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  my $node_in_second_tree = $second_tree->firstson();
  $node_in_second_tree = $node_in_second_tree->firstson();
  
  is(TrEd::Window::TreeBasics::make_root($win_ref, $node_in_second_tree), undef,
    "make_root(): no fsfile");
  
  is($fsfile->notSaved(), 0, 
    "make_root(): do not modify Treex::PML::Document::notSaved if not successful");
  
  $win_ref->{FSFile} = $fsfile;
  $win_ref->{root} = $fsfile->tree(0);
  
  is(TrEd::Window::TreeBasics::make_root($win_ref), undef,
    "make_root(): no node");
  is($fsfile->notSaved(), 0, 
    "make_root(): do not modify Treex::PML::Document::notSaved if not successful");
  
  
  is(TrEd::Window::TreeBasics::make_root($win_ref, $node_in_second_tree), undef,
    "make_root(): node is not part of the current tree");
  is($fsfile->notSaved(), 0, 
    "make_root(): do not modify Treex::PML::Document::notSaved if not successful");
  # notSaved to default position
  $fsfile->notSaved(0);
  
}

sub _test_make_root_discard {
  my ($fsfile) = @_;
  # notSaved to default position
  $fsfile->notSaved(0);
  
  my $second_tree = $fsfile->tree(1);
  my $win_ref = {
   treeNo         => 1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => $second_tree,
   root           => $second_tree,
  };
  my $node = $second_tree->firstson();
  my $node_type = $node->attr('nodetype');
  my @nodes_children = $node->children();
  
#  print "root = $second_tree,\n id= " . $second_tree->attr('id') . "\n";
#  foreach my $child_node (@nodes_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  ################
  #### After  ####
  ################
  is(TrEd::Window::TreeBasics::make_root($win_ref, $node, 1), 1, 
    "make_root(): correct return value");
  
  my $new_root = $fsfile->tree(1);
  my $new_root_type = $new_root->attr('nodetype');
  my @new_roots_children = $new_root->children();
  
  is($new_root, $node, 
    "make_root(): node is the new root");
    
  is($new_root_type, $node_type, 
    "make_root(): node's type is preserved");
    
  is_deeply(\@nodes_children, \@new_roots_children, 
    "make_root(): children of the node becomes the root's children");
    
#  print "root = $new_root,\n ".$new_root->attr('id')."\n";
#  foreach my $child_node (@new_roots_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  is($fsfile->notSaved(), 1, 
    "make_root(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
  
}

sub _test_make_root_nodiscard {
  my ($fsfile) = @_;
  # notSaved to default position
  $fsfile->notSaved(0);
  
  my $second_tree = $fsfile->tree(1);
  my $win_ref = {
   treeNo         => 1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => $second_tree,
   root           => $second_tree,
  };
  my $node = $second_tree->firstson();
  my @nodes_children = $node->children();
  my $node_type = $node->attr('nodetype');
#  print "root = $second_tree,\n " . $second_tree->attr('id') . "\n";
#  foreach my $child_node (@nodes_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  ################
  #### After  ####
  ################
  is(TrEd::Window::TreeBasics::make_root($win_ref, $node, 0), 1, 
    "make_root(): correct return value");
  
  my $new_root = $fsfile->tree(1);
  my $new_root_type = $new_root->attr('nodetype');
  my @new_roots_children = $new_root->children();
  my @nodes_children_and_former_root = (@nodes_children, $second_tree);
  
  is($new_root, $node, 
    "make_root(): node is the new root");
  
  is($new_root_type, $node_type, 
    "make_root(): node's type is preserved");
    
  is_deeply(\@nodes_children_and_former_root, \@new_roots_children, 
    "make_root(): children of the node becomes the root's children");

#  print "root = $new_root,\n ".$new_root->attr('id')."\n";
#  foreach my $child_node (@new_roots_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  is($fsfile->notSaved(), 1, 
    "make_root(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_make_root {
  my ($fsfile) = @_;
  _test_make_root_undef($fsfile);
  _test_make_root_discard($fsfile);
  _test_make_root_nodiscard($fsfile);
}

sub test_set_current {
  my $win_ref = {
    currentNode => 'node1',
  };
  
  my $new_node = 'node2';
  is(TrEd::Window::TreeBasics::set_current($win_ref, $new_node), undef,
    "set_current(): return value");
  
  is($win_ref->{currentNode}, $new_node, 
    "set_current(): currentNode changed in win_ref");
  
  is($win_ref->{msg}, "Changed current from node1 to $new_node by set_current", 
    "set_current(): callback on_current_change called");  
  
}


sub _test_new_node_undef {
  my ($fsfile) = @_;
  
  $fsfile->notSaved(0);
  
  my $first_tree_root = $fsfile->tree(0);
  my $roots_child = $first_tree_root->firstson();
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => $first_tree_root,
   root           => $first_tree_root,
  };
  
  ## FSFile undefined
  is(TrEd::Window::TreeBasics::new_node($win_ref), undef,
    "new_node(): fsfile not defined");
  is($fsfile->notSaved(), 0, 
    "new_node(): Treex::PML::Document::notSaved unchanged");
  
  ## currentNode undefined 
  $win_ref->{FSFile} = $fsfile;
  $win_ref->{currentNode} = undef;
  is(TrEd::Window::TreeBasics::new_node($win_ref), undef, 
    "new_node(): parent does not exist");
  is($fsfile->notSaved(), 0, 
    "new_node(): Treex::PML::Document::notSaved unchanged");
  
  # back to default
  $fsfile->notSaved(0);
}

# also tests get_node_no
sub _test_new_node {
  my ($fsfile) = @_;
  $fsfile->notSaved(0);
  
  my $tree_root = $fsfile->tree(3);
  my $node = $tree_root->firstson();
  my $nodes_son = $node->firstson();
  my @children_before = $node->children();
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => $node,
   root           => $tree_root,
  };
  
  ## create new child of root
  my $new_node = TrEd::Window::TreeBasics::new_node($win_ref);
  ok(UNIVERSAL::DOES::does($new_node, 'Treex::PML::Node'), "new_node(): new node created");
  
  is(TrEd::Window::TreeBasics::get_node_no($win_ref, $new_node), undef,
    "get_node_no(): node not found in another tree");
  
  # move to the tree we have just modified 
  $win_ref->{treeNo} = 3;  
  # the ordinal number of new node is 2:
  # because root is 0, 
  is(TrEd::Window::TreeBasics::get_node_no($win_ref, $tree_root), 0,
    "get_node_no(): root found at the correct position");
  
  # first son of root is 1
  is(TrEd::Window::TreeBasics::get_node_no($win_ref, $node), 1,
    "get_node_no(): root's child found in at the correct position");
  
  # and the new node is a child of the root's first son
  is(TrEd::Window::TreeBasics::get_node_no($win_ref, $new_node), 2,
    "get_node_no(): new node found at the correct position");

    
  ## verify the root's children
  # a) new node is node's first son
  is($node->firstson(), $new_node, 
    "new_node(): new node becomes the first son");
  # b) node's old first son becomes new first son's right brother
  is($new_node->rbrother(), $nodes_son, 
    "new_node(): former first son becomes new node's right brother");
  # c) new node is old first son's left brother
  is($nodes_son->lbrother(), $new_node, 
    "new_node(): new node becomes former first son's left brother");
  # d) all the other sons are untouched
  my @got_children = $node->children();
  my @expected_children = ($new_node, @children_before);
  my $i = 0;
  foreach my $node_ref (@got_children){
    is($node_ref, $expected_children[$i], 
      "new_node(): child $i found at the correct position");
    $i++;
  }
  ## currentNode set to new node
  is($win_ref->{currentNode}, $new_node, 
    "new_node(): set win_ref->{currentNode} to new node");
  
  ## callback on_node_change called
  is($win_ref->{msg}, "Node $new_node changed by new_node", 
    "new_node(): callback called");
  
  ## order set
  my $order = $win_ref->{FSFile}->FS()->order();
  if ($order) {
    is($new_node->get_member($order), $new_node->parent()->get_member($order), 
      "new_node(): order is set to parents order");
    
  }
  
  ## notSaved set to 1
  is($fsfile->notSaved(), 1, 
    "new_node(): Treex::PML::Document::notSaved set to 1");
  
  # back to default
  $fsfile->notSaved(0);
}

sub test_new_node {
  my ($fsfile) = @_;
  _test_new_node_undef($fsfile);
  _test_new_node($fsfile);
}



sub _test_prune_node_undef {
  my ($fsfile) = @_;
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef,
   root           => undef,
  };
  ## FSFile not defined
  my $node = $fsfile->tree(0);
  is(TrEd::Window::TreeBasics::prune_node($win_ref, $node), undef, 
    "prune_node(): return undef if win_ref->{FSFile} is not defined");
  
  $win_ref->{FSFile} = $fsfile;
  ## node not defined
  is(TrEd::Window::TreeBasics::prune_node($win_ref, undef), undef, 
    "prune_node(): return undef if node is not defined");
  
  ## node's parent not defined
  is(TrEd::Window::TreeBasics::prune_node($win_ref, bless({}, 'Treex::PML::Node')), undef, 
    "prune_node(): return undef if node's parent is not defined");
  
  
}

sub _test_prune_node {
  my ($fsfile) = @_;
  
  $fsfile->notSaved(0);
  
  my $root = $fsfile->tree(1);
  my $node = $root->firstson();
  my @nodes_children = $node->children();
  my $nodes_brother = $node->rbrother();
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => $node,
   root           => $root,
  };
  
  ## Prune node
  is(TrEd::Window::TreeBasics::prune_node($win_ref, $node), 1,
    "prune_node(): return value");
    
  ## Is the node really gone?
  ## Are all the node's children his parent's children now?
  ## Is node's ex-right brother new right brother of node's sons?
  my @got_children = $root->children();
  my @expected_children = (@nodes_children, $nodes_brother);
  my $i = 0;
  foreach my $node_ref (@got_children){
    is($node_ref, $expected_children[$i], 
      "prune_node(): node's child $i is its grandparent's new son (brother is still son)");
    $i++;
  }
  
  ## currentNode set to new node
  is($win_ref->{currentNode}, $root, 
    "prune_node(): set win_ref->{currentNode} to deleted node's parent");
  
  ## callback on_node_change called 
                      ## this is not a copy-paste mistake, this is testing copy-paste mistakes ;)
  is($win_ref->{msg}, "Node 1 changed by prune_node", 
    "prune_node(): callback called");
  
  ## notSaved set to 1
  is($fsfile->notSaved(), 1, 
    "new_node(): Treex::PML::Document::notSaved set to 1");
  
  # back to default
  $fsfile->notSaved(0);
}

sub test_prune_node {
  my ($fsfile) = @_;
  _test_prune_node_undef($fsfile);
  _test_prune_node($fsfile);
}


### Run tests

# create callbacks

$TrEd::Window::TreeBasics::on_current_change = sub {
  my ($win_ref, $new_current, $old_current, $fn_name) = @_;
  $win_ref->{msg} = "Changed current from $old_current to $new_current by $fn_name"; 
  return;
};


$TrEd::Window::TreeBasics::on_node_change = sub {
  my ($win_ref, $fn_name, $new_node) = @_;
  $win_ref->{msg} = "Node $new_node changed by $fn_name"; 
  return;
};

$TrEd::Window::TreeBasics::on_tree_change = sub {
  my ($win_ref, $fn_name, $tree) = @_;
  my $tree_id = ref($tree) ? "no-id-tree" : $tree;
  $win_ref->{msg} = "Changed tree $tree_id by $fn_name"; 
  return;
};

my $sample_file = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.t.gz");
my $fsfile = _init_fsfile($sample_file);

test_go_to_tree($fsfile);
test_next_tree($fsfile);
test_prev_tree($fsfile);

# new empty trees created at position 0 and 56 
test_new_tree($fsfile);

# two more empty trees at the end of file, one in the beginning
test_new_tree_after($fsfile);

# two empty trees from the end and one from the beginning of file are deleted
test_prune_tree($fsfile);

# first (empty) tree moved to position 3
test_move_tree($fsfile);

# modify 2nd tree -- at first 'pripravovat' becomes the root, discarding the original root
# then 'vystavba' becomes root, but 'pripravovat' is not discarded, it becomes the subtree of 'vystavba' 
test_make_root($fsfile);

test_set_current();

test_prune_node($fsfile);
#$fsfile->save("sample0_afterPruneNode.t.gz");

test_new_node($fsfile);



done_testing();