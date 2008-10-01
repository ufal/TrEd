package SCzechA_to_SCzechT::Assign_grammatemes;

use 5.008;
use strict;
#use warnings;  ### poopravovat pozdeji !!!

use base qw(TectoMT::Block);

use TectoMT::Document;
use TectoMT::Bundle;
use TectoMT::Node;

use utf8;


my $global_document;


sub process_document {
    my ($self,$document) = @_;
    $global_document = $document;
    Fill_grammatemes::process_trees(map {$_->get_tree('SCzechT')} $document->get_bundles()) ;
}


1;

=over

=item SCzechA_to_SCzechT::Assign_grammatemes

Grammatemes of SCzechT complex nodes are filled by this block, using
POS tags, info about auxiliary words, list of pronouns etc. Besides
the genuine grammatemes such as C<gram/number> or C<gram/tense>, also
the classification attribute C<gram/sempos> is filled.

=back

=cut

# Copyright 2008 Zdenek Zabokrtsky


# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

# extracted from fill_grammatemes.ntred by Zdenek Zabokrtsky:




package PML_T;             # funkce simulujici pritomnost baliku PML_T

sub GetEParents {
    my $fs_t_node = shift;
    return map {$_->get_tied_fsnode} $TectoMT::Node::fsnode2tmt_node{$fs_t_node}->get_eff_parents;
}

sub GetEChildren {
    my $fs_t_node = shift;
    return map {$_->get_tied_fsnode} $TectoMT::Node::fsnode2tmt_node{$fs_t_node}->get_eff_children;
}


sub GetANodes {
    my $fs_t_node = shift;
    return map {$_->get_tied_fsnode} $TectoMT::Node::fsnode2tmt_node{$fs_t_node}->get_anodes;
}


sub GetANodeByID {
    my $id = shift;
    return $global_document->get_node_by_id($id)->get_tied_fsnode();
}


package Fill_grammatemes;


# globalni promenne (nejruznejsi tabulky puvodne ulozene v externich souborech)
my %verbal_aspect;
my %nongradadv;                 # nestupnovatelne adverbium
my %pronomadv;                  # adverbium pronominalni povahy
my %notnegableadv;              # nenegovatelne adverbium
my %adv2adj;                    # puvodni adjektivum
my %applicable_gram;
my %all_applicable_grams;
my %t_lemma2attribs; # hodnoty atributu, ktere se maji vyplnit na zaklade hodnoty t_lemmatu
my %origrule;
my %premise;                    # seznam moznych premis
my %nonnegable_semn;

my %tnumber2gnumber = ('S' => 'sg', 'P' => 'pl' , 'D' => 'pl');
my %tgender2ggender = ('F' => 'fem', 'I' => 'inan', 'M' => 'anim', 'N' => 'neut' );


my $report;

sub set_attr {
    my ($node, $attr_name, $attr_value, $author) = @_;
    #  print "tlemma: $node->{t_lemma}     \t$attr_name\t$attr_value\t$author\n";
    $node->set_attr($attr_name,$attr_value);
}


# test, zda je uzel povrchove vyjadreny
sub surface ($) {
    my $t_node = shift;
    return ($t_node->{temp_lex_tag} ne "");
}

# test, zda je sloveso dokonave
sub perfective ($) {
    my $lemma = shift;
    return ($verbal_aspect{$lemma}=~/P/);
}



# vyhodnocovani podminek pouzitych v (puvodne externim) konverznim souboru
sub evalpremise($$) {
    my ($node,$condition) = @_;
    if ($report) {
        print "Eval premise: $condition\n";
    }
    my $plur = ($node->{g_number}=~/pl/); # ???
    my $func = $node->{functor};
    my $tag = $node->{temp_lex_tag};
    my $coref = ($node->{temp_relative_clause} || defined $node->attr('coref_gram.rf'));
    # ???? tady je potreba nafejkovat gramatickou koreferenci u vztaznych vet

    if ($condition!~/^(rstr|notrstr|coref|notcoref|plur|notplur|twhen|ttill|loc|dir3|n&notrstr|notn&notrstr|coref&rstr|coref&notrstr|notcoref&rstr|notcoref&notrstr|coref&plur|coref&notplur|notcoref&plur|notcoref&notplur)$/) {
        print "Unknown premise $condition !\n";
    }

    return (($condition eq "rstr" and adjectival($node)) or
                ($condition eq "notrstr" and not adjectival($node)) or
                    ($condition eq "coref" and $node->{coref} ne "") or
                        ($condition eq "notcoref" and $node->{coref} eq "") or
                            ($condition eq "plur" and $plur) or
                                ($condition eq "notplur" and not $plur) or
                                    ($condition eq "twhen" and $func eq "TWHEN") or
                                        ($condition eq "ttill" and $func eq "TTILL") or
                                            ($condition eq "loc" and $func eq "LOC") or
                                                ($condition eq "dir3" and $func eq "DIR3") or
                                                    ($condition eq "n&notrstr" and $tag=~/^..N/ and not adjectival($node)) or
                                                        ($condition eq "notn&notrstr" and $tag!~/^..N/ and not adjectival($node)) or
                                                            ($condition eq "coref&rstr" and $coref and adjectival($node)) or
                                                                ($condition eq "coref&notrstr"  and $coref and not adjectival($node)) or
                                                                    ($condition eq "notcoref&rstr"  and not $coref and adjectival($node)) or
                                                                        ($condition eq "notcoref&notrstr"  and not $coref and not adjectival($node)) or
                                                                            ($condition eq "coref&plur" and $coref and $plur) or
                                                                                ($condition eq "coref&notplur" and $coref and not $plur) or
                                                                                    ($condition eq "notcoref&plur" and not $coref and $plur) or
                                                                                        ($condition eq "notcoref&notplur" and not $coref and not $plur)
                                                                                    )
}


# prevod privlastnovaciho adjektiva na substantivum (Karluv -> Karel)
sub possadj_to_noun ($) {
    my $adj_mlemma = shift;
    $adj_mlemma =~/\^\(\*(\d+)(.+)?\)/;
    my $cnt = $1;
    my $suffix = $2;
    my $noun_mlemma = $adj_mlemma;
    $noun_mlemma =~s/\_.+//;
    $noun_mlemma =~s/.{$cnt}$/$suffix/;
    $noun_mlemma =~s/\-.+//;

    # ??? co s timhle: ???
    #  $node->{t_lemma}=~/^(.)/; # prevezme velikost prvniho pismene z t_lemmatu, nikoli z lemmatu (pokud se lisi jen velikosti)
    #  my $origfirstletter=$1;
    #  $newt_lemma=~/^(.)/;
    #  my $newfirstletter=$1;
    #  if ($newfirstletter ne $origfirstletter and lc($newfirstletter) eq lc($origfirstletter)) {
    #    $newt_lemma=~s/^./$origfirstletter/;
    #  }
    return $noun_mlemma;
}

# zda je uzel v pozici syntaktickeho adjektiva

