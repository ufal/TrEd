# $Id$ '
#
# Copyright (c) 2001-2003 by Petr Pajas <pajas@matfyz.cz>
#
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Chooser;
use strict;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;

sub show_dialog {
  my @ret = reusable_dialog(@_);
  my $chooser = shift @ret;
  $chooser->destroy_dialog();
  return @ret;
}

sub destroy_dialog {
  my ($self)=@_;
  my $d = $self->widget->toplevel;
  $self->destroy();
  $d->destroy();
}

sub create_toplevel {
  my ($title,
      $top,
      $confs,
      $item_style,
      $frame_browser_styles,
      $frame_browser_wordlist_item_style,
      $frame_browser_framelist_item_style,
      $frame_editor_styles,
      $show_obsolete_ref,
      $data,
      $field,
      $select_frame,
      $start_editor,
      $assign_callback,
      $destroy_callback
     )=@_;

  my $d = $top->Toplevel(-title => $title);
  $d->withdraw;
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  my $top = $d->Frame();
  my $bot = $d->Frame();
  $bot->pack(qw/-side bottom -fill x -ipady 3 -ipadx 3/);
  $top->pack(qw/-side top -fill both -ipady 3 -ipadx 3 -expand 1/);

  my $chooser =
    TrEd::ValLex::Chooser->new($data, $field, $top,
			       ((ref($field) eq "ARRAY") ?
				scalar(@$field)/2 : 1),
			       $item_style,
			       $frame_browser_styles,
			       $frame_browser_wordlist_item_style,
			       $frame_browser_framelist_item_style,
			       $frame_editor_styles,
			       undef,
			       $bot,
			       -width => '25c');
  $chooser->subwidget_configure($confs) if ($confs);
  ${$chooser->subwidget('hide_obsolete')}=$$show_obsolete_ref;
  if (defined $assign_callback) {
    my $assign_cb = ref($assign_callback) eq 'ARRAY' ?
      [ @$assign_callback, $chooser ] : [ $assign_callback,$chooser ];
    my $ab = $bot->Button(-text => 'Assign',
			  -command => $assign_cb)->pack(-side => 'left',-expand => 1);
    $d->bind('<Return>',sub { $ab->flash; $ab->invoke });
    $d->bind('<KP_Enter>',sub { $ab->flash; $ab->invoke });
    $chooser->widget()->bind('<Double-1>'=> sub { $ab->invoke });
  }
  $bot->Button(-text => 'Close',
	       -command => [$destroy_callback,$d] )->pack(-side => 'right', -expand => 1);
  $d->protocol('WM_DELETE_WINDOW' => [$destroy_callback,$d]);
  $chooser->subwidget('frame')->pack(qw/-fill both -expand 1/);
  $d->bind($d,'<Escape>'=> [$destroy_callback,$d]);


  $chooser->prepare($show_obsolete_ref, $field, $select_frame, $start_editor);
  $chooser->widget->focus;
#  $d->resizable(0,0);
  $d->Popup;
  return $chooser;
}

sub reusable_dialog {
  my ($title,$top,
      $confs,
      $item_style,
      $frame_browser_styles,
      $frame_browser_wordlist_item_style,
      $frame_browser_framelist_item_style,
      $frame_editor_styles,
      $show_obsolete_ref,
      $data,
      $field,
      $select_frame,
      $start_editor
     )=@_;

  my $d = $top->DialogBox(-title => $title,
			  -buttons => ['Choose', 'Cancel'],
			  -default_button => 'Choose'
			 );
  $d->bind('<Return>',\&TrEd::ValLex::Widget::dlgReturn);
  $d->bind('<KP_Enter>',\&TrEd::ValLex::Widget::dlgReturn);
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Escape>'=> [sub { shift; shift->{selected_button}='Cancel'; },$d ]);
  my $chooser =
    TrEd::ValLex::Chooser->new($data, $field, $d,
			       ((ref($field) eq "ARRAY") ?
				scalar(@$field)/2 : 1),
			       $item_style,
			       $frame_browser_styles,
			       $frame_browser_wordlist_item_style,
			       $frame_browser_framelist_item_style,
			       $frame_editor_styles,
			       undef, 1,-width => '25c');
  $chooser->subwidget_configure($confs) if ($confs);
  ${$chooser->subwidget('hide_obsolete')}=$$show_obsolete_ref;
  $chooser->widget()->bind('<Double-1>'=> [sub { shift; shift->{selected_button}='Choose'; },$d ]);
  $chooser->subwidget('frame')->pack(qw/-expand yes -fill both -side left/);
  $chooser->prepare($show_obsolete_ref, $field, $select_frame, $start_editor);
  if (TrEd::ValLex::Widget::ShowDialog($d,$chooser->widget) eq 'Choose') {
    my @frames=$chooser->get_selected_frames();
    my $real=$chooser->get_selected_element_string();
    $$show_obsolete_ref=${$chooser->subwidget('hide_obsolete')};
    return ($chooser,$chooser->data->conv->decode(join("|",map { $_->getAttribute('frame_ID') } @frames)),$real);
  } else {
    $$show_obsolete_ref=${$chooser->subwidget('hide_obsolete')};
    return ($chooser);
  }
}

