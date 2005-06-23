# -*- cperl -*-
package Tk::TrEdNodeEdit;

#   _ _ _ _ _
#   " ' ~ ^ `
use Tk;
use Tk::Tree;
use Tk::Derived;
use Tk::ItemStyle;
use Tk::JComboBox_0_02;
use base qw(Tk::Derived Tk::Tree);
use strict;

Construct Tk::Widget 'TrEdNodeEdit';

use Data::Dumper;
use vars qw(%colors %bitmap);

%colors = (
  alt_flat => "#FFFF00",
  alt => "#CDFFC3",
  list => "#FFCEA9",
  struct => "#FFFFA7",
  sequence => "#B0C1FF",
  constant => "#F6E9D1",
  fg => '#800000',
  bg => '#F6E9D1'
 );

sub _debug {
  print STDERR join "",@_,"\n";
}

sub CreateArgs {
 my ($package,$parent,$args) = @_;
 my @result = $package->SUPER::CreateArgs($parent,$args);
 delete $args->{-columns};
 push(@result, '-columns' => 3);
 return @result;
}

sub find_subwidget {
  my ($w,$name)=@_;
  return $w if ($w->name eq $name);
  foreach ($w->children) {
    my $ww = find_subwidget($_,$name);
    return $ww if $ww;
  }
  return undef;
}

sub Populate {
  my ($w, $args)=@_;

  $args->{-background}=$colors{bg}
    unless exists($args->{-background});

  $w->SUPER::Populate( $args );

  $w->ConfigSpecs(
    -ignoreinvoke => ['PASSIVE',  'ignoreInvoke', 'IgnoreInvoke', 0],

    -relief => ['SELF', 'relief', 'Relief', 'solid'],
    -highlightthickness => ['SELF', 'highlightThickness', 'HighlightThickness', 0],
    -borderwidth => ['SELF', 'borderWidth', 'BorderWidth', 0],

    -indicator => ['SELF', 'indicator', 'Indicator', 1],
    -indent => ['SELF', 'indent', 'Indent', 15],
    -pady => ['SELF', 'pady', 'Pady', 0],
    -drawbranch => ['SELF', 'drawbranch', 'Drawbranch', 1],
    -selectbackground => ['SELF', 'selectBackground', 'Foreground', $colors{bg}],
    -selectmode => ['SELF', 'selectmode', 'Selectmode', 'browse'],

    -separator => ['SELF', 'separator', 'Separator', "/"],
    -columns => ['SELF', 'columns', 'Columns', 3],
    -width => ['SELF', 'width', 'Width', 0],
    -height => ['SELF', 'height', 'Height', 40]

   );

  $w->{my_itemstyles} = {
    default => $w->ItemStyle('text', -foreground=>'#880000',
			     -background => 'white',
			     -pady => 0
			    ),
    list =>  $w->ItemStyle('text', -foreground=>'#800000',
			  -background => $colors{list},
			  -pady => 0
			 ),
    sequence =>  $w->ItemStyle('text', -foreground=>'#800000',
			       -background => $colors{sequence},
			       -pady => 0
			      ),
    struct => $w->ItemStyle('text', -foreground=>'#800000',
			    -background => $colors{struct},
			   ),
    constant => $w->ItemStyle('text', -foreground=>'black',
			    -background => $colors{constant},
			   ),
    alt => $w->ItemStyle('text', -foreground=>$colors{fg},
			 -background => $colors{alt}
			),
    alt_flat => $w->ItemStyle('text', -foreground=>$colors{fg},
			      -background => $colors{alt_flat},
			     ),
    buttons => $w->ItemStyle('window',
			     -pady => 1, -padx => 0, -anchor => "nw"
			    ),
    entries => $w->ItemStyle('window',
			     -pady => 0, -padx => 0, -anchor => "nw"
			    )
   };


  my %minib = qw(
    plus plus
    KP_Add plus
    asterisk star
    KP_Multiply star
    minus minus
    KP_Subtract minus
    Up up
    Down down
    KP_Divide cross
    slash cross
  );
  for (keys %minib) {
    $w->bind('<Control-'.$_.'>',
	     [$w,'invoke_mini_button',$minib{$_}]);
  }

}

sub BindResize {
  my ($w)=@_;
  $w->configure(
    -sizecmd =>
      [sub {
	 my ($w)=shift;
	 return if $w->{in_resize_callback};
	 $w->{in_resize_callback} = 1;
	 $w->afterIdle([$w,'adjust_size']);
       },$w
      ]
     );
}

