package TrEd::Macros;

use strict;
use warnings;

use Carp;

use Data::Dumper;

BEGIN {
    use Cwd;
    use Treex::PML;
    use File::Spec;
    use File::Glob qw(:bsd_glob);
    use TrEd::Config
        qw($default_macro_file $default_macro_encoding $macroDebug $hookDebug);
    use TrEd::Utils qw{uniq $EMPTY_STR};
    use TrEd::Error::Message;
    use TrEd::Convert;
    use TrEd::File qw{dirname};
    use Encode   ();
    use Exporter ();
    use vars
        qw($VERSION @ISA @EXPORT @EXPORT_OK $exec_code @macros $useEncoding
        $macrosEvaluated $safeCompartment %defines $warnings $strict
        @macro_include_paths
        %keyBindings
        %menuBindings
    );

    use base qw(Exporter);
    $VERSION = "0.2";

    # dont't export unless it's really necessary
    #  %keyBindings
    #  %menuBindings
    @EXPORT = qw(
        &read_macros
        &do_eval_macro
        &do_eval_hook
        &macro_variable
        &get_macro_variable
        &set_macro_variable
        @macros
        $macrosEvaluated
        &get_contexts
        bind_macro
    );

    # can be used from perl 5.8
    $useEncoding = ( $] >= 5.008 );
}

my @current_binding_contexts = qw{TredMacro};

#######################################################################################
# Usage         : define_symbol($name, $value)
# Purpose       : Define symbol with name $name and assigns the value $value to it
# Returns       : Function's second argument -- $value
# Parameters    : scalar $name  -- name of the variable to be defined
#                 scalar $value -- the value that will be assigned to the variable $name
# Throws        : no exception
# Comments      : Information about defines is stored in file-scoped hash %defines
# See Also      : undefine_symbol(), is_defined()
sub define_symbol {
    my ( $name, $value ) = @_;
    $defines{$name} = $value;
    return $value;
}

#######################################################################################
# Usage         : undefine_symbol($name)
# Purpose       : Deletes the definition of symbol $name
# Returns       : The value or values deleted in list context, or the last such element in scalar context
# Parameters    : string $name -- name of the symbol
# Throws        : no exception
# Comments      : ...
# See Also      : define_symbol(), is_defined(), delete()
sub undefine_symbol {
    my ($name) = @_;
    return delete $defines{$name};
}

#######################################################################################
# Usage         : is_defined($name)
# Purpose       : Tell whether symbol $name is defined
# Returns       : True if the symbol $name is defined, false otherwise
# Parameters    : string $name -- name of the symbol
# Throws        : no exception
# Comments      : ...
# See Also      : exists(), define_symbol(), undefine_symbol()
sub is_defined {
    my ($name) = @_;
    return exists $defines{$name};
}

#######################################################################################
# Usage         : get_contexts()
# Purpose       : Returns sorted and uniqued list of contexts, i.e. keys of %menuBindings and %keyBindings hashes
# Returns       : List of contexts
# Parameters    : no parameters
# Throws        : no exception
# Comments      :
# See Also      : %menuBindings, %keyBindings
sub get_contexts {
    return TrEd::Utils::uniq sort { $a cmp $b }
        ( keys %menuBindings, keys %keyBindings );
}

#######################################################################################
# Usage         : _normalize_key($key)
# Purpose       : Normalize the keybinding description
# Returns       : Normalized key description
# Parameters    : string $key -- represents the key combination, e.g. 'Ctrl+X'
# Throws        : no exception
# Comments      : Changes the '-' character to '+' and uppercases modifier keys
sub _normalize_key {
    my ($key) = @_;
    $key =~ s/\-/+/g;                   # convert ctrl-x to ctrl+x
    $key =~ s/([^+]+[+-])/uc($1)/eg;    # uppercase modifiers
    return $key;
}

#######################################################################################
# Usage         : _normalize_macro($context, $macro)
# Purpose       : Test whether the $macro is a valid macro name or reference and construct its name from context and macro name
# Returns       : Normalized macro string that is accepted as $macro in functions
# Parameters    : string $context      -- the context which is used for name construction
#                 string or ref $macro -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : none yet
sub _normalize_macro {
    my ( $context, $macro ) = @_;
    if ( scalar(@_) < 2 ) {
        croak("You must specify both context and macro in _normalize_macro");
    }
    return ( ref($macro) or $macro =~ /^\w+-\>/ )
        ? $macro
        : $context . '->' . $macro;
}

