#!/usr/bin/perl -w ############################################### Otakar Smrz, 2001/11/05
#
# ArabicRemix.pm ############################################################## 2004/03/10

package TrEd::ArabicRemix;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = "0.2";

#######################################################################################
# Usage         : remix($arabic_string, [$ignored_param])
# Purpose       : Not sure
# Returns       : Remixed arabic string
# Parameters    : scalar $arabic_string   -- string to remix
#                 [scalar $ignored_param  -- not used, however it's part of the prototype]
# Throws        : no exception
# Comments      : Prototyped function. 
#                 Splits the string using various arabic character classes, then take all the even 
#                 elements of resulting array and split them into subarrays. Reverse all the odd elements of
#                 each subarray, then reverse the subarray. 
# See Also      : 
sub remix ($;$) {
  
  my $arabic_number_re = qr{
    [\x{0660}-\x{0669}]+              # at least one of arabic digits (ARABIC-INDIC DIGIT ZERO - ARABIC-INDIC DIGIT NINE)
    # and then maybe also
    (?:
      [.,\x{060C}\x{066B}\x{066C}]   # a separator (ARABIC COMMA, ARABIC DECIMAL SEPARATOR, ARABIC THOUSANDS SEPARATOR or COMMA or FULL STOP)
      [\x{0660}-\x{0669}]+           # and at least one arabic digit (ARABIC-INDIC DIGIT ZERO - ARABIC-INDIC DIGIT NINE)
    )?
  }x;
  
  my $latin_number_re = qr{
    [0-9]+                            # at least one latin digit
    # and then maybe 
    (?:
      [.,\x{060C}\x{066B}\x{066C}]   # a separator (ARABIC COMMA, ARABIC DECIMAL SEPARATOR, ARABIC THOUSANDS SEPARATOR or COMMA or FULL STOP)
      [0-9]+                         # and at least one latin digit after the separator
    )?
  }x;
  
  # I am not sure, what this reg exp represents, but appears twice, so it can be compiled just once
  my $arabic_substr_re = qr{
    (?:
      \p{Arabic}
      |
      [\x{064B}-\x{0652}\x{0670}\x{0657}\x{0656}\x{0640}]
      |
      \p{InArabicPresentationFormsA}
      |
      \p{InArabicPresentationFormsB}
    )
  }x;
  
  my @data = split /(  (?: $arabic_substr_re+ 
                            |
                           $arabic_number_re )
                       (?: \p{Common}*
                       (?: $arabic_substr_re+ 
                            |
                           $latin_number_re 
                            |
                           $arabic_number_re )
                    )* )/x, $_[0];

  for (my $i = 1; $i < @data; $i += 2) {

    my @atad = split /($latin_number_re | $arabic_number_re)/x, $data[$i];

    for (my $j = 0; $j < @atad; $j += 2) {

      $atad[$j] = reverse $atad[$j];
    }

    $data[$i] = join "", reverse @atad;
  }

  return join "", @data;
}

#######################################################################################
# Usage         : direction($string)
# Purpose       : Find out the direction of the $string
# Returns       : If the $string contains latin characters, numbers or arabic numbers, function returns 1.
#                 Otherwise, if the string containst some arabic characters, function returns -1.
#                 Otherwise function returns 0.
# Parameters    : scalar $string -- string to be examined
# Throws        : no exception
# See Also      : 
sub direction ($) {
  my ($string) = @_;
  return  1 if $string =~ /\p{Latin}|[0-9\x{0660}-\x{0669}]/;
  return -1 if $string =~ /\p{Arabic}|\p{InArabic}|\p{InArabicPresentationFormsA}|\p{InArabicPresentationFormsB}/;
  return  0;
}

