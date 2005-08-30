# -*- cperl -*-

package IOBackend;
use Exporter;
require File::Temp;
use IO::File;
use IO::Pipe;
use strict;

use vars qw(@ISA $VERSION @EXPORT @EXPORT_OK
	    $Debug
	    $kioclient $kioclient_opts
	    $ssh $ssh_opts
	    $curl $curl_opts
	    $gzip $gzip_opts
	    $zcat $zcat_opts
	    $reject_proto
	   );

$VERSION = "0.1";

sub _find_exe {
  local $_ = `/usr/bin/which $_[0] 2>/dev/null`; chomp; /\S/ ? $_ : undef
}

BEGIN {
  @ISA=qw(Exporter);
  @EXPORT_OK = qw($kioclient $kioclient_opts
		  $ssh $ssh_opts
		  $curl $curl_opts
		  $gzip $gzip_opts
		  $zcat $zcat_opts
		  &set_encoding
		  &open_backend &close_backend
		  &get_protocol &quote_filename);

  $zcat	      ||= _find_exe('zcat');
  $gzip	      ||= _find_exe('gzip');
  $kioclient  ||= _find_exe('kioclient');
  $ssh	      ||= _find_exe('ssh');
  $curl	      ||= _find_exe('curl');
  $ssh_opts   ||= '-C';
  $reject_proto ||= '^(pop3?s?|imaps?)\$';
};


sub set_encoding {
  my ($fh,$encoding) = @_;
  no integer;
  if (defined($fh) and defined($encoding) and ($]>=5.008)) {
    eval {
      print STDERR "USING PERL IO ENCODING: $encoding\n" if $Debug;
      binmode($fh,":encoding($encoding)");
    };
    print STDERR $@ if $@;
  }
  return $fh;
}

# to avoid collision with Win32 drive-names, we only support protocols
# with at least two letters
sub get_protocol {
  my ($uri) = @_;
  if ($uri =~ m{^\s*([[:alnum:]][[:alnum:]]+):}) {
    return $1;
  } else {
    return 'file';
  }
}

