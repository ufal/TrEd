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

our $DEBUG;
#ifdef TRED
$DEBUG=1;
#endif

my $evaluator;
#ifndef TRED
sub start_hook {
  my ($query_fn,$query_id)=@ARGV;
  my $query_file = FSFile->newFSFile($query_fn,[Backends()]);
  my $query_tree = $query_file->appData('id-hash')->{$query_id};
  #  print STDERR "$query_file\n";
  die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
  $evaluator = Tree_Query::Evaluator->new($query_tree);

  # print STDERR "initialized @iterators, $query_pos\n";
  # print $query_node,",",$query_tree->{id},"\n";
}

sub test_btred {
  my $match;
  while ($match = $evaluator->find_next_match()) {
    print join(",",map { $_->{id}.": ".$_->{functor} } @$match)."\n";
  }
  $evaluator->reset(); # prepare for next file
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

  $evaluator = Tree_Query::Evaluator->new($query_tree) if !$evaluator or $restart;
#  return;
  my $match = $evaluator->find_next_match();
  if ($match) {
    %Tree_Query::is_match = map { $_ => 1 } @$match;
    print join(",",map { $_->{id}.": ".$_->{functor} } @$match)."\n";
    $this = $match->[0];
  }

  print STDERR "Searching done!\n" if $DEBUG;

  Redraw();
  SetCurrentWindow($cur_win);
}

