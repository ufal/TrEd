#!/usr/bin/perl
#
# Usage: 
# fsdiff.pl files ...
#
# Compares two or more fs files annotated on TG level. Stores the
# differences in err1 and err2 attributes.
#  

use Fslib;
use locale;
use POSIX qw(locale_h);

use integer;


setlocale(LC_ALL,"cs_CZ");
setlocale(LANG,"czech");

%attribs = ();
@atord = ();


$usenames=0;
$hide=1;
while (@ARGV>0 and $ARGV[0]=~/^-/) {
  $_=shift @ARGV;
  if (/h/ && ! $helped) {
    print STDERR <<EOL;

  Find differences in fs-files from TR-level
  Usage: fsdiff.pl [-h] [-a] [-n] file1, file2, ...

  Options:
     -a   diff all nodes (i.e. hidden too)
     -n   guess and use names of anotators instead of filenames
     -d   check dependency only
     -l   check lemma only
     -m   check missing only
     -e   exclude differences in lemma
     -h   print this help screen
EOL
    exit 0;
  };
  $usenames=1 if (/n/);
  $onlylemma=1 if (/l/);
  $onlydep=1 if (/d/);
  $onlymissing=1 if (/m/);
  $excludelemma=1 if (/e/);
  $hide=0 if (/a/);
}

@files=@ARGV;

%alltrees=();
%allheaders = ();
%allrests = ();

$filecount=$#files+1;

my $eb=0;
my $ab=0;
my $zu=0;

foreach $f (@files) {
  $name=$f;
  $name="ZU".($zu?$zu+1:""),$zu++ if ($usenames and $f=~/zu?\.fs/i);
  $name="EB".($eb?$eb+1:""),$eb++ if ($usenames and $f=~/eb?\.fs/i);
  $name="AB".($ab?$ab+1:""),$ab++ if ($usenames and $f=~/ab?\.fs/i);    
  $names{$f}=$name;
}

@names=sort values %names;

