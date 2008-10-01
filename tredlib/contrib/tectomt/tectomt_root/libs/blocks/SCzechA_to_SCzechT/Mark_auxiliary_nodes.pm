package SCzechA_to_SCzechT::Mark_auxiliary_nodes;

use 5.008;
use strict;
use warnings;
use Report;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use utf8;

#use utf8;

sub aux_to_parent($) {
    my ($a_node) = shift;
    my $tag = $a_node->get_attr('m/tag');
    my $afun = $a_node->get_attr('afun');
    my $lemma = $a_node->get_attr('m/lemma');
    my $document = $a_node->get_document();
    return (
        ($tag =~ /^Z/ and $afun!~/Coord|Apos/)
            or
                ($afun eq "AuxV")
                    or
                        ($afun eq "AuxT")
                            or
                                ($lemma eq "jako" and $afun!~/AuxC/)
                            );

    # naprosto nedodelane
}


sub aux_to_child($) {
    my ($a_node) = shift;
    my $tag = $a_node->get_attr('m/tag');
    my $form = $a_node->get_attr('m/form');
    my $afun = $a_node->get_attr('afun');

    return (($tag =~ /^(R|J,)/ and not ($form eq "jako" and $afun eq "AuxY")) or $form eq "li"
                or $afun=~/^(AuxP)$/
                    #	  or
                    #	  ($tag=~/^Vf/ and $a_parent and $a_parent->get_attr('m/lemma')=~/^(m.t|cht.t|muset|moci|sm.t)(\_.*)?$/
                    #	   and (print STDERR $a_node->get_attr('id')." QQQ zasah\n\n ")
                    #	  )
            );
}


sub parent_is_aux($) {
    my ($a_node) = shift;
    my $a_parent = $a_node->get_parent();
    return ($a_node->get_attr('m/tag')=~/^Vf/ and $a_parent and $a_parent->get_attr('m/lemma')=~/^(m.t|cht.t|muset|moci|sm.t)(\_.*)?$/
                or ($a_node->get_attr('m/tag')=~/^Vs/ and $a_parent and $a_parent->get_attr('m/lemma')=~/^(b[ý]t)(\_.*)?$/)
                    #	   and (print STDERR $a_node->get_attr('id')." QQQ zasah\n\n ")
            );
}


sub process_document {
    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {
        my $a_aux_root = $bundle->get_tree('SCzechA');
        my ($a_root) = $a_aux_root->get_children(); # there should be always only one child (??? final punctuation?)
        if ($a_root) {
            foreach my $a_node ($a_root, $a_root->get_descendants) {
                $a_node->set_attr('is_aux_to_child',(aux_to_child($a_node)?"1":undef));
                $a_node->set_attr('is_aux_to_parent',(aux_to_parent($a_node)?"1":undef));
                $a_node->set_attr('parent_is_aux',(parent_is_aux($a_node)?"1":undef));
            }
        } else {
            Report::warn ("No children below SCzechA root!");
        }
    }

}

1;


=over

=item SCzechA_to_SCzechT::Mark_auxiliary_nodes


It marks SCzechA nodes which are auxiliary
by filling node attributes aux_to_parent (for nodes which are to be merged
with their autosemantic parents during the conversion to t-layer)
and aux_to_child (for nodes which go to their autsemantic children).


=back
=cut

# Copyright 2008 Zdenek Zabokrtsky
