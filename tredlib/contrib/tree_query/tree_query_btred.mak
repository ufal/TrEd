# -*- cperl -*-
{
package Tree_Query_Btred;
use strict;

BEGIN {
  use vars qw($this $root);
  import TredMacro;
}

# Bind sub { test(1,{one_tree=>1}); ChangingFile(0) } => {
#   key => 's',
#   menu => 'TrEd-based search (one tree)',
#   context=>'Tree_Query',
# };
# Bind sub { test(1,{plan=>1, one_tree=>1}); ChangingFile(0) } => {
#   key => 'P',
#   menu => 'TrEd-based search with planner (one tree)',
#   context=>'Tree_Query',
# };
# Bind sub { test(1); ChangingFile(0) } => {
#   key => 'Ctrl+s',
#   menu => 'TrEd-based search (all trees)',
#   context=>'Tree_Query',
# };
# Bind \&test => {
#   key => 'S',
#   menu => 'TrEd-based search (next match)',
#   changing_file => 0,
#   context=>'Tree_Query',
# };

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
    'query|q=s',
    'plan|p',
  ) or die "Wrong options\n";
  my $query_tree;
  if (defined $opts{query}) {
    my $query=$opts{query};
    die "Empty query\n" unless length $query;
    $query_tree=Tree_Query->parse_query($query);
    DetermineNodeType($_) for $query_tree->descendants;
    print STDERR "Parsed $query\n";
  } else {
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
    die "Query tree $query_fn#$query_id not found\n" unless ref $query_tree;
  }
  #  print STDERR "$query_file\n";
  #plan_query($query_tree) if $opts{plan};
  $evaluator = Tree_Query::BtredEvaluator->new($query_tree,{plan=>$opts{plan}});

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
      $evaluator = Tree_Query::BtredEvaluator->new($query_tree,$opts) if !$evaluator or $restart;
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

