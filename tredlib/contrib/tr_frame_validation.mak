# -*- cperl -*-
#encoding iso-8859-2

package TR_FrameValidation;
@ISA=qw(TR_Correction);
sub first (&@);
sub with_AR (&);
import TR_Correction;
sub uniq { my %a; @a{@_}=@_; values %a }

#bind only_parent_aidrefs to Ctrl+p menu Make only parent have the current node among its AIDREFS
#bind make_lighten_be_aidrefs to Ctrl+l menu Make nodes marked with _light=_LIGHT_ be the nodes and only the nodes referencing current node in AIDREFS

#include <contrib/frame_validation.mak>

$V_backend = 'JHXML';
#$V_backend = 'LibXML';

$V_module = 'ValLex::Extended'.$V_backend;

sub init_vallex {
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
    %cache=();
#endif
    unless ($V) {
      print "ERROR loading vallex\n";
      die "No Vallex\n";
    }
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
		   '@L dispmod|---|NA|NIL|DISPMOD|???');
  }
  $this->{dispmod}='DISPMOD';
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

#bind validate_assigned_frames to Ctrl+m menu Validate against assigned frameid
sub validate_assigned_frames {
  shift if @_ and !ref($_[0]);
  my $node = $_[0] || $this;
  my $fix = $_[1];
  foreach ($node->root->descendants) {
    delete $_->{_light};
  }
  init_vallex();
  my $aids = hash_AIDs();
  unless ($ENV{LC_CTYPE}=~/UTF-?8/i) {
    binmode STDOUT;
    binmode STDOUT,':utf8';
  }
  local $V_verbose = 1;
  print "\n\n==================================================\n";
  print $node->{trlemma}."\t".ThisAddress($node)."\n";
  print "==================================================\n";
  if (check_verb_frames($node,$aids,'frameid',$fix)==0) {
    $node->{_light}='_LIGHT_';
  }
  ChangingFile(0);
}
