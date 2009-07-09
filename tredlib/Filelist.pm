package Filelist;
# -*- cperl -*-

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# filelist handling routines

=pod

=head1 NAME

Filelist.pm - Simple filelist handling routines for TrEd

=head1 REFERENCE

=over 4

=cut

use Exporter;

@ISA=(Exporter);
$VERSION = "0.1";
@EXPORT = qw();
@EXPORT_OK = qw();

use Carp;
use vars qw( $VERSION @EXPORT @EXPORT_OK );
use File::Glob qw(:glob);
use Encode qw(encode decode);

=pod

=item new

Create a new filelist object

=cut

sub new {
  my ($self,$name,$filename) = @_;
  my $class = ref($self) || $self;
  my $new =
    {
     name => $name,
     filename => $filename,
     list => [],
     files => [],
     current => undef,
     load => undef,
    };
  bless $new, $class;
  return $new;
}

=pod

=item name

Return name of the file-list

=cut

sub name {
  my ($self)=@_;
  $self->_load_name;
  return ref($self) ? $self->{name} : undef;
}


=pod

=item rename (new_name)

Re-name the file-list

=cut

sub rename {
  my ($self,$new_name)=@_;
  return unless ref($self);
  return $self->{name}=$new_name;
}

=pod

=item filename (new_name?)

