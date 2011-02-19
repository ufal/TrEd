package TrEd::MinMax;

#
# $Revision: 2548 $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
require Exporter;

@ISA=qw(Exporter);
$VERSION = "0.1";
@EXPORT = qw(min max min2 max2);
@EXPORT_OK=qw(min max min2 max2 minstr maxstr sum reduce first shuffle);

# This code is similar to List::Util but uses @_ instead of $a and $b,
# as it's very hard or impossible to locate those two correctly under
# the Safe mode (because of the namespace mangling)

##TODO: nejak zmysluplnejsie opisat, co robi tato funkcia
#######################################################################################
# Usage         : reduce(\&sub, @list)
# Purpose       : Template function that calls sub on pair of values. 
#                 This pair consists of the value returned by sub in previous iteration
#                 and new value from the list  
# Returns       : Whatever is returned by the last run of sub (scalar context)
# Parameters    : anonymous_sub \&sub, list @list
# Throws        : no exceptions
# Comments      : Prototyped function
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
# Returns       : The sum of the elements of the list (or their numeric value) 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function
sub sum (@) { 
  return reduce { $_[0] + $_[1] } @_;
}


#######################################################################################
# Usage         : min(@list)
# Purpose       : Find the smallest element of the list (in numeric value)
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
# Purpose       : Find the biggest element of the list (in numeric value)
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
# Purpose       : Find the string that is first in lexicographical ordering 
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
# Purpose       : Find the string that is last in lexicographical ordering  
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
# Parameters    : anonymous_sub \&sub, list @list
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
  my @a=\(@_);
  my $n;
  my $i=scalar(@_);
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
