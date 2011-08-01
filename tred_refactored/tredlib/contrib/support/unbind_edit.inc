# -*- cperl -*-

=head1 unbind_edit.inc

Disable default TredMacro key-bindings that modify trees.

=head2 USAGE

  #include <common/support/unbind_edit.inc>

=head2 DESCRIPTION

Include this macro in your binding context if you want to disable all
default TredMacro key-bindings that modify trees, such as copy/paste,
etc.

Extensions can also use TredMacro::UnbindTreeEdit($context) function.

=cut

require TrEd::MacroAPI::Default;
# CurrentContext would not work here, because the current context would be
# TredMacro, we need to pass the name of package that called this function
TredMacro::UnbindTreeEdit(__PACKAGE__);
