# -*- cperl -*-

#ifndef Show_Neigboring_Trees
#define Show_Neigboring_Trees
{
package Show_Neigboring_Trees;
use strict;
BEGIN {
  import TredMacro;
}

my $cfg = QuickPML(
  cfg=> [
    'structure',
    context_before => 'nonNegativeInteger',
    context_after => 'nonNegativeInteger',
   ],
  Fslib::Struct->new({
    context_before=>5,
    context_after=>5,
  }));

sub edit_configuration {
  ToplevelFrame()->TrEdNodeEditDlg({
    title => 'Edit Parameters',
    type => $cfg->schema->get_root_type,
    object => $cfg->get_root,
    search_field => 0,
    focus => 'context_before',
    no_sort=>1,
  });
  ChangingFile(0);
}
sub configure {
  my ($before,$after)=@_;
  for my $c (get_config()) {
    $c->{context_before}=int($before);
    $c->{context_after}=int($after);
  }
}
sub get_config {
  return $cfg->get_root;
}


DeclareMinorMode 'Show_Neigboring_Trees' => {
  abbrev => 'neigh_trees',
  configure => \&edit_configuration,
  post_hooks => {
    get_nodelist_hook => sub {
      my ($fsfile,$no,$prevcurrent,$show_hidden)=@_;
      my ($context_before,$context_after) =
	map { $_->{context_before}, $_->{context_after} } get_config();
      my $from=max(0,$no-$context_before);
      my $to=min($no+$context_after,$fsfile->lastTreeNo);
      my $sub = UNIVERSAL::can(CurrentContext(),'get_nodelist_hook')
	|| UNIVERSAL::can('TredMacro','get_value_line_hook');
      my $attr=FS->order();
      my ($nodes,$current);
      my $l = $_[-1];
      if (ref($l) eq 'ARRAY' and @$l==2) {
	($nodes,$current)=@$l;
      } else {
	$nodes=[];
	undef $l;
      }
      for my $i (reverse ($from..$no-1),
		 ($l ? () : $no),
		 $no+1..$to) {
	my @unsorted;
	my ($res,$cur);
	if ($sub) {
	  ($res,$cur)=$sub->($fsfile,$i,$prevcurrent,$show_hidden);
	} else {
	  ($res,$cur)=$fsfile->nodes($i,$prevcurrent,$show_hidden);
	}
	$current=$cur if ($i==$no);
	if ($i<$no) {
	  unshift @$nodes, @$res;
	} else {
	  push @$nodes,@$res;
	}
      }
      $current ||= $fsfile->tree($no);
      $_[-1] = [$nodes,$current];
    }
  },
};

}
1;

#endif Show_Neigboring_Trees
