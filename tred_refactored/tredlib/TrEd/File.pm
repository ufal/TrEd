package TrEd::File;

use strict;
use warnings;

use TrEd::ManageFilelists;
use TrEd::Basics qw{$EMPTY_STR getSecondaryFiles errorMessage};
use TrEd::Config qw{$ioBackends $lockFiles $reloadKeepsPatterns};
use TrEd::MinMax qw{max2 first};
use TrEd::Utils qw{applyFileSuffix};
use Treex::PML;

use Carp;

# if extensions has not been dependent on this variable, we could have changed 'our' to 'my'
our @openfiles = ();

my $new_file_no = 0;

#print "file\n ";
#print "iobackends" if defined $TrEd::Config::ioBackends;
#print "opt_B" if defined $main::opt_B;
#
#use Data::Dumper;
#
#my @hm = defined $TrEd::Config::ioBackends ? $TrEd::Config::ioBackends : ();
#print Dumper(\@hm);
#
#my @hm2 = defined $main::opt_B ? $main::opt_B : ();

#load back-ends
my @backends = (
    'FS',
    Treex::PML::ImportBackends(
        defined $TrEd::Config::ioBackends 
            ? split( /,/, $TrEd::Config::ioBackends) 
            : (),
        defined $main::opt_B 
            ? split( /,/, $main::opt_B) 
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
# Usage         : _insert_if_before($class, $before, $found_ref, $backend)
# Purpose       : Add $class to list of returned backends if backend $before was found
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
# See Also      : remove_backend(), get_backends()
sub add_backend {
    my ($class, $before) = @_;
    if (defined $before) {
        my $found;
        #TODO: try to use split instead?
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

#TODO: mozno tieto backendy --^ dat osve

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
    if ($status2_ref->{error} ne $EMPTY_STR) {
        $status1_ref->{error} .= "\n" . $status2_ref->{error};
    }
    # merge reports
    if ($status2_ref->{report} ne $EMPTY_STR) {
        $status1_ref->{report} .= "\n" . $status2_ref->{report};
    }
    return;
}

#######################################################################################
# Usage         : _new_status( ok => 0, error => 'File not found')
# Purpose       : Create a hash reference containing status information about a file operation
# Returns       : Reference to hash which contains status information
# Parameters    : List of status information pairs
# Throws        : No exception
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

#TODO: docs, see also $document->relatedSuperDocuments()
sub _related_files {
    my ($fsfile) = @_;
    return TrEd::Basics::getSecondaryFiles($fsfile), 
            @{ $fsfile->appData('fs-part-of') };
}

# set keep to 1 if filename is related and related should be keeped
sub _fix_keep_option {
    my ($fsfile, $file_name, $opts_ref) = @_;
    if ( !$opts_ref->{-keep} and $opts_ref->{-keep_related} ) {
        if ( $main::tredDebug and $fsfile ) {
            print STDERR "got -keep_related flag for open $file_name:\n";
            print STDERR map { $_->filename() . "\n" } _related_files($fsfile);
        }
        if ($fsfile 
            && first { $_->filename() eq $file_name } _related_files($fsfile)) {
                $opts_ref->{-keep} = 1;
                print STDERR "keep: $opts_ref->{-keep}\n" if $main::tredDebug;
        }
    }
}

# return first primary file of $fsfile's primary files whose name equals to $file_name or undef
sub _is_among_primary_files {
    my ($file_name, $fsfile) = @_;
    if (!defined $fsfile) {
        return;
    } 
    return TrEd::MinMax::first {
            Treex::PML::IO::is_same_filename( $_->filename(), $file_name );
            }
            TrEd::Basics::getPrimaryFilesRecursively($fsfile)
}

sub _check_for_recovery {
    my ($file_name, $grp, $win, $fsfile, $lockinfo, $opts_ref) = @_;
    
    # $grp->{noOpenFileError} can be set by TrEd::Filelist::Navigation::nextOrPrevFile, 
    # but I'm not sure what is it good for.. something with autosaving...?
    my $no_err = $grp->{noOpenFileError};  
    
    my $recover  = 'No';
    my $autosave = main::autosave_filename($file_name);
    if ( !$no_err && defined $autosave && -r $autosave ) {
        $recover = main::userQuery(
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
        ( $fsfile, $status ) = loadFile( $grp, $autosave, $backends );
        if (ref($fsfile)) {
            main::initAppData($fsfile);
        }
        if ( $status->{ok} ) {

            # Success
            $fsfile->changeFilename($file_name);
            $fsfile->notSaved(2);
            if ($TrEd::Config::lockFiles) {
                TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo );
            }
            if ( $status->{ok} < 0 ) {
                TrEd::Basics::errorMessage( $win, $status->{report}, 'warn' );
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

                ( $fsfile, $status ) = loadFile( $grp, $file_name, $backends );
                if (ref($fsfile)) {
                    main::initAppData($fsfile);
                }
                if ($TrEd::Config::lockFiles) {
                    TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo );
                }
            }
            elsif ( $answer eq 'Ignore' ) {
                if ( !$opts_ref->{-preload} && !$opts_ref->{-noredraw} ) {
                    redraw_win($win);
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

        ( $fsfile, $status ) = loadFile( $grp, $file_name, $backends );
        main::initAppData($fsfile) if ref($fsfile);
        TrEd::FileLock::set_fs_lock_info( $fsfile, $lockinfo )
            if $TrEd::Config::lockFiles;
    }

    if ( $status->{ok} ) {
        $fsfile->changeFileFormat(
            ( $file_name =~ /\.gz$/ ? "gz-compressed " : $EMPTY_STR ) . $fsfile->backend );
        unless ($main::no_secondary) {
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
        errorMessage( $win, $status->{report}, 'warn' );
    }
    return $status;
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
#                   -justheader   -- 
#                 Hooks run: 
# See Also      : 
sub open_file {
    my ( $grp_or_win, $raw_file_name, %opts ) = @_;
    my ( $grp, $win ) = grp_win($grp_or_win);
    if (!$opts{-nohook}) {
        if ( main::doEvalHook( $win, "open_file_hook", $raw_file_name, {%opts} ) eq 'stop' )
        {
            # not sure what status we should return
            return
                wantarray
                ? ( $win->{FSFile}, _new_status( ok => 1 ) )
                : $win->{FSFile};
        }
    }
    
    my $fsfile = $win->{FSFile};

    my ( $file_name, $suffix ) = TrEd::Utils::parse_file_suffix($raw_file_name);
    print "Goto suffix is $suffix\n" if defined($suffix) && $main::tredDebug;

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
            main::get_nodes_win( $win, $opts{-noredraw} );
            if ( !$opts{-nohook} ) {
                main::doEvalHook( $win, "guess_context_hook", "file_resumed_hook" );
                main::doEvalHook( $win, "file_resumed_hook" );
            }
            if ( !$opts{-noredraw} ) {
                main::redraw_win($win);
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
            my $answer = askSaveFile( $win, 1, 1 );
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
            if ( ref($opened_file)
                && Treex::PML::IO::is_same_filename( $opened_file->filename(), $file_name ) )
            {
                print "Opening postponed file\n" if $main::tredDebug;
                if ( !$opts{-preload} ) {
                    main::resumeFile( $win, $opened_file, $opts{-keep} );
                    main::update_title_and_buttons($grp);
                    TrEd::Utils::applyFileSuffix( $win, $suffix );
                    main::unhide_current_node($win);
                    main::get_nodes_win( $win, $opts{-noredraw} );
                    if ( !$opts{-nohook} ) {
                        main::doEvalHook( $win, "guess_context_hook",
                            "file_resumed_hook" );
                        main::doEvalHook( $win, "file_resumed_hook" );
                    }
                    if ( !$opts{-noredraw} ) {
                        main::redraw_win($win);
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
        if ( $lockinfo eq 'Cancel' ) {
            return wantarray ? ( undef, _new_status( cancel => 1 ) ) : undef;
        }
    }

    # Check autosave file
    my $status = _check_for_recovery();
    
    if (!$opts{-preload}) {
        set_window_file( $win, $fsfile ) ;
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

    #TODO: tento koment asi patri inam
    # add file to filelist
    if (!$opts{-preload}) {
        main::update_title_and_buttons($grp);
    }

    my $save_current;
    if ( !$opts{-preload} ) {
        TrEd::Utils::applyFileSuffix( $win, $suffix );
        $save_current = $win->{currentNode};
        main::unhide_current_node($win);
        main::get_nodes_win( $win, 1 );    # for the hook below
    }
    # if redraw is called during the hook, we will know it
    my $r = $win->{redrawn};
    if ( $opts{-preload} ) {
        if ( $fsfile && !$opts{-nohook} ) {
            main::doEvalHook( $win, "guess_context_hook", "file_opened_hook" );
            main::doEvalHook( $win, "file_opened_hook" );
        }
    }
    else {
        if (   $main::init_macro_context ne $EMPTY_STR
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
            if ( $win->{redrawn} <= $r ) {
                if ($save_current) {
                    $win->{currentNode} = $save_current;
                }
                main::get_nodes_win($win);    # the hook may have changed something
                main::redraw_win($win);
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
# a non-filelist operation (that is other than nextFile, or gotoFile)
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
# Usage         : reload_on_usr2($grp, $file_name)
# Purpose       : Reload file or open it if it is not open
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp     -- reference to hash containing TrEd options
#                 string $file_name -- name of the file to reload 
# Throws        : No exception
# Comments      : This function is a part of USR2 signal handler
# See Also      : main::handleUSR2Signal()
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
        __debug( "Closing ", $fsfile->filename,
            "; keep postponed: $opts{-keep_postponed}\n" );
        doEvalHook( $win, "file_close_hook", $fsfile, \%opts );
        $fsfile->currentTreeNo( $win->{treeNo} );
        $fsfile->currentNode( $win->{currentNode} );
    }
    else {
        return;
    }
    my $fn = $fsfile->filename;
    if ( !$opts{-keep_postponed} ) {
        if ( filePartOfADisplayedFile( $win->{framegroup}, $fsfile ) ) {
            warn "closeFile: Keeping postponed "
                . $fsfile->filename
                . " - part of a displayed file\n";
            $opts{-keep_postponed} = 1;
        }
        else {
            my @part_of = findToplevelFileFor( $win->{framegroup}, $fsfile );
            if ( $part_of[0] != $fsfile ) {
                return unless askSaveFile( $win, 0, 1, $fsfile ) == 0;
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
        $w->{stylesheet} = STYLESHEET_FROM_FILE();
        set_window_file( $w, undef );
        delete $w->{currentNode} if ( exists $w->{currentNode} );
        $w->{treeView}->clear_pinfo();
        if ( is_focused($w) ) {
            TrEd::ValueLine::set_value( $w->{framegroup}, $EMPTY_STR );
        }
        unless ( $opts{-no_update} ) {
            get_nodes_win($w);
            redraw_win($w);
        }
    }

    unless ( $opts{-no_update} ) {
        update_title_and_buttons( $win->{framegroup} );
        updatePostponed( $win->{framegroup} );
    }

    if ( $opts{-keep_postponed} and $fsfile ) {
        print STDERR "Postponing " . $fsfile->filename() . "\n"
            if $main::tredDebug;
        $fsfile->changeAppData( 'last-context',    $last_context );
        $fsfile->changeAppData( 'last-stylesheet', $last_stylesheet );
    }
    else {
        if ( $fsfile
            and not main::fsfileDisplayingWindows( $win->{framegroup}, $fsfile ) )
        {
            my $f = $fsfile->filename();
            print STDERR "Removing $f from list of open files\n"
                if $main::tredDebug;
            @openfiles = grep { $_ ne $fsfile } @openfiles;
            TrEd::RecentFiles::add_file( $win->{framegroup}, $f )
                unless $opts{-norecent}
                    or $fsfile->appData('norecent');
            my $autosave = autosave_filename($f);
            unlink $autosave if defined $autosave;
            TrEd::FileLock::remove_lock( $fsfile, $f );

            # remove dependency
            for my $req_fs ( getSecondaryFiles($fsfile) ) {
                if ( ref( $req_fs->appData('fs-part-of') ) ) {
                    @{ $req_fs->appData('fs-part-of') }
                        = grep { $_ != $fsfile }
                        @{ $req_fs->appData('fs-part-of') };
                }
                unless (
                    main::fsfileDisplayingWindows( $win->{framegroup}, $req_fs ) )
                {
                    print STDERR "Attempting to close dependent "
                        . $req_fs->filename . "\n"
                        if $main::tredDebug;
                    my $answer = askSaveFile( $win, 1, 1, $req_fs );
                    return if $answer == -1;
                    if ( $answer == 1 ) {
                        print STDERR "Keeping dependent "
                            . $req_fs->filename . "\n"
                            if $main::tredDebug;
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
    my ( $grp, $win ) = grp_win($grp_or_win);
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
        return if askSaveFile( $win, 0, 1 ) == -1;
        my $ctxt = $grp->{selectedContext};
        closeFile( $win, -all_windows => 1 );
        open_file( $win, $f, -noredraw => 1, -nohook => 1 );
        if ( $ctxt ne $grp->{selectedContext} ) {
            switchContext( $win, $ctxt, 1 );
        }
        $fsfile = $win->{FSFile};
        if ($fsfile) {
            if ($TrEd::Config::reloadKeepsPatterns) {
                $fsfile->changePatterns(@patterns);
                $fsfile->changeHint($hint);
            }
            doEvalHook( $win, "file_reloaded_hook" );
        }
        get_nodes_win($win);
        redraw_win($win);
        centerTo( $win, $win->{currentNode} );
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
sub loadFile {
    my ( $grp, $file, $backends ) = @_;
    $grp = cast_to_grp($grp);
    my @warnings;
    my $bck = ref($backends) ? $backends : \@backends;
    my $status = _new_status(
        ok       => 0,
        filename => $file,
        backends => $bck,
        warnings => \@warnings
    );
    _clear_err();
    local $SIG{__WARN__} = sub {
        my $msg = shift;
        chomp $msg;
        print STDERR $msg . "\n";
        push @warnings, $msg;
    };
    my $fsfile = Treex::PML::Factory->createDocumentFromFile(
        $file,
        {   encoding => $TrEd::Convert::inputenc,
            backends => $bck,
            recover  => 1,
        }
    );
    my $error = $Treex::PML::FSError;
    $status->{error} = $error == 1 ? 'No suitable backend!' : _last_err();
    $status->{report} = "Loading file '$file':\n\n";

    if ( ref($fsfile) and $fsfile->lastTreeNo >= 0 and $error == 0 ) {
        $status->{ok} = @warnings ? -1 : 1;
    }
    else {
        if ( ref($fsfile) and $error == 0 ) {
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
        return ( $fsfile, $status );
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
    my $requires = $fsfile->metaData('fs-require');
    if ($requires) {
        for my $req (@$requires) {
            next if ref( $fsfile->appData('ref')->{ $req->[0] } );
            my $req_filename
                = absolutize_path( $fsfile->filename, $req->[1] );
            print STDERR
                "Pre-loading dependent $req_filename ($req->[1]) as appData('ref')->{$req->[0]}\n"
                if $main::tredDebug;
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
            else {
                push @{ $req_fs->appData('fs-part-of') },
                    $fsfile;    # is this a good idea?
                __debug("Setting appData('ref')->{$req->[0]} to $req_fs");
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
                __debug( "Closing all parts of " . $fsfile->filename );
                closeFile(
                    $grp->{focusedWindow},
                    -fsfile      => $_,
                    -no_update   => 1,
                    -all_windows => 1
                );
            }
        }
        __debug( "Now closing file " . $fsfile->filename );
        closeFile(
            $grp->{focusedWindow},
            -fsfile      => $fsfile,
            -no_update   => 1,
            -all_windows => 1
        );
        if ( grep { $_ == $fsfile } @openfiles ) {

            # still there?
            __debug( "File still open, pushing it to the end: $fsfile: "
                    . $fsfile->filename );
            shift @openfiles;
            push @openfiles, $fsfile;
            __debug("Open files: @openfiles");
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
# ask user whether the current file should be saved (and save it if yes)
# if $keepbutton parameter is 1, allow user to keep the file
# return 0 if file saved, 1 if file should be kept and undef if no
# file
sub askSaveFile {
    my ( $win, $keepbutton, $cancelbutton, $fsfile ) = @_;
    $fsfile ||= $win->{FSFile};
    return 0
        unless ref($fsfile)
            and $fsfile->notSaved;
    my $answer = userQuery(
        $win,
        $fsfile->filename()
            . "\n\nFile may be changed!\nDo you want to save it?",
        -bitmap  => 'question',
        -title   => "Should I save the file?",
        -buttons => [
            'Yes', 'No',
            $keepbutton ? 'Keep' : (), $cancelbutton ? 'Cancel' : ()
        ]
    );
    if ( $answer eq 'Yes' ) {
        return saveFile( $win, $fsfile ) == -1 ? -1 : 0;
    }
    elsif ( $answer eq 'Keep' ) {
        return 1;
    }
    elsif ( $answer eq 'Cancel' ) {
        return -1;
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
    $win = cast_to_win($win);
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
                $win->{currentFileNo} = max2( 0, $win->{currentFileNo} );
                my $pos
                    = TrEd::ManageFilelists::insertToFilelist( $win,
                    $win->{currentFilelist},
                    $win->{currentFileNo}, $fsfile->filename );
                $win->{currentFileNo} = $pos if $pos >= 0;
                update_filelist_views( $win, $win->{currentFilelist}, 0 );
            }
            return $ret;
        }
    }

    my $lock = TrEd::FileLock::check_lock( $fsfile, $f );
    if ( $lock =~ /^locked|^stolen|^opened/ ) {
        if (userQuery(
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
        if (userQuery(
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
        if (userQuery(
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
    if (  !askSaveReferences( $win, $fsfile, $refs_to_save, $f )
        or doEvalHook( $win, "file_save_hook", $f ) eq 'stop' )
    {
        update_title_and_buttons( $win->{framegroup} );
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
        $stop = doEvalHook( $win, "after_save_hook", $f, $result );
    }
    $fsfile->changeAppData( 'refs_save', undef );
    if ( !$result or $stop eq "stop_fatal" ) {
        $win->toplevel->Unbusy() unless $main::insideEval;
        $fsfile->notSaved(1);
        saveFileStateUpdate($win) if $fsfile == $win->{FSFile};
        errorMessage(
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
        if ( _last_err() ) {
            my $err = "Error while renaming backup file $f~ back to $f.\n";
            errorMessage( $win, $err, 1 );
        }
        return -1;
    }
    elsif (@warnings) {
        errorMessage( $win,
            "Saving file to '$f':\n\n" . join( "\n", @warnings ), 'warn' );
    }
    else {
        Treex::PML::IO::unlink_uri( $f . "~" ) if $main::no_backups;
    }
    TrEd::FileLock::set_fs_lock_info( $fsfile, TrEd::FileLock::set_lock($f) )
        if $TrEd::Config::lockFiles;
    my $autosave = autosave_filename($f);
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
    saveFileStateUpdate($win) if $fsfile == $win->{FSFile};
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
    my $answer = askSaveFile( $win, 1, 1 );
    return 0 if $answer == -1;
    $keep = $keep || $answer;
    closeFile( $win, -no_update => 1, -keep_postponed => $keep );

    #  $new->new_tree(0);
    set_window_file( $win, $new );
    push @openfiles, $win->{FSFile};
    updatePostponed($grp);

    update_title_and_buttons($grp);
    $win->{redrawn}
        = 0;    # if redraw is called during the hook, we will know it
    get_nodes_win($win);
    if (    $main::init_macro_context ne $EMPTY_STR
        and $win->{macroContext} ne $main::init_macro_context )
    {
        switchContext( $win, $main::init_macro_context, 1 );
    }
    else {
        doEvalHook( $win, "guess_context_hook", "file_opened_hook" );
    }
    doEvalHook( $win, "file_opened_hook" );
    redraw_win($win) unless $win->{redrawn};
    centerTo( $win, $win->{currentNode} );
    $win->toplevel->Unbusy() unless $main::insideEval;

    #  TrEd::RecentFiles::add_file($grp,$new->filename);
    return 1;
}

1;

__END__

=head1 NAME


TrEd::Dialog::File::Open -- simple open file dialog


=head1 VERSION

This documentation refers to 
TrEd::Dialog::File::Open version 0.1.


=head1 SYNOPSIS

  use TrEd::Dialog::File::Open;
  
    
=head1 DESCRIPTION

This package provides basic open file dialog for TrEd.

=head1 SUBROUTINES/METHODS

=over 4 




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

