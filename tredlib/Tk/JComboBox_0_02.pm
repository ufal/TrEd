package Tk::JComboBox_0_02;

## Quick Acknowledgement: This code started out as Graham Barr's
## MenuEntry. I liked MenuEntry and thought it had lots of 
## promise. So I decided to add to it. The more I added (and
## subtracted), the less it looked like like MenuEntry until it
## got to the point where calling it MenuEntry no longer made
## sense. Thank you Graham for provided the fertile soil from
## which JComboBox grew. - RCS

## By the way, this version of JComboBox.pm is Copyright (c) 
## 2001 Rob Seegel <RobSeegel@aol.com>. All rights reserved. 
## This program is free software; you can redistribute
## it and/or modify it under the same terms as Perl itself. 

## Perl 5.005 requires quotes of some kind around the
## _JCBListItem, otherwise it will generate an error so they
## are there for backwards compatibility

## This struct below meant to represent the contents displayed 
## in the pulldown list. Name is the text which is displayed, 
## value is for text which could be offered as an alternative 
## to the displayed text. It is bit of overkill having a 
## structure for these two values, however, I look at as an 
## open-ended solution which could be easily extended if each 
## list element gained other properties (separate images, 
## bitmaps, and formatting - future enhancements.) - RCS 

use Class::Struct;
struct '_JCBListItem' => [
  name => '$',
  value => '$',
];

use Tk qw(Ev);
use Carp;
use vars qw($VERSION);
$VERSION = "0.02";

use base qw(Tk::Frame);
Tk::Widget->Construct('JComboBox_0_02');

my $BITMAP;

sub ClassInit { # print STDERR "SUB: ClassInit\n";
  my($class,$mw) = @_;

  unless(defined($BITMAP)) {
    $BITMAP = __PACKAGE__ . "::downarrow";

    ## A smaller bitmap suits Win32 better I think
    if ($Tk::platform =~ /Win32/) {
      my $bits = pack("b10"x4,
        ".11111111.",
	"..111111..",
        "...1111...",
        "....11...."
      );
      $mw->DefineBitmap($BITMAP => 10,4, $bits);

    ## Just as this size looks better on Unix platforms
    } else {
      my $bits = pack("b12"x5,
        ".1111111111.",
	"..11111111..",
	"...111111...",
	"....1111....",
	".....11....."
      );
      $mw->DefineBitmap($BITMAP => 12,5, $bits);
    }
    $mw->bind($class, '<FocusIn>', 'SetFocus');
  }
}

