# -*- cperl -*-

#encoding iso-8859-2

$FrameData=undef;
$ChooserHideObsolete=1;
$frameid_attr="frameid";
$framere_attr="framere";
$vallexEditor=undef;
$vallex_validate = 0;
$vallex_file = "$libDir/contrib/ValLex/vallex.xml";

$chooserDialog=undef;

#$XMLDataClass="TrEd::ValLex::JHXMLData";
#$XMLDataClass="TrEd::ValLex::LibXMLData";


sub init_XMLDataClass {

  eval <<'EOF';
    require POSIX;
    # ensure czech collating locale
    #    print STDERR "LC_COLLATE:",
    #      $TrEd::Convert::support_unicode ? "cs_CZ.UTF-8" : "cs_CZ";
    POSIX::setlocale(POSIX::LC_COLLATE,
		     $TrEd::Convert::support_unicode ? "cs_CZ.UTF-8" : "cs_CZ");
EOF
  unless (defined $XMLDataClass) {
    eval { require XML::JHXML; };
    if ($@) {
      print STDERR "Using LibXML\n" if $::tredDebug;
      eval { require XML::LibXML; };
      die $@ if $@;
      $XMLDataClass="TrEd::ValLex::LibXMLData";
    } else {
      print STDERR "Using JHXML\n" if $::tredDebug;
      $XMLDataClass="TrEd::ValLex::JHXMLData";
    }
  }
  if ($XMLDataClass eq "TrEd::ValLex::JHXMLData") {
    require ValLex::JHXMLData;
  } elsif ($XMLDataClass eq "TrEd::ValLex::LibXMLData") {
    require ValLex::LibXMLData;
  } elsif ($XMLDataClass eq "TrEd::ValLex::GDOMEData") {
    require ValLex::GDOMEData;
  }
}


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
  if ((($tag=~/^N/ and $trlemma=~/[tn]‚í(?:$|\s)/) or
       ($tag=~/^A/ and $trlemma=~/[tn]‚ý(?:$|\s)/)) 
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

sub InitFrameData {
  my $top=ToplevelFrame();
  unless ($FrameData) {
    my $support_unicode = ($Tk::VERSION ge 804.00);
    my $conv= TrEd::CPConvert->new("utf-8",
				   $support_unicode ? "utf-8" :
				   (($^O eq "MSWin32") ?
				    "windows-1250" :
				    "iso-8859-2"));
    my $info;
    eval {
      if ($^O eq "MSWin32") {
	$vallex_file =~ s{/}{\\}g;
	#### we may leave this commented out since 1. LibXML is fast enough and
	#### 2. it does not work always well under windows
	#    my $info=InfoDialog($top,"First run, loading lexicon. Please, wait...");

	$FrameData=
	  $XMLDataClass->new($vallex_file,$conv,!$vallex_validate);
      } else {
	$info=InfoDialog($top,"First run, loading lexicon. Please, wait...");
	$FrameData=
	  $XMLDataClass->new(-f "${vallex_file}.gz" ?
			     "${vallex_file}.gz" :
			     "${vallex_file}",$conv,!$vallex_validate);
      }
    };
    my $err=$@;
    $info->destroy() if $info;
    if ($err or !$FrameData->doc()) {
      print STDERR "$err\n";
      $top->Unbusy(-recurse=>1);
      ChangingFile(0);
      ErrorMessage("Valency lexicon not found or corrupted.\nPlease install!\n\n$err\n");
      return 0;
    } else {
      return 1;
    }

  }
}


sub OpenEditor {
  if ($vallexEditor) {
    return unless ref($vallexEditor);
    $vallexEditor->toplevel->deiconify;
    $vallexEditor->toplevel->focus;
    $vallexEditor->toplevel->raise;
  }
  $vallexEditor=1;
  my $top=ToplevelFrame();
#  $top->Busy(-recurse=>1);
  require ValLex::Data;
  init_XMLDataClass();
  require ValLex::Widgets;
  require ValLex::Editor;
  require TrEd::CPConvert;
  InitFrameData() || return; #do { $top->Unbusy(-recurse=>1); return };

  my $pos='V';
  $pos=$1 if $this->{tag}=~/^(.)/;
  my $lemma=TrEd::Convert::encode($this->{trlemma});

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

  print STDERR "EDITOR start at: $lemma,$pos,",$this->{$frameid_attr},"\n";

  my $d;
  ($d,$vallexEditor)=
    TrEd::ValLex::Editor::new_dialog_window($top,
					    $FrameData,
					    [$lemma,$pos],    # select field
					    1,                # autosave
					    $vallex_conf,
					    $fc,
					    $fc,
					    $fe_conf,
					    $this->{$frameid_attr},    # select frame
					    0,
					    {
					     '<F5>' => [\&copy_verb_frame,$grp->{framegroup}],
					     '<F7>' => [\&create_default_subst_frame,$grp->{framegroup}],
					     '<F3>' => [\&open_frame_instance_in_tred,$grp->{framegroup}]
					    }
					   );               # start frame editor
  $d->bind('<Destroy>',sub { undef $vallexEditor; });
  TredMacro::register_exit_hook(sub {
				  if (ref($vallexEditor)) {
				    $vallexEditor->ask_save_data();
				  }
				});
  $d->Popup;
  ChangingFile(0);
}

sub copy_verb_frame {
  my ($w,$group,$editor)=@_;
  print "copy_verb_frame $editor\n";
  my $top=$w->toplevel();
  my $data=$editor->data();

  my $wl=$editor->subwidget('wordlist')->widget();
  my $item=$wl->infoAnchor();
  print "item $item\n";
  return unless defined($item);
  my $word=$wl->infoData($item);
  return unless $word;
  my $target_lemma=$data->getLemma($word);
  my $target_pos=$data->getPOS($word);
  print "lemma $target_lemma\n";

  my $d=$top->Dialog(-title => 'Select source verb',
		     -buttons => ['OK','Cancel']);
  my $lexlist = TrEd::ValLex::WordList->new($data, undef, $d,
					    $editor->subwidget('wordlistitemstyle'),
					    qw/-height 10 -width 0/);
  $lexlist->set_pos_filter('V');
  $lexlist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);
  $lexlist->fetch_data();
  $lexlist->widget()->focus();
  for (my $i=length($target_lemma); $i>0; $i--) {
    $lexlist->focus_by_text(substr($target_lemma,0,$i),undef,1) && last;
  }
  $d->bind('<Return>', \&TrEd::ValLex::Widget::dlgReturn );
  $d->bind('<KP_Enter>', \&TrEd::ValLex::Widget::dlgReturn );
  $d->bind($d,'<Escape>', [sub { shift; $_[0]->{selected_button}= "Cancel"; },$d] );
  $d->protocol('WM_DELETE_WINDOW' => [sub { shift->{selected_button}='Cancel'; },$d]);
  my $answer=$d->Show();
  if ($answer eq 'OK') {
    my $focused=$lexlist->focused_word();
    if (ref($focused)) {
      my ($lemma,$pos)= @$focused;
      print "lemma: $lemma, POS: $pos\n";
      my $verb=$data->findWordAndPOS($lemma,$pos);
      return unless $verb;
      my $new;
      foreach my $frame ($data->getFrameList($verb)) {
	next unless ($frame->[3] =~ /^active$|^reviewed$/);
	my $elements=$frame->[2];
	if ($target_pos eq 'N') {
	  $elements=~s/(ACT[\[\(])(1|[^\]\)]+,1)(\]|\)|,)/${1}p,2,7${3}/;
	  $elements=~s/(PAT[\[\(])(4|[^\]\)]+,4)(\]|\)|,)/${1}2${3}/;
	}
	$new=$data->addFrame(undef,$word,$elements,"($lemma.$pos)",$frame->[4],"",$data->user());
	print "$lemma: converting $frame->[2] => $elements\n";
      }
      if ($new) {
	$editor->subwidget('framelist')->fetch_data($word);
	$editor->wordlist_item_changed($editor->subwidget('wordlist')->focus($word));
	$editor->framelist_item_changed($editor->subwidget('framelist')->focus($new));
      }
    }
  }
  $lexlist->destroy();
  $d->destroy();
}

