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
use Carp;
use strict;
use vars qw($V @actants $match_actants %lemma_normalization @fv_trans_rules_N @fv_trans_rules_V @fv_passivization_rules);

our $V_verbose;

sub Position {
#ifdef NTRED
  &NPosition;
#else
  &FPosition;
#endif
}

sub _highest_coord {
  my ($t_node)=@_;
  while ($t_node->{is_member} and PML_T::IsCoord($t_node->parent)) {
    $t_node=$t_node->parent;
  }
  return $t_node;
}

sub has_auxR {
  my ($a_node)=@_;
  croak "has_auxR: not an a-node" unless $a_node and defined $a_node->{afun};
  my $result = 0;
  # skip infinitives, search for analytic AuxR
  while ($a_node and $a_node->attr('m/tag')=~/^Vf/) {
    $result ||= (first { $_->{afun} eq 'AuxR' and $_->attr('m/lemma')=~/^se_/ }
		   PML_A::GetEChildren($a_node,\&PML_A::DiveAuxCP)) ? 1 : 0;
    last if $result;
    # PP: check me: the following step used node with TR=hide or trlemma matching
    # /^(začít|začínat|končit|přestat|stihnout)$/
    # we replaced the first condition with {afun}=~/^Aux/
    $a_node = first { $_->{afun}=~/^Aux/ or
		    $_->attr('m/lemma') =~ /^(?:začít|začínat|končit|přestat|stihnout)(?:[-_].*|$)/
		  } PML_A::GetEParents($a_node,sub{0});
  }
  if (!$result and $a_node and $a_node->attr('m/tag')=~/^V/) {
    $result = (first { $_->{afun} eq 'AuxR' and $_->attr('m/lemma')=~/^se_/ }
		 PML_A::GetEChildren($a_node,\&PML_A::DiveAuxCP)) ? 1 : 0;
  }
  return $result;
}