sub Populate { # print STDERR "SUB: Populate\n";
  my ($cw ,$args) = @_;

  $cw->SUPER::Populate($args);

  my $gap = $args->{-gap};
  $gap = 2 if (!defined($gap));
  $cw->{_gap} = $gap;

  $cw->{_list} = [];
  $cw->{_selIndex} = undef;
  $cw->{_entryWidth} = 0;

  my $sf = $cw->Component( 
    Frame => 'Frame',
    -bd => 0,
    -highlightthickness => 0
  )->pack( -side => 'right', -fill => 'both', -expand => 1);

  my %stdCompOpt = (
    -highlightthickness => 0,
    -takefocus => 0,
    -borderwidth => 0
  );


  ## 'Button' for editable entry
  my $eb = $sf->Label( %stdCompOpt,
    -bitmap => $BITMAP,
    -anchor => 'center',
    -pady => 0,
  );
  $cw->Advertise(ED_Button => $eb);
  $eb->bind('<ButtonPress-1>',    [$cw => 'ButtonDown']);
  $eb->bind('<ButtonRelease-1>',  [$cw => 'ButtonUp']);
  $eb->bind('<Leave>',            [$cw => 'ButtonUp']);

  ## 'Button' for read only entry
  my $rob = $sf->Label(%stdCompOpt,
    -bitmap => $BITMAP,
    -padx => 4,
    -anchor => 'center'
  );
  $cw->Advertise(RO_Button => $rob);
  $rob->bind('<ButtonPress-1>',   [$cw => 'ButtonDown']);
  $rob->bind('<ButtonRelease-1>', [$cw => 'ButtonUp']);
  $rob->bind('<Leave>',           [$cw => 'ButtonUp']);

  ## Editable Entry
  my $e = $sf->Entry(%stdCompOpt,
    -relief => 'flat',
    -insertwidth =>1,
    -validatecommand => [$cw => 'ValidateCmd']
  );
  $cw->Advertise(ED_Entry => $e);
  $e->bind('<Return>',        [$cw => 'EntryEnter']);
  $e->bind('<Up>',            [$cw => 'EntryUpDown', '-1']);
  $e->bind('<Down>',          [$cw => 'EntryUpDown', '1']);
  $e->bind('<ButtonPress-1>', [$cw => 'NonSelect']);
  
  ## ReadOnly Entry
  my $roe = $sf->Label(
    -anchor => 'w',
    -padx => 4,
    -borderwidth => 0,
    -highlightthickness => 0
  );
  $cw->Advertise(RO_Entry => $roe);   
  $roe->bind('<ButtonPress-1>',   [$cw => 'ButtonDown']);
  $roe->bind('<ButtonRelease-1>', [$cw => 'ButtonUp']);
  $roe->bind('<Leave>',           [$cw => 'ButtonUp']);

    # popup shell for listbox with values.
    my $c = $cw->Component(
      Toplevel => 'Popup',
      -bd => 2,
      -relief => 'groove'
    );
    $c->overrideredirect(1);
    $c->withdraw;

 
   my $sl = $c->ScrlListbox(
      -scrollbars => 'oe',
      -selectmode => "browse",
      -exportselection => 0,
      -bd => 0,
      -height => 4,
      -width => 0,
      -highlightthickness => 0,
      -relief => "raised"
    )->pack( -expand => 1, -fill => "both");
    $cw->Advertise(Listbox => $sl);


    $sl = $sl->Subwidget('scrolled');
    $sl->bind('<ButtonRelease-1>', [$cw => 'SelectEntry', Ev('index',Ev('@'))]);
    $cw->bind('<ButtonRelease-1>', [$cw => 'NonSelect']);

    my @buttons = ($eb, $rob);
    $cw->ConfigSpecs(
      -background       => [qw/SELF background  Background/, Tk::NORMAL_BG],
      -buttonbg         => [{-bg => [@buttons, $roe]}],
      -buttonbitmap     => [{-bitmap => [@buttons]}, undef, undef, $BITMAP],
      -buttonborderwidth     
                        => [{-borderwidth => $eb}, undef, undef, 2],
      -buttonimage      => [{-image =>  [@buttons]}],
      -buttonrelief     => [{-relief => $eb}, undef, undef, 'raised'], 
      -borderwidth      => [qw/SELF borderWidth BorderWidth 2/],
      -choices          => [qw/METHOD/],
      -font             => [[$e, $roe, $sl], qw/font Font/, undef],
      -gap              => [qw/PASSIVE/, undef, undef, $gap],
      -highlightthickness => 
        [qw/SELF highlightThickness HighlightThickness 2/],
      -listbackground   => [{-bg => [$e, $sl, $cw, $sf, 'SELF']}, 
                        qw/listBackground ListBackground/, undef],
      -listhighlight    => [qw/METHOD/, undef, undef, 1],
      -maxrows          => [qw/PASSIVE    maxRows MaxRows/, 10],
      -menucreate       => [qw/CALLBACK/, undef, undef, undef],
      -mode             => [qw/METHOD/, undef, undef, 'readonly'],
      -popupbackground  => [{-bg => $c}],
      -popupborderwidth => [{-bd => $c}],
      -popuprelief      => [{-relief => $c}, undef, undef, 'flat'],
      -relief	        => [qw/ SELF relief Relief flat/],
      -selectbackground => [[$e, $sl], undef, undef, Tk::SELECT_BG],
      -selectcommand    => [qw/CALLBACK/],
      -selectforeground => [[$e, $sl], undef, undef, Tk::SELECT_FG],
      -state            => [$e, qw/state State normal/],
      -takefocus        => [qw/SELF takeFocus Focus 1/],
      -textvariable     => [$e],
      -validate         => [qw/METHOD/, undef, undef, undef],
      -validatecommand  => [qw/CALLBACK/],
    );
    $cw->ConfigAlias(
      -bbmp        => '-buttonbitmap',
      -bimg        => '-buttonimage',
      -bbd         => '-buttonborderwidth',
      -brelief     => '-buttonrelief',
      -choices     => '-options',
      -visiblerows => '-maxrows',
      -pbg         => '-popupbackground',
      -pbd         => '-popupborderwidth',
      -prelief     => '-popuprelief',
      -selectbg    => '-selectbackground',
      -scmd        => '-selectcommand',
      -selectfg    => '-selectforeground'
    );
    return $cw;
}

