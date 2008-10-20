package TrEd::Extensions;
# pajas@ufal.ms.mff.cuni.cz          02 øíj 2008

use 5.008;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);

use URI;

BEGIN {
  require Exporter;
  require Fslib;
  require Tk::DialogReturn;
  require Tk::BindButtons;
  require Tk::ProgressBar;
  require Tk::ErrorReport;
  require Tk::QueryDialog;
  require TrEd::Version;

  our @ISA = qw(Exporter);
  our %EXPORT_TAGS = ( 'all' => [ qw(
				      getExtensionsDir
				      initExtensions
				      getExtensionList
				      getExtensionMacroPaths
				      manageExtensions
                                      getExtensionSampleDataPaths
				      getPreInstalledExtensionsDir
				      getPreInstalledExtensionList
				   ) ] );
  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
  our @EXPORT = qw(  );
  our $VERSION = '0.01';
}

# Preloaded methods go here.

sub getExtensionsDir {
  return $TrEd::Config::extensionsDir;
}
sub getPreInstalledExtensionsDir {
  return $TrEd::Config::preinstalledExtensionsDir;
}

sub getExtensionList {
  my ($repository)=@_;
  my $url;
  if ($repository) {
    $url = IOBackend::make_URI($repository).'/extensions.lst';
  } else {
    $url =
      File::Spec->catfile(getExtensionsDir(),'extensions.lst');
    return unless -f $url;
  }
  my $fh = eval { IOBackend::open_uri($url) };
  warn $@ if ($@);
  return [] unless $fh;
  my @extensions = grep { /^!?[[:alnum:]_-]+\s*$/ } <$fh>;
  s/\s+$// for @extensions;
  IOBackend::close_uri($fh);
  return \@extensions;
}

sub initExtensions {
  my ($list,$extension_dir)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: initExtensions( [ extension_name(s)... ] )');
  }
  $extension_dir||=getExtensionsDir();
  my (%m,%r,%i,%s);
  @s{ @TrEd::Utils::stylesheetPaths } = ();
  @r{ Fslib::ResourcePaths() } = ();
  @m{ @TrEd::Macros::macro_include_paths } = ();
  @i{ @INC } = ();
  for my $name (grep { !/^!/ } @$list) {
    my $dir = File::Spec->catdir($extension_dir,$name,'resources');
    if (-d $dir and !exists($r{$dir})) {
      Fslib::AddResourcePath($dir);
      $r{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir,$name);
    if (-d $dir and !exists($m{$dir})) {
      push @TrEd::Macros::macro_include_paths, $dir;
      $m{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir,$name,'libs');
    if (-d $dir and !exists($i{$dir})) {
      push @INC, $dir;
      $i{$dir}=1;
    }
    $dir = File::Spec->catdir($extension_dir,$name,'stylesheets');
    if (-d $dir and !exists($s{$dir})) {
      push @TrEd::Utils::stylesheetPaths, $dir;
      $s{$dir}=1;
    }
  }
  PMLBackend::configure();
}

sub getExtensionMacroPaths {
  my ($list,$extension_dir)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: configureExtensionMacroPaths( [ extension_name(s)... ] )');
  }
  $extension_dir||=getExtensionsDir();
  return
    #  grep { -f $_ }
  map { glob($_.'/*/contrib.mac'), ( -f $_.'/contrib.mac' ? $_.'/contrib.mac' : ()) }
  map { File::Spec->catfile($extension_dir,$_,'contrib') }
  grep { !/^!/ }
  @$list;
}

sub getPreInstalledExtensionList {
  my ($except)=@_;
  $except||=[];
  my $preinst_dir = getPreInstalledExtensionsDir();
  my $pre_installed = ((-d $preinst_dir) && getExtensionList($preinst_dir)) || [];
  my %preinst;
  @preinst{ grep !/^!/, @$pre_installed } = ();
  delete @preinst{ map { /^!?(\S+)/ ? $1 : $_ } @$except };
  @$pre_installed = grep exists($preinst{$_}), @$pre_installed;
  return $pre_installed;
}

sub getExtensionSampleDataPaths {
  my ($list,$extension_dir)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: configureExtensionSampleDataPaths( [ extension_name(s)... ] )');
  }
  $extension_dir||=getExtensionsDir();
  return
  grep -d $_,
  map File::Spec->catfile($extension_dir,$_,'sample'),
  grep !/^!/,
  @$list;
}

sub getExtensionMetaData {
  my ($name,$extensions_dir)=@_;
  my $metafile;
  if (UNIVERSAL::isa($name,'URI')) {
    $metafile = URI->new('package.xml')->abs($name.'/');
  } else {
    $metafile =
      File::Spec->catfile($extensions_dir||getExtensionsDir(),$name,'package.xml');
    return unless -f $metafile;
  }
  my $data =  eval { PMLInstance->load({
    filename => $metafile,
  })->get_root;
  };
  warn $@ if $@;
  return $data;
}

