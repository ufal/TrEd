# -*- cperl -*-
################
### SQL compiler and evaluator
################
{

our $SEPARATE_TREES=0;

package Tree_Query::SQLEvaluator;
use Benchmark;
use Carp;
use strict;
use warnings;
use PMLSchema;

BEGIN { import TredMacro qw(first SeqV AltV ListV) }

sub new {
  my ($class,$query_tree,$opts)=@_;
  my $self = bless {
    dbi => $opts->{dbi},
    connect => $opts->{connect},
    results => undef,
    query_nodes=>undef,
    type_decls => {},
    schema_types => {},
    schemas => {},
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
  $self->{sql}=undef;
  $self->prepare_sql($self->serialize_conditions($query_tree,
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
    my ($idx,$type)=(shift @list, shift @list);
    my $basename = $self->get_schema_name_for($type);
    my $node_tab = $self->get_node_table_for($type);
    my $sql=<<"EOF".$self->serialize_limit(1);
SELECT "f"."file", "f"."tree_no", "n"."#idx"-"n"."#root_idx"
FROM "${node_tab}" "n" JOIN "${basename}__files" "f" ON "n"."#root_idx"="f"."#idx"
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
	  qq{\$$id.$order},
	  qq{\$$target.$order},
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
    my $table = $self->get_schema_name_for($type).'__eparents';
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
    $cond =
      '('.$self->serialize_predicate(
	{
	  id=>$opts->{id},
	  type=>$type,
	  join=>$opts->{join},
	  is_positive_conjunct=>$opts->{is_positive_conjunct},
	  expression => qq{\$$id.a/lex},
	},
	qq{"$target"."#idx"},
	'=',$opts
       ). qq{ OR }. $self->serialize_predicate(
	 {
	   id=>$from_id,
	   type=>$type,
	   join=>$opts->{join},
	   expression => qq{\$$id.a/aux.rf},
	   is_positive_conjunct=>$opts->{is_positive_conjunct},
	 },
	 qq{"$target"."#idx"},
	 qq(=),$opts,
	).')';
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
  } elsif ($relation eq 'val_frame') {
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
  my ($format,$count,$tree_parent_id) = map {$opts->{$_}} qw(format count parent_id limit);
  $count||=0;
  # we rely on depth first order!
  my @nodes = Tree_Query::FilterQueryNodes($tree);
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
	@conditions = ( [ [['(('], @{Tree_Query::_group(\@conditions,["\n    AND "])}, [qq{) OR "$id"."#idx"="$parent_id"."#idx")}]], $n] );
      }
    }
    push @where, @conditions;
  }

  my @sql = (['SELECT ']);
  if ($count == 2) {
    push @sql,['count(DISTINCT "'.$self->{id_map}{$tree}.'"."#idx")','space'];
  } elsif ($count) {
    push @sql,['count(1)','space'];
  } else {
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
    my @w=@{Tree_Query::_group(\@where,["\n  AND "])};
    push @sql, [ "\nWHERE\n     ",'space'],@w if @w;
  }
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

