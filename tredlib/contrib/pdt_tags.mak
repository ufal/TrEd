# -*- cperl -*-
#encoding iso-8859-2

sub describe_tag {
  my ($tag) = @_;
  my @sel;
  my @val = map {
    my $v = substr($tag,$_-1,1);
    "$v = ".$PDT_TAGINFO{$_.$v}[1]
  } 1..(length($tag));
  listQuery("Detailed tag info for $tag",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}

sub describe_x_origa {
  my ($tag) = @_;
  my @sel;
  my @val = map {
    if ($_ == 4) {
      substr($tag,4,2)." = pozice øídícího slova";
    } elsif ( $_ <= length($tag) ) {
      my $v = substr($tag,$_-1,1);
      "$v  = ".$ORIGA_INFO{$_.$v}
    } else { () }
  } 1,2,3,4,6;
  listQuery("Detailed info for $tag",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}

sub describe_x_origt {
  my ($tag) = @_;
  my @sel;
  my @val = map {
    if ( $_ <= length($tag) ) {
      my $v = substr($tag,$_-1,1);
      "$v  = ".$ORIGT_INFO{$_.$v}
    } else { () }
  } 1..length($tag);
  listQuery("Detailed info for $tag",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}


%ORIGA_INFO = map { my ($pos, $val, $type, $desc) = split /\t/,$_,4;
		    $val=$1 if ($val =~ /'(.)'/);
		     ($pos.$val => $desc) } split /\n/, <<'EOF';
1	1	NA	subjekt
2	' '	NA	x
3	'-'	NA	øídící slovo vlevo
4-5	o	NA	kolik slov vlevo/vpravo je slovo øídící (u druhého a dal¹ích se udává èíslo èlenu nejbli¾¹ího; stejnì se zachycují vztahy mezi èleny sdru¾eného pojmenování i v pøípadì, ¾e nejsou samost. syntaktickými èleny);vzdálenosti men¹í ne¾ deset se zapisují 01, 02, ..., 09
6	1	NA	koordinace (uvádí se pouze u druhého a dal¹ích èlenù koordinaèní øady)
1	2	NA	predikát
2	1	NA	slovesný
3	'+'	NA	øídící slovo vpravo
6	2	NA	sdru¾ené pojmenování determinaèní povahy
2	2	NA	spona
6	3	NA	koordinace uvnitø sdru¾eného pojmenování
2	3	NA	nom. èást spon. pred.
6	4	NA	sdru¾ené pojmenování jiné
2	4	NA	nomin.
6	5	NA	sdru¾ené pojmenování v koordinaci s jiným sdru¾eným pojmenováním
2	5	NA	spona u jednoèl. v.
6	6	NA	dvojice spojkové a pøísloveèné
1	3	NA	...
2	1	NA	atribut
6	9	NA	øídící výraz elidován
2	2	NA	apozice
6	0	NA	øídící výraz vyøazen
1	4	NA	...
2	1	NA	objekt
6	7	NA	???
2	2	NA	doplnìk
6	8	NA	???
1	5	NA	adverbiále
2	1	NA	místa
2	2	NA	èasu
2	3	NA	zpùsobu
2	4	NA	pøíèiny
2	5	NA	pùvodu
2	6	NA	pùvodce
2	7	NA	výsledku
1	6	NA	základ vìty jednoèlenné
2	1	NA	substantivní
2	2	NA	adjektivní
2	3	NA	citosloveèné
2	4	NA	èásticové
2	5	NA	vokativní
2	6	NA	pøísloveèené
2	7	NA	infinitivní
2	8	NA	slovesné
2	9	NA	slovesnì jmenné
2	0	NA	zájmenné
1	7	NA	pøech. typ (s v¹eobecným subjektem)
1	8	NA	samostatný vìtný èlen
1	9	NA	parantéze
EOF

%ORIGT_INFO = map { my ($pos, $val, $type, $desc) = split /\t/,$_,4;
		    $val=$1 if ($val =~ /'(.)'/);
		     ($pos.$val => $desc) } split /\n/, <<'EOF';
1	1	slovní druh	SUBSTANTIVUM
2	1	NA	nesporné
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	8	NA	neskl.
8	4	spisovnost	zastaralé
2	2	NA	adj.
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	3	NA	zvrat.
8	5	spisovnost	nespis.
2	3	NA	zájm.
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
8	6	spisovnost	výplòk. nespis.
2	4	NA	èísl.
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
8	7	spisovnost	výplòk.
2	5	NA	slov.
4	9	rod	nelze urèit
5	9	èíslo	nelze urèit
6	5	pád	vokativ
2	6	NA	slov. zvr.
6	6	pád	lokál
2	7	NA	zkratka
6	7	pád	instrumentál
2	9	NA	zkr. slovo
6	9	pád	nelze urèit
2	0	NA	vl. jméno
1	2	slovní druh	ADJEKTIVUM
2	2	NA	nesporné
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
8	4	spisovnost	zastaralé
3	1	NA	jm. tvar
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
8	5	spisovnost	nespis.
3	2	NA	jm. zvrat.
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
7	2	stupeò	II.st.
8	6	spisovnost	výplòk. nespis.
2	3	NA	zájmenné
3	1	NA	jm. tvar
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
7	3	stupeò	III.st
8	7	spisovnost	výplòk.
3	2	NA	neurèité
4	9	rod	nelze urèit
5	9	èíslo	nelze urèit
6	5	pád	vokativ
7	8	stupeò	neskl.
3	4	NA	ukazovací
6	6	pád	lokál
3	5	NA	tázací
6	7	pád	instrumentál
3	6	NA	vzta¾né
6	9	pád	nelze urèit
3	7	NA	záporné
3	8	NA	pøivl.
2	4	NA	èíslovka
3	2	NA	øadová
3	3	NA	druhová
3	4	NA	násobná
3	5	NA	neurèitá
2	5	NA	slovesné
3	0	NA	zvratné
3	1	NA	jmenné
3	2	NA	jm. zvrat.
2	7	NA	jmenné stø. rodu
2	9	NA	pøivlastòovací
1	3	slovní druh	ZÁJMENO
2	1	NA	osobní
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	1	tvar	krat¹í
8	4	spisovnost	zastaralé
2	2	NA	neurèité
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	2	tvar	del¹í
8	5	spisovnost	nespis.
2	3	NA	zvratné
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
8	6	spisovnost	výplòk. nespis.
2	4	NA	ukazovací
4	4	rod	neutrum
5	9	èíslo	nelze urèit
6	4	pád	akuzativ
8	7	spisovnost	výplòk.
2	5	NA	tázací
4	7	rod	bezrodé
6	5	pád	vokativ
2	6	NA	vzta¾né
4	9	rod	nelze urèit
6	6	pád	lokál
2	7	NA	záporné
6	7	pád	instrumentál
6	9	pád	nelze urèit
1	4	slovní druh	ÈÍSLOVKA
2	1	NA	základní
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	1	pád	nom.
8	4	spisovnost	zastaralé
2	(3)	NA	druhová
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	2	pád	gen.
8	5	spisovnost	nespis.
2	(4)	NA	násobná
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
7	3	pád	dat.
8	6	spisovnost	výplòk. nespis.
2	5	NA	neurèitá
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
7	4	pád	akz.
8	7	spisovnost	výplòk.
2	6	NA	podílná
4	7	rod	bezrodé
5	9	èíslo	nelze urèit
6	5	pád	vokativ
7	5	pád	vok.
4	8	rod	neskl.
6	6	pád	lokál
7	6	pád	lok.
4	9	rod	nelze urèit
6	7	pád	instrumentál
7	7	pád	ins.
6	9	pád	nelze urèit
7	9	pád	nelze urèit
1	5	slovní druh	SLOVESO
2	1	NA	dokonavé
3	1	osoba èíslo	1.sg.
4	1	èas zpùsob	ind.préz.akt.
5	1	imperativ	imp.akt.
6	1	NA	jednosl.
7	1	jmenný rod	m.¾iv.
8	4	spisovnost	zastaralé
2	2	NA	nedokonavé
3	2	osoba èíslo	2.sg.
4	2	èas zpùsob	ind.préz.pas.
5	2	imperativ	imp.pas.
6	2	NA	vícesl. nezvr.
7	2	jmenný rod	m.ne¾.
8	5	spisovnost	nespis.
2	3	NA	obojvidé
3	3	osoba èíslo	3.sg.
4	3	èas zpùsob	kond.préz.ak.
5	3	imperativ	kond.pf.akt.
6	7	NA	zvrat. neslo¾.
7	3	jmenný rod	fem.
8	6	spisovnost	výplòk. nespis.
3	4	osoba èíslo	1.pl.
4	4	èas zpùsob	kond.préz.ps.
5	4	imperativ	kond.pf.pas.
6	8	NA	zvrat. slo¾.
7	4	jmenný rod	neutr.
8	7	spisovnost	výplòk.
3	5	osoba èíslo	2.pl.
4	5	èas zpùsob	ind.prét.akt.
5	5	imperativ	p.sl. ``bývati''
6	9	NA	pf.stav.pøít.
7	5	jmenný rod	pl.m.¾.
3	6	osoba èíslo	3.pl.
4	6	èas zpùsob	ind.prét.pas.
5	6	imperativ	part.pas.
6	0	NA	pf.stav.min.
7	6	jmenný rod	pl.m.n.
3	7	osoba èíslo	inf.ak.
4	7	èas zpùsob	kond.min.akt.
5	7	imperativ	pøech.pø.akt.
7	7	jmenný rod	pl.fem.
3	8	osoba èíslo	inf.ps.
4	8	èas zpùsob	kond.min.pas.
5	8	imperativ	pøech.pø.ps.
7	8	jmenný rod	pl.neu.
3	9	osoba èíslo	neos.
4	9	èas zpùsob	fut.ind.akt.
5	9	imperativ	pøech.min.ak.
7	9	jmenný rod	nelze urèit
4	0	èas zpùsob	fut.ind.pas.
5	0	imperativ	pøech.min.ps.
1	6	slovní druh	ADVERBIUM
2	6	NA	nesporné
2	2	NA	predik.
4	2	stupeò	II. st.
8	4	spisovnost	zastaralé
2	3	NA	zájmenné
4	3	stupeò	III. st.
8	5	spisovnost	nespis.
2	4	NA	èíselné
3	4	NA	násobné
8	6	spisovnost	výplòk. nespis.
3	6	NA	podílné
8	7	spisovnost	výplòk.
3	5	NA	neurèité
2	8	NA	spojovací výraz
1	7	slovní druh	PØEDLO®KA
2	7	NA	vlastní
3	2	pád	s genitivem
8	4	spisovnost	zastaralé
2	8	NA	nevlastní
3	3	pád	s dativem
8	5	spisovnost	nespis.
3	4	pád	s akuzativem
3	6	pád	s lokálem
3	7	pád	s instrumentálem
1	8	slovní druh	SPOJKA
2	1	NA	souøadící
8	4	spisovnost	zastaralé
2	2	NA	podøadící
8	5	spisovnost	nespis.
2	9	NA	jiný výraz
1	9	slovní druh	CITOSLOVCE
2	9	NA	nesporné
8	4	spisovnost	zastaralé
2	1	NA	subst.
8	5	spisovnost	nespis.
2	2	NA	adj.
8	6	spisovnost	výplòk. nespis.
2	3	NA	zájm.
8	7	spisovnost	výplòk.
2	5	NA	slov.
2	6	NA	adv.
1	0	slovní druh	ÈÁSTICE
1	000	slovní druh	CITÁTOVÉ VÝRAZY
EOF


%PDT_TAGINFO = map { my ($pos, $val, $type, $desc) = split /\t/,$_,4; 
		     ($pos.$val => [$type,$desc]) } split /\n/, <<'EOF';
1	A	POS	Adjective
1	C	POS	Numeral
1	D	POS	Adverb
1	I	POS	Interjection
1	J	POS	Conjunction
1	N	POS	Noun
1	P	POS	Pronoun
1	V	POS	Verb
1	R	POS	Preposition
1	T	POS	Particle
1	X	POS	Unknown, Not Determined, Unclassifiable
1	Z	POS	Punctuation (also used for the Sentence Boundary token)
2	!	SUBPOS	Abbreviation used as an adverb (now obsolete)
2	#	SUBPOS	Sentence boundary (for the virtual word
2	*	SUBPOS	Word
2	,	SUBPOS	Conjunction subordinate (incl.
2	.	SUBPOS	Abbreviation used as an adjective (now obsolete)
2	0	SUBPOS	Preposition with attached
2	1	SUBPOS	Relative possessive pronoun
2	2	SUBPOS	Hyphen (always as a separate token)
2	3	SUBPOS	Abbreviation used as a numeral (now obsolete)
2	4	SUBPOS	Relative/interrogative pronoun with adjectival declension of both types (soft and hard) (
2	5	SUBPOS	The pronoun he in forms requested after any preposition (with prefix
2	6	SUBPOS	Reflexive pronoun
2	7	SUBPOS	Reflexive pronouns
2	8	SUBPOS	Possessive reflexive pronoun
2	9	SUBPOS	Relative pronoun
2	:	SUBPOS	Punctuation (except for the virtual sentence boundary word
2	;	SUBPOS	Abbreviation used as a noun (now obsolete)
2	=	SUBPOS	Number written using digits (
2	?	SUBPOS	Numeral
2	@	SUBPOS	Unrecognized word form (
2	A	SUBPOS	Adjective, general
2	B	SUBPOS	Verb, present or future form
2	C	SUBPOS	Adjective, nominal (short, participial) form
2	D	SUBPOS	Pronoun, demonstrative (
2	E	SUBPOS	Relative pronoun
2	F	SUBPOS	Preposition, part of; never appears isolated, always in a phrase (
2	G	SUBPOS	Adjective derived from present transgressive form of a verb
2	H	SUBPOS	Personal pronoun, clitical (short) form (
2	I	SUBPOS	Interjections (
2	J	SUBPOS	Relative pronoun
2	K	SUBPOS	Relative/interrogative pronoun
2	L	SUBPOS	Pronoun, indefinite
2	M	SUBPOS	Adjective derived from verbal past transgressive form
2	N	SUBPOS	Noun (general)
2	O	SUBPOS	Pronoun
2	P	SUBPOS	Personal pronoun
2	Q	SUBPOS	Pronoun relative/interrogative
2	R	SUBPOS	Preposition (general, without vocalization)
2	S	SUBPOS	Pronoun possessive
2	T	SUBPOS	Particle (
2	U	SUBPOS	Adjective possessive (with the masculine ending
2	V	SUBPOS	Preposition (with vocalization
2	W	SUBPOS	Pronoun negative (
2	X	SUBPOS	(temporary) Word form recognized, but tag is missing in dictionary due to delays in (asynchronous) dictionary creation
2	Y	SUBPOS	Pronoun relative/interrogative
2	Z	SUBPOS	Pronoun indefinite (
2	^	SUBPOS	Conjunction (connecting main clauses, not subordinate)
2	a	SUBPOS	Numeral, indefinite (
2	b	SUBPOS	Adverb (without a possibility to form negation and degrees of comparison, e.g.
2	c	SUBPOS	Conditional (of the verb
2	d	SUBPOS	Numeral, generic with adjectival declension (
2	e	SUBPOS	Verb, transgressive present (endings
2	f	SUBPOS	Verb, infinitive
2	g	SUBPOS	Adverb (forming negation (
2	h	SUBPOS	Numeral, generic; only
2	i	SUBPOS	Verb, imperative form
2	j	SUBPOS	Numeral, generic greater than or equal to 4 used as a syntactic noun (
2	k	SUBPOS	Numeral, generic greater than or equal to 4 used as a syntactic adjective, short form (
2	l	SUBPOS	Numeral, cardinal
2	m	SUBPOS	Verb, past transgressive; also archaic present transgressive of perfective verbs (ex.:
2	n	SUBPOS	Numeral, cardinal greater than or equal to 5
2	o	SUBPOS	Numeral, multiplicative indefinite (
2	p	SUBPOS	Verb, past participle, active (including forms with the enclitic
2	q	SUBPOS	Verb, past participle, active, with the enclitic
2	r	SUBPOS	Numeral, ordinal (adjective declension without degrees of comparison)
2	s	SUBPOS	Verb, past participle, passive (including forms with the enclitic
2	t	SUBPOS	Verb, present or future tense, with the enclitic
2	u	SUBPOS	Numeral, interrogative
2	v	SUBPOS	Numeral, multiplicative, definite (
2	w	SUBPOS	Numeral, indefinite, adjectival declension (
2	x	SUBPOS	Abbreviation, part of speech unknown/indeterminable (now obsolete)
2	y	SUBPOS	Numeral, fraction ending at
2	z	SUBPOS	Numeral, interrogative
2	}	SUBPOS	Numeral, written using Roman numerals (
2	~	SUBPOS	Abbreviation used as a verb (now obsolete)
3	-	GENDER	Not applicable
3	F	GENDER	Feminine
3	H	GENDER	Feminine or Neuter
3	I	GENDER	Masculine inanimate
3	M	GENDER	Masculine animate
3	N	GENDER	Neuter
3	Q	GENDER	Feminine (with singular only) or Neuter (with plural only); used only with participles and nominal forms of adjectives
3	T	GENDER	Masculine inanimate or Feminine (plural only); used only with participles and nominal forms of adjectives
3	X	GENDER	Any of the basic four genders
3	Y	GENDER	Masculine (either animate or inanimate)
3	Z	GENDER	Not fenimine (i.e., Masculine animate/inanimate or Neuter); only for (some) pronoun forms and certain numerals
4	-	NUMBER	Not applicable
4	D	NUMBER	Dual
4	P	NUMBER	Plural
4	S	NUMBER	Singular
4	W	NUMBER	Singular for feminine gender, plural with neuter; can only appear in participle or nominal adjective form with gender value
4	X	NUMBER	Any
5	-	CASE	Not applicable
5	1	CASE	Nominative
5	2	CASE	Genitive
5	3	CASE	Dative
5	4	CASE	Accusative
5	5	CASE	Vocative
5	6	CASE	Locative
5	7	CASE	Instrumental
5	X	CASE	Any
6	-	POSSGENDER	Not applicable
6	F	POSSGENDER	Feminine possessor
6	M	POSSGENDER	Masculine animate possessor (adjectives only)
6	X	POSSGENDER	Any gender
6	Z	POSSGENDER	Not feminine (both masculine or neuter)
7	-	POSSNUMBER	Not applicable
7	P	POSSNUMBER	Plural (possessor)
7	S	POSSNUMBER	Singular (possessor)
8	-	PERSON	Not applicable
8	1	PERSON	1st person
8	2	PERSON	2nd person
8	3	PERSON	3rd person
8	X	PERSON	Any person
9	-	TENSE	Not applicable
9	F	TENSE	Future
9	H	TENSE	Past or Present
9	P	TENSE	Present
9	R	TENSE	Past
9	X	TENSE	Any (Past, Present, or Future)
10	-	GRADE	Not applicable
10	1	GRADE	Positive
10	2	GRADE	Comparative
10	3	GRADE	Superlative
11	-	NEGATION	Not applicable
11	A	NEGATION	Affirmative (not negated)
11	N	NEGATION	Negated
12	-	VOICE	Not applicable
12	A	VOICE	Active
12	P	VOICE	Passive
13	-	RESERVE1	Not applicable
14	-	RESERVE2	Not applicable
15	-	VAR	Not applicable (basic variant, standard contemporary style; also used for standard forms allowed for use in writing by the Czech Standard Orthography Rules despite being marked there as colloquial)
15	1	VAR	Variant, second most used (less frequent), still standard
15	2	VAR	Variant, rarely used, bookish, or archaic
15	3	VAR	Very archaic, also archaic + colloquial
15	4	VAR	Very archaic or bookish, but standard at the time
15	5	VAR	Colloquial, but (almost) tolerated even in public
15	6	VAR	Colloquial (standard in spoken Czech)
15	7	VAR	Colloquial (standard in spoken Czech), less frequent variant
15	8	VAR	Abbreviations
15	9	VAR	Special uses, e.g. personal pronouns after prepositions etc.
EOF

