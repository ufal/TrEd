package TectoMT::Node::SEnglishA;

use 5.008;
use strict;
use warnings;
use Carp;
use Report;

use base qw(TectoMT::Node::A);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;


sub get_pml_type_name {
    my ($self) = @_;
    if ($self->get_children) {
        return "english_p_nonterminal.type";
    } else {
        return "english_p_terminal.type"
    }
}

sub get_terminal_pnode {
    my ($self) = @_;
    my $document = $self->get_document();
    if ($self->get_attr('p/terminal.rf')) {
        return $document->get_node_by_id($self->get_attr('p/terminal.rf'));
    } else {
        Report::fatal('SEnglishA node pointing to no SEnglishP node');
    }
}

sub get_nonterminal_pnodes {
    my ($self) = @_;
    my $document = $self->get_document();
    if ($self->get_attr('p/nonterminals.rf')) {
        return grep {$_} map {$document->get_node_by_id($_)} @{$self->get_attr('p/nonterminals.rf')};
    } else {
        return ();
    }
}

sub get_pnodes {
    my ($self) = @_;
    return ($self->get_terminal_pnode, $self->get_nonterminal_pnodes);
}


1;

__END__
