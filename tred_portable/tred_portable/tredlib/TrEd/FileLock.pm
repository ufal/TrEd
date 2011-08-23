package TrEd::FileLock;

use strict;
use warnings;

use base qw(Exporter);
use vars qw(@EXPORT_OK $VERSION);
$VERSION = "0.1";

BEGIN {
    @EXPORT_OK = qw(
        check_lock
        lock_file
        lock_open_file
        read_lock
        remove_lock
        set_fs_lock_info
        set_lock
    );

    if ( exists &Tk::MainLoop ) {

      # it is not very good that TrEd::FileLock loads this Tk and GUI stuff,
      # dialogs for asking for user choices,
      # at least do not load it if no GUI exists
        require TrEd::Query::User;
    }
}

use TrEd::Config qw{$noLockProto $userlogin $tredDebug $lockFiles};
use TrEd::Utils qw{$EMPTY_STR};
use Treex::PML;
use Carp;

######################################################################################
# Usage         : set_lock($filename)
# Purpose       : Locks file $filename by creating a lockfile
# Returns       : If the lock is successful, returns string information about the lock
#                 in the following form: 'by user $userlogin@$hostname pid $process_id
#                 at $time_of_lock mtime: $modif_time_of_file.
#                 If not successful, undef/empty list is returned.
# Parameters    : string $filename -- name of file to lock
# Throws        : Carp if lock could not be created.
# Comments      : Does not lock for these protocols: ntred, protocols matching
#                 TrEd::Config::noLockProto regular expression. Lock file is a file
#                 with the same name as original file, only suffix .lock is appended
#                 to its name.
#                 Basic information about the lock are written into the lock file:
#                 the owner of the lock, the time when the file has been locked,
#                 hostname of the computer, process id and the time of the last modifiaction
#                 of the locked file.
# See Also      : check_lock(), remove_lock()
# was main::setLock
sub set_lock {
    my ($filename) = @_;                                      # filename
    my $protocol = Treex::PML::IO::get_protocol($filename);
    if ( $protocol eq 'file' ) {
        $filename = Treex::PML::IO::strip_protocol($filename);
    }
    return
        if ( $protocol eq 'ntred'
        or $protocol =~ /$TrEd::Config::noLockProto/ );

    my $lock_file
        = eval { Treex::PML::IO::open_backend( $filename . '.lock', 'w' ) };
    if ( $@ || !ref $lock_file ) {
        carp( 'Error creating lock-file: ' . main::_last_err() . "\n" );
        return;
    }

    if ( $^O ne "MSWin32" and $protocol eq 'file' ) {
        chmod 0644, $lock_file;
    }
    my $mtime = [ stat($filename) ]->[9];
    my $hostname = defined $ENV{HOSTNAME} ? $ENV{HOSTNAME} : $EMPTY_STR;
    my $lockinfo
        = 'by user '
        . $TrEd::Config::userlogin . '@'
        . $hostname . ' pid '
        . $$ . ' at '
        . localtime()
        . " mtime: $mtime";

    $lock_file->print( $lockinfo . "\n" );
    Treex::PML::IO::close_backend($lock_file);
    return $lockinfo;
}

######################################################################################
# Usage         : read_lock($filename)
# Purpose       : Read lock information about file $filename from lock file
# Returns       : Lockinfo about locked file as a string containing the owner of the lock,
#                 hostname, pid of the process that locked the file, time when the file has
#                 was locked and time of last modification of the locked file.
#                 Undef/empty list if not successful.
# Parameters    : string $filename -- name of the file whose lockinfo will be read
# Throws        : nothing
# Comments      :
# See Also      : check_lock()
# was main::readLock
sub read_lock {
    my ($filename) = @_;
    my $protocol = Treex::PML::IO::get_protocol($filename);
    if ( $protocol eq 'file' ) {
        $filename = Treex::PML::IO::strip_protocol($filename);
    }
    return if not -f "$filename.lock";
    return
        if ( $protocol eq 'ntred'
        or $protocol =~ /$TrEd::Config::noLockProto/ );
    my $lockinfo;
    eval {
        print STDERR "reading lock $filename.lock\n" if $tredDebug;
        my ( $file, $remove_file )
            = Treex::PML::IO::fetch_file( $filename . '.lock' );
        open my $lock, '<', $file;
        $lockinfo = $lock->getline();
        $lock->close();
        if ($remove_file) {
            unlink $file;
        }
        $lockinfo =~ s/[\n\r]+$//;
    };
    if ($@) {
        print $@;
    }
    if ( $lockinfo and $tredDebug ) {
        print STDERR "Fetched lock $lockinfo\n";
    }
    return $lockinfo;
}

