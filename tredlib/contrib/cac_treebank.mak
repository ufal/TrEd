# -*- cperl -*-
#encoding iso-8859-2

package AcademicTreebank;

use base qw(TredMacro);
import TredMacro;

#ifinclude <contrib/pdt_tags.mak>
#bind show_tag to Alt+t menu Describe PDT tag
sub show_tag {
  describe_tag($this->{tag});
  ChangingFile(0);
}

#bind show_x_origa to Alt+a menu Describe CAC syntactic-analytic tag
sub show_x_origa {
  describe_x_origa($this->{x_origa}) if $this->{x_origa} ne "";
  ChangingFile(0);
}

#bind show_x_origt to Alt+m menu Describe CAC morphological tag
sub show_x_origt {
  describe_x_origt($this->{x_origt}) if $this->{x_origt} ne "";
  ChangingFile(0);
}

#bind rebuild_cac_tree to Alt+r menu Rebuild CAC tree structure
sub rebuild_cac_tree {
  my @nodes = sort {$a->{ord} <=> $b->{ord}} $root->descendants;
  for (my $i=0; $i<@nodes;$i++) {
    my $n = $nodes[$i];
    if ($n->{x_origa} ne "") {
      my $plusminus = substr($n->{x_origa},2,1);
      my $delta = substr($n->{x_origa},3,2);
      my $p;
      if ($plusminus eq '+') {
	$p = $nodes[$i+$delta];
      } elsif ($plusminus eq '_' or $plusminus eq '-') {
	$p = $nodes[$i-$delta];
      }
      CutPaste($n,$p) if $p;
    } else {
      my $j = $i+1;
      while ($j<@nodes) {
	my $p = $nodes[$j];
	if ($p->{x_origt} ne "" and
	    substr($p->{x_origt},2,1) eq '7') {
	  CutPaste($n,$p);
	  last;
	}
	$j++
      }
    }
  }
}


sub do_edit_attr_hook {
  my ($atr,$node)=@_;
  print "$atr\n";
  if ($atr eq 'x_origa') {
    show_x_origa();
    return 'stop';
  } elsif ($atr eq 'x_origt') {
    show_x_origt();
    return 'stop';
  } elsif ($atr eq 'tag') {
    show_tag();
    return 'stop';
  }
  return 1;
}

