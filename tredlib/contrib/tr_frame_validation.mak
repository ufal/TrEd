# -*- cperl -*-
#encoding iso-8859-2

package TR_FrameValidation;
use vars qw($V_backend $V_module $V_verbose $V);
@ISA=qw(TR_Correction);
sub first (&@);
sub with_AR (&);
import TR_Correction;
sub uniq { my %a; @a{@_}=@_; values %a }

#bind only_parent_aidrefs to Ctrl+p menu Make only parent have the current node among its AIDREFS
#bind make_lighten_be_aidrefs to Ctrl+l menu Make nodes marked with _light=_LIGHT_ be the nodes and only the nodes referencing current node in AIDREFS
#bind light_aidrefs to Ctrl+a menu Mark AIDREFS nodes with _light = _LIGHT_
#bind light_aidrefs_reverse to Ctrl+b menu Mark nodes pointing to current via AIDREFS with _light = _LIGHT_
#bind analytical_tree to Ctrl+A menu Display analytical tree
#bind tectogrammatical_tree to Ctrl+R menu Display tectogrammatical tree, discarding changes to analytical tree
#bind tectogrammatical_tree_store_AR to Ctrl+B menu Display tectogrammatical tree, storing changes to analytical tree

#include <contrib/frame_validation.mak>

$V_backend = 'JHXML';
#$V_backend = 'LibXML';

$V_module = 'ValLex::Extended'.$V_backend;


sub init_vallex {
  $TrEd::ValLex::Editor::reviewer_can_modify=1;

  require ValLex::Data;
  unless (defined($V)) {
    my $tredmodule = 'TrEd::'.$V_module;
    eval "require ${V_module}"; die $@ if $@;
#ifdef TRED
    require TrEd::CPConvert;
#    $Tectogrammatic::vallex_file = $V_vallex;
    $Tectogrammatic::vallex_validate = 1;
    $Tectogrammatic::XMLDataClass = $tredmodule;
    $Tectogrammatic::frameid_attr="frameid";
    $Tectogrammatic::framere_attr="framere";

    Tectogrammatic::init_XMLDataClass();
    Tectogrammatic::InitFrameData() || return;
    $V=$Tectogrammatic::FrameData;
#else
    $V_vallex = "$libDir/contrib/ValLex/vallex.xml";
    require ValLex::DummyConv;
    $V = $tredmodule->new($V_vallex,TrEd::ValLex::DummyConv->new(),0);
#endif
    unless ($V) {
      print "ERROR loading vallex\n";
      die "No Vallex\n";
    }
  }
  %{$V->user_cache}=() if defined($V) and defined($V->user_cache()); # clear cache
}

sub reload_macros_hook {
  if ($V) {
    $V->doc_free();
    $V = undef;
    $FrameData = undef;
  }
}


sub frame_chosen {
  my ($grp,$chooser)=@_;
  return unless $grp and $grp->{focusedWindow};
  TR_Correction::frame_chosen(@_);
  my $win = $grp->{focusedWindow};
  if ($win->{FSFile} and
      $win->{currentNode}) {
    my $field = $chooser->focused_framelist()->field();
    my $node = $win->{currentNode};
    main::doEvalMacro($win,__PACKAGE__.'->validate_assigned_frames');
  }
}


#bind open_frame_editor to Ctrl+Shift+Return menu Edit valency lexicon
sub open_frame_editor {
  init_vallex();
  OpenEditor();
}

#bind choose_frame_or_advfunc_validate to Ctrl+Return menu Select frame from valency lexicon
#bind choose_frame_or_advfunc_validate to F1 menu Select frame from valency lexicon

sub choose_frame_or_advfunc_validate {
  init_vallex();
  print "FID: $this->{frameid}\n";
  return unless ($this->{tag}=~/^[VAN]/);
  ChooseFrame(\&frame_chosen);
}



#bind assign_dispmod to Ctrl+asterisk menu Assign dispmod=DISPMOD to this node
sub assign_dispmod {
  unless (exists($defs->{dispmod})) {
    AppendFSHeader('@P dispmod',
		   '@L dispmod|---|NA|NIL|DISP|???');
  }
  $this->{dispmod}='DISP';
}

#bind assign_state to Ctrl+equal menu Assign state=ST
sub assign_state {
  unless (exists($defs->{state})) {
    AppendFSHeader('@P state',
		   '@L state|---|NA|NIL|ST|???');
  }
  $this->{state}='ST';
}

#bind validate_assigned_frames_resolve to Ctrl+M menu Resolve frameid and validate against it
sub validate_assigned_frames_resolve {
  validate_assigned_frames($this,1);
}

#bind validate_assigned_frames_tolerant to Alt+m menu Validate against assigned frameid being tolerant to ExD
sub validate_assigned_frames_tolerant {
  local $ExD_tolerant = 1;
  validate_assigned_frames(@_);
}

