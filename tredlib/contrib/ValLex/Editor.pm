#
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Editor;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;
require Tk::DialogBox;

sub show_dialog {
  my ($top,$data,$select_word)=@_;

  my $d = $top->DialogBox(-title => "Frame editor",
			  -buttons => ["Ok"],
			 );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind($d,'<Return>',[sub {  }]);
  my $vallex= TrEd::ValLex::Editor->new($data, $data->doc() ,$d,0,1);
  $vallex->pack(qw/-expand yes -fill both -side left/);
  $d->Show();
  $d->destroy();
}

sub create_widget {
  my ($self, $data, $field, $top, $reverse, $admin, @conf) = @_;

  my $frame = $top->Frame();
  $frame->configure(@conf) if (@conf);


  # Labeled frames

  my $wf = $frame->Frame();


  my $lexlist_frame=$wf->LabFrame(-label => "Words",
				     -labelside => "acrosstop",
				     qw/-relief raised/);
  $lexlist_frame->pack(qw/-expand yes -fill both -padx 4 -pady 4/);

  my $button_frame=$lexlist_frame->Frame();
  $button_frame->pack(qw/-side top -fill x/);

  my $addword_button=$button_frame->Button(-text => 'Add Word',
					  -command => [\&addword_button_pressed,
						      $self]);
  $addword_button->pack(qw/-padx 5 -side left/);


  my $adjuster = $frame->Adjuster();

  my $ff = $frame->Frame();



  my $lexframe_frame=$ff->LabFrame(-label => "Frames",
				      -labelside => "acrosstop",
				      qw/-relief sunken/);
  $lexframe_frame->pack(qw/-expand yes -fill both -padx 4 -pady 4/);

  my $fbutton_frame=$lexframe_frame->Frame();
  $fbutton_frame->pack(qw/-side top -fill x/);

  my $addframe_button=$fbutton_frame->Button(-text => 'Add');
  $addframe_button->pack(qw/-padx 5 -side left/);

  my $substituteframe_button=$fbutton_frame->Button(-text => 'Substitute');
  $substituteframe_button->pack(qw/-padx 5 -side left/);

  my $obsoleteframe_button=$fbutton_frame->Button(-text => 'Mark as Deleted',
						  -command => [\&obsolete_button_pressed,$self]);
  $obsoleteframe_button->pack(qw/-padx 5 -side left/);


  if ($admin) {
    my $deleteframe_button=$fbutton_frame->Button(-text => 'Delete',
						   -command => [\&delete_button_pressed,
								$self]);
    $deleteframe_button->pack(qw/-padx 5 -side left/);

    my $confirmframe_button=$fbutton_frame->Button(-text => 'Confirm',
						   -command => [\&confirm_button_pressed,
								$self]
						  );
    $confirmframe_button->pack(qw/-padx 5 -side left/);

    my $modifyframe_button=$fbutton_frame->Button(-text => 'Modify');
    $modifyframe_button->pack(qw/-padx 5 -side left/);
  }
  # List of Frames
  my $lexframelist =  TrEd::ValLex::FrameList->new($data, $field, $lexframe_frame,
						   qw/-height 15 -width 50/);
  $lexframelist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);


  ## Frame Note
  my $lexframenote = TrEd::ValLex::TextView->new($data, $field, $lexframe_frame, "Note",
						qw/ -height 2
						    -width 20
						    -spacing3 5
						    -wrap word
						    -scrollbars oe /);
  $lexframenote->pack(qw/-expand yes -fill both/);

  # Frame Problems
  my $lexframeproblem = TrEd::ValLex::FrameProblems->new($data, $field, $lexframe_frame,
							 qw/-width 30 -height 4/);
  $lexframeproblem->pack(qw/-fill both/);


  $lexframelist->configure(-browsecmd => [\&framelist_item_changed,
					  $self
					 ]);

  ## Word List
  my $lexlist = TrEd::ValLex::WordList->new($data, $field, $lexlist_frame,qw/-height 15 -width 0/);
  $lexlist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);


  ## Word Note
  my $lexnote = TrEd::ValLex::TextView->new($data, $field, $lexlist_frame, "Note",
						qw/ -height 2
						    -width 20
						    -spacing3 5
						    -wrap word
						    -scrollbars oe /);
  $lexnote->pack(qw/-expand yes -fill both/);

  # Word Problems
  my $lexproblem = TrEd::ValLex::FrameProblems->new($data, $field, $lexlist_frame,
						   qw/-width 20 -height 4/);
  $lexproblem->pack(qw/-fill both/);


  $lexlist->configure(-browsecmd => [
				     \&wordlist_item_changed,
				     $self
				    ]);

  $lexlist->fetch_data($doc);

  if ($reverse) {
    $wf->pack(qw/-side right -fill both -expand yes/);
    $adjuster->packAfter($wf, -side => 'right');
    $ff->pack(qw/-side right -fill both -expand yes/);
  } else {
    $wf->pack(qw/-side left -fill both -expand yes/);
    $adjuster->packAfter($wf, -side => 'left');
    $ff->pack(qw/-side left -fill both -expand yes/);
  }


  return $lexlist->widget(),{
	     frame        => $frame,
	     word_frame   => $lexlist_frame,
	     frame_frame  => $lexframe_frame,
	     framelist    => $lexframelist,
	     framenote    => $lexframenote,
	     frameproblem => $lexframeproblem,
	     wordlist     => $lexlist,
	     wordnote     => $lexnote,
	     wordproblem     => $lexproblem
	    };
}

sub wordlist_item_changed {
  my ($self,$item)=@_;

  my $h=$self->subwidget('wordlist')->widget();
  my $word=$h->infoData($item);

  $self->subwidget('wordnote')->set_data($self->data()->getSubElementNote($word));
  $self->subwidget('wordproblem')->fetch_data($word);
  $self->subwidget('framelist')->fetch_data($word);

}

sub framelist_item_changed {
  my ($self,$item)=@_;
  my $h=$self->subwidget('framelist')->widget();
  my $frame=$h->infoData($item);
  my $e;
  $self->subwidget('framenote')->set_data($self->data()->getSubElementNote($frame));
  $self->subwidget('frameproblem')->fetch_data($frame);
}

sub add_word_button_pressed {
  my ($self)=@_;

  my $top=$self->widget()->toplevel;
  my $d=ToplevelFrame()->DialogBox(-title => "Add word",
				-buttons => ["OK","Cancel"]);

  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Shift-Tab>',[sub { shift->focusPrev; }]);

  my $label=$d->add(qw/Label -wraplength 6i -justify left -text Lemma/);
  $t->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);

  my $ed=$d->Scrolled(qw/Entry -width 50 -scrollbars os/);
  $ed->pack(qw/-padx 0 -pady 10 -expand yes -fill x/);
  $ed->focus;

  if ($d->Show =~ /OK/) {
    my $result=$ed->get('0.0','end');

    $self->data()->addWord($result,"V");

    $d->destroy();
    return $var;
  } else {
    $d->destroy();
    return undef;
  }
}

sub confirm_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);

  $frame->setAttribute('status','reviewed');
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
}

sub delete_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);

  $frame->setAttribute('status','deleted');
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
}

sub obsolete_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);

  $frame->setAttribute('status','obsolete');
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
}

1;
