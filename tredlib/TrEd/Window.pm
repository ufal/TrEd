package TrEd::Window;

use Tk;
use TrEd::TreeView;
use Tk::Separator;
use strict;
use vars qw($AUTOLOAD);

# options
# Nodes, root, treeView, FSFile, treeNo, currentNode
sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { treeView => shift, @_ };
  bless $new, $class;
  return $new;
}

sub AUTOLOAD {
  my $self=shift;
  return undef unless ref($self);
  my $sub = $AUTOLOAD;
  $sub =~ s/.*:://;
  if ($sub=~/^(?:treeView|FSFile|treeNo|currentNode)$/) {
    return $self->{$sub};
  }
}

sub toplevel {
  my ($self)=@_;
  return $self->canvas()->toplevel();
}

# for user's comfort
sub canvas {
  my ($self) = @_;
  return undef unless (ref($self) and ref($self->{treeView}));
  return $self->{treeView}->canvas();
}

sub canvas_frame {
  my ($self) = @_;
  my $canvas=$self->canvas();
  my $frame=undef;
  if (ref($canvas)) {
    my %pi=$canvas->packInfo();
    $frame=$pi{-in};
  }
  return $frame;
}

sub contains {
  my ($self,$w)=@_;
  return $w eq $self->treeView
    || $w eq $self->canvas()
    || $w eq $self->canvas()->Subwidget('scrolled')
    ||  $w eq $self->canvas_frame();
}

sub remove_canvas {
  my ($self)=@_;
  my $canvas=$self->canvas();
  my $brother_canvas;
  return undef unless $canvas;
  my $frame=$self->canvas_frame();
  my $pframe;
  {
    my %pi=$frame->packInfo();
    $pframe=$pi{-in};
  }
  my $wd=$pframe->width;
  my $ht=$pframe->height;
  my $separator=(grep {ref($_) eq 'Tk::Separator'} $pframe->packSlaves())[0];
  if ($separator) {
    $pframe->GeometryRequest($wd,$ht);
    $pframe->configure(-width=>$wd, -height=>$ht);
    $frame->packForget();
    $canvas->packForget();
    $separator->packForget();
    $separator->destroy();
    undef $separator;
    $frame->destroy();
    undef $frame;
    my $brother=($pframe->packSlaves())[0];
    if ($brother) {
      # repack all widgets from $brother to pframe
      $brother->packForget();
      my %pi;
      foreach my $bc ($brother->packSlaves()) {
	%pi=$bc->packInfo();
	$pi{-in}=$pframe;
	$bc->packForget();
	$bc->pack(%pi);
      }
      $brother->destroy();
      undef $brother;
      my @pc=$pframe->packSlaves();
      my $f;
      while ($_=shift @pc) {
	next if ($_->isa('Tk::Separator'));
	if ($_->isa('Tk::Canvas')) {
	  $brother_canvas=$_;
	  last;
	} else {
	  unshift @pc,$_->packSlaves();
	}
      }
      unless ($brother_canvas) {
	warn "No canvas found in the other frame!!\n"; 
      }
    } else { warn "No other canvas found in the frame!!\n"; }
  }
  return ($canvas,$brother_canvas);
}

sub canvas_destroy {
  my ($self)=@_;
  my ($canvas,$brother_canvas)=$self->remove_canvas();
  $canvas->destroy() if ($canvas);
  return $brother_canvas;
}

sub frame_widget {
  my ($self,$w,$frame_options,$pack_options) = @_;

  return undef unless ref($w);
  my @fo=@$frame_options if ref($frame_options);
  my @po=@$pack_options if ref($pack_options);
  my $top=$w->toplevel;
  my $frame=$top->Frame(@fo);
  $w->pack(-in => $frame,
	   -expand => 'yes',
	   -fill => 'both',
	   @po);
  $w->Tk::Widget::raise();
  return $frame;
}

sub split_frame {
  my ($self,$newc,$ori)=@_;
				# like hsplit_framed but work vertically
  my $c=$self->canvas();
  my $top=$c->toplevel;
  my $frame=$self->canvas_frame();
  my $wd=$frame->width;
  my $ht=$frame->height;
  my ($side,$fill);
  if ($ori eq 'horiz') {
    $ht=($ht-32)/2;
    $side='bottom';
    $fill='x';
  } else {
    $wd=($wd-32)/2;
    $side='left';
    $fill='y';
  }
  my ($cf,$newcf,$sep);

  $c->packForget();
  $c->configure(-width=>$wd, -height=>$ht);
  $newc->configure(-width=>$wd, -height=>$ht);

  $c->GeometryRequest($wd,$ht);
  $cf=$self->frame_widget($c,[],[qw(-side left)]);

  $newc->GeometryRequest($wd,$ht);
  $newcf=$self->frame_widget($newc,[],[qw(-side left)]);

  if ($ori eq 'horiz') {
    # SWAPPING the pack order
    my $swap=$cf;
    $cf=$newcf;
    $newcf=$swap;
  }
  $sep=$top->Separator(-widget1=>$cf,
		       -widget2=>$newcf,
		       -orientation=>$ori);
  $cf->pack(-in => $frame, -side => $side, qw(-expand yes -fill both));
  $sep->pack(-in => $frame, -side => $side,  -fill => $fill, qw(-expand no));
  $newcf->pack(-in => $frame, -side => $side, qw(-expand yes -fill both));
}



1;
