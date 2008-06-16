package TrEd::Utils;
# pajas@ufal.ms.mff.cuni.cz          28 úno 2007

use 5.006;
use strict; 

use Carp;
use Data::Dumper;
use List::Util qw(first min max);
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
  applyFileSuffix
  parseFileSuffix
  getNodeByNo
  applyWindowStylesheet
  fileSchema
  chooseNodeType

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
  } elsif ($filename=~/^(.*)(##[0-9]+\.)([^0-9#][^#]*)$/ and PMLSchema::CDATA->check_string_format($3,'ID')) {
    return ($1,$2.$3);
  } elsif ($filename=~/^(.*)#([^#]+)$/ and PMLSchema::CDATA->check_string_format($2,'ID')) {
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
    $win->{treeNo}=min(max(0,$1-1),$fsfile->lastTreeNo);
  } elsif ($goto=~/^#([0-9]+)/) {
    # this is PDT 1.0-specific code, sorry
    for (my $i=0;$i<=$fsfile->lastTreeNo;$i++) {
      $win->{treeNo}=$i,last if ($fsfile->treeList->[$i]->{form} eq "#$1");
    }
  } elsif ($goto=~/^#([^#]+)$/) {
    my $id = $1;
    if (PMLSchema::CDATA->check_string_format($id,'ID')) {
      my $id_hash = $fsfile->appData('id-hash');
      if (UNIVERSAL::isa($id_hash,'HASH') and exists($id_hash->{$id})) {
	my $node = $id_hash->{$id};
	# we would like to use Fslib::Index() here, but can't
	my $list = $fsfile->treeList;
	my $n = first {
	  $list->[$_]==$node->root
	} 0..$#$list;
	if (defined($n)) {
	  $win->{treeNo}=$n;
	  $win->{currentNode}=$node;
	  return;
	}
      }
    }
  }
  # new: we're the dot in .[0-9]+ (TM)
  if ($goto=~/\.([0-9]+)$/) {
    my $root=getNodeByNo($win,$1);
    if ($root) {
      $win->{currentNode}=$root;
    }
  } elsif ($goto=~/\.([^0-9#][^#]*)$/) {
    my $id = $1;
    if (PMLSchema::CDATA->check_string_format($id,'ID')) {
      my $id_hash = $fsfile->appData('id-hash');
      if (UNIVERSAL::isa($id_hash,'HASH') and exists($id_hash->{$id})) {
	$win->{currentNode}=$id_hash->{$id};
      }
    }
  }
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

sub fileSchema {
  my ($fsfile)=@_;
  return $fsfile->metaData('schema');
}

sub chooseNodeType {
  my ($fsfile,$node,$opts)=@_;
  my $type = $node->type;
  return $type if $type;
  my $ntype;
  my @ntypes;
  if ($node->parent) {
    # is parent's type known?
    my $parent_decl = $node->parent->type;
    if (ref($parent_decl)) {
      # ok, find #CHILDNODES
      my $parent_decl_type = $parent_decl->get_decl_type;
      my $member_decl;
      if ($parent_decl_type == PML_STRUCTURE_DECL()) {
	($member_decl) = map { $_->get_content_decl } 
	  $parent_decl->find_members_by_role('#CHILDNODES');
      } elsif ($parent_decl_type == PML_CONTAINER_DECL()) {
	$member_decl = $parent_decl->get_content_decl;
	undef $member_decl unless $member_decl and $member_decl->get_role eq '#CHILDNODES';
      }
      if ($member_decl) {
	my $member_decl_type = $member_decl->get_decl_type;
	if ($member_decl_type == PML_LIST_DECL()) {
	  $ntype = $member_decl->get_content_decl;
	  undef $ntype unless $ntype and $ntype->get_role eq '#NODE';
	} elsif ($member_decl_type == PML_SEQUENCE_DECL()) {
	  my $elements = 
	  @ntypes = grep { $_->[1]->get_role eq '#NODE' }
	    map { [ $_->get_name, $_->get_content_decl ] }
	      $member_decl->get_elements;
	  if (defined $node->{'#name'}) {
	    $ntype = first { $_->[0] eq $node->{'#name'} } @ntypes;
	    $ntype=$ntype->[1] if $ntype;
	  }
	} else {
	  die "I'm confused - found role #CHILDNODES on a ".$member_decl->get_decl_type_str().", which is neither a list nor a sequence...\n".
	    Dumper($member_decl);
	}
      }
    } else {
      # ask the user to set the type of the parent first
      die("Parent node type is unknown.\nYou must assign node-type to the parent node first!");
      return;
    }
  } else {
    # find #TREES sequence representing the tree list
    my @tree_types;
    my $pml_trees_type = $fsfile->metaData('pml_trees_type');
    if (ref $pml_trees_type) {
      @tree_types = ($pml_trees_type);
    } else {
      my $schema = fileSchema($fsfile);
      @tree_types = $schema->find_types_by_role('#TREES');
    }
    foreach my $tt (map { $_->get_content_decl } @tree_types) {
      if (!ref($tt)) {
	die("I'm confused - found role #TREES on something which is neither a list nor a sequence...\n".
	  Dumper($member_decl));
      } elsif ($tt->get_decl_type == PML_LIST_DECL()) {
	$ntype = $tt->get_content_decl;
	undef $ntype unless $ntype and $ntype->get_role eq '#NODE';
      } elsif ($tt->get_decl_type == PML_SEQUENCE_DECL()) {
	my $elements = 
	  @ntypes = grep { $_->[1]->get_role eq '#NODE' }
	    map { [ $_->get_name, $_->get_content_decl ] }
	    $tt->get_elements;
	  if (defined $node->{'#name'}) {
	    $ntype = first { $_->[0] eq $node->{'#name'} } @ntypes;
	    $ntype=$ntype->[1] if $ntype;
	  }
      } else {
	die ("I'm confused - found role #CHILDNODES on something which is neither a list nor a sequence...\n".
	  Dumper($tt));
      }
    }
  }
  if ($ntype) {
    $base_type = $ntype;
    $node->set_type($base_type);
  } elsif (@ntypes == 1) {
    $node->{'#name'} = $ntypes[0][0];
    $base_type = $ntypes[0][1];
    $node->set_type($base_type);
  } elsif (@ntypes > 1) {
    my $i = 1;
    if (ref($opts) and $opts->{choose_command}) {
      my $type = $opts->{choose_command}->($fsfile,$node,[@ntypes]);
      if ($type and first { $_==$type } @ntypes) {
	$node->set_type($type->[1]);
	$node->{'#name'} = $type->[0];
	$base_type=$node->type;
      } else {
	return;
      }
    }
  } else {
    die("Cannot determine node type: schema does not allow nodes on this level...\n");
    return;
  }
  return $node->type;
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

