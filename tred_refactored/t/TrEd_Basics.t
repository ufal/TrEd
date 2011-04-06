#!/usr/bin/env perl
# tests for TrEd::Basics

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
#use lib "$FindBin::Bin/../tredlib/libs/tk"; # for Tk::ErrorReport

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
  
  is(TrEd::Basics::gotoTree($win_ref), undef, 
    "gotoTree(): return undef if FSFile is not defined");
  
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
  is($win_ref->{root}, undef, 
    "gotoTree(): do not modify win_ref->{root}, if the position does not change");
  
  ## Tree number bigger than number of trees in file
  is(TrEd::Basics::gotoTree($win_ref, 55), 53,
    "gotoTree(): tree number bigger than the number of trees -- return number of trees");
  is($win_ref->{treeNo}, 53,
    "gotoTree(): set win_ref->{treeNo} to last tree if the position is larger than number of trees in file");
  is($win_ref->{root}->attr('nodetype'), 'root',
    "gotoTree(): win_ref->{root} is really a root node of the tree");
  is($win_ref->{root}->attr('id'), 't-ln94208-140-p2s4',
    "gotoTree(): win_ref->{root}'s id is correct -- last root");  
    
  ## Test that callback was called
  is($win_ref->{msg}, "Changed tree ".$win_ref->{treeNo}." by gotoTree", 
    "gotoTree(): callback called");
}


#sub _tree_id_is {
#  my ($tree, $expected_id, $perform_test, $message) = @_;
#  if($perform_test){
#    is($tree->root()->attr('id'), $expected_id, $message);
#  } else {
#    if($tree->root()->attr('id') eq $expected_id){
#      return 1;
#    } else {
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
##    fn_ref            => \&TrEd::Basics::nextTree,
##    win_ref           => $win_ref,
##    expected_val      => 0,
##    msg1              => "nextTree(): return 0 if there is no next tree",
##    expected_win_ref  => $expected_win_ref,
##    msg2              => "nextTree() does not modify win_ref if there is no next tree",
##  });
#  
#}

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
    msg           => "Changed tree 1 by gotoTree",
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
        msg           => "Changed tree 0 by gotoTree",
  };
  is(TrEd::Basics::prevTree($win_ref), 1,
    "prevTree(): return 1 if there is some previous tree");
  is_deeply($win_ref, $expected_win_ref, 
    "prevTree() set root and treeNo correctly");
}

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
    
  is($win_ref->{msg}, "Changed tree no-id-tree by newTree", 
    "newTree(): callback called");
    
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
  
  is(TrEd::Basics::newTree($win_ref), undef, 
    "newTree(): return undef if fsfile is not defined");
  
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
  
  is(TrEd::Basics::newTreeAfter($win_ref), undef, 
    "newTreeAfter(): return undef if fsfile is not defined");
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
  
  is($win_ref->{msg}, "Changed tree no-id-tree by newTreeAfter", 
    "newTreeAfter(): callback called");
  
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
  
  is($win_ref->{msg}, "Changed tree no-id-tree by newTreeAfter", 
    "newTreeAfter(): callback called");
  
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
  
  is($win_ref->{msg}, "Changed tree no-id-tree by newTreeAfter", 
    "newTreeAfter(): callback called");
  
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
    
  is($win_ref->{msg}, "Changed tree 0 by pruneTree", 
    "pruneTree(): callback called");
    
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
  
  is($win_ref->{msg}, "Changed tree $no_of_trees by pruneTree", 
    "pruneTree(): callback called");
  
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
  
  is($win_ref->{msg}, "Changed tree 0 by pruneTree", 
    "pruneTree(): callback called");
  
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
  
  is(TrEd::Basics::pruneTree($win_ref), undef, 
    "pruneTree(): return undef if fsfile is not defined");
  
  ## pruneTree after the end of file
  $win_ref->{treeNo} = $fsfile->lastTreeNo() + 1;  
  is(TrEd::Basics::pruneTree($win_ref), undef, 
    "pruneTree(): tree out of bounds: position after the end of file");

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
  is(TrEd::Basics::moveTree($win_ref, 0), undef, 
    "moveTree(): delta is 0");
  
  $win_ref = {
   treeNo         => 0,
   FSFile         => undef,
   macroContext   => 'TredMacro',
   currentNode    => undef, 
   root           => undef,
  };
  is(TrEd::Basics::moveTree($win_ref, 0), undef, 
    "moveTree(): fsfile not defined");
}

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
  
