#!/usr/bin/perl

use strict;
use Socket;
use IO::Socket;
use Carp;

use FindBin;
use lib ("$FindBin::RealBin", "$FindBin::RealBin/../lib",
         "$FindBin::Bin","$FindBin::Bin/../lib",
	 "$FindBin::Bin/lib", "$FindBin::RealBin/lib"
	);


use Getopt::Long;
use vars qw($shell $OUT $term);
GetOptions(
  "shell|s" => \$shell
 );

if ($shell) {
  $ENV{PERL_READLINE_NOWARN}=1;
  require Term::ReadLine;
  $term = new Term::ReadLine('control');
  $OUT = $term->OUT;
  print $OUT "SHELL: ",$term->ReadLine,"\n";
} else {
  $OUT = \*STDOUT;
}

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

  if ($shell) {
    print $OUT "SHELL: ",$term->ReadLine,"\n";
    while (defined($_=get_line($term,'> ','')) and not /^\\disconnect_client/) {
      exit 0 if (/^\\quit/);
      chomp $_;
      print $new_sock $_,$EOL;
      print $OUT "Echo: $_\n";
      $new_sock->flush();
    }
  } else {
    print $OUT "NO SHELL\n";
    while (defined($_=<STDIN>) and not /^\\disconnect_client/) {
      exit 0 if (/^\\quit/);
      chomp $_;
      print $new_sock $_,$EOL;
      print STDERR "Echo: $_\n";
      $new_sock->flush();
    }
  }
    logmsg "end of communication with $name [", $new_sock->peerhost(), "] at port ".$new_sock->peerport();
}

sub get_line {
  my ($term,$prompt,$retonint)=@_;
  my $line;
  $SIG{INT}=sub { die 'TRAP-SIGINT'; };
  eval {
    $line = $term->readline($prompt);
  };
  if ($@) {
    if ($@ =~ /TRAP-SIGINT/) {
      print "\n" unless $term->ReadLine eq 'Term::ReadLine::Perl'; # clear screen
      return $retonint;
    } else {
      print STDERR $@,"\n";
      return undef;
    }
  }
  return $line;
}

close ($sock);
