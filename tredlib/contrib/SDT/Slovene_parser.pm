#!/usr/bin/perl

# Slovene dependency parser, version 0.0.1
# written by Zdenek Zabokrtsky, March 2003

# this package is to be used e.g. as follows:
# btred -T -e 'use Slovene_parser;$FileNotSaved=1;Slovene_parser::run_parser($root,$grp)' demo.fs


package Slovene_parser;
use strict;
use Fslib;

my ($root,$grp);
my @temporary_attributes=('attached', 'saturated', 'segment', 'ending_segment',
			 'efftag','efflemma','effform','prep_relpron',
			  'subord_clause','direct_speech',
			  'coordination', 'rel_clause');
my @segments;

# ---------------------------------------------------------------
# --------- Interface to the MULTEXT-EAST POS tagset ------------


sub adjective { return $_[0]->{efftag}=~/^A/ }
sub adverb { return $_[0]->{efftag}=~/^R/ }
sub adjectival { return $_[0]->{efftag}=~/^(A|Ps|M[oc]|P.........a)/ }
sub noun { return $_[0]->{efftag}=~/^N/ }
sub personal_pronoun { return $_[0]->{efftag}=~/^Pp/ } #ZO
sub preposition { return ($_[0]->{efftag}=~/^S/ or $_[0]->{efflemma} eq "kot")}
sub subordinating_conjunction { return ($_[0]->{efftag}=~/^Css/ or $_[0]->{lemma} eq 'ali') }
sub relative_pronoun { return $_[0]->{efftag}=~/^Pr/ }
sub numeral { return $_[0]->{efftag}=~/^M/ }

sub case {
  if ($_[0]->{efftag}=~/^N...(.)/) {return $1}
}

# -----------------------------------------------------------------------
# --------- Reduction rules, part 1 - shallow constructions only --------

my @window; # sliding window

sub preposition_and_pronoun {
  if (preposition($window[0]) and personal_pronoun($window[1]) and not $window[0]->{saturated}) {
    attach($window[1],$window[0],'preposition_and_pronoun');
    $window[0]->{saturated}=1;
    return 1;
  }
}

# ---------------------------------------------------------------------------
# --------- Reduction rules, part 2 - potentially recursive constructions ---

sub adjectival_and_noun {
  if (adjectival($window[0]) and noun($window[1])) {
    attach($window[0],$window[1],'adjectival_and_noun');
    return 1;
  }
}

sub preposition_and_noun {
   if (preposition($window[0]) and noun($window[1]) and not $window[0]->{saturated}) {
    attach($window[1],$window[0],'preposition_and_noun');
    $window[0]->{saturated}=1;
    return 1;
  }
}

sub prep_adverb_adj {
  if (preposition($window[0]) and adverb($window[1]) and adjectival($window[2])) {
    attach($window[1],$window[2],'prep_adverb_adj');
    return 1;
  }
}

sub adnominal_genitive {
  if (noun($window[0]) and noun($window[1]) and case($window[1]) eq "g") {
    attach($window[1],$window[0],'adnominal_genitive' );
    return 1;
  }
}

sub subord_clause {
  my $clause_type;
  if ($window[0]->{effform} eq "," and $window[2] and
    (((relative_pronoun($window[1]) or $window[1]->{prep_relpron} or $window[1]->{lemma} eq 'ki')
      and $clause_type='relpron') or
     (subordinating_conjunction($window[1]) and $clause_type='subconj'))) {
#    my $clausenodes=[grep {$_->{ord}>$window[1]->{ord} and not $_->{attached}}
#		    $root->descendants()];
    recompute_clause_segmentation();
    my $clausenodes=$segments[$window[2]->{segment}];
    my $rightmost=${$clausenodes}[-1];
    my ($immediate_right_neighbor)=    sort {$a->{ord}<=>$b->{ord}}
      grep {$_->{ord}>$rightmost->{ord} and !$_->{attached}} $root->descendants();
    my $right_comma;
    if ($immediate_right_neighbor->{effform} eq ",") {$right_comma=$immediate_right_neighbor};
    if ($clause_type eq "subconj") {shift @$clausenodes};
    my $clausehead=parse_clause($clausenodes);
    if ($clause_type eq "relpron") {
      attach($window[0],$clausehead,'comma_on_subord_clause_head');
      attach($window[1],$clausehead,'rel_pron_on_clause_head');
      if ($right_comma) {attach($right_comma,$clausehead)}
      $clausehead->{subord_clause}=1;
      my ($candidate_noun)=sort {$b->{ord}<=>$a->{ord}}
	grep {$_->{ord}<$window[0]->{ord} and (noun($_) or $_->{tag}=~/^P.........n/)} $root->descendants();
      if ($candidate_noun) {
	attach($clausehead,$candidate_noun,'noun_relclause');
      }
    }
    else {
      attach($window[0],$window[1],'comma_on_subconj');
      attach($clausehead,$window[1],'clausehead_on_subconj');
      if ($right_comma) {attach($right_comma,$window[1])};
      $window[1]->{saturated}=1;
      $window[1]->{subord_clause}=1;
    }
    return 1;
  }
}

