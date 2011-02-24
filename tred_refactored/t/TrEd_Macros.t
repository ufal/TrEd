#!/usr/bin/env perl
# tests for TrEd::Macros

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../tredlib";
use Test::More 'no_plan';

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
my @keys = keys(%key_normalization);

# Try to set some bindings
TrEd::Macros::bind_key($context, $keys[0] => $macro);
TrEd::Macros::bind_key($another_context, $keys[3], $another_macro);

# Test existence of those bindings
is(TrEd::Macros::get_binding_for_key($context, $keys[0]), $macro,
    "bind_key() first way of setting the binding and get_binding_for_key() found it");
is(TrEd::Macros::get_binding_for_key($another_context, $keys[3]), $another_macro,
    "bind_key() second way of setting the binding and get_binding_for_key() found it");

# Overwrite old binding
TrEd::Macros::bind_key($another_context, $keys[3], $another_macro_2);

# Test that it worked
is(TrEd::Macros::get_binding_for_key($another_context, $keys[3]), $another_context.'->'.$another_macro_2,
    "bind_key() overwrite old binding and get_binding_for_key() found it");

my @contexts = TrEd::Macros::get_contexts();
my @expected_contexts = ($context, $another_context);
is_deeply(\@contexts, \@expected_contexts,
          "get_contexts(): return contexts for key bindings");

# Test also not existing context and key
ok(!defined(TrEd::Macros::get_binding_for_key("not_existing_context", $keys[3])), "get_binding_for_key() returns undef on unknnown context");
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

#testuj get_contexts priebezne