# -*- cperl -*-
package Tk::TrEdNodeEdit;

# See the documentation at the bottom of this document.

use Tk;
use Tk::Frame;
use Tk::Entry;
use Tk::Balloon;
use Tk::Tree;
use Tk::Button;
use Tk::Bitmap;
use Tk::Menu;
use Tk::Menubutton;
use Tk::Derived;
use Tk::ItemStyle;
use Tk::JComboBox_0_02;
use Tk::QueryDialog;
use base qw(Tk::Derived Tk::Tree);
use strict;
use Carp;
use Treex::PML qw();
use Treex::PML::Schema qw(:constants);
use UNIVERSAL::DOES;
use Scalar::Util qw(blessed);

Construct Tk::Widget 'TrEdNodeEdit';

use Data::Dumper;
use vars qw(%colors %bitmap);

use constant CLEAR => 1;
use constant FORCE_CLEAR => 2;

%colors = (
  alt_flat => "#FFDD77",
  alt => "#CDFFC3",
  list => "#FFCEA9",
  struct => "#FFFFA7",
  sequence => "#B0C1FF",
  fg => '#800000',
  bg => '#F6E9D1',
  constant => '#F6E9D1',
  select_bg => '#a0a0ff',
  select_fg => 'black',
  required_fg => '#0000cc',
  disabled_fg => '#777',
  disabled_bg => 'white',
 );

sub _debug {
  print STDERR join "",@_,"\n";
}

sub CreateArgs {
 my ($package,$parent,$args) = @_;
 my @result = $package->SUPER::CreateArgs($parent,$args);
 delete $args->{-columns};
 unshift(@result, '-columns' => $args->{-columns}||3);
 return @result;
}

sub find_subwidget {
  my ($w,$name)=@_;
  return $w if ($w->name eq $name);
  foreach ($w->children) {
    my $ww = find_subwidget($_,$name);
    return $ww if $ww;
  }
  return;
}

