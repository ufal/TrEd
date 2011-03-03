#!/usr/bin/env perl
# tests for TrEd::Macros

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';
use Data::Dumper;
 use List::Util qw( first );

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
## Public function test -- get_contexts()
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
  "Meta-è"            => "META+è",
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
  );
  
  my %key_bindings_after_unbind = (
    $key_normalization{$keys[0]} => undef,
    $key_normalization{$keys[3]} => undef,
  );
  
  # Bind 2 key combinations with the same macro
  TrEd::Macros::bind_key($context, $keys[0] => $macro);
  TrEd::Macros::bind_key($context, $keys[3], $macro);
  
  
  # Test get_bindings_for_macro function
  my @expected_bindings = sort(keys(%key_bindings_after_unbind));
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
  
  
  # Remove bindings for both key combinations (delete it this time)
  TrEd::Macros::unbind_macro($context, $macro, $delete);
  is_deeply($TrEd::Macros::keyBindings{$context}, {}, 
            "unbind_macro(): delete macro bindings");
  
  # Test get_keybindings function -- when the keybindings does not exist
  %keybindings = TrEd::Macros::get_keybindings($context);
  is_deeply(\%keybindings, {},
                "get_keybindings(): empty hash");
  
  # Test get_bindings_for_macro with empty keybindings hash
  @bindings = TrEd::Macros::get_bindings_for_macro($context, $macro);
  is_deeply(\@bindings, [],
            "get_bindings_for_macro(): reports empty bindings correctly");
  
  # Test get_keybindings function -- when the keybindings does not exist
  ok(!defined(TrEd::Macros::get_keybindings("not_xisting_context")), "get_keybindings(): return undef if context does not exist");
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
  
  # Test that get_contexts unifies correctly
  TrEd::Macros::add_to_menu($menu_only_context, $label, $macro);
  _test_get_contexts([$context, $another_context, $context_copy, $menu_only_context]);
  
  # Test not existing context
  ok(!defined(TrEd::Macros::get_menuitems("not_existing_context")), "get_menuitems(): correct return value for context that does not exist");
  
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

  # Test get_menus_for_macro
  my @got_labels = sort(TrEd::Macros::get_menus_for_macro($menu_only_context, $another_macro));
  my @expected_labels = sort($another_label, $another_label_2);
  is_deeply(\@got_labels, \@expected_labels,
            "get_menus_for_macro(): return all labels for macro");
            
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
  
  # Test remove_from_menu_macro($context, $macro)
  TrEd::Macros::remove_from_menu_macro($menu_only_context, $another_macro);
  %expected_menu_items = (
    $label            => [$macro, undef],
  );
    
  %got_menu_items = TrEd::Macros::get_menuitems($menu_only_context);
  is_deeply(\%got_menu_items, \%expected_menu_items, 
            "remove_from_menu_macro(): remove all labels bound to macro; get_menuitems(): reflect it");
  
  
}

# Test reading macros into memory
{
  # we need to init some basic configuration
  my $encoding = 'utf8';
  my @contexts = ("TredMacro");
  
  $TrEd::Config::libDir = "tredlib";
  TrEd::Macros::define_symbol('TRED');
  
  TrEd::Config::set_config();
  
  # Test reading default macro file first...
  TrEd::Macros::_read_default_macro_file($encoding, \@contexts);
  
  my $package_found = first { /package TredMacro/ } @TrEd::Macros::macros; 
  my $line_info_found = first { /line 1/ } @TrEd::Macros::macros;
  my $file_name_found = first { /tred.def/ } @TrEd::Macros::macros;  
  ok($package_found, "_read_default_macro_file(): macro read successfully && it contains TredMacro package");
  ok($line_info_found, "_read_default_macro_file(): macro read successfully && it contains line number information");
  ok($file_name_found, "_read_default_macro_file(): macro read successfully && it contains file information");
  
  # check that key a menu bindigns are empty...
  ok(scalar(keys(%TrEd::Macros::keyBindings)) == 0, "_read_default_macro_file(): erase key bindings");
  ok(scalar(keys(%TrEd::Macros::menuBindings)) == 0, "_read_default_macro_file(): erase menu bindings");

  

}

#testuj get_contexts priebezne