sub invoke_mini_button {
  my ($hlist,$name)=@_;
  my $path = $hlist->info('anchor');
  if ($path ne '' and
      $hlist->itemExists($path,2) and
      $hlist->itemCget($path,2,'-itemtype') eq 'window') {
    my $w = find_subwidget($hlist->itemCget($path,2,'-widget'),
			   $name."Minibutton");
    if ($w) {
      $w->flash;
      $w->invoke;
    }
  }
  Tk->break;
}

sub ClassInit {
  my ($class, $mw)=@_;

  $class->SUPER::ClassInit($mw);


  $mw->bind($class,'<Return>',\&focus_entry );
  $mw->bind($class,'<space>', ['entry_insert',' ']);
  $mw->bind($class,'<KeyPress>', ['entry_insert',Ev('A')]);
  for (qw(Escape Insert Delete)) {
    $mw->bind($class,'<'.$_.'>', 'NoOp');
  }
  for my $modif (qw(Alt Meta Control)) {
    $mw->bind($class,'<'.$modif.'-'.$_.'>' ,'NoOp') 
      for qw(KeyPress Up Down Return);
  }

  $mw->bind($class,'<Prior>',
	   sub {
	     my ($w)=@_;
	     $w->yview('scroll',-1,'pages');
	     my $ytop = @{$w->yview};
	     my $en = $w->nearest($ytop);;
	     select_entry($w,$en) if $en;
	     Tk->break;
	   });
  $mw->bind($class,'<Next>',
	 sub {
	   my ($w)=@_;
	   $w->yview('scroll',1,'pages');
	   my $ybottom = @{$w->yview} + $w->height;
	   my $en = $w->nearest($ybottom);
	   select_entry($w,$en) if $en;
	   Tk->break;
	 });

  %bitmap = (
    cross =>
      $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x00 };
EOF
  star =>
    $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x15, 0x0e, 0x1f, 0x0e, 0x15, 0x00 };
EOF
  plus =>
    $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x04, 0x04, 0x1f, 0x04, 0x04, 0x00 };
EOF
  minus =>
    $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x0, 0x00, 0x1f, 0x00, 0x00, 0x00 };
EOF
  up =>
    $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x4, 0x0e, 0x11, 0x04, 0x04, 0x00 };
EOF
  down =>
    $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x4, 0x04, 0x11, 0x0e, 0x04, 0x00 };
EOF
);

  $mw->DefineBitmap( 'combo' => 10,4,
		     pack("b10"x4,
			  ".11111111.",
			  "..111111..",
			  "...1111...",
			  "....11...."
			 )
		    );
}

sub mini_button {
  my ($hlist,$w,$bitmap,$path,@opts)=@_;
  my $f = $w->Frame(-background => 'gray',
		    -borderwidth => 1);
  my $b = $f->Button(
    Name => $bitmap."Minibutton",
    -relief => 'ridge',
    -borderwidth => 0,
    -image => $bitmap{$bitmap},
    @opts
   )->pack;
  $b->bind($b,$_,
	   [sub {
	      $_[1]->focus;
	      select_entry($_[1],$_[2]);
	      Tk->break;
	    },$hlist,$path])
    for qw(<Escape> <Return>);
  $b->bind('<FocusIn>',[sub { select_entry($_[1],$_[2]) },$hlist,$path]);
  return $f;
}

sub select_entry {
  my ($hlist,$entry)=@_;
  return unless defined $entry;
  $hlist->anchorSet($entry);
  $hlist->selectionClear();
  $hlist->selectionSet($entry);
  $hlist->see($entry);
}

sub up_or_down {
  my ($hlist,$where,$path)=@_;
  my $parent = $hlist->info(parent => $path);
  return unless $parent;
  my $other = $hlist->next_sibling($path,
				   ($where > 0 ? 'next' : 'prev'));
  return unless ($other ne "" and $other ne $path and $hlist->info('parent',$other) eq $parent);
  my $mtype =
    $hlist->info(data => $parent)->{compressed_type} ||
    $hlist->info(data => $parent)->{type};
  my ($list_no) = $hlist->info(data => $path)->{name} =~ /\[(\d+)\]/;
  my $val = {};

  $hlist->select_entry($path);
  $hlist->update;

  $hlist->dump_child($path, $val, 1);
  $hlist->delete('entry',$path);

  $hlist->add_list_member($parent,$mtype,(values %$val)[0],
		 $list_no,0,
		 [($where>0 ? '-after' : '-before'), $other ]
		);

  $hlist->select_entry($path);
}

