package NTREDBackend;
use Fslib;
use IO::Pipe;

use strict;

use vars qw($ntred);

=pod

=head1 NTREDBackend

Backend for sharing data with remote btred servers using ntred client.

=head2 REFERENCE

=over 4

=cut

=pod

=item $NTREDBackend::ntred

This variable may be used to set-up the path to 'ntred' client program.

=cut

$ntred='ntred';

=item test (filename)

Return true if the given filename contains ntred protocol prefix.

=cut

sub test {
  my ($filename,$encoding)=@_;
  return $filename=~m(^ntred://);
}

=item open_backend (filename,mode)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object blessed to
File::Pipe to corresponding ntred process.

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  my $fh = undef;
  my $cmd = "";
  return undef unless $filename=~m(^ntred://(.*)$);
  $filename=$1;
  $filename=~s/@/##/;
  if ($filename) {
    if ($mode =~/[w\>]/) {
      $cmd = "| $ntred --upload-file \"$filename\" 2>/dev/null";
      print STDERR "[w $cmd]\n" if $Fslib::Debug;
      eval {
#	$fh = new IO::Pipe();
#	$fh && $fh->writer($cmd);
	open $fh,"$cmd";
      } || return undef;
    } else {
      $cmd = "$ntred --dump-files \"$filename\" 2>/dev/null |";
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