# compare two revision numbers
sub _cmp_revisions {
  my ($my_revision,$revision)=@_;
  my @my_revision = split(/\./,$my_revision);
  my @revision = split(/\./,$revision);
  my $cmp=0;
  while ($cmp==0 and (@my_revision or @revision)) {
    $cmp = (shift(@my_revision) <=> shift(@revision));
  }
  return $cmp;
}

sub _required_by {
  my ($name, $exists, $required_by)=@_;
  my %set;
  my @test_deps=($name);
  while (@test_deps) {
    my $n = shift @test_deps;
    if (! exists $set{$n}) {
      push @test_deps,
	grep exists($exists->{$n}), keys %{$required_by->{$n}};
      $set{$n}=$n;
    }
  }
  return values(%set);
}

sub _requires {
  my ($name,$exists,$requires)=@_;
  my %req;
  my @deps = ($name);
  while (@deps) {
    my $n = shift @deps;
    unless (exists $req{$n}) {
      push @deps, grep exists($exists->{$_}), @{$requires->{$n}} if $requires->{$n};
      $req{$n}=$n;
    }
  }
  return values %req;
}

{
  sub _fmt_size {
    my ($size)=@_;
    my $unit;
    for (qw(B KiB MiB)) {
      $unit=$_;
      if ($size<1024) {
	last;
      } else {
	$size=$size/1024;
      }
    }
    return sprintf("%d %s",$size,$unit||'GiB');
  }
}

