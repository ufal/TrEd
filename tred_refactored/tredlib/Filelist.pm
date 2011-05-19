package Filelist;
# -*- cperl -*-

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# filelist handling routines

use strict;

=pod

=head1 NAME

Filelist.pm - Simple filelist handling routines for TrEd

=head1 REFERENCE

=over 4

=cut

use Exporter;

use base qw(Exporter);
our $VERSION = "0.1";
our @EXPORT = qw();
our @EXPORT_OK = qw();

use Carp;
use vars qw( $VERSION @EXPORT @EXPORT_OK );
use File::Glob qw(:glob);
use Cwd;
use Encode qw(encode decode);
use TrEd::MinMax qw(max2);

=pod

=item new

Create a new filelist object

=cut

sub new {
  my ($self, $name, $filename) = @_;
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


#######################################################################################
# Usage         : $file_list->name()
# Purpose       : Return name of the file-list
# Returns       : Filelist's name
#                 Undef if not called on Filelist object.
# Parameters    : no
# Throws        : no exceptions
sub name {
  my ($self) = @_;
  return if not ref $self;
  eval { $self->_load_name() };
  
  return $self->{name};
}

#######################################################################################
# Usage         : $file_list->rename($new_name)
# Purpose       : Rename the filelist
# Returns       : Filelist's new name
#                 Undef if not called on Filelist object.
# Parameters    : string $new_name -- new name for filelist
# Throws        : no exceptions
sub rename {
  my ($self, $new_name) = @_;
  return if not ref $self;
  return $self->{name} = $new_name;
}


#######################################################################################
# Usage         : $file_list->filename([$new_filename])
# Purpose       : Return/change file name of the file-list (path to the file where the
#                 filelist is (or is to be) saved.
# Returns       : Filename of the filelist (new one if it is a setter). 
#                 Undef if not called on Filelist object.
# Parameters    : string $new_filename -- new filename for filelist
# Throws        : no exceptions
sub filename {
  my ($self, $new_name) = @_;
  return if not ref $self;
  return defined($new_name) ? $self->{filename} = $new_name : $self->{filename};
}

#######################################################################################
# Usage         : _filelist_path_without_dir_sep($file_path, $dir_separator)
# Purpose       : Tell whether path contains directory separator or default dir separator
# Returns       : True if path contains directory separator, false otherwise
# Parameters    : string $file_path     -- string of path to tested file
#                 string $dir_separator -- directory separator for current platform
# Throws        : no exceptions
sub _filelist_path_without_dir_sep {
  my ($file_path, $dir_separator) = @_;
  return (index($file_path, $dir_separator) >= 0 || index($file_path, q{/}) >= 0);
}

#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
sub dirname {
  my ($self) = @_;
  my $dir_separator;
  if ($^O eq 'MSWin32') {
    $dir_separator = qq{\\}; # how filenames and directories are separated
  }
  else {
    $dir_separator = q{/};
  }
  my $f = $self->filename();
  my $last_separator_pos = TrEd::MinMax::max2(rindex($f, $dir_separator), rindex($f, q{/})) + 1;
  return (_filelist_path_without_dir_sep($f, $dir_separator)) ? substr($f, 0, $last_separator_pos) : ".$dir_separator";
}

#######################################################################################
# Usage         : $filelist->_filename_not_empty()
# Purpose       : Tell whether filename is defined and empty
# Returns       : True if filelist's filename is defined and empty, false otherwise
# Parameters    : no
# Throws        : no exceptions
# Comments      : 
# See also      : 
sub _filename_not_empty {
  my ($self) = @_;
  return (defined ($self->filename()) and $self->filename() ne q{});
}


#######################################################################################
# Usage         : $filelist->save()
# Purpose       : Write the list of patterns to a file whose filename is obtained via
#                 the filename method
# Returns       : 1 if successful, undef if not called on object or if there is no 
#                 need to save the filelist
# Parameters    : no
# Throws        : Warns if the $filename file could not be opened for writing
# Comments      : If no filename is given, filelist is written to standard output.
#                 Filelist's name goes on the first line of new file, list of 
#                 files/positions follows, every item on its own line
# See also      : load()
sub save {
  my ($self) = @_;
  return if not ref $self;
  my $fh;
  # no need to save - not changed
  if (defined($self->filename) and defined($self->{load}) and 
      $self->{load} eq $self->filename()) {
    return;
  }

  if ($self->_filename_not_empty()) {
    open $fh, ">", $self->filename() or
      warn "Couldn't save filelist to '" . $self->filename() . "': $!\n";
  }
  else {
    $fh = \*STDOUT;
  }
  
  print $fh encode('UTF-8', $self->{name}),"\n";
  print $fh join("\n", $self->list()),"\n";
  if ($self->_filename_not_empty()) {
    close $fh;
  }
  return 1;
}

#######################################################################################
# Usage         : $filelist->_lazy_load()
# Purpose       : Loads the file-list into class's internal data structures
# Returns       : 1 if successful, undef otherwise
# Parameters    : no
# Throws        : Croaks if the file could not be opened or closed.
# Comments      : Removes empty lines, duplicate filenames, but does not remove duplicate patterns
# See also      : load()
# Tested by other public functions, no test on its own
sub _lazy_load {
  my ($self) = @_;
  return if not defined $self->{load};
  open my $fh, "<", $self->{load}
      or croak("Cannot open $self->{load}: $!\n");

  undef $self->{load};
  
  $self->{name} = decode('UTF-8',scalar(<$fh>));
  
  @{ $self->list_ref() } = <$fh>;
  close $fh
    or croak("Cannot open $self->{load}: $!\n");
  
  # remove newlines from filelist name
  $self->{name} =~ s/[\r\n]+$//;
  # and from file names
  foreach my $file (@{ $self->list_ref() }) {
    $file =~ s/[\r\n]+$//;
  }
  
  # remove empty lines
  @{ $self->list_ref() } = grep { $_ ne q{} } @{ $self->list_ref() };
  
  # expand glob patterns, if any...
  $self->expand();
  return 1;
}

#######################################################################################
# Usage         : $filelist->_load_name()
# Purpose       : Load filelist's name from filelist file
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : no
# Throws        : Croaks if the file could not be opened or closed
# Comments      : Function assumes that filelists's name is on the first line of the filelist
# See also      : name(), rename()
# Tested by other public functions, no test on its own
sub _load_name {
  my ($self) = @_;
  return if (!defined $self->{load} || defined $self->{name});
  if (open my $fh, "<", $self->{load}) {
    $self->{name} = decode('UTF-8', scalar(<$fh>));
    $self->{name} =~ s/[\r\n]+$//;
    close $fh
      or croak("Cannot close $self->{load}: $!\n");
    return 1;
  }
  else {
    croak("Cannot open $self->{load}: $!\n");
  }
}

#######################################################################################
# Usage         : $filelist->load()
# Purpose       : Read a file list form a file whose name is set/obtained via the
#                 filename method
# Returns       : 1 if load was successful, undef/empty list otherwise
# Parameters    : no
# Throws        : no exceptions
# Comments      : Implementaion is actually lazy, so the filelist is loaded when it is 
#                 needed (when list(), files() or similar methods are invoked)
#TODO: support stdin?
sub load {
  my ($self) = @_;
  return if not ref $self;
  if ($self->_filename_not_empty()) {
    $self->{load} = $self->filename();
    undef $self->{name};
    $self->_load_name();
    return 1;
  }
  else {
    @{ $self->list_ref() } = ();
    return 1;
  }
}

#######################################################################################
# Usage         : $filelist->current()
# Purpose       : Return current file's name
# Returns       : Current file's name or undef if no current file is defined.
# Parameters    : no
# Throws        : no exceptions
# Comments      : The feature of current file is completely user-driven
# See also      : set_current()
sub current {
  my ($self) = @_;
  if (ref $self) {
    return $self->{current};
  }
  else {
    return;
  }
}


#######################################################################################
# Usage         : $filelist->set_current($filename)
# Purpose       : Let given file be the current file in the file-list
# Returns       : The new current filename
# Parameters    : string $filename  -- name of the file which is to become the current one
# Throws        : no exceptions
# Comments      : Not checked, if it exists or if it is part of the filelist.
#                 The feature of current file is completely user-driven.
# See also      : current()
sub set_current {
  my ($self, $filename) = @_;
  return if not ref $self;
  return $self->{current} = $filename;
}


#######################################################################################
# Usage         : $filelist->files_ref()
# Purpose       : Return a reference to internal list of file names
# Returns       : Reference to list containing expanded file names
#                 as pairs (filename, idx), where idx is the index of a pattern
#                 in filelist, which had brought the file name to the list
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the file list contains glob pattern, it is expanded and all the files
#                 are returned. Invokes lazy loading if the list is not already loaded 
#                 (opening & reading from filelist)
# See also      : files()
sub files_ref {
  my $self = shift;
  return if not ref $self;
  $self->_lazy_load();
  return $self->{files};
}


#######################################################################################
# Usage         : $filelist->files()
# Purpose       : Return a list of all file names in the list
# Returns       : List of all file names in the list
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the file list contains glob pattern, it is expanded and all the files
#                 are returned. Invokes lazy loading if the list is not already loaded 
#                 (opening & reading from filelist)
# See also      : files_ref()
sub files {
  my $self = shift;
  return if not ref $self;
  return map { $_->[0] } @{ $self->files_ref() };
}

#######################################################################################
# Usage         : $filelist->list_ref()
# Purpose       : Return a reference to the filelist's item list 
# Returns       : Reference to the internal pattern list
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the file list contains glob pattern, it is NOT expanded and it is 
#                 considered one item/pattern. 
#                 Invokes lazy loading if the list is not already loaded 
#                 (opening & reading from filelist) 
# See also      : list()
sub list_ref {
  my $self = shift;
  return if not ref $self;
  $self->_lazy_load();
  return $self->{list};
}


#######################################################################################
# Usage         : $filelist->list()
# Purpose       : Return a list of all patterns in the file list
# Returns       : List of all items in the file list
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the file list contains glob pattern, it is NOT expanded and it is 
#                 considered one item/pattern. 
#                 Invokes lazy loading if the list is not already loaded 
#                 (opening & reading from filelist) 
# See also      : list_ref()
sub list {
  my $self = shift;
  return if not ref $self;
  return @{$self->list_ref()};
}

#######################################################################################
# Usage         : $filelist->file_count()
# Purpose       : Return the total number of all files in the list
# Returns       : Number of files in filelist (including globbed ones)
# Parameters    : no
# Throws        : no exceptions
# Comments      : If filelist contains regular file names, number of file names will be 
#                 returned. If it contains a glob pattern like 'sample_?.a.gz', 
#                 it is expanded and real number of files is returned
# See also      : count()
sub file_count {
  my $self = shift;
  return if not ref $self;
  return scalar(@{$self->files_ref()});
}

#######################################################################################
# Usage         : $filelist->count()
# Purpose       : Return the number of all files/patterns in the list
# Returns       : Number of items in the filelist
# Parameters    : no
# Throws        : no exceptions
# Comments      : If filelist contains regular file names, number of file names will be 
#                 returned. If it contains a glob pattern like 'sample_?.a.gz', this pattern
#                 is counted as +1, no matter how many files match this pattern.
# See also      : file_count()
sub count {
  my $self = shift;
  return if not ref $self;
  return $#{$self->list_ref()} + 1;
}

#######################################################################################
# Usage         : $filelist->expand()
# Purpose       : Expand all patterns in the filelist and store them in the internal
#                 list of filenames
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
sub expand {
  my $self = shift;
  return if not ref $self;
  my $files_ref = $self->files_ref();
  my $list_ref = $self->list_ref();
  @{$files_ref} = ();
  
  # change directory to filelist's dir
  my $cwd = cwd();
  chdir($self->dirname());
  
  # expand items in playlist
  foreach my $i (0..$self->count()-1) {
    my $f = $list_ref->[$i];
    # add one file or a list of files, if $f is a pattern
    # not sure, though, why $f can not start with some numbers followed by '://'
    # and what does it mean, if it does
    push @{$files_ref},
      ($f =~ m/[\[\{\*\?]/ and $f !~ m{^[[:alnum:]]+://}) ? (map { [$_, $i] } glob($f)) 
                                                          : [$f, $i];
  }
  
  # change directory back
  chdir($cwd);
  
  my %saw;
  # remove duplicates
  @{$files_ref} = grep 
                    { ref($_) && $_->[0] ne q{} && !$saw{$_->[0]}++ } 
                    @{$files_ref};
  return 1;
}

#TODO continue down here
=pod

=item file_at (n)

Return the n'th file name in the list

=cut
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
sub file_at {
  my ($self,$index) = @_;
  return unless ref($self);
  return if $self->file_count() <= $index;
  return unless ref($self->files_ref->[$index]);
  return $self->files_ref->[$index]->[0];
}

=item position (fsfile?)

If the argument is Treex::PML::Document object, return an index of the filename
corresponding to the given Treex::PML::Document object. IF the argument is string,
return an index of the string in the file list. If no argument is given,
return index of current file.

=cut
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
sub add {
  my ($self, $position) = (shift, shift);
  my @patterns = @_;
  return unless ref($self);

  # never add elements already present here or in files
  # and add each element once only
  {
    my $list_ref = $self->list_ref();
    my %saw;
    for (@{$list_ref}, map {$_->[0]} @{$list_ref}) {
      $saw{$_} = 1;
    }
    splice @{$list_ref}, $position, 0, grep { !($saw{$_}++) } grep { defined($_) && $_ ne q{} } @_;
  }
  $self->expand();
  return 1;
}

=pod

=item add_arrayref (position, patterns_arrayref)

Insert patterns from a given ARRAYREF on the given position in the list and update
file-list

=cut
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
#######################################################################################
# Usage         : $filelist->dirname()
# Purpose       : Return the dirname part of filelist's filename (including trailing directory separator)
# Returns       : Part of filename string from the beginning up to the last directory separator
# Parameters    : no
# Throws        : no exceptions
# Comments      : If the filelist's filename does not contain any file separator, it is considered
#                 to be placed in the current directory and './' or '.\' is returned.
# See also      : filename()
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