sub add_to_list {
  my ($hlist,$path)=@_;
  my $data = $hlist->info(data => $path);
  $data->{list_no}++;
  $hlist->select_entry(
	       $hlist->add_list_member($path,
				      $data->{compressed_type} ||
				      $data->{type},
			      undef,$data->{list_no},0,[-at => 0]));
  $hlist->configure(-height => 0);
}

sub add_to_alt {
  my ($hlist,$path)=@_;
  my $data = $hlist->info(data => $path);
  if (!$data->{compressed_type}) {
    #  simply add new item
    $data->{alt_no}++;
    $hlist->select_entry(
		 $hlist->add_alt_member($path,$data->{type},undef,
					$data->{alt_no},0));
  } else {
    my $val = bless [],'Fslib::Alt';
    $hlist->dump_child($path, $val, 1);
    my $parent = $hlist->info(parent => $path);
    my $next = $hlist->next_sibling($path);
    $hlist->delete('entry',$path);
    my $new_path =
      $hlist->add_member($parent ne '' ? $parent.'/' : '',
		 $data->{type},
		 $val,
		 $data->{name},1,$next ? [-before => $next] : undef);
    $hlist->select_entry($new_path);
  }
#   print "$hlist\n";
#   $hlist->Tk::bind('Freeze','<Map>',undef);
#   $hlist->bindtags([grep { $_ ne 'Freeze'} $hlist->bindtags]);
#   if ($hlist->cget('-height')<2) {
#     $hlist->configure(-height => 0);#$hlist->cget('-height')+3)
#   } else {
#     $hlist->configure(-height => $hlist->cget('-height')+2)
#   }

#  print $hlist->height,"\n";
#  print $hlist->reqheight,"\n";
#  $hlist->parent->parent->configure(-height => $hlist->reqheight);
  print $hlist->cget('-height'),"\n";
}

sub remove_alt_member {
  my ($hlist,$path)=@_;
  my $parent = $hlist->info(parent => $path);
  $hlist->delete('entry',$path);
  $path = $parent;
  if ($hlist->info(children => $path) == 0) {
    # no altrenative left -> replace with the usual type
    my $data = $hlist->info(data => $path);
    my $next = $hlist->next_sibling($path);
    $parent = $hlist->info(parent => $path);
    $hlist->delete('entry',$path);
    my $new_path = $hlist->add_member($parent ne "" ? $parent.'/' : '',
				      $data->{type},undef,
			      $data->{name},0,
			      $next ? [-before => $next] : undef);
    $hlist->select_entry($new_path);
  } else {
    $hlist->select_entry($path);
  }
}

sub new_list_member {
  my ($hlist,$path)=@_;
  my $parent = $hlist->info(parent => $path);
  my $pdata = $hlist->info(data => $parent);
  $pdata->{list_no}++;
  my $new = 
    $hlist->add_list_member($parent,
			   ($pdata->{compressed_type} || $pdata->{type}),
		   undef,$pdata->{list_no},0,
		   [-after => $path]);
  $hlist->select_entry($new);
  $hlist->configure(-height => 0);
}

sub remove_list_member {
  my ($hlist,$path)=@_;
  $hlist->select_entry($hlist->info(next => $path));
  $hlist->delete('entry',$path);
}

