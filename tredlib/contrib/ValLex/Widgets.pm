#
# ValLex views baseclass
#

package TrEd::ValLex::Widget;
use locale;

sub new {
  my ($self, $data, $field, @widget_options)= @_;

  $class = ref($self) || $self;
  my $new = bless [$data,$field],$class;
  my @new= $new->create_widget($data,$field,@widget_options);
  push @$new,@new;
  return $new;
}

sub data {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[0];
}

sub field {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[1];
}

sub widget {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[2];
}

sub pack {
  my $self=shift;
  return undef unless ref($self);
  return $self->widget()->pack(@_);
}

sub configure {
  my $self=shift;
  return undef unless ref($self);
  return $self->widget()->configure(@_);
}

#
# ValLex views baseclass for component widgets
#

package TrEd::ValLex::FramedWidget;
use base qw(TrEd::ValLex::Widget);

sub frame {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[3]->{frame};
}

sub subwidget {
 my ($self,$sub)=@_;
  return undef unless ref($self) and ref($self->[3]);
  return $self->[3]->{$sub};
}

sub pack {
  my $self=shift;
  return undef unless ref($self);
  return $self->frame()->pack(@_);
}

sub configure {
  my $self=shift;
  return undef unless ref($self);
  return $self->widget()->configure(@_);
}

sub subwidget_configure {
  my ($self,$conf)=@_;
  foreach (keys(%$conf)) {
    my $sub=$self->subwidget($_);
    next unless $sub;
    if ($sub->isa("TrEd::ValLex::FramedWidget") and
	ref($conf->{$_}) eq "HASH") {
      $sub->subwidget_configure($conf->{$_});
    } elsif(ref($conf->{$_}) eq "ARRAY") {
      $sub->configure(@{$conf->{$_}});
    } else {
      print STDERR "bad configuration options $conf->{$_}\n";
    }
  }
}

#
# FrameList widget
#

package TrEd::ValLex::FrameList;
use base qw(TrEd::ValLex::Widget);

require Tk::HList;
require Tk::ItemStyle;

sub create_widget {
  my ($self, $data, $field, $top, $common_style, @conf) = @_;

  my $w = $top->Scrolled(qw/HList -columns 1
                              -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/
			  );
  $w->configure(@conf) if (@conf);
  $common_style=[] unless (ref($common_style) eq "ARRAY");
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  $w->headerCreate(0,-itemtype=>'text', -text=>'Elements');
  return $w, {
	      obsolete => $w->ItemStyle("imagetext", -foreground => '#707070',
					-background => 'white', @$common_style),
	      substituted => $w->ItemStyle("imagetext", -foreground => '#707070',
					   -background => 'white', @$common_style),
	      reviewed => $w->ItemStyle("imagetext", -foreground => 'black',
					-background => 'white', @$common_style),
	      active => $w->ItemStyle("imagetext", -foreground => 'black',
				      -background => 'white', @$common_style),
	      deleted => $w->ItemStyle("imagetext", -foreground => '#707070',
				       -background => '#e0e0e0', @$common_style)
	     },{
		obsolete => $w->Pixmap(-file => Tk::findINC("ValLex/stop.xpm")),
		substituted => $w->Pixmap(-file => Tk::findINC("ValLex/red.xpm")),
		reviewed => $w->Pixmap(-file => Tk::findINC("ValLex/finished.xpm")),
		active => $w->Pixmap(-file => Tk::findINC("ValLex/help.xpm")),
		deleted => $w->Pixmap(-file => Tk::findINC("ValLex/error.xpm"))
	       },0;
}

sub style {
  return $_[0]->[3]->{$_[1]};
}

sub pixmap {
  return $_[0]->[4]->{$_[1]};
}

sub SHOW_DELETED { 5 }


sub show_deleted {
  my ($self,$value)=@_;
  if (defined($value)) {
    $self->[SHOW_DELETED]=$value;
  }
  return $self->[SHOW_DELETED];
}

sub fetch_data {
  my ($self, $word)=@_;

  my $t=$self->widget();
  my ($e,$i);
  my $style;

  $t->delete('all');
  my $myfont=$t->cget(-font);
  foreach my $entry ($self->data()->getFrameList($word)) {
    next if (!$self->show_deleted() and $entry->[3] eq 'deleted');
    $e = $t->addchild("",-data => $entry->[0]);
    $i=$t->itemCreate($e, 0,
		      -itemtype=>'imagetext',
		      -image => $self->pixmap($entry->[3]),
		      -text=> $entry->[2].($entry->[4] ? "\n".$entry->[4] : "")." (".$entry->[5].")",
		      -style => $self->style($entry->[3]));
    print "fetching $i: $entry->[0]\n";
  }
}

sub focus {
  my ($self,$frame)=@_;
  print "Frame; $frame\n";
  my $h=$self->widget();
  foreach my $t ($h->infoChildren()) {
    print "trying $t ",$h->infoData($t),"\n";
    if ($self->data()->isEqual($h->infoData($t),$frame)) {
      print "got $t\n";
      $h->anchorSet($t);
      $h->selectionClear();
      $h->selectionSet($t);
      $h->see($t);
      return $t;
    }
  }
}

