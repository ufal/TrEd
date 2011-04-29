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
                          get_extension_sample_data_paths
                          get_extension_doc_paths
                          get_preinstalled_extensions_dir
                          get_preinstalled_extension_list
                          get_extension_template_paths
                          get_extension_subpaths
				   ) ] );
#				                             manageExtensions
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
  return if not eval { require CPAN; 1 };
  return CPAN::Version->vcmp($v1,$v2);
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