sub add_buttons {
  my ($hlist,$path)=@_;

  my $parent = $hlist->info(parent => $path);
  my $mtype = $hlist->info(data => $path)->{type};
  my $ptype = $parent ne "" ? $hlist->info(data => $parent)->{type} : undef;

  return unless (ref($mtype) and ($mtype->{list} or $mtype->{alt}) or 
		 ref($ptype) and ($ptype->{list} or $ptype->{alt}));
  return if ref($mtype) and (($mtype->{list} and $mtype->{list}{role} eq '#CHILDNODES') or $mtype->{role} eq '#CHILDNODES');
  my $f = $hlist->Frame(
    -background => $hlist->cget('-background')
   );

  $hlist->itemCreate($path,2,
		     -itemtype => 'window',
		     -widget => $f,
		     -style => $hlist->{my_itemstyles}{buttons}
		    );
  my $ctype = $hlist->info(data => $path)->{compressed_type};

  for my $type ($mtype, $ctype) {
    if (ref($type)) {
      if ($type->{list}) {
	# add list buttons
	$hlist->mini_button($f,'plus',$path,
			    -background => $colors{list},
			    -command => [$hlist,'add_to_list',$path]
			   )->pack();
      } elsif ($type->{alt}) {
	# add alt buttons
	$hlist->mini_button($f,'star',$path,
			    -background => ($type->{alt}{-flat} ? $colors{alt_flat} : $colors{alt}),
			    -command => [$hlist,'add_to_alt',$path]
			   )->pack(-side => 'top');
      }
    }
  }


  if ($parent ne "") {
    $ptype = (($hlist->info(data => $parent)->{compressed_type}) || $ptype)
  }
#  return; # unless ref $ptype;
  if ($ptype and $ptype->{list}) {
    # add list member buttons
    my ($f1,$f2);
    if ($ptype->{list}{ordered}) {
      $f2 = $f->Frame->pack(qw(-side left));
      $f1 = $f->Frame->pack(qw(-side right));
    } else {
      $f1 = $f->Frame->pack(qw(-side top));
    }
    if ($f1) {
      if ($ptype->{list}{ordered}) {
	$hlist->mini_button($f1,'plus',$path,
			    -background => $colors{list},
			    -command =>
			      [$hlist,'new_list_member',$path]
			     )->pack(qw(-side top));
      }
      $hlist->mini_button($f1,'minus',$path,
			  -background => $colors{list},
			  -command =>
			    [$hlist,'remove_list_member',$path]
			   )->pack(qw(-side top));
    }
    if ($f2) {
      $hlist->mini_button($f2,'up',$path,
			  -background => $colors{list},
			  -command => [$hlist,'up_or_down',-1,$path ]
			 )->pack(qw(-side top));
      $hlist->mini_button($f2,'down',$path,
			  -background => $colors{list},
			  -command => [$hlist,'up_or_down',1,$path]
			 )->pack(qw(-side top));
    }
  } elsif ($ptype and $ptype->{alt}) {
    # add alt member buttons
    $hlist->mini_button($f,'cross',$path,
	  -background => ($ptype->{alt}{-flat} ? $colors{alt_flat} : $colors{alt}),
	  -command => [$hlist,'remove_alt_member',$path]
	   )->pack(-side => 'top');
  }
}


sub add_alt_member {
  my ($hlist,$path,$mtype,$val,$alt_no,$allow_empty,$entry_opts)=@_;
  return $hlist->add_member($path."/",$mtype->{alt},
			    $val,'['.$alt_no.']',$allow_empty,$entry_opts);
}

sub add_list_member {
  my ($hlist,$path,$mtype,$val,$list_no,$allow_empty,$entry_opts)=@_;
  return $hlist->add_member($path."/",$mtype->{list},$val,'['.$list_no.']',$allow_empty,$entry_opts);
}

sub add_sequence_member {
  my ($hlist,$path,$mtype,$val,$list_no,$entry_opts)=@_;
  return $hlist->add_member($path."/",$mtype->{element},$val,'['.$list_no.']',1,$entry_opts);
}


sub next_sibling {
  my ($hlist,$path,$where)=@_;
  $where ||= 'next';
  return undef unless $hlist->info(exists => $path);
  my $next = $hlist->info($where => $path);
  while ($next ne "" and
	   $hlist->info(parent => $next) ne
	   $hlist->info(parent => $path)) {
    $next = $hlist->info($where => $next);
  }
  return undef if
    $next ne "" and
      $hlist->info(parent => $next) ne
	$hlist->info(parent => $path);
  return $next;
}

