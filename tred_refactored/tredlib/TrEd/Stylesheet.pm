package TrEd::Stylesheet;

use strict;
use warnings;

use 5.008;
use strict;
use warnings;

use Carp;
use List::Util qw(first min max);
use File::Spec;
use URI::Escape;
use Treex::PML::Schema::CDATA;
require Exporter;

use TrEd::Utils qw{$EMPTY_STR};

use base qw(Exporter);
use vars qw(@stylesheet_paths $default_stylesheet_path);
use constant {
    STYLESHEET_FROM_FILE => "<From File>",
    NEW_STYLESHEET       => "<New From Current>",
    DELETE_STYLESHEET    => "<Delete Current>",
};

our %EXPORT_TAGS = (
    'all' => [
        qw(
            load_stylesheets
            init_stylesheet_paths
            read_stylesheets
            save_stylesheets
            remove_stylesheet_file
            read_stylesheet_file
            save_stylesheet_file
            get_stylesheet_patterns
            set_stylesheet_patterns

            STYLESHEET_FROM_FILE
            NEW_STYLESHEET
            DELETE_STYLESHEET

            )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT    = qw(  );
our $VERSION   = '0.01';

my @stylesheet_paths        = ();
my $default_stylesheet_path = q{};

sub add_stylesheet_paths {
    push @stylesheet_paths, @_;
}

sub _replace_stylesheet_paths {
    my (@new_stylesheet_paths) = @_;
    @stylesheet_paths = @new_stylesheet_paths;
}

sub stylesheet_paths {
    return @stylesheet_paths;
}

sub default_stylesheet_path {
    return $default_stylesheet_path;
}

######################################################################################
# Usage         : save_stylesheet_file(\%gui, $file_name, $dir_name)
# Purpose       : Save stylesheet $name to file $name under directory $dir_name or
#                 call save_stylesheets() if $dir is a file, not a directory
# Returns       : Zero if the directory could not be created or the file could not be opened for writing
# Parameters    : hash_ref $gui_ref -- hash should contain subkey 'stylesheets', subkeys of 'stylesheets' are the names of the stylesheets
#                                      these should contain 3 subkeys: 'context', 'hint', 'patterns'. First two are strings, the last one
#                                      should be an array_ref containing other stylesheet items
#                 string $file_name -- both the name of the stylesheet file and the subkey in %gui hash
#                 string $dir_name  -- the stylesheet will be saved to the directory $dir_name (if not specified, default directory is used)
# Throws        : no exceptions
# Comments      :
# See Also      : save_stylesheets()
sub save_stylesheet_file {
    my ( $gui_ref, $name, $dir ) = @_;
    $dir ||= $default_stylesheet_path;
    if ( -f $dir ) {

        # old interface
        return save_stylesheets( $gui_ref, $dir );
    }
    if ( !-d $dir ) {
        mkdir $dir || do {
            carp("Cannot create styleheet directory: $dir: $!");
            return 0;
        };
    }
    my $stylesheet_file
        = File::Spec->catfile( $dir, URI::Escape::uri_escape_utf8($name) );
    open( my $f, '>:encoding(utf8)', $stylesheet_file ) || do {
        carp("Cannot write to stylesheet file: $stylesheet_file: $!\n");
        return 0;
    };
    my $current_stylesheet = $gui_ref->{"stylesheets"}->{$name};

    # print context
    if ( defined( $current_stylesheet->{"context"} )
        and $current_stylesheet->{"context"} =~ /\S/ )
    {

        # context is valid
        # get rid of leading and trailing whitespace
        $current_stylesheet->{"context"} =~ s/^\s+|\s+$//g;
        print $f "context: " . $current_stylesheet->{"context"} . "\n";
    }

    # print patterns
    if ( ref( $current_stylesheet->{"patterns"} ) ) {
        print $f map { /\n\s*$/ ? $_ : $_ . "\n" }
            @{ $current_stylesheet->{"patterns"} };
    }

    # print hint
    if ( defined( $current_stylesheet->{"hint"} )
        and length( $current_stylesheet->{"hint"} ) )
    {
        print $f "\nhint:" . $current_stylesheet->{"hint"};
    }
    close $f;
    return;
}

######################################################################################
# Usage         : read_stylesheet_file(\%gui, $stylesheet_file[, \%opts])
# Purpose       : Load options from $stylesheet_file to \%gui hash_reference
# Returns       : Sub-hash of %gui: gui{"stylesheets"}{$file_name} or
#                 undef if stylesheet_file could not be opened or
#                 if %opts{"no_overwrite"} is set and %gui{"stylesheets"}{$file_name} has already been defined
# Parameters    : hash_ref $gui_ref,
#                 string $stylesheet_file,
#                 [hash_ref $opts_ref]
# Throws        : no exceptions
# Comments      :
# See Also      : read_stylesheets(), split_patterns()
sub read_stylesheet_file {
    my ( $gui_ref, $stylesheet_file, $opts_ref ) = @_;
    $opts_ref ||= {};
    my ( undef, undef, $f ) = File::Spec->splitpath($stylesheet_file);
    my $name = URI::Escape::uri_unescape($f);
    my $ss_ref = $gui_ref->{"stylesheets"} ||= {};
    return
        if $opts_ref->{"no_overwrite"}
            and grep {/^\Q$name\E$/i} keys %{$ss_ref};
    open my $filehandle, '<:encoding(utf8)', $stylesheet_file || do {
        carp("cannot read stylesheet file: $stylesheet_file: $!\n");
        return;
    };
    my $s_ref = $ss_ref->{$name} ||= {};
    local $/;
    ( $s_ref->{"hint"}, $s_ref->{"context"}, $s_ref->{"patterns"} )
        = split_patterns(<$filehandle>);
    close $filehandle;
    return $s_ref;
}

sub remove_stylesheet_file {
    my ( $gui, $path, $name ) = @_;
    if ( -d $path ) {
        my $stylesheetFile = File::Spec->catfile( $path,
            URI::Escape::uri_escape_utf8($name) );
        if ( -f $stylesheetFile ) {
            delete $gui->{stylesheets}->{$name};
            unlink $stylesheetFile . '~';
            rename $stylesheetFile, $stylesheetFile . '~';
        }
    }
    elsif ( -f $path ) {
        delete $gui->{stylesheets}->{$name};
        save_stylesheets( $gui, $path );
    }
    return;
}

######################################################################################
# Usage         : save_stylesheets(\%gui, $destination)
# Purpose       : Save stylesheets from the hash reference \%gui to $destination on the hdd
# Returns       : Zero if the destination directory could not be created or if the file could not be opened
#                 Returns the return value of save_stylesheet_file() or close() function otherwise.
# Parameters    : hash_ref $gui_ref   -- reference to hash that contains stylesheets,
#                 string $destination -- name of the file or directory (default used if no directory is given)
# Throws        : no exceptions
# Comments      : Supports both new and old stylesheets.
#                 Default stylesheet path is directory '.tred.d/stylesheets' under user's home directory
# See Also      : save_stylesheet_file()
sub save_stylesheets {
    my ( $gui, $where ) = @_;
    $where ||= $default_stylesheet_path;
    if ( -d $where || !-e $where ) {
        if ( !-d $where ) {
            mkdir $where || do {
                carp("cannot create stylesheet directory: $where: $!\n");
                return 0;
            };
        }
        foreach my $stylesheet ( keys( %{ $gui->{"stylesheets"} } ) ) {
            next if ( $stylesheet eq STYLESHEET_FROM_FILE() );
            save_stylesheet_file( $gui, $stylesheet, $where );
        }
    }
    else {

        # $where is not a directory, and it is a file
        open( my $f, '>:encoding(utf8)', $where ) || do {
            carp("cannot write to stylesheet file: $where: $!\n");
            return 0;
        };

        # obsolete way -- write all stylesheets into one file
        foreach my $stylesheet ( sort keys( %{ $gui->{"stylesheets"} } ) ) {
            next if ( $stylesheet eq STYLESHEET_FROM_FILE() );
            print $f "#" x 50, "\n";
            print $f "stylesheet: $stylesheet\n";
            for ( $gui->{"stylesheets"}->{$stylesheet} ) {
                if ( $_->{"context"} =~ /\S/ ) {
                    print $f map { "context: " . $_ . "\n" } split /\n/,
                        $_->{"context"};
                }
                print $f map {
                               my $pattern = $_;
                               $pattern =~ tr/\n/\013/;
                               $pattern . "\n"
                             }
                         map { /^#/ ? 'node:' . $_ : $_ }
                         @{ $_->{patterns} };
                print $f map { 'hint:' . $_ . "\n" }
                         split /\n/, $_->{"hint"};
            }
            print $f "\n\n";
        }
        close $f;
    }
    return;
}

######################################################################################
# Usage         : read_stylesheets(\%gui, $file[, $options])
# Purpose       : Calls _read_stylesheets_old if $file is a regular file,
#                 Calls _read_stylesheets_new if $file is a directory.
# Returns       : Return value from the called function
# Parameters    : hash_ref $gui_ref,
#                 string $file_name,
#                 [hash_ref $opts_ref]
# Throws        : no exceptions
# Comments      :
# See Also      : _read_stylesheets_new(), _read_stylesheets_old()
sub read_stylesheets {
    my ( $gui_ref, $file, $opts_ref ) = @_;
    if ( -f $file ) {
        return _read_stylesheets_old( $gui_ref, $file, $opts_ref );
    }
    elsif ( -d $file ) {
        return _read_stylesheets_new( $gui_ref, $file, $opts_ref );
    }
}

######################################################################################
# Usage         : _read_stylesheets_new(\%gui, $dir_name, \%opts)
# Purpose       : Load all the stylesheets in the $dir_name directory into %gui hash
# Returns       : Zero if the $dir_name could not be opened, 1 otherwise
# Parameters    : hash_ref $gui_ref,
#                 string $dir_name,
#                 hash_ref $opts_ref
# Throws        : no exceptions
# Comments      : Skips files with names starting with '#', '.', or ending with '#', '~'
# See Also      : read_stylesheets()
sub _read_stylesheets_new {
    my ( $gui_ref, $dir, $opts_ref ) = @_;
    $opts_ref ||= {};
    opendir( my $dh, $dir ) || do {
        carp("Can not read stylesheet directory: '$dir'\n $!\n");
        return 0;
    };
    $gui_ref->{"stylesheets"} = {}
        unless $opts_ref and $opts_ref->{"no_overwrite"};
    while ( my $file = readdir($dh) ) {

   # skip files with names starting with '#' and '.' or ending with '#' or '~'
        next if $file =~ /~$|^#|#$|^\./;
        my $stylesheet_file = File::Spec->catfile( $dir, $file );
        next unless -f $stylesheet_file;
        read_stylesheet_file( $gui_ref, $stylesheet_file, $opts_ref );
    }
    return 1;
}

######################################################################################
# Usage         : _read_stylesheets_old(\%gui, $filename[, \%opts])
# Purpose       : Load old-style stylesheets from stylesheet file into %gui hash
# Returns       : If the file could not be opened, returns 0,
#                 1 otherwise
# Parameters    : hash_ref $gui_ref,
#                 string $filename,
#                 [hash_ref $opts_ref]
# Throws        : no exceptions
# Comments      : Changed :utf8 to :encoding(utf8), see
#                 http://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8#Input_-_Files.2C_File_Handles
# See Also      : _read_stylesheets_new(), read_stylesheets()
sub _read_stylesheets_old {
    my ( $gui_ref, $filename, $opts_ref ) = @_;
    open( my $f, '<:encoding(utf8)', $filename ) || do {
        carp("No stylesheet file: '$filename'\n");
        return 0;
    };

    my $stylesheet = "Default";
    $gui_ref->{"stylesheets"} = {}
        unless $opts_ref and $opts_ref->{"no_overwrite"};
    while (<$f>) {

        # remove whitespace at the end of line
        s/\s+$//;

        # continue only if there are any non-whitespace characters left
        next unless /\S/;

        # skip lines starting with '#' (comments)
        next if /^#/;
        if (/^stylesheet:\s*(.*)/) {
            $stylesheet = $1;
        }
        elsif (s/^(hint|context)://) {
            my $hint_context = $gui_ref->{"stylesheets"}->{$stylesheet}->{$1};
            if ( defined $hint_context && $hint_context ne $EMPTY_STR ) {
                $gui_ref->{"stylesheets"}->{$stylesheet}->{$1} .= "\n" . $_;
            }
            else {
                $gui_ref->{"stylesheets"}->{$stylesheet}->{$1} .= $_;
            }
        }
        else {
            tr/\013/\n/;
            push @{ $gui_ref->{stylesheets}->{$stylesheet}->{patterns} }, $_;
        }
        foreach my $stylesheet_item (qw(hint context)) {
            if (exists $gui_ref->{"stylesheets"}{$stylesheet}
                {$stylesheet_item} )
            {
                chomp $gui_ref->{"stylesheets"}{$stylesheet}
                    {$stylesheet_item};
            }
        }
    }
    close $f;
    return 1;
}

# was main::getStylesheetPatterns
sub get_stylesheet_patterns {
    my ( $win, $stylesheet ) = @_;
    my ( $hint, $context, $patterns );
    $patterns = [];
    $stylesheet = $win->{stylesheet} unless defined $stylesheet;
    if ( $stylesheet eq STYLESHEET_FROM_FILE() ) {
        if ( $win->{FSFile} ) {
            $hint      = $win->{FSFile}->hint();
            $context   = undef;
            @$patterns = $win->{FSFile}->patterns();
        }
        else {
            return ();
        }
    }
    else {
        my $s = $win->{framegroup}->{stylesheets}->{$stylesheet};
        if ( ref($s) ) {
            $hint    = $s->{hint};
            $context = $s->{context};
            $context = '.*' unless ( wantarray or $context =~ /\S/ );
            chomp $context;
            @$patterns = defined( $s->{patterns} ) ? @{ $s->{patterns} } : ();
        }
        else {
            return ();
        }
    }

    # try to fix old non-labeled patterns
    @$patterns = map { /^([a-z]+):/ ? $_ : "node: " . $_ } @$patterns;
    return wantarray
        ? ( $hint, $context, $patterns )
        : (
              "context: "
            . $context . "\n"
            .

            # fix old non-labeled hints
            join( "\n", "hint: " . $hint ) . "\n" . join( "\n", @$patterns )
        );
}

# was main::setStylesheetPatterns
sub set_stylesheet_patterns {
    my ( $win, $text, $stylesheet, $create ) = @_;
    my $grp = $win->{framegroup};
    my ( $hint, $context, $patterns );
    if ( ref($text) ) {
        ( $hint, $context, $patterns ) = @{$text};
    }
    else {
        ( $hint, $context, $patterns ) = split_patterns($text);
    }
    $stylesheet = $win->{stylesheet} unless defined $stylesheet;
    if ( $stylesheet eq STYLESHEET_FROM_FILE() ) {
        if ( $win->{FSFile} ) {
            $win->{FSFile}->changeHint($hint);
            $win->{FSFile}->changePatterns(@$patterns);
        }
        else {
            return 0;
        }
    }
    else {
        my $s = $grp->{stylesheets}->{$stylesheet};
        if ( ref($s) ) {
            @{ $s->{patterns} } = @$patterns;
            $s->{hint}    = $hint;
            $s->{context} = $context;
        }
        elsif ($create) {
            $grp->{stylesheets}->{$stylesheet}->{patterns} = [@$patterns];
            $grp->{stylesheets}->{$stylesheet}->{hint}     = $hint;
            $grp->{stylesheets}->{$stylesheet}->{context}  = $context;
            $grp->{StylesheetMenu}->update($grp);
        }
        else {
            return 0;
        }
    }
    return 1;
}

######################################################################################
# Usage         : split_patterns($text)
# Purpose       : Parse stylesheet text and divide it into hints, context and other patterns
# Returns       : List of 3 items: two strings (hints and context)
#                 and a referrence to array (containing other patterns)
# Parameters    : string $text -- contents of the stylesheet
# Throws        : no exceptions
# Comments      :
# See Also      : read_stylesheet_file()
#TODO: is the format of stylesheet formally defined somewhere?
sub split_patterns {
    my ($text) = @_;
    my @lines = defined $text ? split( /(\n)/, $text ) : ();
    my @result;
    my $pattern = $EMPTY_STR;
    my $hint    = $EMPTY_STR;
    my $context;
    while (@lines) {
        my $line = shift(@lines);

        # line starts with at least one small letter (a-z) followed by ':'
        if ( $line =~ /^([a-z]+):/ ) {

            # pattern contains non-whitespace character
            if ( $pattern =~ /\S/ ) {
                chomp($pattern);
                if ( $pattern =~ s/^hint:\s*// ) {

                    # 'hint' processing
                    if ( $hint ne $EMPTY_STR ) {
                        $hint .= "\n";
                    }
                    $hint .= $pattern;
                }
                elsif ( $pattern =~ s/^context:\s*// ) {

                    # 'context' processing
                    $context = $pattern;
                    chomp($context);
                }
                else {

                    # other patterns than hint or context
                    push( @result, $pattern );
                }
            }
            $pattern = $line;
        }
        else {
            $pattern .= $line;
        }
    }

    # process the last line
    # but the code ignores context on the last line...
    if ( $pattern =~ /\S/ ) {
        chomp $pattern;
        if ( $pattern =~ s/^hint:\s*// ) {
            $hint .= "\n" if $hint ne $EMPTY_STR;
            $hint .= $pattern;
        }
        else {
            push( @result, $pattern );
        }
    }
    return ( $hint, $context, \@result );
}

######################################################################################
# Usage         : init_stylesheet_paths(\@custom_stylesheets_paths)
# Purpose       : Set the @stylesheet_paths and $default_stylesheet_path variable
#                 according to the environment and argument @custom_stylesheets_paths
# Returns       : nothing
# Parameters    : list_ref $list_ref -- list of custom stylesheet paths
# Throws        : no exceptions
# Comments      : If valid @user_paths list is passed, this list is 'uniqued' and
#                 put before the default path in the @stylesheet_paths array.
#                 If ~/.tred-stylesheets is an ordinary file, directory ~/.tred.d/stylesheets is created and
#                 new stylesheets are created in this new directory from old tred-stylesheets file.
#                 The $default_stylesheet_path is ~/.tred-stylesheets, this is changed to
#                 ~/.tred.d/stylesheets/ if the conversion from old to new stylesheets happened or
#                 it changes to the first item in @stylesheet_paths if user defined any custom paths.
# See Also      : read_stylesheets(), save_stylesheets()
sub init_stylesheet_paths {
    my ($user_paths) = @_;

    $default_stylesheet_path = $ENV{HOME} . "/.tred-stylesheets";
    my $stylesheet_dir
        = File::Spec->catfile( $ENV{HOME}, '.tred.d', 'stylesheets' );
    if ( !-d $stylesheet_dir && -f $default_stylesheet_path ) {
        print STDERR
            "Converting old stylesheets from $default_stylesheet_path to $stylesheet_dir...\n";
        my $gui_ref = { stylesheets => {} };
        read_stylesheets( $gui_ref, $default_stylesheet_path );
        if ( mkdir $stylesheet_dir ) {
            save_stylesheets( $gui_ref, $stylesheet_dir );
            print STDERR "done.\n";
        }
        else {
            carp("failed to create $stylesheet_dir: $!.\n");
            $stylesheet_dir = $default_stylesheet_path;
        }
    }
    if ( -d $stylesheet_dir ) {
        $default_stylesheet_path = $stylesheet_dir;
    }
    my %uniq;
    if ( ref $user_paths && @{$user_paths} ) {
        my @nonempty_user_paths
            = map { length($_) ? $_ : ($default_stylesheet_path) }
            @$user_paths;
        @stylesheet_paths = grep { !( $uniq{$_}++ ) }
            ( @nonempty_user_paths, @stylesheet_paths );
        $default_stylesheet_path = $stylesheet_paths[0];
    }
    else {
        @stylesheet_paths = grep { !( $uniq{$_}++ ) }
            ( $default_stylesheet_path, @stylesheet_paths );
    }
}

# was TrEd::Utils::loadStyleSheets
sub load_stylesheets {
    my ($gui) = @_;
    my $later = 0;
    for my $p (@stylesheet_paths) {
        read_stylesheets( $gui, $p, { no_overwrite => $later } );
        $later = 1;
    }
}

# was main::deleteStylesheet
sub delete_stylesheet {
    my ( $grp, $stylesheet ) = @_;
    remove_stylesheet_file( $grp, $default_stylesheet_path, $stylesheet );
    $grp->{StylesheetMenu}->update($grp);
    foreach my $win ( main::windows_using_stylesheet( $grp, $stylesheet ) ) {
        if ( $grp->{focusedWindow} == $win ) {
            $grp->{selectedStylesheet} = STYLESHEET_FROM_FILE();
        }
        $win->apply_stylesheet( STYLESHEET_FROM_FILE() );
        if ( $win->{FSFile} ) {
            $win->get_nodes();
            $win->redraw();
        }
    }
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
