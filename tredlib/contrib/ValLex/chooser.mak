# -*- cperl -*-

#bind ChooseFrame to Ctrl+Return menu Vyber ramec pro sloveso

$FrameData=undef;

sub InfoDialog {
  my ($top,$text)=@_;

  my $t=$top->Toplevel();
  my $f=$t->Frame(qw/-relief raised -borderwidth 3/)->pack();
  my $l=$f->Label(-text => $text,
		  -font => StandardTredFont(),
		  -wraplength => 200
		 )->pack();
  $t->overrideredirect(1);
  $t->Popup();
  return $t;

}

sub ChooseFrame {
  my $top=ToplevelFrame();

  require ValLex::Data;
  require ValLex::LibXMLData;
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  require TrEd::CPConvert;
  my $frameid_attr="frameid";
  my $framere_attr="framere";
  my $lemma=$this->{trlemma};
  my $tag=$this->{tag};
  if ($lemma=~/^ne/ and $this->{lemma}!~/^ne/) {
    $lemma=~s/^ne//;
  }
  return unless $tag=~/^([VNA])/;
  my $pos=$1;
  $lemma=~s/_/ /g;
  $top->Busy(-recurse=>1);
  my $conv= TrEd::CPConvert->new("utf-8",
				 ($^O eq "MSWin32") ?
				 "windows-1250":
				 "iso-8859-2");
  unless ($FrameData) {
    my $info=InfoDialog($top,"First run, loading lexicon. Please, wait...");
    if ($^O eq "MSWin32") {
      $FrameData=
	TrEd::ValLex::LibXMLData->new("$libDir/contrib/ValLex/vallex.xml",$conv);
    } else {
      $FrameData=
	TrEd::ValLex::LibXMLData->new(-f "$libDir/contrib/ValLex/vallex.xml.gz" ?
				      "$libDir/contrib/ValLex/vallex.xml.gz" :
				      "$libDir/contrib/ValLex/vallex.xml",$conv);
    }
    $info->destroy();
  }
  my $new_word=0;
  my $word=$FrameData->findWord($lemma);
  $top->Unbusy(-recurse=>1);
  unless ($word) {
    if (questionQuery("Word does not exist",
		      "Do you want to add this word to the lexicon?",
		      "Yes", "No") eq "Yes") {
      $word=$FrameData->addWord($lemma,$pos);
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

  my ($frame,$real)=TrEd::ValLex::Chooser::show_dialog($lemma,$top,
					       $chooser_conf,
					       $fc,
					       $vallex_conf,
					       $fc,
					       $fc,
					       $fe_conf,
					       $FrameData,
					       $word,
					       [split "|",$this->{$frameid_attr}],
					       $new_word);
  if ($frame) {
    my $fmt=$grp->{FSFile}->FS();
    $fmt->addNewAttribute("P","",$frameid_attr) if $fmt->atdef($frameid_attr) eq "";
    $fmt->addNewAttribute("P","",$framere_attr) if $fmt->atdef($framere_attr) eq "";
    $this->{$frameid_attr}=$frame;
    $this->{$framere_attr}=$real;
  } else {
    $FileNotSaved=0;
  }
}

