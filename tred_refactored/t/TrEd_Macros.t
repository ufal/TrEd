#!/usr/bin/env perl
# tests for TrEd::Macros

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';
use Test::Exception;
use Data::Dumper;
use List::Util qw( first );
use File::Spec;
use Cwd;
use Encode;
use utf8;
use TrEd::Config;

BEGIN {
  my $module_name = 'TrEd::Macros';
  our @subs = qw(
    read_macros
    do_eval_macro
    do_eval_hook
    macro_variable
    get_macro_variable
    set_macro_variable
    get_contexts
  );
  use_ok($module_name, @subs);
}

binmode(STDOUT, ':utf8');
#binmode(STDERR, ':utf8');

our @subs;
can_ok(__PACKAGE__, @subs);

# write tests
# principial question: should we or should we not test 'private' methods? 
# So these are tests for private methods

############################################
#### Symbols define, undefine, is_defined...
############################################

my $def_name = "special_name";
my $def_value = "special_value";

## Test define_symbol()
is(TrEd::Macros::define_symbol($def_name, $def_value), $def_value, 
    "define_symbol(): return value ok");
is($TrEd::Macros::defines{$def_name}, $def_value, 
    "define_symbol(): defines symbol");


## Test is_defined()
ok(TrEd::Macros::is_defined($def_name), "is_defined(): correctly reports a symbol, that is defined");
ok(!TrEd::Macros::is_defined("not_exist"), "is_defined(): correctly reports a symbol, that is not defined");

## Test undefine_symbol()
is(TrEd::Macros::undefine_symbol($def_name), $def_value,
    "undefine_symbol(): return value ok");

ok(!exists($TrEd::Macros::defines{$def_name}), "undefine_symbol(): undefines symbol");
ok(!TrEd::Macros::is_defined($def_name), "is_defined(): correctly reports a symbol, that is not defined");

##
## Test of public function get_contexts()
##
sub _test_get_contexts {
  my ($expected_contexts_ref) = @_;
  my @contexts = sort(TrEd::Macros::get_contexts());
  my @sorted_expected = sort(@{$expected_contexts_ref});
  is_deeply(\@contexts, \@sorted_expected,
            "get_contexts(): return contexts for key bindings");
}

############################################
#### Utility functions
############################################
my %key_normalization = (
  "Ctrl + Alt + Del"  => "CTRL + ALT + Del",
  "Ctrl-Alt+Del"      => "CTRL+ALT+Del",
  "Ctrl+X"            => "CTRL+X",
  "Meta-č"            => "META+č",
  "Alt->"             => "ALT+>"
);

foreach my $key (keys(%key_normalization)){
  is(TrEd::Macros::_normalize_key($key), $key_normalization{$key},
      "_normalize_key(): key normalization ok");
}

my $macro = sub {
  print "This is a macro\n";
};
my $another_macro = "my_context->macro";
my $another_macro_2 = "macro_2";

my $context = "my_context";
my $another_context = "my_context_2";
my $context_copy = "copy_of_$context";

my %macro_normalization = (
  $another_macro    => $another_macro,
  $another_macro_2  => $context . '->' . $another_macro_2,
  "ma -> cro"       => $context . '->' . "ma -> cro", #TODO: I am not really sure if it should be like that, but we are testing current status quo 
);

is(TrEd::Macros::_normalize_macro($context, $macro), $macro,
      "_normalize_macro(): normalize macro reference properly");

foreach my $macro_cand (keys(%macro_normalization)){
  is(TrEd::Macros::_normalize_macro($context, $macro_cand), $macro_normalization{$macro_cand},
      "_normalize_macro(): normalize macro name properly");
}

