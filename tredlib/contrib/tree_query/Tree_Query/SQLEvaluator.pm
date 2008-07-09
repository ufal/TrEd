package Tree_Query::SQLEvaluator;

our $SEPARATE_TREES=0;

# pajas@ufal.ms.mff.cuni.cz          01 èec 2008
use Benchmark;
use Carp;
use strict;
use warnings;
use PMLSchema;

use Tree_Query::Common;
BEGIN { import Tree_Query::Common ':tredmacro' };

our $VERSION = '0.01';

# BEGIN { import TredMacro qw(first SeqV AltV ListV) }

sub new {
  my ($class,$query_tree,$opts)=@_;
  my $self = bless {
    dbi => $opts->{dbi},
    connect => $opts->{connect},
    debug => $opts->{debug},
    results => undef,
    query_nodes=>undef,
    type_decls => {},
    schema_types => {},
    schemas => {},
    returns_nodes => 1,
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
    $query_tree = Tree_Query::Common::parse_query($query_tree);
  }
  $self->{id} = $query_tree->{id} || 'no_ID';
  $self->{query_nodes} = [Tree_Query::Common::FilterQueryNodes($query_tree)];
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
  $self->{sql}=undef;
  $self->prepare_sql($self->serialize_conditions($query_tree,
						     { %$opts,
						       syntax=>$self->sql_driver,
						       node_limit=>$opts->{node_limit},
						       row_limit=>$opts->{row_limit},
						       returns_nodes=>\$self->{returns_nodes},
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
      $::ENV{NLS_LANG}='AMERICAN_AMERICA.AL32UTF8';
      $::ENV{NLS_NCHAR}='AL32UTF8';
    }
    my $string = 'dbi:'.$cfg->{driver}.':'
			 .($cfg->{driver} eq 'Oracle' ? "sid=" : "database=").$cfg->{database}.';'
			 .($cfg->{driver} eq 'DB2' ? 'hostname=' : 'host=').$cfg->{host}.';'
			   ."port=".$cfg->{port};
    print STDERR "$string\n" if $self->{debug};
    $self->{dbi} = DBI->connect($string,
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
    limit=>$self->{returns_nodes} ? $opts->{node_limit} : $opts->{row_limit},
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
    print STDERR "$self->{id}\tOK\t$driver_name\t$no_results\t$time\n" if $self->{debug};
  }
  return $self->{results}=$results;
}

sub idx_to_pos {
  my ($self,$idx_list)=@_;
  my @res;
  my @list=@$idx_list;
  while (@list) {
    my ($idx,$type)=(shift @list, shift @list);
    my $basename = $self->get_schema_name_for($type);
    my $node_tab = $self->get_node_table_for($type);
    my $sql=<<"EOF".$self->serialize_limit(1);
SELECT "f"."file", "f"."tree_no", "n"."#idx"-"n"."#root_idx"
FROM "${node_tab}" "n" JOIN "${basename}__#files" "f" ON "n"."#root_idx"="f"."#idx"
WHERE "n"."#idx" = ${idx}
EOF
    print "$sql\n";
    my $result = $self->run_sql_query($sql,{ MaxRows=>1, RaiseError=>1 });
    $result = $result->[0];
    my ($fn,$tn,$nn) = @$result;
    $fn=~s{/net/projects/pdt/pdt20/data/}{}; # FIXME
    push @res, $fn.'##'.($tn+1).'.'.$nn;
  }
  return @res;
}

sub run_sql_query {
  my ($self, $sql_or_sth, $opts)=@_;
  my $dbi = $self->{dbi} || die "Not connected to DBI!\n";
  local $dbi->{RaiseError} = $opts->{RaiseError};
  local $dbi->{LongReadLen} = $opts->{LongReadLen} if exists($opts->{LongReadLen});
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
sub serialize_conditions {
  my ($self,$node,$opts)=@_;
  $opts||={};
  if ($node->parent) {
    return [$self->serialize_element({
      %$opts,
      name => 'and',
      condition => $node,
      is_positive_conjunct => 1,
    })];
  } else {
    return $self->build_sql($node,{
      returns_nodes=>$opts->{returns_nodes},
      count=>$opts->{count},
      node_limit => $opts->{node_limit},
      row_limit => $opts->{row_limit},
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
    $cond = qq{"$id"."#root_idx"="$target"."#root_idx" AND "$id"."#idx"!="$target"."#idx" AND }.
      qq{"$target"."#idx" BETWEEN "$id"."#idx" AND "$id"."#r"};
    my $min = $params->{min_length}||0;
    my $max = $params->{max_length}||0;
    if ($min>0 and $max>0) {
      $cond.=qq{ AND "$target"."#lvl"-"$id"."#lvl" BETWEEN $min AND $max};
    } elsif ($min>0) {
      $cond.=qq{ AND "$target"."#lvl"-"$id"."#lvl">=$min}
    } elsif ($max>0) {
      $cond.=qq{ AND "$target"."#lvl"-"$id"."#lvl"<=$max}
    }
  } elsif ($relation eq 'child') {
    $cond = qq{"$id"."#idx"="$target"."#parent_idx"};
  } elsif ($relation eq 'depth-first-precedes') {
    $cond = qq{"$id"."#idx"<"$target"."#idx"};
  } elsif ($relation eq 'order-precedes') {
    my $decl = $self->get_decl_for($opts->{type});
    if ($decl->get_decl_type == PML_ELEMENT_DECL) {
      $decl = $decl->get_content_decl;
    }
    my ($order) = map { $_->get_name } $decl->find_members_by_role('#ORDER');
    if ($order) {
      $cond =
	$self->serialize_predicate(
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	  expression => qq{\$$id.$order},
	},
	{
	  id=>$opts->{id},
	  type=>$opts->{type},
	  join=>$opts->{join},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	  expression => qq{\$$target.$order},
	},
	'<',$opts # there should be no ambiguity here, treat expressoins as positive
	 );
    } else {
      die "Node-type $opts->{type} has no ordering attribute; use depth-first-precedes instead!\n";
    }
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
  my $join=$opts->{join};
  my $from_id = $opts->{id}; # view point
  if ($relation eq 'eparent') {
    ($id,$target)=($target,$id);
    $relation='echild';
  }
  if ($relation eq 'echild') {
    my $table = $self->get_schema_name_for($type).'__#eparents';
    if ($opts->{is_positive_conjunct}) {
      my $J = ($join->{$target}||=[]);
      my $i = @$J;
      my $eid=$target."/e-$i";
      push @$J,[$eid,$table, qq("$eid"."#idx" = "$target"."#idx")];
      $cond = qq{"$eid"."eparent"="$id"."#idx"};
    } else {
      $cond=qq{ EXISTS (SELECT * FROM "$table" e WHERE e."#idx" = "$target"."#idx" AND e."eparent"="$id"."#idx") };
      # $cond=qq{ "$id"."#idx" IN (SELECT e."eparent" FROM "$table" e WHERE e."#idx" = "$target"."#idx") }; equivalent
    }
  } elsif ($relation eq 'a/lex.rf') {
#    $cond =  qq{"$id"."a_lex_idx"="$target"."#idx"}
    $cond =
      $self->serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	  expression => $type eq 't-root' ? qq{\$$id.atree} : qq{\$$id.a/lex},
	},
	qq{"$target"."#idx"},
	'=',$opts
       );
  } elsif ($relation eq 'a/aux.rf') {
    $cond = $self->serialize_predicate(
      {
	id=>$from_id,
	type=>$type,
	join=>$opts->{join},
	expression => qq{\$$id.a/aux.rf},
	is_positive_conjunct=>$opts->{is_positive_conjunct},
      },
      qq{"$target"."#idx"},
      qq(=),$opts,
     )
  } elsif ($relation eq 'a/lex.rf|a/aux.rf') {
    my $table = $self->get_schema_name_for($type).'__#a_rf';
    if ($opts->{is_positive_conjunct}) {
      my $J = ($join->{$id}||=[]);
      my $i = @$J;
      my $eid=$id."/al-$i";
      push @$J,[$eid,$table, qq("$eid"."#idx" = "$id"."#idx")];
      $cond = qq{"$eid"."#value"="$target"."#idx"};
    } else {
      $cond=qq{ EXISTS (SELECT * FROM "$table" al WHERE al."#idx" = "$id"."#idx" AND al."#value"="$target"."#idx") };
      # $cond=qq{ "$id"."#idx" IN (SELECT e."eparent" FROM "$table" e WHERE e."#idx" = "$target"."#idx") }; equivalent
    }

#     $cond =
#       '('.$self->serialize_predicate(
# 	{
# 	  id=>$opts->{id},
# 	  type=>$type,
# 	  join=>$opts->{join},
# 	  is_positive_conjunct=>$opts->{is_positive_conjunct},
# 	  expression => qq{\$$id.a/lex},
# 	},
# 	qq{"$target"."#idx"},
# 	'=',$opts
#        ). qq{ OR }. $self->serialize_predicate(
# 	 {
# 	   id=>$from_id,
# 	   type=>$type,
# 	   join=>$opts->{join},
# 	   expression => qq{\$$id.a/aux.rf},
# 	   is_positive_conjunct=>$opts->{is_positive_conjunct},
# 	 },
# 	 qq{"$target"."#idx"},
# 	 qq(=),$opts,
# 	).')';
  } elsif ($relation eq 'coref_gram') {
    $cond = 
      $self->serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_gram.rf},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	},
	qq{"$target"."#idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'coref_text') {
    $cond = 
      $self->serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.coref_text.rf},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	},
	qq{"$target"."#idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'compl') {
    $cond = 
      $self->serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.compl.rf},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	},
	qq{"$target"."#idx"},
	q(=),$opts,
       );
  } elsif ($relation eq 'val_frame.rf') {
    $cond =
      $self->serialize_predicate(
	{
	  id=>$from_id,
	  type=>$type,
	  join=>$opts->{join},
	  expression => qq{\$$id.val_frame.rf},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	},
	qq{"$target"."#idx"},
	q(=),$opts,
       );
  }
  return $cond;
}

