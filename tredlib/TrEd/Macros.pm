package TrEd::Macros;

BEGIN {
  use Fslib;
  use TrEd::Config;
  import TrEd::Config qw($defaultMacroFile $macroDebug $hookDebug);

  use TrEd::Convert;
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK 
              $macrosEvaluated);

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
    print "ERROR: Cannot open macros: $defaultMacroFile!\n", return
      unless open(F,"<$defaultMacroFile");
    push @macros, <F>;
    close F;
  }

  print "ERROR: Cannot open macros: $file!\n", return
    unless open(F,"<$file");

#
# new "pragmas":
#
# include <file>
# include "file"
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
  while (<F>) {
    push @macros,$_;
    if (/\#[ \t]*binding-context[ \t]+(.*)/) {
      @contexts=(split /[ \t]+/,$1);
    } elsif (/\#[ \t]*key-binding-adopt[ \t]+(.*)/) {
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
    } elsif (/\#[ \t]*menu-binding-adopt[ \t]+(.*)/) {
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
    } elsif (/\#[ \t]*bind[ \t]+(\w*)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+(.+))?/)
      {
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
      } elsif (/\#[ \t]*insert[ \t]+(\w*)[ \t]+(?:as[ \t]+)?(?:menu[ \t]+)?(.+)/) {
	$macro=$1;
	$menu=TrEd::Convert::encode($2);
	foreach (@contexts) {
	  $menuBindings{$_}={} unless exists($menuBindings{$_});
	  $menuBindings{$_}->{$menu}=["$_"."->"."$macro",$key] if ($menu);
	}
      } elsif (/\#[[ \t]*include[ \t]+(.+)/) {
	my $mf=$1;
#	print STDERR "including $mf\n";
	unless (-f $mf) {
	  $mf=dirname($file).$mf;
#	  print STDERR "trying $mf\n";
	  unless (-f $mf) {
	    $mf="$libDir/$1";
#	    print STDERR "not found, trying $mf\n";
	  }
	}
	if (-f $mf) {
	  read_macros($mf,$libDir,1,@contexts);
	} else {
	  print STDERR "Cannot include macros\n$mf\n to $file: file not found!\n";
	}
      }
  }
  close(F);
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



sub do_eval_macro {
  my ($win,$macro)=@_;		# $win is a reference
				# which should in this way be made visible
				# to macros

  $TredMacro::grp=$win;
  return 0,0,$TredMacro::this unless $macro;

  unless ($macrosEvaluated) {
    eval (join("",@macros)."\n return 1;");
    $macrosEvaluated=1;
    if ($result or $@) {
      print STDERR "FirstEvaluation of macros\n" if $macroDebug;
      print STDERR "Returned with: $result\n$@\n" if $macroDebug;
    }
  }
  print STDERR "Running $macro\n" if $macroDebug;
  my $result=eval("$macro");
  if ($result or $@) {
    print STDERR "Had run: ",$macro,"\n" if $macroDebug;
    print STDERR "Returned with: $result\n$@\n" if $macroDebug;
  }
  return $result;
}

sub do_eval_hook {
  my ($win,$context,$hook)=(shift,shift,shift);  # $win is a reference
				# which should in this way be made visible
				# to hooks
  print STDERR "about to run a hook $hook\n" if $hookDebug;
  $TredMacro::grp=$win;
  print STDERR "testing $hook and $TredMacro::this\n" if $hookDebug;
  return undef unless $hook; # and $TredMacro::this;
  print STDERR "no problem, continuing\n" if $hookDebug;

  unless ($macrosEvaluated) {
    eval (join("",@macros)."\n return 1;");
    $macrosEvaluated=1;
    if ($result or $@) {
      print STDERR "FirstEvaluation of macros\n" if $macroDebug;
      print STDERR "Returned with: $result\n$@\n" if $macroDebug;
    }
  }

  my $result=undef;
  if ($context->can($hook)) {
    print STDERR "running hook $context"."::"."$hook\n" if $hookDebug;
    $result=eval { return &{"$context\:\:$hook"}(@_); };
  } elsif ($context ne "TredMacro" and TredMacro->can($hook)) {
    print STDERR "running hook Tredmacro"."::"."$hook\n" if $hookDebug;
    $result=eval { return &{"TredMacro\:\:$hook"}(@_); };
  }
  return $result;
}

1;