#bind validate_assigned_frames to Ctrl+m menu Validate against assigned frameid
sub validate_assigned_frames {
  shift if @_ and !ref($_[0]);
  my $node = $_[0] || $this;
  my $fix = $_[1];
  foreach ($node->root->descendants) {
    delete $_->{_light};
  }
  init_vallex();
  my $aids = hash_AIDs_file();
  eval {
    binmode STDOUT;
    if ($^O eq 'MSWin32') {
      if ($::ENV{OS} eq 'Windows_NT') {
	binmode STDOUT,":encoding(cp1250)";
      } else {
	binmode STDOUT,":encoding(cp852)";
      }
    } elsif ($::ENV{LC_CTYPE}=~/UTF-?8/i) {
      binmode STDOUT,':utf8';
    } else {
      binmode STDOUT,':encoding(iso-8859-2)';
    }
  }; print STDERR $@ if $@;
  local $V_verbose = 1;
  print "\n\n==================================================\n";
  print $node->{trlemma}."\t".$node->{frameid}."\t".ThisAddress($node)."\n";
  print "==================================================\n";
  if ($node->{tag}=~/^[NA]/
      or ($node->{tag}=~/^Vs/ and $node->{trlemma} =~ /[nt]ý$/)) {
    my $pj4 = hash_pj4($node->root);
    if (check_nounadj_frames($node,$aids,'frameid',$pj4,{strict_subclause=>1,ExD_tolerant => $ExD_tolerant})==0) {
      $node->{_light}='_LIGHT_';
    }
  } else {
    if (check_verb_frames($node,$aids,'frameid',$fix,{strict_subclause=>1,ExD_tolerant => $ExD_tolerant})==0) {
      $node->{_light}='_LIGHT_';
    }
  }
  ChangingFile(0);
}


sub status_line_doubleclick_hook {
  # status-line field double clicked
  # there is also status_line_click_hook for single clicks

  # @_ contains a list of style names associated with the clicked
  # field. Style names may obey arbitrary user-defined convention.

  foreach (@_) {
    if (/^\{(.*)}$/) {
      if ($1 eq 'FRAME') {
	choose_frame_or_advfunc_validate();
	last;
      } elsif ($1 eq 'AIDREFS') {
	print "Light aidrefs\n";
	light_aidrefs();
	Redraw();
	last;
      } elsif ($1 eq 'AID') {
	print "Light aidrefs reverse\n";
	light_aidrefs_reverse();
	Redraw();
	last;
      } else {
	if (main::doEditAttr($grp,$this,$1)) {
	  ChangingFile(1);
	}
	last;
      }
    }
  }
}

sub get_status_line_hook {
  # get_status_line_hook may either return a string
  # or a pair [ field-definitions, field-styles ]
  return [
	  # status line field definitions ( field-text => [ field-styles ] )
	  [
	   "form: " => [qw(label)],
	   $this->{form} => [qw({form} value)],
	   ($this->{framere} ne "" ?
	    ("   frame: " => [qw(label)],
	     $this->{framere} => [qw({FRAME} value)]
	    ) : ()),
	   "   " => [qw(label)],
	   $this->{lemma} => [qw({lemma} value)],
	   "   " => [qw(label)],
	   $this->{tag} => [qw({tag} value)],
	   "   " => [qw(label)],
	   $this->{afun} => [qw({afun} value)],
	   "   A/TID: " => [qw(label)],
	   $this->{AID} => [qw({AID} value)],
	   $this->{TID} => [qw({TID} value)],
	   ($this->{AIDREFS} ne "" ?
	     ("   AIDREFS: " => [qw(label)],
	      join(", ",split /\|/,$this->{AIDREFS}) => [qw({AIDREFS} value)]) : ()),
	   ($this->{commentA} ne "" ?
	    ("     [" => [qw()],
	     $this->{commentA} => [qw({commentA})],
	     "]" => [qw()]
	    ) : ())
	  ],

	  # field styles
	  [
	   "label" => [-foreground => 'black' ],
	   "value" => [-underline => 1 ],
	   "{commentA}" => [ -foreground => 'red' ],
	   "{FRAME}" => [ -foreground => 'blue' ],
	   "{afun}" => [ -foreground => 'darkgreen' ],
	   "{tag}" => [ -foreground => 'chocolate3' ],
	   "{lemma}" => [ -foreground => 'chocolate4' ],
	   "bg_white" => [ -background => 'white' ],
	  ]

	 ];
}


# just an experiment
sub get_value_line_hook {
   my ($fsfile,$treeNo)=@_;
   my @vl = $fsfile->value_line_list($treeNo,1,1);
   %colors = ( ACT => 'red',
	       PAT => 'blue',
	       EFF => 'green',
	       PRED => 'gray' );
   @vl = map {
     push @$_, "-underline => 1, -background => cyan" if ($_->[1]->{_light} eq '_LIGHT_');
     $_,[" ",'space']
   } @vl;
   return \@vl;
}

sub node_style_hook {
  my ($node, $style)=@_;
  TR_Correction::node_style_hook(@_);
  if ($node->{_light} eq '_LIGHT_') {
    push @{$style->{Oval}}, -fill => 'cyan';
    push @{$style->{Node}}, -addwidth => 7, -addheight => 7;
  }
}