sub Populate {
  my ($w, $args)=@_;
  my $colors = delete $args->{-colors};
  if ($colors) {
    $colors = { %colors, %$colors };
  } else {
    $colors = \%colors;
  }
  $w->{colors}=$colors;
  $w->{userdata}{common_item_style}=delete $args->{'-itemstyle'}||{};

  $args->{-background}=$colors->{bg}
    unless exists($args->{-background});
  $args->{-selectbackground}=$colors->{select_bg}
    unless exists($args->{-selectbackground});
  $args->{-selectforeground}=$colors->{select_fg}
    unless exists($args->{-selectforeground});

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

    -selectmode => ['SELF', 'selectmode', 'Selectmode', 'browse'],

    -separator => ['SELF', 'separator', 'Separator', "/"],
#    -columns => ['SELF', 'columns', 'Columns', 3],
    -width => ['SELF', 'width', 'Width', 0],
    -height => ['SELF', 'height', 'Height', 40],
#    -takefocus => ['SELF', 'takeFocus', 'TakeFocus', 1]
   );
}
sub InitObject {
  my ($w, $args)=@_;
  $w->SUPER::InitObject($args);
  my $font = $args->{-font};
  my $colors = $w->{colors};
  my %styles = (
    required => ['text', -foreground=>'#0000aa',
		 -background => 'white',
		 -pady => 0,
	       ],
    default => ['text', -foreground=>'#880000',
		-background => 'white',
		-pady => 0
	       ],
    list =>  ['text',
	      -foreground=>'#800000',
	      -background => $colors->{list},
	      -pady => 0
	     ],
    sequence =>  ['text',
		  -foreground=>'#800000',
		  -background => $colors->{sequence},
		  -pady => 0
		 ],
    struct => ['text',
	       -foreground=>'#800000',
	       -background => $colors->{struct},
	     ],
    constant => ['text',
		 -foreground=>'black',
		 -background => $colors->{constant},
	       ],
    alt => ['text', -foreground=>$colors->{fg},
	    -background => $colors->{alt}
	   ],
    alt_flat => ['text', -foreground=>$colors->{fg},
		 -background => $colors->{alt_flat},
	       ],
    buttons => ['window',
		-pady => 1, -padx => 0, -anchor => "nw"
	       ],
    entries => ['window',
		-pady => 0, -padx => 0, -anchor => "nw"
	       ],
    choice => ['text', -foreground=>'black',
	       -background => 'white',
	     ],
    cdata => ['text', -foreground=>'black',
	      -background => 'white',
	    ],
    invalid_cdata => ['text', -foreground=>'black',
		      -background => 'pink',
		     ],
    disabled_choice => ['text',
			-foreground=>$colors->{disabled_fg},
			-background=>$colors->{disabled_bg},
		      ],
    disabled_cdata => ['text',
		       -foreground=>$colors->{disabled_fg},
		       -background=>$colors->{disabled_bg},
		     ],
    disabled_invalid_cdata => ['text',
			       -foreground=>'red',
			       -background=>$colors->{disabled_bg},
			      ],
   );

  $w->{userdata}{itemstyles} = {
    map {
      my $styles = $styles{$_};
      my $type = $styles->[0];
      $_ => $w->ItemStyle(
	$type,
	(($font and $type eq 'text') ? (-font => $font) : ()),
	@{$styles}[1..$#$styles],
	%{$w->{userdata}{common_item_style}},
     ) } keys %styles
  };

  $w->{balloon}=$w->toplevel->Balloon(-initwait=> 1000,
				      -state=> 'balloon',
				     );
  $w->{balloon}->Tk::Toplevel::configure(-background=> '#fff3b0');

  my %minib = qw(
    plus plus
    KP_Add plus
    asterisk star
    numbersign hash
    KP_Multiply star
    minus minus
    KP_Subtract minus
    Up up
    Down down
    KP_Divide cross
    slash cross
  );

  for (keys %minib) {
    $w->bind('<Control-'.$_.'>', [$w,'invoke_mini_button',$minib{$_}]);
    $w->bind('<Alt-'.$_.'>', [$w,'invoke_mini_button',$minib{$_}]);
  }
  $w->configure(-browsecmd => [\&_browse_cmd,$w]);
}

sub _entry_validate {
  my ($self,$txt)=@_;
  my $w_path = $self->{userdata}{current_widget_path};
  my $e = $self->{userdata}{current_widget};
  $e = $e->Subwidget('ED_Entry') if ref($e)=~/JComboBox/;
  return unless defined $w_path;
  my $w_data = $self->info('data' => $w_path);
  my $mdecl = $w_data->{compressed_type} || $w_data->{type};
  my $required = $w_data->{required};

  if (($txt ne q{} and
	 do {
	   my $apath = $w_path; $apath=~s{/\[\d+\]}{}g;
	   my $base_path = $self->{userdata}{base_path};
	   $apath = $base_path.$apath if defined $base_path;
	   $self->do_callback('validate',1,$txt,$apath);
	 } and $mdecl->validate_object($txt)
     )
      or
      ($txt eq q{} and !$required)) {
    $e->configure(-background => 'white');
    $e->configure(-disabledforeground => $colors{disabled_bg});
  } else {
    $e->configure(-background => 'pink');
    $e->configure(-disabledforeground => 'red');
  }
  return 1;
}

sub _browse_cmd {
  my ($self, $path)=@_;
  $self->{userdata}{new_path}=$path;
  if (defined $self->{userdata}{pending_update}) {
    eval { $self->afterCancel($self->{userdata}{pending_update}); };
  } else {
    $self->_edit_entry(CLEAR);
  }
  $self->{userdata}{pending_update} = $self->after(150,[$self,'_edit_entry']);
}
sub _edit_entry {
  my ($self,$clear_only)=@_;
  $self->{userdata}{pending_update}=undef unless $clear_only;
  my $path = $self->{userdata}{new_path};
  my $prev_path = $self->{userdata}{current_path};
  return if $path eq $prev_path and $clear_only!=FORCE_CLEAR;
  my $w_path = $self->{userdata}{current_widget_path};
  my $w = $self->{userdata}{current_widget};
  if (defined($w_path) and $self->info(exists=>$w_path)) {
    my $w_data = $self->info('data' => $w_path);
    $self->itemDelete($w_path,1);
    if ($w) {
      $w->destroy;
      $self->{userdata}{current_widget} = $w = undef;
    }
    my $val = $w_data->{value};
    my $valid;
    if ($w_data->{dump} == PML_CDATA_DECL) {
      my $mdecl = $w_data->{compressed_type} || $w_data->{type};
      my $required = $w_data->{required};
      $valid = (($val ne q{} and $mdecl->validate_object($val))
		     or ($val eq q{} and !$required));
    }
    $val=" " unless defined $val and length $val;

    my $password_map = $self->get_option('password_map');
    my $password_hide;
    if (ref($password_map)) {
      my $p = $w_path;
      $p =~ s{/\[\d+\]/?}{/}g;
      $val=~s/./*/g if $password_map->{$p}
    }
    $self->itemCreate($w_path,1,
		      -itemtype => 'text',
		      -text => $val,
		      -style => $self->{userdata}{itemstyles}{
			($w_data->{enabled} ? '' : 'disabled_').
			($w_data->{dump} == PML_CDATA_DECL ?
			   ($valid ? '' : 'invalid_').'cdata'
			     : 'choice')},
		     );
  }
  $self->{userdata}{current_widget_path} = undef;
  return if $clear_only;
  my $data = $self->info('data' => $path);
  my $mdecl = $data->{type};
  if ($data != PML_ALT_DECL and
	ref($mdecl) and $mdecl->get_decl_type == PML_ALT_DECL) {
    $mdecl = $mdecl->get_content_decl;
  }
  # editable:
  if ( $data and $data->{enabled} and
	 ($data->{dump} == PML_CDATA_DECL)
     ) {

    $self->{userdata}{current_widget_path} = $path;
    $self->itemDelete($path,1);
    my ($w,$choices);
    {
      my $apath = $path; $apath=~s{/\[\d+\]}{}g;
      my $base_path = $self->{userdata}{base_path};
      $apath = $base_path.$apath if defined $base_path;
      $choices = $self->do_callback('choices',undef,$apath,$mdecl,$self);
    }
    if (defined($choices) and ref($choices) eq 'ARRAY') {
      $w = $self->{userdata}{current_widget} = $self->_create_combo(
	-textvariable => \$data->{value},
	-state => $data->{enabled} ? 'normal' : 'disabled',
       );
      $w->configure(
	# this has to be a separate call after -textvariable is configured
	# otherwise Popup is shown
	-choices => $choices,
       );
      $w->configure(-validate => 'key');
      $w->configure(-validatecommand => [sub {
		      my ($self,$cw,$str, $chars, $currval, $i, $action)=@_;
		      my $lb = $cw->Subwidget('Listbox');
		      if ($str eq "") {
			$lb->selectionClear(0, 'end');
			return $self->_entry_validate($str, $chars, $currval, $i, $action);
		      }
		      my $index = $cw->getItemIndex($str, -mode=> 'usecase');
		      $lb->selectionClear(0, 'end');
		      return $self->_entry_validate($str, $chars, $currval, $i, $action) unless (defined($index));
		      $lb->selectionSet($index);
		      $cw->showPopup if (!$cw->popupIsVisible);
		      $lb->see($index);
		      return $self->_entry_validate($str, $chars, $currval, $i, $action);
		    },$self,$w]);
    } else {
      my $password_map = $self->get_option('password_map');
      my $password_hide;
      if (ref($password_map)) {
	my $p = $path;
	$p =~ s{/\[\d+\]/?}{/}g;
	$password_hide = $password_map->{$p};
      }
      $w = $self->{userdata}{current_widget} =
	$self->_create_entry(
	  -state => ($data->{enabled} ? 'normal' : 'disabled'),
	  $password_hide ? (-show => '*') : (),
	  ($mdecl->get_format ne 'any') ?
	    (-validate => 'all', -validatecommand => [$self,'_entry_validate']) : ()
	   );
      # -textvariable validation requires current_widget to be set
      $w->configure(-textvariable => \$data->{value});
    }
    $self->itemCreate($path,1,
		      -itemtype => 'window',
		      -widget => $w,
		      -style => $self->{userdata}{itemstyles}{entries}
		     );
    #    $self->_entry_validate($data->{value});
  } elsif ($data and $data->{dump} == PML_CHOICE_DECL) {
    $self->{userdata}{current_widget_path} = $path;
    $self->itemDelete($path,1);
    my $w = $self->{userdata}{current_widget} = $self->_create_combo(
      -textvariable => \$data->{value},
      -state => $data->{enabled} ? 'normal' : 'disabled',
    );
    my @values = $self->get_custom_value_ordering([$mdecl->get_values],$path);
    unshift @values, '' unless $data->{required};
    $w->configure(
      # this has to be a separate call after -textvariable is configured
      # otherwise Popup is shown
      -choices => \@values,
    );
    $self->itemCreate($path,1,
		      -itemtype => 'window',
		      -widget => $w,
		      -style => $self->{userdata}{itemstyles}{entries}
		     );
  }
  $self->{userdata}{current_path} = $path;

}

sub _create_entry {
  my $hlist = shift;
  my $e = $hlist->Entry( -background => 'white',
			 -relief => 'flat',
			 -borderwidth => 0,
			 -foreground => 'black',
			 -highlightcolor => 'black',
			 -disabledforeground => $hlist->{colors}{disabled_fg},
			 -disabledbackground => $hlist->{colors}{disabled_bg},
			 -font => $hlist->cget('-font'),
			 @_
			);
  $e->bind('<FocusIn>',[sub { $_[1]->select_entry($_[1]->{userdata}{current_widget_path}) },$hlist]);
  $e->bind('<Up>',[sub {
		     my $w=$_[1];
		     $w->focus;
		     $w->UpDown('prev')},$hlist]);
  $e->bind('<Down>',[sub {
		       my $w=$_[1];
		       $w->focus;
		       $w->UpDown('next')},$hlist]);
  $e->bind('<Tab>',[$hlist,'MoveFocus','next']);
  $e->bind('<<LeftTab>>',[$hlist,'MoveFocus','prev']);
  $e->bind($e,'<Escape>',[sub {
		     my $w=$_[1];
		     $w->focus;
		     $w->select_entry($w->{userdata}{current_widget_path}); Tk->break; },$hlist]);
  $e->bind($e,'<Return>',[sub {
		     my $w=$_[1];
		     $w->focus;
		     my $path = $w->{userdata}{current_widget_path};
		     my $next = $w->info(next => $path);
		     $w->select_entry(length($next) ? $next : $path);
		     Tk->break; },$hlist]);

  $e->bind($e,'<Control-Return>',[sub {
		    my $w=$_[1];
		    $w->focus;
		    $w->select_entry($w->{userdata}{current_widget_path}); },$hlist]);
  return $e;
}

sub _create_combo {
  my $hlist=shift;
  my $w = $hlist->JComboBox_0_02(
    -mode => 'editable',
    -validate => 'match',
    -takefocus => 1,

    -highlightcolor => 'black',
    -highlightbackground => 'gray',
    -highlightthickness => 1,

    -background => 'gray',
    -popupbackground => 'black',
    -borderwidth => 0,

    -listhighlight=>1,

    -relief => 'flat',
    -buttonrelief => 'ridge',
    -buttonbitmap => 'combo',
    -buttonborderwidth => 0,

    -font => $hlist->cget('-font'),
    @_,
   );
    $w->setSelected( $w->getSelectedValue );
    $w->bind('<FocusIn>',[$hlist,'_focus_combo']);
    $w->bind('<FocusOut>',[sub {
			     $_[1]->EntryEnter;
			     $_[1]->{index_on_focus} = undef;
			   },$w]);
  my $entry = $w->Subwidget('ED_Entry');
  my $lb = $w->Subwidget('Listbox');
  if ($w->cget('-state') eq 'disabled') {
    $lb->configure(
      -foreground => $hlist->{colors}{disabled_fg},
      -selectforeground => $hlist->{colors}{disabled_fg},
     );
  }
  $entry->configure(
    -disabledforeground => $hlist->{colors}{disabled_fg},
    -disabledbackground => $hlist->{colors}{disabled_bg},
   );
  my $take_focus = $hlist->cget('-takefocus');
  $w->configure(-takefocus=>$take_focus);
  for my $subw ($entry,$w->Subwidget('Popup'),$lb) {
    if ($take_focus) {
      $subw->bind('<Tab>',[$hlist,'MoveFocus','next']);
      $subw->bind('<<LeftTab>>',[$hlist,'MoveFocus','prev']);
      $subw->bind($subw,'<Escape>',[sub {
				      shift;
				      my ($w,$hlist)=@_;
				      $w->setSelectedIndex($w->{index_on_focus})
					if $w->cget('-validate') =~ /match/;
				      $hlist->focus;
				      $hlist->select_entry($hlist->{userdata}{current_widget_path});
				      Tk->break;
				    },$w,$hlist]);
      $subw->bind($subw,"<$_>",[sub {
				  shift;
				  my ($w,$hlist,$key)=@_;
				  if ($w->cget('-validate') !~ /match/ and
					$key ne 'Control-Return') {
				    if ($w->popupIsVisible) {
				      my $lb = $w->Subwidget('Listbox');
				      my $index = $lb->curselection;
				      if (defined($index)) {
					$w->setSelectedIndex($index);
				      }
				    }
				  }
				  $w->hidePopup;
				  $w->EntryEnter;
				  $hlist->focus;
				  my $path = $hlist->{userdata}{current_widget_path};
				  my $next = $hlist->info(next => $path);
				  $hlist->select_entry(length($next) ? $next : $path);
				  Tk->break unless $key eq 'Control-Return';
				},$w,$hlist,$_]) for qw(Return Control-Return);
    } else {
      $subw->configure(-takefocus=>0);
    }
    for my $subw ($entry,$w) {
      $subw->bind($subw,'<Up>',[sub {
			    my ($cw,$hl,$combo)=@_;
			    if ($combo->popupIsVisible) {
			      $combo->EntryUpDown(-1);
			    } else {
			      $hl->focus;
			      $hl->UpDown('prev')
			    }},$hlist,$w]);
      $subw->bind($subw,'<Down>',[sub {
			    my ($cw,$hl,$combo)=@_;
			    if ($combo->popupIsVisible) {
			      $combo->EntryUpDown(1);
			    } else {
			      $hl->focus;
			      $hl->UpDown('next')
			    }},$hlist,$w]);
    }
  }
  return $w;
}

sub _focus_combo {
  my ($hl) = @_;
  my $cw = $hl->{userdata}{current_widget};
  my $lb = $cw->Subwidget('Listbox');
  if (not defined($cw->{index_on_focus})) {
    my $index = $cw->{index_on_focus} = $cw->CurSelection;
    if (defined $index and length $index) {
      my $lb = $cw->Subwidget('Listbox');
      $lb->see($index);
    }
  }
  $hl->select_entry($hl->{userdata}{current_widget_path});
}

sub balloon {
  shift->{balloon};
}

sub _resize {
  my ($w)=shift;
  return if $w->{in_resize_callback};
  $w->{in_resize_callback} = 1;
  $w->afterIdle([$w,'adjust_size']);
}

sub invoke_mini_button {
  my ($hlist,$name)=@_;
  my $path = $hlist->info('anchor');
  if ($path ne '' and
      $hlist->cget('-columns')>2 and
      $hlist->itemExists($path,2) and
      $hlist->itemCget($path,2,'-itemtype') eq 'window') {
    my $w = find_subwidget($hlist->itemCget($path,2,'-widget'),
			   $name."Minibutton");
    if (blessed($w) and $w->isa('Tk::Menubutton')) {
      $w->PostFirst;
    } elsif ($w) {
      $w->flash;
      $w->invoke;
    }
  }
  Tk->break;
}

sub ClassInit {
  my ($class, $mw)=@_;
  $class->SUPER::ClassInit($mw);
  $mw->bind($class,'<<Paste>>',['entry_clipboard','Paste']);
  $mw->bind($class,'<<Copy>>',['entry_clipboard','Copy']);
  $mw->bind($class,'<<Cut>>',['entry_clipboard','Cut']);

  $mw->bind($class,'<Return>',\&focus_entry );
  $mw->bind($class,'<KeyPress>', ['entry_insert',Ev('A')]);

  $mw->bind($class,'<space>', ['entry_insert',' ']);
  for (qw(Escape Insert Delete Tab)) {
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

  $mw->bind($class,'<Tab>',['MoveFocus','next']);
  $mw->bind($class,'<<LeftTab>>',['MoveFocus','prev']);

  %bitmap = (

# 84218421
#1    x x
#2   xxxxx
#3    x x
#4   xxxxx
#5    x x
#6
    hash =>
      $mw->Bitmap(-data => <<'EOF'),
#define x_width 6
#define x_height 6
static unsigned char x_bits[] = { 0x0a, 0x1f, 0x0a, 0x1f, 0x0a, 0x00 };
EOF
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
  my ($hlist,$w,$bitmap,$path,$opts)=@_;
  my $f = $w->Frame(-background => 'gray',
		    -borderwidth => 1);
  my $menu_opts = delete $opts->{-menu};
  my $balloonmsg = delete $opts->{-balloonmsg};

  my $b;
  if ($menu_opts) {
    $b = $f->Menubutton(
      Name => $bitmap."Minibutton",
#      -relief => 'ridge',
#      -borderwidth => 0,
      -image => $bitmap{$bitmap},
      %$opts);
    $b->Tk::pack('configure');
    my $entries = delete($menu_opts->{-entries}) || [];
    my $entries_opts = delete($menu_opts->{-entries_opts}) || {};
    my $menu = $b->menu(-tearoff => 0, %$menu_opts);
    $b->configure(-menu => $menu);
    for my $entry (@$entries) {
      $menu->add(@$entry,%$entries_opts);
    }
  } else {
    $b = $f->Button(
      Name => $bitmap."Minibutton",
      -relief => 'ridge',
      -borderwidth => 0,
      -image => $bitmap{$bitmap},
      %$opts
     );
    $b->Tk::pack('configure');
  }

  if ($hlist->cget('-takefocus')) {
    $b->bind($b,$_,
	     [sub {
		my (undef,$w,$pth)=@_;
		$w->focus;
		select_entry($w,$pth);
		Tk->break;
	    },$hlist,$path])
      for qw(<Escape> <Return>);
  }
  $b->bind('<FocusIn>',[sub { select_entry($_[1],$_[2]) },$hlist,$path]);

  my $balloon = $hlist->balloon;
  if ($balloon and $balloonmsg) {
    $balloon->attach($b, -balloonmsg=> $balloonmsg);
  }
  return $f;
}

sub select_entry {
  my ($hlist,$entry)=@_;
  return unless defined $entry;
  $hlist->anchorSet($entry);
  $hlist->selectionClear();
  $hlist->selectionSet($entry);
  $hlist->see($entry);
  $hlist->Callback(-browsecmd =>$entry);
}

# move elements up or down in a list, alt, or sequence
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
  my $data = $hlist->info(data => $path);
  my ($list_no) = $data->{attr_name} =~ /\[(\d+)\]/;
  my $name = $data->{name};
  my $val = {};

  $hlist->select_entry($path);
  $hlist->update;

  # FIXME: we loose orig_value here!!!
  # we should probably copy the entry and its offsprings instead

  $hlist->dump_child($path, $val, 1);
  $val = (values %$val)[0];

  $hlist->_edit_entry(FORCE_CLEAR);
  $hlist->delete('entry',$path);

  my $ptype = $parent ne "" ? $hlist->info(data => $parent)->{type} : undef;
  if ($ptype->get_decl_type == PML_LIST_DECL) {
    $hlist->add_list_member({
      path => $parent,
      type => $mtype,
      data => $val,
      name => $list_no,
      entry_opts => [($where>0 ? '-after' : '-before'), $other ]
     });
  } else {
    $hlist->add_sequence_member({
      path => $parent,
      type => $mtype,
      data => Treex::PML::Seq::Element->new($name,$val),
      name => $list_no,
      entry_opts => [($where>0 ? '-after' : '-before'), $other ]
     });
  }
  $hlist->select_entry($path);
}

sub toggle_structure {
  my ($hlist,$path)=@_;
  my $data = $hlist->info(data => $path);
  my @children = $hlist->info(children => $path);
  if (@children == 0) {
    # create data
    my $type = $data->{type};
    $hlist->add_members({
      path => $path ne "" ? $path."/" : $path,
      type => $type,
      data => {},
     });
  } else {
    my $answer = $hlist->QuestionQuery(
      -label => "Do you really want to delete the structure '$path'?\n".
	"(All values in this structure will be lost!)",
      -bitmap=> 'question',
      -title => "Delete structure?",
      -buttons => ['Delete', 'Cancel']);
    if ($answer eq 'Delete') {
      $hlist->_edit_entry(FORCE_CLEAR);
      foreach (@children) {
	$hlist->delete('entry',$_);
      }
      $hlist->select_entry($path);
    }
  }
}

# create a new list member
sub add_to_list {
  my ($hlist,$path)=@_;
  my $data = $hlist->info(data => $path);
  $data->{list_no}++;
  my $new = $hlist->add_list_member({
		 path => $path,
		 type => $data->{compressed_type} || $data->{type},
		 name => $data->{list_no},
		 allow_empty => 1,
		 entry_opts => [-at => 0],
		});
  if ($hlist->info(exists=>$new)) {
    my @ch = ($new);
    while (@ch) {
      $new = $ch[0];
      $hlist->see($ch[-1]);
      @ch = $hlist->info(children=>$new);
    }
  }
  $hlist->select_entry($new);
  $hlist->configure(-height => 0);
}

# create a new sequence element
sub add_to_sequence {
  my ($hlist,$path,$name)=@_;
  my $data = $hlist->info(data => $path);
  $data->{list_no}++;
  my $new = $hlist->add_sequence_member({
    path =>$path,
    type => $data->{compressed_type} || $data->{type},
    data => Treex::PML::Seq::Element->new($name,undef),
    name => $data->{list_no},
      allow_empty => 1,
    entry_opts => [-at => 0]
   });
  if ($data->{singleton}) {
    my ($b) = grep {ref($_) eq 'Tk::Menubutton'} map { ref($_) eq 'Tk::Frame' ? ($_->children) : ($_) }
      $hlist->itemCget($path,2,'-widget')->children;
    if ($b) {
      $b->configure(-state => 'disabled');
    }
  }
  if ($hlist->info(exists=>$new)) {
    my @ch = ($new);
    while (@ch) {
      $new = $ch[0];
      $hlist->see($ch[-1]);
      @ch = $hlist->info(children=>$new);
    }
  }
  $hlist->select_entry($new);
  $hlist->configure(-height => 0);
}

# create a new alt member
sub add_to_alt {
  my ($hlist,$path)=@_;
  my $data = $hlist->info(data => $path);
  if (!$data->{compressed_type}) {
    #  simply add new item
    $data->{alt_no}++;
    my $new = $hlist->add_alt_member({
      path => $path,
      allow_empty => 1,
      type => $data->{type},
      name => $data->{alt_no}
     });
    if ($hlist->info(exists=>$new)) {
      my @ch = ($new);
      while (@ch) {
	$new = $ch[0];
	$hlist->see($ch[-1]);
	@ch = $hlist->info(children=>$new);
      }
    }
    $hlist->select_entry($new);
  } else {
    my $val = Treex::PML::Factory->createAlt();
    $hlist->dump_child($path, $val, 1);
#    $val->add('');
    my $parent = $hlist->info(parent => $path);
    my $next = $hlist->next_sibling($path);
    $hlist->_edit_entry(FORCE_CLEAR);
    $hlist->delete('entry',$path);
    my $new_path =
      $hlist->add_member({
	  path => $parent ne '' ? $parent.'/' : '',
	  type => $data->{compressed_type},
	  data => $val,
	  name => $data->{attr_name},
	  allow_empty => 1,
	  entry_opts => $next ? [-before => $next] : undef
	});
    add_to_alt($hlist,$new_path);
 #   my @ch = $hlist->info(children => $new_path);
 #   $hlist->select_entry($ch[-1]);
  }
}

sub remove_alt_member {
  my ($hlist,$path)=@_;
  my $parent = $hlist->info(parent => $path);
  $hlist->_edit_entry(FORCE_CLEAR);
  $hlist->delete('entry',$path);
  $path = $parent;
  if ($hlist->info(children => $path) == 0) {
    # no altrenative left -> replace with the usual type
    my $data = $hlist->info(data => $path);
    my $next = $hlist->next_sibling($path);
    $parent = $hlist->info(parent => $path);
    $hlist->delete('entry',$path);
    my $new_path = $hlist->add_member({
      path => $parent ne "" ? $parent.'/' : '',
      type => $data->{member},
      name => $data->{attr_name},
      allow_empty => 1,
      entry_opts => $next ? [-before => $next] : undef
     });
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
    $hlist->add_list_member({
      path => $parent,
      type => ($pdata->{compressed_type} || $pdata->{type}),
      name => $pdata->{list_no},
      entry_opts => [-after => $path]
     });
  $hlist->select_entry($new);
  $hlist->configure(-height => 0);
}

sub new_sequence_member {
  my ($hlist,$path,$name)=@_;
  my $parent = $hlist->info(parent => $path);
  my $pdata = $hlist->info(data => $parent);
  $pdata->{list_no}++;
  my $new =
    $hlist->add_sequence_member({
      path => $parent,
      type => ($pdata->{compresed_type} || $pdata->{type}),
      data =>Treex::PML::Seq::Element->new($name,undef),
      name => $pdata->{list_no},
      entry_opts => [-after => $path],
      allow_empty => 1,
     });
  $hlist->select_entry($new);
  $hlist->configure(-height => 0);
}

# remove from list
sub remove_list_member {
  my ($hlist,$path)=@_;
  my $next = $hlist->info(next => $path);
  if ($next) {
    $hlist->select_entry($next);
  } else {
    $hlist->select_entry($hlist->info(prev => $path));
  }
  $hlist->_edit_entry(FORCE_CLEAR);
  $hlist->delete('entry',$path);
}

# remove from sequence
sub remove_sequence_member {
  my ($hlist,$path)=@_;
  my $seq_path = $hlist->info(parent=>$path);
  remove_list_member($hlist,$path);
  my $data = $hlist->info(data=>$seq_path);
  if ($data->{singleton}) {
    my ($b) = grep {ref($_) eq 'Tk::Menubutton'} map { ref($_) eq 'Tk::Frame' ? ($_->children) : ($_) }
      $hlist->itemCget($seq_path,2,'-widget')->children;
    if ($b) {
      $b->configure(-state => ($hlist->info(children => $seq_path)<1 ? 'normal' : 'disabled'));
    }
  }
}

# create mini-buttons in the 3rd column
# that add, delete, insert, reorder elements and members
sub add_buttons {
  my ($hlist,$path)=@_;
  my $parent = $hlist->info(parent => $path);
  my $mtype = $hlist->info(data => $path)->{type};
  my $ptype = $parent ne "" ? $hlist->info(data => $parent)->{type} : undef;

  my $mdecl_type = ref($mtype) ? $mtype->get_decl_type : undef;
  my $pdecl_type = ref($ptype) ? $ptype->get_decl_type : undef;

  return unless (
    (ref($mtype) &&
     ($mtype->get_decl_type == PML_LIST_DECL      ||
      $mtype->get_decl_type == PML_ALT_DECL       ||
      $mtype->get_decl_type == PML_SEQUENCE_DECL  ||
      $mtype->get_decl_type == PML_STRUCTURE_DECL ||
      $mtype->get_decl_type == PML_CONTAINER_DECL))
      or
    (ref($ptype) &&
     ($ptype->get_decl_type == PML_LIST_DECL      ||
      $ptype->get_decl_type == PML_ALT_DECL       ||
      $ptype->get_decl_type == PML_SEQUENCE_DECL)));

  return if ref($mtype) and $mtype->get_role =~ m{^\#(?:CHILDNODES|TREES)$} and !$hlist->get_option('allow_trees');
  if ($hlist->cget('-columns')>2) {
    my $f = $hlist->Frame(
      -background => $hlist->cget('-background')
     );
    $hlist->itemCreate($path,2,
		       -itemtype => 'window',
		       -widget => $f,
		       -style => $hlist->{userdata}{itemstyles}{buttons}
		      );
    my $ctype = $hlist->info(data => $path)->{compressed_type};
    for my $decl (grep ref, $mtype, $ctype) {
      my $decl_type = $decl->get_decl_type;
      if ($decl_type == PML_LIST_DECL) {
	# add list buttons
	$hlist->mini_button($f,'plus',$path,
			    {
			      -background => $hlist->{colors}{list},
			      -command => [$hlist,'add_to_list',$path],
			      -balloonmsg => 'Create a new list item (Ctrl-+)',
			    }
			   )->Tk::pack('configure');
      } elsif ($decl_type == PML_SEQUENCE_DECL) {
	  # add sequence buttons
	  my @elements = $hlist->get_custom_attr_ordering([$decl->get_element_names],$path);
	  $hlist->mini_button($f,'plus',$path,
			      {
				-background => $hlist->{colors}{sequence},
				-balloonmsg => 'Create a new sequence element (Ctrl-+)',
				-state =>
				  ($hlist->info(data => $path)->{singleton} ?
				     ($hlist->info(children => $path)<1 ? 'normal' : 'disabled')
				       : 'normal'),
				(@elements == 1 )
				  ?
				    ( -command => [$hlist,'add_to_sequence',$path,$elements[0]] )
				      :
					(
					  -menu => {
					    -entries => [ map { ['command', -label => $_,
								 -command => [$hlist,'add_to_sequence',$path,$_],
								] }
							    @elements
							   ],
					  }
					 )
				       }
			     )->Tk::pack('configure');
      } elsif ($decl_type == PML_ALT_DECL) {
	# add alt buttons
	$hlist->mini_button($f,'star',$path,
			    {
			      -background => ($decl->is_flat ? $hlist->{colors}{alt_flat} : $hlist->{colors}{alt}),
			      -balloonmsg => 'Add an alternative (Ctrl-*)',
			      -command => [$hlist,'add_to_alt',$path],
			    }
			   )->Tk::pack('configure',-side => 'top');
      } elsif ($decl_type == PML_STRUCTURE_DECL or
		 ($decl_type == PML_CONTAINER_DECL and ($decl->has_attributes or defined($decl->get_content_decl)))) {
	# add structure button
	$hlist->mini_button($f,'hash',$path,
			    {
			      -background => $hlist->{colors}{struct},
			      -balloonmsg => 'Create/delete structure content (Ctrl-#)',
			      -command => [$hlist,'toggle_structure',$path],
			    }
			   )->Tk::pack('configure',-side => 'top');
      }
    }
    if ($parent ne "") {
      $ptype = (($hlist->info(data => $parent)->{compressed_type}) || $ptype);
    }
    my $ptype_is = $ptype ? $ptype->get_decl_type : undef;
    if ($ptype_is == PML_LIST_DECL) {
      # add list member buttons
      my ($f1,$f2);
      if ($ptype->is_ordered) {
	$f2 = $f->Frame;
	$f2->Tk::pack('configure',qw(-side left));
	$f1 = $f->Frame;
	$f1->Tk::pack('configure',qw(-side right));
      } else {
	$f1 = $f->Frame;
	$f1->Tk::pack('configure',qw(-side top));
      }
      if ($f1) {
	if ($ptype->is_ordered) {
	  $hlist->mini_button($f1,'plus',$path,
			      {
				-background => $hlist->{colors}{list},
				-balloonmsg => 'Insert list item (Ctrl-+)',
				-command =>
				  [$hlist,'new_list_member',$path],
			      }
			     )->Tk::pack('configure',qw(-side top));
	}
	$hlist->mini_button($f1,'minus',$path,
			    {
			      -background => $hlist->{colors}{list},
			      -balloonmsg => 'Remove list item (Ctrl-minus)',
			      -command =>
				[$hlist,'remove_list_member',$path],
			    }
			   )->Tk::pack('configure',qw(-side top));
      }
      if ($f2) {
	$hlist->mini_button($f2,'up',$path,
			    {
			      -background => $hlist->{colors}{list},
			      -balloonmsg => 'Move item up (Ctrl-Up)',
			      -command => [$hlist,'up_or_down',-1,$path ],
			    }
			   )->Tk::pack('configure',qw(-side top));
	$hlist->mini_button($f2,'down',$path,
			    {
			      -background => $hlist->{colors}{list},
			      -balloonmsg => 'Move item down (Ctrl-Down)',
			      -command => [$hlist,'up_or_down',1,$path],
			    }
			   )->Tk::pack('configure',qw(-side top));
      }
    } elsif ($ptype_is == PML_SEQUENCE_DECL) {
      # add sequence member buttons
      my ($f1,$f2);
      $f2 = $f->Frame;
      $f2->Tk::pack('configure',qw(-side left));
      my $singleton = $hlist->info(data => $parent)->{singleton};
      if ($singleton) {
	$f1=$f2;
      } else {
	$f1 = $f->Frame;
	$f1->Tk::pack('configure',qw(-side right));
	$hlist->mini_button($f1,'plus',$path,
			    {
			      -background => $hlist->{colors}{sequence},
			      -balloonmsg => 'Insert element (Ctrl-+)',
			      -menu => {
				-entries => [ map { ['command', -label => $_,
						     -command => [$hlist,'new_sequence_member',$path,$_],
						  ] }
						$hlist->get_custom_attr_ordering([$ptype->get_element_names],$path),
					   ],
			      }
			     }
			   )->Tk::pack('configure',qw(-side top));
      }
      $hlist->mini_button($f1,'minus',$path,
			  {
			    -background => $hlist->{colors}{sequence},
			    -balloonmsg => 'Remove element (Ctrl-minus)',
			    -command =>
			      [$hlist,'remove_sequence_member',$path],
			  }
			 )->Tk::pack('configure',qw(-side top));
      unless ($singleton) {
	$hlist->mini_button($f2,'up',$path,
			    {
			      -background => $hlist->{colors}{sequence},
			      -balloonmsg => 'Move element up (Ctrl-Up)',
			      -command => [$hlist,'up_or_down',-1,$path ],
			    }
			   )->Tk::pack('configure',qw(-side top));
	$hlist->mini_button($f2,'down',$path,
			    {
			      -background => $hlist->{colors}{sequence},
			    -balloonmsg => 'Move element down (Ctrl-Down)',
			      -command => [$hlist,'up_or_down',1,$path],
			    }
			   )->Tk::pack('configure',qw(-side top));
      }
    } elsif ($ptype_is == PML_ALT_DECL) {
      # remove alt member button
      $hlist->mini_button($f,'cross',$path,
			  {
			    -background => ($ptype->is_flat ? $hlist->{colors}{alt_flat} : $hlist->{colors}{alt}),
			    -balloonmsg => 'Remove alternative (Ctrl-x)',
			    -command => [$hlist,'remove_alt_member',$path],
			  }
			 )->Tk::pack('configure',-side => 'top');
    }
  }
}

# create an alt item
sub add_alt_member {
  die "Usage: \$edit->add_alt_member({arg => value,...})" if @_ != 2;
  my ($hlist,$args)=@_;
  return $hlist->add_member({
    %$args,
    path => $args->{path}."/",
    name => '['.$args->{name}.']',
  });
}

# create a list item
sub add_list_member {
  my $self=shift;
  die "Usage: \$edit->add_list_member({arg => value,...})" if @_ != 1;
  $self->add_alt_member(@_);
}

# create a sequence item
sub add_sequence_member {
  die "Usage: \$edit->add_sequence__member({arg => value,...})" if @_ != 2;
  my ($hlist,$args)=@_;
  my $name = $args->{data}->name;
  return $hlist->add_member(
    {
      %$args,
      path => $args->{path}."/",
      type => $name eq '#TEXT' ? $name : $args->{type}->get_element_by_name($name),
      name => '['.$args->{name}.']'.$name,
      require => 1,
      data =>  $args->{data}->value,
      label => $name,
     });
}

# get to next/prev sibling
sub next_sibling {
  my ($hlist,$path,$where)=@_;
  $where ||= 'next';
  return if !$hlist->info(exists => $path);
  my $next = $hlist->info($where => $path);
  while ($next ne "" and
	   $hlist->info(parent => $next) ne
	   $hlist->info(parent => $path)) {
    $next = $hlist->info($where => $next);
  }
  return if
    $next ne "" and
      $hlist->info(parent => $next) ne
	$hlist->info(parent => $path);
  return $next;
}

# add a new item (and child items) to the Tk::Tree based on the data type and options
sub add_member {
  die "Usage: \$edit->add_member({arg => value,...})" if @_ != 2;
  my ($hlist,$args)=@_;

  my ($base_path,$member,$attr_val,$attr_name,$allow_empty,$entry_opts,$required,$label)=
    @$args{qw(path type data name allow_empty entry_opts required label)};
  if ($hlist->{userdata}{hide_empty}) {
    if (!defined($attr_val) or !ref($attr_val) and !length($attr_val)) {
      return;
    }
  }
  # we need longest attr_val for determining column width
  if(length($attr_val) > $hlist->{userdata}{item_max_length} && !($attr_val =~ /HASH/) && !($attr_val =~ /ARRAY/)){
  	$hlist->{userdata}{item_max_length_text} = $attr_val;
  	$hlist->{userdata}{item_max_length} = length($attr_val);
  }

  my ($mdecl, $mdecl_type);
  $label = $attr_name if (!defined $label || $label eq "");
  if (!ref($member) and $member =~ /^#/) {
    $mdecl = $member;
  } elsif (ref($member)) {
    my $role = $member->get_role;
    return if $role  =~ m/^\#(?:CHILDNODES|TREES)$/ and !$hlist->get_option('allow_trees');
    my $member_type = $member->get_decl_type;
    $required ||= ($member->is_required ? 1 : 0) if
      ($member_type == PML_MEMBER_DECL ||
       $member_type == PML_ATTRIBUTE_DECL);
    $mdecl = ($role eq '#KNIT' and $hlist->get_option('knit_support'))
	? $member->get_type_ref_decl : $member->get_content_decl;
    $mdecl ||= $member;
    $mdecl_type = $mdecl->get_decl_type;
  } else {
    croak("Unknown type object for $attr_name: $member");
  }

  my $path = $base_path.$attr_name;
  my $data = {type => $mdecl,
	      member => $member,
	      attr_name => $attr_name,
	      orig_value => $attr_val,
	      name => $label,
	      # required is 0|1 for struct members
	      # and 1 for all other slots
	      required => defined($required) ? $required : 1,
	      role => (ref($mdecl) ? $mdecl->get_role : undef),
	     };
  $path='/' if $path eq ''; # work around
  $hlist->add($path,-data => $data, $entry_opts ? @$entry_opts : ());
  $hlist->itemCreate($path,0,-itemtype => 'text',
		     -text =>
		       ($label =~ /^\[\d+\]$/) ? '  ' : '  '.$label,
		     -style =>
		       $hlist->{userdata}{itemstyles}{
			 $required ? 'required' : 'default'
		       }
		    );
  my ($hidden,$enabled);
  {
    my $apath = $path; $apath=~s{/\[\d+\]}{}g;
    my $base_path = $hlist->{userdata}{base_path};
    $apath = $base_path.$apath if defined $base_path;
    $hidden = $hlist->do_callback('hide',undef,$apath,$mdecl_type);
    $enabled = $hlist->do_callback('enable',1,$apath,$mdecl_type);
  }
  $data->{dump} = $mdecl_type;
  $data->{enabled} = $enabled;
  $data->{hidden} = $hidden;
  if ( defined $hidden ) { # item will be HIDDEN
    $data->{value} = $attr_val;
    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{text});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $hidden,
		       -style => $hlist->{userdata}{itemstyles}{text});
  } elsif ($member eq '#name' or $member eq '#knit_prefix') {
    $data->{dump} = undef;
    $data->{value} = $attr_val;
    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{text});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $attr_val,
		       -style => $hlist->{userdata}{itemstyles}{text});
  } elsif ($member eq '#TEXT'){
    $data->{dump} = $member;
    $data->{value} = $attr_val;
#    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{cdata});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $attr_val,
		       -style => $hlist->{userdata}{itemstyles}{cdata});
  } elsif ($mdecl_type == PML_CDATA_DECL or
	   $mdecl_type == PML_CHOICE_DECL) {
    $data->{value} = $attr_val;
    my $val = $data->{value};
    my $valid;
    if ($mdecl_type == PML_CDATA_DECL) {
      $valid = (($val ne q{} and $mdecl->validate_object($val))
		  or ($val eq q{} and !$required));
    }
    $val=' ' unless defined $val and length $val;
    my $password_map = $hlist->get_option('password_map');
    my $password_hide;
    if (ref($password_map)) {
      my $p = $path;
      $p =~ s{/\[\d+\]/?}{/}g;
      $val=~s/./*/g if $password_map->{$p}
    }
    my $style_name = ($enabled ? '' : 'disabled_').($mdecl_type == PML_CDATA_DECL ? ($valid ? '' : 'invalid_').'cdata' : 'choice');
    $hlist->itemCreate($path,1,
		       -itemtype => 'text',
		       -text => $val,
		       -style => $hlist->{userdata}{itemstyles}{$style_name},
		      );
  } elsif ($mdecl_type == PML_CONSTANT_DECL) {
    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{constant});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => $mdecl->get_value,
		       -style => $hlist->{userdata}{itemstyles}{constant});
  } elsif ($mdecl_type == PML_STRUCTURE_DECL) {
    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{struct});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => 'Structure',
		       -style => $hlist->{userdata}{itemstyles}{struct});
    if (ref($attr_val)) {
      $hlist->add_members({
	path => $path."/",
	type => $mdecl,
	data => $attr_val,
	knit => $args->{knit},
	allow_empty => 0, # we must not expand all sub-structures for validity(!)
       });
    } elsif ($allow_empty) {
      $hlist->add_members({
	path => $path."/",
	type => $mdecl,
	data => Treex::PML::Factory->createStructure(),
	knit => $args->{knit},
	allow_empty => 0, # we must not expand all sub-structures for validity(!)
       });
    }
   } elsif ($mdecl_type == PML_CONTAINER_DECL) {
    $hlist->entryconfigure($path,-style => $hlist->{userdata}{itemstyles}{struct});
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -text => 'Container',
		       -style => $hlist->{userdata}{itemstyles}{struct});
    if (ref($attr_val)) {
      $hlist->add_members({
	path => $path."/",
	type => $mdecl,
	data => $attr_val,
	knit => $args->{knit},
	allow_empty => 0, # we do not want all sub-structures expanded (!)
       });
    } elsif ($allow_empty) {
      $hlist->add_members({
	path => $path."/",
	type => $mdecl,
	data => Treex::PML::Factory->createContainer(),
	knit => $args->{knit},
	allow_empty => 0, # we do not want all sub-structures expanded (!)
       });
     }
  } elsif ($mdecl_type == PML_LIST_DECL) {
    if ($mdecl->get_role =~ m/^\#(CHILDNODES|TREES)$/ and !$hlist->get_option('allow_trees')) {
      $data->{dump} = undef;
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => $1,
			 -style => $hlist->{userdata}{itemstyles}{list});
    } else {
      my $list_no=0;
      $hlist->itemConfigure($path,0,-style => $hlist->{userdata}{itemstyles}{list});
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text =>
			   $mdecl->is_ordered ?
			     'Ordered list' : 'Unordered list',
			 -style => $hlist->{userdata}{itemstyles}{list});


      if ($attr_val) {
	foreach my $val ($attr_val->values) {
	  $list_no++;
	  $hlist->add_list_member({
	    path => $path,
	    type => $mdecl,
	    data => $val,
	    name => $list_no,
	    knit => $args->{knit},
	   });
	}
      } elsif (!$allow_empty) {
	$list_no++;
	$hlist->add_list_member({
	  path => $path,
	  type => $mdecl,
	  data => $attr_val,
	  name => $list_no,
	  knit => $args->{knit},
	 });
      }
      $data->{list_no}=$list_no;
    }
  } elsif ($mdecl_type == PML_SEQUENCE_DECL) {
    my $list_no=0;
    my $pattern = $mdecl->get_content_pattern;
    $data->{singleton} = (!defined($pattern) or !length($pattern) or $pattern=~/[+*,]/) ? 0 : 1;

    $hlist->itemConfigure($path,0,-style => $hlist->{userdata}{itemstyles}{list});
    if ($mdecl->get_role =~ m/^\#(CHILDNODES|TREES)$/ and !$hlist->get_option('allow_trees')) {
      $data->{dump} = undef;
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 'Sequence of '.$1,
			 -style => $hlist->{userdata}{itemstyles}{sequence});
    } else {
      $hlist->itemCreate($path,1,-itemtype => 'text',
			 -text => 'Sequence',
			 -style => $hlist->{userdata}{itemstyles}{sequence});
      if ($attr_val) {
	foreach my $element ($attr_val->elements) {
	  $list_no++;
	  $hlist->add_sequence_member({path => $path,
				       type => $mdecl,
				       data => $element,
				       name => $list_no});
	}
      }
    }
    $data->{list_no}=$list_no;
  } elsif ($mdecl_type == PML_ALT_DECL) {
    my $alt_no=0;
    my $is_flat = $mdecl->is_flat;
    $hlist->itemConfigure($path,0,-style =>
			    ($is_flat ? $hlist->{userdata}{itemstyles}{alt_flat} : $hlist->{userdata}{itemstyles}{alt}));
    $hlist->itemCreate($path,1,-itemtype => 'text',
		       -style => ($is_flat ?
			   $hlist->{userdata}{itemstyles}{alt_flat} :
			     $hlist->{userdata}{itemstyles}{alt}),
		       -text => $is_flat ?
			   'FS-Alternative' : 'Alternative');
    if (UNIVERSAL::DOES::does($attr_val, 'Treex::PML::Alt')) {
      foreach my $val (@{$attr_val}) {
	$alt_no++;
	$hlist->add_alt_member({
	  path => $path,
	  type => $mdecl,
	  data => $val,
	  name => $alt_no,
	 });
      }
    } elsif (!ref($attr_val) and $is_flat and  $attr_val =~ /\|/) {
      foreach my $val (split /\|/,$attr_val) {
	$alt_no++;
	$hlist->add_alt_member({
	  path => $path,
	  type => $mdecl,
	  data => $val,
	  name => $alt_no
	 });
      }
    } elsif(!$attr_val and $allow_empty) {
      $alt_no++;
      $hlist->add_alt_member({
	path => $path,
	type => $mdecl,
	data => $attr_val,
	name => $alt_no
       });
    } else {
      $hlist->_edit_entry(FORCE_CLEAR);
      $hlist->delete('entry' => $path);
      $path = $hlist->add_member({
	path => $base_path,
	type => $mdecl,
	data => $attr_val,
	name => $attr_name,
	allow_empty => 0,
	entry_opts => $entry_opts
       });
      my $new_data = $hlist->info('data' => $path);
      $new_data->{compressed_type} = $member;
      $new_data->{type} = $mdecl;
      $new_data->{$_} = $data->{$_} for qw(name member text enabled hidden);
    }
    $data->{alt_no}=$alt_no;
  } else {
    warn "Unknown data type: $mdecl - $mdecl_type\n";
  }
  $hlist->add_buttons($path) if $enabled and not defined($hidden);
  $hlist->setmode($path);

  return $path;
}

