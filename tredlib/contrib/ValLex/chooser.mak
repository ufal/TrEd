# -*- cperl -*-

#bind ChooseFrame to Ctrl+Return menu Vyber ramec pro sloveso

$FrameData=undef;
$ChooserHideObsolete=0;

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
  $top->idletasks();
  return $t;

}

sub parse_lemma {
  my ($trlemma,$lemma,$tag)=@_;
  my @components=split /_[\^,:;']/,$lemma;
  my $pure_lemma=shift @components;
  my $deriv;
  foreach (@components) {
    if (/^\(.*\*(.*)\)/) {
      $deriv=$1;
      if ($deriv =~/^([0-9]+)(.*)$/) {
	$deriv=substr($pure_lemma,0,-$1).$2;
      }
      last;
    }
  }
  if ((($tag=~/^N/ and $trlemma=~/[tn]í(?:$|\s)/) or
       ($tag=~/^A/ and $trlemma=~/[tn]ý(?:$|\s)/)) 
      and $deriv=~/t$|ci$/) {
    $deriv=~s/-[0-9]+$//g;
    if ($trlemma=~/( s[ei])$/) {
      $deriv.=$1;
    }
  } else {
    $deriv=undef;
  }
  return ($pure_lemma,$deriv);
}

sub ChooseFrame {
  my $top=ToplevelFrame();
  $top->Busy(-recurse=>1);

  require ValLex::Data;
  require ValLex::LibXMLData;
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  require TrEd::CPConvert;
  my $frameid_attr="frameid";
  my $framere_attr="framere";
  my $lemma=TrEd::Convert::encode($this->{trlemma});
  my $tag=$this->{tag};
  if ($lemma=~/^ne/ and $this->{lemma}!~/^ne/) {
    $lemma=~s/^ne//;
  }
  unless ($tag=~/^([VNA])/) {
    questionQuery("Sorry!","Given word isn't a verb nor noun nor adjective\n".
		  "according to morphological tag.",
		  "Ok");
    return;
  }
  my $pos=$1;
  $lemma=~s/_/ /g;
  my ($l,$base)=parse_lemma($lemma,TrEd::Convert::encode($this->{lemma}),$tag);
  my $field;
  my $title;
  unless ($FrameData) {
    my $conv= TrEd::CPConvert->new("utf-8",
				   ($^O eq "MSWin32") ?
				   "windows-1250":
				   "iso-8859-2");

#### we may leave this commented out since 1. LibXML is fast enough and
#### 2. it does not work always well under windows
#    my $info=InfoDialog($top,"First run, loading lexicon. Please, wait...");
    eval {
      if ($^O eq "MSWin32") {
	$FrameData=
	  TrEd::ValLex::LibXMLData->new("$libDir\\contrib\\ValLex\\vallex.xml",$conv);
      } else {
	$FrameData=
	  TrEd::ValLex::LibXMLData->new(-f "$libDir/contrib/ValLex/vallex.xml.gz" ?
					"$libDir/contrib/ValLex/vallex.xml.gz" :
					"$libDir/contrib/ValLex/vallex.xml",$conv);
      }
    };
    if ($@ or !$FrameData->doc()) {
      print STDERR "$@\n";
      $top->Unbusy(-recurse=>1);
      $FileNotSaved=0;
      questionQuery("Valency lexicon not found.","Valency lexicon not found.\nPlease install!","Ok");
      return;
    }
#    $info->destroy();
  }
  my $new_word=0;
  {
    my $word=$FrameData->findWordAndPOS($lemma,$pos);
    my $base_word;
    $base_word=$FrameData->findWordAndPOS($base,"V") if (defined($base));
    $top->Unbusy(-recurse=>1);
    if (!$word) {
      my $answer= questionQuery("Word not found",
				defined($base) && $base_word ?
				("Word $lemma was not found in the lexicon.\n",
				 "Add $lemma", "Use $base", "Cancel") :
				(!defined($base) ?
				("Word $lemma was not found in the lexicon.\n".
				 "Do you want to add it?","Add $lemma", "Cancel") :
				("Neither $lemma nor $base was found in the lexicon.\n".
				 "Do you want to add them?","Add $lemma",
				 "Add $base", "Add both", "Cancel")));

      if ($answer eq "Add $lemma") {
	$word=$FrameData->addWord($lemma,$pos);
	$new_word=[$lemma,$pos];
      } elsif ($answer eq "Add $base") {
	$base_word=$FrameData->addWord($base,"V");
	$new_word=[$base,"V"];
      } elsif ($answer eq "Add both") {
	$word=$FrameData->addWord($lemma,$pos);
	$base_word=$FrameData->addWord($base,"V");
	$new_word=[$lemma,$pos];
      } elsif ($answer eq "Cancel") {
	return;
      }
    }
    $field=[
	    $word ? ($lemma,$pos) : (),
	    $base_word ? ($base,"V") : ()
	   ];
    $title= join ("/",$word ? $lemma : (), $base_word ? $base : ());
  }
  my $font = $main::font;
  my $fc=[-font => $font];
  my $bfont;
  if (ref($font)) {
    $bfont = $font->Clone(-weight => 'bold');
  } else {
    $bfont=$font;
    $bfont=~s/-medium-/-bold-/;
  }
  my $fb=[-font => $bfont];
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
		      framelists => $fc,
		      framelist_labels => $fb,
		     };

  my ($frame,$real)=TrEd::ValLex::Chooser::show_dialog($title,
						       $top,
						       $chooser_conf,
						       $fc,
						       $vallex_conf,
						       $fc,
						       $fc,
						       $fe_conf,
						       \$ChooserHideObsolete,
						       $FrameData,
						       $field,
						       [split /\|/,
							$this->{$frameid_attr}],
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
  if (ref($bfont)) {
    $top->fontDelete($bfont);
  }
}

