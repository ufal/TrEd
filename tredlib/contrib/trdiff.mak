# -*- cperl -*-
package TR_Diff;

use base qw(Tectogrammatic);
import Tectogrammatic;

#key-binding-adopt Tectogrammatic

# bind TiePrevTree to key Ctrl+comma
# bind TieNextTree to key Ctrl+period

# bind PrevTree to key comma
# bind NextTree to key period


use vars qw($hide $usenames $onlylemma $onlyfunc $onlydep $onlymissing $excludelemma $summary $diff_style);

use integer;

$hide=1;
$diff_style;

sub switch_context_hook {
  my ($precontext,$context)=@_;
  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!
  return unless ($precontext ne $context);
  my @pat=GetDisplayAttrs();
  my $hint=GetBalloonPattern();

  SetDisplayAttrs(@pat,
'style:<? #diff ?><? "#{Line-fill:red}#{Line-dash:- -}" if $${_diff_dep_} ?>',
'style:<? #diff ?><? join "",map{"#{Text[$_]-fill:orange}"} split  " ",$${_diff_attrs_} ?>',
'style:<? #diff ?><? "#{Oval-fill:darkorange}#{Oval-addwidth:4}#{Oval-addheight:4}" if $${_diff_attrs_} ?>',
'style:<? #diff ?><? "#{Oval-fill:cyan}#{Line-fill:cyan}#{Line-dash:- -}" if $${_diff_in_} ?>',
'style:<? #diff ?><? "#{Line-fill:black}#{Line-dash:- -}" if $${_diff_attrs_}=~/ TR/ ?>',
'<? #diff ?>${_group_}');
  SetBalloonPattern($hint.
		    "\n".'Diffs in:${_diff_attrs_}'
		   );
  print STDERR "Setting TRDiff attributes\n";
}

