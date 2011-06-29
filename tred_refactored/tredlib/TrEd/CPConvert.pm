# -*- cperl -*-

package TrEd::CPConvert;

# used in vallex and pdt15_obsolete

#######################################################################################
# Usage         : encoding_to()
# Purpose       : Return the destination/desired encoding (for encode function)
# Returns       : The destination/desired encoding, i.e. the encoding
#                 that is the first argument of the constructor
# Parameters    : no
# Throws        : no exception
# See Also      : decoding_to()
sub encoding_to {
    my ($self) = @_;
    return $self->[2];
}

#######################################################################################
# Usage         : decoding_to()
# Purpose       : Return the source encoding (for encode function)
# Returns       : The source encoding, i.e. the encoding
#                 that is the second argument of the constructor
# Parameters    : no
# Throws        : no exception
# See Also      : encoding_to()
sub decoding_to {
    my ($self) = @_;
    return $self->[3];
}

BEGIN {
    use vars qw($VERSION);
    $VERSION = "0.2";
    if ( $] >= 5.008 ) {
        eval <<'EOF';
    use Encode ();
    
    #######################################################################################
    # Usage         : new($encoding_1, $encoding_2)
    # Purpose       : Create CPConvert object that converts between specified encodings
    # Returns       : Blessed array reference
    # Parameters    : scalar $encoding_1 -- first encoding -- encoding_to
    #                 scalar $encoding_2 -- second encoding -- decoding_to
    # Throws        : no exception
    sub new {
      my ($self, $encoding1, $encoding2)=@_;
      my $class = ref($self) || $self;
      my $new = bless [undef, undef, $encoding1, $encoding2], $class;
      return $new;
    }

    #######################################################################################
    # Usage         : encode($string)
    # Purpose       : Recode string from $self->decoding_to() encoding 
    #                 to $self->encoding_to() encoding
    # Returns       : String in encoding_to() encoding
    # Parameters    : scalar $string -- string to be recoded
    # Throws        : no exception
    # See Also      : decode()
    sub encode {
      my ($self, $string)=@_;
      if ($self->decoding_to() ne 'utf-8') {
        $string = Encode::decode($self->decoding_to(), $string);
      }
      if ($self->encoding_to() ne 'utf-8') {
        $string = Encode::encode($self->encoding_to(), $string);
      }
      return $string;
    }
    
    #######################################################################################
    # Usage         : decode($string)
    # Purpose       : Recode string from $self->encoding_to() encoding 
    #                 to $self->decoding_to() encoding
    # Returns       : String in decoding_to() encoding
    # Parameters    : scalar $string -- string to be examined
    # Throws        : no exception
    # See Also      : encode()
    sub decode {
      my ($self, $string)=@_;
      if ($self->encoding_to() ne 'utf-8') {
        $string = Encode::decode($self->encoding_to, $string);
      }
      if ($self->decoding_to() ne 'utf-8') {
        $string = Encode::encode($self->decoding_to, $string);
      }
      return $string;
    }
EOF
    }
    else {
        eval <<'EOF';
    use Text::Iconv;
    
    #######################################################################################
    # Usage         : new($encoding_1, $encoding_2)
    # Purpose       : Create CPConvert object that converts between specified encodings
    # Returns       : Blessed array reference
    # Parameters    : scalar $encoding_1 -- first encoding -- encoding_to
    #                 scalar $encoding_2 -- second encoding -- decoding_to
    # Throws        : no exception
    sub new {
      my ($self, $encoding1, $encoding2)=@_;
      my $class = ref($self) || $self;
      my $conv1 = Text::Iconv->new($encoding1, $encoding2);
      my $conv2 = Text::Iconv->new($encoding2, $encoding1);
      return undef unless ($conv1 and $conv2);
      my $new = bless [$conv1,$conv2,$encoding1,$encoding2], $class;
      return $new;
    }
    
    #######################################################################################
    # Usage         : encode($string)
    # Purpose       : Recode string from $self->decoding_to() encoding 
    #                 to $self->encoding_to() encoding
    # Returns       : String in encoding_to() encoding
    # Parameters    : scalar $string -- string to be recoded
    # Throws        : no exception
    # See Also      : decode()
    sub encode {
      my ($self, $string)=@_;
      return $self->[1]->convert($string);
    }
    
    #######################################################################################
    # Usage         : decode($string)
    # Purpose       : Recode string from $self->encoding_to() encoding 
    #                 to $self->decoding_to() encoding
    # Returns       : String in decoding_to() encoding
    # Parameters    : scalar $string -- string to be examined
    # Throws        : no exception
    # See Also      : encode()
    sub decode {
      my ($self,$string)=@_;
      my $res= $self->[0]->convert($string);
      return $res;
    }
EOF
    }
}

