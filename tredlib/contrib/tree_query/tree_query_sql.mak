# -*- cperl -*-
################
### SQL compiler and evaluator
################
{

package Tree_Query::SQLEvaluator;
use Benchmark;
use Carp;
use strict;
use warnings;
BEGIN { import TredMacro qw(first SeqV AltV ListV) }

sub new {
  my ($class,$query_tree,$opts)=@_;
  my $self = bless {
    dbi => $opts->{dbi},
    connect => $opts->{connect},
    results => undef,
    query_nodes=>undef,
  }, $class;
  $self->prepare_query($query_tree,$opts) if $query_tree;
  return $self;
}

sub get_results {
  my $self = shift;
  return $self->{results} || [];
}

sub get_query_nodes {
  my $self = shift;
  return $self->{query_nodes};
}

sub get_sql {
  my $self = shift;
  return $self->{sql};
}

sub prepare_sql {
  my ($self,$sql)=@_;
  $self->{sth} = undef;
  $self->{sql} = $sql;
  my $dbi = $self->{dbi} || $self->connect();
  if ($self->sql_driver eq 'Pg') {
    $self->{sth} = $dbi->prepare( $sql, { pg_async => 1 } );
  } else {
    $self->{sth} = $dbi->prepare( $sql );
  }
}

sub prepare_query {
  my ($self,$query_tree,$opts)=@_;
  $opts||={};
  unless (ref($query_tree)) {
    $query_tree = Tree_Query::parse_query($query_tree);
  }
  $self->{id} = $query_tree->{id} || 'no_ID';
  $self->{query_nodes} = [Tree_Query::FilterQueryNodes($query_tree)];
  {
    my %id;
    my %name2node_hash;
    my @nodes = grep { $_->{'#name'} =~ /^(?:node|subquery)$/ } $query_tree->descendants;
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
	$id{$n}=$id;			# generate id;
	$occup{$id}=1;
	$name2node_hash{$id}=$n;
      }
    }
    ;
    $self->{id_map}=\%id;
    $self->{name2node}=\%name2node_hash;
  }
  $self->prepare_sql($self->sql_serialize_conditions($query_tree,
						     { %$opts,
						       syntax=>$self->sql_driver,
						       limit=>$self->{limit}
						      }));
}

sub sql_driver {
  my ($self)=@_;
  return $self->{connect}{driver};
}

sub connect {
  my ($self)=@_;
  return $self->{dbi} if $self->{dbi};
  my $cfg = $self->{connect};
  require DBI;
  require Sys::SigAction;
  # this is taken from http://search.cpan.org/~lbaxter/Sys-SigAction/dbd-oracle-timeout.POD
  eval {
    #note that if you ask for safe, it will not work...
    my $h = Sys::SigAction::set_sig_handler( 'ALRM',
					     sub {
					       die "timed out connecting to database on $cfg->{host}\n";
					     },
					     { flags=>0 ,safe=>0 } );
    alarm(10);
    if ($cfg->{driver} eq 'Pg') {
      require DBD::Pg;
      import DBD::Pg qw(:async);
    } elsif ($cfg->{driver} eq 'Oracle') {
      $::ENV{NLS_LANG}='CZECH_CZECH REPUBLIC.AL32UTF8';
      $::ENV{NLS_NCHAR}='AL32UTF8';
    }
    $self->{dbi} = DBI->connect('dbi:'.$cfg->{driver}.':'.
			  ($cfg->{driver} eq 'Oracle' ? "sid=" : "database=").$cfg->{database}.';'
			   ."host=".$cfg->{host}.';'
			   ."port=".$cfg->{port},
			$cfg->{username},
			$cfg->{password},
			{ RaiseError => 1,
			  (($cfg->{driver} eq 'Pg') ? (AutoCommit=>0) : ())
			}
		       );
    alarm(0);
    die "Connection failed" if not $self->{dbi};
  };
  alarm(0);
  die $@ if $@;
  return $self->{dbi};
}

sub run {
  my ($self,$opts)=@_;
  delete $self->{results};
  $opts||={};
  my $dbi  = $self->{dbi} || die "Not connected to DBI!\n";
  my $timeout = $opts->{timeout};
  my $driver_name = $self->sql_driver;
  my $t0 = new Benchmark;
  my $results = eval { $self->run_sql_query($self->{sth},{
    limit=>$opts->{limit},
    timeout => $timeout,
    timeout_callback => $opts->{timeout_callback},
    raise_error =>1,
  }) };
  if ($@) {
    my $err = $@;
    $err=~s/\n/ /g;
    if ($err =~ /^TIMEOUT /) {
      die "$self->{id}\tTIMEOUT\t".($timeout)."s\n";
    } else {
      die "$self->{id}\tFAIL\t$err\n";
    }
    return;
  }
  my $t1 = new Benchmark;
  my $time = timestr(timediff($t1,$t0));
  my $no_results = $opts->{count} ? $results->[0][0]  : scalar(@$results);
  unless ($opts->{quiet}) {
    my $driver_name = $self->sql_driver;
    print "$self->{id}\tOK\t$driver_name\t$no_results\t$time\n";
  }
  return $self->{results}=$results;
}