# add structure/container members to the Tk::Tree
sub add_members {
  die "Usage: \$edit->add_members({arg => value,...})" if @_ != 2;
  my ($hlist,$args)=@_;
  my ($base_path,$type,$node,$allow_empty) = @$args{qw(path type data allow_empty)};
  my $decl_type =  $type->get_decl_type();
  my @members;
  if ($decl_type == PML_STRUCTURE_DECL) {
    @members = $type->get_member_names();
  } elsif ($decl_type == PML_CONTAINER_DECL) {
    @members = $type->get_attribute_names();
  } else {
    croak "Can't call add_members with ".ref($type);
  }
  if (!UNIVERSAL::isa($node,'HASH')) {
    croak "$base_path: $node not a HASH";
    return;
  }
  if ($node->{'#name'} ne '' and !grep { $_ eq '#name' } @members) {
    # FIXME - we should know by other means that there is a #name
    $hlist->add_member({
      path => $base_path,
      type => '#name',
      data => $node->{'#name'},
      name => '#name'
     });
  }
  if ($args->{knit} and $node->{'#knit_prefix'} ne '') {
    $hlist->add_member({
      path => $base_path,
      type => '#knit_prefix',
      data => $node->{'#knit_prefix'},
      name => '#knit_prefix'
     });
  }
  foreach my $member_name ($hlist->get_custom_attr_ordering(\@members,$base_path)) {
    my $member = $type->get_member_by_name($member_name);
    croak "Can't locate member $member_name\n" unless $member;
    my $mdecl = $member->get_content_decl;
    my $knit;
    if ($decl_type == PML_STRUCTURE_DECL) {
      # member is #KNIT PMLREF or a list of #KNIT PMLREFS
      if ($hlist->get_option('knit_support') and ($member->get_role eq '#KNIT'
	  or $mdecl and $mdecl->get_decl_type() == PML_LIST_DECL
	    and $mdecl->get_role eq '#KNIT')) {
	if (exists($node->{$member_name})) {
	  # $member=$mdecl;
	} else {
	  $knit = 1;
	  $member_name=$member->get_knit_name();
	}
      }
    }

    $hlist->add_member({
      path => $base_path,
      type => $member,
      data => ($node ? $node->{$member_name} : undef),
      knit =>$knit,
      name => $member_name,
      allow_empty => $allow_empty});
  }
  if ($decl_type == PML_CONTAINER_DECL and $type->get_content_decl) {
    $hlist->add_member({
      path => $base_path,
      type => $type,
      data => $node->{'#content'},
      name => '#content'
     });
  }
}

