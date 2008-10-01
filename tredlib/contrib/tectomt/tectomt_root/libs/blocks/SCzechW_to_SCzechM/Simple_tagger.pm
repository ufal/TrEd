package SCzechW_to_SCzechM::Simple_tagger;

use 5.008;
use strict;
use warnings;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use SimpleTagger::Czech;

sub process_document {

    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {
        my $m_root = $bundle->get_tree('SCzechM');

        my @nodes = $m_root->get_children;
        my @forms = map {$_->get_attr('form')} @nodes;

        my @tags =  SimpleTagger::Czech::tag_sentence(@forms);

        if (@tags  != @nodes) {
            Report::fatal "Different number of tokens and tags. TOKENS: @forms, TAGS: ".@tags;
        }

        foreach my $index (0..$#nodes) {
            $nodes[$index]->set_attr('tag',$tags[$index]);
        }

    }
}

1;

=over

=item SCzechW_to_SCzechM::Simple_tagger

Applying simple pure-Perl Czech morphological tagger.

=back

=cut

# Copyright 2008 Zdenek Zabokrtsky
