#!/usr/bin/env perl
# tests for TrEd::Basics

use strict;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;
use Treex::PML qw{ImportBackends};
use File::Spec;
use Cwd;

#use TrEd::Config;
#use TrEd::Utils;

BEGIN {
  my $module_name = 'TrEd::Basics';
  our @subs = qw(
    gotoTree
    nextTree
    prevTree
    newTree
    newTreeAfter
    pruneTree
    moveTree
    makeRoot
    newNode
    pruneNode
    setCurrent
    errorMessage
    absolutize
    absolutize_path
    uniq
    chooseNodeType
    fileSchema
    getSecondaryFiles
    getSecondaryFilesRecursively
    getPrimaryFiles
    getPrimaryFilesRecursively
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

our @subs;
can_ok(__PACKAGE__, @subs);

my @backends=(
  'FS',
  ImportBackends(
#    split(/,/,$opt_B), -- these are from command line
#    split(/,/,$ioBackends), -- and these from config file
    qw{NTRED
       Storable
       PML
       CSTS
       TrXML
       TEIXML
       PMLTransform
      })
);

### test function uniq()
sub test_uniq {
  my @array = qw{ 1 2 3 4 5 1 2 3 4 1 7 7 2 3 9 8 5 6 };
  my @expected = qw{ 1 2 3 4 5 6 7 8 9 };
  my @uniqued_array = sort(TrEd::Basics::uniq(@array));
  my @sorted_expected = sort(@expected);
    is_deeply(\@uniqued_array, \@sorted_expected,
              "uniq(): return uniqued array");
}

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
    # warn: this can be a looong Dump!
#    print Dumper($fsfile);
  return $fsfile;
}

### test fn gotoTree()
sub test_gotoTree {
  my ($fsfile) = @_;
  my $win_ref = {
   treeNo => 0,
   FSFile => undef,
   macroContext =>  'TredMacro',
   currentNode => undef,
   root => undef
  };
  
  ok(!defined(TrEd::Basics::gotoTree($win_ref)), "gotoTree(): return undef if FSFile is not defined");
  
  $win_ref = {
   treeNo => 128,
   FSFile => $fsfile,
   macroContext =>  'TredMacro',
   currentNode => $fsfile->currentNode(),
   root => undef
  };
  
  ## Try negative tree number
  is(TrEd::Basics::gotoTree($win_ref, -1), 0,
    "gotoTree(): negative tree number -- return 0");
  is($win_ref->{treeNo}, 0,
    "gotoTree(): set win_ref->{treeNo} if the position changes");
  is($win_ref->{root}->attr('nodetype'), 'root',
    "gotoTree(): win_ref->{root} is really a root node of the tree");
  is($win_ref->{root}->attr('id'), 't-ln94210-2-p1s1',
    "gotoTree(): win_ref->{root}'s id is correct -- first root");  
  
  ## No effect when not changing tree number
  $win_ref->{treeNo} = 0;
  $win_ref->{root} = undef;
  TrEd::Basics::gotoTree($win_ref, -1);
  is($win_ref->{treeNo}, 0,
    "gotoTree(): do not modify win_ref->{treeNo}, if the position does not change");
  ok(!defined($win_ref->{root}), "gotoTree(): do not modify win_ref->{root}, if the position does not change");
  
  ## Tree number bigger than number of trees in file
  is(TrEd::Basics::gotoTree($win_ref, 55), 53,
    "gotoTree(): tree number bigger than the number of trees -- return number of trees");
  is($win_ref->{treeNo}, 53,
    "gotoTree(): set win_ref->{treeNo} to last tree if the position is larger than number of trees in file");
  is($win_ref->{root}->attr('nodetype'), 'root',
    "gotoTree(): win_ref->{root} is really a root node of the tree");
  is($win_ref->{root}->attr('id'), 't-ln94208-140-p2s4',
    "gotoTree(): win_ref->{root}'s id is correct -- last root");  
    
  #TODO: test also running on_tree_change (and other callbacks) somehow?
}


sub _tree_id_is {
  my ($tree, $expected_id, $perform_test, $message) = @_;
  if($perform_test){
    is($tree->root()->attr('id'), $expected_id, $message);
  } else {
    if($tree->root()->attr('id') eq $expected_id){
      return 1;
    } else {
      return 0;
    }
  }
}

sub _test_win_ref {
  my ($arg_ref) = @_;
  my $win_ref           = $arg_ref->{win_ref};
  my $fn_ref            = $arg_ref->{fn_ref};
  my $expected_win_ref  = $arg_ref->{expected_win_ref};
  my $expected_val      = $arg_ref->{expected_val};
  my $msg1              = $arg_ref->{msg1};
  my $msg2              = $arg_ref->{msg2};
  
  is($fn_ref->($win_ref), $expected_val,
    $msg1);
  is_deeply($win_ref, $expected_win_ref, 
    $msg2);

# toto je asi este horsie zrozumitelne...
#  _test_win_ref({
#    fn_ref            => \&TrEd::Basics::nextTree,
#    win_ref           => $win_ref,
#    expected_val      => 0,
#    msg1              => "nextTree(): return 0 if there is no next tree",
#    expected_win_ref  => $expected_win_ref,
#    msg2              => "nextTree() does not modify win_ref if there is no next tree",
#  });
  
}

sub test_nextTree {
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
  
  is(TrEd::Basics::nextTree($win_ref), 0,
    "nextTree(): return 0 if there is no next tree");
  is_deeply($win_ref, $expected_win_ref, 
    "nextTree() does not modify win_ref if there is no next tree");
  
  
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
  };
  is(TrEd::Basics::nextTree($win_ref), 1,
    "nextTree(): return 1 if there is some next tree");
  is_deeply($win_ref, $expected_win_ref, 
    "nextTree() set root and treeNo correctly");
}
 