############################################################
## MenuEntry - Configuration Methods
############################################################



sub choices { # print STDERR "SUB: choices\n";
  my ($cw, $listAR) = @_;
 
  return if (!$listAR || ref($listAR) ne "ARRAY");

  if ($cw->getItemCount > 0) {
    $cw->removeAllItems;
  }
  foreach my $el (@{$listAR}) {
    if (ref($el) eq 'HASH') {
      my $name = delete $el->{-name} ||
	croak "Invalid Menu Item. -name must be given when using a Hash reference";
      my $index = $cw->addItem($name, %$el);

    } else {
      $cw->addItem($el);
    }
  }
}

sub gap { # print STDERR "SUB: gap\n";
  my ($cw, $gap) = @_;
  return $cw->{Configure}{-gap} unless defined($gap);
  $cw->{_gap} = $gap;
  if ($cw->getItemCount > 0) {
    $cw->_updateWidth('delete');
  }
}

sub listhighlight { # print STDERR "SUB: listhighlight\n";
  my ($cw, $val) = @_;

  if (!defined($val)) { return $cw->{Configure}{-listhighlighting} }
  my $lb = $cw->Subwidget('Listbox');

  ## True: Bind mouseover style event handlers for highlighting
  ## list elements. This is a typical Win32 behavior for ComboBox
  ## style widgets
  if ($val =~ /^(true|yes|1)$/i) {
    $lb->bind('<Motion>',          [\&Motion, $sl]);
    $lb->bind('<Leave>',           [\&AutoScan, $sl]);
    $lb->bind('<Enter>',           [\&CancelAutoScan, $sl]);

  ## False: 'Unbind' the mouseover type event handlers
  } elsif ($val =~ /^(false|no|0)$/i) {
    $lb->bind('<Motion>',          sub {});
    $lb->bind('<Leave>',           sub {});
    $lb->bind('<Enter>',           sub {});      
  } else {
    croak "Invalid value $val submitted for -listhighlighting." .
          "Only Boolean values are allowed";
  }
}



sub mode { # print STDERR "SUB: mode\n";
  my ($cw, $mode) = @_;

  return ($cw->{Configure}->{-mode}) unless $mode;
 
  ## Remove Current Entry and Button
  my $sf = $cw->Subwidget('Frame');
  foreach ($sf->gridSlaves) {
    $_->gridForget;
  }

  my ($b, $e);
  if ($mode =~ /^readonly/i) {
    $b = $cw->Subwidget('RO_Button');
    $e = $cw->Subwidget('RO_Entry');

  } elsif ($mode =~ /^editable/i) {
    $b = $cw->Subwidget('ED_Button');
    $e = $cw->Subwidget('ED_Entry');
  }


  ## Place the widgets in the grid
  $sf->GeometryRequest($b->ReqWidth + 2,0);

  $e->grid(-row => 0, -column => 0, -sticky => 'nsew');
  if ($mode =~ /readonly/) {
    $b->grid(-row => 0, -column => 1, -sticky => 'nsew', -ipadx => 2);
  } else {
    $b->grid(-row => 0, -column => 1, -sticky => 'nsew', -ipadx => 2, -pady => 0);
  }

  $sf->gridPropagate(1);
  $sf->gridRowconfigure(0, -weight => 1);  
  $sf->gridColumnconfigure(0, -weight => 1); 
#  $sf->gridColumnconfigure(1, -weight => 1); 
}

sub validate { # print STDERR "SUB: validate\n";
  my ($cw, $mode) = @_;

  return $cw->{Configure}{-validate} unless $mode;
  $mode = lc($mode);
  croak "Invalid validate value: $mode" 
    if ($mode !~ /^(none|focus|focusin|focusout|key|match|cs-match)$/);

  my $e = $cw->Subwidget('ED_Entry');
  if ($mode eq 'match')  {  
    $e->configure(-validate => 'key');
  } elsif ($mode eq 'cs-match') {
    $e->configure(-validate => 'key');
  } else {
    $e->configure(-validate => $mode);
  }
}  
 
