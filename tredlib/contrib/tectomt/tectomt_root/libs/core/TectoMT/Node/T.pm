package TectoMT::Node::T;

use 5.008;
use strict;
use warnings;
use Carp;
use Report;

use base qw(TectoMT::Node);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

sub ordering_attribute { 'deepord' }

sub get_pml_type_name {
    my ($self) = @_;
    if ($self->get_parent) {
        return "t-node.type";
    } else {
        return "t-root.type";
    }
}

sub get_lex_anode {
    my ($self) = @_;
    my $document = $self->get_document();
    if ($self->get_attr('a/lex.rf')) {
        return $document->get_node_by_id($self->get_attr('a/lex.rf'));
    } else {
        #    Report::fatal('SEnglishA node pointing to no SEnglishP node');
    }
}

sub get_aux_anodes {
    my ($self) = @_;
    my $document = $self->get_document();

    if ($self->get_attr('a/aux.rf')) {
        return map {$document->get_node_by_id($_)} @{$self->get_attr('a/aux.rf')};
    } else {
        return ();
    }
}

sub set_aux_anodes {
    my $self = shift;
    my @aux_anodes = @_;
    $self->set_attr('a/aux.rf',[map {$_->get_attr('id')} @aux_anodes]);
}

sub add_aux_anodes {
    my $self = shift;
    my @prev = $self->get_aux_anodes();
    $self->set_aux_anodes(@prev, @_);
}

sub get_anodes {
    my ($self) = @_;
    return ($self->get_lex_anode, $self->get_aux_anodes);
}


sub get_eff_children {
    my ($self) = @_;
    return map {$TectoMT::Node::fsnode2tmt_node{$_}} PML_T2::GetEChildren($self->get_tied_fsnode());
}

sub get_eff_parents {
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;

    my $node = $self;
    # getting the highest node representing the given node
    if ($node->is_coap_member) {
        while ($node && (!$node->is_coap_root || $node->is_coap_member)) {
            $node = $node->get_parent;
        }
    }
    $node && $node->get_parent or goto FALLBACK_get_eff_parents;
    # getting the parent
    $node = $node->get_parent;
    my @eff = $node->is_coap_root? $node->get_transitive_coap_members : ($node);
    return @eff if @eff > 0;

  FALLBACK_get_eff_parents:
    if ($self->get_parent) {
        Report::warn "The node ".$self->get_id." has no effective parent, using the topological one";
        return $self->get_parent;
    } else {
        Report::warn "The node ".$self->get_id." has no effective nor topological parent, using the root";
        return $self->get_root;
    }
}


sub get_ordering_value { # redefinition of TectoMT::Node's methods (because of the different name of the ordering attribute)
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    return $self->get_attr('deepord');
}

sub set_ordering_value {
    my ($self, $val) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 2;
    $self->set_attr('deepord', $val);
}

# the node is a root of a coordination/apposition construction
sub is_coap_root {              # analogy of PML_T::IsCoord
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    return defined $self->get_attr('functor') && $self->get_attr('functor') =~ /^(CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER)$/;
}

sub is_coap_member {
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    return $self->get_attr('is_member');
}

sub get_transitive_coap_members { # analogy of PML_T::ExpandCoord
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    if ($self->is_coap_root) {
        return (map { $_->is_coap_root? $_->get_transitive_coap_members : ($_) }
                    grep { $_->is_coap_member } $self->get_children);
    } else {
        #Report::warn("The node ".$self->get_attr('id')." is not root of a coordination/apposition construction\n");
        return ($self);
    }
}

sub get_direct_coap_members {
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    if ($self->is_coap_root) {
        return (grep { $_->is_coap_member } $self->get_children);
    } else {
        #Report::warn("The node ".$self->get_attr('id')." is not root of a coordination/apposition construction\n");
        return ($self);
    }
}

sub get_transitive_coap_root { # analogy of PML_T::GetNearestNonMember
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    while ($self->is_coap_member) {
        $self = $self->get_parent;
    }
    return $self;
}

# --------- funkce pro efektivni potomky a rodice by Jan Stepanek - prevzato z PML_T.inc a upraveno -------------

package PML_T2;


my $recursion;

sub _FilterEChildren {          # node suff from
    my ($node,$suff,$from)=(shift,shift,shift);
    my @sons;
    $node=$node->firstson;
    while ($node) {
        #    return @sons if $suff && @sons; #uncomment this line to get only first occurence
        unless ($node==$from){ # on the way up do not go back down again
            if (($suff&&$node->{is_member})
                    ||(!$suff&&!$node->{is_member})) { # this we are looking for
                push @sons,$node unless IsCoord($node);
            }
            push @sons,_FilterEChildren($node,1,0)
                if (!$suff
                        &&IsCoord($node)
                            &&!$node->{is_member})
                    or($suff
                           &&IsCoord($node)
                               &&$node->{is_member});
        }                       # unless node == from
        $node=$node->rbrother;
    }
    @sons;
}                               # _FilterEChildren

sub GetEChildren {              # node
    my $node=shift;
    return () if IsCoord($node);
    my @sons;
    my $init_node=$node;        # for error message
    my $from;
    push @sons,_FilterEChildren($node,0,0);
    if ($node->{is_member}) {
        my @oldsons=@sons;
        while ($node and (!$node->{nodetype} || $node->{nodetype}ne'root')
                   and ($node->{is_member} || !IsCoord($node))) {
            $from=$node;$node=$node->parent;
            push @sons,_FilterEChildren($node,0,$from) if $node;
        }
        if ($node->{nodetype} && $node->{nodetype}eq'root') {
            #      stderr("Error: Missing coordination head: $init_node->{id} $node->{id} ",ThisAddressNTRED($node),"\n");
            Report::warn("Error: Missing coordination head: $init_node->{id} $node->{id} \n");
            @sons=@oldsons;
        }
    }
    @sons;
}                               # GetEChildren


sub IsCoord {
    my $node=shift;
    return 0 unless $node;
    return (defined($node->{functor}) and $node->{functor} =~ /CONJ|CONFR|DISJ|GRAD|ADVS|CSQ|REAS|CONTRA|APPS|OPER/);
}


1;

__END__
