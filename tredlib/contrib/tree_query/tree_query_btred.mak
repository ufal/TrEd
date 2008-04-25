# -*- cperl -*-

{
package Tree_Query_Btred;
use strict;

BEGIN {
  use vars qw($this $root);
  import TredMacro;
}

Bind sub { test(1); ChangingFile(0) } => {
  key => 't',
  menu => 'Test btred search',
  context=>'Tree_Query',
};
Bind \&test => {
  key => 'T',
  menu => 'Test btred find next',
  changing_file => 0,
  context=>'Tree_Query',
};


sub test {
  # assuming the tree we get is ordered
  my ($restart)=@_;
  my $query_tree=$root;
  my ($win) = grep {
    my $fl = GetCurrentFileList($_);
    ($fl and $fl->name eq 'Tree_Query')
  } TrEdWindows();
  print STDERR "$win\n";
  return unless $win;
  my $cur_win=$grp;
  SetCurrentWindow($win);
  print STDERR "Searching...\n";
  $Tree_Query::btred_results=1;
  %Tree_Query::is_match=();
  init_search($query_tree) if $restart; # we skip the root
  my $match = find_next_match();
  if ($match) {
    %Tree_Query::is_match = map { $match->{$_} => 1 } keys %$match;
    print join(",",map { $match->{$_}->{id} 
		       } keys %$match)."\n";
  }
  print STDERR "Searching done!\n";
  Redraw();
  SetCurrentWindow($cur_win);
}




{
  my $query_file;
  my $query_tree;
  my $query_node;
  my @query_stack;
  my %iterator;
  my %conditions;
  my %debug;
  my $ctxt; # not yet used

  my %id;
  my %name2node_hash;
  sub init_id_map {
    my ($tree)=@_;
    my @nodes = $tree->descendants;
    %id = map {
      my $n=lc($_->{name});
    (defined($n) and length($n)) ? ($_=>$n) : ()
  } @nodes;
    %name2node_hash = map {
      my $n=lc($_->{name});
      (defined($n) and length($n)) ? ($n=>$_) : ()
  } @nodes;
    my $id = 'n0';
    my %occup; @occup{values %id}=();
    for my $n (@nodes) {
      unless (defined $id{$n} and length $id{$n}) {
	$id++ while exists $occup{$id}; # just for sure
	$id{$n}=$id; # generate id;
	$occup{$id}=1;
      }
    };
  }

  sub start_hook {
    my ($query_fn,$query_id)=@ARGV;
    $query_file = FSFile->newFSFile($query_fn,[Backends()]);
    $query_tree = $query_file->appData('id-hash')->{$query_id};
    #  print STDERR "$query_file\n";
    die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
    init_search($query_tree);
    print "initialized\n";
    print $query_node,",",$query_tree->{id},"\n";
  }

  sub test_btred {
    my $match;
    reset_search($query_tree);

    while ($match = find_next_match()) {
      print join(",",map { $id{$_}.": ".$match->{$_}->{id}.": ".$match->{$_}->{functor} }
      		 sort {$id{$a} cmp $id{$b}}
      		 keys %$match)."\n";
    }
  }

  sub reset_search {
    my ($query_tree)=@_;
    $query_node=$query_tree->firstson;
    %iterator=();
    $ctxt={};
  }

  sub init_search {
    my ($query_tree)=@_;
    @query_stack=();
    reset_search($query_tree);
    init_id_map($query_node);
#    print STDERR "$query_node",$id{$query_node},"\n";
    %conditions = ( map { $_ => serialize_conditions($_) } ($query_node,$query_node->descendants) );
    $ctxt={};
  }

  sub serialize_conditions {
    my ($qnode,$opts)=@_;
    $opts||={};
    my $conditions = serialize_element({
      %$opts,
      name => 'and',
      condition => $qnode->{conditions},
    });
#    print STDERR "CONDITIONS: $conditions\n";
    $debug{$qnode}=$conditions;
    return eval 'sub { my ($node)=@_; '.$conditions.' }';
  }

  sub serialize_element {
    my ($opts)=@_;
    my ($name,$value)=map {$opts->{$_}} qw(name condition);
    if ($name eq 'test') {
      my $left = serialize_expression({%$opts,expression=>$value->{a}});
      my $right = serialize_expression({%$opts,expression=>$value->{b}});
      my $operator = $value->{operator};
      if ($operator eq '=') {
	$operator = 'eq';
      } elsif ($operator eq '~') {
	$operator = '=~';
      }
      return ($value->{negate}==1 ? 'not' : '').
	('('.$left.' '.$operator.' '.$right.')');
    } elsif ($name =~ /^(?:and|or)$/) {
      my $seq = $value->{'#content'};
      return () unless (UNIVERSAL::isa( $seq, 'Fslib::Seq') and @$seq);
      my $condition = join(' '.$name.' ',
			   grep { defined and length }
			     map {
			       my $n = $_->name;
			       serialize_element({
				 %$opts,
				 name => $n,
				 condition => $_->value,
			       }) } $seq->elements);
      return () unless length $condition;
      return ($value->{negate} ? "not($condition)" : "($condition)");
    } else {
      warn "Unknown element $name ";
    }
  }
  sub serialize_expression {
    my ($opts)=@_;
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
    $exp=~s{(?:(\w+)\.)?"([^"]+)"}{
      my $node = defined($1) ? q($iterator{$name2node_hash{').lc($1).q('}}->node) : '$node';
      my $attr = $2;
      ($attr=~m{/}) ? $node.qq{->attr(q($attr))} : $node.qq[->{q($attr)}];
    }ge;
    return $exp;
  }

  sub find_next_match () {
    my $iterator = $iterator{$query_node};
    if ($iterator) {
      # next
      if ($iterator->node) {
	my $conditions = $conditions{$query_node};
	$iterator->next;
	$iterator->next while $iterator->node and !$conditions->($iterator->node);
      }
    } else {
      # first
      $iterator = $iterator{$query_node} = new_iterator();
    }
    while (1) {
      my $node = $iterator->node;
      if (!$node) {
	if (@query_stack) {
#	  print STDERR "no node: backtracking from $query_node\n";
	  # backtrack
	  delete $iterator{$query_node};
	  my $last=pop @query_stack;
	  ($query_node,$ctxt)=@$last;
#	  print STDERR "query_node: $id{$query_node}, $debug{$query_node}, $iterator{$query_node}\n";
	  $iterator=$iterator{$query_node};
	  if ($iterator->node) {
	    $iterator->next;
	    my $conditions = $conditions{$query_node};
	    $iterator->next while $iterator->node and !$conditions->($iterator->node);
	  }
	  next;
	} else {
#	  print STDERR "no node: no result\n";
	  return; # NO RESULT
	}
      } else {
	# TODO: check relational constraints, backtrack on invalidate
	my $next =  $query_node->following;
	unless ($next) {
#	  print STDERR "complete match\n";
	  # complete match:
	  return { map { $_ => $iterator{$_}->node } keys %iterator };
	}
	push @query_stack, [$query_node,$ctxt];
	$query_node=$next;
	my $relation = $query_node->{relation} || 'parent';
	my $seed = $iterator{$query_node->parent}->node;
#	print STDERR "creating iterator for query-node [$debug{$query_node}] with seed-node: $seed->{t_lemma},$seed->{functor}\n";
	$iterator = $iterator{$query_node} = new_iterator($seed); # node is the seed
	next;
      }
    }
  }# search

  sub new_iterator {
    my ($node)=@_;
    # TODO: conditions
    # TODO: deal with negative relations
    my $iterator;
    if ($node) {
      my ($relation) = map {$_->name} SeqV($query_node->{relation});
      $relation||='parent';
#      print STDERR "iterator: $relation\n";
      if ($relation eq 'parent') {
	$iterator = ChildnodeIterator->new($node);
      } elsif ($relation eq 'ancestor') {
	$iterator = DescendantIterator->new($node);
      } elsif ($relation eq 'child') {
	$iterator = ParentIterator->new($node);
      } elsif ($relation eq 'descendant') {
	$iterator = AncestorIterator->new($node);
      }
    } else {
      $iterator = TreeIterator->new();
    }
    my $conditions = $conditions{$query_node};
    $iterator->next while $iterator->node and !$conditions->($iterator->node);
    return $iterator;
  }
}



