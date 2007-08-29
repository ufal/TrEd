# -*- cperl -*-
package Tree_Query;
use vars qw($this $root);
import TredMacro;

#bind print_serialized_condition key space menu "Serialize condition of the current node"
#include <contrib/support/extra_edit.inc>

{ use strict;

sub print_serialized_condition {
  print "CONDITION: ",serialize_conditions($this),"\n";
  ChangingFile(0);
}

sub serialize_conditions {
  my ($node,$as_id)=@_;
  if ($node->parent) {
    my $sql =  serialize_element( 'and', $node->{conditions}, $as_id );
    return $sql;
  } else {
    my @nodes = $node->descendants; # we rely on depth first order!
    my @select;
    my @join;
    my @where;
    my $table = 'a';
    my %id = map { ($_ => $_->{id}) } @nodes;
    my $id = 'n0';
    my %occup; @occup{values %id}=();
    for my $n (@nodes) {
      unless (defined $id{$n}) {
	$id++ while exists $occup{$id}; # just for sure
	$id{$n}=$id; # generate id;
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
    @where = grep {defined && length} @where;
    my $sql = "SELECT ".join(",",@select)."\n ".
      join("\n ",@join).
      (join('',@where)=~/\S/ ? "\nWHERE\n     ".join("\n AND ",@where) : ()).
      ";\n";
    return $sql;
  }
}
sub serialize_conditions_attr {
  my ($node)=@_;
  if ($node->parent) {
    return serialize_element_attr( $node, 'conditions', 'and', $node->{conditions} );
  } else {
    return;
  }
}

my %op_map = (
   like => ' LIKE ',
   similar => 'SIMILAR',
);

sub serialize_element {
  my ($name,$value,$as_id)=@_;
  if ($name eq 'test') {
    my $op = $value->{operator};
    $op = $op_map{$op} if exists $op_map{$op};
    my $left = $value->{a};
    my $right = $value->{b};
    for ($left,$right) {
      s/\"(.*?)\"/$as_id.$1/g;
    }
    return ($value->{negate} ? 'NOT ' : '').
           ($left. $op. $right);
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

sub serialize_element_attr {
  my ($node,$path,$name,$value)=@_;
  if ($name eq 'test') {
    my $op = $value->{operator};
    $op = $op_map{$op} if exists $op_map{$op};
    return ($value->{negate} ? "#{red(}\${$path/negate=NOT}#{)} " : '').
           (
	     "\${$path/a=".$value->{a}."} ".
	     "#{darkblue(}\${$path/operator=".$op."}#{)} ".
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
	    serialize_element_attr($node,
			      $path.'/#content/['.($i++).']'.$n,
			      $n,
			      $_->value) } $seq->elements
	  ).
	  "#{darkviolet(}\${$path=)}#{)}";
  }
}

} # use strict
1;
