package TrEd::Config;

#
# $Id: Config.pm 4498 2010-10-14 15:34:37Z fabip4am $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use strict;
use warnings;
use File::Spec;
use Cwd;

BEGIN {
    use vars
        qw($VERSION @ISA @EXPORT @EXPORT_OK @config_file_search_list $quiet);
    use Exporter ();
    use base qw(Exporter);

    $VERSION = "0.2";
    @EXPORT  = qw(@config_file_search_list $set_user_config $override_options
        $appName
        $buttonsRelief
        $menubarRelief
        $buttonBorderWidth
        $canvasBalloonInitWait
        $canvasBalloonForeground
        $canvasBalloonBackground
        $toolbarBalloonInitWait
        $toolbarBalloonForeground
        $toolbarBalloonBackground
        $activeTextColor
        $treeViewOpts
        $font
        $guiFont
        $vLineFont
        $libDir
        $extensionsDir
        $preinstalledExtensionsDir
        $extensionRepos
        $iconPath
        $appIcon
        $sortAttrs
        $sortAttrValues
        $macroFile
        $default_macro_file
        $default_macro_encoding
        $printOptions
        $showHidden
        $createMacroMenu
        $maxMenuLines
        $useCzechLocales
        $useLocales
        $imageMagickConvert
        $cstsToFs
        $fsToCsts
        $sgmls
        $sgmlsopts
        $cstsdoctype
        $cstsparsecommand
        $cstsparsezcommand
        $keyboardDebug
        $hookDebug
        $macroDebug
        $tredDebug
        $defaultTemplateMatchMethod
        $defaultMacroListOrder
        $defCWidth
        $defCHeight
        $geometry
        $maxDisplayedValues
        $maxDisplayedAttributes
        $highlightWindowColor
        $highlightWindowWidth
        $lastAction
        $reverseNodeOrder
        $valueLineHeight
        $valueLineAlign
        $valueLineWrap
        $valueLineReverseLines
        $valueLineFocusBackground
        $valueLineFocusForeground
        $valueLineBackground
        $valueLineForeground
        $maxUndo
        $reloadKeepsPatterns
        $autoSave
        $displayStatusLine
        $openFilenameCommand
        $saveFilenameCommand
        $NoConvertWarning
        $lockFiles
        $noLockProto
        $stippleInactiveWindows
        $userConf
        $ioBackends
        $htmlBrowser
        $showSidePanel
        $skipStartupVersionCheck
        $enableTearOff
        %defaultPrintConfig
        %c_fonts
        $sidePanelWrap
        @open_types
        %save_types
        %backend_map
        $userlogin
        $noCheckLocks
        $config_file
        %vertical_key_arrow_map
        @config_recent_files
        $cmdline_config_file
        @config_filelists
        $documentation_dir
    );
    @EXPORT_OK
        = qw(&tilde_expand &read_config &set_config &parse_config_line &apply_config &set_default_config_file_search_list);
    @config_file_search_list = ();

    *find_exe = eval {
        require File::Which;
        \&File::Which::which;
    } || sub { };

}

require File::Spec;
require Treex::PML;


use vars (@EXPORT);

($userlogin)
    = ( getlogin() || ( $^O ne 'MSWin32' ) && getpwuid($<) || 'unknown' );
( $userlogin =~ /\S/ ) || warn "Could not determine user\'s login name\n";

# same as @TrEd::TreeView::Options, which we do not see yet
my @treeViewOpts = qw(

    backgroundColor backgroundImage backgroundImageX backgroundImageY
    balanceTree baseXPos baseYPos boxColor clearTextBackground columnSep
    currentBoxColor currentEdgeBoxColor currentNodeColor
    currentNodeHeight currentNodeWidth customColors dashHiddenLines
    displayMode drawBoxes drawEdgeBoxes drawFileInfo drawSentenceInfo
    edgeBoxColor edgeLabelSkipAbove edgeLabelSkipBelow font
    hiddenBoxColor hiddenEdgeBoxColor hiddenLineColor hiddenNodeColor
    highlightAttributes horizStripe labelSep lineArrow lineArrowShape
    lineColor lineDash lineSpacing lineWidth nearestNodeColor noColor
    nodeColor nodeHeight nodeOutlineColor nodeWidth nodeXSkip nodeYSkip
    reverseNodeOrder showHidden skipHiddenLevels skipHiddenParents
    stripeColor textColor textColorHilite textColorShadow
    textColorXHilite useAdditionalEdgeLabelSkip useFSColors vertStripe
    verticalTree xmargin ymargin

);

$treeViewOpts = {
    customColors => {

        # we override the hash in TrEd::TreeView::DefaultOptions
        # because we don't see it yet
        0 => 'darkgreen',
        1 => 'darkblue',
        2 => 'darkmagenta',
        3 => 'orange',
        4 => 'black',
        5 => 'DodgerBlue4',
        6 => 'red',
        7 => 'gold',
        8 => 'cyan',
        9 => 'midnightblue'
    },

    # we want to create scalar references to these options:
    clearTextBackground => 1,
    drawEdgeBoxes       => 0,
    drawBoxes           => 0,
    showHidden          => 0,
    displayMode         => 0,
};

%defaultPrintConfig = (
    printOnePerFile            => [ '-oneTreePerFile',        0 ],
    printTo                    => [ undef,                    'printer' ],
    printFormat                => [ '-format',                'PS' ],
    printFileExtension         => [ undef,                    'ps' ],
    printSentenceInfo          => [ '-sentenceInfo',          0 ],
    printFileInfo              => [ '-fileInfo',              0 ],
    printImageMagickResolution => [ '-imageMagickResolution', 80 ],
    printNoRotate              => [ '-noRotate',              0 ],
    printColors                => [ '-colors',                1 ],
    ttFont                     => [ '-ttFontName',            "Arial" ],
    ttFontPath                 => [ '-ttFontPath',            undef ],
    psFontFile                 => [ '-psFontFile',            undef ],
    psFontAFMFile              => [ '-psFontAFMFile',         undef ],
    psFontSize => [ '-fontSize', ( ( $^O =~ /^MS/ ) ? 14 : 12 ) ],
    prtFmtWidth       => [ '-fmtWidth',  595 ],
    prtFmtHeight      => [ '-fmtHeight', 842 ],
    prtVMargin        => [ '-vMargin',   '3c' ],
    prtHMargin        => [ '-hMargin',   '2c' ],
    psMedia           => [ '-psMedia',   'A4' ],
    psFile            => [ undef,        undef ],
    maximizePrintSize => [ '-maximize',  0 ],
    defaultPrintCommand =>
        [ '-command', ( ( $^O eq 'MSWin32' ) ? 'prfile32.exe /-' : 'lpr' ) ],
);

$printOptions = {};

#TODO: from tred
@open_types = (
    [   "Supported",
        [qw/.treex .treex.gz .streex .fs .pls .pml .t .a .fs.gz .pls.gz .pml.gz .t.gz .a.gz/]
    ],
    [ "Treex files",         [qw/.treex .treex.gz .streex/]],
    [ "FS files",            [qw/.fs .FS .Fs .fs.gz .FS.gz/] ],
    [ "CSTS files",          [qw/.cst .csts .cst.gz .csts.gz/] ],
    [ "Perl Storable files", [qw/.pls .pls.gz/] ],
    [   "PDT-PML files",
        [qw/.t .a .t.gz .a.gz .m .m.gz .pml .pml.gz .xml .xml.gz/]
    ],
    [ "XML files",     [qw/.xml .xml.gz .pml .pml.gz/] ],
    [ "TectoMT files", [qw/.tmt .tmt.gz/] ],
    [ "All files", '*' ]
);

