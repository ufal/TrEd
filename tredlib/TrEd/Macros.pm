package TrEd::Macros;

BEGIN {
  use Fslib;
  use TrEd::Config;
  use TrEd::Basics;
  import TrEd::Config qw($defaultMacroFile $macroDebug $hookDebug);

  use TrEd::Convert;
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK 
              $macrosEvaluated $safeCompartment);

  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    &read_macros
    &do_eval_macro
    &do_eval_hook
    %keyBindings
    %menuBindings
    @macros
    $macrosEvaluated
  );
  use strict;
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

  my ($file,$libDir,$keep)=(shift,shift,shift);
  $macrosEvaluated=0;
  my $macro;
  my $key;
  local *F;
  my @contexts=@_;

  @contexts=("TredMacro") unless (@contexts);
  unless ($keep) {
    %keyBindings=();
    %menuBindings=();
    @macros=();
    push @macros,"\n#line 1 \"$defaultMacroFile\"\n";
    print "ERROR: Cannot open macros: $defaultMacroFile!\n", return 0
      unless open(F,"<$defaultMacroFile");
    push @macros, <F>;
    close F;
  }
  open(F,"<$file")
    || (!$keep && ($file="$libDir/$file") && open(F,"<$file")) ||
      die "ERROR: Cannot open macros: $file ($!)!\n";

#
# new "pragmas":
#
# include <file>  ... relative to tred's libdir
# include "file"  ... relative to dir of the current macro file
# include file    ... absolute or relative to current dir or one of the above
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
  my $line;
  while (<F>) {
    $line++;
    push @macros,$_;
    if (/^\#[ \t]*binding-context[ \t]+(.*)/) {
      @contexts=(split /[ \t]+/,$1);
    } elsif (/^\#[ \t]*key-binding-adopt[ \t]+(.*)/) {
      my @toadopt=(split /[ \t]+/,$1);
      my $context;
      my $toadopt;
      foreach $context (@contexts) {
	$keyBindings{$context}={} unless exists($keyBindings{$context});
	foreach $toadopt (@toadopt) {
	  foreach (keys %{$keyBindings{$toadopt}}) {
	    $keyBindings{$context}->{$_}=$keyBindings{$toadopt}->{$_};
	  }
	}
      }
    } elsif (/^\#[ \t]*menu-binding-adopt[ \t]+(.*)/) {
      my @toadopt=(split /[ \t]+/,$1);
      my $context;
      my $toadopt;
      foreach $context (@contexts) {
	$menuBindings{$context}={} unless exists($menuBindings{$context});
	foreach $toadopt (@toadopt) {
	  foreach (keys %{$menuBindings{$toadopt}}) {
	    $menuBindings{$context}->{$_}=$menuBindings{$toadopt}->{$_};
	  }
	}
      }
    } elsif (/^\#[ \t]*unbind-key[ \t]([^ \t\r\n]+)?/) {
      $key=$1;
      $key=~s/\-/+/g;		     # convert ctrl-x to ctrl+x
      $key=~s/[^+]+[+-]/uc($&)/eg; # uppercase modifiers
      foreach (@contexts) {
	next unless exists($keyBindings{$_});
	delete $keyBindings{$_}{$key};
      }
    } elsif (/^\#[ \t]*bind[ \t]+(\w*)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+(.+))?/) {
	$macro=$1;
	$key=$2;
	$menu=TrEd::Convert::encode($3);
	$key=~s/\-/+/g;		     # convert ctrl-x to ctrl+x
	$key=~s/[^+]+[+-]/uc($&)/eg; # uppercase modifiers
	#print "binding $key [$menu] => $macro\n";
	foreach (@contexts) {
	  $keyBindings{$_}={} unless exists($keyBindings{$_});
	  $keyBindings{$_}->{$key}="$_"."->"."$macro";
	  if ($menu) {
	    $menuBindings{$_}={} unless exists($menuBindings{$_});
	    $menuBindings{$_}->{$menu}=["$_"."->"."$macro",$key] if ($menu);
	  }
	}
      } elsif (/^\#\s*insert[ \t]+(\w*)[ \t]+(?:as[ \t]+)?(?:menu[ \t]+)?(.+)/) {
	$macro=$1;
	$menu=TrEd::Convert::encode($2);
	foreach (@contexts) {
	  $menuBindings{$_}={} unless exists($menuBindings{$_});
	  $menuBindings{$_}->{$menu}=["$_"."->"."$macro",undef] if ($menu);
	}
      } elsif (/^\#\s*remove-menu[ \t]+(.+)/) {
	$menu=TrEd::Convert::encode($1);
	foreach (@contexts) {
	  next unless exists($menuBindings{$_});
	  delete $menuBindings{$_}{$menu};
	}
      } elsif (/^\#\s*include\s+\<(.+\S)\>\s*$/) {
	my $mf="$libDir/$1";
	if (-f $mf) {
	  read_macros($mf,$libDir,1,@contexts);
	  push @macros,"\n#line $line \"$file\"\n";
	} else {
	  die 
	    "Error including macros $mf\n from $file: ",
	    "file not found!\n";
	}
      } elsif (/^\#\s*include\s+"(.+\S)"\s*$/) {
	$mf=dirname($file).$1;
	if (-f $mf) {
	  read_macros($mf,$libDir,1,@contexts);
	  push @macros,"\n#line $line \"$file\"\n";
	} else {
	  die
	    "Error including macros $mf\n from $file: ",
	    "file not found!\n";
	}
      } elsif (/^\#\s*include\s+(.+\S)\s*$/) {
	my $f=$1;
	if ($f=~m%^/%) {
	  read_macros($f,$libDir,1,@contexts);
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
	    read_macros($mf,$libDir,1,@contexts);
	    push @macros,"\n#line $line \"$file\"\n";
	  } else {
	    die
	      "Error including macros $mf\n from $file: ",
		"file not found!\n";
	  }
	}
      }
  }
  close(F);
  return 1;
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
  unless ($macrosEvaluated) {
    if (defined($safeCompartment)) {
      ${$safeCompartment->varglob('TredMacro::grp')}=$win;
      my $macros=join("",@macros)."\n return 1;";
      my %packages;
      # dirty hack to support ->isa in safe compartment
      $macros=~s/\n\s*package\s+(\S+?)\s*;/exists($packages{$1}) ? $1 : $&.'sub isa {for(@ISA){return 1 if $_ eq $_[1]}}'/ge;
      $result=
	$safeCompartment
	  ->reval($macros);
#     print STDERR "running:\n",substr($macros,0,1000),"\n";
    } else {
      $TredMacro::grp=$win;
      $result=eval (join("",@macros)."\n; return 1;");
    }
    $macrosEvaluated=1;
    print STDERR "FirstEvaluation of macros\n" if $macroDebug;
    print STDERR "Returned with: $result\n\n" if $macroDebug;
    if ($result or $@) {
      print STDERR $@ if $@;
    }
  }
  $TredMacro::grp=$win;
  return $result;
}