#######################################################
## JComboBox - Public methods   
#######################################################

sub addItem { # print STDERR "SUB: addItem\n";
  shift->insertItemAt('end', @_) 
};

sub clearSelection { # print STDERR "SUB: clearSelection\n";
  my $cw = shift;
  $cw->Subwidget('Listbox')->selectionClear(0, 'end');
  $cw->{_selIndex} = undef;
 
  my $e = $cw->Subwidget('ED_Entry');
  my $state = $cw->cget('-state');
  if ($state  eq  'disabled') {
    $e->configure(-state => 'normal');
  }    
  $cw->Subwidget('RO_Entry')->configure(-text => "");
  $cw->Subwidget('ED_Entry')->delete(0, 'end');
  $e->configure(-state => $state);  
}

sub getItemIndex { # print STDERR "SUB: getItemIndex\n"; 
  my ($cw, $item, %args) = @_;

  my $mode = lc($args{-mode}) || "exact";
  croak "Invalid value for -mode in getItemIndex (valid: usecase, ignorecase, exact)"
    if ($mode !~ /^((use|ignore)case|exact)$/);

  $item = "\Q" . $item . "\E"
    if ($mode =~ /^((use|ignore)case)$/);

  my $type = lc($args{-type}) || "name";
  croak "Invalid value for -type in getItemIndex (valid: name|value)"
    if ($type !~ /^(name|value)$/);
   
  foreach my $i (0 .. ($cw->getItemCount - 1)) {
    my $field;
    if    ($type eq 'value') { $field = $cw->getItemValueAt($i) }
    elsif ($type eq 'name')  { $field = $cw->{_list}->[$i]->name }
 
    if    ($mode eq 'usecase')    { return $i if ($field =~ /^\Q$item\E/)  }
    elsif ($mode eq 'ignorecase') { return $i if ($field =~ /^\Q$item\E/i) }
    elsif ($mode eq 'exact')      { return $i if ($field eq $item)     }
  }
  return undef;
}

sub getItemCount { # print STDERR "SUB: getItemCount\n"; 
  return scalar(@{$_[0]->{_list}}) 
}

sub getSelectedIndex { # print STDERR "SUB: getSelectedIndex\n"; 
   my $cw = shift;
   my $index = $cw->{_selIndex};
   if (!defined($index) || $cw->cget('-mode') ne 'editable') {
     return $index;
   }
   my $item = $cw->{_list}->[$index];
   my $val = $cw->Subwidget('ED_Entry')->get;
   return $index 
     if $item->name eq $val;
   return undef;
}

sub getSelectedValue { # print STDERR "SUB: getSelectedValue\n"; 
  my $cw = shift;
  my $index = $cw->getSelectedIndex;
  if (!defined($index)) {
    return $cw->Subwidget('ED_Entry')->get;
  } 
  return $cw->getItemValueAt($index);
}

sub getItemNameAt { # print STDERR "SUB: getItemNameAt\n";
  my ($cw, $index) = @_;
  return undef if (!defined($index));
  $index = $cw->index($index);
  return $cw->{_list}->[$index]->name;
}

sub getItemValueAt { # print STDERR "SUB: getItemValueAt\n"; 
  my ($cw, $index) = @_;
  return undef if (!defined($index));

  $index = $cw->index($index);
  my $item = $cw->{_list}->[$index];
  if (defined($item->value)) {
    return $item->value;
  }
  return $item->name;
}

sub hidePopup { # print STDERR "SUB: hidePopup\n"; 
    my ($cw) = @_;
    my $tl = $cw->Subwidget('Popup');

    if ($tl->ismapped) {
	$tl->withdraw;
	$cw->grabRelease;
    }
}

sub index { # print STDERR "SUB: index\n"; 
  my ($cw, $index) = @_;
  my $lb = $cw->Subwidget('Listbox');

  if ($index eq 'selected') { 
    $index = $cw->getSelectedIndex;

  } elsif ($index =~ /\D/)  {
    $index = $lb->index($index);

  } else {
    my $count = $cw->getItemCount;
   
    if ($index < 0 || $index >= $count) {
      carp "Index: $index is out of array bounds";
      return undef;
    }
  }
  return $index;
}
   
