package TrEd::ManageFilelists;

use strict;
use warnings;

use Carp;
use Cwd;
use File::Spec;

#use TrEd::MinMax; # max2
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::Config qw{$tredDebug @config_filelists};
require TrEd::File;
TrEd::File->import(qw{close_file absolutize filename});

use Treex::PML qw{&Index};
use Treex::PML::IO;
use Filelist;
require TrEd::Bookmarks;

BEGIN {
    if ( exists &Tk::MainLoop ) {
        require TrEd::Dialog::File::Open;
        require TrEd::Query::List;
        require TrEd::Query::User;
        require TrEd::Query::Simple;
    }
}

our $VERSION = "0.1";

# list of all loaded filelists
my @filelists = ();

# filelists from extensions
my %filelist_from_extension = ();

# filelists from .tred.d/filelists folder (filelist's name => 2)
my %filelist_from_std_location = ();

#######################################################################################
# Usage         : _dump_filelists($fn_name, $filelists_ref)
# Purpose       : Dump information about filelists stored inside $filelists_ref array
# Returns       : Undef/Empty list
# Parameters    : string $fn_name -- name of the function that calls the dump (typically, could be any string)
#                 array_ref $filelists_ref -- ref to array of filelists (Filelist objects, possibly)
# Throws        : no exception
# Comments      : Debugging & helper function
sub _dump_filelists {
    my ( $fn_name, $filelists_ref ) = @_;
    print "$fn_name: ";
    print "$filelists_ref\n";
    require Data::Dumper;

    #  local $Data::Dumper::Maxdepth = 1;
    print Dumper($filelists_ref) . "\n";

    #  foreach my $fl (@{$filelists_ref}) {
    #    print "\t" . $fl . q{: } . $fl->name .  "\n";
    #  }
    return;
}

#######################################################################################
# Usage         : get_filelists()
# Purpose       : Returns list of filelists
# Returns       : List of filelists (possibly Filelist objects)
# Parameters    : no
# Throws        : no exception
# Comments      :
# See Also      : add_new_filelist(), add_filelist(), deleteFilelist()
sub get_filelists {

    # _dump_filelists("get_filelists", \@filelists);
    return @filelists;
}

#######################################################################################
# Usage         : find_filelist($name)
# Purpose       : Find filelist by name
# Returns       : Filelist with name $name, if it exists.
#                 Undef/empty list otherwise.
# Parameters    : string $name -- name of the filelist to search for
# Throws        : no exception
# See Also      : get_filelists()
sub find_filelist {
    my ($name) = @_;

    # _dump_filelists("find_filelist", \@filelists);
    foreach my $filelist (@filelists) {
        if ( $filelist->name() eq $name ) {
            return $filelist;
        }
    }
    return;
}

#######################################################################################
# Usage         : add_filelist($filelist)
# Purpose       : Add filelist to array of filelists
# Returns       : Added Filelist object
# Parameters    : Filelist ref $filelist -- reference to Filelist to be added
# Throws        : no exception
# See Also      : find_filelist(),
# was main::addFilelist
sub add_filelist {
    my ($filelist) = @_;

    # _dump_filelists("add_filelist", \@filelists);
    push @filelists, $filelist;
    print "Adding filelist " . $filelist->name() . "\n";
    return $filelist;
}