my %adjectival; # vypocet je pomaly a opakuje se, proto vysledky cachuju
sub adjectival($) {
    #  return 1; #??????????????
    my $t_node = shift;
    if (defined $adjectival{$t_node}) {
        return $adjectival{$t_node};
    }

    my ($parent)=(PML_T::GetEParents($t_node));
    $adjectival{$t_node} =
        (
            grep {$_->attr('m/tag') =~ /^A/} PML_T::GetANodes($t_node) or
                $t_node->{'gram/sempos'}=~/^n/ or
                    $t_node->{functor}=~/EFF|RSTR/ or
                        ($t_node->{functor} eq "COMPL" and $t_node->{temp_lex_tag}!~/^C[l=]/) or # ???
                            ($t_node->{functor} eq "PAT" and ($parent->{t_lemma}=~/^(být|bývat|zůstat|zůstávat|stát_se|stávat_se|#Emp|#EmpVerb)$/)));
    return $adjectival{$t_node};
}


# u finitnich slovesnych tvaru zjisti gramaticky cas
sub tense ($) {
    my $t_node = shift;
    my $tense;

    if ($t_node->{temp_lex_tag} =~ /^V/) {
        my @verb_a_nodes = grep {$_->attr('m/tag') =~ /^V/} PML_T::GetANodes($t_node);

        # jen pro finitni tvary
        if (grep {$_->attr('m/tag') =~ /^V[Bpqt]/} @verb_a_nodes) { #!!!!!!! ubral jsem zatim Vs a Vi

            # minuly cas
            if (grep {$_->attr('m/tag')=~/^Vp/} @verb_a_nodes and not grep {$_->attr('m/tag')=~/^Vc/} @verb_a_nodes) {
                $tense = 'ant'
            }

            # minuly kondicional - byval by prisel
            elsif (grep {$_->attr('m/lemma') !~ /^(být|bývat.*)$/ and $_->attr('m/tag') =~ /^Vp/} @verb_a_nodes
                       and grep{$_->{t_lemma}=~/^(být|bývat.*)$/ and $_->attr('m/tag')=~/^Vp/} @verb_a_nodes
                           and grep {$_->attr('m/tag')=~/^Vc/} @verb_a_nodes) {
                $tense = 'ant';
            }

            # budouci cas slozeny
            elsif ((grep {$_->attr('m/lemma') eq "být" and lc($_->attr('m/form')) =~ /^(ne)?b/ and $_->attr('m/tag')=~/^VB/} @verb_a_nodes)
                       and (grep {$_->attr('m/tag')=~/^Vf/} @verb_a_nodes)) {
                $tense = 'post';
            }

            # budouci cas slovesa byt
            elsif (@verb_a_nodes == 1 and $t_node->{t_lemma} =~ /^být$/
                       and $verb_a_nodes[0]->attr('m/tag')=~/^VB......F/) { #and lc($t_node->{temp_lex_form})=~/^(ne)?b/) {
                $tense = 'post';
            }

            # budouci cas tvoreny prefixaci - pujdu,nepojedu...
            elsif (@verb_a_nodes==1 and $t_node->{t_lemma} !~ /^p/ and lc($t_node->{temp_lex_form})=~/^(ne)?p/) {
                $tense = 'post';
            }

            # budouci cas perfektiv
            elsif (grep {$_->attr('m/tag')=~/^VB/ # and $_->{_t_lemma_}=~/^([^_]+)/ #??? co to je?
                             and perfective($1)} @verb_a_nodes) {
                $tense = 'post';
            }

            # budouci cas - trpny rod
            elsif ((grep {$_->attr('m/tag')=~/^Vs/} @verb_a_nodes) and
                       (grep {$_->attr('m/lemma') eq "být" and $_->attr('m/tag')=~/^VB/
                                  and lc($_->attr('m/form')) =~ /^(ne)?b/} @verb_a_nodes)) {
                $tense = 'post';
            }

            # fallback pro zbytek
            else {
                $tense='sim';
            }

            # ?????
            #      if ($report){print "veta: ".PDT::get_sentence_string_TR()."\n".
            #	"slovesna forma: ".(join " ",map {$_->{form}} @verb_a_nodes)."\n".
            #	    "hlavni lemma: ".$node->{_t_lemma_}."\n".
            #	  "tense: $tense\naid: ".$node->{AID}."\n\n";}

            return $tense;
        }
    }
}


sub set_gn_by_verb_agreement ($$) {

    my ($t_node,$attr) = @_;
    my ($parent) = PML_T::GetEParents($t_node);

    if ($t_node->{functor} eq "ACT" # jako ACT jsem kandidat na subjekt, protoze
            and $parent->{temp_lex_tag}=~/^V[^s]/ # rodic je sloveso (ne v pasivu)
                and $t_node->{temp_lex_tag}!~/^....[2-7]/ # pokud mam vubec tag a pad, neni to jiny nez nominativ
                    and not grep {$_ ne $t_node and ($_->{temp_lex_afun} eq "Sb" or $_->{functor} eq "ACT")} PML_T::GetEChildren($parent) # a neni jiny kandidat
                ) {
        if ($report) {
            print "KKK\t";Position();
        }
        #    my @verbnodes=grep {$_ and $_->{tag}=~/^V/} map {$aid2node{$_}} (split /\|/,($parent->{AIDREFS}||$parent->{AID}));

        my @anodes = PML_T::GetANodes($parent);
        my @verb_a_nodes = grep {$_->attr('m/tag') =~ /^V/} PML_T::GetANodes($parent);

        # ??? tohle zlobi, nezjistuje to kategorie ze shody dobre
        #    print "QQQ1 verbanodes: anodes=".(join " ".map{$_->attr('m/form')}@anodes)." verbanodes=".(join " ".map{$_->attr('m/form')}@anodes)."\n";

        my $adjective; # shoda se prejima pripadne i ze jmenne casti prisudku
        if ($parent->{t_lemma} eq "být" and
                ($adjective)=grep{$_->{functor} eq "PAT" and $_->{temp_lex_tag}=~/^AA/} PML_T::GetEChildren($parent)) {
            push @verb_a_nodes,$adjective;
        }

        my $changed;

        if ($attr eq "gender") {
            #      print "QQQ2\n";
            if ($report) {
                print "UUU\t";Position();
            }
            my ($gender) = map {$_->attr('m/tag')=~/^..(.)/;$1} grep {$_->attr('m/tag')=~/^..[FNIM]/} @verb_a_nodes;

            if ($gender) {
                #	print "QQQ3 $gender\n";
                if ($report) {
                    print "GGG\t"; Position();
                }
                set_attr($t_node,'gram/gender',$tgender2ggender{$gender},'X001');
                $changed++;
            } elsif ($t_node->attr('gram/person') eq "1" and
                         ($gender) = map {$_->attr('m/tag')=~/^..(.)/;$1} grep {$_->attr('m/tag')=~/^..[Y]/} @verb_a_nodes) {
                set_attr($t_node,'gram/gender','anim','X002');
                $changed++;
                if ($report) {
                    print "OOOO\t"; # ### ??? vycistit
                    Position();
                }
            }
        } elsif ($attr eq "number") {
            my ($number) = map {$_->attr('m/tag');$1} grep {$_->attr('m/tag')=~/^...[PS]/} @verb_a_nodes;
            if ($number) {
                if ($report) {
                    print "NNN\t"; ### ??? vycistit
                    Position();
                }
                set_attr($t_node,'gram/number',$tnumber2gnumber{$number},'X003');
                $changed++;
            }
        }
        return $changed;
    }
    return 0;
}


sub set_gn_by_adj_agreement ($$) {
    my ($t_node, $attr) = @_;
    my (@adjectivals) = grep {$_->{temp_lex_tag}=~/^[APC][^Pd][^-][^-]/} PML_T::GetEChildren($t_node);
    my $value;
    if ($attr eq 'gender') {
        my ($tgenderadj) = map {$_->{temp_lex_tag}=~/^..(.)/;$1} grep {$_->{temp_lex_tag}=~/^..[FNIM]/} @adjectivals;
        $value=$tgender2ggender{$tgenderadj};
        set_attr($t_node,'gram/gender',$value,'X004');
    } elsif ($attr eq 'number') {
        my ($tnumberadj) = map {$_->{temp_lex_tag}=~/^...(.)/;$1} grep {$_->{temp_lex_tag}=~/^...[PS]/} @adjectivals;

        if (not $tnumberadj) {
            if (grep {$_->{temp_lex_tag}=~/^C=/ and $_->{temp_lex_form}==1 and $_->{temp_lex_ord}<$t_node->{temp_lex_ord}} @adjectivals) {
                $tnumberadj='S'
            } elsif (grep {$_->{temp_lex_tag}=~/^C=/ and $_->{temp_lex_form}>1 and $_->{temp_lex_ord}<$t_node->{temp_lex_ord}} @adjectivals) {
                $tnumberadj='P'
            } elsif (grep {$_->{temp_lex_tag}=~/^(Dg|Cd)/} @adjectivals) { # dvoje,hodne, malo, vice => plural
                $tnumberadj='P'
            }
        }

        $value = $tnumber2gnumber{$tnumberadj};
        set_attr($t_node,'gram/number',$value,'X005');
    }
    return $value;
}


# --------------------------------------------------------------------------------------------------------------------------------
# pro uzly semn.pron.indef, ktere maji afun Sb a nejsou vztazne, doplni (prebije) person,gender,number  podle shody se slovesem
# (napr. ve vetach "Kdo jsem byla","Vsichni jste....")
sub set_indefpron_pgn_by_verb_agreement ($) {
    my ($t_node) = @_;
    my ($parent) = PML_T::GetEParents($t_node);

    if ($t_node->attr('gram/sempos') eq "n.pron.indef" and $t_node->{g_person}!~/1|2|inher/ and $t_node->{temp_lex_afun}=~/^Sb/) {

        my @verb_a_nodes = grep {$_->attr('m/tag') =~ /^V/ or $_->attr('m/lemma')=~/^(aby|kdyby)/} PML_T::GetANodes($t_node);

        my $adjective;
        if ($parent->{t_lemma} eq "být" and
                ($adjective) = grep{$_->{functor} eq "PAT" and $_->{temp_lex_tag}=~/^AA/} PML_T::GetEChildren($parent)) {
            push @verb_a_nodes,$adjective;
        }

        my $change;

        my ($person)=grep {$_} map{$_->attr('m/tag')=~/^V......([12])/;$1} @verb_a_nodes;
        if ($person and $person ne $t_node->attr('gram/person')) {
            set_attr($t_node,'gram/person',$person,'X006');
            $change++;
        }

        my ($gender) = grep {$_} map{$_->attr('m/tag')=~/^..([MINF])/;$tgender2ggender{$1}} @verb_a_nodes;
        if ($gender and $gender ne $t_node->attr('gram/gender')) {
            set_attr($t_node,'gram/gender',$gender,'X007');
            $change++;
        }

        my ($number)=grep {$_} map{$_->attr('m/tag')=~/^...([PS])/;$tnumber2gnumber{$1}} @verb_a_nodes;
        if ($number and $number ne $t_node->{g_number}) {
            set_attr($t_node,'gram/number',$number,'X008');
            $change++;
        }

        #    Position if $change;
    }
}


# -----------------------------------------------------------------------------------------------------------------------------
# pro veskera semanticka substantiva v subjektove pozici vyplni dosud chybejici gender/number podle shody se slovesem
sub set_missing_gn_by_verb_agreement ($) {
    my ($t_node)=@_;
    #  my ($parent)=PDT::GetFather_TR($t_node);
    my ($parent)=PML_T::GetEParents($t_node);
    if ($t_node->attr('gram/sempos')=~/^n/ and $t_node->{temp_lex_afun}=~/^Sb/ and $t_node->{t_lemma} ne "#PersPron") {

        my @verb_a_nodes = grep {$_->attr('m/tag') =~ /^V/ or $_->attr('m/lemma')=~/^(aby|kdyby)/} PML_T::GetANodes($t_node);

        my $adjective;
        if ($parent->{t_lemma} eq "být" and
                ($adjective) = grep{$_->{functor} eq "PAT" and $_->{temp_lex_tag}=~/^AA/} PML_T::GetEChildren($parent)) {
            push @verb_a_nodes,$adjective;
        }

        my $change;

        if ($t_node->attr('gram/gender')=~/^(|nr)$/) {
            my ($gender)=grep {$_} map{$_->attr('m/tag')=~/^..([MINF])/;$tgender2ggender{$1}} @verb_a_nodes;
            if ($gender and $gender ne $t_node->attr('gram/gender')) {
                set_attr($t_node,'gram/gender',$gender,'X009');
                $change++;
            }
        }

        if ($t_node->attr('gram/number')=~/^(|nr)$/ and $parent eq $t_node->parent) { # cislo se neda spolehlive tahat, kdyz jde o koordinaci
            my ($number) = grep {$_} map{$_->attr('m/tag')=~/^...([PS])/;$tnumber2gnumber{$1}} @verb_a_nodes;
            if ($number and $number ne $t_node->attr('gram/number')) {
                set_attr($t_node,'gram/number',$number,'X010');
                $change++;
            }
        }

        #    if ($change) {print "set_missing\t";Position} # overeno
    }
}


# podruhe: preklad casti tagu na hodnotu gramatemu (navazuje na tabulky u set_gn...
my %tdegree2gdegree = ('1' => 'pos', '2' => 'comp', '3' => 'sup', '-' => 'pos');
my %tnegat2gnegat = ('A' => 'neg0', 'N' => 'neg1', '-' => 'neg0');
my %ajkaaspect2aspect = ('P' => 'cpl', 'I' => 'proc', 'B' => 'nr');

# hodnoty deonticke modality podle lemmatu skryteho slovesa
my %lemma2deontmod = (
    'muset' => 'deb',
    'mít' => 'hrt',
    'chtít' => 'vol',
    'hodlat' => 'vol',
    'moci' => 'poss',
    'dát_se' => 'poss',
    'dát' => 'poss',            # (pro jistotu)
    'smět' => 'perm',
    'dovést' => 'fac',
    'umět' => 'fac'
);

# rody nekterych cislovek vyjadrenych slovem
my %numerallemma2gender = (
    'sto' => 'neut',
    'tisíc' => 'inan',
    'milion' => 'inan',
    'milión' => 'inan',
    'miliarda' => 'fem',
    'bilion' => 'inan',
    'bilión' => 'inan'
);

# -----------------------------------------------------------
# centralni procedura pro vyplneni gramatemu u komplexnich uzlu
sub assign_automatic_grammatemes ($) {

    my $t_node = shift;

    my $tag = $t_node->{temp_lex_tag};
    my ($tpos,$tsubpos,$tgender,$tnumber,$tcase,$tposgender,$tposnumber,$tperson,$ttense,$tdegree,$tnegat) = split "",$tag;
    my $t_lemma = $t_node->{t_lemma};
    my $form = $t_node->{temp_lex_form};
    my $m_lemma = $t_node->{temp_lex_lemma};
    $m_lemma=~s/(.+)([-_`].+)/$1/g;
    my $functor = $t_node->{functor};

    my $parent;
    if ($t_node->parent) {
        ($parent) = PML_T::GetEParents($t_node)
    }

    # ------------- jednotlive tridy komplexnich uzlu -----------


    if ($t_node->{t_lemma} eq "#EmpNoun") {
        set_attr($t_node,'gram/sempos','n.pron.def.demon','X011');
        set_gn_by_adj_agreement($t_node,'gender');
        set_gn_by_adj_agreement($t_node,'number');
    }

    #  adjektiva udelana ze slovesnych pricesti
    elsif ($tag=~/^V/ and $t_node->{t_lemma}=~/[ýí]$/) {
        set_attr($t_node,'gram/sempos','adj.denot','X012');
        set_attr($t_node,'gram/degcmp','pos','X013');
        #    set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat});
    }

    # ciselne vyrazy nejrozlicnejsich tagu, ktere ale chceme zpracovat po svem (osetreno vice_mene)
    elsif ($t_lemma!~/_/ and ($t_lemma=~/^(málo|nemálo|mnoho|nemnoho|hodně|nejeden|bezpočet|bezpočtu)$/ or
                                  ($tag=~/^[^N]/ and $t_lemma=~/^(moc|pár)$/))) {
        set_attr($t_node,'gram/sempos','adj.quant.grad','X014');
        my $degree = $tdegree2gdegree{$tdegree};
        $degree = "pos" unless $degree;
        set_attr($t_node,'gram/degcmp',$degree,'X015');
        set_attr($t_node,'gram/numertype','basic','X016');
    }

    # castice "asi" a "až"
    elsif ($t_lemma=~/^(asi|až|ani|i|nehledě|jen|jenom)$/) {
        set_attr($t_node,'gram/sempos','adv.denot.ngrad.nneg','X017');
    }


    # -------------- osobni zajmena

    # ---- A.1. (i) povrchove realizovana osobni zajmena

    elsif ($tag=~/^P[P5H]/ and surface($t_node)) {
        if ($report) {
            print "Applied A.1\n";
        }
        set_attr($t_node,'t_lemma','#PersPron','X018');
        set_attr($t_node,'gram/sempos','n.pron.def.pers','X019');
        set_attr($t_node,'gram/person',$tperson,'X020');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X021');
        set_attr($t_node,'gram/politeness','basic','X022');
        if ($tperson eq '3') {
            if ($tgender2ggender{$tgender}) {
                set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X023');
            } else {
                #	  set_gn_by_verb_agreement($t_node,'gender')
            }
        } else {
            set_gn_by_verb_agreement($t_node,'gender')
        }
    }

    # ---- A.1. (ii) povrchove nerealizovana osobni zajmena (??? to je cele divne, ty asi nebudou nijak odlisena)

    elsif ($t_lemma=~/^(já|my|ty|vy|on|#PersPron)$/ and not surface($t_node)) {
        set_attr($t_node,'gram/sempos','n.pron.def.pers');
        set_gn_by_verb_agreement($t_node,'number');
        set_gn_by_verb_agreement($t_node,'gender');
        set_attr($t_node,'gram/politeness','basic');
        set_attr($t_node,'gram/person','3');
        #??? dodelat osoby
        #       set_attr($t_node,'t_lemma','#PersPron');

        #       set_attr($t_node,'gram/politeness','basic');

        #       # person
        #       if ($m_lemma=~/(já|my)/) {
        # 	set_attr($t_node,'gram/person','1');
        #       }
        #       elsif ($m_lemma=~/(ty|vy)/) {
        # 	set_attr($t_node,'person','2');
        #       }
        #       else {
        # 	set_attr($t_node,'person','3');
        #       };

        #       # number
        #       if ($t_node->{number}=~/^(SG|PL)/) {   # kde by se tu vzal???
        # 	set_attr($t_node,'number',lc($t_node->{number}));
        #       }
        #       else {
        # 	set_gn_by_verb_agreement($t_node,'number');
        #       }

        #       # gender
        #       if ($t_lemma eq "on" and $t_node->{gender}=~/^(ANIM|INAN|FEM|NEUT)/) {
        # 	set_attr($t_node,'gender',lc($t_node->{gender}))
        #       } else {
        # 	set_gn_by_verb_agreement($t_node,'gender');
        # #	manual ($t_node,'gender');
        #       }
    }

    # ---- A.2. posesivni zajmena
    elsif ($tag=~/^PS/) {
        set_attr($t_node,'t_lemma','#PersPron','X023');
        set_attr($t_node,'gram/sempos','n.pron.def.pers','X024');
        set_attr($t_node,'gram/person',$tperson,'X025');
        set_attr($t_node,'gram/politeness','basic','X026');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tposnumber},'X027');
        if ($tperson eq "3") {
            if ($tgender2ggender{$tposgender}) {
                set_attr($t_node,'gram/gender',$tgender2ggender{$tposgender},'X028')
            }
        }
    }

    # --- zvratna zajmena
    elsif ($tag=~/^P[678]/ and $t_node->{functor} ne "DPHR") {
        set_attr($t_node,'t_lemma','#PersPron','X029');
        set_attr($t_node,'gram/sempos','n.pron.def.pers','X030');
        set_attr($t_node,'gram/number','inher','X031');
        set_attr($t_node,'gram/gender','inher','X032');
        set_attr($t_node,'gram/person','inher','X033');
        set_attr($t_node,'gram/politeness','inher','X034');
    }

    # --- A.3. posesivni adjektiva
    elsif ($tag=~/^AU/) {
        set_attr($t_node,'gram/sempos','n.denot','X035');
        if ($t_lemma=~/^(.+)_/) { # von_Ryanuv, de_Gaulluv
            my $prefix=$1;
            set_attr($t_node,'t_lemma',$prefix."_".possadj_to_noun($t_node->{temp_lex_lemma}),'X036');
        } else {                # Masarykuv
            set_attr($t_node,'t_lemma',possadj_to_noun($t_node->{temp_lex_lemma}),'X037');
        }
        set_attr($t_node,'gram/number','sg','X038');
        set_attr($t_node,'gram/gender',$tgender2ggender{$tposgender},'X039');
    }

    # --- A.4. prevadeni adjektiv vzniklych z adverbii apod. --- to se nebude delat

    
    # B.5 a B.8
    elsif ($t_lemma=~/^(tisíc|mili.n|miliarda|bili.n)$/) {
        #      set_attr($t_node,'t_lemma',$t_lemma);
        set_attr($t_node,'gram/sempos','n.quant.def','X040');
        set_attr($t_node,'gram/numertype','basic','X041');
        set_attr($t_node,'gram/gender',$numerallemma2gender{$t_lemma},'X042');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X043');
    } elsif ($t_lemma eq "sto") {
        #      set_attr($t_node,'t_lemma',$t_lemma);
        set_attr($t_node,'gram/sempos','n.quant.def','X044');
        set_attr($t_node,'gram/numertype','basic','X045');
        set_attr($t_node,'gram/gender','neut','X046');
        if ($form=~/^(sto|stu|stem|sta)/) {
            set_attr($t_node,'gram/number','sg','X047');
        } else {
            set_attr($t_node,'gram/number','pl','X048');
        }
    }


    # --- B.1. pojmenovaci substantiva
    elsif ($tag=~/^N/) {

        if ($t_lemma=~/(ní|tí|ost)$/ and not $nonnegable_semn{$t_lemma}) {
            set_attr($t_node,'gram/sempos','n.denot.neg','X049');
            #	set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat});
        } else {
            set_attr($t_node,'gram/sempos','n.denot','X050');
        }

        #      set_attr($t_node,'t_lemma',$t_lemma);
        set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X051');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X02');

        #      if (not $tnumber2gnumber{$tnumber} and   ### ???? was war tas?
        #	  $t_node->{_t_lemma_}=~/^.R$/ and $t_node->{tag}=~/^..F/) {
        #	set_attr($t_node,'number','sg');
        #      }

        if ($t_node->{temp_lex_afun} eq "Sb" and $t_node->parent->{temp_lex_tag}=~/^V/) { # doplneni rodu a cisla (pokud chybi), ze shody se slovesem
            my $changed;
            if ($t_node->attr('gram/gender') =~ /^(|nr)$/) {
                set_gn_by_verb_agreement($t_node,'gender');
                $changed++;
            }
            if ($t_node->attr('gram/number') =~ /^(|nr)$/) {
                set_gn_by_verb_agreement($t_node,'number');
                $changed++;
            }
            #	Position if $changed;

        }
    }

    # --- B.5 ----
    elsif ($tag =~ /^Cd/) {
        set_attr($t_node,'gram/sempos','adj.quant.def','X053');
        if ($form=~/.+jí/i) {   # dvoji, troji, oboji
            set_attr($t_node,'gram/numertype','kind','X054');
        } else {                # dvoje, troje, oboje
            set_attr($t_node,'gram/numertype','set','X055');
        }
    } elsif ($tag =~ /^C[ln]/) { # zakladni: jedna,dve, Honza de
        #      set_attr($t_node,'t_lemma',$t_lemma); ?
        if ($functor !~ /COMPL|EFF|RSTR/ and not
                ($functor eq "PAT" and $parent->{temp_lex_lemma} eq "být")) {
            set_attr($t_node,'gram/sempos','n.quant.def','X056');
            if ($t_node->{t_lemma} eq "jeden") {
                set_attr($t_node,'gram/number','sg','X057')
            } else {
                set_attr($t_node,'gram/number','pl','X058')
            }
            set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X059'); # ??? od ctyrky to stejne nefunguje, vzal to cert
        } else {
            set_attr($t_node,'gram/sempos','adj.quant.def','X060');
        }
        set_attr($t_node,'gram/numertype','basic','X061');
    } elsif ($tag=~/^C=/ and $t_lemma=~/^(.+)_(krát|x)$/) { # puvodni t_lemma "158_krat" - asi predelat na AIDREFS
        set_attr($t_node,'t_lemma',$1,'X062');
        set_attr($t_node,'gram/sempos','adj.quant.def','X063');
        set_attr($t_node,'gram/numertype','basic','X064');

    }

    # cislice (arabske i rimske)
    elsif ($tag =~ /^C[=}]/) {
        #    set_attr($t_node,'t_lemma',$t_lemma);

        if ($functor eq "RSTR" and $t_node->{temp_lex_ord} > $parent->{temp_lex_ord}
                and $parent->{t_lemma}=~/^(rok|číslo|telefon|fax|tel|PSČ|paragraf|odstavec|odst|sbírka|č|zákon|vyhláška|sezona)$/) {
            set_attr($t_node,'gram/sempos','n.quant.def','X065');
            set_attr($t_node,'gram/number','nr','X066');
            set_attr($t_node,'gram/gender','nr','X067');
            if ($report) {
                print "WWW\t";Position();
            }
        } elsif (adjectival($t_node)) {
            set_attr($t_node,'gram/sempos','adj.quant.def','X068')
        } else {
            set_attr($t_node,'gram/sempos','n.quant.def','X069');
            set_attr($t_node,'gram/number','nr','X070');
            set_attr($t_node,'gram/gender','nr','X071');
        }

        if (grep {$_->{temp_lex_form} eq "."} $t_node->children) { # radeji pres AIDREFS ???
            set_attr($t_node,'gram/numertype','ord','X072');
        } else {
            set_attr($t_node,'gram/numertype','basic','X073')
        }
    } elsif ($tag =~ /^Cy/) { # pětina, wordclass a numertype a tlemma dostanou z konv.souboru
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X073');
        set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X074');
    } elsif ($tag =~ /^Ch/) {   # jedny/nejedny
        set_attr($t_node,'gram/sempos','adj.quant.def','X075');
        set_attr($t_node,'gram/numertype','set','X076');
    }

    # substantivne pouzita adjektiva
    elsif ($tag =~ /^A/ and $functor!~/^(FPHR|ID)/ and not adjectival($t_node) and $parent->{t_lemma}!~/[tn]í$/) {
        set_attr($t_node,'gram/sempos','n.denot','X077');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X078');
        set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X079');
    }

    # --- B.6. adjektiva pojmenovavaci
    elsif ($tag=~/^A[AG2MC]/) {
        set_attr($t_node,'gram/sempos','adj.denot','X080');
        #      set_attr($t_node,'t_lemma',$t_lemma);
        set_attr($t_node,'gram/degcmp',$tdegree2gdegree{$tdegree},'X081');
        #      set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat});
    }

    # --- B.11-B.14 adverbia
    elsif ($tag=~/^D/) {
        if ($adv2adj{$t_lemma} and 0) { # !!! vypnute prevadeni adverbii na adjektiva (v angl. to ted taky nedelam)
            set_attr($t_node,'gram/sempos','adj.denot','X082');
            set_attr($t_node,'t_lemma',$adv2adj{$t_lemma},'X083');
            set_attr($t_node,'gram/degcmp',$tdegree2gdegree{$tdegree},'X084');
            set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat},'X085');
        } elsif ($pronomadv{$t_lemma}) { # tohle by se nikdy nemelo stat, to by mel prebit konverzni soubor!!!
            set_attr($t_node,'gram/sempos','adv.pron.def','X086'); # 'adv.pron.???'
            #	set_attr($t_node,'t_lemma',$t_lemma);
        } elsif ($nongradadv{$t_lemma}) {
            if ($notnegableadv{$t_lemma}) { # 1. nestupnovatelna nenegovatelna - alespon
                set_attr($t_node,'gram/sempos','adv.denot.ngrad.nneg','X087');
            } else {          # 2. nestupnovatelna negovatelna - jinak
                set_attr($t_node,'gram/sempos','adv.denot.ngrad.neg','X088');
                set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat},'X090'),
            }
            #	set_attr($t_node,'t_lemma',$t_lemma);

        } else {
            if ($notnegableadv{$t_lemma}) { # 3. stupnovatelna nenegovatelna - pozde
                set_attr($t_node,'gram/sempos','adv.denot.grad.nneg','X091');
            } else {            # 4. stupnovatelna negovatelna - rad
                set_attr($t_node,'gram/sempos','adv.denot.grad.neg','X092');
                set_attr($t_node,'gram/negation',$tnegat2gnegat{$tnegat},'X093');
            }
            #	set_attr($t_node,'t_lemma',$t_lemma);
            set_attr($t_node,'gram/degcmp',$tdegree2gdegree{$tdegree},'X094');
        }

    }

    # ------------- slovesa
    elsif ($tag=~/^V/) {
        set_attr($t_node,'gram/sempos','v','X095');
        #      set_attr($t_node,'t_lemma',$t_lemma);

        set_attr($t_node,'gram/iterativeness','it0','X096');
        if ($t_lemma=~/^([^\_]+)/) {
            if ($ajkaaspect2aspect{$verbal_aspect{$1}}) {
                set_attr($t_node,'gram/aspect',$ajkaaspect2aspect{$verbal_aspect{$1}},'X097');
            } else {
                set_attr($t_node,'gram/aspect','proc','X098');
            }
        }
        # pokud neni v seznamu, tak co!!!

        my @verb_a_nodes = grep {$_->attr('m/tag') =~ /^V/} PML_T::GetANodes($t_node);

        if (grep {$_->attr('m/tag') =~ /^V.........N/} @verb_a_nodes) { # narozdil od PDT 2.0 je tu negace gramatem i u sloves!
            #	                               VpYS---XR-N
            set_attr($t_node,'gram/negation','neg1','X122');
            #	print STDERR "QQQ Slovesna Negace nalezena\n";
        }


        # --------- B.15. v.fin ------------------
        if (grep {$_->attr('m/tag')=~/^V[Bpqt]/} @verb_a_nodes) { # !!!!!!! smazal jsem Vi a Vs

            # --- dispozicni modalita
            #if ($t_node->attr('gram/dispmod') eq "DISP") { set_attr($t_node,'dispmod','disp1');  } # ocekavana rucni anotace, blbost
            #else {
            set_attr($t_node,'gram/dispmod','disp0','X099');
            #}

            # --- vyplneni verbmod a tense
            if (grep {$_->attr('m/tag')=~/^Vc/ or $_->{lemma}=~/^(aby|kdyby)$/} @verb_a_nodes) { # kondicional
                set_attr($t_node,'gram/verbmod','cdn','X100');
                if (1 < grep {$_->attr('m/tag') =~ /^Vp/} @verb_a_nodes) {
                    set_attr($t_node,'gram/tense','ant','X101');
                } else {
                    set_attr($t_node,'gram/tense','sim','X102');
                }
            } else {            # nekondicional -> indikativ
                set_attr($t_node,'gram/verbmod','ind','X103');
                set_attr($t_node,'gram/tense',tense($t_node),'X104');
            }
        }
        # -------- B.16. v.imp -------------------------
        elsif (grep {$_->attr('m/tag') =~ /^Vi/} @verb_a_nodes) {
            set_attr($t_node,'gram/dispmod','nil','X105');
            set_attr($t_node,'gram/verbmod','imp','X106');
            set_attr($t_node,'gram/tense','nil','X107');
        }

        # -------- B.17. v.trans --------------
        elsif (grep {$_->attr('m/tag') =~ /^V([em])/} @verb_a_nodes) {
            if ($1 eq "m") {
                set_attr($t_node,'tense','ant','X108');
            } else {
                set_attr($t_node,'gram/tense','sim','X109');
            }
            set_attr($t_node,'gram/dispmod','nil','X110');
            set_attr($t_node,'gram/verbmod','nil','X111');
        }

        # -------- B.16. v.inf -------------------------
        else {
            set_attr($t_node,'gram/dispmod','nil','X112');
            set_attr($t_node,'gram/verbmod','nil','X113');
            set_attr($t_node,'gram/tense','nil','X114');
        }

        if ($t_node->attr('gram/verbmod') eq "") {
            set_attr($t_node,'gram/verbmod','nil','X115');
        }
        ;
        if ($t_node->attr('gram/tense') eq "") {
            set_attr($t_node,'gram/tense','nil','X116');
        }
        ;
        if ($t_node->attr('gram/dispmod') eq "") {
            set_attr($t_node,'gram/dispmod','nil','X117');
        }
        ;

        # auxverbs!=verbnodes - samotne 'chtit' nebo 'muset' totiz nema dostat zadnou zvlastni modalitu

        my @auxverbs = grep {$_->attr('m/tag')=~/^V/} map {PML_T::GetANodeByID($_)}  @{$t_node->attr('a/aux.rf')}
            if defined $t_node->attr('a/aux.rf'); # gracefully ignore bad input

        #      my @auxverbs=grep {$_ and $_->{tag}=~/^V/} map {$aid2node{$_}} (split /\|/,$t_node->{AIDREFS});

        # zjisteni deonticke modality
        my ($deontmod) = grep {$_} map {$_->attr('m/lemma')=~/^([^_\-]+)/;$lemma2deontmod{$1}} @auxverbs;
        if ($deontmod) {
            set_attr($t_node,'gram/deontmod',$deontmod,'X118')
        } else {
            set_attr($t_node,'gram/deontmod','decl','X119')
        }

        # zjisteni resultativnosti
        if ($t_node->{temp_lex_tag}=~/^Vs/ and grep {$_->attr('m/lemma')=~/^(mít)/} @auxverbs) { # zruseno byt
            set_attr($t_node,'gram/resultative','res1','X120')
        } else {
            set_attr($t_node,'gram/resultative','res0','X121')
        }

    }


    # tohle je uz jen garbage
    #   elsif ($t_node->{func} eq "ID" or ($t_node->{tag}=~/^T/ and $t_node->{func}=~/^(ACT|PAT|EFF|ORIG)/)) {
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{tag}=~/^[TI]/ and $t_node->{func}=~/(PAT|RSTR)/) {
    #     set_attr($t_node,'gram/sempos','adj.denot');
    #     set_attr($t_node,'degcmp','nr');
    #     set_attr($t_node,'negation','nr');
    #   }

    #   elsif ($t_node->{tag}=~/^I/ and $t_node->{func}=~/(PRED)/) {
    #     set_attr($t_node,'gram/sempos','v');
    #     set_attr($t_node,'verbmod','ind');
    #     set_attr($t_node,'deontmod','decl');
    #     set_attr($t_node,'dispmod','disp0');
    #     set_attr($t_node,'tense','sim');
    #     set_attr($t_node,'aspect','proc');
    #     set_attr($t_node,'resultative','res0');
    #     set_attr($t_node,'iterativeness','it0');
    #   }

    #   elsif ($t_node->{form} eq "=") {
    #     set_attr($t_node,'gram/sempos','v');
    #     set_attr($t_node,'verbmod','ind');
    #     set_attr($t_node,'deontmod','decl');
    #     set_attr($t_node,'dispmod','disp0');
    #     set_attr($t_node,'tense','sim');
    #     set_attr($t_node,'aspect','proc');
    #     set_attr($t_node,'resultative','res0');
    #     set_attr($t_node,'iterativeness','it0');
    #   }

    #   elsif ($t_node->{tag}=~/^[TI]/) {
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{tag}=~/^X/ and "RSTR") {
    #     set_attr($t_node,'gram/sempos','adj.denot');
    #     set_attr($t_node,'degcmp','nr');
    #     set_attr($t_node,'negation','nr');
    #   }

    #   elsif (($t_node->{tag}=~/^X/ or $t_node->{_t_lemma_}=~/^(ad|do|ob)$/) and "PAR") {
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{_t_lemma_} eq "a" and $t_node->{func} eq "RSTR") {
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{_t_lemma_}=~/^pro(ti)?$/) {
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{tag}=~/^R/ and $t_node->{func}=~/(EXT|DIR|LOC)/) { # spatne tagovane kolem,okolo
    #     set_attr($t_node,'gram/sempos','adv.denot.ngrad.nneg');
    #   }

    #   elsif ($t_node->{tag}=~/^R...\d/ and $t_node->{func}=~/(RSTR|ACT|TWHEN)/) { # spatne tagovane misto,po,k,z
    #     set_attr($t_node,'gram/sempos','n.denot');
    #     set_attr($t_node,'gender','nr');
    #     set_attr($t_node,'number','nr');
    #   }

    #   elsif ($t_node->{_t_lemma_}=~/^(de_facto|ad_hoc|a_podobně|a_priori|co_daleko|co_daleko_ten|co_dále_ten|co_dále|jednak|jenže|napospas|plus_minus|pokud_možný|zato)$/) {
    #     set_attr($t_node,'gram/sempos','adv.denot.ngrad.nneg');
    #   }

    #   elsif ($t_node->{tag}=~/^C/) {
    #       set_attr($t_node,'gram/sempos','adj.denot');
    #       set_attr($t_node,'degcmp','pos');
    #       set_attr($t_node,'negation','neg0');
    #   }

    else {
        set_attr($t_node,'gram/sempos','n.denot','X123');
        set_attr($t_node,'gram/gender',$tgender2ggender{$tgender},'X124');
        set_attr($t_node,'gram/number',$tnumber2gnumber{$tnumber},'X125');
    }
}                               # end of assign_automatic_grammatemes



# ---------------------------------------------------------------------------------------------
# doplneni hodnoty nr vsem gramatemum, ktere maji byt vyplnene na zaklade wordclass

sub fill_missing_grammatemes {
    my $node = shift;
    my $wordclass = $node->attr('gram/sempos');
    if ($wordclass) {
        if (defined $applicable_gram{$wordclass}) {
            foreach my $gram (keys %{$applicable_gram{$wordclass}}) {
                if ($node->attr("gram/$gram") eq "") {
                    set_attr($node,"gram/$gram","nr",'X126');
                }
            }
        }
    }
}


# ---------------------------------------------------------------------------------------------
# vyprazdni gramatemy, ktere danemu uzlu podle wordclasu nenalezeji

sub remove_superfluous_grammatemes {
    my $node=shift;
    my $wordclass=$node->attr('gram/sempos');
    foreach my $gram (grep {!/sempos/} grep {not $applicable_gram{$wordclass}{$_}} keys %all_applicable_grams) {
        #    set_attr($node,"gram/$gram",undef,'X127'); # ??? zatim zakomentovano
    }
}


# ---------------------------------------------------------------------------------------------
# aplikace konverznich pravidel ziskanych z (externiho) deklaracniho souboru
# (podle techto pravidel se na zaklade puvodni hodnoty t_lemmatu vyplnuji nektere atributy)
### PRENESENO
sub apply_conversion_rules($) {
    my $t_node = shift;
    my $t_lemma = lc($t_node->{t_lemma});
    my $ord = $t_node->{temp_lex_ord};

    #  if ($t_lemma eq "kolik") {
    #    if ($report) {print "RRR  ".PDT::get_sentence_string_TR($root)."\n";}
    #  };
    #  print "APL1\n";
    if ($t_lemma2attribs{$t_lemma}) {
        #    print "APL2\n";
        foreach my $premise (keys %{$t_lemma2attribs{$t_lemma}}) {

            my $func = $t_node->{functor};
            if ($report) {
                print "Aplikovano pravidlo: ".$origrule{$t_lemma}{$premise}." origt_lemma=$t_lemma ord=$ord premise=$premise func=$func \n";
            }
            if ($premise eq "" or evalpremise($t_node,$premise)) {
                #	if ($t_lemma eq "ten") {if ($report){print "TEN: veta:".PDT::get_sentence_string_TR($root);}}
                if ($report) {
                    print "Zabralo!!",$t_lemma2attribs{$t_lemma}{$premise},"\n";
                }
                set_attr($t_node,'nodetype','complex','X128');
                foreach my $pair (split /,/,$t_lemma2attribs{$t_lemma}{$premise}) {
                    if (my ($name,$value)=split /=/,$pair) {
                        if ($name eq "wordclass") {
                            $name = "sempos"
                        }
                        set_attr($t_node,"gram/$name",$value,'X129');
                    }
                }
            } else {
                if ($report) {
                    print "Fail\n";
                }
            }
        }
    }
}                               # end of apply_conversion_rules




# ---------------------------------------------------------------------------------------------
# dodatecne automaticke upravy (na zaklade toho, co se rozhodlo az konverznimi pravidly)

sub apply_postprocessing ($) {
    my $node = shift;
    my ($tpos,$tsubpos,$tgender,$tnumber,$tcase,$tposgender,$tposnumber,$tperson,$ttense,$tdegree,$tnegat)=split "",$node->{temp_lex_tag};

    # pokud byly konverznimi pravidly rozeznany zlomkove vyrazy (tretina), je potreba
    # doplnit gender a number  ?????
    #  if ($node->attr('gram/sempos') eq "n.quant.def" and $node->{g_wordclass} eq "frac") {
    #    set_attr($node,'gender',$tgender2ggender{$tgender});
    #    set_attr($node,'number',$tnumber2gnumber{$tnumber});
    #  }

    # pokud byly konverznimi pravidly rozeznany uzly N.pron.indef
    if ($node->attr('gram/sempos') eq "n.pron.indef") {
        if ($node->attr('gram/indeftype') eq "relat") {
            set_attr($node,'gram/gender','inher','X130');
            set_attr($node,'gram/number','inher','X131');
            set_attr($node,'gram/person','inher','X132');
        } else {
            if ($tgender2ggender{$tgender}) {
                set_attr($node,'gram/gender',$tgender2ggender{$tgender},'X133')
            } else {            # cosi je defaultne sing.neut.
                set_attr($node,'gram/gender','neut','X134')
            }

            if ($tnumber2gnumber{$tnumber}) {
                set_attr($node,'gram/number',$tnumber2gnumber{$tnumber},'X135')
            } else {
                set_attr($node,'gram/number','sg','X136')
            }

            set_attr($node,'gram/person','3','X137');

            if ($node->{temp_lex_tag}=~/^PQ/) {
                set_attr($node,'gram/gender','neut','X138');
                set_attr($node,'gram/number','sg','X139');
            }
        }
    }

    if ($node->attr('gram/sempos') eq "n.pron.def.demon") {
        set_attr($node,'gram/gender',$tgender2ggender{$tgender},'X140') if $tgender2ggender{$tgender};
        set_attr($node,'gram/number',$tnumber2gnumber{$tnumber},'X141') if $tnumber2gnumber{$tnumber};
    }

    # gramatem negation u pojmenovacich uzlu
    if ($node->attr('gram/sempos')=~/denot/) {
        if ($node->{temp_lex_tag}=~/^..........N/) {
            #      print "sempos=".$node->attr('gram/sempos')."\n";
            set_attr($node,'gram/negation','neg1','X142' );
        } else {
            set_attr($node,'gram/negation','neg0','X143' );
        }
    }

    # nastaveni (pripadne prepsani) osoby, cisla a rodu podle shody podmetu s prisudkem
    if ($node->attr('gram/sempos') eq "n.pron.indef") {
        set_indefpron_pgn_by_verb_agreement($node);
    }

    # nastaveni dosud nevyplneneho  cisla a rodu u vsech semantickych substantiv v sub. pozici podle shody se slovesem.
    if ($node->attr('gram/sempos') and ($node->attr('gram/gender')=~/^(|nr)$/ or $node->attr('gram/number')=~/^(|nr)$/)) {
        set_missing_gn_by_verb_agreement($node);
    }

    # nastaveni dosud nevyplneneho rodu podle shody s adjektivem
    if ($node->attr('gram/sempos')=~/^n/ and $node->attr('gram/gender')=~/^(|nr)$/ ) { #and $node->{AID} ???
        if (set_gn_by_adj_agreement($node,'gender')) {
            #      print "ggg\t$node->{form}\t$node->attr('gram/sempos'\t";Position;  # overeno
        }
    }

    # nastaveni dosud nevyplneneho cisla podle shody s adjektivem
    if ($node->attr('gram/sempos')=~/^n/ and $node->attr('gram/number')=~/^(|nr)$/) { #  and $node->{AID} ???
        if (set_gn_by_adj_agreement($node,'number')) {
            #      print "nnn\t$node->{form}\t$node->attr('gram/sempos'\t";Position; # overeno
        }
    }


    #   # doplneni chybejiciho gender/number u uzlu PersPron na zaklade koreference (dedi se z antecedentu)
    #   # (mela by tu nastat jen textova)
    #   # !!! doplnit pretahovani korefence i opacnym smerem
    #   # (a zkontrolovat, proc se podle koreference nededi pres hranice vety)
    #   my $id=$node->{TID}||$node->{AID};
    #   my $antec=$id2node{$node->{coref}};
    #   if ($node->{t_lemma} eq "&PersPron;" and ($node->{g_number}=~/^(|nr)$/ or $node->{g_gender}=~/^(|nr)$/)
    #       and $node->{coref} and $id2node{$node->{coref}}) {
    #     my $changed;
    #     if ($antec->{g_number} and $antec->{g_number}!~/nr|inher/ and $node->{g_number}=~/^(|nr)$/) {
    #       set_attr($node,'number',$antec->{g_number});
    #       $changed++;
    #       if ($report){print "EEE\t";Position();}
    #     }
    #     if ($antec->{g_gender} and $antec->{g_gender}!~/nr|inher/ and $node->{g_gender}=~/^(|nr)$/) {
    #       set_attr($node,'gender',$antec->{g_gender});
    #       $changed++;
    #       if ($report) {print "EEE\t";Position();}
    #     }
    #     if ($antec->{tag}=~/^V/) {
    #       if ($node->{g_gender}=~/^(|nr)$/) {
    # 	set_attr($node,'gender','neut');
    # #	Position;
    #       }
    #       if ($node->{g_number}=~/^(|nr)$/) {
    # 	set_attr($node,'number','sg');
    # #	Position;
    #       }
    #     }
    # #    Position if $changed;
    #   }


    #   if ($node->{t_lemma} eq "ten" and ($node->attr('gram/number')=~/^(|nr)$/ or $node->attr('gram/gender')=~/^(|nr)$/)  and $antec) {
    #     my $changed;
    #     if ($antec->{g_number} and $antec->{g_number}!~/nr|inher/ and $node->{g_number}=~/^(|nr)$/) {
    #       set_attr($node,'number',$antec->{g_number});
    #       $changed++;
    #       if ($report){print "EEE\t";Position();}
    #     }
    #     if ($antec->{g_gender} and $antec->{g_gender}!~/nr|inher/ and $node->{g_gender}=~/^(|nr)$/) {
    #       set_attr($node,'gender',$antec->{g_gender});
    #       $changed++;
    #       if ($report) {print "EEE\t";Position();}
    #     }
    #     if ($antec->{tag}=~/^V/) {
    #       if ($node->{g_gender}=~/^(|nr)$/) {
    # 	set_attr($node,'gender','neut');
    # 	$changed++;
    #       }
    #       if ($node->{g_number}=~/^(|nr)$/) {
    # 	set_attr($node,'number','sg');
    # 	$changed++
    #       }
    #     }
    # #    Position if $changed;
    #   }


    if ($node->attr('gram/sempos'=~/^n/) and $node->{temp_lex_tag}=~/^PDZ/ and $node->attr('gram/gender')=~/^(|nr)$/) {
        set_attr($node,'gram/gender','neut','X145');
    }

    # vsechny zkopirovane komparativy, ktere maji mezi predky CPR, by mely mit stupen positiv a ne komparativ
    # (jde o casti podstromu zkopirovanych pro ucely zachyceni srovnani)
    #   if ($node->{temp_lex_tag}=~/^.........2/ and $node->{TID}) {
    #     my $n=$node;
    #     while ($n->parent) {
    #       $n=$n->parent;
    #       if ($n->{func} eq "CPR") {
    # 	set_attr($node,'degcmp','pos');
    # 	if ($report){print "FFFFFFFFFFFf\t";Position();}
    #       }
    #     }
    #   }

    #   # upravy lemmat
    #   if ($node->{t_lemma} eq "tak_zvaný") {set_attr($node,'trlemma','takzvaný')}
    #   if ($node->{t_lemma}=~/(\d+)_&Percnt;/) {set_attr($node,'trlemma',"$1_procentní");}


}                               # end of apply_postprocessing



# ---------------------------------------------------------------------------------------------
# participia a prechodniky se maji lematizovat formou
sub ustrnule_slovesne_tvary($) {
    my $node = shift;
    if ($node->{temp_lex_form}=~/^(takřka|takříkajíc|chtě|leže|kleče|sedě|vstoje|vleže|vkleče|vsedě|vstávaje|lehaje|soudíc|soudě|soudíc|soudě|nehledíc|nehledě|nemluvě|vycházejíc|vycházeje|zahrnujíc|nedbajíc|nedbaje|nepočítajíc|počítajíc|nepočítaje|počítaje|vyjmouc|vyjímajíc|vyjímaje|takřka|takříkajíc|leže|kleče|sedě|vstoje|vleže|vkleče|vsedě|vstávaje|lehaje|chtě|chtíc|soudíc|soudě|nehledíc|nehledě|nemluvě|vycházejíc|vycházeje|zahrnujíc|nedbajíc|nedbaje|počítajíc|počítaje|nepočítajíc|nepočítaje|vyjmouc|vyjímajíc|vyjímaje|nevyjímajíc|nevyjímaje)$/i
            or ($node->{temp_lex_form}=~/^(dejme|vzato|věřte|zaplať|nedej|víte|ví|je)$/
                    and $node->{functor} eq "ATT" and grep{$_->{functor} eq "DPHR"}$node->children)
                or ($node->{temp_lex_form}=~/^(věřím|věříme|tuším|tušíme|myslím|myslíme|doufám|doufáme|prosím|promiňte|poslechněte|víte)$/
                        and $node->{functor} eq "ATT")
                    or (lc($node->{temp_lex_form}) eq "nevidět" and grep{$_->{t_lemma} eq "co" and $_->{functor} eq "DPHR"}$node->children)
                        or ($node->{form}=~/^(zahrnuje)$/ and $node->{functor} eq "COND")) {
        set_attr($node,'t_lemma',lc($node->{temp_lex_form}),'X146');
        if ($node->{nodetype} eq "complex") {
            set_attr($node,'gram/sempos','adv.denot.ngrad.nneg','X147')
        }
        if ($report) {
            print "UST\t";Position();
        }
    }
}





# ---------------------------------------------------------------------------------------------
# vyplneni sentmod pro deti technickeho korene, koreny primych recich (ziskane uvozovkovanim i jinak) a koreny PAR

sub assign_sentmod($) {
    my $root = shift;
    my @nodes = PML_T::GetEChildren($root);
    foreach my $node (grep {$_->{functor} eq "PAR"} $root->descendants) {
        my $par_root=$node;
        while ($par_root->parent->{functor}=~/^(APPS|CONJ|DISJ|ADVS|CSQ|GRAD|REAS|CONFR|CONTRA|OPER)/) {
            $par_root=$par_root->parent;
        }
        push @nodes,$par_root;
    }

    foreach my $myroot (@nodes) { #???? to je nejaky divny, to chce zkontrolovat
        my $sentmod;
        my ($aroot) = PML_T::GetANodes($myroot);
        if ($myroot->{temp_lex_tag}=~/Vi/) {
            $sentmod='imper';
        }
        #    elsif ($aroot and grep {$_->attr('m/form') eq "?"} $aroot->children) { # opraveno dle M.Janicka
        elsif ($aroot and grep {$_->attr('m/form') eq "?"} $aroot->parent()->children) {
            $sentmod="inter"
        } else {
            $sentmod='enunc'
        }
        set_attr($myroot,'sentmod',$sentmod,'X148');
    }
}




# ---------------------------------------------------------------------------------------------
# vyprazdni hodnoty vsech atributu, ktere maji byt vyplneny timto skriptem

sub clean_all($) {
    my $root = shift;
    foreach my $node ($root, $root->descendants) {
        #    delete $node->{nodetype};
        delete $node->{gram};
        #    foreach my $attr_name ('nodetype',#map{"gram/$_"} ('sentmod','sempos',keys %all_applicable_grams)
        #			  ) {
        #      delete $node->set_attr($attr_name,'');
        #    }
    }
}



# filling the attribute nodetype in the given node
sub fill_nodetype($) {

    my $node = shift;

    return $node->{nodetype};

    ###
    my $nodetype;
    my $functor = $node->{functor};
    my $t_lemma = $node->{t_lemma};

    if ($functor =~/^(APPS|CONJ|DISJ|ADVS|CSQ|GRAD|REAS|CONFR|CONTRA|OPER)/) {
        $nodetype='coap';
    } elsif ($functor =~/^(RHEM|PREC|PARTL|MOD|ATT|INTF|CM)/) {
        $nodetype='atom';
    } elsif ($functor =~/^FPHR$/) {
        $nodetype='fphr';
    } elsif ($functor =~/^DPHR$/) {
        $nodetype='dphr';
    } elsif ($t_lemma =~/^#(Benef|Total|Cor|EmpVerb|Gen|Whose|Why|QCor|Rcp|Equal|Where|How|When|Some|AsMuch|Unsp|Amp|Ast|Deg|Percnt|Comma|Colon|Dash|Bracket|Period|Period3|Slash)/) {
        $nodetype='qcomplex';
    } elsif ($t_lemma =~/^\#(Forn|Idph)/) {
        $nodetype='list';
    } elsif (not $node->parent) {
        $nodetype='root';
    } else {
        $nodetype = 'complex';
    }
    ;

    set_attr($node,'nodetype',$nodetype,'X149');
    return $nodetype;
}





sub fill_temporary_attributes($) {
    my $root = shift;
    foreach my $t_node ($root->descendants) {
        if ($t_node->attr('a/lex.rf')) {
            my $a_node = PML_T::GetANodeByID($t_node->attr('a/lex.rf'));
            $t_node->{temp_lex_tag} = $a_node->attr('m/tag');
            $t_node->{temp_lex_form} = $a_node->attr('m/form');
            $t_node->{temp_lex_lemma} = $a_node->attr('m/lemma');
            $t_node->{temp_lex_afun} = $a_node->attr('afun');
            $t_node->{temp_lex_ord} = $a_node->attr('ord');

            # oznaceni kandidatu na vztazna zajmena/prislovce ...
            my ($lparent) = PML_T::GetEParents($t_node);
            if ($t_node->{t_lemma}=~/^(který|jaký|jenž|kdy|kde|co|kdo)$/
                    and $lparent->{temp_lex_tag}=~/^V/ and $lparent->{functor} eq "RSTR") {
                my ($lgrandpa)=(PML_T::GetEParents($lparent));
                if ($lgrandpa and $lgrandpa->{temp_lex_tag}=~/^[PN]/) {
                    $t_node->{temp_relative_clause} = 1;
                    #	  print "RELATIVE\n";
                }
            }
        }
    }
}


sub clean_temporary_attributes($) {
    # ???
}

# ------------ MAIN -----------------------

sub process_fsfile {
    my $fsfile = shift;
    foreach my $root ($fsfile->trees()) {
        fill_temporary_attributes($root);
        clean_all($root);

        #    print "sentence: ".PML_T::GetSentenceString($root)."\n";

        foreach my $node ($root,$root->descendants) {
            #      print "node: form=$node->{temp_lex_form}  t_lemma=$node->{t_lemma} functor=$node->{functor}  tag=$node->{temp_lex_tag}\n";
            if (fill_nodetype($node) eq 'complex') {
                assign_automatic_grammatemes($node);
                apply_conversion_rules($node); # aplikace konverznich pravidel z externiho deklaracniho souboru
                apply_postprocessing($node); # dodatecne upravy (dalsi automaticka pravidla)
                fill_missing_grammatemes($node); # vyplni nr do zbyvajicich relevantnich (zatim prazdnych) gramatemu
            }
            #      ustrnule_slovesne_tvary($node);                # specialni osetreni ustrnulych participii a prechodniku
            remove_superfluous_grammatemes($node); # vyprazdni hodnotu nerelevantnich gramatemu
        }

        #    clean_temporary_attributes($root);
        assign_sentmod($root);
        #    print "\n\n";
    }
}


sub process_trees {
    my @trees = @_;
    %adjectival = ();           # mazani cache
    foreach my $root (map {$_->get_tied_fsnode()} @trees) {
        fill_temporary_attributes($root);
        clean_all($root);

        #    print "sentence: ".PML_T::GetSentenceString($root)."\n";

        foreach my $node ($root,$root->descendants) {
            #      print "node: form=$node->{temp_lex_form}  t_lemma=$node->{t_lemma} functor=$node->{functor}  tag=$node->{temp_lex_tag}\n";
            if (fill_nodetype($node) eq 'complex') {
                assign_automatic_grammatemes($node);
                apply_conversion_rules($node); # aplikace konverznich pravidel z externiho deklaracniho souboru
                apply_postprocessing($node); # dodatecne upravy (dalsi automaticka pravidla)
                fill_missing_grammatemes($node); # vyplni nr do zbyvajicich relevantnich (zatim prazdnych) gramatemu
            }
            #      ustrnule_slovesne_tvary($node);                # specialni osetreni ustrnulych participii a prechodniku
            remove_superfluous_grammatemes($node); # vyprazdni hodnotu nerelevantnich gramatemu
        }

        #    clean_temporary_attributes($root);
        assign_sentmod($root);
        #    print "\n\n";
    }
}





# ------------ inicializace ------------

# ---- hodnota vidu

my @vidy = qw(
                 číhat-I čalounit-I čarovat-I číslovat-I časovat-I číst-I častit-I častovat-I
                 čítávat-I čítat-I abdikovat-B absentovat-I absolutizovat-I absolvovat-B
                 absorbovat-B abstrahovat-B adaptovat-B adoptovat-P adresovat-B čekávat-I
                 čekat-I čelit-I čepovat-I čerpat-I česat-I agitovat-I čišet-I činívat-I
                 činit-I čistit-I akcelerovat-I akcentovat-I akceptovat-B aklimatizovat-B
                 akreditovat-B aktivizovat-B aktivovat-B aktualizovat-B akumulovat-I alarmovat-I
                 členit-I alternovat-I amputovat-B analyzovat-I čnít-I čnět-I anektovat-B
                 angažovat-B animovat-I anoncovat-B antropomorfizovat-I anulovat-B čouhat-I
                 čpět-I apelovat-I aplaudovat-I aplikovat-B aranžovat-B argumentovat-I archivovat-I
                 artikulovat-I účastnit-I účinkovat-I účtovat-I asimilovat-B asistovat-I
                 úřadovat-I asociovat-I aspirovat-I úročit-I ústit-I útočit-I úvěrovat-I
                 atakovat-I atomizovat-B čuchnout-P avizovat-B bádat-I básnit-I bát-I bědovat-I
                 bagatelizovat-I běhávat-I běhat-I balancovat-I balit-I běžet-I banalizovat-I
                 bankrotovat-I barvit-I bít-I být-I batolit-I bývávat-I bývat-I bavit-I bazírovat-I
                 bdít-I bečet-I belhat-I besedovat-I bičovat-I bilancovat-I bivakovat-I blábolit-I
                 blahopřát-I blížit-I blamovat-I blýskat-I blýsknout-P blednout-I břinknout-P
                 blokovat-B bloudit-I blufovat-I bodnout-P bodovat-I bohatnout-I bojkotovat-I
                 bojovat-I bolet-I bořit-I bombardovat-I bortit-I bouchnout-P bouřit-I bourat-I
                 boxovat-I bránit-I brát-I brávat-I brázdit-I bratřit-I brblat-I brečet-I
                 brnknout-P brodit-I brojit-I brousit-I bručívat-I bručet-I brumlat-I bruslit-I
                 brzdit-I bubnovat-I budit-I budovat-I bujet-I bušit-I burácet-I burcovat-I
                 bydlívat-I bydlet-I bzučet-I cílit-I cítívat-I cítit-I cedit-I cejchovat-I
                 ceknout-P cementovat-I cenit-I centrovat-I cestovat-I citovat-B civět-I
                 cizelovat-I clít-I couvat-I couvnout-P cpát-I crčet-I ctít-I cukat-I cuknout-P
                 cválat-I cvičit-I cvrnkat-I dát-P dávat-I dávit-I dabovat-I dědit-I dýchat-I
                 dýchnout-P děkovat-I dělávat-I dělat-I dařívat-I dařit-I dělit-I darovat-B
                 děsit-I démonizovat-I dít-I datovat-B dívat-I dbát-I debatovat-I debutovat-B
                 decentralizovat-B defilovat-I definovat-B deformovat-I degradovat-B dechnout-P
                 deklarovat-B dešifrovat-B delegovat-B dementovat-B demokratizovat-B demolovat-B
                 demonopolizovat-B demonstrovat-B demontovat-B deponovat-B deportovat-B deprimovat-I
                 deptat-I destabilizovat-B detekovat-I determinovat-B devalvovat-B devastovat-B
                 dezaktivovat-B dezinfikovat-B dezorganizovat-B diagnostikovat-I diferencovat-B
                 diktovat-I dirigovat-I diskontovat-I diskreditovat-B diskriminovat-I diskutovat-I
                 diskvalifikovat-B dislokovat-B disponovat-I distancovat-B distribuovat-B
                 divergovat-I diverzifikovat-I divit-I dláždit-I dřímat-I dlít-I dřít-I dloubat-I
                 dlužit-I důvěřovat-I dočíst-P dočítat-I dočkat-P dobíhat-I doběhnout-P dobírat-I
                 dobýt-P dobývat-I dobrat-P dobudovat-P docílit-P doceňovat-I docenit-P docilovat-I
                 dodávat-I dodělávat-I dodanit-P dodat-P dodržet-P dodržovat-I dofinišovat-P
                 dohánět-I dohadovat-I dohasínat-I dohasnout-P dohlížet-I dohlédnout-P dohledávat-I
                 dohledat-P dohmátnout-P dohnat-P dohodnout-P dohonit-P dohotovit-P dohovořit-P
                 dohrát-P dohrávat-I docházet-I dochovat-P dochytat-P dojídat-I dojíždět-I
                 dojímat-I dojít-P dojednat-P dojet-P dojit-I dojmout-P dokázat-P dokazovat-I
                 dokládat-I dokladovat-I doklepnout-P doklopýtat-P dokončit-P dokončovat-I
                 dokonat-P dokoupit-P dokralovat-P dokreslit-P dokreslovat-I dokumentovat-B
                 dolaďovat-I doříci-P doladit-P došlápnout-P doléhat-I dolétnout-P dolehnout-P
                 dořešit-P doleptat-P doletět-P doložit-P dolomit-P dožadovat-I dožít-P dožívat-I
                 domáhat-I domýšlet-I domalovat-P domazat-P dominovat-I domlouvat-I domluvit-P
                 domnívat-I domoci-P domyslet-P domyslit-P donášet-I donést-P donosit-P donutit-P
                 dopátrat-P dopadat-I dopadnout-P dopéci-P dopisovat-I doplácet-I dopřát-P
                 dopřávat-I doplatit-P doplavat-P doplazit-P doplňovat-I doplnit-P dopočítávat-I
                 dopočítat-P dopomáhat-I dopomoci-P doporučit-P doporučovat-I dopouštět-I
                 dopovat-I dopracovávat-I dopracovat-P dopravit-P dopravovat-I doprodat-P
                 doprovázet-I doprovodit-P dopsat-P dopustit-P doputovat-P dorážet-I dorazit-P
                 dorůst-P dorůstat-I dorovnat-P dorozumět-P dorozumívat-I doručit-P doručovat-I
                 dosáhnout-P dosadit-P dosahovat-I dosazovat-I dosednout-P doslechnout-P
                 dosloužit-P dosluhovat-I dospět-P dospívat-I dostačovat-I dostát-P dostávat-I
                 dostat-P dostavět-P dostavit-P dostavovat-I dostihnout-P dostihovat-I dostoupit-P
                 dostrkat-P dosvědčit-P dosvědčovat-I dotáhnout-P dotázat-P dotýkat-I dotírat-I
                 dotazovat-I dotisknout-P dotknout-P dotovat-I dotrpět-P dotvářet-I dotvořit-P
                 dotvrzovat-I doufat-I doutnat-I dovádět-I dovážet-I dovážit-P dovídat-I
                 dovědět-P dovařit-P dovažovat-I dovést-I dovézt-P dovodit-P dovolávat-I
                 dovolat-P dovolit-P dovolovat-I dovozovat-I dovršit-P doznávat-I doznat-P
                 doznít-P doznívat-I dozrát-P dozrávat-I dozvídat-I dozvědět-P dozvonit-P
                 dráždit-I drát-I draftovat-I dražit-I dramatizovat-I drhnout-I držet-I drobit-I
                 drolit-I drožkařit-I drtit-I družit-I dušovat-I dunět-I dusat-I dusit-I
                 dvojit-I elektrifikovat-B eliminovat-B emanovat-I emigrovat-B emitovat-I
                 erodovat-I eskalovat-I eskontovat-I eskortovat-B etablovat-I evakuovat-B
                 evidovat-I evokovat-B excelovat-I existovat-I expandovat-I expedovat-B experimentovat-I
                 explodovat-B exportovat-B extrahovat-B fackovat-I fakturovat-I falšovat-I
                 fandit-I fantazírovat-I farmařit-I fascinovat-I fasovat-I fúzovat-I fauloval-I
                 favorizovat-I faxovat-B fičet-I figurovat-I filozofovat-I financovat-I finišovat-I
                 fixlovat-I fixovat-B flákat-I flámovat-I flirtovat-I formalizovat-I formovat-I
                 formulovat-B fotografovat-I foukat-I frčet-I frustrovat-I fungovat-I garantovat-B
                 generovat-I glajchšaltovat-I globalizovat-I glosovat-B gratulovat-I hádat-I
                 hájit-I hýčkat-I házet-I hýbat-I hýbnout-P halit-I hýřit-I handicapovat-B
                 hanobit-I harmonizovat-B harmonovat-I hasit-I hasnout-I havarovat-I hazardovat-I
                 hecovat-I hekat-I hemžit-I hlásat-I hlásit-I hřát-I hlídat-I hladit-I hlídkovat-I
                 hladovět-I hlaholit-I hřímat-I hlasovat-I hlavičkovat-I hledávat-I hledat-I
                 hledět-I hřešit-I hřmět-I hloubit-I hltat-I hnát-I hněvat-I hnisat-I hnout-P
                 hodit-I hodlat-I hodnotit-I hojit-I holdovat-I holedbat-I hořet-I holit-I
                 homologovat-I honit-I honorovat-B honosit-I horlit-I hospitalizovat-B hospodařit-I
                 hostit-I hostovat-I houfovat-I houkat-I houpat-I houstnout-I hovět-I hovořívat-I
                 hovořit-I hrát-I hrávat-I hrabat-I hradívat-I hradit-I hraničit-I hrknout-P
                 hrnout-I hromadit-I hroutit-I hrozívat-I hrozit-I hučet-I hubnout-I hulit-I
                 hvízdat-I hvízdnout-P hynout-I hypertrofovat-B hyzdit-I chápat-I chátrat-I
                 chýlit-I charakterizovat-B chlácholit-I chladit-I chladnout-I chlubit-I
                 chodívat-I chodit-I chopit-P chovat-I chránit-I christianizovat-I chrlit-I
                 chtít-I chudnout-I chutnat-I chválit-I chvástat-I chvět-I chybět-I chybívat-I
                 chybit-I chybovat-I chystat-I chytat-I chytit-P chytnout-P idealizovat-B
                 identifikovat-B ideologizovat-I ignorovat-I ilustrovat-B imitovat-I implantovat-I
                 implikovat-I imponovat-I importovat-B improvizovat-I imputovat-B imunizovat-B
                 indikovat-B indisponovat-I indukovat-B infiltrovat-B informovat-B iniciovat-B
                 inkasovat-B inklinovat-I inovovat-B inscenovat-B inspirovat-B instalovat-B
                 institucionalizovat-I instruovat-B integrovat-B interferovat-I internacionalizovat-B
                 internovat-B interpelovat-B interpretovat-B intervenovat-B intrikovat-I
                 inventarizovat-B investovat-I inzerovat-I iritovat-I izolovat-I jásat-I
                 jídat-I jímat-I jíst-I jít-I jednávat-I jednat-I ježit-I jet-I jevit-I jezdívat-I
                 jezdit-I jiskřit-I jistit-I jmenovat-I jmout-P joggovat-I kácet-I kárat-I
                 kát-I kázat-I kýchnout-P kašlat-I kódovat-B kalit-I kalkulovat-I kótovat-I
                 kamarádit-I kandidovat-I kapat-I kapitulovat-B katapultovat-B kategorizovat-B
                 kývat-I kývnout-P kazit-I kecat-I klíčit-I klást-I klátit-I křížit-I klamat-I
                 klapat-I klasifikovat-B kleknout-P klenout-I křepčit-I klepat-I klepnout-P
                 klesat-I klesnout-P křičívat-I křičet-I kličkovat-I klikatit-I křiknout-P
                 křižovat-I křivdit-I klonit-I klopýtat-I klouzat-I klubat-I kmitat-I kočkovat-I
                 kočovat-I kodifikovat-B koexistovat-I kochat-I kojit-I koketovat-I kolíbat-I
                 kolaborovat-I kolabovat-I kolísat-I kolébat-I kořenit-I kolidovat-I kolonizovat-B
                 kolovat-I kombinovat-I komentovat-B komolit-I komorovat-I kompenzovat-B
                 kompilovat-I komplikovat-I komponovat-I komunikovat-I končívat-I končit-I
                 konat-I koncentrovat-B koncertovat-I koncipovat-B kondolovat-B konejšit-I
                 konferovat-I konfiskovat-I konfrontovat-B konkretizovat-B konkurovat-I konsolidovat-B
                 konspirovat-I konstatovat-B konstituovat-B konstruovat-I kontaktovat-B kontaminovat-B
                 kontrahovat-B kontrastovat-I kontrolovat-I kontrovat-I kontumovat-I konvergovat-I
                 konvertovat-B konverzovat-I konzervovat-B konzultovat-I konzumovat-I kooperovat-I
                 koordinovat-B kopírovat-I kopat-I kopnout-P korespondovat-I korigovat-B
                 korodovat-I korumpovat-I korunovat-I kotvit-I koukat-I kouknout-P kouřit-I
                 koupat-I koupit-P kousat-I kouskovat-I kousnout-P kouzlit-I kovat-I kráčet-I
                 krájet-I krášlit-I krást-I krátit-I krčit-I kralovat-I krýt-I kreslit-I
                 kritizovat-I krmit-I kroužit-I kroutit-I kručet-I krystalizovat-I kulhat-I
                 kulminovat-I kultivovat-I kumulovat-I kupovat-I kutálet-I kvalifikovat-B
                 kvantifikovat-I kvést-I kvitovat-B kydat-I kypět-I řádit-I ládovat-I líčit-I
                 lákat-I šílet-I šířit-I lámat-I šít-I líbat-I líbit-I laborovat-I říci-P
                 ladit-I řadit-I řídit-I řídnout-I šelestit-I šeptávat-I šeptat-I šeptnout-P
                 šermovat-I šetřit-I líhnout-I šidit-I šifrovat-B šikanovat-I šilhat-I říkávat-I
                 říkat-I šklebit-I škobrtnout-P škodit-I školit-I škrábat-I škrábnout-P škrtat-I
                 škrtit-I škrtnout-P škubnout-P škytnout-P šlápnout-P šlapat-I šlehat-I šťourat-I
                 šňupat-I šůrovat-I lamentovat-I šněrovat-I šokovat-B šoupnout-P šoustnout-P
                 lapat-I špehovat-I špinit-I lapit-P špitat-I špitnout-P šplhat-I šplhnout-P
                 šponovat-I šroubovat-I léčit-I léhat-I létat-I lézt-I lít-I štěkat-I štípat-I
                 štěpit-I lítat-I štítit-I řítit-I štvát-I šukat-I šuškat-I šulit-I šumět-I
                 šustit-I lízat-I říznout-P ředit-I legalizovat-B legitimizovat-I legitimovat-B
                 lehat-I lehnout-P lekat-I leknout-P řeknout-P řešívat-I řešit-I ležet-I
                 lemovat-I lenit-I lepit-I lepšit-I leptat-I letět-I řezat-I lhát-I liberalizovat-B
                 libovat-I licitovat-I lichotit-I likvidovat-B lišívat-I lišit-I limitovat-B
                 řinčet-I linout-I řinout-I listovat-I litovat-I lnout-I lobbovat-I lokalizovat-B
                 lomcovat-I lomit-I losovat-I loučit-I loupit-I loutkařit-I lovit-I lpět-I
                 lustrovat-B luxovat-I řvát-I lyžovat-I lze-I žádávat-I žádat-I žárlit-I
                 žadonit-I žalovat-I žasnout-I žít-I žebrat-I žehnat-I žehrávat-I žehrat-I
                 ženit-I žertovat-I žhavit-I živit-I živořit-I životnět-I žonglovat-I žrát-I
                 žvýkat-I máčet-I máchat-I mačkat-I mást-I mávat-I mávnout-P magnetizovat-I
                 míhat-I míchat-I míjet-I makat-I měřívat-I mařit-I mýlit-I mířit-I měřit-I
                 malovat-I mínívat-I měnívat-I manifestovat-B manipulovat-I mínit-I měnit-I
                 mapovat-I masakrovat-B mísit-I maskovat-B mít-I mýt-I materializovat-I maturovat-I
                 mívat-I maximalizovat-B mazat-I mazlit-I meditovat-I metabolizovat-I metat-I
                 mhouřit-I migrovat-I mihnout-P milovat-I minimalizovat-B minout-P mizet-I
                 mlátit-I mlčívat-I mlčet-I mlít-I mluvívat-I mluvit-I mžít-I mžourat-I množit-I
                 mnout-I mobilizovat-I moci-I modelovat-I modernizovat-B moderovat-I modifikovat-B
                 modlívat-I modlit-I modulovat-I mokvat-I mořit-I monitorovat-I monopolizovat-B
                 montovat-I monumentalizovat-I motat-I motivovat-B mračit-I mrknout-P mrštit-P
                 mrskat-I mrzet-I mrznout-I mstít-I mučit-I mumlat-I muset-I musit-I myslet-I
                 myslit-I načasovat-P načít-P načechrat-P načerpat-P naakumulovat-P náležet-I
                 naaranžovat-P nárokovat-I načrtávat-I načrtnout-P naúčtovat-P následovat-I
                 násobit-I nabádat-I nabídnout-P nabíhat-I naběhat-B naběhnout-P nabalit-P
                 nabalovat-I nabírat-I nabít-P nabýt-P nabývat-I nabízet-I nablít-P nabourávat-I
                 nabourat-P nabrat-P nacvičovat-I nadát-P nadávat-I nadýchat-P nadělat-B
                 nadělit-P nadat-P nadechnout-P nadejít-P nadhodit-P nadhodnotit-P nadcházet-I
                 nadchnout-P nadiktovat-P nadřadit-P nadřít-B nadlehčit-P nadsazovat-I nadužít-P
                 nadzvednout-P nafackovat-P nafilmovat-P nafouknout-P nafukovat-I nahánět-I
                 naházet-P nahazovat-I nahlásit-P nahlašovat-I nahlížet-I nahlédnout-P nahřívat-I
                 nahlodat-P nahmátnout-P nahmatat-P nahnat-P nahodit-P nahrát-B nahrávat-I
                 nahrabat-P nahradit-P nahrazovat-I nahromadit-P nacházet-I nachýlit-P nachylovat-I
                 nachystat-P nachytat-P nainstalovat-P najíždět-I najímat-I najíst-P najít-P
                 najet-B najmout-P nakazit-P nakládat-I naklánět-I naklást-P naklonit-P nakomandovat-P
                 nakoupit-P nakousnout-P nakrájet-P nakrást-P nakreslit-P nakukovat-I nakupit-P
                 nakupovat-I nakutat-P nalíčit-I nalákat-P naladit-P nařídit-P našeptávat-I
                 naříkat-I našlápnout-P naléhat-I nalévat-I nalézat-I nalézt-P nalít-P nalítnout-P
                 naštvat-P naříznout-P nalepit-P nalepovat-I naleptávat-I naletět-P nařezat-P
                 naleznout-P nalhávat-I nalistovat-P nařizovat-I nařknout-P naťukat-P nalodit-P
                 naložit-P nalomit-P naloupit-P nalovit-P nažrat-P namáhat-I namíchávat-I
                 namíchat-P namířit-P naměřit-P namalovat-P namarkovat-P namítat-I namítnout-P
                 namazat-P namluvit-B namnožit-P namočit-P namontovat-P nanášet-I nanést-P
                 nandat-P naoktrojovat-P napáchat-B napájet-I napálit-P napást-P napadat-I
                 napadnout-P napíchat-P napařit-P napěstovat-P napít-P naplánovat-P napřít-P
                 naplňovat-I naplnit-P napnout-P napočíst-P napočítat-P napodobit-P napodobovat-I
                 napojit-P napojovat-I napomáhat-I napomínat-I napomenout-P napomoci-P napovídat-I
                 napovědět-P napravit-P napravovat-I napršet-P naprogramovat-P napsat-P napumpovat-P
                 napustit-P narážet-I narýžovat-P narazit-P narůst-P narůstat-I narodit-P
                 naroubovat-P narušit-P narušovat-I nasát-P nasázet-P nasadit-P nasít-P nasazovat-I
                 nasbírat-P nasedat-I nasednout-P naservírovat-P nashromáždit-P nasimulovat-P
                 naskakovat-I naskýtat-I naskicovat-P naskočit-P naskytnout-P naslouchat-I
                 nasměrovat-P nasmlouvat-P nastávat-I nastěhovat-P nastínit-P nastartovat-P
                 nastat-P nastavit-P nastavovat-I nastříkat-P nastřílet-P nastřelit-P nastolit-P
                 nastolovat-I nastoupit-P nastrčit-P nastražit-P nastudovat-P nastupovat-I
                 nastydnout-P nasvědčovat-I nasypat-P nasytit-P nést-I natáčet-I natáhnout-P
                 natahovat-I natírat-I natéci-P natřít-P natočit-P natrénovat-P natrhnout-P
                 naturalizovat-B naučit-P navádět-I navázat-P navýšit-P navalit-P navazovat-I
                 navečeřet-P naverbovat-P navléknout-P navštívit-P navštěvovat-I navodit-P
                 navozovat-I navrátit-P navracet-I navrhnout-P navrhovat-I navyknout-P navyšovat-I
                 nazírat-I nazývat-I naznačit-P naznačovat-I nazpívat-I nazrát-P nazvat-P
                 nedbat-I negovat-I nechávat-I nechat-P nenávidět-I neokázala-P nervovat-I
                 nesnášet-I neutralizovat-B nezbývat-I ničit-I nocovat-I nominovat-B normalizovat-B
                 nosívat-I nosit-I novelizovat-B nudit-I nutívat-I nutit-I očíslovat-P očekávat-I
                 očernit-P očistit-P očkovat-I obávat-I občerstvovat-I obíhat-I obalamutit-P
                 obírat-I oběsit-P obětovat-P obývat-I obdařit-P obdařovat-I obdarovat-P
                 obdivovat-I obdržet-P obehrát-P obehrávat-I obejít-P obejit-P obejmout-P
                 obeplout-P obesílat-I obestírat-I obestřít-P obezdívat-I obeznámit-P obhájit-P
                 obhánět-I obhajovat-I obhlédnout-P obhospodařovat-I obcházet-I obchodovat-I
                 objíždět-I objímat-I objasňovat-I objasnit-P objednávat-I objednat-P objektivizovat-I
                 objet-P objevit-P objevovat-I obklíčit-P obklopit-P obklopovat-I obšancovat-P
                 obšívat-I oblíbit-P obšlápnout-P obšťastňovat-I oblažit-P oblažovat-I obléci-P
                 obléhat-I oblékat-I obléknout-P obletět-P obložit-P obžalovat-P obměňovat-I
                 obmyslet-P obnášet-I obnažovat-I obnovit-P obnovovat-I obohacovat-I obohatit-P
                 obořit-P obouvat-I obrážet-I obrátit-I obracet-I obrat-P obrůst-P obrůstat-I
                 obrodit-P obrousit-P obrušovat-I obsáhnout-P obsadit-P obsahovat-I obsazovat-I
                 obsloužit-P obsluhovat-I obstát-P obstarávat-I obstarat-P obstoupit-P obtížit-P
                 obtěžkat-P obtěžovat-I obveselit-P obviňovat-I obvinit-P obydlet-P ocejchovat-P
                 oceňovat-I ocenit-P ocitat-I ocitnout-P ocitovat-P ocnout-P octnout-P odčarovat-P
                 odčerpávat-I odčerpat-P odčinit-P odírat-I odít-P odbíhat-I odběhnout-P
                 odbarvovat-I odbýt-P odbývat-I odbavovat-I odbřemenit-P odblokovat-P odbočovat-I
                 odbourávat-I odbourat-P odbrzdit-P odcentrovat-P odcestovat-P odcizit-P
                 odcizovat-I oddálit-P oddávat-I oddělat-P oddělit-P oddalovat-I oddělovat-I
                 oddat-P oddechnout-P oddychnout-P oddychovat-I odečíst-P odečítat-I odebírat-I
                 odebrat-P odehnat-P odehrát-P odehrávat-I odejít-P odejet-P odejmout-P odemknout-P
                 odepisovat-I odepřít-P odepsat-P odesílat-I odeslat-P odevzdávat-I odevzdat-P
                 odezírat-I odeznít-P odeznívat-I odhánět-I odhadnout-P odhadovat-I odhalit-P
                 odhalovat-I odhlásit-P odhlasovat-P odhlédnout-P odhodit-P odhodlávat-I
                 odhodlat-P odhrabat-P odcházet-I odchýlit-P odchodit-P odchovat-P odchylovat-I
                 odchytit-P odjíždět-I odjet-P odjistit-P odkázat-P odkapávat-I odkazovat-I
                 odkládat-I odklánět-I odklízet-I odklidit-P odklonit-P odkopávat-I odkoupit-P
                 odkráčet-P odkrýt-P odkrývat-I odkupovat-I odlákat-P odříci-P odříkávat-I
                 odříkat-I odškodňovat-I odškodnit-P odlétat-I odřít-P odštěpit-P odříznout-P
                 odlehčit-P odřeknout-P odlepit-P odletět-P odřezávat-I odlišit-P odlišovat-I
                 odložit-P odlomit-P odloučit-P odlučovat-I odlupovat-I odůvodňovat-I odůvodnit-P
                 odmávat-P odměňovat-I odměřovat-I odměnit-P odmítat-I odmítnout-P odmaturovat-P
                 odmlčet-P odmontovat-P odmrštit-P odmyslit-P odnášet-I odnímat-I odnést-P
                 odnaučit-P odnaučovat-I odolávat-I odolat-P odoperovat-P odpálit-P odpadat-I
                 odpadnout-P odpařit-P odpařovat-I odpírat-I odpírat;-I odpískat-P odplížit-P
                 odplavit-P odpřisáhnout-P odplout-P odplouvat-I odpočíst-P odpočívat-I odpočinout-P
                 odpochodovat-P odpolitizovat-P odpomoci-P odporovat-I odpouštět-I odpoutávat-I
                 odpoutat-P odpovídat-I odpovědět-P odpracovat-P odpreparovat-P odprodávat-I
                 odprodat-P odpustit-P odpuzovat-I odpykávat-I odpykat-P odrážet-I odradit-P
                 odrazit-P odrazovat-I odreagovat-P odrůst-P odročit-P odsát-P odsávat-I
                 odsedět-P odsednout-P odseknout-P odskákat-P odskakovat-I odskočit-P odsloužit-P
                 odsoudit-P odsouhlasit-P odsouvat-I odstátnit-P odstěhovat-P odstartovat-P
                 odstavit-P odstavovat-I odstřelit-P odstřelovat-I odstoupit-P odstrčit-P
                 odstrašovat-I odstraňovat-I odstranit-P odstupňovat-P odstupovat-I odsunout-P
                 odsuzovat-I odtajnit-P odtékat-I odtlačovat-I odtrhnout-P odtrhovat-I odtroubit-P
                 odvádět-I odvážet-I odvážit-P odvát-P odvíjet-I odvalit-P odvažovat-I odvanout-P
                 odvést-P odvézt-P odvětit-P odvětvovat-I odvděčit-P odvděčovat-I odvelet-P
                 odvinit-P odvinout-P odvléci-P odvodit-P odvolávat-I odvolat-P odvozit-P
                 odvozovat-I odvrátit-P odvracet-I odvrhnout-P odvrtat-P odvyknout-P odvysílat-P
                 odzbrojit-P odzbrojovat-I ohánět-I ohýbat-I ohlásit-P ohřát-P ohlídat-P
                 ohlašovat-I ohlížet-I ohlédnout-P ohřívat-I ohledat-P ohluchnout-P ohodnocovat-I
                 ohodnotit-P ohořet-P oholit-P ohrát-P ohrávat-I ohradit-P ohrazovat-I ohrožovat-I
                 ohromit-P ohrozit-P ochabnout-P ochladit-P ochladnout-P ochlazovat-I ochránit-P
                 ochraňovat-I ochromit-P ochromovat-I ochudit-P ochutnat-P ochuzovat-I okázat-P
                 okřídlit-P oklamat-P oklešťovat-I okleštit-P okořenit-P okomentovat-P okopávat-P
                 okopírovat-P okoukat-P okouknout-P okouzlit-P okouzlovat-I okrádat-I okrást-P
                 oktrojovat-B okupovat-I okusit-P okusovat-I ošetřit-P ošetřovat-I ošidit-P
                 ošlapat-P ošoustat-P oťukat-P oloupat-P oloupit-P ožít-P ožívat-I ožebračovat-I
                 oželet-P oženit-P oživit-P oživovat-I omalovat-P omývat-I omdlít-P omezit-P
                 omezovat-I omilostnit-P omládnout-P omlátit-P omladit-P omlouvat-I omluvit-P
                 omráčit-P onemocnět-P opáčit-P opájet-I opálit-P opásat-P opadávat-I opadnout-P
                 opíjet-I opakovat-I opařit-P opalovat-I opírat-I opít-P opatřit-P opatřovat-I
                 opětovat-I opatrovat-I operovat-I opevňovat-I opisovat-I oplakávat-I opřít-P
                 oplatit-P oplývat-I oplodnit-P oplotit-P opodstatňovat-I opojit-P opožďovat-I
                 opomíjet-I opomenout-P oponovat-I opouštět-I opozdit-P oprášit-P oprávnit-P
                 oprat-P opravit-P opravňovat-I opravovat-I oprostit-P optat-P optimalizovat-B
                 opustit-P orat-I orazit-P ordinovat-I organizovat-B orientovat-B orosit-P
                 osadit-P osídlit-P osahávat-I osahat-P osamostatnit-P osazovat-I oscilovat-I
                 osidlovat-I osiřet-P oslabit-P oslabovat-I osladit-P oslavit-P oslavovat-I
                 oslazovat-I oslepit-P oslnit-P oslovit-P oslovovat-I oslyšet-P osmělit-P
                 osočit-P osočovat-I osobovat-I osolit-P ospravedlňovat-I ospravedlnit-P
                 ostýchat-I ostříhat-P ostřelovat-I ostřit-I ostrouhat-P osušit-P osvědčit-P
                 osvědčovat-I osvěžit-P osvítit-P osvětlit-P osvětlovat-I osvobodit-P osvobozovat-I
                 osvojit-P osvojovat-I otáčet-I otálet-I otázat-P otěhotnět-P otéci-P otékat-I
                 oteplit-P oteplovat-I otestovat-P otevírat-I otevřít-P otipovat-P otisknout-P
                 otiskovat-I otřásat-I otřást-P otřít-P otočit-P otrávit-P otravovat-I otrkat-P
                 otrnout-P otužovat-I otupět-P otupovat-I otvírat-I ověřit-P ověřovat-I ověsit-P
                 ovdovět-P ovládat-I ovládnout-P ovlivňovat-I ovlivnit-P oxidovat-B ozářit-P
                 ozývat-I ozbrojit-P ozdobit-P ozdravit-P ozdravovat-I ozřejmit-P označit-P
                 oznámit-P označovat-I oznamovat-I ozvat-P ozvláštnit-P páchat-I páchnout-I
                 pálit-I pást-I pátrat-I pacifikovat-B padělat-P padat-I pídit-I padnout-P
                 píchat-I píchnout-P pachtovat-I pašovat-I pózovat-I pamatovat-I pěnit-I
                 panovat-I parafovat-B parafrázovat-B paralyzovat-B parazitovat-I parkovat-I
                 parodovat-I participovat-I pískat-I písknout-P pasovat-B pěstovat-I péci-I
                 pít-I pět-I patentovat-B patřívat-I patřit-I pečetit-I pečovat-I penalizovat-B
                 pentlit-I penzionovat-B perzekuovat-I perzekvovat-I peskovat-I pilotovat-I
                 pinkat-I pinknout-P piplat-I pitvat-I plácat-I plácnout-P příčit-I plánovat-I
                 přát-I přátelit-I plakat-I plašit-I plížit-I planout-I přísahat-I příslušet-I
                 příspívat-I příst-I plédovat-I plést-I přít-I platívat-I platit-I plýtvat-I
                 plavat-I plavit-I plazit-I přečíslovat-P přečíst-P přečerpat-P přečkat-P
                 přebíhat-I přeběhnout-P přebírat-I přebít-P přebývat-I přebolet-P přebrat-P
                 přebudovat-P přeceňovat-I přecenit-P předčítat-I předávat-I předávkovat-P
                 předčit-B předělávat-I předělat-P předat-P předbíhat-I předběhnout-P předehrávat-I
                 předejít-P předepisovat-I předepsat-P předestřít-P předhánět-I předhazovat-I
                 předcházet-I předimenzovat-P předjímat-I předkládat-I předřadit-P předříkávat-I
                 předložit-P předlužit-P přednášet-I přednést-P předpisovat-I předplatit-P
                 předpokládat-I předpovídat-I předpovědět-P předražit-P předražovat-I předsedat-I
                 předsevzít-P předstírat-I představit-P představovat-I předstihnout-P předstoupit-P
                 předstupovat-I předtisknout-P předurčit-P předurčovat-I předvádět-I předvídat-I
                 předvést-P předvolávat-I předvolat-P předznamenávat-I předznamenat-P přefilmovat-P
                 přehánět-I přehazovat-I přehřát-P přehlížet-I přehlasovat-P přehlédnout-P
                 přehlavičkovat-P přehlcovat-I přehltit-P přehnat-P přehodit-P přehodnocovat-I
                 přehodnotit-P přehoupnout-P přehrát-P přehrávat-I přehradit-P přecházet-I
                 přechodit-P přechovávat-I přejíždět-I přejímat-I přejít-P přejet-P přejmenovat-P
                 přejmout-P překážet-I překódovat-P překazit-P překládat-I překlenout-P překřikovat-I
                 překřtít-P překonávat-I překonat-P překontrolovat-P překopnout-P překousnout-P
                 překračovat-I překrýt-P překrývat-I překreslovat-I překrmovat-I překročit-P
                 překroutit-P překrucovat-I překvapit-P překvapovat-I překypovat-I přelaďovat-I
                 plešatět-I přeladit-P přeřadit-P přešetřit-P přešetřovat-I přeškolit-P přešlapávat-I
                 přešlapovat-I přelévat-I přelézt-P přelít-P přeletět-P přeložit-P přelouskat-P
                 přelstít-P přežít-P přežívat-I přemýšlet-I přeměřit-P přemalovávat-I přemalovat-P
                 přeměňovat-I přeměnit-P přemístit-P přemítat-I přemisťovat-I přemlouvat-I
                 přemluvit-P přemoci-P přemostit-P přenášet-I přenést-P přenechávat-I přenechat-P
                 přeočkovat-P přeorganizovat-P přeorientovat-P přepadávat-I přepadat-I přepadnout-P
                 přepínat-I přepisovat-I přeplácet-I přeplavit-P přeplňovat-I přeplnit-P
                 přeplouvat-I přepnout-P přepočíst-P přepočítávat-I přepočítat-P přepojit-P
                 přepracovávat-I přepracovat-P přepravit-P přepravovat-I přepsat-P přepustit-P
                 přerazit-P přeregistrovat-P přerůst-P přerůstat-I přerozdělit-P přerozdělovat-I
                 přerušit-P přerušovat-I přervat-P přesáhnout-P přesadit-P přesídlit-P přesahovat-I
                 přesedlávat-I přesedlat-P přeskakovat-I přeskočit-P přeskupit-P přeslechnout-P
                 přesměrovat-P přesmyknout-P přesouvat-I přespávat-I přespat-P přesprintovat-P
                 přestát-P přestávat-I přestěhovat-P přestat-P přestavět-P přestavovat-I
                 přestřelit-P přestřelovat-I přestřihnout-P přestoupit-P přestupovat-I přesunout-P
                 přesunovat-I přesvědčit-P přesvědčovat-I přesytit-P přetáhnout-P přetápět-I
                 přetahovat-I přetížit-P přetěžovat-I přetéci-P přetékat-I přetavit-P přetavovat-I
                 přetisknout-P přetiskovat-I přetlačovat-I přetřásat-I přetřít-P přetlumočit-P
                 přetočit-P přetopit-P přetransformovat-P přetrhnout-P přetrvávat-I přetrvat-P
                 přetvářet-I přetvořit-P přeučit-P převádět-I převážet-I převážit-P převýšit-P
                 převalit-P převalovat-I převažovat-I převést-P převézt-P převelet-P převládat-I
                 převládnout-P převléci-P převrátit-P převracet-I převrhnout-P převtělit-P
                 převychovávat-I převychovat-P převyšovat-I převyprávět-P převzít-P přezbrojit-P
                 přezdívat-I přezkoumat-P přezkušovat-I přezouvat-I přičínět-I přičíst-P
                 přičítat-I přičinit-P přičlenit-P přiběhnout-P přibírat-I přibarvovat-I
                 přibít-P přibýt-P přibývat-I přiblížit-P přibližovat-I přibrat-P přibrzdit-P
                 přicestovat-P přidávat-I přidělávat-I přidělat-P přidělit-P přidělovat-I
                 přidat-P přidržet-P přidržovat-I přidružit-P přiházet-I přihazovat-I přihlásit-P
                 přihřát-P přihlašovat-I přihlížet-I přihlédnout-P přihnat-P přihnojovat-I
                 přihodit-P přihoršit-P přihrát-P přihrávat-I přihustit-P přicházívat-I přicházet-I
                 přichycovat-I přichystat-P přijíždět-I přijímat-I přijít-P přijet-P přijmout-P
                 přikázat-P přikývnout-P přikazovat-I přikládat-I přiklánět-I přiklonit-P
                 přiklopit-P přikovat-P přikráčet-P přikrádat-I přikrýt-P přikročit-P přikusovat-I
                 přikyvovat-I přilákat-P přišít-P přiřadit-P přišroubovat-P přiléhat-I přilétat-I
                 přilétnout-P přilévat-I přiřítit-P přiřazovat-I přilepit-P přilepšit-P přilepovat-I
                 přiletět-P přiřknout-P přiťuknout-P přiložit-P přiloudat-P přiživit-P přiživovat-I
                 přimáčknout-P přimíchat-P přiměřit-P přimísit-P přimět-P přimknout-P přimlouvat-I
                 přinášet-I přináležet-I přinést-P přinutit-P přiostřovat-I připadat-I připadnout-P
                 připíchnout-P připínat-I připevňovat-I připevnit-P připisovat-I připlácet-I
                 připlatit-P připlout-P připlynout-P připočíst-P připočítávat-I připočítat-P
                 připojištěn-P připojistit-P připojit-P připojovat-I připomínat-I připomenout-P
                 připouštět-I připoutávat-I připoutat-P připravit-P připravovat-I připsat-P
                 připustit-P přirážet-I přirůstat-I přirovnávat-I přirovnat-P přislíbit-P
                 přisoudit-P přispěchat-P přispět-P přispívat-I přistát-P přistávat-I přistěhovat-P
                 přistavět-P přistavit-P přistavovat-I přistihnout-P přistřihnout-P přistoupit-P
                 přistupovat-I přisunout-P přisuzovat-I přisvojit-P přitáhnout-P přitahovat-I
                 přitížit-P přitěžovat-I přitéci-P přitékat-I přitisknout-P přitlačit-P přituhnout-P
                 přitvrdit-P přitvrzovat-I přiučit-P přivádět-I přivážet-I přivírat-I přivést-P
                 přivézt-P plivat-I přivítat-P přivazovat-I přivlastňovat-I přivlastnit-P
                 přivřít-P plivnout-P přivodit-P přivolat-P přivolit-P přivrhnouti-P přivydělávat-I
                 přivydělat-P přivyknout-P přizdobit-P přiznávat-I přiznat-P přizpůsobit-P
                 přizpůsobovat-I přizvat-P plnit-I plodit-I plout-I plynout-I půjčit-P půjčovat-I
                 půlit-I působit-I počíhat-P počínat-I počíst-P počastovat-P počít-P počítat-I
                 počeštit-P počkat-P počůrat-P pobíhat-I pobírat-I pobýt-P pobývat-I pobavit-P
                 pobízet-I pobodat-P pobouřit-P pobrat-P pobrukovat-I pobuřovat-I pocítit-P
                 pociťovat-I podávat-I poděkovat-P podílet-I podařit-P podělit-P poděsit-P
                 podat-P podít-P podívat-P podbarvovat-I podbízet-I podceňovat-I podcenit-P
                 poddat-P podepisovat-I podepřít-P podepsat-P podezírat-I podezřívat-I podhodnotit-P
                 podchytit-P podivit-P podivovat-I podjet-P podkládat-I podkopávat-I podkopat-P
                 podřadit-P podřídit-P podléhat-I podříznout-P podlehnout-P podřezat-P podřimovat-I
                 podřizovat-I podložit-P podlomit-P podmalovávat-I podmaňovat-I podmanit-P
                 podmínit-P podmiňovat-I podminovat-P podněcovat-I podnítit-P podnikat-I
                 podniknout-P podobat-I podotýkat-I podotknout-P podpisovat-I podplatit-P
                 podpořit-P podporovat-I podráždit-P podražit-P podrazit-P podržet-P podrobit-P
                 podrobovat-I podsouvat-I podstoupit-P podstrčit-P podstrojovat-I podstupovat-I
                 podtrhávat-I podtrhnout-P podtrhovat-I podupávat-I podvádět-I podvázat-P
                 podvést-P podvazovat-I podvolit-P podvolovat-I podvrhnout-P pohánět-I pohasnout-P
                 pohlídat-P pohladit-P pohlížet-I pohlédnout-P pohřbít-P pohřbívat-I pohlcovat-I
                 pohledávat-I pohledět-P pohřešovat-I pohltit-P pohnat-P pohnout-P pohodit-P
                 pohořet-P pohoršit-P pohoršovat-I pohovořit-P pohrát-P pohrávat-I pohrdat-I
                 pohrdnout-P pohroužit-P pohrozit-P pohupovat-I pohybovat-I pocházet-I pochlubit-P
                 pochodit-P pochodovat-I pochopit-P pochovat-P pochroumat-P pochutnat-P pochválit-P
                 pochvalovat-I pochybět-P pochybit-P pochybovat-I pochytat-P pochytit-P pojídat-I
                 pojímat-I pojít-P pojednávat-I pojednat-P pojišťovat-I pojistit-P pojit-I
                 pojmenovávat-I pojmenovat-P pojmout-P pokašlávat-I pokývat-P pokývnout-P
                 pokazit-P pokládat-I poklást-P poklepat-P poklesávat-I poklesat-I poklesnout-P
                 pokřikovat-I pokřivovat-I poklonit-P pokřtít-P pokořit-P pokoušet-I pokousat-P
                 pokračovat-I pokračuje-I pokrčit-P pokrýt-P pokrývat-I pokročit-P pokulhávat-I
                 pokusit-P pokutovat-I pokydat-P pokynout-P pořádat-I políbit-P pořídit-P
                 poškodit-P poškozovat-I poškrábat-P poškrabat-P pošlapávat-I pošlapat-P
                 pošpinit-P polapit-P pošramotit-P polarizovat-I polévat-I polít-P poštěstit-P
                 poštvat-P pošušňávat-I polehávat-I polekat-P polemizovat-I polepit-P polepšit-P
                 polepovat-I poletovat-I polevit-P polevovat-I pořezat-P politizovat-I pořizovat-I
                 polknout-P pololhát-I položit-P polychromovat-B požádat-P požadovat-I požírat-I
                 požít-P požívat-I požehnat-P pomáhat-I pomíjet-I pomýšlet-I pomalovat-P
                 poměřovat-I pominout-P pomlčet-P pomlouvat-I pomluvit-P pomnožit-P pomnožovat-I
                 pomočit-P pomoci-P pomodlit-P pomrznout-P pomstít-P pomuchlat-P pomyslet-P
                 pomyslit-P ponížit-P poněmčit-P poněmčovat-I ponaučit-P ponechávat-I ponechat-P
                 poničit-P ponořit-P ponořovat-I ponoukat-I poodhalit-P poodhalovat-P poodhrnout-P
                 poodstoupit-P poohlédnout-P pookřát-P poopravit-P pootáčet-I pootočit-P
                 popálit-P popásat-I popadat-P popadnout-P popíjet-I popírat-I popisovat-I
                 popřát-P popřávat-I poplakat-P poplést-P popřít-P popřemýšlet-P popleskat-P
                 poplivat-P poplynout-P popojíždět-I poporůst-P popovídat-P poprat-P popravit-P
                 poprosit-P popsat-P poptávat-I popudit-P popularizovat-I poputovat-P porážet-I
                 poradit-P poraňovat-I poranit-P porazit-P porcovat-I porůst-P porodit-P
                 poroučet-I porovnávat-I porovnat-P porozumět-P portrétovat-I poručit-P porušit-P
                 porušovat-I porvat-P posadit-P posílat-I posílit-P posít-P posbírat-P posečkat-P
                 posedávat-I posedět-P posilnit-P posilovat-I poskakovat-I poskládat-P poskytnout-P
                 poskytovat-I poslat-P poslechnout-P poslouchat-I posloužit-P posluhovat-I
                 posmívat-I posoudit-P posouvat-I pospíchat-I pospíšit-P postačit-P postačovat-I
                 postát-P postávat-I postěžovat-P postarat-P postavit-P postesknout-P postihnout-P
                 postihovat-I postříkat-P postřílet-P postřehnout-P postřelit-P postoupit-P
                 postrádat-I postrčit-P postrašit-P postrkovat-I postulovat-I postupovat-I
                 posunkovat-I posunout-P posunovat-I posuzovat-I posvěcovat-I posvítit-P
                 posvětit-P potácet-I potáhnout-P potápět-I potýkat-I potěšit-P potěžkávat-I
                 potírat-I potýrat-P potit-I potkávat-I potkat-P potlačit-P potlačovat-I
                 potřást-P potřísnit-P potřebovat-I potopit-P potrápit-P potrefit-P potrestat-P
                 potrpět-I potrvat-P potulovat-I potupovat-I potvrdit-P potvrzovat-I poučit-P
                 poučovat-I poukázat-P poukazovat-I pouštět-I použít-P používat-I pousmát-P
                 poutat-I povážit-P povídat-I povědět-P povýšit-P povalit-P povařit-P pověřit-P
                 pověřovat-I považovat-I pověsit-P povést-P povinout-P povinovat-I povšimnout-P
                 povléci-P povolávat-I povolat-P povolit-P povolovat-I povozit-P povraždit-P
                 povstávat-I povstat-P povyrůst-P povzbudit-P povzbuzovat-I povzdechnout-P
                 povznášet-I povznést-P pozapomenout-P pozastavit-P pozastavovat-I pozatýkat-P
                 pozbýt-P pozbývat-I pozdravit-P pozdravovat-I pozdržet-P pozdvihnout-P pozřít-P
                 pozlobit-P pozůstavit-P pozměňovat-I pozměnit-P poznávat-I poznamenávat-I
                 poznamenat-P poznat-P pozorovat-I poztrácet-P pozvat-P pozvedat-I pozvednout-P
                 prát-I pracovávat-I pracovat-I prahnout-I praktikovat-I praštět-I praštit-P
                 prýštit-I pramenit-I pranýřovat-I praskat-I prasknout-P pravit-P predikovat-I
                 preferovat-I presentovat-I prezentovat-B prchat-I prchnout-P privatizovat-B
                 pršet-I pročítat-I pročesávat-I probíhat-I proběhnout-P probíjet-I probírat-I
                 probít-P problematizovat-I probleskovat-I probodnout-P probojovat-P probouzet-I
                 probrat-P probrečet-P probudit-P procedit-P procitat-I procitnout-P proclít-P
                 proclívat-I procvaknout-P procvičit-P procvičovat-I prodávat-I prodělávat-I
                 prodělat-P prodírat-I prodat-P prodiskutovávat-I prodiskutovat-P prodloužit-P
                 prodlužovat-I prodražit-P prodražovat-I prodrat-P produkovat-I profanovat-I
                 profesionalizovat-I profičet-P profilovat-B profitovat-I profrčet-P prognózovat-I
                 prohýbat-I prohazardovat-P prohazovat-I prohlásit-P prohlašovat-I prohlížet-I
                 prohlédnout-P prohledávat-I prohledat-P prohřešit-P prohřešovat-I prohloubit-P
                 prohlubovat-I prohodit-P prohrát-P prohrávat-I prohrnovat-I procházet-I
                 proinvestovat-P projíždět-I projasnit-P projít-P projednávat-I projednat-P
                 projektovat-I projet-P projevit-P projevovat-I prokázat-P prokazovat-I proklamovat-I
                 proklínat-I proklestit-P prokňučet-P proklubat-P prokouknout-P prokousat-P
                 prošetřit-P prošetřovat-I proškolit-P prošlapat-P prolamovat-I prolínat-I
                 prošpikovat-P prolít-P proříznout-P prořeknout-P proležet-P proletět-P prořezat-P
                 prolistovat-P prolnout-P proložit-P prolomit-P prožít-P prožívat-I prožvanit-P
                 promíchat-P promíjet-I promýšlet-I proměřit-P proměňovat-I proměřovat-I
                 proměnit-P promarnit-P promarodit-P promísit-P promítat-I promítnout-P promeškat-P
                 prominout-P promlčet-P promlouvat-I promluvit-P promnout-P promoknout-P
                 promrhat-P promyslet-P promyslit-P pronášet-I pronásledovat-I pronajímat-I
                 pronajmout-P pronést-P pronikat-I proniknout-P proočkovat-P propálit-P propásnout-P
                 propást-P propadat-I propadnout-P propagovat-I propíchat-P propíchnout-P
                 propašovávat-I propašovat-P propékat-I propít-P proplácet-I proplést-P proplétat-I
                 proplatit-P propůjčit-P propůjčovat-I propočíst-P propočítávat-I propojit-P
                 propojovat-I propouštět-I propracovávat-I propracovat-P proprat-P propuknout-P
                 propustit-P prorážet-I prorývat-I prorazit-P prorůst-P prorůstat-I prorokovat-I
                 prosáknout-P prosadit-P prosít-P prosívat-I prosazovat-I prosekat-P prosit-I
                 proskakovat-I proskočit-P proslýchat-I proslavit-P proslout-P proslovit-P
                 prospat-P prospět-P prospívat-I prosperovat-I prostavět-P prostituovat-I
                 prostříhat-P prostředkovat-I prostřelit-P prostoupit-P prostrčit-P prostudovat-P
                 prostupovat-I prosvítat-I protáčet-I protáhnout-P protahovat-I protínat-I
                 protéci-P protékat-I protežovat-I protestovat-I protiřečit-I protkat-P protlačit-P
                 protřepat-P protnout-P protrhávat-I protrhnout-P protrpět-P proudit-I proukázati-P
                 provádět-I provázet-I provalit-P prověřit-P prověřovat-I provést-P provézt-P
                 provětrat-P provdat-P provinit-P provokovat-I provolávat-I provolat-P provozovat-I
                 provzdušňovat-I prozkoumat-P prozradit-P prozrazovat-I psát-I psávat-I ptát-I
                 ptávat-I publikovat-B pudit-I puknout-P pulírovat-I pusinkovat-I pustit-P
                 putovat-I pykat-I pyšnit-I pytlačit-I ráčkovat-I rámovat-I radikalizovat-B
                 radit-I radovat-I ranit-P rýpnout-P rýsovat-I ratifikovat-B razítkovat-I
                 razit-I rdít-I reagovat-B realizovat-B recenzovat-I recitovat-I recyklovat-B
                 redigovat-I redukovat-B reeditovat-B reexportovat-P referovat-B reflektovat-I
                 reformovat-B regenerovat-B registrovat-B regulovat-I rehabilitovat-B reinvestovat-P
                 rekapitulovat-B reklamovat-I rekonstruovat-B rekreovat-I rekrutovat-I rekvalifikovat-B
                 rekvírovat-B relativizovat-I relaxovat-I režírovat-I remízovat-I remizovat-I
                 reorganizovat-B replikovat-I representovat-I reprezentovat-I reprodukovat-B
                 respektovat-I restaurovat-B restituovat-I restrukturalizovat-I retardovat-I
                 retušovat-B revalvovat-B revidovat-I revokovat-B rezavět-I rezervovat-B
                 rezignovat-B rezultovat-I riskovat-B růst-I různit-I rmoutit-I rodit-I rojit-I
                 rokovat-I rotovat-I rovnat-I rozčílit-P rozčarovat-P rozčeřit-P rozčilovat-I
                 rozčlenit-P rozbíhat-I rozběhnout-P rozbíjet-I rozbalit-P rozbít-P rozcupovat-P
                 rozcvičovat-I rozdávat-I rozdílet-I rozdělit-P rozdělovat-I rozdat-P rozdmýchat-P
                 rozdrobit-P rozdrtit-P rozeběhnout-P rozebírat-I rozebrat-P rozednívat-I
                 rozehřát-P rozehnat-P rozehrát-P rozehrávat-I rozechvět-P rozechvívat-I
                 rozejít-P rozepisovat-I rozepnout-P rozepsat-P rozesílat-I rozeslat-P rozesmát-P
                 rozestavět-P rozestavit-P rozetnout-P rozevírat-I rozevřít-P rozeznávat-I
                 rozeznat-P rozeznívat-I rozezpívat-I rozezvučet-P rozházet-P rozhýbat-P
                 rozhlížet-I rozhlédnout-P rozhněvat-P rozhodit-P rozhodnout-P rozhodovat-I
                 rozhořčit-P rozhořčovat-I rozhořet-P rozhorlit-P rozhostit-P rozhoupat-P
                 rozhovořit-P rozhrnout-P rozcházet-I rozjásat-P rozjíždět-I rozjet-P rozkazovat-I
                 rozkládat-I rozklížit-P rozklenout-P rozklepat-P rozkřičet-P rozkřiknout-P
                 rozkmitat-P rozkolísat-P rozkrást-P rozkramařit-P rozkvést-P rozšířit-P
                 rozlámat-P rozladit-P rozšiřovat-I rozškrábat-P rozšlehat-P rozléhat-I rozštěpit-P
                 rozlítit-P rozříznout-P rozřeďovat-P rozlehnout-P rozřešit-P rozlepit-P
                 rozletět-P rozlišit-P rozlišovat-I rozložit-P rozlomit-P rozloučit-P rozlučovat-I
                 rozluštit-P rozžvýkávat-I rozžvýkat-P rozmáhat-I rozmíchat-P rozmýšlet-I
                 rozmělňovat-I rozměnit-P rozmísťovat-I rozmístit-P rozmazat-P rozmetat-P
                 rozmlátit-P rozmlouvat-I rozmnožit-P rozmnožovat-I rozmoci-P rozmotat-P
                 rozmrznout-P rozmyslet-P rozmyslit-P roznášet-I rozněcovat-I roznést-P roznítit-P
                 rozpálit-P rozpárat-P rozpadat-I rozpadnout-P rozpíjet-I rozpakovat-I rozpalovat-I
                 rozpínat-I rozpitvávat-I rozplakat-P rozplývat-I rozplynout-P rozpočíst-P
                 rozpočítávat-I rozpočítat-P rozpoltit-P rozpomínat-I rozpomenout-P rozpouštět-I
                 rozpoutat-P rozpovídat-P rozpoznávat-I rozpoznat-P rozprášit-P rozprávět-I
                 rozpracovávat-I rozpracovat-P rozprašovat-I rozprodávat-I rozprodat-P rozprostírat-I
                 rozptýlit-P rozptylovat-I rozpustit-P rozrýt-P rozrazit-P rozrůst-P rozrůstat-I
                 rozrůzňovat-I rozrušit-P rozsít-P rozstřílet-P rozstrkat-P rozsvěcet-I rozsvítit-P
                 rozsypávat-I rozsypat-P roztáčet-I roztáhnout-P roztát-P roztahovat-I roztančit-P
                 roztancovat-P roztavit-P roztlačit-P roztřídit-P roztleskat-P roztočit-P
                 roztrhat-P roztrhnout-P roztrousit-P roztrpčit-P rozumět-I rozvádět-P rozvážit-P
                 rozvázat-P rozvíjet-I rozvířit-P rozvažovat-I rozvěsit-P rozvést-P rozvézt-P
                 rozvětvovat-I rozvinout-P rozvinovat-I rozvodnit-P rozvolnit-P rozvrátit-P
                 rozvrhnout-P rozzářit-P rozzlobit-P ručit-I ruinovat-I rukovat-I rušívat-I
                 rušit-I rvát-I rybařit-I sáhnout-P sýčkovat-I sálat-I sát-I sčítat-I sázet-I
                 sídlit-I sahat-I sílit-I sankcionovat-I sít-I sbíhat-I sbalit-P sbírat-I
                 sblížit-P scupovat-P scvrknout-P sdílet-I sdělit-P sdělovat-I sdružit-P
                 sdružovat-I sečíst-P seběhnout-P sebrat-P sedávat-I sedat-I sedět-I sednout-P
                 sehnat-P sehrát-P sehrávat-I sejít-P sejmout-P sekat-I sekundovat-I sešít-P
                 seřadit-P seřídit-P seškrtat-P selektovat-I selhávat-I selhat-P seřizovat-I
                 seřvat-P sežehnout-P sežrat-P semlít-P semnout-P sepisovat-I sepsat-P sepsout-P
                 servírovat-B sesadit-P seskočit-P seskupovat-I sestávat-I sestavit-P sestavovat-I
                 sestřelit-P sestoupit-P sestrojit-P sestupovat-I sestykovat-P sesunout-P
                 sesypat-P setkávat-I setkat-P setřít-P setnout-P setrvávat-I setrvat-P sevřít-P
                 seznámit-P seznamovat-I sezvat-P shánět-I shazovat-I shlížet-I shledávat-I
                 shledat-P shluknout-P shlukovat-I shodit-P shodnout-P shodovat-I shořet-P
                 shrnout-P shrnovat-I shromáždit-P shromažďovat-I scházívat-I scházet-I schnout-I
                 schovávat-I schovat-P schválit-P schvalovat-I schylovat-I schytat-P signalizovat-I
                 signovat-B simulovat-I situovat-I sjíždět-I sjednávat-I sjednat-P sjednocovat-I
                 sjednotit-P sjet-P sjezdit-P skákat-I skórovat-B skandalizovat-I skandovat-I
                 skartovat-B skýtat-I skládat-I sklánět-I skladovat-I skřípat-I sklízet-I
                 sklidit-P skloňovat-I sklonit-P skloubit-P sklouzávat-I sklouznout-P skočit-P
                 skolit-P skončit-P skonat-P skoncovat-P skrýt-P skrývat-I skrečovat-I skupovat-I
                 skutálet-P skvět-I slábnout-I slíbit-P sladit-P slýchávat-I slýchat-I slévat-I
                 slézat-I slézt-P slavit-I sledovat-I slehnout-P slepit-P slepovat-I slevit-P
                 slevovat-I slibovat-I slitovat-P složit-P sloučit-P sloužívat-I sloužit-I
                 slout-I slučovat-I slušet-I slunit-I slupnout-P slyšívat-I slyšet-I sžírat-I
                 sžít-P smát-I smávat-I smíchat-P smýkat-I smířit-P směňovat-I směřovat-I
                 smažit-I směnit-P směrovat-I smísit-P směstnat-P smést-P smět-I smítat-I
                 smazat-P smekat-I smeknout-P smilovat-P smiřovat-I smlouvat-I smluvit-P
                 smolit-I smontovat-P smrákat-I smrdět-I smrštit-P snášet-I snažívat-I snažit-I
                 snížit-P sněžit-I snímat-I sníst-P snést-P snít-I snižovat-I snoubit-I sondovat-I
                 soucítit-I soudcovat-I soudit-I souhlasit-I soupeřit-I sousedit-I soustřeďovat-I
                 soustředit-P soutěžit-I souviset-I souznít-P spáchat-P spálit-P spářit-P
                 spásat-I spát-I spadat-I spadnout-P spěchat-I spíchnout-P spílat-I spalovat-I
                 spasit-P spékat-I spět-I spatřit-P spatřovat-I specializovat-B specifikovat-B
                 spekulovat-I spelovat-I spiknout-I spisovat-I splácet-I spřádat-I spřátelit-P
                 splakat-P splasknout-P splést-P splétat-I splatit-P splývat-I spříznit-P
                 splňovat-I splnit-P splynout-P spočíst-P spočítat-P spočívat-I spočinout-P
                 spojit-P spojovat-I spokojit-P spokojovat-I spořádat-P spolčit-P spoléhat-I
                 spolehnout-P spořit-I spolknout-P spolufinancovat-I spolužít-I spolupůsobit-I
                 spolupodílet-I spolupracovat-I spoluredigovat-I spolurozhodovat-I spoluvytvářet-I
                 spoluzahájit-P spoluzaložit-P spolykat-P sponzorovat-I sportovat-I spotřebovávat-I
                 spotřebovat-P spouštět-I spoutat-P spravit-P spravovat-I sprchnout-P sprchovat-I
                 sprintovat-I sprovodit-P spustit-P srážet-I srazit-P srůst-P srůstat-I sroubit-P
                 srovnávat-I srovnat-P stáčet-I stačívat-I stáhnout-P stačit-I stárnout-I
                 stát-I stávat-I stávkovat-I stabilizovat-B stagnovat-I stíhat-I stahovat-I
                 stěhovat-I stýkat-I stěžovat-I stínat-I stanout-P stanovit-P stanovovat-I
                 starat-I stírat-I startovat-I stýskat-I stísnit-P stavět-I stavit-I sterilizovat-B
                 sterilovat-B stihnout-P stimulovat-B stiskat-I stisknout-P střádat-I stlačit-P
                 stlačovat-I střídávat-I střídat-I stříkat-I střílet-I střelit-P střežit-I
                 střetávat-I střetnout-P stmívat-I stmelit-P stočit-P stonat-I stop-P stopovat-I
                 stornovat-B stoupat-I stoupit-P stoupnout-P strádat-I strávit-P strachovat-I
                 strčit-P strašit-I stranit-I stravovat-I strefit-P strhávat-I strhat-P strhnout-P
                 strkat-I strnout-P strpět-P strukturovat-B studovat-I stupňovat-I stvořit-P
                 stvrdit-P stvrzovat-I stydět-I subvencovat-I sugerovat-B sušit-I sužovat-I
                 sumarizovat-I sundávat-I sundat-P sundavat-I sunout-I suplovat-I surfovat-I
                 suspendovat-I svádět-I svářet-I svážet-I svázat-P svědčívat-I svědčit-I
                 svědět-I svěřit-P svařovat-I svěřovat-I svažovat-I svírat-I svést-P svézt-P
                 svítat-I svítit-I světit-I svatořečit-B svazovat-I svištět-I svitnout-P
                 svléci-P svlékat-I svléknout-P svolávat-I svolat-P svolit-P svrbět-I svrbit-I
                 svrhnout-P syčet-I symbolizovat-I sympatizovat-I synchronizovat-B syntetizovat-I
                 sypat-I sytit-I tábořit-I táhnout-I tápat-I tát-I tázat-I tabuizovat-I tahat-I
                 tíhnout-I tajit-I týkat-I taktizovat-I těšívat-I těšit-I tížit-I těžit-I
                 tančit-I tancovat-I tankovat-I típnout-P týrat-I tasit-I tísnit-I téci-I
                 téct-I týt-I taxikařit-I tečovat-I telefonovat-I telit-I tematizovat-I tenčit-I
                 tendovat-I tepat-I terorizovat-I testovat-I tetovat-I textovat-I tipnout-P
                 tipovat-I tisknout-I titulovat-I tkvít-I tlačit-I třást-I tříbit-I třídit-I
                 tříštit-I třímat-I třaskat-I třísknout-P třepetat-I tleskat-I tlouci-I třpytit-I
                 tlumit-I tlumočit-I tmět-I tmelit-I točit-I tolerovat-I tonout-I topit-I
                 torpédovat-I toulat-I toužívat-I toužit-I trápívat-I trápit-I trávit-I tradovat-I
                 trčet-I traktovat-I transformovat-B transplantovat-B transportovat-B trénovat-I
                 tratit-I trefit-P trestat-I trhat-I trhnout-P triumfovat-I trmácet-I tropit-I
                 troskotat-I troufat-I troufnout-P trousit-I trpět-I trpívat-I trucovat-I
                 trumfnout-P trumfovat-I trvávat-I trvat-I tuhnout-I tušívat-I tušit-I tutlat-I
                 tvářet-I tvářit-I tvarovat-I tvořívat-I tvořit-I tvrdívat-I tvrdit-I tyčit-I
                 učívat-I učinit-P učit-I ubíhat-I uběhnout-P ubíjet-I ubírat-I ubít-P ubýt-P
                 ubývat-I ubezpečit-P ubezpečovat-I ublížit-P ubližovat-I ubodat-P ubránit-P
                 ubrat-P ubytovat-P ucítit-P ucpávat-I ucpat-P uctít-P uctívat-I udát-P udávat-I
                 udýchat-P udělat-P udílet-I udělit-P udělovat-I udat-P udeřit-P udivit-P
                 udivovat-I udržet-P udržovat-I udusit-P uhádnout-P uhájit-P uhasit-P uhasnout-P
                 uhlídat-P uhnívat-I uhnízdit-P uhnout-P uhodit-P uhodnout-P uhrát-P uhradit-P
                 uhranout-P uhrazovat-I uhynout-P ucházet-I uchýlit-P uchlácholit-P uchopit-P
                 uchopovat-I uchovávat-I uchovat-P uchránit-P uchvátit-P uchvacovat-I uchylovat-I
                 uchytit-P ujídat-I ujíždět-I ujímat-I ujasnit-P ujíst-P ujít-P ujednat-P
                 ujet-P ujeti-P ujišťovat-I ujistit-P ujmout-P ukázat-P ukáznit-P ukamenovat-P
                 ukapávat-I ukazovat-I ukládat-I uklízet-I uklidit-P uklidňovat-I uklidnit-P
                 uklouznout-P ukočírovat-P ukojit-P ukončit-P ukončovat-I ukrást-P ukradnout-P
                 ukrýt-P ukrývat-I ukusovat-I ukvapit-P ušít-P ušetřit-P ušklíbnout-P uškodit-P
                 uškrtit-P ulít-P uštvat-P uříznout-P ulehčit-P ulehčovat-I ulehnout-P uletět-P
                 ulevit-P uložit-P ulomit-P uloupnout-P ulovit-P ulpívat-I užírat-I užasnout-P
                 užít-P užívat-I uživit-P umínit-P umanout-P umírat-I umísťovat-I umístit-P
                 umýt-P umět-I umisťovat-I umlčet-P umlčovat-I umřít-P umocňovat-I umocnit-P
                 umořovat-I umožňovat-I umožnit-P umoudřit-P umrtvit-P umučit-P unášet-I
                 unést-P unavit-P unavovat-I unikat-I uniknout-P upálit-P upadat-I upadnout-P
                 upalovat-I upamatovat-P upínat-I upírat-I upéci-P upít-P upevňovat-I upevnit-P
                 upisovat-I uplácet-I upřít-P uplatit-P uplatňovat-I uplatnit-P uplývat-I
                 upřednostňovat-I upřesňovat-I upřesnit-P uplynout-P upnout-P upomínat-I
                 uposlechnout-P upotřebit-P upouštět-I upoutávat-I upoutat-P upozorňovat-I
                 upozornit-P uprázdnit-P upravit-P upravovat-I uprchnout-P upsat-P upustit-P
                 urážet-I určit-P určovat-I urazit-P urgovat-B urovnat-P urychlit-P urychlovat-I
                 usadit-P usídlit-P usínat-I usazovat-I usedat-I usednout-P uschovávat-I
                 uschovat-P usilovat-I uskladnit-P uskromnit-P uskrovnit-P uskutečňovat-I
                 uskutečnit-P uslyšet-P usmát-P usmířit-P usměrňovat-I usměrnit-P usmívat-I
                 usmiřovat-I usmrtit-P usnášet-I usnadňovat-I usnadnit-P usnést-P usnout-P
                 usoudit-P usoužit-P uspěchat-P uspíšit-P uspat-P uspět-P uspokojit-P uspokojovat-I
                 uspořádat-P uspořit-P ustálit-P ustát-P ustávat-I ustalovat-I ustanovit-P
                 ustanovovat-I ustat-P ustavit-P ustavovat-I ustoupit-P ustrnout-P ustupovat-I
                 usuzovat-I usvědčit-P utábořit-P utáhnout-P utahovat-I utajit-P utajovat-I
                 utíkat-I utěšovat-I utírat-I utýrat-P utéci-P utichnout-P utišovat-I utkávat-I
                 utkat-P utkvít-P utkvět-P utlačovat-I utřást-P utříbit-P utřídit-P utřít-P
                 utlouci-P utloukat-I utlumit-P utlumovat-I utnout-P utonout-P utopit-P utrácet-I
                 utratit-P utrhat-I utrhnout-P utržit-P utrousit-P utrpět-P utuchat-I utužovat-I
                 ututlat-P utvářet-I utvořit-P utvrdit-P utvrzovat-I uvádět-I uvážit-P uvázat-P
                 uváznout-P uvědomit-P uvědomovat-I uvalit-P uvařit-P uvěřit-P uvalovat-I
                 uvažovat-I uvést-P uvítat-P uvěznit-P uvíznout-P uveřejňovat-I uveřejnit-P
                 uvidět-P uvolit-P uvolňovat-I uvolnit-P uvrhnout-P uzákonit-P uzamknout-P
                 uzavírat-I uzavřít-P uzdravit-P uzdravovat-I uzemnit-P uzlit-I uznávat-I
                 uznat-P uzpůsobit-P uzrát-P uzurpovat-B vábit-I váhat-I válčit-I vážit-I
                 vát-I vázat-I váznout-I vídat-I vědět-I vadívat-I vadit-I věšet-I věštit-I
                 věřívat-I včleňovat-P valit-I vařit-I věřit-I valorizovat-B vandrovat-I
                 vanout-I věnovat-I varovat-I věstit-I vést-I vévodit-I vézt-I vít-I výt-I
                 vítat-I vítězit-I větrat-I větvit-I vězet-I věznit-I vběhnout-P vcítit-P
                 vděčit-I vdát-P vdávat-I vdechovat-I vejít-P velebit-I velet-I velnout-P
                 ventilovat-B vepsat-P verbovat-I verifikovat-B veselit-I vestavět-P vetkat-P
                 vetknout-P vetřít-P vetovat-I vhazovat-I vhodit-P vcházet-I vidět-I vidívat-I
                 vinit-I viset-I viz-I vjíždět-I vjet-P vkládat-I vklouznout-P vkrádat-I
                 vkročit-P vládnout-I všímat-I vlát-I všívat-I všimnout-P vlastnit-I vléci-I
                 vlétat-I vlézat-I vlézt-P vřít-I vštípit-P vštěpovat-I vřítit-P vlítnout-P
                 vlepit-P vlepovat-I vletět-P vlnit-I vložit-P vloudit-P vloupat-P vžít-P
                 vžívat-I vměšovat-I vměstnat-P vnášet-I vnadit-I vnímat-I vnést-P vnikat-I
                 vniknout-P vnucovat-I vnutit-P vodit-I volávat-I volat-I volit-I vonět-I
                 voperovat-P vozit-I vpálit-P vpadnout-P vpíjet-I vpašovat-P vplížit-P vplést-P
                 vplétat-I vplout-P vplouvat-I vplynout-P vpouštět-I vpravit-P vpravovat-I
                 vpustit-P vrážet-I vrátit-P vracívat-I vracet-I vrčet-I vraždit-I vrýt-P
                 vrhat-I vrhnout-P vrcholit-I vrůst-P vrůstat-I vrtat-I vrtět-I vrzat-I vsázet-I
                 vsadit-P vsítit-P vsazovat-I vsednout-P vsouvat-I vstát-P vstávat-I vstříknout-P
                 vstřebávat-I vstřebat-P vstřelit-P vstoupit-P vstupovat-I vsunout-P vtáhnout-P
                 vtahovat-I vtělit-P vtělovat-I vtípit-I vtírat-I vtěsnat-P vtipkovat-I vtisknout-P
                 vtiskovat-I vtlačit-P vtrhnout-P vyčíslit-P vyčíslovat-P vyčíst-P vyčítat-I
                 vyčerpávat-I vyčerpat-P vyčinit-P vyčistit-P vyčkávat-I vyčkat-P vyčleňovat-I
                 vyčlenit-P vyčnívat-I vyúčtovat-P vyasfaltovat-P vyúsťovat-I vyústit-P vybídnout-P
                 vybíhat-I vyběhat-P vyběhnout-P vybíjet-I vybalancovat-P vybírat-I vybarvit-P
                 vybarvovat-I vybýt-P vybavit-P vybavovat-I vybízet-I vybičovat-I vyblednout-P
                 vybočit-P vybočovat-I vybojovat-P vybourat-P vyboxovat-P vybrakovat-P vybrat-P
                 vybrousit-P vybruslit-P vybudovat-P vybuchnout-P vybuchovat-I vybujet-P
                 vyburcovat-P vycítit-P vycementovat-P vycestovat-P vycouvat-P vycucat-P
                 vydávat-I vydědit-P vydýchat-P vydělávat-I vydělat-P vydařit-P vydělit-P
                 vydělovat-I vydírat-I vyděsit-P vydat-P vydedukovat-P vydechnout-P vydechovat-I
                 vydekorovat-P vydlabat-P vydlužit-P vydobýt-P vydolovat-P vydovádět-P vydražit-P
                 vydrancovat-P vydržet-P vydržovat-I vydupat-P vyfasovat-P vyfotografovat-P
                 vyfouknout-P vygradovat-P vygumovat-P vyháčkovat-P vyhánět-I vyházet-P vyhýbat-I
                 vyhasínat-I vyhasnout-P vyhazovat-I vyhlásit-P vyhladit-P vyhlašovat-I vyhlížet-I
                 vyhlédnout-P vyhřívat-I vyhlazovat-I vyhledávat-I vyhledat-P vyhloubit-P
                 vyhmátnout-P vyhnat-P vyhnout-P vyhodit-P vyhodnocovat-I vyhodnotit-P vyhošťovat-I
                 vyhořet-P vyhostit-P vyhotovit-P vyhoupnout-P vyhovět-P vyhovovat-I vyhrát-P
                 vyhrávat-I vyhrabávat-I vyhrabat-P vyhradit-P vyhraňovat-I vyhranit-P vyhrkávat-I
                 vyhrkat-I vyhrknout-P vyhrnout-P vyhrocovat-I vyhrožovat-I vyhrotit-P vyhubit-P
                 vyhynout-P vycházet-I vychýlit-P vychladnout-P vychodit-P vychovávat-I vychovat-P
                 vychrlit-P vychutnávat-I vychutnat-P vychvalovat-I vychytat-P vyinkasovat-P
                 vyjádřit-P vyjadřovat-I vyjíždět-I vyjímat-I vyjasňovat-I vyjasnit-P vyjít-P
                 vyjednávat-I vyjednat-P vyjet-P vyjevit-P vyjmenovat-P vyjmout-P vykácet-P
                 vykázat-P vykazovat-I vykládat-I vyklíčit-P vyklízet-I vyklidit-P vykřiknout-P
                 vykřikovat-I vyklopit-P vykloubit-P vyklubat-P vyklusávat-I vykolíkovat-P
                 vykoledovat-P vykořenit-P vykompenzovat-P vykonávat-I vykonat-P vykopávat-I
                 vykopat-P vykopnout-P vykouknout-P vykoupat-P vykoupit-P vykouzlit-P vykrádat-I
                 vykrást-P vykrýt-P vykreslit-P vykrmit-P vykročit-P vykrvácet-P vykrystalizovat-P
                 vykuchávat-I vykukovat-I vykupovat-I vykvést-P vykvétat-I vyšachovat-P vylíčit-P
                 vylákat-P vylámat-P vyřadit-P vyřídit-P vyšetřit-P vyšetřovat-I vylíhnout-P
                 vyříkat-P vyškemrat-P vyškolit-P vyškrtnout-P vyšlápnout-P vyšlapat-P vyšlehnout-P
                 vyšlechtit-P vylamovat-I vyšperkovat-P vyšplhat-P vyšroubovat-P vyléčit-P
                 vylétat-I vylétnout-P vylézat-I vylézt-P vylít-P vyšumět-P vyšvihnout-P
                 vylízat-P vyříznout-P vyřazovat-I vylekat-P vyřešit-P vylepit-P vylepšit-P
                 vylepšovat-I vyletět-P vyřezat-P vylhávat-I vylidnit-P vyřizovat-I vyřknout-P
                 vylodit-P vyložit-P vylomit-P vylosovat-P vyloučit-P vyloupit-P vyloupnout-P
                 vylovit-P vylučovat-I vylustrovat-P vyluxovat-P vyžádat-P vyžadovat-I vymáčknout-P
                 vymáhat-I vymámit-P vymýšlet-I vyměřit-P vymalovat-P vyměňovat-I vyměřovat-I
                 vymanévrovat-P vymanit-P vymínit-P vyměnit-P vymírat-I vymést-P vymýtit-P
                 vymývat-I vymazat-P vymetat-I vymezit-P vymezovat-I vymiňovat-I vymizet-P
                 vymknout-P vymřít-P vymlouvat-I vymluvit-P vymočit-P vymoci-P vymodelovat-P
                 vymodlit-P vymrštit-P vymstít-P vymycovat-I vymykat-I vymyslet-P vymyslit-P
                 vynášet-I vynásobit-P vynadat-P vynahradit-P vynacházet-I vynakládat-I vynalézat-I
                 vynaleznout-P vynaložit-P vynést-P vyndávat-I vyndat-P vynechávat-I vynechat-P
                 vynikat-I vyniknout-P vynořit-P vynořovat-I vynucovat-I vynulovat-P vynutit-P
                 vyobrazit-P vyoperovat-P vyostřit-P vyostřovat-I vypáčit-P vypálit-P vypátrat-P
                 vypadávat-I vypadat-I vypadnout-P vypíchnout-P vypařit-P vypínat-I vypískat-P
                 vypěstovat-P vypít-P vypiplat-P vypisovat-I vyplácet-I vyplašit-P vyplatit-P
                 vyplýtvávat-I vyplavat-P vyplývat-I vyplenit-P vyplivnout-P vyplňovat-I
                 vyplnit-P vyplout-P vyplouvat-I vyplynout-P vypůjčit-P vypůjčovat-I vypnout-P
                 vypočíst-P vypočítávat-I vypočítat-P vypořádávat-I vypořádat-P vypomáhat-I
                 vypomoci-P vypouštět-I vypovídat-I vypovědět-P vyprávět-I vypracovávat-I
                 vypracovat-P vyprat-P vypravit-P vypravovat-I vyprazdňovat-I vypreparovat-P
                 vyprchat-P vypršet-P vyprodávat-I vyprodat-P vyprodukovat-P vyprofilovat-P
                 vyprojektovat-P vyprošťovat-I vyprostit-P vyprovázet-I vyprovodit-P vyprovokovat-P
                 vypsat-P vyptávat-I vyptat-I vypudit-P vypuknout-P vypumpovat-P vypustit-P
                 vypuzovat-I vyrábět-I vyrážet-I vyrýt-P vyrazit-P vyrůst-P vyrůstat-I vyrobit-P
                 vyrojit-P vyrovnávat-I vyrovnat-P vyrozumět-P vyrozumívat-I vyrukovat-P
                 vyrušit-P vyrvat-P vysávat-I vysázet-P vysadit-P vysílat-I vysazovat-I vysedávat-I
                 vysedat-I vyschnout-P vyskakovat-I vyskočit-P vyskytnout-P vyskytovat-I
                 vyslýchat-I vyslat-P vysledovat-P vyslechnout-P vysloužit-P vyslovit-P vyslovovat-I
                 vyslyšet-P vysmát-P vysmívat-I vysmeknout-P vysnívat-I vysouvat-I vyspat-P
                 vyspět-P vyspravit-P vysrat-P vystačit-P vystačovat-I vystěhovat-P vystýlat-I
                 vystartovat-P vystavět-P vystavit-P vystavovat-I vystihnout-P vystihovat-I
                 vystřídat-P vystříhat-B vystřílet-P vystřízlivět-P vystřelit-P vystřelovat-I
                 vystřihávat-I vystřihnout-P vystopovat-P vystoupat-P vystoupit-P vystrčit-P
                 vystrašit-P vystrkovat-I vystrojit-P vystudovat-P vystupňovat-P vystupovat-I
                 vysušit-P vysunout-P vysvítat-I vysvětit-P vysvětlit-P vysvětlovat-I vysvitnout-P
                 vysvobodit-P vysvobozovat-I vysychat-I vysypat-P vytáčet-I vytáhnout-P vytýčit-P
                 vytápět-I vytahat-P vytahovat-I vytýkat-I vytížit-P vytěžit-P vytanout-P
                 vytasit-P vytěsnit-P vytéci-P vytečkovat-P vytempovat-P vytesávat-I vytesat-P
                 vytetovat-P vytipovat-P vytisknout-P vytknout-P vytlačit-P vytlačovat-I
                 vytříbit-P vytřídit-P vytřískat-P vytloukat-I vytočit-P vytrácet-I vytratit-P
                 vytrejdovat-P vytrhávat-I vytrhat-P vytrhnout-P vytrhovat-I vytrpět-P vytrucovat-P
                 vytrvávat-I vytrvat-P vytušit-P vytvářet-I vytvarovat-P vytvořit-P vytyčit-P
                 vytyčovat-I vytypovat-I vyučit-P vyučovat-I využít-P využívat-I vyvádět-I
                 vyvážet-I vyvážit-P vyváznout-P vyvíjet-I vyvalit-P vyvařovat-I vyvažovat-I
                 vyvěrat-I vyvarovat-P vyvěsit-P vyvést-P vyvézt-P vyvinout-P vyvinovat-I
                 vyvlastňovat-I vyvlastnit-P vyvléknout-P vyvodit-P vyvolávat-I vyvolat-P
                 vyvozovat-I vyvrátit-P vyvracet-I vyvražďovat-I vyvraždit-P vyvrcholit-P
                 vyvstávat-I vyvstat-P vyvzdorovat-P vyzářit-P vyzařovat-I vyzývat-I vyzbrojit-P
                 vyzbrojovat-I vyzdobit-P vyzdvihnout-P vyzdvihovat-I vyzkoušet-P vyzkoumat-P
                 vyznačit-P vyznačovat-I vyznávat-I vyznamenat-P vyznat-P vyznít-P vyznívat-I
                 vyzobávat-I vyzpívat-I vyzpovídat-P vyzrát-P vyzradit-P vyztužit-P vyzvánět-I
                 vyzvídat-I vyzvědět-P vyzvat-P vyzvedávat-I vyzvednout-P vzít-P vzývat-I
                 vzbouřit-P vzbouzet-I vzbudit-P vzbuzovat-I vzdálit-P vzdát-P vzdávat-I
                 vzdělávat-I vzdělat-P vzdalovat-I vzdorovat-I vzdychat-I vzdychnout-P vzedmout-P
                 vzejít-P vzepřít-P vzhlížet-I vzhlédnout-P vzchopit-P vzkázat-P vzkazovat-I
                 vzklíčit-P vzkřísit-P vzlétat-I vzlétnout-P vznášet-I vznést-P vznítit-P
                 vznikat-I vzniknout-P vzpamatovávat-I vzpamatovat-P vzpínat-I vzpírat-I
                 vzplanout-P vzpomínat-I vzpomenout-P vzrůst-P vzrůstat-I vzrušit-P vzrušovat-I
                 vztáhnout-P vztahovat-I vztyčit-P vztyčovat-I začínat-I začíst-P začít-P
                 zábst-I začervenat-P začleňovat-I záležet-I začlenit-P zářit-I zálohovat-B
                 zápasit-I zápolit-I zaúčtovat-P zásobovat-I zaútočit-P závidět-I záviset-I
                 závodit-I závojovat-I zaběhnout-P zabíjet-I zabalit-P zabalovat-I zabírat-I
                 zabarikádovat-P zabarvit-P zabít-P zabývat-I zabavit-P zabavovat-I zaberanit-P
                 zabetonovat-P zabezpečit-P zabezpečovat-I zablátit-P zabředat-I zabřednout-P
                 zablokovat-P zabloudit-P zabodnout-P zabodovat-P zabolet-P zabořit-P zabouchnout-P
                 zabránit-P zabraňovat-I zabrat-P zabrnkat-P zabrzdit-P zabudovávat-I zabudovat-P
                 zabydlet-P zabydlovat-I zacelit-P zacelovat-I zacloumat-P zacpávat-I zadávat-I
                 zadat-P zadlužit-P zadlužovat-I zadministrovat-P zadout-P zadrhnout-P zadržet-P
                 zadržovat-I zadrnčet-P zčervenat-P zafixovat-P zafungovat-P zahájit-P zahálet-I
                 zahánět-I zahýbat-I zahajovat-I zahalit-P zahalovat-I zahanbit-P zahaprovat-P
                 zahřát-P zahladit-P zahlédnout-P zahřívat-I zahlazovat-I zahledět-P zahltit-P
                 zahnat-P zahnout-P zahodit-P zahojit-P zahrát-P zahrávat-I zahrabat-P zahradit-P
                 zahrazovat-I zahrnout-P zahrnovat-I zahrozit-P zahryznout-P zahubit-P zahustit-P
                 zahynout-P zacházel-I zacházet-I zachovávat-I zachovat-P zachránit-P zachraňovat-I
                 zachtít-P zachumlat-P zachvátit-P zachvět-P zachycovat-I zachytávat-I zachytat-P
                 zachytit-P zachytnout-P zainteresovat-P zčitelnit-P zajásat-P zajíždět-I
                 zajímat-I zajít-P zajet-P zajišťovat-I zajiskřit-P zajistit-P zajmout-P
                 zakázat-P zakódovat-P zakalkulovat-P zakazovat-I zakládat-I zaklít-P zakleknout-P
                 zaklepat-P zakřičet-P zakřivovat-I zaknihovat-P zakolísat-P zakořenit-P
                 zakomponovat-P zakončit-P zakončovat-I zakonzervovat-P zakopat-P zakopnout-P
                 zakormidlovat-P zakotvit-P zakotvovat-I zakoukat-P zakoupit-P zakousnout-P
                 zakrýt-P zakrývat-I zakreslit-P zakrnět-P zakročit-P zakročovat-I zaktivizovat-P
                 zaktualizovat-P zakuklit-P zakupovat-I zakusovat-I zakutat-P zašátrat-P
                 zařaďovat-I zašívat-I zalíbit-P zařadit-P zařídit-P zašeptat-P zašermovat-P
                 zaškolit-P zaškrtnout-P zalarmovat-P zalévat-I zalézat-I zalézt-P zalít-P
                 zaštítit-P zaštiťovat-I zaříznout-P zařazovat-I zaleknout-P zařeknout-P
                 zalepit-P zařezávat-I zalichotit-P zalitovat-P zařizovat-I založit-P zalomit-P
                 zařvat-P zalyžovat-P zažádat-P zažíhat-I zažalovat-P zažít-P zažívat-I zažehnat-P
                 zamáčknout-P zamávat-P zamíchat-P zamýšlet-I zamířit-P zaměřit-P zaměňovat-I
                 zaměřovat-I zaměnit-P zamanout-P zamaskovat-P zaměstnávat-I zaměstnat-P
                 zamést-P zamítat-I zamítnout-P zameškat-P zametat-I zamezit-P zamezovat-I
                 zamilovat-P zamknout-P zamlčet-P zamlčovat-I zamlžovat-I zamlouvat-I zamluvit-P
                 zamnout-P zamořit-P zamotat-P zamručet-P zamrznout-P zamykat-I zamyslet-P
                 zamyslit-P zanášet-I zanést-P zanedbávat-I zanedbat-P zanechávat-I zanechat-P
                 zaneprázdnit-P zanikat-I zaniknout-P zanořovat-I zaobírat-P zaoblit-P zaokrouhlit-P
                 zaokrouhlovat-I zaopatřovat-I zaostávat-I zaostat-P zapálit-P zapadávat-I
                 zapadat-I zapadnout-P zapíchnout-P zapalovat-I zapamatovat-P zapínat-I zaparkovat-P
                 zapět-P zapečetit-P zapisovat-I zapřáhnout-P zapříčinit-P zaplakat-P zaplašit-P
                 zaplašovat-I zaplést-P zaplétat-I zapřít-P zaplatit-P zaplavat-P zaplavit-P
                 zaplavovat-I zaplňovat-I zaplnit-P zapůjčit-P zapůjčovat-I zapůsobit-P zapnout-P
                 započíst-P započít-P započítávat-I započítat-P zapochybovat-P zapojit-P
                 zapojovat-I zapomínat-I zapomenout-P zaposlouchat-P zapotit-P zapovídat-P
                 zapovědět-P zapracovávat-I zapraskat-P zaprodávat-I zaprotokolovat-P zapsat-P
                 zapudit-P zapustit-P zarážet-I zarámovat-P zaradovat-P zírat-I zarývat-I
                 zarazit-P zareagovat-P zaregistrovat-P zariskovat-P zarůstat-P zarmoutit-P
                 zaručit-P zaručovat-I zasáhnout-P zúčastňovat-I zúčastnit-P zasadit-P zasahovat-I
                 zasílat-I zasít-P zúčtovat-P zasazovat-I zasedat-I zasednout-P zaseknout-P
                 získávat-I získat-P zaskočit-P zaslat-P zaslechnout-P zaslepit-P zaslepovat-I
                 zasloužit-P zasluhovat-I zúžit-P zasmát-P zasmečovat-P zasout-P zaspat-P
                 zúročit-P zastávat-I zastínit-P zastarávat-I zastírat-I zastat-P zastavět-P
                 zastavit-P zastavovat-I zastihnout-P zastihovat-I zastiňovat-I zastřít-P
                 zastřešovat-I zastřelit-P zastoupit-P zastrašit-P zastrašovat-I zastrkávat-I
                 zastupovat-I zastydět-P zasvítit-P zasvětit-P zasypat-P zatáčet-I zatáhnout-P
                 zatápět-I zatajit-P zatajovat-I zatýkat-I zatížit-P zatěžovat-I zatančit-P
                 zatarasit-P zatékat-I zatavit-P zatelefonovat-P zatemňovat-I zatemnit-P
                 zateplovat-I zatknout-P zatlačit-P zatřást-P zatřepat-P zatleskat-P zatlouci-P
                 zatnout-P zatočit-P zatopit-P zatoulat-P zatoužit-P zatracovat-I zatrénovat-P
                 zatratit-P zatrhnout-P zatrnout-P zatroubit-P zatvářit-P zaujímat-I zaujmout-P
                 zauzlovat-P zavádět-I zaváhat-P zavážet-I zavánět-I zavát-P zavázat-P zavadit-P
                 zavěšovat-I zavalit-P zavírat-I zavěsit-P zavést-P zavézt-P zavítat-P zavazovat-I
                 zavděčit-P zavdávat-I zavdat-P zavelet-P zavinit-P zavinout-P zavládnout-P
                 zavlát-P zavléci-P zavřít-P zavolat-P zavraždit-P zavrhnout-P zavrhovat-I
                 završit-P završovat-I zavrtávat-I zavrtět-P zavzpomínat-P zazářit-P zazlít-P
                 zazlívat-I zaznamenávat-I zaznamenat-P zaznít-P zaznívat-I zazpívat-P zazvonit-P
                 zbankrotovat-P zbít-P zbýt-P zbývat-I zbavit-P zbavovat-I zbláznit-P zblbnout-P
                 zblokovat-P zbobtnat-P zbohatnout-P zbořit-P zbožštit-P zbožňovat-I zbortit-P
                 zbourat-P zbrázdit-P zbrojit-I zbrousit-P zbrzdit-P zbudovat-P zbuntovat-P
                 zbystřit-P zcizit-P zdát-I zdávat-I zdědit-P zdařit-P zdaňovat-I zdanit-P
                 zdecimovat-P zdeformovat-P zdemolovat-P zdiskreditovat-P zdřímnout-P zdůrazňovat-I
                 zdůraznit-P zdůvodňovat-I zdůvodnit-P zdobit-I zdokonalit-P zdokonalovat-I
                 zdolávat-I zdolat-P zdomácnět-P zdráhat-I zdražit-P zdražovat-I zdramatizovat-P
                 zdravit-I zdržet-P zdržovat-I zdrsnit-P zdrtit-P zdvihnout-P zdvojit-P zdvojnásobit-P
                 zdvojnásobovat-I zefektivňovat-I zešedivět-I zeštíhlet-P zeštíhlit-P zeštíhlovat-I
                 zelenat-I zemřít-P zepsout-P zeptat-P zesílit-P zesilovat-I zeslabit-P zeslabovat-I
                 zesměšňovat-I zesměšnit-P zestárnout-P zestátňovat-I zestátnit-P zestručnit-P
                 zet-I zevšeobecňovat-I zezelenat-P zfalšovat-P zfilmovat-P zformovat-P zformulovat-P
                 zhýčkat-P zhanobit-P zhasínat-I zhasnout-P zhlížet-P zhlédnout-P zhlavovat-P
                 zhřešit-P zhmotňovat-I zhmotnit-P zhodnocovat-I zhodnotit-P zhojit-P zhořknout-P
                 zhoršit-P zhoršovat-I zhospodárnit-P zhostit-P zhotovit-P zhoustnout-P zhroutit-P
                 zhrudkovatět-P zhubnout-P zhušťovat-I zhumanizovat-P zhysterizovat-P zchladit-P
                 zchladnout-P zideologizovat-P zimovat-I zinscenovat-P zintenzívnit-P zjasňovat-I
                 zjednávat-I zjednat-P zjednodušit-P zjednodušovat-I zjevit-P zjevovat-I
                 zjišťovat-I zjistit-P zjizvit-P zkalkulovat-P zkazit-P zklamat-P zklidňovat-I
                 zklidnit-P zkřivit-P zkolabovat-P zkolaudovat-P zkombinovat-P zkompletovat-P
                 zkomplikovat-P zkomponovat-P zkoncentrovat-P zkonfiskovat-P zkonsolidovat-P
                 zkonstruovat-P zkontrolovat-P zkonzumovat-P zkoordinovat-P zkopat-P zkorumpovat-P
                 zkoušet-I zkoumat-I zkrášlit-P zkrátit-P zkracovat-I zkrachovat-P zkreslit-P
                 zkreslovat-I zkrotit-P zkultivovat-P zkusit-P zkvašovat-I zkvalitňovat-I
                 zkvalitnit-P zlákat-P zlíbit-P zříci-P zřídit-P zříkat-I zlanařit-P zřít-I
                 zřítit-P zředit-P zlehčovat-I zřeknout-P zlepšit-P zlepšovat-I zlevňovat-I
                 zlevnit-P zlikvidovat-P zřizovat-I zlobívat-I zlobit-I zlořečit-I zlomit-P
                 zůstávat-I zůstat-P zželet-P zmáčknout-P zmást-P zmýdelňovat-I změkčet-P
                 změkčit-P změkčovat-I zmalátnit-P zmalířštět-P zmařit-P zmýlit-P změřit-P
                 zmalomyslnět-P zmanipulovat-P zmínit-P změnit-P zmapovat-P zmírat-I zmírňovat-I
                 zmírnět-P zmarnit-P zmírnit-P zmasakrovat-P zmítat-I zmehnout-P zmenšit-P
                 zmenšovat-I zmiňovat-I zmizet-P zmlátit-P zmnohonásobit-P zmnožit-P zmnožovat-I
                 zmobilizovat-P zmoci-I zmocňovat-I zmocnět-P zmocnit-P zmodernizovat-P zmrazit-P
                 zmrazovat-I zmrzačit-P zmrznout-P značívat-I značit-I značkovat-I známkovat-I
                 znárodňovat-I znárodnit-P znásilňovat-I znásilnit-P znásobit-P znát-I znávat-I
                 znázorňovat-I znázornit-P zněkolikanásobit-P znamenat-I znít-I znečišťovat-I
                 znečistit-P znehodnocovat-I znehodnotit-P znechucovat-I znechutit-P znejistět-P
                 znejistit-P zneklidňovat-I zneklidnět-P zneklidnit-P znelíbit-P zneškodňovat-I
                 zneškodnit-P znemožňovat-I znemožnit-P znepřátelit-P znepříjemňovat-I znepříjemnit-P
                 znepokojit-P znepokojovat-I znervózňovat-I znervóznit-P znesnadňovat-I znesvěcovat-I
                 znetvořit-P zneuctít-P zneužít-P zneužívat-I znevážit-P znevýhodňovat-I
                 znevýhodnit-P znevažovat-I zničit-P zničovat-I znivelizovat-P znormalizovat-P
                 znovuobjevit-P znovuobjevovat-I znovuožívat-I znovuotevřít-P zobecňovat-I
                 zobecnit-P zobchodovat-P zobrazit-P zobrazovat-I zocelovat-I zodpovídat-I
                 zodpovědět-P zohavit-P zohledňovat-I zohlednit-P zopakovat-P zorganizovat-P
                 zorientovat-P zosobňovat-I zostřit-P zostřovat-P zotavit-P zotavovat-I zotvírat-P
                 zoufat-B zout-I zpěčovat-I zpanikařit-P zpívávat-I zpívat-I zpečetit-P zpeněžit-P
                 zpestřit-P zpestřovat-I zpevňovat-I zpevnit-P zpříjemnit-P zpřísňovat-I
                 zpřísnět-P zpřísnit-P zpřístupňovat-I zpřístupnět-P zpřístupnit-P zpřítomňovat-I
                 zpřehlednit-P zpřesňovat-I zpřesnit-P zpřetrhat-P zplnomocňovat-I zplnomocnit-P
                 zplodit-P zploštit-P způsobit-P způsobovat-I zpodobnit-P zpohodlnět-P zpohodlnit-P
                 zpochybňovat-I zpochybnit-P zpolitizovat-P zpožďovat-I zpomalit-P zpomalovat-I
                 zpovídat-I zpozdit-P zpozorovat-P zpracovávat-I zpracovat-P zpravit-P zprivatizovat-P
                 zprůhlednit-P zprůměrovat-P zprůzračnit-P zprofanovat-P zprošťovat-I zpronevěřit-P
                 zprostit-P zprostředkovávat-I zprostředkovat-P zprovoznit-P zpuchřet-P zpustnout-P
                 zpustošit-P zpytovat-I zračit-I zrát-I zracionalizovat-P zradit-P zraňovat-I
                 zranit-P zrazovat-I zrcadlit-I zrealizovat-P zredukovat-P zrekapitulovat-P
                 zrekonstruovat-P zrentgenovat-P zreprodukovat-P zrestaurovat-P zrevidovat-P
                 zrezivět-I zrůžovět-P zrodit-P zruinovat-P zrušit-P zrušovat-I zrychlit-P
                 zrychlovat-I ztělesňovat-I ztělesnit-P ztížit-P ztěžknout-P ztěžovat-I ztenčit-P
                 ztenčovat-I ztichnout-P ztišit-P ztišovat-I ztlouci-P ztlumit-P ztotožňovat-I
                 ztotožnit-P ztrácet-I ztrapnit-P ztratit-P ztrestat-P ztrojnásobit-P ztroskotávat-I
                 ztroskotat-P ztrpčovat-I ztuhnout-P ztvárnit-P ztvrdit-P zuřit-I zužitkovat-P
                 zužovat-I zurčet-I zvážit-P zvěčnit-P zvát-I zvědět-P zvadnout-P zvýhodňovat-I
                 zvýhodnit-P zvýšit-P zvalchovat-P zvažovat-I zvýraznět-P zvýraznit-P zvěstovat-I
                 zvítězit-P zvětšit-P zvětšovat-I zvedat-I zvednout-P zvelebit-P zvelebovat-I
                 zveřejňovat-I zveřejnět-P zveřejnit-P zveličovat-I zviditelňovat-I zviditelnit-P
                 zvládat-I zvládnout-P zvolat-P zvolit-P zvolňovat-I zvonit-I zvrátit-P zvracet-I
                 zvrhnout-P zvučet-I zvykat-I zvyknout-P zvyšovat-I);



foreach my $item (@vidy) {
    my ($mlemma,$vid) = split "-",$item;
    $verbal_aspect{$mlemma} = $vid;
}



# ------- klasifikace prislovci

my @pronomadv = qw (
                       dokdy dokud jak jakkoliv jaksi jakž kam kamkoliv kampak kamsi kde kdekoliv
                       kdepak kdesi kdeže kdy kdykoli kdysi kudy leckde leckdy málokde málokdy
                       navždy nějak někam někde někdy nijak nikam nikde nikdy odevšad odkdy odkud
                       odněkud odnikud odsud onak onde onehdá pak poté potom potud proč proto sem
                       tady taktéž takž tam tamhle tamtéž teď tudy tuhle tytam všudy vždy zde
               );
foreach my $adverb (@pronomadv) {
    $pronomadv{$adverb} = 1
}


my @nongradadv = qw (
                        akorát alespoň ani ani_tak asi aspoň až bezděčně bezesporu bezmála bezpochyby
                        beztak bohudík bohužel bůhvíkdy celkem celkem_vzato cik_cak časem čas_od_času
                        dejme_tomu díkybohu dnes docela dodnes doholaido_hola dohromady dojetím
                        dokola dokonce dokořán doleva dom doma domů donedávna donekonečna doopravdy
                        dopodrobna dopoledne doprava doprostřed dopředu dost dosud dosyta doširoka
                        doteď doufám doufejme do_úmoru dovnitř dozadu dozajista druhdy dvaapůlkrát
                        dvakrát furt hned horempádem chtě_nechtě chtíc_nechtíc chválabohu chvílemi
                        i ihned jakkoliv jaksepatří jakž jednou jednou_provždy jen_co_je_pravda
                        jenom ještě ještě_více jinak jinam jinde jindy jinudy již kampak kamsi každopádně
                        kdekoliv kdepak kdesi kdeže kdovíjak kleče kolem kolem_dokola koneckonců
                        křížem_krážem kupodivu kupředu kupříkladu kvapem ladem leckde leckdy letos
                        leže líto loni málem mezitím mimo mimoděk mimochodem mimoto místy mlčky
                        mnohde mnohem mnohokrát myslím nabíledni naboso načas načase načerno nadále
                        nadarmo nadlouhoina_dlouho nadobro nadto nadvakrát nahlas náhodou nahoru
                        nahoře najednou najevo najisto nakolik nakonec nakrátkoina_krátko nakřivo
                        nalevo námahou namále namátkou naměkko namístě nanejvýš naneštěstí nanovo
                        naoko naopak naostro napevno napilno naplno napodruhé napolo napoprvé naposled
                        napospas napotřetí napovrch napravo naprázdno naprosto naproti napřed napřesrok
                        například napříště naráz naruby narychlo naschvál nasnadě nastojato naštěstí
                        nato natolik natruc natrvalo natřikrát natvrdo navečer navěkyina_věky navenek
                        navíc navrch navýsost navzájem navzdory nazítří nazmar nazpátek naživu ne
                        nedbaje nedej_Bůh nehledě nechtě nejdříve nejen nejpozději nejprve nejspíš
                        nejvýše několikrát nemluvě nepočítaje nepříliš neřku nevědomky nevyjímaje
                        nicméně nikdá nikoliv nikterak nóbl nyní občas obzvlášť odedávna odevšad
                        odhadem odjakživa odjinud odnikud od_oka odpoledne omylem onak onde onehdá
                        opět opodál opravdu ostatně ovšem ovšemže pěšky poblíž počítaje podomácku
                        podruhé pohromadě pohříchu pojednou pokaždé ponejprv ponejvíce poněkolikáté
                        poněkud popořádkuipo_pořádku popravdě popřípadě pořád posavad poskrovnu
                        poslechněte posléze potají potažmo potmě potud pouze povýtce pozadu pozítří
                        poznenáhlu pozpátku pozvolna pranic právě právem právě_tak proboha promiňte
                        propříště prosím protentokrát provždy prozatím prý pryč přece přece_jen
                        předem předevčírem především předloni předtím přesčas přespříliš přesto
                        příliš přinejhorším přinejmenším přitom rádoby ráno respektive rovněž rovnou
                        rušno sebelépe sem_tam seshora shůry sice skoro snad sotva soudě stěží strachem
                        stranou středem střemhlav široce šmahem štěstím tak také tak_jako_tak tak_říkaje
                        takřka taktéž takto takž tamhle tamtéž tedy tehdy téměř tenkrát tentokrát
                        teprve též tím_méně tím_spíše tolik toliko totiž trochu třeba tudíž tuhle
                        tuším tytam uprostřed už vabank vcelku včas včera včetně večer vedle ven
                        venku věřím věřte veskrze vesměs většinou vhod víceméně víte vlastně vlevo
                        vloni vniveč v_podstatě vpodvečer vpravdě vpravo vpřed vpředu vsedě vskutku
                        vstávaje_lehaje vstoje všanc všehovšudy všude všudy vůbec vycházeje vyjímaje
                        vzadu vzápětí v_zásadě vzhůru vždyť zadarmo zadem zadobře zadost zahrnuje
                        záhy zajedno zajisté zakrátko zamladaiza_mlada zanedlouho zaplať_Pánbůh
                        zapotřebí zaprvé zároveň zase zatím zavděk závěrem zázrakem zaživa zblízka
                        zbrusu zcela zčásti zčistajasna zdaleka zdola zejména zevnitř zezadu zhola
                        zhruba zhusta zítra zjara zkrátka zkusmo zlehka zleva znenadání zničehonic
                        znovu zostra zpaměti zpátky zpočátkuiz_počátku zpravidla zprvu zrovna zřídka
                        ztěžka zticha zuby_nehty zvenčí zvenku zvlášť zvnějšku zvolna
                );
foreach my $adverb (@nongradadv) {
    $nongradadv{$adverb} = 1
}



my @notnegableadv = qw (
                           abecedně abnormálně akorát alegoricky alespoň alikvótně analogicky ani ani_tak
                           antikomunisticky aprioristicky archetypálně asi asketicky aspoň astmaticky
                           až báječně bedlivě bezcelně bezděčně bezdrátově bezdůvodně bezesporu bezhlavě
                           bezhlesně bezchybně bezkonkurenčně bezmála bezmezně bezmocně bezmyšlenkovitě
                           beznadějně bezpečnostně bezplatně bezpodmínečně bezpochyby bezproblémově
                           bezprostředně bezradně beztak beztrestně bezúplatně bezúročně bezúspěšně
                           bezvládně bezvýhradně bezvýsledně bídně bigbítově biograficky bizarně blahobytně
                           bláznivě blbě bledě bleskově bohudík bohužel bombasticky bouřlivě branně
                           bravurně brilantně briskně brzy bůhvíkdy bystře bytostně celkem celkem_vzato
                           celkově celoročně celostátně celosvětově cik_cak církevně citově cynicky
                           časem časně časopisecky částečně čecháčkovsky čerstvě červenobíle čiperně
                           číslicově čtenářsky čtvrtletně čtyřnásobně dál dálkově dekadentně denně
                           dennodenně desetinásobně detailně diametrálně díkybohu disciplinárně dlouhodobě
                           dnes dobromyslně docela dodatečně dodnes doholaido_hola dohromady dojemně
                           dokdy dokola dokonce dokořán doktrinárně dokud dole doleva dolů dom domněle
                           domů donedávna donekonečna doopravdy dopodrobna dopoledne doprava doprostřed
                           dopředu doslova doslovně dosud dosyta doširoka doteď dovnitř dozadu dozajista
                           doživotně dramaturgicky drasticky druhdy druhotně dříve duševně dutě dvaapůlkrát
                           dvakrát dvojjazyčně dvojnásob dvořákovsky dvoukolově dychtivě dylanovsky
                           ebenově enormně evidentně excelentně excentricky existenčně exponenciálně
                           externě fakticky faktograficky familiérně famózně fixně flagrantně folklorně
                           foneticky formulačně frontálně furt fyzikálně geometricky gólově goticky
                           hazardérsky herně hladce hladově hlasově hned hněvivě hodně horce horempádem
                           horlivě hořce houževnatě hravě hromadně hrozivě hrozně hutně hypoteticky
                           chladně chladno chlapecky chrabře chronologicky chtě_nechtě chtíc_nechtíc
                           chválabohu chvílemi chybně i ihned ikonologicky ilegálně informačně instinktivně
                           intelektově interně ironicky jak jakkoliv jaksepatří jaksi jakž jedině jednohlasně
                           jednomyslně jednorázově jednostranně jednostrunně jemně jen_co_je_pravda
                           ještě ještě_více jihovýchodně jihozápadně jinam jindy jinudy již jižně jmenovitě
                           kacířsky kam kamkoliv kampak kamsi kapacitně kapitálově kategoricky každopádně
                           každoročně kde kdekoliv kdepak kdesi kdeže kdovíjak kdy kdykoli kdysi kladně
                           klamavě klaunsky kleče klimaticky kolem kolmo komorně kompetenčně kompozičně
                           koneckonců konstrukčně kontraktačně kontumačně krajně krásně krátce kratičce
                           krátkodobě krutě křížem_krážem kudy kulantně kupodivu kuponově kupředu kupříkladu
                           kuriózně kvapem kvapně kyvadlově laboratorně ladem laicky lajdácky lakonicky
                           lapidárně leckde leckdy ledově legračně lehkomyslně lehounce letmo letos
                           lexikálně leže libovolně liknavě líně líto loni málem maličko málokde málokdy
                           markantně marketingově marně masajsky měkce mělce mentálně meritorně měsíčně
                           metodologicky meziměsíčně meziročně mezitím mimo mimoděk mimochodem mimořádně
                           mimoto minimálně minule mistrně místy mizerně mlčenlivě mlčky mlhavě mnohde
                           mnohdy mnohem mnohokrát mnohomluvně mnohonásobně mnohovrstevně moc mocensky
                           mocně modře mohutně momentálně monetálně monotematicky moralisticky morfologicky
                           myšlenkově nabíledni naboso nacionálně načas načase načerno nadále nadarmo
                           nádherně nadlouhoina_dlouho nadměrně nadneseně nadobro nadprůměrně nadstandardně
                           nadto nadvakrát nahlas náhodou nahoru nahoře najednou najevo najisto nakolik
                           nakonec nakrátkoina_krátko nakřivo naléhavě nalevo námahou namále namátkou
                           naměkko namístě nanejvýš naneštěstí nanovo naoko naopak naostro napevno
                           napilno naplno napodruhé napolo napoprvé naposled napospas napotřetí napovrch
                           napravo naprázdno naprosto naproti napřed napřesrok například napříště naráz
                           narkoticky národnostně naruby narychlo naschvál následně následovně nasnadě
                           nastojato naštěstí nato natolik natruc natrvalo natřikrát natvrdo navečer
                           navěkyina_věky navenek navíc navrch navýsost navzájem navzdory navždy nazítří
                           nazmar názorově nazpátek naživu ne nečekaně nedávno nedbaje nedbale negativně
                           nehledě nehorázně nechtě nějak nejdříve někam někde někdy několikanásobně
                           několikrát neměně nemluvě nenadále nenávratně neodbytně neoddiskutovatelně
                           neodkladně neodlučně nepatrně nepočítaje nepochybně neprodleně nepřeberně
                           nerozlučně nervózně nesčetně neskonale nesmírně nesmyslně nestranně neúnavně
                           neustále neutrálně nevyjímaje nezvykle nicméně nijak nikam nikdá nikde nikdy
                           nikoliv nikterak nízko nóbl noblesně nostalgicky notářsky notně notoricky
                           nouzově nudně nyní občas obdivně obdivuhodně obdobně obecně objevně oblačno
                           obludně oboustranně obráceně obranně obrazově obrovsky obsahově obzvlášť
                           očividně odedávna odevšad odhadem odjakživa odjinud odkdy odkud odlišně
                           odloučeně odmítavě odněkud odnikud od_oka odpoledne odsud odtažitě ohnivě
                           ohromně ochotnicky ojediněle okamžitě okatě okrajově okupačně omylem onak
                           onde onehdá opačně opět opětovně opodál opožděně opravdu oranžově osminásobně
                           ostatně osudově ošklivě otrocky ovšem ovšemže pádně pak palčivě parádně
                           paradoxně paralelně pasivně patentově permanentně perně personálně pesimisticky
                           pěšky pěvecky pikantně pirátsky planě planetárně plasticky plebejsky pobaveně
                           poblíž podivně podloudně podomácku podrobně podruhé podvědomě pofidérně
                           pohrdavě pohrdlivě pohromadě pohříchu pojednou pokaždé pokoutně polohově
                           polojasno polopaticky polystylově pomalu ponejprv ponejvíce poněkolikáté
                           poněkud popořádkuipo_pořádku popravdě popřípadě pořád posavad poskrovnu
                           posléze posluchačsky posměšně posmrtně postupně posupně pošetile potají
                           potažmo poté potenciálně potichu potmě potom poťouchle potud pouze povahově
                           povážlivě povrchově povýtce pozadu pozdě pozitivně pozítří poznenáhlu pozpátku
                           pozvolna pracně pranic právě právě_tak pregnantně preventivně proboha procentuálně
                           proč profesorsky prohibitně projektově promptně propříště prostě prostředně
                           protentokrát protestantsky protestně protibakteriálně protiinflačně protikladně
                           protikomunisticky protinacisticky protiněmecky protiprávně protiústavně
                           protiválečně protizákonně proto provinile provizorně provokativně provždy
                           prozatím prý pryč přece přece_jen předběžně předčasně předem předevčírem
                           především předloni předně přednostně předtím přemrštěně přesčas přespříliš
                           přesto převážně převelice přibližně příjmově příležitostně přinejhorším
                           přinejmenším přísně příště přitom psychicky rádoby raně ráno rapidně razantně
                           rázně redakčně rekordně rekreačně relativně resortně respektive restriktivně
                           rezolutně riskantně ročně rovněž rovnou rozechvěle rozhořčeně rozkošně rozšafně
                           roztomile rozverně rozvroucněně ručně rušno různě rychle řádově řečnicky
                           řemeslně řetězovitě samočinně samoúčelně samozvaně sarkasticky satiricky
                           sebelépe sebevražedně sedminásobně sem sem_tam seshora setrvačně severně
                           severozápadně shrnutě shůry schválně sice silně skandovaně skepticky skoro
                           skvěle skvostně slabě slepě sluchově snad sólově sotva souborně soudě souhrnně
                           spíše sponzorsky sporadicky spoře staročesky stěží stonásobně stoprocentně
                           strachem stranou strašlivě strašně striktně strojně stručně středem středně
                           střelecky střemhlav střídavě stupňovitě surově suše svahilsky svérázně sveřepě
                           světle svévolně svisle svižně svobodomyslně syrově šalamounsky šedě šikmo
                           škaredě šmahem šokovaně špičkově štěstím tabulkově tady tak také tak_jako_tak
                           tak_říkaje takřka taktéž takto takzvaně takž tam tamhle tamtéž taxativně
                           teď tedy teenagersky tehdy telefonicky televizně téměř temně tenkrát tentokrát
                           tepelně teprve též tím_méně tím_spíše tolik toliko totálně totiž transdisciplinárně
                           trapně tréninkově trestuhodně triumfálně trochu trojnásobně trpce trpně
                           trvale třeba tudíž tudy tuhle tvrdě tvrdošíjně tytam údajně uhrančivě úhrnně
                           úlevně úlisně umně univerzálně uprostřed upřeně urbionalisticky urychleně
                           úsečně usilovně ustavičně ústně uvnitř úzce územně územněsprávně úzkostlivě
                           úzkostně už vančurovsky varovně vcelku včas včera večer věčně vedle vehementně
                           věkově velmi ven venku vertikálně veřejnoprávně veskrze vesměs většinou
                           více víceméně víceúčelově virtuózně vítězně vlastně vlastnoručně vlažně
                           vlevo vloni vnějškově vnitropoliticky vnitřně vniveč vodivě vodorovně vokálně
                           v_podstatě vpodvečer vpravdě vpravo vpřed vpředu vratce vrcholně vrcholově
                           vřele vsedě vskutku vstoje všanc všehovšudy všelijak všestranně všude všudy
                           vůbec vulgárně výborně výdajově výhledově vycházeje vypjatě výrazově výsledně
                           výtečně vytrženě vzadu vzájemně vzápětí v_zásadě vzdáleně vzhledově vzhůru
                           vzorně vždy vždyť zadarmo zadem zadobře zadost zahraničně záhy zajedno zajisté
                           zakrátko zakřiknutě zálibně zálohově zamladaiza_mlada zamračeně zanedlouho
                           západně zaplať_Pánbůh zapotřebí zaprvé zároveň zarytě zásadně zase zatím
                           zatraceně zavděk závěrem závratně zázračně zázrakem zaživa zběsile zblízka
                           zbrkle zbrusu zbytečně zcela zčásti zčistajasna zdaleka zdánlivě zde zděšeně
                           zdlouhavě zdola zejména zelenobíle zevnitř zevrubně zezadu zhola zhruba
                           zhusta zítra zjara zkoumavě zkrátka zkusmo zlatavě zlehka zleva zlobně zlomyslně
                           zlověstně značně znamenitě znechuceně znenadání zničehonic znovu zostra
                           zoufale zpaměti zpátky zpětně zpočátkuiz_počátku zpravidla zpropadeně zprvu
                           zpupně zrakově zrcadlově zrovna zřejmě ztepile ztěžka zticha zvenčí zvenku
                           zvlášť zvláštně zvnějšku zvolna zvukově žalostně žánrově žíznivě
                   );
foreach my $adverb (@notnegableadv) {
    $notnegableadv{$adverb} = 1
}



# ???? tohle je velmi tupe, pole by se melo omezit jen na ty, ktere nejdou odvodit pravidelne (tezce-tezky)
my @adv2adj = qw (
                     abecedně-abecední abnormálně-abnormální absolutně-absolutní abstraktně-abstraktní
                     absurdně-absurdní adekvátně-adekvátní adresně-adresný agresivně-agresivní
                     akademicky-akademický aktivně-aktivní alegoricky-alegorický alibisticky-alibistický
                     alikvótně-alikvótní amatérsky-amatérský americky-americký analogicky-analogický
                     andělsky-andělský anglicky-anglický anonymně-anonymní antikomunisticky-antikomunistický
                     antisemitsky-antisemitský aprioristicky-aprioristický apriorně-apriorní
                     archetypálně-archetypální asketicky-asketický astmaticky-astmatický autenticky-autentický
                     automaticky-automatický autoritativně-autoritativní báječně-báječný banálně-banální
                     barevně-barevný barvitě-barvitý bedlivě-bedlivý bezcelně-bezcelní bezdrátově-bezdrátový
                     bezdůvodně-bezdůvodný bezhlavě-bezhlavý bezhlesně-bezhlesný bezchybně-bezchybný
                     bezkonkurenčně-bezkonkurenční bezmezně-bezmezný bezmocně-bezmocný bezmyšlenkovitě-bezmyšlenkovitý
                     beznadějně-beznadějný bezpečně-bezpečný bezpečnostně-bezpečnostní bezplatně-bezplatný
                     bezpodmínečně-bezpodmínečný bezproblémově-bezproblémový bezprostředně-bezprostřední
                     bezradně-bezradný beztrestně-beztrestný bezúplatně-bezúplatný bezúročně-bezúročný
                     bezúspěšně-bezúspěšný bezvládně-bezvládný bezvýhradně-bezvýhradný bezvýsledně-bezvýsledný
                     běžně-běžný bídně-bídný bigbítově-bigbítový bíle-bílý biograficky-biografický
                     biologicky-biologický bizarně-bizarní blahobytně-blahobytný bláznivě-bláznivý
                     blbě-blbý bledě-bledý bleskově-bleskový bohatě-bohatý bolestivě-bolestivý
                     bombasticky-bombastický bouřlivě-bouřlivý branně-branný bravurně-bravurní
                     brilantně-brilantní briskně-briskní brutálně-brutální bystře-bystrý bytostně-bytostný
                     bývale-bývalý cele-celý celkově-celkový celoročně-celoroční celostátně-celostátní
                     celosvětově-celosvětový cenově-cenový centrálně-centrální cílevědomě-cílevědomý
                     církevně-církevní citelně-citelný citlivě-citlivý citově-citový civilně-civilní
                     cudně-cudný cynicky-cynický časně-časný časopisecky-časopisecký časově-časový
                     částečně-částečný čecháčkovsky-čecháčkovský čerstvě-čerstvý červenobíle-červenobílý
                     česky-český čestně-čestný čiperně-čiperný číslicově-číslicový čistě-čistý
                     čítankově-čítankový čitelně-čitelný čtenářsky-čtenářský čtvrtletně-čtvrtletní
                     čtyřnásobně-čtyřnásobný dalece-daleký dálkově-dálkový daňově-daňový definitivně-definitivní
                     dekadentně-dekadentní delikátně-delikátní demagogicky-demagogický demokraticky-demokratický
                     denně-denní dennodenně-dennodenní desetinásobně-desetinásobný destruktivně-destruktivní
                     detailně-detailní dětsky-dětský diametrálně-diametrální diferencovaně-diferencovaný
                     digitálně-digitální diplomaticky-diplomatický disciplinárně-disciplinární
                     disciplinovaně-disciplinovaný diskrétně-diskrétní diskriminačně-diskriminační
                     diskursivně-diskursivní divácky-divácký divadelně-divadelní divoce-divoký
                     dlouho-dlouhý dlouhodobě-dlouhodobý dlouze-dlouhý dobromyslně-dobromyslný
                     dobrovolně-dobrovolný dobře-dobrý dočasně-dočasný dodatečně-dodatečný dojemně-dojemný
                     dokonale-dokonalý doktrinárně-doktrinární domněle-domnělý doslovně-doslovný
                     dostatečně-dostatečný dotčeně-dotčený dovedně-dovedný doživotně-doživotní
                     draho-drahý dramaticky-dramatický dramaturgicky-dramaturgický drasticky-drastický
                     draze-drahý dráždivě-dráždivý drogově-drogový drsně-drsný druhotně-druhotný
                     duchovně-duchovní důkladně-důkladný důležitě-důležitý důmyslně-důmyslný
                     důrazně-důrazný důsledně-důsledný důstojně-důstojný duševně-duševní dutě-dutý
                     důvěrně-důvěrný důvodně-důvodný dvojjazyčně-dvojjazyčný dvojnásob-dvojnásobný
                     dvojnásobně-dvojnásobný dvořákovsky-dvořákovský dvoukolově-dvoukolový dychtivě-dychtivý
                     dylanovsky-dylanovský dynamicky-dynamický ebenově-ebenový efektivně-efektivní
                     efektně-efektní ekologicky-ekologický ekonomicky-ekonomický elegantně-elegantní
                     elektricky-elektrický elitářsky-elitářský emocionálně-emocionální energeticky-energetický
                     energicky-energický enormně-enormní eroticky-erotický erudovaně-erudovaný
                     esteticky-estetický eticky-etický etnicky-etnický eventuálně-eventuální
                     evidentně-evidentní evropsky-evropský excelentně-excelentní excentricky-excentrický
                     existenčně-existenční exkluzivně-exkluzivní exoticky-exotický experimentálně-experimentální
                     exponenciálně-exponenciální exportně-exportní externě-externí extrémně-extrémní
                     fakticky-faktický faktograficky-faktografický falešně-falešný familiérně-familiérní
                     famózně-famózní fantasticky-fantastický fašisticky-fašistický fatálně-fatální
                     feministicky-feministický fér-férový férově-férový filozoficky-filozofický
                     finančně-finanční fixně-fixní flagrantně-flagrantní flegmaticky-flegmatický
                     folklorně-folklórní foneticky-fonetický formálně-formální formulačně-formulační
                     francouzsky-francouzský frontálně-frontální funkčně-funkční fyzicky-fyzický
                     fyzikálně-fyzikální galantně-galantní generačně-generační geometricky-geometrický
                     globálně-globální gólově-gólový goticky-gotický graficky-grafický gramaticky-gramatický
                     halasně-halasný hazardérsky-hazardérský herecky-herecký herně-herní hezky-hezký
                     historicky-historický hladce-hladký hladově-hladový hlasitě-hlasitý hlasově-hlasový
                     hlavně-hlavní hluboce-hluboký hluboko-hluboký hlučně-hlučný hmotně-hmotný
                     hněvivě-hněvivý hodnotově-hodnotový hojně-hojný horce-horký horečně-horečný
                     horlivě-horlivý hořce-hořký hospodárně-hospodárný hospodářsky-hospodářský
                     hotově-hotový houfně-houfný houževnatě-houževnatý hravě-hravý hrdě-hrdý
                     hromadně-hromadný hrozivě-hrozivý hrozně-hrozný hrubě-hrubý hudebně-hudební
                     humorně-humorný hutně-hutný hygienicky-hygienický hypoteticky-hypotetický
                     chaoticky-chaotický chladně-chladný chladno-chladný chlapecky-chlapecký
                     chrabře-chrabrý chronologicky-chronologický chtěně-chtěný chvalně-chvalný
                     chybně-chybný chytře-chytrý ideálně-ideální ideologicky-ideologický ideově-ideový
                     ikonologicky-ikonologický ilegálně-ilegální individuálně-individuální informačně-informační
                     informativně-informativní informovaně-informovaný instinktivně-instinktivní
                     intelektově-intelektový intelektuálně-intelektuální intenzivně-intenzívní
                     intenzívně-intenzívní interně-interní intimně-intimní invenčně-invenční
                     investičně-investiční ironicky-ironický janáčkovsky-janáčkovský jasně-jasný
                     jasno-jasný jazykově-jazykový jedině-jediný jednoduše-jednoduchý jednohlasně-jednohlasný
                     jednolitě-jednolitý jednomyslně-jednomyslný jednorázově-jednorázový jednostranně-jednostranný
                     jednostrunně-jednostrunný jednotlivě-jednotlivý jednotně-jednotný jednoznačně-jednoznačný
                     jemně-jemný jihovýchodně-jihovýchodní jihozápadně-jihozápadní jistě-jistý
                     jižně-jižní jmenovitě-jmenovitý kacířsky-kacířský kapacitně-kapacitní kapitálově-kapitálový
                     kategoricky-kategorický každodenně-každodenní každoročně-každoroční kladně-kladný
                     klamavě-klamavý klasicky-klasický klaunsky-klaunský klidně-klidný klimaticky-klimatický
                     kmenově-kmenový knižně-knižní kolektivně-kolektivní kolmo-kolmý komediálně-komediální
                     komerčně-komerční komicky-komický komorně-komorní kompaktně-kompaktní kompetenčně-kompetenční
                     kompetentně-kompetentní kompletně-kompletní komplexně-komplexní kompozičně-kompoziční
                     koncepčně-koncepční konečně-konečný konfrontačně-konfrontační konkrétně-konkrétní
                     konstantně-konstantní konstrukčně-konstrukční kontraktačně-kontraktační
                     kontrastně-kontrastní kontrolovaně-kontrolovaný kontumačně-kontumační korektně-korektní
                     kovově-kovový kradmo-kradmý krajně-krajní krásně-krásný krátce-krátký kratičce-kratičký
                     krátko-krátký krátkodobě-krátkodobý kriticky-kritický krutě-krutý krvavě-krvavý
                     křečovitě-křečovitý křesťansky-křesťanský kulantně-kulantní kultivovaně-kultivovaný
                     kulturně-kulturní kuponově-kuponový kuriózně-kuriózní kvalifikovaně-kvalifikovaný
                     kvalitativně-kvalitativní kvalitně-kvalitní kvantitativně-kvantitativní
                     kvapně-kvapný kyvadlově-kyvadlový laboratorně-laboratorní lacině-laciný
                     lacino-laciný laicky-laický lajdácky-lajdácký lakonicky-lakonický lapidárně-lapidární
                     laskavě-laskavý ledově-ledový legálně-legální legislativně-legislativní
                     legitimně-legitimní legračně-legrační lehce-lehký lehko-lehký lehkomyslně-lehkomyslný
                     lehounce-lehounký letecky-letecký levicově-levicový levně-levný lexikálně-lexikální
                     libě-libý liberálně-liberální libovolně-libovolný lidově-lidový liknavě-liknavý
                     líně-líný logicky-logický maďarsky-maďarský maličko-maličký málo-malý manuálně-manuální
                     markantně-markantní marketingově-marketingový marně-marný masajsky-masajský
                     masivně-masivní masově-masový materiálně-materiální maximálně-maximální
                     mechanicky-mechanický měkce-měkký mělce-mělký melodicky-melodický mentálně-mentální
                     meritorně-meritorní měsíčně-měsíční metodicky-metodický metodologicky-metodologický
                     meziměsíčně-meziměsíční mezinárodně-mezinárodní meziročně-meziroční mile-milý
                     militantně-militantní milosrdně-milosrdný mimořádně-mimořádný minimálně-minimální
                     minule-minulý mírně-mírný místně-místní mistrně-mistrný mistrovsky-mistrovský
                     mizerně-mizerný mlčenlivě-mlčenlivý mlhavě-mlhavý mnohomluvně-mnohomluvný
                     mnohonásobně-mnohonásobný mnohovrstevně-mnohovrstevný mocensky-mocenský
                     mocně-mocný moderně-moderní módně-módní modře-modrý mohutně-mohutný momentálně-momentální
                     monetálně-monetální monolitně-monolitní monotematicky-monotematický moralisticky-moralistický
                     morálně-morální morfologicky-morfologický moudře-moudrý možná-možný mravně-mravní
                     mylně-mylný myšlenkově-myšlenkový nábožensky-náboženský nacionalisticky-nacionalistický
                     nacionálně-nacionální nadějně-nadějný nádherně-nádherný nadměrně-nadměrný
                     nadmíru-nadměrný nadneseně-nadnesený nadprůměrně-nadprůměrný nadstandardně-nadstandardní
                     nadšeně-nadšený náhle-náhlý nahodile-nahodilý náhodně-náhodný naivně-naivní
                     naléhavě-naléhavý náležitě-náležitý nápaditě-nápaditý nápadně-nápadný narativně-narativní
                     narkoticky-narkotický národně-národní národnostně-národnostní násilně-násilný
                     následně-následný následovně-následovný názorně-názorný názorově-názorový
                     nečekaně-nečekaný nečinně-nečinný nedávno-nedávný nedbale-nedbalý negativně-negativní
                     nehorázně-nehorázný nechtěně-nechtěný nějak-nějaký několikanásobně-několikanásobný
                     nekompromisně-kompromisní německy-německý neměně-neměnný nenávratně-nenávratný
                     neobyčejně-neobyčejný neočekávaně-neočekávaný neodbytně-neodbytný neoddiskutovatelně-neodiskutovatelný
                     neodkladně-neodkladný neodlučně-neodlučný neodmyslitelně-neodmyslitelný
                     neodolatelně-neodolatelný neodůvodnitelně-neodůvodnitelný neodvratně-neodvratný
                     neohroženě-neohrožený neomylně-neomylný neopakovatelně-neopakovatelný neotřele-neotřelý
                     neovladatelně-neovladatelný nepatrně-nepatrný nepochybně-nepochybný nepokrytě-nepokrytý
                     nepopiratelně-nepopiratelný nepopsatelně-nepopsatelný nepotlačitelně-nepotlačitelný
                     nepozorovaně-nepozorovaný neprodleně-neprodlený nepřeberně-nepřeberný nepřehlédnutelně-nepřehlédnutelný
                     nepřetržitě-nepřetržitý nepřítomně-nepřítomný nerozhodně-nerozhodný nerozlučně-nerozlučný
                     nerušeně-nerušený nervózně-nervózní nesčetně-nesčetný neskonale-neskonalý
                     neskutečně-neskutečný nesmírně-nesmírný nesmyslně-nesmyslný nesouměřitelně-nesouměřitelný
                     nesporně-nesporný nesrovnatelně-nesrovnatelný nestranně-nestranný neúnavně-neúnavný
                     neustále-neustálý neústupně-neústupný neutrálně-neutrální neuvěřitelně-neuvěřitelný
                     nevěřícně-nevěřícný nevinně-nevinný nevyhnutelně-nevyhnutelný nevysvětlitelně-nevysvětlitelný
                     nezadržitelně-nezadržitelný nezaměnitelně-nezaměnitelný nezávisle-nezávislý
                     nezbytně-nezbytný nezvratně-nezvratný nezvykle-nezvyklý něžně-něžný nízko-nízký
                     noblesně-noblesní normálně-normální nostalgicky-nostalgický notářsky-notářský
                     notně-notný notoricky-notorický nouzově-nouzový nově-nový nuceně-nucený
                     nudně-nudný nutně-nutný občansky-občanský obdivně-obdivný obdivuhodně-obdivuhodný
                     obdobně-obdobný obecně-obecný obezřetně-obezřetný obchodně-obchodní objektivně-objektivní
                     objevně-objevný oblačno-oblačný obludně-obludný oborově-oborový oboustranně-oboustranný
                     obráceně-obrácený obranně-obranný obratně-obratný obrazně-obrazný obrazově-obrazový
                     obrovsky-obrovský obsáhle-obsáhlý obsahově-obsahový obtížně-obtížný obvykle-obvyklý
                     obyčejně-obyčejný očividně-očividný odborně-odborný odděleně-oddělený odlišně-odlišný
                     odloučeně-odloučený odmítavě-odmítavý odpovědně-odpovědný odtažitě-odtažitý
                     odůvodněně-odůvodněný odvážně-odvážný oficiálně-oficiální ohleduplně-ohleduplný
                     ohnivě-ohnivý ohromně-ohromný ochotně-ochotný ochotnicky-ochotnický ojediněle-ojedinělý
                     okamžitě-okamžitý okatě-okatý okázale-okázalý okrajově-okrajový okupačně-okupační
                     omezeně-omezený opačně-opačný opakovaně-opakovaný opatrně-opatrný operativně-operativní
                     opětně-opětný opětovně-opětovný opodstatněně-opodstatněný opožděně-opožděný
                     opravdově-opravdový oprávněně-oprávněný optimálně-optimální optimisticky-optimistický
                     oranžově-oranžový organizačně-organizační originálně-originální ortodoxně-ortodoxní
                     osminásobně-osminásobný osobně-osobní ostře-ostrý osudově-osudový ošklivě-ošklivý
                     otevřeně-otevřený otrocky-otrocký oulisně-úlisný ozdobně-ozdobný pádně-pádný
                     palčivě-palčivý památkově-památkový papírově-papírový parádně-parádní paradoxně-paradoxní
                     paralelně-paralelní pasivně-pasivní patentově-patentový pateticky-patetický
                     patrně-patrný patřičně-patřičný paušálně-paušální pečlivě-pečlivý pejorativně-pejorativní
                     pěkně-pěkný perfektně-perfektní periodicky-periodický permanentně-permanentní
                     perně-perný personálně-personální perspektivně-perspektivní pesimisticky-pesimistický
                     pestře-pestrý pěvecky-pěvecký pevně-pevný pietně-pietní pikantně-pikantní
                     pilně-pilný pirátsky-pirátský písemně-písemný planě-planý planetárně-planetární
                     plasticky-plastický platově-platový plebejsky-plebejský plně-plný plno-plný
                     plnohodnotně-plnohodnotný plošně-plošný plynule-plynulý pobaveně-pobavený
                     poctivě-poctivý počítačově-počítačový podbízivě-podbízivý podezřele-podezřelý
                     podivně-podivný podloudně-podloudný podloženě-podložený podmínečně-podmínečný
                     podmíněně-podmíněný podobně-podobný podrobně-podrobný podstatně-podstatný
                     podvědomě-podvědomý pofidérně-pofidérní pohádkově-pohádkový pohlavně-pohlavní
                     pohodlně-pohodlný pohotově-pohotový pohrdavě-pohrdavý pohrdlivě-pohrdlivý
                     pohyblivě-pohyblivý pochopitelně-pochopitelný pochvalně-pochvalný pochybně-pochybný
                     pokojně-pokojný pokorně-pokorný pokoutně-pokoutný politicky-politický polohově-polohový
                     polojasno-polojasný polopaticky-polopatický polystylově-polystylový pomalu-pomalý
                     poměrně-poměrný populárně-populární populisticky-populistický porovnatelně-porovnatelný
                     pořádně-pořádný posledně-poslední posluchačsky-posluchačský poslušně-poslušný
                     posměšně-posměšný posmrtně-posmrtný postmodernisticky-postmodernistický
                     postupně-postupný posupně-posupný pošetile-pošetilý potenciálně-potenciální
                     potěšitelně-potěšitelný poťouchle-poťouchlý poučeně-poučený poutavě-poutavý
                     povahově-povahový povážlivě-povážlivý povědomě-povědomý povinně-povinný
                     povrchově-povrchový pozitivně-pozitivní pozorně-pozorný pozoruhodně-pozoruhodný
                     pracně-pracný pracovně-pracovní pragmaticky-pragmatický prakticky-praktický
                     pravděpodobně-pravděpodobný pravicově-pravicový pravidelně-pravidelný právně-právní
                     pravomocně-pravomocný pravopisně-pravopisný pregnantně-pregnantní preventivně-preventivní
                     principiálně-principiální problematicky-problematický procentuálně-procentuální
                     profesionálně-profesionální profesně-profesní profesorsky-profesorský programově-programový
                     progresivně-progresivní prohibitně-prohibitní projektově-projektový prokazatelně-prokazatelný
                     proklamativně-proklamativní proloženě-proložený promptně-promptní promyšleně-promyšlený
                     propagandisticky-propagandistický proporcionálně-proporcionální prospěšně-prospěšný
                     prostě-prostý prostorově-prostorový prostředně-prostřední protestantsky-protestantský
                     protestně-protestní protibakteriálně-protibakteriální protiinflačně-protiinflační
                     protikladně-protikladný protikomunisticky-protikomunistický protinacisticky-protinacistický
                     protiněmecky-protiněmecký protiprávně-protiprávní protiústavně-protiústavní
                     protiválečně-protiválečný protizákonně-protizákonný protokolárně-protokolární
                     provinile-provinilý provizorně-provizorní provokativně-provokativní prozaicky-prozaický
                     prozíravě-prozíravý průběžně-průběžný prudce-prudký průhledně-průhledný
                     průměrně-průměrný průmyslově-průmyslový průrazně-průrazný průzračně-průzračný
                     pružně-pružný přátelsky-přátelský předběžně-předběžný předčasně-předčasný
                     předně-přední přednostně-přednostní přehledně-přehledný přehnaně-přehnaný
                     přechodně-přechodný překvapeně-překvapený překvapivě-překvapivý přemrštěně-přemrštěný
                     přeneseně-přenesený přerývaně-přerývaný přesně-přesný přesvědčivě-přesvědčivý
                     převážně-převážný převelice-převeliký převratně-převratný přibližně-přibližný
                     příjemně-příjemný příjmově-příjmový příkladně-příkladný příležitostně-příležitostný
                     přiměřeně-přiměřený přímo-přímý přímočaře-přímočarý případně-případný přirozeně-přirozený
                     příslušně-příslušný přísně-přísný příspěvkově-příspěvkový příště-příští
                     přitažlivě-přitažlivý příznačně-příznačný příznivě-příznivý psychicky-psychický
                     psychologicky-psychologický původně-původní pyšně-pyšný racionálně-racionální
                     radikálně-radikální radostně-radostný rafinovaně-rafinovaný raně-raný rapidně-rapidní
                     rasově-rasový razantně-razantní rázně-rázný realisticky-realistický reálně-reálný
                     recipročně-reciproční redakčně-redakční reflektivně-reflektivní regulérně-regulérní
                     rekordně-rekordní rekreačně-rekreační relativně-relativní rentabilně-rentabilní
                     reprezentativně-reprezentativní resortně-resortní restriktivně-restriktivní
                     rezolutně-rezolutní riskantně-riskantní rizikově-rizikový rockově-rockový
                     ročně-roční romanticky-romantický rovnoměrně-rovnoměrný rovnoprávně-rovnoprávný
                     rozechvěle-rozechvělý rozhodně-rozhodný rozhořčeně-rozhořčený rozkošně-rozkošný
                     rozpačitě-rozpačitý rozporně-rozporný rozporuplně-rozporuplný rozsáhle-rozsáhlý
                     rozšafně-rozšafný roztomile-roztomilý rozumně-rozumný rozvážně-rozvážný
                     rozverně-rozverný rozvroucněně-rozvroucněný ručně-ruční rusky-ruský rušno-rušný
                     rutinně-rutinní různě-různý růžově-růžový rychle-rychlý rytmicky-rytmický
                     řádně-řádný řádově-řádový řečnicky-řečnický řemeslně-řemeslný řetězovitě-řetězovitý
                     řídce-řídký samočinně-samočinný samostatně-samostatný samoúčelně-samoúčelný
                     samozřejmě-samozřejmý samozvaně-samozvaný sarkasticky-sarkastický satiricky-satirický
                     sebevědomě-sebevědomý sebevražedně-sebevražedný sedminásobně-sedminásobný
                     selektivně-selektivní sériově-sériový seriózně-seriózní setrvačně-setrvačný
                     severně-severní severozápadně-severozápadní sevřeně-sevřený sexuálně-sexuální
                     sezonně-sezónní shodně-shodný shrnutě-shrnutý silně-silný silově-silový
                     skandálně-skandální skandovaně-skandovaný skepticky-skeptický skromně-skromný
                     skrytě-skrytý skutečně-skutečný skvěle-skvělý skvostně-skvostný slabě-slabý
                     sladce-sladký slavně-slavný slavnostně-slavnostní slepě-slepý slibně-slibný
                     slovensky-slovenský slovně-slovní složitě-složitý sluchově-sluchový slušivě-slušivý
                     slušně-slušný služebně-služební směle-smělý směšně-směšný smírně-smírný
                     smluvně-smluvní smrtelně-smrtelný smutně-smutný smyslově-smyslový snadno-snadný
                     snesitelně-snesitelný sociálně-sociální sociologicky-sociologický solidně-solidní
                     sólově-sólový souběžně-souběžný souborně-souborný současně-současný soudně-soudný
                     soudržně-soudržný souhlasně-souhlasný souhrnně-souhrnný soukromě-soukromý
                     soustavně-soustavný soustředěně-soustředěný soutěžně-soutěžní sovětsky-sovětský
                     speciálně-speciální specificky-specifický spokojeně-spokojený společensky-společenský
                     společně-společný spolehlivě-spolehlivý spolu-společný spontánně-spontánní
                     sponzorsky-sponzorský sporadicky-sporadický sporně-sporný sportovně-sportovní
                     spořádaně-spořádaný spoře-sporý spravedlivě-spravedlivý správně-správný
                     srovnatelně-srovnatelný srozumitelně-srozumitelný stabilně-stabilní stále-stálý
                     standardně-standardní staročesky-staročeský statečně-statečný statisticky-statistický
                     stavebně-stavební stejně-stejný stonásobně-stonásobný stoprocentně-stoprocentní
                     stranicky-stranický strašlivě-strašlivý strašně-strašný strategicky-strategický
                     striktně-striktní strojně-strojní stručně-stručný středně-střední střelecky-střelecký
                     střídavě-střídavý střídmě-střídmý střízlivě-střízlivý studeně-studený stupňovitě-stupňovitý
                     stylově-stylový subjektivně-subjektivní sugestivně-sugestivní surově-surový
                     surrealisticky-surrealistický suše-suchý suverénně-suverénní svahilsky-svahilský
                     svědomitě-svědomitý svérázně-svérázný sveřepě-sveřepý světle-světlý světově-světový
                     svévolně-svévolný svisle-svislý svižně-svižný svobodně-svobodný svobodomyslně-svobodomyslný
                     svorně-svorný svrchovaně-svrchovaný symbolicky-symbolický symfonicky-symfonický
                     sympaticky-sympatický syrově-syrový systematicky-systematický šalamounsky-šalamounský
                     šedě-šedý šetrně-šetrný šikmo-šikmý šikovně-šikovný široce-široký široko-široký
                     škaredě-škaredý škodlivě-škodlivý šokovaně-šokovaný španělsky-španělský
                     špatně-špatný špičkově-špičkový špinavě-špinavý šťastně-šťastný tabulkově-tabulkový
                     tajemně-tajemný tajně-tajný takticky-taktický takzvaně-takzvaný tanečně-taneční
                     taxativně-taxativní teenagersky-teenagerský technicky-technický technologicky-technologický
                     telefonicky-telefonický tělesně-tělesný televizně-televizní tematicky-tematický
                     temně-temný teoreticky-teoretický tepelně-tepelný těsně-těsný textově-textový
                     těžce-těžký těžko-těžký tiše-tichý totálně-totální tradičně-tradiční tragicky-tragický
                     transdisciplinárně-transdisciplinární trapně-trapný trefně-trefný tréninkově-tréninkový
                     trestně-trestní trestuhodně-trestuhodný triumfálně-triumfální trojnásobně-trojnásobný
                     trpce-trpký trpělivě-trpělivý trpně-trpný trvale-trvalý tržně-tržný tučně-tučný
                     tvrdě-tvrdý tvrdošíjně-tvrdošíjný týdně-týdní typicky-typický typově-typový
                     uctivě-uctivý účelně-účelný účelově-účelový účetně-účetní-1 účinně-účinný
                     údajně-údajný uhrančivě-uhrančivý úhrnně-úhrnný úlevně-úlevný úlisně-úlisný
                     uměle-umělý umělecky-umělecký úměrně-úměrný umně-umný úmyslně-úmyslný unaveně-unavený
                     univerzálně-univerzální únosně-únosný úplně-úplný upřeně-upřený upřímně-upřímný
                     úrazově-úrazový urbionalisticky-urbionalistický určitě-určitý urychleně-urychlený
                     úředně-úřední úsečně-úsečný usilovně-usilovný uspěchaně-uspěchaný úspěšně-úspěšný
                     uspokojivě-uspokojivý ustavičně-ustavičný ústavně-ústavní ústně-ústní ústrojně-ústrojný
                     utěšeně-utěšený uvěřitelně-uvěřitelný uvnitř-vnitřní úzce-úzký územně-územní
                     územněsprávně-územněsprávní úzkostlivě-úzkostlivý úzkostně-úzkostný valně-valný
                     vančurovsky-vančurovský varovně-varovný vášnivě-vášnivý vážně-vážný věcně-věcný
                     věčně-věčný vědecky-vědecký vědomě-vědomý vehementně-vehementní věkově-věkový
                     velkoryse-velkorysý verbálně-verbální věrně-věrný věrohodně-věrohodný vertikálně-vertikální
                     veřejně-veřejný veřejnoprávně-veřejnoprávní vesele-veselý větrno-větrný
                     vhod-vhodný vhodně-vhodný víceúčelově-víceúčelový viditelně-viditelný virtuózně-virtuózní
                     vítězně-vítězný vkusně-vkusný vlastnoručně-vlastnoruční vlažně-vlažný vnějškově-vnějškový
                     vnímavě-vnímavý vnitropoliticky-vnitropolitický vnitřně-vnitřní vodivě-vodivý
                     vodorovně-vodorovný vojensky-vojenský vokálně-vokální volně-volný vratce-vratký
                     vrcholně-vrcholný vrcholově-vrcholový vrozeně-vrozený vřele-vřelý vstřícně-vstřícný
                     všelijak-všelijaký všeobecně-všeobecný všestranně-všestranný vtipně-vtipný
                     vtíravě-vtíravý vulgárně-vulgární výběrově-výběrový výborně-výborný vybraně-vybraný
                     výdajově-výdajový vydatně-vydatný výdělečně-výdělečný výhledově-výhledový
                     výhodně-výhodný výhradně-výhradní vyhýbavě-vyhýbavý výjimečně-výjimečný
                     vyloženě-vyložený výlučně-výlučný výmluvně-výmluvný vypjatě-vypjatý výrazně-výrazný
                     výrazově-výrazový vyrovnaně-vyrovnaný výřečně-výřečný výsledně-výsledný
                     vysloveně-vyslovený výslovně-výslovný vysoce-vysoký vysoko-vysoký vysokoškolsky-vysokoškolský
                     výstižně-výstižný výtečně-výtečný vytrvale-vytrvalý vytrženě-vytržený výtvarně-výtvarný
                     významně-významný významově-významový vyzrále-vyzrálý vzácně-vzácný vzájemně-vzájemný
                     vzdáleně-vzdálený vzhledově-vzhledový vzorně-vzorný vzrušeně-vzrušený záhadně-záhadný
                     zahraničně-zahraniční zajímavě-zajímavý zákonitě-zákonitý zákonně-zákonný
                     zakřiknutě-zakřiknutý zálibně-zálibný zálohově-zálohový záměrně-záměrný
                     zamračeně-zamračený zanedbatelně-zanedbatelný zaníceně-zanícený zaobaleně-zaobalený
                     západně-západní záporně-záporný zarputile-zarputilý zaručeně-zaručený zarytě-zarytý
                     zařaditelně-zařaditelný zásadně-zásadní zaslouženě-zasloužený zastřeně-zastřený
                     zasvěceně-zasvěcený zatraceně-zatracený zatvrzele-zatvrzelý závazně-závazný
                     závažně-závažný záviděníhodně-záviděníhodný závistivě-závistivý závratně-závratný
                     zázračně-zázračný zběsile-zběsilý zbrkle-zbrklý zbytečně-zbytečný zdánlivě-zdánlivý
                     zdařile-zdařilý zděšeně-zděšený zdlouhavě-zdlouhavý zdravě-zdravý zdravotně-zdravotní
                     zdrženlivě-zdrženlivý zdvořile-zdvořilý zelenobíle-zelenobílý zevrubně-zevrubný
                     zištně-zištný zjednodušeně-zjednodušený zjevně-zjevný zkoumavě-zkoumavý
                     zkratkovitě-zkratkovitý zlatavě-zlatavý zle-zlý zlobně-zlobný zlomyslně-zlomyslný
                     zlověstně-zlověstný značně-značný znamenitě-znamenitý znatelně-znatelný
                     znechuceně-znechucený zodpovědně-zodpovědný zoufale-zoufalý zpětně-zpětný
                     zpropadeně-zpropadený zprostředkovaně-zprostředkovaný zpupně-zpupný zrakově-zrakový
                     zrcadlově-zrcadlový zrychleně-zrychlený zřejmě-zřejmý zřetelně-zřetelný
                     ztepile-ztepilý zvláštně-zvláštní zvukově-zvukový žalostně-žalostný žánrově-žánrový
                     živě-živý životně-životní žíznivě-žíznivý
             );


foreach my $pair (@adv2adj) {
    my ($adverb,$adj) = split "-",$pair;
    $adv2adj{$adverb} = $adj;
}











my @nonnegable_semn = qw( glasnost Hnutí hnutí hodnost Host host Husajní Husní Chomejní Investiční
                          jakost jmění kamení kontilití Kost kost krveprolévání krveprolití lešení
                          listí Martí mezipřistání místnost monopost Most most náčiní nadání Náměstí
                          náměstí nanebevstoupení napětí národnost návštěvnost Nedorost nerost neštěstí
                          Nevolnost oddělení okolnost osobnost paní pidiosobnost Pobaltí podezření
                          podnikání podsvětí pokání pokolení pololetí ponětí porodnost porost Porýní
                          post prazkušenost prodlení Prost proticírkevnost protiopatření předloktí
                          předměstí přednost představení příčestí příjmení příležitost pseudoživnost
                          půlstoletí působnost Rabbání rádio_aktivní radní radost rčení recepční rozhraní
                          ručení rukoudání sebehodnocení sebeobětování sebeomezení sebepoznání sebeupálení
                          sebeurčení sebezahleděnost sebezkoumání sebezničení sepjetí skvost soustátí
                          společnost Srní stání starost státnost století štěstí Štětí televizní tisíciletí
                          trnkobraní trojutkání účetní úmrtí úpatí uskupení ustanovení Ústí ústraní
                          utrpení vedení vězení vlastnost vrchní výsluní výsost vysvědčení Záblatí
                          zákoutí záležitost Zámostí zápěstí Zápotoční zemětřesení zmrtvýchvstání
                          znakování znamení Znouzecnost znovunavrácení znovuzačlenění znovuzavedení
                          zvláštnost žádost živobytí);

foreach my $item (@nonnegable_semn) {
    $nonnegable_semn{$item}=1;
}










# -------------- konverzni soubor ---------
my $configtext = q{
# - - - - - - - - - - - - - - - - - - - - - - - - - 
# Část 1: atributy související s gramatémy
# a výčty jejich možných hodnot
# notace: název atributu následovaný dvojtečkou
# a výčtem možných hodnot oddělených čárkou,
# vše ukončeno středníkem


WordClass: N.denot, # substantiva pojmenovací
	N.denot.neg, # substantiva pojmenovací s formal. zprac. negace
	N.pron.def.demon, # např. substantivní ten (ten nepřijde)
	N.pron.def.pers , # např. &PersPron;
	N.pron.indef, # např. kdo, nikdo, jenž
	N.quant.def, # např. sto, tři (v subst. pozici: Přišli tři)
	ADJ.denot, # adjektiva pojmenovací stupňovatelná i nestupňovatelná (která 
		# nejsou deadverbiální, a tudíž nedostanou adv. trlemma)
	ADJ.pron.def.demon, # např. takový, tenhle, adjektivní ten (ten muž)
	ADJ.pron.indef, # např. jaký, který, nějaký
	ADJ.quant.def, # např.tři v adj.funkci (tři děti)
	ADJ.quant.indef, # např. kolik, několikery, tolik, málo
	ADJ.quant.grad,
           	ADV.denot.grad.nneg, # pojmenovací příslovce stupňovatelná (která nejsou deadjektivní, 
		# a tudíž nedostanou adj. trlemma), např. dole, pozdě, brzy, často
           	ADV.denot.ngrad.nneg, # pojmenovací příslovce nestupňovatelná (nejsou deadjektivní, 
		# a tudíž nedostanou adj. trlemma), např. doma, dnes, mimo, kupříkladu
	ADV.denot.grad.neg, 
	ADV.denot.ngrad.neg,
	ADV.pron.def, # např. tam, potom
	ADV.pron.indef, # např. kdy, proč
           	V;
Gender: ANIM,INAN,FEM,NEUT;
Number: SG,PL;
DegCmp: POS,COMP,ACOMP,SUP;
Sentmod: ENUNC,EXCL,DESID,IMPER,INTER;
Verbmod: IND,IMP,CDN;
Deontmod: DEB,HRT,VOL,POSS,PERM,FAC,DECL;
Tense: SIM,ANT,POST;
Aspect: PROC,CPL;
Resultative: RES1,RES0;
Dispmod: DISP1,DISP0;
Iterativeness: IT1,IT0;
IndefType: RELAT,INDEF1,INDEF2,INDEF3,INDEF4,INDEF5,INDEF6,INTER,NEGAT,TOTAL1,TOTAL2;
	# k hodnotám TOTAL1/2: TOTAL1 označuje celek globálně (př. všichni), 
	# TOTAL2 se vztahuje k jednotlivinám (př. každý)
Person: 1,2,3; 
NumerType: BASIC,SET,KIND,ORD,FRAC;
Politeness: POLITE,BASIC;
Negation: NEG0,NEG1;


# - - - - - - - - - - - - - - - - - - - - - - - - - 
# Část 2: výčet gramatémů relevantních pro danou WordClass
# notace: hodnota WordClass následovaná dvojitou šipkou =>
# a výčtem gramatémů (potenciálně prázdným) oddělených
# čárkou, vše ukončeno středníkem
 
N.denot => Gender,Number; 
N.denot.neg => Gender,Number,Negation; 
N.pron.def.demon => Gender,Number; 
N.pron.def.pers => Gender,Number,Person,Politeness; 
N.pron.indef => Gender,Number,IndefType,Person;
N.quant.def => Gender,Number,NumerType;
ADJ.denot => DegCmp,Negation;
ADJ.pron.def.demon =>; # žádný gramatém - prázdná množina
ADJ.quant.def => NumerType;
ADJ.pron.indef => IndefType; 
ADJ.quant.indef => IndefType,NumerType;
ADJ.quant.grad => DegCmp,NumerType;
ADV.denot.ngrad.neg => Negation;
ADV.denot.grad.neg => DegCmp,Negation;
ADV.denot.ngrad.nneg =>;
ADV.denot.grad.nneg => DegCmp;
ADV.pron.def =>; # prázdná množina
ADV.pron.indef => IndefType;
V => Verbmod,Deontmod,Dispmod,Tense,Aspect,Resultative,Iterativeness;

# gramatém Sentmod není jako jediný přidělován uzlu na základě jeho hodnoty WordClassu,
# v této části tedy nebyl uveden


# - - - - - - - - - - - - - - - - - - - - - - - - - 
# Část 3: výčet podmínek, které budou užity v části 4, 
# notace: v závorce identifikátor podmínky, který ji bude reprezentovat v části 4,
# ukončeno středníkem,
# jediným identifikátorem budou zaznamenány podmínky jednoduché 
# i podmínky kombinované z několika jednoduchých, 
# uvedena vždy zvlášť kladná a zvlášť negativní podoba podmínky,
# za křížkem stručné vysvětlení, co podmínka postihuje


(RSTR); # uzel (s lematem, jehož se následující informace o změně lematu a o hodnotách gramatémů 
	# týkají) má fuktor RSTR
(notRSTR); # uzel má funktor jiný než RSTR
(Coref); # od uzlu vede šipka koreference
(notCoref); # od uzlu nevede šipka koreference
(Plur); # uzel visí na uzlu, jehož lematem je pomnožné substantivum (identifikováno seznamem), popř. 
	# se pomnožné substantivum vyskytuje jinde ve stromě
(notPlur); # uzel nevisí na pomnožném substantivu (identifikováno seznamem) a pomnožné 
	# substantivum se nevyskytuje ani jinde ve stromě
(TWHEN); # uzel má funktor TWHEN
(TTILL); # uzel má funktor TTILL
(LOC); # uzel má funktor LOC
(DIR3); # uzel má funktor DIR3
(N&notRSTR); # jde o uzel s lematem středního rodu (3. pozice morfologického tagu = N) a zároveň 
	# má tento uzel funktor jiný než RSTR 
(notN&notRSTR); # jde o uzel s lematem jiného než středního rodu (3. pozice morfologického tagu 
	 # jiná než N) a zároveň má tento uzel funktor jiný než RSTR 
(Coref&RSTR); # od uzlu vede koreferenční šipka a zároveň má uzel funktor RSTR
(Coref&notRSTR); # od uzlu vede koreferenční šipka a zároveň má uzel funktor jiný než RSTR
(notCoref&RSTR); # od uzlu nevede šipka koreference a zároveň má uzel funktor RSTR 
(notCoref&notRSTR); # od uzlu nevede šipka koreference a zároveň má uzel funktor jiný než RSTR
(Coref&Plur); # od uzlu vede šipka koreference a zároveň uzel visí na uzlu, jehož lematem je 
	# pomnožné substantivum (identifikováno seznamem), popř. se pomnožné 
	# substantivum vyskytuje jinde ve stromě
 (Coref&notPlur); # od uzlu vede šipka koreference a zároveň uzel nevisí na pomnožném substantivu 
	# (identifikováno seznamem) a pomnožné substantivum se nevyskytuje ani jinde ve stromě
(notCoref&Plur); # od uzlu nevede šipka koreference a zároveň uzel visí na uzlu, jehož lematem je 
	# pomnožné substantivum (identifikováno seznamem), popř. se pomnožné substantivum 
	# vyskytuje jinde ve stromě
(notCoref&notPlur); # od uzlu nevede šipka koreference a zároveň uzel nevisí na pomnožném 
	# substantivu (identifikováno seznamem) a pomnožné substantivum se nevyskytuje
 	# ani jinde ve stromě
# - - - - - - - - - - - - - - - - - - - - - - - - - 
# Část 4: převodní tabulka, kdy hodnoty gramatému
# přímo vyplývají z mrlemmatu.
# notace: uvedení podmínky ve tvaru if + identifikátor (z části 3), která 
# se na následující převodní případ vztahuje, 
# na dalším řádku mrlemma (v případě více styl.variant
# více mrlemmat oddělených čárkou) následované
# jednoduchou šipkou -> a výčtem dvojic atribut=hodnota
# oddělených čárkou, vše ukončeno středníkem 

# ad B.2.-a (N.pron.def.demon):demonstrativní zájmena substantivní "ten" a další- vyplní se Gender 
# a Number; ponechají si VŽDY své lema; v prosincové zprávě část 3. 2. na str. 7
# TAKÉ: tentýž
if notRSTR
ten -> 	trlemma=ten,
         	WordClass= N.pron.def.demon;
if notRSTR
tento -> 	trlemma=tento,
         	WordClass= N.pron.def.demon;
if notRSTR
tamten -> 	trlemma= tamten,
         	WordClass= N.pron.def.demon;
if notRSTR
onen -> 	trlemma= onen,
         	WordClass= N.pron.def.demon;
if notRSTR
tenhle -> 	trlemma= tenhle,
         	WordClass= N.pron.def.demon;
if notRSTR
tenhleten -> trlemma= tenhleten,
         	WordClass= N.pron.def.demon;
if notRSTR
tadyhleten -> trlemma= tadyhleten,
         	WordClass= N.pron.def.demon;
if notRSTR
tuhleten -> trlemma= tuhleten,
         	WordClass= N.pron.def.demon;
if notRSTR
tamhleten -> trlemma= tamhleten,
         	WordClass= N.pron.def.demon;
if notRSTR
tentýž -> 	trlemma=tentýž,
         	WordClass= N.pron.def.demon;



# ad B.4.-a (N.pron.indef); substantivní zájmena neurčitá apod. - ve zprávě tabulka 2 na str. 8
if Coref
kdo,kdož -> trlemma=kdo,
	WordClass= N.pron.indef,
	IndefType=RELAT;
někdo -> trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF1;
kdosi,kdos -> trlemma=kdo,
	WordClass=N.pron.indef,
	IndefType=INDEF2;
kdokoli,kdokoliv -> trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF3;
ledakdo,leckdo,ledakdos,ledaskdo -> trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF4;
kdekdo -> trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF5;
málokdo,sotvakdo,zřídkakdo,všelikdo,nevímkdo,kdovíkdo,bůhvíkdo,čertvíkdo -> trlemma=kdo, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíkdo i kdoví kdo)
         	WordClass=N.pron.indef,
	IndefType=INDEF6;
if notCoref
kdo,kdopak,kdožpak,kdože -> trlemma=kdo,
	WordClass=N.pron.indef,
	IndefType=INTER;
nikdo -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=NEGAT; 
if notN&notRSTR
všechen,všecek -> trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=TOTAL1; 


# ad B.4.-b (N.pron.indef); substantivní zájmena neurčitá apod. - ve zprávě tabulka 2 na str. 8
if Coref
co,což,oč,nač,zač -> trlemma=co,
	WordClass=N.pron.indef,
	IndefType=RELAT;
něco -> 	trlemma=co,
         	WordClass=N.pron.indef,
	IndefType=INDEF1;
cosi,cos -> trlemma=co,
	WordClass=N.pron.indef,
	IndefType=INDEF2;
cokoli,cokoliv,cožkoli,cožkoliv -> trlemma=co,
         	WordClass=N.pron.indef,
	IndefType=INDEF3;
ledaco,lecco,leccos,ledacos,ledasco -> trlemma=co,
         	WordClass=N.pron.indef,
	IndefType=INDEF4;
kdeco -> 	trlemma=co,
         	WordClass=N.pron.indef,
	IndefType=INDEF5;
máloco,sotvaco,zřídkaco,všelico,všelicos,nevímco,kdovíco,bůhvíco,čertvíco -> trlemma=co, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíco i kdoví co)
         	WordClass=N.pron.indef,
	IndefType=INDEF6;
if notCoref
co,copak,cožpak,cože,oč,nač,zač -> trlemma=co,
	WordClass=N.pron.indef,
	IndefType=INTER;
nic -> 	trlemma=co,
         	WordClass=N.pron.indef,
	IndefType=NEGAT; 
if N&notRSTR
všechen,všechno,vše,všecek -> trlemma=co, # "všechno, vše" jako mrlemmata asi nebudou (zde pro jistotu); 
	# "vše" jako varianta k "všechno"
	WordClass=N.pron.indef,
	IndefType=TOTAL1; 


# ad B.4.-c (N.pron.indef); posesivní zajmena, která budou převedena na trlemma odpovídajícího 
# substantivního zájmena; ve zprávě tabulka 3 na str. 9
if Coref
čí -> 	trlemma=kdo,
	WordClass= N.pron.indef,
	IndefType=RELAT;
něčí -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF1;
čísi -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF2;
číkoli -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF3;
ledačí -> 	trlemma=kdo,
	WordClass=N.pron.indef,
	IndefType=INDEF4;
kdečí -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INDEF5;
máločí-> 	trlemma=kdo,
	WordClass=N.pron.indef,
	IndefType=INDEF6;
if notCoref
čí -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=INTER;
ničí -> 	trlemma=kdo,
         	WordClass=N.pron.indef,
	IndefType=NEGAT;

# ad B.4.-d (N.pron.indef); substantivní zájmena neurčitá apod. - ve zprávě tabulka 2 na str. 8
jenž -> 	trlemma=který, # "jenž" se chápe jako stylistická varianta k subst. "který"
	WordClass=N.pron.indef,
	IndefType=RELAT;
if Coref&notRSTR
který,kterýž -> trlemma=který, # "kterýž" se chápe jako stylistická varianta k subst. "který"
	WordClass=N.pron.indef,
	IndefType=RELAT;
if notRSTR
některý -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INDEF1;
if notRSTR
kterýsi -> 	trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INDEF2;
if notRSTR
kterýkoli,kterýkoliv -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INDEF3;
if notRSTR
ledakterý,leckterý -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INDEF4;
if notRSTR
kdekterý -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INDEF5;
if notRSTR
málokterý,sotvakterý,zřídkakterý,všelikterý,nevímkterý,bůhvíkterý,čertvíkterý -> trlemma=který, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíkterý i kdoví který) - otázkou je, kolik 
	# takových slov v treebanku je
	WordClass=N.pron.indef,
	IndefType=INDEF6;
if notCoref&notRSTR
který,kterýpak -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=INTER;
if notRSTR
žádný -> trlemma=který,
	WordClass=N.pron.indef,
	IndefType=NEGAT; 
if notRSTR
každý -> 	trlemma=který,
         	WordClass=N.pron.indef,
	IndefType=TOTAL2;


# ad B.4.-e (N.pron.indef); substantivní zájmena neurčitá apod. - ve zprávě tabulka 2 na str. 8
if Coref&notRSTR
jaký,jakýž, jakýs -> trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=RELAT;
if notRSTR
nějaký -> 	trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INDEF1;
if notRSTR
jakýsi  -> 	trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INDEF2;
if notRSTR
jakýkoli,jakýkoliv -> trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INDEF3;
if notRSTR
ledajaký,lecjaký -> trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INDEF4;
if notRSTR
kdejaký -> trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INDEF5;
if notRSTR
málojaký,sotvajaký,zřídkajaký,všelijaký,nevímjaký,kdovíjaký,bůhvíjaký,čertvíjaký -> trlemma=jaký, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíjaký i kdoví jaký) - otázkou je, kolik takových
	# slov v treebanku je
	WordClass=N.pron.indef,
	IndefType=INDEF6;
if notCoref&notRSTR
jaký,jakýpak,jakýs -> trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=INTER;
if notRSTR
nijaký -> 	trlemma=jaký,
	WordClass=N.pron.indef,
	IndefType=NEGAT;


# ad B.7.-a (ADJ.pron.def.demon): adjektivní "ten", tenhle" atd.- nevyplňuje se žádný gramatém - 
# ponechají si VŽDY své lema; ve zprávě část 3. 2. na str. 7
if RSTR
ten -> 	trlemma=ten,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tento -> 	trlemma=tento,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tamten -> 	trlemma= tamten,
         	WordClass= ADJ.pron.def.demon;
if RSTR
onen -> 	trlemma= onen,
         	WordClass= ADJ.pron.def.demon;
onaký -> 	trlemma= onaký,
         	WordClass= ADJ.pron.def.demon;
takový,taký,takýs -> 	trlemma= takový, 
         	WordClass= ADJ.pron.def.demon;
if RSTR
tenhle -> 	trlemma= tenhle,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tenhleten -> trlemma= tenhleten,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tadyhleten -> trlemma= tadyhleten,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tuhleten -> trlemma= tuhleten,
         	WordClass= ADJ.pron.def.demon;
if RSTR
tamhleten -> trlemma= tamhleten,
         	WordClass= ADJ.pron.def.demon;
takovýto -> trlemma= takový,
         	WordClass= ADJ.pron.def.demon;
takovýhle -> trlemma= takovýhle,
         	WordClass= ADJ.pron.def.demon;
sám -> 	trlemma= sám,
         	WordClass= ADJ.pron.def.demon;
samý -> 	trlemma= samý,
         	WordClass= ADJ.pron.def.demon;

# ad B.7.-b (ADJ.pron.def.demon): identifikační (demonstrativní) zájmena (adjektivní "tentýž"
# a "týž" - nevyplňuje se u nich žádný gramatém) - ponechají 
# si VŽDY své lema; ve zprávě část 3. 2. na str. 7 (Otevřené otázky)
týž -> 	trlemma= týž,
         	WordClass= ADJ.pron.def.demon;
tentýž -> 	trlemma= tentýž,
         	WordClass= ADJ.pron.def.demon;


# ad B.5. a B.8. (N.quant.def a ADJ.quant.def): číslovky určité (čísla vyjádřená slovy)
# převod lemat a přidělení hodnot některých gramatémů 
# ve zprávě část 5. 1. na str. 13 a dál - zde ale zatím jen pro ty číslovky, které byly nalezeny 
# v treebanku

# ad B.5. a B.8. iii)
stý -> 	trlemma=sto,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
tisící -> 	trlemma=tisíc,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
první,prvý -> trlemma=jeden,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
druhý -> 	trlemma=dva,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třetí -> 	trlemma=tři,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
čtvrtý -> 	trlemma=čtyři,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pátý -> 	trlemma=pět,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
šestý -> 	trlemma=šest,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmý -> 	trlemma=sedm,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmý -> 	trlemma=osm,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devátý -> 	trlemma=devět,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
desátý -> 	trlemma=deset,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
jedenáctý -> trlemma=jedenáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvanáctý -> trlemma=dvanáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třináctý -> trlemma=třináct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
čtrnáctý -> trlemma=čtrnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
patnáctý -> trlemma=patnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
šestnáctý -> trlemma=šestnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmnáctý -> trlemma=sedmnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmnáctý -> trlemma=osmnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devatenáctý -> trlemma=devatenáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvacátý -> trlemma=dvacet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvaadvacátý -> trlemma=dvaadvacet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pětadvacátý -> trlemma=pětadvacet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třicátý -> 	trlemma=třicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmatřicátý -> trlemma=sedmatřicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmatřicátý -> trlemma=osmatřicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devětatřicátý -> trlemma=devětatřicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
čtyřicátý -> trlemma=čtyřicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pětačtyřicátý -> trlemma=pětačtyřicet,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
padesátý -> trlemma=padesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmapadesátý -> trlemma=sedmapadesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devětapadesátý -> trlemma=devětapadesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
šedesátý -> trlemma=šedesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
jedenašedesátý -> trlemma=jedenašedesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmašedesátý -> trlemma=osmašedesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmdesátý -> trlemma=sedmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvaasedmdesátý -> trlemma=dvaasedmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pětasedmdesátý -> trlemma=pětasedmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmasedmdesátý -> trlemma=sedmasedmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmdesátý -> trlemma=osmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třiaosmdesátý -> trlemma=třiaosmdesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devadesátý -> trlemma=devadesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
devětadevadesátý -> trlemma=devětadevadesát,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;

# ad B.5. a B.8. iv)
stokrát -> 	trlemma=sto,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
posté -> 	trlemma=sto,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
tisíckrát -> trlemma=tisíc,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
jednou,jedenkrát,jedinkrát -> trlemma=jeden,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
poprvé -> 	trlemma=jeden,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvakrát -> trlemma=dva,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
podruhé -> trlemma=dva,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třikrát -> 	trlemma=tři,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
potřetí -> 	trlemma=tři,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
čtyřikrát -> trlemma=čtyři,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
počtvrté -> trlemma=čtyři,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pětkrát -> 	trlemma=pět,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
popáté -> 	trlemma=pět,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
šestkrát -> trlemma=šest,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
pošesté -> trlemma=šest,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
sedmkrát -> trlemma=sedm,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
posedmé -> trlemma=sedm,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
osmkrát -> trlemma=osm,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
devětkrát -> trlemma=devět,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
desetkrát -> trlemma=deset,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
podesáté -> trlemma=deset,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
jedenáctkrát -> trlemma=jedenáct,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
pojedenácté -> trlemma=jedenáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvanáctkrát -> trlemma=dvanáct,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
podvanácté -> trlemma=dvanáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
třináctkrát -> trlemma=třináct,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
čtrnáctkrát -> trlemma=čtrnáct,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
patnáctkrát -> trlemma=patnáct,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;
popatnácté -> trlemma=patnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
pošestnácté -> trlemma=šestnáct,
         	WordClass=ADJ.quant.def,
	NumerType=ORD;
dvacetkrát -> trlemma=dvacet,
         	WordClass=ADJ.quant.def,
	NumerType=BASIC;



nejednou -> trlemma=nejeden,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=POS;



# ad B.5. a B.8. v)
třetina -> 	trlemma=tři,
         	WordClass=N.quant.def,
	NumerType=FRAC;
čtvrtina -> trlemma=čtyři,
         	WordClass=N.quant.def,
	NumerType=FRAC;
pětina -> 	trlemma=pět,
         	WordClass=N.quant.def,
	NumerType=FRAC;
šestina -> trlemma=šest,
         	WordClass=N.quant.def,
	NumerType=FRAC;
desetina -> trlemma=deset,
         	WordClass=N.quant.def,
	NumerType=FRAC;
setina -> 	trlemma=sto,
         	WordClass=N.quant.def,
	NumerType=FRAC;
sedmdesátina -> trlemma=sedmdesát,
         	WordClass=N.quant.def,
	NumerType=FRAC;

# ad ADJ.quant.grad: jen slova na "krát", ostaní je v programovacím skriptu
mnohokrát,mnohokráte -> trlemma=mnoho,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=POS;
vícekrát,víckrát,vícekráte,víckráte -> trlemma=mnoho,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=COMP;
bezpočtukrát,bezpočtukráte -> trlemma=bezpočet,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=POS;
málokrát,málokráte -> trlemma=málo,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=POS;
párkrát,párkráte -> trlemma=pár,
         	WordClass=ADJ.quant.grad,
	NumerType=BASIC,
	DegCmp=POS;

# ad B.9. (ADJ.pron.indef): adjektivní zájmena indefinitní atd.; ve zprávě tabulka 2 na str. 8
if Coref&RSTR
jaký,jakýž -> trlemma=jaký,
	WordClass=ADJ.pron.indef,
	IndefType=RELAT;
if RSTR
nějaký -> 	trlemma=jaký,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF1;
if RSTR
jakýsi -> 	trlemma=jaký,
	WordClass=ADJ.pron.indef,
	IndefType=INDEF2;
if RSTR
jakýkoli,jakýkoliv -> trlemma=jaký,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF3;
if RSTR
ledajaký,lecjaký -> trlemma=jaký,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF4;
if RSTR
kdejaký -> trlemma=jaký,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF5;
if RSTR
málojaký,sotvajaký,zřídkajaký,všelijaký,nevímjaký,kdovíjaký,bůhvíjaký,čertvíjaký -> trlemma=jaký, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíjaký i kdoví jaký) - otázkou je, kolik takových
	# slov v treebanku je
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF6;
if notCoref&RSTR
jaký,jakýpak -> trlemma=jaký,
	WordClass=ADJ.pron.indef,
	IndefType=INTER;
if RSTR
nijaký -> 	trlemma=jaký,
         	WordClass=ADJ.pron.indef,
	IndefType=NEGAT;
if Coref&RSTR
který,kterýž -> trlemma=který,
	WordClass=ADJ.pron.indef,
	IndefType=RELAT;
if RSTR
některý -> trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF1;
if RSTR
kterýsi -> 	trlemma=který,
	WordClass=ADJ.pron.indef,
	IndefType=INDEF2;
if RSTR
kterýkoli,kterýkoliv -> trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF3;
if RSTR
ledakterý,leckterý -> trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF4;
if RSTR
kdekterý -> trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF5;
if RSTR
málokterý,sotvakterý,zřídkakterý,všelikterý,nevímkterý,bůhvíkterý,čertvíkterý -> trlemma=který, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíkterý i kdoví který) - otázkou je, kolik 
	# takových slov v treebanku je
         	WordClass=ADJ.pron.indef,
	IndefType=INDEF6;
if notCoref&RSTR
který,kterýpak -> trlemma=který,
	WordClass=ADJ.pron.indef,
	IndefType=INTER;
if RSTR
žádný -> 	trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=NEGAT; 
if RSTR
každý -> 	trlemma=který,
         	WordClass=ADJ.pron.indef,
	IndefType=TOTAL2;
if RSTR
všechen,veškerý,všecek -> trlemma=který, # "veškerý" je stylová varianta k "všechen" 
	WordClass=ADJ.pron.indef,
	IndefType=TOTAL1;


# ad B.10. - a (ADJ.quant.indef): neurčité číslovky pronominální indef. včetně adverbií
# (ně)kolikrát / po(ně)kolikáté, která dostanou adj. trlemma (ve zprávě str. 17-18, tabulky 11-13)
if Coref
kolik,kolikero -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=RELAT;
if Coref&Plur
kolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=RELAT;
if Coref&notPlur
kolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=SET,
	IndefType=RELAT;
if Coref
kolikerý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=KIND,
	IndefType=RELAT;
if Coref
kolikátý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=RELAT;
několik,několikero -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF1;
if Plur
několikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF1;
if notPlur
několikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=SET,
	IndefType=INDEF1;
několikerý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=KIND,
	IndefType=INDEF1;
několikátý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INDEF1;
kdovíkolik,bůhvíkolik,čertvíkolik,nevímkolik,kdovíkolikero,bůhvíkolikero,čertvíkolikero,nevímkolikero -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF6;
if Plur
kdovíkolikery,bůhvíkolikery,čertvíkolikery,nevímkolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF6;
if notPlur
kdovíkolikery,bůhvíkolikery,čertvíkolikery,nevímkolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=SET,
	IndefType=INDEF6;
kdovíkolikerý,bůhvíkolikerý,čertvíkolikerý,nevímkolikerý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=KIND,
	IndefType=INDEF6;
kdovíkolikátý,bůhvíkolikátý,čertvíkolikátý,nevímkolikátý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INDEF6;
if notCoref
kolik,kolikero -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INTER;
if notCoref&Plur
kolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INTER;
if notCoref&notPlur
kolikery -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=SET,
	IndefType=INTER;
if notCoref
kolikerý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=KIND,
	IndefType=INTER;
if notCoref
kolikátý -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INTER;
if Coref
kolikrát,kolikráte ->	trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=RELAT;
if Coref
pokolikáté -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=RELAT;
několikrát,několikráte -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF1;
poněkolikáté -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INDEF1;
kdovíkolikrát,bůhvíkolikrát,čertvíkolikrát,nevímkolikrát -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INDEF6;
pokdovíkolikáté,pobůhvíkolikáté,počertvíkolikáté,ponevímkolikáté -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INDEF6;
if notCoref
kolikrát,kolikráte -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=BASIC,
	IndefType=INTER;
if notCoref
pokolikáté -> trlemma=kolik,
	WordClass=ADJ.quant.indef,
	NumerType=ORD,
	IndefType=INTER;

# ad B.10. - b (ADJ.quant.def): ZMĚNA: neurčitá číslovky "tolik" bude patřit do URČITÝCH
# včetně adverbií tolikrát / potolikáté, která dostanou adj. trlemma (ve zprávě str. 16-17, tabulka 10);
# uvedena rovněž číslovka tolikhle a (identifikační) číslovka "tolikéž" - 
# obě si ponechají původní lema (ADJ.quant.def) 
tolik -> 	trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=BASIC;
if Plur
tolikery -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=BASIC;
if notPlur
tolikery -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=SET;
tolikerý -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=KIND;
tolikátý -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=ORD;
tolikrát,tolikráte -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=BASIC;
potolikáté -> trlemma=tolik,
	WordClass=ADJ.quant.def,
	NumerType=ORD;
tolikhle -> trlemma=tolikhle,
	WordClass=ADJ.quant.def,
	NumerType=BASIC;
tolikéž -> trlemma=tolikéž,
	WordClass=ADJ.quant.def,
	NumerType=BASIC;


# ad B.13. (ADV.pron.def): pronominální adverbia určitá; ve zprávě tabulka 6a,b na str. 12
tak -> 	trlemma=tak,
	WordClass=ADV.pron.def;

onak -> 	trlemma=onak,
	WordClass=ADV.pron.def;

proto -> 	trlemma=proto,
	WordClass=ADV.pron.def;
teď,nyní -> trlemma=teď,
	WordClass=ADV.pron.def;
if TWHEN
tu -> 	trlemma=teď,
	WordClass=ADV.pron.def;

if TWHEN
tuhle -> 	trlemma=tuhle,
	WordClass=ADV.pron.def;


odteď -> 	trlemma=teď,
	WordClass=ADV.pron.def;
doteď -> 	trlemma=teď,
	WordClass=ADV.pron.def;
if TTILL
doposud,potud,posud -> trlemma=teď,
	WordClass=ADV.pron.def;
potom,pak,poté -> trlemma=potom,
	WordClass=ADV.pron.def;
tehdy -> 	trlemma=tehdy,
	WordClass=ADV.pron.def;
tenkrát -> 	trlemma=tenkrát,
	WordClass=ADV.pron.def;
onehdy -> trlemma=onehdy,
	WordClass=ADV.pron.def;
předtím -> trlemma=předtím,
	WordClass=ADV.pron.def;
tady,zde -> trlemma=tady,
	WordClass=ADV.pron.def;
if LOC
tu -> 	trlemma=tady,
	WordClass=ADV.pron.def;
odtud,odsud -> trlemma=tady,
	WordClass=ADV.pron.def;
tudy -> 	trlemma=tady,
	WordClass=ADV.pron.def;
sem -> 	trlemma=tady,
	WordClass=ADV.pron.def;
if DIR3
potud,posud -> trlemma=tady,
	WordClass=ADV.pron.def;
tam -> 	trlemma=tam,
	WordClass=ADV.pron.def;
odtamtud -> trlemma=tam,
	WordClass=ADV.pron.def;
tamtudy -> trlemma=tam,
	WordClass=ADV.pron.def;

tytam -> 	trlemma=tytam,
	WordClass=ADV.pron.def;
tamhle -> 	trlemma=tamhle,
	WordClass=ADV.pron.def;

tamtéž -> 	trlemma=tamtéž,
	WordClass=ADV.pron.def;

onehdá -> trlemma=onehdá,
	WordClass=ADV.pron.def;
onde -> 	trlemma=onde,
	WordClass=ADV.pron.def;


# ad B.14 (ADV.pron.indef): pronominální adverbia; ve zprávě tabulka 4 na str. 11
if Coref
kdy -> 	trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
odkdy -> 	trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
dokdy -> 	trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
dokud -> 	trlemma=kdy, # myslí se příslovce, nikoli spojka podřadicí (její uzel bude schovaný)
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
někdy -> 	trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
kdysi -> 	trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
kdykoli,kdykoliv -> trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
ledakdy,leckdy,ledaskdy -> trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF4;
málokdy,sotvakdy,zřídkakdy,všelikdy,nevímkdy,kdovíkdy,bůhvíkdy,čertvíkdy -> trlemma=kdy, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíkdy i kdoví kdy)
         	WordClass=ADV.pron.indef,
	IndefType=INDEF6;
if notCoref
kdy,kdypak,kdyže -> trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
odkdy -> trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
dokdy -> trlemma=kdy,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
dokud -> trlemma=kdy, # myslí se příslovce, nikoli spojka podřadicí (její uzel schován)
	WordClass=ADV.pron.indef,
	IndefType=INTER;
nikdy -> 	trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
vždy,vždycky -> trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=TOTAL1;
navždy, navždycky -> trlemma=kdy,
         	WordClass=ADV.pron.indef,
	IndefType=TOTAL1;
if Coref
kde -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
odkud -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
kudy -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if Coref
kam -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
někde -> 	trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
odněkud -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
někudy -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
někam -> 	trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
kdesi -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
odkudsi -> trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
kudysi -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
kamsi -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
kdekoli,kdekoliv -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
odkudkoli,odkudkoliv -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
kudykoli,kudykoliv -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
kamkoli,kamkoliv -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
ledakde,leckde,ledaskde,leckdes -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF4;
málokde,sotvakde,zřídkakde,všelikde,nevímkde,kdovíkde,bůhvíkde,čertvíkde -> trlemma=kde, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíkde i kdoví kde)
         	WordClass=ADV.pron.indef,
	IndefType=INDEF6;
if notCoref
kde,kdepak,kdeže -> trlemma=kde, # pozor: ne každé "kdeže" je 
	# adverbium - to by však mělo být v morfolog.tagu (?)
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
odkud -> trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
kudy -> 	trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
if notCoref
kam,kampak,kamže -> trlemma=kde,
	WordClass=ADV.pron.indef,
	IndefType=INTER;
nikde -> 	trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
odnikud -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
nikudy -> 	trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
nikam -> 	trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
všude,všade -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=TOTAL1;
odevšad,odevšud -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=TOTAL1;
všudy,všady -> trlemma=kde,
         	WordClass=ADV.pron.indef,
	IndefType=TOTAL1;
if Coref
jak -> 	trlemma=jak,
	WordClass=ADV.pron.indef,
	IndefType=RELAT;
nějak -> 	trlemma=jak,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF1;
jaksi -> 	trlemma=jak,
	WordClass=ADV.pron.indef,
	IndefType=INDEF2;
jakkoli,jakkoliv -> trlemma=jak,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF3;
ledajak,lecjak,ledasjak -> trlemma=jak,
         	WordClass=ADV.pron.indef,
	IndefType=INDEF4;
všelijak,nevímjak,kdovíjak,bůhvíjak,čertvíjak -> trlemma=jak, 
	# variant mrlemmatu může být ještě asi víc, navíc se některé typy dají psát 
	# několikerým způsobem (např. kdovíjak i kdoví jak)
         	WordClass=ADV.pron.indef,
	IndefType=INDEF6;
if notCoref
jak,jakpak,jakže -> trlemma=jak, # pozor: možná ne všechna "jakže" jsou 
	# adverbia - to by však mělo být v morfolog.tagu (?)
	WordClass=ADV.pron.indef,
	IndefType=INTER;
nijak -> 	trlemma=jak,
         	WordClass=ADV.pron.indef,
	IndefType=NEGAT; 
if Coref
proč -> 	trlemma=proč,
         	WordClass=ADV.pron.indef,
	IndefType=RELAT;
if notCoref
proč,pročpak -> trlemma=proč,
         	WordClass=ADV.pron.indef,
	IndefType=INTER;


# ad B.15.: iterativní slovesa (s iterativní příponou; zatím pouze slovesa, obsažená v treebanku) - jejich 
# trlemma se převede na trlemma odpovídajícího slovesa neiterativního
bydlívat -> trlemma=bydlit, # možná trlemma "bydlet" - podívat se, zda je v treebanku jen jedno nebo obojí 
	Iterativeness=IT1;
bývat -> 	trlemma=být,
	Iterativeness=IT1;
bývávat -> trlemma=být, # je to iterativum "druhého stupně", ale asi se to nebude rozlišovat
	Iterativeness=IT1;
čítávat -> 	trlemma=číst,
	Iterativeness=IT1;
hrávat -> 	trlemma=hrát,
	Iterativeness=IT1;
jezdívat -> trlemma=jezdit,
	Iterativeness=IT1;
končívat -> trlemma=končit,
	Iterativeness=IT1;
mívat -> 	trlemma=mít,
	Iterativeness=IT1;
psávat -> 	trlemma=psát,
	Iterativeness=IT1;
říkávat -> 	trlemma=říkat,
	Iterativeness=IT1;
sedávat -> trlemma=sedat,
	Iterativeness=IT1;
slýchávat -> trlemma=slyšet, # nejdřív jsem myslela "slýchat", ale to samotné je už iterativum (SSČ)
	Iterativeness=IT1;


};


$configtext =~s/#.+?\n//g;
$configtext =~s/if\s+(\S+)/if\($1\)/sxmg; # ?
$configtext =~s/\s+//smxg;
$configtext =~s/wordclass/sempos/ig;
$configtext =~s/trlemma/t_lemma/ig;
$configtext=~s/,[^a-zA-Z0-9_]+/,/gsxm;

#if (not $configtext=~/\s/) {
#  print STDERR "Neni zadna mezera v :   |$configtext|\n";
#  exit;
#}


foreach my $commandline (split ";",lc($configtext)) {
    #  print "commandline: >>$commandline<<\n";
    my $type;

    if ($commandline=~/^([a-z,0-9,\,]+):((([a-z,0-9,.])+)(,([a-z,0-9,.])+)*)$/) { # possible values
        # uz neni potreba, bylo to tam jen kvuli upravam hlavicek ve fs:
        #     my $attrname=$1;
        #     my $values=$2;
        #     $values=~s/,/\|/g;

        #     if ($attrname eq "sempos") {
        #       while ($values=~s/^(.+\|)?(v|(n|adj|adv)\.)/$1sem$2/) {
        #       }				# pridat 'sem' pred hodnoty wordclasu
        #       $attrname="g_$attrname";
        #     }

        #     elsif ($attrname=~/gender|number|politeness|person/) {
        #       $values="$values|inher|nr|nil";
        #       $attrname="g_$attrname";
        #     }

        #     elsif ($attrname ne "sentmod") {
        #       $values="$values|nr|nil";
        #       $attrname="g_$attrname";
        #     }

        $type='possible values of attribute';
    } elsif ($commandline=~/^([a-z,0-9,\.]+)\=\>(((([a-z,0-9,.])+)?(,([a-z,0-9,.])+)*))$/) { # atributy u wordclassu
        my $sempos=$1;
        my @grams=split ",",$2;

        if (@grams) {
            foreach (@grams) {
                $applicable_gram{$sempos}{$_}=1;
                $all_applicable_grams{$_}=1;
            }
        } else {
            %{$applicable_gram{$sempos}}=();
            $all_applicable_grams{$_}=1;
        }

        $type='attributes relevant for given wordclass';
    } elsif ($commandline=~/^(if\((\S+)\))?([^-()]+)\-\>(([a-z,0-9,_]+=[^,]+,?)*)$/) { # co vyplyva primo z trlemmatu
        my $premise = $2;
        if ($premise and not $premise{$premise}) {
            if ($report) {
                print "Unknown premise '$premise' , line $commandline \n";
            }
        }
        my $lemmas=$3;
        my $attribs=$4;
        foreach my $l (split ",",$lemmas) {
            $t_lemma2attribs{$l}{$premise}=$attribs;
            $origrule{$l}{$premise}=$commandline;
        }
        $type="trlemma consequences($2)";
    } elsif ($commandline=~/^\((\S+)\)$/) { # deklarace moznych premis
        $premise{$1}=1;
        $type='premise declaration';
    }
    ;

    if ($type) {
        #    print "$commandline\n$type\n\n"
    } else {
        if ($report or 1) {
            print "$commandline\nUnrecognized line in the config file:\n|$commandline|\n";
        }
    }
}



1;