###########################################
{
  package Tree_Query::Evaluator;
  use strict;
  use Scalar::Util qw(weaken);

  my %test_relation = (
    'ancestor-of'   => q(first { $_ == $start } $end->ancestors), # not very effective !!
    'descendant-of' => q(first { $_ == $end } $start->ancestors), # not very effective !!

    'child-of' => q($start->parent == $end),
    'parent-of' => q($end->parent == $start),

    'order-precedes' => q($start->get_order < $end->get_order ), # not very effective !!
    'order-follows' => q($end->get_order < $start->get_order ), # not very effective !!

    'depth-first-precedes' => q( $start->root==$end->root and  do{my $n=$start->following; $n=$n->following while ($n and $n!=$end); $n ? 1 : 0 }), # not very effective !!
    'depth-first-follows' => q( $start->root==$end->root and  do{my $n=$end->following; $n=$n->following while ($n and $n!=$start); $n ? 1 : 0 }), # not very effective !!
   );

  my %test_user_defined_relation = (
    'eparent_of' => q(do{ my $type = $node->type->get_base_type_name;
                        first { $_ == $start }
                        ($type eq 't-node.type' ? PML_T::GetEParents($end) :
                         $type eq 'a-node.type' ? PML_A::GetEParents($end,\\&PML_A::DiveAuxCP) : ()) }),
    'echild_of' => q(do{ my $type = $node->type->get_base_type_name;
                        first { $_ == $end }
                        ($type eq 't-node.type' ? PML_T::GetEParents($start) :
                         $type eq 'a-node.type' ? PML_A::GetEParents($start,\\&PML_A::DiveAuxCP) : ()) }),
    'a/lex.rf|a/aux.rf' => q(first { $_ eq $end->{id} } GetANodeIDs()),
    'a/lex.rf' => q(do { my $id=$start->attr('a/lex.rf'); $id=~s/^.*?#//; $id  eq $end->{id} } ),
    'a/aux.rf' => q(first { my $id=$_; $id=~s/^.*?#//; $id eq $end->{id} } TredMacro::ListV($start->attr('a/lex.rf'))),
    'coref_text' => q(first { $_ eq $end->{id} } TredMacro::ListV($start->{'coref_text.rf'})),
    'coref_gram' => q(first { $_ eq $end->{id} } TredMacro::ListV($start->{'coref_gram.rf'})),
    'compl' => q(first { $_ eq $end->{id} } TredMacro::ListV($start->{'compl.rf'})),
   );

  sub _filter_subqueries {
    my ($node)=@_;
    return $node, map {
      length($_->{occurrences}) ?  () : _filter_subqueries($_)
    } $node->children;
  }

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


      matched_nodes => $matched_nodes, # nodes matched so far (incl. nodes in subqueries; used for evaluation of cross-query relations)

      name2pos => \%name2pos,
      parent_pos => undef,
      pos2match_pos => undef,
      name2match_pos => undef,
    }, $class;
    weaken($self->{parent_query}) if $self->{parent_query};
    $query_pos = \$self->{query_pos};

    my $type = $query_tree->type->get_base_type_name;
    my $query_node = $type eq 'q-query.type' ? $query_tree->firstson :
                     $type eq 'q-node.type' ? $query_tree :
		     die "Query root is not a a query-tree node: $type!";

    my @query_nodes=_filter_subqueries($query_node);
    %name2pos = map {
      my $name = lc($query_nodes[$_]->{name});
      (defined($name) and length($name)) ? ($name=>$_) : ()
    } 0..$#query_nodes;

    {
      my @all_query_nodes = ($query_node->root->descendants);
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
    {
      my %node2pos = map { $query_nodes[$_] => $_ } 0..$#query_nodes;
      $self->{parent_pos} = [ map { $node2pos{ $_->parent  } } @query_nodes ];
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
	$iterator = TreeIterator->new($conditions);
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
    $relation||='parent';

    print STDERR "iterator: $relation\n" if $DEBUG;
    my $iterator;
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
      } elsif ($rel->value->{label} eq 'coref_text') {
	$iterator = CorefTextRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'coref_gram') {
	$iterator = CorefGramRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'compl') {
	$iterator = ComplRFIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'eparent') {
	$iterator = EChildIterator->new($conditions);
      } elsif ($rel->value->{label} eq 'echild_of') {
	$iterator = EParentIterator->new($conditions);
      } else {
	die "user-defined relation ".$rel->value->{label}." not yet implemented\n"
      }
    } else {
      die "relation ".$relation." not yet implemented\n"
    }
    return $iterator;
  }

  sub serialize_conditions {
    my ($self,$qnode,$opts)=@_;
    my $conditions = $self->serialize_element({
      %$opts,
      name => 'and',
      condition => $qnode->{conditions},
    });

    my $pos = $opts->{query_pos};
    my $match_pos = $self->{pos2match_pos}[$pos];

    # extra-relations:
    # relations aiming forward will be evaluated on the target node
    my $reverted=$opts->{reverted_relations};
    my @relations = defined($reverted->[$pos]) ? @{$reverted->[$pos]} : (); # won't be needed when we plan the query
    for my $rel (TredMacro::SeqV($qnode->attr('extra-relations'))) {
      my $relation = $rel->name;
      my $target = lc( $rel->value->{target} );
      my $expression;
      if ($relation eq 'user-defined') {
	my $label = $rel->value->{label};
	$expression = $test_user_defined_relation{$label};
	die "User-defined relation '$label' not supported test!\n" unless defined $expression;
      } else {
	$expression = $test_relation{$relation};
	die "Relation '$relation' not supported test!\n" unless defined $expression;
      }
      $expression = $rel->value->{negate} ? 'not('.$expression.')' : '('.$expression.')';

      my $target_pos = $self->{name2pos}{$target};
      my $target_match_pos = $self->{name2match_pos}{$target};
      if (defined $target_pos) {
	# target node in the same sub-query
	if ($target_pos<$pos) {
	  push @relations, q/ do{ my ($start,$end)=($node,$matched_nodes->[/.$target_match_pos.q/]); /.$expression.q/ } /;
	} elsif ($target_pos>$pos) {
	  # evaluate at target node
	  push @{$reverted->[$target_pos]}, q/ do{ my ($end,$start)=($node,$matched_nodes->[/.$match_pos.q/]); /.$expression.q/ } /;
	} else {
	  # huh, really?
	  push @relations, q/ do{ my ($start,$end)=($node,$node); /.$expression.q/ } /;
	}
      } elsif (defined $target_match_pos) {
	# this node is matched by some super-query
	my $expr = q/do{ my ($start,$end)=($node,$matched_nodes->[/.$target_match_pos.q/]); /.$expression.q/ }/;
	push @relations, $expr;
	if ($target_match_pos > $match_pos) {
	  # we need to postpone the evaluation of the whole sub-query up-till $matched_nodes->[$target_pos] is known
	  $self->{postpone_subquery_till}=$target_match_pos if ($self->{postpone_subquery_till}||0)<$target_match_pos;
	}
      } else {
	die "Node '$target' does not exist or belongs to a sub-query and cannot be referred from here!\n";
      }
    }

    my @subquery_nodes = grep { length($_->{occurrences}) } $qnode->children;
    my @subquery_conditions;
    for my $sqn (@subquery_nodes) {
      # TODO: cross-query dependencies
      my $subquery = ref($self)->new($sqn, {
	parent_query => $self,
	parent_query_pos => $opts->{query_pos},
      });
      push @{$self->{sub_queries}}, $subquery;
      my $sq_pos = $#{$self->{sub_queries}};
      my $sq_condition = qq/\$sub_queries[$sq_pos]->test_occurrences(\$node,$sqn->{occurrences})/;
      my $postpone_subquery_till = $subquery->{postpone_subquery_till};
      if (defined $postpone_subquery_till) {
	if ($postpone_subquery_till<=$self->{pos2match_pos}[-1]) {
	  # same subquery, simply postpone, just like when recomputing conditions
	  push @{$opts->{recompute_subquery}[$postpone_subquery_till]},
	    qq/\$sub_queries[$sq_pos]->test_occurrences(\$matched_nodes->[$match_pos],$sqn->{occurrences})/;
	} else {
	  # otherwise postpone this subquery as well
	  $self->{postpone_subquery_till}=$postpone_subquery_till if $postpone_subquery_till>($self->{postpone_subquery_till}||0);
	  push @subquery_conditions,$sq_condition;
	}
      } else {
	push @subquery_conditions,$sq_condition;
      }

    }

    print STDERR "CONDITIONS[$pos/$match_pos]: $conditions\n" if $DEBUG;
    my $check_preceding = '';

    my $recompute_cond = $opts->{recompute_condition}[$pos];
    if (defined $recompute_cond) {
      $check_preceding = join('', map {"\n   and ".'$conditions['.$_.']->($matched_nodes->['.$self->{pos2match_pos}[$_].']) '} sort { $a<=>$b } keys %$recompute_cond);
    }
    my $recompute_sq = $opts->{recompute_subquery}[$match_pos];
    if (defined $recompute_sq) {
      $check_preceding .= join('', map {"\n  and ".$_ } @$recompute_sq);
    }
    if (length $check_preceding) {
      $check_preceding = "\n  and ".'($matched_nodes->['.$match_pos.']=$node) # a trick: make it appear as if this node already matched!'.$check_preceding;
    }
    my $sub = 'sub { my ($node)=@_; '."\n  ".
                       '$node and !exists($have{$node})'
		       .($conditions=~/\S/ ? "\n  and ".$conditions : '')
			 .(join '',map { "\n  and ".$_ } @relations )
			 .(join '',map { "\n  and ".$_ } @subquery_conditions )
			   .$check_preceding."\n}";

    print STDERR "SUB: $sub\n" if $DEBUG;
    return $sub;
  }

  sub serialize_element {
    my ($self,$opts)=@_;
    my ($name,$value)=map {$opts->{$_}} qw(name condition);
    if ($name eq 'test') {
      my %depends_on;
      my $left = $self->serialize_expression({%$opts,
					      depends_on => \%depends_on,
					      expression=>$value->{a}
					     }); # FIXME: quoting
      my $right = $self->serialize_expression({%$opts,
					       depends_on => \%depends_on,
					       expression=>$value->{b}
					      }); # FIXME: quoting
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
      my $last_dependency = TredMacro::max($opts->{query_pos},keys %depends_on);
      my $pos = $opts->{query_pos};
      if ($last_dependency>$pos) {
	$opts->{recompute_condition}[$_]{$pos}=1 for keys %depends_on;
	my $truth_value = $opts->{negative_formula} ? 0 : 1;
	$truth_value=!$truth_value if $value->{negate};
	return ($value->{negate}==1 ? 'not' : '').
	  ('( $$query_pos < '.$last_dependency.' ? '.$truth_value.'  : ('.$left.' '.$operator.' '.$right.'))');
      } else {
	return ($value->{negate}==1 ? 'not' : '').
	  ('('.$left.' '.$operator.' '.$right.')');
      }
    } elsif ($name =~ /^(?:and|or)$/) {
      my $seq = $value->{'#content'};
      return () unless (UNIVERSAL::isa( $seq, 'Fslib::Seq') and @$seq);
      my $negative = $opts->{negative_formula} ? 1 : 0;
      $negative=!$negative if $value->{negate};
      my $condition = join(' '.$name.' ',
			   grep { defined and length }
			     map {
			       my $n = $_->name;
			       $self->serialize_element({
				 %$opts,
				 negative_formula => $negative,
				 name => $n,
				 condition => $_->value,
			       })
			     } $seq->elements);
      return () unless length $condition;
      return ($value->{negate} ? "not($condition)" : "($condition)");
    } else {
      die "Unknown element $name ";
    }
  }

  sub serialize_expression {
    my ($self,$opts)=@_;
    my $parent_id = $opts->{parent_id};
    my $pos = $opts->{query_pos};
    my $match_pos = $self->{pos2match_pos}[$pos];

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
	  my $target_pos = $self->{name2pos}{$target};
	  my $target_match_pos = $self->{name2match_pos}{$target};
	  if (defined $target_pos) {
	    # target node in the same sub-query
	    $node='$matched_nodes->['.$target_match_pos.']';
	    if ($target_pos>$pos) {
	      $opts->{depends_on}{$pos}=1;
	    }
	  } elsif (defined $target_match_pos) {
	    # this node is matched by some super-query
	    $node='$matched_nodes->['.$target_match_pos.']';
	    if ($target_match_pos > $match_pos) {
	      # we need to postpone the evaluation of the whole sub-query up-till $matched_nodes->[$target_pos] is known
	      $self->{postpone_subquery_till}=$target_match_pos if ($self->{postpone_subquery_till}||0)<$target_match_pos;
	    }
	  } else {
	    die "Node '$target' does not exist or belongs to a sub-query and cannot be referred from here!\n";
	  }
	}
	($attr=~m{/}) ? $node.qq{->attr(q($attr))} : $node.qq[->{q($attr)}];
      }ge;
    }
    return $exp;
  }

  sub test_occurrences {
    my ($self,$seed,$test_count)=@_;
    $self->reset();
    my $count=0;
    $count++ while $self->find_next_match({boolean => 1, seed=>$seed}) and $count<=$test_count;
    # print "occurrences: >=$count\n" if $DEBUG;
    $self->reset();
    return ($count==$test_count) ? 1 : 0;
  }

  sub find_next_match ($) {
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

	# TODO: check relational constraints, backtrack on invalidate
	print STDERR ("match $node->{id}: $node->{t_lemma}.$node->{functor}\n") if $DEBUG;

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
  }				# search
  return;
}