sub pre_switch_context_hook {
  my $hint=GetBalloonPattern();
  $hint=~s/\n_diff_\n//g;
  SetBalloonPattern($hint);
  SetDisplayAttrs(grep { !/\#diff.*(?:\n?|$)/ } GetDisplayAttrs());
  print "Removing TRDiff attributes\n";
}


sub get_anotator_names {
  my (@files)=@_;
  my $filecount=$#files+1;
  my ($eb,$ab,$zu,$ik,$h,$jh,$vr)=(0,0,0,0);
  my %names;
  my $name;
  foreach my $f (@files) {
    $name=$f;
    if ($usenames) {
      $name="ZU".($zu?$zu+1:""),$zu++ if ($f=~/zu?\.fs/i);
      $name="EB".($eb?$eb+1:""),$eb++ if ($f=~/eb?\.fs/i);
      $name="AB".($ab?$ab+1:""),$ab++ if ($f=~/ab?\.fs/i);
      $name="IK".($ik?$ik+1:""),$ik++ if ($f=~/ik?\.fs/i);
      $name="H".($ik?$ik+1:""),$ik++ if ($f=~/h\.fs/i);
      $name="VR".($ik?$ik+1:""),$ik++ if ($f=~/vr?\.fs/i);
      $name="JH".($ik?$ik+1:""),$ik++ if ($f=~/jh?\.fs/i);
    }
    $names{$f}=$name;
  }
  return %names;
}

sub Max {
  my $max=0;
  foreach (@_) {
    $max=$_ if $_>$max;
  }
  return $max;
}

sub diff_trees {
  my %T=@_;
  my @names=keys %T;
  # %T is a has of the form id => tree, where id is any textual identifier
  # of the tree

  foreach my $tree (values %T) {
    print "Prepairing tree\n";
    # count all nodes, visible nodes and nodes added on TR-layer
    my $acount=0;
    my $trcount=0;
    my $newcount=0;
    my $node=$tree;
    while($node) {
      if (IsHidden($node) or $node->{TR} eq 'hide') {
	$acount++;
      } else {
	$trcount++;
	$acount++;
	$newcount++ if ($node->{ord}=~/\./);
      }
      delete $node->{_group_};
      delete $node->{_diff_in_};
      delete $node->{_diff_dep_};
      delete $node->{_diff_attrs_};

      $node=Next($node);
    }
    # store the information in $tree
    $tree->{acount}=$acount;
    $tree->{trcount}=$trcount;
    $tree->{newcount}=$newcount;
  }

  my $total=0;
  my %total=undef;
  my $total_dependency=0;
  my $total_restoration=0;
  my %restoration=map { $_ => 0 } 1..@names;
  my %dependency=map { $_ => 0 } 1..@names;
  my %value=map { $_ => 0 } 1..@names;

  my $any=0;
  my $alldiffs=0;
  my $node;

  my %G=();
  foreach my $f (sort @names) {
    print "Crating groups for $f\n";
    # create groups of corresponding old nodes, i.e. nodes not created
    # by anotators
    if ($T{$f}) {
      $node=Next($T{$f}); # or NextVisibleNode if all are to be compared
      while ($node) {
	if ($node->{"ord"}!~/\./) {
	  if (! exists $G{$node->{"ord"}}) { 
	    $G{$node->{"ord"}} = { }; # structure: $G{ ord }->{ file } == node_from_file_at_ord
	  }
	  $G{$node->{"ord"}}->{$f}=$node;
	  $node->{_group_}=$node->{"ord"};
	}
	$node=Next($node);
      }
    }
  }

  # create groups of nodes added by anotators that correspond
  # dunno how to make it easily, so I'm working hard (looking for func)
  my $g;
  my $grpid=0;
  my $parent_grp;
  my $son;
  for (my $i=0; $i < @names; $i++) {
    if ($T{$names[$i]}) {
      $node=Next($T{$names[$i]});
      while ($node) {
	if (! exists $node->{_group_}) {
	  $g="N$grpid";
	  $grpid++;
	  if (! exists $G{$g}) {
	    $G{$g} = { };
	  }
	  $G{$g}->{$names[$i]}=$node;
	  $node->{"_group_"}=$g;
	  $parent_grp= $node->parent->{_group_};
	  for (my $j=$i+1; $j < @names; $j++) {
	    if (exists ($G{$parent_grp}->{$names[$j]})) {
	      $son=FirstSon($G{$parent_grp}->{$names[$j]});
	    SON: while ($son) {
		if ((! exists $son->{_group_})
		    and
		    ($son->{"func"} eq $node->{"func"})) {
		  $son->{"_group_"}=$g;
		  $G{$g}->{$names[$j]}=$son;
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

  # Now have look on the groups:
  my ($A,$B);
  my %valhash;
  foreach my $g (sort { $A=~/N?([0-9]+)/;
			$A=$1;
			$A+=1000*($a=~/^N/);
			$b=~/N?([0-9]+)/;
			$B=$1;
			$B+=1000*($b=~/^N/);
			$A <=> $B }
		 keys(%G)) {

    next if $g eq "";
    my $Gr=$G{$g};
    my $diffs=0;

    my @grps=keys(%$Gr);

    unless ($onlylemma or $onlydep) {
      # check if all files have node in this group
      if (@grps != @names) {
	$diffs++;
	$total_restoration++;
	$restoration{max(scalar(@names)-scalar(@grps),scalar(@grps))}++;

	foreach my $node (values %$Gr) {
	  $node->{_diff_in_}=join(" ",@grps);
	  print "DIFF in $node->{_diff_in_}\n";
	}
      }
    }

    # check for (parent) structure differences but ignore changes,
    # if parents are alone, i.e. not associated in groups

    unless ($onlylemma or $onlymissing) {
      undef %valhash;
      my $diff_them=0;

      foreach my $f (@grps) {
	if ($Gr->{$f}->parent) {
	  $valhash{$Gr->{$f}->parent->{"_group_"}}.=" $f";
	  $diff_them++ if (keys(%{$G{$Gr->{$f}->parent->{"_group_"}}})>1);
	} else {
	  $valhash{"none"}.=" $f";
	}
      }

      if ($diff_them and keys (%valhash) > 1) {
	$diffs++;
	$total_dependency++;
	my @a;
	$dependency{Max(map { my @a=split " ",$valhash{$_}; scalar(@a) } %valhash)}++;
	foreach my $f (@grps) {
	  $Gr->{$f}->{_diff_dep_}=$valhash{$Gr->{$f}->parent->{"_group_"}};
	  print "DIFF DEP: ",$Gr->{$f}->{_diff_dep_},"\n";
	}
      }
    }

    #check for value differences
    my @atrchecklist=();
    unless($onlydep or $onlymissing) {

      if ($onlyfunc or $onlylemma) {
      	@atrchecklist=();
	push (@atrchecklist,"trlemma","lemma") if $onlylemma;
	push (@atrchecklist,"func") if $onlyfunc;
      } else {
	@atrchecklist=$excludelemma ? qw(func form origf del gram sentmod deontmod TR) :
	  qw(func form trlemma lemma origf del gram sentmod deontmod TR);
      }
      foreach my $attr (@atrchecklist) {
	undef %valhash;
	foreach my $f (@grps) {
	  $valhash{"$Gr->{$f}->{$attr}"}.=" $f";
	}
	if (keys (%valhash) > 1) {
	  my @a;
	  $value{Max( map { scalar(@a=split " ",$valhash{$_}) } %valhash)}++;
	  $diffs++;
	  $total{$attr}++;
	  foreach my $f (@grps) {
	    print "Attr diff in $attr\n";
	    $Gr->{$f}->{_diff_attrs_}.=" $attr";
	  }
	}
      }
      $alldiffs+=$diffs;
      $total+=$diffs;
    }
  }
}

#bind DiffTRFiles to key equal menu Porovnej tektogramatické soubory

sub DiffTRFiles {

  my $fg=$TredMacro::grp->{framegroup};
  my @T;
  my ($fs,$tree);
  foreach my $win (@{$fg->{treeWindows}}) {
    next unless $win->{macroContext} eq 'TR_Diff';
    $fs=$win->{FSFile};
    if ($fs) {
      $tree=$fs->treeList()->[$win->{treeNo}];
      push @T, $fs->filename()."##".$win->{treeNo} => $tree if $tree;
    }
  }
  if (@T>2) {
    diff_trees(@T);
  }
  $Redraw='all';
}
