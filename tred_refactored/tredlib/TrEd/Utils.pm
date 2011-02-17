package TrEd::Utils;
# pajas@ufal.ms.mff.cuni.cz          28 uno 2007

use 5.008;
use strict;

use Carp;
use Data::Dumper;
use List::Util qw(first min max);
use File::Spec;
use URI::Escape;
require Exporter;

our @ISA = qw(Exporter);
use vars qw(@stylesheetPaths $defaultStylesheetPath);
use constant {
  STYLESHEET_FROM_FILE  => "<From File>",
  NEW_STYLESHEET        => "<New From Current>",
  DELETE_STYLESHEET     => "<Delete Current>",
  
  EMPTY                 => "",
};

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use TrEd::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  @stylesheetPaths
  $defaultStylesheetPath
  fetch_from_win32_reg
  find_win_home
  loadStyleSheets
  initStylesheetPaths
  readStyleSheets
  saveStyleSheets
  removeStylesheetFile
  readStyleSheetFile
  saveStyleSheetFile
  getStylesheetPatterns
  setStylesheetPatterns
  updateStylesheetMenu
  getStylesheetMenuList
  applyFileSuffix
  parseFileSuffix
  getNodeByNo
  applyWindowStylesheet
  setFHEncoding

  STYLESHEET_FROM_FILE
  NEW_STYLESHEET
  DELETE_STYLESHEET
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.01';

#######################################################################################
# Usage         : fetch_from_win32_reg_old('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry, 
# Returns       : Value read or undef when the key was not found
# Parameters    : string $registry, string $key[, string $subkey]
# Throws        : no exceptions
# Comments      : Requires Win32::Registry; Now obsolete, just for testing purposes, see newer version: fetch_from_win32_reg
# See Also      : fetch_from_win32_reg
sub fetch_from_win32_reg_old {
  my ($registry,$key,$subkey)=@_;
  my ($reg,%data);

  require Win32::Registry;
  {
    no strict;
    ${"::".$registry}->Open($key,$reg);
  }
  if ($reg) {
    $reg->GetValues(\%data);
    return $data{"$subkey"}[2];
  }
  return undef;
}

######################################################################################
# Usage         : fetch_from_win32_reg('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry, 
# Returns       : Value read or undef when the key was not found
# Parameters    : string $registry, string $key[, string $subkey]
# Throws        : no exceptions
# Comments      : Requires Win32::TieRegistry
# See Also      : fetch_from_win32_reg_old, Win32::TieRegistry (cpan)
sub fetch_from_win32_reg_2 {
  my ($registry,$key,$subkey)=@_;

  my $reg_ref;
  my $delimiter = "\\";
  require Win32::TieRegistry;
  import Win32::TieRegistry ( Delimiter=>$delimiter, ArrayValues=>1, DWordsToHex=>1, TiedRef => \$reg_ref, "REG_DWORD");
  my $query = ($registry . $delimiter . $key . $delimiter);
  # if subkey is not defined, we have to use one more delimiter to let the module know, we want the default value
  if(defined($subkey)){
    $query .= $subkey;
  } else {
    $query .= $delimiter;
  }
  # Array returned by the registry reader:
  # array_ref->[0] == value
  # array_ref->[1] == type
  my $value_array_ref = $reg_ref->{$query};
  if (defined $value_array_ref) { 
    # print "key was found.\n";
  } else {
    # print "key not found.\n";
    return undef;
  }
  # to be coherent with the old version, which returns decimal instead of hexadecimal value   
  return ($value_array_ref->[1] == REG_DWORD()) ? hex($value_array_ref->[0]) : $value_array_ref->[0];
}

