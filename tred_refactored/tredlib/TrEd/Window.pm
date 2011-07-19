package TrEd::Window;

use Tk;
use TrEd::TreeView;
use Tk::Separator;
use strict;
use Carp;
use vars qw($AUTOLOAD);

use TrEd::Stylesheet;

# options
# Nodes, root, treeView, FSFile, treeNo, currentNode
sub new {
  my $self = shift;
  my $class = ref($self) || $self;
  my $new = { treeView => shift, redrawn => 0, @_ };
  bless $new, $class;
  return $new;
}

# sub AUTOLOAD {
#   my $self=shift;
#   return undef unless ref($self);
#   my $sub = $AUTOLOAD;
#   $sub =~ s/.*:://;
#   if ($sub=~/^(?:treeView|FSFile|treeNo|currentNode)$/) {
#     return $self->{$sub};
#   } else {
#     croak "Undefined method $sub called on class ".ref($self);
#   }
# }

sub treeView { return $_[0]->{treeView} }
sub FSFile { return $_[0]->{FSFile} }
sub treeNo { return $_[0]->{treeNo} }
sub currentNode { return $_[0]->{currentNode} }

sub DESTROY {
  my ($self)=@_;
  undef $self->{treeView};
}

#TODO: addition from Utils/Stylesheet
# was Utils::applyWindowStylesheet
sub apply_stylesheet {
  my ($self,$stylesheet)=@_;
  return unless $self;
  my $s=$self->{framegroup}->{stylesheets}->{$stylesheet};
  if ($stylesheet eq TrEd::Stylesheet::STYLESHEET_FROM_FILE()) {
    $self->{treeView}->set_patterns(undef);
    $self->{treeView}->set_hint(undef);
  } else {
    if ($s) {
      $self->{treeView}->set_patterns($s->{patterns});
      $self->{treeView}->set_hint(\$s->{hint});
    }
  }
  $self->{stylesheet}=$stylesheet;
}

#######################################################################################
# Usage         : set_current_file($win, $fsfile)
# Purpose       : Set tree number, current node and FSFile for Window $win to values 
#                 obtained from $fsfile
# Returns       : Undef/empty list
# Parameters    : TrEd::Window ref $win -- ref to TrEd::Window object which is to be altered
#                 Treex::PML::Document ref $fsfile -- ref to Document which is set as current for the Window
# Throws        : No exception
# Comments      : If $fsfile is not defined, all the beforementioned values are set to undef.
#                 If Windows is focused, session status is updated.
# See Also      : is_focused(), fsfileDisplayingWindows()
# was main::setWindowFile
sub set_current_file {
    my ( $self, $fsfile ) = @_;
    $self->{FSFile} = $fsfile;
    if (defined $fsfile) {
        $self->{treeNo} = $fsfile->currentTreeNo() || 0;
        $self->{currentNode} = $fsfile->currentNode();
    }
    else {
        $self->{treeNo}      = undef;
        $self->{currentNode} = undef;
    }
    if ( $self->is_focused() ) {
        main::update_session_status( $self->{framegroup} );
    }
    return;
}

#######################################################################################
# Usage         : isFocused($win)
# Purpose       : Find out whether $win Window is currently focused
# Returns       : 1 if the Window $win is focused, 0 otherwise
# Parameters    : TrEd::Window ref $win -- ref to TrEd::Window object which is tested for focus
# Throws        : No exception
# Comments      : 
# See Also      : 
sub is_focused {
  my ($self) = @_;
  return $self eq $self->{framegroup}->{focusedWindow} ? 1 : 0;
}

sub toplevel {
  my ($self)=@_;
  return $self->canvas()->toplevel();
}

# for user's comfort
sub canvas {
  my ($self) = @_;
  return if (!ref $self || !ref $self->{treeView} );
  return $self->{treeView}->canvas();
}

sub canvas_frame {
  my ($self,$canvas) = @_;
  $canvas||=$self->canvas();
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

# this can work as a class method as well
sub remove_split {
  my ($self,$canvas)=@_;
  $canvas||=$self->canvas();
  return undef unless $canvas;
  my $frame=$self->canvas_frame($canvas);
  my $brother_canvas;
  my $pframe;
  {
    my %pi=$frame->packInfo();
    $pframe=$pi{-in};
  }
  return unless $pframe;
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
BEGIN{
*remove_canvas = \&remove_split;
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
  my $self = shift;
  $self->splitPack($self->canvas(),@_);
}

sub splitPack {
  my ($self,$c,$newc,$ori,$ratio)=@_;
  my $frame=$self->canvas_frame($c);
  my $top=$c->toplevel;
  my $owd=$frame->width;
  my $oht=$frame->height;
  my ($side,$fill,$wd,$ht);
  $ratio ||= 0.5;
  $ratio = -$ratio if $ori eq 'horiz';
  if ($ori eq 'horiz') {
    $ht=$oht*abs($ratio)-16;
    $oht-=$ht+16;
    $wd=$owd;
    $side='bottom';
    $fill='x';
  } else {
    $wd=$owd*abs($ratio)-16;
    $owd-=$wd+16;
    $ht=$oht;
    $side='left';
    $fill='y';
  }
  my ($cf,$newcf,$sep);

  $c->packForget();
  $c->configure(-width=>$owd, -height=>$oht);
  $newc->configure(-width=>$wd, -height=>$ht);

  $c->GeometryRequest($owd,$oht);
  $cf=$self->frame_widget($c,[],[qw(-side left)]);

  $newc->GeometryRequest($wd,$ht);
  $newcf=$self->frame_widget($newc,[],[qw(-side left)]);
  if ($ratio<0) {
    # SWAPPING the pack order
    my $swap=$cf;
    $cf=$newcf;
    $newcf=$swap;
  }

  $sep=$top->Separator(-widget1=>$cf,
		       -widget2=>$newcf,
		       -orientation=>$ori,
		      );
  $sep->configure(-side =>'bottom');

  $cf->pack(-in => $frame, -side => $side, qw(-expand yes -fill both));
  $sep->pack(-in => $frame, -side => $side,  -fill => $fill, qw(-expand no));
  $newcf->pack(-in => $frame, -side => $side, qw(-expand yes -fill both));
  $frame->idletasks; # pack first
  if ($ori eq 'horiz') {
    $sep->delta_height($ht-$newc->height);
  } else {
    $sep->delta_width($wd-$newc->width);
  }
  $frame->idletasks;
  return $sep;
}

# Return the index of the last file in the current filelist.
# was main::lastFileNo
sub last_file_no {
  my ($self) = @_;
  return $self->{currentFilelist} ? $self->{currentFilelist}->file_count()-1 : -1;
}

# Return the index of the current file in the current filelist.
# was main::currentFileNo
sub current_file_no {
  my ($self)=@_;
  return $self->{currentFileNo};
}



1;