#######################################################################################
# Usage         : _user_resolve_filelist_conflict($top, $filelist_filename_new, $filelist_filename_colliding)
# Purpose       : Allows user to reload filelist, if it is identical filelist or rename filelist that already exists in TrEd
# Returns       : The result of TrEd::Query::User::new_query function, i.e. the string which represents user's choice
# Parameters    : Tk::Widget $top -- top widget in TrEd (for creating new dialog)
#                 string $filelist_filename_new -- file name of filelist that is being added/created
#                 string $filelist_filename_colliding -- filename of already existing filelist, whose name conflicts with new filelist
# Throws        : no exception
# Comments      :
# See Also      : TrEd::Query::User::new_query()
sub _user_resolve_filelist_conflict {
    my ( $top, $filelist_filename_new, $filelist_filename_colliding ) = @_;
    if ( Treex::PML::IO::is_same_file( $filelist_filename_colliding, $filelist_filename_new ) ) {
        return TrEd::Query::User::new_query(
            $top,
            "Filelist '" . $filelist_filename_new . "' already loaded.\n",
            -bitmap  => 'question',
            -title   => "Reload filelist?",
            -buttons => [ 'Reload', 'Cancel' ]
        );
    }
    else {
        return TrEd::Query::User::new_query(
            $top,
            "Filelist named '"
                . $filelist_filename_new
                . "' is already loaded from\n"
                . $filelist_filename_colliding . "\n",
            -bitmap  => 'question',
            -title   => "Filelist conflict",
            -buttons => [ 'Replace', 'Change name', 'Cancel' ]
        );
    }
}

#######################################################################################
# Usage         : _solve_filelist_conflict($top, $filelist)
# Purpose       : Ask user what to do if filelist with same name as he/she wants to create
#                 already exists, replace the original filelist by default
# Returns       : A list of two items: a colliding filelist (if there is any, undef otherwise)
#                 and indication of continuation for caller function
# Parameters    : Tk::Widget $top -- top widget in TrEd, determines whether Tk dialogs will be shown
#                 Filelist $filelist -- filelist object, whose conflicts will be checked for
# Throws        : Dies with stack backtrace if the name of the filelist $filelist could not be determined
# Comments      : If $top is defined, user is prompted to resolve conflict (by renaming the new
#                 filelist or reloading existing one). 
#                 Otherwise, the original filelist is replaced by the new one.
#                 If the user cancels the operation or does not support us with a new name, the
#                 indication for the caller is string 'return', otherwise, a string 'cont'
#                 is returned as the second element of list.
# See Also      : _user_resolve_filelist_conflict(), add_new_filelist()
sub _solve_filelist_conflict {
    my ( $top, $filelist ) = @_;

    my $old_name = eval { $filelist->name() };
    if ($@) {
        confess($@);
    }

    my $colliding_filelist;
LOOP:
    for my $dummy (1) {

        # ($l) = grep { $_->name eq $fl->name } @filelists;
        $colliding_filelist
            = TrEd::MinMax::first { $_->name() eq $filelist->name() }
                                  @filelists;
        #don't prompt user if nothing collides
        last if not $colliding_filelist;

        if ($top) {
            my $answer = _user_resolve_filelist_conflict( $top,
                $filelist->filename(), $colliding_filelist->filename() );
            return ( $colliding_filelist, 'return' ) if $answer eq 'Cancel';
            if ( $answer eq 'Change name' ) {
                my $new_name
                    = TrEd::Query::String::new_query( $top, "Filelist name",
                    "Name: ", $filelist->name );
                return ( $colliding_filelist, 'return' )
                    if ( !defined $new_name );
                $filelist->rename($new_name);
                redo LOOP;
            }
        }
        elsif ($tredDebug) {
            print STDERR 'Filelist ', $filelist->name(),
                " already exists, replacing!\n";
        }
    }

    # rename filelist if the user chose different name
    if ( $old_name ne $filelist->name() ) {
        if ( !$main::opt_q ) {
            print STDERR 'Saving filelist ' . $filelist->name() . ' to: ',
                $filelist->filename(), "\n";
        }
        $filelist->save();
    }
    return ( $colliding_filelist, 'cont' );
}