sub idx_to_pos {
  my ($self,$idx_list)=@_;
  my @res;
  my @list=@$idx_list;
  while (@list) {
    my ($idx,$type)=(shift@list, shift@list);
    my $result = $self->run_sql_query(qq(SELECT "file", "sent_num", "pos" FROM ${type}_pos WHERE "idx" = $idx ).$self->serialize_limit(1),
			   { MaxRows=>1, RaiseError=>1 });
    $result = $result->[0];
    push @res, $result->[0].'##'.$result->[1].'.'.$result->[2];
  }
  return @res;
}

sub run_sql_query {
  my ($self, $sql_or_sth, $opts)=@_;
  my $dbi = $self->{dbi} || die "Not connected to DBI!\n";
  local $dbi->{RaiseError} = $opts->{RaiseError};
  require Time::HiRes;
  my $canceled = 0;
  my $driver_name = $self->sql_driver;
  my $sth = ref($sql_or_sth) ? $sql_or_sth : $dbi->prepare( $sql_or_sth,
							    $driver_name eq 'Pg' ? { pg_async => 1 } : ());
  if ($driver_name eq 'Pg') {
    my $step=0.05;
    my $time=0;
    eval {
      $sth->execute();
      if (defined $opts->{timeout}) {
	while (!$sth->pg_ready) {
	  $time+=$step;
	  Time::HiRes::sleep($step);
	  if ($time>=$opts->{timeout}) {
	    if ($opts->{'timeout_callback'} and $opts->{'timeout_callback'}->($self)) {
	      $time=0;
	    } else {
	      $sth->pg_cancel();
	      die "TIMEOUT\n"
	    }
	  }
	}
      }
      $sth->pg_result;
    };
    if ($@) {
      $dbi->rollback();
      die $@;
    }
  } else {
    eval {
      if (defined $opts->{timeout}) {
	require Sys::SigAction;
	my $h = Sys::SigAction::set_sig_handler( 'ALRM',
				 sub {
				   if ($opts->{'timeout_callback'} and $opts->{'timeout_callback'}->($self)) {
				     alarm($opts->{timeout});
				   } else {
				     $canceled = 1;
				     my $res = $sth->cancel();
				     warn "Canceled: ".(defined($res) ? $res : 'undef');
				   }
				 }, #dont die (oracle spills its guts)
				 { mask=>[ qw( INT ALRM ) ] ,safe => 0 }
				);
	alarm($opts->{timeout});
	$sth->execute();
	alarm(0);
      } else {
	$sth->execute();
      }
    };
    alarm(0);
    if ( $@ ) {
      $dbi->rollback();
      if ($canceled) {
	die "TIMEOUT"
      } else {
	die $@;
      }
    }
  }
  return $sth->fetchall_arrayref(undef,$opts->{limit});
}

sub serialize_limit {
  my ($self, $limit)=@_;
  my $driver = $self->sql_driver;
  if ($driver eq 'Oracle') {
    return 'AND ROWNUM<='.$limit;
  } elsif ($driver eq 'Pg') {
    return 'LIMIT '.$limit.';';
  }
}


# serialize to SQL (or SQL fragment)
sub sql_serialize_conditions {
  my ($self,$node,$opts)=@_;
  $opts||={};
  if ($node->parent) {
    return [$self->sql_serialize_element({
      %$opts,
      name => 'and',
      condition => $node,
    })];
  } else {
    return $self->build_sql($node,{
      count=>$opts->{count},
      limit => $opts->{limit},
      syntax=>$opts->{syntax},
    });
  }
}

sub relation {
  my ($self,$id,$rel,$target,$opts)=@_;
  my $relation = $rel->name;
  my $params = $rel->value;
  if ($relation eq 'ancestor') {
    $relation = 'descendant';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'parent') {
    $relation = 'child';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'order-follows') {
    $relation = 'order-precedes';
    ($id,$target)=($target,$id);
  } elsif ($relation eq 'depth-first-follows') {
    $relation = 'depth-first-precedes';
    ($id,$target)=($target,$id);
  }
  my $cond;
  if ($relation eq 'user-defined') {
    return $self->user_defined_relation($id,$params,$target,$opts);
  } elsif ($relation eq 'descendant') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND $id."idx"!=$target."idx" AND }.
      qq{$target."idx" BETWEEN $id."idx" AND $id."r"};
    my $min = int($params->{min_length});
    my $max = int($params->{max_length});
    if ($min>0 and $max>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl" BETWEEN $min AND $max};
    } elsif ($min>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl">=$min}
    } elsif ($max>0) {
      $cond.=qq{ AND $target."lvl"-$id."lvl"<=$max}
    }
  } elsif ($relation eq 'child') {
    $cond = qq{$id."idx"=$target."parent_idx"};
  } elsif ($relation eq 'depth-first-precedes') {
    $cond = qq{$id."idx"<$target."idx"};
  } elsif ($relation eq 'order-precedes') {
    my $order; # FIXME: get the ordering attribute from the database
    if ($opts->{type} eq 'a') {
      $order = q(ord);
    } else {
      $order = q(tfa/deepord);
    }
    $cond =
      $self->sql_serialize_predicate(
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  expression => qq{\$$id.$order},
	},
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  expression => qq{\$$target.$order},
	},
	'<',$opts # there should be no ambiguity here, treat expressoins as positive
       );
  } else {
    die "Unsupported relation: $relation between nodes $id and $target\n";
  }
  return $cond;
}

