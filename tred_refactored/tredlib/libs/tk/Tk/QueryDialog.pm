package Tk::QueryDialog;
# pajas@ufal.mff.cuni.cz

use Tk::BindMouseWheel;
use Carp;
use Tk::Dialog;
use Tk::DialogBox;
use Tk::DialogReturn;
use Tk::BindButtons;

# this package actually adds methods to Tk::Widget
# options:
# -title
# -selectmode
# -values
# -selected
# 


sub Tk::Widget::ListQuery {
  my ($w,%opts)=@_;
  my $title = delete $opts{-title};
  my $select_mode = delete $opts{-selectmode};
  my $vals = delete $opts{-values};
  my $indexes = delete $opts{-selected_indexes};
  my $selected = delete $opts{-selected};
  my $buttons = delete $opts{-buttons};
  my $top=$w->toplevel;
  my $d=$w->DialogBox(-title	  => $title,
		      -width	  => '8c',
		      -buttons  => ["OK", "Cancel"]);
  $d->BindReturn;
  $d->BindEscape;
  if (ref($opts{Label})) {
    $d->Label(%{$opts{Label}})->pack(qw/-side top/);
  }
  my $height = scalar(@$vals);
  $height = 25 if $height>25;
  my $l=$d->Scrolled(qw/Listbox -relief sunken
                        -takefocus 1
                        -width 0
                        -scrollbars e/,
		     (defined($select_mode) ? (-selectmode => $select_mode) : ()),
		     -height=> $height,
		     %opts
		    )->pack(qw/-expand yes -fill both/);
  $l->insert('end',@$vals);
  if (@$vals>0) {
    $l->activate(0);
  }
  $l->BindMouseWheelVert();
  my $f=$d->Frame()->pack(qw/-fill x/);
  if ($select_mode eq 'multiple') {
    $f->Button(-text => 'All',
	       -underline => 0,
	       -command => [
			    sub{
			      my ($list)=@_;
			      $list->selectionSet(0,'end');
			    },
			    $l
			   ])->pack(-side => 'left');
    $f->Button(-text => 'None',
	       -underline => 0,
	       -command => [
			    sub{
			      my ($list)=@_;
			      $list->selectionClear(0,'end');
			    },
			    $l
			   ])->pack(-side => 'left');
  }
  if (ref($buttons)) {
    foreach my $b (@$buttons) {
      if (ref($b->{-command}) eq 'ARRAY') {
	push @{$b->{-command}}, $l;
      }
      $f->Button(%$b)->pack(-side => 'left');
    }
  }
  $d->BindButtons;
  my $act=0;
  if ($indexes) {
    for my $i (@$selected) {
      $l->selectionSet($i);
      if (not $act) {
	$act=1;
	$l->activate($i);
	$l->see($i);
      }
    }
  } else {
    my %selected = map { $_ => 1 } @$selected;
    for (my $i=0;$i<@$vals;$i++)  {
      if ($selected{$$vals[$i]}) {
	$l->selectionSet($i);
	if (not $act) {
	  $act=1;
	  $l->activate($i);
	  $l->see($i);
	}
      }
    }
  }
  $d->configure(-focus => $l);
  my $result= $d->Show;
  if ($result=~ /OK/) {
    @$selected=();
    if ($indexes) {
      foreach (0 .. $l->size-1) {
	push @$selected, $_ if $l->selectionIncludes($_);
      }
    } else {
      foreach (0 .. $l->size-1) {
	push @$selected, $l->get($_) if $l->selectionIncludes($_);
      }
    }
    $d->destroy;
    return 1;
  }
  $d->destroy;
  return 0;
}

sub Tk::Widget::QuestionQuery {
  my ($w, %opts) = @_;
  my $top = $w->toplevel;
  my $label = delete $opts{-label};
  my $d = $top->Dialog(%opts);
  $d->add('Label', -text => $label, -wraplength => 300)->pack() if defined $label;
  $d->BindReturn;
  if (exists($opts{-buttons}) and 
      grep { $_ eq 'Cancel' } @{$opts{-buttons}}) {
    $d->BindEscape;
  }
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->BindButtons;
  return $d->Show;
}

sub _get_tk_entry_type {
  my $Entry = "Entry";
  my @Eopts;
  eval {
    require Tk::HistEntry;
    $Entry = "SimpleHistEntry";
    @Eopts = qw(-case 0 -match 1);
  };
  undef $@;
  return ($Entry,@Eopts);
}

