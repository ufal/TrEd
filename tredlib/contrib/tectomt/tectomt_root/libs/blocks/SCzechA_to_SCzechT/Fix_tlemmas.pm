package SCzechA_to_SCzechT::Fix_tlemmas;

use 5.008;
use strict;
use warnings;
use Report;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;


sub possadj_to_noun ($) {
    my $adj_mlemma = shift;
    $adj_mlemma =~/\^\(\*(\d+)(.+)?\)/;
    my $cnt = $1;
    my $suffix = $2;
    my $noun_mlemma = $adj_mlemma;
    $noun_mlemma =~s/\_.+//;
    $noun_mlemma =~s/.{$cnt}$/$suffix/;
    $noun_mlemma =~s/\-.+//;
    return $noun_mlemma;
}



sub process_document {
    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {
        my $t_root = $bundle->get_tree('SCzechT');

        foreach my $t_node ($t_root->get_descendants) {
            my $t_lemma;
            my $a_lex_node = $t_node->get_lex_anode();
            if ($a_lex_node) {
                my $tag = $a_lex_node->get_attr('m/tag');

                if ($tag=~/^P[PS5678H]/) { # osobni zajmena
                    $t_lemma = "#PersPron";
                } elsif ($tag=~/^AU/) {
                    $t_lemma = lc(possadj_to_noun($a_lex_node->get_attr('m/lemma')));
                }

            }

            my ($auxt) = grep {$_->get_attr('afun') eq "AuxT"} $t_node->get_aux_anodes; # reflexiva tantum: smat_se
            if ($auxt) {
                $t_lemma = $t_node->get_attr('t_lemma')."_".lc($auxt->get_attr('m/form')); # zachovane rozliseni se/si
            }


            if ($t_lemma) {
                $t_node->set_attr('t_lemma',$t_lemma);
            } else {
                $t_node->set_attr('t_lemma',lc($t_node->get_attr('t_lemma')));
            }
        }
    }
}

1;


=over

=item SCzechA_to_SCzechT::Fix_tlemmas

???

=back
=cut

# Copyright 2008 Zdenek Zabokrtsky
