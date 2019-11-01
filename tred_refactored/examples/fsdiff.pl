#!/usr/bin/perl
#
#
# Usage:
# fsdiff.pl files ...
#
# fsdiff.pl -h for help
#
# Compares two or more FS files annotated on TG level.

setlocale(LC_ALL,"cs_CZ");
setlocale(LANG,"czech");

use Getopt::Std;
getopts('andflmesSqQRDKA:M:owh');

$usenames=0;
$hide=1;
if ($opt_h) {
  print <<EOL;
  Find differences in fs-files annotated on TG-level

  Usage: fsdiff.pl [options] file1, file2, ...

  Options:
     -a   diff all nodes (i.e. hidden too)
     -n   guess and use names of anotators instead of filenames
     -d   check dependency only
     -f   check func only
     -l   check lemma only
     -m   check missing only
     -e   exclude differences in lemma
     -s   print summary information at the end
     -S   print summary information for every tree
     -q   be quiet
     -Q   do not print individual differences
     -R   build TR tree from CSTS
     -o   check only attributes listed in -A
     -w   print relevant part of the sentence below each node
     -K   compute kappa measure
     -h   print this help screen
     -D   debug

     -A <atr1,atr2,...> check also attributes atr1, atr2, etc.
     -M <xy>            use lemma and tag from <MD src="xy">
EOL
  exit 0;
};

use FindBin;
my $rb=$FindBin::RealBin;
if (exists $ENV{TREDHOME}) {
  $libDir=$ENV{TREDHOME};
} elsif (-d "$rb/tredlib") {
  $libDir="$rb/tredlib";
} elsif (-d "$rb/../lib/tredlib") {
  $libDir="$rb/../lib/tredlib";
} elsif (-d "$rb/../lib/tred") {
  $libDir="$rb/../lib/tred";
} elsif (-d "$rb/../tredlib") {
  $libDir="$rb/../tredlib";
} elsif (-d "$rb/../../lib/tredlib") {
  $libDir="$rb/../../lib/tredlib";
} elsif (-d "$rb/../../lib/tred") {
  $libDir="$rb/../../lib/tred";
}

print STDERR "Trying $libDir\n" if ($libDir and !$opt_q);
unshift @INC,"$libDir";

require Treex::PML;
import Treex::PML;
import Treex::PML qw(&UseBackends);

use locale;
use POSIX qw(locale_h);

use integer;

sub is_coord {
  my ($node)=@_;
  return $node->{func} =~ /^(?:CONJ|DISJ|GRAD|ADVS|CSQ|REAS)$/;
}

sub is_apos {
  my ($node)=@_;
  return $node->{func} eq 'APPS';
}

sub expand_coord_apos {
  my ($node,$keep)=@_;
  if (is_coord($node)) {
    return (($keep ? $node : ()),map { expand_coord_apos($_) }
      grep { $_->{memberof} eq 'CO' or $_->{reltype} eq 'CO' }
	$node->children());
  } elsif (is_apos($node)) {
    return (($keep ? $node : ()), map { expand_coord_apos($_) }
      grep { $_->{memberof} eq 'CO' or $_->{reltype} eq 'CO' }
	$node->children());
  } else {
    return $node;
  }
}

sub align_by_id {
  my ($attr,$trees,$G,@names)=@_;


  # $G is a reference to alignment hash
  # structure: $G->{ ord }->{ file } == node_from_file_at_ord

  # create groups of corresponding old nodes, i.e. nodes not created
  # by anotators
  my ($ord, $node, $tree);

  foreach my $f (sort @names) {
    # store trees to compare to $f-indexed hash
    $tree=$trees->{$f};
    if ($tree) {
      $node=$tree->following;
      while ($node) {
	$ord=$node->{$attr};
	if ($ord !~ /\./) {
	  if (! exists $G->{$ord}) {
	    $G->{$ord} = { };
	  }
	  $G->{$ord}{$f}=$node;
	  $node->{_group_}=$ord;
	}
	$node=$node->following();
      }
    }
  }
  print STDERR "Done.\n" unless ($opt_q);
}