######################################################################################
# Usage         : find_win_home()
# Purpose       : Set 'HOME' environment variable on Windows to user's AppData 
# Returns       : nothing
# Parameters    : no
# Throws        : a string; dies if the 'HOME' env variable is not set and AppData could not be read from the registry 
# Comments      : Requires Win32::TieRegistry indirectly
# See Also      : fetch_from_win32_reg, Win32::TieRegistry (cpan)
sub find_win_home {
  # in Windows, if HOME not defined, use user's AppData folder instead
  if ($^O eq "MSWin32" and !exists($ENV{HOME})) {
    my $key = q(Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders);
    my $home = fetch_from_win32_reg
      ('HKEY_CURRENT_USER',
     $key,
       'AppData');
    if (defined($home)) {
      $ENV{HOME}= $home;
    } else {
      croak("Couldn't fetch $key from Win32 registry: $^E\n");
    }
  }
}

sub saveStyleSheetFile {
  my ($gui,$dir,$name)=@_;
  if (-f $dir) {
    # old interface
    return saveStyleSheets($gui,$dir);
  }
  unless (-d $dir) {
    mkdir $dir || do {
      print STDERR "Cannot create styleheet directory: $dir: $!";
      return 0
    };
  }
  my $stylesheetFile = File::Spec->catfile($dir,URI::Escape::uri_escape_utf8($name));
  open my $f, '>:utf8',$stylesheetFile || do {
    print STDERR "cannot write to stylesheet file: $stylesheetFile: $!\n";
    return 0;
  };
  my $s = $gui->{stylesheets}->{$name};
  if (defined($s->{context}) and $s->{context} =~ /\S/) {
    $s->{context}=~s/^\s+|\s+$//g;
    print $f "context: ".$s->{context}."\n";
  }
  print $f map { /\n\s*$/ ? $_ : $_."\n" } @{$s->{patterns}}
    if ref($s->{patterns});
  print $f "\nhint:". $s->{hint} if defined($s->{hint}) and length($s->{hint});
  close $f;
}

sub readStyleSheetFile {
  my ($gui,$stylesheetFile,$opts)=@_;
  $opts||={};
  my (undef,undef,$f) = File::Spec->splitpath($stylesheetFile);
  my $name = URI::Escape::uri_unescape($f);
  my $ss =  $gui->{stylesheets}||={};
  return if $opts->{no_overwrite} and grep /^\Q$name\E$/i, keys %$ss;
  open my $f, '<:utf8',$stylesheetFile || do {
    print STDERR "cannot read stylesheet file: $stylesheetFile: $!\n";
    return;
  };
  my $s = $ss->{$name} ||= {};
  local $/;
  ($s->{hint},$s->{context},$s->{patterns})=splitPatterns(<$f>);
  close $f;

  return $s;
}

sub removeStylesheetFile {
  my ($gui,$path,$name)=@_;
  if (-d $path) {
    my $stylesheetFile = File::Spec->catfile($path,URI::Escape::uri_escape_utf8($name));
    if (-f $stylesheetFile) {
      delete $gui->{stylesheets}->{$name};
      unlink $stylesheetFile.'~';
      rename $stylesheetFile, $stylesheetFile.'~';
    }
  } elsif (-f $path) {
    delete $gui->{stylesheets}->{$name};
    saveStyleSheets($gui,$path);
  }
}