sub get_option {
  my ($self,$opt)=@_;
  $self->{userdata}{option}{$opt}
}
sub set_option {
  my ($self,$opt,$val)=@_;
  $self->{userdata}{option}{$opt}=$val;
}

sub get_schema {
  $_[0]->{userdata}{schema}
}
sub schema {
  $_[0]->{userdata}{schema}
}

sub set_schema {
  my ($hlist,$schema)=@_;
  $hlist->{userdata}{schema}=$schema;
}
sub set_base_path {
  my ($hlist,$base_path)=@_;
  $hlist->{userdata}{base_path}=$base_path;
}
sub get_base_path {
  my ($hlist)=@_;
  return $hlist->{userdata}{base_path};
}

sub set_callback {
  my ($hlist,$name,$callback)=@_;
  $hlist->{userdata}{$name.'_callback'}=$callback;
}
sub get_callback {
  my ($hlist,$name)=@_;
  return $hlist->{userdata}{$name.'_callback'};
}
sub do_callback {
  my ($hlist,$name,$default_value,@callback_args)=@_;
  my $cb = $hlist->{userdata}{$name.'_callback'};
  if (ref($cb) eq 'CODE') {
    return $cb->(@callback_args)
  } elsif (ref($cb) eq 'ARRAY') {
    my ($func,@user_args) = @$cb;
    return $func->(@user_args,@callback_args);
  } else {
    return $default_value;
  }
}

