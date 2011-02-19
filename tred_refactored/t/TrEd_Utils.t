#!/usr/bin/env perl
# tests for TrEd::Utils

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';#tests => 19;
use IO qw(File Handle);
use utf8;
use Encode;
use Data::Dumper;
use File::Spec;
use Cwd;

BEGIN {
  my $module_name = 'TrEd::Utils';
  our @subs = qw(
    fetch_from_win32_reg
    find_win_home
    loadStyleSheets
    init_stylesheet_paths
    read_stylesheets
    save_stylesheets
    removeStylesheetFile
    read_stylesheet_file
    save_stylesheet_file
    getStylesheetPatterns
    setStylesheetPatterns
    updateStylesheetMenu
    getStylesheetMenuList
    applyFileSuffix
    parseFileSuffix
    getNodeByNo
    applyWindowStylesheet
    set_fh_encoding
  );
  use_ok($module_name, @subs);
}

our @subs;
can_ok(__PACKAGE__, @subs);

# Test two windows functions
SKIP: {
#  eval { require Win32::TieRegistry };
#  skip "Win32::TieRegistry not installed", 3 if $@;
  skip "Not on Windows", 3 if $^O ne "MSWin32";
  
  like( fetch_from_win32_reg(q(HKEY_CURRENT_USER), q(Control Panel\Colors), q(Background)), 
        qr/^[\d]{1,3} [\d]{1,3} [\d]{1,3}$/, 
        "fetch_from_win32_reg(): successfully read value from registry");
  is( fetch_from_win32_reg('HKEY_CURRENT_USER', q(Software\NotExist), 'Nothing'), 
      undef, 
      "fetch_from_win32_reg(): return undef on failure");

  # Test if the environment variable is set properly
  find_win_home();
  ok(exists($ENV{'HOME'}) == 1, "find_win_home(): HOME Environment variable set successfully");
  
}


###################################
####### Test set_fh_encoding()
###################################
# Write $text to file $fname using $encoding 
# (set encoding by using set_fh_encoding() function)
sub _write_text_to_file {
  my ($fname, $encoding, $text) = @_;
  my $fh;
  open($fh, ">", $fname)
    or die "Could not open file $fname";
  set_fh_encoding($fh, $encoding);
  print $fh $text
    or die "Could not write to file $fname";;
  close($fh);
}

# Read text from file $fname (optionally using $encoding) 
sub _read_text_from_file {
  my ($fname, $encoding) = @_;
  my $fh;
  open($fh, "<", $fname)
    or die "Could not open file $fname";
  if(defined($encoding)){
    binmode($fh, $encoding);
  } else {
    binmode($fh);
  }
  my $file_bytes=<$fh>;
  close($fh);
  return $file_bytes;
}

my $utf8_test_string = "Příliš žluťoučký kůň úpěl ďábelské ódy\n";
my $cp1250_test_string = encode("cp1250", $utf8_test_string);
my $utf8_file_name = "utf8_file.txt";
my $cp1250_file_name = "cp1250_file.txt";

# Write strings to files using different encoding
_write_text_to_file($cp1250_file_name,  "cp1250", $utf8_test_string);
_write_text_to_file($utf8_file_name,    ":utf8",  $utf8_test_string);

# Read the strings from files
my $cp1250_bytes = _read_text_from_file($cp1250_file_name, undef);
my $utf8_bytes = _read_text_from_file($utf8_file_name, ":encoding(utf8)");

is($utf8_test_string,   $utf8_bytes,    "set_fh_encoding(): utf8 strings are equal");
is($cp1250_test_string, $cp1250_bytes,  "set_fh_encoding(): cp1250 strings are equal");

# Remove temporary files
unlink $utf8_file_name;
unlink $cp1250_file_name;

###################################
####### Test split_patterns()
###################################

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

# Runs 5 tests, test whether $hash_ref contains all the properties we have
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

my $stylesheet_ref = {};
($stylesheet_ref->{"hint"}, $stylesheet_ref->{"context"}, $stylesheet_ref->{"patterns"}) = TrEd::Utils::split_patterns($stylesheet_file);

