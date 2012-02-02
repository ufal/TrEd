# test macro file no 6
# Test binding-context and includes in various contexts (before and after setting context...)

package my_new_extension;

#binding-context my_new_extension

our @ISA = qw(TredMacro);

use strict;

#include ../t/test_macros/include/include3.inc
#include "include/include4.inc"

#key-binding-adopt TredMacro
#menu-binding-adopt TredMacro

#insert my_new_ext_macro as menu My New Extension
#bind my_new_ext_macro to key Ctrl+Alt+Esc

sub my_new_ext_macro {
	return "here is my new extension macro function";
}