Return/change file name of the file-list (path to the file where the
filelist is (or is to be) saved.

=cut

sub filename {
  my ($self,$new_name)=@_;
  return unless ref($self);
  return defined($new_name) ? $self->{filename}=$new_name : $self->{filename};
}

sub max {
  my ($a,$b)=@_;
  return ($a<$b)?$b:$a;
}

sub dirname {
  my ($self)=@_;
  if ($^O eq "MSWin32") {
    $Ds="\\"; # how filenames and directories are separated
  } else {
    $Ds='/';
  }
  my $f=$self->filename();
  return (index($f,$Ds)+index($f,'/')>=0)? substr($f,0,
				    max(rindex($f,$Ds),
					rindex($f,'/'))+1) : ".$Ds";
}


=pod

=item save

Write the list of patterns to a file whose filename is stored/obtained via
the filename method, or to standard output, if no filename is given.

=cut

sub save {
  my ($self)=@_;
  return unless ref($self);
  my $fh;
  if (defined($self->filename) and
      defined($self->{load}) and
	$self->{load} eq $self->filename) {
    # no need to actually save - not changed
    return;
  }

  if (defined ($self->filename) and $self->filename ne "") {
    open $fh, ">", $self->filename or
      warn "Couldn't save filelist to '".$self->filename."': $!\n";
  } else {
    $fh=\*STDOUT;
  }
  print $fh encode('UTF-8',$self->{name}),"\n";
  print $fh join("\n",$self->list),"\n";
  if (defined ($self->filename) and $self->filename ne "") {
    close $fh;
  }
  return 1;
}

=item load

Read a file list form a file whose name is set/obtained via the
filename method, or from the standard input, if no filename is given.

=cut

sub _lazy_load {
  my ($self)=@_;
  return unless defined $self->{load};
  open $fh,"<",$self->{load}
      or croak("Cannot open $self->{load}: $!\n");
  undef $self->{load};
  $self->{name} = decode('UTF-8',scalar(<$fh>));
  $self->{name} =~ s/[\r\n]+$//;
  @{ $self->list_ref } = <$fh>; #grep { -f $_ } <$fh>;
  s/[\r\n]+$// for @{ $self->list_ref };
  @{ $self->list_ref } = grep $_ ne "", @{ $self->list_ref };
  close $fh;
  $self->expand;
  return 1;
}

sub _load_name {
  my ($self)=@_;
  return unless defined $self->{load} and !defined($self->{name});
  open $fh,"<",$self->{load}
      or croak("Cannot open $self->{load}: $!\n");
  $self->{name} = decode('UTF-8',scalar(<$fh>));
  $self->{name} =~ s/[\r\n]+$//;
  close $fh;
  return 1;
}

sub load {
  my ($self)=@_;
  return unless ref($self);
  if (defined ($self->filename) and $self->filename ne "") {
    $self->{load}=$self->filename;
    undef $self->{name};
    return 1;
  } else {
    @{ $self->list_ref }=();
    return;
  }
}

=pod

=item current

Return current file's name or undef if no current file is defined.

Note: the feature of current file is completely user-driven

=cut

sub current {
  my ($self)=@_;
  return ref($self) ? $self->{current} : undef;
}

=pod

=item set_current (filename)

Let given file be the current file in the file-list (completely user-driven).

=cut

sub set_current {
  my ($self,$filename)=@_;
  return unless ref($self);
  return $self->{current}=$filename;
}


=pod

=item files_ref

Return a reference to internal list containing expanded file names
as pairs L<[filename,idx]>, where idx is the index of a pattern
in filelist, which had brought the file name to the list

=cut

sub files_ref {
  my $self = shift;
  return unless ref($self);
  $self->_lazy_load;
  return $self->{files};
}

=pod

=item files

Return a list of all file names in the list

=cut

sub files {
  my $self = shift;
  return unless ref($self);
  return map { $_->[0] } @{ $self->files_ref };
}

=pod

=item list_ref

Return a reference to the internal pattern list

=cut

sub list_ref {
  my $self = shift;
  return unless ref($self);
  $self->_lazy_load;
  return $self->{list};
}

=pod

=item list

Return a list of all patterns in the file list

=cut

sub list {
  my $self = shift;
  return unless ref($self);
  return @{$self->list_ref};
}

=pod

=item file_count

Return the total number of all files in the list

=cut

sub file_count {
  my $self = shift;
  return unless ref($self);
  return scalar(@{$self->files_ref});
}

=pod

=item count

Return the number of all patterns in the list

=cut

sub count {
  my $self = shift;
  return unless ref($self);
  return $#{$self->list_ref}+1;
}

=pod

=item expand

Expand all patterns in the filelist and store them in the internal
list of filenames

=cut

sub expand {
  my $self = shift;
  return unless ref($self);
  my $fr = $self->files_ref;
  my $lr = $self->list_ref;
  @$fr=();
  foreach my $i (0..$self->count-1) {
    my $f = $lr->[$i];
    push @$fr,
      ($f=~m/[\[\{\*\?]/ and $f!~m{^[[:alnum:]]+://}) ?
	(map { [$_,$i] } glob($f)) : [$f,$i];
  }
  my %saw;
  @$fr = grep( ref($_) && $_->[0] ne "" && !$saw{$_->[0]}++, @$fr );
  return 1;
}

=pod

=item file_at (n)

Return the n'th file name in the list

=cut

sub file_at {
  my ($self,$index) = @_;
  return unless ref($self);
  return if $self->file_count() <= $index;
  return unless ref($self->files_ref->[$index]);
  return $self->files_ref->[$index]->[0];
}

=item position (fsfile?)

If the argument is FSFile object, return an index of the filename
corresponding to the given FSFile object. IF the argument is string,
return an index of the string in the file list. If no argument is given,
return index of current file.

=cut

sub position {
  my ($self,$fsfile) = @_;
  return unless ref($self);
  $fsfile=$self->current() unless defined($fsfile);
  my $files=$self->files_ref;
  my $fname=ref($fsfile) ? $fsfile->filename() : $fsfile;
  my $basedir=$self->dirname();
  my $relfname=$fname;
  if (index($fname,$basedir)==0) {
    $relfname=substr($fname,length($basedir));
  }
  for (my $i=0; $i < $self->file_count; $i++) {
    return $i if ($fname eq $files->[$i]->[0]
		  or
		  $relfname eq $files->[$i]->[0]
		 );
  }
  return -1;
}


=pod

=item file_pattern_index (n)

Return the index of the pattern which has generated the n'th file

=cut

sub file_pattern_index {
  my ($self,$index) = @_;
  return unless ref($self);
  if ($index<0) {
    return -1;
  }
  return $self->files_ref->[$index]->[1];
}

=pod

=item file_pattern (n)

Return the pattern which has generated the n'th file

=cut

sub file_pattern {
  my ($self,$index) = @_;
  return unless ref($self);
  return $self->list_ref->[$self->file_pattern_index($index)];
}

=pod

=item add (position, patterns)

Insert patterns on the given position in the list and update
file-list

=cut

sub add {
  my ($self,$position)=(shift,shift);
  return unless ref($self);

  # never add elements already present here or in files
  # and add each element once only
  {
    my $lr = $self->list_ref;
    my %saw;
    $saw{$_}=1 for (@$lr, map($_->[0], @$lr));
    splice @$lr,$position,0, grep !($saw{$_}++), grep defined($_) && $_ ne "", @_;
  }
  $self->expand();
  return 1;
}

=pod

=item add_arrayref (position, patterns_arrayref)

Insert patterns from a given ARRAYREF on the given position in the list and update
file-list

=cut

sub add_arrayref {
  my ($self,$position,$list)=@_;
  return unless ref($self);

  # never add elements already present here or in files
  # and add each element once only
  my $lr = $self->list_ref;
  {
    my %saw;
    $saw{$_}=1 for (@$lr,map($_->[0], @$lr));
    splice @$lr, $position,0, grep !($saw{$_}++), grep defined($_) && $_ ne "", @$list;
  }
  $self->expand();
  return 1;
}



=item remove (patterns+)

Remove given patterns from the list and update file-list

=cut

sub remove {
  my ($self)=shift;
  return unless ref($self);
  do {
    my %remove = map { $_ => 1 } @_;
    @{ $self->list_ref }=grep(!$remove{$_}++,@{ $self->list_ref }); #remove and uniq
  };
  $self->expand();
  return 1;
}

=pod

=item clear

Remove all patterns from a filelist

=cut

sub clear {
  my ($self)=shift;
  return unless ref($self);
  @{ $self->list_ref }=();
  $self->expand();
  return 1;
}


=pod

=item find_pattern (pattern)

Return index of a given pattern in the filelist or -1 if not found.

=cut

sub find_pattern {
  my ($self,$pattern)=@_;
  return unless ref($self);
  for (my $i=0; $i< $self->count; $i++) {
    return $i if $self->list_ref->[$i] eq $pattern;
  }
  return -1;
}


1;

__END__

=head1 AUTHOR

Petr Pajas

=cut
