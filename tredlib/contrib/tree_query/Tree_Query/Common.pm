package Tree_Query::Common;
# pajas@ufal.ms.mff.cuni.cz          01 èec 2008

use 5.006;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use PMLSchema;

# sub first (&@); # prototype it for compile-time
use List::Util qw(first);

#BEGIN {
#  import TredMacro qw(uniq SeqV AltV ListV)
#}

sub uniq  { my %a; grep { !($a{$_}++) } @_ }
sub AltV  { ref($_[0]) eq 'Fslib::Alt' ? @{$_[0]} : $_[0] }
sub ListV { ref($_[0]) eq 'Fslib::List' ? @{$_[0]} : () }
sub SeqV  { ref($_[0]) eq 'Fslib::Seq' ? $_[0]->elements : () }

require Exporter;
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Tree_Query::Common ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
  tq_serialize
  as_text
  occ_as_text
  rel_as_text
  _group
  make_string
  make_string_with_tags
  query_parser
  parse_query
  parse_expression
  parse_column_expression
  cmp_subquery_scope

  SetRelation
  GetRelationTypes
  FilterQueryNodes
  Schema
) ],
  'tredmacro' => [ qw(
    first uniq ListV AltV SeqV
  )],
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} },  @{ $EXPORT_TAGS{'tredmacro'} } );

our @EXPORT = qw(  );

our $VERSION = '0.01';

# Preloaded methods go here.

my $query_schema = PMLSchema->new({filename => 'tree_query_schema.xml',use_resources=>1});
sub Schema {
  return $query_schema;
}

sub GetQueryNodeType {
  my ($node,$type_mapper)=@_;
  my $p;
  return unless $node;
  $node=$p while (($p=$node->parent) && $node->{'#name'} !~ /^(?:node|subquery)$/);
  if ($type_mapper) {
    return $node->{'node-type'} ||
      ($p &&
      ( wantarray
	  ? (uniq map GetRelativeQueryNodeType($_,$type_mapper,SeqV($node->{relation})), GetQueryNodeType($p,$type_mapper))
	  : GetRelativeQueryNodeType(scalar(GetQueryNodeType($p,$type_mapper)),$type_mapper,SeqV($node->{relation}))));
  } else {
    return $node->{'node-type'} || $node->root->{'node-type'};
  }
}


sub DeclPathToQueryType {
  my ($path) = @_;
  return unless defined $path;
  $path=~s/\[LIST\]/LM/;
  $path=~s/\[ALT\]/AM/;
  $path=~s{^!([^/]+)\.type\b}{$1};
  return $path;
}
sub QueryTypeToDecl {
  my ($type,$schema)=@_;
  return unless $type and $schema;
  $type=~s{(/|$)}{.type$1};
  return $schema->find_type_by_path('!'.$type)
    or die "Did not find type '!$type'";
}

my %type = (
  't-root:user-defined:a/lex.rf' => 'a-root',
  't-root:user-defined:a/lex.rf|a/aux.rf' => 'a-root',
  ':user-defined:a/lex.rf' => 'a-node',
  ':user-defined:a/aux.rf' => 'a-node',
  ':user-defined:a/lex.rf|a/aux.rf' => 'a-node',
  ':user-defined:val_frame.rf' => 'frame',
  ':user-defined:coref_text' => 't-node',
  ':user-defined:coref_gram' => 't-node',
  ':user-defined:compl' => 't-node',
  ':user-defined:echild' => '#same',
  ':user-defined:eparent' => '#same',

  ':descendant' => '#descendant',
  ':ancestor' => '#ancestor',
  ':child' => '#child',
  ':parent' => '#parent',
  ':depth-first-precedes' => '#any',
  ':order-precedes' => '#any',
);

