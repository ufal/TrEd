package TrEd::Macros;

BEGIN {
  use Fslib;
  use TrEd::Config;
  use TrEd::Basics;
  import TrEd::Config qw($defaultMacroFile $defaultMacroEncoding $macroDebug $hookDebug);

  use TrEd::Convert;
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $exec_code @macros $useEncoding
              $macrosEvaluated $safeCompartment %defines);

  @ISA=qw(Exporter);
  $VERSION = "0.1";
  @EXPORT = qw(
    &read_macros
    &do_eval_macro
    &do_eval_hook
    &macro_variable
    %keyBindings
    %menuBindings
    @macros
    $macrosEvaluated
  );
  $useEncoding = ($]>=5.008);
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

  my ($file,$libDir,$keep,$encoding)=(shift,shift,shift,shift);
  $macrosEvaluated=0;
  my $macro;
  my $key;
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
    } elsif (/^\#elseif\s*$|^\#elseif\s+(\S*)$/) {
      if (@conditions) {
	if (defined($1)) {
	  $conditions[$#conditions]=
	    !$conditions[$#conditions] &&
	    (exists($defines{$1}) && (!@conditions || $conditions[$#conditions]));
	} else {
	  $conditions[$#conditions]=!$conditions[$#conditions];
	}
	$ifok = $conditions[$#conditions];
      } else {
	die "unmatched #elseif in \"$file\" line $line\n";
      }
    } else {
      if ($ifok) {
	push @macros,$_;
	if (/^\#!(.*)$/) {
	  $exec_code=$1 unless defined $exec_code; # first wins
	} elsif (/^\#define\s+(\S*)(?:\s+(.*))?/) {
	  $defines{$1}=$2;	# there is no use for $2 so far
	} elsif (/^\#undefine\s+(\S*)/) {
	  delete $defines{$1};
	} elsif (/^\#ifdef\s+(\S*)/) {
	  push @conditions, (exists($defines{$1}) && (!@conditions || $conditions[$#conditions]));
	  $ifok = $conditions[$#conditions];
	} elsif (/^\#ifndef\s+(\S*)/) {
	  push @conditions, (!exists($defines{$1}) && (!@conditions || $conditions[$#conditions]));
	  $ifok = $conditions[$#conditions];
	} elsif (/^\#[ \t]*binding-context[ \t]+(.*)/) {
	  @contexts=(split /[ \t]+/,$1) if $ifok;
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
	  $key=~s/\-/+/g;	# convert ctrl-x to ctrl+x
	  $key=~s/[^+]+[+-]/uc($&)/eg; # uppercase modifiers
	  foreach (@contexts) {
	    next unless exists($keyBindings{$_});
	    delete $keyBindings{$_}{$key};
	  }
	} elsif (/^\#[ \t]*bind[ \t]+(\w*)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+(.+))?/) {
	  $macro=$1;
	  $key=$2;
	  $menu=TrEd::Convert::encode($3);
	  $key=~s/\-/+/g;	# convert ctrl-x to ctrl+x
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
	} elsif (/^\#\s*(if)?include\s+\<(.+\S)\>\s*(?:encoding\s+(\S+)\s*)?$/) {
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
	} elsif (/^\#\s*(if)?include\s+"(.+\S)"\s*(?:encoding\s+(\S+)\s*)?$/) {
	  my $enc = $3;
	  $mf=dirname($file).$2;
	  if (-f $mf) {
	    read_macros($mf,$libDir,1,$enc,@contexts);
	    push @macros,"\n#line $line \"$file\"\n";
	  } elsif ($1 ne 'if') {
	    die
	      "Error including macros $mf\n from $file: ",
		"file not found!\n";
	  }
	} elsif (/^\#\s*(if)?include\s+(.+?\S)\s*(?:encoding\s+(\S+)\s*)?$/) {
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
  die "Missing #endif in $file (".scalar(@conditions)." unmatched #if-pragmas)\n" if (@conditions);
  close(F);
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
    my $macros=$utf.join("",@macros)."\n; return 1;";
    if (defined($safeCompartment)) {
      ${macro_variable('TredMacro::grp')}=$win;
      my %packages;
      # dirty hack to support ->isa in safe compartment
      $macros=~s{\n\s*package\s+(\S+?)\s*;}
	{ exists($packages{$1}) ? $& : do { $packages{$1} = 1; $&.'sub isa {for(@ISA){return 1 if $_ eq $_[1]}}'} }ge;
      $result=
	$safeCompartment
	  ->reval($macros);
      print STDERR $@ if $@;
    } else {
      ${macro_variable('TredMacro::grp')}=$win;
      $result=eval ($macros);
    }
    $macrosEvaluated=1;
    print STDERR "FirstEvaluation of macros\n" if $macroDebug;
    print STDERR "Returned with: $result\n\n" if $macroDebug;
    print STDERR $@ if $@
  }
  ${macro_variable('TredMacro::grp')}=$win;
  return $result;
}

sub macro_variable {
  my ($name)=@_;
  if (defined($safeCompartment)) {
    $safeCompartment->varglob($name);
  } else {
    $name
  }
}

sub do_eval_macro {
  my ($win,$macro)=@_;		# $win is a reference
				# which should in this way be made visible
				# to macros
  return 0,0,$TredMacro::this unless $macro;
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  my $result;
  initialize_macros($win);
  print STDERR "Running $macro\n" if $macroDebug;
  if (defined($safeCompartment)) {
    ${macro_variable('TredMacro::grp')}=$win;
    $result = $safeCompartment->reval($utf.$macro);
  } else {
    $result = eval($utf.$macro);
  }
  TrEd::Basics::errorMessage($win,$@) if ($@);
  print STDERR "Had run: ",$macro,"\n" if $macroDebug;
  print STDERR "Returned with: $result\n" if $macroDebug;
  return $result;
}

sub context_can {
  my ($context,$sub)=@_;
  if (defined($safeCompartment)) {
    return $safeCompartment->reval($utf."\${'${context}::'}{'$sub'}");
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
  my $utf = ($useEncoding) ? "use utf8;\n" : "";
  initialize_macros($win);
  my $result=undef;

  if (context_can($context,$hook)) {
    print STDERR "running hook $context"."::"."$hook\n" if $hookDebug;
    if (defined($safeCompartment)) {
      $safeCompartment->reval($utf."\&$context\:\:$hook(\@_)");
    } else {
      $result=eval($utf."\&$context\:\:$hook(\@_)");
    }
  } elsif ($context ne "TredMacro" and context_can('TredMacro',$hook)) {
    print STDERR "running hook Tredmacro"."::"."$hook\n" if $hookDebug;
    if (defined($safeCompartment)) {
      $safeCompartment->reval($utf."\&TredMacro\:\:$hook(\@_)");
    } else {
      $result=eval($utf."\&TredMacro\:\:$hook(\@_)");
    }
  }

  return $result;
}

1;