sub _populate_extension_pane {
  my ($tred,$d,$opts)=@_;
  my $list;
  my (%enable,%required_by,%embeded,%requires,%data,%pre_installed);
  my ($progress,$progressbar)=($opts->{progress},$opts->{progressbar});
  if ($opts->{install}) {
    my @list;
    for my $repo (map { IOBackend::make_URI($_) } @{$opts->{repositories}}) {
      push @list, map { [$repo,$_,URI->new($_)->abs($repo.'/')] } 
	grep { $opts->{only_upgrades} ? exists($opts->{installed}{$_}) : 1 }
	grep { length and defined }
	@{getExtensionList($repo)};
    }
    if ($progressbar) {
      $progressbar->configure(
	-to => scalar(@list),
	-blocks => scalar(@list),
       );
    }
    my $i=0;
    my %in_def_repo; @in_def_repo{map $_->[2], @list}=();
    my (%seen);
  PKG:
    while ($i<@list) {
      my ($repo,$short_name,$uri) = @{$list[$i]};

      my $data = $data{$uri} ||= getExtensionMetaData($uri);
      my $installed_ver = $opts->{installed}{$short_name};
      $installed_ver||=0;
      if (exists $in_def_repo{$uri}) {
	$$progress++ if $progress;
	$progressbar->update if $progressbar;
      }
      if ($data and
#	    (!@req_tred or
#	      !grep { $main::VERSION } @req_tred
#	    ) and
	    (!$installed_ver and $data->{version})
	    or ($installed_ver and $data->{version} and _cmp_revisions($installed_ver,$data->{version})<0)) {
	$i++
      } else {
	splice @list,$i,1;
	next PKG;
      }
      $requires{$uri} = [];
      my $require = $data && ref($data->{require}) && $data->{require};
      if (!exists($seen{$uri}) and $require) {
	$seen{$uri}=1;
	for my $req ($require->values('extension')) {
	  Encode::_utf8_off($_) for grep defined, $req->{name}, $req->{href};
	  my $req_name = $req->{name};
	  my $installed_req_ver = $opts->{installed}{$req_name};
	  my ($min,$max) = ($req->{min_version}||'',$req->{max_version}||'');
	  next if ($installed_req_ver
		   and (!$min or _cmp_revisions($installed_req_ver,$min)>=0)
		   and (!$max or _cmp_revisions($installed_req_ver,$max)<=0));
	  my $repo = $data->{repository} && $data->{repository}{href};
	  my $req_uri = ($repo && (!$req->{href} || (URI->new('.')->abs($req->{href}) eq $repo))) ?
	      URI->new($req_name)->abs($uri) : URI->new($req->{href} || $req_name)->abs($uri);
	  my $req_data = $data{$req_uri} ||= getExtensionMetaData($req_uri);
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
	    push @list,[URI->new('.')->abs($req_uri), $req_name, $req_uri];
	  }
	}
      }
      $required_by{$_}{$uri}=1 for @{$requires{$uri}};
    }
    $list = [ map $_->[2], @list ];
  } else {
    $list = getExtensionList();
    my $pre_installed = getPreInstalledExtensionList($list);
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
      my $data = $data{$name} = getExtensionMetaData($name, exists($pre_installed{$name}) ? getPreInstalledExtensionsDir() : ());
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
  my $extension_dir=$opts->{extensions_dir} || getExtensionsDir();
  my $row=0;
  my $text = $opts->{pane} || $d->add('Scrolled' => 'ROText',
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
  for my $name (@$list) {
    my $short_name = UNIVERSAL::isa($name,'URI') ?
      do { my $n=$name; $n=~s{.*/}{}; $n } : $name;
    my $data = $data{$name};
    my $start = $text->index('end');
    my $bf = $text->Frame(-background=>'white');
    my $image;
    if ($data) {
      $opts->{versions}{$name}=$data->{version};
      if ($data->{icon}) {
	my ($path,$unlink,$format);
	if (UNIVERSAL::isa($name,'URI')) {
	  ($path,$unlink) = eval { IOBackend::fetch_file(URI->new($data->{icon})->abs($name.'/')) };
	} else {
	  $path = File::Spec->rel2abs($data->{icon},
				      File::Spec->catdir($extension_dir,$name)
				       );
	}
	{ #DEBUG; 
	  $path||='';
	  print "$name => $data->{icon}\n";
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
    $enable{$name}=1 if $opts->{only_upgrades};
    if (UNIVERSAL::isa($name,'URI')) {
      my @req_tred = $data && $data->{require} && $data->{require}->values('tred');
      my $requires_different_tred='';
      for my $r (@req_tred) {
	if ($r->{min_version}) {
	  if (TrEd::Version::CMP_TRED_VERSION_AND($r->{min_version})<0) {
	    $requires_different_tred.=' and ' if $requires_different_tred;
	    $requires_different_tred='at least '.$r->{min_version}
	  }
	}
	if ($r->{max_version}) {
	  if (TrEd::Version::CMP_TRED_VERSION_AND($r->{max_version})>0) {
	    $requires_different_tred.=' and ' if $requires_different_tred;
	    $requires_different_tred='at most '.$r->{max_version}
	  }
	}
      }
      if (length $requires_different_tred) {
	$bf->Label(-text=>'Requires TrEd '.$requires_different_tred.' (this is '.TrEd::Version::TRED_VERSION().')')->pack(-fill=>'x');
      } else {
	$bf->Checkbutton(-text=> exists($opts->{installed}{$short_name})
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
				      my ($name,$opts,$required_by,$requires)=@_;
				      my (@enable,@disable);
				      if ($enable{$name}) {
					@enable=_requires($name,$opts->{versions},$requires);
				      } else {
					@disable=_required_by($name,$opts->{versions},$required_by);
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
				      ${$opts->{reload_macros}}=1 if ref $opts->{reload_macros};
				      $enable{$_}=0 for @disable;
				      $enable{$_}=1 for @enable;
				      setExtension(\@disable,0) if (@disable);
				      setExtension(\@enable,1) if (@enable)
				    },$name,$opts,\%required_by,\%requires],
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
				 },$name,\%required_by,$opts,$d], #,\%embeded
		   )->pack(-fill=>'both',
			   -side=>'right',
			   -padx => 5);
      }
    }
    $text->insert('end',' ',[$bf]);
    {
      if ($data and ($data->{install_size} or $data->{package_size})) {
	$text->insert('end', '(Size: ');
	if (UNIVERSAL::isa($name,'URI')) {
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
  unless ($opts->{pane}) {
    $text->TextSearchLine(-parent => $d, -label=>'S~earch')->pack(qw(-fill x));
    $opts->{pane}=$text;
  }
  $text->see('0.0');
  return \%enable;
}

sub manageExtensions {
  my ($tred,$opts)=@_;
  $opts||={};
  my $mw = $opts->{top} || $tred->{top} || return;
  my $UPGRADE = 'Check updates';
  my $DOWNLOAD_NEW = 'Get new extensions';
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
	if ((ref(eval{ getExtensionList($url) }) and !$@
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

sub installExtensions {
  my ($urls,$opts)=@_;
  croak(q{Usage: installExtensions(\@urls,\%opts)}) unless ref($urls) eq 'ARRAY';
  return unless @$urls;
  $opts||={};
  my $extension_dir=$opts->{extensions_dir} || getExtensionsDir();
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
      $opts->{quiet}=1 if $1 eq 'All';
      uninstallExtension($name); # or just rmtree
    }
    mkdir $dir;
    my ($zip_file,$unlink) = eval { IOBackend::fetch_file($url.'.zip') };
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
    unless ($zip->extractTree( '', $dir.'/' ) == Archive::Zip::AZ_OK()) {
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

sub setExtension {
  my ($name,$enable,$extension_dir)=@_;
  my %names; @names{ (ref($name) eq 'ARRAY' ? @$name : $name) } = ();
  $extension_dir||=getExtensionsDir();
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

sub uninstallExtension {
  my ($name,$opts) = @_;
  require File::Path;
  return unless defined $name and length $name;
  $opts||={};
  my $extension_dir=$opts->{extensions_dir} || getExtensionsDir();
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
# Below is stub documentation for your module. You'd better edit it!

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

