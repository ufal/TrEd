package SCzechM_to_SCzechA::ZZ_parser;

use 5.008;
use strict;
use warnings;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use ZZParser::CzechDepParser;

sub reorder_children { # so that the linked-list representation matches the ord ordering
    my $node = shift;
    foreach my $child (sort {$a->get_attr('ord')<=>$b->get_attr('ord')} $node->get_children) {
        $child->set_parent($node);
    }
}


sub process_document {
    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {

        my $m_root = $bundle->get_tree('SCzechM');

        my $new_a_root = TectoMT::Node->new();
        $bundle->set_tree('SCzechA',$new_a_root);

        $new_a_root->set_attr('id','SCzechA-'.$bundle->get_attr('id').'-root');
        $new_a_root->set_attr('ord',0);

        my $ord = 0;
        foreach my $m_node ($m_root->get_children()) {

            my $new_a_node = TectoMT::Node->new();
            $new_a_node->set_parent($new_a_root);

            $ord++;
            $new_a_node->set_attr('ord',$ord);
            foreach my $attr_name ('form','lemma','tag') {
                $new_a_node->set_attr($attr_name,$m_node->get_attr($attr_name));
                $new_a_node->set_attr("m/$attr_name",$m_node->get_attr($attr_name));
            }
            my $id = $m_node->get_attr('id');
            $id =~ s/^SCzechM/SCzechA/;
            $new_a_node->set_attr('id',$id);

        }

        ZZParser::CzechDepParser::fs_parse($new_a_root->get_tied_fsnode(),$document->get_tied_fsfile());

        reorder_children($new_a_root);

        #    print "\n\n XX deti korene: ".(join (" ",$new_a_root->get_children()))."\n";

    }
}

1;

=over

=item SCzechM_to_SCzechA::ZZ_parser

Zdenek Zabokrtsky's parser is used for building SCzechA trees.
Obsolete, substituted with McDonnald's parser.

=back
=cut



# Copyright 2008 Zdenek Zabokrtsky
