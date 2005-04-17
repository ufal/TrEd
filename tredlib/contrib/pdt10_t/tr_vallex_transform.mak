# -*- cperl -*-

#encoding iso-8859-2

package TRValLexTransform;
use base qw(TredMacro);
import TredMacro;

# Terminology: valency lexicon consists of headwords (which have their POS) and
# their framesets. Each frameset consists of one or more frames. Each frames
# consists of one or more slots, which are either obligatory or facultative
# (i. e. optional). Each slot consists of (tectogrammatical) functor (func) and
# zero or more morphemic realizations (MR).

# Valency lexicon is loaded into the variable $vallex, which has the following
# structure:
# % key is (headword, POS)-pair, value is frameset:
#   @ values are frames:
#     @ 2 values: 0 -- obligatory slots, 1 -- facultative slots:
#       @ values are slots:
#         $ 1st is func, the remaining are morphemic realizations

# MR is of any of the following shape:
# - case expressed with a number; can be prepended a preposition with '+' to it
# - subordinating preposition (for subordinated clause)
# - 'vv' for subordinated clause without a preposition
# - 'Inf' for an infinitive form of a verb

# Handling coordinations and apositions: Not all the nodes depending on a node
# are its modifications and vice versa. When a node is a part of a 
# coordination, we have to consider nodes depending on the coordinating node 
# (but only those which are not part of a coordination) as its modifications. 
# And this have to be done recursively. On the other side, when a coordination 
# depends on a node, nodes depending on the coordinating node have to be 
# considered as the modifications of this node -- recursively, again. The same 
# with apositions.
# When determining morphemic realizations of the modifications of a node, the 
# coordination depending on this node has to be considered as one node, but its
# morphemic realization is determined as the unification of those of the parts 
# of the coordination. When assigning the determined functors, these 
# coordinations have to be "decomposed" again.


###############################################################################
# SetAttrsNewNode
#
# Sets attributes of a newly generated node. Sets del, trlemma, gender and
# number.
# When the verb is finite and either the new node is 'ACT' and the verb is
# active or the new node is 'PAT' and the verb is passive, "on" ("he") is
# set as trlemma; otherwise "&Gen;" (general member) (exception described in
# the next sentence).
# When the verb is infinitive, has func other than 'ACT' and the new node is
# 'ACT', its trlemma is "&Cor;" (correference).
# Gender and number are set only when trlemma is "on" ("he"). The default gender
# is animatum and the default number is singular.

sub SetAttrsNewNode($)
{
	my ($node) = @_;
	my %genders = ("M" => "ANIM", "I" => "INAN", "F" => "FEM", "N" => "NEUT");
	my %numbers = ("S" => "SG", "P" => "PL");
	my $par = $node->parent;
	$node->{'del'} = 'ELID';

	# handling trlemma of DIRs and LOC
	if ($node->{'func'} =~ /^(DIR.)|(LOC)$/) {
		$node->{'trlemma'} = $node->{'func'} eq 'DIR3'? 'tady' : 'tam';
		return;
	}

	$node->{'trlemma'} = ($par->{'x_finit'} &&
		(($node->{'func'} eq 'ACT' && $par->{'x_voice'} eq 'ACT')
		|| ($node->{'func'} eq 'PAT' && $par->{'x_voice'} eq 'PAS'))) ?
		"on" : "&Gen;";
	if (!defined $par->{'x_finit'} && $par->{'tag'} =~ /^Vf/
		 && $par->{'func'} ne 'ACT' && $node->{'func'} eq 'ACT') { $node->{'trlemma'} = "&Cor;"; }
	if ($node->{'trlemma'} eq "on") {
		my $number = substr($par->{'x_finit'}, 0, 1);
		my $gender = substr($par->{'x_finit'}, 1, 1);
		my $person = substr($par->{'x_finit'}, 2, 1);
		if ($person eq '1') {
			if ($number eq 'S') { $node->{'trlemma'} = 'já'; }
			if ($number eq 'P') { $node->{'trlemma'} = 'my'; }
		}
		if ($person eq '2') {
			if ($number eq 'S') { $node->{'trlemma'} = 'ty'; }
			if ($number eq 'P') { $node->{'trlemma'} = 'vy'; }
		}
		$node->{'number'} = defined $numbers{$number}? $numbers{$number} : "SG";
		$node->{'gender'} = defined $genders{$gender}? $genders{$gender} : "ANIM";
	}
}


