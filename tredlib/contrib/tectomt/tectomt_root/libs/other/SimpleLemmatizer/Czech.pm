package SimpleLemmatizer::Czech;

# simple lemmatizer using mapping (form,pos)->lemma extracted from PDT
# written by Zdenek Zabokrtsky

use strict;
use warnings;

my $filename = "$ENV{TMT_SHARED}/generated_data/data_for_simple_lemmatizer/form_and_pos_to_lemma.tsv.gz";

my %form_and_pos_to_lemma;

print STDERR "Loading the lemmatization table...\n";
open I,"<:raw:perlio:gzip:utf8",$filename or die $!;
while (<I>) {
    chomp;
    my ($form,$pos,$lemma) = split /\t/;
    $form_and_pos_to_lemma{$form}{$pos} = $lemma
        unless defined $form_and_pos_to_lemma{$form}{$pos};
}
print STDERR "Lemmatization table loaded.\n";

sub lemmatize {
    my ($form,$tag) = @_;
    if ($tag =~ /^(.)/) {
        my $pos = $1;
        my $lemma = $form_and_pos_to_lemma{lc($form)}{$pos} || lc($form);
    }
}
