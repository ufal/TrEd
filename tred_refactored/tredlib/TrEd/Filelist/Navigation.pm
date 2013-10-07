package TrEd::Filelist::Navigation;

use strict;
use warnings;

use Carp;

use TrEd::Utils;
use Treex::PML;

use TrEd::Basics;
use TrEd::File;
use TrEd::ManageFilelists;

#######################################################################################
# Usage         : filelist_full_filename($win, $file_number)
# Purpose       : Resolve path to file number $file_number in current filelist
# Returns       : Scalar -- resolved path of file, undef if there is no current filelist
# Parameters    : TrEd::Window ref $win -- reference to focused window
#                 scalar $file_number   -- the ordinal number of file
# Throws        : no exceptions
# was main::filelistFullFileName
sub filelist_full_filename {
    my ( $win, $fn ) = @_;
    my $filelist = $win->{currentFilelist};
    return if ( !ref $filelist );
    return _filelist_full_filename( $filelist, $filelist->file_at($fn) );
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list
# Throws        : carps if file_list is not a Filelist object
# See Also      : filelist_full_filename()
# was main::_filelistFullFileName
sub _filelist_full_filename {
    my ( $file_list, $file_name ) = @_;
    if ( !eval { $file_list->isa('Filelist') } ) {
        carp 'argument file_list should be a Filelist object';
        return;
    }
    my $suffix;
    ( $file_name, $suffix ) = TrEd::Utils::parse_file_suffix($file_name);
    my $full_filename
        = Treex::PML::ResolvePath( $file_list->filename(), $file_name );

    if ( defined $suffix ) {
        $full_filename .= $suffix;
    }
    else {

      # ResolvePath returns URI::File object, we just want to return a string,
      # so we use this
        $full_filename .= q{};
    }
    return $full_filename;
}

#######################################################################################
# Usage         : go_to_file($grp_or_win, $file_no, $no_recent, $no_redraw)
# Purpose       : Open file with number $file_no from current filelist and set this 
#                 file as current file
# Returns       : Status hash of opening operation, for details, see TrEd::File documentation
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 scalar $file_no -- number of file that is going to be opened & activated
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
#                 bool $no_redraw -- switch telling whether to redraw windows after opening the file
# Throws        : no exceptions
# Comments      : Updates filelist views, too.
#                 Calls 'goto_file_hook', which may interrupt the operation,
#                 if it returns 'stop'
# See Also      : TrEd::File::open_file, update_filelist_views()
# was main::gotoFile
sub go_to_file {
    my ( $grp_or_win, $file_no, $no_recent, $no_redraw ) = @_;
    my ( $grp, $win ) = TrEd::Basics::grp_win($grp_or_win);
    return if not $win->{currentFilelist};
    my $goto_file_hook_res = main::doEvalHook( $win, 'goto_file_hook', $file_no );
    return 0 if defined $goto_file_hook_res && $goto_file_hook_res eq 'stop';
    return 0 if ( $file_no >= $win->{currentFilelist}->file_count() || $file_no < 0 );
    my $last_no = $win->{currentFileNo};
    $win->{currentFileNo} = $file_no;
    my ( $fs, $status ) = TrEd::File::open_file(
        $win, filelist_full_filename( $win, $file_no ),
        -norecent     => $no_recent,
        -noredraw     => $no_redraw,
        -keep_related => 1
    );
    if (not $status) {
        $win->{currentFileNo} = $last_no;
    }
    main::update_filelist_views( $grp, $win->{currentFilelist}, 0 );
    return $status;
}

#######################################################################################
# Usage         : prev__real_file($grp_or_win, $delta, $no_recent, $real)
# Purpose       : Opens & activates the previous file in current filelist in focused window,
#                 goes to previous file until the file name changes
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 scalar $delta -- the change in position in the current filelist
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
#                 bool $real -- switch telling the function whether to search for next file or just to go to next filelist item
# Throws        : no exceptions
# Comments      : Uses Tk error report dialog if the desired file could not be opened
# See Also      : prev_file(), next_file(), go_to_file()
# was main::nextOrPrevFile
sub next_or_prev_file {
    my ( $grp_or_win, $delta, $no_recent, $real ) = @_;
    my ( $grp, $win ) = TrEd::Basics::grp_win($grp_or_win);
    return 0 if ( $delta == 0 );
    my $op = $grp->{noOpenFileError};
    $grp->{noOpenFileError} = 1;
    my $filename;

    # desired position
    my $pos = $win->{currentFileNo} + $delta;
    if ( $real && $win->{FSFile} ) {
        my $prev_filename = $win->{FSFile}->filename();
        my $f = $filename = filelist_full_filename( $win, $pos );
        ($prev_filename) = TrEd::Utils::parse_file_suffix($prev_filename);
        ($f)             = TrEd::Utils::parse_file_suffix($f);
        while ( Treex::PML::IO::is_same_filename( $f, $prev_filename ) ) {
            $pos += $delta;
            $f = $filename = filelist_full_filename( $win, $pos );
            ($f) = TrEd::Utils::parse_file_suffix($f);
        }
    }
    else {
        $filename = filelist_full_filename( $win, $pos );
    }
    my $result = go_to_file( $win, $pos, $no_recent );
    my $quiet = 0;
    my $response;
    while ( ref $result and $result->{ok} == 0 ) {
        my $trees = $win->{FSFile} ? $win->{FSFile}->lastTreeNo + 1 : 0;
        if (!$quiet) {
            $response = $win->toplevel->ErrorReport(
                -title => 'Error: open failed',
                -message =>
                    "File is unreadable, empty, corrupted, or does not exist ($trees trees read)!"
                    . "\nPossible problem was:",
                -body    => $grp->{lastOpenError},
                -buttons => [
                    'Try next',
                    'Skip broken files',
                    'Remove from filelist',
                    'Cancel'
                ]
            );
            last if ( $response eq 'Cancel' );
            if ( $response eq 'Skip broken files' ) {
                $quiet = 1;
            }
        }
        if ( $response eq 'Remove from filelist' ) {
            my $f = filelist_full_filename( $win, $pos );
            TrEd::ManageFilelists::removeFromFilelist( $win, undef, undef,
                $f );
            if ( $delta > 0 ) {
                if ( $pos >= $win->{currentFilelist}->file_count() ) {
                    $pos = $win->{currentFilelist}->file_count() - 1;
                }
                else {
                    $pos += $delta - 1;
                }
            }
            else {
                $pos += $delta;
            }
        }
        else {
            $pos += $delta;
        }
        $result = go_to_file( $win, $pos, $no_recent );
    }
    $grp->{noOpenFileError} = $op;
    return ref $result and $result->{ok};
}

#######################################################################################
# Usage         : next_real_file($grp_or_win, $no_recent)
# Purpose       : Opens & activates the next file in current filelist in focused window,
#                 goes to next file until the file name changes
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
# Throws        : no exceptions
# See Also      : prev_real_file(), next_file(), tie_next_file(), next_or_prev_file()
# was main::nextRealFile
sub next_real_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, 1, $no_recent, 1 );
}

