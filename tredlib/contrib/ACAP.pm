
# -*- perl -*-
# This script is an attempt to automatically find possible coreferents
# in TGTS structures for Czech.
# contributed to TrEd by Oliver Culo in 12/2003


#### Package declarations: ###############################################

package ACAP;


#### Variables ############################################################

# we build up the data structures, that represent the Gender and
# number hierarchies:
my %Case = 
  { X => 'Y|Z|H|M|I|N|F',
    Y => 'M|I', Z => 'M|I|N', T => 'I|F', H => 'N|F' }; 
# wie sieht's mit den Basistypen aus? Sieht man spaeter...

my %Number = 
  { X => 'P|S' };
# ebenfalls Basistypen: ???

# with translation, we cover special cases, e.g. Q constrains
# to 'QP', so it has to be plural:
my %GenderTranslation = 
  { Q => 'QP', T => 'TP' };
my %NumberTranslation =
  { W => 'FS|NP', D => 'XP' };

# verbs with antecedent PAT (for automatic coreference assingment)
my $InfLemmataPAT =
    'cítit|dát|dávat|lákat|nechat|nechávat|nutit|ponechat|ponechávat|poslat|'.
    'posílat|sly¹et|slıchávat|spatøit|uvidìt|vidìt|vídávat|vyslat|vysílat';


# verbs with antecedent ADDR (for automatic coreference assingment)
my $InfLemmataADDR =
    'bránit|donutit|donucovat|doporuèit|doporuèovat|dovolit|dovolovat|zaøídit|'.
    'za¾izovat|nauèit|pomoci|pomáhat|povolit|povolovat|pøimìt|uèit|umo¾nit|'.
    'umo¾òovat|zabránít|zabraòovat|zakázat|zakazovat';

my %Coref;

#### Main ##################################################################

sub autoAssignCorefs ($) {
    my $node = shift;
    %Coref = undef;

    # rule for reflexives:
    &ReflexiveAndEmpCompRule($node,'Reflexive') 
	if ($node->{trlemma} =~ /^(se|svùj)$/ &&
	    $node->{func} !~ /^(DPHR|ETHD)/);
    # first, use the ReflexiveAndEmpCompRule, as it
    # is a special case for &Cor; occurences. &Cor;
    # in general is dealt with at a later point:
#    &ReflexiveAndEmpCompRule($node,'EmptyCOMP')
#	    if ($node->{trlemma} =~ /^\&Cor/ && 
#		$node->parent->{trlemma} eq '&Emp;' &&
#		$node->parent->{func} eq 'COMPL') ;
    # use infinitive Coref rule if we have an infinitive
    # construction with an &Cor; or a construction of
    # coordinated infinitives with &Cor; at the same level:
#    &ControlRule($node) if ($node->{trlemma} =~ /^\&Cor/ and
#	    ($node->parent->{tag} =~ /^V[fs]/ or
#	     ($node->parent->{func} =~ /^(?:APOS|CONJ|DISJ)$/ and
#	      grep { $_->{tag}=~/^V[fs]/ and
#			 $_->{memberof}=~/^(CO|AP)$/ } $node->parent->children)));
    # sentential rule for coz:
#    &SententialRule($node) 
#	if ($node->{trlemma} =~ /^co¾$/ );
    # COMPL that are participles:
#    &ParticipleComplementRule($node) 
#	if ($node->{func} eq 'COMPL' && $node->{tag} =~ /^V[ems]/); 
    # for COMPL that are adjectives, numerals or nouns:
#    &NonVerbalComplementRule($node)
#	if ($node->{func} eq 'COMPL' && $node->{tag} !~ /^V/);
#    &VerbalComplementRule($node) 
#	if ($node->{func} eq 'COMPL' && $node->{tag} =~ /^V/);
    # relative clause rule for the trlemmata ketry and jenz and jak:
    &RelativeClauseRule($node) 
	if ($node->{trlemma} =~ /^(kterı|jen¾|jak)$/);

    # we return auto.'type', as we want to distinguish
    # these arrows frow the manually annotated ones:
    if ($Coref{ID}) {return ($Coref{ID},'auto'.$Coref{type})}
    else {return undef}

}


#### SUBs and HOOks ##################################################################

########################
### Annotation SUBs: ###
########################

# automatically assign coreference to constructions with infinitive
sub ControlRule ($) {
    my $node = shift;

    my $p=$node->parent->parent;
 
    $p=$p->parent while ($p and $p->{tag} !~ /^(?:V|AG)/);
    if ($p) {
	#print "P2: $p->{trlemma},$p->{func}\n";
	my $cor;
	if ($p->{tag} =~ /^AG/) {
	    $cor=$p->parent;
	    $cor=$cor->parent while ($cor and $cor->{func} =~ /^(?:APOS|CONJ|DISJ)$/);
	    $cor=undef unless ($cor->{tag}=~/^[ANCP]/);
	    $Coref{lastRule} = 'Control';
	} elsif ($p->{trlemma} =~ /^(?:$InfLemmataPAT)$/) {
	    $cor=&GetEffectiveDaughter($p,'func','PAT');
	    $Coref{lastRule} = 'ControlPAT';
	} elsif ($p->{trlemma} =~ /^(?:$InfLemmataADDR)$/) {
	    $cor=&GetEffectiveDaughter($p,'func','ADDR');
	    $Coref{lastRule} = 'ControlADDR';
	} else {
	    $cor=&GetEffectiveDaughter($p,'func','ACT');
	    $Coref{lastRule} = 'ControlACT';
	}
	if ($cor and $cor != $node->parent) {
	    $cor = $cor->parent if ($cor->{memberof} =~ /^(CO|AP)/);
	    $Coref{ID} = &GetID($cor);
	    $Coref{type} = 'grammatical';
	} 
    }
}


