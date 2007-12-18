package TrEd::Macros;

BEGIN {
  use Cwd;
  use Fslib;
  use File::Spec;
  use TrEd::Config;
  use TrEd::Basics;
  import TrEd::Config qw($defaultMacroFile $defaultMacroEncoding $macroDebug $hookDebug);

  use TrEd::Convert;
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $exec_code @macros $useEncoding
              $macrosEvaluated $safeCompartment %defines
	      %keyBindings
	      %menuBindings
	     );

  @ISA=qw(Exporter);
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
    &getContexts
  );
  $useEncoding = ($]>=5.008);
}

use strict;

sub define_symbol {
  my ($name, $value) = @_;
  $defines{$name}=$value;
  return $value;
}

sub undefine_symbol {
  my ($name) = @_;
  return delete $defines{$name};
}

sub is_defined {
  my ($name) = @_;
  return exists $defines{$name};
}

sub getContexts {
  return
    uniq sort (keys(%menuBindings),
	       keys(%keyBindings))
}

sub _normalize_key {
  my ($key)=@_;
  $key=~s/\-/+/g;	# convert ctrl-x to ctrl+x
  $key=~s/([^+]+[+-])/uc($1)/eg; # uppercase modifiers
  return $key;
}

sub bind_key {
  my ($context,$key,$macro)=@_;
  if (defined($macro) and length($macro)) {
    $keyBindings{$context}={} unless exists($keyBindings{$context});
    $keyBindings{$context}->{_normalize_key($key)} = (ref($macro) or $macro=~/^\w+-\>/) ? $macro : $context.'->'.$macro,
  }
}
sub unbind_key {
  my ($context,$key,$delete)=@_;
  my $h = $keyBindings{$context};
  if (ref($h)) {
    if ($delete) {
      return delete $h->{_normalize_key($key)};
    } else {
      $h->{_normalize_key($key)}=undef;  # we do not delete so that we may override TrEdMacro
    }
  }
  return;
}
sub unbind_macro {
  my ($context,$macro, $delete)=@_;
  my $h = $keyBindings{$context};
  if (ref($h)) {
    while (my($k,$v)=each %$h) {
      next unless $v eq $macro;
      if ($delete) {
	delete $h->{$k};
      } else {
	$h->{$k} = undef; # we do not delete so that we may override TrEdMacro
      }
    }
  }
}
sub get_bindings_for_macro {
  my ($context,$macro)=@_;
  my $h = $keyBindings{$context};
  my @ret;
  if (ref($h)) {
    while (my($k,$v)=each %$h) {
      next unless $v eq $macro;
      wantarray || return $k;
      push @ret, $k;
    }
  }
  return @ret;
}
sub get_binding_for_key {
  my ($context,$key)=@_;
  my $h = $keyBindings{$context};
  return ref($h) ? $h->{_normalize_key($key)} : undef;
}
sub add_to_menu {
  my ($context,$label,$macro)=@_;
  if (defined($label) and length($label)) {
    $menuBindings{$context}={} unless exists($menuBindings{$context});
    $menuBindings{$context}->{$label}=[
      (ref($macro) or $macro=~/^\w+-\>/) ? $macro : $context.'->'.$macro,
      undef
     ];
  }
}
sub remove_from_menu {
  my ($context,$label)=@_;
  if (exists($menuBindings{$context})) {
    return delete $menuBindings{$context}{$label}
  }
  return;
}
sub remove_from_menu_macro {
  my ($context,$macro)=@_;
  my $h = $menuBindings{$context};
  if (ref($h)) {
    while (my($k,$v)=each %$h) {
      next unless $v eq $macro;
      delete $h->{$k};
    }
  }
}
sub get_menus_for_macro {
  my ($context,$macro)=@_;
  my $h = $menuBindings{$context};
  my @ret;
  if (ref($h)) {
    while (my($k,$v)=each %$h) {
      next unless $v eq $macro;
      wantarray || return $k;
      push @ret, $k;
    }
  }
  return @ret;
}
sub get_macro_for_menu {
  my ($context,$label)=@_;
  my $h = $menuBindings{$context};
  return ref($h) ? $h->{$label} : undef;

}
sub get_menuitems {
  my ($context)=@_;
  my $h = $menuBindings{$context};
  return ref($h) ? %$h : undef;
}
sub get_keybindings {
  my ($context)=@_;
  my $h = $keyBindings{$context};
  return ref($h) ? %$h : undef;
}
sub copy_key_bindings {
  my ($source_context, $destination_context)=@_;
  my $s = $keyBindings{$source_context};
  return unless ref($s);
  my $d = ($keyBindings{$destination_context}||={});
  while (my ($k,$v)=each %$s) {
    $d->{$k} = $v;
  }
  return $d;
}
sub copy_menu_bindings {
  my ($source_context, $destination_context)=@_;
  my $s = $menuBindings{$source_context};
  return unless ref($s);
  my $d = ($menuBindings{$destination_context}||={});
  while (my ($k,$v)=each %$s) {
    $d->{$k} = $v;
  }
  return $d;
}

