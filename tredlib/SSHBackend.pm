package SSHBackend;
use Fslib;
use IO::Pipe;

use strict;

use vars qw($ssh $gzip);

=pod

=head1 SSHBackend

Backend for reading/writing data from a remote server via ssh and
gzip. Both commands may be customized by a global module variable of
the same name. By default, C<$gzip> is set to 'gzip' and C<$ssh> is
set to 'ssh -C' for compression.

=head2 REFERENCE

=over 4

=cut

=pod

=item $SSHBackend::ssh

This variable may be used to set-up the path to 'ssh' client program.

=cut

$ssh='ssh -C';

=item $SSHBackend::gzip

This variable may be used to set-up the path to 'gzip' client program
(the path must work for both client and server).

=cut

$gzip='gzip';

=item test (filename)

Return true if the given filename contains ssh/scp/fish protocol prefix.

=cut

sub test {
  my ($filename,$encoding)=@_;
  return $filename=~m(^(ssh|scp|fish)://);
}

=item open_backend (filename,mode)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object blessed to
File::Pipe to corresponding ssh process.

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  my $fh = undef;
  my $cmd = "";
  return undef unless $filename=~m(^(ssh|scp|fish)://([^:]+):(.*)$);
  my $host = $2;
  $filename=$3;
  if ($filename) {
    if ($mode =~/[w\>]/) {
      if (defined($gzip)) {
	$cmd = "| $gzip | $ssh $host \"$gzip -d > $filename\" 2>/dev/null";
      } else {
	$cmd = "$ssh $host \"cat > $filename\" 2>/dev/null";
      }
      print STDERR "[w $cmd]\n" if $Fslib::Debug;
      eval {
 #	$fh = new IO::Pipe();
 #	$fh && $fh->writer($cmd);
	 open $fh,"$cmd";
       } || return undef;
     } else {
       if (defined($gzip)) {
	 $cmd = "$ssh $host \"$gzip < $filename\" 2>/dev/null | $gzip -d |";
      } else {
	$cmd = "$ssh $host \"cat $filename\" 2>/dev/null |";
      }
      print STDERR "[r $cmd]\n" if $Fslib::Debug;
      eval {
#	$fh = new IO::Pipe();
#	$fh && $fh->reader($cmd);
	open $fh,"$cmd";
      } || return undef;
    }
  }
  no integer;
  if ($]>=5.008 and defined $encoding) {
    eval {
      print STDERR "USING PERL IO ENCODING: $encoding FOR MODE $mode\n" if $Fslib::Debug;
      binmode $fh,":encoding($encoding)";
    };
    print STDERR $@ if $@;
  }
  return $fh;
}

=pod

=item close_backend (filehandle)

Close given filehandle opened by previous call to C<open_backend>

=cut

sub close_backend {
  my ($fh)=@_;
  return $fh && $fh->close();
}

=pod

=item read (handle_ref,fsfile)

=cut

sub read {
  FSBackend::read(@_);
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  FSBackend::write(@_);
}


=pod

=back

=cut

1;