1;

__END__

=head1 NAME


TrEd::CPConvert


=head1 VERSION

This documentation refers to 
TrEd::CPConvert version 0.2.


=head1 SYNOPSIS

  # file encoded in iso-8859-2
  use Encode;
  use TrEd::CPConvert;
  
  my $convert = TrEd::CPConvert->new("iso-8859-2", "cp1250");
  
  # From encode function viewpoint
  my $source_encoding = $convert->decoding_to();
  my $dest_encoding   = $convert->encoding_to();
  
  my $str_iso88592 = "ì¹èø¾ýáíéù";
  my $str_cp1250   = $str_iso88592;
  Encode::from_to($str_cp1250, "iso-8859-2", "cp1250");
  
  my $str_cp1250_2 = $convert->decode($str_iso88592);
  
  my $str_iso88592_2 = $convert->encode($str_cp1250_2);
  
  
=head1 DESCRIPTION

Basic functions for converting between two encodings. Uses either Tk::Iconv or Encode
Perl modules, depending on the Perl version (Encode for Perl 5.8 and newer).

=head1 SUBROUTINES/METHODS

=over 4 



=item * C<TrEd::CPConvert::encoding_to()>

=over 6

=item Purpose

Return the destination/desired encoding (for encode function)

=item Parameters



=item See Also

L<decoding_to>,

=item Returns

The destination/desired encoding, i.e. the encoding 
that is the first argument of the constructor

=back


=item * C<TrEd::CPConvert::decoding_to()>

=over 6

=item Purpose

Return the source encoding (for encode function)

=item Parameters



=item See Also

L<encoding_to>,

=item Returns

The source encoding, i.e. the encoding 
that is the second argument of the constructor

=back


=item * C<TrEd::CPConvert::new($encoding_1, $encoding_2)>

=over 6

=item Purpose

Create CPConvert object that converts between specified encodings

=item Parameters

  C<$encoding_1> -- scalar $encoding_1 -- first encoding -- encoding_to
  C<$encoding_2> -- scalar $encoding_2 -- second encoding -- decoding_to



=item Returns

Blessed array reference

=back


=item * C<TrEd::CPConvert::encode($string)>

=over 6

=item Purpose

Recode string from $self->decoding_to() encoding 
to $self->encoding_to() encoding

=item Parameters

  C<$string> -- scalar $string -- string to be recoded


=item See Also

L<decode>,

=item Returns

String in encoding_to() encoding

=back


=item * C<TrEd::CPConvert::decode($string)>

=over 6

=item Purpose

Recode string from $self->encoding_to() encoding 
to $self->decoding_to() encoding

=item Parameters

  C<$string> -- scalar $string -- string to be examined


=item See Also

L<encode>,

=item Returns

String in decoding_to() encoding

=back





=back


=head1 DIAGNOSTICS

This module does not output any diagnostic messages.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES

Encode for Perl >=5.8, Text::Iconv for older Perl.

=head1 INCOMPATIBILITIES

No known compatibility problems.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
