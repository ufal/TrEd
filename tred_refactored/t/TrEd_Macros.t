#!/usr/bin/env perl
# tests for TrEd::Macros

use strict;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More;
use Test::Trap;
use Data::Dumper;
use List::Util qw( first );
use File::Spec;
use Cwd;
use Encode;
use utf8;
use TrEd::Config;
use TrEd::Utils;
# to make summarization work in safe compartment
#use Devel::Cover;

sub lives_ok {
    my ($code, $name) = @_;
    trap sub { $code->() };
    $trap->leaveby('return'), $name;
}

sub dies_ok {
    my ($code, $name) = @_;
    trap sub { $code->() };
    $trap->leaveby('die'), $name;
}

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
binmode(STDERR, ':utf8');

our @subs;
can_ok(__PACKAGE__, @subs);

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
  my ($macro_file_name, $should_contain_ref, $should_not_contain_ref) = @_;
  open(my $macro_fh, '<', $macro_file_name) or
    die("Could not open $macro_file_name\n");

  $TrEd::Macros::macrosEvaluated = 0;

  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # load macro from new macro file
  TrEd::Macros::preprocess($macro_fh, $macro_file_name, \@TrEd::Macros::macros, \@TrEd::Macros::contexts, $TrEd::Config::libDir);
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
  my $negat = $arg_ref->{"negat"};

  if($negat){
    ok(!defined(TrEd::Macros::get_binding_for_key($context, $key_combination)), "preprocess() -- key binding should not exist");
    ok(!defined(TrEd::Macros::get_macro_for_menu($context, $menu_item)), "preprocess() -- menu binding should not exist");
  } else {
#  $macro_name = "$context->$macro_name";
    is(TrEd::Macros::get_binding_for_key($context, $key_combination), $macro_name,
        "preprocess() -- key binding created");
    my $macro_name_ref = TrEd::Macros::get_macro_for_menu($context, $menu_item);
    is(@{$macro_name_ref}[0], $macro_name,
        "preprocess() -- menu binding created");
  }
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
  TrEd::Macros::_reset_macros();
  my %default_macro_file_cont = (
    "tred.def"          =>  "_reset_macros(): macros does not contain old default macro name",
    "line "             =>  "_reset_macros(): macros does not contain line information",
  );

  _test_macros_dont_contain(\%default_macro_file_cont);

  # check that key a menu bindigns are empty...
  ok(scalar(keys(%TrEd::Macros::keyBindings)) == 0, "_reset_macros(): erase key bindings");
  ok(scalar(keys(%TrEd::Macros::menuBindings)) == 0, "_reset_macros(): erase menu bindings");

  my $simple_macro_name = "simple-macro.mac";
  my $simple_macro_file = File::Spec->catfile($FindBin::Bin, "test_macros", $simple_macro_name);

  TrEd::Macros::read_macros($simple_macro_file, $TrEd::Config::libDir, 0, "");
  my %simple_macro_test_file_cont = (
    $simple_macro_name  =>  "read_macros(): test macro no. 1 read into memory",
  );
  _test_macros_contain(\%simple_macro_test_file_cont);
  # no deafult macro
  %default_macro_file_cont = (
    "tred.def"          =>  "_reset_macros(): default macro not read anymore",
  );
  _test_macros_dont_contain(\%default_macro_file_cont);

