# -*- cperl -*-

package TrEd::CPConvert;

use Text::Iconv;

sub new {
  my ($self, $encoding1, $encoding2)=@_;
  my $class = ref($self) || $self;
  my $conv1 = Text::Iconv->new($encoding1, $encoding2);
  my $conv2 = Text::Iconv->new($encoding2, $encoding1);
  return undef unless ($conv1 and $conv2);
  my $new = bless [$conv1,$conv2,$encoding1,$encoding2], $class;
  return $new;
}

sub encode {
  my ($self,$string)=@_;
  return $self->[1]->convert($string);
}

sub decode {
  my ($self,$string)=@_;
  return $self->[0]->convert($string);
}

sub encoding_to {
  my ($self)=@_;
  return $self->[2];
}

sub decoding_to {
  my ($self)=@_;
  return $self->[3];
}

1;
