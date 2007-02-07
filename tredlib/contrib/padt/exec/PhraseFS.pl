#!/usr/bin/perl -w ###################################################################### 2005/07/12

eval 'exec /usr/bin/perl -w ###################################################################### 2005/07/12 -S $0 ${1+"$@"}'
    if 0; # not running under some shell
#
# PhraseFS.pl ########################################################################## Otakar Smrz

# $Id$

use strict;

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

BEGIN {

    our $libDir = `btred --lib`;

    chomp $libDir;

    eval "use lib '$libDir'";
}

use Fslib 1.6;

use MorphoMap 1.9;

use Encode::Arabic ':modes';


demode 'buckwalter', 'noneplus';

our $decode = "utf8";

our $encode = "utf8";

our ($target, $file, $twig, $this, $tree_lim, $node_lim, $term_lim);


# ##################################################################################################
#
# ##################################################################################################


@ARGV = glob join " ", @ARGV;


until (eof()) {

    $target = FSFile->create(

                'FS'        => FSFormat->create(

                    '@P token',
                    '@P label',
                    '@P tag_1',
                    '@P tag_2',
                    '@P tag_3',
                    '@P other',
                    '@P form',
                    '@P ref',
                    '@N ord',
                    '@P ord_just',
                    '@P ord_term',

                                ),

                'hint'      =>  ( join "\n",

                        'token: ${token}',
                        'label: ${label}',
                        'tag_1: ${tag_1}',
                        'tag_2: ${tag_2}',
                        'tag_3: ${tag_3}',
                        'other: ${other}',

                                ),
                'patterns'  => [

                        'cvs: $' . 'Revision' . ': $ $' . 'Date' . ': $',

                        'mode:' . 'PhraseTrees',

                        'style:' . q {<?

                                '#{Line-coords:n,n,n,(p+n)/2,p,p}'

                            ?>},

                        q {<? $this->{token} eq '' ? '#{custom1}${label}' : '#{custom2}${token} #{custom6}${form}' ?>},

                        '#{custom3}${tag_1}',
                        '#{custom4}${tag_2}',
                        '#{custom5}${tag_3}',

                                ],
                'trees'     => [],
                'backend'   => 'FSBackend',
                'encoding'  => $encode,
        );

    $file = $ARGV;

    $/ = "(";

    $tree_lim = $node_lim = 0;

    $this = undef;

    until (eof) {

        $twig = decode $decode, scalar <>;

        $this = parse_twig($twig, $this);
    }

    foreach my $tree ($target->trees()) {

        justify_order($tree);
    }

    $target->writeFile($file . '.fs') if $tree_lim > 0;

    printf "%s\t%s\n", $_, $file foreach keys %MorphoMap::AraMorph_POSVector_missing;

    %MorphoMap::AraMorph_POSVector_missing = ();
}


sub parse_twig {

    my ($twig, $this) = @_;

    my $node;

    my @tokens = map { split ' ', $_ } split /(\))/, $twig;

    warn "!!! No tokens to parse !!!" unless @tokens;

    while (@tokens) {

        if ($tokens[0] eq "(") {

            if (defined $this) {

                $node = FSNode->new();

                $node->{'ord'} = ++$node_lim;

                $node->paste_on($this, 'ord');

                $this = $node;
            }
            else {

                $this = $target->new_tree($tree_lim++);

                $node_lim = $term_lim = 0;

                $this->{'ord'} = ++$node_lim;
            }
        }
        elsif ($tokens[0] eq ")") {

            if ($this->parent()) {

                $this = $this->parent();
            }
            else {

                $this = undef;
            }
        }
        elsif ($tokens[1] eq "(") {

            $this->{'label'} = $tokens[0];
            $this->{'token'} = '';
        }
        elsif ($tokens[2] eq ")") {

            $this->{'label'} = $tokens[0];
            $this->{'token'} = $tokens[1];

            $this->{'form'} = $tokens[1] =~ /^\*(?:[A-Z0-9]+\*)?$/
                                                ? '_'
                                                : decode 'buckwalter', $tokens[1];

            $this->{'tag_1'} = $tokens[0];
            $this->{'tag_2'} = MorphoMap::AraMorph_POSVector($tokens[0]);
            $this->{'tag_3'} = MorphoMap::AraMorph_PennTBSet($tokens[0]);

            $this->{'ord_term'} = ++$term_lim;

            shift @tokens;
        }
        else {

            warn "!!! Unrecognized tokens !!!" unless @tokens;
        }

        shift @tokens;
    }

    return $this;
}

sub justify_order {

    my ($root) = @_;

    my ($index, $cnst) = (0, 0.001);

    my @nodes = ();

    my $this = $root->rightmost_descendant();

    do {

        $this->{'ord_just'} = $this->{'ord'} unless $this->firstson();

        $this->parent()->{'ord_just'} = $this->{'ord_just'} unless $this->rbrother();

        $this->parent()->{'ord_just'} = ($this->parent()->{'ord_just'} + $this->{'ord_just'} + $cnst) / 2 unless $this->lbrother();

        unshift @nodes, $this;
    }
    while $this = $this->previous($root) and $this != $root;

    unshift @nodes, $root;

    @nodes = sort { $a->{'ord_just'} <=> $b->{'ord_just'} } @nodes;

    foreach $this (@nodes) {

        $this->{'ord_just'} = ++$index;
    }
}


__END__


=head1 NAME

PhraseFS - Generating PhraseTrees given a list of input Tree/Text documents


=head1 REVISION

    $Revision$       $Date$


=head1 DESCRIPTION

Prague Arabic Dependency Treebank
L<http://ufal.mff.cuni.cz/padt/online/2007/01/prague-treebanking-for-everyone-video.html>


=head1 AUTHOR

Otakar Smrz, L<http://ufal.mff.cuni.cz/~smrz/>

    eval { 'E<lt>' . ( join '.', qw 'otakar smrz' ) . "\x40" . ( join '.', qw 'mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright 2005-2007 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
