# -*- cperl -*-
# Common tfa macros

#encoding iso-8859-2

# use strict;

sub TFAAssign {
  my ($value)=@_;
  if ($this->parent) {
    $this->{'tfa'} = $value;
    $this=NextVisibleNode($this);
  }
}

sub tfa_focus {
  TFAAssign('F');
}

sub tfa_topic {
  TFAAssign('T');
}

sub tfa_C {
  TFAAssign('C');
}

sub tfa_NA {
  TFAAssign('NA');
}

sub tfa_qm {
  TFAAssign('???');
}

#include <contrib/support/projectivize.inc>

sub NotOrderableByTFA {
# displays a message box
  MessageCzEn("Podstrom nebyl uspoøádán podle atributu tfa.",
	      "The subtree has not been ordered according to the tfa attribute.")
}


sub OrderByTFA {
# orders the current subtree according to the value of the tfa attribute
# and returns an ordered array containing the subtree
# checks for projectivity, then orders the subtrees of the top node


  my $top=ref($_[0]) ? $_[0] : $this;  # the reference to the node whose subtree is to be ordered according to tfa

  my $value=$top->{tfa};  # the tfa value for the top node

  if ((IsHidden($top)) or ($value !~ /T|C|F/)) {
    # does not do anything on hidden nodes and on nodes with NA or no tfa value
    NotOrderableByTFA;
    return
  }

  my (@subtree, @sons_C, @sons_T, @sons_F, @sons_hidden);
  my $ord=$grp->{FSFile}->FS->order;  # the ordering attribute

  my $node;
  # now go through the sons
  for ($node=$top->firstson; $node; $node=$node->rbrother) {

    if (IsHidden($node)) {push @sons_hidden, $node}  # the node is hidden
    else {  # decide according to the tfa value of the node
      $value=$node->{tfa};  # the tfa value of the node

      if ($value eq "C") {push @sons_C, $node}
      elsif ($value eq "T") {push @sons_T, $node}
      elsif ($value eq "F") {push @sons_F, $node}
      elsif ($value eq "NA") {
	# in this case decide according to the tfa value of depending nodes
	# if there is at least one depending node with F, place the current node among F nodes
	# otherwise if there is at least one with T, place the current node among T nodes, return otherwise
	my @nodes= HiddenVisible() ? GetNodes($node) : GetVisibleNodes($node);
	# look at appropriate nodes according to the visibility-of-hidden-nodes status
	my ($hasTorC, $hasF) = (0,0);
	while (@nodes) {  # checks whether at least some depending node has tfa value
	  my $value=shift(@nodes)->{tfa};
	  if (($value eq "C") or ($value eq "T")) {$hasTorC=1}
	  elsif ($value eq "F") {$hasF=1}
	}
	if ($hasF or $hasTorC) {  # there is a depending node with tfa value
	  if ($hasF) {push @sons_F, $node}
	  else {push @sons_T, $node}
	} else {  # no depending node has a tfa value, therefore return
	  NotOrderableByTFA;
	  return
	}
      }
      else {  # return if there is a node that is visible and doesn't have tfa value
	NotOrderableByTFA;
	return
      }
    }
  }

  SortByOrd(\@sons_C);
  SortByOrd(\@sons_T);
  SortByOrd(\@sons_F);
  SortByOrd(\@sons_hidden);

  foreach $node (@sons_C, @sons_T, $top, @sons_F, @sons_hidden) {
    # creates an ordered array with the subtree ordered according to tfa
    if ($node == $top) {
      push @subtree, $node  # only the top node
    } else {
      my @sonssubtree=GetNodes($node);
      SortByOrd(\@sonssubtree);
      push @subtree, @sonssubtree  # push a son's subtree
    }
  }
  return \@subtree
}


sub OrderSTByTFA {
# orders the passed node's sons' subtrees according to the tfa value

  my $top=ref($_[0]) ? $_[0] : $this; # $top contains the reference to the node whose subtree is to be projectivized

  return unless ProjectivizeSubTree($top);

  my $subtree=OrderByTFA($top);
  return unless $subtree;

  my $all=GetNodesExceptST([$top]);

  splice @$all,Index($all,$top),1, @$subtree;   # the subtree is spliced at the right place

  NormalizeOrds($all);  # the ordering attributes are modified accordingly
}


# slightly modified from PDT module
sub expand_coord_apos {
  my ($node,$keep)=@_;
  if (PDT::is_coord_TR($node)) {
    return (($keep ? $node : ()),
	    map { expand_coord_apos($_,$keep) }  $node->children());
  } else {
    return ($node);
  }
}


