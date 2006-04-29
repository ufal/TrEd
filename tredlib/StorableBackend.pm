package StorableBackend;
use Fslib;
use Storable qw(nstore_fd fd_retrieve);
use IOBackend qw( close_backend);
use strict;


=pod

=head1 StorableBackend

Backend for storing data using perl Storable module.

=head2 REFERENCE

=over 4

=cut

=item test (filename)

Return true if the given filename contains a .str suffix.

=cut

sub test {
  my ($f,$encoding)=@_;
  if (ref($f)) {
    return $f->getline()=~/^pst0/;
  } else {
    my $fh = open_backend($f,"r");
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

sub open_backend {
  IOBackend::open_backend(@_[0,1]);
}

=pod

=item read (handle_ref,fsfile)

=cut

sub read {
  my ($fd,$fs)=@_;
  binmode($fd);
  my $restore = fd_retrieve($fd);

  my $api_version = $restore->[6];
  if ($api_version ne $Fslib::API_VERSION) {
    warn "Warning: the binary file ".$fs->filename." is a dump of structures created by possibly incompatible Fslib API version $api_version (the current Fslib API version is $Fslib::API_VERSION)\n";
  }

  $fs->changeFS($restore->[0]);
  $fs->changeTrees(@{$restore->[1]});
  $fs->changeTail(@{$restore->[2]});
  $fs->[13]=$restore->[3]; # metaData
  $fs->changePatterns(@{$restore->[4]});
  $fs->changeHint($restore->[5]);
  $fs->FS->renew_specials();
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  my ($fd,$fs)=@_;
  binmode($fd);
  nstore_fd([$fs->FS,
	     $fs->treeList,
	     [$fs->tail],
	     $fs->[13], # metaData
	     [$fs->patterns],
	     $fs->hint,
	     $Fslib::API_VERSION
	    ],$fd);
}



=pod

=back

=cut
1;
