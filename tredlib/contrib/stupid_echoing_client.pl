#!/usr/bin/perl
# -*- cperl -*-

#insert connectToRemoteControl as menu Connect to Remote Control
#insert disconnectFromRemoteControl as menu Disconnect from Remote Control

$peer_addr='localhost';
$peer_port='2345';


  use IO::Socket;

  disconnectFromRemoteControl();


  return unless defined($peer_addr) and defined($peer_port);

  print STDERR "Connecting to $remote on port $port\n";

  $remote_control_socket
    = new IO::Socket::INET( PeerAddr => $peer_addr,
			    PeerPort => $peer_port,
			    Proto => 'tcp' );
  unless ($remote_control_socket) {
    print STDERR "Couldn't open socket: $!\n";
    return;
  }

while (defined($_=<$remote_control_socket>)) {
  print "Got: $_";
}

print "Disconnected.\n";

close $remote_control_socket;

