package ZZParser::CzechDepParser;

# Czech Dependency Parser written by Zdenek Zabokrtsky

use utf8;
use strict;
use vars qw ($root);

use Fslib;

binmode STDOUT,":encoding(iso-8859-2)";

# package CzechDepParser;

# use Exporter;
# use strict;
# use vars qw($VERSION @ISA @EXPORT_OK);
# use utf8;

# BEGIN {
#   $VERSION = '1.0';
#   @ISA=qw(Exporter);
#   @EXPORT_OK=qw(fs_parse parse);
# }

# --------- global parameters -------------

my $debug=0;                    # print info for debugging

my $deadlooplimit=10000;
my $loopcnt;
my $save_partial_as_csts=0;

my $fsfile;

# ---------- initialing hashes and loading external probability dictionaries -----------

#my $dict_dir='/home/zabokrtsky/projects/DependencyParsers/Czech/Version1/Extract_dictionaries';
my $dict_dir = $ENV{TMT_ROOT}."/libs/other/ZZParser/Extracted_dictionaries/";

my %val_prob;                   # probability valency
my %personal_roles;
my %adv_adj;
my %numbered_noun;
my %refl_tantum;
my %named_entity;
my %short_sentence_patterns;
my %extracted_lex_ngrams;
my %extracted_mildly_lex_ngrams;
my %extracted_adv_adv;
my %adv_adv;

sub load_external_dict {

    open V,"<:encoding(iso-8859-2)","$dict_dir/valency-prob";
    while (<V>) {
        chomp;
        my ($pos,$lemma,$form,$prob)=split /\t/;
        $val_prob{$pos}{$lemma}{$form}=$prob;
    }
    close V;
    $val_prob{N}{zákon}{o}=10;


    open V,"<:encoding(iso-8859-2)","$dict_dir/joined-personal-roles2";
    while (<V>) {
        chomp;
        $personal_roles{$_}=1;
    }
    close V;

    open V,"<:encoding(iso-8859-2)","$dict_dir/Named-Entities";
    while (<V>) {
        chomp;
        my ($named_ent)=split /\t/;
        $named_entity{$named_ent}=1;
    }
    close V;


    open V,"<:encoding(iso-8859-2)","$dict_dir/Adv-Adj";
    while (<V>) {
        chomp;
        $adv_adj{$_}=1;
    }
    close V;

    open V,"<:encoding(iso-8859-2)","$dict_dir/Numbered-nouns" or die "Can't open Numbered nouns!\n";;
    while (<V>) {
        chomp;
        my ($noun,$cnt)=split/\t/;
        $numbered_noun{$noun}=1;
    }
    close V;


    open V,"<:encoding(iso-8859-2)","$dict_dir/refl-tantum-ze-ssjc";
    while (<V>) {
        chomp;
        $refl_tantum{$_}=1;
    }
    close V;


    my $cnt;
    open V,"<:encoding(iso-8859-2)","$dict_dir/short_sentence_patterns";
    while (<V>) {
        chomp;
        if (/\s*(\d+)\s*(\S.+)\t(.+)/) {
            if ($1>0) {
                $short_sentence_patterns{$2}=$3;

                $cnt++;
            }
        }
    }
    close V;

    open V,"<:encoding(iso-8859-2)","$dict_dir/extracted_lex_ngrams";
    while (<V>) {
        chomp;
        my ($ngram,$tree)=split /\t/;
        $extracted_lex_ngrams{$ngram}=$tree;
    }
    close V;

    open V,"<:encoding(iso-8859-2)","$dict_dir/extracted_mildly_lex_ngrams";
    while (<V>) {
        chomp;
        my ($ngram,$tree)=split /\t/;
        $extracted_mildly_lex_ngrams{$ngram}=$tree;
    }
    close V;

    open V,"<:encoding(iso-8859-2)","$dict_dir/extracted_adv_adv";
    while (<V>) {
        chomp;
        my ($lemma,$cnt)=split /\t/;
        $adv_adv{$lemma}=$cnt;
    }
    close V;

}


# ----------- interface to the tagset ----------------



sub noun($) {
    return ($_[0]->{p_eff_tag}=~/^(N|Cy)/);
}

sub nominal($) {
    return (($_[0]->{p_eff_tag}=~/^(N|.[PH59L4y])/) or ($_[0]->{p_eff_tag}=~/^P[WZ]/ and $_[0]->{p_eff_lemma}!~/ý$/));
}

sub adverb($) {
    return ($_[0]->{p_eff_tag}=~/^D/);
}


sub adjectival($) {
    my $n=shift;
    return ($n->{p_eff_tag}=~/^.[48ADGLSUWZrwz1]/ or $n->{p_ordinal});

    # || ($$T[$node]{lemma} eq "tzv" && children($T,$node)));
}


sub adjo($) {                   # cesko(-madarsky)
    return ($_[0]->{p_eff_tag}=~/^A2/);
}

sub transgres_adj($) {          # potapejici
    return ($_[0]->{p_eff_tag}=~/^AG/);
}


sub verb($) {
    return ($_[0]->{p_eff_tag}=~/^V/);
}

sub vfin($) {
    return ($_[0]->{p_eff_tag}=~/^V[Bp]/);
}

sub verb_passive($) {
    return ($_[0]->{p_eff_tag}=~/^Vs/);
}

sub past_participle($) {
    return ($_[0]->{p_eff_tag}=~/^Vp/);
}

sub present_tense($) {
    return ($_[0]->{p_eff_tag}=~/^V.......P/);
}

sub future_tense($) {
    return ($_[0]->{p_eff_tag}=~/^V.......F/);
}

sub infinitive($) {
    return ($_[0]->{p_eff_tag}=~/^Vf/);
}


sub adjective($) {
    return ($_[0]->{p_eff_tag}=~/^A/);
}

sub pron_poss_rel($){
    return ($_[0]->{p_eff_tag}=~/^P1/);
}


sub arab_digit($) {
    return ($_[0]->{p_eff_tag}=~/^C=/);
}

sub roman_digit($) {
    return ($_[0]->{p_eff_tag}=~/^C\}/);
}


sub numeral($) {
    return ($_[0]->{p_eff_tag}=~/^C/);
}

sub num_multiple($){
    return ($_[0]->{p_eff_tag}=~/^Cv/);
}

sub basnumeral_4($) {
    return ($_[0]->{p_eff_tag}=~/^Cl/);
}

sub basnumeral_5($) {
    return ($_[0]->{p_eff_tag}=~/^Cn/);
}

sub basnumeral($) {
    return ($_[0]->{p_eff_tag}=~/^C[nl]/);
}

sub indef_numeral($) {
    return ($_[0]->{p_eff_tag}=~/^Ca/);
}

sub pron_demon($) {
    return ($_[0]->{p_eff_tag}=~/^PD/);
}


sub preposition($) {
    return ($_[0]->{p_eff_tag}=~/^R/);
}


sub surname($) {
    return ($_[0]->{p_suffix}=~/;S/)
}

sub geographic($) {
    return ($_[0]->{p_suffix}=~/;G/)
}

sub firstname($) {
    return ($_[0]->{p_suffix}=~/;Y/)
}


sub relative($) {
    $_[0]->{p_eff_tag}=~/^.[149EJK\?]/;
}

sub subord_conj($) {
    $_[0]->{p_eff_tag}=~/^J,/;
}

sub coord_conj($) {
    return ($_[0]->{p_eff_tag}=~/^J\^/ and $_[0]->{p_lemma}!~/^(však|ovšem)$/);
}

sub comparative($) {
    $_[0]->{p_eff_tag}=~/^.........2/;
}

sub superlative($) {
    $_[0]->{p_eff_tag}=~/^.........3/;
}


sub multip_num($){
    $_[0]->{p_eff_tag}=~/^Cv/;
}


sub to_be($) {
    if ($_[0]->{p_eff_lemma} eq "být") {
        return 1
    } else {
        return
    }
}


sub subpos($) {
    $_[0]->{p_eff_tag}=~/^.(.)/;
    return $1;
}

sub gender($) {
    $_[0]->{p_eff_tag}=~/^..(.)/;
    return $1;
}

sub number($) {
    $_[0]->{p_eff_tag}=~/^...(.)/;
    return $1;
}

sub poss_gender($) {
    $_[0]->{p_eff_tag}=~/^.....(.)/;
    return $1;
}

sub poss_number($) {
    $_[0]->{p_eff_tag}=~/^......(.)/;
    return $1;
}



sub case($) {
    $_[0]->{p_eff_tag}=~/^....(.)/;
    return $1;
}

sub person($) {
    $_[0]->{p_eff_tag}=~/^.......(.)/;
    return $1;
}

sub refl_sesi($) {
    return ($_[0]->{p_eff_tag}=~/^P7/);
}



sub personal_name($) {
    return ($_[0]->{p_form}=~/^[A-ZŘÚČŠŽ][a-záéíěůžščř][a-záéíěůžščř]/ and noun($_[0]))
}


sub punctuation($) {
    return ($_[0]->{p_eff_tag}=~/^Z/);
}



# 'i' jsem zatim vyhodil, kazilo to koordinace
sub rhematizer($) {
    return ($_[0]->{p_eff_lemma}=~/^(akorát|alespoň|aspoň|ani|asi|aspoň|bezmála|cca|celkem|dohromady|dokonce|hlavně|hned|jakoby|jedině|jen|jenom|ještě|již|jmenovitě|kupříkladu|leda|málem|maximálně|minimálně|ne|nanejvýš|například|např|nejen|nejvíce|pouze|právě|prostě|především|přesně|přímo|přinejmenším|rovněž|rovnou|skoro|snad|sotva|spíš|spíše|také|takříkajíc|takřka|taktéž|také|taky|téměř|teprve|též|toliko|třeba|už|vůbec|zase|zcela|zejména|zhruba|zrovna|zřejmě|zvláště)$/);
}


