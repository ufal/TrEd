package TrEd::ValLex::DummyConv;
use strict;

sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  return bless [],$class;
}

sub encode { return $_[0]; }
sub decode { return $_[0]; }

1;
