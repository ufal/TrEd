# -*- mode: cperl; coding: iso-8859-2; -*-
#encoding iso-8859-2

#########################
# Frame validation code #
#########################

=comment

Known issues:

- There is a KDO-RULE for (usually object or subject) subclauses
starting with "kdo" or "co".  It tries to verify the form of "kdo" or
"co" instead of the original node (which would be the root of the
subclause). This behaviour is probably incorrect: instead we should allow
nodes satisfying KDO-RULE at all places where direct 1. or .4 are present.

- KDO-RULE is only applied if the subclause is NOT analytically
governed by "ten".

- KDO-RULE does not apply to subclauses with "jaky", "jak" etc.
Whether there will be a need for such rules is yet to be determined by
further research.

- Passivisation rules for se/AuxR are strict, meaning they will not
apply if the afun of "se" is AuxT or Obj. Fixing the analytical
layer is often required.

TODO:

- A rule that would handle "po jablicku" is missing.


PROBLEMS OF OPER:

- ".1 az po.OPER .4" - in this (and probably other similar) the latter
member of the OPER has a different case than expected.

- "zvysili na 1 :.OPER 2" - "na" is in AIDREFS of the OPER



- distinguish between:
"Marie ma pro Petra uvareno" (where no transformation rules applies) and
"Petr ma od Marie uvareno" (where transformation changes ADDR(.3) to
ADDR(.1), etc)

- preposition+&Idph; - we should igore case tests in these cases

=cut

{
use strict;
use vars qw(@actants $match_actants %lemma_normalization @fv_trans_rules_N @fv_trans_rules_V @fv_passivization_rules);

@actants = qw(ACT PAT EFF ORIG ADDR);
$match_actants = '(?:'.join('|',@actants).')';

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
      $node = first { $_->{TR} eq 'hide' or $_->{trlemma} =~ /^(začít|začínat|končit|přestat|stihnout)$/
		    } PDT::GetFather_AR($node,sub{0});
    }
    if (!$result and $node and $node->{tag}=~/^V/) {
      $result = (first { $_->{afun} eq 'AuxR' and $_->{lemma}=~/^se_/ }
		 PDT::GetChildren_AR($node,sub{1},sub{($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0})) ? 1 : 0;
    }
  };
  return $result;
}