sub add_member {
  my ($hlist,$base_path,$member,$attr_val,$attr_name,$allow_empty,$entry_opts)=@_;
  my $mtype;
  if (!ref($member) and $member =~ /^#/) {
    $mtype = $member;
  } else {
    $mtype = $hlist->schema->resolve_type($member);
  }
  return if ref($mtype) and $mtype->{role} eq '#CHILDNODES';
  my $path = $base_path.$attr_name;
  my $data = {type => $mtype,
	      name => $attr_name,
	     };
  $hlist->add($path,-data => $data, $entry_opts ? @$entry_opts : ());
  $hlist->itemCreate($path,0,-itemtype => 'text',
		     -text => 
		       ($attr_name =~ /^\[\d+\]$/) ? ' ' : "  ".$attr_name,
		     -style => $hlist->{my_itemstyles}{default}
		    );
  my $enabled = 1;
  if (ref($hlist->{my_enable_callback})) {
    $enabled = $hlist->enable_callback($path);
  }

  if ($mtype eq '#type') {
    $hlist->entryconfigure($path,-style => $hlist->{my_itemstyles}{text});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $attr_val,
		       -style => $hlist->{my_itemstyles}{text});
  } elsif (!ref($mtype) or $mtype->{cdata}) {
    my $w = $hlist->Frame(-background => 'white', #'gray',
			  -borderwidth => 1
			 );
    $data->{value} = $attr_val;
    my $e = $w->Entry( -background => 'white',
		       -textvariable => \$data->{value},#$attr_val,
		       -relief => 'flat',
		       -borderwidth => 1,
		       -state => ($enabled ? 'normal' : 'disabled'),
		       -foreground => 'black',
		       -highlightcolor => 'black',
		       ((ref($mtype) and $mtype->{format} eq 'nonNegativeInteger') ?
		       (-validate => 'all',
			-validatecommand => sub { $_[0]=~/^\d+$/ ? 1 : 0 }) :
		       ())
		      )
      ->pack(qw(-fill both -expand yes));
    $e->bind('<FocusIn>',[sub { $_[1]->select_entry($_[2]) },$hlist,$path]);
    $e->bind('<Up>',[sub {
		       $_[1]->focus;
		       $_[1]->UpDown('prev')},$hlist]);
    $e->bind('<Down>',[sub {
		       $_[1]->focus;
		       $_[1]->UpDown('next')},$hlist]);
    $e->bind($e,$_,[sub { $_[1]->focus; $_[1]->select_entry($_[2]); Tk->break; },$hlist,$path])
      for qw(<Escape> <Return>);
    $e->bind($e,$_,[sub { $_[1]->focus; $_[1]->select_entry($_[2]); },$hlist,$path])
      for qw(<Control-Return>);

    $hlist->itemCreate($path,1,
		       -itemtype => 'window',
		       -widget => $w,
		       -style => $hlist->{my_itemstyles}{entries}
		      );
  } elsif (exists $mtype->{choice}) {
    $data->{value} = $attr_val;
    my $w = $hlist->JComboBox_0_02(

      -mode => 'editable',
      -validate => 'match',
      -takefocus => 1,
      -borderwidth => 0,
      -highlightcolor => 'black',
      -highlightbackground => 'gray',
      -highlightthickness => 1,
      -textvariable => \$data->{value},
      -background => 'gray',

      -choices => ($mtype->{required} ? $mtype->{choice} : ['',@{$mtype->{choice}}]),
      -popupbackground => 'black',
      -borderwidth => 1,
      -relief => 'flat',

      -buttonrelief => 'ridge',
      -buttonbitmap => 'combo'
     );#->pack(qw(-expand 1 -fill both));
    $w->bind('<FocusIn>',[sub {
			    if (not defined($_[0]->{index_on_focus})) {
			      $_[0]->{index_on_focus} = $_[0]->CurSelection;
			    }
			    $_[1]->select_entry($_[2]);
			  },$hlist,$path]);
    $w->bind('<FocusOut>',[sub { #$_[1]->hidePopup;
				 $_[1]->EntryEnter;
				 $_[1]->{index_on_focus} = undef;
#				 $_[1]->MakeValid;
			       },$w]);
    $w->configure(-state => $enabled ? 'normal' : 'disabled');
    for my $subw ($w->Subwidget('ED_Entry'),$w->Subwidget('Popup'),
	 $w->Subwidget('Listbox')) {
      $subw->bind($subw,"<$_>",[sub {
				  shift;
				  my ($w,$hlist,$path,$key)=@_;
			      $w->hidePopup;
			      if ($key eq 'Escape') {
				$w->setSelectedIndex($w->{index_on_focus});
			      } else {
				$w->EntryEnter;
			      }
			      $hlist->focus;
			      $hlist->select_entry($path);
			      Tk->break unless $key eq 'Control-Return';
			    },$w,$hlist,$path,$_]) for qw(Escape Return Control-Return);
    }
    #$w->setSelected($attr_val);
    $hlist->itemCreate($path,1,-itemtype => 'window',
		       -widget => $w,
		       -style => $hlist->{my_itemstyles}{entries}
		      );
  } elsif (exists $mtype->{constant}) {
    $hlist->entryconfigure($path,-style => $hlist->{my_itemstyles}{constant});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $mtype->{constant},
		       -style => $hlist->{my_itemstyles}{constant});
  } elsif (exists $mtype->{structure}) {
    $hlist->entryconfigure($path,-style => $hlist->{my_itemstyles}{struct});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => 'Structure',
		       -style => $hlist->{my_itemstyles}{struct});
    $hlist->add_members($path."/",$mtype->{structure},$attr_val);
  } elsif (exists $mtype->{list}) {
    if ($mtype->{list}{role} eq '#CHILDNODES' or $mtype->{role} eq '#CHILDNODES') { 
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 'child nodes',
			 -style => $hlist->{my_itemstyles}{list});
    } else {
      my $list_no=0;
      $hlist->itemConfigure($path,0,-style => $hlist->{my_itemstyles}{list});
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 
			   $mtype->{list}{ordered} ?
			     'Ordered list' : 'Unordered list',
			 -style => $hlist->{my_itemstyles}{list});


      if ($attr_val) {
	foreach my $val (@{$attr_val}) {
	  $list_no++;
	  $hlist->add_list_member($path,$mtype,$val,$list_no);
	}
      } elsif (!$allow_empty) {
	$list_no++;
	$hlist->add_list_member($path,$mtype,$attr_val,$list_no);
      }
      $data->{list_no}=$list_no;
    }
  } elsif (exists $mtype->{sequence}) {
    my $list_no=0;
    $hlist->itemConfigure($path,0,-style => $hlist->{my_itemstyles}{list});
    if ($mtype->{role} ne '#CHILDNODES') {
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 'XML sequence',
			 -style => $hlist->{my_itemstyles}{sequence});
      if ($attr_val) {
	foreach my $element (@{$attr_val}) {
	  $list_no++;
	  $hlist->add_sequence_member($path,$mtype->{sequence},$element,$list_no);
	}
      }
    } else {
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 'child nodes',
			 -style => $hlist->{my_itemstyles}{sequence});
    }
    $data->{list_no}=$list_no;
  } elsif (exists $mtype->{alt}) {
    my $alt_no=0;
    $hlist->itemConfigure($path,0,-style => 
			    ($mtype->{alt}{-flat} ? $hlist->{my_itemstyles}{alt_flat} : $hlist->{my_itemstyles}{alt}));
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -style => 
			 ($mtype->{alt}{-flat} ?
			   $hlist->{my_itemstyles}{alt_flat} :
			     $hlist->{my_itemstyles}{alt}),
		       -text => 
			 $mtype->{alt}{-flat} ?
			   'FS-Alternative' : 'Alternative');

    if (ref($attr_val) eq 'Fslib::Alt') {
      foreach my $val (@{$attr_val}) {
	$alt_no++;
	$hlist->add_alt_member($path,$mtype,$val,$alt_no);
      }
    } elsif (!ref($attr_val) and $attr_val =~ /\|/ and
	       $mtype->{alt}{-flat}) {
      foreach my $val (split /\|/,$attr_val) {
	$alt_no++;
	$hlist->add_alt_member($path,$mtype,$val,$alt_no);
      }
    } elsif(!$attr_val and !$allow_empty) {
      $alt_no++;
      $hlist->add_alt_member($path,$mtype,$attr_val,$alt_no);
    } else {
      $hlist->delete('entry' => $path);
      $path = $hlist->add_member($base_path,$mtype->{alt},
				 $attr_val,$attr_name,0,$entry_opts);
      my $new_data = $hlist->info('data' => $path);
      $new_data->{compressed_type}=$new_data->{type};
      $new_data->{$_} = $data->{$_} for qw(type name text);
    }
    $data->{alt_no}=$alt_no;
  }
  $hlist->add_buttons($path) if $enabled;
  $hlist->setmode($path);

  return $path;
}

