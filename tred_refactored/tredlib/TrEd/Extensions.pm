package TrEd::Extensions;
# pajas@ufal.ms.mff.cuni.cz          02 rij 2008

use 5.008;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);
use Scalar::Util qw(blessed);

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
				      get_extensions_dir
				      init_extensions
				      get_extension_list
				      get_extension_macro_paths
				      manageExtensions
                      get_extension_sample_data_paths
                      get_extension_doc_paths
				      get_preinstalled_extensions_dir
				      get_preinstalled_extension_list
                      get_extension_template_paths
				      get_extension_subpaths
				   ) ] );
  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
  our @EXPORT = qw(  );
  our $VERSION = '0.01';
}

# Preloaded methods go here.

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
# Throws        : no exception
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
    $url = File::Spec->catfile(get_extensions_dir(), 'extensions.lst');
    return if (!( -f $url));
  }
  my $fh = eval { Treex::PML::IO::open_uri($url) };
  carp($@) if ($@);
  return [] if (!$fh);
  my $ext_filter = qr{
    ^
    !?
    [[:alnum:]_-]+
    \s*
    $
  }x;
  my @extensions = grep { /$ext_filter/ } <$fh>;
  for my $extension (@extensions) {
    $extension =~ s/\s+$//x;
  }
  Treex::PML::IO::close_uri($fh);
  return \@extensions;
}