sub user_defined_relation {
  my ($self,$id,$params,$target,$opts)=@_;
  my $relation=$params->{label};
  my $type = $opts->{type};
  my $cond;
  my $from_id = $opts->{id}; # view point
  if ($relation eq 'eparent') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND }.
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.eparents/eparent_idx},
	  negative=> $opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'echild') {
    $cond = qq{$id."root_idx"=$target."root_idx" AND }.
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$target.eparents/eparent_idx},
	  negative=>$opts->{negative},
	},
	qq{$id."idx"},
	q(=),$opts,
       )
  } elsif ($relation eq 'a/lex.rf') {
    $cond =  qq{$id."a_lex_idx"=$target."idx"}
  } elsif ($relation eq 'a/aux.rf') {
    $cond = $self->sql_serialize_predicate(
      {
	id=>$from_id,
	type=>$type,
	join=>$opts->{join},
	expression => qq{\$$id.a_aux/a_idx},
	negative=>$opts->{negative},
      },
      qq{$target."idx"},
      qq(=),$opts,
     )
  } elsif ($relation eq 'a/lex.rf|a/aux.rf') {
    $cond =
      qq{($id."a_lex_idx"=$target."idx" OR }.
	$self->sql_serialize_predicate(
	  {
	    id=>$from_id,
	    type=>$type,
	    join=>$opts->{join},
	    expression => qq{\$$id.a_aux/a_idx},
	    negative=>$opts->{negative},
	  },
	  qq{$target."idx"},
	  qq(=),$opts,
	 ).')';
  } elsif ($relation eq 'coref_gram') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_gram/corg_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'coref_text') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_text/cort_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'compl') {
    $cond = 
      $self->sql_serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.compl/compl_idx},
	  negative=>$opts->{negative},
	},
	qq{$target."idx"},
	q(=),$opts,
       );
  }
  return $cond;
}

sub build_sql {
  my ($self,$tree,$opts)=@_;
  $opts||={};
  my ($format,$count,$tree_parent_id) = map {$opts->{$_}} qw(format count parent_id limit);
  # we rely on depth first order!
  my @nodes = Tree_Query::FilterQueryNodes($tree);
  my @select;
  my @table;
  my @where;
  my %conditions;
  my $extra_joins = $opts->{join} || {};
  my $default_type = $opts->{type}||$tree->root->{'node-type'}||'a';
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $table = $n->{'node-type'}||$default_type;
    my $id = $self->{id_map}{$n};

    push @select, $id;
    my $parent = $n->parent;
    while ($parent and $parent->{'#name'} !~/^(?:node|subquery)$/) {
      $parent=$parent->parent
    }
    my $parent_id = $self->{id_map}{$parent};
    $conditions{$id} = Tree_Query::as_text($n);
    my @conditions;
    if ($parent && $parent->parent) {
      my ($rel) = SeqV($n->{relation});
      $rel ||= Tree_Query::SetRelation($n,'child');
      push @conditions,
	[$self->relation($parent_id,$rel,$id, {
	  %$opts,
	  id=>$id,
	  join => $extra_joins,
	  type=>($parent->{'node-type'}||$default_type)
	 }),$n];
      push @table,[$table,$id,$n];
    } else {
      push @table,[$table,$id,$n];
    }
    push @conditions,
      (map {
	[qq{$self->{id_map}{$_}."idx"}.
	   ($conditions{$id} eq $conditions{$self->{id_map}{$_}} ? '<' : '!=' ).
	     qq{${id}."idx"},$n] }
	 grep { #$_->parent == $n->parent
	   #  or
	   my $type=$_->{'node-type'}||$default_type;
	   $type eq $table and
	     (first { !$_->{optional} } $_->ancestors)==(first { !$_->{optional} } $n->ancestors)
	   }
	   map { $nodes[$_] } 0..($i-1));
    {
      my $conditions = $self->sql_serialize_conditions($n,{
	type=>$table,
	id=>$id,
	parent_id=>$parent_id,
	join => $extra_joins,
	syntax=>$opts->{syntax},
      });
      push @conditions, [$conditions,$n] if @$conditions;
    }
    # where could also be obtained by replacing ___SELF___ with $id
    if ($n->{optional}) {
      # identify with parent
      if (@conditions) {
	@conditions = ( [ [['(('], @{Tree_Query::_group(\@conditions,[' AND '])}, [qq{) OR $id."idx"=$parent_id."idx")}]], $n] );
      }
    }
    push @where, @conditions;
  }

  my @sql = (['SELECT ']);
  if ($count == 2) {
    push @sql,['count(DISTINCT '.$self->{id_map}{$tree}.'."idx")','space'];
  } elsif ($count) {
    push @sql,['count(1)','space'];
  } else {
    push @sql, (['DISTINCT '], map {
      my $n = $nodes[$_];
      (($_==0 ? () : [', ','space']),
       [$select[$_].'."idx"',$n],
       [' AS "'.$select[$_].'.idx"',$n],
       [q(, ').($nodes[$_]->{'node-type'}||$default_type).q('),$n],
       [' AS "'.$select[$_].'.type"',$n]
      )
    } 0..$#nodes);
  }
  # joins
  {
    my $i=0;
    for my $t (@table) {
      my ($tab, $name, $node)=@$t;
      push @sql, ($i++)==0 ? ["\nFROM\n  ",'space'] : [",\n  ",'space'];
      push @sql, ["$tab $name",$node];
      if ($extra_joins->{$name}) {
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  push @sql, [' ','space'], [qq($join_type JOIN $join_tab $join_as ON $join_on),$node]
	}
      }
    }
  }
  push @sql, [ "\nWHERE\n     ",'space'],@{Tree_Query::_group(\@where,[' AND '])};

  unless (defined($tree_parent_id) and defined($self->{id_map}{$tree}) 
	  or !defined($opts->{limit})) {
    push @sql, ["\n".$self->serialize_limit($opts->{limit})."\n",'space']
  }

  if ($format) {
    return Tree_Query::make_string_with_tags(\@sql,[$tree]);
  } else {
    return Tree_Query::make_string(\@sql);
  }
}

