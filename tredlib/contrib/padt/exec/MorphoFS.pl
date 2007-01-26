#!/usr/bin/perl -w ###################################################################### 2004/03/02

eval 'exec /usr/bin/perl -w ###################################################################### 2004/03/02 -S $0 ${1+"$@"}'
    if 0; # not running under some shell
#
# MorphoFS.pl ########################################################################## Otakar Smrz

# $Id$

our $VERSION = do { q $Revision$ =~ /(\d+)/; sprintf "%4.2f", $1 / 100 };

BEGIN {

    $libDir = `btred --lib`;

    chomp $libDir;

    eval "use lib '$libDir'";
}

use Fslib 1.6;

use Encode::Arabic;

use lib 'D:/DevPerl/MorphoMap';
use MorphoMap 1.13;

use lib 'D:/DevPerl/AraMorph';
use AraMorph 2.01;

use lib 'D:/DevPerl/XMorph';
use XMorph;


sub encrypt ($) {

    my $text = $_[0];

    $text =~ s/\&/\&amp\;/g;
    $text =~ s/\>/\&gt\;/g;
    $text =~ s/\</\&lt\;/g;

    return $text;
}

sub decrypt ($) {

    my $text = $_[0];

    $text =~ s/\&lt\;/\</g;
    $text =~ s/\&gt\;/\>/g;
    $text =~ s/\&amp\;/\&/g;

    $text = decode $E, $text if defined $E;

    return $text;
}


$decode = "utf8";
$encode = "utf8";


$regexQ = qr/[0-9]+(?:[\.\,\x{060C}\x{066B}\x{066C}][0-9]+)? |
             [\x{0660}-\x{0669}]+(?:[\.\,\x{060C}\x{066B}\x{066C}][\x{0660}-\x{0669}]+)?/x;

