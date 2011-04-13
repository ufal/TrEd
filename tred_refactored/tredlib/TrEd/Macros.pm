package TrEd::Macros;

use strict;
use warnings;
use Carp;

#use Data::Dumper;

BEGIN {
  use Cwd;
  use Treex::PML;
  use File::Spec;
  use File::Glob qw(:glob);
  use TrEd::Config;
  use TrEd::Basics;
  import TrEd::Config qw($default_macro_file $default_macro_encoding $macroDebug $hookDebug);
  use TrEd::Convert;
  use Encode ();
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $exec_code @macros $useEncoding
              $macrosEvaluated $safeCompartment %defines $warnings $strict
	      @macro_include_paths
	      %keyBindings
	      %menuBindings
	     );

  use base qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    &read_macros
    &do_eval_macro
    &do_eval_hook
    &macro_variable
    &get_macro_variable
    &set_macro_variable
    %keyBindings
    %menuBindings
    @macros
    $macrosEvaluated
    &get_contexts
  );
  # can be used from perl 5.8
  $useEncoding = ($]>=5.008);
}


#######################################################################################
# Usage         : define_symbol($name, $value)
# Purpose       : Define symbol with name $name and assigns the value $value to it
# Returns       : Function's second argument -- $value
# Parameters    : scalar $name  -- name of the variable to be defined
#                 scalar $value -- the value that will be assigned to the variable $name 
# Throws        : no exception
# Comments      : Information about defines is stored in file-scoped hash %defines
# See Also      : undefine_symbol(), is_defined()
sub define_symbol {
  my ($name, $value) = @_;
  $defines{$name} = $value;
  return $value;
}

#######################################################################################
# Usage         : undefine_symbol($name)
# Purpose       : Deletes the definition of symbol $name  
# Returns       : The value or values deleted in list context, or the last such element in scalar context
# Parameters    : string $name -- name of the symbol
# Throws        : no exception
# Comments      : ...
# See Also      : define_symbol(), is_defined(), delete()
sub undefine_symbol {
  my ($name) = @_;
  return delete($defines{$name});
}

#######################################################################################
# Usage         : is_defined($name)
# Purpose       : Tell whether symbol $name is defined  
# Returns       : True if the symbol $name is defined, false otherwise
# Parameters    : string $name -- name of the symbol
# Throws        : no exception
# Comments      : ...
# See Also      : exists(), define_symbol(), undefine_symbol()
sub is_defined {
  my ($name) = @_;
  return exists($defines{$name});
}

#######################################################################################
# Usage         : get_contexts()
# Purpose       : Returns sorted and uniqued list of contexts, i.e. keys of %menuBindings and %keyBindings hashes 
# Returns       : List of contexts
# Parameters    : no parameters
# Throws        : no exception
# Comments      : 
# See Also      : %menuBindings, %keyBindings
sub get_contexts {
  return #TrEd::Basics::
    uniq sort {$a cmp $b} (keys(%menuBindings), keys(%keyBindings))
}

#######################################################################################
# Usage         : _normalize_key($key)
# Purpose       : Normalize the keybinding description 
# Returns       : Normalized key description
# Parameters    : string $key -- represents the key combination, e.g. 'Ctrl+X'
# Throws        : no exception
# Comments      : Changes the '-' character to '+' and uppercases modifier keys 
sub _normalize_key {
  my ($key) = @_;
  $key =~ s/\-/+/g;	# convert ctrl-x to ctrl+x
  $key =~ s/([^+]+[+-])/uc($1)/eg; # uppercase modifiers
  return $key;
}

#######################################################################################
# Usage         : _normalize_macro($context, $macro)
# Purpose       : Test whether the $macro is a valid macro name or reference, or construct its name from context and macro name 
# Returns       : Normalized macro string that is accepted as $macro in functions
# Parameters    : string or ref $macro -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : none yet
sub _normalize_macro {
  my ($context, $macro) = @_;
  if(scalar(@_) < 2){
    croak("You must specify both context and macro in _normalize_macro");
  };
  return (ref($macro) or $macro=~/^\w+-\>/) ? $macro : $context.'->'.$macro;
}

#######################################################################################
# Usage         : bind_key($context, $key, $macro)
# Purpose       : Binds key (combination) $key to macro $macro in $context
# Returns       : nothing
# Parameters    : string $context       -- the context, in which the binding is valid
#                 string $key           -- key or key combination, e.g. 'Ctrl+x'
#                 string or ref $macro  -- macro which will be bound to the key $key
#                                          if $macro is a reference or string like sth->macro, 
#                                          then it's used as is, 
#                                          otherwise "$context->$macro" is bound to the $key
# Throws        : no exception
# Comments      : Works only if macro is defined
# See Also      : unbind_key(), _normalize_key(), get_bindings_for_macro(), get_binding_for_key()
sub bind_key {
  my ($context, $key, $macro) = @_;
  if (defined($macro) and length($macro)) {
    if(!exists($keyBindings{$context})){
      $keyBindings{$context} = {};
    }
    $keyBindings{$context}->{_normalize_key($key)} = _normalize_macro($context, $macro);
  }
  return;
}

