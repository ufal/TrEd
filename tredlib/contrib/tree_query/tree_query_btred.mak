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

{
  our $DEBUG;
#ifdef TRED
  $DEBUG=1;
#endif
  my $query_file;
  my $query_tree;
  my $query_node;

  my @query_nodes;
  my @conditions;
  my @parent_pos;
  my @iterators;
  my @match;
  my %qnode2pos;

  my $query_pos;

  my %debug;
  my %have;

  sub reset_search {
    my ($query_tree)=@_;
    $query_node=$query_tree->firstson;
    $query_pos = 0;
    $_->reset for @iterators;
    @match=();
    %have=();
  }

  sub prepare_query {
    my ($query_tree)=@_;
    @iterators=();@conditions=();
    reset_search($query_tree);
    @query_nodes=($query_node,$query_node->descendants);
    %qnode2pos = map { $query_nodes[$_] => $_ } 0..$#query_nodes;
    @parent_pos = map { $qnode2pos{ $_->parent  } } @query_nodes;
    init_id_map($query_tree);
#    print STDERR "$query_node",$id{$query_node},"\n";
    for my $i (0..$#query_nodes) {
      my $qn = $query_nodes[$i];
      my $conditions = serialize_conditions($qn,{query_pos => $i});
      push @conditions, $conditions;
      my $iterator;
      if ($qn==$query_node) {
	# top-level node iterates throguh all nodes
	$iterator = TreeIterator->new($conditions);
      } else {
	# TODO: deal with negative relations, etc.
	my ($rel) = SeqV($qn->{relation});
	my $relation = $rel && $rel->name;
	$relation||='parent';
	print STDERR "iterator: $relation\n" if $DEBUG;
	if ($relation eq 'parent') {
	  $iterator = ChildnodeIterator->new($conditions);
	} elsif ($relation eq 'ancestor') {
	  $iterator = DescendantIterator->new($conditions);
	} elsif ($relation eq 'child') {
	  $iterator = ParentIterator->new($conditions);
	} elsif ($relation eq 'descendant') {
	  $iterator = AncestorIterator->new($conditions);
	} elsif ($relation eq 'user-defined') {
	  if ($rel->value->{label} eq 'a/aux.rf') {
	    $iterator = AAuxRFIterator->new($conditions);
	  } elsif ($rel->value->{label} eq 'a/lex.rf') {
	    $iterator = ALexRFIterator->new($conditions);
	  } elsif ($rel->value->{label} eq 'a/lex.rf|a/aux.rf') {
	    $iterator = ALexOrAuxRFIterator->new($conditions);
	  } else {
	    die "user-defined relation ".$rel->value->{label}." not yet implemented\n"
	  }
	} else {
	  die "relation ".$relation." not yet implemented\n"
	}
      }
      push @iterators, $iterator;
    }
  }

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

#ifndef TRED

  sub start_hook {
    my ($query_fn,$query_id)=@ARGV;
    $query_file = FSFile->newFSFile($query_fn,[Backends()]);
    $query_tree = $query_file->appData('id-hash')->{$query_id};
    #  print STDERR "$query_file\n";
    die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
    prepare_query($query_tree);
    # print STDERR "initialized @iterators, $query_pos\n";
    # print $query_node,",",$query_tree->{id},"\n";
  }

  sub test_btred {
    my $match;
    reset_search($query_tree);

    while ($match = find_next_match()) {
      print join(",",map { $_->{id}.": ".$_->{functor} } @$match)."\n";
    }
  }

#endif

  sub test {
    # assuming the tree we get is ordered
    my ($restart)=@_;
    my $query_tree=$root;
    my ($win) = grep {
      my $fl = GetCurrentFileList($_);
      ($fl and $fl->name eq 'Tree_Query')
    } TrEdWindows();
    print STDERR "$win\n" if $DEBUG;
    return unless $win;
    my $cur_win=$grp;
    SetCurrentWindow($win);
    print STDERR "Searching...\n" if $DEBUG;
    $Tree_Query::btred_results=1;
    %Tree_Query::is_match=();
    prepare_query($query_tree) if $restart; # we skip the root
    my $match = find_next_match();
    if ($match) {
      %Tree_Query::is_match = map { $_ => 1 } @$match;
      print join(",",map { $_->{id}.": ".$_->{functor} } @$match)."\n";
      $this = $match->[0];
    }
    print STDERR "Searching done!\n" if $DEBUG;
    Redraw();
    SetCurrentWindow($cur_win);
  }

  sub serialize_conditions {
    my ($qnode,$opts)=@_;
    $opts||={};
    my $conditions = serialize_element({
      %$opts,
      name => 'and',
      condition => $qnode->{conditions},
    });
    $debug{$qnode}=$conditions;
    print STDERR "CONDITIONS: $conditions\n" if $DEBUG;
    return eval 'sub { my ($node)=@_; $node and !exists($have{$node}) '.($conditions=~/\S/ ? ' and '.$conditions : '').' }';
  }

  sub serialize_element {
    my ($opts)=@_;
    my ($name,$value)=map {$opts->{$_}} qw(name condition);
    if ($name eq 'test') {
      my $left = serialize_expression({%$opts,expression=>$value->{a}}); # FIXME: quoting
      my $right = serialize_expression({%$opts,expression=>$value->{b}}); # FIXME: quoting
      my $operator = $value->{operator};
      if ($operator eq '=') {
	if ($right=~/^(?:\d*\.)?\d+$/ or $left=~/^(?:\d*\.)?\d+$/) {
	  $operator = '==';
	} else {
	  $operator = 'eq';
	}
      } elsif ($operator eq 'like') {
	# FIXME, this is ugly
	$operator = '=~';
	$right =~s{^'|'$}{}g;
	$right =~ s{\\}{\\\\}g;
	$right =~ s{\}}{\\\}}g;
	$right=q(m{\Q).$right.q(\E});
	$right=~s{%}{\\E.*\\Q}g;
	$right=~s{_}{\\E.\\Q}g;
	$right=~s{\\Q\\E}{}g;
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
    if ($exp=~/^'((?:\d*\.)?\d+)'$/) {
      $exp=$1;
    } else {
      $exp=~s{(?:(\w+)\.)?"([^"]+)"}{
	my $node = defined($1) ? q($iterators[$qnode2pos{$name2node_hash{').lc($1).q('}}]->node) : '$node';
	my $attr = $2;
	($attr=~m{/}) ? $node.qq{->attr(q($attr))} : $node.qq[->{q($attr)}];
      }ge;
    }
    return $exp;
  }

  sub find_next_match () {
    my $iterator = $iterators[$query_pos];
    my $node = $iterator->node;
    if ($node) {
      delete $have{$node};
      $node = $iterator->next;
      $have{$node}=1 if $node;
    } elsif ($query_pos==0) {
      # first
      print STDERR "creating Tree iterator query-node [$debug{$query_node}]\n" if $DEBUG;
      $node = $iterator->start();
      $have{$node}=1 if $node;
    }
    while (1) {
      if (!$node) {
	if ($query_pos) {
	  print STDERR "no node: backtracking from $query_node, $query_pos\n" if $DEBUG;
	  # backtrack
	  print STDERR "old_query_node: $id{$query_node}, $debug{$query_node}, $iterators[$query_pos]\n" if $DEBUG;

	  $query_pos -= 1; # backtrack
	  $query_node = $query_nodes[$query_pos];
	  $iterator=$iterators[$query_pos];

	  print STDERR "query_node: $id{$query_node}, $debug{$query_node}, $iterators[$query_pos]\n" if $DEBUG;
	  delete $have{$node} if $node;
	  $node = $iterator->next;
	  $have{$node}=1 if $node;
	  next;
	} else {
	  print STDERR "no node: no result\n" if $DEBUG;
	  return; # NO RESULT
	}
      } else {
	print STDERR "at: $id{$query_node}, $debug{$query_node} with node: $node->{t_lemma},$node->{functor}\n" if $DEBUG;

	# TODO: check relational constraints, backtrack on invalidate
	if ($query_pos<$#query_nodes) {
	  $query_node =  $query_nodes[++$query_pos];
	  my $relation = $query_node->{relation} || 'parent';
	  my $seed = $iterators[$parent_pos[$query_pos]]->node;
	  print STDERR "creating iterator for query-node [$debug{$query_node}] with seed-node: $seed->{t_lemma},$seed->{functor}\n" if $DEBUG;
	  $iterator = $iterators[$query_pos];
	  $node = $iterator->start($seed);
	  $have{$node}=1 if $node;
	  next;
	} else {
	  print STDERR "complete match\n" if $DEBUG;
	  # complete match:
	  return [map { $_->node } @iterators];
	}
      }
    }
  }# search

}
#################################################
package Tree_Query::Iterator;
use constant CONDITIONS=>0;
use Carp;
sub new ($$) {
  my ($class,$conditions)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions],$class;
}
sub start ($$) {}
sub next ($) {}
sub node ($) {}
sub reset ($) {}