############################################
#### Key binding
############################################
{
  my @keys = keys(%key_normalization);
  
  # Return undef if macro is not defined
  ok(!defined(TrEd::Macros::bind_key($context, $keys[0])), "bind_key(): return undef if there is no macro argument passed to function");

  # Try to set some bindings
  TrEd::Macros::bind_key($context, $keys[0] => $macro);
  TrEd::Macros::bind_key($another_context, $keys[3], $another_macro);
  
  # Test existence of those bindings
  is(TrEd::Macros::get_binding_for_key($context, $keys[0]), $macro,
      "bind_key() first way of setting the binding and get_binding_for_key() found it");
  is(TrEd::Macros::get_binding_for_key($another_context, $keys[3]), $another_macro,
      "bind_key() second way of setting the binding and get_binding_for_key() found it");
  
  # Overwrite old binding for key $keys[3]
  TrEd::Macros::bind_key($another_context, $keys[3], $another_macro_2);
  
  # Test that overwriting old binding works
  is(TrEd::Macros::get_binding_for_key($another_context, $keys[3]), $another_context.'->'.$another_macro_2,
      "bind_key() overwrite old binding and get_binding_for_key() found it");
  
  # Test get_contexts() 
  my @expected_contexts = ($context, $another_context);
  _test_get_contexts(\@expected_contexts);
  
  # Test also not existing context and key
  ok(!defined(TrEd::Macros::get_binding_for_key("not_existing_context", $keys[3])), "get_binding_for_key() returns undef on unknown context");
  ok(!defined(TrEd::Macros::get_binding_for_key($another_context, "not_existing_key")), "get_binding_for_key() returns undef on unknnown key");
  
  # Unbind key, test it...
  my $delete = 1;
  is(TrEd::Macros::unbind_key($context, $keys[0], $delete), $macro, 
      "unbind_key(): return value ok");
  ok(!defined(TrEd::Macros::get_binding_for_key($context, $keys[0])), "unbind_key() discarded binding and get_binding_for_key() correctly didn't find it");
  
  # Test also 'soft' unbinding, just undef without delete
  TrEd::Macros::unbind_key($another_context, $keys[3]);
  ok(!defined(TrEd::Macros::get_binding_for_key($another_context, $keys[3])), "unbind_key() discarded binding and get_binding_for_key() correctly didn't find it");
  ok(exists($TrEd::Macros::keyBindings{$another_context}->{TrEd::Macros::_normalize_key($keys[3])}), "unbind_key() set binding to undef, not deleting it");
  
  # And after that, delete binding completely
  TrEd::Macros::unbind_key($another_context, $keys[3], $delete);
  ok(!exists($TrEd::Macros::keyBindings{$another_context}->{TrEd::Macros::_normalize_key($keys[3])}), "unbind_key() deleting the value");
  
  
  my %key_bindings_before_unbind = (
    $key_normalization{$keys[0]} => $macro,
    $key_normalization{$keys[3]} => $macro,
    $key_normalization{$keys[2]} => $another_macro,
  );
  
  my %key_bindings_after_unbind = (
    $key_normalization{$keys[0]} => undef,
    $key_normalization{$keys[3]} => undef,
    $key_normalization{$keys[2]} => $another_macro,
  );
  
  # Bind 2 key combinations with the same macro
  TrEd::Macros::bind_key($context, $keys[0] => $macro);
  TrEd::Macros::bind_key($context, $keys[3], $macro);
  TrEd::Macros::bind_key($context, $keys[2], $another_macro);
  
  
  # Test get_bindings_for_macro function
  my @expected_bindings = sort($key_normalization{$keys[3]}, $key_normalization{$keys[0]});
  my @bindings = sort(TrEd::Macros::get_bindings_for_macro($context, $macro));
  my $first_binding = TrEd::Macros::get_bindings_for_macro($context, $macro);
  
  
  is_deeply(\@bindings, \@expected_bindings,
            "get_bindings_for_macro(): in array context");
  ok((($first_binding eq $expected_bindings[0]) || ($first_binding eq $expected_bindings[1])), "get_bindings_for_macro(): scalar contex");
  
  # Test get_keybindings function -- when the keybindings are not empty
  my %keybindings = TrEd::Macros::get_keybindings($context);
  is_deeply(\%keybindings, \%key_bindings_before_unbind,
                "get_keybindings(): returns hash of key bindings");
  
  
  # Unbind the macro
  TrEd::Macros::unbind_macro($context, $macro);
  
  
  # Test that it really undefs macro
  is_deeply($TrEd::Macros::keyBindings{$context}, \%key_bindings_after_unbind, 
            "unbind_macro(): undefine macro");
  
  # Test get_keybindings function -- when the keybindings exist, but macros are undefined
  %keybindings = TrEd::Macros::get_keybindings($context);
  is_deeply(\%keybindings, \%key_bindings_after_unbind,
                "get_keybindings(): returns hash of undefined key bindings");
  
  # Bind 2 key combinations with the same macro, again
  TrEd::Macros::bind_key($context, $keys[0] => $macro);
  TrEd::Macros::bind_key($context, $keys[3], $macro);
  
  # Test copying key bindings between contexts
  is_deeply(TrEd::Macros::copy_key_bindings($context, $context_copy), \%key_bindings_before_unbind,
            "copy_key_bindings(): correct return value if context exists");
  
  # Test that new context exists
  _test_get_contexts([$context, $context_copy, $another_context]);
  
  # Test that all the keybindings were copied
  my %source_keybindings = TrEd::Macros::get_keybindings($context);
  my %dest_keybindings = TrEd::Macros::get_keybindings($context_copy);
  is_deeply(\%source_keybindings, \%dest_keybindings,
                "copy_key_bindings(): everything got copied");
  
  # Test copying key bindings with context that does not exist
  ok(!defined(TrEd::Macros::copy_key_bindings("not_existing_context", $context_copy)), "copy_key_bindings(): correct return value if context does not exist");
  
  my %key_bindings_after_delete = (
    $key_normalization{$keys[2]} => $another_macro
  );
  
  # Remove bindings for both key combinations (delete it this time)
  TrEd::Macros::unbind_macro($context, $macro, $delete);
  is_deeply($TrEd::Macros::keyBindings{$context}, \%key_bindings_after_delete, 
            "unbind_macro(): delete macro bindings");
  
  # Test get_keybindings function -- when the keybindings does not exist
  %keybindings = TrEd::Macros::get_keybindings($context);
  is_deeply(\%keybindings, \%key_bindings_after_delete,
                "get_keybindings(): empty hash");
  
  # Test get_bindings_for_macro with empty keybindings hash
  @bindings = TrEd::Macros::get_bindings_for_macro($context, $macro);
  is_deeply(\@bindings, [],
            "get_bindings_for_macro(): reports empty bindings correctly");
  
  # Test get_keybindings function -- when the keybindings does not exist
  ok(!defined(TrEd::Macros::get_keybindings("not_xisting_context")), "get_keybindings(): return undef if context does not exist");
  
  # Test unbinding when context does not exist
  ok(!defined(TrEd::Macros::unbind_key("not_xisting_context", "key", $delete)), "unbind_key(): return undef if context does not exist");
  
  # Test unbinding when context does not exist
  ok(!defined(TrEd::Macros::unbind_macro("not_xisting_context", "macro", $delete)), "unbind_macro(): return undef if context does not exist");
  
  # Test get_bindings_for_macro when context does not exist
  my @not_exist_context_result = TrEd::Macros::get_bindings_for_macro("not_xisting_context", $macro);
  my @empty_array = ();
  is(@not_exist_context_result, @empty_array,
      "get_bindings_for_macro(): return empty array if context does not exist");
  
}

