package Extract_node_features;

use Exporter;
@ISA=(Exporter);
@EXPORT = ('extract_edge_features');
#use Fslib;

sub add_node_feature ($$$) {
  my ($node,$prefix,$features)=@_;
  if ($node->parent()) { # not the tree root
    $$features{"$prefix\_lemma"}=$node->{lemma};
    my $tag=$node->{tag};
    $tag=~s/^([^+]+)\+?//;
    $$features{"$prefix\_taghead"}=$1;
    $$features{"$prefix\_tagtail"}=$tag;
    $$features{"$prefix\_children"}=$node->children();
    if ($$features{"$prefix\_children"}>=2) {$$features{"$prefix\_children"}="more"};
  }
  else {
    foreach ("lemma","taghead","tagtail") {$$features{"$prefix\_$_"}="root"};
    $$features{"$prefix\_children"}=$node->children();
    if ($$features{"$prefix\_children"}>=2) {$$features{"$prefix\_children"}="more"};
  }
}

sub extract_edge_features ($) {
  my ($node)=@_;
  my $son=$node;
  my %features=();
  add_node_feature($node,"d",\%features);
  $features{afun}=$node->{afun};
  do {
    $node=$node->parent();
    if ($node->{tag} eq "PREP") {
      add_node_feature($node,"i",\%features);
      $node=$node->parent();
    }
  } while ($node and $node->parent() and $node->{tag} eq "CONJ");
  add_node_feature($node,"g",\%features);
  if ($features{'i_tag'} eq "") {
    foreach my $attr ('children','lemma','taghead','tagtail') {$features{"i\_$attr"}="empty"}
  }
  if ($son->{ord}>$node->{ord}) {$features{g_position}="left"}
  else  {$features{g_position}="right"};
  return \%features;
}



1;