#  print "b4 moveTree" . Dumper($fsfile->treeList());
  is(TrEd::Basics::moveTree($win_ref, 2), 1, 
    "moveTree(): return value");
  
  ################
  #### After  ####
  ################
#  print "after moveTree" . Dumper($fsfile->treeList());
  my $now_first_tree  = $fsfile->tree(0);
  my $now_second_tree = $fsfile->tree(1);
  my $now_third_tree  = $fsfile->tree(2);
  my $now_fourth_tree = $fsfile->tree(3);

  is($win_ref->{root}, $now_third_tree, 
    "moveTree(): win_ref->root contains moved tree");
  
  is($now_first_tree, $second_tree, 
    "moveTree(): second tree becomes the first one");
  
  is($now_second_tree, $third_tree, 
    "moveTree(): 3rd tree becomes the 2nd one");
  
  is($now_third_tree, $first_tree, 
    "moveTree(): 1st tree becomes the 3rd one");
  
  is($now_fourth_tree, $fourth_tree, 
    "moveTree(): 4th tree is still the 4th one");
  
  is($win_ref->{msg}, "Changed tree 2 by moveTree", 
    "moveTree(): callback called");
  
  is($fsfile->notSaved(), 1, 
    "moveTree(): negative index: Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_moveTree {
  my ($fsfile) = @_;
  _test_moveTree($fsfile);
  _test_moveTree_out_of_bounds($fsfile);
}

sub _test_makeRoot_undef {
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
  
  is(TrEd::Basics::makeRoot($win_ref, $node_in_second_tree), undef,
    "makeRoot(): no fsfile");
  
  is($fsfile->notSaved(), 0, 
    "makeRoot(): do not modify Treex::PML::Document::notSaved if not successful");
  
  $win_ref->{FSFile} = $fsfile;
  $win_ref->{root} = $fsfile->tree(0);
  
  is(TrEd::Basics::makeRoot($win_ref), undef,
    "makeRoot(): no node");
  is($fsfile->notSaved(), 0, 
    "makeRoot(): do not modify Treex::PML::Document::notSaved if not successful");
  
  
  is(TrEd::Basics::makeRoot($win_ref, $node_in_second_tree), undef,
    "makeRoot(): node is not part of the current tree");
  is($fsfile->notSaved(), 0, 
    "makeRoot(): do not modify Treex::PML::Document::notSaved if not successful");
  # notSaved to default position
  $fsfile->notSaved(0);
  
}

sub _test_makeRoot_discard {
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
  is(TrEd::Basics::makeRoot($win_ref, $node, 1), 1, 
    "makeRoot(): correct return value");
  
  my $new_root = $fsfile->tree(1);
  my $new_root_type = $new_root->attr('nodetype');
  my @new_roots_children = $new_root->children();
  
  is($new_root, $node, 
    "makeRoot(): node is the new root");
    
  is($new_root_type, $node_type, 
    "makeRoot(): node's type is preserved");
    
  is_deeply(\@nodes_children, \@new_roots_children, 
    "makeRoot(): children of the node becomes the root's children");
    
#  print "root = $new_root,\n ".$new_root->attr('id')."\n";
#  foreach my $child_node (@new_roots_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  is($fsfile->notSaved(), 1, 
    "makeRoot(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
  
}