sub sql_serialize_expression_pt {# pt stands for parse tree
  my ($self,$pt,$opts,$extra_joins)=@_;
  my $this_node_id = $opts->{id};
  if (ref($pt)) {
    my $type = shift @$pt;
    if ($type eq 'ATTR' or $type eq 'REF_ATTR') {
      my ($id,$attr,$cmp);
      if ($type eq 'REF_ATTR') {
	$id = lc($pt->[0]);
	$pt=$pt->[1];
	die "Error in attribute reference of node $id in expression $opts->{expression} of node '$this_node_id'" 
	  unless shift(@$pt) eq 'ATTR'; # not likely
	$cmp = $self->cmp_subquery_scope($this_node_id,$id);
	if ($cmp<0) {
	  die "Node '$id' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
	}
      } else {
	$id=$this_node_id;
      }
      my $column = pop @$pt;
      my $table = $opts->{type};
      my $node_id = $id;
      for my $tab (@$pt) {
	next if $tab =~ /^[mw]$/;  # FIXME: hack
	my $prev = $id;
	my $j;
	if ($opts->{negative} or $cmp) {
	  $opts->{use_exists}=1;
	  $j=$extra_joins;
	} else {
	  $j=$opts->{join};
	}
	$j->{$node_id}||=[];
	my $i = @{$j->{$node_id}};
	$id.="_${tab}_$i";
	$table.="_$tab";
	push @{$j->{$node_id}},[$id,$table, qq($id."idx" = $prev."idx"), 'LEFT']; # should be qq($prev."$tab")
      }
      return qq( $id."$column" );
    } elsif ($type eq 'FUNC') {
      my $name = $pt->[0];
      my $args = $pt->[1];
      my $id;
      if ($name=~/^(?:descendants|lbrothers|rbrothers|sons|depth)$/) {
	if ($args and @$args==1 and !ref($args->[0]) and $args->[0]=~s/^\$//) {
	  $id = $args->[0];
	  if ($self->cmp_subquery_scope($this_node_id,$id)<0) {
	    die "Node '$id' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
	  }
	} elsif ($args and @$args) {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(\$node?)\n";
	} else {
	  $id=$this_node_id;
	}
	return ($name eq 'descendants') ? qq{$id."r"-$id."idx"}
	     : ($name eq 'lbrothers')   ? qq{$id."chord"}
	     : ($name eq 'rbrothers')   ? qq{$opts->{parent_id}."chld"-$id."chord"-1}
             : ($name eq 'sons')        ? qq{$id."chld"}
             : ($name eq 'depth')       ? qq{$id."lvl"}
             : die "Tree_Query internal error while compiling expression: should never get here!";
      } elsif ($name=~/^(?:lower|upper|length)$/) {
	if ($args and @$args==1) {
	  return uc($name).'('
	         .  $self->sql_serialize_expression_pt($args->[0],$opts,$extra_joins)
	         . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	}
      } elsif ($name eq 'substr') {
	if ($args and @$args>1 and @$args<4) {
	  my @args = map { $self->sql_serialize_expression_pt($_,$opts,$extra_joins) } @$args;
	  $args[1].='+1';
	  return 'SUBSTR('
	         .  join(',', @args)
	         . ')';
	} else {
	  die "Wrong arguments for function substr() in expression $opts->{expression} of node '$this_node_id'!\nUsage: substr(string,from,length?)\n";
	}
      }
    } elsif ($type eq 'EXP') {
      my $out.='(';
      while (@$pt) {
	$out.=$self->sql_serialize_expression_pt(shift @$pt,$opts,$extra_joins);
	if (@$pt) { # op
	  my $op = shift @$pt;
	  if ($op eq 'div') {
	    $op='/'
	  } elsif ($op eq 'mod') {
	    $op='%'
	  } elsif ($op eq '&') {
	    $op='||'
	  } elsif ($op !~ /[-+*]/) {
	    die "Urecognized operator '$op' in expression $opts->{expression} of node '$this_node_id'\n";
	  }
	  $out.=$op;
	}
      }
      $out.=')';
      return $out;
    }
  } else {
    if ($pt=~/^[-0-9']/) { # literal
      return qq( $pt );
    } elsif ($pt=~s/\$//) { # a plain variable
      if ($self->cmp_subquery_scope($this_node_id,$pt)<0) {
	die "Node '$pt' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
      }
      return qq( $pt."idx" );
    } else { # unrecognized token
      die "Token '$pt' not recognized in expression $opts->{expression} of node '$this_node_id'\n";
    }
  }
}

sub sql_serialize_expression {
  my ($self,$opts)=@_;

  my $pt = Tree_Query::parse_expression($opts->{expression}); # $pt stands for parse tree
  die "Invalid expression '$opts->{expression}' on node '$opts->{id}'" unless defined $pt;

  my $extra_joins={};
  my $out = $self->sql_serialize_expression_pt($pt,$opts,$extra_joins); # do not copy $opts here!

  my $wrap;
  if ($opts->{use_exists}) {
    my @from;
    my @where;
    for my $name (keys (%$extra_joins)) {
      if ($extra_joins->{$name}) {
	my $table;
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  if (defined $table) {
	    $table.=qq( $join_type JOIN $join_tab $join_as ON $join_on);
	  } else {
	    $table=qq($join_tab $join_as);
	    push @where, $join_on;
	  }
	}
	push @from,$table;
      }
    }
    if (@from) {
      $wrap='EXISTS (SELECT *'
	.' FROM '.join(', ',@from)
	.' WHERE '.join(' AND ',@where);
      $wrap=~s/%/%%/g;
      $wrap.=' AND ' if @where;
      $wrap.='%s )';
    }
  }
  return ($out,$wrap);
}