sub prepare {
  my ($chooser, $show_obsolete_ref, $field,  $select_frame, $start_editor)=@_;
  if (ref($field) eq "ARRAY") {
    foreach my $fl (@{$chooser->subwidget('framelists')}) {
      $fl->show_obsolete(!$$show_obsolete_ref);
      $fl->fetch_data($chooser->data()->findWordAndPOS(@{$fl->field()}));
    }
  }
  if ($select_frame) {
    my ($fl)=@{ $chooser->subwidget("framelists") };
    $chooser->focus_framelist($fl) if ($fl);
    if (ref($select_frame) eq "ARRAY") {
      if (@$select_frame) {
	foreach (@{$chooser->subwidget("framelists")}) {
	  if ($_->select_frames(@$select_frame)) {
	    $_->widget()->focus();
	    $chooser->framelist_item_changed();
	  }
	}
      } else {
	if ($chooser->widget()->infoExists(0)) {
#	  $chooser->widget()->anchorSet(0);
#	  $chooser->widget()->selectionSet(0);
	  $chooser->widget()->focus();
	  $chooser->framelist_item_changed(0);
	}
      }
    } else {
      foreach (@{$chooser->subwidget("framelists")}) {
	if ($_->select_frames($select_frame)) {
	  $chooser->framelist_item_changed();
	  $_->widget()->focus();
	}
      }
    }
  } else {
    if ($chooser->widget()->infoExists(0)) {
#      $chooser->widget()->anchorSet(0);
#      $chooser->widget()->selectionSet(0);
      $chooser->widget()->focus();
      $chooser->framelist_item_changed(0);
    }
  }
  if ($start_editor) {
    unless ($chooser->focused_framelist()) {
      my ($fl) = grep { $_->field()->[0] eq $start_editor->[0] and
			  $_->field()->[1] eq $start_editor->[1]
		      } @{$chooser->subwidget('framelists')};
      $chooser->focus_framelist($fl) if ($fl);
    }
    $chooser->widget->toplevel->afterIdle([sub { $_[0]->edit_button_pressed(1) },$chooser]);
  }

}

sub reuse {
  my ($self,
      $title,
      $show_obsolete_ref,
      $field,
      $select_frame,
      $start_editor,
      $modal
     )=@_;
  my $d = $self->widget()->toplevel();
  $d->configure(-title => $title) if defined $title;
  @{$self->field} = @$field;
  my $count = ref($field) eq 'ARRAY' ? scalar(@$field/2) : 1;
  my $lexframelists=$self->subwidget('framelists');
  my $lexframelabels=$self->subwidget('framelist_labels');
  for (my $i=0; $i<$count; $i++) {
    # List of Frames
    if (ref($lexframelists->[$i])) {
      $lexframelabels->[$i]->configure(-text => $field->[2*$i]);
      @{$lexframelists->[$i]->field()} =
	($field->[2*$i], $field->[2*$i+1]);
    }
  }
  $self->prepare($show_obsolete_ref, $field, $select_frame, $start_editor);
  $self->widget()->focus();
  if ($modal) {
    if (TrEd::ValLex::Widget::ShowDialog($d,$self->widget) eq 'Choose') {
      my @frames=$self->get_selected_frames();
      my $real=$self->get_selected_element_string();
      $$show_obsolete_ref=${$self->subwidget('hide_obsolete')};
    return ($self->data->conv->decode(join("|",map { $_->getAttribute('frame_ID') } @frames)),$real);
    } else {
      $$show_obsolete_ref=${$self->subwidget('hide_obsolete')};
      return undef;
    }
  } else {
    $d->deiconify;
    $d->focus;
    $d->raise;
    $self->widget->focus;
  }
}

