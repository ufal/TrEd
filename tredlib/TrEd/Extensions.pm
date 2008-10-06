package TrEd::Extensions;
# pajas@ufal.ms.mff.cuni.cz          02 øíj 2008

use 5.008;
use strict;
use warnings;
use Carp;
use File::Spec;
use URI;

BEGIN {
  require Exporter;
  require Fslib;

  our @ISA = qw(Exporter);
  our %EXPORT_TAGS = ( 'all' => [ qw(
				      getExtensionsDir
				      initExtensions
				      getExtensionList
				      getExtensionMacroPaths
				      manageExtensions
  ) ] );
  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
  our @EXPORT = qw(  );
  our $VERSION = '0.01';
}

# Preloaded methods go here.

sub getExtensionsDir {
  return $TrEd::Config::extensionsDir;
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
  my $fh = IOBackend::open_uri($url,'UTF-8') || return [];
  my @extensions = grep { /^!?[[:alnum:]_-]+\s*$/ } <$fh>;
  s/\s+$// for @extensions;
  IOBackend::close_uri($fh);
  return \@extensions;
}

sub initExtensions {
  my ($list)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: initExtensions( [ extension_name(s)... ] )');
  }
  my $extension_dir=getExtensionsDir();
  for my $name (grep { !/^!/ } @$list) {
    my $dir = File::Spec->catdir($extension_dir,$name,'resources');
    if (-d $dir) {
      Fslib::AddResourcePath($dir);
    }
  }
}
sub getExtensionMacroPaths {
  my ($list)=@_;
  if (@_==0) {
    $list=getExtensionList();
  } elsif (!ref($list) eq 'ARRAY') {
    carp('Usage: configureExtensionMacroPaths( [ extension_name(s)... ] )');
  }
  my $extension_dir=getExtensionsDir();
  return
#  grep { -f $_ }
  map { File::Spec->catfile($extension_dir,$_,'contrib','contrib.mac') }
  grep { !/^!/ }
  @$list;
}

