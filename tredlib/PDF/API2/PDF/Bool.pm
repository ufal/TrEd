package PDF::API2::PDF::Bool;

use strict;
use vars qw(@ISA);
# no warnings qw(uninitialized);

use PDF::API2::PDF::String;
@ISA = qw(PDF::API2::PDF::String);

=head1 NAME

PDF::Bool - A special form of L<PDF::String> which holds the strings
B<true> or B<false>

=head1 METHODS

=head2 $b->convert($str)

Converts a string into the string which will be stored.

=cut

sub convert
{ return $_[1] eq "true"; }


=head2 as_pdf

Converts the value to a PDF output form

=cut

sub as_pdf
{ $_[0]->{'val'} ? "true" : "false"; }

sub outxmldeep
{
    my ($self, $fh, $pdf, %opts) = @_;

    $opts{-xmlfh}->print("<Bool>".$self->as_pdf."</Bool>\n");
}

1;

