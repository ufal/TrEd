
# -*- perl -*-
# This script is an attempt to automatically find possible coreferents
# in TGTS structures for Czech.
# contributed to TrEd by Oliver Culo in 12/2003

# Completely substituted by Zdenek Zabokrtsky'code in 4/2004

package ACAP;


# listst of control verbs

my $control_ADDR='(bránit|dát|donutit|dopomoci|doporuèit|doporuèovat|dovolit|dovolovat|motivovat|naøídit|nauèit|navrhnout|navrhovat|nutit|podaøit_se|pomáhat|pomoci|povìøit|povolit|povolovat|po¾adovat|pøedepsat|pøikázat|pøimìt|pøinutit|staèit|stát|ukládat|ulo¾it|umo¾nit|umo¾òovat|urèit|vypomoci|zabránit|zabraòovat|zakázat|zakazovat|zapovídat|zavazovat|zmocnit|znemo¾nit|znemo¾òovat)';

my $control_PAT='(bavit|být|donutit|nauèit|nechat|nechávat|nutit|oprávnit|osvìdèovat_se|podaøit_se|pøipravit|sna¾it_se|spatøit|staèit|¹kodit|unavovat|vadit|vidìt|vyplatit_se|zbýt|zbývat)';

my $control_BEN='(být|bývat|jít|lze|odmítat|oznaèit|pova¾ovat|sna¾it_se|stát|uznat|vyplatit_se|zdát_se|znamenat)';

my $control_ACT='(bát_se|cítit_se|èasit|daøit_se|dát|dát|dát_se|dávat|dojít|dokázat|dostat|dovést|dovolit_si|dovolovat_si|dozvìdìt_se|hodlat|hrozit|chodit|chtít|chtít_se|chystat_se|jet|jevit_se|jezdit|klást|koukat|mínit|mít|moci|naklonit|namáhat_se|napadnout|nauèit_se|nechat_se|nechávat|nechávat_se|odejít|odhodlat|odhodlat_se|odlétat|odmítat|odmítnout|odnauèit_se|odvá¾it_se|opomenout|oprávnit|ostýchat_se|plánovat|podaøit_se|pokou¹et_se|pokusit|pokusit_se|pomáhat|potøebovat|pova¾ovat|povést_se|pøát_si|pøestat|pøestávat|pøicházet|pøijet|pøijít|pøijít_si|pøijí¾dìt|pøipravit|pøislíbit|pøíslu¹et|rozhodnout|rozhodnout_se|rozmyslit_si|sna¾it_se|spìchat|stihnout|svést|tou¾it|troufat_si|troufnout_si|uèit_se|ukázat_se|ukazovat_se|umìt|usilovat|uznat|váhat|vìdìt|vyhýbat_se|vytknout_si|zaèínat|zaèít|zakázat|zapomenout|zapomínat|zaslou¾it_si|zatou¾it|zavázat_se|zbýt|zkou¹et|zkusit|znamenat|znemo¾òovat|zùstat|zùstávat|zvládnout|zvyknout_si)';

# ------------------------------------------------------------------------------
# --------  function for automatic assignment of grammatical coreference -------

