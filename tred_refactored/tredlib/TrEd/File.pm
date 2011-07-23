package TrEd::File;

use strict;
use warnings;

require TrEd::ManageFilelists;
use TrEd::Config qw{$ioBackends $lockFiles $reloadKeepsPatterns %save_types %backend_map $tredDebug};
use TrEd::MinMax qw{max2 first max};
use TrEd::Utils qw{applyFileSuffix uniq $EMPTY_STR};
use Treex::PML;
use TrEd::Error::Message;
use TrEd::FileLock;
use TrEd::RecentFiles;
use TrEd::Stylesheet;

require Filelist;

# it is not very good that TrEd::File loads this Tk and GUI stuff :/
# dialogs for asking for user choices, 
require TrEd::Query::List;
require TrEd::Query::User;


use Carp;
use Cwd;

our $dir_separator = q{/}; # default

if ($^O eq "MSWin32") {
    $dir_separator = "\\"; # how filenames and directories are separated
} 
else {
    $dir_separator = q{/};
}


# if extensions has not been dependent on this variable, we could have changed 'our' to 'my'
# (pmltq and pdt20 access @openfiles directly)
our @openfiles = ();

# the ordinal number of new file when it is opened (increases as files are opened)
my $new_file_no = 0;

use Exporter;

use base qw(Exporter);
BEGIN {
    our $VERSION = "0.2";
    # because of extensions
    our @EXPORT = qw(dirname
                    filename
                    );
    our @EXPORT_OK = qw(
                        closeFile
                        absolutize
                        absolutize_path
                        get_secondary_files
                        get_secondary_files_recursively
                        get_primary_files
                        get_primary_files_recursively
                        );
}

use Carp;
use vars qw( $VERSION @EXPORT @EXPORT_OK );

use Readonly;

Readonly my $ASK_SAVE_REF_LABEL => <<'EOF';
This document contains data obtained from external resources.
Please select which of them should be updated:
EOF


#load back-ends
my @backends = ();

#######################################################################################
# Usage         : init_backends($cmdline_backends)
# Purpose       : Initialize and import backends for reading various file types
# Returns       : Undef/empty list
# Parameters    : scalar $cmdline_backends -- string of comma separated backend names
# Throws        : No exception
# Comments      : Relies on Treex::PML::ImportBackends function
# See Also      : add_backend(), remove_backend(), get_backends()
sub init_backends {
    my ($cmdline_backends) = @_;
    @backends = (
        'FS',
        Treex::PML::ImportBackends(
            defined $TrEd::Config::ioBackends 
                ? split( /,/, $TrEd::Config::ioBackends) 
                : (),
            defined $cmdline_backends 
                ? split( /,/, $cmdline_backends) 
                : (),
            qw{NTRED
                Storable
                PML
                CSTS
                TrXML
                TEIXML
                PMLTransform
                }
        )
    );
    return;
}


#######################################################################################
# Usage         : get_backends()
# Purpose       : Return loaded backends for opening files
# Returns       : List of strings -- loaded backend names
# Parameters    : no
# Throws        : No exception
# Comments      : 
# See Also      : add_backend(), remove_backend()
sub get_backends {
    return @backends;
}


#######################################################################################
# Usage         : _insert_if_before_exists($class, $before, $found_ref, $backend)
# Purpose       : Add $class to list of returned backends if backend $before was found,
#                 otherwise return only $before
# Returns       : A list containing one or two elements. If $before is equal to $backend
#                 (or $backend . 'Backend'), function returns two elements -- $class and 
#                 $backend. Otherwise only $backend is returned.
# Parameters    : scalar $class  -- Name of the first backend
#                 scalar $before -- Name of the backend, before whom the $class is inserted
#                 scalar_ref $found_ref -- Reference to indicator telling if $before was found
#                 scalar $backend -- Name of the current backend
# Throws        : No exception
# Comments      : As a side effect, $found_ref is set to 1 if $backend equals to $before. 
#                 If $found_ref is set to 1, the $class is not prepended any more.
# See Also      : add_backend()
sub _insert_if_before_exists {
    my ($class, $before, $found_ref, $backend) = @_;
    if (!${$found_ref} && ($backend eq $before)
        || ($backend . 'Backend' eq $before) ) {
        ${$found_ref} = 1;
        return ($class, $backend);
    }
    else { 
        return ($backend); 
    }
}

#######################################################################################
# Usage         : add_backend($class, $before)
# Purpose       : Add backend $class to the list of loaded backends. If $before is specified
#                 and loaded, $class backend is inserted before $before backend.
# Returns       : Undef/empty list
# Parameters    : scalar $class -- Name of the added backend
#                 scalar $before -- Name of the backend before which the $class backend is added
# Throws        : Carp if $before is specified but not found in the list of loaded backends
#                 Side note: this function does not call Treex::PML::ImportBackends, so it can 
#                 add backend that does not actually exist.
# See Also      : remove_backend(), get_backends()
sub add_backend {
    my ($class, $before) = @_;
    if (defined $before) {
        my $found;
        #TODO: try to use splice instead?
        @backends = map {
            _insert_if_before_exists($class, $before, \$found, $_);
        } @backends;
        if (!$found) {
            carp("TrEd::File::add_backend('$class', '$before'): backend '$before' not found, appending");
            push @backends, $class;
        }
    }
    else {
        push @backends, $class;
    }
    return;
}

#######################################################################################
# Usage         : remove_backend($class)
# Purpose       : Remove all the backends with name $class
# Returns       : The list of backends without the $class backends
# Parameters    : scalar $class -- name of backend that will be removed
# Throws        : No exception
# See Also      : add_backend(), get_backends()
sub remove_backend {
    my $class = shift;
    @backends = grep { $_ ne $class } @backends;
    return @backends;
}


#######################################################################################
# Usage         : get_openfiles()
# Purpose       : Return a list of TrEd's opened files (data files)
# Returns       : A list of opened files
# Parameters    : no
# Throws        : No exception
sub get_openfiles {
    return @openfiles;
}

#######################################################################################
# Usage         : _merge_status($status1_ref, $status2_ref)
# Purpose       : Merge two statuses into the first one
# Returns       : Undef/empty list
# Parameters    : hash_ref $status1_ref -- reference to first hash containing status information
#                 hash_ref $status2_ref -- reference to second hash containing status information
# Throws        : No exception
# Comments      : Status information hash should contain these keys: 
#                   ok       -- numeric value
#                   warnings -- reference to array of warnings
#                   error    -- string 
#                   report   -- string
#                 Merging means that 'ok' value will be constructed by logical and from the two 
#                 statuses, second 'warnings' arrays will be appended after the first one and 
#                 string items will be concatenated (if not empty)
# See Also      : _new_status()
sub _merge_status {
    my ( $status1_ref, $status2_ref ) = @_;
    # similar to &&, except for n1, n1 (not 1)
    # s1 |  s2 | merged (s1)
    #-------------------------
    #  1  | n1  |   n1
    #  1  |  1  |   1
    # n1  |  1  |   n1
    # n1  | n1  |   max(s1,s2)
    if ( $status1_ref->{ok} == 1 ) {
        $status1_ref->{ok} = $status2_ref->{ok};
    }
    elsif ( $status2_ref->{ok} != 1 ) {
        $status1_ref->{ok} = TrEd::MinMax::max2( $status2_ref->{ok}, $status1_ref->{ok} );
    }
    # merge warnings
    push @{ $status1_ref->{warnings} }, @{ $status2_ref->{warnings} };
    # merge errors
    if (defined $status2_ref->{error} && $status2_ref->{error} ne $EMPTY_STR) {
        $status1_ref->{error} .= "\n" . $status2_ref->{error};
    }
    # merge reports
    if (defined $status2_ref->{report} && $status2_ref->{report} ne $EMPTY_STR) {
        $status1_ref->{report} .= "\n" . $status2_ref->{report};
    }
    return;
}

