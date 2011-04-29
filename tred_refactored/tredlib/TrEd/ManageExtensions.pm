package TrEd::ManageExtensions;
# peterfabian1000@gmail.com          22 apr 2011

use 5.008;
use strict;
use warnings;
use TrEd::Extensions;

#use Carp;
#use File::Spec;
#use File::Glob qw(:glob);
#use Scalar::Util qw(blessed);

use URI;
use URI::file;

BEGIN {
  require Exporter;
  require Treex::PML;

  if (exists &Tk::MainLoop) {
    require Tk::DialogReturn;
    require Tk::BindButtons;
    require Tk::ProgressBar;
    require Tk::ErrorReport;
    require Tk::QueryDialog;
  }
  require TrEd::Version;

  use base qw(Exporter);
  our %EXPORT_TAGS = ( 'all' => [ qw(
				      manageExtensions
				   ) ] );
  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
  our @EXPORT = qw(  );
  our $VERSION = '0.01';
}

# just one of many dialog boxes...
#my $dialog_box;
my %required_by;
my %requires;
# populate_extension_pane opts..
#my $opts_ref;

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
  my $short_name = (blessed($pkg_name) and $pkg_name->isa('URI')) ?
         do { my $n = $pkg_name; 
              $n =~ s{.*/}{}; 
              return $n 
         } 
         : $pkg_name;
  return $short_name;
}

