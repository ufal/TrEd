# -*- cperl -*-
#encoding iso-8859-2

#########################
# Frame validation code #
#########################

=comment

Known issues:

- There is a KDO-RULE for (usually object or subject) subclauses
starting with "kdo" or "co".  It tries to verify the form of "kdo" or
"co" instead of the original node (which would be the root of the
subclause). This behaviour may/may not be incorrect, needs more
research.

- KDO-RULE is only applied if the subclause is NOT analytically
governed by "ten".

- KDO-RULE does not apply to subclauses with "jaky", "jak" etc.
Whether there will be a need for such rules is yet to be determined by
further research.

- Passivisation rules for se/AuxR are strict, meaning they will not
apply if the afun of "se" is AuxT or Obj. Fixing the analytical
layer is often required.

- A rule that would handle "po jablicku" is missing.

- 

=cut


sub _highest_coord {
  my ($node)=@_;
  while (PDT::is_valid_member_TR($node)) {
    $node=$node->parent;
  }
  return $node;
}

sub has_auxR {
  my ($node)=@_;
  my $result = 0;
  # skip infinitives, search for analytic AuxR
  with_AR {
    while ($node and $node->{tag}=~/^Vf/) {
      $result ||= (first { $_->{afun} eq 'AuxR' and $_->{lemma}=~/^se_/ }
		   PDT::GetChildren_AR($node,sub{1},sub{($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0})) ? 1 : 0;
      last if $result;
      $node = PDT::GetFather_AR($node,sub{0});
    }
    if (!$result and $node and $node->{tag}=~/^V/) {
      $result = (first { $_->{afun} eq 'AuxR' and $_->{lemma}=~/^se_/ }
		 PDT::GetChildren_AR($node,sub{1},sub{($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0})) ? 1 : 0;
    }
  };
  return $result;
}

@fv_passivization_rules = (
    [ 'ACT(.1)', 'PAT(.4)',
      ['EFF',
       qr/^\.a?4(\[(jako|{jako,jako¾to})(\/AuxY)?\])$/ ]] =>
    [ '-ACT(.1)', '+ACT(.7)', '-PAT(.4)', '+PAT(.1)',
      ['EFF',
       sub { s/^(\.a?)4(\[(jako|{jako,jako¾to})(\/AuxY)?\])$/${1}1${2}/ }
      ]],
    # frame test
    [ 'ACT(.1)', ['PAT', qr/^\.a?4(\[(jako|{jako,jako¾to})(\/AuxY)?\])?$/ ]]  =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)',
      ['PAT',sub { s/((?:^|,)\.a?)4((?:\[(jako|{jako,jako¾to})(\/AuxY)?\])?(?:,|$))/${1}1${2}/ } ]],
    # ditto for CPHR
    # form transformation rules:
    [ 'ACT(.1)', ['CPHR', qr/^[^\[]*[.:][^\[,:.]*4/ ] ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)', ['CPHR',sub { s/^([^\[]*[.:][^\[,:.]*)4/${1}1/ }]],
    # frame test
    [ 'ACT(.1)', 'ADDR(.4)' ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)', '-ADDR(.4)', '+ADDR(.1)' ],
    # frame test
    [ 'ACT(.1)', ['EFF', qr/^\.a?4(\[(jako|{jako,jako¾to})(\/AuxY)?\])?$/ ] ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)',
      ['EFF',
       sub { s/^(\.a?)4(\[(jako|{jako,jako¾to})(\/AuxY)?\])?$/${1}1${2}/ }
      ]]);

@fv_trans_rules_V =
  (
   # 1.
   [# verb test: "nekdo1.ADDR ma auto pronajmuto nekym2/od+nekoho2.ACT",
    # transforms to: "nekdo2.ACT pronajmul auto nekomu1.ADDR"
    sub { my ($node,$aids) = @_;
	  ($node->{tag}=~/^Vs/ and
	   (first { $_->{AID} ne "" and $_->{lemma} eq 'mít' } get_aidrefs_nodes($aids,$node)
	    and not first { $_->{AID} ne "" and $_->{lemma} ne 'mít' and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node))
	  ) ? 1:0;
	} =>
    # frame transformation rules:
    @fv_passivization_rules,
    # frame test
    [ 'ACT(.1)', 'ADDR(.3)' ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])', '-ADDR(.3)', '+ADDR(.1)' ],
   ],
   # 2.
   [# verb test: passive verb
    # applies to "problem je vyresen nekym", but not to "nekdo ma problem vyresen",
    # but should still apply to "problem ma byt vyresen"
    sub { my ($node,$aids) = @_;
	  ($node->{tag}=~/^Vs/ and
	   not (first { $_->{AID} ne "" and $_->{lemma} eq 'mít' } get_aidrefs_nodes($aids,$node)
		and not first { $_->{AID} ne "" and $_->{lemma} ne 'mít' and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node))
	  ) ? 1:0;
	} =>
    # frame transformation rules:
    @fv_passivization_rules,
    # frame test
    [ 'ACT(.1)' ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.7)' ],
   ],
   # 3.
   [# dispmod
    sub { $_[0]->{dispmod} eq "DISPMOD" } =>
    # frame transformation rules:
    # frame test
    [ 'ACT(.1)', 'PAT(.4)' ] =>
    [ '-ACT(.1)', '+ACT(.3)', '-PAT(.4)', '+PAT(.1)', '+(.[se])', '+MANN(*)' ],
    # frame test
    [ 'ACT(.1)' ] =>
    # form transformation rules:
    [ '-ACT(.1)', '+ACT(.3)', '+(.[se])', '+MANN(*)' ]
   ],
   # 4.
   [ # chce se mu riskovat
    sub {
      my ($node,$aids) = @_;
      return 0 unless $node->{tag}=~/^Vf/;
      if ($node->{TID} ne "") {
	($node) = first { $_->{AID} ne "" and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node);
	return 0 unless $node;
      }
      my ($p) = with_AR { PDT::GetFather_AR($node,sub{ ($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0 }) };
      return 0 unless $p and
	$p->{trlemma}=~/^chtít$/ and has_auxR($p);
      } =>
    [ 'ACT(.1)' ] =>
    [ '-ACT(.1)', '+ACT(.3)' ]
   ],
   # 5.
   [# verb test: verb treated as passive due to "se".AuxR
    sub {
      my ($node,$aids) = @_;
      return (first { $_->{AID} ne "" and $_->{tag}=~/^V/ and has_auxR($_)
		    } get_aidrefs_nodes($aids,$node)) ? 1: 0;
    }
    # used to be ACT(!), but some abstract constructions with se.AuxR feel like ACT(.7)
    =>
    @fv_passivization_rules
   ],
   # 6.
   [ # nechat si/dat si udelat neco udelat od nekoho/nekym
    sub {
      my ($node,$aids) = @_;
      return 0 unless $node->{tag}=~/^Vf/;
      if ($node->{TID} ne "") {
	($node) = first { $_->{AID} ne "" and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node);
	return 0 unless $node;
      }
      my ($p) = with_AR { PDT::GetFather_AR($node,sub{ ($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0 }) };
      return 0 unless $p and
	$p->{trlemma}=~/^nechat$|^dát$/
      } =>
    [ 'ACT(.1)' ] =>
    [ '-ACT(.1)', '+ACT(od-1[.2];.7)' ]
   ],
  );


sub match_node_coord {
  my ($node, $fn,$aids,$loose_lemma) = @_;
  my $res = match_node($node,$fn,$aids,0,$loose_lemma);
  if (!$res and $node->{afun} =~ /^Coord|^Apos/) {
    foreach (grep { $node->{lemma} ne 'a-1' or $_->{lemma}!~/^(podobnì|daleko-1|dal¹í)(_|$)/ }
	     with_AR{PDT::expand_coord_apos($node)}) {
      return 0 unless match_node($_,$fn,$aids,0,$loose_lemma);
    }
    return 1;
  } else {
    return $res;
  }
}

sub get_aidrefs_nodes {
  my ($aids,$node)=@_;
  return grep { defined($_) } map { $aids->{$_} } grep { $_ ne "" } getAIDREFs($node);
}

sub is_numeric_expression {
  my ($node)=@_;
  return ($node->{tag} =~ /^C/ or $node->{lemma} =~ /^(?:dost|málo-3|hodnì|spousta|sto-[12]|tisíc-[12]|milión|miliarda|pár-[12]|pøíli¹)(?:\`|$|_)/) ? 1:0;
}

sub get_chilren_include_auxcp {
  my ($node)=@_;
  return with_AR { map { PDT::expand_coord_apos($_) } $node->children };
}

sub check_node_case {
  my ($node,$case)=@_;

  # simple case
  print "   CASE: Checking simple case\n" if $V_verbose;
  return 1 if $node->{tag}=~/^[NCPA]...(\d)/ and $case eq $1;
  print "   CASE: Checking AC..- tag ('vinen', etc.)\n" if $V_verbose;
  return 1 if $node->{tag}=~/^AC..-/;
  print "   CASE: Checking case X\n" if $V_verbose;
  return 1 if $node->{tag}=~/^[NCPA]...X/ or $node->{tag}=~/^X...-/;
  print "   CASE: Checking lemmas w/o case\n"  if $V_verbose;
  # special lemmas without case:
  return 1 if $node->{lemma} =~ /^(?:&percnt;|hodnì|málo-3|dost)(?:\`|$|_)/;
  print "   CASE: Checking simple number w/o case\n"  if $V_verbose;
  # simple number without case: e.g. 3
  return 1 if ($node->{tag}=~/^C=..\D/);
  print "   CASE: Checking 'kolem|okolo'+Num\n"  if $V_verbose;
  # kolem milionu (lidí)
  return 1 if $node->{lemma} =~ /^kolem-1|okolo-1$/ and $node->{afun}=~/^AuxP/ and
    first { $_->{tag}=~/^....2/ and is_numeric_expression($_) } get_chilren_include_auxcp($node);
  print "   CASE: Checking 'pres|na'+Num\n"  if $V_verbose;
  # pøes milion (lidí)
  return 1 if $node->{lemma} =~ /^(pøes-1|na-1)$/ and $node->{afun}=~/^AuxP/ and
    first { $_->{tag}=~/^....4/ and is_numeric_expression($_) } get_chilren_include_auxcp($node);
  print "   CASE: Checking num+2 construct\n"  if $V_verbose;
  # a number has the right case (or no case at all) and is analytically governing the node
  return 1 if ($node->{tag}=~/^....2/ and
	       first {
		 print("     CASE: testing parent instead: $_->{form}\n") if $V_verbose;
		 is_numeric_expression($_) and
		 (print("     CASE: parent is numeric: $_->{form}\n"),1) and
		   (($_->{tag}!~/^....(\d)/) or ($case == $1) or
		    ($_->{tag}=~/^....4/ and
		     grep { $_->{lemma} =~ /^(pøes-1|na-1)$/ and $_->{afun}=~/^AuxP/ }
		     with_AR { PDT::GetFather_AR($_,sub{0}) }
		    ) or
		    ($_->{tag}=~/^....2/ and
		     first {
		       $_->{lemma} =~ /^kolem-1|okolo-1$/ and $_->{afun}=~/^AuxP/ }
		     with_AR { PDT::GetFather_AR($_,sub{0}) }
		    ))
	       } with_AR { PDT::GetFather_AR($node,sub{0}) });
  print "   CASE: Checking 2+num construct\n"  if $V_verbose;
  return 1 if ($node->{tag}=~/^....2/ and
	       first {
		 is_numeric_expression($_) and (($_->{tag}!~/^....(\d)/) or ($case eq $1))
	       } get_chilren_include_auxcp($node));
  print "   CASE: All checks failed\n"  if $V_verbose;
  return 0;
}

sub match_node {
  my ($node, $fn, $aids,$no_case,$loose_lemma) = @_;
  my ($lemma,$form,$pos,$case,$gen,$num,$deg,$neg,$agreement,$afun)=map {$fn->getAttribute($_)} qw(lemma form pos case gen num deg neg agreement afun);
  if ($V_verbose) {
    print "TEST [tag=$node->{tag}, lemma=$node->{lemma}]  ==>  ";
    print join ", ", map { "$_->[0]=$_->[1]" } grep { $_->[1] ne "" } ([lemma => $lemma], [pos => $pos], [case => $case],
								 [gen => $gen], [num => $num], [deg => $deg], [afun => $afun]);
    print "\n";
  }

  if ($lemma ne '') {
    my $l = $node->{lemma};
    $l =~ s/[_\`&].*$//;
    if ($lemma=~/^\{(.*)\}$/) {
      my $list = $1;
      my @l = split /,/,$list;
      return 0 unless (first { (!$loose_lemma and $_ eq '...')
			       or $_ eq $l } @l)
    } else {
      return 0 unless $lemma eq $l;
    }
  }
  if ($agreement) {
    my ($p)=with_AR{PDT::GetFather_AR($node,sub{shift->{afun}=~/Aux[CP]/?1:0})};
    if ($p) {
      $p->{tag}=~/^....(\d)/;
      $case=$1 if ($case ne '' and $1);
      $p->{tag}=~/^...([SP])/;
      $num=$1 if ($num ne '' and $1);
      $p->{tag}=~/^..([FMIN])/;
      $gen=$1 if ($gen ne '' and $1);
    } else {
      print "AGREEMENT REQUESTED BUT NO PARENT: ",$V->serialize_form($fn),"\n" if $V_verbose;
      return 0;
    }
  }
  if ($form ne '') {
    if (lc($form) eq $form) { # form is lowercase => assume case insensitive
      return 0 if $form ne lc($node->{form});
    } else {
      return 0 if $form ne $node->{form};
    }
  }
  if ($gen ne '') {
    return 0 if $node->{tag}=~/^..([FMIN])/ and $gen ne $1;
  }
  if ($neg eq 'negative') {
    return 0 unless $node->{tag}=~/^..........N/;
  }
  if ($afun ne "" and $afun ne 'unspecified') {
    return 0 unless $node->{afun}=~/^\Q${afun}\E($|_)/;
  }
  if ($pos ne '') {
    if ($pos eq 'a' and ($case==1 and $node->{tag}=~/^Vs..[-1]/ or
			 $case==4 and $node->{tag}=~/^Vs..4/)) {
      # treat as ok
    } elsif ($pos =~ /^[adnijv]$/) {
      $pos = uc($pos);
      return 0 if $node->{tag}!~/^$pos/;
    } elsif ($pos eq 'f') {
      return 0 unless $node->{tag}=~/^Vf/;
    } elsif ($pos eq 'u') {
      return 0 unless $node->{tag}=~/^AU|^PS/;
    } else {
      # TODO: c s
      return 0 unless $node->{tag}=~/^V/;
    }
  } elsif ($case ne '') { # assume $tag =~ /^[CNP]/
    unless ($node->{tag}=~/^[CNPAX]/ or
	    $node->{lemma} =~ /^(?:&percnt;|hodnì|málo-3|dost|kolem-1|okolo-1|pøes-1|na-1)(?:\`|$|_)/) {
      print "NON_EMPTY CASE + INVALID POS: $node->{lemma}, $node->{tag}\n" if $V_verbose;
      return 0;
    }
  }
  if (!$no_case and $case ne '') {
    return 0 unless ($pos eq 'a' and ($case==1 and $node->{tag}=~/^Vs..[-1]/ or
				      $case==4 and $node->{tag}=~/^Vs..4/))
      or check_node_case($node,$case);
#     return 0 if ((($node->{tag}=~/^[NCPA]...(\d)/ and $case ne $1) or
# 		  ($node->{tag}!~/^[NCPAX]/ and $node->{lemma} !~ /^(?:&percnt;|hodnì|málo-3|dost)(?:\`|$|_)/))
# 		 and
# 		 not ($node->{tag}=~/^C...\D/ and not get_chilren_include_auxcp($node) and
# 		 not ($node->{tag}=~/^....2/ and
# 		      (print("CASE2: $node->{lemma}\n"),1) and
# 		      first {
# 			($_->{tag} =~ /^C/ or $_->{lemma} =~ /^(?:dost|málo-3|hodnì|spousta|sto-[12]|tisíc-[12]|milión|miliarda)(?:\`|$|_)/) and
#              		(print("CASE3: $node->{lemma}\n"),1) and
# 			($_->{tag}!~/^....(\d)/ or $case eq $1 or
# 			 ($1 eq '4' and first { $_->{lemma} eq 'pøes-1' } get_aidrefs_nodes($aids,$_) or
# 			  $1 eq '2' and first { $_->{lemma} eq 'kolem-1' } get_aidrefs_nodes($aids,$_)))
# 		      } with_AR { (PDT::GetFather_AR($node,sub{shift->{afun}=~/Aux[CP]/?1:0}),
# 				   PDT::GetChildren_AR($node,sub{1},sub{shift->{afun}=~/Aux[CP]/?1:0})) })
#    );
  }
  if ($num ne '') {
    return 0 if $node->{tag}=~/^...([SP])/ and $num ne $1;
  }
  if ($deg ne '') {
    return 0 if $node->{tag}=~/^........([123])/ and $deg ne $1;
  }
  foreach my $tagpos (1..15) {
    if (my $tag = $fn->getAttribute('tagpos'.$tagpos)) {
      return 0 if substr($node->{tag},$tagpos-1,1) !~ /[\Q$tag\E]/;
    }
  }
  foreach my $ffn ($fn->getChildrenByTagName('node')) {
    unless (first { match_node_coord($_,$ffn,$aids,$loose_lemma) }
	    get_chilren_include_auxcp($node)
	    # $node->children
	   ) {
      print "CHILDMISMATCH: ",$V->serialize_form($ffn),"\n" if $V_verbose;
      return 0;
    }
  }
  print "MATCH: [$node->{lemma} $node->{form} $node->{tag}] ==> ",$V->serialize_form($fn),"\n" if $V_verbose;
  return 1;
}

sub match_form {
  my ($node, $form, $aids, $loose_lemma) = @_;
  print "\nFORM: ".$V->serialize_form($form)." ==> $node->{lemma}, $node->{tag}\n" if $V_verbose;
  my @a = get_aidrefs_nodes($aids,$node);
  my $no_case=0;
  if ($node->{TID} ne "") {
    $no_case=1;
  }
  if (@a) {
    my @ok_a;
    my $node_aidrefs = getAIDREFsHash($node);
    foreach (@a) {
      if (first { $_->{afun}=~/^Aux[CP]/
		  and $_->{lemma} !~ /^místo-2_/ and $node_aidrefs->{$_->{AID}} } with_AR { PDT::GetFather_AR($_,sub{0}) }) {
	print "Ignoring AIDREF to $_->{form}\n" if $V_verbose;
      } else {
	print "Accepting AIDREF to $_->{form}\n" if $V_verbose;
	push @ok_a,$_;
      }
    }
    # add "kdo" of "kdo" subclauses
    @ok_a = map {
      if ($_->{tag}=~/^V/ and
	  not first { $_->{lemma} eq 'ten' and IsHidden($_) and
		      $_->{func} ne 'INTF' }
	  with_AR { PDT::GetFather_AR($_,sub{0}) }) {
	my $kdo = first { $_->{lemma} eq 'kdo' or $_->{lemma} eq 'co-1' }
	  PDT::GetChildren_TR($_);
	if ($kdo) {
	  print "KDO-RULE: found $kdo->{form}\n" if $V_verbose;
	}
	$kdo ? ($kdo,$_) : $_;
      } else { $_ }
    } @ok_a;
    my ($parent) = $form->getChildrenByTagName('parent');
    my ($pnode) = $parent->getChildrenByTagName('node') if $parent;
    if ($pnode) {
      foreach my $p (PDT::GetFather_TR($node)) {
	unless (match_node($p,$pnode,$aids,0,$loose_lemma)) {
	  print "PARENT-CONSTRAINT MISMATCH: [$p->{lemma} $p->{form} $p->{tag}] ==> ",$V->serialize_form($pnode),"\n" if $V_verbose;
	  return 0;
	}
      }
    }
    my @form_nodes = $form->getChildrenByTagName('node');
    if (@form_nodes) {
      foreach my $fn (@form_nodes) {
	unless (first { match_node($_,$fn,$aids,$no_case,$loose_lemma) } @ok_a) {
	  print "MISMATCH: $node->{lemma} $node->{form} $node->{tag} ==> ",$V->serialize_form($fn),"\n"
	    if $V_verbose;
	  return 0;
	}
      }
      return 1;
    } elsif ($form->getChildrenByTagName('typical')) {
      # TODO: somebody pls provide me the map of functors and their typical forms
      print "MATCH: typical form always matches (TODO)" if $V_verbose;
      return 1;
    } elsif ($form->getChildrenByTagName('elided')) {
      my $r = ($node->{AID} eq "" and $node->{AIDREFS} eq "") ? 1 : 0;
      print $r ? "MATCH: node elided" : "MISMATCH: node not elided\n" if ($V_verbose);
      return $r;
    } elsif ($form->getChildrenByTagName('recip')) {
      my $r = ($node->{trlemma} ne "&Rcp;") ?  1 : 0; # correct?
      print $r ? "MATCH: trlemma=&Rcp;" : "MISMATCH: trlemma=$node->{trlemma} instead of &Rcp;\n" if ($V_verbose);
      return $r;
    } elsif ($form->getChildrenByTagName('state')) {
      my $r = ($node->{state} eq "ST" or
	       $node->{func} =~ /\?\?\?/) ? 1 : 0;
      print $r ? "MATCH: state=ST" : "MISMATCH: state!=ST\n" if ($V_verbose);
      return $r;
    } else {
      print "MATCH, THOUGH FORM UNSPECIFIED: ==> ",$V->serialize_form($form),"\n" if $V_verbose;
      return 1;
    }
  } else {
    print "NOAIDREFS: $node->{lemma} $node->{form}\n" if $V_verbose;
    if ($node->{tag} ne '-') {
      print "WW no AIDREFs: $node->{trlemma}\t";
      Position($node);
    }
    # hm, really nothing to check here? If yes, we have to assume a match.
    # TODO: we still have to check something, e.g. lemma, pos; probably not case,
    # prepositions, number, gender
    return 1;
  }
  print "Why I'm here?\n";
  return 0;
}

sub get_func { join '|',grep {$_ ne '???'} split /\|/, $_[0]->{func} };

sub frame_matches_rule ($$$) {
  my ($V,$frame,$frame_test) = @_;
  foreach my $el (@$frame_test) {
    if (ref($el)) { # match a regexp
      my ($func, $regexp)=@$el;
      my $oblig = ($func=~s/^\?// ? 1 : 0);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->elements($frame);
      if (!defined($element)) {
	return 0 unless $oblig;
	next;
      }
      return 0 unless first { /$regexp/ } map { $V->serialize_form($_) } $V->forms($element);
    } elsif ($el =~ /^(\?)?([[:upper:]]*)\((.*)\)$/) {
      my ($oblig, $func, $forms)=($1,$2,$3);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->elements($frame);
      if (!defined($element)) {
	return 0 unless $oblig;
	next;
      }
      my @forms = $V->split_serialized_forms($forms);
      next unless @forms;
      my %forms = map { $V->serialize_form($_) => 1 } $V->forms($element);
      foreach my $form (@forms) {
	$form = TrEd::ValLex::Data::expandFormAbbrevs($form);
	return 0 unless $forms{$form};
      }
    } else {
      die "Can't parse frame rule element: $el\n";
    }
  }
  return 1;
}

sub transform_frame {
  my ($V,$old_frame,$frame_trans) = @_;
  my $new = $V->clone_frame($old_frame);
  foreach my $trans (@$frame_trans) {
    if (ref($trans)) { # match a regexp
      my ($func, $code)=@$trans;
      my $oblig = ($func=~s/^\?// ? 1 : 0);
      $func = '---' if $func eq "";
      if (!defined($func)) {
        # TODO: transform verb form
	next;
      }

      my ($element) = grep { $V->func($_) eq $func } $V->elements($new);
      next unless $element; # nothing to do
      foreach my $form ($V->forms($element)) {
	my $old_form = $V->serialize_form($form);
	my $new_form =
	  eval {
	    local $_ = $old_form;
	    &$code;
	    $_;
	  };
	$new_form = TrEd::ValLex::Data::expandFormAbbrevs($new_form);
	if ($old_form ne $new_form) {
	  $V->remove_node($form);
	  $V->new_element_form($element,$new_form);
	}
      }
    } elsif ($trans=~/^([\-\+])(\??)([[:upper:]]*)?(?:\((.*)\))?$/) {
      my ($add_or_remove,$type,$func,$forms)=($1,$2,$3,$4);
      $func = '---' if $func eq "";

      if (!defined($func)) {
        # TODO: transform verb form
	next;
      }

      my ($element) = grep { $V->func($_) eq $func } $V->elements($new);
      next unless $element or $add_or_remove eq "+"; # nothing to remove

      # remove the whole element if the deletion rule has no form-list
      if (!defined($forms) and $add_or_remove eq "-") {
	$V->remove_node($element) if ($element);
	next;
      }

      if (not($element) and $add_or_remove eq "+") {
	# create new element
	$element = $V->new_frame_element($new,$func,$type);
      }

      my @forms = $V->split_serialized_forms($forms);
      next unless @forms;
      my %forms = map { $V->serialize_form($_) => $_ } $V->forms($element);
      foreach my $form (@forms) {
	$form = TrEd::ValLex::Data::expandFormAbbrevs($form);
	if ($add_or_remove eq "+") {
	  # add form
	  $forms{$form} = $V->new_element_form($element, $form) unless ($forms{$form});
	} else {
	  # remove form
	  $V->remove_node($forms{$form}) if ($forms{$form});
	}
      }
    } else {
      die "Invalid frame form transform rule: $trans\n";
    }
  }
  return $new;
}

sub do_transform_frame {
  my ($V,$trans_rules,$node, $frame,$aids,$quiet) = @_;
  my ($i, $j)=(0,0);
  TRANS:
  foreach my $rule (@$trans_rules) {
    $i++; $j=0;
    my ($verbtest,@frame_tests) = @$rule;
    if ($verbtest->($node,$aids)) { # check if rule matches verb
      while (@frame_tests) {
	$j++;
	my $cache_key = "r:$i t:$j f:".$V->frame_id($frame);
	if ($cached_trans_frames{$cache_key}) {
	  print "TRANSFORMING FRAME ".$V->frame_id($frame)." (rule $i/$j): ".$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
	  $frame = $cached_trans_frames{$cache_key};
	  print "RESULT: ".$V->serialize_frame($frame)."\n\n" if (!$quiet and $V_verbose);
	  last TRANS;
	} else {
	  my ($frame_test,$frame_trans)=(shift @frame_tests, shift @frame_tests);
	  # print "testing rule $cache_key\n" if (!$quiet and $V_verbose);
	  if (frame_matches_rule($V,$frame,$frame_test)) {
	    print "TRANSFORMING FRAME ".$V->frame_id($frame)." (rule $i/$j): ".$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
	    $frame = transform_frame($V,$frame,$frame_trans);
	    print "RESULT: ".$V->serialize_frame($frame)."\n\n" if (!$quiet and $V_verbose);
	    $cached_trans_frames{$cache_key} = $frame;
	  }
	}
      }
    }
  }
  return $frame;
}

sub _filter_OPER_AP_and_jako_APPS {
  # filter out all members of jako.APPS right of the aposition node
  # and all OPER_AP nodes
  my ($n)=@_;
  while (PDT::is_member_TR($n)) {
    return 1 if
      ($n->parent and $n->parent->{func} eq "APPS" and
       $n->parent->{trlemma} eq "jako" and
       $n->{memberof} eq "AP" and
       (($n->{AID} ne "" and $n->parent->{AID} ne "" and
	 $n->parent->{ord} < $n->{ord}) or
	(($n->{AID} eq "" or $n->parent->{AID} eq "") and
	 $n->parent->{dord} < $n->{dord}))) or
	   (($n->{func} eq "OPER" and
	     $n->parent and $n->parent->{func} eq "APPS" and
	     $n->{memberof} eq "AP"));
    $n=$n->parent;
  }
  return 0;
}


sub validate_frame {
  my ($V,$trans_rules,$node, $frame,$aids,$pj4,$quiet) = @_;
  $frame = do_transform_frame($V,$trans_rules,$node, $frame,$aids,$quiet);

  my %oblig = map { $V->func($_) => $_ } $V->oblig($frame);
  my %nonoblig = map { $V->func($_) => $_ } $V->nonoblig($frame);
  my ($word_form) = $V->word_form($frame);

  if ($word_form) {
    my @forms = $V->forms($word_form);
    print "WORD FORM: ",$V->serialize_form($word_form)."\n" if (!$quiet and $V_verbose);
    if (@forms) {
      unless (grep { match_form($node,$_,$aids) } @forms) {
	unless ($quiet) {
	  print "11 no word form matches: $node->{lemma},$node->{tag}\t";
	  Position($node);
	}
	$node->{_light}='_LIGHT_';
	return 0;
      }
    }
  }

  my @c = PDT::GetChildren_TR($node);

  # we must include children of ktery/jaky/... in relative subclauses
  # co-referring to the current node
  if ($node->{tag}=~/^N/ and @$pj4) {
    my $id = $node->{AID}.$node->{TID};
    my @d = grep { grep { $_ eq $id } split /\|/,$_->{coref} } @$pj4;
    #    if (@d) {
    #      print "20 found ".scalar(@d)." refering ",join "/",(map { $_->{trlemma} } @d),"\t";
    #      Position($node);
    #    }
    @d = map { PDT::GetChildren_TR($_) } @d;
    if (@d) {
      print "22 found children of pz4:".scalar(@d)."\t";
      Position($node);
    }
    push @c,@d;
  }

  # ignore all coordinated members right of a "coz" on the level of "coz"'s parent
  my %ignore;
  foreach $m (@c) {
    if (($m->{tag}=~/^V/ or $m->{trlemma} eq '&Emp;') 
	and PDT::is_coord_TR($m->parent) and
	first { $_->{trlemma} eq "co¾" } PDT::GetChildren_TR($m)) {
      $ignore{$m}=1;
      print "WW should ignore node: '$m->{trlemma}'\n" if (!$quiet and $V_verbose);
      if ($m->{AID} ne "") {
	for (grep { $_->{func} eq $m->{func} }
	     map { PDT::expand_coord_apos_TR($_) }
	     grep { PDT::is_valid_member_TR($_) and $_->{AID} ne "" and $_->{sentord} > $m->{sentord}  }
	     $m->parent->children) {
	  print "WW should also ignore node: '$_->{trlemma}'\n" if (!$quiet and $V_verbose);
	  $ignore{$_}=1;
	}
      }
    } elsif (_filter_OPER_AP_and_jako_APPS($m)) {
      $ignore{$m}=1;
      print "WW should ignore node: '$m->{trlemma}'\n" if (!$quiet and $V_verbose);
    } elsif ($m->{lemma}=~/^(podobnì|daleko-1|dal¹í)(_|$)/
	     and  $m->{AID} ne "" and
             with_AR {
	       $m->parent and
	       $m->parent->{lemma} eq 'a-1'
	       and PDT::is_coord($m->parent) and $m->{afun}=~/_Co$/
	       and not first { $_->{ord} > $m->{ord} } PDT::expand_coord_apos($m->parent)
	     }) {
      $ignore{$m}=1;
      print "WW should ignore node: '$m->{trlemma}'\n" if (!$quiet and $V_verbose);
    }
  }

  @c = grep {
	if ($ignore{$_}) {
	  print "WW ignoring node: '$_->{trlemma}'\n" if (!$quiet and $V_verbose);
	}
	!$ignore{$_};
       } @c;


  my %c;
  foreach (@c) {
    push @{$c{get_func($_)}}, $_;
  }

  foreach my $o (keys %oblig) {
    unless (exists($c{$o})) {
      unless ($quiet) {
	print "06 missing obligatory element: '$o'\t";
	Position($node);
	print "FRAME: ",$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
      }
      return 0;
    }
  }
  foreach my $ac (@actants) {
    if (exists($c{$ac}) and not($oblig{$ac} or $nonoblig{$ac})) {
      unless ($quiet) {
	print "07 actant present in data but not in vallex: $ac\t";
	Position($node);
      }
      return 0;
    } elsif (exists $c{$ac}) {
      if (@{$c{$ac}} > 1) {
	my @ancestors = uniq map { _highest_coord($_) } @{$c{$ac}};
	if (@ancestors > 1) {
	  unless ($quiet) {
	    print "08 multiple actants: $ac\t";
	    Position($node);
	  }
	  return 0;
	}
      }
    }
  }

  foreach my $c (@c) {
    my $e = $oblig{get_func($c)} || $nonoblig{get_func($c)};
    next unless ($e);
    my @forms = $V->forms($e);
    if (!$quiet and $V_verbose) {
      print "--------------------------\n";
      print "NODE: $c->{func},$c->{lemma},$c->{tag}\n";
      print "ELEMENT: ",$V->serialize_element($e)."\n";
    }
    if (@forms) {
      unless (first { match_form($c,$_,$aids) } @forms) {
	if ($V_verbose) {
	  print "\n09 no form matches: $c->{func},$c->{lemma},$c->{tag}\n";
	} elsif (!$quiet) {
	  print "09 no form matches: $c->{func},$c->{lemma},$c->{tag}\t";
	  Position($node);
	}
	$c->{_light}='_LIGHT_';
	return 0;
      }
    }
  }

  print "\nOK - frame matches!\n" if ($V_verbose and !$quiet);
  return 1;
}

sub resolve_substitution_for_assigned_frames {
  my ($V,$node)=@_;
  my $lemma = $node->{trlemma};
  $lemma =~ s/_/ /g;
  my @frameids;
  foreach my $fi (split /\|/, $node->{frameid}) {
    print "resolving $fi\n";
    my $frame = $V->by_id($fi);
    if (ref($frame)) {
      my @valid = $V->valid_frames_for($frame);
      if (@valid) {
	foreach my $vframe (@valid) {
	  if ($V->word_lemma($V->frame_word($vframe)) eq $lemma) {
	    push @frameids, $V->frame_id($vframe);
	    print "OK: $fi resolves to ".$V->frame_id($vframe)."\n";
	  } else {
	    print "FAIL: $fi resolves to ".$V->frame_id($vframe)." with different lemma\n";
	  }
	}
      } else {
	print "$fi doesn't resolve\n";
      }
    } else {
      print "FAIL: $fi not found\n";
    }
  }
  return join '|',@frameids;
}

sub hash_pj4 {
  my ($tree)=shift;
  return [ grep { $_->{tag}=~/^PJ/ or ($_->{tag}=~/^P4/ and $_->{lemma}=~/^který$|^jaký$|^co-4/)
		} $tree->descendants ];
}

sub check_verb_frames {
  my ($node,$aids,$frameid,$fix)=@_;
  my $func = get_func($node);
  return -1 if $node->{tag}!~/^V/ or $func =~ /[DF]PHR/
    or ($func eq 'APPS'and $node->{trlemma} eq 'tzn');
  #    return if $node->{tag}!~/^Vs/; # TODO: REMOVE ME!
  my $lemma = $node->{trlemma};
  $lemma =~ s/_/ /g;
  $cache{$lemma} = $V->word($lemma,'V') unless exists($cache{$lemma});
  if ($cache{$lemma}) {
    if ($node->{$frameid} ne '') {
      my @frames;
      foreach my $fi (split /\|/, $node->{$frameid}) {
	my $frame = $V->by_id($fi);
	if (ref($frame)) {
	  my @valid = $V->valid_frames_for($frame);
	  if (@valid) {
	    foreach my $vframe (@valid) {
	      print "Valid frame: ",$V->frame_id($vframe),": ",
		$V->serialize_frame($vframe),"\n" if $vframe and $V_verbose;
	      if ($vframe) {
		if ($V->word_lemma($V->frame_word($vframe)) eq $lemma) {
		  push @frames, $vframe;
		} else {
		  print "00 invalid lemma for: ",$V->frame_id($vframe),"\t";
		  Position($node);
		}
	      }
	    }
	  } else {
	    # frame not resolved
	    if ($cache{$lemma}) {
	      my @possible_frames =
		grep { validate_frame($V,\@fv_trans_rules_V,$node,$_,$aids,undef,1) } $V->valid_frames($cache{$lemma});
	      $node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	      $node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;

	      if (@possible_frames==1) {
		print "12 unresloved frame, but one matching frame: $fi\t";
	      } elsif (@possible_frames>1) {
		print "13 unresloved frame, but more matching frames: $fi\t";
	      } else {
		print "14 unresloved frame, but no matching frame: $fi\t";
	      }
	    } else {
	      print "15 unresloved frame and lemma not found: $fi\t";
	    }
	    Position($node);
	    return 0;
	  }
	} else {
	  print "02 frame not found: $fi\t";
	  Position($node);
	  return 0;
	}
      }
      if (@frames) {
	if ($fix) {
	  $node->{$frameid}=join "|",map { $V->frame_id($_) } @frames;
	  $node->{$framere} = join " | ", map { $V->serialize_frame($_) } @frames;
	  ChangingFile(1);
	}
	foreach my $frame (@frames) {
	  return 0 unless validate_frame($V,\@fv_trans_rules_V,$node,$frame,$aids,undef,0);
	}
	# process frames
      } else {
	print "03 no valid frame for: $node->{$frameid} \t";
	Position($node);
	return 0;
      }
    } else {
      print "04 no frame assigned: $lemma\t";
      Position($node);
      return 0;
    }
  } else {
    print "05 lemma not in vallex: $lemma\t";
    Position($node);
    return 0;
  }
  return 1;
}