#################################################
package TreeIterator;
use base qw(Tree_Query::Iterator);
BEGIN {
  import TredMacro qw($this $root);
}
use constant CONDITIONS=>0;
use constant NODE=>1;
sub start ($$) {
  my ($self)=@_;
  # TredMacro::GotoFileNo(0);
  TredMacro::GotoTree(0);
  $this=$root;
  $self->[NODE]=$this;
  return $self->[CONDITIONS]->($this) ? $this : ($this && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  while ($n) {
    $n = $n->following || (TredMacro::NextTree() && $this);
    last if $conditions->($n);
  }
  return $self->[NODE]=$n;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
}

package ChildnodeIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
sub start ($$) {
  my ($self,$parent)=@_;
  my $n = $self->[NODE]=$parent->firstson;
  return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE]->rbrother;
  $n=$n->rbrother while ($n and !$conditions->($n));
  return $self->[NODE]=$n;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
}

package DescendantIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
use constant TOP=>2;

sub start ($$) {
  my ($self,$parent)=@_;
  my $n= $parent->firstson;
  $self->[NODE]=$n;
  $self->[TOP]=$parent;
  return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $top = $self->[TOP];
  my $n=$self->[NODE]->following($top);
  $n=$n->following($top) while ($n and !$conditions->($n));
  return $self->[NODE]=$n;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
  $self->[TOP]=undef;
}

package ParentIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
sub start ($$) {
  my ($self,$node)=@_;
  my $n = $node->parent;
  return $self->[NODE] = $self->[CONDITIONS]->($n) ? $n : undef;
}
sub next ($) {
  return $_[0]->[NODE]=undef;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
}

package AncestorIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
sub start ($$) {
  my ($self,$node)=@_;
  my $n = $node->parent;
  $self->[NODE]=$n;
  return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE]->parent;
  $n=$n->parent while ($n and !$conditions->($n));
  return $_[0]->[NODE]=$n;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
}

package ALexRFIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
sub start ($$) {
  my ($self,$node)=@_;
  my $lex_rf = $node->attr('a/lex.rf');
  my $refnode;
  if (defined $lex_rf) {
    $lex_rf=~s/^.*?#//;
    $refnode=PML_T::GetANodeByID($lex_rf);
    print $lex_rf," => $refnode\n";
  }
  return $self->[NODE]= $self->[CONDITIONS]->($refnode) ? $refnode : undef;
}
sub next ($) {
  return $_[0]->[NODE]=undef;
}
sub node ($) {
  return $_[0]->[NODE];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODE]=undef;
}

package AAuxRFIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODES=>1;
sub start ($$) {
  my ($self,$node)=@_;
  my @aux_rf = ListV($node->attr('a/aux.rf'));
  $self->[NODES]=[grep defined, map {
    my $id = $_; $id=~s/^.*?#//;
    PML_T::GetANodeByID($id)
    } @aux_rf];
  my $n = $self->[NODES]->[0];
  return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $nodes = $_[0]->[NODES];
  my $conditions=$self->[CONDITIONS];
  shift @{$nodes};
  shift @{$nodes} while ($nodes->[0] and !$conditions->($nodes->[0]));
  return $nodes->[0];
}
sub node ($) {
  return $_[0]->[NODES]->[0];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODES]=undef;
}

package ALexOrAuxRFIterator;
use base qw(Tree_Query::Iterator);
use constant CONDITIONS=>0;
use constant NODES=>1;
sub start ($$) {
  my ($self,$node)=@_;
  $self->[NODES]=[PML_T::GetANodes($node)];
  my $n = $self->[NODES]->[0];
  return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
}
sub next ($) {
  my ($self)=@_;
  my $nodes = $self->[NODES];
  my $conditions=$self->[CONDITIONS];
  shift @{$nodes};
  shift @{$nodes} while ($nodes->[0] and !$conditions->($nodes->[0]));
  return $nodes->[0];
}
sub node ($) {
  return $_[0]->[NODES]->[0];
}
sub reset ($) {
  my ($self)=@_;
  $self->[NODES]=undef;
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