#######################################################################################
# Usage         : _repo_extensions_uri_list($opts_ref)
# Purpose       : Create list of triples: repository, extension name, extension URI
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
  foreach my $repo (map { Treex::PML::IO::make_URI($_) } @{$opts_ref->{repositories}}) {
    push @repo_extension_uri_list, 
    # create a triple: repository, short name of extension, URI of the extension
    map { [$repo, $_, URI->new($_)->abs($repo.'/')] } 
    # if we are only upgrading, then filter out all the extensions that are not installed
    grep { $opts_ref->{only_upgrades} ? exists($opts_ref->{installed}{$_}) : 1 } 
    # remove ! from the extension name if it is at the beginning of the name
    map { /^!(.*)/ ? $1 : $_ }  
    # take only those extensions that are defined and their name length is not 0
    grep { length and defined } 
    @{get_extension_list($repo)};
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
  my ($opts_ref) = @_;
  my $progress    = $opts_ref->{progress};
  my $progressbar = $opts_ref->{progressbar};
  
  if ($progress) {
    $$progress++;
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
# Parameters    : scalar $my_revision     -- first revision string (e.g. 1.256)
#                 scalar $other_revision  -- second revision string (e.g. 1.1024)
# Throws        : no exception
# Comments      : E.g. 1.1024 > 1.256, thus cmp_revisions("1.1024", "1.256") should return 1
sub cmp_revisions {
  my ($my_revision, $revision)=@_;
  my @my_revision = split(/\./, $my_revision);
  my @revision = split(/\./, $revision);
  my $cmp = 0;
  while ($cmp == 0 and (@my_revision or @revision)) {
    $cmp = (shift(@my_revision) <=> shift(@revision));
  }
  return $cmp;
}

#######################################################################################
# Usage         : _version_ok(..)
# Purpose       : Test whether the installed version of extension is between
#                 min and max required version (if specified)
# Returns       : True if the installed version is ok, false otherwise
# Parameters    : scalar $my_version            -- version of installed extension
#                 hash_ref $required_extension  -- reference to hash of info about required extension
# Throws        : no exception
# Comments      : Required extension hash should contain at least min_version and 
#                 max_version values
# See Also      : cmp_revisions()
sub _version_ok {
  my ($my_version, $required_extension) = @_;
  
  my $min_version = $required_extension->{min_version} || '';
  my $max_version = $required_extension->{max_version} || '';
  
  return (!$min_version || cmp_revisions($my_version, $min_version) >= 0) 
          && (!$max_version || cmp_revisions($my_version, $max_version) <= 0);
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
  my ($meta_data_ref, $installed_ver) = @_;
    
  if ($meta_data_ref) {
    return
    # not installed and exists in repository
    ((!$installed_ver && $meta_data_ref->{version}) 
    or 
    # installed, but version in repository is newer
    ($installed_ver and 
      $meta_data_ref->{version} and 
      cmp_revisions($installed_ver, $meta_data_ref->{version}) < 0));
  } 
  else {
    return 0;
  } 
}

#TODO: upravit pod_generator, aby vedel pracovat s named args...?
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
# Comments      : Needs Tk and uses its QuestionQuery function
sub _resolve_missing_dependency {
  my ($args_ref) = @_;
  
  my $req_data            = $args_ref->{req_data};
  my $required_extension  = $args_ref->{required_extension};
  my $short_name          = $args_ref->{short_name};
  my $repo                = $args_ref->{repo};
  my $dialog_box          = $args_ref->{dialog_box};
  
  my $req_name = $required_extension->{name};
  my $min = $required_extension->{min_version} || '';
  my $max = $required_extension->{max_version} || '';
  
  if ($req_data) {
    my $req_version = $req_data->{version};
    
    if (!_version_ok($req_version, $min, $max)) {
      return $dialog_box->parent->QuestionQuery(
                                      -title => 'Error',
                                      -label => "Package $short_name from $repo\nrequires package $req_name "
                                        ." in version $min..$max, but only $req_version is available",
                                      -buttons =>["Skip $short_name", 'Ignore versions', 'Cancel']
                                      );
    }
  }
  else { # no req_data
    return $dialog_box->parent->QuestionQuery(
                                  -title => 'Error',
                                  -label => "Package $short_name from $repo\nrequires package $req_name "
                                  ." which is not available",
                                  -buttons =>["Skip $short_name", 'Ignore dependencies', 'Cancel']
                                  );
  }
  return;
}
#TODO:!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#TODO: create package with extension pane?
# with its dialog box, opts, etc...
# then another package with manageExtension's dialog box and opts...
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
#                 (if they are not already there)
# Returns       : String 'Cancel' if user chooses to cancel installation, 
#                 'Skip' if user chooses to skip extension $uri, undef otherwise
# Parameters    : hash_ref $extension_data_ref    -- hash reference to extension's meta data
#                 array_ref $extensions_list_ref  -- reference to array containing list of extensions
#                 hash_ref $uri_in_repository_ref -- ref to hash of URIs in repositories
#                 scalar $uri                     -- URI of the extension whose requirements are searched for
#                 scalar $short_name              -- name of the extension whose requirements are searched for
#                 Tk::DialogBox $dialog_box       -- dialog box for creating GUI elements
#                 hash_ref $opts_ref              -- populate_extension_pane options
# Throws        : no exception
# Comments      : If any of the required extensions is missing, user is prompted with dialog 
#                 to choose whether TrEd should ignore the dependency, cancel the installation 
#                 or skip installation of the extension
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
  my $meta_data_ref = $extension_data_ref->{$uri} ||= TrEd::Extensions::getExtensionMetaData($uri);
  
  # find required packages and their versions
  $requires{$uri} = [];
  my %seen;
  # this can be a little tricky: if any of those three expressions is false, $require would be false/0
  # however, if all of them are true, last one is used as the value for $require
  my $require = $meta_data_ref && ref($meta_data_ref->{require}) && $meta_data_ref->{require};
  if (!exists($seen{$uri}) && $require) {
    $seen{$uri} = 1;
    for my $required_extension ($require->values('extension')) {
      for (grep { defined } ($required_extension->{name}, $required_extension->{href})) {
        Encode::_utf8_off($_);
      }
      my $req_name = $required_extension->{name};
      my $installed_req_ver = $opts_ref->{installed}{$req_name};
      
      next if ($installed_req_ver and _version_ok($installed_req_ver, $required_extension));
      
      # If we are here, required extension is not installed or it's not up-to-date
      my $repo = $meta_data_ref->{repository} && $meta_data_ref->{repository}{href};
      my $req_uri = ($repo && (!$required_extension->{href} || (URI->new('.')->abs($required_extension->{href}) eq $repo))) ?
          URI->new($req_name)->abs($uri) 
          : URI->new($required_extension->{href} || $req_name)->abs($uri);
      
      # get meta data about required extension from its xml file
      my $req_data = $extension_data_ref->{$req_uri} ||= TrEd::Extensions::getExtensionMetaData($req_uri);
      # what does the user want to do with missing dependency?
      my $res = _resolve_missing_dependency({
        req_data            => $req_data, 
        required_extension  => $required_extension, 
        short_name          => $short_name, 
        repo                => $repo,
        dialog_box          => $dialog_box,
      });
      
      return 'Cancel' if ($res eq 'Cancel');
      return 'Skip' if ($res =~ /^Skip/);
      
      # add URI of the required extension to $requires{$URI} array
      push @{$requires{$uri}}, $req_uri;
      # Add dependent extension to $extensions_list_ref, if URI of the required extension is not already listed 
      # in the list
      if (!exists $seen{$req_uri} && !exists $uri_in_repository_ref->{$req_uri}) {
        push @$extensions_list_ref, [URI->new('.')->abs($req_uri), $req_name, $req_uri];
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
  foreach my $dependency (@{$requires{$id}}) {
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
# Purpose       : Create list of URIs of extensions from $extensions_list_ref with their dependencies
# Returns       : Reference to array of URIs or undef/empty list if cancelled by user
# Parameters    : hash_ref $extension_data_ref   -- ref to hash of meta data about extensions
#                 hash_ref $opts_ref             -- ref to hash of populate_extension_pane options
#                 Tk::DialogBox $dialog_box      -- dialg box to create GUI elements
# Throws        : no exception
# Comments      : 
# See Also      : _update_progressbar(), _ext_not_installed_or_actual(), _add_required_exts(), _fill_required_by()
sub _uri_list_with_required_exts {
  my ($arg_ref) = @_;

  my $extension_data_ref = $arg_ref->{extension_data_ref};
  my $opts_ref           = $arg_ref->{opts_ref};
#  my $requires_ref        = $arg_ref->{requires_ref};
#  my $required_by_ref     = $arg_ref->{required_by_ref};
  my $dialog_box         = $arg_ref->{dialog_box};
  
  # for each repository find all the available extensions 
  # (if we are updating, only those that are installed already)
  my @list_of_extensions = _repo_extensions_uri_list($opts_ref);
  
  my $progressbar = $opts_ref->{progressbar};
  # set the progress bar
  if ($progressbar) {
    $progressbar->configure(
      -to => scalar(@list_of_extensions),
      -blocks => scalar(@list_of_extensions),
     );
  }
  
  my $i = 0;
  my %uri_in_repository; 
  @uri_in_repository{ map { $_->[2] } @list_of_extensions } = ();
  PKG:
  while ($i < @list_of_extensions) {
    my ($repo, $short_name, $uri) = @{$list_of_extensions[$i]};
    # read metadata from package.xml (or from cache)
    my $meta_data_ref = $extension_data_ref->{$uri} ||= TrEd::Extensions::getExtensionMetaData($uri);
    
    # if the extension is installed, find its version
    my $installed_ver = $opts_ref->{installed}{$short_name};
    $installed_ver ||= 0;
    
    if (exists $uri_in_repository{$uri}) {
      _update_progressbar($opts_ref);
    }
    
    # if extension is found in repository and it is not installed or there is a newer version in repository
    # increment excrement i
    if (_ext_not_installed_or_actual($meta_data_ref, $installed_ver)) {
      $i++;
    } 
    else {
      # remove the extensions from the list, if it is installed & up to date
      splice @list_of_extensions, $i, 1;
      # and go from the beginning to process another extension
      next PKG;
    }
    
    # add required extensions to @list_of_extensions and @$requires{$uri}
    my $res = _add_required_exts({
      extension_data_ref    => $extension_data_ref,
      extensions_list_ref   => \@list_of_extensions,
      uri_in_repository_ref => \%uri_in_repository,
      uri                   => $uri,
      short_name            => $short_name,
      dialog_box            => $dialog_box,
      opts_ref              => $opts_ref,
    });
    
    return if ($res eq 'Cancel');
    next PKG if ($res eq 'Skip');
    
    _fill_required_by($uri);
  }
  my $list_of_uris = [ map { $_->[2] } @list_of_extensions ];
  return $list_of_uris;
}

#######################################################################################
# Usage         : _uri_list_with_preinstalled_exts({
#                   pre_installed_ref   => $pre_installed_ref,
#                   enable_ref          => $enable_ref,
#                   opts_ref            => $opts_ref,
#                   extension_data_ref  => $extension_data_ref,
#                 });
# Purpose       : Create list of URIs of preinstalled extensions and 
#                 extensions from $extensions_list_ref
# Returns       : Reference to array of URIs
# Parameters    : hash_ref pre_installed_ref        -- ref to hash of pre-installed extensions
#                 hash_ref $enable_ref              -- ref to hash of enabled extensions
#                 hash_ref $opts_ref                -- ref to hash of populate_extension_pane options                 
#                 hash_ref $extension_data_ref      -- ref to hash of meta data about extensions                 
# Throws        : no exception
# Comments      : Also creates a hash of enabled extensions (those that are listed with exclamation 
#                 mark in the beginning are disabled). 
# See Also      : _update_progressbar(), _ext_not_installed_or_actual(), _add_required_exts(), _fill_required_by()
sub _uri_list_with_preinstalled_exts {
  my ($args_ref) = @_;
  
  my $pre_installed_ref       = $args_ref->{pre_installed_ref};
  my $enable_ref              = $args_ref->{enable_ref};
  my $opts_ref                = $args_ref->{opts_ref};
  my $extension_data_ref      = $args_ref->{extension_data_ref};
  
  my $uri_list_ref = TrEd::Extensions::getExtensionList();
  my $pre_installed_ext_list = TrEd::Extensions::getPreInstalledExtensionList($uri_list_ref);
  
  my $progressbar = $opts_ref->{progressbar};
  if ($progressbar) {
    $progressbar->configure(
      -to => scalar(@$uri_list_ref + @$pre_installed_ext_list),
      -blocks => scalar(@$uri_list_ref + @$pre_installed_ext_list),
     );
  }
  
  $pre_installed_ref->{ @$pre_installed_ext_list } = ();
  for my $name (@$uri_list_ref, @$pre_installed_ext_list) {
    # mark extensions with ! as not enabled
    $enable_ref->{$name} = 1;
    if ($name =~ s{^!}{}) {
      $enable_ref->{$name} = 0;
    }
    my $meta_data_ref = $extension_data_ref->{$name} = 
      TrEd::Extensions::getExtensionMetaData($name, exists($pre_installed_ref->{$name}) 
      ? TrEd::Extensions::getPreInstalledExtensionsDir() 
      : ());
    
    _update_progressbar($opts_ref);
    
    my $require = $meta_data_ref && ref($meta_data_ref->{require}) && $meta_data_ref->{require};
    if ($require) {
      $requires{$name} = $require ? [ map { $_->{name} } $require->values('extension') ] 
                                  : [];
    }
    
    _fill_required_by($name);
  }
  push(@$uri_list_ref, @$pre_installed_ext_list);
  return $uri_list_ref;
}

#######################################################################################
# Usage         : _create_uri_list({
#                   pre_installed_ref     => \%pre_installed,
#                   extension_data_ref    => \%extension_data,
#                   enable_ref            => \%enable,
#                   opts_ref              => $opts_ref,
#                   dialog_box            => $dialog_box,
#                 });
# Purpose       : Create list of URIs of extensions
# Returns       : Reference to list of extensions' URIs
# Parameters    : hash_ref $pre_installed_ref   -- ref to empty hash of preinstalled extensions (is filled by _uri_list_with_preinstalled_exts)
#                 hash_ref $extension_data_ref  -- ref to empty hash of extensions' data (is filled by this function)
#                 hash_ref $enable_ref          -- ref to empty hash of enabled & disabled extensions (is filled by this function)
#                 hash_ref $opts_ref            -- ref to hash of options
#                 Tk::DialogBox $dialog_box     -- dialg box to create GUI elements
# Throws        : no exception
# Comments      : 
# See Also      : _uri_list_with_preinstalled_exts(), _uri_list_with_required_exts()
sub _create_uri_list {
  my ($args_ref) = @_;
  
  my $pre_installed_ref   = $args_ref->{pre_installed_ref};
  my $extension_data_ref  = $args_ref->{extension_data_ref};
  my $enable_ref          = $args_ref->{enable_ref};
  my $opts_ref            = $args_ref->{opts_ref};
  my $dialog_box          = $args_ref->{dialog_box};
  
  my $uri_list_ref;
  
  if ($opts_ref->{install}) {
    $uri_list_ref = _uri_list_with_required_exts({
      extension_data_ref  => $extension_data_ref,
      opts_ref            => $opts_ref,
      dialog_box          => $dialog_box,
    });
  }
  else {
    $uri_list_ref = _uri_list_with_preinstalled_exts({
      pre_installed_ref  => $pre_installed_ref,
      enable_ref         => $enable_ref,
      opts_ref           => $opts_ref,
      extension_data_ref => $extension_data_ref,
    });
    
  }
  return $uri_list_ref;
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
  
  my $requires_different_tred = '';
  my @req_tred = $extension_data_ref && $extension_data_ref->{require} && $extension_data_ref->{require}->values('tred');
  foreach my $requirements (@req_tred) {
    if ($requirements->{min_version}) {
      if (TrEd::Version::CMP_TRED_VERSION_AND($requirements->{min_version}) < 0) {
        $requires_different_tred .= ' and ' if $requires_different_tred;
        $requires_different_tred = 'at least ' . $requirements->{min_version};
      }
    }
    if ($requirements->{max_version}) {
      if (TrEd::Version::CMP_TRED_VERSION_AND($requirements->{max_version}) > 0) {
        $requires_different_tred .= ' and ' if $requires_different_tred;
        $requires_different_tred = 'at most ' . $requirements->{max_version};
      }
    }
  }
  
  if (length $requires_different_tred) {
    $requires_different_tred = 'Requires TrEd '.$requires_different_tred.' (this is '.TrEd::Version::TRED_VERSION().')';
  }
  return $requires_different_tred;
}

#######################################################################################
# Usage         : _required_perl_modules($req_modules_ref)
# Purpose       : Test whether all the perl module dependencies of extension are satisfied
# Returns       : Empty string if all the dependencies are installed, error message otherwise
# Parameters    : array_ref $req_modules_ref -- ref to list of required perl modules
# Throws        : no exception
# See Also      : TrEd::Extensions::compare_module_versions(), TrEd::Extensions::get_module_version()
sub _required_perl_modules {
  my ($req_modules_ref) = @_;
  
  my $requires_modules = '';
  foreach my $requirements (@$req_modules_ref) {
    next if (!$requirements->{name} or (lc($requirements->{name}) eq 'perl'));
    my $req = '';
    my $available_version = eval { TrEd::Extensions::get_module_version($requirements->{name}) };
    next if $@;
    if (defined $available_version) {
      if ($requirements->{min_version}) {
        if (TrEd::Extensions::compare_module_versions($available_version, $requirements->{min_version}) < 0) {
          $req = 'at least ' . $requirements->{min_version};
        }
      }
      if ($requirements->{max_version}) {
        if (TrEd::Extensions::compare_module_versions($available_version, $requirements->{max_version}) > 0) {
          $req .= ' and ' if $req;
          $req = 'at most ' . $requirements->{max_version};
        }
      }
    }
    if (length $req or not(defined($available_version))) {
      $requires_modules .= "\n\t".$requirements->{name}." ".$req." ".
      (defined($available_version)  ? "(installed version: $available_version)" 
                                    : '(not installed)');
    }
  }
  if (length $requires_modules) {
    $requires_modules = 'Requires Perl Modules:'.$requires_modules;
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

  my $requires_perl = '';
  foreach my $requirements (grep { lc($_->{name}) eq 'perl' } @$req_modules_ref) {
    my $req='';
    if ($requirements->{min_version}) {
      if ($] < $requirements->{min_version}) {
        $req = 'at least ' . $requirements->{min_version};
      }
    }
    if ($requirements->{max_version}) {
      if ($] > $requirements->{max_version}) {
        $req .= ' and ' if $req;
        $req = 'at most ' . $requirements->{max_version};
      }
    }
    if (length $req) {
      $requires_perl = 'Requires Perl '.$req." (this is $])";
    }
  }
  return $requires_perl;
}

#######################################################################################
# Usage         : _find_all_requirements($uri_list, $extension_data_ref)
# Purpose       : Test all the requirements of extension from @$uri_list_ref
# Returns       : Reference to hash of extensions that can't be installed
# Parameters    : array_ref $uri_list_ref       -- ref to array of extensions' URIs
#                 hash_ref $extension_data_ref  -- ref to hash of extensions' meta data
# Throws        : no exception
# Comments      : 
# See Also      : _required_tred_version(), _required_perl_modules(), _required_perl_version()
sub _find_all_requirements {
  my ($uri_list_ref, $extension_data_ref) = @_;
  my %uninstallable;
  # for each extension
  for my $name (@$uri_list_ref) {
    my $data = $extension_data_ref->{$name};
    next if !((blessed($name) and $name->isa('URI')));
    
    # test tred requirements
    my $requires_different_tred=_required_tred_version($data);
    
    my @req_modules = $data && $data->{require} && $data->{require}->values('perl_module');
    # perl modules requirements
    my $requires_modules=_required_perl_modules(\@req_modules);
    
    # perl version requirements
    my $requires_perl=_required_perl_version(\@req_modules);
    
    my $all_requirements = join("\n", grep { defined($_) and length($_) } ($requires_different_tred, $requires_perl, $requires_modules));
    if (length $all_requirements) {
      $uninstallable{$name} = $all_requirements;
    }
  }
  return \%uninstallable;
}

#######################################################################################
# Usage         : _dependencies_of_req_exts(..)
# Purpose       : Test whether all the dependecies of extensions from @$uri_list_ref are satisfied
# Returns       : Undef/empty list 
# Parameters    : array_ref $uri_list_ref     -- ref to list of extensions' URIs
#                 hash_ref $uninstallable_ref -- ref to hash of extensions that can't be installed (due to unsatisfied dependencies)
# Throws        : no exception
# Comments      : Modifies $uninstallable_ref hash according to the uninstallability of 
#                 required extensions
# See Also      : 
sub _dependencies_of_req_exts {
  my ($uri_list_ref, $uninstallable_ref) = @_;
  
  # for each extension from URI list
  for my $name (@$uri_list_ref) {
    # if there is a dependency (TrEd version, Perl or Perl module) 
    # missing for the extension $name, go to next one 
    next if $uninstallable_ref->{$name};
    
    # create queue from required extensions
    my @queue = @{$requires{$name}};
    my %seen; 
    @seen{@queue}=();
    # search for unsatisfied dependencies among required extensions
    while (@queue) {
      my $required_ext = shift @queue;
      if ($uninstallable_ref->{$required_ext}) {
        # required extension requires different TrEd version, Perl version or some Perl modules,
        # -> mark dependent extension as uninstallable
        if ($uninstallable_ref->{$name}) {
          $uninstallable_ref->{$name} .= "\n";
        }
        $uninstallable_ref->{$name} .= 'Depends on uninstallable ' . short_name($required_ext);
      }
      # put requirements of required extension into queue to process them later 
      # (BFS - like, since we use push (to the end of array) & shift(from the beginning))
      my @more = grep { !exists($seen{$_}) } @{$requires{$required_ext}};
      @seen{@more} = ();
      push(@queue, @more);
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
#                 scalar/URI $name            -- name of the extension
#                 hash_ref $pre_installed_ref -- ref to hash containing meta data about preinstalled extensions
#                 Tk::ROText $text            -- ref to ROText on which the Labels/icons are created
#                 Tk::Photo $generic_icon     -- ref to Tk::Photo with generic extension icon
#                 hash_ref $opts_ref          -- ref to options hash
# Throws        : no exception
# Comments      : If extension's meta $data->{icon} is set, it is used. 
#                 Generic icon is used otherwise.
# See Also      : 
sub _set_extension_icon {
  my ($args_ref) = @_;
  
  my $data_ref          = $args_ref->{data};
  my $name              = $args_ref->{name};
  my $pre_installed_ref = $args_ref->{pre_installed_ref}; 
  my $text              = $args_ref->{text};
  my $generic_icon      = $args_ref->{generic_icon};
  my $opts_ref          = $args_ref->{opts_ref};
  
  my $extension_dir = $opts_ref->{extensions_dir} || TrEd::Extensions::getExtensionsDir();
  my $image;
  
  if ($data_ref && $data_ref->{icon}) {
    my ($path, $unlink, $format);
    # construct path of the image
    if ((blessed($name) and $name->isa('URI'))) {
      ($path, $unlink) = eval { Treex::PML::IO::fetch_file(URI->new($data_ref->{icon})->abs($name . '/')) };
    } 
    else {
      my $dir = exists($pre_installed_ref->{$name}) 
                ? TrEd::Extensions::get_preinstalled_extensions_dir() 
                : $extension_dir;
      $path = File::Spec->rel2abs($data_ref->{icon}, File::Spec->catdir($dir, $name));
    }
    { #DEBUG; 
      $path ||= '';
      # print STDERR "Extensions.pm: $name => $data->{icon}\n";
    }
    if (defined($path) and -f $path) {
      require Tk::JPEG;
      require Tk::PNG;
      my $result = eval {
        my $img = $text->Photo(
          -file   => $path,
          -format => $format,
          -width  => 0,
          -height => 0,
         );
        $image = $text->Label(-image => $img, -background => 'white');
      };
      carp($@) if ($@ || !defined($result));
      
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
      $image = $text->Label(-image => $generic_icon, -background => 'white');
    };
    carp($@) if ($@ || !defined($res));
  }
  return $image;
}

#######################################################################################
# Usage         : _set_name_desc_copyright({
#                   data_ref          => $data_ref,
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
  
  my $data_ref          = $args_ref->{data};
  my $name              = $args_ref->{name};
  my $pre_installed_ref = $args_ref->{pre_installed_ref};
  my $text              = $args_ref->{text};
  my $opts_ref          = $args_ref->{opts_ref};
    
  if ($data_ref) {
    $opts_ref->{versions}{$name} = $data_ref->{version};
    
    my $version = (defined($data_ref->{version}) && length($data_ref->{version}))  
                ? ' ' . $data_ref->{version} 
                : ''; 
                
    $text->insert('end', $data_ref->{title}, [qw(title)]);
    $text->insert('end', ' (' . short_name($name) . $version  . ')', [qw(name)]);
    $text->insert('end', "\n");
    my $require = $data_ref->{require};
#     $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
    my $desc = $data_ref->{description} || 'N/A';
    $desc =~ s/\s+/ /g;
    $desc =~ s/^\s+|\s+$//g;
    #'Description: ',[qw(label)],
    $text->insert('end', $desc, [qw(desc)], "\n");
    
    if (ref($data_ref->{copyright})) {
      my $c_year = $data_ref->{copyright}{year} ? ' (c) ' . $data_ref->{copyright}{year} : '';
      $text->insert('end', 'Copyright ' . $data_ref->{copyright}{'#content'} . $c_year, [qw(copyright)], "\n");
    }
  }
  else {
    $text->insert('end', 'Name: ', [qw(label)], $name, [qw(name)], "\n");
    $text->insert('end', 'Description: ', [qw(label)], 'N/A', [qw(desc)], "\n\n");
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
  my ($size)=@_;
  my $unit;
  foreach my $order (qw{B KiB MiB GiB}) {
    $unit = $order;
    if ($size < 1024) {
      last;
    } 
    else {
      $size = $size / 1024;
    }
  }
  return sprintf("%d %s", $size, $unit);
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
  my ($data_ref, $text, $name) = @_;
  if ($data_ref and ($data_ref->{install_size} or $data_ref->{package_size})) {
    $text->insert('end', '(Size: ');
    if ((blessed($name) and $name->isa('URI'))) {
      if ($data_ref->{package_size}) {
        $text->insert('end', _fmt_size($data_ref->{package_size}). ' package');
      }
      if ($data_ref->{package_size} && $data_ref->{install_size}) {
        $text->insert('end', ' / ');
      }
    }
    if ($data_ref->{install_size}) {
      $text->insert('end', _fmt_size($data_ref->{install_size}).' installed');
    }
    $text->insert('end', ") ");
  }
  return;
}

#######################################################################################
# Usage         : _required_by($name, $exists_ref, $required_by_ref)
# Purpose       : Find all the dependendents for $name listed in $required_by_ref
#                 hash; continue recusively for all dependendents which exist 
#                 in $exists_ref hash 
# Returns       : List of dependendents
# Parameters    : scalar $name              -- name of entity, whose dependecies are searched for
#                 hash_ref $exists_ref      -- reference to hash containing elements for which the recursion is allowed
#                 hash_ref $required_by_ref -- reference to hash of dependendents for each $name
# Throws        : no exception
# Comments      : 
# See Also      : _requires()
#TODO: test behaviour
sub _required_by {
  my ($name, $exists_ref, $required_by_ref)=@_;
  my %dependents_of;
  my @test_deps = ($name);
  while (@test_deps) {
    my $n = shift @test_deps;
    if (not exists $dependents_of{$n}) {
      push @test_deps, grep { exists($exists_ref->{$n}) } keys %{$required_by_ref->{$n}};
      $dependents_of{$n} = $n;
    }
  }
  return values(%dependents_of);
}

#######################################################################################
# Usage         : _requires($name, $exists_ref, $requires_ref)
# Purpose       : Find all the dependendencies for $name listed in $required_by_ref
#                 hash; continue recusively for all dependencies which exist 
#                 in $exists_ref hash
# Returns       : List of dependencies
# Parameters    : scalar $name            -- name of entity, whose dependecies are searched for
#                 hash_ref $exists_ref    -- reference to hash containing elements for which the recursion is allowed
#                 hash_ref $requires_ref  -- reference to hash of dependendencies for each $name
# Throws        : no exception
# Comments      : 
# See Also      : _required_by()
#TODO: test behaviour
sub _requires {
  my ($name, $exists_ref, $requires_ref) = @_;
  my %dependencies_of;
  my @deps = ($name);
  while (@deps) {
    my $n = shift @deps;
    if (not exists $dependencies_of{$n}) {
      if ($requires_ref->{$n}) {
        push @deps, grep { exists($exists_ref->{$_}) } @{$requires_ref->{$n}};
      }
      $dependencies_of{$n} = $n;
    }
  }
  return values(%dependencies_of);
}


#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub _anon_sub_1 {
  my ($enable_ref, $required_by, $name, $requires) = @_;
  # print "Enable: $enable->{$name}, $name, ",join(",",map { $_->{name} } @$requires),"\n";;
  if ($enable_ref->{$name}==1) {
    $required_by->{$name}{$name}=1;
  }
  else {
    delete $required_by->{$name}{$name};
    if (keys %{$required_by->{$name}}) {
      $enable_ref->{$name}=1; # do not allow
      return;
    }
  }
  my @req = _requires($name, $enable_ref, $requires);
  for my $href (@req) {
    next if ($href eq $name || !exists($enable_ref->{$href}));
    if ($enable_ref->{$name} == 1) {
      $enable_ref->{$href} = 1;
      $required_by->{$href}{$name} = 1;
    }
    elsif ($enable_ref->{$name} == 0) {
      delete $required_by->{$href}{$name};
      unless (keys(%{$required_by->{$href}})) {
        $enable_ref->{$href} = 0;
      }
    }
  }
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub _anon_sub_2 {
  my ($name, $opts, $required_by, $requires, $enable_ref) = @_;
  my (@enable, @disable);
  if ($enable_ref->{$name}) {
    @enable = _requires($name, $opts->{versions}, $requires);
  }
  else {
    @disable = _required_by($name, $opts->{versions}, $required_by);
    if ((grep { $enable_ref->{$_} } @disable)) {
      my $res = $dialog_box->QuestionQuery(
                -title => 'Disable related packages?',
                -label => "The following packages require '$name':\n\n".
                          join ("\n",grep { $_ ne $name } sort grep { $enable_ref->{$_} } @disable),
                -buttons =>['Ignore dependencies', 'Disable all', 'Cancel']
              );
      if ($res =~ /^Ignore/) {
        @disable = ($name);
      }
      elsif ($res =~ /^Cancel/) {
        $enable_ref->{$name} = $enable_ref->{$name} ? 0 : 1;
        return;
      }
    }
  }
  if (ref($opts->{reload_macros})) {
    ${$opts->{reload_macros}} = 1;
  }
  foreach my $disabled (@disable) {
    $enable_ref->{$disabled} = 0;
  }
  foreach my $enabled (@enable) {
    $enable_ref->{$enabled} = 1;
  }
  if (@disable) {
    setExtension(\@disable,0);
  }
  if (@enable) {
    setExtension(\@enable,1);
  }
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub _anon_sub_3 {
  my ($name, $required_by, $embeded_ref, $text)=@_;
  my @remove = _required_by($name,$opts_ref->{versions}, $required_by);
  my $quiet;
  if (@remove>1) {
    $quiet=1;
    my $res = $dialog_box->QuestionQuery(
      -title => 'Remove related packages?',
      -label => "The following packages require '$name':\n\n".
                 join ("\n",grep { $_ ne $name } sort @remove),
      -buttons =>['Ignore dependencies', 'Remove all', 'Cancel']
     );
    if ($res=~/^Ignore/) {
      @remove=($name);
    }
    elsif ($res =~ /^Cancel/) {
      return;
    }
  }
  $text->configure(-state=>'normal');
  foreach my $n (@remove) {
    if (uninstallExtension($n,{tk=>$dialog_box, quiet=>$quiet})) {
      delete $opts_ref->{versions}{$n};
    $text->DeleteTextTaggedWith($n);
      #for (@{$embeded->{$n}}) {
      #  eval { $_->destroy };
      #}
      delete $embeded_ref->{$n};
      if (ref( $opts_ref->{reload_macros})) {
        ${$opts_ref->{reload_macros}} = 1;
      }
    }
  }
  #$text->Subwidget('scrolled')->configure(-state=>'disabled');
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# text-> _anon_sub_4,$name,$bf,$image
sub _anon_sub_4 {
  my ($text, $name, $bf, $image)=@_;
  $bf->configure(-background=>'lightblue');
  $image->configure(-background=>'lightblue') if $image;
  $text->tagConfigure($name,-background=>'lightblue');
  $bf->focus;
  $bf->focusNext;
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# bf-> _anon_sub_5,$text,$name,$image
sub _anon_sub_5 {
  my ($bf, $text, $name, $image)=@_;
  $bf->configure(-background=>'lightblue');
  $image->configure(-background=>'lightblue') if $image;
  $text->tagConfigure($name,-background=>'lightblue');
  $bf->focus;
  $bf->focusNext;
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# image-> _anon_sub_6,$text,$name,$bf
sub _anon_sub_6 {
  my ($image, $text, $name, $bf)=@_;
  $bf->configure(-background=>'lightblue');
  $image->configure(-background=>'lightblue') if $image;
  $text->tagConfigure($name,-background=>'lightblue');
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# text-> _anon_sub_7,$name,$bf,$image
sub _anon_sub_7 {
  my ($text, $name, $bf, $image)=@_;
  $bf->configure(-background=>'white');
  $image->configure(-background=>'white') if $image;
  $text->tagConfigure($name,-background=>'white');
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# bf-> _anon_sub_8,$text,$name,$image
sub _anon_sub_8 {
  my ($bf, $text, $name, $image)=@_;
  $bf->configure(-background=>'white');
  $image->configure(-background=>'white') if $image;
  $text->tagConfigure($name,-background=>'white');
  return;
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
# $image-> _anon_sub_9,$text,$name,$bf
sub _anon_sub_9 {
  my ($image, $text, $name, $bf)=@_;
  $bf->configure(-background=>'white');
  $image->configure(-background=>'white') if $image;
  $text->tagConfigure($name,-background=>'white');
  return;
}

#######################################################################################
# Usage         : _create_checkbutton(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub _create_checkbutton {
  my ($args_ref) = @_;
  
  my $tred = $args_ref->{tred};
  my $name = $args_ref->{name};
  my $bf   = $args_ref->{bf};
  my $enable_ref = $args_ref->{enable_ref};
  my $text = $args_ref->{text};
  my $uninstallable_ref = $args_ref->{uninstallable_ref};
  my $embedded_ref = $args_ref->{embedded_ref};
  my $pre_installed_ref = $args_ref->{pre_installed_ref};
  my $opts_ref = $args_ref->{opts_ref};
  
  if ((blessed($name) and $name->isa('URI'))) {
    if ($uninstallable_ref->{$name}) {
      $bf->Label(-text=>$uninstallable_ref->{$name}, -anchor=>'nw', -justify=>'left')->pack(-fill=>'x');
    }
    else {
      $bf->Checkbutton(
                -text             => exists($opts_ref->{installed}{short_name($name)}) 
                                      ? 'Upgrade' 
                                      : 'Install',
                -compound         => 'left',
                -selectcolor      => undef,
                -indicatoron      => 0,
                -background       => 'white',
                -relief           => 'flat',
                -borderwidth      => 0,
                -height           => 18,
                -selectimage      => main::icon($tred, "checkbox_checked"),
                -image            => main::icon($tred, "checkbox"),
                -command          => [\&_anon_sub_1, $enable_ref, \%required_by, $name, \%requires],
                -variable         => \$enable_ref->{$name}
              )->pack(-fill=>'x');
    }
  } 
  else {
    if (exists $pre_installed_ref->{$name}) {
      $bf->Label(-text=>,"PRE-INSTALLED")->pack(-fill=>'both', -side=>'right', -padx => 5);
    }
    else {
      $bf->Checkbutton( -text         => 'Enable',
                        -compound     => 'left',
                        -selectcolor  => undef,
                        -indicatoron  => 0,
                        -background   => 'white',
                        -relief       => 'flat',
                        -borderwidth  => 0,
                        -height       => 18,
                        -selectimage  => main::icon($tred, "checkbox_checked"),
                        -image        => main::icon($tred, "checkbox"),
                        -command      => [\&_anon_sub_2, $name, $opts_ref, \%required_by, \%requires, $enable_ref],
                        -variable     => \$enable_ref->{$name}
                      )->pack(-fill=>'both',-side=>'left',-padx => 5);
      $bf->Button(-text     =>'Uninstall',
                  -compound =>'left',
                  -height   => 18,
                  -image    => main::icon($tred, 'remove'),
                  -command  => [\&_anon_sub_3, $name, \%required_by, $embedded_ref, $text],
	   )->pack( -fill => 'both',
                  -side => 'right',
                  -padx => 5);
    }
  }
  return;
}

#######################################################################################
# Usage         : _populate_extension_pane(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub _populate_extension_pane {
  my ($tred, $dialog_box, $opts_ref) = @_;
  
  my %enable;
  my %embeded;
  my %extension_data;
  my %pre_installed;
  

  # construct URI list with required/pre-installed extensions
  my $uri_list = _create_uri_list({
    pre_installed_ref     => \%pre_installed,
    extension_data_ref    => \%extension_data,
    enable_ref            => \%enable,
    opts_ref              => $opts_ref,
    dialog_box            => $dialog_box,
  });
  
  # find required TrEd version, Perl version and module requirements of all the extensions from URI list
  my $uninstallable_ref = _find_all_requirements($uri_list, \%extension_data);
  
  # test required extensions for unsatisfied(-able) dependencies, modify uninstallable_ref accordingly
  _dependencies_of_req_exts($uri_list, $uninstallable_ref);
  
  my $row = 0;
  my $text = $opts_ref->{pane} || $dialog_box->add('Scrolled' => 'ROText',
				      -scrollbars => 'oe',
				      -takefocus  => 0,
				      -relief     => 'flat',
				      -wrap       => 'word',
				      -width      => 70,
				      -height     => 20,
				      -background => 'white',
				     );
  $text->configure(-state => 'normal');
  $text->delete(qw(0.0 end));

  foreach my $name (@$uri_list) {
    my $data_ref = $extension_data{$name};
    my $start = $text->index('end');
    my $bf = $text->Frame(-background=>'white');
    
    my $generic_icon ||= main::icon($tred, 'extension');
    my $image = _set_extension_icon({
      data              => $data_ref,
      name              => $name,
      pre_installed_ref => \%pre_installed,
      text              => $text,
      generic_icon      => $generic_icon,
    });
    
    $text->insert('end', "\n");
    if ($image) {
      $text->windowCreate('end', -window => $image, -padx => 5)
    }
    
    _set_name_desc_copyright({
      data_ref          => $data_ref,
      pre_installed_ref => \%pre_installed,
      text              => $text,
      opts_ref          => $opts_ref,
    });
    
    my $end = $text->index('end');
    $end=~s/\..*//;
    $text->configure(-height=>$end);

    $embeded{$name} = [$bf, $image ? $image : ()];
    
    if ($opts_ref->{only_upgrades}) {
      $enable{$name} = 1;
    }
    
    _create_checkbutton();
    
    $text->insert('end',' ',[$bf]);
    
    _set_ext_size($data_ref, $text, $name);
    
    $text->windowCreate('end',-window => $bf,-padx=>5);
    $text->tagConfigure($bf,-justify=>'right');
#    $text->tagConfigure('preinst',-justify=>'right');
    $text->Insert("\n");
    $text->Insert("\n");
    $text->tagAdd($name, $start . ' - 1 line', 'end -1 char');
    
    # Any-Enter
    $text->tagBind($name,'<Any-Enter>' => [\&_anon_sub_4,$name,$bf,$image]);
    $bf->bind('<Any-Enter>' => [\&_anon_sub_5,$text,$name,$image]);
    if ($image) {
      $image->bind('<Any-Enter>' => [\&_anon_sub_6,$text,$name,$bf]);
    }
    
    # Any-Leave
    $text->tagBind($name,'<Any-Leave>' => [\&_anon_sub_7,$name,$bf,$image]);
    $bf->bind('<Any-Leave>' => [\&_anon_sub_8,$text,$name,$image]);
    if ($image) {
      $image->bind('<Any-Leave>' => [\&_anon_sub_9,$text,$name,$bf]);
    }
    # Mouse wheel
    for my $w ($bf, $bf->children) {
      $w->bind('<4>',         [$text,'yview','scroll',-1,'units']);
      $w->bind('<5>',         [$text,'yview','scroll',1,'units']);
      $w->Tk::bind('<MouseWheel>',
		   [ sub { $text->yview('scroll', -($_[1]/120)*3,'units') },
		     Tk::Ev("D")]);
    }


    $row++;
  }
  $text->tagConfigure('label', -foreground => 'darkblue', -font => 'C_bold');
  $text->tagConfigure('desc', -foreground => 'black', -font => 'C_default');
  $text->tagConfigure('name', -foreground => '#333', -font => 'C_default');
  $text->tagConfigure('title', -foreground => 'black', -font => 'C_bold');
  $text->tagConfigure('copyright', -foreground => '#666', -font => 'C_small');

  $text->configure(-height => 20);
  $text->pack(-expand => 1, -fill => 'both');
  #$text->Subwidget('scrolled')->configure(-state=>'disabled');
  unless ($opts_ref->{pane}) {
    $text->TextSearchLine(-parent   => $dialog_box,
                          -label    =>'S~earch',
                          -prev_img => main::icon($tred,'16x16/up'),
                          -next_img => main::icon($tred,'16x16/down'),
                         )->pack(qw(-fill x));
    $opts_ref->{pane} = $text;
  }
  $text->see('0.0');
  return \%enable;
}

sub _anon_sub_10 {
  my ($args_ref) = @_;
  
  my $upgrades = $args_ref->{upgrades};
  my $manage_ext_dialog = $args_ref->{manage_ext_dialog};
  my $tred = $args_ref->{tred};
  my $enable_ref = $args_ref->{enable_ref};
  my $INSTALL = $args_ref->{INSTALL};
  my $manage_ext_opts = $args_ref->{manage_ext_opts};
  my $opts_ref = $args_ref->{opts_ref};
  
  my $progress;
  my $progressbar = $manage_ext_dialog->add('ProgressBar',
		       -from=>0,
		       -to => 1,
		       -colors => [0,'darkblue'],
		       -width => 15,
		       -variable => \$progress)->pack(-expand =>1, -fill=>'x',-pady => 5);
  
  my $opts_to_pass = { install=>1,
			  top=>$manage_ext_dialog,
			  only_upgrades=>$upgrades,
			  progress=>\$progress,
			  progressbar=>$progressbar,
			  installed => $manage_ext_opts->{versions},
			  repositories => $manage_ext_opts->{repositories} };
			  
  if (manageExtensions($tred, $opts_to_pass) eq $INSTALL) {
    $enable_ref = _populate_extension_pane($tred, $manage_ext_dialog, $manage_ext_opts);
    if (ref($manage_ext_opts->{reload_macros})) {
      ${$opts_ref->{reload_macros}}=1;
    }
  }
  $progressbar->packForget;
  $progressbar->destroy;
  return;
}

#######################################################################################
# Usage         : manageExtensions(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub manageExtensions {
  my ($tred, $opts_ref)=@_;
  $opts_ref ||= {};
  
  my $mw = $opts_ref->{top} || $tred->{top} || return;
  my $UPGRADE = 'Check Updates';
  my $DOWNLOAD_NEW = 'Get New Extensions';
  my $REPOSITORIES = 'Edit Repositories';
  my $INSTALL = 'Install Selected';
  my $manage_ext_dialog = $mw->DialogBox(-title => $opts_ref->{install} ? 'Install New Extensions' : 'Manage Extensions',
			 -buttons => [ ($opts_ref->{install} ? $INSTALL : ($UPGRADE, $DOWNLOAD_NEW, $REPOSITORIES)),
				       'Close'
				      ]
			);
  $manage_ext_dialog->maxsize(0.9*$manage_ext_dialog->screenwidth,0.9*$manage_ext_dialog->screenheight);
  my $enable = _populate_extension_pane($tred,$manage_ext_dialog,$opts_ref);
  unless (ref $enable) {
    $manage_ext_dialog->destroy;
    return;
  }
  if ($opts_ref->{install}) {
    $manage_ext_dialog->Subwidget('B_'.$INSTALL)->configure(
      -command => sub {
	my @selected = grep { $enable->{$_} } keys %$enable;
	my $progress;
	if (@selected) {
	  $manage_ext_dialog->add('ProgressBar',
		  -from=>0,
		  -to => scalar(@selected),
		  -colors => [0,'darkblue'],
		  -blocks => scalar(@selected),
		  -width => 15,
		  -variable => \$progress)->pack(-expand =>1, -fill=>'x',-pady => 5);
	  $manage_ext_dialog->Busy(-recurse=>1);
	  eval {
	    installExtensions(\@selected,{
	      tk => $manage_ext_dialog,
	      progress=>\$progress,
	      quiet=>$opts_ref->{only_upgrades},
	    });
	  };
	}
	$manage_ext_dialog->ErrorReport(
	  -title   => "Installation error",
	  -message => "The following error occurred during package installation:",
	  -body    => "$@",
	  -buttons => [qw(OK)],
	 ) if $@;
	$manage_ext_dialog->Unbusy;
	$manage_ext_dialog->{selected_button}=$INSTALL;
      }
     );
  }
  elsif ($opts_ref->{repositories} and @{$opts_ref->{repositories}}) {
    for my $but ($DOWNLOAD_NEW,$UPGRADE) {
      my $upgrades = $but eq $UPGRADE ? 1 : 0;
      $manage_ext_dialog->Subwidget('B_'.$but)->configure(
      -command => [\&_anon_sub_10, $upgrades]
     );
    }
    $manage_ext_dialog->Subwidget('B_'.$REPOSITORIES)->configure(
              -command => sub { manageRepositories($manage_ext_dialog, $opts_ref->{repositories} ); }
     );

  }
  require Tk::DialogReturn;
  $manage_ext_dialog->BindEscape(undef,'Close');
  $manage_ext_dialog->BindButtons();
  return $manage_ext_dialog->Show();
}

sub _cond_1 {
  my ($url, $manage_repos_dialog, $listbox) = @_;
  my $ext_list = eval { 
    TrEd::Extensions::get_extension_list($url) 
  };
  
  return (
      (
        ref($ext_list) && !$@
        ||
        ($manage_repos_dialog->QuestionQuery( -title    =>'Repository error',
                                            -label    => 'No repository was found on a given URL!',
                                            -buttons  => ['Cancel', 'Add Anyway']
                                          ) =~ /Anyway/)
      )
      && !grep { $_ eq $url } $listbox->get(0,'end')
      );
}

#######################################################################################
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub manageRepositories {
  my ($top, $repos)=@_;
  my $manage_repos_dialog = $top->DialogBox(
    -title=> "Manage Extension Repositories",
    -buttons => [qw(Add Remove Save Cancel)]);

  my $manage_repos_listbox = $manage_repos_dialog->add('Listbox',
		  -width=>60,
		  -background=>'white',
		 )->pack(-fill=>'both',-expand => 1);
 $manage_repos_listbox->insert(0, @$repos);
  $manage_repos_dialog->Subwidget('B_Add')->configure(
    -command => sub {
      my $url = $manage_repos_dialog->StringQuery(
	-label => 'Repository URL:',
	-title => 'Add Repository',
	-default => ($manage_repos_listbox->get('anchor')||''),
	-select=>1,
      );
      if ($url) {
	if (_cond_1()) {
	  $manage_repos_listbox->insert('anchor',$url);
	}
      }
    }
   );
  $manage_repos_dialog->Subwidget('B_Remove')->configure(
    -command => sub {
      foreach my $element (grep $manage_repos_listbox->selectionIncludes($_), 0..$manage_repos_listbox->index('end')) {
        $manage_repos_listbox->delete($element);
      }
    }
   );
  $manage_repos_dialog->Subwidget('B_Save')->configure(
    -command => sub {
      @$repos = $manage_repos_listbox->get(0,'end');
      $manage_repos_dialog->{selected_button}='Save';
    }
   );
  return $manage_repos_dialog->Show;
}

#######################################################################################
# Usage         : setExtension(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub setExtension {
  my ($name,$enable,$extension_dir)=@_;
  my %names; @names{ (ref($name) eq 'ARRAY' ? @$name : $name) } = ();
  $extension_dir||=get_extensions_dir();
  my $extension_list_file =
    File::Spec->catfile($extension_dir,'extensions.lst');
  if (-f $extension_list_file) {
    open my $fh, '<', $extension_list_file ||
      die "Configuring extension failed: cannot read extension list $extension_list_file: $!";
    my @list = <$fh>;
    close $fh;
    open $fh, '>', $extension_list_file ||
      die "Configuring extenson failed: cannot write extension list $extension_list_file: $!";
    for (@list) {
      if (/^!?(\S+)\s*$/ and exists($names{$1})) {
	print $fh (($enable ? '' : '!').$1."\n");
      } else {
	print $fh ($_);
      }
    }
    close $fh;
  }
  return;
}


#######################################################################################
# Usage         : installExtensions(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
sub installExtensions {
  my ($urls,$opts)=@_;
  croak(q{Usage: installExtensions(\@urls,\%opts)}) unless ref($urls) eq 'ARRAY';
  return unless @$urls;
  $opts||={};
  my $extension_dir=$opts->{extensions_dir} || get_extensions_dir();
  unless (-d $extension_dir) {
    mkdir $extension_dir ||
      die "Installation failed: cannot create extension directory $extension_dir: $!";
  }
  my $extension_list_file =
    File::Spec->catfile($extension_dir,'extensions.lst');
  my @extension_file;
  if (-f $extension_list_file) {
    open my $fh, '<', $extension_list_file ||
      die "Installation failed: cannot read extension list $extension_list_file: $!";
    chomp( @extension_file = <$fh> );
    close $fh;
  } else {
    push @extension_file, split /\n\s*/, <<'EOF';
# DO NOT MODIFY THIS FILE
#
# This file only lists installed extensions.
# ! before extension name means the module is disabled
#
EOF
  }
  require Archive::Zip;
  for my $url (@$urls) {
    my $name = $url; $name=~s{.*/}{}g;
    Encode::_utf8_off($name);
    my $dir = File::Spec->catdir($extension_dir,$name);
    if (-d $dir) {
      next unless ($opts->{quiet} or
	$opts->{tk}->QuestionQuery(
	-title => 'Reinstall?',
	-label => "Extension $name is already installed in $dir.\nDo you want to upgrade/reinstall it?",
	-buttons =>['Install/Upgrade', 'All',  'Cancel']
       ) =~ /(Install|All)/);
      $opts->{quiet}=1 if !$opts->{quiet} and ($1 eq 'All');
      uninstallExtension($name); # or just rmtree
    }
    mkdir $dir;
    my ($zip_file,$unlink) = eval { Treex::PML::IO::fetch_file($url.'.zip') };
    if ($@) {
      my $err = "Downloading ${url}.zip failed:\n".$@;
      if ($opts->{tk}) {
	$opts->{tk}->ErrorReport(
	  -title   => "Installation error",
	  -message => "The following error occurred during package installation:",
	  -body    => $err,
	  -buttons => [qw(OK)],
	 ) if $@;
      } else {
	warn $err;
      }
      next;
    }
    my $zip = Archive::Zip->new();
    unless ($zip->read( $zip_file ) == Archive::Zip::AZ_OK()) {
      my $err = "Reading ${url}.zip failed!\n";
      if ($opts->{tk}) {
	$opts->{tk}->ErrorReport(
	  -title   => "Installation error",
	  -message => "The following error occurred during package installation:",
	  -body    => $err,
	  -buttons => [qw(OK)],
	 ) if $@;
      } else {
	warn $err;
      }
      next;
    }
    if ($zip->extractTree( '', $dir.'/' ) == Archive::Zip::AZ_OK()) {
      # try to restore executable bit
      if ($^O ne 'MSWin32') {
	for my $member ( $zip->members ) {
	  my $exe_perms = ($member->unixFileAttributes & 0111);
	  if ($exe_perms) {
	    my $fn = File::Spec->catfile($dir,URI::file->new($member->fileName)->file);
	    my $perms = ((stat $fn)[2] & 0777);
	    chmod(($perms | $exe_perms), $fn) if $perms;
	  }
	}
      }
    } else {
      my $err = "Extracting files from ${url}.zip failed!\n";
      if ($opts->{tk}) {
	$opts->{tk}->ErrorReport(
	  -title   => "Installation error",
	  -message => "The following error occurred during package installation:",
	  -body    => $err,
	  -buttons => [qw(OK)],
	 ) if $@;
      } else {
	warn $err;
      }
      next;
    }
    
    @extension_file = ((grep { !/^\!?\Q$name\E\s*$/ } @extension_file),$name);
    if (ref $opts->{progress}) {
      ${$opts->{progress}}++;
      $opts->{tk}->update if $opts->{tk};
    }
  }
  open my $fh, '>', $extension_list_file ||
    die "Installation failed: cannot write to extension list $extension_list_file: $!";
  print $fh ($_."\n") for @extension_file;
  close $fh;
}

#######################################################################################
# Usage         : uninstallExtension()
# Purpose       : ...
# Returns       : 
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : ...
# See Also      : ...
sub uninstallExtension {
  my ($name,$opts) = @_;
  require File::Path;
  return unless defined $name and length $name;
  $opts||={};
  my $extension_dir=$opts->{extensions_dir} || get_extensions_dir();
  my $dir = File::Spec->catdir($extension_dir,$name);
  if (-d $dir) {
    return if ($opts->{tk} and !$opts->{quiet} and
		 $opts->{tk}->QuestionQuery(
		   -title => 'Uninstall?',
		   -label => "Really uninstall extension $name ($dir)?",
		   -buttons =>['Uninstall', 'Cancel']
		  ) ne 'Uninstall');
    File::Path::rmtree($dir);
  }
  my $extension_list_file =
    File::Spec->catfile($extension_dir,'extensions.lst');
  if (-f $extension_list_file) {
    open my $fh, '<', $extension_list_file ||
      die "Uninstall failed: cannot read extension list $extension_list_file: $!";
    my @list = <$fh>;
    close $fh;
    open $fh, '>', $extension_list_file ||
      die "Uninstall failed: cannot write extension list $extension_list_file: $!";
    for (@list) {
      next if /^!?\Q$name\E\s*$/;
      print $fh ($_);
    }
    close $fh;
  }
  return 1;
}

1;

__END__