#######################################################################################
# Usage         : remixdir($string, [$dont_reverse])
# Purpose       : Change the string from left-to-right to right-to-left orientation
# Returns       : Reversed string
# Parameters    : scalar $string        -- string to remix
#                 scalar $dont_reverse  -- if set to 1, parts of string are not reversed
# Throws        : no exception
# Comments      : Reverse string, but keep latin parts in the same order, e.g. 1 2 _arabic_letter_1 _arabic_letter_2
#                 becomes _arabic_letter_2 _arabic_letter_1 1 2. If $dont_reverse is set to 1, 
#                 1 2 _arabic_letter_1 _arabic_letter_2 becomes _arabic_letter_1 _arabic_letter_2 1 2 
# See Also      : direction()
sub remixdir ($;$) {
  my ($string, $dont_reverse) = @_;
  my @char = split //, $string;

  my $context = 1;
  my @cut = (0);

  my $reverse = $context == 1 ? 0 : 1;

  my ($i, @line);

  for ($i = 0; $i < @char; $i++) {

    if ($context + direction $char[$i] == 0) {

      push @cut, $i;
      $context *= -1;
    }
  }

  push @cut, $i;
  
  for ($i = 1; $i < @cut; $i++) {
  
    if ($i % 2 == $reverse and not $dont_reverse) {
    
      unshift @line, reverse @char[$cut[$i - 1]..$cut[$i] - 1];
    }
    else {
    
      unshift @line, @char[$cut[$i - 1]..$cut[$i] - 1];
    }
  }

  return join "", @line;
}


1;

__END__


=head1 NAME


TrEd::ArabicRemix


=head1 VERSION

This documentation refers to 
TrEd::ArabicRemix version 0.2.


=head1 SYNOPSIS

  use TrEd::ArabicRemix
  
  my $char = "\x{064B}";
  my $dir = TrEd::ArabicRemix::direction($char); # -1 
  
  $char = "a";
  $dir = TrEd::ArabicRemix::direction($char); # 1
  
  my $str = "\x{064B}\x{062E}\x{0631}0123";
  my $remixed = TrEd::ArabicRemix::remix($str);
  
  my $dont_reverse = 0;
  my $remixed_dir = TrEd::ArabicRemix::remixdir($str, $dont_reverse);
  
=head1 DESCRIPTION

Basic functions for reversing string direction (LTR to RTL) with respect to numbers etc.

=head1 SUBROUTINES/METHODS

=over 4 


=item * C<TrEd::ArabicRemix::remix($arabic_string, [$ignored_param])>

=over 6

=item Purpose

Not sure

=item Parameters

  C<$arabic_string> -- scalar $arabic_string   -- string to remix
  C<[$ignored_param]> -- [scalar $ignored_param  -- not used, however it's part of the prototype]

=item Comments

Prototyped function. 
Splits the string using various arabic character classes, then take all the even 
elements of resulting array and split them into subarrays. Reverse all the odd elements of
each subarray, then reverse the subarray. 


=item Returns

Remixed arabic string

=back


=item * C<TrEd::ArabicRemix::direction($string)>

=over 6

=item Purpose

Find out the direction of the $string

=item Parameters

  C<$string> -- scalar $string -- string to be examined



=item Returns

If the $string contains latin characters, numbers or arabic numbers, function returns 1.
Otherwise, if the string containst some arabic characters, function returns -1.
Otherwise function returns 0.

=back


=item * C<TrEd::ArabicRemix::remixdir($string, [$dont_reverse])>

=over 6

=item Purpose

Change the string from left-to-right to right-to-left orientation

=item Parameters

  C<$string> -- scalar $string        -- string to remix
  C<[$dont_reverse]> -- scalar $dont_reverse  -- if set to 1, parts of string are not reversed

=item Comments

Reverse string, but keep latin parts in the same order, e.g. 1 2 _arabic_letter_1 _arabic_letter_2
becomes _arabic_letter_2 _arabic_letter_1 1 2. If $dont_reverse is set to 1, 
1 2 _arabic_letter_1 _arabic_letter_2 becomes _arabic_letter_1 _arabic_letter_2 1 2 

=item See Also

L<direction>,

=item Returns

Reversed string

=back



=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES



=head1 INCOMPATIBILITIES


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Otakar Smrz <otakar.smrz@mff.cuni.cz>

Copyright (c) 
2004 Otakar Smrz <otakar.smrz@mff.cuni.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