sub _test_makeRoot_nodiscard {
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
  is(TrEd::Basics::makeRoot($win_ref, $node, 0), 1, 
    "makeRoot(): correct return value");
  
  my $new_root = $fsfile->tree(1);
  my $new_root_type = $new_root->attr('nodetype');
  my @new_roots_children = $new_root->children();
  my @nodes_children_and_former_root = (@nodes_children, $second_tree);
  
  is($new_root, $node, 
    "makeRoot(): node is the new root");
  
  is($new_root_type, $node_type, 
    "makeRoot(): node's type is preserved");
    
  is_deeply(\@nodes_children_and_former_root, \@new_roots_children, 
    "makeRoot(): children of the node becomes the root's children");

#  print "root = $new_root,\n ".$new_root->attr('id')."\n";
#  foreach my $child_node (@new_roots_children) {
#    print "child " . $child_node->attr('id') . "\n";
#  }
  
  is($fsfile->notSaved(), 1, 
    "makeRoot(): Treex::PML::Document::notSaved set to 1");
  # notSaved to default position
  $fsfile->notSaved(0);
}

sub test_makeRoot {
  my ($fsfile) = @_;
  _test_makeRoot_undef($fsfile);
  _test_makeRoot_discard($fsfile);
  _test_makeRoot_nodiscard($fsfile);
}

sub test_setCurrent {
  my $win_ref = {
    currentNode => 'node1',
  };
  
  my $new_node = 'node2';
  is(TrEd::Basics::setCurrent($win_ref, $new_node), undef,
    "setCurrent(): return value");
  
  is($win_ref->{currentNode}, $new_node, 
    "setCurrent(): currentNode changed in win_ref");
  
  is($win_ref->{msg}, "Changed current from node1 to $new_node by setCurrent", 
    "setCurrent(): callback on_current_change called");  
  
}


sub _test_newNode_undef {
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
  is(TrEd::Basics::newNode($win_ref), undef,
    "newNode(): fsfile not defined");
  is($fsfile->notSaved(), 0, 
    "newNode(): Treex::PML::Document::notSaved unchanged");
  
  ## currentNode undefined 
  $win_ref->{FSFile} = $fsfile;
  $win_ref->{currentNode} = undef;
  is(TrEd::Basics::newNode($win_ref), undef, 
    "newNode(): parent does not exist");
  is($fsfile->notSaved(), 0, 
    "newNode(): Treex::PML::Document::notSaved unchanged");
  
  # back to default
  $fsfile->notSaved(0);
}

sub _test_newNode {
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
  my $new_node = TrEd::Basics::newNode($win_ref);
  ok(UNIVERSAL::DOES::does($new_node, 'Treex::PML::Node'), "newNode(): new node created");
    
  ## verify the root's children
  # a) new node is node's first son
  is($node->firstson(), $new_node, 
    "newNode(): new node becomes the first son");
  # b) node's old first son becomes new first son's right brother
  is($new_node->rbrother(), $nodes_son, 
    "newNode(): former first son becomes new node's right brother");
  # c) new node is old first son's left brother
  is($nodes_son->lbrother(), $new_node, 
    "newNode(): new node becomes former first son's left brother");
  # d) all the other sons are untouched
  my @got_children = $node->children();
  my @expected_children = ($new_node, @children_before);
  my $i = 0;
  foreach my $node_ref (@got_children){
    is($node_ref, $expected_children[$i], 
      "newNode(): child $i found at a correct place");
    $i++;
  }
  ## currentNode set to new node
  is($win_ref->{currentNode}, $new_node, 
    "newNode(): set win_ref->{currentNode} to new node");
  
  ## callback on_node_change called
  is($win_ref->{msg}, "Node $new_node changed by newNode", 
    "newNode(): callback called");
  
  ## order set
  my $order = $win_ref->{FSFile}->FS()->order();
  if ($order) {
    is($new_node->get_member($order), $new_node->parent()->get_member($order), 
      "newNode(): order is set to parents order");
    
  }
  
  ## notSaved set to 1
  is($fsfile->notSaved(), 1, 
    "newNode(): Treex::PML::Document::notSaved set to 1");
  
  # back to default
  $fsfile->notSaved(0);
}

