#!/usr/bin/perl
# -*- cperl -*-

my ($peer_addr,$peer_port)=@ARGV;

use IO::Socket;


$remote_control_socket
  = new IO::Socket::INET( PeerAddr => $peer_addr,
			  PeerPort => $peer_port,
			  Proto => 'tcp' );
die "Echoing client: Couldn't open socket of $peer_addr on $peer_port: $!\n" unless ($remote_control_socket);

while (!eof($remote_control_socket)) {
  $_=<$remote_control_socket>;
  print $_;
}

close ($remote_control_socket)	    || die "close: $!";