$regexG = qr/[\.\,\;\:\!\?\`\"\'\(\)\[\]\{\}\<\>\\\|\/\~\@\#\$\%\^\&\*\_\=\+\-\x{00AB}\x{00BB}\x{060C}\x{061B}\x{061F}]/;


# ##################################################################################################
#
# ##################################################################################################

@ARGV = glob join " ", @ARGV;

if ($ARGV[0] eq '-E') {

    $E = $ARGV[1];

    splice @ARGV, 0, 2;
}

identify_pronouns();


until (eof()) {


    $file = FSFile->create(

                'FS'        => FSFormat->create(

                                        '@N ord',
                                        '@P type',
                                        '@L type|paragraph|word_node|entity|partition|token_form|lemma_id|token_node',
                                        '@P tips',
                                        '@P inherit',
                                        '@H hide',
                                        '@P restrict',
                                        '@P ref',
                                        '@P par',
                                        '@V input',
                                        '@P input',

                                        map {

                                            '@P ' . $_,

                                            } qw 'solution form morph tag gloss lookup id apply_m apply_t comment'
                                ),

                'hint'      => q {<? '${gloss}' if $this->{type} eq 'token_node' ?>},
                'patterns'  => [

                        'svn: $' . 'Revision' . ': $ $' . 'Date' . ': $',

                        'style:' . q {<?

                                $this->{apply_m} > 0 ? '#{Line-fill:red}' : defined $this->{apply_m} ? '#{Line-fill:black}' : ''

                            ?>},

                        q {<?   '#{magenta}${comment} << ' if $this->{type} !~ /^(?:token_node|paragraph)$/
                                                                                            and $this->{comment} ne '' ?>} .

                        q {<?
                                $this->{type} eq 'token_node'

                                    ? ( '${form}' )

                                    : (

                                    $this->{type} eq 'lemma_id'

                                        ? ( '#{purple}${gloss} #{gray}${id} #{darkmagenta}${form}' )
                                        : (

                                        $this->{type} =~ /^(?:entity|word_node|paragraph)$/

                                            ? (

                                            $this->{apply_m} > 0

                                                ? '#{black}${id} #{gray}${lookup} #{red}${input}'
                                                : '#{black}${id} #{gray}${lookup} #{black}${input}'

                                            )
                                            : ( '${form}' )
                                        )
                                    )
                            ?>},

                        q {<? '#{goldenrod}${comment} << ' if $this->{type} eq 'token_node' and $this->{comment} ne '' ?>} .

                        '#{darkred}${tag}' . q {<?

                                $this->{inherit} eq '' ? '#{red}' : '#{orange}'

                            ?>} . '${restrict}',

                                ],
                'trees'     => [],
                'backend'   => 'FSBackend',
                'encoding'  => $encode,
        );


    $now_time = gmtime;

    $/ = ">";

    ($date, $type) = <> =~ /<DOC (?:doc)?id=\"([^\"]+)\" (?:type|language)=\"([^\"]+)\"/;

    $DOCid = $date . '_' . $type;

    $par_id = 0;

    $word_tree = 0;

    $prev_par = 1;

    $/ = "</";


    until (eof) {

        $_ = decode $decode, scalar <>;

        $meta = $sgml = $data = undef;

        ($meta, $sgml, $data) = m%^(?: [A-Za-z]+ > )? (?: [\ \t\r\n]* < ([^>]+) > )* (?: [\ \t\r\n]* < ([^>]+) > ) ([^<]*) </$%x;

        next unless $sgml and $data;

        $meta = $sgml unless defined $meta;

        $data = decrypt $data;

        @nodes = ();

        while ($data =~ /(?: \G [\ \t\r\n]* ( (?: \p{Arabic} | [\x{064B}-\x{0652}\x{0670}\x{0657}\x{0656}\x{0640}] |
                                                # \p{InArabic} |   # too general
                                               \p{InArabicPresentationFormsA} | \p{InArabicPresentationFormsB} )+ |
                                               \p{Latin}+ |
                                               $regexQ |
                                               $regexG |
                                               [^\ \t\r\n] ) )/gx) {

            $node = {};

            $node->{'input'} = $input = $1;

            if ($input =~ /^$regexQ$/) {

                $node->{'lookup'} = $lookup = encode 'buckwalter', $input;

                $node->{'morpho'} = [ [ "() [DEFAULT] " . ( #encrypt
                                                            $lookup ) . "/NUM", "" ] ];
            }
            elsif ($input =~ /^$regexG$/) {

                $node->{'lookup'} = $lookup = $input;

                $node->{'morpho'} = [ [ "() [DEFAULT] " . ( #encrypt
                                                            $lookup ) . "/PUNC", "" ] ];
            }
            else {

                $node->{'lookup'} = $lookup = encode 'buckwalter', $input;

                $remove = remove_diacritics_buckwalter($lookup);

                @queue = (( $remove eq $lookup ? () : $lookup ), AraMorph::get_variants($remove));

                $score = 0;

                $node->{'morpho'} = [];

                while (@queue) {

                    $lookup = shift @queue;

                    if (@morpho = AraMorph::analyze($lookup)) {

                        $node->{'lookup'} .= ' ' . $lookup;

                        push @{$node->{'morpho'}}, map { [ $morpho[$_][0], $morpho[$_][1] ] } 0 .. @morpho - 1;

                        $score++;
                    }
                }

                unless ($score > 0) {

                    $node->{'morpho'} = [ [ '(' . ( #encrypt
                                                    $node->{'lookup'} ) . ') ' .
                                                  ( #encrypt
                                                    $node->{'lookup'} ) . '/NIL', 'NOT_IN_LEXICON' ] ];
                }

                @lookups = split / /, $node->{'lookup'};

                if (@lookups > 1 and $lookups[0] eq $lookups[1]) {

                    shift @lookups;
                }
                else {

                    $lookups[0] = '[' . $lookups[0] . ']';
                }

                $node->{'lookup'} = join ' ', @lookups;
            }

            push @nodes, $node;
        }

        $this_par = ++$par_id + $word_tree;

        $root = $file->new_tree($this_par - 1);

        $root->{'type'} = 'paragraph';
        $root->{'id'} = "#$par_id";

        $root->{'input'} = ( $meta =~ /^(?: seg (?:\s+id=\"(?: seg \_)?$par_id\")? |
                                            seg (?:\s+id=  (?: seg \_)?$par_id  )? |
                                            p   (?:\s+id=\"(?: p \_)?  [0-9]+ \")? |
                                            p   (?:\s+id=  (?: p \_)?  [0-9]+   )? )$/ix
                                        ? 'TEXT'
                                        : $meta eq 'hl' ? 'HEADLINE' : $meta );

        $root->{'ord'} = $ord = 0;

        $root->{'comment'} = "$DOCid $now_time [MorphoFS.pl $VERSION]";

        foreach $node (@nodes) {

            $wordnode = FSNode->new();

            $wordnode->{'type'} = 'word_node';
            $wordnode->{'input'} = $node->{'input'};
            $wordnode->{'ref'} = ++$word_tree + $par_id;
            $wordnode->{'ord'} = ++$ord;

            Fslib::Paste($wordnode, $root, $file->FS());
        }

        $root->{'par'} = $prev_par . '^';
        $prev_par = $this_par;
        $root->{'par'} .= $word_tree + $par_id + 1;

        $word_in_par = 0;

        foreach $node (@nodes) {

            $root = $file->new_tree(++$word_in_par + $this_par - 1);

            $root->{'type'} = 'entity';
            $root->{'id'} = "#$par_id/" . $word_in_par;
            $root->{'ref'} = $this_par;
            $root->{'ord'} = $ord = 0;

            $root->{$_} = $node->{$_} foreach qw 'input lookup';

            process_node_morpho($node);

            foreach (@{$node->{'token_info'}}) {

                push @{$node->{'partition'}{remove_diacritics(join " ", map { $_->[0] } @{$_}[1 .. @{$_} - 1])}}, $_;
            }

            foreach (sort keys %{$node->{'partition'}}) {

                $partinode = FSNode->new();

                $partinode->{'type'} = 'partition';
                $partinode->{'form'} = $_;
                $partinode->{'ord'} = ++$ord;

                Fslib::Paste($partinode, $root, $file->FS());

                for ($l = 1; $l < @{$node->{'partition'}{$_}->[0]}; $l++) {

                    $morphonode = FSNode->new();

                    $morphonode->{'type'} = 'token_form';
                    $morphonode->{'form'} = remove_diacritics($node->{'partition'}{$_}->[0][$l][0]);
                    $morphonode->{'ord'} = ++$ord;

                    Fslib::Paste($morphonode, $partinode, $file->FS());

                    %repeated = ();
                    %cluster = ();

                    for ($i = 0; $i < @{$node->{'partition'}{$_}}; $i++) {

                        push @{$cluster{$node->{'partition'}{$_}->[$i][$l][4]}}, $node->{'partition'}{$_}->[$i][$l];
                    }

                    foreach (sort keys %cluster) {

                        $lemmanode = FSNode->new();

                        @lem_id = restore_lemma($_);

                        $lemmanode->{'type'} = 'lemma_id';
                        $lemmanode->{'form'} = $lem_id[0];
                        $lemmanode->{'id'} = $lem_id[1];
                        $lemmanode->{'ord'} = ++$ord;

                        $lemmanode->{'gloss'} = join '/', sort keys %{XMorph::analyze(@lem_id)};

                        Fslib::Paste($lemmanode, $morphonode, $file->FS());

                        for ($i = 0; $i < @{$cluster{$_}}; $i++) {

                            foreach $tag (MorphoMap::distinguish_POSVector($cluster{$_}[$i]->[2])) {

                                next if exists $repeated{join " ", $cluster{$_}[$i]->[0], $cluster{$_}[$i]->[4], $tag};

                                $repeated{join " ", $cluster{$_}[$i]->[0], $cluster{$_}[$i]->[4], $tag}++;

                                $tokennode = FSNode->new();

                                $tokennode->{'type'} = 'token_node';
                                $tokennode->{'form'} = $cluster{$_}[$i]->[0];
                                $tokennode->{'morph'} = $cluster{$_}[$i]->[1];
                                $tokennode->{'tag'} = $tag;

                                $tokennode->{'gloss'} = $cluster{$_}[$i]->[3];
                                $tokennode->{'gloss'} =~ s/[\+\ ]+$//;

                                $tokennode->{'ord'} = ++$ord;

                                Fslib::Paste($tokennode, $lemmanode, $file->FS());
                            }
                        }
                    }
                }
            }
        }
    }

    $file->tree($this_par - 1)->{'par'} = join '^', (split /[^0-9]+/, $file->tree($this_par - 1)->{'par'})[0], $this_par;

    $file->writeFile($ARGV . '.morpho.fs');

    printf "%s\t%s\n", $_, $ARGV foreach keys %MorphoMap::AraMorph_POSVector_missing;

    %MorphoMap::AraMorph_POSVector_missing = ();
}


# ##################################################################################################
#
# ##################################################################################################

# process the string of morphological analysis

sub process_node_morpho {

    my ($node) = @_;
    my (@token_info, @morpheme_buffer, @morphemes, @glosses, $lemma_id, $i, $m);

    # $node->{'morpho'} = [];   # to include elements of the form ['translit', 'lemma_id', 'tag', 'gloss', 'number']

    if (exists $node->{'morpho'} and @{$node->{'morpho'}}) {

        # extract the elements out of the analyzer's string

        $node->{'morpho'} = [ map { [

                                        $_->[0] =~ m/^\( ( [^\)]* ) \) \s* ((?: \[ [^\]]* \] )?) \s* (.*)$/x,
                                        $_->[1],
                                        ++$i

                                ] } @{$node->{'morpho'}} ];

        $node->{'token_info'} = [];

        foreach (@{$node->{'morpho'}}) {

            @token_info = ($_->[1]);    # remember the lemma_id

            @morpheme_buffer = ();

            if (defined $_->[2]) {

                $_->[2] =~ s/\s+//g;

                $_->[2] =~ s/\-//g unless $_->[2] eq '-/PUNC';
            }
            else {

                warn "Morpho undefined, token_info = '@token_info', remember = '$remember'\n";

                $_->[2] = "";
            }

            $remember = $_->[1];

            @morphemes = split /\+(?!\/PUNC)/, $_->[2];

            @glosses = split /\s*\+\s*/, $_->[3];   # '+/PUNC' is fine .. no glosses for non-words
            push @glosses, ('') x (@morphemes - @glosses);

            for ($m = 0; $m < @morphemes; $m++) {

                if (MorphoMap::morph_is_prefix($morphemes[$m]) and $m < @morphemes - 1) {

                    # fill the buffer and complete the info on the token being this morpheme

                    $lemma_id = $morphemes[$m];

                    push @morpheme_buffer, [$morphemes[$m], $glosses[$m]];
                    push @token_info, process_morpheme_buffer(\@morpheme_buffer, $lemma_id);
                }
                elsif (MorphoMap::morph_is_suffix($morphemes[$m]) and $m > 0) {

                    # complete the info on the token defined by the previous sequence of morphemes
                    # buffer the current morpheme

                    push @token_info, process_morpheme_buffer(\@morpheme_buffer, $lemma_id);
                    push @morpheme_buffer, [$morphemes[$m], $glosses[$m]];

                    $lemma_id = $morphemes[$m];
                }
                else {

                    # buffer the current morpheme

                    push @morpheme_buffer, [$morphemes[$m], $glosses[$m]];

                    $lemma_id = $token_info[0];
                }
            }

            push @token_info, process_morpheme_buffer(\@morpheme_buffer, $lemma_id);

            push @{$node->{'token_info'}}, [@token_info];
        }

    }
    else {

        warn "Empty token_info, which is highly improbable and risky!\n";

        $node->{'token_info'} = [ [] ];
    }
}


# process the token's morphological information

sub process_morpheme_buffer {

    my ($ref, $lemma) = @_;

    return unless @$ref;

    my $tim = join "+", map { $_->[0] =~ m{^.*/(.*)}; $1 } @$ref;

    my $tag = MorphoMap::AraMorph_POSVector($tim);

    my $morph = join "+", map { $_->[0] =~ m{^(.*)/}; $1 } @$ref;

    $morph =~ tr[{][A];

    $morph =~ s/^\~a$/ya/;
    $morph =~ s/^\~A$/nA/;
    $morph =~ s/^\~iy$/iy/;

    my $token = $morph;

    my $gloss = join " + ", map { $_->[1] } @$ref;

    @$ref = ();

    $lemma =~ tr[{][A];

    $lemma =~ s/\/RC_PART$/\/EMPH_PART/;

    $lemma = identify_pronoun($lemma, $tag);

    $token =~ s/([tknhy])\+\1/$1\~/g;

    $token =~ s/\+at((?:\+[aiuFKN])?)$/\+ap$1/ unless $tag =~ /^V/;

    $token =~ s/A\+a/A/g;

    if ($token =~ /\+/ and $token ne '+') {

        $token =~ s/\+//g;
    }

    if ($token =~ /\-/ and $token ne '-') {

        warn "Reducing '-' in '$token'";
        $token =~ s/\-//g;
    }

    $token = detransliterate($token);

    return [$token, $morph, $tag, $gloss, $lemma, 'f'];
}


sub restore_lemma {

    my ($lemma, $idx) = $_[0] =~ /^\[ ([^\_]*) \_ ([^\]*]) \]$/x;

    ($lemma, $idx) = $_[0] =~ /^([^\/]*) \/ (.*)$/x unless $lemma;

    printf "%s\t%s\n", $lemma, $ARGV if defined $idx and $idx !~ /^(?:PRONOUN|[1-5])$/ and
                                        MorphoMap::AraMorph_POSVector($idx) eq '-' x 10;

    return ( ( decode 'buckwalter', $lemma ), $idx ) if $lemma;

    return $_[0], '?';
}


sub remove_diacritics {

    return $_[0] if $_[0] =~ /^(?:$regexQ|$regexG)$/;

    my $text = encode 'buckwalter', shift;

    $text = remove_diacritics_buckwalter($text);

    return decode 'buckwalter', $text;
}


sub remove_diacritics_buckwalter {

    my $text = shift;

    $text =~ tr[aiuoFKN\~\`\_][]d;

    return $text;
}


sub detransliterate {

    return $_[0] if $_[0] =~ /^(?:$regexQ|$regexG)$/;

    my $text = shift;

    $text =~ s/\(null\)//g;

    $text = decode 'buckwalter', $text;

    $text =~ tr[\x{0671}][\x{0627}];

    return $text;
}


sub identify_pronoun {

    my ($lemma, $idx) = $_[0] =~ /^([^\/]*) \/ (.*)$/x;
    my ($tag) = $_[1];

    if ($tag =~ /^S-/ and defined $lemma) {

        if (exists $pronoun{substr $tag, 0, 8}) {

            return $pronoun{substr $tag, 0, 8} . '/PRONOUN';
        }
        else {

            printf "%s\t%s\n", $_[0], $ARGV;
        }
    }

    return $_[0];
}


sub identify_pronouns {

    %pronoun = (

        'S----1-S'          =>      '>anA',
        'S----2MS'          =>      '>anota',
        'S----2FS'          =>      '>anoti',
        'S----3MS'          =>      'huwa',
        'S----3FS'          =>      'hiya',

        'S----1-P'          =>      'naHonu',
        'S----2MP'          =>      '>anotum',
        'S----2FP'          =>      '>anotun~a',
        'S----3MP'          =>      'hum',
        'S----3FP'          =>      'hun~a',

        'S----2-D'          =>      '>anotumA',
        'S----3-D'          =>      'humA',

    );
}
