#!/usr/bin/perl -w ###################################################################### 2004/04/15
#
# SyntaxFS.pl ########################################################################## Otakar Smrz

# $Id: SyntaxFS.pl,v 1.11 2006/07/14 10:37:23 smrz Exp $

our $VERSION = do { my @r = q$Revision: 1.11 $ =~ /\d+/g; sprintf "%d." . "%02d" x $#r, @r };

use lib 'D:/TrEd/tredlib';
use Fslib 1.5;


$decode = "utf8";
$encode = "utf8";

@ARGV = glob join " ", @ARGV;

foreach $file (@ARGV) {

    $target = FSFile->create(

                'FS'        => FSFormat->create(

                    '@P form',
                    '@P afun',
                    '@O afun',
                    '@L afun|---|Pred|PredC|PredE|PredP|Pnom|Sb|Obj|Atr|Adv|AtrAdv|AdvAtr|Coord|Ref|AtrObj|ObjAtr|AtrAtr' .
                           '|AuxP|Apos|ExD|Atv|Ante|AuxC|AuxO|AuxE|AuxY|AuxM|AuxG|AuxK|AuxX|AuxS|Generated|NA|???',
                    '@P lemma',
                    '@P tag',
                    '@P origf',
                    '@V origf',
                    '@N ord',
                    '@P afunaux',
                    '@P tagauto',
                    '@P lemauto',
                    '@P parallel',
                    '@L parallel|Co|Ap|no-parallel',
                    '@P paren',
                    '@L paren|Pa|no-paren',
                    '@P arabfa',
                    '@L arabfa|Ca|Exp|Fi|no-fa',
                    '@P arabspec',
                    '@L arabspec|Ref|Msd|no-spec',
                    '@P arabclause',
                    '@L arabclause|Pred|PredC|PredE|PredP|Pnom|no-claus',
                    '@P comment',
                    '@P docid',
                    '@P1 warning',
                    '@P3 err1',
                    '@P3 err2',
                    '@P reserve1',
                    '@P reserve2',
                    '@P reserve3',
                    '@P reserve4',
                    '@P reserve5',
                    '@P x_id_ord',
                    '@P x_input',
                    '@P x_lookup',
                    '@P x_morph',
                    '@P x_gloss',
                    '@P x_comment',

                                ),

                'hint'      =>  ( join "\n",

                        'tag:   ${tag}',
                        'lemma: ${lemma}',
                        'morph: ${x_morph}',
                        'gloss: ${x_gloss}',
                        'comment: ${x_comment}',

                        #'comment:  ' . q {<? '${comment}' if $this->{comment} ?>},

                                ),
                'patterns'  => [

                        'svn: $' . 'Revision' . ': $ $' . 'Date' . ': $',

                        'style:' . q {<?

                                $this->{arabclause} =~ /^./ && $this->{arabclause} !~ /^no-/ ||
                                $this->{tag} =~ /^V/ || $this->{afun} =~ /^P/ ? '#{Line-fill:gold}' : ()

                            ?>},

                        q {<? $this->{form} =~ /^./ ? '${form}' : '#{custom6}${origf}' ?>},

                        q {<?

                                join '#{custom1}_', ( $this->{afun} eq '???' && $this->{afunaux} ne '' ?
                                '#{custom3}${afunaux}' : '#{custom1}${afun}' ), ( ( join '_', map {
                                '${' . $_ . '}' } grep { $this->{$_} =~ /^./ && $this->{$_} !~ /^no-/ }
                                qw 'parallel paren arabfa arabspec arabclause' ) || () )

                            ?>},

                        '#{custom2}${tag}',

                        #'#{custom2}' . q {<? $this->{afun} eq 'AuxS' ? '${form}' : '${tag}' ?>},

                                ],
                'trees'     => [],
                'backend'   => 'FSBackend',
                'encoding'  => $encode,
        );

    $source = FSFile->create('encoding' => $decode);

    $source->readFile($file);

    $tree_id = $para_id = 0;

    foreach $tree ($source->trees()) {

        $tree_id++;

        next unless $tree->{'type'} eq 'paragraph';

        $para = $tree;

        $root = $target->new_tree($para_id++);

        $root->{'ord'} = $ord = 0;

        $root->{'afun'} = 'AuxS';

        $root->{'x_id_ord'} = join '_', $para->{'id'}, $tree_id;
        $root->{'form'} = $para->{'id'};

        $root->{'tag'} = $para->{'input'};
        $root->{'origf'} = $para->{'id'};

        $root->{'comment'} = gmtime() . " [SyntaxFS.pl $VERSION]";
        $root->{'x_comment'} = $para->{'comment'};

        $node = $root;

        foreach $entity ($para->children()) {

            if (defined $entity->{'apply_m'} and $entity->{'apply_m'} > 0) {

                $ent = 0;

                foreach $lemma ($entity->children()) {

                    foreach $form ($lemma->children()) {

                        $ref = ($source->tree($entity->{'ref'} - 1)->descendants())[$form->{'ref'} - 1];

                        $token = FSNode->new();

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

                        Fslib::Paste($token, $node, $target->FS());

                        $node = $token;
                    }
                }
            }
            else {

                $ref = $source->tree($entity->{'ref'} - 1);

                $token = FSNode->new();

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

                Fslib::Paste($token, $node, $target->FS());

                $node = $token;
            }
        }
    }

    $file =~ s/(?:\.morpho)?\.fs$//;
    $target->writeFile($file . '.syntax.fs');
}
