# -*- cperl -*-
# TrEd's main toolbar menus

#
# DO NOT CHANGE ANY IDENTIFIERS
# (not even if moving menus to different submenus, the identifiers are meaningless!!!)
#
# Use TrEd::Menu's lookup_menu_item method to look up actual menu entry
#

return sub {
    my ($grp) = @_;
    return {
        'MENUBAR' => [
            'Menu',
            'MENUBAR',
            {},
            [   'MENUBAR:FILE',   'MENUBAR:NODE',
                'MENUBAR:TREE',   'MENUBAR:VIEW',
                'MENUBAR:MACROS', 'MENUBAR:SETUP',
                'MENUBAR:HELP'
            ]
        ],
        'MENUBAR:FILE' => [
            'Cascade',
            'File',
            { '-underline' => 0 },
            [   'MENUBAR:FILE:OPEN',
                'MENUBAR:FILE:OPEN_URL',
                'MENUBAR:FILE:RELOAD',
                'SEPARATOR',
                'MENUBAR:FILE:RECENT',
                'SEPARATOR',
                'MENUBAR:FILE:KEPT_IN_MEMORY',
                'MENUBAR:FILE:FILE_LISTS',
                'MENUBAR:FILE:BOOKMARKS',
                'SEPARATOR',
                'MENUBAR:FILE:NEW',
                'SEPARATOR',
                'MENUBAR:FILE:PROPERTIES',
                'SEPARATOR',
                'MENUBAR:FILE:CLOSE',
                'MENUBAR:FILE:CLOSE_IN_WINDOW',
                'MENUBAR:FILE:CLOSE_AND_REMOVE_FROM_FILE_LIST',
                'SEPARATOR',
                'MENUBAR:FILE:SAVE',
                'MENUBAR:FILE:SAVE_AS',
                'SEPARATOR',
                'MENUBAR:FILE:PRINT',
                'SEPARATOR',
                'MENUBAR:FILE:QUIT'
            ]
        ],
        'MENUBAR:FILE:PROPERTIES' => [
            'Button',
            'Properties',
            {   -underline => 6,
                -command =>
                    [ \&TrEd::Dialog::FileProperties::show_dialog, $grp ],
            }
        ],
        'MENUBAR:FILE:BOOKMARKS' => [
            'Cascade',
            'Bookmarks',
            { '-underline' => 0 },
            [   'MENUBAR:FILE:BOOKMARKS:PLACE_OF_LAST_ACTION',
                'MENUBAR:FILE:BOOKMARKS:ADD_BOOKMARK',
                'MENUBAR:FILE:BOOKMARKS:ADD_BOOKMARK_TO_LIST',
                'MENUBAR:FILE:BOOKMARKS:GO_TO_BOOKMARK'
            ]
        ],
        'MENUBAR:FILE:BOOKMARKS:ADD_BOOKMARK' => [
            'Button',
            'Add Bookmark',
            {   '-command' =>
                    [ \&TrEd::Bookmarks::bookmark_actual_position, $grp ],
                '-underline' => 0,
            },
            undef
        ],
        'MENUBAR:FILE:BOOKMARKS:ADD_BOOKMARK_TO_LIST' => [
            'Button',
            'Add Bookmark To List ...',
            {   '-command' => [
                    \&TrEd::ManageFilelists::bookmarkToFilelistDialog, $grp
                ],
                '-underline' => 16
            },
            undef
        ],
        'MENUBAR:FILE:BOOKMARKS:GO_TO_BOOKMARK' =>
            [ 'Cascade', 'Go To Bookmark', { '-underline' => 0 }, undef ],
        'MENUBAR:FILE:BOOKMARKS:PLACE_OF_LAST_ACTION' => [
            'Button',
            'Place of Last Action',
            {   '-command' => [
                    \&TrEd::File::open_standalone_file, $grp,
                    TrEd::Bookmarks::get_last_action()
                ],
                '-state' => (
                    TrEd::Bookmarks::get_last_action() ? 'normal' : 'disabled'
                ),
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:CLOSE' => [
            'Button', 'Close',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        return
                            if TrEd::File::ask_save_file(
                                    $grp->{focusedWindow}, 0, 1 )
                                == $TrEd::File::SAVING_CANCELLED_OR_UNSUCCESSFUL;
                        TrEd::File::close_file( $grp->{focusedWindow},
                            -all_windows => 1 );
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:CLOSE_AND_REMOVE_FROM_FILE_LIST' => [
            'Button',
            'Close and Remove From File List',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        if ( ref $grp->{focusedWindow}->{currentFilelist} ) {
                            my $lr = $grp->{focusedWindow}->{currentFilelist}
                                ->list_ref;
                            if ( scalar @{$lr} ) {
                                TrEd::ManageFilelists::removeFromFilelist(
                                    $grp, undef, undef,
                                    $lr->[
                                        $grp->{focusedWindow}->{currentFileNo}
                                    ]
                                );
                            }
                        }
                        return
                            if TrEd::File::ask_save_file(
                                    $grp->{focusedWindow}, 0, 1 )
                                == $TrEd::File::SAVING_CANCELLED_OR_UNSUCCESSFUL;
                        TrEd::File::close_file( $grp->{focusedWindow},
                            -all_windows => 1 );
                    },
                    $grp
                ],
                '-underline' => 12
            },
            undef
        ],
        'MENUBAR:FILE:CLOSE_IN_WINDOW' => [
            'Button',
            'Close in Window',
            {   '-command'   => [ \&TrEd::File::close_file_in_window, $grp ],
                '-underline' => 9
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS' => [
            'Cascade',
            'File Lists',
            { '-underline' => 5 },
            [   'MENUBAR:FILE:FILE_LISTS:SELECT_FILE_LIST',
                'SEPARATOR',
                'MENUBAR:FILE:FILE_LISTS:NEXT_IN_FILE_LIST',
                'MENUBAR:FILE:FILE_LISTS:PREVIOUS_IN_FILE_LIST',
                'MENUBAR:FILE:FILE_LISTS:GO_TO_FILE_LIST_INDEX',
                'SEPARATOR',
                'MENUBAR:FILE:FILE_LISTS:NEW_FILE_LIST',
                'MENUBAR:FILE:FILE_LISTS:LOAD_FILE_LIST',
                'MENUBAR:FILE:FILE_LISTS:REMOVE_FILE_LISTS',
                'MENUBAR:FILE:FILE_LISTS:EDIT_FILE_LISTS',
                'MENUBAR:FILE:FILE_LISTS:ADD_FILES_TO_DEFAULT_FILE_LIST'
            ]
        ],
        'MENUBAR:FILE:FILE_LISTS:ADD_FILES_TO_DEFAULT_FILE_LIST' => [
            'Checkbutton',
            'Add Files To Default File List',
            {   '-underline' => 0,
                '-variable'  => \$grp->{append_files_to_default_fl}
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:EDIT_FILE_LISTS' => [
            'Button',
            'Manage File Lists ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::Filelist::show_dialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:GO_TO_FILE_LIST_INDEX' => [
            'Button',
            'Go to File List Index ...',
            {   '-command' => [
                    sub {
                        my $to = TrEd::Query::String::new_query(
                            $_[0],
                            'Go To File List Index',
                            'File List Index'
                        );
                        if ( defined $to ) {
                            TrEd::Filelist::Navigation::tie_go_to_file( $_[0],
                                $to );
                        }
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:NEW_FILE_LIST' => [
            'Button',
            'New File List ...',
            {   '-command' => [
                    \&TrEd::ManageFilelists::makeNewFilelist,
                    $grp,
                    \&TrEd::ManageFilelists::selectFilelist
                ],
                '-underline' => 2
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:LOAD_FILE_LIST' => [
            'Button',
            'Load File List ...',
            {   '-command' => [ \&TrEd::ManageFilelists::loadFilelist, $grp ],
                '-underline' => 0,
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:NEXT_IN_FILE_LIST' => [
            'Button',
            'Next in File List',
            {   '-command' =>
                    [ \&TrEd::Filelist::Navigation::tie_next_file, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:PREVIOUS_IN_FILE_LIST' => [
            'Button',
            'Previous in File List',
            {   '-command' =>
                    [ \&TrEd::Filelist::Navigation::tie_prev_file, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:REMOVE_FILE_LISTS' => [
            'Button',
            'Remove File Lists ...',
            {   '-command' =>
                    [ \&TrEd::ManageFilelists::removeFilelistsDialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:FILE_LISTS:SELECT_FILE_LIST' => [
            'Button',
            'Select File List ...',
            {   '-command' =>
                    [ \&TrEd::ManageFilelists::selectFilelistDialog, $grp ],
                '-underline' => 0,
            },
            undef
        ],
        'MENUBAR:FILE:KEPT_IN_MEMORY' => [
            'Cascade',
            'Kept in Memory',
            { '-underline' => 0 },
            undef
        ],
        'MENUBAR:FILE:NEW' => [
            'Cascade',
            'New',
            { '-underline' => 0 },
            [   'MENUBAR:FILE:NEW:FROM_TEMPLATE',
                'MENUBAR:FILE:NEW:BASED_ON_AN_EXISTING_FILE',
                'MENUBAR:FILE:NEW:BASED_ON_CURRENT_FILE'
            ]
        ],
        'MENUBAR:FILE:NEW:BASED_ON_AN_EXISTING_FILE' => [
            'Button',
            'Based on an Existing File ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::File::Open::show_dialog, $grp, 1 ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:FILE:NEW:BASED_ON_CURRENT_FILE' => [
            'Button',
            'Based on Current File ...',
            {   '-command'   => [ \&TrEd::File::new_file_from_current, $grp, 1 ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:FILE:NEW:FROM_TEMPLATE' => [
            'Button',
            'From Template ...',
            {   '-command'   => [ \&newFileFromTemplate, $grp ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:FILE:OPEN' => [
            'Button',
            'Open ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::File::Open::show_dialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:OPEN_URL' => [
            'Button',
            'Open URL ...',
            {   '-command'   => [ \&TrEd::Dialog::URL::show_dialog, $grp ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:FILE:RELOAD' => [
            'Button',
            'Reload',
            {   '-command'   => [ \&TrEd::File::reload_file, $grp ],
                '-underline' => 1
            },
            undef
        ],

        'MENUBAR:FILE:PRINT' => [
            'Button',
            'Print ...',
            {   '-command'   => [ \&printThis, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:QUIT' => [
            'Button', 'Quit',
            {   '-command'   => [ \&quit, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:RECENT' =>
            [ 'Cascade', 'Recent', { '-underline' => 0 }, [] ],
        'MENUBAR:FILE:SAVE' => [
            'Button', 'Save',
            {   '-command' => [
                    sub { TrEd::File::save_file( $_[0]->{focusedWindow} ); },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:FILE:SAVE_AS' => [
            'Button',
            'Save As ...',
            {   '-command' => [
                    sub { TrEd::File::save_file_as( $_[0]->{focusedWindow} ); },
                    $grp
                ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:HELP' => [
            'Cascade',
            'Help ',
            { '-underline' => 0 },
            [   'MENUBAR:HELP:USER_MANUAL',
                'MENUBAR:HELP:TRED_HOME_PAGE',
                'MENUBAR:HELP:EXTENSION_MANUALS',
                'MENUBAR:HELP:LIBRARY_MANUALS',
                'MENUBAR:HELP:COMMAND_LINE_TOOLS',
                'MENUBAR:HELP:KEYBINDINGS',
                'SEPARATOR',
                'MENUBAR:HELP:ABOUT',
                'SEPARATOR',
                'MENUBAR:HELP:DEBUGGING_MESSAGES',
                'MENUBAR:HELP:PROFILER'
            ]
        ],
        'MENUBAR:HELP:ABOUT' => [
            'Button', 'About',
            {   '-command'   => [ \&About, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:COMMAND_LINE_TOOLS' => [
            'Cascade',
            'Command-Line Tools',
            { '-underline' => 0 },
            [   'MENUBAR:HELP:COMMAND_LINE_TOOLS:BN_TUTORIAL',
                'MENUBAR:HELP:COMMAND_LINE_TOOLS:TRED_COMMAND_LINE',
                'MENUBAR:HELP:COMMAND_LINE_TOOLS:BTRED_COMMAND_LINE',
                'MENUBAR:HELP:COMMAND_LINE_TOOLS:NTRED_COMMAND_LIONE'
            ]
        ],
        'MENUBAR:HELP:COMMAND_LINE_TOOLS:BN_TUTORIAL' => [
            'Button',
            'BTrEd Tutorial for PDT 2.0',
            {   '-command' =>
                    [ \&open_url_in_browser, $documentation_dir . '/bn-tutorial.html' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:COMMAND_LINE_TOOLS:BTRED_COMMAND_LINE' => [
            'Button',
            'BTrEd Manual Page',
            {   '-command' =>
                    [ \&open_url_in_browser, $documentation_dir . '/btred.html', ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:COMMAND_LINE_TOOLS:NTRED_COMMAND_LIONE' => [
            'Button',
            'NTrEd Manual Page',
            {   '-command' =>
                    [ \&open_url_in_browser, $documentation_dir . '/ntred.html', ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:COMMAND_LINE_TOOLS:TRED_COMMAND_LINE' => [
            'Button',
            'TrEd Manual Page',
            {   '-command'   => [ \&help_topic, $grp, 'commandline' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES' => [
            'Cascade',
            'Debugging Messages',
            { '-underline' => 0 },
            [   'MENUBAR:HELP:DEBUGGING_MESSAGES:TRED',
                'MENUBAR:HELP:DEBUGGING_MESSAGES:MACROS',
                'MENUBAR:HELP:DEBUGGING_MESSAGES:HOOKS',
                'MENUBAR:HELP:DEBUGGING_MESSAGES:KEYBOARD',
                'MENUBAR:HELP:DEBUGGING_MESSAGES:BACKEND',
                'MENUBAR:HELP:DEBUGGING_MESSAGES:VIEW'
            ]
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:BACKEND' => [
            'Checkbutton',
            'backend',
            {   '-underline' => 0,
                '-variable'  => \$Treex::PML::Debug
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:HOOKS' => [
            'Checkbutton',
            'hooks',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::Config::hookDebug
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:KEYBOARD' => [
            'Checkbutton',
            'keyboard',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::Config::keyboardDebug
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:MACROS' => [
            'Checkbutton',
            'macros',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::Config::macroDebug
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:TRED' => [
            'Checkbutton',
            'tred',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::Config::tredDebug
            },
            undef
        ],
        'MENUBAR:HELP:DEBUGGING_MESSAGES:VIEW' => [
            'Checkbutton',
            'view',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::TreeView::Debug
            },
            undef
        ],
        'MENUBAR:HELP:EXTENSION_MANUALS' =>
            [ 'Cascade', 'Extension Manuals', { '-underline' => 1 }, [] ],
        'MENUBAR:HELP:KEYBINDINGS' => [
            'Cascade',
            'Keybindings',
            { '-underline' => 0 },
            [   'MENUBAR:MACROS:EXAMINE_KEY_BINDINGS',
                'MENUBAR:HELP:KEYBINDINGS:CURRENT_MODE',
                'MENUBAR:HELP:KEYBINDINGS:CURRENT_MODE_AND_TREDMACRO'
            ]
        ],
        'MENUBAR:HELP:KEYBINDINGS:CURRENT_MODE' => [
            'Button',
            'Table of Macros in Current Mode',
            {   '-command'   => [ \&showMacrosAsHtml, $grp, 0, 'N' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:KEYBINDINGS:CURRENT_MODE_AND_TREDMACRO' => [
            'Button',
            'Table of Macros in Current Mode + TredMacro',
            {   '-command'   => [ \&showMacrosAsHtml, $grp, 2, 'N' ],
                '-underline' => 1,
            },
            undef
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS' => [
            'Cascade',
            'Library Manuals',
            { '-underline' => 0 },
            [   'MENUBAR:HELP:LIBRARY_MANUALS:TRED_API',
                'MENUBAR:HELP:LIBRARY_MANUALS:PML_MAK',
                'MENUBAR:HELP:LIBRARY_MANUALS:FSLIB',
                'MENUBAR:HELP:LIBRARY_MANUALS:PMLSCHEMA',
                'MENUBAR:HELP:LIBRARY_MANUALS:PMLINSTANCE'
            ]
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS:FSLIB' => [
            'Button',
            'Treex::PML',
            {   '-command' =>
                    [ \&open_url_in_browser, $documentation_dir . '/Treex::PML.html' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS:PMLINSTANCE' => [
            'Button',
            'Treex::PML::Instance',
            {   '-command' => [
                    \&open_url_in_browser,
                    $documentation_dir . '/Treex::PML::Instance.html'
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS:PMLSCHEMA' => [
            'Button',
            'Treex::PML::Schema',
            {   '-command' => [
                    \&open_url_in_browser,
                    $documentation_dir . '/Treex::PML::Schema.html'
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS:PML_MAK' => [
            'Button',
            'PML.mak',
            {   '-command' =>
                    [ \&open_url_in_browser, $documentation_dir . '/PML_mak.html' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:LIBRARY_MANUALS:TRED_API' => [
            'Button',
            'TrEd API: Pre-Defined Macros',
            {   '-command'   => [ \&help_topic, $grp, 'defaultmacros' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:PROFILER' => [
            'Cascade',
            'Profiler',
            { '-underline' => 0 },
            [ 'MENUBAR:HELP:PROFILER:START', 'MENUBAR:HELP:PROFILER:START' ]
        ],
        'MENUBAR:HELP:PROFILER:START' => [
            'Button', 'Stop',
            {   '-command'   => [ sub { DB::disable_profile(); } ],
                '-underline' => 2
            },
            undef
        ],
        'MENUBAR:HELP:TRED_HOME_PAGE' => [
            'Button',
            'TrEd Home Page',
            {   '-command' => [
                    \&open_url_in_browser,
                    'http://ufal.mff.cuni.cz/tred/'
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:HELP:USER_MANUAL' => [
            'Button',
            'User\'s Manual',
            {   '-command'   => [ \&help_topic, $grp, '_TOC_' ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:MACROS' => [
            'Cascade',
            'Macros',
            { '-underline' => 0 },
            [   'MENUBAR:MACROS:LIST_OF_MACROS',
                'SEPARATOR',
                'MENUBAR:MACROS:CURRENT_MODE',
                'MENUBAR:MACROS:ALL_MODES',
                'SEPARATOR',
                'MENUBAR:MACROS:*_EXTENSION_TOOLS',
                'SEPARATOR',
                'MENUBAR:MACROS:RELOAD_MACROS',
            ]
        ],
        'MENUBAR:MACROS:*_EXTENSION_TOOLS' => [
            'Button', '* Extension Tools',
            { '-state' => 'disabled' }, undef
        ],
        'MENUBAR:MACROS:ALL_MODES' =>
            [ 'Cascade', 'All Modes', { '-underline' => 0 }, [] ],
        'MENUBAR:MACROS:CURRENT_MODE' =>
            [ 'Cascade', 'Current Mode', { '-underline' => 0 }, [] ],
        'MENUBAR:MACROS:EXAMINE_KEY_BINDINGS' => [
            'Button',
            'Examine Key Bindings ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::ExamineBindings::show_dialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:MACROS:LIST_OF_MACROS' => [
            'Button',
            'List Of Macros ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::MacroList::show_dialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:MACROS:RELOAD_MACROS' => [
            'Button',
            'Reload Macros',
            {   '-command'   => [ \&reloadMacros, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:NODE' => [
            'Cascade',
            'Node',
            { '-underline' => 0 },
            [   'MENUBAR:NODE:NEXT',
                'MENUBAR:NODE:PREVIOUS',
                'MENUBAR:NODE:UP_LEVEL',
                'MENUBAR:NODE:DOWN_LEVEL',
                'MENUBAR:NODE:LEFT_SIBLING',
                'MENUBAR:NODE:RIGHT_SIBLING',
                'MENUBAR:NODE:LEFT_ON_LEVEL',
                'MENUBAR:NODE:RIGHT_ON_LEVEL',
                'MENUBAR:NODE:NEXT_IN_ORDER',
                'MENUBAR:NODE:PREVIOUS_IN_ORDER',
                'MENUBAR:NODE:FIRST',
                'MENUBAR:NODE:LAST',
                'SEPARATOR',
                'MENUBAR:NODE:EDIT_NODE_ATTRIBUTES',
                'SEPARATOR',
                'MENUBAR:NODE:NEW_NODE',
                'MENUBAR:NODE:REMOVE_ACTIVE_NODE',
                'MENUBAR:NODE:MAKE_CURRENT_NODE_THE_ROOT',
                'SEPARATOR',
                'MENUBAR:NODE:FIND',
                'MENUBAR:NODE:FIND_NEXT',
                'MENUBAR:NODE:FIND_PREVIOUS'
            ]
        ],
        'MENUBAR:NODE:DOWN_LEVEL' => [
            'Button',
            'Down Level',
            {   '-accelerator' => 'Down',
                '-command'     => [ \&currentDown, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:EDIT_NODE_ATTRIBUTES' => [
            'Button',
            'Edit Node Attributes ...',
            {   '-accelerator' => 'Enter',
                '-command'     => [
                    sub {
                        my ($grp) = @_;
                        if ( $grp->{focusedWindow}->{currentNode} ) {
                            TrEd::Dialog::EditAttributes::show_dialog(
                                $grp->{focusedWindow},
                                $grp->{focusedWindow}->{currentNode} );
                        }
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:NODE:FIND' => [
            'Button',
            'Find ...',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        if ( $grp->{focusedWindow}->{currentNode} ) {
                            TrEd::Dialog::FindNode::show_dialog($grp);
                        }
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:NODE:FIND_NEXT' => [
            'Button',
            'Find Next',
            {   '-command'   => [ \&doFindFirstTemplated, $grp, 1 ],
                '-underline' => 7
            },
            undef
        ],
        'MENUBAR:NODE:FIND_PREVIOUS' => [
            'Button',
            'Find Previous',
            {   '-command'   => [ \&doFindPrevTemplated, $grp, 1 ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:NODE:FIRST' => [
            'Button',
            'First in Order',
            {   '-accelerator' => 'Shift+Home',
                '-command'     => [ \&gotoFirstDisplayedNode, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:LAST' => [
            'Button',
            'Last in Order',
            {   '-accelerator' => 'Shift+End',
                '-command'     => [ \&gotoLastDisplayedNode, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:LEFT_ON_LEVEL' => [
            'Button',
            'Left on Level',
            {   '-accelerator' => 'Shift+Left',
                '-command'     => [ \&currentLeftWholeLevel, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:LEFT_SIBLING' => [
            'Button',
            'Left Sibling',
            {   '-accelerator' => 'Left',
                '-command'     => [
                    sub {
                        my ($grp) = @_;
                        TrEd::Window::TreeBasics::tree_is_reversed($grp)
                            ? currentRight($grp)
                            : currentLeft($grp);
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:NODE:MAKE_CURRENT_NODE_THE_ROOT' => [
            'Button',
            'Make Current Node the Root',
            {   '-command'   => [ \&makeCurrentNodeRoot, $grp ],
                '-underline' => 2
            },
            undef
        ],
        'MENUBAR:NODE:NEW_NODE' => [
            'Button',
            'New Node',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'New Node',
                                TrEd::Undo::undo_type_id('UNDO_ACTIVE_NODE')
                            )
                        );
                        my $new = TrEd::Window::TreeBasics::new_node($win);
                        determineNodeType( $win, $new );
                    },
                    $grp
                ],
                '-underline' => 2
            },
            undef
        ],
        'MENUBAR:NODE:NEXT' => [
            'Button',
            'Next',
            {   '-accelerator' => 'Tab',
                '-command' =>
                    [ sub { currentNext( $_[0]->{focusedWindow} ) }, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:NEXT_IN_ORDER' => [
            'Button',
            'Next in Order',
            {   '-accelerator' => 'Shift+Down',
                '-command'     => [
                    sub {
                        &TrEd::Window::TreeBasics::tree_is_reversed
                            ? &currentLeftLin
                            : &currentRightLin;
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:NODE:PREVIOUS' => [
            'Button',
            'Previous',
            {   '-accelerator' => 'Shift+Tab',
                '-command' =>
                    [ sub { currentPrev( $_[0]->{focusedWindow} ) }, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:PREVIOUS_IN_ORDER' => [
            'Button',
            'Previous in Order',
            {   '-accelerator' => 'Shift+Up',
                '-command'     => [
                    sub {
                        my ($grp) = @_;
                        TrEd::Window::TreeBasics::tree_is_reversed(@_)
                            ? currentRightLin(@_)
                            : currentLeftLin(@_);
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:NODE:REMOVE_ACTIVE_NODE' => [
            'Button',
            'Remove Active Node',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Remove Active Node',
                                ,
                                TrEd::Undo::undo_type_id('UNDO_ACTIVE_ROOT')
                            )
                        );
                        TrEd::Window::TreeBasics::prune_node( $win,
                            $win->{currentNode} );
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:NODE:RIGHT_ON_LEVEL' => [
            'Button',
            'Right on Level',
            {   '-accelerator' => 'Shift+Right',
                '-command'     => [ \&currentRightWholeLevel, $grp ]
            },
            undef
        ],
        'MENUBAR:NODE:RIGHT_SIBLING' => [
            'Button',
            'Right Sibling',
            {   '-accelerator' => 'Right',
                '-command'     => [
                    sub {
                        my ($grp) = @_;
                        TrEd::Window::TreeBasics::tree_is_reversed(@_)
                            ? currentLeft(@_)
                            : currentRight(@_);
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:NODE:UP_LEVEL' => [
            'Button',
            'Up Level',
            {   '-accelerator' => 'Up',
                '-command'     => [ \&currentUp, $grp ]
            },
            undef
        ],
        'MENUBAR:SETUP' => [
            'Cascade',
            'Setup',
            { '-underline' => 0 },
            [   'MENUBAR:SETUP:MANAGE_EXTENSIONS',
                'SEPARATOR',
                'MENUBAR:SETUP:EDIT_STYLESHEET',
                'MENUBAR:SETUP:RELOAD_STYLESHEETS',
                'SEPARATOR',
                'MENUBAR:SETUP:EDIT_CONFIG_FILE',
                'MENUBAR:SETUP:RELOAD_CONFIG_FILE',
                'SEPARATOR',
                'MENUBAR:SETUP:APPEARANCE',
                'MENUBAR:SETUP:FILES_IN_MEMORY'
            ]
        ],
        'MENUBAR:SETUP:APPEARANCE' => [
            'Cascade',
            'Appearance',
            { '-underline' => 0 },
            [   'MENUBAR:SETUP:APPEARANCE:SHOW_HIDDEN_NODES',
                'SEPARATOR',
                'MENUBAR:SETUP:APPEARANCE:STIPPLE_INACTIVE_VIEWS',
                'SEPARATOR',
                'MENUBAR:SETUP:APPEARANCE:CLEAR_TEXT_BACKGROUND',
                'MENUBAR:SETUP:APPEARANCE:DRAW_BOXES_AROUND_LABELS',
                'MENUBAR:SETUP:APPEARANCE:DRAW_BOXES_AROUND_EDGE_LABELS',
                'SEPARATOR',
                'MENUBAR:SETUP:APPEARANCE:PRESERVE_STYLESHEET_ON_FILE_RELOAD',
                'MENUBAR:SETUP:APPEARANCE:SORT_ATTRIBUTES_IN_DIALOGS'
            ]
        ],
        'MENUBAR:SETUP:APPEARANCE:CLEAR_TEXT_BACKGROUND' => [
            'Checkbutton',
            'Clear Text Background',
            {   '-command' => [
                    sub {
                        my $win = $_[0]->{focusedWindow};
                        $win->treeView->set_clearTextBackground(
                            $treeViewOpts->{clearTextBackground} );
                        $win->get_nodes();
                        $win->redraw();
                    },
                    $grp
                ],
                '-underline' => 0,
                '-variable'  => \$treeViewOpts->{clearTextBackground}
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:DRAW_BOXES_AROUND_EDGE_LABELS' => [
            'Checkbutton',
            'Draw Boxes Around Edge Labels',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        ## vice versa setting should be done when focus changes
                        $win->{treeView}->set_drawEdgeBoxes(
                            $treeViewOpts->{drawEdgeBoxes} );
                        $win->get_nodes();
                        $win->redraw();
                    },
                    $grp
                ],
                '-underline' => 1,
                '-variable'  => \$treeViewOpts->{drawEdgeBoxes}
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:DRAW_BOXES_AROUND_LABELS' => [
            'Checkbutton',
            'Draw Boxes Around Labels',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        ## vice versa setting should be done when focus changes
                        my $win = $grp->{focusedWindow};
                        $win->{treeView}
                            ->set_drawBoxes( $treeViewOpts->{drawBoxes} );
                        $win->get_nodes();
                        $win->redraw();
                    },
                    $grp
                ],
                '-underline' => 0,
                '-variable'  => \$treeViewOpts->{drawBoxes}
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:PRESERVE_STYLESHEET_ON_FILE_RELOAD' => [
            'Checkbutton',
            'Preserve Stylesheet on File Reload',
            {   '-underline' => 0,
                '-variable'  => \$TrEd::Config::reloadKeepsPatterns
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:SHOW_HIDDEN_NODES' => [
            'Checkbutton',
            'Show Hidden Nodes',
            {   '-command' => [
                    sub {
                        my $win = $_[0]->{focusedWindow};
                        $win->treeView->set_showHidden(
                            $treeViewOpts->{showHidden} );
                        $win->get_nodes();
                        $win->redraw();
                        $win->ensure_current_is_displayed();
                    },
                    $grp
                ],
                '-underline' => 5,
                '-variable'  => \$treeViewOpts->{showHidden}
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:SORT_ATTRIBUTES_IN_DIALOGS' => [
            'Checkbutton',
            'Sort Attributes in Dialogs',
            {   '-command' => [
                    sub {
                        TrEd::SidePanel::update_attribute_view( $_[0] );
                    },
                    $grp
                ],
                '-underline' => 1,
                '-variable'  => \$TrEd::Config::sortAttrs
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:SORT_ATTRIBUTE_VALUES_IN_DIALOGS' => [
            'Checkbutton',
            'Sort Attribute Values in Dialogs',
            {   '-command' => [
                    sub {
                        TrEd::SidePanel::update_attribute_view( $_[0] );
                    },
                    $grp
                ],
                '-underline' => 1,
                '-variable'  => \$TrEd::Config::sortAttrValues
            },
            undef
        ],
        'MENUBAR:SETUP:APPEARANCE:STIPPLE_INACTIVE_VIEWS' => [
            'Checkbutton',
            'Stipple Inactive Views',
            {   '-command'   => [ \&update_treeviews, $grp ],
                '-underline' => 17,
                '-variable'  => \$TrEd::Config::stippleInactiveWindows
            },
            undef
        ],
        'MENUBAR:SETUP:EDIT_CONFIG_FILE' => [
            'Button',
            'Edit Config File ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::EditConfig::show_dialog, $grp ],
                '-underline' => 5
            },
            undef
        ],
        'MENUBAR:SETUP:EDIT_STYLESHEET' => [
            'Button',
            'Edit Stylesheet ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::EditStylesheet::show_dialog, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:SETUP:FILES_IN_MEMORY' => [
            'Cascade',
            'Files in Memory',
            { '-underline' => 0 },
            [   'MENUBAR:SETUP:FILES_IN_MEMORY:KEEP_THIS_FILE_IN_MEMORY_WHEN_OPENING_A_NEW_ONE',
                'MENUBAR:SETUP:FILES_IN_MEMORY:KEEP_ALL_FILES_IN_MEMORY_WHEN_OPENING_A_NEW_ONE'
            ]
        ],
        'MENUBAR:SETUP:FILES_IN_MEMORY:KEEP_ALL_FILES_IN_MEMORY_WHEN_OPENING_A_NEW_ONE'
            => [
            'Checkbutton',
            'Keep All Files in Memory Until Explicitly Closed',
            {   '-underline' => 0,
                '-variable'  => \$grp->{keepfiles}
            },
            undef
            ],
        'MENUBAR:SETUP:FILES_IN_MEMORY:KEEP_THIS_FILE_IN_MEMORY_WHEN_OPENING_A_NEW_ONE'
            => [
            'Checkbutton',
            'Keep This File in Memory Until Explicitly Closed',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        if ( $win and $win->{FSFile} ) {
                            $win->{FSFile}->changeAppData( 'noautoclose',
                                $grp->{keepcurrentfile} );
                        }
                    },
                    $grp
                ],
                '-underline' => 6,
                '-variable'  => \$grp->{keepcurrentfile}
            },
            undef
            ],
        'MENUBAR:SETUP:MANAGE_EXTENSIONS' => [
            'Button',
            'Manage Extensions ...',
            {   '-command'   => [ \&manage_extensions, $grp, 1 ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:SETUP:RELOAD_CONFIG_FILE' => [
            'Button',
            'Reload Config File',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        read_config();
                        reconfigure($grp);
                        get_nodes_all($grp);
                        redraw_all($grp);
                    },
                    $grp
                ],
                '-underline' => 1,
            },
            undef
        ],
        'MENUBAR:SETUP:RELOAD_STYLESHEETS' => [
            'Button',
            'Reload Stylesheets',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        TrEd::Stylesheet::load_stylesheets($grp);
                        $grp->{StylesheetMenu}->update($grp);
                        foreach my $win ( @{ $grp->{treeWindows} } ) {
                            $win->apply_stylesheet( $win->{stylesheet} );
                        }
                        get_nodes_all($grp);
                        redraw_all($grp);
                    },
                    $grp
                ],
                -underline => 0,
            },
            undef
        ],
        'MENUBAR:TREE' => [
            'Cascade',
            'Tree',
            { '-underline' => 0 },
            [   'MENUBAR:TREE:PREVIOUS_TREE',
                'MENUBAR:TREE:NEXT_TREE',
                'MENUBAR:TREE:GO_TO_TREE_NUMBER',
                'SEPARATOR',
                'MENUBAR:TREE:INSERT_NEW_TREE_BEFORE',
                'MENUBAR:TREE:INSERT_NEW_TREE_AFTER',
                'MENUBAR:TREE:REMOVE_WHOLE_CURRENT_TREE',
                'SEPARATOR',
                'MENUBAR:TREE:MOVE_CURRENT_TREE_BACKWARD',
                'MENUBAR:TREE:MOVE_CURRENT_TREE_FOREWARD',
                'SEPARATOR',
                'MENUBAR:TREE:COPY_TREES'
            ]
        ],
        'MENUBAR:TREE:COPY_TREES' => [
            'Button',
            'Copy Trees ...',
            {   '-command' =>
                    [ \&TrEd::Dialog::CopyTrees::show_dialog, $grp ],
                '-underline' => 1
            },
            undef
        ],
        'MENUBAR:TREE:GO_TO_TREE_NUMBER' => [
            'Button',
            'Go To Tree Number ...',
            {   '-command' => [
                    sub {
                        my $to
                            = TrEd::Query::String::new_query( $_[0],
                            'Go To Tree Number',
                            'Tree Number' );
                        if ( defined $to && $to > 0) {
                            tieGotoTree( $_[0], $to - 1 );
                        }
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:TREE:INSERT_NEW_TREE_AFTER' => [
            'Button',
            'Insert New Tree After',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Insert New Tree After',
                                TrEd::Undo::undo_type_id('UNDO_TREE_ORDER')
                            )
                        );
                        TrEd::Window::TreeBasics::new_tree_after($win);
                        determineNodeType( $win, $win->{root} );
                    },
                    $grp
                ],
                '-underline' => 16
            },
            undef
        ],
        'MENUBAR:TREE:INSERT_NEW_TREE_BEFORE' => [
            'Button',
            'Insert New Tree Before',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Insert New Tree',
                                TrEd::Undo::undo_type_id('UNDO_TREE_ORDER')
                            )
                        );
                        TrEd::Window::TreeBasics::new_tree($win);
                        determineNodeType( $win, $win->{root} );
                    },
                    $grp
                ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:TREE:MOVE_CURRENT_TREE_BACKWARD' => [
            'Button',
            'Move Current Tree Backward',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Move Tree Backward',
                                TrEd::Undo::undo_type_id('UNDO_TREE_ORDER')
                            )
                        );
                        TrEd::Window::TreeBasics::move_tree( $win, -1 );
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:TREE:MOVE_CURRENT_TREE_FOREWARD' => [
            'Button',
            'Move Current Tree Foreward',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Move Tree Foreward',
                                TrEd::Undo::undo_type_id('UNDO_TREE_ORDER')
                            )
                        );
                        TrEd::Window::TreeBasics::move_tree( $win, 1 );
                    },
                    $grp
                ]
            },
            undef
        ],
        'MENUBAR:TREE:NEXT_TREE' => [
            'Button',
            'Next Tree',
            {   '-accelerator' => 'Page Down',
                '-command'     => [ \&tieNextTree, $grp ],
                '-underline'   => 0
            },
            undef
        ],
        'MENUBAR:TREE:PREVIOUS_TREE' => [
            'Button',
            'Previous Tree',
            {   '-accelerator' => 'Page Up',
                '-command'     => [ \&tiePrevTree, $grp ],
                '-underline'   => 0
            },
            undef
        ],
        'MENUBAR:TREE:REMOVE_WHOLE_CURRENT_TREE' => [
            'Button',
            'Remove Whole Current Tree',
            {   '-command' => [
                    sub {
                        my ($grp) = @_;
                        my $win = $grp->{focusedWindow};
                        TrEd::Undo::save_undo(
                            $win,
                            TrEd::Undo::prepare_undo(
                                $win,
                                'Remove Tree',
                                TrEd::Undo::undo_type_id(
                                    'UNDO_CURRENT_TREE_AND_TREE_ORDER')
                            )
                        );
                        TrEd::Window::TreeBasics::prune_tree($win);
                    },
                    $grp
                ],
                '-underline' => 8
            },
            undef
        ],
        'MENUBAR:VIEW' => [
            'Cascade',
            'View',
            { '-underline' => 0 },
            [   'MENUBAR:VIEW:LIST_OF_SENTENCES',
                'SEPARATOR',
                'MENUBAR:VIEW:GUESS_SUITABLE_MODE',
                'MENUBAR:VIEW:SELECT_MODE',
                'MENUBAR:VIEW:SELECT_STYLESHEET',
                'MENUBAR:VIEW:TOGGLE_MINOR_MODES',
                'SEPARATOR',
                'MENUBAR:VIEW:ORIENTATION',
                'SEPARATOR',
                'MENUBAR:VIEW:CLOSE_CURRENT_VIEW',
                'MENUBAR:VIEW:SPLIT_VIEW_HORIZONTALLY',
                'MENUBAR:VIEW:SPLIT_VIEW_VERTICALLY',
                'MENUBAR:VIEW:FOCUS_NEXT_VIEW',
                'MENUBAR:VIEW:FOCUS_PREVIOUS_VIEW',
                'SEPARATOR',
                'MENUBAR:VIEW:SIDE_PANEL'
            ]
        ],
        'MENUBAR:VIEW:CLOSE_CURRENT_VIEW' => [
            'Button',
            'Close Current View',
            {   '-command'   => [ \&removeWindow, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:VIEW:FOCUS_NEXT_VIEW' => [
            'Button',
            'Focus Next View',
            {   '-accelerator' => 'Ctrl+Tab',
                '-command'     => [ \&focusNextWindow, $grp ],
                '-underline'   => 6
            },
            undef
        ],
        'MENUBAR:VIEW:FOCUS_PREVIOUS_VIEW' => [
            'Button',
            'Focus Previous View',
            {   '-accelerator' => 'Ctrl+Shift+Tab',
                '-command'     => [ \&focusPrevWindow, $grp ],
                '-underline'   => 6
            },
            undef
        ],
        'MENUBAR:VIEW:GUESS_SUITABLE_MODE' => [
            'Button',
            'Guess Suitable Mode',
            {   '-command'   => [ \&autoSelectContext, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:VIEW:LIST_OF_SENTENCES' => [
            'Button',
            'List of Sentences ...',
            {   '-command' =>
                    [ \&TrEd::View::Sentence::show_sentences, $grp ],
                '-underline' => 0
            },
            undef
        ],
        'MENUBAR:VIEW:ORIENTATION' => [
            'Cascade',
            'Orientation',
            { '-underline' => 0 },
            [   'MENUBAR:VIEW:ORIENTATION:DEFAULT',
                'MENUBAR:VIEW:ORIENTATION:HORIZONTAL',
                'MENUBAR:VIEW:ORIENTATION:VERTICAL'
            ]
        ],
        'MENUBAR:VIEW:ORIENTATION:DEFAULT' => [
            'Radiobutton',
            'Default',
            {   '-command'   => [ \&_change_orientation, $grp ],
                '-underline' => 0,
                '-value'     => 0,
                '-variable'  => \$treeViewOpts->{displayMode}
            },
            undef
        ],
        'MENUBAR:VIEW:ORIENTATION:HORIZONTAL' => [
            'Radiobutton',
            'Horizontal',
            {   '-command'   => [ \&_change_orientation, $grp ],
                '-underline' => 0,
                '-value'     => -1,
                '-variable'  => \$treeViewOpts->{displayMode}
            },
            undef
        ],
        'MENUBAR:VIEW:ORIENTATION:VERTICAL' => [
            'Radiobutton',
            'Vertical',
            {   '-command'   => [ \&_change_orientation, $grp ],
                '-underline' => 0,
                '-value'     => 1,
                '-variable'  => \$treeViewOpts->{displayMode}
            },
            undef
        ],
        'MENUBAR:VIEW:SELECT_MODE' => [
            'Button',
            'Select Mode ...',
            {   '-command'   => [ \&selectContext, $grp ],
                '-underline' => 7
            },
            undef
        ],
        'MENUBAR:VIEW:SELECT_STYLESHEET' => [
            'Button',
            'Select Stylesheet ...',
            {   '-command'   => [ \&selectStylesheet, $grp ],
                '-underline' => 7
            },
            undef
        ],
        'MENUBAR:VIEW:SIDE_PANEL' => [
            'Checkbutton',
            'Side Panel',
            {   '-command'   => [ \&toggleSidePanel, $grp ],
                '-underline' => 1,
                '-variable'  => \$TrEd::Config::showSidePanel
            },
            undef
        ],
        'MENUBAR:VIEW:SPLIT_VIEW_HORIZONTALLY' => [
            'Button',
            'Split View Horizontally',
            {   '-command'   => [ \&splitWindow, $grp, 'horiz' ],
                '-underline' => 11
            },
            undef
        ],
        'MENUBAR:VIEW:SPLIT_VIEW_VERTICALLY' => [
            'Button',
            'Split View Vertically',
            {   '-command'   => [ \&splitWindow, $grp, 'vert' ],
                '-underline' => 11
            },
            undef
        ],
        'MENUBAR:VIEW:TOGGLE_MINOR_MODES' => [
            'Cascade',
            'Toggle Minor Modes',
            { '-underline' => 0 },
            []
        ],
        'SEPARATOR' => [
            'Separator',
            q{}
        ]
    };
}
