package TrEd::Cipher;

use strict;
use base qw(Exporter);
use vars qw(@EXPORT_OK);

BEGIN {
  @EXPORT_OK = qw(generate_random_block block_to_hex hex_to_block block_xor block_md5
		  Negotiate Authentify save_block);
}

#######################################################################################
# Usage         : generate_random_block($length)
# Purpose       : Generate a block of pseudo-random bytes with length $length
# Returns       : Sequence of pseudo-random numbers
# Parameters    : scalar $length  -- length of the block of bytes (1024 if no length is specified)
# Throws        : no exceptions
# Comments      : Reads from /dev/urandom, thus is not multiplatform, uses also perl's rand() function
# See also      : pack, unpack, rand
sub generate_random_block {
  my ($length) = @_;
  if ($length <= 0) {
    $length = 1024;
  }
  my $key;
  open(my $ur, "/dev/urandom");
  read($ur, $key, $length);
  close $ur;
  my @key = map { int(rand(256))^$_ } unpack("C".$length, $key);
  return pack("C".$length, @key);
}

#######################################################################################
# Usage         : block_to_hex($key)
# Purpose       : Convert each character to its hexadecimal value
# Returns       : Upper-cased sequence of hexadecimal codes
# Parameters    : scalar $key -- scalar to be turned to hexadecimal codes
# Throws        : no exceptions
# Comments      : 
# See also      : unpack, sprintf
sub block_to_hex {
  my ($key) = @_;
  my @hex_codes = map { sprintf("%02x",$_) } unpack("C".length($key), $key);
  return uc(join("", @hex_codes));
}

#######################################################################################
# Usage         : hex_to_block($hex)
# Purpose       : Convert hexadecimal values to characters
# Returns       : Sequence of characters represented by $hex hexcodes
# Parameters    : scalar $hex -- string with hexadecimal values
# Throws        : no exceptions
# Comments      : 
# See also      : pack
sub hex_to_block {
  my ($hex) = @_;
  my @decimal_values =  map { hex($_) } $hex=~/(..)/g;
  return pack("C".(length($hex)/2), @decimal_values);
}

#######################################################################################
# Usage         : block_xor($b1, $b2)
# Purpose       : $b1 bitwise XORs $b2 cyclically 
# Returns       : Result of the XOR operator
# Parameters    : scalar $b1 -- key
#                 scalar $b2 -- data
# Throws        : no exceptions
# Comments      : $b1 cycles (if it is shorter than $b2)
# See also      : unpack, pack
sub block_xor {
  my ($b1, $b2) = @_;
  # b1 is key
  # b2 is data
  # b1 XORs cyclically b2
  my @b1 = unpack("C".length($b1), $b1);
  my @b2 = unpack("C".length($b1), $b2);

  my @result;
  my $i = 0;
  while (@b2) {
    push @result, ($b1[$i]^shift(@b2));
    $i = ($i+1) % scalar(@b1); # cycle 
  }
  return pack("C".scalar(@result), @result);
}

#######################################################################################
# Usage         : shuffle(@list)
# Purpose       : Shuffle elements of the list in a (pseudo)random way
# Returns       : Randomly shuffled list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function; afaik never actually used in the code
# See also      : map, rand perl functions
sub block_md5 {
  my ($b)=@_;
  require Digest::MD5;
  uc(Digest::MD5::md5_hex($b));
}

#######################################################################################
# Usage         : shuffle(@list)
# Purpose       : Shuffle elements of the list in a (pseudo)random way
# Returns       : Randomly shuffled list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function; afaik never actually used in the code
# See also      : map, rand perl functions
sub Authentify {
  my ($key, $peer, $control)=@_;
  my $rand = generate_random_block(length($key));
  $peer->print("$control AUTH_SIGN=",block_to_hex($rand),"\n");
  $peer->flush();
  my $reply;
  $reply = readline($peer);
  chomp ($reply);
  unless ($reply =~ /^$control AUTH_SIGNED=([0-9ABCDEF]+)$/
	  and $1 eq block_md5(block_xor($key,$rand))) {
    $peer->print("$control AUTH_FAILED\n");
    $peer->flush();
    return 0;
  } else {
    $peer->print("$control AUTH_OK\n");
    $peer->flush();
    return 1;
  }
}

#######################################################################################
# Usage         : shuffle(@list)
# Purpose       : Shuffle elements of the list in a (pseudo)random way
# Returns       : Randomly shuffled list 
# Parameters    : list @list
# Throws        : no exceptions
# Comments      : Prototyped function; afaik never actually used in the code
# See also      : map, rand perl functions
sub Negotiate {
  my ($key, $server, $control)=@_;
  my $reply;
  $reply = readline($server);
  chomp ($reply);
  return 0 unless ($reply =~ /^$control AUTH_SIGN=([0-9ABCDEF]+)$/);
  $server->print("$control AUTH_SIGNED=".
		 block_md5(block_xor($key,hex_to_block($1)))."\n");
  $server->flush();
  $reply = readline($server);
  chomp ($reply);
  return 0 unless $reply eq "$control AUTH_OK";
  return 1;
}

#######################################################################################
# Usage         : save_block($block, $filename)
# Purpose       : Save hexadecimal representation of $block to file $filename
# Returns       : True if close of file succeeds
# Parameters    : scalar $block     -- data to be written to file (it is converted to hexadecimal)
#                 scalar $filename  -- name of the file
# Throws        : Dies if open fails.
# Comments      : If there is any file with identical name, function deletes it.
# See also      : sysopen, unlink
sub save_block {
  my ($block, $filename)=@_;
  use Fcntl;
  local *FH;
  unlink($filename);
  # Create the file if it doesn't exist & Fail if the file already exists
  sysopen(FH, $filename, O_WRONLY|O_EXCL|O_CREAT, 0600) || die $!;
  print FH block_to_hex($block)."\n";
  return close(FH);
}

1;

__END__

=head1 NAME


TrEd::Cipher - ?


=head1 VERSION

This documentation refers to 
TrEd::Cipher version 0.2.


=head1 SYNOPSIS

  use TrEd::Cipher;
  
  ...

=head1 DESCRIPTION

...


=head1 SUBROUTINES/METHODS

=over 4 



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

Petr Pajas <pajas@matfyz.cz>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .
