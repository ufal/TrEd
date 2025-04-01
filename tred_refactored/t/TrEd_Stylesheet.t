#!/usr/bin/env perl
# tests for TrEd::Stylesheet

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;
use IO qw(File Handle);
use utf8;
use Encode;
use Data::Dumper;
use File::Spec;
use Cwd;
use File::Copy; # need move

BEGIN {
  my $module_name = 'TrEd::Stylesheet';
  our @subs = qw(
      load_stylesheets
      init_stylesheet_paths
      read_stylesheets
      save_stylesheets
      remove_stylesheet_file
      read_stylesheet_file
      save_stylesheet_file
      get_stylesheet_patterns
      set_stylesheet_patterns
        
      STYLESHEET_FROM_FILE
      NEW_STYLESHEET
      DELETE_STYLESHEET
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);



### These are sample stylesheet files
### Used in multiple tests
my $hint1 = "<?   my \@first_hints;?>";
my $hint2 = "<?   my \@second_hints;\n?>";
my $context1 = "PML_T";
my $context2 = "PML_A";
my $root_style = "#{NodeLabel-skipempty:1}";
my $node_style = "<? '#{customparenthesis}' if \$\${is_parenthesis}\n?>";
my $style_style = "#{Node-width:7}#{Node-height:7}";
my @patterns = ($root_style, $node_style, $style_style);

my $stylesheet_file = <<END;
context: $context1
rootstyle: $root_style
hint:$hint1
node: $node_style
style:$style_style
context: $context2
hint:$hint2

END


my $hint2_1 = "<?   my \@first_hints_2;?>";
my $hint2_2 = "<?   my \@second_hints_2;\n?>";
my $context2_1 = "PML_A2_1";
my $context2_2 = "PML_A2_2";
my $root_style2 = "#root_style_2";
my $node_style2 = "<? second_node_style ?>";
my $style_style2 = "second_style";
my @patterns2 = ($root_style2, $node_style2, $style_style2);

my $stylesheet_file_2 = <<END;
context: $context2_1
rootstyle: $root_style2
hint:$hint2_1
node:$node_style2
style: $style_style2
context: $context2_2
hint:$hint2_2

END

sub _create_stylesheet {
  my ($file_name, $text) = @_;
  my $fh;
  
  open($fh, '>:utf8', $file_name)
    or return 0;
  
  print $fh $text
    or return 0;
  close($fh);
}

sub _create_new_stylesheet_structure {
  my ($stylesheet_dir, $file_name, $file_name_2) = @_;
  my $orig_dir = getcwd();
  mkdir $stylesheet_dir;
  chdir $stylesheet_dir;
  
  _create_stylesheet($file_name, $stylesheet_file);
  _create_stylesheet($file_name_2, $stylesheet_file_2);
  
}

sub _clean_up_new_stylesheet_structure {
  my ($stylesheet_dir, $file_name, $file_name_2) = @_;
  unlink $file_name;
  unlink $file_name_2;
  rmdir $stylesheet_dir;
}

# Runs 5 tests: test whether $hash_ref contains all the properties we have
sub _test_stylesheet_hash{
  my ($hash_ref, $fn_name, $hint1, $hint2, $context1, $context2, $patterns_ref) = @_;
  like($hash_ref->{"hint"}, 
      qr/$hint1/,
      "$fn_name(): catch the first hint");

  like($hash_ref->{"hint"}, 
      qr/$hint2/,
      "$fn_name(): catch the second hint");

  like($hash_ref->{"context"}, 
      qr/$context1/,
      "$fn_name(): catch the context (and overwrite if needed)");
  
  like($hash_ref->{"context"}, 
      qr/$context2/,
      "$fn_name(): catch the context (and overwrite if needed)");
  

  # We are optimistic
  my $all_patterns_found = 1;
  foreach my $pattern (@{$patterns_ref}){
    my $pattern_found = grep($pattern, @{$hash_ref->{"patterns"}});
    if($pattern_found){
      #ok
    } else {
      # one of the patterns not found
      $all_patterns_found = 0;
      last;
    }
  }

  ok($all_patterns_found, "$fn_name(): catch other patterns");
}

###################################
####### Test split_patterns()
###################################

sub test_split_patterns {
  my $stylesheet_ref = {};
  ($stylesheet_ref->{"hint"}, $stylesheet_ref->{"context"}, $stylesheet_ref->{"patterns"}) = TrEd::Stylesheet::split_patterns($stylesheet_file);
  
  # 5 tests
  # context2 is here twice, because split_patterns does not allow more contexts, it overwrites previous value,
  # but we need it for read_stylesheets_old()
  _test_stylesheet_hash($stylesheet_ref, "split_patterns", "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
}

####################################################
####### Test read_stylesheets_file()
####################################################
# write one stylesheet file and then try to read 
# written options...
sub test_read_stylesheets_file {
  SKIP: {
    
    my $file_name = "stylesheet.file";
    
    # skip tests, if the file could not be created
    skip "Could not create stylesheet file", 9 if !_create_stylesheet($file_name, $stylesheet_file);
    
    my $gui_ref = {};
    my $opts_ref = {};
    
    my $subhash_ref = read_stylesheet_file($gui_ref, $file_name, $opts_ref);
  
    # 5 tests
    _test_stylesheet_hash($subhash_ref, "read_stylesheet_file", "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
    
    # test also proper use of 'no_overwrite'
    $gui_ref->{"stylesheets"}->{$file_name} = {
      'context'   => 'old_context',
      'hint'      => 'old_hint',
      'patterns'  => 'old_patterns',
    };
    
    $opts_ref->{"no_overwrite"} = 1;
    $subhash_ref = read_stylesheet_file($gui_ref, $file_name, $opts_ref);
    
    ok(!defined($subhash_ref), "read_stylesheet_file(): return undef if not overwriting");
    
    is($gui_ref->{"stylesheets"}{$file_name}{"context"}, "old_context",
        "read_stylesheet_file(): don't overwrite context if 'no_overwrite' is set");
        
    is($gui_ref->{"stylesheets"}{$file_name}{"hint"}, "old_hint",
        "read_stylesheet_file(): don't overwrite hints if 'no_overwrite' is set");
        
    is($gui_ref->{"stylesheets"}{$file_name}{"patterns"}, "old_patterns",
        "read_stylesheet_file(): don't overwrite patterns if 'no_overwrite' is set");
    
    unlink $file_name;
  }
}
####################################################
####### Test read_stylesheets_new()
####################################################
# 18 tests
# since more functions call this one, it is convenient to test all its functionality within 
# these functions with one function 
sub _subtest_read_stylesheet_new {
  my ($function, $fn_name, $stylesheet_dir, $file_name, $file_name_2) = @_;
  my $gui_ref = {};
  my $opts_ref = {};
  
  my $ret_value = $function->($gui_ref, $stylesheet_dir, $opts_ref);
  
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$file_name}, $fn_name, "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$file_name_2}, $fn_name, "first_hints_2", "second_hints_2", "PML_A2_2", "PML_A2_2", \@patterns2);

  is($ret_value, 1, "$fn_name(): correct return value if successful");
  
  # test also proper use of 'no_overwrite'
  # here it means 'do not change already defined values' 
  $gui_ref->{"stylesheets"}{$file_name} = {
    'context'   => 'old_context',
    'hint'      => 'old_hint',
    'patterns'  => 'old_patterns',
  };
  $gui_ref->{"stylesheets"}{$file_name_2} = {
    'context'   => 'old_context',
    'hint'      => 'old_hint',
    'patterns'  => 'old_patterns',
  };
  
  $opts_ref->{"no_overwrite"} = 1;
  $ret_value = $function->($gui_ref, $stylesheet_dir, $opts_ref);
  
  is($ret_value, 1, "$fn_name(): correct return value if not overwriting");
  
  is($gui_ref->{"stylesheets"}{$file_name}{"context"}, "old_context",
      "$fn_name(): File 1: don't overwrite context if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name}{"hint"}, "old_hint",
      "$fn_name(): File 1: don't overwrite hints if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name}{"patterns"}, "old_patterns",
      "$fn_name(): File 1: don't overwrite patterns if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"context"}, "old_context",
      "$fn_name(): File 2: don't overwrite context if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"hint"}, "old_hint",
      "$fn_name(): File 2: don't overwrite hints if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"patterns"}, "old_patterns",
      "$fn_name(): File 2: don't overwrite patterns if 'no_overwrite' is set");
}

sub test_read_stylesheets_new {
  SKIP: {
    my $orig_dir = getcwd();
    
    my $file_name = "stylesheet.file";
    my $file_name_2 = "stylesheet.file2";
    my $stylesheet_dir = File::Spec->catdir($orig_dir, "stylesheets");
    my $fn_name = "_read_stylesheets_new";
    
    # skip tests, if the files could not be created
    skip "Could not create stylesheets '$file_name' and '$file_name_2' in the '$stylesheet_dir' directory.", 19 if !(_create_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2));
    
    # 18 tests
    _subtest_read_stylesheet_new(\&TrEd::Stylesheet::_read_stylesheets_new, $fn_name, $stylesheet_dir, $file_name, $file_name_2);
    
    my $ret_value = TrEd::Stylesheet::_read_stylesheets_new({}, "not_existing_directory", {});
    is($ret_value, 0, "_read_stylesheets_new(): correct return value if directory not found");
    
    
    _clean_up_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2);
    chdir $orig_dir;
  }
}
####################################################
####### Test read_stylesheets_old()
####################################################
# 18 tests
# since more functions call this one, it is convenient to test all its functionality within 
# these functions with one function 
sub _subtest_read_stylesheet_old {
  my ($function, $fn_name, $file_name, $stylesheet_name_1, $stylesheet_name_2) = @_;
  my $gui_ref = {};
  my $opts_ref = {};
  
  # test that function reads values from the specified file correctly
  my $ret_value = $function->($gui_ref, $file_name, $opts_ref);
  
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$stylesheet_name_1}, $fn_name, "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$stylesheet_name_2}, $fn_name, "first_hints_2", "second_hints_2", "PML_A2_1", "PML_A2_2", \@patterns2);

  is($ret_value, 1, "$fn_name(): correct return value if successful");
  
  # test also proper use of 'no_overwrite'
  # here it means 'add new values to the previously defined ones'
  $gui_ref->{"stylesheets"}{$stylesheet_name_1} = {
    'context'   => 'old_context',
    'hint'      => 'old_hint',
    'patterns'  => ['old_patterns'],
  };
  $gui_ref->{"stylesheets"}{$stylesheet_name_2} = {
    'context'   => 'old_context',
    'hint'      => 'old_hint',
    'patterns'  => ['old_patterns'],
  };
  
  $opts_ref->{"no_overwrite"} = 1;
  $ret_value = $function->($gui_ref, $file_name, $opts_ref);
  
  is($ret_value, 1, "$fn_name(): correct return value if no_overwrite is in use");
  
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_1}{"context"}, 
        qr{old_context.*$context1.*$context2}ms,
        "$fn_name(): File 1: add context");
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_1}{"hint"}, 
        qr{old_hint.*first_hints.*second_hints}ms,
        "$fn_name(): File 1: add hint");

  my $patterns_in_stylesheet = grep(/old_patterns|rootstyle/, @{$gui_ref->{"stylesheets"}{$stylesheet_name_1}{"patterns"}});
  is($patterns_in_stylesheet, 2,
    "$fn_name(): File 1: add other patterns");

  
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_2}{"context"}, 
        qr{old_context.*$context2_1.*$context2_2}ms,
        "$fn_name(): File 2: add context");
      
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_2}{"hint"}, 
        qr{old_hint.*first_hints_2.*second_hints_2}ms,
        "$fn_name(): File 2: add hint");
        
  $patterns_in_stylesheet = grep(/old_patterns|rootstyle/, @{$gui_ref->{"stylesheets"}{$stylesheet_name_1}{"patterns"}});
  is($patterns_in_stylesheet, 2,
    "$fn_name(): File 2: add other patterns");
}

