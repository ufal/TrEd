# -*- cperl -*-

#include <contrib/pml/PML.mak>

#TODO
#
# - new netgraph _optional semantics?

# - _transitive=exclusive (in NG by default, a query node can lay on
# the transitive edge of other query node; if =exclusive, than no query
# node can lay on the transitive edge and also, the transitive edge
# cannot share nodes with any other exclusive transitive edge (but can
# share nodes with some non-exclusive transitive edge)). Thus,
# exclusivity in NG seems equivalent to creating an optional node
# between the transitive query node and its query parent.

# allow the user to mark the nodes with colours and recognize the
# colored nodes in the result tree

# - _#lbrothers
# - _#rbrothers
# - modify type of the default relation: parent/ancestor/effective_parent/...)
#   (parent and ancestor implemented, TODO: effective_parent)
# - additional relations to existing nodes (of any type except parent and possibly descendant)
#   with possibility to negate them or maybe even using them in propositional formulae
# non-projective edge search

# relations/attributes from external tables:
# tables:
# - T            (tree structure)
# - T_FILEINFO   (currently T_POS)
# - T_ATTRS      (attribute structure, not yet used)
# - T_QUOT       (quot (list))
# - T_GRAM       (grammatemes)
# - T_COREF_GRAM (attribute structure (list))
# - T_COMPL      (attribute structure (list))
# - T_A_AUX      (relation to A_ (list))
# - T_EPARENTS   (relation to T_ (list))


# some helpful predicates:
#  - is_leaf
#

#
# relations and their representation by colors:
# - parent-child: grey
# - ancestor-descendant: light-blue
# - e_parent-e_child: green
# - preceding-following: yellow

package Tree_Query;
BEGIN {
  use vars qw($this $root);
  import TredMacro;
  import PML qw(&SchemaName);
}

Bind 'query_sql' => {
  key => 'space',
  menu => 'Query SQL server',
  changing_file => 0,
};

#include <contrib/support/extra_edit.inc>

{
use strict;

# Setup context
unshift @TredMacro::AUTO_CONTEXT_GUESSING,
sub { 
SchemaName() eq 'tree_query' ? __PACKAGE__ : undef };
sub allow_switch_context_hook {
  return 'stop' if SchemaName() ne 'tree_query';
}

# Setup stylesheet
sub switch_context_hook {
  CreateStylesheets();
  SetCurrentStylesheet('Tree_Query'),Redraw()
    if GetCurrentStylesheet() eq STYLESHEET_FROM_FILE();
}
sub CreateStylesheets{
  unless(StylesheetExists('Tree_Query')){
    SetStylesheetPatterns(<<'EOF','Tree_Query',1);
context:   Tree_Query
rootstyle: #{vertical:0}
node: #{darkblue}${name}
node: <? Tree_Query::serialize_conditions_as_stylesheet($this) ?>
node: #{brown}${description}
EOF
  }
}

my $dbi_config;
my $dbi;
sub get_dbi {
  my ($userlogin) = (getlogin() || ($^O ne 'MSWin32') && getpwuid($<) || 'unknown');
  $dbi_config ||=
  PMLInstance->load({ string => <<"EOF" });
<dbi xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
  <head>
    <schema><pml_schema 
      xmlns="http://ufal.mff.cuni.cz/pdt/pml/schema/" version="1.1">
     <root name="dbi"><structure>
       <member name="driver"><cdata format="NMTOKEN"/></member>
       <member name="host"><cdata format="url"/></member>
       <member name="port"><cdata format="integer"/></member>
       <member name="database"><cdata format="NMTOKEN"/></member>
       <member name="username"><cdata format="NMTOKEN"/></member>
       <member name="password"><cdata format="any"/></member>
     </structure></root>
    </pml_schema></schema>
  </head>
  <driver>Pg</driver>
  <host>localhost</host>
  <port>5432</port>
  <database>treebase</database>
  <username>$userlogin</username>
  <password></password>
</dbi>
EOF
  my $cfg = $dbi_config->get_root;
  my $cfg_type = $dbi_config->get_schema->get_root_type;
  if (EditAttribute($cfg,'',$cfg_type,'password')) {
    $dbi = DBI->connect('dbi:'.$cfg->{driver}.':'.
			"database=".$cfg->{database}.';'.
			"host=".$cfg->{host}.';'.
			"port=".$cfg->{port},
			$cfg->{username},
			$cfg->{password},
			{ RaiseError => 1 }
		       );
  }
  return $dbi;
}
sub query_sql {
  require DBI;
  my $sql = serialize_conditions($root);
  my $max=100;
  #  my @text_opt = eval { require Tk::CodeText; } ? (qw(CodeText -syntax SQL)) : qw(Text);
  $sql = EditBoxQuery(
    "SQL Query",
    $sql,
    'Confirm or Edit the generated SQL Query',
    #    { -widget => \@text_opt },
  );

  if (defined $sql and length $sql) {
    get_dbi() unless $dbi;
    print "Sending query:\n$sql\n...\n";
    my $results = $dbi->selectall_arrayref($sql,{MaxRows=>100, RaiseError=>1});
    print "Displaying results.\n";
    ListQuery("Results",
	      'browse',
	      [map { join '|',@$_ } @$results],
	      [],
	      {buttons=>[qw(Ok)]});
  }
  print "Done.\n";
}

use constant {
  SUB_QUERY => 1,
  GROUP    => 2,
};

my $occurrences_strategy = SUB_QUERY;

# serialize to SQL (or SQL fragment)
sub serialize_conditions {
  my ($node,$as_id)=@_;
  if ($node->parent) {
    my $sql =  serialize_element( 'and', $node->{conditions}, $as_id );
    if ($occurrences_strategy == SUB_QUERY) {
      my @occ_child = grep { defined $_->{occurrences} } $node->children;
      for my $child (@occ_child) {
	my $occ = $child->{occurrences};
	$sql .= " AND $occ=(".make_sql($child,0,1,$as_id).")";
      }
    }
    return $sql;
  } else {
    init_id_map($root);
    return make_sql($root,0);
  }
}
sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  init_id_map($tree);
  return make_sql($tree,1);
}