#######################################################################################
# Usage         : unbind_key($context, $key, $delete)
# Purpose       : Discard binding for key $key in specified $context (if $delete is true, delete it, otherwise set bound macro to undef)
# Returns       : The result of delete function or undef/empty list, depending on the context
# Parameters    : string $context -- context in which the binding is being deleted
#                 string $key     -- key or key combination, e.g. 'Ctrl+x'
#                 bool $delete    -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : ...
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub unbind_key {
  my ($context, $key, $delete) = @_;
  my $bindings_ref = $keyBindings{$context};
  if (ref($bindings_ref)) {
    if ($delete) {
      return delete($bindings_ref->{_normalize_key($key)});
    } else {
      $bindings_ref->{_normalize_key($key)} = undef;  # we do not delete so that we may override TrEdMacro
    }
  }
  return;
}

#######################################################################################
# Usage         : unbind_macro($context, $macro, $delete)
# Purpose       : Discards all the bindings for $macro in context $context (if $delete is true, delete it, otherwise set to undef)
# Returns       : nothing
# Parameters    : string $context       -- context in which the binding is being deleted
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
#                 bool $delete          -- if set to true, binding is deleted, otherwise the macro is just set to undef
# Throws        : no exception
# Comments      : Shouldn't we normalize $macro here as well?
# See Also      : bind_key(), unbind_key(),
sub unbind_macro {
  my ($context, $macro, $delete) = @_;
  my $bindings_ref = $keyBindings{$context};
  if (ref($bindings_ref)) {
    while (my($key, $m) = each(%{$bindings_ref})) {
      next if($m ne $macro);
      if ($delete) {
        delete($bindings_ref->{$key});
      } else {
        $bindings_ref->{$key} = undef; # we do not delete so that we may override TrEdMacro
      }
    }
  }
  return;
}

#######################################################################################
# Usage         : get_bindings_for_macro($context, $macro)
# Purpose       : Return all the bindings for macro $macro in the specified $context
# Returns       : Array of the bindings in list context, first binding in scalar context
# Parameters    : string $context       -- context in which to look for the macro bindings
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : Be aware, that the 'first' binding means first one in the hash, 
#                 and you can hardly tell, which one that is
#                 Maybe we should normalize $macro here as well... 
# See Also      : get_binding_for_key(), bind_key(), unbind_key(), unbind_macro()
sub get_bindings_for_macro {
  my ($context, $macro) = @_;
  my $bindings_ref = $keyBindings{$context};
  my @ret;
  if (ref($bindings_ref)) {
    while (my($key, $m) = each(%{$bindings_ref})) {
      next if($m ne $macro);
      if(wantarray()){
        push(@ret, $key);
      } else {
        # if called in scalar context, the internal hash iterator stops somewhere in the middle of
        # the hash %keyBindings (if it finds the $macro, of course) and other functions calling each() 
        # would not work properly, because they all share the hash's internal iterator, thus we need to reset it
        keys(%{$bindings_ref});
        return $key
      }
    }
  }
  return @ret;
}

#######################################################################################
# Usage         : get_binding_for_key($context, $key)
# Purpose       : Return the binding for the $key in specified $context
# Returns       : Key binding if defined, undef otherwise
# Parameters    : string $context   -- context for key binding
#                 string $key       -- key or key combination, e.g. 'Ctrl+x'
# Throws        : no exception
# See Also      : unbind_key(), bind_key()
sub get_binding_for_key {
  my ($context, $key) = @_;
  my $binding = $keyBindings{$context};
  return ref($binding) ? $binding->{_normalize_key($key)} : undef;
}

#######################################################################################
# Usage         : get_keybindings($context)
# Purpose       : Return hash of key bindings in context $context
# Returns       : Hash of key bindings in context $context if there are any, undef otherwise
# Parameters    : string $context -- context we are examinig
# Throws        : no exception
# Comments      : ...
# See Also      : get_binding_for_key(), bind_key(), unbind_key(), copy_key_bindings()
sub get_keybindings {
  my ($context) = @_;
  my $bindings_ref = $keyBindings{$context};
  return ref($bindings_ref) ? %{$bindings_ref} : undef;
}

#######################################################################################
# Usage         : copy_key_bindings($source_context, $destination_context)
# Purpose       : Copy key bindings from one context $source_context to another ($destination_context)
#                 The $destination_context is created, if it does not exist. 
# Returns       : Hash reference to destination context's keybindings or undef if $source_context does not exist 
#                 (or empty list in array context)
# Parameters    : string $source_context
#                 string $destination_context
# Throws        : no exception
# See Also      : bind_key(), unbind_key(), get_contexts(), 
sub copy_key_bindings {
  my ($source_context, $destination_context) = @_;
  my $source_bindings_ref = $keyBindings{$source_context};
  return unless ref($source_bindings_ref);
  my $dest_bindings_ref = ($keyBindings{$destination_context} ||= {});
  while (my ($key, $macro) = each(%{$source_bindings_ref})) {
    $dest_bindings_ref->{$key} = $macro;
  }
  return $dest_bindings_ref;
}