#######################################################################################
# Usage         : _new_status( ok => 0, error => 'File not found' )
# Purpose       : Create a hash reference containing status information about a file operation
# Returns       : Reference to hash which contains status information
# Parameters    : List of status information pairs
# Throws        : No exception
# Comments      : The hash items for status hash are following:
#                   ok, cancel, warnings, error, filename, backends, report
#                 Other (custom) hash items can be passed as parameters
# See Also      : _merge_status()
sub _new_status {
    my %status = (
        ok       => undef,
        cancel   => undef,
        warnings => [],
        error    => undef,
        filename => undef,
        backends => undef,
        report   => undef,
        @_
    );
    return \%status;
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
#TODO: test?
sub reload_on_usr2 {
    my ( $grp, $file_name ) = @_;
    my ($fsfile) = grep {
        Treex::PML::IO::is_same_filename( $_->filename(), $file_name )
    } @openfiles;
    if ($fsfile) {
        if ( $grp->{focusedWindow}->{FSFile} != $fsfile ) {
            my ($win) = main::fsfileDisplayingWindows( $grp, $fsfile );
            if ($win) {
                main::focusCanvas( $win->canvas(), $grp );
            }
            else {
                openStandaloneFile( $grp, $fsfile->filename(), -keep => 1 );
            }
        }
        reloadFile($grp);
    }
    return;
}


#######################################################################################
# Usage         : _related_files($fsfile)
# Purpose       : Find all related files of $fsfile
# Returns       : List of Treex::PML::Document objects which represent related documents
# Parameters    : Treex::PML::Document ref $fsfile -- ref to file whose related files are searched for
# Throws        : No exception
# Comments      : 
# See Also      : get_secondary_files(), get_primary_files()
sub _related_files {
    my ($fsfile) = @_;
    return get_secondary_files($fsfile), 
            # these are relatedSuperDocuments:
            get_primary_files($fsfile); 
}

#######################################################################################
# Usage         : _fix_keep_option($fsfile, $file_name, $opts_ref)
# Purpose       : If $filename is related to $fsfile file and "-keep_related" option is true,
#                 set also the "-keep" option to true
# Returns       : Undef/empty list
# Parameters    : Treex::PML::Document ref $fsfile -- ref to file whose related files are examined
#                 scalar $file_name  -- name of file that is searched among related files of $fsfile
#                 hash_ref $opts_ref -- ref to hash of options
# Throws        : No exception
# See Also      : _related_files()
sub _fix_keep_option {
    my ($fsfile, $file_name, $opts_ref) = @_;
    if ( !$opts_ref->{-keep} && $opts_ref->{-keep_related} ) {
        if ( $TrEd::Config::tredDebug && $fsfile ) {
            print STDERR "got -keep_related flag for open $file_name:\n";
            print STDERR map { $_->filename() . "\n" } _related_files($fsfile);
        }
        if ($fsfile 
            && first { $_->filename() eq $file_name } _related_files($fsfile)) {
                $opts_ref->{-keep} = 1;
                if ($TrEd::Config::tredDebug) {
                    print STDERR "keep: $opts_ref->{-keep}\n";
                }
        }
    }
    return;
}


#######################################################################################
# Usage         : _is_among_primary_files($fsfile, $file_name)
# Purpose       : Test whether $file_name is among $fsfile's primary files
# Returns       : First $fsfile's primary file whose name equals to $file_name or undef otherwise
# Parameters    : Treex::PML::Document ref $fsfile -- ref to file whose primary files are examined
#                 scalar $file_name  -- name of file that is searched among primary files of $fsfile
# Throws        : No exception
# Comments      : Searches for primary files recursively
# See Also      : get_primary_files_recursively()
sub _is_among_primary_files {
    my ($file_name, $fsfile) = @_;
    if (!defined $fsfile) {
        return;
    } 
    return TrEd::MinMax::first {
            Treex::PML::IO::is_same_filename( $_->filename(), $file_name );
            }
            get_primary_files_recursively($fsfile)
}

# zislo by sa premenovat, lebo to aj otvara subor, nie len checkuje recovery
sub _check_for_recovery {
    my ($file_name, $grp, $win, $fsfile, $lockinfo, $opts_ref) = @_;
    
    # $grp->{noOpenFileError} can be set by TrEd::Filelist::Navigation::next_or_prev_file, 
    # but I'm not sure what is it good for.. something with autosaving...?
    my $no_err = $grp->{noOpenFileError};  
    
    my $recover  = 'No';
    my $autosave = main::autosave_filename($file_name);
    if ( !$no_err && defined $autosave && -r $autosave ) {
        $recover = TrEd::Query::User::new_query(
            $win,
            "File seems to have an auto-saved recovery file from a previous session.\n"
                . "Shell I try to use the recovery file?",
            -bitmap  => 'question',
            -title   => "Recover file?",
            -buttons => [ 'Yes', 'No', 'No, delete recovery file' ]
        );
    }

    my $backends = main::doEvalHook( $win, 'get_backends_hook', @backends );

    # Autosave file requested
    my $status = { ok => 0 };

    if ( $recover eq 'Yes' ) {

        # Open recovery file
        #TODO: ci to nevadi, ked tu sa dosadzuje nove fsfile
        ( $fsfile, $status ) = load_file( $grp, $autosave, $backends );
        if (ref($fsfile)) {
            init_app_data($fsfile);
        }
        if ( $status->{ok} ) {

            # Success
            $fsfile->changeFilename($file_name);
            $fsfile->notSaved(2);
            if ($TrEd::Config::lockFiles) {
                TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo );
            }
            if ( $status->{ok} < 0 ) {
                TrEd::Error::Message::error_message( $win, $status->{report}, 'warn' );
            }
        }
        else {

            # Recovery failed
            my $trees = $fsfile ? $fsfile->lastTreeNo() + 1 : 0;
            my $answer = $win->toplevel->ErrorReport(
                -title   => "Error: recovery failed",
                -message => "Recovery file is corrupted ($trees trees read)!"
                          . "\nPossible problem was:",
                -body    => $status->{report},
                -buttons => [ 'Open the original file', 'Ignore', 'Cancel' ],
            );
            if ( $answer eq 'Open the original file' ) {
                if (!$opts_ref->{-preload}) {
                    closeFile( $win, -no_update => 1 );
                }

                ( $fsfile, $status ) = load_file( $grp, $file_name, $backends );
                if (ref($fsfile)) {
                    init_app_data($fsfile);
                }
                if ($TrEd::Config::lockFiles) {
                    TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo );
                }
            }
            elsif ( $answer eq 'Ignore' ) {
                if ( !$opts_ref->{-preload} && !$opts_ref->{-noredraw} ) {
                    $win->redraw();
                }
                if (!$main::insideEval) {
                    $win->toplevel->Unbusy();
                }
                return
                    wantarray ? ( undef, _new_status( cancel => 1 ) ) : undef;
            }
            else {
                if (!$opts_ref->{-preload} && $fsfile->lastTreeNo < 0) {
                    closeFile( $win, -no_update => 1 );
                }
                $no_err = 1;
            }
        }
    }
    else {
        if ( $recover eq 'No, delete recovery file' ) {
            unlink $autosave;
        }

        # Open requeseted file

        ( $fsfile, $status ) = load_file( $grp, $file_name, $backends );
        init_app_data($fsfile) if ref $fsfile;
        TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo )
            if $TrEd::Config::lockFiles;
    }

    if ( $status->{ok} ) {
        $fsfile->changeFileFormat(
            ( $file_name =~ /\.gz$/ ? "gz-compressed " : $EMPTY_STR ) . $fsfile->backend() );
        if (!$main::no_secondary) {
            $status = openSecondaryFiles( $win, $fsfile, $status )
                or undef $fsfile;
        }
    }
    
    # don't make this an else for the above if: something might have changed in
   # the above block
    if ( $status->{ok} == 0 ) {
        unless ($no_err) {
            my $trees = $fsfile ? $fsfile->lastTreeNo + 1 : 0;
            $win->toplevel->ErrorReport(
                -title => "Error: open failed",
                -message =>
                    "File '$file_name' is unreadable, empty, corrupted, or does not exist ($trees trees read)!"
                    . "\nPossible problem was:",
                -body => $status->{report},
            );
        }
        closeFile( $win, -no_update => 1 ) unless $opts_ref->{-preload};
        TrEd::FileLock::remove_lock( undef, $file_name )
            if $lockinfo and $lockinfo !~ /^locked/;
    }
    elsif ( $status->{ok} < 1 ) {
        error_message( $win, $status->{report}, 'warn' );
    }
    
    return ($fsfile, $status);
}

sub _should_save_to_recent_files {
    my ($fsfile, $opts_ref) = @_;
    return (! ($opts_ref->{-norecent} 
                || $fsfile && $fsfile->appData('norecent')
               )
            );        
}

