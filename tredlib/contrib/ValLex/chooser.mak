# -*- cperl -*-

#bind ChooseFrame to Ctrl+Return menu Vyber ramec pro sloveso

$FrameData=undef;
unshift @INC,"$libDir/contrib" unless (grep($_ eq "$libDir/contrib", @INC));
print "-=---------------=-\n";
print "INC @INC\n";

sub ChooseFrame {
  my $top=ToplevelFrame();

  require ValLex::Data;
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  require TrEd::CPConvert;
  my $lemma=$this->{trlemma};
  my $tag=$this->{tag};
  return unless $tag=~/^V/;
  $lemma=~s/_/ /g;
  $top->Busy(-recurse=>1);
  my $conv= TrEd::CPConvert->new("utf-8",
				 ($^O eq "MSWin32") ?
				 "windows-1250":
				 "iso-8859-2");
  $FrameData=
    TrEd::ValLex::Data->new("$libDir/contrib/ValLex/vallex.xml",$conv)
      unless ($FrameData);
  my $new_word=0;
  my $word=$FrameData->findWord($lemma);
  $top->Unbusy(-recurse=>1);
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

  my $font = $main::font;
  my $fc=[-font => $font];
  my $fe_conf={ elements => $fc,
		example => $fc,
		note => $fc,
		problem => $fc
	      };
  my $vallex_conf = {
		     framelist => $fc,
		     framenote => $fc,
		     frameproblem => $fc,
		     wordlist => { wordlist => $fc, search => $fc},
		     wordnote => $fc,
		     wordproblem => $fc,
		     infoline => { label => $fc }
		    };

  my $chooser_conf = {
		      framelist => $fc
		     };

  my $frame=join "|",TrEd::ValLex::Chooser::show_dialog($lemma,$top,
					       $chooser_conf,
					       $fc,
					       $vallex_conf,
					       $fc,
					       $fc,
					       $fe_conf,
					       $FrameData,
					       $word,undef,$new_word);
  if ($frame) {
    print "Frame: $frame\n";
    $this->{commentA}=$frame;
  }
}