sub create_widget {
  my ($self, $data, $field, $top,
      $count,
      $item_style,
      $frame_browser_styles,
      $frame_browser_wordlist_item_style,
      $frame_browser_framelist_item_style,
      $frame_editor_styles,
      $cb,
#      $no_choose_button,
      $fbutton_frame,
      @conf) = @_;

  my $frame = $top->Frame();
  $frame->configure(@conf) if (@conf);

  my $info_line = TrEd::ValLex::InfoLine->new($data, undef, $frame, qw/-background white/);
  $info_line->pack(qw/-side bottom -fill x -expand 0/);


  # Labeled frames

#  my $lexframe_frame=$frame->LabFrame(-label => "Frames",
#				   -labelside => "acrosstop",
#				   qw/-relief sunken/);
  my $lexframe_frame=$frame->Frame();

  $lexframe_frame->pack(qw/-side top -expand 1 -fill both -padx 4/);


  unless (defined($fbutton_frame)) {
    $fbutton_frame=$lexframe_frame->Frame();
    $fbutton_frame->pack(qw/-side top -expand 0 -fill x/);
  }

#   unless ($no_choose_button) {
#     my $choose_button=$fbutton_frame->Button(-text => 'Choose',
# 					     -command => [
# 							  \&choose_button_pressed,
# 							  $self
# 							 ]);
#     $choose_button->pack(qw/-padx 5 -side left/);
#   }

  my $editframes_button=$fbutton_frame->Button(-text => 'Edit Frames',
					       -command => [
							    \&edit_button_pressed,
							    $self
							   ]);

  $editframes_button->pack(qw/-padx 5 -side left/); 
  my $hide_obsolete=0;
  my $hide_obsolete_button=
    $fbutton_frame->
      Checkbutton(-text => 'Hide obsolete',
		  -variable => \$hide_obsolete,
		  -command =>
		  [
		   sub {
		     my ($self)=@_;
		     foreach my $fl (@{$self->subwidget('framelists')}) {
		       $fl->show_obsolete(!${$self->subwidget('hide_obsolete')});
		       $fl->fetch_data($self->data()->findWordAndPOS(@{$fl->field()}));
		     }
		     $self->framelist_item_changed();
		   },
		   $self
		  ]);
  $hide_obsolete_button->pack(qw/-padx 5 -side left/);
  my $multiselect_button=
    $fbutton_frame->
      Checkbutton(-text => 'Multiple select',

		  -command =>
		  [
		   sub {
		     my ($self)=@_;
		     foreach my $f (@{$self->subwidget('framelists')}) {
		       my $fl=$f->widget();
		       my $mode = $fl->cget('-selectmode');
		       if ($mode eq 'extended') {
			 $fl->configure(-selectmode => 'browse');
		       } else {
			 $fl->configure(-selectmode => 'extended');
		       }
		     }
		   },
		   $self
		  ]);

  $multiselect_button->pack(qw/-padx 5 -side left/);

  my @lexframelists=();
  my @lexframelistlabels=();
  my $focused_framelist;
  my $size=10;
  $size/=$count if $count>0;
  for (my $i=0; $i<$count; $i++) {
    # List of Frames
    $lexframe_frame->Frame(-height => 12)->pack(qw/-expand 0 -fill x/);
    my $lexframelistlab=$lexframe_frame->Label(-text => $self->field()->[2*$i],
			   qw/-anchor nw -justify left/)
      ->pack(qw/-fill x -expand 0 -padx 4/);
    my $lexframelist =  TrEd::ValLex::FrameList->new($data,
						     [
						      $self->field()->[2*$i],
						      $self->field()->[2*$i+1]
						     ],
						     $lexframe_frame,
						     $item_style,
						     -height => $size,
						     qw/-width 90/,
						     -command => [
								  \&item_chosen,
								  $self
								 ]
						    );
    $lexframelist->widget()->bind('<FocusIn>',[\&focus_framelist,$self,$lexframelist]);
    $lexframelist->pack(qw/-expand 1 -fill both -padx 6/);
    $lexframelists[$i]=$lexframelist;
    $lexframelistlabels[$i]=$lexframelistlab;
    $lexframelist->configure(-browsecmd => [\&framelist_item_changed,
					    $self
					   ]);

    my $fsearch_frame=$lexframe_frame->Frame(-takefocus => 1);
    $fsearch_frame->Label(-text => 'Search frame: ',-underline => 7)->pack(qw/-side left/);
    $fsearch_frame->pack(qw/-side top -pady 6 -fill x/);
    my $search_entry = $fsearch_frame->Entry(qw/-width 50 -background white -validate key/,
					     -validatecommand => [\&quick_search,$self,$lexframelist])
      ->pack(qw/-side left -fill both -expand yes/);
    $top->toplevel->bind('<Alt-f>',sub { $search_entry->focus() }) if $i==0;
    $search_entry->bind('<Up>',[$lexframelist->widget(),'UpDown', 'prev']);
    $search_entry->bind('<Down>',[$lexframelist->widget(),'UpDown', 'next']);
    $search_entry->bind('<F3>',[sub { my ($w,$self,$fl)=@_;
				      my $h=$fl->widget();
				      my $t = $h->infoAnchor();
				      $h->UpDown('next');
				      if ($t eq $h->infoAnchor()
					  or
					  !$self->quick_search($fl,$w->get)) {
					($t) = $h->infoChildren("");
					$h->anchorSet($t);
					$h->selectionClear();
					$h->selectionSet($t);
					$h->see($t);
					$self->quick_search($fl,$w->get);
				      }
				    },$self,$lexframelist]);

    $search_entry->bind('<Return>',[sub { my ($w,$self,$fl)=@_;
					  $self->quick_search($fl,$w->get);
					},$self,$lexframelist]);
    $search_entry->bind('<KP_Enter>',[sub { my ($w,$self,$fl)=@_;
					    $self->quick_search($fl,$w->get);
					  },$self,$lexframelist]);

  }

#  my $lexframenote=TrEd::ValLex::TextView->new($data, undef, $lexframe_frame, "Note",
#					    qw/ -height 2
#						-width 20
#						-spacing3 5
#						-wrap word
#						-scrollbars oe /);
#  $lexframenote->pack(qw/-fill x/);


  return $lexframelists[0]->widget(),{
	     callback     => $cb,
	     frame        => $frame,
	     frame_frame  => $lexframe_frame,
	     framelists    => \@lexframelists,
	     framelist_labels    => \@lexframelistlabels,
	     focused_framelist => \$focused_framelist,
	     hide_obsolete => \$hide_obsolete,
#	     framenote    => $lexframenote
#	     frameproblem => $lexframeproblem,
	     infoline     => $info_line
	    }, {
		items => $item_style,
		editor => $frame_browser_styles,
		editor_wordlist_items => $frame_browser_wordlist_item_style,
		editor_framelist_items => $frame_browser_framelist_item_style,
		frame_editor => $frame_editor_styles
	       };
}

