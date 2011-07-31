package TrEd::Filelist::Navigation;

use strict;
use warnings;

use Carp;

use TrEd::Utils;
use Treex::PML;

use TrEd::File;
use TrEd::ManageFilelists;

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
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
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
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      : Updates filelist views, too.
#                 Calls 'goto_file_hook', which may interrupt the operation,
#                 if it returns 'stop'
# See Also      : TrEd::File::open_file, update_filelist_views()
# was main::gotoFile
sub go_to_file {
    my ( $grp_or_win, $file_no, $no_recent, $no_redraw ) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    return unless $win->{currentFilelist};
    my $goto_file_hook_res = main::doEvalHook( $win, "goto_file_hook", $file_no );
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
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::nextOrPrevFile
sub next_or_prev_file {
    my ( $grp_or_win, $delta, $no_recent, $real ) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
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
        unless ($quiet) {
            $response = $win->toplevel->ErrorReport(
                -title => "Error: open failed",
                -message =>
                    "File is unreadable, empty, corrupted, or does not exist ($trees trees read)!"
                    . "\nPossible problem was:",
                -body    => $grp->{lastOpenError},
                -buttons => [
                    "Try next",
                    "Skip broken files",
                    "Remove from filelist",
                    "Cancel"
                ]
            );
            last if ( $response eq "Cancel" );
            if ( $response eq "Skip broken files" ) {
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
    return ref($result) and $result->{ok};
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::nextRealFile
sub next_real_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, 1, $no_recent, 1 );
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::prevRealFile
sub prev_real_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, -1, $no_recent, 1 );
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::nextFile
sub next_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, 1, $no_recent );
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::prevFile
sub prev_file {
    my ( $grp_or_win, $no_recent ) = @_;
    return next_or_prev_file( $grp_or_win, -1, $no_recent );
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::tieNextFile
sub tie_next_file {
    my ( $grp, $win ) = main::grp_win(shift);
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
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::tiePrevFile
sub tie_prev_file {
    my ( $grp, $win ) = main::grp_win(shift);
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
}

#######################################################################################
# Usage         : _filelist_full_filename($file_list_ref, $file_name)
# Purpose       : Resolve path to file $file_name relatively to location of $file_list
# Returns       : Scalar -- resolved path of file
# Parameters    : Filelist $file_list -- Filelist object
#                 string $file_name   -- name of the file list?? really?
# Throws        : no exceptions
# Comments      :
# See Also      :
# was main::tieGotoFile
sub tie_go_to_file {
    my ( $grp, $win ) = main::grp_win(shift);
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
}

1;
