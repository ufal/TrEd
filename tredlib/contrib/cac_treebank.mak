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
	substr($tag,3,2)." = pozice ��d�c�ho slova";
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
3	'-'	NA	��d�c� slovo vlevo
3	'_'	NA	��d�c� slovo vlevo
4-5	o	NA	kolik slov vlevo/vpravo je slovo ��d�c� (u druh�ho a dal��ch se ud�v� ��slo �lenu nejbli���ho; stejn� se zachycuj� vztahy mezi �leny sdru�en�ho pojmenov�n� i v p��pad�, �e nejsou samost. syntaktick�mi �leny);vzd�lenosti men�� ne� deset se zapisuj� 01, 02, ..., 09
6	1	NA	koordinace (uv�d� se pouze u druh�ho a dal��ch �len� koordina�n� �ady)
1	2	NA	predik�t
2	21	NA	slovesn�
3	'+'	NA	��d�c� slovo vpravo
6	2	NA	sdru�en� pojmenov�n� determina�n� povahy
2	2	NA	spona
6	3	NA	koordinace uvnit� sdru�en�ho pojmenov�n�
2	23	NA	nom. ��st spon. pred.
6	4	NA	sdru�en� pojmenov�n� jin�
2	24	NA	nomin.
6	5	NA	sdru�en� pojmenov�n� v koordinaci s jin�m sdru�en�m pojmenov�n�m
2	5	NA	spona u jedno�l. v.
6	6	NA	dvojice spojkov� a p��slove�n�
1	3	NA	...
2	31	NA	atribut
6	9	NA	��d�c� v�raz elidov�n
2	32	NA	apozice
6	0	NA	��d�c� v�raz vy�azen
1	4	NA	...
2	41	NA	objekt
6	7	NA	???
2	42	NA	dopln�k
6	8	NA	???
1	5	NA	adverbi�le
2	51	NA	m�sta
2	52	NA	�asu
2	53	NA	zp�sobu
2	54	NA	p���iny
2	55	NA	p�vodu
2	56	NA	p�vodce
2	57	NA	v�sledku
1	6	NA	z�klad v�ty jedno�lenn�
2	61	NA	substantivn�
2	62	NA	adjektivn�
2	63	NA	citoslove�n�
2	64	NA	��sticov�
2	65	NA	vokativn�
2	66	NA	p��slove�en�
2	67	NA	infinitivn�
2	68	NA	slovesn�
2	69	NA	slovesn� jmenn�
2	60	NA	z�jmenn�
1	7	NA	p�ech. typ (s v�eobecn�m subjektem)
1	8	NA	samostatn� v�tn� �len
1	9	NA	parant�ze
EOF


@ORIGT_INFO =
  map { chomp; [split /\t/] }
  grep /\S/,
  split /\n/, <<'EOF';
1	1	slovn� druh	SUBSTANTIVUM
2	1	NA	nesporn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	8	NA	neskl.
8	4	spisovnost	zastaral�
2	2	NA	adj.
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	3	NA	zvrat.
8	5	spisovnost	nespis.
2	3	NA	z�jm.
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
8	6	spisovnost	v�pl�k. nespis.
2	4	NA	��sl.
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
8	7	spisovnost	v�pl�k.
2	5	NA	slov.
4	9	rod	nelze ur�it
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
2	6	NA	slov. zvr.
6	6	p�d	lok�l
2	7	NA	zkratka
6	7	p�d	instrument�l
2	9	NA	zkr. slovo
6	9	p�d	nelze ur�it
2	0	NA	vl. jm�no

1	2	slovn� druh	ADJEKTIVUM
2	22	NA	nesporn�
3	221	NA	jm. tvar
3	222	NA	jm. zvrat.
2	23	NA	z�jmenn�
3	231	NA	jm. tvar
3	232	NA	neur�it�
3	234	NA	ukazovac�
3	235	NA	t�zac�
3	236	NA	vzta�n�
3	237	NA	z�porn�
3	238	NA	p�ivl.
2	24	NA	��slovka
3	242	NA	�adov�
3	243	NA	druhov�
3	244	NA	n�sobn�
3	245	NA	neur�it�
2	25	NA	slovesn�
3	250	NA	zvratn�
3	251	NA	jmenn�
3	252	NA	jm. zvrat.
2	27	NA	jmenn� st�. rodu
2	29	NA	p�ivlast�ovac�
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
8	4	spisovnost	zastaral�
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
8	5	spisovnost	nespis.
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
7	2	stupe�	II.st.
8	6	spisovnost	v�pl�k. nespis.
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
7	3	stupe�	III.st
8	7	spisovnost	v�pl�k.
4	9	rod	nelze ur�it
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
7	8	stupe�	neskl.
6	6	p�d	lok�l
6	7	p�d	instrument�l
6	9	p�d	nelze ur�it

1	3	slovn� druh	Z�JMENO
2	1	NA	osobn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	1	tvar	krat��
8	4	spisovnost	zastaral�
2	2	NA	neur�it�
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	2	tvar	del��
8	5	spisovnost	nespis.
2	3	NA	zvratn�
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
8	6	spisovnost	v�pl�k. nespis.
2	4	NA	ukazovac�
4	4	rod	neutrum
5	9	��slo	nelze ur�it
6	4	p�d	akuzativ
8	7	spisovnost	v�pl�k.
2	5	NA	t�zac�
4	7	rod	bezrod�
6	5	p�d	vokativ
2	6	NA	vzta�n�
4	9	rod	nelze ur�it
6	6	p�d	lok�l
2	7	NA	z�porn�
6	7	p�d	instrument�l
6	9	p�d	nelze ur�it

