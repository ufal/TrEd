
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Editor;
use strict;
use base qw(TrEd::ValLex::FramedWidget);
use vars qw($reviewer_can_delete $reviewer_can_modify $display_problems);

require Tk::LabFrame;
require Tk::DialogBox;
require Tk::Adjuster;
require Tk::Dialog;
require Tk::Checkbutton;
require Tk::Button;
require Tk::Optionmenu;

sub limit { 100 }

sub new_dialog_window {
  my ($top,$data,$select_field,$autosave,$confs,
      $wordlist_item_style,
      $framelist_item_style,
      $fe_confs,
      $select_frame,
      $start_frame_editor,
      $bindings
     )=@_;

  my $d = $top->Toplevel(-title => "Frame editor: ".
			 $data->getUserName($data->user())
			);
  $d->withdraw;

  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind($d,'<Return>',[sub {  }]);
  my $button_frame=$d->Frame()->pack(qw(-fill x -side bottom));

  my $vallex= TrEd::ValLex::Editor->new($data, $data->doc() ,$d,0,
					$wordlist_item_style,
					$framelist_item_style,
					$fe_confs);

  $vallex->subwidget_configure($confs) if ($confs);
  $vallex->pack(qw/-expand 1 -fill both -side top/);
  {
    $vallex->wordlist_item_changed($vallex->subwidget('wordlist')
				 ->focus($data->findWordAndPOS(@{$select_field})));
    $vallex->subwidget('framelist')->select_frames($select_frame);
  }
  $d->Frame(qw/-height 3 -borderwidth 2 -relief sunken/)->
    pack(qw(-fill x -side top -pady 6));
  $button_frame->Frame()->pack(qw(-expand 1 -fill x -side left))->
    Button(-text => 'Save & Close',
	   -command =>
	   [sub {
	      my ($d,$f,$autosave,$top)=@_;
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
	    },$d,$vallex,$autosave,$top]
	  )->pack(qw(-padx 10 -expand 1));
  $button_frame->Frame()->pack(qw(-expand 1 -fill x -side left))->
    Button(-text => 'Save',
	   -command =>
	   [sub {
	      my ($d,$f)=@_;
	      $f->save_data($d);
	    },$d,$vallex])->pack(qw(-padx 10 -expand 1));
  $button_frame->Frame()->pack(qw(-expand 1 -fill x -side left))->
    Button(-text => 'Undo Changes',
	   -command =>[sub {
			 my ($d,$f)=@_;
			 $d->Busy(-recurse=> 1);
			 my $field=$f->subwidget("wordlist")->focused_word();
			 $f->data()->reload();
			 if ($field) {
			   my $word=$f->data()->findWordAndPOS(@{$field});
			   $f->wordlist_item_changed($f->subwidget("wordlist")->focus($word));
			 } else {
			   $f->subwidget("wordlist")->fetch_data();
			 }
			 $d->Unbusy(-recurse=> 1);
		       },$d,$vallex])->pack(qw(-padx 10 -expand 1));
  if (ref($bindings)) {
    while (my ($event, $command) = each %$bindings) {
      if (ref($command) eq 'ARRAY') {
	$d->bind($event, [@$command,$vallex]);
      } else {
	$d->bind($event, [$command,$vallex]);
      }
    }
  }

  if ($start_frame_editor) {
    $d->afterIdle([$vallex => 'addframe_button_pressed']);
  }

  return ($d,$vallex);
}

sub show_dialog {
  my ($top,$data,$select_field,$autosave,$confs,
      $wordlist_item_style,
      $framelist_item_style,
      $fe_confs,
      $select_frame,
      $start_frame_editor,
      $bindings
     )=@_;

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

  $vallex->subwidget_configure($confs) if ($confs);
  $vallex->pack(qw/-expand yes -fill both -side left/);
  {
    $vallex->wordlist_item_changed($vallex->subwidget('wordlist')
				 ->focus($data->findWordAndPOS(@{$select_field})));
    $vallex->subwidget('framelist')->select_frames($select_frame);
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
		 if ($field) {
		   my $word=$f->data()->findWordAndPOS(@{$field});
		   $f->wordlist_item_changed($f->subwidget("wordlist")->focus($word));

		 } else {
		   $f->subwidget("wordlist")->fetch_data();
		 }
		 $d->Unbusy(-recurse=> 1);
	       },$d,$vallex]);
  if (ref($bindings)) {
    while (my ($event, $command) = each %$bindings) {
      if (ref($command) eq 'ARRAY') {
	$d->bind($event, [@$command,$vallex]);
      } else {
	$d->bind($event, [$command,$vallex]);
      }
    }
  }
  if ($start_frame_editor) {
    $d->afterIdle([$vallex => 'addframe_button_pressed']);
  }
  $d->Show();
  if ($vallex->data()->changed()) {
    if ($autosave) {
      $vallex->save_data($top);
    } else {
      $vallex->ask_save_data($top);
    }
  }
  my $frame_id;
  do {
    my $fl=$vallex->subwidget('framelist')->widget();
    my $item=$fl->infoAnchor();
    if (defined($item)) {
      my $frame=$fl->infoData($item);
      if (ref($frame)) {
	$frame_id=$vallex->data()->getFrameId($frame);
      }
    }
  };
  $vallex->destroy();
  undef $vallex;
  $d->destroy();
  undef $d;
  return $frame_id;
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
  my $fbutton_frame2=$lexframe_frame->Frame(-takefocus => 0);

  my $fsearch_frame=$lexframe_frame->Frame(-takefocus => 1);

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
    if ($reviewer_can_delete) {
      my $deleteframe_button=$fbutton_frame->Button(-text => 'Delete',
						    -command => [\&delete_button_pressed,
								 $self]);
      $deleteframe_button->pack(qw/-padx 5 -side left/);
    }

    my $confirmframe_button=$fbutton_frame->Button(-text => 'Confirm',
						   -command => [\&confirm_button_pressed,
								$self]
						  );
    $confirmframe_button->pack(qw/-padx 5 -side left/);

    if ($reviewer_can_modify) {
      my $modifyframe_button=$fbutton_frame->Button(-text => 'Modify',
						    -command => [\&modify_button_pressed,
								 $self]);
      $modifyframe_button->pack(qw/-padx 5 -side left/);
    }

    my $moveup_button=$fbutton_frame2->Button(-text => 'Move Up',
						   -command => [\&move_button_pressed,
								$self,'up']
						  );
    $moveup_button->pack(qw/-padx 5 -side left/);

    my $movedown_button=$fbutton_frame2->Button(-text => 'Move Down',
						   -command => [\&move_button_pressed,
								$self,'down']
						  );
    $movedown_button->pack(qw/-padx 5 -side left/);

    my $nextactive_button=$fbutton_frame2->Button(-text => 'Next Active',
						 -command => [\&findactive_button_pressed,
							      $self,'next']
						);
    $nextactive_button->pack(qw/-padx 5 -side left/);

    my $prevactive_button=$fbutton_frame2->Button(-text => 'Prev Active',
						 -command => [\&findactive_button_pressed,
							      $self,'prev']
						);
    $prevactive_button->pack(qw/-padx 5 -side left/);

    if ($reviewer_can_delete) {
      my $show_deleted=
	$fbutton_frame2->
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
  }
  my $hide_obsolete=
    $fbutton_frame2->
      Checkbutton(-text => 'Show Obsolete',
		  -command => [
			       sub {
				 my ($self)=@_;
				 $self->
				   wordlist_item_changed($self->subwidget("wordlist")->widget()->infoAnchor());
			       },$self],
		  -variable =>
		  \$lexframelist->[$lexframelist->SHOW_OBSOLETE]
		 );
  $hide_obsolete->pack(qw/-padx 5 -side left/);

  my $use_superframes=
    $fbutton_frame2->
      Checkbutton(-text => 'Superframes',
		  -command => [
			       sub {
				 my ($self)=@_;
				 $self->
				   wordlist_item_changed($self->subwidget("wordlist")->widget()->infoAnchor());
			       },$self],
		  -variable =>
		  \$lexframelist->[$lexframelist->USE_SUPERFRAMES]
		 );
  $use_superframes->pack(qw/-padx 5 -side left/);


  # Frame search entry
  $fsearch_frame->Label(-text => 'Search frame: ')->pack(qw/-side left/);;
  my $search_entry = $fsearch_frame->Entry(qw/-width 50 -background white -validate key/,
					   -validatecommand => [\&quick_search,$self])
    ->pack(qw/-side left -fill both -expand yes/);
  $search_entry->bind('<Up>',[$lexframelist->widget(),'UpDown', 'prev']);
  $search_entry->bind('<Down>',[$lexframelist->widget(),'UpDown', 'next']);
  $search_entry->bind('<Return>',[sub { my ($w,$self)=@_;
					$self->quick_search($w->get);
				      },$self]);

  $fsearch_frame->pack(qw/-side top -pady 6 -fill x/);

  $lexframelist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);
  $fbutton_frame2->pack(qw/-side top -fill x/);


  ## Frame Note
