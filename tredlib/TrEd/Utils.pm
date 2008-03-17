package TrEd::Utils;
# pajas@ufal.ms.mff.cuni.cz          28 úno 2007

use 5.006;
use strict; 

use Carp;
use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);

use constant {
  STYLESHEET_FROM_FILE  => "<From File>",
  NEW_STYLESHEET        => "<New From Current>",
  DELETE_STYLESHEET     => "<Delete Current>",

  EMPTY                 => qw(),
};

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use TrEd::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  fetch_from_win32_reg
  find_win_home
  readStyleSheets
  saveStyleSheets
  getStylesheetPatterns
  setStylesheetPatterns
  updateStylesheetMenu
  getStylesheetMenuList

  STYLESHEET_FROM_FILE
  NEW_STYLESHEET
  DELETE_STYLESHEET
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(  );
our $VERSION = '0.01';

sub fetch_from_win32_reg {
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

sub find_win_home {
  # in Windows, if HOME not defined, use user's AppData folder instaed
  if ($^O eq "MSWin32" and !exists $ENV{HOME}) {
    my $key = q(Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders);
    my $home = fetch_from_win32_reg
      ('HKEY_CURRENT_USER',
     $key,
       'AppData');
    if (defined($home)) {
      $ENV{HOME}= $home;
    } else {
      die "Couldn't fetch $key from Win32 registry: $^E\n";
    }
  }
}

sub saveStyleSheets {
  my ($gui,$stylesheetFile)=@_;
  open my $f, '>:utf8',$stylesheetFile || do {
    print STDERR "cannot write to stylesheet file: $stylesheetFile\n";
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

sub readStyleSheets {
  my ($gui,$filename)=@_;
  open my $f, '<:utf8',$filename || do {
    print STDERR "no stylesheet file: $filename\n";
    return 0;
  };
  my $stylesheet="Default";
  $gui->{stylesheets}={};
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
       $match = '.*' unless $match =~ /\S/;
       $context =~ /^${match}$/x ? 1 : 0;
     }
   } sort keys %{$grp->{stylesheets}}];
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

