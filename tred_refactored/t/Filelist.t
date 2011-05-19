#!/usr/bin/env perl
# tests for Filelist package

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

use utf8;

use Test::More 'no_plan';
use Test::Exception;
#use Data::Dumper;

BEGIN {
  our $module_name = 'Filelist';
  use_ok($module_name);
}


binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


sub test_name {
  my ($file_list, $filelist_name_1) = @_;
  # check filelist name
  is($file_list->name(), $filelist_name_1, 
    "Filelist->name(): correct name of filelist");
    
  is(Filelist::name(), undef, 
    "Filelist::name(): return undef if not invoked on object");
  
}

sub test_rename {
  my ($file_list) = @_;
  # check that rename works
  my $filelist_new_name_1 = 'New First filelist';
  $file_list->rename($filelist_new_name_1);
  is($file_list->name(), $filelist_new_name_1, 
    "Filelist->rename(): rename filelist correctly");
}

sub test_filename_get {
  my ($file_list, $filelist_filename_1) = @_;
  # check filelist file name
  is($file_list->filename(), $filelist_filename_1, 
    "Filelist->filename(): return correct filename");
  
}

sub test_filename_set {
  my ($file_list) = @_;
  # save original file name
  my $orig_filename = $file_list->filename(); 
  
  # set filelist file name
  # and check that it works
  my $new_name = '_new_filelist_';
  $file_list->filename($new_name);
  is($file_list->filename(), $new_name, 
    "Filelist->filename(): filename changed successfully");
  
  # and change it back
  $file_list->filename($orig_filename);
}

sub test_dirname_unix {
  my ($file_list) = @_;
  
  # save original file name
  my $orig_filename = $file_list->filename(); 
  
  my %expected_dirname = (
    '/home/john/dir/filelist.fl'    => '/home/john/dir/',
    '/home/john/../dir/filelist.fl' => '/home/john/../dir/',
    'filelist.fl'                   => q{./},
    '/filelist.fl'                  => q{/},
  );
  
  local $^O = 'linux';
  foreach my $path (keys %expected_dirname) {
    $file_list->filename($path);
    is($file_list->dirname(), $expected_dirname{$path}, 
      "Filelist->dirname() works for path $path");
  }
  
  # and change it back
  $file_list->filename($orig_filename);
}

sub test_dirname_win32 {
  my ($file_list) = @_;
  
  # save original file name
  my $orig_filename = $file_list->filename(); 
  
  my %expected_dirname = (
    'c:\\Users\\john\\dir\\filelist.fl' => 'c:\\Users\\john\\dir\\',
    'filelist.fl'                       => q{.\\},
    '\\\\CmpName\\Folder\\filelist.fl'  => q{\\\\CmpName\\Folder\\},
  );
  
  local $^O = 'MSWin32';
  foreach my $path (keys %expected_dirname) {
    $file_list->filename($path);
    is($file_list->dirname(), $expected_dirname{$path}, 
      "Filelist->dirname() works for path $path");
  }
  
  # and change it back
  $file_list->filename($orig_filename);
}

sub test__filelist_path_without_dir_sep {
  my %expected_result = (
    '/home/john',       => {
                              q{/}    => 1,
                              q{\\}   => 1,
                            },
    'filelist.fl',      => {
                              q{/}    => q{},
                              q{\\}   => q{},
                            },
    'c:\\Users',        => {
                              q{/}    => q{},
                              q{\\}   => 1,
                            },
    '\\\\MyCmp\\Folder',=> {
                              q{/}    => q{},
                              q{\\}   => 1,
                            },
  );
  
  foreach my $path (keys %expected_result) {
    foreach my $dir_sep (keys %{$expected_result{$path}}){
      is(Filelist::_filelist_path_without_dir_sep($path, $dir_sep), $expected_result{$path}{$dir_sep}, 
        "_filelist_path_without_dir_sep(): directory separator identified correctly for path $path and dir separator $dir_sep");
    }
  }
}

sub test__filename_not_empty {
#  my ($filelist) = @_;

  # undefined filename
  my $filelist = Filelist->new('file list 1', undef);
  ok(!$filelist->_filename_not_empty(), "Filelist->_filename_not_empty(): undefined file name");
  
  $filelist = Filelist->new('file list 1', q{});
  ok(!$filelist->_filename_not_empty(), "Filelist->_filename_not_empty(): empty file name");
  
  $filelist = Filelist->new('file list 1', 'filelist_filename.fl');
  ok($filelist->_filename_not_empty(), "Filelist->_filename_not_empty(): file name not empty");
}

sub test_count {
  my ($filelist, $expected_count) = @_;
  is($filelist->count(), $expected_count,
    "Filelist->count(): correct count of items in filelist: $expected_count");
  
}

sub test_file_count {
  my ($filelist, $expected_count) = @_;
  is($filelist->file_count(), $expected_count, 
    "Filelist->file_count(): correct count of files in filelist: $expected_count");
}

sub test_load {
  my ($filelist) = @_;
  $filelist->load();
}

sub test_files {
  my ($file_list, $files_in_list_ref) = @_;
  my @got_files       = sort $file_list->files();
  my @expected_files  = sort map { $_->[0] } @{$files_in_list_ref};
  is_deeply(\@got_files, \@expected_files, 
    "Filelist->files(): return list of files");
}

sub test_files_ref {
  my ($file_list, $files_in_list_ref) = @_;
  
  is_deeply($file_list->files_ref(), $files_in_list_ref, 
    "Filelist->files_ref(): return internal files structure");
}

