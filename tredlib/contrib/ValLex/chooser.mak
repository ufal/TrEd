# -*- cperl -*-

#bind ChooseFrame to Ctrl+Return menu Vyber ramec pro sloveso

$FrameData=undef;
unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
print "-=---------------=-\n";
print "INC @INC\n";

sub ChooseFrame {
  require ValLex::Data;
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  my $lemma=$this->{trlemma};
  my $tag=$this->{tag};
  return unless $tag=~/^V/;
  $FrameData=TrEd::ValLex::Data->new("$libDir/contrib/ValLex/vallex.xml") unless ($FrameData);
  my $new_word=0;
  my $word=$FrameData->findWord($lemma);
  unless ($word) {
    if (questionQuery("Word does not exist",
		      "Do you want to add this word to the lexicon?",
		      "Yes", "No") eq "Yes") {
      $word=$FrameData->addWord($lemma,"V");
      $new_word=1;
    } else {
      return;
    }
  }

  my $frame=TrEd::ValLex::Chooser::show_dialog($lemma,ToplevelFrame(),$FrameData,
					       $word,undef,$new_word);
  if ($frame) {
    print "Frame: $frame\n";
    $this->{commentA}=$frame;
  }
}