sub create_default_subst_frame {
  my ($d,$group,$editor)=@_;
  print "create_default_subst_frame $editor\n";
  my $data=$editor->data();
  my $wl=$editor->subwidget('wordlist')->widget();
  my $item=$wl->infoAnchor();
  print "item $item\n";
  return unless defined($item);
  my $word=$wl->infoData($item);
  print "word $word\n";
  return unless $word;
  my $pos=$data->getPOS($word);
  my $new=$data->addFrame(undef,$word,
			  ($pos eq 'V') ? 'ACT(1) PAT(4)' :
			  ($pos eq 'A') ? 'ACT(7) PAT(2)' : 'ACT(2,p,7) PAT(2)',
			  ,"","","",$data->user());
  print "new $new\n";
  $editor->subwidget('framelist')->fetch_data($word);
  $editor->wordlist_item_changed($editor->subwidget('wordlist')->focus($word));
  $editor->framelist_item_changed($editor->subwidget('framelist')->focus($new));
}

sub open_frame_instance_in_tred {
  my ($w,$group,$editor)=@_;
  my $top=$w->toplevel();
  my $win=$group->{focusedWindow};
  print "open_frame_instance_in_tred $editor\n";
  my $data=$editor->data();
  my $fl=$editor->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return unless defined($item);
  my $frame=$fl->infoData($item);
  return unless ref($frame);
  my $example=$data->getFrameExample($frame);
  if ($example =~ /\{([^#}]*)(##?[0-9A-Z]+(?:\.[0-9]+)?)?\}/) {
    my $f=$1;
    my $suffix=$2;
    print "file: $f\n";
    my $fl=$win->{currentFilelist};
    return unless ref($fl);
    my $files=$fl->files_ref;
    my $i;
    for ($i=0; $i<=$#$files; $i++) {
      last if ($fl->file_at($i)=~/(?:^|\\|\/)([^\\\/]*)$/ and $1 eq $f);
    }
    if ($i<=$#$files) {
      print "index: $i\n";
      print "file: $files->[$i]\n";
      print "suffix: $suffix\n";
      print "win $win\n";
      $top->Busy(-recurse=>1);
      &main::gotoFile($group,$i,1,1);
      &main::applyFileSuffix($win,$suffix);
      &main::get_nodes_win($win);
      &main::redraw_win($win);
      &main::centerTo($win,$win->{currentNode});
      $top->Unbusy(-recurse=>1);
    }
  } else {
    print "no pointer in $example\n";
  }
}

sub ChooseFrame {
  my ($no_assign)=@_;
  if ($vallexEditor) {
    questionQuery("Sorry!","Valency editor already running.\n".
		  "To assign frames, you have to close it first.",
		  "Ok");
    return;
  }
  my $top=ToplevelFrame();
  $top->Busy(-recurse=>1);

  require ValLex::Data;
  init_XMLDataClass();
  require ValLex::Widgets;
  require ValLex::Editor;
  require ValLex::Chooser;
  require TrEd::CPConvert;

  my $lemma=TrEd::Convert::encode($this->{trlemma});
  my $tag=$this->{tag};
  if ($lemma=~/^ne/ and $this->{lemma}!~/^ne/) {
    $lemma=~s/^ne//;
  }
  unless ($tag=~/^([VNA])/) {
    questionQuery("Sorry!","Given word isn't a verb nor noun nor adjective\n".
		  "according to morphological tag.",
		  "Ok");
    ChangingFile(0);
    return;
  }
  my $pos=$1;
  $lemma=~s/_/ /g;
  my ($l,$base)=parse_lemma($lemma,TrEd::Convert::encode($this->{lemma}),$tag);
  my $title;
  InitFrameData() || do { ChangingFile(0); return; };
  my $field;
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
	ChangingFile(0);
	return;
      }
    }
    $title= join ("/",$word ? $lemma : (), $base_word ? $base : ());
    $field=[
	    $word ? ($lemma,$pos) : (),
	    $base_word ? ($base,"V") : ()
	   ];
  }
  my ($frame,$real);

  if (ref($chooserDialog) and
      scalar(@{$chooserDialog->subwidget('framelists')}) !=
      scalar(@{$field}/2)) {
    $chooserDialog->destroy_dialog();
    undef $chooserDialog;
  }
  if (not ref($chooserDialog)) {
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
		  problem => $fc,
		  addword => $fc
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
    $chooserDialog=
      TrEd::ValLex::Chooser::create_toplevel($title,
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
					     [split /\|/, $this->{$frameid_attr}],
					     $new_word,
					     ($no_assign ? undef :
					      [\&frame_chosen, $grp->{framegroup}]),
					     sub {
					       $chooserDialog->destroy_dialog();
					       undef $chooserDialog;
					     }
					    );
  } else {
    $chooserDialog->reuse($title,
			  \$ChooserHideObsolete,
			  $field,
			  [split /\|/, $this->{$frameid_attr}],
			  $new_word,
			  0);
  }
  ChangingFile(0);
  return 1;
}

