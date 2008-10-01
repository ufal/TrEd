package TredPlugin::CzechAnalysis;

# Simple API for morphological, analytical and tectogrammatical
# analysis of Czech sentences, using only pure-Perl TectoMT blocks.
# Intended for interactive usage in Tred.
# written by Zdenek Zabokrtsky

use strict;
use warnings;

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;
use TectoMT::Scenario;

my $scenario =  TectoMT::Scenario->new({'blocks' => [ qw(
                                                            SCzechW_to_SCzechM::Tokenize.pm
                                                            SCzechW_to_SCzechM::Simple_tagger
                                                            SCzechW_to_SCzechM::Simple_lemmatizer
                                                            SCzechM_to_SCzechA::ZZ_parser
                                                            SCzechA_to_SCzechT::Mark_auxiliary_nodes
                                                            SCzechA_to_SCzechT::Build_ttree
                                                            SCzechA_to_SCzechT::Rehang_unary_coord_conj
                                                            SCzechA_to_SCzechT::Fill_is_member
                                                            SCzechA_to_SCzechT::Assign_coap_functors
                                                            SCzechA_to_SCzechT::Distrib_coord_aux
                                                            SCzechA_to_SCzechT::Mark_clause_heads
                                                            SCzechA_to_SCzechT::Mark_relclause_heads
                                                            SCzechA_to_SCzechT::Fix_tlemmas
                                                            SCzechA_to_SCzechT::Recompute_deepord
                                                            SCzechA_to_SCzechT::Assign_nodetype
                                                            SCzechA_to_SCzechT::Assign_grammatemes
                                                            SCzechA_to_SCzechT::Detect_formeme 
                                                    ) ]});


sub Get_mat_sentence_analyses {
    my $sentence = shift;

    if (not defined $sentence or $sentence eq "") {
        die "Undefined or empty input sentence!";
    }

    my $document = TectoMT::Document->new();
    my $bundle = $document->new_bundle();
    $bundle->set_attr('id', 'b1');
    $bundle->set_attr('czech_source_sentence', $sentence);

    $scenario->apply_on_tmt_documents($document);

    my $fs_m_root = $bundle->get_tree('SCzechM')->get_tied_fsnode;
    my $fs_a_root = $bundle->get_tree('SCzechA')->get_tied_fsnode;
    my $fs_t_root = $bundle->get_tree('SCzechT')->get_tied_fsnode;
    return ( $fs_m_root, $fs_a_root, $fs_t_root );

}
