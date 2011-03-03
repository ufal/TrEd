package TrEd::MinMax;

use strict;
use warnings;
#
# $Revision: 2548 $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
require Exporter;

use base qw(Exporter);
our $VERSION = "0.2";
our @EXPORT = qw(min max min2 max2);
our @EXPORT_OK=qw(min max min2 max2 minstr maxstr sum reduce first shuffle);


##TODO: nejak zmysluplnejsie opisat, co robi tato funkcia
#######################################################################################
# Usage         : reduce(\&sub, @list)
# Purpose       : Template function that calls sub on pair of values. 
#                 This pair consists of the value returned by sub in previous iteration
#                 and new value from the list  
# Returns       : Whatever is returned by the last run of sub (scalar context)
# Parameters    : anonymous_sub \&sub -- subroutine that takes two args and returns a scalar
#                 list @list -- list of values
# Throws        : no exceptions
# Comments      : Prototyped function; It's not a very good idea to lexicalize variables $a and $b, 
#                 because if we wanted to use sort() function, we wouldn't be able to...
# See Also      : perlsub
sub reduce (&@) {
  my $code = shift;

  return shift unless @_ > 1;
  my ($a,$b);
  $a = shift;
  foreach (@_) {
    $b = $_;
    $a = &{$code}($a,$b);
  }
  return $a;
}


#######################################################################################
# Usage         : min2($a, $b)
# Purpose       : Find the smaller of 2 numbers  
# Returns       : If the numbers are equal, the second one is returned. Otherwise, the smaller number is returned. 
# Parameters    : num $a, num $b
# Throws        : no exceptions
# Comments      : Prototyped function
sub min2 ($$) { 
  return $_[0] < $_[1] ? $_[0] : $_[1];
}


######################################################################################
# Usage         : max2($a, $b)
# Purpose       : Find the bigger of 2 numbers  
# Returns       : If the numbers are equal, the second one is returned. Otherwise, the larger number is returned. 
# Parameters    : num $a, num $b
# Throws        : no exceptions
# Comments      : Prototyped function
sub max2 ($$) { 
  return $_[0] > $_[1] ? $_[0] : $_[1];
}


######################################################################################
# Usage         : sum(@list)
# Purpose       : Sum the elements of the list  
# Returns       : The sum of the elements of the @list (or their numeric value) 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
sub sum (@) { 
  return reduce { $_[0] + $_[1] } @_;
}


#######################################################################################
# Usage         : min(@list)
# Purpose       : Find the smallest element of the @list (in numeric value)
# Returns       : The smallest number in the list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
# See also      : min2, reduce
sub min (@) { 
  return reduce \&min2, @_; 
}


#######################################################################################
# Usage         : max(@list)
# Purpose       : Find the biggest element of the @list (in numeric value)
# Returns       : The biggest number in the list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
# See also      : max2, reduce
sub max (@) { 
  return reduce \&max2, @_;
}


#######################################################################################
# Usage         : minstr(@list)
# Purpose       : Find the string that is first in lexicographical ordering in the @list
# Returns       : The first string in lexicographical order
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
# See also      : lt operator, locale
sub minstr (@) { 
  return reduce { $_[0] lt $_[1] ? $_[0] : $_[1] } @_;
}


#######################################################################################
# Usage         : maxstr(@list)
# Purpose       : Find the string that is last in lexicographical ordering in the @list
# Returns       : The last string in lexicographical order 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
# See also      : gt operator, reduce
sub maxstr (@) { 
  return reduce { $_[0] gt $_[1] ? $_[0] : $_[1] } @_;
}


#######################################################################################
# Usage         : first(\&sub, @list)
# Purpose       : Return the first element of list for which the sub returns true 
#                 (no arguments are passed to the sub, it has to use $_);
#                 Return undef otherwise (or empty list in list context)
# Returns       : see Purpose 
# Parameters    : anonymous_sub \&sub -- subroutine that does not take any arguments and 
#                                         returns values which can be evaluated to true or false
#                 list @list -- first element from the @list, which is accepted by \&sub is then returned
# Throws        : no exceptions
# Comments      : Prototyped function
sub first (&@) {
  my $code = shift;

  foreach (@_) {
    return $_ if &{$code}();
  }
  
  return;
}

#######################################################################################
# Usage         : shuffle(@list)
# Purpose       : Shuffle elements of the list in a (pseudo)random way
# Returns       : Randomly shuffled list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function; afaik never actually used in the code
# See also      : map, rand perl functions
sub shuffle (@) {
  # create an array of references to items in the list
  my @a = \(@_);
  my $n;
  my $i = scalar(@_);
  # on every 'iteration' we virtually shortens the list;
  # we choose a random number from the range [0, length_of_shortened_list]
  # we return the item in the list on the position chosen by a random pick
  # and then we assign a reference of the last item in the (shortened) list 
  # to the position chosen by a random pick, i.e. we replace the item we returned
  # with the one from the end of the list to not lose it when we shorten the list
  return map {
    $n = rand($i--);
    (${$a[$n]}, $a[$n] = $a[$i])[0];
  } @_;
}

