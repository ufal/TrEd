package Assign_arab_afun;

use Extract_node_features;
use Arab_special_chars; # module for substituting  special characters with sequences
use Arab_afun_dec_tree; # decision tree for assigning of the analytical function
#use strict;
#use Fslib;

my %frequent;
open F,$TredMacro::libDir."/contrib/PADT/most_freq_200"
  or warn "Can't find the most frequent lemmas (most_freq_200)!";
while (<F>) {chomp; $frequent{$_}=1}

sub afun($)  {
  my ($fsnode)=@_;
  my $attributes=extract_edge_features($fsnode);
  foreach my $attrname (grep {/lemma/} keys %$attributes) {
    $$attributes{$attrname}="other_lemma" unless $frequent{$$attributes{$attrname}}
  }
  @$attributes{keys %$attributes} = special_chars_off(values %$attributes);
  my %a=%$attributes;
#  print STDERR ("Assignafun (node $fsnode->{lemma}): ".(join " ",(map {"$_=$a{$_}"} keys %a))."\n\n");
  return Arab_afun_dec_tree::evalTree($attributes);
  }
1;

