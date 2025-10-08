package Filelist;

# -*- cperl -*-

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Description:
# filelist handling routines

use strict;
use warnings;

use Exporter;

use base qw(Exporter);
our $VERSION   = "0.2";
our @EXPORT    = qw();
our @EXPORT_OK = qw();

use Carp;
use vars qw( $VERSION @EXPORT @EXPORT_OK );
use File::Glob qw(:bsd_glob);
use Cwd;
use Encode qw(encode decode);
use TrEd::MinMax qw(max2);
require TrEd::Utils;

use Readonly;

Readonly my $NOT_FOUND => -1;

#######################################################################################
# Usage         : Filelist->new($name, $filename)
# Purpose       : Create file list object
# Returns       : Filelist object
# Parameters    : string $name      -- name of the file list
#                 string $filename  -- file name of the playlist
# Throws        : no exceptions
sub new {
    my ( $self, $name, $filename ) = @_;
    my $class = ref($self) || $self;
    my $new = {
        name     => $name,
        filename => $filename,
        list     => [],
        files    => [],
        current  => undef,
        load     => undef,
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
    eval { $self->_load_name() } unless defined $self->{name};
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
    my ( $self, $new_name ) = @_;
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
    my ( $self, $new_name ) = @_;
    return if !ref $self;
    return defined($new_name)
        ? $self->{filename} = $new_name
        : $self->{filename};
}

#######################################################################################
# Usage         : _filelist_path_without_dir_sep($file_path, $dir_separator)
# Purpose       : Tell whether path contains directory separator or default dir separator
# Returns       : True if path contains directory separator, false otherwise
# Parameters    : string $file_path     -- string of path to tested file
#                 string $dir_separator -- directory separator for current platform
# Throws        : no exceptions
sub _filelist_path_without_dir_sep {
    my ( $file_path, $dir_separator ) = @_;
    return if !defined $file_path;
    return (   index( $file_path, $dir_separator ) >= 0
            || index( $file_path, q{/} ) >= 0 );
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
    if ( $^O eq 'MSWin32' ) {
        $dir_separator = qq{\\}; # how filenames and directories are separated
    }
    else {
        $dir_separator = q{/};
    }
    my $filename = $self->filename();
    my $last_separator_pos
        = defined $filename
        ? TrEd::MinMax::max2( rindex( $filename, $dir_separator ),
        rindex( $filename, q{/} ) ) + 1
        : 0;

    return ( _filelist_path_without_dir_sep( $filename, $dir_separator ) )
        ? substr( $filename, 0, $last_separator_pos )
        : ".$dir_separator";
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
    return ( defined( $self->filename() ) and $self->filename() ne q{} );
}

#######################################################################################
# Usage         : $filelist->save()
# Purpose       : Write the list of patterns to a file whose filename is obtained via
#                 the filename method
# Returns       : 1 if successful, undef if not called on a reference or if there is no
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

    # no need to save - not changed (filelist is prepared for lazy loading,
    # but wasn't loaded yet)
    if (    defined( $self->filename() )
        and defined( $self->{load} )
        and $self->{load} eq $self->filename() )
    {
        return;
    }

    if ( $self->_filename_not_empty() ) {
        open $fh, ">", $self->filename()
            or warn "Couldn't save filelist to '"
            . $self->filename()
            . "': $!\n";
    }
    else {
        $fh = \*STDOUT;
    }

    print $fh encode( 'UTF-8', $self->{name} ), "\n";
    print $fh join( "\n", $self->list() ), "\n";
    if ( $self->_filename_not_empty() ) {
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
sub _lazy_load {
    my ($self) = @_;
    my $load = $self->{load};
    undef $self->{load};
    return if not defined $load;
    my $fh;

    # - means list coming from standard input
    if ($load eq '-') {
        $fh = *STDIN;
    }
    else {
        open $fh, "<", $load
            or croak("Cannot open $load: $!\n");
    }

    @{ $self->list_ref() } = <$fh>;
    if ($load ne '-') {
        close $fh
            or croak("Cannot close $self->{load}: $!\n");
    }

    if ($load =~ /\.fl$/) {
        my $fl_name = decode('UTF-8', shift @{ $self->list_ref });
        $self->{name} ||= $fl_name;
    }

    # remove newlines from filelist name
    $self->{name} =~ s/[\r\n]+$//;

    # and from file names
    foreach my $file ( @{ $self->list_ref() } ) {
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
    return if ( !defined $self->{load} || defined $self->{name} );
    if ( open my $fh, "<", $self->{load} ) {
        $self->{name} = decode( 'UTF-8', scalar(<$fh>) );
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
sub load {
    my ($self) = @_;
    return if not ref $self;
    if ( $self->_filename_not_empty() ) {
        $self->{load} = $self->filename();

        # don't rename filelist if it was given a name
        # undef $self->{name};
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
    if ( ref $self ) {
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
    my ( $self, $filename ) = @_;
    return if not ref $self;
    $self->{current} = $filename;
    return $filename;
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
    return @{ $self->list_ref() };
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
    return scalar( @{ $self->files_ref() } );
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
    return $#{ $self->list_ref() } + 1;
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
    my $list_ref  = $self->list_ref();
    @{$files_ref} = ();

    # change directory to filelist's dir
    my $cwd = cwd();
    chdir( $self->dirname() );

    # expand items in filelist
    foreach my $i ( 0 .. $self->count() - 1 ) {
        my $f = $list_ref->[$i];

  # add one file or a list of files, if $f is a pattern
  # not sure, though, why $f can not start with some numbers followed by '://'
  # and what does it mean, if it does
        push @{$files_ref},
            ( $f =~ m/[\[\{\*\?]/ and $f !~ m{^[[:alnum:]]+://} )
            ? ( map { [ $_, $i ] } glob($f) )
            : [ $f, $i ];
    }

    # change directory back
    chdir($cwd);

    my %saw;

    # remove duplicates
    @{$files_ref} = grep { ref($_) && $_->[0] ne q{} && !$saw{ $_->[0] }++ }
        @{$files_ref};
    return 1;
}

#######################################################################################
# Usage         : $filelist->file_at($n)
# Purpose       : Return the n-th file name in the list
# Returns       : Name of the file on the n-th position in the filelist, undef if no such
#                 file exists
# Parameters    : scalar $n -- ordinal number of filename to return
# Throws        : no exceptions
# Comments      : Supports negative indices (in the same fashion as perl arrays)
# See also      : files(), files_ref()
sub file_at {
    my ( $self, $index ) = @_;
    return if not ref $self;
    return if $self->file_count() <= $index;
    return if not ref $self->files_ref()->[$index];
    return $self->files_ref()->[$index]->[0];
}

#######################################################################################
# Usage         : $filelist->position([$file])
# Purpose       : Find the position of $file (or current file) in the filelist
# Returns       : Position of the file in the filelist, -1 if the filename was not found
#                 in the filelist
# Parameters    : string/Treex::PML::Document $file -- file name as a string or file as a Treex::PML::Document object
# Throws        : no exceptions
# Comments      : If the argument is Treex::PML::Document object, return an index of the filename
#                 corresponding to the given Treex::PML::Document object. If the argument is string,
#                 return an index of the string in the file list. If no argument is given,
#                 return index of current file.
# See also      : file_at(), file_pattern_index(), loose_position_of_file()
sub position {
    my ( $self, $fsfile ) = @_;
    return if not ref $self;
    if ( not defined $fsfile ) {
        $fsfile = $self->current();
    }
    my @files = $self->files();

    # if argument is a Treex::PML::Document, find out its filename
    my $fname
        = ref $fsfile     ? $fsfile->filename()
        : defined $fsfile ? $fsfile
        :                   q{};

    my $basedir  = $self->dirname();
    my $relfname = $fname;

    # if basedir is at the beginning of the filename,
    # make the rest of the string relative filename
    if ( index( $fname, $basedir ) == 0 ) {
        $relfname = substr( $fname, length($basedir) );
    }

    # linear search through filenames in filelist
    for my $i ( 0 .. $self->file_count() - 1 ) {
        return $i if ( $fname eq $files[$i] or $relfname eq $files[$i] );
    }

    # no such file found
    return $NOT_FOUND;
}

#######################################################################################
# Usage         : $filelist->loose_position_of_file($fsfile)
# Purpose       : Find the position of file $fsfile in filelist even if the name
#                 of the file contains suffix or if relative portion of file name matches
# Returns       : Position of $fsfile in the filelist.
#                 -1 if file was not found
# Parameters    : string/Treex::PML::Document ref $fsfile -- name of fsfile or the object itself
# Throws        : no exception
# Comments      : The relative path is constructed from the position of current filelist.
#                 E.g. if the filename of the filelist is 'my_filelists/trees.fl',
#                 and $fsfile is 'my_filelists/analytical_trees.tgz#123', then it should be found
#                 if 'analytical_trees.tgz' is part of trees.fl filelist.
# See Also      : position()
sub loose_position_of_file {
    my ( $self, $fsfile ) = @_;

    # _dump_filelists("looseFilePositionInFilelist", \@filelists);
    return if ( !ref $self );

    my $pos = $self->position($fsfile);
    return $pos if $pos >= 0;

    my $fname = ref $fsfile ? $fsfile->filename() : $fsfile;
    ($fname) = TrEd::Utils::parse_file_suffix($fname);
    my $files    = $self->files_ref();
    my $basedir  = $self->dirname();
    my $relfname = $fname;
    if ( index( $fname, $basedir ) == 0 ) {
        $relfname = substr( $fname, length($basedir) );
    }
    for ( my $i = 0; $i < $self->file_count(); $i++ ) {
        my ($fn) = TrEd::Utils::parse_file_suffix( $files->[$i]->[0] );
        return $i if ( $fname eq $fn || $relfname eq $fn );
    }
    return -1;
}

#######################################################################################
# Usage         : $filelist->file_pattern_index($n)
# Purpose       : Return the index of the pattern which has generated the n'th file
# Returns       : Index of the filelist item which has generated the n'th file,
#                 -1 if the index of file does not exist or it is negative
# Parameters    : scalar $n -- index of the file whose pattern index function searches for
# Throws        : no exceptions
# Comments      : Does not support negative indices.
# See also      : position(), file_at()
# Previous implementation was kind of flawed, because it created empty element in files_ref
# data structure if asked for $n bigger than number of files
sub file_pattern_index {
    my ( $self, $index ) = @_;
    return if not ref $self;
    if ( $index < 0 ) {
        return $NOT_FOUND;
    }
    if ( exists $self->files_ref()->[$index] ) {
        return $self->files_ref()->[$index]->[1];
    }
    else {
        return $NOT_FOUND;
    }
}

#######################################################################################
# Usage         : $filelist->file_pattern($n)
# Purpose       : Return the pattern which has generated the n-th file
# Returns       : List item/pattern which has generated the n-th file, undef if $n is
#                 out of bounds
# Parameters    : scalar $n -- index of the file whose pattern function searches for
# Throws        : no exceptions
# Comments      : Does not support negative indices (since it uses file_pattern_index internally)
# See also      : file_pattern_index()
# Previous implementation was kind of flawed, because it returned the last pattern from filelist
# if the file with index $n did not exist
sub file_pattern {
    my ( $self, $index ) = @_;
    return if not ref $self;
    my $pattern_index = $self->file_pattern_index($index);
    if ( $pattern_index == $NOT_FOUND ) {
        return;
    }
    else {
        return $self->list_ref()->[$pattern_index];
    }
}

#######################################################################################
# Usage         : $fl->entry_path($index)
# Purpose       : Return pattern and file which are located at position n in the filelist
# Returns       : Undef/empty list if there is no file at index $index, string which contains
#                 pattern and file name delimited by tab is returned otherwise.
# Parameters    : scalar $index -- index of the filelist entry whose path is returned
# Throws        : no exception
# See Also      : file_at(), file_pattern()
# was filelistEntryPath
sub entry_path {
    my ( $self, $index ) = @_;
    return if ( !ref $self );

    my $file = $self->file_at($index);
    my $pattern = $self->file_pattern($index);

    # some mambo-jumbo to supress complaints about undef
    return if ( !defined $file );

    # $file is defined now
    # if $pattern is not defined, $file is not equal to $pattern, 
    # we should return "$pattern\t$file", so skip $pattern
    if ( !defined $pattern ) {
        return "\t$file";
    }
    return $file eq $pattern ? $file : "$pattern\t$file";
}

#######################################################################################
# Usage         : $filelist->add($position, @patterns)
# Purpose       : Insert patterns on the given position in the list and update file list
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : scalar $position  -- position at which the new patterns are inserted
#                 list @patterns    -- new patterns for file list
# Throws        : no exceptions
# Comments      : If position is past the end of the current list of patterns, new patterns
#                 are simply added at the end of the list.
# See also      : add_arrayref(), remove()
sub add {
    my ( $self, $position, @patterns ) = @_;
    return if not ref $self;

    # never add elements already present here or in files
    # and add each element once only

    my $list_ref = $self->list_ref();
    my %saw;
    foreach my $pattern ( @{$list_ref} ) {
        $saw{$pattern} = 1;
    }

    # non-empty non-duplicate patterns
    my @filtered_patterns = grep { !( $saw{$_}++ ) }
        grep { defined($_) && $_ ne q{} } @patterns;

    # insert into array @{$list_ref} at position $position 
    # and don't remove anything
    splice @{$list_ref}, $position, 0, @filtered_patterns;

    $self->expand();
    return 1;
}

#######################################################################################
# Usage         : $filelist->add_arrayref($position, $arr_ref)
# Purpose       : Insert patterns from a given $list_ref on the given position in the list and update
#                 file-list
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : scalar $position   -- position on which new patterns will be inserted
#                 array_ref $arr_ref -- reference to array of patterns
# Throws        : no exceptions
# Comments      :
# See also      : add()
sub add_arrayref {
    my ( $self, $position, $patterns_ref ) = @_;
    return if not ref $self;
    return $self->add( $position, @{$patterns_ref} );
}

#######################################################################################
# Usage         : $filelist->remove(@patterns)
# Purpose       : Remove given patterns from the list and update file list
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : list @patterns -- patterns to be removed from file list
# Throws        : no exceptions
# Comments      : If filelist contains duplicit entries, they are filtered out.
# See also      : add()
sub remove {
    my ( $self, @patterns_to_remove ) = @_;

    # Don't do anything if there are no files to remove
    return if ( !ref $self );

    @patterns_to_remove = grep { defined $_ } @patterns_to_remove;
    return if ( !scalar @patterns_to_remove );

    my %remove = map { $_ => 1 } @patterns_to_remove;
    @{ $self->list_ref() }
        = grep { !$remove{$_}++ } @{ $self->list_ref() };    #remove and uniq

    $self->expand();
    return 1;
}

#######################################################################################
# Usage         : $filelist->clear()
# Purpose       : Remove all patterns from a filelist
# Returns       : 1 if successful, undef/empty list otherwise
# Parameters    : no
# Throws        : no exceptions
# Comments      : Empties internal structures for list of patterns and files
sub clear {
    my ($self) = shift;
    return if not ref $self;
    @{ $self->list_ref() } = ();
    $self->expand();
    return 1;
}

#######################################################################################
# Usage         : $filelist->find_pattern($pattern)
# Purpose       : Return index of a given pattern in the filelist or -1 if not found.
# Returns       : Index of the pattern or -1 if not found. Undef/empty list if not called
#                 on Filelist object.
# Parameters    : string $pattern -- pattern which is searched for in file list
# Throws        : no exceptions
# Comments      :
# See also      : file_at(), file_pattern(), file_pattern_index()
sub find_pattern {
    my ( $self, $pattern ) = @_;
    return if not ref $self;
    for my $i ( 0 .. $self->count() ) {
        return $i if $self->list_ref->[$i] eq $pattern;
    }
    return $NOT_FOUND;
}

#TODO: test, doc
# was: main: renameFileInFilelist
sub rename_file {
    my ( $self, $old_file, $filename, $position ) = @_;

    # TRY UPDATING THE CURRENT FILELIST:
    #  if position is undefined - update all
    #  if defined, update only given position
    return
        unless ref($self)
            and UNIVERSAL::can( $self, 'list_ref' )
            and UNIVERSAL::can( $self, 'files_ref' );
    my $pattern_list = $self->list_ref;
    my $rel_name = File::Spec->abs2rel( $filename, $self->filename );

    # my %fixed;
    for my $i (
        defined($position) ? $position : 0 .. ( $self->file_count() - 1 ) )
    {
        my $fn = $self->file_at($i);
        my ( $f, $suffix ) = TrEd::Utils::parse_file_suffix($fn);
        if (Treex::PML::IO::is_same_file(
                TrEd::Filelist::Navigation::_filelist_full_filename(
                    $self, $f
                ),
                $old_file
            )
            )
        {
            my $pattern_no = $self->file_pattern_index($i);
            my $pattern    = $pattern_list->[$pattern_no];
            my $new_filename
                = ( Treex::PML::_is_absolute($f)
                ? $filename . $suffix
                : $rel_name . $suffix );
            $self->files_ref->[$i][0] = $new_filename;
            if ( $pattern eq $fn ) {

                # direct filename - easy: change pattern
                $pattern_list->[$pattern_no] = $new_filename;
            }
        }
    }
}

1;

__END__

=head1 NAME


Filelist - Class handling file lists manipulations -- creating, loading from file, saving to file,
adding and removing patterns.


=head1 VERSION

This documentation refers to
Filelist version 0.2.


=head1 SYNOPSIS

  use Filelist;

  my $fl = Filelist->new('my filelist', '/home/john/filelist.fl');

  $fl->load();

  # find out what are the patterns and files in filelist
  my @patterns = $fl->list();
  my @files = $fl->files();

  # equivalents with references and more info
  my $patterns_ref = $fl->list_ref();
  my $files_ref = $fl->files_ref();

  # count of patterns and files in filelist
  my $pattern_count = $fl->count();
  my $files_count = $fl->file_count();

  # rename filelist and ask for the name
  $fl->rename('my filelist 2');
  my $new_name = $fl->name();

  # change the filelist's file name and ask for it
  $fl->filename('new_filename.fl');
  my $new_filename = $fl->filename();

  # save filelist under the new name
  $fl->save();

  # add more patterns at position 24 to filelist
  my @new_patterns = qw{ file1 file2 file_? };
  $fl->add(24, @new_patterns);
  $fl->add_arrayref(24, \@new_patterns);

  # search for pattern's index
  my $pos = $fl->find_pattern('file1');

  # search for pattern, which generated specified file
  my $pattern = $fl->file_pattern('file_9');

  # search for pattern, which generated file no 35
  my $pat_idx = $fl->file_pattern_index(35);

=head1 DESCRIPTION

Filelist class allows creating objects which represent TrEd's file lists.

Filelist consists of its name on the first line followed by any number of files, each file on one line.
Filelist can also contain patterns for the glob function, which are expanded when the file list is being
loaded.

If file list contains relative file names, files are searched relative to the path where the filelist is stored.

This class supports two concepts: list of patterns/filelist items and list of files. If a filelist contains
only one pattern that represents 10 files, then list() function returns just that one pattern, while files()
function returns a list of filenames which match beforementioned pattern.


Filelist class supports lazy loading of filelists. load() method marks file to be loaded when needed and exits.
Filelist is then loaded when it is needed, i.e. when any of the functions needs to work with the list.



=head1 SUBROUTINES/METHODS

=over 4



=item * C<Filelist->new($name, $filename)>

=over 6

=item Purpose

Create file list object

=item Parameters

  C<$name> -- string $name      -- name of the file list
  C<$filename> -- string $filename  -- file name of the playlist



=item Returns

Filelist object

=back


=item * C<$file_list->name()>

=over 6

=item Purpose

Return name of the file-list

=item Parameters




=item Returns

Filelist's name
Undef if not called on Filelist object.

=back


=item * C<$file_list->rename($new_name)>

=over 6

=item Purpose

Rename the filelist

=item Parameters

  C<$new_name> -- string $new_name -- new name for filelist



=item Returns

Filelist's new name
Undef if not called on Filelist object.

=back


=item * C<$file_list->filename([$new_filename])>

=over 6

=item Purpose

Return/change file name of the file-list (path to the file where the
filelist is (or is to be) saved.

=item Parameters

  C<$new_filename> -- string $new_filename -- new filename for filelist



=item Returns

Filename of the filelist (new one if it is a setter).
Undef if not called on Filelist object.

=back


=item * C<Filelist::_filelist_path_without_dir_sep($file_path, $dir_separator)>

=over 6

=item Purpose

Tell whether path contains directory separator or default dir separator

=item Parameters

  C<$file_path> -- string $file_path     -- string of path to tested file
  C<$dir_separator> -- string $dir_separator -- directory separator for current platform



=item Returns

True if path contains directory separator, false otherwise

=back


=item * C<$filelist->dirname()>

=over 6

=item Purpose

Return the dirname part of filelist's filename (including trailing directory separator)

=item Parameters


=item Comments

If the filelist's filename does not contain any file separator, it is considered
to be placed in the current directory and './' or '.\' is returned.

=item See Also

L<filename>,

=item Returns

Part of filename string from the beginning up to the last directory separator

=back


=item * C<$filelist->_filename_not_empty()>

=over 6

=item Purpose

Tell whether filename is defined and empty

=item Parameters




=item Returns

True if filelist's filename is defined and empty, false otherwise

=back


=item * C<$filelist->save()>

=over 6

=item Purpose

Write the list of patterns to a file whose filename is obtained via
the filename method

=item Parameters


=item Comments

If no filename is given, filelist is written to standard output.
Filelist's name goes on the first line of new file, list of
files/positions follows, every item on its own line

=item See Also

L<load>,

=item Returns

1 if successful, undef if not called on object or if there is no
need to save the filelist

=back


=item * C<$filelist->_lazy_load()>

=over 6

=item Purpose

Loads the file-list into class's internal data structures

=item Parameters


=item Comments

Removes empty lines, duplicate filenames, but does not remove duplicate patterns

=item See Also

L<load>,

=item Returns

1 if successful, undef otherwise

=back


=item * C<$filelist->_load_name()>

=over 6

=item Purpose

Load filelist's name from filelist file

=item Parameters


=item Comments

Function assumes that filelists's name is on the first line of the filelist

=item See Also

L<name>,
L<rename>,

=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->load()>

=over 6

=item Purpose

Read a file list form a file whose name is set/obtained via the
filename method

=item Parameters


=item Comments

Implementaion is actually lazy, so the filelist is loaded when it is
needed (when list(), files() or similar methods are invoked)


=item Returns

1 if load was successful, undef/empty list otherwise

=back


=item * C<$filelist->current()>

=over 6

=item Purpose

Return current file's name

=item Parameters


=item Comments

The feature of current file is completely user-driven

=item See Also

L<set_current>,

=item Returns

Current file's name or undef if no current file is defined.

=back


=item * C<$filelist->set_current($filename)>

=over 6

=item Purpose

Let given file be the current file in the file-list

=item Parameters

  C<$filename> -- string $filename  -- name of the file which is to become the current one

=item Comments

Not checked, if it exists or if it is part of the filelist.
The feature of current file is completely user-driven.

=item See Also

L<current>,

=item Returns

The new current filename

=back


=item * C<$filelist->files_ref()>

=over 6

=item Purpose

Return a reference to internal list of file names

=item Parameters


=item Comments

If the file list contains glob pattern, it is expanded and all the files
are returned. Invokes lazy loading if the list is not already loaded
(opening & reading from filelist)

=item See Also

L<files>,

=item Returns

Reference to list containing expanded file names
as pairs (filename, idx), where idx is the index of a pattern
in filelist, which had brought the file name to the list

=back


=item * C<$filelist->files()>

=over 6

=item Purpose

Return a list of all file names in the list

=item Parameters


=item Comments

If the file list contains glob pattern, it is expanded and all the files
are returned. Invokes lazy loading if the list is not already loaded
(opening & reading from filelist)

=item See Also

L<files_ref>,

=item Returns

List of all file names in the list

=back


=item * C<$filelist->list_ref()>

=over 6

=item Purpose

Return a reference to the filelist's item list

=item Parameters


=item Comments

If the file list contains glob pattern, it is NOT expanded and it is
considered one item/pattern.
Invokes lazy loading if the list is not already loaded
(opening & reading from filelist)

=item See Also

L<list>,

=item Returns

Reference to the internal pattern list

=back


=item * C<$filelist->list()>

=over 6

=item Purpose

Return a list of all patterns in the file list

=item Parameters


=item Comments

If the file list contains glob pattern, it is NOT expanded and it is
considered one item/pattern.
Invokes lazy loading if the list is not already loaded
(opening & reading from filelist)

=item See Also

L<list_ref>,

=item Returns

List of all items in the file list

=back


=item * C<$filelist->file_count()>

=over 6

=item Purpose

Return the total number of all files in the list

=item Parameters


=item Comments

If filelist contains regular file names, number of file names will be
returned. If it contains a glob pattern like 'sample_?.a.gz',
it is expanded and real number of files is returned

=item See Also

L<count>,

=item Returns

Number of files in filelist (including globbed ones)

=back


=item * C<$filelist->count()>

=over 6

=item Purpose

Return the number of all files/patterns in the list

=item Parameters


=item Comments

If filelist contains regular file names, number of file names will be
returned. If it contains a glob pattern like 'sample_?.a.gz', this pattern
is counted as +1, no matter how many files match this pattern.

=item See Also

L<file_count>,

=item Returns

Number of items in the filelist

=back


=item * C<$filelist->expand()>

=over 6

=item Purpose

Expand all patterns in the filelist and store them in the internal
list of filenames

=item Parameters


=item Comments

If the filelist's filename does not contain any file separator, it is considered
to be placed in the current directory and './' or '.\' is returned.

=item See Also

L<filename>,

=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->file_at($n)>

=over 6

=item Purpose

Return the n-th file name in the list

=item Parameters

  C<$n> -- scalar $n -- ordinal number of filename to return

=item Comments

Supports negative indices (in the same fashion as perl arrays)

=item See Also

L<files>,
L<files_ref>,

=item Returns

Name of the file on the n-th position in the filelist, undef if no such
file exists

=back


=item * C<$filelist->position([$file])>

=over 6

=item Purpose

Find the position of $file (or current file) in the filelist

=item Parameters

  C<$file> -- string/Treex::PML::Document $file -- file name as a string or file as a Treex::PML::Document object

=item Comments

If the argument is Treex::PML::Document object, return an index of the filename
corresponding to the given Treex::PML::Document object. If the argument is string,
return an index of the string in the file list. If no argument is given,
return index of current file.

=item See Also

L<file_at>,
L<file_pattern_index>,

=item Returns

Position of the file in the filelist, -1 if the filename was not found
in the filelist

=back


=item * C<$filelist->file_pattern_index($n)>

=over 6

=item Purpose

Return the index of the pattern which has generated the n'th file

=item Parameters

  C<$n> -- scalar $n -- index of the file whose pattern index function searches for

=item Comments

Does not support negative indices.

=item See Also

L<position>,
L<file_at>,

=item Returns

Index of the filelist item which has generated the n'th file,
-1 if the index of file does not exist or it is negative

=back


=item * C<$filelist->file_pattern($n)>

=over 6

=item Purpose

Return the pattern which has generated the n-th file

=item Parameters

  C<$n> -- scalar $n -- index of the file whose pattern function searches for

=item Comments

Does not support negative indices (since it uses file_pattern_index internally)

=item See Also

L<file_pattern_index>,

=item Returns

List item/pattern which has generated the n-th file, undef if $n is
out of bounds

=back


=item * C<$filelist->add($position, @patterns)>

=over 6

=item Purpose

Insert patterns on the given position in the list and update file list

=item Parameters

  C<$position> -- scalar $position  -- position at which the new patterns are inserted
  C<@patterns> -- list @patterns    -- new patterns for file list

=item Comments

If position is past the end of the current list of patterns, new patterns
are simply added at the end of the list.

=item See Also

L<add_arrayref>,
L<remove>,

=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->add_arrayref($position, $arr_ref)>

=over 6

=item Purpose

Insert patterns from a given $list_ref on the given position in the list and update
file-list

=item Parameters

  C<$position> -- scalar $position   -- position on which new patterns will be inserted
  C<$arr_ref> -- array_ref $arr_ref -- reference to array of patterns


=item See Also

L<add>,

=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->remove(@patterns)>

=over 6

=item Purpose

Remove given patterns from the list and update file list

=item Parameters

  C<@patterns> -- list @patterns -- patterns to be removed from file list

=item Comments

If filelist contains duplicit entries, they are filtered out.

=item See Also

L<add>,

=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->clear()>

=over 6

=item Purpose

Remove all patterns from a filelist

=item Parameters


=item Comments

Empties internal structures for list of patterns and files


=item Returns

1 if successful, undef/empty list otherwise

=back


=item * C<$filelist->find_pattern($pattern)>

=over 6

=item Purpose

Return index of a given pattern in the filelist or -1 if not found.

=item Parameters

  C<$pattern> -- string $pattern -- pattern which is searched for in file list


=item See Also

L<file_at>,
L<file_pattern>,
L<file_pattern_index>,

=item Returns

Index of the pattern or -1 if not found. Undef/empty list if not called
on Filelist object.

=back






=back


=head1 DIAGNOSTICS

Croaks "Cannot open filelist" or "Cannot close filelist" if these operations fail.

=head1 CONFIGURATION AND ENVIRONMENT

No configuration or environment settings needed.

=head1 DEPENDENCIES

TrEd modules:
TrEd::Utils, TrEd::MinMax

Standard Perl modules:
Carp, File::Glob, Cwd, Encode,

CPAN modules:
Readonly


=head1 INCOMPATIBILITIES

Name of rename function collides with built-in.
The name of function dirname can also collide, TrEd::File contains subroutine with the same name.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c)
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests).
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
