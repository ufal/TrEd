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
      substr($tag,4,2)." = pozice ��d�c�ho slova";
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
3	'-'	NA	��d�c� slovo vlevo
4-5	o	NA	kolik slov vlevo/vpravo je slovo ��d�c� (u druh�ho a dal��ch se ud�v� ��slo �lenu nejbli���ho; stejn� se zachycuj� vztahy mezi �leny sdru�en�ho pojmenov�n� i v p��pad�, �e nejsou samost. syntaktick�mi �leny);vzd�lenosti men�� ne� deset se zapisuj� 01, 02, ..., 09
6	1	NA	koordinace (uv�d� se pouze u druh�ho a dal��ch �len� koordina�n� �ady)
1	2	NA	predik�t
2	1	NA	slovesn�
3	'+'	NA	��d�c� slovo vpravo
6	2	NA	sdru�en� pojmenov�n� determina�n� povahy
2	2	NA	spona
6	3	NA	koordinace uvnit� sdru�en�ho pojmenov�n�
2	3	NA	nom. ��st spon. pred.
6	4	NA	sdru�en� pojmenov�n� jin�
2	4	NA	nomin.
6	5	NA	sdru�en� pojmenov�n� v koordinaci s jin�m sdru�en�m pojmenov�n�m
2	5	NA	spona u jedno�l. v.
6	6	NA	dvojice spojkov� a p��slove�n�
1	3	NA	...
2	1	NA	atribut
6	9	NA	��d�c� v�raz elidov�n
2	2	NA	apozice
6	0	NA	��d�c� v�raz vy�azen
1	4	NA	...
2	1	NA	objekt
6	7	NA	???
2	2	NA	dopln�k
6	8	NA	???
1	5	NA	adverbi�le
2	1	NA	m�sta
2	2	NA	�asu
2	3	NA	zp�sobu
2	4	NA	p���iny
2	5	NA	p�vodu
2	6	NA	p�vodce
2	7	NA	v�sledku
1	6	NA	z�klad v�ty jedno�lenn�
2	1	NA	substantivn�
2	2	NA	adjektivn�
2	3	NA	citoslove�n�
2	4	NA	��sticov�
2	5	NA	vokativn�
2	6	NA	p��slove�en�
2	7	NA	infinitivn�
2	8	NA	slovesn�
2	9	NA	slovesn� jmenn�
2	0	NA	z�jmenn�
1	7	NA	p�ech. typ (s v�eobecn�m subjektem)
1	8	NA	samostatn� v�tn� �len
1	9	NA	parant�ze
EOF

%ORIGT_INFO = map { my ($pos, $val, $type, $desc) = split /\t/,$_,4;
		    $val=$1 if ($val =~ /'(.)'/);
		     ($pos.$val => $desc) } split /\n/, <<'EOF';