sub add_members {
  my ($hlist,$base_path,$type,$node,$allow_empty)=@_;
  my $members = $type->{member};
  foreach my $attr (sort(keys %$members)) {
    my $member = $members->{$attr};
    my $mtype = $hlist->schema->resolve_type($member);
    if (ref($member) and
	($member->{role} eq '#KNIT' or
	 ref($mtype) and $mtype->{list} and
	 $mtype->{list}{role} eq '#KNIT')
       ) {
      # #KNIT PMLREF or a list of #KNIT PMLREFS
      if (exists($node->{$attr})) {
	$member={ cdata => {format => 'PMLREF'} };
      } else {
	$attr=~s/\.rf$//;
      }
    }
    $hlist->add_member($base_path,$member,($node ? $node->{$attr} : undef), $attr,$allow_empty);
  }
}

sub add_xmlnode {
  my ($hlist,$base_path,$type,$node)=@_;
  if ($node) {
    $hlist->add_member($base_path,'#type',$node->{'#type'}, '#type');
    if ($node->{'#type'} =~ /element/) {
      $hlist->add_member($base_path,'#name',$node->{'#name'}, '#name');
      $hlist->add_member($base_path,'#ns',$node->{'#ns'}, '#ns') if $node->{'#type'} eq 'element';
      if ($type->{attribute}) {
	foreach my $atr (sort keys (%{$type->{attribute}})) {
	  $hlist->add_member($base_path,$type->{attribute}{$atr},$node->{$atr},$atr);
	}
      }
    }
    $hlist->add_member($base_path,$type,$node->{'#content'}, '#content');
  }
}