foreach $f (@files) {
  @trees = ();
  @header = ();
  @rest = ();
  @nodes=();

  die "cannot open $f!\n" unless open(F,"<$f");
  $fileno++;
  
  %attribs=ReadAttribs(\*F,\@atord,2,\@header);

  print STDERR "Reading $f ...\n";
  while ($_=ReadTree(\*F)) {
    if (/^\[/) {
      $root=GetTree($_,\@atord,\%attribs);

      if ($hide) {
	# here we delete all hidden nodes (God bless 'em - or us? )
	$node=$root;
	while ($node) {
	  if ($$node{"TR"} eq "hide") {
	    Cut($node);
	    $node=$root;
	    next;
	  }
	  $node=Next($node);
	}
      }

      push(@trees, $root);
      print STDERR @trees[$#trees]->{"form"},"\n";
    } else { push(@rest, $_); }
  }
  print STDERR "Done.\n";
  $alltrees{$names{$f}}= [ @trees ];
  print STDERR $alltrees{$names{$f}}->[0]{"form"},"\n";
  $allheaders{$names{$f}}= [ @header ];
  $allrests{$names{$f}} = [ @rest ];
  
  close (F);
}


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
      print STDERR "\n*****************************************\n\n";
      print STDERR "Working on ",$trees[$n]->{"form"},"\n";
      print STDERR "Tree ",$n+1," has form ",$trees[$n]->{"form"},"\n";
      $any=1;
    }

    # create groups of corresponding old nodes, i.e. nodes not created
    # by anotators
    if ($T{$f}) {
      print STDERR "Creating groups for tree # $n (starting at $f)\n"; 
      $node=Next($T{$f}); 
      while ($node) {
	if ($$node{"ord"}!~/\./) {
	  if (! exists $G{$$node{"ord"}}) { 
	    $G{$$node{"ord"}} = { };	# structure: $G{ ord }->{ file } == node_from_file_at_ord     
	  }
	  $G{$$node{"ord"}}->{$f}=$node;	
	  $$node{"_group_"}=$$node{"ord"};
	}
	$node=Next($node);	
      }
      print STDERR "Done.\n";
    }
  }
  
  if ($any) {
    print "Comparing trees #",$n+1,":\n";
    print STDERR "Crating groups for new nodes\n";

    # create groups of nodes added by anotators that correspond
    # dunno how to make it easily, so I'm working hard (looking for func)

    $grpid=0;
    for ($i=0; $i < @names; $i++) {
      if ($T{$names[$i]}) {
	$node=Next($T{$names[$i]});
	while ($node) {
	  if (! exists $$node{"_group_"}) {
	    $grp="N$grpid";
	    $grpid++;

	    if (! exists $G{$grp}) { 
	      $G{$grp} = { };	
	    }
	    $G{$grp}->{$names[$i]}=$node;	
	    $$node{"_group_"}=$grp;
	   
	    $parent_grp= Get(Parent($node),"_group_");
	    for ($j=$i+1; $j < @names; $j++) {
	      if (exists ($G{$parent_grp}->{$names[$j]})) {
		$son=FirstSon($G{$parent_grp}->{$names[$j]});
		SON: while ($son) {
		  if ((! exists $$son{"_group_"}) and ($$son{"func"} eq $$node{"func"})) {
		    $$son{"_group_"}=$grp;
		    $G{$grp}->{$names[$j]}=$son;
		    last SON;
		  }
		  $son=RBrother($son);
		}
	      }
	    }
	  }
	  $node=Next($node);
	}
      }      
    }
    # well, wasn't so difficult :)

    print STDERR "Done.\n";
    # Now have look on the groups:
    foreach $grp (sort { $a=~/N?([0-9]+)/,$A=$1,$A+=1000*($a=~/^N/),
			   $b=~/N?([0-9]+)/,$B=$1,$B+=1000*($b=~/^N/),$A <=> $B } 
		  keys(%G)) {
      $Gr=$G{$grp};
      $diffs=0;

      unless ($onlylemma or $onlydep) {
	# check if all files have node in this group
	@grps=keys(%$Gr);
	$rep=$grps[0]."[".$$Gr{$grps[0]}->{"ord"}."]: ".
	  $$Gr{$grps[0]}->{"trlemma"}.".".$$Gr{$grps[0]}->{"func"};
	if (@grps != @names) {		
	  print "== $grp =============\n$rep\n" if (! $diffs);
	  $diffs++;
	  if (2*@grps<@names) {
	    print "  only in:";
	    foreach $f (keys %$Gr) {
	      print " $f";
	    }
	    print "\n";
	  } else {
	    print "  not in:";
	    foreach $f (@names) {
	      print " $f" if (! exists $$Gr{$f} );
	    }
	    print "\n";
	  }
	}
      }

      # check for (parent) structure differences but ignore changes,
      # if parents are alone, i.e. not associated in groups
      unless ($onlylemma or $onlymissing) {
	undef %valhash;
	$diff_them=0;
	foreach $f (keys %$Gr) {
	  if (Parent($$Gr{$f})) {
	    $valhash{Get(Parent($$Gr{$f}),"_group_")}.=" $f";
	    $diff_them++ if (keys(% {$G{Get(Parent($$Gr{$f}),"_group_")}})>1);
	  } else {
	    $valhash{"none"}.=" $f";
	  }
	}
	if ($diff_them and keys (%valhash) > 1) {
	  print "== $grp =============\n$rep\n" if (! $diffs);
	  $diffs++;
	  foreach $val (keys %valhash) {
	    if ($val=~/N/) {
	      @gval=keys(% {$G{$val}});
	      $gval=$gval[0];
	      print "  depends on $val($gval\[",$G{$val}->{$gval}->{ord},"] ",
		$G{$val}->{$gval}->{trlemma},".",
		$G{$val}->{$gval}->{func},
		  "): $valhash{$val}\n";
	    } else {
	      print "  depends on $val:$valhash{$val}\n";
	    }
	  }
	}
      }

      #check for value differences
      unless($onlydep or $onlymissing) {
	@atrchecklist=$onlylemma ? ("trlemma","lemma") : 
	  ($excludelemma ? ("func","form","origf","del","gram","sentmod","deontmod") :
	   ("func","form","trlemma","lemma","origf","del","gram","sentmod","deontmod"));
	foreach $attr (@atrchecklist) {
	  undef %valhash;
	  foreach $f (keys %$Gr) {
	    $valhash{$$Gr{$f}->{$attr}}.=" $f";
	  }
	  if (keys (%valhash) > 1) {
	    print "== $grp =============\n$rep\n" if (! $diffs);
	    $diffs++;
	    foreach $val (keys %valhash) {
	      print "  $attr=$val:$valhash{$val}\n";
	    } 
	  }
	}
      }
      $alldiffs+=$diffs;
    }
    print "\n$alldiffs differences.\n\n";
  }
  $n++;
} until (! $any);


# popí¹u algoritmus (bomba: Emacs umí M-q i v perlovských komentáøích:) : 
#
# jedu pìknì soubor po souboru (pøes keys %alltrees), ze v¹ech beru
# i-tý strom (mám stromy T1,T2,...,Tk, kde k je poèet souborù) 
# 
# 1. Ke ka¾dému uzlu stromu T1 najdu postupnì ve v¹ech stromech
# T2,...,Tk odpovídající uzly a ty si zapamatuji a oznaèím, ¾e jsou
# pøiøazeny.  Podobnì posupuji pro dosud neoznaèené uzly stromù T2 a¾
# Tk, pøièem¾ takto seskupuji uzly které si odpovídají.
# 
# 2. Pro ka¾dou skupinu odpovídajících si uzlù porovnávám: a) které
# uzly mají shodné zkoumané atributy b) které uzly mají "shodné" otce
# 3. Pokud nìkterý strom nemá zastoupení v nìkteré skupinì, zji¹»uji,
# který otec v ní nemá syna (pøípadnì jeho dal¹í potomky)


foreach $f (keys %alltrees) { 
  foreach $tree (@{ $alltrees{$f} }) {
    DeleteTree($tree); 
  }
  undef @{ $allheaders{$f} };
  undef @{ $allrests{$f} };
}
