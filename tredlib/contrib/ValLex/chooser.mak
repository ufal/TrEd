# -*- cperl -*-

#bind ChooseFrame to Ctrl+Return menu Vyber ramec pro sloveso

$FrameData=undef;

sub ChooseFrame {
  require ValLex::Data;
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  my $lemma=$this->{trlemma};
  $FrameData=TrEd::ValLex::Data->new("$libDir/contrib/ValLex/pokus.xml") unless ($FrameData);
  my $word=$FrameData->findWord($lemma);
  my $frame=TrEd::ValLex::Chooser::show_dialog($lemma,ToplevelFrame(),$FrameData,$word);
  if ($frame) {
    print "Frame: $frame\n";
    $this->{commentA}=$frame;
  }
}
