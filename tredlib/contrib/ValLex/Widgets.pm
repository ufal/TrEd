#
# ValLex views baseclass
#

package TrEd::ValLex::Widget;

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
  return $self->frame()->pack(@_);
}

#
# LexFrameList widget
#

package TrEd::ValLex::FrameList;
use base qw(TrEd::ValLex::Widget);

require Tk::HList;
require Tk::ItemStyle;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $w = $top->Scrolled(qw/HList -columns 1
                              -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/
			  );
  $w->configure(@conf) if (@conf);
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  $w->headerCreate(0,-itemtype=>'text', -text=>'Elements');
  print "INC: ",Tk::findINC("ValLex/stop.xpm"),"\n";
  return $w, {
	      obsolete => $w->ItemStyle("imagetext", -foreground => '#707070',
					-background => 'white'),
	      substituted => $w->ItemStyle("imagetext", -foreground => '#707070',
					   -background => 'white'),
	      reviewed => $w->ItemStyle("imagetext", -foreground => 'black',
					-background => '#d0e0f0'),
	      active => $w->ItemStyle("imagetext", -foreground => 'black',
				      -background => 'white'),
	      deleted => $w->ItemStyle("imagetext", -foreground => '#707070',
				       -background => '#e0e0e0')
	     },{
		obsolete => $w->Pixmap(-file => Tk::findINC("ValLex/stop.xpm")),
		substituted => $w->Pixmap(-file => Tk::findINC("ValLex/red.xpm")),
		reviewed => $w->Pixmap(-file => Tk::findINC("ValLex/green.xpm")),
		active => $w->Pixmap(-file => Tk::findINC("ValLex/help.xpm")),
		deleted => $w->Pixmap(-file => Tk::findINC("ValLex/error.xpm"))
	       };
}

sub style {
  return $_[0]->[3]->{$_[1]};
}

sub pixmap {
  return $_[0]->[4]->{$_[1]};
}

sub fetch_data {
  my ($self, $word)=@_;

  my $t=$self->widget();
  my $e;
  my $style;

  $t->delete('all');
  foreach my $entry ($self->data()->getFrameList($word)) {
    next if ($entry->[3] eq 'deleted');
    $e = $t->addchild("",-data => $entry->[0]);
    $t->itemCreate($e, 0,
		   -itemtype=>'imagetext',
		   -image => $self->pixmap($entry->[3]),
		   -text=> $entry->[2]."\n".$entry->[4],
		   -style => $self->style($entry->[3]));
  }


}

#
# LexWordList widget
#

package TrEd::ValLex::WordList;
use base qw(TrEd::ValLex::Widget);

require Tk::HList;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  ## Word List
  my $w = $top->Scrolled(qw/HList -columns 1 -background white
                              -selectmode browse
                              -header 1
                              -relief sunken
                              -scrollbars osoe/);
  $w->configure(@conf) if (@conf);
  $w->BindMouseWheelVert() if $w->can('BindMouseWheelVert');
  return $w;
}

sub fetch_data {
  my ($self)=@_;
  my $t=$self->widget();
  my $e;
  $t->delete('all');
  $t->headerCreate(0,-itemtype=>'text', -text=>'lemma');
  $t->columnWidth(0,'');
  foreach my $entry ($self->data()->getWordList()) {
    $e= $t->addchild("",-data => $entry->[0]);
    $t->itemCreate($e, 0, -itemtype=>'text', -text=> $entry->[2]);
  }
}

#
# LexFrameProblems widget
#

package TrEd::ValLex::FrameProblems;
use base qw(TrEd::ValLex::FramedWidget);
require Tk::HList;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $frame = $top->Frame();
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

  my $frame = $top->Frame();
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

1;