BEGIN {
@actants = qw(ACT PAT EFF ORIG ADDR);
$match_actants = '(?:'.join('|',@actants).')';
@fv_passivization_rules = (
    # /1
    [[ 'ACT(.1)', 'PAT(.4)', ['EFF', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])$/ ]] =>
     [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-PAT(.4)', '+PAT(.1)',
       ['EFF', sub { s/^(\.a?)4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])$/${1}1${2}/ } ]],
     { LABEL => 'V_PASS_1' }
    ],
    # /2 frame test
    [[ 'ACT(.1)', ['PAT', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?$/ ]]  =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])',
      ['PAT',sub { s/((?:^|,)\.a?)4((?:\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?(?:,|$))/${1}1${2}/ } ]],
     { LABEL => 'V_PASS_2' }],
    # /3 ditto for CPHR
    [[ 'ACT(.1)', ['CPHR', qr/^[^\[]*[.:][^\[,:.]*4/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', ['CPHR',sub { s/^([^\[]*[.:][^\[,:.]*)4/${1}1/ }]],
     { LABEL => 'V_PASS_3' }],
    # /4 ditto for DPHR
    [[ 'ACT(.1)', ['DPHR', qr/^[^\[]*[.:][^\[,:.]*4/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', ['DPHR',sub { s/^([^\[]*[.:][^\[,:.]*)4/${1}1/ }]],
     { LABEL => 'V_PASS_4' }],
    # /5 frame test
    [[ 'ACT(.1)', 'ADDR(.4)' ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-ADDR(.4)', '+ADDR(.1)' ],
     { LABEL => 'V_PASS_5' }],
    # /6 frame test
    [[ 'ACT(.1)', 'ADDR(.2)' ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])', '-ADDR(.2)', '+ADDR(.1)' ],
     { LABEL => 'V_PASS_6' }],
    # /7 frame test
    [[ 'ACT(.1)', ['EFF', qr/^\.a?4(\[(jako|{jako,jakožto})(\/AuxY)?[.:]?\])?$/ ] ] =>
    [ '-ACT(.1)', '+ACT(.7;od-1[.2])',
      ['EFF',
       sub { s/^(\.a?)4(\[(jako|{jako,jakožto})(\/AuxY)?\])?[.:]?$/${1}1${2}/ }
      ]],
     { LABEL => 'V_PASS_7' }]);

@fv_trans_rules_V =
  (
   # 1.
   [# verb test: "nekdo1.ADDR ma auto pronajmuto nekym2/od+nekoho2.ACT",
    # transforms to: "nekdo2.ACT pronajmul auto nekomu1.ADDR"
    sub { my ($node) = @_;
	  my $a_node = PML_T::GetALexNode($node);
	  ($a_node and $a_node->attr('m/tag')=~/^Vs/ and
	   (first { my $a_lex=PML_T::GetALexNode($_);
		   $_->{functor} eq 'ACT' and (!$a_lex or $a_lex->attr('m/tag')!~/^....1/) 
		  }
	      PML_T::GetEChildren($node))
	   and
	   (first { $_->attr('m/lemma') =~ /^mít$|^mívat_/ } PML_T::GetANodes($node))
	  ) ? 1:0; # STOP
	} =>
    [[ '(.$2<s>)', 'ACT(.1)' ] => 
       ['-ACT(.1)', '+ACT(.4)' ],
     { LABEL => 'V_MA_UVARENO_PASS_FRAME' }
    ],
    # frame transformation rules:
    # frame test
    [[ 'ACT(.1)', 'ADDR(.3)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])', '-ADDR(.3)','-ADDR(pro-1[.4])', '+ADDR(.1)' ],
     { KEEP_ORIG => 1, # try the original frame too
       LABEL => 'V_MA_UVARENO_OD_ADDR'
     } 
    ],
    [[ 'ACT(.1)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])' ],
     { KEEP_ORIG => 1,
       LABEL => 'V_MA_UVARENO'
     } # try the original frame too
    ]
   ],
   # 2.
   [# case: "mrizka/mrizku=PAT(.4,.1) nejde udelat", "mrizka/mrizku je videt"
    # adds PAT(.1)
    sub { my ($node) = @_;
	  my $a_lex = PML_T::GetALexNode($node);
	  ($a_lex and
	   $a_lex->attr('m/tag')=~/^Vf/ and
	   first { $_->attr('m/lemma') =~ /^(?:být|jít)$/ }
	   grep { defined }
	   map { PML_T::GetALexNode($_) }
	   PML_T::GetEParents($node)
	  ) ? 1:0;
	} =>
    [[ 'PAT(.4)' ] => [ '+PAT(.1)' ],
     { LABEL => 'V_JDE_UDELAT' }
    ],
   ],
   # 3.
   [# verb test: passive verb
    # applies to "problem je vyresen nekym", but not to "nekdo ma problem vyresen",
    # but should still apply to "problem ma byt vyresen"
    sub { my ($node) = @_;
	  my $a_lex = PML_T::GetALexNode($node);
	  ($a_lex->attr('m/tag')=~/^Vs/ and
	   not (
	     # eliminate "ma", "bude mit" or even "mel by mit"
	     # Here is what we eliminate:
	     # -------------------------
	     # there is some "mit"
	     first { $_->attr('m/lemma') =~ /^mít$|^mívat_/ } PML_T::GetANodes($node)
	     # there is some active hidden verb
	     and
	     first { $_->attr('m/tag') =~ /V[^fc]/ } PML_T::GetANodes($node)
	     # there is no infinitive "byt"
	     and
	     !first { $_->attr('m/lemma') =~ /^být$|^bývat_/ and $_->attr('m/tag') =~ /Vf/ } PML_T::GetANodes($node)
	    )
	  ) ? 1:0;
	} =>
    # frame transformation rules:
    [[ '(.$2<s>)' ] => [],
     { LABEL => 'V_PASS_FRAME_NOTRANS' }
    ],
    [[ '(.v[se/AuxR])' ] => [],
     { LABEL => 'V_REFLEX_PASS_FRAME_NOTRANS' }
    ],
    @fv_passivization_rules,
    # frame test
    [[ 'ACT(.1)' ] =>
     [ '-ACT(.1)', '+ACT(.7)', '+ACT(od-1[.2])'],
     { LABEL => 'V_PASS_ACT' }
    ],
   ],
   # 4.
   [# dispmod
    sub { $_[0]->attr('gram/dispmod') eq 'disp1' } => # PP: was eq 'DISP'; don't know which of disp0/disp1 corresponds to it
    # frame transformation rules:
    # frame test
    [[ 'ACT(.1)', 'PAT(.4)' ] =>
     [ '-ACT(.1)', '+ACT(.3)', '-PAT(.4)', '+PAT(.1)', '+(.[se])', '+MANN(*)' ],
     { LABEL => 'V_DISPMOD_PAT' }
    ],
    # frame test
    [[ 'ACT(.1)' ] =>
    # form transformation rules:
     [ '-ACT(.1)', '+ACT(.3)', '+(.[se])', '+MANN(*)' ],
     { LABEL => 'V_DISPMOD' }
    ]
   ],
   # 5.
   [ # chce se mu riskovat prohra/prohru (zachtelo se mu stihnout přestat zazpivat pisnicku, pisnicka se mu zachtela zazpivat)
    sub {
      my ($node) = @_;
      my $a_node = PML_T::GetALexNode($node);
      return 0 unless $a_node and $a_node->attr('m/tag')=~/^Vf/;
      if ($node->{is_generated}) {
	$a_node = first { $_->attr('m/tag')=~/^Vf/ } GetANodes($node);
	return 0 unless $a_node;
      }
      my ($p) = PML_A::GetEParents($a_node,\&PML_A::DiveAuxCP);
      while ($p and $p->attr('m/tag')=~/^Vf/ and $p->attr('m/lemma') =~ /^(?:začít|začínat|končit|přestat|stihnout)(?:[-_].*|$)/) {
	($p) = PML_A::GetEParents($p,\&PML_A::DiveAuxCP);
      }
      return 0 unless $p and $p->attr('m/lemma') =~ /^(?:za)?chtít$/ and has_auxR($p);
    } =>
    [[ 'ACT(.1)', 'PAT(.4)' ] =>
     [ '-ACT(.1)', '+ACT(.3)', '+PAT(.#)' ],
     { LABEL => 'V_CHCE_SE_PAT' }
    ],
    [[ 'ACT(.1)' ] =>
     [ '-ACT(.1)', '+ACT(.3)' ],
     { LABEL => 'V_CHCE_SE' }
    ]
   ],
   # 6.
   [# verb test: verb treated as passive due to "se".AuxR
    sub {
      my ($node) = @_;
      return (first { $_->attr('m/tag')=~/^V/ and has_auxR($_) }
		(PML_T::GetANodes($node),
		 grep { $_->attr('m/lemma') eq "dát" and $_->attr('m/tag')=~/V.........N/ }
		   grep {defined}
		   map { PML_T::GetALexNode($_) }
		   PML_T::GetEParents($node))
	       ) ? 1: 0;
    }
    # used to be ACT(!), but some abstract constructions with se.AuxR feel like ACT(.7)
    =>
    @fv_passivization_rules
   ],
   # 7.
   [ # nechat si/dat si udelat neco udelat od nekoho/nekym
    sub {
      my ($node) = @_;
      my $a_node = PML_T::GetALexNode($node);
      return 0 unless $a_node->attr('m/tag')=~/^Vf/;
      if ($node->{is_generated}) {
	$a_node = first { $_->{tag}=~/^Vf/ } PML_T::GetANodes($node);
	return 0 unless $a_node;
      }
      # get analytic parent, but only in case that no AuxC/AuxP are in the way
      my ($p) = (climb_auxcp($a_node)->{afun} =~ /Aux[CP]/)
	? undef : PML_A::GetEParents($a_node,\&PML_A::DiveAuxCP);
      return ($p and $p->attr('m/lemma')=~/^(?:nech(áv)?at|^dát)(?:[-_].*|$)/) ? 1 : 0;
    } =>
      [[ 'ACT(.1)', 'PAT(.7)' ] =>
       [ '-ACT(.1)', '+ACT(od-1[.2];.7)', '+PAT(.4)' ],
       { LABEL => 'V_NECHAT_SI_UDELAT_PAT' }
      ],
      [[ 'ACT(.1)' ] =>
       [ '-ACT(.1)', '+ACT(od-1[.2];.7)' ],
       { LABEL => 'V_NECHAT_SI_UDELAT' }
      ]
   ],
   # 8. imperative
   [
    sub { my ($node) = (@_);
	  my $a_node = PML_T::GetALexNode($node);
	  $a_node->{tag}=~/^Vi/ ? 1 : 0 } =>
    [[ 'ACT(.1)' ] => [ '+ACT(.5)' ],
     { LABEL => 'V_IMPERATIVE' }
    ]
   ],
   # 9. agreement between EFF and PAT in "mit tisic aut koupenych"
   [
    sub {
      my ($node)=@_;
      $node->{t_lemma} eq "mít"
      and
      first { 
	my $a_lex = PML_T::GetALexNode($_);
	$_->{functor} eq "PAT" and
	$a_lex and
	( # "nema pranic spolecneho"
	  $a_lex->attr('m/lemma')=~/^(nic|pranic|málo-2|pramálo|něco|co-1)$/ or
	  # "s Petrem ma 5/mnoho vlastnosti spolecnych"
	  $a_lex->attr('m/tag')=~/^....2/ or is_numeric_expression($a_lex) or
	  # "s Petrem ma spolecneho, ze ..."
	  $a_lex->attr('m/tag')=~/^V/ and first { $_->attr('m/lemma') eq "že" } PML_T::GetANodes($_)
	)
      } PML_T::GetEChildren($node)
    } =>
      [[ 'PAT(.4)','EFF(.4)' ] => [ '+EFF(.a2)' ],
       { LABEL => 'V_SHODA_EFF_DOPLNKU' }
      ]
     ],
   # 10. verb test: verb treated as passive due to: něco "se".AuxR má (stihnout začít přestat) dělat
   [
    sub {
      my ($node) = @_;
      my $a_node = PML_T::GetALexNode($node);
      return 0 unless $a_node and $a_node->attr('m/tag')=~/^Vf/;
      if ($node->{is_generated}) {
	$a_node = first { $_->attr('m/tag')=~/^Vf/ } GetANodes($node);
	return 0 unless $a_node;
      }
      my ($p) = PML_A::GetEParents($a_node,\&PML_A::DiveAuxCP);
      while ($p and $p->attr('m/tag')=~/^Vf/ and $p->attr('m/lemma') =~ /^(?:začít|začínat|končit|přestat|stihnout)(?:[-_].*|$)/) {
	($p) = PML_A::GetEParents($p,\&PML_A::DiveAuxCP);
      }
      return 0 unless $p and $p->attr('m/lemma') =~ /^(?:mít|moci)(?:$|_)/ and has_auxR($p);
    } =>
    @fv_passivization_rules
   ],
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
}

# check if genders in given tags/nodes match
sub match_gender {
  my ($g1,$g2)= @_;
  my $g=$g1.$g2;
  return (($g1 eq $g2) or
          ($g=~/-|X|^(?:Q[FN]|[FN]Q|T[IF]|[IF]T|H[NF]|[NF]H|Y[IMZ]|[ZIM]Y|Z[IMN]|[IMN]Z)$/)
         ) ? 1 : 0;
}

sub match_number {
  my ($n1,$n2)= @_;
  my $n=$n1.$n2;
  return (($n1 eq $n2) or
          ($n=~/^-|X|^DP$|^PD$|W/)
         ) ? 1 : 0;
}

sub match_lemma {
  my ($l1,$l2)=@_;
  return ($l1 eq $l2 or
	  exists ($lemma_normalization{$l1}) and $lemma_normalization{$l1} eq $l2) ? 1 : 0;
}

sub match_node_coord {
  my ($a_node, $t_node, $fn,$no_case,$flags) = @_;
  $flags = {} unless defined($flags);
  my $res = match_node($a_node, $t_node, $fn,$no_case,$flags);
  if (!$res and $a_node->{afun} =~ /^Coord|^Apos/) {
    foreach my $member (grep {
      not($_->attr('m/lemma') =~ /^a-1$|^nebo$/ or
	  $_->attr('m/lemma')=~/^(podobně|daleko-1|další)(_|$)/ or
	  ($_->attr('m/lemma') =~ /^(?:dále-3|daleko-1)(_|$)/ and
	     first { $_->attr('m/lemma') =~ /^tak-3(_|$)/ } PML_A::GetEChildren($_,\&PML_A::DiveAuxCP)))
    } PML_A::ExpandCoord($a_node)) {
      return 0 unless match_node($member,$t_node,$fn,$no_case,$flags);
    }
    return 1;
  } else {
    return $res;
  }
}

sub is_numeric_expression {
  my ($a_node)=@_;
  return ($a_node->attr('m/tag') =~ /^C/ or $a_node->attr('m/lemma') =~ /^(?:dost|málo-3|kolik|tolik-1|trochu|plno|hodně|nesčetně|spousta|půl-[12]|sto-[12]|tisíc-[12]|milión|půldruhý|miliarda|stovka|desítka|pár-[12]|příliš)(?:\`|$|_)/) ? 1:0;
}

# climb up a chain of AuxC or AuxP (skipping Coord/Apos nodes that
# might got in between, but only for coordinations the current node is a member of)
sub climb_auxcp {
  my ($a_node) = @_;
  my $last = $a_node;
  my $is_member = ($a_node->{is_member}) ? 1 : 0;
  while ($a_node->parent) {
    if ($is_member and $a_node->parent->{afun} eq 'Coord') {
      $a_node=$a_node->parent;
      $is_member = $a_node->{is_member};
    } elsif ($is_member and $a_node->parent->{afun} eq 'Apos') {
      $a_node=$a_node->parent;
      $is_member = $a_node->{is_member};
    } elsif ($a_node->parent->{afun}=~/^Aux[CP]/) {
      $last=$a_node=$a_node->parent;
    } else {
      last;
    }
  }
  $a_node = $last if ($a_node->{afun}=~/^Coord|^Apos/);
  return $a_node;
}

sub get_children_include_auxcp {
  my ($a_node)=@_;
  if ($a_node->{afun} =~ /^Aux[CP]/) {
    return map { PML_A::ExpandCoord($_) } $a_node->children;
  } else {
    return map { climb_auxcp($_) } PML_A::GetEChildren($a_node,\&PML_A::DiveAuxCP);
  }
}

sub same_clause_below {
  my ($t_node)=@_;
  my $a_node = PML_T::GetALexNode($t_node);
  return 0 unless $a_node or $t_node->{t_lemma} eq '#EmpVerb';
  return 1 unless ($a_node and $a_node->attr('m/tag')=~/^V/);
  my @p= grep {defined} map { PML_T::GetALexNode($_) } PML_T::GetEParents($t_node);
  if ($a_node and $a_node->attr('m/tag')=~/^Vf/ and
      first { $_->attr('m/lemma') =~ /^(umět|dokázat|lze|schopný)(|$)/ } @p
      or
      $a_node and $a_node->attr('m/tag')=~/^Vs/ and
      first { $_->attr('m/lemma') =~ /^být|bývat|mít$/ } @p) {
    return 1;
  } else {
    return 0;
  }
}

sub is_direct_subclause {
  my ($t_node)=@_;
  # |což-1
  # TODO: try finite verb
  my $obj_pronoun=qr/^(?:co-1|co-3|jak-3|jaký|kdo|kudy|kolik|proč|kde|kdeže|jak-2|co-4|kdy|kam|který|nakolik|odkud|čí)(?:_|$)/;
  if ($t_node->{__no_fake}) {
    $t_node=$t_node->{__no_fake};
  }
  my $a_node = PML_T::GetALexNode($t_node);
  if ($t_node->{t_lemma} eq '#EmpVerb' or
      $a_node and $a_node->attr('m/tag')=~/^V/) {
    print "subclause trying:",join(", ",map{$_->{t_lemma}} $t_node),"\n" if $V_verbose;
    my @c= PML_T::GetEChildren($t_node);
    print "1st level:",join(", ",map{$_->{t_lemma}} @c),"\n" if $V_verbose;
    @c = grep { same_clause_below($_) } @c;
    while (@c) {
      return 1 if (first { $_->attr('m/lemma') =~ $obj_pronoun }
		   grep {defined}
		   map { PML_T::GetALexNode($_) } @c);
      @c = uniq(map { grep { same_clause_below($_) } PML_T::GetEChildren($_) } @c);
    }
  }
  return 0;
}

sub check_node_case {
  my ($a_node,$case)=@_;

  # simple case
  print "   CASE: Checking simple case\n" if $V_verbose;
  return 1 if $a_node->attr('m/tag')=~/^[FNCPA]...(\d)/ and $case eq $1;
  print "   CASE: Checking case N..XX\n" if $V_verbose;
  return 1 if $a_node->attr('m/tag')=~/^N..XX/;
  print "   CASE: Checking AC..- tag ('vinen', etc.)\n" if $V_verbose;
  return 1 if $a_node->attr('m/tag')=~/^AC..-/ and $case=~/[14]/;#
  print "   CASE: Checking case X\n" if $V_verbose;
  return 1 if $a_node->attr('m/tag')=~/^[FNCPA]...X/ or $a_node->attr('m/tag')=~/^X...-/;
  print "   CASE: Checking lemmas w/o case\n"  if $V_verbose;
  # special lemmas without case:
  return 1 if $a_node->attr('m/lemma') =~ /^(?:%|trochu|plno|hodně|málo-3|dost)(?:\`|$|_)/;
  print "   CASE: Checking simple number w/o case\n"  if $V_verbose;
  # simple number without case: e.g. 3
  return 1 if ($a_node->attr('m/tag')=~/^C=..\D/);
  print "   CASE: Checking 'kolem|okolo'+Num\n"  if $V_verbose;
  # kolem milionu (lidí)
  return 1 if $a_node->attr('m/lemma') =~ /^(?:do-1|kolem-1|okolo-1)$/ and $a_node->{afun}=~/^AuxP/ and
    first { $_->attr('m/tag')=~/^C=/
	    or $_->attr('m/tag')=~/^....2/
	      and (is_numeric_expression($_) or first { $_->attr('m/tag')=~/^C=/ } get_children_include_auxcp($_))
	  } get_children_include_auxcp($a_node);
  print "   CASE: Checking 'pres|na'+Num\n"  if $V_verbose;
  # přes milion (lidí)
  return 1 if $a_node->attr('m/lemma') =~ /^(přes-1|na-1|pod-1)$/ and $a_node->{afun}=~/^AuxP/ and
    first { $_->attr('m/tag')=~/^C=/ or $_->attr('m/tag')=~/^....4/ and is_numeric_expression($_) } get_children_include_auxcp($a_node);
  print "   CASE: Checking num+2 construct\n"  if $V_verbose;
  # a number has the right case (or no case at all) and is analytically governing the node
  return 1 if ($a_node->attr('m/tag')=~/^....2/ and
	       first {
		 print("     CASE: testing parent instead: ".$_->attr('m/form')."\n") if $V_verbose;
		 is_numeric_expression($_) and
		 ($V_verbose && print("     CASE: parent is numeric: ".$_->attr('m/form')."\n"),1) and
		   (($_->attr('m/tag')!~/^....(\d)/) or ($case == $1) or
		    ($_->attr('m/tag')=~/^....4/ and
		     grep { $_->attr('m/lemma') =~ /^(přes-1|na-1|pod-1)$/ and $_->{afun}=~/^AuxP/ }
		     PML_A::GetEParents($_,sub{0})
		    ) or
		    ($_->attr('m/tag')=~/^....2/ and
		     first {
		       $_->attr('m/lemma') =~ /^(do-1|kolem-1|okolo-1)$/ and $_->{afun}=~/^AuxP/ }
		       PML_A::GetEParents($_,sub{0})
		    ))
	       } PML_A::GetEParents($a_node,sub{0}));
  print "   CASE: Checking 2+num construct\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/tag')=~/^....2/ and
	       first {
		 is_numeric_expression($_) and (($_->attr('m/tag')!~/^....(\d)/) or ($case eq $1))
	       } get_children_include_auxcp($a_node));
  print "   CASE: Checking 2+za XY Kc construct\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/tag')=~/^....2/ and
	       first {
		 $_->attr('m/lemma') eq 'za-1' and
		   first { is_numeric_expression($_) } get_children_include_auxcp($_)
		 } get_children_include_auxcp($a_node));
  print "   CASE: Checking mezi-1 X /COORD Y Kc construct\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/lemma') eq 'mezi-1' and
		 scalar(get_children_include_auxcp($a_node)) > 1 and
		 !first { !is_numeric_expression($_) } get_children_include_auxcp($a_node));
  print "   CASE: Checking 'po jablicku' construct\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/lemma') eq 'po-1' and
		 !first { $_->attr('m/tag')!~/^....6/ } get_children_include_auxcp($a_node));
  print "   CASE: Checking 'po jablicku' construct - hack 2\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/tag') =~ /^....6/ and
	       $a_node->parent and $a_node->parent->attr('m/lemma') eq 'po-1');
  print "   CASE: Checking actant of a copied 'CPR' with hodne\n"  if $V_verbose;
  return 1 if ($a_node->attr('m/tag') =~ /^....2/ and
	       $a_node->parent and
	       $a_node->parent->attr('m/lemma') eq 'než-2' and
	       $a_node->parent->parent->attr('m/lemma') eq 'hodně' and
	       (1<grep { $_->{afun}!~/^AuxY/ } $a_node->parent->children));

  print "   CASE: All checks failed\n"  if $V_verbose;
  return 0;
}

sub match_node {
  my ($a_node, $t_node, $fn, $no_case,$flags,$toplevel) = @_;

  print "match_node_FLAGS: ",join(" ",%$flags),"\n" if $V_verbose;

  my ($lemma,$form,$pos,$case,$gen,$num,$deg,$neg,$agreement,$afun)=map {$fn->getAttribute($_)} qw(lemma form pos case gen num deg neg agreement afun);

  my $l = $a_node->attr('m/lemma');
  my $f = $a_node->attr('m/form');

  if ($lemma ne '' or $form ne '') {
    if ($a_node->attr('m/tag')=~/^P[5P]/ or $a_node->attr('m/tag')=~/^PJ/ or
	  ($a_node->attr('m/tag')=~/^P4/ and $a_node->attr('m/lemma')=~/^který$|^jaký$|^co-4/)) {
      my $find_cortype = $a_node->attr('m/tag')=~/^P[5P]/ ? 'coref_text.rf' : 'coref_gram.rf';
      if ($V_verbose) {
	print "--------------------------\n";
	print "EXPANDING DPHR/CPHR TO CO-REFERRED NODE ($find_cortype)\n";
      }
      for my $coref (ListV($t_node->attr($find_cortype))) {
	# find referent
	print "LOOKING FOR $find_cortype: $coref\n" if ($V_verbose);
	my ($referent,undef) = PML_T::SearchForNodeById($coref);
	if (ref $referent) {
	  print "FOUND CO-REFERRED NODE: $referent->{t_lemma}\n" if ($V_verbose);
	  my $a_referent = PML_T::GetALexNode($referent);
	  if ($a_referent) {
	    ($l,$f) = map { $a_referent->attr($_) } qw(m/lemma m/form);
	  } else {
	    print "CO-REFERRED NODE HAS NO a/lex.rf\n" if ($V_verbose);
	  }
	} else {
	  print "CANNOT FIND CO-REFERRED NODE\n" if ($V_verbose);
	}
	last;
      }
    }
  }

  if ($V_verbose) {
    print "TEST [no_case=$no_case, tag=".$a_node->attr('m/tag').", lemma=".$l."]  ==>  ";
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
    my ($p)=PML_A::GetEParents($a_node,\&PML_A::DiveAuxCP);
    if ($p) {
      $p->attr('m/tag')=~/^....(\d)/;
      $case=$1 if ($case eq '' and $1);
      $p->attr('m/tag')=~/^...([DWSP])/;
      $num=$1 if ($num eq '' and $1);
      $p->attr('m/tag')=~/^..([TQFMINHZY])/;
      $gen=$1 if ($gen eq '' and $1);
      if ($V_verbose) {
	print "AGREEMENT [no_case=$no_case, tag=$a_node->attr('m/tag'), lemma=".$l.", p-lemma=".$p->attr('m/lemma').", p-tag=".$p->attr('m/tag')."]  ==>  ";
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
    return 0 if $a_node->attr('m/tag')=~/^..([TQFMINHZY])/ and !match_gender($gen,$1);
  }
  if ($neg eq 'negative') {
    return 0 unless $a_node->attr('m/tag')=~/^..........N/;
  }
  if ($afun ne "" and $afun ne 'unspecified') {
    return 0 unless $a_node->{afun} eq $afun;
  }

  # KDO-RULE:
  my $kdo;
  #  print "KDO-RULE: step 1: case $case rest '$lemma$form$pos$gen$num$deg' a '$agreement' N '$neg' top $toplevel tag $a_node->attr('m/tag')\n" if $V_verbose;
  if ($toplevel			# no nodes above
      and $case =~ /^[14]$/
      and !$agreement
      and (!$neg or $neg eq 'unspecified')
      and "$lemma$form$pos$gen$num$deg" eq ""
      and $a_node->attr('m/tag')=~/^V/
      and not first {
	$_->attr('m/lemma') eq 'ten'
	  # PP: these conditions could not be (easily) translated to PML:
	  # and IsHidden($_) and $_->{functor} ne 'INTF'
      } PML_A::GetEParents($a_node,sub{0})
     ) {
    # GAP: kdo/co-1 can be a one level below if the EChild is a modal verb or
    # 'byt treba', etc.
    $kdo = first { $_->attr('m/lemma') eq 'kdo' or $_->attr('m/lemma') eq 'co-1' } 
      grep {defined}
      map { PML_T::GetALexNode($_) }
      PML_T::GetEChildren($t_node);
  }
  print "KDO-RULE: ".$kdo->attr('m/form')." on ".$a_node->attr('m/form')."\n" if $kdo and $V_verbose;
  if ($pos ne '') {
    if ($pos eq 'a' and ($case==1 and $a_node->attr('m/tag')=~/^Vs..[-1]/ or
			 $case==4 and $a_node->attr('m/tag')=~/^Vs..4/ or
			 $a_node->attr('m/tag')=~/^PD/
			)) {
      # treat as ok
    } elsif ($pos =~ /^[adnijv]$/) {
      $pos = uc($pos);
      return 0 if $a_node->attr('m/tag')!~/^$pos/;
    } elsif ($pos eq 'f') {
      return 0 unless ($a_node->attr('m/tag')=~/^Vf/
			 or ($t_node->{is_generated} and $t_node->{t_lemma} eq '#EmpVerb'));
    } elsif ($pos eq 'u') {
      return 0 unless $a_node->attr('m/tag')=~/^AU|^P[S1]|^P8/
	or $a_node->attr('m/lemma') eq 'čí';
    } elsif ($pos eq 's') {
      if ($flags->{loose_dsp}) {
	return 0 unless $a_node->attr('m/tag')=~/^V/;
      } else {
	my $p = $t_node;
	unless ($p->{is_dsp_root}) {
	  my $dsp = 0;
	  if ($p->{is_member}) {
	    $p = $p->parent;
	    while ($p and PML_T::IsCoord($p)) {
	      if ($p->{is_dsp_root}) {
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
	return 0 unless is_direct_subclause($t_node);
      } else {
	return 0 unless $a_node->attr('m/tag')=~/^V/;
      }
    } else {
      warn "Unknown POS: '$pos'\n";
      return 0;
    }
  } elsif (			#!$no_case and  # BYT_CHANGE
    $case ne '') {		# assume $tag =~ /^[CNP]/
    unless ($kdo or
	      ($t_node and $t_node->{t_lemma} eq "#Forn") or
		$a_node->attr('m/tag')=~/^[CNFPX]/ or (!$flags->{strict_adjectives} and $a_node->attr('m/tag')=~/^A/) or
		  ($a_node->attr('m/lemma')=~ /^(ano|ne|pro-1|proti-1|off-1)(?:\`|$|_)/ and $a_node->{afun}=~/^(ExD|Adv|Obj|Sb|Atr)(_|$)/) or
		    $a_node->attr('m/lemma') =~ /^(?:%|trochu|plno|hodně|nemálo-1|málo-3|dost|do-1|mezi-1|kolem-1|po-1|okolo-1|přes-1|na-1|pod-1)(?:\`|$|_)/) {
      print "NON_EMPTY CASE + INVALID POS: ".$a_node->attr('m/lemma').", ".$a_node->attr('m/tag')."\n" if $V_verbose;
      print "TNODE: trlemma=$t_node->{t_lemma}, operand=$t_node->{operand}\n" if $t_node and $V_verbose;
      return 0;
    }
  }
  if (!$kdo and !$no_case and $case ne '' and 
	!($t_node and $t_node->{t_lemma} eq "#Forn") and
	  !($t_node and $t_node->{is_member} and $t_node->parent and $t_node->parent->{functor} eq "OPER")) {
    return 0 unless ($pos eq 'a' and ($case==1 and $a_node->attr('m/tag')=~/^Vs..[-1]/ or
					$case==4 and $a_node->attr('m/tag')=~/^Vs..4/))
      or check_node_case($a_node,$case);
  }
  if ($num ne '') {
    return 0 if $a_node->attr('m/tag')=~/^...([DWSP])/ and !match_number($num,$1);
  }
  if ($deg ne '') {
    return 0 if ($a_node->attr('m/tag') =~ /^........([123])/ and $deg ne $1);
  }

  foreach my $tagpos (1..15) {
    if (my $tag = $fn->getAttribute('tagpos'.$tagpos)) {
      return 0 if substr($a_node->attr('m/tag'),$tagpos-1,1) !~ /[\Q$tag\E]/;
    }
  }
  foreach my $ffn ($fn->getChildrenByTagName('node')) {
    unless (first { match_node_coord($_,$t_node,$ffn,$no_case,$flags) } get_children_include_auxcp($a_node)) {
      my @nc = PML_A::GetEChildren($a_node,\&PML_A::DiveAuxCP);
      unless ($flags->{ExD_tolerant} and
		(@nc and !first { $_->{afun}!~/ExD|AtvV|AuxG|AuxX/ } @nc
		   or
		     !@nc and $a_node->{afun}=~/Adv/ and $a_node->attr('m/lemma')=~/^pro-1$|^proti-1$/)) {
	print "CHILDMISMATCH: $flags->{ExD_tolerant}, ".$a_node->attr('m/lemma')."[".
	  join(",",map {$_->attr('m/form')} @nc)."] ... [".$V->serialize_form($ffn)."]\n" if $V_verbose;
	return 0;
      }
    }
  }
  print "MATCH: [".join(' ',map { $a_node->attr($_) } qw(m/lemma m/form m/tag afun))."] ==> ",$V->serialize_form($fn),"\n" if $V_verbose;
  return 1;
}

sub match_text_form {
  my ($t_node,$serialized_form,$flags)=@_;
  my $formdom = $V->doc()->createElement('form');
  $V->doc()->getDocumentElement()->appendChild($formdom);

  $V->parseFormPart($serialized_form,0,$formdom);
  my $ret = match_form($t_node, $formdom, $flags);

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
  my ($t_node, $form, $flags) = @_;
  my $a_node = PML_T::GetALexNode($t_node);
  print "match_node_FLAGS: ",join(" ",%$flags),"\n" if $V_verbose;
  print "\nFORM: ".$V->serialize_form($form)." ==> ".$a_node->attr('m/lemma').",".$a_node->attr('m/tag')."\n" if $a_node and $V_verbose;
  my @a = PML_T::GetANodes($t_node);
  my $no_case=0;
  
  @a = grep { $_->{t_lemma} ne 'se' } @a if $t_node->{t_lemma} eq "#Rcp";

  # try to fake AIDREFs for certain added nodes
  if ($t_node->{is_generated} and !@a) {
    # &PersPron;
    my $fake_node = FSNode->new();
    # if node is 1st/2nd person and the verb is in 1st/2nd person,
    # we may suppose 1st case (.1)

    print "ADDED NODE: '$t_node->{t_lemma}'\n" if $V_verbose;
    my ($afun,$pos,$case,$gen,$num,$person,$tag,$lemma,$form)=('','XX','-','-','-','-');
    if ($t_node->{t_lemma} eq '#Neg') {
      $lemma = 'ne';
      $tag = 'TT-------------';
    } elsif (exists($fake_when_where{$t_node->{t_lemma}.".".$t_node->{functor}})) {
      my $fake = $fake_when_where{$t_node->{t_lemma}.".".$t_node->{functor}};
      my $fake_children;
      ($form,$lemma,$tag,$fake_children,$afun) = @$fake;
      if (ref($fake_children)) {
	foreach my $fake_child (@$fake_children) {
	  my $c = FSNode->new();
	  $c->{m}=Fslib::Struct->new({
	    form => $fake_child->[0],
	    lemma => $fake_child->[1],
	    tag =>  $fake_child->[2],
	  },1);
	  $c->{afun} =  $fake_child->[3];
	  $c->paste_on($fake_node);
	}
      }
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} =~ /^(já|my)$/) {
      print "ADDED JA/MY: '$t_node->{t_lemma}'\n" if $V_verbose;
      print "VERB-PERSONS:",join("\t",map {
	my $a_lex=PML_T::GetALexNode($_);
	($a_lex ? $a_lex->attr('m/form') : '')." ".verb_person($_) } PML_T::GetEParents($t_node)),"\n"
	if $V_verbose;
      if (first { verb_person($_) eq '1' } PML_T::GetEParents($t_node)) {
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
    } elsif ($t_node->{t_lemma} =~ /^(ty|vy)$/) {
      if (first { verb_person($_) eq '2' } PML_T::GetEParents($t_node)) {
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
    } elsif ($t_node->{t_lemma} eq 'všechen') {
      $tag = 'PLYSX----------';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'stejně') {
      $lemma = 'stejně_^(*1ý)';
      $tag = 'Dg-------1A----';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'stejný') {
      $tag = 'AAXXX----1A----';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'tak') {
      $lemma = 'tak-3';
      $tag = 'Db-------------';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'takový') {
      $tag = 'AAXXX----------';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq '#EmpNoun' or $t_node->{t_lemma} eq '#Idph') {
      $tag = 'NNXXX----------';
      $no_case=2 if $t_node->{t_lemma} eq '#Idph';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq '#EmpVerb') {
      $pos='VX';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'ten') {
      $tag='PDXSX----------';
      push @a,$fake_node;
    } elsif ($t_node->{t_lemma} eq 'on' and $flags->{fake_perspron}) {
      my $gender = ($t_node->{gender} eq 'ANIM' ? 'M' : ($t_node->{gender}=~/^([INF])/ ? $1 : 'X'));
      my $number = ($t_node->{number}=~/^([PS])/ ? $1 : 'X');
      $tag='PP'.$gender.$number.'X--3-------';
      push @a,$fake_node;
    }
    if (@a) {
      $tag = $pos.$gen.$num.$case.'--'.$person.'-------' unless defined($tag);
      $fake_node->{m} =
	Fslib::Struct->new({
	  tag => $tag,
	  lemma => $lemma || $t_node->{t_lemma},
	  form => $form || $t_node->{t_lemma},
	});
      $fake_node->{afun}=$afun;
      #PP: not implementable: $fake_node->{t_lemma} = $t_node->{t_lemma};
      #PP: not implementable: $fake_node->{TID} = $t_node->{TID};
      $fake_node->{__no_fake} = $t_node;
      print "Creating FAKE node [".
	join(' ',map{ "$_=".$fake_node->attr($_) } qw(m/form m/lemma m/tag))."])\n" if $V_verbose;
    } else {
      $no_case=1;
    }
  } elsif ($t_node->{is_generated}) {
    $no_case=1;
  }

  if (@a) {
    my @ok_a;
    my %in_aidrefs; @in_aidrefs{ GetANodeIDs($t_node) } = (); # to test if an a-nodes is in t-nodes a/lex.rf or a/aux.rf
    foreach my $a_n (@a) {
      if (!$flags->{no_ignore}
	  and first { $_->{afun}=~/^Aux[CP]/
		      and $_->attr('m/lemma') !~ /^místo-2_/
		      and exists($in_aidrefs{$_->{id}})
		    } PML_A::GetEParents($a_n,sub{0}) ) {
	print "Ignoring AIDREF to ".$a_n->attr('m/form')."\n" if $V_verbose;
      } else {
	print "Accepting AIDREF to ".$a_n->attr('m/form')."\n" if $V_verbose;
	push @ok_a,$a_n;
      }
    }

    my ($parent) = $form->getChildrenByTagName('parent');
    my ($pnode) = $parent->getChildrenByTagName('node') if $parent;
    if ($pnode) {
      foreach my $p (PML_T::GetEParents($t_node)) {
	unless (match_node(PML_T::GetALexNode($p),$p,$pnode,0,$flags,1)) {
	  print "PARENT-CONSTRAINT MISMATCH: [".map { $p->attr($_) } qw(m/lemma m/form m/tag)."] ==> ",$V->serialize_form($pnode),"\n" if $V_verbose;
	  return 0;
	}
      }
    }
    my @form_nodes = $form->getChildrenByTagName('node');
    if (@form_nodes) {
      foreach my $fn (@form_nodes) {
	unless (first { match_node($_,$t_node,$fn,$no_case,$flags,1) } @ok_a) {
	  print "MISMATCH: [".join(",",map { $a_node->attr($_) } qw(m/lemma m/form m/tag))."] ==> ".$V->serialize_form($fn)."\n" if $a_node and $V_verbose;
	  return 0;
	}
      }
      return 1;
    } elsif ($form->getChildrenByTagName('typical')) {
      # TODO: somebody pls provide me the map of functors and their typical forms
      print "MATCH: typical form always matches (TODO)" if $V_verbose;
      return 1;
    } elsif ($form->getChildrenByTagName('elided')) {
      my $r = ($t_node->{is_generated} and !PML_T::GetANodeIDs($t_node)) ? 1 : 0;
      print $r ? "MATCH: node elided" : "MISMATCH: node not elided\n" if ($V_verbose);
      return $r;
    } elsif ($form->getChildrenByTagName('recip')) {
      my $r = ($t_node->{t_lemma} ne "#Rcp") ?  1 : 0; # correct?
      print $r ? "MATCH: t_lemma=#Rcp" : "MISMATCH: trlemma=$t_node->{t_lemma} instead of #Rcp\n" if ($V_verbose);
      return $r;
    } elsif ($form->getChildrenByTagName('state')) {
      my $r = ($t_node->{is_state}) ? 1 : 0;
      print $r ? "MATCH: state=ST" : "MISMATCH: state!=ST\n" if ($V_verbose);
      return $r;
    } else {
      print "MATCH, THOUGH FORM UNSPECIFIED: ==> ",$V->serialize_form($form),"\n" if $V_verbose;
      return 1;
    }
  } else {
    if ($V_verbose) {
      print "NOAIDREFS: ";
      print $a_node->attr('m/lemma')." ".$a_node->attr('m/form') if $a_node;
      print "\n";
    }
    if ($a_node) {
      print "WW no AIDREFs: $t_node->{t_lemma}\t";
      Position($t_node);
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
  my ($t_node)=@_;
  my $a_node = PML_T::GetALexNode($t_node);
  return '-' unless $a_node and $a_node->attr('m/tag')=~/^V/;
  foreach (PML_T::GetANodes($t_node)) {
    $a_node=PML_T::GetALexNode($_);
    return $1 if $a_node and $a_node->attr('m/tag')=~/^V......(\d)/;
  }
  return 'X';
}

sub get_func { join '|',AltV($_[0]->{functor}) };

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
  my ($V,$old_frame,$frame_trans,$label) = @_;
  my $new = $V->clone_frame($old_frame);
  if ($new->getAttribute('transformations') ne "") {
    $new->setAttribute('transformations', $new->getAttribute('transformations')." ".$label);
  } else {
    $new->setAttribute('transformations',$label);
  }
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
  my ($V,$trans_rules,$t_node,$frame,$quiet) = @_;
  my ($i, $j)=(0,0);
  my @transformed;
  TRANS:
  foreach my $rule (@$trans_rules) {
    $i++; $j=0;
    my ($verbtest,@frame_tests) = @$rule;
    my $vt = $verbtest->($t_node);
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
	      push @transformed, transform_frame($V,$frame,$frame_trans,"r${i}t${j}:".$opts->{LABEL});
	      print "RESULT: ".$V->serialize_frame($transformed[$#transformed])."\n\n" if (!$quiet and $V_verbose);
	      print "WILL TRY ORIGINAL FRAME TOO\n" if (!$quiet and $V_verbose);
	    } else {
	      $frame = transform_frame($V,$frame,$frame_trans,"r${i}t${j}:".$opts->{LABEL});
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

sub _a_or_t_precedes {
  my ($t_a,$t_b)=@_;
  my ($a_a,$a_b) = map { PML_T::GetALexNode($_) } ($t_a,$t_b);
  return ((!$t_a->{is_generated} and !$t_b->{is_generated} and $a_a and $a_b and $a_a->{ord}<$a_b->{ord})
	    or
	  (($t_a->{is_generated} or $t_b->{is_generated}) and $t_a->{deepord} < $t_b->{deepord}));
}
sub _filter_OPER_AP_and_jako_APPS {
  # filter out all members of jako.APPS right of the aposition node
  # and all OPER_AP nodes
  my ($t_n)=@_;
  while ($t_n->{is_member}) {
    return 1 if
      $t_n->parent and (
      (($t_n->parent->{functor} eq "APPS" and
	($t_n->parent->{t_lemma} =~ /^(?:jako|#Colon|#Hyphen|#Dash|#Lpar)$/
	 or first { $_->{functor} eq "CM" and $_->attr('m/lemma') eq 'například' } PML_T::GetEChildren($t_n))
       ) and _a_or_t_precedes($t_n->parent,$t_n))
      or
      (PML_T::IsCoord($t_n->parent) and
       $t_n->parent->{t_lemma} eq "aniž" and
       _a_or_t_precedes($t_n->parent,$t_n))
      or
      ($t_n->{functor} eq "OPER" and
	$t_n->parent->{functor} eq "APPS"));
    $t_n=$t_n->parent;
  }
  return 0;
}


sub _has_parent_coord_a {
  my ($a_node,$nebo) = @_;
  return
    ($a_node->parent
    and ($a_node->parent->attr('m/lemma') eq 'a-1' 
	 or $nebo and $a_node->parent->attr('m/lemma') eq 'nebo')
    and $a_node->parent->{afun} eq 'Coord' and $a_node->{is_member}
    and not first { $_->{ord} > $a_node->{ord} } PML_A::ExpandCoord($a_node->parent)) ? 1 :0;
}

sub _node_info ($) {
  my ($t_node)=@_;
  my $a_node = PML_T::GetALexNode($t_node);
  my ($tag,$lemma)=$a_node ? ($a_node->attr('m/tag'),
			      $a_node->attr('m/lemma')) : ('N/A','N/A');
  return "[functor=$t_node->{functor}, t_lemma=$t_node->{functor}, a/lex_rf=[m/lemma=$lemma, m/tag=$tag]]";
}
sub match_element ($$$$$$) {
  my ($V,$t_node,$e,$node,$flags,$quiet) = @_;
  my $info = _node_info($t_node);
  if (!$quiet and $V_verbose) {
    print "\n--------------------------\n";
    print $V->func($e)."$info\n";
  }

  my @forms = $V->forms($e);
  if (!$quiet and $V_verbose) {
    print "--------------------------\n";
    print "NODE: $info\n";
    print "ELEMENT: ",$V->serialize_element($e)."\n";
  }
  if (@forms) {
    unless (first { match_form($t_node,$_,$flags) } @forms) {
      if ($V_verbose) {
	print "\n09 no form matches: $info\n";
      } elsif (!$quiet) {
	print "09 no form matches: $info\t";
	Position($node);
      }
      $PML_T::show{$t_node->{id}}=1 unless $quiet;
      return 0;
    }
  }
  return 1;
}

sub validate_frame {
  my ($V,$trans_rules,$t_node, $frame,$pj4,$quiet,$flags) = @_;
  my @transformed = do_transform_frame($V,$trans_rules,$t_node, $frame,$quiet);
  if (@transformed>1) {
    print "TRANSFORMATION RETURNED ".scalar(@transformed)." FRAMES, WILL CHECK ALL\n" if (!$quiet and $V_verbose);
    my @ok_frames = grep {
      local $V_verbose=0;
      validate_frame_no_transform($V, $t_node, $_, $pj4, 1, $flags)
    } @transformed;
    unless ($quiet) {
      # once more for the show
      print scalar(@ok_frames)." OF ".scalar(@transformed)." FRAMES MATCHED, HERE IS WHY:\n\n" if (!$quiet and $V_verbose);
      if (@ok_frames) {
	return 1 unless $V_verbose;
	foreach (@ok_frames) {
	  print "FRAME ".$V->frame_id($_)."\n" if (!$quiet and $V_verbose);
	  validate_frame_no_transform($V, $t_node, $_, $pj4, 0, $flags);
	}
	return 1;
      } else {
	foreach (@transformed) {
	  print "FRAME ".$V->frame_id($_)."\n" if (!$quiet and $V_verbose);
	  validate_frame_no_transform($V, $t_node, $_, $pj4, 0, $flags);
	}
	return 0;
      }
    }
  } else {
    validate_frame_no_transform($V, $t_node, $transformed[0],  $pj4, $quiet, $flags);
  }
}

### PP: ABOVE ALREADY CONVERTED FOR PML ###########
sub validate_frame_no_transform {
  my ($V,$t_node, $frame,$pj4,$quiet, $flags) = @_;

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
	  Position($t_node);
	}
	$PML_T::show{$t_node->{id}}=1 unless $quiet;
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
	  Position($t_node);
	}
	$PML_T::show{$t_node->{id}}=1 unless $quiet;
	return 0;
      }
    }
  }

  my ($word_form) = $V->word_form($frame);

  if ($word_form) {
    my @forms = $V->forms($word_form);
    print "WORD FORM: ",$V->serialize_element($word_form)."\n" if (!$quiet and $V_verbose);
    if (@forms) {
      unless (grep { match_form($t_node,$_,{%$flags,no_ignore => 1}) } @forms) {
	unless ($quiet) {
	  print "11 no word form matches: "._node_info($t_node)."\t";
	  Position($t_node);
	}
	$PML_T::show{$t_node->{id}}=1 unless $quiet;
	return 0;
      }
    }
  }

  my @c = grep { $_->{functor} !~/^(CM|RHEM|PREC)$/ } PML_T::GetEChildren($t_node);

  # we must include children of ktery/jaky/... in relative subclauses
  # co-referring to the current node
  my $a_node = PML_T::GetALexNode($t_node);
  if ($a_node and $a_node->attr('m/tag')=~/^N/ and @$pj4) {
    my $id = $t_node->{id};
    my @d = grep { first { $_ eq $id }
		     (ListV($_->{'coref_gram.rf'}),
		      ListV($_->{'coref_text.rf'}),
		      ListV($_->{'compl.rf'}))
		 } @$pj4;
    #    if (@d) {
    #      print "20 found ".scalar(@d)." refering ",join "/",(map { $_->{t_lemma} } @d),"\t";
    #      Position($t_node);
    #    }
    @d = map { PML_T::GetEChildren($_) } @d;
    if (@d) {
#      print "22 found children of pz4:".scalar(@d)."\t";
#      Position($t_node);
    }
    push @c,@d;
  }

  # ignore all coordinated members right of a "coz" on the level of "coz"'s parent
  my %ignore;
  foreach my $t_m (@c) {
    my $a_m = PML_T::GetALexNode($t_m);
    if (($t_m->{t_lemma} eq '#EmpVerb' or ($a_m and $a_m->attr('m/tag')=~/^V/))
	and PML_T::IsCoord($t_m->parent)
	and first { $_->attr('m/lemma') eq 'což-1' }
	  grep {defined} map { PML_T::GetALexNode($_) }
	  PML_T::GetEChildren($t_m)) {
      $ignore{$t_m}=1;
      print "WW should ignore node: '$t_m->{t_lemma}'\n" if (!$quiet and $V_verbose);
      if (!$t_m->{is_generated} and $a_m) {
	for (grep { $_->{functor} eq $t_m->{functor} }
	     map { PML_T::ExpandCoord($_) }
	     grep {
	       my $a_lex = PML_T::GetALexNode($_);
	       $_->{is_member}
	       and !$_->{is_generated}
	       and $a_lex
	       and $a_lex->{ord} > $a_m->{ord}  
	     } $t_m->parent->children) {
	  print "WW should also ignore node: '$_->{t_lemma}'\n" if (!$quiet and $V_verbose);
	  $ignore{$_}=1;
	}
      }
    } elsif (_filter_OPER_AP_and_jako_APPS($t_m)) {
      $ignore{$t_m}=1;
      print "WW should ignore node: '$t_m->{t_lemma}'\n" if (!$quiet and $V_verbose);
    } elsif (!$t_m->{is_generated}
	     and $a_m
	     and (($a_m->attr('m/lemma')=~/^(?:podobně|daleko-1|další)(?:_|$)/ and _has_parent_coord_a($a_m,1))
		  or ($a_m->attr('m/lemma')=~/^(atd-1|aj-2|aj-1|apod-1)(?:_|$)/)
		  or ( (first { $_->attr('m/lemma') =~ /^(?:dále-3|daleko-1)(?:_|$)/ } PML_T::GetANodes($t_m))
		       and
		       (first { $_->attr('m/lemma')=~/^tak-3(?:_|$)/ }
			  ((grep {defined} map { PML_T::GetALexNode($_) } PML_T::GetEChildren($t_m)), PML_T::GetANodes($t_m)))
		       and
		       (first { _has_parent_coord_a($_) } PML_T::GetANodes($t_m))
		      )
		 )
	    ) {
      $ignore{$t_m}=1;
      print "WW should ignore node: '$t_m->{t_lemma}'\n" if (!$quiet and $V_verbose);
    }
  }

  @c = grep {
	if ($ignore{$_}) {
	  print "WW ignoring node: '$_->{t_lemma}'\n" if (!$quiet and $V_verbose);
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
      push @{ $groups{ $coord->{id} } }, $child;
      $cgroups{$child} = $coord->{id};
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
	  print "NODES: ",join(";",(map { _node_info($_) } @{ $groups{$g} })),"\n" if $V_verbose;
	  if (! first { local $V_verbose = 0; !match_element($V,$_,$e,$t_node,$flags,1) } @{ $groups{$g} }) {
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
	print join(";",(map {_node_info($_)} @{ $groups{$_} })).": ".
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
	  foreach my $c (grep { $_->{functor}!~/^$o$/} @{$groups{$g}}) {
	    $functors_changed ++;
	  }
	}
      }
      # functors deleted:
      my $functors_to_delete = 0;
      foreach my $c (
	grep { exists($group_matches{ $cgroups{$_} }) }
	  grep { $_->{functor}=~ /^[CD]PHR$|^$match_actants$/ } @c) {
	$functors_to_delete ++;
      }
      my $children = @c;
      my $actants = grep { $_->{functor}=~ /^[CD]PHR$|^$match_actants$/ } @c;
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
	  Position($t_node);
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
	  Position($t_node);
	}
	return 0;
      } elsif (exists $c{$ac}) {
	if (@{$c{$ac}} > 1) {
	  my @ancestors = uniq(map { _highest_coord($_) } @{$c{$ac}});
	  if (@ancestors > 1) {
	    unless ($quiet) {
	      print "08 multiple actants: $ac\t";
	      Position($t_node);
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
	    unless (match_element($V,$c,$alt_e,$t_node,$flags,1) ) {
	      $fail=1;
	      if (!$quiet and $V_verbose) {
		# once more for the show
		match_element($V,$c,$alt_e,$t_node,$flags,0);
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
	    Position($t_node);
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
	    if (first { !match_element($V,$_,$e,$t_node,$flags,0) } @{$c{$o}}) {
	      return 0;
	    }
	  } else {
	    return 0 if (first { !match_element($V,$_,$e,$t_node,$flags,$quiet) } @{$c{$o}});
	  }
	} else {
	  # FREE MODIFIERS: some of the sibling nodes must match
	  # (meaning that it matches and if coordinated, then all
	  # other nodes with the same functor in the coordination
	  # match too)
	  my %match;
	  for my $c ( @{$c{$o}} ) {
	    my $match = match_element($V,$c,$e,$t_node,$flags,1);
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
	      first { !match_element($V,$_,$e,$t_node,$flags,0) } @{$c{$o}};
	    } else {
	      first { !match_element($V,$_,$e,$t_node,$flags,$quiet) } @{$c{$o}};
	    }
	  }
	}
      }
    }

    # check realizations of non-obligatory elements
    foreach my $c (@c) {
      my $e = $nonoblig{get_func($c)};
      next unless ($e);
      return 0 unless match_element($V,$c,$e,$t_node,$flags,$quiet);
    }

    my %oblig_func = map {$_=>1} map { split /\|/,$_ } keys %oblig;
    # warn about nodes possibly added for no reason ...
    foreach my $c (@c) {
      if ($c->{is_generated} and !$oblig_func{get_func($c)}
	  and !ListV($c->{'coref_gram.rf'})
	  and !ListV($c->{'coref_text.rf'})
	  and !ListV($c->{'compl.rf'})
	  and $c->{t_lemma} ne "#Neg"
	  and $c->{t_lemma} ne "#Rcp;"
	  and !PML_T::GetANodeIDs($c)
	  and !first { $_->attr('a/lex.rf') } $c->descendants) {
	# this is brutal: check if some other node refers to $c by coreference
	my $coref = 0;
      TREE:
	foreach my $tree (GetTrees()) {
	  my $n = $tree;
	  while ($n) {
	    if (first { $_ eq $c->{id} } (ListV($n->{'coref_gram.rf'}), ListV($n->{'coref_text.rf'}))) {
	      $coref = 1;
	      last TREE;
	    }
	    $n=$n->following;
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
      } elsif (!$flags->{dont_report_redundant}
	       and $c->{t_lemma} eq '#Rcp'
	       and !$oblig_func{ get_func($c) }
	       and !first { $_->attr('m/tag')=~/^V/
			    and first { $_->attr('m/lemma')=~/^se(?:_|$)/ } $_->children
			  } PML_T::GetANodes($t_node)
	) {
	print "0Y Possibly redundant Rcp: ",get_func($c)."\t";
	Position($c);
      }
    }
    print "\nOK - frame matches!\n" if ($V_verbose and !$quiet);
    if ($flags->{report_ok_transformations}) {
      print "OK ",$V->frame_id($frame),"\t", $t_node->{t_lemma},"\t",$frame->getAttribute('transformations'),"\t";
      Position($t_node);
    }
  }
  return 1;
}

sub resolve_substitution_for_assigned_frames {
  my ($V,$t_node)=@_;
  my $lemma = $t_node->{t_lemma};
  $lemma =~ s/_/ /g;
  my @frameids;
  foreach my $fi (map {my $id=$_; $id=~s/^.*?#//; $id } AltV($t_node->{'val_frame.rf'})) {
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
  return [ grep {
    my $a_lex=PML_T::GetALexNode($_);
    $a_lex and ($a_lex->attr('m/tag')=~/^PJ/ or ($a_lex->attr('m/tag')=~/^P4/ and $a_lex->attr('m/lemma')=~/^který$|^jaký$|^co-4/)) 
  } $tree->descendants ];
}

sub check_verb_frames {
  my ($t_node,$fix,$flags)=@_;
  undef %PML_T::show;
  $flags = {} unless defined($flags);
  my $func = get_func($t_node);
#  return -1 if
#    $t_node->attr('m/tag')=~/^Vs/ and $t_node->{t_lemma} =~ /[nt]ý$/ or
#    $t_node->attr('m/tag')!~/^V/ or $func =~ /[DF]PHR/
#    or ($func eq 'APPS'and $t_node->{t_lemma} eq 'tzn');
  #    return if $t_node->attr('m/tag')!~/^Vs/; # TODO: REMOVE ME!
  return -1 unless $t_node->attr('gram/sempos') eq 'v';
  my $lemma = lc($t_node->{t_lemma});
  $lemma =~ s/_/ /g;
  $V->user_cache->{$lemma} = $V->word($lemma,'V') unless exists($V->user_cache->{$lemma});
  if ($V->user_cache->{$lemma}) {
    my @VIds = map {my $id=$_; $id=~s/^.*?#//; $id } AltV($t_node->attr('val_frame.rf'));
    if (@VIds) {
      my @frames;
      foreach my $fi (@VIds) {
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
		  	  print $t_node->{id}."\t";
		  Position($t_node);
		}
	      }
	    }
	  } else {
	    # frame not resolved
	    if ($V->user_cache->{$lemma}) {
	      my @possible_frames =
		grep { validate_frame($V,\@fv_trans_rules_V,$t_node,$_,[],1,{%$flags, strict_adjectives => 1}) }
		  $V->valid_frames($V->user_cache->{$lemma});
	      my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	      $t_node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	      $t_node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;

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
		  _assign_frames($t_node,@possible_frames);
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
	    print $t_node->{id}."\t";
	    Position($t_node);
	    return 0;
	  }
	} else {
	  print "02 frame not found: $fi\t";
	  print $t_node->{id}."\t";
	  Position($t_node);
	  return 0;
	}
      }
      if (@frames) {
	# 	if ($fix) {
	#		  _assign_frames($t_node,@frames);
	# 	}
	foreach my $frame (@frames) {
	  return 0 unless validate_frame($V,\@fv_trans_rules_V,$t_node,$frame,[],0,$flags);
	}
	# process frames
      } else {
	print "03 no valid frame for: ".join('|',map {my $id=$_; $id=~s/^.*?#//; $id } AltV($t_node->{'val_frame.rf'}))." \t";
	print $t_node->{id}."\t";
	Position($t_node);
	return 0;
      }
    } else {
      if ($V->user_cache->{$lemma}) {
	my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	my @possible_frames = 
	  grep { validate_frame($V,\@fv_trans_rules_V,$t_node,$_,[],1,
				{%$flags, strict_adjectives => 1}) }
	    @word_frames;
	#$t_node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	#$t_node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	if (@possible_frames == 1 and
	    @word_frames == 1) {
	  my @els = $V->all_elements($possible_frames[0]);
	  if (@els == 0) {
	    print "16 no frame assigned, but word has only EMPTY frame, which matches:\t";
	  } else {
	    print "17 no frame assigned, but word has only one frame, which matches:\t";
	  }
	  if ($fix) {
	    _assign_frames($t_node,@possible_frames);
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
	    _assign_frames($t_node,@possible_frames);
	  }
	} elsif (@possible_frames>1) {
	  print "19 no frame assigned, but more matching frames:\t";
	  print join("|",sort map { $V->frame_id($_) } @possible_frames)."\t";
	} elsif (@word_frames==0) {
	  print "21 no frames:\t";
	} else {
	  my @fuzzy_frames =
	    grep { ref($_) }
	    map { validate_frame($V,\@fv_trans_rules_V,$t_node,$_,[],1,{ %$flags, fuzzy => 1}) }
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
      print $t_node->{id}."\t";
      Position($t_node);
      return 0;
    }
  } else {
    print "05 lemma not in vallex: $lemma (V)\t";
    print $t_node->{id}."\t";
    Position($t_node);
    return 0;
  }
  return 1;
}

sub _assign_frames {
  my ($t_node,@possible_frames)=@_;
  print "FIXED\t";
  delete $t_node->{'val_frame.rf'};
  AddToAlt($t_node,'val_frame.rf',map { 'v#'.$V->frame_id($_) } @possible_frames);
  ChangingFile(1);
}

sub check_nounadj_frames {
  my ($t_node,$pj4,$flags)=@_;
  undef %PML_T::show;
  $flags = {} unless defined($flags);
#  if (@$pj4) {
#    Position($pj4->[0]);
#  }

  my $func = get_func($t_node);
  return unless ($t_node->attr('gram/sempos')=~/^(n|adj|adv)(?:\.|$)/);
  my $pos = ($1 eq 'n'   ? 'N' :
	     $1 eq 'adj' ? 'A' :
	     $1 eq 'adv' ? 'D' : 'X');
  local @actants = qw(ACT PAT EFF MAT ADDR) if ($pos eq 'N');
  local $match_actants = '(?:'.join('|',@actants).')' if ($pos eq 'N');

  my $lemma = lc($t_node->{t_lemma});
  $lemma =~ s/_/ /g;
  $V->user_cache->{$lemma} = $V->word($lemma,$pos) unless exists($V->user_cache->{$lemma});
  if ($V->user_cache->{$lemma}) {
    my @VIds = map {my $id=$_; $id=~s/^.*?#//; $id } AltV($t_node->attr('val_frame.rf'));
    if (@VIds) {
      my @frames;
      foreach my $fi (@VIds) {
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
		Position($t_node);
		return 0;
	      }
	    }
	  } else {
	    # frame not resolved
	    my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	    my @possible_frames = 
	      grep { validate_frame($V,\@fv_trans_rules_N,$t_node,$_,$pj4,1,$flags) }
		@word_frames;
	    #$t_node->{rframeid} = join "|", map { $V->frame_id($_) } @possible_frames;
	    #$t_node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	    if (@possible_frames == 1 and
		@word_frames == 1) {
	      my @els = $V->all_elements($possible_frames[0]);
	      if (@els == 0) {
		print "10 unresloved frame, but word has only EMPTY frame, which matches: $fi\t";
		_assign_frames($t_node,@possible_frames) if $flags->{assign_10};
	      } else {
		print "11 unresloved frame, but word has only one frame, which matches: $fi\t";
		_assign_frames($t_node,@possible_frames) if $flags->{assign_11};
	      }
	    } elsif (@possible_frames==1) {
	      if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
		print "12a no frame assigned, one of two frames matches, the other is EMPTY: $fi\t";
	      } elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
		print "12b no frame assigned, one frame matches, the other have no actants: $fi\t";
	      } else {
		print "12 no frame assigned, one frame matches, but other frames with actants exist: $fi\t";
	      }
	      _assign_frames($t_node,@possible_frames) if $flags->{assign_12};
	    } elsif (@possible_frames>1) {
	      print "13 unresloved frame, but more matching frames: $fi\t";
	    } elsif (@word_frames==0) {
	      print "21 no frames: $fi\t";
	    } else {
	      print "14 unresloved frame, but no matching frame: $fi\t";
	    }
	    Position($t_node);
	    return 0;
	  }
	} else {
	  print "02 frame not found: $fi\t";
	  if ($flags->{delete_not_found}) {
	    delete $t_node->{'val_frame.rf'};
	    print "FIX: DELETED\n";
	    ChangingFile(1);
	  }
	  Position($t_node);
	  return 0;
	}
      }
      if (@frames) {
	#$t_node->{$frameid}=join "|",map { $V->frame_id($_) } @frames;
	#$t_node->{rframere} = join " | ", map { $V->serialize_frame($_) } @frames;
	foreach my $frame (@frames) {
	  return 0 unless validate_frame($V,\@fv_trans_rules_N,$t_node,$frame,$pj4,0,$flags);
	}
	# process frames
      } else {
	print "03 no valid frame for: ".join('|',map {my $id=$_; $id=~s/^.*?#//; $id } AltV($t_node->{'val_frame.rf'}))." \t";
	Position($t_node);
	return 0;
      }
    } else {
      if ($V->user_cache->{$lemma}) {
	my @word_frames = $V->valid_frames($V->user_cache->{$lemma});
	my @possible_frames = 
	  grep { validate_frame($V,\@fv_trans_rules_N,$t_node,$_,$pj4,1,$flags) }
	    @word_frames;
	#$t_node->{$frameid} = join "|", map { $V->frame_id($_) } @possible_frames;
	#$t_node->{rframere} = join " | ", map { $V->serialize_frame($_) } @possible_frames;
	if (@possible_frames == 1 and
	    @word_frames == 1) {
	  my @els = $V->all_elements($possible_frames[0]);
	  if (@els == 0) {
	    print "16 no frame assigned, but word has only EMPTY frame, which matches:\t";
	    _assign_frames($t_node,@possible_frames) if $flags->{assign_16};
	  } else {
	    print "17 no frame assigned, but word has only one frame, which matches:\t";
	    _assign_frames($t_node,@possible_frames) if $flags->{assign_17};
	  }
	} elsif (@possible_frames==1) {
	  if (1 == grep { $V->getFrameElementString($_)!~/EMPTY/ } @word_frames) {
	    print "18a no frame assigned, one of two frames matches, the other is EMPTY:\t";
	  } elsif (0 == grep { $V->getFrameElementString($_)!~/^(ACT|PAT|ADDR|EFF)$/ } grep { $_!=$possible_frames[0] } @word_frames) {
	    print "18b no frame assigned, one frame matches, the other have no actants:\t";
	  } else {
	    print "18 no frame assigned, one frame matches, but other frames with actants exist:\t";
	  }
	  _assign_frames($t_node,@possible_frames) if $flags->{assign_18};
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
      Position($t_node);
      return 0;
    }
  } else {
    # report problem only if this instance has DPHR, CPHR or actant
    if (grep { get_func($_) =~ /^[CD]PHR$|^$match_actants$/ } PML_T::GetEChildren($t_node)) {
      print "05 lemma not in vallex: $lemma ($pos)\t";
      Position($t_node);
    }
    return 0;
  }
  return 1;
}
}
