#!/usr/bin/perl -Tw

use strict;
BEGIN { $ENV{PATH} = '/usr/ucb:/bin' }
use Socket;
use IO::Socket;
use Carp;

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

  my($port,$iaddr) = sockaddr_in($peer_addr);
  my $name = gethostbyaddr($iaddr,AF_INET);

  logmsg "connection from $name [", inet_ntoa($iaddr), "] at port $port";

  while (defined($_=<STDIN>) and not /disconnect_client/) {
    print $new_sock $_;
    $new_sock->flush();
  }
  logmsg "end of communication with $name [", inet_ntoa($iaddr), "] at port $port";
}

close ($sock);


