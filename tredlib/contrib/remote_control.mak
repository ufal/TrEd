# -*- cperl -*-

#insert connectToRemoteControl as menu Connect to Remote Control
#insert disconnectFromRemoteControl as menu Disconnect from Remote Control

###
## This macro realises a communication with a remote control. It can be any
## server accepting tcp communication and sending to its client (TrEd) commands. 
## Command is simply a name of TrEd's macro to be executed. Each command must be
## on one line, the usual socket end-of-line (\015\012) is expected (i.e. each
## line of input is chopped twice).
###

$default_remote_addr='localhost';
$default_remote_port='2345';
$remote_control_socket=undef;
$remote_control_notify=undef;

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

sub runCommand {
  my ($grp,$command)=@_;

  print STDERR "Got $command command from remote control server\n";
  chop $command; chop $command;
  my $macro=resolveRemoteCommand($grp,$command);
  if (defined($macro)) {
    main::doEvalMacro($grp,$macro);
  } else {
    print STDERR "Remote command $command not recognized!\n";
  }
}

sub onRemoteCommand {
  my $grp=shift;
  print "$remote_control_socket\n";
  print STDERR "reading from socket REMOTE_CONTROL\n";
  if (eof($remote_control_socket)) {
    disconnectFromRemoteControl("Disconnected from remote control server!");
    return;
  }
  if (defined($_=<$remote_control_socket>)) {
    runCommand($grp,$_);
  } else {
    disconnectFromRemoteControl("Error reading from socket!\nDisconnecting remote control server!\n");
    return;
  }
}

sub periodicSocketCanReadCheck {
  my $grp=shift;
  my @can_read;
  if (@can_read=$remote_control_socket_sel->can_read(0)) {
    foreach (@can_read) {
      onRemoteCommand($grp) if ($_ == $remote_control_socket);
    }
  }
}

sub connectToRemoteControl {

  use IO::Socket;
  use IO::Select;

  disconnectFromRemoteControl();
  print "Macro connectToRemoteControl is here!\n";

  my ($peer_addr,$peer_port)=askRemoteControlInfo();
  return unless defined($peer_addr) and defined($peer_port);

  print STDERR "Connecting to $peer_addr on port $peer_port\n";

  $remote_control_socket
    = new IO::Socket::INET( PeerAddr => $peer_addr,
			    PeerPort => $peer_port,
			    Proto => 'tcp' );
  die "Couldn't open socket: $!\n"
    unless ($remote_control_socket);

  if ($^O eq "MSWin32") {
    print STDERR "MSWin32 platform detected.\n";
    $remote_control_socket_sel = new IO::Select( $remote_control_socket );
    $remote_control_notify=$grp->{top}->
      repeat(100,[\&periodicSocketCanReadCheck, $grp ]);  
  } else {
    print STDERR "Non-MS platform: good choice!\n";
    $grp->{top}->fileevent($remote_control_socket,'readable',[\&onRemoteCommand,$grp]);
  }
}

sub exit_hook {
  disconnectFromRemoteControl();
}

sub disconnectFromRemoteControl {
  my $message=shift || "Disconnecting from remote control.";
  if (defined($remote_control_socket)) {
    if ($^O eq "MSWin32") {
      $grp->{top}->afterCancel($remote_control_notify);
      $remote_control_socket_sel->remove($remote_control_socket) if ($^O eq 'MSWin32');
      undef $remote_control_socket_sel;
    } else {
      $grp->{top}->fileevent($remote_control_socket,'readable',undef);
    }
    close $remote_control_socket;
    undef $remote_control_socket;
    print STDERR "$message\n";
    $grp->{top}->toplevel->
      messageBox(-icon => 'info',
		 -message => $message,
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
