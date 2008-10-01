package SCzechW_to_SCzechM::Tokenize;

use 5.008;
use strict;
use warnings;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;
use Report;

sub process_document {
    my ($self,$document) = @_;

    foreach my $bundle ($document->get_bundles()) {

        my $m_root = TectoMT::Node->new();
        $bundle->set_tree('SCzechM',$m_root);

        my $bundle_id = $bundle->get_attr('id');
        $m_root->set_attr('id', "SCzechM-$bundle_id");

        my $sentence = $bundle->get_attr('czech_source_sentence');

        my $tokencnt = 0;

        while ($sentence=~s/([[:alnum:]]+|[^\s[:alnum:]])//) {
            my $token = $1;
            $tokencnt++;
            my $new_m_node = TectoMT::Node->new();
            $new_m_node->set_parent($m_root);
            $new_m_node->set_attr('form',$token);
            $new_m_node->set_attr('id',"SCzechM-${bundle_id}-w$tokencnt");
        }
    }
}

1;

=over

=item SCzechW_to_SCzechM::Tokenize

Each Czech sentence (stored in the bundle attribute C<czech_source_sentence>)
is split into a sequence of tokens using a simpler regular expression.
Within each bundle, a new SCzechM tree is initiated and filled
with nodes corresponding to the tokens, each of them equipped
with attributes C<form> and C<id>.

=back
=cut

# Copyright 2008 Zdenek Zabokrtsky