#  ($key_combination, $menu_item, $context, $macro_name)
  _test_macro_bindings({"key_combination" => "CTRL+ALT+Del",
                        "menu_item"       => "My First Macro",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->my_first_macro"});

  # now test that $keep = 0 really erases macros from before
  my $test_macro_1 = "test_macro_01.mak";
  my $test_macro_file_1 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_1);
  TrEd::Macros::read_macros($test_macro_file_1, $TrEd::Config::libDir, 0, "utf-8");
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
                        "macro_name"      => "$contexts[0]->include1"});

  _test_macro_bindings({"key_combination" => "CTRL+ě",
                        "menu_item"       => "include2_label",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->include2"});

  _test_macro_bindings({"key_combination" => "CTRL+3",
                        "menu_item"       => "include3_label",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->include3"});

  _test_macro_bindings({"key_combination" => "CTRL+ž",
                        "menu_item"       => "include0x_label",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->include0x"});

  _test_macro_bindings({"key_combination" => "CTRL+q",
                        "menu_item"       => "include0x_label_2",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->include0x"});

  _test_macro_bindings({"key_combination" => "CTRL+4",
                        "menu_item"       => "include4_label",
                        "context"         => $contexts[0],
                        "macro_name"      => "$contexts[0]->include4"});

  # Macro file no. 4 -- test #encoding utf-8 directive
  my $test_macro_4 = "test_macro_04.mak";
  my $test_macro_file_4 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_4);

  my $utf8_pattern = "žluťoučký kůň úpěl ďábelské ódy";
  my %test_macro_4_cont = (
    $utf8_pattern      => "preprocess() & set_encoding(): encoding in utf-8",
  );
  _test_macro_file($test_macro_file_4, \%test_macro_4_cont);


  # Macro file no. 5 -- test #encoding iso-8859-2 directive
  my $test_macro_5 = "test_macro_05.mak";
  my $test_macro_file_5 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_5);


  my $iso_8859_2_pattern = "žluťoučký kůň úpěl ďábelské ódy";
  my %test_macro_5_cont = (
    $iso_8859_2_pattern      => "preprocess() & set_encoding(): encoding in iso-8859-2",
  );
  _test_macro_file($test_macro_file_5, \%test_macro_5_cont);

  # Macro file no. 6 -- test #binding-context, #key-binding-adopt, #menu-binding-adopt directives
  my $test_macro_6 = "test_macro_06.mak";
  my $test_macro_file_6 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_6);
  my $new_context = "my_new_extension";
  my %test_macro_6_cont = (
    "include3"      => "preprocess(): include no. 3 included successfully",
    "include4"      => "preprocess(): include no. 4 included successfully",
  );

  _test_macro_file($test_macro_file_6, \%test_macro_6_cont);

  # adopted bindings
  _test_macro_bindings({"key_combination" => "CTRL+ř",
                        "menu_item"       => "include1_label",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include1"});

  _test_macro_bindings({"key_combination" => "CTRL+ě",
                        "menu_item"       => "include2_label",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include2"});

  _test_macro_bindings({"key_combination" => "CTRL+3",
                        "menu_item"       => "include3_label",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include3"});

  _test_macro_bindings({"key_combination" => "CTRL+ž",
                        "menu_item"       => "include0x_label",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include0x"});

  _test_macro_bindings({"key_combination" => "CTRL+q",
                        "menu_item"       => "include0x_label_2",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include0x"});

  _test_macro_bindings({"key_combination" => "CTRL+4",
                        "menu_item"       => "include4_label",
                        "context"         => $new_context,
                        "macro_name"      => "$contexts[0]->include4"});

  # new binding
  _test_macro_bindings({"key_combination" => "CTRL+ALT+Esc",
                        "menu_item"       => "My New Extension",
                        "context"         => $new_context,
                        "macro_name"      => "$new_context->my_new_ext_macro"});


  # Macro file no. 7 -- test #unbind-key and #remove-menu
  my $test_macro_7 = "test_macro_07.mak";
  my $test_macro_file_7 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_7);
  $new_context = "my_new_extension";
  # macro is empty
  my %test_macro_7_cont = (
  );
  # open macro and preprocess it
  _test_macro_file($test_macro_file_7, \%test_macro_7_cont);

  # removed binding, should not exist
  _test_macro_bindings({"negat"           => 1,
                        "key_combination" => "CTRL+ALT+Esc",
                        "menu_item"       => "My New Extension",
                        "context"         => $new_context,
                        "macro_name"      => "$new_context->my_new_ext_macro",});

  # Macro file no. 8 -- test unmatched #elseif
  my $test_macro_8 = "test_macro_08.mak";
  my $test_macro_file_8 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_8);

  open(my $macro_fh, '<', $test_macro_file_8) or
    die("Could not open $test_macro_file_8\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die on unmatched #elseif
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_8, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die on unmatched elseif in macro");
  close($macro_fh);

  # Macro file no. 9 -- test unmatched #endif
  my $test_macro_9 = "test_macro_09.mak";
  my $test_macro_file_9 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_9);

  open($macro_fh, '<', $test_macro_file_9) or
    die("Could not open $test_macro_file_9\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die on unmatched #endif
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_9, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die on unmatched endif in macro");
  close($macro_fh);

  # Macro file no. 10 -- test missing #endif and exec code
  my $test_macro_10 = "test_macro_10.mak";
  my $test_macro_file_10 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_10);

  open($macro_fh, '<', $test_macro_file_10) or
    die("Could not open $test_macro_file_10\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die because of missing #endif
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_10, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die on missing endif in macro");
  is($TrEd::Macros::exec_code, "/usr/bin/perl",
      "preprocess(): set exec_code, first wins");
  close($macro_fh);

  # Macro file no. 11 -- test die on not existing file
  my $test_macro_11 = "test_macro_11.mak";
  my $test_macro_file_11 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_11);

  open($macro_fh, '<', $test_macro_file_11) or
    die("Could not open $test_macro_file_11\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die because included file does not exist
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_11, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die if include file does not exist -- quoted include");
  close($macro_fh);

  # Macro file no. 12 -- test die on not existing file, other kind of include
  my $test_macro_12 = "test_macro_12.mak";
  my $test_macro_file_12 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_12);

  open($macro_fh, '<', $test_macro_file_12) or
    die("Could not open $test_macro_file_12\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die because included file does not exist
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_12, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die if include file does not exist -- <> include");
  close($macro_fh);

  # Macro file no. 16 -- test die on not existing file, other kind of include
  my $test_macro_16 = "test_macro_16.mak";
  my $test_macro_file_16 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_16);

  open($macro_fh, '<', $test_macro_file_16) or
    die("Could not open $test_macro_file_16\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should die because included file does not exist
  dies_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_16, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): die if include file does not exist -- unquoted include");
  close($macro_fh);

  # testing __END__
  my $test_macro_14 = "test_macro_14.mak";
  my $test_macro_file_14 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_14);
  open($macro_fh, '<', $test_macro_file_14) or
    die("Could not open $test_macro_file_14\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should not die because __END__ directive stops processing
  lives_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_14, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): don't die -- die is after __END__");
  close($macro_fh);

  # testing __DATA__
  my $test_macro_15 = "test_macro_15.mak";
  my $test_macro_file_15 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_15);
  open($macro_fh, '<', $test_macro_file_15) or
    die("Could not open $test_macro_file_15\n");
  # clear macros loaded before
  @TrEd::Macros::macros = ();
  # should not die because __DATA__ directive stops processing
  lives_ok(sub { TrEd::Macros::preprocess($macro_fh, $test_macro_15, \@TrEd::Macros::macros, \@TrEd::Macros::contexts) }, "preprocess(): don't die -- die is after __DATA__");
  close($macro_fh);

}

{
  # Test working with macro variables
  my $macro_var_name_1 = "test_name";
  my $macro_var_name_2 = "Extension::test_name";
  my %macro_vars_test = (
    $macro_var_name_1  => "test_value",
    $macro_var_name_2  => "Extension_test_value"
  );

  TrEd::Macros::set_macro_variable($macro_var_name_1, $macro_vars_test{$macro_var_name_1});
  TrEd::Macros::set_macro_variable($macro_var_name_2, $macro_vars_test{$macro_var_name_2});


  is(TrEd::Macros::get_macro_variable($macro_var_name_1), $macro_vars_test{$macro_var_name_1},
      "set_macro_variable() && get_macro_variable() -- without full name qualification");

  is(TrEd::Macros::get_macro_variable($macro_var_name_2), $macro_vars_test{$macro_var_name_2},
      "set_macro_variable() && get_macro_variable() -- with full name qualification");
}


  # set saved contex variables
  my @context_save_vars = qw(grp this root FileNotSaved forceFileSaved);
  my @context_save_vals = qw(context_test_grp context_test_this context_test_root context_test_fns context_test_ffs);

sub test_macro_context_operations {
  # Test saving and restoring context

  TrEd::Macros::set_macro_variable($context_save_vars[0], $context_save_vals[0]);
  TrEd::Macros::set_macro_variable($context_save_vars[1], $context_save_vals[1]);
  TrEd::Macros::set_macro_variable($context_save_vars[2], $context_save_vals[2]);
  TrEd::Macros::set_macro_variable($context_save_vars[3], $context_save_vals[3]);
  TrEd::Macros::set_macro_variable($context_save_vars[4], $context_save_vals[4]);

  my $old_context = TrEd::Macros::save_ctxt();
  my @sorted_old_context = sort(@$old_context);
  my @sorted_expected_context = sort(@context_save_vals);
  is_deeply(\@sorted_old_context, \@sorted_expected_context,
              "save_ctxt(): save values of selected variables");

  TrEd::Macros::set_macro_variable($context_save_vars[0], "other_value");
  TrEd::Macros::set_macro_variable($context_save_vars[1], "other_value");
  TrEd::Macros::set_macro_variable($context_save_vars[2], "other_value");
  TrEd::Macros::set_macro_variable($context_save_vars[3], "other_value");
  TrEd::Macros::set_macro_variable($context_save_vars[4], "other_value");

  # Test new, overwritten values
  is(TrEd::Macros::get_macro_variable($context_save_vars[0]), "other_value",
      "set_macro_variable() && get_macro_variable() -- change context saved vars -- grp");
  is(TrEd::Macros::get_macro_variable($context_save_vars[1]), "other_value",
      "set_macro_variable() && get_macro_variable() -- change context saved vars -- this");
  is(TrEd::Macros::get_macro_variable($context_save_vars[2]), "other_value",
      "set_macro_variable() && get_macro_variable() -- change context saved vars -- root");
  is(TrEd::Macros::get_macro_variable($context_save_vars[3]), "other_value",
      "set_macro_variable() && get_macro_variable() -- change context saved vars -- FileNotSaved");
  is(TrEd::Macros::get_macro_variable($context_save_vars[4]), "other_value",
      "set_macro_variable() && get_macro_variable() -- change context saved vars -- forceFileSaved");

  TrEd::Macros::restore_ctxt($old_context);

  # Test restored values
  is(TrEd::Macros::get_macro_variable($context_save_vars[0]), $context_save_vals[0],
      "restore_ctxt() -- restore context -- grp");
  is(TrEd::Macros::get_macro_variable($context_save_vars[1]), $context_save_vals[1],
      "restore_ctxt() -- restore context -- this");
  is(TrEd::Macros::get_macro_variable($context_save_vars[2]), $context_save_vals[2],
      "restore_ctxt() -- restore context -- root");
  is(TrEd::Macros::get_macro_variable($context_save_vars[3]), $context_save_vals[3],
      "restore_ctxt() -- restore context -- FileNotSaved");
  is(TrEd::Macros::get_macro_variable($context_save_vars[4]), $context_save_vals[4],
      "restore_ctxt() -- restore context -- forceFileSaved");

#  note(Dumper($old_context));
}

sub test_running_macros {
  $TrEd::Config::default_macro_encoding = "utf8";
  $TrEd::Config::default_macro_file = 'tredlib/tred.def';
  # initialize basic variables for macro initialization
  my $grp = {
	   treeNo => 0,
	   FSFile => undef,
	   macroContext =>  'TredMacro',
	   currentNode => undef,
	   root => undef
	  };
  # $TrEd::Config::macroDebug = 1;

  # default macro does not work in Safe compartment, it seems
  my $default_keep_value = 1;

  ###################
  ### Macro 13
  ###################
  my $test_macro_13 = "test_macro_13.mak";
  my $test_macro_file_13 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_13);
  @TrEd::Macros::macros = ();

  # load dying macro, we have to
  TrEd::Macros::read_macros($test_macro_file_13, $TrEd::Config::libDir, $default_keep_value);
  my $ret_val;
  lives_ok(sub { $ret_val = TrEd::Macros::initialize_macros($grp) }, "initialize_macros(): don't die if macro dies");
  ok(!defined($ret_val), "initialize_macros(): return undef if macro dies");

  $TrEd::Macros::macrosEvaluated = 0;
  ok(!defined(TrEd::Macros::do_eval_macro($grp, "some->macro")), "do_eval_macro(): return undef if macro dies");



  ###################
  ### Macro 06
  ###################
  # Test context_can, context_isa and initialize_macros
  my $test_macro_6 = "test_macro_06.mak";
  my $test_macro_file_6 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_6);
  my $new_context = "my_new_extension";
  @TrEd::Macros::macros = ();

  # load another macro
  TrEd::Macros::read_macros($test_macro_file_6, $TrEd::Config::libDir, $default_keep_value);
#  _test_macro_file($test_macro_file_6, {});

  # init macros
  TrEd::Macros::initialize_macros($grp);

  my $fn_ref = TrEd::Macros::context_can("my_new_extension", "my_new_ext_macro");
  ok($fn_ref, "context_can(): find existing method");
  is($fn_ref->(), "here is my new extension macro function",
      "context_can(): returned coderef is correct");

  ok(!defined(TrEd::Macros::context_can("my_new_extension", "not_existing_method")), "context_can(): return undef if method does not exist");
  ok(!defined(TrEd::Macros::context_can(undef, "not_existing_method")), "context_can(): return undef if context is not defined");

  # testing context_isa
  ok(TrEd::Macros::context_isa("my_new_extension", "TredMacro"), "context_isa(): context is-a package");
  ok(!TrEd::Macros::context_isa("dummy_pkg", "dummy_pkg"), "context_isa(): return false when context & package does not exist");
  ok(!TrEd::Macros::context_isa("my_new_extension", "dummy_pkg"), "context_isa(): return false when package does not exist");
  ok(!TrEd::Macros::context_isa("dummy_pkg", "my_new_extension"), "context_isa(): return false when context does not exist");
  ok(!TrEd::Macros::context_isa(undef, "my_new_extension"), "context_isa(): return false when context does not exist");

  ###################
  ### Macro 05
  ###################
  #test context_can, do_eval_macro, do_eval_hook
  my $test_macro_5 = "test_macro_05.mak";
  my $test_macro_file_5 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_5);
  @TrEd::Macros::macros = ();

  my $iso_8859_2_pattern = "žluťoučký kůň úpěl ďábelské ódy";

  TrEd::Macros::read_macros($test_macro_file_5, $TrEd::Config::libDir, $default_keep_value);
   my %test_macro_5_file_cont = (
    $test_macro_5           =>  "read_macros(): test macro no. 5 read into memory",
    $iso_8859_2_pattern     =>  "preprocess() & set_encoding(): encoding in iso-8859-2",
  );

  _test_macros_contain(\%test_macro_5_file_cont);

  $grp = {
	   treeNo => 0,
	   FSFile => undef,
	   macroContext =>  'encode_test',
	   currentNode => undef,
	   root => undef
	  };
	
  TrEd::Macros::initialize_macros($grp);

  $fn_ref = TrEd::Macros::context_can("encode_test", "fn_from_pdt20_ext");

  my $pattern = "svůj-1_^(přivlast.)";
  ok($fn_ref->($pattern), "calling function with diacritics...");

  is(TrEd::Macros::do_eval_macro($grp), $context_save_vals[1],
    "do_eval_macro(): return value in scalar context: return TredMacro::this if no macro is passed as an argument");

  my @arr = TrEd::Macros::do_eval_macro($grp);
  my @expected_result = (0, 0, $context_save_vals[1]);
  is_deeply(\@arr, \@expected_result,
    "do_eval_macro(): return value in list context if no macro is passed as an argument");


  is(TrEd::Macros::do_eval_macro($grp, "encode_test->macro5_return"), 5,
    "do_eval_macro(): eval macro using string call, test return value of the macro");

  ### do_eval_macro only accepts name of function in Safe compartment
  if(!defined($TrEd::Macros::safeCompartment)){
    $fn_ref = TrEd::Macros::context_can("encode_test", "macro5_return");
    is(TrEd::Macros::do_eval_macro($grp, $fn_ref), 5,
      "do_eval_macro(): eval macro using code ref call, test return value of the macro");

    $fn_ref = TrEd::Macros::context_can("encode_test", "fn_from_pdt20_ext");
    my @call_array = ($fn_ref, $pattern);
    is(TrEd::Macros::do_eval_macro($grp, \@call_array), 1,
      "do_eval_macro(): eval macro using array ref call, test return value of the macro");
  }

  ok(!defined(TrEd::Macros::do_eval_hook($grp, "encode_test", "hook_that_does_not_exist")), "do_eval_hook(): return undef if hook does not exist");
  ok(!defined(TrEd::Macros::do_eval_hook($grp, "encode_test")), "do_eval_hook(): return undef if there was no hook name passed as an argument");

  is(TrEd::Macros::do_eval_hook($grp, "encode_test", "repeater_hook", 10), 10,
    "do_eval_hook(): hook is run & returns value correctly");

  ###################
  ### Macro 17
  ###################
  # test TrEd::Macros::do_eval_hook
  my $test_macro_17 = "test_macro_17.mak";
  my $test_macro_file_17 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_17);
  @TrEd::Macros::macros = ();

  TrEd::Macros::read_macros($test_macro_file_17, $TrEd::Config::libDir, $default_keep_value);

  $TrEd::Macros::warnings = 1;
  TrEd::Macros::initialize_macros($grp);

  is(TrEd::Macros::do_eval_hook($grp, "wrong_context", "repeater_hook", 10), 20,
    "do_eval_hook(): hook is run in default context & returns value correctly");

  ###################
  ### Macro 18
  ###################
  # test macro that is-a TrEd::Context

  my $test_macro_18 = "test_macro_18.mak";
  my $test_macro_file_18 = File::Spec->catfile($FindBin::Bin, "test_macros", $test_macro_18);
  @TrEd::Macros::macros = ();

  TrEd::Macros::read_macros($test_macro_file_18, $TrEd::Config::libDir, $default_keep_value);

  $TrEd::Macros::warnings = 1;
  TrEd::Macros::initialize_macros($grp);

  # I do not really know why, but do_eval_macro does not support safe compartment when using TrEd::Context
  if(!defined($TrEd::Macros::safeCompartment)){
    is(TrEd::Macros::do_eval_macro($grp, "tred_context_descendant->tred_context_macro"), "hello from tred_context_macro",
      "do_eval_macro(): eval macro using new calling convention, test return value of the macro");
  }

  # this code has been commented out/removed for now, maybe resurect test in the future...
  # is(TrEd::Macros::do_eval_hook($grp, "tred_context_descendant", "repeater_hook", 10), 10,
  #  "do_eval_hook(): hook is run using new calling convention & returns value correctly");

  @TrEd::Macros::macros = ();
  @TrEd::Macros::keyBindings = ();
  @TrEd::Macros::menuBindings = ();
}

################################
### NOT in Safe compartment
################################

test_macro_context_operations();
test_running_macros();

# testing safe compartment
{
  require Safe;
  $TrEd::Config::default_macro_encoding = "utf8";
  $TrEd::Config::default_macro_file = 'tredlib/tred.def';

  $TrEd::Macros::macrosEvaluated=0;
  $TrEd::Macros::safeCompartment=undef;

  %{TredMacroCompartment::}=();
  my $compartment = Safe->new('TredMacroCompartment');
  $compartment->{Erase} = 1;
  $compartment->reval("package TredMacro;");
  $compartment->share_from('TrEd::Config',[qw($libDir)]);
  # this is just for Devel::Cover purposes
  $compartment->share_from('main',[qw(Devel::Cover::use_file)]);
  $compartment->deny_only(qw{});

  $TrEd::Macros::safeCompartment = $compartment;

  my $grp = {
	   treeNo => 0,
	   FSFile => undef,
	   macroContext =>  'TredMacro',
	   currentNode => undef,
	   root => undef
	  };
  TrEd::Macros::initialize_macros($grp);


  $compartment->permit_only(qw(:base_core :base_mem :base_loop :base_math :base_orig
			       entereval caller dofile
			       print entertry leavetry tie untie bless
			       sprintf localtime gmtime sort require));
  $compartment->deny(qw(getppid getpgrp setpgrp getpriority setpriority
			pipe_op sselect select dbmopen dbmclose tie untie
		       ));
  $TrEd::Macros::safeCompartment = $compartment;

  note("\n## Using safe compartment:");
  test_macro_context_operations();
  note("\n## Using safe compartment:");
  test_running_macros();

}

done_testing();