sub align_other {
  my ($trees,$G,@names)=@_;
  # $trees: a hash reference of trees to align
  # $G is a reference to alignment hash
  # structure: $G->{ grpid }->{ file } == node_from_file_at_ord

  # create groups of nodes added by anotators that correspond
  # dunno how to make it easily, so I'm working hard (looking for func)

  # a node is aligned here to the first unaligned son of the aligned parent
  # with the same func :) (hard to understand? look at the code bellow)

  my $grpid=0;
  my ($i_name,$j_name,$node,$grp);
  for ($i=0; $i < @names; $i++) {
    $i_name=$names[$i];
    next unless ($trees->{$i_name});
    $node=$trees->{$i_name}->following();
  NODE: while ($node) {
      unless (exists($node->{_group_}) and $node->{_group_} ne "") {
	$grp="N$grpid";
	$grpid++;
	if (! exists $G->{$grp}) {
	  $G->{$grp} = { };
	}
	$G->{$grp}{$i_name}=$node;
	$node->{_group_}=$grp;
	$parent_grp= $node->parent()->{_group_};
	for ($j=$i+1; $j < @names; $j++) {
	  $j_name=$names[$j];
	  if (exists ($G->{$parent_grp}{$j_name})) {
	    $son=$G->{$parent_grp}->{$j_name}->firstson();
	  SON: while ($son) {
	      if ((!exists($son->{_group_}) or $son->{_group_} eq "")
		  and ($son->{func} eq $node->{func})) {
		$son->{_group_}=$grp;
		$G->{$grp}->{$j_name}=$son;
		last SON;
	      }
	      $son=$son->rbrother();
	    }
	  }
	}
      }
      $node=$node->following();
    }
  }   # well, wasn't so difficult :)
}

UseBackends(qw(FS TrXMLBackend CSTS));
$opt_R && Csts2fs::setupTR();
$Treex::PML::Debug=$opt_D;

%bkmap=(
	fs => 'FS',
	csts => 'CSTS',
	trxml => 'TrXML'
);


if ($opt_A) {
  @userdefinedlist=(@userdefinedlist,split(/,/,$opt_A));
}

#$opt_q=1 if $opt_Q;


my @files;
if ($^O eq 'MSWin32') {
  @files=map glob, @ARGV;
} else {
  @files = @ARGV;
}

%alltrees=();
@allfiles=();

$filecount=scalar(@files);

my $eb=0;
my $ab=0;
my $zu=0;
my $ik=0;

foreach $f (@files) {
  $name=$f;
  $name="ZU".($zu?$zu+1:""),$zu++ if ($opt_n and $f=~/zu?\.fs/i);
  $name="EB".($eb?$eb+1:""),$eb++ if ($opt_n and $f=~/eb?\.fs/i);
  $name="AB".($ab?$ab+1:""),$ab++ if ($opt_n and $f=~/ab?\.fs/i);
  $name="IK".($ik?$ik+1:""),$ik++ if ($opt_n and $f=~/ik?\.fs/i);
  $names{$f}=$name;
}

@names=sort values %names;


sub max {
  ($a,$b)=@_;
  return $a<$b ? $b : $a;
}

sub Max {
  my $max=0;
  foreach (@_) {
    $max=$_ if $_>$max;
  }
  return $max;
}


