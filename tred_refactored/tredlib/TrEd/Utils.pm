package TrEd::Utils;
# pajas@ufal.ms.mff.cuni.cz          28 uno 2007

use 5.008;
use strict;

use Carp;
#use Data::Dumper;
use List::Util qw(first min max);
use File::Spec;
use URI::Escape;
use Treex::PML::Schema::CDATA;
require Exporter;

use TrEd::Basics qw{$EMPTY_STR};

use base qw(Exporter);
use vars qw(@stylesheet_paths $default_stylesheet_path);
use constant {
  STYLESHEET_FROM_FILE  => "<From File>",
  NEW_STYLESHEET        => "<New From Current>",
  DELETE_STYLESHEET     => "<Delete Current>",
};

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use TrEd::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  @stylesheet_paths
  $default_stylesheet_path
  fetch_from_win32_reg
  find_win_home
  loadStyleSheets
  init_stylesheet_paths
  read_stylesheets
  save_stylesheets
  removeStylesheetFile
  read_stylesheet_file
  save_stylesheet_file
  getStylesheetPatterns
  setStylesheetPatterns
  updateStylesheetMenu
  getStylesheetMenuList
  applyFileSuffix
  parse_file_suffix
  getNodeByNo
  applyWindowStylesheet
  set_fh_encoding

  STYLESHEET_FROM_FILE
  NEW_STYLESHEET
  DELETE_STYLESHEET
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.02';

#######################################################################################
# Usage         : fetch_from_win32_reg_old('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry 
# Returns       : Value from the registry key or undef when the key was not found
# Parameters    : string $registry  -- name of the registry (HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER, etc), 
#                 string $key       -- name of the key (backslash-delimited)
#                 [string $subkey]  -- optional -- subkey name
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
  return;
}

######################################################################################
# Usage         : fetch_from_win32_reg('HKEY_LOCAL_MACHINE', q(SOFTWARE\Classes\.html)[, $subkey])
# Purpose       : Read a value from windows registry
# Returns       : Value read or undef when the key was not found
# Parameters    : string $registry  -- name of the registry (HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER, etc), 
#                 string $key       -- name of the key (backslash-delimited)
#                 [string $subkey]  -- optional -- subkey name
# Throws        : no exceptions
# Comments      : Requires Win32::TieRegistry
# See Also      : fetch_from_win32_reg_old, Win32::TieRegistry (cpan)
sub fetch_from_win32_reg {
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
    return;
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
      $ENV{HOME} = $home;
    }
    else {
      croak("Couldn't fetch $key from Win32 registry: $^E\n");
    }
  }
}

######################################################################################
# Usage         : save_stylesheet_file(\%gui, $dir_name, $file_name)
# Purpose       : Save stylesheet $name to file $name under directory $dir_name or 
#                 call save_stylesheets() if $dir is a file, not a directory 
# Returns       : Zero if the directory could not be created or the file could not be opened for writing
# Parameters    : hash_ref $gui_ref -- hash should contain subkey 'stylesheets', subkeys of 'stylesheets' are the names of the stylesheets
#                                      these should contain 3 subkeys: 'context', 'hint', 'patterns'. First two are strings, the last one
#                                      should be an array_ref containing other stylesheet items
#                 string $dir_name  -- the stylesheet will be saved to the directory $dir_name
#                 string $file_name -- both the name of the stylesheet file and the subkey in %gui hash
# Throws        : no exceptions
# Comments      : 
# See Also      : save_stylesheets()
sub save_stylesheet_file {
  my ($gui_ref, $dir, $name)=@_;
  if (-f $dir) {
    # old interface
    return save_stylesheets($gui_ref, $dir);
  }
  if (! -d $dir) {
    mkdir $dir || do {
      carp("Cannot create styleheet directory: $dir: $!");
      return 0
    };
  }
  my $stylesheet_file = File::Spec->catfile($dir, URI::Escape::uri_escape_utf8($name));
  open(my $f, '>:utf8', $stylesheet_file) || do {
    carp("Cannot write to stylesheet file: $stylesheet_file: $!\n");
    return 0;
  };
  my $current_stylesheet = $gui_ref->{"stylesheets"}->{$name};
  # print context
  if (defined($current_stylesheet->{"context"}) and $current_stylesheet->{"context"} =~ /\S/) {
    # context is valid
    # get rid of leading and trailing whitespace
    $current_stylesheet->{"context"} =~ s/^\s+|\s+$//g;
    print $f "context: ".$current_stylesheet->{"context"}."\n";
  }
  # print patterns
  if (ref($current_stylesheet->{"patterns"})){
    print $f map { /\n\s*$/ ? $_ : $_."\n" } @{$current_stylesheet->{"patterns"}};
  }
  # print hint
  if (defined($current_stylesheet->{"hint"}) and length($current_stylesheet->{"hint"})){
    print $f "\nhint:". $current_stylesheet->{"hint"};
  }
  close $f;
  return;
}