######################################################################################
# Usage         : remove_lock($fsfile, $filename, $force)
# Purpose       : Remove the lock if we locked the file (or if we use force to do so)
# Returns       : Undef/empty list
# Parameters    : Treex::PML::Document $fsfile -- file whose lock should be removed
#                 string $filename             -- name of the file whose lock will be removed
#                 scalar $force                -- indicator whether to force the removing of the lock
# Throws        : nothing
# Comments      : Lock is removed if $force evaluates to true, $fsfile is not defined
#                 or if check_lock returns lock status that starts with 'my' or 'changed'
# See Also      : set_lock(), check_lock()
# was main::removeLock
# TODO: test
sub remove_lock {
    my ( $fsfile, $filename, $force ) = @_;    # filename
    my $protocol;
    if ( defined $filename ) {
        $protocol = Treex::PML::IO::get_protocol($filename);
        if ( $protocol eq 'file' ) {
            $filename = Treex::PML::IO::strip_protocol($filename);
        }
    }
    else {
        $filename = $fsfile->filename();
        $protocol = ref($filename) ? $filename->scheme() : 'file';
    }
    return
        if ( $protocol eq 'ntred'
        or $protocol =~ /$TrEd::Config::noLockProto/ );

    local $TrEd::Config::noCheckLocks = 0;
    if (   $force
        or not defined $fsfile
        or check_lock( $fsfile, $filename ) =~ /^my|^changed/ )
    {
        if ($tredDebug) {
            print STDERR "removing lock $filename.lock\n";
        }
        Treex::PML::IO::unlink_uri( $filename . '.lock' );
    }
    return;
}

######################################################################################
# Usage         : _check_lock_with_lockfile_info($fsfile, $file_name, $lockinfo)
# Purpose       : Check whether file is locked if there exist any lock information in
#                 '.lock' file
# Returns       : 9 possible string outcomes
# Parameters    : Treex::PML::Document $fsfile  -- file object (not obligatory)
#                 string $file_name             -- name of the file whose lock to check
#                 string $lockinfo              -- information read from '.lock' file
# Throws        : nothing
# Comments      : Complex and difficult to understand, diagram should be drawn here,
#                 but it's quite difficult to draw it here..
# See Also      : _check_lock_only_mem_lock(), check_lock()
sub _check_lock_with_lockfile_info {
    my ( $fsfile, $filename, $lockinfo ) = @_;

    my $current_mtime = [ stat($filename) ]->[9];

    my ( $user, $host, $pid )
        = $lockinfo =~ m/^by user (.*?)@(.*?) pid (\d+)/;
    if ( $fsfile and $fsfile->appData('lockinfo') ) {
        my $ourlockinfo = $fsfile->appData('lockinfo');
        my ($mtime) = $ourlockinfo =~ / mtime: (\d+)$/;
        if ( $ourlockinfo =~ /^locked (.*)/ ) {
            if ( $1 ne $lockinfo ) {
                return
                    "opened by us ignoring the lock $1, but later locked again $lockinfo";
            }
            elsif ( $mtime != $current_mtime ) {
                return
                    "opened by us ignoring the lock $1 and later changed by the lock owner";
            }
            else {
                return
                    "opened by us ignoring the lock $1, who still owns the lock, but has not saved the file since";
            }
        }
        elsif ( $ourlockinfo ne $lockinfo ) {
            if ( $current_mtime != $mtime ) {
                return
                    "stolen and changed $lockinfo (previously locked $ourlockinfo)";
            }
            else {
                return
                    "stolen (but not yet changed) $lockinfo (previously locked $ourlockinfo)";
            }
        }
        elsif ( $mtime != $current_mtime ) {
            return 'changed by another program';
        }
        else {
            return 'my';
        }
    }
    elsif ( $pid == $$
        and $user eq $TrEd::Config::userlogin
        and $host eq ( defined $ENV{HOSTNAME} ? $ENV{HOSTNAME} : q{} ) )
    {
        return 'my';
    }
    else {
        return 'locked ' . $lockinfo;
    }
}

