package CSTS_SGML_SP_Backend;

use Csts2fs;
use Fs2csts;

use vars qw($zcat $gzip $sgmls $sgmlsopts $doctype);

sub default_settings {
  $zcat = "/bin/zcat" unless $zcat;
  $gzip = "/usr/bin/gzip" unless $gzip;

  $sgmls = "nsgmls" unless $sgmls;
  $sgmlsopts = "-i preserve.gen.entities" unless $sgmlsopts;
  $doctype = "csts.doctype" unless $doctype;

  $sgmls_command='%s %o %d %f' unless $sgmls_command;
  $z_sgmls_command='%z < %f | %s %o %d -' unless $z_sgmls_command;
}

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

  if ($mode =~/[w\>]/) {
    if ($filename=~/.gz$/) {
      eval {
	$fh = new IO::Pipe();
	$fh && $fh->writer("$gzip > $filename");
      } || return undef;
	print STDERR "[w $cmd]\n" if $Fslib::Debug;
    } else {
      eval { $fh = new IO::File(); } || return undef;
      $fh->open($filename,$mode) || return undef;
    }
  } else {
    if ($filename and -r $filename) {
      if ($filename=~/.gz$/) {
	return undef unless -x $zcat;
	$cmd=$z_sgmls_command;
      } else {
	$cmd=$sgmls_command;
      }
      print STDERR "$cmd\n" if $Fslib::Debug;
      $cmd=~s/\%f/"$filename"/g;
      $cmd=~s/\%s/$sgmls/g;
      $cmd=~s/\%o/$sgmlsopts/g;
      $cmd=~s/\%d/$doctype/g;
      $cmd=~s/\%z/$zcat/g;
      print STDERR "[r $cmd]\n" if $Fslib::Debug;
      eval {
	if ($^O eq 'MSWin32') {
	  $fh = new IO::File();
	  $fh && $fh->open("$cmd |");
	} else {
	  $fh = new IO::Pipe();
	  $fh && $fh->reader($cmd);
	}
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


sub test_nsgmls {
  return 1 if (-x $nsgmls);
  foreach (split(($^O eq 'MSWin32' ? ';' : ':'),$ENV{PATH})) {
    return 1 if -x "$_".($^O eq 'MSWin32' ? "\\" : "/")."$nsgmls";
  }
  print STDERR "nsgmls not found at $nsgmls\n" if $Fslib::Debug;
  return 0;
}

sub test {
  my ($f)=@_;

  return 0 unless test_nsgmls();

  if (ref($f)) {
    return $f->getline()=~/^Alang|\(csts/;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh);
    close_backend($fh);
    return $test;
  }
}

BEGIN {
  default_settings();
}

1;