# ******************************* pre-set the attribute tfa *****************************************
sub PreSetTFASubTree {
# sets the tfa attribute for the subtree of a node passed as parameter or the root if no parameter is passed

  my $top=ref($_[0]) ? $_[0] : $root;  # the reference to the node in whose subtree the tfa attribute is to be set

  return if IsHidden($top); # do not do anything on hidden nodes

  my @all=GetNodes($root);
  SortByOrd(\@all);  # an array of all nodes in the tree ordered according to the ordering attribute

  PreSetTFArecursive(\@all,$top,$root,"F",0);

  NormalizeOrds(\@all);
}


# PreSetTFArecursive(\all_nodes, subtree root, node to be processed, flag)

sub PreSetTFArecursive {
# sets the tfa attribute for the subtree

  my ($all, $top, $node, $value, $flag) = (shift, shift, shift, shift, shift);
  # reference to the array of all nodes
  # the reference to the node in whose subtree the tfa attribute is to be set
  # node to be processed
  # value to be assigned
  # flag (whether to really modify the tfa attribute and perform modifications of structure)

  # set the flag when top of the subtree is encountered
  $flag = 1 if ($node == $top); # simple case
  if (not ($flag)) { # case when top is a coordination node
    for (my $n=$node->parent; $n and PDT::is_coord_TR($n); $n=$n->parent) {
      $flag = 1 if ($n == $top);
    }
  }

  # print STDERR "+\n=== DELKA POLE:  ".scalar(@$all);
  # print STDERR "      UZEL:  ".$node->{'trlemma'}."      HODNOTA:  ".$value."    FLAG:  ".$flag."\n+\n";

  # set the attribute
  if ($flag and ($node != $root)) {
    $node->{'tfa'} = $value;
  }

  # do not recurse on coordination nodes !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # print STDERR "--- nezanoruje se v rekurzi!!!\n" if (PDT::is_coord_TR($node));
  return if PDT::is_coord_TR($node);

  # all visible children, including expanded coordinations and appositions
  my @children = map { IsHidden($_) ? () : $_ }
                 map { expand_coord_apos($_,1) } $node->children();
  SortByOrd(\@children);

     # print STDERR "!!! children: ";
     # print STDERR join " ", map $_->{'trlemma'}, @children;
     # print STDERR "\n";

  my $verb = 0; # a flag (whether a finite verb is being processed)
  if ($node->{'tag'}=~/^V[^f].*/ or $node->{'func'}=~/PRED/) {
    $verb = 1
  }

  # arrays for nodes that might be moved according to the below-mentioned rules
  my (@leftmovedchildren, @rightmovedchildren, @prec, @neg) = ();

  foreach my $child (@children) {  # go through all children

    # print STDERR "================== zanoruju se na:  ".$child->{'trlemma'}." : ";

    if (PDT::is_coord_TR($child)) { # non-applicable (coordination and apposition)
      # print STDERR "coord prirazuju NA\n";
      PreSetTFArecursive($all, $top, $child, "NA", $flag);
      next;
    }

    # "linguistic" root(s) of the tree
    if ($node==$root) { # "skip" the root of the whole tree
      # print STDERR "setting TFA value to linguistic root: F\n";
      PreSetTFArecursive($all, $top, $child, "F", $flag);
      next;
    }

    # the things common to verbal and nominal phrases
    # reorder certain visible children and set the tfa attribute to all the visible children of the current node

    # negation
    if ($child->{'func'} =~ /RHEM/ and $child->{'trlemma'} =~ /^(&)?Neg(;)?$/) {
      # print STDERR "   negation F\n";
      PreSetTFArecursive($all, $top, $child, "F", $flag);
      if ($flag and $child->parent == $node and $node != $root) {
 	push @neg, @{Projectivize($child)};
      }
    }
    # certain modifiers are to be put immediately after their parent node
    elsif ($child->{'func'} =~ /MOD|MANN|EXT/) {
      # print STDERR "  modifiers F\n";
      PreSetTFArecursive($all, $top, $child, "F", $flag);
      if ($flag and $child->parent == $node and $node != $root) {
 	push @rightmovedchildren, @{Projectivize($child)};
      }
    }
    # restored leaf nodes to be put to the left of the governing node
    elsif ($child->{'ord'} =~ /\./ and not($child->firstson)) {
      # print STDERR "  restored nodes T\n";
      PreSetTFArecursive($all, $top, $child, "T", $flag);
      if ($flag and $child->parent == $node and $node != $root) {
 	push @leftmovedchildren, @{Projectivize($child)};
      }
    }
    # nodes with functors ATT pr PREC
    elsif ($child->{'func'} =~ /ATT|PREC/) {
      # print STDERR "  PREC or ATT nodes T\n";
      PreSetTFArecursive($all, $top, $child, "T", $flag);
      if ($flag and $node != $root) {
	push @prec, @{Projectivize($child)}
      }
    }
    # nodes depending on a finite verb
    elsif ($verb) {
      # actants
      if ($child->{'func'} =~ /ACT|PAT|ADDR|ORIG|EFF/) {
      # print STDERR "  verbal actants";
	if (GetOrd($child) < GetOrd($node)) {
	  # print STDERR "  T\n";
	  PreSetTFArecursive($all, $top, $child, "T", $flag);
	}
	else {
	  # print STDERR "  F\n";
	  PreSetTFArecursive($all, $top, $child, "F", $flag);
	}
      }
      # other nodes
      else {
	# print STDERR "  other verbal complements  T\n";
	PreSetTFArecursive($all, $top, $child, "T", $flag);
      }
    }
    # nodes depending on a nominal phrase
    # (all those not depending on a finite verb and not pertaining to the above categories
    else {
      # print STDERR " NP - ";
      # pronouns (TODO subtypes)
      if (($child->{'tag'} =~ /^P.*/) or ($child->{'trlemma'} eq "tento")) {
	# print STDERR "pronouns T\n";
	PreSetTFArecursive($all, $top, $child, "T", $flag);
      }
      # other nodes
      else {
	# print STDERR "other F\n";
	PreSetTFArecursive($all, $top, $child, "F", $flag);
      }
    }
  }  # for for children

  if ($flag and $node != $root) {

    # before splicing them back, first remove the nodes you want to move
    foreach my $n (@leftmovedchildren, @rightmovedchildren, @prec, @neg) {
      splice @$all, Index($all,$n), 1
    };

    # debugging prints
#     if (@leftmovedchildren) {
#       print STDERR "**********    moved nodes - left: ";
#       print STDERR join " ", map "$_", @leftmovedchildren;
#       print STDERR "\n";
#       print STDERR join " ", map $_->{'trlemma'}, @leftmovedchildren;
#       print STDERR "\n";
#     }
#     if (@neg) {
#       print STDERR "**********    moved nodes - negation: ";
#       print STDERR join " ", map "$_", @neg;
#       print STDERR "\n";
#       print STDERR join " ", map $_->{'trlemma'}, @neg;
#       print STDERR "\n";
#     }
#     if (@rightmovedchildren) {
#       print STDERR "**********    moved nodes - right: ";
#       print STDERR join " ", map "$_", @rightmovedchildren;
#       print STDERR "\n";
#       print STDERR join " ", map $_->{'trlemma'}, @rightmovedchildren;
#       print STDERR "\n";
#     }
#     if (@prec) {
#       print STDERR "**********    PREC or ATT nodes: ";
#       print STDERR join " ", map "$_", @prec;
#       print STDERR "\n";
#       print STDERR join " ", map $_->{'trlemma'}, @prec;
#       print STDERR "\n";
#     }

    # place child nodes appropriately
    splice @$all, Index($all,$node), 0, @leftmovedchildren, @neg;
    splice @$all, Index($all,$node)+1, 0, @rightmovedchildren;

    NormalizeOrds($all);

    if (@prec) { # place prec nodes before the subtree of the parent node
      # except for the nodes depending on the given node
      my @currentsubtree = GetVisibleNodes($node);
      foreach my $n (@prec) {
	if (defined(Index(\@currentsubtree,$n))) {
	  splice @currentsubtree, Index(\@currentsubtree,$n), 1;
	}
      }
      SortByOrd(\@currentsubtree);
      splice @$all, Index($all,$currentsubtree[0]), 0, @prec;
    }

    NormalizeOrds($all);

} # fi

  print STDERR "--------------------------- vynoruji se z:  ".$node->{'trlemma'}."\n";

}


sub PreSetTFACurrentTree {
  PreSetTFASubTree($this);
}

sub PreSetTFATree {
  PreSetTFASubTree($root);
}

sub PreSetTFAAllTrees {
  if (AskCzEn("Varování","Chcete nastavit atribut TFA u v¹ech stromù v souboru?","Warning","Do you want to set the TFA attribute in all trees in the file?")) {
    foreach my $node ($grp->{FSFile}->trees()) {
      my @all=GetNodes($node);
      SortByOrd(\@all);
      PreSetTFArecursive(\@all,$node,$node,"F",0);
      NormalizeOrds(\@all);
    }
  }
}

#include <contrib/support/reordering.inc>
