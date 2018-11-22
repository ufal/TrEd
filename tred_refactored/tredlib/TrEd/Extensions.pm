package TrEd::Extensions;

# pajas@ufal.ms.mff.cuni.cz          02 rij 2008

use 5.008;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);
use Scalar::Util qw(blessed);
use File::pushd;

use URI;
use URI::file;

use TrEd::MinMax qw(first);
use TrEd::Utils qw{$EMPTY_STR};
require TrEd::Stylesheet;

BEGIN {
    require Exporter;
    require Treex::PML;

    if ( exists &Tk::MainLoop ) {
        require Tk::DialogReturn;
        require Tk::BindButtons;
        require Tk::ProgressBar;
        require Tk::ErrorReport;
        require Tk::QueryDialog;
    }
    require TrEd::Version;

    use base qw(Exporter);
    our %EXPORT_TAGS = (
        'all' => [
            qw(
                get_extensions_dir
                init_extensions
                get_extension_list
                get_extension_macro_paths
                get_extension_sample_data_paths
                get_extension_doc_paths
                get_preinstalled_extensions_dir
                get_preinstalled_extension_list
                get_extension_template_paths
                get_extension_subpaths
                manage_extensions_dialog
                )
        ]
    );

    # manage_extensions
    our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
    our $VERSION   = '0.02';
}

# used for storing command line options
our $enable_extensions = $EMPTY_STR;
our $disable_extensions = $EMPTY_STR;


my @extension_file_prologue = split /\n\s*/, <<'EOF';
# DO NOT MODIFY THIS FILE
#
# This file only lists installed extensions.
# ! before extension name means the module is disabled
#
EOF

# $ext_1 is required by $ext_2 ~> $required_by{$ext_1}{$ext_2} = 1
my %required_by = ();

# $ext_2 requires $ext_1 ~> $requires{$ext_2}{$ext_1} = 1
my %requires = ();

#######################################################################################
# Usage         : short_name($pkg_name)
# Purpose       : Construct short name for package $pkg_name
# Returns       : Short name for $pkg_name
# Parameters    : scalar or blessed URI ref $pkg_name -- name of the package
# Throws        : no exception
# Comments      : If $pkg name is blessed URI reference, everything from the beginning
#                 of $pkg_name to last slash is removed and the rest is returned.
#                 Otherwise $pkg_name is returned without any modification
sub short_name {
    my ($pkg_name) = @_;
    my $short_name = ( blessed($pkg_name) && $pkg_name->isa('URI') )
        ? do {
                my $name = $pkg_name;
                $name =~ s{.*/}{}x;
                return $name;
             }
        : $pkg_name;
    return $short_name;
}

#######################################################################################
# Usage         : _repo_extensions_uri_list($opts_ref)
# Purpose       : Create list of triples: repository, extension name, extension URI
#                 for repositories listed in $opts_ref->{repositories}
# Returns       : List of array references, each array contains triple repo, extension
#                 name, extension URI
# Parameters    : hash_ref $opts_ref -- reference to hash with options
# Throws        : no exception
# Comments      : Options hash reference should contain list of repositories in
#                 $opts_ref->{repositories}, information about installed extensions
#                 as a hash $opts_ref->{installed}{installed_ext_name}.
#                 If we are updating extensions, $opts_ref->{only_upgrades} should be set.
# See Also      : Treex::PML::IO::make_URI(), URI
sub _repo_extensions_uri_list {
    my ($opts_ref) = @_;
    my @repo_extension_uri_list;

    # Tip: read the comments from the bottom up
    foreach my $repo ( map { Treex::PML::IO::make_URI($_) }
                           @{ $opts_ref->{repositories} } )
    {
        push @repo_extension_uri_list,
            # read the following from the bottom upwards ;)
            # create a triple: repository, short name of extension, URI of the extension
            map { [ $repo, $_, URI->new($_)->abs( $repo . q{/} ) ] }
            # if we are only upgrading, then filter out all the extensions that are not installed
            grep {
            $opts_ref->{only_upgrades}
                ? exists( $opts_ref->{installed}{$_} )
                : 1
            }
            # remove ! from the extension name if it is at the beginning of the name
            map { m/^!(.*)/x ? $1 : $_ }
            # take only those extensions that are defined and their name length is not 0
            grep { length and defined } @{ get_extension_list($repo) };
    }
    return @repo_extension_uri_list;
}

#######################################################################################
# Usage         : _update_progressbar($opts_ref)
# Purpose       : Update progress information and progressbar
# Returns       : Undef in scalar context, empty list in list context
# Parameters    : hash_ref $opts_ref -- reference to hash of options
# Throws        : no exception
# Comments      : Hash of options should contain at least $opts_ref->{progress} and
#                 $opts_ref->{progressbar}
# See Also      :
sub _update_progressbar {
    my ($opts_ref)  = @_;
    my $progress    = $opts_ref->{progress};
    my $progressbar = $opts_ref->{progressbar};

    if ($progress) {
        ${$progress}++;
    }

    if ($progressbar) {
        $progressbar->update();
    }
    return;
}

#######################################################################################
# Usage         : cmp_revisions($my_revision, $other_revision)
# Purpose       : Compare two revision numbers
# Returns       : -1 if $my_revision is numerically less than $other_revision,
#                 0 if $my_revision is equal to $other_revision
#                 1 if $my_revision is greater than $other_revision
#                 Undef/empty list, if one of the revisions is not defined.
# Parameters    : scalar $my_revision     -- first revision string (e.g. 1.256)
#                 scalar $other_revision  -- second revision string (e.g. 1.1024)
# Throws        : no exception
# Comments      : E.g. 1.1024 > 1.256, thus cmp_revisions("1.1024", "1.256") should return 1
sub cmp_revisions {
    my ( $my_revision, $revision ) = @_;
    return if (!defined $my_revision || !defined $revision);
    my @my_revision = split /\./, $my_revision;
    my @revision    = split /\./, $revision;
    my $cmp         = 0;
    while ( $cmp == 0 && ( @my_revision or @revision ) ) {
        $cmp = ( shift(@my_revision) <=> shift(@revision) );
    }
    return $cmp;
}

#######################################################################################
# Usage         : _version_ok($my_version, $required_extension_ref)
# Purpose       : Test whether the installed version of extension is between
#                 min and max required version (if specified)
# Returns       : True if the installed version is ok, false otherwise
# Parameters    : scalar $my_version               -- version of installed extension
#                 hash_ref $required_extension_ref -- ref to hash which contains required version info
# Throws        : no exception
# Comments      : Required extension hash should contain at least min_version and
#                 max_version values
# See Also      : cmp_revisions()
sub _version_ok {
    my ( $my_version, $required_extension_ref ) = @_;

    my $min_version = $required_extension_ref->{min_version} || q{};
    my $max_version = $required_extension_ref->{max_version} || q{};

    return ( !$min_version
            || cmp_revisions( $my_version, $min_version ) >= 0 )
        && ( !$max_version
        || cmp_revisions( $my_version, $max_version ) <= 0 );
}

#######################################################################################
# Usage         : _ext_not_installed_or_actual($meta_data_ref, $installed_ver)
# Purpose       : Test whether the extension is not installed or is not up to date
# Returns       : Extension's version from repository if it is not installed,
#                 True if the extension is installed, but not up to date.
#                 0 if the extension is not installed or up to date $meta_data_ref is not defined
# Parameters    : hash_ref $meta_data_ref -- reference to meta data about the extension
#                 scalar $installed_ver   -- version of installed extension (if any)
# Throws        : no exception
# Comments      :
# See Also      : cmp_revisions()
sub _ext_not_installed_or_actual {
    my ( $meta_data_ref, $installed_ver ) = @_;

    if ($meta_data_ref) {
        return
            # not installed and exists in repository
            (
            ( !$installed_ver && $meta_data_ref->{version} )
                ||
                # installed, but version in repository is newer
                (
                    $installed_ver
                && $meta_data_ref->{version}
                && cmp_revisions( $installed_ver, $meta_data_ref->{version} ) < 0
                )
            );
    }
    else {
        return 0;
    }
}


#######################################################################################
# Usage         : _resolve_missing_dependency({
#                   req_data           => $req_data,
#                   required_extension => $required_extension,
#                   short_name         => $short_name,
#                   repo               => $repo,
#                   dialog_box         => $dialog_box })
# Purpose       : Ask user what to do with unresolved dependencies
# Returns       : User's choice: string 'Cancel', 'Ignore versions'/'Ignore dependencies'
#                 or 'Skip pkg_name'.
#                 Returns undef if correct version of extension is available in the repository.
# Parameters    : hash_ref $req_data           -- reference to hash containing at least 'version' key
#                 hash_ref $required_extension -- reference to hash of info about required extension
#                 scalar $short_name           -- short name of extension whose dependecies are searched for
#                 scalar $repo                 -- URL of the repository which contains $short_name extension
#                 Tk::DialogBox $dialog_box    -- DialogBox object for creating GUI & interaction with the user
# Throws        : no exception
# Comments      : Needs Tk and uses its QuestionQueryAuto function
sub _resolve_missing_dependency {
    my ($args_ref) = @_;

    my $req_data           = $args_ref->{req_data};
    my $required_extension = $args_ref->{required_extension};
    my $short_name         = $args_ref->{short_name};
    my $repo               = $args_ref->{repo};
    my $dialog_box         = $args_ref->{dialog_box};


    my $req_name = $required_extension->{name};
    my $min      = $required_extension->{min_version} || q{};
    my $max      = $required_extension->{max_version} || q{};

    if ($req_data) {
        my $req_version = $req_data->{version};
                                            #vvv-- beware of the second argument, it is not a number!
        if ( !_version_ok( $req_version, $required_extension ) ) {
            return $dialog_box->parent->QuestionQueryAuto({
                -title => 'Error',
                -label =>
                    "Package $short_name from $repo\nrequires package $req_name "
                    . " in version $min..$max, but only $req_version is available",
                -buttons =>
                    [ "Skip $short_name", 'Ignore versions', 'Cancel' ],
            });
        }
    }
    else {    # no req_data
        return $dialog_box->parent->QuestionQueryAuto({
            -title => 'Error',
            -label =>
                "Package $short_name from $repo\nrequires package $req_name "
                . " which is not available",
            -buttons =>
                [ "Skip $short_name", 'Ignore dependencies', 'Cancel' ],
        });
    }
    return;
}

#######################################################################################
# Usage         : _add_required_exts({
#                   extension_data_ref    => $extension_data_ref,
#                   extensions_list_ref   => $extensions_list_ref,
#                   uri_in_repository_ref => \%uri_in_repository,
#                   uri                   => $uri,
#                   short_name            => $short_name,
#                   dialog_box            => $dialog_box,
#                   opts_ref              => $opts_ref,
#                 })
# Purpose       : Check requirements of each extension that is required by $uri extension
#                 and add all the requirements to $extensions_list_ref
#                 (if they are not already in the list, installed or up-to date)
# Returns       : String 'Cancel' if user chooses to cancel installation,
#                 'Skip' if user chooses to skip extension $uri, undef otherwise
# Parameters    : hash_ref $extension_data_ref    -- hash reference to extension's meta data
#                 array_ref $extensions_list_ref  -- reference to array containing list of information about extensions
#                 hash_ref $uri_in_repository_ref -- ref to hash of URIs in repositories
#                 scalar $uri                     -- URI of the extension whose requirements are searched for
#                 scalar $short_name              -- name of the extension whose requirements are searched for
#                 Tk::DialogBox $dialog_box       -- dialog box for creating GUI elements
#                 hash_ref $opts_ref              -- populate_extension_pane options
# Throws        : no exception
# Comments      : If any of the required extensions is missing, user is prompted with dialog
#                 to choose whether TrEd should ignore the dependency, cancel the installation
#                 or skip installation of the extension.
#                 $extensions_list_ref and $uri_in_repository_ref can be modified as a side effect
#                 during finding new dependencies. This function can also modify %requires and
#                 required_by hash.
# See Also      : _resolve_missing_dependency(),
sub _add_required_exts {
    my ($arg_ref) = @_;

    my $extension_data_ref    = $arg_ref->{extension_data_ref};
    my $extensions_list_ref   = $arg_ref->{extensions_list_ref};
    my $uri_in_repository_ref = $arg_ref->{uri_in_repository_ref};
    my $uri                   = $arg_ref->{uri};
    my $short_name            = $arg_ref->{short_name};
    my $dialog_box            = $arg_ref->{dialog_box};
    my $opts_ref              = $arg_ref->{opts_ref};

    # get meta data about dependent extension
    my $meta_data_ref = $extension_data_ref->{$uri}
        ||= get_extension_meta_data($uri);

    # find required packages and their versions
    $requires{$uri} = [];
    my %seen;

    # this can be a little tricky: if any of those three expressions
    # is false, $require would be false/0. However, if all of them
    # are true, last one is used as the value for $require
    my $require
        = $meta_data_ref
        && ref $meta_data_ref->{require}
        && $meta_data_ref->{require};
    if ( !exists( $seen{$uri} ) && $require ) {
        $seen{$uri} = 1;
        for my $required_extension ( $require->values('extension') ) {
            for ( grep {defined}
                ( $required_extension->{name}, $required_extension->{href} ) )
            {
                Encode::_utf8_off($_);
            }
            my $req_name          = $required_extension->{name};
            my $installed_req_ver = $opts_ref->{installed}{$req_name};

            next
                if ( $installed_req_ver
                && _version_ok( $installed_req_ver, $required_extension ) );

            # If we are here, required extension is not installed
            # or it's not up-to-date
            my $repo = $meta_data_ref->{repository}
                && $meta_data_ref->{repository}{href};
            my $req_uri
                = (
                $repo
                    && (
                    !$required_extension->{href}
                    || ( URI->new(q{.})->abs( $required_extension->{href} ) eq
                        $repo )
                    )
                )
                ? URI->new($req_name)->abs($uri)
                : URI->new( $required_extension->{href} || $req_name )
                ->abs($uri);

            # get meta data about required extension from its xml file
            my $req_data = $extension_data_ref->{$req_uri}
                ||= get_extension_meta_data($req_uri);

            # what does the user want to do with missing dependency?
            my $res = _resolve_missing_dependency(
                {   req_data           => $req_data,
                    required_extension => $required_extension,
                    short_name         => $short_name,
                    repo               => $repo,
                    dialog_box         => $dialog_box,
                }
            );

            return 'Cancel' if ( defined($res) && $res eq 'Cancel' );
            return 'Skip' if ( defined($res) && $res =~ m/^Skip/ );

            # add URI of the required extension to $requires{$URI} array
            push @{ $requires{$uri} }, $req_uri;
            # and fill also %required_by hash
            _fill_required_by($uri);

            # Add dependent extension to $extensions_list_ref,
            # if URI of the required extension is not already listed
            # in the list
            if (   !exists $seen{$req_uri}
                && !exists $uri_in_repository_ref->{$req_uri} )
            {
                push @{$extensions_list_ref},
                    [ URI->new(q{.})->abs($req_uri), $req_name, $req_uri ];
            }
        }
    }
    return;
}

#######################################################################################
# Usage         : _fill_required_by($id)
# Purpose       : Construct hash with information, which extensions depend on specified
#                 extension from $requires hash
# Returns       : Undef/empty list
# Parameters    : scalar $id -- extension's identification (URI/name)
# Throws        : no exception
# Comments      : Uses $requires and $required_by package variables
sub _fill_required_by {
    my ($id) = @_;
    foreach my $dependency ( @{ $requires{$id} } ) {
        $required_by{$dependency}{$id} = 1;
    }
    return;
}

#######################################################################################
# Usage         : _uri_list_with_required_exts({
#                   extension_data_ref  => $extension_data_ref,
#                   opts_ref            => $opts_ref,
#                   dialog_box          => $dialog_box,
#                 });
# Purpose       : Create list of URIs of extensions that are not installed or up-to date
#                 from repository specified in opts_ref hash
# Returns       : Reference to array of URIs or undef/empty list if cancelled by user
# Parameters    : hash_ref $extension_data_ref   -- ref to hash of meta data about extensions
#                 hash_ref $opts_ref             -- ref to hash of populate_extension_pane options
#                 Tk::DialogBox $dialog_box      -- dialg box to create GUI elements
# Throws        : no exception
# Comments      : opts_ref hash should contain an element with name 'repositories', whose
#                 value is a reference to array of extension repositories (as their URIs) and
#                 an element with key 'installed', whose value is a hash reference
#                 with names of isntalled extensions as keys and their installed versions as
#                 corresponding values.
# See Also      : _update_progressbar(), _ext_not_installed_or_actual(), _add_required_exts(), _fill_required_by()
sub _uri_list_with_required_exts {
    my ($arg_ref) = @_;

    my $extension_data_ref = $arg_ref->{extension_data_ref};
    my $opts_ref           = $arg_ref->{opts_ref};
    my $dialog_box         = $arg_ref->{dialog_box};
    my $short_circuit      = $arg_ref->{short_cicruit};

    # for each repository find all the available extensions
    # (if we are updating, only those that are already installed)
    my @list_of_extensions = _repo_extensions_uri_list($opts_ref);

    my $progressbar = $opts_ref->{progressbar};

    # set the progress bar
    if ($progressbar) {
        $progressbar->configure(
            -to     => scalar(@list_of_extensions),
            -blocks => scalar(@list_of_extensions),
        );
    }

    my $i = 0;
    my %uri_in_repository;
    @uri_in_repository{ map { $_->[2] } @list_of_extensions } = ();
PKG:
    while ( $i < @list_of_extensions ) {
        my ( $repo, $short_name, $uri ) = @{ $list_of_extensions[$i] };

        # read metadata from package.xml (or from cache)
        my $meta_data_ref = $extension_data_ref->{$uri}
            ||= get_extension_meta_data($uri);

        # if the extension is installed, find its version
        my $installed_ver = $opts_ref->{installed}{$short_name};
        $installed_ver ||= 0;

        if ( exists $uri_in_repository{$uri} ) {
            _update_progressbar($opts_ref);
        }

        # if extension is found in repository and it is not installed
        # or there is a newer version in repository, increment $i
        if ( _ext_not_installed_or_actual( $meta_data_ref, $installed_ver ) )
        {
            $i++;
        }
        else {

            # remove the extensions from the list,
            # if it is installed & up to date
            splice @list_of_extensions, $i, 1;

            # and go from the beginning to process another extension
            next PKG;
        }

        # add required extensions to @list_of_extensions and @$requires{$uri}
        my $res = _add_required_exts(
            {   extension_data_ref    => $extension_data_ref,
                extensions_list_ref   => \@list_of_extensions,
                uri_in_repository_ref => \%uri_in_repository,
                uri                   => $uri,
                short_name            => $short_name,
                dialog_box            => $dialog_box,
                opts_ref              => $opts_ref,
                short_circuit         => $short_circuit,
            }
        );

        # handle user-chosen resolutions of missing packages
        return   if ( defined($res) && $res eq 'Cancel' );
        next PKG if ( defined($res) && $res eq 'Skip' );

    }
    my $list_of_uris = [ map { $_->[2] } @list_of_extensions ];
    return $list_of_uris;
}