######################################################################################
# Usage         : _check_lock_only_mem_lock($fsfile, $file_name)
# Purpose       : Check whether file is locked if only memory lock information exists
# Returns       : 4 possible string outcomes
# Parameters    : Treex::PML::Document $fsfile  -- file object (not obligatory)
#                 string $file_name             -- name of the file whose lock to check
# Throws        : nothing
# Comments      : Complex and difficult to understand, diagram should be drawn here,
#                 but it's quite difficult to draw it here..
# See Also      : _check_lock_with_lockfile_info(), check_lock()
sub _check_lock_only_mem_lock {
    my ( $fsfile, $filename ) = @_;

    my $current_mtime = [ stat($filename) ]->[9];

    my $ourlockinfo = $fsfile->appData('lockinfo');
    my ($mtime) = $ourlockinfo =~ / mtime: (\d+)$/;
    if ( $ourlockinfo =~ /^locked (.*)/ ) {
        my $lock_part = $1;
        if ( $current_mtime != $mtime ) {
            return
                "opened by us ignoring a lock $lock_part who released the lock, but the file has changed since";
        }
        else {
            return
                "opened by us ignoring a lock $lock_part, who released the lock without making any changes";
        }
    }
    else {
        if ( $current_mtime != $mtime ) {
            return "changed by another program and our lock was removed";
        }
        else {
            return
                "originally locked by us but the lock was stolen from us by an unknown thief. The file seems unchanged";
        }
    }
}

######################################################################################
# Usage         : check_lock($fsfile, $file_name)
# Purpose       : Check whether file is locked and if it was locked by us
#                 or the file was modified since we created the lock
# Returns       : 15 possible string outcomes
# Parameters    : Treex::PML::Document $fsfile  -- file object (not obligatory)
#                 string $file_name             -- name of the file whose lock to check
# Throws        : nothing
# Comments      : Complex and difficult to understand, diagram should be drawn here,
#                 but it's quite difficult to draw it here in ASCII
# See Also      : set_lock(), read_lock()
# was main::checkLock
sub check_lock {
    my ( $fsfile, $filename ) = @_;    # filename
    return 'Ignore' if $TrEd::Config::noCheckLocks;

    if ( $fsfile && !defined $filename ) {
        $filename = $fsfile->filename();
    }

    my $lockinfo = read_lock($filename);

    if ( defined $lockinfo && $lockinfo ne $EMPTY_STR ) {

        # we have some information from '.lock' file
        return _check_lock_with_lockfile_info( $fsfile, $filename,
            $lockinfo );
    }
    else {

        # we do not have information from '.lock' file
        if ( $fsfile and $fsfile->appData('lockinfo') ) {

            # but we do have info from our lock
            return _check_lock_only_mem_lock( $fsfile, $filename );
        }
        else {

            # there is no '.lock' file, neither exist our memory lock info
            return 'none';
        }
    }

}

######################################################################################
# Usage         : lock_file($win, $filename, $opts_ref, $auto_answer)
# Purpose       : Lock file $filename
# Returns       : Lock info string from '.lock' file or 'Cancel' if locking was cancelled
# Parameters    : TrEd::Window $win   -- TrEd's window object
#                 string $filename    -- name of the file that should be locked
#                 hash_ref $opts_ref  -- options for redrawing window
#                 string $auto_answer -- use auto answer instead of asking the user
# Throws        : nothing
# Comments      : $auto_answer, if defined should have one of the following values:
#                 'Cancel', 'Steal lock' or 'Open anyway'
# See Also      : set_lock(), remove_lock()
#TODO: test
sub lock_file {
    my ( $win, $filename, $opts_ref, $auto_answer ) = @_;
    my $lock = check_lock( undef, $filename );
    if ($tredDebug) {
        print STDERR "LOCK: $lock\n";
    }
    my $lockinfo;
    if ( $lock =~ /^locked/ ) {
        my $answer;
        if ( defined $auto_answer && $auto_answer ne $EMPTY_STR ) {
            $answer = $auto_answer;
        }
        else {
            $answer = TrEd::Query::User::new_query(
                $win,
                "File $filename is $lock.",
                -bitmap  => 'question',
                -title   => "Accessing locked file?",
                -buttons => [ 'Open anyway', 'Steal lock', 'Cancel' ]
            );
        }
        if ( $answer eq 'Cancel' ) {
            if (not( $opts_ref
                    and ( $opts_ref->{-preload} or $opts_ref->{-noredraw} ) )
                )
            {
                $win->redraw();
            }
            if ( not $main::insideEval ) {
                $win->toplevel->Unbusy();
            }
            return 'Cancel';
        }
        elsif ( $answer eq 'Steal lock' ) {
            $lockinfo = set_lock($filename);
        }
        else {
            $lockinfo = $lock;
            print STDERR "LOCKINFO: $lockinfo\n";
        }
    }
    elsif ($lockFiles) {
        $lockinfo = set_lock($filename);
    }
    return $lockinfo;
}