{

package Tree_Query::TrEdSearch;
use Benchmark;
use Carp;
use strict;
use warnings;
BEGIN { import TredMacro  }

$Tree_Query::TrEdSearchPreserve::object_id=0; # different NS so that TrEd's reload-macros doesn't clear it

sub new {
  my ($class,$opts)=@_;
  $opts||={};
  my $what = ($opts->{file}?0:1) +
             ($opts->{filelist}?0:1);
  die "Neither fsfile, nor filelist were specified!" unless $what;
  die "Options fsfile, filelist are exclusive!" if $what>1;
  my $self = bless {
    object_id =>  $Tree_Query::TrEdSearchPreserve::object_id++,
    file => $opts->{file},
    filelist => $opts->{filelist},
    evaluator => undef,
    query => undef,
    results => undef,
  }, $class;
  my $ident = $self->identify;
  Tree_Query::CreateSearchToolbar($ident);
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
  return 'TrEdSearch-'.$self->{object_id}.' '
    .($self->{filelist} ? 'Filelist: '.$self->{filelist} :
      $self->{file}     ? 'File: '     .$self->{file}    : '');
}

sub configure {
  # nothing to configure here, yet
  # in the future we could set file/filelist/one tree only,
  # non-tred filelist etc.
  return;
}

sub reconfigure {
  return;
}

sub search_first {
  my ($self, $opts)=@_;
  $opts||={};
  local $SIG{__DIE__} = sub { confess(@_) };
  my $query = $opts->{query} || $root;
  $self->{query}=$query;
  $self->{evaluator} = Tree_Query::BtredEvaluator->new($query,
						      {current_filelist => $self->{filelist} ? 1 : 0});
  $self->{current_result} = undef;
  $self->{past_results}=[];
  $self->{next_results}=[];
  $self->{have_all_results}=undef;
  return $self->show_next_result;
}

sub current_query {
  my ($self)=@_;
  return $self->{query};
}

sub show_next_result {
  my ($self)=@_;
  return unless $self->{evaluator};
  if ($self->{current_result}) {
    push @{$self->{past_results}},
      $self->{current_result};
  }
  if ($self->{next_results} and @{$self->{next_results}}) {
    $self->{current_result} = pop @{$self->{next_results}};
    return $self->show_current_result;
  }
  if ($self->{have_all_results}) {
    QuestionQuery('TrEdSearch','No more matches','OK');
    return;
  }
  my @save = ($grp,$root,$this);
  $grp=$self->claim_search_win;
  if ($self->{current_result}) {
    Open($self->{current_result}->[0]);
  } else {
    if ($self->{filelist}) {
#      SetCurrentFileList($self->{filelist});
      GotoFileNo(0);
    } else {
      GotoTree(0);
    }
  }
  my $result;
  eval {
    $result = $self->{evaluator}->find_next_match();
    my $result_files = $self->{evaluator}->get_result_files;
    if ($result) {
      $self->{current_result} = [
	map ThisAddress($result->[$_],$result_files->[$_]), 0..$#$result
      ];
    } else {
      $self->{have_all_results}=1;
    }
  };
  $Redraw='all';
  ($grp,$root,$this)=@save;
  die $@ if $@;
  if ($result) {
    $self->select_matching_node($this);
  } else {
    QuestionQuery('TrEdSearch','No more matches','OK');
  }
  $self->update_label;
  return $self->{current_result};
}

sub update_label {
  my ($self)=@_;
  my $past = (($self->{past_results} ? int(@{$self->{past_results}}) : 0)
		+ ($self->{current_result} ? 1 : 0));
  ${$self->{label}} = $past
    .' of '
    .($self->{next_results} ? $past+int(@{$self->{next_results}}) : $past)
    .($self->{have_all_results} ? '' : '+');
}

sub show_prev_result {
  my ($self)=@_;
  if ($self->{past_results} and @{$self->{past_results}}) {
    if ($self->{current_result}) {
      push @{$self->{next_results}},
	$self->{current_result};
    }
    $self->{current_result} = pop @{$self->{past_results}};
    return $self->show_current_result;
  }
  return;
}

sub show_current_result {
  my ($self)=@_;
  $self->update_label;
  return unless $self->{current_result};
  my $idx = $self->node_index_in_last_query($this);
  $idx ||= 0;
  my @save = ($grp,$root,$this);
  my $address = $self->{current_result}[$idx];
  my ($file) = ParseNodeAddress($address);
  $grp=$self->claim_search_win($file);
  Open($address,{-keep_related=>1});
  Redraw($grp);
  ($grp,$root,$this)=@save;
  return $self->{current_result};
}

sub matching_nodes {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my @matching;
  my $fn = $filename.'##'.($tree_number+1);
  my @nodes = ($tree,$tree->descendants);
  my @positions = map { /^\Q$fn\E\.(\d+)$/ ? $1 : () } @{$self->{current_result}};
  return @nodes[@positions];
}

sub map_nodes_to_query_pos {
  my ($self,$filename,$tree_number,$tree)=@_;
  return unless $self->{current_result};
  my $fn = $filename.'##'.($tree_number+1);
  my @nodes = ($tree,$tree->descendants);
  my $r = $self->{current_result};
  return {
    map { $_->[1]=~/^\Q$fn\E\.(\d+)$/ ? ($nodes[$1] => $_->[0]) : () } 
      reverse # upper nodes first (optional nodes do not overwrite their parents)
      map { [$_,$r->[$_]] } 0..$#$r
  };
}

sub node_index_in_last_query {
  my ($self,$query_node)=@_;
  return unless $self->{current_result};
  return $self->{evaluator}->{query_node2pos}{$query_node};
}

sub select_matching_node {
  my ($self,$query_node)=@_;
  return unless $self->{current_result} and $self->{evaluator};
  my $idx = $self->node_index_in_last_query($query_node);
  return if !defined($idx);
  my $result = $self->{current_result}->[$idx];
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
      EnableMinorMode('Tree_Query_Results',$win);
      SetCurrentNodeInOtherWin($win,$r);
      CenterOtherWinTo($win,$r);
    }
  }
  return;
}

sub get_schema_for_query_node {
  my ($self,$node)=@_;
  my $decl = $self->get_type_decl_for_query_node($node);
  return $decl && $decl->schema;
}
sub get_schema_for_type {
  my ($self,$type)=@_;
  my $decl = $self->get_decl_for($type);
  return $decl && $decl->get_schema;
}