sub schema {
  $_[0]->{my_schema}
}

sub set_schema {
  my ($hlist,$schema)=@_;
  $hlist->{my_schema}=$schema;
}

sub set_enable_callback {
  my ($hlist,$callback)=@_;
  $hlist->{my_enable_callback}=$callback;
}

sub enable_callback {
  my ($hlist,$path)=@_;
  my $cb = $hlist->{my_enable_callback};
  if (ref($cb) eq 'CODE') {
    $cb->($path)
  } elsif (ref($cb) eq 'ARRAY') {
    my ($func,@args) = @$cb;
    $func->(@args,$path);
  }

}

sub adjust_size {
  my ($w,$manual)=@_;
  $w->parent->update;
  $w->update;
  $w->columnWidth(1,$w->width-4-
			$w->columnWidth(0)-
			$w->columnWidth(2));
  $w->update;
  $w->{in_resize_callback} = 0;
}

sub dump_child {
  my ($hlist, $path, $ref, $preserve_empty,$mtype)=@_;
  my $data = $hlist->info(data => $path);
  $mtype = $data->{type} unless defined $mtype;
  if (!ref($mtype) or $mtype->{cdata} or $mtype->{choice}) {
    if (ref($ref) eq 'Fslib::List' or ref($ref) eq 'Fslib::Alt') {
      push @$ref, $data->{value} if $preserve_empty or defined $data->{value};
    } else {
      $ref->{$data->{name}} = $data->{value};
    }
  } elsif ($mtype->{structure}) {
    my $new_ref;
    if (ref($ref) eq 'Fslib::List' or ref($ref) eq 'Fslib::Alt') {
      $new_ref = {};
      push @$ref, $new_ref;
    } else {
      $ref->{$data->{name}} = {} unless ref($ref->{$data->{name}});
      $new_ref = $ref->{$data->{name}};
    }
    for my $child ($hlist->info(children => $path)) {
      $hlist->dump_child($child,$new_ref,$preserve_empty);
    }
  } elsif ($mtype->{list}) {
    my $new_ref=bless [],'Fslib::List';
    if (ref($ref) eq 'Fslib::List' or ref($ref) eq 'Fslib::Alt') {
      push @$ref, $new_ref;
    } else {
      $ref->{$data->{name}} = $new_ref;
    }
    for my $child ($hlist->info(children => $path)) {
      $hlist->dump_child($child,$new_ref,$preserve_empty);
    }
  } elsif ($mtype->{alt}) {
    my $new_ref=bless [],'Fslib::Alt';
    if ($data->{compressed_type}) {
      $hlist->dump_child($path,$new_ref,
			 $preserve_empty,$data->{compressed_type});
      die "error: expected only single item in a compressed alt\n"
	unless @$new_ref<2;
      $new_ref = $new_ref->[0];
    } else {

      for my $child ($hlist->info(children => $path)) {
	$hlist->dump_child($child,$new_ref,$preserve_empty);
      }
      unless ($preserve_empty) {
	# simpify <=1 element alternatives
	if (@$new_ref == 1) {
	  $new_ref = $new_ref->[0];
	} elsif (@$new_ref == 0) {
	  $new_ref = undef;
	}
      }
    }
    if (ref($ref) eq 'Fslib::List' or ref($ref) eq 'Fslib::Alt') {
      push @$ref, $new_ref;
    } elsif (ref($new_ref) and $mtype->{alt}{-flat}) {
      $ref->{$data->{name}} = join '|',@$new_ref;
    } else {
      $ref->{$data->{name}} = $new_ref;
    }
  }
}