sub test_prevTree {
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
  
  is(TrEd::Basics::prevTree($win_ref), 0,
    "prevTree(): return 0 if there is no previous tree");
  is_deeply($win_ref, $expected_win_ref, 
    "prevTree() does not modify win_ref if there is no next tree");
  
  
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
  };
  is(TrEd::Basics::prevTree($win_ref), 1,
    "prevTree(): return 1 if there is some previous tree");
  is_deeply($win_ref, $expected_win_ref, 
    "prevTree() set root and treeNo correctly");
}

$Data::Dumper::Maxdepth = 1;

sub test_newTree {
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
  is(TrEd::Basics::newTree($win_ref), 1,
    "newTree(): return value");
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  
  is($win_ref->{root}, $now_first_tree, 
    "newTree(): win_ref->root contains new tree which becomes the first tree in file");
  
  is($first_tree, $now_second_tree, 
    "newTree(): move first tree to the second position");
  
  is($second_tree, $now_third_tree, 
    "newTree(): move second tree to the third position");
  
  is($fsfile->notSaved(), 1, 
    "newTree(): Treex::PML::Document::notSaved set to 1");
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
  
  ok(!defined(TrEd::Basics::newTree($win_ref)), "newTree(): return undef if fsfile is not defined");
  
  ## Try position out of bounds of the loaded file
  $win_ref = {
   treeNo         => 120,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
  is(TrEd::Basics::newTree($win_ref), 1,
    "newTree(): return value when out of bounds");
    
  is($win_ref->{root}, $fsfile->tree($fsfile->lastTreeNo()), 
    "newTree(): if the position is after the end of file, add after last position");
  
}

sub _test_newTreeAfter_undef {
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
  
  ok(!defined(TrEd::Basics::newTreeAfter($win_ref)), "newTreeAfter(): return undef if fsfile is not defined");
}

sub _test_newTreeAfter_in_bounds {
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
  
  is(TrEd::Basics::newTreeAfter($win_ref), 1,
    "newTreeAfter(): return value");
  
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_no_of_trees = $fsfile->lastTreeNo();
  my $now_last_tree = $fsfile->tree($now_no_of_trees);
  my $now_bef_last_tree = $fsfile->tree($now_no_of_trees - 1);

  
  is($win_ref->{root}, $now_last_tree, 
    "newTreeAfter(): win_ref->root contains new tree which becomes the last tree in file");
  
  is($last_tree, $now_bef_last_tree, 
    "newTreeAfter(): last tree becomes the one before the last one");
  
  is($fsfile->notSaved(), 1, 
    "newTreeAfter(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_newTreeAfter_after_eof {
  my ($fsfile) = @_;
  note("newTreeAfter: adding after the end of file");
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
  
  is(TrEd::Basics::newTreeAfter($win_ref), 1,
    "newTreeAfter(): return value");
  
  ################
  #### After  ####
  ################
#  print Dumper($fsfile->treeList());
  
  my $now_no_of_trees = $fsfile->lastTreeNo();
  my $now_last_tree = $fsfile->tree($now_no_of_trees);
  my $now_bef_last_tree = $fsfile->tree($now_no_of_trees - 1);

  
  is($win_ref->{root}, $now_last_tree, 
    "newTreeAfter(): win_ref->root contains new tree which becomes the last tree in file");
  
  is($last_tree, $now_bef_last_tree, 
    "newTreeAfter(): last tree becomes the one before the last one");
  
  is($fsfile->notSaved(), 1, 
    "newTreeAfter(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_newTreeAfter_before_bof {
  my ($fsfile) = @_;
  note("newTreeAfter: adding before the beginning of file");
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
  
  is(TrEd::Basics::newTreeAfter($win_ref), 1,
    "newTreeAfter(): return value");
  
  ################
  #### After  ####
  ################
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  
  is($win_ref->{root}, $now_first_tree, 
    "newTreeAfter(): win_ref->root contains new tree which becomes the first tree in file");
  
  is($first_tree, $now_second_tree, 
    "newTreeAfter(): first tree becomes the second one");
  
  is($second_tree, $now_third_tree, 
    "newTreeAfter(): 2nd tree becomes the 3rd one");
  
  is($fsfile->notSaved(), 1, 
    "newTreeAfter(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_newTreeAfter {
  my ($fsfile) = @_;
  _test_newTreeAfter_in_bounds($fsfile);
  _test_newTreeAfter_after_eof($fsfile);
  _test_newTreeAfter_before_bof($fsfile);
  _test_newTreeAfter_undef();
}


sub _test_pruneTree_first {
  my ($fsfile) = @_;
  note("pruneTree: removing from the beginning of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $first_tree  = $fsfile->tree(0);
  my $second_tree = $fsfile->tree(1);
  my $third_tree  = $fsfile->tree(2);
  my $fourth_tree = $fsfile->tree(3);
  
#  print "before pruneTree: " . Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  
  is(TrEd::Basics::pruneTree($win_ref), 1,
    "pruneTree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after pruneTree" . Dumper($fsfile->treeList());
  
  my $now_first_tree = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree = $fsfile->tree(2);
  my $now_fourth_tree = $fsfile->tree(3);
  
  is($win_ref->{root}, $second_tree, 
    "pruneTree(): win_ref->root contains second tree");
  
  is($third_tree, $now_second_tree, 
    "pruneTree(): second tree moved to the first position");
  
  is($fourth_tree, $now_third_tree, 
    "pruneTree(): 4th tree moved to the 3rd position");
    
  is($fsfile->notSaved(), 1, 
    "pruneTree(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_pruneTree_last {
  my ($fsfile) = @_;
  ########################
  #### Remove from end ###
  ########################
  note("pruneTree: removing from the end of file");
  ################
  #### Before ####
  ################
  # set notSaved to 0, so we see if it is changed
  $fsfile->notSaved(0);
  my $no_of_trees = $fsfile->lastTreeNo();
  my $last_tree  = $fsfile->tree($no_of_trees);
  my $before_last_tree = $fsfile->tree($no_of_trees - 1);
  
#  print "before last pruneTree: " . Dumper($fsfile->treeList());
  
  my $win_ref = {
   treeNo         => $no_of_trees,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $last_tree->root(),
  };
  
  is(TrEd::Basics::pruneTree($win_ref), 1,
    "pruneTree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after pruneTree" . Dumper($fsfile->treeList());
  $no_of_trees = $fsfile->lastTreeNo();
  
  my $now_last_tree = $fsfile->tree($no_of_trees);
  
  is($win_ref->{root}, $now_last_tree, 
    "pruneTree(): win_ref->root contains the new last tree");
  
  is($before_last_tree, $now_last_tree, 
    "pruneTree(): last tree is removed, the one before the last one becomes the last one");
    
  is($fsfile->notSaved(), 1, 
    "pruneTree(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_pruneTree_negative {
  my ($fsfile) = @_;
  ############################
  #### Remove with - index ###
  ############################
  note("pruneTree: negative index");
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
  
#  print "b4 pruneTree" . Dumper($fsfile->treeList());
  is(TrEd::Basics::pruneTree($win_ref), 1, 
    "pruneTree(): return value, negative index");
  
  ################
  #### After  ####
  ################
#  print "after pruneTree" . Dumper($fsfile->treeList());
  $no_of_trees = $fsfile->lastTreeNo();

  my $now_last_tree = $fsfile->tree($no_of_trees);

  is($win_ref->{root}, $fsfile->tree(0), 
    "pruneTree(): negative index: win_ref->root contains the first tree");
  
  is($before_last_tree, $now_last_tree, 
    "pruneTree(): negative index: last tree is removed, the one before the last one becomes the last one");
    
  is($fsfile->notSaved(), 1, 
    "pruneTree(): negative index: Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub _test_pruneTree_undef {
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
  
  ok(!defined(TrEd::Basics::pruneTree($win_ref)), "pruneTree(): return undef if fsfile is not defined");
  
  ## pruneTree after the end of file
  $win_ref->{treeNo} = $fsfile->lastTreeNo() + 1;  
  ok(!defined(TrEd::Basics::pruneTree($win_ref)), "pruneTree(): tree out of bounds: position after the end of file");

}

sub test_pruneTree {
  my ($fsfile) = @_;
  _test_pruneTree_first($fsfile);
  _test_pruneTree_undef($fsfile);
  _test_pruneTree_last($fsfile);
  _test_pruneTree_negative($fsfile);
}

sub _test_moveTree_out_of_bounds {
  my ($fsfile) = @_;
  note("moveTree: corner cases");
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
  
  dies_ok(sub { TrEd::Basics::moveTree($win_ref, $no_of_trees + 1) }, "moveTree(): move existing tree after the file ending");
  dies_ok(sub { TrEd::Basics::moveTree($win_ref, -1) }, "moveTree(): move existing tree before the file beginning");
  
  $win_ref = {
   treeNo         => $no_of_trees + 1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  dies_ok(sub { TrEd::Basics::moveTree($win_ref, 0) }, "moveTree(): try to move tree with ordinal number greater than total number of trees in file");
  
  $win_ref = {
   treeNo         => -1,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  dies_ok(sub { TrEd::Basics::moveTree($win_ref, 0) }, "moveTree(): try to move tree with ordinal number -1");
  
  $win_ref = {
   treeNo         => 0,
   FSFile         => $fsfile,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => $first_tree->root(),
  };
  ok(!defined(TrEd::Basics::moveTree($win_ref, 0)), "moveTree(): delta is 0");
  
  $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  ok(!defined(TrEd::Basics::moveTree($win_ref, 0)), "moveTree(): fsfile not defined");
}

#sub moveTree {
#  my ($win_ref,$delta) = @_;
#  my $fsfile = $win_ref->{FSFile};
#  return if (!$fsfile);
#  my $no = $win_ref->{treeNo};
#  $fsfile->move_tree_to($no, $no + $delta) || return;
#  $win_ref->{treeNo} = $no + $delta;
#  $win_ref->{root} = $win_ref->{FSFile}->treeList()->[$win_ref->{treeNo}];
#  $win_ref->{FSFile}->notSaved(1);
#  &$on_tree_change($win_ref,'moveTree',$win_ref->{treeNo}) if $on_tree_change;
#  return 1;
#}
sub _test_moveTree {
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
  
#  print "b4 pruneTree" . Dumper($fsfile->treeList());
  is(TrEd::Basics::moveTree($win_ref, 2), 1, 
    "moveTree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after pruneTree" . Dumper($fsfile->treeList());
  my $now_first_tree  = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree  = $fsfile->tree(2);
  my $now_fourth_tree = $fsfile->tree(3);

  is($win_ref->{root}, $now_third_tree, 
    "moveTree(): win_ref->root contains moved tree");
  
  is($now_first_tree, $second_tree, 
    "pruneTree(): second tree becomes the first one");
  
  is($now_second_tree, $third_tree, 
    "pruneTree(): 3rd tree becomes the 2nd one");
  
  is($now_third_tree, $first_tree, 
    "pruneTree(): 1st tree becomes the 3rd one");
  
  is($now_fourth_tree, $fourth_tree, 
    "pruneTree(): 4th tree is still the 4th one");
  
  is($fsfile->notSaved(), 1, 
    "pruneTree(): negative index: Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_moveTree {
  my ($fsfile) = @_;
  _test_moveTree($fsfile);
  _test_moveTree_out_of_bounds($fsfile);
}

### Run tests

test_uniq();

my $sample_file = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.t.gz");
my $fsfile = _init_fsfile($sample_file);
test_gotoTree($fsfile);
test_nextTree($fsfile);
test_prevTree($fsfile);
test_newTree($fsfile);
test_newTreeAfter($fsfile);
test_pruneTree($fsfile);
test_moveTree($fsfile);