sub _get_fsfile {
  my ($self)=@_;
  my $file = $self->{file};
  my $fl;
  if ($file) {
    return first { $_->filename eq $file } GetOpenFiles();
  } elsif ($fl = GetFileList($self->{filelist})) {
    my %fl;
    my @files = $fl->files;
    print "@files\n";
    @fl{ @files } = ();
    my $fsfile = ((first { exists($fl{$_->filename}) } GetOpenFiles())||
	     $files[0] && Open(AbsolutizeFileName($files[0],$fl->filename),{-preload=>1}))
      || return;
    return $fsfile;
  }
}

sub get_schema {
  my ($self)=@_;
  my $fsfile = $self->_get_fsfile || return;
  return PML::Schema($fsfile);
}

sub get_schemas {
  my ($self)=@_;
  my $fsfile = $self->_get_fsfile || return;
  return uniq map PML::Schema($_), ($fsfile,  GetSecondaryFiles($fsfile));
}

sub get_type_decl_for_query_node {
  my ($self,$node)=@_;
  return $self->get_decl_for(Tree_Query::Common::GetQueryNodeType($node));
}

sub get_decl_for {
  my ($self,$type)=@_;
  $type=~s{(/|$)}{.type$1};
  for my $schema ($self->get_schemas) {
    my $decl = $schema->find_type_by_path('!'.$type);
    return $decl if $decl;
  }
  warn "Did not find type '!$type'";
  return;
}

sub get_node_types {
  my ($self)=@_;
  return [map Tree_Query::Common::DeclToQueryType( $_ ), map $_->node_types, $self->get_schemas];
}



######## Private

sub claim_search_win {
  my ($self,$file)=@_;
  my $win;
  $file ||= $self->{file};
  if ($file) {
    ($win) = map { $_->[0] } grep { $_->[1]->filename eq $file } grep ref($_->[1]), map [$_,CurrentFile($_)], TrEdWindows();
  } else {
    ($win) = map { $_->[0] } grep { $_->[1]->name eq $self->{filelist} } grep ref($_->[1]), map [$_,GetCurrentFileList($_)], TrEdWindows();
  }
  unless ($win) {
    $win = SplitWindowVertically();
    my $cur_win = $grp;
    $grp=$win;
    EnableMinorMode('Tree_Query_Results',$win);
    eval {
      if ($file) {
	Open($file);
      } elsif ($self->{filelist}) {
	SetCurrentFileList($self->{filelist});
      }
    };
    $grp=$cur_win;
    die $@ if $@;
  }
  return $win;
}


}