sub describe_x_origa {
  my ($tag) = @_;
  my @sel;
  my @val = map {
    if ($_ == 4) {
      if (substr($tag,3,2)=~/\S/) {
	substr($tag,3,2)." = pozice øídícího slova";
      } else { () }
    } elsif ( $_ <= length($tag) ) {
      my $w = substr($tag,0,$_);
      my $v = substr($tag,$_-1,1);
      if (exists $ORIGA_INFO{"$_;$w"}) {
	"$v  = ".$ORIGA_INFO{"$_;$w"}
      } elsif (exists $ORIGA_INFO{"$_;$v"}) {
	"$v  = ".$ORIGA_INFO{"$_;$v"}
      } elsif ($v eq " ") {
	()
      } else {
	"$v  = UNKNOWN"
      }
    } else { () }
  } 1,2,3,4,6;
  listQuery("$tag - detailed info",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}

sub get_x_origt_description {
  my ($tag) = @_;
  if (exists $ORIGT_INFO{"$tag;desc"}) {
    return "$tag = ".$ORIGT_INFO{"$tag;desc"};
  } else {
    my $POS=substr($tag,0,1);
    if (exists $ORIGT_INFO{"$POS;desc"}) {
      my @v = ("$POS = ".$ORIGT_INFO{"$POS;desc"});
      for my $pos (2..length($tag)) {
	my $v=substr($tag,$pos-1,1);
	my $w=substr($tag,0,$pos);
	if (exists $ORIGT_INFO{"$POS;$pos;$w;desc"}) {
	  push @v,"$v = ".$ORIGT_INFO{"$POS;$pos;$w;desc"};
	} elsif (exists $ORIGT_INFO{"$POS;$pos;$v;type"}) {
	  push @v,"$v = ".$ORIGT_INFO{"$POS;$pos;$v;desc"};
	} elsif ($v ne ' ') {
	  push @v,"$v = UNKNOWN";
	}
      }
      return @v;
    } else {
      return "$POS = UNKNOWN";
    }
  }
}

sub describe_x_origt {
  my ($tag) = @_;
  my @sel;
  my @val = get_x_origt_description($tag);
  listQuery("$tag - detailed info",
	    'browse',
	    \@val,
	    \@sel);
  ChangingFile(0);
  return;
}

%ORIGA_INFO = map { my ($pos, $val, $type, $desc) = split /\t/,$_,4;
		    $val=$1 if ($val =~ /'(.)'/);
		     ("$pos;$val" => $desc) } split /\n/, <<'EOF';
1	1	NA	subjekt
3	'-'	NA	øídící slovo vlevo
3	'_'	NA	øídící slovo vlevo
4-5	o	NA	kolik slov vlevo/vpravo je slovo øídící (u druhého a dal¹ích se udává èíslo èlenu nejbli¾¹ího; stejnì se zachycují vztahy mezi èleny sdru¾eného pojmenování i v pøípadì, ¾e nejsou samost. syntaktickými èleny);vzdálenosti men¹í ne¾ deset se zapisují 01, 02, ..., 09
6	1	NA	koordinace (uvádí se pouze u druhého a dal¹ích èlenù koordinaèní øady)
1	2	NA	predikát
2	21	NA	slovesný
3	'+'	NA	øídící slovo vpravo
6	2	NA	sdru¾ené pojmenování determinaèní povahy
2	2	NA	spona
6	3	NA	koordinace uvnitø sdru¾eného pojmenování
2	23	NA	nom. èást spon. pred.
6	4	NA	sdru¾ené pojmenování jiné
2	24	NA	nomin.
6	5	NA	sdru¾ené pojmenování v koordinaci s jiným sdru¾eným pojmenováním
2	5	NA	spona u jednoèl. v.
6	6	NA	dvojice spojkové a pøísloveèné
1	3	NA	...
2	31	NA	atribut
6	9	NA	øídící výraz elidován
2	32	NA	apozice
6	0	NA	øídící výraz vyøazen
1	4	NA	...
2	41	NA	objekt
6	7	NA	???
2	42	NA	doplnìk
6	8	NA	???
1	5	NA	adverbiále
2	51	NA	místa
2	52	NA	èasu
2	53	NA	zpùsobu
2	54	NA	pøíèiny
2	55	NA	pùvodu
2	56	NA	pùvodce
2	57	NA	výsledku
1	6	NA	základ vìty jednoèlenné
2	61	NA	substantivní
2	62	NA	adjektivní
2	63	NA	citosloveèné
2	64	NA	èásticové
2	65	NA	vokativní
2	66	NA	pøísloveèené
2	67	NA	infinitivní
2	68	NA	slovesné
2	69	NA	slovesnì jmenné
2	60	NA	zájmenné
1	7	NA	pøech. typ (s v¹eobecným subjektem)
1	8	NA	samostatný vìtný èlen
1	9	NA	parantéze
EOF


@ORIGT_INFO =
  map { chomp; [split /\t/] }
  grep /\S/,
  split /\n/, <<'EOF';
1	1	slovní druh	SUBSTANTIVUM
2	1	NA	nesporné
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	8	NA	neskl.
8	4	spisovnost	zastaralé
2	2	NA	adj.
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	3	NA	zvrat.
8	5	spisovnost	nespis.
2	3	NA	zájm.
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
8	6	spisovnost	výplòk. nespis.
2	4	NA	èísl.
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
8	7	spisovnost	výplòk.
2	5	NA	slov.
4	9	rod	nelze urèit
5	9	èíslo	nelze urèit
6	5	pád	vokativ
2	6	NA	slov. zvr.
6	6	pád	lokál
2	7	NA	zkratka
6	7	pád	instrumentál
2	9	NA	zkr. slovo
6	9	pád	nelze urèit
2	0	NA	vl. jméno

1	2	slovní druh	ADJEKTIVUM
2	22	NA	nesporné
3	221	NA	jm. tvar
3	222	NA	jm. zvrat.
2	23	NA	zájmenné
3	231	NA	jm. tvar
3	232	NA	neurèité
3	234	NA	ukazovací
3	235	NA	tázací
3	236	NA	vzta¾né
3	237	NA	záporné
3	238	NA	pøivl.
2	24	NA	èíslovka
3	242	NA	øadová
3	243	NA	druhová
3	244	NA	násobná
3	245	NA	neurèitá
2	25	NA	slovesné
3	250	NA	zvratné
3	251	NA	jmenné
3	252	NA	jm. zvrat.
2	27	NA	jmenné stø. rodu
2	29	NA	pøivlastòovací
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
8	4	spisovnost	zastaralé
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
8	5	spisovnost	nespis.
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
7	2	stupeò	II.st.
8	6	spisovnost	výplòk. nespis.
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
7	3	stupeò	III.st
8	7	spisovnost	výplòk.
4	9	rod	nelze urèit
5	9	èíslo	nelze urèit
6	5	pád	vokativ
7	8	stupeò	neskl.
6	6	pád	lokál
6	7	pád	instrumentál
6	9	pád	nelze urèit

1	3	slovní druh	ZÁJMENO
2	1	NA	osobní
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	1	tvar	krat¹í
8	4	spisovnost	zastaralé
2	2	NA	neurèité
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	2	tvar	del¹í
8	5	spisovnost	nespis.
2	3	NA	zvratné
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
8	6	spisovnost	výplòk. nespis.
2	4	NA	ukazovací
4	4	rod	neutrum
5	9	èíslo	nelze urèit
6	4	pád	akuzativ
8	7	spisovnost	výplòk.
2	5	NA	tázací
4	7	rod	bezrodé
6	5	pád	vokativ
2	6	NA	vzta¾né
4	9	rod	nelze urèit
6	6	pád	lokál
2	7	NA	záporné
6	7	pád	instrumentál
6	9	pád	nelze urèit

1	4	slovní druh	ÈÍSLOVKA
2	1	NA	základní
3	0	valence	bez pøedlo¾ky
4	1	rod	m. ¾iv.
5	1	èíslo	singulár
6	1	pád	nominativ
7	1	pád	nom.
8	4	spisovnost	zastaralé
2	3	NA	druhová
3	7	valence	s pøedlo¾kou
4	2	rod	m. ne¾.
5	2	èíslo	plurál
6	2	pád	genitiv
7	2	pád	gen.
8	5	spisovnost	nespis.
2	4	NA	násobná
4	3	rod	fem.
5	3	èíslo	duál
6	3	pád	dativ
7	3	pád	dat.
8	6	spisovnost	výplòk. nespis.
2	5	NA	neurèitá
4	4	rod	neutrum
5	4	èíslo	pomn.
6	4	pád	akuzativ
7	4	pád	akz.
8	7	spisovnost	výplòk.
2	6	NA	podílná
4	7	rod	bezrodé
5	9	èíslo	nelze urèit
6	5	pád	vokativ
7	5	pád	vok.
4	8	rod	neskl.
6	6	pád	lokál
7	6	pád	lok.
4	9	rod	nelze urèit
6	7	pád	instrumentál
7	7	pád	ins.
6	9	pád	nelze urèit
7	9	pád	nelze urèit

1	5	slovní druh	SLOVESO
2	1	NA	dokonavé
3	1	osoba èíslo	1.sg.
4	1	èas zpùsob	ind.préz.akt.
5	1	imperativ	imp.akt.
6	1	NA	jednosl.
7	1	jmenný rod	m.¾iv.
8	4	spisovnost	zastaralé
2	2	NA	nedokonavé
3	2	osoba èíslo	2.sg.
4	2	èas zpùsob	ind.préz.pas.
5	2	imperativ	imp.pas.
6	2	NA	vícesl. nezvr.
7	2	jmenný rod	m.ne¾.
8	5	spisovnost	nespis.
2	3	NA	obojvidé
3	3	osoba èíslo	3.sg.
4	3	èas zpùsob	kond.préz.ak.
5	3	imperativ	kond.pf.akt.
6	7	NA	zvrat. neslo¾.
7	3	jmenný rod	fem.
8	6	spisovnost	výplòk. nespis.
3	4	osoba èíslo	1.pl.
4	4	èas zpùsob	kond.préz.ps.
5	4	imperativ	kond.pf.pas.
6	8	NA	zvrat. slo¾.
7	4	jmenný rod	neutr.
8	7	spisovnost	výplòk.
3	5	osoba èíslo	2.pl.
4	5	èas zpùsob	ind.prét.akt.
5	5	imperativ	p.sl. ``bývati''
6	9	NA	pf.stav.pøít.
7	5	jmenný rod	pl.m.¾.
3	6	osoba èíslo	3.pl.
4	6	èas zpùsob	ind.prét.pas.
5	6	imperativ	part.pas.
6	0	NA	pf.stav.min.
7	6	jmenný rod	pl.m.n.
3	7	osoba èíslo	inf.ak.
4	7	èas zpùsob	kond.min.akt.
5	7	imperativ	pøech.pø.akt.
7	7	jmenný rod	pl.fem.
3	8	osoba èíslo	inf.ps.
4	8	èas zpùsob	kond.min.pas.
5	8	imperativ	pøech.pø.ps.
7	8	jmenný rod	pl.neu.
3	9	osoba èíslo	neos.
4	9	èas zpùsob	fut.ind.akt.
5	9	imperativ	pøech.min.ak.
7	9	jmenný rod	nelze urèit
4	0	èas zpùsob	fut.ind.pas.
5	0	imperativ	pøech.min.ps.

1	6	slovní druh	ADVERBIUM
2	6	NA	nesporné
2	2	NA	predik.
4	2	stupeò	II. st.
8	4	spisovnost	zastaralé
2	3	NA	zájmenné
4	3	stupeò	III. st.
8	5	spisovnost	nespis.
2	4	NA	èíselné
3	4	NA	násobné
8	6	spisovnost	výplòk. nespis.
3	6	NA	podílné
8	7	spisovnost	výplòk.
3	5	NA	neurèité
2	8	NA	spojovací výraz

1	7	slovní druh	PØEDLO®KA
2	7	NA	vlastní
3	2	pád	s genitivem
8	4	spisovnost	zastaralé
2	8	NA	nevlastní
3	3	pád	s dativem
8	5	spisovnost	nespis.
3	4	pád	s akuzativem
3	6	pád	s lokálem
3	7	pád	s instrumentálem

1	8	slovní druh	SPOJKA
2	1	NA	souøadící
8	4	spisovnost	zastaralé
2	2	NA	podøadící
8	5	spisovnost	nespis.
2	9	NA	jiný výraz

1	9	slovní druh	CITOSLOVCE
2	9	NA	nesporné
8	4	spisovnost	zastaralé
2	1	NA	subst.
8	5	spisovnost	nespis.
2	2	NA	adj.
8	6	spisovnost	výplòk. nespis.
2	3	NA	zájm.
8	7	spisovnost	výplòk.
2	5	NA	slov.
2	6	NA	adv.

1	000	slovní druh	CITÁTOVÉ VÝRAZY
1	0	slovní druh	ÈÁSTICE

EOF

%ORIGT_INFO=();
do {{
  my $last1=undef;
  foreach (@ORIGT_INFO) {
    my ($pos, $val, $type, $desc)=@$_;
    if ($pos==1) {
      $last1=$val;
      $ORIGT_INFO{"$val;type"}=$type;
      $ORIGT_INFO{"$val;desc"}=$desc;
    } else {
      $ORIGT_INFO{"$last1;$pos;$val;type"} = $type;
      $ORIGT_INFO{"$last1;$pos;$val;desc"} = $desc;
    }
  }
}};