# 5 tests
# context2 is here twice, because split_patterns does not allow more contexts, it overwrites previous value,
# but we need it for read_stylesheets_old()
_test_stylesheet_hash($stylesheet_ref, "split_patterns", "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);


####################################################
####### Test read_stylesheets_file()
####################################################
# write one stylesheet file and then try to read 
# written options...
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

####################################################
####### Test read_stylesheets_new()
####################################################
# 19 tests
sub _test_read_stylesheet_new {
  my ($function, $stylesheet_dir, $file_name, $file_name_2) = @_;
  my $gui_ref = {};
  my $opts_ref = {};
  
  my $ret_value = &{$function}($gui_ref, $stylesheet_dir, $opts_ref);
  
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$file_name}, "read_stylesheets_new", "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$file_name_2}, "read_stylesheets_new", "first_hints_2", "second_hints_2", "PML_A2_2", "PML_A2_2", \@patterns2);

  is($ret_value, 1, "read_stylesheets_new(): correct return value if successful");
  
  $ret_value = &{$function}($gui_ref, "not_existing_directory", $opts_ref);
  is($ret_value, 0, "read_stylesheets_new(): correct return value if directory not found");

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
  $ret_value = &{$function}($gui_ref, $stylesheet_dir, $opts_ref);
  
  is($ret_value, 1, "read_stylesheets_new(): correct return value if not overwriting");
  
  is($gui_ref->{"stylesheets"}{$file_name}{"context"}, "old_context",
      "read_stylesheets_new(): File 1: don't overwrite context if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name}{"hint"}, "old_hint",
      "read_stylesheets_new(): File 1: don't overwrite hints if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name}{"patterns"}, "old_patterns",
      "read_stylesheets_new(): File 1: don't overwrite patterns if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"context"}, "old_context",
      "read_stylesheets_new(): File 2: don't overwrite context if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"hint"}, "old_hint",
      "read_stylesheets_new(): File 2: don't overwrite hints if 'no_overwrite' is set");
      
  is($gui_ref->{"stylesheets"}{$file_name_2}{"patterns"}, "old_patterns",
      "read_stylesheets_new(): File 2: don't overwrite patterns if 'no_overwrite' is set");
}


SKIP: {
  my $orig_dir = getcwd();
  
  my $file_name = "stylesheet.file";
  my $file_name_2 = "stylesheet.file2";
  my $stylesheet_dir = File::Spec->catdir($orig_dir, "stylesheets");
  
  # skip tests, if the files could not be created
  skip "Could not create stylesheets", 19 if !(_create_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2));
  
  # 19 tests
  _test_read_stylesheet_new(\&TrEd::Utils::read_stylesheets_new, $stylesheet_dir, $file_name, $file_name_2);
  
  _clean_up_new_stylesheet_structure($stylesheet_dir, $file_name, $file_name_2);
  chdir $orig_dir;
}

####################################################
####### Test read_stylesheets_old()
####################################################
# 19 tests
sub _test_read_stylesheet_old {
  my ($function, $file_name, $stylesheet_name_1, $stylesheet_name_2) = @_;
  my $gui_ref = {};
  my $opts_ref = {};
  
  # test that function reads values from the specified file correctly
  my $ret_value = &{$function}($gui_ref, $file_name, $opts_ref);
  
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$stylesheet_name_1}, "read_stylesheets_old", "first_hints;", "second_hints;", "PML_A", "PML_A", \@patterns);
  # 5 tests
  _test_stylesheet_hash($gui_ref->{"stylesheets"}{$stylesheet_name_2}, "read_stylesheets_old", "first_hints_2", "second_hints_2", "PML_A2_1", "PML_A2_2", \@patterns2);

  is($ret_value, 1, "read_stylesheets_old(): correct return value if successful");
  
  $ret_value = &{$function}($gui_ref, "this_file_does_not_exist", $opts_ref);
  is($ret_value, 0, "read_stylesheets_old(): correct return value if the file is not found");

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
  $ret_value = &{$function}($gui_ref, $file_name, $opts_ref);
  
  is($ret_value, 1, "read_stylesheets_old(): correct return value if no_overwrite is in use");
  
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_1}{"context"}, 
        qr{old_context.*$context1.*$context2}ms,
        "read_stylesheets_old(): File 1: add context");
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_1}{"hint"}, 
        qr{old_hint.*first_hints.*second_hints}ms,
        "read_stylesheets_old(): File 1: add hint");

  my $patterns_in_stylesheet = grep(/old_patterns|rootstyle/, @{$gui_ref->{"stylesheets"}{$stylesheet_name_1}{"patterns"}});
  is($patterns_in_stylesheet, 2,
    "read_stylesheets_old(): File 1: add other patterns");

  
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_2}{"context"}, 
        qr{old_context.*$context2_1.*$context2_2}ms,
        "read_stylesheets_old(): File 2: add context");
      
  like( $gui_ref->{"stylesheets"}{$stylesheet_name_2}{"hint"}, 
        qr{old_hint.*first_hints_2.*second_hints_2}ms,
        "read_stylesheets_old(): File 2: add hint");
        
  $patterns_in_stylesheet = grep(/old_patterns|rootstyle/, @{$gui_ref->{"stylesheets"}{$stylesheet_name_1}{"patterns"}});
  is($patterns_in_stylesheet, 2,
    "read_stylesheets_old(): File 2: add other patterns");
}

SKIP: {
  my $file_name = "stylesheet.file";
  my $stylesheet_name_1 = "stylesheet_1";
  my $stylesheet_name_2 = "stylesheet_2";
  my $old_stylesheet_text = "stylesheet: $stylesheet_name_1 \n$stylesheet_file \nstylesheet: $stylesheet_name_2 \n$stylesheet_file_2\n";
  
  # skip tests, if the file could not be created
  skip "Could not create stylesheet file", 19 if !_create_stylesheet($file_name, $old_stylesheet_text);
  
  # 19 tests
  _test_read_stylesheet_old(\&TrEd::Utils::read_stylesheets_old, $file_name, $stylesheet_name_1, $stylesheet_name_2);

  unlink $file_name;
}

####################################################
####### Test read_stylesheets()
####################################################



