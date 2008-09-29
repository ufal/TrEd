# -*- cperl -*-

#ifndef Show_Neighboring_Sentences
#define Show_Neighboring_Sentences
{
package Show_Neighboring_Sentences;

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
    object => get_config(),
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

DeclareMinorMode 'Show_Neighboring_Sentences' => {
  abbrev => 'neigh_sent',
  configure => \&edit_configuration,
  post_hooks => {
    get_value_line_hook => sub {
      my ($fsfile,$no)=@_;
      if (!defined $_[-1]) {
	# value line not supplied by hook, we provide the standard one
	$_[-1] = $grp->treeView->value_line($fsfile,$no,1,1,$grp);
      } elsif (!ref($_[-1])) {
	$_[-1] = [[$_[-1]]];
      }
      my $vl =  $_[-1];
      unshift @$vl,['--> ',$fsfile->tree($no)];
      push @$vl,["\n"];
      my $sub = UNIVERSAL::can(CurrentContext(),'get_value_line_hook')
	|| UNIVERSAL::can('TredMacro','get_value_line_hook');
      my ($before,$after) =
	map { $_->{context_before}, $_->{context_after} } get_config();
      my $first = max($no-$before,0);
      my $last = min($no+$after,$fsfile->lastTreeNo);
      for my $i (reverse($first..$no-1), $no+1..$last) {
	my $res = $sub && $sub->($fsfile,$i);
	$res = $grp->treeView->value_line($fsfile,$i,1,1,$grp)
	  unless defined($res);
	if ($i>$no) {
	  push @$vl,
	    map { push @$_,'-foreground => #777'; $_ }
	    (ref($res) ? @$res : [$res]), ["\n"];
	} else {
	  unshift @$vl,
	    map { push @$_,'-foreground => #777'; $_ }
	    (ref($res) ? @$res : [$res]),["\n"];
	}
      }
      # return $vl;
    },
    value_line_doubleclick_hook => sub {
      my $res = $_[-1];
      my %tags; @tags{@_[0..$#_-1]}=();
      if ($res ne 'stop' and !ref($res)) {
	my ($before,$after) =
	  map { $_->{context_before}, $_->{context_after} } get_config();
	my $fsfile=CurrentFile();
	my $no = CurrentTreeNumber();
	my $first = max($no-$before,0);
	my $last = min($no+$after,$fsfile->lastTreeNo);
	for my $i (reverse($first..$no-1), $no+1..$last) {
	  my $tree = $fsfile->tree($i);
	  while ($tree) {
	    if (exists $tags{"$tree"}) {
	      GotoTree($i+1);
	      $this=$tree;
	      Redraw();
	      $_[-1]='stop';
	    }
	    $tree=$tree->following;
	  }
	}
      }
    },
  },
};

}
1;

#endif Show_Neighboring_Trees