1	4	slovn� druh	��SLOVKA
2	1	NA	z�kladn�
3	0	valence	bez p�edlo�ky
4	1	rod	m. �iv.
5	1	��slo	singul�r
6	1	p�d	nominativ
7	1	p�d	nom.
8	4	spisovnost	zastaral�
2	3	NA	druhov�
3	7	valence	s p�edlo�kou
4	2	rod	m. ne�.
5	2	��slo	plur�l
6	2	p�d	genitiv
7	2	p�d	gen.
8	5	spisovnost	nespis.
2	4	NA	n�sobn�
4	3	rod	fem.
5	3	��slo	du�l
6	3	p�d	dativ
7	3	p�d	dat.
8	6	spisovnost	v�pl�k. nespis.
2	5	NA	neur�it�
4	4	rod	neutrum
5	4	��slo	pomn.
6	4	p�d	akuzativ
7	4	p�d	akz.
8	7	spisovnost	v�pl�k.
2	6	NA	pod�ln�
4	7	rod	bezrod�
5	9	��slo	nelze ur�it
6	5	p�d	vokativ
7	5	p�d	vok.
4	8	rod	neskl.
6	6	p�d	lok�l
7	6	p�d	lok.
4	9	rod	nelze ur�it
6	7	p�d	instrument�l
7	7	p�d	ins.
6	9	p�d	nelze ur�it
7	9	p�d	nelze ur�it

1	5	slovn� druh	SLOVESO
2	1	NA	dokonav�
3	1	osoba ��slo	1.sg.
4	1	�as zp�sob	ind.pr�z.akt.
5	1	imperativ	imp.akt.
6	1	NA	jednosl.
7	1	jmenn� rod	m.�iv.
8	4	spisovnost	zastaral�
2	2	NA	nedokonav�
3	2	osoba ��slo	2.sg.
4	2	�as zp�sob	ind.pr�z.pas.
5	2	imperativ	imp.pas.
6	2	NA	v�cesl. nezvr.
7	2	jmenn� rod	m.ne�.
8	5	spisovnost	nespis.
2	3	NA	obojvid�
3	3	osoba ��slo	3.sg.
4	3	�as zp�sob	kond.pr�z.ak.
5	3	imperativ	kond.pf.akt.
6	7	NA	zvrat. neslo�.
7	3	jmenn� rod	fem.
8	6	spisovnost	v�pl�k. nespis.
3	4	osoba ��slo	1.pl.
4	4	�as zp�sob	kond.pr�z.ps.
5	4	imperativ	kond.pf.pas.
6	8	NA	zvrat. slo�.
7	4	jmenn� rod	neutr.
8	7	spisovnost	v�pl�k.
3	5	osoba ��slo	2.pl.
4	5	�as zp�sob	ind.pr�t.akt.
5	5	imperativ	p.sl. ``b�vati''
6	9	NA	pf.stav.p��t.
7	5	jmenn� rod	pl.m.�.
3	6	osoba ��slo	3.pl.
4	6	�as zp�sob	ind.pr�t.pas.
5	6	imperativ	part.pas.
6	0	NA	pf.stav.min.
7	6	jmenn� rod	pl.m.n.
3	7	osoba ��slo	inf.ak.
4	7	�as zp�sob	kond.min.akt.
5	7	imperativ	p�ech.p�.akt.
7	7	jmenn� rod	pl.fem.
3	8	osoba ��slo	inf.ps.
4	8	�as zp�sob	kond.min.pas.
5	8	imperativ	p�ech.p�.ps.
7	8	jmenn� rod	pl.neu.
3	9	osoba ��slo	neos.
4	9	�as zp�sob	fut.ind.akt.
5	9	imperativ	p�ech.min.ak.
7	9	jmenn� rod	nelze ur�it
4	0	�as zp�sob	fut.ind.pas.
5	0	imperativ	p�ech.min.ps.

1	6	slovn� druh	ADVERBIUM
2	6	NA	nesporn�
2	2	NA	predik.
4	2	stupe�	II. st.
8	4	spisovnost	zastaral�
2	3	NA	z�jmenn�
4	3	stupe�	III. st.
8	5	spisovnost	nespis.
2	4	NA	��seln�
3	4	NA	n�sobn�
8	6	spisovnost	v�pl�k. nespis.
3	6	NA	pod�ln�
8	7	spisovnost	v�pl�k.
3	5	NA	neur�it�
2	8	NA	spojovac� v�raz

1	7	slovn� druh	P�EDLO�KA
2	7	NA	vlastn�
3	2	p�d	s genitivem
8	4	spisovnost	zastaral�
2	8	NA	nevlastn�
3	3	p�d	s dativem
8	5	spisovnost	nespis.
3	4	p�d	s akuzativem
3	6	p�d	s lok�lem
3	7	p�d	s instrument�lem

1	8	slovn� druh	SPOJKA
2	1	NA	sou�ad�c�
8	4	spisovnost	zastaral�
2	2	NA	pod�ad�c�
8	5	spisovnost	nespis.
2	9	NA	jin� v�raz

1	9	slovn� druh	CITOSLOVCE
2	9	NA	nesporn�
8	4	spisovnost	zastaral�
2	1	NA	subst.
8	5	spisovnost	nespis.
2	2	NA	adj.
8	6	spisovnost	v�pl�k. nespis.
2	3	NA	z�jm.
8	7	spisovnost	v�pl�k.
2	5	NA	slov.
2	6	NA	adv.

1	000	slovn� druh	CIT�TOV� V�RAZY
1	0	slovn� druh	��STICE

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
