# -*- cperl -*-
#encoding iso-8859-2

#########################
# Frame validation code #
#########################

sub _highest_coord {
  my ($node)=@_;
  while (PDT::is_valid_member_TR($node)) {
    $node=$node->parent;
  }
  return $node;
}

sub match_node_coord {
  my ($node, $fn,$aids,$loose_lemma) = @_;
  my $res = match_node($node,$fn,$aids,0,$loose_lemma);
  if (!$res and $node->{afun} =~ /^Coord|^Apos/) {
    foreach (grep { $node->{lemma} ne 'a-1' or $_->{lemma}!~/^(podobnì|daleko-1|dal¹í)(_|$)/ }
	     with_AR{PDT::expand_coord_apos($node)}) {
      return 0 unless match_node($_,$fn,$aids,0,$loose_lemma);
    }
    return 1;
  } else {
    return $res;
  }
}

sub get_aidrefs_nodes {
  my ($aids,$node)=@_;
  return grep { defined($_) } map { $aids->{$_} } grep { $_ ne "" } getAIDREFs($node);
}

sub match_node {
  my ($node, $fn, $aids,$no_case,$loose_lemma) = @_;
  my ($lemma,$form,$pos,$case,$gen,$num,$deg,$neg,$agreement)=map {$fn->getAttribute($_)} qw(lemma form pos case gen num deg neg agreement);
  print "TRYING: $node->{tag}, $node->{lemma}  .... $lemma,$pos,$case,$gen,$num,$deg\n" if $V_verbose;

  if ($lemma ne '') {
    my $l = $node->{lemma};
    $l =~ s/[_`&].*$//;
    if ($lemma=~/^\{(.*)\}$/) {
      my $list = $1;
      my @l = split /,/,$list;
      return 0 unless (first { (!$loose_lemma and $_ eq '...')
			       or $_ eq $l } @l)
    } else {
      return 0 unless $lemma eq $l;
    }
  }
  if ($agreement) {
    my ($p)=with_AR{PDT::GetFather_AR($node,sub{shift->{afun}=~/Aux[CP]/?1:0})};
    if ($p) {
      $p->{tag}=~/^....(\d)/;
      $case=$1 if ($case ne '' and $1);
      $p->{tag}=~/^...([SP])/;
      $num=$1 if ($num ne '' and $1);
      $p->{tag}=~/^..([FMIN])/;
      $gen=$1 if ($gen ne '' and $1);
    } else {
      print "AGREEMENT REQUESTED BUT NO PARENT: ",$fn->toString(),"\n" if $V_verbose;
      return 0;
    }
  }
  if ($form ne '') {
    if (lc($form) eq $form) { # form is lowercase => assume case insensitive
      return 0 if $form ne lc($node->{form});
    } else {
      return 0 if $form ne $node->{form};
    }
  }
  if ($gen ne '') {
    return 0 if $node->{tag}=~/^..([FMIN])/ and $gen ne $1;
  }
  if ($neg eq 'negative') {
    return 0 unless $node->{tag}=~/^..........N/;
  }

  if (!$no_case and $case ne '') {
    return 0 if ((($node->{tag}=~/^....(\d)/ and $case ne $1) or
		  ($node->{tag}!~/^[NCPAX]/ and $node->{lemma} !~ /^(?:&percnt;|hodnì|málo-3|dost)(?:`|$|_)/))
		 and
		 not ($node->{tag}=~/^C...\D/ and not with_AR { PDT::GetChildren_AR($node,sub{1},sub{0}) }) and
		 not ($node->{tag}=~/^....2/ and
		      first {
			($_->{tag} =~ /^C/ or $_->{lemma} =~ /^(?:dost|málo-3|hodnì|sto-[12]|tisíc-[12]|milión|miliarda)(?:`|$|_)/) and
			($_->{tag}!~/^....(\d)/ or $case eq $1 or
			 ($1 eq '4' and first { $_->{lemma} eq 'pøes-1' } get_aidrefs_nodes($aids,$_) or
			  $1 eq '2' and first { $_->{lemma} eq 'kolem-1' } get_aidrefs_nodes($aids,$_)))
		      } with_AR { (PDT::GetFather_AR($node,sub{shift->{afun}=~/Aux[CP]/?1:0}),
				   PDT::GetChildren_AR($node,sub{1},sub{shift->{afun}=~/Aux[CP]/?1:0})) })
   );
  }
  if ($pos ne '') {
    if ($pos =~ /^[adnijv]$/) {
      $pos = uc($pos);
      return 0 if $node->{tag}!~/^$pos/;
    } elsif ($pos eq 'f') {
      return 0 unless $node->{tag}=~/^Vf/;
    } elsif ($pos eq 'u') {
      return 0 unless $node->{tag}=~/^AU|^PS/;
    } else {
      # TODO: c s
      return 0 unless $node->{tag}=~/^V/;
    }
  }
  if ($num ne '') {
    return 0 if $node->{tag}=~/^...([SP])/ and $num ne $1;
  }
  if ($deg ne '') {
    return 0 if $node->{tag}=~/^........([123])/ and $deg ne $1;
  }
  foreach my $tagpos (1..15) {
    if (my $tag = $fn->getAttribute('tagpos'.$tagpos)) {
      return 0 if substr($node->{tag},$tagpos-1,1) !~ /[\Q$tag\E]/;
    }
  }
  foreach my $ffn ($fn->getChildrenByTagName('node')) {
    unless (first { match_node_coord($_,$ffn,$aids,$loose_lemma) } with_AR { $node->children }) {
      print "CHILDMISMATCH: ",$ffn->toString(),"\n" if $V_verbose;
      return 0;
    }
  }
  print "MATCH: $node->{lemma} $node->{form} $node->{tag} ==> ",$fn->toString(),"\n" if $V_verbose;
  return 1;
}

sub match_form {
  my ($node, $form, $aids, $loose_lemma) = @_;
  my @a = get_aidrefs_nodes($aids,$node);
  my $no_case=0;
  if ($node->{TID} ne "") {
    $no_case=1;
  }
  if (@a) {
    my ($parent) = $form->getChildrenByTagName('parent');
    my ($pnode) = $parent->getChildrenByTagName('node') if $parent;
    if ($pnode) {
      foreach my $p (PDT::GetFather_TR($node)) {
	unless (match_node($p,$pnode,$aids,0,$loose_lemma)) {
	  print "PARENT-CONSTRAINT MISMATCH: $p->{lemma} $p->{form} $p->{tag} ==> ",$pnode->toString(),"\n" if $V_verbose;
	  return 0;
	}
      }
    }
    my @form_nodes = $form->getChildrenByTagName('node');
    if (@form_nodes) {
      foreach my $fn (@form_nodes) {
	unless (first { match_node($_,$fn,$aids,$no_case,$loose_lemma) } @a) {
	  print "MISMATCH: $node->{lemma} $node->{form} $node->{tag} ==> ",$fn->toString(),"\n"
	    if $V_verbose;
	  return 0;
	}
      }
      return 1;
    } elsif ($form->getChildrenByTagName('typical')) {
      # TODO: somebody pls provide me the map of functors and their typical forms
      return 1;
    } elsif ($form->getChildrenByTagName('elided')) {
      return ($node->{AID} eq "" and $node->{AIDREFS} eq "") ? 1 : 0
    } elsif ($form->getChildrenByTagName('recip')) {
      return ($node->{trlemma} ne "&Rcp;") ?  1 : 0; # correct?
    } elsif ($form->getChildrenByTagName('state')) {
      return ($node->{state} eq "ST") ? 1 : 0;
    } else {
      print "UNSPECIFIED FORM: ==> ",$form->toString(),"\n" if $V_verbose;
      return 1;
    }
  } else {
    print "NOAIDREFS: $node->{lemma} $node->{form}\n" if $V_verbose;
    if ($node->{tag} ne '-') {
      print "WW no AIDREFs: $node->{trlemma}\t";
      Position($node);
    }
    # hm, really nothing to check here? If yes, we have to assume a match.
    # TODO: we still have to check something, e.g. lemma, pos; probably not case,
    # prepositions, number, gender
    return 1;
  }
  print "Why I'm here?\n";
  return 0;
}

sub get_func { join '|',grep {$_ ne '???'} split /\|/, $_[0]->{func} };

sub frame_matches_rule ($$$) {
  my ($V,$frame,$frame_test) = @_;
  foreach my $el (@$frame_test) {
    if (ref($el)) { # match a regexp
      my ($func, $regexp)=@$el;
      my $oblig = ($func=~s/^\?// ? 1 : 0);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->elements($frame);
      if (!defined($element)) {
	return 0 unless $oblig;
	next;
      }
      return 0 unless first { /$regexp/ } map { $V->serialize_form($_) } $V->forms($element);
    } elsif ($el =~ /^(\?)?([[:upper:]]*)\((.*)\)$/) {
      my ($oblig, $func, $forms)=($1,$2,$3);
      $func = '---' if $func eq "";
      my ($element) = grep { $V->func($_) eq $func } $V->elements($frame);
      if (!defined($element)) {
	return 0 unless $oblig;
	next;
      }
      my @forms = $V->split_serialized_forms($forms);
      next unless @forms;
      my %forms = map { $V->serialize_form($_) => 1 } $V->forms($element);
      foreach my $form (@forms) {
	$form = TrEd::ValLex::Data::expandFormAbbrevs($form);
	return 0 unless $forms{$form};
      }
    } else {
      die "Can't parse frame rule element: $el\n";
    }
  }
  return 1;
}

sub transform_frame {
  my ($V,$old_frame,$frame_trans) = @_;
  my $new = $V->clone_frame($old_frame);
  foreach my $trans (@$frame_trans) {
    if (ref($trans)) { # match a regexp
      my ($func, $code)=@$trans;
      my $oblig = ($func=~s/^\?// ? 1 : 0);
      $func = '---' if $func eq "";
      if (!defined($func)) {
        # TODO: transform verb form
	next;
      }

      my ($element) = grep { $V->func($_) eq $func } $V->elements($new);
      next unless $element; # nothing to do
      foreach my $form ($V->forms($element)) {
	my $old_form = $V->serialize_form($form);
	my $new_form =
	  eval {
	    local $_ = $old_form;
	    &$code;
	    $_;
	  };
	$new_form = TrEd::ValLex::Data::expandFormAbbrevs($new_form);
	if ($old_form ne $new_form) {
	  $V->remove_node($form);
	  $V->new_element_form($element,$new_form);
	}
      }
    } elsif ($trans=~/^([\-\+])(\??)([[:upper:]]*)?(?:\((.*)\))?$/) {
      my ($add_or_remove,$type,$func,$forms)=($1,$2,$3,$4);
      $func = '---' if $func eq "";

      if (!defined($func)) {
        # TODO: transform verb form
	next;
      }

      my ($element) = grep { $V->func($_) eq $func } $V->elements($new);
      next unless $element or $add_or_remove eq "+"; # nothing to remove

      # remove the whole element if the deletion rule has no form-list
      if (!defined($forms) and $add_or_remove eq "-") {
	$V->remove_node($element) if ($element);
	next;
      }

      if (not($element) and $add_or_remove eq "+") {
	# create new element
	$element = $V->new_frame_element($new,$func,$type);
      }

      my @forms = $V->split_serialized_forms($forms);
      next unless @forms;
      my %forms = map { $V->serialize_form($_) => $_ } $V->forms($element);
      foreach my $form (@forms) {
	$form = TrEd::ValLex::Data::expandFormAbbrevs($form);
	if ($add_or_remove eq "+") {
	  # add form
	  $forms{$form} = $V->new_element_form($element, $form) unless ($forms{$form});
	} else {
	  # remove form
	  $V->remove_node($forms{$form}) if ($forms{$form});
	}
      }
    } else {
      die "Invalid frame form transform rule: $trans\n";
    }
  }
  return $new;
}

sub do_transform_frame {
  my ($V,$trans_rules,$node, $frame,$aids,$quiet) = @_;
  my ($i, $j)=(0,0);
  TRANS:
  foreach my $rule (@$trans_rules) {
    $i++; $j=0;
    my ($verbtest,@frame_tests) = @$rule;
    if ($verbtest->($node,$aids)) { # check if rule matches verb
      while (@frame_tests) {
	$j++;
	my $cache_key = "r:$i t:$j $f:".$V->frame_id($frame);
	if ($cached_trans_frames{$cache_key}) {
	  print "applying rule $cache_key\n";
	  $frame = $cached_trans_frames{$cache_key};
	  last TRANS;
	} else {
	  my ($frame_test,$frame_trans)=(shift @frame_tests, shift @frame_tests);
	  print "testing rule $cache_key\n" if (!$quiet and $V_verbose);
	  if (frame_matches_rule($V,$frame,$frame_test)) {
	    print "applying rule $cache_key\n" if (!$quiet and $V_verbose);
	    $frame = transform_frame($V,$frame,$frame_trans);
	    $cached_trans_frame{$cache_key} = $frame;
	  }
	}
      }
    }
  }
  return $frame;
}

sub validate_frame {
  my ($V,$trans_rules,$node, $frame,$aids,$pj4,$quiet) = @_;
  $frame = do_transform_frame($V,$trans_rules,$node, $frame,$aids,$quiet);

  my %oblig = map { $V->func($_) => $_ } $V->oblig($frame);
  my %nonoblig = map { $V->func($_) => $_ } $V->nonoblig($frame);
  my ($word_form) = $V->word_form($frame);

  if ($word_form) {
    my @forms = $V->forms($word_form);
    print $word_form->toString()."\n" if (!$quiet and $V_verbose);
    if (@forms) {
      unless (grep { match_form($node,$_,$aids) } @forms) {
	unless ($quiet) {
	  print "11 no word form matches: $node->{lemma},$node->{tag}\t";
	  Position($node);
	}
	$node->{_light}='_LIGHT_';
	return 0;
      }
    }
  }

  my @c = PDT::GetChildren_TR($node);


  # we must include children of ktery/jaky/... in relative subclauses
  # co-referring to the current node
  if ($node->{tag}=~/^N/ and @$pj4) {
    my $id = $node->{AID}.$node->{TID};
    my @d = grep { grep { $_ eq $id } split /\|/,$_->{coref} } @$pj4;
    #    if (@d) {
    #      print "20 found ".scalar(@d)." refering ",join "/",(map { $_->{trlemma} } @d),"\t";
    #      Position($node);
    #    }
    @d = map { PDT::GetChildren_TR($_) } @d;
    if (@d) {
      print "22 found children of pz4:".scalar(@d)."\t";
      Position($node);
    }
    push @c,@d;
  }

  # ignore all coordinated members right of a "coz" on the level of "coz"'s parent
  my %ignore;
  foreach $m (@c) {
    if (($m->{tag}=~/^V/ or $m->{trlemma} eq '&Emp;') 
	and PDT::is_coord_TR($m->parent) and
	first { $_->{trlemma} eq "co¾" } PDT::GetChildren_TR($m)) {
      $ignore{$m}=1;
      print "WW should ignore node: '$m->{trlemma}'\n" if (!$quiet and $V_verbose);
      if ($m->{AID} ne "") {
	for (grep { $_->{func} eq $m->{func} }
	     map { PDT::expand_coord_apos_TR($_) }
	     grep { PDT::is_valid_member_TR($_) and $_->{AID} ne "" and $_->{sentord} > $m->{sentord}  }
	     $m->parent->children) {
	  print "WW should also ignore node: '$_->{trlemma}'\n" if (!$quiet and $V_verbose);
	  $ignore{$_}=1;
	}
      }
    }
  }
  @c = grep {
	if ($ignore{$_}) {
	  print "WW ignoring node: '$_->{trlemma}'\n" if (!$quiet and $V_verbose);
	}
	!$ignore{$_};
       } @c;


  my %c;
  foreach (@c) {
    push @{$c{get_func($_)}}, $_;
  }

  foreach my $o (keys %oblig) {
    unless (exists($c{$o})) {
      unless ($quiet) {
	print "06 missing obligatory element: '$o'\t";
	Position($node);
	print $frame->toString()."\n" if (!$quiet and $V_verbose);
      }
      return 0;
    }
  }
  foreach my $ac (@actants) {
    if (exists($c{$ac}) and not($oblig{$ac} or $nonoblig{$ac})) {
      unless ($quiet) {
	print "07 actant present in data but not in vallex: $ac\t";
	Position($node);
      }
      return 0;
    } elsif (exists $c{$ac}) {
      if (@{$c{$ac}} > 1) {
	my @ancestors = uniq map { _highest_coord($_) } @{$c{$ac}};
	if (@ancestors > 1) {
	  unless ($quiet) {
	    print "08 multiple actants: $ac\t";
	    Position($node);
	  }
	  return 0;
	}
      }
    }
  }

  foreach my $c (@c) {
    my $e = $oblig{get_func($c)} || $nonoblig{get_func($c)};
    next unless ($e);
    my @forms = $V->forms($e);
    print $e->toString()."\n" if (!$quiet and $V_verbose);
    if (@forms) {
      unless (grep { match_form($c,$_,$aids) } @forms) {
	unless ($quiet) {
	  print "09 no form matches: $c->{func},$c->{lemma},$c->{tag}\t";
	  Position($node);
	}
	$c->{_light}='_LIGHT_';
	return 0;
      }
    }
  }
  return 1;
}

sub resolve_substitution_for_assigned_frames {
  my ($V,$node)=@_;
  my $lemma = $node->{trlemma};
  $lemma =~ s/_/ /g;
  my @frameids;
  foreach my $fi (split /\|/, $node->{frameid}) {
    print "resolving $fi\n";
    my $frame = $V->by_id($fi);
    if (ref($frame)) {
      my @valid = $V->valid_frames_for($frame);
      if (@valid) {
	foreach my $vframe (@valid) {
	  if ($V->word_lemma($V->frame_word($vframe)) eq $lemma) {
	    push @frameids, $V->frame_id($vframe);
	    print "OK: $fi resolves to ".$V->frame_id($vframe)."\n";
	  } else {
	    print "FAIL: $fi resolves to ".$V->frame_id($vframe)." with different lemma\n";
	  }
	}
      } else {
	print "$fi doesn't resolve\n";
      }
    } else {
      print "FAIL: $fi not found\n";
    }
  }
  return join '|',@frameids;
}

sub hash_pj4 {
  my ($tree)=shift;
  return [ grep { $_->{tag}=~/^PJ/ or ($_->{tag}=~/^P4/ and $_->{lemma}=~/^kterı$|^jakı$|^co-4/)
		} $tree->descendants ];
}