1	1	slovn� druh	SUBSTANTIVUM
2	1	NA	nesporn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	8	NA	neskl.
8	4	spisovnost	zastaral�
2	2	NA	adj.
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	3	NA	zvrat.
8	5	spisovnost	nespis.
2	3	NA	z�jm.
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
8	6	spisovnost	v�pl�k. nespis.
2	4	NA	��sl.
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
8	7	spisovnost	v�pl�k.
2	5	NA	slov.
4	9	rod	nelze ur�it
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
2	6	NA	slov. zvr.
6	6	p�d	lok�l
2	7	NA	zkratka
6	7	p�d	instrument�l
2	9	NA	zkr. slovo
6	9	p�d	nelze ur�it
2	0	NA	vl. jm�no
1	2	slovn� druh	ADJEKTIVUM
2	2	NA	nesporn�
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
8	4	spisovnost	zastaral�
3	1	NA	jm. tvar
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
8	5	spisovnost	nespis.
3	2	NA	jm. zvrat.
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
7	2	stupe�	II.st.
8	6	spisovnost	v�pl�k. nespis.
2	3	NA	z�jmenn�
3	1	NA	jm. tvar
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
7	3	stupe�	III.st
8	7	spisovnost	v�pl�k.
3	2	NA	neur�it�
4	9	rod	nelze ur�it
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
7	8	stupe�	neskl.
3	4	NA	ukazovac�
6	6	p�d	lok�l
3	5	NA	t�zac�
6	7	p�d	instrument�l
3	6	NA	vzta�n�
6	9	p�d	nelze ur�it
3	7	NA	z�porn�
3	8	NA	p�ivl.
2	4	NA	��slovka
3	2	NA	�adov�
3	3	NA	druhov�
3	4	NA	n�sobn�
3	5	NA	neur�it�
2	5	NA	slovesn�
3	0	NA	zvratn�
3	1	NA	jmenn�
3	2	NA	jm. zvrat.
2	7	NA	jmenn� st�. rodu
2	9	NA	p�ivlast�ovac�
1	3	slovn� druh	Z�JMENO
2	1	NA	osobn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	1	tvar	krat��
8	4	spisovnost	zastaral�
2	2	NA	neur�it�
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	2	tvar	del��
8	5	spisovnost	nespis.
2	3	NA	zvratn�
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
8	6	spisovnost	v�pl�k. nespis.
2	4	NA	ukazovac�
4	4	rod	neutrum
5	9	��slo	nelze ur�it
6	4	p�d	akuzativ
8	7	spisovnost	v�pl�k.
2	5	NA	t�zac�
4	7	rod	bezrod�
6	5	p�d	vokativ
2	6	NA	vzta�n�
4	9	rod	nelze ur�it
6	6	p�d	lok�l
2	7	NA	z�porn�
6	7	p�d	instrument�l
6	9	p�d	nelze ur�it
1	4	slovn� druh	��SLOVKA
2	1	NA	z�kladn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	1	p�d	nom.
8	4	spisovnost	zastaral�
2	(3)	NA	druhov�
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	2	p�d	gen.
8	5	spisovnost	nespis.
2	(4)	NA	n�sobn�
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
7	3	p�d	dat.
8	6	spisovnost	v�pl�k. nespis.
2	5	NA	neur�it�
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
7	4	p�d	akz.
8	7	spisovnost	v�pl�k.
2	6	NA	pod�ln�
4	7	rod	bezrod�
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
7	5	p�d	vok.
4	8	rod	neskl.
6	6	p�d	lok�l
7	6	p�d	lok.
4	9	rod	nelze ur�it
6	7	p�d	instrument�l
7	7	p�d	ins.
6	9	p�d	nelze ur�it
7	9	p�d	nelze ur�it
1	5	slovn� druh	SLOVESO
2	1	NA	dokonav�
3	1	osoba ��slo	1.sg.
4	1	�as zp�sob	ind.pr�z.akt.
5	1	imperativ	imp.akt.
6	1	NA	jednosl.
7	1	jmenn� rod	m.�iv.
8	4	spisovnost	zastaral�
2	2	NA	nedokonav�
3	2	osoba ��slo	2.sg.
4	2	�as zp�sob	ind.pr�z.pas.
5	2	imperativ	imp.pas.
6	2	NA	v�cesl. nezvr.
7	2	jmenn� rod	m.ne�.
8	5	spisovnost	nespis.
2	3	NA	obojvid�
3	3	osoba ��slo	3.sg.
4	3	�as zp�sob	kond.pr�z.ak.
5	3	imperativ	kond.pf.akt.
6	7	NA	zvrat. neslo�.
7	3	jmenn� rod	fem.
8	6	spisovnost	v�pl�k. nespis.
3	4	osoba ��slo	1.pl.
4	4	�as zp�sob	kond.pr�z.ps.
5	4	imperativ	kond.pf.pas.
6	8	NA	zvrat. slo�.
7	4	jmenn� rod	neutr.
8	7	spisovnost	v�pl�k.
3	5	osoba ��slo	2.pl.
4	5	�as zp�sob	ind.pr�t.akt.
5	5	imperativ	p.sl. ``b�vati''
6	9	NA	pf.stav.p��t.
7	5	jmenn� rod	pl.m.�.
3	6	osoba ��slo	3.pl.
4	6	�as zp�sob	ind.pr�t.pas.
5	6	imperativ	part.pas.
6	0	NA	pf.stav.min.
7	6	jmenn� rod	pl.m.n.
3	7	osoba ��slo	inf.ak.
4	7	�as zp�sob	kond.min.akt.
5	7	imperativ	p�ech.p�.akt.
7	7	jmenn� rod	pl.fem.
3	8	osoba ��slo	inf.ps.
4	8	�as zp�sob	kond.min.pas.
5	8	imperativ	p�ech.p�.ps.
7	8	jmenn� rod	pl.neu.
3	9	osoba ��slo	neos.
4	9	�as zp�sob	fut.ind.akt.
5	9	imperativ	p�ech.min.ak.
7	9	jmenn� rod	nelze ur�it
4	0	�as zp�sob	fut.ind.pas.
5	0	imperativ	p�ech.min.ps.
1	6	slovn� druh	ADVERBIUM
2	6	NA	nesporn�
2	2	NA	predik.
4	2	stupe�	II. st.
8	4	spisovnost	zastaral�
2	3	NA	z�jmenn�
4	3	stupe�	III. st.
8	5	spisovnost	nespis.
2	4	NA	��seln�
3	4	NA	n�sobn�
8	6	spisovnost	v�pl�k. nespis.
3	6	NA	pod�ln�
8	7	spisovnost	v�pl�k.
3	5	NA	neur�it�
2	8	NA	spojovac� v�raz
1	7	slovn� druh	P�EDLO�KA
2	7	NA	vlastn�
3	2	p�d	s genitivem
8	4	spisovnost	zastaral�
2	8	NA	nevlastn�
3	3	p�d	s dativem
8	5	spisovnost	nespis.
3	4	p�d	s akuzativem
3	6	p�d	s lok�lem
3	7	p�d	s instrument�lem
1	8	slovn� druh	SPOJKA
2	1	NA	sou�ad�c�
8	4	spisovnost	zastaral�
2	2	NA	pod�ad�c�
8	5	spisovnost	nespis.
2	9	NA	jin� v�raz
1	9	slovn� druh	CITOSLOVCE
2	9	NA	nesporn�
8	4	spisovnost	zastaral�
2	1	NA	subst.
8	5	spisovnost	nespis.
2	2	NA	adj.
8	6	spisovnost	v�pl�k. nespis.
2	3	NA	z�jm.
8	7	spisovnost	v�pl�k.
2	5	NA	slov.
2	6	NA	adv.
1	0	slovn� druh	��STICE
1	000	slovn� druh	CIT�TOV� V�RAZY
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