sub sql_serialize_predicate {
  my ($self,$L,$R,$operator,$opts)=@_;
  my ($left,$wrap_left) = ref($L) ? $self->sql_serialize_expression($L) : ($L);
  my ($right,$wrap_right) = ref($R) ? $self->sql_serialize_expression($R) : ($R);
  my $res;
  if ($operator eq '~' and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right)};
  } elsif ($operator eq '~*' and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right,'i')};
  } else {
    $res = $left.' '.uc($operator).' '.$right;
  }
  if (defined $wrap_right) {
    $res=sprintf($wrap_right,$res);
  }
  if (defined $wrap_left) {
    $res=sprintf($wrap_left,$res);
  }
  return $res;
}

sub sql_serialize_element {
  my ($self,$opts)=@_;
  my ($name,$node,$as_id,$parent_as_id)=map {$opts->{$_}} qw(name condition id parent_id);
  my $negative = $opts->{negative};
  $negative=!$negative if $name eq 'not';
  if ($name eq 'test') {
    return
      [$self->sql_serialize_predicate({%$opts,expression=>$node->{a},negative=>$negative},
				      {%$opts,expression=>$node->{b},negative=>$negative},
				      $node->{operator},
				      $opts),$node];
  } elsif ($name =~ /^(?:and|or|not)$/) {
    my @c =
      grep { @$_ }
      map {
	my $n = $_->{'#name'};
	$self->sql_serialize_element({
	  %$opts,
	  name => $n,
	  condition => $_,
	  id => $as_id,
	  parent_id => $parent_as_id,
	  negative=>$negative
	 })
      } grep { $_->{'#name'} ne 'node' } $node->children;
   return unless @c;
   return
     $name eq 'not' ? [[['NOT('],@{Tree_Query::_group(\@c,[' AND '])},[')']],$node] :
     $name eq 'and' ? [[['('],@{Tree_Query::_group(\@c,[' AND '])},[')']],$node] :
     $name eq 'or' ? [[['('],@{Tree_Query::_group(\@c,[' OR '])},[')']],$node] : ();
  } elsif ($name eq 'subquery') {
    my $subquery = $self->build_sql($node,{
      format => 1,
      count=>2,
      parent_id=>$opts->{id},
      join => $opts->{join},
      syntax=>$opts->{syntax},
    });
    my @sql;
    my @occ;
    my @vals = grep ref, AltV($node->{occurrences});
    @vals=(Fslib::Struct->new({min=>1})) unless @vals;
    for my $occ (@vals) { # this is not optimal for @occ>1
      my ($min,$max)=($occ->{min},$occ->{max});
      if (length($min) and length($max)) {
	if ($min==$max) {
	  push @occ,[[['('],@$subquery,[qq')=$min']],$node];
	} else {
	  push @occ,[[['('],@$subquery,[qq') BETWEEN $min AND $max']],$node];
	}
      } elsif (length($min)) {
	push @occ,[[['('],@$subquery,[qq')>=$min']],$node];
      } elsif (length($max)) {
	push @occ,[[['('],@$subquery,[qq')<=$max']],$node];
      }
    }
    return (@occ ? [[ ['('],@{Tree_Query::_group(\@occ,[' OR '])},[')'] ],$node] : ());
  } elsif ($name eq 'ref') {
    my $target = $node->{target};
    if ($self->cmp_subquery_scope($node,$target)<0) {
      die "Node '$as_id' belongs to a sub-query and cannot be referred from the scope of node '$target'\n";
    }
    my ($rel) = SeqV($node->{relation});
    if ($rel) {
      return ['('.$self->relation($as_id,$rel,$target,$opts).')',$node];
    } else {
      return;
    }
  } else {
    Carp::cluck "Unknown element $name ";
    return;
  }
}

