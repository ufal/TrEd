#!/usr/bin/env xsh2
# -*- cperl -*-

quiet;
perl {
  %ppms=();
  $architecture=shift;
  @repositories=split /,/, shift @ARGV;
  foreach (@repositories) {
    echo "Repository: $_\n";
  }
  @packages=@ARGV;
  echo "Packages: @packages\n";
};

def open_ppd $package {
  my $err;
  if {$ppms{$package}} return;
  try {
    my $ok=0;
    my $next=0;
    foreach my $__ in { @repositories } {
      # echo "Trying repository ${__}";
      try {
	$next=0;
	# echo  "Trying ${__}/${package}.ppd";
        my $pkg := open :W "${__}/${package}.ppd";
	#echo "<${package}>***************";
	#ls $pkg//SOFTPKG/@NAME;
	# echo xsh:filename($pkg);
        unless ($pkg//SOFTPKG[@NAME=$package] and
		$pkg//IMPLEMENTATION[ARCHITECTURE[@NAME=$architecture] or not(ARCHITECTURE)]/CODEBASE/@HREF)	  {
	  perl { die "Not a package file\n"; }
        }
	echo "Found '${package}' at ${__}";
        perl { $ppms{$package}=$pkg };
        foreach $pkg//DEPENDENCY/@NAME {
          my $dep = string(.);
	  #echo "Dependency: ${dep}";
	  if { ! $ppms{$dep} } {
	    open_ppd $dep;
	  }
        }
	# echo "</${package}>***************";
      } catch my $err {
        #echo "${package} not found in ${__}, skipping:" $err;
        $next=1;
      }
      unless ($next) {
	#echo "finished";
        throw "finished";
      }
    }
  } catch $err {
    unless {$err =~ /^finished/} {
      throw $err;
    }
  }
}

def wget $href $baseurl {
  if { $href=~s{^file://}{} } {
    # echo "Using absolute URL $href";
    system "cp" $href ".";
  } elsif { $href=~/^[a-zA-Z]+:/ } {
    # echo "Using absolute URL $href";
    system "wget" "-nv" $href;
  } else {
    perl { $baseurl=~s{/[^/]+$}{} };
    # echo "Resolving relative URL $href as $baseurl/$href";
    if { $baseurl=~s{^file://}{} } {
      system "cp" "${baseurl}/${href}" ".";
    } else {
      system "wget" "-nv" "${baseurl}/${href}";
    }
  }
}

def download_package $package {
  my $href;
  echo $package;
  my $pkg = { $ppms{$package} };
  if ($pkg) {
    rm $pkg//REQUIRE[@NAME='perl']; # non-installable
    rm $pkg//REQUIRE[@NAME='IO-File' or @NAME='IO::File']; # non-installable, part of Perl distro
    rm $pkg//REQUIRE[@NAME='XML::SAX::Base']; # obsoleted by XML::SAX
    my $baseurl = xsh:filename($pkg);
    foreach ($pkg//IMPLEMENTATION[ARCHITECTURE[@NAME=$architecture]]/CODEBASE/@HREF) {
      echo wget  string(.) $baseurl;
      wget string(.) $baseurl;
      map :i { s{^.*?([^/]+)$}{$1} } .; # convert URL to filename
      # ls .;
    }
    if not($pkg//IMPLEMENTATION/PROVIDE) {
      # echo "Fixing PROVIDE in ${package}";
      my $p := insert element 'PROVIDE' into $pkg//IMPLEMENTATION;
      set $p/@NAME $pkg/SOFTPKG/@NAME;
      map :i { s{-}{::}g } $p/@NAME;
      set $p/@VERSION 'undef';
    }
    save --format xml --file "${package}.ppd" $pkg;
  } else {
    echo "Don't know the package ${package}";
  }
}

foreach my $package in { @packages } {
  # echo "Openning ${package}";
  open_ppd $package;
}

foreach my $package in { keys %ppms } {
  # echo "Downloading distribution package for ${package}";
  download_package $package;
}

foreach my $package in { grep {!$ppms{$_}} @packages } {
  echo "*** ERROR ***: FAILED to get ${package}!";
}

echo "Finished.";