#######################################################################################
# Usage         : add_to_menu($context, $label, $macro)
# Purpose       : Adds new menu binding to macro $macro with label $label in context $context
# Returns       : nothing
# Parameters    : string $context       -- context for macro $macro 
#                 string $label         -- nonempty menu label for the $macro
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : If label is empty, nothing is done, $context is created if it does not exist, 
#                 But more interestingly, undef is the second element in anon array, whose first element is
#                 the $macro
#TODO: Why do we use the array_ref???
# See Also      : remove_from_menu()
sub add_to_menu {
  my ($context, $label, $macro) = @_;
  if (defined($label) and length($label)) {
    if(!exists($menuBindings{$context})){
      $menuBindings{$context} = {};
    }
    $menuBindings{$context}->{$label}=[
      _normalize_macro($context, $macro),
      undef
     ];
  }
  return;
}

#######################################################################################
# Usage         : remove_from_menu($context, $label)
# Purpose       : Remove menu binding with label $label in specified $context 
# Returns       : List of removed elements, i.e. list containing one array reference,
#                 or undef in scalar context if $context or $label in $context does not exist
# Parameters    : string $context -- name of the context
#                 string $label   -- menu label
# Throws        : no exception
# Comments      : Confusion between perl context and macro context in explanation is not very good I guess... 
# See Also      : add_menu(), remove_from_menu_macro()
sub remove_from_menu {
  my ($context, $label) = @_;
  if (exists($menuBindings{$context})) {
    return delete($menuBindings{$context}{$label});
  }
  return;
}

#######################################################################################
# Usage         : remove_from_menu_macro($context, $macro)
# Purpose       : Remove menu binding for macro $macro in specified $context 
# Returns       : nothing
# Parameters    : string $context       -- context for macro $macro 
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : ...
# See Also      : remove_from_menu(), add_menu()
#TODO: actually it is never used (not even in extensions, nor here)
#TODO: Shall we use _normalize_macro()?
sub remove_from_menu_macro {
  my ($context, $macro) = @_;
  my $bindings_ref = $menuBindings{$context};
  if (ref($bindings_ref)) {
    while (my($key, $array_ref) = each(%{$bindings_ref})) {
      next if($array_ref->[0] ne $macro);
      delete($bindings_ref->{$key});
    }
  }
  return;
}

#######################################################################################
# Usage         : get_menus_for_macro($context, $macro)
# Purpose       : Return all the menus bound to $macro in $context
# Returns       : Array of all menu labels bound with specified $macro in context $context, 
#                 or 'first' label in scalar context
# Parameters    : string $context       -- name of the context
#                 string or ref $macro  -- string in the form "sth->$macro" or ref to macro subroutine
# Throws        : no exception
# Comments      : Be aware, that the 'first' label means first one in the hash, 
#                 and you can hardly tell, which one that is
# See Also      : get_macro_for_menu(), add_menu(), remove_from_menu()
#TODO: never actually used...
#TODO: Shouldn't we normalize macro here as well?
sub get_menus_for_macro {
  my ($context, $macro) = @_;
  my $bindings_ref = $menuBindings{$context};
  my @ret;
  if (ref($bindings_ref)) {
    while (my($key,$array_ref)=each %{$bindings_ref}) {
      next if($array_ref->[0] ne $macro);
      if(wantarray){
        push(@ret, $key);
      } else {
        # if called in scalar context, the internal hash iterator stops somewhere in the middle of
        # the hash %menuBindings (if it finds the $macro, of course) and other functions calling each() 
        # would not work properly, because they all share the hash's internal iterator, thus we need to reset it
        keys(%{$bindings_ref});
        return $key;
      }
    }
  }
  return @ret;
}

#######################################################################################
# Usage         : get_macro_for_menu($context, $label)
# Purpose       : Return macro bound to menu $label in specified $context
# Returns       : Array reference with macro or undef if there is no menu binding with $label in $context
# Parameters    : string $context -- name of the desired context
#                 string $label   -- menu label
# Throws        : no exception
# See Also      : get_menus_for_macro(), get_menuitems(), add_menu(), remove_from_menu()
sub get_macro_for_menu {
  my ($context, $label) = @_;
  my $bindings_ref = $menuBindings{$context};
  return ref($bindings_ref) ? $bindings_ref->{$label} : undef;

}

#######################################################################################
# Usage         : get_menuitems($context)
# Purpose       : Return all the menu bindings in context $context
# Returns       : Hash of menu bindings, or undef if no menu bindigs exists for specified $context
# Parameters    : string $cotnext -- context searched for menu bindings
# Throws        : no exception
# See Also      : add_to_menu(), remove_from_menu()
sub get_menuitems {
  my ($context) = @_;
  my $menu_bindings_ref = $menuBindings{$context};
  return ref($menu_bindings_ref) ? %{$menu_bindings_ref} : undef;
}

#######################################################################################
# Usage         : copy_menu_bindings($source_context, $destination_context)
# Purpose       : Copies menu bindings from $source_context to $destination_context
# Returns       : Hash reference to destination context's menu bindings, or undef if no menu bindings for $source_context exists
# Parameters    : string $source_context      -- string representation (aka name) of source context
#                 string $destination_context -- name of the destination context
# Throws        : no exception
# Comments      : Destination context is created if it does not exist
# See Also      : add_menu(), remove_from_menu(), get_contexts()
sub copy_menu_bindings {
  my ($source_context, $destination_context) = @_;
  my $source_bindings_ref = $menuBindings{$source_context};
  return if(!ref($source_bindings_ref));
  
  my $dest_bindings_ref = ($menuBindings{$destination_context} ||= {});
  while (my ($key, $macro_arr) = each(%{$source_bindings_ref})) {
    $dest_bindings_ref->{$key} = $macro_arr;
  }
  return $dest_bindings_ref;
}

