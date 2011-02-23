package Tk::EditableCanvas;
# pajas@ufal.mff.cuni.cz          17 èec 2007
# looks like it's not used anywhere...
 
use 5.008;
use strict; 
use warnings;
use Carp;

use Tk::widgets qw/ Canvas /;
use base qw/ Tk::Derived Tk::Canvas /;

Construct Tk::Widget 'EditableCanvas';

sub Populate {
  my ($self, $args) = @_;
  $self->SUPER::Populate($args);
  $self->InitEditModeBindings;
  $self->ConfigSpecs(
    '-entercommand'    => [ 'CALLBACK', 'entercommand', 'enterCommand',   undef ],
    '-leavecommand'    => [ 'CALLBACK', 'leavecommand', 'leaveCommand',   undef ],
    '-submitcommand'   => [ 'CALLBACK', 'submitcommand', 'submitCommand',   undef ],
   );
}

sub InitEditModeBindings {
  my ($c)=@_;
  $c->bind(qw/editable <Double-ButtonRelease-1>/          => 'ctext_doubleclick');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <1>/		  => 'ctxt_click_to_leave_edit_mode');
#  $c->CanvasBind(qw/CANVAS_EDIT_MODE <KeyPress>/	  => 'NoOp');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <B1-Motion>/	  => 'ctext_move');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-1>/		  => 'ctext_adjust_selection');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-B1-Motion>/	  => 'ctext_move');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <KeyPress>/	  => 'ctext_keypress');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Home>/		  => 'ctext_home');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <End>/		  => 'ctext_end');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-Home>/		  => 'ctext_shift_home');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-End>/		  => 'ctext_shift_end');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Left>/		  => 'ctext_left');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Right>/		  => 'ctext_right');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-Left>/	  => 'ctext_shift_left');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Shift-Right>/	  => 'ctext_shift_right');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Return>/		  => 'ctext_return');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Escape>/		  => 'ctext_escape');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Control-h>/	  => 'ctext_bs');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <BackSpace>/	  => 'ctext_bs');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <Delete>/		  => 'ctext_delete');
  $c->CanvasBind(qw/CANVAS_EDIT_MODE <2>/		  => 'ctext_paste');
}

sub ctext_escape {
  my($w) = @_;
  $w->afterIdle( [\&ctext_leave,$w] );
  Tk->break;
}
sub ctext_paste {
  my($w) = @_;
  $w->insert('edited', 'insert', $w->toplevel->SelectionGet);
  ctext_update_editbg($w);
  Tk->break;
}
sub ctext_delete {
  my($w) = @_;
  eval {local $SIG{__DIE__}; $w->dchars(qw/edited sel.first sel.last/)};
  $w->dchars('edited', 'insert');
  ctext_update_editbg($w);
  Tk->break;
}
sub  ctext_shift_right {
  my($w) = @_;
  $w->selectTo('edited','insert');
  $w->icursor('edited',$w->index('edited','insert')+1);
  Tk->break;
}
sub ctext_shift_left {
  my($w) = @_;
  $w->icursor('edited',$w->index('edited','insert')-1);
  $w->selectTo('edited','insert');
  Tk->break;
}
sub ctext_right {
  my($w) = @_;
  $w->selectFrom('edited','insert');
  $w->selectClear();
  $w->icursor('edited',$w->index('edited','insert')+1);
  Tk->break;
}

sub ctext_left {
  my($w) = @_;
  $w->selectFrom('edited','insert');
  $w->selectClear();
  $w->icursor('edited',$w->index('edited','insert')-1);
  Tk->break;
}
sub ctext_shift_home {
  my($w) = @_;
  $w->icursor('edited',0);
  $w->selectTo('edited','insert');
  Tk->break;
}
sub ctext_shift_end {
  my($w) = @_;
  $w->icursor('edited','end');
  $w->selectTo('edited','insert');
  Tk->break;
}
sub ctext_home {
  my($w) = @_;
  $w->selectFrom('edited','insert');
  $w->selectClear();
  $w->icursor('edited',0);
  Tk->break;
}

sub ctext_end {
  my($w) = @_;
  $w->selectFrom('edited','insert');
  $w->selectClear();
  $w->icursor('edited','end');
  Tk->break;
}