sub build_sql {
  my ($self,$tree,$opts)=@_;
  $opts||={};
  my ($format,$count,$tree_parent_id) = map {$opts->{$_}} qw(format count parent_id);
  $count||=0;
  # we rely on depth first order!
  my @nodes = Tree_Query::Common::FilterQueryNodes($tree);
  my @select;
  my @table;
  my @where;
  my %conditions;
  my $extra_joins = $opts->{join} || {};
  my $default_type = $opts->{type}||$tree->root->{'node-type'}||'UNKNOWN';
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $table = $n->{'node-type'}||$default_type;
    my $id = $self->{id_map}{$n};

    push @select, $id;
    my $parent = $n->parent;
    while ($parent and ($parent->{'#name'}||'') !~/^(?:node|subquery)$/) {
      #      push @ancestors,$parent;
      $parent=$parent->parent;
    }
#     my $is_positive_conjunct=1;
#     {
#       my @ancestors;
#       while ($parent and ($parent->{'#name'}||'') !~/^(?:node|subquery)$/) {
# 	push @ancestors,$parent;
# 	$parent=$parent->parent;
#       }
#       for my $anc (@ancestors) {
# 	my $name = $anc->{'#name'};
# 	if ($name eq 'not') {
# 	  $is_positive_conjunct=!$is_positive_conjunct;
# 	} elsif ($name eq 'or' and $is_positive_conjunct) {
# 	  $is_positive_conjunct = 0;
# 	  last;
# 	} elsif ($name eq 'and' and !$is_positive_conjunct) {
# 	  $is_positive_conjunct = 0;
# 	  last;
# 	}
#       }
#     }
    my $parent_id = $self->{id_map}{$parent};
    $conditions{$id} = Tree_Query::Common::as_text($n);
    my @conditions;
    if ($parent && $parent->parent) {
      my ($rel) = SeqV($n->{relation});
      $rel ||= Tree_Query::Common::SetRelation($n,'child');
      push @conditions,
	[$self->relation($parent_id,$rel,$id, {
	  %$opts,
	  id=>$id,
	  join => $extra_joins,
	  type=>($parent->{'node-type'}||$default_type),
	  is_positive_conjunct=>($n->{'#name'} eq 'subquery' ? 0 : 1),
	 }),$n];
      push @table,[$self->get_node_table_for($table),$id,$n];
    } else {
      push @table,[$self->get_node_table_for($table),$id,$n];
    }
    push @conditions,
      (map {
	[qq{"$self->{id_map}{$_}"."#idx"}.
	   ($conditions{$id} eq $conditions{$self->{id_map}{$_}} ? '<' : '!=' ).
	     qq{"${id}"."#idx"},$n] }
	 grep { #$_->parent == $n->parent
	   #  or
	   my $type=$_->{'node-type'}||$default_type;
	   $type eq $table and
	     (first { !$_->{optional} } $_->ancestors)==(first { !$_->{optional} } $n->ancestors)
	   }
	   map { $nodes[$_] } 0..($i-1));
    {
      my $conditions = $self->serialize_conditions($n,{
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
	@conditions = ( [ [['(('], @{Tree_Query::Common::_group(\@conditions,["\n    AND "])}, [qq{) OR "$id"."#idx"="$parent_id"."#idx")}]], $n] );
      }
    }
    push @where, @conditions;
  }

  my @sql = (['SELECT ']);
  my @outputs = $tree->parent ? () : ListV($tree->{'output-filters'});
  my $output_opts;
  my $returns_nodes = $opts->{returns_nodes} || \ my $dummy;
  if (@outputs) {
    $$returns_nodes=0;
    my $first = first { $_->{'#name'} eq 'node' } $tree->children;
    $output_opts = {
      id     => $self->{id_map}{$first},
      join   => $extra_joins,
      syntax => $opts->{syntax},
    };
    push @sql, ['DISTINCT '] if $outputs[0]->{distinct};
    $output_opts->{group_by} = $self->serialize_columns($outputs[0]->{'group-by'},0,$output_opts,'group_by');
    push @sql,[$self->serialize_columns($outputs[0]->{return},0,$output_opts,'select'),'space'];
  } elsif ($count == 2) {
    $$returns_nodes=0;
    push @sql,['count(DISTINCT "'.$self->{id_map}{$tree}.'"."#idx")','space'];
  } elsif ($count) {
    $$returns_nodes=0;
    push @sql,['count(1)','space'];
  } else {
    $$returns_nodes=1;
    push @sql, (['DISTINCT '], map {
      my $n = $nodes[$_];
      (($_==0 ? () : [', ','space']),
       ['"'.$select[$_].'"."#idx"',$n],
       [' AS "'.$select[$_].'.#idx"',$n],
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
      push @sql, [qq{"$tab" "$name"},$node];
      if ($extra_joins->{$name}) {
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  push @sql, [' ','space'], [qq($join_type JOIN "$join_tab" "$join_as" ON $join_on),$node]
	}
      }
    }
  }
  {
    my @w=@{Tree_Query::Common::_group(\@where,["\n  AND "])};
    push @sql, [ "\nWHERE\n     ",'space'],@w if @w;
  }
  if (@outputs) {
    my $group_by = delete $output_opts->{group_by};
    push @sql,
      (@$group_by ?
	 ["\n GROUP BY ".join(', ',@$group_by)."\n",$tree] : ()),
      ($outputs[0]->{'sort-by'} ?
	 ["\n ORDER BY ".$self->serialize_columns($outputs[0]->{'sort-by'},1,$output_opts,'order_by'),$tree] : ());
    shift @outputs;
    my $i=1;
    for my $out (@outputs) {
      $output_opts->{group_by} = $self->serialize_columns($outputs[0]->{'group-by'},$i,$output_opts,'group_by');
      unshift @sql, ['SELECT '
		    .($out->{distinct} ? 'DISTINCT ' : '')
		    .$self->serialize_columns($out->{'return'},$i,$output_opts,'select')." FROM (\n",$tree];
      my $group_by = delete $output_opts->{group_by};
      push @sql,
	[")\n",$tree],
	(@$group_by ?
	   ["\n GROUP BY ".join(', ',@$group_by)."\n",$tree] : ()),
	($out->{'sort-by'} ?
	   ["\n ORDER BY ".$self->serialize_columns($out->{'sort-by'},$i+1,$output_opts,'order_by')."\n",$tree] : ());
      $i++;
    }
  }
  unless (defined($tree_parent_id) and defined($self->{id_map}{$tree})) {
    if ($$returns_nodes) {
      push @sql, ["\n".$self->serialize_limit($opts->{node_limit})."\n",'space'] if defined $opts->{node_limit};
    } elsif (defined $opts->{row_limit}) {
      unshift @sql, ['SELECT * FROM ('];
      push @sql, [") WHERE 1=1 ".$self->serialize_limit($opts->{row_limit})];
    }
  }
  if ($format) {
    return Tree_Query::Common::make_string_with_tags(\@sql,[$tree]);
  } else {
    return Tree_Query::Common::make_string(\@sql);
  }
}