#######################################################################################
# Usage         : _list_of_installed_extensions({
#                   pre_installed_ref   => $pre_installed_ref,
#                   enable_ref          => $enable_ref,
#                   opts_ref            => $opts_ref,
#                   extension_data_ref  => $extension_data_ref,
#                 });
# Purpose       : Create list of URIs of preinstalled and installed extensions
# Returns       : Reference to array of URIs
# Parameters    : hash_ref pre_installed_ref        -- ref to hash of pre-installed extensions
#                 hash_ref $enable_ref              -- ref to hash of enabled extensions
#                 hash_ref $opts_ref                -- ref to hash of populate_extension_pane options
#                 hash_ref $extension_data_ref      -- ref to hash of meta data about extensions
# Throws        : no exception
# Comments      : Also creates a hash of enabled extensions (those that are listed with exclamation
#                 mark in the beginning are disabled). As a side effect, requires and required_by hashes
#                 are updated with new information about the extensions.
#                 Only 'progressbar' option is used from $opts_ref hash in this function.
# See Also      : _update_progressbar(), _ext_not_installed_or_actual(), _add_required_exts(), _fill_required_by()
sub _list_of_installed_extensions {
    my ($args_ref) = @_;

    my $pre_installed_ref  = $args_ref->{pre_installed_ref};
    my $enable_ref         = $args_ref->{enable_ref};
    my $opts_ref           = $args_ref->{opts_ref};
    my $extension_data_ref = $args_ref->{extension_data_ref};

    my $ext_list_ref = get_extension_list();
    my $pre_installed_ext_list
        = get_preinstalled_extension_list($ext_list_ref);

    my $progressbar = $opts_ref->{progressbar};
    if ($progressbar) {
        $progressbar->configure(
            -to => scalar( @{$ext_list_ref} + @{$pre_installed_ext_list} ),
            -blocks =>
                scalar( @{$ext_list_ref} + @{$pre_installed_ext_list} ),
        );
    }

    %{$pre_installed_ref} = map { $_ => 1; } @{$pre_installed_ext_list};
    for my $name ( @{$ext_list_ref}, @{$pre_installed_ext_list} ) {

        # mark extensions with ! as not enabled
        $enable_ref->{$name} = 1;
        if ( $name =~ s{^!}{} ) {
            $enable_ref->{$name} = 0;
        }
        my $meta_data_ref = $extension_data_ref->{$name}
            = get_extension_meta_data(
            $name,
            exists( $pre_installed_ref->{$name} )
            ? get_preinstalled_extensions_dir()
            : ()
            );

        _update_progressbar($opts_ref);

        my $require
            = $meta_data_ref
            && ref $meta_data_ref->{require}
            && $meta_data_ref->{require};
        if ($require) {
            $requires{$name}
                = $require
                ? [ map { $_->{name} } $require->values('extension') ]
                : [];
        }

        _fill_required_by($name);
    }
    push( @{$ext_list_ref}, @{$pre_installed_ext_list} );
    return $ext_list_ref;
#    my @list = map { $extension_data_ref->{$_}{repository}{href} . $_ } keys %{$enable_ref};
#    return \@list;
}

#######################################################################################
# Usage         : _create_ext_list({
#                   pre_installed_ref     => \%pre_installed,
#                   extension_data_ref    => \%extension_data,
#                   enable_ref            => \%enable,
#                   opts_ref              => $opts_ref,
#                   dialog_box            => $dialog_box,
#                 });
# Purpose       : Create list of extensions
# Returns       : Reference to list of extensions/their URIs
# Parameters    : hash_ref $pre_installed_ref   -- ref to empty hash of preinstalled extensions (filled by _list_of_installed_extensions)
#                 hash_ref $extension_data_ref  -- ref to empty hash of extensions' data (filled by this function)
#                 hash_ref $enable_ref          -- ref to empty hash of enabled & disabled extensions (filled by this function)
#                 hash_ref $opts_ref            -- ref to hash of options
#                 Tk::DialogBox $dialog_box     -- dialg box to create GUI elements
# Throws        : no exception
# Comments      : If $opts_ref->{install} is set to true, list of URIs of extensions that are not
#                 installed or are not up-to date is returned. Otherwise, list of installed
#                 and preinstalled extensions' names is returned.
#                 extension_data_ref is filled accordingly, i.e. if list of URIs is returned,
#                 the keys of %{$extension_data_ref} hash are URIs, otherwise the keys are names
#                 of extensions.
# See Also      : _list_of_installed_extensions(), _uri_list_with_required_exts()
sub _create_ext_list {
    my ($args_ref) = @_;

    my $pre_installed_ref  = $args_ref->{pre_installed_ref};
    my $extension_data_ref = $args_ref->{extension_data_ref};
    my $enable_ref         = $args_ref->{enable_ref};
    my $opts_ref           = $args_ref->{opts_ref};
    my $dialog_box         = $args_ref->{dialog_box};
    my $short_circuit      = $args_ref->{short_circuit};

    my $ext_list_ref;

    if ( $opts_ref->{install} ) {
        $ext_list_ref = _uri_list_with_required_exts(
            {   extension_data_ref => $extension_data_ref,
                opts_ref           => $opts_ref,
                dialog_box         => $dialog_box,
                short_circuit      => $short_circuit,
            }
        );
    }
    else {
        $ext_list_ref = _list_of_installed_extensions(
            {   pre_installed_ref  => $pre_installed_ref,
                enable_ref         => $enable_ref,
                opts_ref           => $opts_ref,
                extension_data_ref => $extension_data_ref,
            }
        );

    }
    return $ext_list_ref;
}

#######################################################################################
# Usage         : _required_tred_version($extension_data_ref)
# Purpose       : Test whether TrEd's version corresponds with extension's requirements
# Returns       : Empty string if TrEd's version is ok, error message otherwise
# Parameters    : hash_ref $extension_data_ref -- ref to hash with meta data about the extension
# Throws        : no exception
# See Also      : TrEd::Version::CMP_TRED_VERSION_AND(), TrEd::Version::TRED_VERSION()
sub _required_tred_version {
    my ($extension_data_ref) = @_;

    my $requires_different_tred = q{};
    my @req_tred
        = $extension_data_ref
        && $extension_data_ref->{require}
        && $extension_data_ref->{require}->values('tred');
    foreach my $requirements (@req_tred) {
        if ( $requirements->{min_version} ) {
            if (TrEd::Version::CMP_TRED_VERSION_AND(
                    $requirements->{min_version}
                ) < 0
                )
            {
                if ($requires_different_tred) {
                    $requires_different_tred .= ' and ';
                }
                $requires_different_tred
                    = 'at least ' . $requirements->{min_version};
            }
        }
        if ( $requirements->{max_version} ) {
            if (TrEd::Version::CMP_TRED_VERSION_AND(
                    $requirements->{max_version}
                ) > 0
                )
            {
                if ($requires_different_tred) {
                    $requires_different_tred .= ' and ';
                }
                $requires_different_tred
                    = 'at most ' . $requirements->{max_version};
            }
        }
    }

    if ( length $requires_different_tred ) {
        $requires_different_tred
            = 'Requires TrEd '
            . $requires_different_tred
            . ' (this is '
            . TrEd::Version::TRED_VERSION() . ')';
    }
    return $requires_different_tred;
}

#######################################################################################
# Usage         : _required_perl_modules($req_modules_ref)
# Purpose       : Test whether all the perl module dependencies of extension are satisfied
# Returns       : Empty string if all the dependencies are installed, error message otherwise
# Parameters    : array_ref $req_modules_ref -- ref to list of required perl modules
# Throws        : no exception
# See Also      : compare_module_versions(), get_module_version()
sub _required_perl_modules {
    my ($req_modules_ref) = @_;

    my $requires_modules = q{};
    foreach my $requirements ( @{$req_modules_ref} ) {
        next
            if ( !$requirements->{name}
            || ( lc( $requirements->{name} ) eq 'perl' ) );
        my $req = q{};
        my $available_version
            = eval { get_module_version( $requirements->{name} ) };
        next if $@;
        if ( defined $available_version ) {
            if ( $requirements->{min_version} ) {
                if (compare_module_versions( $available_version,
                        $requirements->{min_version} ) < 0
                    )
                {
                    $req = 'at least ' . $requirements->{min_version};
                }
            }
            if ( $requirements->{max_version} ) {
                if (compare_module_versions( $available_version,
                        $requirements->{max_version} ) > 0
                    )
                {
                    if ($req) {
                        $req .= ' and ';
                    }
                    $req = 'at most ' . $requirements->{max_version};
                }
            }
        }
        if ( length $req || !defined $available_version ) {
            $requires_modules
                .= "\n\t"
                . $requirements->{name} . q{ }
                . $req . q{ }
                . (
                defined($available_version)
                ? "(installed version: $available_version)"
                : '(not installed)'
                );
        }
    }
    if ( length $requires_modules ) {
        $requires_modules = 'Requires Perl Modules:' . $requires_modules;
    }
    return $requires_modules;
}

#######################################################################################
# Usage         : _required_perl_version($req_modules_ref)
# Purpose       : Test whether the perl's version corresponds with extension's requirements
# Returns       : Empty string if Perl's version is ok, error message otherwise
# Parameters    : array_ref $req_modules_ref -- ref to list of requirements
# Throws        : no exception
# See Also      :
sub _required_perl_version {
    my ($req_modules_ref) = @_;

    my $requires_perl = $EMPTY_STR;
    foreach my $requirements ( grep { length $_ && lc( $_->{name} // '' ) eq 'perl' }
                               @{$req_modules_ref} )
    {
        my $req = $EMPTY_STR;
        if ( $requirements->{min_version} ) {
            if ( $] < $requirements->{min_version} ) {
                $req = 'at least ' . $requirements->{min_version};
            }
        }
        if ( $requirements->{max_version} ) {
            if ( $] > $requirements->{max_version} ) {
                if ($req) {
                    $req .= ' and ';
                }
                $req = 'at most ' . $requirements->{max_version};
            }
        }
        if ( length $req ) {
            $requires_perl = 'Requires Perl ' . $req . " (this is $])";
        }
    }
    return $requires_perl;
}

#######################################################################################
# Usage         : _find_uninstallable_exts($ext_list_ref, $extension_data_ref)
# Purpose       : Test all the requirements of extension from @$ext_list_ref
# Returns       : Reference to hash of extensions that can't be installed
# Parameters    : array_ref $ext_list_ref       -- ref to array of extensions' URIs/names
#                 hash_ref $extension_data_ref  -- ref to hash of extensions' meta data
# Throws        : no exception
# Comments      :
# See Also      : _required_tred_version(), _required_perl_modules(), _required_perl_version()
sub _find_uninstallable_exts {
    my ( $ext_list_ref, $extension_data_ref ) = @_;
    my %uninstallable;

    # for each extension
    for my $name ( @{$ext_list_ref} ) {
        my $data = $extension_data_ref->{$name};
        next if !( ( blessed($name) && $name->isa('URI') ) );

        # test tred requirements
        my $requires_different_tred = _required_tred_version($data);

        my @req_modules
            = $data
            && $data->{require}
            && $data->{require}->values('perl_module');

        # perl modules requirements
        my $requires_modules = _required_perl_modules( \@req_modules );

        # perl version requirements
        my $requires_perl = _required_perl_version( \@req_modules );

        my $all_requirements = join(
            "\n",
            grep { defined($_) and length($_) } (
                $requires_different_tred, $requires_perl,
                $requires_modules
            )
        );
        if ( length $all_requirements ) {
            $uninstallable{$name} = $all_requirements;
        }
    }
    return \%uninstallable;
}

#######################################################################################
# Usage         : _dependencies_of_req_exts($ext_list_ref, $uninstallable_ref)
# Purpose       : Test whether all the dependecies of extensions from @$ext_list_ref are satisfied
# Returns       : Undef/empty list
# Parameters    : array_ref $ext_list_ref     -- ref to list of extensions' names
#                 hash_ref $uninstallable_ref -- ref to hash of extensions that can't be installed (due to unsatisfied dependencies)
# Throws        : no exception
# Comments      : Modifies $uninstallable_ref hash according to the uninstallability of
#                 required extensions
# See Also      :
sub _dependencies_of_req_exts {
    my ( $ext_list_ref, $uninstallable_ref ) = @_;

    # for each extension from URI list
    for my $name ( @{$ext_list_ref} ) {

        # if there is a dependency (TrEd version, Perl or Perl module)
        # missing for the extension $name, go to next one
        next if $uninstallable_ref->{$name};

        # create queue from required extensions
        my @queue = @{ $requires{$name} };
        my %seen;
        @seen{@queue} = ();

        # search for unsatisfied dependencies among required extensions
        while (@queue) {
            my $required_ext = shift @queue;
            if ( $uninstallable_ref->{$required_ext} ) {

                # required extension requires different TrEd version,
                # Perl version or some Perl modules,
                # -> mark dependent extension as uninstallable
                if ( $uninstallable_ref->{$name} ) {
                    $uninstallable_ref->{$name} .= "\n";
                }
                $uninstallable_ref->{$name} .= 'Depends on uninstallable '
                    . short_name($required_ext);
            }

            # put requirements of required extension into queue
            # to process them later (BFS - like, since we use push
            # (to the end of array) & shift(from the beginning))
            my @more
                = grep { !exists( $seen{$_} ) } @{ $requires{$required_ext} };
            @seen{@more} = ();
            push( @queue, @more );
        }
    }
    return;
}

#######################################################################################
# Usage         : _set_extension_icon({
#                   data              => $data,
#                   name              => $name,
#                   pre_installed_ref => $pre_installed_ref,
#                   text              => $text,
#                   generic_icon      => $generic_icon,
#                   opts_ref          => $opts_ref,
#                 });
# Purpose       : Set extension's icon
# Returns       : Tk::Label object with icon set
# Parameters    : hash_ref $data              -- ref to hash with extension's meta data
#                 scalar/URI $name            -- name or URI of the extension
#                 hash_ref $pre_installed_ref -- ref to hash containing names of preinstalled extensions (& empty values)
#                 Tk::ROText $text            -- ref to ROText on which the Labels/icons are created
#                 Tk::Photo $generic_icon     -- ref to Tk::Photo with generic extension icon
#                 hash_ref $opts_ref          -- ref to options hash
# Throws        : carp if the icon could not be loaded
# Comments      : If extension's meta $data->{icon} is set, it is used.
#                 Generic icon is used otherwise.
# See Also      :
sub _set_extension_icon {
    my ($args_ref) = @_;

    my $data_ref          = $args_ref->{data_ref};
    my $name              = $args_ref->{name};
    my $pre_installed_ref = $args_ref->{pre_installed_ref};
    my $text              = $args_ref->{text};
    my $generic_icon      = $args_ref->{generic_icon};
    my $opts_ref          = $args_ref->{opts_ref};

    my $extension_dir = $opts_ref->{extensions_dir} || get_extensions_dir();
    my $image;

    if ( $data_ref && $data_ref->{icon} ) {
        my ( $path, $unlink, $format );

        # construct path of the image
        if ( ( blessed($name) and $name->isa('URI') ) ) {
            ( $path, $unlink ) = eval {
                Treex::PML::IO::fetch_file(
                    URI->new( $data_ref->{icon} )->abs( $name . q{/} ) );
            };
        }
        else {
            my $dir
                = exists( $pre_installed_ref->{$name} )
                ? get_preinstalled_extensions_dir()
                : $extension_dir;
            $path = File::Spec->rel2abs( $data_ref->{icon},
                File::Spec->catdir( $dir, $name ) );
        }
        {    #DEBUG;
            $path ||= q{};

            # print STDERR "Extensions.pm: $name => $data->{icon}\n";
        }
        if ( defined($path) and -f $path ) {
            require Tk::JPEG;
            require Tk::PNG;
            my $result = eval {
                my $img = $text->Photo(
                    -file   => $path,
                    -format => $format,
                    -width  => 0,
                    -height => 0,
                );
                $image
                    = $text->Label( -image => $img, -background => 'white' );
            };
            carp($@) if ( $@ || !defined $result );

            # cleaning up after from Treex::PML::IO::fetch_file()
            if ($unlink) {
                unlink $path;
            }
        }
    } # no icon specified in extension's meta data -- use default generic icon
    else {
        require Tk::JPEG;
        require Tk::PNG;
        my $res = eval {
            $image = $text->Label(
                -image      => $generic_icon,
                -background => 'white'
            );
        };
        carp($@) if ( $@ || !defined $res );
    }
    return $image;
}

#######################################################################################
# Usage         : _set_name_desc_copyright({
#                   data_ref          => $data_ref,
#                   name              => $name,
#                   pre_installed_ref => \%pre_installed,
#                   text              => $text,
#                   opts_ref          => $opts_ref,
#                 });
# Purpose       : Set name, description and copyright information for extension
# Returns       : Undef/empty list
# Parameters    : hash_ref $data_ref          -- ref to hash containing meta data of the extension
#                 scalar $name                -- name of the extension
#                 hash_ref $pre_installed_ref -- ref to hash of preinstalled extensions
#                 Tk::ROText $text            -- ROText where the text is added
#                 hash_ref $opts_ref          -- ref to hash of options
# Throws        : no exception
# Comments      : If $data_ref is not set, $name is used as name, other fields are left blank
# See Also      :
sub _set_name_desc_copyright {
    my ($args_ref) = @_;

    my $data_ref          = $args_ref->{data_ref};
    my $name              = $args_ref->{name};
    my $pre_installed_ref = $args_ref->{pre_installed_ref};
    my $text              = $args_ref->{text};
    my $opts_ref          = $args_ref->{opts_ref};

    if ($data_ref) {
        $opts_ref->{versions}{$name} = $data_ref->{version};

        my $version
            = ( defined( $data_ref->{version} )
                && length( $data_ref->{version} ) )
            ? q{ }
            . $data_ref->{version}
            : q{};

        $text->insert( 'end', $data_ref->{title}, [qw(title)] );
        $text->insert( 'end', ' (' . short_name($name) . $version . ')',
            [qw(name)] );
        $text->insert( 'end', "\n" );
        my $require = $data_ref->{require};

        #     $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
        my $desc = $data_ref->{description} || 'N/A';
        $desc =~ s/\s+/ /g;
        $desc =~ s/^\s+|\s+$//g;

        #'Description: ',[qw(label)],
        $text->insert( 'end', $desc, [qw(desc)], "\n" );

        if ( ref( $data_ref->{copyright} ) ) {
            my $c_year
                = $data_ref->{copyright}{year}
                ? ' (c) ' . $data_ref->{copyright}{year}
                : q{};
            $text->insert( 'end',
                'Copyright ' . $data_ref->{copyright}{'#content'} . $c_year,
                [qw(copyright)], "\n" );
        }
    }
    else {
        $text->insert( 'end', 'Name: ', [qw(label)], $name, [qw(name)],
            "\n" );
        $text->insert( 'end', 'Description: ',
            [qw(label)], 'N/A', [qw(desc)], "\n\n" );
    }
    return;
}

#######################################################################################
# Usage         : _fmt_size($size)
# Purpose       : Convert (and round) information amount from bytes to MiB, KiB or GiB,
#                 so that numerical part of the expression is an integer between 1 and 1023
# Returns       : Number with information unit
# Parameters    : scalar $size -- number of bytes
# Throws        : no exception
sub _fmt_size {
    my ($size) = @_;
    my $unit;
    # magnitude multiplier
    my $magnitude = 1024;
    foreach my $order (qw{B KiB MiB GiB}) {
        $unit = $order;
        if ( $size < $magnitude ) {
            last;
        }
        else {
            $size = $size / $magnitude;
        }
    }
    return sprintf( "%d %s", $size, $unit );
}