sub ctext_keypress {
  my($w) = @_;
  my $e = $w->XEvent;
  my $A = $e->A;
  return unless length $A;
  eval {local $SIG{__DIE__}; $w->dchars(qw/edited sel.first sel.last/) };
  $w->insert(qw/edited insert/, "$A");
  $w->selectFrom('edited','insert');
  $w->selectClear();
  ctext_update_editbg($w);
  Tk->break;
}
sub ctext_adjust_selection {
  my($w) = @_;
  my $e = $w->XEvent;
  my($x, $y) = ($w->canvasx($e->x), $w->canvasy($e->y));
  $w->icursor('edited',"\@$x,$y");
  $w->select(qw/adjust edited/, "\@$x,$y");
}
sub ctext_bs {
  my($w) = @_;
  eval {local $SIG{__DIE__}; $w->dchars(qw/edited sel.first sel.last/)};
  my $char = $w->index(qw/edited insert/) - 1;
  $w->dchars('edited', $char) if $char >= 0;
  ctext_update_editbg($w);
  Tk->break;
}
sub ctext_click {
  my($w) = @_;
  my $e = $w->XEvent;
  my($x, $y) = ($w->canvasx($e->x), $w->canvasy($e->y));
  my $char = $w->index(edited => [$x,$y]);
  eval { $w->icursor('edited',$char ) };
  $w->selectFrom('edited',$char);
  $w->selectClear();

  Tk->break;
}
sub ctext_move {
  my($w) = @_;
  my $e = $w->XEvent;
  my($x, $y) = ($w->canvasx($e->x), $w->canvasy($e->y));
  eval { $w->icursor('edited', [$x,$y]) };
  eval { $w->selectTo(qw/edited insert/); };
  Tk->break;
}
sub ctext_update_editbg {
  my ($w) = @_;
  unless ($w->find(withtag => 'editbg')) {
    $w->createRectangle(
      0,0,0,0,
      -state => 'hidden',
      -outline => 'white',
      -fill => 'white',
      -tags => ['editbg'],
     );
  }
  if ($w->find(withtag => 'edited')) {
    $w->coords('editbg', $w->bbox('edited'));
    $w->itemconfigure('editbg',-state => 'normal');
    $w->raise('editbg','all');
    $w->raise('edited','all');
  } else {
    $w->itemconfigure('editbg',-state => 'hidden');
  }
}
sub ctext_suppress_tags {
  my ($w,$item) = @_;
  for my $t ($w->find(withtag => $item)) {
    my @tags = $w->gettags($t); # carefully preserving tag order
    $w->dtag($t,$_) for @tags;
    $w->addtag($_, withtag => $t)
      for map { $_ eq 'current' ? $_ : $_.'___suppressed' } @tags;
  }
}
sub ctext_revive_tags {
  my ($w,$item) = @_;
  for my $t ($w->find(withtag => $item)) {
    my @tags = $w->gettags($t); # carefully preserving tag order
    $w->dtag($t,$_) for @tags;
    $w->addtag($_, withtag => $t)
      for map { s/___suppressed$//; $_ } @tags;
  }
}
sub ctext_leave {
  my ($w) = @_;
  my ($t) = $w->find(withtag => 'edited');
  $w->focus('');
  ctext_revive_tags($w,$t);
  $w->dtag($t,'edited');
  $w->itemconfigure('all',-state => 'normal');
  ctext_update_editbg($w);
  $w->Callback('-leavecommand',$w,$t);
  $w->toplevel->Unbusy();
  $w->bindtags([$w, ref($w),$w->toplevel,'all']);
}
sub ctext_return {
  my ($w) = @_;
  my ($t) = $w->find(withtag => 'edited');
  ctext_revive_tags($w,$t);
  if ($w->Callback('-submitcommand',$w,$t)) {
    $w->afterIdle([\&ctext_leave,$w]);
  } else {
    $w->dtag($t,'edited');
    ctext_suppress_tags($w,$t);
    $w->addtag('edited', withtag => $t);
  }
  Tk->break;
}
sub ctxt_click_to_leave_edit_mode {
  my ($w) = @_;
  my $e = $w->XEvent;
  my ($t) = $w->find(withtag => 'edited');
  if ($t) {
    my($x, $y) = ($w->canvasx($e->x), $w->canvasy($e->y));
    my @bbox = $w->bbox($t);
    if ($bbox[0] <= $x and $bbox[1] <= $y and
	  $bbox[2] >= $x and $bbox[3] >= $y) {
      ctext_click($w);
    } else {
      ctext_leave($w);
    }
    Tk->break;
  } else {
    # this should not happen
    warn "Canvas unexpectedly in CANVAS_EDIT_MODE:",join(",",$w->bindtags);
    ctext_leave($w);
  }
}

sub ctext_doubleclick {
  my $w = shift;
  $w->afterIdle([$w,'ctext_enter',@_]); # wait till all button-release events are processed
  # Tk->break; # THIS leaks some objects which causes problems
}

sub ctext_enter {
  my($w,$obj) = @_;
  my $e = $w->XEvent;
  my($x, $y) = ($w->canvasx($e->x), $w->canvasy($e->y));
  my $current = defined($obj) ? $obj : $w->find(withtag=>'current');

  if (defined $current) {
    if ($w->Callback('-entercommand',$w,$current)) {
      ctext_leave($w);
      $w->toplevel->Busy(-recurse => 1, -cursor => 'xterm');
      $w->itemconfigure('all',-state => 'disabled');
      $w->itemconfigure($current,-state => 'normal');
      $w->icursor($current, "\@$x,$y");
      $w->focus($current);
      eval { $w->select(from => $current, "\@$x,$y") };
      ctext_suppress_tags($w,$current);
      $w->addtag('edited', withtag => $current);
      ctext_update_editbg($w);
      $w->Unbusy();
      $w->bindtags(['CANVAS_EDIT_MODE']);
      $w->CanvasFocus;
    }
  }
#  Tk->break;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

EditableCanvas - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Tk::EditableCanvas;
   my $canvas = $mw->EditableCanvas(
    -entercommand => \&on_edit_enter,
    -leavecommand => \&on_edit_leave,
    -submitcommand => \&on_submit
   );

=head1 DESCRIPTION

A canvas widget that supports in-line editing of text items that carry
the tag 'editable'.  Editing is started by double-clicking such an
text item and leaved by pressing either Escape, Return, or clicking
outside the editable item. 
During editing, the canvas only responds to
bindings with the CANVAS_EDIT_MODE binding tag.

=head2 OPTIONS

=over 5

=item -entercommand

A callback invoked when the editing starts. The callback obtains the
canvas object and the item's ID as an argument. If the callback
returns a false value (0 or undef), editing is cancelled.

=item -leavecommand
b
A callback invoked when the editing ends (for any reason
described above). The callback obtains the item's ID as an argument.

=item -submitcommand

A callback invoked when the editing ends because the user pressed
Return. The callback obtains the item's ID as an argument.  If the
callback returns a false value (0 or undef), submitting is cancelled
and the canvas stays in the editing mode.

=back

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

