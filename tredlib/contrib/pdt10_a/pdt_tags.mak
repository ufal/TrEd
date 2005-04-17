# -*- cperl -*-
#encoding iso-8859-2

sub describe_tag {
  my ($tag) = @_;
  my @sel;
  my @val = map {
    my $v = substr($tag,$_-1,1);
    if ($v ne '-') {
      "$v = ".$PDT_TAGINFO{$_.$v}[1]
    } else {()}
  } 1..(length($tag));
  ListQuery("$tag - detailed info",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}


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