sub test_newNode {
  my ($fsfile) = @_;
  _test_newNode_undef($fsfile);
  _test_newNode($fsfile);
}



sub _test_pruneNode_undef {
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
  is(TrEd::Basics::pruneNode($win_ref, $node), undef, 
    "pruneNode(): return undef if win_ref->{FSFile} is not defined");
  
  $win_ref->{FSFile} = $fsfile;
  ## node not defined
  is(TrEd::Basics::pruneNode($win_ref, undef), undef, 
    "pruneNode(): return undef if node is not defined");
  
  ## node's parent not defined
  is(TrEd::Basics::pruneNode($win_ref, bless({}, 'Treex::PML::Node')), undef, 
    "pruneNode(): return undef if node's parent is not defined");
  
  
}

sub _test_pruneNode {
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
  is(TrEd::Basics::pruneNode($win_ref, $node), 1,
    "pruneNode(): return value");
    
  ## Is the node really gone?
  ## Are all the node's children his parent's children now?
  ## Is node's ex-right brother new right brother of node's sons?
  my @got_children = $root->children();
  my @expected_children = (@nodes_children, $nodes_brother);
  my $i = 0;
  foreach my $node_ref (@got_children){
    is($node_ref, $expected_children[$i], 
      "pruneNode(): node's child $i is its grandparent's new son (brother is still son)");
    $i++;
  }
  
  ## currentNode set to new node
  is($win_ref->{currentNode}, $root, 
    "pruneNode(): set win_ref->{currentNode} to deleted node's parent");
  
  ## callback on_node_change called 
                      ## this is not a copy-paste mistake, this is testing copy-paste mistakes ;)
  is($win_ref->{msg}, "Node 1 changed by newTree", 
    "pruneNode(): callback called");
  
  ## notSaved set to 1
  is($fsfile->notSaved(), 1, 
    "newNode(): Treex::PML::Document::notSaved set to 1");
  
  # back to default
  $fsfile->notSaved(0);
}

sub test_pruneNode {
  my ($fsfile) = @_;
  _test_pruneNode_undef($fsfile);
  _test_pruneNode($fsfile);
}

#TODO: Tk GUI testing
sub test__messageBox {
#  TrEd::Basics::_messageBox({}, "titulok", "mesidz");
}


sub _test_errorMessage_onerror {
  my ($fsfile) = @_;
  $TrEd::Basics::on_error = sub {
    my ($win_ref, $msg, $nobug) = @_;
    return "Message: $msg, Nobug: $nobug";
  };
  
  my $msg = "message";
  my $nobug = "nobug";
  is(TrEd::Basics::errorMessage({}, $msg, $nobug), "Message: $msg, Nobug: $nobug",
    "errorMessage(): use callback");
}

sub _test_errorMessage {
  my ($fsfile) = @_;
  note("Expected error message:");
  $TrEd::Basics::on_error = undef;
  
  my $msg = "message";
  my $nobug = "nobug";
  TrEd::Basics::errorMessage({}, $msg, $nobug);
}

sub test_errorMessage {
  my ($fsfile) = @_;
  _test_errorMessage_onerror($fsfile);
  _test_errorMessage($fsfile);
}


