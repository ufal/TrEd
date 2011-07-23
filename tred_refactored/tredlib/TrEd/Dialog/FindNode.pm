package TrEd::Dialog::FindNode;

use strict;
use warnings;

use TrEd::Config qw{$sortAttrs $maxDisplayedAttributes $font $tredDebug};
use TrEd::MinMax qw{min max2};
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::ManageFilelists;
use TrEd::Convert;
use Tk;

require TrEd::Dialog::FocusFix;

my %searchTemplate = ();

#sub findNodeDialog
#TODO: vycentrovat najdeny node?
sub findNodeDialog {
  my ($grp)=@_;
  
  my $template = \%searchTemplate;
  return unless $grp->{focusedWindow}->{FSFile};
  my $win = $grp->{focusedWindow};
  my $r;
  my @vals;
  my @atord;
  if ( $win->{FSFile}->schema() ) {
    @atord = $win->{FSFile}->schema()->attributes;
  } else {
    @atord = $win->{FSFile}->FS()->attributes;
  }

  if ($TrEd::Config::sortAttrs) {
    my @atord2 = @atord;
    if (main::doEvalHook($win,"sort_attrs_hook",\@atord2,'',undef)) {
      @atord = @atord2;
    } else {
      @atord=sort {uc($a) cmp uc($b)} @atord
    }
  }

  my $b;
  my $a;
  my $rows=min($TrEd::Config::maxDisplayedAttributes,$#atord+1);
  my %e=();
  $grp->{top}->Busy(-recurse=>1);
  my $d=$grp->{top}->DialogBox(-title=> "Find Node By Attributes", -width=> '10c',
				 -buttons=> ["Find"]);
  my $bcl=$d->Subwidget('bottom')->Button(-text=> "Clear",
				  -command=> [sub { my $e=shift;
						     foreach (keys %$e) {
						       $e->{$_}->delete(0,'end');
						     }
						   },\%e] );
  my $bca=$d->Subwidget('bottom')->Button(-text=> "Cancel",
				  -command=> [sub { shift->{selected_button}= "Cancel"},$d] );
  foreach ($bcl,$bca) {
    $_->configure(-width=> 10, -pady=> 0) if ($Tk::platform eq 'MSWin32');
    $_->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  }
  $d->BindReturn($d,1);
  $d->BindEscape();
  my $ff=$d->Frame(-relief=> 'groove',
		   -bd => 1);
  my $f= $ff->Scrolled('Pane',
		      -sticky => 'we',
		      -scrollbars=> 'oe');
  main::disable_scrollbar_focus($f);
  $f->BindMouseWheelVert($EMPTY_STR,"EditEntry");

  my $lwidth;
  foreach (@atord) {
    $lwidth=max2($lwidth,length($_));
  }
  my $height=0;
  for (my $i=0;$i<=$#atord;$i++) {
    $_=$atord[$i];
    # Reliefs: raised, sunken, flat, ridge, and groove.
    my $eef=$f->Frame()->pack(qw/-side top -expand yes -fill x/);
    $eef->Label(-text=> $_,
		-underline => 0,
		-justify => 'left',
		-width =>$lwidth,
		-anchor=> 'nw')->pack(qw/-side left/);
    $e{$_}= $eef->Entry(-relief=> 'sunken', -takefocus=> 1,
			-font=> $TrEd::Config::font)->pack(qw/-side right -expand yes -fill both/);
    main::addBindTags($e{$_},"EditEntry");
    $e{$_}->insert(0,TrEd::Convert::encode($template->{$_}));
    $height += $e{$_}->reqheight() if ($i<$rows);
    $f->bind($e{$_}, '<Tab>',       [\&main::focusxEditDn,$i,\%e,$f,\@atord]);
    $f->bind($e{$_}, '<Down>',      [\&main::focusxEditDn,$i,\%e,$f,\@atord]);
    $f->bind($e{$_}, '<Shift-Tab>', [\&main::focusxEditUp,$i,\%e,$f,\@atord]);
    $f->bind($e{$_}, '<Shift-ISO_Left_Tab>',
	                            [\&main::focusxEditUp,$i,\%e,$f,\@atord]);
    $f->bind($e{$_}, '<Up>',        [\&main::focusxEditUp,$i,\%e,$f,\@atord]);
    $f->bind($e{$_}, '<Alt-KeyPress>', [\&main::focusxFind,$i,\%e,$f,\@atord]);
  }
  $f->configure(-height => $height);
  $f->pack(qw/-expand yes -fill both/);
  $ff->pack(qw/-expand yes -fill both/);

  do {
    my $of=$d->Frame()->pack(qw/-expand yes -fill x/);
    $of->Label(-text=> 'Search method: ')->pack(qw/-side left/);
    my $om = $of->Optionmenu(-variable=> \$grp->{templateMatchMethod},
		    -textvariable=> \$grp->{templateMatchMethod},
		    -options=> ['Regular expression',
				'Exhaustive regular expression',
				'Wildcard pattern',
				'Literal'])->pack(qw/-side left/);
    $om->menu->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Tk::Ev('K')]);
    $of->Checkbutton(-text => 'Always load secondary files',
		     -variable => \$grp->{searchAlwaysSecondary})->pack(qw/-side right/);
  };
  my $of=$d->Frame()->pack(qw/-expand yes -fill x/);
  $of->Label(-text=> 'Search file-list: ')->pack(qw/-side left/);
  my $ot = $of->Optionmenu(-variable=> \$grp->{searchFilelistTraverse},
			   -textvariable=> \$grp->{searchFilelistTraverseText},
			   # -textvariable is only used here to preserve last state
			   -options=> [ [ 'Whole files' => 'all' ],
					[ 'Particular tree' => 'tree' ],
					[ 'Particular node' => 'node' ] ]);
  $ot->menu->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Tk::Ev('K')]);
  my $oe = $of->Button(-text=> 'Edit');
  my $om=$of->Optionmenu(-textvariable=> \$grp->{searchFilelist},
			 -command => [
			   sub {
			     my $opt = pop;
			     my $state = $opt eq '[Current file only]' ? 'disabled' : 'normal';
			     for my $w (@_) {
			       $w->configure(-state => $state)
			     }
			   },
			   $ot,$oe
			  ]
			)->pack(qw/-side left/);
  $om->menu->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Tk::Ev('K')]);
  my @filelists = TrEd::ManageFilelists::get_filelists();
  $om->options(['[Current file only]', map { $_->name } @filelists]);
  $oe->configure(
    -command=> [ sub {
		   my ($grp)=@_;
		   my $name=TrEd::Dialog::Filelist::create_dialog($grp,1);
		   $om->options(['[Current file only]',sort map { $_->name } @filelists]);
		   $grp->{searchFilelist}=$name if (ref(TrEd::ManageFilelists::find_filelist($name)));
		 },$grp,$om]);
  $oe->pack(qw/-side left/);
  $ot->pack(qw/-side left/);
  $grp->{top}->Unbusy();
  $d->BindButtons;
  my $result= TrEd::Dialog::FocusFix::show_dialog($d,($atord[0] ? $e{$atord[0]}->focus : undef),$grp->{top});
  if ($result=~ /Find/) {
#    %$template = (); # cleanup template
    my $search_code = 'sub {
  my ($node)=@_;';
    my $method=substr($grp->{templateMatchMethod},0,1);
    foreach my $t (@atord) {
        #TODO: ktory decode? z TrEd::Convert?
      my $val = TrEd::Convert::decode($e{$t}->get);
      $searchTemplate{$t}=$val;
      if ($val ne $EMPTY_STR) {
	$search_code.='  return 0 unless $node->all(q{'.$t.'});
  for ($node->all(q{'.$t.'})) { return 0 unless ';
	if ($method eq 'E') {
	  my $re = qr{^$val$};
	  $search_code .= '$_ =~ m('.$re.')';
	} elsif ($method eq 'R') {
	  my $re = qr{$val};
	  $search_code .= '$_ =~ m('.$re.')';
	} elsif ($method eq 'W') {
	  $val=~s/([+\[\].^$(){}<>\\])/\\$1/g;
	  $val=~s/\*/.\*/g;
	  $val=~s/\?/./g;
	  my $re = qr{^$val$};
	  $search_code .= '$_ =~ m('.$re.')';
	} else { # $method eq 'L'
	  $val =~ s{([\\'])}{\\$1}g;
	  $search_code .= '$_ eq '."'$val'";
	}
	$search_code .= " }\n";
      }
    }
    $search_code .= '  return 1;'."\n}";
    print STDERR "$search_code\n" if $TrEd::Config::tredDebug;
    $search_code = eval $search_code;
    $grp->{searchCode}=$search_code;
    if ($@) {
      TrEd::Error::Message::error_message($win,$@);
    } else {
      if ($grp->{searchFilelist} ne '[Current file only]') {
	my $fl=TrEd::ManageFilelists::find_filelist($grp->{searchFilelist});
	if (ref($fl) and $fl->file_count>0 ) {
	  local $main::insideEval=1;                 # no redraw
	  $fl->set_current($fl->file_at(0));
	  TrEd::ManageFilelists::selectFilelist($grp,$fl);
	}
      } else {
	$grp->{searchFilelist}=undef;
      }
      main::doFindFirstTemplated($grp,0);
    }
  }
  $d->destroy;
  undef $d;
}


1;