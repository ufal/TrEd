# -*- cperl -*-

package TrEd::CPConvert;

sub encoding_to {
  my ($self)=@_;
  return $self->[2];
}

sub decoding_to {
  my ($self)=@_;
  return $self->[3];
}

BEGIN {
  if ($]>=5.008) {
    eval <<'EOF';
    use Encode ();
    sub new {
      my ($self, $encoding1, $encoding2)=@_;
      my $class = ref($self) || $self;
      my $new = bless [undef,undef,$encoding1,$encoding2], $class;
      return $new;
    }
    sub encode {
      my ($self,$string)=@_;
      if ($self->decoding_to ne 'utf-8') {
        $string = Encode::decode($self->decoding_to,$string);
      }
      if ($self->encoding_to ne 'utf-8') {
        $string = Encode::encode($self->encoding_to,$string);
      }
      return $string;
    }
    sub decode {
      my ($self,$string)=@_;
      if ($self->encoding_to ne 'utf-8') {
        $string = Encode::decode($self->encoding_to,$string);
      }
      if ($self->decoding_to ne 'utf-8') {
        $string = Encode::encode($self->decoding_to,$string);
      }
      return $string;
    }
EOF
  } else {
    eval <<'EOF';
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
      my $res= $self->[0]->convert($string);
      Dump $res;
      return $res;
    }
EOF
  }
}
1;