sub quote_filename {
  my ($uri)=@_;
  $uri =~ s{\\}{\\\\}g;
  $uri =~ s{\"}{\\\"}g;
  return '"'.$uri.'"';
}

sub strip_protocol {
  my ($uri)=@_;
  $uri =~ s{^\s*(?:[[:alnum:]][[:alnum:]]+):(?://)?}{};
  return $uri;
}

sub _is_gzip {
  ($_[0] =~/.gz~?$/) ? 1 : 0;
}

sub open_pipe {
  my ($file,$rw,$pipe) = @_;
  my $fh;
  if (_is_gzip($file)) {
    if (-x $gzip && -x $zcat) {
      if ($rw eq 'w') {
	open $fh, "| $pipe | $gzip $gzip_opts > ".quote_filename($file) || undef $fh;
      } else {
	open $fh, "$zcat $zcat_opts < ".quote_filename($file)." | $pipe |" || undef $fh;
      }
    } else {
      warn "Need a functional gzip and zcat to open this file\n";
    }
  } else {
    if ($rw eq 'w') {
      open $fh, "| $pipe > ".quote_filename($file) || undef $fh;
    } else {
      open $fh, "$pipe < ".quote_filename($file)." |" || undef $fh;
    }
  }
  return $fh;
}

sub open_file_posix {
  my ($file,$rw) = @_;
  my $fh;
  if (_is_gzip($file)) {
    if (-x $gzip) {
      $fh = new IO::Pipe();
      if ($rw eq 'w') {
	$fh->writer("$gzip $gzip_opts > ".quote_filename($file)) || undef $fh;
      } else {
	$fh->reader("$zcat $zcat_opts < ".quote_filename($file)) || undef $fh;
      }
    }
    unless ($fh) {
      eval {
	require IO::Zlib;
	$fh = new IO::Zlib();
      } || return undef;
      $fh->open($file,$rw."b") || undef $fh;
    }
  } else {
    $fh = new IO::File();
    $fh->open($file,$rw) || undef $fh;
  }
  return $fh;
}

sub open_file_win32 {
  my ($file,$rw) = @_;
  my $fh;
  if (_is_gzip($file)) {
    eval {
      $fh = new File::Temp(UNLINK => 1);
    } && $fh || return undef;
    if ($rw eq 'w') {
      print "IOBackend: Storing ZIPTOFILE: $rw\n" if $Debug;
      ${*$fh}{'ZIPTOFILE'}=$file;
    } else {
      my $tmp;
      eval {
	require IO::Zlib;
	$tmp = new IO::Zlib();
      } && $tmp || return undef;
      $tmp->open($file,"rb") || return undef;
      $fh->print($_) while <$tmp>;
      $tmp->close();
      seek($fh,0,'SEEK_SET');
    }
    return $fh;
  } else {
    $fh = new IO::File();
    $fh->open($file,$rw) || return undef;
  }
  return $fh;
}

sub open_file {
  ($^O eq 'MSWin32') ? &open_file_win32 : &open_file_posix;
}

sub fetch_file {
  my ($uri) = @_;
  my $proto = get_protocol($uri);
  if ($proto eq 'file') {
    return (strip_protocol($uri),0);
  } elsif ($proto eq 'ntred' or $proto =~ /$reject_proto/) {
    return ($uri,0);
  } else {
    if ($^O eq 'MSWin32') {
      return fetch_file_win32($uri,$proto);
    } else {
      return fetch_file_posix($uri,$proto);
    }
  }
}

sub fetch_cmd {
  my ($cmd, $filename)=@_;
  print "IOBackend: fetch_cmd: $cmd\n" if $Debug;
  if (system($cmd." > ".$filename)==0) {
    return ($filename,1);
  } else {
    warn "$cmd > $filename failed (code $?): $!\n";
    return $filename,0;
  }
}

sub fetch_file_win32 {
  my ($uri,$proto)=@_;
  my $filename=POSIX::tmpnam();
  if ($proto=~m(^https?|ftp|gopher|news) and eval { require LWP::Simple }) {
    eval {
      LWP::Simple::is_success(LWP::Simple::getstore($uri,$filename)) ||
	  die "Error occured while fetching URL $uri\n";
      return $filename,1;
    };
    warn $@ if $@;
  }
  return $uri,0;
}

sub fetch_file_posix {
  my ($uri,$proto)=@_;
  print "IOBackend: fetching file using protocol $proto ($uri)\n" if $Debug;
  my ($fh,$tempfile)=File::Temp::mkstemps("/tmp/tredioXXXXXX",(_is_gzip($uri) ? ".gz" : ""));
  print "IOBackend: tempfile: $tempfile\n" if $Debug;

  if ($proto=~m(^https?|ftp|gopher|news) and eval { require LWP::Simple }) {
    print "IOBackend: using LWP::Simple\n" if $Debug;
    if (LWP::Simple::is_success(LWP::Simple::getstore($uri,$tempfile))) {
      return $tempfile,1;
    } else {
      warn "Error occured while fetching URL $uri\n";
      return $uri,0;
    };
  }
  if ($ssh and -x $ssh and $proto =~ /^(ssh|fish|sftp)$/) {
    print "IOBackend: using plain ssh\n" if $Debug;
    if ($uri =~ m{^\s*(?:ssh|sftp|fish):(?://)?([^-/][^/]*)(/.*)$}) {
      my ($host,$file) = ($1,$2);
      print "IOBackend: tempfile: $tempfile\n" if $Debug;
      return
	fetch_cmd($ssh." ".$ssh_opts." ".quote_filename($host).
	" /bin/cat ".quote_filename(quote_filename($file)),$tempfile);
    } else {
      warn "failed to parse URI for ssh $uri\n";
    }
  }
  if ($kioclient and -x $kioclient) {
    print "IOBackend: using kioclient\n" if $Debug;
    # translate ssh protocol to fish protocol
    if ($proto eq 'ssh') {
      ($uri =~ s{^\s*ssh:(?://)?([/:]*)[:/]}{fish://$1/});
    }
    return fetch_cmd($kioclient." ".$kioclient_opts.
		     " cat ".quote_filename($uri),$tempfile);
  }
  if ($curl and -x $curl and $proto =~ /^(?:https?|ftps?|gopher)$/) {
    return fetch_cmd($curl." ".$curl_opts." ".quote_filename($uri),$tempfile);
  }
  warn "No handlers for protocol $proto\n";
  return ($uri,0);
}

sub open_upload_pipe {
  my ($need_gzip,$user_pipe,$upload_pipe)=@_;
  my $fh;
  $user_pipe="| ".$user_pipe if defined($user_pipe) and $user_pipe !~ /^\|/;
  $user_pipe.=" ";
  my $cmd;
  if ($need_gzip) {
    if (-x $gzip) {
      $cmd = $user_pipe."| $gzip $gzip_opts | $upload_pipe ";
    } else {
      die "Need a functional gzip and zcat to open this file\n";
    }
  } else {
    $cmd = $user_pipe."| $upload_pipe ";
  }
  print "IOBackend: upload: $cmd\n" if $Debug;
  open $fh, $cmd || undef $fh;
  return $fh;
}

sub get_upload_fh_win32 {
  my ($uri,$proto,$userpipe)=@_;
  die "Can't save files using protocol $proto on Windows\n";
}

=pod upload_pipe_posix ($uri, $protocol, $userpipe)

Uploading is different from fetching, since it does not use a
temporary file.  Instead, a filehandle to an uploading pipeline is
returned.

=cut

sub get_upload_fh_posix {
  my ($uri,$proto,$userpipe)=@_;
  print "IOBackend: uploading file using protocol $proto ($uri)\n" if $Debug;

  if ($ssh and -x $ssh and $proto =~ /^(ssh|fish|sftp)$/) {
    print "IOBackend: using plain ssh\n" if $Debug;
    if ($uri =~ m{^\s*(?:ssh|sftp|fish):(?://)?([^-/][^/]*)(/.*)$}) {
      my ($host,$file) = ($1,$2);
      return open_upload_pipe(_is_gzip($uri), $userpipe, "$ssh $ssh_opts ".
		       quote_filename($host)." /bin/cat \\> ".
			      quote_filename(quote_filename($file)));
    } else {
      die "failed to parse URI for ssh $uri\n";
    }
  }
  if ($kioclient and -x $kioclient) {
    print "IOBackend: using kioclient\n" if $Debug;
    # translate ssh protocol to fish protocol
    if ($proto eq 'ssh') {
      $uri =~ s{^\s*ssh:(?://)?([/:]*)[:/]}{fish://$1/};
    }
    return open_upload_pipe(_is_gzip($uri),$userpipe,
		     "$kioclient $kioclient_opts put ".quote_filename($uri));
  }
  if ($curl and -x $curl and $proto =~ /^(?:ftps?)$/) {
    return open_upload_pipe("$curl --upload-file - $curl_opts ".quote_filename($uri));
  }
  die "No handlers for protocol $proto\n";
}

sub get_store_fh {
  my ($uri,$user_pipe) = @_;
  my $proto = get_protocol($uri);
  if ($proto eq 'file') {
    $uri = strip_protocol($uri);
    if ($user_pipe) {
      return open_pipe($uri,'w',$user_pipe);
    } else {
      return open_file($uri,'w');
    }
  } elsif ($proto eq 'ntred' or $proto =~ /$reject_proto/) {
    return $uri;
  } else {
    if ($^O eq 'MSWin32') {
      return get_upload_fh_win32($uri,$proto,$user_pipe);
    } else {
      return get_upload_fh_posix($uri,$proto,$user_pipe);
    }
  }
}

sub unlink_uri {
  ($^O eq 'MSWin32') ? &unlink_uri_win32 : &unlink_uri_posix;
}

sub unlink_uri_win32 {
  my ($uri) = @_;
  my $proto = get_protocol($uri);
  if ($proto eq 'file') {
    unlink strip_protocol($uri);
  } else {
    die "Can't unlink file $uri\n";
  }
}

sub unlink_uri_posix {
  my ($uri)=@_;
  my $proto = get_protocol($uri);
  if ($proto eq 'file') {
    return unlink strip_protocol($uri);
  }
  print "IOBackend: unlinking file $uri using protocol $proto\n" if $Debug;
  if ($ssh and -x $ssh and $proto =~ /^(ssh|fish|sftp)$/) {
    print "IOBackend: using plain ssh\n" if $Debug;
    if ($uri =~ m{^\s*(?:ssh|sftp|fish):(?://)?([^-/][^/]*)(/.*)$}) {
      my ($host,$file) = ($1,$2);
      return (system("$ssh $ssh_opts ".quote_filename($host)." /bin/rm ".
		     quote_filename(quote_filename($file)))==0) ? 1 : 0;
    } else {
      die "failed to parse URI for ssh $uri\n";
    }
  }
  if ($kioclient and -x $kioclient) {
    # translate ssh protocol to fish protocol
    if ($proto eq 'ssh') {
      $uri =~ s{^\s*ssh:(?://)?([/:]*)[:/]}{fish://$1/};
    }
    return (system("$kioclient $kioclient_opts rm ".quote_filename($uri))==0 ? 1 : 0);
  }
  die "No handlers for protocol $proto\n";
}

sub rename_uri {
  print "IOBackend: rename @_\n" if $Debug;
  ($^O eq 'MSWin32') ? &rename_uri_win32 : &rename_uri_posix;
}


sub rename_uri_win32 {
  my ($uri1,$uri2) = @_;
  my $proto1 = get_protocol($uri1);
  my $proto2 = get_protocol($uri2);
  if ($proto1 eq 'file' and $proto2 eq 'file') {
    my $uri1 = strip_protocol($uri1);
    return undef unless -f $uri1;
    rename $uri1, strip_protocol($uri2);
  } else {
    die "Can't rename file $uri1 to $uri2\n";
  }
}

sub rename_uri_posix {
  my ($uri1,$uri2) = @_;
  my $proto = get_protocol($uri1);
  my $proto2 = get_protocol($uri2);
  if ($proto ne $proto2) {
    die "Can't rename file $uri1 to $uri2\n";
  }
  if ($proto eq 'file') {
    my $uri1 = strip_protocol($uri1);
    return undef unless -f $uri1;
    return rename $uri1, strip_protocol($uri2);
  }
  print "IOBackend: rename file $uri1 to $uri2 using protocol $proto\n" if $Debug;
  if ($ssh and -x $ssh and $proto =~ /^(ssh|fish|sftp)$/) {
    print "IOBackend: using plain ssh\n" if $Debug;
    if ($uri1 =~ m{^\s*(?:ssh|sftp|fish):(?://)?([^-/][^/]*)(/.*)$}) {
      my ($host,$file) = ($1,$2);
      if ($uri2 =~ m{^\s*(?:ssh|sftp|fish):(?://)?([^-/][^/]*)(/.*)$} and $1 eq $host) {
	my $file2 = $2;
	return (system("$ssh $ssh_opts ".quote_filename($host)." /bin/mv ".
		       quote_filename(quote_filename($file))." ".
		       quote_filename(quote_filename($file2)))==0) ? 1 : 0;
      } else {
	die "failed to parse URI for ssh $uri2\n";
      }
    } else {
      die "failed to parse URI for ssh $uri1\n";
    }
  }
  if ($kioclient and -x $kioclient) {
    # translate ssh protocol to fish protocol
    if ($proto eq 'ssh') {
      $uri1 =~ s{^\s*ssh:(?://)?([/:]*)[:/]}{fish://$1/};
      $uri2 =~ s{^\s*ssh:(?://)?([/:]*)[:/]}{fish://$1/};
    }
    return (system("$kioclient $kioclient_opts mv ".quote_filename($uri1).
		     " ".quote_filename($uri2))==0 ? 1 : 0);
  }
  die "No handlers for protocol $proto\n";
}



=item open_backend (filename,mode,encoding?)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object based on
File::Handle class. Only files the filename of which ends with '.gz'
are considered to be gz-commpressed. All other files are opened using
IO::File.

Optionally, in perl ver. >= 5.8, you may also specify file character
encoding.

=cut


sub open_backend {
  my ($filename, $rw,$encoding)=@_;
  $filename =~ s/^\s*|\s*$//g;
  if ($rw eq 'r') {
    set_encoding(open_file($filename,$rw),$encoding);
  } else {
    set_encoding(get_store_fh($filename),$encoding);
  }
}

=pod

=item close_backend (filehandle)

Close given filehandle opened by previous call to C<open_backend>

=cut

sub close_backend {
  my ($fh)=@_;
  # Win32 hack:
  if (ref($fh) eq 'File::Temp') {
    my $filename = ${*$fh}{'ZIPTOFILE'};
    if ($filename ne "") {
      print "IOBackend: Doing the real save to $filename\n" if $Debug;
      seek($fh,0,'SEEK_SET');
      require IO::Zlib;
      my $tmp = new IO::Zlib();
      $tmp->open($filename,"wb") || die "Cannot write to $filename: $!\n";
      # binmode $tmp;
      binmode $fh;
      $tmp->print(<$fh>);
      $tmp->close;
    }
  }
  return ref($fh) && $fh->close();
}