sub test_read_stylesheets_old {
  SKIP: {
    my $file_name = "stylesheet.file";
    my $stylesheet_name_1 = "stylesheet_1";
    my $stylesheet_name_2 = "stylesheet_2";
    my $old_stylesheet_text = "stylesheet: $stylesheet_name_1 \n$stylesheet_file \nstylesheet: $stylesheet_name_2 \n$stylesheet_file_2\n";
    my $fn_name = "_read_stylesheets_old";
    # skip tests, if the file could not be created
    skip "Could not create stylesheet file '$file_name'.", 19 if !_create_stylesheet($file_name, $old_stylesheet_text);
    
    # 18 tests
    _subtest_read_stylesheet_old(\&TrEd::Stylesheet::_read_stylesheets_old, $fn_name, $file_name, $stylesheet_name_1, $stylesheet_name_2);
    
    my $ret_value = TrEd::Stylesheet::_read_stylesheets_old({}, "this_file_does_not_exist", {});
    is($ret_value, 0, "_read_stylesheets_old(): correct return value if the file is not found");
    
    unlink $file_name;
  }
}
####################################################
####### Test read_stylesheets()
####################################################
sub test_read_stylesheets {
  # calling the new stylesheet handling procedure
  # which means that we pass a directory as the second argument 
  # to the read_stylesheets function
  SKIP: {
    my $orig_dir = getcwd();
    
    my $file_name = "stylesheet.file1";
    my $file_name_2 = "stylesheet.file2";
    my $stylesheet_dir = File::Spec->catdir($orig_dir, "stylesheets");
    my $fn_name = "read_stylesheets";
    # skip tests, if the files could not be created
    skip "Could not create stylesheets dir", 19 if !(_create_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2));
    
    # 18 tests
    _subtest_read_stylesheet_new(\&TrEd::Stylesheet::read_stylesheets, $fn_name, $stylesheet_dir, $file_name, $file_name_2);
    
     my $ret_value = read_stylesheets({}, "this_dir_does_not_exist", {});
    ok(!defined($ret_value), "read_stylesheets(): correct return value if the directory does not exist");
    
    _clean_up_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2);
    chdir $orig_dir;
  }
  # calling the old stylesheet handling procedure
  # which means that a file is passed to read_stylesheets function
  # as the second argument
  SKIP: {
    my $file_name = "stylesheet.file";
    my $stylesheet_name_1 = "stylesheet_1";
    my $stylesheet_name_2 = "stylesheet_2";
    my $old_stylesheet_text = "stylesheet: $stylesheet_name_1 \n$stylesheet_file \nstylesheet: $stylesheet_name_2 \n$stylesheet_file_2\n";
    my $fn_name = "read_stylesheets";
    
    # skip tests, if the file could not be created
    skip "Could not create stylesheet file", 19 if !_create_stylesheet($file_name, $old_stylesheet_text);
    
    # 18 tests
    _subtest_read_stylesheet_old(\&TrEd::Stylesheet::read_stylesheets, $fn_name, $file_name, $stylesheet_name_1, $stylesheet_name_2);
    
    my $ret_value = read_stylesheets({}, "this_file_does_not_exist", {});
    ok(!defined($ret_value), "read_stylesheets(): correct return value if the file is not found");
    
    unlink $file_name;
  }
}
# Test that file $file_name contains all the strings from the \@contents array
sub _test_file_contents {
  my ($file_name, $contents_ref) = @_;
  my $fh;
  my $file_contents_ok = 1;
  if(open($fh, '<:encoding(utf8)', $file_name)){
    local $/; # read whole file into the string (should be used for small files only)
    my $file = <$fh>;
    foreach my $pattern (@{$contents_ref}){
      if($file =~ /\Q$pattern/){
        #ok
      } else {
        $file_contents_ok = 0;
        last;
      }
    }
    close($fh);
  } else {
    croak("The file '$file_name' could not be opened. Its content could not be checked.");
    $file_contents_ok = 0;
  }
  return $file_contents_ok;
}