sub get_custom_attr_ordering {
  my ($hlist,$list,$path) = @_;
  return @$list if (scalar(@$list)<2 or $hlist->get_option('no_attribute_sort'));
  my @list = @$list;
  if ($hlist->do_callback('attribute_sort',0,\@list,$path)) {
    return @list;
  } else {
    return sort @list;
  }
}

sub get_custom_value_ordering {
  my ($hlist,$list,$path) = @_;
  return @$list if (scalar(@$list)<2 or $hlist->get_option('no_value_sort'));
  my @list = @$list;
  if ($hlist->do_callback('value_sort',0,\@list,$path)) {
    return @list;
  } else {
    return sort @list;
  }
}


# Set the value column size to max
sub adjust_size {
  my ($w,$manual)=@_;
#  $w->parent->update;
  $w->update;

  my $new_col1_width = $w->width - 4 - $w->columnWidth(0) - $w->columnWidth($w->cget('-columns') - 1);

  # we need to find the longest of displayed texts 
  # and adjust the width of the column accordingly
  my $default_style = $w->{'userdata'}{'itemstyles'}{'default'};
  my $font = $default_style->cget(-font);
  my $longest_attr_val = $w->{userdata}{item_max_length_text};
  my $hor_space = $w->fontMeasure($font, $longest_attr_val) + 10;

  # does the user want to wrap lines in side panel and editing window?
  if($w->{userdata}{option}{side_panel_wrap} == 1){
    my @itemstyles_to_change=qw(required default list sequence struct constant choice cdata invalid_cdata disabled_choice disabled_cdata disabled_invalid_cdata);
    my $font;
    foreach my $style_name (@itemstyles_to_change) {
      my $style = $w->{'userdata'}{'itemstyles'}{$style_name};
      $style->configure(-wraplength => $new_col1_width - 5); # we wrap some more pixels so the last character is not cut-off
      # this wrapping works in a strange way, but -5 pixels seems to work usually fine...
    }
    $w->columnWidth(1,$new_col1_width);
  } else {
    if($w->width > $w->columnWidth(0) + $hor_space){
        $w->columnWidth(1,$new_col1_width);
    } else {
        $w->columnWidth(1,$hor_space);
    }
  }
  $w->update;
  $w->{in_resize_callback} = 0;
}

