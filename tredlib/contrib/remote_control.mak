# -*- cperl -*-

#insert connectToRemoteControl as menu Connect to Remote Control
#insert disconnectFromRemoteControl as menu Disconnect from Remote Control

$default_remote_addr='localhost';
$default_remote_port='2345';

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
  if (eof($remote_control_socket)) {
    $grp->{top}->fileevent(REMOTE_CONTROL,"readable",undef);
    print STDERR "Disconnected from remote control by server!\n";
    close $remote_control_socket || die "close: $!";
    return;
  }
  if ($_=<$remote_control_socket>) {
    chomp $_;
    print STDERR "Got $_ command from remote control server\n";
    my $macro=resolveRemoteCommand($grp,$_);
    if (defined($macro)) {
      main::doEvalMacro($grp,$macro);
    } else {
      print STDERR "Remote command $_ not recognized!\n";
    }
  } else {
    $grp->{top}->fileevent($remote_control_socket,"readable",undef);
    print STDERR "Error reading from socket, aborting communication!\n";
    close $remote_control_socket || die "close: $!";
    return;
  }
}


sub connectToRemoteControl {

  use IO::Socket;

  disconnectFromRemoteControl();


  my ($peer_addr,$peer_port)=askRemoteControlInfo();
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

  $grp->{top}->fileevent($remote_control_socket,'readable',\&onRemoteCommand);

}


sub disconnectFromRemoteControl {
  if (defined($remote_control_socket)) {
    $grp->{top}->fileevent($remote_control_socket,'readable',undef);
    close $remote_control_socket;
    undef $remote_control_socket;
    print STDERR "Disconnecting from remote control.\n";
    $grp->{top}->toplevel->
      messageBox(-icon => 'info',
		 -message => "Disconnecting from remote control.",
		 -title => 'Remote control', -type => 'ok');

  }
}

sub askRemoteControlInfo {
  my $peer_addr  = shift || $default_remote_addr;
  my $peer_port    = shift || $default_remote_port;

  print "creating dialog\n";
  my $d=$grp->{top}->DialogBox(-title => "Connect to remote control",
			       -buttons => ["Connect","Cancel"]);
  $d->bind('all','<Escape>' => [sub { shift; shift->{'selected_button'}='Cancel'; },$d ]);

  print "frames\n";
  my $hframe=$d->Frame()->pack(qw/-side top -expand yes -fill both/);
  my $pframe=$d->Frame()->pack(qw/-side top -expand yes -fill both/);
  print "host entry\n";
  my $he=$hframe->Label(-text => "Host", -anchor => 'e', -justify => 'right')
    ->pack(-side=>'left');
  $hframe->Entry(-relief => 'sunken', -width => 40, -takefocus => 1,
	       -textvariable => \$peer_addr)->pack(-side=>'right');
  print "port entry\n";
  $pframe->Label(-text => "Port", -anchor => 'e', -justify => 'right')
    ->pack(-side=>'left');
  $pframe->Entry(-relief => 'sunken', -width => 40, -takefocus => 1,
		 -textvariable => \$peer_port)
    ->pack(-side=>'right');
  print "resizable 0,0\n";
  $d->resizable(0,0);
  print "Showing dialog\n";
  $result = main::ShowDialog($d,$he,$grp->{top});
  print "done\n";
  $d->destroy();
  undef $d;
  return ($result eq 'Connect') ? ($peer_addr, $peer_port) : (undef, undef);
}
