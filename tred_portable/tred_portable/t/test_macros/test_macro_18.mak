# test macro file no 18
# Test macro which is a descendant of Tred::Context

package TrEd::Context;

# this is just an ad-hoc implementation created by looking at code in 
# TrEd/Macros.pm and seeing how is the sub called...
sub global {
	my $class = shift;
	return $class;
}

package tred_context_descendant;

#binding-context tred_context_descendant

our @ISA = qw(TrEd::Context);


sub tred_context_macro {
	return "hello from tred_context_macro";
}

sub repeater_hook {
	my ($arg) = @_;
	return $_[1];
}