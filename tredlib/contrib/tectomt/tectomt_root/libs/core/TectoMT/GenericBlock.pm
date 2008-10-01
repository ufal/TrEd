package TectoMT::GenericBlock;

use 5.008;
use strict;
use warnings;
use Report;
use Class::Std;

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

{

    our $VERSION = '0.01';
    my %Anylang1 : ATTR;
    my %Anylang2 : ATTR;


    sub BUILD {
        my ($self, $ident, $arg_ref) = @_;

        if (not defined $arg_ref->{Anylang1}) {
            Report::fatal "At least Anylang1 has to be specified when calling TectoMT::GenericBlock constructor.";
        }

        $Anylang1{$ident} = $arg_ref->{Anylang1};
        $Anylang2{$ident} = $arg_ref->{Anylang2};

        #print STDERR "TectoMT::GenericBlock: self: $self , anylang1=$Anylang1{$ident}   anylang2=$Anylang2{$ident} \n";

        return;
    }


    sub get_Anylang1 {
        my ($self) = @_;
        return $Anylang1{ident $self};
    }

    sub get_Anylang2 {
        my ($self) = @_;
        return $Anylang2{ident $self};

    }

}


1;


__END__

=head1 NAME

TectoMT::GenericBlock


=head1 VERSION

0.0.1

=head1 SYNOPSIS

 use TectoMT::Bundle;
 priklad vytvoreni noveho bloku
 ??? ??? ??? ???



=head1 DESCRIPTION


?? ?? ?? ?? ?? ???? ?? ???? ?? ???? ?? ??


Abstract class which is to be used only as a common predecessor
of all translation blocks used in the TectoMT system.


=head1 METHODS different from TectoMT::Block

=over 4

=item $block->get_Anylanguage1;

Get the value of language parameter Anylanguage1 by matching
the name of the requested block with the name of the generic block.

=item $block->get_Anylanguage2;

...


=item $block->process_document($document);

Applies the translation block on the given TectoMT::Document object.

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