@fv_passivization_rules = (
    # /1
    [[ 'ACT(.1)', 'PAT(.4)', ['EFF', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])$/ ]] =>
     [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-PAT(.4)', '+PAT(.1)',
       ['EFF', sub { s/^(\.a?)4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])$/${1}1${2}/ } ]]],
    # /2 frame test
    [[ 'ACT(.1)', ['PAT', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?$/ ]]  =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])',
      ['PAT',sub { s/((?:^|,)\.a?)4((?:\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?(?:,|$))/${1}1${2}/ } ]]],
    # /3 ditto for CPHR
    [[ 'ACT(.1)', ['CPHR', qr/^[^\[]*[.:][^\[,:.]*4/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', ['CPHR',sub { s/^([^\[]*[.:][^\[,:.]*)4/${1}1/ }]]],
    # /4 ditto for DPHR
    [[ 'ACT(.1)', ['DPHR', qr/^[^\[]*[.:][^\[,:.]*4/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', ['DPHR',sub { s/^([^\[]*[.:][^\[,:.]*)4/${1}1/ }]]],
    # /5 frame test
    [[ 'ACT(.1)', 'ADDR(.4)' ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-ADDR(.4)', '+ADDR(.1)' ]],
    # /6 frame test
    [[ 'ACT(.1)', 'ADDR(.2)' ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-ADDR(.2)', '+ADDR(.1)' ]],
    # /7 frame test
    [[ 'ACT(.1)', ['EFF', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?$/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])',
      ['EFF',
       sub { s/^(\.a?)4(\[(jako|{jako,jakožto})(\/AuxY)?\])?[.:]?$/${1}1${2}/ }
      ]]]);

@fv_trans_rules_V =
  (
   # 1.
   [# verb test: "nekdo1.ADDR ma auto pronajmuto nekym2/od+nekoho2.ACT",
    # transforms to: "nekdo2.ACT pronajmul auto nekomu1.ADDR"
    sub { my ($node,$aids) = @_;
	  ($node->{tag}=~/^Vs/ and
	   first { $_->{func} eq 'ACT' and $_->{tag}!~/^....1/ } PDT::GetChildren_TR($node) and
	   (first { $_->{AID} ne "" and $_->{lemma} =~ /^mít$|^mívat_/ } get_aidrefs_nodes($aids,$node)
	   )
#	    and
#	    not first { $_->{AID} ne "" and $_->{lemma} !~ /^mít$|^mívat_/ and $_->{tag}=~/^Vf/ }
#	      get_aidrefs_nodes($aids,$node))
	  ) ? 1:0; # STOP
	} =>
    [[ '(.$2<s>)', 'ACT(.1)' ] => 
       ['-ACT(.1)', '+ACT(.4)' ]],
    # frame transformation rules:
    # frame test
    [[ 'ACT(.1)', 'ADDR(.3)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])', '-ADDR(.3)','-ADDR(pro-1[.4])', '+ADDR(.1)' ],
     { KEEP_ORIG => 1 } # try the original frame too
    ],
    [[ 'ACT(.1)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])' ],
     { KEEP_ORIG => 1 } # try the original frame too
    ]
   ],
   # 2.
   [# case: "mrizka/mrizku=PAT(.4,.1) nejde udelat", "mrizka/mrizku je videt"
    # adds PAT(.1)
    sub { my ($node) = @_;
	  ($node->{tag}=~/^Vf/ and first { $_->{lemma} eq 'být' or $_->{lemma} eq 'jít' } PDT::GetFather_TR($node)) ? 1:0;
	} =>
    [[ 'PAT(.4)' ] => [ '+PAT(.1)' ]],
   ],
   # 3.
   [# verb test: passive verb
    # applies to "problem je vyresen nekym", but not to "nekdo ma problem vyresen",
    # but should still apply to "problem ma byt vyresen"
    sub { my ($node,$aids) = @_;
	  ($node->{tag}=~/^Vs/ and
	   not (
	     # eliminate "ma", "bude mit" or even "mel by mit" or "chtel by mit"
		#first { $_->{AID} ne "" and $_->{lemma} =~ /^být$|^bývat_/ and $_->{tag} !~ /Vc/ } get_aidrefs_nodes($aids,$node) 
		#and 
#		and not first { $_->{AID} ne "" and $_->{lemma} !~ /^mít$|^mívat_/ and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node)
#		and not first { $_->{AID} ne "" and $_->{lemma} =~ /^být$|^bývat_/ and $_->{tag} !~ /V[fc]/ } get_aidrefs_nodes($aids,$node)

	     # Here is what we eliminate:
	     # -------------------------
	     # there is some "mit"
	     first { $_->{AID} ne "" and $_->{lemma} =~ /^mít$|^mívat_/ } get_aidrefs_nodes($aids,$node)
	     and
	     # there is some active hidden verb
	     first { $_->{AID} ne "" and $_->{tag} =~ /V[^fc]/ } get_aidrefs_nodes($aids,$node)
	     # there is no infinitive "byt"
	     and !first { $_->{AID} ne "" and $_->{lemma} =~ /^být$|^bývat_/ and $_->{tag} =~ /Vf/ } get_aidrefs_nodes($aids,$node)
	    )
	  ) ? 1:0;
	} =>
    # frame transformation rules:
    [[ '(.$2<s>)' ] => []],
    [[ '(.v[se/AuxR])' ] => []],
    @fv_passivization_rules,
    # frame test
    [[ 'ACT(.1)' ] =>
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])']],
   ],
   # 4.
   [# dispmod
    sub { $_[0]->{dispmod} eq "DISP" } =>
    # frame transformation rules:
    # frame test
    [[ 'ACT(.1)', 'PAT(.4)' ] =>
     [ '-ACT(.1)', '+ACT(.3)', '-PAT(.4)', '+PAT(.1)', '+(.[se])', '+MANN(*)' ]],
    # frame test
    [[ 'ACT(.1)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.3)', '+(.[se])', '+MANN(*)' ]]
   ],
   # 5.
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
    [[ 'ACT(.1)' ] =>
     [ '-ACT(.1)', '+ACT(.3)' ]]
   ],
   # 6.
   [# verb test: verb treated as passive due to "se".AuxR
    sub {
      my ($node,$aids) = @_;
      return (first { $_->{AID} ne "" and $_->{tag}=~/^V/ and has_auxR($_) } 
		(get_aidrefs_nodes($aids,$node),
		 grep { $_->{lemma} eq "dát" and $_->{tag}=~/V.........N/ } PDT::GetFather_TR($node))
		   ) ? 1: 0;
    }
    # used to be ACT(!), but some abstract constructions with se.AuxR feel like ACT(.7)
    =>
    @fv_passivization_rules
   ],
   # 7.
   [ # nechat si/dat si udelat neco udelat od nekoho/nekym
    sub {
      my ($node,$aids) = @_;
      return 0 unless $node->{tag}=~/^Vf/;
      if ($node->{TID} ne "") {
	($node) = first { $_->{AID} ne "" and $_->{tag}=~/^Vf/ } get_aidrefs_nodes($aids,$node);
	return 0 unless $node;
      }
      # get analytic parent, but only in case that no AuxC/AuxP are in the way
      my ($p) = with_AR {
	(climb_auxcp($node)->{afun} =~ /Aux[CP]/) ? undef :
	  PDT::GetFather_AR($node,sub{ ($_[0] and $_[0]->{afun}=~/Aux[CP]/)?1:0 })
	  };
      return 0 unless $p and $p->{trlemma}=~/^nech(áv)?at$|^dát$/
    } =>
      [[ 'ACT(.1)', 'PAT(.7)' ] =>
       [ '-ACT(.1)', '+ACT(od-1[.2];.7)', '+PAT(.4)' ]],
      [[ 'ACT(.1)' ] =>
       [ '-ACT(.1)', '+ACT(od-1[.2];.7)' ]]
   ],
   # 8. imperative
   [
    sub { $_[0]->{tag}=~/^Vi/ ? 1 : 0 } =>
    [[ 'ACT(.1)' ] => [ '+ACT(.5)' ]]
   ],
   # 9. agreement between EFF and PAT in "mit tisic aut koupenych"
   [
    sub {
      my ($node,$aids)=@_;
      $node->{trlemma} eq "mít"
      and
      first { $_->{func} eq "PAT" and
	      ( # "nema pranic spolecneho"
		$_->{lemma}=~/^(nic|pranic|málo-2|pramálo|něco|co-1)$/ or
		# "s Petrem ma 5/mnoho vlastnosti spolecnych"
		$_->{tag}=~/^....2/ or is_numeric_expression($_) or
		# "s Petrem ma spolecneho, ze ..."
		$_->{tag}=~/^V/ and first { $_->{lemma} eq "že" } get_aidrefs_nodes($aids,$_))
	      } PDT::GetChildren_TR($node)
	} =>
    [[ 'PAT(.4)','EFF(.4)' ] => [ '+EFF(.a2)' ]]
   ]
  );


# substantive frame transformation rules
@fv_trans_rules_N =
  (
   [
    sub { 1 } =>
    [[ 'ACT(.2;.u)', 'ADDR(s-1[.7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
    [[ 'ACT(:2;:u)', 'ADDR(s-1[:7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
   ],
   [
    sub { 1 } =>
    [[ 'ACT(.2;.u)', 'PAT(s-1[.7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
    [[ 'ACT(:2;:u)', 'PAT(s-1[:7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
   ],
   [
    sub { 1 } =>
    [[ 'ACT(.2;.u)', 'EFF(s-1[.7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
    [[ 'ACT(:2;:u)', 'EFF(s-1[:7])' ] => [ '+ACT(mezi-1[.P7];mezi-1[.7],mezi-1[.7])' ]],
   ],
   [
    sub { 1 } =>
    [[ 'ACT(.2;.u)' ] => [ '+ACT(z-1[strana:2[.2]])' ]],
    [[ 'ACT(:2;:u)' ] => [ '+ACT(z-1[strana:2[.2]])' ]],
   ]
  );


%lemma_normalization =
  qw(
     li jestli
    );

sub match_lemma {
  my ($l1,$l2)=@_;
  return ($l1 eq $l2 or
	  exists ($lemma_normalization{$l1}) and $lemma_normalization{$l1} eq $l2) ? 1 : 0;
}

sub match_node_coord {
  my ($node, $tnode, $fn,$aids,$no_case,$flags) = @_;
  $flags = {} unless defined($flags);
  my $res = match_node($node, $tnode, $fn,$aids,$no_case,$flags);
  if (!$res and $node->{afun} =~ /^Coord|^Apos/) {
    foreach (grep { $node->{lemma} !~ /^a-1$|^nebo$/ or $_->{lemma}!~/^(podobně|daleko-1|další)(_|$)/ or
		      ((first { $_->{lemma} =~ /^tak-3(_|$)/ } get_aidrefs_nodes($aids,$_)) and
		       (first { $_->{lemma} =~ /^(?:dále-3|daleko-1)(_|$)/ } get_aidrefs_nodes($aids,$_)))
		  }
	     with_AR{PDT::expand_coord_apos($node)}) {
      return 0 unless match_node($_,$tnode,$fn,$aids,$no_case,$flags);
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
  return ($node->{tag} =~ /^C/ or $node->{lemma} =~ /^(?:dost|málo-3|kolik|tolik-1|trochu|plno|hodně|nesčetně|spousta|půl-[12]|sto-[12]|tisíc-[12]|milión|půldruhý|miliarda|stovka|desítka|pár-[12]|příliš)(?:\`|$|_)/) ? 1:0;
}

sub climb_auxcp {
  my ($node) = @_;
  my $last = $node;
  my $go_coord = ($node->{afun}=~/_Co/) ? 1 : 0;
  my $go_apos = ($node->{afun}=~/_Ap/) ? 1 : 0;
  while ($node->parent) {
    if ($go_coord and $node->parent->{afun}=~/^Coord/) {
      $node=$node->parent;
      $go_coord = ($node->{afun}=~/_Co/) ? 1 : 0;
      $go_apos = ($node->{afun}=~/_Ap/) ? 1 : 0;
    } elsif ($go_apos and $node->parent->{afun}=~/^Apos/) {
      $node=$node->parent;
      $go_apos = ($node->{afun}=~/_Ap/) ? 1 : 0;
      $go_coord = ($node->{afun}=~/_Co/) ? 1 : 0;
    } elsif ($node->parent->{afun}=~/^Aux[CP]/) {
      $last=$node=$node->parent;
    } else {
      last;
    }
  }
  $node = $last if ($node->{afun}=~/^Coord|^Apos/);
  return $node;
}

sub get_children_include_auxcp {
  my ($node)=@_;
  if ($node->{afun} =~ /^Aux[CP]/) {
    return with_AR { map { PDT::expand_coord_apos($_) } $node->children };
  } else {
    return with_AR { map { climb_auxcp($_) } PDT::GetChildren_AR($node,
								 sub{1},
								 sub{ $_[0]{afun}=~/Aux[CP]/ }) };
  }
}

sub same_clause_below {
  my ($node)=@_;
  return 0 if $node->{trlemma} eq "&Emp;";
  return 1 if $node->{tag}!~/^V/;
  my @c= PDT::GetFather_TR($node);
  if ($node->{tag}=~/^Vf/ and
      first { $_->{lemma} =~ /^(umět|dokázat|lze|schopný)(|$)/ } @c
      or
      $node->{tag}=~/^Vs/ and
      first { $_->{lemma} =~ /^být|bývat|mít$/ } @c) {
    return 1;
  } else {
    return 0;
  }
}

sub is_direct_subclause {
  my ($node)=@_;
  # |což-1
  my $obj_pronoun=qr/^(?:co-1|co-3|jak-3|jaký|kdo|kudy|kolik|proč|kde|kdeže|jak-2|co-4|kdy|kam|který|nakolik|odkud|čí)(_|$)/;
  # TODO: try finite verb
  if ($node->{__no_fake}) {
    $node=$node->{__no_fake};
  }
  if ($node->{tag}=~/^V/ or $node->{trlemma} eq "&Emp;") {
    print "subclause trying:",join(", ",map{$_->{trlemma}} $node),"\n" if $V_verbose;
    my @c= PDT::GetChildren_TR($node);
    print "1st level:",join(", ",map{$_->{trlemma}} @c),"\n" if $V_verbose;
    @c = grep { same_clause_below($_) } @c;
    while (@c) {
      print "subclause trying:",join(", ",map{$_->{trlemma}} @c),"\n" if $V_verbose;
      return 1 if (first { $_->{lemma} =~ $obj_pronoun } @c);
      @c = uniq map {
	grep { same_clause_below($_) } PDT::GetChildren_TR($_)
      } @c;
    }
  }
  return 0;
}

sub check_node_case {
  my ($node,$case)=@_;

  # simple case
  print "   CASE: Checking simple case\n" if $V_verbose;
  return 1 if $node->{tag}=~/^[FNCPA]...(\d)/ and $case eq $1;
  print "   CASE: Checking case N..XX\n" if $V_verbose;
  return 1 if $node->{tag}=~/^N..XX/;
  print "   CASE: Checking AC..- tag ('vinen', etc.)\n" if $V_verbose;
  return 1 if $node->{tag}=~/^AC..-/ and $case=~/[14]/;#
  print "   CASE: Checking case X\n" if $V_verbose;
  return 1 if $node->{tag}=~/^[FNCPA]...X/ or $node->{tag}=~/^X...-/;
  print "   CASE: Checking lemmas w/o case\n"  if $V_verbose;
  # special lemmas without case:
  return 1 if $node->{lemma} =~ /^(?:&percnt;|trochu|plno|hodně|málo-3|dost)(?:\`|$|_)/;
  print "   CASE: Checking simple number w/o case\n"  if $V_verbose;
  # simple number without case: e.g. 3
  return 1 if ($node->{tag}=~/^C=..\D/);
  print "   CASE: Checking 'kolem|okolo'+Num\n"  if $V_verbose;
  # kolem milionu (lidí)
  return 1 if $node->{lemma} =~ /^(?:do1|kolem-1|okolo-1)$/ and $node->{afun}=~/^AuxP/ and
    first { $_->{tag}=~/^C=/ or $_->{tag}=~/^....2/ and is_numeric_expression($_) } get_children_include_auxcp($node);
  print "   CASE: Checking 'pres|na'+Num\n"  if $V_verbose;
  # přes milion (lidí)
  return 1 if $node->{lemma} =~ /^(přes-1|na-1|pod-1)$/ and $node->{afun}=~/^AuxP/ and
    first { $_->{tag}=~/^C=/ or $_->{tag}=~/^....4/ and is_numeric_expression($_) } get_children_include_auxcp($node);
  print "   CASE: Checking num+2 construct\n"  if $V_verbose;
  # a number has the right case (or no case at all) and is analytically governing the node
  return 1 if ($node->{tag}=~/^....2/ and
	       first {
		 print("     CASE: testing parent instead: $_->{form}\n") if $V_verbose;
		 is_numeric_expression($_) and
		 ($V_verbose && print("     CASE: parent is numeric: $_->{form}\n"),1) and
		   (($_->{tag}!~/^....(\d)/) or ($case == $1) or
		    ($_->{tag}=~/^....4/ and
		     grep { $_->{lemma} =~ /^(přes-1|na-1|pod-1)$/ and $_->{afun}=~/^AuxP/ }
		     with_AR { PDT::GetFather_AR($_,sub{0}) }
		    ) or
		    ($_->{tag}=~/^....2/ and
		     first {
		       $_->{lemma} =~ /^(do-1|kolem-1|okolo-1)$/ and $_->{afun}=~/^AuxP/ }
		     with_AR { PDT::GetFather_AR($_,sub{0}) }
		    ))
	       } with_AR { PDT::GetFather_AR($node,sub{0}) });
  print "   CASE: Checking 2+num construct\n"  if $V_verbose;
  return 1 if ($node->{tag}=~/^....2/ and
	       first {
		 is_numeric_expression($_) and (($_->{tag}!~/^....(\d)/) or ($case eq $1))
	       } get_children_include_auxcp($node));
  print "   CASE: Checking 2+za XY Kc construct\n"  if $V_verbose;
  return 1 if ($node->{tag}=~/^....2/ and
	       first {
		 $_->{lemma} eq 'za-1' and
		   first { is_numeric_expression($_) } get_children_include_auxcp($_)
		 } get_children_include_auxcp($node));
  print "   CASE: Checking mezi-1 X /COORD Y Kc construct\n"  if $V_verbose;
  return 1 if ($node->{lemma} eq 'mezi-1' and
		 scalar(get_children_include_auxcp($node)) > 1 and
		 !first { !is_numeric_expression($_) } get_children_include_auxcp($node));
  print "   CASE: Checking 'po jablicku' construct\n"  if $V_verbose;
  return 1 if ($node->{lemma} eq 'po-1' and
		 !first { $_->{tag}!~/^....6/ } get_children_include_auxcp($node));
  print "   CASE: Checking 'po jablicku' construct - hack 2\n"  if $V_verbose;
  return 1 if ($node->{tag} =~ /^....6/ and
	       with_AR { $node->parent and $node->parent->{lemma} eq 'po-1' } );
  print "   CASE: Checking actant of a copied 'CPR' with hodne\n"  if $V_verbose;
  return 1 if ($node->{tag} =~ /^....2/ and
	       with_AR { $node->parent and
			 $node->parent->{lemma} eq 'než-2' and
			 $node->parent->parent->{lemma} eq 'hodně' and
			   (1<grep { $_->{afun}!~/^AuxY/ } $node->parent->children) 
		       } );



  print "   CASE: All checks failed\n"  if $V_verbose;
  return 0;
}

# check if genders in given tags/nodes match
sub match_gender {
  my ($g1,$g2)= @_;
  my $g=$g1.$g2;
  return (($g1 eq $g2) or
          ($g=~/-|X|^(?:H[NF]|[NF]H|Y[IMZ]|[ZIM]Y|Z[IMN]|[IMN]Z)$/)
         ) ? 1 : 0;
}


sub match_node {
  my ($node, $tnode, $fn, $aids,$no_case,$flags,$toplevel) = @_;

  print "match_node_FLAGS: ",join(" ",%$flags),"\n" if $V_verbose;

  my ($lemma,$form,$pos,$case,$gen,$num,$deg,$neg,$agreement,$afun)=map {$fn->getAttribute($_)} qw(lemma form pos case gen num deg neg agreement afun);

  my $l = $node->{lemma};
  my $f = $node->{form};

  if ($lemma ne '' or $form ne '') {
    if ($node->{tag}=~/^P[5P]/ or $node->{tag}=~/^PJ/ or
	($node->{tag}=~/^P4/ and $node->{lemma}=~/^který$|^jaký$|^co-4/)) {
      my @corefs = split /\|/,$node->{coref};
      my @cortypes = split /\|/,$node->{cortype};
      my $find_cortype = $node->{tag}=~/^P[5P]/ ? 'textual' : 'grammatical';
      if ($V_verbose) {
	print "--------------------------\n";
	print "EXPANDING DPHR/CPHR TO CO-REFERRED NODE (cortype $find_cortype)\n";
      }
      while (@corefs) {
	my $coref = shift @corefs;
	my $cortype = shift @cortypes;
	if ($cortype eq $find_cortype) {
	  # find referent
	  print "FOUND GRAMMATICAL COREF $coref\n" if ($V_verbose);
	  my $referent = $aids->{$coref} || first { $_->{AID}.$_->{TID} eq $coref } $node->root->descendants;
	  if ($referent) {
	    print "FOUND CO-REFERRED NODE\n" if ($V_verbose);
	    $l = $referent->{lemma};
	    $f = $referent->{form};
	  } else {
	    print "CANNOT FIND CO-REFERRED NODE\n" if ($V_verbose);
	  }
	  last;
	}
      }
    }
  }

  if ($V_verbose) {
    print "TEST [no_case=$no_case, tag=$node->{tag}, lemma=".$l."]  ==>  ";
    print join ", ", map { "$_->[0]=$_->[1]" } grep { $_->[1] ne "" } ([lemma => $lemma], [pos => $pos], [case => $case],
								 [gen => $gen], [num => $num], [deg => $deg], [afun => $afun]);
    print "\n";
  }

  if ($lemma ne '') {
    $l =~ s/[_\`&].*$//;
    if ($lemma=~/^\{(.*)\}$/) {
      my $list = $1;
      my @l = split /,/,$list;
      return 0 unless (first { ($flags->{loose_lemma} and $_ eq '...')
			       or $_ eq $l or match_lemma($l,$_) } @l)
    } else {
      return 0 unless $lemma eq $l or match_lemma($l,$lemma);
    }
  }
  if ($agreement) {
    my ($p)=with_AR{PDT::GetFather_AR($node,sub{shift->{afun}=~/Aux[CP]/?1:0})};
    if ($p) {
      $p->{tag}=~/^....(\d)/;
      $case=$1 if ($case eq '' and $1);
      $p->{tag}=~/^...([SP])/;
      $num=$1 if ($num eq '' and $1);
      $p->{tag}=~/^..([FMINHZY])/;
      $gen=$1 if ($gen eq '' and $1);
      if ($V_verbose) {
	print "AGREEMENT [no_case=$no_case, tag=$node->{tag}, lemma=".$l."]  ==>  ";
	print join ", ", map { "$_->[0]=$_->[1]" } grep { $_->[1] ne "" } ([lemma => $lemma], [pos => $pos], [case => $case],
									   [gen => $gen], [num => $num], [deg => $deg], [afun => $afun]);
	print "\n";
      }
    } else {
      print "AGREEMENT REQUESTED BUT NO PARENT: ",$V->serialize_form($fn),"\n" if $V_verbose;
      return 0;
    }
  }
  if ($form ne '') {
    if (lc($form) eq $form) { # form is lowercase => assume case insensitive
      return 0 if $form ne lc($f);
    } else {
      return 0 if $form ne $f;
    }
  }
  if ($gen ne '') {
    return 0 if $node->{tag}=~/^..([FMINHZY])/ and !match_gender($gen,$1);
  }
  if ($neg eq 'negative') {
    return 0 unless $node->{tag}=~/^..........N/;
  }
  if ($afun ne "" and $afun ne 'unspecified') {
    return 0 unless $node->{afun}=~/^\Q${afun}\E($|_)/;
  }

  # KDO-RULE:
  my $kdo;
#  print "KDO-RULE: step 1: case $case rest '$lemma$form$pos$gen$num$deg' a '$agreement' N '$neg' top $toplevel tag $node->{tag}\n" if $V_verbose;
  if ($toplevel # no nodes above
      and $case =~ /^[14]$/
      and !$agreement
      and (!$neg or $neg eq 'unspecified')
      and "$lemma$form$pos$gen$num$deg" eq ""
      and $node->{tag}=~/^V/
      and not first { $_->{lemma} eq 'ten' and IsHidden($_) and $_->{func} ne 'INTF' }
	with_AR { PDT::GetFather_AR($node,sub{0}) }) {
#    print "KDO-RULE: step 2\n" if $V_verbose;
    $kdo = first { $_->{lemma} eq 'kdo' or $_->{lemma} eq 'co-1' } PDT::GetChildren_TR($node);
  }
  print "KDO-RULE: $kdo->{form} on $node->{form}\n" if $kdo and $V_verbose;

  if ($pos ne '') {
    if ($pos eq 'a' and ($case==1 and $node->{tag}=~/^Vs..[-1]/ or
			 $case==4 and $node->{tag}=~/^Vs..4/ or
			 $node->{tag}=~/^PD/
			)) {
      # treat as ok
    } elsif ($pos =~ /^[adnijv]$/) {
      $pos = uc($pos);
      return 0 if $node->{tag}!~/^$pos/;
    } elsif ($pos eq 'f') {
      return 0 unless $node->{tag}=~/^Vf/ or ($node->{TID} ne "" and $node->{trlemma} eq '&Emp;');
    } elsif ($pos eq 'u') {
      return 0 unless $node->{tag}=~/^AU|^P[S1]|^P8/ or $node->{lemma} eq 'čí';
    } elsif ($pos eq 's') {
      if ($flags->{loose_dsp}) {
	return 0 unless $node->{tag}=~/^V/;
      } else {
	my $p = $tnode || $node;
	unless ($p->{dsp_root}==1) {
	  my $dsp = 0;
	  if (PDT::is_member_TR($p)) {
	    $p = $p->parent;
	    while ($p and PDT::is_coord_TR($p)) {
	      if ($p->{dsp_root}) {
		$dsp=1;
		last;
	      }
	      $p = $p->parent;
	    }
	  }
	  return 0 unless $dsp;
	}
      }
    } elsif ($pos eq 'c') {
      # TODO: c
      # this should be more strict, for ex. we should probably require IsFiniteVerb or something
      unless ($flags->{loose_subclause}) {
	print "trying STRICT subclause\n" if $V_verbose;
	return 0 unless is_direct_subclause($tnode || $node);
      } else {
	return 0 unless $node->{tag}=~/^V/;
      }
    } else {
      warn "Unknown POS: '$pos'\n";
      return 0;
    }
  } elsif (#!$no_case and  # BYT_CHANGE
	   $case ne '') { # assume $tag =~ /^[CNP]/
    unless ($kdo or
	    ($tnode and $tnode->{trlemma} eq "&Forn;") or
	    $node->{tag}=~/^[CNFPX]/ or (!$flags->{strict_adjectives} and $node->{tag}=~/^A/) or
	    ($node->{lemma}=~ /^(ano|ne|pro-1|proti-1|off-1)(?:\`|$|_)/ and $node->{afun}=~/^(ExD|Adv|Obj|Sb|Atr)(_|$)/) or
	    $node->{lemma} =~ /^(?:&percnt;|trochu|plno|hodně|nemálo-1|málo-3|dost|do-1|mezi-1|kolem-1|po-1|okolo-1|přes-1|na-1|pod-1)(?:\`|$|_)/) {
      print "NON_EMPTY CASE + INVALID POS: $node->{lemma}, $node->{tag}\n" if $V_verbose;
      print "TNODE: trlemma=$tnode->{trlemma}, operand=$tnode->{operand}\n" if $tnode and $V_verbose;
      return 0;
    }
  }
  if (!$kdo and !$no_case and $case ne '' and 
      !($tnode and $tnode->{trlemma} eq "&Forn;") and
      !($tnode and $tnode->{operand} eq "OP")
     ) {
    return 0 unless ($pos eq 'a' and ($case==1 and $node->{tag}=~/^Vs..[-1]/ or
				      $case==4 and $node->{tag}=~/^Vs..4/))
      or check_node_case($node,$case);
#     return 0 if ((($node->{tag}=~/^[NCPA]...(\d)/ and $case ne $1) or
# 		  ($node->{tag}!~/^[NCPAX]/ and $node->{lemma} !~ /^(?:&percnt;|trochu|plno|hodně|málo-3|dost)(?:\`|$|_)/))
# 		 and
# 		 not ($node->{tag}=~/^C...\D/ and not get_children_include_auxcp($node) and
# 		 not ($node->{tag}=~/^....2/ and
# 		      (print("CASE2: $node->{lemma}\n"),1) and
# 		      first {
# 			($_->{tag} =~ /^C/ or $_->{lemma} =~ /^(?:dost|málo-3|trochu|plno|hodně|spousta|sto-[12]|tisíc-[12]|milión|miliarda)(?:\`|$|_)/) and
#              		(print("CASE3: $node->{lemma}\n"),1) and
# 			($_->{tag}!~/^....(\d)/ or $case eq $1 or
# 			 ($1 eq '4' and first { $_->{lemma} eq 'přes-1' } get_aidrefs_nodes($aids,$_) or
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
    unless (first { match_node_coord($_,$tnode,$ffn,$aids,$no_case,$flags) } get_children_include_auxcp($node)) {
      my @nc = with_AR {
	PDT::GetChildren_AR($node,
			    sub{1},
			    sub{ $_[0]{afun}=~/Aux[CP]/ }) };
      unless ($flags->{ExD_tolerant} and
	      (@nc and !first { $_->{afun}!~/ExD|AtvV|AuxG|AuxX/ } @nc
	       or
               !@nc and $node->{afun}=~/Adv/ and $node->{lemma}=~/^pro-1$|^proti-1$/)) {
      print "CHILDMISMATCH: $flags->{ExD_tolerant}, $node->{lemma}"."[".join(",",map {$_->{form}} @nc)."] ... [",
	  $V->serialize_form($ffn),"]\n" if $V_verbose;
	return 0;
      }
    }
  }
  print "MATCH: [$node->{lemma} $node->{form} $node->{tag} $node->{afun}] ==> ",$V->serialize_form($fn),"\n" if $V_verbose;
  return 1;
}


sub match_text_form {
  my ($node,$serialized_form,$aids,$flags)=@_;
  $aids ||= TR_Correction::hash_AIDs_file();
  my $formdom = $V->doc()->createElement('form');
  $V->doc()->getDocumentElement()->appendChild($formdom);

  $V->parseFormPart($serialized_form,0,$formdom);
  my $ret = match_form($node, $formdom, $aids, $flags);

  $formdom->parentNode->removeChild($formdom);
  $V->dispose_node($formdom);
  return $ret;
}


my %fake_when_where = (
'tady.LOC' =>
[qw(tady tady Db------------- Adv)],
'tady.DIR1' =>
[qw(odsud odsud Db------------- Adv)],
'tady.DIR2' =>
[qw(tudy tudy Db------------- Adv)],
'tady.DIR3' =>
[qw(sem sem Db------------- Adv)],
'tam.LOC' =>
[qw(tam tam Db------------- Adv)],
'tam.LOC1' =>
[qw(odtamtud odtamtud Db------------- Adv)],
'tam.DIR2' =>
[qw(tamtudy tamtudy Db------------- Adv)],
'tam.DIR3' =>
[qw(tam tam Db------------- Adv)],
'kdy.TWHEN' =>
[qw(kdy kdy Db------------- Adv)],
'kdy.TSIN' =>
[qw(odkdy odkdy Db------------- Adv)],
'kdy.TTILL' =>
[qw(dokdy dokdy Db------------- Adv)],
'kdy.TFHL' =>
[qw(dlouho dlouho_^(o_čase;_př._dlouhá_doba) Dg-------1A---- Adv)],
'kdy.THO' =>
[qw(často často Dg-------1A---- Adv)],
'kdy.TFRWH' =>
[qw(ze z-1 RV--2---------- AuxP),
   [qw(kdy kdy Db------------- Adv)],
],
'kdy.TOWH' =>
[qw(na-1 1 RR--4---------- AuxP),
 [qw(kdy kdy Db------------- Adv)],
],
);

sub match_form {
  my ($node, $form, $aids, $flags) = @_;
  print "match_node_FLAGS: ",join(" ",%$flags),"\n" if $V_verbose;
  print "\nFORM: ".$V->serialize_form($form)." ==> $node->{lemma}, $node->{tag}\n" if $V_verbose;
  my @a = get_aidrefs_nodes($aids,$node);
  my $no_case=0;
  
  @a = grep { $_->{trlemma} ne 'se' } @a if $node->{trlemma} eq "&Rcp;";

  # try to fake AIDREFs for certain added nodes
  if ($node->{TID} ne '' and !@a) {
    # &PersPron;
    my $fake_node = FSNode->new();
    # if node is 1st/2nd person and the verb is in 1st/2nd person,
    # we may suppose 1st case (.1)

    print "ADDED NODE: '$node->{trlemma}'\n" if $V_verbose;
    my ($afun,$pos,$case,$gen,$num,$person,$tag,$lemma,$form)=('','XX','-','-','-','-');
    if ($node->{trlemma} =~ /^&Neg;$/) {
      $lemma = 'ne';
      $tag = 'TT-------------';
    } elsif (exists($fake_when_where{$node->{trlemma}.".".$node->{func}})) {
      my $fake = $fake_when_where{$node->{trlemma}.".".$node->{func}};
      my $fake_children;
      ($form,$lemma,$tag,$fake_children,$afun) = @$fake;
      if (ref($fake_children)) {
	foreach my $fake_child (@$fake_children) {
	  my $c = FSNode->new();
	  ($c->{form},$c->{lemma},$c->{tag},$c->{afun}) = @$fake_child;
	  $c->{_P_}=$fake_node;
	  $fake_node->{_F_} ||= $c;
	}
      }
      push @a,$fake_node;
    } elsif ($node->{trlemma} =~ /^(já|my)$/) {
      print "ADDED JA/MY: '$node->{trlemma}'\n" if $V_verbose;
      print "VERB-PERSONS:",join("\t",map { $_->{form}." ".verb_person($aids,$_) } PDT::GetFather_TR($node)),"\n"
	if $V_verbose;

      if (first { verb_person($aids,$_) eq '1' } PDT::GetFather_TR($node)) {
	$lemma = 'já';
	if ($form eq 'já') {
	  $tag='PP-S1--1-------';
	} else {
	  $tag='PP-P1--1-------';
	}
	push @a,$fake_node;
      } else {
	$lemma = 'já';
	$tag='PP-XX--1-------';
      }
      push @a,$fake_node;
    } elsif ($node->{trlemma} =~ /^(ty|vy)$/) {
      if (first { verb_person($aids,$_) eq '2' } PDT::GetFather_TR($node)) {
	$lemma = 'ty';
	if ($form eq 'ty') {
	  $tag='PP-S1--2-------';
	} else {
	  $tag='PP-P1--2-------';
	}
      } else {
	$lemma = 'ty';
	$tag='PP-XX--2-------';
      }
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'všechen') {
      $tag = 'PLYSX----------';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'stejně') {
      $lemma = 'stejně_^(*1ý)';
      $tag = 'Dg-------1A----';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'stejný') {
      $tag = 'AAXXX----1A----';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'tak') {
      $lemma = 'tak-3';
      $tag = 'Db-------------';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'takový') {
      $tag = 'AAXXX----------';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq '&EmpNoun;' or $node->{trlemma} eq '&Idph;') {
      $tag = 'NNXXX----------';
      $no_case=2 if $node->{trlemma} eq '&Idph;';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq '&Emp;') {
      $pos='VX';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'ten') {
      $tag='PDXSX----------';
      push @a,$fake_node;
    } elsif ($node->{trlemma} eq 'on' and $flags->{fake_perspron}) {
      my $gender = ($node->{gender} eq 'ANIM' ? 'M' : ($node->{gender}=~/^([INF])/ ? $1 : 'X'));
      my $number = ($node->{number}=~/^([PS])/ ? $1 : 'X');
      $tag='PP'.$gender.$number.'X--3-------';
      push @a,$fake_node;
    }
    if (@a) {
      $tag = $pos.$gen.$num.$case.'--'.$person.'-------'     unless defined($tag);
      $fake_node->{tag}=$tag;
      $fake_node->{afun}=$afun;
      $fake_node->{lemma} = $lemma || $node->{trlemma};
      $fake_node->{form} = $form || $node->{trlemma};
      $fake_node->{trlemma} = $node->{trlemma};
      $fake_node->{TID} = $node->{TID};
      $fake_node->{__no_fake} = $node; 
      print "Creating FAKE node [form=$fake_node->{form},lemma=$fake_node->{lemma},tag=$fake_node->{tag}\n" if $V_verbose;
    } else {
      $no_case=1;
    }
  } elsif ($node->{TID} ne '') {
    $no_case=1;
  }

  if (@a) {
    my @ok_a;
    my $node_aidrefs = getAIDREFsHash($node);
    foreach (@a) {
      if (!$flags->{no_ignore} and first { $_->{afun}=~/^Aux[CP]/
		  and $_->{lemma} !~ /^místo-2_/ and $node_aidrefs->{$_->{AID}} } with_AR { PDT::GetFather_AR($_,sub{0}) }) {
	print "Ignoring AIDREF to $_->{form}\n" if $V_verbose;
      } else {
	print "Accepting AIDREF to $_->{form}\n" if $V_verbose;
	push @ok_a,$_;
      }
    }

    my ($parent) = $form->getChildrenByTagName('parent');
    my ($pnode) = $parent->getChildrenByTagName('node') if $parent;
    if ($pnode) {
      foreach my $p (PDT::GetFather_TR($node)) {
	unless (match_node($p,$p,$pnode,$aids,0,$flags,1)) {
	  print "PARENT-CONSTRAINT MISMATCH: [$p->{lemma} $p->{form} $p->{tag}] ==> ",$V->serialize_form($pnode),"\n" if $V_verbose;
	  return 0;
	}
      }
    }
    my @form_nodes = $form->getChildrenByTagName('node');
    if (@form_nodes) {
      foreach my $fn (@form_nodes) {
	unless (first { match_node($_,$node,$fn,$aids,$no_case,$flags,1) } @ok_a) {
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


sub verb_person {
  my ($aids,$node)=@_;
  return '-' unless $node->{tag}=~/^V/;
  foreach (get_aidrefs_nodes($aids,$node)) {
    return $1 if $_->{tag}=~/^V......(\d)/;
  }
  return 'X';
}
sub get_func { join '|',grep {$_ ne '???'} split /\|/, $_[0]->{func} };

sub frame_matches_rule ($$$) {
  my ($V,$frame,$frame_test) = @_;
  foreach my $el (@$frame_test) {
    if (ref($el)) { # match a regexp
      my ($func, $regexp)=@$el;
      my $oblig = ($func=~s/^\?// ? 1 : 0);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->all_elements($frame);
      if (!defined($element)) {
	return 0 unless $oblig;
	next;
      }
      return 0 unless first { /$regexp/ } map { $V->serialize_form($_) } $V->forms($element);
    } elsif ($el =~ /^([?!])?([[:upper:]]*)\((.*)\)$/) {
      my ($oblig, $func, $forms)=($1,$2,$3);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->all_elements($frame);
      if (!defined($element)) {
	return 1 if $oblig eq '!';
	return 0 unless $oblig eq '?';
	next;
      }
      my @forms = $V->split_serialized_forms($forms);
      next unless @forms;
      my %forms = map { $V->serialize_form($_) => 1 } $V->forms($element);
      foreach my $form (@forms) {
	$form = TrEd::ValLex::Data::expandFormAbbrevs($form);
	if ($oblig eq '!') {
	  return 0 if $forms{$form};
	} else {
	  return 0 unless $forms{$form};
	}
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

      my ($element) = grep { $V->func($_) eq $func } $V->all_elements($new);
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

      my ($element) = grep { $V->func($_) eq $func } $V->all_elements($new);
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
  my @transformed;
  TRANS:
  foreach my $rule (@$trans_rules) {
    $i++; $j=0;
    my ($verbtest,@frame_tests) = @$rule;
    my $vt = $verbtest->($node,$aids);
    my $filter_applied = 0;
    if ($vt) { # check if rule matches verb
      while (@frame_tests) {
	my $frame_rule = shift @frame_tests;
	my ($frame_test,$frame_trans,$opts) = @$frame_rule;
	$opts ||= {};
	#TODO: check if we better stop here or continue
	#  possibly: make each rule have a parameter for this: i.e. "filter"-like rules

	$j++;
	my $cache_key = "r:$i t:$j f:".$V->frame_id($frame);
	# only use cache if no filter was applied so far
	if (!$filter_applied and $V->user_cache->{$cache_key}) {
	  print "TRANSFORMING FRAME ".$V->frame_id($frame)." (rule $i/$j): ".$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
	  $frame = $V->user_cache->{$cache_key};
	  print "RESULT: ".$V->serialize_frame($frame)."\n\n" if (!$quiet and $V_verbose);
	  last TRANS; # except for filters?
	} else {
	  # print "testing rule $cache_key\n" if (!$quiet and $V_verbose);
	  if (frame_matches_rule($V,$frame,$frame_test)) {
	    print "TRANSFORMING FRAME ".$V->frame_id($frame)." (rule $i/$j): ".$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
	    if ($opts->{KEEP_ORIG}) {
	      push @transformed, transform_frame($V,$frame,$frame_trans);
	      print "RESULT: ".$V->serialize_frame($transformed[$#transformed])."\n\n" if (!$quiet and $V_verbose);
	      print "WILL TRY ORIGINAL FRAME TOO\n" if (!$quiet and $V_verbose);
	    } else {
	      $frame = transform_frame($V,$frame,$frame_trans);
	      print "RESULT: ".$V->serialize_frame($frame)."\n\n" if (!$quiet and $V_verbose);
	      $V->user_cache->{$cache_key} = $frame unless $filter_applied; # only cache if no filter was applied so far
	    }
	    $filter_applied ||= $opts->{FILTER} || $opts->{KEEP_ORIG};
	    last TRANS unless $opts->{KEEP_ORIG} || $opts->{FILTER}; # except for filters
	  }
	}
      }
      last TRANS if $vt eq 'STOP'; # stop if verbtest matched, but no rule applied
    }
  }
  return $frame,@transformed;
}

sub _filter_OPER_AP_and_jako_APPS {
  # filter out all members of jako.APPS right of the aposition node
  # and all OPER_AP nodes
  my ($n)=@_;
  while (PDT::is_member_TR($n)) {
    return 1 if
      ($n->parent and
       ($n->parent->{func} eq "APPS" and $n->{memberof} eq "AP" and
	($n->parent->{trlemma} =~ /^(jako|&Colon;|&Hyphen;|&Lpar;)$/ 
	 or first { $_->{func} eq "CM" and $_->{lemma} eq 'například' } PDT::GetChildren_TR($n))
#	  or
#	    $n->parent->{func} eq "OPER"
      ) and
       (($n->{AID} ne "" and $n->parent->{AID} ne "" and
	 $n->parent->{ord} < $n->{ord}) or
	(($n->{AID} eq "" or $n->parent->{AID} eq "") and
	 $n->parent->{dord} < $n->{dord})))
	or
      ($n->parent and PDT::is_coord_TR($n->parent) and
       $n->parent->{trlemma} eq "aniž" and
       $n->{memberof} eq "CO" and
       (($n->{AID} ne "" and $n->parent->{AID} ne "" and
	 $n->parent->{ord} < $n->{ord}) or
	(($n->{AID} eq "" or $n->parent->{AID} eq "") and
	 $n->parent->{dord} < $n->{dord})))
	or
	  (($n->{func} eq "OPER" and
	      $n->parent and $n->parent->{func} eq "APPS" and
		$n->{memberof} eq "AP"));
    $n=$n->parent;
  }
  return 0;
}


sub _has_parent_coord_a {
  my ($m,$nebo) = @_;
  my $res = with_AR {
    $m->parent and
    ($m->parent->{lemma} eq 'a-1' or $nebo and $m->parent->{lemma} eq 'nebo') and 
    PDT::is_coord($m->parent) and $m->{afun}=~/_Co$/ and
    not first { $_->{ord} > $m->{ord} } PDT::expand_coord_apos($m->parent)
  };
  return $res ? 1 :0
}


sub match_element ($$$$$$$) {
  my ($V,$c,$e,$node,$aids,$flags,$quiet) = @_;
  print $V->func($e)." $c->{tag} $c->{lemma}\n"     if (!$quiet and $V_verbose);

  my @forms = $V->forms($e);
  if (!$quiet and $V_verbose) {
    print "--------------------------\n";
    print "NODE: $c->{func},$c->{lemma},$c->{tag}\n";
    print "ELEMENT: ",$V->serialize_element($e)."\n";
  }
  if (@forms) {
    unless (first { match_form($c,$_,$aids,$flags) } @forms) {
      if ($V_verbose) {
	print "\n09 no form matches: $c->{func},$c->{lemma},$c->{tag}\n";
      } elsif (!$quiet) {
	print "09 no form matches: $c->{func},$c->{lemma},$c->{tag}\t";
	Position($node);
      }
      $c->{_light}='_LIGHT_' unless $quiet;
      return 0;
    }
  }
  return 1;
}

sub validate_frame {
  my ($V,$trans_rules,$node, $frame,$aids,$pj4,$quiet,$flags) = @_;

  my @transformed = do_transform_frame($V,$trans_rules,$node, $frame,$aids,$quiet);
  if (@transformed>1) {
    print "TRANSFORMATION RETURNED ".scalar(@transformed)." FRAMES, WILL CHECK ALL\n" if (!$quiet and $V_verbose);
    my @ok_frames = grep {
      local $V_verbose=0;
      validate_frame_no_transform($V, $node, $_, $aids, $pj4, 1, $flags)
    } @transformed;
    unless ($quiet) {
      # once more for the show
      print scalar(@ok_frames)." OF ".scalar(@transformed)." FRAMES MATCHED, HERE IS WHY:\n\n" if (!$quiet and $V_verbose);
      if (@ok_frames) {
	return 1 unless $V_verbose;
	foreach (@ok_frames) {
	  print "FRAME ".$V->frame_id($_)."\n" if (!$quiet and $V_verbose);
	  validate_frame_no_transform($V, $node, $_, $aids, $pj4, 0, $flags);
	}
	return 1;
      } else {
	foreach (@transformed) {
	  print "FRAME ".$V->frame_id($_)."\n" if (!$quiet and $V_verbose);
	  validate_frame_no_transform($V, $node, $_, $aids, $pj4, 0, $flags);
	}
	return 0;
      }
    }
  } else {
    validate_frame_no_transform($V, $node, $transformed[0], $aids, $pj4, $quiet, $flags);
  }
}

sub validate_frame_no_transform {
  my ($V,$node, $frame,$aids,$pj4,$quiet, $flags) = @_;

  local @actants = qw(ACT PAT EFF MAT ADDR) if ($V->getPOS($frame) eq 'N');
  local $match_actants = '(?:'.join('|',@actants).')' if ($V->getPOS($frame) eq 'N');

  $flags = {} unless defined($flags);
  my %all_elements;
  # check over-all validity of the frame itself
  {
      # verify, that no functors are repeated in the frame
    foreach my $el ($V->all_elements($frame)) {
      my $func = $V->func($el);
      if (exists($all_elements{$func})) {
	unless ($quiet) {
	  print "EE invalid frame: repeated elements\t";
	  Position($node);
	}
	$node->{_light}='_LIGHT_' unless $quiet;
	return 0;
      }
      $all_elements{$func} = $el;
    }
    # verify, that every alternation either consists entirely of obligatory elements
    # or entirely consists of non-obligatory elements
    foreach my $alt ($V->alternations($frame)) {
      if (grep { !$V->isOblig($_) } $V->alternation_elements($alt)) {
	unless ($quiet) {
	  print "EE invalid frame: non-obligatory element in alternation\t";
	  Position($node);
	}
	$node->{_light}='_LIGHT_' unless $quiet;
	  return 0;
      }
    }
  }

  my ($word_form) = $V->word_form($frame);

  if ($word_form) {
    my @forms = $V->forms($word_form);
    print "WORD FORM: ",$V->serialize_element($word_form)."\n" if (!$quiet and $V_verbose);
    if (@forms) {
      unless (grep { match_form($node,$_,$aids,{%$flags,no_ignore => 1}) } @forms) {
	unless ($quiet) {
	  print "11 no word form matches: $node->{lemma},$node->{tag}\t";
	  Position($node);
	}
	$node->{_light}='_LIGHT_' unless $quiet;
	return 0;
      }
    }
  }

  my @c = PDT::GetChildren_TR($node,sub { $_[0]->{func} !~/^(CM|RHEM|PREC)$/ });

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
#      print "22 found children of pz4:".scalar(@d)."\t";
#      Position($node);
    }
    push @c,@d;
  }

  # ignore all coordinated members right of a "coz" on the level of "coz"'s parent
  my %ignore;
  foreach my $m (@c) {
    if (($m->{tag}=~/^V/ or $m->{trlemma} eq '&Emp;') 
	and PDT::is_coord_TR($m->parent) and
	first { $_->{trlemma} eq "což" } PDT::GetChildren_TR($m)) {
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
    } elsif ($m->{AID} ne "" and
	     (($m->{lemma}=~/^(podobně|daleko-1|další)(_|$)/
	       and _has_parent_coord_a($m,1))
              or ($m->{lemma}=~/^(atd-1|aj-2|aj-1|apod-1)(_|$)/)
	      or ( (first { $_->{lemma} =~ /^(?:dále-3|daleko-1)(_|$)/ } get_aidrefs_nodes($aids,$m)) and
		   first { $_->{lemma}=~/^tak-3(_|$)/ } (PDT::GetChildren_TR($m),get_aidrefs_nodes($aids,$m)) and
		   (first { _has_parent_coord_a($_) } get_aidrefs_nodes($aids,$m))))) {
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


  # hash children by functor
  my %c;
  foreach (@c) {
    push @{$c{get_func($_)}}, $_;
  }

  # alternations are included too, with |-concatenated functors
  my %oblig = map { $V->func($_) => $_ } $V->oblig($frame);
  my %nonoblig = map { $V->func($_) => $_ } $V->nonoblig($frame);

  # IN THIS SECTION I'LL ATTEMPT TO IMPLEMENT MATCH MODULO FUNCTORS
  if ($flags->{fuzzy}) {

    # group children by coordination
    my %groups;
    my %cgroups;
    my %element_matches;
    my %group_matches;
    for my $child (@c) { 
      my $coord = _highest_coord($child);
      push @{ $groups{ $coord->{AID}.$coord->{TID} } }, $child;
      $cgroups{$child} = $coord->{AID}.$coord->{TID};
    }
    print "FUZZY MATCHING: ",$V->serialize_frame($frame)."\n" if $V_verbose;
    foreach my $o (keys %oblig) {
      my $e = $oblig{$o};
      if ($V->is_alternation($e)) {
	# TODO
	return 0;
      } else {
	# try to match each obligatory element to as many children as possible
	print "ELEMENT: ",$V->serialize_element($e)."\n" if $V_verbose;
	foreach my $g (keys %groups) {
	  # $quiet
	  print "NODES: ",join(";",(map {$_->{form}."[$_->{tag}]".".".$_->{func}} @{ $groups{$g} })),"\n" if $V_verbose;
	  if (! first { local $V_verbose = 0; !match_element($V,$_,$e,$node,$aids,$flags,1) } @{ $groups{$g} }) {
	    push @{ $element_matches{$o} }, $g;
	    push @{ $group_matches{$g} }, $o;
	    print "YES\n" if $V_verbose;
	  } else {
	    print "NO\n" if $V_verbose;
	  }
	}
      }
    }
    if ($V_verbose) {
      print "FUZZY FRAME: ",$V->serialize_frame($frame)."\n" if $V_verbose;
      print "ELEMENT RESULTS: ";
      print "$_: ",(exists($element_matches{$_}) ? scalar(@{$element_matches{$_}}) : "0")."\t" for (keys %oblig);
      print "\n";
      print "CHILD RESULTS: ";
	print join(";",(map {$_->{form}.".".$_->{func}} @{ $groups{$_} })).": ".
	  ($group_matches{$_} ? join(",",@{$group_matches{$_}}) : "")."\t" for (keys %groups);
      print "\n";
    }
    if ((!first { @{$group_matches{$_}} > 1 } keys %group_matches) and
	(!first { !exists $element_matches{$_} or 
		  @{$element_matches{$_}} != 1 } keys %oblig)) {
      # compute match cost (penalty):
      # functors changed:
      my $functors_changed = 0;
      foreach my $o (%oblig) {
	foreach my $g (@{$element_matches{$o}}) {
	  foreach my $c (grep { $_->{func}!~/^$o$/} @{$groups{$g}}) {
	    $functors_changed ++;
	  }
	}
      }
      # functors deleted:
      my $functors_to_delete = 0;
      foreach my $c (
	grep { exists($group_matches{ $cgroups{$_} }) }
	  grep { $_->{func}=~ /^[CD]PHR$|^$match_actants$/ } @c) {
	$functors_to_delete ++;
      }
      my $children = @c;
      my $actants = grep { $_->{func}=~ /^[CD]PHR$|^$match_actants$/ } @c;
      my $elements = scalar(keys(%oblig));
      print "FUZZY-MATCH (frame-elements: $elements, func-changes: $functors_changed/$children, func-deletions: $functors_to_delete/$actants)\n" if $V_verbose;
      return [$V->frame_id($frame),$elements,$children,$actants,$functors_changed,$functors_to_delete];
    } else {
      print "FUZZY-MISMATCH\n" if $V_verbose;
      return 0;
    }
  } else {
  # THIS IS THE USUAL FRAME MATCHING ROUTINE

    # check, that all obligatory elements are present
    foreach my $o (keys %oblig) {
      # at least one of alternations must match
      unless (grep exists($c{$_}), split /\|/,$o) {
	unless ($quiet) {
	  print "06 missing obligatory element: '$o'\t";
	  Position($node);
	  print "FRAME: ",$V->serialize_frame($frame)."\n" if (!$quiet and $V_verbose);
	}
	return 0;
      }
    }

    # check, that all actants present in data are in the vallex
    # check, multiplicity
    foreach my $ac (@actants,qw(DPHR CPHR)) {
      if (!$flags->{${ac}."_is_free"} and
	    exists($c{$ac}) and !exists($all_elements{$ac})) {
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

    # check realizations of obligatory elements
    foreach my $o (keys %oblig) {
      my $e = $oblig{$o};
      # 1) alternations
      if ($V->is_alternation($e)) {
	# for at least one functor in the alternations,
	# all nodes with this functor must match
	if (!$quiet and $V_verbose) {
	  print "****\n";
	  print "ALTERNATION: ",$V->serialize_element($e)."\n";
	}
	my $success = 0;
	foreach my $alt_e ($V->alternation_elements($e)) {
	  my $alt_func = $V->func($alt_e);
	  unless (ref($c{$alt_func})) {
	    print "ALTERNATIVE $alt_func NO NODES\n" if (!$quiet and $V_verbose);
	    next;
	  }
	  my $fail=0;
	  foreach my $c (@{$c{$alt_func}}) {
	    unless (match_element($V,$c,$alt_e,$node,$aids,$flags,1) ) {
	      $fail=1;
	      if (!$quiet and $V_verbose) {
		# once more for the show
		match_element($V,$c,$alt_e,$node,$aids,$flags,0);
		print "ALTERNATIVE $alt_func FAIL\n";
	      }
	      last;
	    }
	  }
	  unless ($fail) {
	    $success = 1;
	    print "ALTERNATIVE $alt_func SUCCESS\n" if (!$quiet and $V_verbose);
	    last;
	  }
	}
	unless ($success) {
	  if ($V_verbose) {
	    print "\nA0 no alternative matches: $o\n";
	  } elsif (!$quiet) {
	    print "A0 no alternative matches: $o\t";
	    Position($node);
	  }
	  print "NO MATCH FOR ALTERNATION: ",$V->serialize_element($e)."\n" if (!$quiet and $V_verbose);
	  return 0;
	}
	print "****\n" if (!$quiet and $V_verbose);
      } else {
	# 2) check obligatory frame slots
	if ($o =~ /^[CD]PHR$|^$match_actants$/) {
	  # ACTANTS:
	  # all nodes must match
	  if ($V_verbose) {
	    if (first { !match_element($V,$_,$e,$node,$aids,$flags,0) } @{$c{$o}}) {
	      return 0;
	    }
	  } else {
	    return 0 if (first { !match_element($V,$_,$e,$node,$aids,$flags,$quiet) } @{$c{$o}});
	  }
	} else {
	  # FREE MODIFIERS: some of the sibling nodes must match
	  # (meaning that it matches and if coordinated, then all
	  # other nodes with the same functor in the coordination
	  # match too)
	  my %match;
	  for my $c ( @{$c{$o}} ) {
	    my $match = match_element($V,$c,$e,$node,$aids,$flags,1);
	    my $h = _highest_coord($c);
	    if (exists $match{ $h }) {
	      $match{ $h } &&= $match;
	    } else {
	      $match{ $h } = $match;
	    }
	  }
	  unless (first { $_ } values %match) {
	    # there was a problem, report first of the nodes that didn't match
	    if ($V_verbose) {
	      first { !match_element($V,$_,$e,$node,$aids,$flags,0) } @{$c{$o}};
	    } else {
	      first { !match_element($V,$_,$e,$node,$aids,$flags,$quiet) } @{$c{$o}};
	    }
	  }
	}
      }
    }

    # check realizations of non-obligatory elements
    foreach my $c (@c) {
      my $e = $nonoblig{get_func($c)};
      next unless ($e);
      return 0 unless match_element($V,$c,$e,$node,$aids,$flags,$quiet);
    }

    my %oblig_func = map {$_=>1} map { split /\|/,$_ } keys %oblig;
    # warn about nodes possibly added for no reason ...
    foreach my $c (@c) {
      if ($c->{TID} ne "" and !$oblig_func{get_func($c)} and
	    $c->{coref} eq "" and $c->{trlemma} ne "&Neg;" and
#            ($c->{tag} !~ /..../ or 
	       $c->{AIDREFS} eq "" and
	      $c->{trlemma} ne "&Rcp;" and
		!first { $_->{AID} ne "" } $c->visible_descendants(FS())
	       ) {

	# this is brutal
	my $coref = 0;
      TREE:
	foreach my $tree (GetTrees()) {
	  my $n = $tree;
	  while ($n) {
	    if (first { $_->[0] eq $c->{TID} and $_->[1] =~ /^(grammatical|textual)$/ }
		  ListRegroupElements([split(/\t/,$n->{coref})],
				      [split(/\t/,$n->{cortype})])) {
	      $coref = 1;
	      last TREE;
	    }
	    $n=$n->following_visible(FS());
	  }
	}
	if (!$coref) {
	  if ($flags->{delete_redundant_added_nodes}) {
	    print "0D Deleted possibly redundant added node: ",get_func($c)."\t";
	    Position($c);
	    DeleteCurrentNode($c);
	    ChangingFile(1);
	  } else  {
	    print "0X Possibly redundant added node: ",get_func($c)."\t";
	    Position($c);
	  }
	} elsif (!$flags->{dont_report_redundant}) {
	  print "0Z Possibly redundant added node, but coreference leads to it: ",get_func($c)."\t";
	  Position($c);
	}
      } elsif (!$flags->{dont_report_redundant} and
	$c->{trlemma} eq '&Rcp;' and !$oblig_func{get_func($c)} and
	  !first { $_->{tag}=~/^V/ and first { $_->{trlemma} eq "se" } $_->children } get_aidrefs_nodes($aids,$node)
	 ) {
	print "0Y Possibly redundant Rcp: ",get_func($c)."\t";
	Position($c);
      }
    }

    print "\nOK - frame matches!\n" if ($V_verbose and !$quiet);
  }
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
  my ($node,$aids,$frameid,$fix,$flags)=@_;
  $flags = {} unless defined($flags);
  my $func = get_func($node);
#  return -1 if
#    $node->{tag}=~/^Vs/ and $node->{trlemma} =~ /[nt]ý$/ or
#    $node->{tag}!~/^V/ or $func =~ /[DF]PHR/
#    or ($func eq 'APPS'and $node->{trlemma} eq 'tzn');
  #    return if $node->{tag}!~/^Vs/; # TODO: REMOVE ME!
  return -1 unless $node->{g_wordclass} =~ /^semv/;
  my $lemma = lc($node->{t_lemma});
  $lemma =~ s/_/ /g;
  $V->user_cache->{$lemma} = $V->word($lemma,'V') unless exists($V->user_cache->{$lemma});
  if ($V->user_cache->{$lemma}) {
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
		my $vlemma = $V->word_lemma($V->frame_word($vframe));
		if ($vlemma eq $lemma) {
		  push @frames, $vframe;
		} else {
		  print "00 invalid lemma for: ",$V->frame_id($vframe)," [$vlemma $lemma]\t";
		  	  print $node->{AID}.$node->{TID}."\t";
		  Position($node);
		}
	      }
	    }
	  } else {
	    # frame not resolved
	    if ($V->user_cache->{$lemma}) {
	      my @possible_frames =
		grep { validate_frame($V,\@fv_trans_rules_V,$node,$_,$aids,[],1,{%$flags, strict_adjectives => 1}) }
		  $V->valid_frames($V->user_cache->{$lemma});
	      my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	      $node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	      $node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;

	      if (@possible_frames==1) {
		#print "12 unresloved frame, but one matching frame: $fi\t";
		if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
		  print "12a no frame assigned, one of two frames matches, the other is EMPTY: $fi\t";
		} elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
		  print "12b no frame assigned, one frame matches, the other have no actants: $fi\t";
		} else {
		  print "12 no frame assigned, one frame matches, but other frames with actants exist: $fi\t";
		}
		print join("|",sort map { $V->frame_id($_) } @possible_frames)."\t";
		if ($fix) {
		  print "FIXED\t";
		  $node->{frameid}=join "|",map { $V->frame_id($_) } @possible_frames;
		  $node->{framere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
		  ChangingFile(1);
		}
	      } elsif (@possible_frames>1) {
		print "13 unresloved frame, but more matching frames: $fi\t";
		print join("|",sort map { $V->frame_id($_) } @possible_frames)."\t";
	      } else {
		print "14 unresloved frame, but no matching frame: $fi\t";
	      }
	    } else {
	      print "15 unresloved frame and lemma not found: $fi\t";
	    }
	    print $node->{AID}.$node->{TID}."\t";
	    Position($node);
	    return 0;
	  }
	} else {
	  print "02 frame not found: $fi\t";
	  print $node->{AID}.$node->{TID}."\t";
	  Position($node);
	  return 0;
	}
      }
      if (@frames) {
# 	if ($fix) {
# 	print "FIXED\t";
# 	  $node->{frameid}=join "|",map { $V->frame_id($_) } @frames;
# 	  $node->{framere} = join " | ", map { $V->serialize_frame($_) } @frames;
# 	  ChangingFile(1);
# 	}
	foreach my $frame (@frames) {
	  return 0 unless validate_frame($V,\@fv_trans_rules_V,$node,$frame,$aids,[],0,$flags);
	}
	# process frames
      } else {
	print "03 no valid frame for: $node->{$frameid} \t";
	print $node->{AID}.$node->{TID}."\t";
	Position($node);
	return 0;
      }
    } else {
      if ($V->user_cache->{$lemma}) {
	my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	my @possible_frames = 
	  grep { validate_frame($V,\@fv_trans_rules_V,$node,$_,$aids,[],1,
				{%$flags, strict_adjectives => 1}) }
	    @word_frames;
	#$node->{$frameid} = join "|", map { $V->frame_id($_) } @possible_frames;
	#$node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	if (@possible_frames == 1 and
	    @word_frames == 1) {
	  my @els = $V->all_elements($possible_frames[0]);
	  if (@els == 0) {
	    print "16 no frame assigned, but word has only EMPTY frame, which matches:\t";
	  } else {
	    print "17 no frame assigned, but word has only one frame, which matches:\t";
	  }
	  if ($fix) {
	    print "FIXED\t";
	    $node->{frameid}=join "|",map { $V->frame_id($_) } @possible_frames;
	    $node->{framere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	    ChangingFile(1);
	  }
	} elsif (@possible_frames==1) {
	  if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
	    print "18a no frame assigned, one of two frames matches, the other is EMPTY:\t";
	  } elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
	    print "18b no frame assigned, one frame matches, the other have no actants:\t";
	  } else {
	    print "18 no frame assigned, one frame matches, but other frames with actants exist:\t";
	  }
	  print join (",",map { $V->frame_id($_) } @possible_frames)."\t";
	  if ($fix) {
	    print "FIXED\t";
	    $node->{frameid}=join "|",map { $V->frame_id($_) } @possible_frames;
	    $node->{framere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	    ChangingFile(1);
	  }
	} elsif (@possible_frames>1) {
	  print "19 no frame assigned, but more matching frames:\t";
	  print join("|",sort map { $V->frame_id($_) } @possible_frames)."\t";
	} elsif (@word_frames==0) {
	  print "21 no frames:\t";
	} else {
	  my @fuzzy_frames =
	    grep { ref($_) }
	    map { validate_frame($V,\@fv_trans_rules_V,$node,$_,$aids,[],1,{ %$flags, fuzzy => 1}) }
	      @word_frames;
	  if (@fuzzy_frames >= 1) {
	    my $fuzzy = scalar(@fuzzy_frames);
	    print "2A no frame assigned, no match, but $fuzzy match(es) modulo functors:\t";
	    print join("|",map { $_->[0].
				   sprintf("(%.2f)",($_->[4]+$_->[5]/$_->[1]))
				   ."[elems:$_->[1],nodes:$_->[2],actants:$_->[3],ch:$_->[4],del:$_->[5]]"
			       } @fuzzy_frames)."\t";
	  } else {
	    print "20 no frame assigned, but no matching frame:\t";
	  }
	}
      } else {
	print "04 no frame assigned: $lemma\t";
      }
      print $node->{AID}.$node->{TID}."\t";
      Position($node);
      return 0;
    }
  } else {
    print "05 lemma not in vallex: $lemma (V)\t";
    print $node->{AID}.$node->{TID}."\t";
    Position($node);
    return 0;
  }
  return 1;
}



sub check_nounadj_frames {
  my ($node,$aids,$frameid,$pj4,$flags)=@_;
  $flags = {} unless defined($flags);
#  if (@$pj4) {
#    Position($pj4->[0]);
#  }

  my $func = get_func($node);
  return unless ($node->{g_wordclass}=~/^(semn|semadj|semadv)/);
  my $pos = ($node->{g_wordclass}=~/semn/ ? 'N' :
	     $node->{g_wordclass}=~/semadj/ ? 'A' :
	     $node->{g_wordclass}=~/semadv/ ? 'D' : 'X');

  local @actants = qw(ACT PAT EFF MAT ADDR) if ($pos eq 'N');
  local $match_actants = '(?:'.join('|',@actants).')' if ($pos eq 'N');

  my $lemma = lc($node->{t_lemma});
  $lemma =~ s/_/ /g;
  $V->user_cache->{$lemma} = $V->word($lemma,$pos) unless exists($V->user_cache->{$lemma});
  if ($V->user_cache->{$lemma}) {
    if ($node->{$frameid} ne '') {
      my @frames;
      foreach my $fi (split /\|/, $node->{$frameid}) {
	my $frame = $V->by_id($fi);
	if (ref($frame)) {
	  my @valid = $V->valid_frames_for($frame);
	  if (@valid) {
	    foreach my $frame (@valid) {
	      my $vlemma = $V->word_lemma($V->frame_word($frame));
	      if ($vlemma eq $lemma) {
		push @frames, $frame;
	      } else {
		print "00 invalid lemma for: ",$V->frame_id($frame)," [$vlemma $lemma]\t";
		Position($node);
		return 0;
	      }
	    }
	  } else {
	    # frame not resolved
	    my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	    my @possible_frames = 
	      grep { validate_frame($V,\@fv_trans_rules_N,$node,$_,$aids,$pj4,1,$flags) }
		@word_frames;
	    #$node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	    #$node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	    if (@possible_frames == 1 and
		@word_frames == 1) {
	      my @els = $V->all_elements($possible_frames[0]);
	      if (@els == 0) {
		print "10 unresloved frame, but word has only EMPTY frame, which matches: $fi\t";
	      } else {
		print "11 unresloved frame, but word has only one frame, which matches: $fi\t";
	      }
	    } elsif (@possible_frames==1) {
	      if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
		print "12a no frame assigned, one of two frames matches, the other is EMPTY: $fi\t";
	      } elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
		print "12b no frame assigned, one frame matches, the other have no actants: $fi\t";
	      } else {
		print "12 no frame assigned, one frame matches, but other frames with actants exist: $fi\t";
	      }
	    } elsif (@possible_frames>1) {
	      print "13 unresloved frame, but more matching frames: $fi\t";
	    } elsif (@word_frames==0) {
	      print "21 no frames: $fi\t";
	    } else {
	      print "14 unresloved frame, but no matching frame: $fi\t";
	    }
	    Position($node);
	    return 0;
	  }
	} else {
	  print "02 frame not found: $fi\t";
	  if ($flags->{delete_not_found}) {
	    $node->{frameid} = "";
	    $node->{framere} = "";
	    print "FIX: DELETED\n";
	    ChangingFile(1);
	  }
	  Position($node);
	  return 0;
	}
      }
      if (@frames) {
	#$node->{$frameid}=join "|",map { $V->frame_id($_) } @frames;
	#$node->{rframere} = join " | ", map { $V->serialize_frame($_) } @frames;
	foreach my $frame (@frames) {
	  return 0 unless validate_frame($V,\@fv_trans_rules_N,$node,$frame,$aids,$pj4,0,$flags);
	}
	# process frames
      } else {
	print "03 no valid frame for: $node->{$frameid} \t";
	Position($node);
	return 0;
      }
    } else {
      if ($V->user_cache->{$lemma}) {
	my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	my @possible_frames = 
	  grep { validate_frame($V,\@fv_trans_rules_N,$node,$_,$aids,$pj4,1,$flags) }
	    @word_frames;
	#$node->{$frameid} = join "|", map { $V->frame_id($_) } @possible_frames;
	#$node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	if (@possible_frames == 1 and
	    @word_frames == 1) {
	  my @els = $V->all_elements($possible_frames[0]);
	  if (@els == 0) {
	    print "16 no frame assigned, but word has only EMPTY frame, which matches:\t";
	  } else {
	    print "17 no frame assigned, but word has only one frame, which matches:\t";
	  }
	} elsif (@possible_frames==1) {
	  if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
	    print "18a no frame assigned, one of two frames matches, the other is EMPTY:\t";
	  } elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
	    print "18b no frame assigned, one frame matches, the other have no actants:\t";
	  } else {
	    print "18 no frame assigned, one frame matches, but other frames with actants exist:\t";
	  }
	} elsif (@possible_frames>1) {
	  print "19 no frame assigned, but more matching frames:\t";
	} elsif (@word_frames==0) {
	  print "21 no frames:\t";
	} else {
	  print "20 no frame assigned, but no matching frame:\t";
	}
      } else {
	print "04 no frame assigned: $lemma\t";
      }
      Position($node);
      return 0;
    }
  } else {
    # report problem only if this instance has DPHR, CPHR or actant
    if (grep { get_func($_) =~ /^[CD]PHR$|^$match_actants$/ } PDT::GetChildren_TR($node)) {
      print "05 lemma not in vallex: $lemma ($pos)\t";
      Position($node);
    }
    return 0;
  }
  return 1;
}
}