my %id;
sub init_id_map {
  my ($tree)=@_;
  my @nodes = $tree->descendants;
  %id = map { ($_ => lc($_->{name})) } @nodes;
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

sub make_sql {
  my ($tree,$format,$count,$tree_parent_id)=@_;
  # we rely on depth first order!
  my @nodes;
  if ($occurrences_strategy == SUB_QUERY) {
    my $n = $tree;
    while ($n) {
      if ($n->parent) {
	if (defined $n->{occurrences} and $n!=$tree) {
	  $n = $n->following_right_or_up;
	  next;
	} else {
	  push @nodes, $n;
	}
      }
      $n = $n->following;
    }
  } else {
    @nodes =  grep { $_->parent }  ($tree, $tree->descendants);
  }
  my @select;
  my @join;
  my @where;
  my $table = 'a';


  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $id = $id{$n};
    push @select, $id;
    my $parent = $n->parent;
    my $parent_id = $id{$parent};
    if ($i==0) {
      push @join," FROM $table $id ";
    } else {
      my $join;
      if ($parent->parent) {
	if ($n->{'relation'} eq 'ancestor') {
	  $join.=qq{$id."root_idx"=$parent_id."root_idx" AND }.
	    qq{$id."idx" BETWEEN $parent_id."l" AND $parent_id."r"};
	} elsif ($n->{'relation'} eq 'effective_parent') {
	  # TODO
	  # $join.=qq{$id."parent_idx"=$id{$n->parent}."idx"};
	} elsif ($n->{'relation'} eq 'parent' or
		 $n->{'relation'} eq '') {
	  $join.=qq{$id."parent_idx"=$id{$n->parent}."idx"};
	}
	if ($n->{optional}) {
	  # identify with parent
	  $join = qq{(($join) OR $id."idx"=$parent_id."idx")};
	}
      } else {
	# what do we with _optional here?
	$join .= "$id.root_idx=n0.root_idx";
      }
      push @join, 
	" JOIN $table $id ON ".$join.
	  join('', (map { qq{ AND $id{$_}."idx" != ${id}."idx"} }
		      grep { $_->parent == $n->parent }
		      map { $nodes[$_] } 0..($i-1)));
    }
    my $where = Tree_Query::serialize_conditions($n,$id);
    if ($n->{optional}) {
      if (length $where) {
	$where = qq{(($where) OR $id."idx"=$parent_id."idx")};
      }
    }
    push @where, $where;
  }
  my $i=0;
  my @sql = (['SELECT '],
      ($count ? ['count(1)','space'] : (map {
	(($_==0 ? () : [', ','space']),
	 [$select[$_].'."idx"',$nodes[$_]],
	 [' AS "'.$select[$_].'.idx"','space']
	)
      } 0..$#nodes)),
      (map {
	(($_==0 ? () : ["\n ",'space']),
	 [$join[$_],$nodes[$_]])
      } 0..$#nodes),
      (
       ((defined($tree_parent_id) and defined($id{$tree}) and ++$i) ?
	  ["\nWHERE\n     ".$id{$tree}.'."parent_idx"='.$tree_parent_id.'."idx"','space'] : ()),
       map {
	 (($i++ == 0 ? ([ "\nWHERE\n     ",'space']) : ["\n AND ",'space']),
	  [$where[$_],$nodes[$_]]
	 )
      } (grep {
	  my $w = $where[$_];
	  defined($w) and length($w)
	} 0..$#nodes)),
      ((defined($tree_parent_id) and defined($id{$tree})) ? () : ["\nLIMIT 100;\n",'space'])
    );
  if ($format) {
    return \@sql;
  } else {
    return join '',map { $_->[0] } @sql;
  }
}

sub serialize_element {
  my ($name,$value,$as_id)=@_;
  if ($name eq 'test') {
    my $left = $value->{a};
    my $right = $value->{b};
    for ($left,$right) {
      s/"_[#]descendants"/"r"-"l"/g;
      s/"_[#]sons"/"chld"/g;
      s/"_depth"/"lvl"/g;
      s/(?<![.])(\"[^"]*\")/$as_id.$1/g;
    }
    return ($value->{negate}==1 ? 'NOT ' : '').
           ($left.' '.uc($value->{operator}).' '.$right);
  } elsif ($name =~ /^(?:and|or)$/) {
   my $seq = $value->{'#content'};
   return () unless (
     UNIVERSAL::isa( $seq, 'Fslib::Seq') and
     @$seq
   );
   my $condition = join(' '.uc($name).' ',
			grep { defined and length }
			map {
			  my $n = $_->name;
			  serialize_element(
			    $n,
			    $_->value,
			    $as_id
			   ) } $seq->elements);
   return () unless length $condition;
   return ($value->{negate} ? "NOT ($condition)" :
	   @$seq > 1 ? "($condition)" : $condition);
  } else {
    warn "Unknown element $name ";
  }
}

# serialize to stylesheet
sub serialize_conditions_as_stylesheet {
  my ($node)=@_;
  if ($node->parent) {
    return serialize_element_as_stylesheet( $node, 'conditions', 'and', $node->{conditions} );
  } else {
    return;
  }
}

sub serialize_element_as_stylesheet {
  my ($node,$path,$name,$value)=@_;
  if ($name eq 'test') {
    return ($value->{negate} ? "#{red(}\${$path/negate=NOT}#{)} " : '').
           (
	     "\${$path/a=".$value->{a}."} ".
	     "#{darkblue(}\${$path/operator=".uc($value->{operator})."}#{)} ".
	     "\${$path/b=".$value->{b}."} "
	   );
  } elsif ($name =~ /^(?:and|or)$/) {
   my $seq = $value->{'#content'};
   return () unless (
     UNIVERSAL::isa( $seq, 'Fslib::Seq') and
     @$seq
   );
   my $i=1;
   return ($value->{negate} ? "#{red(}\${$path/negate=NOT}#{)} " : '').
         "#{darkviolet(}\${$path=(}#{)}".
       	  join(' #{darkviolet(}${'.$path.'/#content='.uc($name).'}#{)} ',map {
	    my $n = $_->name;
	    serialize_element_as_stylesheet($node,
			      $path.'/#content/['.($i++).']'.$n,
			      $n,
			      $_->value) } $seq->elements
	  ).
	  "#{darkviolet(}\${$path=)}#{)}";
  }
}

} # use strict
1;