#######################################################################################
# Usage         : _set_ext_size($data_ref, $text, $name)
# Purpose       : Insert size of extension $name to $text
# Returns       : Undef/empty list
# Parameters    : hash_ref $data_ref  -- ref to hash containing meta data about the extension
#                 Tk::ROText $text    -- ROText where the info about extension's size is added
#                 scalar $name        -- extension's name
# Throws        : no exception
# Comments      : Only added if $data_ref->{install_size} or $data_ref->{package_size} is set
# See Also      : _fmt_size()
sub _set_ext_size {
    my ( $data_ref, $text, $name ) = @_;
    if ( $data_ref
        and ( $data_ref->{install_size} or $data_ref->{package_size} ) )
    {
        $text->insert( 'end', '(Size: ' );
        if ( ( blessed($name) and $name->isa('URI') ) ) {
            if ( $data_ref->{package_size} ) {
                $text->insert( 'end',
                    _fmt_size( $data_ref->{package_size} ) . ' package' );
            }
            if ( $data_ref->{package_size} && $data_ref->{install_size} ) {
                $text->insert( 'end', ' / ' );
            }
        }
        if ( $data_ref->{install_size} ) {
            $text->insert( 'end',
                _fmt_size( $data_ref->{install_size} ) . ' installed' );
        }
        $text->insert( 'end', ") " );
    }
    return;
}

#######################################################################################
# Usage         : _required_by($name, $exists_ref)
# Purpose       : Find all the dependendents for $name listed in %required_by
#                 hash; continue recusively for all dependendents which exist
#                 in $exists_ref hash
# Returns       : List of dependendents
# Parameters    : scalar $name          -- name of entity, whose dependecies are searched for
#                 hash_ref $exists_ref  -- reference to hash containing elements for which the recursion is allowed
# Throws        : no exception
# Comments      :
# See Also      : _requires()
sub _required_by {
    my ( $name, $exists_ref ) = @_;
    my %dependents_of;
    my @test_deps = ($name);
    while (@test_deps) {
        my $n = shift @test_deps;
        if ( not exists $dependents_of{$n} ) {
            push @test_deps,
                grep { exists( $exists_ref->{$n} ) }
                keys %{ $required_by{$n} };
            $dependents_of{$n} = $n;
        }
    }
    return values(%dependents_of);
}

#######################################################################################
# Usage         : _requires($name, $exists_ref)
# Purpose       : Find all the dependendencies for $name listed in %requires
#                 hash; continue recusively for all dependencies which exist
#                 in $exists_ref hash
# Returns       : List of dependencies
# Parameters    : scalar $name          -- name of entity, whose dependecies are searched for
#                 hash_ref $exists_ref  -- reference to hash containing elements for which the recursion is allowed
# Throws        : no exception
# Comments      :
# See Also      : _required_by()
sub _requires {
    my ( $name, $exists_ref ) = @_;
    my %dependencies_of;
    my @deps = ($name);
    while (@deps) {
        my $n = shift @deps;

        # is it already in the list?
        if ( not exists $dependencies_of{$n} ) {
            if ( $requires{$n} ) {
                push @deps,
                    grep { exists( $exists_ref->{$_} ) } @{ $requires{$n} };
            }
            $dependencies_of{$n} = $n;
        }
    }
    return values(%dependencies_of);
}

#######################################################################################
# Usage         : _upgrade_install_checkbutton(\%enable, $ext_name)
# Purpose       : Mark extension and its requirements to be installed/upgraded
# Returns       : Undef/Empty list
# Parameters    : hash_ref $enable_ref  -- ref to hash of extensions to install/upgrade
#                 scalar $ext_name      -- name of extension
# Throws        : no exception
# Comments      : Upgrade/install checkbox callback -- called every time checkbox's state changes
#                 If extension is selected, adds reflexive dependency and enables all required extensions.
#                 If it is unselected, removes reflexive dependency and disables required extensions,
#                 if they are not required by another extension (which does not have to be installed -> why is that? :/).
# See Also      : _requires(),
sub _upgrade_install_checkbutton {
    my ( $enable_ref, $ext_name ) = @_;

# print "Enable: $enable->{$name}, $name, ",join(",",map { $_->{name} } @$requires),"\n";;

    #extension enabled -> say it is required by itself
    if ( $enable_ref->{$ext_name} == 1 ) {
        $required_by{$ext_name}{$ext_name} = 1;
    }
    else {

        # extension disabled -> not required by itself
        delete $required_by{$ext_name}{$ext_name};

# if there are any extensions required by $ext_name extension, enable it and return
        if ( keys %{ $required_by{$ext_name} } ) {
            $enable_ref->{$ext_name} = 1;    # do not allow
            return;
        }
    }

    # find all enabled dependencies for $ext_name extension (recursively)
    my @req = _requires( $ext_name, $enable_ref );
    foreach my $required_ext_uri (@req) {

# if $ext_name extension requires itself or dependency is not listed in enable_ref,
# don't do any changes to enable_ref
        next
            if ( $required_ext_uri eq $ext_name
            || !exists( $enable_ref->{$required_ext_uri} ) );

# if dependent extension is enabled, enable also $required_ext_uri extension and
        if ( $enable_ref->{$ext_name} == 1 ) {
            $enable_ref->{$required_ext_uri} = 1;

            # $required_ext_uri is required_by $ext_name
            $required_by{$required_ext_uri}{$ext_name} = 1;
        }
        elsif ( $enable_ref->{$ext_name} == 0 ) {

            # $required_ext_uri is not required_by $ext_name
            #delete $required_by{$required_ext_uri}{$ext_name};
            # if required extension $href
            #unless (keys(%{$required_by{$required_ext_uri}})) {
            $enable_ref->{$required_ext_uri} = 0;

            #}
        }
    }
    return;
}

#######################################################################################
# Usage         : _enable_checkbutton($name, $opts_ref, $enable_ref, $dialog_box)
# Purpose       : Enable/disable extensions and their dependants
# Returns       : Undef/empty list
# Parameters    : scalar $name              -- name of extension which is being enabled/disabled
#                 hash_ref $opts_ref        -- ref to hash of options
#                 hash_ref $enable_ref      -- ref to hash of extensions to enable/disable
#                 Tk::DialogBox $dialog_box -- dialog box to create GUI elements
# Throws        : no exception
# Comments      : Enable checkbox callback -- called every time checkbox's state changes.
#                 Updates also the extensions list file.
# See Also      : update_extensions_list(), _requires(), _required_by()
sub _enable_checkbutton {
    my ( $name, $opts_ref, $enable_ref, $dialog_box ) = @_;
    my ( @required_extensions, @dependent_extensions );
    if ( $enable_ref->{$name} ) {
        @required_extensions = _requires( $name, $opts_ref->{versions} );
    }
    else {
        @dependent_extensions = _required_by( $name, $opts_ref->{versions} );

# If any of the dependent packages is enabled, ask whether to disable all of them
#if ((grep { $enable_ref->{$_} } @dependent_extensions)) {
        if ( TrEd::MinMax::first { $enable_ref->{$_} } @dependent_extensions )
        {
            my $res = $dialog_box->QuestionQueryAuto({
                -title => 'Disable related packages?',
                -label => "The following packages require '$name':\n\n"
                    . join( "\n",
                    grep { $_ ne $name }
                        sort grep { $enable_ref->{$_} }
                        @dependent_extensions ),
                -buttons => [ 'Ignore dependencies', 'Disable all', 'Cancel' ]
            });
            if ( $res =~ m/^Ignore/ ) {

                # Ignore deps -> disable only package that was unchecked
                @dependent_extensions = ($name);
            }
            elsif ( $res =~ m/^Cancel/ ) {
                $enable_ref->{$name} = !$enable_ref->{$name};
                return;
            }
        }
    }
    if ( ref( $opts_ref->{reload_macros} ) ) {
        ${ $opts_ref->{reload_macros} } = 1;
    }
    foreach my $disabled (@dependent_extensions) {
        $enable_ref->{$disabled} = 0;
    }
    foreach my $enabled (@required_extensions) {
        $enable_ref->{$enabled} = 1;
    }
    if (@dependent_extensions) {
        update_extensions_list( \@dependent_extensions, 0 );
    }
    if (@required_extensions) {
        update_extensions_list( \@required_extensions, 1 );
    }
    return;
}

#######################################################################################
# Usage         : _uninstall_button($name, $embedded_ref, $text, $dialog_box, $opts_ref)
# Purpose       : Uninstall extension callback
# Returns       : Undef/empty list
# Parameters    : scalar $name              -- extension's name
#                 hash_ref $embedded_ref    -- ref to hash of pairs ext_name => [Tk::Frame, Tk::Image]
#                 Tk::ROText $text          -- ROText from which the extension's info is removed
#                 Tk::DialogBox $dialog_box -- dialog box for creating GUI elements
#                 hash_ref $opts_ref        -- ref to hash of options
# Throws        : no exception
# Comments      : If the user allows it, also dependent extensions are removed.
#                 Information about the extensions is removed also from $opts_ref->{versions}
#                 and $embedded_ref
# See Also      :
sub _uninstall_button {
    my ( $name, $embedded_ref, $text, $dialog_box, $opts_ref ) = @_;
    my @dependent_extensions = _required_by( $name, $opts_ref->{versions} );
    my $quiet;
    if ( @dependent_extensions > 1 ) {
        $quiet = 1;
        my $res = $dialog_box->QuestionQueryAuto({
            -title => 'Remove related packages?',
            -label => "The following packages require '$name':\n\n"
                . join( "\n",
                grep { $_ ne $name } sort @dependent_extensions ),
            -buttons => [ 'Ignore dependencies', 'Remove all', 'Cancel' ]
        });
        if ( $res =~ m/^Ignore/ ) {
            @dependent_extensions = ($name);
        }
        elsif ( $res =~ m/^Cancel/ ) {
            return;
        }
    }
    $text->configure( -state => 'normal' );
    foreach my $extension (@dependent_extensions) {
        if (uninstall_extension(
                $extension, { tk => $dialog_box, quiet => $quiet }
            )
            )
        {
            delete $opts_ref->{versions}{$extension};
            $text->DeleteTextTaggedWith($extension);
            delete $embedded_ref->{$extension};
            if ( ref( $opts_ref->{reload_macros} ) ) {
                ${ $opts_ref->{reload_macros} } = 1;
            }
        }
    }
    return;
}

#######################################################################################
# Usage         : _any_enter_text($text, $name, $frame, $image)
# Purpose       : Change background to light blue and focus when entered on text area
# Returns       : Undef/empty list
# Parameters    : Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Frame $frame  -- frame, whose background is changed
#                 Tk::Image $image  -- image, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_frame(), _any_enter_image(), _any_leave_text()
sub _any_enter_text {
    my ( $text, $name, $frame, $image ) = @_;

    # change backgrounds to light blue color
    $frame->configure( -background => 'lightblue' );
    if ($image) {
        $image->configure( -background => 'lightblue' );
    }
    $text->tagConfigure( $name, -background => 'lightblue' );

    # move focus, for details, see Tk/pod/focus
    $frame->focus;
    $frame->focusNext;
    return;
}

#######################################################################################
# Usage         : _any_enter_frame($frame, $text, $name, $image)
# Purpose       : Change background to light blue and focus when entered on frame area
# Returns       : Undef/empty list
# Parameters    : Tk::Frame $frame  -- frame, whose background is changed
#                 Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Image $image  -- image, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_text(), _any_enter_image(), _any_leave_frame()
sub _any_enter_frame {
    my ( $frame, $text, $name, $image ) = @_;

    $frame->configure( -background => 'lightblue' );
    if ($image) {
        $image->configure( -background => 'lightblue' );
    }
    $text->tagConfigure( $name, -background => 'lightblue' );

    $frame->focus;
    $frame->focusNext;
    return;
}

#######################################################################################
# Usage         : _any_enter_image($image, $text, $name, $frame)
# Purpose       : Change background to light blue when entered on image area
# Returns       : Undef/empty list
# Parameters    : Tk::Image $image  -- image, whose background is changed
#                 Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Frame $frame  -- frame, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_frame(), _any_enter_text(), _any_leave_image()
sub _any_enter_image {
    my ( $image, $text, $name, $frame ) = @_;
    $frame->configure( -background => 'lightblue' );
    if ($image) {
        $image->configure( -background => 'lightblue' );
    }
    $text->tagConfigure( $name, -background => 'lightblue' );
    return;
}

#######################################################################################
# Usage         : _any_leave_text($text, $name, $frame, $image)
# Purpose       : Change background to white when leaving the text area
# Returns       : Undef/empty list
# Parameters    : Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Frame $frame  -- frame, whose background is changed
#                 Tk::Image $image  -- image, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_text(), _any_leave_image(), _any_leave_frame()
sub _any_leave_text {
    my ( $text, $name, $frame, $image ) = @_;
    $frame->configure( -background => 'white' );
    if ($image) {
        $image->configure( -background => 'white' );
    }
    $text->tagConfigure( $name, -background => 'white' );
    return;
}

#######################################################################################
# Usage         : _any_leave_text($frame, $text, $name, $image)
# Purpose       : Change background to white when leaving the frame area
# Returns       : Undef/empty list
# Parameters    : Tk::Frame $frame  -- frame, whose background is changed
#                 Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Image $image  -- image, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_frame(), _any_leave_text(), _any_leave_image()
sub _any_leave_frame {
    my ( $frame, $text, $name, $image ) = @_;
    $frame->configure( -background => 'white' );
    if ($image) {
        $image->configure( -background => 'white' );
    }
    $text->tagConfigure( $name, -background => 'white' );
    return;
}

#######################################################################################
# Usage         : _any_leave_image($image, $text, $name, $frame)
# Purpose       : Change background to white when leaving the text area
# Returns       : Undef/empty list
# Parameters    : Tk::Image $image  -- image, whose background is changed
#                 Tk::ROText $text  -- ROText, whose background is changed
#                 scalar $name      -- extension's name
#                 Tk::Frame $frame  -- frame, whose background is changed
# Throws        : no exception
# Comments      : Callback function
# See Also      : _any_enter_image(), _any_leave_frame(), _any_leave_text()
sub _any_leave_image {
    my ( $image, $text, $name, $frame ) = @_;
    $frame->configure( -background => 'white' );
    if ($image) {
        $image->configure( -background => 'white' );
    }
    $text->tagConfigure( $name, -background => 'white' );
    return;
}

#######################################################################################
# Usage         : _create_checkbutton({
#                     tred              => $tred,
#                     name              => $name,
#                     frame             => $frame,
#                     enable_ref        => $enable_ref,
#                     text              => $text,
#                     uninstallable_ref => $uninstallable_ref,
#                     embedded_ref      => \%embedded,
#                     pre_installed_ref => $pre_installed_ref,
#                     opts_ref          => $opts_ref,
#                     dialog_box        => $dialog_box,
#                 });
# Purpose       : Create Enable/Upgrade/Install checkbutton and Uninstall button if appropriate
# Returns       : Undef/empty list
# Parameters    : hash_ref $tred              -- ref to hash that contains TrEd window global data
#                 scalar/URI $name            -- name/URI of the extension
#                 Tk::Frame $frame            -- frame on which the buttons are created
#                 hash_ref $enable_ref        -- ref to hash with extensions that will be changed (enabled/disabled/(un)installed)
#                 Tk::ROText $text            -- ROText with extensions' information
#                 hash_ref $uninstallable_ref -- ref to hash of uninstallable extensions
#                 hash_ref $embedded_ref      -- ref to hash of pairs ext_name => [Tk::Frame, Tk::Image]
#                 hash_ref $pre_installed_ref -- ref to hash of preinstalled extensions (keys are names of extensions, no values)
#                 hash_ref $opts_ref          -- ref to hash of options
#                 Tk::DialogBox $dialog_box   -- dialog box for creating GUI elements
# Throws        : no exception
# Comments      : If $name is a blessed URI reference, Upgrade/Install checkbuttons are created.
#                 Otherwise Enable and Uninstall buttons are created.
# See Also      :
sub _create_checkbutton {
    my ($args_ref) = @_;

    my $tred              = $args_ref->{tred};
    my $name              = $args_ref->{name};
    my $frame             = $args_ref->{frame};
    my $enable_ref        = $args_ref->{enable_ref};
    my $text              = $args_ref->{text};
    my $uninstallable_ref = $args_ref->{uninstallable_ref};
    my $embedded_ref      = $args_ref->{embedded_ref};
    my $pre_installed_ref = $args_ref->{pre_installed_ref};
    my $opts_ref          = $args_ref->{opts_ref};
    my $dialog_box        = $args_ref->{dialog_box};

    if ( ( blessed($name) and $name->isa('URI') ) ) {
        if ( $uninstallable_ref->{$name} ) {
            $frame->Label(
                -text    => $uninstallable_ref->{$name},
                -anchor  => 'nw',
                -justify => 'left'
            )->pack( -fill => 'x' );
        }
        else {
            $frame->Checkbutton(
                -text => exists( $opts_ref->{installed}{ short_name($name) } )
                ? 'Upgrade'
                : 'Install',
                -compound    => 'left',
                -selectcolor => undef,
                -indicatoron => 0,
                -background  => 'white',
                -relief      => 'flat',
                -borderwidth => 0,
                -height      => 18,
                -selectimage => main::icon( $tred, "checkbox_checked" ),
                -image       => main::icon( $tred, "checkbox" ),
                -command =>
                    [ \&_upgrade_install_checkbutton, $enable_ref, $name ],
                -variable => \$enable_ref->{$name}
            )->pack( -fill => 'x' );
        }
    }
    else {
        if ( exists $pre_installed_ref->{$name} ) {
            $frame->Label( -text =>, "PRE-INSTALLED" )
                ->pack( -fill => 'both', -side => 'right', -padx => 5 );
        }
        else {
            $frame->Checkbutton(
                -text        => 'Enable',
                -compound    => 'left',
                -selectcolor => undef,
                -indicatoron => 0,
                -background  => 'white',
                -relief      => 'flat',
                -borderwidth => 0,
                -height      => 18,
                -selectimage => main::icon( $tred, "checkbox_checked" ),
                -image       => main::icon( $tred, "checkbox" ),
                -command     => [
                    \&_enable_checkbutton, $name,
                    $opts_ref,             $enable_ref,
                    $dialog_box
                ],
                -variable => \$enable_ref->{$name}
            )->pack( -fill => 'both', -side => 'left', -padx => 5 );
            $frame->Button(
                -text     => 'Uninstall',
                -compound => 'left',
                -height   => 18,
                -image    => main::icon( $tred, 'remove' ),
                -command  => [
                    \&_uninstall_button, $name,       $embedded_ref,
                    $text,               $dialog_box, $opts_ref
                ],
                )->pack(
                -fill => 'both',
                -side => 'right',
                -padx => 5
                );
        }
    }
    return;
}