%save_types = (
    fs => [
        [ "FS files",         [qw/.fs .FS .Fs/] ],
        [ "gzipped FS files", [qw/.fs.gz .FS.gz .FS.GZ/] ],
        [ "All files",        ['*'] ]
    ],
    pml => [
        [ "PML files",         [qw/.t .a .pml .xml/] ],
        [ "gzipped PML files", [qw/.t.gz .a.gz .pml.gz .xml.gz/] ],
        [ "All files",         ['*'] ]
    ],
    csts => [
        [ "CSTS files",         [qw/.cst .csts/] ],
        [ "gzipped CSTS files", [qw/.cst.gz .csts.gz/] ],
        [ "All files",          ['*'] ]
    ],
    trxml => [
        [ "TrXML files",         [qw/.trx .trxml .xml/] ],
        [ "gzipped TrXML files", [qw/.trx.gz .trxml.gz .xml.gz/] ],
        [ "All files",           ['*'] ]
    ],
    teixml => [
        [ "TEIXML files",         [qw/.tei .xml/] ],
        [ "gzipped TEIXML files", [qw/.tei.gz .xml.gz/] ],
        [ "All files",            ['*'] ]
    ],
    storable => [
        [ "Perl Storable files", [qw/.pls .pls.gz/] ],
        [ "All files", ['*'] ]
    ],
    all => [
        [ "All files", ['*'] ],
        [   "Recognized",
            [   qw/.fs .csts .pls .t .a .pls.gz .fs.gz .t.gz .a.gz .csts.gz .pml .pml.gz .xml .xml.gz .tmt .tmt.gz .treex .treex.gz .streex/
            ]
        ],
    ]
);

%backend_map = (
    fs       => 'FS',
    csts     => 'CSTS',
    pml      => 'PML',
    trxml    => 'TrXML',
    teixml   => 'TEIXML',
    ntred    => 'NTRED',
    storable => 'Storable'
);

# rotation of keyboard bindings for verticalTree mode
%vertical_key_arrow_map = (
    Left  => 'Up',
    Right => 'Down',
    Up    => 'Left',
    Down  => 'Right',
);
our $MAX_RECENTFILES = 9;

$documentation_dir = 'http://ufal.mff.cuni.cz/tred/documentation';

######################################################################################
# Usage         : set_default_config_file_search_list()
# Purpose       : Set @config_file_search_list values to common places where
#                 tredrc cofiguration file (tredrc) is usually found
# Returns       : Undef/empty string
# Parameters    : no
# Throws        : nothing
# Comments      : Requires FindBin. Tredrc paths are set to HOME environment variable,
#                 TREDHOME environment variable and relative to the original perl script's
#                 directory: under subdirectory tredlib, ../lib/tredlib, ../lib/tred
# See Also      : $FindBin::RealBin
sub set_default_config_file_search_list {
    require FindBin;
    @config_file_search_list = (
        File::Spec->catfile( $ENV{'HOME'}, '.tredrc' ),
        map { File::Spec->catfile( $_, 'tredrc' ) } (
            ( exists( $ENV{'TREDHOME'} ) ? $ENV{'TREDHOME'} : () ),
            $FindBin::RealBin,
            File::Spec->catfile( $FindBin::RealBin, 'tredlib' ),
            File::Spec->catfile( $FindBin::RealBin, '..', 'lib', 'tredlib' ),
            File::Spec->catfile( $FindBin::RealBin, '..', 'lib', 'tred' ),
        )
    );
    return;
}

######################################################################################
# Usage         : tilde_expand($path_str)
# Purpose       : If string contains tilde, substitute tilde with home directory of current user
# Returns       : String after the substitution
# Parameters    : scalar $path_str -- string containing path
# Throws        : nothing
# Comments      :
# See Also      :
sub tilde_expand {
    my ($a) = @_;

    # substitute tilde with HOME env variable at the beginning of the string
    $a =~ s/^\~/$ENV{HOME}/;

    # substitute tilde with HOME env variable anywhere in the string
    $a =~ s/([^\\])\~/$1$ENV{HOME}/g;
    return $a;
}