# ---------- agreement ----------------

sub agr_gender($$) {
    my ($val1,$val2)=map {gender($_)} (@_);
    return ($val1 eq $val2 or $val1.$val2=~/(\-.|.\-|YM|YI|MY|IY|Z[HIMNTXY]|[HIMNTXY]Z|H[NF]|[NF]H)/);
}

sub agr_number($$) {
    my ($val1,$val2)=map {number($_)} (@_);
    return ($val1 eq $val2 or $val1 eq "X" or $val2 eq "X");
}

sub agr_case($$) {
    my ($val1,$val2)=map {case($_)} (@_);
    return ($val1 eq $val2 or $val1 eq "X" or $val2 eq "X");
}

sub agr_gnc($$) {
    my ($a,$b)=@_;
    return (agr_gender($a,$b) and agr_number($a,$b) and agr_case($a,$b));
}


sub rel_agr_number($$) {
    my ($antec,$rnode) = @_;
    my  $val1=number($antec);
    my $val2;
    if (pron_poss_rel($rnode)) {
        $val2=poss_number($rnode);
    } else {
        $val2=number($rnode);
    }
    return ($val1 eq $val2 or $val1 eq "X" or $val2 eq "X");
}

sub rel_agr_gender($$) {
    my ($antec,$rnode) = @_;
    my  $val1=gender($antec);
    my $val2;
    if (pron_poss_rel($rnode)) {
        $val2=poss_gender($rnode);
    } else {
        $val2=gender($rnode);
    }
    report_line( "antec:$antec->{p_form} val1=$val1   rnode:$rnode->{p_form} val2=$val2");
    return ($val1 eq $val2 or $val1 eq "X" or $val2 eq "X" or ($val1.$val2)=~/^(\-.|.\-|YM|YI|MY|IY|Z[HIMNTXY]|[HIMNTXY]Z|H[NF]|[NF]H)$/);
}



# ---------- auxiliary technical functions ----------------

sub CutPaste($$) {
    my ($node,$new_parent) = @_;
    if ($node->parent) {
        Fslib::Cut($node);
    }
    #  Fslib::Paste($node,$new_parent);
    Fslib::Paste($node,$new_parent,$fsfile->FS());
}


sub prevent_looping {
    if ($loopcnt++>$deadlooplimit) {
        print STDERR "ERROR: looping detected!!\n";
        print "ERROR: looping detected!!";
        #    exit;
        ###    TredMacro::NPosition;
        return 1;
    }
}


sub min(@) {
    if ($_[0]<$_[1]) {
        return $_[0];
    } else {
        return $_[1];
    }
}


sub report($) {
    prevent_looping();
    print shift() if $debug;
}

sub report_line($) {
    prevent_looping();
    print shift()."\n" if $debug;
}



sub print_csts {
    print "CSTS\t<s id='xx'>\n";
    foreach my $n (sort { $a->{ord} <=> $b->{ord} } $root->descendants) {
        print "CSTS\t<f>$n->{p_form}<l>X<t>X<A>Atr<r>$n->{ord}<g>".$n->parent->{ord}."\n";
    }
}


    sub hang($$$) {
        my ($node,$parent,$rule)=@_;
        report_line "hanging $node->{p_form}(eff $node->{p_eff_form}) below $parent->{p_form}(eff $parent->{p_eff_form}) by rule $rule";
        #  if (not eval{
        CutPaste($node,$parent)
            #  }) {
            #    report_line "ERROR: can't past node $node->{p_eff_form} below $parent->{p_eff_form}";
            #    return 0
            #  }
            ;
        $node->{p_rule} = $rule;

        if (relative($node)) {  # remembering relative descendant
            $parent->{p_rel_desc}=$node;
        } elsif ($node->{p_rel_desc}) { # and propagating it higher
            $parent->{p_rel_desc}=$node->{p_rel_desc};
        }

        # propagating rightcomma upward
        if ($node->{p_rightcomma} and before($parent,$node) and not grep{before($node->{p_rightcomma},$_)} $parent->children) {
            $parent->{p_rightcomma}=$node->{p_rightcomma}
        }
        #  else {  # dodelat
        #  }

        report_line("hanged");
        if ($save_partial_as_csts) {
            print_csts;
        }
        return 1;
    }


sub before($$) {                # node1 preceeds node2 in the sentence
    my ($node1,$node2) = @_;
    return ($node1->{ord}<$node2->{ord});
}


sub derived_lemma($) {
    my $node=shift;
    my $lemma=$node->{p_lemma};
    my $suffix=$node->{p_suffix};
    if ($suffix=~/\(\*(\d)([^\)]+)/) {
        my $cnt=$1;
        my $newending=$2;
        foreach (1..$cnt) {
            $lemma=~s/.$//;
        }
        $lemma .= $newending;
        report_line "derived lemma: $lemma (from $node->{p_lemma})";
        return $lemma;
    }
    return 0;

}

sub descendant_of($$) {
    my ($node1,$node2)=@_;
    return (grep {$_ eq $node1} ($node2,$node2->descendants))
}


# ------ short sentence patterns -------------

sub node2abbrev($) {
    my $node=shift;
    if ($node->attr('m/tag')=~/^[ZJR]/) {
        return lc($node->attr('m/form'))
    } else {
        my $suffix;
        if ($node->attr('m/lemma')=~/\_.*;([A-Z])/) {
            $suffix=";$1";
        }
        return $node->attr('m/tag').$suffix;
    }
}


sub sentence_pattern($) {
    my $root=shift;
    return (join " ", map{node2abbrev($_)} sort {$a->{ord}<=>$b->{ord}} sort {$a->{ord}<=>$b->{ord}} $root->descendants);
}


sub apply_short_sentence_patterns($) {
    my $root = shift;
    my @descendants = sort {$a->{ord}<=>$b->{ord}} $root->descendants;
    report_line "apply_short_sentence_patterns:";
    if (@descendants<8 and @descendants>1) {
        my $pattern = sentence_pattern($root);
        my $tree=$short_sentence_patterns{$pattern};
        report_line "Sentence pattern: $pattern    tree: $tree";
        if ($tree) {
            my @parents=split / /,$tree;
            unshift @descendants,$root;
            foreach my $i (1..$#descendants) {
                #	report_line "parent index: $parents[$i]";
                hang($descendants[$i],$descendants[$parents[$i-1]],'short sentence patterns')
            }
            report_line "Sentence pattern $tree applied";
            report_line (join " ",map{$_->attr('m/form')} @descendants)."\n\n";
            return 1;
        }
    }
    return 0;
}


my $maxlen=6;

