# -*- cperl -*-

$AdvLexiconData=undef;
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
  }
  return unless $AdvLexiconData;
  require TrEd::CPConvert;
  my $conv= TrEd::CPConvert->new("utf-8",
				 ($^O eq "MSWin32") ?
				 "windows-1250":
				 "iso-8859-2");
  my $lemma=$this->{trlemma};
  my $func=show_adverbs_dialog($top,$AdvLexiconData,$conv,$lemma,$this->{func});
  if ($func) {
    $this->{func}=$func;
  }
}

sub parse_advxml {
  my ($file)=@_;
  require XML::LibXML;
  my $parser=XML::LibXML->new();
  return undef unless $parser;
  my $doc=$parser->parse_file($file);
  return $doc;
}

sub listAdverbs {
  my ($doc,$conv)=@_;
  return map { $conv->decode($_->getAttribute("lemma")) }
    $doc->getDocumentElement()->findnodes("/adverbs/adverb");
}

sub get_text {
  my ($element)=@_;
  my ($text)=$element->findnodes("text()");
  if ($text) {
    my $data=$text->getData();
    $data=~s/^\s+//;
    $data=~s/\s*;\s*/\n/g;
    $data=~s/[\s\n]+$//g;
    return $data;
  }
}

sub get_adverbs {
  my ($doc,$conv)=@_;
  my @adverbs=();
  foreach my $adv ($doc->getDocumentElement()->findnodes("/adverbs/adverb")) {
    push @adverbs,[
		   $conv->decode($adv->getAttribute("lemma")),
		   map { $conv->decode($_->getAttribute("functor")),
		         $conv->decode(get_text($_)),
		       } $adv->findnodes("example")
		  ];
  }
  return @adverbs;
}


sub show_adverbs_dialog {
  my ($top,$data,$conv,$trlemma,$func)=@_;
  require TrEd::CPConvert;
  my $d = $top->DialogBox(-title => "List of Adverbials",
			  -buttons => ['Choose','Cancel'],
			  -default_button => 'Choose'
			 );

  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Escape>'=> [sub { shift; shift->{selected_button}='Cancel'; },$d ]);

  require Tk::Tree;
  my $hlist=$d->Scrolled(qw/Tree
				-columns 1
				-indent 15
				-drawbranch 1
				-background white
				-selectmode browse
				-relief sunken
				-width 0
			        -height 20
				-scrollbars osoe/)->pack(qw/-side top -expand yes -fill both/);
  $hlist->BindMouseWheelVert() if $hlist->can('BindMouseWheelVert');

  $hlist->delete('all');
  my ($e,$f);
  foreach my $adv (get_adverbs($data,$conv)) {
    my $lemma=shift @$adv;
    $e=$hlist->addchild("", -data => $lemma);
    my $i=$hlist->itemCreate($e, 0,
			     -itemtype => 'text',
			     -text => $lemma,
			    );
    while (@$adv) {
      my ($fn,$example)=(shift @$adv, shift @$adv);
      $f = $hlist->addchild("$e",-data => $fn);
      $i = $hlist->itemCreate($f, 0,
			      -itemtype => 'text',
			      -text => "$fn\n$example"
			     );
    }
  }
  $hlist->autosetmode();
  foreach $e ($hlist->infoChildren("")) {
    if ($hlist->infoData($e) eq $trlemma) {
      $hlist->see($e);
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
  $hlist->bind('all','<Double-1>'=> [sub { shift; shift->{selected_button}='Choose'; },$d ]);
  $hlist->bind('all','<space>'=> [sub { my ($w)=@_;
					my $e=$w->infoAnchor();
					if ($e ne "") {
					  $w->getmode($e) eq "open" ? 
					    $w->open($e) : $w->close($e);
					}
				      },$hlist ]);
  $hlist->focus();
  if ($d->Show() eq 'Choose') {
    $func = join("|",
		 map { $hlist->infoData($_) }
		 grep { $hlist->infoParent($_) ne "" } $hlist->infoSelection()
		);
  }
  $d->destroy();
  return $func;
}
