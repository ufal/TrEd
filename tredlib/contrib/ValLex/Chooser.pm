#
# ValLex Editor widget (the main component)
#

package TrEd::ValLex::Chooser;
use base qw(TrEd::ValLex::FramedWidget);

require Tk::LabFrame;

sub show_dialog {
  my ($title,$top,$data,$word,$select_frame)=@_;

  my $d = $top->DialogBox(-title => $title,
			  -buttons => ['Choose', 'Cancel'],
			  -default_button => 'Choose'
			 );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Escape>'=> [sub { shift; shift->{selected_button}='Cancel'; },$d ]);
  my $chooser =
    TrEd::ValLex::Chooser->new($data, $word, $d, undef, 1);
  $chooser->pack(qw/-expand yes -fill both -side left/);
  $chooser->widget()->focus();
  if ($chooser->widget()->infoExists(0)) {
    $chooser->widget()->anchorSet(0);
  }

  if ($d->Show() eq 'Choose') {
    my $frame=$chooser->get_current_frame();
    $d->destroy();
    return $frame ? $frame->getAttribute('frame_ID') : undef;
  } else {
    $d->destroy();
    return undef;
  }
}

sub create_widget {
  my ($self, $data, $word, $top, $cb, $no_choose_button, @conf) = @_;

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

  # List of Frames
  my $lexframelist =  TrEd::ValLex::FrameList->new($data, $field, $lexframe_frame,
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
	    };
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

sub get_current_frame {
  my ($self,$item)=@_;
  my $fl=$self->subwidget('framelist')->widget();
  $item = $fl->infoAnchor() unless defined($item);
  return undef unless defined($item);
  return $fl->infoData($item);
}

sub item_chosen {
  my ($self,$item)=@_;
  $self->callback($self->get_current_frame($item));
}

sub choose_button_pressed {
  my ($self)=@_;
  $self->callback($self->get_current_frame());
}

sub edit_button_pressed {
  my ($self)=@_;
  TrEd::ValLex::Editor::show_dialog($self->widget()->toplevel,
				    $self->data(), "");
  if ($self->field()) {
    $self->subwidget('framelist')->fetch_data($self->field());
  }
}

1;
