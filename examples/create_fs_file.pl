#!/usr/bin/perl
BEGIN {
  use File::Basename;
  use lib dirname($0).'/../tredlib';
  use Fslib;
};

my @format=(
'@P form',               # simple FS format header with 4 attributes
'@P lemma',
'@P tag',
'@P afun',
'@N ord');		 # @N - ordering of nodes in the tree


my $fs=
  FSFile->create(		# create a new FSFile object
    FS => FSFormat->create(@format), # with our header
    hint => '${tag}',	        # tooltip when mouse hoovers over a node
    patterns => ['node:${form}','node:${afun}'], # default display stylesheet
    trees => [],		# no trees so far
    backend => 'FSBackend',     # will save as FS (default)
    encoding => 'iso-8859-2'    # file encoding
  );

# create 10 sample trees
my ($root,$node);
foreach (1..10) {
  $root=$fs->new_tree($_-1);	# create a new root
  $root->{form}="#$_";
  $root->{ord}=0;
  foreach (1..4) {
    $node=FSNode->new();	# create a new node
    $node->{form}="node-$_";
    $node->{ord}=$_;
    Fslib::Paste($node,$root,$fs->FS); # paste the node on root
  }
}

print STDERR "Saving test.fs\n";
$fs->writeFile('test.fs');     # save the file
