# Package for automatic assignment
# of attribute wordclass and related grammatemes
# (only for TG trees generated from Negra)

# written by Zdenek Zabokrtsky, March 2003

package Assign_german_grammatemes;
#import TredMacro;
#use strict;

#use vars qw ($root);

my %wordtag2wordclass = (
			 '^ADJ' => 'ADJ',
			 '^ADV' => 'ADV',
			 '^N' => 'N',
			 '^V' => 'V',
			 '^PPER' => 'P'
			);

my %modal2deontmod=( # deontmod valued derived from modal verb lemma
		    "müssen" => "DEB",
		    "sollen" => "HRT",
		    "wollen" => "VOL",
		    "können" => "POSS",
		    "mögen" => "PERM",
		    "dürfen" => "PERM",
		    "" => "DECL"
		    );

sub assign_grammatemes {
  print "Assigning grammatemes\n";
  my ($root)=@_;
  foreach my $node (grep {$_->{TR} ne "hide"} $root->descendants()) {
      # detect wordclass
      foreach my $regexp (keys %wordtag2wordclass) {
	if ($node->{x_wordtag}=~/$regexp/) {
	  $node->{wordclass}=$wordtag2wordclass{$regexp};
	  last;
	}
      }
      # fill grammatemes relevant for the wordclass

      if ($node->{wordclass} eq "N") { # nouns
	if ($node->{x_morphtag}=~/Pl/) {$node->{number}="PL"}
	else {$node->{number}="SG"};
      }
      elsif ($node->{wordclass}=~/^AD/) { # adjectives and adverbs
	if ($node->{x_morphtag}=~/(COMP|SUP)/) {$node->{degcmp}=uc($1)}
	else {$node->{degcmp}='POS'};
      }
      elsif ($node->{wordclass} eq "V") { # verbs
	$node->{deontmod}=$modal2deontmod{$node->{x_modalverb}};
	if ($node->{x_wordtag} eq "VVPP" and $node->{x_auxverb}=~/(sein|haben)/) {$node->{tense}='ANT'}
	else {$node->{tense}='SIM'};
	$node->{verbmod}="IND";

	if ($node->{x_wordtag} eq 'VAINF') {
	  foreach my $attr ('sentmod','verbmod','deontmod') {$node->{$attr}='NA'}
	}
      }

      if ($node->{x_edgetag_sequence}=~/SB/) {$node->{subject}=1}
    }
}

# sub update_file_header {
#   print "Updating file header\n";
#   AppendFSHeader(
# 		 '@P determination',
# 		 '@L determination|DEF|IND|BARE|NA|???',
# 		 '@P wordclass',
# 		 '@L wordclass|V|N|ADJ|ADV|NUM',
# 		 '@P subject'
# 		);
# }
