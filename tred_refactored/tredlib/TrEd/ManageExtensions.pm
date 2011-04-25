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

my $dialog_box;
my %required_by;
my %requires;
my $opts_ref;

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
  my ($pkg_name)=@_;
  my $short_name = (blessed($pkg_name) and $pkg_name->isa('URI')) ?
         do { my $n = $pkg_name; 
              $n =~ s{.*/}{}; 
              return $n 
         } 
         : $pkg_name;
  return $short_name;
}


sub _repo_extensions_uri_list {
  my @repo_extension_uri_list;
  # Tip: read the comments from the bottom up
  for my $repo (map { Treex::PML::IO::make_URI($_) } @{$opts_ref->{repositories}}) {
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

sub _update_progressbar {
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

sub _version_ok {
  my ($my_version, $required_extension) = @_;
  
  my $min_version = $required_extension->{min_version} || '';
  my $max_version = $required_extension->{max_version} || '';
  
  return (!$min_version || cmp_revisions($my_version, $min_version) >= 0) 
          && (!$max_version || TrEd::Extensions::cmp_revisions($my_version, $max_version) <= 0);
}

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
      TrEd::Extensions::cmp_revisions($installed_ver, $meta_data_ref->{version}) < 0));
  } 
  else {
    return 0;
  } 
}

sub _resolve_missing_dependency {
  my ($req_data, $required_extension, $short_name, $repo) = @_;
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
}