# Stuff like file openning, reading, counting and optional hidden nodes pruning
foreach $f (@files) {
  $fileno++;
  print STDERR "Reading $f\t($fileno/$filecount)\n" unless $opt_q;
  my $fs = Treex::PML::Factory->createDocument($f,{encoding=>'iso-8859-2',
					      backends=>\@backends});
  $fs->lastTreeNo<0 && die "$f: empty or corrupt file!\n";

  foreach my $root ($fs->trees) {
    # count all nodes, visible nodes and nodes added on TR-layer
    $acount=0;
    $trcount=0;
    $newcount=0;
    my $node=$root;
    while($node) {
      if ($opt_M and $fs->FS->exists("lemmaMD_$opt_M")) {
	$node->{lemma}=$node->{"lemmaMD_$opt_M"} if ($node->{"lemmaMD_$opt_M"} ne "");
	$node->{tag}=$node->{"tagMD_$opt_M"} if ($node->{"tagMD_$opt_M"} ne "");
      }
      if ($fs->FS->isHidden($node)) {
	$acount++;
      } else {
	$trcount++;
	$acount++;
	$newcount++ if ($node->{ord}=~/\./);
      }
      $node=$node->following();
    }
    # store the information in $root
    $root->{acount}=$acount;
    $root->{trcount}=$trcount;
    $root->{newcount}=$newcount;
    unless ($opt_a) {
      # here we delete all hidden nodes (God bless 'em - or us? )
      $node=$root;
      while ($node) {
	if ($node->{TR} eq "hide") {
	  Cut($node);
	  $node=$root;
	  next;
	}
	$node=$node->following();
      }
    }
  }
  push @allfiles,$fs;
  $alltrees{$names{$f}}= $fs->treeList();
  print STDERR "$names{$f}: ",scalar(@{$alltrees{$names{$f}}})," trees\n" unless $opt_q;
}
print STDERR "Done.\n" unless ($opt_q);


$total=0;
%total=undef;
%tree_att_diff=undef;
$tree_dependency=0;
$total_dependency=0;
$total_restoration=0;
$tree_restoration=0;
$tree_cmp_attrs=0;
$total_cmp_attrs=0;
%restoration=map { $_ => 0 } 1..@names;
%dependency=map { $_ => 0 } 1..@names;
%value=map { $_ => 0 } 1..@names;

