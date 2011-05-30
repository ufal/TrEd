package TrEd::Bindings;

use strict;
use warnings;

# consider moving keyBindings and macroBindings from TrEd::Macro here...?

# rotation of keyboard bindings for verticalTree mode
my %vertical_key_arrow_map = (
  Left => 'Up',
  Right => 'Down',
  Up => 'Left',
  Down => 'Right',
);

my %context_override_binding;
#TODO: do nejakeho TrEd::Config::View alebo do TrEd::Config?
my %default_binding = (
  '<Tab>' => 
    [ sub { 
	main::currentNext($_[1]->{focusedWindow}); Tk->break; },
      'select next node',
      'top',
     ],
  '<Shift-ISO_Left_Tab>' => 
    [sub { main::currentPrev($_[1]->{focusedWindow}); Tk->break; },
     'select previous node',
    ],
  '<Shift-Tab>'=>
    [sub { main::currentPrev($_[1]->{focusedWindow}); Tk->break; },
     'select previous node',
    ],
  '<period>'=> 
    [sub { main::onIdleNextTree($_[1]->{focusedWindow}); }, 'go to next tree', ],
  '<comma>'=> 
    [sub { main::onIdlePrevTree($_[1]->{focusedWindow}); }, 'go to previous tree',
    ],
  '<Next>'=> 
    [sub { main::onIdleNextTree($_[1]->{focusedWindow}); }, 'go to next tree', ],
  '<Prior>'=> 
    [sub { main::onIdlePrevTree($_[1]->{focusedWindow}); }, 'go to previous tree', ],
  '<greater>'=>
    [sub { my $fw=$_[1]->{focusedWindow};
	   main::gotoTree($fw,
		    $fw->{FSFile}->lastTreeNo);
	   Tk->break();
	 },
     'go to last tree in file',
    ],
  '<less>'=> 
    [sub { main::gotoTree($_[1]->{focusedWindow},0);
	   Tk->break();
	 },
     'go to first tree in file',
    ],
  '<KeyPress-Return>'=>
    [sub { main::editAttrsDialog($_[1]->{focusedWindow},
			   $_[1]->{focusedWindow}->{currentNode});
	   Tk->break();
	 },
     'view/edit attributes',
    ],
  '<KeyPress-Left>'=>
    [sub {
       my $grp = $_[1];
       if (main::treeIsVertical($grp)) {
	 main::currentUp($grp);
       } else {
	 main::treeIsReversed($grp)
	   ? main::currentRight($grp)
	   : main::currentLeft($grp);
       }
       Tk->break();
     },
     'select left sibling',
    ],
  '<Shift-Home>'=>
    [sub {main::gotoFirstDisplayedNode($_[1]); Tk->break()}, 'select left-most node',
   ],
  '<Shift-End>'=>
    [sub {main::gotoLastDisplayedNode($_[1]); Tk->break()}, 'select right-most node',
   ],
  '<Shift-Left>'=>
    [sub {
       my $grp = $_[1];
       main::currentLeftWholeLevel($grp);
       Tk->break();
     },
     'select previous node on the same level',
    ],
  '<KeyPress-Right>'=>
    [sub {
      my $grp = $_[1];
      if (main::treeIsVertical($grp)) {
        main::currentDown($grp);
      } else {
        main::treeIsReversed($grp)
        ? main::currentLeft($grp)
        : main::currentRight($grp);
      }
        Tk->break();
     },
     'select right sibling',
    ],
  '<Shift-Right>'=>
    [sub {
       my $grp = $_[1];
       main::currentRightWholeLevel($grp);
       Tk->break();
     },
     'select next node on the same level',
    ],
  '<KeyPress-Up>'=>
    [sub {
       my $grp = $_[1];
       if (main::treeIsVertical($grp)) {
	 main::currentLeft($grp);
       } else {
	 main::currentUp($grp);
       }
       Tk->break();
     },
     'select parent node',
    ],
  '<Shift-Up>'=>
    [sub {
       my $grp = $_[1];
       main::treeIsReversed($grp)
	 ? main::currentRightLin($grp)
	 : main::currentLeftLin($grp);
       Tk->break();
     },
     'select previous node in linear order',
    ],
  '<KeyPress-Down>'=>
    [sub {
       my $grp = $_[1];
       if (main::treeIsVertical($grp)) {
	 main::currentRight($grp);
       } else {
	 main::currentDown($grp);
       }
       Tk->break();
     },
     'select first child-node',
    ],
  '<Shift-Down>'=>
    [sub {
       my $grp = $_[1];
       main::treeIsReversed($grp)
	 ? main::currentLeftLin($grp)
	 : main::currentRightLin($grp);
       Tk->break();
     },
     'select next node in linear order',
    ],
  '<Control-Tab>'=>
    [sub {
       my $grp = $_[1];
       main::focusNextWindow($grp);
       Tk->break();
     },
     'focus next view',
    ],
  '<Control-Shift-Tab>'=>
    [sub {
       my $grp = $_[1];
       main::focusPrevWindow($grp);
       Tk->break();
     },
     'focus previous view',
    ],
  '<Control-Shift-ISO_Left_Tab>'=>
    [sub {
       my $grp = $_[1];
       main::focusPrevWindow($grp);
       Tk->break();
     },
     'focus previous view',
    ],
 );
 
# binding
sub resolve_default_binding {
  my ($grp,$key) =@_;
  my $context = $grp->{focusedWindow}->{macroContext};
  my $key2 = $key;
  $key2=~s/^<KeyPress-/</;
  my $def = ($context_override_binding{$context} &&
	       ($context_override_binding{$context}{$key} || $context_override_binding{$context}{$key2}))
    || $default_binding{$key} || $default_binding{$key2};
  return $def;
}

# binding
sub default_binding {
  my ($mw, $key, $grp, @args)=@_;
  my $def = resolve_default_binding($grp,$key);
  if (ref($def->[0]) eq 'CODE') {
    $def->[0]->($mw,$grp,$key,@args);
  } elsif (ref($def->[0]) eq 'Tk::Callback') {
    $def->[0]->Call($mw,$grp,$key,@args);
  }
}

# binding
sub change_default_binding {
  my ($grp,$context,$key,$spec)=@_;
  my $def;
  if ($context and $context eq '*') {
    $def = $default_binding{"<$key>"} || $default_binding{"<KeyPress-$key>"};
    return unless $def;
  } else {
    $def = $context_override_binding{$context}{"<KeyPress-$key>"} ||
      ($context_override_binding{$context}{"<$key>"}||=[]);
  }
  my $prev = [@$def[0,1]];
  if (ref($spec) eq 'ARRAY') {
    if (ref($spec->[0]) eq 'ARRAY') {
      $def->[0]=Tk::Callback->new($spec->[0]);
    } else {
      $def->[0]=$spec->[0];
    }
    $def->[1]=$spec->[1];
  }
  return $prev;
}

# binding
sub get_default_binding {
  my ($grp,$context,$key)=@_;
  my $def = ($context and $context eq '*') ? ($default_binding{"<KeyPress-$key>"}  || $default_binding{"<$key>"}) :
    ($context_override_binding{$context} && ($context_override_binding{$context}{"<KeyPress-$key>"} ||
					     $context_override_binding{$context}{"<$key>"}));
  return $def ? [@$def[0,1]] : [];
}

sub setup_default_bindings {
  my ($tred_ref) = @_;
# setup default binding
  while (my ($key, $def) = each %default_binding) {
    $tred_ref->{ $def->[2] || 'Toolbar' }->bind('my', $key => [ \&default_binding, $key, $tred_ref ]);
  }
}

1;