sub serialize_columns {
  my ($self,$col_list,$j,$opts,$type)=@_;
  my @cols;
  my $i=1;
  for my $col (ListV($col_list)) {
    my ($str,$wrap,$cal_be_null)=$self->serialize_expression({%$opts,expression=>$col,output_column=>$j+1,is_positive_conjunct=>1});
    push @cols, $str.($type eq 'select' ? ' AS c'.($j+1).'_'.($i++) : '');
  }
  return $type eq 'group_by' ? \@cols : join(',  ', @cols);
}

sub get_node_table_for {
  my ($self,$type)=@_;
  return $SEPARATE_TREES==1 ? $self->get_schema_name_for($type).'__#trees' : $type;
}
sub get_schema_name_for {
  my ($self,$type)=@_;
  if ($self->{schema_types}{$type}) {
    return $self->{schema_types}{$type};
  }
  my $t=$type; $t=~s/'/''/g;
  my $results = $self->run_sql_query(qq(SELECT "root" FROM "#PMLTYPES" WHERE "type" = '$t' ),{ MaxRows=>1, RaiseError=>1 });
  return $self->{schema_types}{$type} = $results->[0][0] || die "Did not find schema name for type $type\n";
}
sub get_schema {
  my ($self,$name)=@_;
  return unless $name;
  if ($self->{schemas}{$name}) {
    return $self->{schemas}{$name};
  }
  my $n=$name; $n=~s/'/''/g;
  my $results = $self->run_sql_query(qq(SELECT "schema" FROM "#PML" WHERE "root" = '$n' ),
				     { MaxRows=>1, RaiseError=>1, LongReadLen=> 512*1024 });
  unless (ref($results) and ref($results->[0]) and $results->[0][0]) {
    die "Failed to obtain PML schema $name\n";
  }
  return $self->{schemas}{$name} = PMLSchema->new({string => $results->[0][0]});
}
sub get_node_types {
  my ($self)=@_;
  return $self->{node_types} if defined $self->{node_types};
  my $results = $self->run_sql_query(qq(SELECT "type" FROM "#PMLTYPES" ORDER BY "type"),{ MaxRows=>1, RaiseError=>1 });
  return $self->{node_types} = [ map $_->[0], @$results ];
  
}
sub get_decl_for {
  my ($self,$type)=@_;
  return unless $type;
  if ($self->{type_decls}{$type}) {
    return $self->{type_decls}{$type};
  }
  my $schema = $self->get_schema($self->get_schema_name_for($type));
  $type=~s{(/|$)}{.type$1};
  my $decl = $self->{type_decls}{$type} = $schema->find_type_by_path('!'.$type);
  $decl or die "Did not find type '!$type'";
  return $decl;
}