sub insertItemAt { # print STDERR "SUB: insertItemAt\n"; 
  my ($cw, $i, $name, %args) = @_;

  if (!defined($name)) {
    carp "Insert failed: undefined element";
    return;
  }
  my $index = $cw->index($i);
  my $lb = $cw->Subwidget('Listbox');

  ## Create new ListItem and set name
  my $item = new _JCBListItem;
  $item->name($name);

  ## Set the value if it's given
  my $value = $args{-value};
  if (defined($value)) {
    $item->value($value);
  }

  ## Add Name to Listbox
  $lb->insert($index, $name);

  ## Add ListItem to Internal Array (append or splice)
  if ($lb->index('end') == $index) {
    push @{$cw->{_list}}, $item;
  } else {
    my $listAR = $cw->{_list};
    splice(@$listAR, $index, 0, ($item, splice(@$listAR, $index)));
    $cw->{_list} = $listAR;
  }
 
  ## Set Entry as selected if option is set
  my $sel = $args{-selected};
  if ($sel && $sel =~ /yes|true|1/i) {
    $cw->setSelectedIndex($index);
  }

  $cw->_updateWidth('add', $name);
}    

sub removeAllItems { # print STDERR "SUB: removeAllItems\n"; 
  my $cw = shift;
  $cw->{_selIndex} = undef;
  $cw->{_entryWidth} = 0;
  $cw->Subwidget('RO_Entry')->configure(-text => "");
  $cw->Subwidget('ED_Entry')->delete(0, 'end');
  $cw->Subwidget('Listbox')->delete(0, 'end');
  $cw->{_list} = [];
}


sub removeItemAt { # print STDERR "SUB: removeItemAt\n"; 
  my ($cw, $index) = @_;
  $index = $cw->index($index);
  if ($index == $cw->getSelectedIndex) {
    $cw->Subwidget('RO_Entry')->configure(-text => "");
    $cw->Subwidget('ED_Entry')->delete(0, 'end');
    $cw->Subwidget('Listbox')->selectionClear(0, 'end');
  }
  my $listAR = $cw->{_list};
  splice(@$listAR, $index, 1);  
    
  $cw->{_list} = $listAR;
  $cw->Subwidget('Listbox')->delete($index); 
  $cw->_updateWidth('delete');

}

sub setSelected { # print STDERR "SUB: setSelected\n";
  my ($cw, $str, %args) = @_; 
  my $index = $cw->getItemIndex($str, %args);
  $cw->setSelectedIndex($index) if defined($index);
  return 1 if defined($index);
  return 0;
}

sub setSelectedIndex { # print STDERR "SUB: setSelectedIndex\n"; 
  my ($cw, $index) = @_;

  return if ($cw->cget('-state') =~ /disabled/);
  my $lb = $cw->Subwidget('Listbox');
  $index = $cw->index($index);
  return if (!defined($index));  

  $cw->{_selIndex} = $index;

  if (defined($lb->curselection)) {
    if ($lb->curselection != $index) {
      $lb->selectionClear(0, 'end');
      $lb->selectionSet($index);
    }
  } else {
    $lb->selectionSet($index);
  }
 
  my $sel = $lb->get($index);
  my $e = $cw->Subwidget('ED_Entry');
  my $state = $cw->cget('-state');
  if ($state  eq  'disabled') {
    $e->configure(-state => 'normal');
  }    
  my $mode = $cw->cget('-validate');
  if ($mode =~ /match/) {
    $cw->configure(-validate => 'none');
  }
  $cw->Subwidget('RO_Entry')->configure(-text => $sel);
  $e->delete(0, 'end');
  $e->insert(0, $sel);
  $e->configure(-state => $state);
  $cw->configure(-validate => $mode);

  if (ref($cw->cget('-selectcommand')) eq 'Tk::Callback') {
    $cw->Callback(-selectcommand => $cw, $index);
  }
}

sub popupIsVisible { # print STDERR "SUB: popupIsVisible\n";
  my $cw = shift;
  if ($cw->Subwidget('Popup')->ismapped) {
    return 1;
  }
  return 0;
}

sub see { # print STDERR "SUB: see\n";
  my ($cw, $index) = @_;
  $index = $cw->index($index);
  my $lb = $cw->Subwidget('Listbox');
  $cw->showPopup 
    if (!$cw->popupIsVisible);
  $lb->see($index);
}

