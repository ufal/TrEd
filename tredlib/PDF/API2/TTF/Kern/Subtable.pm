package PDF::API2::TTF::Kern::Subtable;

=head1 NAME

PDF::API2::TTF::Kern::Subtable

=head1 METHODS

=cut

use strict;
use PDF::API2::TTF::Utils;
use PDF::API2::TTF::AATutils;

require PDF::API2::TTF::Kern::OrderedList;
require PDF::API2::TTF::Kern::StateTable;
require PDF::API2::TTF::Kern::ClassArray;
require PDF::API2::TTF::Kern::CompactClassArray;

sub new
{
    my ($class) = @_;
    my ($self) = {};

    $class = ref($class) || $class;

    bless $self, $class;
}

sub create
{
    my ($class, $type, $coverage, $length) = @_;

    $class = ref($class) || $class;

    my $subclass;
    if ($type == 0) {
        $subclass = 'PDF::API2::TTF::Kern::OrderedList';
    }
    elsif ($type == 1) {
        $subclass = 'PDF::API2::TTF::Kern::StateTable';
    }
    elsif ($type == 2) {
        $subclass = 'PDF::API2::TTF::Kern::ClassArray';
    }
    elsif ($type == 3) {
        $subclass = 'PDF::API2::TTF::Kern::CompactClassArray';
    }
    
    my @options;
    push @options,'vertical'    if ($coverage & 0x8000) != 0;
    push @options,'crossStream'    if ($coverage & 0x4000) != 0;
    push @options,'variation'    if ($coverage & 0x2000) != 0;
    
    my ($subTable) = $subclass->new(@options);

    map { $subTable->{$_} = 1 } @options;

    $subTable->{'type'} = $type;
    $subTable->{'length'} = $length;

    $subTable;
}

=head2 $t->out($fh)

Writes the table to a file

=cut

sub out
{
    my ($self, $fh) = @_;
    
    my $subtableStart = $fh->tell();
    my $type = $self->{'type'};
    my $coverage = $type;
    $coverage += 0x4000 if $self->{'direction'} eq 'RL';
    $coverage += 0x2000 if $self->{'orientation'} eq 'VH';
    $coverage += 0x8000 if $self->{'orientation'} eq 'V';
    
    $fh->print(TTF_Pack("SSL", 0, $coverage, $self->{'subFeatureFlags'}));    # placeholder for length
    
    $self->out_sub($fh);
    
    my $length = $fh->tell() - $subtableStart;
    my $padBytes = (4 - ($length & 3)) & 3;
    $fh->print(pack("C*", (0) x $padBytes));
    $length += $padBytes;
    $fh->seek($subtableStart, IO::File::SEEK_SET);
    $fh->print(pack("n", $length));
    $fh->seek($subtableStart + $length, IO::File::SEEK_SET);
}

=head2 $t->print($fh)

Prints a human-readable representation of the table

=cut

sub post
{
    my ($self) = @_;
    
    my $post = $self->{' PARENT'}{' PARENT'}{'post'};
    if (defined $post) {
        $post->read;
    }
    else {
        $post = {};
    }
    
    return $post;
}

sub print
{
    my ($self, $fh) = @_;
    
    my $post = $self->post();
    $fh = 'STDOUT' unless defined $fh;
}

=head2 $t->print_classes($fh)

Prints a human-readable representation of the table

=cut

sub print_classes
{
    my ($self, $fh) = @_;
    
    my $post = $self->post();
    
    my $classes = $self->{'classes'};
    foreach (0 .. $#$classes) {
        my $class = $classes->[$_];
        if (defined $class) {
            $fh->printf("\t\tClass %d:\t%s\n", $_, join(", ", map { $_ . " [" . $post->{'VAL'}[$_] . "]" } @$class));
        }
    }
}

sub dumpClasses
{
    my ($self, $classes, $fh) = @_;
    my $post = $self->post();
    
    foreach (0 .. $#$classes) {
        my $c = $classes->[$_];
        if ($#$c > -1) {
            $fh->printf("<class n=\"%s\">\n", $_);
            foreach (@$c) {
                $fh->printf("<g index=\"%s\" name=\"%s\"/>\n", $_, $post->{'VAL'}[$_]);
            }
            $fh->printf("</class>\n");
        }
    }
}

1;

=head1 BUGS

None known

=head1 AUTHOR

Jonathan Kew L<Jonathan_Kew@sil.org>. See L<PDF::API2::TTF::Font> for copyright and
licensing.

=cut

