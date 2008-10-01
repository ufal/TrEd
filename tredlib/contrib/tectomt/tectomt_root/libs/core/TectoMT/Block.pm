package TectoMT::Block;

use 5.008;
use strict;
use warnings;
use Report;
use Class::Std;

{

    sub BUILD {
        my ($self, $ident, $arg_ref) = @_;

        return;
    }

    sub process_document {
        Report::fatal "process_document() is not implemented in the abstract class TectoMT::Block !"
      }

}

1;

__END__

=head1 NAME

TectoMT::Block

=head1 SYNOPSIS

 package My_Group_Of_Blocks::My_Block;
 
 use strict;
 use warnings;
 
 use base qw(TectoMT::Block);
 use TectoMT::Document;
 use TectoMT::Bundle;
 use TectoMT::Node;
 
 sub process_document {
    my ($self,$document) = @_;
    foreach my $bundle ($document->get_bundles) {
      # processing
    }
 }



=head1 DESCRIPTION


TectoMT::Block is an abstract class serving as a common ancestor of
all TectoMT blocks. It has the only function: to define their interface,
which is in fact only the process_document method.


=head1 METHODS

=over 4

=item $block->process_document($document);

Applies the block instance on the given instance of TectoMT::Document.

=back


=head1 SEE ALSO

L<TectoMT::Node|TectoMT::Node>,
L<TectoMT::Bundle|TectoMT::Bundle>,
L<TectoMT::Document|TectoMT::Document>,
L<TectoMT::Scenario|TectoMT::Scenario>,

=head1 AUTHOR

Zdenek Zabokrtsky <zabokrtsky@ufal.mff.cuni.cz>

=head1 COPYRIGHT

Copyright (c) 2006 by Zdenek Zabokrtsky. This module is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

