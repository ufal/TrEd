# -*- cperl -*-

sub resolveRemoteCommand {
  my ($grp,$macro)=@_;
  my $context=$grp->{macroContext};

  if ($context->can($macro)) {
    return "$context\:\:$macro";
  } elsif ($context ne "TredMacro" and TredMacro->can($macro)) {
    return "Tredmacro->$macro";
  }
  return undef;
}

sub onRemoteCommand {

  print STDERR "reading from socket REMOTE_CONTROL\n";
  if (eof(REMOTE_CONTROL)) {
    $grp->{top}->fileevent(REMOTE_CONTROL,"readable",undef);
    print STDERR "Disconnected from remote control by server!\n";
    close REMOTE_CONTROL || die "close: $!";
    return;
  }
  if ($_=<REMOTE_CONTROL>) {
    print STDERR "Got $_ command from remote control server\n";
    my $macro=resolveRemoteCommand($grp,$_);
    if (defined($macro)) {
      main::doEvalMacro($grp,$_);
    } else {
      print STDERR "Remote command $_ not recognized!\n";
    }
  } else {
    $grp->{top}->fileevent(REMOTE_CONTROL,"readable",undef);
    print STDERR "Error reading from socket, aborting communication!\n";
    close REMOTE_CONTROL || die "close: $!";
    return;
  }
}

#insert connectToRemoteControl as menu Connect to Remote Control
sub connectToRemoteControl {

  use Socket;
  my ($remote,$port, $iaddr, $paddr, $proto, $line);

  shift;
  $remote  = shift || 'localhost';
  $port    = shift || 2345;
  print STDERR "Connecting to $remote on port $port\n";
  if ($port =~ /\D/) { $port = getservbyname($port, 'tcp') }
  die "No port" unless $port;
  $iaddr   = inet_aton($remote)               || die "no host: $remote";
  $paddr   = sockaddr_in($port, $iaddr);

  $proto   = getprotobyname('tcp');
  socket(REMOTE_CONTROL, PF_INET, SOCK_STREAM, $proto)  || die "socket: $!";
  connect(REMOTE_CONTROL, $paddr)    || die "connect: $!";

  $grp->{top}->fileevent(REMOTE_CONTROL,'readable',\&onRemoteCommand);
}