sub test_absolutizePath {
  my $findbin = $FindBin::Bin;
  my @expected_paths = (
      # If the $filename is an absolute path or an absolute URL, it is returned umodified
      {
        "filename"        => "/home/even/though/it/does/not/exist",
        "ref_path"        => "",
        "search_res_path" => 0,
        "expected_result" => "file:///home/even/though/it/does/not/exist", 
        "test_name"       => "Absolute filename 1",
      },
      {
        "filename"        => "file://etc/X11/xorg.conf",
        "ref_path"        => "",
        "search_res_path" => 0,
        "expected_result" => "file://etc/X11/xorg.conf",
        "test_name"       => "Absolute filename 2", 
      },
      # If it is a relative path and $ref_path is a local path or a file:// URL,
      # the function tries to locate the file relatively to $ref_path and
      # if such a file exists, returns an absolute filename or file:// URL to the file.
      {
        "filename"        => "simple-macro.mac",
        "ref_path"        => "$findbin/test_macros",
        "search_res_path" => 0,
        "expected_result" => "file://$findbin/simple-macro.mac",
        "test_name"       => "Relative filename 1", 
      },
      {
        "filename"        => "t/test_macros/include/../simple-macro.mac",
        "ref_path"        => "$findbin",
        "search_res_path" => 0,
        "expected_result" => "$findbin/test_macros/simple-macro.mac",
        "test_name"       => "Relative filename 2", 
      },
      #this works strange
      {
        "filename"        => "simple-macro.mac",
        "ref_path"        => "file://$findbin/test_macros",
        "search_res_path" => 0,
        "expected_result" => "simple-macro.mac",
        "test_name"       => "Relative filename 3", 
      },
      {
        "filename"        => "t/test_macros/include/../simple-macro.mac",
        "ref_path"        => "file://$findbin",
        "search_res_path" => 0,
        "expected_result" => "file://$findbin/test_macros/simple-macro.mac",
        "test_name"       => "Relative filename 4",
      },
    );
  my $i = 0;
  foreach my $hash (@expected_paths){
    is(TrEd::Basics::absolutize_path($hash->{'ref_path'}, $hash->{'filename'}, $hash->{'search_res_path'}), $hash->{'expected_result'}, 
      "absolutizePath(): " . $hash->{'test_name'});
  }
}

sub test_absolutize {
  my @input_array = (
    "     ",
    "  ",
    "/home/something/unusual",
    "x:/Documents and Settings/John",
    "t/test_macros/include/../simple-macro.mac",
  );

  my @expected_result = sort(
    "/home/something/unusual",
    "x:/Documents and Settings/John",
    $FindBin::Bin . "/test_macros/include/../simple-macro.mac",
  );
  
  my @got_result = sort(TrEd::Basics::absolutize(@input_array));
  
  is_deeply(\@got_result, \@expected_result, 
    "absolutize(): create absolute paths");
}


sub test_fileSchema {
  my ($fsfile) = @_;
  is(TrEd::Basics::fileSchema($fsfile), $fsfile->schema(),
    "fileSchema(): return ref to PML schema");
}

sub test_getSecondaryFiles {
  my ($fsfile) = @_;
  my @pair_list = $fsfile->relatedDocuments();

  my @secondary_files = TrEd::Basics::getSecondaryFiles($fsfile);

#  print Dumper(\@secondary_files);
  is("file://" . $secondary_files[0]->filename(), $pair_list[0]->[1], 
    "getSecondaryFiles(): file name agrees");
}


sub test_getSecondaryFilesRecursively {
  my ($fsfile, $fsfile_2) = @_;
  
  # first level
  my @pair_list = $fsfile->relatedDocuments();
  my $file_1 = $pair_list[0]->[1];
  # load doc from second level
  
  @pair_list = $fsfile_2->relatedDocuments();
  my $file_2 = $pair_list[0]->[1];
  # construct expected file list
  my @expected_files = sort($file_1, $file_2);
  
  
  my @secondary_files_rec = sort( map { "file://" . $_->filename() } TrEd::Basics::getSecondaryFilesRecursively($fsfile) );
  
  is_deeply(\@secondary_files_rec, \@expected_files, 
    "getSecondaryFilesRecursively(): find all files");
  
#  $Data::Dumper::Maxdepth = 2;

}