sub _add_required_exts {
  my ($arg_ref) = @_;

  my $meta_data_ref         = $arg_ref->{meta_data_ref};
  my $extension_data_ref    = $arg_ref->{extension_data_ref};
  my $extensions_list_ref   = $arg_ref->{extensions_list_ref};
  my $uri_in_repository_ref = $arg_ref->{uri_in_repository_ref};
  my $uri                   = $arg_ref->{uri};
  my $short_name            = $arg_ref->{short_name};
  
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
      
      # If we are here, required extension is not installed or it is not up-to-date
      my $repo = $meta_data_ref->{repository} && $meta_data_ref->{repository}{href};
      my $req_uri = ($repo && (!$required_extension->{href} || (URI->new('.')->abs($required_extension->{href}) eq $repo))) ?
          URI->new($req_name)->abs($uri) 
          : URI->new($required_extension->{href} || $req_name)->abs($uri);
      my $req_data = $extension_data_ref->{$req_uri} ||= TrEd::Extensions::getExtensionMetaData($req_uri);
      
      # what does the user want to do with missing dependency?
      my $res = _resolve_missing_dependency($req_data, $required_extension, $short_name, $repo);
      
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

sub _fill_required_by {
  my ($id) = @_;
  foreach my $dependency (@{$requires{$id}}) {
    $required_by{$dependency}{$id} = 1;
  }
  return;
}

sub _uri_list_with_required_exts {
  my ($arg_ref) = @_;

  my $extensions_list_ref = $arg_ref->{extensions_list_ref};
  my $extension_data_ref = $arg_ref->{extension_data_ref};
#  my $opts_ref            = $arg_ref->{opts_ref};
#  my $requires_ref        = $arg_ref->{requires_ref};
#  my $required_by_ref     = $arg_ref->{required_by_ref};
#  my $dialog_box          = $arg_ref->{dialog_box};
  
  my $i = 0;
  my %uri_in_repository; 
  @uri_in_repository{ map { $_->[2] } @$extensions_list_ref } = ();
  PKG:
  while ($i < @$extensions_list_ref) {
    my ($repo, $short_name, $uri) = @{$extensions_list_ref->[$i]};
    # read metadata from package.xml (or from cache)
    my $meta_data_ref = $extension_data_ref->{$uri} ||= TrEd::Extensions::getExtensionMetaData($uri);
    
    # if the extension is installed, find its version
    my $installed_ver = $opts_ref->{installed}{$short_name};
    $installed_ver ||= 0;
    
    if (exists $uri_in_repository{$uri}) {
      _update_progressbar();
    }
    
    # if extension is found in repository and it is not installed or there is a newer version in repository
    # increment excrement i
    if (_ext_not_installed_or_actual($meta_data_ref, $installed_ver)) {
      $i++;
    } 
    else {
      # remove the extensions from the list, if it is installed & up to date
      splice @$extensions_list_ref, $i, 1;
      # and go from the beginning to process another extension
      next PKG;
    }
    
    # add required extensions to @$extensions_list_ref and @$requires{$uri}
    my $res = _add_required_exts({
      meta_data_ref         => $meta_data_ref,
      extension_data_ref   => $extension_data_ref,
      extensions_list_ref   => $extensions_list_ref,
      uri_in_repository_ref => \%uri_in_repository,
      uri                   => $uri,
      short_name            => $short_name,
    });
    
    return if ($res eq 'Cancel');
    next PKG if ($res eq 'Skip');
    
    _fill_required_by($uri);
  }
  my $list_of_uris = [ map { $_->[2] } @$extensions_list_ref ];
  return $list_of_uris;
}

sub _create_uri_list {
  my ($args_ref) = @_;
  
  my $pre_installed_ref   = $args_ref->{pre_installed_ref};
  my $extension_data_ref = $args_ref->{extension_data_ref};
  my $enable_ref          = $args_ref->{enable_ref};
  
  my $uri_list;
  
  my $progress = $opts_ref->{progress};
  my $progressbar = $opts_ref->{progressbar};
  
  if ($opts_ref->{install}) {
    # for each repository find all the available extensions 
    # (if we are updating, only those that are installed already)
    my @list_of_extensions = _repo_extensions_uri_list();
    
    # set the progress bar
    if ($progressbar) {
      $progressbar->configure(
        -to => scalar(@list_of_extensions),
        -blocks => scalar(@list_of_extensions),
       );
    }
    $uri_list = _uri_list_with_required_exts({
      extensions_list_ref => \@list_of_extensions,
      extension_data_ref => $extension_data_ref,
    });
  }
  else {
    $uri_list = TrEd::Extensions::getExtensionList();
    my $pre_installed = TrEd::Extensions::getPreInstalledExtensionList($uri_list);
    if ($progressbar) {
      $progressbar->configure(
        -to => scalar(@$uri_list + @$pre_installed),
        -blocks => scalar(@$uri_list + @$pre_installed),
       );
    }
    
    $pre_installed_ref->{ @$pre_installed } = ();
    for my $name (@$uri_list, @$pre_installed) {
      # mark extensions with ! as not enabled
      $enable_ref->{$name} = 1;
      if ($name =~ s{^!}{}) {
        $enable_ref->{$name} = 0;
      }
      my $meta_data_ref = $extension_data_ref->{$name} = 
        TrEd::Extensions::getExtensionMetaData($name, exists($pre_installed_ref->{$name}) 
        ? TrEd::Extensions::getPreInstalledExtensionsDir() 
        : ());
      
      _update_progressbar();
      
      my $require = $meta_data_ref && ref($meta_data_ref->{require}) && $meta_data_ref->{require};
      if ($require) {
        $requires{$name} = $require ? [ map { $_->{name} } $require->values('extension') ] 
                                    : [];
      }
      
      _fill_required_by($name);
    }
    push(@$uri_list, @$pre_installed);
  }
  return $uri_list;
}

sub _test_tred_requirements {
  my ($data) = @_;
  my $requires_different_tred = '';
  my @req_tred = $data && $data->{require} && $data->{require}->values('tred');
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

sub _perl_module_requirements {
  my ($req_module_ref) = @_;
  
  my $requires_modules = '';
  foreach my $requirements (@$req_module_ref) {
    next if !($requirements->{name} and (lc($requirements->{name}) ne 'perl'));
    my $req = '';
    my $available_version = eval { TrEd::Extensions::get_module_version($requirements->{name}) };
    next if $@;
    if (defined $available_version) {
      if ($requirements->{min_version}) {
        if (TrEd::Extensions::compare_module_versions($available_version,$requirements->{min_version}) < 0) {
          $req = 'at least '.$requirements->{min_version};
        }
      }
      if ($requirements->{max_version}) {
        if (TrEd::Extensions::compare_module_versions($available_version,$requirements->{max_version}) > 0) {
          $req .= ' and ' if $req;
          $req = 'at most '.$requirements->{max_version};
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

sub _required_perl_version {
  my ($req_module_ref) = @_;

  my $requires_perl = '';
  foreach my $requirements (grep { lc($_->{name}) eq 'perl' } @$req_module_ref) {
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

sub _find_all_requirements {
  my ($uri_list, $extension_data_ref) = @_;
  my %uninstallable;
  # for each extension
  for my $name (@$uri_list) {
    my $data = $extension_data_ref->{$name};
    next if !((blessed($name) and $name->isa('URI')));
    
    # test tred requirements
    my $requires_different_tred=_test_tred_requirements($data);
    
    my @req_module = $data && $data->{require} && $data->{require}->values('perl_module');
    # perl modules requirements
    my $requires_modules=_perl_module_requirements(\@req_module);
    
    # perl version requirements
    my $requires_perl=_required_perl_version(\@req_module);
    
    my $all_requirements = join("\n", grep { defined($_) and length($_) } ($requires_different_tred, $requires_perl, $requires_modules));
    if (length $all_requirements) {
      $uninstallable{$name} = $all_requirements;
    }
  }
  return \%uninstallable;
}

sub _dependencies_of_req_exts {
  my ($uri_list, $uninstallable_ref) = @_;
  # for each extension from URI list
  for my $name (@$uri_list) {
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
        # required extension requires different TrEd version, Perl version or some Perl modules
        $uninstallable_ref->{$name} .= "\n" if $uninstallable_ref->{$name};
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

sub _set_icon {
  my ($args_ref) = @_;
  
  my $data              = $args_ref->{data};
  my $name              = $args_ref->{name};
  my $pre_installed_ref = $args_ref->{pre_installed_ref}; 
  my $text              = $args_ref->{text};
  my $generic_icon      = $args_ref->{generic_icon};

  
  my $extension_dir = $opts_ref->{extensions_dir} || TrEd::Extensions::getExtensionsDir();
  my $image;
  
  if ($data->{icon}) {
    my ($path, $unlink, $format);
    # construct path of the image
    if ((blessed($name) and $name->isa('URI'))) {
      ($path, $unlink) = eval { Treex::PML::IO::fetch_file(URI->new($data->{icon})->abs($name . '/')) };
    } 
    else {
      my $dir = exists($pre_installed_ref->{$name}) 
                ? TrEd::Extensions::get_preinstalled_extensions_dir() 
                : $extension_dir;
      $path = File::Spec->rel2abs($data->{icon}, File::Spec->catdir($dir, $name));
    }
    { #DEBUG; 
      $path ||= '';
      # print STDERR "Extensions.pm: $name => $data->{icon}\n";
    }
    if (defined($path) and -f $path) {
      require Tk::JPEG;
      require Tk::PNG;
      eval {
        my $img = $text->Photo(
          -file   => $path,
          -format => $format,
          -width  => 0,
          -height => 0,
         );
        $image = $text->Label(-image => $img, -background => 'white');
      };
      carp($@) if $@;
      
      # cleaning up after from Treex::PML::IO::fetch_file()
      if ($unlink) {
        unlink $path;
      }
    }
  } # no data -- use default generic icon
  else {
    require Tk::JPEG;
    require Tk::PNG;
    eval {
      $image = $text->Label(-image => $generic_icon, -background => 'white');
    };
    carp($@) if $@;
  }
  return $image;
}

sub _set_text {
  my ($args_ref) = @_;
  
  my $data              = $args_ref->{data};
  my $name              = $args_ref->{name};
  my $pre_installed_ref = $args_ref->{pre_installed_ref};
  my $text              = $args_ref->{text};
  my $image             = $args_ref->{image};
  my $tred              = $args_ref->{tred};
  
  my $generic_icon ||= main::icon($tred, 'extension');
    
  if ($data) {
    $opts_ref->{versions}{$name} = $data->{version};
    
    $image = _set_icon({
      data              => $data,
      name              => $name,
      pre_installed_ref => $pre_installed_ref,
      text              => $text,
      generic_icon      => $generic_icon,
    });
    
    $text->insert('end', "\n");
    if ($image) {
      $text->windowCreate('end', -window => $image, -padx => 5)
    }
    
    my $version = (defined($data->{version}) && length($data->{version}))  
                ? ' ' . $data->{version} 
                : ''; 
                
    $text->insert('end',$data->{title},[qw(title)]);
    $text->insert('end',' (' . short_name($name) . $version  . ')' , [qw(name)]);
    $text->insert('end',"\n");
    my $require = $data->{require};
#     $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
    my $desc = $data->{description} || 'N/A';
    $desc=~s/\s+/ /g;
    $desc=~s/^\s+|\s+$//g;
    #'Description: ',[qw(label)],
    $text->insert('end', $desc, [qw(desc)], "\n");
    
    if (ref($data->{copyright})) {
      my $c_year = $data->{copyright}{year} ? ' (c) ' . $data->{copyright}{year} : '';
      $text->insert('end', 'Copyright ' . $data->{copyright}{'#content'} . $c_year, [qw(copyright)], "\n");
    }
  }
  else {
    $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
    $text->insert('end','Description: ',[qw(label)],'N/A',[qw(desc)],"\n\n");
  }
}

sub _sub_ref {
  my ($enable, $required_by, $name, $requires) = @_;
  # print "Enable: $enable->{$name}, $name, ",join(",",map { $_->{name} } @$requires),"\n";;
  if ($enable->{$name}==1) {
    $required_by->{$name}{$name}=1;
  }
  else {
    delete $required_by->{$name}{$name};
    if (keys %{$required_by->{$name}}) {
      $enable->{$name}=1; # do not allow
      return;
    }
  }
  my @req = _requires($name, $enable, $requires);
  for my $href (@req) {
#   my $href = $req->{href};
#   my $req_name = $req->{name};
#   next if $req_name eq $name;
#   unless (exists($enable->{$href})) {
#     ($href) = grep { m{/\Q$req_name\E$}  } keys %$enable;
#   }
    next if $href eq $name or !exists($enable->{$href});
    if ($enable->{$name}==1) {
      $enable->{$href}=1;
      $required_by->{$href}{$name}=1;
    }
    elsif ($enable->{$name}==0) {
      delete $required_by->{$href}{$name};
      unless (keys(%{$required_by->{$href}})) {
        $enable->{$href}=0;
      }
    }
  }
}

sub _populate_extension_pane {
  my ($tred) = @_;
  
  my %enable;
  my %embeded;
  my %extension_data;
  my %pre_installed;
  
  # construct URI list with required extensions
  my $uri_list = _create_uri_list({
    pre_installed_ref     => \%pre_installed,
    extension_data_ref    => \%extension_data,
    enable_ref            => \%enable,
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
    my $data = $extension_data{$name};
    my $start = $text->index('end');
    my $bf = $text->Frame(-background=>'white');
    my $image;
    
    _set_text();
    
    my $end = $text->index('end');
    $end=~s/\..*//;
    $text->configure(-height=>$end);

    $embeded{$name} = [$bf, $image ? $image : ()];
    
    if ($opts_ref->{only_upgrades}) {
      $enable{$name} = 1;
    }
    
    if ((blessed($name) and $name->isa('URI'))) {
      if ($uninstallable_ref->{$name}) {
        $bf->Label(-text=>$uninstallable_ref->{$name}, -anchor=>'nw', -justify=>'left')->pack(-fill=>'x');
      }
      else {
        $bf->Checkbutton(-text=> exists($opts_ref->{installed}{short_name($name)})
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
			 -command => [\&_sub_ref, \%enable, \%required_by, $name, \%requires],
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
				      my ($name,$opts,$required_by,$requires)=@_;
				      my (@enable,@disable);
				      if ($enable{$name}) {
					@enable=_requires($name,$opts->{versions},$requires);
				      } else {
					@disable=_required_by($name,$opts->{versions},$required_by);
					if ((grep $enable{$_}, @disable)) {
					  my $res = $dialog_box->QuestionQuery(
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
				      ${$opts->{reload_macros}}=1 if ref $opts->{reload_macros};
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
				   my ($name,$required_by,$opts,$d,$embeded)=@_;
				   my @remove=_required_by($name,$opts->{versions},$required_by);
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
				       delete $opts->{versions}{$n};
				     $text->DeleteTextTaggedWith($n);
				       #for (@{$embeded->{$n}}) {
				       #  eval { $_->destroy };
				       #}
				       delete $embeded->{$n};
				       ${$opts->{reload_macros}}=1 if ref( $opts->{reload_macros} );
				     }
				   }
				   #$text->Subwidget('scrolled')->configure(-state=>'disabled');
				 },$name,\%required_by,$opts_ref,$dialog_box], #,\%embeded
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
    $text->TextSearchLine(-parent => $dialog_box,
			  -label=>'S~earch',
			  -prev_img =>main::icon($tred,'16x16/up'),
			  -next_img =>main::icon($tred,'16x16/down'),
			 )->pack(qw(-fill x));
    $opts_ref->{pane}=$text;
  }
  $text->see('0.0');
  return \%enable;
}

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
# Usage         : manageRepositories(..)
# Purpose       : 
# Returns       : 
# Parameters    :  
# Throws        : no exception
# Comments      : 
# See Also      : 
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