### SUB
# automatically assign relative clause coreference
sub RelativeClauseRule ($) {
  my $node = shift;
  my $climb;

  # this rule goes as follows: find the first RSTS above the 
  # relative clause node, and then the first noun above that
  # RSTR; this should be the coreferent
  $climb = $node->parent;
  $climb = $climb->parent while ($climb && ($climb->{func} ne 'RSTR' || $climb->{func} =~ /^(CONJ|DISJ)$/));
  $climb = $climb->parent while ($climb && $climb->{tag} !~ /^[NP]/);

  if ($climb) {
      $Coref{ID} = &GetID($climb);
      $Coref{type} = 'grammatical';
  }

}


### SUB
sub SententialRule ($) {
    my $node = shift;
    my ($climb,$lb);

    # if coz is firstson of the main verb (except
    # a PREC or RHEM to its left), the coref is the previous sentence:
    if (!$node->lbrother ||
	$node->lbrother->{func} =~ /(RHEM|PREC)/) {
	$Coref{ID} = &GetID($LastSentTop);
	$Coref{type} = 'grammatical';
	return;
    }

    # if we are in a coordination, coz will relate to the
    # previous sentence, if it is on the left hand side:
    $climb = $node->parent; # up one level...
    if ($climb) {$climb = $climb->lbrother} # ...then get the left brother:
    if ($climb && $climb->{func} eq 'CONFR') {
	$climb = $climb->firstson;
	$climb = $climb->rbrother while ($climb->rbrother);
    }
    
    if ($climb) {
	$Coref{ID} = &GetID($climb);
	$Coref{type} = 'grammatical';
    }

}


### SUB
sub ReflexiveAndEmpCompRule ($$) {
    my ($node,$rule) = @_;
    my ($climb,$daughter);

    # set lastRule for later Evaluation:
    $Coref{lastRule} = $rule;

    # climb up to the first node that has an ACT as child
    # which is not 'se'
    $climb = $node->parent;
    while ($climb) {
	# we get the "effective daughter":
	$daughter = &GetEffectiveDaughter($climb,'func','ACT');
	# if this daughter is part of a coordination, we
	# choose its parent node as we want to refer to all
	# nodes below:
	if ($daughter && $daughter->{memberof} =~ /CO/) {$daughter = $daughter->parent}
	last if ($daughter && $daughter->{trlemma} ne 'se');
	$climb = $climb->parent;
    }
    if ($daughter && $climb) {
	$Coref{ID} = &GetID($daughter);
	$Coref{type} = 'grammatical';
    }
    
}    

### SUB 
sub ParticipleComplementRule ($) {
    my $node = shift;
    my ($climb,$cor);

    $climb = $node;
    # climb until the first verb above the complement:
    $climb = $climb->parent while ($climb && ($climb->{memberof} =~ /(CO|AP)/
				   || $climb->{tag} !~ /^V/));
    # now search for an actor:
    $cor = &GetEffectiveDaughter($climb,'func','ACT');

    if ($cor) {
	$Coref{ID} = &GetID($cor);
	$Coref{type} = 'grammatical';
    }

}

### SUB 
sub NonVerbalComplementRule ($) {
    my $node = shift;
    my ($climb,@children,$anaCase,$a,$cor);

    $climb = $node;
    # extract the case value from the positional tag:
    ($a,$a,$a,$a,$anaCase) = split("|",$node->{tag});
    # climb until the first verb above the complement:
    $climb = $climb->parent while ($climb->parent && ($climb->{memberof} =~ /(CO|AP)/
				   || $climb->{tag} !~ /^V/));
    # get these verb's children:
    @children = $climb->children;
    # now search for a noun in the same case:
    foreach my $child (@children) {
	# extract the child's case:
	my ($a,$a,$a,$a,$cCase) = split("|",$child->{tag}); 
	if ($anaCase eq $cCase &&
	    $child->{tag} =~ /^[NP]/) {
	    $cor = $child;
	    last;
	}
    }

    if ($cor) {
	$Coref{ID} = &GetID($cor);
	$Coref{type} = 'grammatical';
    }

}


### SUB
sub VerbalComplementRule () {
    my $node = shift;
    my $cor;

    # this rules works as follows: we check each node
    # whether it has jaky as its daughter, then we put up a link between that node
    # and the verb:
    foreach my $desc ($node->descendants) {
	if (grep {$_->{trlemma} eq 'jakı'} $desc->children) {
	    $cor = $desc;
	    last;
	}
    }

    if ($cor) {
	$Coref{ID} = &GetID($cor);
	$Coref{type} = 'grammatical';
    }
}


####################
### Helper SUBs: ###
####################

### SUB
### return AID or TID of a node (whichever is available)
sub GetID {
  my $node = shift;
  return ($node->{TID} ne "") ? $node->{TID} : $node->{AID};
}

### SUB
### get daughter with specified feature-value-pair
sub GetEffectiveDaughter ($$$) {
    my ($node,$feat,$val) = @_;

    foreach my $child ($node->children) {
	# jump over coordination:
	if ($child->{func} =~ /(CONJ|DISJ)/) {
	    $child = &GetEffectiveDaughter($child,$feat,$val);}
	return $child if ($child->{$feat} eq $val);
    }

    return undef;

}

1;