###############################################################################

sub Num ($) {
	my ($node) = @_;
	my $res = substr($node->{'tag'}, 3, 1);
	$res eq 'D' and $res = 'P';
	$res eq 'W' and $res = 'X';
	return $res;
}


sub Gen ($) {
	my ($node) = @_;
	my $res = substr($node->{'tag'}, 2, 1);
	if ($res =~ /[HQTZ]/) { $res = 'X'; }
	return $res;
}

sub Per ($) {
	my ($node) = @_;
	my $res = substr($node->{'tag'}, 7, 1);
	if ($res !~ /[123]/) { $res = 'X'; }
	return $res;
}


sub Verb_Modality ($) {
	my ($node) = @_;
	my $node_t = substr($node->{'tag'}, 0, 2);

	my @auxvs = grep { $_->{'afun'} eq 'AuxV' } $node->children;
	my @budu = grep { $_->{'tag'} =~ /^VB/ && $_->{'form'} =~ /^b/ } @auxvs; # dirty trick -- just for 'budu', 'bude' etc.
	my @jsem = grep { $_->{'tag'} =~ /^VB/ && $_->{'form'} =~ /^j/ } @auxvs; # dirty trick -- just for 'jsem', 'je' etc.
	my @byl  = grep { $_->{'tag'} =~ /^Vp/ } @auxvs;
	my @bych = grep { $_->{'tag'} =~ /^Vc/ } @auxvs;
	my @refl_se = grep { $_->{'afun'} eq 'AuxR' } $node->children;

	# imperative
	if ($node_t eq 'Vi') {
		$node->{'x_finit'} = undef;
	}

	# simple present (or future) form
	elsif ($node_t eq 'VB') {
		$node->{'x_finit'} = Num($node).Gen($node).Per($node);
		$node->{'x_voice'} = 'ACT';
	}

	# infinitive
	elsif ($node_t eq 'Vf') {
		# compound future tense
		if (@budu) {
			$node->{'x_finit'} = Num($budu[0]).Gen($budu[0]).Per($budu[0]);
			$node->{'x_voice'} = 'ACT';
		}
		# real infinitive
		else {
			$node->{'x_finit'} = undef;
			# handling modal verbs
			my @modals = grep { $_->{'afun'} =~ /^Pred/ } $node->children;
			if (@modals) {
				&Verb_Modality($modals[0]);
				$node->{'x_finit'} = $modals[0]->{'x_finit'};
				$node->{'x_voice'} = $modals[0]->{'x_voice'};
			}
		}
	}

	# past participle
	elsif ($node_t eq 'Vp') {
		# conditional
		if (@bych) {
			$node->{'x_finit'} = Num($bych[0]).Gen($node).Per($node);
			$node->{'x_voice'} = 'ACT';
		}
		# compound past tense -- it don't need to be compound in 3rd person
		else {
			# in 3rd person there is no AuxV, so distinguishing according to the verb
			# -- even it need not to be unique (e.g. "delala")
			$node->{'x_finit'} = Num(@jsem? $jsem[0]:$node).Gen($node).(@jsem? Per($jsem[0]):'3');
			$node->{'x_voice'} = 'ACT';
		}
	}

	# passive participle
	elsif ($node_t eq 'Vs') {
		$node->{'x_voice'} = 'PAS';
		# passive conditional
		if (@bych) {
			# assert @byl > 0
			$node->{'x_finit'} = Num( Num($bych[0]) eq 'X'? $byl[0]:$bych[0] ).Gen($byl[0]).Per($bych[0]);
		}
		# passive indicative
		else {
			# future passive indicative
			if (@budu) {
				$node->{'x_finit'} = Num($budu[0]).Gen($budu[0]).Per($budu[0]);
			}
			# past passive indicative
			elsif (@byl) {
				# in 3rd person there is no AuxV, so distinguishing according to the verb
				# -- even it need not to be unique (e.g. "delala")
				$node->{'x_finit'} = Num(@jsem? $jsem[0]:$node).Gen($node).(@jsem? Per($jsem[0]):'3');
			}
			# present passive indicative
			else {
				# assert @jsem
				$node->{'x_finit'} = Num($jsem[0]).Gen($jsem[0]).Per($jsem[0]);
			}
		}
	}

	# reflexive 'se' -> passive voice
	if (@refl_se) { $node->{'x_voice'} = 'PAS'; }
#	print "$node->{'form'}: FIN:$node->{'x_finit'} VOI:$node->{'x_voice'}\n";
}