####################################################
####### Test init_stylesheet_paths()
####################################################
# test conversion from old to new stylesheet
# and setting two exported variables
sub test_init_stylesheets_path {
  SKIP: {
    my $old_home = $ENV{'HOME'};
    # fake home directory
    $ENV{'HOME'} = getcwd();
    my $home = $ENV{'HOME'};
    my $tred_d_dir = File::Spec->catdir($home, ".tred.d");
    mkdir($tred_d_dir);
    
    my $new_stylesheet_dir = File::Spec->catdir($home, ".tred.d", "stylesheets");
    my $file_name = File::Spec->catfile($home, ".tred-stylesheets");
  
    my $stylesheet_name_1 = "stylesheet_1";
    my $stylesheet_name_2 = "stylesheet_2";
    my $old_stylesheet_text = "stylesheet: $stylesheet_name_1 \n$stylesheet_file \nstylesheet: $stylesheet_name_2 \n$stylesheet_file_2\n";
    
    my $fn_name = "init_stylesheet_paths";
    
    # skip tests, if the file could not be created
    skip "Could not create an old-style stylesheet file", 6 if !_create_stylesheet($file_name, $old_stylesheet_text);
    
    init_stylesheet_paths();
  
    # does the change from old to new stylesheets work?
    my $test_file_name1 = File::Spec->catfile($new_stylesheet_dir, $stylesheet_name_1);
    my $test_file_name2 = File::Spec->catfile($new_stylesheet_dir, $stylesheet_name_2);
    my @contents_of_test_file1 = ("first_hints;", "second_hints;", "rootstyle: #{NodeLabel-skipempty:1}", "context: PML_T");
    my @contents_of_test_file2 = ("first_hints_2;", "second_hints_2;", "rootstyle: #root_style_2", "context: PML_A2_1");
    
    ok(_test_file_contents($test_file_name1, \@contents_of_test_file1), "init_stylesheet_paths(): newly created style 1 ok");
    ok(_test_file_contents($test_file_name2, \@contents_of_test_file2), "init_stylesheet_paths(): newly created style 2 ok");
    
    my @stylesheet_paths = TrEd::Stylesheet::stylesheet_paths();  
    is($stylesheet_paths[0], $new_stylesheet_dir,
        "init_stylesheet_paths(): setting stylesheet_paths without custom paths");
    is(TrEd::Stylesheet::default_stylesheet_path(), $new_stylesheet_dir,
        "init_stylesheet_paths(): setting default_stylesheet_path without custom paths");
    
    my @custom_paths = ("/path/to/stylesheets_1", "/path/to/stylesheets_2", "/path/to/stylesheets_1");
    init_stylesheet_paths(\@custom_paths);
    @stylesheet_paths = TrEd::Stylesheet::stylesheet_paths();
    is($stylesheet_paths[0], "/path/to/stylesheets_1",
        "init_stylesheet_paths(): setting stylesheet_paths with custom paths");
    is(TrEd::Stylesheet::default_stylesheet_path(), "/path/to/stylesheets_1",
        "init_stylesheet_paths(): setting default_stylesheet_path with custom paths");
    
    # clean up created files and directories
    unlink $file_name;
    unlink File::Spec->catfile($new_stylesheet_dir, $stylesheet_name_1);
    unlink File::Spec->catfile($new_stylesheet_dir, $stylesheet_name_2);
    rmdir $new_stylesheet_dir;
    rmdir $tred_d_dir;
    $ENV{'HOME'} = $old_home;  
  }
}
####################################################
####### Test save_stylesheets()
####################################################
#### Possibility no 1: Old stylesheet, all the styles are in 
#### one file, create a dummy file and then write stylesheets 
#### into this file
sub test_1_save_stylesheets {
  SKIP: {
    my $fh;
    my $file_name = ".tred-stylesheets";
    
    my $stylesheet_1 = "style_1";
    my $stylesheet_2 = "style_2";
    my %gui;
    # create sample stylesheets in the memory
    $gui{"stylesheets"}{$stylesheet_1} = {
      "context"     =>    $context1,
      "hint"        =>    $hint1 . "\n" . $hint2,
      "patterns"    =>    [
                            "rootstyle: $root_style",
                            "node: $node_style",
                            "style: $style_style"
                          ]
    };
    
    $gui{"stylesheets"}{$stylesheet_2} = {
      "context"     =>    $context2_1,
      "hint"        =>    $hint2_1 . "\n"  . $hint2_2,
      "patterns"    =>    [
                            "rootstyle: $root_style2",
                            "node: $node_style2",
                            "style: $style_style2"
                          ]
    };
    
    # skip tests, if the file could not be opened for writing, can not simulate old-style stylesheets
    # create dummy stylesheet
    skip "Could not open an old-style stylesheet file '$file_name' for writing", 1 if !open($fh, '>:encoding(utf8)', $file_name);
    print $fh $stylesheet_file;
    close($fh);
  
    save_stylesheets(\%gui, File::Spec->catfile(getcwd(), $file_name));
  
    # new stylesheet should contain both stylesheets
    my $test_file_name1 = File::Spec->catfile(getcwd(), $file_name);
    my @contents_of_both_stylesheets = ("first_hints;", "second_hints;", "rootstyle: #{NodeLabel-skipempty:1}", "context: PML_T", 
                                        "first_hints_2;", "second_hints_2;", "rootstyle: #root_style_2", "context: PML_A2_1");
    ok(_test_file_contents($test_file_name1, \@contents_of_both_stylesheets), "save_stylesheets(): old-style stylesheet 1 & 2 written");
    
    
    # clean up created files and directories
    unlink $file_name;
  
  }
}
#### Possibility no 2: New stylesheet, each style has its own
#### file within the specified directory 
####
sub test_2_save_stylesheets {
  my $stylesheet_1 = "style_1";
  my $stylesheet_2 = "style_2";
  my %gui;
  $gui{"stylesheets"}{$stylesheet_1} = {
    "context"     =>    $context1,
    "hint"        =>    $hint1 . "\n" . $hint2,
    "patterns"    =>    [
                          "rootstyle: $root_style",
                          "node: $node_style",
                          "style: $style_style"
                        ]
  };
  
  $gui{"stylesheets"}{$stylesheet_2} = {
    "context"     =>    $context2_1,
    "hint"        =>    $hint2_1 . "\n"  . $hint2_2,
    "patterns"    =>    [
                          "rootstyle: $root_style2",
                          "node: $node_style2",
                          "style: $style_style2"
                        ]
  };
  my $where = ".tred-stylesheets";
  
  save_stylesheets(\%gui, File::Spec->catdir(getcwd(), $where));
  
  my $test_file_name_1 = File::Spec->catfile(getcwd(), $where, $stylesheet_1);
  my @contents_of_test_file1 = ("first_hints;", "second_hints;", "rootstyle: #{NodeLabel-skipempty:1}", "context: PML_T");
  ok(_test_file_contents($test_file_name_1, \@contents_of_test_file1), "save_stylesheets(): new-style stylesheet 1 written");
  
  my $test_file_name_2 = File::Spec->catfile(getcwd(), $where, $stylesheet_2);
  my @contents_of_test_file2 = ("first_hints_2;", "second_hints_2;", "rootstyle: #root_style_2", "context: PML_A2_1");
  ok(_test_file_contents($test_file_name_2, \@contents_of_test_file2), "save_stylesheets(): new-style stylesheet 2 written"); 
  
  # clean up created files and directories
  unlink $test_file_name_1;
  unlink $test_file_name_2;
  rmdir $where;
}
####################################################
####### Test save_stylesheet_file()
####################################################
sub test_save_stylesheet_file {
  my $stylesheet_1 = "style_1";
  
  my %gui;
  $gui{"stylesheets"}{$stylesheet_1} = {
    "context"     =>    $context1,
    "hint"        =>    $hint1 . "\n" . $hint2,
    "patterns"    =>    [
                          "rootstyle: $root_style",
                          "node: $node_style",
                          "style: $style_style"
                        ]
  };
  
  my $dir_name = ".tred-stylesheets";
  
  save_stylesheet_file(\%gui, $stylesheet_1, $dir_name);
  
  my $test_file_name_1 = File::Spec->catfile(getcwd(), $dir_name, $stylesheet_1);
  my @contents_of_test_file1 = ("first_hints;", "second_hints;", "rootstyle: #{NodeLabel-skipempty:1}", "context: PML_T");
  ok(_test_file_contents($test_file_name_1, \@contents_of_test_file1), "save_stylesheet_file(): new-style stylesheet written");
  
  # clean up created files and directories
  unlink $test_file_name_1;
  rmdir $dir_name;
}



####################################################
################## Run Tests #####################
####################################################

test_split_patterns();

test_read_stylesheets_file();
test_read_stylesheets_new();
test_read_stylesheets_old();
test_read_stylesheets();

test_init_stylesheets_path();

test_1_save_stylesheets();
test_2_save_stylesheets();

test_save_stylesheet_file();



done_testing();
