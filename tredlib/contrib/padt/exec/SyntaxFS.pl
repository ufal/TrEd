#!/usr/bin/perl -w ###################################################################### 2004/04/15

eval 'exec /usr/bin/perl -w ###################################################################### 2004/04/15 -S $0 ${1+"$@"}'
    if 0; # not running under some shell
#
# SyntaxFS.pl ########################################################################## Otakar Smrz

# $Id: SyntaxFS.pl 480 2008-01-24 16:26:56Z smrz $

use strict;

our $VERSION = do { q $Revision: 480 $ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

BEGIN {

    our $libDir = `btred --lib`;

    chomp $libDir;

    eval "use lib '$libDir', '$libDir/libs/fslib', '$libDir/libs/pml-base'";
}

use Fslib 1.6;


our $decode = "utf8";

our $encode = "utf8";


our ($source, $target, $file, $FStime);


# ##################################################################################################
#
# ##################################################################################################


@ARGV = glob join " ", @ARGV;


foreach $file (@ARGV) {

    $FStime = gmtime;

    $target = FSFile->create(define_target_format());

    $source = FSFile->create('encoding' => $decode);

    $source->readFile($file);

    process_source();

    $file =~ s/(?:\.morpho)?\.fs$//;

    $target->writeFile($file . '.syntax.fs');
}


sub process_source {

    my ($tree_id, $para_id) = (0, 0);

    my ($ord, $ent, $ref);


    foreach my $tree ($source->trees()) {

        $tree_id++;

        next unless $tree->{'type'} eq 'paragraph';

        my $para = $tree;

        my $root = $target->new_tree($para_id++);

        $root->{'ord'} = $ord = 0;

        $root->{'afun'} = 'AuxS';

        $root->{'x_id_ord'} = join '_', $para->{'id'}, $tree_id;
        $root->{'form'} = $para->{'id'};

        $root->{'tag'} = $para->{'input'};
        $root->{'origf'} = $para->{'id'};

        $root->{'comment'} = "$FStime [SyntaxFS.pl $VERSION]";
        $root->{'x_comment'} = $para->{'comment'};

        my $node = $root;

        foreach my $entity ($para->children()) {

            if (defined $entity->{'apply_m'} and $entity->{'apply_m'} > 0) {

                $ent = 0;

                foreach my $lemma ($entity->children()) {

                    foreach my $form ($lemma->children()) {

                        $ref = ($source->tree($entity->{'ref'} - 1)->descendants())[$form->{'ref'} - 1];

                        my $token = FSNode->new();

                        $token->{'ord'} = ++$ord;

                        $token->{'afun'} = '???';

                        $token->{'form'} = $ref->{'form'};
                        $token->{'tag'} = $ref->{'tag'};
                        $token->{'lemma'} = join '_', map { defined $_ ? $_ : '' } @{$ref->parent()}{'form', 'id'};

                        $token->{'x_gloss'} = $ref->{'gloss'};
                        $token->{'x_comment'} = $ref->{'comment'};
                        $token->{'x_morph'} = $ref->{'morph'};

                        $token->{'x_id_ord'} = join '_', $ref->root()->{'id'}, $ref->{'ord'};
                        $token->{'x_lookup'} = $ref->root()->{'lookup'};
                        $token->{'x_form'} = $ref->parent()->parent()->{'form'};

                        $token->{'origf'} = $ref->root()->{'input'} unless $ent++;

                        $token->paste_on($node, 'ord');

                        $node = $token;
                    }
                }
            }
            else {

                $ref = $source->tree($entity->{'ref'} - 1);

                my $token = FSNode->new();

                $token->{'ord'} = ++$ord;

                $token->{'afun'} = '???';

                $token->{'form'} = '';
                $token->{'tag'} = '';
                $token->{'lemma'} = '';

                $token->{'x_gloss'} = '';
                $token->{'x_comment'} = $ref->{'comment'};
                $token->{'x_morph'} = '';

                $token->{'x_id_ord'} = $ref->{'id'};
                $token->{'x_lookup'} = $ref->{'lookup'};
                $token->{'x_form'} = '';

                $token->{'origf'} = $ref->root()->{'input'};

                $token->paste_on($node, 'ord');

                $node = $token;
            }
        }
    }
}


sub define_target_format {

    return (

        'FS'        => FSFormat->create(

            '@P form',
            '@P afun',
            '@O afun',
            '@L afun|Pred|Pnom|PredE|PredC|PredM|PredP|Sb|Obj|Adv|Atr|Atv|ExD|Coord|Apos|Ante|AuxS' .
                   '|AuxC|AuxP|AuxE|AuxM|AuxY|AuxG|AuxK|ObjAtr|AtrObj|AdvAtr|AtrAdv|AtrAtr|???',
            '@P lemma',
            '@P tag',
            '@P origf',
            '@V origf',
            '@N ord',
            '@P afunaux',
            '@P tagauto',
            '@P lemauto',
            '@P parallel',
            '@L parallel|Co|Ap',
            '@P paren',
            '@L paren|Pa',
            '@P arabfa',
            '@L arabfa|Ca|Exp|Fi',
            '@P arabspec',
            '@L arabspec|Ref|Msd',
            '@P arabclause',
            '@L arabclause|Pred|Pnom|PredE|PredC|PredM|PredP',
            '@P comment',
            '@P docid',
            '@P1 warning',
            '@P3 err1',
            '@P3 err2',
            '@H hide',

            map {

                '@P ' . $_,

                } qw 'reserve1 reserve2 reserve3 reserve4 reserve5',
                  qw 'x_id_ord x_input x_lookup x_morph x_gloss x_comment'

                        ),

        'hint'      =>  ( join "\n",

                'tag:   ${tag}',
                'lemma: ${lemma}',
                'morph: ${x_morph}',
                'gloss: ${x_gloss}',
                'comment: ${x_comment}',

                        ),
        'patterns'  => [

                'svn: $' . 'Revision' . ': $ $' . 'Date' . ': $',

                'style:' . q {<?

                        Analytic::isClauseHead() ? '#{Line-fill:gold}' : ''

                    ?>},

                q {<? $this->{form} ne '' ? '${form}' : '#{custom6}${origf}' ?>},

                q {<?

                        join '#{custom1}_', ( $this->{afun} eq '???' && $this->{afunaux} ne '' ?
                        '#{custom3}${afunaux}' : '#{custom1}${afun}' ), ( ( join '_', map {
                        '${' . $_ . '}' } grep { $this->{$_} ne '' }
                        qw 'parallel paren arabfa arabspec arabclause' ) || () )

                    ?>},

                q {<? '#{custom6}${x_comment} << ' if $this->{afun} ne 'AuxS' and $this->{x_comment} ne '' ?>}

                    . '#{custom2}${tag}',

                        ],
        'trees'     => [],
        'backend'   => 'FSBackend',
        'encoding'  => $encode,

    );
}


__END__


=head1 NAME

SyntaxFS - Generating Analytic given a list of input MorphoTrees documents


=head1 REVISION

    $Revision: 480 $       $Date: 2008-01-24 17:26:56 +0100 (Thu, 24 Jan 2008) $


=head1 DESCRIPTION

Prague Arabic Dependency Treebank
L<http://ufal.mff.cuni.cz/padt/online/2007/01/prague-treebanking-for-everyone-video.html>


=head1 AUTHOR

Otakar Smrz, L<http://ufal.mff.cuni.cz/~smrz/>

    eval { 'E<lt>' . ( join '.', qw 'otakar smrz' ) . "\x40" . ( join '.', qw 'mff cuni cz' ) . 'E<gt>' }

Perl is also designed to make the easy jobs not that easy ;)


=head1 COPYRIGHT AND LICENSE

Copyright 2004-2008 by Otakar Smrz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
