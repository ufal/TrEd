
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Editor;
use strict;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;
require Tk::DialogBox;
require Tk::Adjuster;
require Tk::Dialog;
require Tk::Checkbutton;
require Tk::Button;
require Tk::Optionmenu;

sub show_dialog {
  my ($top,$data,$select_field,$autosave,$confs,
      $wordlist_item_style,
      $framelist_item_style,
      $fe_confs)=@_;

  my $d = $top->DialogBox(-title => "Frame editor: ".
			  $data->getUserName($data->user()),
			  -buttons => ["Save & Close", "Save", "Undo Changes"],
			 );

  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind($d,'<Return>',[sub {  }]);
  my $vallex= TrEd::ValLex::Editor->new($data, $data->doc() ,$d,0,
					$wordlist_item_style,
					$framelist_item_style,
					$fe_confs);
  print "Editor created\n";
  print "Configuring...\n";
  $vallex->subwidget_configure($confs) if ($confs);
  print "Packing...\n";
  $vallex->pack(qw/-expand yes -fill both -side left/);
  print "getting words\n";
  {
    print "querying @{$select_field}\n";
    $vallex->wordlist_item_changed($vallex->subwidget('wordlist')
				 ->focus($data->findWordAndPOS(@{$select_field})));
    print "done.\n";
  }

#   my $adjuster = $d->Adjuster();
#   my $vallex2= TrEd::ValLex::Editor->new($data, $data->doc() ,$d,1,
# 					$wordlist_item_style,
# 					$framelist_item_style,
# 					$fe_confs);
#   my $double=0;
#   my $chb=$d->Checkbutton(-variable => \$double,
# 		       -command => [sub {
# 				      my($d,$vallex,$vallex2,$adjuster,$double)=@_;
# 				      if ($$double) {
# 					$adjuster->packAfter($vallex->frame(), -side => 'left');
# 					$vallex2->pack(qw/-expand yes -fill both -side left/);
# 				      } else {
# 					$adjuster->packForget();
# 					$vallex2->frame()->packForget();

# 				      }
# 				    },$d,$vallex,$vallex2,$adjuster,\$double])->pack(qw/-side left/);


  $d->Subwidget("B_Save & Close")->
    configure(-command =>
	      [sub {
		 my ($d,$f)=@_;
		 $d->{selected_button}='Save & Close';
	       },$d,$vallex]);

  $d->Subwidget("B_Save")->
    configure(-command =>
	      [sub {
		 my ($d,$f)=@_;
		 $f->save_data($d);
	       },$d,$vallex]);

  $d->Subwidget("B_Undo Changes")->
    configure(-command =>
	      [sub {
		 my ($d,$f)=@_;
		 $d->Busy(-recurse=> 1);
		 my $field=$f->subwidget("wordlist")->focused_word();
		 $f->data()->reload();
		 $f->fetch_data();
		 if ($field) {
		   my $word=$f->data()->findWordAndPOS(@{$field});
		   $f->wordlist_item_changed($f->subwidget("wordlist")->focus($word));

		 }
		 $d->Unbusy(-recurse=> 1);
	       },$d,$vallex]);
  print "Show!\n";

  $d->Show();
  if ($vallex->data()->changed()) {
    if ($autosave) {
      $vallex->save_data($top);
    } else {
      $vallex->ask_save_data($top);
    }
  }
  $vallex->destroy();
  undef $vallex;
  $d->destroy();
  undef $d;
}

