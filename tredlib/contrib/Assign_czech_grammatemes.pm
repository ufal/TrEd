# Package for automatic assignment
# of attribute wordclass and related grammatemes
# (only for Czech TG trees created from PDT analytical trees)

# written by Zdenek Zabokrtsky, April 2003

package Assign_czech_grammatemes;
use strict;



# mapping from JH's tags to (semantic) word classes
my %POStagRegexp2wordclass = (
			      'N' => 'N',
			      'A' => 'ADJ',
			      'D' => 'ADV',
			      'V' => 'V',
			      'C' => 'NUM'
			     );

sub assign_grammatemes {
  print "Assigning grammatemes\n";
  my ($root)=@_;
  foreach my $node (grep {$_->{TR} ne "hide"} $root->descendants()) {
    # detect wordclass
    foreach my $regexp (keys %POStagRegexp2wordclass) {
      if ($node->{tag}=~/^$regexp/) {
	$node->{wordclass}=$POStagRegexp2wordclass{$regexp};
	last;
      }
      if ($node->{wordclass} eq "") {$node->{wordclass}='???'}
    }
  }
}
