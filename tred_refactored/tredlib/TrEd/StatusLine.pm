package TrEd::StatusLine;

use strict;
use warnings;

use TrEd::SidePanel;
use TrEd::Config;
use TrEd::Convert qw{encode};
use TrEd::Basics qw{$EMPTY_STR};

use Data::Dumper;

sub new {
    my ($class, $parent, $grp) = @_;
    if (!ref $parent || !ref $grp) {
        croak("Status line constructor needs reference to parent widget and TrEd hash");
    }
    my $status_line = $parent->ROText(qw(-takefocus 0
                                		  -state disabled
                                		  -borderwidth 1
                                		  -height 1
                                		  -width 10
                                		 ),
                            	       -relief => 'sunken',
                            	       -font => $vLineFont);
    
    #TODO: what does this do?                        	       
	main::_deleteMenu($status_line->menu,'File');
    
    $status_line->bind('<1>',
			    [\&TrEd::StatusLine::_click_handle, $grp]
			   );
    $status_line->bind('<Double-1>',
			    [\&TrEd::StatusLine::_doubleclick_handle, $grp]
			   );
    $status_line->pack(qw/-side left -fill x -expand yes/);
    
    my $obj = {
        status_line => $status_line,
        text        => $EMPTY_STR,
    };
    return bless $obj, $class;
}


sub _click_handle {
				my ($w,$grp)=@_;
				my $Ev=$w->XEvent();
				my $win=$grp->{focusedWindow};
				main::doEvalHook($win,"status_line_click_hook",
					   $w->tagNames($w->index($Ev->xy)));
				Tk->break();
}

sub _doubleclick_handle {

				my ($w,$grp)=@_;
				my $Ev=$w->XEvent();
				my $win=$grp->{focusedWindow};
				main::doEvalHook($win,"status_line_doubleclick_hook",
					   $w->tagNames($w->index($Ev->xy)));
				Tk->break();
}

sub configure {
    my ($self, @opts) = @_;
    return $self->{status_line}->configure(@opts);
}

sub set_text {
    my ($self, $new_text) = @_;
    $self->{text} = $new_text;
}

## 
##
##

# sub update_status_info 
sub update_status {
  my ($self, $win)=@_;
  $self->_update_status_line($win);
  $win->toplevel->afterIdle(sub{
			      TrEd::SidePanel::update_attribute_view($win);
			    });
}

# status line
sub _update_status_line {
  my ($self, $win) = @_;
  return if not $win;
  return if not $TrEd::Config::displayStatusLine;
  my $l = main::doEvalHook($win, 'get_status_line_hook');
  $self->_set_status_line($l);
}

# status line
sub _set_status_line {
  my ($self, $text)=@_;
  my $status_line=$self->{status_line}; #$grp->{statusLine};
  return unless $status_line;
  $status_line->configure(qw(-state normal));
  $status_line->delete('0.0','end');
  my @oldtags=$status_line->tagNames();
  if (@oldtags) {
    $status_line->tagDelete(@oldtags);
  }
  if (defined $self->{text} && $self->{text} ne $EMPTY_STR) {
    $status_line->insert('end', TrEd::Convert::encode($self->{text}),undef);
    $status_line->insert('end'," | ",undef) if ($text);
  }
  if (ref($text)) {
    my ($fields,$styles) = @$text;
    my $i=0;
    my @fields = map { $i=!$i; $i ? TrEd::Convert::encode($_) : $_ } @$fields;
    $status_line->insert('end',@fields) if @fields;
    while (@$styles) {
      my $style = shift @$styles;
      my $opts = shift @$styles;
      $status_line->tagConfigure($style, @$opts);
    }
  } else {
    $status_line->insert('0.0',TrEd::Convert::encode($text));
  }

  $status_line->configure(qw(-state disabled));
  return $text;
}


1;