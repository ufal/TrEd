# -*- cperl -*-
{
package Tree_Query_Btred;
use strict;

BEGIN {
  use vars qw($this $root);
  import TredMacro;
}

Bind sub { test(1,{one_tree=>1}); ChangingFile(0) } => {
  key => 's',
  menu => 'TrEd-based search (one tree)',
  context=>'Tree_Query',
};
Bind sub { test(1,{plan=>1, one_tree=>1}); ChangingFile(0) } => {
  key => 'P',
  menu => 'TrEd-based search with planner (one tree)',
  context=>'Tree_Query',
};
Bind sub { test(1); ChangingFile(0) } => {
  key => 'Ctrl+s',
  menu => 'TrEd-based search (all trees)',
  context=>'Tree_Query',
};
Bind \&test => {
  key => 'S',
  menu => 'TrEd-based search (next match)',
  changing_file => 0,
  context=>'Tree_Query',
};

=comment

TODO:

- limitations: ID-based iterators such a/lex.rf and coref 
  require the current FSFile
  to be known. Currently we use $grp to keep this context. But that can
  in general break if we have relations that need to follow ID-references
  from an ID-referenced layer. The correct solution is to know the FSFile of
  of each matched node, i.e. keep that information in the iterator.

- simplify query editing:

  - edit conditions as text in a text editor (with highlighting)

  - graphically in TrEd - in that way we could add and/or nodes that we can
    also use for subqueries and conditional extra-relations)

- make Ctrl|Ctrl+insert macros schema aware

- [X] support for multi-line attributes in TreeView

- support for macro-definable toolbars

- support for custom cdata- selections in TredNodeEdit from a combo box

- fully define attribute tests and simplify syntax (n1.gram/sempos instead of n1.'gram/sempos')

- [X] and/or/extra-relation/condition/subquery nodes for combining tests with sub-queries
(displayed as sub-trees).  Maybe conditions should be subtrees anyway,
only hidden. Condition node is a conjunction of tests, and there are
furhter and/or/extra-relation/subquery nodes.

- planner weights based on attribute tests
(favor less specific nodes to become leafs)

- [X] optional nodes
- [X] lengths of ancestor/descendant axes
- [X] plan subqueries
- [X] inequalities for occurrences (implemented using alternatives of min/max)

- definitions: the user draws a named query with zero or one specified
node (e.g. TARGET). The definition can be then used as a user-defined
relation which identifies the root node of the definition with the
query node in which the relation arrow starts and the TARGET node with
the query node in which the relation arrow ends. If no TARGET is used,
the definition can be used as a predicate (meaning: this node also
matches the root of the defined query).

- define text-format (syntax) for tree queries (possibly inspire in
    TigerSearch and TGrep, but use relation names instead of cryptic symbols)
  write serialization/parser

       $n1: is_member=1 and nodetype!='coap'
          and (gram/sempos!='v'
            or has child n3:[is_member=1 and nodetype!='coap'])
          and
            has optional child $n2;
       $n2: is_member!=1;
       $n2: gram/(sempos='v' and number ~ 'sg') and has 0x child [is_member=1])

       $n1 has child $n2
       $n2 has not eparent $n1
       ### or just: $n1 child $n2
       $n1 order-precedes $n2

- [X] relational predicates that one can use in boolean
  combinations like (child(ref0) or order-precedes(ref1))

- define exact syntax for a term in the tree-query
  (make a specific list of available functions and predicates)

- query options: one match per tree, output format

- Database:
-   use tables for m/, m/w/, remove tables for tfa/,
-   maybe use a separate table for every attribute?
-   unify the PMLSchema to DB schema translation
-   this will require PMLSchema and node-type to be known for each query node
    so that attribute paths are translated correctly
-   use test-data only
- [X] fix negations of mutli-match comparisons
- [X] make a/foo=1 and a/bar=2 independent searches in the list/alt a/
- implement some form of (exists a (foo=1 and bar=2))
  or (forall a (foo=1 and bar=2))
  to be able to fix a/ and constraint a/foo and a/bar

- generalize the sql data model so that it can capture lists, alts and sequences
  (the query translation engine will require PMLSchema)

=cut

our $DEBUG;
#ifdef TRED
$DEBUG=1;
#endif

my $evaluator;
#ifndef TRED
sub start_hook {
  use Getopt::Long ();
  my %opts;
  Getopt::Long::GetOptions(
    \%opts,
    'plan|p',
  ) or die "Wrong options\n";
  my ($query_fn,$query_id)=@ARGV;
  my $query_file = FSFile->newFSFile($query_fn,[Backends()]);
  if (ref($query_file)) {
    if ($Fslib::FSError!=0) {
      die "Error: loading query-file failed: $@ ($!)\n";
    } elsif ($query_file->lastTreeNo<0) {
      die "Error: Query file is empty\n";
    }
  }
  my $query_tree = $query_file->appData('id-hash')->{$query_id};
  #  print STDERR "$query_file\n";
  #plan_query($query_tree) if $opts{plan};
  die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
  $evaluator = Tree_Query::Evaluator->new($query_tree,{plan=>$opts{plan}});

  # print STDERR "initialized @iterators, $query_pos\n";
  # print $query_node,",",$query_tree->{id},"\n";
}

sub test_btred {
  my $match;
  while ($match = $evaluator->find_next_match()) {
    print join(" ",map { $_->{id} } @$match)."\n";
  }
  $evaluator->reset(); # prepare for next file
}
sub test_btred_count {
  my $limit = @_ ? int(shift()) : 100;
  my $count=0;
  $count++ while $evaluator->find_next_match({boolean => 1}) and (!$limit or $count<=$limit);
  $evaluator->reset(); # prepare for next file
  if ($limit and $count>$limit) {
    print ">$count matches\n";
  } else {
    print "$count match(es)\n";
  }
}

#endif

sub test {
  # assuming the tree we get is ordered
  my ($restart,$opts)=@_;
  my $query_tree=$root;
  my ($win) = grep {
    my $fl = GetCurrentFileList($_);
    ($fl and $fl->name eq 'Tree_Query')
  } TrEdWindows();
  return unless $win;
  my $fsfile = CurrentFile($win);
  return unless $fsfile;
  {
    my $cur_win = $grp;
    $grp=$win;
    eval {
      print STDERR "Searching...\n" if $DEBUG;
      $Tree_Query::btred_results=1;
      %Tree_Query::is_match=();
      my $one_tree = delete $opts->{one_tree};
      if ($one_tree) {
	$opts->{tree}=$fsfile->tree(CurrentTreeNumber($win));
      }
      # $opts->{fsfile} = $fsfile;
      $evaluator = Tree_Query::Evaluator->new($query_tree,$opts) if !$evaluator or $restart;
      #  return;
      my $match = $evaluator->find_next_match();
      if ($match) {
	%Tree_Query::is_match = map { $_ => 1 } @$match;
	print join(",",map { $_->{id}.": ".$_->{functor} } @$match)."\n";
	SetCurrentNodeInOtherWindow($win,$match->[0]);
      }
      print STDERR "Searching done!\n" if $DEBUG;
      
      $Redraw='all';
    };
    $grp=$cur_win;
  }
  my $err = $@;
  die $err if $err;
}

