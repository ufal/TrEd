package CSTSBackend;

use Fslib;

=pod

=head1 CSTSBackend

CSTSBackend - generic IO backend for reading/writing csts sgml files
using external cstsfs conversion utility and possibly zcat for
gz-compressed files.  Only open_backend, close_backend and test functions
are implemented, read and write functions are imported from FSBackend.

=head2 REFERENCE

=over 4

=cut

=pod

=item $CSTSBackend::zcat

This variable may be used to set-up the zcat external utility. This
utility must be able to decompress standard input to standard output.

=item $CSTSBackend::gzip

This variable may be used to set-up the gzip external utility. This
utility must be able to compress standard input to standard output.

=cut

$CSTSBackend::zcat = "/bin/zcat" unless $CSTSBackend::zcat;
$CSTSBackend::gzip = "/usr/bin/gzip" unless $CSTSBackend::zcat;

=pod

=item $CSTSBackend::csts2fs

This variable may be used to set-up the external utility for
conversion from CSTS SGML format to FS format. This utility must be
able to read standard input and write it in FSFormat to standard
output.

=item $CSTSBackend::fs2csts

This variable may be used to set-up the external utility for
conversion from FS format to CSTS SGML format. This utility must be
able to read standard input in FS format and write it in to standard
output in CSTS SGML format.

=cut

$CSTSBackend::csts2fs = "/f/common/bin-linux-intel/cstsfs.x -oformat=fs";
$CSTSBackend::fs2csts = "/f/common/bin-linux-intel/cstsfs.x -oformat=csts -imh";

=pod

=item open_backend (filename,mode)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object blessed to
File::Pipe. Only files the filename of which ends with `.gz' are
considered to be gz-commpressed.

=cut

sub open_backend {
  my ($filename, $mode)=@_;
  my $fh = undef;
  my $cmd = "";
  if ($filename and -r $filename) {
    if ($mode =~/[w\>]/) {
      $cmd = "| $CSTSBackend::gzip" if ($filename=~/.gz$/);
      $cmd="$CSTSBackend::fs2csts $cmd > \"$filename\"";
      print STDERR "[w $cmd]\n" if $Fslib::Debug;
      eval {
	$fh = new IO::Pipe();
	$fh && $fh->writer($cmd);
      } || return undef;
    } else {
      if ($filename=~/.gz$/) {
	$cmd = "$CSTSBackend::zcat < \"$filename\" | $CSTSBackend::csts2fs";
      } else {
	$cmd="$CSTSBackend::csts2fs < \"$filename\"";
      }
      print STDERR "[r $cmd]\n" if $Fslib::Debug;
      eval {
	$fh = new IO::Pipe();
	$fh && $fh->reader($cmd);
      } || return undef;
    }
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

=item test (filehandle | filename)

Test if given file can be converted to FSFormat using the external
utilities. If the argument is a file-handle the filehandle is supposed
to be open by previous call to C<open_backend> and therefore input in
FS format is expected.  In this case, the calling application may need
to close the handle and reopen it in order to seek the beginning of
the file after the test has read few characters or lines from it.

=cut

sub test {
  my ($f)=@_;
  if (ref($f)) {
    return FSBackend::test($f);
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && FSBackend::test($fh);
    close_backend($fh);
    return $test;
  }
}


=pod

=back

=cut

1;
