package TrEd::StatusLine;

use strict;
use warnings;

use TrEd::SidePanel;
use TrEd::Config;
use TrEd::Convert qw{encode};
use TrEd::Basics qw{$EMPTY_STR};

# status, UI
sub update_status_info {
  my ($win)=@_;
  update_status_line($win);
  $win->toplevel->afterIdle(sub{
			      TrEd::SidePanel::update_attribute_view($win);
			    });
}

# status line
sub update_status_line {
  my ($win) = @_;
  return if not $win;
  return if not $TrEd::Config::displayStatusLine;
  my $l = main::doEvalHook($win, 'get_status_line_hook');
  set_status_line($win->{framegroup},$l);
}

# status line
sub set_status_line {
  my ($grp,$text)=@_;
  my $sl=$grp->{statusLine};
  return unless $sl;
  $sl->configure(qw(-state normal));
  $sl->delete('0.0','end');
  my @oldtags=$sl->tagNames();
  if (@oldtags) {
    $sl->tagDelete(@oldtags);
  }
  if (defined $grp->{statusLineText} && $grp->{statusLineText} ne $EMPTY_STR) {
  #if ($grp->{statusLineText} ne $EMPTY_STR) {
    $sl->insert('end', TrEd::Convert::encode($grp->{statusLineText}),undef);
    $sl->insert('end'," | ",undef) if ($text);
  }
  if (ref($text)) {
    my ($fields,$styles) = @$text;
    my $i=0;
    my @fields = map { $i=!$i; $i ? TrEd::Convert::encode($_) : $_ } @$fields;
    $sl->insert('end',@fields) if @fields;
    while (@$styles) {
      my $style = shift @$styles;
      my $opts = shift @$styles;
      $sl->tagConfigure($style, @$opts);
    }
  } else {
    $sl->insert('0.0',TrEd::Convert::encode($text));
  }

  $sl->configure(qw(-state disabled));
  return $text;
}


1;