sub create_widget {
  my ($self, $data, $field, $top, $reverse,
      $wordlist_item_style,
      $framelist_item_style,
      $fe_confs)= @_;

  my $frame;

  $frame = $top->Frame(-takefocus => 0);

  my $top_frame = $frame->Frame(-takefocus => 0)->pack(qw/-expand yes -fill both -side top/);

  # Labeled frames

  my $wf = $top_frame->Frame(-takefocus => 0);


  my $lexlist_frame=$wf->LabFrame(-takefocus => 0,-label => "Words",
				  -labelside => "acrosstop",
				     qw/-relief raised/);
  $lexlist_frame->pack(qw/-expand yes -fill both -padx 4 -pady 4/);

  my $button_frame=$lexlist_frame->Frame(-takefocus => 0);
  $button_frame->pack(qw/-side top -fill x/);

  if ($self->data()->user_is_annotator() or
      $self->data()->user_is_reviewer()) {
    my $addword_button=$button_frame->Button(-text => 'Add Word',
					     -command => [\&addword_button_pressed,
							  $self]);
    $addword_button->pack(qw/-padx 5 -side left/);
  }

  my $adjuster = $top_frame->Adjuster();

  my $ff = $top_frame->Frame(-takefocus => 0);

  my $lexframe_frame=$ff->LabFrame(-takefocus => 0,
				   -label => "Frames",
				      -labelside => "acrosstop",
				      qw/-relief sunken/);
  $lexframe_frame->pack(qw/-expand yes -fill both -padx 4 -pady 4/);

  my $fbutton_frame=$lexframe_frame->Frame(-takefocus => 0);
  $fbutton_frame->pack(qw/-side top -fill x/);


  # List of Frames
  my $lexframelist =
    TrEd::ValLex::FrameList->new($data, undef, $lexframe_frame,
				 $framelist_item_style,
				 qw/-height 10 -width 50/);


  # Buttons
  if ($self->data()->user_is_annotator() or
      $self->data()->user_is_reviewer()) {
    my $addframe_button=$fbutton_frame->Button(-text => 'Add',
					       -command => [\&addframe_button_pressed,$self]);
    $addframe_button->pack(qw/-padx 5 -side left/);

    my $substituteframe_button=$fbutton_frame->Button(-text => 'Substitute',
						      -command => [\&substitute_button_pressed,$self]);
    $substituteframe_button->pack(qw/-padx 5 -side left/);

    my $obsoleteframe_button=$fbutton_frame->Button(-text => 'Mark as Deleted',
						    -command => [\&obsolete_button_pressed,$self]);
    $obsoleteframe_button->pack(qw/-padx 5 -side left/);
  }

  if ($self->data()->user_is_reviewer()) {
    my $deleteframe_button=$fbutton_frame->Button(-text => 'Delete',
						   -command => [\&delete_button_pressed,
								$self]);
    $deleteframe_button->pack(qw/-padx 5 -side left/);

    my $confirmframe_button=$fbutton_frame->Button(-text => 'Confirm',
						   -command => [\&confirm_button_pressed,
								$self]
						  );
    $confirmframe_button->pack(qw/-padx 5 -side left/);

    my $modifyframe_button=$fbutton_frame->Button(-text => 'Modify',
						   -command => [\&modify_button_pressed,
								$self]);
    $modifyframe_button->pack(qw/-padx 5 -side left/);

    my $show_deleted=
      $fbutton_frame->
	Checkbutton(-text => 'Show Deleted',
		    -command => [
				 sub {
				   my ($self)=@_;
				   $self->
				     wordlist_item_changed($self->subwidget("wordlist")->widget()->infoAnchor());
				 },$self],
		    -variable =>
		    \$lexframelist->[$lexframelist->SHOW_DELETED]
		   );
    $show_deleted->pack(qw/-padx 5 -side left/);

  }


  $lexframelist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);


  ## Frame Note
  my $lexframenote = TrEd::ValLex::TextView->new($data, undef, $lexframe_frame, "Note",
						qw/ -height 2
						    -width 20
						    -spacing3 5
						    -wrap word
						    -scrollbars oe /);
  $lexframenote->pack(qw/-fill x/);

  # Frame Problems
  my $lexframeproblem = TrEd::ValLex::FrameProblems->new($data, undef, $lexframe_frame,
							 qw/-width 30 -height 3/);
  $lexframeproblem->pack(qw/-fill both/);


  $lexframelist->configure(-browsecmd => [\&framelist_item_changed,
					  $self
					 ]);

  ## Word List
  my $lexlist = TrEd::ValLex::WordList->new($data, undef, $lexlist_frame,
					    $wordlist_item_style,
					    qw/-height 10 -width 0/);
  $lexlist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);


  ## Word Note
  my $lexnote = TrEd::ValLex::TextView->new($data, undef, $lexlist_frame, "Note",
						qw/ -height 2
						    -width 20
						    -spacing3 5
						    -wrap word
						    -scrollbars oe /);
  $lexnote->pack(qw/-fill x/);

  # Word Problems
  my $lexproblem = TrEd::ValLex::FrameProblems->new($data, undef, $lexlist_frame,
						   qw/-width 20 -height 3/);
  $lexproblem->pack(qw/-fill both/);


  $lexlist->configure(-browsecmd => [
				     \&wordlist_item_changed,
				     $self
				    ]);

  $lexlist->fetch_data();

  if ($reverse) {
    $wf->pack(qw/-side right -fill both -expand yes/);
    $adjuster->packAfter($wf, -side => 'right');
    $ff->pack(qw/-side right -fill both -expand yes/);
  } else {
    $wf->pack(qw/-side left -fill both -expand yes/);
    $adjuster->packAfter($wf, -side => 'left');
    $ff->pack(qw/-side left -fill both -expand yes/);
  }

  $lexlist->widget()->focus;

  # Status bar
  my $info_line = TrEd::ValLex::InfoLine->new($data, undef, $frame, qw/-background white/);
  $info_line->pack(qw/-side bottom -fill x/);

  return $lexlist->widget(),{
	     frame        => $frame,
	     top_frame    => $top_frame,
	     word_frame   => $lexlist_frame,
	     frame_frame  => $lexframe_frame,
	     framelist    => $lexframelist,
	     framenote    => $lexframenote,
	     frameproblem => $lexframeproblem,
	     wordlist     => $lexlist,
	     wordnote     => $lexnote,
	     wordproblem  => $lexproblem,
	     infoline     => $info_line
	    },$fe_confs;
}