1;

__END__

=head1 NAME


TrEd::MinMax - List and compare utility functions


=head1 VERSION

This documentation refers to 
TrEd::MinMax version 0.2.


=head1 SYNOPSIS

  use TrEd::MinMax qw(min max min2 max2 minstr maxstr sum reduce first shuffle);
  
  my @list = (3, 1, 2);
  my $min = min(@list); # $min = 1
  my $max = max(@list); # $max = 3
  my $sum = sum(@list); # $sum = 6
  $sum = reduce { $_[0] + $_[1] } @list; # $sum = 6
  
  $min = min2(1, 2); # $min = 1
  $max = max2(1, 2); # $max = 2
  
  my @str_list = qw(aaa, bbb, zz, abz, cz);
  my $min_str = minstr(@str_list); # $min_str = 'aaa'
  my $max_str = maxstr(@str_list); # $max_str = 'zz'
  
  my $first_ok = first { $_ =~ /a.*z/ } @str_list; # $first_ok = 'abz'
  
  my @shuffled = shuffle(@str_list) # @shuffled contains shuffled @str_list


=head1 DESCRIPTION

This code is similar to List::Util but uses @_ instead of $a and $b,
as it's very hard or impossible to locate those two correctly under
the Safe mode (because of the namespace mangling).


=head1 SUBROUTINES/METHODS

=over 4 

=item * C<TrEd::MinMax::reduce (&@)>

=over 6

=item Purpose

"Template" prototyped function that calls I<sub> on pair of values. 
This pair consists of the value returned by I<sub> in previous iteration
and new value from the I<@list>.  

=item Parameters

C<\&sub> -- (anonymous) subroutine that takes two args and returns a scalar,
C<@list> -- list of values

=item Description

see L<List::Util::reduce>

=item Returns

Whatever is returned by the last run of sub (scalar context).

=back


=item * C<TrEd::MinMax::min2($a, $b)>

=over 6

=item Purpose

Find the smaller of 2 numbers

=item Parameters

C<$a> -- number no. 1,
C<$b> -- number no. 2

=item Description

Prototyped function.

=item Returns

If the numbers are equal, the second one is returned. Otherwise, the smaller number is returned.

=back


=item * C<TrEd::MinMax::max2($a, $b)>

=over 6

=item Purpose

Find the bigger of 2 numbers

=item Parameters

C<$a> -- number no. 1,
C<$b> -- number no. 2

=item Description

Prototyped function.

=item Returns

If the numbers are equal, the second one is returned. Otherwise, the larger number is returned.

=back


=item * C<TrEd::MinMax::min(@list)>

=over 6

=item Purpose

Find the smallest element of the @list (in numeric value)

=item Parameters

C<@list> -- list of numbers

=item Description

Prototyped function.

=item Returns

The smallest number in the I<@list>

=back


=item * C<TrEd::MinMax::max(@list)>

=over 6

=item Purpose

Find the biggest element of the I<@list> (in numeric value)

=item Parameters

C<@list> -- list of numbers

=item Description

Prototyped function.

=item Returns

The biggest number in the list I<@list>

=back



=item * C<TrEd::MinMax::minstr(@list)>

=over 6

=item Purpose

Find the string that is first in lexicographical ordering in the I<@list>.

=item Parameters

C<@list> -- list of strings

=item Description

Prototyped function.

=item Returns

The first string in lexicographical order from the I<@list>

=back


=item * C<TrEd::MinMax::maxstr(@list)>

=over 6

=item Purpose

Find the string that is last in lexicographical ordering in the I<@list>.

=item Parameters

C<@list> -- list of strings

=item Description

Prototyped function.

=item Returns

The last string in lexicographical order from the I<@list>

=back


=item * C<TrEd::MinMax::shuffle(@list)>

=over 6

=item Purpose

Shuffle elements of the I<@list> in a (pseudo)random way.

=item Parameters

C<@list> -- a list

=item Description

Prototyped function.

=item Returns

Randomly shuffled I<@list>

=back


=item * C<TrEd::MinMax::sum(@list)>

=over 6

=item Purpose

Sum the elements of the I<@list>

=item Parameters

C<@list> -- a list of numbers

=item Description

Prototyped function.

=item Returns

The sum of the elements of the I<@list> (their numeric value)

=back


=item * C<TrEd::MinMax::first(\&sub, @list)>

=over 6

=item Purpose

Find the first element of the I<@list> for which the I<\&sub> returns true.

=item Parameters

C<\&sub> -- subroutine that does not take any arguments and 
returns values which can be evaluated to true or false, 
C<@list> -- a list of values -- first element from the I<@list>, which is accepted by I<\&sub> is then returned

=item Description

Prototyped function.

=item Returns

The first element of list for which the sub returns true.
Undef otherwise (or empty list in list context).

=back


=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES


=head1 INCOMPATIBILITIES

Names of subroutines conflict with List::Util


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <email@address.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .
