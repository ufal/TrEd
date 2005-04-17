package Extract_node_features;

use Exporter;
@ISA=(Exporter);
@EXPORT = ('extract_edge_features');
#use Fslib;

my @tagpos = qw 'pos subpos verbmod voice XXX pers gender number case defin';

my @attrlist=qw "d_lemma d_pos d_subpos d_verbmod d_voice d_case d_defin d_children i_lemma g_lemma g_pos g_subpos g_verbmod g_voice g_children g_position afun";

### print "##".(join "\t",@attrlist)."\n";

sub add_node_feature ($$$) {
  my ($node,$prefix,$features)=@_;
  if ($node->parent()) { # not the tree root
    my @cats=@tagpos; # categories in tag
    my $tag=$node->{tag};
    while (@cats) {
      my $cat=shift @cats;
      if ($tag=~s/(.)//) { $$features{"$prefix\_$cat"}=$1;}
    }
    $$features{"$prefix\_lemma"}=$node->{x_morph};
    $$features{"$prefix\_children"}=$node->children();
    if ($$features{"$prefix\_children"}>=2) {$$features{"$prefix\_children"}="more"};
  }
  else {
    foreach (@tagpos) {$$features{"$prefix\_$_"}="root"};
    $$features{"$prefix\_children"}=$node->children();
    if ($$features{"$prefix\_children"}>=2) {$$features{"$prefix\_children"}="more"};
  }
}

sub extract_edge_features ($) {
  my ($node)=@_;
  my %features=();
  my $parent=$node;
  my $prep;
  do {
    $parent=$parent->parent();
    if ($parent->{tag}=~/^P/) {
      $prep=$parent;
      $node=$node->parent();
    }
  } while ($parent and $parent->parent() and $parent->{tag}=~/^C/);

  foreach my $attr (@attrlist) {$$features{$attr}='empty'}
  add_node_feature($parent,"g",\%features);
  add_node_feature($prep,"i",\%features) if $prep; # intermediate
  add_node_feature($node,"d",\%features);

  if ($node->{ord}>$parent->{ord}) {$features{g_position}="left"}
  else  {$features{g_position}="right"};
  $features{afun}=$node->{afun};
  return \%features;
}

1;