sub destroy {
  my ($self)=@_;
  $self->subwidget("framelist")->destroy();
  $self->subwidget("framenote")->destroy();
  $self->subwidget("frameproblem")->destroy();
  $self->subwidget("wordlist")->destroy();
  $self->subwidget("wordnote")->destroy();
  $self->subwidget("wordproblem")->destroy();
  $self->subwidget("infoline")->destroy();
  $self->SUPER::destroy();
}

sub frame_editor_confs {
  return $_[0]->[4];
}


sub ask_save_data {
  my ($self,$top)=@_;
  return 0 unless ref($self);
  my $d=$self->widget()->toplevel->Dialog(-text=>
					"Data changed!\nDo you want to save it?",
					-bitmap=> 'question',
					-title=> 'Question',
					-buttons=> ['Yes','No']);
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  my $answer=$d->Show();
  if ($answer eq 'Yes') {
    $self->save_data($top);
    return 0;
  } elsif ($answer eq 'Keep') {
    return 1;
  }
}

sub save_data {
  my ($self,$top)=@_;
  my $top=$top || $self->widget->toplevel;
  $top->Busy(-recurse=> 1);
  $self->data()->save();
  $top->Unbusy(-recurse=> 1);
}

sub fetch_data {
  my ($self)=@_;
  $self->subwidget("wordlist")->fetch_data();
  $self->wordlist_item_changed();
}

sub wordlist_item_changed {
  my ($self,$item)=@_;

  my $h=$self->subwidget('wordlist')->widget();
  my $word;
  $word=$h->infoData($item) if ($h->infoExists($item));
  $self->subwidget('wordnote')->set_data($self->data()->getSubElementNote($word));
  $self->subwidget('wordproblem')->fetch_data($word);
  $self->subwidget('framelist')->fetch_data($word);
  $self->subwidget('infoline')->fetch_word_data($word);
  $self->framelist_item_changed();
}

sub framelist_item_changed {
  my ($self,$item)=@_;
  my $h=$self->subwidget('framelist')->widget();
  my $frame;
  my $e;
  $frame=$h->infoData($item) if $item;
  $frame=undef unless ref($frame);
  $self->subwidget('framenote')->set_data($self->data()->getSubElementNote($frame));
  $self->subwidget('frameproblem')->fetch_data($frame);
  $self->subwidget('infoline')->fetch_frame_data($frame);
}

sub addword_button_pressed {
  my ($self)=@_;
  my $POS="V";
  my $top=$self->widget()->toplevel;
  my $d=$top->DialogBox(-title => "Add word",
				-buttons => ["OK","Cancel"]);

  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Shift-Tab>',[sub { shift->focusPrev; }]);

  my $poslab=$d->add(qw/Label -wraplength 6i -justify left -text POS/);
  $poslab->pack(qw/-padx 5 -side left/);

  my $pos=$d->Optionmenu(-options => [qw/V N A/], -variable => \$POS);
  $pos->pack(qw/-padx 5 -expand yes -fill x -side left/);

  my $label=$d->add(qw/Label -wraplength 6i -justify left -text Lemma/);
  $label->pack(qw/-padx 5 -side left/);

  my $ed=$d->Entry(qw/-width 50 -background white/);
  $ed->pack(qw/-padx 5 -expand yes -fill x -side left/);
  $ed->focus;



  if ($d->Show =~ /OK/) {
    my $result=$ed->get();

    my $word=$self->data()->addWord($result,$POS);
    if ($word) {
      $self->subwidget('wordlist')->fetch_data();
      $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
    } else {
      $self->wordlist_item_changed($self->subwidget('wordlist')->focus_by_text($result,$POS));
    }
    $d->destroy();
    return $result;
  } else {
    $d->destroy();
    return undef;
  }
}

sub addframe_button_pressed {
  my ($self)=@_;

  my $wl=$self->subwidget('wordlist')->widget();
  my $item=$wl->infoAnchor();
  return unless defined($item);
  my $word=$wl->infoData($item);
  return unless $word;

  my $top=$self->widget()->toplevel;
  my ($ok,$elements,$note,$example,$problem)=
    $self->show_frame_editor_dialog("Add frame for ".
				    $wl->itemCget($item,1,'-text'),
				    $self->frame_editor_confs,
				    "ACT(1) "
				   );

  if ($ok) {
    my $new=$self->data()->addFrame(undef,$word,$elements,$note,$example,$problem,$self->data()->user());
    $self->subwidget('framelist')->fetch_data($word);
    $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
    $self->framelist_item_changed($self->subwidget('framelist')->focus($new));
    return $new;
  } else {
    return undef;
  }
}

