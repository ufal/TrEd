# -*- cperl -*-

unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
require ArabicRemix;

$TrEd::TreeView::DefaultNodeStyle{NodeLabel}=
  [-valign => 'top', -halign => 'right'];


sub get_value_line_hook {
  my ($fsfile,$treeNo)=@_;
  print "Using remix\n";
  my $line=$fsfile->value_line($treeNo);
  $line=~m!^([0-9]+/[0-9]+: )(.*)$!;
  my $no=$1;
  return $no.(ArabicRemix::remix($2));
}

sub get_nodelist_hook {
  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  my ($nodes,$current)=$fsfile->nodes($tree_no,$prevcurrent,$show_hidden);
  print "Using new nodelist\n";
  return [[reverse @$nodes],$current];
}