#######################################################################################
# Usage         : prev__real_file($grp_or_win, $no_recent)
# Purpose       : Opens & activates the previous file in current filelist in focused window,
#                 goes to previous file until the file name changes
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
# Throws        : no exceptions
# See Also      : next_real_file(), tie_prev_file(), prev_file(), next_or_prev_file()
# was main::prevRealFile
sub prev_real_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, -1, $no_recent, 1 );
}

#######################################################################################
# Usage         : next_file($grp_or_win, $no_recent)
# Purpose       : Opens & activates the next file in current filelist in focused window
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
# Throws        : no exceptions
# See Also      : prev_file(), tie_next_file(), next_real_file(), next_or_prev_file()
# was main::nextFile
sub next_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, 1, $no_recent );
}

#######################################################################################
# Usage         : prev_file($grp_or_win, $no_recent)
# Purpose       : Opens & activates the previous file in current filelist in focused window
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
# Throws        : no exceptions
# See Also      : next_file(), tie_prev_file(), prev_real_file(), next_or_prev_file()
# was main::prevFile
sub prev_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, -1, $no_recent );
}

#######################################################################################
# Usage         : tie_next_file($grp_or_win)
# Purpose       : Opens & activates the next file in current filelist in all tie windows
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
# Throws        : no exceptions
# See Also      : tie_prev_file(), next_file(), next_real_file(), next_or_prev_file()
# was main::tieNextFile
sub tie_next_file {
    my ( $grp, $win ) = TrEd::Basics::grp_win(shift);
    if ( $grp->{tieWindows} ) {
        foreach my $w ( @{ $grp->{treeWindows} } ) {
            if ( $w->{FSFile} ) {
                next_file($w);
            }
        }
    }
    else {
        if ( $win->{FSFile} ) {
            next_file($win);
        }
    }
    return;
}

