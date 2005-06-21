package NTREDBackend;
use Fslib;
use Storable qw(nfreeze thaw);
use MIME::Base64;
use IOBackend;
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
    if ($mode eq 'w') {
      $cmd = "| $ntred -Q --upload-file \"$filename\" ";
      print STDERR "[w $cmd]\n" if $Fslib::Debug;
      eval { open $fh,"$cmd"; } || return undef;
    } else {
      $cmd = "$ntred -Q --dump-files \"$filename\" |";
      print STDERR "[r $cmd]\n" if $Fslib::Debug;
      eval { open $fh,"$cmd"; } || return undef;
    }
  }
  return IOBackend::set_encoding($fh,$encoding);
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
  my ($fd,$fs)=@_;
  my $fs_files = Storable::thaw(decode_base64(join "",<$fd>));
  my $restore = $fs_files->[0];
  if (ref($restore)) {
    $fs->changeFS($restore->[0]);
    $fs->changeTrees(@{$restore->[1]});
    $fs->changeTail(@{$restore->[2]});
    $fs->[13]=$restore->[3];
    $fs->changePatterns(@{$restore->[4]});
    $fs->changeHint($restore->[5]);
    $fs->FS->renew_specials();
  }
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  my ($fh,$fsfile)=@_;
  my $dump= [$fsfile->FS,
	     $fsfile->treeList,
	     [$fsfile->tail],
	     $fsfile->[13],
	     [$fsfile->patterns],
	     $fsfile->hint];
  eval {
    print $fh (encode_base64(Storable::nfreeze([$dump])));
    print $fh ("\n");
  };
}


=pod

=back

=cut

1;
