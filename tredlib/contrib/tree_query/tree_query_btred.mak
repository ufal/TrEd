# -*- cperl -*-

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

sub test_btred {
  shift if $_[0] eq __PACKAGE__;
  my ($query_fn,$query_id)=@_;
  my $query_file = FSFile->newFSFile($query_fn,[Backends()]);
  print STDERR "$query_file\n";
  my $query_tree = $query_file->appData('id-hash')->{$query_id};
  die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
  init_search($query_tree);
  my $match;
  while ($match = find_next_match()) {
    print join(",",map { $id{$_}.": ".$match->{$_}->{id}.": ".$match->{$_}->{functor} }
		 sort {$id{$a} cmp $id{$b}}
		 keys %$match)."\n";
  }
}



  sub init_search {
    my ($query_tree)=@_;
    $query_node=$query_tree->firstson; # skipping the technical root, we should instead rebuild the tree using Kruskal
    init_id_map($query_node);
    @query_stack=();
    %iterator=();
    print STDERR "$query_node",$id{$query_node},"\n";
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
    print STDERR "CONDITIONS: $conditions\n";
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
      $node.qq{->attr(q($2))};
    }ge;
    return $exp;
  }

  sub find_next_match () {
    if ($iterator{$query_node}) {
      # next
      if ($iterator{$query_node}->node) {
	$iterator{$query_node}->next;
	$iterator{$query_node}->next while $iterator{$query_node}->node and !$conditions{$query_node}->($iterator{$query_node}->node);
      }
    } else {
      # first
      $iterator{$query_node} = new_iterator();
    }
    while (1) {
      my $node = $iterator{$query_node}->node;
      if (!$node) {
	if (@query_stack) {
	  print STDERR "no node: backtracking from $query_node\n";
	  # backtrack
	  delete $iterator{$query_node};
	  my $last=pop @query_stack;
	  ($query_node,$ctxt)=@$last;
	  print STDERR "query_node: $id{$query_node}, $debug{$query_node}, $iterator{$query_node}\n";
	  if ($iterator{$query_node}->node) {
	    $iterator{$query_node}->next;
	    $iterator{$query_node}->next while $iterator{$query_node}->node and !$conditions{$query_node}->($iterator{$query_node}->node);
	  }
	  next;
	} else {
	  print STDERR "no node: no result\n";
	  return; # NO RESULT
	}
      } else {
	# TODO: check relational constraints, backtrack on invalidate
	my $next =  $query_node->following;
	unless ($next) {
	  print STDERR "complete match\n";
	  # complete match:
	  return { map { $_ => $iterator{$_}->node } keys %iterator };
	}
	push @query_stack, [$query_node,$ctxt];
	$query_node=$next;
	my $relation = $query_node->{relation} || 'parent';
	my $seed = $iterator{$query_node->parent}->node;
	print STDERR "creating iterator for query-node [$debug{$query_node}] with seed-node: $seed->{t_lemma},$seed->{functor}\n";
	$iterator{$query_node} = new_iterator($seed); # node is the seed
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
      print STDERR "iterator: $relation\n";
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
    $iterator->next while $iterator->node and !$conditions{$query_node}->($iterator->node);
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


1;