######################################################################################
# Usage         : read_stylesheet_file(\%gui, $stylesheet_file[, \%opts])
# Purpose       : Load options from $stylesheet_file to \%gui hash_reference 
# Returns       : Sub-hash of %gui: gui{"stylesheets"}{$file_name} or 
#                 undef if stylesheet_file could not be opened or 
#                 if %opts{"no_overwrite"} is set and %gui{"stylesheets"}{$file_name} has already been defined
# Parameters    : hash_ref $gui_ref, 
#                 string $stylesheet_file,
#                 [hash_ref $opts_ref]
# Throws        : no exceptions 
# Comments      : 
# See Also      : read_stylesheets(), split_patterns()
sub read_stylesheet_file {
  my ($gui_ref, $stylesheet_file, $opts_ref)=@_;
  $opts_ref ||= {};
  my (undef,undef,$f) = File::Spec->splitpath($stylesheet_file);
  my $name = URI::Escape::uri_unescape($f);
  my $ss_ref = $gui_ref->{"stylesheets"} ||= {};
  return if $opts_ref->{"no_overwrite"} and grep { /^\Q$name\E$/i } keys %{$ss_ref};
  open my $filehandle, '<:encoding(utf8)', $stylesheet_file || do {
    carp("cannot read stylesheet file: $stylesheet_file: $!\n");
    return;
  };
  my $s_ref = $ss_ref->{$name} ||= {};
  local $/;
  ($s_ref->{"hint"}, $s_ref->{"context"}, $s_ref->{"patterns"}) = split_patterns(<$filehandle>);
  close $filehandle;
  return $s_ref;
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
    save_stylesheets($gui,$path);
  }
  return;
}