############################################
#### Menu binding
############################################

{
  my $label = "ref_macro_menu_label";
  my $macro_overwrite = "overwritten->macro";
  my $another_label = "str_macro_menu_label";
  my $another_label_2 = "str_macro_2_menu_label";
  my $menu_only_context = "menu_context";
  
  # Empty label
  ok(!defined(TrEd::Macros::add_to_menu($context, "", $macro)), "add_to_menu(): return undef if the label is empty");
  
  # Add new menu items
  TrEd::Macros::add_to_menu($context, $label, $macro);
  my %expected_menu_items = (
    $label  =>  [$macro, undef],
  );
  my %got_menu_items = TrEd::Macros::get_menuitems($context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "add_to_menu(): new label added; get_menuitems(): reflects this change");
  
  # Test overwriting previous 
  TrEd::Macros::add_to_menu($context, $label, $macro_overwrite);
  %expected_menu_items = (
    $label  =>  [$macro_overwrite, undef],
  );
  %got_menu_items = TrEd::Macros::get_menuitems($context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "add_to_menu(): overwrite existing label; get_menuitems(): reflects this change");
  
  # Add two labels for the same macro
  TrEd::Macros::add_to_menu($another_context, $another_label, $another_macro);
  TrEd::Macros::add_to_menu($another_context, $another_label_2, $another_macro);
  
  # Check that writing another context has no effect on original context 
  %got_menu_items = TrEd::Macros::get_menuitems($context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "get_menuitems(): writing for another context does not affect other contexts");
  
  # Test whether the new context was written correctly
  %expected_menu_items = (
    $another_label    => [$another_macro, undef],
    $another_label_2  => [$another_macro, undef],
  );
  %got_menu_items = TrEd::Macros::get_menuitems($another_context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "add_to_menu(): using another context; get_menuitems(): reflect it");
  
  # Test that get_contexts unifies bindings correctly
  TrEd::Macros::add_to_menu($menu_only_context, $label, $macro);
  _test_get_contexts([$context, $another_context, $context_copy, $menu_only_context]);
  
  # Test not existing context
  ok(!defined(TrEd::Macros::get_menuitems("not_existing_context")), "get_menuitems(): correct return value for context that does not exist");
  
  # Test copying menu bindings with context that does not exist
  ok(!defined(TrEd::Macros::copy_menu_bindings("not_existing_context", $menu_only_context)), "copy_menu_bindings(): return undef if context does not exist");
  # original context is still there and untouched
  %got_menu_items = TrEd::Macros::get_menuitems($menu_only_context);
  %expected_menu_items = (
    $label  =>  [$macro, undef],
  );
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "get_menuitems(): writing for another context does not affect other contexts");
  
  # Test copying menu bindings
  TrEd::Macros::copy_menu_bindings($another_context, $menu_only_context);
  %expected_menu_items = (
    $another_label    => [$another_macro, undef],
    $another_label_2  => [$another_macro, undef],
    $label            => [$macro, undef],
  );
  
  %got_menu_items = TrEd::Macros::get_menuitems($menu_only_context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "copy_menu_bindings(): copy from one context to another; get_menuitems(): reflect it");
  
  # Test get_macro_for_menu
  is_deeply(TrEd::Macros::get_macro_for_menu($menu_only_context, $label), [$macro, undef], "get_macro_for_menu(): find correct ref macro");
  is_deeply(TrEd::Macros::get_macro_for_menu($another_context, $another_label), [$another_macro, undef], "get_macro_for_menu(): find correct string macro");
  ok(!defined(TrEd::Macros::get_macro_for_menu("not_existing_context", $another_label)), "get_macro_for_menu(): return undef when asked for unknown context");

  # Test get_menus_for_macro in array context
  my @got_labels = sort(TrEd::Macros::get_menus_for_macro($menu_only_context, $another_macro));
  my @expected_labels = sort($another_label, $another_label_2);
  is_deeply(\@got_labels, \@expected_labels,
            "get_menus_for_macro(): return all labels for macro in array context");
  
  # Test get_menus_for_macro in scalar context
  my $menus = TrEd::Macros::get_menus_for_macro($menu_only_context, $another_macro);
  ok($menus eq $another_label || $menus eq $another_label_2, "get_menus_for_macro(): return one of the labels for macro in scalar context");
  
  
  # Test get_menus_for_macro if context does not exist
  my @not_exist_context_result = TrEd::Macros::get_menus_for_macro("not_existing_context", $another_macro);
  my @empty_arr = ();
  is_deeply(\@not_exist_context_result, \@empty_arr,
              "get_menus_for_macro(): return undef if the context is unknown");
            
  # Test remove_from_menu with existing item
  my $removed_arr_ref = TrEd::Macros::remove_from_menu($another_context, $another_label);
  is($removed_arr_ref->[0], $another_macro, 
      "remove_from_menu(): correct return value");
  ok(!defined($removed_arr_ref->[1]), "remove_from_menu(): correct return value");
  
  ok(!defined(TrEd::Macros::get_macro_for_menu($another_context, $another_label)), "remove_from_menu(): removed from menu & get_macro_for_menu() reflects this change");
  
  # Test remove_from_menu with not existing context
  $removed_arr_ref = TrEd::Macros::remove_from_menu("not_existing_context", $another_label);
  ok(!defined($removed_arr_ref), "remove_from_menu(): correct return value -- context does not exist");
  
  # Test remove_from_menu with not existing label
  $removed_arr_ref = TrEd::Macros::remove_from_menu($another_context, "not_existing_label");
  ok(!defined($removed_arr_ref), "remove_from_menu(): correct return value -- label does not exist");
  
  # Test remove_from_menu_macro($context, $macro) with context that does not exist
  ok(!defined(TrEd::Macros::remove_from_menu_macro("not_existing_context", $another_macro)), "remove_from_menu_macro(): return undef when not existing context is passed to the function");
  
  # Test remove_from_menu_macro($context, $macro)
  TrEd::Macros::remove_from_menu_macro($menu_only_context, $another_macro);
  %expected_menu_items = (
    $label            => [$macro, undef],
  );
    
  %got_menu_items = TrEd::Macros::get_menuitems($menu_only_context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "remove_from_menu_macro(): remove all labels bound to macro; get_menuitems(): reflect it");
  
}