sub cmp_subquery_scope {
  my ($self,$src,$target)=@_;
  $_ = ref($_) ? $_ : $self->{name2node}{$_} || croak("didn't find node $_")
    for $src,$target;
  return Tree_Query::cmp_subquery_scope($src,$target);
}

}

#### TrEd interface to Tree_Query::Evaluator
{

package Tree_Query::SQLSearch;
use Benchmark;
use Carp;
use strict;
use warnings;
use Scalar::Util qw(weaken);
BEGIN { import TredMacro  }

our %DEFAULTS = (
  limit => 100,
  timeout => 30,
);

$Tree_Query::SQLSearchPreserve::object_id=0; # different NS so that TrEd's reload-macros doesn't clear it

sub new {
  my ($class,$opts)=@_;
  $opts||={};
  my $self = bless {
    object_id =>  $Tree_Query::SQLSearchPreserve::object_id++,
    evaluator => undef,
    config => {
      pml => $opts->{config_pml},
    },
    query_nodes => undef,
    results => undef,
  }, $class;
  $self->init($opts->{config_file},$opts->{config_id}) || return;
  $self->{callback} = [\&open_pmltq,$self];
  weaken($self->{callback}[1]);
  register_open_file_hook($self->{callback});
  my $ident = $self->identify;
  (undef, $self->{label}) = Tree_Query::CreateSearchToolbar($ident);
  $self->{on_destroy} = MacroCallback(sub {
					DestroyUserToolbar($ident);
					ChangingFile(0);
				      });
  return $self;
}

sub DESTROY {
  my ($self)=@_;
  warn "DESTROING $self\n";
  RunCallback($self->{on_destroy}) if $self->{on_destroy};
  unregister_open_file_hook($self->{callback});
}

sub identify {
  my ($self)=@_;
  return "SQLSearch" unless $self->{config}{data};
  my $cfg = $self->{config}{data};
  return "SQLSearch $cfg->{driver}:$cfg->{username}\@$cfg->{host}:$cfg->{port}/$cfg->{database}";
}

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  my $query = $opts->{query} || $root;
  unless ($self->{evaluator}) {
    $self->{evaluator} = Tree_Query::SQLEvaluator->new($query,{connect => $self->{config}{data}});
  CONNECT: {
      eval {
	$self->{evaluator}->connect;
      };
      if ($@) {
	ErrorMessage($@);
	if ($@ =~ /timed out/) {
	  return;
	}
	GUI() && EditAttribute($self->{config}{data},'',$self->{config}{type},'password') || return;
	$self->{config}{pml}->save();
	redo CONNECT;
      }
    }
  } else {
    $self->{evaluator}->prepare_query($query);
  }
  if (GUI() and $opts->{edit_sql}) {
    my $sql = EditBoxQuery(
      "SQL Query",
      $self->{evaluator}->get_sql,
      qq{Confirm or Edit the generated SQL Query},
     );
    return unless defined($sql) and length($sql);
    $self->{evaluator}->prepare_sql($sql);
  }
  $self->{last_query_nodes} = $self->{evaluator}->get_query_nodes;
  my ($limit, $timeout) = map { int($opts->{$_}||$self->{config}{pml}->get_root->get_member($_))||$DEFAULTS{$_} }
    qw(limit timeout);
  my $results = $self->{evaluator}->run({
    limit => $limit,
    timeout => $timeout,
    timeout_callback => sub {
      (!GUI() or
	 QuestionQuery('Query Timeout',
			 'The evaluation of the query seems to take too long',
		       'Wait another '.$timeout.' seconds','Abort') eq 'Abort') ? 0 : 1
		     },
  });
  $self->{results} = $results;
  my $matches = @$results;
  if ($matches) {
    return $results unless QuestionQuery('Results',
					 ((defined($limit) and $matches==$limit) ? '>=' : '').
					   $matches.' match'.($matches>1?'(es)':''),
					 'Display','Cancel') eq 'Display';
    my @wins = TrEdWindows();
    my $res_win;
    my $fn = $self->filelist_name;
    if (@wins>1) {
      ($res_win) = grep { 
	my $f = GetCurrentFileList($_);
	($f and $f->name eq $fn)
      } @wins;
      unless ($res_win) {
	($res_win) = grep { $_ ne $grp } @wins;
      }
    } else {
      $res_win = SplitWindowVertically();
    }
    {
      my $fl = Filelist->new($fn);
      my @files = map {
	'pmltq://'.join('/',$self->{object_id},@$_)
      } @$results;
      $fl->add(0, @files);
      my @context=($this,$root,$grp);
      CloseFileInWindow($res_win);
      $grp=$res_win;
      SetCurrentStylesheet(STYLESHEET_FROM_FILE);
      AddNewFileList($fl);
      SetCurrentFileList($fl->name);
      GotoFileNo(0);
      ($this,$root,$grp)=@context;
      ${$self->{label}} = (CurrentFileNo($res_win)+1).' of '.(LastFileNo($res_win)+1).
	($limit == $matches ? '+' : '');
      select_matching_node($this);
    }
  } else {
    QuestionQuery('Results','No results','OK');
  }
  return $results;
}

