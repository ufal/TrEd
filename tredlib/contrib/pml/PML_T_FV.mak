# -*- mode: cperl; coding: iso-8859-2; -*-
#encoding iso-8859-2

#include <contrib/pml/contrib.mac>

package PML_T_FV;
BEGIN { import TredMacro };

#binding-context PML_T_FV 
#include <contrib/pml/PML_T_Edit.inc>

#include "PML_T_FV.inc"

#key-binding-adopt PML_T_Edit
#menu-binding-adopt PML_T_Edit

*V = \$ValLex::GUI::ValencyLexicon;

#ifndef TRED
sub start_hook {
  init_vallex();
  die "vallex loading failed!\n" unless ($V);
}
sub exit_hook { undef $V; }
#endif

sub init_vallex {
  $V_verbose = 0;
  $V_backend = 'JHXML';
  $V_module = 'ValLex::Extended'.$V_backend;

  $TrEd::ValLex::Editor::reviewer_can_modify=1;
  require ValLex::Data;
  unless (defined($V)) {
    my $tredmodule = 'TrEd::'.$V_module;
    eval "require ${V_module}"; die $@ if $@;
    #ifdef TRED
    #else
    my $V_vallex = $ENV{VALLEX};
    if ($V_vallex eq "") {
      # try to find vallex in resources
      $V_vallex = FindInResources('vallex.xml') ||
	FindInResources('vallex.xml.gz');
    }
    require ValLex::DummyConv;
    $V = $tredmodule->new($V_vallex,TrEd::ValLex::DummyConv->new(),0);
    #endif
    unless ($V) {
      print "ERROR loading vallex: $V_vallex\n";
      die "No Vallex: $V_vallex\n";
    }
  }
  %{$V->user_cache}=() if defined($V) and defined($V->user_cache()); # clear cache
}

register_reload_macros_hook(sub {
  if ($V) {
    $V->doc_free();
    $V = undef;
    $ValLex::GUI::ValencyLexicon = undef;
  }
});

sub AssignValencyFrames {
  PML_T::AssignValencyFrames(@_);
  main::doEvalMacro($grp,__PACKAGE__.'->validate_assigned_frames');
}

#bind validate_assigned_frames_tolerant to Alt+v menu Validate against assigned frameid being tolerant to ExD
sub validate_assigned_frames_tolerant {
  local $ExD_tolerant = 1;
  validate_assigned_frames(@_);
}

#bind validate_assigned_frames to Ctrl+v menu Validate against assigned frameid
sub validate_assigned_frames {
  shift if @_ and !ref($_[0]);
  my $node = $_[0] || $this;
  my $fix = $_[1];
  init_vallex();
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
      binmode STDOUT,':utf8';
#      binmode STDOUT,':locale';
    }
  }; print STDERR $@ if $@;
  local $V_verbose = 1;
  print "\n\n==================================================\n";
  print $node->{t_lemma}."\t".$node->{'val_frame.rf'}."\t";
  Position($node);
  print "==================================================\n";
  my $sempos=$this->attr('gram/sempos');
  if ($sempos=~/^(?:n|adj|adv)/) {
    my $pj4 = hash_pj4($node->root);
    if (check_nounadj_frames($node,$pj4,{strict_subclause=>1,ExD_tolerant => $ExD_tolerant})==0) {
      $PML_T::show{$node->{id}}=1;
    }
  } elsif($sempos eq 'v') {
    if (check_verb_frames($node,$fix,{strict_subclause=>1,ExD_tolerant => $ExD_tolerant})==0) {
      $PML_T::show{$node->{id}}=1;
    }
  } else {
    questionQuery("Sorry!","Given word isn't a verb, nor noun, nor adjective, nor adverb\n".
		    "according to gram/sempos: $sempos.",
		  "Ok");
  }
  ChangingFile(0);
}

sub std_validate_verb {
  my $node = $this;
  if ($node!=$root and $node->attr('gram/sempos') eq 'v') {
    check_verb_frames($node,0, {
      ExD_tolerant => 1,
      fake_perspron => 0,
      ORIG_is_free => ($node->{trlemma} eq "být" ? 1:0),
      dont_report_redundant => 1,
      report_ok_transformations => $ARGV[0]
     });
  }
}

sub std_validate_noun {
  my $node = $this;
  return if (
    $node==$root
    or $node->{t_lemma}=~/^(století|čtvrtletí|desetiletí|pololetí|který)$/
    or not(
      $node->attr('gram/sempos') =~ /^n/ or
      $node->attr('gram/sempos') -~ /^adv/ 
	and $node->{t_lemma}=~/^(blízko|chtě|chtíc|nefér|nehledě|nemluvě|nepočítaje|nevidět|nevyjímaje|soudě|zapotřebí|závisle)$/
    )
    or $node->{t_lemma} eq "možný"
    or $node->{t_lemma} eq "třeba"
    or ($node->attr('gram/sempos') =~ /^n/
	and $node->{functor} ne "CPHR"
	and $node->{t_lemma}!~/[nt]í(_s[ie])?$/)
   );
  check_nounadj_frames($node,hash_pj4($root), {
    ExD_tolerant => 1,
    fake_perspron => 0,
    loose_dsp => 0,
    loose_subclause => 0,
    dont_report_redundant => 1
   } );
}

# just an experiment
sub get_value_line_hook {
   my ($fsfile,$treeNo)=@_;
   my $vl = PML_T_Edit::get_value_line_hook(@_);
   my %colors = ( ACT => 'red',
	       PAT => 'blue',
	       EFF => 'green',
	       PRED => 'gray' );
   return [ map {
     push @$_, "-underline => 1, -background => cyan"
       if (ref($_->[1]) eq 'FSNode' and $PML_T::show{$_->[1]->{id}});
     $_,
   } @$vl];
}