#######################################################################################
# Usage         : _add_pane_items({
#                   ext_list_ref        => $ext_list_ref,
#                   extension_data      => \%extension_data,
#                   text                => $text,
#                   tred                => $tred,
#                   pre_installed_ref   => \%pre_installed,
#                   opts_ref            => $opts_ref,
#                   enable_ref          => \%enable,
#                   uninstallable_ref   => $uninstallable_ref,
#                   dialog_box          => $dialog_box,
#                 });
# Purpose       : For each extension from @$ext_list_ref add item on window panner
# Returns       : Undef/empty list
# Parameters    : array_ref $ext_list_ref      -- ref to list of extenions' URIs
#                 hash_ref $extension_data_ref -- ref to hash of pairs ext URI => ext meta data
#                 Tk::ROText $text             -- ROText with extensions' information
#                 hash_ref $tred               -- ref to hash that contains TrEd window global data
#                 hash_ref $pre_installed_ref  -- ref to hash of preinstalled extensions (keys are names of extensions, no values)
#                 hash_ref $opts_ref           -- ref to hash of options
#                 hash_ref $enable_ref         -- ref to hash with extensions that will be changed (enabled/disabled/(un)installed)
#                 hash_ref $uninstallable_ref  -- ref to hash of uninstallable extensions
#                 Tk::DialogBox $dialog_box    -- dialog box for creating GUI elements
# Throws        : no exception
# Comments      : Also sets up callbacks for mouse over events and scrolling wheel
# See Also      :
sub _add_pane_items {
    my ($args_ref) = @_;

    my $ext_list_ref       = $args_ref->{ext_list_ref};
    my $extension_data_ref = $args_ref->{extension_data};
    my $text               = $args_ref->{text};
    my $tred               = $args_ref->{tred};
    my $pre_installed_ref  = $args_ref->{pre_installed_ref};
    my $opts_ref           = $args_ref->{opts_ref};
    my $enable_ref         = $args_ref->{enable_ref};
    my $uninstallable_ref  = $args_ref->{uninstallable_ref};
    my $dialog_box         = $args_ref->{dialog_box};

    my $row = 0;
    my %embedded;

    foreach my $ext_name ( @{$ext_list_ref} ) {
        my $data_ref = $extension_data_ref->{$ext_name};
        my $start    = $text->index('end');
        my $frame    = $text->Frame( -background => 'white' );

        my $generic_icon ||= main::icon( $tred, 'extension' );
        my $image = _set_extension_icon(
            {   data_ref          => $data_ref,
                name              => $ext_name,
                pre_installed_ref => $pre_installed_ref,
                text              => $text,
                generic_icon      => $generic_icon,
            }
        );

        $text->insert( 'end', "\n" );
        if ($image) {
            $text->windowCreate( 'end', -window => $image, -padx => 5 );
        }

        _set_name_desc_copyright(
            {   data_ref          => $data_ref,
                name              => $ext_name,
                pre_installed_ref => $pre_installed_ref,
                text              => $text,
                opts_ref          => $opts_ref,
            }
        );

        my $end = $text->index('end');
        $end =~ s/\..*//;
        $text->configure( -height => $end );

        $embedded{$ext_name} = [ $frame, $image ? $image : () ];

        if ( $opts_ref->{only_upgrades} ) {
            $enable_ref->{$ext_name} = 1;
        }

        # Create Enable / Upgrade / Install checkbutton
        _create_checkbutton(
            {   tred              => $tred,
                name              => $ext_name,
                frame             => $frame,
                enable_ref        => $enable_ref,
                text              => $text,
                uninstallable_ref => $uninstallable_ref,
                embedded_ref      => \%embedded,
                pre_installed_ref => $pre_installed_ref,
                opts_ref          => $opts_ref,
                dialog_box        => $dialog_box,
            }
        );

        $text->insert( 'end', q{ }, [$frame] );

        # Add information about extension's size
        _set_ext_size( $data_ref, $text, $ext_name );

        $text->windowCreate( 'end', -window => $frame, -padx => 5 );
        $text->tagConfigure( $frame, -justify => 'right' );

        #    $text->tagConfigure('preinst',-justify=>'right');
        $text->Insert("\n");
        $text->Insert("\n");
        $text->tagAdd( $ext_name, $start . ' - 1 line', 'end -1 char' );

        # Any-Enter
        $text->tagBind( $ext_name,
            '<Any-Enter>' => [ \&_any_enter_text, $ext_name, $frame, $image ]
        );
        $frame->bind(
            '<Any-Enter>' => [ \&_any_enter_frame, $text, $ext_name, $image ]
        );
        if ($image) {
            $image->bind( '<Any-Enter>' =>
                    [ \&_any_enter_image, $text, $ext_name, $frame ] );
        }

        # Any-Leave
        $text->tagBind( $ext_name,
            '<Any-Leave>' => [ \&_any_leave_text, $ext_name, $frame, $image ]
        );
        $frame->bind(
            '<Any-Leave>' => [ \&_any_leave_frame, $text, $ext_name, $image ]
        );
        if ($image) {
            $image->bind( '<Any-Leave>' =>
                    [ \&_any_leave_image, $text, $ext_name, $frame ] );
        }

        # Mouse wheel
        for my $w ( $frame, $frame->children ) {
            $w->bind( '<4>', [ $text, 'yview', 'scroll', -1, 'units' ] );
            $w->bind( '<5>', [ $text, 'yview', 'scroll', 1,  'units' ] );
            $w->Tk::bind(
                '<MouseWheel>',
                [   sub {
                        $text->yview( 'scroll', -( $_[1] / 120 ) * 3,
                            'units' );
                    },
                    Tk::Ev("D")
                ]
            );
        }
        $row++;
    }
    return;
}

#######################################################################################
# Usage         : _populate_extension_pane($tred, $dialog_box, $opts_ref)
# Purpose       : Create and populate extension window panner
# Returns       : Reference to hash which contains information about extensions' changes
# Parameters    : hash_ref $tred            -- ref to hash that contains TrEd window global data
#                 Tk::DialogBox $dialog_box -- dialog box for creating GUI elements
#                 hash_ref $opts_ref        -- ref to hash of options
# Throws        : no exception
# Comments      : Creates list of extension, finds information about dependencies between them,
#                 dependencies on other perl modules, perl version and TrEd version. Populates
#                 window panner with extensions and creates buttons to Install/Uninstall,
#                 Enable/Disable them.
#                 Returned hash's keys are URIs of extensions. Values are 0, 1, or undef, where
#                 1 means to enable/install extension, 0 to disable/uninstall extension.
# See Also      : _add_pane_items(), _create_ext_list()
sub _populate_extension_pane {
    my ( $tred, $dialog_box, $opts_ref ) = @_;

    my %enable = ();
    my %extension_data = ();
    my %pre_installed = ();

    %requires = ();
    %required_by = ();

    # construct extensions list with required/(pre-)installed extensions
    # If the user chooses to install or upgrade extensions,
    # $ext_list_ref would be a list of URIs of extensions.
    #
    # Otherwise, $ext_list_ref would be a list of names of extensions.
    # Following functions should be ready for such schizophrenic behaviour.
    # The same applies to %requires, %required_by, %extension_data hashes,
    # the keys could be either names or URIs
    my $ext_list_ref = _create_ext_list(
        {   pre_installed_ref  => \%pre_installed,
            extension_data_ref => \%extension_data,
            enable_ref         => \%enable,
            opts_ref           => $opts_ref,
            dialog_box         => $dialog_box,
        }
    );

    # find required TrEd version, Perl version and module requirements
    #of all the extensions from URI list
    my $uninstallable_ref
        = _find_uninstallable_exts( $ext_list_ref, \%extension_data );

    # test required extensions for unsatisfied(-able)
    # dependencies, modify uninstallable_ref accordingly
    _dependencies_of_req_exts( $ext_list_ref, $uninstallable_ref );

    my $text = $opts_ref->{pane} || $dialog_box->add(
        'Scrolled'  => 'ROText',
        -scrollbars => 'oe',
        -takefocus  => 0,
        -relief     => 'flat',
        -wrap       => 'word',
        -width      => 70,
        -height     => 20,
        -background => 'white',
    );
    $text->configure( -state => 'normal' );
    $text->delete(qw(0.0 end));

    _add_pane_items(
        {   ext_list_ref      => $ext_list_ref,
            extension_data    => \%extension_data,
            text              => $text,
            tred              => $tred,
            pre_installed_ref => \%pre_installed,
            opts_ref          => $opts_ref,
            enable_ref        => \%enable,
            uninstallable_ref => $uninstallable_ref,
            dialog_box        => $dialog_box,
        }
    );

    $text->tagConfigure(
        'label',
        -foreground => 'darkblue',
        -font       => 'C_bold'
    );
    $text->tagConfigure(
        'desc',
        -foreground => 'black',
        -font       => 'C_default'
    );
    $text->tagConfigure(
        'name',
        -foreground => '#333',
        -font       => 'C_default'
    );
    $text->tagConfigure( 'title', -foreground => 'black', -font => 'C_bold' );
    $text->tagConfigure(
        'copyright',
        -foreground => '#666',
        -font       => 'C_small'
    );

    $text->configure( -height => 20 );
    $text->pack( -expand => 1, -fill => 'both' );

    #$text->Subwidget('scrolled')->configure(-state=>'disabled');
    if ( !$opts_ref->{pane} ) {
        $text->TextSearchLine(
            -parent   => $dialog_box,
            -label    => 'S~earch',
            -prev_img => main::icon( $tred, '16x16/up' ),
            -next_img => main::icon( $tred, '16x16/down' ),
        )->pack(qw(-fill x));
        $opts_ref->{pane} = $text;
    }
    $text->see('0.0');
    return \%enable;
}

#######################################################################################
# Usage         : _install_ext_button($enable_ref, $manage_ext_dialog, $opts_ref, $INSTALL);
# Purpose       : Create progressbar and installs extensions marked for installation in
#                 %$enable_ref hash
# Returns       : Undef/empty list
# Parameters    : hash_ref $enable_ref             -- ref to hash of extensions to install
#                 Tk::DialogBox $manage_ext_dialog -- dialog box for creating GUI elements
#                 hash_ref $opts_ref               -- ref to hash of options
#                 scalar $INSTALL                  -- sign on Install button
# Throws        : no exception
# Comments      : Callback function for 'Install selected' button
# See Also      : _update_install_new_button()
sub _install_ext_button {
    my ( $enable_ref, $manage_ext_dialog, $opts_ref, $INSTALL ) = @_;

    my @selected = grep { $enable_ref->{$_} } keys %{$enable_ref};
    my $progress;
    my $ret;
    if (@selected) {
        $manage_ext_dialog->add(
            'ProgressBar',
            -from     => 0,
            -to       => scalar(@selected),
            -colors   => [ 0, 'darkblue' ],
            -blocks   => scalar(@selected),
            -width    => 15,
            -variable => \$progress
        )->pack( -expand => 1, -fill => 'x', -pady => 5 );

        $manage_ext_dialog->Busy( -recurse => 1 );
        $ret = eval {
            install_extensions(
                \@selected,
                {   tk       => $manage_ext_dialog,
                    progress => \$progress,
                    quiet    => $opts_ref->{only_upgrades},
                }
            );
        };
    }
    if ( $@ || !defined $ret ) {
        $manage_ext_dialog->ErrorReport(
            -title => "Installation error",
            -message =>
                "The following error occurred during package installation:",
            -body    => "$@",
            -buttons => [qw(OK)],
        );
    }
    $manage_ext_dialog->Unbusy();
    $manage_ext_dialog->{selected_button} = $INSTALL;
    return;
}

#######################################################################################
# Usage         : _update_install_new_button({
#                   manage_ext_dialog => $manage_ext_dialog,
#                   tred              => $tred,
#                   enable_ref        => $enable_ref,
#                   INSTALL           => $INSTALL,
#                   opts_ref          => $opts_ref,
#                   upgrades          => $upgrades
#                 });
# Purpose       : Create dialog box with listed extensions which allows user to install new
#                 or update existing extensions
# Returns       : Undef/empty list
# Parameters    : Tk::DialogBox $manage_ext_dialog -- dialog box for creating GUI elements
#                 hash_ref $tred        -- ref to hash that contains TrEd window global data
#                 hash_ref $enable_ref  -- ref to hash of extensions to update/install
#                 scalar $INSTALL       -- sign on Install button
#                 hash_ref $opts_ref    -- ref to hash of options
#                 scalar $upgrades      -- 0 when installing, 1 when updating extensions
# Throws        : no exception
# Comments      : Callback function for 'Get new extensions' and 'Check for updates' buttons
# See Also      : manage_repositories()
sub _update_install_new_button {
    my ( $args_ref, $upgrades ) = @_;

    #  my $upgrades          = $args_ref->{only_upgrades};
    my $manage_ext_dialog = $args_ref->{manage_ext_dialog};
    my $tred              = $args_ref->{tred};
    my $enable_ref        = $args_ref->{enable_ref};
    my $INSTALL           = $args_ref->{INSTALL};
    my $opts_ref          = $args_ref->{opts_ref};

    my $progress;
    my $progressbar = $manage_ext_dialog->add(
        'ProgressBar',
        -from     => 0,
        -to       => 1,
        -colors   => [ 0, 'darkblue' ],
        -width    => 15,
        -variable => \$progress
    )->pack( -expand => 1, -fill => 'x', -pady => 5 );
    my $opts_to_pass = {
        install       => 1,
        top           => $manage_ext_dialog,
        only_upgrades => $upgrades,
        progress      => \$progress,
        progressbar   => $progressbar,
        installed     => $opts_ref->{versions},
        repositories  => $opts_ref->{repositories}
    };

    if ( manage_extensions_dialog( $tred, $opts_to_pass ) eq $INSTALL ) {
        $enable_ref = _populate_extension_pane( $tred, $manage_ext_dialog,
            $opts_ref );
        if ( ref( $opts_ref->{reload_macros} ) ) {
            ${ $opts_ref->{reload_macros} } = 1;
        }
    }
    $progressbar->packForget();
    $progressbar->destroy();
    return;
}

#######################################################################################
# Usage         : manage_extensions_dialog($tred, $opts_ref)
# Purpose       : Create dialog box with listed extensions which allows user to install,
#                 update, remove, enable and disable extensions
# Returns       : Result of Tk::DialogBox::Show() function, i.e. name of the Button invoked,
#                 undef/empty list if no change was requested by the user
# Parameters    : hash_ref $tred      -- ref to hash that contains TrEd window global data
#                 hash_ref $opts_ref  -- ref to hash of options
# Throws        : no exception
# Comments      : opts_ref should contain 'install' key in case Install button should appear
#                 on the widget. opts_ref->{repositories} should be a ref to a list of repositories
#                 with extensions.
# See Also      : manage_repositories(), install_extensions(), Tk::DialogBox::Show()
sub manage_extensions_dialog {
    my ( $tred, $opts_ref ) = @_;
    $opts_ref ||= {};

    my $mw           = $opts_ref->{top} || $tred->{top} || return;
    my $UPGRADE      = 'Check Updates';
    my $DOWNLOAD_NEW = 'Get New Extensions';
    my $REPOSITORIES = 'Edit Repositories';
    my $INSTALL      = 'Install Selected';

    # if $opts_ref->{install} is true, set title to
    # 'Install New Extensions', otherwise use 'Manage Extensions'
    # if $opts_ref->{install} is true, only install button is created,
    # otherwise, also upgrade, download new and repositories buttons
    # are created (Close button is always created)
    my $dialog_title
        = $opts_ref->{only_upgrades} ? 'Update Extensions'
        : $opts_ref->{install}       ? 'Install New Extensions'
        :                              'Manage Extensions';

    my $manage_ext_dialog = $mw->DialogBox(
        -title   => $dialog_title,
        -buttons => [
            (     $opts_ref->{install}
                ? $INSTALL
                : ( $UPGRADE, $DOWNLOAD_NEW, $REPOSITORIES )
            ),
            'Close'
        ]
    );
    my $scale = 0.9;
    $manage_ext_dialog->maxsize(
        $scale * $manage_ext_dialog->screenwidth(),
        $scale * $manage_ext_dialog->screenheight()
    );
    my $enable_ref
        = _populate_extension_pane( $tred, $manage_ext_dialog, $opts_ref );
    if ( not ref $enable_ref ) {
        $manage_ext_dialog->destroy;
        return;
    }
    if ( $opts_ref->{install} ) {

        # Install button
        $manage_ext_dialog->Subwidget( 'B_' . $INSTALL )->configure(
            -command => [
                \&_install_ext_button, $enable_ref, $manage_ext_dialog,
                $opts_ref,             $INSTALL
            ]
        );
    }
    elsif ( $opts_ref->{repositories} and @{ $opts_ref->{repositories} } ) {

        # common settings
        my $args_ref = {
            manage_ext_dialog => $manage_ext_dialog,
            tred              => $tred,
            enable_ref        => $enable_ref,
            INSTALL           => $INSTALL,
            opts_ref          => $opts_ref,
        };

        # Download button
        $manage_ext_dialog->Subwidget( 'B_' . $DOWNLOAD_NEW )
            ->configure(
            -command => [ \&_update_install_new_button, $args_ref, 0 ] );

        # Upgrade button
        $manage_ext_dialog->Subwidget( 'B_' . $UPGRADE )
            ->configure(
            -command => [ \&_update_install_new_button, $args_ref, 1 ] );

        # Repositories button
        $manage_ext_dialog->Subwidget( 'B_' . $REPOSITORIES )->configure(
            -command => sub {
                manage_repositories( $manage_ext_dialog,
                    $opts_ref->{repositories} );
            }
        );

    }

    #  should be already loaded
    #  require Tk::DialogReturn;
    $manage_ext_dialog->BindEscape( undef, 'Close' );
    $manage_ext_dialog->BindButtons();
    return $manage_ext_dialog->Show();
}

#######################################################################################
# Usage         : _repo_ok_or_forced($url, $manage_repos_dialog, $listbox)
# Purpose       : Check whether the repository on $url is valid and if not, ask user
#                 what to do
# Returns       : True if repository is found and is not a duplicate of already existing one,
#                 or if the user chooses to add non-duplicit repository. False otherwise.
# Parameters    : scalar $url                         -- url of the repository
#                 Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
#                 Tk::Listbox $listbox                -- listbox with listed repositories
# Throws        : no exception
# Comments      :
# See Also      : _add_repo()
sub _repo_ok_or_forced {
    my ( $url, $manage_repos_dialog, $listbox ) = @_;
    my $ext_list = eval { get_extension_list($url) };

    return (
        (   ref $ext_list && !$@
                || (
                $manage_repos_dialog->QuestionQueryAuto({
                    -title   => 'Repository error',
                    -label   => 'No repository was found on a given URL!',
                    -buttons => [ 'Cancel', 'Add Anyway' ]
                }) =~ /Anyway/
                )
        )
            && !TrEd::MinMax::first { $_ eq $url } $listbox->get( 0, 'end' )
    );
}

#######################################################################################
# Usage         : _add_repo($manage_repos_dialog, $manage_repos_listbox)
# Purpose       : Prompt user to input repository URL, validate and add the extension repository
# Returns       : Undef/empty list
# Parameters    : Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
#                 Tk::Listbox $listbox                -- listbox with listed repositories
# Throws        : no exception
# Comments      : Callback for 'Add repository' button
# See Also      : _remove_repo()
sub _add_repo {
    my ( $manage_repos_dialog, $manage_repos_listbox ) = @_;
    my $url = $manage_repos_dialog->StringQuery(
        -label   => 'Repository URL:',
        -title   => 'Add Repository',
        -default => ( $manage_repos_listbox->get('anchor') || q{} ),
        -select  => 1,
    );
    if ($url) {
        if (_repo_ok_or_forced(
                $url, $manage_repos_dialog, $manage_repos_listbox
            )
            )
        {
            $manage_repos_listbox->insert( 'anchor', $url );
        }
    }
    return;
}

#######################################################################################
# Usage         : _remove_repo($manage_repos_dialog, $manage_repos_listbox)
# Purpose       : Remove selected extension repositories
# Returns       : Undef/empty list
# Parameters    : Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
#                 Tk::Listbox $listbox                -- listbox with listed repositories
# Throws        : no exception
# Comments      : Callback for 'Remove' repository button
# See Also      : _add_repo()
sub _remove_repo {
    my ( $manage_repos_dialog, $manage_repos_listbox ) = @_;
    foreach
        my $element ( grep { $manage_repos_listbox->selectionIncludes($_) }
        0 .. $manage_repos_listbox->index('end') )
    {
        $manage_repos_listbox->delete($element);
    }
    return;
}