sub get_node_table_for {
  my ($self,$type)=@_;
  return $SEPARATE_TREES==1 ? $self->get_schema_name_for($type).'__trees' : $type;
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
      my $node_id = $id;
	my $decl = $self->get_decl_for($opts->{type});
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
      # url|tree_no
      if ($name=~/^(?:descendants|lbrothers|rbrothers|sons|depth|name)$/) {
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
	return ($name eq 'descendants') ? qq{"$id"."#r"-"$id"."#idx"}
	     : ($name eq 'lbrothers')   ? qq{"$id"."#chord"}
	     : ($name eq 'rbrothers')   ? qq{"$opts->{parent_id}"."#chld"-"$id"."#chord"-1}
             : ($name eq 'sons')        ? qq{"$id"."#chld"}
             : ($name eq 'depth')       ? qq{"$id"."#lvl"}
             : ($name eq 'name')        ? qq{"$id"."#name"}
#             : ($name eq 'url')         ? qq{"$id"."#name"}
#             : ($name eq 'tree_no')     ? qq{"$id"."#name"}
             : die "Tree_Query internal error while compiling expression: should never get here!";
      } elsif ($name=~/^(?:lower|upper|length)$/) {
	if ($args and @$args==1) {
	  return uc($name).'('
	         .  $self->serialize_expression_pt($args->[0],$opts,$extra_joins)
	         . ')';
	} else {
	  die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	}
      } elsif ($name eq 'substr') {
	if ($args and @$args>1 and @$args<4) {
	  my @args = map { $self->serialize_expression_pt($_,$opts,$extra_joins) } @$args;
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
    }
  } else {
    if ($pt=~/^[-0-9']/) { # literal
      return qq( $pt );
    } elsif ($pt=~s/^\$//) { # a plain variable
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
  my $pt = Tree_Query::parse_expression($opts->{expression}); # $pt stands for parse tree
  die "Invalid expression '$opts->{expression}' on node '$opts->{id}'" unless defined $pt;

  my $extra_joins={};
  $opts->{use_exists}=0;
  $opts->{can_be_null}=0;
  my $out = $self->serialize_expression_pt($pt,$opts,$extra_joins); # do not copy $opts here!

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
     $name eq 'not' ? [[['NOT('],@{Tree_Query::_group(\@c,["\n      AND "])},[')']],$node] :
     $name eq 'and' ? [[['('],@{Tree_Query::_group(\@c,["\n    AND "])},[')']],$node] :
     $name eq 'or' ? [[['('],@{Tree_Query::_group(\@c,["\n    OR "])},[')']],$node] : ();
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
    return (@occ ? [[ ['('],@{Tree_Query::_group(\@occ,[' OR '])},[')'] ],$node] : ());
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
    query => undef,
    query_nodes => undef,
    results => undef,
  }, $class;
  $self->init($opts->{config_file},$opts->{config_id}) || return;
  $self->{callback} = [\&open_pmltq,$self];
  weaken($self->{callback}[1]);
  register_open_file_hook($self->{callback});
  my $ident = $self->identify;
  (undef, $self->{label}) = Tree_Query::CreateSearchToolbar($ident);
  my $fn = $self->filelist_name;
  $self->{on_destroy} = MacroCallback(
    sub {
      DestroyUserToolbar($ident);
      for my $win (map { $_->[0] } grep { $_->[1]->name eq $fn } grep ref($_->[1]), map [$_,GetCurrentFileList($_)], TrEdWindows()) {
	CloseFileInWindow($win);
	CloseWindow($win);
      }
      RemoveFileList($fn) if GetFileList($fn);
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
  my $ident= "SQLSearch-".$self->{object_id};
  if ($self->{config}{data}) {
    my $cfg = $self->{config}{data};
    $ident.=" $cfg->{driver}:$cfg->{username}\@$cfg->{host}:$cfg->{port}/$cfg->{database}";
  }
  return $ident;
}

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  my $query = $opts->{query} || $root;
  $self->{query}=$query;
  $self->init_evaluator;
  eval {
    $self->{evaluator}->prepare_query($query);
  };
  if ($@) {
    ErrorMessage($@);
    return unless GUI() and $opts->{edit_sql};
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
  my ($limit, $timeout) = map { int($opts->{$_}||$self->{config}{pml}->get_root->get_member($_)||0)||$DEFAULTS{$_} }
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
      SetCurrentFileList($fl->name,{no_open=>1});
      #GotoFileNo(0);
      $self->{current_result}=[$self->{evaluator}->idx_to_pos($results->[0])];
      ($this,$root,$grp)=@context;
      ${$self->{label}} = (CurrentFileNo($res_win)+1).' of '.(LastFileNo($res_win)+1).
	($limit == $matches ? '+' : '');
      $self->show_result('current');
    }
  } else {
    QuestionQuery('Results','No results','OK');
  }
  return $results;
}

sub current_query {
  my ($self)=@_;
  return $self->{query};
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

sub __cat_path {
  my ($source_dir,$path)=@_;
  return $path if $path=~m{^/};
  return $source_dir.'/'.$path;
}

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my $source_dir = $self->get_source_dir;
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () }
    map { __cat_path($source_dir,$_) } @{$self->{current_result}};
  return @nodes[@positions];
}

sub map_nodes_to_query_pos {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my $source_dir = $self->get_source_dir;
  my @nodes = ($tree,$tree->descendants);
  my $r = $self->{current_result};
  return {
    map { $_->[1]=~/^\Q$fn\E\.(\d+)$/ ? ($nodes[$1] => $_->[0]) : () } map { [$_,__cat_path($source_dir,$r->[$_])] } 0..$#$r 
  };
}

sub node_index_in_last_query {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  return Index($self->{last_query_nodes},$query_node);
}

sub select_matching_node {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  my $idx = Index($self->{last_query_nodes},$query_node);
  return if !defined($idx);
  my $result = $self->{current_result}->[$idx];
  my $source_dir = $self->get_source_dir;
  $result = __cat_path($source_dir,$result);
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

sub get_node_types {
  my ($self)=@_;
  $self->init_evaluator;
  return $self->{evaluator}->get_node_types;
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

sub init_evaluator {
  my ($self)=@_;
  unless ($self->{evaluator}) {
    $self->{evaluator} = Tree_Query::SQLEvaluator->new(undef,{connect => $self->{config}{data}});
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
  }
}


sub filelist_name {
  my $self=shift;
  return ref($self).":".$self->{object_id};
}

sub show_result {
  my ($self,$dir)=@_;
  return unless $self->{evaluator};
  my @save = ($this,$root,$grp);
  my $win=$self->claim_search_win();
  eval {
    if ($dir eq 'prev') {
      $grp=$win;
      PrevFile();
      my $idx = Index($self->{last_query_nodes},$save[0]);
      if (defined($idx)) {
	my $source_dir = $self->get_source_dir;
	my $fn = FileName();
	my $result_fn = __cat_path($source_dir,$self->{current_result}[$idx]);
	if ($result_fn !~ /^\Q$fn\E\.(\d+)$/) {
	  Open($result_fn,{-keep_related=>1});
	  Redraw($win);
	} else {
	  $self->select_matching_node($save[0]);
	}
      }
    } elsif ($dir eq 'next') {
      $grp=$win;
      NextFile();
#       my $idx = Index($self->{last_query_nodes},$save[0]);
#       if (defined($idx)) {
# 	my $source_dir = $self->get_source_dir;
# 	my $fn = FileName();
# 	my $result_fn = __cat_path($source_dir,$self->{current_result}[$idx]);
# 	print "$fn, $result_fn\n";
# 	if ($result_fn !~ /^\Q$fn\E\.(\d+)$/) {
# 	  Open($result_fn,{-keep_related=>1});
# 	  Redraw($win);
# 	} else {
# 	  $self->select_matching_node($save[0]);
# 	}
#       }
    } elsif ($dir eq 'current') {
      return unless $self->{current_result};
      my $idx = Index($self->{last_query_nodes},$save[0]);
      if (defined($idx)) {
	$grp=$win;
	my $source_dir = $self->get_source_dir;
	Open(__cat_path($source_dir,$self->{current_result}[$idx]),{-keep_related=>1});
	Redraw($win);
      }
    }
  };
  my $err=$@;
  my $plus = ${$self->{label}}=~/\+/;
  ${$self->{label}} = (CurrentFileNo($win)+1).' of '.(LastFileNo($win)+1).
    ($plus ? '+' : '');
  ($this,$root,$grp)=@save;
  die $err if $err;
  return;
}


sub claim_search_win {
  my ($self)=@_;
  my $fn = $self->filelist_name;
  my ($win) = map { $_->[0] } grep { $_->[1]->name eq $fn } grep ref($_->[1]), map [$_,GetCurrentFileList($_)], TrEdWindows();
  unless ($win) {
    $win = SplitWindowVertically();
    my $cur_win = $grp;
    $grp=$win;
    eval {
      if ($self->{file}) {
	Open($self->{file});
      } elsif ($self->{filelist}) {
	SetCurrentFileList($self->{filelist});
      }
    };
    $grp=$cur_win;
    die $@ if $@;
  }
  return $win;
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
  print "$filename\n";
  my $object_id=$self->{object_id};
  return unless $filename=~s{pmltq://$object_id/}{};
  my @positions = $self->{evaluator}->idx_to_pos([split m{/}, $filename]);
  $self->{current_result}=\@positions;
  my ($node) = map { CurrentNodeInOtherWindow($_) }
              grep { CurrentContextForWindow($_) eq __PACKAGE__ } TrEdWindows();
  my $idx = Index($self->{last_query_nodes},$node);
  my $first = $positions[$idx||0];
  if (defined $first and length $first) {
    my $source_dir = $self->get_source_dir;
    $opts->{-norecent}=1;
    $opts->{-keep_related}=1;
    my $fsfile = Open(__cat_path($source_dir,$first),$opts);
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
    <schema href="treebase_conf_schema.xml"/>
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