#######################################################################################
# Usage         : selectFilelistDialog($grp)
# Purpose       : 
# Returns       : 
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub selectFilelistDialog {
    my ($grp) = @_;

    # Dump was commented out, so its pointless to use Devel::Peek
    #  use Devel::Peek;
    #  for (@filelists) {
    #    #Dump($_->name);
    #  }
    my @lists = sort { $a->[2] cmp $b->[2] }
        ( map { [ $_, $_->name, lc( $_->name ) ] } @filelists );
    return unless @lists;
    my $i         = 'A';
    my $selection = [ $i . '.  ' . $lists[0]->[1] ];
    TrEd::Query::List::new_query( $grp->{top}, 'Select File Lists',
        'browse', [ map { ( $i++ ) . ".  " . $_->[1] } @lists ], $selection, )
        || return;
    return unless ( @{$selection} );
    my $sel = $selection->[0];
    $sel =~ s {^\w+.  }{};
    selectFilelist( $grp, $sel );
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub loadFilelist {
    my ( $grp, $top ) = @_;

    # _dump_filelists("loadFilelist", \@filelists);
    $top ||= $grp->{top};
    my $file = TrEd::Dialog::File::Open::get_open_filename(
        $top,
        -filetypes =>
            [ [ "Filelists", ['.fl'] ], [ "All files", [ '*', '*.*' ] ] ],
        -title => "Load filelist ..."
    );
    $top->deiconify();
    $top->focus();
    $top->raise();
    return unless ( defined $file and $file ne $EMPTY_STR );
    my $fl = Filelist->new( undef, $file );
    return unless $fl;
    print STDERR "Loading filelist: $file\n";
    $fl->load();
    add_new_filelist( $grp, $fl, $top );
    return $fl->name();
}

#######################################################################################
# Usage         : load_std_filelists()
# Purpose       : Load 'standard' filelists (i.e. filelists placed in .tred.d/filelists folder)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub load_std_filelists {
    my $dir = File::Spec->catdir( $main::tred_d, 'filelists' );

    # _dump_filelists("load_std_filelists", \@filelists);
    return unless -d $dir;
    my %name = map { $_->name() => $_ } @filelists;
    for my $filelist_filename ( glob( File::Spec->catfile( $dir, '*' ) ) ) {
        my $name = TrEd::File::filename($filelist_filename);
        $name =~ s/\.fl$//i;    # strip .fl suffix if any
        my $uname
            = Encode::decode( 'UTF-8', URI::Escape::uri_unescape($name) );
        if ( URI::Escape::uri_escape_utf8($uname) ne $name ) {
            my $nf = File::Spec->catfile( $dir,
                URI::Escape::uri_escape_utf8($uname) );
            if ( rename $filelist_filename, $nf ) {    # rename unescaped version if exists
                $filelist_filename = $nf;
                print STDERR "renaming\n $filelist_filename\n  to\n $nf\n" if $tredDebug;
            }
            else {
                warn "Failed to rename $filelist_filename to $nf\n";
            }
        }
        $name = $uname;
        if ( exists $name{$name} ) {
            warn(
                "Ignoring filelist $filelist_filename, filelist named $name already loaded from ",
                $name{$name}->filename, "\n"
            );
        }
        else {
            my $fl = Filelist->new( $name, $filelist_filename );
            if ($fl) {
                print STDERR "Reading filelist " . $fl->filename . "\n"
                    if $tredDebug;
                eval {
                    $fl->load();
                    add_new_filelist( undef, $fl );
                };
                if ($@) {
                    warn $@;
                }
                else {
                    $filelist_from_std_location{$fl} = 1;
                }
            }
        }
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub saveStdFilelist {
    my ($fl) = @_;

    # _dump_filelists("saveStdFilelist", \@filelists);
    my $dir = File::Spec->catdir( $main::tred_d, 'filelists' );
    mkdir $dir unless -d $dir;
    my $name = $fl->name();
    $name = URI::Escape::uri_escape_utf8($name);
    if ( defined $name and length $name ) {
        $fl->filename( File::Spec->catdir( $dir, $name ) );
        $fl->save();
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# for each filelist add an entry to a given menu
# using -command => [ @command, $filelist_name ]
# as menu callback
# filelist menu, UI
sub createFilelistsMenu {
    my ( $grp, $menu, $command, $bookmark_to ) = @_;

    # _dump_filelists("createFilelistsMenu", \@filelists);
    my $i = 'A';
    foreach my $fl (
        sort { lc( $a->name() ) cmp lc( $b->name() ) }
        grep {
            !( $bookmark_to
                and ( ( $filelist_from_extension{$_} || 0 ) == 1 ) )
        } @filelists
        )
    {
        $menu->command(
            -label     => "$i.  " . $fl->name(),
            -underline => 0,
            -command   => [ @$command, $fl->name() ]
        );
        $i++;
    }
    if ($bookmark_to) {
        $menu->separator();
        $menu->command(
            -label => (
                $bookmark_to ? 'New File List...' : 'Create New File List ...'
            ),
            -command => [
                \&makeNewFilelist, $grp,
                \&TrEd::Bookmarks::bookmark_actual_position
            ]
        );
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub makeNewFilelist {
    my ( $grp, $action ) = @_;

# Let's suppose that once there was only one argument to this function and then
# it's been transformed to two-arg function, so this line should have been deleted
#  my $grp = shift; #??? wtf
# _dump_filelists("makeNewFilelist", \@filelists);
    my $fl = createNewFilelist($grp);
    if ( defined $fl ) {
        my $sub  = shift;
        my $name = $fl->name;
        $action->( $grp, $name ) if $action;
        saveStdFilelist($fl);
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# extracted from main::updateRuntimeConfig
sub update_runtimeconfig_filelists {
    my ( $s, $conf ) = @_;

    # _dump_filelists("update_filelists", \@filelists);
    my $i = 0;
    foreach my $filelist (@filelists) {
        next
            if ( exists $filelist_from_extension{$filelist}
            && $filelist_from_extension{$filelist} == 1 );
        my $fn   = ref $filelist && $filelist->filename();
        my $name = ref $filelist && $filelist->name();
        next if ( $name eq 'Default' || $name =~ /^CmdLine-\d+$/ );
        if ( !defined $fn || !length $fn ) {
            saveStdFilelist($filelist);
        }
        else {
            $filelist->save();
            if (   !$filelist_from_extension{$filelist}
                && !$filelist_from_std_location{$filelist} )
            {
                $s = $filelist->filename();
                $s =~ s/\\/\\\\/g;
                push @{$conf}, "filelist" . $i++ . "\t\t=\t" . $s . "\n";
            }
        }
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# extracted from loadMacros
sub create_ext_filelist {
    my ($f) = @_;

    # _dump_filelists("create_ext_filelist", \@filelists);
    print "Reading $f\n" if $tredDebug;
    my $fl = Filelist->new( undef, $f );
    next unless $fl;
    print STDERR "Reading filelist " . $fl->filename . "\n" if $tredDebug;
    eval {
        $fl->load();
        add_new_filelist( undef, $fl );
    };
    if ($@) {
        warn $@;
    }
    else {
        $filelist_from_extension{$fl} = 1;
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# comes from main::, maybe to bookmarks..?
sub bookmarkToFilelistDialog {
    my ($grp) = @_;
    my @lists = sort { $a->[2] cmp $b->[2] }
        grep { ( $filelist_from_extension{ $_->[0] } || 0 ) != 1 }
        map { [ $_, $_->name, lc( $_->name ) ] } 
        @filelists;
    return if !@lists;
    my $i         = 'A';
    my $selection = [ $i . '.  ' . $lists[0]->[1] ];
    TrEd::Query::List::new_query( $grp->{top}, 'Add Bookmark To File Lists',
        'browse', [ map { ( $i++ ) . '.  ' . $_->[1] } @lists ], $selection, )
        || return;
    return unless (@$selection);
    my $sel = $selection->[0];
    $sel =~ s {^\w+.  }{};
    TrEd::Bookmarks::bookmark_actual_position( $grp, $sel );
    return;
}

#######################################################################################
# Usage         : create_filelists($cmdline_filelists)
# Purpose       : Create filelists during TrEd's start up: 'Default' filelist, 
#                 filelists specified on command line, bookmark filelist and standard filelists
# Returns       : Undef/empty list
# Parameters    : string $cmdline_filelists -- filelists specified on the command line
# Throws        : no exception
# See Also      : create_ext_filelist(), create_cmdline_filelists(), load_std_filelists()
# was main::createCmdLineFilelists
sub create_filelists {
    my ($cmdline_filelists) = @_;
    print STDERR "Creating filelists...\n" if $tredDebug;

    # create 'Default' filelist
    {
        my $default_filelist = new Filelist('Default');
        if (@ARGV) {
            $default_filelist->add(
                0,
                map {
                    my ( $filename, $suffix )
                        = TrEd::Utils::parse_file_suffix($_);
                    Treex::PML::IO::make_abs_URI($filename)->as_string . $suffix
                    } @ARGV
            );
        }
        add_new_filelist( undef, $default_filelist );
    }

    create_cmdline_filelists($cmdline_filelists);
    TrEd::Bookmarks::create_bookmarks_filelist();
    load_std_filelists();
    return;
}

#######################################################################################
# Usage         : create_cmdline_filelists($filelist_str)
# Purpose       : Create filelists specified on the command line
# Returns       : Undef/empty list
# Parameters    : string $filelist_str -- string which contains comma delimited names of filelist files
# Throws        : no exception
# Comments      : Filelists created from command line will be named 'CmdLine-#no#' according
#                 to the order of their appearance on the command line
# See Also      : create_filelists(), create_bookmarks_filelist()
# was main::createCmdLineFilelists
sub create_cmdline_filelists {
    my ($filelist_str) = @_;
    return if not($filelist_str);

    print STDERR "Reading -l filelists...\n" if $tredDebug;

    my $fl_no = 1;
    foreach my $filelist ( split /\s*,\s*/, $filelist_str ) {
        my $filelist_name = 'CmdLine-' . $fl_no;
        my $fl = new Filelist( $filelist_name, $filelist );
        $fl->load();
        add_new_filelist( undef, $fl );
        $fl_no++;
    }
    print STDERR "Done...\n" if $tredDebug;
    return;
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# extracted from main::set_config
sub load_filelists_from_conf {
    my $fl;
    foreach my $config_filelist ( @TrEd::Config::config_filelists )
    {
        print "Reading $_\n" if $tredDebug;
        $fl = Filelist->new( undef, $config_filelist );
        next unless $fl;
        eval {
            print STDERR "Reading filelist " . $fl->filename() . "\n"
                if $tredDebug;
            $fl->load();
            add_new_filelist( undef, $fl );
        };
        warn $@ if $@;
    }
}

#######################################################################################
# Usage         : selectFilelistNoUpdate($grp_or_win, $list_name, $no_reset_position)
# Purpose       : Select filelist $list_name for specified window without updating it
# Returns       : Undef/empty list if filelist was not found.
#                 Filelist object if the filelist was found successfully.
# Parameters    : hash_ref or TrEd::Window ref $grp_or_win -- reference to hash containing TrEd options or ref to TrEd::Window
#                 string $list_name       -- 
#                 bool $no_reset_position -- 
# Throws        : no exception
# Comments      : ...
# See Also      : selectFilelist()
sub selectFilelistNoUpdate {
    my ( $grp_or_win, $list_name, $no_reset_position ) = @_;

    my ( $grp, $win ) = main::grp_win($grp_or_win);
    my $fl
        = $win->is_focused()
        ? TrEd::Dialog::Filelist::switch_filelist( $grp, $list_name )
        : find_filelist($list_name);
    print "Selecting filelist '$list_name' (found: $fl)\n" if $tredDebug;
    return if ( !defined $fl );

    # little fiddling with condition
    if ( !exists $win->{currentFilelist} || $fl != $win->{currentFilelist} ) {

        # save file position in the current file-list
        # before switching
        $win->{currentFilelist}->set_current(
            TrEd::Filelist::Navigation::filelist_full_filename(
                $win, $win->{currentFileNo}
            )
        ) if ref( $win->{currentFilelist} );
        $win->{currentFilelist} = $fl;
    }
    if ( !$no_reset_position ) {
        $win->{currentFileNo} = TrEd::MinMax::max2( 0, $fl->position() );
    }
    return $fl;
}

#######################################################################################
# Usage         : selectFilelist($grp_or_win, $list_name, $opts)
# Purpose       : 
# Returns       : 
# Parameters    : hash_ref or TrEd::Window ref $grp_or_win -- reference to hash containing TrEd options or ref to TrEd::Window
#                 string $list_name -- 
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub selectFilelist {
    my ( $grp_or_win, $list_name, $opts ) = @_;

    # _dump_filelists("selectFilelist", \@filelists);
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    my $fl = selectFilelistNoUpdate( $win, $list_name );
    if ( $fl and !$opts->{no_open} ) {
        if ( $win->{currentFileNo} >= $fl->file_count() ) {
            TrEd::File::close_file($win);
        }
        else {
            # we use next_file instead of go_to_file so that
            # the user can 'Skip broken files'
            $win->{currentFileNo}--;
            TrEd::Filelist::Navigation::next_file($win);
        }
        main::update_title_and_buttons($grp);

        #TODO: neprepisat na sipkovu notaciu?
        TrEd::Filelist::View::update( $grp, $fl, 1 );
    }
    return $fl;
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub removeFromFilelist {
    my ( $grp_or_win, $filelist, $position ) = ( shift, shift, shift );
    my @files_to_remove = grep {defined} @_;
    if ( !scalar @files_to_remove ) {
        print STDERR "removeFromFilelist: no file given\n";
        return;
    }

    my ( $grp, $win ) = main::grp_win($grp_or_win);
    $filelist = $win->{currentFilelist} if not defined($filelist);
    $position = $win->{currentFileNo}   if not defined($position);
    return unless ref($filelist) && UNIVERSAL::can( $filelist, 'remove' );

    $filelist->remove(@files_to_remove);
    if ( $filelist eq $win->{currentFilelist} ) {
        $win->{currentFileNo} = TrEd::MinMax::min( $win->{currentFileNo},
            $filelist->file_count - 1 );
    }
    my $filelist_widget = TrEd::Dialog::Filelist::filelist_widget();
    main::update_filelist_views( $grp, $filelist, 1 );
    if (    $filelist_widget
        and $TrEd::Dialog::Filelist::current_filelist == $filelist )
    {
        $position
            = TrEd::MinMax::min2( $position, $filelist->file_count - 1 );
        TrEd::Filelist::View::update_a_filelist_view( $grp, $filelist_widget,
            $filelist, $position, 0 );
    }
    return;
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub createNewFilelist {
    my ( $grp, $top ) = @_;

    # _dump_filelists("createNewFilelist", \@filelists);
    my $name = TrEd::Query::String::new_query(
        $top || $grp,
        "File-list name",
        "Name: "
    ) || return;
    if ($top) {
        $top->deiconify();
        $top->focus();
        $top->raise();
    }
    if ( find_filelist($name) ) {
        TrEd::Query::User::new_query(
            $top || grp_win($grp),
            "File-list named '$name' already exists.\n",
            -title   => "File-list already exists",
            -buttons => ["OK"]
        );
        return;
    }
    else {
        my $fl = Filelist->new($name);
        add_filelist($fl);
        TrEd::Dialog::Filelist::switch_filelist( $grp, $fl->name );
        main::updatePostponed($grp);
        return $fl;
    }
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub insertToFilelist {
    my ( $grp_or_win, $filelist, $position ) = ( shift, shift, shift );

    # _dump_filelists("insertToFilelist", \@filelists);
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    $filelist = $win->{currentFilelist} unless defined($filelist);
    $position = $win->{currentFileNo}   unless defined($position);
    return -1 unless ref($filelist) && UNIVERSAL::can( $filelist, 'add' );

    print "Insert: ", @_, " ", $_[0], " is at position ",
        $filelist->position( $_[0] ), "\n"
        if $tredDebug;
    return -1 if ( @_ == 1 and $filelist->position( $_[0] ) >= 0 );

    # this is the case when we add a file which is actually already there

    my @list = map { TrEd::File::absolutize($_) } @_;
    my $tmp;
    my $filelist_widget = TrEd::Dialog::Filelist::filelist_widget();
    my $toplevel
        = $filelist_widget ? $filelist_widget->toplevel : $grp->{top};
    @list = map {
        my $dir = $_;
        if ( -d $dir )
        {
            $grp->{'hist-fileListPattern'} = []
                unless $grp->{'hist-fileListPattern'};
            $tmp = TrEd::Query::Simple::new_query(
                $toplevel,
                "Selection Pattern",
                "Insert pattern for directory $dir",
                "*.*", 1, $grp->{'hist-fileListPattern'}
            );
            $dir = defined $tmp ? File::Spec->catfile( $dir, $tmp ) : undef;
        }
        $dir;
    } @list;
    $position = TrEd::MinMax::min( $position + 1, $filelist->count() ) - 1;
    print "Inserting @list to position ", $position + 1, "\n" if $tredDebug;
    $filelist->add( $position + 1, @list );

    main::update_filelist_views( $grp, $filelist, 1 );
    if (    $filelist_widget
        and $TrEd::Dialog::Filelist::current_filelist == $filelist )
    {
        $position = TrEd::MinMax::max2( 0, $filelist->position( $list[0] ) );
        TrEd::Filelist::View::update_a_filelist_view( $grp, $filelist_widget,
            $filelist, $position, 0 );

        # select all files resulting from an added patterns
        for ( my $i = 0; $i < $filelist->file_count; $i++ ) {
            if (defined(
                    Treex::PML::Index( \@list, $filelist->file_pattern($i) )
                )
                )
            {
                my $file = $filelist->entry_path( $i );
                if ( $filelist_widget->info( 'exists', $file ) ) {
                    $filelist_widget->selectionSet($file);
                }
            }
        }
    }
    return $position + 1;
}

#######################################################################################
# Usage         : removeFilelistsDialog($grp)
# Purpose       : Create window with a list of deletable filelists and optionally 
#                 remove some of them on user's request
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : no exception
# Comments      : Called for menu item File -> File Lists -> Remove File Lists, needs Tk
# See Also      : TrEd::Query::User::new_query(),
sub removeFilelistsDialog {
    my ($grp) = @_;

    # create list of triples: Filelist, its name and its name lowercased
    my @lists = sort { $a->[1] cmp $b->[1] }
        grep {
               $_->[1] ne 'Default'
            && $_->[1] ne $TrEd::Bookmarks::FILELIST_NAME
            && ( $filelist_from_extension{ $_->[0] } || 0 ) != 1
        }
        map { [ $_, $_->name, lc( $_->name ) ] }
        @filelists;

    return if !@lists;
    my $i         = 'A';
    my $selection = [ $i . '.  ' . $lists[0]->[1] ];
    my $indexes   = TrEd::Query::List::new_query(
        $grp->{top}, 'Remove File Lists',
        'extended', [ map { ( $i++ ) . '.  ' . $_->[1] } @lists ],
        $selection, { -label => 'Select one or more file lists', }
    ) || return;
    return
        unless (
        @{$selection}
        && TrEd::Query::User::new_query(
            $grp->{top},
            "Realy remove " . scalar(@$selection) . " file list(s)?\n",
            -bitmap  => 'question',
            -title   => "Remove file lists?",
            -buttons => [ 'Remove', 'Cancel' ]
        ) eq 'Remove'
        );
    deleteFilelist( $grp, map $_->[0], @lists[@{$indexes}] );
    return;
}

#######################################################################################
# Usage         : add_new_filelist($grp, $fl, $top)
# Purpose       : Add new filelist $fl, resolve possible conflict in names of filelists
# Returns       : In case of no collision (and also after renaming new filelist, if it collided),
#                 the $fl filelist is returned. If a collision in names of the filelists occurs, 
#                 there are two possible return values, depending on user's choice:
#                 a) if users cancels the adding, the already existing colliding filelist is returned
#                 b) if users wishes to replace the already existing colliding filelist,
#                 colliding filelist is returned, too, but this time it contains all the information
#                 from the new filelist $fl.
#                 If $fl is not defined, undef/empty string is returned.
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
#                 Filelist $fl -- filelist to be added
#                 Tk::Widget $top -- top widget for creating dialogs
# Throws        : If the name of filelist $fl could not be determined, dies with backtrace (from _solve_filelist_conflict)
# Comments      : If $grp is defined, changes the filelist in TrEd::Dialog::Filelist and calls 
#                 postponed update (main::updatePostponed)
# See Also      : _solve_filelist_conflict(), main::updatePostponed(), TrEd::Dialog::Filelist::switch_filelist()
# TODO: tests
# was main::addNewFilelist
sub add_new_filelist {
    my ( $grp, $fl, $top ) = @_;

    # dump_filelists("add_new_filelist", \@filelists);
    return if ( !defined $fl || $fl eq $EMPTY_STR );

    # returns other filelist with same name, undef otherwise
    my ( $colliding, $cont ) = _solve_filelist_conflict( $top, $fl );

    # user cancelled the operation, return
    if ( $cont eq 'return' ) {
        return $colliding;
    }

    if ($colliding) {
        # replace information in colliding filelist with info from the new filelist
        @{ $colliding->list_ref } = $fl->list();
        $colliding->filename( $fl->filename() );
        $colliding->expand();
        if ($grp) {
            $TrEd::Dialog::Filelist::current_filelist = undef;
            TrEd::Dialog::Filelist::switch_filelist( $grp, $colliding );
        }
        undef $fl;
        return $colliding;
    }
    if ( !defined $fl->name() or $fl->name() eq $EMPTY_STR ) {
        undef $fl;
        return;
    }
    push @filelists, $fl;
    if ($grp) {
        TrEd::Dialog::Filelist::switch_filelist( $grp, $fl );
        main::updatePostponed($grp);
    }
    return $fl;
}


#######################################################################################
# Usage         : deleteFilelist($grp, @filelists)
# Purpose       : Remove filelists which are elements of @filelists from TrEd and also from disk
#                 if they are placed in standard location (~/.tred.d directory)
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
#                 array of Filelists @lists -- filelists to remove
# Throws        : Carps if @lists contains item which is not a reference.
# Comments      : Does nothing if there is nothing to delete.
# See Also      : main::updatePostponed(), TrEd::Dialog::Filelist::switch_filelist()
# TODO: tests
# was main::deleteFilelist
sub deleteFilelist {
    my ( $grp, @lists ) = @_;

    # filter out Default filelist, Bookmarks filelist and filelists from extensions
    @lists = grep {
        (   ref $_
            ? ( ( $filelist_from_extension{$_} || 0 ) != 1 )
            : do { carp("deleteFilelist: $_ is not a Filelist object!"); 0 }
            )
            and $_->name !~ /^(Default|Bookmarks)$/
    } @lists;
    return if !@lists;

    my %to_delete;
    @to_delete{@lists} = ();

    print "Removing filelists " . join( ",", map $_->name(), @lists ) . "\n"
        if $tredDebug;
    # remove Filelists which are being deleted from @filelists array
    @filelists = grep { !exists $to_delete{$_} } @filelists;

    # delete filelist from standard location (~.tred.d/...)
    for my $list (@lists) {
        if ( exists $filelist_from_std_location{$list} ) {
            my $fn = $list->filename();
            if ($fn) {
                print "Deleting filelist file $fn\n" if $tredDebug;
                unlink $fn;
            }
        }
    }

    # take care of current filelist, if it was deleted, switch to 'Default' one
    if ( defined $TrEd::Dialog::Filelist::current_filelist
        && exists( $to_delete{$TrEd::Dialog::Filelist::current_filelist} ) )
    {
        $TrEd::Dialog::Filelist::current_filelist = undef;
        TrEd::Dialog::Filelist::switch_filelist( $grp, 'Default' );
    }

    # update menu with opened files and filelists
    main::updatePostponed($grp);
    return;
}

1;

__END__

# pod comes here