#######################################################################################
# Usage         : tie_prev_file($grp_or_win)
# Purpose       : Opens & activates the previous file in current filelist in all tie windows
# Returns       : True if the operation succeeded, false otherwise
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
# Throws        : no exceptions
# See Also      : tie_next_file(), prev_file(), prev_real_file(), next_or_prev_file()
# was main::tiePrevFile
sub tie_prev_file {
    my ( $grp, $win ) = TrEd::Basics::grp_win(shift);
    if ( $grp->{tieWindows} ) {
        foreach my $w ( @{ $grp->{treeWindows} } ) {
            if ( $w->{FSFile} ) {
                prev_file($w);
            }
        }
    }
    else {
        if ( $win->{FSFile} ) {
            prev_file($win);
        }
    }
    return;
}

#######################################################################################
# Usage         : tie_go_to_file($grp_or_win, $file_no, $no_recent, $no_redraw)
# Purpose       : Changes the current file for all tie windows from $grp hash
# Returns       : Undef/empty list
# Parameters    : ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
#                 scalar $file_no -- number of file that is going to be opened & activated
#                 bool $no_recent -- switch telling whether to add this file to the list of recent files
#                 bool $no_redraw -- switch telling whether to redraw windows after opening the file
# Throws        : no exceptions
# Comments      : Wrapper around go_to_file sub
# See Also      : go_to_file()
# was main::tieGotoFile
sub tie_go_to_file {
    my ( $grp, $win ) = TrEd::Basics::grp_win(shift);
    if ( $grp->{tieWindows} ) {
        foreach my $w ( @{ $grp->{treeWindows} } ) {
            if ( $w->{FSFile} ) {
                go_to_file( $w, @_ );
            }
        }
    }
    else {
        if ( $win->{FSFile} ) {
            go_to_file( $win, @_ );
        }
    }
    return;
}

1;

__END__

=head1 NAME


TrEd::Filelist::Navigation - functions which provide navigation in filelists


=head1 VERSION

This documentation refers to
TrEd::Filelist::Navigation version 0.2.


=head1 SYNOPSIS

  use TrEd::Filelist::Navigation;

  # objects from TrEd main file
  my $grp = \%tred;
  my $win = $grp->{focusedWindow};
  # open a filelist...
  
  # affects all windows in $grp->{tieWindows}
  tie_next_file($grp);
  tie_prev_file($grp);
  
  my $file_no = 5;
  tie_go_to_file($grp, $file_no);
  
  # affects only focused window
  next_file($grp);
  prev_file($grp);
  
  my $file_no = 5;
  go_to_file($grp, $file_no);
  
  # affects only focused window, goes to next file, not next filelist item
  next_real_file($grp);
  prev_real_file($grp);
  

=head1 DESCRIPTION

Supports moving to next, previous files in the filelist or going to specified file number.


=head1 SUBROUTINES/METHODS

=over 4



=item * C<TrEd::Filelist::Navigation::filelist_full_filename($win, $file_number)>

=over 6

=item Purpose

Resolve path to file number $file_number in current filelist

=item Parameters

  C<$win> -- TrEd::Window ref $win -- reference to focused window
  C<$file_number> -- scalar $file_number   -- the ordinal number of file



=item Returns

Scalar -- resolved path of file, undef if there is no current filelist

=back


=item * C<TrEd::Filelist::Navigation::_filelist_full_filename($file_list_ref, $file_name)>

=over 6

=item Purpose

Resolve path to file $file_name relatively to location of $file_list

=item Parameters

  C<$file_list_ref> -- Filelist $file_list -- Filelist object
  C<$file_name> -- string $file_name   -- name of the file list


