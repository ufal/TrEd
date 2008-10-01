package SCzechA_to_SCzechT::Build_ttree;

use 5.008;
use strict;
use warnings;
use Report;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use TectoMT::Node::SCzechT;

sub aux_to_parent($) {
    my ($a_node) = shift;
    return ($a_node->get_attr('is_aux_to_parent')
                or $a_node->get_attr('parent_is_aux') #hack kvuli nahore visicim mod.slov
            );

}

sub aux_to_child($) {
    my ($a_node) = shift;
    return $a_node->get_attr('is_aux_to_child');
}



sub asubtree_2_tsubtree {
    my ($a_root, $t_parent) = @_;

    if (not $a_root) {
        Report::warn("No children below SCzechT root!");
        return;
    }

    my @a_children = $a_root->get_children();
    #  my $absorbing_child = grep {absorb_parent($_)} @a_children;
    #    print "************new t-node: $a_root @a_children\n";

    if (not aux_to_parent($a_root) and not aux_to_child($a_root)) {

        my $t_new_node = TectoMT::Node::SCzechT->new();

        $t_new_node->set_parent($t_parent);

        #    my $mlemma = $a_root->get_attr('m/lemma');
        #    $mlemma =~ s /[\-\_\`](.+)$//;
        #    $t_new_node->set_attr('t_lemma',$mlemma);
        #    my $id = $a_root->get_attr('id');
        #    $id =~ s/CzechA/CzechT/;
        #    $t_new_node->set_attr('id',$id);
        #    $t_new_node->set_attr('deepord',$a_root->get_attr('ord'));

        foreach my $a_child (@a_children) {
            asubtree_2_tsubtree($a_child,$t_new_node);
        }

        # setting references to a-layer nodes
        $t_new_node->set_attr('a/lex.rf',$a_root->get_attr('id'));
        my $grandpa = $a_root->get_parent->get_parent;

        my @aux_nodes =
            (
                (grep {aux_to_parent($_)} @a_children), # nahradit efektivnima detma!!!
                (grep {aux_to_child($_)} ($a_root->get_parent)), # nahradit efektivnim rodicem!!!
                (($grandpa and aux_to_child($a_root->get_parent) and aux_to_child($grandpa))?($grandpa):()) # plus prarodic, pokud je mezilehly uzel taky schovavaci
            );


        push @aux_nodes, map {grep {aux_to_parent($_)}  $_->get_children()} @aux_nodes;

        my @aux_nodes_rf = map {$_->get_attr('id')} @aux_nodes;

        $t_new_node->set_attr('a/aux.rf', \@aux_nodes_rf);

    } else {
        foreach my $a_child (@a_children) {
            asubtree_2_tsubtree($a_child,$t_parent);
        }
    }
}


sub process_document {
    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {
        my $a_aux_root = $bundle->get_tree('SCzechA');
        my @a_children = $a_aux_root->get_children();
        my ($a_root) = grep {not aux_to_parent($_)} @a_children; # there should be always only one child
        if (not defined $a_root) {
            $a_root = $a_children[0];
        }


        #    print "\n\nYY: a_root form".$a_root->get_attr('m/form')."\n";

        my $t_root = TectoMT::Node::SCzechT->new();
        $bundle->set_tree('SCzechT',$t_root);

        my $root_id = $a_aux_root->get_attr('id');
        #    print "aroot id: ".($a_root->get_attr('id'))."\n";
        $root_id =~ s/CzechA/CzechT/ or Report::fatal("root id $root_id does not match the expected regexp!");
        $t_root->set_attr('id',$root_id);
        $t_root->set_attr('deepord',0);
        $t_root->set_attr('atree.rf', $a_aux_root->get_attr('id'));

        asubtree_2_tsubtree($a_root,$t_root,[]);

        # postprocessing
        foreach my $t_node ($t_root->get_descendants) {

            # oprava u modalnich sloves: do lex patri vyznamove sloveso (a ne modalni), i kdyz bylo v a-stromu dole
            my ($aux_should_be_lex) = grep {$_->get_attr('parent_is_aux')} $t_node->get_aux_anodes();
            if ($aux_should_be_lex) {
                $t_node->set_attr('a/aux.rf',
                                  [$t_node->get_attr('a/lex.rf'),
                                   map {$_->get_attr('id')} grep {$_!=$aux_should_be_lex} $t_node->get_aux_anodes
                               ]
                              );
                $t_node->set_attr('a/lex.rf', $aux_should_be_lex->get_attr('id'));
                #	$t_node->set_attr('t_lemma','modal!!!');
            }

            my $a_lex_node = $t_node->get_lex_anode();

            my $mlemma = $a_lex_node->get_attr('m/lemma');
            $mlemma =~ s /[\-\_\`](.+)$//;
            $t_node->set_attr('t_lemma',$mlemma);

            my $id = $a_lex_node->get_attr('id');
            $id =~ s/CzechA/CzechT/;
            $t_node->set_attr('id',$id);

            $t_node->set_attr('deepord',$a_lex_node->get_attr('ord'));

        }

    }

}

1;


=over

=item SCzechA_to_SCzechT::Build_ttree

For each bundle, a skeleton of the tectogrammatical tree is created (and stored as CzechT tree)
by recursive collapse of the Czech tree (merging functional words with the autosemantic ones etc.).
In each new SCzechT node, references to the source SCzechA nodes are stored in the C<a/lex.rf> and C<a/aux.rf>
attributes. Also attributes C<id>, C<t_lemma>, and C<deepord> are (preliminarly) filled.

=back
=cut

# Copyright 2008 Zdenek Zabokrtsky