sub quick_search {
  my ($self,$fl,$value)=@_;
  return defined($self->focus_by_text($value,$fl));
}


sub focus_by_text {
  my ($self,$text,$fl,$caseinsensitive)=@_;
  my $h=$fl->widget();
#  use locale;
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


sub focus_framelist {
  my ($w,$self,$framelist);
  if ($_[0]->isa('Tk::Widget')) {
    ($w,$self,$framelist)=@_;
  } else {
    ($self,$framelist)=@_;
  }
  return unless ref($framelist);
  $self->unselect_other_framelists($framelist);
  ${$self->subwidget('focused_framelist')}=$framelist;
}

sub framelist_item_changed {
  my ($self,$item)=@_;
  return unless $self->focused_framelist();
  my $h=$self->focused_framelist()->widget();
  $item = $item || $h->infoAnchor();
  my $frame;
  my $e;
  $frame=$h->infoData($item) if $item ne "";
  $frame=undef unless ref($frame);
  $self->subwidget('infoline')->fetch_frame_data($frame);
#  $self->subwidget('framenote')->set_data($self->data()->getSubElementNote($frame));
}


sub destroy {
  my ($self)=@_;
  foreach (@{$self->subwidget('framelists')}) {
    $_->destroy();
  }
  $self->subwidget("infoline")->destroy();
  $self->SUPER::destroy();
}

sub style {
  return $_[0]->[4]->{$_[1]};
}

sub callback {
  my ($self)=@_;
  my $cb=$self->subwidget('callback');
  return unless $cb;
  eval {
    &$cb(@_);
  }
}

sub get_selected_element_string {
  my ($self)=@_;
  my $f=$self->focused_framelist();
  return "" unless ref($f);
  my $fl=$f->widget();
  my @selection=$fl->infoSelection();
  if ($#selection==0) {
    my $data=$fl->infoData($selection[0]);
    if (ref($data)) {
      return $self->data()->getFrameElementString($data);
    } else {
      my $text=$fl->itemCget($selection[0],0,'-text');
      ($text) = $text=~/^(.*)/;
      return $text;
    }
  } else {
    return "";			# if multiple frames are selected return nothing
  }
}

sub get_selected_frames {
  my ($self)=@_;
  my @frames;
  my $f=$self->focused_framelist();
  return () unless ref($f);
  my $fl=$f->widget();
  my $data;
  foreach my $item ($fl->infoSelection()) {
    $data=$fl->infoData($item);
    if (ref($data)) {
      push @frames,$fl->infoData($item);
    } else {
      foreach my $kid ($fl->infoChildren($item)) {
	push @frames,$fl->infoData($kid);
      }
    }
  }
  return @frames;
}

sub get_current_frame {
  my ($self,$item)=@_;
  foreach my $f (@{$self->subwidget('framelists')}) {
    my $fl=$f->widget();
    next unless $fl eq $fl->focusCurrent();
      $item = $fl->infoAnchor() unless defined($item);
    return $fl->infoData($item) if defined($item);
  }
  return undef;
}

sub item_chosen {
  my ($self,$item)=@_;
  $self->callback($self->get_selected_frames($item));
}

sub choose_button_pressed {
  my ($self)=@_;
  $self->callback($self->get_selected_frames());
}

sub focused_framelist {
  my ($self)=@_;
  my $fl=$self->subwidget('focused_framelist');
  return $$fl;
}

sub unselect_other_framelists {
  my ($self,$framelist)=@_;
  foreach my $f (@{$self->subwidget('framelists')}) {
    if ($framelist ne $f) {
      $f->widget()->selectionClear();
      $f->widget()->anchorClear();
    }
  }
}

sub find_framelist_index {
  my ($self,$fl)=@_;
  my $i=0;
  foreach my $f (@{$self->subwidget('framelists')}) {
    return $i if ($fl eq $f);
    $i++;
  }
  return undef;
}

sub edit_button_pressed {
  my ($self,$start_frame_editor)=@_;
  my $fl=$self->focused_framelist();
  return unless defined($fl);
  my ($frame)= $self->get_selected_frames();
  $frame= ref($frame) ? $self->data()->getFrameId($frame) : undef;
  my $frame=TrEd::ValLex::Editor::show_dialog($self->widget()->toplevel,
				    $self->data(),
				    $fl->field(),
				    1,
				    $self->style('editor'),
				    $self->style('editor_wordlist_items'),
				    $self->style('editor_framelist_items'),
				    $self->style('frame_editor'),
				    $frame,
				    $start_frame_editor
				   );
  eval { Tk->break; };
  if (ref($self->field()) eq "ARRAY") {
    my $i=0;
    foreach my $f (@{$self->subwidget('framelists')}) {
      $f->fetch_data($self->data()->findWordAndPOS(
						   @{$f->field()}
						  ));
    }
    $self->widget()->toplevel()->update();
    foreach my $f (@{$self->subwidget('framelists')}) {
      if ($f->select_frames($frame)) {
	$f->widget()->focus();
	$self->focus_framelist($f);
      }
    }
    $self->framelist_item_changed();
  }
}

1;
