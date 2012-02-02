package TrEd::RecentFiles;

use strict;
use warnings;

use TrEd::MinMax;
require TrEd::File;
TrEd::File->import(qw{absolutize});

use TrEd::Config qw{@config_recent_files};


my @recent_files;

#######################################################################################
# Usage         : add_file($grp, $file_name)
# Purpose       : Add file with name $file_name to list of recent files and update menu
#                 accordingly
# Returns       : Undef/empty list
# Parameters    : hash ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file that will be added to recent files list
# Throws        : No exception
# Comments      : Updates $grp->{RecentFileMenu}
# See Also      : recent_files(), init_recent_files()
sub add_file {
    my ( $grp, $file_name ) = @_;
    return if $grp->{noRecent};
    if ( defined($file_name) ) {
        ($file_name) = TrEd::File::absolutize($file_name);
        @recent_files = grep { $_ ne $file_name } @recent_files;
        unshift @recent_files, $file_name;
    }
    my $max_index = TrEd::MinMax::min( $#recent_files, $TrEd::Config::MAX_RECENTFILES );
    @recent_files = @recent_files[ 0 .. $max_index ];

    #TODO: toto mozno delegovat niekam
    if ( $grp->{RecentFileMenu} ) {
        my $menu = $grp->{RecentFileMenu};
        $menu->delete( 0, 'end' );
        $_->destroy() for $menu->children();

        main::populate_recent_files_menu( $grp, \@recent_files );
    }
    return;
}

sub recent_files {
    return @recent_files;
}

sub init_recent_files {
    @recent_files = @TrEd::Config::config_recent_files;
    return;
}

1;