sub read_macros {
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

  my ($file,$libDir,$keep,$encoding)=(shift,shift,shift,shift);
  $macrosEvaluated=0;
  local *F;
  my @contexts=@_;
  $encoding = $defaultMacroEncoding unless $encoding ne "";
  @contexts=("TredMacro") unless (@contexts);
  unless ($keep) {
    %keyBindings=();
    %menuBindings=();
    @macros=();
    $exec_code=undef;
    print STDERR "Reading $defaultMacroFile\n" if $macroDebug;
    push @macros,"\n#line 1 \"$defaultMacroFile\"\n";
    print "ERROR: Cannot open macros: $defaultMacroFile!\n", return 0
      unless open(F,"<$defaultMacroFile");
    set_encoding(\*F,$encoding);
    push @macros, <F>;
    close F;
  }
  print STDERR "Reading $file\n" if $macroDebug;
  open(F,"<$file")
    || (!$keep && ($file="$libDir/$file") && open(F,"<$file")) ||
      die "ERROR: Cannot open macros: $file ($!)!\n";
  set_encoding(\*F,$encoding);

#
# new "pragmas":
#
# include <file>  ... relative to tred's libdir
# include "file"  ... relative to dir of the current macro file
# include file    ... absolute or relative to current dir or one of the above
#
# ifinclude       ... as include but without producing an error if file doesn't exist
#
# binding-context <context> [<context> [...]]
#
# key-binding-adopt <contexts>
# menu-binding-adopt <contexts>
#
# bind <method> [to] [key[sym]] <key> [menu <menu>[/submenu[/...]]]
#
# insert <method> [as] [menu] <menu>[/submenu[/...]]
#

  push @macros,"\n#line 1 \"$file\"\n";
  my $line=1;
  my @conditions;
  my $ifok=1;
  while (<F>) {
    $line++;
    if (/^\#endif(?:$|\s)/) {
      push @macros,$_;
      if (@conditions) {
	pop @conditions;
	$ifok = (!@conditions || $conditions[$#conditions]);
      } else {
	die "unmatched #endif in \"$file\" line $line\n";
      }
    } elsif (/^\#elseif\s+(\S*)$|^\#else(?:if)?(?:\s|$)/) {
      if (@conditions) {
	my $prev = ($#conditions>0) ? $conditions[$#conditions-1] : 1;
	if (defined($1)) {
	  $conditions[$#conditions]= $prev &&
	    !$conditions[$#conditions] && is_defined($1);
	} else {
	  $conditions[$#conditions]=$prev && !$conditions[$#conditions];
	}
	$ifok = $conditions[$#conditions];
      } else {
	die "unmatched #elseif in \"$file\" line $line\n";
      }
    } elsif (/^\#ifdef\s+(\S*)/) {
      push @macros,$_;
      push @conditions, (is_defined($1) && (!@conditions || $conditions[$#conditions]));
      $ifok = $conditions[$#conditions];
    } elsif (/^\#ifndef\s+(\S*)/) {
      push @macros,$_;
      push @conditions, (!is_defined($1) && (!@conditions || $conditions[$#conditions]));
      $ifok = $conditions[$#conditions];
    } else {
      if ($ifok) {
	if (/^\s*__END__/) {
	  last;
	} elsif (/^\s*__DATA__/) {
	  warn "Warning: __DATA__ has no meaning in TredMacro (ise __END__ instead) at $file line $line\n";
	  last;
	}
	push @macros,$_;
	if (/^\#!(.*)$/) {
	  $exec_code=$1 unless defined $exec_code; # first wins
	} elsif (/^\#define\s+(\S*)(?:\s+(.*))?/) {
	  define_symbol($1, $2); # there is no use for $2 so far
	} elsif (/^\#undefine\s+(\S*)/) {
	  undefine_symbol($1);
	} elsif (/^\#\s*binding-context\s+(.*)/) {
	  @contexts=(split /\s+/,$1) if $ifok;
	} elsif (/^\#\s*key-binding-adopt\s+(.*)/) {
	  my @toadopt=(split /\s+/,$1);
	  foreach my $context (@contexts) {
	    foreach my $toadopt (@toadopt) {
	      copy_key_bindings($toadopt,$context);
	    }
	  }
	} elsif (/^\#\s*menu-binding-adopt\s+(.*)/) {
	  my @toadopt=(split /\s+/,$1);
	  foreach my $context (@contexts) {
	    foreach my $toadopt (@toadopt) {
	      copy_menu_bindings($toadopt,$context);
	    }
	  }
	} elsif (/^\#[ \t]*unbind-key[ \t]+([^ \t\r\n]+)/) {
	  my $key=$1;
	  unbind_key($_,$key) for @contexts;
	} elsif (/^\#[ \t]*bind[ \t]+(\w+(?:-\>\w+)?)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+([^\r\n]+))?/) {
	  my ($macro,$key,$menu)=($1,$2,$3);
	  $menu = TrEd::Convert::encode($menu);
	  if ($menu) { add_to_menu($_, $menu => $macro) for @contexts; }
	  bind_key($_, $key => $macro) for @contexts;
	} elsif (/^\#\s*insert[ \t]+(\w*)[ \t]+(?:as[ \t]+)?(?:menu[ \t]+)?([^\r\n]+)/) {
	  my $macro=$1;
	  my $menu=TrEd::Convert::encode($2);
	  add_to_menu($_, $menu, $macro) for @contexts;
	} elsif (/^\#\s*remove-menu[ \t]+([^\r\n]+)/) {
	  my $menu=TrEd::Convert::encode($1);
	  remove_from_menu($_, $menu) for @contexts;
	} elsif (/^\#\s*(if)?include\s+\<([^\r\n]+\S)\>\s*(?:encoding\s+(\S+)\s*)?$/) {
	  my $enc = $3;
	  my $mf="$libDir/$2";
	  if (-f $mf) {
	    read_macros($mf,$libDir,1,$enc,@contexts);
	    push @macros,"\n#line $line \"$file\"\n";
	  } elsif ($1 ne 'if') {
	    die
	      "Error including macros $mf\n from $file: ",
		"file not found!\n";
	  }
	} elsif (/^\#\s*(if)?include\s+"([^\r\n]+\S)"\s*(?:encoding\s+(\S+)\s*)?$/) {
	  my $enc = $3;
	  my $pattern = $2;
	  my @includes;
	  if ($pattern=~/^<(.*)>$/) {
	    my $glob = $1;
	    my ($vol,$dir) = File::Spec->splitpath(dirname($file));
	    $dir = File::Spec->catpath($vol,$dir); 
	    my $cwd = cwd();
	    chdir $dir;
	    @includes = map { File::Spec->rel2abs($_) } glob($glob);
	    chdir $cwd;
	  } else {
	    @includes = (dirname($file).$pattern);
	  }
	  foreach my $mf (@includes) {
	    if (-f $mf) {
	      read_macros($mf,$libDir,1,$enc,@contexts);
	      push @macros,"\n#line $line \"$file\"\n";
	    } elsif ($1 ne 'if') {
	      die
		"Error including macros $mf\n from $file: ",
		  "file not found!\n";
	    }
	  }
	} elsif (/^\#\s*(if)?include\s+([^\r\n]+?\S)\s*(?:encoding\s+(\S+)\s*)?$/) {
	  my ($if,$f,$enc) = ($1,$2,$3);
	  if ($f=~m%^/%) {
	    read_macros($f,$libDir,1,$enc,@contexts);
	    push @macros,"\n#line $line \"$file\"\n";
	  } else {
	    my $mf=$f;
	    print STDERR "including $mf\n" if $macroDebug;
	    unless (-f $mf) {
	      $mf=dirname($file).$mf;
	      print STDERR "trying $mf\n" if $macroDebug;
	      unless (-f $mf) {
		$mf="$libDir/$f";
		print STDERR "not found, trying $mf\n" if $macroDebug;
	      }
	    }
	    if (-f $mf) {
	      read_macros($mf,$libDir,1,$enc,@contexts);
	      push @macros,"\n#line $line \"$file\"\n";
	    } elsif ($if ne 'if') {
	      die
		"Error including macros $mf\n from $file: ",
		  "file not found!\n";
	    }
	  }
	} elsif (/^\#\s*encoding\s+(\S+)\s*$/) {
	  set_encoding(\*F,$1);
	}
      } else {
	# $ifok == 0
	push @macros,"\n"; # only for line numbering purposes
      }
    }
  }
  die "Missing #endif in $file line $line (".scalar(@conditions)." unmatched #if-pragmas)\n" if (@conditions);
  close(F);
  print STDERR "Read ",scalar(@macros)." lines of code.\n" if !$keep and $macroDebug;
  return 1;
}

sub set_encoding {
  my $fh = shift;
  my $enc = shift || $defaultMacroEncoding;
  if ($useEncoding and $enc) {
    eval {
      $fh->flush();
      binmode $fh;  # first get rid of all I/O layers
      if (lc($enc) =~ /^utf-?8$/) {
	binmode $fh,":utf8";
      } else {
	binmode $fh,":encoding($enc)";
      }
    };
    print STDERR $@ if $@;
  }
}

#
# The $win parameter to the following two routines should be
# a hash reference, having at least the following keys:
#
# FSFile       => FSFile blessed reference of the current FSFile
# treeNo       => number of the current tree in the file
# macroContext => current context under which macros are run 
#
# the $win itself is passed to the macro in the $grp variable
#
# Macros expect the following (minimally) variables set:
# $TredMacro::root    ... root of the current tree
# $TredMacro::this    ... current node
# $TredMacro::libDir  ... path to TrEd's library directory
#
# Macros signal the results of their operation using the following
# variables
#
# $TredMacro::FileNotSaved   ... if 0, macro claims it has done no no changes
#                                that would need saving
# $TredMacos::forceFileSaved ... if 1, macro claims it saved the file itself

sub initialize_macros {
  my ($win)=@_;		# $win is a reference
                        # which should in this way be made visible
                        # to macros
  my $result = 2;
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  unless ($macrosEvaluated) {
    my $macros="{\n".$utf.join("",@macros)."\n}; 1;\n";
    print STDERR "FirstEvaluation of macros\n" if $macroDebug;
    if (defined($safeCompartment)) {
      set_macro_variable('grp',$win);
      my %packages;
      # dirty hack to support ->isa in safe compartment
      $macros=~s{(\n\s*package\s+(\S+?)\s*;)}
	{ exists($packages{$2}) ? $1 : do { $packages{$2} = 1; $1.'sub isa {for(@ISA){return 1 if $_ eq $_[1]}}'} }ge;
      $macrosEvaluated=1;
      {
	no strict;
	$result = $safeCompartment->reval($macros);
      }
      TrEd::Basics::errorMessage($win,$@) if $@;
    } else {
      no strict;
      ${TredMacro::grp}=$win;
      $macrosEvaluated=1;
      $result=eval { my $res=eval ($macros); die $@ if $@; $res; };
    }
    print STDERR "Returned with: $result\n\n" if $macroDebug;
    TrEd::Basics::errorMessage($win,$@) if $@;
  }
  no strict 'refs';
  set_macro_variable('grp',$win);
  return $result;
}

sub macro_variable {
  my $prefix = ($_[0] =~ /::/) ? '' : 'TredMacro::';
  if (defined($safeCompartment)) {
    $safeCompartment->varglob($prefix.$_[0]);
  } else {
    $prefix.$_[0]
  }
}

sub get_macro_variable {
  no strict 'refs';
  ${ &macro_variable };
}

sub set_macro_variable {
  no strict 'refs';
  while (@_) {
    ${ &macro_variable } = $_[1];
    shift; shift;
  }
}

my @_saved_vars = qw(grp this root FileNotSaved forceFileSaved);

sub save_ctxt {
  return [ map { get_macro_variable($_) } @_saved_vars ];
}
sub restore_ctxt {
  my $ctxt = shift;
  my $i=0;
  for my $var (@_saved_vars) {
    set_macro_variable($var, $ctxt->[$i++]);
  }
}

sub do_eval_macro {
  my ($win,$macro)=@_;		# $win is a reference
				# which should in this way be made visible
				# to macros
  return 0,0,$TredMacro::this unless $macro;
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

sub context_can {
  my ($context,$sub)=@_;
  if (defined($safeCompartment)) {
    no strict;
    return $safeCompartment->reval("\${'${context}::'}{'$sub'}");
  } else {
    return UNIVERSAL::can($context,$sub);
  }
}

sub context_isa {
  my ($context,$package)=@_;
  if (defined($safeCompartment)) {
    no strict;
    return grep { $_ eq $package } $safeCompartment->reval("\@${context}::ISA") ? 1 : undef;
  } else {
    return UNIVERSAL::isa($context,$package);
  }
}

sub do_eval_hook {
  my ($win,$context,$hook)=(shift,shift,shift);  # $win is a reference
				# which should in this way be made visible
				# to hooks
  print STDERR "about to run the hook: '$hook' (in $context context)\n" if $hookDebug;
  return undef unless $hook; # and $TredMacro::this;
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  undef $@;
  initialize_macros($win);
  return undef if $@;
  my $result=undef;

  if (context_isa($context,'TrEd::Context') and context_can($context,$hook)) {
    # experimental new-style calling convention
    print STDERR "running hook $context".'->global->'.$hook."\n" if $hookDebug;
    if (defined($safeCompartment)) {
      no strict;
      $safeCompartment->reval($utf."$context\-\>global\-\>$hook(\@_)");
    } else {
      no strict;
      $result=eval($utf."$context\-\>global\-\>$hook(\@_)");
    }
  } else {
    if (context_can($context,$hook)) {
      print STDERR "running hook $context"."::"."$hook\n" if $hookDebug;
      if (defined($safeCompartment)) {
	no strict;
	$safeCompartment->reval($utf."\&$context\:\:$hook(\@_)");
      } else {
	no strict;
	$result=eval($utf."\&$context\:\:$hook(\@_)");
      }
    } elsif ($context ne "TredMacro" and context_can('TredMacro',$hook)) {
      print STDERR "running hook Tredmacro"."::"."$hook\n" if $hookDebug;
      if (defined($safeCompartment)) {
	no strict;
	$safeCompartment->reval($utf."\&TredMacro\:\:$hook(\@_)");
      } else {
	no strict;
	$result=eval($utf."\&TredMacro\:\:$hook(\@_)");
      }
    }
  }

  return $result;
}

1;
