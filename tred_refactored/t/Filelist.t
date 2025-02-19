#!/usr/bin/env perl
# tests for Filelist package

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";

use utf8;

use Test::More;
use Test::Exception;
use Data::Dumper;

use Treex::PML::Document;
use List::Util;

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
  my ($file_list, $filelist_new_name) = @_;
  # check that rename works
  $file_list->rename($filelist_new_name);
  is($file_list->name(), $filelist_new_name,
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
  is($filelist->load(), 1,
    "Filelist->load(): correct return value");
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

sub test_file_at {
  my ($file_list, $files_in_list_ref) = @_;

  my @list_of_files = map { $_->[0] } @{$files_in_list_ref};
  my $index = 0;
  foreach my $filename (@list_of_files) {
    is($file_list->file_at($index), $filename,
      "Filelist->file_at(): return filename correctly");
    $index++;
  }

  # test negative and too big index
  is($file_list->file_at(-1), $list_of_files[-1],
      "Filelist->file_at(): handle negative index");

  is($file_list->file_at(scalar(@list_of_files)), undef,
      "Filelist->file_at(): index bigger than number of files");

}

sub test_position {
  my ($file_list, $files_in_list_ref) = @_;


  my @list_of_files = map { $_->[0] } @{$files_in_list_ref};
  my $index = 0;
  foreach my $filename (@list_of_files) {
    # test with filenames
    is($file_list->position($filename), $index,
      "Filelist->position(): return index of file $filename correctly");

    # test with Treex::PML::Documents
    my $document = Treex::PML::Document->create({ name => $filename });
    is($file_list->position($document), $index,
      "Filelist->position(): return index of Treex::PML::Document correctly");

    $index++;
  }

  # position of file that does not exist
  is($file_list->position('file_is_not_in_filelist'), -1,
      "Filelist->position(): return value for file that is not in the filelist");
}

sub test_loose_position_of_file {
  my ($file_list, $files_in_list_ref) = @_;


  my @list_of_files = map { $_->[0] } @{$files_in_list_ref};
  my $index = 0;
  foreach my $filename (@list_of_files) {
    # test with filenames
    my $filename_plus_suffix = $filename . '#012';
    is($file_list->loose_position_of_file($filename_plus_suffix), $index,
      "Filelist->loose_position_of_file(): return index of file $filename_plus_suffix correctly");


    # test with Treex::PML::Documents
    my $document = Treex::PML::Document->create({ name => $filename });
    is($file_list->loose_position_of_file($document), $index,
      "Filelist->loose_position_of_file(): return index of Treex::PML::Document correctly");

    # test relative filenames support
    #my ($volume,$directories,$filename) = File::Spec->splitpath( $filename );
    $filename = "t/test_filelists/$filename";
    is($file_list->loose_position_of_file($filename), $index,
      "Filelist->loose_position_of_file(): return index of file $filename correctly");



    $index++;
  }

  #TODO: pridaj tu nejake testy na rel path...
  # s!.*/([^/]\+)$!$1! -- use as filename

  # position of file that does not exist
  is($file_list->position('file_is_not_in_filelist'), -1,
      "Filelist->file_at(): return value for file that is not in the filelist");
}

sub test_file_pattern_index {
  my ($file_list, $files_in_list_ref) = @_;

  my @list_of_indices = map { $_->[1] } @{$files_in_list_ref};
  my $index = 0;
  foreach my $index_of_filenames_pattern (@list_of_indices) {
    # test with filenames
    is($file_list->file_pattern_index($index), $index_of_filenames_pattern,
      "Filelist->file_pattern_index(): return index of pattern for ${index}-th file correctly");
    $index++;
  }

  # test too big or negative file index
  is($file_list->file_pattern_index(scalar(@list_of_indices)), -1,
      "Filelist->file_pattern_index(): index of file too big");

  is($file_list->file_pattern_index(-1), -1,
      "Filelist->file_pattern_index(): negative index of file");

}

sub test_file_pattern {
  my ($file_list, $files_in_list_ref, $patterns_in_list_ref) = @_;

  my @list_of_indices = map { $_->[1] } @{$files_in_list_ref};
  my $index = 0;
  foreach my $index_of_filenames_pattern (@list_of_indices) {
    # test with filenames
    is($file_list->file_pattern($index), $patterns_in_list_ref->[$index_of_filenames_pattern],
      "Filelist->file_pattern(): return pattern for ${index}-th file correctly");
    $index++;
  }

  # test too big or negative file index
  is($file_list->file_pattern(scalar(@list_of_indices)), undef,
      "Filelist->file_pattern(): index of file too big");

  is($file_list->file_pattern(-1), undef,
      "Filelist->file_pattern(): negative index of file");

}

sub test_add {
  my ($file_list, $files_in_list_ref, $patterns_in_list_ref, $new_patterns_ref) = @_;

  my %old_patterns;
  @old_patterns{ @{$patterns_in_list_ref} } = ();

  my @non_duplicate_new_patterns = grep { not exists $old_patterns{$_} } @{$new_patterns_ref};

  is($file_list->add(0, @{$new_patterns_ref}), 1,
    "Filelist->add_arrayref(): correct return value");

  # test that patterns were added
  my @got_list      = $file_list->list();
  my @expected_list = (@non_duplicate_new_patterns, @{$patterns_in_list_ref});
  is_deeply(\@got_list, \@expected_list,
    "Filelist->add(): new non-duplicate patterns added");

  # and also that filenames were added
  my @list_of_files = map { $_->[0] } @{$files_in_list_ref};
  my @got_list_of_files = $file_list->files();
  my @expected_list_of_files = (@non_duplicate_new_patterns, @list_of_files);
  is_deeply(\@got_list_of_files, \@expected_list_of_files,
    "Filelist->add(): new files added");

  return @non_duplicate_new_patterns;
}


sub test_add_arrayref {
  my ($file_list, $files_in_list_ref, $patterns_in_list_ref, $new_patterns_ref) = @_;

  my %old_patterns;
  @old_patterns{ @{$patterns_in_list_ref} } = ();

  my @non_duplicate_new_patterns = grep { not exists $old_patterns{$_} } @{$new_patterns_ref};

  is($file_list->add_arrayref(0, $new_patterns_ref), 1,
    "Filelist->add_arrayref(): correct return value");

  # test that patterns were added
  my @got_list      = $file_list->list();
  my @expected_list = (@non_duplicate_new_patterns, @{$patterns_in_list_ref});
  is_deeply(\@got_list, \@expected_list,
    "Filelist->add_arrayref(): new non-duplicate patterns added");

  # and also that filenames were added
  my @list_of_files = map { $_->[0] } @{$files_in_list_ref};
  my @got_list_of_files = $file_list->files();
  my @expected_list_of_files = (@non_duplicate_new_patterns, @list_of_files);
  is_deeply(\@got_list_of_files, \@expected_list_of_files,
    "Filelist->add_arrayref(): new files added");

  return @non_duplicate_new_patterns;
}

sub unique {
  my %seen;
  return grep {!$seen{$_}++} @_;
}

sub test_remove {
  my ($file_list, $files_in_list_ref, $patterns_in_list_ref, $rm_patterns_ref) = @_;

  $file_list->remove(@{$rm_patterns_ref});

  # test that patterns were removed
  my @got_list      = $file_list->list();
  my @expected_list = @{$patterns_in_list_ref};
  is_deeply(\@got_list, \@expected_list,
    "Filelist->remove(): patterns removed successfully");

  # and also that filenames were removed
  my @got_list_of_files = $file_list->files();
  my @expected_list_of_files = map { $_->[0] } @{$files_in_list_ref};;
  is_deeply(\@got_list_of_files, \@expected_list_of_files,
    "Filelist->remove(): files removed successfully");

  # also test for empty removes
  my @patterns = undef;
  is($file_list->remove(@patterns), undef,
    "Filelist->remove(): return undef if no files were specified");
  is_deeply(\@got_list, \@expected_list,
    "Filelist->remove(): don't modify the filelist if no files were specified");
  is_deeply(\@got_list_of_files, \@expected_list_of_files,
    "Filelist->remove(): don't modify the filelist if no files were specified");
}

# this test won't work if it would be run before remove test, which gets rid of
# duplicate pattern entries
sub test_find_pattern {
  my ($file_list, $patterns_in_list_ref) = @_;

  my $i = 0;
  foreach my $pattern (@{$patterns_in_list_ref}) {
    is($file_list->find_pattern($pattern), $i,
      "Filelist->find_pattern(): correct index for pattern $pattern");
    $i++;
  }
}

sub test_clear {
  my ($file_list) = @_;

  $file_list->clear();

  is_deeply($file_list->list_ref(), [],
    "Filelist->clear(): empty list of patterns");

  my @files = $file_list->files();
  is_deeply(\@files, [],
    "Filelist->clear(): empty list of files");

}

sub test_save {
  my ($file_list, $files_in_list_ref, $patterns_in_list_ref, $new_patterns_ref) = @_;

  my $new_fl_name = 'new_filelist.fl';

  $file_list->filename($new_fl_name);

  is($file_list->save(), 1,
    "Filelist->save(): correct return value");

  $file_list = Filelist->new('new_filelist', $new_fl_name);
  $file_list->load();

  my @expected_list = (@{$new_patterns_ref}, @{$patterns_in_list_ref});

  is_deeply($file_list->list_ref(), \@expected_list,
    "Filelist->save(): saved all the patterns");

  unlink($new_fl_name);
}

sub test_filelist {
  my ($args_ref) = @_;

  my $filelist_name         = $args_ref->{filelist_name};
  my $filelist_filename     = $args_ref->{filelist_filename};
  my $patterns_in_list_ref  = $args_ref->{patterns_in_list};
  my $files_in_list_ref     = $args_ref->{files_in_list};
  my $new_patterns_ref      = $args_ref->{new_patterns};
  my $filelist_name_in      = $args_ref->{filelist_name_in};

  my $file_list = Filelist->new($filelist_name, $filelist_filename);

  test_load_empty();

  test_name($file_list, $filelist_name);

  my $filelist_new_name = 'New First filelist';
  test_rename($file_list, $filelist_new_name);

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

  ### here the load happens
  test_load($file_list);

  test_name($file_list, $filelist_new_name);

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

  test_file_at($file_list, $files_in_list_ref);

  test_position($file_list, $files_in_list_ref);

  test_loose_position_of_file($file_list, $files_in_list_ref);

  test_file_pattern_index($file_list, $files_in_list_ref);

  test_file_pattern($file_list, $files_in_list_ref, $patterns_in_list_ref);

  my @added_patterns = test_add($file_list, $files_in_list_ref, $patterns_in_list_ref, $new_patterns_ref);

  # 'remove' function also uniques patterns, so we need to uniq our patterns, too
  @{$patterns_in_list_ref} = unique(@{$patterns_in_list_ref});

  test_remove($file_list, $files_in_list_ref, $patterns_in_list_ref, \@added_patterns);

  test_find_pattern($file_list, $patterns_in_list_ref);

  @added_patterns = test_add_arrayref($file_list, $files_in_list_ref, $patterns_in_list_ref, $new_patterns_ref);

  test_save($file_list, $files_in_list_ref, $patterns_in_list_ref, \@added_patterns);

  # last test
  test_clear($file_list);

  # test loading filelist's name if no name is defined
  $file_list = Filelist->new(undef, $filelist_filename);
  $file_list->load();
  test_name($file_list, $filelist_name_in);

}

#################
### Run Tests ###
#################

my $filelist_name_1 = 'First filelist';
my $filelist_name_in_1 = 'PDT 2.0 a-layer sample';
my $filelist_filename_1 = 't/test_filelists/sample_1.fl';

my $filelist_name_2 = 'Second filelist';
my $filelist_name_in_2 = 'PDT 2.0 a-layer glob sample';
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
  ['../test_files/sample0.w.gz', 0],
  ['../test_files/sample0.x.gz', 0],
];

my @new_patterns = qw{
    new_pattern_1.gz
    new_pattern_2.gz
    sample0.a.gz
    ../test_files/sample0.a.gz
  };

note('Testing Filelist 1');

test_filelist({
                filelist_name       => $filelist_name_1,
                filelist_name_in    => $filelist_name_in_1,
                filelist_filename   => $filelist_filename_1,
                patterns_in_list    => \@patterns_in_list_1,
                files_in_list       => $files_in_list_1,
                new_patterns        => \@new_patterns,
              });

note('Testing Filelist 2');
test_filelist({
                filelist_name       => $filelist_name_2,
                filelist_name_in    => $filelist_name_in_2,
                filelist_filename   => $filelist_filename_2,
                patterns_in_list    => \@patterns_in_list_2,
                files_in_list       => $files_in_list_2,
                new_patterns        => \@new_patterns,
              });

#TODO:     entry_path

done_testing();