sub show_next_result {
  my ($self)=@_;
  return $self->show_result('next');
}

sub show_prev_result {
  my ($self)=@_;
  return $self->show_result('prev');
}

sub show_current_result {
  my ($self)=@_;
  return $self->show_result('current');
}

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my @matching;
  my $fn = $filename.'##'.($tree_number+1);
  my $source_dir = $self->get_source_dir;
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () }
    map { $source_dir.'/'.$_ } @{$self->{current_result}};
  return @nodes[@positions];
}

sub select_matching_node {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  my $idx = Index($self->{last_query_nodes},$query_node);
  return if !defined($idx);
  my $result = $self->{current_result}->[$idx];
  my $source_dir = $self->get_source_dir;
  $result = $source_dir.'/'.$result;
  foreach my $win (TrEdWindows()) {
    my $fsfile = $win->{FSFile};
    next unless $fsfile;
    my $fn = $fsfile->filename.'##'.($win->{treeNo}+1);
    next unless $result =~ /\Q$fn\E\.(\d+)$/;
    my $pos = $1;
    my $r=$fsfile->tree($win->{treeNo});
    for (1..$pos) {
      $r=$r->following();
    }
    if ($r) {
      SetCurrentNodeInOtherWin($win,$r);
      CenterOtherWinTo($win,$r);
    }
  }
  return;
}

sub configure {
  my ($self)=@_;
  my $config = $self->{config}{pml};
  GUI() && EditAttribute($config->get_root,'',
			 $config->get_schema->get_root_decl->get_content_decl) || return;
  $config->save();
}

#########################################
#### Private API

sub init {
  my ($self,$config_file,$id)=@_;
  $self->load_config_file($config_file) || return;
  my $configuration = $self->{config}{data};
  my $cfgs = $self->{config}{pml}->get_root->{configurations};
  my $cfg_type = $self->{config}{type};
  if (!$id) {
    my @opts = ((map { $_->{id} } ListV($cfgs)),' CREATE NEW ');
    my @sel= $configuration ? $configuration->{id} : @opts ? $opts[0] : ();
    ListQuery('Select treebase connection',
			 'browse',
			 \@opts,
			 \@sel) || return;
    ($id) = @sel;
  }
  return unless $id;
  my $cfg;
  if ($id eq ' CREATE NEW ') {
    $cfg = Fslib::Struct->new();
    GUI() && EditAttribute($cfg,'',$cfg_type) || return;
    $cfgs->append($cfg);
    $self->{config}{pml}->save();
    $id = $cfg->{id};
  } else {
    $cfg = first { $_->{id} eq $id } ListV($cfgs);
    die "Didn't find configuration '$id'" unless $cfg;
  }
  $self->{config}{id} = $id;
  unless (defined($cfg->{username}) and defined($cfg->{password})) {
    if (GUI()) {
       EditAttribute($cfg,'',$cfg_type,'password') || return;
    } else {
      die "The configuration $id does not specify username or password\n";
    }
    $self->{config}{pml}->save();
  }
  $self->{config}{data} = $cfg;
}


sub filelist_name {
  my $self=shift;
  return ref($self).":".$self->{object_id};
}

sub show_result {
  my ($self,$dir)=@_;
  return unless $self->{evaluator};
  my $prev_grp = $grp;
  my @save = ($this,$root,$grp);
  my $fn = $self->filelist_name;
  for my $win (TrEdWindows()) {
    my $fl = GetCurrentFileList($win);
    if ($fl and $fl->name eq $fn) {
      eval {
	if ($dir eq 'prev') {
	  $grp=$win;
	  PrevFile();
	} elsif ($dir eq 'next') {
	  $grp=$win;
	  NextFile()
	} elsif ($dir eq 'current') {
	  return unless $self->{current_result};
	  my $idx = Index($self->{last_query_nodes},$this);
	  if (defined($idx)) {
	    $grp=$win;
	    my $source_dir = $self->get_source_dir;
	    Open($source_dir.'/'.$self->{current_result}[$idx]);
	    Redraw($win);
	  }
	}
      };
      my $plus = ${$self->{label}}=~/\+/;
      ${$self->{label}} = (CurrentFileNo($win)+1).' of '.(LastFileNo($win)+1).
	($plus ? '+' : '');
      ($this,$root,$grp)=@save;
      $self->select_matching_node($this);
      die $@ if $@;
      return;
    }
  }
  return;
}