$n=0;
do {
  $any=0;
  $alldiffs=0;
  undef %T;
  undef %G;
  foreach $f (sort @names) {

    # store trees to compare to $f-indexed hash
    @trees=@{ $alltrees{$f} };
    $T{$f}=$trees[$n];
    if ($T{$f}) {
      unless ($opt_q) {
	print STDERR "\n*****************************************\n\n";
	print STDERR "Working on ",$trees[$n]->{"form"},"\n";
	print STDERR "Tree ",$n+1," has form ",$trees[$n]->{"form"},"\n";
      }
      $any=1;
    }
  }

  if ($any) {
    print "Comparing trees ",$trees[$n]->{'form'}," (",$n+1,"):\n" unless ($opt_Q);

    print STDERR "Creating groups for tree # $n (starting at $f)\n" unless ($opt_q);
    align_by_id('ord',\%T,\%G,@names);

    print STDERR "Crating groups for new nodes\n" unless ($opt_q);
    align_other(\%T,\%G,@names);

    print STDERR "Done.\n" unless ($opt_q);
    # Now have look on the groups:
    foreach $grp (sort { local ($A,$B);
			 $a=~/N?([0-9]+)/;
			 $A=$1;
			 $A+=1000*($a=~/^N/);
			 $b=~/N?([0-9]+)/;
			 $B=$1;
			 $B+=1000*($b=~/^N/);
			 $A <=> $B }
		  keys(%G)) {
      next if $grp eq "" ;
      $Gr=$G{$grp};
      $diffs=0;

      unless ($opt_l or $opt_d) {
	# check if all files have node in this group
	@grps=keys(%$Gr);
	$rep=$grps[0]."[".$Gr->{$grps[0]}->{"ord"}."]: ".
	  $Gr->{$grps[0]}->{"trlemma"}.".".$Gr->{$grps[0]}->{"func"};
	if (@grps != @names) {		
	  print "== $grp =============\n$rep\n" unless ($opt_Q or $diffs);
	  $diffs++;
	  $total_restoration++;
	  $tree_restoration++;
	  $restoration{max(scalar(@names)-scalar(keys %$Gr),scalar(keys %$Gr))}++;
	  if (2*@grps<@names) {
	    print "  only in: ", join(" ",keys %$Gr),"\n" unless ($opt_Q);
	  } else {
	    print "  not in:" unless ($opt_Q);
	    foreach $f (@names) {
	      print " $f" unless ($opt_Q or exists $Gr->{$f} );
	    }
	    print "\n" unless ($opt_Q);
	  }
	}
      }

      # check for (parent) structure differences but ignore changes,
      # if parents are alone, i.e. not associated in groups
      unless ($opt_l or $opt_m) {
	undef %valhash;
	$diff_them=0;
	foreach $f (keys %$Gr) {
	  if ($Gr->{$f}->parent()) {
	    $valhash{$Gr->{$f}->parent->{_group_}}.=" $f";
	    $diff_them++ if (keys(%{$G{ $Gr->{$f}->parent->{_group_} }})>1);
	  } else {
	    $valhash{"none"}.=" $f";
	  }
	}
	if ($diff_them and keys (%valhash) > 1) {
	  print "== $grp =============\n$rep\n" unless ($opt_Q or $diffs);
	  $diffs++;
	  $total_dependency++;
	  $tree_dependency++;
	  $dependency{Max( map { scalar(split " ",$valhash{$_}) } %valhash)}++;
	  foreach $val (keys %valhash) {
	    if ($val=~/N/) {
	      @gval=keys(% {$G{$val}});
	      $gval=$gval[0];
	      print "  depends on $val($gval\[",$G{$val}->{$gval}->{ord},"] ",
		$G{$val}->{$gval}->{trlemma},".",
		$G{$val}->{$gval}->{func},
		  "): $valhash{$val}\n"  unless ($opt_Q);
	    } else {
	      print "  depends on $val:",$valhash{$val},"\n"  unless ($opt_Q);
	    }
	  }
	}
      }

      #check for value differences
      unless($opt_d or $opt_m) {
	if ($opt_o) {
	  @atrchecklist=();
	} elsif ($opt_f or $opt_l) {
	  @atrchecklist=();
	  push (@atrchecklist,"trlemma","lemma") if $opt_l;
	  push (@atrchecklist,"func") if $opt_f;
	} else {
	  @atrchecklist=$opt_e ? ("func","form","origf","del","gram","sentmod","deontmod") :
	    ("func","form","trlemma","lemma","origf","del","gram","sentmod","deontmod");
	}

	foreach $attr (@atrchecklist,@userdefinedlist) {
	  $tree_cmp_attrs++;
	  $total_cmp_attrs++;
	  undef %valhash;
	  foreach $f (keys %$Gr) {
	    $valhash{$Gr->{$f}->{$attr}}.=" $f";
	  }
	  if (keys (%valhash) > 1) {
	    $value{Max( map { scalar(split " ",$valhash{$_}) } %valhash)}++;
	    print "== $grp =============\n$rep\n" unless ($opt_Q or $diffs);
	    if ($opt_w) {
	      my $child=$Gr->{$grps[0]};
	      print
		("> ",join(" ",map { ($_->{fw},$_->{form}.".".$_->{func}) }
			   sort {$a->{ord} <=> $b->{ord}}
#			   grep { $_->{ord}!~/\./ }
			   $child,
			   map { expand_coord_apos($_,1) } $child->children())
#			   expand_coord_apos($child->children,1))
		 ,"\n");
	    };
	    $diffs++;
	    $total{$attr}++;
	    $tree_att_diff{$attr}++;
	    foreach $val (keys %valhash) {
	      print "  $attr=$val:$valhash{$val}\n" unless ($opt_Q);
	    }
	  }
	}
      }
      $alldiffs+=$diffs;
      $total+=$diffs;
    }
    print "\n" unless $opt_Q;

    if ($opt_S) {
      print "#\n";
      foreach my $f (sort keys %alltrees) {
	my $tree=$alltrees{$f}->[$n];
	$acount=$tree->{acount};
	$trcount=$tree->{trcount};
	$newcount=$tree->{newcount};
	print "# $f$tree->{form} ($n):\n#\tTotal: $acount nodes\n#\tOn TR: $trcount nodes\n#\tNew:   $newcount\n#\n";
      }
      $tree_values=0;
      foreach (keys %tree_att_diff) {
	$tree_values+=$tree_att_diff{$_};
      }
      my $comparisons=$newcount+$trcount-1+$tree_cmp_attrs;
      print
	"> Diferences statistics:\n",
	">\tTotal:        $alldiffs differences of $comparisons comparisons \n";
      print (">\tTotal\%:       ",(100*$alldiffs)/$comparisons,"\% wrong\n")
	if ($comparisons>0);
	
      print ">\tStructure:    $tree_dependency differences on ",$trcount-1," edges\n";
      print (">\tStructure\%:   ",(100*$tree_dependency)/($trcount-1),"\% wrong\n") if ($trcount>1);
      print ">\tRestoration:  $tree_restoration differences on $newcount new nodes\n";
      print (">\tRestoration\%: ",(100*$tree_restoration)/($newcount),"\% wrong\n") if ($newcount);
      print
        ">\tAttributes:   $tree_values\n",
        map ({  ">\t\t".pack("A12","$_:").$tree_att_diff{$_}."\n" } grep {$_ ne ""} keys(%tree_att_diff)),
        "\n";
      print (">\tAttributes%:  ",(100*$tree_values)/($tree_cmp_attrs),"%\n") if ($tree_cmp_attrs);
    }
  
    if ($opt_K) {
      no integer;
      for (my $i=0;$i<@names;$i++) {
	for (my $j=$i+1;$j<@names;$j++) {
	  my $I=$names[$i];
	  my $J=$names[$j];
	  print "Kappa($I,$J): ";

	  # pocet uzlu ve stromu vyjma vrcholu == pocet hran ve stromu :)

	  my $a=0;    # pocet hran, ktere se vyskytuji v obou stromech
	  my $b=0;            # pocet hran, ktere se vyskytuji jen v I
	  my $c=0;            # pocet hran, ktere se vyskytuji jen v J
	  my $k=0; # pocet uzlu ktere se vyskytuji alespon u jednoho z I,J

	  # daly na grafu o @nodes+1 uzlech vytvorit
	  foreach $nodegrp (values(%G)) {
	    if (exists($nodegrp->{$I}) and $nodegrp->{$I}) {
	      $k++;
	      my $Inode=$nodegrp->{$I};
	      if (exists($nodegrp->{$J}) and $nodegrp->{$J}) {
		my $Jnode=$nodegrp->{$J};
		if ($Inode->parent->{_group_} eq $Jnode->parent->{_group_}) {
		  $a++;
		} else {
		  $b++; $c++;	# rodic vzdy exisistuje
		}
	      } else {
		$b++
	      }
	    } elsif (exists($nodegrp->{$J}) and $nodegrp->{$J}) {
	      my $Jnode=$nodegrp->{$J};
	      $k++;
	      $c++;
	    }
	  }
	  if ($k==0) {
	    print "1.00 (trivial agreement - no possible edges)\n";
	    next;
	  }
	  my $h=$k*($k+1); 	# potencialni pocet vsech hran v grafu
                                # o $k+1 uzlech
	  my $d=$h-$a-$b-$c;	# pocet hran, ktere nejsou ani u I ani u J

	  my $p = ($a+$c)*($a+$b)/$h + ($c+$d)*($b+$d)/$h;
	  my $kappa=($a+$d - $p) / ($h - $p);
	  # print "[a=$a,b=$b,c=$c,d=$d,h=$h,nodes=$k,p=$p,kappa=$kappa]\n";

	  printf '%.2f (',$kappa;
	  if ($kappa<0) { print "no agreement" }
	  elsif ($kappa<0.20) { print "poor agreement" }
	  elsif ($kappa<0.40) { print "fair agreement" }
	  elsif ($kappa<0.60) { print "moderate agreement" }
	  elsif ($kappa<0.80) { print "substantial agreement" }
	  elsif ($kappa<1) { print "almost perfect agreement" }
	  else { print "perfect agreement" }
	  print ")\n\n";
	}
      }
    }
    print "$alldiffs differences.\n\n" unless ($opt_Q);
  }

  $tree_cmp_attrs=0;
  $tree_dependency=0;
  $tree_restoration=0;
  %tree_att_diff=undef;
  $n++;
} until (! $any);

