# -*- cperl -*-
## Macros that postprocess netgraph queries converted to Tree_Query


sub fix_netgraph_ord_to_precedes {
  my ($test) = @_;
  return unless $test->{'#name'} eq 'test' and $test->{operator}=~/[<>]/;
  my ($x,$y)=($test->{a},$test->{b});
  if ($test->{operator} =~/>/) {
    ($x,$y)=($y,$x);
  }
  my $node = first { $_->{'#name'}=~/^(?:node|subquery)$/ } $test->ancestors;
  return unless $node;
  my $ord = (get_query_node_type($node) eq 't') ? 'tfa/deepord' : 'ord';
  my $end;
  my $rel;
  if ($x eq qq($ord) and $y=~/^([[:alnum:]]+)\.\Q$ord\E$/) {
    $end = $name2node_hash{lc($1)};
    $rel  = 'order-precedes';
  } elsif ($y eq qq($ord) and $x=~/^([[:alnum:]]+)\.\Q$ord\E$/) {
    $end=$name2node_hash{lc($1)};
    $rel  = 'order-follows';
  }
  if ($end) {
    my $ref = NewRBrother($test);
    $ref->{'#name'}='ref';
    DetermineNodeType($ref);
    $ref->{target}=$end->{name};
    SetRelation($ref,$rel);
    DeleteLeafNode($test);
    ChangingFile(1);
    return $ref
  }
}

sub fix_tecto_coap {
  my ($node) = @_;
  return unless $node->{'#name'} eq 'test';
  if ($node->{operator} eq 'in'
      and $node->{a} eq q(functor)) {
    my $y = $node->{b};
    $y=~s/\s//g;
    $y=~s/^{|}$//g;
    if (join(',',uniq sort split(/,/,$y)) eq q('ADVS','APPS','CONFR','CONJ','CONTRA','CSQ','DISJ','GRAD','OPER','REAS')) {
      $node->{a} = q(nodetype);
      $node->{b} = q('coap');
      $node->{operator} = '=';
      ChangingFile(1);
    }
  }
}

sub fix_or2in {
  my ($or) = @_;
  return unless $or->{'#name'} eq 'or';
  my @tests = $or->childnodes;
  if (@tests>3
      and !(first { !($_->{'#name'} eq 'test' and $_->{operator} eq '=') } @tests) # all are tests with =
      and !(first { !($_->{a} eq $tests[0]->{a}) } @tests)            # all have the same a
     ) {
    ChangingFile(1);
    $tests[0]->{operator}='in';
    $tests[0]->{b}='('.join(',', sort map { $_->{b} } @tests) .')';
    DeleteLeafNode($_) for (@tests[1..$#tests]);
  }
}

sub reduce_similar_siblings {
  my ($node)=@_;
  my $name = $node->{'#name'}||'';
  return if $name eq 'test' or $name eq 'ref'; # atoms
  for my $c ($node->children) {
    reduce_similar_siblings($c);
  }
  my %c;
  for my $c (grep { $_->{'#name'} eq 'node' } $node->children) {
    # TODO: the nodes should not be referred to from anywhere
    # or, if so, from the same node in the exact same way,
    # which may be hard to verify
    my $k = as_text($c);
    $k=~s/^\s*|\s*$//g;
    push @{$c{$k}}, $c;
  }
  for my $k (keys %c) {
    next unless @{$c{$k}}>1;
    my $first = shift @{$c{$k}};
    ChangingFile(1);
    $first->set_type(undef);
    $first->{'#name'} = 'subquery';
    $first->{occurrences}=Fslib::Struct->new({min => @{$c{$k}}+1});
    DetermineNodeType($first);
    DeleteSubtree($_) for @{$c{$k}};
  }
}

sub __test_optional_chain {
  my ($node)=@_;
  return unless $node;
  my @kids = grep { $_->{'#name'} eq 'node' } $node->children;
  my $son = $kids[0];
  return (
    @kids==1
    and ((grep { $_->{'#name'} eq 'node' } $son->children)<=1)
    and (!$son->{relation} or $son->{relation}->name_at(0) eq 'child')
    and $node->{'#name'} ne 'subquery'
    and (!$node->{relation} or $node->{relation}->name_at(0) eq 'child')
  )
  ? 1 : 0;
}

sub reduce_optional_node_chain {
  my ($node)=@_;
  return unless $node->{'#name'} eq 'node';
  my $parent = $node->parent;
  return unless $parent and $parent->parent;
  my $conditions = as_text($node,{no_childnodes=>1});
  my $last = $node;
  my $max_length=0;
  my $min_length=0;
  while ( $last and __test_optional_chain($last) and ($last==$node or $conditions eq as_text($last,{no_childnodes=>1}))) {
    $max_length++;
    $min_length++ unless $last->{optional};
    ($last) = grep { $_->{'#name'} eq 'node' } $last->children;
  }
  if ($max_length>1) {
    ChangingFile(1);
    # trim the chain between $node and $last
    my @kids = reverse grep { $_->{'#name'} ne 'node' } $node->children;
    my $subquery;
    if (@kids) {
      $subquery = NewRBrother($node);
      $subquery->{'#name'} = 'subquery';
      DetermineNodeType($subquery);
      CutPasteAfter($last,$subquery);
      AddOrRemoveRelations($subquery,$last,['descendant'],{ -add_only=>1 });
      SetRelation($subquery,'descendant');
      $subquery->{occurrences}=Fslib::Struct->new({
	max => 0
       });
      my $not = NewSon($subquery);
      $not->{'#name'}='not';
      DetermineNodeType($not);
      for my $child (@kids) {
	CutPaste($child,$not)
      }
    } else {
      CutPaste($last,$node->parent);
    }
    DeleteSubtree($node);
    SetRelation($last,'descendant', {
      $min_length ? (min_length => $min_length) : (),
      max_length => $max_length,
    });
    return $subquery||$last;
  }
  return;
}

sub fix_netgraph_query {
  init_id_map($root);
  ChangingFile(0);
  {
    my $node = $root;
    my $next;
    while ($node) {
      fix_or2in($node);
      $node=$node->following;
    }
  }
  {
    my $node = $root;
    while ($node) {
      fix_tecto_coap($node);
      $node=$node->following;
    }
  }
  {
    my $node = $root;
    while ($node) {
      FPosition($node);
      $node = (reduce_optional_node_chain($node) || $node->following);
    }
  }
  {
    reduce_similar_siblings($root);
  }
  {
    my $node = $root;
    while ($node) {
      $node = (fix_netgraph_ord_to_precedes($node)||$node->following);
    }
  }
}