sub _store_data {
  my ($ref,$name,$value,$preserve_empty)=@_;
  if (UNIVERSAL::DOES::does($ref,'Treex::PML::List') or UNIVERSAL::DOES::does($ref,'Treex::PML::Alt')) {
    $ref->push($value) if $preserve_empty or defined $value;
  } elsif (UNIVERSAL::DOES::does($ref,'Treex::PML::Seq')) {
    $ref->push_element($name, $value);
  } else {
    if ($preserve_empty or defined $value) {
      $ref->{$name} = $value;
    } else {
      delete $ref->{$name};
    }
  }
}

# Get value of entry at a given path
sub get_current_value {
  my ($hlist,$path)=@_;
  my $ref={};
  $hlist->dump_child($path,$ref);
  $path =~ s{.*/}{};
  return $ref->{$path};
}

# Dump the content of a subtree in the the editor to a given data structure
sub dump_child {
  my ($hlist, $path, $ref, $preserve_empty,$mtype, $use_orig_value)=@_;
  my $data = $hlist->info(data => $path);
  my $dump = $data->{dump};

  $mtype = $data->{type} unless defined $mtype;
  if (!defined($dump)) {
    # nothing to do
  } elsif (exists $data->{value}) {
    _store_data($ref,$data->{name},$data->{value},$preserve_empty);
  } elsif ($dump == PML_CDATA_DECL or $dump == PML_CHOICE_DECL) {
    _store_data($ref,$data->{name},$data->{value},$preserve_empty);
  } elsif ($dump == PML_CONSTANT_DECL) {
    _store_data($ref,$data->{name},$mtype->get_value,1);
  } elsif ($dump == PML_LIST_DECL) {
    my $new_ref = $use_orig_value && UNIVERSAL::DOES::does($data->{orig_value},'Treex::PML::List')
	 ? $data->{orig_value}->empty : Treex::PML::Factory->createList();
    _store_data($ref,$data->{name},$new_ref,1);
    for my $child ($hlist->info(children => $path)) {
      $hlist->dump_child($child,$new_ref,$preserve_empty,undef,$use_orig_value);
    }
  } elsif ($dump == PML_SEQUENCE_DECL) {
    my $new_ref = $use_orig_value && UNIVERSAL::DOES::does($data->{orig_value},'Treex::PML::Seq')
      ? $data->{orig_value}->empty : Treex::PML::Factory->createSeq();
    _store_data($ref,$data->{name},$new_ref,1);
    for my $child ($hlist->info(children => $path)) {
      $hlist->dump_child($child,$new_ref,$preserve_empty,undef,$use_orig_value);
    }
  } elsif ($dump == PML_ALT_DECL) {
    my $new_ref = $use_orig_value && UNIVERSAL::DOES::does($data->{orig_value},'Treex::PML::Alt')
      ? $data->{orig_value}->empty : Treex::PML::Factory->createAlt();
    if ($data->{compressed_type}) {
      $hlist->dump_child($path,$new_ref,
			 $preserve_empty,$data->{compressed_type},$use_orig_value);
      die "error: expected only single item in a compressed alt\n"
	unless @$new_ref<2;
      $new_ref = $new_ref->[0];
    } else {
      for my $child ($hlist->info(children => $path)) {
	$hlist->dump_child($child,$new_ref,$preserve_empty,undef,$use_orig_value);
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
    if (ref($new_ref) and $mtype->is_flat) {
      _store_data($ref,$data->{name},join('|',@$new_ref),1);
    } else {
      _store_data($ref,$data->{name},$new_ref,1);
    }
  } elsif ($dump == PML_STRUCTURE_DECL or $dump == PML_CONTAINER_DECL) {
    my $new_ref = $dump == PML_STRUCTURE_DECL ?
      ($use_orig_value && UNIVERSAL::DOES::does($data->{orig_value},'Treex::PML::Struct')
	? $data->{orig_value} :
	  ($data->{role} eq '#NODE' ?
	     Treex::PML::Factory->createTypedNode($data->{type}) : Treex::PML::Factory->createStructure()))
      :
      ($use_orig_value && UNIVERSAL::DOES::does($data->{orig_value},'Treex::PML::Container')
	? $data->{orig_value} :
	  ($data->{role} eq '#NODE' ?
	     Treex::PML::Factory->createTypedNode($data->{type}) : Treex::PML::Factory->createContainer()));

    # fixme: probably we want to clear the Struct/Container ???
    my @children = $hlist->info(children => $path);
    if (UNIVERSAL::DOES::does($ref, 'Treex::PML::List')) {
      $ref->push($new_ref) if @children;
    } elsif (UNIVERSAL::DOES::does($ref, 'Treex::PML::Alt')) {
      $ref->add($new_ref) if @children;
    } elsif (UNIVERSAL::DOES::does($ref,'Treex::PML::Seq')) {
      if (@children or ($dump == PML_CONTAINER_DECL and !defined($mtype->get_content_decl))) {
	$ref->push_element($data->{name}, $new_ref);
      }
    } else {
      if (@children) {
	if (ref($ref->{$data->{name}})) {
	  $new_ref = $ref->{$data->{name}};
	} else {
	  $ref->{$data->{name}} = $new_ref;
	}
      } else {
	delete $ref->{$data->{name}};
      }
    }
    for my $child (@children) {
      $hlist->dump_child($child,$new_ref,$preserve_empty,undef,$use_orig_value);
    }
  } else {
    warn "Can't dump $path as data type no. $dump. Type ",Dumper($mtype),"\n";
  }
}

# dump the content of the editor to the original object
sub apply {
  my ($self,$preserve_empty)=@_;
  return $self->dump_to_node(undef,$preserve_empty,1);
}

# see below
sub apply_to_object {
  my $self = shift;
  return $self->dump_to_node(@_);
}

# dump the content of the editor to a given original object
sub dump_to_node {
  my ($hlist,$node,$preserve_empty,$use_orig_value)=@_;
  if (!$node and $use_orig_value) {
    my $data = $hlist->info(data=>'');
    $node = $data->{orig_value} if $data;
    return unless $node;
  }
  for my $child ($hlist->info(children => '')) {
    $hlist->dump_child($child,$node,$preserve_empty,undef,$use_orig_value);
  }
  return $node;
}

# when an editable item is selected create the corresponding widget (Entry or ComboBox)
sub focus_entry {
  my ($hlist)=@_;
  my $path = $hlist->info('anchor');
  unless ($hlist->info('exists',$path)) {
    Tk->break;
  }
  if ($hlist->itemExists($path,1)) {
    my $mode = $hlist->getmode($path);
    if ($mode ne 'none') {
      $hlist->$mode($path);
    } else {
      unless ($hlist->itemCget($path,1,'-itemtype') eq 'window') {
	Tk->break;
      }
      my $w = $hlist->itemCget($path,1,'-widget');
      while (ref($w) eq 'Tk::Frame') {
	($w) = $w->children;
      }
      if ($w) {
	$w->focus;
	if ($w->isa('Tk::JComboBox_0_02')) {
	  $w->showPopup unless $w->popupIsVisible;
	} elsif ($w->isa('Tk::Entry')) {
	  $w->icursor('end');
	}
      }
    }
  }
  Tk->break;
}

# handle clipboard events on a Tk::Tree item
sub entry_clipboard {
  my ($hlist,$action)=@_;
  my $path = $hlist->info('anchor');
  return unless $hlist->info('exists',$path);
  my $copy;
  if ($hlist->itemExists($path,1)) {
    my $itemtype = $hlist->itemCget($path,1,'-itemtype');
    if ($itemtype =~ /text/) {
      if ($action eq 'Copy' or $action eq 'Cut') {
	$copy = $hlist->itemCget($path,1,'-text');
	$hlist->clipboardClear;
	$hlist->clipboardAppend('--',$copy);
      }
    } else {
      my $w = $hlist->get_entry_widget($path);
      if ($w) {
	$w = $w->Subwidget('ED_Entry') if $w->isa('Tk::JComboBox_0_02');
	if ($action eq 'Copy') {
	  $w->clipboardClear;
	  $w->clipboardAppend('--',$w->get);
	} elsif ($action eq 'Cut') {
	  $w->clipboardClear;
	  $w->clipboardAppend('--',$w->get);
	  $w->delete(0,'end') if $action eq 'Cut';
	} elsif ($action eq 'Paste') {
	  my $value = $w->clipboard('get');
	  if (defined($value) and length($value)) {
	    $w->delete(0,'end');
	    $w->insert(0,$value);
	  }
	}
      }
    }
  }
}

# get the widget on a given Tk::Tree item
sub get_entry_widget {
  my ($hlist, $path) = @_;
  return unless $hlist->itemCget($path,1,'-itemtype') eq 'window';
  my $w = $hlist->itemCget($path,1,'-widget');
  while (ref($w) eq 'Tk::Frame') {
    ($w) = $w->children;
  }
  return $w;
}

# insert text into an editing widget of the currently focused Tk::List item
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
      my $w = $hlist->get_entry_widget($path);
      if ($w) {
	if ($w->isa('Tk::JComboBox_0_02')) {
	  #$w->setSelected( $w->getSelectedValue );
	  $w->{index_on_focus} = $w->CurSelection;
	  #$w->see($w->{index_on_focus});
	  #what = undef if $what eq ' ';
	  $w->showPopup unless $w->popupIsVisible;
	  $w = $w->Subwidget('ED_Entry');
	}
	$w->selectionClear;
	$w->selectionRange(0,'end');
	$w->focus;
	if (defined $what and $what =~ /[^[:cntrl:]]/) { # and $w->can('Insert')) {
	  eval { $w->Insert($what); };
	}
      }
    }
  }
  Tk->break;
}

# "fix" behavior of JComboBox
*Tk::JComboBox_0_02::EntryUpDown = sub {
  my ($cw, $modifier) = @_;
  # return unless $cw->cget('-validate') =~ /cs-match|match/;
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
    my $text = $lb->get('active');
    $e->insert(0,$text) if defined $text and length $text;
  }
  Tk->break;
};

# "fix" behavior of JComboBox
*Tk::JComboBox_0_02::EntryEnter = sub {
  my $cw = shift;
  if ($cw->cget('-validate') =~ /cs-match|match/) {
    my $lb = $cw->Subwidget('Listbox');
    my $index = $lb->curselection;
    unless (defined($index)) {
      my $str =  $cw->Subwidget('ED_Entry')->get;
      $index = $cw->getItemIndex($str);
    }
    $index = 0 unless defined($index);
    $cw->setSelectedIndex($index);
  }
  $cw->hidePopup;
};


sub FocusChildren {
  return ();
}

sub focusNext {
  shift->MoveFocus('next');
}

sub focusPrev {
  shift->MoveFocus('prev');
}

sub MoveFocus {
  my ($w,$where) = @_;
  my $anchor = $w->info('anchor');
  my $entry = defined($anchor)  ? $w->info($where => $anchor) : undef;
  if ($entry) {
    $w->focus;
    $w->select_entry($entry);
  } else {
    if (defined $anchor) {
      $w->anchorClear;
      my $call = "Tk::focus".ucfirst($where);
      $w->$call() ;
    } else {
      my ($first) = $where eq 'next' ? $w->info('children') : reverse $w->info('children');
      $w->select_entry($first);
    }
  }
  Tk->break;
}

# cleanup
sub clear {
  my $hlist = shift;
  $hlist->balloon->Tk::Balloon::destroy if $hlist->balloon;
}

# forget the currently edited object
sub empty {
  my ($self)=@_;
  $self->_edit_entry(FORCE_CLEAR);
  $self->delete('all');
}

