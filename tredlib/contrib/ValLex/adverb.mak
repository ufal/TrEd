# -*- cperl -*-

$AdvLexiconData=undef;
$AdvLexiconDialog=undef;

if ($^O eq "MSWin32") {
  $AdvFile="$libDir\\contrib\\ValLex\\adverbs.xml";
} else {
  $AdvFile= -f "$libDir/contrib/ValLex/adverbs.xml.gz" ?
    "$libDir/contrib/ValLex/adverbs.xml.gz" :
      "$libDir/contrib/ValLex/adverbs.xml";
}


sub ChooseAdverbFunc {
  my $top=ToplevelFrame();
  unless ($AdvLexiconData) {
    $AdvLexiconData=parse_advxml($AdvFile);
    unless ($AdvLexiconData) {
      $FileNotSaved=0;
      questionQuery("Lexicon not found.",
		    "Lexicon of adverbials not found.\nPlease install!","Ok");
      return;
    }
  }
  return unless $AdvLexiconData;
  require TrEd::CPConvert;
  require TrEd::Convert;
  my $conv= TrEd::CPConvert->new("utf-8",
				 ($^O eq "MSWin32") ?
				 "windows-1250":
				 "iso-8859-2");
  my $lemma=TrEd::Convert::encode($this->{trlemma});
  my $func=show_adverbs_dialog($top,$AdvLexiconData,$conv,$lemma,$this->{func});
  if ($func) {
    $this->{func}=$func;
  }
}

sub parse_advxml {
  my ($file)=@_;
  my $parser;
  eval { require XML::JHXML; };
  if ($@) {
    require XML::LibXML;
    $parser=XML::LibXML->new();
    print STDERR "Using LibXML\n";
    $XMLDataClass="TrEd::ValLex::LibXMLData";
  } else {
    print STDERR "Using JHXML\n";
    require XML::JHXML;
    $parser=XML::JHXML->new();
  }

  return undef unless $parser;
  my $doc;
  print "parsing $file\n";
  eval {
    $doc=$parser->parse_file($file);
  };
  print "done\n";
  if ($@ or !$doc) {
    print STDERR "$@\n";
    return undef;
  } else {
    return $doc;
  }

}

sub listAdverbs {
  my ($doc,$conv)=@_;
  return map { $conv->decode($_->getAttribute("lemma")) }
    $doc->getDocumentElement()->getChildrenByTagName("adverb");
}

sub adverb_get_text {
  my ($element)=@_;
  my $text=$element->firstChild();
  my $ret="";
  while ($text) {
    if ($text) {
      my $data=$text->getData();
      $data=~s/^\s+//;
      $data=~s/\s*;\s*/\n/g;
      $data=~s/[\s\n]+$//g;
      $ret.=$data;
    }
    $text = $text->nextSibling();
  }
  return $ret;
}

sub get_adverbs {
  my ($doc,$conv)=@_;
  my @adverbs=();
  my $adv=$doc->getDocumentElement()->firstChild();
  while ($adv) {
    if ($adv->nodeName eq "adverb") {
      push @adverbs,[
		     $conv->decode($adv->getAttribute("lemma")),
		     $conv->decode($adv->getAttribute("author")),
		     map { $conv->decode($_->getAttribute("functor")),
			     $conv->decode(adverb_get_text($_)),
			   } $adv->getElementsByTagName("example")
		    ];
    }
    $adv=$adv->nextSibling();

  }
  return @adverbs;
}

sub adverb_focus_by_text {
  my ($h,$text)=@_;
  foreach my $e ($h->infoChildren("")) {
    if (index($h->infoData($e),$text)==0) {
      $h->anchorSet($e);
      $h->selectionClear();
      $h->selectionSet($e);
      $h->see($e);
      return $e;
    }
  }
  return undef;
}

sub adverb_quick_search {
  my ($hlist,$value)=@_;
  return defined(adverb_focus_by_text($hlist,$value));
}