sub dump_to_node {
  my ($hlist,$node,$preserve_empty)=@_;
  for my $child ($hlist->info(children => '')) {
    $hlist->dump_child($child,$node,$preserve_empty);
  }
}

sub focus_entry {
  my ($hlist)=@_;
  my $path = $hlist->info('anchor');
  return unless $hlist->info('exists',$path);
  if ($hlist->itemExists($path,1)) {
    my $mode = $hlist->getmode($path);
    if ($mode ne 'none') {
      $hlist->$mode($path);
    } else {
      return unless $hlist->itemCget($path,1,'-itemtype') eq 'window';
      my $w = $hlist->itemCget($path,1,'-widget');
      while (ref($w) eq 'Tk::Frame') {
	($w) = $w->children;
      }
      if ($w) {
	$w->focus;
	if ($w->isa('Tk::JComboBox_0_02')) {
	  $w->showPopup unless $w->popupIsVisible;
	}
      }
    }
  }
  Tk->break;
}

sub entry_insert {
  my ($hlist,$what)=@_;
  my $path = $hlist->info('anchor');
  return unless $hlist->info('exists',$path);
  return unless $what ne '';
  if ($hlist->itemExists($path,1)) {
    my $mode = $hlist->getmode($path);
    if ($what eq ' ' and $mode ne 'none') {
      $hlist->$mode($path);
    } else {
      return unless $hlist->itemCget($path,1,'-itemtype') eq 'window';
      my $w = $hlist->itemCget($path,1,'-widget');
      while (ref($w) eq 'Tk::Frame') {
	($w) = $w->children;
      }
      if ($w) {
	if ($w->isa('Tk::JComboBox_0_02')) {
	  $w->{index_on_focus} = $w->CurSelection;
	  $w->showPopup unless $w->popupIsVisible;
	  $w = $w->Subwidget('ED_Entry');
	}
	$w->selectionClear;
	$w->selectionRange(0,'end');
	$w->focus;
	if ($what =~ /[^[:cntrl:]]/ and $w->can('Insert')) {
	  $w->Insert($what);
	}
      }
    }
  }
  Tk->break;
}

# "fix" behavior of JComboBox
*Tk::JComboBox_0_02::EntryUpDown = sub {
  my ($cw, $modifier) = @_;
  return unless $cw->cget('-validate') =~ /cs-match|match/;
  $cw->showPopup unless
    $cw->popupIsVisible;
  my $lb = $cw->Subwidget('Listbox');
  my $index = $lb->curselection;
  $lb->activate(($index and @$index) ? $index->[0]+$modifier : 0);
  $lb->selectionClear(0, 'end');
  $lb->selectionSet('active');
  $lb->see($index+$modifier);
  my $e = $cw->Subwidget('ED_Entry');
  if ($e) {
    $e->delete(0,'end');
    $e->insert(0,$lb->get('active'));
  }
  Tk->break;
};


*Tk::JComboBox_0_02::EntryEnter = sub {
  my $cw = shift;
  return unless $cw->cget('-validate') =~ /cs-match|match/;
  my $lb = $cw->Subwidget('Listbox');
  my $index = $lb->curselection;
  $index = 0 unless defined($index);
  $cw->setSelectedIndex($index);
  $cw->hidePopup;
};


# *Tk::JComboBox_0_02::MakeValid = sub {
#   my ($cw) = @_;
#   my $mode = $cw->cget('-validate');
#   print "MODE: $mode\n";
#   return unless $mode=~/^(cs-match|match)$/;
#   my $e = $cw->Subwidget('ED_Entry');
#   my $str = $e->get();
#   print "STR: '$str'\n";
#   my $index = $cw->getItemIndex($str, 
#       -mode=> ($mode eq 'match') ? 'ignorecase' : 'usecase');
#   $index = 0 unless defined($index);
#   print "INDEX: '$index'\n";
#   $lb->selectionClear(0, 'end');
#   $lb->selectionSet($index);
#   if ($e) {
#     $e->delete(0,'end');
#     $e->insert(0,$lb->get('active'));
#   }
#   $lb->see($index);
# };


1;