sub test_getPrimaryFiles {
  my ($fsfile, $fsfile_2) = @_;
  my @expected_primary = $fsfile_2->relatedSuperDocuments();
  $Data::Dumper::Maxdepth = 2;
#  print Dumper(\@expected_primary);
  
  my @primary_files = TrEd::Basics::getPrimaryFiles($fsfile_2);
  
#  print Dumper(\@primary_files);
  is_deeply(\@primary_files, \@expected_primary, 
    "getPrimaryFiles(): primary file found");
}

sub test_getPrimaryFilesRecursively {
  my ($fsfile_2, $fsfile_3) = @_;
  my @expected_primary = $fsfile_3->relatedSuperDocuments();
  
  my @expected_primary_2 = $fsfile_2->relatedSuperDocuments();
  
  my @expected_primary_rec = sort(@expected_primary, @expected_primary_2);
  $Data::Dumper::Maxdepth = 2;
#  print Dumper(\@expected_primary_rec);
    
  my @primary_files_rec = sort(TrEd::Basics::getPrimaryFilesRecursively($fsfile_3));
  
#  print Dumper(\@primary_files_rec);
  is_deeply(\@primary_files_rec, \@expected_primary_rec, 
    "getPrimaryFilesRecursively(): primary files found recursively");
}

### Run tests

test_uniq();
# create callbacks

$TrEd::Basics::on_current_change = sub {
  my ($win_ref, $new_current, $old_current, $fn_name) = @_;
  $win_ref->{msg} = "Changed current from $old_current to $new_current by $fn_name"; 
  return;
};


$TrEd::Basics::on_node_change = sub {
  my ($win_ref, $fn_name, $new_node) = @_;
  $win_ref->{msg} = "Node $new_node changed by $fn_name"; 
  return;
};

$TrEd::Basics::on_tree_change = sub {
  my ($win_ref, $fn_name, $tree) = @_;
  my $tree_id = ref($tree) ? "no-id-tree" : $tree;
  $win_ref->{msg} = "Changed tree $tree_id by $fn_name"; 
  return;
};

my $sample_file = File::Spec->catfile($FindBin::Bin, "test_files", "sample0.t.gz");
my $fsfile = _init_fsfile($sample_file);

test_gotoTree($fsfile);
test_nextTree($fsfile);
test_prevTree($fsfile);

# new empty trees created at position 0 and 56 
test_newTree($fsfile);

# two more empty trees at the end of file, one in the beginning
test_newTreeAfter($fsfile);

# two empty trees from the end and one from the beginning of file are deleted
test_pruneTree($fsfile);

# first (empty) tree moved to position 3
test_moveTree($fsfile);

# modify 2nd tree -- at first 'pripravovat' becomes the root, discarding the original root
# then 'vystavba' becomes root, but 'pripravovat' is not discarded, it becomes the subtree of 'vystavba' 
test_makeRoot($fsfile);

test_setCurrent();

test_pruneNode($fsfile);
#$fsfile->save("sample0_afterPruneNode.t.gz");

test_newNode($fsfile);

test__messageBox();

test_errorMessage($fsfile);

test_absolutizePath();

test_absolutize();

test_fileSchema($fsfile);

test_getSecondaryFiles($fsfile);

## Get ref to Treex::PML::Document for files loaded with loadRelatedDocuments()
my @secondary_files = $fsfile->relatedDocuments();
my $id = $secondary_files[0]->[0];
my $fsfile_2 = $fsfile->referenceObjectHash()->{$id};

my @secondary_files_2 = $fsfile_2->relatedDocuments();
$id = $secondary_files_2[0]->[0];
my $fsfile_3 = $fsfile_2->referenceObjectHash()->{$id};

test_getSecondaryFilesRecursively($fsfile, $fsfile_2);

test_getPrimaryFiles($fsfile, $fsfile_2);

test_getPrimaryFilesRecursively($fsfile_2, $fsfile_3);