sub show_adverbs_dialog {
  my ($top,$data,$conv,$trlemma,$func)=@_;
  require TrEd::CPConvert;
  my $d,$hlist,$entry;
  if ($AdvLexiconDialog) {
    ($d,$hlist,$entry)=@$AdvLexiconDialog;
  } else {
    $d = $top->DialogBox(-title => "List of Adverbials",
			 -buttons => ['Choose','Cancel'],
			 -default_button => 'Choose'
			);
    $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
    $d->bind('all','<Escape>'=> [sub { shift; shift->{selected_button}='Cancel'; },$d ]);

    require Tk::Tree;
    require Tk::ItemStyle;
    $hlist=$d->Scrolled(qw/Tree
			   -columns 1
			   -indent 15
			   -drawbranch 1
			   -background white
			   -selectmode browse
			   -relief sunken
			   -width 0
			   -height 20
			   -scrollbars osoe/,
			-font => StandardTredFont()
		       );

    $hlist->Subwidget('xscrollbar')->configure(-takefocus=>0) if ($hlist->Subwidget('xscrollbar'));
    $hlist->Subwidget('yscrollbar')->configure(-takefocus=>0) if ($hlist->Subwidget('yscrollbar'));
    $hlist->Subwidget('corner')->configure(-takefocus=>0) if ($hlist->Subwidget('corner'));

    $entry = $d->Entry(qw/-background white -validate key/,
		       -font => StandardTredFont(),
		       -validatecommand => [\&adverb_quick_search,$hlist]
		      )->pack(qw/-expand yes -fill x/);
    $hlist->pack(qw/-side top -expand yes -fill both/);


    $hlist->BindMouseWheelVert() if $hlist->can('BindMouseWheelVert');

    $hlist->delete('all');
    my ($e,$f);

    my %styles=(EB => $hlist->ItemStyle('text',-foreground => 'black',
					-background => 'white',
					-font => StandardTredFont()),
		S => $hlist->ItemStyle('text',-foreground => '#707070',
				       -background => 'white',
				       -font => StandardTredFont()));

    print "populating list\n";
    foreach my $adv (get_adverbs($data,$conv)) {
      my $lemma=shift @$adv;
      my $author=shift @$adv;
      $author=~s/buranova/EB/;
      $author=~s/sidak/S/;
      $e=$hlist->addchild("", -data => $lemma);
      my $i=$hlist->itemCreate($e, 0,
			       -itemtype => 'text',
			       -text => "$lemma ($author)",
			       exists($styles{$author}) ? (-style => $styles{$author}) : ()
			      );
      while (@$adv) {
	my ($fn,$example)=(shift @$adv, shift @$adv);
	$f = $hlist->addchild("$e",-data => $fn);
	$i = $hlist->itemCreate($f, 0,
				-itemtype => 'text',
				-text => "$fn\n$example",
				exists($styles{$author}) ? (-style => $styles{$author}) : ()
			       );
      }
    }
    print "done\n";
    $hlist->autosetmode();
    $d->bind('all','<Double-1>'=> [sub {
				     shift;
				     shift->{selected_button}='Choose';
				     Tk->break; 
				   },$d ]);
    $d->bind('all','<Up>'=> [sub { my ($w,$h)=@_;
				   $h->UpDown('prev');
				   Tk->break;
				 }, $hlist ]);
    $d->bind('all','<Down>'=> [sub { my ($w,$h)=@_;
				     $h->UpDown('next');
				     Tk->break;
				   }, $hlist ]);


    $d->bind('all','<space>'=> [sub { my ($w,$h)=@_;
				      $h=$h->Subwidget('scrolled');
				      my $e=$h->infoAnchor();
				      if ($e ne "") {
					$h->getmode($e) eq "open" ? 
					  $h->open($e) : $h->close($e);
				      }
				      Tk->break;
				    },$hlist ]);
    $entry->focus();
  }
  print "search $trlemma start\n";
  $hlist->selectionClear();
  foreach $e ($hlist->infoChildren("")) {
    if ($hlist->infoData($e) eq $trlemma) {
      $hlist->see($e);
      $hlist->open($e);
      # first we try the child with the same functor as current node
      my ($child)=
	grep { $hlist->infoData($_) eq $func }
	  $hlist->infoChildren($e);
      # if we fail we take the first child
      ($child)=$hlist->infoChildren($e) unless ($child);
      if ($child ne "") {
	$hlist->anchorSet($child);
	$hlist->selectionSet($child);
      }
    } else {
      $hlist->close($e);
    }
  }
  print "search $trlemma done\n";
  $top->Unbusy();
  my $result = $AdvLexiconDialog ? 
    main::RepeatedShowDialog($d,$entry) :
    main::ShowDialog($d,$entry);
  if ($result eq 'Choose') {
    $func = join("|",
		 map { $hlist->infoData($_) }
		 grep { $hlist->infoParent($_) ne "" } $hlist->infoSelection()
		);
  }
#  $d->destroy();
  $AdvLexiconDialog=[$d,$hlist,$entry];
  return $func;
}