###########################################
{
  package Tree_Query::BtredEvaluator;

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
    'same-tree-as' => q($start->root==$end->root), # not very effective !!
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

    my $clone_before_plan = 0;
    if (ref($query_tree)) {
      $clone_before_plan = 1;
    } else {
      $query_tree = Tree_Query->parse_query($query_tree);
      TredMacro::DetermineNodeType($_) for $query_tree->descendants;
    }

    $opts ||= {};

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
      # query_nodes => [],
      results => [],
    }, $class;
    weaken($self->{parent_query}) if $self->{parent_query};
    $query_pos = \$self->{query_pos};

    my $type = $query_tree->type->get_base_type_name;
    unless ($type eq 'q-query.type' or
	    $type eq 'q-subquery.type') {
      die "Not a query tree: $type!\n";
    }
    my $roots;
    my @orig_nodes=Tree_Query::FilterQueryNodes($query_tree);
    my @query_nodes;
    my %orig2query;
    if ($opts->{no_plan}) {
      $roots = ($type eq 'q-query.type') ? [ $query_tree->children ] : [$query_tree];
      @query_nodes=@orig_nodes;
      %orig2query = map { $_ => $_ } @orig_nodes;
    } elsif ($self->{parent_query}) {
      $roots = Tree_Query::BtredPlanner::plan(
	\@orig_nodes,
	$query_tree->parent,
	$query_tree
       );
      %orig2query = map { $_ => $_ } @orig_nodes;
      @query_nodes=Tree_Query::FilterQueryNodes($query_tree); # reordered
    } else {
      if ($clone_before_plan) {
	$query_tree=FSFormat->clone_subtree($query_tree);
      }
      @query_nodes=Tree_Query::FilterQueryNodes($query_tree); # same order as @orig_nodes
      %orig2query = map { $orig_nodes[$_] => $query_nodes[$_] } 0..$#orig_nodes;
      Tree_Query::BtredPlanner::name_all_query_nodes($query_tree); # need for planning
      $roots = Tree_Query::BtredPlanner::plan(\@query_nodes,$query_tree);
      @query_nodes=Tree_Query::FilterQueryNodes($query_tree); # reordered
    }
    my $query_node;
    if (@$roots==0) {
      die "No query node!\n";
    } elsif (@$roots>1) {
      die "The query is not connected: the graph has more than one root node (@$roots)!\n";
    } else {
      ($query_node)=@$roots;
    }
    # @{$self->{query_nodes}}=@orig_nodes;
    %name2pos = map {
      my $name = lc($query_nodes[$_]->{name});
      (defined($name) and length($name)) ? ($name=>$_) : ()
    } 0..$#query_nodes;
    {
      my %node2pos = map { $query_nodes[$_] => $_ } 0..$#query_nodes;
      $self->{query_node2pos} = { map { $_=>$node2pos{$orig2query{$_}} } @orig_nodes };
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
 	} elsif ($opts->{current_filelist}) {
 	  $iterator = CurrentFilelistIterator->new($conditions);
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

  sub get_results {
    my $self = shift;
    return $self->{results}
  }
  sub get_result_files {
    my $self = shift;
    return $self->{result_files}
  }
  sub r {
    my ($self,$name)=@_;
    return unless $self->{results};
    my $pos =  $self->{name2pos}{$name};
    return unless defined $pos;
    return wantarray ? ($self->{results}[$pos],$self->{result_files}[$pos]) : $self->{results}[$pos];
  }
  *get_result_node = \&r;

#   sub get_query_nodes {
#     my $self = shift;
#     return $self->{query_nodes};
#   }

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
    } elsif ($relation eq 'same-tree-as') {
      $iterator = SameTreeIterator->new($conditions);
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
	die "user-defined relation ".$rel->value->{label}." not yet implemented in BTrEd Search\n"
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
      $check_preceding = join('', map {"\n   and ".
	   '$conditions['.$_.']->($matched_nodes->['.$self->{pos2match_pos}[$_].'],'
	   .'$iterators['.$_.']->file,'
	   .'1) '
     } sort { $a<=>$b } keys %$recompute_cond);
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
    my $type_name = quotemeta($qnode->{'node-type'});
    my $sub = qq(#line 0 "query-node/${match_pos}"\n)
      . 'sub { my ($node,$fsfile,$backref)=@_; '."\n  "
       .$nodetest
       .(defined($type_name) && length($type_name) ? "\n and ".q[$node->type->get_decl_path =~ m{^\!].$type_name.q[(?:\.type)$}] : ())
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
      return unless $rel;
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

  sub serialize_target {
    my ($self,$target,$opts)=@_;
    if ($target eq $opts->{id}) {
      return '$node';
    }
    my $target_match_pos = $self->{name2match_pos}{$target};
    if (defined $target_match_pos) {
      $opts->{depends_on}{$target_match_pos}=1;
      return '$matched_nodes->['.$target_match_pos.']';
    } else {
      my $pos = $opts->{query_pos};
      my $match_pos = $self->{pos2match_pos}[$pos];
      die "Node '$target' does not exist or belongs to a sub-query and cannot be referred from expression $opts->{expression} of node no. $match_pos!\n";
    }
  }

  sub serialize_expression_pt { # pt stands for parse tree
    my ($self,$pt,$opts)=@_;
    my $this_node_id = $opts->{id};
    if (ref($pt)) {
      my $type = shift @$pt;
      if ($type eq 'ATTR' or $type eq 'REF_ATTR') {
	my ($node);
	if ($type eq 'REF_ATTR') {
	  my $target = lc($pt->[0]);
	  $pt=$pt->[1];
	  die "Error in attribute reference of node $target in expression $opts->{expression} of node '$this_node_id'"
	    unless shift(@$pt) eq 'ATTR'; # not likely
	  $node=$self->serialize_target($target,$opts);
	} else {
	  $node='$node';
	}
	my $attr=join('/',@$pt);
	## FIXME: hack: not needed once we have equality for nodes
	if ($attr =~ /^(?:tag|lemma|form)/) {
	  $attr='m/'.$attr; #FIXME: remove me
	} else {
	  $attr =~ s{^tfa/}{}; #FIXME: remove me
	}
	$attr = (($attr=~m{/}) ? $node.qq{->attr(q($attr))} : $node.qq[->{q($attr)}]);
	return qq{ $attr };
      } elsif ($type eq 'FUNC') {
	my $name = $pt->[0];
	my $args = $pt->[1];
	my $id;
	if ($name=~/^(?:descendants|lbrothers|rbrothers|sons|depth|name)$/) {
	  my $node;
	  if ($args and @$args==1 and !ref($args->[0]) and $args->[0]=~s/^\$//) {
	    $node=$self->serialize_target($args->[0],$opts);
	  } elsif ($args and @$args) {
	    die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(\$node?)\n";
	  } else {
	    $node='$node';
	  }
	  return ($name eq 'descendants') ? qq{ scalar(${node}->descendants) }
	       : ($name eq 'lbrothers')   ? q[ do { my $n = ].$node.q[; my $i=0; $i++ while ($n=$n->lbrother); $i } ]
	       : ($name eq 'rbrothers')   ? q[ do { my $n = ].$node.q[; my $i=0; $i++ while ($n=$n->rbrother); $i } ]
	       : ($name eq 'depth_first_order') ? q[ do { my $n = ].$node.q[; my $r=$n->root; my $i=0; $i++ while ($n!=$r and $r=$r->following); $i } ]
	       : ($name eq 'sons')        ? qq{ scalar(${node}->children) }
    	       : ($name eq 'depth')       ? qq{ ${node}->level }
    	       : ($name eq 'name')       ? qq{ ${node}->{'#name'} }
	       : die "Tree_Query internal error while compiling expression: should never get here!";
	} elsif ($name=~/^(?:lower|upper|length)$/) {
	  if ($args and @$args==1) {
	    my $func = $name eq 'lower' ? 'lc'
	             : $name eq 'upper' ? 'uc'
		     : 'length';
	    return $func.'('
	      .  $self->serialize_expression_pt($args->[0],$opts)
		. ')';
	  } else {
	    die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: ${name}(string)\n";
	  }
	} elsif ($name eq 'substr') {
	  if ($args and @$args>1 and @$args<4) {
	    return 'substr('
	      .  join(',', map { $self->serialize_expression_pt($_,$opts) } @$args)
	      . ')';
	  } else {
	    die "Wrong arguments for function substr() in expression $opts->{expression} of node '$this_node_id'!\nUsage: substr(string,from,length?)\n";
	  }

	} elsif ($name eq 'replace') {
	  if ($args and @$args==3) {
	    my @args = map { $self->serialize_expression_pt($_,$opts) } @$args;
	    return 'do{ my ($str,$from,$to) = (' .join(',', @args).'); $str=~s/\Q$from/$to/g; $str }';
	  } else {
	    die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: $name(string,target,replacement)\n"
	  }
	} elsif ($name eq 'tr') {
	  if ($args and @$args==3) {
	    my @args = map { $self->serialize_expression_pt($_,$opts) } @$args;
	    return 'do{ my ($str,$from,$to) = (' .join(',', @args).'); $from=~s{/}{\\/}g; $to=~s{/}{\\/}g; eval qq{$str=~tr/$from/$to/}; $str; }';
	  } else {
	    die "Wrong arguments for function ${name}() in expression $opts->{expression} of node '$this_node_id'!\nUsage: $name(string,from_chars,to_chars)\n"
	  }
	} elsif ($name eq 'match') {
	  die "match() NOT YET IMPLEMENTED!\n";
	} elsif ($name eq 'substitute') {
	  die "substitue() NOT YET IMPLEMENTED!\n";
	}
      } elsif ($type eq 'EXP') {
	my $out.='(';
	while (@$pt) {
	  $out.=$self->serialize_expression_pt(shift @$pt,$opts);
	  if (@$pt) {		# op
	    my $op = shift @$pt;
	    if ($op eq 'div') {
	      $op='/'
	    } elsif ($op eq 'mod') {
	      $op='%'
	    } elsif ($op eq '&') {
	      $op=' . '
	    } elsif ($op !~ /[-+*]/) {
	      die "Urecognized operator '$op' in expression $opts->{expression} of node '$this_node_id'\n";
	    }
	    $out.=$op;
	  }
	}
	$out.=')';
	return $out;
      } elsif ($type eq 'SET') {
	return '('
	  .  join(',', map { $self->serialize_expression_pt($_,$opts) } @$pt)
	  . ')';
      }
    } else {
      if ($pt=~/^[-0-9']/) {	# literal
	return qq( $pt );
      } elsif ($pt=~s/^(['"])(.*)\1$/$2/s) { # literal string
	$pt=~s/\\([^\\])/$1/sg;
	$pt=~s/'/\\'/sg;
	$pt=q{'}.$pt.q{'};
      } elsif ($pt=~s/^\$//) {	# a plain variable
	if ($pt eq '$') {
	  return $self->serialize_target($this_node_id,$opts);
	} else {
	  return $self->serialize_target($pt,$opts);
	}
      } else {			# unrecognized token
	die "Token '$pt' not recognized in expression $opts->{expression} of node '$this_node_id'\n";
      }
    }
  }

  sub serialize_expression {
    my ($self,$opts)=@_;
    my $pt = Tree_Query::query_parser()->parse_expression($opts->{expression}); # $pt stands for parse tree
    die "Invalid expression '$opts->{expression}' on node '$opts->{id}'" unless defined $pt;
    return $self->serialize_expression_pt($pt,$opts);
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
	  = $iterator->start( $opts->{seed}, $opts->{fsfile} );
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
	  $iterator = $iterators->[ $parent_pos->[$$query_pos] ];
	  my ($seed,$fsfile) = ($iterator->node, $iterator->file);
	  $iterator = $iterators->[$$query_pos];
	  $node
	    = $matched_nodes->[$pos2match_pos->[$$query_pos]]
	      = $iterator->start($seed,$fsfile);
	  #print STDERR ("restart $$query_pos $iterator from $seed->{t_lemma}.$seed->{functor} $self->{debug}[$$query_pos]\n") if $DEBUG;
	  $have->{$node}=1 if $node;
	  next;

	} else {
	  print STDERR ("complete match [bool: $opts->{boolean}]\n") if $DEBUG;
	  # complete match:
	  if ($opts->{boolean}) {
	    return 1;
	  } else {
	    $self->{result_files}=[map { $_->file } @$iterators];
	    return $self->{results}=[map { $_->node } @$iterators];
	  }
	}
      }
    }
    return;
  }


}
#################################################
{
  package Tree_Query::BtredPlanner;

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
    'same-tree-as' => 40,
   );

  %reverse = (
    'user-defined:echild' => 'user-defined:eparent',
    'user-defined:eparent' => 'user-defined:echild',
    'descendant' => 'ancestor',
    'ancestor' => 'descendant',
    'parent' => 'child',
    'child' => 'parent',
    'same-tree-as' => 'same-tree-as',
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
    my @query_nodes=Tree_Query::FilterQueryNodes($query_tree);
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
#    TredMacro::ChangingFile(1);
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
    my ($self,$fsfile)=@_;
    $self->[TREE_NO]=0;
    if ($fsfile) {
      $self->[FILE]=$fsfile;
    } else {
      $fsfile=$self->[FILE];
    }
    my $n = $self->[NODE] = $self->[FILE]->tree(0);
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile=$self->[FILE];
    while ($n) {
      $n = $n->following || $fsfile->tree(++$self->[TREE_NO]);
      last if $conditions->($n,$fsfile);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
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
    return ($this && $self->[CONDITIONS]->($this,TredMacro::CurrentFile())) ? $this : ($this && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile=TredMacro::CurrentFile();
    while ($n) {
      $n = $n->following || (TredMacro::NextTree() && $this);
      last if $conditions->($n,$fsfile);
    }
    return $self->[NODE]=$n;
  }
  sub file {
    return TredMacro::CurrentFile();
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
  package CurrentFilelistIterator;
  use base qw(Tree_Query::Iterator);
  BEGIN {
    import TredMacro qw($this $root $grp);
  }
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  sub start  {
    my ($self)=@_;
    # TredMacro::GotoFileNo(0);
    TredMacro::GotoTree(0);
    $this=$root;
    $self->[NODE]=$this;
    my $fsfile = $grp->{FSFile};
    return ($this && $self->[CONDITIONS]->($this,$fsfile)) ? $this : ($this && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile = $grp->{FSFile};
    while ($n) {
      $n = $n->following
	|| (TredMacro::NextTree() && $this ) 
	||  (TredMacro::NextFile() && ($fsfile=$grp->{FSFile}) && $this)
	  ;
      last if $conditions->($n,$fsfile);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $grp->{FSFile};
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
  use constant FILE=>3;
  sub new  {
    my ($class,$conditions,$root,$fsfile)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions,$root,$fsfile],$class;
  }
  sub start  {
    my ($self)=@_;
    my $root = $self->[NODE] = $self->[TREE];
    return ($root && $self->[CONDITIONS]->($root,$self->[FILE])) ? $root : ($root && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile=$self->[FILE];
    while ($n) {
      $n = $n->following;
      last if $conditions->($n,$fsfile);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }
}
#################################################
{
  package SameTreeIterator;
  use Carp;
  use base qw(TreeIterator);
  sub new  {
    my ($class,$conditions)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions],$class;
  }
  sub start  {
    my ($self,$root,$fsfile)=@_;
    $root=$root->root if $root;
    $self->[TreeIterator::NODE] = $self->[TreeIterator::TREE] = $root;
    $self->[TreeIterator::FILE]=$fsfile;
    return ($root && $self->[TreeIterator::CONDITIONS]->($root,$fsfile)) ? $root : ($root && $self->next);
  }
}
#################################################
{
  package OptionalIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant ITERATOR=>1;
  use constant NODE=>2;
  use constant FILE=>3;
  use Carp;
  sub new {
    my ($class,$iterator)=@_;
    croak "usage: $class->new($iterator)" unless UNIVERSAL::isa($iterator,'Tree_Query::Iterator');
    return bless [$iterator->conditions,$iterator],$class;
  }
  sub start  {
    my ($self,$parent,$fsfile)=@_;
    $self->[NODE]=$parent;
    $self->[FILE]=$fsfile;
    return $parent ? ($self->[CONDITIONS]->($parent,$fsfile) ? $parent : $self->next) : undef;
  }
  sub next {
    my ($self)=@_;
    my $n = $self->[NODE];
    if ($n) {
      $self->[NODE]=undef;
      return $self->[ITERATOR]->start($n,$self->[FILE]);
    }
    return $self->[ITERATOR]->next;
  }
  sub node {
    my ($self)=@_;
    return $self->[NODE] || $self->[ITERATOR]->node;
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
    $self->[ITERATOR]->reset;
  }
}
#################################################
{
  package ChildnodeIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;
  sub start  {
    my ($self,$parent,$fsfile)=@_;
    if ($fsfile) {
      $self->[FILE]=$fsfile;
    } else {
      $fsfile=$self->[FILE];
    }
    my $n = $self->[NODE]=$parent->firstson;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE]->rbrother;
    my $fsfile = $self->[FILE];
    $n=$n->rbrother while ($n and !$conditions->($n,$fsfile));
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }
}
#################################################
{
  package DescendantIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant TOP=>2;
  use constant FILE=>3;

  sub start  {
    my ($self,$parent,$fsfile)=@_;
    if ($fsfile) {
      $self->[FILE]=$fsfile;
    } else {
      $fsfile=$self->[FILE];
    }
    my $n= $parent->firstson;
    $self->[NODE]=$n;
    $self->[TOP]=$parent;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $top = $self->[TOP];
    my $n=$self->[NODE]->following($top);
    my $fsfile=$self->[FILE];
    $n=$n->following($top) while ($n and !$conditions->($n,$fsfile));
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[TOP]=undef;
    $self->[FILE]=undef;
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
  use constant FILE=>5;

  sub new {
    my ($class,$conditions,$min,$max)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    $min||=0;
    return bless [$conditions,$min,$max],$class;
  }
  sub start  {
    my ($self,$parent,$fsfile)=@_;
    $self->[FILE]=$fsfile;
    my $n=$parent->firstson;
    $self->[DEPTH]=1;
    $self->[NODE]=$n;
    return ($self->[MIN]<=1 and $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $min = $self->[MIN];
    my $max = $self->[MAX];
    my $depth = $self->[DEPTH];
    my $conditions=$self->[CONDITIONS];
    my $n = $self->[NODE];
    my $fsfile=$self->[FILE];
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
      if ($n and $min<=$depth and $conditions->($n,$fsfile)) {
	$self->[DEPTH]=$depth;
	return $self->[NODE]=$n;
      }
    }
    return $self->[NODE]=undef;
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }
}
#################################################
{
  package ParentIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;
  sub start  {
    my ($self,$node,$fsfile)=@_;
    $self->[FILE]=$fsfile;
    my $n = $node->parent;
    return $self->[NODE] = ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : undef;
  }
  sub next {
    return $_[0]->[NODE]=undef;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }
}
#################################################
{
  package AncestorIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;
  sub start  {
    my ($self,$node,$fsfile)=@_;
    $self->[FILE]=$fsfile;
    my $n = $node->parent;
    $self->[NODE]=$n;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE]->parent;
    my $fsfile = $self->[FILE];
    $n=$n->parent while ($n and !$conditions->($n,$fsfile));
    return $_[0]->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
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
  use constant FILE=>5;
  sub new  {
    my ($class,$conditions,$min,$max)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    $min||=0;
    return bless [$conditions,$min,$max],$class;
  }
  sub start  {
    my ($self,$node,$fsfile)=@_;
    my $min = $self->[MIN]||1;
    my $max = $self->[MAX];
    $self->[FILE]=$fsfile;
    my $depth=0;
    $node = $node->parent while ($node and ($depth++)<$min);
    $node=undef if defined($max) and $depth>$max;
    $self->[NODE]=$node;
    $self->[DEPTH]=$depth;
    return ($node && $self->[CONDITIONS]->($node,$fsfile)) ? $node : ($node && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $max = $self->[MAX];
    my $depth = $self->[DEPTH]+1;
    return $_[0]->[NODE]=undef if ($depth>$max);
    my $n=$self->[NODE]->parent;
    my $fsfile = $self->[FILE];
    while ($n and !$conditions->($n,$fsfile)) {
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
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }
}

#################################################
{
  package ALexRFIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;
  sub start  {
    my ($self,$node,$fsfile)=@_;
    my $lex_rf = $node->attr('a/lex.rf');
    my $refnode;
    $self->[FILE] = $fsfile;
    if (defined $lex_rf) {
      # $lex_rf=~s/^.*?#//;
      $refnode=PML_T::GetANodeByID($lex_rf,$fsfile);
    }
    return $self->[NODE] = $self->[CONDITIONS]->($refnode,$self->file) ? $refnode : undef;
  }
  sub next {
    return $_[0]->[NODE]=undef;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return PML_T::AFile($_[0]->[FILE]);
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }
}
#################################################
{
  package SimpleListIterator;
  use base qw(Tree_Query::Iterator);
  use constant CONDITIONS=>0;
  use constant NODES=>1;
  use constant FILE=>2;
  sub start  {
    my ($self,$node,$fsfile)=@_;
    $self->[FILE]=$fsfile;
    $self->[NODES] = $self->get_node_list($node);
    my $n = $self->[NODES]->[0];
    return $self->[CONDITIONS]->($n,$self->file) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $nodes = $self->[NODES];
    my $conditions=$self->[CONDITIONS];
    shift @{$nodes};
    my $fsfile = $self->file;
    while ($nodes->[0] and !$conditions->($nodes->[0],$fsfile)) {
      shift @{$nodes};
    }
    return $nodes->[0];
  }
  sub node {
    my ($self)=@_;
    return $self->[NODES]->[0];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODES]=undef;
    $self->[FILE]=undef;
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
        # my $id = $_; # $id=~s/^.*?#//;
        PML_T::GetANodeByID($_,$self->[SimpleListIterator::FILE])
      } TredMacro::ListV($node->attr('a/aux.rf'))];
  }
  sub file {
    return PML_T::AFile($_[0]->[SimpleListIterator::FILE]);
  }
}
#################################################
{
  package ALexOrAuxRFIterator;
  use base qw(SimpleListIterator);
  sub get_node_list  {
    my ($self,$node)=@_;
    return [PML_T::GetANodes($node,$self->[SimpleListIterator::FILE])];
  }
  sub file {
    return PML_T::AFile($_[0]->[SimpleListIterator::FILE]);
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
