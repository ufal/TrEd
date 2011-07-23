package TrEd::ManageFilelists;

use strict;
use warnings;

use Carp;
use Cwd;
use File::Spec;

#use TrEd::MinMax; # max2
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::Config qw{$tredDebug};
require TrEd::File;
TrEd::File->import(qw{closeFile absolutize filename});

use Treex::PML qw{&Index};
use Treex::PML::IO;
use Filelist;
require TrEd::Bookmarks;
require TrEd::Dialog::File::Open;

require TrEd::Query::List;
require TrEd::Query::User;
require TrEd::Query::Simple;

# list of all loaded filelists
my @filelists = ();

# filelists from extensions
my %filelist_from_extension = ();

#use Data::Dumper;

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
}

#######################################################################################
# Usage         : get_filelists()
# Purpose       : Returns list of filelists
# Returns       : List of filelists (possibly Filelist objects)
# Parameters    : no
# Throws        : no exception
# Comments      :
# See Also      : add_new_filelist(), addFilelist(), deleteFilelist()
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
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub addFilelist {
    my ($fl) = @_;

    # _dump_filelists("addFilelist", \@filelists);
    push @filelists, $fl;
    print "adding filelist " . $fl->name() . "\n";
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
sub _user_resolve_filelist_conflict {
    my ( $top, $file_name_loaded, $file_name_new ) = @_;
    if ( Treex::PML::IO::is_same_file( $file_name_new, $file_name_loaded ) ) {
        return TrEd::Query::User::new_query(
            $top,
            "Filelist '" . $file_name_loaded . "' already loaded.\n",
            -bitmap  => 'question',
            -title   => "Reload filelist?",
            -buttons => [ 'Reload', 'Cancel' ]
        );
    }
    else {
        return TrEd::Query::User::new_query(
            $top,
            "Filelist named '" 
                . $file_name_loaded
                . "' is already loaded from\n"
                . $file_name_new . "\n",
            -bitmap  => 'question',
            -title   => "Filelist conflict",
            -buttons => [ 'Replace', 'Change name', 'Cancel' ]
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
sub _solve_filelist_conflict {
    my ( $top, $filelist ) = @_;

    my $old_name = eval { $filelist->name() };
    if ($@) {
        confess($@);
    }

    my $l;
LOOP:
    for my $dummy (1) {

        # ($l) = grep { $_->name eq $fl->name } @filelists;
        $l = TrEd::MinMax::first { $_->name() eq $filelist->name() }
        @filelists;
        last if not $l;
        if ($top) {
            my $answer = _user_resolve_filelist_conflict( $top,
                $filelist->filename(), $l->filename() );
            return ( $l, 'return' ) if $answer eq 'Cancel';
            if ( $answer eq 'Change name' ) {
                my $new_name
                    = TrEd::Query::String::new_query( $top, "Filelist name",
                    "Name: ", $filelist->name );
                return ( $l, 'return' ) if ( !defined($new_name) );
                $filelist->rename($new_name);
                redo LOOP;
            }
        }
        elsif ($tredDebug) {
            print STDERR 'Filelist ', $filelist->name(),
                " already exists, replacing!\n";
        }
    }

    if ( $old_name ne $filelist->name() ) {
        if ( not $main::opt_q ) {
            print STDERR 'Saving filelist ' . $filelist->name() . ' to: ',
                $filelist->filename(), "\n";
        }
        $filelist->save();    # filelist renamed
    }
    return ( $l, 'cont' );
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
sub filelistEntryPath {
    my ( $fl, $index ) = @_;
    return if ( !ref($fl) );

    my $f = $fl->file_at($index);
    my $p = $fl->file_pattern($index);

    # some mambo-jumbo to supress complaints about undef
    return if ( !defined $f );

    # $f is defined now
    # if $p is not defined, $f ne $p, should return "$p\t$f", so skip $p
    if ( !defined $p ) {
        return "\t$f";
    }
    return $f eq $p ? $f : "$p\t$f";
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
sub selectFilelistDialog {
    my ($grp) = @_;

    # Dump was commented out, so its pointless to use Devel::Peek
    #  use Devel::Peek;
    #  for (@filelists) {
    #    #Dump($_->name);
    #  }
    my @lists
        = sort { $a->[2] cmp $b->[2] }
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
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub loadStdFilelists {
    my $dir = File::Spec->catdir( $main::tred_d, 'filelists' );

    # _dump_filelists("loadStdFilelists", \@filelists);
    return unless -d $dir;
    my %name = map { $_->name() => $_ } @filelists;
    for my $f ( glob( File::Spec->catfile( $dir, '*' ) ) ) {
        my $name = TrEd::File::filename($f);
        $name =~ s/\.fl$//i;    # strip .fl suffix if any
        my $uname
            = Encode::decode( 'UTF-8', URI::Escape::uri_unescape($name) );
        if ( URI::Escape::uri_escape_utf8($uname) ne $name ) {
            my $nf = File::Spec->catfile( $dir,
                URI::Escape::uri_escape_utf8($uname) );
            if ( rename $f, $nf ) {    # rename unescaped version if exists
                $f = $nf;
                print STDERR "renaming\n $f\n  to\n $nf\n" if $tredDebug;
            }
            else {
                warn "Failed to rename $f to $nf\n";
            }
        }
        $name = $uname;
        if ( exists $name{$name} ) {
            warn(
                "Ignoring filelist $f, filelist named $name already loaded from ",
                $name{$name}->filename, "\n"
            );
        }
        else {
            my $fl = Filelist->new( $name, $f );
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
                    $filelist_from_extension{$fl} = 2;
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
sub update_filelists {
    my ( $s, $conf ) = @_;

    # _dump_filelists("update_filelists", \@filelists);
    my $i = 0;
    foreach (@filelists) {
        next
            if ( exists $filelist_from_extension{$_}
            && $filelist_from_extension{$_} == 1 );
        my $fn   = ref($_) && $_->filename;
        my $name = ref($_) && $_->name;
        next if ( $name eq 'Default' or $name =~ /^CmdLine-\d+$/ );
        unless ( defined($fn) and length($fn) ) {
            saveStdFilelist($_);
        }
        else {
            $_->save;
            if ( !$filelist_from_extension{$_} )
            {    # note: this equals 2 for "StdFilelist" loaded from ~/.tred.d
                $s = $_->filename();
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
        map { [ $_, $_->name, lc( $_->name ) ] } @filelists;
    return unless @lists;
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
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
# was main::createCmdLineFilelists
sub create_filelists {
    my ($cmdline_filelists) = @_;
    print STDERR "Creating filelists...\n" if $tredDebug;

    {
        my $default_filelist = new Filelist('Default');
        $default_filelist->add(
            0,
            map {
                my ( $filename, $suffix )
                    = TrEd::Utils::parse_file_suffix($_);
                Treex::PML::IO::make_abs_URI($filename)->as_string . $suffix
                } @ARGV
        ) if @ARGV;
        add_new_filelist( undef, $default_filelist );
    }

    create_cmdline_filelists($cmdline_filelists);
    TrEd::Bookmarks::create_bookmarks_filelist();
    loadStdFilelists();
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
    my ($confs) = @_;
    my $fl;
    foreach ( sort { substr( $a, 8 ) <=> substr( $b, 8 ) }
        grep /^filelist[0-9]+/,
        keys %{$confs} )
    {
        print "Reading $_\n" if $tredDebug;
        $fl = Filelist->new( undef, $confs->{$_} );
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
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : selectFilelist()
sub selectFilelistNoUpdate {
    my ( $grp_or_win, $list_name, $no_reset_position ) = @_;

    # _dump_filelists("selectFilelistNoUpdate", \@filelists);
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    my $fl
        = $win->is_focused()
        ? TrEd::Dialog::Filelist::switch_filelist( $grp, $list_name )
        : find_filelist($list_name);
    print "Selecting filelist '$list_name' (found: $fl)\n" if $tredDebug;
    return if ( !defined($fl) );

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
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
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
            TrEd::File::closeFile($win);
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
    if ( $filelist_widget and $TrEd::Dialog::Filelist::current_filelist == $filelist ) {
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
        addFilelist($fl);
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
        if ( -d $_ )
        {
            $grp->{'hist-fileListPattern'} = []
                unless $grp->{'hist-fileListPattern'};
            $tmp = TrEd::Query::Simple::new_query(
                $toplevel,
                "Selection Pattern",
                "Insert pattern for directory $_",
                "*.*", 1, $grp->{'hist-fileListPattern'}
            );
            $_ = defined($tmp) ? File::Spec->catfile( $_, $tmp ) : undef;
        }
        $_;
    } @list;
    $position = TrEd::MinMax::min( $position + 1, $filelist->count() ) - 1;
    print "Inserting @list to position ", $position + 1, "\n" if $tredDebug;
    $filelist->add( $position + 1, @list );

    main::update_filelist_views( $grp, $filelist, 1 );
    if ( $filelist_widget and $TrEd::Dialog::Filelist::current_filelist == $filelist ) {
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
                my $file = filelistEntryPath( $filelist, $i );
                if ( $filelist_widget->info( 'exists', $file ) ) {
                    $filelist_widget->selectionSet($file);
                }
            }
        }
    }
    return $position + 1;
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
sub removeFilelistsDialog {
    my ($grp) = @_;

    # _dump_filelists("removeFilelistsDialog", \@filelists);
    my @lists = sort { $a->[1] cmp $b->[1] }
        grep {
        $_->[1] ne 'Default'
            and $_->[1] ne $TrEd::Bookmarks::FILELIST_NAME
            and ( $filelist_from_extension{ $_->[0] } || 0 )
            != 1
        }
        map { [ $_, $_->name, lc( $_->name ) ] } @filelists;
    return unless @lists;
    my $i         = 'A';
    my $selection = [ $i . '.  ' . $lists[0]->[1] ];
    my $indexes   = TrEd::Query::List::new_query(
        $grp->{top}, 'Remove File Lists',
        'extended', [ map { ( $i++ ) . '.  ' . $_->[1] } @lists ],
        $selection, { -label => 'Select one or more file lists', }
    ) || return;
    return
        unless (
        @$selection
        and TrEd::Query::User::new_query(
            $grp->{top},
            "Realy remove " . scalar(@$selection) . " file list(s)?\n",
            -bitmap  => 'question',
            -title   => "Remove file lists?",
            -buttons => [ 'Remove', 'Cancel' ]
        ) eq 'Remove'
        );
    deleteFilelist( $grp, map $_->[0], @lists[@$indexes] );
}

#######################################################################################
# Usage         : add_new_filelist(..)
# Purpose       : ...  
# Returns       : ..
# Parameters    : ..
# Throws        : ..
# Comments      : ..
# See Also      : .. 
# TODO: tests
# TODO: to je iny filelist ako je ten tredlib/Filelist.pm?
# was main::addNewFilelist
sub add_new_filelist {
  my ($grp, $fl, $top) = @_;
  # dump_filelists("add_new_filelist", \@filelists);
  return if not defined($fl) or $fl eq $EMPTY_STR;
  
  #TODO: nad tymto este podumaj dakus
  my ($l, $cont) = _solve_filelist_conflict($top, $fl);
  # osetri return $l 
  if($cont eq 'return') {
    return $l;
  }
  
  if ($l) {
      @{ $l->list_ref } = $fl->list();
      $l->filename($fl->filename()); # set filename
      $l->expand();
      if ($grp) {
        $TrEd::Dialog::Filelist::current_filelist = undef;
        TrEd::Dialog::Filelist::switch_filelist($grp, $l);
      }
      undef $fl;
      return $l;
  }
  if (not defined($fl->name()) or $fl->name() eq $EMPTY_STR) {
    undef $fl;
    return;
  }
  push @filelists, $fl;
  if ($grp) {
    TrEd::Dialog::Filelist::switch_filelist($grp,$fl);
    main::updatePostponed($grp);
  }
  return $fl;
}

sub deleteFilelist {
  my ($grp, @lists)=@_;
  # dump_filelists("deleteFilelist", \@filelists);
  @lists = grep {
    (ref($_) ? (($filelist_from_extension{$_}||0)!=1) : do { carp("deleteFilelist: $_ is not a filelist object!"); 0 })
    and $_->name !~ /^(Default|Bookmarks)$/
  } @lists;
  my %to_delete; 
  @to_delete{ @lists } = ();
  return unless @lists;
  print "Removing filelists ".join(",",map $_->name(), @lists)."\n" if $tredDebug;
  @filelists = grep { !exists($to_delete{$_}) } @filelists;
  for my $list (@lists) {
    if (($filelist_from_extension{$list} || 0) == 2) {
      my $fn = $list->filename();
      if ($fn) {
        print "Deleting filelist file $fn\n" if $tredDebug;
        unlink $fn;
      }
    }
  }
  if (defined $TrEd::Dialog::Filelist::current_filelist && exists($to_delete{$TrEd::Dialog::Filelist::current_filelist})) {
    $TrEd::Dialog::Filelist::current_filelist=undef;
    TrEd::Dialog::Filelist::switch_filelist($grp,'Default');
  }
  undef @lists;
  main::updatePostponed($grp);
  return;
}

1;

__END__

# pod comes here