sub update_label {
  my ($self)=@_;
  my $past = (($self->{past_results} ? int(@{$self->{past_results}}) : 0)
		+ ($self->{current_result} ? 1 : 0));
  ${$self->{label}} = $past.' of '.
	 ($self->{next_results} ? $past+int(@{$self->{next_results}}) : $past).'+';
}

# registered open_file_hook
# called by Open to translate URLs of the
# form pmltq//table/idx/table/idx ....  to a list of file positions
# and opens the first of the them
sub open_pmltq {
  my ($self,$filename,$opts)=@_;
  my $object_id=$self->{object_id};
  return unless $filename=~s{pmltq://$object_id/}{};
  my @positions = $self->{evaluator}->idx_to_pos([split m{/}, $filename]);
  $self->{current_result}=\@positions;
  my ($node) = map { CurrentNodeInOtherWindow($_) }
              grep { CurrentContextForWindow($_) eq __PACKAGE__ } TrEdWindows();
  my $idx = Index($self->{last_query_nodes},$node);
  my $first = $positions[$idx||0];
  print "$first\n";
  if (defined $first and length $first) {
    my $source_dir = $self->get_source_dir;
    $opts->{-norecent}=1;
    my $fsfile = Open($source_dir.'/'.$first,$opts);
    if (ref $fsfile) {
      $fsfile->changeAppData('tree_query_url',$filename);
      $fsfile->changeAppData('norecent',1);
      for my $req_fs (GetSecondaryFiles($fsfile)) {
	$req_fs->changeAppData('norecent',1);
      }
    }
    Redraw();
  }
  return 'stop';
}

sub get_source_dir {
  my ($self)=@_;
  my $conf = $self->{config}{data};
  my $source_dir = $conf->{sources};
  unless ($source_dir) {
    if (GUI()) {
      EditAttribute($conf,'sources',
		    $self->{config}{type},
		   ) || return;
      $self->{config}{pml}->save();
      $source_dir = $conf->{sources};
    }
  }
  return $source_dir;
}

sub load_config_file {
  my ($self,$config_file)=@_;
  if (!$self->{config}{pml} or ($config_file and
				$config_file ne $self->{config}{pml}->filename)) {
    if ($config_file) {
      die "Configuration file '$config_file' does not exist!" unless -f $config_file;
      $self->{config}{pml} = PMLInstance->load({ filename=>$config_file });
    } else {
      $config_file ||= FindInResources('treebase.conf');
      if (-f $config_file) {
	$self->{config}{pml} = PMLInstance->load({ filename=>$config_file });
      } else {
	my $tred_d = File::Spec->catfile($ENV{HOME},'.tred.d');
	mkdir $tred_d unless -d $tred_d;
	$config_file = File::Spec->catfile($tred_d,'treebase.conf');
	$self->{config}{pml} = PMLInstance->load({ string => $DEFAULTS{dbi_config},
					      filename=> $config_file});
	$self->{config}{pml}->save();
      }
    }
  }
  $self->{config}{type} = $self->{config}{pml}->get_schema->get_type_by_name('dbi-config.type')->get_content_decl;
  return $self->{config}{pml};
}

sub get_results {
  my $self = shift;
  return $self->{results} || [];
}

sub get_query_nodes {
  my $self = shift;
  return $self->{query_nodes};
}


my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
$DEFAULTS{dbi_config} = <<"EOF";
<dbi xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema>
      <pml_schema 
	  xmlns="http://ufal.mff.cuni.cz/pdt/pml/schema/" version="1.1">
        <revision>1.1</revision>
	<root name="dbi">
	  <structure>
	    <member name="limit"><cdata format="nonNegativeInteger"/></member>
	    <member name="timeout"><cdata format="nonNegativeInteger"/></member>
	    <member name="configurations">
	      <list ordered="1" type="dbi-config.type"/>
	    </member>
	  </structure>
	</root>
	<type name="dbi-config.type">
	  <structure>
	    <member name="id" role="#ID" required="1" as_attribute="1"><cdata format="ID"/></member>
	    <member name="driver"><cdata format="NMTOKEN"/></member>
	    <member name="host"><cdata format="url"/></member>
	    <member name="port"><cdata format="integer"/></member>
	    <member name="database"><cdata format="NMTOKEN"/></member>
	    <member name="username"><cdata format="NMTOKEN"/></member>
	    <member name="password"><cdata format="any"/></member>
	    <member name="sources"><cdata format="anyURI"/></member>
	  </structure>
	</type>
      </pml_schema>
    </schema>
  </head>
  <limit>$DEFAULTS{limit}</limit>
  <timeout>$DEFAULTS{timeout}</timeout>
  <configurations>
    <LM id="postgress">
      <driver>Pg</driver>
      <host>localhost</host>
      <port>5432</port>
      <database>treebase</database>
      <username>$userlogin</username>
      <password></password>
    </LM>
    <LM id="oracle">
      <driver>Oracle</driver>
      <host>localhost</host>
      <port>1521</port>
      <database>XE</database>
      <username></username>
      <password></password>
    </LM>
  </configurations>
</dbi>
EOF

} # SQL