#######################################################################################
# Usage         : init_extensions([$ext_list, $extension_dir])
# Purpose       : Add stylesheets, lib, macro and resources paths to TrEd paths
#                 for each extension from extensions directory
# Returns       : nothing
# Parameters    : array_ref $list $ext_list -- reference to list of extension names
#                 scalar $extension_dir     -- name of the directory where extensions are stored
# Throws        : carp if the first argument is a reference, but not array reference
# Comments      : If $ext_list is not supplied, get_extension_list() function is used to get the list 
#                 of extensions. If $extension_dir is not supplied, get_extensions_dir() is used to find
#                 the directory for extensions.
# See Also      : Treex::PML::Backend::PML::configure(), get_extensions_dir(), get_extension_list()
sub init_extensions {
  my ($list, $extension_dir) = @_;
  # check parameters
  if (@_ == 0) {
    $list = get_extension_list();
  } elsif (ref($list) ne 'ARRAY') {
    carp('Usage: init_extensions( [ extension_name(s)... ] )');
  }
  $extension_dir ||= get_extensions_dir();
  
  my (%m,%r,%i,%s);
  # stylesheet paths
  if (defined(@TrEd::Utils::stylesheet_paths)) {
    @s{ grep { defined($_) } @TrEd::Utils::stylesheet_paths } = ();
  }
  # resource paths
  @r{ Treex::PML::ResourcePaths() } = ();
  # macro include paths
  if (defined(@TrEd::Macros::macro_include_paths)) {
    @m{ grep { defined($_) } @TrEd::Macros::macro_include_paths } = ();
  }
  # perl include paths
  @i{ @INC } = ();
  
  # add each extension's resources, macros, stylesheets and libs to appropriate paths 
  # used by TrEd
  for my $name (grep { !/^!/ } @$list) {
    my $dir = File::Spec->catdir($extension_dir, $name, 'resources');
    if (-d $dir && !exists($r{$dir})) {
      Treex::PML::AddResourcePath($dir);
      $r{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir, $name);
    if (-d $dir && !exists($m{$dir})) {
      push @TrEd::Macros::macro_include_paths, $dir;
      $m{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir, $name, 'libs');
    if (-d $dir && !exists($i{$dir})) {
      push(@INC, $dir);
      $i{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir, $name, 'stylesheets');
    if (-d $dir && !exists($s{$dir})) {
      push(@TrEd::Utils::stylesheet_paths, $dir);
      $s{$dir}=1;
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
  my ($except, $preinst_dir) = @_;
  $except ||= [];
  $preinst_dir ||= get_preinstalled_extensions_dir();
  my $pre_installed_dir_exts = ((-d $preinst_dir) && get_extension_list($preinst_dir)) || [];
  # hash of extensions to return
  my %preinst;
  # remove those extensions that are commented out
  @preinst{ grep { !/^!/ } @$pre_installed_dir_exts } = ();
  # delete extensions that should be ignored / not listed
  delete @preinst{ map { /^!?(\S+)/ ? $1 : $_ } @$except };
  
  # filter only those extensions that exist in hash (i.e. those that are not commented out, 
  # nor ignored)
  @$pre_installed_dir_exts = grep { exists($preinst{$_}) } @$pre_installed_dir_exts;
  return $pre_installed_dir_exts;
}

#######################################################################################
# Usage         : get_extension_subpaths($list, $extension_dir, $rel_path)
# Purpose       : Take $list of extensions in $extension_dir directory and return list of 
#                 subdirectories specified by $rel_path
# Returns       : List of subdirectories of the extensions in $extension_dir specified by $rel_path
# Parameters    : array_ref $list       -- reference to array of extensions
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : carp if $list is a reference, but not a ref to array
# Comments      : Ignores extensions that are commented out by ! at the beginning of line. 
#                 If no $list is supplied, get_extension_list() return value is used. 
#                 If $extension_dir is not supplied, get_extensions_dir() return value is used
# See Also      : get_extensions_dir(), get_extension_list()
sub get_extension_subpaths {
  my ($list, $extension_dir, $rel_path) = @_;
  if (@_ == 0) {
    $list = get_extension_list();
  } 
  elsif (ref($list) ne 'ARRAY') {
    carp('Usage: get_extension_subpaths( [ extension_name(s)... ], extension_dir, rel_path )');
  }
  $extension_dir ||= get_extensions_dir();
  my @filtered_extensions_list = grep { !/^!/ } @$list;
  return map { File::Spec->catfile($extension_dir, $_, $rel_path) } @filtered_extensions_list;
}

#######################################################################################
# Usage         : get_extension_sample_data_paths($list, $extension_dir)
# Purpose       : Find all the valid 'sample' subdirectories for all the extensions from 
#                 $list in $extension_dir directory
# Returns       : List of existing 'sample' subdirectories for specified extensions
# Parameters    : array_ref $list       -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_sample_data_paths {
  my ($list, $extension_dir) = @_;
  return grep { -d $_ } get_extension_subpaths($list, $extension_dir, 'sample');
}

#######################################################################################
# Usage         : get_extension_doc_paths($list, $extension_dir)
# Purpose       : Find all the valid 'documentation' subdirectories for all the extensions from 
#                 $list in $extension_dir directory
# Returns       : List of existing 'documentation' subdirectories for specified extensions
# Parameters    : array_ref $list       -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_doc_paths {
  my ($list, $extension_dir) = @_;
  return grep { -d $_ } get_extension_subpaths($list, $extension_dir, 'documentation');
}

#######################################################################################
# Usage         : get_extension_template_paths($list, $extension_dir)
# Purpose       : Find all the valid 'templates' subdirectories for all the extensions from 
#                 $list in $extension_dir directory
# Returns       : List of existing 'templates' subdirectories for specified extensions
# Parameters    : array_ref $list       -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# See Also      : get_extension_subpaths()
sub get_extension_template_paths {
  my ($list, $extension_dir) = @_;
  return grep { -d $_ } get_extension_subpaths($list, $extension_dir, 'templates');
}

#######################################################################################
# Usage         : _contrib_macro_paths($direcotry)
# Purpose       : Find all directories and subdirectories of $directory that contains 
#                 'contrib.mac' file
# Returns       : List of paths to contrib.mac file in subdirectories of $directory
# Parameters    : scalar $directory -- name of the directory where the search starts
# Throws        : no exception
# See Also      : glob()
sub _contrib_macro_paths {
  my ($direcotry) = @_;
  return glob($direcotry . '/*/contrib.mac'), ( (-f $direcotry . '/contrib.mac') ? $direcotry . '/contrib.mac' : () );
}

#######################################################################################
# Usage         : get_extension_macro_paths($list, $extension_dir)
# Purpose       : Find all the paths with 'contrib.mac' file for all the extensions from 
#                 $list in $extension_dir directory
# Returns       : List of paths to 'contrib.mac' files for specified extensions
# Parameters    : array_ref $list       -- reference to array of extensions to work with
#                 scalar $extension_dir -- name of the directory containing extensions
# Throws        : no exception
# Comments      : 
# See Also      : get_extension_subpaths()
sub get_extension_macro_paths {
  my ($list, $extension_dir) = @_;
  my @contrib_subdirs = get_extension_subpaths($list, $extension_dir, 'contrib');
  return  map { _contrib_macro_paths($_) } @contrib_subdirs;
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
  my ($name, $extensions_dir)=@_;
  my $metafile;
  if ((blessed($name) and $name->isa('URI'))) {
    $metafile = URI->new('package.xml')->abs($name . '/');
  } 
  else {
    $metafile = File::Spec->catfile($extensions_dir || get_extensions_dir(), $name, 'package.xml');
    return if not -f $metafile;
  }
  my $data =  eval { 
    Treex::PML::Instance->load({ filename => $metafile, })->get_root();
  };
  carp($@) if $@;
  return $data;
}

#######################################################################################
# Usage         : _cmp_revisions($my_revision, $other_revision)
# Purpose       : Compare two revision numbers
# Returns       : -1 if $my_revision is numerically less than $other_revision, 
#                 0 if $my_revision is equal to $other_revision
#                 1 if $my_revision is greater than $other_revision
# Parameters    : scalar $my_revision     -- first revision string (e.g. 1.256)
#                 scalar $other_revision  -- second revision string (e.g. 1.1024)
# Throws        : no exception
# Comments      : E.g. 1.1024 > 1.256, thus _cmp_revisions("1.1024", "1.256") should return 1
sub _cmp_revisions {
  my ($my_revision,$revision)=@_;
  my @my_revision = split(/\./, $my_revision);
  my @revision = split(/\./, $revision);
  my $cmp = 0;
  while ($cmp == 0 and (@my_revision or @revision)) {
    $cmp = (shift(@my_revision) <=> shift(@revision));
  }
  return $cmp;
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

{
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
}

#######################################################################################
# Usage         : _inst_file($name)
# Purpose       : Find perl package by name
# Returns       : Path to perl package, if it is found in @INC array, undef otherwise
# Parameters    : scalar $name -- name of the perl package, e.g. Data::Dumper
# Throws        : no exception
# Comments      : 
sub _inst_file {
  my($name) = @_;
  my @packpath;
  @packpath = split /::/, $name;
  $packpath[-1] .= ".pm";
  foreach my $dir (@INC) {
    my $pmfile = File::Spec->catfile($dir, @packpath);
    if (-f $pmfile){
      return $pmfile;
    }
  }
  return;
}

#######################################################################################
# Usage         : _inst_version($module)
# Purpose       : Find out the version number for installed $module
# Returns       : Undef if module is not present in @INC, version string 
#                 found by ExtUtils::MM::parse_version() otherwise
# Parameters    : scalar $module -- name of perl module 
# Throws        : no exception
# Comments      : requires CPAN, ExtUtils::MM
# See Also      : _inst_file(), 
sub _inst_version {
  my($module) = @_;
  require CPAN;
  require ExtUtils::MM;
  my $parsefile = _inst_file($module) or return;
  # disable warnings for a while
  local($^W) = 0;
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
# Usage         : get_module_version($name)
# Purpose       : Find which version of module $name is installed
# Returns       : Version string of installed module
# Parameters    : scalar $name -- perl module name, e.g. Data::Dumper
# Throws        : no exception
# Comments      : 
# See Also      : _inst_version()
# TODO: naco je dobry takyto wrapper?
sub get_module_version {
  my ($name) = @_;
  return _inst_version($name);
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
  my ($v1,$v2)=@_;
  return undef if not eval { require CPAN; 1 };
  return CPAN::Version->vcmp($v1,$v2);
}

#######################################################################################
# Usage         : _short_name($pkg_name)
# Purpose       : Construct short name for package $pkg_name
# Returns       : Short name for $pkg_name
# Parameters    : scalar or blessed URI ref $pkg_name -- name of the package
# Throws        : no exception
# Comments      : If $pkg name is blessed URI reference, everything from the beginning
#                 of $pkg_name to last slash is removed and the rest is returned. 
#                 Otherwise $pkg_name is returned without any modification
sub _short_name {
  my ($pkg_name)=@_;
  my $short_name = (blessed($pkg_name) and $pkg_name->isa('URI')) ?
    do { my $n = $pkg_name; $n =~ s{.*/}{}; return $n } : $pkg_name;
}


sub _repo_extensions_uri_list {
  my ($opts_ref) = @_;
  my @repo_extension_uri_list;
  for my $repo (map { Treex::PML::IO::make_URI($_) } @{$opts_ref->{repositories}}) {
    push @repo_extension_uri_list, 
    map { [$repo, $_, URI->new($_)->abs($repo.'/')] } 
    grep { $opts_ref->{only_upgrades} ? exists($opts_ref->{installed}{$_}) : 1 } # if we are only upgrading, then filter out all the extensions that are not installed
    map { /^!(.*)/ ? $1 : $_ }  # remove ! from the extension name if it is at the beginning of the name
    grep { length and defined } # take only those extensions that are defined and their name length is not 0
    @{get_extension_list($repo)};
  }
  return @repo_extension_uri_list;
}

#######################################################################################
# Usage         : _populate_extension_pane($tred, $d, $opts)
# Purpose       : 
# Returns       : 
# Parameters    : ? $tred --
#                 ? $d    --
#                 ? $opts -- 
# Throws        : no exception
# Comments      : $opts->{progress}, 
#$opts->{progressbar}, 
#$opts-{repositories}, 
#$opts->{install}, 
#$opts->{installed}, 
#$opts->{only_upgrades}
# See Also      : 
sub _populate_extension_pane {
  my ($tred, $d, $opts_ref)=@_;
  my $list;
  my (%enable, %required_by, %embeded, %requires, %data, %pre_installed);
  my ($progress,$progressbar) = ($opts_ref->{progress}, $opts_ref->{progressbar});
  if ($opts_ref->{install}) {
    # for each repository find all the extensions (if we are updating, only those that are already installed)
    my @list_of_extensions = _repo_extensions_uri_list($opts_ref);
    if ($progressbar) {
      $progressbar->configure(
        -to => scalar(@list_of_extensions),
        -blocks => scalar(@list_of_extensions),
       );
    }
    my $i=0;
    my %in_def_repo; 
    @in_def_repo{ map { $_->[2] } @list_of_extensions} = ();
    my (%seen);
  PKG:
    while ($i < @list_of_extensions) {
      my ($repo, $short_name, $uri) = @{$list_of_extensions[$i]};

      my $data = $data{$uri} ||= get_extension_meta_data($uri);
      my $installed_ver = $opts_ref->{installed}{$short_name};
      $installed_ver ||= 0;
      if (exists $in_def_repo{$uri}) {
        $$progress++ if $progress;
        $progressbar->update() if $progressbar;
      }
      # since 'and' has higher priority than 'or', I assume, there is a missing bracket around (..) or (..),
      # but in this particular case it does not really matter, it works also without the brackets
      if ($data and
        
	    (!$installed_ver && $data->{version})
	    or ($installed_ver and $data->{version} and _cmp_revisions($installed_ver, $data->{version}) < 0) ) {
        $i++
      } 
      else {
        # remove the extensions from the list, if it is installed & up to date
        splice @list_of_extensions, $i, 1;
        next PKG;
      }
      $requires{$uri} = [];
      # this can be a little tricky: if any of those three expressions is false, $require would be false/0
      # however, if all of them are true, last one is used as the value for $require
      my $require = $data && ref($data->{require}) && $data->{require};
      if (!exists($seen{$uri}) and $require) {
        $seen{$uri} = 1;
        for my $req ($require->values('extension')) {
          for my $req_value (grep { defined($_) } ($req->{name}, $req->{href})) {
            Encode::_utf8_off($req_value);
          }
          my $req_name = $req->{name};
          my $installed_req_ver = $opts_ref->{installed}{$req_name};
          
          my $min = $req->{min_version} || '';
          my $max = $req->{max_version} || '';
          
          next if ($installed_req_ver
        	   and (!$min or _cmp_revisions($installed_req_ver, $min) >= 0)
        	   and (!$max or _cmp_revisions($installed_req_ver, $max) <= 0));
          # careful, reusing name 'repo'!!
          my $repo = $data->{repository} && $data->{repository}{href};
          my $req_uri = ($repo && (!$req->{href} || (URI->new('.')->abs($req->{href}) eq $repo))) ?
              URI->new($req_name)->abs($uri) : URI->new($req->{href} || $req_name)->abs($uri);
          my $req_data = $data{$req_uri} ||= get_extension_meta_data($req_uri);
          if ($req_data) {
            my $req_version = $req_data->{version};
            unless ((!$min or _cmp_revisions($req_version,$min)>=0)
        	  and (!$max or _cmp_revisions($req_version,$max)<=0)) {
              my $res = $d->parent->QuestionQuery(
        	-title => 'Error',
        	-label => "Package $short_name from $repo\nrequires package $req_name "
        	  ." in version $min..$max, but only $req_version is available",
        	-buttons =>["Skip $short_name", 'Ignore versions', 'Cancel']
               );
              return if $res eq 'Cancel';
              if ($res=~/^Skip/) {
        	next PKG;
              }
            }
          } else {
            my $res = $d->parent->QuestionQuery(
              -title => 'Error',
              -label => "Package $short_name from $repo\nrequires package $req_name "
        	." which is not available",
              -buttons =>["Skip $short_name", 'Ignore dependencies', 'Cancel']
             );
            return if $res eq 'Cancel';
            if ($res=~/^Skip/) {
              next PKG;
            }
          }
          push @{$requires{$uri}}, $req_uri;
          unless (exists $seen{$req_uri} or exists $in_def_repo{$req_uri}) {
            push @list_of_extensions,[URI->new('.')->abs($req_uri), $req_name, $req_uri];
          }
        }
      }
      $required_by{$_}{$uri}=1 for @{$requires{$uri}};
    }
    $list = [ map $_->[2], @list_of_extensions ];
  } 
  else {
    $list = get_extension_list();
    my $pre_installed = get_preinstalled_extension_list($list);
    if ($progressbar) {
      $progressbar->configure(
        -to => scalar(@$list+@$pre_installed),
        -blocks => scalar(@$list+@$pre_installed),
       );
    }
    @pre_installed{ @$pre_installed } = ();
    for my $name (@$list, @$pre_installed) {
      $enable{$name} = 1;
      if ($name=~s{^!}{}) {
	  $enable{$name} = 0;
	}
      my $data = $data{$name} = get_extension_meta_data($name, exists($pre_installed{$name}) ? get_preinstalled_extensions_dir() : ());
      $$progress++ if $progress;
      $progressbar->update if $progressbar;
      my $require = $data && ref($data->{require}) && $data->{require};
      if ($require) {
        $requires{$name} = $require ? [map { $_->{name} } $require->values('extension')] : [];
      }
      $required_by{$_}{$name}=1 for @{$requires{$name}};
    }
    push @$list, @$pre_installed;
  }
  my $extension_dir=$opts_ref->{extensions_dir} || get_extensions_dir();
  my $row=0;
  my $text = $opts_ref->{pane} || $d->add('Scrolled' => 'ROText',
                                           -scrollbars=>'oe',
                                           -takefocus=>0,
                                           -relief=>'flat',
                                           -wrap=>'word',
                                           -width=>70,
                                           -height=>20,
                                           -background => 'white',
                                          );
  $text->configure(-state=>'normal');
  $text->delete(qw(0.0 end));
  my $generic_icon;

  my %uninstallable;
  for my $name (@$list) {
    my $data = $data{$name};
    next unless ((blessed($name) and $name->isa('URI')));
    my @req_tred = $data && $data->{require} && $data->{require}->values('tred');
    my $requires_different_tred='';
    for my $r (@req_tred) {
      if ($r->{min_version}) {
	if (TrEd::Version::CMP_TRED_VERSION_AND($r->{min_version})<0) {
	  $requires_different_tred.=' and ' if $requires_different_tred;
	  $requires_different_tred='at least '.$r->{min_version};
	}
      }
      if ($r->{max_version}) {
	if (TrEd::Version::CMP_TRED_VERSION_AND($r->{max_version})>0) {
	  $requires_different_tred.=' and ' if $requires_different_tred;
	  $requires_different_tred='at most '.$r->{max_version};
	}
      }
    }
    if (length $requires_different_tred) {
      $requires_different_tred = 'Requires TrEd '.$requires_different_tred.' (this is '.TrEd::Version::TRED_VERSION().')'
    }
    my @req_module = $data && $data->{require} && $data->{require}->values('perl_module');
    my $requires_modules='';
    for my $r (@req_module) {
      next unless ($r->{name} and (lc($r->{name}) ne 'perl'));
      my $req = '';
      my $available_version = eval { get_module_version($r->{name}) };
      next if $@;
      if (defined $available_version) {
	if ($r->{min_version}) {
	  if (compare_module_versions($available_version,$r->{min_version})<0) {
	    $req='at least '.$r->{min_version};
	  }
	}
	if ($r->{max_version}) {
	  if (compare_module_versions($available_version,$r->{max_version})>0) {
	    $req.=' and ' if $req;
	    $req='at most '.$r->{max_version};
	  }
	}
      }
      if (length $req or not(defined($available_version))) {
	$requires_modules .= "\n\t".$r->{name}." ".$req." ".
	  (defined($available_version) ? "(installed version: $available_version)" : '(not installed)');
      }
    }
    if (length $requires_modules) {
      $requires_modules = 'Requires Perl Modules:'.$requires_modules;
    }
    my $requires_perl='';
    for my $r (grep { lc($_->{name}) eq 'perl' } @req_module) {
      my $req='';
      if ($r->{min_version}) {
	if ($]<$r->{min_version}) {
	  $req='at least '.$r->{min_version};
	}
      }
      if ($r->{max_version}) {
	if ($]>$r->{max_version}) {
	  $req.=' and ' if $req;
	  $req='at most '.$r->{max_version};
	}
      }
      if (length $req) {
	$requires_perl = 'Requires Perl '.$req." (this is $])";
      }
    }
    my $requires = join("\n",grep { defined($_) and length($_) } ($requires_different_tred,$requires_perl,$requires_modules));
    if (length $requires) {
      $uninstallable{$name}=$requires;
    }
  }
  for my $name (@$list) {
    next if $uninstallable{$name};
    my @queue = @{$requires{$name}};
    my %seen; @seen{@queue}=();
    while (@queue) {
      my $r = shift @queue;
      if ($uninstallable{$r}) {
	$uninstallable{$name}.="\n" if $uninstallable{$name};
	$uninstallable{$name}.='Depends on uninstallable '._short_name($r);
      }
      my @more = grep !exists($seen{$_}), @{$requires{$r}};
      @seen{@more}=();
      push @queue,@more;
    }
  }
  for my $name (@$list) {
    my $short_name = _short_name($name);
    my $data = $data{$name};
    my $start = $text->index('end');
    my $bf = $text->Frame(-background=>'white');
    my $image;
    if ($data) {
      $opts_ref->{versions}{$name}=$data->{version};
      if ($data->{icon}) {
	my ($path,$unlink,$format);
	if ((blessed($name) and $name->isa('URI'))) {
	  ($path,$unlink) = eval { Treex::PML::IO::fetch_file(URI->new($data->{icon})->abs($name.'/')) };
	} else {
	  my $dir = exists($pre_installed{ $name }) ? get_preinstalled_extensions_dir() : $extension_dir;
	  $path = File::Spec->rel2abs($data->{icon},
				      File::Spec->catdir($dir,$name)
				       );
	}
	{ #DEBUG; 
	  $path||='';
	  # print STDERR "Extensions.pm: $name => $data->{icon}\n";
	}
	if (defined($path) and -f $path) {
	  require Tk::JPEG;
	  require Tk::PNG;
	  eval {
	    my $img = $text->Photo(
	      -file => $path,
	      -format => $format,
	      -width=>0,
	      -height=>0,
	     );
	    $image = $text->Label(-image=> $img,-background=>'white');
	  };
	  warn $@ if $@;
	  unlink $path if $unlink;
	}
      } else {
	require Tk::JPEG;
	require Tk::PNG;
	eval {
	  $generic_icon ||= main::icon($tred,'extension');
	  $image = $text->Label(-image=> $generic_icon,-background=>'white');
	};
	warn $@ if $@;
      }
      $text->insert('end',"\n");
      if ($image) {
	$text->windowCreate('end',-window => $image,-padx=>5)
      }
      $text->insert('end',$data->{title},[qw(title)]);
      $text->insert('end',' ('.$short_name.(defined($data->{version}) && length($data->{version})
			  ? ' '.$data->{version} : ''
			 ).')',[qw(name)]);
      $text->insert('end',"\n");
      my $require = $data->{require};
#      $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
      my $desc = $data->{description} || 'N/A';
      $desc=~s/\s+/ /g;
      $desc=~s/^\s+|\s+$//g;
      $text->insert('end',#'Description: ',[qw(label)],
		    $desc,[qw(desc)],"\n");
      $text->insert('end','Copyright '.
		    ( $data->{copyright}{'#content'}
			.($data->{copyright}{year} ? ' (c) '.$data->{copyright}{year} : '')
		    ),[qw(copyright)],"\n") if ref $data->{copyright};
    } else {
      $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
      $text->insert('end','Description: ',[qw(label)],'N/A',[qw(desc)],"\n\n");
    }
    my $end = $text->index('end');
    $end=~s/\..*//;
    $text->configure(-height=>$end);

    $embeded{$name}=[$bf,$image ? $image : ()];
    $enable{$name}=1 if $opts_ref->{only_upgrades};
    if ((blessed($name) and $name->isa('URI'))) {
      if ($uninstallable{$name}) {
	$bf->Label(-text=>$uninstallable{$name}, -anchor=>'nw', -justify=>'left')->pack(-fill=>'x');
      } else {
	$bf->Checkbutton(-text=> exists($opts_ref->{installed}{$short_name})
			   ? 'Upgrade' : 'Install',
			 -compound=>'left',
			 -selectcolor=>undef,
			 -indicatoron => 0,
			 -background=>'white',
			 -relief => 'flat',
			 -borderwidth => 0,
			 #		       -padx => 5,
			 #		       -pady => 5,
			 -height => 18,
			 -selectimage => main::icon($tred,"checkbox_checked"),
			 -image => main::icon($tred,"checkbox"),
			 -command => [sub {
				      my ($enable,$required_by,$name,$requires)=@_;
				      # print "Enable: $enable->{$name}, $name, ",join(",",map { $_->{name} } @$requires),"\n";;
				      if ($enable->{$name}==1) {
					$required_by->{$name}{$name}=1;
				      } else {
					delete $required_by->{$name}{$name};
					if (keys %{$required_by->{$name}}) {
					  $enable->{$name}=1; # do not allow
					  return;
					}
				      }
				      my @req = _requires($name, $enable, $requires);
				      for my $href (@req) {
#					my $href = $req->{href};
#					my $req_name = $req->{name};
#					next if $req_name eq $name;
#					unless (exists($enable->{$href})) {
#					  ($href) = grep { m{/\Q$req_name\E$}  } keys %$enable;
#					}
					next if $href eq $name or !exists($enable->{$href});
					if ($enable->{$name}==1) {
					  $enable->{$href}=1;
					  $required_by->{$href}{$name}=1;
					} elsif ($enable->{$name}==0) {
					  delete $required_by->{$href}{$name};
					  unless (keys(%{$required_by->{$href}})) {
					    $enable->{$href}=0;
					  }
					}
				      }
				    },\%enable,\%required_by,$name,\%requires],
			 -variable=>\$enable{$name}
			)->pack(-fill=>'x')
      }
    } else {
      if (exists $pre_installed{$name}) {
	$bf->Label(-text=>,"PRE-INSTALLED")->pack(-fill=>'both', -side=>'right', -padx => 5);
      } else {
      $bf->Checkbutton(-text=>'Enable',
		       -compound=>'left',
		       -selectcolor=>undef,
		       -indicatoron => 0,
		       -background=>'white',
		       -relief => 'flat',
		       -borderwidth => 0,
#		       -padx => 2,
#		       -pady => 2,
		       -height => 18,
		       -selectimage => main::icon($tred,"checkbox_checked"),
		       -image => main::icon($tred,"checkbox"),
		       -command => [sub {
				      my ($name,$opts_ref,$required_by,$requires)=@_;
				      my (@enable,@disable);
				      if ($enable{$name}) {
					@enable=_requires($name,$opts_ref->{versions},$requires);
				      } else {
					@disable=_required_by($name,$opts_ref->{versions},$required_by);
					if ((grep $enable{$_}, @disable)) {
					  my $res = $d->QuestionQuery(
					    -title => 'Disable related packages?',
					    -label => "The following packages require '$name':\n\n".
					      join ("\n",grep { $_ ne $name } sort grep $enable{$_}, @disable),
					    -buttons =>['Ignore dependencies', 'Disable all', 'Cancel']
					   );
					  if ($res=~/^Ignore/) {
					    @disable=($name);
					  } elsif ($res =~ /^Cancel/) {
					    $enable{$name}=$enable{$name} ? 0 : 1;
					    return;
					  }
					}
				      }
				      ${$opts_ref->{reload_macros}}=1 if ref $opts_ref->{reload_macros};
				      $enable{$_}=0 for @disable;
				      $enable{$_}=1 for @enable;
				      setExtension(\@disable,0) if (@disable);
				      setExtension(\@enable,1) if (@enable)
				    },$name,$opts_ref,\%required_by,\%requires],
		       -variable=>\$enable{$name})->pack(-fill=>'both',-side=>'left',-padx => 5);
	$bf->Button(-text=>'Uninstall',
		    -compound=>'left',
		    -height => 18,
		    -image => main::icon($tred,'remove'),
		    -command => [sub {
				   my ($name,$required_by,$opts_ref,$d,$embeded)=@_;
				   my @remove=_required_by($name,$opts_ref->{versions},$required_by);
				   my $quiet;
				   if (@remove>1) {
				     $quiet=1;
				     my $res = $d->QuestionQuery(
				       -title => 'Remove related packages?',
				       -label => "The following packages require '$name':\n\n".
					 join ("\n",grep { $_ ne $name } sort @remove),
				       -buttons =>['Ignore dependencies', 'Remove all', 'Cancel']
				      );
				     if ($res=~/^Ignore/) {
				       @remove=($name);
				     } elsif ($res =~ /^Cancel/) {
				       return;
				     }
				   }
				   $text->configure(-state=>'normal');
				   for my $n (@remove) {
				     if (uninstallExtension($n,{tk=>$d, quiet=>$quiet})) {
				       delete $opts_ref->{versions}{$n};
				     $text->DeleteTextTaggedWith($n);
				       #for (@{$embeded->{$n}}) {
				       #  eval { $_->destroy };
				       #}
				       delete $embeded->{$n};
				       ${$opts_ref->{reload_macros}}=1 if ref( $opts_ref->{reload_macros} );
				     }
				   }
				   #$text->Subwidget('scrolled')->configure(-state=>'disabled');
				 },$name,\%required_by,$opts_ref,$d], #,\%embeded
		   )->pack(-fill=>'both',
			   -side=>'right',
			   -padx => 5);
      }
    }
    $text->insert('end',' ',[$bf]);
    {
      if ($data and ($data->{install_size} or $data->{package_size})) {
	$text->insert('end', '(Size: ');
	if ((blessed($name) and $name->isa('URI'))) {
	  $text->insert('end', _fmt_size($data->{package_size}). ' package') if $data->{package_size};
	  $text->insert('end', ' / ') if $data->{package_size} && $data->{install_size};
	}
	$text->insert('end', _fmt_size($data->{install_size}).' installed') if $data->{install_size};
	$text->insert('end', ") ");
    }
    }
    $text->windowCreate('end',-window => $bf,-padx=>5);
    $text->tagConfigure($bf,-justify=>'right');
#    $text->tagConfigure('preinst',-justify=>'right');
    $text->Insert("\n");
    $text->Insert("\n");
    $text->tagAdd($name,$start.' - 1 line','end -1 char');

    $text->tagBind($name,'<Any-Enter>' => [sub {
					     my ($text,$name,$bf,$image)=@_;
					     $bf->configure(-background=>'lightblue');
					     $image->configure(-background=>'lightblue') if $image;
					     $text->tagConfigure($name,-background=>'lightblue');
					     $bf->focus;
					     $bf->focusNext;
					   },$name,$bf,$image]);
    $bf->bind('<Any-Enter>' => [sub {
			      my ($bf,$text,$name,$image)=@_;
			      $bf->configure(-background=>'lightblue');
			      $image->configure(-background=>'lightblue') if $image;
			      $text->tagConfigure($name,-background=>'lightblue');
			      $bf->focus;
			      $bf->focusNext;
			    },$text,$name,$image]);
    $image->bind('<Any-Enter>' => [sub {
			      my ($image,$text,$name,$bf)=@_;
			      $bf->configure(-background=>'lightblue');
			      $image->configure(-background=>'lightblue') if $image;
			      $text->tagConfigure($name,-background=>'lightblue');
			    },$text,$name,$bf])
      if $image;
    $text->tagBind($name,'<Any-Leave>' => [sub {
					     my ($text,$name,$bf,$image)=@_;
					     $bf->configure(-background=>'white');
					     $image->configure(-background=>'white') if $image;
					     $text->tagConfigure($name,-background=>'white');
					   },$name,$bf,$image]);
    $bf->bind('<Any-Leave>' => [sub {
			      my ($bf,$text,$name)=@_;
			      $bf->configure(-background=>'white');
			      $image->configure(-background=>'white') if $image;
			      $text->tagConfigure($name,-background=>'white');
			    },$text,$name,$image]);
    $image->bind('<Any-Leave>' => [sub {
			      my ($image,$text,$name,$bf)=@_;
			      $bf->configure(-background=>'white');
			      $image->configure(-background=>'white') if $image;
			      $text->tagConfigure($name,-background=>'white');
			    },$text,$name,$bf]) if $image;
    for my $w ($bf,$bf->children) {
      $w->bind('<4>',         [$text,'yview','scroll',-1,'units']);
      $w->bind('<5>',         [$text,'yview','scroll',1,'units']);
      $w->Tk::bind('<MouseWheel>',
		   [ sub { $text->yview('scroll',-($_[1]/120)*3,'units') },
		     Tk::Ev("D")]);
    }


    $row++;
  }
  $text->tagConfigure('label', -foreground => 'darkblue', -font => 'C_bold');
  $text->tagConfigure('desc', -foreground => 'black', -font => 'C_default');
  $text->tagConfigure('name', -foreground => '#333', -font => 'C_default');
  $text->tagConfigure('title', -foreground => 'black', -font => 'C_bold');
  $text->tagConfigure('copyright', -foreground => '#666', -font => 'C_small');

  $text->configure(-height=>20);
  $text->pack(-expand=>1,-fill=>'both');
  #$text->Subwidget('scrolled')->configure(-state=>'disabled');
  unless ($opts_ref->{pane}) {
    $text->TextSearchLine(-parent => $d,
			  -label=>'S~earch',
			  -prev_img =>main::icon($tred,'16x16/up'),
			  -next_img =>main::icon($tred,'16x16/down'),
			 )->pack(qw(-fill x));
    $opts_ref->{pane}=$text;
  }
  $text->see('0.0');
  return \%enable;
}

#######################################################################################
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
#TODO: na zaver
sub manageExtensions {
  my ($tred,$opts)=@_;
  $opts||={};
  my $mw = $opts->{top} || $tred->{top} || return;
  my $UPGRADE = 'Check Updates';
  my $DOWNLOAD_NEW = 'Get New Extensions';
  my $REPOSITORIES = 'Edit Repositories';
  my $INSTALL = 'Install Selected';
  my $d = $mw->DialogBox(-title => $opts->{install} ? 'Install New Extensions' : 'Manage Extensions',
			 -buttons => [ ($opts->{install} ? $INSTALL : ($UPGRADE, $DOWNLOAD_NEW, $REPOSITORIES)),
				       'Close'
				      ]
			);
  $d->maxsize(0.9*$d->screenwidth,0.9*$d->screenheight);
  my $enable = _populate_extension_pane($tred,$d,$opts);
  unless (ref $enable) {
    $d->destroy;
    return;
  }
  if ($opts->{install}) {
    $d->Subwidget('B_'.$INSTALL)->configure(
      -command => sub {
	my @selected = grep $enable->{$_}, keys %$enable;
	my $progress;
	if (@selected) {
	  $d->add('ProgressBar',
		  -from=>0,
		  -to => scalar(@selected),
		  -colors => [0,'darkblue'],
		  -blocks => scalar(@selected),
		  -width => 15,
		  -variable => \$progress)->pack(-expand =>1, -fill=>'x',-pady => 5);
	  $d->Busy(-recurse=>1);
	  eval {
	    installExtensions(\@selected,{
	      tk => $d,
	      progress=>\$progress,
	      quiet=>$opts->{only_upgrades},
	    });
	  };
	}
	$d->ErrorReport(
	  -title   => "Installation error",
	  -message => "The following error occurred during package installation:",
	  -body    => "$@",
	  -buttons => [qw(OK)],
	 ) if $@;
	$d->Unbusy;
	$d->{selected_button}=$INSTALL;
      }
     );
  } elsif ($opts->{repositories} and @{$opts->{repositories}}) {
    for my $but ($DOWNLOAD_NEW,$UPGRADE) {
      my $upgrades = $but eq $UPGRADE ? 1 : 0;
      $d->Subwidget('B_'.$but)->configure(
      -command => [sub {
		     my ($upgrades)=@_;
		     my $progress;
		     my $progressbar = $d->add('ProgressBar',
					       -from=>0,
					       -to => 1,
					       -colors => [0,'darkblue'],
					       -width => 15,
					       -variable => \$progress)->pack(-expand =>1, -fill=>'x',-pady => 5);
		     if (manageExtensions($tred,{ install=>1,
						  top=>$d,
						  only_upgrades=>$upgrades,
						  progress=>\$progress,
						  progressbar=>$progressbar,
						  installed => $opts->{versions},
						  repositories => $opts->{repositories} }) eq $INSTALL) {
		       $enable = _populate_extension_pane($tred,$d,$opts);
		       if (ref($opts->{reload_macros})) {
			 ${$opts->{reload_macros}}=1;
		       }
		     }
		     $progressbar->packForget;
		     $progressbar->destroy;
		   },$upgrades]
     );
    }
    $d->Subwidget('B_'.$REPOSITORIES)->configure(
      -command => sub {	manageRepositories($d, $opts->{repositories} ); }
     );

  }
  require Tk::DialogReturn;
  $d->BindEscape(undef,'Close');
  $d->BindButtons();
  return $d->Show();
}

#######################################################################################
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
sub manageRepositories {
  my ($top, $repos)=@_;
  my $d = $top->DialogBox(
    -title=> "Manage Extension Repositories",
    -buttons => [qw(Add Remove Save Cancel)]);

  my $l = $d->add('Listbox',
		  -width=>60,
		  -background=>'white',
		 )->pack(-fill=>'both',-expand => 1);
 $l->insert(0, @$repos);
  $d->Subwidget('B_Add')->configure(
    -command => sub {
      my $url = $d->StringQuery(
	-label => 'Repository URL:',
	-title => 'Add Repository',
	-default => ($l->get('anchor')||''),
	-select=>1,
      );
      if ($url) {
	if ((ref(eval{ get_extension_list($url) }) and !$@
	     or
	     ($d->QuestionQuery(-title=>'Repository error',
				-label => 'No repository was found on a given URL!',
				-buttons => ['Cancel', 'Add Anyway']
			       ) =~ /Anyway/))
	    and !grep($_ eq $url, $l->get(0,'end'))) {
	  $l->insert('anchor',$url);
	}
      }
    }
   );
  $d->Subwidget('B_Remove')->configure(
    -command => sub {
      $l->delete($_) for grep $l->selectionIncludes($_), 0..$l->index('end')
    }
   );
  $d->Subwidget('B_Save')->configure(
    -command => sub {
      @$repos = $l->get(0,'end');
      $d->{selected_button}='Save';
    }
   );
  return $d->Show;
}

#######################################################################################
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
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
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
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
}

#######################################################################################
# Usage         : newNode($win_ref)
# Purpose       : Create new node as a new child of current node
# Returns       : Undef if $win_ref->{FSFile} or $win_ref->{currentNode} are not defined, 
#                 reference to new Treex::PML::Node object otherwise
# Parameters    : hash_ref $win_ref  -- see comment of gotoTree function 
# Throws        : no exception
# Comments      : Marks the modified file as notSaved(1), calls on_node_chage() callback
# See Also      : Treex::PML::Node::new(), Treex::PML::Struct::set_member(), Treex::PML::Struct::paste_on()
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


=head1 NAME

TrEd::Extensions - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::Extensions;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::Extensions, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