###############################################################################
# Unify
#
# Tries to unify the given morphemic realizations (i.e. parts of MRs have to
# be the same or empty). It returns MR with the all the known information or
# undef when MRs are not unifiable.

sub Unify(@)
{
  my ($res1, $res2) = ("", "");
	while (defined (my $mr = shift @_))
  {
    my ($mr1, $mr2) = ($mr =~ /(.*)\+(.*)/)? ($1, $2) : ("", $mr);
		$res1 = $res1 || $mr1;
		$res2 = $res2 || $mr2;
		(!$mr1 || $mr1 eq $res1) && (!$mr2 || $mr2 eq $res2) or return undef;
	}
	return ($res1? "$res1+" : "") . $res2;
}


###############################################################################
# GetMR
#
# Determines and returns morphemic realization of the given node, i.e. 
# information which can be searched for in the valency lexicon.

sub GetMR($)
{
	my ($node) = @_;
	my $mr = "";
	
	#if ($node->{'afun'} =~ /^Sb/) { $mr = '1'; goto END; } #!
	# for coordination and aposition take values of the node's children
	if ($node->{'afun'} =~ /^(Coord|Apos)/)
	{
		my @child_mr = map { &GetMR($_) } grep { !IsHidden($_) && $_->{'afun'} =~ /_(Co|Ap)$/ } $node->children;
		# unify realizations of children
		$mr = &Unify(@child_mr);
		defined $mr or print "| Cannot unify MRs: ".(join ", ", @child_mr)." | ";
		defined $mr or $mr = "";
		# there is a fw by the coordination/aposition
		if ($node->{'fw'}) {
			# if the realization matches with ^[1-7]$, it is a noun and thus fw is a 
			# preposition => prepend it with '+'; otherwise it is a verb and fw is a 
			# conjunction => replace the realization with it
			$mr = ($mr =~ /^[1-7]$/? $node->{'fw'}."+".$mr : $node->{'fw'});
		}	
	}

	# handling nouns
	elsif ($node->{'tag'} =~ /^[CNPA]/)
	{
		my @numbers = grep { $_->{'tag'} =~ /^C/ } $node->children;
		# if a noun has no preposition and has a numeral as its child, take the MR 
		# of this child as its realization (e.g. "pro desítky lidí")
		if (@numbers && !defined $node->{'fw'}) { $mr = GetMR($numbers[0]); }
		# if it has a preposition, don't check for children (e.g. "po 20 kopiích")
		else {
			if (defined $node->{'fw'}) { $mr = $node->{'fw'}.'+'; }
			my $case = substr($node->{'tag'}, 4, 1);
			if ($case =~ /[1-7]/) { $mr .= $case; }
		}
	}

	# handling verbs
	elsif ($node->{'tag'} =~ /^V/)
	{
		if (defined $node->{'fw'}) { $mr = $node->{'fw'}; } # subord. conjunctions
		elsif ($node->{'tag'} =~ /^Vf/) { $mr = 'Inf'; }
		else { $mr = 'vv'; }
	}

END:	
	# trick: if subject and no realization assigned yet, return realization as if it is nominative
	if ($node->{'afun'} =~ /^Sb/ && $mr eq "") { $mr = '1'; }

	# trick: handling passivization
	if ($node->parent->{'x_voice'} eq 'PAS') {
		$mr eq '1' and $mr = '4';
		$mr eq '7' and $mr = '1';
	}
	
	return $mr;
}