#  my $lexframenote = TrEd::ValLex::TextView->new($data, undef, $lexframe_frame, "Note",
#						qw/ -height 2
#						    -width 20
#						    -spacing3 5
#						    -wrap word
#						    -scrollbars oe /);
#  $lexframenote->pack(qw/-fill x/);

  # Frame Problems
  my $lexframeproblem;
  if ($display_problems) {
    $lexframeproblem = TrEd::ValLex::FrameProblems->new($data, undef, $lexframe_frame,
							   qw/-width 30 -height 3/);
    $lexframeproblem->pack(qw/-fill both/);
  }
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
  my $lexproblem;
  if ($display_problems) {
    $lexproblem = TrEd::ValLex::FrameProblems->new($data, undef, $lexlist_frame,
						   qw/-width 20 -height 3/);
    $lexproblem->pack(qw/-fill both/);

  }

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

  $lexlist->subwidget('search')->focus;

  # Status bar
  my $info_line = TrEd::ValLex::InfoLine->new($data, undef, $frame, qw/-background white/);
  $info_line->pack(qw/-side bottom -fill x/);

  return $lexlist->widget(),{
	     frame        => $frame,
	     top_frame    => $top_frame,
	     word_frame   => $lexlist_frame,
	     frame_frame  => $lexframe_frame,
	     framelist    => $lexframelist,
#	     framenote    => $lexframenote,
	     frameproblem => $lexframeproblem,
	     wordlist     => $lexlist,
	     wordnote     => $lexnote,
	     wordproblem  => $lexproblem,
	     infoline     => $info_line,
	     framesearch  => $search_entry,
	     wordlistitemstyle  => $wordlist_item_style,
	     framelistitemstyle  => $framelist_item_style,
      	     hide_obsolete => \$hide_obsolete,
	    },$fe_confs;
}

sub destroy {
  my ($self)=@_;
  $self->subwidget("framelist")->destroy();
#  $self->subwidget("framenote")->destroy();
  $self->subwidget("frameproblem")->destroy() if $self->subwidget("frameproblem");
  $self->subwidget("wordlist")->destroy();
  $self->subwidget("wordnote")->destroy();
  $self->subwidget("wordproblem")->destroy() if $self->subwidget("wordproblem");
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
  my ($self,$word)=@_;
  $self->subwidget("wordlist")->fetch_data($word);
  $self->wordlist_item_changed();
}

sub wordlist_item_changed {
  my ($self,$item)=@_;

  my $h=$self->subwidget('wordlist')->widget();
  my $word;

#   print "$item ";
   $word=$h->infoData($item) if ($h->infoExists($item));
#   print $self->data->getLemma($word),"\n";
#   $self->subwidget('wordlist')->fetch_data($word);
#   $self->subwidget('wordlist')->focus($word);
   $self->subwidget('wordlist')->focus_index($item);
#   if ($h->infoAnchor()) {
#     print "Anchor: ",$h->infoAnchor()," ";
#     print $self->data->getLemma($h->infoData($h->infoAnchor())),"\n";
#   }
#   print "\n";

  $self->subwidget('framesearch')->delete(0,'end');
  $self->subwidget('wordnote')->set_data($self->data()->getSubElementNote($word));
  $self->subwidget('wordproblem')->fetch_data($word) if $self->subwidget('wordproblem');
  $self->subwidget('framelist')->fetch_data($word);
  $self->subwidget('infoline')->fetch_word_data($word);
  $self->framelist_item_changed();
}