######################################################################################
# Usage         : save_stylesheets(\%gui, $destination)
# Purpose       : Save stylesheets from the hash reference \%gui to $destination on the hdd
# Returns       : Zero if the destination directory could not be created or if the file could not be opened
#                 Returns the return value of save_stylesheet_file() or close() function otherwise.
# Parameters    : hash_ref $gui_ref   -- reference to hash that contains stylesheets, 
#                 string $destination -- name of the file or directory
# Throws        : no exceptions 
# Comments      : Supports both new and old stylesheets
# See Also      : save_stylesheet_file()
sub save_stylesheets {
  my ($gui, $where)=@_;
  if (-d $where || ! -e $where) {
    if (! -d $where) {
      mkdir $where || do {
        carp("cannot create stylesheet directory: $where: $!\n");
        return 0;
      };
    }
    foreach my $stylesheet (keys (%{$gui->{"stylesheets"}})) {
      next if($stylesheet eq STYLESHEET_FROM_FILE());
      save_stylesheet_file($gui, $where, $stylesheet);
    }
  } else {
    # $where is not a directory, and it is a file
    open(my $f, '>:utf8', $where) || do {
      carp("cannot write to stylesheet file: $where: $!\n");
      return 0;
    };
    # obsolete way -- write all stylesheets into one file
    foreach my $stylesheet (sort keys (%{$gui->{"stylesheets"}})) {
      next if($stylesheet eq STYLESHEET_FROM_FILE());
      print $f "#"x 50,"\n";
      print $f "stylesheet: $stylesheet\n";
      for ($gui->{"stylesheets"}->{$stylesheet}) {
        if ($_->{"context"} =~ /\S/) {
          print $f map { "context: ".$_."\n" } split /\n/, $_->{"context"};
        }
        print $f map { local $_=$_; tr/\n/\013/; $_."\n" } 
                      map { /^#/ ? 'node:'.$_ : $_ } @{$_->{patterns}};
        print $f map { 'hint:'.$_."\n" } split /\n/, $_->{"hint"};
      }
      print $f "\n\n";
    }
    close $f;
  }
  return;
}

######################################################################################
# Usage         : read_stylesheets(\%gui, $file[, $options])
# Purpose       : Calls read_stylesheets_old if $file is a regular file, 
#                 Calls read_stylesheets_new if $file is a directory.
# Returns       : Return value from the called function 
# Parameters    : hash_ref $gui_ref, 
#                 string $file_name, 
#                 [hash_ref $opts_ref]
# Throws        : no exceptions 
# Comments      : 
# See Also      : read_stylesheets_new(), read_stylesheets_old()
sub read_stylesheets {
  my ($gui_ref, $file, $opts_ref)=@_;
  if (-f $file) {
    return read_stylesheets_old($gui_ref, $file, $opts_ref);
  } elsif (-d $file) {
    return read_stylesheets_new($gui_ref, $file, $opts_ref);
  }
}

######################################################################################
# Usage         : read_stylesheets_new(\%gui, $dir_name, \%opts)
# Purpose       : Load all the stylesheets in the $dir_name directory into %gui hash
# Returns       : Zero if the $dir_name could not be opened, 1 otherwise
# Parameters    : hash_ref $gui_ref, 
#                 string $dir_name, 
#                 hash_ref $opts_ref
# Throws        : no exceptions 
# Comments      : Skips files with names starting with '#', '.', or ending with '#', '~'
# See Also      : read_stylesheets()
sub read_stylesheets_new {
  my ($gui_ref, $dir, $opts_ref)=@_;
  $opts_ref ||= {};
  opendir(my $dh, $dir) || do {
    carp("Can not read stylesheet directory: '$dir'\n $!\n");
    return 0;
  };
  $gui_ref->{"stylesheets"}={} unless $opts_ref and $opts_ref->{"no_overwrite"};
  while (my $file = readdir($dh)){
    # skip files with names starting with '#' and '.' or ending with '#' or '~'
    next if $file =~ /~$|^#|#$|^\./;
    my $stylesheet_file = File::Spec->catfile($dir, $file);
    next unless -f $stylesheet_file;
    read_stylesheet_file($gui_ref, $stylesheet_file, $opts_ref);
  }
  return 1;
}

######################################################################################
# Usage         : read_stylesheets_old(\%gui, $filename[, \%opts])
# Purpose       : Load old-style stylesheets from stylesheet file into %gui hash
# Returns       : If the file could not be opened, returns 0, 
#                 1 otherwise
# Parameters    : hash_ref $gui_ref, 
#                 string $filename, 
#                 [hash_ref $opts_ref]
# Throws        : no exceptions 
# Comments      : Changed :utf8 to :encoding(utf8), see 
#                 http://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8#Input_-_Files.2C_File_Handles
# See Also      : read_stylesheets_new(), read_stylesheets()
sub read_stylesheets_old {
  my ($gui_ref, $filename, $opts_ref)=@_;
  open(my $f, '<:encoding(utf8)', $filename) || do {
    carp("No stylesheet file: '$filename'\n");
    return 0;
  };
  
  my $stylesheet="Default";
  $gui_ref->{"stylesheets"}={} unless $opts_ref and $opts_ref->{"no_overwrite"};
  while (<$f>) {
    # remove whitespace at the end of line
    s/\s+$//;
    # continue only if there are any non-whitespace characters left
    next unless /\S/;
    # skip lines starting with '#' (comments)
    next if /^#/;
    if (/^stylesheet:\s*(.*)/) {
      $stylesheet = $1;
    } elsif (s/^(hint|context)://) {
      if ($gui_ref->{"stylesheets"}->{$stylesheet}->{$1} ne qw()) {
        $gui_ref->{"stylesheets"}->{$stylesheet}->{$1}.="\n".$_;
      } else {
        $gui_ref->{"stylesheets"}->{$stylesheet}->{$1}.=$_;
      }
    } else {
      tr/\013/\n/;
      push @{$gui_ref->{stylesheets}->{$stylesheet}->{patterns}},$_;
    }
    foreach my $stylesheet_item qw(hint context) {
      chomp $gui_ref->{"stylesheets"}{$stylesheet}{$stylesheet_item};
    }
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
    ($hint,$context,$patterns)=split_patterns($text);
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

######################################################################################
# Usage         : split_patterns($text)
# Purpose       : Parse stylesheet text and divide it into hints, context and other patterns 
# Returns       : List of 3 items: two strings (hints and context) 
#                 and a referrence to array (containing other patterns)
# Parameters    : string $text -- contents of the stylesheet
# Throws        : no exceptions 
# Comments      : 
# See Also      : read_stylesheet_file(), EMPTY
#TODO: is the format of stylesheet formally defined somewhere?
sub split_patterns {
  my ($text) = @_;
  my @lines = split(/(\n)/, $text);
  my @result;
  my $pattern = $EMPTY_STR;
  my $hint = $EMPTY_STR;
  my $context;
  while (@lines) {
    my $line = shift(@lines);
    # line starts with at least one small letter (a-z) followed by ':'
    if ($line =~ /^([a-z]+):/) {
      # pattern contains non-whitespace character
      if ($pattern =~ /\S/) {
        chomp($pattern);
        if ($pattern =~ s/^hint:\s*//) {
          # 'hint' processing
          if ($hint ne $EMPTY_STR){
            $hint .= "\n" ;
          }
          $hint .= $pattern;
        } elsif ($pattern=~s/^context:\s*//) {
          # 'context' processing
          $context = $pattern;
          chomp($context);
        } else {
          # other patterns than hint or context
          push(@result, $pattern);
        }
      }
      $pattern = $line;
    } else {
      $pattern .= $line;
    }
  }
  # process the last line 
  # but the code ignores context on the last line... 
  if ($pattern =~ /\S/) {
    chomp $pattern;
    if ($pattern =~ s/^hint:\s*//) {
      $hint .= "\n" if $hint ne $EMPTY_STR;
      $hint .= $pattern;
    } else {
      push(@result, $pattern);
    }
  }
  return ($hint,$context,\@result);
}

#######################################################################################
# Usage         : parse_file_suffix($filename)
# Purpose       : Split file name into file name itself and its suffix  
# Returns       : List which contains file name and its suffix, if there is no suffix, 
#                 second list element is undef
# Parameters    : scalar $filename -- name of the file
# Throws        : no exceptions
# Comments      : File suffix can be of the following forms:
#                 a) 1 or 2 #-signs, upper-case characters or numbers, and optionally followed by 
#                     optional dash, full stop and at least one number
#                 b) 2 #-signs, at least one number, full stop, followed by 
#                     one non-numeric not-# character and any number of not-# chars
#                 c) 1 #-sign followed by any number of not-# characters
# See Also      : 
sub parse_file_suffix {
  my ($filename) = @_;
  # 
  if ($filename =~ s/(##?[0-9A-Z]+(?:-?\.[0-9]+)?)$// ) {
    return ($filename, $1);
  }
  elsif ($filename =~ m{^ 
                        (.*)               # file name with any characters followed by
                        (\#\#[0-9]+\.)       # 2x#, at least one number and full stop
                        ([^0-9\#][^\#]*)     # followed by one non-numeric not-# character and any number of not-# chars
                        $
                        }x and 
         Treex::PML::Schema::CDATA->check_string_format($3, 'ID')) {
    return ($1, $2 . $3);
  }
  elsif ($filename =~ m{^
                        (.*)        # file name with any characters followed by
                        \#          # one hash followed by
                        ([^\#]+)     # any number of not-# characters
                        $    
                        }x and 
          Treex::PML::Schema::CDATA->check_string_format($2, 'ID')) {
    return ($1, '#' . $2);
  }
  else {
    return ($filename, undef);
  }
}

#TODO: document & test this unclear function
sub _find_tree_no {
    my ($fsfile, $root, $list) = @_;
    my $n = undef;
    # hm, we have a node, but don't know to which tree
    # it belongs
    my $trees_type = $fsfile->metaData('pml_trees_type');
    my $root_type  = $root->type();
    #TODO: empty? or defined???
    if ( $trees_type and $root_type ) {
        my $trees_type_is = $trees_type->get_decl_type();
        my %paths;
        my $is_sequence;
        my $found;
        my @elements;
        if ( $trees_type_is == Treex::PML::Schema::PML_LIST_DECL() ) {
            @elements = [ 'LM', $trees_type->get_content_decl() ];
        }
        elsif ( $trees_type_is == Treex::PML::Schema::PML_SEQUENCE_DECL() ) {
            # Treex::PML::Schema::Element::get_name(), 
            #           ::Schema::Decl::get_content_decl()
            @elements = map { [ $_->get_name(), $_->get_content_decl() ] }
                        $trees_type->get_elements();
            $is_sequence = 1;
        }
        else {
            return -1;
        }
        
        for my $el (@elements) {
            $paths{ $el->[0] } = [
                $trees_type->get_schema->find_decl(
                    sub {
                        $_[0] == $root_type;
                    },
                    $el->[1],
                    {}
                )
            ];
            if (@{ $paths{ $el->[0] } }) {
                $found = 1;
            }
        }
        return -1 if !$found;
    TREE:
        for my $i ( 0 .. $#$list ) {
            my $tree = $list->[$i];
            my $paths
                = $is_sequence
                ? $paths{ $tree->{'#name'} }
                : $paths{LM};
            for my $p ( @{ $paths || [] } ) {
                for my $value ( $tree->all($p) ) {
                    if ( $value == $root ) {
                        $n = $i;
                        last TREE;
                    }
                }
            }
        }
    }
    return $n;
}

#TODO: could be renamed to use _, but it is used in Vallex extension
#######################################################################################
# Usage         : applyFileSuffix($win, $goto)
# Purpose       : Set current tree and node positions to positions described by 
#                 $goto suffix in file displayed in $win window 
# Returns       : 1 if the new position was found and set, 0 otherwise
# Parameters    : TrEd::Window $win -- reference to TrEd::Window object 
#                 string $goto      -- suffix of the file (or a position in the file)
# Throws        : no exceptions
# Comments      : Possible suffix formats:
#                   ##123.2 -- tree number 123 (if counting from 1) and its second node
#                   #123.3 -- tree whose $root->{form} equals to #123 and its third node
#                           (only hint found in Treex/PML/Backend/CSTS/Csts2fs.pm)
#                   #a123 -- finds node with id #a123 and the tree it belongs to
#                 The node's id can also be placed after the '.', e.g. ##123.#a123, in 
#                 which case the sub searches for node with id #a123 inside tree no 123
#
#                 Sets $win->{treeNo} and $win->{currentNode} if appropriate.
# See Also      : parse_file_suffix()
sub applyFileSuffix {
    my ( $win, $goto ) = @_;
    return if ( !defined $win );
    my $fsfile = $win->{FSFile};
    return if !( defined $fsfile && defined $goto && $goto ne $EMPTY_STR );

    if ( $goto =~ m/^##([0-9]+)/ ) {
        # handle cases like '##123'
        my $no = int( $1 - 1 );
        $win->{treeNo} = min( max( 0, $no ), $fsfile->lastTreeNo() );
        return 0 if $win->{treeNo} != $no;
    }
    elsif ( $goto =~ /^#([0-9]+)/ ) {
        # handle cases like '#123'
        # this is PDT 1.0-specific code, sorry
        my $no;
        for ( my $i = 0; $i <= $fsfile->lastTreeNo(); $i++ ) {
            if ( $fsfile->treeList()->[$i]->{form} eq "#$1" ) {
                $no = $i;
                last;
            }
        }
        return 0 if (!defined $no);
        $win->{treeNo} = $no;
    }
    elsif ( $goto =~ /^#([^#]+)$/ ) {
        # handle cases like '#a123'
        my $id = $1;
        if ( Treex::PML::Schema::CDATA->check_string_format( $id, 'ID' ) ) {
            my $id_hash = $fsfile->appData('id-hash');
            if ( UNIVERSAL::isa( $id_hash, 'HASH' )
                && exists $id_hash->{$id} )
            {
                my $node = $id_hash->{$id};

                # we would like to use Treex::PML::Index() here, but can't
                # and why we can not?
                my $list = $fsfile->treeList();
                my $root = UNIVERSAL::can( $node, 'root' ) && $node->root();
                my $n    = defined($root) && first {
                    $list->[$_] == $root;
                } 0 .. $#$list;
                
                if ( defined $root and !defined($n) ) {
                    $n = _find_tree_no($fsfile, $root, $list);
                    # exit from _find_tree_no() function
                    if (!defined $n || $n == -1) {
                        return 0;
                    }
                }
                if ( defined($n) ) {
                    $win->{treeNo}      = $n;
                    $win->{currentNode} = $node;
                    return 1;
                }
                else {
                    return 0;
                }
            }
        }
    }

    # new: we're the dot in .[0-9]+ (TM)
    if ( $goto =~ /\.([0-9]+)$/ ) {
        my $root = getNodeByNo( $win, $1 );
        if ($root) {
            $win->{currentNode} = $root;
            return 1;
        }
        else {
            return 0;
        }
    }
    elsif ( $goto =~ /\.([^0-9#][^#]*)$/ ) {
        my $id = $1;
        if ( Treex::PML::Schema::CDATA->check_string_format( $id, 'ID' ) ) {
            my $id_hash = $fsfile->appData('id-hash');
            if ( UNIVERSAL::isa( $id_hash, 'HASH' )
                 && exists( $id_hash->{$id} ) )
            {
                return 1
                    if ( $win->{currentNode} = $id_hash->{$id} ); # assignment
            }
            else {
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

######################################################################################
# Usage         : init_stylesheet_paths(\@custom_stylesheets_paths)
# Purpose       : Set the @stylesheet_paths and $default_stylesheet_path variable 
#                 according to the environment and argument @custom_stylesheets_paths
# Returns       : nothing
# Parameters    : list_ref $list_ref -- list of custom stylesheet paths
# Throws        : no exceptions
# Comments      : If valid @user_paths list is passed, this list is 'uniqued' and 
#                 put before the default path in the @stylesheet_paths array.
#                 If ~/.tred-stylesheets is an ordinary file, directory ~/.tred.d/stylesheets is created and 
#                 new stylesheets are created in this new directory from old tred-stylesheets file. 
#                 The $default_stylesheet_path is ~/.tred-stylesheets, this is changed to 
#                 ~/.tred.d/stylesheets/ if the conversion from old to new stylesheets happened or
#                 it changes to the first item in @stylesheet_paths if user defined any custom paths.
# See Also      : read_stylesheets(), save_stylesheets()
sub init_stylesheet_paths {
  my ($user_paths)=@_;
  $default_stylesheet_path = $ENV{HOME}."/.tred-stylesheets";
  my $stylesheet_dir = File::Spec->catfile($ENV{HOME},'.tred.d','stylesheets');
  if (!-d $stylesheet_dir and -f $default_stylesheet_path) {
    print STDERR "Converting old stylesheets from $default_stylesheet_path to $stylesheet_dir...\n";
    my $gui_ref = { stylesheets => {} };
    read_stylesheets($gui_ref, $default_stylesheet_path);
    if (mkdir $stylesheet_dir) {
      save_stylesheets($gui_ref, $stylesheet_dir);
      print STDERR "done.\n";
    } else {
      carp("failed to create $stylesheet_dir: $!.\n");
      $stylesheet_dir=$default_stylesheet_path;
    }
  }
  if (-d $stylesheet_dir){
    $default_stylesheet_path = $stylesheet_dir;
  }  
  my %uniq;
  if (ref($user_paths) and @{$user_paths}) {
    my @nonempty_user_paths = map { length($_) ? $_ : ($default_stylesheet_path) } @$user_paths;
    @stylesheet_paths = grep { !($uniq{$_}++) } ( @nonempty_user_paths, @stylesheet_paths );
    $default_stylesheet_path = $stylesheet_paths[0];
  } else {
    @stylesheet_paths = grep { !($uniq{$_}++) } ($default_stylesheet_path, @stylesheet_paths);
  }
}

sub loadStyleSheets {
  my ($gui)=@_;
  my $later=0;
  for my $p (@stylesheet_paths) {
    read_stylesheets($gui, $p, {no_overwrite=>$later});
    $later=1;
  }
}

#######################################################################################
# Usage         : set_fh_encoding(\*STDOUT, ':utf8', "STDOUT")
# Purpose       : Set encoding on a file handle  
# Returns       : nothing
# Parameters    : filehandle $fh    -- filehandle, 
#                 string $encoding  -- same encoding, as is accepted by open/binmode functions, e.g. ":encoding(utf8)"
#                 string $what      -- name of the flush (so we can report error if any occurs)
# Throws        : a string; When binmode or flush call fails
# Comments      : Be careful, don't use :utf8 on input files and STDIN (http://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8);
#                 It seems that the third parameter is not used in the sub, why is it here?
# See Also      : binmode (perldoc)
sub set_fh_encoding {
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