sub do_eval_macro {
  my ($win,$macro)=@_;		# $win is a reference
				# which should in this way be made visible
				# to macros

  return 0,0,$TredMacro::this unless $macro;
  my $result;
  initialize_macros($win);
  print STDERR "Running $macro\n" if $macroDebug;
  if (defined($safeCompartment)) {
    ${$safeCompartment->varglob('TredMacro::grp')}=$win;
    $result = $safeCompartment->reval("$macro");
  } else {
    $result = eval("$macro");
  }
  TrEd::Basics::errorMessage($win,$@) if ($@);
  print STDERR "Had run: ",$macro,"\n" if $macroDebug;
  print STDERR "Returned with: $result\n" if $macroDebug;
  return $result;
}

sub context_can {
  my ($context,$sub)=@_;
  if (defined($safeCompartment)) {
    return $safeCompartment->reval("\${'${context}::'}{'$sub'}");
  } else {
    return $context->can($sub);
  }
}

sub do_eval_hook {
  my ($win,$context,$hook)=(shift,shift,shift);  # $win is a reference
				# which should in this way be made visible
				# to hooks
  print STDERR "about to run the hook: '$hook' (in $context context)\n" if $hookDebug;
  return undef unless $hook; # and $TredMacro::this;
  initialize_macros($win);
  my $result=undef;

  if (context_can($context,$hook)) {
    print STDERR "running hook $context"."::"."$hook\n" if $hookDebug;
    if (defined($safeCompartment)) {
      $safeCompartment->reval("\&$context\:\:$hook(\@_)");
    } else {
      $result=eval { return &{"$context\:\:$hook"}(@_); };
    }
  } elsif ($context ne "TredMacro" and context_can('TredMacro',$hook)) {
    print STDERR "running hook Tredmacro"."::"."$hook\n" if $hookDebug;
    if (defined($safeCompartment)) {
      $safeCompartment->reval("\&TredMacro\:\:$hook(\@_)");
    } else {
      $result=eval { return &{"TredMacro\:\:$hook"}(@_); };
    }
  }

  return $result;
}

1;