sub intersent_coord {
  if ($window[1]->{efflemma}=~/^(in|,)$/ and strict_clause_boundary($window[1]) and $window[2]) {
    print "Intersent coord!!!!!!!!!\n";
    print "Testuju pravou: ";
    my $right_clause_head=parse_clause($segments[$window[2]->{segment}]);
    attach($right_clause_head,$window[1],'intersent_coord');
    $right_clause_head->{parallel}='Co';
    my $left_clause_head=parse_clause($segments[$window[0]->{segment}]);
    attach($left_clause_head,$window[1], 'intersent_coord');
    $left_clause_head->{parallel}='Co';
    return 1;
  }
  return 0;
}

sub coordinable {
  my ($node1,$node2)=@_;
  return ((adverb($node1) and adverb($node2)) or
	  (adjective($node1) and adjective($node2)) or
	  (numeral($node1) and numeral($node2)) or
	  (noun($node1) and noun($node2) and case($node1)==case($node2))
	 );
}

sub substitute_effectives {
  my ($what,$withwhat)=@_;
  print "?????????? \n\n\n";
  foreach my $attr ('tag','lemma','form') {
    print  "Substitute:  ".$what->{"eff$attr"}." with ".$withwhat->{"eff$attr"}."\n";
    $what->{"eff$attr"}=$withwhat->{"eff$attr"};
  }
  print "End of substitution\n";
}

sub intrasent_coord {
  if ($window[1]->{efflemma}=~/^(in|ali|,)$/ and
 #     eval {  print "Trying coordinate: $window[0]->{effform} a $window[2]->{effform}\n" } and
      !strict_clause_boundary($window[1]) and $window[2] and
      coordinable($window[0],$window[2])) {
    if ($window[2]{coordination}) {
      attach($window[0],$window[2],'multiple_coord');
      $window[0]->{parallel}='Co';
      attach($window[1],$window[2],'multiple_coord');
    }
    else {
      attach($window[0],$window[1],'intrasent_coord');
      $window[0]->{parallel}='Co';
      attach($window[2],$window[1],'intrasent_coord');
      $window[2]->{parallel}='Co';
    }
    substitute_effectives($window[1],$window[0]);
    $window[1]{coordination}=1;
    return 1;
  }
#  return 0;
}

sub multiple_times { # tri hkrati
#  print "Tried HKRATI  on $window[0]->{form} (efftag $window[0]->{efftag})  $window[1]->{form}\n\n";
  if ($window[0]->{efftag}=~/^M/ and $window[1]->{lemma} eq 'hkrati') {
    attach($window[0],$window[1],'multiple_times');
    return 1
  }
}

sub prep_anything {
  if (preposition($window[0]) and !$window[0]->{saturated} and $window[1]) {
    attach($window[1],$window[0],'prep_anything');
    $window[0]{saturated}=1;
    if (relative_pronoun($window[1])) {$window[0]{prep_relpron}=1}
    return 1;
  }
}

sub adjective_se {
    if (adjective($window[0]) and $window[1]->{lemma} eq "se") {
	attach($window[1],$window[0],'adjective_se');
	return 1;
    }
}


# --------------------------------------------------
# --------- Auxiliary functions --------------------
my %applied_rules;

sub attach ($$$) { # 'hanging' a child node below its parent
  my ($childnode,$parentnode,$rulename)=@_;
#  print "Attach node '$childnode->{effform}' below '$parentnode->{effform}'\n";
  Cut($childnode);
  Paste($childnode,$parentnode,$grp->{FSFile}->FS->defs());
#  print "Hotovo\n";
  $childnode->{attached}=1;
  $applied_rules{$rulename}++;
  $childnode->{commentA}=$rulename;
}

