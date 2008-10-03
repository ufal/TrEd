#!/usr/bin/perl

package SimpleTagger::Czech;

# simple pure-Perl bigram tagger
# written by Zdenek Zabokrtsky
# accuracy cca 87 %

use strict;
use warnings;

my %prob;

#my $data_dir = "$ENV{TMT_ROOT}/training/simple_czech_tagger";
my $data_dir = "$ENV{TMT_SHARED}/generated_data/models_for_simple_tagger";

print STDERR "Loading probability tables...\n";
foreach my $table_name ('prob_tag_given_form','prob_tag_given_prevtag',
			'prob_tag_given_suffix4','prob_tag_given_suffix2') {
    my $filename = "$data_dir/$table_name.tsv.gz";
    print STDERR "   $filename ... \n";
    open I,"<:raw:perlio:gzip:utf8",$filename or die $! ;
    while (<I>) {
        chomp;
        my ($attr1,$attr2,$prob) = split /\t/;
        if (defined $prob and do{$prob=~s/[^\d]//g} and $prob >= 0.00001) {
            $prob{$table_name}{$attr1}{$attr2} = $prob || 1;
        }
    }
}
print STDERR "Loaded.\n";


sub get_possible_tags {
    my $form = shift;

    if ($form =~ /\d/) {
        return ("C=-------------");
    }

    if ($prob{prob_tag_given_form}{$form}) {
        return (sort {$prob{prob_tag_given_form}{$form}{$b}<=>$prob{prob_tag_given_form}{$form}{$a}}
                    keys %{$prob{prob_tag_given_form}{$form}});
    } elsif ($form =~ /.(....)$/ and $prob{prob_tag_given_suffix4}{$1}) {
        return (sort {$prob{prob_tag_given_suffix4}{$1}{$b} <=> $prob{prob_tag_given_suffix4}{$1}{$a}}
                    keys %{$prob{prob_tag_given_suffix4}{$1}});
    } elsif ($form =~ /..(..)$/ and $prob{prob_tag_given_suffix2}{$1}) {
        return (sort {$prob{prob_tag_given_suffix2}{$1}{$b} <=> $prob{prob_tag_given_suffix2}{$1}{$a}}
                    keys %{$prob{prob_tag_given_suffix2}{$1}});
    } else {
        return "NNMS1-----A----";
    }
}

sub get_prob_tag_given_form {
    my ($form,$tag) = @_;
    my $suffix = "";
    if ($form =~ /.(....)$/) {
        $suffix = $1;
    }
    return ($prob{prob_tag_given_form}{$form}{$tag}
                || $prob{prob_tag_given_suffix4}{$suffix}{$tag}
                    || $prob{prob_tag_given_suffix2}{$suffix}{$tag}
                        || 1);
}



sub tag_sentence {
    my @wordforms = map {lc($_)} @_;
    my $prevtag = "";
    my @tag_sequence;
    foreach my $i (0..$#wordforms) {
        my $form = $wordforms[$i];
        my @tags = get_possible_tags($form);
        my %score;
        foreach my $tag (@tags) {
            #      print "    $form/$tag  prob_tag_given_form ".get_prob_tag_given_form($form,$tag)." ";
            #      print "   prob_tag_given_prevtag ".($prob{prob_tag_given_prevtag}{$prevtag}{$tag}||"0.000")."\n";
            $score{$tag} = get_prob_tag_given_form($form,$tag) * ($prob{prob_tag_given_prevtag}{$prevtag}{$tag} || 0.00001);
        }
        my ($best_tag) = sort {$score{$b}<=>$score{$a}} @tags;
        #    print " ---> $form\t$best_tag\t".(join " ",get_possible_tags($wordforms[$i]))."\n";
        if (not defined $best_tag) {
            $best_tag = "NNMS1-----A----";
        }
        $prevtag = $best_tag;
        push @tag_sequence, $best_tag;
    }
    return @tag_sequence;
}
