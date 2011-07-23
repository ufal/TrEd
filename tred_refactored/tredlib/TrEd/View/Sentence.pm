package TrEd::View::Sentence;

use strict;
use warnings;

use Cwd;

use TrEd::Config;
use TrEd::ValueLine;
use TrEd::HTML::Simple;
use TrEd::Utils qw{$EMPTY_STR}; 
use TrEd::Stylesheet; # for STYLESHEET_FROM_FILE
use TrEd::File;
use TrEd::Error::Message;

require TrEd::Dialog::FocusFix;

my $selected_sentences;
my $expand_view;
my $dialog;

# was main::reloadSentenceView
sub reload_view {
  my ($grp,$t,$selref)=@_;
  return unless $t;
  my $d = $dialog;
  $t->delete('0.0','end'); #something smells here!! 
  $dialog = $d;#WTF?!
  my $filename=$grp->{focusedWindow}->{FSFile}->filename();
  for (my $i=0; $i<=$grp->{focusedWindow}->{FSFile}->lastTreeNo();$i++) {
    $t->window('create', 'end', -window =>
	       $t->Checkbutton(-selectcolor => undef,
			       -indicatoron => 0,
			       -height => 25,
			       -width => 25,
			       -background=>'white',
			       -relief => 'flat',
			       -borderwidth => 0,
			       -padx => 5,
			       -pady => 5,
			       -selectimage => main::icon($grp,"checkbox_checked"),
			       -image => main::icon($grp,"checkbox"),
			       -variable => \$selref->[$i]
			      ));
    $t->window('create', 'end', -window =>
	       $t->Button(-height => 19,
			  -width => 19,
			  -background=>'white',
			  -relief => 'flat',
			  # -borderwidth => 0,
			  -padx => 0,
			  -pady => 0,
			  -image => main::icon($grp,'1rightarrow'),
			  -command => [\&TrEd::File::open_file, $grp, "$filename##".($i+1)]
			 ));

    my $v = $grp->{valueLine}->get_value_line($grp->{focusedWindow},
			   $grp->{focusedWindow}->{FSFile},$i,1,1,'sent_list');
    my %tags;
    if (ref($v)) {
      @tags{ map { @{$_}[1..$#$_] } @$v }=();
      foreach my $tag (keys(%tags)) {
	if ($tag=~/^\s*-/) {
	  eval {
	    $t->tagConfigure(
	      $tag => (map { (/^\s*(-[[:alnum:]]+)\s*=>\s*(.*\S)\s*$/) }
			 split(/,/,$tag)));
	  };
	  print $@ if $@;
	}
      }
    } else {
      $v = [ map [$_], split /(\n)/, $v ];
    }
    my $collapse=0;
    $t->insert('end',"(".($i+1).") ",['treeno',"start-tree-".($i+1)],
	       map {
		  my $l = $v->[$_];
		  my $t = $l->[0];
		  my @t = @$l[1..$#$l];
		  if (!$collapse and $_<$#$v and $t=~s/(\n\s*)$//) {
		    $collapse=1;
		    ($t,\@t,"...",["#collapse_bar#","#collapse_bar_$i#"],$1,["#collapse_$i#"])
		  } else {
		    push @t, "#collapse_$i#" if $collapse;
		    ($t, \@t)
		  }
		} 0..$#$v);
    if ($collapse) {
      $t->tagBind("#collapse_bar_$i#",'<Any-Enter>', => [sub { $_[0]->tagConfigure("#collapse_bar_$_[1]#", -background => 'cyan') },$i]);
      $t->tagBind("#collapse_bar_$i#",'<Any-Leave>', => [sub { $_[0]->tagConfigure("#collapse_bar_$_[1]#", -background => undef) },$i]);
      $t->tagConfigure("#collapse_$i#", -elide => 0);
      $t->tagBind("#collapse_bar_$i#",'<1>', => [sub {
		    my ($w,$i)=@_; 
		    $w->tagConfigure("#collapse_$i#",
				     -elide => $w->tagCget("#collapse_$i#",'-elide') ? 0 : 1) },$i]);
    }
    $t->insert('end',"\n",['newline',"end-tree-".($i+1), "#collapse_$i#"
			  ]);
  }
  $t->tagAdd('all','0.0','end');
  $t->tagConfigure('all',-lmargin2 => 50);
}

sub _selection_is_valid {
  my ($selection_ref) = @_;
  if (ref($selection_ref) eq 'ARRAY') {
    return 1;
  }
  else {
    return;
  }
}

sub _sentence_is_selected {
  my ($selection_ref, $i) = @_;
  if (ref($selection_ref) eq 'ARRAY') {
    return $selection_ref->[$i];
  }
  else {
    return;
  }
}

# was main::sentViewSelectAll
sub select_all_sentences {
  my ($grp, $selection_ref) = @_;
  return if (!_selection_is_valid($selection_ref));
  foreach my $sentence_selected (@{$selection_ref}) {
    $sentence_selected = 1;
  }
  return;
}

# was main::sentViewSelectNone
sub select_none {
  my ($grp, $selection_ref) = @_;
  return if (!_selection_is_valid($selection_ref));
  foreach my $sentence_selected (@{$selection_ref}) {
    $sentence_selected = 0;
  }
  return;
}

# was main::sentViewGetSelection
sub get_selection {
  my ($grp, $selection_ref) = @_;
  $selection_ref ||= $selected_sentences;
  my $range = $EMPTY_STR;
 
  if (_selection_is_valid($selection_ref)) {
    for (my $i = 0; $i <= $#{$selection_ref}; $i++) {
      if (_sentence_is_selected($selection_ref, $i)) {
        $range .= ($i+1) . q{,};
      }
    }
    # remove trailing comma
    $range =~ s/,$//;
  }
  return $range;
}

# was main::sentViewToggleCollapse
sub toggle_collapse {
 my ($grp,$t,$val)=@_;
 if (!defined $val) {
   $val = $expand_view;
 }
 $t->tagConfigure('#collapse_bar#',
		  -elide => $val ? 0 : 1);
 my $i=0;
 undef $@;
 do {{
   eval {
     $t->tagCget("#collapse_$i#",'-elide'); # dies if the tag does not exist
     $t->tagConfigure("#collapse_$i#", -elide => $val ? 1 : 0);
   };
   $i++
 }} while (!$@);
}

# was main::viewSentences
sub show_sentences {
  my ($grp)=@_;
  return unless $grp and ref($grp->{focusedWindow}->{FSFile});
  if ($dialog) {
    my $d=$dialog;
    $d->deiconify;
    $d->focus;
    $d->raise;
    return;
  }
  $selected_sentences = [];
  my $d=$dialog=
    $grp->{top}->Toplevel(-title=> "List of sentences for ".
			  $grp->{focusedWindow}->{FSFile}->filename(),
			  -width=> "10c");
  $d->withdraw();
  $d->bind('<Return>'=> [\&Tk::Widget::_DialogReturn,1]);
  $d->bind('<Escape>'=> [sub { $_[1]->destroy(); }, $d]);
  $d->bind('<Destroy>'=> [sub { $dialog = undef; } ]);
  populate_dialog($grp,$dialog,
			  $grp->{focusedWindow}->{FSFile},
			  $selected_sentences,
			  1
			 );
  $d->Popup;
}

# was main::viewSentencesDialog
sub show_sentences_dialog {
  my ($grp,$top,$fsfile,$selref)=@_;
  return unless $grp and ref($grp->{focusedWindow}->{FSFile});
  my $d=
    $top->DialogBox(-title=> "List of sentences for ".
		    $fsfile->filename(),
		    -width=> "10c");
  $d->BindReturn($d,1);
  $d->BindEscape();
  $selref ||= [];
  populate_dialog($grp,$d,$fsfile,$selref,0);
  TrEd::Dialog::FocusFix::show_dialog($d,$top);
  $d->destroy;
  undef $d;
  return $selref;
}

# was main::dumpSentView
sub dump_view {
  my ($grp, $fsfile, $t, $create_images, $selref)=@_;

  my $win = $grp->{focusedWindow};
  return if ($create_images and main::warnWin32PrintConvert($t) eq 'Cancel');

  toggle_collapse($grp,$t,1);

  my $file=$fsfile->filename();
  $file=~s/\.(?:csts|sgml|sgm|cst|trxml|trx|tei|xml|fs|pls)(?:\.gz)?$/.html/i;

  my $initdir = TrEd::File::dirname($file);
  $initdir = cwd() if ($initdir eq './');
  $initdir =~ s!${TrEd::File::dir_separator}$!!m;

  my @selref = split /,/, get_selection($grp, $selref);
  unless (@selref) {
    TrEd::Error::Message::error_message($t->toplevel,"No sentences selected. Select requested sentences and try again. To select a sentence, click the round button in front of it.",1);
    return;
  }

  my $errors;

  (my $html,$file) = TrEd::HTML::Simple::open($t,$file,"Save Sentences As HTML ...",$initdir);
  my $ttfont = $grp->{ttfonts} ? $grp->{ttfonts}->{$TrEd::Config::printOptions->{ttFont}} : undef;
  my $dpi = int($grp->{top}->fpixels('1i'));

  if (defined($html)) {
    my @dump=$t->dump('0.0','end'); # to avoid a bug ??
    @dump = map $t->dump("start-tree-$_.first","end-tree-$_.last"), @selref;
    # @dump=$t->dump('0.0','end');
    my $img;

    # there seems to be a bug in Dump which prevents dumping tagoff
    # for the last open element on a line

    while (@dump) {
      my ($K,$V,$I) = splice @dump, 0, 3;
      if ($K eq 'tagon') {
	if ($V eq 'treeno') {
	  $img=1;
	  print $html "<div class=\"TREE\">";
	  print $html "<p>";
	} else {
	  print $html "<u>" if $t->tagCget($V,'-underline');
	  print $html "<font color=\"".$t->tagCget($V,'-foreground')."\">"
	    if $t->tagCget($V,'-foreground');
	  print $html "<span class=\"$1\">" if $V =~ /^tag\s*=>\s*(.*)$/;
	}
	
	if ($V eq 'newline') {
	  print $html "</p>\n";
	  print $html "</div>\n";
	  print $html "<hr />\n" if $create_images;
	}
      } elsif ($K eq 'tagoff') {
        print $html "</span>" if $V =~  /^tag\s*=>\s*.*$/ ;
        print $html "</font>" if $t->tagCget($V,'-foreground');
        print $html "</u>" if $t->tagCget($V,'-underline');
        $img=0 if $img;
      } elsif ($K eq 'text') {
	if ($img and $create_images) {
	  # create image filename
	  my $img_file = $file;
	  my $no = $V; 
	  $no =~ s/[()]|\s*//g;
	  $img_file =~ s/\.[^.]*$/_${no}.png/;
	  print $html "<img src=\"".TrEd::File::filename($img_file)."\"/><br />\n";
	  # create image
	  my $canvas=$grp->{top}->Canvas();
	  my $stylesheet = $win->{stylesheet};
	  my $ss = undef;
	  if ($stylesheet ne TrEd::Stylesheet::STYLESHEET_FROM_FILE()) {
	    $ss=$win->{framegroup}->{stylesheets}->{$stylesheet};
	  }
	  eval {
	    TrEd::Print::Print({
	      -context => $win,
	      -toplevel => $grp->{top},
	      -fsfile => $fsfile,
	      -canvas => $canvas,

	      -filename => $img_file,
	      -to => 'convert',
	      -convert => $TrEd::Config::imageMagickConvert,
	      -imageMagickResolution => $dpi,
	      -range => $no,

	      ($ttfont ? (
		-format => 'PDF',
		-ttFont => $ttfont,
	       ) : (
		 -format => 'EPS',
		 -psFontFile => $TrEd::Config::printOptions->{psFontFile},
		 -psFontAFMFile => $TrEd::Config::printOptions->{psFontAFMFile},
	       )),

	      -styleSheetObject=>$ss,
	      -hidden => $win->{treeView}->get_showHidden(),
	      -fontSize => $TrEd::Config::printOptions->{psFontSize},
	      -treeViewOpts => $TrEd::Config::treeViewOpts,

	      -onGetRootStyle => \&main::onGetRootStyle,
	      -onGetNodeStyle => \&main::onGetNodeStyle,
	      -onGetNodes => \&main::printGetNodesCallback,
	      -onRedrawDone => \&main::onRedrawDone,
	    });
	  };
	  $errors .= $@ if $@;

	  $canvas->destroy();
	  $img=0;
	}
	$V=~s{&}{&amp;}g;
	$V=~s{<}{&lt;}g;
	$V=~s{\t}{     }g;
	$V=~s{\n}{<br/>}g;
	$V=~s{ ( +)}{' '.('&nbsp;'x length($1))}eg;
	print $html $V;
      } else {
#	print $html "<other key=\"$K\" value=\"$V\"/>";
      }
    }
    TrEd::HTML::Simple::close($html);
    $win->get_nodes(); # printGetNodesCallback may have fiddled with $win
  }
  TrEd::Error::Message::error_message($win,$errors) if defined $errors;
  return $file;
}

# was main::populateSentencesDialog
sub populate_dialog {
  my ($grp,$d,$fsfile,$selref,$close_button)=@_;
  return unless $grp and $fsfile;

  use Tk::ROText;
#c -background white
# -spacing3 6 
  my $t= $d->
    Scrolled(qw/ROText -relief sunken -borderwidth 2 -setgrid true
		     -wrap word
		     -height 20
		     -scrollbars oe/,
	     -font=>$font
	    );

  main::_deleteMenu($t->Subwidget('scrolled')->menu,'File');
  main::disable_scrollbar_focus($t);
  $t->pack(qw/-expand yes -fill both/);
  $t->TextSearchLine(-parent => $d,
		     -label=>'S~earch',
		     -prev_img =>main::icon($grp,'16x16/up'),
		     -next_img =>main::icon($grp,'16x16/down'),
		    )->pack(qw(-fill x));

  $t->BindMouseWheelVert();
  $grp->{sentDialogText}=$t;
  my $bottom=$d->Frame()->pack(qw/-expand 0 -fill x/);

  if ($close_button) {
    $bottom->Button(-text=> "Close",
		    -underline => 0,
		    -command=> [sub { $_[0]->destroy; },$d])
      ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  }

  $bottom->Button(-text=> "Reload",
		  -underline => 0,
		  -command=> [\&reload_view,$grp,$t,$selref])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "Select All",
		  -underline => 7,
		  -command=>[ \&select_all_sentences,$grp,$selref])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "Clear selection",
		  -underline => 1,
		  -command=>[ \&select_none,$grp,$selref])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "Save As HTML",
		  -underline => 0,
		  -command=>[ sub { main::open_url_in_browser(&dump_view) }, $grp, $fsfile, $t, 0, $selref])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "Save As HTML with Images",
		  -underline => 18,
		  -command=>[ sub { main::open_url_in_browser(&dump_view) }, $grp, $fsfile, $t, 1, $selref])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);

  $bottom->Checkbutton(-text=> "Shrink/Expand",
		  -underline => 0,
		  -variable => \$expand_view,
		  -command=>[ \&toggle_collapse,$grp,$t])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $d->BindButtons;
  reload_view($grp,$t,$selref);
}

1;