sub recompute_clause_segmentation {
  @segments=();
  my $current_segment=0;
  foreach my $node (sort {$a->{ord}<=>$b->{ord}} $root->descendants()) {
     if ($node->{attached}) {delete $node->{segment}}
     elsif ($node->{efflemma}=~/^(,|in)$/) {
       $node->{ending_segment}=$current_segment;
       $current_segment++;
       $segments[$current_segment]=[];
#       print "new seg - $current_segment\n";
     }
     else {
       $node->{segment}=$current_segment;
       push @{$segments[$current_segment]},$node;
     }
   }
#  print "----------- Segmentation -----------\n";
#  foreach my $s (0..$#segments) {
#    print "Segment $s: ".(join " ",map {$_->{effform}} @{$segments[$s]})."\n";
#  }
#  print "--------- End of Segmentation ------\n";
}

sub strict_clause_boundary {
  my ($separator)=@_;
  recompute_clause_segmentation();
  my @potential_clause=(@{$segments[$separator->{ending_segment}]},
			@{$segments[1+$separator->{ending_segment}]} );

#  print "Potential clause: ".(join " ",map {$_->{effform}} @potential_clause)."\n";

  my $verbs=join " ",sort map {($_->{efftag}."-----")=~/^(....)/;$1}
    grep {$_->{efftag}=~/^V[com]/ and
	      (!$_->{subord_clause}) and (!$_->{direct_speech})} @potential_clause;


  my $regexp=join "|",(
		       'V[mo]ip',  # hodi / he walks
		       'Vcip V[mo]ps', # hodil je / he walked
		       'Vcif V[mo]ps', # hodil bo / he will walk
		       'Vcc V[mo]ps', # hodil bi / he would walk
		       'Vcip Vmp-', # je pozabljeno / it is forgotten
		       'Vcif Vmp-', # pozabljeno bo / it will be forgotten
		       'Vcip Vcps Vmp-', # pozabljeno je bilo / it was forgotten
		       'Vmm.', # pozabiti / forget
		       'Vc..',
		       ''  # no verb
		      );
#  print "Separator: $separator->{efflemma}\n";
#  if ($verbs=~/^($regexp)$/) {print ">> $verbs : One clause\n"}
#  else {print ">> $verbs : Not a single clause!\n";}
  return ($verbs!~/^($regexp)$/);
}


