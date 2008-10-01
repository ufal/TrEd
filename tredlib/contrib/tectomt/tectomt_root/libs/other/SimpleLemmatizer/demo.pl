#!/usr/bin/perl

use SimpleLemmatizer::Czech;

print "Lemma: ".SimpleLemmatizer::Czech::lemmatize("Budu","V")."\n";
print "Lemma: ".SimpleLemmatizer::Czech::lemmatize("oslavou","N")."\n";