=item See Also

L<filelist_full_filename>,

=item Returns

Scalar -- resolved path of file

=back


=item * C<TrEd::Filelist::Navigation::go_to_file($grp_or_win, $file_no, $no_recent, $no_redraw)>

=over 6

=item Purpose

Open file with number $file_no from current filelist and set this 
file as current file

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$file_no> -- scalar $file_no -- number of file that is going to be opened & activated
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files
  C<$no_redraw> -- bool $no_redraw -- switch telling whether to redraw windows after opening the file

=item Comments

Updates filelist views, too.
Calls 'goto_file_hook', which may interrupt the operation,
if it returns 'stop'

=item See Also

L<update_filelist_views>,

=item Returns

Status hash of opening operation, for details, see TrEd::File documentation

=back


=item * C<TrEd::Filelist::Navigation::prev__real_file($grp_or_win, $delta, $no_recent, $real)>

=over 6

=item Purpose

Opens & activates the previous file in current filelist in focused window,
goes to previous file until the file name changes

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$delta> -- scalar $delta -- the change in position in the current filelist
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files
  C<$real> -- bool $real -- switch telling the function whether to search for next file or just to go to next filelist item

=item Comments

Uses Tk error report dialog if the desired file could not be opened

=item See Also

L<prev_file>,
L<next_file>,
L<go_to_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::next_real_file($grp_or_win, $no_recent)>

=over 6

=item Purpose

Opens & activates the next file in current filelist in focused window,
goes to next file until the file name changes

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files


=item See Also

L<prev_real_file>,
L<next_file>,
L<tie_next_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::prev__real_file($grp_or_win, $no_recent)>

=over 6

=item Purpose

Opens & activates the previous file in current filelist in focused window,
goes to previous file until the file name changes

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files


=item See Also

L<next_real_file>,
L<tie_prev_file>,
L<prev_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::next_file($grp_or_win, $no_recent)>

=over 6

=item Purpose

Opens & activates the next file in current filelist in focused window

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files


=item See Also

L<prev_file>,
L<tie_next_file>,
L<next_real_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::prev_file($grp_or_win, $no_recent)>

=over 6

=item Purpose

Opens & activates the previous file in current filelist in focused window

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files


=item See Also

L<next_file>,
L<tie_prev_file>,
L<prev_real_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::tie_next_file($grp_or_win)>

=over 6

=item Purpose

Opens & activates the next file in current filelist in all tie windows

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object


=item See Also

L<tie_prev_file>,
L<next_file>,
L<next_real_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::tie_prev_file($grp_or_win)>

=over 6

=item Purpose

Opens & activates the previous file in current filelist in all tie windows

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object


=item See Also

L<tie_next_file>,
L<prev_file>,
L<prev_real_file>,
L<next_or_prev_file>,

=item Returns

True if the operation succeeded, false otherwise

=back


=item * C<TrEd::Filelist::Navigation::tie_go_to_file($grp_or_win, $file_no, $no_recent, $no_redraw)>

=over 6

=item Purpose

Changes the current file for all tie windows from $grp hash

=item Parameters

  C<$grp_or_win> -- ref $grp_or_win -- reference to hash of TrEd options or to TrEd::Window object
  C<$file_no> -- scalar $file_no -- number of file that is going to be opened & activated
  C<$no_recent> -- bool $no_recent -- switch telling whether to add this file to the list of recent files
  C<$no_redraw> -- bool $no_redraw -- switch telling whether to redraw windows after opening the file

=item Comments

Wrapper around go_to_file sub

=item See Also

L<go_to_file>,

=item Returns

Undef/empty list

=back






=back


=head1 DIAGNOSTICS

Carps 'argument file_list should be a Filelist object' if file_list is not a Filelist object
in _filelist_full_filename subroutine.

=head1 CONFIGURATION AND ENVIRONMENT

No special configuration or enviromnent settings needed.

=head1 DEPENDENCIES

Standard Perl modules:
Carp,

TrEd modules:
TrEd::Utils, TrEd::File, TrEd::ManageFilelists

CPAN modules:
Treex::PML


=head1 INCOMPATIBILITIES


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