sub getExtensionMetaData {
  my ($name)=@_;
  my $metafile;
  if (UNIVERSAL::isa($name,'URI')) {
    $metafile = URI->new('package.xml')->abs($name.'/');
  } else {
    $metafile =
      File::Spec->catfile(getExtensionsDir(),$name,'package.xml');
    return unless -f $metafile;
  }
  print "$metafile\n";
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

sub _populate_extension_pane {
  my ($tred,$d,$opts)=@_;
  my $list = $opts->{list};
  if (!$list) {
    if ($opts->{install}) {
      $list=[];
      for my $repo (map { IOBackend::make_URI($_) } @{$opts->{repositories}}) {
	push @$list, map { URI->new($_)->abs($repo.'/') } grep { length and defined }
	  @{getExtensionList($repo)};
      }
    } else {
      $list = getExtensionList();
    }
  } elsif (!ref($list) eq 'ARRAY') {
    carp('manageExtensions: parameter list must be an array reference');
  }
  my $extension_dir=getExtensionsDir();
  my $row=0;
  my %enable;
#   my $pane = $d->add('Scrolled' => 'Pane',
# 		     -scrollbars=>'oe',
# 		     -sticky=>'nw',
# 		     -gridded => 'xy',
# 		     -height=>400,
# 		     #		     -width =>600,
# 		     -background=>'white',
# 		    );
  my $text = $d->add('Scrolled' => 'ROText',
		     -scrollbars=>'oe',
		     -takefocus=>0,
		     -relief=>'flat',-wrap=>'word',-width=>60,);
  for my $name (@$list) {
    my $short_name = UNIVERSAL::isa($name,'URI') ?
      do { my $n=$name; $n=~s{.*/}{}; $n } : $name;
    my $data;
    if ($opts->{install}) {
      $data = getExtensionMetaData($name);
      next unless $data;
      my $installed_ver = $opts->{installed}{$short_name};
      next unless (!$installed_ver and $data->{version})
	or ($installed_ver and $data->{version}
	    and _cmp_revisions($installed_ver,$data->{version})<0
	   );
    } else {
      $enable{$name} = 1;
      if ($name=~s{^!}{}) {
	$enable{$name} = 0;
      }
      $data = getExtensionMetaData($name);
    }
    my $start = $text->index('end');
    my $bf = $text->Frame(-background=>undef);
#    $bf->bind('<MouseWheel>',sub{print "y\n" });
#    $bf->bind("<$_>",sub{print "x\n" }) for 4..7;
    my $image;
    if ($data) {
      $opts->{versions}{$name}=$data->{version};
      if ($data->{icon}) {
	my ($path,$unlink,$format);
	if (UNIVERSAL::isa($name,'URI')) {
	  ($path,$unlink) = IOBackend::fetch_file(URI->new($data->{icon})->abs($name.'/'));
	} else {
	  $path = File::Spec->rel2abs($data->{icon},
				      File::Spec->catdir($extension_dir,$name)
				       );
	}
	if (-f $path) {
	  require Tk::JPEG;
	  require Tk::PNG;
	  eval {
	    my $img = $text->Photo(
	      -file => $path,
	      -format => $format,
	      -width=>160,
	      -height=>0,
	     );
	    $image = $text->Label(-image=> $img);
	  };
	  warn $@ if $@;
	  unlink $path if $unlink;
	}
      }
      $text->insert('end',"\n");
      $text->windowCreate('end',-window => $image,-padx=>5) if $image;

      $text->insert('end',$data->{title},[qw(title)]);
      $text->insert('end',' ('.$short_name.(defined($data->{version}) && length($data->{version})
			  ? ' '.$data->{version} : ''
			 ).')',[qw(name)]);
      $text->insert('end',"\n");
#      $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
      my $desc = $data->{description} || 'N/A';
      $desc=~s/\s+/ /g;
      $desc=~s/^\s+|\s+$//g;
      $text->insert('end',#'Description: ',[qw(label)],
		    $desc,[qw(desc)],"\n");
      $text->insert('end','Copyright '.
		    ( $data->{copyright}{'#content'}
			.($data->{copyright}{year} ? ' (c) '.$data->{copyright}{year} : '')
		    ),[qw(copyright)],"\n\n") if ref $data->{copyright};
    } else {
      $text->insert('end','Name: ',[qw(label)],$name,[qw(name)],"\n");
      $text->insert('end','Description: ',[qw(label)],'N/A',[qw(desc)],"\n\n");
    }
    my $end = $text->index('end');
    $end=~s/\..*//;
    $text->configure(-height=>$end);
    my @requires;
    if ($data and ref $data->{require}) {
      #print "$name\n";
      #print "$data->{require}\n";
      @requires = $data->{require}->values('extension');
      #print ((map { $_->{href} } @requires),"\n");
    }

    if (UNIVERSAL::isa($name,'URI')) {
      $bf->Checkbutton(-text=> exists($opts->{installed}{$short_name})
			 ? 'Upgrade' : 'Install',
		       -compound=>'left',
		       -selectcolor=>undef,
		       -indicatoron => 0,
		       -background=>'white',
		       -relief => 'flat',
		       -borderwidth => 0,
		       -padx => 5,
		       -pady => 5,
		       -selectimage => main::icon($tred,"checkbox_checked"),
		       -image => main::icon($tred,"checkbox"),
		       -command => [sub {
				      my ($enable,$name,$requires)=@_;
				      # print "Enable: $enable->{$name}, $name, ",join(",",map { $_->{name} } @$requires),"\n";;
				      if ($enable->{$name}==1) {
					$enable->{$_}++ for map { $_->{href} } @$requires;
				      } elsif ($enable->{$name}==0) {
					$enable->{$_}-- for map { $_->{href} } @$requires;
				      }
				    },\%enable,$name,\@requires],
		       -variable=>\$enable{$name})->pack(-fill=>'x')
    } else {
      $bf->Checkbutton(-text=>'Enable',
		       -compound=>'left',
		       -selectcolor=>undef,
		       -indicatoron => 0,
		       -background=>'white',
		       -relief => 'flat',
		       -borderwidth => 0,
		       -padx => 5,
		       -pady => 5,
		       -selectimage => main::icon($tred,"checkbox_checked"),
		       -image => main::icon($tred,"checkbox"),
		       -command => [sub {
				      my ($name,$reload)=@_;
				      $$reload=1 if ref $reload;
				      setExtension($name,$enable{$name});
				    },$name,$opts->{reload_macros}],
		       -variable=>\$enable{$name})->pack(-fill=>'both',-side=>'left',-padx => 5);
      $bf->Button(-text=>'Uninstall',
		  -compound=>'left',
		  -image => main::icon($tred,'remove'),
		  -command => [sub {
				 my ($name,$d,$reload,@slaves)=@_;
				 uninstallExtension($name,{tk=>$d}); # or just rmtree
				 $text->configure(-state=>'normal');
				 $text->DeleteTextTaggedWith($name);
				 $text->configure(-state=>'disabled');
				 # $text->gridForget(grep defined, @slaves);
				 $_->destroy for @slaves;
				 $$reload=1 if ref $reload;
			       },$name,$d,$opts->{reload_macros},$bf,$text,$image],
		 )->pack(-fill=>'both',
			 -side=>'right',
			 -padx => 5);
    }
#    $bf->grid(-column=>0,-row=>$row, -sticky=>'nw',);
#    $text->grid(-column=>1,-row=>$row,-padx=>5,-pady=>5, -sticky=>'nw', );
#    $image->grid(-column=>2,-row=>$row,-padx=>5,-pady=>5, -sticky=>'nw',) if $image;

    $text->insert('end',' ',[$bf]);
    $text->windowCreate('end',-window => $bf,-padx=>5);
    $text->tagConfigure($bf,-justify=>'right');
    $text->Insert("\n");
    $text->Insert("\n");
    $text->tagAdd($name,$start.' - 1 line','end -1 char');

    $text->tagBind($name,'<Any-Enter>' => [sub {
					     my ($text,$name,$bf)=@_;
					     $bf->configure(-background=>'lightblue');
					     $text->tagConfigure($name,-background=>'lightblue');
					     $bf->focus;
					     $bf->focusNext;
					   },$name,$bf]);
    $bf->bind('<Any-Enter>' => [sub {
			      my ($bf,$text,$name)=@_;
			      $bf->configure(-background=>'lightblue');
			      $text->tagConfigure($name,-background=>'lightblue');
			      $bf->focus;
			      $bf->focusNext;
			    },$text,$name]);
    $text->tagBind($name,'<Any-Leave>' => [sub {
					     my ($text,$name,$bf)=@_;
					     $bf->configure(-background=>'white');
					     $text->tagConfigure($name,-background=>'white');
					   },$name,$bf]);
    $bf->bind('<Any-Leave>' => [sub {
			      my ($bf,$text,$name)=@_;
			      $bf->configure(-background=>'white');
			      $text->tagConfigure($name,-background=>'white');
			    },$text,$name]);
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
  $text->tagConfigure('title', -foreground => 'black', -font => 'C_bold');
  $text->tagConfigure('copyright', -foreground => '#666', -font => 'C_small');

  $text->configure(-state=>'disabled');

  if ($opts->{pane}) {
    $opts->{pane}->packForget;
    $opts->{pane}->destroy
  }
  $text->pack(-expand=>1,-fill=>'both');
  $text->see('0.0');
  $opts->{pane}=$text;
  return \%enable;
}

sub manageExtensions {
  my ($tred,$opts)=@_;
  $opts||={};
  my $mw = $tred->{top} || return;
  my $DOWNLOAD_NEW = 'Get new extensions';
  my $INSTALL = 'Install Selected';
  my $d = $mw->DialogBox(-title => 'Manage Extensions',
			 -buttons => ['Close',
				      $opts->{install} ? $INSTALL : $DOWNLOAD_NEW]
			);
  my $enable = _populate_extension_pane($tred,$d,$opts);
  if ($opts->{install}) {
    $d->Subwidget('B_'.$INSTALL)->configure(
      -command => sub {
	my @selected = grep $enable->{$_}, keys %$enable;
	$d->Busy(-recurse=>1);
	eval {
	  installExtensions(\@selected,{tk => $d}) if @selected;
	};
	main::errorMessage($d,$@) if $@;
	$d->Unbusy;
	$d->{selected_button}=$INSTALL;
      }
     );
  } elsif ($opts->{repositories} and @{$opts->{repositories}}) {
    $d->Subwidget('B_'.$DOWNLOAD_NEW)->configure(
      -command => sub {
	if (manageExtensions($tred,{ install=>1,
				     installed => $opts->{versions},
				     repositories => $opts->{repositories} }) eq $INSTALL) {
	  $enable = _populate_extension_pane($tred,$d,$opts);
	  if (ref($opts->{reload_macros})) {
	    ${$opts->{reload_macros}}=1;
	  }
	}
      }
     );
  }
  require Tk::DialogReturn;
  $d->BindEscape(undef,'Close');
  return $d->Show();
}

sub installExtensions {
  my ($urls,$opts)=@_;
  croak(q{Usage: installExtensions(\@urls,\%opts)}) unless ref($urls) eq 'ARRAY';
  return unless @$urls;
  $opts||={};
  my $extension_dir=getExtensionsDir();
  unless (-d $extension_dir) {
    mkdir $extension_dir ||
      die "Installation failed: cannot create extension directory $extension_dir: $!";
  }
  my $extension_list_file =
    File::Spec->catfile($extension_dir,'extensions.lst');
  my @extension_file;
  if (-f $extension_list_file) {
    open my $fh, '<:utf8', $extension_list_file ||
      die "Installation failed: cannot read extension list $extension_list_file: $!";
    chomp( @extension_file = <$fh> );
    close $fh;
  } else {
    push @extension_file, split /\n\s*/, <<'EOF';
    # DO NOT MODIFY THIS FILE
    #
    # This file only lists installed extensions.
    # ! before extension name means the module is enabled
    #
EOF
  }
  require Archive::Zip;
  for my $url (@$urls) {
    my $name = $url; $name=~s{.*/}{}g;
    my $dir = File::Spec->catdir($extension_dir,$name);
    if (-d $dir) {
      next if ($opts->{tk}->QuestionQuery(
	-title => 'Reinstall?',
	-label => "Extension $name is already installed in $dir.\nDo you want to upgrade/reinstall it?",
	-buttons =>['Install/Upgrade', 'Cancel']
       ) eq 'Cancel');
      uninstallExtension($name); # or just rmtree
    }
    mkdir $dir;
    my ($zip_file,$unlink) = eval { IOBackend::fetch_file($url.'.zip') };
    if ($@) {
      main::errorMessage($opts->{tk},"Downloading ${url}.zip failed:\n".$@);
      next;
    }
    my $zip = Archive::Zip->new();
    unless ($zip->read( $zip_file ) == Archive::Zip::AZ_OK()) {
      main::errorMessage($opts->{tk},"Reading ${url}.zip failed!\n");
      next;
    }
    unless ($zip->extractTree( '', $dir.'/' ) == Archive::Zip::AZ_OK()) {
      main::errorMessage($opts->{tk},"Extracting files from ${url}.zip failed!\n");
      next;
    }
    @extension_file = ((grep { !/^\!?\Q$name\E\s*$/ } @extension_file),$name);
  }
  open my $fh, '>:utf8', $extension_list_file ||
    die "Installation failed: cannot write to extension list $extension_list_file: $!";
  print $fh ($_."\n") for @extension_file;
  close $fh;
}

sub setExtension {
  my ($name,$enable)=@_;
  my $extension_dir=getExtensionsDir();
  my $extension_list_file =
    File::Spec->catfile($extension_dir,'extensions.lst');
  if (-f $extension_list_file) {
    open my $fh, '<:utf8', $extension_list_file ||
      die "Configuring extension failed: cannot read extension list $extension_list_file: $!";
    my @list = <$fh>;
    close $fh;
    open $fh, '>:utf8', $extension_list_file ||
      die "Configuring extenson failed: cannot write extension list $extension_list_file: $!";
    for (@list) {
      if (/^!?\Q$name\E\s*$/) {
	print $fh (($enable ? '' : '!').$name."\n");
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
  my $extension_dir=getExtensionsDir();
  my $dir = File::Spec->catdir($extension_dir,$name);
  if (-d $dir) {
    return if ($opts->{tk} and
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
    open my $fh, '<:utf8', $extension_list_file ||
      die "Uninstall failed: cannot read extension list $extension_list_file: $!";
    my @list = <$fh>;
    close $fh;
    open $fh, '>:utf8', $extension_list_file ||
      die "Uninstall failed: cannot write extension list $extension_list_file: $!";
    for (@list) {
      next if /^!?\Q$name\E\s*$/;
      print $fh ($_);
    }
    close $fh;
  }
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