#######################################################################################
# Usage         : bind_key($context, $key, $macro)
# Purpose       : Binds key (combination) $key to macro $macro in $context
# Returns       : nothing
# Parameters    : string $context       -- the context, in which the binding is valid
#                 string $key           -- key or key combination, e.g. 'Ctrl+x'
#                 string or ref $macro  -- macro which will be bound to the key $key
#                                          if $macro is a reference or string like sth->macro,
#                                          then it's used as is,
#                                          otherwise "$context->$macro" is bound to the $key
# Throws        : no exception
# Comments      : Works only if macro is defined
# See Also      : unbind_key(), _normalize_key(), get_bindings_for_macro(), get_binding_for_key()
sub bind_key {
    my ( $context, $key, $macro ) = @_;
    if ( defined($macro) and length($macro) ) {
        if ( !exists( $keyBindings{$context} ) ) {
            $keyBindings{$context} = {};
        }
        $keyBindings{$context}->{ _normalize_key($key) }
            = _normalize_macro( $context, $macro );
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
sub unbind_key {
    my ( $context, $key, $delete ) = @_;
    my $bindings_ref = $keyBindings{$context};
    if ( ref $bindings_ref ) {
        if ($delete) {
            return delete $bindings_ref->{ _normalize_key($key) };
        }
        else {
            $bindings_ref->{ _normalize_key($key) }
                = undef;  # we do not delete so that we may override TrEdMacro
        }
    }
    return;
}

#######################################################################################
# Usage         : unbind_macro($context, $macro, $delete)
# Purpose       : Discards all the bindings for $macro in context $context (if $delete is true, delete it, otherwise set to undef)
# Returns       : nothing
# Parameters    : string $context       -- context in which the binding is being deleted
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
#                 bool $delete          -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : Shouldn't we normalize $macro here as well?
# See Also      : bind_key(), unbind_key(),
sub unbind_macro {
    my ( $context, $macro, $delete ) = @_;
    my $bindings_ref = $keyBindings{$context};
    if ( ref($bindings_ref) ) {
        while ( my ( $key, $m ) = each %{$bindings_ref} ) {
            next if ( $m ne $macro );
            if ($delete) {
                delete $bindings_ref->{$key};
            }
            else {
                # we do not delete so that we may override TrEdMacro
                $bindings_ref->{$key} = undef;
            }
        }
    }
    return;
}

#######################################################################################
# Usage         : get_bindings_for_macro($context, $macro)
# Purpose       : Return all the bindings for macro $macro in the specified $context
# Returns       : Array of the bindings in list context, first binding in scalar context
# Parameters    : string $context       -- context in which to look for the macro bindings
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : Be aware, that the 'first' binding means first one in the hash,
#                 and you can hardly tell, which one that is
#                 Maybe we should normalize $macro here as well...
# See Also      : get_binding_for_key(), bind_key(), unbind_key(), unbind_macro()
sub get_bindings_for_macro {
    my ( $context, $macro ) = @_;
    my $bindings_ref = $keyBindings{$context};
    my @ret;
    if ( ref $bindings_ref ) {
        while ( my ( $key, $m ) = each %{$bindings_ref} ) {
            next if ( $m ne $macro );
            if ( wantarray() ) {
                push( @ret, $key );
            }
            else {
                # if called in scalar context, the internal hash iterator stops 
                # somewhere in the middle of the hash %keyBindings 
                # (if it finds the $macro, of course) and other functions calling each()
                # would not work properly, because they all share 
                # the hash's internal iterator, thus we need to reset it
                keys %{$bindings_ref};
                return $key;
            }
        }
    }
    return @ret;
}

#######################################################################################
# Usage         : get_binding_for_key($context, $key)
# Purpose       : Return the binding for the $key in specified $context
# Returns       : Key binding if defined, undef otherwise
# Parameters    : string $context   -- context for key binding
#                 string $key       -- key or key combination, e.g. 'Ctrl+x'
# Throws        : no exception
# See Also      : unbind_key(), bind_key()
sub get_binding_for_key {
    my ( $context, $key ) = @_;
    my $binding = $keyBindings{$context};
    return ref $binding ? $binding->{ _normalize_key($key) } : undef;
}

#######################################################################################
# Usage         : get_keybindings($context)
# Purpose       : Return hash of key bindings in context $context
# Returns       : Hash of key bindings in context $context if there are any, undef otherwise
# Parameters    : string $context -- context we are examinig
# Throws        : no exception
# Comments      : ...
# See Also      : get_binding_for_key(), bind_key(), unbind_key(), copy_key_bindings()
sub get_keybindings {
    my ($context) = @_;
    my $bindings_ref = $keyBindings{$context};
    return ref $bindings_ref ? %{$bindings_ref} : undef;
}

#######################################################################################
# Usage         : copy_key_bindings($source_context, $destination_context)
# Purpose       : Copy key bindings from one context $source_context to another ($destination_context)
#                 The $destination_context is created, if it does not exist.
# Returns       : Hash reference to destination context's keybindings or undef if $source_context does not exist
#                 (or empty list in array context)
# Parameters    : string $source_context
#                 string $destination_context
# Throws        : no exception
# See Also      : bind_key(), unbind_key(), get_contexts(),
sub copy_key_bindings {
    my ( $source_context, $destination_context ) = @_;
    my $source_bindings_ref = $keyBindings{$source_context};
    return if !ref $source_bindings_ref;
    my $dest_bindings_ref = ( $keyBindings{$destination_context} ||= {} );
    while ( my ( $key, $macro ) = each %{$source_bindings_ref} ) {
        $dest_bindings_ref->{$key} = $macro;
    }
    return $dest_bindings_ref;
}

#######################################################################################
# Usage         : add_to_menu($context, $label, $macro)
# Purpose       : Adds new menu binding to macro $macro with label $label in context $context
# Returns       : nothing
# Parameters    : string $context       -- context for macro $macro
#                 string $label         -- nonempty menu label for the $macro
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : If label is empty, nothing is done, $context is created if it does not exist,
#                 But more interestingly, undef is the second element in anon array, whose first element is
#                 the $macro
# See Also      : remove_from_menu()
sub add_to_menu {
    my ( $context, $label, $macro ) = @_;
    if ( defined $label and length $label ) {
        if ( !exists $menuBindings{$context} ) {
            $menuBindings{$context} = {};
        }
        $menuBindings{$context}->{$label}
            = [ _normalize_macro( $context, $macro ), undef ];
    }
    return;
}

#######################################################################################
# Usage         : remove_from_menu($context, $label)
# Purpose       : Remove menu binding with label $label in specified $context
# Returns       : List of removed elements, i.e. list containing one array reference,
#                 or undef in scalar context if $context or $label in $context does not exist
# Parameters    : string $context -- name of the context
#                 string $label   -- menu label
# Throws        : no exception
# Comments      : Confusion between perl context and macro context in explanation is not very good I guess...
# See Also      : add_menu(), remove_from_menu_macro()
sub remove_from_menu {
    my ( $context, $label ) = @_;
    if ( exists $menuBindings{$context} ) {
        return delete $menuBindings{$context}{$label};
    }
    return;
}

#######################################################################################
# Usage         : remove_from_menu_macro($context, $macro)
# Purpose       : Remove menu binding for macro $macro in specified $context
# Returns       : nothing
# Parameters    : string $context       -- context for macro $macro
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : ...
# See Also      : remove_from_menu(), add_menu()
#TODO: actually it is never used (not even in extensions, nor here)
#TODO: Shall we use _normalize_macro()?
sub remove_from_menu_macro {
    my ( $context, $macro ) = @_;
    my $bindings_ref = $menuBindings{$context};
    if ( ref $bindings_ref ) {
        while ( my ( $key, $array_ref ) = each %{$bindings_ref} ) {
            next if ( $array_ref->[0] ne $macro );
            delete $bindings_ref->{$key};
        }
    }
    return;
}

#######################################################################################
# Usage         : get_menus_for_macro($context, $macro)
# Purpose       : Return all the menus bound to $macro in $context
# Returns       : Array of all menu labels bound with specified $macro in context $context,
#                 or 'first' label in scalar context
# Parameters    : string $context       -- name of the context
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : Be aware, that the 'first' label means first one in the hash,
#                 and you can hardly tell, which one that is
# See Also      : get_macro_for_menu(), add_menu(), remove_from_menu()
#TODO: never actually used...
#TODO: Shouldn't we normalize macro here as well?
sub get_menus_for_macro {
    my ( $context, $macro ) = @_;
    my $bindings_ref = $menuBindings{$context};
    my @ret;
    if ( ref $bindings_ref ) {
        while ( my ( $key, $array_ref ) = each %{$bindings_ref} ) {
            next if ( $array_ref->[0] ne $macro );
            if (wantarray) {
                push @ret, $key;
            }
            else {
                # if called in scalar context, the internal hash iterator 
                # stops somewhere in the middle of the hash %menuBindings
                # (if it finds the $macro, of course) and other functions 
                # calling each() would not work properly, because they all 
                # share the hash's internal iterator, thus we need to reset it
                keys %{$bindings_ref};
                return $key;
            }
        }
    }
    return @ret;
}

#######################################################################################
# Usage         : get_macro_for_menu($context, $label)
# Purpose       : Return macro bound to menu $label in specified $context
# Returns       : Array reference with macro or undef if there is no menu binding with $label in $context
# Parameters    : string $context -- name of the desired context
#                 string $label   -- menu label
# Throws        : no exception
# See Also      : get_menus_for_macro(), get_menuitems(), add_menu(), remove_from_menu()
sub get_macro_for_menu {
    my ( $context, $label ) = @_;
    my $bindings_ref = $menuBindings{$context};
    return ref $bindings_ref ? $bindings_ref->{$label} : undef;

}

#######################################################################################
# Usage         : get_menuitems($context)
# Purpose       : Return all the menu bindings in context $context
# Returns       : Hash of menu bindings, or undef if no menu bindigs exists for specified $context
# Parameters    : string $cotnext -- context searched for menu bindings
# Throws        : no exception
# See Also      : add_to_menu(), remove_from_menu()
sub get_menuitems {
    my ($context) = @_;
    my $menu_bindings_ref = $menuBindings{$context};
    return ref $menu_bindings_ref ? %{$menu_bindings_ref} : undef;
}

#######################################################################################
# Usage         : copy_menu_bindings($source_context, $destination_context)
# Purpose       : Copies menu bindings from $source_context to $destination_context
# Returns       : Hash reference to destination context's menu bindings, or undef if no menu bindings for $source_context exists
# Parameters    : string $source_context      -- string representation (aka name) of source context
#                 string $destination_context -- name of the destination context
# Throws        : no exception
# Comments      : Destination context is created if it does not exist
# See Also      : add_menu(), remove_from_menu(), get_contexts()
sub copy_menu_bindings {
    my ( $source_context, $destination_context ) = @_;
    my $source_bindings_ref = $menuBindings{$source_context};
    return if ( !ref $source_bindings_ref );

    my $dest_bindings_ref = ( $menuBindings{$destination_context} ||= {} );
    while ( my ( $key, $macro_arr ) = each %{$source_bindings_ref} ) {
        $dest_bindings_ref->{$key} = $macro_arr;
    }
    return $dest_bindings_ref;
}

#######################################################################################
# Usage         : _reset_macros();
# Purpose       : Reset key bindings, menu bindings and loaded macros
# Returns       : nothing
# Parameters    : no
# Throws        : no exception
# Comments      :
# See Also      : read_macros()
sub _reset_macros {
    # overwrite key and menu bindings
    %keyBindings  = ();
    %menuBindings = ();
    @macros       = ();
    $exec_code    = undef;
    if ($macroDebug) {
        print STDERR "Reseting key bindings, menu bindings and loaded macros\n";
    }

    return;
}

#######################################################################################
# Usage         : read_macros($file, $libDir, $keep, $encoding, @contexts);
# Purpose       : Read default macros and the specified macro $file using encoding $encoding
# Returns       : nothing
# Parameters    : scalar $file      -- macro file name
#                 scalar $libDir    -- library directory (usually tred/tredlib)
#                 scalar $keep      -- 0/1 -- keep already loaded macros in memory?
#                 scalar $encoding  -- set the encoding of macro file
#                 list @contexts    -- list of contexts returned from preprocess function
# Throws        : no exception
# Comments      : This subroutine reads macro file. Macros are usual perl
#                 subroutines and may use this program's namespace. They are also
#                 provided some special names for certain variables which override
#                 the original namespace.
#                 Macros may be bound to a keysym with a special form of a comment.
#
#                 The synax is:
#
#                   # bind MacroName to key [[Modifyer+]*]KeySym
#
#                 which causes subroutine MacroName to be bound to keyboard event of
#                 simoultaneous pressing the optionally specified Modifyer(s) (which
#                 should be some of Shift, Ctrl and Alt) and the specified KeySym
#                 (this probabbly depends on platform too :( ).
# See Also      : preprocess(), set_encoding()
sub read_macros {
    my ( $file, $libDir, $keep, $encoding, @contexts ) = @_;

    if ( !defined $file ) {
        _reset_macros();
        return;
    }
    $macrosEvaluated = 0;
    if ( !defined($encoding) || $encoding eq "" ) {
        $encoding = $TrEd::Config::default_macro_encoding;
    }
    if ( !@contexts ) {
        @contexts = ('TredMacro');
    }
    if ( !$keep ) {
        _reset_macros();
    }
    if ($macroDebug) {
        print STDERR "Reading $file\n";
    }
    my $macro_filehandle;

    # try to open file
    open $macro_filehandle, '<', $file

        # or to open it from different location
        or ( ! $keep
             && ( $file = "$libDir/$file" )
             && open( $macro_filehandle, '<', $file ) )
        or croak("ERROR: Cannot open macros: $file ($!)!\n");
    set_encoding( $macro_filehandle, $encoding );
    preprocess( $macro_filehandle, $file, \@macros, \@contexts, $libDir );
    close $macro_filehandle
        or croak("ERROR: Cannot close macros: $file ($!)!\n");
    if ( !$keep && $macroDebug ) {
        print STDERR "Read " . scalar(@macros) . " lines of code.\n";
    }
    return;
}

# should handle #bind macro instruction
sub bind_macro {
    my ( $macro, $key, $menu ) = @_;
    $menu = TrEd::Convert::encode($menu);
    if ( defined $menu ) {
        foreach my $context (@current_binding_contexts) {
            add_to_menu( $context, $menu => $macro );
        }
    }
    foreach my $context (@current_binding_contexts) {
        bind_key( $context, $key => $macro );
    }
}

# should handle #binding-context macro instruction
sub set_current_binding_contexts {
    my $contexts = join ' ', @_;
    @current_binding_contexts = split /\s+/, $contexts;
}

#######################################################################################
# Usage         : preprocess($file_handle, $file_name, \@macros, \@contexts, $libDir)
# Purpose       : Preprocess file $file_name, save the results to macros and contexts arrays
#                 Include #includes and #ifincludes respecting #ifdefs, #ifndefs, #elsifs, etc.
# Returns       : nothing
# Parameters    : file_handle $file_handle  -- handle to opened file
#                 string $file_name         -- name of the file whose handle is passed as arg 1
#                 array_ref $macros         -- reference to array storing lines of macro files
#                 array_ref $contexts       -- reference to array storing macro contexts, i.e. TrEd modes
#                 scalar $libDir            -- directory which contains TrEd libraries
# Throws        : a scalar (string) if it fails to include a file or finds unmatched elseif/endif
# Comments      : new "pragmas":
#                   include <file>  ... relative to tred's libdir
#                   include "file"  ... relative to dir of the current macro file
#                   include file    ... absolute or relative to current dir or one of the above
#
#                   ifinclude       ... as include but without producing an error if file doesn't exist
#
#                   binding-context <context> [<context> [...]]
#
#                   key-binding-adopt <contexts>
#                   menu-binding-adopt <contexts>
#
#                   bind <method> [to] [key[sym]] <key> [menu <menu>[/submenu[/...]]]
#
#                   insert <method> [as] [menu] <menu>[/submenu[/...]]
# See Also      : read_macros(),
sub preprocess {
    my ( $file_handle, $file_name, $macros_ref, $contexts_ref, $libDir ) = @_;

# Again, turn off UTF-8 flag for string $file_name, it is used as a comment in macro string
    Encode::_utf8_off($file_name);

    push( @{$macros_ref}, "\n#line 1 \"$file_name\"\n" );
    my $line = 1;
    my @conditions;
    my $ifok = 1;
    while (<$file_handle>) {
        $line++;
        if (/^\#endif(?:$|\s)/) {
            push @{$macros_ref}, $_;
            if (@conditions) {
                pop(@conditions);
                $ifok = ( !@conditions || $conditions[-1] );
            }
            else {
                die "unmatched #endif in \"$file_name\" line $line\n";
            }
        }
        elsif (/^\#elseif\s+(\S*)$|^\#else(?:if)?(?:\s|$)/) {
            if (@conditions) {
                my $prev = ( $#conditions > 0 ) ? $conditions[-2] : 1;
                if ( defined($1) ) {
                    $conditions[-1] 
                        = $prev
                        && !$conditions[-1]
                        && is_defined($1);
                }
                else {
                    $conditions[-1] = $prev && !$conditions[-1];
                }
                $ifok = $conditions[-1];
            }
            else {
                die "unmatched #elseif in \"$file_name\" line $line\n";
            }
        }
        elsif (/^\#ifdef\s+(\S*)/) {
            push @{$macros_ref}, $_;
            push @conditions,
                ( is_defined($1) && ( !@conditions || $conditions[-1] ) );
            $ifok = $conditions[-1];
        }
        elsif (/^\#ifndef\s+(\S*)/) {
            push @{$macros_ref}, $_;
            push @conditions,
                ( !is_defined($1) && ( !@conditions || $conditions[-1] ) );
            $ifok = $conditions[-1];
        }
        else {
            if ($ifok) {
                if (/^\s*__END__/) {
                    last;
                }
                elsif (/^\s*__DATA__/) {
                    warn
                        "Warning: __DATA__ has no meaning in TredMacro (use __END__ instead) at $file_name line $line\n";
                    last;
                }
                push( @{$macros_ref}, $_ );
                if (/^\#!(.*)$/) {
                    if ( !defined $exec_code ) {
                        $exec_code = $1;    # first wins
                    }
                }
                elsif (/^\#define\s+(\S*)(?:\s+(.*))?/) {
                    define_symbol( $1, $2 );   # there is no use for $2 so far
                }
                elsif (/^\#undefine\s+(\S*)/) {
                    undefine_symbol($1);
                }
                elsif (/^\#\s*binding-context\s+(.*)/) {
                    if ($ifok) {
                        @$contexts_ref = ( split /\s+/, $1 );
                    }
                }
                elsif (/^\#\s*key-binding-adopt\s+(.*)/) {
                    my @toadopt = ( split /\s+/, $1 );
                    foreach my $context ( @{$contexts_ref} ) {
                        foreach my $toadopt (@toadopt) {
                            copy_key_bindings( $toadopt, $context );
                        }
                    }
                }
                elsif (/^\#\s*menu-binding-adopt\s+(.*)/) {
                    my @toadopt = ( split /\s+/, $1 );
                    foreach my $context ( @{$contexts_ref} ) {
                        foreach my $toadopt (@toadopt) {
                            copy_menu_bindings( $toadopt, $context );
                        }
                    }
                }
                elsif (/^\#[ \t]*unbind-key[ \t]+([^ \t\r\n]+)/) {
                    my $key = $1;
                    for ( @{$contexts_ref} ) {
                        unbind_key( $_, $key );
                    }
                }
                elsif (
                    /^\#[ \t]*bind[ \t]+(\w+(?:-\>\w+)?)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+([^\r\n]+))?/
                    )
                {
                    my ( $macro, $key, $menu ) = ( $1, $2, $3 );
                    $menu = TrEd::Convert::encode($menu);
                    if ($menu) {
                        for ( @{$contexts_ref} ) {
                            add_to_menu( $_, $menu => $macro );
                        }
                    }
                    for ( @{$contexts_ref} ) {
                        bind_key( $_, $key => $macro );
                    }
                }
                elsif (
                    /^\#\s*insert[ \t]+(\w*)[ \t]+(?:as[ \t]+)?(?:menu[ \t]+)?([^\r\n]+)/
                    )
                {
                    my $macro = $1;
                    my $menu  = TrEd::Convert::encode($2);
                    for ( @{$contexts_ref} ) {
                        add_to_menu( $_, $menu, $macro );
                    }
                }
                elsif (/^\#\s*remove-menu[ \t]+([^\r\n]+)/) {
                    my $menu = TrEd::Convert::encode($1);
                    for ( @{$contexts_ref} ) {
                        remove_from_menu( $_, $menu );
                    }
                }
                elsif (
                    /^\#\s*(if)?include\s+\<([^\r\n]+\S)\>\s*(?:encoding\s+(\S+)\s*)?$/
                    )
                {
                    my $conditional_include
                        = defined($1) && ( $1 eq 'if' ) ? 1 : 0;
                    my $enc = $3;
                    my $f   = $2;

                    # don't include these, they already exist as Perl packages
                    if (   $f =~ m/tred\.mac/
                        || $f =~ m/move_nodes_freely\.inc/ )
                    {
                        warn
                            "\nTrying to #include $f. This is now obsolete. Please just import the namespace instead.\n\n";
                        next;
                    }
                    Encode::_utf8_off($f);
                    my $found;
                    for my $path ( grep defined, $libDir, @macro_include_paths ) {
                        my $mf = "$path/$f";
                        if ( -f $mf ) {
                            read_macros( $mf, $libDir, 1, $enc,
                                @{$contexts_ref} );
                            push @{$macros_ref},
                                "\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
                            $found = 1;
                            last;
                        }
                    }
                    if ( !$found && !$conditional_include ) {
                        die
                            "Error including macros $f\n from $file_name: ",
                            "file not found in search paths: $libDir @macro_include_paths\n";
                    }
                }
                elsif (
                    /^\#\s*(if)?include\s+"([^\r\n]+\S)"\s*(?:encoding\s+(\S+)\s*)?$/
                    )
                {
                    my $enc     = $3;
                    my $pattern = $2;
                    my $if      = defined($1) ? $1 : 0;
                    Encode::_utf8_off($pattern);

                    my @includes;
                    if ( $pattern =~ /^<(.*)>$/ ) {
                        my $glob = $1;
                        my ( $vol, $dir )
                            = File::Spec->splitpath(
                            TrEd::File::dirname($file_name) );
                        $dir = File::Spec->catpath( $vol, $dir );
                        my $cwd = cwd();
                        chdir $dir;
                        @includes
                            = map { File::Spec->rel2abs($_) } glob($glob);
                        chdir $cwd;
                    }
                    else {
                        @includes
                            = ( TrEd::File::dirname($file_name) . $pattern );
                    }
                    foreach my $mf (@includes) {
                        _load_macro( $mf, $enc, $contexts_ref, $macros_ref,
                            $if, $libDir, $file_name, $line );
                    }
                }
                elsif (
                    /^\#\s*(if)?include\s+([^\r\n]+?\S)\s*(?:encoding\s+(\S+)\s*)?$/
                    )
                {
                    my ( $if, $f, $enc ) = ( $1, $2, $3 );
                    Encode::_utf8_off($f);

                    if ( $f =~ m%^/% ) {
                        read_macros( $f, $libDir, 1, $enc, @{$contexts_ref} );

                        push @{$macros_ref},
                            "\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
                    }
                    else {
                        my $mf = $f;
                        print STDERR "including $mf\n" if $macroDebug;
                        unless ( -f $mf ) {
                            $mf = TrEd::File::dirname($file_name) . $mf;
                            print STDERR "trying $mf\n" if $macroDebug;
                            unless ( -f $mf ) {
                                $mf = "$libDir/$f";
                                print STDERR "not found, trying $mf\n"
                                    if $macroDebug;
                            }
                        }
                        _load_macro( $mf, $enc, $contexts_ref, $macros_ref,
                            $if, $libDir, $file_name, $line );
                    }
                }
                elsif (/^\#\s*encoding\s+(\S+)\s*$/) {
                    set_encoding( $file_handle, $1 );
                }
            }
            else {

                # $ifok == 0
                push @{$macros_ref}, "\n";  # only for line numbering purposes
            }
        }
    }
    if (@conditions) {
        die "Missing #endif in $file_name line $line ("
            . scalar(@conditions)
            . " unmatched #if-pragmas)\n";
    }
    return 1;
}

#######################################################################################
# Usage         : _load_macro($mf, $enc, $contexts_ref, $macros_ref, $if, $libDir, $file_name, $line);
# Purpose       : Load macro from file $file_name or die
# Returns       : Undef/empty list
# Parameters    : file handle $mf         -- handle to the macro file
#                 scalar $enc             -- encoding of macro file
#                 array_ref $contexts_ref -- reference to array of contexts
#                 array_ref $macros_ref   -- reference to array of all the lines from macro files
#                 scalar $if              -- is the include conditional? (ifinclude)
#                 scalar $libDir          -- name of the library directory
#                 scaalr $file_name       -- name of macro file
#                 scalar $line            -- number of lines processed in macro file
# Throws        : Dies if $mf is not a file
# Comments      :
sub _load_macro {
    my ( $mf, $enc, $contexts_ref, $macros_ref, $if, $libDir, $file_name,
        $line )
        = @_;

    if ( -f $mf ) {
        read_macros( $mf, $libDir, 1, $enc, @{$contexts_ref} );
        push @{$macros_ref},
            "\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
    }
    elsif ( !defined($if) || $if ne 'if' ) {
        die "Error including macros $mf\n from $file_name: ",
            "file not found!\n";
    }
    return;
}

#######################################################################################
# Usage         : set_encoding($file_handle, [$encoding]);
# Purpose       : Set encoding for file $file_handle to $encoding (or to default_macro_encoding, if no encoding is specified)
# Returns       : nothing
# Parameters    : file handle $file_handle  -- handle to a file
#                 [string $encoding          -- encoding name]
# Throws        : no exception
# Comments      : ':utf8' should only be used for output, using ':encoding(utf8)' instead
sub set_encoding {
    my $fh = shift;
    my $enc = shift || $default_macro_encoding;
    if ( $useEncoding and $enc ) {
        eval {
            $fh->flush();
            binmode $fh;    # first get rid of all I/O layers
            if ( lc($enc) =~ /^utf-?8$/ ) {
                binmode( $fh, ":encoding(utf8)" );
            }
            else {
                binmode( $fh, ":encoding($enc)" );
            }
        };
        print STDERR $@ if $@;
    }
    return;
}

#######################################################################################
# Usage         : initialize_macros($win_ref)
# Purpose       : Initializes macros, run them for the first time either using eval or in safe compartment
# Returns       : Return the result of macro evaluation or 2 if the macros were already evaluated
# Parameters    : hash_ref $win_ref -- see below
# Throws        : no exception
# Comments      : The $win_ref parameter to the following two routines should be
#                 a hash reference, having at least the following keys:
#
#                 FSFile       => FSFile blessed reference of the current FSFile
#                 treeNo       => number of the current tree in the file
#                 macroContext => current context under which macros are run
#
#                 the $win_ref itself is passed to the macro in the $grp variable
#
#                 Macros expect the following (minimally) variables set:
#                 $TredMacro::root    ... root of the current tree
#                 $TredMacro::this    ... current node
#                 $TredMacro::libDir  ... path to TrEd's library directory
#
#                 Macros signal the results of their operation using the following
#                 variables:
#                 $TredMacro::FileNotSaved   ... if 0, macro claims it has done no no changes
#                                that would need saving
#                 $TredMacos::forceFileSaved ... if 1, macro claims it saved the file itself
# See Also      : set_macro_variable()
sub initialize_macros {
    my ($win_ref) = @_;    # $win is a reference
                           # which should in this way be made visible
                           # to macros
    my $result    = 2;     #hm? strange init, return value never actually used
    no warnings;
    if ( not $macrosEvaluated ) {
        my $utf = ($useEncoding) ? "use utf8;\n" : q{};
        my $macros = q{};
        $macros .= 'use strict;' if $strict;
        $macros .= "use warnings; no warnings 'redefine';" if $warnings;
        $macros
            .= "{\n" 
            . $utf
            . join( q{}, map { Encode::_utf8_off($_); $_ } @macros )
            . "\n}; 1;\n";
        print STDERR "FirstEvaluation of macros\n" if $macroDebug;
        if ( defined($safeCompartment) ) {
            set_macro_variable( 'grp', $win_ref );
            my %packages;

            # dirty hack to support ->isa in safe compartment
            $macros =~ s{(\n\s*package\s+(\S+?)\s*;)}
                          {
                            exists($packages{$2}) ? $1 : do { $packages{$2} = 1 ;
                                                              $1.'sub isa {
                                                                            for(@ISA){
                                                                              return 1 if $_ eq $_[1]}
                                                                            }'
                                                            }
                          }ge;
            $macrosEvaluated = 1;
            {
                no strict;
                $result = $safeCompartment->reval($macros);
            }
            TrEd::Error::Message::error_message( $win_ref, $@ ) if $@;
        }
        else {
            no strict;
            ${"TredMacro::grp"} = $win_ref;
            $macrosEvaluated = 1;

            # print "macros: " . $macros . "\n";
            $result = eval {
                my $res = eval($macros);
                die $@ if $@;
                return $res;
            };
        }
        print STDERR "Returned with: $result\n\n" if $macroDebug;
        TrEd::Error::Message::error_message( $win_ref, $@ ) if $@;
    }
    set_macro_variable( 'grp', $win_ref );
    return $result;
}

#######################################################################################
# Usage         : macro_variable($var_name)
# Purpose       : Construct a symbolic reference for getter and setter of macro variables
# Returns       : Name of the variable, either from Safe compartment, or with macro namespace prefix
# Parameters    : string $var_name -- name of the variable
# Throws        : no exception
# Comments      : Symbolic references are kind of deprecated in Perl Best Practices, maybe think up some other way to do this...
#                 although in Safe.pm the implementation is similar...
# See Also      : get_macro_variable(), set_macro_variable()
sub macro_variable {
    my $prefix = ( $_[0] =~ /::/ ) ? q{} : 'TredMacro::';
    if ( defined($safeCompartment) ) {
        return $safeCompartment->varglob( $prefix . $_[0] );
    }
    else {
        return $prefix . $_[0];
    }
}

#######################################################################################
# Usage         : get_macro_variable($var_name)
# Purpose       : Retrieve value of specified macro variable
# Returns       : Value of the macro variable
# Parameters    : string $var_name  -- name of the variable
# Throws        : no exception
# Comments      :
# See Also      : set_macro_variable(), macro_variable()
sub get_macro_variable {
    no strict 'refs';
    return ${&macro_variable};
}

#######################################################################################
# Usage         : set_macro_variable($var_name, $var_value)
# Purpose       : Set macro variable in desired namespace
# Returns       : nothing
# Parameters    : string $var_name  -- name of the variable, e.g. TredMacro::my_variable
#                 scalar $var_value -- value of the var, e.g. 'value_of_var'
# Throws        : no exception
# Comments      :
# See Also      : get_macro_variable(), macro_variable()
sub set_macro_variable {
    no strict 'refs';
    while (@_) {
        ${&macro_variable} = $_[1];
        shift;
        shift;
    }
}

# variables used in macros
my @_saved_vars = qw(grp this root FileNotSaved forceFileSaved);

#######################################################################################
# Usage         : save_ctxt()
# Purpose       : Allow saving current context by returning values of chosen variables
# Returns       : Reference to array with values of selected variables from current context
# Parameters    : no
# Throws        : no exception
# Comments      : selected variables: grp, this, root, FileNotSaved, forceFileSaved
# See Also      : restore_ctxt()
sub save_ctxt {
    no strict 'refs';
    if ( defined($safeCompartment) ) {
        return [
            map ${ $safeCompartment->varglob( 'TredMacro::' . $_ ) },
            @_saved_vars
        ];
    }
    else {
        return [ map ${ 'TredMacro::' . $_ }, @_saved_vars ];
    }
}

#######################################################################################
# Usage         : restore_ctxt($old_context)
# Purpose       : Restore selected context variables from previously saved array reference
# Returns       : nothing
# Parameters    : array_ref $old_context -- context returned from function save_ctxt()
# Throws        : no exception
# Comments      : selected variables: grp, this, root, FileNotSaved, forceFileSaved
# See Also      : save_ctxt()
sub restore_ctxt {
    my $ctxt_ref = shift;
    my $i        = 0;
    no strict 'refs';
    if ( defined($safeCompartment) ) {
        for my $var (@_saved_vars) {
            ${ $safeCompartment->varglob( 'TredMacro::' . $var ) }
                = $ctxt_ref->[ $i++ ];
        }
    }
    else {
        for my $var (@_saved_vars) {
            ${ 'TredMacro::' . $var } = $ctxt_ref->[ $i++ ];
        }
    }
    return;
}

#######################################################################################
# Usage         : do_eval_macro($win_ref, $macro)
# Purpose       : Evaluate macro and pass $win_ref to macro context
# Returns       : The return value of evaluated macro, if macro is not supported
#                 function returns $TredMacro::this in scalar context or a list containing
#                 two zeroes and $TredMacro::this in list context
# Parameters    : hash_ref $win_ref -- for details, see initialize_macros function
#                 scalar $macro     -- name of macro to evaluate or reference to macro function or
#                                      array with function reference as the first element and function arguments as other elements
# Throws        : no exception
# Comments      : Safe compartment accepts only string $macro parameter
# See Also      : initialize_macros(), set_macro_variable()
sub do_eval_macro {
    my ( $win, $macro ) = @_; # $win is a reference
                              # which should in this way be made visible
                              # to macros
                              # hm, this would not work in safe compartment...
    if ( !$macro ) {
        if ( defined $safeCompartment ) {
            my $return_val = $safeCompartment->reval('$TredMacro::this');
            return 0, 0, $return_val;
        }
        else {
            return 0, 0, $TredMacro::this;
        }
    }
    my $result;
    undef $@;
    initialize_macros($win);
    return if $@;

    # not used yet
#    if ( !ref $macro
#        and $macro
#        =~ /^\s*([_[:alpha:]][_[:alnum:]]*)-[>]([_[:alpha:]][_[:alnum:]]*)$/ )
#    {
#        my ( $context, $call ) = ( $1, $2 );
#        if ( context_isa( $context, 'TrEd::Context' ) ) {
#
#            # experimental new-style calling convention
#            $macro = $context . '->global->' . $call;
#        }
#    }
    print STDERR "Running $macro\n" if $macroDebug;
    no warnings; # at least 
    if ( defined $safeCompartment ) {
        set_macro_variable( 'grp', $win );
        my $utf = ($useEncoding) ? "use utf8;\n" : q{};
        $result = $safeCompartment->reval( $utf . $macro );
    }
    elsif ( ref $macro eq 'CODE' ) {
        $result = eval {
            use utf8;
            &$macro();
        };
    }
    elsif ( ref $macro eq 'ARRAY' ) {
        $result = eval {
            use utf8;
            $macro->[0]->( @{$macro}[ 1 .. $#$macro ] );
        };
    }
    else {
        if ($useEncoding) {
            $result = eval( "use utf8;\n" . $macro );
        }
        else {
            $result = eval($macro);
        }
    }
    TrEd::Error::Message::error_message( $win, $@ ) if ($@);
    print STDERR 'Had run: ', $macro, "\n" if $macroDebug;
    print STDERR "Returned with: $result\n" if $macroDebug;
    return $result;
}

#######################################################################################
# Usage         : context_can($context, $sub)
# Purpose       : Determine whether the context $context has a method called $sub
# Returns       : Reference to method called $sub in context $context or undef if there is no such method
# Parameters    : string $context -- Name of the context
#                 string $sub     -- Name of subroutine
# Throws        : no exception
# Comments      : supports using safe compartment
# See Also      : context_isa()
sub context_can {
    my ( $context, $sub ) = @_;
    return if ( !defined($context) );
    if ( defined($safeCompartment) ) {
        no strict;
        return $safeCompartment->reval("\${'${context}::'}{'$sub'}");
    }
    else {

        # needs testing, if it works in Class::Std
        #print "testing $context->$sub\n";
        #    print "$context->$sub?";
        my $sub_ref = eval { $context->can($sub) };
        if ( defined $sub_ref ) {

            #        print " yup: $sub_ref\n";
        }
        else {

            #        print " nope!\n";
        }
        return $sub_ref;

        #    return UNIVERSAL::can($context, $sub);
    }
}

#######################################################################################
# Usage         : context_isa($context, $package)
# Purpose       : Determine whether context $context is in package $package
# Returns       : True if context contains specified package, false otherwise
# Parameters    : string $context -- Name of the context
#                 string $package -- Name of package
# Throws        : no exception
# Comments      : supports using safe compartment (via a nasty hack introduced in initialize_macros)
# See Also      : initialize_macros(), context_can()
sub context_isa {
    my ( $context, $package ) = @_;
    return if ( !defined($context) );
    if ( defined($safeCompartment) ) {
        my $arr_ref = $safeCompartment->reval( '\@' . ${context} . '::ISA' );
        my @list = grep { $_ eq $package } @{$arr_ref};
        return scalar(@list) ? 1 : undef;
    }
    else {

        # needs testing, if it works in Class::Std
        return eval { $context->isa($package) };

        #    return UNIVERSAL::isa($context, $package);
    }
}

#######################################################################################
# Usage         : do_eval_hook($win_ref, $context, $hook, @args)
# Purpose       : Evaluate hook
# Returns       : The result of hook eval or undef if no hook is specified
# Parameters    : hash_ref $win_ref -- see initialize_macros for details
#                 string $context   -- context name
#                 string $hook      -- name of the hook
#                 list @args        -- list of hook arguments
# Throws        : no exception
# See Also      : initialize_macros()
sub do_eval_hook {
    my ( $win, $context, $hook )
        = ( shift, shift, shift );  # $win is a reference
                                    # which should in this way be made visible
                                    # to hooks
    print STDERR "about to run the hook: '$hook' (in $context context)\n"
        if $hookDebug;
    return if not $hook;            # and $TredMacro::this;
    my $utf = ($useEncoding) ? "use utf8;\n" : q{};
    undef $@;
    initialize_macros($win);
    return if $@;
    my $result = undef;


    if ( !context_can( $context, $hook ) ) {
        if ( $context ne "TredMacro"
            && context_can( 'TredMacro', $hook ) )
        {
            $context = "TredMacro";
        }
        else {
            return;
        }
    }
    print STDERR "running hook $context" . '::' . "$hook\n" if $hookDebug;
    if ( defined($safeCompartment) ) {

        #      no strict;
        my $reval_str = $utf . "$context\:\:$hook(@_)";
        $result = $safeCompartment->reval($reval_str);
    }
    else {

        #      no strict;
        $result = eval( $utf . "\&$context\:\:$hook(\@_)" );
    }

    return $result;
}

#TODO: tests, documentation
# macro
sub findMacroDescription {
    my ( $grp_or_win, $macro ) = @_;
    if ( !ref($macro) and $macro =~ /^(.*)->/ ) {
        my $b = $menuBindings{$1};
        my ($desc)
            = grep { ref( $b->{$_} ) and $b->{$_}[0] eq $macro } keys %$b;
        return "$desc ($macro)" if length $desc;
        return "macro $macro";
    }
    else {
        my ( $grp, $win ) = main::grp_win($grp_or_win);
        for my $context (
            TrEd::Utils::uniq( $win->{macroContext}, "TredMacro" ) )
        {
            my $Menus = $menuBindings{$context};
            my %macro_to_menu
                = map { $Menus->{$_}->[0] => $_ } keys %{$Menus};
            my $desc = $macro_to_menu{$macro};
            return $desc . " (inline code)" if defined $desc;
        }
        return "this macro has no description (inline code)";
    }
}

1;

__END__

=head1 NAME


TrEd::Macros - package for handling TrEd's macros


=head1 VERSION

This documentation refers to
TrEd::Macros version 0.2.


=head1 SYNOPSIS

  use TrEd::Macros;



=head1 DESCRIPTION



=head1 SUBROUTINES/METHODS

=over 4



=item * C<TrEd::Macros::define_symbol($name, $value)>

=over 6

=item Purpose

Define symbol with name $name and assigns the value $value to it


=item Parameters

  C<$name> -- scalar $name  -- name of the variable to be defined
  C<$value> -- scalar $value -- the value that will be assigned to the variable $name

=item Comments

Information about defines is stored in file-scoped hash %defines


=item See Also

L<undefine_symbol>,
L<is_defined>,

=item Returns

Function's second argument -- $value


=back


=item * C<TrEd::Macros::undefine_symbol($name)>

=over 6

=item Purpose

Deletes the definition of symbol $name


=item Parameters

  C<$name> -- string $name -- name of the symbol

=item Comments



=item See Also

L<define_symbol>,
L<is_defined>,
L<delete>,

=item Returns

The value or values deleted in list context, or the last such element in scalar context


=back


=item * C<TrEd::Macros::is_defined($name)>

=over 6

=item Purpose

Tell whether symbol $name is defined


=item Parameters

  C<$name> -- string $name -- name of the symbol

=item Comments



=item See Also

L<exists>,
L<define_symbol>,
L<undefine_symbol>,

=item Returns

True if the symbol $name is defined, false otherwise


=back


=item * C<TrEd::Macros::get_contexts()>

=over 6

=item Purpose

Returns sorted and uniqued list of contexts, i.e. keys of %menuBindings and %keyBindings hashes


=item Parameters



=item See Also


=item Returns

List of contexts


=back


=item * C<TrEd::Macros::_normalize_key($key)>

=over 6

=item Purpose

Normalize the keybinding description


=item Parameters

  C<$key> -- string $key -- represents the key combination, e.g. 'Ctrl+X'

=item Comments

Changes the '-' character to '+' and uppercases modifier keys



=item Returns

Normalized key description


=back


=item * C<TrEd::Macros::_normalize_macro($context, $macro)>

=over 6

=item Purpose

Test whether the $macro is a valid macro name or reference and construct its name from context and macro name


=item Parameters

  C<$context> -- string $context      -- the context which is used for name construction
  C<$macro> -- string or ref $macro -- string in the form "sth->$macro" or ref to macro subroutine

=item Comments

none yet



=item Returns

Normalized macro string that is accepted as $macro in functions


=back


=item * C<TrEd::Macros::bind_key($context, $key, $macro)>

=over 6

=item Purpose

Binds key (combination) $key to macro $macro in $context


=item Parameters

  C<$context> -- string $context       -- the context, in which the binding is valid
  C<$key> -- string $key           -- key or key combination, e.g. 'Ctrl+x'
  C<$macro> -- string or ref $macro  -- macro which will be bound to the key $key
                                        if $macro is a reference or string like sth->macro,
                                        then it's used as is, otherwise "$context->$macro" is bound to the $key

=item Comments

Works only if macro is defined


=item See Also

L<unbind_key>,
L<_normalize_key>,
L<get_bindings_for_macro>,
L<get_binding_for_key>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::unbind_key($context, $key, $delete)>

=over 6

=item Purpose

Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)


=item Parameters

  C<$context> -- string $context -- context in which the binding is being deleted
  C<$key> -- string $key     -- key or key combination, e.g. 'Ctrl+x'
  C<$delete> -- bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef

=item Comments


=item See Also

L<bind_key>,
L<get_binding_for_key>,
L<get_bindings_for_macro>,

=item Returns

The result of delete function or undef/empty list, depending on the context


=back


=item * C<TrEd::Macros::unbind_macro($context, $macro, $delete)>

=over 6

=item Purpose

Discards all the bindings for $macro in context $context (if $delete is true, delete it, otherwise set to undef)


=item Parameters

  C<$context> -- string $context       -- context in which the binding is being deleted
  C<$macro> -- string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
  C<$delete> -- bool $delete          -- if set to true, binding is deleted, otherwise the macro is just set to undef

=item Comments

Shouldn't we normalize $macro here as well?


=item See Also

L<bind_key>,
L<unbind_key>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::get_bindings_for_macro($context, $macro)>

=over 6

=item Purpose

Return all the bindings for macro $macro in the specified $context


=item Parameters

  C<$context> -- string $context       -- context in which to look for the macro bindings
  C<$macro> -- string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine

=item Comments

Be aware, that the 'first' binding means first one in the hash,
and you can hardly tell, which one that is
Maybe we should normalize $macro here as well...

=item See Also

L<get_binding_for_key>,
L<bind_key>,
L<unbind_key>,
L<unbind_macro>,

=item Returns

Array of the bindings in list context, first binding in scalar context


=back


=item * C<TrEd::Macros::get_binding_for_key($context, $key)>

=over 6

=item Purpose

Return the binding for the $key in specified $context


=item Parameters

  C<$context> -- string $context   -- context for key binding
  C<$key> -- string $key       -- key or key combination, e.g. 'Ctrl+x'


=item See Also

L<unbind_key>,
L<bind_key>,

=item Returns

Key binding if defined, undef otherwise


=back


=item * C<TrEd::Macros::get_keybindings($context)>

=over 6

=item Purpose

Return hash of key bindings in context $context


=item Parameters

  C<$context> -- string $context -- context we are examinig

=item Comments


=item See Also

L<get_binding_for_key>,
L<bind_key>,
L<unbind_key>,
L<copy_key_bindings>,

=item Returns

Hash of key bindings in context $context if there are any, undef otherwise


=back


=item * C<TrEd::Macros::copy_key_bindings($source_context, $destination_context)>

=over 6

=item Purpose

Copy key bindings from one context $source_context to another ($destination_context).
The $destination_context is created, if it does not exist.

=item Parameters

  C<$source_context> -- string $source_context
  C<$destination_context> -- string $destination_context


=item See Also

L<bind_key>,
L<unbind_key>,
L<get_contexts>,

=item Returns

Hash reference to destination context's keybindings or undef if $source_context does not exist
(or empty list in array context)

=back


=item * C<TrEd::Macros::add_to_menu($context, $label, $macro)>

=over 6

=item Purpose

Adds new menu binding to macro $macro with label $label in context $context


=item Parameters

  C<$context> -- string $context       -- context for macro $macro
  C<$label> -- string $label         -- nonempty menu label for the $macro
  C<$macro> -- string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine

=item Comments

If label is empty, nothing is done, $context is created if it does not exist.
But more interestingly, undef is the second element in anon array, whose first element is
the $macro

=item See Also

L<remove_from_menu>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::remove_from_menu($context, $label)>

=over 6

=item Purpose

Remove menu binding with label $label in specified $context


=item Parameters

  C<$context> -- string $context -- name of the context
  C<$label> -- string $label   -- menu label

=item Comments

Confusion between perl context and macro context in explanation is not very good I guess...


=item See Also

L<add_menu>,
L<remove_from_menu_macro>,

=item Returns

List of removed elements, i.e. list containing one array reference,
or undef in scalar context if $context or $label in $context does not exist

=back


=item * C<TrEd::Macros::remove_from_menu_macro($context, $macro)>

=over 6

=item Purpose

Remove menu binding for macro $macro in specified $context


=item Parameters

  C<$context> -- string $context       -- context for macro $macro
  C<$macro> -- string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine

=item Comments

...


=item See Also

L<remove_from_menu>,
L<add_menu>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::get_menus_for_macro($context, $macro)>

=over 6

=item Purpose

Return all the menus bound to $macro in $context


=item Parameters

  C<$context> -- string $context       -- name of the context
  C<$macro> -- string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine

=item Comments

Be aware, that the 'first' label means first one in the hash,
and you can hardly tell, which one that is

=item See Also

L<get_macro_for_menu>,
L<add_menu>,
L<remove_from_menu>,

=item Returns

Array of all menu labels bound with specified $macro in context $context,
or 'first' label in scalar context

=back


=item * C<TrEd::Macros::get_macro_for_menu($context, $label)>

=over 6

=item Purpose

Return macro bound to menu $label in specified $context


=item Parameters

  C<$context> -- string $context -- name of the desired context
  C<$label> -- string $label   -- menu label


=item See Also

L<get_menus_for_macro>,
L<get_menuitems>,
L<add_menu>,
L<remove_from_menu>,

=item Returns

Array reference with macro or undef if there is no menu binding with $label in $context


=back


=item * C<TrEd::Macros::get_menuitems($context)>

=over 6

=item Purpose

Return all the menu bindings in context $context


=item Parameters

  C<$context> -- string $cotnext -- context searched for menu bindings


=item See Also

L<add_to_menu>,
L<remove_from_menu>,

=item Returns

Hash of menu bindings, or undef if no menu bindigs exists for specified $context


=back


=item * C<TrEd::Macros::copy_menu_bindings($source_context, $destination_context)>

=over 6

=item Purpose

Copies menu bindings from $source_context to $destination_context


=item Parameters

  C<$source_context> -- string $source_context      -- string representation (aka name) of source context
  C<$destination_context> -- string $destination_context -- name of the destination context

=item Comments

Destination context is created if it does not exist


=item See Also

L<add_menu>,
L<remove_from_menu>,
L<get_contexts>,

=item Returns

Hash reference to destination context's menu bindings, or undef if no menu bindings for $source_context exists


=back


=item * C<TrEd::Macros::_read_default_macro_file($encoding, \@contexts);>

=over 6

=item Purpose

Read default macro file in encoding $encoding into package variable @macros


=item Parameters

  C<$encoding> -- string $encoding        -- encoding of the default macro file
  C<\@contexts> -- array_ref $contexts_ref -- reference to array of contexts

=item Comments

Origin: Sub extracted from read_macros to decrease its complexity

Default macro file is set by TrEd::Config and can be configured via tredrc file.
The default 'default macro file' is $libDir/tred.def (where $libDir is set by TrEd::Config, too)

=item See Also

L<read_macros>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::read_macros($file, $libDir, $keep, $encoding, @contexts);>

=over 6

=item Purpose

Read default macros and the specified macro $file using encoding $encoding


=item Parameters

  C<$file> -- scalar $file      -- file name
  C<$libDir> -- scalar $libDir    -- library directory (usually tred/tredlib)
  C<$keep> -- scalar $keep      -- 0/1 -- keep already loaded macros in memory?
  C<$encoding> -- scalar $encoding  -- set the encoding of macro file
  C<@contexts> -- list @contexts    -- list of contexts returned from preprocess function

=item Comments

This subroutine reads macro file. Macros are usual perl

subroutines and may use this program's namespace. They are also
provided some special names for certain variables which override
the original namespace.
Macros may be bound to a keysym with a special form of a comment.

The synax is:
  # bind MacroName to key [[Modifyer+]*]KeySym
which causes subroutine MacroName to be bound to keyboard event of
simoultaneous pressing the optionally specified Modifyer(s) (which
should be some of Shift, Ctrl and Alt) and the specified KeySym
(this probabbly depends on platform too :( ).

=item See Also

L<preprocess>,
L<set_encoding>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::preprocess($file_handle, $file_name, \@macros, \@contexts)>

=over 6

=item Purpose

Preprocess file $file_name, save the results to macros and contexts arrays
Include #includes and #ifincludes respecting #ifdefs, #ifndefs, #elsifs, etc.

=item Parameters

  C<$file_handle> -- file_handle $file_handle  -- handle to opened file
  C<$file_name> -- string $file_name         -- name of the file whose handle is passed as arg 1
  C<\@macros> -- array_ref $macros         -- reference to array storing lines of macro files
  C<\@contexts> -- array_ref $contexts       -- reference to array storing macro contexts, i.e. TrEd modes

=item Comments

new "pragmas":

include <file>  ... relative to tred's libdir
include "file"  ... relative to dir of the current macro file
include file    ... absolute or relative to current dir or one of the above
ifinclude       ... as include but without producing an error if file doesn't exist
binding-context <context> [<context> [...]]
key-binding-adopt <contexts>
menu-binding-adopt <contexts>
bind <method> [to] [key[sym]] <key> [menu <menu>[/submenu[/...]]]
insert <method> [as] [menu] <menu>[/submenu[/...]]

=item See Also

L<read_macros>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::set_encoding($file_handle, [$encoding]);>

=over 6

=item Purpose

Set encoding for file $file_handle to $encoding (or to default_macro_encoding, if no encoding is specified)


=item Parameters

  C<$file_handle> -- file handle $file_handle  -- handle to a file
  C<[$encoding]> -- [string $encoding          -- encoding name]

=item Comments

':utf8' should only be used for output, using ':encoding(utf8)' instead



=item Returns

nothing


=back


=item * C<TrEd::Macros::initialize_macros($win_ref)>

=over 6

=item Purpose

Initializes macros, run them for the first time either using eval or in safe compartment


=item Parameters

  C<$win_ref> -- hash_ref $win_ref -- see below

=item Comments

The $win_ref parameter to the following two routines should be

a hash reference, having at least the following keys:
FSFile       => FSFile blessed reference of the current FSFile
treeNo       => number of the current tree in the file
macroContext => current context under which macros are run
the $win_ref itself is passed to the macro in the $grp variable
Macros expect the following (minimally) variables set:
$TredMacro::root    ... root of the current tree
$TredMacro::this    ... current node
$TredMacro::libDir  ... path to TrEd's library directory
Macros signal the results of their operation using the following
variables:
$TredMacro::FileNotSaved   ... if 0, macro claims it has done no no changes
that would need saving
$TredMacos::forceFileSaved ... if 1, macro claims it saved the file itself

=item See Also

L<set_macro_variable>,

=item Returns

Return the result of macro evaluation or 2 if the macros were already evaluated


=back


=item * C<TrEd::Macros::macro_variable($var_name)>

=over 6

=item Purpose

Construct a symbolic reference for getter and setter of macro variables


=item Parameters

  C<$var_name> -- string $var_name -- name of the variable

=item Comments

Symbolic references are kind of deprecated in Perl Best Practices, maybe think up some other way to do this...
although in Safe.pm the implementation is similar...

=item See Also

L<get_macro_variable>,
L<set_macro_variable>,

=item Returns

Name of the variable, either from Safe compartment, or with macro namespace prefix


=back


=item * C<TrEd::Macros::get_macro_variable($var_name)>

=over 6

=item Purpose

Retrieve value of specified macro variable


=item Parameters

  C<$var_name> -- string $var_name  -- name of the variable


=item See Also

L<set_macro_variable>,
L<macro_variable>,

=item Returns

Value of the macro variable


=back


=item * C<TrEd::Macros::set_macro_variable($var_name, $var_value)>

=over 6

=item Purpose

Set macro variable in desired namespace


=item Parameters

  C<$var_name> -- string $var_name  -- name of the variable, e.g. TredMacro::my_variable
  C<$var_value> -- scalar $var_value -- value of the var, e.g. 'value_of_var'


=item See Also

L<get_macro_variable>,
L<macro_variable>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::save_ctxt()>

=over 6

=item Purpose

Allow saving current context by returning values of chosen variables


=item Parameters


=item Comments

selected variables: grp, this, root, FileNotSaved, forceFileSaved


=item See Also

L<restore_ctxt>,

=item Returns

Reference to array with values of selected variables from current context


=back


=item * C<TrEd::Macros::restore_ctxt($old_context)>

=over 6

=item Purpose

Restore selected context variables from previously saved array reference


=item Parameters

  C<$old_context> -- array_ref $old_context -- context returned from function save_ctxt()

=item Comments

selected variables: grp, this, root, FileNotSaved, forceFileSaved


=item See Also

L<save_ctxt>,

=item Returns

nothing


=back


=item * C<TrEd::Macros::do_eval_macro($win_ref, $macro)>

=over 6

=item Purpose

Evaluate macro and pass $win_ref to macro context


=item Parameters

  C<$win_ref> -- hash_ref $win_ref -- for details, see initialize_macros function
  C<$macro> -- scalar $macro     -- name of macro to evaluate or reference to macro function or
                                    array with function reference as the first element and function arguments as other elements

=item Comments

Safe compartment accepts only string $macro parameter


=item See Also

L<initialize_macros>,
L<set_macro_variable>,

=item Returns

The return value of evaluated macro, if macro is not supported
function returns $TredMacro::this in scalar context or a list containing
two zeroes and $TredMacro::this in list context

=back


=item * C<TrEd::Macros::context_can($context, $sub)>

=over 6

=item Purpose

Determine whether the context $context has a method called $sub


=item Parameters

  C<$context> -- string $context -- Name of the context
  C<$sub> -- string $sub     -- Name of subroutine

=item Comments

supports using safe compartment


=item See Also

L<context_isa>,

=item Returns

Reference to method called $sub in context $context or undef if there is no such method


=back


=item * C<TrEd::Macros::context_isa($context, $package)>

=over 6

=item Purpose

Determine whether context $context is in package $package


=item Parameters

  C<$context> -- string $context -- Name of the context
  C<$package> -- string $package -- Name of package

=item Comments

supports using safe compartment (via a nasty hack introduced in initialize_macros)


=item See Also

L<initialize_macros>,
L<context_can>,

=item Returns

True if context contains specified package, false otherwise


=back


=item * C<TrEd::Macros::do_eval_hook($win_ref, $context, $hook, @args)>

=over 6

=item Purpose

Evaluate hook


=item Parameters

  C<$win_ref> -- hash_ref $win_ref -- see initialize_macros for details
  C<$context> -- string $context   -- context name
  C<$hook> -- string $hook      -- name of the hook
  C<@args> -- list @args        -- list of hook arguments


=item See Also

L<initialize_macros>,

=item Returns

The result of hook eval or undef if no hook is specified


=back




=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Carp, Cwd, Treex::PML, File::Spec, File::Glob, TrEd::Config, TrEd::Utils, TrEd::Convert, Encode, Exporter


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