#######################################################################################
# Usage         : manage_repositories($top, $repos)
# Purpose       : Add, remove and save extension repositories for TrEd
# Returns       : Return value of Tk::DialogBox::Show(), i.e. name of the Button invoked,
#                 in this case one of 'Add', 'Remove', 'Save' and 'Cancel'
# Parameters    : Tk::DialogBox $top  -- dialog box for creating GUI elements
#                 hash_ref $repos_ref -- ref to hash of repositories
# Throws        : no exception
# Comments      : Callback for 'Edit repositories' button
# See Also      :
sub manage_repositories {
    my ( $top, $repos ) = @_;
    my $manage_repos_dialog = $top->DialogBox(
        -title   => "Manage Extension Repositories",
        -buttons => [qw(Add Remove Save Cancel)]
    );

    my $manage_repos_listbox = $manage_repos_dialog->add(
        'Listbox',
        -width      => 60,
        -background => 'white',
    )->pack( -fill => 'both', -expand => 1 );

    $manage_repos_listbox->insert( 0, @{$repos} );
    $manage_repos_dialog->Subwidget('B_Add')
        ->configure( -command =>
            [ \&_add_repo, $manage_repos_dialog, $manage_repos_listbox ] );
    $manage_repos_dialog->Subwidget('B_Remove')
        ->configure( -command =>
            [ \&_remove_repo, $manage_repos_dialog, $manage_repos_listbox ] );
    $manage_repos_dialog->Subwidget('B_Save')->configure(
        -command => sub {
            @{$repos} = $manage_repos_listbox->get( 0, 'end' );
            $manage_repos_dialog->{selected_button} = 'Save';
        }
    );
    return $manage_repos_dialog->Show();
}

#######################################################################################
# Usage         : update_extensions_list($name, $enable[, $extension_dir])
# Purpose       : Update local extensions list file
# Returns       : Undef/empty list
# Parameters    : scalar/array_ref $name -- name of extension(s) to enable/disable
#                 scalar $enable -- 1 if extension(s) should be enabled, 0 otherwise
#                 scalar $extension_dir -- local directory where the extensions are stored
# Throws        : Croaks if extensions list file could not be found/opened/written into.
# Comments      :
# See Also      :
sub update_extensions_list {
    my ( $name, $enable, $extension_dir ) = @_;

    my %names;
    @names{ ( ref $name eq 'ARRAY' ? @{$name} : $name ) } = ();

    $extension_dir ||= get_extensions_dir();
    my $extension_list_file
        = File::Spec->catfile( $extension_dir, 'extensions.lst' );
    if ( -f $extension_list_file ) {
        open my $fh, '<', $extension_list_file
            or croak(
            "Configuring extension failed: cannot read extension list $extension_list_file: $!"
            );
        my @list = <$fh>;
        close $fh
            or croak(
            "Configuring extension failed: cannot close extension list $extension_list_file: $!"
            );

        open $fh, '>', $extension_list_file
            or croak(
            "Configuring extenson failed: cannot write extension list $extension_list_file: $!"
            );
        foreach my $extension_name (@list) {
            # ext name is valid name and
            # it is one of the names specified by sub argument
            if ( $extension_name =~ m/^!?(\S+)\s*$/ && exists $names{$1} )
            {
                print $fh ( ( $enable ? q{} : q{!} ) . $1 . "\n" );
            }
            else {
                print $fh ($extension_name);
            }
        }
        close($fh)
            or croak(
            "Configuring extenson failed: cannot close extension list $extension_list_file: $!"
            );
    }
    return;
}

#######################################################################################
# Usage         : _load_extension_file($extension_list_file)
# Purpose       : Load extension file list if it exists. Otherwise use standard begin commentary.
# Returns       : List of extensions read from $extension_list_file
# Parameters    : scalar $extension_list_file -- path to extension list file
# Throws        : Croaks if extensions list file could not be opened.
# Comments      : If $extension_list_file exists, it is read and its lines are returned
#                 as a list. Otherwise, just a list of lines of beginning commentary is returned.
# See Also      :
sub _load_extension_file {
    my ($extension_list_file) = @_;
    my @extension_file;
    if ( -f $extension_list_file ) {
        open my $fh, '<', $extension_list_file
            or croak(
            "Installation failed: cannot read extension list $extension_list_file: $!"
            );
        @extension_file = <$fh>;
        chomp @extension_file;
        close $fh
            or croak(
            "Installation failed: cannot close extension list $extension_list_file: $!"
            );
    }
    else {
        @extension_file = @extension_file_prologue;
    }
    return @extension_file;
}

#######################################################################################
# Usage         : _force_reinstall($opts_ref, $name, $dir)
# Purpose       : Ask user whether to force extension's reinstallation/update
# Returns       : If $opts_ref->{quiet} is 0, return value of QuestionQueryAuto is returned.
#                 Undef/empty list is returned otherwise.
# Parameters    : hash_ref $opts_ref -- ref to hash of options
#                 scalar $name       -- name of the extension
#                 scalar $dir        -- extensions' directory
# Throws        : no exception
# Comments      :
# See Also      :
sub _force_reinstall {
    my ( $opts_ref, $name, $dir ) = @_;

    if ( $opts_ref->{quiet} == 0 ) {
        return $opts_ref->{tk}->QuestionQueryAuto({
            -title => 'Reinstall?',
            -label =>
                "Extension $name is already installed in $dir.\nDo you want to upgrade/reinstall it?",
            -buttons => [ 'Install/Upgrade', 'All', 'Cancel' ]
        });
    }
    else {
        return;
    }
}

#######################################################################################
# Usage         : _report_install_error($opts_ref, $error_message, $eval_error)
# Purpose       : Display $error_message if using GUI, carp otherwise
# Returns       : Undef/empty list
# Parameters    : hash_ref $opts_ref    -- ref to hash of options
#                 scalar $error_message -- error message to display
#                 scalar $eval_error    -- error from last eval
# Throws        : Carp error message
# Comments      : $opts_ref->{tk} has to be set to Tk::DialogBox to display error message in GUI
# See Also      :
sub _report_install_error {
    my ( $opts_ref, $error_message, $eval_error ) = @_;
    if ( $opts_ref->{tk} && $eval_error ) {
        $opts_ref->{tk}->ErrorReport(
            -title => "Installation error",
            -message =>
                "The following error occurred during package installation:",
            -body    => $error_message,
            -buttons => [qw(OK)],
        );
    }
    else {
        carp($error_message);
    }
    return;
}

#######################################################################################
# Usage         : _install_extension_from_zip($dir, $url, $opts_ref)
# Purpose       : Install extension from $url to directory $dir
# Returns       : Zero if some error occured, 1 if successful
# Parameters    : hash_ref $opts_ref  -- ref to hash of options
#                 scalar $dir         -- extensions' directory
#                 scalar $url         -- URL of the extension
# Throws        : no exception
# Comments      : Tries to download extension as a zip file from $url, extracts archive
#                 using Archive::Zip and fixes permissions of files if needed.
# See Also      : install_extensions(), Treex::PML::IO::fetch_file()
sub _install_extension_from_zip {
    my ( $dir, $url, $opts_ref ) = @_;

    # Fetch extension from repository
    mkdir $dir;
    print "Downloading extension from ${url}.zip\n";
    my ( $zip_file, $unlink )
        = eval { Treex::PML::IO::fetch_file( $url . '.zip' ) };
    if ($@) {
        my $err = "Downloading ${url}.zip failed:\n" . $@;
        _report_install_error( $opts_ref, $err, $@ );
        return 0;
    }

    print "Extracting ${url}.zip to $dir\n";
    # Read the downloaded zip file which contains extension
    my $zip = Archive::Zip->new();
    if ( $zip->read($zip_file) != Archive::Zip::AZ_OK() ) {
        my $err = "Reading ${url}.zip failed!\n";
        _report_install_error( $opts_ref, $err, $@ );
        return 0;
    }
    my $d = pushd($dir);
    # Extract zip archive, i.e. the extension
    if ( $zip->extractTree( ) == Archive::Zip::AZ_OK() ) {

        # try to restore executable bit
        if ( $^O ne 'MSWin32' ) {
            for my $member ( $zip->members ) {
                my $exe_perms = ( $member->unixFileAttributes & 0111 );
                if ($exe_perms) {
                    my $fn = File::Spec->catfile( $dir,
                        URI::file->new( $member->fileName )->file() );
                    my $perms = ( ( stat $fn )[2] & 0777 );
                    if ($perms) {
                        chmod( ( $perms | $exe_perms ), $fn );
                    }
                }
            }
        }
    }
    else {
        my $err = "Extracting files from ${url}.zip failed!\n";
        _report_install_error( $opts_ref, $err, $@ );
        return 0;
    }
    if ($unlink) {
        unlink($zip_file);
    }
    return 1;
}

#######################################################################################
# Usage         : install_extensions($urls_ref, $opts_ref)
# Purpose       : Install extensions from list @$urls_ref
# Returns       : 1 on success, undef/empty list if $urls_ref is a reference to empty array
# Parameters    : array_ref $urls_ref -- ref to list of extensions to install (theirs URLs)
#                 hash_ref $opts_ref  -- ref to hash of options
# Throws        : Croaks if $urls_ref is not reference to array, if extension list file
#                 could not be opened or if extension directory could not be created
# Comments      : Creates extension directory if it does not exist, loads extension list file,
#                 uninstalls old versions of extensions if updating (or if the installation is
#                 forced). Then the function downloads extensions & installs them and updates
#                 extension file list.
# See Also      : uninstall_extension()
sub install_extensions {
    my ( $urls_ref, $opts_ref ) = @_;
    if ( ref $urls_ref ne 'ARRAY' ) {
        croak(q{Usage: install_extensions(\@urls, \%opts)});
    }
    return if ! @{$urls_ref};
    $opts_ref ||= {};

    # Create extension directory if it does not exist..
    my $extension_dir = $opts_ref->{extensions_dir} || get_extensions_dir();
    if ( not -d $extension_dir ) {
        mkdir $extension_dir
            or croak(
            "Installation failed: cannot create extension directory $extension_dir: $!"
            );
    }

    # Load extension file
    my $extension_list_file
        = File::Spec->catfile( $extension_dir, 'extensions.lst' );
    my @extension_file = _load_extension_file($extension_list_file);

    # extract the zip archive with extension
    require Archive::Zip;
    for my $url ( @{$urls_ref} ) {
        my $name = $url;
        $name =~ s{.*/}{}g;
        Encode::_utf8_off($name);
        my $dir = File::Spec->catdir( $extension_dir, $name );
        if ( -d $dir ) {
            my $user_choice = _force_reinstall( $opts_ref, $name, $dir );
            next if ( !$opts_ref->{quiet} && $user_choice eq 'Cancel' );
            if ( !$opts_ref->{quiet} && ( $user_choice eq 'All' ) ) {
                $opts_ref->{quiet} = 1;
            }
            uninstall_extension($name);    # or just rmtree
        }

        if ( not _install_extension_from_zip( $dir, $url, $opts_ref ) ) {
            next;
        }

        @extension_file
            = ( ( grep { !/^\!?\Q$name\E\s*$/ } @extension_file ), $name );

        if ( ref $opts_ref->{progress} ) {
            ${ $opts_ref->{progress} }++;
            if ( $opts_ref->{tk} ) {
                $opts_ref->{tk}->update();
            }
        }
    }

    # Update extension list file
    open my $fh, '>', $extension_list_file
        or croak(
        "Installation failed: cannot write to extension list $extension_list_file: $!"
        );
    foreach my $extension_name (@extension_file) {
        print $fh ( $extension_name . "\n" );
    }
    close $fh
        or croak(
        "Installation failed: cannot close to extension list $extension_list_file: $!"
        );

    return 1;
}

#######################################################################################
# Usage         : uninstall_extension($name, $opts_ref)
# Purpose       : Uninstall extension from extension directory and update extension list
# Returns       : 1 if successful, undef/empty list if cancelled
# Parameters    : scalar $name        -- name of the extension
#                 sahs_ref $opts_ref  -- ref to hash of options
# Throws        : Croaks if extension list could not be opened for reading or writing
# Comments      :
# See Also      : install_extensions()
sub uninstall_extension {
    my ( $name, $opts_ref ) = @_;

    return if ( !defined $name || !length $name );
    $opts_ref ||= {};
    my $extension_dir = $opts_ref->{extensions_dir} || get_extensions_dir();
    my $dir = File::Spec->catdir( $extension_dir, $name );
    if ( -d $dir ) {
        return
            if (
               $opts_ref->{tk}
            && !$opts_ref->{quiet}
            && $opts_ref->{tk}->QuestionQueryAuto({
                -title   => 'Uninstall?',
                -label   => "Really uninstall extension $name ($dir)?",
                -buttons => [ 'Uninstall', 'Cancel' ]
            }) ne 'Uninstall'
            );
        require File::Path;
        File::Path::rmtree($dir);
    }

    # remove extension from extensions list file
    my $extension_list_file
        = File::Spec->catfile( $extension_dir, 'extensions.lst' );
    if ( -f $extension_list_file ) {

        # first load all the extensions to @ext_list
        open my $fh, '<', $extension_list_file
            or croak(
            "Uninstall failed: cannot read extension list $extension_list_file: $!"
            );
        my @ext_list = <$fh>;
        close $fh
            or croak(
            "Uninstall failed: cannot close extension list $extension_list_file: $!"
            );

        # then write all the extension back, except $name extension
        open $fh, '>', $extension_list_file
            or croak(
            "Uninstall failed: cannot write extension list $extension_list_file: $!"
            );
        foreach my $extension (@ext_list) {
            next if ( $extension =~ m/^!?\Q$name\E\s*$/x );
            print $fh ($extension);
        }
        close $fh
            or croak(
            "Uninstall failed: cannot close extension list $extension_list_file: $!"
            );
    }
    return 1;
}



#######################################################################################
# Usage         : get_extensions_dir()
# Purpose       : Return extensions directory from config
# Returns       : Name of the extensions directory (as a string)
# Parameters    : no
# Throws        : no exception
# Comments      : Reads TrEd::Config::extensionsDir
sub get_extensions_dir {
    return $TrEd::Config::extensionsDir;
}
# wrapper for PADT
sub getExtensionsDir {
    # maybe print that should be renamed
    return get_extensions_dir();
}

#######################################################################################
# Usage         : get_preinstalled_extensions_dir()
# Purpose       : Return configuration option -- directory where extensions are preinstalled
# Returns       : Name of the directory where extensions are preinstalled (string)
# Parameters    : no
# Throws        : no exception
# Comments      : Reads TrEd::Config::preinstalledExtensionsDir
sub get_preinstalled_extensions_dir {
    return $TrEd::Config::preinstalledExtensionsDir;
}

#######################################################################################
# Usage         : get_extension_list($repository)
# Purpose       : Return list of extensions in repository/extensions directory
# Returns       : Reference to array of extension names, empty array reference if repository does not
#                 contain list of extensions. Undef/empty array if extensions directory does not exist
#                 and no $repository is specified
# Parameters    : scalar $repository -- path to extensions repository
# Throws        : carps if extension directory list (extensions.lst) could not be opened
# Comments      : File extensions.lst is searched for in $repository (if it is set) or local extensions directory.
#                 List of extensions listed in this file is returned.
# See Also      : Treex::PML::IO::make_URI(), File::Spec::catfile(), Treex::PML::IO::open_uri(),
#                 Treex::PML::IO::close_uri()
sub get_extension_list {
    my ($repository) = @_;
    my $url;
    if ($repository) {
        $url = Treex::PML::IO::make_URI($repository) . '/extensions.lst';
    }
    else {
        $url = File::Spec->catfile( get_extensions_dir(), 'extensions.lst' );
        return if ( !( -f $url ) );
    }
    my $fh = eval { Treex::PML::IO::open_uri($url) };
    carp($@) if ($@);
    return [] if ( !$fh );
    my $ext_filter = qr{
                            ^               # at the beginning of string, we accept
                            !?              # an optional sign of disabled extension
                            [[:alnum:]_-]+  # the name of extension
                            \s*             # any number of whitespace
                            $               # followed by the end of string
                       }x;
    my @extensions = grep { m/$ext_filter/ } <$fh>;
    foreach my $extension (@extensions) {
        $extension =~ s/\s+$//;
    }
    Treex::PML::IO::close_uri($fh);
    return \@extensions;
}

#######################################################################################
# Usage         : init_extensions([$ext_list, $extension_dir])
# Purpose       : Add stylesheets, lib, macro and resources paths to TrEd paths
#                 for each extension from extensions directory
# Returns       : nothing
# Parameters    : array_ref $ext_list -- reference to list of extension names
#                 scalar $extension_dir     -- name of the directory where extensions are stored
# Throws        : carps if the first argument is a reference, but not array reference
# Comments      : If $ext_list is not supplied, get_extension_list() function is used to get the list
#                 of extensions. If $extension_dir is not supplied, get_extensions_dir() is used to find
#                 the directory for extensions.
# See Also      : Treex::PML::Backend::PML::configure(), get_extensions_dir(), get_extension_list()
sub init_extensions {
    my ( $list, $extension_dir ) = @_;

    # check parameters
    if ( @_ == 0 ) {
        $list = get_extension_list();
    }
    elsif ( ! defined $list || ref $list ne 'ARRAY' ) {
        carp('Usage: init_extensions( [ extension_name(s)... ] )');
        $list = ();
    }
    $extension_dir ||= get_extensions_dir();

    my ( %macro_includes, %resources, %includes, %stylesheets );

    # stylesheet paths
    my @stylesheet_paths = TrEd::Stylesheet::stylesheet_paths();
    if ( @stylesheet_paths ) {
        @stylesheets { grep { defined($_) } @stylesheet_paths } = ();
    }

    # resource paths
    @resources{ Treex::PML::ResourcePaths() } = ();

    # macro include paths
    if (@TrEd::Macros::macro_include_paths) {
        @macro_includes{ grep { defined($_) } @TrEd::Macros::macro_include_paths } = ();
    }

    # perl include paths
    @includes{@INC} = ();

    # add each extension's resources, macros, stylesheets
    # and libs to appropriate paths used by TrEd
    for my $name ( grep { !/^!/ } @{$list} ) {
        my $dir = File::Spec->catdir( $extension_dir, $name, 'resources' );
        if ( -d $dir && !exists( $resources{$dir} ) ) {
            Treex::PML::AddResourcePath($dir);
            $resources{$dir} = 1;
        }
        $dir = File::Spec->catdir( $extension_dir, $name );
        if ( -d $dir && !exists( $macro_includes{$dir} ) ) {
            push @TrEd::Macros::macro_include_paths, $dir;
            $macro_includes{$dir} = 1;
        }
        $dir = File::Spec->catdir( $extension_dir, $name, 'libs' );
        if ( -d $dir && !exists( $includes{$dir} ) ) {
            unshift( @INC, $dir );
            $includes{$dir} = 1;
        }
        $dir = File::Spec->catdir( $extension_dir, $name, 'stylesheets' );
        if ( -d $dir && !exists( $stylesheets{$dir} ) ) {
            TrEd::Stylesheet::add_stylesheet_paths($dir);
            $stylesheets{$dir} = 1;
        }
    }

    # updates resource paths for Treex::PML
    Treex::PML::Backend::PML::configure();
    return;
}

