#!/usr/bin/perl -Tw

use strict;
BEGIN { $ENV{PATH} = '/usr/ucb:/bin' }
use Socket;
use IO::Socket;
use Carp;

my $EOL = "\015\012";

my $port = shift || 2345;
$port = $1 if $port =~ /(\d+)/; # untaint port number

print "Port: $port\n";

my $sock = new IO::Socket::INET(LocalHost => 'localhost',
				LocalPort => $port,
				Proto => 'tcp',
				Listen => 5,
				Reuse => 1);

die "Socket not created: $!" unless $sock;


sub logmsg { print STDERR "$0 $$: @_ at ", scalar localtime, "\n" }

logmsg "server started on port $port";

my ($new_sock,$peer_addr);

while (($new_sock,$peer_addr) = $sock->accept()) {

  my $name = $new_sock->peerhost();

  logmsg "connection from $name [", $new_sock->peerhost(), "] at port ".$new_sock->peerport();

  while (defined($_=<STDIN>) and not /disconnect_client/) {
    chomp $_;
    print $new_sock $_,$EOL;
    print STDERR "Echo: $_\n";
    $new_sock->flush();
  }
  logmsg "end of communication with $name [", $new_sock->peerhost(), "] at port ".$new_sock->peerport();
}

close ($sock);



