package TrEd::Query::String;

use strict;
use warnings;

use TrEd::Config qw{$font};
use TrEd::Utils qw{$EMPTY_STR};

use Tk;

use TrEd::Convert qw{encode decode};

require TrEd::Dialog::FocusFix;

# was main::QueryString
sub new_query {
  my ($grp, $title, $label,$default_text, $select, $hist,$before_label,$opts)=@_;
  my $top = (ref($grp) and UNIVERSAL::can($grp,'toplevel')) ? $grp->toplevel : $grp->{top};
  my $newvalue=encode($default_text);
  my $d=$top->DialogBox(-title=> $title,
				 -buttons=> ["OK", "Cancel"]);
  $d->BindEscape();
  $d->BindReturn($d,1);
  $d->bind('<Tab>',[sub { shift->focusNext; }]);
  $d->bind('<Shift-Tab>',[sub { shift->focusPrev; }]);

  main::addBindTags($d,'dialog');
  $opts||={};
  my ($Entry,@Eopts) = @{delete($opts->{-entry}) || [get_entry_type()]};

  my $f = $d;
  if (defined $before_label) {
    my $l= $d->Label(-text=> encode($before_label),
		   -anchor=> 'ne',
		   -justify=> 'left')->pack();
    $f=$d->Frame->pack();
  }
  my $e=$f->$Entry(
		@Eopts,
		-relief=> 'sunken',
		-width=> 70,
		-takefocus=> 1,
		-font=> $font,
		-textvariable=> \$newvalue);
  if ($opts->{-entry_config}) {
    $opts->{-entry_config}->($e);
  }
  if ($e->can('history') and ref($hist)) {
    $e->history($hist);
  }
  $e->selectionRange(qw(0 end)) if ($select);
  my $l= $f->Label(-text=> encode($label),
		    -anchor=> 'e',
		    -justify=> 'right');

  $l->pack(-side=>'left');
  $e->pack(-side=>'right');
  $d->resizable(0,0);
  $d->BindButtons;
  my $result= TrEd::Dialog::FocusFix::show_dialog($d,$e,$top);
  if ($result=~ /OK/) {
    if (ref($hist) and $e->can('historyAdd')) {
      $e->historyAdd($newvalue) if $newvalue ne $EMPTY_STR;
      @$hist = $e->history();
    }
    $d->destroy; undef $d;
    return decode($newvalue);
  } else {
    $d->destroy; undef $d;
    return undef;
  }
}

1;