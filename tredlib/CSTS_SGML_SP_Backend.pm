package CSTS_SGML_SP_Backend;

use Csts2fs;
use Fs2csts;

$CSTS_SGML_SP_Backend::zcat = "/bin/zcat";
$CSTS_SGML_SP_Backend::gzip = "/usr/bin/gzip";

$CSTS_SGML_SP_Backend::sgmls = "nsgmls -i preserve.gen.entities";
$CSTS_SGML_SP_Backend::doctype = "csts/csts.doctype";

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
  if ($filename) {
    if ($mode =~/[w\>]/) {
      if ($filename=~/.gz$/) {
	eval {
	  $fh = new IO::Pipe();
	  $fh && $fh->writer("| $CSTS_SGML_SP_Backend::gzip > $filename");
	} || return undef;
	print STDERR "[w $cmd]\n";
      } else {
	eval { $fh = new IO::File(); } || return undef;
	$fh->open($filename,$mode) || return undef;
      }
    } else {
      if ($filename=~/.gz$/) {
	$cmd = "$CSTS_SGML_SP_Backend::zcat < \"$filename\" | $CSTS_SGML_SP_Backend::sgmls $CSTS_SGML_SP_Backend::doctype";
      } else {
	$cmd="$CSTS_SGML_SP_Backend::sgmls $CSTS_SGML_SP_Backend::doctype $filename";
      }
      print STDERR "[r $cmd]\n";
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
  Csts2fs::read(@_);
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  Fs2csts::write(@_);
}

=pod

=item test (filehandle | filename)

=cut


sub test {
  my ($f)=@_;
  if (ref($f)) {
    return $f->getline()=~/^Alang|\(csts/;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}