sub saveStyleSheets {
  my ($gui,$where)=@_;
  if (-d $where || ! -e $where) {
    if (!-d $where) {
      mkdir $where || do {
	print STDERR "cannot create stylesheet directory: $where: $!\n";
	return 0;
      };
    }
    foreach my $stylesheet (keys (%{$gui->{stylesheets}})) {
      next if $stylesheet eq STYLESHEET_FROM_FILE();
      saveStyleSheetFile($gui,$where,$stylesheet);
    }
  } else {
    open my $f, '>:utf8',$where || do {
      print STDERR "cannot write to stylesheet file: $where: $!\n";
      return 0;
    };
    foreach my $stylesheet (sort keys (%{$gui->{stylesheets}})) {
      next if $stylesheet eq STYLESHEET_FROM_FILE();
      print $f "#"x 50,"\n";
      print $f "stylesheet: $stylesheet\n";
      for ($gui->{stylesheets}->{$stylesheet}) {
	if ($_->{context} =~ /\S/) {
	  print $f map { "context: ".$_."\n" } split /\n/, $_->{context};
	}
	print $f map { local $_=$_; tr/\n/\013/; $_."\n" } 
	  map { /^#/ ? 'node:'.$_ : $_ } @{$_->{patterns}};
	print $f map { 'hint:'.$_."\n" } split /\n/, $_->{hint};
      }
      print $f "\n\n";
    }
    close $f;
  }
}

sub readStyleSheets {
  my ($gui,$file,$opts)=@_;
  if (-f $file) {
    readStyleSheetsOld($gui,$file,$opts);
  } elsif (-d $file) {
    readStyleSheetsNew($gui,$file,$opts);
  }
}


sub readStyleSheetsNew {
  my ($gui,$dir,$opts)=@_;
  $opts||={};
  opendir(my $dh, $dir) || do {
    print STDERR "cannot read stylesheet directory: $dir: $!\n";
    return 0;
  };
  $gui->{stylesheets}={} unless $opts->{no_overwrite};
  while (my $f = readdir($dh)){
    next if $f =~ /~$|^#|#$|^\./;
    my $stylesheetFile = File::Spec->catfile($dir,$f);
    next unless -f $stylesheetFile;
    readStyleSheetFile($gui,$stylesheetFile,$opts);
  }
  return 1;
}

sub readStyleSheetsOld {
  my ($gui,$filename,$opts)=@_;
  open my $f, '<:utf8',$filename || do {
    print STDERR "no stylesheet file: $filename\n";
    return 0;
  };
  my $stylesheet="Default";
  $gui->{stylesheets}={} unless $opts and $opts->{no_overwrite};
  while (<$f>) {
    s/\s+$//;
    next unless /\S/;
    next if /^#/;
    if (/^stylesheet:\s*(.*)/) {
      $stylesheet = $1;
    } elsif (s/^(hint|context)://) {
      if ($gui->{stylesheets}->{$stylesheet}->{$1} ne qw()) {
	$gui->{stylesheets}->{$stylesheet}->{$1}.="\n".$_;
      } else {
	$gui->{stylesheets}->{$stylesheet}->{$1}.=$_;
      }
    } else {
      tr/\013/\n/;
      push @{$gui->{stylesheets}->{$stylesheet}->{patterns}},$_;
    }
    chomp $gui->{stylesheets}{$stylesheet}{$_} for qw(hint context);
  }
  close $f;
  return 1;
}

sub getStylesheetPatterns {
  my ($win,$stylesheet)=@_;
  my ($hint,$context,$patterns);
  $patterns = [];
  $stylesheet = $win->{stylesheet} unless defined $stylesheet;
  if ($stylesheet eq STYLESHEET_FROM_FILE()) {
    if ($win->{FSFile}) {
      $hint = $win->{FSFile}->hint();
      $context = undef;
      @$patterns = $win->{FSFile}->patterns()
    } else {
      return ();
    }
  } else {
    my $s=$win->{framegroup}->{stylesheets}->{$stylesheet};
    if (ref($s)) {
      $hint = $s->{hint};
      $context = $s->{context};
      $context = '.*' unless (wantarray or $context =~ /\S/);
      chomp $context;
      @$patterns = defined($s->{patterns}) ? @{$s->{patterns}} : ();
    } else {
      return ();
    }
  }
  # try to fix old non-labeled patterns
  @$patterns = map { /^([a-z]+):/ ? $_ : "node: ".$_ } @$patterns;
  return wantarray ? ($hint,$context,$patterns) :
    ("context: ".$context."\n".
       # fix old non-labeled hints
       join("\n","hint: ".$hint)."\n".
	 join("\n",@$patterns));
}

sub setStylesheetPatterns {
  my ($win,$text,$stylesheet,$create)=@_;
  my $grp = $win->{framegroup};
  my ($hint,$context,$patterns);
  if (ref($text)) {
    ($hint,$context,$patterns)=@$text;
  } else {
    ($hint,$context,$patterns)=splitPatterns($text);
  }
  $stylesheet = $win->{stylesheet} unless defined $stylesheet;
  if ($stylesheet eq STYLESHEET_FROM_FILE()) {
    if ($win->{FSFile}) {
      $win->{FSFile}->changeHint($hint);
      $win->{FSFile}->changePatterns(@$patterns);
    } else {
      return 0;
    }
  } else {
    my $s=$grp->{stylesheets}->{$stylesheet};
    if (ref($s)) {
      @{$s->{patterns}} = @$patterns;
      $s->{hint} = $hint;
      $s->{context} = $context;
    } elsif ($create) {
      $grp->{stylesheets}->{$stylesheet}->{patterns}=[@$patterns];
      $grp->{stylesheets}->{$stylesheet}->{hint}=$hint;
      $grp->{stylesheets}->{$stylesheet}->{context}=$context;
      updateStylesheetMenu($grp);
    } else {
      return 0;
    }
  }
  return 1;
}

sub updateStylesheetMenu {
  my ($grp)=@_;
  return if $grp->{noUpdateStylesheetMenu};
  if (ref($grp->{StylesheetMenu})) {
    $grp->{StylesheetMenu}->configure(-options => getStylesheetMenuList($grp));
  }
}

sub getStylesheetMenuList {
  my ($grp,$all)=@_;
  my $context=$grp->{focusedWindow}->{macroContext};
  undef $context if $context eq 'TredMacro';
  my $match;
  [STYLESHEET_FROM_FILE(),NEW_STYLESHEET(),DELETE_STYLESHEET(),
   grep { 
     if ($all or !defined($context)) { 1 } else {
       $match = $grp->{stylesheets}{$_}{context};
       chomp $match;
       $match = '.*' unless $match =~ /\S/;
       $context =~ /^${match}$/x ? 1 : 0;
     }
   } sort keys %{$grp->{stylesheets}}];
}

sub applyWindowStylesheet {
  my ($win,$stylesheet)=@_;
  return unless $win;
  my $s=$win->{framegroup}->{stylesheets}->{$stylesheet};
  if ($stylesheet eq STYLESHEET_FROM_FILE()) {
    $win->{treeView}->set_patterns(undef);
    $win->{treeView}->set_hint(undef);
  } else {
    if ($s) {
      $win->{treeView}->set_patterns($s->{patterns});
      $win->{treeView}->set_hint(\$s->{hint});
    }
  }
  $win->{stylesheet}=$stylesheet;
}

sub splitPatterns {
  my ($text)=@_;
  my @lines = split /(\n)/,$text;
  my @result;
  my $pattern = EMPTY;
  my $hint = EMPTY;
  my $context;
  while (@lines) {
    my $line = shift @lines;
    if ($line=~/^([a-z]+):/) {
      if ($pattern =~ /\S/) {
	chomp $pattern;
	if ($pattern=~s/^hint:\s*//) {
	  $hint .= "\n" if $hint ne EMPTY;
	  $hint .= $pattern;
	} elsif ($pattern=~s/^context:\s*//) {
	  $context = $pattern;
	  chomp $context;
	} else {
	  push @result, $pattern;
	}
      }
      $pattern = $line;
    } else {
      $pattern.=$line;
    }
  }
  if ($pattern =~ /\S/) {
    chomp $pattern;
    if ($pattern=~s/^hint:\s*//) {
      $hint .= "\n" if $hint ne EMPTY;
      $hint .= $pattern;
    } else {
      push @result, $pattern;
    }

  }
  return $hint,$context,\@result;
}

sub parseFileSuffix {
  my ($filename)=@_;
  if ($filename=~s/(##?[0-9A-Z]+(?:-?\.[0-9]+)?)$// ) {
    return ($filename,$1);
  } elsif ($filename=~/^(.*)(##[0-9]+\.)([^0-9#][^#]*)$/ and Treex::PML::Schema::CDATA->check_string_format($3,'ID')) {
    return ($1,$2.$3);
  } elsif ($filename=~/^(.*)#([^#]+)$/ and Treex::PML::Schema::CDATA->check_string_format($2,'ID')) {
    return ($1,'#'.$2);
  } else {
    return ($filename,undef);
  }
}

sub applyFileSuffix {
  my ($win,$goto)= @_;
  return unless $win;
  my $fsfile = $win->{FSFile};
  return unless $fsfile and defined($goto) and $goto ne EMPTY;

  if ($goto=~/^##([0-9]+)/) {
    my $no = int($1 - 1);
    $win->{treeNo}=min(max(0,$no),$fsfile->lastTreeNo);
    return 0 if $win->{treeNo} != $no;
  } elsif ($goto=~/^#([0-9]+)/) {
    # this is PDT 1.0-specific code, sorry
    my $no;
    for (my $i=0;$i<=$fsfile->lastTreeNo;$i++) {
      if ($fsfile->treeList->[$i]->{form} eq "#$1") {
	$no=$i; last;
      }
    }
    return 0 unless defined $no;
    $win->{treeNo}=$no;
  } elsif ($goto=~/^#([^#]+)$/) {
    my $id = $1;
    if (Treex::PML::Schema::CDATA->check_string_format($id,'ID')) {
      my $id_hash = $fsfile->appData('id-hash');
      if (UNIVERSAL::isa($id_hash,'HASH') and exists($id_hash->{$id})) {
	my $node = $id_hash->{$id};
	# we would like to use Treex::PML::Index() here, but can't
	my $list = $fsfile->treeList;
	my $root = UNIVERSAL::can($node,'root') && $node->root;
	my $n = defined($root) && first {
	  $list->[$_]==$root;
	} 0..$#$list;
	if ($root and !defined($n)) {
	  # hm, we have a node, but don't know to which tree
	  # it belongs
	  my $trees_type = $fsfile->metaData('pml_trees_type');
	  my $root_type = $root->type;
	  if ($trees_type and $root_type) {
	    my $trees_type_is = $trees_type->get_decl_type;
	    my %paths;
	    my $is_sequence;
	    my $found;
	    my @elements;
	    if ($trees_type_is == Treex::PML::Schema::PML_LIST_DECL()) {
	      @elements = ['LM',$trees_type->get_content_decl];
	    } elsif ($trees_type_is == Treex::PML::Schema::PML_SEQUENCE_DECL()) {
	      @elements = map { [$_->get_name,$_->get_content_decl] } $trees_type->get_elements;
	      $is_sequence=1;
	    } else {
	      return 0;
	    }
	    for my $el (@elements) {
	      $paths{$el->[0]} = [$trees_type->get_schema->find_decl(
		sub {
		  $_[0] == $root_type
		}, $el->[1],{})];
	      $found = 1 if @{ $paths{$el->[0]} };
	    }
	    return 0 unless $found;
	    TREE:
	    for my $i (0..$#$list) {
	      my $tree = $list->[$i];
	      my $paths = $is_sequence ? $paths{$tree->{'#name'}} : $paths{LM};
	      for my $p (@{$paths||[]}) {
		for my $value ($tree->all($p)) {
		  if ($value == $root) {
		    $n = $i;
		    last TREE;
		  }
		}
	      }
	    }
	  }
	}
	if (defined($n)) {
	  $win->{treeNo}=$n;
	  $win->{currentNode}=$node;
	  return 1;
	} else {
	  return 0;
	}
      }
    }
  }
  # new: we're the dot in .[0-9]+ (TM)
  if ($goto=~/\.([0-9]+)$/) {
    my $root=getNodeByNo($win,$1);
    if ($root) {
      $win->{currentNode}=$root;
      return 1;
    } else {
      return 0;
    }
  } elsif ($goto=~/\.([^0-9#][^#]*)$/) {
    my $id = $1;
    if (Treex::PML::Schema::CDATA->check_string_format($id,'ID')) {
      my $id_hash = $fsfile->appData('id-hash');
      if (UNIVERSAL::isa($id_hash,'HASH') and exists($id_hash->{$id})) {
	return 1 if ($win->{currentNode}=$id_hash->{$id}); # assignment
      } else {
	return 0;
      }
    }
  }
  return 1;
  # hey, caller, you should redraw after this!
}

sub getNodeByNo {
  my ($win,$no)=@_;
  my $root=$win->{FSFile}->treeList->[$win->{treeNo}];
  my $i=$no;
  while ($root and $i>0) {
    $i--;
    $root=$root->following();
  }
  return $root;
}

sub initStylesheetPaths{
  my ($userPaths)=@_;
  $defaultStylesheetPath = $ENV{HOME}."/.tred-stylesheets";
  my $stylesheetDir = File::Spec->catfile($ENV{HOME},'.tred.d','stylesheets');
  if (!-d $stylesheetDir and -f $defaultStylesheetPath) {
    print STDERR "Converting old stylesheets from $defaultStylesheetPath to $stylesheetDir...\n";
    my $gui = { stylesheets => {} };
    readStyleSheets($gui,$defaultStylesheetPath);
    if (mkdir $stylesheetDir) {
      saveStyleSheets($gui,$stylesheetDir);
      print STDERR "done.\n";
    } else {
      print STDERR "failed to create $stylesheetDir: $!.\n";
      $stylesheetDir=$defaultStylesheetPath;
    }
  }
  $defaultStylesheetPath=$stylesheetDir if -d $stylesheetDir;
  my %uniq;
  if (ref($userPaths) and @$userPaths) {
    @stylesheetPaths = grep { !($uniq{$_}++) } ( (map { length($_) ? $_ : ($defaultStylesheetPath) } @$userPaths), @stylesheetPaths ),
    $defaultStylesheetPath=$stylesheetPaths[0];
  } else {
    @stylesheetPaths = grep { !($uniq{$_}++) } ($defaultStylesheetPath,@stylesheetPaths);
  }
}

sub loadStyleSheets {
  my ($gui)=@_;
  my $later=0;
  for my $p (@stylesheetPaths) {
    readStyleSheets($gui, $p, {no_overwrite=>$later});
    $later=1;
  }
}

#######################################################################################
# Usage         : setFHEncoding(\*STDOUT, ':utf8', "STDOUT")
# Purpose       : Set encoding on a file handle  
# Returns       : nothing
# Parameters    : filehandle $fh, string $encoding, string $what
# Throws        : a string; When binmode or flush call fails
# Comments      : Be careful, don't use :utf8 on input files and STDIN (http://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8);
#                 It seems that the third parameter is not used in the sub, why is it here?
# See Also      : binmode (perldoc)
#TODO: mixing of camel and underscore, should be used in a coherent manner...
sub setFHEncoding {
  my ($fh, $enc, $what)=@_;
  return unless $enc;
  $fh->flush()
    or croak("Could not flush $what");
  # first get rid of all I/O layers
  binmode($fh)
    or croak("Could not set binmode on $what");
  
  if ($enc =~ /^:/) {
    binmode($fh,$enc)
      or croak("Could not use binmode to set encoding to $enc on $what");
  } else {
    binmode($fh,":encoding($enc)")
      or croak("Could not use binmode to set encoding to $enc on $what");
  }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::Utils - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::Utils;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::Utils, 
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

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