sub apply_lexicalized_ngrams($) {
    my $root = shift;
    my @nodes = sort {$a->{ord}<=>$b->{ord}} $root->descendants;
    foreach my $from (0 .. $#nodes-1) {
        foreach my $to ( $from+1 , min($#nodes, $from+$maxlen) ) {
            my @window=@nodes[$from..$to];
            my $string = join " ",map{$_->{p_form}} @window;
            my $tree=$extracted_lex_ngrams{$string};
            if ($tree) {
                report_line "lexicalized ngram: $string";
                my @parents=split / /,$tree;
                foreach my $i (0..$#window) {
                    if ($parents[$i] ne "X") {
                        my $parent=$nodes[$window[$i]->{ord}+$parents[$i]-1];
                        $window[$i]->{p_lex_ngram}=$parent;
                        #	    hang($window[$i],$parent,'lex ngrams') if not preposition($parent);
                        #	    if (preposition($parent)) {
                        #	      $parent->{p_saturated}=1;
                        #	    }
                    }
                }
            }
        }
    }
}



sub apply_mildly_lexicalized_ngrams($) {
    my $root = shift;
    my @nodes = sort {$a->{ord}<=>$b->{ord}} $root->descendants;
    foreach my $from (0 .. $#nodes-1) {
        foreach my $to ( $from+1 , min($#nodes, $from+$maxlen) ) {
            my @window=@nodes[$from..$to];
            my $string = join " ",map{node2string($_)} @window;
            my $tree=$extracted_mildly_lex_ngrams{$string};
            if ($tree) {
                report_line "mildly lexicalized ngram: $string";
                my @parents=split / /,$tree;
                foreach my $i (0..$#window) {
                    if ($parents[$i] ne "X") {
                        if (not $window[$i]->{p_rule}) {
                            my $parent=$nodes[$window[$i]->{ord}+$parents[$i]-1];
                            $window[$i]->{p_mlex_ngram}=$parent;
                            #	      hang($window[$i],$parent,'lex ngrams');
                            #	      if (preposition($parent)) {
                            #		$parent->{p_saturated}=1;
                            #	      }
                        }
                    }
                }
            }
        }
    }
}


sub node2string($) {
    my $node = shift;
    my $tag=$node->attr('m/tag');
    my $form=$node->attr('m/form');
    my $lemma=$node->attr('m/lemma');
    my $shortlemma=$lemma;
    $shortlemma=~s/([\_\-\'\`].+)//;
    my $suffix=$1;

    if ($tag=~/^Z/) {
        return $form;
    } elsif ($tag=~/^(R|J|T|Db)/) {
        return $shortlemma;
    } elsif ($shortlemma eq "být") {
        return $shortlemma
    } else {
        my $reduced_tag=$tag;
        $reduced_tag=~s/^(..........).(.)/$1$2/; # vypusteni negace
        if ($tag=~/^P/ and $shortlemma=~/([ýí])$/) { # rozliseni substantivnich a adjektivnich zajmen
            $reduced_tag .= $1;
        }
        if ($suffix=~/;([A-Z])/) {
            $reduced_tag .= ";$1";
        }
        return $reduced_tag;
    }
}


# --------- clause segmentation ----------------

my %node2segment;
my %first_in_segment;

my @segments;
my %segment_type;
my %soft_left_separator; # soft (potential) separator = already attached right comma

sub recompute_segmentation($) {
    return if prevent_looping();
    my $nodes = shift;
    @segments = ();
    report "recompute_segmentation: ";
    %node2segment = ();
    %soft_left_separator=();
    my $segment_number;
    my $state = 0;         # three-state automaton: 0, separator, word

    foreach my $node (@$nodes) {

        my $newstate;
        if ($node->{p_eff_tag}=~/^(Z|J\^)/ and $node->{p_lemma} ne "však"
                and not $node->{p_saturated}
                    and not $node->{p_nonseparator}
                        and not $node->{p_sport_score}
                            and not $node->{p_dsp_root}
                                and not $node->{p_parenthesed}
                            ) { # separator
            $newstate='separator';
            $node->{p_separator}=1;
        } else {
            $newstate='word';
            $node->{p_separator}=0;
        }

        if ($state ne $newstate) { # start new segment
            $segment_number++;
            $segment_type{$segment_number}=$newstate;
            $segments[$segment_number]=[$node];
            if ($state eq 0) {
                $soft_left_separator{$segment_number}=1;
            }
        } else {                # add to the last segment
            push @{$segments[$segment_number]},$node;
        }

        $node2segment{$node} = $segment_number;
        $state = $newstate;

        if ($node->{p_rightcomma}) {
            $state = 0;
        }

    }

    foreach my $segment_number (1..$#segments) {
        report " <Seg=$segment_number> ";
        foreach my $node (@{$segments[$segment_number]}) {
            report "$node->{p_eff_form} ";
        }
    }
    report_line "";

}

sub node2segment ($) {          # to which segment the node belongs to
    my $node = shift;
    if (not eval{$node->parent or 1}) {
        report_line("node2segment: argument must be a node");
        die "node2segment: argument must be a node\n";
    }
    my $segment = $node2segment{$node};
    if ($segment) {
        return $segment
    } else {
        while ($node=$node->parent) { # pokud uzel nema sam cislo segmentu, tak se zkousi predci (nemelo by se stat);
            if ($node2segment{$node}) {
                return $node2segment{$node}
            }
        }
        report_line("node $node->{p_eff_form} not belonging to any segment");
        die "node2segment: node $node not belonging to any segment\n";
    }
}

sub segment2nodes ($) { # return the ref. to the array of nodes in the given segment
    my $segment_number = shift;
    if ($segment_number<1 or $segment_number>$#segments) {
        die "segment2nodes: segment number $segment_number outside the range (1..$#segments)\n";
    } else {
        return @{$segments[$segment_number]};
    }
}

sub node2segmentnodes($) {
    my $node = shift;
    return (grep {not $_->{p_rule}} segment2nodes(node2segment($node)));

}


sub segment_start ($) {
    my $node = shift;
    if (grep {$_->{ord}<$node->{ord}} node2segmentnodes($node)) {
        return 0
    } else {
        return 1
    }
}

sub word_segments() {
    return (map {$segments[$_]} grep{$segment_type{$_} eq "word"} (1..$#segments));
}


sub sure_clause_boundary($) {

}


sub try_to_cancel_next_soft_separator($) {
    my $node=shift;
    report_line("try_to_delete_soft_separator():  node=$node->{p_eff_form}");
    my $seg_number=node2segment($node);
    if ($#segments>$seg_number) {
        my ($first_right)=(segment2nodes($seg_number+1));
        if (joinable_segments($node,$first_right)) {
            foreach (segment2nodes($seg_number)) {
                undef $_->{p_rightcomma};
            }
            return 1;
        }
        return 0
    }
    return 0
}


# --------- functions related to coordination --------------

#   my $verbs=(join " ",sort grep {$_=~/V[Bpc]/ }   map {$$T[$_]{tag}=~/^(..)/;$1} @nodes);

#   my ($byt)= grep {$$T[$_]{tag}=~/^V[Bpc]/ && $$T[$_]{lemma} eq "být" } @nodes;
#   my $verbs_tmp=(join " ", map {$$T[$_]{tag}=~/^V[Bpc]/;} @nodes);
# #    print STDERR "one_clause verbs: $verbs  uzly: $verbs_tmp  z ( ".(join " ",sort @nodes)." )\n";
#   if ($verbs eq "") {
#     return "none vfin";
#   }
#   ;
#   if (($verbs eq "VB") # present or future tense, e.g.: volam, zavolam, budu volat
#       || ($verbs eq "Vp")	# simple past tense
#       || ($verbs eq "VB Vp" && $byt && $$T[$byt]{form}=~/^[Jj]s/) # volal jsem
#       || ($verbs eq "Vc Vp")	# volal bych
#       || ($verbs eq "Vc Vp Vp" and # byl bych volal
# 	  (grep {$$T[$_]{tag}=~/Vp/ and $$T[$_]{lemma} eq "být"} @nodes)==1)) {
#     #    print STDERR "one_clause: $verbs    ok\n";
#     return "one vfin";

#   }

sub plausible_vfin($) {
    my $nodes = shift;
    my $hash = (join " ", sort map{$_->{p_eff_tag}=~/^(..).....(..)/;$1.$2.to_be($_)} grep{$_->{p_eff_tag}=~/^V[Bpci]/}
                    grep{not $_->{p_rc_head}} @$nodes);
    report_line("plausible_vfin: $hash");
    return ($hash =~ /^(|VB..1?|Vp..1?|Vi..1?|VB[12]P1 Vp..1?|Vc..1 Vp..1?|Vc..1 Vp.. Vp..1)$/ );
    #  if (($verbs eq "VB") # present or future tense, e.g.: volam, zavolam, budu volat
    #      || ($verbs eq "Vp")	# simple past tense
    #      || ($verbs eq "VB Vp" && $byt && $$T[$byt]{form}=~/^[Jj]s/) # volal jsem
    #      || ($verbs eq "Vc Vp")	# volal bych
    #      || ($verbs eq "Vc Vp Vp" and # byl bych volal
}


sub joinable_segments($$) {
    my ($node1,$node2) = @_;
    my @segment1 = node2segmentnodes($node1);
    my @segment2 = node2segmentnodes($node2);
    report_line ("joinable_segments:  s1: ".(join " ",map{$_->{p_eff_form}} @segment1)."     s2: ".(join " ",map{$_->{p_eff_form}} @segment2));
    return plausible_vfin ( [@segment1, @segment2] );
    #  if ((grep {$_->{p_eff_tag}=~/^V[Bp]/} (@segment1,@segment2))>1) {
    #    return 0
    #  }
    #  else {
    #    return 1;
    #  }
}


sub coordinability($$) {
    my ($left,$right)=@_;
    if ((((nominal($left) and nominal($right)) or (adjectival($left) and adjectival($right))) and agr_case($left,$right))
            or (arab_digit($left) and arab_digit($right))
                or (roman_digit($left) and roman_digit($right))
                    or (adverb($left) and adverb($right))
                        or (infinitive($left) and infinitive($right))
                            or (preposition($left) and $left->{p_saturated} and preposition($right) and $right->{p_saturated})
                                or (subord_conj($left) and $left->{p_saturated} and subord_conj($right) and $right->{p_saturated}
                                        and not $left->{p_parenthesed} and not $right->{p_parenthesed})
                                    #      or ($left->{p_rc_head} and not $left->{p_rightcomma} and $right->{p_rc_head}) ???
                            ) {
        return 1
    }
    #  if (subpos($left) eq subpos($right)) {
    #    return 1;
    #  }
    else {
        return 0
    }
}

sub simulate_eff($$) { # node1 "inherits" the effective attributes of $node2
    my ($node1,$node2)=@_;
    foreach my $attr (grep {/^p_eff/} keys %$node2) {
        $node1->{$attr}=$node2->{$attr};
    }
}


sub left_edge_descendants($) {
    my $node = shift;
    my ($leftmostchild) = sort {$a->{ord}<=>$b->{ord}} grep {$_->{ord}<$node->{ord}} $node->children;
    if ($leftmostchild) {
        return ($leftmostchild, left_edge_descendants($leftmostchild))
    } else {
        return ()
    }
}

sub right_edge_descendants($) {
    my $node = shift;
    my ($rightmostchild) = sort {$b->{ord}<=>$a->{ord}} grep {$_->{ord}>$node->{ord}} $node->children;
    if ($rightmostchild) {
        return ($rightmostchild, right_edge_descendants($rightmostchild))
    } else {
        return ()
    }
}


# --------- simple (non-recursive) rules ----------------

sub rule_ordinal_dot($) {
    my $win = shift;
    if ((arab_digit($win->[0]) or roman_digit($win->[0])) and $win->[1]->{p_form} eq ".") {
        $win->[0]->{p_ordinal}=1;
        hang($win->[1],$win->[0],'rule_ordinal_dot');
        return 'resegment';
    }
    return 0;
}

sub rule_sport_score($) {
    my $win = shift;
    if (arab_digit($win->[0]) and arab_digit($win->[2]) and $win->[1]->{p_form} eq ":") {
        hang($win->[0],$win->[1],'rule score 1');
        hang($win->[2],$win->[1],'rule score 2');
        $win->[1]->{p_sport_score}=1;
        return 1;

    }
    return 0;
}

sub rule_potapejici_se($) {
    my $win = shift;
    if (transgres_adj($win->[0]) and refl_sesi($win->[1])) {
        hang($win->[1],$win->[0],'potapejici se');
        return 1;

    }
    return 0;
}


sub rule_country_country($) {
    my $win = shift;
    if (geographic($win->[0]) and geographic($win->[2]) and $win->[1]->{p_form} eq "-") {
        hang($win->[2],$win->[0],'country-country');
        hang($win->[1],$win->[2],'country-country');
        $win->[1]->{p_sport_score}=1;
        return 1;

    }
    return 0;
}





# --------- (potentially) recursive rules ----------------

sub rule_adj_noun($) {
    my $win = shift;
    if (adjectival($win->[0]) and noun($win->[1]) and
            ($win->[0]->{p_ordinal} or (agr_case($win->[0],$win->[1]) and agr_number($win->[0],$win->[1]) and agr_gender($win->[0],$win->[1])))) {
        return hang($win->[0],$win->[1],'rule_ajd_noun');
    }
    return 0;
}


sub rule_prep_noun($) {
    my $win = shift;
    if (preposition($win->[0]) and nominal($win->[1]) and not $win->[0]->{p_saturated}) {
        $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'rule_prep_noun');
    }
    return 0;
}

sub rule_adnom_gen($) {
    my $win = shift;
    if (noun($win->[0]) and case($win->[1])=~/[2X]/ and (nominal($win->[1]) or adjectival($win->[1]))) {
        #    $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'rule_adnom_gen');
    }
    return 0;
}


sub rule_J_Brabec($) {
    my $win = shift;
    if ( @$win>=3 and $win->[1]->{p_form} eq "."
             and $win->[0]->{p_form}=~/^([A-ZŽŠČŘ]|Fr|Ant|Zd)$/
                 and (surname($win->[2]) or personal_name($win->[2]))
             ) {
        hang($win->[1],$win->[0],'rule_J_Brabec_dot');
        hang($win->[0],$win->[2],'rule_J_Brabec');
        return 'resegment';
    }
    return 0;
}

sub rule_Josef_Novak($) {
    my $win = shift;
    if ( (firstname($win->[0]) or personal_name($win->[0]))
             and (surname($win->[1]) or personal_name($win->[1])) and agr_case($win->[0],$win->[1]) ) {
        return hang($win->[0],$win->[1],'rule_Josef_Novak');
    }
    return 0;
}


sub rule_rel_clause($) {
    my $win = shift;
    if ($win->[0]->{p_form} eq "," and
            (relative($win->[1]) or $win->[1]->{p_rel_desc}) or
                ($win->[1]->{p_form}=~/^(proč|kdy|kde|kdo|co|jak|kudy|kam)$/ and not $win->[1]->children)) {

        my $rel_clause_head = parse_clause( [ segment2nodes(node2segment($win->[1])) ] );
        $rel_clause_head->{p_rc_head} = 1;

        # dovesovani hranicnich carek

        my @clausenodes = sort {$a->{ord}<=>$b->{ord}} ($rel_clause_head,$rel_clause_head->descendants);
        #       if ($clausenodes[0]->{p_prev} and $clausenodes[0]->{p_prev}->{p_form} eq ",") {
        #	 hang($clausenodes[0]->{p_prev},$win->[0],'left comma bel relclausehead');
        #	 $win->[0]->{p_leftcomma}=$clausenodes[0]->{p_prev};
        #       }

        if ($clausenodes[-1]->{p_next} and $clausenodes[-1]->{p_next}->{p_form} eq ",") {
            hang($clausenodes[-1]->{p_next},$rel_clause_head,'right comma bel relclausehead');
            $rel_clause_head->{p_rightcomma}=$clausenodes[-1]->{p_next};
        }


        hang($win->[0],$rel_clause_head,'left comma bel rc-head') if $win->[0]->{p_form} eq ",";
        $rel_clause_head->{p_leftcomma}=$win->[0];
        return 'resegment';
    }
    return 0;
}


sub rule_subord_conj_clause($$) {
    my $win = shift;
    my $parentless = shift;
    my $li;
    if (((subord_conj($win->[0]))  and not $win->[0]->{p_saturated} and segment_start($win->[0]))
            or
                (@$win>=3 and verb($win->[0]) and $win->[1]->{p_form} eq "-" and $win->[2]->{p_form} eq "li" and do{$li=1})

            ) {
        if ((not $li and try_to_cancel_next_soft_separator($win->[1]))) {
            recompute_segmentation($parentless);
        }
        my @clause_nodes;
        my $subconj;
        if ($li) {
            hang($win->[1],$win->[2],'- below li');
            $parentless = [ grep{$_ ne $win->[1]} @$parentless ];
            recompute_segmentation($parentless);
            @clause_nodes = grep {$_ ne $win->[1] and $_ ne $win->[2] } (node2segmentnodes($win->[0]));
            $subconj=$win->[2];
        } else {
            @clause_nodes = grep {$_ ne $win->[0] } (node2segmentnodes($win->[0]));
            $subconj=$win->[0];
        }
        if (@clause_nodes) {
            my $clause_head = parse_clause([@clause_nodes]);
            $win->[0]->{p_subordclause_head}=$clause_head;
            hang($clause_head,$subconj,'sc head bel subconj');
            $win->[0]->{p_saturated}=1;

            # dovesovani hranicnich carek
            my @clausenodes = sort {$a->{ord}<=>$b->{ord}} ($win->[0],$win->[0]->descendants);
            if ($clausenodes[0]->{p_prev} and $clausenodes[0]->{p_prev}->{p_form} eq ",") {
                hang($clausenodes[0]->{p_prev},$subconj,'left comma bel subconj');
                $win->[0]->{p_leftcomma}=$clausenodes[0]->{p_prev};
            }

            if ($clausenodes[-1]->{p_next} and $clausenodes[-1]->{p_next}->{p_form} eq ",") {
                hang($clausenodes[-1]->{p_next},$subconj,'right comma bel subconj');
                $win->[0]->{p_rightcomma}=$clausenodes[-1]->{p_next};
            }

            return 'resegment'
        }
        return 0;
    }
    return 0;
}



sub rule_intraclaus_coord ($) {
    my $win = shift;
    report "intra1";
    if (@$win>=3 and (coord_conj($win->[1]) or $win->[1]->{p_eff_form} eq "až" or $win->[1]->{p_eff_form} eq ",")
            and $win->[1]->children==0 and do {report " intra1.5 "} and joinable_segments($win->[0],$win->[2])) {

        report "intra2";
        # choosing the best pair of conjuncts

        my @pairs;
        foreach my $left_candidate ($win->[0],right_edge_descendants($win->[0])) {
            push @pairs, [ $left_candidate, $win->[2] ];
        }
        foreach my $right_candidate (left_edge_descendants($win->[2])) {
            push @pairs, [ $win->[0], $right_candidate ];
        }

        my ($left_winner,$right_winner);
        my $best_pair_value;
        foreach my $pair (@pairs) {
            my ($left_candidate,$right_candidate) = @$pair;
            my $value = coordinability($left_candidate,$right_candidate);
            report "(pair: $left_candidate->{p_form} $right_candidate->{p_form} val=$value) ";
            if ($value>$best_pair_value) {
                $best_pair_value = $value;
                $left_winner = $left_candidate;
                $right_winner = $right_candidate;
            }
        }


        report "best pair value: $best_pair_value ";

        if ($best_pair_value > 0) {
            report_line "\n winners: $left_winner->{p_eff_form} $right_winner->{p_eff_form} ";
            if ($right_winner ne $win->[2]) {
                #	print STDERR "A1\n";
                hang($win->[0],$win->[1],'intra coord 1');
                hang($win->[1],$right_winner->parent,'intra coord 2');
                hang($right_winner,$win->[1],'intra coord 3')
            } elsif ($left_winner ne $win->[0]) {
                #	print STDERR "A2\n";
                hang($win->[2],$win->[1],'intra coord 4');
                hang($win->[1],$left_winner->parent,'intra coord 5');
                hang($left_winner,$win->[1],'intra coord 6')
            } else {
                hang($win->[0],$win->[1],'intra coord 0 left');
                hang($win->[2],$win->[1],'intra coord 0 right');
            }

            $win->[1]->{p_coordhead}++;

            if ($right_winner->{p_coordhead}) { # multiple coordination  (the last conjunction/comma becomes the head)
                hang($right_winner,$win->[1]->parent,$win->[1]->{p_rule});
                hang($win->[1],$right_winner,'intra coord 7');
                hang($left_winner,$right_winner,'intra coord 8')
            } else {
                simulate_eff($win->[1],$left_winner);
            }



            return 'resegment';
        }

        return 0;
    }
    return 0;
}


sub rule_noun_relclause($) {
    my $win = shift;
    my $rnode;
    if (noun($win->[0]) and $win->[1]->{p_rc_head} and $rnode=$win->[1]->{p_rel_desc}
            and  rel_agr_number($win->[0],$rnode) and rel_agr_gender($win->[0],$rnode)) {
        hang($win->[1],$win->[0],'rc head bel noun');
        return "resegment";
    }
    return 0;
}


sub rule_whatever_relclause($) {
    my $win = shift;
    my $rnode;
    if ($win->[1]->{p_rc_head}) {
        hang($win->[1],$win->[0],'rc head bel whatever');
        return "resegment";
    }
    return 0;
}




# cislovky mensi nez pet a podobne
sub rule_number_noun_4($) {
    my $win=shift;
    if ( ( (arab_digit($win->[0]) and $win->[0]->{p_eff_form}<=4) or basnumeral_4($win->[0]))
             and $win->[0]->{p_lemma}!~/\./ and noun($win->[1]) and not $win->[0]->{p_ordinal}     ) {
        return hang($win->[0],$win->[1],'numeral-noun 4');
    }
    return 0;
}


# cislovky vetsi nebo rovno pet a podobne se chovajicic
sub rule_number_noun_5($) {
    my $win=shift;
    my $branch;
    if ( !$win->[0]->{p_saturated} and !$win->[0]->{p_ordinal} and noun($win->[1]) and
             #       do {print "R1"} and
             (

                 (do{$branch="AA"} and arab_digit($win->[0]) and ($win->[0]->{p_lemma}>5 or $win->[0]->{p_lemma}=~/\d+\.\d+/))
                     or
                         (do{$branch="BB"} and
                              (basnumeral_5($win->[0]) or indef_numeral($win->[0]) or $win->[0]->{p_lemma}=~/^(více|méně|mnoho|málo|středně|hodně)$/)
                                  and
                                      (case($win->[1])=~/[2X]/ or agr_case($win->[0],$win->[1]))
                                  )
                     )
         ) {
        $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'numeral-noun 5'.$branch)
    }
    return 0;
}


sub rule_number_noun_5($) {
    my $win=shift;
    my $branch;
    if ( !$win->[0]->{p_saturated} and !$win->[0]->{p_ordinal} and noun($win->[1])) {
        if ( arab_digit($win->[0]) and ($win->[0]->{p_lemma}>5 or $win->[0]->{p_lemma}=~/\d+\.\d+/)) {
            if (case($win->[1])!~/[\-2X]/) {
                $win->[0]->{p_saturated}=1;
                $branch="AA0";
                return hang($win->[0],$win->[1],'numeral-noun 5'.$branch)
            } else {
                $win->[0]->{p_saturated}=1;
                $branch="AA1";
                return hang($win->[1],$win->[0],'numeral-noun 5'.$branch)
            }
        } elsif ( basnumeral_5($win->[0]) or indef_numeral($win->[0]) or $win->[0]->{p_lemma}=~/^(více|méně|mnoho|málo|středně|hodně)$/) {
            if (case($win->[0])=~/[14]/) {
                $branch="EE";
                return hang($win->[1],$win->[0],'numeral-noun 5'.$branch)
            } elsif (agr_case($win->[0],$win->[1])) {
                $branch="BB";
                return hang($win->[0],$win->[1],'numeral-noun 5'.$branch)
            } elsif (case($win->[1])=~/[2X]/) {
                $branch="CC";
                return hang($win->[1],$win->[0],'numeral-noun 5'.$branch)
            } else {
                $branch="DD";
                return hang($win->[0],$win->[1],'numeral-noun 5'.$branch)
            }

        } else {
            return 0;
        }
    }
    return 0;
}






sub rule_subordconj_coord($) {
    my $win = shift;
    if ($win->[0]->{p_subordclause_head} and not $win->[0]->{p_parenthesed}
            and $win->[2] and
                $win->[1]->{p_form} eq "a" and not $win->[1]->{p_coordhead}
                    and grep{vfin($_)} (node2segmentnodes($win->[2]))) {
        my $clause1_head = $win->[0]->{p_subordclause_head};
        my $clause2_head = parse_clause([node2segmentnodes($win->[2])]);
        hang($clause1_head,$win->[1],'subord coord');
        hang($clause2_head,$win->[1],'subord coord');
        hang($win->[1],$win->[0],'subord coord');
        return 1;
    }
    return 0;
}


sub rule_personal_roles ($) {
    my $win = shift;
    if (noun($win->[0]) and noun($win->[1]) and
            agr_case($win->[0],$win->[1]) and
                ($personal_roles{$win->[0]->{p_eff_lemma}} or lc($win->[0]->{p_eff_form})=~/^(ing|mgr|dr|dra|doc|prof|phdr|mudr|judr|thdr|rndr)$/) and
                    (surname($win->[1]) #or personal_name($win->[1]) or $personal_roles{$win->[1]->{p_eff_lemma}}
                 )) {                   # pan ministr
        return hang($win->[0],$win->[1],'personal roles');
    }
    return 0;
}

sub rule_nez_whatever($) {
    my $win = shift;
    if ($win->[0]->{p_lemma} eq "než" and not $win->[0]->{p_saturated}) {
        $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'nez whatever');
    }
    return 0;
}

sub rule_comparison_nez($) {
    my $win = shift;
    my $comparative;
    if ($win->[1]->{p_lemma} eq "než" and $win->[1]->{p_saturated} and
            ($comparative)=grep {comparative($_)} ($win->[0],$win->[0]->descendants) ) {
        return hang($win->[1],$win->[0],'comparative nez');
    }
    return 0;
}


sub rule_rhematizer($) {
    my $win = shift;
    if (rhematizer($win->[0]) and $win->[1]->{p_eff_tag}=~/^[NRDAP][^7H]/) { #radsi predelat ---  (7H - ne klitiky)
        my $rhematized;
        if ($win->[1]->{p_eff_tag}=~/^R/ and $win->[1]->children) {
            ($rhematized)=($win->[1]->children);
        } else {
            $rhematized=$win->[1]
        }
        return hang($win->[0],$rhematized,'rhematizer');
    }
    return 0;
}

sub rule_prep_whatever($) {
    my $win = shift;
    if (not $win->[0]->{p_saturated} and preposition($win->[0])) {
        $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'prep whatever');
    }
    return 0;
}


sub rule_pristavek_volny($) {
    my $win = shift;
    if (noun($win->[0]) and $win->[1]->{p_form} eq "," and not $win->[1]->children
            and adjectival($win->[2]) and agr_gnc($win->[0],$win->[2])) {
        $win->[2]->{p_to_become_clause_head}=1;
        my $pristavek_head = parse_clause([node2segmentnodes($win->[2])]);

        my @pristavek_nodes = sort {$a->{ord}<=>$b->{ord}} ($pristavek_head,$pristavek_head->descendants);
        if ($pristavek_nodes[-1]->{p_next} and $pristavek_nodes[-1]->{p_next}->{p_form} eq ",") {
            hang($pristavek_nodes[-1]->{p_next},$pristavek_head,'right comma bel pristavek');
            $win->[0]->{p_rightcomma}=$pristavek_nodes[-1]->{p_next};
        }

        hang($pristavek_head,$win->[0],'pristavek-hlava');
        hang($win->[1],$pristavek_head,'pristavek-leftcomma');


        return 'resegment';
    }
    return 0;
}



sub rule_jako_whatever ($) {
    my $win = shift;
    if ($win->[0]->{p_lemma} eq "jako" and not $win->[0]->{p_saturated}) {
        $win->[0]->{p_saturated}=1;
        return hang($win->[1],$win->[0],'whatever bel jako');
    }
    return 0;
}



sub rule_num_percnt($) {
    my $win = shift;
    if (arab_digit($win->[0]) and $win->[1]->{p_eff_form} eq "%") {
        return hang($win->[1],$win->[0],'51 %')
    }
    return 0;
}

sub rule_numbered_entity($) {   # rok 1994, strana 58, Praha 3
    my $win = shift;
    if (arab_digit($win->[1]) and
            ($numbered_noun{$win->[0]->{p_eff_lemma}} or $win->[0]->{p_eff_suffix}=~/G/)
        ) {
        return hang($win->[1],$win->[0],'rok 1994')
    }
    return 0;
}

sub rule_trikrat_rychlesi ($) {
    my $win = shift;
    if ((multip_num($win->[0]) or $win->[0]->{p_eff_lemma}=~/krát$/) and comparative($win->[1])) {
        return hang($win->[0],$win->[1],'trikrat rychlesi');
    } 
    return 0


}


sub rule_title_behind($) {
    my $win = shift;
    if (@$win>=3 and personal_name($win->[0]) and $win->[1]->{p_form} eq ","
            and $win->[2]->{p_form}=~/^(drsc|csc|phd)$/i
        ) {
        hang($win->[1],$win->[2],'title behind 1');
        return hang($win->[2],$win->[0],'title behind 1');
    }
    return 0;
}


sub rule_selection_scope($) {
    my $win = shift;
    if ((superlative($win->[0]) or numeral($win->[0])) and $win->[1]->{p_eff_lemma} eq "z") {
        return hang($win->[1],$win->[0],'title behind 1');
    }
    return 0;
}


sub rule_noun_ajd($) {
    my $win = shift;
    if (adjectival($win->[1]) and nominal($win->[0]) and
            ($win->[1]->{p_ordinal} or (agr_case($win->[0],$win->[1]) and agr_number($win->[0],$win->[1]) and agr_gender($win->[0],$win->[1])))) {
        return hang($win->[1],$win->[0],'rule_noun_adj');
    }
    return 0;
}

sub rule_adjo_adj($) {          # ostravsko-karvinske
    my $win = shift;
    if (@$win>=3 and adjo($win->[0]) and $win->[1]->{p_form} eq "-" and adjective($win->[2])) {
        hang($win->[0],$win->[1],'ostravsko-karvinske left');
        hang($win->[2],$win->[1],'ostravsko-karvinske right');
        simulate_eff($win->[0],$win->[1]); # pomlcka predstira prave adjektivum
        return "resegment";
    }
    return 0;
}


sub rule_to_ze ($) {
    my $win=shift;
    if (pron_demon($win->[0]) and $win->[1]->{p_eff_form}=~/^(že|aby)$/ and $win->[1]->{p_saturated}) {
        return hang($win->[1],$win->[0],'rule to ze')
    }
    return 0;
}


sub rule_dvakrat_tydne($) {
    my $win=shift;
    if (num_multiple($win->[0]) and
            ($win->[1]->{p_lemma}=~/^(denně|týdně|měsíčně|čtvrtletně|půlročně|ročně)$/ or ($win->[1]->{p_eff_form} eq "za" and $win->[1]->{p_saturated}))) {
        return hang($win->[1],$win->[0],'dvakrat tydne')
    }
    return 0;
}


sub rule_named_entity($) {
    my $win=shift;
    if ($named_entity{$win->[0]->{p_eff_lemma}} and $win->[1]->{p_eff_lemma}=~/^[A-ZŽŠČŘ]/ and not $win->[0]->{p_ne_saturated}) {
        $win->[0]->{p_ne_saturated}=1;
        return hang($win->[1],$win->[0],'rule named entity')
    }
    return 0;
}




sub rule_adv_adj($) {
    my $win = shift;
    my $adj;
    if (adverb($win->[0]) and $adv_adj{$win->[0]->{p_eff_lemma}} and
            ($adj)=(grep {adjectival($_)} ($win->[1],left_edge_descendants($win->[1])))) { # adjektivum uz muze byt zavesene
        return hang($win->[0],$adj,'adv below adj')
    }

    return 0;
}





sub rule_adv_adv($) {
    my $win=shift;
    if (adverb($win->[0]) and adverb($win->[1]) and $adv_adv{$win->[0]->{p_orig_lemma}}) {
        return hang($win->[0],$win->[1],'adv below adv');
    }
    return 0;
}


sub rule_compound_numeral ($) { # tricet pet
    my $win=shift;
    if (basnumeral($win->[0]) and basnumeral($win->[1])) {
        return hang($win->[0],$win->[1],'compound number');
    }
    return 0;
}


sub rule_somebody_from_somewhere ($) { # Pepa Novak z Kadane
    my $win=shift;
    if (surname($win->[0]) and $win->[1]->{p_eff_form} eq "z" and $win->[1]->{p_saturated}) {
        return hang($win->[1],$win->[0],'smbody from smwhere');
    }
    return 0;
}



# --------- bottom-up application of reduction rules  -------------------

sub apply_simple_rules($) {
    my $nodes = shift;
    my @all=@$nodes;

    while (@all>1) {
        if (lc($all[0]->{p_form})=~/^(ing|dr|dra|doc|prof|phdr|drsc|csc|mudr|judr|thdr|rndr|tzv|mj|např|čs)$/ and $all[1]->{p_form} eq ".") {
            hang($all[1],$all[0],'simple-dot in abbrev');
        } elsif (arab_digit($all[0]) and arab_digit($all[2]) and $all[1]->{p_form} eq ":") {
            hang($all[0],$all[1],'rule score 1');
            hang($all[2],$all[1],'rule score 2');
            $all[1]->{p_sport_score}=1;
        } else {
            rule_adjo_adj(\@all);
            rule_country_country(\@all);
            rule_potapejici_se(\@all);
        }

        shift @all;
    }

    @$nodes = ( grep {!$_->{p_rule}} @$nodes );
}


sub apply_recursive_rules {
    my $nodes = shift;
    report_line "apply_recursive_rule: ".(join " ", map {$_->{p_form}} @$nodes);

    my @parentless=@$nodes;
    my $restart_cnt;  # number of restarts, counted to prevent looping


    my $first = $#parentless-1; # minimum sliding window size is 2
    my $lastparentlesscnt=@parentless;
    while ($first>=0) {
        my $window = [@parentless[$first..min($#parentless,$first+5)]];
        my $delayed_window = [@parentless[$first+1..min($#parentless,$first+6)]];
        report_line " window:   ".(join " ",map{"$_->{p_eff_form}"} @$window);
        my $success = 0
            || rule_noun_relclause($window)
                || rule_adj_noun($window)
                    || rule_noun_ajd($window)
                        #	|| rule_sport_score($window)
                        || rule_ordinal_dot($window)
                            || rule_prep_noun($window)
                                || rule_jako_whatever($window)
                                    || rule_personal_roles($window)
                                        || rule_numbered_entity($window)
                                            || rule_number_noun_4($window)
                                                || rule_title_behind($window)
                                                    || rule_number_noun_5($window)
                                                        || rule_J_Brabec($window)
                                                            || rule_Josef_Novak($window)
                                                                || rule_named_entity($window)
                                                                    || rule_num_percnt($window)
                                                                        || rule_adnom_gen($window)
                                                                            || rule_rel_clause($window)
                                                                                || rule_subord_conj_clause($window,\@parentless)
                                                                                    || rule_to_ze($window)
                                                                                        || rule_intraclaus_coord($delayed_window) || ($first==0 and rule_intraclaus_coord($window))
                                                                                            ||  rule_subordconj_coord($window)
                                                                                                #			      ||  rule_relclause_coord($window)
                                                                                                || rule_nez_whatever($window)
                                                                                                    || rule_dvakrat_tydne($window)
                                                                                                        || rule_trikrat_rychlesi($window)
                                                                                                            || rule_comparison_nez($window)
                                                                                                                || rule_adv_adj($window)
                                                                                                                    || rule_adv_adv($window)
                                                                                                                        || rule_rhematizer($window)
                                                                                                                            || rule_pristavek_volny($window)
                                                                                                                                || rule_prep_whatever($window)
                                                                                                                                    || rule_selection_scope($window) # jeden z, nejlepsi z
                                                                                                                                        || rule_compound_numeral($window)
                                                                                                                                            || rule_somebody_from_somewhere($window)
                                                                                                                                                #				|| rule_whatever_relclause($window)
                                                                                                                                                #				  || rule_adjo_adj($window)   # only once
                                                                                                                                                ;
        if ($success) {
            $restart_cnt++;
            @parentless = grep {not $_->{p_rule}} @parentless;
            if ( @parentless <  $lastparentlesscnt ) { # tohle by melo platit vzdycky, ale bohuzel...
                $lastparentlesscnt = @parentless;
                report_line "* restart: ".(join " ", map {$_->{p_eff_form}} @parentless);
                if ($success eq "resegment") {
                    recompute_segmentation(\@parentless);
                }
                # $segmentation = recompute_segmentation(\@parentless);
                $first=$#parentless-1;
            } else {
                $first--;
            }
        } else {
            $first--;
        }
    }



}





# -------- top-down parsing -----------------------------


sub parse_clause {
    return if prevent_looping();
    my $nodes = shift;

    @$nodes = grep {not $_->{p_rule}} @$nodes;

    if (@$nodes < 2) {
        return $nodes->[0];
    }

    report_line "parse_clause: ".(join " ", map {$_->{p_form}} @$nodes);


    # lexikalizovane ngramy
    foreach my $node (grep{$_->{p_lex_ngram}} @$nodes) {
        my $parent=$node->{p_lex_ngram};
        if (not descendant_of($node,$parent)) {
            eval{hang($node,$node->{p_lex_ngram},"lex ngram");if (preposition($parent)) {$parent->{p_saturated}=1};};

        }
    }
    @$nodes = grep {not $_->{p_rule}} @$nodes;

    foreach my $node (grep{$_->{p_mlex_ngram}} @$nodes) {
        my $parent=$node->{p_mlex_ngram};
        if (not descendant_of($node,$parent) and case($node) ne "1") {
            eval{  hang($node,$parent,"mlex ngram"); if (preposition($parent)) {$parent->{p_saturated}=1};};
        }
    }
    @$nodes = grep {not $_->{p_rule}} @$nodes;



    # zbyva-li nezavesena veta relativni klauze, najd
    my ($rc_head)=grep {$_->{p_rc_head}} @$nodes;
    if ($rc_head) {
        report_line ("parentless rc_head $rc_head->{p_eff_form}");
        my $rnode=$rc_head->{p_rel_desc};
        my @prev_nodes;
        my $prev=$rnode;
        my $success;
        while ($prev=$prev->{p_prev} and not $success) { # cokoli v predchazejicim kontextu, co se shoduje
            if (not descendant_of($prev,$rc_head) and noun($prev) and rel_agr_number($prev,$rnode) and rel_agr_gender($prev,$rnode)) {
                $success=hang($rc_head,$prev,'rc_head bel prev agr');
            }
        }
        if (not $success) {
            my $prev=$rnode;
            my $success;
            while ($prev=$prev->{p_prev} and not $success) { # cokoli v predchazejicim kontextu, i bez shody
                if (not descendant_of($prev,$rc_head) and nominal($prev)) {
                    $success=hang($rc_head,$prev,'rc_head bel prev agr');
                }
            }

        }
        if ($success) {
            @$nodes = grep {not $_->{p_rule}} @$nodes;
        }
    }


    # je-li v klauzi reflexivum tantum, pak vyhrava refl. zajmeno
    my (@tantum) = grep {$refl_tantum{$_->{p_lemma}} and $_->{p_eff_tag}=~/^V[^s]/} @$nodes;
    my ($particle) = grep {refl_sesi($_)} @$nodes;
    if (@tantum and $particle) {
        my ($winner) = sort { abs($particle->{ord} - $b->{ord}) <=> abs($particle->{ord} - $a->{ord})}  @tantum;
        hang($particle,$winner,'refl si/se bel r.tantum');
        @$nodes = grep {not $_->{p_rule}} @$nodes;
    }


    # 'o 50 Kc vice'
    my ($o) = grep { $_->{p_eff_lemma} eq "o" and case($_) eq "4"}  @$nodes;
    my ($comp) = grep { comparative($_) }  @$nodes;
    if ($o and $comp) {
        hang($o,$comp,'prep o bel compar');
        @$nodes = grep {not $_->{p_rule}} @$nodes;
    }


    # hledani rodice skrze vyextrahovanou valenci
    my $prev;
    foreach my $node (@$nodes) {
        my $form;
        if ($node->{p_eff_tag}=~/^(R|J,)/) {
            $form = $node->{p_eff_lemma};
        } elsif ($node->{p_eff_tag}=~/^Vf/) {
            $form = 'inf'
        } elsif ($node->{p_eff_tag}=~/^[NAP]...(\d)/) {
            $form = $1;
        }


        if ($form) {
            report_line "potential valency slot, form=$form";
            #      my $form = $node->{p_eff_lemma};
            my @candidates;     # candidates for parent;
            if ($prev) {
                push @candidates,$prev;
                push @candidates,(grep {noun($_) or adjective($_)} right_edge_descendants($prev));
            }
            push @candidates,(grep {$_ ne $prev and verb($_)} @$nodes);

            # choosing the winner
            my ($max,$winner);
            my $derived;
            foreach my $cand (grep {not $_->{p_parenthesed} and not $_->{p_dsp_root}} @candidates) {
                report_line "  parent candidate: $cand->{p_pos} $cand->{p_lemma} form=$form   value=$val_prob{$cand->{p_pos}}{$cand->{p_lemma}}{$form}";
                my $value = $val_prob{$cand->{p_pos}}{$cand->{p_lemma}}{$form};
                if ($value>$max) {
                    $max = $value;
                    $winner = $cand;
                    $derived=0;
                }
                my $dlemma = derived_lemma($cand);
                foreach my $pos ('N','A','V') {
                    if ($dlemma) {
                        report_line (" valtrying: $pos $dlemma $form");
                        $value = $val_prob{$pos}{$dlemma}{$form};
                        if ($value>$max) {
                            $max = $value;
                            $winner = $cand;
                            $derived=$pos;
                            report_line ("QQQQ");
                        }
                    }
                }

            }

            if ($winner) {
                if (not grep{$_ eq $winner} ($node,$node->descendants)) { # prevention of creating cycles
                    hang($node,$winner,"prob valency winner $derived");
                }
            }
        }


        $prev=$node;
    }

    @$nodes = grep {not $_->{p_rule}} @$nodes;

    foreach my $node (@$nodes) {
        if ($node->{p_to_become_clause_head}) {
            $node->{p_preference}=1000;
            undef $node->{p_to_become_clause_head};
        }
        if ($node->{p_eff_tag}=~/^V[^c]/) {
            $node->{p_preference} = 100;
            if (vfin($node)) {
                $node->{p_preference}+=10;
            }
        }
        if ($node->{p_dsp_root} or $node->{p_rc_head} or $node->{p_parenthesed}) {
            $node->{p_preference} -= 50;
        }
    }

    my ($winner) = (sort {$b->{p_preference} <=> $a->{p_preference}} @$nodes);
    foreach my $node (grep {$_ ne $winner} @$nodes) {
        hang($node,$winner,'below clause winner');
    }

    $winner->{p_clausehead}=1;
    return $winner;
}


sub parse_sentence($) {
    return if prevent_looping();
    my $nodes = shift;
    report_line "parse_sentence: ".(join " ", map {$_->{p_form}} @$nodes);


    # parove uvozovky
    my @quotes = grep {$_->{p_form} eq '"'} @$nodes;
    while (@quotes>=2) {
        my $left_quote = shift @quotes;
        my $right_quote = shift @quotes;
        my @dsp_nodes = grep { before($left_quote,$_) and before($_,$right_quote) } @$nodes;
        my $dsp_root = parse_sentence(\@dsp_nodes);
        hang($left_quote,$dsp_root,'leftquot bel dsp root');
        hang($right_quote,$dsp_root,'rightquot bel dsp root');
        $dsp_root->{p_dsp_root}=1;
    }

    $nodes = [grep {not $_->{p_rule}} @$nodes];

    # jedina uvozovka a predchazi ji carka (tzn. prima rec je asi vlevo)
    if (@quotes==1 and $quotes[0]->{p_prev} and $quotes[0]->{p_prev}->{p_form} eq ",") {
        my @dsp_nodes = (grep { before($_,$quotes[0]) } @$nodes);
        my $dsp_root = parse_sentence(\@dsp_nodes);
        hang($quotes[0],$dsp_root,'rightquot bel dsp root');
        $dsp_root->{p_dsp_root}=1;
    }

    $nodes = [grep {not $_->{p_rule}} @$nodes];


    # jedina uvozovka a predchazi ji dvojtecka (tzn. prima rec je asi vpravo)
    if (@quotes==1 and $quotes[0]->{p_prev} and $quotes[0]->{p_prev}->{p_form} eq ":") {
        my @dsp_nodes = (grep { before($quotes[0],$_) } @$nodes);
        my $dsp_root = parse_sentence(\@dsp_nodes);
        hang($quotes[0],$dsp_root,'rightquot bel dsp root');
        $dsp_root->{p_dsp_root}=1;
    }

    $nodes = [grep {not $_->{p_rule}} @$nodes];


    # jedina dvojtecka (a neni to skore);
    my (@colon) = grep {$_->{p_form} eq ":" and not $_->{p_sport_score}} @$nodes;
    if (@colon==1) {
        my @left_nodes=grep {$_->{ord}<$colon[0]->{ord}} @$nodes;
        my @right_nodes=grep {$_->{ord}>$colon[0]->{ord}} @$nodes;
        if (@left_nodes and @right_nodes) {
            my $left_root=parse_sentence(\@left_nodes);
            my $right_root=parse_sentence(\@right_nodes);
            hang($left_root,$colon[0],'left bel colon');
            hang($right_root,$colon[0],'right bel colon');
        }
        $nodes = [grep {not $_->{p_rule}} @$nodes];
    }




    my @parentheses = grep {$_->{p_form}=~/[()]/} @$nodes;
    while (@parentheses>=2) {
        my $left_par = shift @parentheses;
        my $right_par = shift @parentheses;
        my @par_nodes = grep { before($left_par,$_) and before($_,$right_par) } @$nodes;
        my $par_root = parse_sentence(\@par_nodes);
        report_line("leftpar $left_par parroot $par_root");
        hang($left_par,$par_root,'leftpar bel par root');
        hang($right_par,$par_root,'rightpar bel par root');
        $par_root->{p_parenthesed}=1;
    }


    $nodes = [grep {not $_->{p_rule}} @$nodes];


    recompute_segmentation($nodes);
    apply_recursive_rules($nodes);

    my $fullstop;

    report_line('checkpoint 1');
    if ($nodes->[-1] and $nodes->[-1]->{p_form}=~/^[.!?;]$/) {
        $fullstop = $nodes->[-1];
        $fullstop->{p_rule} = 'postponed';
    }

    $nodes = [grep {not $_->{p_rule}} @$nodes];

    report_line('checkpoint 1');

    # zbavit se nekoordinacnich 'i' (jako vetna koordinace jsou ridke), predelat je na rematizatory
    my @i = grep {$nodes->[$_]->{p_eff_lemma} eq "i"} (0..($#$nodes-1));
    foreach my $i (@i) {
        hang($nodes->[$i],$nodes->[$i+1],'rhematizer i');
    }

    if (@i) { 
        $nodes = [grep {not $_->{p_rule}} @$nodes];
        recompute_segmentation($nodes);
    }


    # predposledni pokus o pospojovani spojitelnych segmentu


    my $success=1;
    while ($success) {
        $success=0;
        foreach my $i (0..$#$nodes-2) {
            if (not $nodes->[$i]->{p_separator} and not $nodes->[$i+1]->{p_separator} and
                    $nodes->[$i]->{p_rightcomma} and joinable_segments($nodes->[$i],$nodes->[$i+1])) {
                report_line ("  joining segments: ");
                report_line("seg1: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i])));
                report_line("seg2: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i+1])));
                undef $nodes->[$i]->{p_rightcomma};
                recompute_segmentation($nodes);
                $success=1;
                last;
            }
        }
    }


    # pripadne zapojeni skupiny 'nez' ke komparativu
    my ($nez) = grep {$_->{p_eff_lemma} eq "než"}  @$nodes;
    my ($compar)= grep {comparative($_)}  @$nodes;
    if ($nez and $compar) {
        hang($nez,$compar,'nez fallback');
        $nodes = [grep {not $_->{p_rule}} @$nodes];
    }

    # posledni pokus o pospojovani spojitelnych segmentu

  
    report_line("trying to join: ".(join " ",map{$_->{p_eff_form}} @$nodes));
    my $success=1;
    while ($success) {
        $success=0;
        foreach my $i (0..$#$nodes-1) {
            if ($i<$#$nodes-1 and $nodes->[$i+1]->{p_separator} and
                    node2segment($nodes->[$i]) < node2segment($nodes->[$i+1]) and
                        node2segment($nodes->[$i+1]) < node2segment($nodes->[$i+2]) and
                            joinable_segments($nodes->[$i],$nodes->[$i+2])) {
                $nodes->[$i+1]->{p_nonseparator}=1;
                report_line ("  joining segments1: ");
                report_line("seg1: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i])));
                report_line("seg2: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i+2])));
                recompute_segmentation($nodes);
                $success=1;
                last;
            } elsif ($nodes->[$i]->{p_rightcomma} and
                         node2segment($nodes->[$i]) < node2segment($nodes->[$i+1]) and # neriskuju neprojektivity
                             joinable_segments($nodes->[$i],$nodes->[$i+1])) {
                undef $nodes->[$i]->{p_rightcomma};
                report_line ("  joining segments2: ");
                report_line("seg1: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i])));
                report_line("seg2: ".(join " ",map{$_->{p_eff_form}} node2segmentnodes($nodes->[$i+1])));
                recompute_segmentation($nodes);
                $success=1;
                last;
            }
        }
    }


    # vsechny slovni (neseparatorove) segmenty se ted jednotlive budou povazovat za klauze
    my @word_segments = word_segments();
    if (@word_segments>0) {
        foreach my $segment (word_segments()) {
            parse_clause($segment)
        }
        $nodes = [grep {not $_->{p_rule}} @$nodes];
        recompute_segmentation($nodes)
    }

    $nodes = [grep {not $_->{p_rule}} @$nodes];

    # konecnym automatem jedu od konce po vrcholech klauzi a separatorech

    my @nodes=@$nodes;
    report_line ("final countdown: ".(join " ",map{$_->{p_eff_form}} @nodes));

    my $head=pop @nodes;

    my $first=$head;

    while (@nodes) {
        my $next=pop @nodes;
        report_line("next: $next->{p_eff_form}");
        if (coord_conj($next) or $next->{p_eff_form}=~/^[,;:]/ and not $head->{p_coordhead}) { # zakladani koordinace
            hang($head,$next,'F: last below conj');
            report_line ("   F: last below conj");
            $head=$next;
            $head->{p_coordhead}=1;
        } elsif ($head->{p_coordhead}) {
            report_line ("   F: everth below coord");
            hang($next,$head,'F: everth below coord')
        } elsif (not (@nodes==0 and punctuation($next))) {
            hang($head,$next,'F: everth below next');
            if ($head->{p_form} eq '"' and $next->{p_form} eq ".") {
                $head->{p_last_quot_rehang}=1;
            }
            report_line ("   F: everth below next");
            $head=$next;
        }

    }

    undef $head->{p_rightcomma};
    if ($head) {
        return $head
    } else {
        return $fullstop
    }
  

    #  if ($fullstop) {
    #    hang($fullstop,$head,'fullstop');
    #    $head->{p_rehang_to_grandpa}=1;
    #  }



    # --------   puvodni koncovka

    # a co zbude (ted by nemelo nic) se bude taky povazovat za klauzi
    #  my $sent_root = parse_clause($nodes);#

    #  if ($fullstop) {
    #    hang($fullstop,$sent_root,'fullstop');
    #    $fullstop->{p_rehang_to_grandpa}=1;
    #  }

    #  return $sent_root;

}


# -------- sentence preprocessing and postprocessing

sub sentence_preprocessing($) {
    my $root = shift;
    my $prev_node;
    foreach my $node ($root,sort{$a->{ord}<=>$b->{ord}}$root->descendants) {

        # hanging everything below the root
        CutPaste($node,$root) if $node ne $root;

        # cleaning auxiliary attributes
        foreach my $attr (grep {/^p_/} keys %{$node}) {
            undef $node->{$attr};
        }

        # copying {m}{form} to {p_form}
        foreach my $attr ('form','lemma','tag') { 
            $node->{"p_$attr"} =  $node->attr("m/$attr");
        }

        # separating technical suffix from the morphological lemma
        $node->{p_orig_lemma}=$node->{p_lemma};
        if ($node->{p_lemma}=~s/([\'\`\_\-].+)$//) {
            $node->{p_suffix} = $1 ;
        }


        # -------------

        foreach my $attr ('form','lemma','tag','suffix') {
            $node->{"p_eff_$attr"} =  $node->{"p_$attr"};
        }


        if ($node->{p_tag}=~/^(.)/) {
            $node->{p_pos}=$1;
        }

        if ($prev_node) {
            $prev_node->{p_next}=$node;
            $node->{p_prev}=$prev_node;
        }
        $prev_node = $node;

    }
}


sub swap_with_parent($) {
    my $node = shift;
    my $parent = $node->parent;
    my $grandpa = $node->parent->parent;
    hang($node,$grandpa,'swap with parent');
    hang($parent,$node,'swap with parent');
    return 1;
}

sub swap_aux($$) {              # horni,dolni
    #  return 1;
    my ($auxverb,$fullverb)=@_;
    my $auxverb = $fullverb->parent;
    hang($fullverb,$auxverb->parent,'passive swap 1');
    hang($auxverb,$fullverb,'passive swap 2');
    foreach my $sister ($auxverb->children) {
        hang($sister,$fullverb,'passive swap 3');
    }
    return 1
}

sub sentence_postprocessing($) {
    report_line "sentence_postprocessing:";
    my $root = shift;

    # rehanging full stop to root
    foreach my $fstop (grep {$_->{p_rule} eq "postponed"} $root->descendants) {
        hang($fstop,$root,'postponed');
    }

    # swapping passive verb form and aux 'to be'
    foreach my $passive (grep{verb_passive($_) and $_->parent->{p_eff_lemma} eq "být"} ($root->descendants)) {
        my $auxverb = $passive->parent;
        swap_aux($auxverb,$passive);
    }

    # swapping participle verb form and aux 'to be' in complex past tens (prisel jsem)
    foreach my $past (grep{past_participle($_) and to_be($_->parent)
                               and present_tense($_->parent) and person($_->parent)=~/[12]/} ($root->descendants)) {
        my $auxverb = $past->parent;
        swap_aux($auxverb,$past);
    }

    # swapping infinite verb form and aux 'to be' in complex future tens (budu chodit)
    foreach my $fut (grep{infinitive($_) and to_be($_->parent) and future_tense($_->parent)} ($root->descendants)) {
        my $auxverb = $fut->parent;
        swap_aux($auxverb,$fut);
    }



    # pokud dostane cislovka vetsi nez ctyri shora rizeny genitiv, mohlo zustat pocitane substantivum nahore
    foreach my $counted (grep {$_->{p_rule} eq "numeral-noun 5" and $_->parent->parent
                                   and preposition($_->parent->parent) and case($_->parent->parent) eq "2"} $root->descendants) {

        swap_with_parent($counted);
    }

    # privlastky ukradene osobnim rolim
    foreach my $persrole (grep {$_->{p_rule} eq "personal roles"} $root->descendants()) {
        foreach my $stolen (grep {adjectival($_) and before($_,$persrole)} $persrole->parent->children) {
            hang($stolen,$persrole,'returned to persrole');
        }
    }

    # preveseni akuzativu pod infinitivy (ve vetach s fin.slovesem)
    foreach my $clausehead (grep {$_->{p_clausehead}} $root->descendants) {
        my ($vinf) = grep {infinitive($_) and not $_->{p_clausehead} } $clausehead->children;
        if ($vinf) {
            my @direct = (grep { #not preposition($_) and 
                case($_)=~/[2347]/ and $_->{p_rule}!~/(valen|tantum)/} $clausehead->children);
            foreach (@direct) {
                hang($_,$vinf,'direct case below infin');
            }
        }
    }

    # carka pred ale prijde pod nej
    foreach my $comma (grep {$_->{p_form} eq "," and $_->{p_next}->{p_form} eq "ale" and not $_->children} $root->descendants) {
        hang($comma,$comma->{p_next},'carka pod ale');
    }




    # preveseni spolecneho subjektu v koordinovanych klauzich

    foreach my $subject (grep {case($_) eq "1" and $_->parent->{p_clausehead} and $_->parent->parent->{p_coordhead}} $root->descendants) {
        report_line( "Kandidat na rise-subj $subject->{p_eff_form}");
        report_line "X -2";
        my $my_clause_head=$subject->parent;
        report_line " X -1 ";
        my @remaining_clause_heads = grep {$_->{p_clausehead} and verb($_) and $_ ne $my_clause_head} $my_clause_head->parent->children;
        report_line " X0 ";
        if (@remaining_clause_heads # aspon jedna dalsi koordinovana klause
                and do {report_line " X1 "}
                    and not (grep {$_->{ord}<$subject->{ord}} $my_clause_head->children) # subjekt je v klauzi prvni, tzn. nezpusobi neprojekt
                        and do {report_line " X2 "}
                            and not (grep{grep{case($_) eq "1"} $_->children} @remaining_clause_heads) # zadna z dalsich ale nema zadny subjekt
                                and do {report_line " X3 "}
                                    and not (grep{$_->{ord}<$my_clause_head->{ord}} @remaining_clause_heads) # ja jsem prvni klauze
                                        and do {report_line " X4 "}
                                    ) {
            hang($subject,$my_clause_head->parent,'rise subject');
        }

    }


    # jednoclenne koordinace
    foreach my $coord (grep  {not $_->children and $_->parent->parent and
                                  ((coord_conj($_) and $_->{ord}==1) or ($_->{p_lemma}=~/^(však|ale|proto)$/ and $_->parent->parent eq $root))}
                           $root->descendants) {
        report_line("VSAK: eff=$coord->{p_eff_lemma}  orig=$coord->{p_lemma}");
        swap_with_parent($coord);
    }


    foreach my $rehang (grep {$_->{p_rehang_to_grandpa}} $root->descendants) {
        hang($rehang,$rehang->parent->parent,'rehang to grandpa');
    }


    # posledni uvozovka pred teckou
    foreach my $quot (grep {$_->{p_last_quot_rehang}} $root->descendants) {
        my $fullstop=$quot->parent;
        hang($quot,$fullstop->parent,'last quote rehang');
        hang($fullstop,$root,'last quote rehang');
    }



    foreach my $node ($root->descendants) {
        if ($node->{p_rule} eq "") {
            $node->{p_rule}="rest below root";
        }
    }


    return 1;

}                               # end of   sentence_postprocessing






# --------- initialization

load_external_dict();

#print STDERR "numbered nouns: rok  $numbered_noun{rok}\n\n";


# clear global variables
%node2segment=();
%first_in_segment=();
@segments=();
%segment_type=();


# --------- exported functions --------------------------------

sub fs_parse($$) {
    my $root = shift;
    $fsfile = shift;

    if ($save_partial_as_csts) {
        if ($root->{id} ne "a-ln94202-19-p5s4") {
            return;
        }
    }
    #  if (not $root->{backup}) {
    #    die "Shouldn't run the parser - the original structure was not saved!\n";
    #  }

    #  print STDERR FileName()."\n";

    sentence_preprocessing($root);

    $loopcnt=0;
    my @nodes = sort {$a->{ord}<=>$b->{ord}} $root->descendants;
    my $sentence=(join " ",map{$_->{form}} @nodes); #p_form

    #  if ($sentence =~/^Politolog/) {
    report_line "\n------------------------------------\n\n".
        "fs_parse: $sentence\n";
    foreach my $node ($root->descendants) {
        undef $node->{p_rule};
    }
    #  sentence_preprocessing($root);
    if ($save_partial_as_csts) {
        print_csts
    }
    if (not apply_short_sentence_patterns($root)) {
        apply_lexicalized_ngrams($root);
        apply_mildly_lexicalized_ngrams($root);
        @nodes = grep{not $_->{p_rule}} @nodes;
        apply_simple_rules( \@nodes );
        parse_sentence( \@nodes );
        sentence_postprocessing($root);
    }
    foreach my $node ($root->descendants) {
        $node->{parent_parsed}=$node->parent->{ord};
    }

    #  }
    1;
}


1;
