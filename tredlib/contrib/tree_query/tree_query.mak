# -*- cperl -*-
package Tree_Query;
use vars qw($this $root);
import TredMacro;
import PML qw(SchemaName);

#include <contrib/support/extra_edit.inc>

{
use strict;

# Setup context
push @TredMacro::AUTO_CONTEXT_GUESSING,
sub { SchemaName() eq 'tree_query' ? __PACKAGE__ : undef };
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

#bind query_sql key space menu Query SQL server
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
  if (EditAttribute($cfg,'',$cfg_type)) {
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
  get_dbi() unless $dbi;
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
  ChangingFile(0);
}

# serialize to SQL (or SQL fragment)
sub serialize_conditions {
  my ($node,$as_id)=@_;
  if ($node->parent) {
    my $sql =  serialize_element( 'and', $node->{conditions}, $as_id );
    return $sql;
  } else {
    my $sql = make_sql($root,0);
  }
}
sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  return unless $fsfile;
  my $tree = $fsfile->tree($treeNo);
  return unless $tree;
  return make_sql($tree,1);
}
sub make_sql {
  my ($tree,$format)=@_;
  my @nodes = $tree->descendants; # we rely on depth first order!
  my @select;
  my @join;
  my @where;
  my $table = 'a';
  my %id = map { ($_ => $_->{name}) } @nodes;
  my $id = 'n0';
  my %occup; @occup{values %id}=();
  for my $n (@nodes) {
    unless (defined $id{$n} and length $id{$n}) {
      $id++ while exists $occup{$id}; # just for sure
      $id{$n}=$id; # generate id;
      $occup{$id}=1;
    }
  };
  for (my $i=0; $i<@nodes; $i++) {
    my $n = $nodes[$i];
    my $id = $id{$n};
    push @select, $id.".id";
    push @join,
      ($i==0 ? " FROM $table AS $id " :
	 " JOIN $table AS $id ON ".
	   ($n->parent->parent ? "$id.parent=".$id{$n->parent}.".id" :
	      "$id.root=n0.root"));
    push @where, Tree_Query::serialize_conditions($n,$id);
  }
  my @sql = (['SELECT '],
      (map {
	(($_==0 ? () : [' ,',"space"]),
	 [$select[$_],$nodes[$_]])
      } 0..$#nodes),
      (map {
	(($_==0 ? () : ["\n ","space"]),
	 [$join[$_],$nodes[$_]])
      } 0..$#nodes),
      join('',@where)!~/\S/ ? () :
      ([ "\nWHERE\n     "],
       map {
	 (($_==0 ? () : ["\n AND ","space"]),
	  [$where[$_],$nodes[$_]])
      } grep {
	my $w = $where[$_];
	defined($w) and length($w)
      } 0..$#nodes),
      [";\n","space"]
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
      s/\"(.*?)\"/$as_id.$1/g;
    }
    return ($value->{negate} ? 'NOT ' : '').
           ($left.' '.uc($value->{operator}).' '.$right);
  } elsif ($name =~ /^(?:and|or)$/) {
   my $seq = $value->{'#content'};
   return () unless (
     UNIVERSAL::isa( $seq, 'Fslib::Seq') and
     @$seq
   );
   return ($value->{negate} ? 'NOT (' : '(').
       	  join(' '.uc($name).' ',map {
	    my $n = $_->name;
	    serialize_element(
	      $n,
	      $_->value,
	      $as_id
	     )
	  } $seq->elements).')';
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