#######################################################################################
# Usage         : get_preinstalled_extension_list([$except, $preinstalled_ext_dir])
# Purpose       : Return list of extensions from pre-installed extensions directory,
#                 except those listed in $except
# Returns       : Reference to array containing extensions from pre-installed extensions directory
# Parameters    : array_ref $except             -- reference to list of extensions to ignore
#                 scalar $preinstalled_ext_dir  -- name of the directory with preinstalled extensions
# Throws        : no exception
# Comments      : If no parameters were supplied, $except is considered to be an empty list,
#                 return value of get_preinstalled_extensions_dir() is used as $preinstalled_ext_dir
# See Also      : get_preinstalled_extensions_dir(), get_extension_list()
sub get_preinstalled_extension_list {
    my ( $except, $preinst_dir ) = @_;
    $except ||= [];
    $preinst_dir ||= get_preinstalled_extensions_dir();
    my $pre_installed_dir_exts
        = ( ( -d $preinst_dir ) && get_extension_list($preinst_dir) ) || [];

    # hash of extensions to return
    my %preinst;

    # remove those extensions that are commented out
    @preinst{ grep { !/^!/ } @{$pre_installed_dir_exts} } = ();

    # delete extensions that should be ignored / not listed
    delete @preinst{ map { /^!?(\S+)/ ? $1 : $_ } @{$except} };

    # filter only those extensions that exist in hash
    # (i.e. those that are not commented out, nor ignored)
    @{$pre_installed_dir_exts}
        = grep { exists( $preinst{$_} ) } @{$pre_installed_dir_exts};
    return $pre_installed_dir_exts;
}

#######################################################################################
# Usage         : get_extension_subpaths($list_ref, $extension_dir, $rel_path)
# Purpose       : Take $list of extensions in $extension_dir directory and return list of
#                 subdirectories specified by $rel_path
# Returns       : List of subdirectories of the extensions in $extension_dir specified by $rel_path
# Parameters    : array_ref $list_ref   -- reference to array of extensions
#                 scalar $extension_dir -- name of the directory containing extensions
#                 scalar $rel_path      -- subdirectory name
# Throws        : carp if $list is a reference, but not a ref to array
# Comments      : Ignores extensions that are commented out by ! at the beginning of line.
#                 If no $list is supplied, get_extension_list() return value is used.
#                 If $extension_dir is not supplied, get_extensions_dir() return value is used
# See Also      : get_extensions_dir(), get_extension_list()
sub get_extension_subpaths {
    my ( $list_ref, $extension_dir, $rel_path ) = @_;
    if ( @_ == 0 ) {
        $list_ref = get_extension_list();
    }
    elsif ( ref $list_ref ne 'ARRAY' ) {
        carp(
            'Usage: get_extension_subpaths( [ extension_name(s)... ], extension_dir, rel_path )'
        );
    }
    $extension_dir ||= get_extensions_dir();
    my @filtered_extensions_list = grep { !/^!/ } @{$list_ref};
    return
        map { File::Spec->catfile( $extension_dir, $_, $rel_path ) }
        @filtered_extensions_list;
}

#######################################################################################
# Usage         : get_extension_sample_data_paths($list_ref, $extension_dir)
# Purpose       : Find all the valid 'sample' subdirectories for all the extensions from
#                 $list in $extension_dir directory
# Returns       : List of existing 'sample' subdirectories for specified extensions
# Parameters    : array_ref $list_ref   -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_sample_data_paths {
    my ( $list_ref, $extension_dir ) = @_;
    return
        grep { -d $_ }
        get_extension_subpaths( $list_ref, $extension_dir, 'sample' );
}

#######################################################################################
# Usage         : get_extension_doc_paths($list_ref, $extension_dir)
# Purpose       : Find all the valid 'documentation' subdirectories for all the extensions from
#                 $list in $extension_dir directory
# Returns       : List of existing 'documentation' subdirectories for specified extensions
# Parameters    : array_ref $list_ref   -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_doc_paths {
    my ( $list_ref, $extension_dir ) = @_;
    return
        grep { -d $_ }
        get_extension_subpaths( $list_ref, $extension_dir, 'documentation' );
}

#######################################################################################
# Usage         : get_extension_template_paths($list_ref, $extension_dir)
# Purpose       : Find all the valid 'templates' subdirectories for all the extensions from
#                 $list in $extension_dir directory
# Returns       : List of existing 'templates' subdirectories for specified extensions
# Parameters    : array_ref $list_ref   -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_template_paths {
    my ( $list_ref, $extension_dir ) = @_;
    return
        grep { -d $_ }
        get_extension_subpaths( $list_ref, $extension_dir, 'templates' );
}

#######################################################################################
# Usage         : _contrib_macro_paths($directory)
# Purpose       : Find all directories and subdirectories of $directory that contains
#                 'contrib.mac' file
# Returns       : List of paths to contrib.mac file in subdirectories of $directory
# Parameters    : scalar $directory -- name of the directory where the search starts
# Throws        : no exception
# See Also      : glob()
sub _contrib_macro_paths {
    my ($directory) = @_;
    return glob( $directory . '/*/contrib.mac' ),
        ( ( -f $directory . '/contrib.mac' )
        ? $directory . '/contrib.mac'
        : () );
}

#######################################################################################
# Usage         : get_extension_macro_paths($list_ref, $extension_dir)
# Purpose       : Find all the paths with 'contrib.mac' file for all the extensions from
#                 $list in $extension_dir directory
# Returns       : List of paths to 'contrib.mac' files for specified extensions
# Parameters    : array_ref $list_ref   -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# Comments      :
# See Also      : get_extension_subpaths()
sub get_extension_macro_paths {
    my ( $list_ref, $extension_dir ) = @_;
    my @contrib_subdirs
        = get_extension_subpaths( $list_ref, $extension_dir, 'contrib' );
    return map { _contrib_macro_paths($_) } @contrib_subdirs;
}

#######################################################################################
# Usage         : get_extension_meta_data($name, $extension_dir)
# Purpose       : Load package.xml metafile for extension $name and create
#                 Treex::PML::Instance object from this metafile
# Returns       : Root data structure returned by Treex::PML::Instance::get_root(),
#                 undef if metafile is not a valid file
# Parameters    : scalar or URI ref $name -- reference to URI object with extension name or the name itself
#                 scalar $extension_dir   -- name of the directory containing extensions
# Throws        : carp if Treex::PML::Instance::load() fails
# Comments      : If $extensions_dir is not supplied, result of get_extensions_dir() is used.
# See Also      : Treex::PML::Instance::load(),
sub get_extension_meta_data {
    my ( $name, $extensions_dir ) = @_;
    my $metafile;
    if ( ( blessed($name) and $name->isa('URI') ) ) {
        $metafile = URI->new('package.xml')->abs( $name . q{/} );
    }
    else {
        $metafile
            = File::Spec->catfile( $extensions_dir || get_extensions_dir(),
            $name, 'package.xml' );
        return if not -f $metafile;
    }
    my $data = eval {
        Treex::PML::Instance->load( { filename => $metafile, } )->get_root();
    };
    carp($@) if $@;
    return $data;
}

#######################################################################################
# Usage         : _inst_file($name)
# Purpose       : Find perl package by name
# Returns       : Path to perl package, if it is found in @INC array, undef otherwise
# Parameters    : scalar $name -- name of the perl package, e.g. Data::Dumper
# Throws        : no exception
# Comments      :
sub _inst_file {
    my ($name) = @_;
    my @packpath;
    @packpath = split /::/, $name;
    $packpath[-1] .= ".pm";
    foreach my $dir (@INC) {
        my $pmfile = File::Spec->catfile( $dir, @packpath );
        if ( -f $pmfile ) {
            return $pmfile;
        }
    }
    return;
}

#######################################################################################
# Usage         : get_module_version($module)
# Purpose       : Find out the version number for installed $module
# Returns       : Undef if module is not present in @INC, version string
#                 found by ExtUtils::MM::parse_version() otherwise
# Parameters    : scalar $module -- name of perl module
# Throws        : no exception
# Comments      : requires CPAN, ExtUtils::MM
# See Also      : _inst_file(),
sub get_module_version {
    my ($module) = @_;
    require CPAN;
    require ExtUtils::MM;
    my $parsefile = _inst_file($module) or return;

    # disable warnings for a while
    local ($^W) = 0;
    my $module_version;

    # Parse a $file and return what $VERSION is set to
    $module_version = MM->parse_version($parsefile) || "undef";

    # get rid of spaces on both sides of string
    $module_version =~ s/^ | $//g;

    # better version of version string, somehow standard
    $module_version = CPAN::Version->readable($module_version);

    # remove spaces
    $module_version =~ s/\s*//g;
    return $module_version;
}


#######################################################################################
# Usage         : compare_module_versions($version_1, $version_2)
# Purpose       : Compare two version numbers
# Returns       : 1 if $version_1 is larger than $version_2,
#                 -1 if $version_1 is smaller than $version_2,
#                 0 if versions are equal,
#                 undef if CPAN could not be loaded
# Parameters    : scalar $version_1 -- first version string
#                 scalar $version_2 -- second version string
# Throws        : no exception
# Comments      : requires CPAN
# See Also      : CPAN::Version->vcmp(),
sub compare_module_versions {
    my ( $v1, $v2 ) = @_;
    return if !eval { require CPAN; 1 };
    return CPAN::Version->vcmp( $v1, $v2 );
}

#######################################################################################
# Usage         : _check_extensions_cmdline_opts($extension_name, $enabled_ref, $disabled_ref, $macro_file_cmdline)
# Purpose       : Tell whether the extension $extension_name is going to be enabled
#                 or disabled according to command line options and extensions file
# Returns       : The name of the extension with or without an exclamation mark
#                 in the beginning (! means the extension is going to disabled)
# Parameters    : string $extension_name -- name of the extension
#                 hash_ref $enabled_ref -- ref to hash of explicitly enabled extensions
#                 hash_ref $disabled_ref -- ref to hash of explicitly disabled extensions
#                 string $macro_file_cmdline -- the string from -m switch on command line
# Throws        : no exception
# Comments      : If any macro is specified on the command line, the extensions are
#                 disabled by default. Specifying enabled extensions on command line
#                 has however, higher priority.
# See Also      : prepare_extensions()
sub _check_extensions_cmdline_opts {
    my ($extension_name, $enabled_ref, $disabled_ref, $macro_file_cmdline) = @_;
    # ext name starts with '!' ~ is disabled
    if ($extension_name =~ m/^!(.*)/) {

        if (exists $enabled_ref->{'*'} && !exists $disabled_ref->{$1}
            || exists $enabled_ref->{$1})
        {
            # user forced enable all && did not disable this extension
            # => make extension enabled
            return $1;
        }
        else {
            # otherwise, keep the extension disabled
            return $extension_name;
        }
    }
    else {
        # if a macro is specified on the command line
        # treat the extension as if it was disabled
        # in extension list file
        if ($macro_file_cmdline) {
            if ( exists $enabled_ref->{'*'}
                    && !exists $disabled_ref->{$extension_name}
                 || exists $enabled_ref->{$extension_name} )
            {
                return $extension_name;
            }
            else {
                return '!'.$extension_name;
            }
        }
        else {
            if (exists $disabled_ref->{'*'}
                    && !exists $enabled_ref->{$extension_name}
                || exists $disabled_ref->{$extension_name} )
            {
                # all extensions are disables
                #  and this one is not explicitly enabled
                # or this extension is explicitly disabled
                # => disable extension
                return q{!} . $extension_name;
            }
            else {
                # otherwise just keep the extension enabled
                return $extension_name;
            }
        }

    }
}

#######################################################################################
# Usage         : prepare_extensions($macro_file_cmdline)
# Purpose       : Prepare all the installed extensions for use
# Returns       : Reference to array which contains two array references: first one
#                 is a reference to array of installed extensions, second one is a ref
#                 to array of preinstalled extensions
# Parameters    : scalar $macro_file_cmdline -- command line argument -- macro file to read
# Throws        : carp if required extension could not be found
# Comments      : Also reflects command-line arguments which can enable and disable
#                 loading of extensions
# See Also      : init_extensions()
sub prepare_extensions {
    my ($macro_file_cmdline) = @_;
    my $extensions           = get_extension_list();
    my $pre_installed        = get_preinstalled_extension_list($extensions);

    my ( %enabled, %disabled );
    @enabled{ split /,/,  $enable_extensions }  = ();
    @disabled{ split /,/, $disable_extensions } = ();

    #   if (defined $opt_m) {
    #     warn("Using -m implies all extensions disabled...\n") unless $opt_q;
    #  }

    @{$extensions}
        = map {
        _check_extensions_cmdline_opts( $_, \%enabled, \%disabled,
            $macro_file_cmdline )
        } @{$extensions};

    @{$pre_installed}
        = map {
        _check_extensions_cmdline_opts( $_, \%enabled, \%disabled,
            $macro_file_cmdline )
        } @{$pre_installed};

    my %have;
    @have{ @{$extensions}, @{$pre_installed} } = ();

    for my $required ( keys %enabled ) {
        if ( $required ne q{*} and !exists $have{$required} ) {
            carp("WARNING: extension $required not found!");
        }
    }

    init_extensions($extensions);
    init_extensions( $pre_installed, get_preinstalled_extensions_dir() );

    return [ $extensions, $pre_installed ];
}


1;

__END__


=head1 NAME


TrEd::Extensions - GUI & code for managing Extensions and repositories


=head1 VERSION

This documentation refers to
TrEd::Extensions version 0.2.


=head1 SYNOPSIS

  use TrEd::Extensions;

  my $ext_directory = TrEd::Extensions::get_extensions_dir();

  my @extension_list = qw{
    extension_one
    extension_two
  };
  my $ext_path = "/home/john/.tred.d/extensions";

  TrEd::Extensions::init_extensions(\@extension_list, $ext_path);

  my $repo_URI = "http://tred.com/extensions/";
  my $ext_in_repo = TrEd::Extensions::get_extension_list($repo_URI); # returns ref to array


  my @macro_paths = TrEd::Extensions::get_extension_macro_paths(\@extension_list, $ext_path);
  my @sample_data_paths = TrEd::Extensions::get_extension_sample_data_paths(\@extension_list, $ext_path);
  my @doc_paths = TrEd::Extensions::get_extension_doc_paths(\@extension_list, $ext_path);
  my @template_paths = TrEd::Extensions::get_extension_template_paths(\@extension_list, $ext_path);

  my $preinstalled_ext_dir = TrEd::Extensions::get_preinstalled_extensions_dir();
  my $preinstalled_extensions = TrEd::Extensions::get_preinstalled_extension_list(); # ref to array

  my $subpath = "macros";
  my @subpaths = TrEd::Extensions::get_extension_subpaths(\@extension_list, $ext_path, $subpath);

  my $opts = {
    repositories => $repos,
    reload_macros => \$reload_macros,
  }
  # fires up the GUI installer
  TrEd::Extensions::manage_extensions_dialog($tred, $opts);



=head1 DESCRIPTION

Package for managing TrEd's extensions -- installation, removing, enabling and disabling.
Uses Tk to create GUI to perform these changes.

=head1 SUBROUTINES/METHODS

=over 4


=item * C<TrEd::Extensions::short_name($pkg_name)>

=over 6

=item Purpose

Construct short name for package $pkg_name

=item Parameters

  C<$pkg_name> -- scalar or blessed URI ref $pkg_name -- name of the package

=item Comments

If $pkg name is blessed URI reference, everything from the beginning
of $pkg_name to last slash is removed and the rest is returned.
Otherwise $pkg_name is returned without any modification


=item Returns

Short name for $pkg_name

=back


=item * C<TrEd::Extensions::_repo_extensions_uri_list($opts_ref)>

=over 6

=item Purpose

Create list of triples: repository, extension name, extension URI
for repositories listed in $opts_ref->{repositories}

=item Parameters

  C<$opts_ref> -- hash_ref $opts_ref -- reference to hash with options

=item Comments

Options hash reference should contain list of repositories in
$opts_ref->{repositories}, information about installed extensions
as a hash $opts_ref->{installed}{installed_ext_name}.
If we are updating extensions, $opts_ref->{only_upgrades} should be set.

=item See Also

L<Treex::PML::IO::make_URI()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/IO::make_URI.pm>,

=item Returns

List of array references, each array contains triple repo, extension
name, extension URI

=back


=item * C<TrEd::Extensions::_update_progressbar($opts_ref)>

=over 6

=item Purpose

Update progress information and progressbar

=item Parameters

  C<$opts_ref> -- hash_ref $opts_ref -- reference to hash of options

=item Comments

Hash of options should contain at least $opts_ref->{progress} and
$opts_ref->{progressbar}


=item Returns

Undef in scalar context, empty list in list context

=back


=item * C<TrEd::Extensions::cmp_revisions($my_revision, $other_revision)>

=over 6

=item Purpose

Compare two revision numbers

=item Parameters

  C<$my_revision> -- scalar $my_revision     -- first revision string (e.g. 1.256)
  C<$other_revision> -- scalar $other_revision  -- second revision string (e.g. 1.1024)

=item Comments

E.g. 1.1024 > 1.256, thus cmp_revisions("1.1024", "1.256") should return 1


=item Returns

-1 if $my_revision is numerically less than $other_revision,
0 if $my_revision is equal to $other_revision
1 if $my_revision is greater than $other_revision
Undef/empty list, if one of the revisions is not defined.

=back


=item * C<TrEd::Extensions::_version_ok($my_version, $required_extension_ref)>

=over 6

=item Purpose

Test whether the installed version of extension is between
min and max required version (if specified)

=item Parameters

  C<$my_version> -- scalar $my_version               -- version of installed extension
  C<$required_extension_ref> -- hash_ref $required_extension_ref -- ref to hash which contains required version info

=item Comments

Required extension hash should contain at least min_version and
max_version values

=item See Also

L<cmp_revisions>,

=item Returns

True if the installed version is ok, false otherwise

=back


=item * C<TrEd::Extensions::_ext_not_installed_or_actual($meta_data_ref, $installed_ver)>

=over 6

=item Purpose

Test whether the extension is not installed or is not up to date

=item Parameters

  C<$meta_data_ref> -- hash_ref $meta_data_ref -- reference to meta data about the extension
  C<$installed_ver> -- scalar $installed_ver   -- version of installed extension (if any)


=item See Also

L<cmp_revisions>,

=item Returns

Extension's version from repository if it is not installed,
True if the extension is installed, but not up to date.
0 if the extension is not installed or up to date $meta_data_ref is not defined

=back


=item * C<TrEd::Extensions::_resolve_missing_dependency({req_data           => $req_data,
required_extension => $required_extension,
short_name         => $short_name,
repo               => $repo,
dialog_box         => $dialog_box })
>

=over 6

=item Purpose

Ask user what to do with unresolved dependencies

=item Parameters

  C<$req_data> -- hash_ref $req_data           -- reference to hash containing at least 'version' key
  C<$required_extension> -- hash_ref $required_extension -- reference to hash of info about required extension
  C<$short_name> -- scalar $short_name           -- short name of extension whose dependecies are searched for
  C<$repo> -- scalar $repo                 -- URL of the repository which contains $short_name extension
  C<$dialog_box> -- Tk::DialogBox $dialog_box    -- DialogBox object for creating GUI & interaction with the user

=item Comments

Needs Tk and uses its QuestionQueryAuto function


=item Returns

User's choice: string 'Cancel', 'Ignore versions'/'Ignore dependencies'
or 'Skip pkg_name'.
Returns undef if correct version of extension is available in the repository.

=back


=item * C<TrEd::Extensions::_add_required_exts({extension_data_ref    => $extension_data_ref,
extensions_list_ref   => $extensions_list_ref,
uri_in_repository_ref => \%uri_in_repository,
uri                   => $uri,
short_name            => $short_name,
dialog_box            => $dialog_box,
opts_ref              => $opts_ref,
})
>

=over 6

=item Purpose

Check requirements of each extension that is required by $uri extension
and add all the requirements to $extensions_list_ref
(if they are not already in the list, installed or up-to date)

