package Filelist;
# -*- cperl -*-

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# (TrEd's) filelist handling routines

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

use Fslib;

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
     current => undef
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
  return ref($self) ? $self->{name} : undef;
}


=pod

=item rename (new_name)

Re-name the file-list

=cut

sub rename {
  my ($self,$new_name)=@_;
  return undef unless ref($self);
  return $self->{name}=$new_name;
}

=pod

=item filename (new_name?)

Return/change file name of the file-list (path to the file where the
filelist is (or is to be) saved.

=cut

sub filename {
  my ($self,$new_name)=@_;
  return undef unless ref($self);
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
  return undef unless ref($self);
  do {
    local *F;
    print "Saving to: ",$self->filename,"\n";
    if (defined ($self->filename) and $self->filename ne "") {
      open F,">".$self->filename;
    } else {
      *F=*STDOUT;
    }
    print F $self->{name},"\n";
    print F join("\n",$self->list),"\n";
    if (defined ($self->filename) and $self->filename ne "") {
      close F;
    }
  }
}

=item load

Read a file list form a file whose name is set/obtained via the
filename method, or from the standard input, if no filename is given.

=cut

sub load {
  my ($self)=@_;
  return undef unless ref($self);
  do {
    local *F;
    if (defined ($self->filename) and $self->filename ne "") {
      open F,"<".$self->filename;
      chomp ($self->{name} = <F>);
      @{ $self->list_ref } = <F>; #grep { -f $_ } <F>;
      chomp @{ $self->list_ref };
      @{ $self->list_ref } = grep $_ ne "", @{ $self->list_ref };
      close F;
    } else {
      @{ $self->list_ref }=();
      return;
    }
  };
  $self->expand;
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
  return undef unless ref($self);
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
  return undef unless ref($self);
  return $self->{files};
}

=pod

=item files

Return a list of all file names in the list

=cut

sub files {
  my $self = shift;
  return undef unless ref($self);
  return map { $_->[0] } @{ $self->{files} };
}

=pod

=item list_ref

Return a reference to the internal pattern list

=cut

sub list_ref {
  my $self = shift;
  return undef unless ref($self);
  return $self->{list};
}

=pod

=item list

Return a list of all patterns in the file list

=cut

sub list {
  my $self = shift;
  return undef unless ref($self);
  return @{$self->{list}};
}

=pod

=item file_count

Return the total number of all files in the list

=cut

sub file_count {
  my $self = shift;
  return undef unless ref($self);
  return scalar(@{$self->{files}});
}

=pod

=item count

Return the number of all patterns in the list

=cut

sub count {
  my $self = shift;
  return undef unless ref($self);
  return $#{$self->{list}}+1;
}

=pod

=item expand

Expand all patterns in the filelist and store them in the internal
list of filenames

=cut

sub expand {
  my $self = shift;
  return undef unless ref($self);
  @{ $self->files_ref }=();
  foreach my $i (0..$self->count-1) {
    push @{ $self->files_ref },
      $self->list_ref->[$i]=~/[\[\{\*\?]/ ?
	map { [$_,$i] } glob($self->list_ref->[$i]) :
	  [$self->list_ref->[$i],$i];
  }

  my %saw;
  @{ $self->files_ref } = grep( ref($_) && $_->[0] ne "" && !$saw{$_->[0]}++, @{ $self->files_ref } );

  return 1;
}

=pod

=item file_at (n)

Return the n'th file name in the list

=cut

sub file_at {
  my ($self,$index) = @_;
  return undef unless ref($self);
  return undef if $self->file_count() <= $index;
  return undef unless ref($self->files_ref->[$index]);
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
  return undef unless ref($self);
  $fsfile=$self->current() unless defined($fsfile);
  my $files=$self->files_ref;
  my $fname=ref($fsfile) ? $fsfile->name() : $fsfile;
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
  return undef unless ref($self);
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
  return undef unless ref($self);
  return $self->list_ref->[$self->file_pattern_index($index)];
}

=pod

=item add (position, patterns)

Insert patterns on the given position in the list and update
file-list

=cut

sub add {
  my ($self,$position)=(shift,shift);
  return undef unless ref($self);

  # never add elements already present here or in files
  # and add each element once only
  @_=grep {defined($_) and $_ ne ""} @_;
  do {
    my %saw;
    $saw{$_}=1 for (@{ $self->list_ref },(map {$_->[0]} @{ $self->files_ref }));
    @_=grep{ !($saw{$_}++) } @_;
  };
  splice @{ $self->list_ref },$position,0,@_;
  $self->expand();
  return 1;
}

=pod

=item remove (patterns+)

Remove given patterns from the list and update file-list

=cut

sub remove {
  my ($self)=shift;
  return undef unless ref($self);

  print "Filelist.pm: removing @_\n";

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
  return undef unless ref($self);
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
  return undef unless ref($self);
  for (my $i=0; $i< $self->count; $i++) {
    return $i if $self->list_ref->[$i] eq $pattern;
  }
  return -1;
}


1;

__END__

=head1 AUTHOR

Petr Pajas

=head1 SEE ALSO

L<tred(1)|tred>, L<Fslib(1)|Fslib>.

=cut
