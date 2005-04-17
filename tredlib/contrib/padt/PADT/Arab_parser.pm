#!/bin/bash
# -*- cperl -*-

package Arab_parser;

use Detect_arab_dependencies;
use Arab_special_chars;
use Fslib;

my %frequent;
open F,$TredMacro::libDir."/contrib/padt/PADT/most_freq_200"
  or warn "Can't find the most frequent lemmas (most_freq_200)!";
while (<F>) {chomp; $frequent{$_}=1};
close F;

sub add_node_feature ($$$) {
  my ($node,$prefix,$features)=@_;
  $$features{"$prefix\_lemma"}=$node->{lemma};
  my $tag=$node->{tag};
  $tag=~s/\:.+//;
  if ($tag=~s/^DET\+//) {$$features{"$prefix\_det"}="det"}
  else {$$features{"$prefix\_det"}="nodet"};
  $tag=~s/^([^+]+)\+?//;
  $$features{"$prefix\_taghead"}=$1;
  $$features{"$prefix\_tagtail"}=$tag;
  if ($node->{ord}==1) {$$features{"$prefix\_position"}="leftmost"}
  elsif (not $node->following()) {$$features{"$prefix\_position"}="righttmost"}
  else {$$features{"$prefix\_position"}="middle"}
}

sub parse_sentence($$) {
  my ($grp,$root)=@_;
  print STDERR "Parsing sentence...";
  my @allnodes=sort {$a->{ord}<=>$b->{ord}} $root->descendants();
  my %ord2fs;
  foreach my $node (@allnodes) {
    $ord2fs{$node->{ord}}=$node;
    $node->{orig_parent}=$node->parent()->{ord};
  }
  my @parentless=@allnodes;

  # performing reductions from right to left
  my $index=1;
  while ($index>0) {
      @parentless=grep {not $_->{new_parent}} @parentless;
      $index=$#parentless;
      my $success=0;
      while ($index>0 and not $success) {
	my $bnode=$parentless[$index];
	my $anode=$parentless[$index-1];

	# creating feature vector
	my %features;
	add_node_feature($anode,"a",\%features);
	add_node_feature($bnode,"b",\%features);
	if (1+$anode->{ord}==$bnode->{ord}) {$features{immediate_neighbors}="yes"}
	else  {$features{immediate_neighbors}="no"};
	foreach my $attrname (grep {/lemma/} keys %features) {
	  $features{$attrname}="other_lemma" unless $frequent{$features{$attrname}};
	  ($features{$attrname})=special_chars_off($features{$attrname});
	}

	# dependency detection
	my ($dependency,$x,$y)=Detect_arab_dependencies::evalTree(\%features);
	if (($y/($x+0.001))>0.50) {$dependency="none"};
	if ($dependency eq "left") {
	  $anode->{new_parent}=$bnode;
	  $success=1;
	}
	elsif ($dependency eq "right") {
	  $bnode->{new_parent}=$anode;
	  $success=1
	}
	else {$index--}
      };
    }

  # hanging the remaining nodes on the sentence root
  foreach my $node  (grep {not $_->{new_parent}} @allnodes) {$node->{new_parent}=$root};

  # splitting the original tree structure
  foreach my $node (@allnodes) {Cut($node)};

  # hanging nodes according to the detected dependencies
  foreach my $node (@allnodes) {  PasteNode($node,$node->{new_parent}) }

  print STDERR "Done.\n";
}

1;