sub _test_macros_contain {
  my ($patterns_ref) = @_;
  # for every pattern, test that macros contain desired string and 
  # report if the test was successful
  foreach my $pattern (keys(%$patterns_ref)){
    my $macro_found = first { $_ =~ /$pattern/ } @TrEd::Macros::macros;
    ok($macro_found, qq/$patterns_ref->{$pattern}/);
  }
}

sub _test_macros_dont_contain {
  my ($patterns_ref) = @_;
  # for every pattern, test that macros contain desired string and 
  # report if the test was successful
  foreach my $pattern (keys(%$patterns_ref)){
    my $macro_found = first { $_ =~ /$pattern/ } @TrEd::Macros::macros;
    ok(!defined($macro_found), qq/$patterns_ref->{$pattern}/);
  }
}

sub _test_macro_file {
  my ($macro_file_name, $should_contain_ref, $should_not_contain_ref, $encoding) = @_;
  open(my $macro_fh, '<', $macro_file_name) or 
    die("Could not open $macro_file_name\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # load macro from new macro file
  TrEd::Macros::preprocess($macro_fh, $macro_file_name, \@TrEd::Macros::macros, \@TrEd::Macros::contexts);
  # check if it contains what it should 
  if(defined($should_contain_ref) && ref($should_contain_ref)) {
    _test_macros_contain($should_contain_ref);
  }
  # and that it does not contain what it should not...
  if(defined($should_not_contain_ref) && ref($should_not_contain_ref)) {
    _test_macros_dont_contain($should_not_contain_ref);
  }
  close($macro_fh);
}

sub _test_macro_bindings { 
  my ($arg_ref) = @_;
  my $key_combination = $arg_ref->{"key_combination"};
  my $menu_item = $arg_ref->{"menu_item"};
  my $context = $arg_ref->{"context"};
  my $macro_name = $arg_ref->{"macro_name"};
  
  $macro_name = "$context->$macro_name";
  is(TrEd::Macros::get_binding_for_key($context, $key_combination), $macro_name, 
      "preprocess() -- key binding created");
  my $macro_name_ref = TrEd::Macros::get_macro_for_menu($context, $menu_item);
  is(@{$macro_name_ref}[0], $macro_name,
      "preprocess() -- menu binding created");
  return;
}

# Test reading macros into memory
{
  # we need to init some basic configuration
  # set default encoding and context
  my $encoding = 'utf8';
  my @contexts = ("TredMacro");
  
  $TrEd::Config::libDir = "tredlib";
  TrEd::Macros::define_symbol('TRED');
  
  TrEd::Config::set_config();
  
  # Test reading default macro file first...
  TrEd::Macros::_read_default_macro_file($encoding, \@contexts);
  my %default_macro_file_cont = (
    "package TredMacro" =>  "_read_default_macro_file(): macro read successfully into memory && TredMacro package found",
    "line 1"            =>  "_read_default_macro_file(): macro read successfully into memory && line number information found",
    "tred.def"          =>  "_read_default_macro_file(): macro read successfully into memory && file name found",
  );
  
  _test_macros_contain(\%default_macro_file_cont);
  
  # check that key a menu bindigns are empty...
  ok(scalar(keys(%TrEd::Macros::keyBindings)) == 0, "_read_default_macro_file(): erase key bindings");
  ok(scalar(keys(%TrEd::Macros::menuBindings)) == 0, "_read_default_macro_file(): erase menu bindings");

  my $simple_macro_name = "simple-macro.mac";
  my $simple_macro_file = File::Spec->catfile($FindBin::Bin, "test_macros", $simple_macro_name);

  TrEd::Macros::read_macros($simple_macro_file, $TrEd::Config::libDir, 0, q{});
  my %simple_macro_test_file_cont = (
    $simple_macro_name  =>  "read_macros(): test macro no. 1 read into memory",
    "tred.def"          =>  "read_macros(): default macro read successfully into memory && file name found",
  );
  _test_macros_contain(\%simple_macro_test_file_cont);
  
#  ($key_combination, $menu_item, $context, $macro_name)
  _test_macro_bindings({"key_combination" => "CTRL+ALT+Del", 
                        "menu_item"       => "My First Macro", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "my_first_macro"});

  # now test that $keep = 0 really erases macros from before
  my $test_macro_1 = "test_macro_01.mak";
  my $test_macro_file_1 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_1);
  TrEd::Macros::read_macros($test_macro_file_1, $TrEd::Config::libDir, 0, q{});
  my %test_macro_1_file_name_only = (
    $test_macro_1   =>  "read_macros(): new macro is loaded into memory",
  );
  my %test_macro_1_simple_name = (
    $simple_macro_name    =>  "read_macros(): \$keep = 0 really overwrites",
  );
  _test_macros_dont_contain(\%test_macro_1_simple_name);
  _test_macros_contain(\%test_macro_1_file_name_only);
  
  # now testing that $keep = 1 just adds new macro 
  TrEd::Macros::read_macros($simple_macro_file, $TrEd::Config::libDir, 1, q{});
  my %keep_1_test_macro_cont = (
    $simple_macro_name  => "read_macros(): new macro loaded into memory",
    $test_macro_1       => "read_macros(): old macro is still in the memory",
    "tred.def"          => "read_macros(): default macro is still in the memory",
  );
  _test_macros_contain(\%keep_1_test_macro_cont);
  
  #TODO: potom este nieco, co otestuje predavanie contexts
  
  # Test that read_macros dies if the macro file does not exist... as a side effect, clean the binding from before
  dies_ok(sub { TrEd::Macros::read_macros("not_existing_file", $TrEd::Config::libDir, 0, q{}) }, "read_macros(): die if the macro file does not exist");
  
  
  
  
  # testing first test-macro -- simple #ifdef and #ifndef directives
  # should contain first test-macro
  my %test_macro_1_tred_defined = (
    "tred_defined"        =>  "preprocess(): #ifdef test",
    "ntred_not_defined"   =>  "preprocess(): #ifndef test",
  );
  
  _test_macro_file($test_macro_file_1, \%test_macro_1_tred_defined);
  
  
  # Macro file no. 2 -- test #ifdef, #ifndef, #elseif, #define and #undefine
  my $test_macro_2 = "test_macro_02.mak";
  my $test_macro_file_2 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_2);
  
  my %test_macro_2_not_contain = (
    "tred_defined"        =>  "preprocess(): #ifdef test after #undefine",
    "ntred_not_defined"   =>  "preprocess(): #ifndef test after #undefine",
    
  );
  my %test_macro_2_tred_not_defined = (
    "mtred_elseif_defined"     => "preprocess(): #elseif test",
  );
  
  _test_macro_file($test_macro_file_2, \%test_macro_2_tred_not_defined, \%test_macro_2_not_contain);
  
  # Macro file no. 3 -- test including other files via #include and #ifinclude directives
  my $test_macro_3 = "test_macro_03.mak";
  my $test_macro_file_3 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_3);
  
  my %test_macro_3_cont = (
    "sub include1"      => "preprocess(): double quoted include",
    "sub include2"      => "preprocess(): include <file>",
    "include0x"         => 'preprocess(): include "<file*.inc>", file 1 included',
    "include0y"         => 'preprocess(): include "<file*.inc>", file 2 included',
    "sub include3"      => "preprocess(): include without quotes",
    "sub include4"      => "preprocess(): ifinclude "
    
  );
  _test_macro_file($test_macro_file_3, \%test_macro_3_cont);
  
  _test_macro_bindings({"key_combination" => "CTRL+ř", 
                        "menu_item"       => "include1_label", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include1"});
  
  _test_macro_bindings({"key_combination" => "CTRL+ě", 
                        "menu_item"       => "include2_label", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include2"});
  
  _test_macro_bindings({"key_combination" => "CTRL+3", 
                        "menu_item"       => "include3_label", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include3"});
                        
  _test_macro_bindings({"key_combination" => "CTRL+ž", 
                        "menu_item"       => "include0x_label", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include0x"});
  
  _test_macro_bindings({"key_combination" => "CTRL+q", 
                        "menu_item"       => "include0x_label_2", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include0x"});
                        
  _test_macro_bindings({"key_combination" => "CTRL+4", 
                        "menu_item"       => "include4_label", 
                        "context"         => $contexts[0], 
                        "macro_name"      => "include4"});
  
  # Macro file no. 4 -- test #encoding directive
  my $test_macro_4 = "test_macro_04.mak";
  my $test_macro_file_4 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_4);
  
  my $utf8_pattern = "žluťoučký kůň úpěl ďábelské ódy";
  my %test_macro_4_cont = (
    $utf8_pattern      => "preprocess() & set_encoding(): encoding in utf-8",
  );
  _test_macro_file($test_macro_file_4, \%test_macro_4_cont);
  
  
  # Macro file no. 5 -- test #encoding directive
  my $test_macro_5 = "test_macro_05.mak";
  my $test_macro_file_5 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_5);
  
  
  my $iso_8859_2_pattern = "žluťoučký kůň úpěl ďábelské ódy";
  my %test_macro_5_cont = (
    $iso_8859_2_pattern      => "preprocess() & set_encoding(): encoding in iso-8859-2",
  );
  _test_macro_file($test_macro_file_5, \%test_macro_5_cont);

}

#testuj get_contexts priebezne