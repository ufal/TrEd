package PDF::API2::PDF::Number;

=head1 NAME

PDF::API2::PDF::Number - Numbers in PDF. Inherits from L<PDF::API2::PDF::String>

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
# no warnings qw(uninitialized);

use PDF::API2::PDF::String;
@ISA = qw(PDF::API2::PDF::String);


=head2 $n->convert($str)

Converts a string from PDF to internal, by doing nothing

=cut

sub convert
{ return $_[1]; }


=head2 $n->as_pdf

Converts a number to PDF format

=cut

sub as_pdf
{ $_[0]->{'val'}; }

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $opts{-xmlfh}->print("<Number>".$self->val."</Number>\n");
}

