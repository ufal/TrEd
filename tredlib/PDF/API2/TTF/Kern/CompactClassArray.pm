package PDF::API2::TTF::Kern::CompactClassArray;

=head1 NAME

PDF::API2::TTF::AAT::Kern::CompactClassArray

=head1 METHODS

=cut

use strict;
use vars qw(@ISA);
use PDF::API2::TTF::Utils;
use PDF::API2::TTF::AATutils;

@ISA = qw(PDF::API2::TTF::Kern::Subtable);

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $class = ref($class) || $class;
    bless $self, $class;
}

=head2 $t->read

Reads the table into memory

=cut

sub read
{
    my ($self, $fh) = @_;
    
    die "incomplete";
            
    $self;
}

=head2 $t->out($fh)

Writes the table to a file

=cut

sub out_sub
{
    my ($self, $fh) = @_;
    
    die "incomplete";
            
    $self;
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub print
{
    my ($self, $fh) = @_;
    
    my $post = $self->post();
    
    $fh = 'STDOUT' unless defined $fh;

    die "incomplete";
}


sub type
{
    return 'kernCompactClassArray';
}


1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::TTF::Font> for copyright and
licensing.

=cut

