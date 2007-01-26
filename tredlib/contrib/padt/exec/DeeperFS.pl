#!/usr/bin/perl -w ###################################################################### 2006/03/21

eval 'exec /usr/bin/perl -w ###################################################################### 2006/03/21 -S $0 ${1+"$@"}'
    if 0; # not running under some shell
#
# DeeperFS.pl ########################################################################## Otakar Smrz

# $Id$

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

BEGIN {

    $libDir = `btred --lib`;

    chomp $libDir;

    eval "use lib '$libDir'";
}

use Fslib 1.6;


$decode = "utf8";
$encode = "utf8";

@ARGV = glob join " ", @ARGV;

foreach $file (@ARGV) {

    $target = FSFile->create(

                'FS'        => FSFormat->create(

                    '@P form',
                    '@P afun',
                    '@O afun',
                    '@L afun|Pred|Pnom|PredE|PredC|PredP|Sb|Obj|Adv|Atr|Atv|ExD|Coord|Apos|Ante|AuxS' .
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

                    '@H hide',
                    '@P y_ord',
                    '@P y_parent',
                    '@P y_comment',
                    '@P context',
                    '@L context|---|B|N|C|???',

                    '@P gender',
                    '@L gender|---|ANIM|INAN|FEM|NEUT|NA|???',
                    '@P number',
                    '@L number|---|SG|PL|NA|???',
                    '@P degcmp',
                    '@L degcmp|---|POS|COMP|SUP|NA|???',
                    '@P tense',
                    '@L tense|---|SIM|ANT|POST|NA|???',
                    '@P aspect',
                    '@L aspect|---|PROC|CPL|RES|NA|???',
                    '@P iterativeness',
                    '@L iterativeness|---|IT1|IT0|NA|???',
                    '@P verbmod',
                    '@L verbmod|---|IND|IMP|CDN|NA|???',
                    '@P deontmod',
                    '@L deontmod|---|DECL|DEB|HRT|VOL|POSS|PERM|FAC|NA|???',
                    '@P sentmod',
                    '@L sentmod|---|ENUNC|EXCL|DESID|IMPER|INTER|NA|???',
                    '@P tfa',
                    '@L tfa|---|T|F|C|NA|???',
                    '@P func',
                    '@L func|---|ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|ATT|BEN|CAUS|CNCS|COMPL|COND|CONJ|CONFR|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|DPHR|ETHD|EXT|EV|FPHR|GRAD|HER|ID|INTF|INTT|LOC|MANN|MAT|MEANS|MOD|NA|NORM|OPER|PAR|PARTL|PN|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT|SENT|???',
                    '@P gram',
                    '@L gram|---|0|GNEG|DISTR|APPX|GPART|GMULT|VCT|PNREL|DFR|BEF|AFT|JBEF|INTV|WOUT|AGST|MORE|LESS|MINCL|LINCL|NIL|NA|???',
                    '@P memberof',
                    '@L memberof|---|CO|AP|PA|NIL|???',
                    '@P phraseme',
                    '@P del',
                    '@L del|---|ELID|ELEX|EXPN|NIL|???',
                    '@P quoted',
                    '@L quoted|---|QUOT|NIL|???',
                    '@P dsp',
                    '@L dsp|---|DSP|DSPP|NIL|???',
                    '@P coref',
                    '@P cornum',
                    '@P corsnt',
                    '@L corsnt|---|PREV1|PREV2|PREV3|PREV4|PREV5|PREV6|PREV7|NIL|???',
                    '@P dord',
                    '@P parenthesis',
                    '@L parenthesis|---|PA|NIL|???',
                    '@P recip',
                    '@L recip|---|YES|NO|NIL|???',
                    '@P dispmod',
                    '@L dispmod|---|DISP|NIL|NA|???',
                    '@P trneg',
                    '@L trneg|---|A|N|NA|???',

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

                                (

                                    DeepLevels::isClauseHead() ? '#{Line-fill:gold}' : ''

                                ) . (

                                    $this->{context} eq 'B' ? '#{Node-shape:rectangle}#{Oval-fill:lightblue}' :
                                    $this->{context} eq 'N' ? '#{Node-shape:rectangle}#{Oval-fill:magenta}' :
                                    $this->{context} eq 'C' ? '#{Node-shape:rectangle}#{Oval-fill:blue}' : ''
                                )

                            ?>},

                        q {<? $this->{form} =~ /^./ ? $this->{lemma} =~ /^([^\_]+)/ ?
                                                    $1 : '${form}' : '#{custom6}${origf}' ?>},

                        q {<?

                                join '#{custom5}_', ( $this->{func} eq '???' && $this->{afun} ne '' ?
                                '#{custom3}${afun}' : '#{custom5}${func}' ), ( ( join '_', map {
                                '${' . $_ . '}' } grep { $this->{$_} =~ /^./ && $this->{$_} !~ /^no-/ }
                                qw 'parallel paren arabfa arabspec arabclause' ) || () )

                            ?>},

                        q {<? '#{custom6}${x_comment} << ' if $this->{afun} ne 'AuxS' and $this->{x_comment} ne '' ?>}

                            . '#{custom2}${tag}',

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

        $para = $target->FS()->clone_subtree($tree);

        $root = $target->insert_tree($para, $para_id++);

        $root->{'y_comment'} = $root->{'comment'};
        $root->{'comment'} = gmtime() . " [DeeperFS.pl $VERSION]";

        $root->{'ord'} = 0;

        $root->{'func'} = 'SENT';

        $node = $root;

        while ($node = $node->following()) {

            $node->{'func'} = '???';

            $node->{'y_ord'} = $node->{'ord'};
            $node->{'y_parent'} = $node->parent()->{'ord'};
        }

        foreach $node ($root->descendants()) {

            if ($node->{'afun'} =~ /^Aux/) {

                $node->{'hide'} = 'hide';

                if ($node->children()) {

                    @children = $node->children();

                    foreach $child (reverse @children) {

                        $child = Fslib::Cut($child);

                        Fslib::Paste($child, $node->parent(), $target->FS());
                    }

                    $node = Fslib::Cut($node);

                    Fslib::Paste($node, $children[0], $target->FS());
                }
            }
        }
    }

    $file =~ s/(?:\.syntax)?\.fs$//;
    $target->writeFile($file . '.deeper.fs');
}