sub test_load_empty {
  my $filelist = Filelist->new('file list 1', q{});
  
  ok($filelist->load(), "Filelist->load(): load empty filelist");
  
  is($filelist->count(), 0, 
    "Filelist->count(): 0 if filelist empty");
  
  is($filelist->file_count(), 0, 
    "Filelist->file_count(): 0 if filelist empty");
  
  
}

sub test_list {
  my ($file_list, $list_of_patterns) = @_;
  my @got_list      = sort $file_list->list();
  my @expected_list = sort @{$list_of_patterns};
  
  is_deeply(\@got_list, \@expected_list, 
    "Filelist->list(): return list of patterns/items from filelist");
}

sub test_list_ref {
  my ($file_list, $list_of_patterns) = @_;
  my @got_list      = sort @{$file_list->list_ref()};
  my @expected_list = sort @{$list_of_patterns};
  
  is_deeply(\@got_list, \@expected_list, 
    "Filelist->list_ref(): return list of patterns/items from filelist");
}

sub test_expand {
  my ($file_list, $list_of_files) = @_;
  is($file_list->expand(), 1, 
    "Filelist->expand(): correct return value");
  
  my @got_list      = sort $file_list->files();
  my @expected_list = sort map { $_->[0] } @{$list_of_files};
  
  is_deeply(\@got_list, \@expected_list, 
    "Filelist->expand(): patterns expanded to files correctly");
}

sub test_current {
  my ($file_list) = @_;
  is($file_list->current(), undef, 
    "Filelist->current(): current file in file-list not defined at the beginning");
  
  my $new_current_filename = 'new_current_file';
  is($file_list->set_current($new_current_filename), $new_current_filename, 
    "Filelist->set_current(): correct return value");
    
  is($file_list->current(), $new_current_filename, 
    "Filelist->current(): set_current set the new current filename correctly");
  
}

sub test_filelist {
  my ($args_ref) = @_;
  
  
  my $file_list             = $args_ref->{file_list};
  my $filelist_name         = $args_ref->{filelist_name};
  my $filelist_filename     = $args_ref->{filelist_filename};
  my $patterns_in_list_ref  = $args_ref->{patterns_in_list};
  my $files_in_list_ref     = $args_ref->{files_in_list};
  
  
  
  test_load_empty();
  
  test_name($file_list, $filelist_name);

  test_rename($file_list);
  
  test_filename_get($file_list, $filelist_filename);
  
  test_filename_set($file_list);
  
  test__filelist_path_without_dir_sep();
  
  test_dirname_unix($file_list);
    
  test_dirname_win32($file_list);
  
  test__filename_not_empty();
  
  test_count($file_list, 0);
  
  test_file_count($file_list, 0);
  
  # empty list of files before loading
  test_files($file_list, ());
  
  # empty list of patterns before loading
  test_list($file_list, []);
  
  test_list_ref($file_list, []);
  
  ### here is the 
  test_load($file_list);
  
  # corect count of patterns
  test_count($file_list, scalar(@{$patterns_in_list_ref}));
  
  # correct count of files
  test_file_count($file_list, scalar(@{$files_in_list_ref}));
  
  # names of files
  test_files($file_list, $files_in_list_ref);
  # and reference to the list
  test_files_ref($file_list, $files_in_list_ref);
  
  # patterns
  test_list($file_list, $patterns_in_list_ref);
  # and reference to the list of them
  test_list_ref($file_list, $patterns_in_list_ref);
  
  test_expand($file_list, $files_in_list_ref);
  
  test_current($file_list);
  
}

#################
### Run Tests ###
#################

my $filelist_name_1 = 'First filelist';
my $filelist_filename_1 = 't/test_filelists/sample_1.fl';

my $filelist_name_2 = 'Second filelist';
my $filelist_filename_2 = 't/test_filelists/sample_2.fl';

my @patterns_in_list_1 = qw{
  sample0.a.gz
  sample1.a.gz
  sample2.a.gz
  sample3.a.gz
  sample0.a.gz
};

my @patterns_in_list_2 = qw{
  ../test_files/sample0.?.gz
  ../test_files/sample0.a.gz
};

my $files_in_list_1 = [
  ['sample0.a.gz', 0],
  ['sample1.a.gz', 1],
  ['sample2.a.gz', 2],
  ['sample3.a.gz', 3],
];

my $files_in_list_2 = [
  ['../test_files/sample0.a.gz', 0],
  ['../test_files/sample0.m.gz', 0],
  ['../test_files/sample0.t.gz', 0],
  ['../test_files/sample0.x.gz', 0],
];

# Create new filelist
my $file_list_1 = Filelist->new($filelist_name_1, $filelist_filename_1);
my $file_list_2 = Filelist->new($filelist_name_2, $filelist_filename_2);

note('Testing Filelist 1');

test_filelist({
                file_list           => $file_list_1, 
                filelist_name       => $filelist_name_1,
                filelist_filename   => $filelist_filename_1, 
                patterns_in_list    => \@patterns_in_list_1,
                files_in_list       => $files_in_list_1,
              });

note('Testing Filelist 2');              
test_filelist({
                file_list           => $file_list_2, 
                filelist_name       => $filelist_name_2,
                filelist_filename   => $filelist_filename_2, 
                patterns_in_list    => \@patterns_in_list_2,
                files_in_list       => $files_in_list_2,
              });