sub select_frames {
  my ($self,@frames)=@_;
  my $frames=" ".join(" ",@frames)." ";
  my $h=$self->widget();
  my $data=$self->data();
  my $have=0;
  $h->selectionClear();
  foreach my $t ($h->infoChildren()) {
    $id = $data->getFrameId($h->infoData($t));
    if (index($frames," $id ")>=0) {
      unless ($have) {
	$have=1;
	$h->anchorSet($t);
	$h->see($t);
      }
      $h->selectionSet($t);
    }
  }
}


#
# WordList widget
#

package TrEd::ValLex::WordList;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::HList;
require Tk::ItemStyle;

sub create_widget {
  my ($self, $data, $field, $top, $item_style, @conf) = @_;

  my $frame = $top->Frame(-takefocus => 0);
  my $ef = $frame->Frame(-takefocus => 0)->pack(qw/-pady 5 -side top -fill x/);
  my $l = $ef->Label(-text => "Search: ")->pack(qw/-side left/);
  my $e = $ef->Entry(qw/-background white -validate key/,
		     -validatecommand => [\&quick_search,$self]
		    )->pack(qw/-expand yes -fill x/);

  ## Word List
  my $w = $frame->Scrolled(qw/HList -columns 2 -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/)->pack(qw/-side top -expand yes -fill both/);
  $e->bind('<Return>',[
			  sub {
			    my ($cw,$w)=@_;
			    $w->Callback(-browsecmd => $w->infoAnchor());
			  },$w
			 ]);

  $w->configure(@conf) if (@conf);
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  $item_style = [] unless(ref($item_style) eq "ARRAY");
  my $itemStyle = $w->ItemStyle("text",
				-foreground => 'black',
				-background => 'white',
				@{$item_style});
  return $w, {
	      frame => $frame,
	      wordlist => $w,
	      search => $e,
	      label => $l
	     }, $itemStyle;
}

sub style {
  return $_[0]->[4];
}

sub quick_search {
  my ($self,$value)=@_;
  return defined($self->focus_by_text($value));
}

sub fetch_data {
  my ($self)=@_;
  my $t=$self->widget();
  my $e;
  $t->delete('all');
  $t->headerCreate(0,-itemtype=>'text', -text=>'');
  $t->headerCreate(1,-itemtype=>'text', -text=>'lemma');
  $t->columnWidth(0,'');
  $t->columnWidth(1,'');

  foreach my $entry (sort { $a->[2] cmp $b->[2] } $self->data()->getWordList())
    {
      $e= $t->addchild("",-data => $entry->[0]);
      $t->itemCreate($e, 0, -itemtype=>'text',
		     -text=> $entry->[3],
		     -style => $self->style());
      $t->itemCreate($e, 1, -itemtype=>'text',
		     -text=> $entry->[2],
		     -style => $self->style());
    }
}

sub focus_by_text {
  my ($self,$text,$pos)=@_;
  my $h=$self->widget();
  foreach my $t ($h->infoChildren()) {
    if (index($h->itemCget($t,1,'-text'),$text)==0 and
	($pos eq "" || $pos eq $h->itemCget($t,0,'-text'))) {
      $h->anchorSet($t);
      $h->selectionClear();
      $h->selectionSet($t);
      $h->see($t);
      return $t;
    }
  }
  return undef;
}
sub focus {
  my ($self,$word)=@_;
  print "Word: $word\n";
  my $h=$self->widget();
  foreach my $t ($h->infoChildren()) {
    if ($self->data()->isEqual($h->infoData($t),$word)) {
      print "Have $t\n";
      $h->anchorSet($t);
      $h->selectionClear();
      $h->selectionSet($t);
      $h->see($t);
      return $t;
    }
  }
}

#
# FrameProblems widget
#

package TrEd::ValLex::FrameProblems;
use base qw(TrEd::ValLex::FramedWidget);
require Tk::HList;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $frame = $top->Frame(-takefocus => 0);
  my $label = $frame->Label(qw/-text Problems -anchor nw -justify left/)->pack(qw/-fill both/);

  my $w=
    $frame->Scrolled(qw/HList -columns 3 -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/
			  );
  $w->configure(@conf) if (@conf);
  $w->headerCreate(0,-itemtype=>'text', -text=>'By');
  $w->headerCreate(1,-itemtype=>'text', -text=>'Problem');
  $w->headerCreate(2,-itemtype=>'text', -text=>'Solved');
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  $w->pack(qw/-expand yes -fill both -padx 6 -pady 6/);

  return $w, {
	      frame => $frame,
	      label => $label
	     };
}

sub fetch_data {
  my ($self,$frame)=@_;
  my $t=$self->widget();
  my $e;
  $t->delete('all');
  $t->columnWidth(0,'');
  $t->columnWidth(1,'');
  $t->columnWidth(2,'');
  foreach my $entry ($self->data()->getSubElementProblemsList($frame)) {
    $e = $t->addchild("",-data => $entry->[0]);
    $t->itemCreate($e, 0, -itemtype=>'text', -text=> $entry->[2]);
    $t->itemCreate($e, 1, -itemtype=>'text', -text=> $entry->[1]);
    $t->itemCreate($e, 2, -itemtype=>'text', -text=> $entry->[3]);
  }
}