sub showPopup { # print STDERR "SUB: showPopup\n"; 
  my $cw = shift;
  my $tl = $cw->Subwidget('Popup');

  return if ($tl->ismapped);

  my $mc = $cw->{Configure}{-menucreate};
  $mc->Call($cw)
    if defined $mc;

  my $lb = $cw->Subwidget("Listbox");
  my $x = $cw->rootx;
  my $y = $cw->rooty + $cw->height;
  my $size = $lb->size;
  my $msize = $cw->{Configure}{-maxrows};

  $size = $msize
    if $size > $msize;
  $size = 1
    if(($size = int($size)) < 1);

  $lb->configure(-height => $size);
  # Scrolled turns propagate off, but I need it on
  $lb->Tk::pack('propagate',1);
  $lb->update;

  $x = 0
    if $x < 0;
  $y = 0
    if $y < 0;

  my $vw = $cw->vrootwidth;
  my $rw = $tl->ReqWidth;
  my $w = $cw->rootx + $cw->width - $x;

  $w = $rw
    if $rw > $w;
  $x =  $vw - $w
    if(($x + $w) > $vw);

  my $vh = $cw->vrootheight;
  my $h = $tl->ReqHeight;

  $y = $vh - $h
    if(($y + $h) > $vh);

  $tl->geometry(sprintf("%dx%d+%d+%d",$w, $h, $x, $y));

  $tl->deiconify;
  $tl->raise;

  my $entry;
  if ($cw->cget('-mode') =~ /readonly/i) {
    $entry = $cw->Subwidget('RO_Entry');
  } elsif ($cw->cget('-mode') =~ /editable/i) {
    $entry = $cw->Subwidget('ED_Entry');
  }
  $entry->focus;

  $tl->configure(-cursor => "arrow");
  $cw->grabGlobal;
}


#######################################################
## JComboBox - Private methods and Event Handlers 
#######################################################

sub _updateWidth { # print STDERR "SUB: _updateWidth\n"; 
  my ($cw, $action, $name) = @_;

  my $edEntry = $cw->Subwidget('ED_Entry');
  my $roEntry = $cw->Subwidget('RO_Entry');

  if ($action eq "add") {
    my $len = length($name);
    return if ($len <= $cw->{_entryWidth});
    $cw->{_entryWidth} = $len;

  } elsif ($action eq "delete") {
    my $currLen = 0;
    foreach my $item (@{$cw->{_list}}) {
      if ($currLen < length($item->name)) {
	$currLen = length($item->name);
      }
    }
    if ($cw->{_entryWidth} > $currLen) {
      $cw->{_entryWidth} = $currLen;
    }
  }
  $width = $cw->{_entryWidth} + $cw->{_gap};
  $roEntry->configure(-width => $width);
  $edEntry->configure(-width => $width);
}


#############################################################
## JComboBox Event Handler Routines
#############################################################

sub AutoScan { # print STDERR "SUB: AutoScan\n";
  my $lb = shift;
  my $Ev = $lb->XEvent;
  $lb->AutoScan($Ev->x, $Ev->y);
}
  
sub ButtonDown { # print STDERR "SUB: ButtonDown\n";
  my ($cw) = shift;

#  return if ($cw->cget('-state') =~ /disabled/);

  my $button;
  my $mode = $cw->cget('-mode');
  if ($mode =~ /^readonly/i) {
    $button = $cw;
  } elsif ($mode =~ /^editable/i) {
    $button = $cw->Subwidget('ED_Button');
  }

  $cw->{_tmpRelief} = $button->cget('-relief');
  $button->configure(-relief => 'sunken');
#  $cw->{_buttonPressed} = 1;

  my $tl = $cw->Subwidget('Popup');
  if ($tl->ismapped) {
    $cw->hidePopup;
    $index = $cw->getSelectedIndex;
    if (defined($index)) {
      $cw->setSelectedIndex($index);
    }
  } else {
    $cw->showPopup;
  }
}

sub ButtonUp { # print STDERR "SUB: ButtonUp\n";
  my $cw = shift;

#  return unless $cw->{_buttonPressed};

  ## Take care of returning the button relief
  my $button;
  my $mode = $cw->cget('-mode');
  if ($mode =~ /^readonly/i) {
    $button = $cw;
  } elsif ($mode =~ /^editable/i) {
    $button = $cw->Subwidget('ED_Button');
  }
  if ($cw->{_tmpRelief}) { 
    $button->configure(-relief => $cw->{_tmpRelief});
    $cw->{_tmpRelief} = undef;
    $cw->{_buttonPressed} = undef;
  }
}