# create a search field associated with the editor on a given parent widget
sub add_search_field {
  my ($self, $parent)=@_;
  my $sf = $parent->Frame;
  $sf->Label(-underline => 0,
	     -text => 'Search name:')->Tk::pack('configure',qw(-side left));
  my $qs = $sf->Entry(
    -background => 'white',
    -textvariable=>\$self->{userdata}{current_path},
    -validate => 'key',
    -validatecommand =>
      [sub {
	 my ($tree,$value)=@_;
	 if ($tree->info(exists => $value)) {
	   $tree->select_entry($value);
	   return $value;
	 } elsif ($value =~ /^(.*)\/([^\/]*)/) {
	   my ($p,$v)=($1,$2);
	   if ($tree->info(exists => $p)) {
	     foreach ($tree->info('children'=>$p)) {
	       if (/^\Q$p\E\/\Q$v\E/) {
		 $tree->select_entry($_);
		 return $_;
	       }
	     }
	   }
	 } else {
	   foreach ($tree->info('children')) {
	     if (/^\Q$value\E/) {
	       $tree->select_entry($_);
	       return $_;
	     }
	   }
	   }
	 return;
	 },$self]
     );
  $qs->Tk::pack('configure',qw(-side right -expand 1 -fill x));
  $parent->bind('all','<Alt-s>', [$qs,'focus']);
  $qs->bind('<FocusIn>',sub{
    my $w = shift;
    $w->selectionClear;
    $w->selectionRange(0,'end');
    $w->configure(-textvariable => undef);
  });
  $qs->bind('<FocusOut>',sub{
    my $w = shift;
    $w->selectionClear;
    $w->configure(-textvariable => \$self->{userdata}{current_path});
  });
  $qs->bind('<Return>',[$self,'focus_entry']);
  $qs->bind('<Escape>',[sub {
			  my $w=$_[1];
			  $w->focus;
			  Tk->break; },$self]);
  return $sf;
}

# create a full-featured editor dialog box
sub Tk::Widget::TrEdNodeEditDlg {
  my ($w,$opts) = @_;

  use Treex::PML::Schema;
  use Treex::PML::Instance;
  use Tk::BindButtons;
  use Tk::DialogReturn;

  croak "TrEdNodeEditDlg: the 1st (and only) argument must be a hash reference"
    unless ref $opts eq 'HASH';
  my $mw = $opts->{mainwindow} || $w->toplevel;
  croak "Missing or invalid 'mainwindow' option" unless ref $mw;
  my $base_type = $opts->{type};
#  croak "Missing or invalid 'type' option" unless ref $base_type;
  my $obj = $opts->{object};
#  croak "Missing or invalid 'object' option" unless ref $obj;
  my $attr_path = $opts->{path};

  my $ok_button = $opts->{ok_button};
  $ok_button = 'OK' unless defined($ok_button) and length($ok_button);

  $mw->Busy(-recurse=>1);
  my $d = $opts->{dialog};
  if (!$d) {
    $d = $mw->DialogBox(
      -buttons=> $opts->{buttons} || [$ok_button, 'Cancel'],
     );
  }
  if (ref $opts->{buttons_configure}) {
    while (my ($bk,$bc)=each %{$opts->{buttons_configure}}) {
      my $but = $d->Subwidget('B_'.$bk);
      if ($but) {
	if (ref($bc) eq 'ARRAY') {
	  $but->configure(@$bc);
	} elsif (ref($bc) eq 'HASH') {
	  $but->configure(%$bc)
	} elsif (ref($bc) eq 'CODE') {
	  $bc->($but);
	}
      }
    }
  }
  unless ($opts->{dialog}) {
    $d->protocol('WM_DELETE_WINDOW' =>
		   [sub { shift->{selected_button}='Cancel'; },$d]);
    $d->maxsize(0,int(0.9*$d->screenheight));
  }
  my $edit = $d->Scrolled('TrEdNodeEdit',
			  -width=> 70,
			  -height => 0,
			  -indicator => 1,
			  -scrollbars => 'osoe',
			  %{$opts->{TrEdNodeEdit}},
			 );
  eval { $d->configure(-focus=>$edit) };
  # can't recall what are these supposed to do
  #  $edit->Tk::bind('Freeze','<Map>',undef);
  #  $edit->bindtags([grep { $_ ne 'Freeze'} $edit->bindtags]);
  $edit->set_option(knit_support=>$opts->{knit_support});
  $edit->set_option(no_sort=>$opts->{no_sort});
  $edit->set_option(no_value_sort=>$opts->{no_value_sort});
  $edit->set_option(password_map=>$opts->{password_map});
  $edit->set_option(allow_trees=>$opts->{allow_trees});
  $edit->set_option(side_panel_wrap=>$opts->{side_panel_wrap});

  $edit->set_callback( 'attribute_sort', $opts->{attribute_sort_callback} );
  $edit->set_callback( 'value_sort', $opts->{value_sort_callback} );
  $edit->set_callback( 'enable', $opts->{enable_callback} );
  $edit->set_callback( 'hide', $opts->{hide_callback} );
  $edit->set_callback( 'choices', $opts->{choices_callback} );
  $edit->set_callback( 'validate', $opts->{validate_callback} );
  my ($attr_name,$data_type,$is_required) =
    $edit->set_data({
      type => $base_type,
      path => $attr_path,
      object => $obj,
      allow_empty => $opts->{allow_empty},
      hide_empty => $opts->{hide_empty},
      object_name => $opts->{object_name},
    });
  unless ($opts->{dialog}) {
    my $dlg_title = $opts->{title} || ("Edit ".$data_type->get_decl_path.(length $attr_path ? '/'.$attr_path : ''));
    $d->configure(-title=> $dlg_title);
  }
  if ($opts->{search_field} or
      !exists($opts->{search_field}) and !length($attr_path)) {
    $edit->add_search_field($d)->Tk::pack('configure',qw(-fill x -side bottom));
  }
  $edit->autosetmode();
  $edit->columnWidth(0,'');
  $edit->columnWidth(1,'');
  $edit->columnWidth(2,'') if $edit->cget('-columns')>2;
  $edit->update;

  $edit->Tk::pack('configure',qw(-expand 1 -fill both));
  $edit->configure(-sizecmd => [$edit,'_resize']);
  if ($opts->{no_focus}) {
    $edit->configure('-takefocus'=>0);
  } else {
    $edit->focus;
    if (defined $opts->{focus}) {
      eval{ $edit->select_entry($opts->{focus}); };
    } elsif (length $attr_path) {
      eval{ $edit->select_entry($attr_name); };
    } else {
      my ($first)=$edit->info('children');
      eval{ $edit->select_entry($first); } if $first;
    }
  }
  unless ($opts->{dialog}) {
    $d->bind('all','<Tab>','focusNext');
    $d->bind('all','<<LeftTab>>','focusPrev');
    $d->BindButtons();
    for ($d, $edit) {
      $d->BindReturn($_);
      $d->BindEscape($_);
    }
  }
  $mw->Unbusy();

  my $result;
  my $flags = $opts->{validate_flags};
  $flags = PML_VALIDATE_NO_TREES unless defined $flags;
  if ($opts->{no_show}) {
    return $opts->{dialog} ? $edit : $d;
  }

  while (($result = $d->Show) eq $ok_button) {
    # validating data
    my $val = UNIVERSAL::DOES::does($obj,'Treex::PML::Node') ? ref($obj)->new() : {};
    $edit->apply_to_object($val,undef,0);
    my @log;
    if (length $attr_path) {
      my $v = $val->{$attr_name}; # the actual value
      if ($is_required or
	  (defined $v and (ref $v or length $v))) {
	$data_type->validate_object($v,
				    { path => $attr_path,
				      log => \@log,
				      flags => $flags,
				    });
      }
    } else {
      $data_type->validate_object( $val, { log => \@log,
					   flags => $flags,
					  } );
    }
    if (@log and
	  $mw->ErrorReport(
	    -title => "Invalid attribute values",
	    -message => "Validation of the following attributes failed.\n".
	      "Do not save your file in this state, you may not be able to open it again.",
	    -body => join("\n",@log),
	    -buttons => ["Edit attributes","Ignore these errors"]
	   ) !~ /Ignore/) {
      my ($err_path) = split /:/,$log[0];
      my $base_path = $edit->get_base_path;
      $err_path =~ s{^\Q$base_path\E/?}{};
      if (length $err_path) {
	eval {
	  $edit->select_entry($err_path);
	};
	warn $@ if $@;
      }
      eval {
	if ($edit->cget('-takefocus')) {
	  $edit->focus;
	}
      }; warn $@ if $@;
    } else {
      # setting the data
      my $set_data = sub {
	if (length $attr_path) {
	  unless (defined($val)) { # otherwise we reuse val from validation above
	    $val = {};
	    $edit->apply_to_object($val,undef,1);
	  }
	  Treex::PML::Instance::set_data($obj,$attr_path,$val->{$attr_name});
	} else {
	  $edit->apply_to_object($obj,undef,1);
	}
      };
      if ($opts->{set_command}) {
	$opts->{set_command}->($set_data,$edit);
      } else{
	&$set_data();
      }
      last;
    }
  }
  $edit->clear();
  $d->destroy() unless $opts->{dialog};
  return $result eq $ok_button ? 1 : 0;
}

# associate the editor with data (object, type, etc.)
sub set_data {
  my ($edit,$opts)=@_;
  my $base_type = $opts->{type};
  my $attr_path = $opts->{path};
  my $obj = $opts->{object};
  $edit->empty;
  $edit->{userdata}{hide_empty}=$opts->{hide_empty} if defined $opts->{hide_empty};
  return unless defined $obj and defined $base_type;
  my $data_type = length $attr_path
    ? $base_type->find($attr_path,1)
    : $base_type;
  unless (defined $data_type) {
    croak("Unknown attribute '$attr_path' on type '$base_type'");
  }

  # reset longest attr_val-ues for determining the width of column 1
  $edit->{userdata}{item_max_length_text} = "";
  $edit->{userdata}{item_max_length} = 0;

  my $schema = $base_type->get_schema;
  $edit->set_schema($schema);
  my $attr_name = $attr_path;
  my $base_path = (length $attr_name and $attr_name =~ s{(.*/)}{}) ? $1 : '';
  $edit->set_base_path( $base_path );
  my %allow_empty = map { $_ => 1 } ($opts->{allow_empty}||[]);
  my $is_required = 1;
  if (length $attr_path) {
    my $decl_type = $data_type->get_decl_type;
    if (($decl_type == PML_MEMBER_DECL() or
	 $decl_type == PML_ATTRIBUTE_DECL()) and
	!$data_type->is_required) {
      $is_required = 0;
    }
    $edit->add_member({
      #	path type data name allow_empty entry_opts required label
      path => '',
      type => $data_type,
      data => Treex::PML::Instance::get_data($obj,$attr_path)||undef,
      name => $attr_name,
      allow_empty => $allow_empty{$attr_name}||0,
        # expanding all sub-structures could break validity (!)
      required => $is_required,
     });
  } else {
    # 1=allow empty (don't create empty structures)
    my $type_is =  $data_type->get_decl_type();
    if ($type_is == PML_STRUCTURE_DECL or $type_is == PML_CONTAINER_DECL) {
      $edit->add_members({
	path => '',
	type => $data_type,
	data => $obj,
	allow_empty => $allow_empty{$attr_name}||0,
	# expanding all sub-structures could break validity (!)
      });
    } else {
      $edit->add_member({
	path => '',
	type => $data_type,
	data => $obj,
	name => ($opts->{object_name} || 'value'),
	allow_empty => $allow_empty{$attr_name}||0,
      });
    }
  }
  return ($attr_name,$data_type,$is_required);
}

1;
__END__