###########################################
{
  package Tree_Query::Evaluator;

  use strict;
  use Scalar::Util qw(weaken);
  use List::Util qw(first);

  my %test_relation = (
    'parent' => q($start->parent == $end),
    'child' => q($end->parent == $start),

    'order-precedes' => q($start->get_order < $end->get_order ), # not very effective !!
    'order-follows' => q($end->get_order < $start->get_order ), # not very effective !!

    'depth-first-precedes' => q( $start->root==$end->root and  do{my $n=$start->following; $n=$n->following while ($n and $n!=$end); $n ? 1 : 0 }), # not very effective !!
    'depth-first-follows' => q( $start->root==$end->root and  do{my $n=$end->following; $n=$n->following while ($n and $n!=$start); $n ? 1 : 0 }), # not very effective !!
   );

  my %test_user_defined_relation = (
    'echild' => q(do{ my $type = $node->type->get_base_type_name;
                        grep $_ == $start,
                        ($type eq 't-node.type' ? PML_T::GetEParents($end) :
                         $type eq 'a-node.type' ? PML_A::GetEParents($end,\\&PML_A::DiveAuxCP) : ()) }),
    'eparent' => q(do{ my $type = $node->type->get_base_type_name;
                        grep $_ == $end,
                        ($type eq 't-node.type' ? PML_T::GetEParents($start) :
                         $type eq 'a-node.type' ? PML_A::GetEParents($start,\\&PML_A::DiveAuxCP) : ()) }),
    'a/lex.rf|a/aux.rf' => q(grep $_ eq $end->{id}, GetANodeIDs()),
    'a/lex.rf' => q(do { my $id=$start->attr('a/lex.rf'); $id=~s/^.*?#//; $id  eq $end->{id} } ),
    'a/aux.rf' => q(grep { my $id=$_; $id=~s/^.*?#//; $id eq $end->{id} } TredMacro::ListV($start->attr('a/lex.rf'))),
    'coref_text' => q(grep $_ eq $end->{id}, TredMacro::ListV($start->{'coref_text.rf'})),
    'coref_gram' => q(grep $_ eq $end->{id}, TredMacro::ListV($start->{'coref_gram.rf'})),
    'compl' => q(grep $_ eq $end->{id}, TredMacro::ListV($start->{'compl.rf'})),
   );


  sub new {
    my ($class,$query_tree,$opts)=@_;

    #######################
    # The following lexical variables may be used directly by the
    # condition subroutines
    my @conditions;
    my @iterators;
    my @sub_queries;
    my $parent_query=$opts->{parent_query};
    my $matched_nodes = $parent_query ? $parent_query->{matched_nodes} : [];
    my %have;
    my $query_pos;
    #######################

    $opts ||= {};

    my @debug;
    my %name2pos;
    # maps node position in a (sub)query to a position of the matching node in $matched_nodes
    # we avoid using hashes for efficiency

    my $self = bless {

      query_pos => 0,
      iterators => \@iterators,
      conditions => \@conditions,
      have => \%have,

      debug => \@debug,

      sub_queries => \@sub_queries,
      parent_query => $parent_query,
      parent_query_pos => $opts->{parent_query_pos},
      parent_query_match_pos => $opts->{parent_query_match_pos},

      matched_nodes => $matched_nodes, # nodes matched so far (incl. nodes in subqueries; used for evaluation of cross-query relations)

      name2pos => \%name2pos,
      parent_pos => undef,
      pos2match_pos => undef,
      name2match_pos => undef,
    }, $class;
    weaken($self->{parent_query}) if $self->{parent_query};
    $query_pos = \$self->{query_pos};

    my $type = $query_tree->type->get_base_type_name;
    unless ($type eq 'q-query.type' or
	    $type eq 'q-subquery.type') {
      die "Not a query tree: $type!\n";
    }
    my $roots;
    if ($opts->{plan}) {
      if ($self->{parent_query}) {
	$roots = Tree_Query_Btred::Planner::plan(
	  [ Tree_Query::get_query_nodes($query_tree) ],
	  $query_tree->parent,
	  $query_tree
	 );
      } else {
	Tree_Query_Btred::Planner::name_all_query_nodes($query_tree);
	$roots = Tree_Query_Btred::Planner::plan([
	  Tree_Query::get_query_nodes($query_tree)
	 ],$query_tree);
      }
    } else {
      $roots = ($type eq 'q-query.type') ? [ $query_tree->children ] : [$query_tree];
    }
    my $query_node;
    if (@$roots==0) {
      die "No query node!\n";
    } elsif (@$roots>1) {
      die "The query is not connected: the graph has more than one root node!\n";
    } else {
      ($query_node)=@$roots;
    }
    my @query_nodes=Tree_Query::get_query_nodes($query_tree);
    %name2pos = map {
      my $name = lc($query_nodes[$_]->{name});
      (defined($name) and length($name)) ? ($name=>$_) : ()
    } 0..$#query_nodes;
    {
      my %node2pos = map { $query_nodes[$_] => $_ } 0..$#query_nodes;
      $self->{parent_pos} = [ map { $node2pos{ $_->parent  } } @query_nodes ];
    }

    {
      my @all_query_nodes = grep {$_->{'#name'} =~ /^(node|subquery)$/ } ($query_node->root->descendants);
      {
	my %node2match_pos = map { $all_query_nodes[$_] => $_ } 0..$#all_query_nodes;
	$self->{pos2match_pos} = [
	  map { $node2match_pos{ $query_nodes[$_] } } 0..$#query_nodes
	];
      }
      # we only allow refferrences to nodes in this query or some super-query
      $self->{name2match_pos} = {
	($self->{parent_query} ? (%{$self->{parent_query}{name2match_pos}}) : ()),
	map { $_ => $self->{pos2match_pos}[$name2pos{$_}] } keys %name2pos
      };
    }

    # compile condition testing functions and create iterators
    my (@r1,@r2,@r3);
    for my $i (0..$#query_nodes) {
      my $qn = $query_nodes[$i];

      my $sub = $self->serialize_conditions($qn,{
	query_pos => $i,
	recompute_condition => \@r1, # appended in recursion
	recompute_subquery => \@r2,  # appended in recursion
	reverted_relations => \@r3,  # appended in recursion
      });
      my $conditions = eval $sub; die $@ if $@; # use the above-mentioned lexical context
      push @debug, $sub;
      push @conditions, $conditions;
      my $iterator;
      if (!$self->{parent_query} and $qn==$query_node) {
	# top-level node iterates throguh all nodes
	if ($opts->{iterator}) {
	  $iterator = $opts->{iterator};
	} elsif ($opts->{tree}) {
	  $iterator = TreeIterator->new($conditions,$opts->{tree});
# 	} elsif ($opts->{fsfile}) {
# 	  $iterator = FSFileIterator->new($conditions,$opts->{fsfile});
	} else {
	  $iterator = CurrentFileIterator->new($conditions);
	}
      } else {
	$iterator = $self->create_iterator($qn,$conditions);
      }
      push @iterators, $iterator;
    }
    return $self;
  }

  sub reset {
    my ($self)=@_;
    $self->{query_pos} = 0;
    %{$self->{have}}=$self->{parent_query} ? %{$self->{parent_query}{have}} : ();
    $_->reset for @{$self->{iterators}};
  }

  sub create_iterator {
    my ($self,$qn,$conditions)=@_;
    	# TODO: deal with negative relations, etc.
    my ($rel) = TredMacro::SeqV($qn->{relation});
    my $relation = $rel && $rel->name;
    $relation||='child';

    print STDERR "iterator: $relation\n" if $DEBUG;
    my $iterator;
    if ($relation eq 'child') {
      $iterator = ChildnodeIterator->new($conditions);
    } elsif ($relation eq 'descendant') {
      my ($min,$max)=
	map { (defined($_) and length($_)) ? $_ : undef }
	map { $rel->value->{$_} }
	qw(min_length max_length);
      if (defined($min) or defined($max)) {
	print STDERR "with bounded depth ($min,$max)\n" if $DEBUG;
	$iterator = DescendantIteratorWithBoundedDepth->new($conditions,$min,$max);
      } else {
	$iterator = DescendantIterator->new($conditions);
      }
    } elsif ($relation eq 'parent') {
      $iterator = ParentIterator->new($conditions);
    } elsif ($relation eq 'ancestor') {
      my ($min,$max)=
	map { (defined($_) and length($_)) ? $_ : undef }
	map { $rel->value->{$_} }
	qw(min_length max_length);
      if (defined($min) or defined($max)) {
	$iterator = AncestorIteratorWithBoundedDepth->new($conditions,$min,$max);
      } else {
	$iterator = AncestorIterator->new($conditions);
      }
    } elsif ($relation eq 'user-defined') {
      if ($rel->value->{label} eq 'a/aux.rf') {
	$iterator = AAuxRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'a/lex.rf') {
	$iterator = ALexRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'a/lex.rf|a/aux.rf') {
	$iterator = ALexOrAuxRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'coref_text') {
	$iterator = CorefTextRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'coref_gram') {
	$iterator = CorefGramRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'compl') {
	$iterator = ComplRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'echild') {
	$iterator = EChildIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'eparent') {
	$iterator = EParentIterator->new($conditions);
      } else {
	die "user-defined relation ".$rel->value->{label}." not yet implemented\n"
      }
    } else {
      die "relation ".$relation." not yet implemented\n"
    }
    if ($qn->{optional}) {
      return OptionalIterator->new($iterator);
    } else {
      return $iterator;
    }
  }

  sub serialize_conditions {
    my ($self,$qnode,$opts)=@_;
    my $conditions = $self->serialize_element({
      %$opts,
      name => 'and',
      condition => $qnode,
    });

    my $pos = $opts->{query_pos};
    my $match_pos = $self->{pos2match_pos}[$pos];
    my $optional;
    if ($qnode->{optional}) {
      my $parent_pos = $self->{parent_pos}[$pos];
      if (!defined $parent_pos) {
	die "Optional node cannot at the same time be the head of a subquery!";
      }
      $optional = '$matched_nodes->['.$self->{pos2match_pos}[$parent_pos].']';
    }
    if ($conditions=~/\S/) {
      if (defined $optional) {
	$conditions='('.$optional.'==$node or '.$conditions.')';
      }
    } else {
      $conditions=undef
    }

    print STDERR "CONDITIONS[$pos/$match_pos]: $conditions\n" if $DEBUG;
    my $check_preceding = '';

    my $recompute_cond = $opts->{recompute_condition}[$match_pos];
    if (defined $recompute_cond) {
      $check_preceding = join('', map {"\n   and ".'$conditions['.$_.']->($matched_nodes->['.$self->{pos2match_pos}[$_].'],1) '} sort { $a<=>$b } keys %$recompute_cond);
    }
    if (length $check_preceding) {
      $check_preceding = "\n".
	'  and ($backref or '.
	  '($matched_nodes->['.$match_pos.']=$node) # a trick: make it appear as if this node already matched!'.
	    $check_preceding.
	')';
    }
    my $nodetest = '$node and ($backref or '
      .(defined($optional) ? $optional.'==$node or ' : '')
      .'!exists($have{$node}))';
    my $sub = qq(#line 0 "query-node/${match_pos}"\n)
      . 'sub { my ($node,$backref)=@_; '."\n  "
       .$nodetest
       .(defined($conditions) ? "\n  and ".$conditions : '')
       . $check_preceding
       ."\n}";
    print STDERR "SUB: $sub\n" if $DEBUG;
    return $sub;
  }

  sub serialize_element {
    my ($self,$opts)=@_;
    my ($name,$node)=map {$opts->{$_}} qw(name condition);
    my $pos = $opts->{query_pos};
    my $match_pos = $self->{pos2match_pos}[$pos];
    if ($name eq 'test') {
      my %depends_on;
      my $left = $self->serialize_expression({%$opts,
					      depends_on => \%depends_on,
					      expression=>$node->{a}
					     }); # FIXME: quoting
      my $right = $self->serialize_expression({%$opts,
					       depends_on => \%depends_on,
					       expression=>$node->{b}
					      }); # FIXME: quoting
      my $operator = $node->{operator};
      if ($operator eq '=') {
	if ($right=~/^(?:\d*\.)?\d+$/ or $left=~/^(?:\d*\.)?\d+$/) {
	  $operator = '==';
	} else {
	  $operator = 'eq';
	}
      } elsif ($operator eq '~') {
	$operator = '=~';
      }
      my $condition;
      if ($operator eq '~*') {
	$condition='do{ my $regexp='.$right.'; '.$left.'=~ /$regexp/i}';
      } elsif ($operator eq 'in') {
	# TODO: 'first' is actually pretty slow, we should use a disjunction
	# but splitting may be somewhat non-trivial in such a case
	# - postponing till we know exactly how a tree-query term may look like
	$condition='do{ my $node='.$left.'; grep $_ eq '.$left.', '.$right.'}';
	# #$condition=$left.' =~ m{^(?:'.join('|',eval $right).')$}';
	# 	$right=~s/^\s*\(//;
	# 	$right=~s/\)\s*$//;
	# 	my @right = split /,/,$right;
	# 	$condition='do { my $node='.$left.'; ('.join(' or ',map { '$node eq '.$_ } @right).')}';
      } else {
	$condition='('.$left.' '.$operator.' '.$right.')';
      }
      my $target_match_pos = TredMacro::max($match_pos,keys %depends_on);
      my $target_pos = TredMacro::Index($self->{pos2match_pos},$target_match_pos);
      if (defined $target_pos) {
	# target node in the same sub-query
	if ($target_pos<=$pos) {
	  return $condition;
	} elsif ($target_pos>$pos) {
	  $opts->{recompute_condition}[$target_match_pos]{$pos}=1;
	  return ('( $$query_pos < '.$target_pos.' ? '.int(!$opts->{negative}).' : '.$condition.')');
	}
      } else {
	# this node is matched by some super-query
	if ($target_match_pos > $self->{parent_query_match_pos}) {
	  # we need to postpone the evaluation of the whole sub-query up-till $matched_nodes->[$target_pos] is known
	  $self->{postpone_subquery_till}=$target_match_pos if ($self->{postpone_subquery_till}||0)<$target_match_pos;
	}
	return $condition;
      }
    } elsif ($name =~ /^(?:and|or|not)$/) {
      my $negative = $opts->{negative} ? 1 : 0;
      if ($name eq 'not') {
	$negative=!$negative;
      }
      my @c =grep {defined and length}
	map {
	  $self->serialize_element({
	    %$opts,
	    negative => $negative,
	    name => $_->{'#name'},
	    condition => $_,
	  })
	} grep { $_->{'#name'} ne 'node' } $node->children;
      return () unless @c;
      if ($name eq 'not') {
	return 'not('.join("\n  and ",@c).')';
      } else {
	return '('.join("\n  $name ",@c).')';
      }
    } elsif ($name eq 'subquery') {
      my $subquery = ref($self)->new($node, {
	parent_query => $self,
	parent_query_pos => $pos,
	parent_query_match_pos => $match_pos,
      });
      push @{$self->{sub_queries}}, $subquery;
      my $sq_pos = $#{$self->{sub_queries}};
      my @occ = map {
	(length($_->{min}) || length($_->{max})) ?
	  ((length($_->{min}) ? $_->{min} : undef),
	   (length($_->{max}) ? $_->{max} : undef)) : (1,undef)
      } TredMacro::AltV($node->{occurrences});
      my $occ_list=
	TredMacro::max(map {int($_)} @occ).','.join(',',(map { defined($_) ? $_ : 'undef' } @occ));
      my $condition = qq/\$sub_queries[$sq_pos]->test_occurrences(\$node,$occ_list)/;
      my $postpone_subquery_till = $subquery->{postpone_subquery_till};
      if (defined $postpone_subquery_till) {
	print "postponing subquery till: $postpone_subquery_till\n" if $DEBUG;
	my $target_pos = TredMacro::Index($self->{pos2match_pos},$postpone_subquery_till);
	if (defined $target_pos) {
	  # same subquery, simply postpone, just like when recomputing conditions
	  my $postpone_pos = $postpone_subquery_till;
	  return ('( $$query_pos < '.$target_pos.' ? '.int(!$opts->{negative}).' : '.$condition.')');
	} else {
	  print "other subquery\n" if $DEBUG;
	  # otherwise postpone this subquery as well
	  $self->{postpone_subquery_till}=$postpone_subquery_till if $postpone_subquery_till>($self->{postpone_subquery_till}||0);
	  return $condition;
	}
      } else {
	return $condition;
      }
    } elsif ($name eq 'ref') {
      my ($rel) = TredMacro::SeqV($node->{relation});
      my $target = lc( $node->{target} );
      my $relation = $rel->name;
      my $expression;
      my $label='';
      if ($relation eq 'user-defined') {
	$label = $rel->value->{label};
	$expression = $test_user_defined_relation{$label};
	die "User-defined relation '$label' not supported test!\n" unless defined $expression;
      } else {
	if ($relation eq 'descendant' or $relation eq 'ancestor') {
	  my ($min,$max)=
	    map { (defined($_) and length($_)) ? $_ : undef }
	    map { $rel->value->{$_} }
	    qw(min_length max_length);
	  my ($START,$END)=($relation eq 'ancestor') ? ('$start','$end') : ('$end','$start');
	  $expression = 'do { my $n='.$START.'; '.
	    ((defined($min) or defined($max)) ? 'my $l=0; ' : '').
	      'while ($n and $n!='.$END.(defined($max) ? ' and $l<'.$max : ''). ') { $n=$n->parent; '.
		((defined($min) or defined($max)) ? '$l++;' : '').
	      ' }'.
	      ' ($n and $n!='.$START.' and $n=='.$END.(defined($min) ? ' and '.$min.'<=$l' : '').') ? 1 : 0}';
	} else {
	  $expression = $test_relation{$relation};
	}
	die "Relation '$relation' not supported test!\n" unless defined $expression;
      }
      my $target_pos = $self->{name2pos}{$target};
      my $target_match_pos = $self->{name2match_pos}{$target};
      my $condition = q/ do{ my ($start,$end)=($node,$matched_nodes->[/.$target_match_pos.q/]); /.$expression.q/ } /;
      if (defined $target_pos) {
	# target node in the same sub-query
	if ($target_pos<$pos) {
	  return $condition;
	} elsif ($target_pos>$pos) {
	  $opts->{recompute_condition}[$target_match_pos]{$pos}=1;
	  return ('( $$query_pos < '.$target_pos.' ? '.int(!$opts->{negative}).' : '.$condition.')');
	} else {
	  # huh, really?
	  return q/ do{ my ($start,$end)=($node,$node); /.$expression.q/ } /;
	}
      } elsif (defined $target_match_pos) {
	# this node is matched by some super-query
	if ($target_match_pos > $self->{parent_query_match_pos}) {
	  # we need to postpone the evaluation of the whole sub-query up-till $matched_nodes->[$target_pos] is known
	  $self->{postpone_subquery_till}=$target_match_pos if ($self->{postpone_subquery_till}||0)<$target_match_pos;
	}
	return $condition;
      } else {
	die "Node '$target' does not exist or belongs to a sub-query and cannot be referred from relation $relation $label at node no. $match_pos!\n";
      }
    } else {
      die "Unknown element $name ";
    }
  }

  sub serialize_expression {
    my ($self,$opts)=@_;
    my $parent_id = $opts->{parent_id};

    my $exp = $opts->{expression};
    # TODO
    #    for ($exp) {
    #      s/(?:(\w+)\.)?"_[#]descendants"/$1"r"-$1"idx"/g;
    #      s/"_[#]lbrothers"/"chord"/g;
    #      s/(?:(\w+)\.)?"_[#]rbrothers"/$1$parent_id."chld"-$1"chord"-1/g;
    #      s/"_[#]sons"/"chld"/g;
    #      s/"_depth"/"lvl"/g;
    #    }
    if ($exp=~/^'((?:\d*\.)?\d+)'$/) {
      $exp=$1;
    } else {
      $exp=~s{(?:(\w+)\.)?"([^"]+)"}{
	my $target = $1;
	my $attr = $2;
	my $node='$node';
	if (defined $target) {
	  $target = lc($target);
	  my $target_match_pos = $self->{name2match_pos}{$target};
	  $node='$matched_nodes->['.$target_match_pos.']';
	  if (defined $target_match_pos) {
	    $opts->{depends_on}{$target_match_pos}=1;
	  } else {
	    my $pos = $opts->{query_pos};
	    my $match_pos = $self->{pos2match_pos}[$pos];
	    die "Node '$target' does not exist or belongs to a sub-query and cannot be referred from expression $exp of node no. $match_pos!\n";
	  }
	}
	## FIXME: hack: not needed once SQL db is fixed
	if ($attr eq 'idx') {
	  $attr = 'id';
	} elsif ($attr =~ /^(?:tag|lemma|form)/) {
	  $attr='m/'.$attr; #FIXME: remove me
	} else {
	  $attr =~ s{^tfa/}{}; #FIXME: remove me
	}
	if ($attr eq '_depth') {
	  $node.qq{->level}
	} elsif ($attr eq '_#sons') {
	  'scalar('.$node.qq{->children}.')'
	} elsif ($attr eq '_#descendants') {
	  'scalar('.$node.qq{->descendants}.')'
	} elsif ($attr eq '_#lbrothers') {
          q[ do { my $n = ].$node.q[; my $i=0; $i++ while ($n=$n->lbrother); $i } ]
	} elsif ($attr eq '_#rbrothers') {
          q[ do { my $n = ].$node.q[; my $i=0; $i++ while ($n=$n->rbrother); $i } ]
	} else {
	  ($attr=~m{/}) ? $node.qq{->attr(q($attr))} : $node.qq[->{q($attr)}];
        }
      }ge;
    }
    return $exp;
  }

  sub test_occurrences {
    my ($self,$seed,$test_max) = (shift,shift,shift);
    $self->reset();
    my $count=0;
    print STDERR "<subquery>\n" if $DEBUG;
    while ($self->find_next_match({boolean => 1, seed=>$seed})) {
      last unless $count<=$test_max;
      $count++;
      $self->backtrack(0); # this is here to count on DISTINCT
      # roots of the subquery (i.e. the node with occurrences specified).
    }
    my ($min,$max)=@_;
    my $ret=0;
    while (@_) {
      ($min,$max)=(shift,shift);
      if ((!defined($min) || $count>=$min) and
	    (!defined($max) || $count<=$max)) {
	$ret=1;
	last;
      }
    }
    print "occurrences: >=$count\n" if $DEBUG;
    print STDERR "</subquery>\n" if $DEBUG;
    $self->reset() if $count;
    return $ret;
  }

  sub backtrack {
    my ($self,$pos)=@_;
    my $query_pos = \$self->{query_pos}; # a scalar reference
    return unless $$query_pos >= $pos;

    my $iterators = $self->{iterators};
    my $matched_nodes = $self->{matched_nodes};
    my $pos2match_pos = $self->{pos2match_pos};
    my $have = $self->{have};
    my $iterator;
    my $node;
    while ($pos<$$query_pos) {
      $node = delete $matched_nodes->[$pos2match_pos->[$$query_pos]];
      delete $have->{$node} if $node;
      $$query_pos--;
    }
    return 1;
  }
  sub find_next_match {
    my ($self,$opts)=@_;
    $opts||={};
    my $iterators = $self->{iterators};
    my $parent_pos = $self->{parent_pos};
    my $query_pos = \$self->{query_pos}; # a scalar reference
    my $matched_nodes = $self->{matched_nodes};
    my $pos2match_pos = $self->{pos2match_pos};
    my $have = $self->{have};

    my $iterator = $iterators->[$$query_pos];
    my $node = $iterator->node;
    if ($node) {
      delete $have->{$node};
      # print STDERR ("iterate $$query_pos $iterator: $self->{debug}[$$query_pos]\n") if $DEBUG;
      $node
	= $matched_nodes->[$pos2match_pos->[$$query_pos]]
	  = $iterator->next;
      $have->{$node}=1 if $node;
    } elsif ($$query_pos==0) {
      # first
      # print "Starting subquery on $opts->{seed}->{id} $opts->{seed}->{t_lemma}.$opts->{seed}->{functor}\n" if $opts->{seed} and $DEBUG;
      $node
	= $matched_nodes->[$pos2match_pos->[$$query_pos]]
	  = $iterator->start( $opts->{seed} );
      $have->{$node}=1 if $node;
    }
    while (1) {
      if (!$node) {
	if ($$query_pos) {
	  # backtrack
	  $matched_nodes->[$pos2match_pos->[$$query_pos]]=undef;
	  $$query_pos--;	# backtrack
	  print STDERR ("backtrack to $$query_pos\n") if $DEBUG;
	  $iterator=$iterators->[$$query_pos];

	  $node = $iterator->node;
	  delete $have->{$node} if $node;

	  #print STDERR ("iterate $$query_pos $iterator: $self->{debug}[$$query_pos]\n") if $DEBUG;
	  $node
	    = $matched_nodes->[$pos2match_pos->[$$query_pos]]
	      = $iterator->next;
	  $have->{$node}=1 if $node;
	  next;
	} else {
	  print STDERR "no match\n" if $DEBUG;
	  return;		# NO RESULT
	}
      } else {
	print STDERR ("match $node->{id} [$$query_pos,$pos2match_pos->[$$query_pos]]: $node->{t_lemma}.$node->{functor}\n") if $DEBUG;

	if ($$query_pos<$#$iterators) {
	  $$query_pos++;
	  my $seed = $iterators->[ $parent_pos->[$$query_pos] ]->node;
	  $iterator = $iterators->[$$query_pos];
	  $node
	    = $matched_nodes->[$pos2match_pos->[$$query_pos]]
	      = $iterator->start($seed);
	  #print STDERR ("restart $$query_pos $iterator from $seed->{t_lemma}.$seed->{functor} $self->{debug}[$$query_pos]\n") if $DEBUG;
	  $have->{$node}=1 if $node;
	  next;

	} else {
	  print STDERR ("complete match [bool: $opts->{boolean}]\n") if $DEBUG;
	  # complete match:
	  return $opts->{boolean} ? 1 : [map { $_->node } @$iterators];
	}
      }
    }
    return;
  }


}
#################################################
{
  package Tree_Query_Btred::Planner;

  use vars qw(%weight %reverse);

  %weight = (
    'user-defined:echild' => 5,
    'user-defined:eparent' => 2,
    'user-defined:a/lex.rf|a/aux.rf' => 2,
    'user-defined:a/lex.rf' => 1,
    'user-defined:a/aux.rf' => 2,
    'user-defined:coref_text' => 1,
    'user-defined:coref_gram' => 1,
    'user-defined:compl' => 1,
    'descendant' => 30,
    'ancestor' => 8,
    'parent' => 0.5,
    'child' => 10,
    'order-precedes' => 10000,
    'order-follows' => 10000,
    'depth-first-precedes' => 1000,
    'depth-first-follows' => 1000,
   );

  %reverse = (
    'user-defined:echild' => 'user-defined:eparent',
    'user-defined:eparent' => 'user-defined:echild',
    'descendant' => 'ancestor',
    'ancestor' => 'descendant',
    'parent' => 'child',
    'child' => 'parent',
    'order-precedes' => 'order-follows',
    'order-follows' => 'order-precedes',
    'depth-first-precedes' => 'depth-first-follows',
    'depth-first-follows' => 'depth-first-precedes',
   );

  sub name_all_query_nodes {
    my ($tree)=@_;
    my @nodes = grep { $_->{'#name'} =~ /^(?:node|subquery)$/ } $tree->descendants;
    my $max=0;
    my %name2node = map {
      my $n=lc($_->{name});
      $max=$1+1 if $n=~/^n(\d+)$/ and $1>=$max;
      (defined($n) and length($n)) ? ($n=>$_) : ()
    } @nodes;
    my $name = 'n0';
    for my $node (@nodes) {
      my $n=lc($node->{name});
      unless (defined($n) and length($n)) {
	$node->{name}= $n ='n'.($max++);
	$name2node{$n}=$node;
      }
    }
    return \%name2node;
  }
  sub weight {
    my ($rel)=@_;
    my $name = $rel->name;
    if ($name eq 'user-defined') {
      $name.=':'.$rel->value->{label};
    }
    my $w = $weight{$name};
    return $w if defined $w;
    warn "do not have weight for edge: '$name'\n";
    use Data::Dumper;
    print Dumper(\%weight);
    return;
  }
  sub reversed_rel {
    my ($ref)=@_;
    my ($rel)=TredMacro::SeqV($ref->{relation});
    my $name = $rel->name;
    if ($name eq 'user-defined') {
      $name.=':'.$rel->value->{label};
    }
    my $rname = $reverse{$name};
    if (defined $rname) {
      my $rev;
      if ($rname =~s/^user-defined://) {
	$rev = Fslib::Seq::Element->new('user-defined', Fslib::CloneValue($rel->value));
	$rev->value->{label}=$rname;
      } else {
	$rev = Fslib::Seq::Element->new(
	  $rname,
	  Fslib::CloneValue($rel->value)
	   );
      }
      $rev->value->{reversed}=$ref;
      return $rev;
    } else {
      return;
    }
  }
  sub plan_query {
    my ($query_tree)=@_;
    $query_tree||=$TredMacro::root;
    name_all_query_nodes($query_tree);
    my @query_nodes=Tree_Query::get_query_nodes($query_tree);
    plan(\@query_nodes,$query_tree);
  }

  sub plan {
    my ($query_nodes,$query_tree,$query_root)=@_;
    die 'usage: plan(\@nodes,$query_tree,$query_node?)' unless
      ref($query_nodes) eq 'ARRAY' and $query_tree;
    my %node2pos = map { $query_nodes->[$_] => $_ } 0..$#$query_nodes;
    my %name2pos = map {
      my $name = lc($query_nodes->[$_]->{name});
      (defined($name) and length($name)) ? ($name=>$_) : ()
    } 0..$#$query_nodes;
    my $root_pos = defined($query_root) ? $node2pos{$query_root} : undef;

    require Graph;
    require Graph::ChuLiuEdmonds;
    my @edges;
    my @parent;
    my @parent_edge;
    for my $i (0..$#$query_nodes) {
      my $n = $query_nodes->[$i];
      print "$i: $n->{name}\n" if $DEBUG;
      my $parent = $n->parent;
      my $p = $node2pos{$parent};
      $parent[$i]=$p;
      # turn node's relation into parent's extra-relation
      if (defined $p) {
	my ($rel) = TredMacro::SeqV($n->{relation});
	$rel||=Fslib::Seq::Element->new('child', Fslib::Container->new());
	$parent_edge[$i]=$rel;
	delete $n->{relation};
	my $ref = TredMacro::NewSon($parent);
	$ref->{'#name'} = 'ref';
	TredMacro::DetermineNodeType($ref);
	$ref->{relation}=Fslib::Seq->new([$rel]);
	$ref->{target} = $n->{name};
      }
    }
    for my $i (0..$#$query_nodes) {
      my $n = $query_nodes->[$i];
      for my $ref (grep { $_->{'#name'} eq 'ref' } $n->children) {
	my $target = lc( $ref->{target} );
	my ($rel)=TredMacro::SeqV($ref->{relation});
	next unless $rel;
	my $t = $name2pos{$target};
	my $no_reverse;
	my $tn = $query_nodes->[$t];
	my $tnp=$tn->parent;
	if ($n->{optional} or $tn->{optional} or ($tnp and $tnp->{optional})) {
	  # only direct edges can go in and out of an optional node
	  # and only direct edge can go to a child of an optional node
	  next unless $rel==$parent_edge[$t];
	  $no_reverse=1;
	}
	if (defined $t and $t!=$i) {
	  push @edges,[$i,$t,$ref,weight($rel)] unless defined($root_pos) and $t==$root_pos;
	  unless ($no_reverse or (defined($root_pos) and $i==$root_pos)) {
	    my $reversed = reversed_rel($ref);
	    if (defined $reversed) {
	      push @edges,[$t,$i,$reversed,weight($reversed)];
	    }
	  }
	}
      }
    }
    undef @parent_edge; # not needed anymore
    my $g=Graph->new(directed=>1);
    $g->add_vertex($_) for 0..$#$query_nodes;
    my %edges;
    for my $e (@edges) {
      my $has = $g->has_edge($e->[0],$e->[1]);
      my $w = $e->[3]||100000;
      if (!$has or $g->get_edge_weight($e->[0],$e->[1])>$w) {
	$edges{$e->[0]}{$e->[1]}=$e->[2];
	$g->delete_edge($e->[0],$e->[1]) if $has;
	$g->add_weighted_edge($e->[0],$e->[1], $w);
      }
    }
    my $mst=$g->MST_ChuLiuEdmonds();
#ifdef TRED
    TredMacro::ChangingFile(1);
#endif
    for my $qn (@$query_nodes) {
      $qn->cut();
    }
    my $last_ref=0;
    my @roots;
    for my $i (0..$#$query_nodes) {
      my $qn = $query_nodes->[$i];
      my $p=undef;
      if ($mst->in_degree($i)==0) {
	$qn->paste_on($query_tree);
	push @roots,$qn;
      } else {
	my ($e) = $mst->edges_to($i);
	$p=$e->[0];
	$qn->paste_on($query_nodes->[$p]);
      }

      # now turn the selected extra-relation into relation
      # of $qn
      if (defined $p) {
 	my $parent = $query_nodes->[$p];
	my $ref = $edges{$p}{$i};
	my $rel;
	if (UNIVERSAL::isa($ref,'Fslib::Seq::Element')) {
	  $rel = $ref;
	  $ref = delete $rel->value->{reversed};
	} else {
	  ($rel) = TredMacro::SeqV($ref->{relation});
	}
	TredMacro::DeleteLeafNode($ref);
	delete $qn->{'relation'};
	TredMacro::AddToSeq($qn,'relation',$rel);
      }
    }
    return \@roots;
  }
}
#################################################
{
  package Tree_Query::Iterator;
  use constant CONDITIONS=>0;
  use Carp;
  sub new {
    my ($class,$conditions)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions],$class;
  }
  sub conditions { return $_[0]->[CONDITIONS]; }
  sub start {}
  sub next {}
  sub node {}
  sub reset {}
}
#################################################
{
  package OptionalIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant ITERATOR=>1;
  use constant NODE=>2;
  use Carp;
  sub new {
    my ($class,$iterator)=@_;
    croak "usage: $class->new($iterator)" unless UNIVERSAL::isa($iterator,'Tree_Query::Iterator');
    return bless [$iterator->conditions,$iterator],$class;
  }
  sub start  {
    my ($self,$parent)=@_;
    $self->[NODE]=$parent;
    return $parent ? ($self->[CONDITIONS]->($parent) ? $parent : $self->next) : undef;
  }
  sub next {
    my ($self)=@_;
    my $n = $self->[NODE];
    if ($n) {
      $self->[NODE]=undef;
      return $self->[ITERATOR]->start($n);
    }
    return $self->[ITERATOR]->next;
  }
  sub node {
    my ($self)=@_;
    return $self->[NODE] || $self->[ITERATOR]->node;
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[ITERATOR]->reset;
  }
}
#################################################
{
  package FSFileIterator;
  use Carp;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant FILE=>1;
  use constant TREE_NO=>2;
  use constant NODE=>3;
  sub new {
    my ($class,$conditions,$fsfile)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions,$fsfile],$class;
  }
  sub start  {
    my ($self)=@_;
    $self->[TREE_NO]=0;
    my $n = $self->[NODE] = $self->[FILE]->tree(0);
    return ($n && $self->[CONDITIONS]->($n)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    while ($n) {
      $n = $n->following || $self->[FILE]->tree(++$self->[TREE_NO]);
      last if $conditions->($n);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package CurrentFileIterator;
  use base qw(Tree_Query::Iterator);
  BEGIN {
    import TredMacro qw($this $root);
  }
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self)=@_;
    # TredMacro::GotoFileNo(0);
    TredMacro::GotoTree(0);
    $this=$root;
    $self->[NODE]=$this;
    return ($this && $self->[CONDITIONS]->($this)) ? $this : ($this && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    while ($n) {
      $n = $n->following || (TredMacro::NextTree() && $this);
      last if $conditions->($n);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package TreeIterator;
  use Carp;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant TREE=>1;
  use constant NODE=>2;
  sub new  {
    my ($class,$conditions,$root)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions,$root],$class;
  }
  sub start  {
    my ($self)=@_;
    my $root = $self->[NODE] = $self->[TREE];
    return ($root && $self->[CONDITIONS]->($root)) ? $root : ($root && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    while ($n) {
      $n = $n->following;
      last if $conditions->($n);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package ChildnodeIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self,$parent)=@_;
    my $n = $self->[NODE]=$parent->firstson;
    return ($n && $self->[CONDITIONS]->($n)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE]->rbrother;
    $n=$n->rbrother while ($n and !$conditions->($n));
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package DescendantIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant TOP=>2;

  sub start  {
    my ($self,$parent)=@_;
    my $n= $parent->firstson;
    $self->[NODE]=$n;
    $self->[TOP]=$parent;
    return ($n && $self->[CONDITIONS]->($n)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $top = $self->[TOP];
    my $n=$self->[NODE]->following($top);
    $n=$n->following($top) while ($n and !$conditions->($n));
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[TOP]=undef;
  }
}

#################################################
{
  package DescendantIteratorWithBoundedDepth;
  use base qw(Tree_Query::Iterator);
  use Carp;
  use constant CONDITIONS=>0;
  use constant MIN=>1;
  use constant MAX=>2;
  use constant DEPTH=>3;
  use constant NODE=>4;

  sub new {
    my ($class,$conditions,$min,$max)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    $min||=0;
    return bless [$conditions,$min,$max],$class;
  }
  sub start  {
    my ($self,$parent)=@_;
    my $n=$parent->firstson;
    $self->[DEPTH]=1;
    $self->[NODE]=$n;
    return ($self->[MIN]<=1 and $self->[CONDITIONS]->($n)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $min = $self->[MIN];
    my $max = $self->[MAX];
    my $depth = $self->[DEPTH];
    my $conditions=$self->[CONDITIONS];
    my $n = $self->[NODE];
    my $r;
    SEARCH:
    while ($n) {
      if ((!defined($max) or ($depth<$max)) and $n->firstson) {
	$n=$n->firstson;
	$depth++;
      } else {
	while ($n) {
	  if ($depth == 0) {
	    undef $n;
	    last SEARCH;
	  }
	  if ($r = $n->rbrother) {
	    $n=$r;
	    last;
	  } else {
	    $n=$n->parent;
	    $depth--;
	  }
	}
      }
      if ($n and $min<=$depth and $conditions->($n)) {
	$self->[DEPTH]=$depth;
	return $self->[NODE]=$n;
      }
    }
    return $self->[NODE]=undef;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package ParentIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self,$node)=@_;
    my $n = $node->parent;
    return $self->[NODE] = ($n && $self->[CONDITIONS]->($n)) ? $n : undef;
  }
  sub next {
    return $_[0]->[NODE]=undef;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package AncestorIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self,$node)=@_;
    my $n = $node->parent;
    $self->[NODE]=$n;
    return ($n && $self->[CONDITIONS]->($n)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE]->parent;
    $n=$n->parent while ($n and !$conditions->($n));
    return $_[0]->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package AncestorIteratorWithBoundedDepth;
  use base qw(Tree_Query::Iterator);
  use Carp;
  use constant CONDITIONS=>0;
  use constant MIN=>1;
  use constant MAX=>2;
  use constant NODE=>3;
  use constant DEPTH=>4;
  sub new  {
    my ($class,$conditions,$min,$max)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    $min||=0;
    return bless [$conditions,$min,$max],$class;
  }
  sub start  {
    my ($self,$node)=@_;
    my $min = $self->{MIN}||1;
    my $max = $self->{MAX};
    my $depth=0;
    $node = $node->parent while ($node and ($depth++)<$min);
    $node=undef if defined($max) and $depth>$max;
    $self->[NODE]=$node;
    $self->[DEPTH]=$depth;
    return ($node && $self->[CONDITIONS]->($node)) ? $node : ($node && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $max = $self->{MAX};
    my $depth = $self->[DEPTH]+1;
    return $_[0]->[NODE]=undef if ($depth>$max);
    my $n=$self->[NODE]->parent;
    while ($n and !$conditions->($n)) {
      $depth++;
      if ($depth<=$max) {
	$n=$n->parent;
      } else {
	$n=undef;
      }
    }
    return $_[0]->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}

#################################################
{
  package ALexRFIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self,$node)=@_;
    my $lex_rf = $node->attr('a/lex.rf');
    my $refnode;
    if (defined $lex_rf) {
      $lex_rf=~s/^.*?#//;
      $refnode=PML_T::GetANodeByID($lex_rf);
    }
    return $self->[NODE]= $self->[CONDITIONS]->($refnode) ? $refnode : undef;
  }
  sub next {
    return $_[0]->[NODE]=undef;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package SimpleListIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODES=>1;
  sub start  {
    my ($self,$node)=@_;
    $self->[NODES] = $self->get_node_list($node);
    my $n = $self->[NODES]->[0];
    return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $nodes = $self->[NODES];
    my $conditions=$self->[CONDITIONS];
    shift @{$nodes};
    while ($nodes->[0] and !$conditions->($nodes->[0])) {
      shift @{$nodes};
    }
    return $nodes->[0];
  }
  sub node {
    my ($self)=@_;
    return $self->[NODES]->[0];
  }

  sub reset {
    my ($self)=@_;
    $self->[NODES]=undef;
  }
  sub get_node_list {
    return [];
  }
}

#################################################
{
  package AAuxRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [grep defined, map {
      my $id = $_; $id=~s/^.*?#//;
      PML_T::GetANodeByID($id)
      } TredMacro::ListV($node->attr('a/aux.rf'))];
  }
}
#################################################
{
  package ALexOrAuxRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [PML_T::GetANodes($node)];
  }
}
#################################################
{
  package CorefTextRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [grep defined, map {
      PML::GetNodeByID($_)
      } TredMacro::ListV($node->attr('coref_text.rf'))];
  }
}
#################################################
{
  package CorefGramRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [grep defined, map {
      PML::GetNodeByID($_)
      } TredMacro::ListV($node->attr('coref_gram.rf'))];
  }
}
#################################################
{
  package ComplRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [grep defined, map {
      PML::GetNodeByID($_)
      } TredMacro::ListV($node->attr('compl.rf'))];
  }
}
#################################################
{
  package EParentIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    my $type = $node->type->get_base_type_name;
    return [$type eq 't-node.type' ?
	      PML_T::GetEParents($node) :
		  $type eq 'a-node.type' ?
		    PML_A::GetEParents($node,\&PML_A::DiveAuxCP) :
			()
		       ];
  }
}
#################################################
{
  package EChildIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    my $type = $node->type->get_base_type_name;
    return [$type eq 't-node.type' ?
	      PML_T::GetEChildren($node) :
		  $type eq 'a-node.type' ?
		    PML_A::GetEChildren($node,\&PML_A::DiveAuxCP) :
			()
		       ];
  }
}
#################################################


=comment on implementation on top of btred search engine

1. find in the query graph an oriented sceleton tree, possibly using
Kruskal and some weighting rules favoring easy to follow types of
edges (relations) with minimum number of potential target nodes
(e.g. parent, ancestor a/lex.rf are better than child, descendant or
a/aux.rf, and far better then their negated counterparts).

2. Order sibling nodes of this tree by similar algorithm so that all
relations between these nodes go from right bottom to left top (using
reversing where possible) and the result is near optimal using similar
weighting as above. This may be done only for relations not occuring
in condition formulas.

3. For each relation between nodes that occurs in a condition formula,
assume that the relation is or is not satisfied so that the truth
value of the condition is not decreased (whether to take the formula
negatively or positively is probably easy to compute since we may
eliminate all negations of non-atomic subformulas and then aim for
TRUE value of the respective literal; that is, we only count the
number of negations on the path from the root of the expression to the
predicate representing the relational constraint and assume TRUE for
even numbers and FALSE for odd numbers).

The actual truth values of these relations will be verified only after
all query nodes have been matched (or maybe for each node as soon as
all nodes it refers to have been matched).

4. The query context consists of:

- the node in the query-tree being matched (current query node)

- association of the previously matched query nodes with result node iterators

- information about unresolved relational constraints on already
  matched nodes

5. the search starts by creating an initial query context and a simple
iterator for the root query node matches

6. in each step one of the following cases occurs:

- the iterator for the current query node is empty
  -> backtrack: return to the state of the context of the previous query node
     and iterate the associated iterator
  -> fail if there is no previous query node

- the iterator returns a node:

  - check relational constraints depending on this node.
    If any of them invalidates the condition on an already matched node,
    itereate and repeat 6

  - if there is a following query node, make it the current query node
    and repeat 6

  - otherwise: we have a complete match. Return the match, back-track
    the context to the root-node and iterate the root-node iterator.
    Then repeat 6.

Note: #occurrences are to be implemented as sub-queries that are
processed along with other conditions within the simple iterators.
The relation predicates from these sub-queries to the out-side trees
are treated as predicate relations in complex relations and are only
resolved as soon as all required query nodes are matched.

=cut

}
1;