######################################################################################
# Usage         : lock_open_file($win, $fsfile)
# Purpose       : Create lock file and set memory lock info (if it is not already set)
# Returns       : Undef/empty list
# Parameters    : TrEd::Window $win             -- TrEd window
#                 Treex::PML::Document $fsfile  -- file to lock
# Throws        : nothing
# Comments      : $TrEd::Config::lockFiles has to be set to true to create locks.
#                 If lock for the actual file already exists, it is not recreated or
#                 modified.
# See Also      : lock_file(), set_fs_lock_info()
#TODO: test
sub lock_open_file {
    my ( $win, $fsfile ) = @_;
    $fsfile ||= $win->{FSFile};
    if ( $TrEd::Config::lockFiles
        and !defined( $fsfile->appData('lockinfo') ) )
    {
        my $lockinfo
            = lock_file( $win, $fsfile->filename(), { -noredraw => 1 } );
        if ( $lockinfo ne 'Cancel' ) {
            set_fs_lock_info( $fsfile, $lockinfo );
        }
    }
    return;
}

######################################################################################
# Usage         : set_fs_lock_info($fsfile, $lockinfo)
# Purpose       : Set fsfile's lockinfo to $lockinfo
# Returns       : Undef/empty list.
# Parameters    : Treex::PML::Document $fsfile  -- file whose lock info is set
#                 string $lockinfo              -- lock information written to fsfile's non-persistent memory
# Throws        : nothing
# Comments      :
# See Also      : lock_open_file(), lock_file()
#TODO: test
# was main::setFSLockInfo
sub set_fs_lock_info {
    my ( $fsfile, $lockinfo ) = @_;
    if ( defined $fsfile ) {
        $fsfile->changeAppData( 'lockinfo', $lockinfo );
    }
    return;
}

1;

#TODO: edit pod

__END__


=head1 NAME


TrEd::ArabicRemix


=head1 VERSION

This documentation refers to
TrEd::ArabicRemix version 0.2.


=head1 SYNOPSIS

  use TrEd::ArabicRemix;

  my $char = "\x{064B}";
  my $dir = TrEd::ArabicRemix::direction($char); # -1

  $char = "a";
  $dir = TrEd::ArabicRemix::direction($char); # 1

  my $str = "\x{064B}\x{062E}\x{0631}0123";
  my $remixed = TrEd::ArabicRemix::remix($str);

  my $dont_reverse = 0;
  my $remixed_dir = TrEd::ArabicRemix::remixdir($str, $dont_reverse);

=head1 DESCRIPTION

Basic functions for reversing string direction (LTR to RTL) with respect to numbers etc.

=head1 SUBROUTINES/METHODS

=over 4


=item * C<TrEd::ArabicRemix::remix($arabic_string, [$ignored_param])>

=over 6

=item Purpose

Not sure

=item Parameters

  C<$arabic_string> -- scalar $arabic_string   -- string to remix
  C<[$ignored_param]> -- [scalar $ignored_param  -- not used, however it's part of the prototype]

=item Comments

Prototyped function.
Splits the string using various arabic character classes, then take all the even
elements of resulting array and split them into subarrays. Reverse all the odd elements of
each subarray, then reverse the subarray.


=item Returns

Remixed arabic string

=back


=item * C<TrEd::ArabicRemix::direction($string)>

=over 6

=item Purpose

Find out the direction of the $string

=item Parameters

  C<$string> -- scalar $string -- string to be examined



=item Returns

If the $string contains latin characters, numbers or arabic numbers, function returns 1.
Otherwise, if the string containst some arabic characters, function returns -1.
Otherwise function returns 0.

=back


=item * C<TrEd::ArabicRemix::remixdir($string, [$dont_reverse])>

=over 6

=item Purpose

Change the string from left-to-right to right-to-left orientation

=item Parameters

  C<$string> -- scalar $string        -- string to remix
  C<[$dont_reverse]> -- scalar $dont_reverse  -- if set to 1, parts of string are not reversed

=item Comments

Reverse string, but keep latin parts in the same order, e.g. 1 2 _arabic_letter_1 _arabic_letter_2
becomes _arabic_letter_2 _arabic_letter_1 1 2. If $dont_reverse is set to 1,
1 2 _arabic_letter_1 _arabic_letter_2 becomes _arabic_letter_1 _arabic_letter_2 1 2

=item See Also

L<direction>,

=item Returns

Reversed string

=back



=back


=head1 DIAGNOSTICS

No diagnostic messages.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES

No dependencies.

=head1 INCOMPATIBILITIES

No known incompatibilities.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Otakar Smrz <otakar.smrz@mff.cuni.cz>

Copyright (c)
2004 Otakar Smrz <otakar.smrz@mff.cuni.cz>
2011 Peter Fabian (documentation & tests).
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