#####################################################################################
# Usage         : parse_config_line($line, $confs_ref)
# Purpose       : Parse each line of the config file to extract key and value pair and
#                 save it into hash $confs_ref
# Returns       : Undef/empty string
# Parameters    : string $line        -- line to be parsed
#                 hash_ref $confs_ref -- hash of configuration key-value pairs
# Throws        : nothing
# Comments      : Longer because of comments of quite sophisticated regexp
# See Also      : read_config() -- a caller of this function
sub parse_config_line {
    my ( $line, $confs_ref ) = @_;
    my $key;
    my $spaces_re          = qr{\s*};
    my $optional_subkey_re = qr{
    ::[a-zA-Z_]+[a-zA-Z_0-9:]*
  }x;
    my $key_standard_re = qr{
    [a-zA-Z_]+[a-zA-Z_0-9]*
  }x;
    my $single_quot_value_re = qr {
    '(?:[^\\']|\\.)*' # we want the regexp to be able to match escaped single quotes and backslashes in string and use it,
                      # so |'" \'sth_else| or |'abc\'\'| does not match
                      # but |'" \'sth_else'| or |'abcd\''| matches and it extracts |" \'sth_else| and |abcd\'|, respectively
                      # be careful, though: |'abcd\\''| matches, but the last quote is not extracted: |abcd\\|
  }x;
    my $double_quot_value_re = qr {
    "(?:[^\\"]|\\.)*" # the same situation as with single quotes, just change ' => " and vice versa
  }x;
    my $unquot_value_re = qr {
    (?:\s*(?:[^;\\\s]|\\.)+)* # we want to allow strings like C:\\Documents and Settings\\John\\Application Data\\
                              # so we basically accept everything except for ';', which is a start for a commentary (but it can be escaped)
                              # everything after the ';' until the end of the line is thrown away
                              # backslash, ';' and whitespace at the end of the string is chopped, but only if they are not escaped
  }x;
    my $parse_config_re = qr {
    ^
    $spaces_re # any number of spaces
    #capturing key to $1
    (	
    $key_standard_re
    ($optional_subkey_re)?
    )
    $spaces_re # any number of spaces
    =	       # equal sign as the key-value delimiter
    $spaces_re # any number of spaces
    #capture value to $2
    (
    #single quoted value
    $single_quot_value_re
    | # or
    $double_quot_value_re
    | # or
    $unquot_value_re
    )
  }x;

    # if line starts with ; or # or contains only spaces, don't do anything
    if ( !( $line =~ /^\s*[;#]/ or $line =~ /^\s*$/ ) ) {
        chomp($line);
        if ( $line =~ $parse_config_re ) {

            # if there is no "::" in key, lowercase it
            $key = $2 ? $1 : lc($1);
            $confs_ref->{$key} = $3;
            $confs_ref->{$key} =~ s/\\(.)/$1/g;

            # remove quotes
            if (   $confs_ref->{$key} =~ /^'(.*)'$/
                or $confs_ref->{$key} =~ /^"(.*)"$/ )
            {
                $confs_ref->{$key} = $1;
            }
        }
    }
    return;
}

#####################################################################################
# Usage         : read_config(@paths_to_config_file)
# Purpose       : Read configuration values from file and save it to %confs hash
# Returns       : Name/path to config file that was used to read cofiguration values
# Parameters    : list @paths_to_config_file -- array containing file name of config file(s)
# Throws        :
# Comments      : Tries to open config file, first from list supported by argument, if it does not succeed,
#                 function tries to open files from @config_file_search_list. If any of these files is opened
#                 successfully, the configuration is then read to memory from this file.
# See Also      : set_config(), parse_config_line()
sub read_config {
    my %confs;
    my ( $key, $f );

    # reading new config -> (re)init
    my $config_found = 0;
    $config_file = undef;

    foreach my $f ( @_, @config_file_search_list ) {
        my $fh;
        if ( defined $f && open $fh, '<', $f ) {
            print STDERR "Config file: $f\n" unless $quiet;
            while (<$fh>) {
                parse_config_line( $_, \%confs );
            }
            close $fh;
            $config_found = 1;
            $config_file  = $f;
            last;
        }
    }
    if ( !$config_found ) {
        print STDERR
            "Warning: Cannot open any file in:\n",
            join( q{:}, @config_file_search_list ),
            "\n" . "         Using configuration defaults!\n"
            unless $quiet;
    }
    set_config( \%confs );
    return $config_file;
}

#####################################################################################
# Usage         : apply_config(@options)
# Purpose       : Apply configuration @options
# Returns       : Nothing
# Parameters    : list @options -- list of option_name=option_value strings
# Throws        : nothing
# Comments      : Parses configuration @options, calls set_config() with new options
# See Also      : set_config(), parse_config_line()
sub apply_config {
    my %confs;
    foreach my $line (@_) {
        parse_config_line( $line, \%confs );
    }
    set_config( \%confs );
    return;
}

#####################################################################################
# Usage         : val_or_def($configuration_hash, $key, $default_value)
# Purpose       : Choose value from $configuration_hash with $key if it exists or $default_value otherwise
# Returns       : Value set in $configuration_hash reference with key $key if it exists, $default_value otherwise
# Parameters    : hash_ref $configuration_hash  -- reference to hash with configuration options
#                 scalar $key                   -- string containing name of the option
#                 scalar $default_value         -- scalar containing the value of configuration option
# Throws        :
# Comments      :
# See Also      :
sub val_or_def {
    my ( $confs_ref, $key, $default ) = @_;
    return ( exists( $confs_ref->{$key} ) ? $confs_ref->{$key} : $default );
}

#####################################################################################
# Usage         : _parse_cmdline_options($confs_ref)
# Purpose       : Parse options from command line switch -O and save them in $confs_ref
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : Uses array reference $override_options, where the command line options are
#                 stored. The syntax of -O argument is specified in tred manual, in short these options
#                 are supported:
#                 * name=value    -- set option 'name' to 'value'
#                 * nameX=value   -- treat the option as a list delimited by the delimiter X and prepend the value to the list.
#                 * nameX+=value  -- treat the option as a list delimited by the delimiter X and append the value to the list.
#                 * nameX-=value  -- treat the option as a list delimited by the delimiter X and remove the value from the list (if exists).
#                 Only the following characters can be used as a delimiter:
#                 ; : , & | / + - \s \t SPACE
#                 Can be combined, i.e. -O "extensionRepos\\s"-=http://foo/bar -O "extensionRepos\\s"+=http://foo/bar
#                 first removes any occurrence of the URL http://foo/bar from the white-space separated list of extensionRepos and then appends the URL to the end of the list.
# See Also      : set_config()
sub _parse_cmdline_options {
    my ($confs_ref) = @_;

    if ( ref($override_options) ) {
        foreach my $opt (@$override_options) {
            my ( $name, $value ) = split( /=/, $opt, 2 );
            if ( !( $name =~ /::/ ) ) {
                $name = lc($name);
            }
            if ( $name =~ s{([-+;:.,&|/ \t]|\\s|\\t)([-.+]?)$}{} ) {
                my $delim     = $1;
                my $operation = $2;
                my $wdelim    = $delim;
                if ( $delim eq '\s' ) {
                    $wdelim = ' ';
                }
                if ( $delim eq '\t' ) {
                    $wdelim = "\t";
                }
                if ( defined( $confs_ref->{$name} )
                    and length( $confs_ref->{$name} ) )
                {
                    if ( !$operation ) {
                        $confs_ref->{$name}
                            = $value . $wdelim . $confs_ref->{$name};
                    }
                    elsif ( $operation eq '+' ) {
                        $confs_ref->{$name}
                            = $confs_ref->{$name} . $wdelim . $value;
                    }
                    elsif ( $operation eq '-' ) {
                        $confs_ref->{$name} = join( $wdelim,
                            grep { $_ ne $value }
                                split( /[$delim]/, $confs_ref->{$name} ) );
                    }
                    next;
                }
                else {
                    next if ( $operation and $operation eq '-' );
                }
            }
            $confs_ref->{$name} = $value;
        }
    }
    return;
}

#####################################################################################
# Usage         : _set_treeViewOpts($confs_ref)
# Purpose       : Set various options in treeViewOpts hash
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : Tries to set all options found in treeViewOpts from $confs_ref.
#                 In addition, sets these options: currentNodeHeight, -Width, nodeHeight, -Width,
#                 customColor..., font and backgroundImage
#                 $TrEd::Config::font should be set before running this function e.g. by calling _set_fonts()
# See Also      : set_config()
sub _set_treeViewOpts {
    my ($confs_ref) = @_;
    ## set treeViewOpts
    for my $opt (@treeViewOpts) {
        if ( exists $confs_ref->{ lc $opt } ) {
            $treeViewOpts->{$opt} = $confs_ref->{ lc $opt };
        }
    }

    # treeViewOpts: set currentNodeWidht & -Height
    for my $opt (qw(Height Width)) {
        if (  !exists( $treeViewOpts->{ 'currentNode' . $opt } )
            && exists( $treeViewOpts->{ 'node' . $opt } ) )
        {
            $treeViewOpts->{ 'currentNode' . $opt }
                = $treeViewOpts->{ 'node' . $opt } + 2;    # Hm, why +2?
        }
    }

    # treeViewOpts: set customColors
    # and user- settings
    #TODO: find out whether userConf is somehow connected 
    # with the treeViewOpts, maybe put it back into set_config()
    foreach my $key ( keys %$confs_ref ) {
        if ( $key =~ m/^customcolor(.*)$/ ) {
            $treeViewOpts->{customColors}->{$1} = $confs_ref->{$key};
        }
        elsif ( $key =~ m/^user(.*)$/ ) {
            $userConf->{$1} = $confs_ref->{$key};
        }
    }

    # Font
    $treeViewOpts->{font} = $font;

    # Background image
    my $bg_image = $confs_ref->{backgroundimage};
    if ( defined $bg_image && $bg_image ne q{}
        && !-f $bg_image
        && -f $libDir . '/' . $bg_image )
    {
        $treeViewOpts->{backgroundImage}
            = $libDir . '/' . $bg_image;
    }
    else {
        $treeViewOpts->{backgroundImage}
            = val_or_def( $confs_ref, 'backgroundimage', undef );
    }
    return;
}

#####################################################################################
# Usage         : _set_fonts($confs_ref)
# Purpose       : Set font family, size and encoding
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : If font is set in $confs_ref, it is used. Otherwise Arial is picked as a default font
#                 on Windows and Helvetica on other OSes.
#                 Function also sets vlinefont, guifont and
#                 guifont_small/small_bold/heading/fixed/default/bold/italic fonts.
# See Also      : set_config(), _set_font_encoding()
sub _set_fonts {
    my ($confs_ref) = @_;
    my $fontenc = _set_font_encoding();

    if ( exists( $confs_ref->{'font'} ) ) {
        $font = $confs_ref->{'font'};

        # substitute -*-* at the end of $confs_ref->{font} with -$fontenc
        $font =~ s/-\*-\*$/-$fontenc/;
    }
    else {
        if ( $^O =~ /^MS/ ) {
            $font = 'family:Arial,size:10';
        }
        elsif ( $fontenc eq 'iso10646-1' ) {
            $font = '{Arial Unicode Ms} 10';

     #$font = '-*-arial unicode ms-medium-r-normal-*-12-*-*-*-*-*-iso10646-1';
        }
        else {
            $font = '-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-' . $fontenc;
        }
    }

    # print "USING FONT $font\n";

    $vLineFont = val_or_def( $confs_ref, 'vlinefont', $font );
    $guiFont   = val_or_def( $confs_ref, 'guifont',   undef );

    # set up various gui fonts
    for my $name (qw(small small_bold heading fixed default bold italic)) {
        $c_fonts{$name} = val_or_def( $confs_ref, 'guifont_' . $name, undef );
    }
    return;
}

#####################################################################################
# Usage         : _set_font_encoding()
# Purpose       : Choose font encoding according to Tk version and TrEd::Convert::outputenc
# Returns       : Font encoding
# Parameters    :
# Throws        : nothing
# Comments      : If $TrEd::Convert::outputenc is set, it is used, otherwise iso-8859-2 is used
#                 with Tk versions older than 804, iso-10646-1 
#                 (aka Universal Character Set) for newer versions
# See Also      : set_config(), _set_font_encoding()
sub _set_font_encoding {
    my $fontenc = $TrEd::Convert::outputenc
        || ( ( defined($Tk::VERSION) and $Tk::VERSION < 804 )
        ? 'iso-8859-2'
        : 'iso-10646-1' );
    $fontenc =~ s/^iso-/iso/;
    return $fontenc;
}

#####################################################################################
# Usage         : _set_resource_path($confs_ref, $default_share_path)
# Purpose       : Add resource paths from configuration hash and default resource path to $Treex::PML::resourcePath
# Returns       : nothing
# Parameters    : hash_ref $confs_ref         -- hash with configuration options
#                 scalar $default_share_path  -- default share path
# Throws        : nothing
# Comments      : HOME environment variable should be set before running this function, on Windows,
#                 one can run TrEd::Utils::find_win_home() to set HOME variable for this purpose
#                 Default resource path is constructed from $def_share_path
# See Also      : set_config(), _set_font_encoding(), tilde_expand()
sub _set_resource_path {
    my ( $confs_ref, $def_share_path ) = @_;

    # resource path delimiter
    my $resourcePathSplit = ( $^O eq 'MSWin32' ) ? ',' : ':';

    # construct default resource path
    my $def_res_path
        = ( $def_share_path =~ m{/share/tred$} )
        ? $def_share_path
        : File::Spec->catdir( $def_share_path, 'resources' );
    $def_res_path
        = tilde_expand(q(~/.tred.d)) . $resourcePathSplit . $def_res_path;

    # original resourcePath
    my @r = ();
    if (defined $Treex::PML::resourcePath) {
        @r = split( $resourcePathSplit, $Treex::PML::resourcePath );
    }
    my $r;
    if ( exists( $confs_ref->{'resourcepath'} ) ) {

        # tilde-expand all the resource paths in confs_ref
        my $path = join(
            $resourcePathSplit,
            map { tilde_expand($_) } split(
                /\Q$resourcePathSplit\E/, $confs_ref->{'resourcepath'}
            )
        );

        # if there is a delimiter at the beginning of the string,
        # prepend default resource path ($def_res_path)
        # side note:  By default, empty leading fields are preserved,
        # and empty trailing ones are deleted, so it is
        # actually not possible for the $resourcePathSplit
        # to be at the end of $path
        if ( $path =~ /^\Q$resourcePathSplit\E/ ) {
            $path = $def_res_path . $path;
        }
        elsif ( $path =~ /\Q$resourcePathSplit\E$/ ) {
            # if there is a delimiter at the end of the string,
            # append default resource path ($def_res_path)
            $path .= $def_res_path;
        }

        # use both default resource path and all the paths from config hash
        $r = $path;
    }
    else {
        # there is no resource path in configuration hash,
        # just use default resource path
        $r = $def_res_path;
    }
    unshift( @r, split( $resourcePathSplit, $r ) );
    my %r;
    $Treex::PML::resourcePath = join( $resourcePathSplit,
        grep { defined and length }
        map { exists( $r{$_} ) ? () : ( $r{$_} = $_ ) } @r );
    return;
}

#####################################################################################
# Usage         : _set_print_options($confs_ref)
# Purpose       : Set print options from $defaultPrintConfig, try to find ps, AFM font file and path for TTF fonts
# Returns       : nothing
# Parameters    : hash_ref $confs_ref         -- hash with configuration options
# Throws        : nothing
# Comments      : Prefers using options in $confs_ref. If the option is not defined there, uses
#                 default option set in %defaultPrintConfig
#                 psFontFile and psFontAFMFile are looked for in directories found in $printOptions,
#                 if they do not exist there, they are looked up in $libDir. If this fails, too,
#                 default paths for font files supplied with TrEd are used.
#                 TTF font directory is determined from the registry on Windows, from /etc/fonts/fonts.conf otherwise
# See Also      : set_config()
sub _set_print_options {
    my ($confs_ref) = @_;
    for my $opt ( keys(%defaultPrintConfig) ) {
        $printOptions->{$opt} = val_or_def( $confs_ref, lc($opt),
            $defaultPrintConfig{$opt}[1] );
    }
    {
        my $psFontFile = $printOptions->{psFontFile};

        # try to find psFontFile
        if ( defined($psFontFile) and length($psFontFile) ) {
            $psFontFile = tilde_expand($psFontFile);
            if ( not -f $psFontFile and -f "$libDir/" . $psFontFile ) {
                $psFontFile = "$libDir/" . $psFontFile;
            }
        }
        else {
            if ( !defined($Tk::VERSION) || $Tk::VERSION >= 804 ) {
                $psFontFile = "$libDir/fonts/n019003l.pfa";
            }
            else {
                $psFontFile = "$libDir/fonts/ariam___.pfa";
            }
        }

        # try to find psFontAFMFile
        my $psFontAFMFile = $printOptions->{psFontAFMFile};
        if ( defined($psFontAFMFile) and length($psFontAFMFile) ) {
            $psFontAFMFile = tilde_expand($psFontAFMFile);
            if ( not -f $psFontAFMFile and -f "$libDir/" . $psFontAFMFile ) {
                $psFontAFMFile = "$libDir/" . $psFontAFMFile;
            }
        }
        else {
            $psFontAFMFile = $psFontFile;

            # change extension of the psFontFile to .afm and
            # test whether it exists
            $psFontAFMFile =~ s/\.[^.]+$/.afm/;

            # if not, try to search for afm font file
            # in afm subdirectory (relative to psFontFile)
            if ( !( -f $psFontAFMFile ) ) {
                $psFontAFMFile =~ s!/([^/]+)$!/afm/$1!;
            }
        }
        $printOptions->{psFontFile}    = $psFontFile;
        $printOptions->{psFontAFMFile} = $psFontAFMFile;
    }

    {
        my $ttFontPath = $printOptions->{ttFontPath};
        if ( defined $ttFontPath && length $ttFontPath ) {
            $ttFontPath = tilde_expand( $confs_ref->{ttfontpath} );
            if ( ! -d $ttFontPath && -d "$libDir/" . $ttFontPath ) {
                $ttFontPath = "$libDir/" . $ttFontPath;
            }
        }
        else {
            my @fontpath;

            # Read paths from registry on Windows
            if ( $^O eq 'MSWin32' ) {
                my %shf;
                require TrEd::Utils;
                my $ShellFolders
                    = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders";
                @fontpath = TrEd::Utils::fetch_from_win32_reg('HKEY_CURRENT_USER', $ShellFolders, 'Fonts');

                #		 qw(c:/windows/fonts/ c:/winnt/fonts/);
            }
            else {

                # use fontconfig here?
                if ( open my $fc, '<', '/etc/fonts/fonts.conf' ) {
                    my $line;
                    while ( $line = <$fc> ) {

                      # there can be more than one <dir></dir> tag on one line
                        while ( $line =~ m{<dir>([^<]*)<\/dir>}g
                            and -d tilde_expand($1) )
                        {
                            push( @fontpath, tilde_expand($1) );

                            # naive, should subst. entities, etc.
                        }
                    }
                }

                # Use some default paths if no paths were 
                # found using fontconfig configuration file
                if ( !(@fontpath) ) {
                    @fontpath = (
                        "$ENV{HOME}/.fonts/",
                        qw(
                            /usr/X11R6/lib/X11/fonts/TTF/
                            /usr/X11R6/lib/X11/fonts/TrueType/
                            /usr/share/fonts/default/TrueType/
                            /usr/share/fonts/default/TTF/
                            )
                    );
                }
            }
            $ttFontPath = join( q{,}, map { tilde_expand($_) } @fontpath );
        }
        $printOptions->{ttFontPath} = $ttFontPath;
    }
    return;
}

#####################################################################################
# Usage         : _set_extensions($confs_ref, $default_share_path)
# Purpose       : Set variables which are related to TrEd extensions
# Returns       : nothing
# Parameters    : hash_ref $confs_ref         -- hash with configuration options
#                 scalar $default_share_path  -- default share path
# Throws        : nothing
# Comments      : Takes care of setting $extensionsDir, $extensionsRepos and $preinstalledExtensionsDir variables.
#                 Tries to set these variables from $confs_ref, if there is no value in the $confs_ref hash,
#                 function uses default values
# See Also      : set_config(), _set_font_encoding(), tilde_expand()
sub _set_extensions {
    my ( $confs_ref, $def_share_path ) = @_;
    my $conf_extension_dir
        = defined $confs_ref->{extensionsdir} 
          && length $confs_ref->{extensionsdir}
        ? $confs_ref->{extensionsdir}
        : '~/.tred.d/extensions';
    $extensionsDir = File::Spec->rel2abs( tilde_expand($conf_extension_dir),
        Cwd::cwd() );

    $extensionRepos = val_or_def( $confs_ref, 'extensionrepos',
        "http://ufal.mff.cuni.cz/tred/extensions/core/\nhttp://ufal.mff.cuni.cz/tred/extensions/external/" );

    $preinstalledExtensionsDir
        =  defined $confs_ref->{preinstalledextensionsdir}
           && length $confs_ref->{preinstalledextensionsdir}
        ? tilde_expand( $confs_ref->{preinstalledextensionsdir} )
        : $def_share_path =~ m{/share/tred$} ? $def_share_path . '-extensions'
        :   File::Spec->catdir( $def_share_path, 'tred-extensions' );
    return;
}

#####################################################################################
# Usage         : set_config($confs_ref)
# Purpose       : Set configuration values to values in $confs_ref hash (if defined) or to default values
# Returns       : nothing
# Parameters    : hash_ref @confs_ref -- hash with configuration options
# Throws        : nothing
# Comments      : Does not call $set_user_config($confs_ref) function any more!
# See Also      : apply_config(), read_config()
sub set_config {
    my ($confs_ref) = @_;

    # options specified on (b/n)tred's command line
    _parse_cmdline_options($confs_ref);

    $appName
        = val_or_def( $confs_ref, 'appname', 'TrEd ver. ' . $main::VERSION );
    if ( !exists( $ENV{PML_COMPILE} ) ) {
        $ENV{PML_COMPILE} = val_or_def( $confs_ref, 'pml_compile', 0 );
    }

    $buttonsRelief     = val_or_def( $confs_ref, 'buttonsrelief', 'flat' );
    $menubarRelief     = val_or_def( $confs_ref, 'menubarrelief', 'flat' );
    $buttonBorderWidth = val_or_def( $confs_ref, 'buttonsborder', 2 );
    $canvasBalloonInitWait = val_or_def( $confs_ref, 'hintwait', 1000 );
    $canvasBalloonForeground
        = val_or_def( $confs_ref, 'hintforeground', 'black' );
    $canvasBalloonBackground
        = val_or_def( $confs_ref, 'hintbackground', '#fff3b0' );
    $toolbarBalloonInitWait
        = val_or_def( $confs_ref, 'toolbarhintwait', 450 );
    $toolbarBalloonForeground
        = val_or_def( $confs_ref, 'toolbarhintforeground', 'black' );
    $toolbarBalloonBackground
        = val_or_def( $confs_ref, 'toolbarhintbackground', '#fff3b0' );

    $activeTextColor = val_or_def( $confs_ref, 'activetextcolor', 'blue' );
    $stippleInactiveWindows
        = val_or_def( $confs_ref, 'stippleinactivewindows', 1 );

    $highlightWindowColor
        = val_or_def( $confs_ref, 'highlightwindowcolor', 'black' );
    $highlightWindowWidth
        = val_or_def( $confs_ref, 'highlightwindowwidth', 3 );

    $valueLineHeight = val_or_def( $confs_ref, 'vlineheight',
        defined($valueLineHeight) ? $valueLineHeight : 2 );
    $valueLineAlign = val_or_def( $confs_ref, 'vlinealign',
        defined($valueLineAlign) ? $valueLineAlign : 'left' );
    $valueLineWrap = val_or_def( $confs_ref, 'vlinewrap',
        defined($valueLineWrap) ? $valueLineWrap : 'word' );
    $valueLineReverseLines = val_or_def( $confs_ref, 'vlinereverselines',
        defined($valueLineReverseLines) ? $valueLineReverseLines : 0 );
    $valueLineFocusForeground = val_or_def(
        $confs_ref,
        'vlinefocusforeground',
        defined($valueLineFocusForeground)
        ? $valueLineFocusForeground
        : 'black'
    );
    $valueLineForeground = val_or_def( $confs_ref, 'vlineforeground',
        defined($valueLineForeground) ? $valueLineForeground : 'black' );
    $valueLineFocusBackground = val_or_def(
        $confs_ref,
        'vlinefocusbackground',
        defined($valueLineFocusBackground)
        ? $valueLineFocusBackground
        : 'yellow'
    );
    $valueLineBackground = val_or_def( $confs_ref, 'vlinebackground',
        defined($valueLineBackground) ? $valueLineBackground : 'white' );

    # Set encoding and text orientation
    $TrEd::Convert::inputenc = val_or_def( $confs_ref, 'defaultfileencoding',
        $TrEd::Convert::inputenc );
    $TrEd::Convert::outputenc
        = val_or_def( $confs_ref, 'defaultdisplayencoding',
        $TrEd::Convert::outputenc );
    $TrEd::Convert::lefttoright
        = val_or_def( $confs_ref, 'displaynonasciilefttoright',
        $TrEd::Convert::lefttoright );

    # Set font and its encoding
    _set_fonts($confs_ref);

    # Set libdir and perllib
    if ( $confs_ref->{perllib} ) {
        foreach my $perllib ( split /\:/, $confs_ref->{perllib} ) {
            $perllib = tilde_expand($perllib);
            if ( !( grep { $_ eq $perllib} @INC ) ) {
                unshift( @INC, $perllib );
            }
        }
    }
    if ( exists $confs_ref->{libdir} ) {
        $libDir = tilde_expand( $confs_ref->{libdir} );
    }
    if ($libDir) {
        if ( !( grep { $_ eq $libDir } @INC ) ) {
            unshift( @INC, $libDir );
        }
    }

    my $def_share_path = $libDir;

    if ( $^O eq 'MSWin32' ) {
        $def_share_path =~ s/[\\\/](?:lib[\\\/]tred|tredlib)$//;
    }
    else {
        if ( !( $def_share_path =~ s{/lib/tred$}{/share/tred} ) ) {
            $def_share_path =~ s/\/(?:tredlib)$//;
        }
    }

    _set_extensions( $confs_ref, $def_share_path );

    _set_resource_path( $confs_ref, $def_share_path );

    _set_treeViewOpts($confs_ref);

    $appIcon
        = ( exists $confs_ref->{appicon} )
        ? tilde_expand( $confs_ref->{appicon} )
        : "$libDir/tred.xpm";
    $iconPath
        = ( exists $confs_ref->{iconpath} )
        ? tilde_expand( $confs_ref->{iconpath} )
        : "$libDir/icons/crystal";
    $macroFile
        = ( exists $confs_ref->{macrofile} )
        ? tilde_expand( $confs_ref->{macrofile} )
        : undef;
    $default_macro_file
        = ( exists $confs_ref->{defaultmacrofile} )
        ? tilde_expand( $confs_ref->{defaultmacrofile} )
        : "$libDir/tred.def";
    $default_macro_encoding
        = val_or_def( $confs_ref, 'defaultmacroencoding', 'utf8' );
    $sortAttrs      = val_or_def( $confs_ref, 'sortattributes',      1 );
    $sortAttrValues = val_or_def( $confs_ref, 'sortattributevalues', 1 );

    _set_print_options();

    $createMacroMenu = val_or_def( $confs_ref, 'createmacromenu', 0 );
    $maxMenuLines    = val_or_def( $confs_ref, 'maxmenulines',    20 );
    $useCzechLocales = val_or_def( $confs_ref, 'useczechlocales', 0 );
    $useLocales      = val_or_def( $confs_ref, 'uselocales',      0 );
    $Tk::strictMotif = val_or_def( $confs_ref, 'strictmotif',     0 );
    $imageMagickConvert
        = val_or_def( $confs_ref, 'imagemagickconvert', 'convert' );
    $NoConvertWarning = val_or_def( $confs_ref, 'noconvertwarning', 0 );

    $Treex::PML::IO::reject_proto
        = val_or_def( $confs_ref, 'rejectprotocols', '^(pop3?s?|imaps?)\$' );
    $Treex::PML::IO::gzip
        = val_or_def( $confs_ref, 'gzip', find_exe("gzip") );
    if ( !$Treex::PML::IO::gzip and -x "$libDir/../gzip" ) {
        $Treex::PML::IO::gzip = "$libDir/../bin/gzip";
    }
    $Treex::PML::IO::gzip_opts = val_or_def( $confs_ref, 'gzipopts', '-c' );
    $Treex::PML::IO::zcat      = val_or_def( $confs_ref, 'zcat', find_exe('zcat') );
    $Treex::PML::IO::zcat_opts = val_or_def( $confs_ref, 'zcatopts',  undef );
    $Treex::PML::IO::ssh       = val_or_def( $confs_ref, 'ssh',       undef );
    $Treex::PML::IO::ssh_opts  = val_or_def( $confs_ref, 'sshopts',   undef );
    $Treex::PML::IO::kioclient = val_or_def( $confs_ref, 'kioclient', undef );
    $Treex::PML::IO::kioclient_opts
        = val_or_def( $confs_ref, 'kioclientopts', undef );
    $Treex::PML::IO::curl      = val_or_def( $confs_ref, 'curl',     undef );
    $Treex::PML::IO::curl_opts = val_or_def( $confs_ref, 'curlopts', undef );

    if ( !$Treex::PML::IO::zcat ) {
        if ($Treex::PML::IO::gzip) {
            $Treex::PML::IO::zcat      = $Treex::PML::IO::gzip;
            $Treex::PML::IO::zcat_opts = '-d';
        }
        elsif ( -x "$libDir/../zcat" ) {
            $Treex::PML::IO::zcat = "$libDir/../bin/zcat";
        }
    }
    $cstsToFs = val_or_def( $confs_ref, 'cststofs', undef );
    $fsToCsts = val_or_def( $confs_ref, 'fstocsts', undef );

    $sgmls = val_or_def( $confs_ref, 'sgmls', 'nsgmls' );
    $sgmlsopts
        = val_or_def( $confs_ref, 'sgmlsopts', '-i preserve.gen.entities' );
    $cstsdoctype = val_or_def( $confs_ref, 'cstsdoctype', undef );
    $cstsparsecommand
        = val_or_def( $confs_ref, 'cstsparsercommand', "\%s \%o \%d \%f" );

    $Treex::PML::Backends::CSTS::sgmls         = $sgmls;
    $Treex::PML::Backends::CSTS::sgmlsopts     = $sgmlsopts;
    $Treex::PML::Backends::CSTS::doctype       = $cstsdoctype;
    $Treex::PML::Backends::CSTS::sgmls_command = $cstsparsecommand;

    $keyboardDebug = val_or_def( $confs_ref, 'keyboarddebug', 0 );
    $hookDebug     = val_or_def( $confs_ref, 'hookdebug',     0 );
    $macroDebug    = val_or_def( $confs_ref, 'macrodebug',    0 );
    $tredDebug     = val_or_def( $confs_ref, 'treddebug',     $tredDebug );
    $Treex::PML::Debug
        = val_or_def( $confs_ref, 'backenddebug', $Treex::PML::Debug );
    $defaultTemplateMatchMethod
        = val_or_def( $confs_ref, 'searchmethod', 'R' );
    $defaultMacroListOrder = val_or_def( $confs_ref, 'macrolistorder', 'M' );
    $defCWidth     = val_or_def( $confs_ref, 'canvaswidth',   '18c' );
    $defCHeight    = val_or_def( $confs_ref, 'canvasheight',  '12c' );
    $geometry      = val_or_def( $confs_ref, 'geometry',      undef );
    $showSidePanel = val_or_def( $confs_ref, 'showsidepanel', undef );
    $maxDisplayedValues = val_or_def( $confs_ref, 'maxdisplayedvalues', 25 );
    $maxDisplayedAttributes
        = val_or_def( $confs_ref, 'maxdisplayedattributes', 20 );
    $lastAction = val_or_def( $confs_ref, 'lastaction', undef );

    $maxUndo = val_or_def( $confs_ref, 'maxundo', 30 );
    $reloadKeepsPatterns
        = val_or_def( $confs_ref, 'reloadpreservespatterns', 1 );
    $autoSave          = val_or_def( $confs_ref, 'autosave',          5 );
    $displayStatusLine = val_or_def( $confs_ref, 'displaystatusline', 1 );
    $openFilenameCommand
        = val_or_def( $confs_ref, 'openfilenamecommand', undef );
    $saveFilenameCommand
        = val_or_def( $confs_ref, 'savefilenamecommand', undef );
    $lockFiles = val_or_def( $confs_ref, "lockfiles", 1 );
    $noLockProto
        = val_or_def( $confs_ref, 'nolockprotocols', '^(https?|zip|tar)$' );
    $ioBackends  = val_or_def( $confs_ref, 'iobackends',  undef );
    $htmlBrowser = val_or_def( $confs_ref, 'htmlbrowser', undef );

    $skipStartupVersionCheck
        = val_or_def( $confs_ref, 'skipstartupversioncheck', undef );
    $enableTearOff = val_or_def( $confs_ref, 'enabletearoff', 0 );

    $sidePanelWrap = val_or_def( $confs_ref, 'sidepanelwrap', 0 );

    # ADD NEW OPTIONS HERE

    init_recent_files($confs_ref);

    init_filelist_list($confs_ref);

    # let this be the very last line

    {
        no strict qw(vars refs);
        foreach ( keys %$confs_ref ) {
            if (/::/) {
                ${"$_"} = $confs_ref->{$_};
            }
        }
    }
    return;
}

sub init_filelist_list {
    my ($confs_ref) = @_;
    foreach my $filelist_id ( sort { substr( $a, 8 ) <=> substr( $b, 8 ) }
                           grep { /^filelist[0-9]+/ }
                           keys %{$confs_ref} ) 
    {
        push @config_filelists, $confs_ref->{$filelist_id};
    }
    return;
}

sub init_recent_files {
    my ($confs_ref) = @_;
    foreach my $index ( 0 .. $MAX_RECENTFILES ) {
        $config_recent_files[$index] = $confs_ref->{"recentfile$index"};
    }
    @config_recent_files = grep {$_} @config_recent_files;
}

# config
sub get_config_from_file {
    my @conf;
    if ( open( my $fh, "<", $config_file ) ) {
        @conf = <$fh>;
        close($fh);
        return \@conf;
    }
    else {
        return;
    }
}

# was main::saveRuntimeConfig
sub save_runtime_config {
    my ( $grp, $update ) = @_;

    # Save configuration
    if ($tredDebug) {
        print STDERR "Saving some configuration options.\n";
    }
    my $config = get_config_from_file() || [];
    update_runtime_config( $grp, $config, $update );
    save_config( $grp, $config, $main::opt_q );
}

sub update_runtime_config {
    my ( $grp, $conf, $update ) = @_;
    # we don't want these to load at the very beginning of TrEd startup
    require TrEd::ManageFilelists;
    require TrEd::Bookmarks;
    require TrEd::RecentFiles;


    $update ||= {};
    my $comment = ';; Options changed by TrEd on every close (DO NOT EDIT)';
    my $ommit
        = 'canvasheight|canvaswidth|recentfile[0-9]+|geometry|showsidepanel|lastaction|filelist[0-9]+';
    my $update_comment = delete $update->{';'};
    for ( keys %$update ) {
        $ommit .= qq(|$_);
    }
    @{$conf} = grep { !/^\s*(?:\Q$comment\E|(?:$ommit)\s*=)/i } @{$conf};
    @{$conf} = grep { !/^\s*;*\s*\Q$update_comment\E/i } @{$conf}
        if defined $update_comment;
    pop @{$conf} while @{$conf} and $conf->[-1] =~ /^\s*$/;

    push @{$conf}, "\n", ";; " . $update_comment . "\n" if $update_comment;
    push @{$conf}, ( map { qq($_\t=\t) . $update->{$_} . "\n" } keys %$update );

    push @{$conf}, "\n", $comment . "\n";

    #  $geometry=~s/^[0-9]+x[0-9]+//;
    if ( TrEd::Bookmarks::get_last_action() ) {
        my $s = TrEd::Bookmarks::get_last_action();
        $s =~ s/\\/\\\\/g;
        push @{$conf}, "LastAction\t=\t" . $s . "\n";
    }
    if ( $grp->{top} ) {
        eval {
            $geometry = $grp->{top}->geometry();
            if ($tredDebug) {
                print "geometry is $geometry\n";
            }
            if ( $^O eq 'MSWin32' and $grp->{top}->state() eq 'zoomed' ) {
                $geometry =~ s/\+[-0-9]+\+[-0-9]+/+-3+-3/;
            }
        };
    }
    do {
        my $s;
        my @recentFiles = TrEd::RecentFiles::recent_files();
        push @{$conf},
            "Geometry\t=\t" . $TrEd::Config::geometry . "\n",
            "ShowSidePanel\t=\t" . $TrEd::Config::showSidePanel . "\n",
            "CanvasHeight\t=\t" . $TrEd::Config::defCHeight . "\n",
            "CanvasWidth\t=\t" . $TrEd::Config::defCWidth . "\n", map {
            $s = $recentFiles[$_];
            $s =~ s/\\/\\\\/g;
            "RecentFile$_\t=\t$s\n"
            } 0 .. $#recentFiles;

        TrEd::ManageFilelists::update_runtimeconfig_filelists( $s, $conf );

    };
    chomp $conf->[-1];
}



# save configuration to tredrc file
sub save_config {
    my ( $win, $config, $quiet ) = @_;
    require TrEd::Error::Message;
    my $top;
    if ( ref($win) =~ /^Tk::/ ) {
        $top = $win->toplevel;
    }
    else {
        $top = $win->{top};
    }
    my ($default_trc)
        = File::Spec->catfile( $libDir, 'tredrc' );
    if ( Treex::PML::IO::is_same_file( $config_file, $default_trc ) ) {
        $config_file = File::Spec->catfile( $ENV{HOME}, '.tredrc' );
    }
    my $exists = -e $config_file ? 1 : 0;
    if ( !$exists || ( -f $config_file && -w $config_file ) ) {
        my $renamed = q{};
        if ($exists) {
            $renamed = rename $config_file, "${config_file}~";
        }
        if ( open my $fh, '>', "$config_file" ) {
            if (!$quiet) {
                print STDERR "Saving tred configuration to: $config_file\n";
            }
            print $fh (@{$config});
            close $fh;
            return;
        }
        elsif ($renamed) {
            rename "${config_file}~", $config_file;
        }
    }

    # otherwise something went wrong
    {
        my $lasterr = main::conv_from_locale($!);
        my ($trc) = File::Spec->catfile( $ENV{HOME}, '.tredrc' );
        if (!Treex::PML::IO::is_same_file( $config_file, $trc )
            and (
                (   defined $top
                    and $top->messageBox(
                        -icon => 'warning',
                        -message =>
                            "Cannot write configuration to $config_file: $lasterr\n\n"
                            . "Shell I try to save it to ~/.tredrc?\n",
                        -title => 'Configuration cannot be saved',
                        -type  => 'YesNo',

                       # -default=> 'Yes' # problem: Windows 'yes', UNIX 'Yes'
                    ) =~ m(yes)i
                )
                or (    !defined $top
                     && !-f $trc
                     && !defined $cmdline_config_file )
            )
            )
        {
            my $renamed = rename $trc, "${trc}~";
            if ( open my $fh, '>',  $trc ) {
                print STDERR "SAVING CONFIG TO: $trc\n";
                print $fh (@$config);
                print STDERR "done\n";
                close $fh;
                $config_file = $trc;
            }
            else {
                if ($renamed) {
                    rename( "${trc}~", $trc );
                }
                TrEd::Error::Message::error_message(
                    $top,
                    "Cannot write to \"$trc\": $lasterr!\n"
                        . "\nConfiguration could not be saved!\n"
                        . 'Check file and directory permissions.', 
                    1
                );
            }
        }
        else {
            TrEd::Error::Message::error_message(
                $top,
                "Cannot write to \"$config_file\": $lasterr!\n"
                    . "\nConfiguration could not be saved!\n" 
                    . 'Check file and directory permissions.',
                1
            );
        }
    }
    return;
}


1;

__END__

=head1 NAME


TrEd::Config - TrEd's configuration file loader and parser


=head1 VERSION

This documentation refers to
TrEd::Config version 0.2.


=head1 SYNOPSIS

  use TrEd::Config;

  # $default_option = 'default_value'
  my $default_option = TrEd::Config::val_or_def($configuration_hash_ref, 'buttonsrelief', 'default_value');

  # set value in cofiguration hash
  my %confs = (
    "buttonrelief"  => 'other_value',
  );

  # use configuration hash in helper function
  # $option = 'other_value'
  my $option = TrEd::Config::val_or_def($configuration_hash_ref, "buttonsrelief", 'default value');

  my $home = TrEd::Config::tilde_expand("~");

  # apply alternative options right now
  my @alternative_options = (
    "width = 50",
    "height = 100",
  );
  TrEd::Config::apply_config(@alternative_options);

  my $line = "width = 50";
  my $config_ref = {};
  TrEd::Config::parse_config_line($line, $config_ref);
  # $config_ref now contains new key-value pair: 'width' => 50

  # set standard paths where TrEd's config is usually found
  TrEd::Config::set_default_config_file_search_list();

  # read first existing configuration file from list and load all the options into memory
  my @config_paths = qw(/home/john/.tred.d/tredrc /home/john/.tredrc);
  TrEd::Config::read_config(@config_paths);

  # set all the configuration values from $confs_ref
  TrEd::Config::set_config($confs_ref);


=head1 DESCRIPTION

This module contains basic functions for reading and parsing configuration files in simple format

  option_name = "option value"

Comments are created by putting # or ; characters at the beginning of the line.

By default, it exports *a lot of* variables, here is the list:
  @config_file_search_list
  $set_user_config
  $override_options
  $appName
  $buttonsRelief
  $menubarRelief
  $buttonBorderWidth
  $canvasBalloonInitWait
  $canvasBalloonForeground
  $canvasBalloonBackground
  $toolbarBalloonInitWait
  $toolbarBalloonForeground
  $toolbarBalloonBackground
  $activeTextColor
  $treeViewOpts
  $font
  $guiFont
  $vLineFont
  $libDir
  $extensionsDir
  $preinstalledExtensionsDir
  $extensionRepos
  $iconPath
  $appIcon
  $sortAttrs
  $sortAttrValues
  $macroFile
  $default_macro_file
  $default_macro_encoding
  $printOptions
  $showHidden
  $createMacroMenu
  $maxMenuLines
  $useCzechLocales
  $useLocales
  $imageMagickConvert
  $cstsToFs
  $fsToCsts
  $sgmls
  $sgmlsopts
  $cstsdoctype
  $cstsparsecommand
  $cstsparsezcommand
  $keyboardDebug
  $hookDebug
  $macroDebug
  $tredDebug
  $defaultTemplateMatchMethod
  $defaultMacroListOrder
  $defCWidth
  $defCHeight
  $geometry
  $maxDisplayedValues
  $maxDisplayedAttributes
  $highlightWindowColor
  $highlightWindowWidth
  $lastAction
  $reverseNodeOrder
  $valueLineHeight
  $valueLineAlign
  $valueLineWrap
  $valueLineReverseLines
  $valueLineFocusBackground
  $valueLineFocusForeground
  $valueLineBackground
  $valueLineForeground
  $maxUndo
  $reloadKeepsPatterns
  $autoSave
  $displayStatusLine
  $openFilenameCommand
  $saveFilenameCommand
  $NoConvertWarning
  $lockFiles
  $noLockProto
  $stippleInactiveWindows
  $userConf
  $ioBackends
  $htmlBrowser
  $showSidePanel
  $skipStartupVersionCheck
  $enableTearOff
  %defaultPrintConfig
  %c_fonts
  $sidePanelWrap

=head1 SUBROUTINES/METHODS

=over 4


=item * C<TrEd::Config::set_default_config_file_search_list()>

=over 6

=item Purpose

Set @config_file_search_list values to common places where

tredrc cofiguration file (tredrc) is usually found

=item Parameters


=item Comments

Requires FindBin. Tredrc paths are set to HOME environment variable,

TREDHOME environment variable and relative to the original perl script's
directory: under subdirectory tredlib, ../lib/tredlib, ../lib/tred

=item See Also


=item Returns

nothing


=back


=item * C<TrEd::Config::tilde_expand($path_str)>

=over 6

=item Purpose

If string contains tilde, substitute tilde with home directory of current user


=item Parameters

  C<$path_str> -- scalar $path_str -- string containing path



=item Returns

String after the substitution


=back


=item * C<TrEd::Config::parse_config_line($line, $confs_ref)>

=over 6

=item Purpose

Parse each line of the config file to extract key and value pair and

save it into hash $confs_ref

=item Parameters

  C<$line> -- string $line        -- line to be parsed
  C<$confs_ref> -- hash_ref $confs_ref -- hash of configuration key-value pairs

=item Comments

Longer because of comments of quite sophisticated regexp


=item See Also

L<read_config>,

=item Returns

nothing


=back


=item * C<TrEd::Config::read_config(@paths_to_config_file)>

=over 6

=item Purpose

Read configuration values from file and save it to %confs hash


=item Parameters

  C<@paths_to_config_file> -- list @paths_to_config_file -- array containing file name of config file(s)

=item Comments

Tries to open config file, first from list supported by argument, if it does not succeed,

function tries to open files from @config_file_search_list. If any of these files is opened
successfully, the configuration is then read to memory from this file.

=item See Also

L<set_config>,
L<parse_config_line>,

=item Returns

Name/path to config file that was used to read cofiguration values


=back


=item * C<TrEd::Config::apply_config(@options)>

=over 6

=item Purpose

Apply configuration @options


=item Parameters

  C<@options> -- list @options -- list of option_name=option_value strings

=item Comments

Parses configuration @options, calls set_config() with new options


=item See Also

L<set_config>,
L<parse_config_line>,

=item Returns

Nothing


=back


=item * C<TrEd::Config::val_or_def($configuration_hash, $key, $default_value)>

=over 6

=item Purpose

Choose value from $configuration_hash with $key if it exists or $default_value otherwise


=item Parameters

  C<$configuration_hash> -- hash_ref $configuration_hash  -- reference to hash with configuration options
  C<$key> -- scalar $key                   -- string containing name of the option
  C<$default_value> -- scalar $default_value         -- scalar containing the value of configuration option



=item Returns

Value set in $configuration_hash reference with key $key if it exists, $default_value otherwise


=back


=item * C<TrEd::Config::_parse_cmdline_options($confs_ref)>

=over 6

=item Purpose

Parse options from command line switch -O and save them in $confs_ref


=item Parameters

  C<$confs_ref> -- hash_ref @confs_ref -- hash with configuration options

=item Comments

Uses array reference $override_options, where the command line options are

stored. The syntax of -O argument is specified in tred manual, in short these options
are supported:
* name=value    -- set option 'name' to 'value'
* nameX=value   -- treat the option as a list delimited by the delimiter X and prepend the value to the list.
* nameX+=value  -- treat the option as a list delimited by the delimiter X and append the value to the list.
* nameX-=value  -- treat the option as a list delimited by the delimiter X and remove the value from the list (if exists).
Only the following characters can be used as a delimiter:
; : , & | / + - \s \t SPACE
Can be combined, i.e. -O "extensionRepos\\s"-=http://foo/bar -O "extensionRepos\\s"+=http://foo/bar
first removes any occurrence of the URL http://foo/bar from the white-space separated list of extensionRepos and then appends the URL to the end of the list.

=item See Also

L<set_config>,

=item Returns

nothing


=back


=item * C<TrEd::Config::_set_treeViewOpts($confs_ref)>

=over 6

=item Purpose

Set various options in treeViewOpts hash


=item Parameters

  C<$confs_ref> -- hash_ref @confs_ref -- hash with configuration options

=item Comments

Tries to set all options found in treeViewOpts from $confs_ref.

In addition, sets these options: currentNodeHeight, -Width, nodeHeight, -Width,
customColor..., font and backgroundImage
$TrEd::Config::font should be set before running this function e.g. by calling _set_fonts()

=item See Also

L<set_config>,

=item Returns

nothing


=back


=item * C<TrEd::Config::_set_fonts($confs_ref)>

=over 6

=item Purpose

Set font family, size and encoding


=item Parameters

  C<$confs_ref> -- hash_ref $confs_ref -- hash with configuration options

=item Comments

If font is set in $confs_ref, it is used. Otherwise Arial is picked as a default font

on Windows and Helvetica on other OSes.
Function also sets vlinefont, guifont and
guifont_small/small_bold/heading/fixed/default/bold/italic fonts.

=item See Also

L<set_config>,
L<_set_font_encoding>,

=item Returns

nothing


=back


=item * C<TrEd::Config::_set_font_encoding()>

=over 6

=item Purpose

Choose font encoding according to Tk version and TrEd::Convert::outputenc


=item Parameters


=item Comments

If $TrEd::Convert::outputenc is set, it is used, otherwise iso8859-2 is used

with Tk versions older than 804, iso10646-1 for newer versions

=item See Also

L<set_config>,
L<_set_font_encoding>,

=item Returns

Font encoding


=back


=item * C<TrEd::Config::_set_resource_path($confs_ref, $default_share_path)>

=over 6

=item Purpose

Add resource paths from configuration hash and default resource path to $Treex::PML::resourcePath


=item Parameters

  C<$confs_ref> -- hash_ref $confs_ref         -- hash with configuration options
  C<$default_share_path> -- scalar $default_share_path  -- default share path

=item Comments

HOME environment variable should be set before running this function, on Windows,

one can run TrEd::Utils::find_win_home() to set HOME variable for this purpose
Default resource path is constructed from $def_share_path

=item See Also

L<set_config>,
L<_set_font_encoding>,
L<tilde_expand>,

=item Returns

nothing


=back


=item * C<TrEd::Config::_set_print_options($confs_ref)>

=over 6

=item Purpose

Set print options from $defaultPrintConfig, try to find ps, AFM font file and path for TTF fonts


=item Parameters

  C<$confs_ref> -- hash_ref $confs_ref         -- hash with configuration options

=item Comments

Prefers using options in $confs_ref. If the option is not defined there, uses

default option set in %defaultPrintConfig
psFontFile and psFontAFMFile are looked for in directories found in $printOptions,
if they do not exist there, they are looked up in $libDir. If this fails, too,
default paths for font files supplied with TrEd are used.
TTF font directory is determined from the registry on Windows, from /etc/fonts/fonts.conf otherwise

=item See Also

L<set_config>,

=item Returns

nothing


=back


=item * C<TrEd::Config::_set_extensions($confs_ref, $default_share_path)>

=over 6

=item Purpose

Set variables which are related to TrEd extensions


=item Parameters

  C<$confs_ref> -- hash_ref $confs_ref         -- hash with configuration options
  C<$default_share_path> -- scalar $default_share_path  -- default share path

=item Comments

Takes care of setting $extensionsDir, $extensionsRepos and $preinstalledExtensionsDir variables.

Tries to set these variables from $confs_ref, if there is no value in the $confs_ref hash,
function uses default values

=item See Also

L<set_config>,
L<_set_font_encoding>,
L<tilde_expand>,

=item Returns

nothing


=back


=item * C<TrEd::Config::set_config($confs_ref)>

=over 6

=item Purpose

Set configuration values to values in $confs_ref hash (if defined) or to default values


=item Parameters

  C<$confs_ref> -- hash_ref @confs_ref -- hash with configuration options

=item Comments

Also runs $set_user_config($confs_ref) function.


=item See Also

L<apply_config>,
L<read_config>,

=item Returns

nothing


=back



=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Standard Perl modules:
File::Spec, Cwd, FindBin, 


TrEd modules:
TrEd::ManageFilelists, TrEd::Bookmarks, TrEd::RecentFiles

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