#
# TextView widget
#

package TrEd::ValLex::TextView;
use base qw(TrEd::ValLex::FramedWidget);
require Tk::ROText;

sub create_widget {
  my ($self, $data, $field, $top, $label, @conf) = @_;

  my $frame = $top->Frame(-takefocus => 0);
  my $label = $frame->Label(-text => $label, qw/-anchor nw -justify left/)->pack(qw/-fill both/);
  my $w =
    $frame->Scrolled(qw/ROText -background white
                               -relief sunken/);
  $w->configure(@conf) if (@conf);
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  $w->pack(qw/-expand yes -fill both -padx 6 -pady 4/);

  return $w, {
	      frame => $frame,
	      label => $label
	     };
}

sub set_data {
  my ($self,$data)=@_;
  my $w=$self->widget();
  $w->delete('0.0','end');
  $w->insert('0.0',$data);
}

#
# AddFrame widget
#

package TrEd::ValLex::FrameElementEditor;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $frame = $top->LabFrame(-takefocus => 0,
			     -label => "Edit Frame",
			     -labelside => "acrosstop",
			     -relief => 'raised'
			    );

  my $label=$frame->Label(-text => "Frame Elements",
			  qw/-anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $w=$frame->Entry(qw/-background white/,
		      -validate => 'focusout',
#		      -vcmd => [\&validate,$self]
		     );
#  $w->configure(-invcmd => [\&bell,$self]);
  $w->pack(qw/-padx 6 -fill x -expand yes/);
  $frame->Frame(-takefocus => 0,qw/-height 6/)->pack();
  my $ex_label=$frame->Label(qw/-text Example -anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $example=$frame->Text(qw/-width 40 -height 5 -background white/);
  $example->pack(qw/-padx 6 -expand yes -fill both/);
  $example->bind($example,'<Tab>',[sub { shift->focusNext; Tk->break;}]);
  $frame->Frame(-takefocus => 0,qw/-height 6/)->pack();

  my $note_label=$frame->Label(qw/-text Note -anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $note=$frame->Text(qw/-width 40 -height 5 -background white/);
  $note->pack(qw/-padx 6 -expand yes -fill both/);
  $note->bind($note,'<Tab>',[sub { shift->focusNext; Tk->break;}]);
  $frame->Frame(-takefocus => 0,qw/-height 6/)->pack();

  my $problem_label=$frame->Label(qw/-text Problem -anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $problem=$frame->Entry(qw/-background white/);
  $problem->pack(qw/-padx 6 -expand yes -fill x/);

  foreach my $b ($w, $example, $note, $problem) {
    $b->bindtags([$b,ref($b),$b->toplevel,'all']);
  }

  $w->focus();

  return $w, {
	      frame => $frame,
	      elements => $w,
	      example => $example,
	      note => $note,
	      problem => $problem
	     };

}

sub validate {
  my ($self,$elements)=@_;
  if (!defined($elements)) {
    $elements=$self->subwidget('elements')->get();
  }
  $elements=" $elements";
  return $elements=~m{^(?:\s+([A-Z][A-Z0-9]+)(?:[[(][^])]*[])])?)+\s*$};
}

sub bell {
  my ($self)=@_;
  $self->widget()->toplevel()->messageBox(-message => 'Invalid frame elements!',
					  -title => 'Error',
					  -type => 'OK');
  $self->widget()->focus();
  return 0;
}

#
# Frame Info Line
#

package TrEd::ValLex::InfoLine;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::HList;

sub LINE_CONTENT { 4 }

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $value="";
  my $frame = $top->Frame(-takefocus => 0,-relief => 'sunken',
			  -borderwidth => 4);
  my $w=$frame->Label(-textvariable => \$value,
		      qw/-anchor nw -justify left/)
    ->pack(qw/-fill x/);

  $w->configure(@conf) if (@conf);

  return $w, {
	      frame => $frame,
	      label => $w
	     }, \$value;
}


sub line_content {
  my ($self,$value)=@_;
  if (defined($value)) {
    ${$self->[LINE_CONTENT]}=$value;
  }
  return ${$self->[LINE_CONTENT]};
}

sub fetch_word_data {
  my ($self,$word)=@_;
  return unless $self;
  if (!$word) {
    $self->line_content("");
    return;
  }
  my $w_id=$self->data()->getWordId($word);
  $self->line_content("word: $w_id");
}

sub fetch_frame_data {
  my ($self,$frame)=@_;
  return unless $self;
  if (!$frame) {
    $self->line_content("");
    return;
  }
  my $word=$self->data()->getWordForFrame($frame);
  my $w_id=$self->data()->getWordId($word);
  my $f_id=$self->data()->getFrameId($frame);
  my $subst=$self->data()->getSubstitutingFrame($frame);
  my $status=$self->data->getFrameStatus($frame);

  $self->line_content("word: $w_id      frame: $f_id   status: $status ".
		      (($status eq 'substituted') ? "with $subst" : "")
		     );
}

1;