## Total results:

print "Comparison of @files\n\nFile statistics:\n" if ($opt_s);

foreach $f (keys %alltrees) {

  $acount=0;
  $trcount=0;
  $newcount=0;

  foreach $tree (@{ $alltrees{$f} }) {
    $acount+=$tree->{acount};
    $trcount+=$tree->{trcount};
    $newcount+=$tree->{newcount};

    $tree->destroy();
  }

  print "$f:\n\tTotal: $acount nodes\n\tOn TR: $trcount nodes\n\tNew:   $newcount\n\tAttrs: $total_cmp_attrs\n" if ($opt_s);
}

foreach (keys %total) {
  $total_values+=$total{$_};
}

delete $total{''};

if ($opt_s) {

  print
    "Diferences statistics:\n",
    "\tTotal:       $total differences\n",
    "\tStructure:   $total_dependency\n",
    "\tRestoration: $total_restoration\n",
    "\tAttributes:  $total_values\n",
    map ({ "\t\t".pack("A12","$_:").$total{$_}."\n" } keys(%total)),
    "\n";

  print 
    "Restoration - detailed statiscics:\n",
    "\tOf $total_restoration differences, there were\n",
    map ({ "\t\t".pack("A4",$restoration{$_})." agreements of $_\n" }
	 grep {$restoration{$_}>0} keys %restoration),
    "\n";

  print 
    "Dependency - detailed statiscics:\n",
    "\tOf $total_dependency differences, there were\n",
    map ({ "\t\t".pack("A4",$dependency{$_})." agreements of $_\n" }
	 grep {$dependency{$_}>0} keys %dependency),
    "\n";

  print 
    "Values of attributes - detailed statiscics:\n",
    "\tOf $total_values differences, there were\n",
    map ({ "\t\t".pack("A4",$value{$_})." agreements of $_\n" }
	 grep {$value{$_}>0} keys %value),
    "\n";

}


# popí¹u algoritmus:
#
# jedu pìknì soubor po souboru (pøes keys %alltrees), ze v¹ech beru
# i-tý strom (mám stromy T1,T2,...,Tk, kde k je poèet souborù) 
#
# 1. Ke ka¾dému uzlu stromu T1 najdu postupnì ve v¹ech stromech
# T2,...,Tk odpovídající uzly a ty si zapamatuji a oznaèím, ¾e jsou
# pøiøazeny.  Podobnì posupuji pro dosud neoznaèené uzly stromù T2 a¾
# Tk, pøièem¾ takto seskupuji uzly které si odpovídají. 
#
# Uzly si odpovídají, mají-li stejný ord neobsahující teèku (staré
# uzly), nebo kdy¾ si odpovídají jejich rodièe a uzly mají stejný
# funktor (pøidané uzly).
#
# 2. Pro ka¾dou skupinu odpovídajících si uzlù porovnávám: a) které
# uzly mají shodné zkoumané atributy b) které uzly mají "shodné" otce
# 3. Pokud nìkterý strom nemá zastoupení v nìkteré skupinì, zji¹»uji,
# který otec v ní nemá syna (pøípadnì jeho dal¹í potomky)