#######################################################################################
# Usage         : _read_default_macro_file($encoding, \@contexts);
# Purpose       : Read default macro file in encoding $encoding into package variable @macros
# Returns       : nothing
# Parameters    : string $encoding        -- encoding of the default macro file
#                 array_ref $contexts_ref -- reference to array of contexts
# Throws        : no exception
# Comments      : Sub extracted from read_macros to decrease its complexity
#                 Default macro file is set by TrEd::Config and can be configured via tredrc file.
#                 The default 'default macro file' is $libDir/tred.def (where $libDir is set by TrEd::Config, too)
# See Also      : read_macros(), $TrEd::Config::default_macro_file, $TrEd::Config::libDir
sub _read_default_macro_file {
  my ($encoding, $contexts_ref) = @_;
  # overwrite key and menu bindings
  %keyBindings = ();
  %menuBindings = ();
  @macros = ();
  $exec_code = undef;
  print STDERR "Reading $TrEd::Config::default_macro_file\n" if $macroDebug;
  #Hmm, turn off UTF-8 flag in string $default_macro_file... what for? 
  Encode::_utf8_off($TrEd::Config::default_macro_file);
  # this push is also done in preprocess, shouldn't we remove it from here?
#  push(@macros,"\n#line 1 \"$TrEd::Config::default_macro_file\"\n");
  my $default_macro_fh;
  open($default_macro_fh,'<',$TrEd::Config::default_macro_file) or do {
    carp("ERROR: Cannot open macros: $TrEd::Config::default_macro_file!\n");
    # return value is never used, why should it return some code...
    return;
  };
  set_encoding($default_macro_fh, $encoding);
  preprocess($default_macro_fh, $TrEd::Config::default_macro_file, \@macros, $contexts_ref);
  close($default_macro_fh);
  return;
}

#######################################################################################
# Usage         : read_macros($file, $libDir, $keep, $encoding, @contexts);
# Purpose       : Read default macros and the specified macro $file using encoding $encoding
# Returns       : nothing
# Parameters    : ...
# Throws        : no exception
# Comments      : ...
# See Also      : ...
#TODO: what will happen, if we would call read_macros with $keep = 1 for the first time?
# well, obviously, default macro would not be loaded... which is not good, I guess...
#
# This subroutine reads macro file. Macros are usual perl
# subroutines and may use this program's namespace. They are also
# provided some special names for certain variables which override
# the original namespace.

# Macros may be bound to a keysym with a special form of a comment.
# The synax is:
#
# # bind MacroName to key [[Modifyer+]*]KeySym
#
# which causes subroutine MacroName to be bound to keyboard event of
# simoultaneous pressing the optionally specified Modifyer(s) (which
# should be some of Shift, Ctrl and Alt) and the specified KeySym
# (this probabbly depends on platform too :( ).
sub read_macros {
  my ($file, $libDir, $keep, $encoding) = (shift, shift, shift, shift);
  my @contexts = @_;
  $macrosEvaluated = 0;
  if(!defined($encoding) || $encoding eq ""){
    $encoding = $TrEd::Config::default_macro_encoding;
  }
  if(!@contexts){
    @contexts = ("TredMacro");
  }
  if (!$keep) {
    _read_default_macro_file($encoding, @contexts);
  }
  print STDERR "Reading $file\n" if $macroDebug;
  my $macro_filehandle;
  # try to open file
  open($macro_filehandle,'<',$file)
  # or to open it from different location
    || (!$keep && ($file = "$libDir/$file") && open($macro_filehandle,'<',$file)) ||
      croak("ERROR: Cannot open macros: $file ($!)!\n");
  set_encoding($macro_filehandle, $encoding);
  preprocess($macro_filehandle, $file, \@macros, \@contexts);
  close($macro_filehandle);
  if (!$keep && $macroDebug){
    print STDERR "Read " . scalar(@macros) . " lines of code.\n";
  }
}