sub _table_name {
  my ($path) = @_;
  return unless defined $path;
  $path=~s/\[LIST\]/LM/;
  $path=~s/\[ALT\]/AM/;
  $path=~s{^!([^/]+)\.type\b}{$1};
  return $path;
}

sub serialize_expression_pt {# pt stands for parse tree
  my ($self,$pt,$opts,$extra_joins)=@_;
  my $this_node_id = $opts->{id};
  if (ref($pt)) {
    my $type = shift @$pt;
    if ($type eq 'ATTR' or $type eq 'REF_ATTR') {
      my ($id,$attr,$cmp,$decl);
      if ($type eq 'REF_ATTR') {
	$id = lc($pt->[0]);
	$pt=$pt->[1];
	die "Error in attribute reference of node $id in expression $opts->{expression} of node '$this_node_id'" 
	  unless shift(@$pt) eq 'ATTR'; # not likely
	$cmp = $self->cmp_subquery_scope($this_node_id,$id);
	if ($cmp<0) {
	  die "Node '$id' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
	}
	my $n = $self->{name2node}{$id};
	$decl = $self->get_decl_for($n->{'node-type'}||$n->root->{'node-type'});
      } else {
	$id=$this_node_id;
	$decl = $self->get_decl_for($opts->{type});
      }
      my $node_id = $id;
      my $j;
# 	if (!$opts->{is_positive_conjunct} or $cmp) {
# 	  print "extra joins\n";
# 	  $opts->{use_exists}=1;
# 	  $j=$extra_joins;
# 	} else {
# 	  print "normal joins\n";
	$j=$opts->{join};
	#	}
	$extra_joins->{$node_id}||=[];
	$j->{$node_id}||=[];

	my $i = 0;
	my $table=_table_name($decl->get_decl_path);
        if ($SEPARATE_TREES==1) {
	  $id=$node_id."/$i";
	  unless (first {$_->[0] eq $id} (@{$j->{$node_id}}, @{$extra_joins->{$node_id}})) {
	    push @{$j->{$node_id}},[$id,$table, qq("$id"."#idx" = "$node_id"."#idx")];
	  }
	} else {
	  $id=$node_id;
	}
	my @t = @$pt;
	my $column;
	my $iter=0;
	while ($iter++ < 100) {
	  my $prev = $id;
	  my ($mdecl,$mtable);
	  my $can_be_null = 0;
	  my $decl_is = $decl->get_decl_type;
	  if ($decl_is == PML_STRUCTURE_DECL or
              $decl_is == PML_CONTAINER_DECL) {
	    last unless @t;
	    $column= shift @t;
	    $mdecl = $decl->get_member_by_name($column);
	    if (!$mdecl and $decl_is == PML_STRUCTURE_DECL) {
	      $mdecl=$decl->get_member_by_name($column.'.rf');
	      $mdecl=undef unless $mdecl; # and $mdecl->get_knit_name eq $column;
	    }
	    if ($mdecl) {
	      unless ($mdecl->is_required) {
		$can_be_null=1;
	      }
	      $mdecl = $mdecl->get_knit_content_decl;
	    }
	  } elsif ($decl_is == PML_LIST_DECL or $decl_is == PML_ALT_DECL) {
	    $mdecl=$decl->get_knit_content_decl;
	    $column='#value';
	    $can_be_null=1;
	  } elsif ($decl_is == PML_SEQUENCE_DECL) {
	    last unless @t;
	    $column= shift @t;
	    $mdecl = $decl->get_element_by_name($column);
	    $mtable='#e_'.table_name($mdecl->get_knit_content_decl->get_decl_path);
	    $can_be_null=1;
	  } elsif ($decl_is == PML_ELEMENT_DECL) {
	    $mdecl=$decl->get_knit_content_decl;
	    $column='#value';
	  } else {
	    die ref($self)." internal error: Didn't expect $decl_is type\n";
	  }
	  die "Didn't find member '$column' on '$table' while compiling expression $opts->{expression} of node '$this_node_id'" unless $mdecl;
	  $opts->{can_be_null}=1 if $can_be_null;
	  if ($mdecl->is_atomic) {
	    if (@t) {
	      die "Cannot follow attribute path past atomic type while compiling expression $opts->{expression} of node '$this_node_id': "
		.join('/',@t);
	    }
	    return qq( "$prev"."$column" );
	  } else {
	    if ($opts->{can_be_null} and (!$opts->{is_positive_conjunct} or $cmp)) {
	      $opts->{use_exists}=1;
	      $j=$extra_joins;
	    }
	    $i = @{$j->{$node_id}}+@{$extra_joins->{$node_id}};
	    #$i = @{$j->{$node_id}};
	    $id=$node_id."/$i";
	    $table=$mtable||_table_name($mdecl->get_decl_path);
	    push @{$j->{$node_id}},[$id,$table, qq("$id"."#idx" = "$prev"."$column") ];
#				    ($can_be_null # || !$opts->{is_positive_conjunct} || $cmp
#				       and !$opts->{use_exists}) ? 'LEFT' : ()];
	  }
	  $decl=$mdecl;
	}
	if ($iter>=100) {
	  die "Deep recursion while compiling $opts->{expression} of node '$this_node_id'";
	}
	die "Expression $opts->{expression} of node '$this_node_id' does not lead to an attomic value";
    } elsif ($type eq 'FUNC') {
      my $name = $pt->[0];
      my $args = $pt->[1];
      my $id;
      if ($name=~/^(?:descendants|lbrothers|rbrothers|sons|depth|depth_first_order|name)$/) {
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
	return ($name eq 'descendants') ? qq{("$id"."#r"-"$id"."#idx")}
	     : ($name eq 'lbrothers')   ? qq{"$id"."#chord"}
	     : ($name eq 'rbrothers')   ? qq{("$opts->{parent_id}"."#chld"-"$id"."#chord"-1)}
             : ($name eq 'sons')        ? qq{"$id"."#chld"}
             : ($name eq 'depth')       ? qq{"$id"."#lvl"}
             : ($name eq 'depth_first_order') ? qq{("$id"."#idx"-"$id"."#root_idx")}
             : ($name eq 'name')        ? qq{"$id"."#name"}
             : die "Tree_Query internal error while compiling expression: should never get here!";
      } elsif ($name=~/^(?:lower|upper|length|abs|floor|ciel)$/) {
	if ($args and @$args==1) {
	  return uc($name).'('
	         .  $self->serialize_expression_pt($args->[0],$opts,$extra_joins)
	         . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	}
      } elsif ($name =~ /^(position)$/) {
	my @arg;
	if ($args and @$args) {
	  my $ref = $args->[0];
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(\$node?)\n"
	    if (@$args>1 or $ref!~/^\$(?!\d)/);
	  @arg = ($ref);
	}
	return $self->serialize_expression_pt(
	  ['EXP' =>
	     [FUNC => 'file', [@arg]],
	     '&', "'##'", '&',
	     [FUNC => 'tree_no', [@arg]],
	     '&', "'.'", '&',
	    [FUNC => 'depth_first_order', [@arg]],
	  ],$opts,$extra_joins);
      } elsif ($name =~ /^(file|tree_no)$/) {
	my $id;
	if ($args and @$args) {
	  my $ref = $args->[0];
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(\$node?)\n"
	    if (@$args>1 or not $ref=~s/^\$(?!\d)//);
	  $id= $ref eq '$' ? $this_node_id : $ref;
	} else {
	  $id = $this_node_id;
	}
	my $n = $self->{name2node}{$id};
	$n or die "Cannot refer to node '$id' from $name() in expression $opts->{expression} of node '$this_node_id'!\n";
	my $J = ($extra_joins->{$id}||=[]);
	my $table = $self->get_schema_name_for($n->{'node-type'}||$n->root->{'node-type'}).'__#files';
	my $fid = $id."/#file";
	push @$J,[$fid,$table, qq("$fid"."#idx" = "$id"."#root_idx")] unless first { $_->[0] eq $fid } @$J;
	return $name eq 'tree_no' ? qq{("$fid"."$name"+1)} : qq{"$fid"."$name"};
      } elsif ($name=~/^(?:round|trunc)$/) {
	if ($args and @$args and @$args<3) {
	  return uc($name).'('
	         .  join(',',map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$args)
	         . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	}
      } elsif ($name eq 'percnt') {
	if ($args and @$args>0 and @$args<3) {
	  my @args = map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$args;
	  return 'round(100*('.$args[0].')'
	    . (@args>1 ? ','.$args[1] : '').q[)];
	} else {
	  die "Wrong arguments for function percnt() in expression $opts->{expression} of node '$this_node_id'!\nUsage: percnt(number,precision?)\n";
	}
      } elsif ($name eq 'substr') {
	if ($args and @$args>1 and @$args<4) {
	  my @args = map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$args;
	  $args[1].='+1';
	  return 'SUBSTR('
	    .  join(',', @args)
	      . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: substr(string,from,length?)\n";
	}
      }
    } elsif ($type eq 'ANALYTIC_FUNC') {
      my $name = shift @$pt;
      die "The analytic function $name can only be used in an output filter expression!\n"
	unless $opts->{'output_column'};
      my $first_arg = shift @$pt;
      die "The analytic function $name without an 'over' clause cannot be used to compute an argument to another analytic function without an 'over' clause $opts->{aggregated} in the output filter expression $opts->{expression}!\n" if defined($opts->{'aggregated'}) and !@$pt and !($opts->{group_by} and @{$opts->{group_by}});
      $name = 'ratio_to_report' if $name eq 'ratio';
      my $out=uc($name).'(';
      if (defined($first_arg) and length($first_arg)) {
	$out.=  $self->serialize_expression_pt($first_arg,{%$opts,
							   (@$pt ? () : (aggregated=>$name))
							  },$extra_joins)
      } else {
	if ($name eq 'count') {
	  $out.='*'
	} elsif ($name eq 'ratio_to_report') {
	  $out.='count(*)'
	} else {
	  $out.= ($opts->{group_by} and @{$opts->{group_by}}) ? $opts->{group_by}[0] : 'c'.($opts->{'output_column'}-1).'_1';
	}
      }
      $out.=')';
      if (@$pt) {
	$out.= ' over ('
	  .((@$pt==1 and $pt->[0] eq 'ALL')
	    ? ''
	    : 'partition by '.join(',',map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$pt)
	   ).')';
      }
      return $out;
    } elsif ($type eq 'EXP') {
      my $out.='(';
      while (@$pt) {
	$out.=$self->serialize_expression_pt(shift @$pt,$opts,$extra_joins);
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
    } elsif ($type eq 'SET') {
      my $res= '('
	.  join(',', map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$pt)
	. ')';
      $opts->{can_be_null}=0;
      return $res;
    } else {
      die "Internal error: unrecognized parse tree item $type\n";
    }
  } else {
    if ($pt=~/^[-0-9']/) { # literal
      return qq( $pt );
    } elsif ($pt=~s/^\$//) { # a plain variable
      if ($pt =~ /^\d+$/) { #column reference
	die "Column reference \$$pt can only be used in an output filter; error in expression '$opts->{expression}' of node '$this_node_id'\n"
	  unless $opts->{'output_column'};
	my $col = ($opts->{group_by} and @{$opts->{group_by}}) ? $opts->{group_by}[$pt-1] : 'c'.($opts->{'output_column'}-1).'_'.$pt;
	return ' '.$col.' ';
      }
      return qq{ "$this_node_id"."#idx" } if $pt eq '$';
      if ($self->cmp_subquery_scope($this_node_id,$pt)<0) {
	die "Node '$pt' belongs to a sub-query and cannot be referred from the scope of node '$this_node_id' ($opts->{expression})\n";
      }
      return qq( "$pt"."#idx" );
    } else { # unrecognized token
      die "Token '$pt' not recognized in expression $opts->{expression} of node '$this_node_id'\n";
    }
  }
}

sub serialize_expression {
  my ($self,$opts)=@_;
  my $pt = 
    $opts->{'output_column'}
      ? Tree_Query::Common::parse_column_expression($opts->{expression})
      : Tree_Query::Common::parse_expression($opts->{expression}); # $pt stands for parse tree
  die "Invalid expression '$opts->{expression}' on node '$opts->{id}'" unless defined $pt;

  my $extra_joins=$opts->{'output_column'} ? $opts->{join} : {};
  $opts->{use_exists}=0;
  $opts->{can_be_null}=0;
  my $out = $self->serialize_expression_pt($pt,$opts,$extra_joins); # do not copy $opts here!

  my $wrap;
  if (!$opts->{'output_column'} and $opts->{use_exists}) {
    my @from;
    my @where;
    for my $name (keys (%$extra_joins)) {
      if ($extra_joins->{$name}) {
	my $table;
	for my $join_spec (@{$extra_joins->{$name}}) {
	  my ($join_as,$join_tab,$join_on,$join_type)=@{$join_spec};
	  $join_type||='';
	  if (defined $table) {
	    $table.=qq( $join_type JOIN "$join_tab" "$join_as" ON $join_on);
	  } else {
	    $table=qq("$join_tab" "$join_as");
	    push @where, $join_on;
	  }
	}
	push @from,$table;
      }
    }
    if (@from) {
      $wrap='EXISTS (SELECT *'
	.' FROM '.join(', ',@from)
	.' WHERE '.join("\n   AND ",@where);
      $wrap=~s/%/%%/g;
      $wrap.="\n  AND " if @where;
      $wrap.='%s )';
    }
  }
  return ($out,$wrap,$opts->{can_be_null});
}

sub serialize_predicate {
  my ($self,$L,$R,$operator,$opts)=@_;
  my ($left,$wrap_left,$left_can_be_null) = ref($L) ? $self->serialize_expression($L) : ($L);
  my ($right,$wrap_right,$right_can_be_null) = ref($R) ? $self->serialize_expression($R) : ($R);
  my $res;
  my $is_positive_conjunct = $opts->{is_positive_conjunct};
  if ($operator eq '~' and defined($opts->{syntax}) and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right)};
    $res .= qq{ AND $left IS NOT NULL} if $left_can_be_null and !$is_positive_conjunct;
  } elsif ($operator eq '~*' and defined($opts->{syntax}) and $opts->{syntax} eq 'Oracle') {
    $res = qq{REGEXP_LIKE($left,$right,'i')};
    $res .= qq{ AND $left IS NOT NULL} if $left_can_be_null and !$is_positive_conjunct;
  } else {
    $res = qq{($left }.uc($operator).qq{ $right}
      .($left_can_be_null && !$is_positive_conjunct ? qq{ AND $left IS NOT NULL} : '')
      .($right_can_be_null && !$is_positive_conjunct ? qq{ AND $right IS NOT NULL} : '')
      .(($opts->{syntax} eq 'Oracle' and $operator eq '='
	   and $left_can_be_null and $right_can_be_null
	  ) ? qq{ OR $left IS NULL AND $right IS NULL} : '').')';
  }
  if (defined $wrap_right) {
    $res=sprintf($wrap_right,$res);
  }
  if (defined $wrap_left) {
    $res=sprintf($wrap_left,$res);
  }
  return $res;
}

sub serialize_element {
  my ($self,$opts)=@_;
  my ($name,$node,$as_id,$parent_as_id)=map {$opts->{$_}} qw(name condition id parent_id);
  my $is_positive_conjunct = $opts->{is_positive_conjunct};
  if ($name eq 'test') {
    return
      [$self->serialize_predicate({%$opts,expression=>$node->{a},is_positive_conjunct=>$is_positive_conjunct},
				      {%$opts,expression=>$node->{b},is_positive_conjunct=>$is_positive_conjunct},
				      $node->{operator},
				      $opts),$node];
  } elsif ($name =~ /^(?:and|or|not)$/) {
    my @c = $node->children;
    if (defined($is_positive_conjunct)) {
      if ($name eq 'not') {
	$is_positive_conjunct=!$is_positive_conjunct;
	$is_positive_conjunct=undef if @c>1 and !$is_positive_conjunct;
      } elsif ($name eq 'and') {
	$is_positive_conjunct=undef if @c>1 and !$is_positive_conjunct;
      } elsif ($name eq 'or') {
	$is_positive_conjunct=undef if @c>1 and $is_positive_conjunct;
      }
    }
    @c =
      grep { @$_ }
      map {
	my $n = $_->{'#name'};
	$self->serialize_element({
	  %$opts,
	  name => $n,
	  condition => $_,
	  id => $as_id,
	  parent_id => $parent_as_id,
	  is_positive_conjunct=>$is_positive_conjunct
	 })
      } grep { $_->{'#name'} ne 'node' } @c;
   return unless @c;
   return
     $name eq 'not' ? [[['NOT('],@{Tree_Query::Common::_group(\@c,["\n      AND "])},[')']],$node] :
     $name eq 'and' ? [[['('],@{Tree_Query::Common::_group(\@c,["\n    AND "])},[')']],$node] :
     $name eq 'or' ? [[['('],@{Tree_Query::Common::_group(\@c,["\n    OR "])},[')']],$node] : ();
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
      $min='' unless defined $min;
      $max='' unless defined $max;
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
    return (@occ ? [[ ['('],@{Tree_Query::Common::_group(\@occ,[' OR '])},[')'] ],$node] : ());
  } elsif ($name eq 'ref') {
    my $target = $node->{target};
    my $cmp = $self->cmp_subquery_scope($node,$target);
    if ($cmp<0) {
      die "Node '$as_id' belongs to a sub-query and cannot be referred from the scope of node '$target'\n";
    }
    # case $cmp>0 implies we use negative approach: FIXME - force using EXISTS
    my ($rel) = SeqV($node->{relation});
    if ($target and $rel) {
      return ['('.$self->relation($as_id,$rel,$target,
				  {%$opts,is_positive_conjunct=>($opts->{is_positive_conjunct}&&!$cmp ? 1 : undef)},
				  $opts
				 ).')',$node];
    } else {
      return;
    }
  } else {
    Carp::cluck("Unknown element $name ");
    return;
  }
}

sub cmp_subquery_scope {
  my ($self,$src,$target)=@_;
  $_ = ref($_) ? $_ : $self->{name2node}{$_} || croak("didn't find node '$_'")
    for $src,$target;
  return Tree_Query::Common::cmp_subquery_scope($src,$target);
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Tree_Query::SQLEvaluator - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Tree_Query::SQLEvaluator;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Tree_Query::SQLEvaluator, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

