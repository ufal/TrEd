package TectoMT::Node::A;

use 5.008;
use strict;
use warnings;
use Carp;
use Report;

use base qw(TectoMT::Node);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

sub ordering_attribute { 'ord' }

sub get_pml_type_name {
    my ($self) = @_;
    if ($self->get_parent) {
        return "a-node.type";
    } else {
        return "a-root.type";
    }
}

sub get_eff_children {
    my ($self) = @_;
    return  map {$TectoMT::Node::fsnode2tmt_node{$_}}
        PML_A2::GetEChildren($self->get_tied_fsnode());
}

sub get_eff_parents {
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;

    my $node = $self;
    # getting the highest node representing the given node
    if ($node->is_coap_member) {
        while ($node && $node->is_coap_member && $node->get_parent->is_coap_root) {
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

# the node is a root of a coordination/apposition construction
sub is_coap_root {              # analogy of PML_T::IsCoord
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    return defined $self->get_attr('afun') && $self->get_attr('afun') =~ /^(Coord|Apos)$/;
}

sub is_coap_member {
    my ($self) = @_;
    Report::fatal("Incorrect number of arguments") if @_ != 1;
    return ($self->get_attr('is_member')
		|| (($self->get_attr('afun')||"") =~ /^Aux[CP]$/ && grep { $_->is_coap_member } $self->get_children))
        ? 1 : undef;
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


# --------- funkce pro efektivni potomky a rodice by Jan Stepanek - prevzato z PML_A.inc a upraveno -------------

package PML_A2;

no warnings;

sub _FilterEChildren{           # node dive suff from
    my ($node,$dive,$suff,$from)=@_;
    my @sons;
    $node=$node->firstson;
    while ($node) {
        #    return @sons if $suff && @sons; # comment this line to get all members
        unless ($node==$from) { # on the way up do not go back down again
            if (!$suff&&$node->{afun}=~/Coord|Apos/&&!$node->{is_member}
                    or $suff&&$node->{afun}=~/Coord|Apos/&&$node->{is_member}) {
                push @sons,_FilterEChildren($node,$dive,1,0)
            } elsif (&$dive($node) and $node->firstson) {
                push @sons,_FilterEChildren($node,$dive,$suff,0);
            } elsif (($suff&&$node->{is_member})
                         ||(!$suff&&!$node->{is_member})) { # this we are looking for
                push @sons,$node;
            }
        }                       # unless node == from
        $node=$node->rbrother;
    }
    @sons;
}                               # _FilterEChildren

sub GetEChildren{               # node dive
    my ($node,$dive)=@_;
    my @sons;
    my $from;
    $dive = sub { 0 } unless defined($dive);
    push @sons,_FilterEChildren($node,$dive,0,0);
    if ($node->{is_member}) {
        my @oldsons=@sons;
        while ($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}) {
            $from=$node;$node=$node->parent;
            push @sons,_FilterEChildren($node,$dive,0,$from);
        }
        if (not $node->parent) {
            print STDERR "Error: Missing Coord/Apos: $node->{id} ".ThisAddress($node)."\n";
            @sons=@oldsons;
        }
    }
    return@sons;
}                               # GetEChildren




1;

__END__
