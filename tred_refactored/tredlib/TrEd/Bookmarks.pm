package TrEd::Bookmarks;

require TrEd::ManageFilelists;
use TrEd::Config qw{$tredDebug};
require TrEd::Window::TreeBasics;

use strict;
use warnings;

our $VERSION = '0.01';

our $FILELIST_NAME = 'Bookmarks';

# bookmarks the place of last action in TrEd
my $last_action_bookmark = q{};

#######################################################################################
# Usage         : get_last_action()
# Purpose       : Find the last spot of modification/action in TrEd
# Returns       : Stringified identification of place of last action
# Parameters    : no
# Throws        : no exception
# See Also      : set_last_action(), actual_position()
sub get_last_action {
    return $last_action_bookmark;
}

#######################################################################################
# Usage         : set_last_action($new_action_bookmark)
# Purpose       : Set the last action bookmark in TrEd
# Returns       : Undef/empty list
# Parameters    : scalar $new_action_bookmark -- stringified identification of place of last action
# Throws        : no exception
# Comments      : For TrEd to understand the bookmark, its format should be
#                 "fileName##treeNumber", optionally followed by ".nodeNumber"
# See Also      : get_last_action(), actual_position()
sub set_last_action {
    my ($new_action_bookmark) = @_;
    $last_action_bookmark = $new_action_bookmark;
    return;
}

#######################################################################################
# Usage         : bookmark_filelist()
# Purpose       : Return bookmarks filelist object
# Returns       : Filelist object which represents bookmarks or undef if this filelist does not exist
# Parameters    : no
# Throws        : no exception
# See Also      : TrEd::ManageFilelists::find_filelist()
# was main::bookmarkFilelist
sub bookmark_filelist {
    return TrEd::ManageFilelists::find_filelist($FILELIST_NAME);
}

#######################################################################################
# Usage         : create_bookmarks_filelist()
# Purpose       : Create bookmarks filelist
# Returns       : Undef/empty list
# Parameters    : no
# Throws        : no exception
# See Also      : bookmark_filelist()
# was main::createBookmarksFilelist
sub create_bookmarks_filelist {
    # create Bookmarks filelist
    if ( !defined bookmark_filelist() ) {
        if ($tredDebug) {
            print 'Bookmarks: ' . $ENV{HOME} . '/.tred_bookmarks' . "\n";
        }
        my $bookmarks
            = Filelist->new( $FILELIST_NAME, $ENV{HOME} . '/.tred_bookmarks' );
        TrEd::ManageFilelists::add_new_filelist( undef, $bookmarks );
    }
    return;
}


#######################################################################################
# Usage         : actual_position($grp)
# Purpose       : Return identification of actual position
# Returns       : String identification of actual position that can be used as bookmark
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : no exception
# Comments      : The actual position is the highlighted tree/node in focused window
# was main::bookmarkThis
#TODO: toto je asi skor pre node ako pre bookmarks?
# hm, lenze aky node...
sub actual_position {
    my ($grp) = @_;
    my $f     = undef;
    my $win   = $grp->{focusedWindow};
    if ( ref $win->{FSFile} ) {
        $f = $win->{FSFile}->filename() . q{##} . ( $win->{treeNo} + 1 );
        my $nodeno = TrEd::Window::TreeBasics::get_node_no( $win, $win->{currentNode} );
        if ( defined $nodeno ) {
            $f .= ".$nodeno";
        }
    }
    return $f;
}

# #######################################################################################
# Usage         : bookmark_actual_position($grp, $to_filelist)
# Purpose       : Add new bookmark to filelist $to_filelist, or to bookmarks filelist, if
#                 no other filelsit is specified
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
#                 string $to_filelist -- name of the filelist to which the bookmark will be added (optional)
# Throws        : no exception
# Comments      : Also updates the bookmarks menu
# See Also      : TrEd::ManageFilelists::insertToFilelist()
# was main::addBookmark
sub bookmark_actual_position {
    my ( $grp, $to_filelist ) = @_;
    my $filelist
        = defined $to_filelist
        ? TrEd::ManageFilelists::find_filelist($to_filelist)
        : bookmark_filelist();
    return if !ref $filelist;
    my $bookmark = actual_position($grp);
    if ( defined $bookmark ) {
        TrEd::ManageFilelists::insertToFilelist( $grp, $filelist, $filelist->count, $bookmark );
        update_bookmarks($grp);
    }
    return;
}

#######################################################################################
# Usage         : last_action_bookmark($grp, $bookmark)
# Purpose       : Set the last action bookmark to $bookmark or to actual position, if
#                 $bookmark is not defined
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
#                 string $bookmark -- string identification of bookmarked spot
# Throws        : no exception
# See Also      : set_last_action(), bookmark_actual_position()
# was main::lastActionBookmark
sub last_action_bookmark {
    my ( $grp, $bookmark ) = @_;

    my $new_bookmark = defined $bookmark ? $bookmark : actual_position($grp);
    if ( defined $new_bookmark ) {
        if ($tredDebug) {
            print STDERR "Bookmarking last action at: $new_bookmark\n";
        }
        $last_action_bookmark = $new_bookmark;
    }
    return;
}

#######################################################################################
# Usage         : update_bookmarks($grp)
# Purpose       : Updates bookmarks file menu
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : no exception
# Comments      : Does nothing if $grp->{noUpdatePostponed} is set.
# was main::updateBookmarks
sub update_bookmarks {
    my ($grp) = @_;
    return if $grp->{noUpdatePostponed};
    my $menu = $grp->{BookmarksFileMenu};
    if ( $menu ) {
        if ($tredDebug) {
            print STDERR "Updating bookmark menu\n";
        }

        # delete old menu items
        $menu->delete( 0, 'end' );
        foreach my $menu_bookmark ( $menu->children() ) {
            $menu_bookmark->destroy();
        }

        # fetch bookmarks filelist
        my $i  = 0;
        my $bookmark_filelist = bookmark_filelist();
        return if !ref $bookmark_filelist;

        # create new menu items
        foreach my $bookmark ( $bookmark_filelist->files() ) {
            if ($tredDebug) {
                print STDERR "$bookmark\n";
            }
            $menu->command(
                -label     => "$i.  " . $bookmark,
                -underline => 0,
                -command   => [ \&TrEd::File::open_standalone_file, $grp, $bookmark ]
            );
            $i++;
        }
        # e.g. after adding/removing a bookmark to/from a filelist
        main::update_title_and_buttons($grp);
    }
    return;
}

1;

__END__

=head1 NAME


TrEd::Bookmarks


=head1 VERSION

This documentation refers to
TrEd::Bookmarks version 0.2.


=head1 SYNOPSIS

  use TrEd::Bookmarks;



=head1 DESCRIPTION

Basic functions for reversing string direction (LTR to RTL) with respect to numbers etc.

=head1 SUBROUTINES/METHODS

=over 4





=back


=head1 DIAGNOSTICS

No diagnostic messages.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES



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