=item Parameters

  C<$extension_data_ref> -- hash_ref $extension_data_ref    -- hash reference to extension's meta data
  C<$extensions_list_ref> -- array_ref $extensions_list_ref  -- reference to array containing list of information about extensions
  C<\%uri_in_repository> -- hash_ref $uri_in_repository_ref -- ref to hash of URIs in repositories
  C<$uri> -- scalar $uri                     -- URI of the extension whose requirements are searched for
  C<$short_name> -- scalar $short_name              -- name of the extension whose requirements are searched for
  C<$dialog_box> -- Tk::DialogBox $dialog_box       -- dialog box for creating GUI elements
  C<$opts_ref> -- hash_ref $opts_ref              -- populate_extension_pane options

=item Comments

If any of the required extensions is missing, user is prompted with dialog
to choose whether TrEd should ignore the dependency, cancel the installation
or skip installation of the extension.
$extensions_list_ref and $uri_in_repository_ref can be modified as a side effect
during finding new dependencies. This function can also modify %requires and
required_by hash.

=item See Also

L<_resolve_missing_dependency>,

=item Returns

String 'Cancel' if user chooses to cancel installation,
'Skip' if user chooses to skip extension $uri, undef otherwise

=back


=item * C<TrEd::Extensions::_fill_required_by($id)>

=over 6

=item Purpose

Construct hash with information, which extensions depend on specified
extension from $requires hash

=item Parameters

  C<$id> -- scalar $id -- extension's identification (URI/name)

=item Comments

Uses $requires and $required_by package variables


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_uri_list_with_required_exts({extension_data_ref  => $extension_data_ref,
opts_ref            => $opts_ref,
dialog_box          => $dialog_box,
});
>

=over 6

=item Purpose

Create list of URIs of extensions that are not installed or up-to date
from repository specified in opts_ref hash

=item Parameters

  C<$extension_data_ref> -- hash_ref $extension_data_ref   -- ref to hash of meta data about extensions
  C<$opts_ref> -- hash_ref $opts_ref             -- ref to hash of populate_extension_pane options
  C<$dialog_box> -- Tk::DialogBox $dialog_box      -- dialg box to create GUI elements

=item Comments

opts_ref hash should contain an element with name 'repositories', whose
value is a reference to array of extension repositories (as their URIs) and
an element with key 'installed', whose value is a hash reference
with names of isntalled extensions as keys and their installed versions as
corresponding values.

=item See Also

L<_update_progressbar>,
L<_ext_not_installed_or_actual>,
L<_add_required_exts>,
L<_fill_required_by>,

=item Returns

Reference to array of URIs or undef/empty list if cancelled by user

=back


=item * C<TrEd::Extensions::_list_of_installed_extensions({pre_installed_ref   => $pre_installed_ref,
enable_ref          => $enable_ref,
opts_ref            => $opts_ref,
extension_data_ref  => $extension_data_ref,
});
>

=over 6

=item Purpose

Create list of URIs of preinstalled and installed extensions

=item Parameters

  C<$pre_installed_ref> -- hash_ref pre_installed_ref        -- ref to hash of pre-installed extensions
  C<$enable_ref> -- hash_ref $enable_ref              -- ref to hash of enabled extensions
  C<$opts_ref> -- hash_ref $opts_ref                -- ref to hash of populate_extension_pane options
  C<$extension_data_ref> -- hash_ref $extension_data_ref      -- ref to hash of meta data about extensions

=item Comments

Also creates a hash of enabled extensions (those that are listed with exclamation
mark in the beginning are disabled). As a side effect, requires and required_by hashes
are updated with new information about the extensions.
Only 'progressbar' option is used from $opts_ref hash in this function.

=item See Also

L<_update_progressbar>,
L<_ext_not_installed_or_actual>,
L<_add_required_exts>,
L<_fill_required_by>,

=item Returns

Reference to array of URIs

=back


=item * C<TrEd::Extensions::_create_ext_list({pre_installed_ref     => \%pre_installed,
extension_data_ref    => \%extension_data,
enable_ref            => \%enable,
opts_ref              => $opts_ref,
dialog_box            => $dialog_box,
});
>

=over 6

=item Purpose

Create list of extensions

=item Parameters

  C<\%pre_installed> -- hash_ref $pre_installed_ref   -- ref to empty hash of preinstalled extensions (filled by _list_of_installed_extensions)
  C<\%extension_data> -- hash_ref $extension_data_ref  -- ref to empty hash of extensions' data (filled by this function)
  C<\%enable> -- hash_ref $enable_ref          -- ref to empty hash of enabled & disabled extensions (filled by this function)
  C<$opts_ref> -- hash_ref $opts_ref            -- ref to hash of options
  C<$dialog_box> -- Tk::DialogBox $dialog_box     -- dialg box to create GUI elements

=item Comments

If $opts_ref->{install} is set to true, list of URIs of extensions that are not
installed or are not up-to date is returned. Otherwise, list of installed
and preinstalled extensions' names is returned.
extension_data_ref is filled accordingly, i.e. if list of URIs is returned,
the keys of %{$extension_data_ref} hash are URIs, otherwise the keys are names
of extensions.

=item See Also

L<_list_of_installed_extensions>,
L<_uri_list_with_required_exts>,

=item Returns

Reference to list of extensions/their URIs

=back


=item * C<TrEd::Extensions::_required_tred_version($extension_data_ref)>

=over 6

=item Purpose

Test whether TrEd's version corresponds with extension's requirements

=item Parameters

  C<$extension_data_ref> -- hash_ref $extension_data_ref -- ref to hash with meta data about the extension


=item See Also

L<TrEd::Version::CMP_TRED_VERSION_AND>,
L<TrEd::Version::TRED_VERSION>,

=item Returns

Empty string if TrEd's version is ok, error message otherwise

=back


=item * C<TrEd::Extensions::_required_perl_modules($req_modules_ref)>

=over 6

=item Purpose

Test whether all the perl module dependencies of extension are satisfied

=item Parameters

  C<$req_modules_ref> -- array_ref $req_modules_ref -- ref to list of required perl modules


=item See Also

L<compare_module_versions>,
L<get_module_version>,

=item Returns

Empty string if all the dependencies are installed, error message otherwise

=back


=item * C<TrEd::Extensions::_required_perl_version($req_modules_ref)>

=over 6

=item Purpose

Test whether the perl's version corresponds with extension's requirements

=item Parameters

  C<$req_modules_ref> -- array_ref $req_modules_ref -- ref to list of requirements



=item Returns

Empty string if Perl's version is ok, error message otherwise

=back


=item * C<TrEd::Extensions::_find_uninstallable_exts($ext_list_ref, $extension_data_ref)>

=over 6

=item Purpose

Test all the requirements of extension from @$ext_list_ref

=item Parameters

  C<$ext_list_ref> -- array_ref $ext_list_ref       -- ref to array of extensions' URIs/names
  C<$extension_data_ref> -- hash_ref $extension_data_ref  -- ref to hash of extensions' meta data


=item See Also

L<_required_tred_version>,
L<_required_perl_modules>,
L<_required_perl_version>,

=item Returns

Reference to hash of extensions that can't be installed

=back


=item * C<TrEd::Extensions::_dependencies_of_req_exts($ext_list_ref, $uninstallable_ref)>

=over 6

=item Purpose

Test whether all the dependecies of extensions from @$ext_list_ref are satisfied

=item Parameters

  C<$ext_list_ref> -- array_ref $ext_list_ref     -- ref to list of extensions' names
  C<$uninstallable_ref> -- hash_ref $uninstallable_ref -- ref to hash of extensions that can't be installed (due to unsatisfied dependencies)

=item Comments

Modifies $uninstallable_ref hash according to the uninstallability of
required extensions


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_set_extension_icon({data              => $data,
name              => $name,
pre_installed_ref => $pre_installed_ref,
text              => $text,
generic_icon      => $generic_icon,
opts_ref          => $opts_ref,
});
>

=over 6

=item Purpose

Set extension's icon

=item Parameters

  C<$data> -- hash_ref $data              -- ref to hash with extension's meta data
  C<$name> -- scalar/URI $name            -- name or URI of the extension
  C<$pre_installed_ref> -- hash_ref $pre_installed_ref -- ref to hash containing names of preinstalled extensions (& empty values)
  C<$text> -- Tk::ROText $text            -- ref to ROText on which the Labels/icons are created
  C<$generic_icon> -- Tk::Photo $generic_icon     -- ref to Tk::Photo with generic extension icon
  C<$opts_ref> -- hash_ref $opts_ref          -- ref to options hash

=item Comments

If extension's meta $data->{icon} is set, it is used.
Generic icon is used otherwise.


=item Returns

Tk::Label object with icon set

=back


=item * C<TrEd::Extensions::_set_name_desc_copyright({data_ref          => $data_ref,
name              => $name,
pre_installed_ref => \%pre_installed,
text              => $text,
opts_ref          => $opts_ref,
});
>

=over 6

=item Purpose

Set name, description and copyright information for extension

=item Parameters

  C<$data_ref> -- hash_ref $data_ref          -- ref to hash containing meta data of the extension
  C<$name> -- scalar $name                -- name of the extension
  C<\%pre_installed> -- hash_ref $pre_installed_ref -- ref to hash of preinstalled extensions
  C<$text> -- Tk::ROText $text            -- ROText where the text is added
  C<$opts_ref> -- hash_ref $opts_ref          -- ref to hash of options

=item Comments

If $data_ref is not set, $name is used as name, other fields are left blank


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_fmt_size($size)>

=over 6

=item Purpose

Convert (and round) information amount from bytes to MiB, KiB or GiB,
so that numerical part of the expression is an integer between 1 and 1023

=item Parameters

  C<$size> -- scalar $size -- number of bytes



=item Returns

Number with information unit

=back


=item * C<TrEd::Extensions::_set_ext_size($data_ref, $text, $name)>

=over 6

=item Purpose

Insert size of extension $name to $text

=item Parameters

  C<$data_ref> -- hash_ref $data_ref  -- ref to hash containing meta data about the extension
  C<$text> -- Tk::ROText $text    -- ROText where the info about extension's size is added
  C<$name> -- scalar $name        -- extension's name

=item Comments

Only added if $data_ref->{install_size} or $data_ref->{package_size} is set

=item See Also

L<_fmt_size>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_required_by($name, $exists_ref)>

=over 6

=item Purpose

Find all the dependendents for $name listed in %required_by
hash; continue recusively for all dependendents which exist
in $exists_ref hash

=item Parameters

  C<$name> -- scalar $name          -- name of entity, whose dependecies are searched for
  C<$exists_ref> -- hash_ref $exists_ref  -- reference to hash containing elements for which the recursion is allowed


=item See Also

L<_requires>,

=item Returns

List of dependendents

=back


=item * C<TrEd::Extensions::_requires($name, $exists_ref)>

=over 6

=item Purpose

Find all the dependendencies for $name listed in %requires
hash; continue recusively for all dependencies which exist
in $exists_ref hash

=item Parameters

  C<$name> -- scalar $name          -- name of entity, whose dependecies are searched for
  C<$exists_ref> -- hash_ref $exists_ref  -- reference to hash containing elements for which the recursion is allowed


=item See Also

L<_required_by>,

=item Returns

List of dependencies

=back


=item * C<TrEd::Extensions::_upgrade_install_checkbutton(\%enable, $ext_name)>

=over 6

=item Purpose

Mark extension and its requirements to be installed/upgraded

=item Parameters

  C<\%enable> -- hash_ref $enable_ref  -- ref to hash of extensions to install/upgrade
  C<$ext_name> -- scalar $ext_name      -- name of extension

=item Comments

Upgrade/install checkbox callback -- called every time checkbox's state changes
If extension is selected, adds reflexive dependency and enables all required extensions.
If it is unselected, removes reflexive dependency and disables required extensions,
if they are not required by another extension (which does not have to be installed -> why is that? :/).

=item See Also

L<_requires>,

=item Returns

Undef/Empty list

=back


=item * C<TrEd::Extensions::_enable_checkbutton($name, $opts_ref, $enable_ref, $dialog_box)>

=over 6

=item Purpose

Enable/disable extensions and their dependants

=item Parameters

  C<$name> -- scalar $name              -- name of extension which is being enabled/disabled
  C<$opts_ref> -- hash_ref $opts_ref        -- ref to hash of options
  C<$enable_ref> -- hash_ref $enable_ref      -- ref to hash of extensions to enable/disable
  C<$dialog_box> -- Tk::DialogBox $dialog_box -- dialog box to create GUI elements

=item Comments

Enable checkbox callback -- called every time checkbox's state changes.
Updates also the extensions list file.

=item See Also

L<update_extensions_list>,
L<_requires>,
L<_required_by>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_uninstall_button($name, $embedded_ref, $text, $dialog_box, $opts_ref)>

=over 6

=item Purpose

Uninstall extension callback

=item Parameters

  C<$name> -- scalar $name              -- extension's name
  C<$embedded_ref> -- hash_ref $embedded_ref    -- ref to hash of pairs ext_name => [Tk::Frame, Tk::Image]
  C<$text> -- Tk::ROText $text          -- ROText from which the extension's info is removed
  C<$dialog_box> -- Tk::DialogBox $dialog_box -- dialog box for creating GUI elements
  C<$opts_ref> -- hash_ref $opts_ref        -- ref to hash of options

=item Comments

If the user allows it, also dependent extensions are removed.
Information about the extensions is removed also from $opts_ref->{versions}
and $embedded_ref


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_enter_text($text, $name, $frame, $image)>

=over 6

=item Purpose

Change background to light blue and focus when entered on text area

=item Parameters

  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed
  C<$image> -- Tk::Image $image  -- image, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_frame>,
L<_any_enter_image>,
L<_any_leave_text>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_enter_frame($frame, $text, $name, $image)>

=over 6

=item Purpose

Change background to light blue and focus when entered on frame area

=item Parameters

  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed
  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$image> -- Tk::Image $image  -- image, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_text>,
L<_any_enter_image>,
L<_any_leave_frame>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_enter_image($image, $text, $name, $frame)>

=over 6

=item Purpose

Change background to light blue when entered on image area

=item Parameters

  C<$image> -- Tk::Image $image  -- image, whose background is changed
  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_frame>,
L<_any_enter_text>,
L<_any_leave_image>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_leave_text($text, $name, $frame, $image)>

=over 6

=item Purpose

Change background to white when leaving the text area

=item Parameters

  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed
  C<$image> -- Tk::Image $image  -- image, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_text>,
L<_any_leave_image>,
L<_any_leave_frame>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_leave_text($frame, $text, $name, $image)>

=over 6

=item Purpose

Change background to white when leaving the frame area

=item Parameters

  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed
  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$image> -- Tk::Image $image  -- image, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_frame>,
L<_any_leave_text>,
L<_any_leave_image>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_any_leave_image($image, $text, $name, $frame)>

=over 6

=item Purpose

Change background to white when leaving the text area

=item Parameters

  C<$image> -- Tk::Image $image  -- image, whose background is changed
  C<$text> -- Tk::ROText $text  -- ROText, whose background is changed
  C<$name> -- scalar $name      -- extension's name
  C<$frame> -- Tk::Frame $frame  -- frame, whose background is changed

=item Comments

Callback function

=item See Also

L<_any_enter_image>,
L<_any_leave_frame>,
L<_any_leave_text>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_create_checkbutton({tred              => $tred,
name              => $name,
frame             => $frame,
enable_ref        => $enable_ref,
text              => $text,
uninstallable_ref => $uninstallable_ref,
embedded_ref      => \%embedded,
pre_installed_ref => $pre_installed_ref,
opts_ref          => $opts_ref,
dialog_box        => $dialog_box,
});
>

=over 6

=item Purpose

Create Enable/Upgrade/Install checkbutton and Uninstall button if appropriate

=item Parameters

  C<$tred> -- hash_ref $tred              -- ref to hash that contains TrEd window global data
  C<$name> -- scalar/URI $name            -- name/URI of the extension
  C<$frame> -- Tk::Frame $frame            -- frame on which the buttons are created
  C<$enable_ref> -- hash_ref $enable_ref        -- ref to hash with extensions that will be changed (enabled/disabled/(un)installed)
  C<$text> -- Tk::ROText $text            -- ROText with extensions' information
  C<$uninstallable_ref> -- hash_ref $uninstallable_ref -- ref to hash of uninstallable extensions
  C<\%embedded> -- hash_ref $embedded_ref      -- ref to hash of pairs ext_name => [Tk::Frame, Tk::Image]
  C<$pre_installed_ref> -- hash_ref $pre_installed_ref -- ref to hash of preinstalled extensions (keys are names of extensions, no values)
  C<$opts_ref> -- hash_ref $opts_ref          -- ref to hash of options
  C<$dialog_box> -- Tk::DialogBox $dialog_box   -- dialog box for creating GUI elements

=item Comments

If $name is a blessed URI reference, Upgrade/Install checkbuttons are created.
Otherwise Enable and Uninstall buttons are created.


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_add_pane_items({ext_list_ref        => $ext_list_ref,
extension_data      => \%extension_data,
text                => $text,
tred                => $tred,
pre_installed_ref   => \%pre_installed,
opts_ref            => $opts_ref,
enable_ref          => \%enable,
uninstallable_ref   => $uninstallable_ref,
dialog_box          => $dialog_box,
});
>

=over 6

=item Purpose

For each extension from @$ext_list_ref add item on window panner

=item Parameters

  C<$ext_list_ref> -- array_ref $ext_list_ref      -- ref to list of extenions' URIs
  C<\%extension_data> -- hash_ref $extension_data_ref -- ref to hash of pairs ext URI => ext meta data
  C<$text> -- Tk::ROText $text             -- ROText with extensions' information
  C<$tred> -- hash_ref $tred               -- ref to hash that contains TrEd window global data
  C<\%pre_installed> -- hash_ref $pre_installed_ref  -- ref to hash of preinstalled extensions (keys are names of extensions, no values)
  C<$opts_ref> -- hash_ref $opts_ref           -- ref to hash of options
  C<\%enable> -- hash_ref $enable_ref         -- ref to hash with extensions that will be changed (enabled/disabled/(un)installed)
  C<$uninstallable_ref> -- hash_ref $uninstallable_ref  -- ref to hash of uninstallable extensions
  C<$dialog_box> -- Tk::DialogBox $dialog_box    -- dialog box for creating GUI elements

=item Comments

Also sets up callbacks for mouse over events and scrolling wheel


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_populate_extension_pane($tred, $dialog_box, $opts_ref)>

=over 6

=item Purpose

Create and populate extension window panner

=item Parameters

  C<$tred> -- hash_ref $tred            -- ref to hash that contains TrEd window global data
  C<$dialog_box> -- Tk::DialogBox $dialog_box -- dialog box for creating GUI elements
  C<$opts_ref> -- hash_ref $opts_ref        -- ref to hash of options

=item Comments

Creates list of extension, finds information about dependencies between them,
dependencies on other perl modules, perl version and TrEd version. Populates
window panner with extensions and creates buttons to Install/Uninstall,
Enable/Disable them.
Returned hash's keys are URIs of extensions. Values are 0, 1, or undef, where
1 means to enable/install extension, 0 to disable/uninstall extension.

=item See Also

L<_add_pane_items>,
L<_create_ext_list>,

=item Returns

Reference to hash which contains information about extensions' changes

=back


=item * C<TrEd::Extensions::_install_ext_button($enable_ref, $manage_ext_dialog, $opts_ref, $INSTALL);>

=over 6

=item Purpose

Create progressbar and installs extensions marked for installation in
%$enable_ref hash

=item Parameters

  C<$enable_ref> -- hash_ref $enable_ref             -- ref to hash of extensions to install
  C<$manage_ext_dialog> -- Tk::DialogBox $manage_ext_dialog -- dialog box for creating GUI elements
  C<$opts_ref> -- hash_ref $opts_ref               -- ref to hash of options
  C<$INSTALL> -- scalar $INSTALL                  -- sign on Install button

