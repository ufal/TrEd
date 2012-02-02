#!/usr/bin/env xsh2
# -*- mode: cperl; coding: utf-8; -*-

perl {
  use Getopt::Long;
  GetOptions(
    "quiet|q" => \$quiet,
  );
};

if (count($ARGV)<1) {
  echo :e "Usage: $CURRENT_SCRIPT rewrite_map.xml [files]\n";
}

register-xhtml-namespace xhtml;

def spit $what {
  unless {$quiet} echo :e $what;
}

spit "-------------------------------------------------------------------";
spit "Indexing rewrite map...";

perl { use File::Spec };

quiet;
my $map := open $ARGV[1];
my $doc_map = {{}};
my $id_maps = {{}};
my $title_maps = {{}};

def index_doc $id {
  my $id_map = { $id_maps->{$id} };
  unless { defined $id_map } {
    spit "-------------------------------------------------------------------";
    spit "Indexing rewrite map for key ${id}...";
    foreach ($map/rewrite/map/url[@name=$id]) {
      $id_map = { $id_maps->{$id}={} };
      my $base = string(../@base-dir);
      if ($base='.') $base = { use Cwd; getcwd() };

      my $main = string(@main);
      unless { $main=~m{^/|^[[:alnum:]]+:} } $main = {$base.'/'.$main};
      perl { $doc_map->{$id} = [$main,literal('.')] };
      my $search = string(@search);

      my $title_map = { $title_maps->{$id}={} };
      unless { $search eq '' or $search=~m{^/|^[[:alnum:]]+:} } $search={$base.'/'.$search};
      my $base_dir = string(@base-dir);
      unless { $base_dir eq '' or $base_dir=~m{^/|^[[:alnum:]]+:} } {
 	$base_dir={ $base.'/'.$base_dir };
      }
      spit "[Id: ${id}, Main: ${main}, Search: ${search}]";
      my $files = { ($search =~ /^[[:alnum:]]+:/) ? [$search] : ($search ne "" ? [glob($search)] : [])};
      if {@$files} {
	foreach my $f in { @$files } {
 	  my $base_f = $f;
 	  my $real_f = $f;
          if { $base_dir ne ''} {
 	    if { $base_dir=~/^[[:alnum:]]+:/ } {
	      $real_f={(File::Spec->splitpath($f))[2]};
	      $real_f=concat($base_dir,'/',$real_f);
	    } else {
	      $base_f={(File::Spec->splitpath($f))[2]};
	      $base_f=concat($base_dir,'/',$base_f);
	      $real_f=$base_f;
	    }
	  }
	  spit "Parsing: ${f} as ${base_f}, real is ${real_f}";
 	  try {
	    try {
	      open --format xml $f;
	    } catch {
	      open --recover --format html $f;
	    }
 	    my $refs=0;
 	    foreach (//*[name()='a' and (@name or @id)]) {
 	      my $name = string((@name|@id)[1]);
 	      my $title = string((parent::*|following-sibling::*)[xsh:matches(name(),'^h\d$')][1]);
 	      perl { 
 		  $id_map->{ $name } = $real_f;
 		  $title_map->{ $name } = $title;
 		  $refs++ 
 		};
 	    }
 	    spit { "$refs target(s) in $f $id" };
 	  } catch {
 	    echo :e  "Did not find: ${f}";
 	  }
 	}
      } else {
	echo :e "Didn not find: ${search}";
      }
    }
    spit "-------------------------------------------------------------------";
  }
  return { $id_map }
}

spit "Rewriting ...";

my $files = {
  shift @ARGV;
  @ARGV ? [@ARGV] :
  do {
    open my $find, 'find . -name "*.html" -or -name "*.xhtml" |';
    my @files = <$find>;
    chomp @files;
    \@files;
  };
};

foreach my $f in { @$files } {
  try {
    try {
      open --format xml $f;
    } catch {
      open --format html $f;
    };
    my $dir = { (File::Spec->splitpath($f))[1] };
    if ($dir='') $dir = {`pwd`};
    perl { chomp $dir };
    spit { "DIR: $dir ($f)"};
    foreach (//*[name()='a' and starts-with(@href,'rewrite:')]|//ulink[starts-with(@url,'rewrite:')]) {
      my $attr=@href|self::ulink/@url;
      my $uri = substring-after($attr,'rewrite:');
      spit "REWRITE: '${uri}'";
     if (contains($uri,'#')) {
	my $rewrite = substring-before($uri,'#');
	my $id = substring-after($uri,'#');
	my $id_map := index_doc $rewrite;
	if { ref $id_map } {
	  if { $id_maps->{$rewrite}{$id} } {
	    if (.=$attr or .='') {
	      delete text();
	      insert text { $title_maps->{$rewrite}{$id} } into .;
	    };
	    my $rf = { $id_map->{$id} };
	    insert text { ($rf=~/^[[:alnum:]]+:/ ? $rf : File::Spec->abs2rel($rf,$dir)).'#'.$id } into $attr;
	    spit { "$uri\t->\t$id_maps->{$rewrite}{$id}#$id ($title_maps->{$rewrite}{$id})" };
	  };
	} else {
	  echo :e "No mapping for: '${rewrite}'";
	}
      } else {
 	index_doc $uri;
 	if { $doc_map->{$uri}[0] ne '' } {
	  if (.='' or .=$attr) {
	    delete text();
	    insert text { $doc_map->{$uri}[1] } into .;
	  }
	  insert text { 
	    my $rf = $doc_map->{$uri}[0];
	    my $target = ($rf=~/^[[:alnum:]]+:/ ? $rf : File::Spec->abs2rel($rf,$dir));
	    $target .= '/' if $target!~m{/$} and $doc_map->{$uri}[0]=~m{/$};
	    $target
	  } into $attr;
 	}
      }
    }
    if (html) {
      save --format html;
    } else {
      # create a/@name for every a/@id in XHTML
      if (xhtml:html) foreach //xhtml:a[@id and not(@href) and not(@name)] cp xsh:new-attribute('name',@id) into .;
      save;
    }
  } catch my $error {
    echo :e {"Remap failed: $error"};
  }
}
spit "-------------------------------------------------------------------";
