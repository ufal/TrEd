#
# ValLex views baseclass
#

package TrEd::ValLex::Widget;
use locale;
use base qw(TrEd::ValLex::DataClient);

sub new {
  my ($self, $data, $field, @widget_options)= @_;

  $class = ref($self) || $self;
  my $new = bless [$data,$field],$class;
  $new->register_as_data_client();
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
    my $subw=$self->subwidget($_);
    next unless $subw;
    foreach my $sub (ref($subw) eq 'ARRAY' ? @$subw : ($subw)) {
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
}

#
# FrameList widget
#

package TrEd::ValLex::FrameList;
use base qw(TrEd::ValLex::Widget);

require Tk::Tree;
require Tk::HList;
require Tk::ItemStyle;

sub create_widget {
  my ($self, $data, $field, $top, $common_style, @conf) = @_;

  my $w = $top->Scrolled(qw/Tree -columns 1
                              -indent 15
                              -drawbranch 1
                              -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/,
			  );
  $w->configure(-opencmd => [\&open_superframe,$w],
		-closecmd => [\&close_superframe,$w]);
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
		substituted => $w->Pixmap(-file => Tk::findINC("ValLex/reload.xpm")),
		reviewed => $w->Pixmap(-file => Tk::findINC("ValLex/ok.xpm")),
		active => $w->Pixmap(-file => Tk::findINC("ValLex/filenew.xpm")),
		deleted => $w->Pixmap(-file => Tk::findINC("ValLex/erase.xpm"))
	       },0,1;
}

sub style {
  return $_[0]->[3]->{$_[1]};
}

sub pixmap {
  return $_[0]->[4]->{$_[1]};
}

sub SHOW_DELETED { 5 }
sub SHOW_OBSOLETE { 6 }

sub show_deleted {
  my ($self,$value)=@_;
  if (defined($value)) {
    $self->[SHOW_DELETED]=$value;
  }
  return $self->[SHOW_DELETED];
}

sub show_obsolete {
  my ($self,$value)=@_;
  if (defined($value)) {
    $self->[SHOW_OBSOLETE]=$value;
  }
  return $self->[SHOW_OBSOLETE];
}

sub forget_data_pointers {
  my ($self)=@_;
  my $t=$self->widget();
  if ($t) {
    $t->delete('all');
  }
}

sub close_superframe {
  my( $w, $ent ) = @_;
  my $data=$w->infoData($ent);
  $w->itemConfigure($ent,0,-text => $w->itemCget($ent,0,'-text').$data);
  foreach my $kid ($w->infoChildren( $ent )) {
    $w->hide( -entry => $kid );
  }
}

sub open_superframe {
  my( $w, $ent ) = @_;
  my $text=$w->itemCget($ent,0,'-text');
  ($text) = $text=~/^(.*)/;
  $w->itemConfigure($ent,0,-text => $text);
  foreach my $kid ($w->infoChildren( $ent )) {
    $w->show( -entry => $kid );
  }
}

sub fetch_data {
  my ($self, $word)=@_;

  my $t=$self->widget();
  my ($e,$f,$i);
  my $style;
  $t->delete('all');
  
#  foreach my $entry ($self->data()->getFrameList($word)) {
#    next if (!$self->show_deleted() and $entry->[3] eq 'deleted');
#    $e = $t->addchild("",-data => $entry->[0]);
#    $i=$t->itemCreate($e, 0,
#		      -itemtype=>'imagetext',
#		      -image => $self->pixmap($entry->[3]),
#		      -text=> $entry->[2].($entry->[4] ? "\n".$entry->[4] : "")." (".$entry->[5].")",
#		      -style => $self->style($entry->[3]));
#
#  }
  my $super=$self->data()->getSuperFrameList($word);
  foreach my $sframe (sort {
    @{$super->{$b}} <=> @{$super->{$a}}
  } keys(%$super)) {
    if (@{$super->{$sframe}}>1) {
      my $examples=join("",map { $_->[4] ? "\n$_->[4] ($_->[5])" : () } 
					 @{$super->{$sframe}});
      $e = $t->addchild("",-data => $examples);
      $i=$t->itemCreate($e, 0,
			-itemtype=>'imagetext',
			-text => $sframe,
			-style => $self->style('active')
		       );
    } else {
      $e="";
    }
    foreach my $entry (@{$super->{$sframe}}) {
      next if (!$self->show_deleted() and $entry->[3] eq 'deleted');
      next if (!$self->show_obsolete() and
		   ($entry->[3] eq 'obsolete' or
		    $entry->[3] eq 'substituted'));
      $f = $t->addchild("$e",-data => $entry->[0]);
      $i=$t->itemCreate($f, 0,
			-itemtype=>'imagetext',
			-image => $self->pixmap($entry->[3]),
			-text=> $entry->[2].($entry->[6].$entry->[4] ? "\n" : "").
			($entry->[6] ? "(".$entry->[6].") " : "").
			$entry->[4]." (".$entry->[5].")",
			-style => $self->style($entry->[3]));
    }
  }
  $t->autosetmode();
}

