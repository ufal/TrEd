package CSTS_SGML_SP_Backend;

use IOBackend qw(handle_protocol set_encoding);
use Csts2fs;
use Fs2csts;

use vars qw($zcat $gzip $sgmls $sgmlsopts $doctype);

sub default_settings {
  $zcat = "/bin/zcat" unless $zcat;
  $gzip = "/usr/bin/gzip" unless $gzip;

  $sgmls = "nsgmls" unless $sgmls;
  $sgmlsopts = "-i preserve.gen.entities" unless $sgmlsopts;
  $doctype = "csts.doctype" unless $doctype;

  $sgmls_command='%s %o %d' unless $sgmls_command;
}

=item open_backend (filename,mode, encoding?)

Open given file for reading or writing (depending on mode which may be
one of "r" or "w"); Return the corresponding object blessed to
File::Pipe. Only files the filename of which ends with '.gz' are
considered to be gz-commpressed.

Optionally, in perl ver. >= 5.8, you may also specify file character
encoding.

=cut

sub open_backend {
  my ($filename, $mode, $encoding)=@_;
  if ($mode eq 'w') {
    return IOBackend::open_backend($filename,$mode,$encoding);
  } elsif ($mode eq 'r') {
    my $fh = undef;
    my $cmd = $sgmls_command;
    print STDERR "$cmd\n" if $Fslib::Debug;
    $cmd=~s/\%s/$sgmls/g;
    $cmd=~s/\%o/$sgmlsopts/g;
    $cmd=~s/\%d/$doctype/g;
    $cmd=~s/\%f/-/g;
    print STDERR "[r $cmd]\n"; # if $Fslib::Debug;
    no integer;
    $fh = set_encoding(IOBackend::get_store_fh($filename,$cmd),$encoding);
  } else {
    die "unknown mode $mode\n";
  }
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

=item test (filehandle | filename, encoding?)

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
  my ($f,$encoding)=@_;

  return 0 unless test_nsgmls();
  if (ref($f)) {
    my $line=$f->getline();
    return $line=~/^\s*<csts[ >]/;
  } else {
    my $fh = IOBackend::open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

BEGIN {
  default_settings();
}

1;
