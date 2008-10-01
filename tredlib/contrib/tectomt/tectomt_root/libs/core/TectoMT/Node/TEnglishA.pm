package TectoMT::Node::TEnglishA;

use 5.008;
use strict;
use warnings;
use Carp;
use Report;

use base qw(TectoMT::Node::A);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;


#sub get_pml_type_name {
#  my ($self) = @_;
#  if ($self->get_children) {
#    return "english_p_nonterminal.type";
#  }
#  else {
#    return "english_p_terminal.type"
#  }
#}


sub reset_morphcat {
    my ($self) = @_;
    foreach my $category (qw(pos subpos gender number case possgender possnumber
                             person tense grade negation voice reserve1 reserve2)) {
        $self->set_attr("morphcat/$category",".");
    }
}





1;

__END__
