# -*- cperl -*-
# common tfa macros

# use strict;

sub TFAAssign {
  my ($value)=@_;
  if (Parent($this)) {
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


sub GetNodesExceptST {
# returns the reference to an array ordered according to the ordering attribute
# containing the whole tree except the nodes depending on the given nodes
# the array contains all nodes or only visible nodes depending on the second parameter

  # $tops contains the reference to a list containing reference to the nodes whose subtrees are to be skipped
  my $tops=ref($_[0]->[0]) ? $_[0] : [$this];

  my @all;

  my $node=$root;

  if ($_[1]) {               # @all is filled with the the visible nodes of the whole tree
    while ($node) {          # except for the nodes depending on the given node
      push @all, $node;
      if (defined(Index($tops,$node))) {
	$node=$node->following_right_or_up;
	$node=$node->following_visible($grp->{FSFile}->FS) if IsHidden($node);
      } else {
	$node=$node->following_visible($grp->{FSFile}->FS);
      }
    }
  } else {
    while ($node) {          # @all is filled with the nodes of the whole tree
      push @all, $node;      # except for the nodes depending on the given node
      if (defined(Index($tops,$node))) {
	$node=$node->following_right_or_up;
      }
      else {
	$node=$node->following;
      }
    }
  }

  SortByOrd(\@all);
  return \@all;
}


sub ProjectivizeSubTree {
# projectivizes the subtree of a given node (within the whole tree)
# if it succeeds, it returns 1, undef otherwise

  my $top=ref($_[0]) ? $_[0] : $this; # $top contains the reference to the node whose subtree is to be projectivized

  my $subtree=ContinueProjectivizing($top); # the ordered array of the projectivized subtree, or undef
  return undef unless @$subtree;

  my $all=GetNodesExceptST([$top]);

  splice @$all,Index($all,$top),1, @$subtree;   # the projectivized subtree is spliced at the right place

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

  return 1
}


sub ProjectivizeCurrentSubTree {
# interactively projectivizes current subtree
  ProjectivizeSubTree($this)
}


sub ProjectivizeTree {
# interactively projectivizes the whole tree
  ProjectivizeSubTree($root)
}

sub ProjectivizeSubTreeWithoutAsking {
# projectivizes (asks for no confirmation) subtree
  my $top=ref($_[0]) ? $_[0] : $this; # $top contains the reference to the node whose subtree is to be projectivized
  my $subtree=Projectivize($top);
  my $all=GetNodesExceptST([$top]);
  splice @$all,Index($all,$top),1, @$subtree;   # the projectivized subtree is spliced at the right place
  NormalizeOrds($all);  # the ordering attributes are modified accordingly
}

sub Projectivize {
# returns an ordered array with the nodes of the projectivized subtree of a given node

  my ($top,$onlyvisible) = @_;  # the reference to the node whose subtree is to be projectivized
                                # whether only non-hidden nodes are to be put in the array
  return undef unless ref($top);

  my @subtree;
  my @sons_left;
  my @sons_right;
  my $node;
  my $i = 0;
  my $ord=$grp->{FSFile}->FS->order;

  push @subtree, [$top,1] unless ($onlyvisible and IsHidden($top));
                           # an ordered array of the projectivized subtree is being created
                           # it contains pairs consisting of a reference to a node
                           # and an indicator saying whether its sons have already been processed

  while ($i<=$#subtree) {  # the subtree is being traversed and projectivized at the same time
                           # the array @subtree grows only to the right of the current index
    if ($subtree[$i]->[1] == 1) { # this node's sons have not been processed yet
        undef(@sons_left);
    	undef(@sons_right);
	$node=$subtree[$i]->[0]->firstson;
	  while ($node) {  # the sons are being traversed and
                           # divided into those on the left and those on the right from the given node
	    next if ($onlyvisible and IsHidden($node));
	    if ($node->{$ord} < $subtree[$i]->[0]->{$ord}) {
	      push @sons_left, [$node,1];
	    }
	    else {
	      push @sons_right, [$node,1];
	    }
	  }
	continue {
	  $node=$node->rbrother;
	}
        $subtree[$i]->[1]=0;  # the processed noded is marked as such
	# the left and right sons are spliced at appropriate places in the array
        splice @subtree,$i+1,0,(sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_right);
        splice @subtree,$i,0,(sort {$a->[0]->{$ord} <=> $b->[0]->{$ord}} @sons_left);
      }
      else {
	$i++;  # increase the current index by one if the sons of the current node have already been processed
      }
  }

  return [map {$_->[0]} @subtree];  # an ordered array containing only the references
                                  # to the nodes of the projectivized subtree is returned
}


sub AskCzEn ($$$$) {
# asks a question in Czech or English, returns 1 if the answer is positive, 0 otherwise
# if the locale language setting is Czech, it asks in Czech, otherwise English is used

  my ($titleCz, $messageCz, $titleEn, $messageEn) = @_;
  my ($title, $message, $yes, $no);

  use POSIX qw(locale_h);

    if (setlocale(LC_MESSAGES) =~ /^cs_CZ$|^czech/i) {
      ($yes, $no, $title, $message) = ("Ano", "Ne", $titleCz, $messageCz);
    } else {
      ($yes, $no, $title, $message) = ("Yes", "No", $titleEn, $messageEn);
    }

  my $d = ToplevelFrame()->DialogBox(-title => $title,
				       -buttons => [$yes, $no]
				      );
  $d->add(Label, -text => $message, -font => StandardTredFont(), -wraplength => 200)->pack;
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Right>',[sub { shift->focusNext; }]);
  $d->bind('all','<Left>',[sub { shift->focusPrev; }]);
  if ($d->Show eq $yes) {
    return 1
  } else {
    return 0
  };
}

sub MessageCzEn ($$) {
# displays a message in Czech or in English
  my ($messageCz, $messageEn) = @_;

  my ($title, $message);

  use POSIX qw(locale_h);

  if (setlocale(LC_MESSAGES) =~ /^cs_CZ$|^czech/i) {
    ($title, $message) = ("Zpráva", $messageCz);
  } else {
    ($title, $message) = ("Message", $messageEn);
  }
  my $d = ToplevelFrame()->DialogBox(-title => $title,
				       -buttons => ["OK"]
				      );
  $d->add(Label, -text => $message, -font => StandardTredFont(), -wraplength => 200)->pack;
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  $d->Show;
  return 1
}


sub AskProjectivityQuestion {
# ask appropriate question (about the whole tree or some subtree)
  my $top=ref($_[0]) ? $_[0] : $root;

  if ($top == $root) {
    AskCzEn("Varování", "Strom není projektivní. Chcete pokraèovat?", "Warning", "The tree is not projective. Continue anyway?")
  }
  else {
    AskCzEn("Varování", "Podstrom není projektivní. Chcete pokraèovat?", "Warning", "The subtree is not projective. Continue anyway?")
  }
}

sub CheckProjectivity {
# checks whether the current visible subtree or the whole tree
# (if no parameter is passed) is projective
# returns 1 if the subtree is projective (according to the visibility status of hidden nodes)
# 0 otherwise

  my $top=ref($_[0]) ? $_[0] : $root;
  # $top contains the reference to the node whose subtree is to be checked for projectivity (or roo)

  my $ProjectivizedSubTree=Projectivize($top,not(IsHidden($top)));  # projectivized subtree
  my $SubTree = IsHidden($top) ? [GetNodes($top)] : [GetVisibleNodes($top)] ;
  SortByOrd($SubTree);
     # subtree ordered according to the ordering attribute
  my ($proj, $sub) = ($#$ProjectivizedSubTree, $#$SubTree);
  my $differ = 0;  # suppose they do not differ

  if ($proj != $sub) {  # compares the actual subtree with the projectivized one
    return 0; # they differ
  }
  else {
    for (my $i=0; $i<=$proj; $i++) {
      if ($$ProjectivizedSubTree[$i] != $$SubTree[$i]) {
	return 0;  # they differ
      }
    }
    return 1
  }
}

sub ContinueProjectivizing {
# checks whether the current visible subtree or the whole tree
# (if no parameter is passed) is projective
# if it is not, is asks whether it should be projectivized
# if the user answers yes, it returns the whole projectivized subtree (including the hidden nodes)
# undef otherwise

  my $top=ref($_[0]) ? $_[0] : $root;
  # $top contains the reference to the node whose subtree is to be checked for projectivity (or roo)

  if (not(CheckProjectivity($top))) { # they are not the same !!!
    if (AskProjectivityQuestion($top)) {
      return Projectivize($top);  # continue, return the whole projectivized subtree
    } else {
      return;  # do not continue
    }

  } else {

    return Projectivize($top);  # continue by default if the subtree has already been projective
                                # return the whole projectivized subtree
  }
}


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
    if ($node eq $top) {
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

  my $top=ref($_[0]) ? $_[0] : $this; # $top contains the reference to the node whos
e subtree is to be projectivized

  return unless ProjectivizeSubTree($top);

  my $subtree=OrderByTFA($top);
  return unless $subtree;

  my $all=GetNodesExceptST([$top]);

  splice @$all,Index($all,$top),1, @$subtree;   # the subtree is spliced at the right place

  NormalizeOrds($all);  # the ordering attributes are modified accordingly
}


# ******************************* pre-set the attribute tfa *****************************************
sub PreSetTFASubTree {
# sets the tfa attribute for the subtree of a node passed as parameter or the root if no parameter is passed

  my $top=ref($_[0]) ? $_[0] : $root;  # the reference to the node whose subtree is to be set the tfa attribute

  my @all=GetNodes($root);
  SortByOrd(\@all);  # an array of all nodes in the tree ordered according to the ordering attribute

  for (my $node=$top; $node; $node=NextVisibleNode($node,$top)) {  # go through all nodes of the subtree

    print STDERR "==================  ".$node->{'trlemma'}." : ";
    my $verb=0;  # a flag (whether a finite verb is being processed)

    if ($node->{'func'} =~ /CONJ|DISJ|ADVS|CONFR|GRAD|CSQ|REAS|APPS/) { # non-applicable (conjunctions)
    print STDERR "  NA";
      $node->{'tfa'} = "NA";
      next;
    }
    # verbal phrase (finite verb)
    elsif ($node->{'tag'} =~ /^V[^f].*/) {
      print STDERR "  VP F";
      $node->{'tfa'} = "F";
      $verb = 1;  # set the verb flag
    }
#     # not covered by the rules
#     elsif ($node->{'tag'} !~ /^(N.*|Vp.*)/) {
#       print STDERR "++++++++++++  ".$node->{'trlemmma'}."not covered by rules ???\n";
#       $node->{'tfa'} = "???";
#       next;
#     }

    print STDERR "\n";

    # nominal phrase and infinitive remain

    # the things common to verbal and nominal phrases
    my (@leftmovedchildren, @rightmovedchildren, @prec, @neg)=();
    for (my $child=$node->firstson; $child; $child=$child->rbrother) {
      # reorder certain visible children and set the tfa attribute to all the visible children of the current node
      if (not IsHidden($child)) {
        print STDERR "   +++++++++  ".$child->{trlemma}.": ";
	# negation
	if ($child->{'func'} =~ /RHEM/ and $child->{'trlemma'} =~ /^(&)?Neg(;)?$/) {
	  print STDERR "   negation F\n";
	  $child->{'tfa'} = "F";
	  push @neg, splice @all, Index(\@all,$child), 1;
	}
	# certain modifiers are to be put immediately after their parent node
	elsif ($child->{'func'} =~ /MOD|MANN|EXT/) {
	  print STDERR "  modifiers F\n";
	  $child->{'tfa'} = "F";
	  push @rightmovedchildren, splice @all, Index(\@all,$child), 1;
	}
	# restored nodes to be put to the left of the governing node
	elsif ($child->{'ord'} =~ /\./) {
	  print STDERR "  restored nodes T\n";
	  $child->{'tfa'} = "T";
	  push @leftmovedchildren, splice @all, Index(\@all,$child), 1;
	}
	# nodes depending on a finite verb (TODO functors PREC and ATT)
	elsif ($verb) {
	  # actants
	  print STDERR "  verbal actants";
    	  if ($child->{'func'} =~ /ACT|PAT|ADDR|ORIG|EFF/) {
	    if (GetOrd($child) < GetOrd($node)) {
	      $child->{'tfa'} = "T";
	      print STDERR "  T\n";
	    }
	    else { 
	      $child->{'tfa'} = "F";
	      print STDERR "  F\n";
	    }
	  }
	  # other nodes
	  else {
	    print STDERR "  other verbal complements  T\n";
	    $child->{'tfa'} = "T";
	  }
	}
	# nodes depending on a nominal phrase
	# (all those not depending on a finite verb and not pertaining to the above categories
	else {
	  print STDERR " NP - ";
	  # pronouns (TODO subtypes)
	  if ($child->{'tag'} =~ /^P.*/) {
	    print STDERR "pronouns T\n";
	    $child->{'tfa'} = "T";
	  }
	  # other nodes
	  else {
	    print STDERR "other F\n";
    	    $child->{'tfa'} = "F";
	    # unshift @rightmovedchildren, splice @all, Index(\@all,$child), 1;  BETTER DO NOT MOVE ATTRIBUTES
	  }
	}
      }

    }  # for for children

    if (@leftmovedchildren) {
      print STDERR "    moved nodes - left: ";
      print STDERR join " ", map $_->{'trlemma'}, @leftmovedchildren;
      print STDERR "\n";
    }
    if (@neg) {
      print STDERR "    moved nodes - negation: ";
      print STDERR join " ", map $_->{'trlemma'}, @neg;
      print STDERR "\n";
    }
    if (@rightmovedchildren) {
      print STDERR "     moved nodes - right: ";
      print STDERR join " ", map $_->{'trlemma'}, @rightmovedchildren;
      print STDERR "\n";
    }

#    print STDERR join " ", map $_->{'trlemma'}, @all; print STDERR "     - 1\n";

    splice @all, Index(\@all,$node), 0, @leftmovedchildren, @neg;

#    print STDERR join " ", map $_->{'trlemma'}, @all; print STDERR "     - 2\n";

    splice @all, Index(\@all,$node)+1, 0, @rightmovedchildren;

#    print STDERR join " ", map $_->{'trlemma'}, @all; print STDERR "     - 3\n";

    NormalizeOrds(\@all);

  }  # the global for

#   # set the tfa attribute to tha added nodes and nodes considered as bound or tfa non-applicable
#   if ($node->{'func') =~ /CONJ|DISJ|ADVS|CONFR|GRAD|CSQ|REAS|APPS/) { # non-applicable
#     $node->{'tfa'} = "NA";
#   } elsif ($node->{'func'} =~ /MOD|MANN|EXT/) { # modifiers are to be put immediately after their parent node
#   }

#   my @nodes;
#   while ($node) { # get all original nodes
#     if ($node != $top) { # preset all except the root as non-bound
#       $node->{'tfa'} = "F";
#     }
#     push @nodes,$node if $node->{ord} !~ /./;
#     $node=$node->following($top);
#   }

#   sort {$a->{'ord'} <=> $b->{'ord'}} @nodes;  # sort the array according to the original surface ordering

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
      PreSetTFASubTree($node);
    }
  }
}

sub Move {
# move the node specified by the first parameter right after the node specified in the second parameter

  my $top=$_[0];
  return unless $top;

  my $after= ref($_[1]) ? $_[1] : $root;  # if no node to place after is specified, it is taken to be the root node

  my $all = [GetNodes($top)];
  SortByOrd($all);

  splice @$all,Index($all,$top),1;   # the top node is cut off from the array
  splice @$all,Index($all,$after)+1,0,$top;   # the top node is spliced after the appropriate node

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


#************************** shifting subtrees ****************************************************
sub MoveST {
# move the subtree specified by the first parameter right after the node specified in the second parameter

  my $top=$_[0];
  return unless $top;

  return unless my $subtree=ContinueProjectivizing($top);

  my $after= ref($_[1]) ? $_[1] : $root;  # if no node to place after is specified, it is taken to be the root node

  my $all=GetNodesExceptST([$top]);

  splice @$all,Index($all,$top),1;   # the top node is cut off from the array
  splice @$all,Index($all,$after)+1,0,@$subtree;   # the subtree is spliced after the appropriate node

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSTLeft {
# moves the (projectivized) subtree of a given node one node left,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeLeft($this);
  } else {
    ShiftSubTreeLeftSkipHidden($this);
  }
}


sub ShiftSTRight {
# moves the (projectivized) subtree of a given node one node right,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeRight($this);
  } else {
    ShiftSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeLeft {
# moves the (projectivized) subtree of a given node one node left (with respect to all nodes)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $i=Index($all,$top);  # locate the given node in the array @all
  if ($i>1) {  # check if there is place where to move (the root is always number zero)
    splice @$all,$i,1;  # cut out the given node
    splice @$all,$i-1,0, @$subtree;  # splice the projectivized subtree at the right (ie left ;-) place
  }
  else {
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtree
                                 # instead of the given node - thus the subtree gets projectivized
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeRight {
# moves the (projectivized) subtree of a given node one node right (with respect to all nodes)
# see ShiftSubTreeLeft

  my $top=ref($_[0]) ? $_[0] : $this;

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $i=Index($all,$top);
  if ($i<$#$all) {
    splice @$all,$i,1;
    splice @$all,$i+1,0, @$subtree;
  }
  else {
    splice @$all,$i,1, @$subtree;
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeLeftSkipHidden {
# moves the (projectivized) subtree of a given node one node left (with respect to non-hidden nodes only)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  return unless my $subtree=ContinueProjectivizing($top);  # the projectivized subtree

  my $all=GetNodesExceptST([$top]);  # all nodes except the nodes depending on the given node

  my $allvis=GetNodesExceptST([$top],1); # all visible (ie non-hidden) nodes except the nodes depending on the given node

  my $i=Index($allvis,$top);  # locate the given node within the array @allvis
  if ($i>1) {  # if there is room where to move
    splice @$all,Index($all,$top),1;  # cut the given node
    splice @$all,Index($all,$$allvis[$i-1]),0, @$subtree;  # locate the first visible node to the left
                                                    # and splice the projectivized subtree accordingly
  }
  else {  # nowhere to move, the subtree of the given node gets projectivized
    splice @$all,Index($all,$top),1, @$subtree;
  }

  NormalizeOrds($all);

}


sub ShiftSubTreeRightSkipHidden {
# moves the (projectivized) subtree of a given node one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeLeftSkipHidden

  my $top=ref($_[0]) ? $_[0] : $this;

  return unless my $subtree=ContinueProjectivizing($top);

  my $all=GetNodesExceptST([$top]);

  my $allvis=GetNodesExceptST([$top],1);

  my $i=Index($allvis,$top);
  if ($i<$#$allvis) {
    splice @$all,Index($all,$top),1;
    splice @$all,Index($all,$$allvis[$i+1])+1,0, @$subtree;
  }
  else {
    splice @$all,Index($all,$top),1, @$subtree;
  }

  NormalizeOrds($all);

}

#************************** switching subtrees ****************************************************
sub brothernodes {
# return an array of all the brothers of the given node (including itself)
# according to the visibility status
  my $node = ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed
  my @brothers;
  while ($node->lbrother) {$node=$node->lbrother};  # get to the leftmost brother
  if ($_[1]) {               # @brothers is filled only with the visible brothers
    while ($node) {push @brothers,$node unless IsHidden($node); $node=$node->rbrother};
  }
  else {                     # @brothers is filled with all brothers
    while ($node) {push @brothers,$node; $node=$node->rbrother};
  };
  SortByOrd(\@brothers);
  return @brothers;
}

sub ShiftSToverSTLeft {
# switches the (projectivized) subtree of the current node with the (projectivized) subtree to the left,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeOverSubTreeLeft($this);
  } else {
    ShiftSubTreeOverSubTreeLeftSkipHidden($this);
  }
}


sub ShiftSToverSTRight {
# switches the (projectivized) subtree of the current node with the (projectivized) subtree to the right,
# according to the visibility-of-hidden-nodes status
  return unless (GetOrd($this)>0);
  if (HiddenVisible()) {
    ShiftSubTreeOverSubTreeRight($this);
  } else {
    ShiftSubTreeOverSubTreeRightSkipHidden($this);
  }
}


sub ShiftSubTreeOverSubTreeLeft {
  # moves the (projectivized) subtree of a given node one subtree left (with respect to all nodes)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  my @brothers = brothernodes($top);

  my $switch = $brothers[max(Index(\@brothers,$top)-1,0)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

      splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
      splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place

  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}

sub ShiftSubTreeOverSubTreeRight {
# moves the (projectivized) subtree of a given node one node right (with respect to all nodes)
# see ShiftSubTreeOverSubTreeLeft

  my $top=ref($_[0]) ? $_[0] : $this;

  my @brothers = brothernodes($top);

  my $switch = $brothers[min(Index(\@brothers,$top)+1,$#brothers)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

    splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place
    splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeOverSubTreeLeftSkipHidden {
# moves the (projectivized) subtree of a given node one subtree left (with respect to non-hidden nodes only)

  my $top=ref($_[0]) ? $_[0] : $this;  # if no parameter is passed,
                                       # take $this to be the reference to the node to be processed

  my @brothers = brothernodes($top,1);

  my $switch = $brothers[max(Index(\@brothers,$top)-1,0)];

  my $all=GetNodesExceptST([$top,$switch]);  # all nodes except the nodes depending on the given node

#  my $allvis=GetNodesExceptST([$top,$switch],1); # all visible (ie non-hidden) nodes except the nodes depending on the given nodes
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtree back
    #  - thus the subtree gets projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

      splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place
      splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place

  }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


sub ShiftSubTreeOverSubTreeRightSkipHidden {
# moves the (projectivized) subtree of a given node one node right (with respect to non-hidden nodes only)
# see ShiftSubTreeOverSubTreeLeftSkipHidden
  my $top=ref($_[0]) ? $_[0] : $this;

  my @brothers = brothernodes($top,1);

  my $switch = $brothers[min(Index(\@brothers,$top)+1,$#brothers)];

  my $all=GetNodesExceptST([$top,$switch]);
  my $i=Index($all,$top);  # locate the given node in the array @all

  if ($top == $switch) {
    return unless my $subtree=ContinueProjectivizing($top);
    splice @$all,$i,1, @$subtree;  # if there is no room where to move, just splice the proj. subtrees
    # instead of the given nodes - thus the subtrees get projectivized
  }

  else {
    return unless
      (my $subtree=ContinueProjectivizing($top)) and (my $switchsubtree=ContinueProjectivizing($switch));

    my $si=Index($all,$switch); # locate the switching node in the array @all

    splice @$all,$si,1,@$subtree;   # splice the projectivized moving subtree at the right place
    splice @$all,$i,1,@$switchsubtree;  # splice the projectivized switching subtree at the right place

    }

  NormalizeOrds($all);  # the ordering attributes are modified accordingly

}


# *************************************************************************************
# *************************************************************************************
# *************************************************************************************
# *************************************************************************************

# sub OrderByTFA {
# # orders the current subtree according to the value of the tfa attribute
# # and returns an ordered array containing the subtree
# # checks for projectivity, then accordingly orders the subtrees of the top node
# # it only shuffles the whole sons' subtrees !!!

#   my $top=$_[0];  # the reference to the node whose subtree is to be ordered according to tfa

#   return unless ref($top);  # no valid reference parameter was passed

#   my $value=$top->{tfa};  # the tfa value for the top node

#   if ((IsHidden($top)) or ($value !~ /T|C|F/)) {
#     # does not do anything on hidden nodes and on nodes with NA or no tfa value
#     NotOrderableByTFA;
#     return
#   }

#   my (@subtree, @sons_C, @sons_T, @sons_F, @sons_hidden);
#   my $ord=$grp->{FSFile}->FS->order;  # the ordering attribute

#   # place the top node appropriately among its sons
#   if (($value eq "C") or ($value eq "T")) {
#     push @sons_T, $top
#   } elsif ($value eq "F") {
#     push @sons_F, $top
#   } else {  # return if the top node's tfa value is not acceptable
#     NotOrderableByTFA;
#     return
#   }

#   my $node;
#   # now go through the sons
#   for ($node=$top->firstson; $node; $node=$node->rbrother) {

#     if (IsHidden($node)) {push @sons_hidden, $node}  # the node is hidden
#     else {  # decide according to the tfa value of the node
#       $value=$node->{tfa};  # the tfa value of the node

#       if ($value eq "C") {push @sons_C, $node}
#       elsif ($value eq "T") {push @sons_T, $node}
#       elsif ($value eq "F") {push @sons_F, $node}
#       elsif ($value eq "NA") {
# 	# in this case decide according to the tfa value of depending nodes
# 	# if there is at least one depending node with F, place the current node among F nodes
# 	# otherwise if there is at least one with T, place the current node among T nodes, return otherwise
# 	my @nodes= HiddenVisible() ? GetNodes($node) : GetVisibleNodes($node);
# 	# look at appropriate nodes according to the visibility-of-hidden-nodes status
# 	my ($hasTorC, $hasF);
# 	while (@nodes) {  # checks whether at least some depending node has tfa value
# 	  my $value=shift(@nodes)->{tfa};
# 	  if (($value eq "C") or ($value eq "T")) {$hasTorC=1}
# 	  elsif ($value eq "F") {$hasF=1}
# 	}
# 	if ($hasF or $hasTorC) {  # there is a depending node with tfa value
# 	  if ($hasF) {push @sons_F, $node}
# 	  else {push @sons_T, $node}
# 	} else {  # no depending node has a tfa value, therefore return
# 	  NotOrderableByTFA;
# 	  return
# 	}
#       }
#       else {  # return if there is a node that is visible and doesn't have tfa value
# 	NotOrderableByTFA;
# 	return
#       }
#     }
#   }

#   @sons_C= sort {$a->{$ord} <=> $b->{$ord}} @sons_C;
#   @sons_T= sort {$a->{$ord} <=> $b->{$ord}} @sons_T;
#   @sons_F= sort {$a->{$ord} <=> $b->{$ord}} @sons_F;
#   @sons_hidden= sort {$a->{$ord} <=> $b->{$ord}} @sons_hidden;

#   foreach $node (@sons_C, @sons_T, @sons_F, @sons_hidden) {
#     # creates an ordered array with the subtree ordered according to tfa
#     if ($node eq $top) {
#       push @subtree, $node  # only the top node
#     } else {
#       my @sonssubtree=GetNodes($node);
#       SortByOrd(\@sonssubtree);
#       push @subtree, @sonssubtree  # push a son's subtree
#     }
#   }
#   return \@subtree
# }



#  sub ShiftSubTreeLeft {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;
#    return 0 if ($node->{$ord} < $min);
#    Projectivize($node);
#    my @all=GetNodes();
#    SortByOrd(\@all);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)),0);
#    $all[$x--]->{$ord}=$y;
#    for (my $i=$x;$i<=$y;$i++) { $all[$i]->{$ord}--; }
#    RepasteNode($node);
#  }



#  sub ShiftSubTreeLeftSkipHidden {
#    my ($node,$min)=@_;          # min sets the minimum left...
#    my $ord=$grp->{FSFile}->FS->order;     # ... boundary for Ord
#    return unless $node;

#    Projectivize($node);

#    my @all=GetNodes();
#    SortByOrd(\@all);

#  #  print "$n\n";

#    my @vis=GetVisibleNodes();
#    SortByOrd(\@vis);
#    my $m=Index(\@vis,$node);
#    my $beforethis=$vis[$m-1];

#    my $n=$node->{$ord};
#    return 0 if ($n < $min);

#    return undef unless (defined($m) and !defined($min) || $m>$min);
#    my $x=max(Index(\@all,leftmost_descendant($node)]),0);
#    my $y=max(Index(\@all,rightmost_descendant($node)]),0);
#    for (my $i=$n-1;$i>=$x;$i--) { $all[$i]->{$ord}++; }
#    $node->{$ord}=$x;
#    RepasteNode($node);
#  }