sub Tk::Widget::StringQuery {
  my ($w, %opts)=@_;
  my $top = $w->toplevel;
  my $entry_type = delete $opts{-entrytype};
  my $title = delete $opts{-title};
  my $label = delete $opts{-label};
  my $default = delete $opts{-default};
  my $select = delete $opts{-select};
  my $history = delete $opts{-history};

  my $newvalue=$default;
  my $d=$top->DialogBox(-title=> $title,
			-buttons=> ["OK", "Cancel"]);
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Shift-Tab>',[sub { shift->focusPrev; }]);
  my $e=$d->add(defined($entry_type) ? ($entry_type) : _get_tk_entry_type(),
		-relief=> 'sunken',
		-width=> 70,
		-takefocus=> 1,
		-textvariable=> \$newvalue,
		%opts,
	       );
  $d->configure(-focus => $e);
  if ($e->can('history') and ref($history)) {
    $e->history($history);
  }
  $e->selectionRange(qw(0 end)) if ($select);
  my $l= $d->Label(-text=> $label,
		   -anchor=> 'e',
		   -justify=> 'right');
  $l->pack(-side=>'left');
  $e->pack(-side=>'right');
  $d->resizable(0,0);
  $d->BindButtons;
  $d->BindReturn;
  $d->BindEscape;

  my $result= $d->Show;
  if ($result=~ /OK/) {
    if (ref($history) and $e->can('historyAdd')) {
      $e->historyAdd($newvalue) if length $newvalue;
      @$history = $e->history();
    }
    $d->destroy; undef $d;
    return $newvalue;
  } else {
    $d->destroy;
    return;
  }
}

sub Tk::Widget::TextQuery {
  ## draws a dialog box with one Text widget and Ok/Cancel buttons
  ## expects dialog title and default text
  ## returns text of the Text widget
  my ($w, %opts)=@_;
  my $top = $w->toplevel;
  my $title = delete $opts{-title};
  my $var = delete $opts{-content};
  my $message = delete $opts{-message};
  my $buttons = delete $opts{-buttons} || ["OK","Cancel"];
  my $init_callback = delete $opts{-init};
  my $tw = delete $opts{-text_widget};

  my $d=$top->DialogBox(-title => $title,
			-buttons => $buttons);
  $d->BindButtons;
  $d->BindReturn;
  $d->BindEscape;

  $d->bind('all','<Tab>',sub { shift->focusNext; });
  $d->bind('all','<Shift-Tab>',sub { shift->focusPrev; });
  if ($message) {
    my $t=$d->add(qw/Label -wraplength 6i -justify left -text/,$message);
    $t->pack(qw/-padx 0 -pady 0 -expand 0 -fill x/);
  }
  my @opts = qw/-height 8 -relief sunken -scrollbars sw -borderwidth 2/;

  if (!$tw or !eval { $ed=$d->Scrolled($tw,@opts,%opts); }) {
    $ed=$d->Scrolled('Text',@opts,%opts);
  }
  $ed->insert('0.0',UNIVERSAL::isa($var,'ARRAY') ? @$var : $var) if defined $var;
  if (defined $init_callback) {
    my ($cb, @args);
    if (UNIVERSAL::isa($init_callback,'CODE') or !ref($init_callback)) {
      $cb=$init_callback;
    } elsif (UNIVERSAL::isa($init_callback,'ARRAY')) {
      ($cb,@args)=@$init_callback;
    } else {
      croak("-init must be a CODE or ARRAY ref");
    }
    $cb->($d,$ed,@args);
  }
  $ed->update;
  eval { $ed->highlight('0.0','end') if $opts{-highlight} };
  $ed->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);
  $d->bind(ref($ed->Subwidget('scrolled')),'<Control-Return>' => sub {1;});
  $d->bind('<Return>' => sub {Tk->break;});
  $d->bind('<Control-Return>' => sub { shift->toplevel->{default_button}->Invoke; Tk->break;});
#   $d->bind($d,'<Escape>', [sub { shift; shift->{selected_button}= 'Cancel'; },$d] );
#   for my $w ($ed->Subwidget('scrolled')) {
#       $w->bindtags([$w, ref($w),$w->toplevel,'all']);
#   }
#   $d->bind($ed->Subwidget('scrolled'),'<Escape>', [sub { shift; my $w=shift; $w->{selected_button}= 'Cancel'; },$d] );
  $ed->focus;
  if ($d->Show =~ /OK/) {
    $var=$ed->get('0.0','end');
    chomp($var);
    $d->destroy();
    return "$var";
  } else {
    $d->destroy();
    return;
  }
}


1;
__END__