sub substitute_button_pressed {
  my ($self)=@_;

  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return unless defined($item);
  my $frame=$fl->infoData($item);
  return unless $frame;
  my $word=$self->data()->getWordForFrame($frame);
  my $top=$self->widget()->toplevel;
  my $elements=$self->data()->getFrameElementString($frame);
  my $note=$self->data()->getSubElementNote($frame);
  my $example=$self->data()->getFrameExample($frame);
  my $problem="";
  my $ok;
  ($ok,$elements,$note,$example,$problem)=
    $self->show_frame_editor_dialog("Substitute frame",
				    $self->frame_editor_confs,
				    $elements,$note,$example,$problem);

  if ($ok) {
    my $new=$self->data()->substituteFrame($word,$frame,$elements,$note,$example,$problem,$self->data()->user());
    $self->subwidget('framelist')->fetch_data($word);
    $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
    $self->framelist_item_changed($self->subwidget('framelist')->focus($new));
    return $new;
  } else {
    return undef;
  }
}

sub modify_button_pressed {
  my ($self)=@_;

  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return unless defined($item);
  my $frame=$fl->infoData($item);
  return unless $frame;
  my $word=$self->data()->getWordForFrame($frame);
  my $top=$self->widget()->toplevel;
  my $elements=$self->data()->getFrameElementString($frame);
  my $note=$self->data()->getSubElementNote($frame);
  my $example=$self->data()->getFrameExample($frame);
  my $problem="";
  my $ok;
  ($ok,$elements,$note,$example,$problem)=
    $self->show_frame_editor_dialog("Change frame",
				    $self->frame_editor_confs,
				    $elements,$note,$example,$problem);

  if ($ok) {
    $self->data()->modifyFrame($frame,$elements,$note,$example,$problem,$self->data()->user());
    $self->subwidget('framelist')->fetch_data($word);
    $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
    $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
    return $frame;
  } else {
    return undef;
  }
}


sub show_frame_editor_dialog {
  my ($self,$title,$confs,$elements,$note,$example,$problem)=@_;

  my $top=$self->widget()->toplevel;
  my $d=$top->DialogBox(-title => $title,
				-buttons => ["OK","Cancel"]);
  my $ed=TrEd::ValLex::FrameElementEditor->new($self->data(), undef, $d);
  $ed->subwidget_configure($confs) if ($confs);
  $ed->pack(qw/-expand yes -fill both/);
  $ed->subwidget('elements')->insert(0,$elements) unless $elements eq "";
  $ed->subwidget('note')->insert("0.0",$note) unless $note eq "";
  $ed->subwidget('example')->insert("0.0",$example) unless $example eq "";
  $ed->subwidget('problem')->insert("0",$problem) unless $problem eq "";
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Shift-Tab>',[sub { shift->focusPrev; }]);
  $d->bind('all','<Escape>'=> [sub { shift;
				     shift->{selected_button}='Cancel'; 
				   },$d ]);
  $d->Subwidget('B_OK')->configure(-command => [sub {
						  my ($cw,$ed)=@_;
						  if ($ed->validate()) {
						    $cw->{'selected_button'} = "OK";
						  } else {
						    $ed->bell();
						  }
						},$d,$ed
					       ]);
  if ($d->Show =~ /OK/) {
    my $elements=$ed->subwidget('elements')->get();
    my $note=$ed->subwidget('note')->get('0.0','end');
    my $example=$ed->subwidget('example')->get('0.0','end');
    my $problem=$ed->subwidget('problem')->get();
    $d->destroy();
    $note=~s/[\s\n]+$//g;
    $example=~s/[\s\n]+$//g;
    $ed->destroy();
    return (1,$elements,$note,$example,$problem);
  } else {
    $ed->destroy();
    $d->destroy();
    return (0);
  }
}

sub confirm_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);

  $self->data()->changeFrameStatus($frame,'reviewed','review');
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
  $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
}

sub delete_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);

  $self->data()->changeFrameStatus($frame,'deleted','delete');
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
  my $fanchor=$self->subwidget('framelist')->focus($frame);
  if ($fanchor ne "") {
    $self->framelist_item_changed($fanchor);
  }
}

sub obsolete_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);
  if ($self->data()->getFrameStatus($frame) eq "active") {
    $self->data()->changeFrameStatus($frame,'obsolete','obsolete');
    $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
    $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
  }
}

1;
