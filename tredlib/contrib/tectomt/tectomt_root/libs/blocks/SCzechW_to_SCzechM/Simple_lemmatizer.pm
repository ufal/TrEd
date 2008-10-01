package SCzechW_to_SCzechM::Simple_lemmatizer;

use 5.008;
use strict;
use warnings;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use SimpleLemmatizer::Czech;

sub process_document {

    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {
        my $m_root = $bundle->get_tree('SCzechM');
        foreach my $m_node ($m_root->get_children) {
            my $tag = $m_node->get_attr('tag');
            my $form = $m_node->get_attr('form');
            $m_node->set_attr('lemma',SimpleLemmatizer::Czech::lemmatize($form,$tag));
        }
    }
}

1;

=over

=item Print::Simple_lemmatizer

Applying simple pure-Perl Czech lemmatizer,
using a lemmatization table derived from PDT.

=back

=cut

# Copyright 2008 Zdenek Zabokrtsky