sub GetRelativeQueryNodeType {
  my ($type,$type_mapper,$rel)=@_;
  $type ||= '';
  print "type: $type\n";
  # TODO: if $type is void, we could check if there is just one node-type in the schema and return it if so
  my $name = $rel ? $rel->name : 'child';
  $name .= ':'.$rel->value->{label} if $name eq 'user-defined';
  my $reltype = $type{$type.':'.$name} || $type{':'.$name};
  my @t;
  if ($reltype eq '#same') {
    return $type ? $type : ();
  } elsif ($reltype =~ /^(#ancestor|#any)/) {
    my $schema = $type_mapper->get_schema_for_type($type)
      or return;
    @t=$schema->node_types;
  } elsif ($reltype eq '#descendant') {
    my $schema = $type_mapper->get_schema_for_type($type)
      or return;
    my $t = QueryTypeToDecl($type,$schema);
    @t = ($t->get_childnodes_decls);
    my %seen = map { $_=>1 } @t;
    my $i=0;
    while ($i<@t) {
      for $t ($t[$i]->get_childnodes_decls) {
	if (!$seen{$t}) {
	  push @t, $t;
	  $seen{$t}=1;
	}
      }
      $i++;
    }
  } elsif ($reltype eq '#child') {
    my $schema = $type_mapper->get_schema_for_type($type)
      or return;
    @t = QueryTypeToDecl($type,$schema)->get_childnodes_decls;
  } elsif ($reltype eq '#parent') {
    my $schema = $type_mapper->get_schema_for_type($type)
      or return;
    my $decl = QueryTypeToDecl($type,$schema);
    return unless $decl;
    @t = uniq grep {
      first { $_==$decl } $_->get_childnodes_decls
    } $schema->node_types;
  } else {
    return $reltype;
  }
  print @t,"\n";
  print "wantarray", wantarray(),"\n";
  return if !wantarray and @t!=1;
  @t = map DeclPathToQueryType( $_->get_decl_path ),
    map { ($_->get_decl_type == PML_ELEMENT_DECL) ? $_->get_content_decl : $_ } @t;
  print "@t\n";
  return wantarray ? @t : $t[0];
}

sub SetRelation {
  my ($node,$type,$opts)=@_;
  if ($type=~s/ \(user-defined\)$// and !($opts and $opts->{label})) {
    $opts||={};
    $opts->{label}=$type;
    $type = 'user-defined';
  }
  my $rel = Fslib::Seq::Element->new( 
    $type => Fslib::Container->new(undef,$opts) 
  );
  $node->{relation}||=Fslib::Seq->new();
  @{$node->{relation}->elements_list}=( $rel );
  return $rel;
}

sub GetRelationTypes {
  my ($node)=@_;
  [
    map {
      my $name = $_->get_name;
      if ($name eq 'user-defined') {
	(map { qq{$_ ($name)} } $_->get_content_decl->get_attribute_by_name('label')->get_content_decl->get_values())
      } else {
	$name;
      }
    } $node->type->schema->get_type_by_name('q-ref-relation.type')->get_content_decl->get_elements(),
   ],
}

sub FilterQueryNodes {
  my ($tree)=@_;
  my @nodes;
  my $n = $tree;
  while ($n) {
    my $name = $n->{'#name'}||'';
    if ($name eq 'node' or
	  ($n==$tree and $name eq 'subquery')) {
      push @nodes, $n;
    } elsif ($n->parent) {
      $n = $n->following_right_or_up($tree);
      next;
    }
    $n = $n->following($tree);
  }
  return @nodes;
}

### Query serialization

sub cmp_subquery_scope {
  my ($node,$ref_node) = @_;
  return 0 if $node==$ref_node;
  while ($node->parent and $node->{'#name'} ne 'subquery') {
    $node=$node->parent;
  }
  while ($ref_node->parent and $ref_node->{'#name'} ne 'subquery') {
    $ref_node=$ref_node->parent;
  }
  return 0 if $node==$ref_node;
  return 1 if first { $_==$ref_node } $node->ancestors;
  return -1;
}

sub occ_as_text {
  my ($node)=@_;
  return '' unless ($node->{'#name'}||'') eq 'subquery';
  return join('|', grep { /\d/ } map {
    my ($min,$max)=($_->{min},$_->{max});
    $min='' if !defined $min;
    $max='' if !defined $max;
    if (length($min) and length($max)) {
      if (int($min)==int($max)) {
	int($min)
      } else {
	int($min).'..'.int($max)
      }
    } elsif (length($min)) {
      int($min).'+'
    } elsif (length($max)) {
      int($max).'-'
    } else {
      '1+'
    }
  } AltV($node->{occurrences}));
}


my %child_order = (
  test=>1,
  not=>2,
  or=>3,
  and=>4,
  ref=>5,
  subquery=>6,
  node=>7,
);

sub sort_children_by_node_type {
  my ($node)=@_;
  return map { $_->[0] }
         sort { $a->[1]<=>$b->[1] }
         map { [$_,int($child_order{$_->{'#name'}})] } $node->children;
}

sub rel_as_text {
  my ($node)=@_;
  my ($rel) = SeqV($node->{relation});
  if ($rel) {
    my ($rn,$rv)=($rel->name,$rel->value);
    if ($rn eq 'user-defined') {
      return $rv->{label};
    } elsif ($rn =~ /^(?:ancestor|descendant)/
	       and
		 (defined($rv->{min_length}) && length($rv->{min_length}))||
		 (defined($rv->{max_length}) && length($rv->{max_length}))) {
      return $rn.'{'.($rv->{min_length}||'').','.($rv->{max_length}||'').'}'
    } else {
      return $rn;
    }
  } else {
    return 'child';
  }
}

sub tq_serialize {
  my ($node,$opts)=@_;
  my $indent = $opts->{indent};
  my $do_wrap = $opts->{wrap};
  my $query_node = $opts->{query_node};
  my $name = $node->{'#name'};
  $indent||='';
  my @ret;
  my $wrap=($do_wrap||0) ? "\n$indent" : " ";
  if (!(defined $name and length $name) and !$node->parent) {
    my $desc = $node->{description}||'';
    return [
      [(length($desc) ? '#  '.$desc."\n" : ''),$node],
      ($opts->{no_childnodes} ? () : (map { (@{tq_serialize($_,$opts)},[";\n"]) } $node->children)),
      map {
	[join('',
	      '  >> ',
	      (ListV($_->{'group-by'}) ? (' for ',join(',',ListV($_->{'group-by'})),"\n     give ")  : ()),
	      ($_->{distinct} ? ('distinct ')  : ()),
	      join(',',ListV($_->{return})),
	      (ListV($_->{'sort-by'}) ? ("\n     sort by ",join(',',ListV($_->{'sort-by'})))  : ()),
	      "\n"
	     ), $node]
      } ListV($node->{'output-filters'})
     ]
  } else {
    my $copts = {%$opts,no_childnodes=>0,indent=>$indent."     "};
    if ($name eq 'subquery' or $name eq 'node') {
      $copts->{query_node}=$node;
    }
    my @r = map [tq_serialize($_,$copts)], 
      $opts->{no_childnodes} ? (grep { $_->{'#name'} ne 'node' } $node->children) : $node->children;
    if ($name=~/^(?:not|or|and)$/) {
      if ($name eq 'not') {
	push @ret,['!',$node,$query_node,'-foreground=>darkcyan'];
	$name='and';
      }
      if (@r) {
	push @ret,( @r==1 ? $r[0] : (['(',$node,$query_node,'-foreground=>darkcyan'],
				     @{_group(\@r,["${wrap}$name ",$node,$query_node,'-foreground=>darkcyan'])},
				     [')',$node,$query_node,'-foreground=>darkcyan']) );
      }
    } elsif ($name eq 'ref') {
      my $rel=rel_as_text($node);
      my $arrow = $rel;
      $arrow=~s/{.*//;
      my $color=ref($opts->{arrow_colors}) ? $opts->{arrow_colors}{$arrow} : ();
      push @ret,
	[$rel.' ',$node,$query_node,($color ? ('-foreground=>'.$color) : ())];
      my $ref = $node->{target} || '???';
      push @ret,["\$$ref",$node,$query_node,'-foreground=>darkblue'];
    } elsif ($name eq 'test') {
      my $test=  $node->{a}.' '.$node->{operator}.' '.$node->{b};
      @ret = ( [$test,$node,$query_node] );
    } elsif ($name eq 'subquery' or $name eq 'node') {
      if ($name eq 'subquery') {
	push @ret, [occ_as_text($node).'x ',$node,'-foreground=>darkgreen'];
      } elsif ($node->{optional}) {
	push @ret, ['?',$node,'-foreground=>darkgreen'];
      }
      my $rel='';
      if ($node->parent and $node->parent->parent) {
	$rel=rel_as_text($node);
	my $arrow = $rel;
	$arrow=~s/{.*//;
	my $color=ref($opts->{arrow_colors}) ? $opts->{arrow_colors}{$arrow} : ();
	push @ret,[$rel.' ',$node,($color ? ('-foreground=>'.$color) : ())];
      }
      my $type=$node->{'node-type'}; # get_query_node_type($node);
      push @ret,[$type.' ',$node] if $type; #FIXME: 
      if ($node->{name}) {
	push @ret,['$'.$node->{name},$node,'-foreground=>darkblue'],[' := ',$node];
      }
      if ($do_wrap) {
	if (@r) {
	  push @ret, (["[ ",$node],["${wrap}  "],
		      @{_group(\@r,[",${wrap}  "])},
		      ["${wrap}"],[" ]",$node]);
	} else {
	  push @ret, (["[ ]",$node]);
	}
      } else {
	unshift @ret,["\n${indent}"] if $node->lbrother;
	if (@r) {
	  push @ret,["\n${indent}"],["[ ",$node],
	    @{_group(\@r,[", ",$node])},
	      [" ]",$node];
	} else {
	  push @ret, (["[ ]",$node]);
	}
      }
    } else {
      @ret = (['## unknown: '.$name,$node]);
    }
  }
  return \@ret;
}

sub as_text {
  my ($node,$opts)=@_;
  make_string(tq_serialize($node,$opts));
}

sub _group {
  my ($array,$and_or) = @_;
  return [ map {
    ($_==0) ? ($array->[$_]) : ($and_or,$array->[$_])
  } 0..$#$array ];
}

sub make_string {
  my ($array) = @_;
  Carp::cluck "not an array" unless ref($array) eq 'ARRAY';
  return join '', map {
    ref($_->[0]) ? make_string($_->[0]) : $_->[0]
  } @$array;
}

sub make_string_with_tags {
  my ($array,$tags) = @_;
  return [map {
    ref($_->[0]) ? @{make_string_with_tags($_->[0],[uniq(@$tags,@{$_}[1..$#$_])])} : [$_->[0], uniq(@$tags,@{$_}[1..$#$_])]
  } @$array];
}

### Query parsing

my $parser;
sub query_parser {
  return $parser if defined $parser;
#  my $Grammar = $main::libDir."/contrib/tree_query/Grammar.pm";
  my $Grammar = $INC{'Tree_Query/Common.pm'}; $Grammar=~s{Common.pm$}{Grammar.pm};
  delete $INC{$Grammar};
  require $Grammar;
  $Tree_Query::user_defined = 'echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_text|coref_gram|compl|val_frame.rf';
  $parser = Tree_Query::Grammar->new() or die "Could not create parser for Tree_Query grammar\n";
  return $parser;
}
sub parse_query {
  shift if @_>1;
  my $ret = eval {query_parser()->parse_query($_[0])};
  confess($@) if $@;
  $ret->set_type($query_schema->find_type_by_path('!q-query.type'));
  return $ret;
}
sub parse_expression {
  shift if @_>1;
  my $ret = eval { query_parser()->parse_expression($_[0]) };
  confess($@) if $@;
  return $ret;
}
sub parse_column_expression {
  shift if @_>1;
  my $ret = eval { query_parser()->parse_column_expression($_[0]) };
  confess($@) if $@;
  return $ret;
}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Tree_Query::Common - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Tree_Query::Common;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Tree_Query::Common,
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