#################################################
{
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
}
#################################################
{
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
#    TredMacro::GotoTree(0);
    $this=$root;
    $self->[NODE]=$this;
    return $self->[CONDITIONS]->($this) ? $this : ($this && $self->next);
  }
  sub next ($) {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    while ($n) {
      $n = $n->following ; # || (TredMacro::NextTree() && $this);
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
}
#################################################
{
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
}
#################################################
{
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
}
#################################################
{
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
}
#################################################
{
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
}
#################################################
{
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
}
#################################################
{
  package SimpleListIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODES=>1;
  sub start ($$) {
    my ($self,$node)=@_;
    $self->[NODES] = $self->get_node_list($node);
    my $n = $self->[NODES]->[0];
    return $self->[CONDITIONS]->($n) ? $n : ($n && $self->next);
  }
  sub next ($) {
    my ($self)=@_;
    my $nodes = $self->[NODES];
    my $conditions=$self->[CONDITIONS];
    shift @{$nodes};
    while ($nodes->[0] and !$conditions->($nodes->[0])) {
      shift @{$nodes};
    }
    return $nodes->[0];
  }
  sub node ($) {
    my ($self)=@_;
    return $self->[NODES]->[0];
  }

  sub reset ($) {
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
  sub get_node_list ($$) {
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
  sub get_node_list ($$) {
    my ($self,$node)=@_;
    return [PML_T::GetANodes($node)];
  }
}
#################################################
{
  package CorefTextRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list ($$) {
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
  sub get_node_list ($$) {
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
  sub get_node_list ($$) {
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
  sub get_node_list ($$) {
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
  sub get_node_list ($$) {
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

