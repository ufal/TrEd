#
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Chooser;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;

sub show_dialog {
  my ($title,$top,
      $confs,
      $item_style,
      $frame_browser_styles,
      $frame_browser_wordlist_item_style,
      $frame_browser_framelist_item_style,
      $frame_editor_styles,
      $data,$word,$select_frame,$start_editor)=@_;

  my $d = $top->DialogBox(-title => $title,
			  -buttons => ['Choose', 'Cancel'],
			  -default_button => 'Choose'
			 );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Escape>'=> [sub { shift; shift->{selected_button}='Cancel'; },$d ]);
  my $chooser =
    TrEd::ValLex::Chooser->new($data, $word, $d,
			       $item_style,
			       $frame_browser_styles,
			       $frame_browser_wordlist_item_style,
			       $frame_browser_framelist_item_style,
			       $frame_editor_styles,
			       undef, 1);
  $chooser->subwidget_configure($confs) if ($confs);
  $chooser->widget()->bind('all','<Double-1>'=> [sub { shift; shift->{selected_button}='Choose'; },$d ]);
  $chooser->pack(qw/-expand yes -fill both -side left/);
  if ($select_frame) {
    if (ref($select_frame) eq "ARRAY") {
      if (@$select_frame) {
	$chooser->subwidget("framelist")->select_frames(@$select_frame);
      } else {
	if ($chooser->widget()->infoExists(0)) {
	  $chooser->widget()->anchorSet(0);
	  $chooser->widget()->selectionSet(0);
	}
      }
    } else {
      $chooser->subwidget("framelist")->select_frames($select_frame);
    }
  } else {
    if ($chooser->widget()->infoExists(0)) {
      $chooser->widget()->anchorSet(0);
      $chooser->widget()->selectionSet(0);
    }
  }
  $chooser->widget()->focus();
  if ($start_editor) {
    $chooser->widget()->afterIdle([\&TrEd::ValLex::Chooser::edit_button_pressed,$chooser]);
  }

  if ($d->Show() eq 'Choose') {
    my @frames=$chooser->get_selected_frames();
    my $real="";
    if ($#frames==0) {
      $real=$chooser->data()->getFrameElementString($frames[0]);
    }
    $d->destroy();
    return (join("|",map { $_->getAttribute('frame_ID') } @frames),$real);
  } else {
    $d->destroy();
    return undef;
  }
}

sub create_widget {
  my ($self, $data, $word, $top,
      $item_style,
      $frame_browser_styles,
      $frame_browser_wordlist_item_style,
      $frame_browser_framelist_item_style,
      $frame_editor_styles,
      $cb,
      $no_choose_button, @conf) = @_;

  my $frame = $top->Frame();
  $frame->configure(@conf) if (@conf);

  # Labeled frames

  my $lexframe_frame=$top->LabFrame(-label => "Frames",
				   -labelside => "acrosstop",
				   qw/-relief sunken/);
  $lexframe_frame->pack(qw/-expand yes -fill both -padx 4 -pady 4/);

  my $fbutton_frame=$lexframe_frame->Frame();
  $fbutton_frame->pack(qw/-side top -fill x/);


  unless ($no_choose_button) {
    my $choose_button=$fbutton_frame->Button(-text => 'Choose',
					     -command => [
							  \&choose_button_pressed,
							  $self
							 ]);
    $choose_button->pack(qw/-padx 5 -side left/);
  }

  my $editframes_button=$fbutton_frame->Button(-text => 'Edit Frames',
					       -command => [
							    \&edit_button_pressed,
							    $self
							   ]);

  $editframes_button->pack(qw/-padx 5 -side left/); 

  my $multiselect_button=
    $fbutton_frame->Checkbutton(-text => 'Multiple select',
				-command => [
					     sub {
					       my ($self)=@_;
					       my $fl=$self->subwidget('framelist')->widget();
					       $mode = $fl->cget('-selectmode');
					       if ($mode eq 'extended') {
						 $fl->configure(-selectmode => 'browse');
					       } else {
						 $fl->configure(-selectmode => 'extended');
					       }
					     },
					     $self
					    ]);

  $multiselect_button->pack(qw/-padx 5 -side left/);

  # List of Frames
  my $lexframelist =  TrEd::ValLex::FrameList->new($data, $field, 
						   $lexframe_frame,
						   $item_style,
						   qw/-height 15 -width 50/,
						   -command => [
								\&item_chosen,
								$self
							       ]);
  $lexframelist->pack(qw/-expand yes -fill both -padx 6 -pady 6/);

  $lexframelist->fetch_data($word) if ($word);

  return $lexframelist->widget(),{
	     callback     => $cb,
	     frame        => $frame,
	     frame_frame  => $lexframe_frame,
	     framelist    => $lexframelist,
#	     framenote    => $lexframenote,
#	     frameproblem => $lexframeproblem,
	    }, {
		items => $item_style,
		editor => $frame_browser_styles,
		editor_wordlist_items => $frame_browser_wordlist_item_style,
		editor_framelist_items => $frame_browser_framelist_item_style,
		frame_editor => $frame_editor_styles
	       };
}


sub style {
  return $_[0]->[4]->{$_[1]};
}

sub framelist_item_changed {
  my ($self,$item)=@_;
}

sub callback {
  my ($self)=@_;
  my $cb=$self->subwidget('callback');
  return unless $cb;
  eval {
    &$cb(@_);
  }
}

sub get_selected_frames {
  my ($self)=@_;
  my @frames;
  my $fl=$self->subwidget('framelist')->widget();
  foreach ($fl->infoSelection()) {
    push @frames,$fl->infoData($_);
  }
  return @frames;
}

sub get_current_frame {
  my ($self,$item)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  $item = $fl->infoAnchor() unless defined($item);
  return undef unless defined($item);
  return $fl->infoData($item);
}

sub item_chosen {
  my ($self,$item)=@_;
  $self->callback($self->get_selected_frames($item));
}

sub choose_button_pressed {
  my ($self)=@_;
  $self->callback($self->get_selected_frames());
}

sub edit_button_pressed {
  my ($self)=@_;
  TrEd::ValLex::Editor::show_dialog($self->widget()->toplevel,
				    $self->data(),
				    $self->field(),
				    1,
				    $self->style('editor'),
				    $self->style('editor_wordlist_items'),
				    $self->style('editor_framelist_items'),
				    $self->style('frame_editor')
				   );
  eval { Tk->break; };
  if ($self->field()) {
    $self->subwidget('framelist')->fetch_data($self->field());
  }
}

1;