sub framelist_item_changed {
  my ($self,$item)=@_;
  my $h=$self->subwidget('framelist')->widget();
  my $frame;
  my $e;
  $frame=$h->infoData($item) if defined($item);
  $frame=undef unless ref($frame);
#  $self->subwidget('framenote')->set_data($self->data()->getSubElementNote($frame));
  $self->subwidget('frameproblem')->fetch_data($frame) if $self->subwidget("frameproblem");
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

  my $ed=$d->Entry(qw/-width 50 -background white/,
		   -font =>
		   $self->subwidget('wordlist')->subwidget('wordlist')
		   ->Subwidget('scrolled')->cget('-font')
		  );
  $ed->pack(qw/-padx 5 -expand yes -fill x -side left/);
  $ed->focus;



  if ($d->Show =~ /OK/) {
    my $result=$ed->get();

    my $word=$self->data()->addWord($result,$POS);
    if ($word) {
      $self->subwidget('wordlist')->fetch_data($result);
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
  return unless ref($frame);
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
  return unless ref($frame);
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

sub findactive_button_pressed {
  my ($self,$which)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return unless defined($item);
  my $frame=$fl->infoData($item);
  if ($which eq 'next') {
    $frame = $self->data()->findNextFrame($frame,'active',
					  $self->subwidget('wordlist')->pos_filter());
  } else {
    $frame = $self->data()->findPrevFrame($frame,'active',
					  $self->subwidget('wordlist')->pos_filter());
  }
  return unless ref($frame);
  my $word=$self->data()->getWordForFrame($frame);
  $self->subwidget('framelist')->fetch_data($word);
  $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
  $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
}

sub move_button_pressed {
  my ($self,$where)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return unless defined($item);
  my $frame=$fl->infoData($item);
  return unless ref($frame);
  my $word=$self->data()->getWordForFrame($frame);
  if ($where eq 'up') {
    my $previtem=$fl->infoPrev($item);
    return unless ($previtem ne "");
    my $prevframe=$fl->infoData($previtem);
    return unless ref($prevframe);
    $self->data()->moveFrameBefore($frame,$prevframe);
  } else {
    my $nextitem=$fl->infoNext($item);
    return unless ($nextitem ne "");
    my $nextframe=$fl->infoData($nextitem);
    return unless ref($nextframe);
    $self->data()->moveFrameAfter($frame,$nextframe);
  }
  $self->subwidget('framelist')->fetch_data($word);
  $self->wordlist_item_changed($self->subwidget('wordlist')->focus($word));
  $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
}

sub show_frame_editor_dialog {
  my ($self,$title,$confs,$elements,$note,$example,$problem)=@_;

  my $top=$self->widget()->toplevel;
  my $d=$top->DialogBox(-title => $title,
				-buttons => ["OK","Cancel"]);
  $d->bind($d,'<Return>', sub {
	     my $w=shift;
	     my $f=$w->focusCurrent;
	     $f->Invoke if ($f and $f->isa('Tk::Button'));
	     Tk->break;
	   } );
  my $ed=TrEd::ValLex::FrameElementEditor->new($self->data(), undef, $d);
  $ed->subwidget_configure($confs) if ($confs);
  $ed->pack(qw/-expand yes -fill both/);
  $ed->subwidget('elements')->insert(0,$elements) unless $elements eq "";
  $ed->subwidget('note')->insert("0.0",$note) unless $note eq "";
  $ed->subwidget('example')->insert("0.0",$example) unless $example eq "";
  $ed->subwidget('problem')->insert("0",$problem) unless $problem eq "";
  $d->bind($ed->subwidget('elements'),'<Return>', [sub { $_[1]->Subwidget('B_OK')->Invoke },$d]);
  $d->bind($ed->subwidget('problem'),'<Return>', [sub { $_[1]->Subwidget('B_OK')->Invoke },$d]);
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
    $note=~s/^[\s\n]+//g;
    $note=~s/[\s\n]+$//g;
    $note=~s/[\s]*\n[\n\s]*/;/g;
    $example=~s/^[\s\n]+//g;
    $example=~s/[\s\n]+$//g;
    $example=~s/[\s]*\n[\n\s]*/;/g;
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
  return unless ref($frame);
  if ($self->data()->getFrameStatus($frame) eq 'reviewed') {
    $self->data()->changeFrameStatus($frame,'active','unreview');
  } else {
    $self->data()->changeFrameStatus($frame,'reviewed','review');
  }
  $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
  $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
}

sub delete_button_pressed {
  my ($self)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  my $item=$fl->infoAnchor();
  return if $item eq "";
  my $frame=$fl->infoData($item);
  return unless ref($frame);
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
  return unless ref($frame);
  my $status=$self->data()->getFrameStatus($frame);
  if ($status eq "active" or $status eq "reviewed") {
    $self->data()->changeFrameStatus($frame,'obsolete','obsolete');
    $self->wordlist_item_changed($self->subwidget('wordlist')->widget()->infoAnchor());
    $self->framelist_item_changed($self->subwidget('framelist')->focus($frame));
  }
}

sub quick_search {
  my ($self,$value)=@_;
  return defined($self->focus_by_text($value));
}


sub focus_by_text {
  my ($self,$text,$caseinsensitive)=@_;
  my $h=$self->subwidget('framelist')->widget();
  use locale;
  my $st = $h->infoAnchor();
  my ($t) = ($st eq "") ? $h->infoChildren("") : $st;
  while ($t ne "") {
    my $item=$h->itemCget($t,0,'-text');
    if (!$caseinsensitive and index($item,$text)>=0 or
	$caseinsensitive and index(lc($item),lc($text))>=0) {
      $h->anchorSet($t);
      $h->selectionClear();
      $h->selectionSet($t);
      $h->see($t);
      return $t;
    }
    $t=$h->infoNext($t);
    last if $t eq $st;
    ($t) = $h->infoChildren("") if ($t eq "" and $st);
    last if $t eq $st;
  }
  return undef;
}

1;
