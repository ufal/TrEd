#!/usr/bin/perl

die "Usage: $^0 <input-file>\n" if @ARGV<1;

use FindBin;

push @INC,"$FindBin::RealBin","$FindBin::RealBin/../..";

require Data;
require LibXMLData;
require TrEd::CPConvert;

my $conv= TrEd::CPConvert->new("utf-8",
			       "iso-8859-2");
print STDERR "Parsing...\n";

my $data=TrEd::ValLex::LibXMLData->new($ARGV[0],$conv);

print STDERR "Creating report...\n";

my ($output1,$output2);
foreach my $entry ($data->getWordList()) {
  my ($word,$id,$lemma,$pos)=@$entry;
  $output1='';
  $output2='';
  $output1.="\n--- $lemma ";
  $output1.="-" x (20-length($lemma));
  $output1.=" $id ";
  $output1.="-" x (14-length($id));
  $output1.="\n";

  my @frames=$data->getFrameList($word);

  @ML_frames=grep { $_->[5] eq 'ML' or ($_->[5] eq 'ZU' and $_->[1] !~ /ZU/ )} @frames;

  $output1.= "original:\n";
  foreach my $f (@ML_frames) {
    my ($frame,$frame_id,$elements,$status,$example,$auth,$note)=@$f;
    $example="\n$example" if ($example ne "");
    $example =~ s/\n/\n  \t  /g;
    $output1.= "  $frame_id: ($auth)\n  \t$elements$example\n";
  }
  $output1.= "changes:\n";
  foreach my $f (@frames) {
    my ($frame,$frame_id,$elements,$status,$example,$auth,$note)=@$f;
    $example="\n$example" if ($example ne "");
    $example =~ s/\n/\n  \t  /g;
    if ($auth ne "ML") {
      $output2.= "  $frame_id:  --> added ($auth=".
	$data->conv()->decode($data->get_user_info($auth)->[0]).
	  ")\n  \t$elements$example\n";
    }
    if ($status eq 'obsolete') {
      my ($who)=$frame->findnodes("./local_history/local_event[\@type_of_event='obsolete']");
      unless (!$who and $auth eq 'ZU') { 
	$output2.= "  $frame_id:  --> obsolete (".$who->getAttribute('author')."=";
	$output2.= $data->conv()->decode($data->get_user_info($who->getAttribute('author'))->[0]) if ($who);
	$output2.= ")\n";
      }
    } elsif ($status eq 'substituted') {
      my ($who)=$frame->findnodes("./local_history/local_event[\@type_of_event='obsolete']");
      $output2.= "  $frame_id:  --> substituted with ".
	$data->getSubstitutingFrame($frame)." (".$who->getAttribute('author')."=";
      $output2.= $data->conv()->decode($data->get_user_info($who->getAttribute('author'))->[0]) if ($who);
      $output2.= ")\n";
    }
  }
  print ($output1,$output2) if $output2 ne "";
}

print STDERR "Done.\n";

1;