=head1 NAME

Tk::TrEdNodeEdit - editor of PML data structures

=head1 SYNOPSIS

   use Tk::TrEdNodeEdit;
   my $mw = Tk::MainWindow->new();

   # high-level API

   my $ok = $mw->TrEdNodeEditDlg(
    title => "Edit data,
    type => $pml_type_decl,
    object => $pml_object,
    path => $attribute_path,
    # ... options ...
   );
   if ($ok) {
     print "User edited the object adn pressed OK!"
   }

   # low-level API

   my $editor = $mw->Scrolled('TrEdNodeEdit');
   # $editor->set_option( name   => $value);    # ... configure options
   # $editor->set_callback( name => $callback); # ... configure callbacks
   $editor->set_data({
     type => $pml_type_decl,
     object => $pml_object,
     path => $attribute_path,
     #  allow_empty => 1,
     #  hide_empty => 0,
     #  object_name => 'label',
   });
   # Tk:Tree setup
   eval {
     $edit->autosetmode();
     $edit->columnWidth($_,'') for 0..2;
   };
   $edit->update();
   $editor->pack();


=head1 DESCRIPTION

This module implements an editor for PML data structures based on a
hierarchical list widget (Tk::Tree).

This API works with so called attribute paths, described in the
C<Treex::PML::Instance> documentation.

=head2 HIGH LEVEL API

=over 5

=item $widget->Tk::Widget::TrEdNodeEditDlg

  my $ok = $mw->TrEdNodeEditDlg( option=>value, ... );

This highly configurable-level Tk::Widget method provides a
hilgh-level API to the editor.  It wraps the editor into a dialog
window (new or passed by the user), shows the dialog and if the user
modifies the data and presses OK, apply the corresponding changes to
the edited data structure.

Returns value: if C<no_show> option is true, the method returns a
Tk::DialogBox object. Otherwise, a boolean value is returned
indicating whether the user applied the changes (by pressing OK or
another confirmation button) or not (e.g. by closing the window or
pressing Cancel).

The following options can be passed to the method:

=over 8

=item title

Window title.

=item dialog

A Tk::DialogBox object; if omitted, a new one is created.

=item search_field

Boolean: whether or not to include a search field which displays the
path to the currently focused item and which the user can use to focus
an item by path.

=item object

A PML data structure (Treex::PML::*).

=item type

A Treex::PML::Schema::Decl object representing the data type of the object.

=item path

If specified, the editor will be narrowed to a sub-structure or
attribute of C<object> given by the attribute path. No other data from
the C<object> will be shown to the user.


=item focus

An attribute path of an item to focus when the dialog is first shown.

=item TrEdNodeEdit

    TrEdNodeEdit => { -background => 'green', -relief => 'sunken', ... },

A hash reference with options to be passed to the C<TrEdNodeEdit>
widget.

=item buttons

    buttons => [qw(Finish Help Cancel)],

An array reference of labels of buttons to create. Defaults to C<<< [qw(OK Cancel)] >>>.

=item ok_button

    ok_button => 'Finish',

A label of the button that the users uses to confirm the changes. If not given, 'OK' is assumed.

Note: it is safe to specify C<buttons> as C<<< [qw(Cancel)] >> and leave
C<ok_button> empty or specified as C<OK>.  The user, however, will not
be able to apply the changes.

=item buttons_configure

    buttons_configure => {
      Help => sub {
        my $b = shift;
        $b->configure(
          -foreground=>"blue",
          -command => [\&show_help,$b->toplevel,'EDIT_DATA']
        );
      },
    }

This option can be used to customize the buttons.
A hash reference where each key => value element is used as follows:
the key is a button label and the value is either a hash or array
reference to be applied to that button using the widget's
C<configure()> method, or a CODE reference which will be called with
the button as the first argument when after the button is created.

=item set_command

    set_command => sub {
      my ($callback, $editor)=@_;
      if (run_internal_checks($editor->get_current_value('/'))) {
        print "Changing object data!\n";
        &$callback();
        print "Object changed!\n";
      } else {
        print "Ignoring changes!\n";
      }
    },

A user's callback subroutine to be called when the user confirms the
changes, and all internal validation performed by TrEdNodeEdit based
on the PML data types passed and the editor widget is about to apply
the changes to the object. The user's callback obtains one argument,
which is a callback back to the TrEdNodeEdit which performs the
changes.The default C<set_command> implementation simply calls the
passed callback: C<< sub { shift()->() } >>

=item knit_support

Whether the TrEdNodeEdit should obey the PML role #KNIT.

=item allow_empty

An array reference containing attribute paths of attributes that the
editor should not expand and initialize with empty values (e.g. an
empty structure) if undefined.

=item no_show

A boolean value; if true, the method Show() will not called on the dialog box; instead
the Tk::DialogBox object will be returned.

=item enable_callback

    enable_callback => [ sub {
			   my (...extra-agrs..., $path)=@_;
                           return $path eq 'id' ? 0 : 1
			 }, ...extra-args...
                      ],

A callback function which is consulted for each item in
order to determine whether the item can be editied (enable - true
value returned) or not (disable - false value returned). The following
arguments are passed to the callback: an attribute path of the item,
Treex::PML::Schema::Decl object.

=item hide_callback

Like C<enable_callback> except that items to which the callback
responds with a false value are completely hidden.

=item choices_callback

    choices_callback => [ sub {
			   my (..extra-args...,$path,$mtype,$this_dlg)=@_;
			   return ['a'...'z'] if $path =~ m{/letter};
			 }, ...extra-args... ],

A callback function which is consulted for each text (CDATA) item in
order to obtain a list of pre-defined values to offer to the user in a
list box.

The following arguments are passed to the callback: an attribute path
of the item, Treex::PML::Schema::Decl object, and the TrEdNodeEdit object,
which may be used e.g. to inspect current values e.g. in other
attributes.

=item validate_callback

    validate_callback => [ sub {
			   my (...extra-args...,$value,$path,$mtype,$editor)=@_;
                           if ($path eq 'address/ZIP') {
                             use Regexp::Common::zip;
                             my $country = $editor->get_current_value('address/Country');
                             return ($RE{zip}{$country}=~$value) ? 1 : 0;
                           }
                           return 1;
			 }, ...extra-args... ],

A callback function which is consulted each time the user modifies
some text value. If the callback returns false, the editor indicates
by coloring the item that the attribute value entered so far is not
valid (or incomplete).

The following arguments are passed to the callback: current value, an
attribute path of the item being edited, Treex::PML::Schema::Decl object, and the
TrEdNodeEdit object, which may be used e.g. to inspect current values
e.g. in other attributes.

=item attribute_sort_callback

    attribute_sort_callback => [ sub {
				   my (...extra-args...,$array,$path)=@_;
				   return reverse sort @$array;
				 }, ...extra-args... ],

This callback is consulted in order to provide ordering of items or
sub-items in the editor. See
also C<no_sort>.

The callback (if given) must return a list of attribute names in the order in which the
corresponding items should appear in the editor.  Note that the return
value is not an array reference!

The following arguments are passed to the callback: an array reference
with the attribute names to order and a base attribute path for the
item whose child items are being displayed.

=item value_sort_callback

    value_sort_callback => [ sub {
			       my (...extra-args...,$array,$path)=@_;
			       return sort { $a<=>$b } @$array if $path=~/amount/;
                               return;
			     }, ...extra-args... ],

This callback is consulted when a list box with a choice of values is
presented to the user in order to provide an ordering of the values.
See also C<no_value_sort>.

The callback (if given) must return a list of values in the
presentational order. Note that the return value is not an array
reference!

The following arguments are passed to the callback: an array reference
with the values to order and the attribute path for the item whose
possible values are being displayed.

=item no_sort

If true, ordering (either customised by the C<attribute_sort_callback>
or the default, alphabetical) of items (attributes) is disabled
and the ordering implied by the PML schema is used.

=item no_value_sort

If true, ordering (either customised by the C<attribute_sort_callback>
or the default, alphabetical) of values in drop-down list boxes is
disabled and the ordering implied by the PML schema is used.

=item password_map

A hash reference mapping attribute paths to boolean values. If this
hash maps an attribute path corresponding to a text item to a true
value, then a blind "password" inpunt entry widget (displaying stars
instead of the actual characters) is used instead of a normal entry
widget for editing.

=item validate_flags

  validate_flags => Treex::PML::Schema::PML_VALIDATE_NO_TREES|Treex::PML::Schema::PML_VALIDATE_NO_CHILDNODES,

Extra flags for the Treex::PML::Schema-based validation applied to the edited
object before the editor permits the assignment (see
Treex::PML::Schema::validate_object).

=back

=back

=head2 LOW LEVEL API

=over 5

=item $widget->Tk::Widget::TrEdNodeEdit

  my $editor = $mw->TrEdNodeEdit( -option=>value, ... );

This Tk::Widget method creates a new editor widget, which may be
controlled using the low-level API methods described below. Supported
options are similar to those of a Tk::Tree.

=item $editor->set_data(\%arguments)

Associate the editor with some object. The argument is a HASH
reference with the following keys:

   {
      # mandatory
      object => $object,
      type => $base_type,

      # optional:
      path => $attr_path,
      allow_empty => \%paths,
      hide_empty => $bool,
      object_name => $label, # label for the top-level item
   }

See similarly named TrEdNodeEditDlg() options for descriptions.

=item $editor->get_current_value($path)

Retrieve current value of an item specified by an attribute path.

=item $editor->apply($preserve_empty_values);

This method stores the content of the editor to the original object
and returns it. The optional C<preserve_empty_values> flag, if true,
indicates that values that are displayed in the GUI but left empty
(e.g. empty lists, or empty members of a structure) are to be stored
as empty rather than deleted from the object.

=item $editor->apply_to_object($object, $preserve_empty_values, $embed_original_structures)

Like C<$editor->apply()> but allows the data to be stored into an
object specified by the user rather than the original object. The
C<embed_original_structures>, if true, forces the nested data objects
(lists, sequences, structures, etc) from the original object to be
reused rather than copied when populating the new object.

=item $editor->set_option($option => $value)

Set an editor option. Recognized options are knit_support, no_sort,
no_value_sort, password_map, allow_trees (see description in
TrEdNodeEditDlg).

=item $editor->get_option($option)

Get an editor option, see above.

=item $editor->get_schema()

Returns a PML schema to which the data type associated with the edited
object belongs to.

=item $editor->set_schema($pml_schema)

Set PML schema to which the data type associated with the edited
object belongs to.

=item $editor->get_base_path()

Get base attribute path (see the C<path> option of C<TrEdNodeEditDlg()>).

=item $editor->set_base_path($path)

Set base attribute path (see the C<path> option of C<TrEdNodeEditDlg()>).

=item get_callback( $callback_name )

Get a subroutine (or other type of Tk-like callback) associated with a given type of callback.  See
C<TrEdNodeEditDlg()> for a list of supported callbacks. Note that in
this method, the callbacks names occur without the trailing
C<_callback> suffix.

=item $editor->set_callback( $callback_name => $sub )

Associate a subroutine (or other type of Tk-like callback) with a
given type of callback.  See C<TrEdNodeEditDlg()> for a list of
supported callbacks. Note that in this method, the callbacks names
occur without the trailing C<_callback> suffix.

=item $editor->adjust_size()

Update the widget and the parent widget and set the column width of
the second (value) column to fit.

=item $editor->select_entry($path)

Set focus to a the item specified by a given path.

=item $editor->empty()

Empty the widget by deleting all items (does not modify the edited
object); the widget can then be reused for another object.

=item $editor->add_search_field($parent)

Create a search field associated with the editor widget parented in a
given parent.




=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