sub CancelAutoScan { # print STDERR "SUB: CancelAutoScan\n";
  my $lb = shift;
  $lb->CancelRepeat;
}

sub Motion { # print STDERR "SUB: Motion\n";
  my $lb = shift;
  my $Ev = $lb->XEvent;
  my $index = $lb->index($Ev->xy);
  $lb->Motion($index);
}

sub NonSelect { # print STDERR "SUB: NonSelect\n";
  my $cw = shift;

  return unless $cw->popupIsVisible;
  $cw->hidePopup;
  my $index = $cw->getSelectedIndex;
  if (defined($index)) {
    $cw->setSelectedIndex($index);
  }

}
    
sub SelectEntry { # print STDERR "SUB: SelectEntry\n"; 
  my ($cw, $index) = @_;

  if ($cw->Subwidget('Popup')->ismapped) { 
      $cw->setSelectedIndex($index);
  }
  $cw->hidePopup;
}

sub ValidateCmd { # print STDERR "SUB: ValidateCmd\n";
  my ($cw, $str, $chars, $currval, $i, $action) = @_;


  my $vcmd = $cw->cget('-validatecommand');
  if ($vcmd) {
    if (!$vcmd->Call($str, $chars, $currval, $i, $action)) {
      return 0;
    }
  }

  ## Always allow deletes (unless unallowed in user specified)
  my $mode = $cw->cget('-validate');
  my $lb = $cw->Subwidget('Listbox');
 
  if ($str eq "") {
    $lb->selectionClear(0, 'end');
    return 1;
  }
  if ($mode eq "match") {
    my $index = $cw->getItemIndex($str, -mode=> 'ignorecase');
    return 0 unless  (defined($index));
    $lb->selectionClear(0, 'end');
    $lb->selectionSet($index);
    $cw->showPopup 
      if (!$cw->popupIsVisible);
    $lb->see($index);

  } elsif ($mode eq 'cs-match') {
    my $index = $cw->getItemIndex($str, -mode => 'usecase');
    return 0 unless (defined($index));
    $lb->selectionClear(0, 'end');
    $lb->selectionSet($index);
    $cw->showPopup 
	if (!$cw->popupIsVisible); 
    $lb->see($index);
  }
  return 1;
} 

sub EntryEnter { # print STDERR "SUB: EntryEnter\n";
  my $cw = shift;
  return unless $cw->cget('-validate') =~ /cs-match|match/;
  my $lb = $cw->Subwidget('Listbox');
  my $index = $lb->curselection;
  if (defined($index)) {
    $cw->setSelectedIndex($index);
    $cw->hidePopup;
  } else {
    $cw->hidePopup;
  }
}

sub EntryUpDown { # print STDERR "SUB: EntryUpDown\n";
  my ($cw, $modifier) = @_;
  print STDERR "EntryUpDown: $modifier\n";
  return unless $cw->cget('-validate') =~ /cs-match|match/;
  $cw->showPopup unless
    $cw->popupIsVisible;
  my $lb = $cw->Subwidget('Listbox');
  my $index = $lb->curselection;
  print STDERR "EntryUpDown: $index+$modifier\n";
  $lb->activate($index+$modifier);
  $lb->selectionClear(0, 'end');
  $lb->selectionSet('active');
  $lb->see($index+$modifier);
}

sub SetFocus { # print STDERR "SUB: SetFocus\n";
  my $cw = shift;
  if ($cw->cget('-mode') eq 'editable') {
    $cw->Subwidget('ED_Entry')->focus;
  }
}

sub CurSelection { # print STDERR "SUB: CurSelection\n";
  my $cw = shift;
  my $lb = $cw->Subwidget('Listbox');
  my $sel = $lb->curselection;
  if (ref($sel) and $sel->[0]) {
    return $sel->[0];
  } elsif ($cw->cget('-mode') eq 'editable') {
    my $str =  $cw->Subwidget('ED_Entry')->get;
    return $cw->getItemIndex($str);
  } else {
    return undef;
  } 
}

1;
__END__