sub scan_with_rule ($$) {
  my ($rulename,$nodelist)=@_;
  my ($from,$to,$inc);
  my @indices=(0..$#$nodelist-1);
#  print "   applying: $rulename\n";
  if ($rulename=~s/>>//) {
  }
  elsif ($rulename!~s/<<//) {
    die "Wrong rule specification!";
  }
  else {@indices=reverse @indices};

  foreach my $window_start (@indices) {
    @window=@{[@$nodelist,0,0,0,0]}[$window_start..$window_start+3];
#    print "Window: ".(join " ",map {$_->{ord}} @window)."\n";
#    print "Eval: $rulename()\n";
    if (eval ("$rulename()")) {return 1}
  }
}


sub parse_clause($) {
  my ($nodelist)=@_;
  my $clausehead;
#  print  "---parse_clause: ".(join " ",map {$_->{effform}} @$nodelist)."\n";
  foreach my $regexp ('^Vm[imcpu]','^V.p','^V') {
    if (($clausehead)=grep {$_->{efftag}=~/$regexp/ and
				!$_->{subord_clause} and !$_->{direct_speech}}
	@$nodelist) {last}
  }
  if (not $clausehead) {$clausehead=${$nodelist}[-1]}; #rightmost
  foreach my $node (grep {$_->{ord}!=$clausehead->{ord}} @$nodelist) {
    attach($node,$clausehead,'everything_on_clause_head');
  }
#  print "---parse_clause finished";
  return $clausehead;
}



my $shallow_rules='preposition_and_pronoun';

my $recursive_rules='<<adjectival_and_noun <<adjective_se <<intrasent_coord <<adnominal_genitive <<preposition_and_noun <<multiple_times <<prep_anything <<subord_clause <<intersent_coord';


sub parse_sentence ($) {

  my ($parentless)=@_;
  my $success;

  print "Parsing sentence: ". (join " ",map {$_->{effform}} @$parentless)."\n";

  my $lastnode=${$parentless}[-1];
  my $last_dot;
  if ($lastnode->{effform} eq ".") {
    attach (${$parentless}[-1],$root,'last_dot');
    $last_dot=${$parentless}[-1];
    $parentless=[@{$parentless}[0..$#$parentless-1]];
  };

  # try to apply all shallow rules
  foreach my $rulename (split /\s/,$shallow_rules)
    { scan_with_rule(">>$rulename",$parentless) }
  print "  shallow rules finished\n";

  # try to apply all recursive rules
  do {
    my $parentless=[grep {not $_->{attached}} @$parentless];
    $success=0;
    foreach my $rulename (split /\s/,$recursive_rules) {
      if (scan_with_rule($rulename,$parentless)) {
	$success=1;
	last
      }
    }
  } while ($success);

  print "  recursive rules finished\n";

  # if nothing else is applicable, consider the remaining node list as a single clause
  my $parentless=[grep {not $_->{attached}} @$parentless];
  my $sentence_head;
  if (@$parentless>1) { $sentence_head = parse_clause($parentless) }
  else { ($sentence_head) = @$parentless }
  if ($last_dot) {  attach($last_dot,$sentence_head,'last_dot') }
  print "End of parse_sentence\n";
  return $sentence_head;

}

# -------------------------------------------
# --------- MAIN ----------------------------

sub run_parser ($$) {
  print STDERR "next sentence\n";
  ($root,$grp)=@_;
  @segments=();
  recompute_clause_segmentation();

  foreach my $node ($root->descendants()) { # flattening the original structure, if any
      $node->{attached}=0;
      Cut($node);
      Paste($node,$root,$grp->{FSFile}->FS->defs());
      foreach my $attr ('tag','lemma','form') {
	  $node->{"eff$attr"}=$node->{$attr};
      }
  }

  my $parentless=[grep {not $_->{attached}}
		  sort {$a->{ord} <=> $b->{ord} } $root->descendants()];

  # test
  foreach my $index (1..$#$parentless) {
    if (${$parentless}[$index]->{effform}=~/^(,|in)/) {
#      possibly_in_one_clause(${$parentless}[$index-1],${$parentless}[$index+1] );
      strict_clause_boundary(${$parentless}[$index]);
    }
  }

  # /test

  # ----------- directed speech treatment
  # (token sequence between "", if there is any, is parsed as a sentence
  my @quot= grep {$_->{effform}=~/\"/} @$parentless;
  if (@quot==2) {
    my $direct_speech=[grep {$_->{ord}>$quot[0]->{ord} and 
			  $_->{ord}<$quot[1]->{ord}} @$parentless];
    if (@$direct_speech) {
	my $dsp_head=parse_sentence($direct_speech);
	$dsp_head->{direct_speech}=1;
	attach($quot[0],$dsp_head,'left_quot');
	attach($quot[1],$dsp_head,'right_quot');
	$parentless=[grep {!$_->{attached}} @$parentless];
    }
  }


#  my @parentheses=grep {$_->{efflemma}=~/[()]/} @$parentless;
#  print "--------------- Zavorky: ".(join "",map {$_->{efflemma}} @parentheses)."\n\n";
#  if ((join "",map {$_->{efflemma}} @parentheses) eq "()") {
#    my $parenthesed_head=
#      parse_sentence([grep { $_->{ord} > $parentheses[0]->{ord} and
#			  $_->{ord} < $parentheses[1]->{ord}} @$parentless]);
#    attach($parentheses[0],$parenthesed_head,'left_parenthese');
#    attach($parentheses[1],$parenthesed_head,'right_parenthese');
#    $parentless=[grep {!$_->{attached}} @$parentless];
#  }


  parse_sentence($parentless);

  foreach my $node (grep {not $_->{attached}} @$parentless) {
    attach($node,$root,'hang_remaining_on_root')
  }

  foreach my $node ($root->descendants()) {
    foreach my $attr (@temporary_attributes) {
      delete $node->{$attr}
    }
  }

  print "Parsing correctly finished!\n";
}


# ------------------------------------------------
# ------ Evaluation ------------------------------

#END {
#
#  print "Applied rules:\n";
#  print join "",map {"$applied_rules{$_}   $_\n"}
#    sort {$applied_rules{$b}<=>$applied_rules{$a}} keys %applied_rules;
#
#
#}