package TreeIterator;
BEGIN {
  import TredMacro qw($this $root);
}
use constant NODE=>0;
sub new ($) {
  my ($class)=@_;
#  TredMacro::GotoFileNo(0);
  TredMacro::GotoTree(0);
  $this=$root;
  return bless [$this],$class;
}

sub next ($) {
  $_[0]->[NODE] = ($_[0]->[NODE]->following || (TredMacro::NextTree() && $this));
}

sub node ($) {
  return $_[0]->[NODE];
}

package ChildnodeIterator;

use constant NODE=>0;

sub new ($$) {
  my ($class,$parent)=@_;
  bless [$parent->firstson],$class;
}

sub next ($) {
  my ($self)=@_;
  return $self->[0]=$self->[NODE]->rbrother;
}

sub node ($) {
  return $_[0]->[NODE];
}

package DescendantIterator;

use constant NODE=>0;
use constant TOP=>1;

sub new ($$) {
  my ($class,$parent)=@_;
  bless [$parent->firstson,$parent],$class;
}

sub next ($) {
  my ($self)=@_;
  return $self->[0]=$self->[NODE]->following($self->[TOP]);
}

sub node ($) {
  return $_[0]->[NODE];
}

package ParentIterator;

use constant NODE=>0;

sub new ($$) {
  my ($class,$node)=@_;
  bless [$node->parent],$class;
}

sub next ($) {
  return $_[0]->[0]=undef;
}

sub node ($) {
  return $_[0]->[NODE];
}

package AncestorIterator;

use constant NODE=>0;

sub new ($$) {
  my ($class,$node)=@_;
  bless [$node->parent],$class;
}

sub next ($) {
  return $_[0]->[0]=$_[0]->[0]->parent;
}

sub node ($) {
  return $_[0]->[NODE];
}


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

- a flag RETURNING indicating that all child-nodes have been matched

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

  - if RETURNING==0 and the current query node has
    child-nodes, make the first of them the current node and repeat 6

  - if the current query node has a right sibling, make it the current node,
    and set RETURNING=0

  - if the current query node has a parent, set RETURNING=1 and make the parent node the current node;

  - otherwise: we have a complete match. Return the match, back-track
    the context to the root-node and iterate the root-node iterator.
    Then repeat 6.

Note: #occurrences are treated as sub-queries that are processed by
the simple iterators. The relation predicates from these sub-queries
to the out-side trees are treated as predicate relations in complex
relations and are only resolved as soon as all required query nodes
are matched.

More implementation details:

back-tracking: either know how what to discard from the context or
clone the context upon moving the context-node forward and return to
the previous context when returning back

Iterator:
 ->node (the current result node)
 ->iterate (returns 0 or 1)

may, for efficiency, be not an Object but a triplet:

$iterator=[$node,$data,$code_ref], with iterate being implemented as $code_ref->($data,$node);

where the $data may consist of a 'seed' (e.g. the parent node)

=cut



}
1;

