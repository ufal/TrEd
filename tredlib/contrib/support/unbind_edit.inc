# -*- cperl -*-

=head1 unbind_edit.inc

Disable default TredMacro key-bindings that modify trees.

=head2 USAGE

#include <common/support/unbind_edit.inc>

=head2 DESCRIPTION

Include this macro in your binding context if you want to disable all
default TredMacro key-bindings that modify trees, such as copy/paste,
etc.

=cut

#unbind-key F7
#unbind-key Shift+F7
#unbind-key F8
#unbind-key F5
#unbind-key F6
#unbind-key Ctrl+Insert
#unbind-key Shift+Insert