###############################################################################
# MatchFrame
#
# Gets a frame and a the array of (realization, node)-pairs and matches them. 
# It returns the array of (func, node)-pairs, where the first member is func 
# from the given frame and the second one is the corresponding node, If the 
# func has not been found for the given node, the node in not returned.
#
# E.g. The pairs are ("1", node A), ("3", node B), ("4", node C), ("v+6", node D);
# the frame is "ACT(1) PAT(4) ADDR[3] MEANS[7]".
# The return array is: ("ACT", node A), ("PAT", node C), ("ADDR", node B).
#
# When there would be more than one inner participant in the output array,
# all the nodes with this participant assigned are ommited and the participant
# is added with 'undef' node. This is logically consistent (there *is* this
# participant, we only do not know which node it is assigned to), so that
# the consecutive comparison of frames is not broken, and this info is also
# needed to not creating node with this participant (when it is obligatory).

sub MatchFrame ($$)
{
	my ($frame, $rnps) = @_;

	# merge obligatory and facultative members of a frame
	my @fr = map { @$_ } @$frame;

	my %morph2func; # morphemic realization of a frame => the corresponding func
	my @res; # return array of pairs

	#!
#	my %deter = ();
#	for my $node (map { $_->[1] } @$rnps) {
#		if (defined $node->{'func'} && $node->{'func'} ne '???' && (!defined $node->{'afun'} || $node->{'afun'} !~ /^(Coord|Apos)/) && $deter{$node->{'func'}}->{'del'} ne 'ELID')
#		{
#			$deter{$node->{'func'}} = $node;
#		}
#	}

	# preprocess the frame -- fill %morph2func
	for my $slot (@fr)
	{
#		if (defined $deter{$slot->[0]}) { print "DETERMINED $slot->[0]\n"; next; } #!

		# if there are no MR required, use the "standard" ones
		for my $mr (scalar(grep { $_ } @$slot[1..@$slot-1])? grep { $_ } @$slot[1..@$slot-1] : @{$func2prep->{$slot->[0]}})
#		for my $mr (grep { $_ } @$slot[1..@$slot-1])
		{
			$morph2func{$mr} = $slot->[0];
		}
	}

	# determine pairs -- fill @res
	for $rnp (@$rnps)
	{
		push @res, [ $morph2func{ $rnp->[0] }, $rnp->[1] ] if defined $morph2func{ $rnp->[0] };
	}

	#!
#	for $det (keys %deter) 
#	{
#		push @res, [ $det, $deter{$det} ];
#	}

	#!
#	if (grep { defined $_->[1]->{'func'} && $_->[1]->{'func'} ne '???' && $_->[1]->{'afun'} !~ /^(Coord|Apos)/ && $_->[0] ne $_->[1]->{'func'} } @res) {
#		print "DELETING FRAME\n";
#		return ();
#	}

	# there cannot be more than one same inner participant 
	for $inner ('ACT', 'PAT', 'ADDR', 'EFF', 'ORIG')
	{
		if ((grep {$_->[0] eq $inner} @res) > 1)
		{
			# omit them if they is more than one node with it
			@res = grep {$_->[0] ne $inner } @res;
			# add the deleted func to the result
			push @res, [ $inner, undef ];
		}
	}

	return @res;
}	


