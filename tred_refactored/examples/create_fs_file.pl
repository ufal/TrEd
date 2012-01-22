#!/usr/bin/perl
BEGIN {
  use File::Basename;
  use lib dirname($0).'/../tredlib';
  use Treex::PML;
};

my @format=(
'@P form',               # simple FS format header with 4 attributes
'@P lemma',
'@P tag',
'@P afun',
'@N ord');		 # @N - ordering of nodes in the tree


my $fs=
  Treex::PML::Factory->createDocument(		# create a new Document object
    FS => Treex::PML::Factory->createFSFormat(\@format), # with our header
    hint => '${tag}',	        # tooltip when mouse hoovers over a node
    patterns => ['node:${form}','node:${afun}'], # default display stylesheet
    trees => [],		# no trees so far
    backend => 'FS',     # will save as FS (default)
    encoding => 'iso-8859-2'    # file encoding
  );

# create 10 sample trees
my ($root,$node);
foreach (1..10) {
  $root=Treex::PML::Factory->createNode();	# create a new root
  $fs->insert_tree($root,$_-1);
  $root->{form}="#$_";
  $root->{ord}=0;
  foreach (1..4) {
    $node=Treex::PML::Factory->createNode();	# create a new node
    $node->{form}="node-$_";
    $node->{ord}=$_;
    $node->paste_on($root,'ord'); # paste the node on root
  }
}

print STDERR "Saving test.fs\n";
$fs->writeFile('test.fs');     # save the file