#######################################################################################
# Usage         : preprocess($file_handle, $file_name, \@macros, \@contexts)
# Purpose       : Preprocess file $file_name, save the results to macros and contexts arrays
#                 Include #includes and #ifincludes respecting #ifdefs, #ifndefs, #elsifs, etc.
# Returns       : nothing
# Parameters    : file_handle $file_handle  -- handle to opened file
#                 string $file_name         -- name of the file whose handle is passed as arg 1
#                 array_ref $macros         -- reference to array storing lines of macro files
#                 array_ref $contexts       -- reference to array storing macro contexts, i.e. TrEd modes
# Throws        : a scalar (string) if it fails to include a file or finds unmatched elseif/endif
# Comments      : new "pragmas":
#                   include <file>  ... relative to tred's libdir
#                   include "file"  ... relative to dir of the current macro file
#                   include file    ... absolute or relative to current dir or one of the above
#
#                   ifinclude       ... as include but without producing an error if file doesn't exist
#
#                   binding-context <context> [<context> [...]]
#
#                   key-binding-adopt <contexts>
#                   menu-binding-adopt <contexts>
#
#                   bind <method> [to] [key[sym]] <key> [menu <menu>[/submenu[/...]]]
#
#                   insert <method> [as] [menu] <menu>[/submenu[/...]]
# See Also      : read_macros(), 
#TODO: hmm, what if extensions would be subclasses of ~tred.def...?
sub preprocess {
  my ($file_handle, $file_name, $macros_ref, $contexts_ref) = @_;
  # Again, turn off UTF-8 flag for string $file_name? Why we do that? $file_name contains just a name of some file...
  Encode::_utf8_off($file_name);

  push(@$macros_ref,"\n#line 1 \"$file_name\"\n");
  my $line = 1;
  my @conditions;
  my $ifok = 1;
  while (<$file_handle>) {
    $line++;
    if (/^\#endif(?:$|\s)/) {
      push(@$macros_ref, $_);
      if (@conditions) {
        pop(@conditions);
        $ifok = (!@conditions || $conditions[$#conditions]);
      } else {
        die "unmatched #endif in \"$file_name\" line $line\n";
      }
    } elsif (/^\#elseif\s+(\S*)$|^\#else(?:if)?(?:\s|$)/) {
      if (@conditions) {
        my $prev = ($#conditions>0) ? $conditions[$#conditions-1] : 1;
        if (defined($1)) {
          $conditions[$#conditions] = $prev &&
          !$conditions[$#conditions] && is_defined($1);
        } else {
          $conditions[$#conditions] = $prev && !$conditions[$#conditions];
        }
        $ifok = $conditions[$#conditions];
      } else {
        die "unmatched #elseif in \"$file_name\" line $line\n";
      }
    } elsif (/^\#ifdef\s+(\S*)/) {
      push(@$macros_ref, $_);
      push(@conditions, (is_defined($1) && (!@conditions || $conditions[$#conditions])));
      $ifok = $conditions[$#conditions];
    } elsif (/^\#ifndef\s+(\S*)/) {
      push(@$macros_ref, $_);
      push(@conditions, (!is_defined($1) && (!@conditions || $conditions[$#conditions])));
      $ifok = $conditions[$#conditions];
    } else {
      if ($ifok) {
        if (/^\s*__END__/) {
          last;
        } elsif (/^\s*__DATA__/) {
          warn "Warning: __DATA__ has no meaning in TredMacro (use __END__ instead) at $file_name line $line\n";
          last;
        }
        push(@$macros_ref, $_);
        if (/^\#!(.*)$/) {
          $exec_code = $1 unless defined $exec_code; # first wins
        } elsif (/^\#define\s+(\S*)(?:\s+(.*))?/) {
          define_symbol($1, $2); # there is no use for $2 so far
        } elsif (/^\#undefine\s+(\S*)/) {
          undefine_symbol($1);
        } elsif (/^\#\s*binding-context\s+(.*)/) {
          @$contexts_ref = (split /\s+/,$1) if $ifok;
        } elsif (/^\#\s*key-binding-adopt\s+(.*)/) {
          my @toadopt=(split /\s+/,$1);
          foreach my $context (@$contexts_ref) {
            foreach my $toadopt (@toadopt) {
              copy_key_bindings($toadopt, $context);
            }
          }
        } elsif (/^\#\s*menu-binding-adopt\s+(.*)/) {
          my @toadopt=(split /\s+/,$1);
          foreach my $context (@$contexts_ref) {
            foreach my $toadopt (@toadopt) {
              copy_menu_bindings($toadopt, $context);
            }
          }
        } elsif (/^\#[ \t]*unbind-key[ \t]+([^ \t\r\n]+)/) {
          my $key = $1;
          unbind_key($_, $key) for @$contexts_ref;
        } elsif (/^\#[ \t]*bind[ \t]+(\w+(?:-\>\w+)?)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+([^\r\n]+))?/) {
          my ($macro,$key,$menu)=($1, $2, $3);
          $menu = TrEd::Convert::encode($menu);
          if ($menu) { 
            add_to_menu($_, $menu => $macro) for @$contexts_ref; 
          }
          bind_key($_, $key => $macro) for @$contexts_ref;
        } elsif (/^\#\s*insert[ \t]+(\w*)[ \t]+(?:as[ \t]+)?(?:menu[ \t]+)?([^\r\n]+)/) {
          my $macro = $1;
          my $menu = TrEd::Convert::encode($2);
          add_to_menu($_, $menu, $macro) for @$contexts_ref;
        } elsif (/^\#\s*remove-menu[ \t]+([^\r\n]+)/) {
          my $menu=TrEd::Convert::encode($1);
          remove_from_menu($_, $menu) for @$contexts_ref;
        } elsif (/^\#\s*(if)?include\s+\<([^\r\n]+\S)\>\s*(?:encoding\s+(\S+)\s*)?$/) {
          my $conditional_include = defined($1) && ($1 eq 'if') ? 1 : 0;
          my $enc = $3;
          my $f = $2;
          Encode::_utf8_off($f);
          my $found;
          for my $path ($libDir, @macro_include_paths) {
            my $mf="$path/$f";
            if (-f $mf) {
              read_macros($mf,$libDir,1,$enc,@$contexts_ref);
              push @$macros_ref,"\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
              $found = 1;
              last;
            }
          }
          if (!$found and !$conditional_include) {
            die
              "Error including macros $f\n from $file_name: ",
              "file not found in search paths: $libDir @macro_include_paths\n";
          }
        } elsif (/^\#\s*(if)?include\s+"([^\r\n]+\S)"\s*(?:encoding\s+(\S+)\s*)?$/) {
          my $enc = $3;
          my $pattern = $2;
          my $if = defined($1) ? $1 : 0;
          Encode::_utf8_off($pattern);
        
          my @includes;
          if ($pattern=~/^<(.*)>$/) {
            my $glob = $1;
            my ($vol, $dir) = File::Spec->splitpath(dirname($file_name));
            $dir = File::Spec->catpath($vol,$dir); 
            my $cwd = cwd();
            chdir $dir;
            @includes = map { File::Spec->rel2abs($_) } glob($glob);
            chdir $cwd;
          } else {
            @includes = (dirname($file_name).$pattern);
          }
          foreach my $mf (@includes) {
            if (-f $mf) {
              read_macros($mf,$libDir,1,$enc,@$contexts_ref);
              push @$macros_ref,"\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
            } elsif ($if ne 'if') {
              die "Error including macros $mf\n from $file_name: ",  "file not found!\n";
            }
          }
        } elsif (/^\#\s*(if)?include\s+([^\r\n]+?\S)\s*(?:encoding\s+(\S+)\s*)?$/) {
          my ($if, $f, $enc) = ($1, $2, $3);
          Encode::_utf8_off($f);
        
          if ($f =~ m%^/%) {
            read_macros($f, $libDir, 1, $enc, @$contexts_ref);
            push @$macros_ref,"\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
          } else {
            my $mf = $f;
            print STDERR "including $mf\n" if $macroDebug;
            unless (-f $mf) {
              $mf=dirname($file_name).$mf;
              print STDERR "trying $mf\n" if $macroDebug;
              unless (-f $mf) {
                $mf="$libDir/$f";
                print STDERR "not found, trying $mf\n" if $macroDebug;
              }
            }
            if (-f $mf) {
              read_macros($mf, $libDir, 1, $enc, @$contexts_ref);
              push @$macros_ref,"\n\n=pod\n\n=cut\n\n#line $line \"$file_name\"\n";
            } elsif (!defined($if) || $if ne 'if') {
              die
                "Error including macros $mf\n from $file_name: ",
                "file not found!\n";
            }
          }
        } elsif (/^\#\s*encoding\s+(\S+)\s*$/) {
          set_encoding($file_handle,$1);
        }
      } else {
        # $ifok == 0
        push @$macros_ref,"\n"; # only for line numbering purposes
      }
    }
  }
  if (@conditions){
    die "Missing #endif in $file_name line $line (".scalar(@conditions)." unmatched #if-pragmas)\n";
  }
  return 1;
}

#######################################################################################
# Usage         : set_encoding($file_handle, $encoding);
# Purpose       : Set encoding for file $file_handle to $encoding (or to default_macro_encoding, if no encoding is specified)
# Returns       : nothing
# Parameters    : file handle $file_handle  -- handle to a file
#                 [string $encoding          -- encoding name]
# Throws        : no exception
# Comments      : ':utf8' should only be used for output, using ':encoding(utf8)' instead
sub set_encoding {
  my $fh = shift;
  my $enc = shift || $default_macro_encoding;
  if ($useEncoding and $enc) {
    eval {
      $fh->flush();
      binmode $fh;  # first get rid of all I/O layers
      if (lc($enc) =~ /^utf-?8$/) {
        binmode($fh,":encoding(utf8)");
      } else {
        binmode($fh,":encoding($enc)");
      }
    };
    print STDERR $@ if $@;
  }
  return;
}

#######################################################################################
# Usage         : initialize_macros($win_ref)
# Purpose       : Initializes macros, run them for the first time either using eval or in safe compartment
# Returns       : Return the result of macro evaluation or 2 if the macros were already evaluated
# Parameters    : hash_ref $win_ref -- see below
# Throws        : no exception
# Comments      : The $win_ref parameter to the following two routines should be
#                 a hash reference, having at least the following keys:
#
#                 FSFile       => FSFile blessed reference of the current FSFile
#                 treeNo       => number of the current tree in the file
#                 macroContext => current context under which macros are run 
#
#                 the $win_ref itself is passed to the macro in the $grp variable
#
#                 Macros expect the following (minimally) variables set:
#                 $TredMacro::root    ... root of the current tree
#                 $TredMacro::this    ... current node
#                 $TredMacro::libDir  ... path to TrEd's library directory
#
#                 Macros signal the results of their operation using the following
#                 variables:
#                 $TredMacro::FileNotSaved   ... if 0, macro claims it has done no no changes
#                                that would need saving
#                 $TredMacos::forceFileSaved ... if 1, macro claims it saved the file itself

sub initialize_macros {
  my ($win_ref) = @_;	# $win is a reference
                        # which should in this way be made visible
                        # to macros
  my $result = 2; #hm?
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  unless ($macrosEvaluated) {
    my $macros = "";
    $macros .= "use strict;"   if $strict;
    $macros .= "use warnings; no warnings 'redefine';" if $warnings;
    $macros .= "{\n".$utf.join("",
			     map { Encode::_utf8_off($_); $_ }
			     @macros
			    )."\n}; 1;\n";
    print STDERR "FirstEvaluation of macros\n" if $macroDebug;
    if (defined($safeCompartment)) {
      set_macro_variable('grp',$win_ref);
      my %packages;
      # dirty hack to support ->isa in safe compartment
      $macros =~ s{(\n\s*package\s+(\S+?)\s*;)}
      { 
        exists($packages{$2}) ? $1 : do { $packages{$2} = 1 ; 
                                          $1.'sub isa {
                                                        for(@ISA){
                                                          return 1 if $_ eq $_[1]}
                                                        }'
                                        }
      }ge;
      $macrosEvaluated = 1;
      {
        no strict;
        $result = $safeCompartment->reval($macros);
      }
      TrEd::Basics::errorMessage($win_ref,$@) if $@;
    } else {
      no strict;
      ${"TredMacro::grp"} = $win_ref;
      $macrosEvaluated = 1;
      $result = eval { 
        my $res = eval ($macros); 
        die $@ if $@; 
        return $res; 
      };
    }
    print STDERR "Returned with: $result\n\n" if $macroDebug;
    TrEd::Basics::errorMessage($win_ref, $@) if $@;
  }
  no strict 'refs';
  set_macro_variable('grp', $win_ref);
  return $result;
}

#######################################################################################
# Usage         : macro_variable($var_name)
# Purpose       : Construct a symbolic reference for getter and setter of macro variables
# Returns       : Name of the variable, either from Safe compartment, or with macro namespace prefix
# Parameters    : string $var_name -- name of the variable
# Throws        : no exception
# Comments      : Symbolic references are kind of deprecated in Perl Best Practices, maybe think up some other way to do this...
#                 although in Safe.pm the implementation is similar...
# See Also      : get_macro_variable(), set_macro_variable()
sub macro_variable {
  my $prefix = ($_[0] =~ /::/) ? '' : 'TredMacro::';
  if (defined($safeCompartment)) {
    return $safeCompartment->varglob($prefix.$_[0]);
  } else {
    return $prefix.$_[0]
  }
}

#######################################################################################
# Usage         : get_macro_variable($var_name)
# Purpose       : Retrieve value of specified macro variable
# Returns       : Value of the macro variable
# Parameters    : string $var_name  -- name of the variable
# Throws        : no exception
# Comments      : ...
# See Also      : set_macro_variable(), macro_variable()
sub get_macro_variable {
  no strict 'refs';
  return ${ &macro_variable };
}

#######################################################################################
# Usage         : set_macro_variable($var_name, $var_value)
# Purpose       : Set macro variable in desired namespace
# Returns       : nothing
# Parameters    : string $var_name  -- name of the variable, e.g. TredMacro::my_variable
#                 scalar $var_value -- value of the var, e.g. 'value_of_var'
# Throws        : no exception
# Comments      : ...
# See Also      : get_macro_variable(), macro_variable()
sub set_macro_variable {
  no strict 'refs';
  while (@_) {
    ${ &macro_variable } = $_[1];
    shift; 
    shift;
  }
}

# variables used in macros
my @_saved_vars = qw(grp this root FileNotSaved forceFileSaved);

#######################################################################################
# Usage         : save_ctxt()
# Purpose       : Allow saving current context by returning values of chosen variables
# Returns       : Reference to array with values of selected variables from current context
# Parameters    : no
# Throws        : no exception
# Comments      : selected variables: grp, this, root, FileNotSaved, forceFileSaved 
# See Also      : restore_ctxt()
sub save_ctxt {
  no strict 'refs';
  if (defined($safeCompartment)) {
    return [ map ${ $safeCompartment->varglob('TredMacro::'.$_) }, @_saved_vars ];
  } else {
    return [ map ${'TredMacro::'.$_}, @_saved_vars ];
  }
}

#######################################################################################
# Usage         : restore_ctxt($old_context)
# Purpose       : Restore selected context variables from previously saved array reference
# Returns       : nothing
# Parameters    : array_ref $old_context -- context returned from function save_ctxt()
# Throws        : no exception
# Comments      : selected variables: grp, this, root, FileNotSaved, forceFileSaved
# See Also      : save_ctxt()
sub restore_ctxt {
  my $ctxt_ref = shift;
  my $i=0;
  no strict 'refs';
  if (defined($safeCompartment)) {
    for my $var (@_saved_vars) {
      ${ $safeCompartment->varglob('TredMacro::'.$var) } = $ctxt_ref->[$i++];
    }
  } else {
    for my $var (@_saved_vars) {
      ${'TredMacro::'.$var} = $ctxt_ref->[$i++];
    }
  }
  return;
}

#######################################################################################
# Usage         : do_eval_macro($win_ref, $macro)
# Purpose       : Evaluate macro and pass $win_ref to macro context
# Returns       : The return value of evaluated macro, if macro is not supported
#                 function returns $TredMacro::this in scalar context or a list containing 
#                 two zeroes and $TredMacro::this in list context
# Parameters    : hash_ref $win_ref -- for details, see initialize_macros function
#                 string $macro     -- name of macro to evaluate or 
#                 code_ref $macro   -- reference to macro function or 
#                 array_ref $macro  -- array with function reference as the first element and function arguments as other elements
# Throws        : no exception
# Comments      : Safe compartment accepts only string $macro parameter
# See Also      : initialize_macros(), set_macro_variable()
sub do_eval_macro {
  my ($win, $macro) = @_;   # $win is a reference
                            # which should in this way be made visible
                            # to macros
  # hm, this would not work in safe compartment...
  if (!$macro){
    if (defined($safeCompartment)) {
      my $return_val = $safeCompartment->reval('$TredMacro::this');
      return 0,0,$return_val;
    } else {
      return 0,0,$TredMacro::this;
    }
  }
  my $result;
  undef $@;
  initialize_macros($win);
  return undef if $@;
  
  if (!ref($macro) and $macro=~/^\s*([_[:alpha:]][_[:alnum:]]*)-[>]([_[:alpha:]][_[:alnum:]]*)$/) {
    my ($context,$call)=($1,$2);
    if (context_isa($context,'TrEd::Context')) {
      # experimental new-style calling convention
      $macro = $context.'->global->'.$call;
    }
  }
  print STDERR "Running $macro\n" if $macroDebug;
  if (defined($safeCompartment)) {
    no strict;
    set_macro_variable('grp',$win);
    my $utf = ($useEncoding) ? "use utf8;\n" : "";
    $result = $safeCompartment->reval($utf.$macro);
  } elsif (ref($macro) eq 'CODE') {
    $result = eval {
      use utf8;
      &$macro();
    };
  } elsif (ref($macro) eq 'ARRAY') {
    $result = eval {
      use utf8;
      $macro->[0]->(@{$macro}[1..$#$macro]);
    };
  } else {
    no strict;
    if ($useEncoding) {
      $result = eval("use utf8;\n".$macro);
    } else {
      $result = eval($macro);
    }
  }
  TrEd::Basics::errorMessage($win,$@) if ($@);
  print STDERR "Had run: ",$macro,"\n" if $macroDebug;
  print STDERR "Returned with: $result\n" if $macroDebug;
  return $result;
}

#######################################################################################
# Usage         : context_can($context, $sub)
# Purpose       : Determine whether the context $context has a method called $sub
# Returns       : Reference to method called $sub in context $context or undef if there is no such method
# Parameters    : string $context -- Name of the context
#                 string $sub     -- Name of subroutine
# Throws        : no exception
# Comments      : supports using safe compartment
# See Also      : context_isa()
sub context_can {
  my ($context, $sub) = @_;
  return undef if (!defined($context));
  if (defined($safeCompartment)) {
    no strict;
    return $safeCompartment->reval("\${'${context}::'}{'$sub'}");
  } else {
    # needs testing, if it works in Class::Std
    return eval { $context->can($sub) };
#    return UNIVERSAL::can($context, $sub);
  }
}

#######################################################################################
# Usage         : context_isa($context, $package)
# Purpose       : Determine whether context $context is in package $package
# Returns       : True if context contains specified package, false otherwise
# Parameters    : string $context -- Name of the context
#                 string $package -- Name of package
# Throws        : no exception
# Comments      : supports using safe compartment (via a nasty hack introduced in initialize_macros)
# See Also      : initialize_macros(), context_can()
sub context_isa {
  my ($context, $package) = @_;
  return undef if (!defined($context));
  if (defined($safeCompartment)) {
    my $arr_ref = $safeCompartment->reval('\@' . ${context} . '::ISA');
    my @list = grep { $_ eq $package } @$arr_ref;
    return scalar(@list) ? 1 : undef;
  } else {
    # needs testing, if it works in Class::Std
    return eval { $context->isa($package) };
#    return UNIVERSAL::isa($context, $package);
  }
}

#######################################################################################
# Usage         : do_eval_hook($win_ref, $context, $hook, @args)
# Purpose       : Evaluate hook 
# Returns       : The result of hook eval or undef if no hook is specified
# Parameters    : hash_ref $win_ref -- see initialize_macros for details
#                 string $context   -- context name
#                 string $hook      -- name of the hook
#                 list @args        -- list of hook arguments 
# Throws        : no exception
# See Also      : initialize_macros()
sub do_eval_hook {
  my ($win, $context, $hook)=(shift, shift, shift);   # $win is a reference
                                                      # which should in this way be made visible
                                                      # to hooks
  print STDERR "about to run the hook: '$hook' (in $context context)\n" if $hookDebug;
  return undef unless $hook; # and $TredMacro::this;
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  undef $@;
  initialize_macros($win);
  return undef if $@;
  my $result=undef;

  if (context_isa($context,'TrEd::Context') and context_can($context, $hook)) {
    # experimental new-style calling convention
    print STDERR "running hook $context".'->global->'.$hook."\n" if $hookDebug;
    if (defined($safeCompartment)) {
#      no strict;
      $result = $safeCompartment->reval($utf."$context\-\>global\-\>$hook(@_)");
    } else {
#      no strict;
      $result = eval($utf."$context\-\>global\-\>$hook(\@_)");
    }
  } else {
    if (!context_can($context, $hook)) {
      if ($context ne "TredMacro" and context_can('TredMacro',$hook)) {
        $context = "TredMacro";
      } else {
        return;
      }
    }
    print STDERR "running hook $context"."::"."$hook\n" if $hookDebug;
    if (defined($safeCompartment)) {
#      no strict;
      my $reval_str = $utf . "$context\:\:$hook(@_)";
      $result = $safeCompartment->reval($reval_str);
    } else {
#      no strict;
      $result = eval($utf . "\&$context\:\:$hook(\@_)");
    }
  }
  return $result;
}

1;