###############################################################################
# GetNewOrd
#
# Find suitable (integer dot integer) ord for a new node.

sub GetNewOrd ($)
{
  my ($parent) = @_;
  my ($base, $suff) = (0, 0);

  $base = $1 if $parent && $parent->{'ord'} =~ /^([0-9]+)/;

  for (my $node = $root; $node; $node = $node->following)
	{
    if ($node->{'ord'} =~ /^$base\.([0-9]+)$/ && $1 > $suff)
		{
      $suff = $1;
    }
  }
  return "$base." . ($suff+1);
}


###############################################################################
# EvalFrame
#
# Returns the number denoting quality of match between a frame and a MR-set

my %ips = ('ACT' => 1, 'PAT' => 1, 'ADDR' => 1, 'EFF' => 1, 'ORIG' => 1);

sub EvalFrame (@)
{
	# return number of nodes with inner participants
	return scalar grep { $ips{ $_->[0] } } @_;
}


###############################################################################
# TransformNode
#
# Uses information from valency lexicon -- adds new nodes and and assigns funcs
# to old ones to tectogrammatical trees.

sub TransformNode ()
{
	my $default_V_frameset = [ [ [ [ 'ACT', '1' ] ] ] ]; # default frameset for verbs not found in lexicon

	###	prepare lemma and POS
	$lemma = $this->{'trlemma'};
	$lemma =~ s/_/ /;
#	$lemma ne 'být' or return; #!
	$pos   = substr($this->{'tag'}, 0, 1);
	$pos eq 'V' && $this->{'afun'} ne 'AuxV' or return;

	&Verb_Modality($this);

	print "[$root->{'form'}] $lemma,$pos: ";

	### determine modifications of the given node
	my @modifications = grep { !IsHidden($_) && $_->{'afun'} !~ /_Pa$/ && $_->{'trlemma'} ne '&Neg;'} $this->children; 
	for (my $node = $this; $node->{'afun'} =~ /_(Co|Ap)$/; $node = $node->parent)
	{
		push @modifications, grep { !IsHidden($_) && $_->{'afun'} !~ /_(Co|Ap)$/ } $node->parent->children;
	}

	### very dirty trick: in "ACT{}{&Gen;} ACT" change not-generated ACT to PAT
#	for (my @actors = grep { $_->{'func'} eq 'ACT'} @modifications)
#	{
#		if (my @elids = grep { $_->{'del'} eq 'ELID'} @actors)
#		{
#			for (@actors) { $_->{'func'} = 'PAT'; }
#			for (@elids) { $_->{'func'} = 'ACT'; }
#		}
#	}

	### determine morphemic realizations of @modifications
	my @mrs = (); # (morphemic realization, node)-pairs
	my @elids = (); # existing modifications elided on the surface (and added by AB)
	for my $mod (@modifications)
	{
		my $mr = &GetMR($mod);
		print "$mod->{'func'}\{$mr\}\{$mod->{'trlemma'}\} ";
		push @mrs, [$mr, $mod];
		if ($mod->{'del'} eq 'ELID') { push @elids, $mod; }
	}
	print "\n";
	undef @modifications;

	### find frameset of the given word
	my @frameset; # frameset of the given word
	# word found in the lexicon
	if (defined $vallex->{$lemma, $pos})
	{
		@frameset = @{ $vallex->{$lemma, $pos} };
	}
	# trick: word not found in the lexicon -- assign it the default frameset
	else {
		print "  | Not found in lexicon |\n";
		if ($pos eq 'V') { @frameset = @$default_V_frameset; }
	}

	### match frames with MRs and find the best evaluation
	my $best = 0; # maximal number of slots of a frame matching with MRs
	my @matches = (); # array of arrays returned by MatchFrame for every frame
	for my $frame (@frameset)
	{
		my @match = &MatchFrame($frame, \@mrs);
		print "  <".&EvalFrame(@match)."> ",
			(map { $_->[0]."(".join(",",@{$_}[1..$#$_]).") " } grep defined, @{$frame->[0]}),
			(map { $_->[0]."[".join(",",@{$_}[1..$#$_])."] " } grep defined, @{$frame->[1]}),"\n";
 		$best = $best < &EvalFrame(@match)? &EvalFrame(@match) : $best;
		push @matches, \@match;
	}
	undef @mrs;

	print "  best eval: $best, # of frames: ", scalar(@frameset);

	### delete all the non-best frames
	my $number = @frameset;
	for (my $i=0; $i < $number; $i++)
	{
		my $frame = shift @frameset;
		my $match = shift @matches;
		if (&EvalFrame(@$match) == $best)
		{
			push @frameset, $frame;
			push @matches, $match;
		}
	}
	undef $number;
	undef $best;

	print " # of best frames: ".scalar(@matches)."\n";

	### find intersection of obligatory slots of frames (these had to be on the surface)
	my %ob; # func => the number of the (best) frames which this func occurs in
	# determine number of occurences of each func
	for my $frame (@frameset)
	{
		# only for obligatory slots
		for my $oblig (@{ $frame->[0] })
		{
			my $temp = \$ob{$$oblig[0]};
			defined $$temp or $$temp = 0;
			$$temp++;
		}
	}
	# retain just these funcs which occur in all the frames
	for $func (keys %ob)
	{
		$ob{$func} == @frameset or delete $ob{$func};
	}
	undef @frameset;

	### compose resultant func-node assignment from @matches
	# because of endless stupidity of Perl references cannot be keys of hashes
	my @nodes = (); # ordered nodes
	my %order2func; # indexes of nodes => corresponding funcs
	my %multi = (); # multiple inner participants from the frames (keys)
	for my $match (@matches)
	{
		FNP: for my $fnp (@$match)
		{
			# multiple inner participant -- add them to %multi
			unless (defined $fnp->[1]) 
			{
				$multi{ $fnp->[0] } = 1;
				next;
			}
			# get index of the node; add it if missing
			my $i = 0;
			while ($i<@nodes && $nodes[$i] != $fnp->[1]) { $i++; }
			if ($i == @nodes) { $nodes[$i] = $fnp->[1]; }
			$temp = \$order2func{$i};
			# when two best frames determine the func belonging to a realization
			# differently, none is assigned
			# e.g. verb "pripravit" -- "prepare"/"steal, dispel":
			# in meaning "prepare" it has frame "ACT(1) PAT(4)",
			# in meaning "steal, dispel" it has frame "ACT(1) ADDR(4) PAT(o+4)"
			# when realization is "4", conflict (PAT/ADDR) occurs a no func is assigned
			$$temp = $fnp->[0] unless defined $$temp;
			if ($$temp ne $fnp->[0])
			{
#				#!
#				if ($fnp->[1]->{'func'} eq $$temp) {
#					print STDERR "+";
#					next FNP;
#				}
#				elsif ($fnp->[1]->{'func'} eq $fnp->[0]) {
#					print STDERR "+";
#					$$temp = $fnp->[0];
#					next FNP;
#				}
				#!
#				else {
					$$temp .= '!' unless $$temp =~ /!$/;  # unreliable, guessed
					next FNP;
#				}
#				$$temp = '###'; # '###' means conflicting functors
#				print STDERR "-";
#				delete $ob{$$temp};
#				delete $ob{$fnp->[0]};
			}
		}
	}
	undef @matches;

	### assign funcs to nodes
	for my $order (keys %order2func)
	{
		my $func = $order2func{$order};
		my $node = $nodes[$order];
		my $unreliable = 0;
		if ($func =~ /^(.*)!$/)
		{
			$func = $1;
			$unreliable = 1;
		}
		$func ne '###' or next;
		# func cannot be assigned multiply
		!defined $multi{$func} or next;
		# determine modifications of the node (not equal to children for
		# coordinations and apositions)
		my @modifications = ();
		my @children = ($node);
		while (my $child = shift @children) {
			if ($child->{'afun'} =~ /^(Coord|Apos)/)
			{ 
				push @children, grep { !IsHidden($_) && $_->{'afun'} =~ /_(Co|Ap)$/ } $child->children;
			} 
			else { push @modifications, $child; }
		}
		# assign func and delete it from %ob (it has been assigned already)
		for my $mod (@modifications)
		{
			@elids = grep { $_ ne $mod } @elids;
			if (defined $mod->{'func'} && $mod->{'func'} ne '???')
			{ 
				$mod->{'func'} eq $func or print "  --- repairing $mod->{'func'} to $func {".&GetMR($mod)."}\n";
			}
			else { print "  --- assigning $func {".&GetMR($mod)."}\n"; }
			$mod->{'func'} = $func; #  if !defined $mod->{'func'} || $mod->{'func'} eq '???'; #!
			$mod->{'funcaux'} = $unreliable? "#{custom6}" : "#{custom5}";
			delete $ob{ $func };
		}
	}

	for (my $el_cnt = @elids, my $i = 0; $i < $el_cnt; $i++)
	{
		$el = shift @elids;
		my $cnt_bef = keys %ob;
		map { delete $ob{$_} } grep { $_ eq $el->{'func'} } keys %ob;
		my $cnt_aft = keys %ob;
		push @elids, $el if $cnt_bef == $cnt_aft;
	}

	### create new nodes for funcs remaining in %ob
	foreach $func (keys %ob)
	{
		# multiply assigned func *is* already there (we just don't know which node it is assigned to)
		!defined $multi{$func} or next;
		my $new = shift @elids;
		if (defined $new) {
			print "  --- repairing $new->{'func'} to $func {elided node}\n";
		}
		else {
			print "  === adding node $func\n";
			$new = NewSon($this);
			$new->{'ord'} = GetNewOrd($this);
		}
		$new->{'func'} = $func;
		$new->{'funcaux'} = "#{custom5}";
		SetAttrsNewNode($new);
	}

	if (keys %multi) { print "  multiple: ", (join ", ", keys %multi), "\n"; }
}


###############################################################################
# TransformTree
#
# Calls TransformNode for all visible nodes.

sub TransformTree ()
{
	while ($this)
	{
		TransformNode();
		$this = $this->following_visible($grp->{FSFile}->FS);
	}
}


###############################################################################
# Transform
#
# Main procedure.
# Gets parametres, loads vallex, calls TransformTree() for each tree.
#
# Command line arguments: 
#   src -- source ('src' attribute) of MDl and MDt tags
#   vallex -- file with a valency lexicon

sub Transform ()
{
	use Getopt::Long;

	GetOptions('src=s', \$MD__src, 'vallex=s', \$VallexFileName, 'prep=s', \$PrepFileName);
	#$MD__src='a';
	do $VallexFileName;
	do $PrepFileName;
	do 
	{
		if (defined $MD__src)
		{
			PDT->SaveAttributes("save_", [qw(lemma tag)]);
			PDT->MD2TagLemma($MD__src);
		}
		TransformTree();
		if (defined $MD__src)
		{
			PDT->RestoreSavedAttributes("save_", [qw(lemma tag)]);
		}
	} while (NextTree());
}

###############################################################################
# DoTransformTree
#
# Main procedure for one tree.
# saves lemma and tag and calls TransformTree()
#

sub DoTransformTree {
  my ($MD__src)=@_;
  if (defined $MD__src) {
    PDT->SaveAttributes("save_", [qw(lemma tag)]);
    PDT->MD2TagLemma($MD__src);
  }
  TransformTree();
  if (defined $MD__src) {
    PDT->RestoreSavedAttributes("save_", [qw(lemma tag)]);
  }
}