sub focus {
  my ($self,$frame)=@_;
  return unless ref($frame);
  my $h=$self->widget();
  foreach my $t (map { $_,$h->infoChildren($_) } $h->infoChildren()) {
    next unless ref($h->infoData($t));
    if ($self->data()->isEqual($h->infoData($t),$frame)) {
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
  foreach my $t (map { $_,$h->infoChildren($_) } $h->infoChildren()) {
    next unless ref($h->infoData($t));
    $id = $data->getFrameId($h->infoData($t));
    if (index($frames," $id ")>=0) {
      unless ($have) {
	$h->anchorSet($t);
	$h->see($t);
      }
      $have++;
      $h->selectionSet($t);
    }
  }
  return $have;
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

sub forget_data_pointers {
  my ($self)=@_;
  my $t=$self->widget();
  if ($t) {
    $t->delete('all');
  }
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
  return unless ref($word);
  my $h=$self->widget();
  foreach my $t ($h->infoChildren()) {
    if ($self->data()->isEqual($h->infoData($t),$word)) {
      $h->anchorSet($t);
      $h->selectionClear();
      $h->selectionSet($t);
      $h->see($t);
      return $t;
    }
  }
}

sub focused_word {
  my ($self)=@_;
  my $h=$self->widget();
  my $t=$h->infoAnchor();
  if (defined($t)) {
    return [$h->itemCget($t,1,'-text'),$h->itemCget($t,0,'-text')]
  }
  return undef;
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

sub forget_data_pointers {
  my ($self)=@_;
  my $t=$self->widget();
  if ($t) {
    $t->delete('all');
  }
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
		      -validate => 'all',
		      -vcmd => [\&edit_validate,$self],
		     );
  $w->configure(-invcmd => [\&bell,$self]);
  $w->pack(qw/-padx 6 -fill x -expand yes/);
  $frame->Frame(-takefocus => 0,qw/-height 6/)->pack();
  my $ex_label=$frame->Label(qw/-text Example -anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $example=$frame->Text(qw/-width 40 -height 5 -background white/);
  $example->pack(qw/-padx 6 -expand yes -fill both/);
  $example->bind($example,'<Tab>',[sub { shift->focusNext; Tk->break;}]);
  $example->bind($example,'<Return>',[sub { shift->insert('insert',"\n"); Tk->break;}]);
  $frame->Frame(-takefocus => 0,qw/-height 6/)->pack();

  my $note_label=$frame->Label(qw/-text Note -anchor nw -justify left/)
    ->pack(qw/-expand yes -fill x -padx 6/);
  my $note=$frame->Text(qw/-width 40 -height 5 -background white/);
  $note->pack(qw/-padx 6 -expand yes -fill both/);
  $note->bind($note,'<Tab>',[sub { shift->focusNext; Tk->break;}]);
  $note->bind($note,'<Return>',[sub { shift->insert('insert',"\n"); Tk->break;}]);
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

sub edit_validate {
  my ($self,$elements)=@_;
  $valid=$self->validate($elements);
  $self->widget()->configure(-foreground => $valid ? 'black' : 'red');
  return 1;
}

sub validate {
  my ($self,$elements)=@_;
  if (!defined($elements)) {
    $elements=$self->subwidget('elements')->get();
  }
  $elements=" $elements";
  return 1 if ($elements=~/^\s*EMPTY\s*$/);
  return $elements=~m{^(?:\s+(ACT|PAT|ADDR|EFF|ORIG|ACMP|ADVS|AIM|APP|APPS|ATT|BEN|CAUS|CNCS|COMPL|COND|CONJ|CONFR|CPR|CRIT|CSQ|CTERF|DENOM|DES|DIFF|DIR1|DIR2|DIR3|DISJ|DPHR|ETHD|EXT|EV|GRAD|HER|INTF|INTT|ID|LOC|MANN|MAT|MEANS|MOD|NORM|PAR|PARTL|PREC|PRED|REAS|REG|RESL|RESTR|RHEM|RSTR|SUBS|TFHL|TFRWH|THL|THO|TOWH|TPAR|TSIN|TTILL|TWHEN|VOC|VOCAT)(?:[[(][^])]*[])])?)+\s*$};
}

sub bell {
  my ($self)=@_;
#  $self->widget()->configure(-foreground => 'red');
#  $self->widget()->toplevel()->messageBox(-message => 'Invalid frame elements!',
#					  -title => 'Error',
#					  -type => 'OK');
#  $self->widget()->focus();
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
