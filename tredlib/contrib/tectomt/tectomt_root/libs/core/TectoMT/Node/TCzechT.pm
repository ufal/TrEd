package TectoMT::Node::TCzechT;

use 5.008;
use strict;
use warnings;
use Carp;
use Report;

use base qw(TectoMT::Node::T);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

sub get_source_tnode {
    my ($self) = @_;
    my $source_node_id = $self->get_attr('source/head.rf');
    if (defined $source_node_id and $source_node_id ne "") { # divny!!! kde se tam kurna bere ta mezera?
        my $source_node = $self->get_document->get_node_by_id($source_node_id);
        if (defined $source_node) {
            return $source_node;
        } else {
            return undef;
        }
    } else {
        return undef;
    }
}


1;

__END__