=item Comments

Callback function for 'Install selected' button

=item See Also

L<_update_install_new_button>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_update_install_new_button({manage_ext_dialog => $manage_ext_dialog,
tred              => $tred,
enable_ref        => $enable_ref,
INSTALL           => $INSTALL,
opts_ref          => $opts_ref,
upgrades          => $upgrades
});
>

=over 6

=item Purpose

Create dialog box with listed extensions which allows user to install new
or update existing extensions

=item Parameters

  C<$manage_ext_dialog> -- Tk::DialogBox $manage_ext_dialog -- dialog box for creating GUI elements
  C<$tred> -- hash_ref $tred        -- ref to hash that contains TrEd window global data
  C<$enable_ref> -- hash_ref $enable_ref  -- ref to hash of extensions to update/install
  C<$INSTALL> -- scalar $INSTALL       -- sign on Install button
  C<$opts_ref> -- hash_ref $opts_ref    -- ref to hash of options
  C<$upgrades> -- scalar $upgrades      -- 0 when installing, 1 when updating extensions

=item Comments

Callback function for 'Get new extensions' and 'Check for updates' buttons

=item See Also

L<manage_repositories>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::manage_extensions_dialog($tred, $opts_ref)>

=over 6

=item Purpose

Create dialog box with listed extensions which allows user to install,
update, remove, enable and disable extensions

=item Parameters

  C<$tred> -- hash_ref $tred      -- ref to hash that contains TrEd window global data
  C<$opts_ref> -- hash_ref $opts_ref  -- ref to hash of options

=item Comments

opts_ref should contain 'install' key in case Install button should appear
on the widget. opts_ref->{repositories} should be a ref to a list of repositories
with extensions.

=item See Also

L<manage_repositories>,
L<install_extensions>,
L<Tk::DialogBox::Show>,

=item Returns

Result of Tk::DialogBox::Show() function, i.e. name of the Button invoked,
undef/empty list if no change was requested by the user

=back


=item * C<TrEd::Extensions::_repo_ok_or_forced($url, $manage_repos_dialog, $listbox)>

=over 6

=item Purpose

Check whether the repository on $url is valid and if not, ask user
what to do

=item Parameters

  C<$url> -- scalar $url                         -- url of the repository
  C<$manage_repos_dialog> -- Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
  C<$listbox> -- Tk::Listbox $listbox                -- listbox with listed repositories


=item See Also

L<_add_repo>,

=item Returns

True if repository is found and is not a duplicate of already existing one,
or if the user chooses to add non-duplicit repository. False otherwise.

=back


=item * C<TrEd::Extensions::_add_repo($manage_repos_dialog, $manage_repos_listbox)>

=over 6

=item Purpose

Prompt user to input repository URL, validate and add the extension repository

=item Parameters

  C<$manage_repos_dialog> -- Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
  C<$manage_repos_listbox> -- Tk::Listbox $listbox                -- listbox with listed repositories

=item Comments

Callback for 'Add repository' button

=item See Also

L<_remove_repo>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_remove_repo($manage_repos_dialog, $manage_repos_listbox)>

=over 6

=item Purpose

Remove selected extension repositories

=item Parameters

  C<$manage_repos_dialog> -- Tk::DialogBox $manage_repos_dialog  -- dialog box for creating GUI elements
  C<$manage_repos_listbox> -- Tk::Listbox $listbox                -- listbox with listed repositories

=item Comments

Callback for 'Remove' repository button

=item See Also

L<_add_repo>,

=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::manage_repositories($top, $repos)>

=over 6

=item Purpose

Add, remove and save extension repositories for TrEd

=item Parameters

  C<$top> -- Tk::DialogBox $top  -- dialog box for creating GUI elements
  C<$repos> -- hash_ref $repos_ref -- ref to hash of repositories

=item Comments

Callback for 'Edit repositories' button


=item Returns

Return value of Tk::DialogBox::Show(), i.e. name of the Button invoked,
in this case one of 'Add', 'Remove', 'Save' and 'Cancel'

=back


=item * C<TrEd::Extensions::update_extensions_list($name, $enable[, $extension_dir])>

=over 6

=item Purpose

Update local extensions list file

=item Parameters

  C<$name> -- scalar/array_ref $name -- name of extension(s) to enable/disable
  C<$enable[> -- scalar $enable -- 1 if extension(s) should be enabled, 0 otherwise
  C<$extension_dir> -- scalar $extension_dir -- local directory where the extensions are stored



=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_load_extension_file($extension_list_file)>

=over 6

=item Purpose

Load extension file list if it exists. Otherwise use standard begin commentary.

=item Parameters

  C<$extension_list_file> -- scalar $extension_list_file -- path to extension list file

=item Comments

If $extension_list_file exists, it is read and its lines are returned
as a list. Otherwise, just a list of lines of beginning commentary is returned.


=item Returns

List of extensions read from $extension_list_file

=back


=item * C<TrEd::Extensions::_force_reinstall($opts_ref, $name, $dir)>

=over 6

=item Purpose

Ask user whether to force extension's reinstallation/update

=item Parameters

  C<$opts_ref> -- hash_ref $opts_ref -- ref to hash of options
  C<$name> -- scalar $name       -- name of the extension
  C<$dir> -- scalar $dir        -- extensions' directory



=item Returns

If $opts_ref->{quiet} is 0, return value of QuestionQueryAuto is returned.
Undef/empty list is returned otherwise.

=back


=item * C<TrEd::Extensions::_report_install_error($opts_ref, $error_message, $eval_error)>

=over 6

=item Purpose

Display $error_message if using GUI, carp otherwise

=item Parameters

  C<$opts_ref> -- hash_ref $opts_ref    -- ref to hash of options
  C<$error_message> -- scalar $error_message -- error message to display
  C<$eval_error> -- scalar $eval_error    -- error from last eval

=item Comments

$opts_ref->{tk} has to be set to Tk::DialogBox to display error message in GUI


=item Returns

Undef/empty list

=back


=item * C<TrEd::Extensions::_install_extension_from_zip($dir, $url, $opts_ref)>

=over 6

=item Purpose

Install extension from $url to directory $dir

=item Parameters

  C<$dir> -- hash_ref $opts_ref  -- ref to hash of options
  C<$url> -- scalar $dir         -- extensions' directory
  C<$opts_ref> -- scalar $url         -- URL of the extension

=item Comments

Tries to download extension as a zip file from $url, extracts archive
using Archive::Zip and fixes permissions of files if needed.

=item See Also

L<install_extensions>,
L<Treex::PML::IO::fetch_file()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/IO::fetch_file.pm>,

=item Returns

Zero if some error occured, 1 if successful

=back


=item * C<TrEd::Extensions::install_extensions($urls_ref, $opts_ref)>

=over 6

=item Purpose

Install extensions from list @$urls_ref

=item Parameters

  C<$urls_ref> -- array_ref $urls_ref -- ref to list of extensions to install (theirs URLs)
  C<$opts_ref> -- hash_ref $opts_ref  -- ref to hash of options

=item Comments

Creates extension directory if it does not exist, loads extension list file,
uninstalls old versions of extensions if updating (or if the installation is
forced). Then the function downloads extensions & installs them and updates
extension file list.

=item See Also

L<uninstall_extension>,

=item Returns

1 on success, undef/empty list if $urls_ref is a reference to empty array

=back


=item * C<TrEd::Extensions::uninstall_extension($name, $opts_ref)>

=over 6

=item Purpose

Uninstall extension from extension directory and update extension list

=item Parameters

  C<$name> -- scalar $name        -- name of the extension
  C<$opts_ref> -- sahs_ref $opts_ref  -- ref to hash of options


=item See Also

L<install_extensions>,

=item Returns

1 if successful, undef/empty list if cancelled

=back


=item * C<TrEd::Extensions::get_extensions_dir()>

=over 6

=item Purpose

Return extensions directory from config

=item Parameters


=item Comments

Reads TrEd::Config::extensionsDir


=item Returns

Name of the extensions directory (as a string)

=back


=item * C<TrEd::Extensions::get_preinstalled_extensions_dir()>

=over 6

=item Purpose

Return configuration option -- directory where extensions are preinstalled

=item Parameters


=item Comments

Reads TrEd::Config::preinstalledExtensionsDir


=item Returns

Name of the directory where extensions are preinstalled (string)

=back


=item * C<TrEd::Extensions::get_extension_list($repository)>

=over 6

=item Purpose

Return list of extensions in repository/extensions directory

=item Parameters

  C<$repository> -- scalar $repository -- path to extensions repository

=item Comments

File extensions.lst is searched for in $repository (if it is set) or local extensions directory.
List of extensions listed in this file is returned.

=item See Also

L<Treex::PML::IO::make_URI()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/IO::make_URI.pm>,
L<File::Spec::catfile>,
L<Treex::PML::IO::open_uri(),|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/IO::open_uri.pm>,
Treex::PML::IO::close_uri()

=item Returns

Reference to array of extension names, empty array reference if repository does not
contain list of extensions. Undef/empty array if extensions directory does not exist
and no $repository is specified

=back


=item * C<TrEd::Extensions::init_extensions([$ext_list, $extension_dir])>

=over 6

=item Purpose

Add stylesheets, lib, macro and resources paths to TrEd paths
for each extension from extensions directory

=item Parameters

  C<$ext_list> -- array_ref $ext_list -- reference to list of extension names
  C<$extension_dir> -- scalar $extension_dir     -- name of the directory where extensions are stored

=item Comments

If $ext_list is not supplied, get_extension_list() function is used to get the list
of extensions. If $extension_dir is not supplied, get_extensions_dir() is used to find
the directory for extensions.

=item See Also

L<Treex::PML::Backend::PML::configure()|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Backend::PML::configure.pm>,
L<get_extensions_dir>,
L<get_extension_list>,

=item Returns

nothing

=back


=item * C<TrEd::Extensions::get_preinstalled_extension_list([$except, $preinstalled_ext_dir])>

=over 6

=item Purpose

Return list of extensions from pre-installed extensions directory,
except those listed in $except

=item Parameters

  C<$except> -- array_ref $except             -- reference to list of extensions to ignore
  C<$preinstalled_ext_dir> -- scalar $preinstalled_ext_dir  -- name of the directory with preinstalled extensions

=item Comments

If no parameters were supplied, $except is considered to be an empty list,
return value of get_preinstalled_extensions_dir() is used as $preinstalled_ext_dir

=item See Also

L<get_preinstalled_extensions_dir>,
L<get_extension_list>,

=item Returns

Reference to array containing extensions from pre-installed extensions directory

=back


=item * C<TrEd::Extensions::get_extension_subpaths($list_ref, $extension_dir, $rel_path)>

=over 6

=item Purpose

Take $list of extensions in $extension_dir directory and return list of
subdirectories specified by $rel_path

=item Parameters

  C<$list_ref> -- array_ref $list_ref   -- reference to array of extensions
  C<$extension_dir> -- scalar $extension_dir -- name of the directory containing extensions
  C<$rel_path> -- scalar $rel_path      -- subdirectory name

=item Comments

Ignores extensions that are commented out by ! at the beginning of line.
If no $list is supplied, get_extension_list() return value is used.
If $extension_dir is not supplied, get_extensions_dir() return value is used

=item See Also

L<get_extensions_dir>,
L<get_extension_list>,

=item Returns

List of subdirectories of the extensions in $extension_dir specified by $rel_path

=back


=item * C<TrEd::Extensions::get_extension_sample_data_paths($list_ref, $extension_dir)>

=over 6

=item Purpose

Find all the valid 'sample' subdirectories for all the extensions from
$list in $extension_dir directory

=item Parameters

  C<$list_ref> -- array_ref $list_ref   -- reference to array of extensions to work with
  C<$extension_dir> -- scalar $extension_dir -- name of the directory containing extensions


=item See Also

L<get_extension_subpaths>,

=item Returns

List of existing 'sample' subdirectories for specified extensions

=back


=item * C<TrEd::Extensions::get_extension_doc_paths($list_ref, $extension_dir)>

=over 6

=item Purpose

Find all the valid 'documentation' subdirectories for all the extensions from
$list in $extension_dir directory

=item Parameters

  C<$list_ref> -- array_ref $list_ref   -- reference to array of extensions to work with
  C<$extension_dir> -- scalar $extension_dir -- name of the directory containing extensions


=item See Also

L<get_extension_subpaths>,

=item Returns

List of existing 'documentation' subdirectories for specified extensions

=back


=item * C<TrEd::Extensions::get_extension_template_paths($list_ref, $extension_dir)>

=over 6

=item Purpose

Find all the valid 'templates' subdirectories for all the extensions from
$list in $extension_dir directory

=item Parameters

  C<$list_ref> -- array_ref $list_ref   -- reference to array of extensions to work with
  C<$extension_dir> -- scalar $extension_dir -- name of the directory containing extensions


=item See Also

L<get_extension_subpaths>,

=item Returns

List of existing 'templates' subdirectories for specified extensions

=back


=item * C<TrEd::Extensions::_contrib_macro_paths($directory)>

=over 6

=item Purpose

Find all directories and subdirectories of $directory that contains
'contrib.mac' file

=item Parameters

  C<$directory> -- scalar $directory -- name of the directory where the search starts


=item See Also

L<glob>,

=item Returns

List of paths to contrib.mac file in subdirectories of $directory

=back


=item * C<TrEd::Extensions::get_extension_macro_paths($list_ref, $extension_dir)>

=over 6

=item Purpose

Find all the paths with 'contrib.mac' file for all the extensions from
$list in $extension_dir directory

=item Parameters

  C<$list_ref> -- array_ref $list_ref   -- reference to array of extensions to work with
  C<$extension_dir> -- scalar $extension_dir -- name of the directory containing extensions


=item See Also

L<get_extension_subpaths>,

=item Returns

List of paths to 'contrib.mac' files for specified extensions

=back


=item * C<TrEd::Extensions::get_extension_meta_data($name, $extension_dir)>

=over 6

=item Purpose

Load package.xml metafile for extension $name and create
Treex::PML::Instance object from this metafile

=item Parameters

  C<$name> -- scalar or URI ref $name -- reference to URI object with extension name or the name itself
  C<$extension_dir> -- scalar $extension_dir   -- name of the directory containing extensions

=item Comments

If $extensions_dir is not supplied, result of get_extensions_dir() is used.

=item See Also

L<Treex::PML::Instance::load(),|http://search.cpan.org/~zaba/Treex-PML/lib/Treex/PML/Instance::load.pm>,

=item Returns

Root data structure returned by Treex::PML::Instance::get_root(),
undef if metafile is not a valid file

=back


=item * C<TrEd::Extensions::_inst_file($name)>

=over 6

=item Purpose

Find perl package by name

=item Parameters

  C<$name> -- scalar $name -- name of the perl package, e.g. Data::Dumper



=item Returns

Path to perl package, if it is found in @INC array, undef otherwise

=back


=item * C<TrEd::Extensions::get_module_version($module)>

=over 6

=item Purpose

Find out the version number for installed $module

=item Parameters

  C<$module> -- scalar $module -- name of perl module

=item Comments

requires CPAN, ExtUtils::MM

=item See Also

L<_inst_file>,

=item Returns

Undef if module is not present in @INC, version string
found by ExtUtils::MM::parse_version() otherwise

=back


=item * C<TrEd::Extensions::compare_module_versions($version_1, $version_2)>

=over 6

=item Purpose

Compare two version numbers

=item Parameters

  C<$version_1> -- scalar $version_1 -- first version string
  C<$version_2> -- scalar $version_2 -- second version string

=item Comments

requires CPAN

=item See Also

L<CPAN::Version->vcmp>,

=item Returns

1 if $version_1 is larger than $version_2,
-1 if $version_1 is smaller than $version_2,
0 if versions are equal,
undef if CPAN could not be loaded

=back


=item * C<TrEd::Extensions::_check_extensions_cmdline_opts($extension_name, $enabled_ref, $disabled_ref, $macro_file_cmdline)>

=over 6

=item Purpose

Tell whether the extension $extension_name is going to be enabled
or disabled according to command line options and extensions file

=item Parameters

  C<$extension_name> -- string $extension_name -- name of the extension
  C<$enabled_ref> -- hash_ref $enabled_ref -- ref to hash of explicitly enabled extensions
  C<$disabled_ref> -- hash_ref $disabled_ref -- ref to hash of explicitly disabled extensions
  C<$macro_file_cmdline> -- string $macro_file_cmdline -- the string from -m switch on command line

=item Comments

If any macro is specified on the command line, the extensions are
disabled by default. Specifying enabled extensions on command line
has however, higher priority.

=item See Also

L<prepare_extensions>,

=item Returns

The name of the extension with or without an exclamation mark
in the beginning (! means the extension is going to disabled)

=back


=item * C<TrEd::Extensions::prepare_extensions($macro_file_cmdline)>

=over 6

=item Purpose

Prepare all the installed extensions for use

=item Parameters

  C<$macro_file_cmdline> -- scalar $macro_file_cmdline -- command line argument -- macro file to read

=item Comments

Also reflects command-line arguments which can enable and disable
loading of extensions

=item See Also

L<init_extensions>,

=item Returns

Reference to array which contains two array references: first one
is a reference to array of installed extensions, second one is a ref
to array of preinstalled extensions

=back






=back


=head1 DIAGNOSTICS


Croaks in update_extensions_list sub
if extensions list file could not be found/opened/written into:
    "Configuring extension failed: cannot read/write/open/close extension list ..."


Croaks in _load_extension_file
if extensions list file could not be opened:
    "Installation failed: cannot read extension list

Croaks in install_extensions
if $urls_ref is not reference to array, if extension list file
could not be opened or if extension directory could not be created:
    "Usage: install_extensions(\@urls, \%opts)}"
    "Installation failed: cannot create/write/close extension directory $extension_dir: $!"

Croaks in uninstall_extension
if extension list could not be opened for reading or writing:
    "Uninstall failed: cannot read/close/write extension list $extension_list_file: $!"


Carps in _set_extension_icon
if the icon could not be loaded: the error message itself.

Carps in get_extension_list sub
if extension directory list (extensions.lst) could not be opened.

Carps in init_extensions sub
if the first argument is a reference, but not array reference:
    "Usage: init_extensions( [ extension_name(s)... ] )"


Carps in get_extension_subpaths sub
if $list is a reference, but not a ref to array:
    "Usage: get_extension_subpaths( [ extension_name(s)... ], extension_dir, rel_path )".

Carps in get_extension_meta_data sub
if Treex::PML::Instance::load() fails: the error message itself.


Carps in prepare_extensions sub
if required extension is missing:
    "WARNING: extension $required not found!"


=head1 CONFIGURATION AND ENVIRONMENT

Needs Treex::PML::ResourcePath to be set to a place where tred_extension_schema.xml is present.
Path to TrEd's custom Tk libs (Tk::DialogReturn, Tk::QueryDIalog) has to be present in @INC array.

=head1 DEPENDENCIES

TrEd modules:
TrEd::Version,
TrEd::MinMax,
Tk::DialogReturn,
Tk::ErrorReport,
Tk::QueryDialog,
Tk::BindButtons,

CPAN modules:
Archive::Zip,
L<Treex::PML|http://search.cpan.org/~zaba/Treex-PML/>,
URI,
URI::file,
CPAN,
Tk

Standard Perl modules:
Carp,
Exporter,
ExtUtils::MM,
File::Glob,
File::Path,
File::Spec,
Scalar::Util,

=head1 INCOMPATIBILITIES

No know incompatibilities.

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