sub frame_chosen {
  my ($grp,$chooser)=@_;
  return unless $grp and $grp->{focusedWindow};
  my $win = $grp->{focusedWindow};
  if ($win->{FSFile} and
      $win->{currentNode}) {
    my $field = $chooser->focused_framelist()->field();
    my $node = $win->{currentNode};
    my $lemma = $node->{trlemma}; $lemma=~s/_/ /g;
    my ($pos) = $node->{tag}=~/^(.)/;
    if (ref($field) and $field->[0] eq $lemma and
	$field->[1] eq $pos) {
      my @frames=$chooser->get_selected_frames();
      my $real=$chooser->get_selected_element_string();
      my $ids = $chooser->data->conv->decode(join("|",map { $_->getAttribute('frame_ID') } @frames));
      my $fmt  = $win->{FSFile}->FS();
      $fmt->addNewAttribute("P","",$frameid_attr) if $fmt->atdef($frameid_attr) eq "";
      $fmt->addNewAttribute("P","",$framere_attr) if $fmt->atdef($framere_attr) eq "";
      $node->{$frameid_attr}=$ids;
      $node->{$framere_attr}=TrEd::Convert::decode($real);
      $win->{framegroup}{top}->focus();
      $win->{framegroup}{top}->raise();
      $win->{FSFile}->notSaved(1);
      main::saveFileStateUpdate($win);
      main::onTreeChange($win);
    } else {
      $chooser->widget->toplevel->
	messageBox(-icon=> 'error',
		   -message=> "Can't assign frame for $field->[0].$field->[1] to $lemma.$pos",
		   -title=> 'Error', -type=> 'ok');

    }
  } else {
    $chooser->widget->toplevel->
      messageBox(-icon=> 'error',
		 -message=> "No node to assign selected frame $ids to!",
		 -title=> 'Error', -type=> 'ok');
  }
}