#######################################################################################
# Usage         : open_file($grp_or_win, $file_name, %options)
# Purpose       : Open file...
# Returns       : Status hash reference
# Parameters    : hash_ref $grp_or_win -- reference to hash containing TrEd options or TrEd::Windows
#                 string $file_name    -- name of the file to open
#                 hash %options        -- hash of options 
# Throws        : No exception
# Comments      : Recognized options: 
#                   -nohook       -- 1/0 -- switch to forbid hooks: open_file_hook, guess_context_hook,
#                                           file_resumed_hook, file_resumed_hook
#                   -keep         -- 1/0 -- keep file in memory until they are explicitly closed
#                   -keep-related -- 1/0 -- keep related files in memory until they are explicitly closed
#                   -preload      -- 1/0 --
#                   -noredraw     -- 1/0 -- forbid redrawing after open
#                   -norecent     -- 1/0 -- don't add opened file into recent files list
#                   -justheader   -- 1/0 -- don't update canvas, don't create lockfile,  
#                 Hooks run: open_file_hook, possibly also guess_context_hook, file_opened_hook
#                 (only in this function, other functions called from this function can trigger 
#                  other hooks)
# See Also      : 
sub open_file {
    my ( $grp_or_win, $raw_file_name, %opts ) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    if (!$opts{-nohook}) {
        # extension can take over our open file subroutine
        my $open_file_hook_res = main::doEvalHook( $win, "open_file_hook", 
                                                   $raw_file_name, {%opts} ); 
        if ( defined $open_file_hook_res && $open_file_hook_res eq 'stop' ) {
            # not sure what status we should return
            return
                wantarray
                ? ( $win->{FSFile}, _new_status( ok => 1 ) )
                : $win->{FSFile};
        }
    }
    
    my $fsfile = $win->{FSFile};

    my ( $file_name, $suffix ) = TrEd::Utils::parse_file_suffix($raw_file_name);
    print "Goto suffix is $suffix\n" if defined($suffix) && $TrEd::Config::tredDebug;

    $opts{-keep} ||= $grp->{keepfiles};
    _fix_keep_option($fsfile, $file_name, \%opts);
    
    if (!$main::insideEval) {
        $win->toplevel->Busy( -recurse => 1 );
    }

    # File already open in current window? Simple!
    if ( defined $fsfile
        && Treex::PML::IO::is_same_filename( $fsfile->filename(), $file_name ) )
    {
        if ( !$opts{-preload} ) {
            main::update_title_and_buttons($grp);
            # set current tree and node for $win Window
            TrEd::Utils::applyFileSuffix( $win, $suffix );
            main::unhide_current_node($win);
            $win->get_nodes( $opts{-noredraw} );
            if ( !$opts{-nohook} ) {
                main::doEvalHook( $win, "guess_context_hook", "file_resumed_hook" );
                main::doEvalHook( $win, "file_resumed_hook" );
            }
            if ( !$opts{-noredraw} ) {
                $win->redraw();
                main::centerTo( $win, $win->{currentNode} );
            }
            if ( !$opts{-norecent} && !$fsfile->appData('norecent') ) {
                TrEd::RecentFiles::add_file( $grp, $file_name );
            }
        }
        if (!$main::insideEval) {
            $win->toplevel->Unbusy();
        }
        return wantarray ? ( $fsfile, _new_status( ok => 1 ) ) : $fsfile;
    }

    # the current file would get open again as a secondary file to $file_name
    if (_is_among_primary_files($file_name, $fsfile)) {
        $opts{-keep} = 1;
    }

    # Shell we close current file?
    if ( !$opts{-preload} && !$opts{-keep} ) {
        if ( main::fsfileDisplayingWindows( $grp, $fsfile ) < 2 ) {
            my $answer = ask_save_file( $win, 1, 1 );
            if ( $answer == -1 ) {
                $win->toplevel->Unbusy() unless $main::insideEval;
                return
                    wantarray ? ( undef, _new_status( cancel => 1 ) ) : undef;
            }
            $opts{-keep} = $answer;
        }
    }
    
    if (!$opts{-preload}) {
        my $keep_postponed = $opts{-keep} 
                            || ( defined $fsfile && $fsfile->appData('noautoclose')); 
        closeFile($win, -no_update      => 1,
                        -keep_postponed => $keep_postponed);
    }

    # Search open files for requested file, resume if available
    if ( !$opts{-justheader} ) {
        foreach my $opened_file ( $fsfile, @openfiles ) {
            if ( ref $opened_file
                && Treex::PML::IO::is_same_filename( $opened_file->filename(), $file_name ) )
            {
                if ($TrEd::Config::tredDebug) {
                    print "Opening postponed file\n";
                }
                if ( !$opts{-preload} ) {
                    resume_file( $win, $opened_file, $opts{-keep} );
                    main::update_title_and_buttons($grp);
                    TrEd::Utils::applyFileSuffix( $win, $suffix );
                    main::unhide_current_node($win);
                    $win->get_nodes( $opts{-noredraw} );
                    if ( !$opts{-nohook} ) {
                        main::doEvalHook( $win, "guess_context_hook",
                            "file_resumed_hook" );
                        main::doEvalHook( $win, "file_resumed_hook" );
                    }
                    if ( !$opts{-noredraw} ) {
                        $win->redraw();
                        main::centerTo( $win, $win->{currentNode} );
                    }
                    if ( _should_save_to_recent_files($fsfile, \%opts)) {
                        TrEd::RecentFiles::add_file( $grp, $file_name );
                    }
                }
                if (!$main::insideEval) {
                    $win->toplevel->Unbusy();
                }
                return wantarray ? ( $opened_file, _new_status( ok => 1 ) ) : $opened_file;
            }
        }
    }

    # We're going to open a file: check locks
    my $lockinfo;
    if ( !$opts{-justheader} ) {
        $lockinfo = TrEd::FileLock::lock_file( $win, $file_name, \%opts );
        if ( defined $lockinfo && $lockinfo eq 'Cancel' ) {
            return wantarray ? ( undef, _new_status( cancel => 1 ) ) : undef;
        }
    }

    # Check autosave file (also loads file & secondary files files or sth...)
    my $status;
    ($fsfile, $status) = _check_for_recovery($file_name, $grp, $win, $fsfile, $lockinfo, \%opts);
    
    if (!$opts{-preload}) {
        $win->set_current_file( $fsfile ) ; # window->set_file?
    }
    
    if ($fsfile) {
        if ( $opts{-justheader} ) {
            $file_name = sprintf( '%03d', $new_file_no++ ) . "_new_" . filename($file_name);
            $fsfile->changeFilename($file_name);
            $fsfile->changeTrees();

            #      $fsfile->new_tree(0);
            $fsfile->notSaved(1);
        }
        push @openfiles, $fsfile;
    }
    main::updatePostponed($grp);

    if (!$opts{-preload}) {
        main::update_title_and_buttons($grp);
    }

    my $save_current;
    if ( !$opts{-preload} ) {
        TrEd::Utils::applyFileSuffix( $win, $suffix );
        $save_current = $win->{currentNode};
        main::unhide_current_node($win);
        $win->get_nodes(1); # for the hook below
    }
    # if redraw is called during the hook, we will know it
    my $r = $win->{redrawn};
    if ( $opts{-preload} ) {
        if ( $fsfile && !$opts{-nohook} ) {
            main::doEvalHook( $win, "guess_context_hook", "file_opened_hook" ); # wont work until grp's fsfile is set
            main::doEvalHook( $win, "file_opened_hook" );
        }
    }
    else {
        if ( defined $main::init_macro_context   
             && $main::init_macro_context ne $EMPTY_STR
             && $win->{macroContext} ne $main::init_macro_context )
        {
            main::switchContext( $win, $main::init_macro_context, 1 );
        }
        else {
            if ( $fsfile && !$opts{-nohook} ) {
                main::doEvalHook( $win, "guess_context_hook", "file_opened_hook" );
            }
        }
        if ( $fsfile && !$opts{-nohook} ) {
            main::doEvalHook( $win, "file_opened_hook" );
        }
        if ( !$opts{-noredraw} ) {
            if ( !defined $win->{redrawn} || $win->{redrawn} <= $r ) { # not already redrawn by some hook
                if ($save_current) {
                    $win->{currentNode} = $save_current;
                }
                $win->get_nodes();    # the hook may have changed something
                $win->redraw();
            }
            main::centerTo( $win, $win->{currentNode} );
        }
    }
    if (!$main::insideEval) {
        $win->toplevel->Unbusy();
    }

    if (_should_save_to_recent_files($fsfile, \%opts)) {
        TrEd::RecentFiles::add_file( $grp, $file_name )
    }
    return wantarray ? ( $fsfile, $status ) : $fsfile;
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
# openStandaloneFile should be called whenever a file is opened via
# a non-filelist operation (that is other than next_file, or go_to_file)
# file
sub openStandaloneFile {
    my ( $grp_or_win, $file ) = @_;
    my ( $grp,        $win )  = main::grp_win($grp_or_win);
    if ( $grp->{appenddefault} ) {
        my $ret = open_file(@_);
        if ($ret) {
            my $fl = TrEd::ManageFilelists::selectFilelistNoUpdate( $grp,
                'Default', 1 );
            my $pos
                = TrEd::ManageFilelists::insertToFilelist( $win,
                $win->{currentFilelist},
                $win->{currentFileNo}, $file );
            $win->{currentFileNo} = $pos if $pos >= 0;
            main::update_filelist_views( $grp, $win->{currentFilelist}, 0 );
        }
        main::update_title_and_buttons($grp);
        return $ret;
    }
    else {
        my $ret = open_file(@_);
        undef $win->{currentFilelist};
        $win->{currentFileNo} = -1;
        main::update_title_and_buttons($grp);
        return $ret;
    }
}

#######################################################################################
# Usage         : closeFile($win, %opts)
# Purpose       : 
# Returns       : Undef/empty list if no file was closed (either because there is no file to 
#                 close, or the user cancelled the operation)
#                 1 if the file was closed successfully
# Parameters    : ... 
# Throws        : No exception
# Comments      : 
# See Also      : 
sub closeFile {
    my ( $win, %opts ) = @_;

    my $fsfile;
    if ( $opts{-fsfile} ) {
        $fsfile = $opts{-fsfile};
    }
    else {
        $fsfile = $win->{FSFile};
    }
    if ($fsfile) {
        main::__debug( "Closing ", $fsfile->filename(),
            "; keep postponed: " 
            . defined $opts{-keep_postponed} ? $opts{-keep_postponed} : 'no' 
            . "\n" );
        main::doEvalHook( $win, "file_close_hook", $fsfile, \%opts );
        $fsfile->currentTreeNo( $win->{treeNo} );
        $fsfile->currentNode( $win->{currentNode} );
    }
    else {
        return;
    }
    my $fn = $fsfile->filename;
    if ( !$opts{-keep_postponed} ) {
        if ( main::filePartOfADisplayedFile( $win->{framegroup}, $fsfile ) ) {
            warn "closeFile: Keeping postponed "
                . $fsfile->filename
                . " - part of a displayed file\n";
            $opts{-keep_postponed} = 1;
        }
        else {
            my @part_of = main::findToplevelFileFor( $win->{framegroup}, $fsfile );
            if ( $part_of[0] != $fsfile ) {
                return unless ask_save_file( $win, 0, 1, $fsfile ) == 0;
                for (@part_of) {
                    closeFile(
                        $win, %opts,
                        -fsfile         => $_,
                        -keep_postponed => 0
                    ) || return;
                }
            }
        }
    }
    my @wins;
    my ( $last_context, $last_stylesheet )
        = ( $win->{macroContext}, $win->{stylesheet} );
    if ( $opts{-all_windows} and $fsfile ) {
        @wins = main::fsfileDisplayingWindows( $win->{framegroup}, $fsfile );
    }
    elsif ( !$opts{-fsfile} ) {
        @wins = ($win);
    }

    foreach my $w (@wins) {
        $w->{Nodes} = undef;

        #  undef $NodeClipboard;
        $w->{root}       = undef;
        $w->{stylesheet} = TrEd::Stylesheet::STYLESHEET_FROM_FILE();
        $w->set_current_file( undef );
        delete $w->{currentNode} if ( exists $w->{currentNode} );
        $w->{treeView}->clear_pinfo();
        if ( $w->is_focused() ) {
            # povodny vyznam
#            my $rtl = $w->{framegroup}->{focusedWindow}->treeView()->rightToLeft($w->{framegroup}->{focusedWindow}->{FSFile});
            my $rtl = $w->treeView()->rightToLeft($w->{FSFile});
            $w->{framegroup}->{valueLine}->set_value($rtl, $EMPTY_STR);
#            TrEd::ValueLine::set_value( $w->{framegroup}, $EMPTY_STR );
        }
        unless ( $opts{-no_update} ) {
            $w->get_nodes();
            $w->redraw();
        }
    }

    unless ( $opts{-no_update} ) {
        main::update_title_and_buttons( $win->{framegroup} );
        main::updatePostponed( $win->{framegroup} );
    }

    if ( $opts{-keep_postponed} and $fsfile ) {
        print STDERR "Postponing " . $fsfile->filename() . "\n"
            if $TrEd::Config::tredDebug;
        $fsfile->changeAppData( 'last-context',    $last_context );
        $fsfile->changeAppData( 'last-stylesheet', $last_stylesheet );
    }
    else {
        if ( $fsfile
            && !main::fsfileDisplayingWindows( $win->{framegroup}, $fsfile ) )
        {
            my $f = $fsfile->filename();
            print STDERR "Removing $f from list of open files\n"
                if $TrEd::Config::tredDebug;
            @openfiles = grep { $_ ne $fsfile } @openfiles;
            TrEd::RecentFiles::add_file( $win->{framegroup}, $f )
                unless $opts{-norecent}
                    or $fsfile->appData('norecent');
            my $autosave = main::autosave_filename($f);
            unlink $autosave if defined $autosave;
            TrEd::FileLock::remove_lock( $fsfile, $f );

            # remove dependency
            for my $req_fs ( get_secondary_files($fsfile) ) {
                if ( ref $req_fs->appData('fs-part-of') ) {
                    @{ $req_fs->appData('fs-part-of') }
                        = grep { $_ != $fsfile }
                        @{ $req_fs->appData('fs-part-of') };
                }
                unless (
                    main::fsfileDisplayingWindows( $win->{framegroup}, $req_fs ) )
                {
                    print STDERR "Attempting to close dependent "
                        . $req_fs->filename . "\n"
                        if $TrEd::Config::tredDebug;
                    my $answer = ask_save_file( $win, 1, 1, $req_fs );
                    return if $answer == -1;
                    if ( $answer == 1 ) {
                        print STDERR "Keeping dependent "
                            . $req_fs->filename . "\n"
                            if $TrEd::Config::tredDebug;
                    }
                    else {
                        closeFile(
                            $win, %opts,
                            -fsfile         => $req_fs,
                            -keep_postponed => 0
                        ) || return;
                    }
                }
            }
            undef $fsfile;
        }
    }
    return 1;
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub reloadFile {
    my ($grp_or_win) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    my $fsfile = $win->{FSFile};
    if ( ref($fsfile) and $fsfile->filename() ) {
        my $f        = $fsfile->filename();
        my @patterns = $fsfile->patterns();
        my $hint     = $fsfile->hint();
        ($f) = TrEd::Utils::parse_file_suffix($f);
        if ( $fsfile->lastTreeNo >= 0 ) {
            my $no      = $win->{treeNo} + 1;
            my $nodeidx = 0;
            do {    # $node is undefined after this block
                my $node = $win->{currentNode};
                while ($node) { $nodeidx++; $node = $node->previous() }
            };
            $nodeidx-- if $nodeidx >= 0;
            $f = "$f##$no.$nodeidx";
        }
        return if ask_save_file( $win, 0, 1 ) == -1;
        my $ctxt = $grp->{selectedContext};
        closeFile( $win, -all_windows => 1 );
        open_file( $win, $f, -noredraw => 1, -nohook => 1 );
        if ( $ctxt ne $grp->{selectedContext} ) {
            main::switchContext( $win, $ctxt, 1 );
        }
        $fsfile = $win->{FSFile};
        if ($fsfile) {
            if ($TrEd::Config::reloadKeepsPatterns) {
                $fsfile->changePatterns(@patterns);
                $fsfile->changeHint($hint);
            }
            main::doEvalHook( $win, "file_reloaded_hook" );
        }
        $win->get_nodes();
        $win->redraw();
        main::centerTo( $win, $win->{currentNode} );
    }
}

#######################################################################################
# Usage         : load_file($grp, $file_name, $backends)
# Purpose       : Create Treex::PML::Document object representing file $file_name 
# Returns       : In scalar context reference to created Treex::PML::Document is returned.
#                 In list context, a list with two elements is returned. First element is 
#                 reference to created Treex::PML::Documet, second one is status
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to open and load
#                 array_ref $backends -- reference to array of backends to use for loading file (optional)
# Throws        : No exception
# Comments      : For details about status hash_ref see doc for _new_status() function
# See Also      : Treex::PML::Document, _new_status()
# was main::loadFile
sub load_file {
    my ( $grp, $file_name, $backends ) = @_;
    $grp = main::cast_to_grp($grp);
    my @warnings;
    my $bck = ref $backends ? $backends : \@backends;
    my $status = _new_status(
        ok       => 0,
        filename => $file_name,
        backends => $bck,
        warnings => \@warnings
    );
    main::_clear_err();
    local $SIG{__WARN__} = sub {
        my $msg = shift;
        chomp $msg;
        print STDERR $msg . "\n";
        push @warnings, $msg;
    };
    my $fsfile = Treex::PML::Factory->createDocumentFromFile(
        $file_name,
        {   encoding => $TrEd::Convert::inputenc,
            backends => $bck,
            recover  => 1,
        }
    );
    my $error = $Treex::PML::FSError;
    $status->{error} = $error == 1 ? 'No suitable backend!' : main::_last_err();
    $status->{report} = "Loading file '$file_name':\n\n";

    if ( ref $fsfile && $fsfile->lastTreeNo >= 0 && $error == 0 ) {
        $status->{ok} = @warnings ? -1 : 1;
    }
    else {
        if ( ref $fsfile && $error == 0 ) {
            push @warnings, "NO TREES FOUND in this file.";
            $status->{ok} = -1;
        }
        else {
            $status->{ok} = 0;
            $status->{report} .= "ERRORS:\n\n" . $status->{error} . "\n";
        }
    }
    if (@warnings) {
        $status->{report} .= join "\n", "WARNINGS:\n", @warnings;
    }

    $grp->{lastOpenError} = $status->{report};

    if (wantarray) {
        return ($fsfile, $status);
    }
    else {
        return $fsfile;
    }
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub openSecondaryFiles {
    my ( $win, $fsfile, $status ) = @_;

    # if backend requested another FS-file, load it
    # and store it in appData('ref') hash table
    #
    # mark this secondary FS-file as part of the original file
    # so that they can be closed together
    $status ||= _new_status( ok => 1 );
    return $status if $fsfile->appData('fs-require-loaded');
    $fsfile->changeAppData( 'fs-require-loaded', 1 );
    my $requires = $fsfile->metaData('fs-require'); #$fsfile->relatedDocuments()
    if (defined $requires) {
        for my $req (@$requires) {
            next if ref( $fsfile->appData('ref')->{ $req->[0] } );
            my $req_filename
                = absolutize_path( $fsfile->filename, $req->[1] );
            print STDERR
                "Pre-loading dependent $req_filename ($req->[1]) as appData('ref')->{$req->[0]}\n"
                if $TrEd::Config::tredDebug;
            my ( $req_fs, $status2 ) = open_file(
                $win, $req_filename,
                -preload  => 1,
                -norecent => 1
            );
            _merge_status( $status, $status2 );
            if ( !$status2->{ok} ) {
                closeFile( $win, -fsfile => $req_fs, -no_update => 1 );
                return $status2;
            }
            else { #zaznac do zavisleho, ze je zavisly na nadradenom
                push @{ $req_fs->appData('fs-part-of') },
                    $fsfile;    # is this a good idea?
                main::__debug("Setting appData('ref')->{$req->[0]} to $req_fs");
                $fsfile->appData('ref')->{ $req->[0] } = $req_fs;
            }
        }
    }
    return $status;
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub closeAllFiles {
    my ($grp) = @_;

    @{ $grp->{treeWindows} }
        = grep { $_ ne $grp->{focusedWindow} } @{ $grp->{treeWindows} };
    unshift @{ $grp->{treeWindows} }, $grp->{focusedWindow};
    my $win;
    foreach $win ( @{ $grp->{treeWindows} } ) {
        if ( $win->{FSFile} ) {
            closeFile( $win, -no_update => 1, -all_windows => 1 );
        }
    }
    while (@openfiles) {
        my $fsfile = $openfiles[0];

        # to avoid infinite loop, first try closing all files this one is
        # part of
        if ( $fsfile and ref( $fsfile->appData('fs-part-of') ) ) {
            foreach ( @{ $fsfile->appData('fs-part-of') } ) {
                main::__debug( "Closing all parts of " . $fsfile->filename );
                closeFile(
                    $grp->{focusedWindow},
                    -fsfile      => $_,
                    -no_update   => 1,
                    -all_windows => 1
                );
            }
        }
        main::__debug( "Now closing file " . $fsfile->filename );
        closeFile(
            $grp->{focusedWindow},
            -fsfile      => $fsfile,
            -no_update   => 1,
            -all_windows => 1
        );
        if ( grep { $_ == $fsfile } @openfiles ) {

            # still there?
            main::__debug( "File still open, pushing it to the end: $fsfile: "
                    . $fsfile->filename );
            shift @openfiles;
            push @openfiles, $fsfile;
            main::__debug("Open files: @openfiles");
        }
    }
}


#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub saveFile {
    my ( $win, $f ) = @_;
    $win = main::cast_to_win($win);
    my $fsfile;
    if ( UNIVERSAL::DOES::does( $f, 'Treex::PML::Document' ) ) {
        $fsfile = $f;
        $f      = $f->filename;
    }
    else {
        $fsfile = $win->{FSFile};
    }
    return unless $fsfile;
    unless ( defined($f) ) {
        $f = $fsfile->filename;
        if ( $f =~ /^unnamed\d+$/ ) {
            my $ret = saveFileAs($win);
            if ($ret) {

                # now we may add the file to the current filelist?
                $win->{currentFileNo} = TrEd::MinMax::max2( 0, $win->{currentFileNo} );
                my $pos
                    = TrEd::ManageFilelists::insertToFilelist( $win,
                    $win->{currentFilelist},
                    $win->{currentFileNo}, $fsfile->filename );
                $win->{currentFileNo} = $pos if $pos >= 0;
                main::update_filelist_views( $win, $win->{currentFilelist}, 0 );
            }
            return $ret;
        }
    }

    my $lock = TrEd::FileLock::check_lock( $fsfile, $f );
    if ( $lock =~ /^locked|^stolen|^opened/ ) {
        if (TrEd::Query::User::new_query(
                $win,
                "File $f was $lock!",
                -bitmap  => 'question',
                -title   => "Saving locked file?",
                -buttons => [ 'Steal lock and save', 'Cancel' ]
            ) eq 'Cancel'
            )
        {
            $win->toplevel->Unbusy() unless $main::insideEval;
            return -1;
        }
    }
    elsif ( $lock =~ /^originally locked by us/ ) {
        if (TrEd::Query::User::new_query(
                $win,
                "File $f has been $lock, so saving it now seems quite safe.",
                -bitmap  => 'question',
                -title   => "Saving changed file?",
                -buttons => [ 'Save', 'Cancel' ]
            ) eq 'Cancel'
            )
        {
            $win->toplevel->Unbusy() unless $main::insideEval;
            return -1;
        }
    }
    elsif ( $lock =~ /^changed/ ) {
        if (TrEd::Query::User::new_query(
                $win,
                "File $f has been $lock! Saving it now would overwrite those changes made by the other program.",
                -bitmap  => 'question',
                -title   => "Saving changed file?",
                -buttons => [ 'Save anyway', 'Cancel' ]
            ) eq 'Cancel'
            )
        {
            $win->toplevel->Unbusy() unless $main::insideEval;
            return -1;
        }
    }

    $win->toplevel->Busy( -recurse => 1 ) unless $main::insideEval;

    my $refs_to_save = {};
    my $file_save_hook_res = main::doEvalHook( $win, "file_save_hook", $f )
                             || $EMPTY_STR; 
    if (  !askSaveReferences( $win, $fsfile, $refs_to_save, $f )
        or $file_save_hook_res eq 'stop' )
    {
        main::update_title_and_buttons( $win->{framegroup} );
        $win->toplevel->Unbusy() unless $main::insideEval;
        return;
    }
    eval { Treex::PML::IO::rename_uri( $f, $f . "~" ) unless $f =~ /^ntred:/ };
    print STDERR $@;
    $fsfile->changeAppData( 'refs_save', $refs_to_save );
    my $result;
    my $stop;
    my @warnings;
    my $err;
    {
        local $SIG{__WARN__}
            = sub { my $msg = shift; chomp $msg; push @warnings, $msg; };
        eval { $result = $fsfile->writeFile($f); };
        $err = $@;

        # called from within the eval so all errors and warnings
        # are shown as warnings on the output
        $stop = main::doEvalHook( $win, "after_save_hook", $f, $result ) 
                || $EMPTY_STR;
    }
    $fsfile->changeAppData( 'refs_save', undef );
    if ( !$result or $stop eq "stop_fatal" ) {
        $win->toplevel->Unbusy() unless $main::insideEval;
        $fsfile->notSaved(1);
        main::saveFileStateUpdate($win) if $fsfile == $win->{FSFile};
        TrEd::Error::Message::error_message(
            $win,
            "Error while saving file to '$f'!\nI'll try to recover the original from backup.\n"
                . _last_err(
                $err . "\n"
                    . (
                    @warnings ? join( "\n", 'WARNINGS:', @warnings ) : '' )
                )
                . "\n"
                . "Check file and directory permissions.\nSee also the console error output."
        );
        undef $!;
        eval {
            Treex::PML::IO::rename_uri( $f . "~", $f )
                unless $f =~ /^ntred:/;    # if (-f $f);
        };
        if ( main::_last_err() ) {
            my $err = "Error while renaming backup file $f~ back to $f.\n";
            TrEd::Error::Message::error_message( $win, $err, 1 );
        }
        return -1;
    }
    elsif (@warnings) {
        TrEd::Error::Message::error_message( $win,
            "Saving file to '$f':\n\n" . join( "\n", @warnings ), 'warn' );
    }
    else {
        Treex::PML::IO::unlink_uri( $f . "~" ) if $main::no_backups;
    }
    TrEd::FileLock::set_fs_lock_info( $fsfile, TrEd::FileLock::set_lock($f) )
        if $TrEd::Config::lockFiles;
    my $autosave = main::autosave_filename($f);
    unlink $autosave if defined($autosave);
    $win->toplevel->Unbusy() unless $main::insideEval;
    my $ret = 1;
    if ( $stop eq "stop" ) {

        # SILENT STOP
        # file is considered saved
        $ret = -1;
    }
    elsif ( $stop eq "stop_nonfatal" ) {
        $fsfile->notSaved(1);
        $ret = -1;
    }
    TrEd::RecentFiles::add_file( $win->{framegroup}, $f );
    main::saveFileStateUpdate($win) if $fsfile == $win->{FSFile};
    return $ret;
}

#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub newFileFromCurrent {
    my ( $grp, $keep ) = @_;
    $keep ||= $grp->{keepopen};
    my $win = $grp->{focusedWindow};
    return unless $win->{FSFile};
    $win->toplevel->Busy( -recurse => 1 ) unless $main::insideEval;
    my $cur = $win->{FSFile};
    my $new = $cur->clone(0);

    $new->changeURL( 'unnamed' . sprintf( '%03d', $new_file_no++ ) );
    $cur = undef;
    my $answer = ask_save_file( $win, 1, 1 );
    return 0 if $answer == -1;
    $keep = $keep || $answer;
    closeFile( $win, -no_update => 1, -keep_postponed => $keep );

    #  $new->new_tree(0);
    $win->set_current_file( $new );
    push @openfiles, $win->{FSFile};
    main::updatePostponed($grp);

    main::update_title_and_buttons($grp);
    $win->{redrawn}
        = 0;    # if redraw is called during the hook, we will know it
    $win->get_nodes();
    if (    $main::init_macro_context ne $EMPTY_STR
        and $win->{macroContext} ne $main::init_macro_context )
    {
        main::switchContext( $win, $main::init_macro_context, 1 );
    }
    else {
        main::doEvalHook( $win, "guess_context_hook", "file_opened_hook" );
    }
    main::doEvalHook( $win, "file_opened_hook" );
    $win->redraw() unless $win->{redrawn};
    main::centerTo( $win, $win->{currentNode} );
    $win->toplevel->Unbusy() unless $main::insideEval;

    #  TrEd::RecentFiles::add_file($grp,$new->filename);
    return 1;
}

# dialog
#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub saveFileAs {
    my ( $win, $fsfile ) = @_;
    my $initdir;
    $fsfile ||= $win->{FSFile};
    return unless $fsfile;
    my $file = $fsfile->filename;

    $initdir = dirname($file);
    $initdir = cwd if ( $initdir eq './' );
    $initdir =~ s!${dir_separator}$!!m;

    my $cur = $fsfile->backend || '';
    $cur =~ s/Backend$//;
    $cur = qq{ ($cur)} if $cur;
    my $response = TrEd::Query::User::new_query(
        $win,
        "\nPlease,\nchoose one of the following output formats.\n\n"
            . "\nWARNING:\nsome formats may be incompatible with the current file.\n",
        -title   => "Save As ...",
        -buttons => [
            "Use current" . $cur, "FS",
            "CSTS",               "TrXML",
            "TEIXML",             "Storable",
            "Cancel"
        ]
    );
    return if ( $response eq "Cancel" );

    #urob tabulku podla pbp?
    if ( $response eq 'FS' ) {
        $file =~ s/\.(?:csts|sgml|sgm|cst|trxml|trx|tei|xml)/.fs/i;
        $file =~ s/\.(amt|am|m|a)/$1.fs/;
    }
    elsif ( $response eq 'CSTS' ) {
        $file =~ s/\.(?:fs|tei|trxml|trx|xml)/.csts/i;
    }
    elsif ( $response eq 'TrXML' ) {
        $file =~ s/\.(?:csts|sgml|sgm|cst|fs|tei)/.trxml/i;
    }
    elsif ( $response eq 'TEIXML' ) {
        $file =~ s/\.(?:csts|sgml|sgm|cst|fs|trxml|trx)/.xml/i;
    }
    elsif ( $response eq 'Storable' ) {
        $file =~ s/\.(?:csts|sgml|sgm|cst|fs|trxml|trx|tei|xml)/.pls/i;
    }

    my $filetypes;
    if ( $response =~ /^Use current/ ) {
        my ($backend)
            = grep { $backend_map{$_} eq $fsfile->backend } keys %backend_map;
        if ($backend) {
            $filetypes = $save_types{$backend};
        }
        else {
            $filetypes = $save_types{'all'};
        }
    }
    else {
        $filetypes = $save_types{ lc($response) };
    }

    $file = main::get_save_filename(
        $win->toplevel,
        -filetypes => $filetypes,
        -title     => "Save As ...",
        -d $initdir ? ( -initialdir => $initdir ) : (),
        $^O eq 'MSWin32'
        ? ()
        : ( -initialfile => TrEd::Convert::filename($file) )
    );
    return doSaveFileAs(
        $win,
        $fsfile,
        $file,
        ( $response !~ /^Use current/ )
        ? $backend_map{ lc($response) }
        : $fsfile->backend,
        'ask',
        'ask'
    );
}

# fsfile, dialog+
#######################################################################################
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
sub doSaveFileAs {
    my ( $win, $fsfile, $filename, $backend, $update_refs, $update_filelist )
        = @_;
    my ( $old_file, $old_backend, $old_format )
        = ( $fsfile->filename, $fsfile->backend, $fsfile->fileFormat );

    my $lock_change = 0;
    if ( $filename ne $EMPTY_STR ) {
        if ( $filename ne $fsfile->filename ) {
            if ($lockFiles) {
                my $lock = TrEd::FileLock::check_lock( undef, $filename );
                if ( $lock eq 'my' ) {
                    if (TrEd::Query::User::new_query(
                            $win,
                            "An existing lock on the file $filename indicates that it is probably used by another file-object within this process!",
                            -bitmap  => 'question',
                            -title   => "Saving to a locked file?",
                            -buttons => [ 'Steal lock and save', 'Cancel' ]
                        ) eq 'Cancel'
                        )
                    {
                        return -1;
                    }
                }
                elsif ( $lock ne 'none' ) {
                    if (TrEd::Query::User::new_query(
                            $win,
                            "File $filename was $lock!",
                            -bitmap  => 'question',
                            -title   => "Saving to a locked file?",
                            -buttons => [ 'Steal lock and save', 'Cancel' ]
                        ) eq 'Cancel'
                        )
                    {
                        return -1;
                    }
                }
                $lock_change = 1;
                $fsfile->changeFilename($filename);

                #TODO: here we may be locking a file that does not yet exist
                TrEd::FileLock::set_fs_lock_info( $fsfile,
                    TrEd::FileLock::set_lock($filename) );
            }
            else {
                $fsfile->changeFilename($filename);
            }
        }
        if ( defined $backend ) {
            $fsfile->changeBackend($backend);
        }
        $fsfile->changeFileFormat(
            ( $filename =~ /\.gz$/ ? "gz-compressed " : $EMPTY_STR )
            . $fsfile->backend );
        main::update_title_and_buttons( $win->{framegroup} );
        main::updatePostponed( $win->{framegroup} );
        if ( TrEd::File::saveFile( $win, $filename ) == 1 ) {
            TrEd::FileLock::remove_lock( $fsfile, $old_file, 1 )
                if ($lock_change);

            if ( $filename ne $old_file
                and ref( $fsfile->appData('fs-part-of') ) )
            {
                my @fs = @{ $fsfile->appData('fs-part-of') };
                if ( $update_refs eq 'all' ) {

                    # all
                    $update_refs = \@fs;
                }
                elsif ( UNIVERSAL::isa( $update_refs, 'ARRAY' ) ) {

                    # pre-selected FSFiles
                }
                elsif ( $update_refs eq 'ask' ) {
                    $update_refs = [];
                    if (@fs) {
                        my $filenames = [ map { $_->filename } @fs ];
                        my $selection = [@$filenames];
                        TrEd::Query::List::new_query(
                            $win->toplevel,
                            'Rename file also in...',
                            'multiple',
                            $filenames,
                            $selection,
                            label => {
                                -text => <<'EOF'
You have renamed the current file, but it is referred to by the file(s) below.
Please select files that should update their references to the current file:
EOF
                            },
                            list => { -exportselection => 0, }
                        );
                        if (@$selection) {
                            my %selected = map { $_ => 1 }
                                grep { $_ ne $EMPTY_STR } @$selection;
                            $update_refs
                                = [ grep { $selected{ $_->filename } } @fs ];
                        }
                    }
                }
                my @failed;
                foreach my $reff (@$update_refs) {
                    my $req        = $reff->metaData('fs-require');
                    my $references = $reff->metaData('references');
                    my $match;
                    if ( ref($req) ) {
                        for (@$req) {
                            if ( $_->[1] eq $old_file ) {
                                if ( ref($references) ) {
                                    $references->{ $_->[0] } = $filename;
                                    $_->[1] = $filename;
                                    $reff->notSaved(1);
                                }
                                $match = 1;
                            }
                        }
                    }
                    unless ($match) {
                        push @failed, $reff;
                    }
                }
                TrEd::Error::Message::error_message(
                    $win,
                    "Could not find reference to the current file in the following files:\n\n"
                        . join( "\n", map { $_->filename } @fs ),
                    1
                ) if @failed;
            }

            my $filelist = $win->{currentFilelist};
            if ( $filelist and $filename ne $old_file ) {
                if ( !defined $update_filelist or $update_filelist eq 'ask' )
                {
                    my $response = TrEd::Query::User::new_query(
                        $win,
                        "Do you want to update the current file list ("
                            . $filelist->name
                            . ")?\n\n"
                            . "This will find all occurences in the file list of:\n${old_file}\n"
                            . "and update them to point to:\n${filename}",
                        -bitmap  => 'question',
                        -title   => 'Update file list?',
                        -buttons => [
                            'Yes (all references)',
                            'Only current position',
                            'No'
                        ]
                    );
                    if ( $response ne 'No' ) {
                        if ($filelist) {
                            $filelist->rename_file(
                                $old_file,
                                $filename,
                                $response =~ /^Only/ && $win
                                ? $win->currentFileNo()
                                : undef
                            );
                        }
                    }
                }
                elsif ( $update_filelist =~ /^all$|^current$/ ) {
                    if ($filelist) {
                        $filelist->rename_file(
                            $old_file,
                            $filename,
                            ( $update_filelist eq 'current' && $win )
                            ? $win->currentFileNo()
                            : undef
                        );
                    }
                }
            }
            return 1;
        }
        else {
            TrEd::FileLock::remove_lock( $fsfile, $filename, 1 )
                if ($lock_change);
            $fsfile->changeFilename($old_file);
            TrEd::FileLock::set_fs_lock_info( $fsfile,
                TrEd::FileLock::set_lock($old_file) )
                if $lock_change;
            $fsfile->changeBackend($old_backend);
            $fsfile->changeFileFormat($old_format);
            main::update_title_and_buttons( $win->{framegroup} );
            return 0;
        }
    }
    return 0;
}

sub _change_filename {
    my ($initdir, $l) = @_;
    my ( $file, $rest ) = split / \[/, $l->get('active'), 2;
    my $initdir2 = dirname($file);
    if (!File::Spec->file_name_is_absolute($initdir2)) {
        $initdir2 = File::Spec->catfile( $initdir, $initdir2 );
    }
    $file = main::get_save_filename(
        $l->toplevel,
        -filetypes => $save_types{all},
        -title     => "Save As ...",
        -d $initdir2 ? ( -initialdir => $initdir2 ) : (),
        $^O eq 'MSWin32'
        ? ()
        : ( -initialfile => filename($file) )
    );
    if ( $file ne $EMPTY_STR ) {
        my $index = $l->index('active');
    
        my %selected
            = map { $_ => 1 }
            grep { $l->selectionIncludes($_) }
            ( 0 .. $l->size - 1 );
        
        $l->insert( $index, $file . " [" . $rest );
        $l->delete('active');
        $l->activate($index);
        foreach ( 0 .. $l->size - 1 ) {
            if ( $selected{$_} ) {
                $l->selectionSet($_);
            }
            else {
                $l->selectionClear($_);
            }
        }
    }
    Tk->break();
    return;
}

use Readonly;



#######################################################################################
# Usage         : askSaveReferences($win, $fsfile, $result, $filename)
# Purpose       : Ask the user to choose which of the modified referenced files should be saved
# Returns       : 1 if there are no references to save
#                 
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload
# Throws        : No exception
# Comments      : # result je vystupny hash... C-like predavanie vystupu...
# See Also      : 
sub askSaveReferences { 
    my ( $win_ref, $fsfile, $result, $filename ) = @_;
    if ( !defined $filename ) {
        $filename = $fsfile->filename();
    }
    my (@refs);
    my $schema = $fsfile->schema() || return 1;
    my $references = [ $schema->get_named_references() ]; #name: adata, readas: trees; name:mdata, readas: dom
    return 1 if (!@$references);
    my $name2id = $fsfile->metaData('refnames'); # { mdata => m, wdata => w }
    my $id2href = $fsfile->metaData('references'); # { a => 'URI::File', w dtto, v => vallex.pml }
    foreach my $reference (@{$references}) {
        my $name  = $reference->{name};
        my $refid = $name2id->{$name}; # napr 'a', 'm'
        if ($refid) {
            my $href = $id2href->{$refid}; # napr 'URI::File sample0.a.gz'
            my $r;
            if (    $href
                and $reference->{readas} =~ /^(dom|pml)$/
                and ref $fsfile->appData('ref')
                and $r = $fsfile->appData('ref')->{$refid} )
            {
                push @refs, [ $href . " [$refid, $name]", 
                              $r, 
                              $refid, 
                              $name 
                            ];
            }
        }
    }
    my $i = 0;
    while ( $i < @refs ) {
        my $r = $refs[$i][1];
        if ( UNIVERSAL::DOES::does( $r, 'Treex::PML::Instance' ) ) {
            my $schema     = $r->get_schema();
            my $references = [ $schema->get_named_references() ];
            next if (!@{$references});
            my $name2id = $r->get_refname_hash();
            my $id2href = $r->get_references_hash();
            foreach my $reference (@{$references}) {
                my $name  = $reference->{name};
                my $refid = $name2id->{$name};
                if ($refid) {
                    my $href = $id2href->{$refid};
                    if ( $href && $reference->{readas} =~ /^(dom|pml)$/ ) {
                        my $r2 = $r->get_ref($refid);
                        $refid = $refs[$i][2] . q{/} . $refid;
                        $name  = $refs[$i][3] . q{/} . $name;
                        if ($r2) {
                            push @refs,
                                [ $href . " [$refid, $name]", 
                                  $r2, 
                                  $refid, 
                                  $name 
                                ];
                        }
                    }
                }
            }
        }
    }
    continue { $i++ }
    @refs = map { $_->[0] } @refs;

    # CURSOR
    return 1 if (!@refs);
    my $initdir   = dirname($filename);
    my $selection = [];
    my $return    = TrEd::Query::List::new_query(
        $win_ref->toplevel,
        'Select resources to save',
        'multiple',
        \@refs,
        $selection,
        label => {
            -text => $ASK_SAVE_REF_LABEL,
        },
        list    => { -exportselection => 0, },
        buttons => [
            {   -text      => 'Change filename...',
                -underline => 7,
                -command   => [ \&_change_filename, $initdir ],
            }
        ]
    );
    if ($return) {
        %{$result} = map { /^(.*) \[([^,]+),/ ? ( $2 => $1 ) : () } @{$selection};
    }
    return $return;
}

#######################################################################################
# Usage         : ask_save_file($win_ref, $keepbutton, $cancelbutton, $fsfile)
# Purpose       : Ask user whether the current file should be saved and save it
#                 if it is told so
# Returns       : 0 if there is no file to save or the file has already been saved or the 
#                   save was successful
#                 1 if the user chooses to keep the file open
#                 -1 if the user chooses to cancel the operation or something prevented file from saving
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window
#                 scalar $keepbutton -- if set to true value, allows user to keep the file
#                 scalar $cancelbutton -- if set to true value, allows user to cancel the operation
#                 Treex::PML::Document ref $fsfile -- ref to file that we are asking the user about (optional) 
# Throws        : No exception
# Comments      : If no $fsfile is specified, the file from Window $win_ref is considered.
# See Also      : saveFile(), TrEd::Query::User::new_query()
sub ask_save_file {
    my ( $win_ref, $keepbutton, $cancelbutton, $fsfile ) = @_;
    $fsfile ||= $win_ref->{FSFile};
    # do nithing if there is no fsfile or it has been already saved
    return 0 if (!ref $fsfile || !$fsfile->notSaved());
    my $answer = TrEd::Query::User::new_query(
        $win_ref,
        $fsfile->filename()
            . "\n\nFile may be changed!\nDo you want to save it?",
        -bitmap  => 'question',
        -title   => "Should I save the file?",
        -buttons => [
            'Yes', 
            'No',
            $keepbutton ? 'Keep' : (), 
            $cancelbutton ? 'Cancel' : ()
        ]
    );
    if ( $answer eq 'Yes' ) {
        return saveFile( $win_ref, $fsfile ) == -1 ? -1 : 0;
    }
    elsif ( $answer eq 'Keep' ) {
        return 1;
    }
    elsif ( $answer eq 'Cancel' ) {
        return -1;
    }
}


#######################################################################################
# Usage         : ask_save_files_and_close($grp_ref, $cancelbutton)
# Purpose       : Ask whether to save modified files in all the Windows and close them
# Returns       : -1 if the operation was cancelled by the user
#                 0 otherwise
# Parameters    : hash_ref $grp_ref -- reference to hash containing TrEd options
#                 scalar $cancelbutton -- if set to true, displays cancel button for the user
# Throws        : no exception
# Comments      : 
# See Also      : ask_save_file()
# was main::askSaveFiles
sub ask_save_files_and_close {
    my ( $grp_ref, $cancelbutton ) = @_;
    
    # put focused window in front of other windows in $grp_ref->{treeWindows} array
    @{ $grp_ref->{treeWindows} }
        = grep { $_ ne $grp_ref->{focusedWindow} } @{ $grp_ref->{treeWindows} };
    unshift @{ $grp_ref->{treeWindows} }, $grp_ref->{focusedWindow};
    
    my $win;
    my %asked;
    # ask for every file shown in opened windows
    foreach $win ( @{ $grp_ref->{treeWindows} } ) {
        if ( $win->{FSFile} ) {
            $asked{ $win->{FSFile} } = 1;
            main::focusCanvas( $win->canvas(), $win->{framegroup} );
            return -1 if (ask_save_file( $win, 0, $cancelbutton ) == -1);
            closeFile( $win, -no_update => 1, -all_windows => 1 );
        }
    }
    
    # take care of the rest of opened files
    for my $fsfile ( grep { !$asked{$_} && ref $_ && $_->notSaved() }
        @openfiles )
    {
        my $win = $grp_ref->{focusedWindow};
        resume_file( $win, $fsfile );
        main::update_title_and_buttons($grp_ref);
        $win->get_nodes();
        $win->redraw();
        main::centerTo( $win,
            $win->{currentNode} );
        $grp_ref->{top}->update();
        return -1
            if ask_save_file( $win, 0, $cancelbutton ) == -1;
    }
    closeAllFiles($grp_ref);
    return 0;
}

#######################################################################################
# Usage         : resume_file($win_ref, $fsfile, $keep)
# Purpose       : Resume already opened file 
# Returns       : Undef/empty list
# Parameters    : TrEd::Window ref $win_ref        -- ref to TrEd::Window object in which the file is going to be resumed
#                 Treex::PML::Document ref $fsfile -- a relative path to a file
#                 scalar $keep -- indicator whether the currently opened file should be kept open (optional)
# Throws        : no exception
# Comments      : If file has already been opened and fsfile object has been created, 
#                 the file is resumed instead of opened in a regular way. 
#                 This subroutine is a part of this resume operation, which takes care of
#                 switching context, stylesheet, setting fsfile for TrEd::Window and
#                 updating the state of 'save' button on TrEd's toolbar.
# See Also      : open_file(), closeFile()
sub resume_file {
    my ( $win_ref, $fsfile, $keep ) = @_;
    $keep ||= $win_ref->{framegroup}->{keepopen};
    return if ( !ref $win_ref || !ref $fsfile );
    if ($TrEd::Config::tredDebug) {
        print "Resuming file " . $fsfile->filename() . "\n";
    }

    closeFile( $win_ref, -keep_postponed => $keep );
    main::__debug( "Using last context: ", $fsfile->appData('last-context') );
    main::switchContext( $win_ref, $fsfile->appData('last-context') );
    main::__debug( "Using last stylesheet: ",
        $fsfile->appData('last-stylesheet') );
    main::switchStylesheet( $win_ref, $fsfile->appData('last-stylesheet') );

    $win_ref->set_current_file( $fsfile );
    main::saveFileStateUpdate($win_ref);
    return;
}

#######################################################################################
# Usage         : absolutize_path($ref_filename, $filename, [$search_resource_path])
# Purpose       : Return absolute path unchanged, resolve relative path
# Returns       : Resolved path, return value from Treex::PML::ResolvePath
# Parameters    : scalar $ref_path              -- a reference filename
#                 scalar $filename              -- a relative path to a file
#                 scalar $search_resource_paths -- 0 or 1
# Throws        : no exception
# Comments      : just calls Treex::PML::ResolvePath(@_)
# See Also      : Treex::PML::ResolvePath()
sub absolutize_path {
    return &Treex::PML::ResolvePath;
}

#######################################################################################
# Usage         : absolutize(@array)
# Purpose       : Make all paths in the @array absolute
# Returns       : Array of absolute paths
# Parameters    : list @array -- list of paths to be changed into absolute paths
# Throws        : no exception
# See Also      : File::Spec->rel2abs()
sub absolutize {
    return

        # if the path starts with X:/, | or /, it is absolute, just return it;
        # otherwise change relative to absolute path
        map { m(^[[:alnum:]]+:/|^\s*\||^\s*/) ? $_ : File::Spec->rel2abs($_) }

        # filter out elements containing only whitespace
        grep { !/^\s*$/ } @_;
}



#######################################################################################
# Usage         : get_secondary_files($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list)
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_secondary_files_recursively()
sub get_secondary_files {
    my ($fsfile) = @_;

    # is probably the same as Treex::PML::Document->relatedDocuments()
    # a reference to a list of pairs (id, URL)
    my $requires = $fsfile->metaData('fs-require');
    my @secondary;
    if ($requires) {
        foreach my $req (@$requires) {
            my $id = $req->[0];
            my $req_fs
                = ref( $fsfile->appData('ref') )
                ? $fsfile->appData('ref')->{$id}
                : undef;
            if ( UNIVERSAL::DOES::does( $req_fs, 'Treex::PML::Document' ) ) {
                push( @secondary, $req_fs );
            }
        }
    }
    return uniq(@secondary);
}

#######################################################################################
# Usage         : get_secondary_files_recursively($fsfile)
# Purpose       : Find all secondary files required by Treex::PML::Document $fsfile according to its PML schema,
#                 and also all secondary files of these secondary files, etc recursively
# Returns       : List of Treex::PML::Document objects (every object appears just once in the list)
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose secondary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_secondary_files()
sub get_secondary_files_recursively {
    my ($fsfile) = @_;
    my @secondary = get_secondary_files($fsfile);
    my %seen;
    my $i = 0;
    while ( $i < @secondary ) {
        my $sec = $secondary[$i];
        if ( !exists( $seen{$sec} ) ) {
            $seen{$sec} = 1;
            push( @secondary, get_secondary_files($sec) );
        }
        $i++;
    }
    return uniq(@secondary);
}

#######################################################################################
# Usage         : get_primary_files($fsfile)
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for
# Throws        : no exception
# See Also      : Treex::PML::Document::appData(), get_primary_files_recursively()
sub get_primary_files {
    my ($fsfile) = @_;

    # probably the same as Treex::PML::Document->relatedSuperDocuments()
    return @{ $fsfile->appData('fs-part-of') || [] };
}

#######################################################################################
# Usage         : get_primary_files_recursively($fsfile)
# Purpose       : Find a list of Treex::PML::Document objects representing related superior documents,
#                 and then list of all their superior documents, etc recursively
# Returns       : List of Treex::PML::Document objects representing related superior documents
# Parameters    : Treex::PML::Document ref $fsfile -- the file whose primary files we are searching for
# Throws        : no exception
# See Also      : get_primary_files()
sub get_primary_files_recursively {
    my ($fsfile) = @_;
    my @primary = get_primary_files($fsfile);
    my %seen;
    my $i = 0;
    while ( $i < @primary ) {
        my $prim = $primary[$i];
        if ( !exists( $seen{$prim} ) ) {
            $seen{$prim} = 1;
            push( @primary, get_primary_files($prim) );
        }
        $i++;
    }
    return uniq(@primary);
}

# from tred::convert
#######################################################################################
# Usage         : dirname($path)
# Purpose       : Find out the name of the directory of $path
# Returns       : Part of the string from the first character to the last forward/backward slash.
#                 Empty string if $path is not defined.
# Parameters    : scalar $path -- path whose dirname we are looking for
# Throws        :
# Comments      : If $path does not contain any slash (fw or bw), dot and directory separator is returned, i. e.
#                 "./" on Unices, ".\" on Win32
# See Also      : index(), rindex(), substr()
sub dirname {
    my $a = shift;

    # this is for the sh*tty winz where
    # both slash and backslash may be uzed
    # (i'd sure use File::Spec::Functions had it support
    # for this also in 5.005 perl distro).
    return $EMPTY_STR if ( !defined $a );
    return ( index( $a, $dir_separator ) + index( $a, q{/} ) >= 0 )
        ? substr( $a, 0,
        TrEd::MinMax::max( rindex( $a, $dir_separator ), rindex( $a, q{/} ) ) + 1 )
        : ".$dir_separator";
}

#######################################################################################
# Usage         : filename($path)
# Purpose       : Extract filename from $path
# Returns       : Part of the string after the last slash.
#                 Empty string if $path is not defined.
# Parameters    : scalar $path -- path with file name
# Throws        :
# Comments      : E.g. returns 'filename' from '/home/john/docs/filename'
# See Also      : index(), rindex(), substr()
sub filename {
    my $a = shift;

    # this is for the sh*tty winz where
    # both slash and backslash may be uzed
    return $EMPTY_STR if ( !defined $a );
    return ( index( $a, $dir_separator ) + index( $a, q{/} ) >= 0 )
        ? substr( $a,
        TrEd::MinMax::max( rindex( $a, $dir_separator ), rindex( $a, q{/} ) ) + 1 )
        : $a;
}

#######################################################################################
# Usage         : init_app_data($fsfile)
# Purpose       : Initialize $fsfile's application specific data for using the fsfile in TrEd
# Returns       : Undef/empty list
# Parameters    : Treex::PML::Document ref $fsfile -- ref to file to initialize
# Throws        : No exception
# Comments      : Initialize the undo information and information about related files, 
#                 if they are not already set
# See Also      : 
# was main::initAppData
sub init_app_data {
    my ($fsfile) = @_;
    # init fsfile's undo information
    if ( !ref $fsfile->appData('undostack') ) {
        $fsfile->changeAppData('undostack', [] );
        $fsfile->changeAppData('undo',      -1 );
        $fsfile->changeAppData('lockinfo',  undef );
    }
    # init 'fs-part-of' hash which stores information
    # about primary file of this fsfile
    if ( !ref $fsfile->appData('fs-part-of') ) {
        $fsfile->changeAppData('fs-part-of', []);
    }
    
    # init 'ref' hash which stores information 
    # about loaded secondary files
    if ( !ref $fsfile->appData('ref') ) {
        $fsfile->changeAppData('ref', {});
    }
    return;
}


#######################################################################################
# Usage         : close_file_in_window($grp_or_win)
# Purpose       : Close current opened file in window specified by $grp_or_win
# Returns       : Undef/empty list if the operation was cancelled by the user
#                 1 if the file was closed
# Parameters    : hash_ref $grp_or_win -- ref to hash of TrEd's options or to 
# Throws        : No exception
# Comments      : Initialize the undo information and information about related files, 
#                 if they are not already set
# See Also      : 
# was main::closeFileInWindow
sub close_file_in_window {
  my ($grp_or_win)=@_;
  my ($grp,$win)=main::grp_win($grp_or_win);
  my $keep;
  if (main::fsfileDisplayingWindows($grp,$win->{FSFile})<2) {
    $keep=ask_save_file($win,1,1);
    return if $keep == -1;
  }
  return closeFile($win, -keep_postponed => $keep);
}

1;

__END__

=head1 NAME


TrEd::File -- file handling routines -- opening, saving, (re)loading files in TrEd


=head1 VERSION

This documentation refers to 
TrEd::File version 0.1.


=head1 SYNOPSIS

  use TrEd::File;
  
  
  
  # FSFile metainfo retrieval
  
  my @secondary_files         = TrEd::File::get_secondary_files($fsfile);
  my @secondary_files_recurs  = TrEd::File::get_secondary_files_recursively($fsfile);
  
  
  # Find ref to related Treex::PML::Documents loaded by Treex::PML::Document->loadRelatedDocuments()
  my $id = $secondary_files[0]->[0];
  my $fsfile_2 = $fsfile->referenceObjectHash()->{$id};
  
  my @primary_files         = TrEd::File::get_primary_files($fsfile_2);
  my @primary_files_recurs  = TrEd::File::get_primary_files_recursively($fsfile_2);
  
  
  
  my $path = "/etc/X11/xorg.conf";
  my $dir = TrEd::File::dirname($path);
  my $dir = TrEd::File::filename($path);
    
=head1 DESCRIPTION

This package provides basic open file dialog for TrEd.

=head1 SUBROUTINES/METHODS

=over 4 



=item * C<TrEd::File::dirname($path)>

=over 6

=item Purpose

Find out the name of the directory of $path


=item Parameters

  C<$path> -- scalar $path -- path whose dirname we are looking for

=item Comments

If $path does not contain any slash (fw or bw), dot and directory separator is returned, i. e. 

"./" on Unices, ".\" on Win32

=item See Also

L<index>,
L<rindex>,
L<substr>,

=item Returns

Part of the string from the first character to the last forward/backward slash.
Empty string if $path is not defined.

=back


=item * C<TrEd::File::filename($path)>

=over 6

=item Purpose

Extract filename from $path


=item Parameters

  C<$path> -- scalar $path -- path with file name

=item Comments

E.g. returns 'filename' from '/home/john/docs/filename'


=item See Also

L<index>,
L<rindex>,
L<substr>,

=item Returns

Part of the string after the last slash.
Empty string if $path is not defined.

=back




=back


=head1 DIAGNOSTICS

Carps if the Tk's open file dialog returns file name in UTF-8 

=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES



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

