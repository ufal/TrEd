package StorableBackend;
use Fslib;
use Storable qw(nstore_fd fd_retrieve);
use IO::Pipe;
use vars qw(@ISA);
use Data::Dumper;
import ZBackend;
use strict;

BEGIN {
  print "Loaded Storable backend;\n";
  @ISA=('ZBackend');
};

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
    my $fh = open_backend($f,"r",$encoding);
    my $test = $fh && test($fh,$encoding);
    close_backend($fh);
    return $test;
  }
}

=pod

=item read (handle_ref,fsfile)

=cut

sub read {
  my ($fd,$fs)=@_;
  binmode($fd);
  my $restore = fd_retrieve($fd);
  $fs->changeFS($restore->[0]);
  $fs->changeTrees(@{$restore->[1]});
  $fs->changeTail(@{$restore->[2]});
  $fs->[13]=$restore->[3];
  $fs->changePatterns(@{$restore->[4]});
  $fs->changeHint($restore->[5]);
}


=pod

=item write (handle_ref,fsfile)

=cut

sub write {
  my ($fd,$fs)=@_;
  binmode($fd);
  nstore_fd([$fs->FS,$fs->treeList,[$fs->tail],$fs->[13],[$fs->patterns],$fs->hint],$fd);
}



=pod

=back

=cut
1;
