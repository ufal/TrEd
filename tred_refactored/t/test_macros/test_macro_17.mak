# test macro file no 17
# Test default context for hook

package TredMacro;

#binding-context TredMacro

BEGIN { import TredMacro; }


sub repeater_hook {
	my ($arg) = @_;
	return $arg * 2;
}
