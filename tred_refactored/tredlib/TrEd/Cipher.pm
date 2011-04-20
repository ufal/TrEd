package TrEd::Cipher;

use strict;
use warnings;

use version;

use base qw(Exporter);
use vars qw(@EXPORT_OK $VERSION);
$VERSION = "0.2";




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
# See also      : pack(), unpack(), rand()
#TODO: What if we are on Windows, where no /dev/urandom exist?
sub generate_random_block {
  my ($length) = @_;
  if ($length <= 0) {
    $length = 1024;
  }
  my $key;
  open(my $ur, "/dev/urandom")
    or die("Could not open /dev/urandom: $!");
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
# See also      : unpack(), sprintf()
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
# See also      : pack()
sub hex_to_block {
  my ($hex) = @_;
  my @decimal_values =  map { hex($_) } $hex=~/(..)/g;
  return pack("C".(length($hex)/2), @decimal_values);
}

#######################################################################################
# Usage         : block_xor($key, $data)
# Purpose       : $key bitwise XORs $data cyclically 
# Returns       : Result of the XOR operator
# Parameters    : scalar $key -- key
#                 scalar $data -- data
# Throws        : no exceptions
# Comments      : $key cycles (if it is shorter than $data)
#                 Attention: original implementation readed only the same length of $data as
#                 is the length of $key, changed now.
# See also      : unpack(), pack()
sub block_xor {
  my ($b1, $b2) = @_;
  # b1 is key
  # b2 is data
  # b1 XORs cyclically b2
  my @b1 = unpack("C".length($b1), $b1);
  #TODO: not sure, whether this is a copy-paste bug or intentional: original
  # documentation says sth about cycling, but if $b2 is shortened to the length of $b1,
  # no cycling can actually happen, so we change it
#  my @b2 = unpack("C".length($b1), $b2);
  my @b2 = unpack("C".length($b2), $b2);
  
  my @result;
  my $i = 0;
  while (@b2) {
    push(@result, ($b1[$i]^shift(@b2)));
    $i = ($i+1) % scalar(@b1); # cycle 
  }
  return pack("C".scalar(@result), @result);
}

#######################################################################################
# Usage         : block_md5($block)
# Purpose       : Calculate MD5 hash of given block
# Returns       : Hexadecimal upper-cased form of MD5 hash of the given block
# Parameters    : scalar $block -- block of data to process
# Throws        : no exceptions
# Comments      : Requires Digest::MD5
# See also      : Digest::MD5::md5_hex()
sub block_md5 {
  my ($b) = @_;
  require Digest::MD5;
  return uc(Digest::MD5::md5_hex($b));
}

#######################################################################################
# Usage         : Authentify($key, $peer, $control)
# Purpose       : Authentifies $peer by its answer to AUTH_SIGN
# Returns       : 0 if authentification fails, 1 if it is successful 
# Parameters    : scalar $key             -- session key
#                 IO::Socket::INET $peer  -- object returned by IO::Socket::accept() call
#                 scalar $control         -- control string
# Throws        : no exceptions
# Comments      : Function sends AUTH_SIGN code to $peer, then waits for the answer and tests if it is correct
# See also      : block_md5(), block_xor(), generate_random_block()
sub Authentify {
  my ($key, $peer, $control) = @_;
  my $rand = generate_random_block(length($key));
  $peer->print("$control AUTH_SIGN=",block_to_hex($rand),"\n");
  $peer->flush();
  my $reply;
  $reply = readline($peer);
  chomp ($reply);
  unless ($reply =~ /^$control AUTH_SIGNED=([0-9ABCDEF]+)$/
	  and $1 eq block_md5(block_xor($key, $rand))) {
    $peer->print("$control AUTH_FAILED\n");
    $peer->flush();
    return 0;
  } 
  else {
    $peer->print("$control AUTH_OK\n");
    $peer->flush();
    return 1;
  }
}

#######################################################################################
# Usage         : Negotiate($key, $server, $control)
# Purpose       : Tries to authenticate with server $server usning $key and $control string
# Returns       : Zero if authentication fails, 1 otherwise
# Parameters    : scalar $key               -- session key
#                 IO::Socket::INET $server  -- server object
#                 scalar $control           -- control string
# Throws        : no exceptions
# Comments      : Reads AUTH_SIGN sent by the server, decodes it from hexadecimal to decimal values,
#                 then does a block_xor with $key value and finally counts md5 of the result. This
#                 hash value is then sent to the server.
# See also      : hex_to_block(), block_xor(), block_md5()
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
  return 0 if ($reply ne "$control AUTH_OK");
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
# See also      : sysopen(), unlink()
sub save_block {
  my ($block, $filename)=@_;
  use Fcntl;
  my $fh;
  unlink($filename);
  # Create the file if it doesn't exist & Fail if the file already exists
  sysopen($fh, $filename, O_WRONLY|O_EXCL|O_CREAT, 0600) || die $!;
  print $fh block_to_hex($block)."\n";
  return close($fh);
}

1;

__END__

=head1 NAME


TrEd::Cipher - supporting routines for server/client authentification over the network


=head1 VERSION

This documentation refers to 
TrEd::Cipher version 0.2.


=head1 SYNOPSIS

  use TrEd::Cipher;
  
  # generate random block of size 5
  my $rand_block =  TrEd::Cipher::generate_random_block(5);

  # hex to decimal and vice versa
  my $block;
  my $hex = TrEd::Cipher::block_to_hex($block);
  $block = TrEd::Cipher::hex_to_block($hex);
  
  my $data = "Hello, world";
  my $key = "123456";
  my $xored_data = blockTrEd::Cipher::block_xor($key, $data)

  my $md5_hash = TrEd::Cipher::block_md5($data);

  my $file_name = "my.file";
  TrEd::Cipher::save_block($block, $file_name);
  
  ## Authentification functions
  
  ## common:
  my $key = "123456";
  my $control = "control-string";
  
  ## server-side
  my $server = new IO::Socket::INET (LocalHost => 'localhost',
                                      LocalPort => 5656,
                                      Proto => 'tcp',
                                      Listen => 5,
                                      Reuse => 1,
                                     );
  my $hub;
  do {{
    $hub = $server->accept();
    if(!TrEd::Cipher::Authentify($key, $hub, $control)) {
      print "Access denied\n";
    }
  }} while(!$hub);
   
  ## client-side
  my $hub= new IO::Socket::INET (PeerAddr => $hubname,
                                  PeerPort => $hubport,
                                  Proto => 'tcp'
                                  );
  
  if(TrEd::Cipher::Negotiate($key, $hub, $control)){
    print "Successful negotiation\n";
  }

=head1 DESCRIPTION

These functions are used as a basic security mechanism in ntred and btred when btred acts like a server 
and ntred manages these servers to do some useful work. It should ensure that any other party would be 
rejected without the knowledge of key and how to transform it. 


=head1 SUBROUTINES/METHODS

=over 4 



=item * C<TrEd::Cipher::generate_random_block($length)>

=over 6

=item Purpose

Generate a block of pseudo-random bytes with length $length


=item Parameters

  C<$length> -- scalar $length  -- length of the block of bytes (1024 if no length is specified)

=item Comments

Reads from /dev/urandom, thus is not multiplatform, uses also perl's rand() function


=item See Also

L<pack>,
L<unpack>,
L<rand>,

=item Returns

Sequence of pseudo-random numbers


=back


=item * C<TrEd::Cipher::block_to_hex($key)>

=over 6

=item Purpose

Convert each character to its hexadecimal value


=item Parameters

  C<$key> -- scalar $key -- scalar to be turned to hexadecimal codes


=item See Also

L<unpack>,
L<sprintf>,

=item Returns

Upper-cased sequence of hexadecimal codes


=back


=item * C<TrEd::Cipher::hex_to_block($hex)>

=over 6

=item Purpose

Convert hexadecimal values to characters


=item Parameters

  C<$hex> -- scalar $hex -- string with hexadecimal values


=item See Also

L<pack>,

=item Returns

Sequence of characters represented by $hex hexcodes


=back


=item * C<TrEd::Cipher::block_xor($key, $data)>

=over 6

=item Purpose

$key bitwise XORs $data cyclically 


=item Parameters

  C<$key> -- scalar $key -- key
  C<$data> -- scalar $data -- data

=item Comments

$key cycles (if it is shorter than $data)

Attention: original implementation readed only the same length of $data as
is the length of $key, this is changed now.

=item See Also

L<unpack>,
L<pack>,

=item Returns

Result of the XOR operator


=back


=item * C<TrEd::Cipher::block_md5($block)>

=over 6

=item Purpose

Calculate MD5 hash of given block


=item Parameters

  C<5($block> -- scalar $block -- block of data to process

=item Comments

Requires Digest::MD5


=item See Also

L<Digest::MD5::md5_hex>,

=item Returns

Hexadecimal upper-cased form of MD5 hash of the given block


=back


=item * C<TrEd::Cipher::Authentify($key, $peer, $control)>

=over 6

=item Purpose

Authentifies $peer by its answer to AUTH_SIGN


=item Parameters

  C<$key> -- scalar $key             -- session key
  C<$peer> -- IO::Socket::INET $peer  -- object returned by IO::Socket::accept() call
  C<$control> -- scalar $control         -- control string

=item Comments

Function sends AUTH_SIGN code to $peer, then waits for the answer and tests if it is correct


=item See Also

L<block_md5>,
L<block_xor>,
L<generate_random_block>,

=item Returns

0 if authentification fails, 1 if it is successful 


=back


=item * C<TrEd::Cipher::Negotiate($key, $server, $control)>

=over 6

=item Purpose

Tries to authenticate with server $server usning $key and $control string


=item Parameters

  C<$key> -- scalar $key               -- session key
  C<$server> -- IO::Socket::INET $server  -- server object
  C<$control> -- scalar $control           -- control string

=item Comments

Reads AUTH_SIGN sent by the server, decodes it from hexadecimal to decimal values,

then does a block_xor with $key value and finally counts md5 of the result. This
hash value is then sent to the server.

=item See Also

L<hex_to_block>,
L<block_xor>,
L<block_md5>,

=item Returns

Zero if authentication fails, 1 otherwise


=back


=item * C<TrEd::Cipher::save_block($block, $filename)>

=over 6

=item Purpose

Save hexadecimal representation of $block to file $filename


=item Parameters

  C<$block> -- scalar $block     -- data to be written to file (it is converted to hexadecimal)
  C<$filename> -- scalar $filename  -- name of the file

=item Comments

If there is any file with identical name, function deletes it.


=item See Also

L<sysopen>,
L<unlink>,

=item Returns

True if close of file succeeds


=back



=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Digest::MD5, Fcntl

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
