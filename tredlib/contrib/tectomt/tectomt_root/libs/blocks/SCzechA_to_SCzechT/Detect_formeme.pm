package SCzechA_to_SCzechT::Detect_formeme;

use 5.008;
use strict;
use warnings;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;


sub detect_formeme($$) {
    my ($tnode,$document) = @_;

    if ($tnode->get_attr('a/lex.rf')) {

        my $lex_a_node = $document->get_node_by_id($tnode->get_attr('a/lex.rf'));
        my @aux_a_nodes;
        @aux_a_nodes = map {$document->get_node_by_id($_)} @{$tnode->get_attr('a/aux.rf')}
            if defined $tnode->get_attr('a/aux.rf');
        my $tag = $lex_a_node->get_attr('m/tag');
        my $sempos = $tnode->get_attr('gram/sempos')||"";
        my $formeme;
        my ($tparent) = $tnode->get_eff_parents();
        my $parent_sempos = $tparent->get_attr('gram/sempos')||"";
        my $parent_anode = $tparent->get_lex_anode;
        my $parent_tag = ($parent_anode) ? $parent_anode->get_attr('m/tag') : "";
        #    if ($parent_tag=~/^Vs/) {
        #      print STDERR "Passive\n";
        #    }


        # semantic nouns
        if ($sempos=~/^n/) {
            if ($tag=~/^(AU|PS|P8)/) {
                $formeme = "n:poss";
            } elsif ($tag=~/^[NAP]...(\d)/) {
                my $case = $1;
                my $prep = join "_",
                    map {my $preplemma=$_->get_attr('m/lemma');$preplemma=~s/\-.+//;$preplemma}
                        grep {$_->get_attr('m/tag')=~/^R/  or $_->get_attr('afun')=~/^Aux[PC]/ or $_->get_attr('m/lemma') eq "jako"} @aux_a_nodes;
                if ($prep ne "") {
                    $formeme = "n:$prep+$case";
                } elsif ($parent_sempos=~/^n/ and $tparent->get_attr('deepord') > $tnode->get_attr('deepord')) {
                    $formeme = "n:attr";
                } else {
                    $formeme = "n:$case";
                }
            } else {
                $formeme = "n:???";
            }
        }

        # semantic adjectives
        elsif ($sempos=~/^adj/) {
            my $prep = join "_",
                map {my $preplemma=$_->get_attr('m/lemma');$preplemma=~s/\-.+//;$preplemma}
                    grep {$_->get_attr('m/tag')=~/^R/ or $_->get_attr('afun')=~/^AuxP/} @aux_a_nodes;
            if ($prep ne "") {
                $formeme = "adj:$prep+X";
            } elsif ($parent_sempos=~/v/) {
                $formeme = "adj:compl";
            } else {
                $formeme = "adj:attr";
            }
        }


        # semantic adjectives
        elsif ($sempos=~/^adv/) {
            $formeme = "adv:";
        }


        # semantic verbs
        elsif ($sempos=~/^v/) {
            if ($tag=~/^Vf/ and not grep {$_->get_attr('m/tag')=~/^V[Bp]/} @aux_a_nodes) {
                $formeme = "v:inf"
            } else {
                my $subconj = join "_",
                    map {my $subconjlemma=$_->get_attr('m/lemma');$subconjlemma=~s/\-.+//;$subconjlemma}
                        grep {$_->get_attr('m/tag')=~/^J,/ or $_->get_attr('m/form') eq "li"} @aux_a_nodes;

                if ($tnode->get_attr('is_relclause_head')) {
                    $formeme = "v:rc";
                } elsif ($subconj ne "") {
                    $formeme = "v:$subconj+fin";
                } else {
                    $formeme = "v:fin";
                }
            }
        }



        if ($formeme) {
            #      print "Zjisten cesky formem: $formeme\n";
            $tnode->set_attr('formeme',$formeme);
        } else {
            $tnode->set_attr('formeme',undef);
        }

    }
}



sub process_document {
    my ($self,$document) = @_;
    foreach my $bundle ($document->get_bundles()) {
        my $t_root = $bundle->get_tree('SCzechT');
        foreach my $t_node ( #grep {$_->get_attr('nodetype') eq "complex"}
            $t_root->get_descendants) {
            detect_formeme($t_node,$document);
        }
    }
}

1;

=over

=item SCzechA_to_SCzechT::Detect_formeme

The attribute C<formeme> of CzechT nodes is filled with
a value which describes the morphosyntactic form of the given
node in the original sentence. Values such as C<vfin> (finite verb),
C<pro+noun4> (prepositional group), or C<adv> (adverb) are used.

=back
=cut

# Copyright 2008 Zdenek Zabokrtsky