sub autoAssignCorefs ($) {

  my $node=shift || $this;
  return unless ($node->parent and $node->parent->parent);
  my $parent=$node->parent;
  my $grandpa=$parent->parent;
  my ($lparent)=(PDT::GetFather_TR($node));
  my $antec;

  #  -------------------- gramaticka kontrola -------------------------------
  if ($node->{trlemma} eq '&Cor;' and $parent->{tag}=~/^Vf/ and $grandpa->{tag}=~/^V/) {
    if ($grandpa->{trlemma}=~/^$control_BEN$/) {
      ($antec)=(grep {$_->{func} eq "BEN"} $grandpa->children);
    }
    if (not $antec and $grandpa->{trlemma}=~/^$control_ADDR$/) {
      ($antec)=(grep {$_->{func} eq "ADDR"} $grandpa->children);
    }
    if (not $antec  and $grandpa->{trlemma}=~/^$control_ACT$/) {
      ($antec)=(grep {$_->{func} eq "ACT"} $grandpa->children);
    }
  }

  # ------------------- zvratna zajmena -------------------
  elsif ($node->{trlemma} eq "se" and $node->{func} ne "DPHR") {
    my $par=$node;
    while ($par->parent) {
      my $child=$par;
      $par=$par->parent;
      my @children= PDT::GetChildren_TR($par);
      my ($act)= grep {$_->{afun} eq "Sb" and $_ ne $child and $_ ne $node} @children;
      if (not $act) {($act)= grep {$_->{func} eq "ACT" and $_ ne $child and $_ ne $node} @children; }
      if ($act) {
	if (PDT::is_member_TR($act)) {$act=$act->parent}
	$antec=$act;
	last;
      }
    }
  }

 # -------- vztazne vedlejsi vety
 elsif ($node->{trlemma}=~/^(který|jaký|jen¾|kdy|kde|co|kdo)$/ and $lparent
	and $lparent->{tag}=~/^V/ and $lparent->{func} eq "RSTR") {
   my ($lgrandpa)=(PDT::GetFather_TR($lparent));
   if ($lgrandpa and $lgrandpa->{tag}=~/^[PN]/) {
     my %path_to_root;
     my $n=$node;
     while ($n->parent) {
       $path_to_root{$n}=1;
       $n=$n->parent
     };
     my $n=$lgrandpa;
     while ($n->parent) {
       if ($path_to_root{$n}) {$antec=$n;last}
       $n=$n->parent;
     }
   }
 }

 # -------- vztazne vedlejsi vety s privlastnovacim vztaznym zajmenem (clovek, v jehoz dome...)
 elsif ($node->{trlemma}=~/^(jen¾)$/ and $lparent and $lparent->{tag}=~/^N/) {
   my ($lgrandpa)=(PDT::GetFather_TR($lparent));
   if ($lgrandpa
       and $lgrandpa->{func} eq "RSTR"
       and $lgrandpa->{tag}=~/^V/
      ) {
     my ($lggrandpa)=(PDT::GetFather_TR($lgrandpa));
     if ($lggrandpa and $lggrandpa->{tag}=~/^[PN]/) {
       my %path_to_root;
       my $n=$node;
       while ($n->parent) {
	 $path_to_root{$n}=1;
	 $n=$n->parent
       };
       my $n=$lggrandpa;
       while ($n->parent) {
	 if ($path_to_root{$n}) {$antec=$n;last}
	 $n=$n->parent;
       }
     }
   }
 }

  # ------------------ jmenne doplnky ve shode se subjektem -------------------------
  elsif ($node->{func} eq "COMPL" and $node->{tag}=~/^(AC|((NN|PL|AA|C[rl])..1))/) {
    my ($parent)=(PDT::GetFather_TR($node));
    my @children= PDT::GetChildren_TR($parent);
    my ($act)= grep {$_->{afun} eq "Sb" and $_ ne $child and $_ ne $node} @children;
    if (not $act) {
	($act)= grep {$_->{func} eq "ACT" and $_ ne $child and $_ ne $node} @children;
      }
    if ($act) {
      if (PDT::is_member_TR($act)) {$act=$act->parent}
      $antec=$act;
    }
  }

  # ------------------ jmenne doplnky ve shode s objektem -------------------------
  elsif ($node->{func} eq "COMPL" and $node->{tag}=~/^(NN|AA)..4/) {
    my ($parent)=(PDT::GetFather_TR($node));
    my @children= PDT::GetChildren_TR($parent);
    my ($obj)= grep {$_->{tag}=~/^.[^7]..4/ and $_ ne $child and $_ ne $node} @children;
    if ($obj) {
      if (PDT::is_member_TR($obj)) {$obj=$obj->parent}
      $antec=$obj;
    }
  }

  if ($antec) {
    my $antecid=$antec->{TID} || $antec->{AID};
    return ($antecid,'autogrammatical')
  }  else {
    return undef
  }
}

# ------------------------------------------------------------------------------
# ----------- function for detecting coreference `candidates' ------------------ 

sub corefCandidate {
  my $node=shift || $this;
  my $depth;
  my $x=$node; while ($x->parent) {$depth++;$x=$x->parent}
  my ($parent)=(PDT::GetFather_TR($node));
  return ($node->{func}!~/(ETHD|DPHR|INTF|EXT)/ and
	  (
	   $node->{trlemma}=~/^(Cor|\&Cor|\&Cor;|\&Rcp;|.?QCor.?|on|se)$/
	   or ($node->{trlemma}=~/^(ten|tentý¾|tý¾|tento|tenhle)$/ and
	       $node->{func}!~/(RSTR|DIFF)/
	       and not (grep {
		 $_->{sentord}==$node->{sentord}+2 and
		   ($_->{trlemma}=~/^(kdo|co|který|jaký|jak|jen¾)$/ or # ten, kdo...
		    $_->{tag}=~/^J,/) # to, ze....
		 } $root->descendants()
		       )
	      )
	   or ($node->{trlemma}=~/^(jen¾|jak|kdy|kam|kudy|kde|kdo|co|co¾|tenhle|odkud|odkdy)$/
	       and $node->{ord}>2
	       and not ($parent->{func}=~/(EFF|PAT)/ and $parent->{tag}=~/^V/)
	       and $depth>2
	      )
	   or ($node->{trlemma}=~/^(který|jaký)$/
	       and not $parent->{tag}=~/^N/
	       and $depth>2
	      )

	   or $node->{func}=~/^COMPL/
	  )
	 )
}

1;

